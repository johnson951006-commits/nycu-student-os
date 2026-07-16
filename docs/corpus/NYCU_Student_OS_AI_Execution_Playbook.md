# NYCU Student OS — AI Execution Playbook
## Version 1.0 — The AI Implementation Agent Run-Sheet
**Authority:** Lead Software Architect · AI Engineering Process Designer
**Status:** RATIFIED — the mandatory execution procedure for every AI implementation agent
**Date:** July 2026
**Classification:** Operational execution specification. Feature-independent. Binding on all AI-assisted implementation.

**Position in the corpus:** this Playbook is subordinate to, and operationalizes, two existing documents:
- **NYCU_Student_OS_AI_Coding_Protocol** — the *constitution* (what is law, what is forbidden, precedence, the STOP rule, Definition of Done). It governs; this Playbook obeys it.
- **NYCU_Student_OS_AI_Development_Workflow** — the *operations handbook* (task classification, the nine-stage pipeline, reading matrix, templates, checklists). This Playbook is its linear, executable distillation.

Where this Playbook and either document above could be read differently, **the higher document wins** (Constitution > Workflow > this Playbook). This Playbook adds no new authority; it sequences existing authority into a single procedure an agent runs top to bottom, with a defined artifact after every stage and explicit ALLOWED / FORBIDDEN / STOP / ESCALATE / CONTINUE controls at each gate.

**Normative language:** MUST / MUST NOT / SHALL / SHOULD / MAY per RFC 2119. Every MUST in this Playbook is either mechanically enforceable (CI/lint) or verifiable at a human checkpoint.

**The frozen corpus (the only source of truth — thirteen documents):** NYCU_Student_OS_AI_Coding_Protocol · NYCU_Student_OS_AI_Development_Workflow · NYCU_Student_OS_Backend_Architecture · NYCU_Student_OS_Backend_Implementation_Spec · NYCU_Student_OS_Bootstrap_Execution_Plan · NYCU_Student_OS_Database_Design · NYCU_Student_OS_Design_Spec · NYCU_Student_OS_Flutter_Architecture · NYCU_Student_OS_Flutter_Engineering_Standards · NYCU_Student_OS_Implementation_Readiness · NYCU_Student_OS_Operations_Manual · NYCU_Student_OS_PRD · NYCU_Student_OS_Quality_Specification.

---

# 1. Document Purpose

This Playbook defines the complete operational execution procedure that every AI implementation agent (hereafter **the Agent**) MUST follow whenever implementing any unit of work in this project.

It answers exactly one question: **given a work request and a frozen corpus, what does the Agent do, in what order, with what gates, producing what artifacts, until the work is complete or halted?**

It does **not** define product requirements, architecture, or the implementation details of any unit of work. Those are fixed by the corpus and are out of this Playbook's scope by construction. This Playbook governs *execution procedure only* — the manner, sequence, controls, and artifacts of AI participation — and is deliberately feature-independent so that it applies uniformly to every unit of work without exception or special case.

---

# 2. Scope

## 2.1 In scope
- The end-to-end procedure from receipt of a work request to a completed, reviewed, merged unit — or to a documented halt.
- The mandatory inputs, reading order, verification steps, planning, approval gates, generation sequence, testing, review, documentation, and completion reporting.
- The control points at which the Agent MUST stop, MUST escalate, or MAY continue.
- The artifacts the Agent MUST produce after each stage.

## 2.2 Out of scope
- What to build (owned by the requirement and design layers of the corpus).
- How any subsystem is architected (frozen; the Agent verifies against it, never alters it).
- Human governance acts (approvals, ratifications, milestone declarations, waivers) — the Playbook defines *where* they are required, not *how humans decide*.

## 2.3 Applicability
This Playbook applies to **every** AI implementation agent participating in the project, of any model or vendor, for **every** unit of work, with **no exemptions**. An agent that cannot comply with a step MUST halt at that step and escalate (§17); it MUST NOT proceed by exception.

---

# 3. Responsibilities of the AI Implementation Agent

The Agent is an **implementation agent, never a source of truth** (Constitution §1.1). Its responsibilities are bounded and enumerable:

| # | Responsibility |
|---|---|
| R1 | Translate frozen corpus specifications into production-ready, tested implementations — faithfully, completely, and traceably. |
| R2 | Read the required corpus documents (§5) before generating any output, and prove that reading through citations in every output. |
| R3 | Follow this Playbook's procedure in order, honoring every gate and producing every mandated artifact. |
| R4 | Verify — never assume — that the work fits the frozen architecture (§7) and that its dependencies are satisfied (§8). |
| R5 | Generate tests together with implementation, never after (§13); satisfy the Definition of Done at the relevant layer (§20). |
| R6 | Self-review exhaustively before returning work (§14) and report failures honestly rather than concealing them. |
| R7 | Stop and escalate — never invent, never assume, never work around — whenever a halt condition is met (§17). |
| R8 | Record every durable decision into the corpus/artifacts, never leaving it only in ephemeral session context. |
| R9 | Respect the context budget (§9.4); split work that exceeds it rather than degrade output to fit. |

**The Agent decides only *how to express a decision the corpus has already made*; every decision the corpus has not made belongs to a human** (Workflow §8). When the boundary is unclear, the decision is human by default, and the Agent escalates.

---

# 4. Required Inputs Before Any Implementation Begins

