# IaC Review Scoring Rubric

Score each of the 6 dimensions from 1 to 10 using the anchors below. The overall score is your holistic judgment from the 6 dimension scores — you weight the dimensions based on the change's context (e.g. an ingress change weights security higher; a probe addition weights reliability higher).

## Correctness
Are the manifests valid and internally consistent?

| Score | Anchor |
|---|---|
| 10 | Valid YAML, current API versions, Flux `path` matches dir, selectors match labels, service ports match container ports, names DNS-1035 compliant |
| 8 | Valid; one minor mismatch (a label typo, a port that works but isn't named) |
| 5 | A deprecated API version (e.g. `policy/v1beta1`), OR a Kustomization `path` that doesn't match the directory, OR a selector that doesn't match the pod labels |
| 0 | Invalid YAML, OR a resource that will fail to apply, OR a Deployment whose selector doesn't match its pods |

## Security
Are secrets, network, and identity handled safely?

| Score | Anchor |
|---|---|
| 10 | All secrets via ExternalSecrets (none in Git), NetworkPolicies on exposed workloads, oauth2-proxy on public ingresses, no privileged/hostPath/hostNetwork, `runAsUser`+`runAsGroup` set, `readOnlyRootFilesystem` where possible, image tags pinned (not `latest`) |
| 8 | No secrets in Git; one missing NetworkPolicy on an internal-only service; images pinned |
| 5 | A secret in a ConfigMap, OR a public ingress without oauth2-proxy, OR `latest`/untagged image, OR `runAsUser: 0` |
| 0 | Secret material committed to Git, OR a privileged container exposed publicly, OR no auth on a sensitive endpoint |

## Reliability
Will the workload survive restarts, node loss, and load?

| Score | Anchor |
|---|---|
| 10 | Startup + liveness + readiness probes on every Deployment, requests + limits on every container, `revisionHistoryLimit` set, PDB for multi-replica, `strategy` matches statefulness (RollingUpdate stateless, StatefulSet stateful) |
| 8 | Probes + resources present; one missing `revisionHistoryLimit` or PDB |
| 5 | Missing probes on a production Deployment, OR missing resources (no limits = unbounded), OR stateful data on a Deployment (should be StatefulSet) |
| 0 | No probes anywhere, no resources anywhere, stateful workload on a Deployment with `RollingUpdate` (data loss risk) |

## Consistency
Do the same patterns apply across namespaces?

| Score | Anchor |
|---|---|
| 10 | Same probe shape, same resource policy, same labeling (`app.kubernetes.io/part-of`), same ingress annotations, same image pull policy across all namespaces |
| 8 | Consistent except one namespace that diverges slightly (e.g. one app lacks `topologySpreadConstraints`) |
| 5 | Two namespaces with fundamentally different patterns for the same concern (e.g. oauth2-proxy via Traefik middleware in one, inline in another) |
| 0 | Every namespace reinvents the same resource differently — no shared conventions |

## GitOps hygiene
Does Flux reconcile correctly and safely?

| Score | Anchor |
|---|---|
| 10 | Kustomization `path` matches dir, `prune: true` for apps, `prune: false` only for cluster-level resources, `interval` ≤ 5m, `timeout` reasonable, `sourceRef` correct, dependency order respected (cluster → secrets → auth → observability → apps), `targetNamespace` set |
| 8 | Correct; one `prune: false` on an app namespace, or a long `interval` (10m+) |
| 5 | A Kustomization `path` pointing at the wrong directory, OR `prune` misconfigured (true on cluster, false on apps), OR a missing dependency that causes a reconcile race |
| 0 | Circular Kustomization dependencies, OR `path` points at a non-existent directory, OR `sourceRef` to a deleted GitRepository |

## Maintainability
Can the next person extend this without rewriting?

| Score | Anchor |
|---|---|
| 10 | Shared manifests via Kustomize base/overlay when 3+ namespaces repeat the same shape, values externalized to `config/<env>/<service>/values.yaml`, no duplicated manifests, comments explain non-obvious choices (e.g. why `prune: false`) |
| 8 | Minor duplication (oauth2-proxy manifests copy-pasted across 3 namespaces with 1-line diffs each) |
| 5 | Same Deployment manifest copy-pasted across 5 namespaces with divergent edits, OR values hardcoded in manifests instead of `config/` |
| 0 | Everything copy-pasted, divergent, no shared base — future changes require editing N files in sync |

## How to decide the overall score
- Look at the 6 dimension scores
- Weight by context: a one-line image bump weights correctness + GitOps hygiene; a new namespace weights all six; a security-sensitive ingress change weights security heavily; a probe addition weights reliability
- A 0–3 in **Security** or **Correctness** usually caps the overall at 5 (request changes) — these are production-safety blockers
- A 0–3 in Reliability alone usually doesn't block but pulls the overall down; two or more low dimensions (≤5) usually means request changes
- The overall is a holistic judgment, not an average — justify it in one sentence in the Score table