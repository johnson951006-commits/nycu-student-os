#!/usr/bin/env bash
#
# INFRA-002 Compose smoke test (Required Test: "Compose smoke — all services healthy").
#
# Brings up the local infrastructure topology and asserts every started service
# reaches "healthy", then tears it down. Infra-only by default; pass --app to also
# start the application profile once its images exist (INFRA-004/008/010).
#
# Requires: Docker + Docker Compose v2 (see docs/toolchain.md).
# Usage:    ./scripts/compose-smoke.sh [--app]
#
set -euo pipefail

cd "$(dirname "$0")/.."
COMPOSE_FILE="docker/docker-compose.yml"
ENV_FILE="docker/.env"

# Local, non-secret env (created from the committed example if absent).
[ -f "$ENV_FILE" ] || cp docker/.env.example "$ENV_FILE"

PROFILE_ARGS=()
[ "${1:-}" = "--app" ] && PROFILE_ARGS=(--profile app)

dc() { docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" "${PROFILE_ARGS[@]}" "$@"; }

cleanup() { dc down -v --remove-orphans >/dev/null 2>&1 || true; }
trap cleanup EXIT

echo "==> Validating compose configuration"
dc config -q

echo "==> Starting topology and waiting for health"
# --wait blocks until healthy (or the per-service healthcheck retries are exhausted)
# and returns non-zero if any service ends unhealthy.
dc up -d --wait --wait-timeout 180

echo "==> Verifying every service is healthy/running"
fail=0
while read -r name; do
  [ -z "$name" ] && continue
  health="$(dc ps --format '{{.Health}}' "$name" 2>/dev/null || echo '')"
  state="$(dc ps --format '{{.State}}' "$name" 2>/dev/null || echo '')"
  if [ "$health" = "healthy" ] || { [ -z "$health" ] && [ "$state" = "running" ]; }; then
    echo "   OK   $name (${health:-$state})"
  else
    echo "   FAIL $name (health=${health:-none} state=${state:-none})"
    fail=1
  fi
done < <(dc ps --services)

if [ "$fail" -ne 0 ]; then
  echo "==> SMOKE FAILED"; dc logs --tail=50 || true; exit 1
fi
echo "==> SMOKE PASSED — all services healthy"
