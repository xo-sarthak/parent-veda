// =============================================================================
//  TTC cloud sync
// -----------------------------------------------------------------------------
//  The cloud half of the TTC stores. Local-first, exactly like the rest of the
//  app: every store shows its cached data instantly, syncs afterwards, and a
//  cloud failure is never a crash.
//
//  ---------------------------------------------------------------------------
//  WHY NOT CloudSyncedStore
//
//  The house mixin syncs one JSON blob per user into `user_state`, which is
//  own-row. That is right for "saved / liked / preference" stores and wrong
//  here, because half of the TTC data is COUPLE-SCOPED by design: the shared
//  journal, the supplements list, the daily ritual and the family timeline all
//  have to be readable by the partner, and a blob keyed to one user cannot be.
//
//  So these stores sync to the real tables in 0041_ttc.sql and let RLS do the
//  scoping - `fetchShared` for the couple-scoped tables, `fetch` for her
//  own-row ones. Her raw cycle stays own-row in both directions; her partner
//  reads the DERIVED chapter from ttc_journeys instead.
//
//  ---------------------------------------------------------------------------
//  MERGE RULE: union by id, newest wins on conflict.
//
//  Deliberately NOT cloud-wins. Cloud-wins is fine for a preference blob and
//  wrong for a journal: an entry written on a plane would be silently deleted
//  the moment the phone reconnected. Every row here carries an app-generated
//  id, which is what makes the union trivial and idempotent.
//
//  The one exception is ttc_journeys, which is genuinely one row of settings
//  and where last-write-wins is correct.
//
//  ⚠️ 2026-10-17: "newest wins" was written here and never built. The pull
//  was a union and every push re-sent every row, so another phone that still
//  held an old value pushed it back over an edit or a removal. Her cycle
//  (CycleStore) and her daily log (TtcLogStore) now carry the edit time and a
//  soft delete per row (0097), merge with `ttc_row_merge.dart`, and upload
//  only what changed, confirmed. This mixin now runs ONE upload at a time and
//  runs one more when a change lands mid-upload, so a slow upload can no
//  longer write back a row deleted while it was in flight.
// =============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/remote/supabase_repo.dart';
import '../services/remote/sync_registry.dart';
import '../services/pv_sync_health.dart';

/// Table names, in one place so a rename is one edit.
class TtcTables {
  TtcTables._();
  static const journeys = 'ttc_journeys';
  static const cycles = 'ttc_cycles';
  static const signals = 'ttc_cycle_signals';
  static const logs = 'ttc_logs';
  // The journal left Trying to Conceive on 2026-09-28 and nothing syncs this
  // table any more. The name stays because the table and its rows stay (the
  // user: no need to preserve them, and no reason to drop them either), and
  // the schema contract and 0092's backfill still name it.
  static const journal = 'ttc_journal';

  /// The questions she saves for her doctor (0092). Their own table since
  /// 2026-09-28; before that they were journal rows of kind `question`.
  static const doctorQuestions = 'ttc_doctor_questions';
  static const supplements = 'ttc_supplements';
  static const supplementTaken = 'ttc_supplement_taken';
  static const ritual = 'ttc_ritual';
  static const timeline = 'journey_timeline';
}

