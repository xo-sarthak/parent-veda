# Parenting tools: master plan, one tool at a time

## Context
The parenting stage has 36 tools: trackers, checks, look-ups and players. They are reached from the Tools tab (`lib/screens/post_pregnancy/pp_tools_tab.dart`) and from door tool rows (`lib/data/doors/pp_door_*.dart`), and every one opens through `ppScreenForSurface` in `lib/screens/post_pregnancy/pp_surface_router.dart`. The user wants every tool to be relevant and to work fully, in both frontend and backend, with good UX. Whatever a tool learns should be used elsewhere in the app where it helps, but only after asking the parent.
The user also wants this done **token-efficiently: one tool at a time, never all at once.** So this master plan sets up the method and the order. Each tool then gets its own audit, its own plan, the user's go, and its build, before the next tool starts. It follows the same pattern as the door pass (`docs/pp-door-plans/`).

## Decisions (user, 2026-10-24)
| Question | Recommended | User's answer |
|---|---|---|
| How does the app ask before using what a tool learned? | Ask once per kind | **Ask once per kind.** A small card asks "Use this to suggest pages and reminders?" with Yes / Not now. The answer is remembered for that kind of info, and the parent can change it in You. |
| First tool | Log a feed | **Log a feed** |

## Where it lives
- `docs/pp-tool-plans/README.md`: the index. One row per tool showing status (audit / plan / waiting / approved / built / committed) and the commit.
- `docs/pp-tool-plans/00-MASTER.md`: this checklist, the order and the shared pieces.
- `docs/pp-tool-plans/NN-<tool>.md`: one plan per tool, written only when that tool's turn comes.
(These are new files. They do not touch the files another terminal is working on.)

## The audit checklist (run against each tool in turn)
Every finding gets a severity: **Broken**, **Wrong**, **Weak** or **Polish**.
1. **Reachable.** Grep every way in: the Tools tab, door rows, PpLinks in pages, search and home. Does the label match where the tap lands? Is there any silent tap (S8)? Do names get cut off?
2. **Relevant.** Does it fit the child's age band? Is it hidden or still offered when the child has outgrown it? Does it use the active child (multi-child)? Does it follow the dad or co-parent view?
3. **Works (frontend).** Walk the code path: empty, first-use, normal, edit, delete and undo. Check the validation, the units, the timezone at midnight, and the back button mid-entry. Every save should say what it changed (the "app must explain itself" rule).
4. **UX.** How many taps for the most common action (a log should be one or two)? What does the first view show? Does it meet house look (white ground, ink pills, line marks, no lavender) and the calm-tone rule? Is there a Mobbin reference for this pattern?
5. **Backend.** Find its store (singleton `ChangeNotifier`). Is it local-first, with app-generated ids? Does it sync per item through `supabase_repo.dart`? Is it in the per-child key? Does a contract test pin its columns? Does logging out keep it, and does an uninitialised backend behave like logged out?
6. **Uses what it learned (with consent).** What does this tool produce that another part of the app could use: relevance ranking (`pp_relevance.dart`), reminders (`NotificationService`), the doctor-visit summary, the home Today strip, Ask Veda context? Which uses are already wired, and which are missing? Anything new goes through the consent seam (T0) below.
7. **Clinical.** It must never diagnose and never give a personalised probability. Red flags route calmly to a doctor, with a disclaimer. Where the doctor owns a decision, the tool explains it and never overrides it.
8. **Tests.** Is there a reachability test, a store round-trip test and a sync contract test? Note what is missing.

## Shared piece T0: the consent seam (built with tool 1, its first user)
- `PpUseConsent.instance`: a singleton `ChangeNotifier`. It holds a map from each kind of info (e.g. `feeds`, `growth`, `foods`, `changes`) to a state: asked-yes, asked-no or not-asked. It is stored in `shared_preferences` and synced as one per-item row per kind (the same step-13 merge as `PpChangesStore`).
- `PpUseAskCard`: the card shown once after the first save of a kind. It is calm, has two buttons and gives a one-line "why".
- A "What ParentVeda uses" row in You, so each answer can be changed later.
- Readers (relevance, reminders, Today) check `PpUseConsent.allows(kind)` before using a tool's data. A "no" changes ordering and reminders only. **No feature is ever hidden.**
- The existing "Something changed?" store already feeds relevance without asking. Its plan decides whether it moves under T0.
- **Trade-off:** one place that owns consent means one rule and one settings row, at the cost of a small new store. The other option is a flag inside each tool, which spreads the same question across 36 stores. The single store wins.

## Order (one at a time; the user says go per tool)
1. **Care logs:** Log a feed → Breastfeed timer → Nappies → Pumping → Sleep → Tummy time → The last 7 days
2. **Health:** Growth → Vaccines → Fever check → Is my baby OK? → Something changed? → Health record → Emergency card → Before you see the doctor → Home remedies
3. **Development:** This month's checklist → Milestones → Gentle check-in → Things to do today / Activities → Your child's phases
4. **Food:** What to feed at this age → Can my baby eat this? → Recipes
5. **You, Maa:** How have you been? (keeps "nothing saved", so it is exempt from T0) → Can I...? → Kegel Care → Yoga & fitness
6. **Other:** What to say (scripts) → Sleep Sounds → Baby names → Product guide → Story books and boxes (shop)

