// =============================================================================
//  SyncRegistry - re-run every store's cloud sync at once (e.g. after login)
// -----------------------------------------------------------------------------
//  Stores normally sync from the cloud ONCE, at startup. If someone logs in
//  AFTER that (fresh install, or after a sign-out), their data wouldn't load
//  until the app restarted. Each store registers its "sync from cloud" function
//  here (the first time it runs); after a login we call resyncAll() so the
//  freshly-signed-in user's data loads immediately - no restart.
//
//  Every registered syncer already no-ops when logged out and is safe to run
//  repeatedly (they merge / cloud-wins), so calling resyncAll() is harmless.
// =============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../auth/local_owner.dart';

class SyncRegistry {
  SyncRegistry._();

  // ---- resets (2026-10-17) ----------------------------------------------------
  //
  // ⚠️ SIGNING OUT USED TO LEAVE THE LAST PERSON'S DATA IN MEMORY, and the next
  // account to sign in on the phone uploaded it into ITS account: every store
  // is a singleton, a sign-out only cleared the auth flag, and the next login's
  // [resyncAll] merged and pushed whatever the stores still held. Every store
  // that syncs now registers a reset here, next to its syncer, and a sign-out
  // or a different account signing in runs all of them after the local cache
  // is wiped (`LocalOwner`). `test/sync_reset_coverage_test.dart` fails the
  // build if a syncing store registers no reset.
  static final List<VoidCallback> _resets = [];

  /// Register a store's "forget everything in memory" (deduped).
  static void registerReset(VoidCallback reset) {
    if (!_resets.contains(reset)) _resets.add(reset);
  }

  /// Empty every registered store. Best-effort: one store that throws does
  /// not stop the others.
  static void resetAll() {
    for (final r in List.of(_resets)) {
      try {
        r();
      } catch (_) {/* keep going */}
    }
  }

  static final List<Future<void> Function()> _syncers = [];

  /// Stores that can say "I still have changes the cloud has not confirmed"
  /// (2026-10-17). Read by the sign-out dialog and Settings.
  static final List<bool Function()> _pending = [];

  /// Register a store's "changes waiting to upload" check (deduped).
  static void registerPending(bool Function() pending) {
    if (!_pending.contains(pending)) _pending.add(pending);
  }

  /// True when any store holds changes the cloud has not confirmed yet.
  static bool get hasPendingChanges {
    for (final p in _pending) {
      try {
        if (p()) return true;
      } catch (_) {/* a store that cannot answer has nothing pending */}
    }
    return false;
  }

  static DateTime? _lastResync;

  /// [resyncAll] when the app comes back to the screen, at most once a
  /// minute (2026-10-17). Before this, a change made on another phone showed
  /// only after this one was closed and reopened.
  static Future<void> resyncOnResume({DateTime? now}) async {
    final t = now ?? DateTime.now();
    final last = _lastResync;
    if (last != null && t.difference(last) < const Duration(minutes: 1)) {
      return;
    }
    _lastResync = t;
    await resyncAll();
  }

  /// Register a store's cloud-sync function (deduped - safe to call repeatedly).
  static void register(Future<void> Function() syncer) {
    if (!_syncers.contains(syncer)) _syncers.add(syncer);
  }

  /// Re-run every registered store sync, best-effort, one after another.
  ///
  /// First it makes sure the phone's data belongs to the account that is
  /// signed in (2026-10-17): a different account's data is wiped and every
  /// store emptied BEFORE anything is merged or uploaded.
  static Future<void> resyncAll() async {
    try {
      await LocalOwner.ensureCurrent();
    } catch (_) {/* never block a sync on the check */}
    for (final syncer in List.of(_syncers)) {
      try {
        await syncer();
      } catch (_) {/* keep going */}
    }
  }
}
