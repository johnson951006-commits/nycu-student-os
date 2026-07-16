#!/usr/bin/env bash
#
# corpus-lint — the custom-lint package (INFRA-003).
# Mechanically enforces the corpus boundaries that CI must block on:
#   import-matrix   FES §3   (client layer boundaries; domain is pure Dart)
#   token-literals  FES §6/§14 (no literal colors/durations outside app/theme)
#   no-print        FES §9    (no print()/debugPrint() in app/lib outside the logger)
#   no-raw-sql      BIS §7    ($queryRawUnsafe is banned in the backend)
#   arb-coverage    FES §7    (en covers the zh-TW template 100%)
#   error-registry  IRR §7    (thrown backend codes exist in the error registry)
#   flag-registry   FES §10   (client & server flag registries agree)
#
# Rules whose target artifacts do not exist yet are a NO-OP PASS (nothing to
# violate) — the rules activate automatically as later tasks add source.
#
# Usage:  corpus-lint.sh [rule ...]        # default: all rules
# Env:    LINT_ROOT=<dir>                   # scan root (default: repo root)
#
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LINT_ROOT="${LINT_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

VIOLATIONS=0
violation() { echo "  ✗ [$1] $2"; VIOLATIONS=$((VIOLATIONS + 1)); }

# Dart files, excluding generated (*.g.dart/*.freezed.dart) and build output.
_dart_files() {
  find "$1" -type f -name '*.dart' \
    ! -name '*.g.dart' ! -name '*.freezed.dart' \
    ! -path '*/.dart_tool/*' ! -path '*/build/*' 2>/dev/null
}
# Strip // line comments (best-effort) so comments never trip content rules.
_code_lines() { sed -E 's://.*$::' "$1"; }