Surface ids are in `pp_surface_router.dart`. Each plan lists its own screen and store files.

## Per-tool loop (token-light)
1. **Audit:** read that tool's screen, store and call sites only. Do at most one Mobbin search, only if the UX changes.
2. **Plan:** write `NN-<tool>.md` with findings by checklist item and severity, the fix list (frontend / backend / uses-with-consent), the decisions asked in plain words (recommendation first, the user's answer recorded with the date), the S8 toasts, and the tests to add.
3. **User's go:** if the UI changes, show an HTML mockup first (light mode).
4. **Build:** extend additively. Comment out superseded code, never delete it. English copy only.
5. **Verify** (below), update the README row, and give the git commands (the user runs git).

## House rules for every tool plan
Use the singleton ChangeNotifier and Navigator. Do not add Riverpod or new packages. Local-first always. Rules stay in code, not the database. No decorative emoji. Commit only our own files. Check `git status` before edits, because other terminals share the tree (for example, Wave 8 owns `pp_relevance.dart`, so hold edits there until it is committed). Any Ask Veda context field is a two-repo change: ask for access to the service repo, or write down what the service still needs.

## Verification (per tool)
- Analyze only the touched files (`flutter analyze <files>`), and run the stage's tests (`flutter test test/pp_*` plus the tool's new tests). The full suite runs only when asked.
- New tests: reachability (the surface id resolves and every way in lands), a store round-trip, and a sync contract for any new columns.
- Wiring gate: grep the call sites of every new reader of consented data.
- A phone walk only on the user's word.

## Next action after approval
Create `docs/pp-tool-plans/README.md` and `00-MASTER.md`, then audit **Log a feed** (`pp_feeding` → `FeedingJourneyScreen`, `lib/screens/post_pregnancy/feeding_journey_screen.dart`) and write `01-log-a-feed.md`, which will include T0.

## Coverage and redundancy check (user ask, 2026-10-24)
User's words: "doors should not cover a new tool that isn't listed in tools section, moreover also see do we have repetitive tools? as in redundancy".

**Rule C1:** every tool a door offers must also be listed in the Tools tab (`pp_tools_tab.dart`). A door may show a tool; it may never be the only way to find it. This rule will be held by a test: every door `surfaceId` must appear in the Tools tab list, apart from a short named allow-list (filtered variants and shop cards).

### Door tools missing from the Tools tab (10)
| Door tool | Surface | Door | Proposed |
|---|---|---|---|
| Fever check | `pp_fever_check` | Health | Add to Tools › Health |
| Before you see the doctor | `pp_doctor_visit` | Health | Add to Tools › Health |
| Home remedies, marked honestly | `pp_nuskhe` | Health, Traditions | Add to Tools › Health |
| What to feed at this age | `pp_food_chart` | Feeding | Add to Tools › Food |
| Things to do together today | `pp_activities` | Development | Add to Tools › Development |
| Your child's phases | `pp_leaps` | Development | Add to Tools › Development |
| What to say | `pp_scripts` | Behaviour | Add to Tools (a new Behaviour group) |
| Sleep Sounds | `pp_sleep_sounds` | Sleep | Add to Tools › Care logs, next to Sleep |
| Story books, crayons and activity boxes | `pp_recos` | Early learning | A shop card, not a tool: allow-list it (it already links from Product guide) |
| Something has changed (behaviour) | `pp_what_changed/behaviour` | Behaviour | The same tool with a filter: allow-list it |

### Repeats and overlaps found
| # | What | Finding | Severity | Settled at |
|---|---|---|---|---|
| R1 | Tools tab "Is my baby OK?" | The blurb says "A symptom, checked calmly", but the screen checks four newborn feeding signs (wet nappies, feeds, yellowness, weight). Its label promises something it doesn't do, and it overlaps the "Is he getting enough?" signs merged into What to feed. | Wrong | Is my baby OK? turn: rename to what it is (e.g. "Getting enough milk?") or merge into What to feed |
| R2 | Fever check vs Something changed › Illness (fever) | Two ways to the same worry, which may give different advice | Weak | Fever check turn: one fever answer, and the other links to it |
| R3 | "Things to do together today" | The label says *today* but opens *all activities by area*. Today's pick lives somewhere else. | Wrong | Activities turn: the label must match where it lands |
| R4 | Health record (`pp_health_home`) | A hub that repeats Growth, Vaccines, Emergency card and Doctor visit as tiles. It doesn't keep separate data (same stores), but the Tools tab lists both the hub and the parts. | Weak | Health record turn: keep it as the one place for records and papers, and drop the repeated tiles or call it a hub |
| R5 | This month's checklist vs Milestones vs Vaccines | Not a repeat: it reads the same `MilestoneStore` and `VaxStore`, and a tick goes to the same store. Keep it. | OK | — |
| R6 | Log a feed vs Breastfeed timer | Feeding journey already opens the timer (`feeding_journey_screen.dart:124`). There are two Tools-tab rows for one flow. | Check | Log a feed turn (now) |
| R7 | Sleep tracker vs `pp_sleep_check` chart | The chart lives inside the reads, not as a tool. Check that it isn't a second sleep tool. | Check | Sleep turn |
| R8 | Same tool on several doors (Last 7 days, Growth, Emergency card twice in Health, Nuskhe) | One surface reached from several doors. That is fine; it is not a repeat. | OK | — |

