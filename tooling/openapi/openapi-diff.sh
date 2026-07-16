#!/usr/bin/env bash
#
# openapi-diff — the breaking-change gate (INFRA-007, BIS §12.2).
#
# Fails CI when a revision of the contract introduces a BREAKING change vs the
# base (§12.2): removing/renaming a field, changing a type or semantics,
# tightening validation on an existing field, changing a status code, adding a
# required request field, or changing pagination/sort defaults. Any of these ⇒
# the change belongs in /v2, not /v1.
#
# ADDITIVE changes pass: new endpoints, new optional request/response fields, and
# new `x-extensible-enum` values (clients decode non-strictly).
#
# Backed by `oasdiff` (single Go binary; installed by the CI contract job). This
# wrapper keeps the invocation — and the "what counts as breaking" contract — in
# one reviewed place.
#
# Usage:  openapi-diff.sh <base.yaml> <revision.yaml>
# Exit:   0 = no breaking changes · non-zero = breaking change(s) or tool missing
set -euo pipefail

BASE="${1:?usage: openapi-diff.sh <base.yaml> <revision.yaml>}"
REVISION="${2:?usage: openapi-diff.sh <base.yaml> <revision.yaml>}"

if ! command -v oasdiff >/dev/null 2>&1; then
  echo "openapi-diff: oasdiff not installed (CI installs it in the contract job)" >&2
  exit 127
fi

echo "openapi-diff: comparing base=$BASE revision=$REVISION"
# `breaking` reports only breaking changes; --fail-on ERR makes a breaking finding
# a non-zero exit. Additive/info-level differences do not fail the gate.
oasdiff breaking "$BASE" "$REVISION" --fail-on ERR
