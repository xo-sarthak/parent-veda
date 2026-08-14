# ParentVeda — app audit, seen firsthand

> **What this is.** A walk through the live app on a real device (Samsung SM-G990B2,
> 1080×2340), 2026-08-12. The app had never been looked at in any of the design work
> before this — palettes and type were being proposed from `app_theme.dart` constants
> alone.
>
> **Companions.** `DESIGN-BRIEF.md` (evidence) · `DESIGN-LAYER.md` (the system) ·
> `DESIGN-DECISIONS.md` (the log). Read this before either of the first two — it changes
> a recommendation in `DESIGN-LAYER.md` §1.
>
> **Method.** Screenshots via `adb exec-out screencap`, assembled into contact sheets.
> Navigation only — nothing changed, bought, sent or deleted.

---

## 1. What was seen, and what was not

**Seen:** all three live stages.
- **Pregnancy** (30 weeks / T3) — Today (Classic), Today (Focus), Prepare, Tools,
  Calendar, Community, Ask Veda, and **Father Mode**.
- **Trying to conceive** — Today, full scroll.
- **Parenting** (0–4 weeks) — entry takeover, Today-in-one-watch sheet, My Child home,
  full scroll.

Stage doors sit at the top of the pregnancy Today screen — *"Post-Pregnancy — Baby's
arrived? Step into the parenting app"* and *"Trying to conceive — Planning a baby? Start
the journey here."* They navigate; they do not mutate the profile.

**Not seen:** profile / settings screens. Stage 4 (Skilling) does not exist yet.

---

## 1a. ⚠️ Two corrections from the user, 2026-08-12 — read before §2

1. **The Classic|Focus and Mom|Dad pills are test scaffolding**, not shipping UI. The
   overlap defect in §3.1 therefore reduces to **the Ask Veda FAB alone** — which is
   real, ships, and still covers content on Prepare, Calendar and the article lists.
2. **Father Mode's slate palette is deliberately father-exclusive**, to differentiate the
   father side. It is **not** the direction for ParentVeda generally, and is open for
   separate discussion later.

**Correction to my own reasoning:** I conflated palette with craft. Father Mode is
*warm cream ground + **slate cards** + serif + restraint*. The slate is the
father-specific part and does not travel. The rest — warm ground, serif display,
small-caps eyebrows, one accent, circular line icons, calm empty states — is
**palette-independent craft that works identically with violet.**

**And there is better mother-side evidence for it than Father Mode: the Prepare tab and
the whole TTC stage.** Both keep violet, carry no slate, and are the two best-looking
mother-facing surfaces in the app. That is the argument, and it survives the correction
intact.

---

## 2. ⭐ THE HEADLINE — the app already contains two design systems, and the better one is Father Mode

This supersedes the reasoning in `DESIGN-LAYER.md` §1. That section argued for moving
the violet off lavender onto warm paper as a *proposal*. **It is not a proposal. It is
already built, on the father's side, and it looks markedly better.**

| | Mother's Today (Classic & Focus) | **Father Mode** |
|---|---|---|
| Ground | Cool **lavender wash** | **Warm cream / off-white** |
| Cards | White cards, all identical radius and elevation — card-on-card-on-card | Deep slate cards with real hierarchy |
| Display type | Rounded geometric sans | **Serif** — *"Tonight, don't fix it. Just sit with her."* |
| Colour | Violet doing every job at once | Slate + **one** warm amber accent |
| Metadata | Mixed | Consistent small-caps eyebrows — `WEEKLY SNAPSHOT`, `SUPPORT YOUR PARTNER`, `SCANS & APPOINTMENTS` |
| Icons | Tinted squares in ~7 different hues | Circular line icons, one family |
| Empty state | — | *"Nothing due right now — you're both up to date."* Calm, complete, not a prompt. |

**The mother's Prepare tab is in the same better register** — serif display
(*"Prepare for your baby, one guided step at a time."*), warm near-white ground, a rose
small-caps eyebrow (`30 WEEKS · THIRD TRIMESTER`), an `EN | हिं` toggle.

