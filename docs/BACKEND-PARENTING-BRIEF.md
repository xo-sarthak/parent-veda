# Backend brief — the parenting side

Written 18 July 2026, after the parenting app reached feature-complete for
review. This is a handover to whoever is doing backend work. It assumes you
already know `supabase/BACKEND-PLAN.md`, `CloudSyncedStore`, `SyncRegistry` and
the `user_state` table — this brief is only about what the PARENTING side needs
and what has changed under you.

---

## 1. The headline

**Eighteen parenting stores have no cloud sync at all.** The pregnancy side has
around twenty that do. Everything a parent enters on the parenting side today —
her child's measurements, vaccine doses, feeds, sleeps, milestones, documents —
lives only in `shared_preferences` on one device. Reinstall the app and it is
gone. Change phones and it is gone. Pair a second parent and they see nothing.

That is the gap. Nothing else in this brief matters as much.

### The stores, by what is lost if they never sync

**Tier 1 — parent-entered data. Losing this loses her record of her child.**

| Store | File | Holds |
|---|---|---|
| `ChildProfileStore` | `pp_child_profile.dart` | Name, sex, DOB, weight/height/head. **The keystone — every other row keys to a child_id from here.** Already in flight; see §4. |
| `HealthStore` | `pp_health_data.dart` | Doctor visits, medications, prescriptions, allergies, symptoms, reports, questions |
| `GrowthStore` | `pp_growth_data.dart` | Logged measurements over time |
| `VaxStore` | `pp_vaccine_data.dart` | Which doses are marked done |
| `FeedingStore` | `pp_feeding_data.dart` | Feed logs |
| `SleepStore` | `pp_sleep_data.dart` | Sleep logs |
| `MilestoneStore` | `pp_milestones_data.dart` | Milestones observed, with her notes — these are memories, not checkboxes |
| `BabyDocumentsStore` | `pp_documents_data.dart` | Birth certificate, Aadhaar, records |
| `PpTrackerStore` | `pp_trackers_data.dart` | The everyday trackers |

**Tier 2 — preferences and progress. Losing this is annoying, not tragic.**

`DevStore` (saved activities), `ReadingStore` (reading progress), `WatchStore`
(watch progress, saved videos), `RecoStore` (saved picks, wishlists), `FoodStore`
(veg-only preference, saved recipes), `NameMatchStore` / `NameVersionStore`,
`YogaStore` (bookings).

**Tier 3 — genuinely transient, do not sync.**

`PpCompareStore` — the current compare selection. It is a scratchpad.

### Suggested order

Tier 1 in the order listed. `ChildProfileStore` first because everything else
keys to it, then Health and Growth because those are what a parent would be
most upset to lose, then the rest.

---

## 2. The contract you are implementing against

Already built, already proven on ~20 pregnancy stores. Per store:

```dart
class XStore extends ChangeNotifier with CloudSyncedStore {
  @override String get cloudKey => 'x_store';
  @override Object cloudData() => _toMap();
  @override void applyCloudData(Object data) => _apply(data as Map);
  @override Future<void> persistLocalCache() async { /* write to prefs */ }

  Future<void> init() async {
    /* load from prefs first — local-first, instant, offline-safe */
    notifyListeners();
    try {
      await syncStateFromCloud();
    } catch (_) {/* stay local; a cloud hiccup must never break init */}
  }
}
```

Two rules that are not negotiable, because the pregnancy side already depends
on them:

1. **Local-first.** Read prefs and `notifyListeners()` BEFORE touching the
   network. The app must open instantly and work offline.
2. **A cloud failure is never a crash.** Every `syncStateFromCloud()` call is
   wrapped in try/catch. A logged-out user, a dead network or a Supabase
   outage degrades to local-only, silently.

`user_state` (migration `0011`) is a per-user key/value table and is where most
of these should land. Only promote a store to its own table when you need to
query INTO it — Health and Growth probably qualify eventually; most do not.

---

## 3. Two seams built specifically for you

