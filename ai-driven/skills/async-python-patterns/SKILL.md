---
name: async-python-patterns
description: "Comprehensive guidance for implementing asynchronous Python applications using asyncio, concurrent programming patterns, and async/await for building high-performance, non-blocking systems. Trigger on: asyncio, async/await, FastAPI background tasks, \"async flow\", \"concurrency\", \"non-blocking\", event loop, \"race condition\", gather/TaskGroup, or any async/concurrency task in a Python backend. Use whenever the task touches async or concurrency in Python."
---

# Async Python Patterns

Comprehensive guidance for implementing asynchronous Python applications using asyncio, concurrent programming patterns, and async/await for building high-performance, non-blocking systems.

## Use this skill when

- Building async web APIs (FastAPI, aiohttp, Sanic)
- Implementing concurrent I/O operations (database, file, network)
- Creating web scrapers with concurrent requests
- Developing real-time applications (WebSocket servers, chat systems)
- Processing multiple independent tasks simultaneously
- Building microservices with async communication
- Optimizing I/O-bound workloads
- Implementing async background tasks and queues

## Do not use this skill when

- The workload is CPU-bound with minimal I/O.
- A simple synchronous script is sufficient.
- The runtime environment cannot support asyncio/event loop usage.

## Core concepts (summary)

- **Event loop**: Single-threaded cooperative scheduler that runs coroutines and handles I/O without blocking.
- **Coroutines**: `async def` functions that can be paused at `await` points and resumed by the event loop.
- **Tasks**: Scheduled coroutines running concurrently on the loop (created via `asyncio.create_task`).
- **Futures**: Low-level objects representing eventual results of async operations.
- **Async context managers**: Objects supporting `async with` for safe resource setup/teardown.
- **Async iterators**: Objects supporting `async for` to consume data from async sources (e.g., generators with `yield`).

## Workflow

1. **Clarify workload.** Determine I/O-bound vs CPU-bound, concurrency targets, and runtime constraints (Python version, event loop policy).
2. **Pick concurrency patterns.** Load `references/fundamental-patterns.md` for basic async/await, `gather()`, task management, error handling, and timeouts. Load `references/advanced-patterns.md` for async context managers, iterators/generators, producer-consumer, semaphore rate limiting, and async locks.
3. **Real-world implementation.** Load `references/real-world.md` for web scraping with aiohttp, async database operations, and WebSocket server patterns.
4. **Performance.** Load `references/performance-and-pitfalls.md` for connection pools, batch operations, blocking-operation avoidance (executors), and the common pitfalls checklist (forgotten `await`, blocking the loop, missing cancellation handling, sync/async mixing).
5. **Testing.** Load `references/testing.md` for pytest-asyncio patterns, timeout tests, the resources list, and the best practices summary.

## References

- `references/core-concepts.md` — Event loop, coroutines, tasks, futures, async context managers, async iterators, and a quick-start snippet.
- `references/fundamental-patterns.md` — Patterns 1-5: basic async/await, `gather()`, task creation/management, error handling, timeout handling.
- `references/advanced-patterns.md` — Patterns 6-10: async context managers, async iterators/generators, producer-consumer, semaphore rate limiting, async locks.
- `references/real-world.md` — Web scraping with aiohttp, async database operations, WebSocket server.
- `references/performance-and-pitfalls.md` — Connection pools, batch operations, blocking avoidance, and the common pitfalls checklist.
- `references/testing.md` — pytest-asyncio patterns, resources list, and the 10-point best practices summary.