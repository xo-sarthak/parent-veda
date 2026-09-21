# The pregnancy home, above the fold — research and plan (2026-09-21)

**Status: PLAN, not built.** The user asked for research first ("do your
research well, formulate a plan that is very much executable, then start").
Nothing in `lib/` has changed for this yet.

**The ask, in his words.** The TTC home's first screen — date strip, the
day's hero line, *My daily insights* as a rail of cards, then *Start
anywhere* — is the shape every stage should open with, "especially the hero
section". The pregnancy home's hero "is just one image"; elevate it to the
same shape, then the same goes on Parenting. Pregnancy has a complication
the other two do not: a different baby image every week and a "your baby
is the size of a …" comparison, which competitor apps show with a
**toggle** (fruit / other) and a **horizontal swipe with the dates on top**.
"That section needs to be tackled really well."

---

## 1. What the library shows (Mobbin, 2026-09-21)

Queries: `search_screens` "pregnancy tracker home week baby size fruit
comparison hero"; `search_flows` "pregnancy mode home week change baby
development"; "baby size this week toggle fruit vegetable animal". In the
library: **Flo** (the reference; a 17-screen pregnancy-mode flow), **Clue**,
**Stardust**, **Oura**. NOT in the library: Pregnancy+, What to Expect,
BabyCenter, Ovia, Glow — described from knowledge below, marked as such.

### Flo — pregnancy mode home (in library)
- **Top:** month + calendar icon; a **day strip** (S M T W T F S with dates,
  today ringed, dots on days with logs).
- **Hero:** one big tinted **disc** with the week's baby art inside,
  "**2 weeks** ⓘ" over it, a **"Details"** pill at its foot. Steps count
  under. No name, no long text.
- **Then:** "**My daily insights**" — a rail of cards: *Log your symptoms*
  (a + card), *Your baby's growth diary*, *The first weeks of pregnancy* …
  each an illustrated card, tap → a read.
- **Details** → a **full-bleed 3D baby**, a **week chip strip** across the
  bottom (… 40 weeks · 41 weeks · **42 weeks**, scrollable), and a sheet:
  "What happens at 42 weeks", *Reviewed by Dr …*, then the **baby and a
  watermelon side by side** with *Length · Weight · Size: equivalent to a
  watermelon*, prose, references.

### Clue — pregnancy mode (in library)
"Your first trimester / **2 weeks**" with **‹ ›** arrows, the week's date
range under, a circular illustration, one line "*Your embryo is the size of
powdered sugar*", then "Your weekly insight" (prose with citations).

### Stardust (in library)
Date, "**9 weeks, 2 days**", cosmic art; "Daily forecast — For you / For
baby" as two text blocks; symptoms as icon bubbles.

### Oura (in library)
A *Pregnancy Insights* card on the home (trimester); inside, Yesterday /
Today tabs, trimester + due date tiles, "Keeping track" prose, resources.

### Not in the library (from knowledge — verify by eye before copying)
- **Pregnancy+ (Philips):** a 3D baby per week; "size" card with a
  **category switch** (fruit · animal · sweets · toys); week picker as a
  horizontal number strip; swiping the baby image changes the week.
- **What to Expect:** week hero with an illustration; "Your baby is as big
  as a …" with a **fruit / animal toggle**; the week is a strip of numbers.
- **BabyCenter:** "My baby this week" card, fruit comparison, a week strip.

### What converges
1. **A day strip on top, a week as the unit of the hero.** Days are for
   logging and insights; the baby changes by the week.
2. **The hero is the baby, big, with the week on it** — a disc (Flo, Clue)
   or full-bleed (Flo's Details). Little text on it.
3. **"Size of a …" is one line under the hero, and the comparison object
   is shown next to the baby**, not instead of it.
4. **Week navigation lives on the week's own screen, not the home**: Flo's
   home shows *this* week and a Details pill; the chip strip and the swipe
   are on the Details screen. Clue puts ‹ › on the home, but Clue's home IS
   the week screen.
5. **Daily insights = a rail of tappable cards directly under the hero**,
   the first being an action ("Log your symptoms").

---

## 2. What we have

**TTC home (`lib/screens/ttc/ttc_home_v3.dart`)** — the shape he wants:
`V3HeroField` (tinted ground) → `_CycleHeader` (date strip with a
selectable day, the hero line, the cycle ring) → sheet → *My daily
insights · <day>* → `_InsightRail` (112pt cards from
`ttc_daily_insights.dart`: the set changes by day — cycle day, a logged
symptom, a test not taken, a myth, a nutrition need, a movement, a product)
→ *Start anywhere* 4-column door grid.

**Pregnancy home (`lib/screens/home_v3_screen.dart` + `V3Hero` in
`v2/v3_sections.dart`)** — a 340pt full-bleed photo (`assets/baby/
week_NN.jpg`, 38 weeks) under a dark scrim; her name + a subtitle line;
avatar/saved chrome; a **WEEK n · DAY d** chip; the week's "learning" line;
tap → `WeeklyCardStackScreen` (the 7-card week, with its own week strip).
Then: scans due · Start anywhere · This Week Explained … **No day strip,
no daily insights, no size comparison, no way to see another week from
the hero.**

**Week data (`lib/data/weekContent.json` → `WeekContent.babySnapshot.size`)**
holds `fruit`, `length`, `weight` per week (4–40). The fruit set is the
Western BabyCenter list — *rutabaga, jicama, spaghetti squash, butternut
squash, sweet potato, winter melon* — words an Indian mother has never
bought. **No comparison images exist.**

---

## 3. The plan

### The one decision the plan rests on
**What is consistent across the three stages is the SKELETON, not the
art.** Day strip → the stage's hero → *My daily insights* → *Start
anywhere*. The hero art is the stage's own: TTC's cycle ring, pregnancy's
baby, parenting's child. That is what Flo does too — cycle mode and
pregnancy mode share a layout and swap the disc. Trying to make the
pregnancy hero *look* like the TTC ring would lose the baby, and the baby
is the reason she opens the app.

### Tier 1 — the fold (consistency)
1. **Day strip** on the pregnancy home, the TTC one lifted into a shared
   widget (`PvDayStrip`): the current week's seven days, today ringed,
   dots on days she logged (symptoms). Tapping a day moves *My daily
   insights* to that day, as on TTC. It sits on the hero's top edge.
2. **The hero = this week's baby**, kept full-bleed (our language; Flo's
   Details is full-bleed too), 340 → the photo with **"Week 14 · Day 3"**
   as the one title line and **one line under it: "Your baby is about the
   size of a peach · 8.7 cm · 43 g"** (from `babySnapshot.size`). Name
   and avatar stay in the chrome row. The long "learning" line moves off
   the hero into the first insight card. A **"This week ›"** pill at the
   hero's foot (Flo's *Details*) opens the week stack.
