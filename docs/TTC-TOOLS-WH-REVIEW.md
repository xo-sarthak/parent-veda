# TTC tools: one review per tool (what / why / when / how / who), one tool at a time

Started 2026-09-30 on the user's word: "go tool by tool where I say so." Each card is written from what the screen
actually shows (rendered at 411 wide with the real fonts in its first-visit, part-done, opened-item and summary
states) plus the code, never from the code alone. A fix is only made after the user marks it. Supersedes the
2026-09-26 notes in `TTC-TOOLS-UX-NOTES.md` for the tools reviewed here (those were written before the 2026-09-29
rebuild).

The eight questions: **What** is it, in a plain sentence on the screen? **Why** would she open it and what does it give
back? **When** does she need it, and does the app bring her there? **How:** first tap, time to finish? **Who:** hers, his,
shared; does it ask for what the app knows? **After:** does she see what changed? **Coming back:** a reason to return?
**Words:** one name, short lines, no blob?

Priorities: P1 = fix, small and clearly better; P2 = fix, small; P3 = needs the user's decision.

---

## 1. Pre-pregnancy checklist  (`ttc_precheck_screen.dart`, `ttc_precheck_summary.dart`, data in `lib/ttc/ttc_precheck_*.dart`)

**Verdict: one of the strongest tools. The design is right (ring, next 3 steps, one-tap tick, answers first, a question
for the doctor, a copyable summary that carries what the app knows). The problems are noise, not structure.**