So the two best-looking surfaces in the product — Father Mode and Prepare — both already
use warm ground + serif display + restrained colour. **The recommendation is therefore
not "invent a direction". It is "the product already found it; bring the mother's Today
to it."** Cheaper, faster, lower-risk, and evidenced from inside the product rather than
argued from outside it.

**One tell that confirms the diagnosis:** the Ask Veda FAB stays violet in Father Mode
and is the single jarring element on those screens. It was never re-themed — which is
exactly what a colour that means "important" rather than "actionable" does when it meets
a considered surface.

---

## 3. Defects, ranked

### 3.1 ⚠️ Floating chrome covers content on every Today screen

Five layers compete at the bottom of the viewport: the **Classic | Focus** pill
(bottom-left), the **Mom | Dad** pill (bottom-right), the **nav pill**, the **Ask Veda
FAB**, and the content beneath.

Verified obscured content:
- "Today's Video" card and its `6 min` badge — partly covered
- `Shravan · Sacred Listening` row — covered
- `DAILY MEDICATION AND SUPPLEMENTS` header — covered
- `RESEARCH SUMMARIES` header — covered
- In Focus view, the **ALSO TODAY chips themselves** — "Garbh Sanskar" and "My journal"
  are both partly hidden behind the two pills
- The product-recommendation images sit directly under both pills

This is not a taste judgement. It is content the user cannot read, on the primary screen,
in the default state.

### 3.2 Violet means "important", not "actionable"

On a single Today screen the violet is: the play button, the primary button, a promo
banner (**as a gradient**), the FAB, the active nav pill, the active toggle, section
header blocks, and the eyebrow text. When one colour carries every job, the eye stops
finding the action. `DESIGN-LAYER.md` §2 proposes one job per colour; this is the
concrete thing that rule is for.

### 3.3 ⚠️ Commerce out-weighs content in the visual hierarchy

**"Buy Book" is solid violet. "Read summary" is a pale violet tint.** The purchase gets
primary emphasis and the free content gets secondary, on the same row, repeated down the
list. For a product whose position is *you always know the price before the pitch*, this
is backwards — and it is a one-line fix.

### 3.4 ~~Debug surfaces are shipping to users~~ — ⚠️ WRONG. Retracted 2026-08-14.

**This finding was mine and it was incorrect.** Both tools are already gated:

```dart
if (kDebugMode)
  _Tool('Brand Studio (debug)', …)
if (kDebugMode)
  _Tool('Care Partner (debug)', …)
```

— `lib/screens/tools_hub_screen.dart:124,131`. The parenting equivalent is commented out
entirely. **A release build never shows them.** They appeared on the device because it is
running a **debug build**.

**How the error happened, because it is the same one this project keeps making:** I saw
them on screen and wrote them up without reading the guard. Seeing is necessary and not
sufficient — the phone tells you what a *debug* build does. Nothing was broken; the audit
was.

### 3.5 The Tools grid carries ~7 accent hues at once

Tinted icon tiles in green, purple, pink, red, amber, blue and brown in one 2-column
grid. Against `DESIGN-LAYER.md`'s proposed invariant of **≤2 accent hues per screen**.
Also every one of ~24 cards repeats the word **"Open →"** although the whole card is
tappable — 24 identical redundant labels.

### 3.6 Decorative emoji, against the repo's own rule

`CLAUDE.md` states: *no decorative emoji in chrome; line icons.* Live: 🌷 🥗 on community
cards; 👶 🧒 👨‍👩‍👧 as Ask Veda category headers; 💬 🤝 🎵 🌿 📖 as article row icons.

### 3.6a ⚠️ The view count was FABRICATED — worse than logged, now removed

Logged in §3.7 as "social metrics". On opening the code it was not a metric at all:

```dart
final v = post.likes * 247 + post.comments * 90 + 503;
```

**A number invented from two real ones and rendered beside them, so it read as
measured.** 56.4K views on a post with 210 likes was arithmetic, not observation.

On a product whose position is that a number on screen can be checked, this is not a
cosmetic flourish — it is the single thing we say we do not do.

