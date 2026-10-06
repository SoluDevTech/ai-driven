# Testing a Use Case — EXCEPTION ONLY (`test/unit/`)

> **Use this template ONLY for logic that has NO HTTP route and NO processor/scheduler trigger** (cron-internal logic, pure domain algorithms). These tests live in `test/unit/`.
>
> Decision order:
> - Route exposes it → test from the router (`router-test.md`).
> - A queue processor/messaging consumer/scheduler triggers it → test via `processor-test.md` (real message/job in the real broker, observable side effects only) — do NOT instantiate the use case here.
> - Adapter/internal service → NEVER a direct test subject; its behavior is asserted through whichever entry point triggers it (or `repository-test.md` for adapter-specific SQL).
> - Pure domain with no entry point → direct unit test allowed (`test/unit/`).

Real TypeORM repository backed by testcontainers Postgres; external email adapter mocked via factory. AAA pattern. Docker is a hard requirement — no SQLite fallback.

```typescript
import { Test, TestingModule } from '@nestjs/testing'
import { TypeOrmModule } from '@nestjs/typeorm'
import { DataSource } from 'typeorm'
import { PostgreSqlContainer, StartedPostgreSqlContainer } from '@testcontainers/postgresql'
import { CreateUserUseCase } from './create-user.use-case'
import { CreateUserRequest } from './create-user.request'
import { TypeOrmUserRepository } from '@/infrastructure/persistence/typeorm-user.repository'
import { UserEntity } from '@/infrastructure/persistence/user.entity'
import { DuplicateEmailError } from '@/domain/errors/duplicate-email.error'
import { mockEmailSuccess, mockEmailTimeout } from '@/test/fixtures/external'

describe('CreateUserUseCase', () => {
  let container: StartedPostgreSqlContainer
  let module: TestingModule
  let useCase: CreateUserUseCase
  let dataSource: DataSource

  const validRequest: CreateUserRequest = {
    email: 'test@example.com',
    name: 'John Doe',
  }

  const pgDataSource = () =>
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: container.getHost(),
      port: container.getMappedPort(5432),
      username: container.getUsername(),
      password: container.getPassword(),
      database: container.getDatabase(),
      entities: [UserEntity],
      synchronize: true,
    })

  beforeAll(async () => {
    try {
      container = await new PostgreSqlContainer('postgres:16-alpine').start()
    } catch (err) {
      throw new Error(
        'Docker is required to run the test suite (testcontainers PostgreSQL). Start Docker and re-run the tests.'
      )
    }
  })

  afterAll(async () => {
    await container.stop()
  })

  beforeEach(async () => {
    module = await Test.createTestingModule({
      imports: [pgDataSource(), TypeOrmModule.forFeature([UserEntity])],
      providers: [
        CreateUserUseCase,
        TypeOrmUserRepository,
        mockEmailSuccess(),
      ],
    }).compile()

    useCase = module.get(CreateUserUseCase)
    dataSource = module.get(DataSource)
  })

  afterEach(async () => {
    await dataSource.getRepository(UserEntity).clear()
    await module.close()
  })

  it('creates and persists a new user', async () => {
    // Act
    const result = await useCase.execute(validRequest)

    // Assert
    expect(result.email).toBe(validRequest.email)
    expect(result.name).toBe(validRequest.name)

    // Verify real persistence
    const repository = module.get(TypeOrmUserRepository)
    const saved = await repository.findById(result.id)
    expect(saved).not.toBeNull()
    expect(saved!.email).toBe(validRequest.email)
  })

  it('raises DuplicateEmailError when email already exists', async () => {
    // Arrange — insert via real repository
    const repository = module.get(TypeOrmUserRepository)
    await repository.save({ id: crypto.randomUUID(), email: validRequest.email, name: 'Existing User' })

    // Act & Assert
    await expect(useCase.execute(validRequest)).rejects.toThrow(DuplicateEmailError)
  })

  it('sends a welcome email on successful creation', async () => {
    await useCase.execute(validRequest)

    const emailAdapter = module.get(SendgridEmailAdapter)
    expect(emailAdapter.send).toHaveBeenCalledOnce()
    expect(emailAdapter.send).toHaveBeenCalledWith(
      expect.objectContaining({ to: validRequest.email })
    )
  })

  it('does not fail when email delivery times out', async () => {
    // Re-create module with timeout mock — same real chain, different external mock
    await module.close()
    module = await Test.createTestingModule({
      imports: [pgDataSource(), TypeOrmModule.forFeature([UserEntity])],
      providers: [CreateUserUseCase, TypeOrmUserRepository, mockEmailTimeout()],
    }).compile()

    useCase = module.get(CreateUserUseCase)
    const result = await useCase.execute(validRequest)
    expect(result).toBeDefined()
  })
})
```

## Reasoning example
> "`CreateOrderUseCase` depends on `TypeOrmOrderRepository` (internal → real impl, testcontainers Postgres) and `StripeAdapter` (external → `mockStripeSuccess()` / `mockStripeDeclined()` factory). This use case has no HTTP entry point (queue consumer), so I test it directly with the real repository wired via `Test.createTestingModule`."
