# NYCU Student OS — Software Quality Specification
**Author:** Principal Software Quality Engineer
**Document Status:** Quality Specification v1.0 — official QA handbook, pre-implementation
**Date:** July 2026
**Reviewed corpus (all verified for testability):** PRD v1.1 · Design Spec v1.0 · Backend Architecture v1.0 · IRR v1.1 · Database Design v1.0 · Backend Implementation Spec v1.1 · Flutter Architecture v1.0 · Flutter Engineering Standards v1.0

**Purpose:** verify every requirement in the corpus is testable, bind each to concrete tests, and define the quality machinery (gates, suites, matrices) that governs implementation. This document *consumes* upstream contracts — the Error Matrix (IRR §7), state machine (IRR §2), conflict table (IRR §6.5), performance budgets (Standards §14, DB §12) are already test-shaped; this handbook assigns them IDs, owners, cadence, and pass/fail authority.

**Test ID scheme:** `AT-` acceptance · `SY-` synchronization · `OF-` offline · `API-` backend/API · `WT-` widget · `SEC-` security · `PF-` performance · `AX-` accessibility · `RG-` regression suite. IDs in this document are the canonical registry; test code MUST carry its ID in the test name.

---

# Section 1 — Quality Philosophy & Governance

## 1.1 Philosophy

1. **Trust is the product; sync correctness is the trust.** PRD G5 makes 99% sync success the survival metric — therefore sync, offline, and notification correctness get *census-level* testing (100% path coverage of the IRR §2 state machine), while cosmetic surfaces get sampled testing. Test effort follows user harm, not code volume.
2. **The specs are already the oracles.** Upstream docs were written as contracts (tables, matrices, invariants). QA's job is not to invent expected behavior but to *execute the documents*: every IRR table row becomes at least one test with a traceable ID.
3. **A requirement that cannot fail a test is not a requirement.** The testability audit (§2 RTM) found the corpus testable with **two exceptions**, logged here: (a) PRD §9 D30-retention and NPS targets are product metrics, verified by instrumentation not tests — assigned to analytics dashboards (Standards §7), out of QA scope; (b) PRD §5.4 "adaptive frequency based on historical completion patterns" is post-MVP ML (PRD Future Expansion) — no test until it exists. Everything else maps.
4. **Automate the contract, hand-test the judgment.** Deterministic behavior → CI. Perceptual quality (animation feel, VoiceOver flow coherence, copy tone) → structured manual scripts with named owners — scripted, time-boxed, recorded, never "exploratory when we have time."

## 1.2 Definition of Ready (a story may enter a sprint when…)
- Upstream spec section cited (IRR/Arch §) and unambiguous — any gap goes back through the deviation-ledger process, not into code.
- Acceptance criteria enumerated as testable statements with test IDs reserved.
- Error paths named (which Error Matrix codes can this feature emit?).
- Analytics events + flags identified (Standards §7/§10); a11y impact stated.

## 1.3 Definition of Done (a story is done when…)
- Feature Checklist (Standards §4) fully checked — including offline run, ARB, goldens, semantics.
- All reserved test IDs implemented and green in CI; coverage ratchets hold (§4).
- No open bugs > S3 against the story; error paths demonstrated (not just coded).
- Spec deltas (if any) merged into the owning document's ledger.

## 1.4 Acceptance criteria conventions
Every AC is written as *[Given context] [When action] [Then observable outcome ≤ measurable bound]*. PRD's existing AC checkboxes (§5.x) are inherited verbatim and mapped in the RTM; where a PRD AC lacked a bound, the IRR supplied it (e.g., "within one sync cycle" → HOT tier ≤ 7 min p95, Backend Arch §9.2) — the RTM cites the bounded form.

## 1.5 Release criteria (any production release)
- RG-SMOKE + RG-CRIT green on release build (§12); crash-free sessions ≥ 99.5% over 48h beta (Standards §11.2).
- Zero open S1/S2; S3 count ≤ 10 with PM sign-off; performance budgets green on device farm (§9).
- Security scan clean (no HIGH+); a11y CI guards green + manual pass on 5 hot screens (§11).
- Go/No-Go checklist executed (§15.7).

## 1.6 Risk classification → test depth

| Risk class | Areas (from PRD §10 + IRR) | Mandated depth |
|---|---|---|
| **R1 Existential** | Portal auth/cookie handoff, sync correctness, parser drift safety, notification delivery, data loss | 100% state/branch coverage of owning modules; chaos + DR tests; manual sign-off each release |
| **R2 Trust-eroding** | Offline behavior, conflict resolution, stats accuracy, hidden-assignment consistency, session expiry UX | Full matrix automation; regression suite membership |
| **R3 Experience** | Animation, theming, empty states, responsive layout | Goldens + sampled widget tests |
| **R4 Cosmetic** | Copy nuance, illustration | Manual review only |

## 1.7 Severity matrix (bugs) · 1.8 Priority matrix

| Severity | Definition | Example |
|---|---|---|
| **S1** | Data loss/corruption, security breach, crash-on-launch, missed deadline caused by us | AUTO todo silently deleted; notification never fired for a due assignment |
| **S2** | Core flow broken, no workaround; wrong academic data displayed | Sync stuck; deadline shows wrong date |
| **S3** | Feature impaired, workaround exists | Filter chip state lost on tab switch |
| **S4** | Cosmetic / minor | Misaligned chip in dark mode |

| Priority | Rule |
|---|---|
| **P0** | Fix before anything else; blocks release train; S1 always P0 |
| **P1** | Current train; S2 default; S3 in R1/R2 areas escalates to P1 |
| **P2** | Next train; scheduled |
| **P3** | Backlog; batched |

Severity is *impact* (immutable once assessed); priority is *scheduling* (PM+EM may move P2↔P3 only). S1/S2 in production trigger the incident process (Backend Arch §14), not just a ticket.

---

# Section 2 — Requirement Traceability Matrix

Automation levels: **FA** fully automated (CI) · **AA** automated + manual assert (device farm / scripted) · **M** manual scripted. Priority = risk class §1.6. Acceptance/regression cells cite representative IDs (full suites in §5–§12).