A finding is settled at that tool's turn, as one plan decision. **C1** (the 8 Tools-tab additions plus the test) is one small build, ready on the user's go.

### C1 built (2026-10-25, on the user's "start with 1, fix that issue")
- 8 rows added to `ppToolGroups()` in `lib/screens/post_pregnancy/pp_tools_tab.dart`. "Things to do together today" is listed as **Activities**, named for where it lands; the door label still waits for R3.
- `test/pp_tools_tab_test.dart` › "every door tool is also in the Tools tab" holds the rule. Proven to bite: with the What to say row removed, it fails naming `parenting_behaviour: pp_scripts`.
- **Found by listing them:** 6 of the 8 never moved onto the shared tool shell (`PregToolScaffold`), the look every other tool wears. The one-look test never saw them while they were door-only. They are named in `_owedShell` in `test/pp_tools_one_look_test.dart` (owed, not exempt; the list can only shrink). Each one moves at its own turn:
  | Tool | Turn |
  |---|---|
  | Sleep Sounds `pp_sleep_sounds` | 30 |
  | Fever check `pp_fever_check` | 10 |
  | Before you see the doctor `pp_doctor_visit` | 15. Also **Broken**: a Row overflows by 44px at 360dp at normal text size (`health_doctor_visit_screen.dart:169`) |
  | Your child's phases `pp_leaps` | 21 |
  | What to say `pp_scripts` | 29 |
  | What to feed at this age `pp_food_chart` | 22 |
- Not a fault: Sleep Sounds arms the shared player's 20-minute sleep timer on arrival, and it is meant to outlive the screen.

### A 34th row, from Papers door 14 (2026-10-26)
- The Papers door offers **Document vault** (`pp_baby_documents`, `BabyDocumentsScreen`; until now only Health home opened it), so C1 put it on the Tools tab, under Plan and keep. Its mark is the drawn form card (`TtcToolMark.pcosCheck`), the nearest drawn object to a paper; the folder is Health record's. Owed art: a folder with a lock.
- **Found by listing it:** it does not wear the tool shell (on `_owedShell`, its own turn when the user says), and its "Add another document" button overflowed by 111px at 360dp and 1.5x (`baby_documents_screen.dart`, a label in a Row with no `Flexible`). The overflow is fixed; the shell is not.
- **Backend:** the store (`BabyDocumentsStore`) was not audited here. The backend-done rule applies at its turn.

### T0 built (2026-10-25, with tool 01)
`PpUseConsent` (`lib/services/pp_use_consent.dart`), `PpUseAskCard` (`lib/screens/post_pregnancy/pp_use_ask_card.dart`) and the "What ParentVeda uses" section in You › Data and privacy. First kind: `feeds`. Each later tool adds its kind to `PpUseKind` (with a `label` and a `why`), shows the card on its own screen after the first save, and gates every reader with `allows(kind)`. Answers stay on this phone until consent sync is approved.

### Backend done rule (the user, 2026-10-25)
"Whenever you are completing a tool make sure the back ends are working well." A tool is not done until: its store is child-scoped on read and write, every write syncs (ledger or merged store) with a test, any new consent kind syncs through `PpUseConsent`, and the backend docs (BACKEND-PATTERNS when there's a new pattern, sync log + STILL-OPEN-BACKEND when sync changes) are written in the same change.

### Repeats settled in the Health family (2026-10-25)
- **R1** settled: "Is my baby OK?" is the one symptom tool for every age (the user: "shouldnt it be a whole symptom tool"); the newborn feeding check is "Getting enough milk?" inside it.
- **R2** settled: one fever answer. Fever in the symptom tool hands over to Fever check.
- **R4** settled: Health record stays as the records home, with live status rows.
- **R3** (Activities label) waits for the Development family.

### Settled in the Development family (2026-10-25)
- **R3** settled: everything that opens every activity is named for it ("Activities for this age"); the links that looped back to the door open Activities; area links open on their area (`pp_activities/<area>`).
- **Phases are not a tool** (D4, the user: "why do we need to include phases screens for tools?"). `pp_leaps` is reading in the shared reader; it left the Tools tab, and C1 allows it by name.
- **One drawn mark per Tools row** (the user: "make sure the tools section the UI is consistent with marks/glyphs"). Every `PpTool` names its own `tab:`/`tool:` mark, none shared and none falling back to an icon; `test/pp_tools_tab_test.dart` holds it. Later tools keep to it: a new row picks a mark no other row wears.
- New consent kind `development` (milestones and check-in answers, for the doctor visit).

