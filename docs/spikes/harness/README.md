# F-1 spike harness — run instructions (THROWAWAY)

> **This is a throwaway aid, not shipped code and not a completed INFRA-011.**
> It exists to let an operator OBSERVE the real NYCU Portal login and fill the
> verdict in [`../F-1-webview-cookie.md`](../F-1-webview-cookie.md). Delete the
> spike branch once the redirect-detection pattern is transcribed there.
> **The redirect pattern is discovered by observation here — never invented.**

## Why it can't run in CI / a sandbox

It requires a **real Portal login** (synthetic test account, O-2/Q-1) on a
**device or emulator** with a WebView. There is no automated path — a human
authenticates (incl. 2FA) and reads the navigation log. This is exactly why
INFRA-011 is an operator-run spike, not an autonomous task.

## Setup (on a throwaway branch only — do NOT commit these deps)

1. Create a throwaway Flutter app (or a spike flavor) and drop
   `f1_webview_cookie_spike.dart` in as its `lib/main.dart`.
2. Add the spike-only dependencies (pin at run time; they never enter the
   production `app/pubspec.yaml`):
   ```yaml
   dependencies:
     webview_flutter: ^4.9.0
     webview_cookie_manager: ^2.0.6   # reads the platform jar incl. HttpOnly
     http: ^1.2.0
   ```
3. Start the handoff stub (any tiny server that echoes the posted jar) on
   `http://localhost:8787/auth/portal-session`, or point `HANDOFF_STUB_URL` at
   the dev backend's real endpoint.

## Run (per platform — BOTH iOS and Android are required by the verdict)

```sh
flutter run \
  --dart-define=PORTAL_LOGIN_URL=<REAL NYCU PORTAL LOGIN URL> \
  --dart-define=HANDOFF_STUB_URL=http://localhost:8787/auth/portal-session
```

## Procedure

1. Authenticate on Portal's own page (including 2FA).
2. Watch the on-screen log + console `[F1]` lines — the `URL_CHANGE` /
   `NAV_REQUEST` trace is the raw material. **Identify the single, stable signal
   that marks the authenticated landing** and record it in verdict §4.1.
3. At the authenticated page, tap **⬇ (extract jar + handoff)**. Record the
   `JAR_*`/`COOKIE` lines (names, domains, `httpOnly`) in verdict §4.2 and the
   `HANDOFF` status in §4.3. Compare against the **🍪 (document.cookie)** dump —
   if the session cookie is absent from `document.cookie` but present in the
   platform jar, that's the key HttpOnly-extractability finding.
4. Repeat ≥5 fresh logins per platform. Fill §5 criteria → §6 Verdict → §7 gating.
5. Transcribe the pattern into the verdict doc, then **delete this harness/branch.**

## Honesty note

The harness **does not decide** anything — it observes. It deliberately contains
no redirect rule; adding one before observation would be the invented-pattern
the backlog forbids. The verdict is the operator's, backed by the captured logs.