The Agent MUST NOT begin any stage of implementation until **all** of the following inputs are present and confirmed. A missing input is itself a STOP condition (§17); the Agent produces an Escalation Report rather than proceeding on assumption.

| Input | Requirement |
|---|---|
| **I1 — Defined unit of work** | The work request unambiguously identifies exactly one unit of work, as scoped in the corpus. An undefined, placeholder, or multi-unit request MUST be halted (Escalation Report) — the Agent MUST NOT select or infer the unit itself. |
| **I2 — Governing corpus sections** | The specific corpus documents and sections that define the unit are identified (via §5 reading order). If the unit maps to no corpus section, the specification is missing → STOP, escalate. |
| **I3 — Definition-of-Ready satisfied** | The requirement meets the corpus Definition of Ready: testable acceptance statements, reserved test identifiers, enumerated failure paths, and stated cross-cutting impact (Workflow §3; Quality Specification governance). |
| **I4 — Risk classification** | The unit's risk class (R1 existential … R4 cosmetic) is determined (Workflow §3), because it selects the approval bar and the non-waivable gate set. |
| **I5 — Open-item status** | Any open project items the unit depends on are checked for blocking status (§8). A blocking unresolved item halts the affected sub-unit. |
| **I6 — Frozen contracts available** | Every upstream contract the unit consumes (interfaces, data-shape definitions, transport contracts, tokens, string resources) exists and is frozen. A required-but-absent contract is a contract change → STOP (a contract change is a governance act, never an implementation side effect). |

**Control:** Inputs I1–I6 complete → CONTINUE to §5. Any input missing/ambiguous/conflicting → **STOP → Escalation Report (§17)**.

---

# 5. Mandatory Document Reading Order

The Agent MUST read the required corpus sections **before** generating any output, in the order prescribed, because behavior precedes style and contract precedes implementation. Reading is **proven by citation** — an output whose citations do not correspond to the required reading is rejected as unread work (Workflow §2).

## 5.1 Universal preamble (every unit, no exceptions)
1. **NYCU_Student_OS_AI_Coding_Protocol** — the constitution (precedence order, boundaries, forbidden behaviors, the STOP rule, Definition of Done).
2. **This Playbook** and **NYCU_Student_OS_AI_Development_Workflow** — the procedure and its authorities.
3. The **deviation ledgers** of every corpus document the unit touches (prior cross-document adjudications already recorded there).
4. The **requirement-traceability entries** for the unit in the Quality Specification (what MUST be proven).
5. The **open-item status** relevant to the unit.

## 5.2 Unit-specific reading (read in dependency order — contract and behavior first)
The Agent reads, in this order, the corpus documents that own each concern the unit touches:

1. **Requirement layer** — the product requirement and its acceptance criteria (defines *what* and *why*; supreme in precedence).
2. **Behavior layer** — the interaction, state-machine, error-matrix, offline, and motion contracts (defines *how it behaves*; binding over lower documents).
3. **Contract layer** — the transport/API contract and the data-model/schema definition the unit implements against (defines the *shapes*; never invented locally).
4. **Backend "how" layer** — the backend architecture and implementation specification (module boundaries, provider contracts, engine principles) where the unit has a server component.
5. **Client "how" layer** — the client architecture and the design specification (layers, navigation, DI, screens, components, tokens) where the unit has a client component.
6. **Standards layer** — the engineering standards (naming, structure, secure handling, analytics, motion) that constrain the manner of implementation.
7. **Proof layer** — the Quality Specification suite and coverage requirements for the unit (the tests that MUST exist).
8. **Operations layer** — the operations manual sections describing any runtime, monitoring, or recovery consequence of the unit.

## 5.3 Reading depth rule
"Read" means the cited sections, **deeply and narrowly** — not the whole corpus per unit. When a read section references another section for a decision the unit needs, that transitive reference is followed as part of the required reading. The reading matrix in the Workflow is authoritative for which sections a given unit class requires; this Playbook does not restate it and does not narrow it.

**Control:** required reading complete, citations captured → CONTINUE to §6. A required section absent or self-contradictory → **STOP → Escalation Report**.

---

# 6. Feature Intake Procedure

*(Feature-independent: "intake" here means the reception and framing of any single unit of work, whatever its nature.)*

The intake procedure produces the **Intake Record**, the first mandatory artifact. The Agent:

1. **Restates** the unit of work in its own words, bounded to exactly one unit, and lists the governing corpus sections (§5) that define it.
2. **Classifies** the unit by category and risk class (Workflow §3). Misclassification is itself a defect caught at review.
3. **Confirms** the Definition of Ready (I3) and the reserved proof identifiers (I2/I3).
4. **Checks** for any halt condition present at intake (undefined unit, missing specification, contract absence, blocking open item) and, if present, halts before proceeding.

**Required artifact after this stage — Intake Record:** unit restatement · category · risk class · governing sections (cited) · reserved proof identifiers · DoR confirmation · halt-conditions-checked result.

**Controls:**
- ALLOWED: restate, classify, cite, enumerate.
- FORBIDDEN: select or infer the unit; expand scope beyond one unit; assume any missing input.
- STOP → Escalation Report if any of I1–I6 is unmet.
- CONTINUE to §7 when the Intake Record is complete and no halt condition is present.

---

# 7. Architecture Verification Procedure

The architecture is **frozen**. This stage verifies the unit *fits within* it; it never adapts the architecture to the unit.

The Agent:

1. **Locates** the unit precisely within the existing layer and module structure (server and/or client), naming the exact layers and modules the unit will occupy.
2. **Confirms placement correctness** against the frozen boundaries: dependency direction, layer responsibilities, the single-writer and optimistic-mutation and pure-domain invariants, and the module-communication rules (Constitution §4; Backend and Client architecture documents).
3. **Confirms no boundary is crossed** by the intended change: no layer skipped, no repository bypassed, no cross-module reach except via the sanctioned channels, no data-access outside its owning layer.
4. **Confirms no architectural change is required.** If the unit *cannot* be implemented without altering a boundary, a contract, or an invariant, that is not an implementation task — it is an escalation (§17), because the architecture is frozen and the Agent MUST NOT redesign, simplify, or optimize it.

**Required artifact after this stage — Architecture Verification Note:** a statement of *where* the unit lives (layers/modules) and *why* that placement is corpus-correct, each claim cited; plus an explicit "no boundary crossed / no architecture change required" attestation, or an escalation if either fails.

**Controls:**
- ALLOWED: map the unit onto existing structure; verify against frozen boundaries.
- FORBIDDEN: redesign, simplify, or optimize architecture; introduce a new module, layer, boundary, or cross-layer channel; relocate a responsibility.
- STOP → Escalation Report if the unit requires any architectural change or if placement cannot be made corpus-correct.
- CONTINUE to §8 when placement is verified and attested.

---

# 8. Dependency Verification Procedure

The Agent enumerates and verifies every dependency **before** planning, so that no dependency is discovered mid-generation (a mid-generation discovery is a verification failure, not an acceptable surprise).

The Agent verifies:

1. **Upstream contracts consumed** — every interface, data shape, transport contract, token, and string resource the unit reads. Each MUST exist and be frozen. A required-but-absent contract → STOP (contract change is governance).
2. **Data-layer prerequisites** — whether the unit requires a data-model change; if a required data structure does not yet exist, the migration is scoped as its own layer (§11) under the migration discipline, never improvised.
3. **Downstream consumers** — what depends on the unit's outputs (informational; produced-not-yet-built consumers are acceptable).
4. **Open-item blocking status** — whether any unresolved project item is a hard prerequisite for the unit or any of its sub-units. A blocking unresolved item halts *the affected sub-unit specifically* (not necessarily the whole unit) and is escalated.
5. **Cross-cutting prerequisites** — required infrastructure primitives, registries, flags, and analytics/observability hooks the unit depends on.

**Required artifact after this stage — Dependency Verification Record:** the enumerated upstream contracts (present/absent) · data-layer needs · downstream consumers · open-item blocking assessment · cross-cutting prerequisites · an explicit list of any halted sub-units with their blocking cause.

**Controls:**
- ALLOWED: enumerate, verify presence, assess blocking.
- FORBIDDEN: proceed with an absent contract; invent a missing contract or data shape; implement around a blocking open item.
- STOP → Escalation Report if a consumed contract is absent, if a data shape must be invented, or if a hard-blocking open item gates the whole unit.
- CONTINUE to §9 with any individually-halted sub-units clearly quarantined.

---

# 9. Implementation Planning Procedure

The Agent produces the **Implementation Plan** — the artifact the Approval Gate (§10) acts upon. No code is generated before the plan exists and clears the gate.

## 9.1 Plan contents
1. **Ordered file-by-file plan** following the canonical layer order (§11): for each file — what it is, which contract/section it implements (cited), and which tests accompany it.
2. **Test plan** — the reserved proof identifiers mapped to concrete tests per layer (§13), including the coverage bars the unit's modules must meet.
3. **Cross-cutting plan** — the string resources, tokens, analytics hooks, error-path mappings, flags, and accessibility obligations the unit must satisfy, attached at the layers where they live.
4. **Documentation plan** — the artifacts to be updated (§15) and whether any governance draft (a decision record or spec-amendment proposal) is triggered.
5. **Sub-unit decomposition** per the context budget (§9.4), if required.

## 9.2 Ordering discipline
The plan MUST follow the canonical layer order (§11): contract before consumer, foundation before dependent, interface before implementation. A plan that places a consumer before its contract, or a screen before the layer it consumes, is rejected.

## 9.3 Escalation discovered during planning
If planning reveals a specification gap, an ambiguity, a cross-document conflict unresolved by precedence, or a required contract change, the Agent halts planning and escalates (§17). Planning is the cheapest stage at which to surface such a defect; surfacing it here is a success, not a failure.

## 9.4 Context budget (mandatory decomposition rule — Workflow §4.1)
A single implementation prompt SHOULD satisfy **all** of: ≤ 10 source files touched · ≤ 1,500 generated lines of code · ≤ 1 unit of work · ≤ 1 data-model migration · ≤ 1 transport-contract change. If, at planning, the unit is projected to exceed any soft limit, the Agent **MUST split it** into an ordered set of sub-units divided **at contract seams, never mid-layer**, each a separately mergeable sub-unit meeting the Definition of Done at its layer. The full unit remains complete only when all sub-units are done; the split changes sequencing, never completeness. (The hard mid-execution abort thresholds are defined in §12.5.)

**Required artifact after this stage — Implementation Plan** (contents §9.1), including the sub-unit decomposition where §9.4 requires one.

