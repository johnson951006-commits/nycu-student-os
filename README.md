# NYCU Student OS

The single, trusted academic workspace for NYCU students — one login; every class, every deadline, every day, organized automatically.

> This repository is built **strictly** from the frozen engineering corpus in [`docs/corpus/`](docs/corpus/). No feature, behavior, or architecture originates in code — the corpus is the only source of truth, and the [AI Implementation Backlog](docs/corpus/NYCU_Student_OS_AI_Implementation_Backlog.md) is the only authoritative implementation queue.

## Repository layout (BEP §1.1)

```
nycu-student-os/
├── backend/     # NestJS service (BIS §1.1)                  — scaffolded by INFRA-004
├── app/         # Flutter app (FA §2)                        — scaffolded by INFRA-008
├── contracts/
│   ├── openapi/ # openapi.yaml — single transport contract   — frozen by INFRA-007
│   └── tokens/  # design tokens — single theme source        — INFRA-009
├── infra/       # Terraform, per-env (OPS §3)                 — INFRA-010
├── docs/
│   ├── corpus/  # the 16 frozen specs (read-only reference)
│   ├── adr/     # Architecture Decision Records (FES §16)
│   ├── qa/      # Master Test Plan, RTM (QS §15)
│   ├── gates/   # quality-gate verdicts (FES §17)
│   ├── waivers/ # time-boxed gate waivers (QS §14)
│   └── spikes/  # spike verdicts (e.g. F-1)
├── .github/     # governance: CODEOWNERS, labels, templates, workflows, rulesets
└── scripts/     # operational scripts (e.g. branch-protection apply)
```

Directories carrying only `.gitkeep` are populated by their owning backlog tasks (noted above); this commit is **INFRA-001** (repository bootstrap & Git governance) only.

## How work happens here

- **Source of truth:** the 16 documents in `docs/corpus/`. They are read-only by governance (see `docs/corpus/README.md`); amendments follow `AI_Coding_Protocol` §11.3.
- **What to build & in what order:** the AI Implementation Backlog (atomic tasks `INFRA-*`, `AUTH-*`, `COURSE-*`, `ASSIGN-*`, `DEADLINE-*`, `CAL-*`, `SCHEDULE-*`).
- **How to build each task:** the AI Execution Playbook (intake → architecture-verification → dependency-verification → planning → approval gate → canonical layer order → tests → self-review → docs → completion).
- **Agents MUST NOT** create, merge, split, reorder, redefine, or infer tasks; a task that cannot be completed exactly as defined triggers an Escalation Report.

## Git & governance (BEP §1.2–§1.8)

- **Trunk-based:** `main` is always releasable; short-lived `feat/…` `fix/…` `chore/…` branches; release trains cut `release/x.y`.
- **Branch protection** is stored as code in `.github/rulesets/` and activated with `scripts/apply-branch-protection.sh` (run once by a repo admin after the repo exists on GitHub): no direct pushes to `main`, PR + 1 approving review + CODEOWNERS + required status checks, merge queue (squash), linear history, no force-push, no deletion.
- **Commits:** Conventional Commits (`commitlint.config.js`), validated by the `commit-lint` workflow.
- **PRs** are governed artifacts (`.github/pull_request_template.md`); labels follow `.github/labels.yml`.

## Getting started

1. Read `docs/corpus/README.md`, then the AI Execution Playbook and the AI Implementation Backlog.
2. Pick the next open backlog task in execution order (Backlog Global Section E).
3. Execute it through the Playbook. Do not skip ahead.

> Environment pinning, local topology (Docker Compose), and the CI pipeline are **not** part of INFRA-001 — they are delivered by INFRA-002 and INFRA-003 respectively.
