# Testing a Repository Adapter (optional)

Adapter test against in-memory SQLite. Real TypeORM, real entity, no mocks.

```typescript
import { Test, TestingModule } from '@nestjs/testing'
import { TypeOrmModule, getRepositoryToken } from '@nestjs/typeorm'
import { TypeOrmUserRepository } from './typeorm-user.repository'
import { UserEntity } from './user.entity'

describe('TypeOrmUserRepository', () => {
  let module: TestingModule
  let repository: TypeOrmUserRepository

  beforeEach(async () => {
    module = await Test.createTestingModule({
      imports: [
        TypeOrmModule.forRoot({
          type: 'sqlite',
          database: ':memory:',
          entities: [UserEntity],
          synchronize: true,
        }),
        TypeOrmModule.forFeature([UserEntity]),
      ],
      providers: [TypeOrmUserRepository],
    }).compile()

    repository = module.get(TypeOrmUserRepository)
  })

  afterEach(async () => {
    await module.close()
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