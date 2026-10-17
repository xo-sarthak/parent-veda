// =============================================================================
//  CloudSyncedStore - one-blob-per-user cloud sync for the light stores
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
//      have to hunt down every mutation site - one override covers them all.
//
//  A store adopts it by:  `class FooStore extends ChangeNotifier with
//  CloudSyncedStore`, implementing [cloudKey] / [cloudData] / [applyCloudData]
//  / [persistLocalCache], and awaiting [syncStateFromCloud] at the end of init.
// =============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'supabase_repo.dart';
import 'sync_registry.dart';
import '../pv_sync_health.dart';

// =============================================================================
//  ⚠️ PUSH BEFORE PULL (2026-10-17, STILL-OPEN-BACKEND §2, sync log step 3)
// -----------------------------------------------------------------------------
//  The sync below is "cloud wins": whenever the cloud has a blob, the phone
//  takes it. That is right on a fresh install and WRONG for a phone holding a
//  change the cloud never got. The push on every change was fire-and-forget,
//  so a change made offline failed to upload, nothing retried it, and the next
//  resume or launch replaced it with the cloud's older blob: the change was
//  gone without a word.
//
//  So the mixin now remembers, per store and on disk, that a change is
//  WAITING. A change marks it; an upload the server confirms, of the newest
//  state, clears it. A sync that finds a store waiting uploads the phone's
//  blob first instead of taking the cloud's.
//
//  The trade-off, named: this is still one blob per store, so with two phones
//  the one whose change is waiting wins whole, and an edit made on the other
//  phone meanwhile is overwritten. Before, the offline phone always LOST, and
//  silently. Per-item merge inside the blob, for the lists people curate, is
//  the later fix (§2).
// =============================================================================

/// The three cloud calls the mixin makes, swappable so a test can play an
/// offline phone and a cloud holding an older blob (2026-10-17). The same
/// shape as `TtcAppointmentsStore.schedulePhone`.
@visibleForTesting
class CloudBlobIo {
  CloudBlobIo._();
  static bool Function() isLoggedIn = () => SupabaseRepo.isLoggedIn;
  static Future<dynamic> Function(String key) load = SupabaseRepo.loadState;
  static Future<void> Function(String key, Object data) save =
      SupabaseRepo.saveState;

  static void restore() {
    isLoggedIn = () => SupabaseRepo.isLoggedIn;
    load = SupabaseRepo.loadState;
    save = SupabaseRepo.saveState;
  }
}

