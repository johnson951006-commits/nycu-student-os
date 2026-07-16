# `tooling/openapi` — contract gates (INFRA-007)

Enforces the OpenAPI freeze discipline (BIS §12.2). Wired into the `contract` job
of `.github/workflows/pr.yml`.

| File | Role |
|---|---|
| `openapi-diff.sh` | Breaking-change gate. `openapi-diff.sh <base.yaml> <revision.yaml>` fails (non-zero) when the revision introduces a breaking change vs the base (field removal/rename, type/semantics change, tightened validation, status-code change, new required request field, changed pagination/sort default). Additive changes pass. Backed by `oasdiff`. |
| `test/diff-gate.test.sh` | Self-test proving the gate **blocks** a synthetic breaking change and **passes** an additive one (INFRA-007 Required Test). |

## CI flow (`contract` job)

1. **Validate** — `redocly lint` on `contracts/openapi/openapi.yaml`.
2. **Diff-gate self-test** — `diff-gate.test.sh` (mechanism proof).
3. **Breaking-change gate** — `openapi-diff.sh <base> <head>` against the PR base
   branch's contract; a breaking diff fails the build.
4. **Compile gate** — generate the Dart client and `dart analyze` it.

## Tooling

- **oasdiff** — installed in CI (`curl … install.sh | sh`); the diff engine.
- **@redocly/cli** — OpenAPI validation.
- **@openapitools/openapi-generator-cli** (`dart-dio`) — client generation.

Locally, install `oasdiff` on your PATH to run the self-test; without it the test
exits `127` (skipped, not passed).