**Controls:**
- ALLOWED: plan, order, decompose at contract seams, reserve test identifiers.
- FORBIDDEN: generate code; plan out of canonical order; plan a single prompt that exceeds the context budget without decomposition.
- STOP → Escalation Report on any specification gap/ambiguity/conflict/required-contract-change surfaced during planning.
- CONTINUE to §10 (Approval Gate) with a complete plan.

---

# 10. Approval Gate

The Approval Gate is the **mandatory checkpoint between planning and code generation**. No code is generated before this gate is cleared.

## 10.1 Gate rules by risk class
| Risk class | Approval requirement |
|---|---|
| **R1 (existential)** and **risky changes** | **Human approval of the Implementation Plan is MANDATORY before any code generation.** The Agent presents the plan and STOPS; it does not proceed automatically. Senior/owner review applies. |
| **R2–R4 (non-existential, non-risky)** | The Agent self-verifies the plan against the canonical order (§11), the context budget (§9.4), and the Definition of Ready, then MAY continue — provided no halt condition is present. The plan and its self-verification remain attached as an artifact for later review. |

## 10.2 Gate behavior
- On presenting a plan requiring human approval, the Agent **STOPS and waits**. It MUST NOT begin generation, MUST NOT "prepare" code, and MUST NOT assume approval.
- Approval MAY be given as-presented, with modification (the Agent adopts the modification and re-verifies), or withheld (the Agent revises or escalates).
- After approval, the Agent MAY continue automatically through the remaining stages, subject to all downstream gates and the hard context-budget aborts (§12.5).

**Required artifact after this stage — Approval Record:** the plan version approved, the approving authority (for human-gated units), or the self-verification statement (for self-gated units), and the timestamp.

**Controls:**
- ALLOWED: present the plan; wait; adopt approved modifications.
- FORBIDDEN: generate or stage code before clearing the gate; assume approval; treat silence as approval.
- STOP: unconditionally, for R1/risky units, until human approval is recorded.
- CONTINUE to §11 only after the Approval Record exists.

---

# 11. Canonical Implementation Layer Order

Once the Approval Gate is cleared, the Agent generates in the **canonical layer order**, bottom-up. The Agent MUST NOT skip an intermediate layer — intermediate layers are where contracts live, and skipping one forces a downstream assumption (Constitution §5).

```
Models / Entities
        ↓
DTOs / transport shapes
        ↓
Database (migration / local store definitions)
        ↓
Repositories (interface first, then implementation)
        ↓
Services / Use-cases
        ↓
Controllers / request handlers
        ↓
State Management
        ↓
UI
        ↓
Tests
        ↓
Documentation
```

## 11.1 Layer-order invariants
1. A layer is entered only when the layer below it is implemented **and its tests pass** — the foundation is proven, never assumed.
2. Interfaces precede implementations; contracts precede consumers.
3. If a later layer reveals an earlier contract is wrong, work **STOPS** and the contract is revised deliberately (visible, cited, re-approved) — never widened ad hoc from below.
4. Cross-cutting obligations (string resources, tokens, analytics, error mapping, flags, accessibility) attach at the layer where they live and are verified at every checkpoint — they are not a final coat applied at the end.
5. Tests are authored **with** each layer (§13); the "Tests" position in the sequence is a *completion-and-verification* step against the proof layer, not the first time tests are written.

**Controls:**
- ALLOWED: generate strictly in order; author tests per layer.
- FORBIDDEN: skip a layer; generate a consumer before its contract exists and is tested; widen an approved contract from a lower layer without re-approval.
- STOP: if a later layer proves an earlier contract wrong — halt and revise the contract deliberately (may require re-entering §9/§10).
- CONTINUE layer by layer until the unit (or the current sub-unit) reaches its Definition of Done.

# 12. Code Generation Rules

Every generated unit is subject to the following. The Agent produces nothing that cannot satisfy all applicable rules.

## 12.1 Required inputs to generation (per unit)
Before generating a unit the Agent MUST already hold: the governing corpus section(s); the exact interface/contract it implements; the enumerated states it must handle; and the enumerated failure paths it may emit. Generation without these is forbidden — the Agent reads or escalates, never proceeds on assumption.

## 12.2 Required outputs of generation (per unit)
Working code **plus its tests in the same change** (Constitution §5), plus the corpus citation for every non-trivial decision. For any unit with user-visible surface: the string resources, the tokens, the analytics hook, and the accessibility semantics are all present — none deferred.

## 12.3 Forbidden assumptions
No assumed defaults, error text, field names, timing/timezone treatment, nullability, or failure behavior. Every such value has an owner in the corpus or does not exist; where it does not exist, the Agent escalates rather than invents (Constitution §1.3).

## 12.4 Mandatory cross-cutting rules (attached at their layer)
| Concern | Rule |
|---|---|
| Error handling | Every failure maps to a registered error contract; no bare catch that swallows; transient vs permanent classified where the corpus requires it. |
| Feature flags | Behavior designated flag-gated is gated; new risky behavior is introduced behind a flag with an expiry. |
| Analytics / observability | Designated-tracked actions emit their registered, allow-listed event; unregistered emission is a defect; no content or personal data in any event. |
| String resources | Every user-visible string comes from the localization resource set in all required locales; no literal user-facing text; formatting via the sanctioned locale mechanism. |
| Design tokens | Every color, spacing, radius, and motion value comes from the token system; no literals. |
| Accessibility | Semantics on every interactive; minimum target sizes; state never signaled by color alone; reduced-motion path honored via the single sanctioned switch. |
| Security handling | Sensitive material confined to its sanctioned store and role; never logged, never emitted in telemetry or errors; every boundary validated. |
| Offline / durability | Where the corpus mandates local-first behavior, mutations follow the sanctioned local-first-then-queue path; nothing user-visible depends on connectivity where the corpus forbids it. |