mixin CloudSyncedStore on ChangeNotifier {
  // Guards the auto-push: stays false until the first cloud sync finishes, so
  // the notifyListeners() calls fired while LOADING the local cache don't push
  // stale/empty local state up and clobber the cloud before we've read it.
  bool _cloudReady = false;

  Timer? _pushTimer;

  // ---- what is waiting to upload (2026-10-17) ---------------------------------
  /// A change the cloud has not confirmed. Kept on disk, so a change made
  /// offline survives the app being closed before it could upload.
  bool _waiting = false;
  bool _waitingLoaded = false;

  /// Counts changes, so an upload clears [_waiting] only when nothing changed
  /// while it was in flight.
  int _editSeq = 0;

  /// One upload at a time: two overlapping uploads could land out of order
  /// and leave the cloud with the OLDER blob.
  bool _pushing = false;
  bool _pushAgain = false;

  bool _pendingRegistered = false;

  String get _waitingKey => 'pv_blob_waiting_$cloudKey';

  /// True while this store holds a change the cloud has not confirmed. Read
  /// by the sign-out sheet and Settings through `SyncRegistry`.
  bool get cloudChangeWaiting => _waiting;

  bool _isWaiting() => _waiting;

  void _setWaiting(bool v) {
    if (_waiting == v && _waitingLoaded) return;
    _waiting = v;
    _waitingLoaded = true;
    SharedPreferences.getInstance()
        .then((p) => v ? p.setBool(_waitingKey, true) : p.remove(_waitingKey))
        .catchError((_) => false);
  }

  Future<void> _loadWaiting() async {
    if (_waitingLoaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      _waiting = _waiting || (p.getBool(_waitingKey) ?? false);
    } catch (_) {/* nothing known: nothing waiting */}
    _waitingLoaded = true;
  }

  /// How long to coalesce rapid changes before pushing one blob up.
  ///
  /// Defaults to ZERO - push on every change, exactly as before - so every
  /// existing store keeps its current behaviour untouched. Override it in a
  /// store whose state changes many times a second: WatchStore records the
  /// playback position on every tick, and without this each tick would be its
  /// own Supabase write (network + battery for a value that is only read when
  /// the video is next opened).
  Duration get cloudPushDebounce => Duration.zero;

  /// The per-store key this blob lives under in the user_state table.
  String get cloudKey;

  /// Serialize the store's current state to a json-encodable blob (Map/List) -
  /// typically the same structure it writes to shared_preferences.
  Object cloudData();

  /// Adopt a blob previously produced by [cloudData] into the store's state.
  void applyCloudData(Object data);

  /// The blob of a store nobody has used yet (2026-10-17): what a sign-out,
  /// or another account signing in, resets the store to through
  /// [applyCloudData]. Required, so a new blob store cannot leave a person's
  /// data in memory for the next account to upload.
  Object get cloudEmptyData;

  void _resetForAccount() {
    _pushTimer?.cancel();
    _cloudReady = false;
    // The local cache is wiped by now; nothing of the last person waits.
    _editSeq++;
    _setWaiting(false);
    applyCloudData(cloudEmptyData);
    // Reflect it WITHOUT pushing: there is no account to push to.
    super.notifyListeners();
  }

  /// Write the store's current in-memory state to its shared_preferences cache
  /// (called after adopting the cloud blob, so offline reads match).
  Future<void> persistLocalCache();

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (!_cloudReady || !CloudBlobIo.isLoggedIn()) return;
    _editSeq++;
    _setWaiting(true);
    final wait = cloudPushDebounce;
    if (wait == Duration.zero) {
      _pushNow();
      return;
    }
    // Coalesce a burst into one write. The local cache is already up to date,
    // and the change stays marked waiting until an upload is confirmed, so a
    // push lost to an app close goes on the next sync instead of being
    // replaced by the cloud's older blob (2026-10-17).
    _pushTimer?.cancel();
    _pushTimer = Timer(wait, _pushNow);
  }

  // Kept for revert (2026-10-17): fire-and-forget, success never recorded.
  //   void _pushNow() {
  //     SupabaseRepo.saveState(cloudKey, cloudData()).catchError(PvSyncHealth.report);
  //   }

  /// Uploads the current blob, one upload at a time. Still fire-and-forget
  /// from the caller's side: never awaited by the UI, and a failure stays off
  /// the screen except for one calm offline notice a session (PvSyncHealth).
  /// A failure leaves the change waiting for the next sync.
  void _pushNow() {
    _uploadWaiting().catchError(PvSyncHealth.report);
  }

  Future<void> _uploadWaiting() async {
    if (_pushing) {
      _pushAgain = true;
      return;
    }
    _pushing = true;
    try {
      do {
        _pushAgain = false;
        final seq = _editSeq;
        await CloudBlobIo.save(cloudKey, cloudData());
        if (seq == _editSeq) _setWaiting(false);
      } while (_pushAgain);
    } finally {
      _pushing = false;
    }
  }

  @override
  void dispose() {
    _pushTimer?.cancel();
    super.dispose();
  }

  /// Run once at startup, after the local cache has been loaded.
  Future<void> syncStateFromCloud() async {
    SyncRegistry.register(syncStateFromCloud);
    SyncRegistry.registerReset(_resetForAccount);
    if (!_pendingRegistered) {
      _pendingRegistered = true;
      SyncRegistry.registerPending(_isWaiting);
    }
    if (CloudBlobIo.isLoggedIn()) {
      await _loadWaiting();
      try {
        if (_waiting) {
          // ⚠️ PUSH BEFORE PULL: this phone holds a change the cloud never
          // confirmed, so its blob goes up instead of the cloud's coming
          // down. See the head of this file.
          await _uploadWaiting();
        } else {
          final data = await CloudBlobIo.load(cloudKey);
          if (data != null) {
            applyCloudData(data); // cloud wins
            await persistLocalCache();
          } else {
            await CloudBlobIo.save(cloudKey, cloudData()); // seed from local
          }
        }
      } catch (_) {/* offline - keep local */}
    }
    _cloudReady = true;
    // Reflect the adopted state WITHOUT re-pushing (use the base notifier).
    super.notifyListeners();
  }
}
