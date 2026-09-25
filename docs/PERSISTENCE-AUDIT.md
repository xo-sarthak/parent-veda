# Persistence audit — what a mother does in a pregnancy door, kept

**2026-09-23.** The user: *"make sure every wiring is done for the doors we have
covered, because we want a personalised experience for the mother who is
pregnant right now… if she wishlists something or likes something, if she saves
something, bookmarks something, whatever it is — we should be able to have
it."*

The test for every action is four questions, in order:

1. **Does it reach a store?** (Or does it live in screen state and vanish?)
2. **Does the store save it on the phone?** (`shared_preferences`)
3. **Does it reach her account?** (Supabase — a row, or a `user_state` blob)
4. **Does it come back where she would look for it?** (Saved, the door, the home)

The fourth is the one that failed. Nothing looked wrong until she went looking.

Held by `test/persistence_audit_test.dart` and `test/symptoms_door_test.dart`.

---

## Found and fixed

| What she did | What happened | Fixed by |
|---|---|---|
| **Bookmarked any door read** — a symptom, a scan, a finding, a Complications condition, a nutrient, a stage, a diet condition, a question, a fasting page, Belly & skin, Mind & mood, an "Is this normal?" answer | Saved (to `SavedStore`, synced) — then **could never be opened again**, and listed as "Saved item". The Saved screen resolved ids from one library (the written pregnancy reads); twelve door-built read families were invisible to it, and the title lookup knew the same one library. | `pvDoorEntryForReadId` (router) maps a read id back to the door entry that opens it, reusing the door's own entry opener. The reader now saves the title it is showing. Cravings and Is-it-safe reads have their own openers. |
| **Saved a recipe** (the heart, since e9d8ac8) | Saved and synced — and `SavedKind.recipe` returned *no title, cannot open*. | The Saved screen resolves and opens recipes. |
| **"Log how today feels"** on the pregnancy home | Opened the retired 12-symptom companion, not the Symptoms door. | Opens the door on Today. |
| **"You logged…"** card on the home | For any of the 21 new symptoms the card drew and **the tap did nothing** — the handler searched the old 12. | `symptomById` + the symptom's read. |
| The `symptoms` surface, the Tools hub, global search | All opened the old companion; the door was reachable only from its home tile. | `pvDoorScreenForBracket` — one opener for any door. |
| **Added one ingredient**, then tapped the recipe's list button (found on the phone) | The button read "any ingredient on the list" as "the recipe is on the list", showed ✓ On your list — and **tapping it removed every ingredient**, including the ones she had chosen. A save that a single tap could silently undo. | The button has three states: none → add everything; some → "Add the other n" (only ever adds); all → "All on your list", the only state where a tap removes, and it says so. |
| **Garbh Samvad choices** (which categories, which traditions) | Phone-only, **no reason stated** — gone on a new phone. | `ReadToBabyStore` syncs through `CloudSyncedStore`. |
| **Interested / not interested** on spiritual reads | Phone-only, no reason stated. | `SpiritualPrefsStore` syncs the same way. |
| **Wrote a journal memory with a place** | The place never reached the cloud (no column, not in the row) and a sync then erased it on her phone too. An offline edit was overwritten by the older cloud copy; an offline delete came back. Same in the father's journal. | `journal_sync.dart`: one row mapping with `place` (migration 0091), newer-wins merge, tombstones, seen ids (2026-09-23). |
| **Ticked a Garbh practice done** (home or door) | Only favourites and the streak synced; today's ticks stayed on the phone. | `GarbhStore.cloudData` carries `done` + `doneDate` (2026-09-23). |

---

## Verified, and working

| Area | Store | Kept on phone | Her account |
|---|---|---|---|
| Symptom logs, strength, day edits | `SymptomStore` | ✓ | ✓ rows (`setOn`/`unlogOn` update + delete) |
| Evening reminder | `ReminderStore` | ✓ | ✓ |
| Every save — reads, recipes, products, Is-it-safe, videos | `SavedStore` | ✓ | ✓ rows |
| Plate ticks, swaps, water, **shopping list**, diet prefs | `NutritionDayStore`, `FamilyProfileStore` | ✓ | ✓ blobs |
| Scans, reports locker | `ScansStore`, `ScanReportsStore` | ✓ | ✓ |
| Garbh rituals + streak | `GarbhStore` | ✓ | ✓ |
| Garbh Samvad bookmarks | `ReadToBabySavedStore` → Saved (`readToBaby`, body cached so it opens offline) | ✓ | ✓ |
| Kick counter, contractions, tools | `ToolsStore` | ✓ | ✓ |
| Bump photos + favourites | `BumpStore` | ✓ | ✓ |
| Hospital bag | `HospitalBagV2Store` | ✓ | ✓ |
| Due date | `PregnancyController` | ✓ | ✓ `profiles.due_date`, read back at sign-in |

Every store that uses the `CloudSyncedStore` mixin was checked for a **live**
`syncStateFromCloud()` call — the mixin only starts pushing after it, so a store
without one looks synced in code and never uploads. All pregnancy-side stores
have it. (`CanIStore` does not — it is a facade over `SavedStore`, which syncs;
its mixin is vestigial.) `GarbhStore.toggleFav` has **no callers** — dead API,
so no favourite is lost through it; Garbh saves go through
`ReadToBabySavedStore`.

---

## Local on purpose — the user's call

These say in their own files why they stay on the phone. The audit does not
overrule a documented decision; it puts it back in front of the person who owns
it.

- **Birth plan** (`BirthPlanStore`) — *"the most personal thing the stage
  stores… the way it leaves the phone is by her hand"* (the share sheet). The
  cost: **a new phone loses it.**
- **Questions to take to a scan** (`PvChecklistStore`) — same reasoning. Same
  cost.
- **Reading progress** (`PvReadStore`) — deliberately unsynced for now
  (STILL-OPEN §9.7). Bookmarks moved to `SavedStore` and do sync.
- **Garbh journal** (`GarbhJournalStore` — entries, rituals, japa, voice
  recordings) — phone-only, and NOT by a stated decision: the recordings need
  a private storage bucket first. STILL-OPEN §76.4.
- **Size-comparison set** (`PregSizeSetStore`) — a display preference, "not
  about her pregnancy".

## Owed — needs a backend change

- **The due date's SOURCE does not sync** — only the date. Whether it came
  from a scan, a transfer or her doctor stays on the old phone, so on a new
  phone `DueDateSource` is `unknown` and the clinical rule "a clinic-owned date
  is not ours to second-guess" quietly stops holding. Needs
  `profiles.due_date_source` (a migration) and a read-back at sign-in.
- `PregnancyController.setDueDate` writes Supabase directly, not through
  `supabase_repo.dart` (CLAUDE.md: the repo is the only way in).