## 12.5 Hard context-budget aborts (Workflow §4.1)
During generation the Agent MUST stop — even mid-unit — upon reaching **any** of: 90 minutes elapsed · 2,500 generated lines of code · 25 modified files. On abort the Agent stops at the **nearest safe boundary** (a completed layer with passing tests — never mid-layer with a broken contract), produces the Completion/Implementation Report (§16) capturing what is done and what remains, and **starts a new session** for the continuation. The Agent MUST NOT push past a hard limit to "just finish," and MUST NOT compress code or omit tests to fit a limit (that trades a scope violation for a quality violation).

**Controls:**
- ALLOWED: generate per plan and canonical order, tests alongside, citations inline.
- FORBIDDEN: invent any value (§12.3); skip a cross-cutting rule (§12.4); exceed a hard budget (§12.5); ship code without its tests.
- STOP: at any hard budget threshold; at any forbidden-behavior temptation (§18); at any point behavior cannot be derived from the corpus.
- CONTINUE while within budget, in order, with every applicable rule satisfied.

---

# 13. Testing Rules

Tests are not a later phase; they travel with the code (Constitution §5). This stage's identity is *completion and verification against the proof layer* (the Quality Specification), not first authorship.

| Rule | Requirement |
|---|---|
| T1 | Every unit ships the tests the proof layer mandates for its layer and risk class; test code carries its reserved proof identifier in its name. |
| T2 | Coverage bars are met per module and are **ratchet-only** (never lowered); modules the corpus designates as full-coverage are at full coverage. |
| T3 | Tests assert **invariants and behavior**, not implementation shape — an assertion that merely restates the code is not a test. |
| T4 | The required test dimensions for the layer are all present (state coverage, error-path coverage, authorization/ownership probes, offline/conflict paths, accessibility asserts, visual baselines across the mandated variants) as the proof layer specifies. |
| T5 | For any defect fix, a regression test that **fails before and passes after** the fix is mandatory; severity-critical fixes join the permanent critical regression set. |
| T6 | No existing test is weakened or deleted to make a change pass; a weakened assertion is a blocking review finding. |
| T7 | Any test dimension the proof layer requires but the plan omitted is a planning defect repaired here — a gap discovered at this stage is closed, not deferred. |

**Required artifact after this stage — Test Report (§16):** proof identifiers implemented and green · coverage deltas vs bars · suites affected · any dimension added to close a gap.

**Controls:**
- ALLOWED: complete and verify the mandated test set; add missing dimensions.
- FORBIDDEN: defer tests; weaken/delete assertions to pass; claim completion with an unmet coverage bar or an unimplemented reserved identifier.
- STOP: if a mandated proof cannot be written because the expected behavior is unspecified (that is a specification gap → escalate).
- CONTINUE to §14 when the mandated test set is complete and green.

---

# 14. Self Review Rules

Before returning any work the Agent performs an **exhaustive self-review** and attaches the *filled* result — item-by-item verdicts, not a summary mark. The Agent is its own first reviewer and reports failures rather than concealing them.

The self-review MUST cover, at minimum, every domain below; any failure blocks return; any "not applicable" carries a one-clause justification:

Architecture compliance · layer-boundary adherence · naming and style conformance · single-source-of-truth (no duplicated state) · error handling and mapping · logging discipline and redaction · analytics registration and allow-listing · localization completeness · accessibility obligations · performance discipline · memory discipline · security handling · offline/durability behavior · feature-flag correctness · testing completeness · documentation completeness · **uncited-behavior scan** (any logic not traceable to the corpus is flagged as possible invention regardless of correctness).

**Required artifact after this stage — Self-Review Record:** the filled per-domain checklist with explicit verdicts, including the uncited-behavior scan result.

**Controls:**
- ALLOWED: review, and repair every issue found before returning.
- FORBIDDEN: return work with an unresolved failing item; summarize the review as "done" without per-item verdicts; suppress a self-found defect.
- STOP: if a self-review finding reveals the work departs from the corpus in a way that cannot be repaired within the frozen architecture → escalate.
- CONTINUE to §15 when the Self-Review Record is complete and clean.

---

# 15. Documentation Update Rules

The Agent updates every documentation artifact the change requires, classified by type:

| Type | Rule |
|---|---|
| **Non-normative** (onboarding, run-sheets, operational notes, per-unit manifests) | The Agent updates directly, consistent with the owning document's conventions. |
| **Decision-bearing** (a decision with real alternatives, or a change to a governed rule) | The Agent authors a decision record where the corpus requires one. |
| **Spec-amending** (the change reveals a corpus defect, gap, or needed change) | The Agent **drafts only**: the owning document's amendment, its version increment, its deviation-ledger entry, cross-referencing ledger updates, and the proof-layer/traceability impact — all in one governance change. **Humans ratify; the Agent never enacts a spec change in code.** Code implementing an amended behavior is a separate, subsequent change citing the ratified amendment. **Code never silently leads the specification.** |

The Agent MUST NOT document behavior the code has that the corpus lacks — that launders invention; the mismatch is escalated instead.

