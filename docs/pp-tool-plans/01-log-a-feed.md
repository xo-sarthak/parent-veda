# Tool 01: Log a feed (+ T0, the "ask once" consent seam)

## Context
This is the first tool in the tool-by-tool pass (`docs/pp-tool-plans/00-MASTER.md`). The user wants every parenting tool to work fully in both frontend and backend, with good UX, a Mobbin pass per tool, and whatever a tool learns reused elsewhere only after asking ("ask once per kind").
- **The tool:** `pp_feeding` → `FeedingJourneyScreen` (`lib/screens/post_pregnancy/feeding_journey_screen.dart`).
- **Its store:** `FeedingStore` (`lib/screens/post_pregnancy/pp_feeding_data.dart`), synced to `pp_feed_logs` through `ChildLogLedger` (`lib/services/remote/child_scoped_store.dart`).
On approval, this plan is copied to `docs/pp-tool-plans/01-log-a-feed.md`.

## Audit (8-point checklist)
| # | Finding | Severity |
|---|---|---|
| 5 Backend / 2 Relevant | **Two children's feeds are mixed.** `FeedLog` has no child id. `all`/`todays`/`last`/`nextExpected`/the next-side suggestion read every row in `_logs`. The ledger knows each row's child (`childOf`), but the reads never ask it. With twins or siblings, "last feed", the count, the next side and the 7-day history all blend both children. The pull for child B keeps child A's local rows in the list. | **Broken** |
| 6 Uses | `pp_relevance.dart:75` reads `methodToday`. A **bottle of expressed breast milk raises the formula signal**, so a breastfeeding mother gets formula pages lifted. It also uses the log without asking. | **Wrong** |
| 3 Works | A feed can't be **edited**, only removed and re-added. A wrong time or side means delete and redo. | Weak |
| 3 Works | The shell sheet lost the **note** field the 2026-08 sheet had. The timer still writes notes, so notes show on some feeds and can't be added to others. | Weak |
| 7 Clinical / 4 UX | The count is **since midnight**. At 2 am it says "1 feed today" after a full night. Clinical guidance (and Is my baby OK?) counts per 24 h. The average gap and "next feed" also reset at midnight. | Weak |
| 4 UX | The most common action (same as last time, other side, now) takes 3+ taps. | Weak |
| 4 UX | "What the pattern shows" always prints 2-3 fixed sentences, whatever the data. Filler reads as insight. | Polish |
| 6 Uses | Unused: the "feeds" item in Is my baby OK? asks a question the log already answers. Solids logged are never offered to Can my baby eat this? / first foods. No reminder option. | Weak |
| 1 Reachable | Tools tab, Feeding door, First 40 door, home quick, care history: all land. The Tools tab lists Feeding and Breastfeed timer separately (R6). Kept on purpose: "track live" and "log after" are two acts (Fitbit splits them the same way). | OK |
| 5 Backend | Local-first, app ids, newer-wins ledger, soft delete, sign-out reset, `pp_logs_merge_test` and `sync_guard_contract_test` cover `pp_feed_logs`. | OK |
| 8 Tests | Missing: multi-child isolation, edit round-trip, 24 h counting, the relevance expressed-vs-formula case. | — |

## Mobbin pass (2026-10-25)
The library carries no baby trackers (Huckleberry, Glow, BabyCenter: `docs/MOBBIN-DISCOVERY.md`), so these are daily-logging stand-ins:
- **Fitbit:** "Track live" above "Manually log". We keep the timer and the sheet as two buttons. https://mobbin.com/screens/e04b81b9-1663-4f5a-8634-0a3bc457df69
- **Flo:** every logged item has its own edit pencil, plus inline +/− for amounts. We adopt a tap to edit. https://mobbin.com/screens/88782af7-01e9-4791-865e-b83cdfec1891
- **MacroFactor:** a timeline where each entry carries an edit pencil. Our "Today's feeds" rows become tappable to edit. https://mobbin.com/screens/e2c71034-8855-477f-8d6c-0e497ca346ed
- **Google Health:** log shortcuts as chips near the top. We adopt the one-tap repeat chip. https://mobbin.com/screens/dbc4e875-9f6a-4f5d-bc2e-3b326a943be1
- **Declined:** calorie/target rings (a feed is not a quota) and streaks.

