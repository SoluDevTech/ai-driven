# Testcontainers — Real Infrastructure for Integration Tests

For React apps, testcontainers is mainly relevant when testing **adapter layers** that talk to real backend services (e.g. a WebSocket gateway, a Server-Sent Events endpoint, an SSE/WS client, or an offline-capable IndexedDB that syncs to a real API). Use [@testcontainers/nodejs](https://node.testcontainers.org/) in Node-side test files (Vitest can run tests in the Node environment too).

## When to use testcontainers (in a React codebase)
- **Integration tests** for infrastructure adapters (WebSocket client, SSE client, a real backend echo server)
- **E2E tests** that boot a real backend (NestJS / Express) against a real Postgres / Redis, then run the React app against it via Playwright / Cypress
- **LocalStack** for S3 / SQS adapters that live in the frontend's `infrastructure/` layer (rare but possible — e.g. direct-to-S3 uploads)

## When NOT to use testcontainers
- **Component tests** — use MSW (Mock Service Worker) to mock the network boundary; this is the React equivalent of "mock the external adapter"
- **Hook tests** — real Zustand/React Query + MSW for the fetch
- **Fast feedback loop** — testcontainers add ~5-15s startup per container; keep the unit suite separate

## Install
```bash
pnpm add -D @testcontainers/nodejs @testcontainers/redis
# run integration tests in the node environment, not jsdom
```

## Vitest config — separate environments

```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    projects: [
      {
        // component tests in jsdom
        extends: './tsconfig.json',
        test: {
          environment: 'jsdom',
          name: 'unit',
          include: ['src/**/*.test.{ts,tsx}'],
          setupFiles: './tests/setup.ts',
        },
      },
      {
        // integration tests in node (needs Docker)
        extends: './tsconfig.json',
        test: {
          environment: 'node',
          name: 'integration',
          include: ['tests/integration/**/*.test.ts'],
        },
      },
    ],
  },
})
```

Run only unit (no Docker):
```bash
pnpm vitest --project unit
```

## Redis container (real WebSocket gateway integration)

```typescript
// tests/integration/ws-gateway.test.ts
import { RedisContainer } from '@testcontainers/redis'
import { io } from 'socket.io-client'
import { RedisGateway } from '@/infrastructure/realtime/redis-gateway'

describe('RedisGateway (integration)', () => {
  let container: Awaited<ReturnType<RedisContainer['start']>>
  let gateway: RedisGateway

  beforeAll(async () => {
    container = await new RedisContainer('redis:7-alpine').start()
    gateway = new RedisGateway({
      url: `redis://${container.getHost()}:${container.getMappedPort(6379)}`,
    })
    await gateway.start()
  })

  afterAll(async () => {
    await gateway.stop()
    await container.stop()
  })

  it('broadcasts events to subscribed clients', async () => {
    const client = io(`http://localhost:${gateway.httpPort}`, { transports: ['websocket'] })
    const received: string[] = []

    client.on('userUpdated', (payload: { id: string }) => received.push(payload.id))

    await new Promise<void>((resolve) => client.on('connect', resolve))
    await gateway.emitUserUpdated('42')

    await waitFor(() => expect(received).toContain('42'))
    client.disconnect()
  })
})
```

## E2E with a real backend + real Postgres (Playwright)

```typescript
// tests/e2e/full-flow.test.ts
import { PostgreSqlContainer } from '@testcontainers/postgresql'
import { NestFactory } from '@nestjs/core'
import { AppModule } from '@/backend/app.module'

let backend: INestApplication
let container: Awaited<ReturnType<PostgreSqlContainer['start']>>

beforeAll(async () => {
  container = await new PostgreSqlContainer('postgres:16-alpine').start()
  process.env.DATABASE_URL = container.getConnectionUrl()
  backend = await NestFactory.create(AppModule)
  await backend.listen(3001)
})

afterAll(async () => {
  await backend.close()
  await container.stop()
})

test('user can sign up and see their dashboard', async () => {
  await page.goto('http://localhost:5173/signup')
  await page.fill('[data-testid=email]', 'a@b.c')
  await page.fill('[data-testid=name]', 'Ada')
  await page.click('button[type=submit]')
  await expect(page.locator('h1')).toHaveText('Welcome, Ada')
})
```

## LocalStack (S3 direct uploads)

```typescript
import { GenericContainer } from '@testcontainers/nodejs'

let container: Awaited<ReturnType<GenericContainer['start']>>
let s3Endpoint: string

beforeAll(async () => {
  container = await new GenericContainer('localstack/localstack:3')
    .withExposedPorts(4566)
    .withEnvironment({ SERVICES: 's3' })
    .start()
  s3Endpoint = `http://${container.getHost()}:${container.getMappedPort(4566)}`
})

afterAll(async () => { await container.stop() })

it('uploads a file directly to S3', async () => {
  const adapter = new S3UploadAdapter({ endpoint: s3Endpoint, forcePathStyle: true })
  const url = await adapter.presignUpload('bucket', 'key')
  await fetch(url, { method: 'PUT', body: Buffer.from('data') })
  expect(await adapter.exists('bucket', 'key')).toBe(true)
})
```

## MSW vs testcontainers — when to use which

| Test type | Mock the network? | Use |
|---|---|---|
| Component / hook test | Yes | **MSW** (`http.get('/api/...')`) |
| Adapter test (WebSocket / SSE) | No | **Testcontainers** (real Redis / real WS server) |
| E2E (full app) | No | **Testcontainers** (real Postgres + real backend + Playwright) |

The golden rule still holds: **real implementations for internal, mocks for external**. In a React test, the network boundary is "external" (you don't own the API in component tests) → MSW. In an adapter test or E2E, you own the backend → real containers.

## Best practices
- **Scope containers to `describe`** or `beforeAll` at the file level
- **Reset state between tests** — flush Redis keys, truncate Postgres tables
- **Pin image tags** — `redis:7-alpine`, `postgres:16-alpine` for reproducibility
- **Don't mix with MSW** — MSW mocks the network; testcontainers replaces it with real infra. Pick one per test.
- **Close the connection and `container.stop()`** in `afterAll` to avoid open handles
- **Run in the `node` environment**, not `jsdom` — testcontainers needs Node APIs (net, streams) that jsdom doesn't provide