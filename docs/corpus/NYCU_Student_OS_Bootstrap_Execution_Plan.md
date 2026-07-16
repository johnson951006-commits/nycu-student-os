# NYCU Student OS — Project Bootstrap & Execution Plan
## Version 1.0 — The Engineering Playbook
**Authority:** Principal Software Architect · Principal Engineering Manager · Staff Flutter Engineer · Staff Backend Engineer · Technical Program Manager
**Status:** APPROVED — the execution contract from empty repository to production
**Date:** July 2026

**Governing corpus (frozen — this plan implements, never redesigns):** PRD v1.1 · DS v1.0 · BA v1.0 · IRR v1.1 · DB v1.0 · BIS v1.1 · FA v1.0 · FES v1.0 · QS v1.0 · OPS v1.0 · **AI Coding Protocol v1.0** (the implementation constitution — this plan operates under it).

**What this document is:** the ordered, dependency-aware, gate-bounded sequence that turns eleven specifications into a shipped product. It decides *when* and *in what order*, never *what* or *how* (those are frozen). Every sprint, milestone, and checklist item traces to a corpus contract and the AI Coding Protocol's development order (§5 of that document).

**Carried open items (tracked to closure herein):** **F-1** (WebView cookie-extraction spike — highest project risk, IRR §10.3), **D-3** (design addendum for Notification Center & Sync Health screens, IRR A3), **P-2** (analytics consent copy — PM, FES §7.3), **B-1/B-2/D-1** (backend credential-excision, OpenAPI v1.1 freeze, initial migration set — IRR §10.3), plus **A4/grades** (flag-gated pending PRD amendment).

**Team assumption (for sizing):** ~5 engineers (2 backend, 2 Flutter, 1 full-stack/SRE-leaning) + fractional design, PM, QA. Sprints are 2 weeks (aligns with FES §11 release trains). Adjust cadence, not order — the dependency graph is invariant.

---

# 1. Repository Bootstrap

## 1.1 Repository structure (monorepo)