| PRD req | Requirement (bounded form) | UI (Design/IRR) | Backend API (Impl §5) | DB tables (DB §7) | Flutter screens (Arch §12) | Acceptance tests | Regression | Auto | Pri |
|---|---|---|---|---|---|---|---|---|---|
| §5.1 Portal Login (FR-1) | Two-tier auth; password never persisted; login <5s; session survives restart | IRR §1.1, Onboarding 0.2–0.5 | `POST /auth/portal-session`, `/reauth-session`, `/refresh`, `/logout` | users, app_sessions, portal_sessions | 12.1 Login + WebView | AT-001..008; SEC-001..005 | RG-CRIT | AA (WebView leg M until F-1 stabilizes) | R1 |
| §5.1 Session Expiration | Expiry → banner ≤1 cycle; no data wipe; no auto-WebView | IRR Part 3 (S1–S7) | `/sync/status.sessionExpired`, 401 codes | portal_sessions.status | banners, 12.1 | AT-010..016 (=S1..S7) | RG-CRIT | FA (server) + AA (client) | R1 |
| §5.2 Course Sync (FR-2) | 100% enrolled courses within 1 cycle; changes flagged 48h; no dupes | Course cards, changed badge | sync pipeline, `GET /courses` | courses, course_schedules, enrollments | 12.3/12.4 | SY-001..006 | RG-SYNC | FA | R1 |
| §5.3 Assignment Sync (FR-3) | Portal/LMS only; new items ≤1 cycle; date-needed distinct; manual add ≤3 taps | AssignmentCard states | `GET/POST/PATCH /assignments` | assignments, attachments, overrides | 12.5, 12.8 | SY-010..018; AT-020..024 | RG-SYNC | FA | R1 |
| §5.4 Notifications (FR-4, FR-15) | 3-level prefs, most-specific-wins; dedup 1h; cancel ≤60s on completion; digest ≥3-in-2h | prefs screens, IRR §1.8 | `/notification-prefs/*`, snooze | notification_prefs, schedules, deliveries | 12.11 subpage | API-040..052; AT-030..036 | RG-NOTIF | FA | R1 |
| §5.5 Calendar (FR-5) | Merged view; filter <300ms; holidays suppress; hidden excluded unless toggled (FR-16) | IRR §1.4 | `GET /calendar` | occurrences via courses/exams/events, exceptions | 12.6 | WT-060..068; SY-030 | RG-FEAT | FA | R2 |
| §5.6 Timetable (FR-6) | Accurate grid; live now-line; biweekly only valid weeks; block detail 1 tap | ClassBlock, NowLine | `GET /courses` (schedules) | course_schedules (week_bitmask) | 12.7 | WT-070..075; SY-031 | RG-FEAT | FA | R2 |
| §5.7 Dashboard (FR-7) | Cache paint <500ms / 2s cold; top-5 cap; module reorder persists; empty states | IRR §1.7 | dash payload (cached) | (read model) | 12.2 | WT-001..012; PF-001 | RG-SMOKE | FA | R2 |
| §5.8 Sticky Notes (FR-8) | CRUD ≤3 taps; dated notes on calendar; survives restarts/network switch | StickyNoteCard | `/notes/*` | sticky_notes | 12.9 | WT-080..086; OF-020 | RG-FEAT | FA | R2 |
| §5.9 Todo (FR-9) | Source label immutable; AUTO one-per-assignment; reopen; hide-not-delete; stats instant | TaskRow, IRR §1.5 | `/todos/*` | todos, weekly_statistics | 12.8 | AT-040..049; WT-090..098 | RG-CRIT | FA | R1 |
| §5.10 Completion Rate (FR-10) | Recalc ≤ seconds; Mon–Sun Taipei; zero-task ≠ 0%; recalculated label | StatRingCard | `/stats/weekly` | weekly_statistics | 12.2, progress | AT-050..054 | RG-FEAT | FA | R2 |
| §5.11 Semester Progress (FR-11) | ±1 day accuracy; milestones tappable; auto new-semester; non-standard terms | SemesterProgressBar | `/stats/semester` | semesters | 12.2 | AT-055..058 | RG-FEAT | FA | R2 |
| §5.12 Exam Countdown (FR-12) | Multiple exams; hourly <48h; manual labeled; auto-advance; not-yet-scheduled surfaced | ExamCountdownCard | `/stats/exams` | exams | 12.2 | AT-060..064 | RG-FEAT | FA | R2 |
| §5.13 Offline (FR-17) | Full matrix IRR §6.1; last-sync always shown; sync visibly disabled | BannerSlot, IRR Part 6 | outbox replay endpoints | client drift + outbox | all screens | OF-001..030 | RG-OFF | AA | R1 |
| §5.14 Sync Status (FR-18) | 4 states; failure surfaced ≤1 cycle; retry works; never blocks | SyncStatusPill | `/sync/status`, `/sync/manual` | sync_jobs, sync_runs | pill (global) | AT-070..075 | RG-SMOKE | FA | R1 |
| §5.15 Notification Center (FR-19) | Every event ≤1 cycle regardless of push; semester retention; deep links; offline readable | CenterEntryTile | `/notifications*` | notification_history | 12.10 | AT-080..086 | RG-NOTIF | FA | R2 |
| §5.16 Sync Health Page (FR-20) | Per-category status + retry; root-cause suppression; plain-language bilingual | CategoryHealthRow | `/sync/health`, `/sync/retry` | sync_runs.categories, portal_page_health | 12.12 | AT-090..095 | RG-SYNC | FA | R2 |
| §12 Data Ownership (FR-21) | Deletion removes user-owned data (30d backups); export; no secondary use | Settings privacy | account deletion job | Tier-A purge (DB §3.0) | 12.11 | SEC-030..034; API-090 | RG-CRIT (deletion path) | FA + M (audit) | R1 |
| FR-13 last-known-good | Stale data + timestamp on any failure | staleness notes | cached serving | — | all | OF-003, AT-072 | RG-OFF | FA | R1 |
| FR-14 overrides sync-safe | User edits survive sync; upstream change noted | IRR §1.3/1.5 | PATCH → overrides | assignment_overrides | 12.5 | SY-040..043 | RG-SYNC | FA | R1 |
| IRR A4 Grades (flag) | Detail-only display; quiet push; regrade history | GradeBlock | `/assignments/{id}/grade` | assignment_grades | 12.5 | AT-100..103 (run only with flag on) | RG-FEAT | FA | R2 |
| NFR performance/scale | budgets & SLOs | — | — | — | — | PF-001..030 | RG-PERF | FA | R1/R2 |
| NFR security/privacy | §Backend 14, Standards §13 | — | — | — | — | SEC-001..040 | RG-SEC | FA + M pentest | R1 |
| NFR a11y (WCAG 2.1 AA) | Standards §15 | — | — | — | all | AX-001..020 | RG-AX | FA + M | R2 |
| NFR localization | zh-TW/en parity | — | — | — | all | WT goldens ×2 locales; ARB CI | RG-FEAT | FA | R2 |

