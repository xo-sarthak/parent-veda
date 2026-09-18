# Base UI — what was settled, and the calls that are yours

**Written 2026-09-17.** The user asked for the base of the app — colour, type,
buttons, components — to be settled once, from what the long-standing and the
current apps do, so V3 keeps its restraint and nothing new regresses. This is
the record: §1 what was done without asking (mechanical, reversible, in line
with decisions already written down), §2 the calls that need the user, §3 the
work that follows once §2 is answered.

Read with `DESIGN-SYSTEM.md` §4.0 (the rule) and `MOBBIN-DISCOVERY.md` §6
(the audit).

---

## 1. Done — the base is white, ink and one type family

| Change | Where | Why it needed no asking |
|---|---|---|
| **Page ground is white** (`#FFFFFF`, hairline `0x1F`) across the app — the V2 palette default and every constant that copied the old `#F5F3F6` | `v2_palette.dart`, `pp_common.dart`, `ttc_common.dart`, `game_chrome.dart`, five Garbh screens, `journal_compose_screen.dart` | the user said it, on a side-by-side: "that purple tint… it has to be fixed across the app" |
| **Plus Jakarta Sans is retired into Manrope** — `pvJakarta()` now renders Manrope at the same size, so 433 call sites in 79 files moved in one line | `pv_fonts.dart` | DESIGN-SYSTEM §2.2(a) decided it on 2026-08-16; it was never executed |
| **The commit button is the ink pill** — `FilledButton` and `ElevatedButton` themes: `onSurface` fill, white label, stadium shape; `OutlinedButton`: white pill, hairline, ink label | `app_theme.dart` | the §4.0 rule; 228 `FilledButton`s follow the theme, so the same button appears everywhere |
| **Onboarding chrome** follows §4.0: ink primary, white Google button, ink-selected chips and tiles, colour only in the icon wells | `onboarding_chrome.dart`, `onboarding_flow.dart` | the first consumer of the rule; the user rejected the violet version on sight |
| **The Premiere is off at app open** (Cetaphil / Calm Balm demo) | `main_scaffold.dart`, `my_child_screen.dart` | "it's opening again and again" — commented, Brand Showcase still opens it on demand |

| **Newsreader replaces Fraunces** as the display face — through the `pvFraunces` / `pvDisplayStyle` seams, so 500 call sites moved in two lines; the 80 direct `GoogleFonts.*` calls now go through the seams too | `pv_fonts.dart`, `askveda_screen.dart`, `pp_common.dart`, `reading_reader_screen.dart`, `my_child_screen.dart` | §2.3, answered 2026-09-17: "if it reads as AI-generated, change it" |
| **The three home-version pills moved to Profile → Developer** | `developer_switches.dart`; mounts commented in the three homes | §2.2, answered: (b) |
| **The reader's clinical callout lost its amber** — urgent is the one callout in a well, the others sit inline between hairlines; ink icon, no tint | `pv_reader_screen.dart` `_callout` | the user, on the phone: "gimmicky and random" |
| **One push transition app-wide** (Cupertino slide with swipe-back on both platforms) and **press feedback** (a 2% settle, 120 ms) on every base component | `app_theme.dart`, `onboarding_chrome.dart` `ObPress` | "focus a lot upon motions — stuff that silently appeals" |
| **The tool sheets cover the viewport and own the nav clearance** — the hero field's lower arc no longer bleeds through as a lilac bloom under short tools or under a tool's last card | `ttc_tool_chrome.dart`, `ttc_window_screen.dart`, `ttc_infographic_screen.dart`, `problem_hub_screen.dart` | seen on the phone walking the user's path; DESIGN-SYSTEM §4.1 already said the sheet owns the clearance |
| **TTC meta text and hairlines are grey, not lavender** (`ttcMuted`, `ttcBorder`); **the stage menu's icons are ink** | `ttc_common.dart`, `stage_gateway.dart` | §4.0 — the accent is for eyebrows and links, not small print |
| **The ripple is grey and shaped by the control** — `InkRipple`, `onSurface` at 6% / 3%; the M3 sparkle ignored clips and drew a violet rectangle on rounded rows | `app_theme.dart`, `pv_reader_screen.dart` `_references` | the user, on the References row: "these things just make the app look bad" |
| **Rail art no longer loops; blurred deck cards and the hero field are their own layers** | `ttc_illustrations.dart`, three carousels, `v3_hero_field.dart` | "jittery when exiting a door" — STILL-OPEN §63.4 |
| **Focused inputs ring in ink, not violet**; the caret keeps the accent | `app_theme.dart` `inputDecorationTheme` | seen on the scan note sheet |
| **Tap feedback is a component** — `PvPress`, `PvTick`, `pvCommitFeedback` | `lib/widgets/pv_feedback.dart` | "make the user feel like they did something" — DESIGN-SYSTEM §4.0c |
| **Android pushes with fade-forwards, not Cupertino** — no dimming layer under the new page; back is the system gesture | `app_theme.dart` | "opens with an overlay… closes with an overlay… a single swipe back turns into two" — STILL-OPEN §63.5 |
| **The scans timeline is one card and a dated list** — no legend, no status pills, no colour states | `scan_timeline_screen.dart` | "I hate this screen" — STILL-OPEN §63.6 |
| **Coming-soon film thumbnails stay inside their well** — the gradient's end stop was the deep tone (L 0.52), a violet slab on white; now it travels a third of the way | `pv_placeholders.dart` | seen on the condition page in the reader, 2026-09-17 |

