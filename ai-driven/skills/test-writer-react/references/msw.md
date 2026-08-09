# MSW — Mock Service Worker (API Boundary)

MSW mocks the network boundary at the `fetch` / `XMLHttpRequest` level. This is the React equivalent of "mock the external adapter" — you don't own the API in component tests, so you intercept the HTTP call instead.

## Global setup

```ts
// tests/setup.ts — register MSW server globally
import { setupServer } from 'msw/node'
import { http, HttpResponse } from 'msw'

export const server = setupServer()

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

## Per-test handlers

```ts
import { server } from '@/tests/setup'
import { http, HttpResponse } from 'msw'

it('displays products fetched from the API', async () => {
  server.use(
    http.get('/api/products', () =>
      HttpResponse.json([{ id: '1', name: 'Widget', price: 10 }])
    )
  )

  render(<ProductList />)

  expect(await screen.findByText('Widget')).toBeInTheDocument()
})
```

## Error responses

```ts
server.use(
  http.get('/api/products', () =>
    HttpResponse.json({ message: 'Internal error' }, { status: 500 })
  )
)
```

## MSW vs testcontainers

| Test type | Mock the network? | Use |
|---|---|---|
| Component / hook test | Yes | **MSW** |
| Adapter test (WebSocket / SSE) | No | **Testcontainers** (real Redis / real WS server) |
| E2E (full app) | No | **Testcontainers** (real Postgres + real backend + Playwright) |

The golden rule still holds: **real implementations for internal, mocks for external**. In a React component test, the network boundary is "external" (you don't own the API) → MSW. In an adapter test or E2E, you own the backend → real containers.