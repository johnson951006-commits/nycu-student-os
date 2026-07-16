# NYCU Student OS — Production Operations Manual
**Author:** Principal Site Reliability Engineer
**Document Status:** Operations Manual v1.0 — production-ready runbook
**Date:** July 2026
**Reviewed corpus:** PRD v1.1 · Design Spec v1.0 · Backend Architecture v1.0 · IRR v1.1 · Database Design v1.0 · Backend Impl Spec v1.1 · Flutter Architecture v1.0 · Engineering Standards v1.0 · Quality Specification v1.0

**Purpose:** operate the system defined by the corpus. This manual does not redesign — it makes the already-specified infrastructure runnable: who is paged, what they run, what "healthy" means numerically, and how the service survives its two existential risks (Portal upstream fragility, credential-proxy sensitivity). Every threshold here derives from an upstream SLO (Backend Arch §9.2) or budget (DB §12, Standards §14); this document assigns them alarms, owners, and runbooks.

**Operating principle (SRE):** the product promise is *reliable sync* (PRD G5). Therefore the primary reliability objective is **sync freshness + notification delivery**, not raw API uptime — a fast API serving stale data has failed the user. SLOs (§5.4) and error budgets are written against that truth.

---

# 1. Production Infrastructure

## 1.1 Google Cloud architecture (region `asia-east1`, Taiwan — lowest latency to campus + Portal)

```
                          ┌────────────────────── Internet ──────────────────────┐
                          │                                                       │
                    Flutter clients (iOS/Android)                          NYCU Portal / E3
                          │ HTTPS/TLS1.3 + cert pinning                            ▲
                          ▼                                                        │ egress (allowlist)
        ┌──────────── Global External HTTPS Load Balancer ───────────┐            │
        │  Cloud Armor (WAF, rate rules, geo/IP) · Managed TLS certs │            │
        └───────────────────────────┬───────────────────────────────┘            │
                                     ▼ (serverless NEG)                            │
   ┌──────────────────────── Cloud Run (asia-east1) ────────────────────────┐     │
   │  api  ·  sync-worker  ·  notif-worker  ·  jobs   (one image, 4 services)│─────┘
   └───┬───────────┬─────────────┬──────────────┬────────────────┬──────────┘
       │ VPC connector (private egress + serverless VPC access)   │
       ▼           ▼             ▼              ▼                ▼
   PgBouncer   Memorystore    Pub/Sub       Cloud KMS        Secret Manager
   (on small   Redis (HA)   (topics+DLQ)   (envelope keys)  (secrets, mounted)
    MIG/Cloud     │             │
    Run sidecar)  │             ▼
       ▼          │      ┌─────────────┐
  Cloud SQL       │      │  Firebase   │
  PostgreSQL 16   │      │  Cloud Msg  │──▶ APNs relay / Android
  HA + read       │      └─────────────┘
  replica +       │
  cross-region    ▼
  DR replica   Cloud Storage (HTML quarantine CMEK · logical backups · symbols)
  (Tokyo)
        │
        └──▶ Cloud Trace · Cloud Logging · Cloud Monitoring · Error Reporting · Sentry (ext)
```

## 1.2 Component decisions & rationale