Everything above is commented for revert where it replaced something.

**Answered 2026-09-17:** 2.1 (a) the FAB stays violet · 2.2 (b) done · 2.3
Newsreader, done · 2.4 explained, nothing to change · 2.5–2.7 as recommended.

## 2. Your calls — read, answer, and the follow-up runs

### 2.1 The Ask Veda FAB — violet fill, on every screen

Today it is the one filled-violet circle left on the V3 home. Two readings:
**(a) keep it** — it is the app's signature action, one per screen, and a
brand-coloured floating button is what Airbnb (rausch), Notion (blue) and
Duolingo do with their single "the app's own thing" control; **(b) ink it**
— the same rule as every other button. *Recommendation: (a).* A signature
needs one home, and this is the one place the brand colour is doing a job.

### 2.2 The Classic / V3 pill on the homes

A reviewer control, now sitting on a final screen. **(a) keep until the
classic screens are deleted** (STILL-OPEN §61.4 timing); **(b) move it into
Profile → Developer** so the home is clean; **(c) remove now**.
*Recommendation: (b)* — the comparison is still useful for a month, and the
home should not carry a switch.

### 2.3 Fraunces stays as the display face — confirm — ANSWERED: replaced with Newsreader

The design system pairs Fraunces (display) with Manrope (text). It is what
you chose in the Claude Design and what the V3 homes wear. One honest note:
Fraunces has become common in AI-generated UI, and a reviewer may read it as
generic. Alternatives with the same warmth and better metrics on a phone:
**Newsreader**, **Source Serif 4**, **Instrument Serif** (display only).
*Recommendation: keep Fraunces* — it is already on 500 call sites and the
homes look right; revisit only if you see it elsewhere and it bothers you.

### 2.4 The accent stays violet, and it stays on these five things only

Eyebrows · links · a switch's on-state · the progress hairline · the verified
mark. Material's `colorScheme.primary` is still violet, so Switch, Checkbox
and Slider draw it by default — that is the rule working, not a leak.
*Nothing to decide unless you want the accent hue itself changed*; the whole
app reads `action` from the palette, so that is one value.

### 2.5 Type sizes — confirm the ramp or ask for a bigger body

