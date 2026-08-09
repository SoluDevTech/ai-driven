# Core Concepts

### 1. Event Loop
The event loop is the heart of asyncio, managing and scheduling asynchronous tasks.

**Key characteristics:**
- Single-threaded cooperative multitasking
- Schedules coroutines for execution
- Handles I/O operations without blocking
- Manages callbacks and futures

### 2. Coroutines
Functions defined with `async def` that can be paused and resumed.

**Syntax:**
```python
async def my_coroutine():
    result = await some_async_operation()
    return result
```

### 3. Tasks
Scheduled coroutines that run concurrently on the event loop.

### 4. Futures
Low-level objects representing eventual results of async operations.

### 5. Async Context Managers
Resources that support `async with` for proper cleanup.

### 6. Async Iterators
Objects that support `async for` for iterating over async data sources.

## Quick Start

```python
import asyncio

async def main():
    print("Hello")
    await asyncio.sleep(1)
    print("World")

# Python 3.7+
asyncio.run(main())
```