| Question | Finding |
|---|---|
| **What** | Clear: "Things to sort out before trying. Tick what is done. Open any item for why it matters and what to do." **But the title is wrong for someone already trying** (the user's own account is 43 days in). |
| **Why** | Every item has a real why, a what-to-do and a doctor question. The top three steps' one-line reasons are generic ("One of the few items here that applies to almost everyone" says nothing about *this* item). |
| **When** | The app never brings her here: no card on the home, no nudge. Only Tools, the Getting ready door and two journeys reach it. No timing on items (only the vaccine section blurb mentions a month's gap). |
| **How** | One tap on the circle ticks; the rest opens in place: *Where you are* (Done / Need to do / Not sure / Not relevant), why, what to do, the doctor question on its own card, "I talked to my doctor", links to the tool or read that helps. Good. |
| **Who** | Hers only. His side of the checklist (his health, his tests) does not exist here; it belongs to the his-side pass. |
| **After** | The ring moves, a snack with Undo, the steps re-rank. Good. The summary shows "16 Not looked at" in big type, the same debt number the ring was redesigned to avoid. |
| **Coming back** | The next-3 list changes as she ticks. No other reason to return (acceptable for a checklist). |
| **Words** | "Core / Worth doing / Helpful if it applies" on all 21 rows plus a grey key paragraph: 21 tags to say one thing (which are the important ones). |

### What is noisy, in order

1. **Every section carries a "0 of N done" pill, and it lies or reads silly.** Six of the eleven sections hold ONE item, so
   the pill says "0 of 1 done" under a heading and a blurb for a single row. Worse, a section whose items moved up into
   "Your next 3 steps" still says "0 of 3 done" and shows one row plus "2 more in your next 3 steps, above." The ring at the top
   already carries the count.
2. **Tier tags on every row.** Core matters; Worth doing and Helpful if it applies are 15 tags that add little.
3. **Two items say nearly the same thing:** "Supplement review" (in Folic acid and food) and "A review of your medicines"
   (in Medicines and supplements): both are "check what you take with a doctor".
4. **The title assumes she has not started.**
5. **The summary's third tile** ("16 Not looked at") is a debt number.

### Done 2026-09-30 (the user: "do A to E first")

A to E are built and tested (`test/ttc_precheck_review_test.dart`). One judgement in B: the app has no "actively
trying" flag, only how long she has been in the stage (or her own answer, which sets the same start), so the title says
"while you try" from 30 days on (`kPrecheckWhileTryingDays`) and "before trying" before that. The same night the user asked "why is medicine and supplements randomly placed?": the section
"Medicines and supplements" held one item (a medicines review) while "Supplement review" sat under "Folic acid and food",
and the section came third, after the check-up, though its blurb calls it the most important. Fixed: "Supplement review"
moved into it, and the section order is now by urgency (folic acid, medicines, check-up, vaccines, then the rest). That is
a lighter version of F (the two review items stay separate). The user then asked again ("why is it randomly placed", about the HEADING):
on her real data the app ticks folic acid and her cycle record itself, so both medicine items move up into "Your next 3
steps", and the section underneath was left as a heading, a blurb and "Its one item is in your next 3 steps, above." with
no rows. Fixed: a section with no rows of its own is not drawn, and the "N more in your next 3 steps, above." pointer is
gone. G and H wait for the user.

### Missed in the first pass, found by the user (2026-09-30), fixed

**Every opened item asked the same question with the same four answers** ("Where you are: Done / Need to do / Not sure /
Not relevant to me"), which fits Folic acid and makes no sense on "Tobacco" or "Your reproductive history". The review had
rendered ONE opened item and called the interaction good. Now each of the 23 items asks its own question and its four
answers say what they mean for that item (`kPrecheckAsks` in `ttc_precheck_data.dart`), while still storing the same four
statuses, so the ring, the next 3 steps, the folds and the doctor notes are unchanged. A test holds that no item falls back
to the generic question. **Lesson for every later card: check the control on EVERY item or variant, not one sample.**

### Proposed fixes

| # | Change | Size | Priority |
|---|---|---|---|
| A | Remove the per-section "N of M done" pills (the ring is the count). Keep the "N more in your next 3 steps, above." note. | tiny | **P1** |
| B | Title by where she is: "Things to sort out before trying" until she has started; "Things to sort out while you try" once she has (derived from the journey start, never asked). | small | **P1** |
| C | Show the tier tag only for **Core**; shorten the key to one line ("Core: most people should do this."). | small | P2 |
| D | Summary: drop the "Not looked at" tile (two tiles: Covered, Worth checking). | tiny | P2 |
| E | The next-3 reason lines say something about that item (its own "why", shortened) instead of a tier sentence. | small, copy | P2 |
| F | Merge "Supplement review" into "A review of your medicines" (one item, "What you take"), folic acid stays its own. **Content and clinical-register change.** | medium | P3, the user decides |
| G | Merge the six one-item sections into fewer groups (for example Medicines + Vaccines + Health check-up + Teeth into "Doctor visits and medicines"). Touches `openSection` deep links and tests. | medium | P3, the user decides |
| H | A home nudge ("Your next step: folic acid") for someone who has never opened it. Belongs with the home pass. | small | P3, later |

Nothing in this tool produces a readiness score, and none of the fixes may add one (`ttc_precheck_rules.dart` header).

---

## Card 1, "what does she get back" (2026-10-01, the user chose all five, hers only, nothing for his side)

The checklist only collected. Now its answers come back, in five places:

| # | What | Where it lives | State |
|---|---|---|---|
| 1 | **Home nudge**: a rail card "YOUR NEXT STEP", the checklist's first open step, opens the checklist. Gone when nothing that matters is left, and on a clinic round. | `lib/ttc/ttc_precheck_home.dart`, rail in `ttc_home_v3.dart` | built, tested (this also closes H) |
| 2 | **Into the doctor visit**: "Add my questions to my next visit" puts her questions on the next visit in Appointments (never twice); the Records PDF "for an appointment" gains a "My checklist notes" section. | `lib/ttc/ttc_precheck_notes.dart`, `ttc_precheck_summary.dart`, `ttc_records_pdf.dart` | built, tested |
| 3 | **Ask Veda is told** what she has covered and flagged (ids only, her device only). | `ask_veda_service.dart`, `ttc_askveda_screen.dart` | **app half only. Inert until the service half lands: `docs/ASKVEDA-CHECKLIST-HANDOVER.md`** |
| 4 | **Cloud copy**, hers only. One blob in `user_state` (own-row), merged per item. No migration. | `ttc_precheck_store.dart`, BACKEND-PATTERNS 16u | built, tested |
| 5 | **Since you were last here**: "N more settled since 24 Sep" on the ring card, her own ticks only, after a visit on another day. | `ttc_precheck_store.dart`, `ttc_precheck_screen.dart` | built, tested |

Tests: `test/ttc_precheck_home_test.dart`. Nothing here adds a readiness score, and none of it is on his side.
