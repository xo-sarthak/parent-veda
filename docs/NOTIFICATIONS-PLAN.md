# Notifications, Phase 6a: the market's set, sent only when we have it

GLOBAL-CHANGES #12, Phase 6a. Written 2026-10-28, after relevance Batch 7
(475d2c57) filled the date gaps. Status: **COMMITTED 0a38f4dd (2026-10-28) for Pregnancy and TTC.** The user liked the
prototype and said build it, with one note: too few pregnancy messages.

## Out of scope

- **Parenting.** Parked by the user until the end, like every PP relevance item
  (PP 11, PP 16 in `door-relevance/PARENTING-GAP.md`).
- **Server push (Phase 6b):** FCM, an edge function, a campaigns table. Every
  message here is local (`flutter_local_notifications`), computed on the phone.
  6b gets its own plan with costs in USD and INR.
- **Her own reminders** (medicines, appointments, `ReminderStore`): Terminal B's.
  They are never counted against the cap and never moved by it.
- **Clinic treatment alerts** (the trigger shot, 918001/918002): never capped.

## The idea, in one line

Copy what the leading apps send, but **every type carries a "ready" check against
live data, and stays silent until the thing it points to exists.** No course
message without a live course, no product message without a product in the
Store for her week. The day the content lands, the message starts on its own,
with no app release.

## What the market sends (research, 2026-10-28)

Good evidence for Clue, Flo, Natural Cycles, Ovia and Huckleberry. Thin for
BabyCenter, What to Expect and Pregnancy+. Near nothing for the Indian apps
(Healofy, BabyChakra, Mylo, FirstCry Parenting).

| Stage | Type | Who | We have it? |
|---|---|---|---|
| TTC | Period starting soon, a few days ahead | Clue, Flo, Premom | No: only "late" and "came" |
| TTC | Fertile window | Clue, Flo, Ovia | Yes (opens, and now the wait) |
| TTC | Daily "how are you feeling" check-in, on by default | Clue | No |
| TTC | "Your cycle averages changed" | Clue | Part: the cycle report |
| TTC | Test or measure reminder at a time she picks | Natural Cycles, Premom | No |
| Pregnancy | A daily line for her exact day | BabyCenter, Flo, Pregnancy+ | No: weekly only |
| Pregnancy | Weekly baby update | BabyCenter, Pregnancy+ | Yes |
| Pregnancy | Vitamin reminder | Flo | Terminal B's medicine reminders |
| All | Special offers, on their own switch | Flo | No |

**Built the same way everywhere:** a switch per type (Clue adds a time per type),
marketing on a separate switch (Flo), the global off left to the phone.

**Nobody documents a daily cap or quiet hours.** Apps lean on Do Not Disturb.

**What users complain about most:** messages after a loss (we already stop them);
too many, every day (Flo); messages that raise anxiety; no way to pick types; a
message that opens the wrong page.

**Store rules:** Apple guideline 4.5.4: promotional pushes need explicit in-app
opt-in and an in-app opt-out. Google Play: ads must not imitate system
notifications. Android 13+: the runtime notification permission first.

Sources: Clue help centre (reminders), Flo help centre (turning notifications
off), Natural Cycles help (measuring reminders, NC Recovery), Ovia help (after a
loss), Huckleberry (SweetSpot), App Store listings, Mumsnet and Trustpilot
threads, MacRumors on 4.5.4 (2020), Google Play ads policy. Full URL list in the
research hand-back of the 2026-10-28 session.

## The shape (agreed with the user, 2026-10-28)

1. **A ready check on every type.** Each type names what it points to (a read, a
   course, a product, an expert slot) and asks the live store whether it exists
   for her week, phase or round. False means silent, not "coming soon".
2. **Two lanes.**
   - **Care** (dates, her body, her logs, reads): on by default, as today.
   - **Offers and new things** (courses, products, experts): one switch,
     **off until she says yes once**, asked in a calm card, never in onboarding.
     This is also what Apple requires.
3. **A cap of two a day on her phone:** a **morning slot** and an **evening slot**.
   - Care beats offers. A clinical date moment beats the weekly note, which
     beats a daily line, which beats a check-in.
   - What loses its slot still lands in Messages, in the app only. Nothing is
     lost, it just doesn't ring.
   - Her own reminders and clinic alerts are outside the cap.
   - Two is the starting number, because we have little to say yet. Revisit
     after real use.
4. **Never on a loss path,** as now: the Pregnancy store stops the day she tells
   us; TTC holds window messages until her first period after a loss.

## Candidate types (to be confirmed on the prototype)

