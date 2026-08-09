# Flux CD Checklist

Concrete checks for Flux CRs and the flux repo conventions.

## GitRepository
- [ ] `apiVersion: source.toolkit.fluxcd.io/v1`
- [ ] `spec.url` is a valid Git URL (HTTPS preferred for read-only)
- [ ] `spec.ref.branch` matches the actual branch (`main` by default)
- [ ] `spec.interval` sensible (1m for the source is fine; don't use 10s)
- [ ] One GitRepository per repo (not per namespace — Kustomizations reference it)

## Kustomization
- [ ] `apiVersion: kustomize.toolkit.fluxcd.io/v1`
- [ ] `spec.path` matches an actual directory in the repo (e.g. `prd/opencode` not `prd/open-code`)
- [ ] `spec.sourceRef.kind: GitRepository`, `name` matches the GitRepository
- [ ] `spec.targetNamespace` set (and matches the directory under `prd/`)
- [ ] `spec.prune: true` for app namespaces (soludev, pickpro, ubby, opencode, openclaw, liame, unispace, composables, pickpro-dev)
- [ ] `spec.prune: false` for cluster-level resources (`prd/cluster` — don't auto-delete cluster config)
- [ ] `spec.interval` ≤ 5m (2m is the repo default)
- [ ] `spec.timeout` reasonable (90s is the repo default; increase for slow-to-start workloads)
- [ ] `spec.wait: true` for app namespaces (Flux waits for resources to be ready); `false` for `prd/cluster` (cluster resources don't have a Ready condition)
- [ ] No duplicate Kustomization names in the same namespace

## Dependency order (critical)
The flux repo must reconcile in this order — infra before apps:
1. `prd/cluster` (CoreDNS, NFS backup) — `wait: false`, `prune: false`
2. Secrets infra: OpenBao, ExternalSecrets operator
3. Auth: Logto, oauth2-proxy
4. Observability: OpenObserve collectors
5. Storage: MinIO
6. Apps: opencode, pickpro, ubby, openclaw, liame, unispace, composables

When reviewing a new Kustomization, check it doesn't depend on a resource reconciled later in the chain. If it does, add a `dependsOn` to the prerequisite Kustomization.

## HelmRelease (when used)
- [ ] `apiVersion: helm.toolkit.fluxcd.io/v2beta1`
- [ ] `spec.chart.spec.chart` matches the Chart name
- [ ] `spec.chart.spec.version` pinned (not a range for prod)
- [ ] `spec.chart.spec.sourceRef` references a HelmRepository
- [ ] `spec.interval` ≤ 5m
- [ ] `values` in `config/<env>/<service>/values.yaml` if large; inline if small and stable

## HelmRepository
- [ ] `apiVersion: source.toolkit.fluxcd.io/v1beta2`
- [ ] `spec.url` valid
- [ ] `spec.type: oci` for OCI registries; `default` for HTTP
- [ ] `spec.interval` ≤ 10m (sources don't need to refresh often)

## Repo conventions (observed)
- Flux config: `config/<env>/` (GitRepository, Kustomization, per-service values)
- Manifests: `prd/<namespace>/<service>/<resource>.yaml`
- Scripts: `config/scripts/` (install-flux, install-openbao, backup-openobserve, etc.)
- One file per resource (e.g. `deployment.yaml`, `service.yaml`, `ingress.yaml`)
- Namespaces match directory: `prd/opencode/` → namespace `opencode`
- Ingress backend for public services: `oauth2-proxy-service:4180`
- ExternalSecrets store: `openbao-backend` (ClusterSecretStore)
- Probes: HTTP for web apps, TCP for databases, `startupProbe` for slow-start images
- Labels: `app: <name>` + `app.kubernetes.io/part-of: soludev-workload`

## Anti-patterns to flag
- ❌ Secret material in a ConfigMap or in Git
- ❌ `image: latest` or untagged image in prod
- ❌ `imagePullPolicy: Always` on a pinned tag (use `IfNotPresent`)
- ❌ Stateful data on a Deployment (use StatefulSet + `volumeClaimTemplates`)
- ❌ Public ingress without oauth2-proxy (unless explicitly public, e.g. a landing page)
- ❌ Missing probes on a production Deployment
- ❌ Missing resources on any container (unbounded CPU/memory)
- ❌ `prune: true` on `prd/cluster` (will delete cluster config on removal)
- ❌ Kustomization `path` that doesn't match a directory
- ❌ Two Kustomizations with the same name in the same namespace
- ❌ Duplicated oauth2-proxy manifests across namespaces with 1-line diffs (factor into a Kustomize base)