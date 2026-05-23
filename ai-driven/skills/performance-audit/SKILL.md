---
name: performance-audit
description: >
  Deep performance audit for Python and React codebases. Use this skill ANY TIME the user
  shares code and mentions performance, slow queries, latency, re-renders, optimization,
  profiling, bottlenecks, or memory issues — even if they don't use the word "audit".
  Also trigger when the user pastes code and asks "is this efficient?", "why is this slow?",
  "how can I improve this?", or shares ORM/database code (Django, SQLAlchemy, Prisma, TypeORM)
  where N+1 query risks are high. Covers: N+1 queries, missing indexes, loop anti-patterns,
  React re-render storms, missing memoization, bundle bloat, async misuse, memory leaks,
  caching strategy opportunities (query caching, HTTP caching, client-side caching, cache
  invalidation triggers), and 20+ other patterns across both stacks.
---

# Performance Audit Skill

Perform systematic, production-grade performance audits on Python and React code.
Always be direct: name the exact line/pattern, explain the cost, and provide a fixed version.

---

## Step 1 — Detect the domain(s)

Scan the provided code or file list:
- **Python indicators**: `.py` files, `import`, `def`, `class`, ORM imports (`django`, `sqlalchemy`, `tortoise`, `peewee`), `async def`, `FastAPI`, `Flask`, `Celery`
- **React indicators**: `.jsx`, `.tsx`, `.js` with JSX, `useState`, `useEffect`, `React`, `Next.js`, `Vite`
- **Both**: monorepo or full-stack projects — run both audits

→ Load **only** the relevant reference file(s) before proceeding:
- Python: read `references/python-patterns.md`
- React: read `references/react-patterns.md`

---

## Step 2 — Structured audit pass

For each domain detected, systematically scan for every pattern listed in the reference file.
Do **not** skip patterns just because they seem unlikely — check the code explicitly.

Use this internal checklist approach:
1. Read the full code once for context
2. Second pass: match each pattern category from the reference file
3. Tag every finding with a severity level (see below)

---

## Step 3 — Caching strategy analysis (always run, for every domain detected)

This is a mandatory second pass focused exclusively on caching opportunities and invalidation.
Run it independently from the performance pattern scan — do not merge findings.

Load the `## Caching Strategies` section from the relevant reference file(s) and answer these questions for the provided code:

### 3a — What can be cached?

For every data access, computation, or API call found in the code, evaluate:
- **Is the result deterministic / stable enough to cache?** (same input → same output for a meaningful TTL)
- **What is the read/write ratio?** High reads, rare writes = strong cache candidate
- **What is the cost of recomputing?** DB query, external API call, heavy computation = cache it
- **What is the acceptable staleness window?** Real-time data = no cache or very short TTL; reference data = long TTL

For each cache opportunity found, report:

```
### 💾 CACHE OPPORTUNITY — [Name]
**Location**: `file.py:55` / `useUsers.ts:12`
**Type**: [Query Cache / HTTP Cache / In-Memory / Client State Cache / Full-Page Cache]
**What to cache**: [exact value — e.g., "result of `get_user_permissions(user_id)`"]
**Recommended TTL**: [e.g., "5 minutes", "until logout", "until product updated"]
**Suggested tool**: [e.g., Redis + django-cache-machine, React Query staleTime, SWR, HTTP Cache-Control]

**Before (no cache)**:
\`\`\`python
# current code
\`\`\`

**After (with cache)**:
\`\`\`python
# cached version
\`\`\`
```

### 3b — When should the cache be invalidated?

For every cache opportunity identified in 3a, always specify the invalidation strategy:

| Trigger type | Description | Example |
|---|---|---|
| **Time-based (TTL)** | Expire after N seconds regardless | User session data: TTL 15min |
| **Event-based** | Invalidate on a specific write/mutation | Clear `product:{id}` cache on `product.save()` |
| **Version-based** | Cache key includes a version/hash | `settings:v{hash}` — key changes when config changes |
| **User-scoped** | Invalidate per user on logout or role change | `perms:user:{id}` cleared on role update |
| **Manual/admin** | Explicit flush endpoint or CLI command | Cache warming scripts after deploys |

For each opportunity, pick the **primary** invalidation strategy and state the exact trigger:
```
**Invalidation**:
- Strategy: Event-based
- Trigger: on `Order.objects.create()` / `PATCH /orders/:id` / `useCreateOrder()` mutation
- Implementation: `cache.delete(f"order_list:user:{user_id}")` in post_save signal
```

