# Kubernetes — Blog/CMS Platform Deployment Reference

> **Topic**: Real project K8s deployment (minikube)
> **Source**: Day 15 · ProOps2026 — loaded by the agent before any K8s task on this project

---

## 1. Services

| Service | K8s Service name | Namespace | Port | Type | Image |
|---|---|---|---|---|---|
| postgres | `postgres` | blogcms | 5432 | ClusterIP | `postgres:16-alpine` (public) |
| user-service | `user-service` | blogcms | 3002 | ClusterIP | `user-service:local` (built) |
| content-service | `content-service` | blogcms | 3001 | ClusterIP | `content-service:local` (built) |
| gateway | `gateway` | blogcms | 3000 | ClusterIP + Ingress | `gateway:local` (built) |
| frontend | `frontend` | blogcms | 5173 | ClusterIP + Ingress | `frontend:local` (built, Vite dev server) |

## 2. ConfigMap vs Secret rule

If leaking the value to a CI log or PR diff would require an incident review, it goes in a Secret (`kubectl create secret`, never plaintext YAML); otherwise ConfigMap.

## 3. In-cluster DNS pattern

`<service-name>` alone resolves within the `blogcms` namespace (moved out of `default` 2026-10-17) (e.g. `postgres`, `user-service:3002`) — no `.svc.cluster.local` suffix needed. Every Service name intentionally matches the original Docker Compose service name, so no application code needed to change.

## 4. Apply order (dependency chain)

Since 2026-10-17 one command applies everything into `blogcms`: `k8s/create-secrets.sh && kubectl apply -k k8s/base` (EKS: `kubectl apply -k k8s/overlays/eks`). Backends that start before postgres is Ready crash-loop briefly and recover; the chain below is still the runtime dependency order.

```
postgres  →  user-service, content-service  →  gateway  →  frontend  →  Ingress
```
`postgres` must be `Running` before any backend service (DB connection at startup). `gateway` must be `Running` before `frontend` is useful (though frontend itself doesn't hard-depend on it to start). Ingress can be applied any time after `frontend`+`gateway` Services exist.

## 5. Custom image build (this project, not public images)

```bash
minikube image build -t <service>:local <path-to-service-dir>
```
Deployment must set `imagePullPolicy: Never`. Re-run this + `kubectl rollout restart deployment <name>` any time source code changes — same tag does NOT auto-refresh running Pods.

## 6. Ingress hosts

| Host | Routes to | Notes |
|---|---|---|
| `blogcms.local` | `frontend:5173` | Requires `minikube tunnel` running + curl with `Host:` header (Windows/docker driver — `minikube ip` unreachable directly) |
| `api.blogcms.local` | `gateway:3000` | Host-based, not path-based — gateway routes (`/auth`, `/posts`, etc.) have no `/api` prefix, so path-based `/api` routing would never match |

## 7. Failures hit today + fixes

| Failure | Root cause | Fix |
|---|---|---|
| `user-service` Pod briefly `Error` on very first cold start (2 replicas) | TOCTOU race: both replicas' admin-bootstrap check-then-insert raced on the empty `users` table | Self-resolved on restart (idempotent per app's own "skipped" path) — only happens once, on a genuinely empty table with replicas>1. Not fixed in code; flagged as a gap vs IRD-001's original seed-script intent. |
| HPA-style CPU tuning n/a here, but similar lesson: don't assume | — | (carried over from Day 14, not re-hit here) |
| `/auth/register` through gateway returned `500`, `user-service` logs: `Expected property name or '}' in JSON at position 1` | **Not a real bug** — PowerShell/curl.exe inline `\"` escaping corrupted the JSON body before it left the client | Write payload to a file, use `curl.exe -d "@body.json"` — eliminates all shell-escaping ambiguity. Always suspect the shell before the service when a JSON parse error looks "impossible" given correct-looking code. |
| Vite dev server blocked Ingress requests: `Blocked request. This host ("blogcms.local") is not allowed.` | Vite's DNS-rebinding protection rejects unrecognized `Host` headers by default | Add `server.allowedHosts: ['blogcms.local']` to `vite.config.js`, rebuild image, `kubectl rollout restart` |
| Ingress `/api` path-based routing (as originally planned) would never have matched | `gateway` routes (`/auth/register`, `/posts`, ...) have no `/api` prefix in the actual source code | Switched to host-based routing (`api.blogcms.local`) instead of path-based — always verify actual route prefixes in source before designing Ingress rules, don't assume a convention |

## 8. End-to-end verification (proof, not just "Pod Running")

```powershell
curl.exe -X POST -H "Host: api.blogcms.local" -H "Content-Type: application/json" -d "@body.json" http://127.0.0.1/auth/register
```
Confirmed full chain: Ingress → Service `gateway` → proxy → Service `user-service` → Postgres insert → response relayed back correctly (both 201 success and 409 conflict cases verified).
