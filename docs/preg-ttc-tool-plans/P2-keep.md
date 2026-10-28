# P2: Pregnancy keep tools

## Context
Pregnancy and TTC tools pass (`00-MASTER.md`), family P2, Terminal B. Audit read-only on 2026-10-28; two helpers read the code and the lead checked every Broken and Wrong claim at its file:line. P2 was picked over T3/T4/T5 because Terminal A held the T3/T4 files and Pregnancy goes first (M2). A's week fix (fe1a831) and Tools-tab order (2eb7a77) are both committed, so nothing here waits.

| # | Tool | Surface | Screen |
|---|---|---|---|
| 1 | Journal | `journal` | `journal/pv_journal_screen.dart`, `services/journal_store.dart` |
| 2 | Garbh journal | Garbh door "My Journal" tab | `garbh_journal_screen.dart`, `GarbhJournalStore` (`data/garbh_rebuild_data.dart`) |
| 3 | Spiritual reading | `tools/spiritual_reading` | `tools/spiritual_reading_screen.dart` |
| 4 | Birth plan | `birth_plan` | `pregnancy/birth_plan_screen.dart`, `services/birth_plan_store.dart` |
| 5 | Baby names | `kReadySurfaceNames` | `BabyNamingHomeScreen` (the master's "Name finder"; `NameFinderScreen` is the retired V1 and nothing live opens it) |
| 6 | Bump | `tools/bump` | `belly_skin/bump_ritual_screen.dart`, `bump_book_screen.dart` (`bump_journey_screen.dart` is retired) |
| 7 | Garbh Sanskar row (M7) | `garbh_daily` | the Garbh door |

## Out of scope, said plainly
- **Twins in Baby names** (O3): one chosen name per person until the app models multiples. Parked in STILL-OPEN.
- **Door files** go to Terminal A (list at the end): the "The name finder" tile name, the stale "names tool not here yet" header, and the Labour / Getting ready doors still offering the birth plan and names after a loss.
- `ToolsHubScreenClassic` (hub:484-760) is never opened; its rows are not ways in and are not touched.
- Printed bump books: no commerce exists, so the "Notify me" promise is removed, not built.

## Audit (verified)
| # | Finding | Sev | Where |
|---|---|---|---|
| G1 | A Garbh letter can never be read: two lines, no tap without audio | Broken | `garbh_journal_screen.dart:555-565` |
| J1 | After a loss the Journal still says "Dear little one," / "N weeks until you meet" and adds baby milestones | Wrong | `pv_journal_screen.dart:656, 697`; `journal_store.dart:502` |
| U1 | After a loss Bump still says "By week 40… to show your child" and lists moments ahead | Wrong | `bump_ritual_screen.dart:226, 332` |
| G2 | A letter's week is copied from the newest entry (1 when empty) | Wrong | `garbh_journal_screen.dart:447-450` |
| J2 | Journal delete is silent, no Undo, files go at once | Wrong | `pv_journal_screen.dart:1211` |
| U2 | "Order print" promises a notification that nothing records | Wrong | `bump_book_screen.dart:790` |
| S1 | Spiritual reading opens a private reader (one-reader rule) | Wrong | `spiritual_reading_screen.dart:93, 497` |
| S2 | "Short readings to hear, or to read aloud": there is no audio | Wrong | `tools_hub_screen.dart:288` |
| N1 | Baby names is not a Tools row (C1) | Wrong | — |
| W1 | Silent saves: Journal compose, Garbh "Keep it", Bump photo add (also copies into her Journal unsaid), caption, Bump delete, Birth plan "Start again" | Weak | as listed in the session audit |
| W2 | Birth plan on `PvDoorToolScaffold`, not the shared tool look | Weak | `birth_plan_screen.dart:109` |
| W3 | Partner: Bump reachable through search, You and Ask Veda links though the hub hides it; he gets his own empty birth plan | Weak | `global_search.dart:104`; `pv_you_content.dart:533`; `pv_veda_links.dart:192` |
| W4 | Baby names: a chosen name is not offered at the birth sheet; the list heart cannot unlike; pushes carry no route name | Weak | `pv_you_sheets.dart:68`; `name_list_screen.dart:347`; `baby_naming_home_screen.dart:37` |
| W5 | Ask Veda's "garbh sanskar" / "mantra" words open Spiritual reading | Weak | `pv_veda_links.dart:198` |
| W6 | Tests missing: column contracts for `garbh_journal_entries` and `bump_photos`, birth plan cloud round-trip, hub reachability per row | Weak | — |
| W7 | The Garbh Sanskar row is blocked by `preg_tools_shell_test.dart:43` | Blocker | — |

## Decisions
| # | Question | Recommended | User's answer |
|---|---|---|---|
| D1 | Two journals, both "My Journal" | (c) one journal to look in: Journal also reads Garbh entries; no data moved | **(c)** (2026-10-28, "if analysed well, I don't mind") |
| D2 | Spiritual reading: tool or reading (M6) | Keep on Tools as a second named exception; one reader; honest line | **(a)** (2026-10-28) |
| O1 | Birth plan in the doctor-visit summary | "Birth preferences" section behind the once-only consent ask | **(a)** (2026-10-28) |
| O2 | Partner and the birth plan | He sees her plan read-only (partner-read policy, backend) | **(a)** (2026-10-28) |
| O3 | Twins in Baby names | Park until multiples are modelled | **(a)** (2026-10-28) |
| D4 | Journal's warm paper ground | Keep as a written keepsake exception | **(a)** (2026-10-28) |
| — | After a loss | Already decided 10-27: tools stay, baby wording drops | rule applied |
| — | Garbh row when the door is missing | pvToast (no silent tap), never the retired pillar menu | rule applied |
| — | Where Baby names sits | Get ready (master:72) | rule applied |

### D1 (c), how it works
- `JournalStore.timeline` already merges four sources (hers, partner, auto milestones, auto health), each scoped by `PregnancyRecords.inCurrent`. Garbh entries become a fifth source with the same scope, mapped read-through to `JournalEntry` with a `fromGarbh` mark.
- Her voice, family voices, letters and photos show one by one. "What your baby heard" (one row per finished daily listen, `garbh_shravan_surfaces.dart:100`) folds to **one line per week**, so it cannot flood the timeline.
- Opening or deleting a Garbh entry from the Journal goes through `GarbhJournalStore` (its tested Undo). The Journal never writes Garbh data: no synced audio is rewritten.
- Trade-off: the Journal now depends on a second store's shape. A test pins the mapping.

### O2, the backend shape
Her plan is a row in `user_state` (`store_key = 'birth_plan'`, merged by `pv_state_merge`). `user_state` holds every store she has, so a partner policy on the table would share everything. Migration **0118** adds a select policy narrowed by row: `user_id = my_partner_id() and store_key = 'birth_plan'`. The partner's screen reads her row read-only; he never writes it. BACKEND-PATTERNS gets "share one row of a key-value table, not the table".

## Build, in waves (each ends green)
1. **Fixes and saves:** G1 letter opens; G2 week from the controller; J2 delete with Undo (files after Undo passes); every W1 save says what it changed; U2 promise removed; Birth plan "Start again" Undo.
2. **After a loss:** Journal cover, countdown, size lines and milestones; Bump intro, week clock and "ahead" (album stays).
3. **One journal (D1):** the fifth source, weekly "heard" line, Garbh entry tap/delete through its store.
4. **Rows and look:** Baby names row (Get ready), Garbh Sanskar row (shell test allows the one named exception), Spiritual reading on the one reader with an honest line, Birth plan on `PregToolScaffold`, names unified (Baby names, My bump journey), route names, list heart toggles, partner guards on Bump links, Ask Veda words to the Garbh door, birth sheet offers her chosen name.
5. **Birth plan out (O1, O2):** doctor summary section behind the consent ask; migration 0118 + the partner's read-only view.
6. **Tests:** contracts for `garbh_journal_entries` and `bump_photos`, birth plan round-trip, the journal mapping, hub reachability for the new rows, the 0118 policy text.

## Hand-over list for Terminal A
1. Getting ready door tile "The name finder" → "Baby names" (`pv_door_getting_ready.dart:150`), and its stale header (:34-37).
2. After a loss, the Labour door's birth plan and the Getting ready names tab still offer (`pv_door_router.dart:387, 496`).

## Verification
`flutter analyze` on touched files; `test/preg_*`, journal, garbh, bump, birth plan, Parenting names tests (`pp_other_tools_test.dart`) and the new tests; wiring grep on every new reader and row. Phone walk on the user's word.

## As built (2026-10-28)
All six waves, one session, after the user's "(a), start now".

**Wave 1, fixes and saves**
- G1: a letter opens whole in a sheet (`_readLetter`, `garbh_journal_screen.dart`); the row is a button for letters only.
- G2: a letter files under her live week (`PregnancyController.current`, dated and 1-42); the old "newest entry's week" stays only as the after-birth fallback.
- G3, J3, U3, U4: toasts on Garbh "Keep it", Journal compose (new and edit), Bump photo add ("Added to week N, and to your journal."), caption save, Bump delete.
- J2: Journal delete offers Undo. `JournalStore.deleteEntry(keepFiles:)`, `discardFiles`, `restoreEntry` (clears the tombstone first, so the next sync does not delete it again). The files go only once the Undo has passed, the `garbhDeleteJournalEntry` order.
- **Bump delete has no Undo, on purpose:** the cloud removes the Storage file once it confirms, so an Undo would need a re-upload. The confirm already says "This can't be undone."
- U2: the print sheet keeps the hardcover plan and drops "we will let you know"; the button is "Got it", and points to Download PDF.
- Birth plan "Start again": `BirthPlanStore.snapshot()` / `restore()`, toast with Undo.

**Wave 2, after a loss** (the user's 10-27 rule)
- One helper, `pregnancyEndWeek(controller)` in `pregnancy_ended_store.dart`, so the Journal and Bump stop at the same week.
- Journal: cover reads "What I kept, / Here whenever I want it."; the week strip shows "Your weeks" with no countdown; the weekly question card (written to a growing baby) steps aside; no baby-size line on week heads; milestones stop at the end date.
- Bump: the week clock stops at the week it ended; intro "Every photo you kept stays here, in your book."; no "Still ahead"; no add-this-week prompt. The album stays whole.

**Wave 3, one journal (D1 c)**
- `JournalEntry.fromGarbh` (transient); `JournalStore.journalFromGarbh()` is the fifth timeline source. Voices and letters one by one; "heard" folds to one row per week. The screen listens to `GarbhJournalStore`; a Garbh row opens `GarbhJournalScreen` (its own play, read and Undo). Eyebrow "FROM GARBH SANSKAR".

**Wave 4, rows and look**
- Tools: **Baby names** (Get ready) and **Garbh Sanskar** (Keep, M7; steps aside after a loss with Get ready, R3; a toast if the door cannot be built). `preg_tools_shell_test.dart` now allows the one named exception and pins both rows.
- Spiritual reading opens in `PvReaderScreen` through `pvReadFromSpiritual` (`read_adapters.dart`); the Interested / Not interested marks ride as `PvSpiritualPrefsBlock` and now toast. The private reader is kept, commented, for revert. Line: "Short readings from six faiths, for a quiet moment".
- Birth plan on `PregToolScaffold`, eyebrow "Get ready".
- Ask Veda links: `pvVedaToolStepsAside` keeps the hub's two rules (Bump hers in the partner preview; Get ready after a loss) and says why. Spiritual reading's keywords lose "garbh sanskar" and "mantra" (**takes effect at the next corpus export and ingest**).
- You: Journal and Bump rows toast instead of a silent tap when no pregnancy is loaded; Bump is hers in the partner preview.
- Baby names list heart uses `ppToggleNameLike` (unlikes, with Undo). "My bump journey" is one spelling.
- **N6 closed, no change:** the Ask button finds the stage from the root route in the stack, so unnamed pages inside Baby names do not break it.

**Wave 5, the birth plan goes out**
- O1: consent kind `PpUseKind.pregBirthPlan`; the ask card on the plan once it has answers; "Birth preferences" in the doctor-visit summary, the plan's own text after the title.
- O2: migration **0118** (the user runs it) adds one SELECT policy, `store_key = 'birth_plan' and user_id = my_partner_id()`. `SupabaseRepo.loadPartnerState`, `BirthPlanStore.partnerPlan()` (unwraps the merged book, skips removed items), `summaryFrom` shared by both phones. On his phone (`PartnerSide.following`, or the dev preview) the screen is "Her birth plan", read-only, with share, and four honest states: loading, not started, not linked, could not load (with Try again).

**Wave 6, tests:** `test/p2_keep_test.dart` (15): the Garbh mapping and the weekly fold, the Journal never writing Garbh data, plan Undo, one wording on both phones, O1 consent wiring, the 0118 policy text (select only, one key), the `bump_photos` and `garbh_journal_entries` column contracts, and the wiring of every fix.

**Not done, and why**
- **N4, her chosen name offered at the birth sheet:** `lib/screens/profile/pv_you_sheets.dart` is held by another terminal. Owed; build after its commit.
- `global_search.dart` still lists Bump for the partner and opens the retired `GarbhScreen`. It is reached only from the classic home (`HomeScreenB`), so it is left as is and noted.
- Twins in Baby names: parked (O3), STILL-OPEN line in the ready text.
- `JournalScreenClassic` (`journal_screen.dart`) also reads `timeline()`, so it now shows Garbh rows too; it is the revert screen and not opened.
