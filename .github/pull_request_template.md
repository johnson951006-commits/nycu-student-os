<!--
Governed-artifact PR template (BEP §1.7; mirrors AI_Coding_Protocol §6).
A PR missing an applicable element cannot merge. Delete a line only with an
explicit "N/A — <reason>". Not every task exercises every row (e.g. an
infrastructure task has no ARB/migration); mark those N/A with a reason.
-->

## Task
- **Backlog Task ID:** <!-- e.g. INFRA-001 — exactly one task; no merges/splits (Backlog §0.3) -->
- **Feature:** <!-- MVP-Fn / INFRA -->
- **Traceability:** <!-- PRD FR / IRR § / QS test IDs this PR satisfies -->

## Governed-artifact checklist (AI_Coding_Protocol §6)
- [ ] **Feature checklist** (FES §4) ticked, incl. offline-run attestation where applicable
- [ ] **Tests** ship with the code; reserved QS test IDs implemented; coverage ratchets hold
- [ ] **Migration** expand-phase-safe, `CONCURRENTLY` indexes, matches DB §7 — or N/A
- [ ] **Localization** ARB entries (zh-TW + en) for new strings; ARB-diff green — or N/A
- [ ] **Accessibility** semantics on new interactives; a11y goldens; AX guards green — or N/A
- [ ] **Analytics** new tracked events registered + fired + param-allowlisted — or N/A
- [ ] **Error mapping** every new failure path maps to a registered Error-Matrix code (IRR §7) — or N/A
- [ ] **Documentation** corpus citations for non-obvious decisions; ADR if triggered; MANIFEST current
- [ ] **Tokens only** — no literal colors/durations/spacing (client) — or N/A
- [ ] **Boundaries** import matrix respected; no repository bypass; no cross-feature import
- [ ] **Self-Review Record** (Execution Playbook §14) attached
- [ ] **Completion Report** (Execution Playbook §16) attached

## Self-verification
<!-- Paste or link the Self-Review Record and Completion Report. -->

## Reviewer notes
<!-- R1-area changes require CODEOWNERS senior/security review (non-waivable, QS §14). -->
