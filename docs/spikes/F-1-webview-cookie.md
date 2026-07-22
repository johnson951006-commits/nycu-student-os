# F-1 · WebView Cookie-Extraction Spike — Verdict

> ## ⚠️ STATUS: **VERDICT PENDING — DRAFT, NOT A COMPLETED SPIKE**
> This document is the **verdict-capture template** for INFRA-011. It is **not**
> a finished spike. Every field marked `❏ TO BE OBSERVED` must be filled by an
> operator running the harness (`docs/spikes/harness/`) against the **real NYCU
> Portal login** with a synthetic test account (O-2/Q-1). The redirect-detection
> pattern **must be observed, never invented** (backlog Blocking Condition).
> Until the Verdict box below reads RELIABLE or UNRELIABLE with observed
> evidence, **INFRA-011 is not complete and the AUTH client leg
> (AUTH-011/012/013) stays gated.**

## 1. What this spike decides

F-1 is the project's **#1 existential risk** (IRR §10.3 / §12.2, BEP Sprint 0).
The entire Tier-2 authentication strategy (FA §11, IRR §1.1) rests on one
unproven assumption: **that an in-app WebView can reliably (a) detect when the
user has finished authenticating on Portal's own page — including 2FA — and
(b) extract the resulting session cookie jar** to hand off to
`POST /v1/auth/portal-session`. If that assumption is false, auth cannot be
built on it and the fallback ladder (§6) must be escalated **before** AUTH work
begins. No password is ever stored, in any branch (PRD v1.1 / IRR A1).

## 2. Prerequisites (arrange before running — external, day 1)

- [ ] Real NYCU Portal login reachable (campus SSO), **synthetic test account
      only** — never a real student (OPS §2 / Q-1).
- [ ] A physical device or emulator per platform: **iOS (WKWebView)** and
      **Android (CookieManager)** — the cookie stores differ and BOTH must be
      verified (FA §11 names both).
- [ ] The real Portal login base URL(s) for `PORTAL_BASE_URLS` (do not commit;
      supplied at run time).
- [ ] A local stub of `POST /auth/portal-session` that echoes the received jar
      (the harness ships one; §4 step 6).

## 3. Method (what the operator does)

Run `docs/spikes/harness/` (see its README) on each platform and, for each run:

1. Launch the harness; it opens a WebView on the Portal login URL (cert-pinned
   in production — the spike may run un-pinned and note pinning separately).
2. Authenticate on Portal's own page, **including 2FA**, exactly as a user would.
3. The harness **logs every navigation event** (request, URL change, page
   finished) — this navigation trace is the raw material for the
   redirect-detection pattern. Capture the full trace.
4. At the authenticated landing page, trigger the harness "extract jar" action.
   It reports (a) JS-visible cookies (`document.cookie`) and (b) the platform
   cookie-store jar (Android `CookieManager.getCookie(url)` / iOS
   `WKHTTPCookieStore.getAllCookies`) filtered to Portal domains — **the
   platform store is the one that matters, because session cookies are usually
   `HttpOnly` and invisible to JS.**
5. Record which cookies are present, their domains, and their flags
   (`HttpOnly`, `Secure`, `SameSite`, expiry).
6. POST the extracted jar to the stub `/auth/portal-session`; record the result.
7. Repeat ≥5 times per platform (fresh login each time) to judge **reliability**,
   not just single-shot success.

## 4. Observations (❏ TO BE OBSERVED — fill from real runs)

### 4.1 Navigation trace → redirect-detection pattern
| Item | Observed value |
|---|---|
| Login page URL(s) | `❏ TO BE OBSERVED` |
| Intermediate 2FA / IdP hop URL(s) | `❏ TO BE OBSERVED` |
| **Authenticated-redirect signal** (the exact URL / URL-prefix / navigation event that reliably marks success) | `❏ TO BE OBSERVED — this is the F-1 deliverable; do not guess` |
| Signal type | `❏ URL exact / URL prefix / host change / query param / page-title / other` |
| False-positive risks (URLs that look done but aren't) | `❏ TO BE OBSERVED` |

### 4.2 Cookie jar
| Item | Observed value |
|---|---|
| Session cookie name(s) | `❏ TO BE OBSERVED` |
| Cookie domain(s) | `❏ TO BE OBSERVED` |
| `HttpOnly`? | `❏ yes / no per cookie` |
| Extractable from platform store (Android)? | `❏ yes / no` |
| Extractable from platform store (iOS WKHTTPCookieStore)? | `❏ yes / no` |
| Visible to `document.cookie`? | `❏ yes / no` |
| Expiry / lifetime | `❏ TO BE OBSERVED` |

### 4.3 Handoff & reliability
| Item | Observed value |
|---|---|
| Stub `/auth/portal-session` accepted the jar? | `❏ yes / no` |
| Runs attempted / clean successes (per platform) | `❏ n/n iOS · n/n Android` |
| 2FA interaction issues inside WebView | `❏ TO BE OBSERVED` |
| Reproducibility notes | `❏ TO BE OBSERVED` |

## 5. Reliability criteria (decide against these — do not soften)

Mark **RELIABLE** only if ALL hold, observed, on BOTH platforms:
- The authenticated-redirect signal is **unambiguous and stable** (§4.1) — one
  rule detects success with no false positives across all runs.
- The session cookie jar is **extractable** from the platform store (§4.2),
  even when `HttpOnly`.
- Handoff succeeded on **≥ 5/5** fresh logins per platform (§4.3), 2FA included.

Any failure of the above → **UNRELIABLE** → escalate §6.

## 6. Verdict

> ### VERDICT: `❏ PENDING` → set to **RELIABLE** or **UNRELIABLE**
>
> **If RELIABLE** — record the redirect-detection pattern here, verbatim and
> precise, as the binding input for FA §11 / AUTH-011:
> ```
> ❏ REDIRECT-DETECTION PATTERN (observed): ...
> ```
> and set §7 gating to **UNBLOCKED**.
>
> **If UNRELIABLE** — do **not** proceed with the WebView auth client leg.
> Escalate the fallback ladder in order (IRR §12.2, never stored credentials):
> 1. Accelerate the NYCU IT **SSO partnership** (institutional OAuth/OIDC).
> 2. **Reduced-cadence** sync with more frequent explicit re-auth.
> Attach a separate Escalation Report and set §7 gating to **BLOCKED (escalated)**.

## 7. AUTH client-leg gating status (Blocking Condition)

`❏ STILL GATED` — AUTH-011 / AUTH-012 / AUTH-013 **must not start** until this
document records a verdict with observed evidence. Set to `UNBLOCKED` (verdict
RELIABLE) or `BLOCKED (escalated)` (verdict UNRELIABLE) once observed.

The spike's success path, once RELIABLE, becomes **AUTH-013's E2E regression**
(backlog Required Tests).

## 8. Exit gate (BEP Sprint 0)

INFRA-011 closes when: verdict recorded with evidence · redirect-detection
pattern captured (or fallback escalated) · AUTH client-leg gating status set ·
throwaway harness branch deleted after the pattern is transcribed here.

## 9. Sign-off

| Field | Value |
|---|---|
| Operator | `❏` |
| Platform(s) run | `❏ iOS / Android` |
| Date run | `❏` |
| Verdict | `❏ RELIABLE / UNRELIABLE` |
| Reviewer | `❏` |
