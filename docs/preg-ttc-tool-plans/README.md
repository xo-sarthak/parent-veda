# Pregnancy and TTC tools: plans index

Master: [00-MASTER.md](00-MASTER.md) holds the split with Terminal A, decisions M1-M8, consent T1, rule C1, the Step 0 findings, the TT1/TT2 specs, the families and the hand-over list.
Order (the user, 2026-10-27: "yes go"): P1 and T1 together now; while Terminal A's week fix is in progress, P2, T3, T4, T5; after A's week and phase commit, P3, P4, P5, T2; after A's Tools-tab order commit, C1.
The user says go per family. Each plan records every decision with the user's answer and date.

| # | Family | Status | Commit |
|---|---|---|---|
| 0 | Step 0: inventory, C1, repeats, look (both stages) | DONE, read-only (2026-10-27) | — |
| P1 | Look-ups and records | COMMITTED 2026-10-28 (P1-lookups-records.md) | 305b5c6 |
| P2 | Keep | BUILT 2026-10-28 (P2-keep.md); 0118 run 2026-10-28 | 01f33b1 |
| P3 | Her week | COMMITTED 2026-10-28 (P3-her-week.md) | d94f537e |
| P4 | Birth prep (+ store seed retired, Coming soon) | COMMITTED 2026-10-28 (P4-birth-prep.md) | 17238591 |
| P5 | Daily check-ins (+ mood log sync, 0125) | COMMITTED 2026-10-28 (P5-daily-checkins.md); 0125 run 10-29; BACKEND-PATTERNS 16zzg f7131e97 | d2d5376e |
| T1 | TTC: the doctor check (TT1, TT2, TC3, TC5) | COMMITTED (T1-doctor-check.md); 0117 run 10-28 | 00b3cc5 |
| T2 | TTC: cycle tools | BUILT 2026-10-29 (T2-cycle-tools.md, As built); Ask Veda `window_source` in both repos (Railway redeploy owed) | 635838fe |
| T3 | TTC: getting ready | BUILT 2026-10-29 (T3-getting-ready.md, As built); sync-log step 28 and BEFORE-LAUNCH lines written 10-29; one full TTC run owed | ecb47348 |
| T4 | TTC: treatment and records (+ TTC-GAP 25) | BUILT 2026-10-29 (T4-treatment-records.md, As built; Q3 confirmed at build start); migration 0127 written, the user runs it BEFORE installing; new 54-test file passes; the TTC run was stopped for memory after 18 of 158 files (1 fail, Can I, T3's); one full TTC run owed; door lines, BEFORE-LAUNCH, sync log and TTC-GAP 25 close on the user's word | dff5e77a |
| T5 | TTC: body checks (+ habits shared by choice, 0131) | BUILT 2026-10-29 (T5-body-checks.md, As built; Q1 habits shared each by their own choice, body data private; Q2 his own weight and BMI); 0131 run 2026-10-29; new 47-test file passes; the scoped run's 1 fail is T4's round title; BEFORE-LAUNCH, sync log, BACKEND-PATTERNS and STILL-OPEN on the user's word | c8c117e5 |
| C1 | Pregnancy and TTC Tools rows + tests; plus from P3: the father preview (X5) and Weight and Kegel missing from search (X4), one shared "booked" match for the Calendar and the Scans timeline (today matched by title two ways), the second twin from Add a child marked as a multiple birth (check git status on the family-profile files first) | BUILT 2026-10-30 (C1-tools-rows.md, As built; Q1 three Scans rows, Q2 one mark per row, Q3 every row in search); 8 new Pregnancy and 5 new TTC rows; new tests preg_c1_tools (11) and ttc_c1_tools (5) pass with the scoped pins; the full suite is the next pass | 046f0df7 |
| S1 | The one full suite: TTC, Pregnancy, every schema contract, and the shared Parenting tests (Kegel Care, Baby names, child records, twins, children sync) | RUN 2026-10-30: 215 files in 11 batches; 4386 passed, 20 failed, 11 skipped. Pregnancy, contracts and Parenting all pass. 12 fails ours: T4 8 (one real bug: Save on a result closed through `maybePop` while the `PopScope` still held the unsaved form, so "Discard this result?" rose over a saved record and Discard deleted its photos; fixed with `pop`, plus a test), T5 2, C1 2. Fixed on the user's word 2026-10-30: three labels named (record toast "owner", "Leave without reading your report?", "Read about azoospermia"), the medication pill and the BMI before-pregnancy card brought to the house look, and eight stale pins updated with kept-for-revert notes (including T3's Can I and T4's round title). Re-run of the touched files passes; scoped analyze clean. The 6 not ours (door photos and ids for the PCOS circle and Loss room, "Others who have been here", "What you're working on" twice) were fixed by the other terminals in `b957d0e9` and `a63abb59`; their four files re-run green, so the whole suite is green | aeec8319 |