**Removed 2026-08-14, and deliberately NOT commented out for revert.** The repo's
*comment out, never delete* rule exists so a superseded **design** can return. This was
not a design, and leaving it in the file is an invitation to un-comment it.

### 3.7 Social metrics in Community

Posts carry comments, reposts, likes, **view counts (56.4K, 49.9K, 24.6K)**, bookmark and
share. This sits awkwardly beside the "no scores, no streaks, nothing waiting to be
cleared" principle, and against the explicit "no social metrics" decision taken for
PP Watch. Worth a deliberate call rather than drift.

### 3.8 Two promotional units stacked above the fold

A sponsored brand card (Cetaphil, correctly disclosed as *"Presented by Cetaphil"*) and a
referral banner (*"Invite her and you both get 1 free consultation"*) run back-to-back
above the main content. Individually defensible; consecutively they read as a pitch
before the product has given anything.

---

## 4. What is genuinely good and must survive the revamp

1. ⭐ **"ALSO TODAY — Still here, just not first today."** In the Focus view, demoted
   items appear as chips under that line. This solves `CLAUDE.md`'s *a feature is never
   hidden* in one sentence, and it is exactly the mechanism the revamp needs for
   prioritising without deleting. **The single best idea in the app.**
2. ⭐ **Expert-verified community.** Posts carry `Verified by Dr. Meera +240 experts`,
   `Awaiting expert verification`, and an `Experts only` filter. This directly answers
   the trust deficit the competitor reviews expose, and **no competitor examined has it.**
   A stronger differentiator than anything in the previous website work.
3. **The writing.** *"Two hundred and eighty days ago, this little one was barely a
   whisper of a hope."* Better than any copy on the eight reference websites.
4. **Honest commercial disclosure** — an `Affiliate` badge on product imagery,
   *"Presented by Himalaya"* on Prepare, *"Presented by Cetaphil"* on the launch card.
5. **The clinical invariant is visible** — *"Supportive, never clinical — always check
   with your [doctor]"* anchored at the foot of the Tools hub.
6. **Calm empty states in Father Mode** — *"Nothing due right now — you're both up to
   date."* Complete, not a prompt to do something.
7. **Ask Veda's stage-aware suggestions** — current stage first, later stages shown but
   labelled *"As your journey grows."* Honest about time.
8. **A real dismissal** — the Tools personalisation strip offers **"Not now"**, which is
   a genuine decline rather than a delay. Aligned with *nobody is chasing you*.
9. **The V1/V2 mechanism already exists** as `Classic | Focus`. The revamp does not need
   to build it.

---

## 5. Consequences for the revamp

| Ref | Consequence |
|---|---|
| **R03** (centre button) | The nav pill **re-flows when the active tab changes** — the active item expands and the others shift. Verified: "Today" sits at x≈188 when active and x≈120 when not. With a fixed differentiated centre button this gets harder, not easier. **The centre button must be positionally fixed regardless of active state**, or targets move under the user's thumb. |
| **R04** (Products in slot 2) | Current nav is `Today · Prepare · Tools · Calendar · Community` — **no commerce slot at all.** The revamp introduces one at position 2. Given §3.3 and §3.8, this deserves a deliberate decision rather than a default. |
| **R05** (`not a fit` ≠ empty) | Father Mode already demonstrates the good version: *"Nothing due right now — you're both up to date."* — a complete sentence, not an empty shell. That is the pattern to encode. |
| **R01** (child-facing stage 4) | Nothing in the current app speaks to a child. Father Mode proves the codebase can carry a genuinely separate visual system cleanly, which is encouraging for Stage 4 — but it is a second system to design, not a variation. |
| **New** | The Tools hub is already a de-facto "More" grid (~24 tiles, 2 columns). It is the closest existing thing to the CRED-style More screen the revamp specifies, and it currently fails on icon-colour discipline and redundant labels. |

---

## 5a. The other two stages — and the real ranking

### ⚠️ Three stages, three completely different bottom navs

| Stage | Bottom nav |
|---|---|
| Trying to conceive | `Today · Prepare · Tools · Calendar · Community` |
| Pregnancy | `Today · Prepare · Tools · Calendar · Community` |
| **Parenting** | **`My Child · Brain · Tools · Community · Products`** |

