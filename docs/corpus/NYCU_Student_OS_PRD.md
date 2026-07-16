# Product Requirements Document (PRD)
## NYCU Student OS
**Author:** Senior Product Manager, Apple
**Reviewed & Revised by:** Principal Product Manager (Apple) · Product Lead (Notion)
**Document Status:** Draft v1.1 — Revised
**Date:** July 2026

---

## 0. Revision Log (v1.0 → v1.1)

Scope of this revision: targeted fixes only. Strong sections (Vision, Goals, Personas, User Journey, Success Metrics, Roadmap structure) are preserved verbatim. Each change below records *what* changed and *why*.

| # | Area | Sections touched | Revision | Reasoning |
|---|------|------------------|----------|-----------|
| R1 | Authentication strategy | §5.1, §6 (FR-1), §10 | Replaced the single OAuth assumption with a two-tier strategy: (1) Official OAuth/SSO preferred, (2) Secure Session Cookie Synchronization fallback. Added explicit session-expiration behavior. Passwords are never permanently stored. | v1.0 assumed infrastructure NYCU may never provide — a launch-blocking dependency hiding inside one sentence. A tiered design de-risks launch while keeping the preferred path open. |
| R2 | Assignment sync source | §5.3, §7, §8, §10 | Removed Gmail parsing from MVP scope. Assignments sync directly from Portal/LMS only. Email integration demoted to an optional post-MVP plugin. | Email parsing contradicts the "single source of truth" vision (G1) and carries unbounded failure modes (misparse → missed deadline → permanent churn), directly threatening the trust goal (G5). |
| R3 | Notification preferences | §5.4, §6 | Added a three-level preference model: Global → Per-course → Per-assignment, with explicitly defined behavior when notifications are disabled at each level. | A one-size-fits-all toggle forces students into all-or-nothing; granular control is the actual mechanism behind the <10% opt-out target (§9). |
| R4 | Calendar / hidden assignments | §5.5, §5.7 | When a per-assignment notification is turned OFF, the assignment is hidden from Calendar, Upcoming Assignments, and Dashboard unless "Show Hidden Assignments" is enabled. Data is never deleted. | Muting must be consistent across every surface, or students keep seeing "ghost" items they explicitly silenced — inconsistency reads as a bug and erodes trust. |
| R5 | Todo provenance | §5.9, §6 (FR-9) | Every todo now carries a visible source label: `Source: Portal` or `Source: Manual`. | Provenance is trust. Students must always be able to distinguish what the system asserts (synced) from what they authored — especially when a synced item looks wrong. |
| R6 | Offline mode | New §5.13, §7 | Promoted offline support from a single NFR row to a full feature spec: cached data, last-sync timestamp, offline-functional Todo/Sticky Notes/Calendar, sync features disabled while offline. | Campus dead zones (basements, shuttle, MRT) make offline a *daily* reality, not an edge case. One NFR row was not implementable as written. |
| R7 | Sync status visibility | New §5.14 | Added a persistent Synchronization Status component ("Last Sync · 2 minutes ago · ✓" / "Sync Failed · Retry"). | G5 states trust is built through reliability — but reliability must be *visible* to be trusted. Silent sync is indistinguishable from broken sync. |
| R8 | Data ownership | New §12, §7 | Added a Data Ownership & Privacy section: users own Todos, Sticky Notes, Notification Preferences, Settings; account deletion removes personal data. | Ownership was implied but never stated. PDPA compliance and student trust both require an explicit, testable commitment. |
| R9 | Notification Center | New §5.15 | Added an in-app Notification Center with reviewable history (e.g., "Deadline changed · Homework 4 · Jul 20 → Jul 25"). | Push notifications are ephemeral; a swiped-away banner about a moved deadline is lost forever. High-stakes changes need a durable, reviewable record. |
| R10 | Sync health transparency | New §5.16 | Added a Data Synchronization health page with per-category status (Portal ✓ / Assignments ✓ / Schedule ✗ Retry). | A single "sync failed" is unactionable. Category-level status turns confusion (and support tickets) into self-service recovery. |

---

## 1. Product Vision

NYCU Student OS is the single, trusted academic workspace for every National Yang Ming Chiao Tung University student. It replaces a fragmented daily ritual — checking the Portal for grades, scanning Gmail for assignment announcements, manually copying deadlines into a paper planner, and hoping nothing was missed — with one calm, reliable system that already knows a student's courses, deadlines, and schedule the moment they log in.

Where the current experience is reactive (students must go hunting for information across five disconnected systems), NYCU Student OS is proactive: it pulls the data to the student, organizes it automatically, and surfaces only what matters, when it matters.

**Vision statement:**
*"One login. Every class, every deadline, every day — organized automatically, so students spend their time studying, not searching."*

---

## 2. Product Goals

| # | Goal | Why it matters |
|---|------|-----------------|
| G1 | Consolidate all academic data (courses, assignments, deadlines, schedule) into a single source of truth | Eliminates the need to check Portal, Gmail, and personal calendars separately |
| G2 | Reduce missed assignments and deadlines to near-zero | Missed deadlines are the #1 self-reported academic stressor among surveyed students |
| G3 | Give students an honest, real-time view of their semester workload and progress | Reduces anxiety by replacing uncertainty with visibility |
| G4 | Make daily academic planning a sub-1-minute habit | Drives daily active usage and long-term retention |
| G5 | Build trust through reliability of sync, not feature volume | A student who is burned once by a missed sync will churn permanently |

---

## 3. Personas

### Persona 1 — "The Juggler" (Primary)
- **Name:** Chen Yu-Ting, 2nd-year Computer Science student
- **Behavior:** Takes 6 courses, part-time TA job, active in two clubs. Currently uses a mix of Apple Calendar, Notes, and Portal, but still misses assignment deadlines because announcements are buried in Gmail.
- **Needs:** One place that tells her exactly what's due and when, without her having to check five apps every morning.
- **Quote:** "I don't need another app. I need my existing chaos to organize itself."

### Persona 2 — "The Freshman"
- **Name:** Lin Po-Wei, 1st-year Electrical Engineering student
- **Behavior:** New to university systems, doesn't yet have habits or workarounds. Portal's interface is confusing to him; he has already missed one assignment because he didn't see the Gmail notification.
- **Needs:** A guided, low-friction way to see "what do I have going on this week" without needing to learn Portal's navigation.
- **Quote:** "I didn't even know the assignment existed until it was late."

### Persona 3 — "The Grad Researcher"
- **Name:** Wu Chia-Hsin, 1st-year Master's student
- **Behavior:** Fewer courses, but high-stakes deadlines (thesis proposal, TA duties, lab meetings) mixed with coursework. Needs to distinguish academic deadlines from research/personal tasks in one coherent view.
- **Needs:** Flexible task management layered on top of automatic academic sync.
- **Quote:** "My calendar has three categories of chaos. I need them to coexist, not compete."

