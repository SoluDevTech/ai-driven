# Microservices Transport

NestJS microservices with TCP, Redis, NATS. Use when you actually split services, not as a default.

## Setup
```typescript
const app = await NestFactory.createMicroservice(AppModule, {
  transport: Transport.TCP,
  options: { host: "0.0.0.0", port: 3001 },
});
await app.listen();
```

## Hybrid app (HTTP + microservice)
```typescript
const app = await NestFactory.create(AppModule);
const micro = app.connectMicroservice<MicroserviceOptions>({
  transport: Transport.REDIS,
  options: { url: "redis://localhost:6379" },
});
await app.startAllMicroservices();
await app.listen(3000);
```

## Message patterns
Two styles: request-response (`@MessagePattern`) and event-based (`@EventPattern`).

### Request-response
```typescript
@MessagePattern("user.get", Transport.REDIS)
async getUser(data: { id: string }) {
  return this.users.findById(data.id);
}
```
Client:
```typescript
inject(ClientProxy) // via @Client({ transport: Transport.REDIS, options: {...} })
const user = await firstValueFrom(this.client.send("user.get", { id: "123" }));
```

### Event-based (fire and forget)
```typescript
@EventPattern("user.created")
async onUserCreated(data: UserCreatedPayload) {
  await this.emails.sendWelcome(data.userId);
}
```
Client:
```typescript
this.client.emit("user.created", { userId: "123" });
```

## Transport choice
| Transport | Use when |
|---|---|
| TCP | Simple, single-process split, local dev |
| Redis | Pub/sub across many instances, cheap and reliable |
| NATS | High throughput, subject-based routing, low latency |
| RabbitMQ | Complex routing, durable queues, AMQP features |
| gRPC | Strongly typed contracts, protobuf, low overhead |
| Kafka | Event streaming, replay, log-style consumers |

## Client injection
```typescript
@Module({
  imports: [ClientsModule.register([
    { name: "USER_SERVICE", transport: Transport.REDIS, options: { url: "redis://localhost:6379" } },
  ])],
})
export class OrdersModule {}

@Controller("orders")
export class OrdersController {
  constructor(@Inject("USER_SERVICE") private users: ClientProxy) {}

  @Get(":id")
  async get(@Param("id") id: string) {
    return firstValueFrom(this.users.send("user.get", { id }));
  }
}
```

## Async patterns
- Always `firstValueFrom` when awaiting a single response (RxJS 7+; `toPromise` removed)
- `client.send` returns a cold Observable — it only fires when subscribed. Don't leave it dangling
- `client.emit` returns void — fire and forget. For durability, use a transport that supports it (RabbitMQ / Kafka)

```typescript
async getUser(id: string) {
  return firstValueFrom(this.users.send("user.get", { id }));
}
```

## Error handling
Thrown errors serialize as `{ status, message }` and arrive at the client as a regular response with `err` metadata. Use an RPC exception filter:

```typescript
@Catch()
export class RpcExceptionFilter implements RpcExceptionFilter {
  catch(err: Error) {
    return new RpcException({ status: "error", message: err.message });
  }
}
```

## Anti-patterns
- ❌ Using microservices purely for "architecture" when you have one deployable — adds overhead with no benefit
- ❌ Subscribing to `send()` manually without converting — leaves dangling subscriptions
- ❌ Sending the whole entity over the wire — send IDs/DTOs
- ❌ Treating `emit()` as reliable without a durable transport — events can be lost
- ❌ Synchronous handlers in `@MessagePattern` that block the worker pool — use queues for heavy work