| Component | Decision | Rationale |
|---|---|---|
| **Cloud Run vs GKE** | **Cloud Run** for all four services | Workload is spiky and semester-cyclical (idle in breaks, storms at term start — PRD scalability NFR). Cloud Run scales to near-zero between peaks and to 40+ instances on demand with zero cluster ops; GKE's always-on node pool + operational burden buys nothing this workload needs. **Revisit trigger:** if sync workers need a persistent headless-browser pool (Playwright) for Portal parsing, that fleet moves to GKE (long-lived, resource-heavy) while api/notif stay on Cloud Run — documented in Backend Arch §2.1 extraction triggers. |
| **PostgreSQL** | Cloud SQL PG16, HA (regional), 1 read replica @≥50k users, cross-region DR replica (Tokyo) | Managed HA + PITR + automated backups; sizing ladder in DB §12 (4→8→16 vCPU). Self-managed Postgres would add patching/failover toil for no gain. |
| **Connection pooling** | PgBouncer (transaction mode) as the mandatory front door | Cloud Run's instance×pool multiplication (DB §10.2) exhausts direct backends; PgBouncer caps real backends at 4×vCPU. Deployed as a small always-on component (MIG or dedicated Cloud Run min-instance-1) inside the VPC. |
| **Redis** | Memorystore Redis 7, Standard HA tier | Cache, distributed locks, rate-limit counters, Portal circuit-breaker state (Backend Arch §5). HA tier gives automatic failover; all Redis contents are reconstructible (cache) or short-lived (locks) so a failover blip degrades, never corrupts. |
| **Pub/Sub** | Topics: `sync.jobs.interactive`, `sync.jobs.background`, `sync.events`, `notif.dispatch` + per-topic DLQ | Decouples pipeline stages; flow control + at-least-once; DLQ after 5 deliveries. Managed, zero ops. |
| **Cloud Storage** | Buckets: `quarantine` (drift HTML, CMEK, 7d lifecycle), `backups` (logical dumps, versioned, 1y), `symbols` (obfuscation maps) | Separate IAM domains per bucket; quarantine excluded from analytics access. |
| **FCM** | Single push path (Backend Impl DV1); APNs auth key uploaded to Firebase | One sender, one retry policy, one token lifecycle; shrinks vendor surface. |
| **VPC** | Custom-mode VPC; Serverless VPC Access connector; **all data-tier traffic private** (no public IP on SQL/Redis/PgBouncer) | Cloud SQL via private IP; egress to Portal through Cloud NAT with a **static IP** (so NYCU IT can allowlist us — relationship management for the existential upstream). |
| **CDN** | Cloud CDN in front of static assets only (marketing/app-config JSON if ever public) | The app is API-driven, not asset-heavy; API responses are per-user and uncacheable at edge — Redis is the app's cache tier, not CDN. |
| **Load Balancer** | Global External HTTPS LB + serverless NEG → Cloud Run | Managed certs, HTTP/2, Cloud Armor attach point, single anycast entrypoint. |
| **Cloud Armor** | WAF preconfigured rules (OWASP CRS), adaptive DDoS, per-IP rate rules, `/internal/*` blocked at edge from public | Edge defense before requests reach Cloud Run; complements app-layer rate limits (Backend §6.2). |
| **Secret Manager + KMS** | Secrets mounted at deploy (`--set-secrets`); KMS envelope keys `portal-cookies` (worker-decrypt-only IAM) | Rotation = new revision, not image rebuild (Backend Impl §1.4); credential handling per PRD/IRR (no passwords stored). |

---

# 2. Environment Strategy

| Env | GCP project | Purpose | Portal access | Data | Who deploys |
|---|---|---|---|---|---|
| **Local** | none (Docker Compose) | Inner-loop dev | Fixture Portal server (recorded HTML per `portal_versions`) | Seeded synthetic | developer |
| **Development** | `nycu-os-dev` | Shared integration; ephemeral | Fixture server | Disposable, reset nightly | CI on merge to `main` |
| **Testing/CI** | ephemeral (testcontainers + emulators) | Automated test lanes (QS §13) | Fixture server | Per-run throwaway | CI |
| **Staging** | `nycu-os-staging` | Pre-prod mirror; load/chaos/E2E | **Synthetic Portal test account only** (never real students) | Synthetic cohort (100k seed for load) | CI on `release/*` |
| **Production** | `nycu-os-prod` | Live | Real Portal (per-user cookie sessions) | Real student data (PDPA scope) | tag + gated approval |

**Isolation rules:** separate GCP projects (blast-radius + IAM boundary); no shared secrets across envs; staging touches Portal ONLY through a dedicated synthetic account (protecting the real-Portal relationship and student privacy). Prod data never flows downstream — dev/staging use synthetic seeds; any need to reproduce a prod bug uses anonymized, minimized extracts under audit.

**Configuration strategy:** typed config validated at boot (Backend Impl §1.4) — process refuses to start on invalid config. Non-secret config in Terraform per-env tfvars; secrets in per-env Secret Manager; runtime-tunable knobs (Portal rate caps, feature flags, min-supported-app-version) in the `system_settings` table so operators change them **without a deploy** (this is load-bearing for incident response — §7).

---

# 3. Deployment Strategy

## 3.1 Toolchain
- **Docker:** multi-stage → distroless non-root, read-only FS, one image for all 4 services (profile via `APP_PROFILE`), <250MB, Trivy-scanned, SBOM emitted (Backend Impl §10.2).
- **Docker Compose:** local only — api + workers + Postgres + Redis + Pub/Sub emulator + fixture Portal server; mirrors prod topology enough to catch wiring bugs.
- **Terraform:** all infra as code, per-env workspaces; alert policies, IAM, buckets, Cloud Run services, SQL, Redis, Pub/Sub, KMS all declared — reviewed with the features that need them. State in a locked GCS backend.
- **GitHub Actions:** pipeline in QS §13 / Standards §11.2.

