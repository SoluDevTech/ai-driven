# Zod Usage

Zod for entity validation, application DTOs, controllers, and configuration. Load before writing validation.

## Domain entities
Use Zod schemas in constructors for validation. Infer the props type with `z.infer`.

```typescript
// domain/entities/User.ts
import { z } from "zod";

export const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  displayName: z.string().min(1).max(100),
  role: z.enum(["admin", "member", "viewer"]),
  createdAt: z.date(),
});

export type UserProps = z.infer<typeof UserSchema>;

export class User {
  private constructor(public readonly props: UserProps) {}

  static create(props: UserProps): User {
    UserSchema.parse(props);
    return new User(props);
  }
}
```

## Application DTOs
Define Zod schemas in `application/requests/` and `application/responses/`; infer types with `z.infer`.

```typescript
// application/requests/CreateUserRequest.ts
import { z } from "zod";

export const CreateUserRequestSchema = z.object({
  email: z.string().email(),
  displayName: z.string().min(1).max(100),
});

export type CreateUserRequest = z.infer<typeof CreateUserRequestSchema>;
```

```typescript
// application/responses/UserResponse.ts — only when serialization is required
import { z } from "zod";

export const UserResponseSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  displayName: z.string(),
});

export type UserResponse = z.infer<typeof UserResponseSchema>;
```

## Controllers — ZodValidationPipe
Use a `ZodValidationPipe` for request validation.

```typescript
// shared/pipes/ZodValidationPipe.ts
import { PipeTransform } from "@nestjs/common";
import { ZodSchema } from "zod";

export class ZodValidationPipe<T> implements PipeTransform {
  constructor(private schema: ZodSchema<T>) {}

  transform(value: unknown) {
    return this.schema.parse(value);
  }
}

// application/controllers/UserController.ts
@Post()
async create(@Body(new ZodValidationPipe(CreateUserRequestSchema)) body: CreateUserRequest) {
  return this.createUser.execute(body);
}
```

## Configuration
Validate environment variables with a Zod schema.

```typescript
// config/configuration.ts
import { z } from "zod";

const EnvSchema = z.object({
  PORT: z.coerce.number().default(3000),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  NODE_ENV: z.enum(["development", "test", "production"]),
});

export type Env = z.infer<typeof EnvSchema>;

export function validateEnv(processEnv: NodeJS.ProcessEnv): Env {
  return EnvSchema.parse(processEnv);
}
```

```typescript
// main.ts
import { validateEnv } from "./config/configuration";

const env = validateEnv(process.env);
const app = await NestFactory.create(AppModule);
await app.listen(env.PORT);
```

## Reuse schemas
- `.extend()` — add fields to an existing schema
- `.pick()` / `.omit()` — select/drop fields
- `.partial()` — make all optional
- `.refine()` — complex business rules
- `.transform()` — normalize data

```typescript
const UpdateUserRequest = CreateUserRequestSchema.partial();
const UserRegistration = CreateUserRequestSchema.extend({ password: z.string().min(12) });

const StrictEmail = z.string().email().refine((e) => !e.endsWith("@temp.com"), {
  message: "Temporary emails are not allowed",
});

const NormalizedEmail = z.string().email().transform((e) => e.toLowerCase().trim());
```

## Swagger via zod-openapi
Use `@anatine/zod-openapi` to generate OpenAPI docs from the same Zod schemas you use for validation.

```typescript
import { zodToOpenAPI } from "@anatine/zod-openapi";

const openApiSchema = zodToOpenAPI(CreateUserRequestSchema);
```

## Common pitfalls
- Don't put Zod schemas in `infrastructure/` — they belong in `domain/` (entities) or `application/` (DTOs)
- Don't call `.parse()` twice — entities already validate in their `create()` factory
- Don't infer DTO types from entity schemas when the DTO is a subset — define a separate schema
- Don't use `.refine()` for synchronous DB checks; do those in the use case