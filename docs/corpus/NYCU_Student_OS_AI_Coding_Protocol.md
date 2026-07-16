# NYCU Student OS — AI Coding Protocol
## The Implementation Constitution · Version 1.0
**Authority:** Principal Software Architect · Principal Engineering Manager
**Status:** RATIFIED — binding on every AI agent and human operator who directs one
**Date:** July 2026
**Classification:** Highest-precedence process document. This protocol governs *how* code is written; it does not and cannot alter *what* is to be built.

---

## Preamble

This document is the constitution for machine-assisted implementation of NYCU Student OS. It binds any AI coding agent — ChatGPT, Claude, Gemini, Cursor, GitHub Copilot, or any successor system — and the humans who operate them.

Ten specifications precede this one. Together they define the product, its interfaces, its data, its behavior, its quality bar, and its operation with a completeness rarely achieved before implementation. That completeness is an asset only if implementation *honors* it. The failure mode this protocol exists to prevent is the one AI agents are most prone to: **plausible invention** — generating code that looks correct, compiles, and passes a superficial read, but silently diverges from a contract decided deliberately upstream. In a system whose entire reason for existence is *trust through reliability* (PRD G5), a plausible-but-wrong implementation is not a bug; it is a breach of the product's core promise.

Therefore this protocol's first principle is also its harshest: **the specifications are law, the AI is counsel, and counsel does not amend the law.**

The keywords MUST, MUST NOT, SHALL, SHALL NOT, SHOULD, SHOULD NOT, and MAY are used per RFC 2119.

### The Source-of-Truth Corpus (the ten immutable contracts)

| # | Document | Abbrev | Governs |
|---|---|---|---|
| 1 | Product Requirements Document v1.1 | **PRD** | What must exist and why; acceptance criteria; scope (MoSCoW) |
| 2 | UI/UX Design Specification v1.0 | **DS** | Visual identity, tokens, components, responsive layout |
| 3 | Backend Architecture v1.0 | **BA** | Infrastructure, service topology, sync engine principles |
| 4 | Interaction Readiness Review v1.1 | **IRR** | Interaction rules, state machines, error matrix, offline, animation, ambiguity register |
| 5 | Database Design Specification v1.0 | **DB** | Canonical schema, indexes, constraints, RLS, partitioning |
| 6 | Backend Implementation Specification v1.1 | **BIS** | NestJS module/API/repository contracts; event/versioning/tracing/flags |
| 7 | Flutter Architecture v1.0 | **FA** | Client layers, navigation, DI, screens, repositories |
| 8 | Flutter Engineering Standards v1.0 | **FES** | Naming, structure, tokens, analytics, crash, CI, security, ADR |
| 9 | Software Quality Specification v1.0 | **QS** | Traceability matrix, test taxonomy, coverage gates, severity |
| 10 | Production Operations Manual v1.0 | **OPS** | SRE runbooks, SLOs, deployment, DR |

An eleventh conceptual input — the **Implementation Readiness** state — is not a separate file but the union of IRR §10 (Ambiguity Register, readiness checklist) and QS §2 (Requirement Traceability Matrix). Where this protocol says "the readiness gates," it means those.

---

# 1. AI Development Philosophy

## 1.1 The AI is an implementation agent, not a designer

An AI agent operating under this protocol **produces implementations of already-decided specifications**. It does not decide product behavior, interface shapes, data structures, or interaction rules. Every such decision has an owner document in the corpus; the agent's role is faithful translation from specification to working, tested code.

This is not a limitation to be worked around — it is the precondition for the corpus retaining value. Ten documents of deliberate decisions are worthless if the eleventh actor (the implementer) treats them as suggestions.

## 1.2 Specifications are immutable contracts

An agent **MUST NOT** alter a specification to make implementation easier. If a specification is wrong, impractical, or genuinely ambiguous, the agent's *only* sanctioned action is to **STOP and escalate** (§1.6) — never to silently reinterpret, "improve," or route around it. A spec change is a human governance act performed on the owning document (with its deviation-ledger updated), not a side effect of writing code.

## 1.3 Never invent behavior

