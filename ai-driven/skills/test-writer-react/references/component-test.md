# Testing a Component

Real Zustand store (seeded in `beforeEach`); MSW for the API boundary. Query by role. AAA pattern.

```tsx
import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { render } from '@/tests/utils/render'
import { CartSummary } from './CartSummary'
import { useCartStore } from '@/store/cart'

describe('CartSummary', () => {
  beforeEach(() => {
    // Reset real store state between tests
    useCartStore.setState({ items: [] })
  })

  it('displays empty state when cart has no items', () => {
    render(<CartSummary />)
    expect(screen.getByText(/your cart is empty/i)).toBeInTheDocument()
  })

  it('displays item count and total when cart has items', () => {
    // Arrange — seed real store
    useCartStore.setState({
      items: [
        { id: '1', name: 'Widget', price: 10, quantity: 2 },
        { id: '2', name: 'Gadget', price: 25, quantity: 1 },
      ],
    })

    render(<CartSummary />)

    expect(screen.getByText('3 items')).toBeInTheDocument()
    expect(screen.getByText('€45.00')).toBeInTheDocument()
  })

  it('removes an item when the remove button is clicked', async () => {
    useCartStore.setState({
      items: [{ id: '1', name: 'Widget', price: 10, quantity: 1 }],
    })
    const user = userEvent.setup()

    render(<CartSummary />)
    await user.click(screen.getByRole('button', { name: /remove widget/i }))

    await waitFor(() => {
      expect(screen.getByText(/your cart is empty/i)).toBeInTheDocument()
    })
    expect(useCartStore.getState().items).toHaveLength(0)
  })
})
```

## Reasoning example
> "`CheckoutForm` depends on `useCartStore` (internal → real Zustand store, seeded in `beforeEach`) and `chargeCard` from `payment-client` (external → `vi.mock` + fixtures). I test the form's visible behavior (button states, success message, error message) without asserting on internal state transitions."