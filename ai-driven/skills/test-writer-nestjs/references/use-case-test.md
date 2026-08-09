# Testing a Use Case (SQLite in-memory)

Real TypeORM repository backed by SQLite `:memory:`; external email adapter mocked via factory. AAA pattern.

```typescript
import { Test, TestingModule } from '@nestjs/testing'
import { TypeOrmModule, getRepositoryToken } from '@nestjs/typeorm'
import { DataSource } from 'typeorm'
import { CreateUserUseCase } from './create-user.use-case'
import { CreateUserRequest } from './create-user.request'
import { TypeOrmUserRepository } from '@/infrastructure/persistence/typeorm-user.repository'
import { UserEntity } from '@/infrastructure/persistence/user.entity'
import { DuplicateEmailError } from '@/domain/errors/duplicate-email.error'
import { mockEmailSuccess, mockEmailTimeout } from '@/test/fixtures/external'

describe('CreateUserUseCase', () => {
  let module: TestingModule
  let useCase: CreateUserUseCase
  let dataSource: DataSource

  const validRequest: CreateUserRequest = {
    email: 'test@example.com',
    name: 'John Doe',
  }

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
    // Re-create module with timeout mock
    await module.close()
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
      providers: [CreateUserUseCase, TypeOrmUserRepository, mockEmailTimeout()],
    }).compile()

    useCase = module.get(CreateUserUseCase)
    const result = await useCase.execute(validRequest)
    expect(result).toBeDefined()
  })
})
```

## Reasoning example
> "`CreateOrderUseCase` depends on `TypeOrmOrderRepository` (internal → real impl, SQLite in-memory) and `StripeAdapter` (external → `mockStripeSuccess()` / `mockStripeDeclined()` factory). I test the use case behavior in each payment scenario using the real repository backed by an in-memory SQLite database, wired via `Test.createTestingModule`."