# T1: the TTC doctor check (TT1, TT2, TC3, TC5)

## Out of scope
- **Terminal A (relevance):** the home check card's *placement*, door order, notifications' timing rules. T1 changes only the number those read (`TtcStore.tryingTime`), not where or when they show.
- **The Ask Veda service:** `months_trying` keeps its name and shape (now rounded like everywhere else), so there is no two-repo change.
- **Kept as it was, on purpose:** `ttcStartFromAnswer` reads her onboarding answer at its LOW end (`ttc_store.dart`, "nothing ever says she has tried longer than she told us"). The audit found onboarding uses the middle of the band; aligning them is a separate decision, not taken here.

## Audit (read-only, 2026-10-27, every claim checked at file:line)
| # | Finding | Severity | Where |
|---|---|---|---|
| A1 | After a loss the count kept her old start, so the months she was pregnant counted as trying | Wrong, clinical | `stage_moves.dart:143-158`, `ttc_store.dart:247` |
| A2 | The live result comes from `ivfBuildReadiness`, not the rules engine. One "A previous miscarriage" tick gave `IvfVerdict.flagged` with a broken sentence ("because a previous miscarriage") | Wrong, clinical | `ttc_ivf_readiness.dart:378-383` |
| A3 | The two-loss rule could never fire: nothing on the live path wrote `miscarriages`; recorded losses (`PregnancyRecords`) were never read | Wrong, clinical | `ttc_fertility_help_store.dart:234`, `ttc_ivf_readiness.dart:193` |
| A4 | Not one number: messages and the home check card counted calendar months from the start; Ask Veda floored days/30; You showed the onboarding answer; the checklist notes did days/30 | Wrong | `ttc_messages_store.dart:526-537`, `ttc_askveda_screen.dart:164`, `pv_you_content.dart:859-898`, `ttc_precheck_summary.dart:394` |
| A5 | His phone never read her start, only her chapter | Wrong | `ttc_store.dart:434-439` |
| A6 | The push sent `_journeyStart ?? enteredAt` and the pull wrote it back as her stated start, so after one sync her onboarding answer stopped counting | Wrong | `ttc_store.dart:446`, `:423` |
| A7 | Trying again from the family side kept the old start (the intro no longer asks "how long") | Wrong | `ttc_intro_flow.dart:254`, `stage_moves.dart:345` |
| A8 | The 12-month trigger said "under 36", the rule fires under 35 | Wrong (label) | `ttc_fertility_help_rules.dart:400` |
| A9 | The reasons read "because pcos" (labels lowercased) | Polish | `ttc_ivf_readiness.dart:168-172` |
| A10 | The contract test's added-column check matched only the first column per `alter`, so 0044's columns were never pinned | Weak | `test/ttc_schema_contract_test.dart:140-143` |

## Decisions
| # | Question | Recommended | User's answer |
|---|---|---|---|
| D1 | After a loss, how is time trying counted? | Option A: all months trying, minus pregnancy; show it; let her change it | **Option A**, "be precise… show an option like want to edit" (2026-10-27) |
| D2 | His phone shows her number? | Yes, one number; only the worked-out start is published | **Yes** (2026-10-27) |
| D3 | A pregnancy record she deleted | Respect the delete | **Respect the delete** (2026-10-27) |
| D4 | Build T1 as planned? | Yes | **Yes, build T1** (2026-10-27) |
| — | One loss on record and the earlier ones unanswered | Not reassuring (the tool's asymmetry rule) | chosen and recorded |
| — | A saved "A previous miscarriage" tick | Becomes one loss before ParentVeda, unless her records hold one | chosen and recorded |

## As built (2026-10-27)
- **One count:** `lib/ttc/ttc_trying_time.dart` (pure) and `TtcStore.tryingTime` / `tryingTimeFor` / `setTryingBasis` / `tryingAgainSince`; `daysTrying` reads it. Ended pregnancies (`loss`, `birth`, `ended`) are left out, clipped and merged. An end the app was never told is not left out, and the line says so. A planned month still ahead shows "You plan to start in…" with no count.
- **Every reader on it:** message facts (`effectiveStart`), Ask Veda `months_trying` (same rounding), You ("Trying · about N months"; "Trying for" shows the heading and line, and its edit opens the Change sheet), checklist notes.
- **The line and Change:** `lib/screens/ttc/ttc_trying_change_sheet.dart` (`TtcTryingLine`, `showTtcTryingChange`): three options with each one's months, a date picker (no future date, 15 years back at most), a toast that says what it now counts and that the doctor check uses it. The label names its action ("Change what this counts from"; "Add when you really started" when the start is a guess). Shown under Q2 of the doctor check; changing it re-reads the check.
- **Losses (TT2):** `IvfLossesBefore` plus `recordedLosses` on the answers; a new Q5 asks only about before ParentVeda ("We have 1 loss on record…" when there is one); seven questions now. Two or more = flagged ("because you've had two or more pregnancy losses"). One = a kind line (`kIvfOneLossLine`). "A previous miscarriage" left the conditions list (kept for revert). The engine: `TtcFertilityHelpStore.recordedLosses` / `priorLosses`, `selectedConditions` drops the old id, so `known_condition` no longer fires on it and `two_miscarriages` fires from records. The notes carry a "Pregnancy losses" line.
- **Reasons as sentences:** `kIvfFlagReason` ("you have PCOS").
- **TC3:** "Twelve months of trying, under 35".
- **TC5:** `startTryingFromFamily` sets the basis to "started again, today"; the undo restores her earlier pick (two new undo keys).
- **Sync:** migration `supabase/migrations/0117_ttc_trying_count.sql` (three nullable columns on `ttc_journeys`, a check on `trying_count_from`, no policy change). The push sends only the start she gave (A6), the 0117 keys only when they carry something or must be cleared (BACKEND-PATTERNS §16xx), and his phone reads `trying_effective_start ?? journey_start` from her row.

## Verified
- `test/ttc_trying_time_test.dart` (new): the count and every edge case; one number across store, doctor check, messages, Ask Veda, You and notes (source checks); his phone's line never mentions pregnancy; the Change pick saved and cleared; losses from records, a birth not a loss, the old tick carried over, two losses fire and one does not; TC3; TC5 and its undo; the screen shows the line and the before-ParentVeda question.
- `test/ttc_ivf_readiness_test.dart`: the red-flag list without `miscarriage` (kept for revert). `test/ttc_schema_contract_test.dart`: 0044 and 0117 columns pinned, per statement.
- The TTC suite plus stage moves and You: all pass except three failures in files this work does not touch: `ttc_mind_body_test` (a tool tile on the Mind and body door) and `ttc_no_repetition_test` (articles), both in files Terminal A has open, and `ttc_data_chain_test` "the most recent entry has no length yet" (cycle lengths; not traced, reported).
- `flutter analyze` on every touched file: clean apart from an existing info at `ttc_askveda_screen.dart:1067`.

## Owed
- **Run migration 0117** (the user): DONE 2026-10-28.
- **BEFORE-LAUNCH lines** (that file has another terminal's edits open; text handed to the user): the after-loss default, the one-loss and two-loss wording, running 0117.
- **Sync log step and STILL-OPEN-BACKEND row:** on the user's word (text ready).
- A phone walk, on the user's word.