**RTM verdict:** every PRD FR (1–21) and every §5 feature maps to ≥1 automated test; the two §1.1-3 exceptions are instrumentation-owned. No orphan requirements; no orphan tests permitted (CI check: test IDs must appear in this registry — additions PR this file).

---

# Section 3 — Testing Pyramid (why each level exists)

| Level | Scope · tooling | Why it exists (what only it can catch) |
|---|---|---|
| **Unit** | Dart domain fns; NestJS services w/ fakes | The specs' pure logic (diff, prefs resolution, conflict table, Taipei bucketing) — millisecond feedback where 90% of correctness lives |
| **Widget** | Flutter component/screen w/ fake repos | State-matrix rendering (sealed UiState) and interaction wiring without device cost |
| **Integration (backend)** | testcontainers PG+Redis+PubSub emulator | Things fakes lie about: RLS actually blocking, SKIP LOCKED under contention, triggers, tx rollback (Backend §9) |
| **Integration (client)** | drift real DB + outbox + fake API | Outbox replay, cursor advance, delta upsert — the local-first machinery as a whole |
| **API testing** | supertest per endpoint | Every §Impl-5 row: status codes, validation, authz probes |
| **Contract testing** | OpenAPI validation middleware + Schemathesis fuzz + generated-client compile | The client and server code against the same YAML; drift dies in CI not on devices (Backend §12.2) |
| **System testing** | staging, real GCP topology, synthetic Portal account | Infra truths: Cloud Run scaling, PgBouncer pooling, Pub/Sub DLQs, Scheduler ticks |
| **E2E** | patrol app ↔ staging backend | The only level that proves the PRD's actual promise: login → sync → see deadline → get reminded |
| **Manual (scripted)** | release checklist scripts | Judgment calls machines can't make: animation feel, copy in context, WebView against the *real* Portal |
| **Accessibility** | guideline asserts + semantics snapshots + AT scripts | §11 — CI catches structure; humans catch flow coherence |
| **Security** | SAST/dep scan + pentest checklist | §10 — adversarial behavior is not a happy-path variant |
| **Performance** | device farm + k6 | Budgets are assertions (Standards §14, DB §12) — regressions are build failures, not dashboard sadness |
| **Load** | k6 semester-start scenarios | The one predictable traffic bomb (PRD scalability NFR) rehearsed before it happens |
| **Chaos** | fault injection in staging | Sync engine's failure ladders (IRR §2/§7.4) exist on paper; chaos proves the ladders under real partial failure |
| **DR testing** | quarterly restore drills (DB §9) | An untested backup is a hope; RTO/RPO numbers must be measured, not declared |

---

# Section 4 — Unit Testing Strategy & Coverage Requirements

Coverage gates are **ratchet-only** (never lowered) and enforced per-module, not repo-average — averages hide holes exactly where risk concentrates.

| Module (owner doc) | Coverage gate | Mandatory cases |
|---|---|---|
| Backend `DiffEngine` (Impl §3.1) | 100% branch | created/updated(field-diff)/archived; 2-run absence rule; hash no-op; normalization (full-width, whitespace, UTC); every sanity gate (IRR §4.2) firing and NOT firing |
| Portal parsers (Impl §1.1) | 100% of fixtures pass | one fixture per `portal_versions` row + every quarantined drift page ever seen (append-only corpus); item-level skip rule (IRR §13.1.3) |
| `PrefsResolver` (Impl §4.4) | 100% branch | 3-level inheritance matrix (global/course/assignment × enabled/offsets × NULL-inherit); weight adjust only on defaults; quiet-hours boundary (23:00/08:00 edges) |
| `ScheduleMaterializer` | 100% branch | offsets vs past-skip; generation supersede; snooze one-off; cancel-on-complete; digest grouping window |
| Sync scheduler claim logic | 95% | tier cadence, jitter bounds, claim-in-tx, category_state backoff independence (IRR §13.2) |
| Auth/`TokenService` | 100% branch | rotation chain, reuse-revocation, JWKS overlap verify |
| Flutter `domain/` (Arch §5) | 95% line | urgency ladder boundaries (24h/72h exact), Taipei week edges (Sun 23:59 / Mon 00:00 UTC+8), cursor codec round-trip + tamper, NL-date parser ambiguity set |
| `ConflictResolver` (client) | **100% — the IRR §6.5 table IS the test matrix**, every row × both directions | incl. edit-beats-delete undelete path |
| Outbox reducer/drainer logic | 100% branch | FIFO per entity, idempotency key stability, 4xx-permanent vs 5xx-retry classification, baseVersion propagation |
| Riverpod controllers | 90% | state transitions per screen matrix; failure mapping to AppFailure; no-network-await invariant (fake repo asserts no API call before local commit) |
| Repositories (client, vs in-memory drift) | 90% | watch-query shapes match §Arch 9.1 specs; hidden-assignment filter honoring `show_hidden_assignments` |
| Notification client mirror (`LocalNotifMirror`) | 95% | 14-day window; generation dedup vs push; snooze offline |
| DB layer (backend repos, vs testcontainers) | 90% | CAS 409 path; weekly-stats same-tx invariant; RLS cross-user zero-rows |

---

# Section 5 — Widget Testing

Per-screen strategy: mount with `ProviderScope` fakes (Standards test seam), drive the **full sealed-state matrix** (Loading/Data/Empty/Failure) + screen-specific interactions from IRR Part 1. Base matrix below; every cell = named test(s).

