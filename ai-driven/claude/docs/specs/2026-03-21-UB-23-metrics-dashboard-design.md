# UB-23: MCP Server Metrics Dashboard

## Problem Statement

Project owners have no visibility into the runtime health and usage patterns of their deployed MCP servers. They cannot answer basic questions: How many tool calls have been made? What is the error rate? Which tools are slow? Is the server even running?

### Why it matters

Without metrics, debugging production issues requires digging through raw log entries. There is no aggregated view to spot trends (rising error rates, latency spikes) or to understand which tools are used most. This slows down incident response and makes capacity planning impossible.

### Current situation

- The only runtime data available is the raw log stream (ring buffer of 200 entries per server, implemented in UB-24).
- Logs contain structured data (`mcp_tool_call` entries) with `response.status`, `response.duration_ms`, and `tool.name` -- all the raw material for metrics.
- There is no endpoint that computes aggregates from these logs.
- The dashboard has three tabs (Builder, Logs, History) but no metrics/monitoring tab.

### Design decision

**Compute metrics on-the-fly from the existing in-memory log cache.** No additional persistence layer. The ring buffer of 200 entries per server is the data source. The UI will display a disclaimer: "Metrics based on the last 200 events per server."

---

## Proposed Solution

### Overview

Add a metrics computation layer that reads structured logs from the existing ring buffer, aggregates them into per-server and per-tool statistics, and exposes them through a new REST endpoint. The ubby-back proxy aggregates metrics from all servers in a project. The frontend adds a "Metrics" tab to the dashboard sidebar showing summary cards and a server/tool breakdown table.

### User Stories

- As a project owner, I want to see an overview of total calls, error rate, and average latency across all my MCP servers so that I can assess overall health at a glance.
- As a project owner, I want to see per-server status, uptime, and call counts so that I can identify which server has issues.
- As a project owner, I want to expand a server row to see per-tool statistics (calls, errors, average latency) so that I can pinpoint which tool is misbehaving.
- As a project owner, I want the metrics to auto-refresh periodically so that I see near-real-time data without manual refresh.

---

## 1. ubby-mcp-api -- New Metrics Endpoint

### 1.1 New Use Case: `GetServerMetricsUseCase`

**New file:** `src/application/use-cases/get-server-metrics.use-case.ts`

This use case:
1. Verifies the server exists via `McpServerPort.findById(serverId)`.
2. Reads all logs from `LogCachePort.getLogs(serverId)` (no category filter -- needs all logs).
3. Computes aggregated metrics from the log entries.

**Computation logic:**

Only logs with `category === 'mcp'` (i.e., `StructuredLogType === 'mcp_tool_call'`) contribute to call metrics. Platform and tool (http_request) logs are excluded from call/error/latency calculations.

For each `mcp_tool_call` log entry:
- Parse the structured data via `toStructuredLog()`.
- Count as a call. If `response.status === 'error'`, count as an error call.
- Accumulate `response.duration_ms` for average latency calculation.
- Group by `tool.name` for per-tool breakdown.

For uptime:
- Find the most recent `server_lifecycle` log with `event === 'start'`.
- Compute uptime as `now - start_timestamp`. Format as human-readable string (e.g., "2h 15m").
- If no start event is found in the buffer, return `"unknown"`.

For `lastActivity`:
- The timestamp of the most recent log entry of any category.

**REQ-001:** `GetServerMetricsUseCase` SHALL compute metrics exclusively from `mcp_tool_call` log entries for call/error/latency aggregates.

**REQ-002:** `GetServerMetricsUseCase` SHALL derive uptime from the most recent `server_lifecycle` start event in the log buffer.

**REQ-003:** `GetServerMetricsUseCase` SHALL return `"unknown"` for uptime if no start event exists in the buffer.

### 1.2 New Controller Endpoint

**Modified file:** `src/application/controllers/mcp.controller.ts`

Add a new route to the existing `McpController`:

```
GET /mcp/:id/metrics
```

**Response shape:**