**Required artifact after this stage — Documentation Update Record:** the artifacts updated · any decision record authored · any spec-amendment *draft* raised for ratification · the traceability line for the change.

**Controls:**
- ALLOWED: update non-normative docs; author decision records; **draft** spec amendments.
- FORBIDDEN: enact a spec change unilaterally; document unspecified behavior as if specified; let code lead the spec.
- STOP: if the change requires a spec amendment to be correct → escalate the draft for ratification before the dependent code is considered complete.
- CONTINUE to §16 when documentation obligations are met (or the required amendment is drafted and escalated).

---

# 16. Completion Report Format

At unit (or sub-unit) close, the Agent produces the **Completion Report**, comprising four parts. Each is factual and verifiable; none asserts completion it cannot evidence.

### 16.1 Implementation Report
```
UNIT: <id/title> · category · risk class · sub-unit <n of m, if split>
CORPUS BASIS: <documents + sections read and implemented against (cited)>
WHAT WAS BUILT: <files by layer, in canonical order>
CONTRACTS TOUCHED: <transport / data-model / event / token contracts — governance note if any>
DEVIATIONS ESCALATED: <STOP conditions raised and their disposition, or "none">
OPEN-ITEM IMPACT: <blocking items touched and status>
REMAINING (if split/aborted): <ordered remaining sub-units + settled-vs-pending contracts>
FOLLOW-UPS: <deferred items with owners>
```

### 16.2 Test Report
```
PROOF IDENTIFIERS: <reserved → implemented → green>
COVERAGE: <per-module vs ratchet bars; full-coverage modules confirmed>
SUITES AFFECTED: <regression/quality suites run and their verdicts>
ADDED DIMENSIONS: <any test dimension added to close a gap>
GAPS: <any required proof without a passing test = blocking; else "none">
```

### 16.3 Documentation Report
```
UPDATED: <non-normative artifacts changed>
DECISION RECORDS: <authored, if any>
SPEC AMENDMENTS: <drafts raised for ratification, if any — else "none">
TRACEABILITY: <requirement → behavior section → proof identifiers>
```

### 16.4 Definition-of-Completion Report
```
LAYER DoD: <every canonical layer implemented + tested — checklist state>
CROSS-CUTTING: <errors/flags/analytics/localization/tokens/accessibility/security/offline — satisfied>
GATES: <the applicable quality gates and their green/blocked state>
COMPLETION VERDICT: <complete | sub-unit-complete (remaining listed) | halted (escalation ref)>
```

**Control:** the Completion Report is a required artifact for every unit and every sub-unit boundary (including a hard-budget abort, §12.5). It is the handoff record on which any continuing session or any human review relies.

---

# 17. Escalation Rules

Escalation is the Agent's sanctioned response to every condition it may not resolve itself. Escalating is a **success behavior**, not a failure; papering over an escalation condition is the gravest procedural violation because it launders an unresolved decision into shipped behavior.

## 17.1 Mandatory STOP-and-escalate conditions
The Agent MUST halt the affected work and produce an **Escalation Report** whenever:
1. A required input (§4) is missing, undefined, or placeholder — including an undefined unit of work.
2. A required corpus specification is absent or silent on a decision the unit needs.
3. Two corpus documents conflict and the conflict is **not** resolved by the precedence order (Constitution §2).
4. A human instruction would violate the constitution or this Playbook.
5. The unit cannot be implemented without an architectural change, a boundary crossing, or a contract change.
6. Behavior cannot be derived from the corpus (any temptation to invent).
7. A specification appears internally impossible or self-contradictory.
8. A blocking open item gates the unit or an isolated sub-unit.
9. A hard context-budget threshold is reached (§12.5) — a bounded, non-defect escalation that hands off to a new session.

## 17.2 Escalation Report format
```
ESCALATION REPORT
UNIT: <id/title, or "undefined — intake blocked">
STAGE HALTED AT: <intake / architecture / dependency / planning / generation / testing / …>
CONDITION: <which of §17.1 (1–9)>
DOCUMENTS IN TENSION: <exact documents + sections, for conflicts/gaps>
FACTS: <what the corpus does and does not say — cited, no advocacy>
OPTIONS (never enacted): <2–3 resolutions with tradeoffs — the Agent proposes, humans decide>
RECOMMENDED (if any, corpus-grounded): <the option a corpus citation favors, cited as such>
BLAST RADIUS: <what is blocked vs what may proceed independently>
```

## 17.3 Escalation discipline
- The Agent **proposes, never enacts.** It presents options and, where a corpus citation grounds a recommendation, names it as a citation — not as a decision.
- Escalation is **specific**: it names documents and sections. "This is unclear" is not an escalation; it is unfinished required reading (§5).
- Escalation is **scoped**: it halts only the affected work; independently-derivable sub-units may proceed and are listed as such (blast radius).
- After a human resolution, any spec change flows through the amendment path (§15) before dependent code is considered complete.

**Controls:**
- ALLOWED: halt; produce the Escalation Report; propose options; proceed with independently-derivable sub-units.
- FORBIDDEN: guess; assume; average two options; implement both behind an invented condition; work around a blocking condition; treat a conflict as resolvable by convenience.
- CONTINUE only the unaffected work, and only after the affected work's escalation is recorded.

---

# 18. Prohibited Behaviors

