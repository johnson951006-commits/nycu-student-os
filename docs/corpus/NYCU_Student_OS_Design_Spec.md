# NYCU Student OS — Complete UI Design Specification
**Author:** Senior Product Designer (ex-Apple HIG / Notion Design Systems)
**Document Status:** Design Spec v1.0 — Production Ready
**Date:** July 2026
**Companion Document:** NYCU_Student_OS_PRD.md
**Deliverable Type:** Figma Specifications only — no code

---

# Part 0 — Design Philosophy

Five words govern every decision in this file: **Minimal. Modern. Premium. Simple. Fast.**

| Principle | What it means in practice |
|---|---|
| **Calm by default** | The app never shouts. One accent color, generous whitespace, information revealed progressively. Urgency is expressed through hierarchy, not decoration. |
| **Content is the interface** | Like Things 3 and Apple Calendar: chrome disappears, data breathes. No borders where spacing can do the job. |
| **Deference (Apple HIG)** | UI defers to content. Blur materials, subtle depth, no heavy skeuomorphism. |
| **Speed is a feature** | Every screen is designed for a sub-1-minute morning ritual. The most important answer ("what do I do today?") is visible in 0 taps. |
| **Trust through honesty** | Sync state, "last updated" timestamps, and confidence flags are first-class UI citizens, never buried. |
| **One system, three canvases** | Phone, Tablet, Desktop share one token set and one component library. Layout adapts; identity never changes. |

**Reference DNA:**
- **Apple Calendar** → event color semantics, month/week/day paradigm, current-time indicator
- **Things 3** → checkbox interaction, Today/Upcoming mental model, whitespace discipline
- **Notion** → modular dashboard blocks, hover affordances, quiet iconography
- **Linear** → keyboard-first desktop mode, command palette, speed, dark mode craft
- **Google Classroom** → course color identity, assignment card anatomy

---

# Part 1 — Design Tokens (Foundation)

All tokens are defined as **Figma Variables** in a collection named `NYCU/Core`, with two modes: `Light` and `Dark`. Semantic tokens alias primitive tokens — components only ever reference semantic tokens.

## 1.1 Primitive Color Palette

Naming: `color/{hue}/{step}` — steps run 50 (lightest) → 950 (darkest).

### Brand — NYCU Blue
Derived from NYCU's institutional blue, tuned for WCAG AA on white and near-black.

| Token | Hex | Usage note |
|---|---|---|
| `blue/50` | `#EEF5FF` | Tint backgrounds, selected rows (light) |
| `blue/100` | `#D9E9FF` | Hover fills |
| `blue/200` | `#B3D3FF` | Focus ring inner |
| `blue/300` | `#7EB3FA` | Dark-mode secondary accents |
| `blue/400` | `#4A90F4` | Dark-mode primary accent |
| `blue/500` | `#2472E8` | Light-mode primary accent (4.6:1 on white) |
| `blue/600` | `#1A5FD0` | Pressed state |
| `blue/700` | `#154DA8` | High-contrast text on tint |
| `blue/800` | `#123D85` | — |
| `blue/900` | `#0F3168` | — |
| `blue/950` | `#0A1F42` | — |

### Neutrals — Gray (blue-cast, 2% chroma)

| Token | Hex |
|---|---|
| `gray/0` | `#FFFFFF` |
| `gray/50` | `#F7F8FA` |
| `gray/100` | `#F0F2F5` |
| `gray/200` | `#E4E7EC` |
| `gray/300` | `#D0D5DD` |
| `gray/400` | `#98A2B3` |
| `gray/500` | `#667085` |
| `gray/600` | `#475467` |
| `gray/700` | `#344054` |
| `gray/800` | `#1D2939` |
| `gray/900` | `#101828` |
| `gray/950` | `#0B0F17` |

### Functional Hues (each with 50–950 ramps; key steps listed)

The 400-step is each hue's dark-mode presentation step (see §1.2 event tokens and the dark-mode rule in Part 7); all 400-steps are WCAG-verified ≥ 4.5:1 on `gray/900` and `gray/950`. *(400 column ratified via DS-AMD-001.)*

| Hue | 100 | 400 | 500 | 600 | 700 | Meaning |
|---|---|---|---|---|---|---|
| `red` | `#FEE4E2` | `#F97066` | `#F04438` | `#D92D20` | `#B42318` | Exams, overdue, destructive |
| `orange` | `#FEEAD3` | `#FDB022` | `#F79009` | `#DC6803` | `#B54708` | Assignments, due-soon warnings |
| `green` | `#D3F3DF` | `#32D583` | `#12B76A` | `#039855` | `#027A48` | Completion, success, synced |
| `yellow` | `#FEF3C7` | `#F7D144` | `#F5C518` | `#D9A507` | `#A97F05` | Sticky notes default, caution |
| `purple` | `#EBE4FF` | `#9B8AFB` | `#7A5AF8` | `#6938EF` | `#5925DC` | Personal todos, focus features |
| `teal` | `#CCF3F0` | `#2ED3B7` | `#0FB5AE` | `#0E9188` | `#107569` | Labs / secondary course category |
| `pink` | `#FCE7F6` | `#F670C7` | `#EE46BC` | `#DD2590` | `#C11574` | Course identity option |
| `indigo` | `#E0EAFF` | `#8098F9` | `#6172F3` | `#444CE7` | `#3538CD` | Course identity option |

### Course Identity Palette (auto-assigned, user-overridable)
10-color rotation assigned to courses at first sync, in this order:
`blue/500 → teal/500 → purple/500 → orange/500 → pink/500 → indigo/500 → green/600 → red/500 → yellow/600 → gray/500`
Each course color has a matched `container` (100-step) and `onContainer` (700-step) pair for card tints and text.

## 1.2 Semantic Color Tokens

Format: `token → Light mode alias | Dark mode alias`

### Backgrounds
| Token | Light | Dark |
|---|---|---|
| `bg/canvas` | `gray/50` | `gray/950` |
| `bg/surface` (cards) | `gray/0` | `gray/900` |
| `bg/surface-raised` (dialogs, popovers) | `gray/0` | `gray/800` |
| `bg/surface-sunken` (wells, input fill) | `gray/100` | `#0E1421` |
| `bg/sidebar` | `#FBFCFD` @ 92% + background blur 40 | `gray/900` @ 88% + blur 40 |
| `bg/overlay` (scrim) | `gray/900` @ 40% | `#000000` @ 60% |
| `bg/accent` | `blue/500` | `blue/400` |
| `bg/accent-tint` | `blue/50` | `blue/400` @ 14% |

