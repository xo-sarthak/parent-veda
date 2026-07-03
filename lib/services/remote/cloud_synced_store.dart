// =============================================================================
//  CloudSyncedStore — one-blob-per-user cloud sync for the light stores
// -----------------------------------------------------------------------------
//  A reusable mixin for the many small "saved / liked / preference" stores. It
//  keeps the store's LOCAL shared_preferences behaviour exactly as-is and layers
//  cloud sync on top, following the app's local-first rule:
//
//    * On startup: call [syncStateFromCloud] once (after loading the local
//      cache). If the cloud already has a blob for this user+store, adopt it
//      (cloud wins) and refresh the local cache; otherwise seed the cloud from
//      local. Logged out → it's a no-op and the app runs from local as before.
//    * On every change afterwards: the store already calls notifyListeners();
//      this mixin overrides that to ALSO push the latest blob up. So we don't
//      have to hunt down every mutation site — one override covers them all.
//
//  A store adopts it by:  `class FooStore extends ChangeNotifier with
//  CloudSyncedStore`, implementing [cloudKey] / [cloudData] / [applyCloudData]
//  / [persistLocalCache], and awaiting [syncStateFromCloud] at the end of init.
// =============================================================================

import 'package:flutter/foundation.dart';

import 'supabase_repo.dart';
import 'sync_registry.dart';

mixin CloudSyncedStore on ChangeNotifier {
  // Guards the auto-push: stays false until the first cloud sync finishes, so
  // the notifyListeners() calls fired while LOADING the local cache don't push
  // stale/empty local state up and clobber the cloud before we've read it.
  bool _cloudReady = false;

  /// The per-store key this blob lives under in the user_state table.
  String get cloudKey;

  /// Serialize the store's current state to a json-encodable blob (Map/List) —
  /// typically the same structure it writes to shared_preferences.
  Object cloudData();

  /// Adopt a blob previously produced by [cloudData] into the store's state.
  void applyCloudData(Object data);

  /// Write the store's current in-memory state to its shared_preferences cache
  /// (called after adopting the cloud blob, so offline reads match).
  Future<void> persistLocalCache();

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (_cloudReady && SupabaseRepo.isLoggedIn) {
      // Fire-and-forget; never let a network hiccup break the UI.
      SupabaseRepo.saveState(cloudKey, cloudData()).catchError((_) {});
    }
  }

  /// Run once at startup, after the local cache has been loaded.
  Future<void> syncStateFromCloud() async {
    SyncRegistry.register(syncStateFromCloud);
    if (SupabaseRepo.isLoggedIn) {
      try {
        final data = await SupabaseRepo.loadState(cloudKey);
        if (data != null) {
          applyCloudData(data); // cloud wins
          await persistLocalCache();
        } else {
          await SupabaseRepo.saveState(cloudKey, cloudData()); // seed from local
        }
      } catch (_) {/* offline — keep local */}
    }
    _cloudReady = true;
    // Reflect the adopted state WITHOUT re-pushing (use the base notifier).
    super.notifyListeners();
  }
}
