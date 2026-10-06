# Testing a Custom Hook

`renderHook`, `act`, `waitFor`. Real internal state; mocked external calls.

> **Decision order — prefer the component as the entry point.** If any component consumes this hook and the behavior is observable in the UI, test THROUGH that component (`component-test.md`) instead of rendering the hook directly. Use `renderHook` ONLY when the hook is not yet consumed by a component, or is generic shared infrastructure. Never mock internal modules to make the hook testable — mock the network (MSW) it calls.

```ts
import { renderHook, act, waitFor } from '@testing-library/react'
import { useCheckout } from './useCheckout'
import { chargeCard } from '@/infrastructure/api/payment-client'
import { mockChargeSuccess, mockChargeDeclined } from '@/tests/fixtures/external'

vi.mock('@/infrastructure/api/payment-client')

describe('useCheckout', () => {
  it('transitions to "success" state after a successful payment', async () => {
    mockChargeSuccess()

    const { result } = renderHook(() => useCheckout())

    act(() => {
      result.current.submitPayment({ cardToken: 'tok_visa', amount: 4500 })
    })

    await waitFor(() => {
      expect(result.current.status).toBe('success')
    })
    expect(chargeCard).toHaveBeenCalledOnce()
  })

  it('transitions to "error" state when card is declined', async () => {
    mockChargeDeclined()

    const { result } = renderHook(() => useCheckout())

    act(() => {
      result.current.submitPayment({ cardToken: 'tok_declined', amount: 4500 })
    })

    await waitFor(() => {
      expect(result.current.status).toBe('error')
      expect(result.current.errorMessage).toMatch(/declined/i)
    })
  })
})
```

## External fixtures

```ts
// tests/fixtures/external.ts
import { vi } from 'vitest'
import { chargeCard } from '@/infrastructure/api/payment-client'
import { sendAnalyticsEvent } from '@/infrastructure/analytics/segment-client'

export function mockChargeSuccess() {
  vi.mocked(chargeCard).mockResolvedValue({ status: 'succeeded', id: 'ch_test_123' })
}

export function mockChargeDeclined() {
  vi.mocked(chargeCard).mockRejectedValue(new Error('Your card was declined'))
}

export function mockAnalyticsNoop() {
  vi.mocked(sendAnalyticsEvent).mockResolvedValue(undefined)
}
```