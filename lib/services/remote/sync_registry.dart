// =============================================================================
//  SyncRegistry — re-run every store's cloud sync at once (e.g. after login)
// -----------------------------------------------------------------------------
//  Stores normally sync from the cloud ONCE, at startup. If someone logs in
//  AFTER that (fresh install, or after a sign-out), their data wouldn't load
//  until the app restarted. Each store registers its "sync from cloud" function
//  here (the first time it runs); after a login we call resyncAll() so the
//  freshly-signed-in user's data loads immediately — no restart.
//
//  Every registered syncer already no-ops when logged out and is safe to run
//  repeatedly (they merge / cloud-wins), so calling resyncAll() is harmless.
// =============================================================================

class SyncRegistry {
  SyncRegistry._();

  static final List<Future<void> Function()> _syncers = [];

  /// Register a store's cloud-sync function (deduped — safe to call repeatedly).
  static void register(Future<void> Function() syncer) {
    if (!_syncers.contains(syncer)) _syncers.add(syncer);
  }

  /// Re-run every registered store sync, best-effort, one after another.
  static Future<void> resyncAll() async {
    for (final syncer in List.of(_syncers)) {
      try {
        await syncer();
      } catch (_) {/* keep going */}
    }
  }
}
