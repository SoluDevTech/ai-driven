---
name: async-nestjs-patterns
description: NestJS/TypeScript asynchronous patterns: async/await vs RxJS Observables interop, async interceptors/pipes/guards, event-driven design with @nestjs/event-emitter, background jobs with Bull queues, microservices transport (TCP/Redis/NATS), WebSocket gateways, and lifecycle hooks. Use when implementing async flows, event-driven workflows, queues, microservices, or real-time WebSocket handlers in a NestJS backend.
---

# Async NestJS Patterns

Implement asynchronous flows, event-driven workflows, queues, microservices, and real-time WebSockets in a NestJS/TypeScript backend.

## Use this skill when
- Wiring async/await with RxJS Observables (interceptors, guards)
- Building event-driven flows with `@nestjs/event-emitter`
- Implementing background jobs with Bull/BullMQ queues
- Adding microservices transport (TCP, Redis, NATS)
- Building WebSocket gateways for real-time features
- Implementing async lifecycle hooks (`OnModuleInit`, `OnModuleDestroy`)

## Do not use this skill when
- The task is project structure / hexagonal layers → use `hexagonal-nestjs-patterns`
- The task is performance profiling → use `performance-audit`
- The task is Python async → use `async-python-patterns`
- The task is React async → use `async-react-patterns`

## 🎯 Core workflow
1. **Decide async/await vs RxJS** — load `references/async-vs-rxjs.md` to pick the right primitive.
2. **Interceptors/pipes/guards** — load `references/interceptors-pipes.md` when wiring middleware.
3. **Event-driven** — load `references/event-driven.md` for `@nestjs/event-emitter` and event design.
4. **Background jobs** — load `references/queues.md` for Bull/BullMQ queue patterns.
5. **Microservices** — load `references/microservices-transport.md` for TCP/Redis/NATS.
6. **WebSockets** — load `references/websockets.md` for `@WebSocketGateway` real-time handlers.

## 🎯 Core principles (summary)
- **async/await by default** — use Observables only for multi-event streams, cancellation, or backpressure
- **Interop with `firstValueFrom` / `from`** — convert between Promises and Observables cleanly
- **Event-driven for decoupling** — emit domain events; handlers react in isolation
- **Queues for heavy work** — anything CPU-bound or third-party-latency-bound goes to Bull
- **Microservices for boundaries** — use when you actually split services, not as a default
- **Graceful shutdown** — drain queues and close sockets in `OnModuleDestroy`

## 📦 Default stack
- Runtime: Node.js + NestJS 10+
- Events: `@nestjs/event-emitter`
- Queues: BullMQ + Redis (Bull is deprecated; prefer BullMQ)
- Microservices: `@nestjs/microservices` (TCP, Redis, NATS)
- WebSockets: `@nestjs/websockets` + `ws` or `socket.io`
- Language: TypeScript 5.0+ (strict), async/await native

## References
- `references/async-vs-rxjs.md` — when to use async/await vs Observables, interop patterns
- `references/interceptors-pipes.md` — async interceptors, pipes, guards, middleware
- `references/event-driven.md` — `@nestjs/event-emitter`, domain events, transactional outbox
- `references/queues.md` — Bull/BullMQ producers and consumers, retries, backoff
- `references/microservices-transport.md` — TCP/Redis/NATS, request-response vs event-based
- `references/websockets.md` — `@WebSocketGateway`, lifecycle, rooms, async message handlers