3. **My daily insights · <day>** rail under the hero — the TTC rail
   generalised (`PvInsightCard`, stage-agnostic; `ttc_daily_insights.dart`
   keeps its own set). The pregnancy set, which changes by day:
   *What is forming this week* (the learning line → the week stack) ·
   *Size of a …* (→ the size sheet, Tier 2) · *A scan due / this week's
   test* (from ScansStore) · *A symptom you logged → what helps* (from the
   symptom log; needs the Symptoms door, else the read) · *Myth vs fact*
   (the week's) · *One thing to eat today* (a need not ticked → Nutrition
   Today) · *Move* · *A read for this week*. Every card opens something
   that exists (the TTC rule).
4. **Start anywhere** unchanged. Scans-due card folds into the insights
   rail (it is an insight); "This Week Explained" stays below.
5. **Parenting** gets the same skeleton in a later pass (day strip → the
   child's hero → insights → doors); this plan builds the shared widgets
   so that pass is data + one hero.

### Tier 2 — "the size of a …", done properly
6. **An Indian comparison set** written per week, three sets: **fruit**
   (guava, mosambi, mango, papaya, jackfruit …), **kitchen** (a rajma bean,
   a lemon, a coconut, a cauliflower, a pumpkin), **sweets** (a peda, a
   laddoo, a jalebi, a modak …). 37 weeks × 3 = 111 entries; the current
   Western list stays as the fallback per entry.
7. **A size sheet** (Flo's Details lower half): the baby photo and the
   comparison object **side by side**, *Length · Weight · Size of a …*,
   the **toggle** (fruit / kitchen / sweets) as our ink segmented chips,
   and the week's "what is forming" prose. Opened from the size line on
   the hero and from the *Size of a …* insight card.
8. **Comparison images**: cut-outs on white, one per entry, picked by eye
   (the store-tiles rule), mirrored to R2 — ~111 photos; OR one
   Higgsfield-rendered set in a single style (the 3D-tile question he
   raised on Nutrition applies here exactly). Recommend photos for fruit
   and kitchen (real, cheap, credible), renders for sweets (Commons has
   almost none).

### Tier 3 — moving between weeks
9. **On the week stack, not the home.** `WeeklyCardStackScreen` already has
   a week strip; it gains the **week chip strip** at the foot (Flo) and the
   hero photo swipes with it. The home shows *this* week only — Flo's
   choice, and the right one: a home that scrolls sideways through 37
   babies fights the door grid under it and the day strip above it.
   The day strip on the home covers "what about yesterday"; the pill
   covers "show me the weeks".
10. **Future weeks stay locked** as they are on the stack (the reveal is
    part of the product); past weeks open.

### Clinical
Length, weight and the comparison are **population averages** by week
("about"); the copy never says *your baby weighs*. `DueDateSource` still
owns the week; a clinic-dated pregnancy shows the clinic's week. No
prediction language on the home.

### Order of work, estimated
| Step | What | Size |
|---|---|---|
| A | `PvDayStrip` + `PvInsightCard` + `PvInsightRail` lifted from TTC (TTC keeps working, pinned by its tests) | half a day |
| B | Pregnancy hero restructured (week line, size line, This week pill); insights set for pregnancy; scans-due folded in | half a day |
| C | Indian comparison sets written (111 entries) + the size sheet with the toggle | half a day + content |
| D | Comparison images picked by eye and mirrored (fruit + kitchen photos; sweets rendered) | a session |
| E | Week chip strip + photo swipe on the week stack | half a day |
| F | Walk on the phone (when it is free), then Parenting takes the skeleton | — |

### Decisions needed from the user
1. **Skeleton-consistent, art per stage** (recommended) — or should the
   three heroes share one art treatment (a disc)?
2. **Week navigation on the week stack, not the home** (recommended) — or
   a swipeable hero on the home as Pregnancy+ does?
3. **Three comparison sets** (fruit · kitchen · sweets) with Indian items —
   or keep one set and fix its Western words?
4. **Images**: photos by eye, renders, or a mix (recommended mix)?
5. **Order**: this before or after the 7-day charts / 3D recipe tiles?