### Text
| Token | Light | Dark | Contrast target |
|---|---|---|---|
| `text/primary` | `gray/900` | `#F5F7FA` | ≥ 12:1 |
| `text/secondary` | `gray/600` | `gray/400` | ≥ 4.6:1 |
| `text/tertiary` | `gray/500` | `gray/500` | ≥ 4.5:1 (large text only) |
| `text/disabled` | `gray/400` | `gray/600` | — |
| `text/accent` | `blue/600` | `blue/300` | ≥ 4.5:1 |
| `text/on-accent` | `gray/0` | `gray/950` | ≥ 4.5:1 |
| `text/danger` | `red/600` | `red/400` (`#F97066`) | ≥ 4.5:1 |
| `text/success` | `green/700` | `green/400` (`#32D583`) | ≥ 4.5:1 |
| `text/warning` | `orange/700` | `orange/400` (`#FDB022`) | ≥ 4.5:1 |

### Borders & Lines
| Token | Light | Dark |
|---|---|---|
| `border/subtle` | `gray/200` | `#232B3B` |
| `border/default` | `gray/300` | `#2E3850` |
| `border/strong` | `gray/400` | `gray/600` |
| `border/focus` | `blue/500` | `blue/400` |
| `divider/hairline` | `gray/200` @ 70% | `#FFFFFF` @ 8% |

### Event Category Semantics (Calendar / global)
| Token | Light | Dark | Category |
|---|---|---|---|
| `event/class` | course color | course color (400-step) | Class sessions |
| `event/assignment` | `orange/500` | `orange/400` | Assignment due |
| `event/exam` | `red/500` | `#F97066` | Exams |
| `event/personal` | `yellow/600` | `yellow/500` | Sticky notes / personal |
| `event/todo` | `purple/500` | `purple/400` | Manual todos |

### State Colors
| Token | Value (Light / Dark) |
|---|---|
| `state/hover` | `gray/900` @ 4% / `#FFFFFF` @ 6% |
| `state/pressed` | `gray/900` @ 8% / `#FFFFFF` @ 10% |
| `state/selected` | `blue/500` @ 10% / `blue/400` @ 16% |
| `state/drag-target` | `blue/500` @ 6% + dashed `border/focus` |

## 1.3 Typography Tokens

**Typefaces**
- **Latin/numerals:** SF Pro (iOS/iPadOS/macOS) · Inter (Web/Android fallback)
- **Traditional Chinese:** PingFang TC (Apple platforms) · Noto Sans TC (elsewhere)
- **Numerals in stats/countdown:** SF Pro Rounded (gives countdown warmth) — token `font/family/display-round`
- Font stack token: `font/family/base = "SF Pro", "Inter", "PingFang TC", "Noto Sans TC", sans-serif`

**Type Scale** — 4pt-aligned, Dynamic Type compatible (values = default `Large` size class)

| Token | Size / Line height | Weight | Tracking | Usage |
|---|---|---|---|---|
| `type/display` | 34 / 41 | Bold (700) | +0.4 | Countdown numbers, page hero (tablet/desktop) |
| `type/title-1` | 28 / 34 | Bold (700) | +0.38 | Screen titles ("Today", "Calendar") |
| `type/title-2` | 22 / 28 | Bold (700) | −0.26 | Section titles, dialog titles |
| `type/title-3` | 20 / 25 | Semibold (600) | −0.45 | Card group headers |
| `type/headline` | 17 / 22 | Semibold (600) | −0.43 | Card titles, list item titles |
| `type/body` | 17 / 22 | Regular (400) | −0.43 | Primary reading text |
| `type/callout` | 16 / 21 | Regular (400) | −0.31 | Secondary descriptions |
| `type/subhead` | 15 / 20 | Regular (400) | −0.23 | List metadata, timetable labels |
| `type/footnote` | 13 / 18 | Regular (400) | −0.08 | Timestamps, sync status |
| `type/caption-1` | 12 / 16 | Medium (500) | 0 | Badges, tags, tab labels |
| `type/caption-2` | 11 / 13 | Semibold (600) | +0.06 | Overline labels (ALL CAPS, +4% tracking) |
| `type/mono` | 15 / 20 | SF Mono Regular | 0 | Course codes (e.g., `CS3025`) |

**Rules**
- Numerals in dates, countdowns, and stats always use **tabular lining figures** (`tnum`).
- Traditional Chinese: line-height × 1.15 vs Latin equivalents; never letter-space CJK body text.
- Dynamic Type: all text styles map to Apple text styles (`Large Title, Title 1–3, Headline, Body…`); layouts must survive up to AX3 size with vertical stacking fallbacks.
- Minimum text size anywhere: 11pt.

## 1.4 Spacing System

Base unit: **4pt grid**. Token format `space/{n}`.

| Token | Value | Typical use |
|---|---|---|
| `space/1` | 4 | Icon-to-badge gaps |
| `space/2` | 8 | Inside chips, icon-to-label |
| `space/3` | 12 | Card internal stack gaps |
| `space/4` | 16 | Card padding (phone), list item padding |
| `space/5` | 20 | Card padding (tablet/desktop) |
| `space/6` | 24 | Between cards, section gaps |
| `space/8` | 32 | Between dashboard sections |
| `space/10` | 40 | Page top padding (desktop) |
| `space/12` | 48 | Hero spacing, empty states |
| `space/16` | 64 | Desktop canvas margins |

**Layout margins:** Phone 16 · Tablet 24 · Desktop 32 (content max-width 1200, centered).
**Gutter:** Phone 12 · Tablet 16 · Desktop 24.

## 1.5 Radius, Elevation, Blur

| Token | Value | Use |
|---|---|---|
| `radius/xs` | 6 | Checkboxes, small chips |
| `radius/sm` | 8 | Buttons, inputs, tags |
| `radius/md` | 12 | List rows, small cards |
| `radius/lg` | 16 | Standard cards, dashboard modules |
| `radius/xl` | 20 | Dialogs, sheets |
| `radius/2xl` | 28 | Bottom sheets (top corners), large modals |
| `radius/full` | 999 | Pills, avatars, progress rings, FAB |

| Elevation token | Light | Dark |
|---|---|---|
| `shadow/none` | — | — (dark mode prefers borders over shadows) |
| `shadow/card` | Y2 B8 `gray/900`@6% | none + `border/subtle` 1px |
| `shadow/raised` | Y4 B16 `gray/900`@8% | Y4 B16 `#000`@40% + border |
| `shadow/overlay` | Y12 B40 `gray/900`@16% | Y12 B40 `#000`@55% + border |
| `shadow/fab` | Y6 B20 `blue/500`@28% | Y6 B20 `#000`@45% |

