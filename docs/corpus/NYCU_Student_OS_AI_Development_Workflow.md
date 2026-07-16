# NYCU Student OS — AI Development Workflow
## Version 1.0 — The AI-Assisted Engineering Operations Handbook
**Authority:** Principal Software Architect · Principal Engineering Manager · Staff Flutter Engineer · Staff Backend Engineer · Principal Software Quality Engineer · DevOps Lead · Technical Program Manager · AI Engineering Lead
**Status:** RATIFIED — the operational manual governing all AI participation in this project's development lifecycle
**Date:** July 2026

**Governing corpus (frozen — twelve documents):** PRD v1.1 · DS v1.0 · BA v1.0 · IRR v1.1 · DB v1.0 · BIS v1.1 · FA v1.0 · FES v1.0 · QS v1.0 · OPS v1.0 · **AI Coding Protocol v1.0** · **Bootstrap & Execution Plan v1.0**

**Relationship to the AI Coding Protocol:** the Protocol is the *constitution* — it defines what is law, what is forbidden (F1–F18), the precedence order, the STOP rule, and the Definition of Done. This handbook is the *operations manual* — it defines how work flows through that constitution day to day: what an agent reads before acting, how tasks are classified, how each workflow stage gates the next, how humans and agents divide judgment, and what artifacts every unit of work produces. **Where this handbook and the Protocol could ever be read differently, the Protocol wins** — this document operationalizes it and may not soften it.

Keywords MUST / MUST NOT / SHOULD / MAY per RFC 2119. Architecture is frozen; nothing herein redesigns, simplifies, or reinterprets any corpus decision.

---

# Section 1 — AI Development Philosophy

## 1.1 The role of AI (restated operationally)

1. **AI is an implementation assistant.** It translates frozen specifications into working, tested code and supporting artifacts (tests, docs, reports). It accelerates execution; it does not steer it.
2. **AI is never the source of truth.** The twelve corpus documents are. An agent's output is authoritative about nothing; it is a *proposal* that becomes real only when it passes CI gates and human review. An agent's memory, prior conversation, or training knowledge is never a substitute for reading the corpus (Protocol §11.1).
3. **AI must never invent behavior** (Protocol §1.3). Operationally: any line of generated code whose behavior cannot be traced to a corpus citation is treated in review as a defect, even if it works.
4. **AI must never change requirements.** Requirement changes are human governance acts on the owning document (Protocol §11.3). An agent MAY draft an amendment; it MUST NOT enact one in code.
5. **AI must never optimize architecture unless explicitly requested** — and because the architecture is frozen, an "explicit request" for architectural optimization is itself an escalation trigger: the agent responds by drafting an ADR / spec-amendment proposal (FES §16, Protocol §11.3), never by restructuring code first. Local, behavior-preserving code quality within a layer is not "architecture" and is governed by the refactoring workflow (§11).

## 1.2 Engineering principles for AI participation

| Principle | Operational meaning |
|---|---|
| **Cite or stop** | Every non-trivial decision carries its corpus citation (Protocol §1.5); a decision with no citable authority triggers the STOP rule (Protocol §1.6). Citation is how "read the spec" becomes verifiable. |
| **Smallest complete unit** | An agent delivers the smallest unit that satisfies the Definition of Done at its layer (Protocol §9) — never a sprawling multi-feature change, never a fragment without its tests. Small-and-done beats large-and-almost. |
| **Tests travel with code** | Test generation is not a later stage; it is part of generation (Protocol §5.3). Workflow stage 6 (§4) *verifies completeness* of tests authored during generation — it never begins them. |
| **Deterministic outputs** | Two competent agents given the same task and corpus MUST converge on behaviorally identical implementations. Divergence signals invention. Templates (§6), reading matrices (§2), and mechanical lints exist to force this convergence. |
| **Human accountability** | Every merged line has a human owner (the PR author/approver). "The AI wrote it" is never an accountability answer; the operator who directed the agent owns the output. |
| **Context is ephemeral; the corpus is memory** | Nothing decided only in a chat session exists. Session outputs that matter (decisions, reports, amendments) are written into the repo per §14; the next session starts from documents, not recollection. |
| **Escalate early, escalate specifically** | A good escalation names the documents in tension, the exact sections, and 2–3 options with tradeoffs (Protocol §1.6). "This is unclear" is not an escalation; it is an unfinished reading assignment. |

---

# Section 2 — Document Reading Order (mandatory reading matrix)

**The rule:** an agent MUST NOT generate code before reading the required specifications for its task class. Reading is *proven* by the citations in the output — an output whose citations don't match the matrix row is rejected as unread work.

**Universal preamble (every task, no exceptions):**
1. AI Coding Protocol v1.0 (constitution — especially §2 precedence, §4 boundaries, §8 forbidden)
2. The deviation ledgers of every document the task touches (IRR §10.1 A1–A10, BIS §0, FA §0, FES ADR seeds)
3. The QS §2 RTM row(s) for the requirement being implemented (what must be proven)
4. The open-items status (F-1 / D-3 / P-2 / A4) if the task touches auth, Center/Health screens, analytics, or grades

**Task-specific reading matrix (read in the order listed — behavior before style, contract before implementation):**

