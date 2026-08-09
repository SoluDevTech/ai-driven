---
name: iac-review
description: Static review of Kubernetes/Flux manifests in a GitOps repo (K3s + Flux CD). Scores manifests on 10 across correctness, security, reliability, consistency, GitOps hygiene, and maintainability. Use when reviewing PRs that change deployments, services, ingresses, network policies, external secrets, Flux Kustomizations, Helm values, or any K8s manifest — before it reaches the cluster. Complements popeyescan (runtime audit).
---

# IaC Review — Kubernetes / Flux Manifests

Perform a static, pre-merge review of Kubernetes and Flux manifests in a GitOps repo. You catch issues before they reach the cluster; `popeyescan` catches what slipped through at runtime.

## Use this skill when
- Reviewing a PR that changes `*.yaml` manifests, Flux Kustomizations, Helm values, or install scripts
- Auditing an existing namespace for manifest-level issues (probes, resources, security, consistency)
- You need a structured /10 score before merging infra changes

## Do not use this skill when
- The task is auditing a **running** cluster → use `popeyescan`
- The task is app code (Python/React/NestJS) → use `code-reviewer`
- The task is implementing new manifests → use the `k3s-devops` agent

## Review dimensions (6)
1. **Correctness** — valid YAML, valid API versions (no deprecated `extensions/v1beta1`), Flux Kustomization `path` matches actual directory, resource names match selectors, ports match services
2. **Security** — secrets via ExternalSecrets (never in Git), NetworkPolicies on exposed workloads, oauth2-proxy on public ingresses, no privileged containers, `runAsUser`/`runAsGroup` set, `readOnlyRootFilesystem` where possible, no `hostPath`/`hostNetwork`, image tags pinned (not `latest`)
3. **Reliability** — probes (startup + liveness + readiness) on every Deployment, resources (requests + limits) on every container, `revisionHistoryLimit`, `PodDisruptionBudget` for multi-replica, `strategy` appropriate (RollingUpdate for stateless, Recreate/StatefulSet for stateful)
4. **Consistency** — same patterns across namespaces (probes everywhere or nowhere; resources everywhere or nowhere; labeling conventions like `app.kubernetes.io/part-of`), same probe shape, same image pull policy, same ingress annotation set
5. **GitOps hygiene** — Kustomization `path` matches directory, `prune: true` for app namespaces, `interval`/`timeout` sensible, `sourceRef` correct, dependency order respected (cluster infra before secrets before apps), `targetNamespace` set
6. **Maintainability** — no duplicated manifests (shared via Kustomize base/overlay when 3+ namespaces repeat the same shape), values externalized to `config/<env>/<service>/values.yaml`, no inline secrets, comments explain non-obvious choices

## Workflow
1. **Scope** — run `git diff --name-only` (or list the changed `.yaml`/`.yml`/`.sh` files). Read each changed file.
2. **Classify** — note the resource kind(s) and whether the file is a Flux CR (GitRepository, Kustomization, HelmRelease) or a raw K8s manifest.
3. **Kubernetes checks** — load `references/kubernetes-checklist.md` and apply per resource kind (Deployment, StatefulSet, Service, Ingress, NetworkPolicy, ExternalSecret, ConfigMap, PVC).
4. **Flux checks** — load `references/flux-checklist.md` and apply to GitRepository/Kustomization/HelmRelease.
5. **Score** — load `references/flux-rubric.md` and score each dimension 1–10, then decide the overall /10 holistically (no fixed weights — you weight by context: a security-critical ingress weights security higher; a reliability-focused change weights probes/resources higher).
6. **Output** — use the same Score table format as `code-reviewer` (dimension | score | one-line justification), then Critical/Improvements/Minor/Positive sections.

## Output Format

### Score

| Dimension | Score | One-line justification |
|---|---|---|
| Correctness | x/10 | … |
| Security | x/10 | … |
| Reliability | x/10 | … |
| Consistency | x/10 | … |
| GitOps hygiene | x/10 | … |
| Maintainability | x/10 | … |

**Overall: X/10 — <verdict>** (one sentence)

Verdict: `approve` / `approve with minor comments` / `request changes` / `block`. A 0–3 in Security or Correctness usually caps the overall at 5.

### Critical Issues 🔴
### Improvements 🟡
### Minor Suggestions 🟢
### Positive Highlights ✅

## Stack context (flux repo)
The flux repo uses: K3s + Flux CD, Traefik ingress, ExternalSecrets → OpenBao, oauth2-proxy + Logto auth, OpenObserve observability, MinIO storage, Cloudflare tunnels. Manifests live under `prd/<namespace>/<service>/`; Flux config under `config/<env>/`. See `references/flux-checklist.md` for the repo-specific conventions.

## References
- `references/flux-rubric.md` — per-dimension scoring descriptors (0/5/8/10 anchors)
- `references/kubernetes-checklist.md` — concrete checks per K8s resource kind
- `references/flux-checklist.md` — Flux CR checks + repo-specific conventions