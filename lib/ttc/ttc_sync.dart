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
// =============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/remote/supabase_repo.dart';
import '../services/remote/sync_registry.dart';

/// Table names, in one place so a rename is one edit.
class TtcTables {
  TtcTables._();
  static const journeys = 'ttc_journeys';
  static const cycles = 'ttc_cycles';
  static const signals = 'ttc_cycle_signals';
  static const logs = 'ttc_logs';
  static const journal = 'ttc_journal';
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

  @visibleForTesting
  bool get cloudReady => _cloudReady;

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (!_cloudReady || !SupabaseRepo.isLoggedIn) return;
    _pushTimer?.cancel();
    _pushTimer = Timer(pushDebounce, () {
      // Fire-and-forget. A network hiccup must never reach the UI, and the
      // local cache is already correct - the next sync recovers a lost push.
      pushToCloud().catchError((_) {});
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
    if (SupabaseRepo.isLoggedIn) {
      try {
        await pullFromCloud();
        await persistLocalCache();
        // Seed the cloud with anything local that it did not have. Safe because
        // every write here is an upsert keyed by an app-generated id.
        await pushToCloud();
      } catch (_) {/* offline - keep local, try again after the next login */}
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
