# Python Performance Patterns Reference

Scan for every category below. Each has detection signals and examples.

---

## 1. N+1 Queries (ORM)

**Pattern**: A query inside a loop — one query per record instead of one batched query.

**Signals**:
- `.filter()`, `.get()`, `.objects.all()`, `.query()`, `.execute()` inside a `for` loop or list comprehension
- Accessing a related field (FK, M2M) without `select_related` / `prefetch_related`
- SQLAlchemy `session.query()` inside loops

**Django example**:
```python
# ❌ N+1
for order in Order.objects.all():
    print(order.user.name)  # 1 query per order

# ✅ Fixed
for order in Order.objects.select_related('user').all():
    print(order.user.name)  # 1 query total
```

**SQLAlchemy example**:
```python
# ❌ N+1
orders = session.query(Order).all()
for order in orders:
    print(order.user.name)  # lazy load per row

# ✅ Fixed
orders = session.query(Order).options(joinedload(Order.user)).all()
```

**Prisma/Tortoise**: same principle — check for missing `prefetch_related` or `include`.

---

## 2. Missing DB Indexes

**Signals**:
- `.filter(field=...)` on a non-PK, non-indexed field
- ORDER BY on unindexed columns
- `LIKE '%term'` queries (can't use standard index)
- `annotate` + `order_by` without index
- Large tables without composite indexes on common filter combos

**Fix signal**: suggest `db_index=True` in Django, `Index(fields=[...])` in `Meta`, or raw `CREATE INDEX`.

---

## 3. Unoptimized Aggregations / Full Table Scans

**Signals**:
- `len(queryset)` instead of `.count()`
- `list(queryset)` before slicing
- Loading all records to compute a max/min/sum in Python instead of using `.aggregate()`

```python
# ❌
total = sum([o.amount for o in Order.objects.all()])

# ✅
from django.db.models import Sum
total = Order.objects.aggregate(total=Sum('amount'))['total']
```

---

## 4. Blocking I/O in Async Context

**Signals**:
- `requests.get()`, `time.sleep()`, `open()`, `subprocess.run()` inside `async def`
- `psycopg2` (sync) used inside `asyncio` / FastAPI routes
- Missing `await` on coroutines (they silently don't execute)
- `asyncio.run()` called inside an already-running event loop

```python
# ❌ Blocks the entire event loop
async def get_data():
    return requests.get(url).json()

# ✅
async def get_data():
    async with httpx.AsyncClient() as client:
        return (await client.get(url)).json()
```

---

## 5. Inefficient Loops & Comprehensions

**Signals**:
- Repeated attribute lookup inside loop (`obj.attr.sub` each iteration)
- `.append()` in a loop where a comprehension would work
- Nested loops that can be replaced with sets/dicts for O(1) lookup
- `for x in list` when `x in set` suffices for membership tests

```python
# ❌ O(n²) membership test
result = [x for x in a if x in b_list]

# ✅ O(n) with set
b_set = set(b_list)
result = [x for x in a if x in b_set]
```

---

## 6. String Concatenation in Loops

**Signals**: `result += string` inside a loop

```python
# ❌ O(n²) due to immutability
s = ""
for part in parts:
    s += part

# ✅
s = "".join(parts)
```

---

## 7. Unneeded Object Instantiation / Copy

**Signals**:
- `list(some_list)` just to iterate
- `dict(some_dict)` for read-only access
- Deep copies where shallow suffices
- Creating large intermediate lists when a generator would work

---

## 8. Missing Caching on Expensive Pure Functions

**Signals**:
- Recursive functions without memoization
- Repeated identical DB/API calls with same arguments
- No `@lru_cache` / `@cache` on deterministic functions

```python
# ❌ Recomputes every call
def fib(n):
    if n < 2: return n
    return fib(n-1) + fib(n-2)

# ✅
from functools import lru_cache

@lru_cache(maxsize=None)
def fib(n):
    if n < 2: return n
    return fib(n-1) + fib(n-2)
```

---

## 9. Celery / Background Tasks Anti-Patterns

**Signals**:
- Large objects serialized into task args (pass IDs, not objects)
- `task.delay()` called in a tight loop (use `group()` or `chord()`)
- No `acks_late=True` for idempotent tasks in unreliable environments
- Missing result backend expiry causing memory bloat

---

## 10. Pandas / NumPy Anti-Patterns

**Signals**:
- `iterrows()` — always slow; use vectorized ops or `apply`
- `df[col].apply(lambda x: ...)` where a vectorized op exists
- Growing a DataFrame with `pd.concat` in a loop
- Not using `dtype` specification on read, causing memory bloat
- `df[df['col'] == val]` repeatedly without indexing

```python
# ❌
for _, row in df.iterrows():
    df.loc[_, 'result'] = row['a'] * 2

# ✅
df['result'] = df['a'] * 2
```

---

## 11. Memory Leaks

**Signals**:
- Global list/dict that grows unboundedly
- Circular references without `__del__` or `weakref`
- Unclosed file handles, DB connections, or HTTP sessions
- Django signals holding references to deleted objects

---

## 12. Suboptimal Data Structures

**Signals**:
- `list` used for O(n) lookups when `set`/`dict` would be O(1)
- `deque` missing for queue operations (`.pop(0)` on list is O(n))
- `heapq` missing for priority queue patterns

---

## 13. Inefficient Serialization

**Signals**:
- `json.dumps` on large objects in hot path without caching
- `pickle` on large data structures
- Pydantic model re-validation in loops (validate once, reuse)

---

## 14. Missing `__slots__`

**Signals**: High-volume object instantiation class without `__slots__`

```python
# For classes instantiated millions of times
class Point:
    __slots__ = ['x', 'y']
    def __init__(self, x, y):
        self.x, self.y = x, y
```

---

## 15. Regex Compilation in Hot Path

**Signals**: `re.match(pattern, ...)` called repeatedly — pattern recompiled each time.

```python
# ❌
for line in lines:
    if re.match(r'\d+', line): ...

# ✅
PATTERN = re.compile(r'\d+')
for line in lines:
    if PATTERN.match(line): ...
```

---

## Profiling Tools to Recommend

- **cProfile** — function-level CPU profiling
- **py-spy** — sampling profiler, no code changes needed
- **memory_profiler** — line-by-line memory usage
- **django-debug-toolbar** — query count + timing per request
- **SQLAlchemy `echo=True`** — logs all SQL
- **asyncio debug mode** — `PYTHONASYNCIODEBUG=1` to catch blocking calls

---

## Caching Strategies

### Query Caching

**When to cache**: Any DB query that is read-heavy, expensive, and whose result is stable for a meaningful period.

**Strong cache candidates**:
- Permission/role lookups per user (`get_user_permissions(user_id)`)
- Reference/lookup tables (categories, countries, config)
- Aggregation results (total counts, dashboards) with tolerable staleness
- ORM queries behind public-facing read endpoints with no user-specific data

**Django cache framework**:
```python
from django.core.cache import cache

def get_user_permissions(user_id: int) -> list:
    key = f"user:{user_id}:permissions"
    result = cache.get(key)
    if result is None:
        result = list(Permission.objects.filter(user_id=user_id).values_list('codename', flat=True))
        cache.set(key, result, timeout=900)  # 15 min TTL
    return result

# Invalidation — in signal or service layer:
def on_role_changed(user_id: int):
    cache.delete(f"user:{user_id}:permissions")
```

**Redis with explicit typing (FastAPI / SQLAlchemy)**:
```python
import redis, json

r = redis.Redis(host='localhost', decode_responses=True)

async def get_products(category_id: int) -> list:
    key = f"products:category:{category_id}"
    cached = r.get(key)
    if cached:
        return json.loads(cached)
    rows = await db.execute(select(Product).where(Product.category_id == category_id))
    result = [row._asdict() for row in rows]
    r.setex(key, 300, json.dumps(result, default=str))  # 5 min TTL
    return result

# Invalidation on write:
async def create_product(data: ProductCreate) -> Product:
    product = await db.execute(insert(Product).values(**data.dict()))
    r.delete(f"products:category:{data.category_id}")  # bust category list
    return product
```

---

### Function-Level / Computation Caching

**`@lru_cache` for pure in-process caching** (no TTL, lives for process lifetime):
```python
from functools import lru_cache

@lru_cache(maxsize=256)
def get_config(env: str) -> dict:
    return Config.objects.filter(env=env).values()
# Invalidation: lru_cache has no TTL — use only for truly static data
# or call get_config.cache_clear() on config reload
```

**`cachetools` for TTL-based in-memory caching**:
```python
from cachetools import TTLCache, cached

cache_store = TTLCache(maxsize=1000, ttl=300)

@cached(cache=cache_store)
def get_exchange_rate(currency: str) -> float:
    return ExternalAPI.fetch_rate(currency)
```

---

### HTTP / Response Caching

**Django per-view cache**:
```python
from django.views.decorators.cache import cache_page

@cache_page(60 * 5)  # 5 minutes
def product_list(request):
    ...
# Invalidation: use cache.delete('views.decorators.cache.cache_page.{key}')
# or vary_on_headers/vary_on_cookie for user-specific variants
```

**Cache-Control headers (FastAPI)**:
```python
from fastapi import Response

@app.get("/products")
async def products(response: Response):
    response.headers["Cache-Control"] = "public, max-age=300, stale-while-revalidate=60"
    return await get_products()
```

---

### Invalidation Patterns

| Pattern | Use when | Implementation |
|---------|----------|----------------|
| **TTL expiry** | Tolerable staleness exists | `cache.set(key, val, timeout=300)` |
| **Post-save signal** | Django ORM — invalidate on model save | `@receiver(post_save, sender=Product)` → `cache.delete(key)` |
| **Service-layer bust** | Any ORM — call `cache.delete()` in the write method | Co-locate with `create`, `update`, `delete` |
| **Key versioning** | Config/settings that change rarely | `key = f"config:v{settings.CONFIG_VERSION}"` |
| **Cache tags** (django-cachalot) | Complex ORM — auto-invalidates on table write | Zero manual work, but adds overhead |
| **Write-through** | High consistency required | Update cache and DB in same transaction |
| **Cache stampede prevention** | High concurrency on cold cache | Use `cache.add()` (atomic set-if-missing) + soft TTL |

---

### Cache Coherence Warnings to Flag

- `cache.set()` called **before** `db.commit()` — if commit fails, cache has stale data → always invalidate after commit
- Missing invalidation on **related** model updates (e.g., caching `order.total` but not invalidating when `OrderItem` changes)
- Using `@lru_cache` on a method that accesses DB — survives process restarts but never self-invalidates
- Caching per-user data under a shared key — data leak risk
- No cache key namespacing in multi-tenant apps — tenant A sees tenant B's data