**Materials:** `material/sidebar` = background blur 40 + surface @ 90% · `material/navbar` = blur 24 + surface @ 85% (iOS large-title collapse behavior).

## 1.6 Motion Tokens

| Token | Value | Use |
|---|---|---|
| `motion/instant` | 100ms, ease-out | Hover, pressed states |
| `motion/quick` | 200ms, spring(1, 300, 30) | Checkbox, chip select, toggle |
| `motion/standard` | 300ms, spring(1, 260, 26) | Card expand, sheet present, tab switch |
| `motion/gentle` | 450ms, ease-in-out | Progress ring fill, completion rate animation |
| `motion/celebrate` | 600ms | Task-complete check draw + subtle haptic |

Reduce Motion: all springs fall back to 150ms crossfades.

## 1.7 Iconography

- **Set:** SF Symbols 6 (Apple platforms) / matching custom 24px set for web, 1.5pt stroke, rounded caps.
- Sizes: 16 (inline meta), 20 (list/buttons), 24 (nav), 28 (empty states use 48–64 duotone).
- Icons always paired with labels in navigation; icon-only buttons require tooltips (desktop) and accessibility labels.

**Canonical icons:** Today `sun.max` · Calendar `calendar` · Timetable `tablecells` · Todo `checklist` · Notes `note.text` · Progress `chart.bar` · Exam `timer` · Course `book.closed` · Sync `arrow.triangle.2.circlepath` · Settings `gearshape`.

---

# Part 2 — Information Architecture

## 2.1 IA Map (Full)

```
NYCU Student OS
│
├── 0. Onboarding (first-run only)
│   ├── 0.1 Welcome / value proposition (3-slide pager)
│   ├── 0.2 Sign in with NYCU Portal (webview / SSO)
│   ├── 0.3 Data-access consent (courses · assignments · schedule)
│   ├── 0.4 Notification permission primer → OS prompt
│   ├── 0.5 Face ID / Touch ID opt-in
│   └── 0.6 First-sync progress → lands on populated Dashboard
│
├── 1. Today (Dashboard) ────────────── default landing tab
│   ├── 1.1 Header: date, greeting, sync status, avatar
│   ├── 1.2 Today's Schedule module (timeline strip)
│   ├── 1.3 Due Soon module (top 3–5 + View All)
│   ├── 1.4 Exam Countdown module
│   ├── 1.5 Sticky Notes rail
│   ├── 1.6 Weekly Completion ring + Semester Progress bar
│   ├── 1.7 Edit Mode (long-press / Edit button: reorder & hide modules)
│   └── 1.8 Empty / first-sync / offline states
│
├── 2. Calendar
│   ├── 2.1 Month view (density dots)
│   ├── 2.2 Week view (default)
│   ├── 2.3 Day view (agenda + timeline)
│   ├── 2.4 Filters: category (Class/Assignment/Exam/Personal) + per-course
│   ├── 2.5 Event Detail (sheet/popover)
│   └── 2.6 Add personal event / dated note
│
├── 3. Timetable
│   ├── 3.1 Weekly grid (Mon–Fri default, Mon–Sun toggle)
│   ├── 3.2 Current-time indicator (live line)
│   ├── 3.3 Class Block Detail (room, instructor, linked assignments)
│   ├── 3.4 Week picker (handles biweekly/irregular sessions)
│   └── 3.5 "No classes today" state
│
├── 4. Tasks (Todo)
│   ├── 4.1 Smart lists: Today · Upcoming · All · Done (collapsed)
│   ├── 4.2 Unified list: auto-synced assignments (tagged AUTO) + manual tasks
│   ├── 4.3 Task Detail / Edit (sheet)
│   ├── 4.4 Quick Add (+) with natural date parse
│   ├── 4.5 Sort: due date / priority / course · Filter: course, type
│   └── 4.6 Hidden (auto items "deleted" by user; restorable)
│
├── 5. Notes (Sticky Notes)
│   ├── 5.1 Notes board (masonry grid)
│   ├── 5.2 Note editor (color, pin-to-date, pin-to-dashboard)
│   └── 5.3 Archive (stale-note suggestions)
│
├── 6. Progress
│   ├── 6.1 Weekly Completion Rate (ring + 12-week trend bars)
│   ├── 6.2 Semester Progress (milestone timeline)
│   └── 6.3 Exams overview (all countdowns ranked)
│
├── 7. Courses (secondary — reached via cards/search, not a main tab)
│   ├── 7.1 Course list (this semester)
│   └── 7.2 Course Detail: sessions, instructor, assignments, exams, color override
│
├── 8. Settings
│   ├── 8.1 Account (Portal session, Face ID, logout)
│   ├── 8.2 Sync (frequency, last sync, manual sync, diagnostics)
│   ├── 8.3 Notifications (default intervals, digest, quiet hours)
│   ├── 8.4 Appearance (Light/Dark/Auto, accent, app icon)
│   ├── 8.5 Dashboard modules (show/hide/reorder)
│   ├── 8.6 Language (繁體中文 / English)
│   └── 8.7 Privacy & data (consent review, export, delete local data)
│
└── System overlays (any screen)
    ├── Sync-error banner · "Last synced" pill · Offline read-only banner
    ├── New-assignment badge · "Recently changed" badge (48h)
    └── Notification digest (deadline clusters)
```

## 2.2 Navigation Structure

### Phone (iOS) — Tab Bar (5 tabs)
```
┌─────────────────────────────────────────────┐
│  Today   Calendar   [＋]   Tasks   More     │
│  sun      calendar   FAB   check   ellipsis │
└─────────────────────────────────────────────┘
```
- **Today · Calendar · Tasks** are the three pillars (PRD Must-Haves).
- **[＋] center action button** (not a tab): opens Quick Add sheet — segmented into *Task / Note / Event*. 56×56, `bg/accent`, `radius/full`, `shadow/fab`, floats 8pt above bar.
- **More** → Timetable, Notes, Progress, Courses, Settings (Timetable also embedded on Today, so it earns "More" placement without losing daily reach).
- Tab bar: 49pt + safe area, `material/navbar`, active tint `text/accent`, inactive `text/tertiary`, labels `type/caption-1`.
- Badging: red dot on Tasks when new auto-synced assignment lands.