| Screen | Core widget tests (beyond state matrix) |
|---|---|
| Dashboard (WT-001..012) | module render per fixture; top-5 due cap + "view all n"; edit-mode reorder persists (Hive fake); each banner variant exclusive occupancy of BannerSlot; pill states; stat tap-throughs |
| Course list/detail (WT-020..) | color override popover writes enrollment; dropped group; per-course bell flip shows consequence copy once |
| Assignment detail (WT-040..) | date-needed → picker → override written; archived banner read-only; hide toggle → explainer first-time-only → undo restores; attachment disabled offline |
| Calendar (WT-060..068) | month pips + overflow "+n"; heat tint thresholds; holiday suppression rendering; hidden excluded/included ×filter; drag rejected on synced (lock-shake called), accepted on manual; completed chip same-day strike |
| Todo (WT-090..098) | grouping (overdue/today/tomorrow); swipe pair per source (Delete manual vs Hide AUTO); complete → 600ms hold → Done; undo restores sort_order; NL chip shows parse before commit; AUTO chip + source label |
| Sticky Notes (WT-080..086) | masonry cols per layout class; auto-save on dismiss; empty-discard; stale-30d ghost button; date pin renders on calendar fixture |
| Settings (WT-110..) | background-sync-off consequence dialog precedes write; offset chips min-1 enforced; language swap rebuilds strings in-place |
| Login (WT-120..) | offline disabled state; handoff failure → reopen affordance; different-account dialog |
| Synchronization (pill + health page) (WT-130..) | all 6 pill states; category rows incl. `blocked` rendering "waiting on course list" (IRR §13.2); per-category retry disabled while in-flight |
| Notification Center (WT-140..) | unread dot + dwell-read; day grouping; >5 same-course collapse; snoozed badge; archived-subject navigation to read-only view |

**Cross-cutting dimensions** (applied via test variants, not copy-paste): every above screen × **dark mode** (goldens), × **zh-TW/en** (goldens), × **large font 1.3 + AX3** (Dashboard/Tasks full set; others 1.3 only), × **phone/tablet** layout class (AdaptiveScaffold swap), × **portrait/landscape** (state survival assertion on rotation — controller identity check). Accessibility asserts (`tapTargetGuideline`, `textContrastGuideline`, semantics presence) run inside every screen test (Standards §15), not as a separate suite that can be skipped.

---

# Section 6 — Backend Testing

| Area | Tests (representative IDs) |
|---|---|
| REST API (API-001..) | per §Impl-5 endpoint: happy path, every documented error code, zod rejection of unknown fields, keyset pagination (cursor tamper → 400; stability under concurrent inserts), sort allowlist rejection, Idempotency-Key replay returns original |
| AuthN/JWT (API-020..) | expired/`aud`-mismatch/alg-none rejection; JWKS rotation overlap window; refresh rotation; **reuse → chain revocation** (API-024, R1) |
| Session cookies (API-030..) | handoff probe validation; jar re-encryption on rotate; `SESSION_EXPIRED` propagation; logout deletes portal_sessions row |
| Portal login leg | NOT unit-testable against real Portal — covered by canary account (Backend §8 jobs) + fixture server; real-Portal manual script each release (M) |
| Synchronization (API/SY suites §8) | orchestrator against fixture Portal server: category isolation, cancel-at-boundary, partial success stamping |
| Notification scheduler (API-040..052) | materialize offsets; supersede generation race (concurrent DeadlineChanged); dispatcher claim under 10 workers → zero double-send (testcontainers, the SKIP LOCKED proof); digest batching; quiet-hours deferral; FCM fake: Unregistered → device disable |
| Background jobs (API-060..) | each §Impl-8 job idempotent ×2 runs; deadline-scan convergence (delete schedules → scan recreates); purge respects 30d boundaries; advisory-lock overlap self-serialization |
| Redis (API-070..) | lock heartbeat + owner-token release (no cross-release); rate-limit window precision; cache invalidation completeness (write → key list deleted — key-registry-as-code makes this enumerable) |
| DB transactions / race conditions (API-080..) | CAS concurrent writers (one 409); todo+stats same-tx atomicity under injected failure; category tx rollback leaves zero partial rows; enrollment fan-out consistency |
| Retry logic | transient classifier table-driven; ladder timing (fake clock); max-attempt → DLQ |
| Rate limiting | 429 + Retry-After accuracy; per-user vs per-IP independence; SYNC_COOLDOWN UX contract (countdown value) |
| Caching | dash payload ETag/304; stale-serving during DB blip (chaos §12) |

**Contract verification strategy:** (1) OpenAPI response-validation middleware active in ALL test runs — any response drifting from `openapi.yaml` fails whatever test triggered it; (2) Schemathesis nightly fuzz (negative/boundary generation from the same YAML); (3) generated Dart client compiled in backend CI (a breaking change fails before the client repo ever pulls); (4) `openapi-diff` breaking-change gate (Backend §12.2). Postman/Newman role: §13.

---

# Section 7 — Offline Testing

Automation: patrol with airplane-mode control + drift/outbox fixture assertions; sequence-critical flows below get integration tests at the `core/sync` layer too (device-free, fast).

| ID | Scenario | Assertions |
|---|---|---|
| OF-001 | Cold start offline (cache present) | dashboard full render <500ms; banner "data from {t}" absolute time; zero network calls attempted |
| OF-002 | Cold start offline, first run (no cache) | offline+no-cache empty state (IRR §8.3); Retry works on reconnect |
| OF-003 | Staleness escalation | >7d-old cache adds second banner line |
| OF-010 | Reconnect flow | order proven: outbox drain → P1 sync → notif mirror reconcile → banner dissolve (IRR §6.8) — instrumented sequence assert |
| OF-011 | Reconnect flicker | 2s connectivity blip < 3s debounce → no drain/sync triggered |
| OF-012 | Sync resume | offline mid-first-sync → completed categories kept; resume completes remainder |
| OF-020 | Todo/note editing offline | full CRUD; restart persistence; outbox rows carry baseVersion+idemKey |
| OF-021 | Conflict on reconnect | complete offline on device A, priority-change online device B → both survive (field-class rules); title-vs-server case → server wins + override intact (SY-042) |
| OF-022 | Outbox permanent failure | 410 on replay → item-level retry affordance + Center entry; queue not blocked behind it |
| OF-023 | Duplicate replay | drain interrupted post-send pre-ack → re-drain → server idempotency yields no dupe |
| OF-030 | Notification offline | reminder fires from local mirror on time (airplane); deep link works against cache; on reconnect: mirror reconciled, no double-notify (generation dedup) |
| OF-031 | Snooze offline | local mirror re-schedules immediately; server op drains later; final state converges |
| OF-032 | Calendar offline | ±8wk navigable; beyond → "connect to load more"; manual event create offline lands on correct day |
| OF-040 | Session expired while offline | expiry discovered on reconnect → banner; queued mutations still drain after re-auth **before** P1 sync (order assert) |
| OF-041 | Background server sync while client offline | server-side scheduled run proceeds (session valid); client reconnect pulls delta — "data ready on reconnect" (IRR §2.2 OFFLINE row) |