```json
{
  "serverId": "uuid-string",
  "status": "running",
  "uptime": "2h 15m",
  "totalCalls": 42,
  "successCalls": 38,
  "errorCalls": 4,
  "errorRate": 9.52,
  "avgLatencyMs": 245,
  "tools": [
    {
      "name": "getUsers",
      "calls": 20,
      "errors": 2,
      "avgLatencyMs": 180
    },
    {
      "name": "createUser",
      "calls": 22,
      "errors": 2,
      "avgLatencyMs": 310
    }
  ],
  "lastActivity": "2026-03-21T10:00:00Z",
  "bufferSize": 200,
  "logCount": 142
}
```

**Field definitions:**

| Field          | Type     | Description                                                        |
|----------------|----------|--------------------------------------------------------------------|
| serverId       | string   | The MCP server UUID                                                |
| status         | string   | Current server status from `McpServer.status` enum (pending/running/stopped/error) |
| uptime         | string   | Human-readable uptime since last start event, or "unknown"         |
| totalCalls     | number   | Count of `mcp_tool_call` log entries in the buffer                 |
| successCalls   | number   | Count where `response.status === 'success'`                        |
| errorCalls     | number   | Count where `response.status === 'error'`                          |
| errorRate      | number   | `(errorCalls / totalCalls) * 100`, rounded to 2 decimal places. 0 if totalCalls is 0 |
| avgLatencyMs   | number   | Average of `response.duration_ms` across all tool calls, rounded to nearest integer. 0 if totalCalls is 0 |
| tools          | array    | Per-tool breakdown, sorted by `calls` descending                   |
| tools[].name   | string   | Tool name from `tool.name`                                         |
| tools[].calls  | number   | Total calls for this tool                                          |
| tools[].errors | number   | Error calls for this tool                                          |
| tools[].avgLatencyMs | number | Average latency for this tool, rounded to nearest integer    |
| lastActivity   | string   | ISO 8601 timestamp of the most recent log entry, or `null` if no logs |
| bufferSize     | number   | Maximum ring buffer size (always 200 for V1)                       |
| logCount       | number   | Current number of log entries in the buffer for this server        |

**REQ-004:** `GET /mcp/:id/metrics` SHALL return 404 if the server does not exist.

**REQ-005:** `GET /mcp/:id/metrics` SHALL return valid metrics with all counts at 0 if the server exists but has no `mcp_tool_call` logs.

**REQ-006:** `errorRate` SHALL be computed as `(errorCalls / totalCalls) * 100` rounded to 2 decimal places, and SHALL be 0 when `totalCalls` is 0 (no division by zero).

**REQ-007:** `tools` array SHALL be sorted by `calls` descending (most-called tool first).

### 1.3 Domain Entity: `ServerMetrics`

**New file:** `src/domain/entities/server-metrics.entity.ts`

A plain value object (no framework dependencies) representing the computed metrics. The use case creates it, the controller serializes it.

```typescript
export interface ToolMetrics {
  name: string;
  calls: number;
  errors: number;
  avgLatencyMs: number;
}

export interface ServerMetrics {
  serverId: string;
  status: string;
  uptime: string;
  totalCalls: number;
  successCalls: number;
  errorCalls: number;
  errorRate: number;
  avgLatencyMs: number;
  tools: ToolMetrics[];
  lastActivity: string | null;
  bufferSize: number;
  logCount: number;
}
```

### 1.4 Module Wiring

**Modified file:** `src/app.module.ts`

Register `GetServerMetricsUseCase` in the `providers` array. It depends on `MCP_SERVER_PORT` and `LOG_CACHE_PORT` (both already exported from `McpUseModule`).

**Modified file:** `src/application/controllers/mcp.controller.ts`

Inject `GetServerMetricsUseCase` in the constructor.

---

## 2. ubby-back -- Proxy Endpoint

### 2.1 New Use Case: `GetProjectMetricsUseCase`

**New file:** `src/application/use_cases/get_project_metrics_use_case.py`