/// Shared plumbing for a TTC store that syncs to real rows.
///
/// A store adopts it with `with TtcSyncedStore`, implements [pullFromCloud] and
/// [pushToCloud], and awaits [syncFromCloud] once after loading its local cache.
mixin TtcSyncedStore on ChangeNotifier {
  // Stays false until the first pull finishes, so the notifyListeners() fired
  // while loading the LOCAL cache cannot push half-loaded state up and clobber
  // rows the cloud already has.
  bool _cloudReady = false;
  Timer? _pushTimer;

  /// An upload is running; a change during it asks for one more after it.
  bool _pushing = false;
  bool _pushAgain = false;
  bool _pendingRegistered = false;

  /// Row writes are heavier than a blob upsert, and several TTC surfaces change
  /// many times in a few seconds - ticking five ritual parts, stepping a weight
  /// value. Coalesce them into one round of writes.
  Duration get pushDebounce => const Duration(milliseconds: 700);

  /// Read this user's (and where allowed, the partner's) rows and merge them
  /// into local state. Must be safe to run repeatedly.
  Future<void> pullFromCloud();

  /// Write local state up. Must be idempotent - it re-runs on every change.
  Future<void> pushToCloud();

  /// Write the store's current in-memory state to its local cache, so an
  /// offline read matches what the cloud just gave us.
  Future<void> persistLocalCache();

  /// Forget everything in memory: a sign-out, or another account signing in
  /// (2026-10-17). The local cache has already been wiped by then. Required,
  /// so a new TTC store cannot leave a person's data behind for the next.
  void resetLocal();

  void _resetForAccount() {
    _pushTimer?.cancel();
    _cloudReady = false;
    resetLocal();
  }

  @visibleForTesting
  bool get cloudReady => _cloudReady;

  /// True while this store holds changes the cloud has not confirmed. Stores
  /// that track it (CycleStore, TtcLogStore) override this; the sign-out
  /// dialog and Settings read it through [SyncRegistry.hasPendingChanges].
  bool get hasPendingPush => false;

  /// Runs [pushToCloud], one at a time. A call that arrives while an upload
  /// is running is folded into one more run after it.
  Future<void> runPush() async {
    if (_pushing) {
      _pushAgain = true;
      return;
    }
    _pushing = true;
    try {
      do {
        _pushAgain = false;
        await pushToCloud();
      } while (_pushAgain);
    } finally {
      _pushing = false;
    }
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (!_cloudReady || !SupabaseRepo.isLoggedIn) return;
    _pushTimer?.cancel();
    _pushTimer = Timer(pushDebounce, () {
      // Fire-and-forget. A network hiccup must never reach the UI, and the
      // local cache is already correct - the next sync recovers a lost push.
      // One at a time since 2026-10-17 (`runPush`). Kept for revert:
      //   pushToCloud().catchError(PvSyncHealth.report);
      runPush().catchError(PvSyncHealth.report);
    });
  }

  @override
  void dispose() {
    _pushTimer?.cancel();
    super.dispose();
  }

  /// Run once at startup, after the local cache is loaded. Registers itself so
  /// a LATER login re-syncs without an app restart.
  Future<void> syncFromCloud() async {
    SyncRegistry.register(syncFromCloud);
    // Once per store: a fresh closure each call would never dedupe.
    if (!_pendingRegistered) {
      _pendingRegistered = true;
      SyncRegistry.registerPending(() => hasPendingPush);
      SyncRegistry.registerReset(_resetForAccount);
    }
    if (SupabaseRepo.isLoggedIn) {
      try {
        await pullFromCloud();
        await persistLocalCache();
        // Seed the cloud with anything local that it did not have. Safe because
        // every write here is an upsert keyed by an app-generated id.
        await runPush();
      } catch (e) {
        // Offline - keep local, try again on the next resume or login.
        PvSyncHealth.report(e);
      }
    }
    _cloudReady = true;
    // Reflect the merged state WITHOUT re-pushing.
    super.notifyListeners();
  }

  /// Testing hook: pretend the first sync has happened (or has not).
  @visibleForTesting
  void setCloudReadyForTest(bool ready) => _cloudReady = ready;
}

/// Helpers shared by the TTC stores' row mapping.
class TtcSyncUtil {
  TtcSyncUtil._();

  /// "yyyy-mm-dd" — the shape every date column here uses.
  static String date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime? parseDate(Object? v) {
    final s = v?.toString();
    if (s == null || s.isEmpty) return null;
    final d = DateTime.tryParse(s);
    return d == null ? null : DateTime(d.year, d.month, d.day);
  }

  /// One row, and whether the cloud took it (2026-10-17). The stores that
  /// track what is waiting to upload keep a row waiting until this is true.
  static Future<bool> upsertConfirmed(
    String table,
    Map<String, dynamic> row, {
    String? onConflict,
  }) =>
      SupabaseRepo.upsertRowConfirmed(table, row, onConflict: onConflict);

  /// The time a row changed, in the shape the timestamp columns take.
  static String stamp(DateTime t) => t.toUtc().toIso8601String();

  /// Upsert many rows one table at a time, swallowing individual failures so a
  /// single bad row cannot stop the rest of a sync.
  static Future<void> upsertAll(
    String table,
    List<Map<String, dynamic>> rows, {
    String? onConflict,
  }) async {
    for (final row in rows) {
      await SupabaseRepo.upsertRow(table, row, onConflict: onConflict);
    }
  }
}