| Task | Mandatory reading order (specific chapters) |
|---|---|
| **Creating a Flutter screen** | FA §12 (the screen's spec) → FA §2/§4/§5 (structure, DI, state) → FES §2/§3 (naming, imports) → DS Part 3/5 (visuals, components) → IRR Part 1 (the screen's interaction rows) + IRR §7/§8 (errors, empty states) → PRD §5.x (the feature's AC) → QS §5 (its WT-* tests) |
| **Creating a Flutter widget/component** | DS Part 5 (component spec) → FA §13 (component library entry) → FES §2/§6 (naming, tokens) → IRR §9 (motion) + IRR §8 (states) → QS §5 (golden/a11y dimensions) |
| **Creating a Riverpod controller** | FA §4/§5 (DI, state conventions) → FES §2 (naming) → the owning screen's FA §12 + IRR Part 1 rows → IRR §7 (failure mapping) → QS §4 (controller test gate) |
| **Creating a client repository** | FA §9.1 (the interface) → FES §5 (component split: mapper/outbox/resolver) → IRR §6.4/6.5 (outbox, conflict) → DB §7 (server shapes it mirrors) → QS §4 (coverage) |
| **Creating a backend endpoint** | BIS §5 (the endpoint row — the contract) → BIS §1 (module/validation/authz rules) → DB §5/§7 (indexes, schema) → BA §6 (gateway/rate limits) → IRR §7 (error codes) → PRD §5.x → QS §6 (API-* tests) |
| **Creating a backend service/use-case** | BIS §1.2/§3/§4 (module, provider contracts) → BA §7/§8 (engine principles) → IRR Part 2 (state machine) → QS §4 |
| **Creating a Prisma migration** | DB §7 (canonical DDL) → DB §8 (expand/migrate/contract discipline) → DB §3 (table conventions) → IRR Part 13 deltas → Bootstrap Phase B |
| **Creating a Drift table/DAO** | FA §9.2 (store roles) → DB §7 (server shape being mirrored) → IRR §6.2 (cache scope) → FES §13 (offline encryption) |
| **Sync engine change** | IRR Part 2 (state machine) + Part 4/13 (drift, page health, category isolation) → BIS §3 → BA §7 → DB §3.5/§5 → QS §8 (SY-* cases) → OPS RB-1/RB-2 (operational consequences) |
| **Notification change** | BIS §4 (pipeline) → IRR §1.8 (interactions) + §7 (codes) → PRD §5.4/§5.15 (FR-4/15/19) → DB §3.4 (schema) → FES §7 (analytics events) → QS §6 (API-040..) + RG-NOTIF |
| **Parser / Portal-facing change** | IRR §4 + §13.1 (version detection, page health, sanity gates) → BIS §1.1/§3.6 (parser module, safe mode) → OPS RB-1 → QS §4 (fixture gates) — **R1: senior review mandatory (CODEOWNERS)** |
| **Error-handling change** | IRR §7 (the matrix — the contract) → BIS §1.9 (exception classes) → FA §15 (client rendering) → QS §7/§12 (test + suite impact) |
| **Offline / outbox change** | IRR Part 6 (the whole contract) → FA §9.3 → FES §5 (outbox/resolver split) → QS §7 (OF-* cases) |
| **Analytics change** | FES §7 (architecture, schema, privacy allowlist) → PRD §12 (ownership promises) → P-2 status → QS SEC-031/032 |
| **Security-sensitive change** (auth, cookies, storage, crypto) | PRD §5.1 + IRR A1/A2 + Part 3 → BIS §2/§7 → FES §13 → DB §11 → QS §10 (SEC-*) — **R1** |
| **Writing tests** | QS §3 (level selection) → QS §4–§11 (the relevant suite's cases + IDs) → FES §17-gate patterns → the feature's own specs (the oracle) |
| **CI/CD or infra change** | FES §11 + QS §13/§14 (pipeline, gates) → OPS §1–§3 (topology, deploy) → Bootstrap §1/§3 |
| **Documentation change** | Protocol §11.3 (amendment governance) → the owning document + its ledger → FES §16 (ADR) if decision-bearing |

**Depth rule:** "read" means the cited chapters, not the whole corpus per task — the matrix exists precisely so agents read *deeply and narrowly*. When a read chapter references another section for a decision the task needs, that reference is followed (transitive reads are part of the assignment).

---

# Section 3 — Task Classification

Every incoming request is classified before any work begins; classification selects the reading matrix row (§2), the workflow variant (§4/§10/§11/§12), and the approval bar. Misclassification is itself a review finding.

| Category | Required inputs | Required outputs | Required tests | Approval requirements |
|---|---|---|---|---|
| **New feature** | DoR-complete issue (QS §1.2): corpus citations, AC as testable statements, reserved QS test IDs, error codes, flags/analytics/a11y impact | Vertical slice per Protocol §5 order; FES §4 checklist; ARB, tokens, analytics, semantics; MANIFEST update | Full layer set: unit (gate per QS §4) + widget state-matrix + goldens + integration; RTM updated | PR review (1+); R1 areas → CODEOWNERS senior review; flag creation → owner+expiry set |
| **Bug fix** | Bug issue with severity (QS §1.7), repro, expected-vs-actual **with corpus citation** (what the spec says should happen) | Minimal fix + §10 workflow artifacts (RCA, regression test, docs) | **Regression test that fails before / passes after** (mandatory, no exceptions); S1/S2 → permanent RG-CRIT member | S1/S2: EM visibility + postmortem; S3/S4: standard review |
| **Refactor** | §11 classification (safe/risky/forbidden) + dependency impact analysis | Behavior-identical code; import-lint clean; no public-contract change (or it's not a refactor) | Existing tests green *unchanged* (the definition of behavior-preserving); characterization tests first if coverage is thin | Safe: standard review. Risky: architect sign-off + plan. Forbidden: rejected (→ escalation/ADR) |
| **Performance optimization** | The failing PF-* budget (QS §9) + profile evidence (never optimize on intuition) | Fix + before/after measurements on the reference protocol | PF benchmark re-run proving budget met; no behavior change (existing suites green) | Standard review; budget-definition changes → EM (budgets are ratchet-only) |
| **Accessibility improvement** | The failing AX-* item or audit finding (QS §11) | Fix within token/semantics systems (never per-widget hacks) | AX guideline asserts + goldens (incl. AX3/reduce-motion variants where relevant) | Standard; a11y-standard changes → a11y owner |
| **Localization** | ARB key list + context (screen, placeholder needs) | zh-TW + en entries (zh-TW is template); no concatenation; `intl` formatting | ARB-diff CI green; goldens ×2 locales for layout-sensitive strings | Copy tone: design/PM spot-check (IRR copy tables are already final — new copy only for new features) |
| **Migration** | DB §7 target shape + DB §8 discipline; down-consequence analysis | Expand-phase migration (Prisma or raw-SQL step); header documentation | Migration applies to fresh DB + rollforward test; affected integration suites | **Always human-reviewed by backend lead**; destructive steps → rehearsed down-script + snapshot note |
| **Testing** (adding/repairing tests) | QS suite + test IDs; the spec table being encoded | Tests carrying QS IDs; registry/RTM updated | The tests themselves (meta: flake-checked ×20 runs locally for new integration tests) | Standard; quarantine actions → QA lead |
| **Documentation** | Owning document + ledger; Protocol §11.3 if spec-amending | Amendment PR: version bump, ledger entry, cross-ledger updates, RTM/test impact in same change | n/a (CI checks: links resolve, RTM consistency) | **Spec amendments: architect + EM (governance act)**; non-normative docs: standard |
| **Infrastructure** | OPS §1–§3 topology + Terraform state awareness | Terraform PR; alert policies with the feature; runbook delta if behavior-visible | Plan output reviewed; staging apply before prod | SRE owner; prod apply → deployment-approval environment |
| **Security** | The SEC-* item / finding; FES §13 + BIS §7 standards | Fix + scrub/redaction tests where applicable | SEC regression + full RG-SEC on release | **Security owner sign-off always; never waivable (QS §14)** |

**Risk-class modifier (applies across categories):** any task touching R1 areas (auth/cookies, sync correctness, parser, notification delivery, data deletion — QS §1.6) escalates its approval row: senior/CODEOWNERS review is mandatory, gates are non-waivable, and the agent's implementation plan (§4 stage 3) MUST be human-approved *before* code generation, not after.

---

# Section 4 — AI Prompt Workflow (the nine-stage pipeline)

Every development request flows through these stages **in order**. Each stage ends with a mandatory checkpoint; failing a checkpoint returns the work to the earlier stage — never "fix it later." For small tasks the stages compress in *effort*, never in *order* or *checkpoints*.

| # | Stage | The agent does | Mandatory checkpoint (gate to next stage) |
|---|---|---|---|
| 1 | **Input** | Classify the task (§3); restate the request in its own words *with* the governing corpus sections; identify the QS RTM row | ✋ Classification + citations confirmed by the operator; if the request contradicts the corpus → STOP (Protocol §1.6), do not proceed |
| 2 | **Architecture Review** | Read per the §2 matrix; verify the task fits existing boundaries (Protocol §4); check deviation ledgers for prior adjudications | ✋ Agent states, in one paragraph, *where* the change lives (layers/modules) and *why* that placement is corpus-correct — with citations |
| 3 | **Dependency Analysis** | Enumerate: upstream contracts consumed (interfaces, DTOs, tables, tokens, ARB), downstream consumers affected, open items (F-1/D-3/P-2/A4) blocking, migration/flag/analytics needs | ✋ Dependency list complete; anything blocked-on is surfaced NOW (a dependency discovered during generation = a stage-3 failure) |
| 4 | **Implementation Plan** | Ordered file-by-file plan following Protocol §5 sequence; per file: what, which contract, which tests; flags/rollout noted | ✋ Plan reviewed — **by a human for R1/risky tasks (mandatory pre-approval)**, self-checked against Protocol §5 order otherwise. No plan, no code. |
| 5 | **Code Generation** | Implement per plan, tests authored *with* each unit (Protocol §5.3), citations inline where non-obvious | ✋ Compiles; lints clean (import matrix, tokens, ARB, registries); every §3-required output present |
| 6 | **Self Review** | Full §7 checklist, honestly — the agent is its own first reviewer and reports failures rather than hiding them | ✋ §7 checklist output attached (the filled checklist, not "done ✓"); any unresolved item blocks |
| 7 | **Test Generation (verification)** | *Verify completeness* of the tests authored in stage 5 against the QS matrix: every reserved ID implemented, coverage gates met, state-matrix/error-code/authz coverage present. Author any gap found — a gap here is a stage-5 defect being repaired | ✋ All reserved QS IDs green locally; coverage ratchet satisfied; new IDs registered |
| 8 | **Documentation Update** | ARB entries, MANIFEST, ADR (if triggered), corpus amendment draft (if a spec defect surfaced — human ratifies), runbook delta (if operationally visible) | ✋ Docs list complete per §3 category row; traceability line drafted for the PR |
| 9 | **Completion Report** | The §17.4 Implementation Report: what was built, citations, tests, deviations-escalated, follow-ups | ✋ Report attached to PR; PR template (§Bootstrap 1.7) fully satisfied → hands off to Human Review (§8) |

**Checkpoint discipline:** checkpoints are cheap on purpose — one paragraph, one list, one filled checklist. Their value is *ordering*: they make invention visible at stage 2–3 (where it costs a conversation) instead of stage 9 (where it costs a rewrite).

## 4.1 Context Budget & Task-Splitting (the single-prompt scope law)

A single prompt must fit inside a bounded working set. The reason is not style but *correctness*: an agent whose working context exceeds what it can hold coherently begins to lose track of the contracts it is implementing against — and a context-starved agent is exactly the condition under which plausible invention (Protocol §1.3) becomes most likely. Small, bounded tasks are therefore not a convenience; they are the operating condition under which the constitution's guarantees hold.

**Per-prompt scope budget — a single prompt SHOULD satisfy ALL of:**

| Dimension | Soft limit (per prompt) |
|---|---|
| Source files touched | ≤ 10 |
| Generated lines of code | ≤ 1,500 LOC |
| Feature scope | ≤ 1 feature |
| Migrations | ≤ 1 migration |
| OpenAPI / contract changes | ≤ 1 change |

**If a task, at planning (§4 stage 4), is projected to exceed any soft limit → STOP and SPLIT** before generating code. Splitting follows §15.4: divide at **contract seams, never mid-layer** — e.g., `(migration) → (repository+tests) → (service+tests) → (endpoint+contract) → (controller+providers) → (screen+widgets+goldens) → (integration)`, each a mergeable unit meeting the Definition of Done at its layer (Protocol §5). The split is declared in the stage-4 plan as an ordered task list; each sub-task is then its own prompt. A task that "feels too big to plan" has already exceeded the budget — that feeling is the signal to split, not to push on.

**Hard mid-implementation abort — an agent MUST stop, even mid-task, if generation reaches ANY of:**

| Dimension | Hard limit (abort threshold) |
|---|---|
| Elapsed implementation time | 90 minutes |
| Generated lines of code | 2,500 LOC |
| Modified files | 25 files |

On hitting a hard limit the agent MUST NOT push to "just finish": it **stops at the nearest safe boundary** (a completed layer with green tests — never mid-layer with a broken contract), **generates the §17.4 Implementation Report** capturing exactly what was completed, what remains, which contracts are settled vs pending, and the ordered remaining sub-tasks, then **starts a new session** for the continuation. The report is the handoff (§15.2) — the next session resumes from it and the corpus, never from the exhausted context window.

**Why the two-tier design (soft budget vs hard abort):** the soft budget is evaluated *before* coding, at planning, where splitting is free; the hard limits are the safety net for tasks whose true size was underestimated, catching runaway generation *during* execution before context degradation corrupts the output. A prompt that respects the soft budget almost never reaches a hard limit — hitting a hard abort is itself a signal that stage-4 planning under-scoped, which the Implementation Report notes as a lesson (§13) so future estimates improve. Neither limit is ever "worked around" by generating terser code or skipping tests to fit — that trades a scope violation for a quality violation, which is worse.

---

# Section 5 — Code Generation Rules (mandatory implementation sequence)

The canonical sequence is the AI Coding Protocol §5 (backend §5.1, client §5.2) — reproduced here as the unified ladder the workflow enforces. **An agent MUST NOT skip an intermediate layer**, even when the skipped layer "would be trivial": trivial layers are where contracts live, and skipping one forces a downstream assumption (Protocol F14).

```
Models / Entities        (domain truth: freezed entities / Prisma models — DB §7, FA domain)
   ↓
DTOs                     (wire shapes from OpenAPI; zod schemas — BIS §1.11; never leak upward)
   ↓
Database                 (migration expand-phase / drift table+DAO — DB §8, FA §9.2)
   ↓
Repository               (interface first, then impl — FES §5; the only door to data)
   ↓
Service / Use-case       (business orchestration; transaction boundaries — BIS §6.3)
   ↓
Controller               (HTTP surface / Riverpod controller — validation, failure mapping)
   ↓
State Management         (providers wired per FA §4/§5; optimistic mutations, watch reads)
   ↓
UI                       (screens/widgets: render + forward intents; tokens/ARB/semantics only)
   ↓
Tests                    (VERIFICATION stage — tests were authored per layer above; here the
                          set is completed against QS: goldens, integration, a11y dimensions)
   ↓
Documentation            (MANIFEST, ARB, ADR, report — §4 stages 8–9)
```

**Sequence invariants (operational form of Protocol §5.3):**
1. A layer is entered only when the layer below is implemented *and its tests pass* — the foundation is proven, not assumed.
2. Interfaces precede implementations (repository interface before impl; OpenAPI row before controller) — consumers code against contracts, never against code.
3. If a later layer reveals an earlier contract is wrong, work STOPS and the contract is revised deliberately (visible, cited, re-approved) — never widened ad-hoc from below.
4. Cross-cutting obligations (ARB, tokens, analytics, semantics, error mapping, flags) attach at the layer where they live and are checked at every checkpoint — they are not a final coat of paint.

# Section 6 — Prompt Templates (the official library, extended)

The AI Coding Protocol §7 defines the canonical **common CONSTITUTION block** and eight templates: *create a repository · create a feature · add an endpoint · add Riverpod providers · add widget tests · add backend tests · add integration tests · add migrations*. Those remain canonical and are NOT restated here. This section **extends the library** with the remaining official templates. Every template below implicitly begins with the Protocol §7 CONSTITUTION block; each is reusable without modification — operators fill only the `<brackets>`.

### 6.1 Create a Riverpod controller
```
[CONSTITUTION]
TASK: Implement <Name>Controller for <screen/purpose> per FA §4/§5.
STATE SHAPE: sealed UiState set for this screen (FA §12.<n>) — enumerate variants first.
READS: combine drift StreamProviders only; no direct core/db|core/network imports (§4.1).
MUTATIONS: optimistic (local commit → outbox) — method returns on local tx; NEVER await network.
FAILURES: map every path to AppFailure (IRR §7 codes for this feature — list them).
DISPOSAL: autoDispose unless in the FA §4 keep-alive set — justify any keep-alive in a comment.
TESTS (same change): state transitions per variant; failure mapping per code; the
no-network-await invariant (fake repo asserts no API call before local commit). Gate 90% (QS §4).
```

### 6.2 Create a screen
```
[CONSTITUTION]
TASK: Implement <Screen> per FA §12.<n> (route, providers, widget tree) and its IRR Part 1 rows.
PREREQUISITES (verify, do not create here): repository + controller exist and are tested (§5 order).
RENDER: sealed-state switch, exhaustive; skeleton shape per FA §12.<n>; Empty/Failure copy from
IRR §8.3/§7 via ARB. Components from shared_widgets/ before any bespoke widget.
STYLING: tokens only; layout-class adaptive via AdaptiveScaffold slots (FA §8).
A11Y: semantics on all interactives; traversal order = visual; announcements per IRR phrasing.
ANALYTICS: screen_viewed + the feature's registered events (FES §7.2) — registry first.
TESTS (same change): WT-* state matrix + interaction rows; goldens (theme × locale × scale set).
```

### 6.3 Create a widget (shared component)
```
[CONSTITUTION]
TASK: Implement <Component> in shared_widgets/ per DS Part 5.<n> and FA §13 row.
VARIANTS: constructor enums exactly as the FA §13 row lists — no boolean soup, no subclassing.
STYLING: tokens only (colors/spacing/radius/motion); both themes verified; RTL-safe.
MOTION: Motion.of(context) tokens; Reduce-Motion path included (IRR §9.4).
A11Y: semantics label required (constructor param if content-dependent); tap ≥44 incl. hit-slop.
TESTS (same change): goldens full variant grid × light/dark × zh/en (+ scale set if text-bearing);
guideline asserts. A component PR without goldens is incomplete (FES §12).
```

### 6.4 Create DTOs
```
[CONSTITUTION]
TASK: Define DTO(s) for <endpoint/entity> from contracts/openapi/openapi.yaml — the YAML is the
source; DTOs are generated or transcribed 1:1, never designed here.
BACKEND: zod schema `.strict()` (reject unknown); nullability exactly per DB §7 / BIS §5 row.
CLIENT: generated Dart client types stay in data/; a mapper converts to domain entities (FES §5) —
DTOs never cross into domain/ (Protocol §4).
TESTS: mapper round-trip + total-function behavior (unknown enum → documented fallback, no throw).
IF the YAML lacks the shape you need → STOP: that is a contract change (BIS §12.2 governance).
```

### 6.5 Create a Drift table/DAO
```
[CONSTITUTION]
TASK: Add drift table + DAO for <aggregate> per FA §9.2 store roles.
SHAPE: mirror the server read-model subset (DB §7 columns the client renders) + client-only
columns (sync_meta cursor linkage) — cite the DB table you mirror.
DAO: watch* queries matching the repository read surface (FA §9.1) with LIMIT; upsertAll for
DeltaApplier; no business filtering beyond spec'd query shapes (FES §5).
ENCRYPTION: table lives in the SQLCipher DB — no sensitive field may relocate to Hive/SP (FES §13).
MIGRATION: drift schema version bump + migration step; client_schema_version interplay
(offline_cache_metadata → full re-seed path) noted.
TESTS: DAO integration vs in-memory drift — query shapes, watch emissions distinct(), upsert idempotency.
```

### 6.6 Create a backend service
```
[CONSTITUTION]
TASK: Implement <Name>Service per BIS §<n> provider contract.
BOUNDARIES: orchestrates repositories; owns transaction boundaries (BIS §6.3 — cite which row);
never builds SQL, never parses wire shapes, never reaches other modules except exported
interfaces or domain events (BIS §1.1). Events publish AFTER commit.
ERRORS: throw registered AppException codes; classify Transient vs Permanent for worker paths (BIS §1.9).
TESTS (same change): unit w/ repository fakes per QS §4 gate; if the service owns a spec table
(resolver/materializer class), the table IS the matrix at 100%.
```

### 6.7 Create golden tests
```
[CONSTITUTION]
TASK: Golden coverage for <component/screen> per QS §5 dimensions.
TOOL: alchemist; baselines under mirrored goldens/ path; CI diff threshold 0.
GRID: full variant grid × light/dark × zh-TW/en; text scale 1.0/1.3 (+AX3 for Dashboard/Tasks);
disableAnimations variant where motion-bearing.
DISCIPLINE: deterministic fixtures (frozen clock, seeded data — no now()); fonts loaded; no
network/timers. Baseline updates are deliberate commits, design-approved for token changes (FES §6).
```

### 6.8 Create accessibility tests
```
[CONSTITUTION]
TASK: A11y verification for <screen> per QS §11.
IN every screen test (not a skippable suite): tapTargetGuideline (both platforms),
textContrastGuideline, semantics presence for all interactives.
ADD: semantics-tree snapshot (labels, order = visual via sort keys where layout diverges);
announcement asserts (IRR §7 checkbox phrasing, sync live-region); FocusNode order + Escape-dismiss
+ focus-return for keyboard paths (AX-007).
GOLDENS: AX3 + reduce-motion variants per §6.7 grid.
```

### 6.9 Create documentation
```
[CONSTITUTION]
TASK: Documentation for <change>.
CLASSIFY first: (a) non-normative (README/onboarding/runbook delta) → write directly;
(b) SPEC-AMENDING → you may DRAFT only: owning doc + version bump + deviation-ledger entry +
cross-ledger updates + RTM/test impact in ONE governance change (Protocol §11.3); humans ratify.
NEVER: document behavior the code has that the spec lacks — that is laundering invention (F17);
the mismatch goes to escalation instead.
STYLE: match the owning document's conventions (tables, citation density, RFC keywords).
```

### 6.10 Review existing code
```
[CONSTITUTION]
TASK: Review <PR/files> as first reviewer.
METHOD: run the §7 self-review checklist against the diff as if you authored it; then §9 domain
checklists for the affected areas. For every finding: cite the corpus/handbook rule violated,
severity (blocking vs advisory), and the minimal fix.
SPECIAL DUTY: hunt UNCITED BEHAVIOR — any logic whose expected behavior you cannot trace to a
corpus section is flagged as possible invention (Protocol §1.3) regardless of correctness.
OUTPUT: §17.2 review template, findings ordered by severity. You approve nothing — humans approve.
```

### 6.11 Refactor existing code
```
[CONSTITUTION]
TASK: Refactor <target> — goal: <readability/duplication/structure>, behavior IDENTICAL.
CLASSIFY per §11 first (safe/risky/forbidden) and state the classification with reasoning.
PRECONDITION: existing tests green before AND after, UNCHANGED (the behavior-preservation proof);
if coverage is thin, write characterization tests FIRST, then refactor.
SCOPE: within layer boundaries; no public-interface change (that's not a refactor); no spec'd
behavior "improvement" (F17). Import-lint clean after.
OUTPUT: diff + test evidence + §11 classification note. Risky class → plan awaits human approval
BEFORE code.
```

### 6.12 Fix a bug
```
[CONSTITUTION]
TASK: Fix <bug ref> (severity S<n>).
FOLLOW §10 workflow strictly: (1) RCA — 5-whys to root cause, not symptom; (2) SPEC VERIFICATION —
what does the corpus say SHOULD happen (cite it)? If the spec is silent/wrong → STOP, this may be
a spec defect not a code bug; (3) minimal fix at the root; (4) REGRESSION TEST that fails-before/
passes-after (mandatory — the fix without the test is incomplete); S1/S2 → RG-CRIT membership;
(5) §10 artifacts (docs, incident mapping, lessons).
NEVER: fix the symptom (catch-and-suppress), widen a contract to make the bug unrepresentable
without escalation, or "fix" behavior the spec actually mandates.
```

### 6.13 Performance optimization
```
[CONSTITUTION]
TASK: Bring <metric> within budget <PF-* / value> (QS §9).
PRECONDITION: profile evidence identifying the actual hotspot (DevTools timeline / EXPLAIN ANALYZE /
k6 output) — no intuition-driven optimization.
CONSTRAINTS: behavior identical (all suites green unchanged); architecture frozen — if the fix
requires a boundary change, STOP → escalation/ADR; standard levers first (FA §16 / DB §10.3:
builder lists, select() scoping, index/covering query, cache invalidation correctness).
OUTPUT: before/after measurements on the SAME protocol (QS §9 method column), the fix, and a
one-paragraph explanation of why the hotspot existed.
```

---

# Section 7 — AI Self Review (the exhaustive pre-return checklist)

Executed at workflow stage 6 (§4). The agent attaches the *filled* checklist — item-by-item verdicts, not a summary "✓". Any ❌ blocks return; any "N/A" carries a one-clause justification. This extends Protocol §10 with the operational verify-questions.

| Domain | Verify (every question answered) |
|---|---|
| **Architecture compliance** | Change lives in the layer the plan named? Import matrix clean (mechanically: lint)? No repository bypass, no cross-feature import, no invented cross-layer channel (F1–F4, F16)? Development order followed (§5)? |
| **Coding standards** | FES §2 naming table satisfied (files, classes, providers, enums)? One public type per file? No Manager/Helper/Utils? `dart format`/prettier clean? |
| **Naming consistency** | New names consistent with the aggregate's existing vocabulary (PRD ubiquitous language — Assignment≠Todo≠Event)? ARB keys namespaced per convention? |
| **Layer boundaries** | Domain still pure Dart? DTOs confined to data/? Controllers free of dio/drift/Prisma? Events published post-commit only? |
| **Error handling** | Every failure path mapped to a registered code (IRR §7)? No bare catch? Transient/Permanent classified on worker paths? User copy from the matrix via ARB? |
| **Logging** | Events dot-namespaced; ambient correlation (traceId/syncRunId) via context not hand-passing; ZERO content/PII fields (structural redaction respected)? Log level per FES §9.2 rules? |
| **Analytics** | Required events registered-then-fired? Params within the allowlist (enums/numbers/booleans only)? Exposure event for any flag variant surface? |
| **Localization** | Every user-visible string in ARB (zh-TW + en)? Placeholders not concatenation? intl formatting with app locale? |
| **Accessibility** | Semantics labels on new interactives? Tap ≥44? Color-independent status signaling? Reduce-Motion path via Motion.of? Contrast via tokens only? |
| **Performance** | Lists builder-based (+extent where fixed)? select() scoping on wide providers? const where possible? No work in build()? Queries LIMITed and index-backed (cite the DB §5 index)? |
| **Memory usage** | autoDispose default honored (keep-alives justified)? Subscriptions/timers cancelled? Images sized (cacheWidth)? No unbounded caches introduced? |
| **Security** | No sensitive data outside the four stores' roles (FES §13)? No password/cookie/token/grade in any log/analytic/error? zod on every boundary? Parameterized queries only? Deep-link params validated? |
| **Offline support** | Mutations drift-first→outbox with baseVersion+idemKey? Screen renders from cache with airplane mode on (attested)? Server-dependent affordances degrade per IRR §6.3? |
| **Feature flags** | Flag-gated behavior actually gated? New flags registered with owner+expiresAt? Kill-switch fail-safe direction correct? |
| **Testing completeness** | Every reserved QS ID implemented and green? Coverage ratchets met (100%-modules at 100%)? State-matrix/error-code/authz coverage present? Tests assert invariants, not implementation? |
| **Documentation completeness** | Citations present for non-obvious decisions? MANIFEST/ADR/ARB updated per §3 row? Completion report drafted? Traceability line ready? |

---

# Section 8 — Human Review Workflow (the division of judgment)

## 8.1 Responsibilities

| Role | Owns |
|---|---|
| **AI agent** | Faithful implementation; stage checkpoints; self-review honesty; escalating instead of guessing; drafting (plans, tests, docs, reports, amendment proposals) |
| **Developer (operator)** | Directing the agent; validating stage-1/3 outputs; owning the PR (accountability — §1.2); running the attested checks (offline run, device checks) |
| **Reviewer** | §9 checklists on the diff; hunting uncited behavior; approving or returning; enforcing the PR template |
| **Architect** | Risky-refactor plans; ADR decisions; spec-amendment ratification; boundary/import-matrix changes; resolving escalated conflicts (Protocol §2.2 step 4) |
| **QA** | Suite membership; test-ID registry; flake quarantine; severity assessment; release-gate verdicts |
| **Product Manager** | Requirement/AC interpretation disputes; scope decisions; P-2/A4-class consent & scope items; priority (never severity) |

## 8.2 Decisions AI MAY make independently (within already-decided space)
- Variable/file/test naming *within* FES §2 conventions; test-case enumeration *from* spec tables; choosing among implementation options the corpus treats as equivalent (e.g., which zod combinator) — provided behavior is identical and cited.
- Mechanical refactors classified **safe** (§11) within one layer with green unchanged tests.
- Test additions that increase coverage without changing suites' semantics; documentation of the non-normative class (§6.9a).
- Ordering of work within the §5 sequence; splitting a task into smaller PRs at contract seams.

## 8.3 Decisions that REQUIRE human approval (always)
- Anything the STOP rule catches: spec ambiguity/conflict/silence; any behavior not derivable from the corpus.
- Spec amendments (architect+EM ratify — Protocol §11.3); ADR-triggering changes (import matrix, new dependency, store-role change, template change).
- Schema migrations (backend lead); contract changes to openapi.yaml or tokens.json (both leads — CODEOWNERS); new feature flags (owner+expiry assignment); analytics schema changes (privacy sign-off).
- R1-area merges (senior review); risky-refactor plans (architect, pre-code); anything security-classified (security owner, never waivable).
- Release/rollout decisions, waivers, milestone declarations — entirely human (OPS/QS governance).

**The line, stated once:** *AI decides how to express a decision the corpus already made; humans make every decision the corpus has not.* When classification is unclear, it is human by default.

---

# Section 9 — Code Review Checklist (anti-drift, per domain)

Applied by the reviewer (human, optionally pre-run by an agent via §6.10). Items marked ⚙ are CI-verified — the reviewer confirms the signal. The unifying question behind every domain: **"could this diff move the codebase away from the corpus without anyone deciding that?"** — that is drift, and drift is the primary target.

**Architecture** — placement matches an approved plan; boundaries ⚙; no new lateral channel; no god-object growth (repository/service scope still one aggregate); the diff cites its authority; **zero uncited behavior**.
**Backend** — BIS §5 contract untouched (or governed change); zod `.strict()`; tx boundaries per BIS §6.3; events post-commit; single-writer invariant intact (no academic-table writes outside worker role); idempotency preserved on redelivery paths; error registry ⚙.
**Flutter** — sealed-state exhaustive ⚙(compiler); optimistic mutation invariant (no network await); tokens/ARB ⚙; components from shared_widgets before bespoke; provider layering; disposal policy; deep-links still resolve.
**Database** — migration expand-phase; `CONCURRENTLY` ⚙; every new index has a named consumer (cited); conventions (updated_at trigger, RLS policy, soft-delete tier) applied; hot-query plans still index-backed ⚙(plan-guarantee suite); partition/retention impact considered.
**Security** — four-store roles respected; redaction tests still pass ⚙; no new secret surface; authz probe test present for new endpoints; pinning/KMS/IAM untouched or security-approved.
**Performance** — no unbounded query/list/cache; rebuild scope evidence for hot-screen changes; budgets unthreatened (or PF re-run attached); no polling added.
**Accessibility** — guideline asserts in new screen tests ⚙; semantics/labels; AX golden variants updated; reduce-motion path.
**Localization** — ARB both locales ⚙; no concatenation; locale-sensitive formatting; goldens ×2 locales where layout-sensitive.
**Testing** — QS IDs carried; fails-before/passes-after for bug fixes; invariants-not-implementation; no test deleted/weakened to make the diff pass (a weakened assertion is a blocking finding); flake risk assessed for new integration tests.
**CI/CD** — required checks unchanged or governance-approved; no gate softened; path-trigger mappings updated for new areas; workflow changes reviewed by SRE owner.
**Documentation** — MANIFEST/ADR/ledger/RTM updates present per §3 row; completion report attached; onboarding still true (if setup changed, README changed).

---

# Section 10 — Bug Fix Workflow

Eight steps, in order, no skipping. Artifacts accumulate in the bug issue and the PR.

1. **Root Cause Analysis** — reproduce deterministically first; then 5-whys to the *root* (an unmapped error path, a violated invariant, a missing test dimension), never the symptom. Output: one-paragraph RCA naming the mechanism.
2. **Specification Verification** — the pivotal step: *what does the corpus say should happen?* (cite). Three outcomes: (a) code diverges from spec → normal fix; (b) spec is silent → STOP, escalation (Protocol §1.6), possibly a spec amendment; (c) spec itself is wrong → spec-amendment path (§11.3 Protocol), the code fix follows the *ratified* amendment, never precedes it.
3. **Implementation** — minimal change at the root, via §4 stages (compressed effort, full order); no opportunistic refactoring in a bug-fix PR (separate PR, §11).
4. **Regression Tests** — a test that **fails on the pre-fix code and passes on the post-fix code** (both runs evidenced). Severity placement: S1/S2 → permanent RG-CRIT member (QS §12 growth rule); the test carries the bug ID in its name.
5. **Documentation Updates** — if the bug revealed a doc gap (missing edge in a spec table), the amendment is drafted; runbook delta if operational; FAQ/onboarding if developer-facing.
6. **Incident Mapping** — production bugs: link to the OPS incident (severity, timeline, MTTD/MTTR); confirm alerting *would* catch recurrence (if it didn't catch this one, an alert-gap action item is filed).
7. **Lessons Learned** — one honest paragraph: which defense failed (review? test dimension? lint? spec clarity?) and the *systemic* fix (a checklist item, a lint rule, a test dimension — §13), not "be more careful."
8. **Production Follow-up** — after deploy: verify the fix in production via the relevant dashboard/metric over an appropriate window; close the issue only on observed resolution, not on merge.

---

# Section 11 — Refactoring Workflow

## 11.1 Classification (mandatory first step — the agent states it with reasoning)

| Class | Definition | Requirements |
|---|---|---|
| **Safe** | Behavior-preserving, within one layer/module, public interfaces untouched, existing tests provide meaningful coverage | Green-unchanged tests before/after; import-lint clean; standard review |
| **Risky** | Crosses module seams, touches R1 areas, changes a *non-public* but widely-consumed contract, or coverage is thin | Characterization tests FIRST; written plan (scope, dependency impact, rollback) approved by architect BEFORE code; staged in reviewable slices; RG suite for the touched area |
| **Forbidden** | Changes observable behavior ("improving" spec'd behavior = F17); violates frozen architecture/boundaries; requires a spec or contract change; "refactor" that is really a redesign | Rejected as a refactor. The underlying desire routes to escalation → ADR / spec amendment; only after ratification does it become a (feature/migration) task |

## 11.2 Analysis obligations (before any risky refactor)
- **Dependency impact:** enumerate every consumer of the touched symbols (mechanical: find-usages + import graph); note test coverage per consumer; anything outside the module boundary → contract question → possibly forbidden-class.
- **Migration requirements:** does data shape, drift schema version, event payload, or client cache change? If yes: it is not a refactor — reclassify (migration task, §3) with expand/contract discipline.
- **Regression requirements:** the touched area's RG suite (QS §12) runs pre-merge; for thin coverage, characterization tests are written against *current* behavior first and MUST pass unmodified after.
- **Architecture verification:** post-refactor: import matrix ⚙, layer purity (domain still pure Dart), single-writer/optimistic-mutation invariants spot-verified; the §9 architecture checklist run explicitly.

**Refactor hygiene:** never mixed with behavior changes in one PR; never triggered by "while I'm here"; the corpus's structure IS a decision — restructuring it without governance is drift with good intentions.

---

# Section 12 — Feature Development Workflow (end-to-end lifecycle)

| Stage | What happens | AI responsibilities | Human responsibilities |
|---|---|---|---|
| **Requirement** | Exists in the frozen PRD (or arrives as a change request) | Read; verify against RTM; **may not create or alter** | PM owns; new requirements → governance |
| **Specification** | The corpus already specifies MVP scope; gaps → amendment process | Draft amendment proposals with cross-doc impact analysis when a gap is found | Architect+EM ratify; ledgers/RTM updated |
| **Planning** | Issue reaches DoR (QS §1.2); sprint placement per Bootstrap §4 order | Draft the implementation plan (stage 4, §4) with citations and reserved test IDs | EM/TPM sequence; approve R1 plans pre-code |
| **Implementation** | §4 pipeline, §5 sequence | Primary executor — code+tests+docs per this handbook | Operator validates checkpoints; unblocks escalations |
| **Review** | §8 workflow, §9 checklists | Self-review (§7) + optional first-pass review (§6.10) | Reviewer approves; CODEOWNERS for R1; nothing merges on AI approval alone |
| **Testing** | QS suites at their gates | Author/complete all mandated tests; fix reds; register IDs | QA owns verdicts, suite membership, quarantine |
| **Merge** | Merge queue, gates ⚙ | Ensure PR artifacts complete (report, checklist) | Human clicks merge; accountability attaches |
| **Release** | Trains + canary per OPS §3 / Bootstrap §8 | Draft release notes/changelog from Conventional Commits; verify flag states in the release checklist | ENG lead+PM approve promotion; SRE executes; Go/No-Go for milestones |
| **Monitoring** | OPS §5 dashboards/SLOs | MAY analyze dashboards/logs/traces on request and draft findings; MAY draft postmortem timelines from traces | On-call acts; humans declare incidents and make rollback calls |
| **Maintenance** | §10/§11 workflows; OPS §10 cadences | Execute bug-fix/refactor/upgrade tasks under their workflows; keep fixture corpus growing (parser incidents) | Owners per OPS; architect guards long-term consistency |

# Section 13 — Regression Prevention

The QS §12 growth rule (every production S1/S2 becomes a permanent RG-CRIT test) is the foundation. This section extends it into the full learning loop: **every bug produces four artifacts**, and each artifact hardens a different defense layer.

| Artifact | Defense layer hardened | Rule |
|---|---|---|
| **Regression test** | The suite | Fails-before/passes-after, carries the bug ID, joins the severity-appropriate suite (S1/S2 → RG-CRIT permanently) |
| **Documentation update** | The corpus | If the bug exploited a spec gap/ambiguity: amendment drafted (humans ratify). If it exploited a doc-vs-code mismatch: the mismatch's origin is found (which change diverged?) and the ledger records it |
| **Knowledge update** | Future agents | The lesson lands where the next agent will *actually* look: a spec-table row, a template constraint (§6), a reading-matrix entry (§2) — never only in a postmortem nobody re-reads |
| **Checklist update** | The review process | If the bug class *escaped review*, the checklist that should have caught it (§7 self-review or §9 domain list) gains an item — versioned, via this document's amendment process |

**Continuous improvement mechanics:**
- **Escape analysis is mandatory in every postmortem** (§10 step 7): name the defense that failed. A bug that escaped four layers (spec, lint, test, review) yields up to four fixes — but at minimum one *systemic* fix. "Reviewer should have noticed" is not a fix; a new checklist item or lint rule is.
- **Checklist growth is bounded:** items are added when a class of bug escapes, and *retired* when a lint/CI rule mechanizes them (the best checklist item is one promoted into a machine check). This keeps checklists sharp instead of ritual.
- **Trend review:** monthly, QA + EM review escaped-bug classes and quarantined-test counts; two escapes of the same class = automatic priority for a mechanical defense (lint, generator, schema constraint).
- **The suite is memory:** as QS §15.9 states, the regression suite is "an accumulating memory of every way the system has ever hurt a user." Agents treat suite tests as *load-bearing history* — weakening or deleting one to make a change pass is a blocking review finding (§9 Testing).

---

# Section 14 — Knowledge Management

## 14.1 The knowledge architecture
- **The corpus is the only authoritative knowledge base** (Protocol §11.1). Twelve documents + `docs/adr/` + per-feature `MANIFEST.md` + this handbook. Everything else (chat logs, PR discussions, meeting notes) is *ephemeral input* that either graduates into the corpus/ADRs or is legitimately forgettable.
- **Repo-embedded, versioned, reviewed:** knowledge lives in `docs/` under the same PR discipline as code (Bootstrap §1.1). A knowledge change has a diff, a reviewer, and a history — knowledge without version control is rumor.

## 14.2 How specifications evolve
Only via the Protocol §11.3 governance act: owning document amended → version bumped → its deviation ledger updated → cross-referencing documents' ledgers updated → QS RTM + affected tests updated **in the same change**. The amendment PR uses the Spec-Amendment issue template (Bootstrap §1.6) and requires architect+EM (CODEOWNERS on `docs/corpus/`). Agents draft; humans ratify; **code never silently leads the spec.**

## 14.3 Version history
Each document carries semantic versions (PRD v1.0→v1.1 with its §0 Revision Log is the exemplar: every change lists *what* and *why*). ADRs are immutable once Accepted; changes supersede (FES §16). Git history + Conventional Commits give line-level provenance; the ledgers give *decision-level* provenance — both are maintained because they answer different questions ("what changed" vs "what was decided and why").

## 14.4 Deprecated behavior
Deprecation is always *documented forward*: API endpoints get `Deprecation`/`Sunset` headers + OpenAPI marks (BIS §12.2); events get registry `deprecated`/`removedAfter` dates (BIS §12.1); flags get `expiresAt` + cleanup PRs (FES §10); superseded ADRs point to their successors; superseded spec sections are never deleted silently — the ledger records what replaced them and when. An agent encountering deprecated surface MUST use the successor and MUST NOT extend the deprecated one.

## 14.5 How future AI agents inherit knowledge
The continuity protocol (Protocol §11.2) operationalized: a new agent reads (1) the Protocol, (2) this handbook, (3) its task's §2 matrix row + ledgers, (4) the RTM row, (5) open-items status — and can then work correctly with zero tribal knowledge. The Bootstrap README gate (green build ≤½ day) is the same guarantee for humans. **Inheritance test:** periodically, a task is deliberately given to a fresh agent/session with corpus-only context; if it cannot proceed correctly, that is a *documentation defect* to fix, not an agent failure.

---

# Section 15 — Long-term AI Collaboration (multi-year governance)

## 15.1 How multiple AI assistants cooperate
**The corpus is the coordination mechanism** (Protocol §11.4): agents never coordinate agent-to-agent; they coordinate through frozen contracts (OpenAPI, tokens JSON, repository interfaces, event registry) and the shared constitution. Two agents on two features produce composable code *because* both obey the same precedence, boundaries, order, and templates — divergence between agents is, by definition, one of them departing from the constitution, and CI/review rejects the departure rather than reconciling it.

**Parallelization rule:** work splits at **contract seams** — freeze the interface first (OpenAPI row, repository interface, event schema), then implement both sides in parallel. Two agents MUST NOT concurrently modify the same contract artifact; contract changes serialize through their CODEOWNERS gate.

## 15.2 How context is transferred
Between sessions/agents: the Completion Report (§17.4) + the PR itself + updated MANIFESTs are the handoff — never a chat transcript. An agent resuming another's work re-derives state from: the report, the diff, the failing/passing test set, and the corpus (Protocol §11.2's "no predecessor summaries in lieu of the corpus"). In-repo work-in-progress is preferred over long-lived agent memory: half-done work is a draft PR with a report, not a warm context window.

## 15.3 How coding sessions remain consistent
Session-start ritual (mechanical, every session): read the §2 universal preamble → the task's matrix row → the current open-items status → run the test suite for the touched area (green baseline before touching anything). Session-end ritual: all checkpoints closed or the work parked as a draft PR + report. Consistency across sessions is *structural* — the invariant templates (§6), lints, and gates are the memory that persists when the conversation is gone. Determinism (§1.2) is the goal: the same task against the same corpus yields behaviorally identical output regardless of which agent, which model, or which day — because degrees of freedom are removed by templates and matrices, not left to session-local taste.

## 15.4 How large implementations are divided
Split at **contract seams, never mid-layer** (Protocol §5.3). A large feature decomposes into an ordered chain of mergeable PRs, each meeting the Definition of Done at its layer: `(migration) → (repository interface + impl + tests) → (service + tests) → (endpoint + contract update) → (controller + providers + tests) → (screen + widgets + goldens) → (integration test)`. Two rules bound the division:
- **No PR depends on another's un-merged, un-reviewed assumptions.** A downstream PR opens only after its upstream contract is merged (or is explicitly stacked with the dependency declared and the base reviewed first). "I'll fix the interface in the next PR" is how contracts rot.
- **Parallel splits are by aggregate, synchronized only at shared contracts.** Two agents may build two disjoint features simultaneously; they touch the same `openapi.yaml`/`tokens.json` only through the serialized CODEOWNERS gate (§15.1). Disjoint work needs no coordination; shared-contract work is serialized, never raced.

## 15.5 How architectural consistency is preserved across hundreds of prompts
The frozen architecture plus the constitution make consistency the **default state, not an achievement re-won each prompt.** The 1st prompt and the 400th are bounded by identical law: the same precedence order, the same import matrix, the same single-writer/optimistic-mutation/pure-domain invariants, the same error/analytics/flag registries — all mechanically enforced. An agent *cannot drift far* before a lint, a gate, or a review catches it; the blast radius of any single prompt's mistake is bounded by the machinery, not by the vigilance of the operator. What machines cannot judge (is this behavior corpus-correct? is this the right abstraction?) is exactly the human-review surface (§8) — so the division of labor itself is a consistency mechanism: agents produce within rails, humans guard the rails' edges. The periodic Architecture Compliance Report (§17.8) is the standing audit that the rails still hold.

## 15.6 Governance for future AI participation
This handbook and the Protocol are themselves versioned corpus documents; amending them is a §14.2 governance act (architect + EM). Three durable principles govern any future agent, however capable:
1. **Capability is not authority.** A more powerful future model does not thereby earn permission to redesign, to skip gates, or to decide what the corpus left to humans. New authority is *granted by amending the constitution*, deliberately — never assumed from capability.
2. **The constitution binds every agent equally.** There is no "senior AI" that operates unreviewed; the same STOP rule, the same forbidden list, the same review requirement apply to the newest and the most trusted agent identically. Trust is placed in the *process*, not in any agent.
3. **Every agent leaves the corpus more true, never less.** The standing obligation across years: implement faithfully, prove with tests, escalate on silence, and record every durable decision into the documents — so the agent that arrives in year three inherits a corpus as trustworthy as the one that existed at launch.

**The multi-year invariant (every future agent inherits this):**
> Obey the constitution, coordinate through the corpus not through memory, split at contracts, harden every defense with every bug, and when the corpus is silent or in conflict — stop and escalate, never invent. Consistency across years and across agents is not remembered; it is enforced.

---

# Section 16 — AI Operational Checklists (actionable, per gate)

Each is a literal pre-flight list; an item unchecked blocks the action. These compress the workflow into the moments an agent (or its operator) is about to act.

**Before coding** — [ ] task classified (§3) [ ] §2 reading done, citations ready [ ] deviation ledgers + RTM row read [ ] open-items (F-1/D-3/P-2/A4) checked for blocking [ ] implementation plan written + (R1/risky) human-approved [ ] reserved QS test IDs [ ] no STOP condition outstanding.

**Before committing** — [ ] compiles [ ] `dart format`/prettier clean [ ] analyzer + custom-lints green (imports, tokens, ARB, registries) [ ] tests for this unit written + green [ ] no literal strings/colors/durations [ ] no debug prints / `$queryRawUnsafe` [ ] Conventional Commit message with corpus citation.

**Before opening a PR** — [ ] §7 self-review checklist filled + attached [ ] all reserved QS IDs implemented + green [ ] coverage ratchet met (100%-modules at 100%) [ ] ARB zh+en [ ] goldens updated (theme×locale×scale) [ ] analytics registered+fired [ ] error paths mapped [ ] MANIFEST/ADR/docs per §3 row [ ] PR template complete incl. traceability line [ ] offline run attested (client) [ ] Completion Report (§17.4) attached.

**Before merging** — [ ] required CI checks green (R1 non-waivable) [ ] human review approved (CODEOWNERS for R1) [ ] no weakened/deleted assertions [ ] merge-queue combination tested [ ] no unresolved escalation [ ] linked issue at DoD.

**Before release** — [ ] RG-SMOKE/CRIT/PERF/SEC/AX green on release build [ ] crash-free ≥99.5%/48h beta [ ] zero open S1/S2 [ ] error budget has headroom (else reliability-only) [ ] real-Portal manual pass [ ] a11y manual pass (5 hot screens) [ ] migrations expand-safe + rollback verified [ ] flags at intended state + kill-switches reachable [ ] Go/No-Go unanimous (QS §15.7) [ ] open items resolved-or-deferred-with-owner.

**Before hotfix** — [ ] severity confirmed (S1/S2) [ ] branch from released tag (not main) [ ] §10 workflow followed (RCA→spec-verify→fix→regression) [ ] minimal scope (no opportunistic changes) [ ] regression test fails-before/passes-after [ ] worker-only lane if parser (api untouched) [ ] cherry-pick back to main verified [ ] incident + postmortem opened [ ] production follow-up scheduled.

**Before refactor** — [ ] classified safe/risky/forbidden (§11) with reasoning [ ] forbidden → stopped/escalated [ ] existing tests green *before* (characterization tests added if thin) [ ] risky → architect-approved plan [ ] dependency impact enumerated [ ] no behavior change intended [ ] separate PR from any feature/fix.

**Before migration** — [ ] target matches DB §7 [ ] expand-phase (no breaking step) [ ] `CONCURRENTLY` indexes with named consumers [ ] advisory-lock-compatible [ ] updated_at trigger + RLS on new user-owned tables [ ] down-consequence documented in header [ ] tested on fresh DB + rollforward [ ] backend-lead review [ ] destructive step → rehearsed down-script + snapshot.

---

# Section 17 — Appendices (production-ready templates)

Templates the Protocol §7 / this §6 do not already cover. Fill brackets; do not restructure.

### 17.1 Prompt template index
Canonical (Protocol §7): repository · feature · endpoint · providers · widget-tests · backend-tests · integration-tests · migrations. Extended (§6.1–6.13): controller · screen · widget · DTOs · drift table · service · golden tests · a11y tests · documentation · review · refactor · bug-fix · performance. Every prompt begins with the Protocol §7 CONSTITUTION block.

### 17.2 Code Review Report
```
REVIEW: <PR #> · <title> · reviewer: <name/agent> · date:
CLASSIFICATION: <feature|fix|refactor|…> · risk: <R1..R4> · CODEOWNERS-required: <y/n>
CORPUS CITATIONS VERIFIED: <the diff's citations trace to real sections? y/n + notes>
FINDINGS (ordered by severity):
  [BLOCKING] <domain §9> — <rule cited> — <what> — <minimal fix>
  [ADVISORY] …
UNCITED-BEHAVIOR SCAN: <any logic not traceable to the corpus? list or "none">
CHECKLIST (§9 domains): architecture <✓/✗> backend <> flutter <> db <> security <>
  performance <> a11y <> l10n <> testing <> ci <> docs <>
VERDICT: <approve | return with findings> — humans approve; agent output is advisory
```

### 17.3 Bug Report / Lessons-Learned
```
BUG: <id> · severity S<n> · area: · reported: · env: <prod|staging|dev>
REPRO (deterministic): <steps>
EXPECTED (corpus citation): <what the spec says should happen — §>
ACTUAL: <observed>
RCA (5-whys → root): <mechanism, not symptom>
SPEC VERIFICATION OUTCOME: <code-diverges | spec-silent→escalated | spec-wrong→amendment ADR-N>
FIX: <PR #, minimal change at root>
REGRESSION TEST: <ID, fails-before/passes-after evidence, RG-CRIT? y/n>
INCIDENT MAP: <OPS incident #, MTTD, MTTR, did alerting catch it? gap action if not>
LESSONS: <which defense failed> → <systemic fix: new lint/check/test-dimension §13>
PROD FOLLOW-UP: <metric/dashboard, window, observed-resolved date>
```

### 17.4 Implementation Report (attached to every feature/task PR)
```
IMPLEMENTATION REPORT
TASK: <id/title> · classification: · risk: · sprint:
CORPUS BASIS: <the §2 documents+sections read and implemented against>
WHAT WAS BUILT: <files by layer, §5 order — models→…→tests→docs>
CONTRACTS TOUCHED: <openapi.yaml? tokens.json? drift schema? event version? — governance if yes>
TESTS: <QS IDs implemented, coverage deltas, suites affected>
FLAGS/ANALYTICS/A11Y/L10N: <what was added, registries updated>
DEVIATIONS ESCALATED: <any STOP raised, how resolved — or "none">
OPEN ITEMS TOUCHED: <F-1/D-3/P-2/A4 — status impact>
FOLLOW-UPS: <deferred items with owners + issue links>
DoD: <code|feature-level checklist state — Protocol §9>
```

### 17.5 Feature Completion Report (at feature/milestone close)
```
FEATURE COMPLETION: <feature> · milestone: · date:
RTM STATUS: <QS §2 rows for this feature — all mapped to green tests? list IDs>
ACCEPTANCE: <PRD AC checkboxes — each demonstrated by which test>
QUALITY GATES: <FES §17 gate verdicts relevant to this feature>
NON-FUNCTIONALS: <PF budgets met? SEC items? AX pass? — evidence>
KNOWN LIMITATIONS: <anything deferred, flag-gated, or spec-noted>
SIGN-OFFS: <QA / design / PM / architect as applicable>
```

### 17.6 Daily Progress Report
```
DATE: · agent/operator: · sprint:
DONE (merged/ready): <task ids + one line each>
IN PROGRESS: <task, current §4 stage, blockers>
ESCALATIONS RAISED: <STOP conditions, awaiting whom>
BLOCKED-ON: <open items / dependencies / human decisions>
NEXT: <planned per Bootstrap sprint order>
```

### 17.7 Sprint Report
```
SPRINT <n> · goal (Bootstrap §4): · dates:
EXIT CRITERIA STATUS: <each criterion — met? evidence (test IDs, gate verdicts)>
DELIVERABLES: <shipped vs planned>
RTM MOVEMENT: <requirements newly covered; any newly orphaned (=defect)>
QUALITY: <coverage ratchet trend, flaky count, open S1/S2>
RISKS: <F-1/D-3/P-2/A4 + new risks, status changes>
CARRY-OVER: <with reasons and re-planned sprint>
MILESTONE IMPACT: <on track for the §6 milestone? gate-declared or slipped>
```

### 17.8 Architecture Compliance Report (periodic / pre-milestone)
```
PERIOD: · scope: <modules/features>
IMPORT MATRIX: <lint clean across corpus? violations + remediations>
BOUNDARY INVARIANTS: <single-writer, optimistic-mutation, domain-purity, pure-Dart-domain — spot checks>
CONTRACT INTEGRITY: <openapi/tokens single-source respected? generated-client compiles? drift matches server subset>
UNCITED-BEHAVIOR AUDIT: <sampled diffs — any invention that passed review? findings>
ADR LEDGER: <decisions since last report; superseded marked>
DRIFT VERDICT: <is the codebase still the corpus? issues + owners>
```

### 17.9 Testing Report
```
PERIOD/RELEASE:
COVERAGE: <per-module vs ratchet gates; 100%-modules confirmed at 100%>
SUITES: <RG-SMOKE/CRIT/SYNC/NOTIF/OFF/PERF/SEC/AX — pass/fail, durations>
NEW TESTS: <IDs added; RG-CRIT growth from production S1/S2>
FLAKES: <quarantined count + trend + owners>
PERFORMANCE: <PF budgets — met/exceeded, farm evidence>
GAPS: <any RTM row without a passing test = blocking>
```

### 17.10 Release Readiness Report
```
RELEASE <version> · date · train:
GATES (QS §14): <format/lint/coverage/golden/unit/integration/contract/perf/security/a11y — all green?>
REGRESSION: <RG-CRIT/PERF/SEC/AX on release build — verdicts>
BETA HEALTH: <crash-free % / 48h; SLO adherence over window>
OPEN DEFECTS: <S1/S2 = zero? S3 count + PM sign-off>
MANUAL: <real-Portal script; a11y 5-screen pass>
OPS READINESS: <migrations expand-safe + rollback verified; flags + kill-switches; monitoring/alerts; on-call; DR drill current>
OPEN ITEMS: <F-1/D-3/P-2/A4 — resolved or deferred-with-owner>
GO/NO-GO: <unanimous owner sign-off — QS §15.7>
```

---

## Closing statement

This handbook operationalizes the AI Coding Protocol across the full development lifecycle: it tells an AI agent what to read before it acts (§2), how to classify and gate its work (§3–§5), how to prompt itself and review itself (§6–§7), where its judgment ends and a human's begins (§8), how to fix bugs and refactor without introducing drift (§9–§11), how a feature travels from requirement to maintenance (§12), how every defect strengthens the system permanently (§13), and how knowledge survives across years and across agents that share no memory (§14–§15) — with the checklists and templates to execute all of it (§16–§17).

It changes no requirement and redesigns nothing; the architecture remains frozen. It governs only the *manner* of AI participation, so that hundreds of future prompts from many different agents compose into one coherent system — because they all obey one constitution, coordinate through one corpus, and, when that corpus is silent, stop and ask rather than invent.

*End of AI Development Workflow v1.0 — the AI-assisted engineering operations handbook. Subordinate to the AI Coding Protocol v1.0; consuming the twelve frozen corpus documents; changing none of them. Open items carried unchanged: F-1 (WebView cookie spike), D-3 (design addendum), P-2 (analytics consent copy), A4 (grades scope, flag-off).*

