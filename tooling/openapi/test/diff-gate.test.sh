#!/usr/bin/env bash
#
# diff-gate self-test (INFRA-007 Required Test: "diff-gate on a synthetic
# breaking change"). Proves openapi-diff.sh BLOCKS a breaking change and PASSES
# an additive one, using tiny self-contained specs (independent of the real
# contract's size). Requires `oasdiff` on PATH — the CI contract job installs it.
#
# Usage:  bash tooling/openapi/test/diff-gate.test.sh
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GATE="$SCRIPT_DIR/../openapi-diff.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

FAILURES=0
check() { # <description> <expected: pass|fail> <actual-exit-code>
  local desc="$1" expected="$2" rc="$3"
  if { [ "$expected" = pass ] && [ "$rc" -eq 0 ]; } ||
     { [ "$expected" = fail ] && [ "$rc" -ne 0 ]; }; then
    echo "  ✓ $desc (expected $expected, rc=$rc)"
  else
    echo "  ✗ $desc (expected $expected, rc=$rc)"; FAILURES=$((FAILURES + 1))
  fi
}

if ! command -v oasdiff >/dev/null 2>&1; then
  echo "diff-gate self-test: oasdiff not installed — cannot run (CI installs it)" >&2
  exit 127
fi

# --- base contract: one endpoint, response {id, title} ---
cat > "$TMP/base.yaml" <<'YAML'
openapi: 3.0.3
info: { title: t, version: 1.0.0 }
paths:
  /todos:
    get:
      responses:
        '200':
          description: ok
          content:
            application/json:
              schema:
                type: object
                required: [id, title]
                properties:
                  id: { type: string }
                  title: { type: string }
YAML

# --- additive: add a new OPTIONAL response field → must PASS ---
cat > "$TMP/additive.yaml" <<'YAML'
openapi: 3.0.3
info: { title: t, version: 1.1.0 }
paths:
  /todos:
    get:
      responses:
        '200':
          description: ok
          content:
            application/json:
              schema:
                type: object
                required: [id, title]
                properties:
                  id: { type: string }
                  title: { type: string }
                  note: { type: string }
YAML

# --- breaking: REMOVE a required response field → must FAIL ---
cat > "$TMP/breaking.yaml" <<'YAML'
openapi: 3.0.3
info: { title: t, version: 2.0.0 }
paths:
  /todos:
    get:
      responses:
        '200':
          description: ok
          content:
            application/json:
              schema:
                type: object
                required: [id]
                properties:
                  id: { type: string }
YAML

bash "$GATE" "$TMP/base.yaml" "$TMP/additive.yaml" >/dev/null 2>&1
check "additive change passes the gate" pass $?

bash "$GATE" "$TMP/base.yaml" "$TMP/breaking.yaml" >/dev/null 2>&1
check "breaking change fails the gate" fail $?

echo ""
if [ "$FAILURES" -eq 0 ]; then
  echo "diff-gate self-test: PASS"
  exit 0
fi
echo "diff-gate self-test: FAIL ($FAILURES)"
exit 1
