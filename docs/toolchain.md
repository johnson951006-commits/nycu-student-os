# Toolchain Pins (INFRA-002)

Authoritative version pins for the development environment (BEP §2). The goal is
**byte-identical environments across every machine and CI runner**. Version bumps
follow the OPS §10 dependency-upgrade cadence (never ad hoc).

## System toolchain — pinned in `.tool-versions` (asdf) + `.nvmrc` / `.fvmrc`

| Tool | Pin | Pin file | Role |
|---|---|---|---|
| Node.js | 22.11.0 | `.tool-versions`, `backend/.nvmrc` | Backend runtime (Node 22 LTS) |
| pnpm | 9.12.3 | `.tool-versions` | Backend package manager |
| Flutter (stable) | 3.24.5 | `.tool-versions`, `app/.fvmrc` (FVM) | Client SDK |
| Dart | bundled with the Flutter pin | — | (follows Flutter) |
| Terraform | 1.9.8 | `.tool-versions` | IaC (OPS §3) |
| gcloud | 497.0.0 | `.tool-versions` | GCP CLI |
| Firebase CLI | 13.23.1 | `.tool-versions` | FCM project config |

## Package-manager-level tools — pins recorded here; enforced by INFRA-004 / INFRA-008

These are npm/pub packages that live in `backend/package.json` (created by INFRA-004)
and `app/pubspec.yaml` / workspace (created by INFRA-008). INFRA-002 records the
authoritative pins; the owning tasks write them into the manifests.

| Tool | Pin | Enforced in (task) | Role |
|---|---|---|---|
| Prisma CLI | 5.22.0 | `backend/package.json` (INFRA-004) | Schema + migrations |
| @nestjs/cli | 10.4.5 | `backend/package.json` (INFRA-004) | Backend scaffolding |
| melos | 6.1.0 | Dart workspace (INFRA-008) | Monorepo task orchestration |
| FVM | 3.2.1 | dev prerequisite (BEP §2) | Flutter version management |

## Verification-lane tooling (referenced by INFRA-003 CI)

`dart format`, analyzer (`strict-casts`/`strict-inference`/`strict-raw-types`),
`custom_lint`, `import_lint`, `alchemist`, `patrol`, `k6`, `osv-scanner`, Trivy,
`gitleaks`, `openapi-generator`, Schemathesis. Their versions are pinned where they
enter the pipeline (INFRA-003); this table is the single reference for their identity.

## Local container images — pinned in `docker/docker-compose.yml`

| Service | Image | Mirrors (prod) |
|---|---|---|
| Postgres | `postgres:16.4-alpine` | Cloud SQL PostgreSQL 16 (DB §4.1) |
| Redis | `redis:7.4-alpine` | Memorystore Redis 7 (OPS §1) |
| Pub/Sub emulator | `google-cloud-cli:497.0.0-emulators` | Cloud Pub/Sub (OPS §1) |
| Fixture upstream server | `nginx:1.27-alpine` | the scraped upstream (test double, QS §8) |
