# Tools 02-07: the care logs (Breastfeed timer, Nappies, Pumping, Sleep, Tummy time, The last 7 days)

Done as one family on 2026-10-25, because they share one data file (`pp_care_log_data.dart`, plus `pp_sleep_data.dart`), one sheet kit (`pp_care_parts.dart`) and the same defect. The user wanted the tools finished today ("I want to get done with the tools today"), with the backend working before a tool counts as done.

## Audit
| Tool | Finding | Severity |
|---|---|---|
| Nappies, Pumping, Sleep, Tummy time | **Twins' logs mixed.** Each store keeps every child's rows in one list. The reads never asked the ledger whose a row is (the same bug as Log a feed). | **Broken** |
| Breastfeed timer | Started for one twin, finished after switching to the other, the feed was **saved to the second**. | **Broken** |
| Nappies, Pumping, Sleep | Remove-only: a wrong time meant delete and log again. | Weak |
| Nappies, Sleep, Pumping | Counts were since midnight. At 6 am Sleep said "0m slept today" after a full night, and nappies read low all night. The guidance counts per 24 h, the same call as F1 on feeds. | Weak |
| Sleep | No live logging. Only "type when they fell asleep and woke", afterwards. | Weak |
| The last 7 days | "Share with your doctor" sat greyed out with nothing logged: a silent tap (S8). | Weak |
| Tummy time | Counted per calendar day, kept on purpose: the guidance is "a few times a day", so a day is its unit. Timed entries keep remove + Undo. | OK |
| Backend (all) | Local-first, app ids, newer-wins ledger, soft delete, `pp_logs_merge_test` and `sync_guard_contract_test`. | OK |
| Uses (consent) | No reader outside the tools uses these logs yet. Following the "only add a flag when something reads it" rule, there is no consent kind until one does. Is my baby OK? reading nappies (tool 11) will add `nappies`. | — |

## Mobbin pass
- **Fitbit:** sleep session, one running clock with "End sleep session". https://mobbin.com/screens/1c6f8180-ad93-4e94-a3e0-4314feb19035 — adopted as Asleep now / Woke up.
- **Me+:** "Start tracking" as the first action on the sleep page. https://mobbin.com/screens/bc47884a-c9ee-42e0-9bb5-175fbba27448 — the live button leads, and typing times afterwards becomes the secondary button.
- From tool 01: Flo / MacroFactor edit on every entry, applied to every care log.
- **Declined:** Pillow's and TIDE's alarm-clock framing (a baby's sleep is not an alarm) and sleep scores.

## Decisions
| # | Question | Recommended | User's answer |
|---|---|---|---|
| CL1 | Sleep: live "Asleep now" button? | Yes | **Yes, add Asleep now** (2026-10-25) |
| — | Twins fix, timer child, edits, 24 h counts, empty-share toast | Defects, or the F1 call already made: chosen and recorded, not asked | — |

## Built (2026-10-25)
- **`ChildLogLedger.belongsTo(key, childId)`** (`lib/services/remote/child_scoped_store.dart`): one ownership check on the ledger, used by `all` in Feeding, Nappies, Pumping, Tummy time and Sleep. A row the book never saw counts as the active child's (the uploader's fallback).
- **Timer:** `BreastTimer` captures the child on the first tap, persists it, and `finish` calls `FeedingStore.log(childId:)`. `FeedingStore.add/log` gained an optional `childId`.
- **Edit:** `update()` on `NappyStore`, `PumpStore` and `SleepStore`. Each screen's rows open the same sheet filled in ("Edit this nappy / session / sleep"), with Undo restoring the old row.
- **24 h:** `NappyStore.wet24h/dirty24h` (and the insight lines), `PumpStore.ml24h`, `SleepStore.totalMinutes24h` (clips a night that began before the window).
- **Asleep now:** `SleepStore.startAsleep / wakeUp / cancelAsleep / asleepSince`, kept on this phone with the child it is for, dropped after 16 h. Night if it began 7 pm to 6 am. The screen shows "Asleep since 9:10 pm, 42m so far" with Woke up and Cancel. "Log a sleep from earlier" stays.
- **S8:** the empty share says "Nothing logged in the last 7 days yet...".
- **Test resets** now clear each store's ledger (it decides ownership now).

## Verified
- `test/pp_care_logs_tool_test.dart` (7, new): twins in four stores, the timer across a switch, edits keep ids, 24 h nappies and sleep clipping, asleep-now save and under-a-minute, the sleep screen flow, the empty share toast.
- Neighbouring suites (care logs, care screens, sleep door, sleep check, feed tool, merge, sync guard, tools tab, one look, child switch, relevance, feeding door, consent sync): **187 pass**.
- Analyze is clean on every touched file.

## Known limits
- **Asleep now is per phone.** If Papa taps Asleep on his phone, Maa's phone doesn't show the clock until the sleep is saved, and then it syncs. Sharing a live clock needs a server row. It's recorded, not built.
- **Tummy time** keeps remove + Undo and has no edit (timed entries).