---

## 4. User Journey (End-to-End)

**Stage 1 — Onboarding**
Student downloads app → logs in once via NYCU Portal credentials → grants sync permissions → app auto-imports current semester's courses, timetable, and assignments → Dashboard populates within seconds.

**Stage 2 — Daily Use**
Student opens app in the morning → Dashboard shows today's classes, due assignments, and countdown to next exam → student checks off completed Todo items → adds a personal Sticky Note reminder for a group meeting → notification arrives later reminding of an assignment due in 24 hours.

**Stage 3 — Weekly Planning**
Student reviews Weekly Timetable and Weekly Completion Rate every Sunday night → adjusts Todo priorities for the coming week → checks Semester Progress to gauge overall pacing.

**Stage 4 — Exam Season**
Countdown to Exams becomes the most-viewed widget → Smart Deadline Notifications increase in frequency and specificity → Calendar view consolidates exam dates, review sessions, and assignment due dates in one visual field.

**Stage 5 — Retention Loop**
Because the data is always accurate (auto-synced, not manually entered), the student never has a reason to "go back" to Portal or Gmail — the app becomes the default habit.

---

## 5. Feature-by-Feature Specification

---

### 5.1 NYCU Portal Login

**User Story**
As a student, I want to log in once using my existing NYCU Portal credentials, so that I don't need to create or remember a new account.

**Problem**
Students already manage too many credentials. A separate signup flow adds friction and reduces adoption.

**Solution** *(revised v1.1 — see Revision Log R1)*

Authentication follows a **two-tier strategy**, in strict priority order. The app must not assume NYCU provides OAuth or any official API.

**Tier 1 — Official OAuth / SSO (Preferred).**
If (or when) NYCU IT provides an OAuth 2.0 / SSO endpoint, the app authenticates via the official flow. The app receives only scoped access tokens; it never sees, handles, or transmits the student's password. This is the target end-state and the subject of the partnership track in §11.

**Tier 2 — Secure Session Cookie Synchronization (Fallback).**
Where no OAuth/SSO exists, the student authenticates **directly against NYCU Portal's own login page** rendered in an in-app secure web view (real Portal domain, certificate-validated). The app never intercepts the password field; it captures only the **resulting session cookies** after Portal itself completes authentication (including any Portal-side 2FA). Those cookies are what the sync engine uses.

**Credential handling rules (both tiers, non-negotiable):**
- The student's password is **never permanently stored** — not on device, not on servers, not in logs. In Tier 2 it exists only transiently inside Portal's own login page.
- Only **session-related information** (cookies/tokens) is stored, and only **encrypted** (AES-256-GCM or platform equivalent; Keychain/Keystore on device, KMS-envelope encryption server-side).
- Optional Face ID / Touch ID gates app re-entry; it never substitutes for Portal authentication.

