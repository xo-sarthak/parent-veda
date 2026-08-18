# Scans & tests — reconciliation against the 40-hub Excel

Source: `PARENTVEDA_FINAL_40_HUB_236_JOURNEY_RECONCILIATION.xlsx`, sheet
**Problem Hub UX Map**, plus the implementation prompt (`Prompt.pdf`).

Implemented 2026-08-16. **Pregnancy → Scans & tests only.** The other 39 hubs
are untouched; the Excel's own Inventory Snapshot already says *"39/40 still
generic; Scans & Tests is the only one on new model."*

---

## 1. What changed

**The hub went from four doors to six**, because the Excel specifies this hub as
one primary intent (*"Know what my next scan/test is for"*) walked through six
journey steps, and two of them had no home at all in the four-door build.

| # | Excel journey step | Before | Now |
|---|---|---|---|
| 1 | See my timeline | **missing** | `ScanTimelineScreen` — **new** |
| 2 | Understand this scan | "Understand my next scan" | relabelled → `ScanDetailScreen` |
| 3 | See my appointment | "See my appointments" | relabelled → `appointments` surface |
| 4 | Understand my report | same | unchanged → `reports` surface |
| 5 | What happens next? | **missing** | `ScanNextScreen` — **new** |
| 6 | Need expert help? | "Know when to ask my doctor" | relabelled → urgent/consult path |

Steps 1 and 5 are the opening and closing moves — the run of tests she is
partway along, and what to do once a scan is done. Without them the journey has
no closure, which prompt §4 forbids outright.

### The ceiling that had to go

`problem_hub_screen.dart` asserted `needs.length <= 4`, with the reasoning
"more is a menu, which is what this replaces". The reasoning was sound and the
number was not: **the honest number of answers is a property of the problem, not
of the layout.** Prompt §14 says it directly — *"Do NOT arbitrarily limit this
to four."* Raised to 2–8; the floor stays because one door is not a choice, and
a ceiling stays because past about eight the hub becomes the inventory menu it
was built to replace. `test/problem_hub_test.dart` updated to match.

---

## 2. ⚠️ Two corrections to the Excel's implementation status

Reported rather than silently worked around, per prompt §19: *"if you discover
that the Excel's implementation status is incorrect, report it rather than
silently changing the journey."* **Neither changes the journey.**

### 2.1 Parameter-by-parameter lives in `tests_scans`, not `reports`

The Excel's step 4 says:

> Open report/finding → **parameter-by-parameter explanation** → FAQs → what to ask
> Implementation status: `reports / ReportScreen`

`ReportScreen` is the **findings decoder** — 27 findings (low-lying placenta,
etc.), each with a fixed 7-section structure that does include *"What usually
happens next"* and *"Questions to ask your doctor"*. It is excellent and it is
not parameter-by-parameter.

The parameter-by-parameter capability the Excel describes **does exist**, in a
different place: `TestScanInfo.parameters` (`ReportParameter` — `measures`,
`whyImportant`, `typicalRange`, `ifLow`, `ifHigh`, `note`), rendered by
`tests_scans_reports_screen.dart:343`, reached through the `tests_scans`
surface.

**Left as-is.** Step 4 opens `reports` exactly as the Excel specifies; the
finding decoder is the right answer to "a line on my report I do not recognise".
The correction is recorded so the inventory can be fixed rather than the journey.

### 2.2 Step 6's consult supply is thinner than "configure specialty" implies

The Excel says *"Booking engine + consult surface; provider supply may need
seeding"*. That is accurate, and worth stating plainly: the booking engine is
real, and the seed list is **five specialists with mock slots**. Configuring a
gynae specialty is a config change; having someone to book is not. No new
appointment feature was built (prompt §7).

---

## 3. Reuse audit — what was NOT built

Prompt §11/§19 require searching before creating. Every capability the six steps
need already existed:

