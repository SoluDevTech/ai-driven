# Setup — Jest Config and External Fixtures

## Test Structure
```
src/
├── application/
│   └── use-cases/
│       └── create-user/
│           ├── create-user.use-case.ts
│           └── create-user.use-case.spec.ts    # Co-located use case tests
├── infrastructure/
│   ├── persistence/
│   │   └── typeorm-user.repository.spec.ts     # Adapter tests (optional)
│   └── http/
│       └── user.controller.spec.ts             # Controller tests (e2e-style)
test/
├── app.e2e-spec.ts                             # Full e2e tests
├── jest-e2e.json
└── fixtures/
    └── external.ts                             # Shared jest.fn() factories
```

## jest configuration (package.json)

```json
{
  "jest": {
    "moduleFileExtensions": ["js", "json", "ts"],
    "rootDir": "src",
    "testRegex": ".*\\.spec\\.ts$",
    "transform": { "^.+\\.(t|j)s$": "ts-jest" },
    "moduleNameMapper": { "^@/(.*)$": "<rootDir>/$1" },
    "collectCoverageFrom": ["**/*.(t|j)s"],
    "coverageDirectory": "../coverage",
    "testEnvironment": "node"
  }
}
```

## test/fixtures/external.ts — mock provider factories

```typescript
import { SendgridEmailAdapter } from '@/infrastructure/email/sendgrid-email.adapter'
import { StripeAdapter } from '@/infrastructure/payment/stripe.adapter'

export function mockEmailSuccess() {
  return {
    provide: SendgridEmailAdapter,
    useValue: { send: jest.fn().mockResolvedValue(true) },
  }
}

export function mockEmailTimeout() {
  return {
    provide: SendgridEmailAdapter,
    useValue: {
      send: jest.fn().mockRejectedValue(new Error('Sendgrid timeout')),
    },
  }
}

export function mockStripeSuccess() {
  return {
    provide: StripeAdapter,
    useValue: {
      charge: jest.fn().mockResolvedValue({ status: 'succeeded', id: 'ch_test_123' }),
    },
  }
}

export function mockStripeDeclined() {
  return {
    provide: StripeAdapter,
    useValue: {
      charge: jest.fn().mockRejectedValue(new Error('Your card was declined')),
    },
  }
}
```

## Why real implementations
Using real implementations ensures tests reflect actual behavior. A stub that diverges silently from the real implementation produces tests that pass but do not detect real regressions. Since external dependencies are mocked, there is no infrastructure cost to using real internal implementations.