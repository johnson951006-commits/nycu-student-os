# NYCU Student OS — Backend (NestJS)

One image, four run shapes selected by `APP_PROFILE` (BIS §1.1/§1.2):
`api` · `sync-worker` · `notif-worker` · `jobs`.

This is the **scaffold** (INFRA-004): the boot switch, typed fail-fast config, and
the `src/shared/` structure (empty stubs). The real shared services (Prisma, Redis,
Pub/Sub, KMS, logger, error registry, guards, health) are implemented by INFRA-006;
the database schema by INFRA-005; the transport contract by INFRA-007; feature
modules by their own tasks.

## Run

```bash
pnpm install
cp .env.example .env            # set at least APP_PROFILE, NODE_ENV, PORT
APP_PROFILE=api pnpm start:dev  # HTTP server on :PORT
APP_PROFILE=jobs pnpm start:dev # headless context (sync-worker / notif-worker / jobs)
```

Invalid configuration aborts at boot with a descriptive error (fail-fast, BIS §1.4).

## Test

```bash
pnpm test        # config-validation reject test + per-profile boot test
pnpm lint
pnpm format
```

## Layout (BIS §1.1)

```
src/
├── main.ts            # APP_PROFILE boot switch
├── app.module.ts      # root; assembled per profile
├── config/            # typed config + zod fail-fast validation + profile wiring
├── shared/            # infrastructure stubs (implemented by INFRA-006)
├── modules/           # feature modules (added by feature tasks)
└── workers/           # worker entry points (added by INFRA-006 / feature tasks)
```
