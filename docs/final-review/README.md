# Final review — master (started 2026-10-31 17:20 IST)

The last whole-app review before launch: build all three apps onto the phone, fix
what breaks, walk everything owed, then clear the pending ledgers.

**Read this file first, then ONLY the track file you are working on.** Each track
file is self-contained. Never load the big source ledgers whole (sizes below):
grep them, or read the section a track file points to.

Timestamps: IST, `YYYY-MM-DD HH:MM`, on every entry. Match them against
`git log --format="%h %ad %s" --date=iso`.

## Tracks

| # | Track | File | Status (last update) |
|---|---|---|---|
| 1 | Build + install, three apps; test failures and fixes | `01-build-2026-10-31.md` | Parent INSTALLED 2026-10-31 18:22 (13 test fails fixed, committed `5dd32638`). Doctor INSTALLED 18:49. Partner INSTALLED 19:11. **DONE.** |
| 2 | Phone walk: every walk owed by past sessions, parent app first (doors and relevance lead) | `02-walks/` (one file per area + its own index) | Not started. Do not walk until the user says. |
| 3 | Clear `STILL-OPEN.md` | `03-still-open/` | Not started |
| 4 | Clear `BEFORE-LAUNCH.md` | `04-before-launch/` | Not started |
| 5 | Other pending ledgers (`STILL-OPEN-BACKEND`, `GLOBAL-CHANGES`, `DOOR-CONTENT-OWED`, ...) | `05-other-ledgers/` | Not started |

Order: 1 → 2 → 3/4/5. The user starts each step.

## The source ledgers are big — do not read them whole

| File | Size (2026-10-31) |
|---|---|
| `docs/STILL-OPEN.md` | 11,670 lines, ~720 KB |
| `docs/BEFORE-LAUNCH.md` | 424 lines, ~111 KB |
| `docs/DOOR-CONTENT-OWED.md` | 775 lines, ~106 KB |
| `docs/STILL-OPEN-BACKEND.md` | 473 lines, ~39 KB |
| `docs/GLOBAL-CHANGES.md` | 501 lines, ~34 KB |

## How the files are kept small

- This master holds status lines only: one row per track, updated in place.
- A track folder has its own short `README.md` index plus one file per area or task.
  Detail lives there, never here.
- A finished item gets one line with its date and commit hash; the discussion is not kept.
- Helpers (subagents) run on Sonnet 5.5; the orchestrating session runs on Opus 5.5.

## Rules carried by every session in this review

- Do not run git; give the user the commands with explicit paths. No co-author trailer.
- Ask before driving the phone (taps, installs). Screenshots are announced.
- Phone `RZCX50ZKLBA` (S21 FE), on Wi-Fi since 19:00: `adb connect 192.168.1.6:<port>` (the port changes when the screen locks). Run one build at a time.
- Before each release build, delete the stale `<flavor>Release` native-lib folders
  (see track 1).
