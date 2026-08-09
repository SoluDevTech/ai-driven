# WebSockets

Real-time WebSocket gateways with `@nestjs/websockets`. Use `ws` or `socket.io` as the platform.

## Setup
```bash
pnpm add @nestjs/websockets @nestjs/platform-socket.io socket.io
# or
pnpm add @nestjs/websockets @nestjs/platform-ws ws
```

## Gateway
```typescript
import { OnGatewayConnection, OnGatewayDisconnect, OnGatewayInit, SubscribeMessage, WebSocketGateway, WebSocketServer } from "@nestjs/websockets";
import { Server, Socket } from "socket.io";

@WebSocketGateway({ namespace: "chat", cors: true })
export class ChatGateway implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer() server: Server;

  afterInit() { /* warm up */ }

  handleConnection(client: Socket) {
    this.logger.log(`connected ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`disconnected ${client.id}`);
  }

  @SubscribeMessage("message")
  async onMessage(client: Socket, payload: ChatMessage) {
    try {
      const saved = await this.messages.save(payload);
      this.server.to(payload.room).emit("message", saved); // broadcast to room
    } catch (err) {
      client.emit("error", { message: "send failed" });
    }
  }

  private logger = new Logger(ChatGateway.name);
  constructor(private messages: MessageService) {}
}
```

## Rooms
```typescript
@SubscribeMessage("join")
async onJoin(client: Socket, payload: { room: string }) {
  await client.join(payload.room);
  client.to(payload.room).emit("userJoined", { id: client.id });
}

@SubscribeMessage("leave")
async onLeave(client: Socket, payload: { room: string }) {
  await client.leave(payload.room);
}
```

## Async handlers
Handlers can be async. Emit back to the client or broadcast; don't block the event loop.

```typescript
@SubscribeMessage("typing")
async onTyping(client: Socket, payload: { room: string }) {
  client.to(payload.room).emit("typing", { id: client.id });
}
```

## Emit from a service (outside the gateway)
Inject the server via a registry. Useful when a use case or event handler needs to push to clients.

```typescript
@Injectable()
export class RealtimeService implements OnGatewayInit {
  private server?: Server;

  setServer(server: Server) { this.server = server; }

  emitUserUpdated(userId: string) {
    this.server?.to(`user:${userId}`).emit("userUpdated", { id: userId });
  }
}

// In the gateway
afterInit(server: Server) {
  this.realtime.setServer(server);
}
```

## Backpressure
For high-throughput gateways, batch emissions and use `volatile` to drop if the client can't keep up.

```typescript
this.server.volatile.emit("tick", { t: Date.now() }); // may be dropped
```

## Auth with guards
```typescript
@Injectable()
export class WsJwtGuard implements CanActivate {
  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const client = ctx.switchToWs().getClient<Socket>();
    const token = client.handshake.auth?.token;
    try {
      client.data.user = await this.jwt.verifyAsync(token);
      return true;
    } catch {
      return false;
    }
  }

  constructor(private jwt: JwtService) {}
}

@UseGuards(WsJwtGuard)
@WebSocketGateway()
export class AuthGateway {}
```

## Lifecycle hooks
- `OnGatewayInit` — after the gateway is instantiated
- `OnGatewayConnection` — on each new connection
- `OnGatewayDisconnect` — on each disconnection
- `OnGatewayInit` runs once; use it to register the server in services

## Graceful shutdown
Drain sockets on shutdown so clients see a clean disconnect instead of an ECONNRESET.

```typescript
@Injectable()
export class GatewayShutdown implements OnModuleDestroy {
  constructor(@Inject("WS_SERVER") private server: Server) {}

  async onModuleDestroy() {
    this.server.disconnectSockets(true); // close all sockets
    await new Promise<void>((r) => this.server.close(() => r()));
  }
}
```

## Anti-patterns
- ❌ Mutating client.data without typing it (declare a typed `Socket` extension)
- ❌ Synchronous heavy work in a handler — block the worker pool and other clients see lag
- ❌ Emitting unbounded events to a slow client — use `volatile` or batch
- ❌ Reaching into the gateway from a service via a global singleton — inject a registry
- ❌ Mixing room names with user IDs — pick a convention (`user:<id>`, `room:<id>`) and stick to it