A single monorepo holds both apps and shared contract artifacts — the client and backend are bound by one OpenAPI contract (BIS §12.2) and one design-token JSON (FES §6); a monorepo makes that binding atomic (a contract change and both sides' adaptation land in one PR).

```
nycu-student-os/
├── backend/                # NestJS service (BIS §1.1 folder structure)
├── app/                    # Flutter app (FA §2 folder structure)
├── contracts/
│   ├── openapi/            # openapi.yaml — single source, generates both sides (BIS §12.2)
│   └── tokens/             # design/tokens.json — single source for theme (FES §6)
├── infra/                  # Terraform (OPS §3), per-env workspaces
├── docs/
│   ├── corpus/             # the 11 frozen specs (read-only reference)
│   ├── adr/                # Architecture Decision Records (FES §16)
│   ├── qa/                 # Master Test Plan, RTM (QS §15)
│   ├── gates/             # quality-gate verdicts (FES §17)
│   └── waivers/            # time-boxed gate waivers (QS §14)
├── .github/                # workflows, templates, CODEOWNERS, labels
└── README.md               # onboarding → green build in ≤½ day (FES §17 doc gate)
```

## 1.2 Git strategy
Trunk-based (FES §11.1): `main` always releasable; short-lived `feat/`, `fix/`, `chore/` branches (≤3 days old at merge); release trains cut `release/x.y` every 2 weeks; hotfixes branch from the released tag and cherry-pick back. **Git Flow is explicitly rejected** (FES §11.1) — no long-lived `develop`. Squash-merge only (linear history); merge queue enabled (`main` tested post-combination).

## 1.3 Branch protection (`main` and `release/*`)
- No direct pushes; PR + 1 approving review + all required checks green (QS §14 gates).
- Merge queue required; linear history enforced; force-push and deletion blocked.
- Required status checks: format, analyze+custom-lints, unit, widget, golden(0-diff), backend unit+integration, contract(OpenAPI validate), coverage ratchet, SAST/deps/secrets. R1-area failures non-waivable (QS §14).
- `release/*` additionally requires: RG-CRIT/PERF/SEC/AX green + deployment-approval environment (ENG lead + PM, OPS §11).

## 1.4 Labels (issue/PR taxonomy)
`type:feat|fix|chore|docs|test|infra` · `area:backend|flutter|sync|notif|auth|calendar|db|ci|design` · `risk:R1|R2|R3|R4` (QS §1.6) · `sev:S1|S2|S3|S4` · `prio:P0|P1|P2|P3` · `flag:behind-flag` · `blocked` · `needs-adr` · `needs-design(D-3)` · `open-item:F-1|D-3|P-2`. Labels drive path-based CI suite selection (QS §12) and triage SLAs (QS §15.8).

## 1.5 CODEOWNERS
```
/backend/                @backend-team
/backend/src/modules/portal/   @backend-lead   # parser = R1, senior review mandatory
/backend/src/modules/auth/     @backend-lead @security-owner
/app/                    @flutter-team
/app/lib/core/sync/      @flutter-lead          # outbox/conflict = R1
/contracts/openapi/      @backend-lead @flutter-lead   # contract changes need both
/contracts/tokens/       @design-owner @flutter-lead
/infra/                  @sre-owner
/docs/corpus/            @eng-manager @architect  # spec amendments = governance act (AI Protocol §11.3)
/.github/                @eng-manager
```

## 1.6 Issue templates
- **Feature** — links governing corpus section(s); DoR fields (QS §1.2): AC as testable statements, reserved test IDs, error codes emitted, analytics/flags/a11y impact.
- **Bug** — severity (QS §1.7), repro, expected-vs-actual with corpus citation, affected SLO.
- **Spec amendment** (AI Protocol §11.3) — owning document, proposed change, ledger + RTM + test impact; requires @architect/@eng-manager.
- **ADR** (FES §16) — the template verbatim.

## 1.7 Pull request template
Mirrors the AI Coding Protocol §6 governed-artifact checklist: feature checklist ticked · tests present + IDs registered · migration expand-safe · ARB(zh+en) · a11y/goldens · analytics registered · error mapping · docs/ADR · **traceability line** (PRD req / IRR § / QS test IDs this PR satisfies). A PR missing an applicable element cannot merge.

## 1.8 Commit conventions
Conventional Commits (FES §11.1) — `feat(sync): …`, `fix(auth): …` — feeds changelog + SemVer. Body cites corpus section for non-obvious decisions (AI Protocol §1.5). Footer `Refs #issue`, `ADR-NNNN` where applicable.

---

# 2. Development Environment

Pinned versions live in `.tool-versions` (asdf) + `backend/.nvmrc` + `app/.fvmrc` so every machine and CI runner is byte-identical — "works on my machine" is a config bug, not an excuse.

| Tool | Pin | Role |
|---|---|---|
| Flutter SDK | stable channel, pinned via **FVM** (`.fvmrc`) | client (FA) |
| Dart | bundled with Flutter pin | — |
| Node.js | 22 LTS (`.nvmrc`) | backend runtime (BIS) |
| pnpm | pinned | backend package manager (lockfile-only installs) |
| NestJS CLI | pinned | backend scaffolding (BIS §1.1) |
| Prisma CLI | pinned | schema + migrations (DB §8) |
| Docker + Compose | current stable | local topology (OPS §3.1) |
| Firebase CLI | pinned | FCM project config (BIS DV1) |
| gcloud + Terraform | pinned | GCP + IaC (OPS §1/§3) |
| melos | pinned | monorepo task orchestration (tokens gen, codegen, cross-package scripts) |

**Required tooling:** `dart format`, analyzer (strict-casts/inference/raw-types), `custom_lint` (import matrix FES §3, token/duration literals, ARB coverage, flag/error registries), `import_lint`, alchemist (goldens), patrol (integration), k6 (load), osv-scanner/Trivy/gitleaks (security), openapi-generator (Dart client from contract), Schemathesis (API fuzz).

**IDE setup:** VS Code (or Android Studio/IntelliJ). Committed workspace settings: format-on-save, analyzer strict, FVM SDK path, ARB editor, launch configs per `APP_PROFILE` (api/sync-worker/notif-worker/jobs) and Flutter flavors (dev/staging/prod).

**Recommended extensions:** Dart/Flutter, Prisma, ESLint, GitLens, Error Lens, Conventional Commits, Mermaid preview (the corpus is Mermaid-heavy), REST/OpenAPI client, GitHub Actions.

---

# 3. Project Initialization (Sprint 0 mechanics)

Order matters — each initialization unblocks the next. This section is the "empty repo → green skeleton" sequence; §10 checklist makes it tick-by-tick.

## 3.1 Backend initialization
1. Nest scaffold to BIS §1.1 folder structure; `APP_PROFILE` boot switch (4 profiles) even before profiles have logic.
2. Prisma init; **transcribe DB §7 canonical DDL** into `schema.prisma` + raw-SQL migration steps (triggers, RLS, partitions) — this is task **D-1** (IRR §10.3), and it includes IRR Part 13 deltas (`portal_page_health`, `sync_jobs.category_state`) and the §11.2 deltas (notification_prefs, notification_history, portal_versions; NO `portal_credentials` — task **B-1**).
3. `shared/` infrastructure: PrismaService (pooled) + PrismaDirectService, RedisService+locks, PubSub abstractions, KmsEnvelopeService, structured logger + redaction, error-code registry (transcribe IRR §7), zod validation pipe, health indicators.
4. Two Prisma clients wired for PgBouncer topology (BIS §6.1).

## 3.2 Flutter initialization
1. Flutter create to FA §2 structure; flavors dev/staging/prod.
2. `bootstrap/` sequence: secure-storage read → drift open(SQLCipher) → Hive → snapshot providers (FA §4); no flash-of-wrong-theme.
3. Theme from tokens: **generate `tokens.g.dart` from `contracts/tokens/tokens.json`** (FES §6 pipeline) + WCAG contrast CI check; `ThemeExtension<NycuColors>` for non-M3 tokens.
4. Error layer: `AppFailure` sealed class = IRR §7 codes (client mirror of backend registry).
5. l10n: ARB template zh-TW + en; gen_l10n; ARB-diff CI.
6. Component-library shell in `shared_widgets/` — **goldens first** (visual contract before features, FES §18 / FA §18 build order).

## 3.3 CI/CD initialization
Transcribe the QS §13 / FES §11.2 pipeline into `.github/workflows`: PR lane (format→analyze→unit→widget→golden→backend→contract→coverage→security), merge-queue lane (full + integration + Newman smoke), release lane (RG suites + k6 + chaos smoke), tag lane (staged rollout on Sentry health). Branch protection (§1.3) references these as required checks.

## 3.4 Firebase initialization
Firebase project per env; FCM enabled; **APNs auth key uploaded** (iOS delivery via FCM relay, BIS DV1); service-account JSON → Secret Manager (not committed). `firebase-admin` wired in notif-worker profile behind the `FcmSender` port (test-fakeable).

## 3.5 Environment configuration, secrets, feature flags
- Typed config + zod boot validation (BIS §1.4) — process refuses invalid config.
- Secrets in per-env Secret Manager, mounted via Cloud Run `--set-secrets` (OPS §1.2); nothing secret in image/Terraform state/repo (gitleaks gate).
- Feature-flag registry seeded (FES §10): `grades_sync=false` (A4, off until PRD amendment), `sec_pinning_enforced=true`, `sec_min_supported_version`, `notif_digest_batching`, analytics-enabled — each with owner + `expiresAt`. Backend `/v1/config` + client Hive snapshot wired.

---

# 4. Sprint Planning

Each sprint: **Goal · Deliverables · Dependencies · Exit criteria** (exit = QS DoD at the relevant layer + gates green). Sprints follow the AI Coding Protocol §5 development order (bottom-up: contract before consumer) and the vertical-slice-first strategy (a thin end-to-end slice proves the whole pipeline before breadth).

### Sprint 0 — Foundation & the highest-risk spike (2 wks)
- **Goal:** green skeleton on both sides + retire the project's #1 risk (F-1).
- **Deliverables:** §3 initialization complete (B-1, D-1, CI, Firebase, flags); **F-1 WebView cookie-extraction spike against the real NYCU Portal** (the go/no-go gate for the entire Tier-2 auth strategy); **B-2 OpenAPI v1.1 frozen** in `contracts/`; component-library golden baseline; Q-1/O-2 Portal synthetic test account provisioned (external dependency — start day 1).
- **Dependencies:** none (this is the start); F-1 needs a real Portal login (arrange access immediately).
- **Exit criteria:** both apps build+test green in CI; migrations apply cleanly to a fresh DB incl. all deltas; OpenAPI generates a compiling Dart client; **F-1 outcome documented** — if cookie extraction is unreliable, escalate the fallback ladder (SSO acceleration / reduced-cadence, IRR §12.2) BEFORE building auth on it. Design addendum **D-3** kicked off (needed by Sprint 6).

### Sprint 1 — Authentication (the root dependency)
- **Goal:** end-to-end auth: client WebView handoff → server session → JWT → refresh.
- **Deliverables:** `POST /auth/portal-session|reauth-session|refresh|logout` (BIS §5, §2); SessionVault (KMS envelope), TokenService (rotation+reuse-detection); client auth flow (FA §11) + Login screen (12.1); session-expiry banner plumbing (IRR Part 3 client side). Backend order per AI Protocol §5.1; client per §5.2.
- **Dependencies:** Sprint 0 (F-1 verdict, migrations, contract).
- **Exit criteria:** AT-001..016 + SEC-001..005 green; a real (synthetic-account) login populates a JWT; session survives restart; **password provably never persisted** (SEC-001 audit); expiry → banner, no data wipe. RG-CRIT auth subset passes.

### Sprint 2 — Sync Engine core + first vertical data slice (Courses)
- **Goal:** the product's spine — the sync pipeline working end to end on one category.
- **Deliverables:** backend SyncOrchestrator, DiffEngine (100% unit), SyncScheduler (claim/tier/jitter), RateGate, SignatureService, PortalClient + **CourseParser** (fixture-driven); `sync.jobs` topics + workers; `GET /sync/status|manual`; client SyncCoordinator + DeltaApplier + **outbox** + ConflictResolver (100% unit) + drift store; SyncStatusPill (all states). Courses flow: parser→diff→apply→delta→client render.
- **Dependencies:** Sprint 1 (a session to sync with); fixture Portal server.
- **Exit criteria:** SY-001..006 (course cases), state-machine transitions (IRR §2) covered; a course change in the fixture propagates to a client widget via drift watch; category-tx rollback leaves no partial state; DiffEngine + ConflictResolver at 100%. RG-SYNC (courses subset) green.

### Sprint 3 — Assignments + Todo (the trust-critical pair)
- **Goal:** assignments sync + the task layer that carries the product's core promise (never miss a deadline).
- **Deliverables:** AssignmentParser + assignment sync (new/updated/deleted 2-run/deadline-changed/attachments); assignments API + OverridesService (FR-14); Todo domain+repo+controller+screen (12.8), source labels, AUTO-todo creation, hide-not-delete, weekly-stats same-tx; QuickAdd + NL-date-parse.
- **Dependencies:** Sprint 2 (sync engine, courses as parent).
- **Exit criteria:** SY-010..018, SY-040..043 (overrides), AT-040..049 (todo) green; hidden-assignment consistency (FR-16) across surfaces; stats update instant + Taipei-bucketed; RG-SYNC + RG-CRIT todo subset green.

### Sprint 4 — Notifications (delivery = core promise G2)
- **Goal:** the reminder pipeline + 3-level preferences + Notification Center.
- **Deliverables:** ScheduleMaterializer, Dispatcher (SKIP LOCKED claim), DigestBatcher, FcmSender, PrefsResolver (3-level, 100%); notification_prefs/schedules/history; snooze; client LocalNotifMirror (14d), FCM adapter, deep-link routing; Notification Center screen (12.10 — **needs D-3**); prefs screens.
- **Dependencies:** Sprint 3 (assignments/exams as notification subjects); Firebase (Sprint 0); D-3 for Center UI.
- **Exit criteria:** API-040..052, AT-030..036/080..086 green; deadline-change → supersede→regenerate→push (SY-020); dispatch under 10 workers zero double-send; Center complete regardless of push; offline mirror fires. RG-NOTIF green.

### Sprint 5 — Dashboard + Calendar + Timetable (the daily surfaces)
- **Goal:** the read-heavy daily-use screens assembling everything prior.
- **Deliverables:** Dashboard (12.2, modules, edit-mode, cache-first render); Calendar (12.6, month/week/day, filters, holiday suppression, hidden handling, drag rules); Timetable (12.7, grid, now-line, biweekly); Exam/ExamCountdown, SemesterProgress, WeekRing stat cards; OccurrenceExpander (server).
- **Dependencies:** Sprints 2–4 (all data the dashboard aggregates).
- **Exit criteria:** WT-001..012/060..075 green; dashboard cache-paint <500ms (PF-001); filter <300ms; occurrences/holidays correct (SY-030..031); responsive phone/tablet + goldens (theme×locale×scale). RG-FEAT green.

### Sprint 6 — Offline hardening + Sync Health + Notes + Settings
- **Goal:** close the offline contract fully and finish remaining surfaces.
- **Deliverables:** complete offline matrix (IRR §6) — reconnect ordering, conflict paths, staleness banners; Sync Health page (12.12 — **needs D-3**, category isolation IRR §13.2, per-page health); Sticky Notes (12.9); Settings (12.11) incl. background-sync consequence dialog, data-ownership/export/delete (FR-21); analytics wired (**P-2 consent copy must land here**).
- **Dependencies:** Sprints 1–5; D-3 complete; P-2 resolved.
- **Exit criteria:** OF-001..041 green (reconnect sequence proven); account-deletion completeness (SEC-030); analytics param-allowlist audit (SEC-032); RG-OFF green. Feature-complete for Alpha.

### Sprint 7 — Stabilization, performance, security, accessibility
- **Goal:** meet every budget and gate; no new features.
- **Deliverables:** performance pass to PF budgets on the device farm; k6 load (PF-024 semester-storm); chaos suite (RB failure ladders); full pentest checklist (SEC-*); a11y manual pass + AX goldens complete; flaky-test triage to zero; documentation/onboarding gate (FES §17).
- **Dependencies:** feature-complete (Sprint 6).
- **Exit criteria:** all QS §14 gates green on a release build; PF/SEC/AX suites pass; error-budget instrumentation live; §17-FES quality gates recorded. **Release Candidate ready.**

### Sprint 8+ — Beta iteration & launch
- Closed → Open beta on the pilot cohort (PRD Phase 1, one college/department); notification tuning from opt-out data; sync-reliability watch against SLOs; bug-burn to zero S1/S2; then production staged rollout. (Milestones §6.)

---

# 5. Feature Implementation Order (and why it minimizes risk)

```
Sprint 0  Foundation + F-1 spike ─────────────────┐  (retire top risk FIRST)
Sprint 1  Authentication ─────────────────────────┤  (root dependency: nothing syncs without a session)
Sprint 2  Sync Engine + Courses ──────────────────┤  (the spine + first vertical slice proves the whole pipeline)
Sprint 3  Assignments + Todo ─────────────────────┤  (the trust-critical data: deadlines)
Sprint 4  Notifications ───────────────────────────┤  (core promise G2; depends on assignments/exams existing)
Sprint 5  Dashboard + Calendar + Timetable ───────┤  (read surfaces; aggregate everything prior)
Sprint 6  Offline + Sync Health + Notes + Settings ┤  (harden the contract; finish breadth)
Sprint 7  Stabilization (perf/sec/a11y) ──────────┘  (meet every budget/gate)
Sprint 8+ Beta → Production
```

**Why this exact order minimizes risk:**
1. **Highest risk first (F-1).** The Tier-2 cookie strategy is the one assumption that, if wrong, invalidates the auth approach and cascades everywhere. Proving or breaking it in Sprint 0 means every later decision rests on verified ground — never build eight sprints atop an unproven spike.
2. **Dependency order, not feature glamour.** Auth is the root (no session → no sync → no data → no screens). Sync is the spine (every feature reads its output). Building a dashboard first would mean mocking everything beneath it, then rewriting when reality arrives — the classic top-down waste the AI Protocol §5 order forbids.
3. **Vertical slice before horizontal breadth.** Sprint 2 drives ONE category (courses) fully through parser→diff→apply→delta→outbox→drift→widget. That thin slice exercises the entire architecture once, surfacing integration bugs when they're cheap — before three more categories and ten screens are built on the same rails.
4. **Trust-critical data before convenience surfaces.** Assignments+Todo+Notifications (Sprints 3–4) are the product's reason to exist (G2: never miss a deadline). They come before Dashboard/Calendar polish because a beautiful dashboard over broken reminders fails the mission; the reverse degrades gracefully.
5. **Offline hardened after the happy path exists (Sprint 6), not bolted on.** The local-first architecture makes offline structural (FA §1), but the reconnect/conflict *edges* are best hardened once the online flows they reconcile against are real — testing conflict resolution needs both sides to exist.
6. **Stabilization as its own phase (Sprint 7).** Performance, security, and accessibility budgets are met against a feature-complete build, not chased per-feature and re-broken — one disciplined pass beats seven partial ones.

Each arrow is a hard dependency: the downstream sprint cannot meaningfully start until the upstream's exit criteria are met. This is the program-management expression of the AI Protocol §5.3 invariant — a later step never forces a change to an earlier approved contract.

---

# 6. Milestones

| Milestone | Required features | Required tests | Quality gates |
|---|---|---|---|
| **Internal Alpha** (post-Sprint 4) | Auth, sync (courses+assignments), todo, notifications working end-to-end on synthetic account | RG-SMOKE + RG-CRIT (auth/sync/todo/notif subsets) + unit gates green | CI §14 green on `main`; DiffEngine/ConflictResolver/PrefsResolver at 100%; internal dogfood on synthetic data |
| **Alpha** (post-Sprint 6) | Feature-complete: all §5 PRD features incl. dashboard/calendar/timetable/notes/settings/health/offline | Full RG-FEAT + RG-OFF + RG-NOTIF + RG-SYNC; goldens complete | All CI gates; feature checklists (FES §4) closed for every feature; D-3 shipped; P-2 landed |
| **Release Candidate** (post-Sprint 7) | Alpha + all budgets met, no new features | RG-PERF (device farm) + RG-SEC (pentest) + RG-AX (manual+auto) + k6 load + chaos | All QS §14 gates incl. non-waivable R1; FES §17 quality-gate verdicts recorded; error budget instrumented |
| **Closed Beta** | RC on a small invited cohort (one department, PRD Phase 1) | Real-Portal manual script; E2E smoke daily; crash-free watch | Staged store rollout gated on Sentry release health ≥99.5%/48h (OPS §11) |
| **Open Beta** | Closed-beta + fixes; campus-wide opt-in | Load at real concurrency; notification-timing over days; opt-out <10% watch | SLOs held over the window (sync ≥99%, notif lag ≤60s); zero open S1/S2 |
| **Production** | GA to full population | Go/No-Go unanimous (QS §15.7); DR drill current | All above + on-call staffed, runbooks rehearsed (OPS §7), kill-switches verified reachable |

Milestone rule: a milestone is *declared*, in a recorded meeting with the gate owners (FES §17 / QS §15.7), never assumed from a calendar date. A slipped gate slips the milestone, not the bar.

---

# 7. Risk Tracking

| Risk / unknown | Class | Status & mitigation | Owner |
|---|---|---|---|
| **F-1: WebView cookie extraction vs real Portal** | R1 existential | Retired-or-escalated in Sprint 0; fallback ladder documented (SSO acceleration → reduced-cadence; never stored passwords) | Flutter lead |
| **Portal structure/parser drift** | R1 | Designed-for (versioned parsers, Safe Mode, sanity gates, canary — IRR §4, OPS RB-1); worker-only hotfix <4h MTTR; the *permanent* de-risk is the NYCU SSO/API partnership | Backend lead + EM |
| **NYCU IT relationship / rate limits / allowlist** | R1 | Static egress IP for allowlisting (OPS §1.2); synthetic account (Q-1/O-2); pursue formal partnership early (PRD Risk, Roadmap) | EM/PM |
| **D-3 design addendum (Center, Health screens)** | R2 | Started Sprint 0, due before Sprint 4/6; blocks only those screens, not core | Design |
| **P-2 analytics consent copy** | R2 | PM amendment before analytics ships (Sprint 6); default-off until landed | PM |
| **A4 grades scope** | R2 | Flag-off (`grades_sync=false`) until PRD amendment + PDPA review; zero code waste (BIS §11.2 table empty when off) | PM + Security |
| **Semester-start load** | R2 | Rehearsed via k6 gate (PF-024) each term; pre-warm min-instances (OPS RB-7) | SRE |
| **PDPA compliance** | R1 | Data residency Taiwan, minimization, erasure job, audit; annual pentest; legal review before launch | Security/PM |

**Known unknowns:** real Portal 2FA variability across accounts; true session-TTL Portal enforces (drives sliding-renewal cadence tuning); actual campus-network offline frequency (informs cache aggressiveness). Each becomes measurable in beta and is tracked, not guessed.

**Deferred features (PRD Won't-Have / Future — NOT this project):** external calendar two-way sync; AI daily briefings/study plans; shared/collaborative notes; campus map/walking-time; email-parsing plugin (post-MVP, opt-in). These are out of scope by PRD decision; the architecture leaves seams (BA/BIS extraction triggers, flag framework) but no work is done on them.

**Open issues register:** maintained in GitHub with `open-item:*` labels; F-1/D-3/P-2/A4 tracked to explicit closure; every ambiguity that reaches §1.6-STOP becomes a logged issue + (if resolved) a corpus amendment (AI Protocol §11.3).

---

# 8. Release Strategy

Per OPS §3/§5 and FES §10/§11 — this section sequences them for launch.

- **Feature-flag rollout:** risky/new behavior ships behind a flag (grades, digest, experiments) with deterministic percentage bucketing server-side (FES §10); rollout ladder **1% → 10% → 50% → 100%**, each step watched against SLOs. Flags carry `expiresAt`; settled flags get a cleanup PR (no immortal flags).
- **Canary (primary deploy):** Cloud Run traffic 5% → 50% → 100%, each gated 30-min on error rate / API p95 / sync success / crash-free (OPS §3.2). Breach → instant traffic rollback to previous revision (safe because schema is expand-phase).
- **Rollback doctrine:** code = traffic shift (seconds); behavior = kill-switch flag (≤30s, no deploy); data-shape = forward-fix migration; parser = worker-only revision / Safe Mode (OPS §3.3).
- **Monitoring:** Sync Health + Golden Signals + Notification Funnel + Release Health dashboards (OPS §5.2); sync-first SLOs with error-budget freeze policy (OPS §5.4).
- **Sentry:** release created per tag; symbols uploaded; `beforeSend` scrubbing; fingerprint-by-error-code; release-health gate on staged rollout.
- **Analytics:** own-backend pipeline, param-allowlist, HMAC pseudo-id, default-on with disclosure (P-2) + opt-out; sync/reliability events at 100% (feed PRD success metrics), behavioral sampled 20% (FES §7).
- **Crash thresholds (release gates):** promote a rollout stage only while **crash-free sessions ≥99.5% over 48h**; a regression below that halts promotion and, if severe, triggers rollback (OPS §11 / QS §1.5).

---

# 9. Long-term Maintenance (the multi-year view)

| Activity | Cadence | Standard |
|---|---|---|
| **Dependency upgrades** | continuous (Dependabot/osv) + monthly batch; CRITICAL security <48h | full CI + RG suites per upgrade (OPS §10) |
| **Flutter/Dart upgrades** | per stable channel, on a break window; staging-clone tested first | goldens re-baselined deliberately if rendering shifts; N-2 app-version support (BIS §12.2) |
| **Database migrations** | per feature; major PG upgrade Blue/Green in a break | expand→migrate→contract always; advisory-locked; PITR safety net (DB §8, OPS §4) |
| **Portal changes** (the defining maintenance event) | reactive, monitored proactively (canary hourly + drift alarms) | RB-1: worker-only parser hotfix, Safe Mode limits blast radius, <4h MTTR; grow the fixture corpus each incident |
| **Parser maintenance** | with every Portal change + proactive canary | versioned parsers + fixtures per `portal_versions` (IRR §4, §13.1); every drift page joins the permanent test corpus |
| **Testing cadence** | per-PR (affected suites) · nightly (full RG-FEAT) · release (RG-CRIT/PERF/SEC/AX + k6) · quarterly (chaos + DR restore drill) | QS §12/§13; flaky-test quarantine within 24h |
| **Documentation updates** | with every spec-amending change (AI Protocol §11.3) | the corpus stays true: doc version bumped, ledgers + RTM + tests updated in the same governance act; code never silently leads the spec |

**Multi-year invariants:** the corpus is the memory (AI Protocol §11.1) — a new engineer or agent onboards from documents, not tribal knowledge; the SSO/official-API partnership is pursued continuously as the permanent de-risk of the existential upstream; error-budget policy governs the velocity/reliability balance for the life of the product.

# 10. Execution Checklist (Day 1 → Production)

Executable without ambiguity. Each completed item unlocks the next; `→` marks the unlock. Tasks cite the corpus/section that defines "done." Owner in brackets. This is the playbook a team runs top to bottom.

## Phase A — Repository & Environment (Day 1–3)
- [ ] A1. Create monorepo `nycu-student-os` with §1.1 structure; copy the 11 frozen specs into `docs/corpus/` (read-only) [EM] → unlocks all references
- [ ] A2. Configure Git: trunk-based, branch protection on `main` (§1.3), merge queue, squash-only [EM] → A3
- [ ] A3. Add `.github/`: CODEOWNERS (§1.5), labels (§1.4), issue + PR templates (§1.6–1.7), Conventional-Commits check [EM] → PRs become governed artifacts
- [ ] A4. Pin toolchain: `.tool-versions`, `.nvmrc`, `.fvmrc`, committed IDE settings + extensions (§2) [any] → identical envs everywhere
- [ ] A5. `docker-compose.yml`: api + workers + Postgres + Redis + PubSub emulator + fixture Portal server (OPS §3.1) [backend] → local topology runs
- [ ] A6. README onboarding path verified: fresh clone → green build ≤½ day (FES §17 doc gate) [EM]

## Phase B — Backend skeleton (Day 3–8)
- [ ] B1. Nest scaffold to BIS §1.1; `APP_PROFILE` 4-profile boot switch [backend] → B2
- [ ] B2. **[B-1]** Prisma init; transcribe **DB §7 canonical DDL** (no `portal_credentials`) into schema + raw-SQL migrations (triggers/RLS/partitions) incl. IRR Part 13 + §11.2 deltas [backend] → **[D-1] done**; unlocks all data work
- [ ] B3. Migrations apply cleanly to a fresh DB; RLS + triggers verified by a smoke integration test [backend] → B4
- [ ] B4. `shared/`: Prisma(pooled+direct), Redis+locks, PubSub, KMS, logger+redaction, **error-code registry = IRR §7**, zod pipe, health (BIS §1) [backend] → services can be built
- [ ] B5. **[B-2]** Author/freeze **`contracts/openapi/openapi.yaml` v1.1** (BIS §5 + §12.1 endpoints) [backend+flutter leads] → generated Dart client compiles; contract-lock in place

## Phase C — Flutter skeleton (Day 3–8, parallel to B)
- [ ] C1. Flutter create to FA §2; flavors dev/staging/prod [flutter] → C2
- [ ] C2. `bootstrap/` sequence (secure-storage→drift(SQLCipher)→Hive→snapshots), no theme flash (FA §4) [flutter] → C3
- [ ] C3. **Token pipeline:** `contracts/tokens/tokens.json` → generate `tokens.g.dart` + WCAG contrast CI gate (FES §6); `NycuColors` extension [flutter+design] → tokens-only styling enforceable
- [ ] C4. `AppFailure` sealed = IRR §7 codes; ARB template zh-TW+en + gen_l10n + ARB-diff CI [flutter] → C5
- [ ] C5. Component-library shell in `shared_widgets/`, **goldens-first** baseline (FA §18) [flutter] → screens can be built on real components

## Phase D — CI/CD, Firebase, flags (Day 6–10)
- [ ] D1. Transcribe QS §13 pipeline into `.github/workflows` (PR/merge/release/tag lanes); wire as required checks (§1.3) [SRE] → every PR gated
- [ ] D2. Custom-lints live: import matrix (FES §3), token/duration literals, ARB coverage, flag+error registries, no-print/no-`$queryRawUnsafe` [any] → boundaries mechanically enforced
- [ ] D3. Firebase per env; **APNs key uploaded**; service-account→Secret Manager; `FcmSender` port stubbed (BIS DV1) [backend] → notifications buildable later
- [ ] D4. Terraform skeleton (`infra/`): projects dev/staging/prod, Cloud Run services, SQL, Redis, PubSub, KMS, Secret Manager, LB+Armor (OPS §1) [SRE] → deployable
- [ ] D5. Feature-flag registry seeded (`grades_sync=false`, `sec_*`, digest, analytics), `/v1/config` + Hive snapshot (FES §10) [both] → flag-gating available

## Phase E — F-1 spike (Day 1–10, START IMMEDIATELY, gates everything)
- [ ] E1. **[F-1]** Arrange real NYCU Portal login access for the spike [EM/PM] — day 1, external dependency
- [ ] E2. **[F-1]** Spike: WebView loads real Portal login → detect authenticated redirect → extract cookie jar (WKWebView/CookieManager) → POST to a stub `/auth/portal-session` (FA §11, IRR §1.1) [flutter lead]
- [ ] E3. **[F-1] VERDICT documented:** reliable? → proceed to Sprint 1 on Tier-2. Unreliable? → **STOP, escalate fallback ladder** (SSO acceleration / reduced-cadence — never stored passwords) BEFORE Sprint 1 (IRR §12.2) [EM/architect] → **Sprint 0 exit gate**
- [ ] E4. **[Q-1/O-2]** Portal synthetic test account provisioned (external) [EM] → real-ish integration + staging possible

## Phase F — Sprint 1 Authentication (Weeks 3–4)
- [ ] F1. Backend auth per AI-Protocol §5.1 order: migration(done)→DTO/zod→mapper→SessionVault(KMS)→TokenService(rotation+reuse)→controllers `/auth/*` (BIS §2, §5) [backend]
- [ ] F2. API tests: AT-001..016 + SEC-001..005; **SEC-001 audit — password never persisted anywhere** [backend+QA] → auth trustworthy
- [ ] F3. Client auth per §5.2: AuthRepository→authController→PortalWebViewController→Login screen(12.1)→expiry banner (FA §11, IRR Part 3) [flutter]
- [ ] F4. E2E (patrol, fake+synthetic): login handoff → JWT → survives restart; expiry → banner, no data wipe [QA] → **Sprint 1 exit**; unlocks all syncing

## Phase G — Sprint 2 Sync spine + Courses (Weeks 5–6)
- [ ] G1. Backend: SyncOrchestrator, **DiffEngine (100% unit)**, Scheduler(claim/tier/jitter), RateGate, SignatureService, PortalClient+CourseParser(fixtures), sync topics/workers, `/sync/status|manual` (BIS §3, IRR §2/§4) [backend]
- [ ] G2. Client: SyncCoordinator, DeltaApplier, **outbox**, **ConflictResolver (100% unit)**, drift store, SyncStatusPill (FA §9, IRR §6) [flutter]
- [ ] G3. Courses vertical slice proven end-to-end: fixture change → parser→diff→apply→delta→drift watch→widget [both]
- [ ] G4. SY-001..006 + state-machine (IRR §2) + category-tx-rollback tests green; RG-SYNC(courses) [QA] → **Sprint 2 exit**; pipeline proven for all later categories

## Phase H — Sprint 3 Assignments + Todo (Weeks 7–8)
- [ ] H1. AssignmentParser + assignment sync (new/updated/deleted-2run/deadline/attachments) + assignments API + OverridesService (FR-14) [backend]
- [ ] H2. Todo domain→repo→controller→screen(12.8): source labels, AUTO-todo, hide-not-delete, weekly-stats same-tx, QuickAdd+NL-date [flutter]
- [ ] H3. SY-010..018/040..043 + AT-040..049 + hidden-consistency(FR-16) green; RG-CRIT(todo) [QA] → **Sprint 3 exit**

## Phase I — Sprint 4 Notifications (Weeks 9–10)
- [ ] I1. ScheduleMaterializer, Dispatcher(SKIP LOCKED), DigestBatcher, FcmSender, **PrefsResolver(3-level,100%)**, snooze (BIS §4) [backend]
- [ ] I2. Client: LocalNotifMirror(14d), FCM adapter, deep-link routing, Notification Center(12.10 — **needs [D-3]**), prefs screens [flutter]
- [ ] I3. API-040..052 + AT-030..036/080..086; dispatch-10-workers-zero-double-send; Center-complete-regardless-of-push; RG-NOTIF [QA] → **Sprint 4 exit → Internal Alpha milestone (§6)**

## Phase J — Sprint 5 Dashboard + Calendar + Timetable (Weeks 11–12)
- [ ] J1. Dashboard(12.2, cache-first, modules, edit-mode); Calendar(12.6, M/W/D, filters, holidays, hidden, drag); Timetable(12.7, now-line, biweekly); stat cards; server OccurrenceExpander [both]
- [ ] J2. WT-001..012/060..075 + PF-001(paint<500ms) + filter<300ms + goldens(theme×locale×scale) + responsive; RG-FEAT [QA] → **Sprint 5 exit**

## Phase K — Sprint 6 Offline + Health + Notes + Settings (Weeks 13–14)
- [ ] K1. Complete offline matrix (IRR §6): reconnect ordering, conflict paths, staleness [flutter]
- [ ] K2. Sync Health page(12.12 — **needs [D-3]**, IRR §13.2); Sticky Notes(12.9); Settings(12.11) incl. consequence dialog, ownership/export/delete(FR-21) [flutter]
- [ ] K3. **[P-2]** analytics wired with consent copy landed (FES §7); analytics allowlist audit (SEC-032) [flutter+PM]
- [ ] K4. OF-001..041 + SEC-030 (deletion) + RG-OFF green → **Sprint 6 exit → Alpha milestone (feature-complete)**

## Phase L — Sprint 7 Stabilization (Weeks 15–16)
- [ ] L1. Performance pass to all PF budgets on device farm; k6 PF-024 semester-storm [SRE+QA]
- [ ] L2. Chaos suite (RB ladders); full pentest (SEC-*); a11y manual+AX goldens; flaky→0 [QA+Security]
- [ ] L3. **FES §17 quality gates recorded** (arch/design/API/security/a11y/perf/testing/docs), error-budget instrumented → **Release Candidate milestone; all QS §14 gates green (R1 non-waivable)**

## Phase M — Beta → Production (Weeks 17+)
- [ ] M1. Closed Beta: RC to one department (PRD Phase 1); real-Portal manual script; daily E2E smoke; Sentry health ≥99.5%/48h staged rollout (OPS §11) [all]
- [ ] M2. Notification tuning from opt-out data; sync-reliability vs SLOs; burn S1/S2 to zero [all]
- [ ] M3. Open Beta: campus-wide opt-in; load at real concurrency; SLOs held over window [SRE]
- [ ] M4. **Go/No-Go meeting (QS §15.7):** unanimous QA/Eng/Design/Security/PM/SRE; kill-switches reachable; DR drill current; on-call staffed; open items (F-1/D-3/P-2/A4) resolved-or-deferred-with-owner [all]
- [ ] M5. **Production GA:** canary 5%→50%→100% gated on SLOs; monitor 24–48h; postmortem-ready [SRE] → **Production milestone**

## Phase N — Steady state (ongoing)
- [ ] N1. Operate per OPS: on-call rotation, runbooks, SLO/error-budget policy, dashboards
- [ ] N2. Release trains (2-weekly), staged rollouts, worker-only parser hotfix lane ready
- [ ] N3. Maintenance cadence (§9): dependency/Flutter/DB upgrades, parser corpus growth, quarterly chaos+DR drills
- [ ] N4. Pursue NYCU SSO/official-API partnership — the permanent de-risk of the existential upstream
- [ ] N5. Every production S1/S2 → postmortem → permanent RG-CRIT test (the suite grows toward the real failure surface)

---

## Closing statement

This plan sequences eleven frozen specifications into one executable path. Its spine is a single discipline held from Day 1 to GA and beyond: **retire the biggest risk first (F-1), build in dependency order (auth → sync → data → notifications → surfaces → hardening), prove each layer with the tests the corpus mandates before the next layer rests on it, and let every completed gate unlock exactly the next — never skip ahead onto unproven ground.**

Nothing here redesigns the product; the architecture is frozen and this document does not touch it. It answers only *when* and *in what order*, so that on the day of production launch, every one of the corpus's deliberate decisions has been implemented faithfully, proven by test, and operated under a runbook — and the product's promise, *trust through reliability*, is true not by assertion but by construction.

*End of Project Bootstrap & Execution Plan v1.0 — the engineering playbook. Governed by the AI Coding Protocol; implementing the frozen corpus; carrying open items F-1, D-3, P-2, A4 to explicit closure within the sprint sequence above.*
