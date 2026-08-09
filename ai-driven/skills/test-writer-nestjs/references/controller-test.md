# Testing a Controller (HTTP integration)

Supertest against a real Nest app instance. Configure the app the same way as production (`useGlobalPipes`, `useGlobalFilters`).

```typescript
import { Test, TestingModule } from '@nestjs/testing'
import { INestApplication, ValidationPipe } from '@nestjs/common'
import * as request from 'supertest'
import { TypeOrmModule } from '@nestjs/typeorm'
import { UserController } from './user.controller'
import { CreateUserUseCase } from '@/application/use-cases/create-user/create-user.use-case'
import { TypeOrmUserRepository } from '@/infrastructure/persistence/typeorm-user.repository'
import { UserEntity } from '@/infrastructure/persistence/user.entity'
import { mockEmailSuccess } from '@/test/fixtures/external'

describe('UserController', () => {
  let app: INestApplication

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      imports: [
        TypeOrmModule.forRoot({
          type: 'sqlite',
          database: ':memory:',
          entities: [UserEntity],
          synchronize: true,
        }),
        TypeOrmModule.forFeature([UserEntity]),
      ],
      controllers: [UserController],
      providers: [CreateUserUseCase, TypeOrmUserRepository, mockEmailSuccess()],
    }).compile()

    app = module.createNestApplication()
    app.useGlobalPipes(new ValidationPipe({ whitelist: true }))
    await app.init()
  })

  afterEach(async () => {
    await app.close()
  })

  describe('POST /users', () => {
    it('returns 201 with the created user', async () => {
      const response = await request(app.getHttpServer())
        .post('/users')
        .send({ email: 'test@example.com', name: 'John Doe' })
        .expect(201)

      expect(response.body).toMatchObject({
        email: 'test@example.com',
        name: 'John Doe',
      })
      expect(response.body.id).toBeDefined()
    })

    it('returns 409 when email already exists', async () => {
      await request(app.getHttpServer())
        .post('/users')
        .send({ email: 'test@example.com', name: 'John Doe' })

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
  })
})
```