## 3.2 Release flow (canary, the primary strategy)
```
tag vX.Y.Z
 → pre-deploy migration job (advisory-locked, expand-phase only — §4)
 → deploy new revision to Cloud Run, 0% traffic
 → smoke (RG-SMOKE) against the new revision via tag-based URL
 → canary 5% ── watch 30 min ── SLO gates: error rate, API p95, sync success, crash-free
 → 50% ── watch ── → 100%
 any gate breach → instant rollback (traffic shift to previous revision)
```
**Why canary over blue/green as default:** Cloud Run's revision traffic-splitting IS canary-native and cheaper than standing up a full parallel environment. Blue/Green is reserved for **schema-breaking or infra-topology changes** (e.g., PgBouncer swap, major PG upgrade) where a clean cutover + rehearsed switchback is safer than gradual splitting — documented per-change in an ADR.

## 3.3 Rollback strategy (doctrine)
| Change type | Rollback mechanism | Time |
|---|---|---|
| Code bug | Cloud Run traffic → previous revision | seconds; safe because expand-phase schema serves old code (§4) |
| Behavior regression | Feature-flag kill-switch (`system_settings`, ≤30s) — no deploy | ~30s |
| Bad data-shape migration | Roll **forward** with corrective migration (never blind down-migration on flowed data) | minutes–hours |
| Parser/Portal break | Worker-only revision (api untouched) or Safe Mode flag | <4h MTTR target (IRR §4.4) |
| Config error | Terraform revert or `system_settings` fix | minutes |

Golden rule: **code rolls back, schema rolls forward, behavior flips a flag.** The expand→migrate→contract discipline (DB §8) is precisely what makes "roll code back, leave schema" always safe.

---

# 4. Database Operations

| Operation | Standard | Alarm / owner |
|---|---|---|
| **Migrations** | Prisma chain + raw-SQL steps; run as advisory-locked pre-deploy job; expand→migrate→contract across ≥2 releases; `CREATE INDEX CONCURRENTLY` only (DB §8) | migration job failure → block deploy, page on-call DB |
| **Rollback** | Forward-fix for data shape; revision rollback for code (schema stays); destructive steps require rehearsed down-script + fresh snapshot noted in migration header | — |
| **Backup** | Automated daily (from HA standby), 30d retention; logical `pg_dump` monthly to `backups` bucket (CMEK, versioned, 1y) | backup-missing alert → P1 |
| **PITR** | WAL archiving; 7-day window; RPO ≈ seconds | WAL-archive lag alarm |
| **Replication** | HA regional (sync standby, auto-failover) + read replica @≥50k (replica-safe reads only: calendar/Center/history — never read-after-write, DB §12) + cross-region DR replica (Tokyo, promotable) | replica lag >5s → demote read routing + ticket; >60s → P1 |
| **Maintenance / VACUUM** | Autovacuum tuned per hot table (`todos`, `notification_schedules`, `sync_jobs` at scale_factor 0.02, DB §10.3); partition maintenance via `pg_partman` (pre-create next 2 months) | missing-future-partition → **P1** (would break inserts); dead-tuple ratio >20% on hot tables → ticket |
| **Partition drops** | Retention: `sync_runs` 3mo→BigQuery, `notification_history` semester+30d, `push_deliveries` 6mo — `DROP PARTITION` (instant, no bloat) | drop-job failure → ticket |
| **Monitoring** | Connection saturation (via PgBouncer stats), slow-query log (>1s), cache-hit ratio (SLO ≥99%), transaction age (`idle_in_transaction` kill at 30s) | cache-hit <99% → ticket; long-tx → auto-kill + log |
| **Query health gate** | The 5 hot queries (dashboard, today list, calendar range, dispatcher poll, scheduler claim) must stay index(-only) scans on the 1M-row CI dataset (DB §10.3) | seq-scan plan → CI fail (pre-prod) |

**Routine DB runbook cadence:** weekly — review slow-query top-10, dead-tuple ratios, replica lag trend; monthly — restore drill dry-run subset; quarterly — full PITR restore to scratch + checksum validation (measures real RTO, DB §9).

---

# 5. Observability