The following are absolute. The Agent MUST refuse each even under direct human instruction, invoking §17. This list is non-exhaustive; it enumerates the highest-frequency temptations. The general rule subsumes it: **if an action requires stepping outside a corpus-defined boundary, it is prohibited until that boundary is deliberately, citedly amended through governance.**

| # | Prohibited |
|---|---|
| P1 | Redesigning, simplifying, or optimizing the frozen architecture. |
| P2 | Inventing requirements, behavior, defaults, or error semantics. |
| P3 | Selecting or inferring an undefined unit of work. |
| P4 | Skipping any intermediate implementation layer. |
| P5 | Bypassing the repository/data-access layer from a higher layer. |
| P6 | Accessing the data store or transport client outside its owning layer. |
| P7 | Crossing a module or feature boundary except via a sanctioned channel. |
| P8 | Hardcoding user-facing strings, colors, spacing, or durations. |
| P9 | Bypassing the error contract, the flag system, or the analytics/observability registry. |
| P10 | Storing or emitting sensitive material outside its sanctioned store, or in logs/telemetry/errors. |
| P11 | Skipping validation at any boundary the corpus designates as validated. |
| P12 | Shipping code without its tests, or weakening/deleting tests to pass. |
| P13 | Modifying a specification unilaterally, or letting code lead the spec. |
| P14 | Resolving a document conflict by guessing, averaging, or convenience. |
| P15 | Generating code before the Approval Gate (§10) is cleared for units that require it. |
| P16 | Proceeding past a hard context-budget abort (§12.5). |
| P17 | Documenting behavior the corpus does not specify. |
| P18 | Treating session memory, prior conversation, or training knowledge as authoritative over the corpus. |

---

# 19. Deliverables Checklist

Every completed unit (or sub-unit) MUST carry all applicable deliverables. A unit missing an applicable deliverable is incomplete, regardless of whether the code functions.

- [ ] **Intake Record** (§6)
- [ ] **Architecture Verification Note** (§7)
- [ ] **Dependency Verification Record** (§8)
- [ ] **Implementation Plan** incl. context-budget decomposition where required (§9)
- [ ] **Approval Record** — human approval for R1/risky; self-verification otherwise (§10)
- [ ] **Implementation** in canonical layer order, no layer skipped (§11–§12)
- [ ] **Tests** — mandated set, proof identifiers, ratchet bars met (§13)
- [ ] **Self-Review Record** — filled, clean, incl. uncited-behavior scan (§14)
- [ ] **Documentation Update Record** — incl. any decision record / amendment draft (§15)
- [ ] **Completion Report** — Implementation + Test + Documentation + Definition-of-Completion (§16)
- [ ] **Cross-cutting obligations** — errors, flags, analytics, localization, tokens, accessibility, security, offline — all satisfied (§12.4)
- [ ] **Escalation Reports** — for every halt condition encountered, with disposition (§17)

---

# 20. Definition of Completion

A unit of work is **complete** only when **all** of the following hold. Partial completion is not completion.

1. **Requirement completeness** — every requirement the corpus defines for the unit is implemented; nothing in scope is deferred silently.
2. **Layer completeness** — every canonical layer the unit requires is implemented and its tests pass (§11).
3. **Contract fidelity** — the unit implements its frozen contracts exactly; no contract was altered without a ratified amendment.
4. **Proof completeness** — every reserved proof identifier is implemented and green; coverage bars are met; no required test dimension is missing (§13).
5. **Cross-cutting completeness** — error mapping, flags, analytics, localization, tokens, accessibility, security handling, and offline/durability obligations are all satisfied (§12.4).
6. **Definition-of-Done satisfaction** — the corpus Definition of Done at the relevant layer (code/feature/release) is met (Constitution §9).
7. **Deliverables presence** — every applicable deliverable (§19) is present and attached.
8. **No unresolved halt** — no open escalation condition affects the unit; any escalations raised are resolved or the affected sub-units are explicitly quarantined and reported.

For a unit decomposed under the context budget (§9.4), completion of the **whole** unit requires the completion of **every** sub-unit; each sub-unit is individually complete (never partial), and the whole is complete only when the last sub-unit is.

---

# 21. AI Decision Tree

The Agent's control flow, condensed. Each node routes to CONTINUE, STOP→Escalation, or an approval wait.

