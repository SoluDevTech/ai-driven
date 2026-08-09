# Queues with BullMQ

Background jobs with BullMQ + Redis. Prefer BullMQ over the deprecated Bull.

## Setup
```typescript
import { BullMQModule } from "@nestjs/bullmq";

@Module({
  imports: [
    BullMQModule.forRoot({ connection: { host: "localhost", port: 6379 } }),
    BullMQModule.forQueue("email"),
  ],
})
export class AppModule {}
```

## Producer
Inject the queue via `@InjectQueue`. Don't await the work — enqueue and return immediately.

```typescript
@Injectable()
export class SendWelcomeEmailOnUserCreated {
  constructor(@InjectQueue("email") private queue: Queue<UserCreatedPayload>) {}

  async handle(event: UserCreated) {
    await this.queue.add("welcome", { userId: event.userId });
  }
}
```

## Consumer
```typescript
@Processor("email")
export class EmailConsumer extends WorkerHost {
  private logger = new Logger(EmailConsumer.name);

  async process(job: Job<UserCreatedPayload>) {
    try {
      await this.emails.send(job.data.userId, "welcome");
    } catch (err) {
      this.logger.error(`welcome email failed for ${job.data.userId}`, err);
      throw err; // triggers retry
    }
  }

  constructor(@Inject(EMAIL_SENDER) private emails: EmailSender) {}
}
```

## Retries and backoff
Configure per-job or per-queue. Idempotency is your responsibility — make jobs safe to retry.

```typescript
await this.queue.add("welcome", payload, {
  attempts: 5,
  backoff: { type: "exponential", delay: 1000 },
  removeOnComplete: 100,
  removeOnFail: 1000,
});
```

```typescript
@Processor("email", {
  defaultJobOptions: {
    attempts: 5,
    backoff: { type: "exponential", delay: 1000 },
    removeOnComplete: true,
  },
})
export class EmailConsumer extends WorkerHost {}
```

## Scheduled / cron jobs
```typescript
@Processor("email")
export class EmailDigestConsumer extends WorkerHost {
  @Processor("digest", { repeat: { pattern: "0 9 * * 1" } }) // every Monday 09:00
  async weeklyDigest(job: Job) {
    await this.sendDigests();
  }
}
```

## Delayed jobs
```typescript
await this.queue.add("reminder", payload, { delay: 60_000 }); // 1 min later
```

## Priority and concurrency
```typescript
await this.queue.add("urgent", payload, { priority: 1 });

@Processor("email", { concurrency: 5 })
export class EmailConsumer extends WorkerHost {}
```

## Job events
```typescript
queue.on("completed", (job) => log.info(`completed ${job.id}`));
queue.on("failed", (job, err) => log.error(`failed ${job.id}`, err));
```

## Flows / parent-child
```typescript
await flowProducer.add({
  name: "finalize-order",
  queueName: "orders",
  data: { orderId: "123" },
  children: [
    { name: "charge-card", queueName: "payments", data: { orderId: "123" } },
    { name: "reserve-stock", queueName: "inventory", data: { orderId: "123" } },
  ],
});
```

## Graceful shutdown
Drain queues in `OnModuleDestroy` so in-flight jobs finish.

```typescript
@Injectable()
export class QueueShutdown implements OnModuleDestroy {
  constructor(@InjectQueue("email") private queue: Queue) {}

  async onModuleDestroy() {
    await this.queue.close(); // waits for active jobs to finish (within worker grace)
  }
}
```

## Anti-patterns
- ❌ Awaiting the work inside the request handler — that's not a queue, it's a function call
- ❌ Non-idempotent jobs (retries will double-charge, double-send, etc.)
- ❌ Putting the whole domain entity in the payload — send IDs and rehydrate from the repo
- ❌ Blocking `process()` with synchronous CPU work — offload to a worker pool or child process
- ❌ Swallowing errors in `process()` — rethrow to trigger retry, or move to a dead-letter queue