## 5.1 The four pillars (all specified upstream; here they get thresholds + ownership)
- **Metrics** — OpenTelemetry → Cloud Monitoring. App metrics registry: Backend Impl §1.7 (`sync_runs_total{status,tier}`, `notif_dispatch_lag_ms`, `fcm_send_total{result}`, `portal_page_state{page}`, `cache_hit_ratio`, `pubsub_dlq_total`, `rate_limit_rejections_total`).
- **Tracing** — W3C Trace Context; `requestId` = trace ID; span links across Pub/Sub async boundaries (Backend Impl §12.3). 10% head sampling, 100% on errors + auth + initial-sync. Client → gateway → api → worker → Portal → DB → notif → FCM navigable end-to-end.
- **Logging** — structured JSON, `userHash` (HMAC) never raw IDs, structural redaction of credentials/cookies/grades tested in CI (Backend Impl §1.6, Standards §9). Cloud Logging; 400-day retention on audit (pgAudit) tables, 30d on app logs.
- **Crash reporting** — **Sentry** (Standards §8): `beforeSend` scrubbing, W3C trace correlation, fingerprint grouping by error-code, symbol upload per release, release-health gate.

## 5.2 Dashboards (Cloud Monitoring, code-defined in Terraform)
1. **Sync Health** (the primary board): per-tier throughput, sync success rate, freshness p95, diff volume vs 7d baseline, per-page `portal_page_state`, circuit-breaker state, DLQ depth.
2. **API Golden Signals:** latency (p50/p95/p99), traffic, errors (by code), saturation (instances, PgBouncer pool).
3. **Notification Funnel:** scheduled → claimed → sent → delivered; dispatch lag; FCM result breakdown; opt-out rate.
4. **Data Tier:** connections, replica lag, cache-hit, slow queries, partition status, WAL lag.
5. **Cost & Capacity:** instance-hours, SQL CPU, Redis memory, egress, Pub/Sub volume (feeds §9).
6. **Release Health** (Sentry): crash-free sessions/users per release, adoption.

## 5.3 Alerting policy (routing)
- **P1 → PagerDuty** (on-call paged 24/7 during semester, business-hours in breaks): anything breaching an existential SLO.
- **P2 → Slack `#nycu-os-ops` + ticket:** degradation with budget remaining.
- Every P1 auto-attaches context: relevant dashboard link, trace samples, affected-user estimate, and (for parser drift) quarantine links + Safe Mode scope.

## 5.4 SLIs / SLOs / Error budgets (the contract — sync-first, per operating principle)

| SLI | SLO (28-day window) | Error budget | Alert (burn) |
|---|---|---|---|
| **Sync success rate** (runs ok+partial / total) | **≥ 99.0%** | 1% | fast-burn (2%/1h) → P1; slow-burn (10%/6h) → P2 |
| **Sync freshness** HOT tier (p95 enqueue→applied) | ≤ 7 min | — | >10 min sustained 15m → P2 |
| **Notification delivery lag** (fire_at→device p95) | ≤ 60 s | — | >120s 15m → P1 (core promise G2) |
| **API availability** (non-5xx / total) | ≥ 99.9% | 0.1% | fast-burn → P1 |
| **API latency** (dashboard GET p95, server) | ≤ 400 ms | — | >800ms 15m → P1 |
| **Crash-free sessions** | ≥ 99.5% | 0.5% | release-health gate + P2 |
| **Parser drift / anomaly rate** | < 0.1% of fetches | — | >0.1% → **P1** (silent-wrong-data risk) |
| **Portal circuit-breaker open** | < 1% of time/day | — | >30min open → P2, >2h → P1 |

**Error-budget policy:** when the sync-success or API budget for the window is exhausted, **feature releases freeze** (only reliability fixes ship) until the budget recovers — this is the mechanism that keeps velocity from eating reliability, and it is enforced at the Go/No-Go meeting (QS §15.7). Budget status is a standing agenda item.

---

# 6. Scaling Strategy

| Layer | Mechanism | Trigger / bound | Notes |
|---|---|---|---|
| **api** (Cloud Run) | horizontal autoscale on concurrency | min 2 / max 40, concurrency 80 | latency-sensitive; min 2 avoids cold-start on the hot path |
| **sync-worker** | horizontal on Pub/Sub queue depth | min 1 / max 30 | **RateGate caps effective Portal pressure regardless of instance count** — scaling workers never hammers Portal harder (the key safety property) |
| **notif-worker** | horizontal | min 1 / max 10 | spiky at deadline clusters |
| **jobs** | min 0 / max 1 | scheduler-triggered | idempotent ticks; overlap-safe |
| **Redis** | vertical (Memorystore tier resize) | memory >70% → resize | working set is small (locks + counters + hot projections); rarely the bottleneck |
| **PostgreSQL** | vertical first (4→8→16 vCPU), then read replica @≥50k | CPU >70% sustained → size up; read QPS → replica | working set stays RAM-resident to 100k (DB §12); shard-ready by key design but sharding NOT needed at this scale |
| **PgBouncer** | server pool = 4×vCPU; scale with SQL | pool saturation alarm | the real backend ceiling |

