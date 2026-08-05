# Refinement pass — 2026-08-04

A screen-by-screen walk of **ParentVeda (parenting side)** and **ParentVeda+ (all
of it)** on a real device, with every finding traced to source. Nothing here was
found by reading code alone; each item was seen on a phone first and the
mechanism confirmed afterwards.

**How to read this file.** Every item is tagged:

| Tag | Meaning |
|---|---|
| **UI** | Mechanical. A wrong colour, a broken layout, a typo, a miscounted grid. No decision needed — being executed now. |
| **HOLD** | Needs a decision from the user before code can be right. Parked at the bottom of this file with the question stated. |

The split matters because most of the expensive items are not bugs, they are
*unanswered questions* — which of three Grow versions ships, what the child's
real birth date is, whether the brand names are real. Writing code against a
guess there costs more than waiting.

---

## Root causes

Most symptoms below trace to seven causes. Fixing the cause fixes the list.

### R1 — The child's age has no single source **[HOLD]**

Six answers from one profile:

| Screen | Says |
|---|---|
| My Child phase card | 0–4 weeks |
| Growth journey | 0 weeks |
| Feeding / Sleep journey | newborn *(correct)* |
| Vaccination | 4 months; dates imply birth 8 Mar 2026 |
| Child Snapshot + Grow domains | ~4 months, **hardcoded literals** (`my_child_screen.dart:1561`) |
| My Journal | Aarav, 2y 4m |

Content selection ignores age entirely: Recipes all 6–12 mo, Read "Leap 4",
Courses "The 4-Month Sleep Regression", Watch prints "3–6 mo" under a heading
saying *"Picked for his age"*, and a video asserts *"Your baby is right in the
middle of the 4-month sleep shift"* to a newborn's parent.

### R2 — Health status asserted from an empty record **[HOLD]**

Vaccination: **"On track, and protected."** above **0/23 done · 1 due**.
Health Wallet: **"Healthy · Everything looks fine"**, **"Up to date"**,
**"Growth: On track"** — with nothing recorded anywhere.

Four screens disagree about one vaccine: Tools *"Next due in 3 weeks"* / hero
*"0 overdue"* / timeline *"Due now · 8 Mar 2026"* / Wallet *"Up to date"*.

Green reassurance generated from an empty record is the wrong failure direction
for this app. See the "never a diagnosis" line in CLAUDE.md.

### R3 — `${_child.name}` defaults to a capitalised "Your baby" **[UI]**

Mid-sentence capital Y in ~15 places: *"How **Y**our baby is doing"*, *"Help
**Y**our baby grow"*, *"Add **Y**our baby's latest weight"*, *"for **Y**our
baby's higher education"*, *"AI readings for **Y**our baby"*, and more.

### R4 — Version and debug affordances are user-visible **[HOLD]**

Grow **V1/V2/V3** + "What ships today" · Health Wallet **V2/V3** + "The brief,
as written" · **"Brand Studio (debug)"** in the drawer · **"My Journal V2"** ·
**"VERSION 2 · THE BABY NAMING JOURNEY"**. The Grow switcher also floats over
the black card's text.

Hold, because hiding them requires knowing which version wins.

### R5 — The shared Explore kit has drifted **[UI]**

Every screen using `pp_explore_kit.dart` inherits the same four faults:

- **Double-boxed search bar** — a filled field inside a bordered container.
  Yoga, Find help and Nuskhe use the correct single box, which is how we know
  it is a bug and not a style.
- **Chip rails clip mid-word** at the right edge.
- **"See more"** on two screens, **"View all"** on the others.
- **Three different trust-banner icons** for the same banner.

### R6 — Icon colour is inconsistent **[UI]**

Black icons in Tools, the Community header and post actions, Watch categories
and Products filters. Purple everywhere else.

### R7 — `kAskFabReserve` is honoured only by TTC **[UI]**

`global_ask_fab.dart` defines the constant and documents the contract: *"screens
reserve `kAskFabReserve` at the bottom of their scroll padding."* No parenting
screen does. That single omission is every FAB overlap in the app.

---

## ParentVeda+ (doctor app)

### Tier 1

| # | Finding | Tag |
|---|---|---|
| D1 | **One login, three doctors.** Home = Dr. Neha Sharma; Impact + QR = Dr Meera Rao; tapping "Pregnancy" = Dr. Ananya Rao. `doctor_home_screen.dart:120` calls `firstDoctorOf(stage)` → `DoctorSession.enter()`, a persisted identity swap its own comment marks "TESTING". `doctor_impact_screen.dart:62` reads `partner.name` while the header reads the expert record. | HOLD |
| D2 | **Practice setup is a mockup.** No `TextEditingController` anywhere; chips have no `onTap`; all three Uploads dead; Finish pops silently. Verified: "TESTNAME" typed into *Full name* on step 1 reappeared under *Qualification* on step 2 (element reuse). | HOLD |
| D3 | **Impact says 0 consultations, Earnings says ₹3,840.** Adjacent tabs. Same cause as D1. | HOLD |
| D4 | **Prescription addressed to the prescriber** — *"For Consult · Dr. Neha Sharma"*, which is `b.title`, the parent's purchase label. AppBar also says "Dashboard". | UI (AppBar) + HOLD (title) |
| D5 | **Past consultations offer to cancel themselves** — ⋮ on a finished consult offers "Cancel — use this if you cannot make it" and "Mark as no-show". | HOLD |

