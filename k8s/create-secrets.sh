#!/usr/bin/env bash
# Creates the 4 blogcms Secrets (IRD-007: created imperatively, never committed).
#
# Usage:  k8s/create-secrets.sh [--dry-run]
# Values: taken from env if set (POSTGRES_PASSWORD, JWT_SECRET, INITIAL_ADMIN_PASSWORD),
#         otherwise reused from the cluster, otherwise randomly generated.
#
# Idempotent: an existing Secret is never rotated. Its values are reused so that
#   - DATABASE_URL always matches the password postgres was initialised with, and
#   - gateway + user-service always share one JWT_SECRET (IRD-007 AC-7).
set -euo pipefail

NAMESPACE="${NAMESPACE:-blogcms}"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

command -v kubectl >/dev/null || { echo "ERROR: kubectl not found" >&2; exit 1; }
kubectl cluster-info >/dev/null 2>&1 || { echo "ERROR: cluster unreachable (context: $(kubectl config current-context))" >&2; exit 1; }

random() { head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n'; }

# Prints a decoded key from an existing Secret, or nothing if the Secret/key is absent.
existing() {
  local value
  value=$(kubectl get secret "$1" -n "$NAMESPACE" -o "jsonpath={.data.$2}" 2>/dev/null || true)
  [[ -n "$value" ]] && printf '%s' "$value" | base64 -d
  return 0
}

secret_exists() { kubectl get secret "$1" -n "$NAMESPACE" >/dev/null 2>&1; }

create() {
  local name="$1"; shift
  if secret_exists "$name"; then
    echo "skip    secret/$name (exists)"
    return 0
  fi
  if $DRY_RUN; then
    echo "create  secret/$name (dry-run, keys: ${*%%=*})"
    return 0
  fi
  local args=()
  for kv in "$@"; do args+=(--from-literal="$kv"); done
  kubectl create secret generic "$name" -n "$NAMESPACE" "${args[@]}" >/dev/null
  echo "create  secret/$name"
}

if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  if $DRY_RUN; then echo "create  namespace/$NAMESPACE (dry-run)"
  else kubectl apply -f "$(dirname "$0")/base/namespace.yaml" >/dev/null; echo "create  namespace/$NAMESPACE"; fi
fi

PG_PASSWORD="${POSTGRES_PASSWORD:-$(existing postgres-credentials POSTGRES_PASSWORD)}"
PG_PASSWORD="${PG_PASSWORD:-$(random)}"

JWT="${JWT_SECRET:-$(existing gateway-credentials JWT_SECRET)}"
JWT="${JWT:-$(existing user-service-credentials JWT_SECRET)}"
JWT="${JWT:-$(random)}"

ADMIN_PASSWORD="${INITIAL_ADMIN_PASSWORD:-$(existing user-service-credentials INITIAL_ADMIN_PASSWORD)}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-$(random)}"

create postgres-credentials        "POSTGRES_PASSWORD=$PG_PASSWORD"
create user-service-credentials    "DATABASE_URL=postgres://postgres:$PG_PASSWORD@postgres:5432/user_db" \
                                   "JWT_SECRET=$JWT" \
                                   "INITIAL_ADMIN_PASSWORD=$ADMIN_PASSWORD"
create content-service-credentials "DATABASE_URL=postgres://postgres:$PG_PASSWORD@postgres:5432/content_db"
create gateway-credentials         "JWT_SECRET=$JWT"

echo "Done. Admin login: admin@blogcms.local — password: kubectl get secret user-service-credentials -n $NAMESPACE -o jsonpath='{.data.INITIAL_ADMIN_PASSWORD}' | base64 -d"