This use case follows the exact same pattern as `GetMcpServerLogsUseCase`:
1. Authenticate the user via `AuthService`.
2. Verify project access via `ProjectAccessService`.
3. Retrieve MCP server configuration from `McpServerRepoPort`.
4. Extract server IDs via `McpServerConfigExtractor.extract_server_ids()`.
5. For each server ID, call `GET {mcp_api_base_url}/{server_id}/metrics` via `HttpClientPort`.
6. Aggregate the results into a project-level response.

**Aggregation logic:**

```python
{
  "projectId": project_id,
  "servers": [
    # Raw metrics response from each server, as-is
  ],
  "summary": {
    "totalServers": len(server_ids),
    "activeServers": count of servers with status "running",
    "totalCalls": sum of all servers' totalCalls,
    "totalErrors": sum of all servers' errorCalls,
    "errorRate": (totalErrors / totalCalls) * 100 if totalCalls > 0 else 0,
    "avgLatencyMs": weighted average of avgLatencyMs by totalCalls per server
  }
}
```

**REQ-008:** `GetProjectMetricsUseCase` SHALL aggregate metrics from all servers in the project.

**REQ-009:** If a server is unreachable (mcp-api returns error), the use case SHALL skip that server and log a warning, not fail the entire request. The skipped server SHALL appear in the response with `status: "unreachable"` and all counts at 0.

**REQ-010:** The `summary.avgLatencyMs` SHALL be a weighted average: `sum(server.avgLatencyMs * server.totalCalls) / sum(server.totalCalls)`. If total calls across all servers is 0, it SHALL be 0.

### 2.2 New Route

**Modified file:** `src/application/routes/mcp.py`

Add a new endpoint:

```
GET /mcp/deploy/{project_id}/metrics
```

Response: the aggregated structure described above.

**REQ-011:** The route SHALL use the `@handle_route_exceptions` decorator consistent with existing MCP routes.

**REQ-012:** The route SHALL require the `Authorization` header (same auth pattern as existing MCP routes).

### 2.3 Dependency Injection

**Modified file:** `src/dependencies.py`

Add a `get_project_metrics_use_case` factory function following the same pattern as `get_mcp_server_logs_use_case` (same dependencies: `auth_service`, `mcp_server_repo`, `http_client`, `mcp_api_base_url`, `project_access_service`, `config_extractor`).

---

## 3. ubby-front -- Metrics Tab

### 3.1 Sidebar Menu Item

**Modified file:** `src/domain/entities/MenuItem.ts`

Add `'metrics'` to the `MenuIconSchema` enum:

```typescript
export const MenuIconSchema = z.enum(['builder', 'logs', 'settings', 'history', 'metrics'])
```

Add the new menu item to `DEFAULT_MENU_ITEMS`:

```typescript
{
  id: 'metrics',
  label: 'Metrics',
  icon: 'metrics',
  path: '/metrics',
}
```

Insert it between "Logs" and "History" in the array.

**Modified file:** `src/application/components/sidebar/SidebarMenu.tsx`

Add a metrics icon to the `iconMap`. Use `BarChart3` from `lucide-react`:

```typescript
import { BarChart3, FileText, History, Layout, Settings } from 'lucide-react'

const iconMap = {
  builder: Layout,
  logs: FileText,
  settings: Settings,
  history: History,
  metrics: BarChart3,
}
```

### 3.2 Dashboard Tab Panel

**Modified file:** `src/application/pages/DashboardPage.tsx`

Add a new `TabPanel` for the metrics tab:

```tsx
<TabPanel value="metrics" current={tab}>
  <Metrics isActive={tab === 'metrics'} projectId={projectId} />
</TabPanel>
```

### 3.3 API Client

**Modified file:** `src/infrastructure/api/ProjectRepositoryApi.ts`

Add a `getMetrics` method:

```typescript
async getMetrics(projectId: string): Promise<ProjectMetrics> {
  const url = `/mcp/deploy/${projectId}/metrics`
  const response = await this.fetchRaw(url, {
    headers: this.getHeaders(),
  })

  if (!response.ok) {
    if (response.status === 404) {
      return null
    }
    throw new Error('Failed to fetch metrics')
  }

  return (await response.json()) as ProjectMetrics
}
```

### 3.4 Domain Types

**New file:** `src/domain/entities/Metrics.ts`

```typescript
import { z } from 'zod/v4'

export const ToolMetricsSchema = z.object({
  name: z.string(),
  calls: z.number(),
  errors: z.number(),
  avgLatencyMs: z.number(),
})

export const ServerMetricsSchema = z.object({
  serverId: z.string(),
  status: z.string(),
  uptime: z.string(),
  totalCalls: z.number(),
  successCalls: z.number(),
  errorCalls: z.number(),
  errorRate: z.number(),
  avgLatencyMs: z.number(),
  tools: z.array(ToolMetricsSchema),
  lastActivity: z.string().nullable(),
  bufferSize: z.number(),
  logCount: z.number(),
})

export const MetricsSummarySchema = z.object({
  totalServers: z.number(),
  activeServers: z.number(),
  totalCalls: z.number(),
  totalErrors: z.number(),
  errorRate: z.number(),
  avgLatencyMs: z.number(),
})

export const ProjectMetricsSchema = z.object({
  projectId: z.union([z.string(), z.number()]),
  servers: z.array(ServerMetricsSchema),
  summary: MetricsSummarySchema,
})

export type ToolMetrics = z.infer<typeof ToolMetricsSchema>
export type ServerMetrics = z.infer<typeof ServerMetricsSchema>
export type MetricsSummary = z.infer<typeof MetricsSummarySchema>
export type ProjectMetrics = z.infer<typeof ProjectMetricsSchema>
```

**Modified file:** `src/domain/entities/index.ts`

Export the new types.

### 3.5 TanStack Query Hook

**Modified file:** `src/application/hooks/useProjectRepository.ts`

Add a `useMetrics` hook following the same pattern as `useLogs`:

```typescript
const useMetrics = (enabled = false) => {
  return useQuery({
    queryKey: ['metrics', projectState.id],
    queryFn: () => projectRepositoryApi.getMetrics(projectState.id),
    enabled: enabled && !!projectState.id,
    refetchInterval: 1000 * 30, // 30 seconds
  })
}
```

**REQ-013:** Metrics polling interval SHALL be 30 seconds.

**REQ-014:** Metrics query SHALL only be active when the Metrics tab is selected (`enabled` parameter).

### 3.6 Metrics Component

**New file:** `src/application/components/metrics/Metrics.tsx`

The component renders three sections:

#### Section A: Summary Cards (top row)

Four cards in a horizontal row:

| Card            | Value source               | Format          |
|-----------------|----------------------------|-----------------|
| Total Servers   | `summary.totalServers`     | Integer         |
| Total Calls     | `summary.totalCalls`       | Integer         |
| Error Rate      | `summary.errorRate`        | `X.XX%`         |
| Avg Latency     | `summary.avgLatencyMs`     | `XXXms`         |

Card styling: MUI `Card` component with subtle borders, consistent with the existing dashboard aesthetic (light background `rgb(245, 246, 248)`).

Color coding for error rate card:
- Green (`#27c93f`) when errorRate < 5%
- Orange (`#ffbd2e`) when errorRate >= 5% and < 20%
- Red (`#ff5f56`) when errorRate >= 20%

#### Section B: Servers Table

A table listing each server with columns:

| Column       | Source                  | Notes                           |
|--------------|-------------------------|---------------------------------|
| Server ID    | `server.serverId`       | Truncated to first 8 chars      |
| Status       | `server.status`         | Color-coded badge               |
| Uptime       | `server.uptime`         | String as-is                    |
| Total Calls  | `server.totalCalls`     | Integer                         |
| Errors       | `server.errorCalls`     | Integer, red if > 0             |
| Error Rate   | `server.errorRate`      | `X.XX%`                         |
| Avg Latency  | `server.avgLatencyMs`   | `XXXms`                         |
| Last Activity| `server.lastActivity`   | Relative time ("2m ago")        |