If a behavior is not specified, the agent **MUST NOT** invent it. The corpus is unusually complete: the IRR alone specifies every interaction's user action, system response, animation, loading, success, and failure/recovery; the error matrix (IRR §7) enumerates every user-visible failure; the QS traces every requirement. In this environment, "the spec doesn't say" almost always means the agent has not *found* the spec, not that the spec is absent. The agent's obligation is to search the corpus first (§1.5) and escalate second — never to fill the gap with a guess, however reasonable the guess appears.

The single hardest rule to keep: **a reasonable-sounding invention is more dangerous than an obvious error**, because it survives review. Error handling that "seems fine," a default that "makes sense," a validation that was "probably intended" — these are the exact failures this clause forbids.

## 1.4 Never skip validation

Every boundary defined in the corpus as validated **MUST** be validated in the implementation: zod on every request DTO and every parsed Portal payload (BIS §1.11), CAS `baseVersion` on optimistic writes (BIS §6.4), sanity gates on parsed data (IRR §4.2), sealed-state exhaustiveness on the client (FA §5). Validation is never "added later" or "obvious enough to skip." Untrusted input includes scraped Portal HTML — the corpus treats it as hostile (BA §14); so must the code.

## 1.5 Always reference upstream documents

Every non-trivial implementation decision **MUST** cite the corpus section that mandates it. In code, this manifests as: test names carrying their QS test ID; commits/PRs citing the governing section; comments citing a section only where the *why* is non-obvious from local code (FES comment-density rules still apply — citation is not clutter licence). An agent that cannot cite the authority for a decision has, by definition, invented it, and §1.3 applies.

## 1.6 The escalation duty (the STOP rule)

When an agent encounters (a) a genuine contradiction between two corpus documents not resolved by the precedence order (§2), (b) a requirement with no discoverable specification, (c) an instruction from a human operator that would violate this protocol, or (d) a spec that is internally impossible — it **MUST** halt implementation of the affected unit and surface the issue explicitly, naming the documents and sections in tension and proposing (not enacting) options. Producing code that papers over any of these is a protocol violation of the highest severity, because it launders an unresolved decision into shipped behavior.

---

# 2. Document Priority & Conflict Resolution