**Sequence diagram — OF-040 (the trickiest ordering):**
```mermaid
sequenceDiagram
    participant App as App (offline)
    participant OB as Outbox
    participant API as Backend
    App->>OB: complete todo ×2, edit note (queued)
    Note over App: connectivity returns; /sync/status → sessionExpired
    App->>App: expired banner (mutations stay queued, NOT dropped)
    App->>API: user re-auth → POST /auth/reauth-session → 200
    App->>API: drain outbox FIFO (Idempotency-Keys)
    API-->>App: 200/409 per op → ConflictResolver → drift reconcile
    App->>API: THEN trigger P1 sync → deltas → drift
    Note over App: assert: no queued op lost across expiry;<br/>ordering user-intent-before-server-truth held
```

# Section 8 — Synchronization Testing (detailed cases)

Environment: backend integration harness with **fixture Portal server** (serves recorded HTML per `portal_versions`; scriptable mutations between "cycles"). Every case asserts three surfaces: DB state, emitted events, and `sync_runs.categories` stamp.

| ID | Case | Setup → action → expected |
|---|---|---|
| SY-001 | Initial sync bulk | empty user → run(initial) → all categories inserted; counts match fixtures; run `ok`; per-category progress stamped after EACH category (First-Sync polling contract) |
| SY-002 | No-op incremental | unchanged fixtures → run → zero domain writes; `changes:{}`; hash short-circuit proven (write-count probe) |
| SY-003 | Course room change | mutate room → run → `course_schedules.changed_at` set; Center entry room_changed; badge window 48h |
| SY-004 | Duplicate/cross-listed course | two fixture entries same course diff portal_id alias → dedup rule → single row (PRD §5.2) |
| SY-005 | Course removed | course absent → enrollment `dropped_at` set (archive, not delete); dependents' data retained |
| SY-006 | Semester switch | new semester fixture → new courses under new semester_id; old semester read-only retained (IRR §6.2); sync_jobs tier reset (stats/rollover job) |
| SY-010 | New assignment | added in fixture → row + AUTO todo + Center entry + schedules materialized + NEW window |
| SY-011 | **Duplicate assignment detection** | same title ±48h due, posted twice (Portal+LMS surfaces) → similarity ≥0.9 merge; single row; portal source preferred |
| SY-012 | Deleted assignment (2-run rule) | absent ×1 → still active, absent_run_count=1; absent ×2 → archived + Center entry + todo hidden + schedules canceled; reappears → un-archive, todo state restored |
| SY-013 | **Deadline changed** | due_at moved → field diff; `⚠changed` 48h; Center `Jul 20 → Jul 25` payload; schedules superseded, gen+1 rows against new date; hidden variant: Center only, zero push (SY-013b) |
| SY-014 | Date-needed lifecycle | no due date → confidence=missing; user sets date (override) → schedules materialize from override; later Portal publishes real date → base updated, override wins display, Center note |
| SY-015 | Attachment updated | attachment list change → hash diff → Center materials entry; NEW chip window |
| SY-016 | Grade posted/regraded (flag on) | grade appears → grades row + quiet Center entry; regrade → second row, history intact |
| SY-017 | Sanity-gate mass-archive block | fixture returns empty assignment page (broken selector sim) → ANOMALY → zero archives applied; page → safe_mode; category `failed:E-PARSE-DRIFT`; quarantine written |
| SY-018 | Item-level parse skip | one malformed item among 20 → 19 applied, 1 `item_skipped`; >20% malformed → whole page ANOMALY (IRR §13.1.3 boundary at exactly 20%) |
| SY-020 | **Delta sync / cursor** | client pulls delta with cursor → only post-cursor changes; cursor advances atomically per category; client schema_version bump → full re-seed path |
| SY-021 | Pagination under mutation | 150 assignments; delta paged; insert mid-pull → keyset stability, no skip/dupe |
| SY-030 | Holiday suppression | exception row on class day → occurrence absent in `/calendar`; makeup day present |
| SY-031 | Biweekly pattern | week_bitmask fixture → occurrences only on set weeks across the full 18-week expansion |
| SY-040 | Override survives sync (FR-14) | user title-override → Portal title change → base updated + override re-applied + inline "Portal version updated" data present |
| SY-041 | Override field collision | user overrode due_at; Portal moves due_at → server wins base; override intact; Center "changed the date you edited" |
| SY-042 | Conflict merge (client CAS) | stale baseVersion PATCH → 409 + current row; resolver outcome per field class; loser logged |
| SY-050 | Portal session expired mid-run | expire between categories → remaining `partial`; SESSION_EXPIRED once; queued jobs skip via pre-check (zero Portal calls while expired — call-count probe) |
| SY-051 | Network lost mid-run | fixture server drops conn on category 2 → in-run retry ladder (1s/4s/15s fake-clock) → then partial; requeue delay ladder verified |
| SY-052 | Cancel semantics | cancel flag mid-category → completes current category, skips rest; committed categories intact; `cancelled` stamp; cancel-after-complete = no-op |
| SY-053 | Category isolation | force exams failure ×3 cycles → exams backoff independent; other categories fresh every cycle; `blocked` vs `failed` distinction when courses itself fails (<24h stale-list rule honored) |
| SY-054 | Concurrent manual+scheduled | both fire → single run (lock attach); second caller gets same runId |

---

# Section 9 — Performance Testing (benchmarks)

All budgets inherited from Standards §14 (client) and Backend Arch §9.2 + DB §12 (server) — this section assigns measurement protocol + IDs. Fail = build/train failure (assertions, not dashboards).