DESIGN-SYSTEM §2.2(b) fixes nine roles (display 42 · title1 27 · title2 22 ·
title3 20 · cardTitle 16.5 · body 15/17 · meta 11–12). Mobile type in the
apps audited runs 15–17 for body and 11–12 for metadata — we are inside that.
The one thing worth your eye: **metadata at 11 on a Devanagari screen**
(UX-PRINCIPLES 0.1 — Devanagari runs ~30% wider and needs more line-height).
*Recommendation: leave the ramp; raise `meta` to 12 only if the phone shows
it cramped.*

### 2.6 Card radius 16 and button radius pill — confirm the split

Cards and tiles stay at 16; buttons and chips are pills (999). Every audited
app that reads premium keeps these two apart (Airbnb: 12–16 cards, pill
buttons). *Recommendation: keep.*

### 2.7 Dark mode

`AppTheme` has a dark scheme and the reader has a dark mode. Nothing in this
pass touched it, and nothing audited was checked in dark. *Recommendation:
out of scope until light is settled; then one pass.*

### 2.8 The door deck — tightened, or replaced by chips? — OPEN 2026-09-18

You said: *"I like this swipe animation… but it takes too much space."* Done
without asking: the deck is tightened (card 172×132 → 156×112, track 146 →
124, mark 74 → 62, the gaps either side 22/26 → 14/18 — about 54pt back, on
all three stages). The call: Mobbin's set splits cleanly. When a carousel IS
the task (Klarna "pick your card", Lloyds "choose an account", Tubi's age
rating) it takes the whole screen. When it is a **selector above content**
(Gymshark Workouts / Plans / Creators, DAZN Teams / Standings, Waking Up
Practice / Theory / Life) every one of them uses a **compact row of chips**
and gives the height to the content. Our door is the second case.
**(a)** keep the tightened deck — it is the app's own signature and you like
the motion; **(b)** replace it with a chip row (one line, ~44pt, the content
starts on the first screen) and keep the deck for the hero only.
*Recommendation: (a) for now, and (b) if the next walk still feels tall* —
the tightened deck should be judged on the phone before the signature is
given up.

**Resolved 2026-09-18 — (c), the low deck.** The user saw (b) on Scans &
tests ("minimalistic and clean") and still wanted the swipe: "find a way…
these card swipes… space efficient… this is the last try." The card changed
shape rather than the selector: a wide low landscape card (196×64, mark at
the left, label beside — the low cards in the Mobbin set, Plenty of Fish and
Lloyds, are all icon-left) on the same fan, blur, ring and swipe; track
124 → 76; the selector ~170pt → ~98. On every door of every stage.
`PvDoorChips` stays built behind `kPvDoorChipDoors` (empty).

**Later the same day — four selectors, and the user's own reference.** He
found Flo's doors and asked for that: a flat rail of tall white cards that
STRADDLES THE SEAM between hero photo and sheet, big drawn mark, full label
(never truncated), chevron, plain swipe. Built as `PvDoorRail` and put on
Scans & tests (`kPvDoorRailDoors`); the hero's photo bleeds further under
the sheet on rail doors so the cards sit on picture, not field. He also
liked the TILE ROW (`PvDoorTiles`, DoorDash/Skip/Glovo — icon tiles with a
label beneath, all visible, one tap) which is on Complications
(`kPvDoorTileDoors`); its wells now sit on one line (fixed label box, fixed
border width). The low deck (`PvDoorCarousel`, now white cards, drawn
marks, no dots) is on every other door. Every group can carry an
`IntentMark` (`PvDoorGroup.mark`) — set explicitly per door, never mapped
from an icon. **Open:** which of rail / tiles becomes the one selector for
all doors of all three stages; the user judges Scans & tests (rail) against
Complications (tiles).

**The rail card, trimmed (2026-09-18, 21:30) — "this looks way better."**
Three asks, all kept reversible in `pv_door_rail.dart`: the tinted square
around the mark is gone — the drawn mark sits BARE on the white at 48pt,
the way Flo's cards carry their icon (`bareMark = true`; the well is under
the `else`); the card is 136 tall, not 164 — the gap between mark and
heading was air, not composition; the selected ring is 1.2pt, not 1.8.
The hero bleed and the sheet slot derive from `cardHeight`, so nothing
else moved. Decided on the phone, release build.

