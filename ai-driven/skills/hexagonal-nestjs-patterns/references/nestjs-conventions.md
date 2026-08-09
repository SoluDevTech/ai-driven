# NestJS Conventions

DI, modules, guards, exception filters, middleware, Swagger. Load before wiring NestJS-specific code.

## Dependency Injection
- **Constructor injection** everywhere
- **Injection tokens** (symbols) for ports so application never imports adapters
- `@Inject(TOKEN)` for port dependencies

```typescript
@Injectable()
export class CreateUserUseCase {
  constructor(
    @Inject(USER_REPOSITORY) private users: UserRepository,
    @Inject(EMAIL_SENDER) private emails: EmailSender,
  ) {}
}
```

## Module organization
- One module per bounded context (application) or per infrastructure adapter
- Infrastructure modules `provide` the adapter and `export` the port token

```typescript
@Module({
  imports: [TypeOrmModule.forFeature([UserModel])],
  providers: [
    { provide: USER_REPOSITORY, useClass: PostgresUserRepository },
  ],
  exports: [USER_REPOSITORY],
})
export class PostgresUserModule {}
```

```typescript
@Module({
  imports: [PostgresUserModule, EmailModule],
  providers: [CreateUserUseCase, UserController],
})
export class UserModule {}
```

## Thin controllers
Delegate all logic to use cases. Controllers only: parse request, call use case, return result.

```typescript
@Controller("users")
export class UserController {
  constructor(private createUser: CreateUserUseCase) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body(new ZodValidationPipe(CreateUserRequestSchema)) body: CreateUserRequest) {
    return this.createUser.execute(body);
  }
}
```

## Exception filters
Map domain exceptions to HTTP exceptions with `@Catch()`. Keep the mapping in one place.

```typescript
@Catch(DomainError)
export class DomainExceptionFilter implements ExceptionFilter {
  catch(err: DomainError, host: ArgumentHost) {
    const res = host.switchToHttp().getResponse<Response>();

    const status: Record<string, number> = {
      USER_NOT_FOUND: HttpStatus.NOT_FOUND,
      USER_ALREADY_EXISTS: HttpStatus.CONFLICT,
      INVALID_USER_INPUT: HttpStatus.BAD_REQUEST,
    };

    res.status(status[err.code] ?? HttpStatus.INTERNAL_SERVER_ERROR).json({
      code: err.code,
      message: err.message,
    });
  }
}

// main.ts
app.useGlobalFilters(new DomainExceptionFilter());
```

## Guards
Authentication and authorization with `@UseGuards()`.

```typescript
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private jwt: JwtService) {}

  canActivate(ctx: ExecutionContext): boolean {
    const req = ctx.switchToHttp().getRequest<Request>();
    const token = extractBearer(req);
    if (!token) return false;
    try {
      req.user = this.jwt.verify(token);
      return true;
    } catch {
      return false;
    }
  }
}

@UseGuards(JwtAuthGuard)
@Controller("users")
export class UserController {}
```

## Middleware
Request ID, logging, CORS, security headers.

```typescript
@Injectable()
export class RequestIdMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const id = req.headers["x-request-id"] ?? crypto.randomUUID();
    req.id = id;
    res.setHeader("x-request-id", id);
    next();
  }
}

@Module({
  providers: [RequestIdMiddleware],
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(RequestIdMiddleware).forRoutes("*");
  },
})
export class AppModule {}
```

## Swagger with zod-openapi
Use `@anatine/zod-openapi` for automatic OpenAPI documentation from Zod schemas.

```typescript
// main.ts
const config = new DocumentBuilder().setTitle("My API").setVersion("1.0").build();
const document = SwaggerModule.createDocument(app, config);
SwaggerModule.setup("docs", app, document);
```

## Configuration
`@nestjs/config` with Zod validation at bootstrap.

```typescript
@Module({
  imports: [ConfigModule.forRoot({ validate: (env) => EnvSchema.parse(env) })],
})
export class AppModule {}
```

## Lifecycle hooks
Use `OnModuleInit` / `OnModuleDestroy` for resource setup/teardown (DB connections, queues).

```typescript
@Injectable()
export class DatabaseAdapter implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() { await this.dataSource.initialize(); }
  async onModuleDestroy() { await this.dataSource.destroy(); }
}
```

## Performance patterns
- Caching with `CacheModule` / Redis
- Background jobs with Bull queues
- Connection pooling (TypeOrm default pool, Mongoose poolSize)
- Pagination for list endpoints: `limit`/`offset` or cursor-based