| ID | Benchmark | Target | Protocol |
|---|---|---|---|
| PF-001 | Cold start → dashboard (cached) | ≤1,500ms p90 | Pixel 6a farm, 20 runs, release build |
| PF-002 | Warm start | ≤400ms p90 | platform vitals harness |
| PF-003 | Frame time 5 hot screens | p99 <16ms; jank <1% | patrol scroll scripts + timeline summary |
| PF-004 | Scroll sustained | 60fps; 10k-row task fixture | driveWithTimeline |
| PF-005 | Animation conformance | all durations = IRR §9 tokens | token pipeline audit (static) + spot timeline |
| PF-006 | Rebuild counts | checkbox toggle ≤ row+2 stat cards; hidden tabs 0 | rebuild-counter profile script |
| PF-007 | Memory steady | ≤250MB Android / 200MB iOS; zero leak slope ×3 loops | meminfo/Instruments scripted session |
| PF-008 | CPU idle-foreground | ≤15% avg 60s | farm profiler |
| PF-009 | Battery | zero background tasks in manifest (static audit); push handling ≤2s CPU | manifest audit + vitals |
| PF-010 | drift queries | p95 <8ms @10k rows | drift query log harness |
| PF-011 | App-open network | ≤3 requests; dashboard offline-renderable | dio interceptor counters |
| PF-020 | API p95 (dashboard GET) | ≤400ms server-side | k6 steady-state |
| PF-021 | Sync freshness HOT | p95 ≤7min | staging soak, synthetic cohort |
| PF-022 | Sync run duration | p95 ≤8s full cycle (fixture Portal @ realistic latency) | integration harness timer |
| PF-023 | Notification delay | fire_at → device p95 ≤60s | staging E2E with device farm receipt timestamps |
| PF-024 | **Load: semester-start storm** | 500 initial syncs/min + 1,500 read QPS + 300 tx/s sustained 30min: hot-query p95 <50ms, zero lock-waits >1s, zero DLQ, breaker never opens on self-load | k6 vs staging w/ 100k-user seed (DB §12 gate) |
| PF-025 | Notification burst | 10k schedules due in one window → dispatch lag p95 <60s, dedup guard holds | staging injection |
| PF-030 | Chaos suite | kill worker mid-run (redelivery idempotent); Portal fixture 30% 5xx (breaker opens, users see stale-honest); Redis restart (locks recover via TTL); PgBouncer restart (reconnect, no 5xx burst >10s) | staging fault injection, quarterly + pre-semester |
| PF-031 | DR drill | PITR restore → checksum suite; measured RTO ≤1h, RPO ≤5min | quarterly (DB §9) |

---

# Section 10 — Security Testing (penetration checklist)

Automated (CI): dep/image scanning, secret-leak scan, redaction tests (log/analytics/Sentry fixtures), zod fuzz via Schemathesis. Below = pentest checklist (pre-launch external + each major release internal).

| ID | Check | Pass criterion |
|---|---|---|
| SEC-001 | Password never touches our infra | Proxy-inspect handoff: only cookie jar in `POST /auth/portal-session`; no credential fields anywhere; WebView loads only allowlisted Portal origins |
| SEC-002 | Cookie jar at rest | DB dump shows only ciphertext; KMS decrypt IAM denied to api-role probe; jar absent from all logs/traces (structured-redaction proof) |
| SEC-003 | Cookie zeroing (client) | memory dump post-handoff contains no jar remnant; WebView store cleared post-handoff & logout |
| SEC-004 | JWT attacks | alg:none / HS256-confusion / expired / wrong-aud / tampered → all 401; JWKS endpoint serves only public material |
| SEC-005 | Refresh theft simulation | replay rotated token → whole chain revoked + Center entry (API-024 in adversarial harness) |
| SEC-010 | AuthZ / IDOR sweep | scripted cross-user probe on EVERY id-bearing endpoint (from OpenAPI) → uniform 404; RLS backstop verified by disabling repo scoping in a test build (RLS alone still blocks) |
| SEC-011 | SQL injection | sqlmap against all endpoints → zero findings (Prisma parameterization); `$queryRawUnsafe` lint proven absent in CI |
| SEC-012 | XSS via Portal content | fixture assignment titled `<script>…` + event-handler attrs → stored sanitized; API returns inert text; Flutter renders literally |
| SEC-013 | CSRF posture | confirm zero cookie-auth endpoints exist (Backend §7.2 invariant holds); CORS locked |
| SEC-014 | SSRF | attachment URLs / crafted portal_ids never fetched server-side; PortalClient host allowlist fuzz |
| SEC-020 | MITM / pinning | mitmproxy with trusted-CA cert → app refuses API + WebView Portal traffic; pin kill-switch flag flips behavior (logged, not silent) |
| SEC-021 | Secure storage | rooted-device extraction: tokens/DB key only in Keystore/Keychain paths; drift file unreadable without key; Hive/SP contain nothing from the sensitive denylist (automated schema assert) |
| SEC-022 | Backup exfil | adb backup / iTunes backup excludes secure prefs + drift per manifest config |
| SEC-023 | Screenshot scope | FLAG_SECURE active on WebView + grade block only; app-switcher blur on grade region |
| SEC-030 | Account deletion (FR-21) | delete → Tier-A rows purged (30d job verified with clock advance); export completeness vs ownership table; backups age-out ≤30d (restore-drill assert) |
| SEC-031 | Rate-limit abuse | credential-stuffing sim on handoff → 429 ladder holds; no Portal lockout amplification (call-count toward Portal bounded) |
| SEC-032 | Privacy telemetry audit | run full app script with proxy: every analytics/Sentry payload matches param allowlist; no content strings; userPseudoId only |
| SEC-040 | Dependency/image | zero HIGH+ CVEs at release cut; SBOM published |

---

# Section 11 — Accessibility Testing (WCAG 2.1 AA validation)

CI guards (FA) are non-skippable inside every screen test (Standards §15); AT scripts (M) run on the 5 hot screens (Today/Tasks/Calendar/Timetable/Center) each release train.