### Tier 2

| # | Finding | Tag |
|---|---|---|
| D6 | "Taking bookings" knob invisible — `Switch(activeThumbColor: ppPurple)` on M3's purple active track. Also hits Brand Studio's "Demo mode" in the parent app. | UI |
| D7 | Subtitle "No consultations booked yet." beside a tab reading **Past (6)** | UI |
| D8 | Onboarding chip-group labels indented — parent `Column` centres, `Wrap` shrinks while `TextField` fills | UI |
| D9 | "Paediatrician" and "Pediatrician" three lines apart on Profile | UI |
| D10 | Profile never shows the signed-in email | UI |
| D11 | Every Earnings row names the doctor, not the parent | HOLD |
| D12 | Registration "the single most important thing" accepts empty via Skip *and* Continue | HOLD |
| D13 | "Account number" is the only field with no placeholder | UI |
| D14 | "Copy the link" / "Share the link" — same icon, near-identical label | UI |
| D15 | Slot dates read "Mon 3/8" — ambiguous on a clinical schedule | UI |
| D16 | Impact's 7 stats in a 2-col grid orphan "Guides read" | UI |
| D17 | No orientation lock | UI |

---

## ParentVeda — parenting

### Tier 1

| # | Finding | Tag |
|---|---|---|
| P1 | **Watch's category filter is broken** — 15 chips render full-width and stack, pushing content ~1000px down. The chip `Container` sets `alignment: Alignment.center`, wrapping the child in an `Align` with no `widthFactor`; under `Wrap`'s loose constraints that expands to full width. | UI |
| P2 | **Brand Studio ships real brand names and logos** — Cetaphil, Himalaya, Philips Avent, Pampers, Nestlé, Apollo, Fisher-Price — captioned "Not real partnerships", in the user-facing drawer. "Presented by Pampers" also sits on the live Sleep journey. | HOLD |
| P3 | **My Journal is a disconnected demo world** — greets *Priya*, child *Aarav 2y4m*, entries dated 2025, "Good morning" at 3 PM, its own 5-item bottom nav. | HOLD |
| P4 | **Backing out of the Journal exits the parenting stage** and lands on the pregnancy Calendar. | HOLD |
| P5 | **Wordmark truncates to "Parent…"** — four header icons no longer fit. | UI |
| P6 | **Premiere fires twice per session** (app open + entering parenting), blue, empty image area. `kPremiereAlwaysShow` still `true`. | HOLD |
| P7 | **Placeholder art almost everywhere** — baby avatar, all Products, all Recipes, Watch collections, Yoga, expert avatars, Launches hero. | HOLD |
| P8 | **Player works; content does not.** A 17-second clip of a house and parked cars (readable number plate) under a title advertising 12 min. Scrubber is YouTube red. | HOLD (content) + UI (scrubber) |
| P9 | **Vaccination renders two Ask Veda FABs**, stacked. | UI |

### Tier 2

| # | Finding | Tag |
|---|---|---|
| P10 | Watch collections titled with the doctor's name, then repeat it as the byline | UI |
| P11 | **"4.9 · 312 reviews parents"** — broken word order | UI |
| P12 | Emoji in chrome: 🏆 / 💰 (Products), 🤰 / 👶 (Memories) | UI |
| P13 | Four rating treatments — amber ★, red ♥, pink ★, purple ★ | UI |
| P14 | Five eyebrow colours — purple, coral, amber, grey | UI |
| P15 | Four back-button treatments + Care Circle's bare bold title | UI |
| P16 | Community initials collide — "0–1 Year" → YE, "1 Year Olds" and "2 Year Olds" both → YO | UI |
| P17 | "Awaiting … verification" pill sits above one post, below another | UI |
| P18 | Fabricated view counts (18.2K, 18.6K, 14.3K) | HOLD |
| P19 | Tools list scrolls under the status bar | UI |
| P20 | Three black cards + coral/blue/cream surfaces in a purple app | UI |
| P21 | Read stacks two filter rows both starting with a purple "All" (Courses gets it right) | UI |
| P22 | Health Wallet Quick actions — 5 items, 2 columns, orphan | UI |
| P23 | Memories offers "We're Expecting"; Yoga is the pregnancy screen ported unchanged; Baby names is a pregnancy tool | HOLD |
| P24 | Memories, Astrology and Launches share the identical sparkle icon | UI |
| P25 | Wrong icons — Newborn Diapers = stroller, Water Wipes = broom, Physical domain = baby face | UI |
| P26 | My Bookings "No past sessions yet" and Care Circle empty, while the doctor app shows 6 consults with this parent. Both empty states also lack a CTA. | HOLD (data) + UI (CTA) |
| P27 | Personalize's 0% bar renders as a solid full-width white bar — reads as complete | UI |
| P28 | "Following" pre-set on an expert never followed | HOLD |
| P29 | Straight quotes/apostrophes where the app uses curly ones — **attempted and reverted, see below** | UI, by hand |
| P30 | Brand Studio: "A brand funds a ParentVeda collection existing" (broken); ASCII `->` notation exposed | UI |
| P31 | "Child derma" truncated; "Paediatricians" vs "Pediatrician"/"Gynecologist" on one screen | UI |
| P32 | Trust claims needing verification — the Nuskhe panel, "ParentVeda-verified purchase reviews" | HOLD |
| P33 | Journal photography is stock white/European families | HOLD |
| P34 | Astrology repeats "Off by default…"; Launches is a section with one item | UI (repeat) + HOLD (content) |
| P35 | Truncations — "the first s…", "Developin…", "Problem Solv…", "govt cen…", Baby names' 5th step, "Full ti…" | UI |
| P36 | Four status colours with no legend; grey "On track" reads as disabled | UI |

