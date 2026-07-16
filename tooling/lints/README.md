# corpus-lint (custom-lint package — INFRA-003)

Mechanical enforcement of the corpus boundaries that CI blocks on (QS §14 lint gate;
FES §3/§6/§7/§9/§10; BIS §7). Pure Bash so it runs identically in CI and locally,
independent of the app/backend toolchains.

## Rules

| Rule | Enforces | Corpus |
|---|---|---|
| `import_matrix` | client layer boundaries: `domain/` is pure Dart & imports nothing above it; no cross-feature imports; presentation may not import `dio`/`drift` | FES §3, FA §4.1 |
| `token_literals` | no literal `Color(0x…)` / `Colors.<name>` / `Duration(…)` outside `app/lib/app/theme/` | FES §6, §14 |
| `no_print` | no `print()`/`debugPrint()` in `app/lib` outside `core/logging/` | FES §9 |
| `no_raw_sql` | `$queryRawUnsafe` is banned in the backend | BIS §7 (A03) |
| `arb_coverage` | `en` ARB covers every key in the `zh-TW` template | FES §7 |
| `error_registry` | every thrown backend `AppException('CODE')` exists in the error registry | IRR §7 |
| `flag_registry` | client & server flag registries contain the same flags | FES §10 |

Rules whose target files do not exist yet are a **no-op pass** — they activate
automatically as later tasks add source (backend → INFRA-004, client → INFRA-008,
registries → INFRA-006/010).

## Usage

```bash
bash tooling/lints/corpus-lint.sh            # all rules on the repo tree
bash tooling/lints/corpus-lint.sh no_print   # a single rule
LINT_ROOT=/path bash tooling/lints/corpus-lint.sh   # scan an alternate root
```

Exit code is non-zero on any violation (CI-blocking).

## Tests

```bash
bash tooling/lints/test/lint.test.sh
```

Each rule is asserted to **fail on a violating fixture** and **pass on a clean
fixture** (fixtures are built inline in temp dirs). This suite runs in the PR lane's
`custom-lints` job, so the lints themselves are regression-protected.

## Wiring

Run by `.github/workflows/pr.yml` → `custom-lints` job (a required status check in
`.github/rulesets/main.json`). The token/ARB/flag audits also run in the release lane.
