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
| T5 | TTC: body checks (+ habits shared by choice, 0131) | BUILT 2026-10-29 (T5-body-checks.md, As built; Q1 habits shared each by their own choice, body data private; Q2 his own weight and BMI); 0131 run 2026-10-29; new 47-test file passes; the scoped run's 1 fail is T4's round title; BEFORE-LAUNCH, sync log, BACKEND-PATTERNS and STILL-OPEN on the user's word | — |
| C1 | Pregnancy and TTC Tools rows + tests; plus from P3: the father preview (X5) and Weight and Kegel missing from search (X4), one shared "booked" match for the Calendar and the Scans timeline (today matched by title two ways), the second twin from Add a child marked as a multiple birth (check git status on the family-profile files first) | after A's Tools-tab order commit | — |