---

## P29, and why it is not scripted

Worth writing down, because the next person to look at 200 stray apostrophes
will reach for the same tool.

A regex pass over `.dart` files converting `'` to `’` **cannot be made safe**,
and the reason is not sloppiness — it is that Dart's string delimiter and the
English apostrophe are the same character, U+0027. Nothing in the text says
which one you are looking at.

The pass here required an apostrophe flanked by letters and enclosed in quotes,
which sounds narrow and is not. It matched this:

```dart
NameVibe('Sun & light', (n) => RegExp(r'light|sun|dawn|ray').hasMatch(…))
```

by treating the **closing** quote of `'Sun & light'` as an opening quote, the
text `, (n) => RegExp(r` as the string body, and the **opening** quote of the
raw string as the apostrophe to curl. Result: `RegExp(r’light|sun|dawn|ray')`,
an unterminated literal, and 73 test files failing to load.

The second problem is quieter and would have shipped. Where the pass *was*
safe, it was still **partial** — it curled the apostrophes its pattern could see
and left the others, so one sentence came out as *"It's just for pneumonia, so
it’s optional."* Mixed inside a sentence is worse than uniformly straight.

Both changes were reversed line by line rather than with `git checkout`, because
these files also carry the `nameMid` work and a second agent's edits.

**If this is worth doing, it is worth doing from a list of specific strings** —
the ones actually seen on screen — not from a pattern.

---

## Held for a decision

These need an answer before code can be right. Each is stated as the question,
not the fix.

1. **R1 — What is the child's real birth date, and which screen owns it?**
   Until one source wins, every other screen is guessing. Secondary: the Child
   Snapshot and Grow domain content are hardcoded for ~4 months — do we write
   age-banded content, or derive from the existing leap/phase data?
2. **R2 — What should a health summary say when nothing is recorded?**
   "Nothing recorded yet" is honest; "Everything looks fine" is not. Needs your
   call, and arguably a clinician's.
3. **R4 — Which Grow version and which Wallet version ship?** Hiding the
   switchers means picking a winner.
4. **P2 — Are the brand names real?** If not, they must become invented names
   before any build leaves this machine.
5. **P3 / P4 — Is My Journal meant to read real data**, and should backing out
   of it land in parenting rather than pregnancy?
6. **P6 — When do `kPremiereAlwaysShow` and `kDailyPopupAlwaysShow` go false?**
7. **P7 / P8 / P33 — Where do the real images and videos come from?**
8. **P18 / P28 / P32 — Which demo signals do we keep**: view counts, pre-set
   "Following", the Nuskhe review panel, "ParentVeda-verified reviews"?
9. **P23 — Do pregnancy tools belong in the parenting app?** Memories'
   "We're Expecting", Yoga's prenatal-first framing, Baby names.
10. **P26 — Why does the parent see no bookings** while the doctor sees six with
    them? Data question before a UI one.
11. **D1 / D3 — Retire the stage toggle, and resolve one identity per account.**
12. **D2 — Does practice setup get real state now**, or stay a walkthrough until
    the admin panel can review submissions?
13. **D5 / D12 — What may a doctor do to a past consult**, and must registration
    be mandatory?
14. **D11 — Earnings rows should name the parent** — is the parent's name
    available to the doctor at that point, and are we comfortable showing it?

---

## What is good, and should not be touched

Growth journey · Feeding journey · Sleep journey · What Changed (hub and flow) ·
the activity detail pages · Product Guide · Personalize · Nuskhe · Find help ·
the Saved hub · the Products category guidance · the video player mechanics ·
and the Launches disclosure copy — *"Brands pay to launch here. They do not pay
for what the expert says."*
