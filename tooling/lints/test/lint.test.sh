#!/usr/bin/env bash
#
# Unit tests for corpus-lint (INFRA-003 Required Test): every rule must FAIL on a
# violating fixture and PASS on a clean fixture. Fixtures are built inline in temp
# dirs so the suite is hermetic and adds no committed fixture files.
#
set -uo pipefail

LINT="$(cd "$(dirname "$0")/.." && pwd)/corpus-lint.sh"
TESTS=0; FAILS=0

# run the lint for one rule against a fixture root; echo its exit code
_run() { LINT_ROOT="$1" bash "$LINT" "$2" >/dev/null 2>&1; echo $?; }

expect() { # <desc> <rule> <root> <expect: pass|fail>
  TESTS=$((TESTS+1))
  local code; code="$(_run "$3" "$2")"
  if { [ "$4" = pass ] && [ "$code" -eq 0 ]; } || { [ "$4" = fail ] && [ "$code" -ne 0 ]; }; then
    echo "  PASS: $1"
  else
    echo "  FAIL: $1 (rule=$2 expected=$4 exit=$code)"; FAILS=$((FAILS+1))
  fi
}

mk() { mkdir -p "$(dirname "$1")"; printf '%s\n' "$2" > "$1"; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# ---------------- no-print ----------------
R="$TMP/np_fail"; mk "$R/app/lib/features/x/presentation/w.dart" "void f(){ print('debug'); }"
expect "no-print blocks print() in presentation" no_print "$R" fail
R="$TMP/np_pass"; mk "$R/app/lib/features/x/presentation/w.dart" "import 'package:x/core/logging/logger.dart'; void f(){ log.info('hi'); }"
mk "$R/app/lib/core/logging/logger.dart" "void logIt(){ print('allowed in logger'); }"
expect "no-print allows logger + clean presentation" no_print "$R" pass

# ---------------- no-raw-sql ----------------
R="$TMP/sql_fail"; mk "$R/backend/src/x.ts" "await this.prisma.\$queryRawUnsafe('SELECT 1');"
expect "no-raw-sql blocks \$queryRawUnsafe" no_raw_sql "$R" fail
R="$TMP/sql_pass"; mk "$R/backend/src/x.ts" "await this.prisma.\$queryRaw\`SELECT 1\`;"
expect "no-raw-sql allows tagged \$queryRaw" no_raw_sql "$R" pass

# ---------------- token-literals ----------------
R="$TMP/tok_fail"; mk "$R/app/lib/features/x/presentation/w.dart" "final c = Color(0xFF00FF00);"
expect "token-literals blocks literal Color" token_literals "$R" fail
R="$TMP/tok_fail2"; mk "$R/app/lib/features/x/presentation/w.dart" "const d = Duration(milliseconds: 200);"
expect "token-literals blocks literal Duration" token_literals "$R" fail
R="$TMP/tok_pass"; mk "$R/app/lib/app/theme/tokens.dart" "final primary = Color(0xFF2472E8);"
mk "$R/app/lib/features/x/presentation/w.dart" "final c = NycuColors.of(context).urgencyHigh;"
expect "token-literals exempts theme, allows token use" token_literals "$R" pass

# ---------------- import-matrix ----------------
R="$TMP/im_dom_fail"; mk "$R/app/lib/domain/entities/e.dart" "import 'package:flutter/material.dart';"
expect "import-matrix blocks Flutter import in domain" import_matrix "$R" fail
R="$TMP/im_dom_fail2"; mk "$R/app/lib/domain/entities/e.dart" "import 'package:nycu_student_os/core/db/db.dart';"
expect "import-matrix blocks upper-layer import in domain" import_matrix "$R" fail
R="$TMP/im_cross_fail"; mk "$R/app/lib/features/a/presentation/p.dart" "import 'package:nycu_student_os/features/b/x.dart';"
expect "import-matrix blocks cross-feature import" import_matrix "$R" fail
R="$TMP/im_pres_fail"; mk "$R/app/lib/features/a/presentation/p.dart" "import 'package:dio/dio.dart';"
expect "import-matrix blocks dio in presentation" import_matrix "$R" fail
R="$TMP/im_pass"; mk "$R/app/lib/domain/entities/e.dart" "import 'package:meta/meta.dart';"
mk "$R/app/lib/features/a/presentation/p.dart" "import 'package:nycu_student_os/features/a/application/c.dart';"
expect "import-matrix passes pure domain + intra-feature" import_matrix "$R" pass

# ---------------- arb-coverage ----------------
R="$TMP/arb_fail"; mk "$R/app/lib/core/l10n/app_zh-TW.arb" '{ "hello": "哈囉", "bye": "掰" }'
mk "$R/app/lib/core/l10n/app_en.arb" '{ "hello": "Hello" }'
expect "arb-coverage blocks missing en key" arb_coverage "$R" fail
R="$TMP/arb_pass"; mk "$R/app/lib/core/l10n/app_zh-TW.arb" '{ "hello": "哈囉" }'
mk "$R/app/lib/core/l10n/app_en.arb" '{ "hello": "Hello" }'
expect "arb-coverage passes full parity" arb_coverage "$R" pass

# ---------------- error-registry ----------------
R="$TMP/err_fail"; mk "$R/backend/src/shared/errors/codes.ts" "export const CODES = ['E-COOKIE-INVALID'];"
mk "$R/backend/src/modules/x/x.service.ts" "throw new AppException('E-NOPE', 400);"
expect "error-registry blocks unregistered thrown code" error_registry "$R" fail
R="$TMP/err_pass"; mk "$R/backend/src/shared/errors/codes.ts" "export const CODES = ['E-COOKIE-INVALID'];"
mk "$R/backend/src/modules/x/x.service.ts" "throw new AppException('E-COOKIE-INVALID', 401);"
expect "error-registry passes registered code" error_registry "$R" pass

# ---------------- flag-registry ----------------
R="$TMP/flag_fail"; mk "$R/backend/src/shared/flags/registry.ts" "export const FLAGS = ['grades_sync','notif_digest_batching'];"
mk "$R/app/lib/core/flags/registry.dart" "const flags = ['grades_sync'];"
expect "flag-registry blocks client/server mismatch" flag_registry "$R" fail
R="$TMP/flag_pass"; mk "$R/backend/src/shared/flags/registry.ts" "export const FLAGS = ['grades_sync'];"
mk "$R/app/lib/core/flags/registry.dart" "const flags = ['grades_sync'];"
expect "flag-registry passes matched registries" flag_registry "$R" pass

# ---------------- no-op pass when targets absent ----------------
R="$TMP/empty"; mkdir -p "$R"
expect "all rules no-op PASS on empty tree" "" "$R" pass

echo
echo "lint.test: $((TESTS-FAILS))/$TESTS passed"
[ "$FAILS" -eq 0 ] || exit 1