## Decisions (user, 2026-10-25)
| # | Question | Recommended | User's answer |
|---|---|---|---|
| F1 | Count per 24 h or since midnight | Last 24 hours | **Last 24 hours** |
| F2 | One-tap "Same as last time" | Yes | **Yes, one-tap repeat** |
| F3 | Offer a next-feed reminder after a save | Offer, off by default | **Offer it, off by default** |
| F4 | The existing relevance use of the log: under "ask once"? | Yes, after the bug fix | **Yes, ask once** |
| — | Edit a feed, note back on the sheet, multi-child fix | Defects, so no choice is needed | — |

## Build
**A. Multi-child (Broken).** In `FeedingStore`, add a `_mine(FeedLog)` check: `(_sync.childOf[id] ?? activeChildId) == activeChildId`. Rows with no ledger entry (from before the ledger) count as the active child's, matching how `uploadFor` falls back. `all` returns only the active child's rows, so every derived getter follows. Listen to `ChildProfileStore` so the screen rebuilds on a switch; the screen already merges `ChildProfileStore`. Pull already scopes the cloud side. `pp_care_log_data.dart` (history, `ppNextBreastSide`, timer) reads `FeedingStore.instance.all`, so it is fixed through the same getter. Grep each caller.
- *Trade-off:* filtering at read time keeps one list and one prefs key (no migration, no data move), at the cost of a map lookup per row. Splitting storage per child would be "cleaner", but it would mean migrating every parent's saved feeds, the kind of rewrite of shipped data CLAUDE.md rules out.

**B. Edit.** Tapping a "Today's feeds" row opens the same shell sheet, filled with the feed. Save calls a new `FeedingStore.update(FeedLog)` (replace by id, `_sync.touch`, push), and the toast says what changed, with Undo restoring the old row. `PpCareEntryRow` gains an optional `onTap`, so other care logs can use it later.

**C. Note.** An optional "Add a note" field returns to the shell sheet, collapsed to one line. It is saved on breast, bottle and solids alike.

**D. 24 hours (F1).** Add `last24h`, `countLast24h` and an average gap over the last 24 h. The stat reads "N feeds in 24 h". The "Today's feeds" list keeps the calendar day, headed "Today". `quickInsight`/`patterns` use the 24 h window. `methodToday` stays for its other caller until E replaces it.

**E. One-tap repeat (F2).** Show a chip under "Log a feed": "Same as last: Breast, right" (the side switches, the way `ppNextBreastSide` already suggests) or "Same as last: Bottle, 110 ml". It logs at now, and its toast offers Undo. The chip is hidden when there is no last feed. For a last feed that was solids, it offers the food name.

**F. Reminder (F3).** After a save, the toast carries a quiet action "Remind me in ~3h", using the age gap from `_defaultGapForAge()` or the 24 h average. It calls `NotificationService.scheduleOneOff` (`lib/services/notification_service.dart:217`) with one fixed id, so a newer reminder replaces the older one. Nothing is set unless tapped. Copy: "A gentle nudge, not a schedule. Feed on cue."

**G. Patterns.** Show only lines computed from the parent's own data (24 h gap, longest stretch last night, solids started). Each fixed sentence shows at most once, and only when there is no data line. Comment out the old lines; don't delete them.

**H. T0, the consent seam (first user: feeds).**
- New `lib/services/pp_use_consent.dart`: `PpUseConsent.instance`, a singleton `ChangeNotifier`. `PpUseKind { feeds }`, with more kinds added by later tools. State is `yes | no | unasked`, stored in `shared_preferences`. `allows(kind)` is true only for `yes`.
- *Sync:* it starts local-only. A consent answer is a per-device preference today, and syncing it needs a store key in the step-13 merge. Rule: [[backend-sync-files-write-on-word]], so syncing waits for the user's word and goes in STILL-OPEN-BACKEND.
- `PpUseAskCard` (in the same file): calm, two buttons ("Yes, use it" / "Not now") and a one-line why. It shows once on the Feeding journey after the first save while `unasked`.
- In You: a "What ParentVeda uses" row in `lib/screens/profile/pv_data_privacy_screen.dart`, listing each kind with a switch.

**I. Relevance fix + gate (F4).** In `pp_relevance.dart`, the formula signal reads the store's new `bottleMilkLast24h` (formula only, not expressed). Breastfeeding comes from breast feeds or expressed bottles. Both log-derived inputs are used only when `PpUseConsent.allows(feeds)`. Onboarding answers (`fam.feedings`) are untouched. Run `git status` first: that file belonged to Wave 8, and it must be committed before we edit it.