**Autoscaling doctrine:** scale the stateless tiers freely (Cloud Run); protect the two shared constrained resources — **Portal (via global RateGate, never exceed the agreed rate with NYCU IT)** and **Postgres backends (via PgBouncer)**. Adding capacity above these is not just wasteful but actively harmful (Portal blocking = existential). Semester-start capacity: pre-warm api min-instances up ahead of the known term-start Monday; the storm is predictable, so provision for it rather than autoscale into it cold.

---

# 7. Incident Response

## 7.1 Severity & escalation (aligned to QS §1.7 bug severity, but for live incidents)

| Sev | Definition | Response | Escalation |
|---|---|---|---|
| **SEV1** | Existential: sync broken fleet-wide, data loss/corruption, security breach, auth down, credential exposure | Page on-call immediately; incident commander declared; status updates /30min | → EM + Security + (breach) legal/PDPA within statutory window |
| **SEV2** | Major degradation: one sync category down (parser drift), notification delivery failing, elevated error rate with budget burning | Page on-call; fix or mitigate same shift | → EM if >2h |
| **SEV3** | Minor: single-feature impairment, workaround exists | Ticket, next business day | — |

## 7.2 On-call
- Rotation: primary + secondary, weekly handoff; **24/7 during semester** (the high-stakes window), business-hours + best-effort during breaks (load near-zero).
- Handoff checklist: open incidents, budget status, Safe Mode state, pending Portal changes, ongoing migrations.
- On-call has the authority to: flip kill-switch flags, enter/exit Safe Mode, roll back revisions, open circuit breaker manually — all `system_settings`/traffic operations requiring no deploy.

## 7.3 Runbooks (the core operational asset — one per existential failure mode)