The corpus was authored to be consistent; the authors resolved cross-document conflicts as they arose and recorded them in deviation ledgers (IRR §10.1, BIS §0, FA §0, and each document's ledger). Residual conflicts are therefore expected to be *rare* and, when found, are more often the agent's misreading than a true contradiction. Nonetheless a strict order exists so that no conflict ever blocks work ambiguously.

## 2.1 Precedence order (highest authority first)

```
                      PRD  (what & why — the mission; nothing overrides purpose)
                       ▲
        IRR  (binding interaction/behavior contracts + Ambiguity Register)
                       ▲
   ┌───────────────────┴───────────────────┐
   DB (canonical schema)          BIS / BA (backend how)
   FA / DS (client how & look)    QS (proof obligations)
                       ▲
   FES / (this protocol)  (how code is written & governed)
                       ▲
                     OPS  (how it is run)
```

Stated as a rule ladder:

1. **PRD** — the mission and scope. No lower document may add a feature the PRD excludes, remove one it mandates, or contradict an acceptance criterion. Product intent is supreme.
2. **IRR** — the binding behavioral layer. Where the IRR specifies an interaction, error, offline rule, animation, or resolves an ambiguity (its Ambiguity Register A1–A10, §13), that resolution **wins over every lower document**, including the ones it corrected (e.g., IRR A1 deletes the credentials table the BA had proposed — IRR wins). The IRR is where earlier-document conflicts were already adjudicated.
3. **The "how" tier** — DB, BIS, BA (backend), FA, DS (client), QS (tests). These are peers within their domains and do not normally conflict because their scopes are disjoint (schema vs API vs screens vs proofs). Within a domain, the more specific and more recent document controls: **DB is canonical for schema** (it supersedes BA §4.3 explicitly); **BIS is canonical for API/module contracts** (supersedes BA where they overlap); **FA/DS are canonical for the client**; **QS is canonical for what must be proven**.
4. **FES and this protocol** — how code is written and governed. These constrain *style and process*, never *behavior*; they cannot override a higher-tier behavioral decision, only dictate the manner of its implementation.
5. **OPS** — how the running system is operated. It consumes all above and overrides none.

## 2.2 Conflict-resolution procedure

When two documents appear to conflict, the agent applies, in order:

1. **Re-read for scope, not contradiction.** Most apparent conflicts are disjoint scopes misread as overlapping (BA's "portal_credentials" vs IRR's deletion is *resolved history*, not a live conflict — the ledger says so). Check the deviation ledgers first.
2. **Apply precedence (§2.1).** If the documents are at different tiers, the higher tier wins, full stop.
3. **Apply specificity within a tier.** Same-tier, disjoint-domain: the domain owner wins (schema question → DB; API question → BIS; look question → DS).
4. **If still unresolved → STOP and escalate (§1.6).** A true same-tier, same-domain contradiction is a corpus defect requiring a human governance decision and a ledger update. The agent MUST NOT choose for itself.

The agent **MUST NOT** resolve a conflict by averaging, by choosing the more convenient option, or by implementing both behind a condition it invents.

---

# 3. Code Generation Rules

Every unit of generated code — a function, a widget, an endpoint, a migration — is subject to the following contract. The agent produces nothing that cannot satisfy all applicable rows.

| Dimension | Rule |
|---|---|
| **Required inputs** | Before generating, the agent MUST have identified: the governing corpus section(s); the exact interface it implements (repository method signature from FA §9.1 / BIS; DTO from OpenAPI; entity from FA domain); the states it must handle (sealed `UiState` set / sync state machine subset); the error codes it may emit (IRR §7 subset). Generation without these inputs is forbidden — the agent asks or searches, it does not proceed on assumption. |
| **Required outputs** | Working code + its tests in the same change (QS mandates the test; code without its test is incomplete, not "to be tested later") + the corpus citation. For behavior with user-visible surface: the strings (ARB), the tokens (theme), the analytics event, the semantics label — all present, none deferred. |
| **Forbidden assumptions** | No assumed defaults (a default value is a product decision — it has an owner doc or it does not exist); no assumed error text (comes from IRR §7 registry); no assumed field names (come from DB/OpenAPI); no assumed timezone (Taipei per IRR A10, always explicit); no assumed nullability (DB schema is authoritative); no assumed happy path (every failure branch from the error matrix is handled). |
| **Error handling** | Every failure maps to an `AppFailure` / Error Matrix code (IRR §7). No bare `catch` that swallows; no generic "something went wrong" not backed by a registered code; workers classify transient vs permanent on the exception type (BIS §1.9). An unmapped error path is a defect. |
| **Feature flags** | Behavior designated flag-gated (grades, digest batching, experiments — FES §10) MUST be gated through the flag service, never shipped unconditionally. New risky behavior SHOULD be introduced behind a flag with an `expiresAt` (FES §10). |
| **Analytics** | User actions defined as tracked (QS §2 / FES §7.2 event schema) MUST fire their registered, allowlisted event. Events are declared in the registry first (compile error otherwise); params are the allowlist only — never content strings (FES §7.3). |
| **Localization** | Every user-visible string MUST come from ARB (zh-TW template + en), namespaced per FES §2; no literal user-facing text; sentences use placeholders, never concatenation; dates/numbers via `intl` with app locale. |
| **Accessibility** | Every interactive carries a semantics label; tap targets ≥44; color never the sole signal; Reduce Motion honored via the single `Motion.of` switch; contrast is structural (tokens) not per-widget. AX obligations (QS §11) are part of generation, not a later pass. |
| **Testing** | The unit ships with the tests QS mandates for its layer and risk class (§5 below assigns them): domain logic → unit at its coverage gate; widget → state-matrix test; endpoint → happy + every error code + authz probe; the conflict resolver / diff engine / prefs resolver → 100%. Test IDs from the QS registry are carried in test names. |

---

# 4. Layer Responsibilities (the boundaries an agent MUST NOT cross)

The corpus defines strict layering on both client (FA §1, FES §3 import matrix) and backend (BIS §1.1 module boundaries). The agent implements *within* a layer and communicates *across* layers only through the sanctioned channel. Crossing a boundary — even when it would be shorter — is a protocol violation, because the boundaries are what make the system testable, offline-correct, and maintainable.

## 4.1 Flutter client

| Layer | The agent MAY implement here | The agent MUST NOT |
|---|---|---|
| **Presentation** (`features/*/presentation`, `shared_widgets`) | Widgets that render state and forward intents; token-only styling; semantics; layout | Call `dio`; touch `drift`; hold business state; read connectivity except via provider; import another feature; embed literal strings/colors/durations |
| **Application** (`features/*/application`) | Riverpod controllers (`(Async)Notifier`); screen state shapes; orchestrate repository calls; map failures to `AppFailure` | `await` network in a mutation path (optimistic-first is law, IRR §1); import `core/db` or `core/network` directly; contain UI code |
| **Domain** (`domain/`) | Pure entities (freezed); repository *interfaces*; pure logic (urgency, Taipei bucketing, cursor codec, conflict rules) | Import Flutter, drift, dio, or Riverpod (domain is pure Dart, FES §3); depend on any layer above |
| **Data/Infrastructure** (`data/`, `core/`) | Repository *implementations*; DAOs; outbox; sync adapters; dio client + interceptors; mappers | Leak DTOs/drift rows into domain; be imported by a feature (features see interfaces only, resolved by providers) |

## 4.2 Backend

| Layer | The agent MAY implement here | The agent MUST NOT |
|---|---|---|
| **Controller** (module `*.controller`) | HTTP surface; zod-validated DTOs; auth guards; map service results to responses/`problem+json` | Contain business logic; touch Prisma; call another module's internals |
| **Service/domain** (module services) | Business logic; orchestration; transaction boundaries; event emission (post-commit) | Build SQL; parse JSON wire shapes; reach into another module except via its exported interface or a domain event |
| **Repository/data** | Prisma access; query shapes matching DB indexes; CAS; RLS context | Be called from a controller directly (goes through a service); write academic tables outside the `app_worker` role path (single-writer invariant, DB §2.4) |
| **Worker/consumer** | Pub/Sub consumers; the sync orchestrator; the dispatcher loop; classify transient/permanent | Bypass RateGate to Portal; apply a ChangeSet outside a category transaction; publish events before commit |
| **Database** | Only via migrations (Prisma chain + raw SQL for triggers/RLS/partitions, DB §8) | Hand-edit generated Prisma; skip `CONCURRENTLY`; add an index without a named consumer; alter the schema outside the migration chain |

## 4.3 The cross-boundary channels (the only sanctioned ones)

Client: **widget → provider → controller → repository interface → (impl) → drift/dio**. Backend: **controller → service → repository → Prisma**, and **module → module only via Pub/Sub domain events or an exported service interface** (BIS §1.1). Sync writes *into* the store; repositories read *from* it — an agent MUST NOT wire a repository to call the sync coordinator, nor a widget to call an API client.

---

# 5. Development Order Rules

Implementation proceeds bottom-up so that every layer is built against an already-tested foundation and never against an assumption. The agent **MUST** follow this order per feature; it MUST NOT generate a screen before the repository it consumes exists and is tested, because doing so forces the screen to assume an interface that may not match the contract.

## 5.1 Backend feature order (mandatory)

```
1. Migration (DB schema delta, expand-phase) ──▶ verified against DB §7 canonical schema
2. Prisma model / generated types
3. DTO (from OpenAPI) + zod schema
4. Mapper (DTO ⇄ entity ⇄ Prisma) ──▶ total functions, unit-tested
5. Repository (interface + impl) ──▶ integration-tested vs testcontainers (RLS, CAS)
6. Service / use-case ──▶ unit-tested with repository fakes
7. Controller / endpoint ──▶ API test: happy + every error code + authz probe
8. Events / consumers (if any) ──▶ versioned envelope, consumer-compat tested
9. Contract sync ──▶ OpenAPI updated, generated client compiles
```

## 5.2 Client feature order (mandatory)

```
1. Domain entity (freezed) + pure logic ──▶ unit-tested at coverage gate (95%+)
2. Repository interface (domain/) ──▶ the contract the UI will code against
3. drift table/DAO + mapper (if new local shape) ──▶ integration-tested
4. Repository impl (data/) wiring DAO + outbox + ApiClient ──▶ integration-tested
5. Controller / provider (application/) ──▶ unit-tested: state transitions, failure mapping,
                                            no-network-await invariant
6. Screen + widgets (presentation/) ──▶ widget tests across the sealed-state matrix
7. Goldens (component/screen × light/dark × zh/en × text-scale)
8. Integration test (patrol) for the end-to-end feature flow
9. Feature checklist (FES §4) fully satisfied ──▶ Definition of Done (§9)
```

## 5.3 Order invariants
- Tests are authored **with** their unit, in the same change — never a trailing "add tests" step (a change without its tests is not done, QS DoD).
- A later step MUST NOT force a change to an earlier, already-approved contract without that being an explicit, cited amendment (if the screen reveals the repository interface was wrong, that is a STOP-and-revise the interface deliberately, not an ad-hoc widening).
- The two sequences meet at the **contract** (OpenAPI): backend step 9 and client step 2 are bound by the same YAML; neither side invents its shape.

---

# 6. Pull Request Rules

Every implementation PR is a governed artifact. A PR that omits any applicable element below is incomplete and MUST NOT be merged, regardless of whether the code "works."

| Element | Requirement | Authority |
|---|---|---|
| **Feature checklist** | The FES §4 Feature Checklist, fully ticked, in the PR body — including the offline-run attestation and the manifest update | FES §4 |
| **Tests** | Every unit ships its tests; coverage ratchets hold per module; new test IDs registered in the QS matrix; the S1/S2→RG-CRIT rule honored if fixing a production defect | QS §4/§12 |
| **Migration** | Present, expand-phase-safe, advisory-lock-compatible, `CONCURRENTLY` indexes, matches DB §7; down-consequence documented | DB §8 |
| **Localization** | ARB entries (zh-TW + en) for every new string; ARB-diff CI green | FES §7 |
| **Accessibility** | Semantics on new interactives; goldens include the a11y variants; AX CI guards green | QS §11, FES §15 |
| **Analytics** | New tracked events registered + fired + param-allowlisted; privacy sign-off if the schema changed | FES §7 |
| **Error mapping** | Every new failure path maps to a registered Error Matrix code; no bare catch; user copy from IRR §7 | IRR §7, BIS §1.9 |
| **Documentation** | Corpus citations for non-obvious decisions; ADR if the change touches an ADR-triggering area (import matrix, dependency, store role, spec-binding reversal); MANIFEST current | FES §16 |
| **Traceability** | The PR cites the PRD requirement / IRR section / QS test IDs it satisfies — a reviewer can trace code → contract in one hop | QS §2 |

PR size and review follow FES §11 (≤400 lines soft cap, squash-merge, merge queue). CI gates (QS §14) are non-negotiable and, for R1 areas, non-waivable.

---

# 7. Official AI Prompt Templates

These are the sanctioned prompts for directing an agent to implement a unit. They are templates, not scripts — the operator fills the brackets, and the agent is bound by the constraints block in each. The constraints block is identical across templates because the constitution is invariant; only the task differs. An agent receiving one of these MUST refuse (per §1.6) if the referenced spec section does not exist or is silent on a required decision.

**Common constraints block (prepended to every template below):**
```
CONSTITUTION: Obey the AI Coding Protocol v1.0. Specs are immutable law (§1.2).
Never invent behavior (§1.3); if the spec is silent/ambiguous/contradictory, STOP and
escalate naming the documents in tension (§1.6) — do not guess.
Cite the governing corpus section for every non-trivial decision (§1.5).
Follow the development order (§5) and layer boundaries (§4). Ship tests with code (§6).
Precedence on conflict: PRD > IRR > {DB|BIS|BA|FA|DS|QS by domain} > FES > OPS (§2).
```

### 7.1 Create a repository
```
[CONSTITUTION]
TASK: Implement <AggregateName>Repository.
INTERFACE: exactly as declared in FA §9.1 / domain/repositories — do not add or rename methods.
IMPLEMENT: interface (domain/), impl (data/) wiring DAO + outbox + ApiClient per §5.2.
WATCH QUERIES must match the spec's read surface and map 1:1 to a DB §5 index — cite the index.
MUTATIONS: optimistic drift-first then outbox with baseVersion + Idempotency-Key (IRR §6.4);
conflict handling delegates to ConflictResolver (IRR §6.5) — do not inline merge logic.
TESTS: integration vs in-memory drift for read shapes; the hidden-assignment filter honoring
show_hidden_assignments; outbox enqueue exactly-one-op. Coverage gate 90% (QS §4).
OUTPUT: interface + impl + tests + citations. Nothing else.
```

### 7.2 Create a feature (vertical slice)
```
[CONSTITUTION]
TASK: Implement feature <name> per FA §12.<n> (screen) and its IRR §1 interaction rows.
ORDER (mandatory, §5.2): entity+logic → repo interface → drift/DAO → repo impl → controller
→ screen/widgets → goldens → patrol integration → FES §4 checklist.
STATES: implement the full sealed UiState set (Loading/Data/Empty/Failure); Empty & error copy
verbatim from IRR §8.3 / §7 (ARB). Offline behavior per IRR §6.
BOUNDARIES: presentation renders + forwards intents only; no dio/drift in widgets (§4.1).
DELIVER with: ARB (zh+en), tokens-only styling (DS), analytics events (FES §7), semantics (QS §11).
STOP if any referenced IRR/FA/DS section is missing the detail you need.
```

### 7.3 Add an endpoint
```
[CONSTITUTION]
TASK: Implement <METHOD /v1/path> exactly as specified in BIS §5.
CONTRACT: request/response/status-codes/validation/authz/pagination/sort per the BIS §5 row —
do not add fields, relax validation, or change a status code (that would be a /v2 concern, BIS §12.2).
ORDER (§5.1): migration (if schema delta, matching DB §7) → DTO+zod → mapper → repository →
service → controller → OpenAPI update (generated client must compile).
VALIDATION: zod strict (reject unknown fields); keyset pagination only; Idempotency-Key on POST.
AUTHZ: user-scoped repo + RLS; cross-user probe returns identical 404.
TESTS (QS §6): happy + EVERY documented error code + authz probe + validation-reject + pagination
stability. OpenAPI validation middleware must pass.
```

### 7.4 Add Riverpod providers
```
[CONSTITUTION]
TASK: Add provider(s) for <purpose> per FA §4/§5.
KIND: StreamProvider wrapping a drift watch for reads; (Async)Notifier controller for state+mutations.
NAMING: FES §2 (lowerCamel + Provider; family arg only to disambiguate).
DISPOSAL: autoDispose unless the keep-alive set (FA §4) justifies otherwise — justify in a comment.
RULES: provider reads only downward; controller never imports core/db|core/network directly (§4.1);
mutations optimistic, no network await. Rebuild scoping via select() on wide providers.
TESTS: controller unit tests — state transitions, failure→AppFailure mapping, no-network-await invariant.
```

### 7.5 Add widget tests
```
[CONSTITUTION]
TASK: Widget tests for <Screen/Component> per QS §5.
MOUNT: ProviderScope with in-memory repository fakes (FES test seam) — no real network/drift.
COVER: the full sealed-state matrix (Loading skeleton-shape / Data / Empty(named) / Failure(each code));
plus the screen's IRR §1 interaction rows as tests (e.g., swipe→complete, toggle→explainer-once,
undo restores sort_order).
DIMENSIONS: dark mode + zh/en via goldens; text-scale 1.3/AX3 for Dashboard & Tasks; layout class swap.
A11y asserts inside each test: tapTargetGuideline, textContrastGuideline, semantics presence (QS §11).
Carry the QS WT-* IDs in test names.
```

### 7.6 Add backend tests
```
[CONSTITUTION]
TASK: Backend tests for <unit> per QS §6.
LEVEL: unit (services w/ repo fakes) OR integration (testcontainers: real PG+RLS+triggers, Redis,
PubSub emulator) as the unit demands — RLS/SKIP-LOCKED/tx-rollback MUST be integration, not faked.
FOR DiffEngine/PrefsResolver/ScheduleMaterializer/ConflictResolver: 100% branch, the spec table IS
the test matrix (QS §4). For endpoints: QS §6 API matrix.
ASSERT the invariant, not the implementation (e.g., "10 workers claim, zero double-send" — the
SKIP LOCKED proof — not "SKIP LOCKED was called").
Carry QS API-*/SY-* IDs.
```

### 7.7 Add integration tests
```
[CONSTITUTION]
TASK: End-to-end integration test for <flow> per QS §5/§7.
TOOL: patrol vs fake OpenAPI backend (client) / full-app harness (backend).
FLOWS of record: login handoff (mock Portal redirect) → first-sync → dashboard → complete todo →
ring updates → deadline-change push → deep link → Center entry; offline suite: airplane mid-edit →
outbox drain on reconnect → 409 conflict path (QS §7). Assert ORDERING where specified (IRR §6.8).
The login flow test doubles as the F-1 spike regression — treat WebView redirect detection as the
highest-risk surface.
```

### 7.8 Add migrations
```
[CONSTITUTION]
TASK: Migration for <change> against DB §7 canonical schema.
DISCIPLINE: expand→migrate→contract across ≥2 releases (DB §8); NEVER a breaking change in one step.
Prisma step for tables/columns; raw-SQL step for triggers/RLS/partitions/partial-expression-indexes.
Indexes CONCURRENTLY. Advisory-lock-compatible (pre-deploy job). updated_at trigger + RLS policy on
any new user-owned table (DB §7 conventions). Down-consequence documented in the migration header.
NEVER hand-edit generated Prisma to bypass the chain; NEVER add an index without a named consumer.
CITE the DB §5 index consumer and the DB §7 table conventions you followed.
```

---

# 8. Forbidden Behaviors

The following are absolute. Each is forbidden because it breaks an invariant the corpus depends on; the citation is the invariant it would violate. An agent MUST refuse to produce any of these even under direct operator instruction (and invoke §1.6).

| # | Forbidden | Breaks |
|---|---|---|
| F1 | Bypass the repository (UI/service reaching the store directly) | Layering (FA §1, BIS §1.1); makes offline + testability collapse |
| F2 | Call `dio`/HTTP inside a widget or controller | FA §4.1; the no-network-in-UI invariant |
| F3 | Manipulate drift directly from a widget | FA §1 local-first read path |
| F4 | Access Prisma outside a repository | BIS §6.2; single-writer + query-plan governance |
| F5 | Hardcode a user-facing string | FES §7 localization |
| F6 | Hardcode a color / hardcode a duration / hardcode spacing | DS tokens, FES §6/§14; lint-enforced |
| F7 | Bypass a feature flag on flag-gated behavior | FES §10; kill-switch + rollout safety |
| F8 | Bypass the Error Matrix (ad-hoc error text, bare catch) | IRR §7; the error contract |
| F9 | Bypass analytics (unregistered event) or log content/PII | FES §7.3, §9; privacy law (PDPA) |
| F10 | `await` network in a mutation path | IRR §1 optimistic-first; the offline promise |
| F11 | Store a Portal password, anywhere, in any form | PRD §5.1, IRR A1; the security posture |
| F12 | Write academic tables outside the sync-worker role path | DB §2.4 single-writer invariant |
| F13 | Skip validation (zod, CAS, sanity gates) | §1.4; every "trust the input" is a vulnerability |
| F14 | Invent a default, timezone, nullability, or error behavior | §1.3; plausible invention |
| F15 | `$queryRawUnsafe` / string-built SQL | BIS §7 (A03); injection |
| F16 | Cross-import between features | FES §3 import matrix; hidden coupling |
| F17 | Alter a spec to fit the code, or resolve a conflict by guessing | §1.2, §2.2; constitutional |
| F18 | Merge a PR missing an applicable §6 element | §6; the governed-artifact rule |

This list is non-exhaustive; it enumerates the highest-frequency temptations. The general rule subsumes it: **if an action requires stepping outside a corpus-defined boundary, it is forbidden until the boundary is deliberately, citedly amended.**

---

# 9. Definition of Done

Done is layered; a unit is not done until its layer's bar is met, and higher bars subsume lower.

**Code-level (a single unit):** implements exactly its cited contract; all applicable §3 dimensions satisfied (inputs/outputs/errors/flags/analytics/l10n/a11y/tests); zero hardcoded strings/tokens/durations; every failure path mapped to a code; tests present and green at the module coverage gate; boundaries (§4) respected; corpus cited.

**Feature-level (a vertical slice):** FES §4 Feature Checklist fully ticked; the full sealed-state matrix implemented; offline run attested; goldens across theme×locale×scale; patrol integration green; analytics + semantics + ARB complete; MANIFEST current; QS RTM rows for the feature all mapped to passing tests.

**Sprint-level:** every story meets its DoR→DoD (QS §1.2/§1.3); no open bug > S3 against sprint scope; coverage ratchets held or raised (never lowered); the RTM has no newly-orphaned requirement; deviation ledgers updated for any (escalated, human-approved) spec change.

**Release-level (QS §1.5 / §15.6, OPS §11):** RG-SMOKE/CRIT/PERF/SEC/AX green on the release build; crash-free ≥99.5%/48h beta; zero open S1/S2; error budget has headroom (else reliability-only); real-Portal manual pass; a11y manual pass; migrations expand-safe + rollback verified; Go/No-Go unanimous; kill-switches reachable. Open corpus items (F-1, D-3, P-2) resolved or explicitly deferred with owner.

---

# 10. AI Review Checklist

Every generated change passes this review — self-review by the producing agent, then human/CI verification — before it is considered complete. Items marked ⚙ are CI-verifiable (the reviewer confirms the signal); the rest require judgment.

**Architecture** — boundaries respected (§4) ⚙(import lint); repository not bypassed (F1–F4); development order honored; no invented cross-layer channel.
**Style** — FES §2 naming; one public type per file; no Manager/Helper/Utils; tokens-only ⚙; no literal strings/durations ⚙.
**Performance** — lists builder-based; `select()` scoping; no work in `build()`; `const` ⚙; drift queries LIMITed ⚙; no polling outside the sync loop; images sized.
**Security** — no password/cookie/token/grade in logs/analytics/errors ⚙(redaction tests); zod validation present ⚙; parameterized queries ⚙; secure-storage roles respected; deep-link params validated.
**Accessibility** — semantics on interactives ⚙; tap ≥44 ⚙; contrast via tokens ⚙; Reduce-Motion path ⚙; color not sole signal.
**Testing** — tests ship with code; state matrix / error-code / authz coverage; 100%-gate modules at 100% ⚙; QS IDs in names; invariant-asserted not implementation-asserted.
**Documentation** — corpus citations present; ADR where triggered; MANIFEST + traceability updated; PR §6 elements complete.

A change failing any judgment item is returned; a change failing any ⚙ item cannot pass CI. R1-area failures are never waivable (QS §14).

---

# 11. Future AI Collaboration

This protocol must remain binding as agents, models, and human operators change over the project's life. The mechanisms that keep it so:

## 11.1 The corpus is the memory; the agent is stateless
No agent's private context is authoritative. Everything an implementer needs is in the ten documents plus this protocol; a fresh agent with no history MUST be able to implement any unit correctly by reading the corpus. Therefore: **no decision lives only in a chat log.** A decision that matters is written into its owning document (or an ADR); an agent that "remembers" a decision not in the corpus is operating on invention (§1.3) and MUST re-derive it from, or escalate it into, the corpus.

## 11.2 Continuity protocol for a new agent
On assuming work, an agent MUST: (1) read this protocol first; (2) read the corpus sections governing its task and their deviation ledgers; (3) read the QS RTM row and IRR Ambiguity Register entries touching its task; (4) confirm the open items list (F-1, D-3, P-2, and any successors) and whether its task depends on one; (5) proceed only when it can cite the authority for every decision the task requires. It MUST NOT rely on a predecessor agent's summary in lieu of the corpus.

## 11.3 Amending the corpus (the only sanctioned way behavior changes)
When implementation reveals a genuine spec defect, the change is made **to the owning document**, through the human governance path, with: the document's version bumped, its deviation ledger updated, cross-referencing documents' ledgers updated, and — if behavior changed — the QS RTM and tests updated in the same governance act. An agent MAY draft such an amendment; it MAY NOT enact one by writing divergent code. **Code never silently leads the spec.** The invariant that made this corpus valuable — that the documents are true — is preserved only if every change flows through them.

## 11.4 Cross-agent consistency
Because all agents obey the same precedence order (§2), the same boundaries (§4), the same order (§5), and the same forbidden list (§8), two different agents implementing two features produce consistent, composable code without coordinating — the corpus is the coordination. Divergence between agents is therefore a signal that one of them departed from the constitution; the review checklist (§10) and CI gates (QS §14) catch it, and the departing change is rejected, not reconciled.

## 11.5 The standing invariant
Every future agent inherits one non-negotiable charge, from which all of the above derives:

> **Build exactly what the corpus specifies, prove it with the tests the corpus mandates, and when the corpus is silent or in conflict, stop and escalate — never invent. The product's promise is trust through reliability; an implementation that guesses has already broken it.**

---

*Ratified as NYCU Student OS AI Coding Protocol v1.0 — the implementation constitution. It consumes the ten source-of-truth documents and overrides none of them; it governs only how their decisions become code. Amendments follow §11.3. Open corpus items carried unchanged: F-1 (WebView cookie-extraction spike), D-3 (design addendum for Notification Center & Sync Health screens), P-2 (analytics consent copy).*