**Session Expiration Behavior** *(explicit specification)*
1. Portal sessions expire on Portal's schedule (idle timeout, forced password reset, semester rollover). The app must treat expiry as a **normal, expected state**, not an error.
2. On expiry detection: sync pauses for that account; the app displays a clear, non-alarming prompt — *"Your NYCU Portal session has expired. Sign in again to resume syncing."* — via banner and (at most once) a push notification.
3. While expired: **all locally cached data remains fully accessible** (read-only for synced data; Todos and Sticky Notes remain fully editable). Nothing is wiped. The Sync Status component (§5.14) shows the expired state and last successful sync time.
4. Re-login repeats the Tier-2 flow (Portal's own page). After success, sync resumes automatically and reconciles any changes missed during the gap.
5. The app never retries stored credentials against Portal (it stores none) — eliminating any risk of triggering Portal account lockouts.

**User Flow**
1. Student opens app for the first time.
2. Taps "Sign in with NYCU Portal."
3. In-app secure web view loads NYCU's official login page (Tier 1: OAuth consent page; Tier 2: Portal login page).
4. Student enters credentials on **NYCU's page**; completes 2FA if required by school.
5. Grants data-access consent (courses, assignments, schedule) inside the app.
6. Returns to app; Dashboard begins populating. The active authentication method (SSO vs. session sync) is visible in Settings → Account.

**Edge Cases**
- Portal is down or under maintenance → app shows cached last-known data with a clear "last synced" timestamp (§5.14).
- Incorrect credentials → error is surfaced by Portal's own page; the app adds no ambiguity of its own.
- Portal enforces periodic password resets → app detects the expired session and prompts re-login per the Session Expiration Behavior above, without losing local data (Sticky Notes, Todos).
- Session expires mid-sync → the in-flight sync aborts cleanly; last-known-good data is retained; expiration prompt follows.
- Student has multiple roles (e.g., TA + student) → app asks which role's data to prioritize on Dashboard.

**Acceptance Criteria**
- [ ] Login succeeds using valid Portal credentials in under 5 seconds on stable network.
- [ ] The student's password is never written to persistent storage (device or server) in any form; verified by security audit.
- [ ] Only encrypted session information is stored; no plaintext session material at rest.
- [ ] Session expiry produces the specified re-login prompt within one sync cycle of detection, and never destroys local data.
- [ ] Session persists across app restarts until Portal-side expiry or explicit logout.
- [ ] The active authentication tier is visible to the user in Settings.

**Future Expansion**
- Formal SSO/OAuth partnership with NYCU IT promotes all users from Tier 2 to Tier 1 transparently.
- Multi-account support for dual-degree or exchange students.

---

### 5.2 Automatic Course Synchronization

**User Story**
As a student, I want my enrolled courses to appear automatically in the app, so that I never have to manually re-enter my schedule.

**Problem**
Students currently rebuild their schedule by hand in Calendar or Notes apps each semester, and it falls out of sync when courses change.

**Solution**
Background sync job pulls enrolled course list, meeting times, locations, and instructors from Portal at login and on a recurring schedule (e.g., every 6 hours, plus manual pull-to-refresh).

**User Flow**
1. After login, app queries Portal for current semester's course list.
2. Courses are parsed and mapped into the app's internal schedule model.
3. Timetable and Calendar auto-populate.
4. Background refresh silently checks for changes (added/dropped courses, room changes).

**Edge Cases**
- Course added/dropped mid-semester → app detects diff and notifies student of the change rather than silently overwriting.
- Duplicate or cross-listed courses → deduplication logic before display.
- Room/time changes announced late by department → app flags "recently changed" with a visual badge for 48 hours.
- Sync failure mid-semester → app retains last successful state, displays sync-error banner, retries with backoff.

**Acceptance Criteria**
- [ ] 100% of a student's officially enrolled courses appear within one sync cycle of login.
- [ ] Course changes (add/drop/time/room) reflected within the next scheduled sync.
- [ ] No duplicate course entries under normal conditions.
- [ ] Manual refresh option always available and functional.

**Future Expansion**
- Push-based sync (instant update when Portal record changes) instead of polling.
- Cross-referencing course syllabi (if available) to pre-populate assignment types.

---

### 5.3 Assignment Synchronization

**User Story**
As a student, I want all assignments from my courses to automatically appear in one list, so that I don't have to dig through Gmail or course pages to find them.

**Problem**
Assignment announcements are scattered across Gmail, course announcement pages, and sometimes only mentioned verbally in class — leading to missed or late submissions.

**Solution** *(revised v1.1 — see Revision Log R2)*
Assignments are synchronized **directly and exclusively from the university Portal / LMS (E3)** into a unified assignment list, tagged by course, due date, and type. Email parsing is **explicitly out of scope for the MVP**: it contradicts the single-source-of-truth vision, and a misparsed email that causes one missed deadline would permanently destroy trust (G5). The authoritative academic record is the Portal/LMS; anything not present there is handled by the manual-add flow.

**User Flow**
1. Background sync detects new assignment postings tied to enrolled courses.
2. Assignment is added to the unified list with course tag, due date, and description.
3. Student receives a lightweight in-app badge (not necessarily a push notification) confirming a new assignment was found.
4. Assignment appears in Dashboard, Calendar, and Todo-linked views.

**Edge Cases**
- Assignment has no explicit due date (professor says "next class") → app flags as "date needed," prompts student to set manually.
- Assignment is announced only outside Portal/LMS (email, verbally in class) → not auto-captured in MVP by design; the manual-add flow (≤3 taps from the assignment list) is the sanctioned path, and manually added items are first-class citizens in every view.
- Duplicate postings across Portal and LMS surfaces → deduplication by course + title + approximate date.
- Assignment deleted/cancelled by professor → app archives rather than deletes, so student sees history.

**Acceptance Criteria**
- [ ] New Portal-based assignments appear in-app within one sync cycle.
- [ ] Each assignment entry shows course, title, due date/time, and source.
- [ ] Ambiguous or missing due dates are visually distinguished from confirmed ones.
- [ ] Students can manually edit or add assignments not caught by sync.

**Future Expansion**
- **Email integration as an optional, opt-in plugin (post-MVP only).** If ever built, it ships as a separately installable capability with confidence-scored parsing, mandatory manual confirmation of low-confidence items, and its own consent flow — never as a silent default source. It supplements, and never overrides, Portal/LMS data.
- OCR/parsing of PDF syllabi to pre-populate the full semester's assignment calendar on day one.
- Professor-side integration allowing direct structured assignment posting.

---

### 5.4 Smart Deadline Notifications

**User Story**
As a student, I want to be reminded of upcoming deadlines at the right time, so that I never miss a submission without being spammed by alerts.

**Problem**
Generic, one-size-fits-all reminders either come too late to act on or arrive so frequently that students disable notifications entirely.

**Solution** *(revised v1.1 — see Revision Log R3)*
An adaptive notification engine that scales reminder timing and frequency based on assignment weight (quiz vs. final project), time remaining, and the student's historical completion patterns — governed by a **three-level preference hierarchy**, all three of which are MVP scope:

| Level | Scope | Example |
|---|---|---|
| **Global** | All notifications app-wide: master toggle, default reminder intervals, quiet hours, digest preference | "Quiet hours 23:00–08:00" |
| **Per-course** | Overrides global for one course: toggle + interval override | "Linear Algebra → reminders ON, 1 day + 3 hours before" |
| **Per-assignment** | Overrides course setting for one item | "Linear Algebra · Homework 4 → Notification **ON**"; "Homework 5 → Notification **OFF**" |

Resolution rule: **most specific setting wins** (assignment > course > global). Every notification's detail view shows which level produced it, so behavior is never mysterious.

**Behavior when notifications are disabled** *(explicit specification)*
- **Global OFF:** no push notifications are sent at all. In-app surfaces still show urgency: an in-app banner surfaces urgent (<24h) deadlines on next open, and the Notification Center (§5.15) continues to record all events. Deadlines and assignments remain fully visible everywhere.
- **Per-course OFF:** no push reminders for that course's items. The course's assignments remain visible in all views (Calendar, Dashboard, Todo); Notification Center still logs changes silently. This is "mute," not "hide."
- **Per-assignment OFF:** no push reminders for that item — **and the assignment is additionally hidden from Calendar, Upcoming Assignments, and Dashboard** (see §5.5 for the full cross-surface specification and the "Show Hidden Assignments" recovery path). The item is never deleted: it remains in the Todo list's "All" view with a muted 🔕 indicator, and can be un-hidden at any time. The moment the student turns a per-assignment toggle OFF, a one-time inline explanation states exactly this behavior.

**User Flow**
1. Assignment synced with a due date.
2. Engine resolves the effective preference (assignment > course > global), then calculates the reminder schedule (e.g., 3 days, 1 day, 3 hours before — adjustable).
3. Notification delivered via push at calculated intervals; each is also recorded in the Notification Center (§5.15).
4. If student marks the task complete early, remaining reminders for that item are cancelled automatically.
5. Student can flip the per-assignment toggle from the assignment's detail view; per-course from the course page; global from Settings → Notifications.

**Edge Cases**
- Multiple deadlines cluster on the same day → notifications are batched into a single digest rather than sent separately.
- Student disables notifications globally → in-app banner still surfaces urgent (<24h) deadlines on next open; Notification Center keeps a complete record.
- Deadline changes after a reminder was scheduled → old reminders cancelled, new ones recalculated automatically against the effective preference level.
- A per-course OFF course receives a new assignment → item appears normally in all views (muted push only); no silent data loss.
- Student re-enables a per-assignment toggle after OFF → item reappears in all views immediately and its reminder schedule regenerates from the current time (past-dated reminders are skipped, not fired retroactively).
- Time zone differences (e.g., exchange student traveling) → all times anchored to device local time with explicit time zone label.

**Acceptance Criteria**
- [ ] All three preference levels (global, per-course, per-assignment) are available in MVP, with assignment > course > global resolution.
- [ ] Reminder schedule automatically generated for every synced assignment with a due date, honoring the effective preference.
- [ ] Disabling notifications at any level triggers the specified explanation of resulting behavior at the moment of disabling.
- [ ] No duplicate notifications for the same deadline within a 1-hour window.
- [ ] Completed tasks stop generating further reminders within 60 seconds of being marked done.
- [ ] Students can customize default reminder intervals in settings; per-course and per-assignment overrides persist across syncs.

**Future Expansion**
- Machine-learning personalization based on individual completion behavior (e.g., "you usually start 2 days early — reminder moved accordingly").
- Location-aware reminders (e.g., notify when leaving dorm without submitting an assignment due today).

---

### 5.5 Calendar

**User Story**
As a student, I want a unified calendar showing classes, assignments, and exams together, so that I can see my whole academic life in one view.

**Problem**
Students currently maintain separate mental (or app-based) calendars for classes vs. deadlines, making conflict-spotting and planning harder than it should be.

**Solution**
A month/week/day calendar view that merges auto-synced course sessions, assignment due dates, and exam dates into a single color-coded, filterable timeline.

**Hidden Assignments behavior** *(added v1.1 — see Revision Log R4)*
When a student turns a **per-assignment notification OFF** (§5.4), that assignment is treated as *hidden* and is consistently removed from:
- the **Calendar** (all views — month, week, day),
- the **Upcoming Assignments / Due Soon** lists,
- the **Dashboard** modules,

**unless** the **"Show Hidden Assignments"** setting is enabled (available both as a calendar filter toggle and in Settings → Notifications). With the setting on, hidden items reappear rendered at reduced opacity with a 🔕 indicator, clearly distinguished from active items.

Invariants:
1. Hiding is a *view-layer* state — the assignment is never deleted, its sync continues, and its completion status still counts toward Weekly Completion Rate (§5.10) so statistics stay honest.
2. The item always remains reachable in the Todo list's "All" view (§5.9) with its muted indicator — there is exactly one guaranteed home for every item, hidden or not.
3. Re-enabling the assignment's notification (or tapping "Unhide" on the item) restores it to every surface immediately.
4. If a hidden assignment's deadline changes, the change is still recorded in the Notification Center (§5.15) — silently, with no push.

**User Flow**
1. Student opens Calendar tab.
2. Default view shows current week with classes, due assignments, and exams layered together.
3. Student taps a date to see full-day detail.
4. Student can filter by category (classes only / deadlines only / exams only) or by course.

**Edge Cases**
- Overlapping events (two deadlines same time) → stacked display, not overlap-hidden.
- Recurring class sessions with an exception (holiday cancellation) → app reflects academic calendar holidays, not just raw recurrence.
- Very dense exam weeks → month view uses density indicators instead of listing every item, to avoid clutter.
- All of a day's assignments are hidden (per-assignment OFF) → the day renders as genuinely free; with "Show Hidden Assignments" on, muted items reappear so the student can audit what was silenced.

**Acceptance Criteria**
- [ ] Calendar displays classes, assignments, and exams in one merged view by default.
- [ ] Assignments with per-assignment notifications OFF are excluded from Calendar, Upcoming Assignments, and Dashboard by default, and reappear (visually muted) when "Show Hidden Assignments" is enabled.
- [ ] Hiding/unhiding an assignment propagates to all surfaces within the same app session, with no data loss.
- [ ] Filtering by category/course updates the view instantly (<300ms perceived latency).
- [ ] Month, week, and day views are all available and navigable.
- [ ] Holidays/academic calendar exceptions correctly suppress cancelled class instances.

**Future Expansion**
- Two-way sync with Apple Calendar/Google Calendar for students who want a single external source of truth.
- Shared/group calendar view for team projects or club schedules.

---

### 5.6 Weekly Timetable

**User Story**
As a student, I want to see my class schedule laid out by day and hour, so that I know exactly where I need to be at any given time.

**Problem**
Portal's timetable view is often clunky, non-mobile-friendly, and disconnected from the rest of a student's planning tools.

**Solution**
A clean, grid-based weekly timetable auto-populated from synced course data, with tap-through detail (room, instructor, next session) and visual current-time indicator.

**User Flow**
1. Student opens Timetable tab (or views it embedded in Dashboard).
2. Grid shows Monday–Sunday (or Monday–Friday, configurable) across class hours.
3. Current day/time is highlighted with a live indicator line.
4. Tapping a class block shows room, instructor, and quick links to related assignments.

**Edge Cases**
- Back-to-back classes in different buildings → app can optionally show walking-time warning if location data is available.
- Elective/irregular meeting patterns (biweekly labs) → correctly rendered only on applicable weeks, not every week.
- Student has zero classes on a given day → timetable shows a clear "no classes" state rather than an empty grid.

**Acceptance Criteria**
- [ ] Timetable accurately reflects all synced course meeting times without manual entry.
- [ ] Current-time indicator updates in real time while the view is open.
- [ ] Biweekly/irregular sessions render only on correct weeks.
- [ ] Tapping any class block surfaces full detail within one interaction.

**Future Expansion**
- Campus map integration showing walking routes between back-to-back classes.
- Widget for iOS/Android home screen showing "next class in X minutes."

---

### 5.7 Dashboard

**User Story**
As a student, I want a single home screen that summarizes everything I need to know today, so that I don't have to navigate multiple tabs every morning.

**Problem**
Even with synced data, students need a fast, glanceable summary — not another set of tabs to click through every day.

**Solution**
A modular home screen combining: today's classes, due-soon assignments, active Sticky Notes, Todo highlights, Weekly Completion Rate, Semester Progress, and Exam Countdown — in a prioritized, customizable layout.

**User Flow**
1. Student opens app; Dashboard is the default landing screen.
2. Top section: today's schedule at a glance.
3. Middle section: urgent/due-soon items (assignments, todos).
4. Bottom section: progress indicators (completion rate, semester progress, exam countdown).
5. Student can long-press to reorder or hide modules.

**Edge Cases**
- New student with no data yet (before first sync) → Dashboard shows an onboarding empty state, not a blank/broken screen.
- Extremely busy day (10+ items) → Dashboard shows top 3–5 most urgent items with a "view all" expansion, not a full unfiltered dump.
- Assignments hidden via per-assignment notification OFF (§5.4/§5.5) → excluded from all Dashboard modules unless "Show Hidden Assignments" is enabled; the Dashboard obeys the same hidden-assignment invariants as the Calendar. *(added v1.1 — R4)*
- Module reordering conflicts with future auto-suggested layouts → user customization always takes precedence over any smart defaults.

**Acceptance Criteria**
- [ ] Dashboard loads within 2 seconds on a typical connection.
- [ ] All modules reflect live, synced data — no stale placeholders after initial load.
- [ ] Students can reorder/hide/show modules, and preferences persist across sessions.
- [ ] Empty states are shown gracefully for new users or slow days.

**Future Expansion**
- AI-generated daily briefing ("You have 2 assignments due today and one quiz Friday — here's a suggested plan").
- Cross-device Dashboard sync (start on iPhone, continue on iPad/Mac).

---

### 5.8 Sticky Notes

**User Story**
As a student, I want to jot down quick personal reminders that aren't tied to a formal assignment, so that I can capture thoughts without friction.

**Problem**
Not everything a student needs to remember comes from Portal — group project notes, personal reminders, and quick thoughts need a home too, but shouldn't be forced into the formal Todo/assignment structure.

**Solution**
A lightweight, freeform sticky-note feature with optional color-coding and optional date/location tagging, pinned to Dashboard or Calendar as desired.

**User Flow**
1. Student taps "+" on Dashboard or Notes tab.
2. Types a quick note ("bring laptop charger to group meeting").
3. Optionally assigns a color, pins to a specific date, or leaves it freeform.
4. Note appears on Dashboard and/or Calendar if dated.

**Edge Cases**
- Note left untouched for a long time → no forced expiration, but app may gently suggest archiving stale notes after a configurable period.
- Note contains sensitive personal info → notes are stored locally/encrypted, never parsed or scanned for ad/analytics purposes.
- Very long note text → truncated in card view with "expand" interaction, not silently cut off.

**Acceptance Criteria**
- [ ] Notes can be created, edited, and deleted in under 3 taps from Dashboard.
- [ ] Dated notes appear correctly on the corresponding Calendar day.
- [ ] Notes persist reliably across app restarts and re-logins.
- [ ] No sync/data loss when switching between Wi-Fi and cellular mid-edit.

**Future Expansion**
- Handwriting/Apple Pencil support on iPad.
- Shared sticky notes for group project collaboration.

---

### 5.9 Todo List

**User Story**
As a student, I want a task list that combines auto-synced assignments with my own manually added tasks, so that I have one place to track everything I need to do.

**Problem**
Assignment sync alone doesn't cover personal academic tasks (e.g., "review Chapter 4," "email professor") — students need a flexible task layer on top of the automated one.

**Solution** *(revised v1.1 — see Revision Log R5)*
A unified Todo list where synced assignments appear automatically alongside manually created tasks, with due dates, priority levels, and course tagging. **Every todo carries a mandatory, always-visible source label** so students can instantly tell what the system asserts versus what they authored:

| Example item | Source label |
|---|---|
| Homework 4 | `Source: Portal` |
| Buy Calculator | `Source: Manual` |

Source semantics: `Portal` items are system-maintained (title/due date update on sync; the student's completion state and local overrides are preserved per FR-14). `Manual` items are entirely student-owned and untouched by sync. The source label is data, not decoration — filters and sorting can group by it, and it can never be edited or spoofed.

**User Flow**
1. Student opens Todo tab; sees auto-synced assignments pre-populated.
2. Student adds a manual task via "+" button, optionally tagging a course and due date/priority.
3. Student checks off completed items; completed items move to a collapsed "done" section.
4. List can be sorted by due date, priority, or course.

**Edge Cases**
- Student manually completes a task that's actually still incomplete in Portal (e.g., assignment resubmission required) → app allows "reopen" without data conflict.
- Auto-synced assignment is manually deleted by student → app treats this as "hidden," not deleted from source, and can be restored.
- Conflicting priority tags on multiple items due the same day → sorting logic breaks ties by due time, then manual order.

**Acceptance Criteria**
- [ ] Synced assignments appear as Todo items automatically, labeled `Source: Portal`.
- [ ] Every todo displays its source (`Portal` / `Manual`) in both list and detail views; the label is system-assigned and immutable.
- [ ] Manual tasks can be created, edited, prioritized, and deleted independently of sync, and are labeled `Source: Manual`.
- [ ] Completion status is reflected instantly in Weekly Completion Rate calculations.
- [ ] Sorting/filtering options function correctly and persist per user preference.

**Future Expansion**
- Subtasks/checklists within a single Todo item (e.g., breaking a project into steps).
- Siri/voice-based quick task entry.

---

### 5.10 Weekly Completion Rate

**User Story**
As a student, I want to see what percentage of my planned tasks I actually completed each week, so that I can gauge how well I'm keeping up.

**Problem**
Students often have no objective sense of whether they're falling behind until it's too late (e.g., right before finals).

**Solution**
A calculated metric (completed tasks / total tasks due that week) displayed as a simple visual (ring or bar), with week-over-week comparison.

**User Flow**
1. App tallies all Todo items and assignments due within the current week.
2. As items are checked off, completion percentage updates live.
3. Dashboard and a dedicated Progress view show current rate plus trend vs. prior weeks.

**Edge Cases**
- Student adds/removes tasks mid-week → denominator recalculates dynamically without misleading spikes/drops.
- A week with zero assigned tasks → shown as "no tasks this week" rather than a misleading 0% or 100%.
- Retroactively marking old tasks complete → historical week's rate updates, clearly labeled as "recalculated."

**Acceptance Criteria**
- [ ] Completion percentage recalculates within seconds of any task status change.
- [ ] Weekly boundaries are clearly defined (e.g., Monday–Sunday) and consistent across the app.
- [ ] Historical weekly rates are viewable for at least the current semester.
- [ ] Zero-task weeks are handled gracefully, not as errors or misleading percentages.

**Future Expansion**
- Personalized insights ("Your completion rate drops on weeks with 3+ exams — plan ahead next time").
- Optional social/anonymous benchmarking against course-mates (opt-in only, privacy-preserving).

---

### 5.11 Semester Progress

**User Story**
As a student, I want to see how far along I am in the semester at a glance, so that I can pace my workload appropriately.

**Problem**
Without a visual anchor, it's easy to lose track of how much of the semester remains, leading to poor time allocation (procrastination early, panic late).

**Solution**
A simple progress bar/ring showing percentage of semester elapsed, based on official academic calendar start/end dates, with key milestones (midterms, add/drop deadline, finals) marked along it.

**User Flow**
1. App pulls official semester start/end dates (and key milestones) from the academic calendar.
2. Dashboard displays a progress bar updating daily.
3. Student taps the bar to see a detailed milestone timeline.

**Edge Cases**
- Semester dates change (rare administrative update) → progress bar recalculates automatically on next sync, no manual fix needed.
- Summer session or non-standard term lengths → progress logic adapts to the specific term's actual start/end rather than assuming a standard 18-week semester.
- Withdrawal or leave of absence mid-semester → student can pause/hide this module without deleting historical data.

**Acceptance Criteria**
- [ ] Progress percentage is accurate to within one day of the actual semester calendar.
- [ ] Key milestones (midterms, finals, add/drop) are visually marked and tappable for detail.
- [ ] Module updates automatically at the start of a new semester without manual reset.
- [ ] Works correctly for non-standard term lengths (summer sessions, etc.).

**Future Expansion**
- Personalized pacing suggestions ("You're 40% through the semester with 60% of assignments remaining — consider front-loading next week").
- Multi-semester/degree-progress view (long-term graduation tracking).

---

### 5.12 Countdown to Exams

**User Story**
As a student, I want a clear countdown to my next exam, so that I can mentally and practically prepare with the right sense of urgency.

**Problem**
Exam dates are often buried in Portal or announced in class, and students lose track of exactly how much time remains until it's suddenly "next week."

**Solution**
A prominent countdown widget (days/hours) for the next upcoming exam, pulling from synced course/exam data, with support for multiple simultaneous countdowns during exam season.

**User Flow**
1. Exam dates synced from Portal (or manually added if not yet posted officially).
2. Dashboard displays countdown to the nearest exam by default.
3. Student can tap to see all upcoming exams ranked by proximity.
4. As exam date passes, countdown automatically rolls to the next one.

**Edge Cases**
- Multiple exams on the same or adjacent days (exam week crunch) → countdown module shows a stacked list rather than only the single nearest one.
- Exam date/time changes after initial sync → countdown updates immediately, with a "changed" indicator shown briefly.
- No exam data yet posted for a course → module shows "not yet scheduled" instead of silently omitting the course.

**Acceptance Criteria**
- [ ] Countdown accurately reflects real time remaining, updating at minimum daily (hourly during final 48 hours).
- [ ] Multiple upcoming exams are viewable, not just the single nearest one.
- [ ] Manually added exam dates (for courses without synced data) are supported and clearly labeled as manual.
- [ ] Countdown auto-advances to the next exam once one has passed, with no manual reset required.

**Future Expansion**
- Integrated study-plan suggestions counting backward from exam date.
- Stress-aware notification pacing (avoid notification overload in the final 24 hours before an exam).

---

### 5.13 Offline Mode *(added v1.1 — see Revision Log R6)*

**User Story**
As a student, I want the app to keep working when I have no connection — in a basement lecture hall, on the shuttle, on the MRT — so that my academic information is always available when I need it.

**Problem**
v1.0 treated offline as a single non-functional line item. In reality, students hit connectivity gaps daily; an app that blanks out offline fails exactly when it's needed (walking to class, checking a room number underground).

**Solution**
A local-first cache architecture. All synced data (courses, assignments, exams, timetable, calendar) is persisted on device and rendered instantly from cache. Fully user-owned features remain **fully functional offline**; sync-dependent features degrade gracefully and honestly.

| Capability | Offline behavior |
|---|---|
| Dashboard / Calendar / Timetable | Fully viewable from cached data |
| **Todo** | Full create/edit/complete/delete — changes queued locally |
| **Sticky Notes** | Full create/edit/delete — stored locally by design |
| **Calendar** | Full navigation of all views; dated notes can be added |
| Last Synchronization Time | Always displayed while offline ("Offline — showing data from 09:41") |
| Portal sync, manual refresh | **Disabled**, with the control visibly inactive and labeled — never a spinner that silently fails |
| Login / re-auth | Unavailable offline; clearly explained if attempted |

**User Flow**
1. Device loses connectivity → app switches to offline state within seconds; an unobtrusive banner shows "Offline — showing data from [last sync time]."
2. Student continues reading schedule/calendar and editing Todos/Notes normally.
3. Connectivity returns → banner clears, queued local changes reconcile, and a background sync runs automatically.

**Edge Cases**
- Local edits to a Portal-sourced todo (e.g., completed offline) while the server state also changed → local user-state (completion, priority) wins for user-owned fields; academic fields (title, due date) take the server value, per FR-14 override rules.
- Offline for many days → staleness is communicated by the ever-present last-sync timestamp; data older than 7 days additionally shows a stronger staleness notice.
- First launch with no network → login is impossible; the app explains why and offers retry, rather than showing a broken empty shell.
- Notifications while offline → locally scheduled reminders (already materialized on device) still fire; new/changed reminders resume on reconnect.

**Acceptance Criteria**
- [ ] All previously synced data renders from cache with no network, with no functional regression in read paths.
- [ ] Todo and Sticky Notes support full CRUD offline; changes persist across app restarts and reconcile on reconnect without loss.
- [ ] Last Synchronization Time is visible whenever the app is offline.
- [ ] All sync-dependent actions are visibly disabled offline with a plain-language explanation.
- [ ] Reconnection triggers automatic reconciliation and a fresh sync without user intervention.

**Future Expansion**
- Offline-aware conflict review UI for rare divergent edits.
- Pre-fetch heuristics (e.g., cache next week's data more aggressively before weekends).

---

### 5.14 Synchronization Status *(added v1.1 — see Revision Log R7)*

**User Story**
As a student, I want to always know whether Portal synchronization is working, so that I can trust what the app shows me — or know precisely when not to.

**Problem**
Trust through reliability (G5) requires reliability to be *visible*. Without an explicit status, a silently failing sync is indistinguishable from a healthy one — and the first missed deadline caused by an invisible failure churns the user permanently.

**Solution**
A persistent, glanceable Synchronization Status component, present on the Dashboard header and in Settings, with exactly four states:

| State | Display | Behavior |
|---|---|---|
| Synced | `Last Sync · 2 minutes ago · ✓` | Quiet, green indicator |
| Syncing | `Syncing…` (animated) | Non-blocking |
| **Failed** | `Sync Failed · [Retry]` | Amber/red indicator; one-tap Retry; taps through to the Data Synchronization page (§5.16) for detail |
| Offline | `Offline — data from 09:41` | Links to Offline Mode explanation |

Relative timestamps ("2 minutes ago") refresh live; absolute time shown on tap.

**Edge Cases**
- Repeated failures → status shows failure persistently but never modal-blocks the app; retry uses backoff so the Retry button can't hammer Portal.
- Session-expired failure cause → status message says so specifically and deep-links to re-login (§5.1), not to a generic retry.
- Partial sync (some categories succeeded) → status reads "Partially synced" and defers detail to §5.16 rather than lying with a ✓.

**Acceptance Criteria**
- [ ] Sync status with last-sync time is visible on the Dashboard at all times, in all four states.
- [ ] A failed sync surfaces the failure within one sync cycle, with a functioning Retry action.
- [ ] Status transitions (syncing → success/failure) reflect reality within 5 seconds of the sync outcome.
- [ ] The component never blocks interaction with cached data.

---

### 5.15 In-App Notification Center *(added v1.1 — see Revision Log R9)*

**User Story**
As a student, I want to review past notifications inside the app, so that an important change I swiped away — or never received because my phone was off — is never lost.

**Problem**
Push notifications are ephemeral by design. A dismissed banner announcing "deadline moved" leaves no trace; students are left wondering whether they imagined it. High-stakes academic changes need a durable, reviewable record.

**Solution**
A chronological, in-app Notification Center (bell icon, badge for unread) recording every notable system event, independent of whether a push was sent:

| Event type | Example entry |
|---|---|
| Deadline changed | `Deadline changed · Homework 4 · Jul 20 → Jul 25` |
| New assignment detected | `New assignment · Linear Algebra · Homework 6 · due Aug 2` |
| Course/schedule change | `Room changed · Machine Learning · EC-122 → EC-315` |
| Exam scheduled/changed | `Exam scheduled · OS Midterm · Jul 19 13:20` |
| Reminders sent | `Reminder · ML Lab 2 due in 24 hours` |
| Sync issues | `Sync failed twice · last success 08:12 · [Retry]` |

Each entry deep-links to the relevant item. Entries are retained for the current semester. Push and the Center are **mirrored but independent**: disabling push (any level, §5.4) never disables the Center — it becomes the muted student's single honest record.

**Edge Cases**
- Event affecting a hidden assignment → recorded in the Center (no push), consistent with §5.5 invariant 4.
- Notification storm during exam weeks → Center groups same-day events per course, expandable.
- Entry references an item later archived by the professor → entry remains, links to the archived item's read-only view.

**Acceptance Criteria**
- [ ] Every deadline change, new assignment, schedule change, and sync failure creates a Center entry within one sync cycle, regardless of push settings.
- [ ] Entries deep-link to their subject and are retained for at least the current semester.
- [ ] Unread state is tracked and cleared per entry; badge counts match unread entries.
- [ ] Center remains readable offline (cached).

---

### 5.16 Data Synchronization Page *(added v1.1 — see Revision Log R10)*

**User Story**
As a student, I want to see exactly which part of synchronization failed, so that I know whether my assignment list is trustworthy right now — and can fix what's fixable myself.

**Problem**
A single global "sync failed" is unactionable: did courses fail? Assignments? Everything? Ambiguity creates either misplaced distrust of good data or misplaced trust in stale data.

**Solution**
A synchronization health page (reached from the Sync Status component §5.14 or Settings → Sync) showing per-category status:

```
Portal connection      ✓   authenticated · session healthy
Courses                ✓   last success 2 min ago
Assignments            ✓   last success 2 min ago
Schedule / Timetable   ✗   failed 3 times · last success 08:12   [Retry]
Exams                  ✓   last success 2 min ago
```

Per category: current state (✓ / syncing / ✗), last successful sync time, plain-language failure explanation ("Portal's timetable page didn't respond — your schedule is shown as of 08:12"), and a per-category **Retry**. A global "Sync everything now" action sits at top. Sync history (recent runs with outcomes) is available for the diagnostically curious.

**Edge Cases**
- Portal connection itself is down → dependent categories show "waiting on Portal" rather than independent scary ✗ marks (one root cause, one message).
- Session expired → the page states it explicitly and routes to re-login (§5.1) instead of offering futile retries.
- Category never yet synced (new user mid-first-sync) → "syncing…" with progress, not failure.

**Acceptance Criteria**
- [ ] Each sync category (Portal connection, courses, assignments, schedule, exams) reports independent status with last-success time.
- [ ] Failed categories expose a working per-category Retry (rate-limited with backoff).
- [ ] Failure explanations are plain-language, bilingual, and name the affected data's staleness.
- [ ] Root-cause suppression: an upstream Portal/auth failure does not render as multiple unrelated category failures.

---

## 6. Functional Requirements

| ID | Requirement |
|----|-------------|
| FR-1 | The system shall authenticate users against NYCU's identity system using a two-tier strategy: official OAuth/SSO where available, otherwise Secure Session Cookie Synchronization. Passwords shall never be permanently stored; only encrypted session information may be persisted. *(revised v1.1)* |
| FR-2 | The system shall automatically synchronize enrolled courses, including schedule, room, and instructor data. |
| FR-3 | The system shall automatically synchronize assignments with due dates directly from the university Portal/LMS. Email parsing shall not be a data source in the MVP. *(revised v1.1)* |
| FR-4 | The system shall generate adaptive notification schedules per assignment/exam, resolved through the three-level preference hierarchy (FR-15). |
| FR-5 | The system shall present a unified Calendar merging classes, assignments, and exams. |
| FR-6 | The system shall render a weekly grid-based Timetable from synced course data. |
| FR-7 | The system shall provide a customizable Dashboard aggregating key modules. |
| FR-8 | The system shall allow creation, editing, and deletion of freeform Sticky Notes. |
| FR-9 | The system shall provide a Todo list combining synced and manually created tasks, with a mandatory visible source label (`Portal` / `Manual`) on every item. *(revised v1.1)* |
| FR-10 | The system shall calculate and display Weekly Completion Rate based on task status. |
| FR-11 | The system shall calculate and display Semester Progress based on academic calendar dates. |
| FR-12 | The system shall display a Countdown to Exams, supporting multiple concurrent exams. |
| FR-13 | The system shall retain last-known-good data and clearly indicate sync status when live data is unavailable. |
| FR-14 | The system shall allow manual override/edit of any auto-synced data point without breaking future syncs. |
| FR-15 | The system shall provide notification preferences at three levels — global, per-course, and per-assignment — with most-specific-wins resolution. *(added v1.1)* |
| FR-16 | The system shall hide assignments whose per-assignment notifications are disabled from Calendar, Upcoming Assignments, and Dashboard, unless "Show Hidden Assignments" is enabled; hidden items shall never be deleted and shall remain reachable in the Todo "All" view. *(added v1.1)* |
| FR-17 | The system shall operate offline: displaying cached data with last-sync time, keeping Todo, Sticky Notes, and Calendar functional, and visibly disabling synchronization features. *(added v1.1)* |
| FR-18 | The system shall display a persistent Synchronization Status component (last sync time, success/failure, retry). *(added v1.1)* |
| FR-19 | The system shall provide an in-app Notification Center recording reviewable notification history, independent of push settings. *(added v1.1)* |
| FR-20 | The system shall provide a Data Synchronization page reporting per-category sync health with per-category retry. *(added v1.1)* |
| FR-21 | The system shall treat Todos, Sticky Notes, Notification Preferences, and Settings as user-owned data, and shall delete all personal data upon account deletion (§12). *(added v1.1)* |

---

## 7. Non-Functional Requirements

| Category | Requirement |
|----------|-------------|
| Performance | Dashboard must load in under 2 seconds on a typical campus Wi-Fi/4G connection. |
| Reliability | Background sync must succeed at least 99% of the time under normal Portal availability; failures must degrade gracefully to cached data. |
| Security | All credentials and personal academic data must be encrypted at rest and in transit; no plaintext credential storage. |
| Privacy | No email parsing in the MVP (see §5.3, R2). User-owned data (Todos, Sticky Notes, Notification Preferences, Settings) is governed by §12 Data Ownership; no student data used for advertising or sold to third parties. *(revised v1.1)* |
| Accessibility | UI must meet WCAG 2.1 AA standards, including support for Dynamic Type and VoiceOver/TalkBack. |
| Availability | App must function offline per §5.13: cached data readable, Todo/Sticky Notes/Calendar fully functional, last-sync time always shown, sync features visibly disabled. *(revised v1.1)* |
| Scalability | Backend sync infrastructure must support the full NYCU student population (tens of thousands of concurrent users) without degraded performance during peak periods (semester start, exam weeks). |
| Localization | UI must support both Traditional Chinese and English, matching Portal's bilingual environment. |
| Maintainability | Sync logic must be modular so changes to Portal's structure require isolated updates, not full system rewrites. |

---

## 8. Feature Priority (MoSCoW)

**Must Have (MVP Core)**
- NYCU Portal Login (two-tier authentication, §5.1)
- Automatic Course Synchronization
- Assignment Synchronization (Portal/LMS direct only, §5.3)
- Smart Deadline Notifications **with three-level Notification Preferences** (§5.4) *(v1.1)*
- Calendar (including Hidden Assignments behavior, §5.5)
- Weekly Timetable
- Dashboard
- **Synchronization Status component** (§5.14) *(v1.1 — sync trust is the core product promise; it cannot ship invisible)*
- **Offline Mode** (§5.13) *(v1.1 — daily campus reality; the cache architecture must be foundational, not retrofitted)*

**Should Have**
- Todo List (with source labels, §5.9)
- Countdown to Exams
- Semester Progress
- **In-App Notification Center** (§5.15) *(v1.1)*
- **Data Synchronization Page** (§5.16) *(v1.1)*

**Could Have**
- Sticky Notes
- Weekly Completion Rate

**Won't Have (this release)**
- **Email-parsing integration — deferred to an optional, opt-in post-MVP plugin (§5.3)** *(moved from implied MVP scope, v1.1)*
- Two-way external calendar sync (Apple/Google Calendar)
- AI-generated study plans / daily briefings
- Shared/collaborative notes for group projects
- Campus map / walking-time integration

---

## 9. Success Metrics

| Metric | Target | Purpose |
|--------|--------|---------|
| D1/D7/D30 retention | ≥70% D7, ≥45% D30 | Measures whether the app becomes a daily habit |
| Sync success rate | ≥99% per sync cycle | Core trust metric — broken sync kills adoption |
| Missed-deadline rate (self-reported or inferred) | Reduce by ≥40% vs. pre-adoption baseline | Directly validates the core mission |
| Dashboard daily open rate | ≥1.5 opens/day among active users | Confirms Dashboard is the daily entry point |
| Notification opt-out rate | <10% | Confirms notifications are perceived as useful, not spammy |
| Weekly Completion Rate feature engagement | ≥50% of active users view weekly | Validates progress-tracking value |
| App Store / campus NPS | ≥40 | Overall satisfaction signal |

---

## 10. Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| NYCU Portal has no official API and blocks scraping/automated login | Critical — breaks core sync | Medium | Pursue formal partnership/API access with NYCU IT early; build resilient fallback parsing with rate-limiting and graceful degradation |
| Portal structure changes without notice, breaking sync | High | Medium | Modular sync architecture; automated monitoring/alerts for sync failures; rapid patch process |
| Students distrust an app handling their Portal credentials | High | Medium | Two-tier auth (§5.1): passwords are entered only on NYCU's own login page and never stored; only encrypted session cookies persist; auth method visible in Settings; migrate all users to official SSO/OAuth when available *(revised v1.1)* |
| Notification fatigue causes opt-out | Medium | Medium | Adaptive/batched notification engine; user-configurable frequency |
| Low initial adoption due to habit inertia (students already have workarounds) | High | Medium | Strong onboarding that proves value in the first session (instant populated Dashboard); campus ambassador/launch partnership with student government |
| University policy/legal constraints on handling student academic data | High | Low-Medium | Early legal review; data minimization; clear compliance with Taiwan's Personal Data Protection Act (PDPA) |
| Portal session-cookie fallback (Tier 2) breaks if Portal changes its login flow | High | Medium | Login flow monitored by synthetic canary account; session expiry is a designed-for state (§5.1) so breakage degrades to a re-login prompt, never data loss; parallel pursuit of Tier-1 SSO removes the dependency *(replaced Gmail-parsing risk, which is out of MVP scope — v1.1)* |

---

## 11. Roadmap

**Phase 0 — Foundation (Pre-Launch, ~8 weeks)**
- Secure Portal data-access approach (Tier-1 SSO partnership track + Tier-2 session-cookie fallback, §5.1)
- Build core sync engine (courses, assignments) on a local-first cache foundation (§5.13)
- Build Login, Dashboard, Calendar, Timetable, Sync Status component (Must Have set)

**Phase 1 — MVP Launch (Semester Start)**
- Ship Must Have feature set to a pilot group (e.g., one college or department)
- Instrument success metrics from day one
- Rapid-response support channel for sync issues

**Phase 2 — Core Expansion (Weeks 4–10 post-launch)**
- Ship Todo List, Countdown to Exams, Semester Progress
- Ship In-App Notification Center (§5.15) and Data Synchronization page (§5.16)
- Iterate on notification tuning based on opt-out data
- Expand rollout campus-wide

**Phase 3 — Engagement Layer (Weeks 10–16)**
- Ship Sticky Notes, Weekly Completion Rate
- Introduce Dashboard customization
- Localization polish (Traditional Chinese/English parity)

**Phase 4 — Intelligence & Ecosystem (Semester 2+)**
- External calendar two-way sync
- AI-generated daily briefings and study-plan suggestions
- Shared notes for group projects
- Explore official NYCU IT partnership for native SSO and guaranteed API stability

---

## 12. Data Ownership & Privacy *(added v1.1 — see Revision Log R8)*

**Principle:** the student is the owner of everything they create; the app is merely a custodian of a mirror of their academic record.

### 12.1 Ownership model

| Data category | Owner | Examples | On account deletion |
|---|---|---|---|
| **User-owned data** | **The student** | Todos (manual items and completion states), Sticky Notes, Notification Preferences, Settings (dashboard layout, language, reminder intervals) | **Permanently deleted** |
| Synced academic mirror | NYCU (source); app holds a cached copy | Courses, assignments, exams, timetable | Cached copy deleted; source untouched |
| Session/credential material | The student | Encrypted session cookies (no passwords are ever stored — §5.1) | Revoked and deleted immediately |
| Operational telemetry | App (pseudonymized) | Sync success metrics, crash reports | De-identified; carries no student identity |

### 12.2 Commitments

1. **Account deletion removes personal data.** Deleting an account removes all user-owned data and session material — immediately from active systems, and from backups within 30 days. The flow is self-service (Settings → Account → Delete), requires confirmation, and states exactly what is removed.
2. **Export before deletion.** Students may export their user-owned data (Todos, Notes, preferences) in a portable format at any time, including as a step in the deletion flow.
3. **No secondary use.** User-owned content (notes, todos) is never parsed, scanned, or analyzed for advertising, profiling, or any purpose other than rendering it back to its owner (reaffirms §5.8).
4. **Minimal collection.** The app requests only the data scopes consented to at onboarding (§5.1); revoking a scope stops its collection and offers deletion of the already-cached category.
5. **Regulatory baseline.** All handling complies with Taiwan's Personal Data Protection Act (PDPA), including access, correction, and erasure rights.

### 12.3 Acceptance Criteria
- [ ] Account deletion removes all user-owned data and session material from active systems immediately and from backups within 30 days, verified by audit.
- [ ] Data export produces a complete, portable copy of user-owned data.
- [ ] The ownership table above is reflected verbatim in the in-app privacy explanation (Settings → Privacy), in both Traditional Chinese and English.
- [ ] No user-owned content ever appears in analytics or advertising pipelines, verified by data-flow review.

---

*End of Document*