Status badge colors:
- `running`: green
- `stopped`: grey
- `error`: red
- `pending`: yellow
- `unreachable`: orange dashed border

Each row is expandable (click to toggle). Expanding a row reveals the tools breakdown table.

#### Section C: Tools Breakdown (nested, per server)

Displayed inside the expanded server row:

| Column       | Source               | Notes                     |
|--------------|----------------------|---------------------------|
| Tool Name    | `tool.name`          | Full name                 |
| Calls        | `tool.calls`         | Integer                   |
| Errors       | `tool.errors`        | Integer, red if > 0       |
| Avg Latency  | `tool.avgLatencyMs`  | `XXXms`, color-coded      |

Latency color coding:
- Green when < 500ms
- Orange when >= 500ms and < 2000ms
- Red when >= 2000ms

#### Section D: Disclaimer

A small muted text at the bottom of the metrics panel:

> "Metrics based on the last 200 events per server. Data is computed on-the-fly and resets when the server restarts."

**REQ-015:** The disclaimer text SHALL always be visible at the bottom of the Metrics tab.

**REQ-016:** The Metrics component SHALL show a loading spinner while the first fetch is in progress.

**REQ-017:** The Metrics component SHALL show an empty state with message "No MCP servers deployed for this project" when the API returns 404.

**REQ-018:** The Metrics component SHALL show a refresh button (same pattern as the Logs component) and a subtle "Last updated: X seconds ago" indicator.

**New file:** `src/application/components/metrics/index.ts`

Barrel export.

---

## 4. Files to Modify Per Repository

### ubby-mcp-api (NestJS / TypeScript)

| File (exact path)                                              | Change                                                |
|----------------------------------------------------------------|-------------------------------------------------------|
| `src/domain/entities/server-metrics.entity.ts`                 | **NEW** -- `ServerMetrics` and `ToolMetrics` interfaces |
| `src/application/use-cases/get-server-metrics.use-case.ts`     | **NEW** -- Use case that reads logs and computes metrics |
| `src/application/controllers/mcp.controller.ts`                | Add `GET :id/metrics` route, inject new use case       |
| `src/app.module.ts`                                            | Register `GetServerMetricsUseCase` in providers        |
| `test/unit/get-server-metrics.use-case.spec.ts`                | **NEW** -- Unit tests for metrics computation          |
| `test/unit/mcp-controller-metrics.spec.ts`                     | **NEW** -- Controller test for metrics endpoint        |

### ubby-back (FastAPI / Python)

| File (exact path)                                              | Change                                                |
|----------------------------------------------------------------|-------------------------------------------------------|
| `src/application/use_cases/get_project_metrics_use_case.py`    | **NEW** -- Use case that proxies and aggregates metrics |
| `src/application/routes/mcp.py`                                | Add `GET /mcp/deploy/{project_id}/metrics` route       |
| `src/dependencies.py`                                          | Add `get_project_metrics_use_case` factory function    |
| `tests/unit/test_get_project_metrics_use_case.py`              | **NEW** -- Unit tests for metrics aggregation          |

### ubby-front (React / TypeScript / Vite)