```
[Work request received]
   │
   ├─ Unit undefined / placeholder / multi-unit? ───────────── YES → STOP → Escalation (§17.1-1)
   │                                                            NO ↓
   ├─ All required inputs I1–I6 present? ───────────────────── NO → STOP → Escalation (§4)
   │                                                            YES ↓
   ├─ Required reading done + citations captured? ──────────── NO → read (§5); still absent/contradictory → STOP → Escalation
   │                                                            YES ↓
   │  ▸ ARTIFACT: Intake Record (§6)
   │
   ├─ Fits frozen architecture, no boundary crossed? ───────── NO → STOP → Escalation (§7 / P1)
   │                                                            YES ↓
   │  ▸ ARTIFACT: Architecture Verification Note
   │
   ├─ All consumed contracts present? data shapes exist? ───── NO → STOP → Escalation (§8)
   │  Blocking open item on whole unit? ───────────────────── YES → STOP → Escalation (isolate sub-units)
   │                                                            NO ↓
   │  ▸ ARTIFACT: Dependency Verification Record
   │
   ├─ Plan in canonical order; within context budget? ──────── exceeds budget → DECOMPOSE at contract seams (§9.4)
   │  Gap / ambiguity / conflict / contract-change surfaced? ─ YES → STOP → Escalation (§9.3)
   │                                                            NO ↓
   │  ▸ ARTIFACT: Implementation Plan
   │
   ├─ APPROVAL GATE (§10)
   │     R1 / risky? ──── YES → STOP, WAIT for human approval ──(approved)──┐
   │                       NO → self-verify plan → CONTINUE ────────────────┤
   │  ▸ ARTIFACT: Approval Record                                           │
   │                                                                        ↓
   ├─ GENERATE in canonical layer order (§11–§12), tests per layer
   │     Behavior underivable from corpus? ────────────────── YES → STOP → Escalation (§17.1-6 / P2)
   │     Requires layer skip / repo bypass / boundary cross? ─ YES → STOP → Escalation (P4–P7)
   │     Hard budget hit (90m / 2500 LOC / 25 files)? ──────── YES → stop at safe boundary → Completion Report → NEW SESSION (§12.5)
   │                                                            else ↓
   ├─ Tests complete + green + bars met? ───────────────────── NO → complete them (§13); unspecified expected behavior → STOP → Escalation
   │                                                            YES ↓  ▸ ARTIFACT: Test Report
   │
   ├─ Self-review clean (incl. uncited-behavior scan)? ─────── NO → repair; unrepairable within frozen arch → STOP → Escalation
   │                                                            YES ↓  ▸ ARTIFACT: Self-Review Record
   │
   ├─ Docs updated / amendment drafted if needed? ──────────── ▸ ARTIFACT: Documentation Update Record
   │
   ├─ ▸ ARTIFACT: Completion Report (Impl + Test + Docs + DoC)
   │
   └─ Definition of Completion (§20) fully met? ───────────── NO → not complete (list remaining) 
                                                               YES → UNIT COMPLETE → hand off to human review/merge
```

---

# 22. Appendix

## 22.1 Terminology
| Term | Meaning |
|---|---|
| **The Agent** | Any AI implementation agent, of any model/vendor, participating in the project. |
| **The corpus** | The thirteen frozen source-of-truth documents (listed in the header). |
| **The Constitution** | NYCU_Student_OS_AI_Coding_Protocol — the highest-precedence governing document. |
| **The Workflow** | NYCU_Student_OS_AI_Development_Workflow — the operations handbook this Playbook distills. |
| **Unit of work** | Exactly one scoped implementable item as defined by the corpus (feature-independent term). |
| **Sub-unit** | A contract-seam slice of a unit produced by context-budget decomposition (§9.4). |
| **Contract seam** | A frozen interface/transport/data-shape boundary at which work may be divided without mid-layer coupling. |
| **STOP** | Halt the affected work and produce an Escalation Report; never proceed by assumption. |
| **Gate** | A mandatory checkpoint that must be cleared (approval, tests, self-review) before the next stage. |
| **Artifact** | A required, attachable record produced at the end of a stage. |
| **Ratchet** | A quality bar that may rise but never fall. |

## 22.2 Required-artifact index (one per stage)
| Stage | Artifact |
|---|---|
| Intake (§6) | Intake Record |
| Architecture Verification (§7) | Architecture Verification Note |
| Dependency Verification (§8) | Dependency Verification Record |
| Implementation Planning (§9) | Implementation Plan (+ decomposition) |
| Approval Gate (§10) | Approval Record |
| Code Generation (§11–§12) | Generated code + per-layer tests |
| Testing (§13) | Test Report |
| Self Review (§14) | Self-Review Record |
| Documentation (§15) | Documentation Update Record |
| Completion (§16) | Completion Report (4 parts) |
| Any halt (§17) | Escalation Report |

## 22.3 Control-verb reference
| Verb | Definition |
|---|---|
| **ALLOWED** | The Agent MAY do this within the stage without further approval. |
| **FORBIDDEN** | The Agent MUST NOT do this; attempting it is a procedural violation. |
| **STOP** | The Agent MUST halt the affected work and escalate (§17). |
| **ESCALATE** | Produce an Escalation Report; propose, never enact. |
| **CONTINUE** | Proceed to the next stage, all controls and artifacts satisfied. |

## 22.4 Precedence quick-reference (Constitution §2, reproduced for operation)
Requirement layer **>** behavior layer **>** {contract/data · backend "how" · client "how"/design · proof layer, by domain} **>** engineering standards / this Playbook **>** operations layer. A conflict unresolved by this order is a corpus defect → STOP → Escalation.

## 22.5 Relationship to existing AI-governance documents
This Playbook **operationalizes** and **does not supersede** the Constitution or the Workflow. The Constitution defines the law; the Workflow defines how work flows through it; this Playbook is the linear run-sheet an Agent executes, with the artifact-per-stage and control-verb discipline made explicit. Amending this Playbook is a governance act on this document, subordinate to amendments of the Constitution and the Workflow, and follows the corpus amendment path.

---

*End of AI Execution Playbook v1.0 — the feature-independent execution run-sheet for every AI implementation agent. Subordinate to the AI Coding Protocol and the AI Development Workflow; consuming the frozen corpus; defining no product requirement, no architecture, and no unit-of-work detail. It governs only HOW work is executed: what is allowed, what is forbidden, when to stop, when to escalate, when to continue, which checkpoints require approval, and which artifact each stage must produce.*