### Tablet (iPadOS) — Left Sidebar (collapsible to rail)
```
┌──────────┬──────────────────────────────────┐
│ NYCU OS  │                                  │
│──────────│                                  │
│ ☀ Today   │         Content canvas          │
│ 📅 Calendar│      (2-column when wide)      │
│ ▦ Timetable│                                │
│ ✓ Tasks   │                                  │
│ ▤ Notes   │                                  │
│ ◔ Progress│                                  │
│──────────│                                  │
│ ⌂ Courses │                                  │
│ ⚙ Settings│                                  │
│──────────│                                  │
│ ◍ Synced 9:41 ↻ │                           │
└──────────┴──────────────────────────────────┘
```
- Sidebar 280pt expanded / 72pt rail (icons only). `bg/sidebar` material.
- Quick Add becomes a persistent `＋ New` primary button pinned at sidebar top-under-logo.
- Sync status pill lives at sidebar bottom — always visible (trust principle).

### Desktop (macOS / Web) — Sidebar + Command Palette
- Same sidebar as tablet plus:
  - **Global search / command palette** `⌘K` (Linear DNA): jump to course, add task ("task: review ch4 fri"), toggle filters.
  - **Keyboard map:** `1–6` switch sections · `N` new task · `⇧N` new note · `T` jump to today · `←→` prev/next period · `⌘,` settings.
  - Hover states on all rows; context menus (right-click) on tasks, events, notes.
- Window min-width 960; content max 1200 centered beyond 1440.

### Navigation rules
- Detail views: push (phone), sheet ≤ 560pt-wide content (tablet), popover or right inspector panel 360pt (desktop).
- Deep links: `nycu://today`, `nycu://task/{id}`, `nycu://course/{id}` (notifications land on the exact item).
- Back behavior always preserves scroll position and active filters.

## 2.3 Screen Hierarchy (depth map)

| Depth | Screens |
|---|---|
| L0 (tabs) | Today · Calendar · Timetable* · Tasks · Notes* · Progress* (* = in More on phone) |
| L1 (detail) | Event Detail · Task Detail · Class Block Detail · Course Detail · Note Editor · All Exams |
| L1 (modal) | Quick Add · Filters · Dashboard Edit Mode · Week Picker |
| L2 | Settings subpages · Sync Diagnostics · Milestone Timeline · Hidden Tasks · Notes Archive |
| Overlay | Banners, toasts, digest notifications, command palette (desktop) |

Rule: **no destination is deeper than 2 levels from a tab.** (HIG: shallow hierarchies for daily-habit apps.)

---

# Part 3 — Wireframes (Low-Fidelity)

Annotation key: `[C]` component reference (Part 5) · numbers = spec callouts.

## 3.1 Today / Dashboard — Phone (390×844)

```
┌────────────────────────────────────────┐
│  TUE, JULY 11              ◍ ↻   (👤)  │ ← 1 overline date, sync pill, avatar
│  Today                                 │ ← 2 type/title-1, large-title collapse
│  早安，Yu-Ting 👋                        │ ← 3 greeting, type/callout, text/secondary
│                                        │
│  ── TODAY'S CLASSES ──────────  3 ──── │ ← 4 section header [C-SectionHeader]
│ ┌──────────────────────────────────┐   │
│ │ ● 09:00–10:50  Operating Systems │   │ ← 5 [C-ScheduleRow] course dot = identity color
│ │   EC-315 · Prof. Chang     NOW ▸ │   │ ← 6 "NOW" live badge, green pulse
│ ├──────────────────────────────────┤   │
│ │ ● 13:20–15:10  Linear Algebra    │   │
│ │   SC-204 · Prof. Wu            ▸ │   │
│ ├──────────────────────────────────┤   │
│ │ ● 15:30–17:20  Machine Learning  │   │
│ │   EC-122 · Prof. Lin  ⚠room chg ▸│   │ ← 7 48h "recently changed" badge
│ └──────────────────────────────────┘   │
│                                        │
│  ── DUE SOON ────────────── View All → │
│ ┌──────────────────────────────────┐   │
│ │ ◯ OS HW3 — Scheduler         🔴  │   │ ← 8 [C-AssignmentCard compact]
│ │   Operating Systems · Due 23:59  │   │    urgency dot: red <24h
│ ├──────────────────────────────────┤   │
│ │ ◯ ML Lab Report 2            🟠  │   │    orange <72h
│ │   Machine Learning · Fri 18:00   │   │
│ ├──────────────────────────────────┤   │
│ │ ◯ 讀完 Ch.4 · manual         ⚪  │   │ ← 9 manual todo mixed in, no AUTO tag
│ └──────────────────────────────────┘   │
│                                        │
│ ┌────────────────┐ ┌────────────────┐  │
│ │ NEXT EXAM      │ │ THIS WEEK      │  │ ← 10 [C-StatCard] 2-up grid
│ │ 線性代數 期中考   │ │    ◔ 68%       │  │    countdown + completion ring
│ │   D-5          │ │  17 of 25 done │  │
│ │ Jul 16 · 10:00 │ │  ↑ 6% vs last  │  │
│ └────────────────┘ └────────────────┘  │
│                                        │
│  ── STICKY NOTES ──────────────── ＋ ─ │
│ ╭──────────╮ ╭──────────╮ ╭─────      │ ← 11 horizontal scroll rail [C-StickyNote]
│ │帶充電器去  │ │Group mtg │ │Ask…       │
│ │小組會議    │ │Thu 19:00 │ │           │
│ ╰──────────╯ ╰──────────╯ ╰─────      │
│                                        │
│  SEMESTER ▓▓▓▓▓▓▓▓░░░░░░░ 42% · Wk 8  │ ← 12 [C-ProgressBar] milestone ticks
│                                        │
│────────────────────────────────────────│
│  ☀ Today  📅 Calendar (＋) ✓ Tasks ⋯More│ ← 13 [C-TabBar] + FAB
└────────────────────────────────────────┘
```

**States:** first-sync (skeleton shimmer per module) · empty day ("No classes today 🎉 — next: Wed 09:00") · offline (amber banner under header: "Offline — showing data from 09:41") · 10+ items (Due Soon caps at 5 + "View all 12").

## 3.2 Calendar — Phone, Week view (default)

```
┌────────────────────────────────────────┐
│  ‹ July 2026 ›            [M|W|D] 🜃   │ ← segmented view switch + filter icon
│  Mo  Tu  We  Th  Fr  Sa  Su            │
│   7   8  [9] 10  11  12  13            │ ← week strip, today ringed
│──────────────────────────────────────  │
│ 08 ─────────────────────────────────   │
│ 09 ┃●OS EC-315         ┃               │ ← class blocks, course color bar
│ 10 ┃                   ┃               │
│ 11 ─────────────────────────────────   │
│    ── ◆ OS HW3 due 23:59 ──────────    │ ← all-day/deadline lane: ◆ assignment ▲ exam
│ 12 ───────────── ═══ now ══════════    │ ← current-time line, red, live
│ 13 ┃●LinAlg SC-204     ┃               │
│ ...                                    │
└────────────────────────────────────────┘
```
- Month view: event pips (max 3 dots + `+n`); dense exam week → heat-tint on day cell instead of dot pileup.
- Day view: agenda list (deadlines) above timeline (classes).
- Filter sheet: category chips (Class/Assignment/Exam/Personal) + course checklist; active filters shown as a dismissible chip row under the header. Filter application <300ms — animate as fade, no relayout jump.