These are front-end work already done, deliberately shaped so the backend drops
in without touching any screen.

### 3a. Health "has she entered anything?"

`pp_health_data.dart` now carries:

```dart
bool get growthEntered;   // set by a logged measurement
bool get vaxEntered;      // set by a marked dose
bool get hasAnyEntry;     // any of the above, or visits/reports
```

**Why they exist:** the health snapshot, growth figures and vaccination status
are seed CONSTANTS (`kHealthSnapshot`, `kGrowth`, `kVaxStatus`). The app could
not tell a parent who had logged nothing from one who had logged everything —
which is how "Overall: good" got shown to someone who had never entered a
thing. Every health section now renders either her real data or an invitation
to add it, driven by these flags.

**What you change:** only the derivation. Make them read real rows instead of
local writes. **No screen has to change**, and there is a test asserting both
states render.

### 3b. Profile analytics sink

`docs/PERSONALIZATION.md` §10 carries the full `profile_events` table DDL, the
RLS note (insert-only; never read back to a client), why there is no `user_id`,
and the three SQL queries it needs to answer.

`ProfileAnalyticsRecord.toMap()` already emits exactly those column names, so
the sink is a straight insert with no mapping layer. Wiring is one line:

```dart
ProfileAnalytics.instance.setSink(SupabaseProfileSink());
```

There is a test asserting a throwing sink cannot break a session. Keep that
true.

---

## 4. What is blocking right now

`lib/screens/post_pregnancy/pp_child_profile.dart` has been modified in the
working tree for several days and is **not committed**. Meanwhile commit
`6c59332` (UI harmonisation) is committed and calls `_store.children` and
`_store.switchTo(id)` — the multi-child API that only exists in that
uncommitted file.

**Effect:** the branch tip does not build from a clean checkout. Local working
trees are fine because the file is present on disk; a fresh clone or a CI run
is not. This has been true for six commits now.

**Fix:** commit `pp_child_profile.dart`. Nothing else is needed.

---

## 5. Invariants to preserve

Things the front end now guarantees that a backend change could quietly break.

- **A feature is never hidden for being empty** (`docs/PERSONALIZATION.md` §3).
  A section with no data renders its header and a call-to-action, never
  nothing. When you make the health flags read real rows, an empty result must
  still produce the invitation state — not an absent section.
- **Personalization influences content, recommendations and ordering only** —
  never navigation. There are invariant tests. Do not let a sync introduce a
  "this user does not have X so hide the tab" shortcut.
- **Seed data is not user data.** Several parenting data files ship demo
  content (Aarav, `kHealthSnapshot`, `kGrowth`, `kVaxVisits`, the recipe
  catalogue). When real rows arrive, seed content must be distinguishable —
  otherwise every user inherits a fictional four-month-old's medical history.
  This is the single most likely way to ship something embarrassing.
- **Co-parenting.** A child row is shared by BOTH paired parents — one row per
  baby, not one per parent — and either may edit it. Already noted in
  `0021_children.sql`.

---

## 6. Not in scope

- **Google sign-in.** Currently broken; it is OAuth console configuration
  (Google Cloud client IDs, Supabase auth provider, Android SHA-1), not app
  code. The product owner is handling it.
- **Pregnancy-side stores.** Already synced, already working. Leave them.
- **The `profile_events` analytics table** is spec'd but low priority — it has
  no users to measure yet. Do it when there is a tester cohort.

---

## 7. How to verify you have not broken anything

```
flutter analyze     # must be clean
flutter test        # 349 passing as of commit c48ee0e
```

The parenting smoke suite (`test/post_pregnancy_smoke_test.dart`) drives most
parenting screens end to end and will catch a store whose `init()` starts
throwing. `test/pp_ui_harmony_test.dart` covers the reworked My Child home.

If you change a store's `_toMap()` / `_apply()` shape, check whether an
existing user's cached prefs still decode — silently dropping a field is how a
parent loses data without an error ever appearing.