# ---------------------------------------------------------------- import-matrix
rule_import_matrix() {
  local base="$LINT_ROOT/app/lib"
  [ -d "$base" ] || return 0
  local f rel feat imp g
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    rel="${f#"$base"/}"
    # (a) domain purity: no Flutter/drift/dio/riverpod, no core|data|features imports
    if [[ "$rel" == domain/* ]]; then
      while IFS= read -r imp; do
        case "$imp" in
          *"package:flutter/"*|*"package:flutter_"*|*"package:riverpod"*|\
          *"package:drift"*|*"package:dio"*)
            violation import-matrix "$rel imports non-pure-Dart ($imp) — domain must be pure Dart (FES §3)";;
        esac
        if echo "$imp" | grep -Eq "package:[a-z0-9_]+/(core|data|features)/"; then
          violation import-matrix "$rel imports an upper layer ($imp) — domain imports nothing above it (FES §3)"
        fi
      done < <(_code_lines "$f" | grep -E "^\s*import " || true)
    fi
    # (b) no cross-feature imports
    if [[ "$rel" == features/*/* ]]; then
      feat="${rel#features/}"; feat="${feat%%/*}"
      while IFS= read -r imp; do
        g="$(echo "$imp" | sed -nE "s@.*package:[a-z0-9_]+/features/([a-z0-9_]+)/.*@\1@p")"
        if [ -n "$g" ] && [ "$g" != "$feat" ]; then
          violation import-matrix "features/$feat imports features/$g ($imp) — cross-feature import forbidden (FES §3)"
        fi
      done < <(_code_lines "$f" | grep -E "^\s*import " || true)
    fi
    # (c) presentation must not touch dio/drift directly
    if [[ "$rel" == features/*/presentation/* ]]; then
      while IFS= read -r imp; do
        case "$imp" in
          *"package:dio"*|*"package:drift"*)
            violation import-matrix "$rel imports $imp — presentation may not use the network/DB directly (FA §4.1)";;
        esac
      done < <(_code_lines "$f" | grep -E "^\s*import " || true)
    fi
  done < <(_dart_files "$base")
}

# --------------------------------------------------------------- token-literals
rule_token_literals() {
  local base="$LINT_ROOT/app/lib"
  [ -d "$base" ] || return 0
  local f rel hit
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    rel="${f#"$base"/}"
    [[ "$rel" == app/theme/* ]] && continue   # the token system itself is exempt
    # Require a non-letter boundary so our own token accessors (e.g. NycuColors.of,
    # NycuColor tokens) are never flagged — only Flutter's Color(0x…)/Colors.<name>/Duration(…).
    hit="$(_code_lines "$f" | grep -nE "(^|[^A-Za-z])(Color\(0x|Colors\.[a-zA-Z]|Duration\()" || true)"
    if [ -n "$hit" ]; then
      violation token-literals "$rel uses a literal color/duration — use tokens only (FES §6/§14): $(echo "$hit" | head -1 | cut -c1-80)"
    fi
  done < <(_dart_files "$base")
}

# -------------------------------------------------------------------- no-print
rule_no_print() {
  local base="$LINT_ROOT/app/lib"
  [ -d "$base" ] || return 0
  local f rel
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    rel="${f#"$base"/}"
    [[ "$rel" == core/logging/* ]] && continue   # the logger is the one allowed site
    if _code_lines "$f" | grep -Eq "(^|[^.\w])(print|debugPrint)[[:space:]]*\("; then
      violation no-print "$rel calls print()/debugPrint() — use the app logger (FES §9)"
    fi
  done < <(_dart_files "$base")
}

# ---------------------------------------------------------------- no-raw-sql
rule_no_raw_sql() {
  local base="$LINT_ROOT/backend/src"
  [ -d "$base" ] || return 0
  local f
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    if _code_lines "$f" | grep -q '\$queryRawUnsafe'; then
      violation no-raw-sql "${f#"$LINT_ROOT"/} uses \$queryRawUnsafe — banned; use parameterized queries (BIS §7)"
    fi
  done < <(find "$base" -type f -name '*.ts' ! -path '*/node_modules/*' ! -name '*.spec.ts' 2>/dev/null)
}

# --------------------------------------------------------------- arb-coverage
rule_arb_coverage() {
  local dir
  dir="$(find "$LINT_ROOT/app" -type d -name l10n 2>/dev/null | head -1)"
  [ -n "$dir" ] || return 0
  local tmpl en
  tmpl="$(find "$dir" -maxdepth 1 -type f -name '*zh*.arb' | head -1)"
  en="$(find "$dir" -maxdepth 1 -type f -name '*_en.arb' -o -name 'app_en.arb' 2>/dev/null | head -1)"
  { [ -n "$tmpl" ] && [ -n "$en" ]; } || return 0
  local keys k
  keys="$(grep -oE '"[a-zA-Z0-9_]+"[[:space:]]*:' "$tmpl" | grep -v '^"@' | tr -d '": ' )"
  while IFS= read -r k; do
    [ -z "$k" ] && continue
    grep -qE "\"$k\"[[:space:]]*:" "$en" || violation arb-coverage "en ARB missing key '$k' present in zh-TW template (FES §7)"
  done <<< "$keys"
}

# ------------------------------------------------------------- error-registry
rule_error_registry() {
  local reg
  reg="$(find "$LINT_ROOT/backend/src" -type f -path '*errors*' \( -name 'codes.ts' -o -name 'error-codes.ts' \) 2>/dev/null | head -1)"
  [ -n "$reg" ] || return 0
  local f code
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    while IFS= read -r code; do
      [ -z "$code" ] && continue
      grep -q "$code" "$reg" || violation error-registry "${f#"$LINT_ROOT"/} throws unregistered code '$code' (IRR §7)"
    done < <(_code_lines "$f" | grep -oE "AppException\([[:space:]]*['\"][A-Z0-9_-]+['\"]" | grep -oE "['\"][A-Z0-9_-]+['\"]" | tr -d "\"'" || true)
  done < <(find "$LINT_ROOT/backend/src" -type f -name '*.ts' ! -name '*.spec.ts' ! -path '*errors*' 2>/dev/null)
}

# -------------------------------------------------------------- flag-registry
rule_flag_registry() {
  local sreg creg
  sreg="$(find "$LINT_ROOT/backend/src" -type f -path '*flags*' -name 'registry.ts' 2>/dev/null | head -1)"
  creg="$(find "$LINT_ROOT/app/lib" -type f -path '*flags*' -name 'registry.dart' 2>/dev/null | head -1)"
  { [ -n "$sreg" ] && [ -n "$creg" ]; } || return 0
  local s c k
  s="$(grep -oE "'(flag:)?[a-z0-9_]+'" "$sreg" | tr -d "'" | sort -u)"
  c="$(grep -oE "'(flag:)?[a-z0-9_]+'" "$creg" | tr -d "'" | sort -u)"
  while IFS= read -r k; do
    [ -z "$k" ] && continue
    grep -qx "$k" <<< "$c" || violation flag-registry "flag '$k' in server registry missing from client registry (FES §10)"
  done <<< "$s"
  while IFS= read -r k; do
    [ -z "$k" ] && continue
    grep -qx "$k" <<< "$s" || violation flag-registry "flag '$k' in client registry missing from server registry (FES §10)"
  done <<< "$c"
}

ALL_RULES=(import_matrix token_literals no_print no_raw_sql arb_coverage error_registry flag_registry)

main() {
  local rules=("$@")
  [ ${#rules[@]} -eq 0 ] && rules=("${ALL_RULES[@]}")
  echo "corpus-lint: scanning ${LINT_ROOT}"
  for r in "${rules[@]}"; do
    "rule_${r//-/_}"
  done
  if [ "$VIOLATIONS" -eq 0 ]; then
    echo "corpus-lint: PASS (0 violations)"
    return 0
  fi
  echo "corpus-lint: FAIL ($VIOLATIONS violation(s))"
  return 1
}

main "$@"