| ID | Validation | Method · pass | Gate |
|---|---|---|---|
| AX-001 | TalkBack full-flow | scripted traversal of 5 hot screens; order = visual; every interactive reachable & announced | M each train |
| AX-002 | VoiceOver full-flow | same, iOS; rotor navigation by headings/links works | M each train |
| AX-003 | Screen-reader announcements | checkbox announces IRR §7 phrasing ("OS HW3, due today 11:59 PM, not completed, double-tap to complete"); sync-complete live region fires; countdown reads full phrase not "D-5" | FA (semantics snapshot) + M |
| AX-004 | Tap targets ≥44pt | `tapTargetGuideline` in every screen test (incl. small pills' hit-slop) | FA blocking |
| AX-005 | Contrast ≥4.5:1 (3:1 large) | guaranteed at token layer (§6 CI) + `textContrastGuideline` per screen | FA blocking |
| AX-006 | Semantic labels | all interactives labeled; icon-only actions lint-checked; labels localized | FA blocking |
| AX-007 | Keyboard / switch access | logical tab order; visible focus ring; Escape dismisses sheets; focus returns to invoker | FA (FocusNode tests) + M |
| AX-008 | Large text AX3 (310%) | golden matrix Dashboard/Tasks; no clip/overlap; stat cards reflow 2-up→stacked ≥1.3× | FA goldens |
| AX-009 | Reduce Motion | `disableAnimations` golden set: fades only, shimmer→static, celebrate→instant+haptic | FA goldens |
| AX-010 | Color independence | urgency/priority/status = dot+label/position, never color-only | M review + §12 checklist |
| AX-011 | Color-blindness | 5 hot screens through deuter/prot/tritanopia sim → all states distinguishable | M each train |
| AX-012 | Dynamic Type not forced down | lint bans `textScaleFactor:1.0` fixes; renders at system max | FA |

A11y regression = release blocker at the same severity as a crash regression (Standards §15) — an inaccessible build does not ship, regardless of feature completeness.

---

# Section 12 — Regression Strategy

Suites are tagged sets of existing IDs; membership is the contract (a test not in a suite still runs in full CI, but suites define what MUST pass at each gate).

| Suite | Runs when | Contents | Budget |
|---|---|---|---|
| **RG-SMOKE** | every merge to main; post-deploy staging | app launch; login (fake); dashboard renders; create+complete todo; pill reaches Synced; one push deep-link | <5 min |
| **RG-CRIT** (critical path) | every release train | auth incl. session-expiry S1–S7; sync end-to-end; todo lifecycle; notification fire+cancel; account deletion; offline round-trip | <25 min |
| **RG-SYNC** | any change touching sync/parser/DB sync tables | all SY-*; category isolation; override safety; drift/sanity safety | — |
| **RG-NOTIF** | any change to notifications/prefs/scheduler | API-040..052; snooze; digest; 3-level resolution; Center completeness | — |
| **RG-OFF** | any change to sync/outbox/drift/connectivity | all OF-*; reconnect ordering; conflict table | — |
| **RG-PERF** | release train | PF-* on farm | — |
| **RG-SEC** | release train + weekly | SEC-* automated subset | — |
| **RG-AX** | release train | AX-* automated + scripted | — |
| **RG-FEAT** | nightly | full widget/feature matrix | — |

Selection: PRs auto-run affected suites via path-based triggers (change to `notifications/` → RG-NOTIF); release trains run all. **Flaky-test policy:** a test flaking twice/week is quarantined within 24h with an owner + fix ticket — quarantine ≠ delete, and quarantined count is a release-review metric (rising count = eroding trust in the suite). **Growth rule:** every production S1/S2 postmortem yields a new RG-CRIT member so the same failure can never recur silently — the suite grows toward the real failure surface over time.

---

# Section 13 — Automation Strategy

| Layer | Tool | Role |
|---|---|---|
| Dart unit/widget/golden | `flutter test` + alchemist | domain, controllers, widgets, golden matrix |
| Client integration/E2E | `patrol` (+ `integration_test`) | real drift/outbox, WebView drive, airplane-mode, deep links; emulator farm (Android 34, iOS 17) |
| Backend unit/integration | Jest + testcontainers | services, RLS, SKIP LOCKED, triggers, tx rollback |
| API functional/contract | supertest + OpenAPI validation middleware + Schemathesis | endpoint behavior + boundary fuzz |
| API collection/smoke | **Postman + Newman** | collection mirrors `openapi.yaml`; Newman runs in CI as black-box staging smoke, independent of the app's generated client (catches issues shared codegen would mask); doubles as QA's manual exploration surface |
| Load | k6 | PF-020..025 semester-start scenarios |
| Chaos | fault-injection harness (staging) | Portal 5xx/latency, DB failover, Pub/Sub delay, Redis/PgBouncer restart — assert IRR §2/§7.4 ladders |
| Security | analyzer, osv-scanner, Trivy, gitleaks, sqlmap (pentest) | SAST/deps/secrets + adversarial |
| Orchestration | **GitHub Actions** | pipeline §14 |

**Pipeline (quality view; build/release detail in Standards §11.2):**
```
PR → format · analyze(strict) · custom-lints(import matrix, token/duration literals,
       ARB coverage, flag+error registries, no print/$queryRawUnsafe)
   → dart unit+widget+golden(0-diff) · backend unit+integration(testcontainers)
   → API contract(OpenAPI validate always-on) · affected RG suites(path-triggered)
   → coverage ratchet(per-module §4) · SAST/deps/secrets
merge-queue → full suite + client integration(patrol farm) + Newman staging smoke
release/*   → RG-CRIT · RG-PERF · RG-SEC · RG-AX · k6 load · chaos smoke
tag         → staged rollout gated on Sentry release health (Standards §11)
```

---

# Section 14 — CI/CD Quality Gates (pass/fail rules)

| Gate | Pass | Fail (blocks) |
|---|---|---|
| Format | `dart format` + backend prettier clean | any diff |
| Lint / static analysis | analyzer strict, 0 warnings; custom-lints pass (import matrix §Std-3, no literal tokens/durations, ARB coverage, flag+error registries synced, no `print`/`$queryRawUnsafe`) | any violation |
| Coverage | per-module ratchets §4 met; DiffEngine/ConflictResolver/PrefsResolver/parsers at their 100% bars | any module below gate, or overall below last-week actual |
| Golden tests | 0-diff vs baseline (or updated + design-approved for token PRs) | any unreviewed diff |
| Unit tests | 100% pass | any fail |
| Integration | backend testcontainers + client patrol 100% pass | any fail |
| Contract | OpenAPI validation clean; generated client compiles; `openapi-diff` no unversioned breaking change on /v1 | drift or breaking change |
| Performance | RG-PERF budgets met on farm (release train) | any budget exceeded (>20% = hard block even with waiver) |
| Security scan | no HIGH/CRITICAL CVE; no leaked secret; SAST clean | any HIGH+ |
| Accessibility scan | AX FA guards green (tap/contrast/semantics/reduce-motion) | any failure |
| Deployment approval | prod promotion: ENG lead + PM (GitHub Environments); beta health gate crash-free ≥99.5%/48h | missing approval or failed health gate |

**Waiver protocol:** only P2/P3 non-R1 items are waivable, by EM, time-boxed with a tracking ticket referenced in the waiver (recorded in `docs/waivers/`). **R1-area gates (auth, sync, notification, data-loss, security) are never waivable.**

---

# Section 15 — Test Documentation

## 15.1 Master Test Plan (maintained in `docs/qa/`)
Scope (this corpus) · quality objectives (§1) · RTM (§2, living — CI-checked: every test ID must appear in the registry, every FR must map to ≥1 test) · pyramid & ownership (§3) · environments (dev fixtures / staging synthetic-Portal / device farm) · entry–exit criteria per phase · schedule aligned to release trains · risk register (§1.6) · sign-off roster (= the Standards §17 gate owners).

## 15.2 Test matrix (dimensional coverage grid)
Generated from the test registry + RTM so uncovered cells are *visible, not guessed*. Axes — client: `{screen × state(Loading/Data/Empty/Failure) × theme(L/D) × locale(zh/en) × text(1.0/1.3/AX3) × layout(phone/tablet × portrait/landscape)}`; API: `{endpoint × (happy / each-error-code / authz-probe / validation-reject)}`; sync: `{case × (fixture / canary)}`. A blank cell in the generated grid is a CI warning, not a silent hole.

## 15.3 Edge cases (consolidated from every document's edge lists — each is a test)
Portal down/maintenance (S7) · wrong credentials · expired mid-sync · multi-role account · course add/drop mid-semester · cross-listed/duplicate courses · no-due-date assignment · email-only assignment (manual-add path) · overlapping deadlines · holiday-cancelled class · biweekly lab · zero-class day · new-user no-data · 10+ item day · reorder-vs-smart-default · stale note 30d · long-note truncation · wifi↔cellular mid-edit · notification cluster digest · notifications fully disabled · deadline change post-schedule · traveling-student timezone · semester date change · summer/non-standard term · withdrawal mid-semester · exam same-day cluster · exam rescheduled · exam not-yet-posted · manual completion of Portal-incomplete item · hidden-then-unhidden assignment · different-student-ID on shared device · SQLCipher key loss · crash-loop → safe mode. (Each maps to an ID in §5/§7/§8/§10; this list is the completeness cross-check against the corpus.)

## 15.4 Failure-recovery tests (chaos-driven, §12 RG-PERF/chaos)
Portal 5xx storm → breaker opens → cached-honest serving → auto-recover + backfill · DB failover → API cached reads → reconnect no-error-burst · Pub/Sub delay → dispatch-lag alarm → zero double-send · worker crash mid-category → redelivery idempotent (hash no-op) · poison message → DLQ + alert · parser drift → safe mode → parser deploy → exit + P2 backfill (IRR §4.4) · crash-loop → recovery mode still renders deadlines (Standards §8.5) · SQLCipher key mismatch → explicit reset-and-resync, never auto-wipe.

## 15.5 Acceptance Test Plan
The RTM `AT-*` rows are the acceptance suite (automated). **UAT** with the PRD Phase-1 pilot cohort executes scripted *real-Portal* flows fixtures cannot cover: real login + 2FA, course/assignment fidelity vs the live Portal, notification timing observed over multiple days, offline behavior on real campus dead zones. UAT exit criteria: pilot self-reported missed-deadline rate trending down vs baseline (PRD success metric) + zero S1/S2 over 2 weeks + notification opt-out <10% in-cohort.

## 15.6 Release checklist
- [ ] RG-SMOKE + RG-CRIT + RG-PERF + RG-SEC + RG-AX green on the release build
- [ ] Crash-free sessions ≥99.5% over 48h beta; zero open S1/S2; S3 ≤10 with PM sign-off
- [ ] Real-Portal manual script passed (login+2FA, sync fidelity, notification timing)
- [ ] A11y manual pass on 5 hot screens (TalkBack + VoiceOver)
- [ ] Migrations expand-phase-safe; rollback = traffic-shift verified; feature flags at intended state; kill-switches reachable
- [ ] Store metadata/localization/symbol upload done; open items (F-1, D-3, P-2) resolved or explicitly deferred with named owner

## 15.7 Go / No-Go checklist (release meeting — all owners present)
GO requires **unanimous**: QA (suites + gates green), Eng (no known S1/S2, rollback ready), Design (goldens + a11y signed), Security (scan clean, pentest deltas triaged), PM (AC met, open items dispositioned), SRE/DevOps (monitoring + alerts live, on-call staffed, DR drill current). Any NO-GO → documented reason + remediation owner + next window. The ability to disable each shipped feature via kill-switch (Standards §10) is verified reachable *before* GO — post-release disable capability is itself a release precondition.

## 15.8 Bug Severity Matrix · 15.9 Bug Priority Matrix
Single source: §1.7 / §1.8 (not duplicated). Triage SLA: **S1** → immediate incident (Backend Arch §14) + P0; **S2** → same-day triage, current train; **S3/S4** → weekly grooming. Every production S1/S2 gets a postmortem feeding a permanent RG-CRIT regression test (§12 growth rule) — **a shipped S1/S2 becomes a suite member so it can never recur silently.** This closes the loop between production reality and the test suite: the suite is not static coverage, it is an accumulating memory of every way the system has ever hurt a user.

---

*End of Software Quality Specification v1.0 — the official QA handbook. Every PRD requirement (FR-1..21, §5.1–5.16) is traced to executable tests (§2); the two non-testable product metrics (D30/NPS retention, adaptive-ML frequency) are instrumentation-owned and named (§1.1-3). Implementation proceeds under §14 gates; releases under §15.6–15.7. Open cross-document items carried unchanged: F-1 (WebView cookie spike), D-3 (design addendum for Center/health screens), P-2 (analytics consent copy).*