| File (exact path)                                              | Change                                                |
|----------------------------------------------------------------|-------------------------------------------------------|
| `src/domain/entities/Metrics.ts`                               | **NEW** -- Zod schemas and types for metrics           |
| `src/domain/entities/index.ts`                                 | Export new metrics types                               |
| `src/domain/entities/MenuItem.ts`                              | Add `'metrics'` to `MenuIconSchema`, add menu item     |
| `src/domain/ports/ProjectRepository.ts`                        | Add `getMetrics` method signature                      |
| `src/infrastructure/api/ProjectRepositoryApi.ts`               | Implement `getMetrics` method                          |
| `src/application/hooks/useProjectRepository.ts`                | Add `useMetrics` hook                                  |
| `src/application/components/sidebar/SidebarMenu.tsx`           | Add `BarChart3` icon mapping for metrics               |
| `src/application/pages/DashboardPage.tsx`                      | Add `TabPanel` for metrics tab                         |
| `src/application/components/metrics/Metrics.tsx`               | **NEW** -- Main metrics component                      |
| `src/application/components/metrics/index.ts`                  | **NEW** -- Barrel export                               |
| `src/test/domain/entities/MenuItem.test.ts`                    | Update tests for new menu item                         |
| `src/test/application/components/metrics/Metrics.test.tsx`     | **NEW** -- Unit tests for metrics component            |

---

## 5. Acceptance Criteria

### Happy Path

- [ ] Given a running server with 50 `mcp_tool_call` logs (40 success, 10 error), when `GET /mcp/:id/metrics` is called, then `totalCalls` is 50, `successCalls` is 40, `errorCalls` is 10, and `errorRate` is 20.00.
- [ ] Given the same server, when metrics are requested, then `avgLatencyMs` is the arithmetic mean of all 50 `response.duration_ms` values, rounded to the nearest integer.
- [ ] Given a server with a `server_lifecycle` start event 2 hours and 15 minutes ago, when metrics are requested, then `uptime` is `"2h 15m"`.
- [ ] Given a project with 3 servers, when `GET /mcp/deploy/{project_id}/metrics` is called, then the response contains 3 entries in `servers[]` and the `summary` aggregates all three.
- [ ] Given the Metrics tab is selected in the dashboard, when 30 seconds elapse, then the metrics data auto-refreshes without user interaction.
- [ ] Given a server has tool calls for "getUsers" (20 calls) and "createUser" (30 calls), when metrics are returned, then `tools[0]` is "createUser" (sorted by calls descending).
- [ ] Given the user clicks a server row in the metrics table, when the row expands, then the per-tool breakdown is visible with name, calls, errors, and avg latency.

### Error Cases

- [ ] Given a non-existent server ID, when `GET /mcp/:id/metrics` is called, then 404 is returned.
- [ ] Given one of three servers is unreachable, when project metrics are requested, then the two reachable servers have full metrics and the unreachable one shows `status: "unreachable"` with all counts at 0.
- [ ] Given the user has no MCP servers deployed, when the Metrics tab is opened, then the empty state message "No MCP servers deployed for this project" is displayed.
- [ ] Given the ubby-mcp-api is completely unreachable, when project metrics are requested from ubby-back, then a 502/503 error is returned with a descriptive message.

### Edge Cases

- [ ] Given a server with 0 log entries, when metrics are requested, then all counts are 0, `errorRate` is 0.00, `avgLatencyMs` is 0, `tools` is an empty array, `lastActivity` is null, and `uptime` is "unknown".
- [ ] Given a server with only `platform` and `tool` category logs (no `mcp_tool_call`), when metrics are requested, then `totalCalls` is 0 but `lastActivity` reflects the timestamp of the most recent log.
- [ ] Given a server whose start event has been evicted from the ring buffer, when metrics are requested, then `uptime` is "unknown".
- [ ] Given `totalCalls` is 0 for all servers in a project, when `summary.avgLatencyMs` is computed, then it is 0 (no division by zero).
- [ ] Given the Metrics tab is not selected, when time elapses, then no metrics polling requests are made.

---

## 6. Out of Scope

- **Historical metrics / time-series data.** No persistence. Metrics are computed on-the-fly from the current ring buffer contents.
- **Alerting / thresholds.** No notifications when error rate exceeds a threshold.
- **Per-tool filtering or search in the metrics view.** The tools table is a flat list; no search/filter needed for V1.
- **Export metrics** (CSV, JSON download). Not in this ticket.
- **Grafana / Prometheus integration.** Not in this ticket.
- **WebSocket / SSE for real-time metrics streaming.** Polling at 30s is sufficient.
- **Metrics for non-`mcp_tool_call` events.** Only tool calls contribute to call/error/latency metrics.

