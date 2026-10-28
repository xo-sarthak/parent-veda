# Parenting (not the doors): relevance gap, what is left

**The working file.** Open items in full, finished ones in one line. The original audit (sections 1 to 3 with their tables) and every finished item's write-up are word for word in **`PARENTING-GAP-DONE.md`**: read it only when a step needs that history. Split 2026-10-29 to keep a new session's reading short.

Siblings: `PREGNANCY-GAP.md`, `TTC-GAP.md`. Plan and seams: `README.md`.

**Out of scope:** the 14 doors (rebuilt in `docs/pp-door-plans/`) and the tools themselves (`docs/pp-tool-plans/`).

---

## 0. Decisions already made

| Question | Decision |
|---|---|
| No child saved | **The child's date of birth is required.** The stand-in child born today is for developer mode only (2026-10-26) |
| Which age drives content for a baby born early | **Corrected age for every development and content choice under 24 months.** Birthday age stays for vaccines, growth and messages, and the screen says which (2026-10-26) |
| Consent | **Not blocking.** `PpUseConsent` covers feeds, nappies, development, foods and changes; any new use of tool data calls `PpUseConsent.allows(kind)` from the start, including anything sent to Ask Veda (2026-10-27) |
| Fever check | Keeps a "see a doctor" answer with her yes; never the reading; no ask under "Go now" (2026-10-28, built in be2bb7ee) |
| Programme ages | In the database (0124, run 2026-10-29); **Directus left out** until it is set up (2026-10-28) |
| Ask Veda repo | **Access granted** (`C:\Projects\parentveda-askveda`) for PP 6 (2026-10-28) |

---

## 1. Still open, in build order

### Step 4
**11. Messages have no situation awareness, no limit, no quiet hours and no offers** (Weak, GLOBAL-CHANGES #12). *Fix:* Phase 6a as built for Pregnancy and TTC in 0a38f4dd (`docs/NOTIFICATIONS-PLAN.md`): two a day at most, quiet hours.
What the audit found (`pp_messages_store.dart:312-403`, as of 395ee74): per real child, "X weeks old" weekly to 8 weeks at 9am, then monthly to 36 months, then quarterly to 72 months; vaccines 3 days before at 10am; new phase at 6pm (corrected age, active child only, `:252`); Monday activity at 10am.

**16. Possible double vaccine reminder** (Polish). The opt-in vaccine alarms (`pp_vaccine_data.dart:893-912`) can repeat the automatic 3-day reminder for the same visit. *Fix:* skip the automatic message when the visit has an opt-in alarm.

**14. Stale comments, half left** (Polish). The vaccines header (`pp_messages_store.dart:50-56`) says vaccines go to the active child only, but the code covers every child (`:229-231`). *Fix:* correct it. (The "OFF BY DEFAULT" half was done in be2bb7ee.)

**15. Stale docs** (Polish). STILL-OPEN:1107 ("tips are not personalised by age"), STILL-OPEN §95.6(3) ("Something changed? is not stored"), GLOBAL-CHANGES #2 (Parenting OWED). All three are done in code. *Fix:* mark them done.

### Found in Step 3c
**21. A child's health conditions are stored per family, not per child** (Weak). Onboarding's conditions (eczema, reflux, a hearing need...) live on `FamilyProfileStore`, so with two children nothing says whose they are. Step 3c sends them to Ask Veda only while one child is saved (`ppAskVedaContext`, held by `test/pp_relevance_step3c_test.dart`, "two children"); the home's extra-support signal has the same blind spot. *Fix (not built):* store conditions on the `Child`, ask whose when a second child is added. Touches `docs/FAMILY-MODEL.md` (the child owns child records), so read that first.

### Not this terminal's
**13.** Tools hides two tools after 12 months: Terminal B's (which rows show); the user is deciding.

---

## 2. Finished (one line each; the write-ups are in `PARENTING-GAP-DONE.md` §4)

| # | What | Commit |
|---|---|---|
| 1 | Today's activities follow the child (one set per child and age) | d27e3988 |
| 10 | No child saved: the home asks for one | d27e3988 |
| 2 | One age (corrected, under 24 months) for tips, reads, products and the Store's fit check. **Except Ask Veda: moved to PP 6** | b3caf0dd |
| 3 | "Useful at this age" shows only what fits | b3caf0dd |
| 5 | The home's products read the Store's catalogue | b3caf0dd |
| 12 | The Brain tab's pick is the home's first | b3caf0dd |
| 17 | Continue reading kept per child | b3caf0dd |
| 7 | One lead action: urgent answer above the rail, a visit within a week, the first activity raised | 60c44850 |
| 18 | Found: a visit card shown for ever | 60c44850 |
| 4 | "Is my baby OK?" answers move activities when one fits, and lift pages into the reads | be2bb7ee |
| 8 | Courses and groups by the child's age; no offer made for another age; migration 0124 | be2bb7ee |
| 9 | A line under the grid when her answers moved a tile | be2bb7ee |
| 19 | Found: change words matched inside other words | be2bb7ee |
| 20 | Found: the home's fever card opened the wrong check | be2bb7ee |
| Fever | Fever check keeps "see a doctor" with her yes, so the home follows up | be2bb7ee |
| 6 | Ask Veda gets the corrected age next to the birthday age, and the family's context as closed ids (never the name or prose: the cache is shared); conditions only with one child; the answer says what it used, from the service's `used_context`. Two repos. Inert until the service is redeployed. The audit's "Pregnancy sends conditions" was wrong: `VedaContext` feeds only the retired offline engine | (pending) |

Tests: `test/pp_relevance_batch1_test.dart`, `pp_relevance_batch2_test.dart`, `pp_relevance_step3a_test.dart`, `pp_relevance_step3b_test.dart`, `pp_relevance_step3c_test.dart`; service: `parentveda-askveda/tests/test_child_context.py`.

## 3. Decisions still yours
- Nothing blocking. The hidden-tools question (13) is with the user via Terminal B.
- When to build PP 21 (conditions per child).
