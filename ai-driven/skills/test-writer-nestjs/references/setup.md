# Setup — Jest Config, Shared Setup and External Fixtures

## Test Structure
```
src/
└── domain/
    └── (pure logic — no co-located tests; non-HTTP logic goes to test/unit/)
test/
├── setup.ts                             # real AppModule bootstrap + testcontainers + auth helpers
├── fixtures/
│   └── external.ts                      # mock factories for external adapters (configurable failures)
├── behavioral/                          # Behavioral tests from the router (main focus)
│   └── <feature>/
│       ├── create-user.spec.ts          # Supertest on the real AppModule
│       └── get-user.spec.ts
└── unit/                                # ONLY: pure domain without HTTP entry, scripts, consumers
    ├── create-user.use-case.spec.ts     # queue/cron/pure-domain exceptions
    └── typeorm-user.repository.spec.ts  # adapter-specific SQL exceptions
```

- One file per endpoint under `behavioral/<feature>/`, named after the endpoint (`<endpoint>.spec.ts`).
- No isolated controller tests — behavioral tests cover the chain.
- All exceptions formerly co-located in `src/` move to `test/unit/`.

## jest configuration (package.json)

Single config — one `npm test` runs everything under `test/`:

```json
{
  "jest": {
    "moduleFileExtensions": ["js", "json", "ts"],
    "rootDir": "test",
    "testRegex": ".*\\.spec\\.ts$",
    "transform": { "^.+\\.(t|j)s$": "ts-jest" },
    "moduleNameMapper": { "^@/(.*)$": "<rootDir>/../src/$1" },
    "collectCoverageFrom": ["../src/**/*.(t|j)s"],
    "coverageDirectory": "../coverage",
    "testEnvironment": "node"
  }
}
```

## test/setup.ts — shared bootstrap + auth helpers

The real AppModule bootstrap (testcontainers DataSource + Supertest app) and auth helpers live in ONE place, imported by every behavioral spec:

```typescript
// test/setup.ts
import { Test } from '@nestjs/testing'
import { INestApplication, ValidationPipe } from '@nestjs/common'
import * as request from 'supertest'
import { DataSource } from 'typeorm'
import { AppModule } from '@/app.module'

export async function createTestApp() { /* real AppModule + testcontainers PG — see router-test.md */ }

export async function authHeaders(app: INestApplication): Promise<Record<string, string>> {
  // Register + login through the REAL API — no token forgery
  await request(app.getHttpServer()).post('/auth/register')
    .send({ email: 'test@example.com', password: 'S3curePassw0rd!', name: 'John Doe' })
  const response = await request(app.getHttpServer()).post('/auth/login')
    .send({ email: 'test@example.com', password: 'S3curePassw0rd!' })
  return { Authorization: `Bearer ${response.body.access_token}` }
}
```

Usage in a behavioral test: `await request(app.getHttpServer()).get('/users/me').set(await authHeaders(app))`. Tests for the login route itself live in `behavioral/auth/login.spec.ts` and must NOT use these helpers — they test the flow directly.

## test/fixtures/external.ts — mock provider factories (configurable failures)

For EACH external adapter expose one factory parameterized by outcome mode (`success` default, `error`, `timeout`, `empty`) — see `router-test.md` for how a mode is picked mid-suite:

```typescript
import { SendgridEmailAdapter } from '@/infrastructure/email/sendgrid-email.adapter'
import { StripeAdapter } from '@/infrastructure/payment/stripe.adapter'

export type Outcome = 'success' | 'error' | 'timeout' | 'empty'

export function mockEmail(outcome: Outcome = 'success') {
  const send = jest.fn()
  if (outcome === 'success') send.mockResolvedValue(true)
  if (outcome === 'error') send.mockRejectedValue(new Error('Sendgrid rejected the message'))
  if (outcome === 'timeout') send.mockRejectedValue(new Error('Sendgrid timeout'))
  if (outcome === 'empty') send.mockResolvedValue(null)
  return { provide: SendgridEmailAdapter, useValue: { send } }
}

export function mockStripe(outcome: Outcome = 'success') {
  const charge = jest.fn()
  if (outcome === 'success') charge.mockResolvedValue({ status: 'succeeded', id: 'ch_test_123' })
  if (outcome === 'error') charge.mockRejectedValue(new Error('Your card was declined'))
  if (outcome === 'timeout') charge.mockRejectedValue(new Error('Stripe timeout'))
  if (outcome === 'empty') charge.mockResolvedValue(null)
  return { provide: StripeAdapter, useValue: { charge } }
}

// Legacy per-outcome helpers remain available:
export const mockEmailSuccess = () => mockEmail('success')
export const mockStripeDeclined = () => mockStripe('error')
```

## Why real implementations
Using real implementations ensures tests reflect actual behavior. A stub that diverges silently from the real implementation produces tests that pass but do not detect real regressions. Since external dependencies are mocked, there is no infrastructure cost to using real internal implementations.