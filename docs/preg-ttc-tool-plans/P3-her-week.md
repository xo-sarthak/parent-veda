# P3: Pregnancy, her week

## Context
Pregnancy and TTC tools pass (`00-MASTER.md`), family P3, Terminal B. Audit read-only on 2026-10-28: two helpers read the code and the lead checked every Broken and Wrong claim at its file:line. A's week fix (fe1a831) and Tools order (2eb7a77) are committed, so nothing here waits.

| # | Tool | Surface | Screen |
|---|---|---|---|
| 1 | Due date | `tools/due_date`, `due_date`, `pregnancy/due_date` | `pregnancy/preg_due_date_screen.dart` (kept), `tools/due_date_calculator_screen.dart` (folded in) |
| 2 | Calendar and appointments | `calendar`, `appointments` | `calendar_screen.dart`, `pregnancy/calendar/*`, `services/scans_store.dart` |
| 3 | Scans timeline | Scans door, My scans tab | `brackets/scan_timeline_screen.dart` |
| 4 | Weight | `tools/weight` | `tools/weight_tracker_screen.dart` |
| 5 | Baby movement | `tools/movement` | `tools/baby_movement_screen.dart` |
| 6 | Kegel Care | `tools/kegel` (Parenting opens it too) | `tools/kegel_care_screen.dart` |

## Out of scope, said plainly
- **The home hero after a loss** is Terminal A's (homes). Handed over as a question: what she sees there.
- **Door files** go to A: `ScanNextScreen` still mapped at `pv_door_router.dart:315` (it opens the retired appointments screen); the Scans door's "up next" framing after a loss.
- **The rest of "Get ready" after a loss** (hospital bag, birth plan, contractions, product checklist, names): the same "everything stays" answer applies, and it is built in P4, the family that owns those tools. P3 unhides only its own rows.
- `ScansHubScreen` and `ToolsHubScreenClassic` have no live callers; not touched.
- Kegel history per-item merge stays owed (sync step 10).

## Decisions
| # | Question | Recommended | User's answer (2026-10-28) |
|---|---|---|---|
| D1 | Two due-date screens | Keep `PregDueDateScreen` (clinic warning, date check, clear save); every way in lands there; add Conception as a fifth way; fold the roadmap in as a short trimester section | **Yes**, "industry standard, easy to use" |
| D2 | Calendar and timeline keep different ids for one scan | One id: the store reads both spellings, so no tick is lost | **Yes** |
| D3 | PG2, the retired appointments screen | `appointments` opens the Calendar | **Yes** |
| D4 | Calendar on Tools (C1) | Add the row | **Yes** |
| D5 | After a loss, which tools stay? | (a) Movement and Due date step aside | **(b) Everything stays, baby wording dropped.** No hiding; a gentle note when she opens a tool that needs a pregnancy |
| D6 | Twins weight range | Twin bands, doctor check before launch | **Yes**; and at birth tell her to make one profile per baby so both are tracked |
| D7 | Appointment reminders | On by default, a switch per appointment | **Yes, on by default**; the booking says a reminder is set and where reminders live |
| D8 | Clinical calls | Follow NHS / RCOG / ACOG and the big apps; numbers get a doctor check in BEFORE-LAUNCH | **"you can verify them"** |

## Build, three waves, no stop between
1. **Correctness and safety:** one due-date tool (DD1-DD4, DD7); the movement red flag stays on screen in a live session (M2) and the row line stops saying "count kicks" (M1); one scan id (CA3); `appointments` opens the Calendar (PG2 / CA1); a backdated weight gets that date's week (W3).
2. **After a loss and wording:** unhide Movement, Weight, Due date; the after-loss note on Movement, Due date, Calendar and the timeline; no countdown, usual checks or "up next" after a loss (CA5, ST2); Kegel drops "Preparing for birth" (K1); Weight shows its range and lets her change her start (W1, W2), twin bands (W7), the twins line at the birth sheet; no silent saves (W4, W5, M6, K3, ST3, DD4).
3. **Wiring and tests:** Calendar row on Tools; appointment reminders; column contracts (weight, movement, appointments, completed scans); reachability, after-loss and red-flag tests; analyze and the suite green.