---

## 7. Implementation Order

Strict sequential order across repositories:

### Phase 1: ubby-mcp-api (backend metrics endpoint)

1. Create `ServerMetrics` and `ToolMetrics` interfaces in `src/domain/entities/server-metrics.entity.ts`.
2. Create `GetServerMetricsUseCase` in `src/application/use-cases/get-server-metrics.use-case.ts` with the computation logic.
3. Add `GET :id/metrics` route to `McpController` in `src/application/controllers/mcp.controller.ts`.
4. Register the use case in `src/app.module.ts`.
5. Write unit tests: `test/unit/get-server-metrics.use-case.spec.ts` and `test/unit/mcp-controller-metrics.spec.ts`.

### Phase 2: ubby-back (proxy)

6. Create `GetProjectMetricsUseCase` in `src/application/use_cases/get_project_metrics_use_case.py`.
7. Add `GET /mcp/deploy/{project_id}/metrics` route to `src/application/routes/mcp.py`.
8. Add `get_project_metrics_use_case` factory in `src/dependencies.py`.
9. Write unit tests: `tests/unit/test_get_project_metrics_use_case.py`.

### Phase 3: ubby-front (UI)

10. Create `src/domain/entities/Metrics.ts` with Zod schemas and types.
11. Export from `src/domain/entities/index.ts`.
12. Add `'metrics'` to `MenuIconSchema` and `DEFAULT_MENU_ITEMS` in `src/domain/entities/MenuItem.ts`.
13. Add `BarChart3` icon to `src/application/components/sidebar/SidebarMenu.tsx`.
14. Add `getMetrics` method to `src/infrastructure/api/ProjectRepositoryApi.ts`.
15. Add `useMetrics` hook to `src/application/hooks/useProjectRepository.ts`.
16. Create `src/application/components/metrics/Metrics.tsx` with summary cards, server table, expandable tool breakdown, and disclaimer.
17. Create `src/application/components/metrics/index.ts` barrel export.
18. Add the `TabPanel` for metrics in `src/application/pages/DashboardPage.tsx`.
19. Update existing tests for MenuItem, add new tests for Metrics component.

---

## 8. Open Questions

- [ ] **Uptime format precision:** Should uptime show seconds for short durations (e.g., "45s", "3m 12s") or always round to minutes ("1m")? Recommendation: show seconds only when uptime < 1 hour, otherwise "Xh Ym".
- [ ] **Weighted average edge case:** When aggregating project-level avg latency and one server has 1000 calls at 100ms while another has 1 call at 5000ms, the weighted average will be ~105ms. Is this the desired behavior, or should the UI also show per-server latency prominently? Recommendation: weighted average in summary, per-server values in the table -- which is already the design.

---

## 9. Technical Notes

- The `LogCachePort` interface does not need modification. `getLogs(serverId)` without a category filter already returns all logs. The use case filters in-memory.
- The `toStructuredLog()` method on `LogEntry` throws if the entry has no structured data (legacy entries). The use case must handle this gracefully by wrapping in try/catch or checking `category` before calling `toStructuredLog()`.
- For uptime calculation, the use case iterates logs in reverse (most recent first) to find the latest `server_lifecycle` start event efficiently.
- The `HttpClientPort.get_json()` in ubby-back currently returns `list[dict]`. For the metrics endpoint, we need it to return a single `dict`. Either add a new method to the port (e.g., `get_json_object()`) or handle the type difference in the use case. Recommendation: add a `get_json_object(url: str) -> dict[str, Any]` method to `HttpClientPort` and implement it in `HttpxAdapter`.
- The MUI table in the frontend should use `TableContainer`, `Table`, `TableHead`, `TableBody`, `TableRow`, `TableCell` from `@mui/material` for consistency.
- The expandable row pattern should use MUI `Collapse` component, same pattern used in the Logs component for expandable log entries.