### 3c — Cache coherence warnings

Flag any existing caching code that has incorrect or missing invalidation:
- Cache that is never invalidated (permanent stale risk)
- Cache invalidated too aggressively (negates the benefit)
- Race conditions: cache written before DB commit
- Missing cache invalidation on related entity updates

---

## Step 4 — Output format

Always produce a structured report in this format:

```
## Performance Audit Report

### Summary
- X critical issues, Y warnings, Z suggestions
- X cache opportunities identified
- Estimated impact: [e.g., "3 N+1 queries on hot path — likely major latency source"]

---

### 🔴 CRITICAL — [Issue Name]
**Location**: `file.py`, line 42 / component `UserList`
**Pattern**: [Pattern category, e.g., N+1 Query]
**Cost**: [Concrete explanation — e.g., "fires 1 query per row; 1000 users = 1000 queries"]

**Problematic code**:
\`\`\`python
# what you wrote
\`\`\`

**Fixed code**:
\`\`\`python
# the correct version with explanation inline
\`\`\`

**Why**: [1-2 sentence explanation of the fix]

---

### 🟡 WARNING — [Issue Name]
...

### 🔵 SUGGESTION — [Issue Name]
...

---

## 💾 Caching Strategy Report

### Cache Opportunities

[One block per opportunity found — see Step 3a format]

---

### Cache Invalidation Plan

| Cache Key | TTL | Primary Trigger | Invalidation Call |
|-----------|-----|-----------------|-------------------|
| `user:{id}:permissions` | 15min | Role updated | `cache.delete(key)` in signal |
| `product_list` | — | `Product.save()` | `cache.delete('product_list')` |

---

### ⚠️ Cache Coherence Issues

[Any existing broken or missing invalidation found in the code]

---
```

---

## Severity Scale

| Level | Label | Meaning |
|-------|-------|---------|
| 🔴 | CRITICAL | Production-impacting: query explosions, memory leaks, blocking the event loop, O(n²)+ in hot paths |
| 🟡 | WARNING | Meaningful degradation under load: missing memoization on expensive ops, unnecessary re-renders, missing indexes |
| 🔵 | SUGGESTION | Best-practice gaps: could matter at scale, improves maintainability |

---

## Step 5 — Always end with a full findings index

After all individual findings, close the report with:

```
---

### 📋 Full Findings Index

**Performance Issues**
| # | Severity | Pattern | Location | Fix Effort |
|---|----------|---------|----------|------------|
| 1 | 🔴 CRITICAL | N+1 Query | `views.py:34` | Low |
| 2 | 🟡 WARNING  | Missing useMemo | `UserList.tsx:18` | Low |
| 3 | 🔵 SUGGESTION | Regex not compiled | `utils.py:72` | Low |
...

**Cache Opportunities**
| # | Type | What | Recommended Tool | Invalidation Trigger |
|---|------|------|-----------------|----------------------|
| 1 | Query Cache | `get_user_permissions()` | Redis / django cache | Role update event |
| 2 | Client State Cache | `/api/products` list | React Query (staleTime 5min) | `useCreateProduct` mutation |
...

**Total**: X critical · Y warnings · Z suggestions · W cache opportunities

---

### 🔬 Profiling Recommendations

List every relevant profiling tool for the detected stack(s), e.g.:
- `django-debug-toolbar` — verify query count per request
- `py-spy record -o profile.svg -- python app.py` — CPU flame graph
- React DevTools Profiler → record a session, check "Ranked" view for slowest commits
- `webpack-bundle-analyzer` / `vite-bundle-visualizer` — bundle composition

---

### ✅ Verification Checklist

For each CRITICAL and WARNING finding, provide a one-liner or small snippet to confirm the fix worked:
- "Query count: assert `len(django.db.connection.queries) == 1` after fix"
- "Re-render count: add `console.count('UserList render')` and confirm it drops"
- "Cache hit: log cache.get() before and after first request to confirm HIT on second call"
```

**Rule**: never skip a finding. If 12 issues were found, all 12 must appear in the index table. All cache opportunities must appear in the cache table. Do not summarize or merge findings to keep the list short.

---

## Tone & style rules

- Be surgical, not generic. "You have performance issues" is useless. "Line 34: `User.objects.all()` inside a loop fires N queries" is useful.
- Always show before/after code for every finding.
- Acknowledge when code is already well-optimized for a given pattern — don't invent issues.
- If the code snippet is too partial to make a definitive call, say so and explain what you'd need to see.