**J. Reuse at later turns (written down, not built now).** Is my baby OK? pre-fills feeds in 24 h "from your log" (tool 11). Logged solids feed first foods in Can my baby eat this? (tool 23). Ask Veda context `feeds_24h` is a two-repo change: hand it over to `C:\Projects\parentveda-askveda`, and don't send it until the service declares it.

**S8 (no silent tap).** Repeat chip with no last feed: hidden, not dead. A reminder when notifications are off shows `pvToast`: "Notifications are off for ParentVeda. Turn them on in your phone settings to get reminders."

## Files
- `lib/screens/post_pregnancy/pp_feeding_data.dart` (A, B, D, I getter)
- `lib/screens/post_pregnancy/feeding_journey_screen.dart` (B, C, D, E, F, G, the ask card)
- `lib/screens/post_pregnancy/pp_care_parts.dart` (`PpCareEntryRow.onTap`)
- `lib/services/pp_use_consent.dart` (new: H)
- `lib/screens/profile/pv_data_privacy_screen.dart` (the H row)
- `lib/screens/post_pregnancy/pp_relevance.dart` (I)
- Docs: `docs/pp-tool-plans/01-log-a-feed.md`, README row, `00-MASTER.md` (T0 built), `docs/BACKEND-PATTERNS.md` (new section: "Consent as its own store; filter by owner at read time")

## Verification
- New `test/pp_feed_tool_test.dart`:
  - two children: logging for A doesn't show in B's `all`/`last`/count, and switching back restores A's
  - edit round-trip keeps the id and marks the row pending
  - 24 h count across midnight (23:30 and 00:30 both counted)
  - the repeat chip switches the side
  - `PpUseConsent`: unasked → yes → `allows`; no → doesn't allow
  - relevance: an expressed bottle doesn't raise `PpSignal.formula`, and no consent means no log-derived signal
- Run `flutter test test/pp_feed_tool_test.dart test/pp_care_log_test.dart test/pp_logs_merge_test.dart test/sync_guard_contract_test.dart test/pp_feeding_door_test.dart test/pp_tools_one_look_test.dart`, plus any relevance test (`test/pp_relevance*`).
- `flutter analyze` on the touched files only.
- Wiring gate: grep every `FeedingStore.instance.all` caller, the `PpUseConsent.allows` call sites, and the You row.
- A phone walk only on the user's word.

## Built (2026-10-25)
All of A to I built; J stays written down for tools 11, 23 and the Ask Veda repo.
- **A:** `FeedingStore._mine` + `all` filtered to the active child. Every reader (`ppNextBreastSide`, the timer, 7-day history, home quick, Tools tab live line) goes through `all`. Test: twins never share a log.
- **B:** `FeedingStore.update` keeps the id. Tapping a row opens "Edit this feed", whose Undo restores the old row. `PpCareEntryRow.onTap` is optional, ready for the other care logs.
- **C:** a note field on breast, bottle and solids.
- **D:** `last24h`, `countLast24h`, and gaps over 24 h. The stat reads "N feeds in 24 h".
- **E:** the "Same as last: Breast, right" chip (`ppFeedRepeat`, `ppFeedRepeatLabel`), with Undo.
- **F:** the save toast offers "Remind me in 3h". It asks for notification permission, uses one id (`kPpFeedReminderId`), and if notifications are refused shows a gentle toast instead of tapping silently.
- **G:** patterns come from her data only. The fixed lines are commented out for revert.
- **H:** `lib/services/pp_use_consent.dart` (store, local) + `lib/screens/post_pregnancy/pp_use_ask_card.dart` + the "What ParentVeda uses" section in You › Data and privacy (parenting only) + boot in `main.dart`.
- **I:** `pp_relevance.dart` reads `formulaLast24h` / `breastMilkLast24h`, and only after a yes. An expressed bottle no longer counts as formula.
- **Tests:** `test/pp_feed_tool_test.dart` (8). Neighbouring suites: 134 pass. Analyze is clean on all 9 files.

## Backend closed (2026-10-25, the user's word)
- Consent answers sync: `PpUseConsent` on `CloudMergedStore` (key `pp_use_consent`, one item per kind). Test: `test/pp_use_consent_sync_test.dart`.
- BACKEND-PATTERNS §16ll written (filter by owner at read time; consent as its own store). Sync log step 15 + STILL-OPEN-BACKEND row 15.
- Nappies, Pumping, Sleep and Tummy time had the same read bug: fixed the same day in 02-07, through `ChildLogLedger.belongsTo`.
