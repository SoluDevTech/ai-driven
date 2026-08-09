# async/await vs RxJS Observables

When to use which, and how to interop cleanly.

## Decision table

| Situation | Use |
|---|---|
| Single async operation (DB call, HTTP request) | `async/await` |
| Multiple values over time (WebSocket messages, polling) | Observable |
| You need cancellation / unsubscription | Observable |
| You need composition (map, filter, merge, switchMap) | Observable |
| NestJS interceptor returning a stream (SSE, streaming response) | Observable |
| Backpressure (producer faster than consumer) | Observable |
| Mixing with the rest of NestJS (which uses RxJS internally) | Whatever keeps the chain consistent |

Default: **async/await**. Reach for Observables only when you genuinely need multi-event streams, cancellation, or composition.

## Interop: Observable → Promise
```typescript
import { firstValueFrom } from "rxjs";

const user = await firstValueFrom(userService.findById(id));
```

Use `firstValueFrom` (not `toPromise()` — removed in RxJS 7+). It returns the first emission and unsubscribes.

## Interop: Promise → Observable
```typescript
import { from, switchMap } from "rxjs";

const user$ = from(userService.findById(id)).pipe(
  switchMap((user) => postsService.listByUser(user.id)),
);
```

## async/await in use cases
Use cases are single-operation-shaped; `async/await` is cleaner.

```typescript
@Injectable()
export class CreateUserUseCase {
  async execute(input: CreateUserInput): Promise<User> {
    const user = User.create(input);
    await this.users.save(user);
    await this.events.emit("user.created", new UserCreatedEvent(user));
    return user;
  }
}
```

## Observable in interceptors
Interceptors often need to transform the response stream; use RxJS operators.

```typescript
import { CallHandler, ExecutionContext, NestInterceptor } from "@nestjs/common";
import { map, Observable } from "rxjs";

export class NormalizeResponseInterceptor implements NestInterceptor {
  intercept(ctx: ExecutionContext, next: CallHandler): Observable<unknown> {
    return next.handle().pipe(
      map((data) => ({ data, meta: { timestamp: Date.now() } })),
    );
  }
}
```

## Mixing: interceptor calling an async service
```typescript
@Injectable()
export class EnrichUserInterceptor implements NestInterceptor {
  constructor(private enrich: EnrichUserService) {}

  async intercept(ctx: ExecutionContext, next: CallHandler) {
    const req = ctx.switchToHttp().getRequest<Request>();
    req.user = await this.enrich.fromToken(req.headers.authorization ?? "");

    // return the handler observable unchanged
    return next.handle();
  }
}
```

## Streams that emit multiple values
```typescript
import { interval, Observable } from "rxjs";

@Injectable()
export class HeartbeatService {
  stream(): Observable<string> {
    return interval(1000).pipe(map((i) => `beat ${i}`));
  }
}
```

## Cancellation with AbortController
For HTTP work, pass the signal through so cancelled requests abort the fetch.

```typescript
async findById(id: string, signal?: AbortSignal): Promise<User | null> {
  const res = await fetch(`${this.baseUrl}/users/${id}`, { signal });
  if (!res.ok) return null;
  return User.create(await res.json());
}
```

## Anti-patterns
- ❌ Calling `.subscribe()` and then `await` inside — leaves a dangling subscription
- ❌ Converting a single-value Promise to Observable just to use `map` — use `await` + plain function
- ❌ Mixing `toPromise()` (removed in RxJS 7+) — use `firstValueFrom`
- ❌ Returning a Promise from an interceptor that's expected to return an Observable stream — breaks SSE/streaming
- ❌ Subscribing inside a controller — return the Observable and let NestJS subscribe