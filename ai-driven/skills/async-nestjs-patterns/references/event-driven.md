# Event-driven with @nestjs/event-emitter

Domain events, emit-and-react, transactional outbox. Load before wiring events.

## Setup
```typescript
import { EventEmitterModule } from "@nestjs/event-emitter";

@Module({
  imports: [EventEmitterModule.forRoot()],
})
export class AppModule {}
```

## Emit a domain event
Events are simple value objects. Use the port/injection-token pattern if you want to keep domain pure (recommended); otherwise inject `EventEmitter2` in the use case.

### Pure-domain approach (recommended)
Domain defines an outbound port; the application emits via the port; the adapter uses `EventEmitter2`.

```typescript
// domain/ports/outbound/DomainEventBus.ts
export abstract class DomainEventBus {
  abstract emit(event: DomainEvent): Promise<void>;
}

export abstract class DomainEvent {
  constructor(public readonly occurredAt = new Date()) {}
}

// domain/events/UserCreated.ts
export class UserCreated extends DomainEvent {
  constructor(public readonly userId: string, occurredAt?: Date) {
    super(occurredAt);
  }
}
```

```typescript
// infrastructure/events/NestEventBusAdapter.ts
import { EventEmitter2 } from "@nestjs/event-emitter";
import { Inject } from "@nestjs/common";
import { DomainEventBus, DomainEvent } from "@/domain/ports/outbound/DomainEventBus";

export class NestEventBusAdapter implements DomainEventBus {
  constructor(private bus: EventEmitter2) {}

  async emit(event: DomainEvent) {
    await this.bus.emitAsync(event.constructor.name, event);
  }
}
```

```typescript
// application/use-cases/CreateUserUseCase.ts
@Injectable()
export class CreateUserUseCase {
  constructor(
    @Inject(USER_REPOSITORY) private users: UserRepository,
    @Inject(DOMAIN_EVENT_BUS) private events: DomainEventBus,
  ) {}

  async execute(input: CreateUserInput) {
    const user = User.create(input);
    await this.users.save(user);
    await this.events.emit(new UserCreated(user.id));
    return user;
  }
}
```

## Handle an event
```typescript
@Injectable()
export class SendWelcomeEmailOnUserCreated {
  private logger = new Logger(SendWelcomeEmailOnUserCreated.name);

  @OnEvent(UserCreated.name)
  async handle(event: UserCreated) {
    try {
      await this.emails.send(event.userId, "welcome");
    } catch (err) {
      this.logger.error(`welcome email failed for ${event.userId}`, err);
      // rethrow to trigger retry, or send to a dead-letter queue
    }
  }

  constructor(@Inject(EMAIL_SENDER) private emails: EmailSender) {}
}
```

## Multiple handlers for the same event
Each handler runs in parallel by default with `emitAsync`. If one fails, others still run.

```typescript
@OnEvent(UserCreated.name)
async indexInSearch(_e: UserCreated) { /* ... */ }

@OnEvent(UserCreated.name)
async syncToCrm(_e: UserCreated) { /* ... */ }
```

## Transactional outbox (important)
If you need "exactly once" semantics across DB + event, use the transactional outbox pattern: write the event row in the same DB transaction as the aggregate, then a background poller publishes it.

```typescript
async createUser(input: CreateUserInput) {
  return this.dataSource.transaction(async (tx) => {
    const user = User.create(input);
    await tx.getRepository(UserModel).save({ ...user });
    await tx.getRepository(OutboxModel).save({
      eventName: UserCreated.name,
      payload: new UserCreated(user.id),
      occurredAt: new Date(),
    });
    return user;
  });
}

// OutboxPublisher polls and emits
@Injectable()
export class OutboxPublisher implements OnModuleInit {
  async onModuleInit() {
    setInterval(() => this.drain(), 1000);
  }

  private async drain() {
    const pending = await this.db.getRepository(OutboxModel).find({ where: { publishedAt: IsNull() } });
    for (const row of pending) {
      try {
        await this.events.emit(plainToInstance(eventsByName[row.eventName], row.payload));
        row.publishedAt = new Date();
        await this.db.getRepository(OutboxModel).save(row);
      } catch (err) {
        this.logger.error(`failed to publish ${row.id}`, err);
      }
    }
  }
}
```

## Anti-patterns
- ❌ Emitting events before the DB transaction commits (handlers see state that doesn't exist)
- ❌ Doing synchronous heavy work in handlers (use a queue instead)
- ❌ Calling `.emit` (sync) instead of `.emitAsync` (async) when handlers are async
- ❌ Tight coupling: handlers reaching back into the originating use case
- ❌ Swallowing errors silently in handlers (log + retry or dead-letter)