| Stage | Type | Lane | Slot | Ready when |
|---|---|---|---|---|
| Pregnancy | A line for today (her day of pregnancy) | Care | Morning | A day line exists for that day |
| Pregnancy | How are you feeling? (only if she hasn't checked in) | Care | Evening | Always (the Daily Moment check-in) |
| Pregnancy | A class or course for her week | Offer | Evening | A live, published course matches her week |
| Pregnancy | Something for this week (Store) | Offer | Evening | A Store product's "have it by" week is near |
| Pregnancy | Talk to an expert | Offer | Evening | A bookable expert has a slot |
| TTC | Period starting soon (2 days ahead) | Care | Morning | Reliable history, own cycle |
| TTC | How are you feeling? (if not logged) | Care | Evening | Always |
| TTC | Test reminder at her time | Care | Her time | She logs ovulation tests |
| TTC | Kits for this phase | Offer | Evening | A Store kit for her phase exists |

## Decision record

| Question | Recommended | User's call | Date |
|---|---|---|---|
| Copy the market's set? | Yes, with a ready check per type | Yes: "copy the whole architecture" | 2026-10-28 |
| A type with nothing to point to | Silent until it exists | Yes | 2026-10-28 |
| Care messages default | On | Yes | 2026-10-28 |
| Offers default | Own switch, off until she says yes | Yes | 2026-10-28 |
| Daily cap | One | **Two: morning and evening** | 2026-10-28 |
| Next step | A lock-screen prototype first | Yes | 2026-10-28 |
| Prototype verdict | Build it | "I liked the prototype, execute it"; too few pregnancy messages | 2026-10-28 |
| More pregnancy messages | Use the 7-a-week tips that already exist (`preg_daily_tips.dart`, the home's Today's tip) as the morning line | Taken (the prototype had wrongly marked them as not written) | 2026-10-28 |
| What counts as a real class or expert | Only one published in the admin panel; bundled ones are placeholders (the booking engine already refuses to sell a bundled expert) | Recommended; follows "we cannot notify about a course we don't have" | 2026-10-28 |
| The TTC ovulation-test reminder at her time | Left out: no time to set exists, and her own reminders already cover a time she picks | Recommended | 2026-10-28 |

## Next

1. Prototype (Artifact): a week of her lock screen and Messages at a chosen
   pregnancy week or cycle day, with the cap, the lanes and the ready checks
   visible. The user judges frequency and tone.
   **Published 2026-10-28:** https://claude.ai/artifact/RYy81pzL3FTYvj8hq8vMwM
   (source in the session scratchpad, `notif-week/index.html`). Sample words
   are marked; the dated moments use the app's real copy.
2. Plan the build from the prototype's verdicts: which types, wording, slot
   times, priority order.
3. Build: Pregnancy, then TTC. Tests hold the cap across both stores.

## As built (2026-10-28)

**Pregnancy** (`lib/services/preg_messages_store.dart`, screen `preg_messages_screen.dart`):

| Kind | When | Opens | Ready when |
|---|---|---|---|
| `dayLine` | 8:30 every morning, weeks 4 to 40 | that week's page | always: `kPregDailyTips` has 7 per week |
| `checkIn` | 7:30 pm on odd pregnancy days | Symptoms door, Today | not tonight once she logged (`SymptomStore`), never late |
| `offer` | 7 pm on day 3 and day 6 of her week | the product or the class | `pregOffersForWeek` (`preg_message_offers.dart`) finds something real; off until she says yes |

**TTC** (`lib/ttc/ttc_messages_store.dart`, screen `ttc_messages_screen.dart`):

| Kind | When | Opens | Ready when |
|---|---|---|---|
| `periodSoon` | 9 am, two days before it is due | When to test read | a steady history (`ttcReliableLateAdvice`, the late message's own date) |
| `dayLine` | 8:30 every morning | that phase insight | her own cycle; `ttcInsightsForPhase`, the home's pool |
| `checkIn` | 7:30 pm on odd cycle days | Symptom log | not once she logged today, never late |
| `offer` | 7 pm, 3 days before her window and 2 days before it is due | the kit, class or expert | `ttcOffersFor` (`ttc_message_offers.dart`); off until she says yes |

**The cap:** `pregPhonePlan` and `ttcPhonePlan`, both pure. Per day one slot before 2 pm and one after. Ranks: a dated moment 1, the new week (or the cycle report) 2, the line 3, the check-in 4, an offer 5. TTC treatment messages are always armed, outside the cap. Losers are not armed but are still delivered to Messages at their time.

**Offers:** a card at the top of each Messages screen asks once (Yes, tell me / Not now); the switch "Offers and new things" is the way back. Both answers toast what changed. Stored locally and in the cloud row (`offers`, `offersAsked`).

**Daily kinds leave Messages after 14 days**, so a month of tips never buries the dated moments.

**Never on a loss path:** Pregnancy stops when she tells us (as before); TTC's daily kinds need a cycle start, which is null after a loss until her first period.

**Ids:** Pregnancy 919130 (14), 919150 (14), 919170 (8); TTC 918107, 918130 (14), 918150 (14), 918170 (8). Held unique by `test/notifications_6a_test.dart` (20 tests) and `stage_transitions_test` M37.

**Owed:** clinician read of the new words (BEFORE-LAUNCH); a phone walk on the user's word (an alarm per slot, the offers card, a tap on each kind); Parenting stays parked (built 2026-10-29, below).

## As built: Parenting (2026-10-29, PARENTING-GAP 11)

From the approved prototype (Artifact `8LcSdbkh9LDV32FMVzfqjL`, v3 with the emoji). `lib/services/pp_messages_store.dart`, screen `pp_messages_screen.dart`.

| Kind | When | Opens | Ready when |
|---|---|---|---|
| `tip` | 8:30, one child a day in turn | the child's home, whose tip it is | always: `kAgeTips` by corrected age (`dailyTipFor`, the home's own pick); not on a morning that child's activity speaks; pregnant again, odd days only |
| `offer` | 7 pm Wednesday and Saturday, children in turn; pregnant again, Pregnancy's day 6 | the toy or the class | `ppOffersForAge` (`pp_message_offers.dart`) finds a toy with a REAL age window or a published class with a 0124 window; never one already offered; off until she says yes |

Titles: "Today's tip: <title>", or "Today's tip for Meera: <title>" with two or more children. "For this age: <toy>", or "For Meera now: <toy>"; body "Made for <age label>. See what parents pick, in the Store." (a class: "See what it covers, in Learn.").

**One cap for both stores.** Pregnant again, her messages and her toddler's used to arm separately: Pregnancy held itself to two, Parenting rang everything. Now `familyPhonePlan` (`lib/services/family_phone_plan.dart`) ranks both pending lists on one scale, two a day (before and after 2 pm):

| Rank | Kind |
|---|---|
| 1 | a vaccine visit; a pregnancy dated moment (scans, Tdap, the bag...) |
| 2 | an age; a new stage |
| 3 | Pregnancy's new week |
| 4 | the Monday activity |
| 4.5 | a tip; Pregnancy's day line |
| 5 | the check-in |
| 6 | an offer |

Ties: the earlier time; then, between the stores, Parenting on odd days and Pregnancy on even ones (so the toddler's every-other-day tip wins its morning); then, between two children, the one whose week it is. A loser is not armed but still lands in Messages at its time.

**The design, and the trade-off.** Two pieces: the planner is pure (lists in, winners out, held by tests with no phone), and `FamilyPhone` is the one owner of arming, serialised, reading both stores and handing each its share. Each store still cancels and arms only its own id block, through its own phone interface. The cost: a refresh of either store re-arms both (a few dozen cancel and schedule calls). The alternative, each store arming itself after reading the other's list, is cheaper but races: each arms from the other's stale list, and for a moment both ring the same slot. Pregnancy's own ranks keep their order on the shared scale, so with no child the plan is `pregPhonePlan`'s exactly (tested); with a child, Pregnancy gives up its day 6 offer so the two take turns.

**Offers:** the same card, switch ("Offers and new things") and toasts as Pregnancy; stored locally (`pp_messages_offers`, `pp_messages_offers_asked`) and in the cloud row (`offers`, `offersAsked`). Silent when nothing exists. Toys: a toy with no age window defaults to 0-72 months, so the Store's `fitsNow` is true for every child; only the 136 of 281 with a real window are offered.

**Fixed on the way:** an activity this child already had in the last 7 days is not sent again (a month note filled four Mondays in a row); a phase activity whose intro starts with its title is not doubled ("Explore With Both Hands: Explore With Both Hands gives...", at 5 months).

**Daily kinds leave Messages after 14 days**, as Pregnancy's.

**Ids:** Parenting 929101, 929111, 929121, 929131 (4 each), tip 929140 (14), offer 929160 (8). Held unique by `stage_transitions_test` M37 and `test/pp11_family_messages_test.dart`.

### The phone emoji, all three stages (decided 2026-10-29)

One map, `kPhoneEmoji` in `lib/services/phone_emoji.dart`, one emoji per kind at the END of the title, added only when the phone notification is scheduled. The stored title, the ids and the cloud rows are unchanged, and Messages in the app stays plain. Ages: 🎂 on whole years, 🎉 on the rest, 🎂🎒 on the sixth birthday only. None on the sensitive kinds (a period that came, late, the first check, the two-week wait, clinic treatment, the baby's movements). The one exception to "no decorative emoji", recorded in CLAUDE.md and `docs/CHATGPT-BRIEF.md`. Held by `test/phone_emoji_test.dart`, which also fails when a new kind is added without a decision.

**Owed:** clinician read of the new words (BEFORE-LAUNCH); a phone walk on the user's word (two a day with a toddler and a pregnancy, the offers card, a tap on a tip and an offer, the emoji on the lock screen).