## 3.3 Timetable — Phone

```
┌────────────────────────────────────────┐
│  Timetable        Week 8 ▾    M–F | M–S│
│      MON   TUE   WED   THU   FRI       │
│ 08                                     │
│ 09  ┌───┐        ┌───┐                 │
│ 10  │OS │        │OS │  ┌────┐         │ ← class blocks: course container tint
│ 11  └───┘        └───┘  │Lab*│         │ ← * biweekly: only rendered valid weeks
│ 12 ═══════ now ═══════════════════     │
│ 13        ┌────┐        ┌────┐         │
│ 15  ┌───┐ │ML  │        │LinA│         │
│ 17  └───┘ └────┘        └────┘         │
│                                        │
│  Tap a class for room & assignments    │
└────────────────────────────────────────┘
```
- Block anatomy: 3pt left color bar, course short-name `type/caption-1` semibold, room `type/caption-2`. Min block height 44pt (tap target); overlapping electives split column width.
- Tap → Class Block Detail sheet: full name, `CS3025` mono code, room+building, instructor, next session, linked assignments (2 max + view all), "Open course" link.

## 3.4 Tasks — Phone

```
┌────────────────────────────────────────┐
│  Tasks                    ⇅ Sort   🜃  │
│  [Today] [Upcoming] [All]              │ ← smart list segmented control
│                                        │
│  OVERDUE (1)                           │ ← red section header
│  ◯ Essay draft · 英文寫作 · Yesterday ⚠ │
│                                        │
│  TODAY                                 │
│  ◯ OS HW3 — Scheduler        AUTO 🔴   │ ← AUTO chip = synced from Portal
│  ◯ Review Ch.4                    ⚪   │
│  ◉ Email Prof. Wu ✓ (fading out)       │ ← check → 600ms celebrate → moves to Done
│                                        │
│  TOMORROW                              │
│  ◯ ML Lab Report 2           AUTO 🟠   │
│                                        │
│  ▸ Done this week (6)                  │ ← collapsed group
│                                (＋)    │
└────────────────────────────────────────┘
```
- Row anatomy `[C-TaskRow]`: 24pt circle checkbox (Things-style), title `type/headline`, meta line = course chip + due time + priority flag (P1 red / P2 orange / P3 gray).
- Swipe right = complete · swipe left = reveal Edit / Hide (auto items get "Hide," never "Delete"; manual items get "Delete").
- Quick Add sheet: single text field with natural-language date parse preview ("fri 6pm" → chip), course picker, priority, AUTO-off by definition.
- Reopen: tapping a done item's check un-completes with no confirmation (undo toast pattern).

## 3.5 Notes — Phone

```
┌────────────────────────────────────────┐
│  Notes                          ⋯  ＋  │
│ ╭──────────────╮ ╭──────────────╮     │
│ │ 帶充電器去     │ │ Ask TA about │     │ ← 2-col masonry, [C-StickyNote]
│ │ 小組會議       │ │ HW2 grading  │     │
│ │ 📌 Jul 12     │ │              │     │ ← dated pin shows calendar chip
│ ╰──────────────╯ ╰──────────────╯     │
│ ╭──────────────╮ ╭──────────────╮     │
│ │ 期末專題靈感…  │ │ Buy blue     │     │
│ │ (yellow)     │ │ book ×2      │     │
│ ╰──────────────╯ ╰──────────────╯     │
└────────────────────────────────────────┘
```
- Editor: full-screen (phone) / 480pt modal (desktop). Color swatch row (6 note colors), date pin, dashboard pin toggle, archive.
- Stale suggestion: after 30 days untouched → subtle "Archive?" ghost button on card, never auto-removed.

## 3.6 Progress — Phone

```
┌────────────────────────────────────────┐
│  Progress                              │
│ ┌──────────────────────────────────┐   │
│ │        THIS WEEK                 │   │
│ │          ◔ 68%                   │   │ ← 96pt ring, animated fill (gentle)
│ │      17 of 25 tasks done         │   │
│ │  ▁▃▅▂▆▅█ ← 12-week trend bars    │   │
│ └──────────────────────────────────┘   │
│ ┌──────────────────────────────────┐   │
│ │ SEMESTER · Week 8 of 18 · 42%    │   │
│ │ ●────────◆────░░░░◆░░░░░░○       │   │ ← milestones: add/drop, midterm, final
│ │ Start   Midterms      Finals     │   │
│ └──────────────────────────────────┘   │
│ ┌──────────────────────────────────┐   │
│ │ UPCOMING EXAMS                   │   │
│ │ 線性代數 期中     D-5 · Jul 16 10:00│   │
│ │ OS Midterm      D-8 · Jul 19 13:20│   │
│ │ 英文寫作          not yet scheduled│   │ ← never silently omitted
│ └──────────────────────────────────┘   │
└────────────────────────────────────────┘
```
- Zero-task week: ring replaced by "No tasks this week — enjoy it ☀️" (never 0%/100%).
- Recalculated history weeks get a small `recalculated` footnote chip.

## 3.7 Onboarding — Phone

```
0.1 Welcome            0.2 Login              0.6 First sync
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│              │      │  NYCU logo   │      │   ◔ 72%      │
│  (hero art)  │      │              │      │ Syncing your │
│ One login.   │      │ [Sign in with│      │ semester…    │
│ Every class, │      │  NYCU Portal]│      │ ✓ 6 courses  │
│ every day.   │      │              │      │ ✓ 14 assign. │
│  ● ○ ○       │      │ 🔒 Encrypted. │      │ ◌ timetable  │
│ [Continue]   │      │ Never stored │      │              │
│              │      │ in plaintext.│      │ (auto-lands  │
└──────────────┘      └──────────────┘      │ on Dashboard)│
                                            └──────────────┘
```
- Security messaging is on the login screen itself (trust risk mitigation from PRD §10).
- Consent screen: three toggles (Courses / Assignments / Schedule) each with one-line plain-language explanation; primary CTA "Allow & Continue."
- First sync is a *checklist with live counts* — proves value before the user ever sees the app (PRD adoption risk).

## 3.8 Desktop Dashboard (1440×900) — wireframe