| Need | Existing surface | Verdict |
|---|---|---|
| Scan schedule + costs | `ScanScheduleScreen`, `kScanCost` | REUSE |
| Per-scan explainer, preparation, after-scan | `ScanDetailScreen` | REUSE |
| Appointments | `ScansAppointmentsScreen` (`appointments`) | REUSE |
| Report findings + questions to ask | `ReportScreen` (`reports`) | REUSE |
| Per-scan parameters | `TestsScansReportsScreen` (`tests_scans`) | REUSE |
| Due date / gestational age | `PregnancyController`, `DueDateCalculatorScreen` | REUSE |
| Booked / completed state | `ScansStore` | REUSE |
| Consult | booking engine + `consults` | REUSE |
| Red flags | `kScanRedFlags`, `ScanUrgentScreen` | REUSE |

**Nothing new was created except two orchestration screens.** Both are pure
re-arrangement of data that already ships — no new content type, no new engine,
no new store, no new model. That is the point of the exercise: *the inventory is
the toolbox, the Excel is the journey.*

### What the two new screens actually do

**`ScanTimelineScreen`** (step 1) — the same nine scans as `ScanScheduleScreen`,
read against three things that screen never looks at: her current week, her
booked dates (`ScansStore.appointments`), and what she has marked done
(`ScansStore.completed`). The schedule answers *"what tests exist and what do
they cost"*; this answers *"where am I on them"*, which is why the Excel names
`appointments` and `due_date` as its tools rather than the scan library.

⚠️ `done` beats the week window. A scan she marked complete is complete even if
the arithmetic says it is still ahead — her record outranks our calculation,
which is the truth hierarchy in one line.

⚠️ The due date is **shown and attributed, never recalculated**. Where
`DueDateSource` says a clinic owns it, gestational age is theirs.

**`ScanNextScreen`** (step 5) — closes the journey. It does not re-explain the
scan (step 2 did) and does not decode the report (step 4 does), per §15's
no-duplication rule. It says: that one is behind you, here is what the result
usually means (`TestScanInfo.interpretation` + `interpretPointers`), here is
what is due next, and here is the way to a person.

Its empty state is an invitation, not an error — a mother can reach it before
marking any scan done, and *a feature is never hidden*.

---

## 4. Known debt from this pass

- **`kScanRun` is duplicated.** The clinical order of the nine scans now lives
  in both `scan_schedule_screen.dart` (`_kOrder`) and
  `scan_timeline_screen.dart` (`kScanRun`). Neither screen owns it; it belongs
  in `tests_scans_reports_data.dart`, which four other screens read. Not done
  inside this journey's implementation because it touches unrelated surfaces.
- **English only.** Every string in both new screens is `_en(...)` — *English
  now, Hindi owed*, per CLAUDE.md, which makes `grep -c '_en('` the size of the
  backlog. Deliberate: the screens are being reviewed for shape first. **Never
  `_t(x, x)`** — an identical pair reads as finished work to every audit.
- **Step 2 has no video or article slot.** The Excel asks for *Video + Article +
  FAQs*; `ScanDetailScreen` carries the questions and preparation and links one
  read item. Attaching tagged video/article content is content work on the
  existing read/watch capability, not a build — and it is blocked on the
  Excel's own finding that *"content tagging is currently absent"*.

---

## 5. QA against the Excel's §21 checklist

| Check | Status |
|---|---|
| Correct stage / problem | ✅ PREGNANCY / Scans & tests |
| Correct "what do you need right now?" choices | ✅ six, the Excel's six |
| Correct **number** of choices | ✅ six — the 4-cap removed |
| Each choice opens the correct next level | ✅ all six route |
| Journey continues until closure | ✅ step 5 added for exactly this |
| Tools appear at the correct step | ✅ 1, 3, 5 |
| Products appear only where relevant | ✅ **none** — NOT APPLICABLE for this hub, and two independent locks keep it that way |
| Courses | ✅ none — NOT CORE |
| Consult at the escalation point | ✅ step 6, last |
| Existing functionality reused | ✅ §3 above |
| No duplicate feature created | ✅ two orchestration screens only |
| NOT APPLICABLE items not rendered | ✅ |
| Visual language consistent | ✅ V3 — `V2Palette`, Fraunces/Manrope, drawn marks, no filled violet buttons |
| Videos / articles at the correct step | ⚠️ slot exists, content untagged — §4 above |
