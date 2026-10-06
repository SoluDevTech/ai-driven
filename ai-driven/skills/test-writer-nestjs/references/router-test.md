# Behavioral Test from the Router (PRIMARY template)

Supertest against the REAL `AppModule` — the full chain runs real (Controller → Use Case → Port → Repository) with a testcontainers Postgres behind it. Only external outbound adapters are mocked via `overrideProvider`. Configure the app exactly as production (`useGlobalPipes`, `useGlobalFilters`).

- **Act** = one HTTP call via Supertest on `app.getHttpServer()`
- **Assert** = status code + response body + persistence in the real table
- **Infra** = real Postgres via testcontainers (see `testcontainers.md`)
- **Externals** = the ONLY mocked boundary, via `overrideProvider` on the adapter class

## Test structure
```
test/
├── setup.ts                       # shared bootstrap (real AppModule + testcontainers) + auth helpers
├── fixtures/
│   └── external.ts                # jest.fn() factories for external adapters (configurable failures)
├── behavioral/                    # Behavioral tests from the router (main focus)
│   └── <feature>/
│       ├── create-user.spec.ts
│       └── get-user.spec.ts
└── unit/                          # ONLY: pure domain without HTTP entry, scripts, consumers
```

One file per endpoint, grouped by feature directory. Every branch of the endpoint lives in the same file.

## Behavioral test — real AppModule + testcontainers PG

```typescript
# test/behavioral/users/create-user.spec.ts — one behavioral spec per endpoint
import { Test } from '@nestjs/testing'
import { INestApplication, ValidationPipe } from '@nestjs/common'
import * as request from 'supertest'
import { TypeOrmModule, getDataSourceToken } from '@nestjs/typeorm'
import { DataSource, Repository } from 'typeorm'
import { PostgreSqlContainer, StartedPostgreSqlContainer } from '@testcontainers/postgresql'
import { AppModule } from '@/app.module'                      // the REAL module — full chain wired
import { SendgridEmailAdapter } from '@/infrastructure/email/sendgrid-email.adapter'
import { UserEntity } from '@/infrastructure/persistence/user.entity'
import { mockEmail, mockEmailSuccess, mockEmailTimeout } from '@/test/fixtures/external'

describe('POST /users (behavioral)', () => {
  let app: INestApplication
  let container: StartedPostgreSqlContainer
  let dataSource: DataSource
  let users: Repository<UserEntity>

  beforeAll(async () => {
    container = await new PostgreSqlContainer('postgres:16-alpine').start()

    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],                                    // real chain — nothing re-declared
    })
      // Point the DataSource at the testcontainers instance — the ONLY infra override
      .overrideProvider(getDataSourceToken())
      .useFactory({
        factory: async () => {
          const ds = new DataSource({
            type: 'postgres',
            host: container.getHost(),
            port: container.getMappedPort(5432),
            username: container.getUsername(),
            password: container.getPassword(),
            database: container.getDatabase(),
            entities: [UserEntity],
            synchronize: true,
          })
          await ds.initialize()
          return ds
        },
      })
      // overrideProvider ONLY for external adapters
      .overrideProvider(SendgridEmailAdapter)
      .useValue({ send: jest.fn().mockResolvedValue(true) })
      .compile()

    app = moduleRef.createNestApplication()
    app.useGlobalPipes(new ValidationPipe({ whitelist: true }))   // same as production
    await app.init()

    dataSource = moduleRef.get(DataSource)
    users = dataSource.getRepository(UserEntity)
  })

  afterAll(async () => {
    await app.close()
    await dataSource.destroy()
    await container.stop()
  })

  afterEach(async () => {
    await users.clear()          // reset state, don't recreate the container
  })

  it('returns 201 with the created user and persists it', async () => {
    const response = await request(app.getHttpServer())
      .post('/users')
      .send({ email: 'test@example.com', name: 'John Doe' })
      .expect(201)

    expect(response.body).toMatchObject({ email: 'test@example.com', name: 'John Doe' })
    expect(response.body.id).toBeDefined()

    // Assert side effect — real persistence, real table
    const saved = await users.findOneBy({ id: response.body.id })
    expect(saved).not.toBeNull()
  })

  it('returns 409 when email already exists', async () => {
    // Arrange — seed via the API itself
    await request(app.getHttpServer()).post('/users').send({ email: 'test@example.com', name: 'John Doe' })

    // Act & Assert
    await request(app.getHttpServer())
      .post('/users')
      .send({ email: 'test@example.com', name: 'Another User' })
      .expect(409)
  })

  it('returns 400 when email is missing', async () => {
    await request(app.getHttpServer())
      .post('/users')
      .send({ name: 'John Doe' })
      .expect(400)
  })

  it('still returns 201 when the welcome email times out', async () => {
    // Rebuild the app with mockEmail('timeout') — same real chain, different external failure mode
    // (identical setup, only the .overrideProvider(SendgridEmailAdapter) factory changes)
    const response = await request(app.getHttpServer())
      .post('/users')
      .send({ email: 'test@example.com', name: 'John Doe' })
      .expect(201)

    expect(response.body.id).toBeDefined()
  })
})
```

## Rules
- **Import the real `AppModule`** — never re-declare controllers/use cases/repositories in the testing module; the only infra override is the DataSource pointing at the testcontainers instance
- **`overrideProvider` ONLY for external adapters** (email, Stripe, S3) — using it on an internal class invalidates the test
- **One container per file (or suite)** — amortize startup; reset data between tests (`users.clear()`), don't recreate the container
- **One spec file per endpoint** — `test/behavioral/<feature>/<endpoint>.spec.ts` holds every branch of that endpoint (happy path, validation, auth, conflicts, external failures)
- **Docker unavailable?** do NOT fall back to SQLite — wrap container startup in `try/catch` and fail fast with a clear error so the suite exits non-zero

## Reasoning example
> "POST /users wires UserController → CreateUserUseCase → UserRepository (port) → TypeOrmUserRepository, plus SendgridEmailAdapter (external → `mockEmail('success')` / `mockEmail('timeout')` factory). I write `test/behavioral/users/create-user.spec.ts`: one Supertest call per behavior against the real AppModule with a testcontainers Postgres, assert status + body, then verify persistence in the real table."