```
┌────────┬───────────────────────────────────────────────────────────┐
│SIDEBAR │  Today · Tuesday, July 11              ⌘K Search    ◍ ↻ 👤│
│        │                                                           │
│ ＋ New  │ ┌────────────────────────────┐ ┌────────────────────────┐ │
│        │ │ TODAY'S SCHEDULE (timeline)│ │ NEXT EXAM              │ │
│ ☀ Today │ │ 09:00 ● OS  EC-315   NOW   │ │ 線性代數期中  D-5        │ │
│ 📅 Cal   │ │ 13:20 ● LinAlg SC-204      │ │ Jul 16 · 10:00 · SC-101│ │
│ ▦ Time  │ │ 15:30 ● ML EC-122 ⚠        │ ├────────────────────────┤ │
│ ✓ Tasks │ │                            │ │ THIS WEEK    ◔ 68%     │ │
│ ▤ Notes │ ├────────────────────────────┤ │ 17/25 · ↑6% vs last wk │ │
│ ◔ Prog  │ │ DUE SOON        View all → │ ├────────────────────────┤ │
│        │ │ ◯ OS HW3      AUTO 🔴 23:59 │ │ SEMESTER  ▓▓▓▓░░ 42%   │ │
│ ⌂Courses│ │ ◯ ML Lab 2    AUTO 🟠 Fri  │ ├────────────────────────┤ │
│ ⚙ Set   │ │ ◯ Review Ch.4        ⚪    │ │ STICKY NOTES        ＋ │ │
│        │ │                            │ │ ╭────╮ ╭────╮ ╭────╮  │ │
│ ◍ Synced│ └────────────────────────────┘ │ ╰────╯ ╰────╯ ╰────╯  │ │
│  09:41 ↻│   8-col main                    │  4-col rail            │ │
└────────┴───────────────────────────────────────────────────────────┘
```

---

# Part 4 — Color, Typography & Layout Systems (Applied)

## 4.1 Color usage rules
1. **One accent.** `blue/500` is the only interactive accent. Course colors identify *content*, never *controls*.
2. **Urgency ladder** (assignments/deadlines): `⚪ gray/400` >72h · `🟠 orange/500` ≤72h · `🔴 red/500` ≤24h or overdue. Never more than one red treatment per row.
3. **Tints over fills.** Selected/hover states use 4–16% alpha tints, not solid color swaps.
4. **Category colors are constant across the entire app** — a class is always its course color, exams always red family, assignments orange, personal yellow, todos purple. This is the user's learned legend.
5. All text-on-tint combinations must pass WCAG AA (4.5:1); the token pairs in §1.1 are pre-validated — never mix container steps manually.

## 4.2 Grid & breakpoints

| Class | Width | Columns | Margin | Gutter | Nav |
|---|---|---|---|---|---|
| Phone | 320–743 | 4 | 16 | 12 | Tab bar + FAB |
| Tablet portrait | 744–1023 | 8 | 24 | 16 | Sidebar rail (72) |
| Tablet landscape / small desktop | 1024–1279 | 12 | 24 | 20 | Sidebar (280) |
| Desktop | 1280+ | 12 (max 1200 content) | 32 | 24 | Sidebar (280) + inspector (360 optional) |

**Dashboard module spans:** phone = full-width stack (stat cards 2-up) · tablet = 8-col: schedule 8, then 4+4 pairs · desktop = 12-col: main column 8 (schedule, due soon) + right rail 4 (exam, week ring, semester, notes).

## 4.3 Responsive behavior per screen

| Screen | Phone | Tablet | Desktop |
|---|---|---|---|
| Today | Vertical module stack | 2-column module grid | 8+4 fixed composition, drag-reorder in edit mode |
| Calendar | Week default, month = pips | Month shows event titles (2 lines/day) | Month full titles + week side-by-side day inspector |
| Timetable | Horizontal-scroll if M–S | Full grid fits | Full grid + hover detail popover |
| Tasks | Single list | List + detail split (380/flex) | List + detail + `⌘K` quick add |
| Notes | 2-col masonry | 3-col | 4-col, drag to reorder |
| Detail views | Push / bottom sheet | Centered sheet 560 | Right inspector 360 or popover |

---

# Part 5 — Component Library (Figma Specs)

Every component: Auto Layout, all variants via component properties, semantic tokens only. Published library: **`NYCU OS / Components v1`**. Naming: `Component/Variant` with props `state`, `size`, `mode` handled by variable modes (not duplicate variants) where possible.

## 5.1 Buttons `[C-Button]`

| Prop | Values |
|---|---|
| `variant` | Primary · Secondary · Tertiary(ghost) · Destructive |
| `size` | Large 50pt · Medium 44pt · Small 32pt (pill) |
| `state` | Default · Hover · Pressed · Disabled · Loading |
| `icon` | none · leading · trailing · icon-only |

Specs:
- **Primary:** fill `bg/accent`, text `text/on-accent`, `radius/sm` (Large uses `radius/md`), padding H 20/16/12 by size. Pressed: `blue/600` + scale 0.98. Loading: label → 20pt spinner, width locked.
- **Secondary:** fill `bg/accent-tint`, text `text/accent`. Hover adds 4% overlay.
- **Tertiary:** no fill, text `text/accent`; hover `state/hover` pill.
- **Destructive:** Secondary-style with red tokens; solid red reserved for confirm dialogs.
- Disabled = 40% opacity, no shadow. Focus (keyboard): 2pt `border/focus` ring offset 2.
- Min touch target 44×44 always (Small pill gets invisible hit-area padding).

## 5.2 Cards `[C-Card]`

Base: fill `bg/surface`, `radius/lg`, `shadow/card`, padding `space/4` (phone) / `space/5` (tablet+), internal stack gap `space/3`.
- Variants: `Default` · `Interactive` (hover raises to `shadow/raised` + translateY −1, cursor pointer) · `Sunken` (settings wells).
- Dark mode: shadow → 1px `border/subtle` (flat, Linear-style).
- Card header slot: overline `type/caption-2` uppercase `text/tertiary` + optional trailing action (`View All →` in `type/subhead` accent).

## 5.3 Dialogs & Sheets `[C-Dialog]`

- **Alert dialog (destructive confirm):** 320pt (phone) / 420pt (desktop), `radius/xl`, `bg/surface-raised`, `shadow/overlay`, scrim `bg/overlay`. Title `type/title-3`, body `type/callout` secondary, buttons right-aligned (desktop) / full-width stacked (phone), destructive action red, cancel Tertiary. Enter = confirm only for non-destructive.
- **Bottom sheet (phone):** `radius/2xl` top corners, grabber 36×5 `gray/300`, detents medium (60%) / large (92%), drag-to-dismiss.
- **Modal sheet (tablet/desktop):** centered, max 560, entrance scale 0.97→1 + fade (`motion/standard`).
- Focus trapped; `Esc`/scrim-tap dismisses non-destructive only.