**And the card itself, same day:** "remove these funky colors… it looks
gimmicky and not ready." Mobbin's production cards of this shape (ANZ Plus,
CVS Health, Air NZ, Beli) are unanimous — white, one hairline, a line icon in
a small neutral square, bold title, grey one-liner. The deck card is that
now: white with the page hairline, the icon in a 40pt well carrying a whisper
of the group's tint (the one place colour may show), Manrope label, grey
count line, neutral shadow on the front card, rear cards dimmed towards the
ground. The hue-keyed gradient, rim, shadow and the orbiting-ring
illustration are retired (`_PvDoorMark` kept in the file).

### 2.9 Where search lives — DECIDED 2026-09-18

The user asked for a search bar and asked where, having noticed "it is in
trend to have it at the bottom". Mobbin, three passes:

- **The bottom bar is a search-SCREEN pattern, not an entry.** iOS 26 drops
  the field onto the keyboard once you are already searching — Apple Games,
  Apple Podcasts, Linear, Wabi, Grok, Rodeo. None of them put a field at the
  bottom of a page that is about something else.
- **The entry is at the top, everywhere.** Flo: a field under the heading
  of a topic page ("How to get pregnant": title, one line, white field,
  card rail) and in the app bar of its browse tab. Superpower under its
  heading. CVS, Bloom, Yazio, Apple Health, GoodRx: the field is the first
  thing on the search screen, keyboard up, recents and suggestions below.
- **The field itself is white or grey, never brand-coloured** — every one
  of them.

Tried, in order, on the phone: (1) a bar between "Start anywhere" and the
grid on the home plus a glass search circle top-right of each door — the
user: "not below Start anywhere, that wasn't my intent… I like your button
idea but that isn't very intuitive"; (2) **the bar under the blurb in every
door's hero, Flo's spot — CHOSEN.** The home bar and the circle are
commented out, kept for revert.

What it opens is `PvSearchScreen`: field at the top, keyboard up; before
she types, *Recent* (`PvSearchStore`, six, local) and *Start with* (the
door's tabs — derived, never a typed "popular" list); as she types, rows
that open through the door's own router; a chip pair *In Scans & tests /
Everywhere*; and under any list, or alone under none, *Ask Veda about "…"*
— the miss is never a dead end. The index is `kPvDoorPages` read once;
matching is word-prefix ("nt" finds NT scan, not appointment).

**No violet in any field, at rest or on tap** — the user's rule, applied
app-wide in `app_theme.dart`: white fill, hairline, ink ring, ink caret,
grey selection. It was lavender fill + violet caret + violet handles: "when
tapped the grossness doubles."

**§2.1 is answered by this too.** The user, 2026-09-18: the FAB "seems very
purple and outdated… like a sore thumb on the Products page." (b) it is,
after the door selector is finalised. Recorded in STILL-OPEN §63.11.

## 3. The follow-up sweep, once §2 is answered — work, not decisions

- **Hand-rolled violet buttons** — 24 `backgroundColor: AppTheme.primary…`
  and 43 `Color(0xFF6A30B6)` uses. Some are eyebrows and links (correct);
  the rest are custom buttons that should become `FilledButton` /
  `OutlinedButton` so the theme owns them. One file at a time, classic
  screens last.
- **`pvJakarta` → `pvManrope`** call-site rename (cosmetic; the seam already
  renders Manrope).
- **The Garbh screens' `_cream`** constants → read the palette instead of a
  copied value (they are white now, but a copy drifts again).
- **The reviewer pills** per §2.2.
- **Device walk** of every V3 home and the onboarding on white, with
  screenshots into `docs/`. *Done 2026-09-17 for the user's own path
  (STILL-OPEN §63.3); the parenting home and the onboarding remain.*
