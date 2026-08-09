# Async Interceptors, Pipes, Guards

Async middleware patterns in NestJS.

## Interceptors
Interceptors wrap controller calls. Use RxJS when transforming the response stream; use `async/await` for pre-handler side effects.

### Response transformation (RxJS)
```typescript
import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from "@nestjs/common";
import { map, Observable } from "rxjs";

@Injectable()
export class EnvelopeInterceptor implements NestInterceptor {
  intercept(_ctx: ExecutionContext, next: CallHandler): Observable<unknown> {
    return next.handle().pipe(
      map((data) => ({ ok: true, data })),
    );
  }
}
```

### Logging / timing
```typescript
@Injectable()
export class TimingInterceptor implements NestInterceptor {
  private logger = new Logger(TimingInterceptor.name);

  intercept(_ctx: ExecutionContext, next: CallHandler): Observable<unknown> {
    const start = Date.now();
    return next.handle().pipe(
      tap(() => this.logger.log(`+${Date.now() - start}ms`)),
    );
  }
}
```

### Async pre-handler side effect
```typescript
@Injectable()
export class RequestContextInterceptor implements NestInterceptor {
  constructor(private ctx: RequestContextService) {}

  async intercept(ctx: ExecutionContext, next: CallHandler) {
    const req = ctx.switchToHttp().getRequest<Request>();
    await this.ctx.begin(req.headers["x-request-id"] ?? crypto.randomUUID());
    return next.handle();
  }
}
```

### Caching interceptor
```typescript
@Injectable()
export class CacheInterceptor implements NestInterceptor {
  constructor(private cache: CacheService) {}

  async intercept(ctx: ExecutionContext, next: CallHandler) {
    const req = ctx.switchToHttp().getRequest<Request>();
    const cached = await this.cache.get(req.url);
    if (cached) return of(cached); // short-circuit the handler
    const result = await firstValueFrom(next.handle());
    await this.cache.set(req.url, result, { ttl: 60_000 });
    return of(result);
  }
}
```

### Global vs controller-scoped
```typescript
// global — main.ts
app.useGlobalInterceptors(new TimingInterceptor());

// per-controller
@UseInterceptors(EnvelopeInterceptor)
@Controller("users")
export class UserController {}
```

## Pipes
Pipes transform or validate input. Can be async.

```typescript
@Injectable()
export class ZodValidationPipe<T> implements PipeTransform {
  constructor(private schema: ZodSchema<T>) {}

  async transform(value: unknown) {
    return this.schema.parseAsync(value);
  }
}

@Post()
async create(@Body(new ZodValidationPipe(CreateUserRequestSchema)) body: CreateUserRequest) {
  return this.createUser.execute(body);
}
```

### Async data-fetching pipe
```typescript
@Injectable()
export class UserByIdPipe implements PipeTransform<string, Promise<User>> {
  constructor(@Inject(USER_REPOSITORY) private users: UserRepository) {}

  async transform(id: string) {
    const user = await this.users.findById(id);
    if (!user) throw new NotFoundException(`User ${id} not found`);
    return user;
  }
}

@Get(":id")
async get(@Param("id", UserByIdPipe) user: User) {
  return user; // already resolved by the pipe
}
```

## Guards
Guards decide whether a request proceeds. Can be async (DB/token lookups).

```typescript
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private jwt: JwtService) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const req = ctx.switchToHttp().getRequest<Request>();
    const token = extractBearer(req);
    if (!token) return false;
    try {
      req.user = await this.jwt.verifyAsync(token);
      return true;
    } catch {
      return false;
    }
  }
}
```

### Role guard
```typescript
@Injectable()
export class RolesGuard implements CanActivate {
  canActivate(ctx: ExecutionContext): boolean {
    const req = ctx.switchToHttp().getRequest<Request & { user?: { role: string } }>();
    const required = this.reflector.getAllAndOverride<string[]>("roles", [
      ctx.getHandler(),
      ctx.getClass(),
    ]);
    return !!required?.some((r) => req.user?.role === r);
  }

  constructor(private reflector: Reflector) {}
}

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles("admin")
@Get("admin/stats")
async stats() {
  return this.stats.run();
}
```

## Exception filters
Map domain errors to HTTP responses. Run after guards/interceptors; cannot be async-blocking.

```typescript
@Catch(DomainError)
export class DomainExceptionFilter implements ExceptionFilter {
  async catch(err: DomainError, host: ArgumentHost) {
    const res = host.switchToHttp().getResponse<Response>();
    const status = this.mapStatus(err.code);
    res.status(status).json({ code: err.code, message: err.message });
  }

  private mapStatus(code: string): number {
    return (
      {
        USER_NOT_FOUND: HttpStatus.NOT_FOUND,
        USER_ALREADY_EXISTS: HttpStatus.CONFLICT,
        INVALID_USER_INPUT: HttpStatus.BAD_REQUEST,
      }[code] ?? HttpStatus.INTERNAL_SERVER_ERROR
    );
  }
}
```

## Async middleware
```typescript
@Injectable()
export class RequestIdMiddleware implements NestMiddleware {
  async use(req: Request, res: Response, next: NextFunction) {
    const id = req.headers["x-request-id"] ?? crypto.randomUUID();
    req.id = id;
    res.setHeader("x-request-id", id);
    next();
  }
}
```