## 5.4 Calendar Components `[C-Calendar*]`

- **`C-MonthDayCell`:** 44pt min square; date numeral `type/subhead` (today = white on `bg/accent` 28pt circle); up to 3 category pips 6pt; overflow `+n` `type/caption-2`; density heat-tint (`red/500` @ 6/10/14%) at 4+/6+/8+ items. States: default/today/selected/dimmed(adjacent month)/holiday (numeral `text/tertiary` + tiny `holiday` label, class instances suppressed).
- **`C-WeekEventBlock`:** class block = course container tint fill + 3pt solid left bar, title `type/caption-1` semibold `onContainer`, room `type/caption-2`. Min height 44; overlaps split columns with 2pt gap (never hidden — PRD edge case).
- **`C-DeadlineLane`:** all-day strip above timeline; ◆ assignment (orange) · ▲ exam (red) · 📌 note (yellow); chips `radius/xs`, stack max 2 rows then `+n more` popover.
- **`C-NowLine`:** 1.5pt `red/500` full-width + 6pt dot on time axis; updates each minute; only on today.
- **`C-EventDetail` sheet:** category color header bar 4pt, title `type/title-3`, meta rows (icon 16 + `type/subhead`): time, location, course, source (`Portal · synced 09:41`), actions (Add to tasks · Edit if manual · Directions future-slot). "Changed" badge (amber, 48h) when time/room recently updated.
- **`C-FilterChipRow`:** chips `[C-Chip]` scrollable; category chips carry their category dot; active = `state/selected` fill + accent text.

## 5.5 Course Card `[C-CourseCard]`

```
┌──────────────────────────────────┐
│ ▍Operating Systems        CS3025 │  ▍= 4pt course-color bar, code = type/mono
│ ▍Prof. Chang · EC-315            │
│ ▍Mon 09:00 · Thu 09:00           │
│ ▍ 2 due · next exam D-8          │  footer meta, type/footnote
└──────────────────────────────────┘
```
- Sizes: `Regular` (list, 88pt) · `Compact` (schedule row, 64pt) · `Grid` (tablet 2-3 col).
- Course Detail header: large color swatch (tappable → color override palette of the 10 identity colors), sections: Sessions · Assignments · Exams · Instructor.

## 5.6 Assignment Card `[C-AssignmentCard]`

```
┌──────────────────────────────────┐
│ ◯  OS HW3 — Scheduler    AUTO 🔴 │  checkbox 24 · title headline · source chip · urgency dot
│    Operating Systems             │  course chip (color dot + name, caption-1)
│    Due today 23:59 · Portal      │  due line footnote; overdue = red text "Overdue · Yesterday"
└──────────────────────────────────┘
```
Props: `urgency` (none/soon/urgent/overdue) · `source` (auto/manual — AUTO chip: `bg/surface-sunken`, `type/caption-2`, tooltip "Synced from Portal") · `dateConfidence` (confirmed / **needs-date**: due line → amber "Date needed — tap to set" with dashed underline) · `state` (default/done: title strikethrough `text/tertiary`, card 60%).
Done animation: check draws (`motion/celebrate`), card fades, ring/stat updates live.

## 5.7 Statistics Cards `[C-StatCard]`

- **Completion Ring:** 96pt (dashboard) / 140pt (Progress page); track `gray/200` (dark: `#232B3B`), fill `green/500`→`green/600` conic, 10pt stroke round caps; center % `type/display` tabular; sublabel `type/footnote`. Trend chip `↑ 6%` green / `↓` red-outline-only (calm). Fill animates on appear (`motion/gentle`), respects Reduce Motion.
- **Exam Countdown:** overline `NEXT EXAM`, course name `type/headline`, `D-5` in `type/display` `font/family/display-round` (turns `red/500` at D-2; shows hours at <48h: `36h`), date/room footnote. `changed` amber chip when rescheduled. Stacked variant lists ≤3 exams during clusters. Manual entries carry `MANUAL` chip.
- **Semester Progress:** 8pt bar `radius/full`, fill `bg/accent`; milestone ticks 2×12pt (`◆` labeled on tap): add/drop, midterms, finals; label `Week 8 of 18 · 42%`. Tap → milestone timeline detail.

## 5.8 Sticky Notes `[C-StickyNote]`

- 6 note colors (Light: yellow `#FFF6C9` / pink `#FFE4EF` / blue `#E3F0FF` / green `#E1F7E7` / purple `#F0E9FF` / gray `#F0F2F5`; Dark: same hues at 22% saturation on `gray/800` base with colored 3pt top edge instead of full fill — keeps dark mode calm).
- `radius/md`, NO shadow (flat, premium — not skeuomorphic curl), padding `space/4`, text `type/callout` max 6 lines + "…more"; meta row: 📌 date chip if dated.
- Sizes: rail 148×148 (dashboard) · masonry min 148 max 320 height.
- Long-press (touch) / drag (desktop) to reorder; edit in place on desktop, sheet on phone.

## 5.9 Inputs & Controls

- **Text field:** 44pt, fill `bg/surface-sunken`, `radius/sm`, no border until focus (2pt `border/focus`); label above `type/caption-1` `text/secondary`; error: 1.5pt `red/500` + footnote message below (never color-only).
- **Checkbox (task):** 24pt circle, 1.5pt `border/strong`; hover previews check at 30%; checked = `green/500` fill + white check (spring draw). Priority-flagged tasks ring the checkbox in priority color.
- **Chip `[C-Chip]`:** 28pt pill, `type/caption-1`, fill `bg/surface-sunken`; selected = accent tint + accent text; optional leading dot/icon 14.
- **Segmented control:** iOS-style, 32pt, `bg/surface-sunken` track, floating `bg/surface` thumb with `shadow/card`, `motion/quick` slide.
- **Toggle:** iOS switch, on = `green/500` (system convention) — settings only.
- **Search field:** 36pt pill, leading magnifier 16, placeholder `text/tertiary`; desktop shows `⌘K` key-cap hint trailing.

## 5.10 System Feedback