**RB-1 · Portal parser drift (SEV2, most likely incident — PRD Risk #2)**
Trigger: `parser_drift`/`parse_anomaly` P1 alert, or `portal_page_state != active`.
1. Confirm scope on Sync Health dashboard (which page? fleet-wide or subset?).
2. Verify Safe Mode auto-engaged for the page (sanity gates + drift detection should have; if not, manually set `system_settings safe_mode` for the page — this stops any mass-archive risk).
3. Pull quarantined HTML from `quarantine` bucket + drift diff from the alert.
4. Confirm users are degraded-honest (last-known-good served, status banner shown) — not seeing wrong data.
5. Fix parser + fixtures + bump DOM version → worker-only deploy (api untouched).
6. Canary replay quarantined pages + synthetic account → green ×3.
7. Exit Safe Mode via `/internal/safe-mode`; enqueue P2 backfill for affected users.
8. Postmortem if MTTR >4h; add the drift page to the permanent fixture corpus.

**RB-2 · Portal upstream down / maintenance (SEV1/2)**
1. Circuit breaker should be open (`portal:health`); confirm.
2. Verify clients show blue "Portal maintenance" banner (not amber sign-in — that would fail-loop).
3. NO manual sync retries (would hammer a down upstream). Let breaker half-open probe.
4. If NYCU-announced maintenance: post status, set expectation window, stand down.
5. On recovery: breaker closes → auto full-incremental + "Portal is back" Center entry. Verify freshness recovers.

**RB-3 · Session-expiry storm (SEV2)** — e.g., Portal changed session policy.
1. Alert: expiry rate 5× baseline. Confirm it's real expiry vs misclassified outage (RB-2).
2. Users get one banner + can re-auth; no data loss by design — verify banner/flow working.
3. If Portal shortened session TTL: raise HOT-tier sync frequency temporarily (sliding renewal keeps sessions alive) via `system_settings` — no deploy.
4. Escalate SSO partnership conversation (the permanent fix, IRR A1).

**RB-4 · Notification delivery failure (SEV1 — core promise)**
1. Notification Funnel dashboard: where's the drop — materialize, dispatch, or FCM send?
2. FCM outage → confirm via `fcm_send_total{result}`; schedules remain pending (not lost); they drain on FCM recovery (durable queue = the design's insurance).
3. Dispatcher stalled → check loop heartbeat age; restart notif-worker revision.
4. Reassure: Notification Center entries exist regardless (written at event time) — users lose timeliness, not information.

**RB-5 · Database failover / degradation (SEV1)**
1. Cloud SQL HA auto-fails-over; confirm promotion. API serves Redis-cached reads during blip.
2. Replica lag spike → auto-demote read routing to primary (or manual).
3. Connection exhaustion → check PgBouncer pool; kill long `idle_in_transaction`.
4. Corruption suspected → PITR to pre-event on scratch instance, validate, promote (RPO ≤5min).

**RB-6 · Credential/security incident (SEV1)**
1. Rotate KMS `portal-cookies` key; revoke all `portal_sessions` (force fleet re-auth — safe, no data loss).
2. Revoke app sessions if token compromise suspected (refresh-chain revocation).
3. PDPA breach assessment + statutory notification timeline if student data exposed.
4. Preserve logs/traces; postmortem mandatory.

**RB-7 · Semester-start storm (planned SEV2 readiness)**
Pre-warm api min-instances; verify RateGate + interactive-lane reserve; watch queue depth + Portal latency; DB on the sized-up shape; this is rehearsed via the k6 load gate (QS PF-024) before each term.

## 7.4 Root cause analysis & postmortem
Blameless. Template: **Summary · Impact (users, duration, budget spent) · Timeline (UTC+8) · Root cause (5-whys) · Detection (did alerts fire? MTTD) · Resolution (MTTR) · What went well · What went wrong · Action items (owner+date) · Regression test added (the S1/S2→RG-CRIT rule, QS §12/§15.9).** Every SEV1 and any SEV2 >4h gets a postmortem within 5 business days; action items tracked to closure; the added regression test is the proof the loop closed.

# 8. Security Operations

| Area | Operational standard | Cadence / trigger |
|---|---|---|
| **Secret rotation** | JWT signing keys quarterly (JWKS 7-day overlap so no token invalidated mid-flight); FCM service account on-demand; `LOG_HASH_KEY` never (rotating it breaks log correlation — accepted, documented); DB passwords rotated via Secret Manager + new revision | quarterly + on suspected exposure |
| **KMS key rotation** | `portal-cookies` envelope key 90-day schedule; re-wrap is lazy (on next jar write) so rotation is non-disruptive | scheduled; immediate on incident (RB-6) |
| **Credential management** | No student passwords stored anywhere (IRR A1) — the strongest possible posture; Portal cookies envelope-encrypted, worker-decrypt-only IAM; app secrets in Secret Manager, mounted at deploy, never in image/logs/Terraform state | continuous; audited quarterly |
| **TLS / certificate renewal** | Google-managed certs on the LB (auto-renew); client cert-pinning (api + Portal WebView host) with primary+backup SPKI pins; **pin-rotation runbook**: ship new pin set one release BEFORE old cert retires, `sec_pinning_enforced` kill-switch as the brick-prevention valve (Standards §13) | cert lifecycle; pin update = coordinated client release |
| **IAM** | Least privilege per the role matrix (DB §11.2: app_api/app_worker/app_jobs/app_readonly/app_migrator); no superuser in any runtime path; humans reach prod only via IAP + short-lived IAM DB auth, individually identified; service accounts per Cloud Run service with minimal scopes | quarterly access review (grants diffed against DB §11.2 — drift is a finding) |
| **Firewall / network** | Custom VPC; data tier private-IP only; egress to Portal via Cloud NAT static IP (NYCU-allowlistable); `/internal/*` blocked from public at Cloud Armor; default-deny ingress except LB | reviewed on infra change |
| **DDoS protection** | Cloud Armor adaptive protection + rate rules at edge; app-layer rate limits as second line (Backend §6.2); the RateGate protects Portal from *us* amplifying an attack | continuous |
| **Security monitoring** | pgAudit (write+ddl) on Critical/Sensitive tables → Cloud Logging 400d; auth events audited (login/refresh/revoke/expiry); anomaly alerts on mass login failures, unusual egress, IAM changes; dependency + secret scanning in CI (Standards §11) | continuous; alerts → Security |
| **Compliance (PDPA)** | Data residency Taiwan (`asia-east1`); data minimization (scrape only consented categories); right-to-erasure job (Tier-A soft→30d hard purge incl. backups, DB §9/§3.0); processing register maintained; consent records (grades opt-in, analytics P-2); annual pentest before term-start peak | annual review + per-release privacy check (QS SEC-030..032) |

**Standing security invariants operators must never break:** never enable password storage; never route real-student Portal traffic through staging; never widen KMS decrypt IAM beyond the worker; never disable pgAudit on sensitive tables; never ship a cert rotation without the prior-release pin overlap.

---

# 9. Cost Optimization

Cost model tracks the workload's defining trait: **cyclical demand** (idle breaks, peak term-start/exams). Optimize for scale-to-low in troughs without sacrificing the peak SLOs.

| Cost driver | Optimization | Watch |
|---|---|---|
| **Cloud Run** | Scale-to-near-zero in breaks (workers min 1, jobs min 0); right-size CPU/memory per profile (api latency-tuned, workers throughput-tuned); concurrency 80 on api amortizes instance cost | instance-hours dashboard; alert on min-instance creep |
| **Cloud SQL** | Vertical-first ladder (don't pre-buy 16-vCPU before 100k users); committed-use discount once steady-state size is known (post-launch); read replica only @≥50k, not speculatively | CPU utilization; avoid over-provisioning |
| **Storage** | Lifecycle rules: quarantine 7d, backups tiered (Nearline after 90d, 1y total), partition drops keep hot tables lean; symbols retained per release+12mo | bucket size trend |
| **Bandwidth / egress** | Delta sync (not full pulls) keeps per-open payloads ≤50KB (DB `offline_cache_metadata` cursors); gzip; dashboard renders from local cache (0 requests) — the local-first architecture is itself the biggest bandwidth optimization | egress dashboard |
| **Redis** | Small working set (locks/counters/hot projections, all short-TTL); Standard HA tier sized to working set, not speculative headroom | memory %; resize only on real pressure |
| **Pub/Sub** | Volume dominated by sync jobs; tiering (HOT/WARM/COLD cadence) already minimizes needless syncs — a no-op sync is cheap but not free, so tiering is a cost lever too | message volume vs active users |
| **Monitoring/logging** | Log sampling (DEBUG 1%, trace 10%); 30d app-log retention (audit 400d only where required); metric cardinality controlled (bounded label sets) — observability cost can silently exceed compute if unbounded | logging ingestion volume alert |

**Cost governance:** monthly cost review against a per-active-user unit-economics target; the Cost & Capacity dashboard (§5.2) makes spend attributable; any >20% MoM jump in a driver is investigated. The cheapest infra is the sync we don't run — tiering and no-op-hash-short-circuit (DB) are reliability AND cost features.

---

# 10. Maintenance

| Activity | Procedure | Cadence / window |
|---|---|---|
| **Scheduled maintenance** | Prefer zero-downtime (rolling revisions, expand-phase schema). If ever unavoidable, schedule in a break or low-traffic window (never term-start/exam weeks); announce via in-app status banner (`system_settings`); app degrades to offline-read, never hard-down | rare; announced |
| **Database upgrade** (minor PG) | Cloud SQL maintenance window in a break; test on staging clone first; HA makes it a rolling failover | per GCP minor releases, break windows |
| **Database upgrade** (major PG) | Blue/Green (§3.2): stand up new-version replica, validate, cutover, rehearsed switchback; full restore drill on the new version first | rare; ADR-governed |
| **Dependency upgrade** | Dependabot/osv PRs; security patches expedited (SLA: CRITICAL <48h); batch non-security monthly; every upgrade through full CI + RG suites | continuous + monthly batch |
| **Flutter release** | Release train (2-weekly, Standards §11); staged store rollout gated on Sentry release health; N-2 app-version support; forced-upgrade only for security cuts (426, Backend §12.2) | 2-weekly train |
| **Backend release** | Canary (§3.2); worker-only lane for parser hotfixes; migrations expand→contract | continuous (trunk-based) |
| **Portal API/structure change response** | THE defining maintenance event (existential). Detection: canary account (hourly) + signature drift monitors fire BEFORE users are wrong. Response: RB-1. The whole system is built so this is a worker-only hotfix, not a firefight — versioned parsers, fixture corpus, Safe Mode, sanity gates limiting blast radius. Relationship: maintain the NYCU IT channel; pursue SSO/official API as the permanent de-risk | reactive (any time) + proactive monitoring always-on |

**Maintenance doctrine:** the system is designed so routine maintenance is invisible to students (rolling, expand-phase, offline-tolerant); the one maintenance event that can hurt (Portal change) is monitored-for proactively and structured as a fast worker-only fix. Never do risky maintenance during the academic high-stakes windows the product exists to serve.

---

# 11. Production Checklist

## 11.1 Pre-release
- [ ] All QS §14 CI gates green; RG-SMOKE/CRIT/PERF/SEC/AX pass on the release build
- [ ] Error budget has headroom (§5.4) — if exhausted, only reliability fixes ship
- [ ] Migrations expand-phase-safe, advisory-locked job tested on staging clone; rollback = traffic-shift verified
- [ ] Feature flags at intended state; kill-switches verified reachable (QS §15.7)
- [ ] Sentry symbols uploaded; release-health gate armed
- [ ] Real-Portal manual script passed (login+2FA, sync fidelity, notification timing)
- [ ] On-call briefed; runbooks current; Safe Mode + pending-Portal-change status known
- [ ] Go/No-Go: unanimous owner sign-off (QS §15.7)

## 11.2 Release day
- [ ] Deploy off the academic high-stakes window if possible
- [ ] Pre-deploy migration job green (advisory lock held, no concurrent deploy)
- [ ] Canary 5% → watch 30min on SLO gates (error rate, API p95, sync success, crash-free)
- [ ] 50% → watch → 100%; each step gated; any breach → instant traffic rollback
- [ ] Confirm dashboards green post-100%; sync freshness + notification lag nominal
- [ ] Announce completion in `#nycu-os-ops`

## 11.3 Post-release
- [ ] Watch Sync Health + Release Health for 24–48h (crash-free ≥99.5%, sync success ≥99%)
- [ ] Verify no error-code spikes (new codes = new failure modes)
- [ ] Confirm notification funnel healthy through a full deadline cycle
- [ ] Close the release; note any deferred items with owners
- [ ] If any SEV occurred: postmortem + regression test (S1/S2 → permanent RG-CRIT)

## 11.4 Monitoring (steady-state operator checklist)
- [ ] Daily: Sync Health glance (success rate, drift alerts, Safe Mode state), budget burn
- [ ] Weekly: DB health (slow queries, dead tuples, replica lag), quarantine bucket, flaky-test count, cost drivers
- [ ] Monthly: cost review, restore dry-run, IAM access review prep, dependency batch
- [ ] Quarterly: full PITR restore drill (measure RTO), chaos suite, pentest deltas, KMS rotation, access-grant audit vs DB §11.2

## 11.5 Rollback (execution checklist)
- [ ] Identify class (code / behavior / data / parser / config) → §3.3 mechanism
- [ ] Code: shift Cloud Run traffic to previous revision; confirm SLOs recover
- [ ] Behavior: flip kill-switch flag (`system_settings`); confirm ≤30s propagation
- [ ] Data-shape: write + deploy corrective forward migration (never blind down-migration)
- [ ] Parser: worker-only revision or Safe Mode flag
- [ ] Verify: dashboards return to nominal; affected users reconcile; postmortem opened

---

# Deliverables Index

| Deliverable | Where |
|---|---|
| **Deployment Guide** | §3 (toolchain, canary/blue-green, rollback doctrine) + §11.1–11.2 |
| **Infrastructure Diagram** | §1.1 (+ component decisions §1.2) |
| **Operations Handbook** | this document (whole); routine cadences in §4/§5.2/§11.4 |
| **SRE Runbook** | §7.3 (RB-1..7) + §7.1–7.2 (severity, on-call) |
| **Monitoring Guide** | §5 (pillars, dashboards, alerting, SLI/SLO/error-budget) |
| **Disaster Recovery Plan** | §4 (backup/PITR/replication/DR replica, RTO≤1h/RPO≤5min) + RB-5 + §11.4 quarterly drill |
| **Production Checklist** | §11 (pre/day/post/monitoring/rollback) |
| **Incident Response Manual** | §7 (severity, escalation, runbooks, RCA/postmortem) |
| Security Operations | §8 |
| Cost Optimization | §9 |
| Maintenance (incl. Portal-change response) | §10 |
| Scaling Strategy | §6 |
| Environment Strategy | §2 |

*End of Production Operations Manual v1.0. The system is operable: every existential failure mode has a runbook, every SLO an alarm and owner, every routine a cadence. Guiding truth carried from the corpus — reliability of sync IS the product (PRD G5); operations optimize for that, not for vanity uptime. Open cross-document items unchanged: F-1 (WebView spike), D-3 (design addendum), P-2 (analytics consent copy).*
