# Kubernetes Manifest Checklist

Concrete checks per resource kind. Apply each to every changed manifest.

## Deployment
- [ ] `apiVersion: apps/v1` (not `extensions/v1beta1` or `apps/v1beta1`)
- [ ] `selector.matchLabels` matches `template.metadata.labels`
- [ ] Every container has `resources.requests` and `resources.limits` (cpu + memory)
- [ ] Every container has `livenessProbe` and `readinessProbe`; stateful/slow-start containers have `startupProbe`
- [ ] `image` tag is pinned (not `latest`, not empty) — prefer full SHA or semver
- [ ] `imagePullPolicy: IfNotPresent` for pinned tags (not `Always` — wasteful)
- [ ] `strategy`: `RollingUpdate` for stateless, `Recreate` for single-replica stateful; **stateful data → use StatefulSet instead**
- [ ] `revisionHistoryLimit` set (default 10 is fine; explicit is better)
- [ ] Multi-replica workloads have a `PodDisruptionBudget`
- [ ] `securityContext.runAsUser` + `runAsGroup` set (non-zero unless the image requires it)
- [ ] `securityContext.readOnlyRootFilesystem: true` where the image allows it
- [ ] No `privileged: true`, no `hostPath`, no `hostNetwork`, no `hostPID`
- [ ] `tolerations` / `affinity` / `topologySpreadConstraints` present for HA workloads
- [ ] `env` secrets via `secretKeyRef` (from ExternalSecrets), never inline
- [ ] Volumes: stateful data on a PVC; config on a ConfigMap; secrets on a Secret (from ExternalSecret)

## StatefulSet (preferred for stateful workloads)
- [ ] `serviceName` references an existing headless Service
- [ ] `volumeClaimTemplates` for each replica's persistent storage (not a shared PVC)
- [ ] `podManagementPolicy: OrderedReady` (default) or `Parallel` (for independent replicas)
- [ ] `updateStrategy: RollingUpdate` with `partition` if canary is needed
- [ ] All Deployment checks above also apply

## Service
- [ ] `selector` matches pod labels (not Deployment labels — direct pod labels)
- [ ] `port.targetPort` matches a named container port where possible (not a raw number)
- [ ] `type`: `ClusterIP` by default; `LoadBalancer`/`NodePort` only with justification (prefer Cloudflare Tunnel + Ingress)
- [ ] Headless Service (`clusterIP: None`) for StatefulSets

## Ingress
- [ ] `apiVersion: networking.k8s.io/v1`
- [ ] `pathType: Prefix` (or `Exact` with justification)
- [ ] Backend service name + port match an existing Service
- [ ] Host is a real DNS name (not an IP)
- [ ] Public-facing ingresses route through `oauth2-proxy` (backend = oauth2-proxy-service:4180) OR use Traefik ForwardAuth middleware
- [ ] TLS: `traefik.ingress.kubernetes.io/router.entrypoints: web,websecure` + `redirect-scheme: https` annotation
- [ ] No raw `tls.secretName` unless you manage certs manually (Traefik + Let's Encrypt is the default)

## NetworkPolicy
- [ ] `policyTypes` includes `Ingress` and/or `Egress` as intended
- [ ] `podSelector` selects the right pods
- [ ] `ingress.from` restricts to specific pods/namespaces (not `from: {}` = allow all)
- [ ] `egress.to` restricts to specific pods/namespaces/ports (not `to: {}` = allow all)
- [ ] Every exposed workload has a NetworkPolicy limiting ingress to oauth2-proxy

## ExternalSecret
- [ ] `apiVersion: external-secrets.io/v1`
- [ ] `secretStoreRef.name` = `openbao-backend`, `kind: ClusterSecretStore`
- [ ] `refreshInterval` sensible (60s is fine; don't use 1s)
- [ ] `target.creationPolicy: Owner`
- [ ] `dataFrom.extract.key` matches an OpenBao path (e.g. `opencode/opencode`)
- [ ] No secret material in the manifest (only the path reference)

## ConfigMap
- [ ] No secret material (API keys, passwords, tokens) — use ExternalSecret instead
- [ ] Embedded config files (e.g. `opencode.json: |`) are valid JSON/YAML
- [ ] Environment variables are strings (quoted) — `"true"` not `true`

## PersistentVolumeClaim
- [ ] `storageClassName` matches a real StorageClass (or empty for default)
- [ ] `accessModes`: `ReadWriteOnce` for single-replica, `ReadWriteMany` only with NFS/shared storage
- [ ] `resources.requests.storage` sized appropriately (not unbounded)
- [ ] Stateful workloads use `volumeClaimTemplates` (StatefulSet), not a shared PVC

## PodDisruptionBudget
- [ ] `minAvailable` OR `maxUnavailable` set (not both)
- [ ] `selector` matches the target Deployment/StatefulSet pods
- [ ] Doesn't block node drains (if `minAvailable` = replicas, drains are blocked)

## Generic (all resources)
- [ ] `metadata.name` is DNS-1035 compliant (lowercase, alphanumeric + hyphen, ≤ 63 chars)
- [ ] `metadata.namespace` matches the directory namespace
- [ ] Labels: `app` + `app.kubernetes.io/part-of` where the repo convention uses them
- [ ] No `kubernetes.io/`-prefixed annotations unless documented