## As built (2026-10-28)
**Wave 1, correctness and safety**
- One due-date tool: `DueDateCalculatorScreen` now builds `PregDueDateScreen`, so all seven ways in (Tools, `due_date`, search, Ask Veda, the door, the Calendar's Change) land on the screen with the clinic warning, the date check and "Saved. Your weeks now follow this date." (DD1-DD4, DD7). The old calculator is `DueDateCalculatorClassicScreen`, kept for revert. Conception date is the fifth way (also in `pv_add_pregnancy.dart`, which shares the list); a short "Your trimesters" card replaces the long roadmap.
- `ScansAppointmentsScreen` now builds `CalendarScreen` (PG2 / CA1); the old one is `ScansAppointmentsClassicScreen`. The Calendar's own row is now "My scans" and opens `ScanTimelineScreen`.
- One scan id: `ScansStore.kScanIdTwins` / `scanKey`; reads and removals match either spelling, new marks use the timeline's (CA3).
- Movement: the red flag shows in a live session too (M2); the row and Ask Veda lines say "Note your baby's movements and get to know the pattern" (M1); "Take back the last one" and "Remove this session" with Undo (M6, `undoLastMovement`, `deleteMovementSession`, `restoreMovementSession`).
- Weight: a weigh-in carries the week of its own day (`weightWeekOn`, the Calendar sheet's rule) (W3).

**Wave 2, after a loss and wording**
- Hub: Movement, Weight and Due date no longer hidden after a loss; the rest of Get ready keeps `if (!_ended)` row by row until P4.
- `PregAfterLossNote` (new, `preg_after_loss_note.dart`) at the top of Movement, Due date, Calendar and the Scans timeline. The Calendar drops its hero countdown, the usual checks card and check items; the timeline drops "Up next".
- Kegel: after a loss the routine holds at the middle one (no "Preparing for birth"), the "During pregnancy" line and the contractions warning go (K1); one or two rounds say why they were not kept (K3).
- Weight: the range card is back on the dashboard (W1), with twin bands from `recommendedGainTwins` (W7); "Change your starting weight or height" reopens setup with her values and says what changed (W2); save and invalid entry both speak, delete has Undo (W4, W5); after a loss no week label, no range, no baby explainers.
- Timeline: ticking a scan and saving or removing its date all say what changed, including that the tick writes her Journal (ST3).
- Birth sheet: if she said twins, "Twins? Add one baby here. Then add the other from You, Add a child…" (D6).

**Wave 3, wiring and tests**
- Calendar is a Tools row (Track group, route `calendar`).
- `AppointmentReminders` (new): 7 pm the evening before, or 8 am on the day; on by default, a switch per appointment in Reminders under "Appointments"; armed on add, update, launch and cloud pull, cancelled on delete; every booking message says when and "Your reminders are in Tools, then Reminders."
- Tests: `test/preg_her_week_test.dart` (26 with the contract file), `test/preg_her_week_schema_contract_test.dart` (weight_entries, movement_sessions, appointments, completed_scans columns against every migration).
- Docs: BACKEND-PATTERNS 16zzb; BEFORE-LAUNCH two clinician CHECK lines (twin bands; after-loss wording).

**Left, said plainly**
- "Booked" is still matched by title, two ways (exact in the Calendar, contains in the timeline). It reads as open, never wrong; a shared helper is owed.
- The second twin, added through Add a child, is not marked as a multiple birth.
- Father preview: search, Ask Veda and the Calendar still open her trackers (X5); search lists Movement but not Weight or Kegel (X4). Both go to C1.
- Kegel history per-item merge stays owed (sync step 10).

**Hand-over to Terminal A:** the home hero after a loss (what she sees); `ScanNextScreen` still mapped at `pv_door_router.dart:315`; the Scans door's "up next" framing after a loss.
