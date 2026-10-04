# Testing a Repository Adapter — EXCEPTION ONLY

> **Use this template ONLY for adapter-specific behavior not observable through routes** (raw SQL, JSONB queries, `ON CONFLICT` upserts, migration edge cases). Behavior reachable via a route is tested from the router — see `router-test.md`.

Adapter test against a real testcontainers Postgres. Real TypeORM, real entity, no mocks. Docker is a hard requirement — fail fast when it is unavailable.

```typescript
import { PostgreSqlContainer, StartedPostgreSqlContainer } from '@testcontainers/postgresql'
import { DataSource } from 'typeorm'
import { TypeOrmUserRepository } from './typeorm-user.repository'
import { UserEntity } from './user.entity'

describe('TypeOrmUserRepository', () => {
  let container: StartedPostgreSqlContainer
  let ds: DataSource
  let repository: TypeOrmUserRepository

  beforeAll(async () => {
    try {
      container = await new PostgreSqlContainer('postgres:16-alpine').start()
    } catch (err) {
      throw new Error(
        'Docker is required to run the test suite (testcontainers PostgreSQL). Start Docker and re-run the tests.'
      )
    }

    ds = new DataSource({
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

    repository = new TypeOrmUserRepository(ds)
  })

  afterAll(async () => {
    await ds.destroy()
    await container.stop()
  })

  afterEach(async () => {
    await ds.getRepository(UserEntity).clear()
  })

  it('persists and retrieves a user by id', async () => {
    const id = crypto.randomUUID()
    await repository.save({ id, email: 'test@example.com', name: 'John Doe' })

    const found = await repository.findById(id)
    expect(found).not.toBeNull()
    expect(found!.email).toBe('test@example.com')
  })

  it('returns null when user does not exist', async () => {
    const found = await repository.findById(crypto.randomUUID())
    expect(found).toBeNull()
  })
})
```