Parenting already carries a **Products** slot (position 5), which the other two do not,
and its first two slots are entirely different words. **A user moving from pregnancy to
parenting has to re-learn the nav at the exact moment a newborn arrives.** The revamp's
unified five-slot pattern fixes this, and that is a stronger argument for it than
aesthetics.

Note also that the revamp puts Products at **slot 2**, whereas parenting today has it at
**slot 5** — the least prominent position. Relevant to R04.

### Design quality is ranked by stage, and the flagship is the weakest

Best → weakest, mother-facing:

1. **Trying to conceive** — the best surface in the app. Warm near-white ground, coral
   small-caps eyebrows (`YOUR CHAPTER`, `TODAY'S INSIGHT`, `MYTH VS FACT`, `DAILY
   RITUAL`), a violet chapter card with real progress (`Day 15 of 28`), circular line
   icons (`Me · Us · What's next`), a `Her | Him` toggle.
2. **Parenting** — serif headlines throughout, `PHASE 1 OF 20` with a birth→5-years
   timeline, `Developing` / `On track` status pills, small-caps eyebrows.
3. **Pregnancy Prepare** — serif display, warm ground, rose eyebrow.
4. **Pregnancy Today (Classic & Focus)** — lavender card-soup. **The most-used screen in
   the product is its worst-designed surface.**

### ⭐ The writing is the app's strongest asset, consistently

- TTC: *"You are not waiting for your life to start. You are already building the family
  — this is the first part of it."*
- TTC: *"Record a positive test. Whenever it happens, this is where you tell us.
  **Nothing restarts.**"* — the anti-streak philosophy as one line of kindness.
- TTC: *"Not meditation, and not a task list. One small thing for your head, your breath,
  each other, and the day."*
- Parenting: *"Nothing is expected of him yet, and almost nothing should be expected of
  you. These weeks are about feeding, sleeping in fragments, and the two of you learning
  each other."*
- Parenting: *"Surviving, together."*

### More things that already work and must survive

- ⭐ **Price before the pitch, already shipped.** TTC's `TODAY'S PICK — Fertility-friendly
  lubricant · ₹400 – ₹900` is a content row with the price stated up front, not a sales
  unit. Exactly the wedge in W04.
- ⭐ **Named expert + duration, applied consistently** — `12 min · Dr. Ananya Rao`,
  `40s · Dr. Neha Sharma`. Checkability at the point of consumption, which is the trust
  pattern the reviews demand and no competitor supplies.
- **Clinical framing, done well and repeatedly** — *"These are estimates, never
  guarantees. If your cycles change, stop, or you are worried, talk to a doctor."* ·
  *"General guidance for this stage — not advice about your child in particular. Anything
  that worries you is a question for your paediatrician."*

### ⚠️ Entering the parenting stage fires two consecutive interruptions

1. A **full-screen sponsored takeover** — Cetaphil "Calm Balm" premiere, full-bleed in
   **the advertiser's blue**, before any ParentVeda content is visible.
2. Immediately after dismissing it, a **bottom-sheet modal** — "TODAY, IN ONE WATCH".

Both are dismissible and honestly labelled, and the takeover's disclosure is genuinely
good: *"ParentVeda has no stake in it — here is what we think actually matters when you
choose one."* That is the volunteer-the-unflattering-thing pattern, done properly.

**But two modals back-to-back on stage entry is the moment a new parent meets the
parenting product, and the first thing they see is an advertiser's brand colour
full-screen.** A revenue decision, not a defect — but it should be a decision.

---

## 6. Open questions

1. **May the life stage be switched to see TTC and Parenting?** It mutates profile state
   (due date, stage), so not attempted. Alternatively a second test account or a debug
   stage switch.
2. **Is Fraunces actually wired on the mother's Today screen?** It appears on Prepare,
   Community and Father Mode, but Today's display type reads as the geometric sans.
3. **Social metrics in Community** (§3.7) — keep, reduce, or remove?
4. **The two debug tools** (§3.4) — intentional for this build, or a leak?
