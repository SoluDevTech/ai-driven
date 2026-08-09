# Layer Rules

Detailed rules per layer. Load before writing code in a given layer.

## Domain Layer
- **Pure TypeScript + Zod only** — no NestJS decorators, no TypeORM, no Mongoose
- **Entities**: classes with Zod schemas for validation in constructors
- **Ports**: abstract classes (interfaces don't exist at runtime in TS). Split into `inbound/` (use case entry points) and `outbound/` (infrastructure contracts)
- **Services** (optional): pure domain logic when use cases get heavy
- **Errors**: centralised custom exception hierarchy (inherit from base domain exception)
- **Logging**: centralised log message constants

```typescript
// domain/entities/User.ts
import { z } from "zod";

export const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  displayName: z.string().min(1).max(100),
  role: z.enum(["admin", "member", "viewer"]),
});

export type UserProps = z.infer<typeof UserSchema>;

export class User {
  private constructor(
    public readonly id: string,
    public readonly email: string,
    public readonly displayName: string,
    public readonly role: "admin" | "member" | "viewer",
  ) {}

  static create(props: UserProps): User {
    UserSchema.parse(props);
    return new User(props.id, props.email, props.displayName, props.role);
  }
}
```

```typescript
// domain/errors/DomainError.ts
export abstract class DomainError extends Error {
  constructor(message: string, public readonly code: string) {
    super(message);
    this.name = this.constructor.name;
  }
}

export class UserNotFoundError extends DomainError {
  constructor(id: string) {
    super(`User ${id} not found`, "USER_NOT_FOUND");
  }
}
```

## Application Layer
- **Use cases**: injectable services (`@Injectable()`), one class = one business action. Implement inbound ports.
- **Controllers**: thin — delegate all logic to use cases. Return domain entities directly (no Response DTOs unless serialization is genuinely needed)
- **Request DTOs**: Zod schemas in `application/requests/`; infer types with `z.infer`
- **Response DTOs**: only when you must reshape/serialize (e.g. hide internal fields). Default = return the domain entity.

```typescript
// application/use-cases/CreateUserUseCase.ts
import { Inject, Injectable } from "@nestjs/common";
import { USER_REPOSITORY } from "@/domain/ports/outbound/tokens";
import type { UserRepository } from "@/domain/ports/outbound/UserRepository";
import { User } from "@/domain/entities/User";

@Injectable()
export class CreateUserUseCase {
  constructor(@Inject(USER_REPOSITORY) private users: UserRepository) {}

  async execute(input: { email: string; displayName: string }): Promise<User> {
    const user = User.create({
      id: crypto.randomUUID(),
      email: input.email,
      displayName: input.displayName,
      role: "member",
    });
    await this.users.save(user);
    return user;
  }
}
```

```typescript
// application/controllers/UserController.ts
import { Body, Controller, Post } from "@nestjs/common";
import { CreateUserUseCase } from "@/application/use-cases/CreateUserUseCase";
import { CreateUserRequest } from "@/application/requests/CreateUserRequest";

@Controller("users")
export class UserController {
  constructor(private createUser: CreateUserUseCase) {}

  @Post()
  async create(@Body() body: CreateUserRequest) {
    return this.createUser.execute(body);
  }
}
```

### KISS data transformations
- Direct object spreading: `new Entity({ ...data })`
- Avoid intermediate transformation methods (`fromEntity`, `toEntity`)
- Validate at boundaries with Zod schemas
- Keep transformations simple and readable

```typescript
// GOOD
const userEntity = User.create({ ...createUserDto, id: crypto.randomUUID() });
const dbUser = new UserModel({ ...userEntity });

// BAD
const userEntity = User.fromDto(createUserDto);
const dbUser = UserModel.fromEntity(userEntity);
```

## Infrastructure Layer
- **One folder per implementation**: `postgres/`, `mongodb/`, `email/`
- Each folder contains:
  - `adapter.ts` — implements the domain outbound port
  - `entities/` (TypeORM) or `schemas/` (Mongoose) — persistence models
  - `module.ts` — NestJS module wiring the adapter to the port token
- Use injection tokens for dependency inversion
- Transform persistence models to domain entities with `model_validate`-style direct spread

```typescript
// infrastructure/postgres/UserRepositoryAdapter.ts
import { Inject } from "@nestjs/common";
import { DataSource } from "typeorm";
import { USER_REPOSITORY } from "@/domain/ports/outbound/tokens";
import type { UserRepository } from "@/domain/ports/outbound/UserRepository";
import { User } from "@/domain/entities/User";
import { UserModel } from "./entities/UserModel";

export class PostgresUserRepository implements UserRepository {
  constructor(private db: DataSource) {}

  async findById(id: string) {
    const row = await this.db.getRepository(UserModel).findOne({ where: { id } });
    return row ? User.create({ ...row }) : null;
  }

  async save(user: User) {
    await this.db.getRepository(UserModel).save({ ...user });
  }
}
```

```typescript
// infrastructure/postgres/PostgresModule.ts
import { Module } from "@nestjs/common";
import { DataSource } from "typeorm";
import { USER_REPOSITORY } from "@/domain/ports/outbound/tokens";
import { PostgresUserRepository } from "./UserRepositoryAdapter";

@Module({
  providers: [
    { provide: USER_REPOSITORY, useFactory: (db: DataSource) => new PostgresUserRepository(db), inject: [DataSource] },
  ],
  exports: [USER_REPOSITORY],
})
export class PostgresModule {}
```

## Testing
**Golden rule** — real implementations for all internal components; mocks only for outbound adapters toward external systems.

- **Real implementations**: use the real use case, real domain entity, and the real infrastructure adapter against an in-memory or disposable database for everything inside the application boundary
- **Mocks**: only for outbound adapters toward external systems (third-party APIs, email services, S3, Stripe, payment gateways, etc.)
- **Why real**: a stub/fake that diverges silently from the real implementation produces tests that pass but don't detect real regressions. Mocking only the network/external boundary keeps the cost low and confidence high.

```typescript
// ✅ REAL IMPLEMENTATION — for ALL internal components
const module = await Test.createTestingModule({
  imports: [TypeOrmModule.forFeature([UserModel])],
  providers: [
    CreateUserUseCase,
    { provide: USER_REPOSITORY, useClass: PostgresUserRepository },
  ],
})
  .overrideProvider(DataSource)
  .useValue(inMemorySqlite()) // real DB, in-memory
  .compile();

const useCase = module.get(CreateUserUseCase);
const user = await useCase.execute({ email: "a@b.c", displayName: "Ada" });
expect(user.email).toBe("a@b.c");

// Verify real persistence
const repo = module.get(USER_REPOSITORY) as PostgresUserRepository;
const saved = await repo.findById(user.id);
expect(saved?.email).toBe("a@b.c");
```

```typescript
// ✅ MOCK — ONLY for external outbound adapters
const module = await Test.createTestingModule({
  providers: [
    CreateUserUseCase,
    { provide: USER_REPOSITORY, useClass: PostgresUserRepository }, // real
    { provide: EMAIL_SENDER, useValue: { send: jest.fn().mockResolvedValue(true) } }, // mocked
  ],
})
  .overrideProvider(DataSource)
  .useValue(inMemorySqlite())
  .compile();

// Sendgrid is mocked; the repo and use case are real
```

### In-memory adapters (allowed)
In-memory adapters for tests are **real implementations** of the domain port, not mocks. They must satisfy the same port contract.

```typescript
// tests/doubles/InMemoryUserRepository.ts — real implementation of UserRepository
export class InMemoryUserRepository implements UserRepository {
  private users = new Map<string, User>();
  async findById(id: string) { return this.users.get(id) ?? null; }
  async save(user: User) { this.users.set(user.id, user); }
}
```

### Test framework
- Jest + ts-jest
- Minimum coverage: 80%
- Use `Test.createTestingModule()` to override providers (with real implementations, not mocks, for internal components)