- **Sync status pill `[C-SyncPill]`:** ◍ `Synced 09:41` (green dot) · ↻ animating `Syncing…` · ⚠ amber `Sync failed — retrying` (tap → diagnostics) · ⭘ gray `Offline`. Header (phone) / sidebar bottom (tablet+). This pill is *permanent UI* — trust metric.
- **Banner:** full-width under header, `radius/md` inset 16, icon + `type/subhead` + optional action; variants info(blue)/warning(amber)/error(red) at 10% tint fills. Offline banner: "Offline — showing data from 09:41."
- **Toast:** bottom-floating 8 above tab bar, `bg/surface-raised`, `shadow/raised`, auto-dismiss 4s, single action slot ("Task hidden · **Undo**").
- **Badge:** dot 8pt `red/500` (tab), count pill 16pt min. "NEW" chip for fresh auto-synced assignments (first 24h). `⚠ changed` amber chip (48h) for room/time/exam changes.
- **Skeleton:** `gray/100`↔`gray/200` shimmer (dark `gray/800`↔`#232B3B`), 1.2s; module-shaped, never full-screen spinner.
- **Empty states:** 56pt duotone icon `text/tertiary` + one-line `type/callout` + optional Secondary button. Copy is warm, never blaming ("No tasks today — go touch grass 🌿" en / 「今天沒有任務——出去走走吧 🌿」zh).

---

# Part 6 — Dark Mode

Dark mode is a **first-class equal**, not an inversion. Governing choices:

1. **Near-black, not pure black:** canvas `gray/950 #0B0F17` (blue-cast to match brand); surfaces step *lighter* with elevation (`900 → 800`) per Material/HIG depth logic.
2. **Borders replace shadows.** Elevation reads via 1px `border/subtle` + surface step, not glow.
3. **Accent brightens:** `blue/400` replaces `blue/500`; all functional hues shift to their 400-step (pre-validated 4.5:1 on `gray/900`).
4. **Desaturated tints:** category/course tints render at 14–18% alpha over surface rather than pastel fills — prevents "neon confetti" dashboards.
5. **Sticky notes** switch to colored-edge treatment (§5.8) — full saturated fills are the one place dark mode would otherwise glare.
6. **Text:** `#F5F7FA` primary (never pure white — halation), secondary `gray/400`.
7. **Images/illustrations:** onboarding art has explicit dark variants (Figma variable mode swaps).
8. Mode switch: Auto (follows OS, default) / Light / Dark in Settings → Appearance; every component variant is verified in both Figma variable modes before publish.

---

# Part 7 — Accessibility & Localization (Design Requirements)

- **WCAG 2.1 AA:** all token pairs pre-validated (§1.2); urgency/priority never color-only (dot + text label); focus visible on every interactive element (2pt ring).
- **Dynamic Type:** layouts tested at AX1–AX3; stat cards reflow 2-up → stacked; tab labels persist (HIG).
- **VoiceOver/TalkBack:** reading order top-down per module; checkbox announces "OS HW3, due today 11:59 PM, not completed, double-tap to complete"; countdown announces full phrase not "D-5."
- **Hit targets:** ≥44×44 everywhere, ≥24pt gap between destructive and primary swipe zones.
- **Localization:** all frames authored with zh-TW and en strings (Figma variables `string/*` with `zh-TW`/`en` modes); zh strings average −20% length but +15% line-height — buttons and chips use hug-content, never fixed widths. Dates: `7月11日 (二)` / `Tue, Jul 11` via locale tokens.

---

# Part 8 — Figma File Organization & Handoff

```
📁 NYCU Student OS — Design
├── 📄 00 Cover & Changelog
├── 📄 01 Foundations (tokens, color ramps, type specimens, grids, icons)
├── 📄 02 Components (published library, all variants × Light/Dark modes)
├── 📄 03 Wireframes (lo-fi flows, this doc's Part 3)
├── 📄 04 Hi-Fi — Phone (390) · all screens × Light/Dark × zh/en
├── 📄 05 Hi-Fi — Tablet (1024)
├── 📄 06 Hi-Fi — Desktop (1440)
├── 📄 07 States & Edge Cases (empty, offline, error, dense, AX sizes)
├── 📄 08 Prototypes (onboarding flow · daily loop · task complete · calendar nav)
└── 📄 09 Handoff (redlines, motion specs, a11y annotations)
```

- **Variables:** collections `Core Colors` (Light/Dark modes) · `Strings` (zh-TW/en) · `Layout` (Phone/Tablet/Desktop modes for spacing).
- **Component props over variants** wherever possible; boolean props for badges/chips; instance-swap slots for icons.
- Every hi-fi screen frame carries an annotation sidebar: tokens used, motion refs, a11y notes, PRD acceptance-criteria traceability ID (e.g., `AC-5.7.3`).
- Prototype flows required before dev handoff: Onboarding→First Sync→Dashboard · Morning check ritual (open→scan→check off→close, target <60s) · Deadline notification→Task detail deep link.

---

## Appendix A — PRD Traceability Matrix

| PRD Feature | Primary screens | Key components |
|---|---|---|
| 5.1 Portal Login | Onboarding 0.2–0.5 | Button, security footnote, webview frame |
| 5.2 Course Sync | Courses, Timetable, SyncPill | CourseCard, changed-badge, banner |
| 5.3 Assignment Sync | Tasks, Today | AssignmentCard, AUTO chip, needs-date state |
| 5.4 Notifications | Settings 8.3, digest overlay | Banner, digest notification spec |
| 5.5 Calendar | Calendar M/W/D | MonthDayCell, WeekEventBlock, DeadlineLane, FilterChipRow |
| 5.6 Timetable | Timetable | WeekEventBlock, NowLine, ClassDetail sheet |
| 5.7 Dashboard | Today + Edit Mode | All modules, StatCard, ScheduleRow |
| 5.8 Sticky Notes | Notes, Today rail | StickyNote, editor sheet |
| 5.9 Todo | Tasks | TaskRow, checkbox, QuickAdd |
| 5.10 Completion Rate | Progress, Today | Completion Ring, trend bars |
| 5.11 Semester Progress | Progress, Today | ProgressBar + milestones |
| 5.12 Exam Countdown | Today, Progress | Countdown StatCard, stacked variant |

*End of Design Specification v1.1*

---

## Revision Log

| Version | Date | Change |
|---|---|---|
| v1.0 | — | Initial frozen specification. |
| v1.1 | 2026-07-16 | **DS-AMD-001** — §1.1: functional-hue 400-step column documented (5 new values: `yellow #F7D144`, `purple #9B8AFB`, `teal #2ED3B7`, `pink #F670C7`, `indigo #8098F9`; 3 formal labels: `red/400 #F97066`, `orange/400 #FDB022`, `green/400 #32D583` — values pre-existing in §1.2, unchanged). Completes the dark-mode alias set required by §1.2 event tokens and the Part 7 dark-mode rule. All 400-steps WCAG-verified ≥ 4.5:1 on `gray/900`/`gray/950`. Ratified via INFRA-009 Escalation, Option A. No other value changed. |
