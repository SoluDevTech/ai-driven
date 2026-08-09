# Testcontainers — Real Infrastructure for Integration Tests

Use [@testcontainers/nodejs](https://node.testcontainers.org/) for integration tests against **real** databases, message brokers, and cloud-emulated services. This extends the "real implementations" golden rule to infrastructure that can't run in SQLite in-memory.

## When to use testcontainers
- **Integration tests** that must validate real Postgres / MongoDB / Redis / Kafka / RabbitMQ behavior
- **Adapter tests** for infrastructure where SQLite in-memory doesn't match production (JSONB, `ON CONFLICT`, enum types, PostGIS, Mongo aggregations)
- **S3 / SQS / SNS** tests via LocalStack container (instead of mocking the AWS SDK)
- **Event-driven** flows that must validate real Redis pub/sub, NATS, or RabbitMQ

## When NOT to use testcontainers
- **Unit tests** — use SQLite in-memory (see `use-case-test.md`) for repositories, mocks for external HTTP
- **CI without Docker** — fall back to SQLite in-memory; mark testcontainers tests and skip them when Docker is unavailable
- **Fast feedback loop** — testcontainers add ~5-15s startup per container; keep the unit suite separate

## Install
```bash
pnpm add -D @testcontainers/nodejs
# per-module extras are not needed; @testcontainers/nodejs ships modules separately
pnpm add -D @testcontainers/postgresql @testcontainers/redis @testcontainers/rabbitmq
```

## Postgres container (adapter integration test)

```typescript
import { PostgreSqlContainer } from '@testcontainers/postgresql';
import { DataSource } from 'typeorm';

describe('PostgresUserRepository (integration)', () => {
  let ds: DataSource;
  let container: StartedPostgreSqlContainer;

  beforeAll(async () => {
    container = await new PostgreSqlContainer('postgres:16-alpine').start();
    ds = new DataSource({
      type: 'postgres',
      host: container.getHost(),
      port: container.getMappedPort(5432),
      username: container.getUsername(),
      password: container.getPassword(),
      database: container.getDatabase(),
      entities: [UserEntity],
      synchronize: true,
    });
    await ds.initialize();
  });

  afterAll(async () => {
    await ds.destroy();
    await container.stop();
  });

  afterEach(async () => {
    await ds.getRepository(UserEntity).clear();
  });

  it('persists and retrieves a user by id', async () => {
    const repo = new PostgresUserRepository(ds);
    const id = crypto.randomUUID();
    await repo.save({ id, email: 'a@b.c', name: 'Ada' });

    const found = await repo.findById(id);
    expect(found).not.toBeNull();
    expect(found!.email).toBe('a@b.c');
  });

  it('uses Postgres-specific ON CONFLICT for upsert', async () => {
    const repo = new PostgresUserRepository(ds);
    const id = crypto.randomUUID();
    await repo.save({ id, email: 'a@b.c', name: 'Ada' });
    await repo.save({ id, email: 'a@b.c', name: 'Ada Lovelace' }); // upsert

    const found = await repo.findById(id);
    expect(found!.name).toBe('Ada Lovelace');
  });
});
```

## Redis container (event bus adapter)

```typescript
import { RedisContainer } from '@testcontainers/redis';

describe('RedisEventBus (integration)', () => {
  let container: StartedRedisContainer;
  let bus: RedisEventBus;

  beforeAll(async () => {
    container = await new RedisContainer('redis:7-alpine').start();
    bus = new RedisEventBus({ url: `redis://${container.getHost()}:${container.getMappedPort(6379)}` });
    await bus.connect();
  });

  afterAll(async () => {
    await bus.disconnect();
    await container.stop();
  });

  afterEach(async () => {
    await bus.flush();
  });

  it('publishes and receives events', async () => {
    const received: UserCreated[] = [];
    await bus.subscribe<UserCreated>('user.created', (e) => received.push(e));

    await bus.publish('user.created', new UserCreated('123'));
    await waitFor(() => expect(received).toHaveLength(1));
  });
});
```

## RabbitMQ container

```typescript
import { RabbitMQContainer } from '@testcontainers/rabbitmq';

let container: StartedRabbitMQContainer;
beforeAll(async () => {
  container = await new RabbitMQContainer('rabbitmq:3-management-alpine').start();
});
afterAll(async () => { await container.stop(); });

const amqpUrl = () => `amqp://${container.getUsername()}:${container.getPassword()}@${container.getHost()}:${container.getMappedPort(5672)}`;
```

## Kafka container

```typescript
import { KafkaContainer } from '@testcontainers/kafka';

let container: StartedKafkaContainer;
beforeAll(async () => {
  container = await new KafkaContainer('confluentinc/cp-kafka:7.6.0').start();
});
afterAll(async () => { await container.stop(); });

const bootstrap = () => container.getBootstrapServers();
```

## LocalStack (S3 / SQS / SNS) — instead of mocking the AWS SDK

```typescript
import { GenericContainer } from '@testcontainers/nodejs';

let container: StartedGenericContainer;
let s3Endpoint: string;

beforeAll(async () => {
  container = await new GenericContainer('localstack/localstack:3')
    .withExposedPorts(4566)
    .withEnvironment({ SERVICES: 's3,sqs' })
    .start();
  s3Endpoint = `http://${container.getHost()}:${container.getMappedPort(4566)}`;
});

afterAll(async () => { await container.stop(); });

it('uploads a file to S3 via the real adapter', async () => {
  const adapter = new S3StorageAdapter({ endpoint: s3Endpoint, forcePathStyle: true });
  await adapter.upload('bucket', 'key', Buffer.from('data'));
  const exists = await adapter.exists('bucket', 'key');
  expect(exists).toBe(true);
});
```

## Skip when Docker is unavailable

```typescript
// jest.config.js — separate integration tests
module.exports = {
  projects: [
    { displayName: 'unit', testMatch: ['**/*.spec.ts'], testEnvironment: 'node' },
    { displayName: 'integration', testMatch: ['**/*.integration.spec.ts'], testEnvironment: 'node' },
  ],
};
```

```typescript
// tests/setup.ts
const dockerAvailable = await isDockerAvailable();
if (!dockerAvailable) {
  console.warn('Docker not available; skipping integration tests');
}

// tests/integration/setup.ts
beforeAll(async () => {
  if (!dockerAvailable) {
    // jest will still run the file; skip each test
  }
});
```

Or skip via an env var:
```typescript
const RUN_INTEGRATION = process.env.RUN_INTEGRATION === '1';
(RUN_INTEGRATION ? describe : describe.skip)('PostgresUserRepository (integration)', () => { ... });
```

Run:
```bash
npm run test                    # unit only (no docker)
RUN_INTEGRATION=1 npm run test  # including integration
```

## Best practices
- **Scope containers to `describe`** or a `beforeAll` at the file level — reuse across tests to amortize startup
- **Reset state between tests** — truncate tables / flush keys, don't recreate the container
- **Pin image tags** — `postgres:16-alpine`, not `latest`, for reproducibility
- **Alpine variants** — smaller, faster startup
- **Don't mix with mocks** — if you're using a real Postgres container, use the real `PostgresUserRepository` (not a `jest.fn()` mock). This is the whole point.
- **Parallelism** — each test worker needs its own container or a unique schema/database to avoid collisions
- **Close the DataSource and `container.stop()`** in `afterAll` to avoid open handles