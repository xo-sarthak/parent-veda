// =============================================================================
//  CloudMergedStore: per-item sync for the light stores
//  (2026-10-22, sync log step 13, migration 0110)
// -----------------------------------------------------------------------------
//  The successor to CloudSyncedStore (cloud_synced_store.dart). That mixin
//  kept one JSON blob per store and a sync replaced the WHOLE blob, so two
//  phones that each ticked a different hospital-bag item erased each other's
//  tick (STILL-OPEN-BACKEND §2). This one keeps the store as ITEMS:
//
//    key -> {v: value, t: edited at (epoch ms), d: removed?}
//
//  and merges item by item, the newer `t` winning. A removal is an item with
//  `d: true` (a tombstone), so it travels to the other phone instead of
//  reading as "never had it".
//
//  WHERE THE MERGE RUNS. On the server, in `pv_state_merge` (0110), inside one
//  locked statement. A phone that read, merged and wrote the blob itself
//  would race another phone doing the same; the lock puts the two in order so
//  neither's items are lost. The phone sends only the items it changed and
//  takes back the whole merged map: one call is the push and the pull.
//  [MergedItems.merge] is the same rule in Dart, kept identical by
//  test/cloud_merged_store_test.dart.
//
//  HOW A STORE ADOPTS IT. The store says what its items are ([cloudItems])
//  and how to take a set of items back ([applyCloudItems]). It never stamps
//  an edit itself: every mutation already calls notifyListeners(), and this
//  mixin compares the items before and after and stamps the ones that
//  changed. One override covers every mutation site, the same trick the old
//  mixin used for its push.
//
//  Choosing items: one item per thing two phones could change separately.
//  A set of ticked ids is one item per id; a map of answers is one item per
//  question; a single setting is one item. Items too coarse bring back the
//  old problem in miniature; items finer than anything a person edits buy
//  nothing.
//
//  THE FIRST RUN on a phone stamps what the store already holds with t = 0,
//  so anything a person really edited, on any phone, beats it, and nothing
//  already on the phone is dropped. A store that used to sync as a whole blob
//  ([legacyBlobKey]) and holds nothing yet reads that old blob first, so a
//  new phone does not start empty. The old blob is left in place, kept for
//  revert.
//
//  ACCOUNTS. Edits made while logged out are stamped and wait; the first
//  sync after sign-in sends them. A sign-out resets the store to empty
//  through [applyCloudItems] with no items.
// =============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pv_sync_health.dart';
import 'supabase_repo.dart';
import 'sync_registry.dart';
import 'sync_row_book.dart';

/// The cloud calls and the clock, swappable so a test can play two phones
/// and a server.
@visibleForTesting
class CloudMergeIo {
  CloudMergeIo._();
  static bool Function() isLoggedIn = () => SupabaseRepo.isLoggedIn;
  static Future<Map<String, dynamic>> Function(
      String key, Map<String, dynamic> items) merge = SupabaseRepo.mergeState;
  static Future<dynamic> Function(String key) loadLegacy =
      SupabaseRepo.loadState;
  static int Function() nowMs = () => DateTime.now().millisecondsSinceEpoch;

  static void restore() {
    isLoggedIn = () => SupabaseRepo.isLoggedIn;
    merge = SupabaseRepo.mergeState;
    loadLegacy = SupabaseRepo.loadState;
    nowMs = () => DateTime.now().millisecondsSinceEpoch;
  }
}

/// The merge rule, the same as `pv_state_merge` in 0110.
class MergedItems {
  MergedItems._();

  /// The server drops tombstones older than this (0109's window).
  static const Duration serverKeep = Duration(days: 90);

  /// The phone drops its settled tombstones sooner (step 12, §16ii-m).
  static Duration get phoneKeep => SyncRowBook.keepRemovals;

  /// A clock this far ahead of the server's is pulled back to it.
  static const int futureSlackMs = 300000;

  static int timeOf(Object? item) {
    if (item is Map) {
      final t = item['t'];
      if (t is num) return t.toInt();
      if (t is String) return num.tryParse(t)?.toInt() ?? 0;
    }
    return 0;
  }

  static bool removedOf(Object? item) => item is Map && item['d'] == true;

  /// Pure: [incoming] merged into [base] item by item. Newer `t` wins, a tie
  /// keeps [base], a `t` from the future is pulled back to [nowMs], and
  /// tombstones older than [keep] are dropped.
  static Map<String, Map<String, dynamic>> merge(
    Map<String, dynamic> base,
    Map<String, dynamic> incoming, {
    required int nowMs,
    Duration keep = serverKeep,
  }) {
    final out = <String, Map<String, dynamic>>{
      for (final e in base.entries)
        if (e.value is Map) e.key: Map<String, dynamic>.from(e.value as Map),
    };
    for (final e in incoming.entries) {
      if (e.value is! Map) continue;
      final v = Map<String, dynamic>.from(e.value as Map);
      var t = timeOf(v);
      if (t > nowMs + futureSlackMs) {
        t = nowMs;
        v['t'] = t;
      }
      final cur = out[e.key];
      if (cur == null || t > timeOf(cur)) out[e.key] = v;
    }
    final cutoff = nowMs - keep.inMilliseconds;
    out.removeWhere((_, v) => removedOf(v) && timeOf(v) < cutoff);
    return out;
  }
}

mixin CloudMergedStore on ChangeNotifier {
  // ---- what the store provides -------------------------------------------------

  /// The store's name in the cloud. Its items live under `<cloudKey>:items`.
  String get cloudKey;

  /// The store's live items, key -> a JSON-encodable value.
  Map<String, Object?> cloudItems();

  /// Take these live items as the store's whole state (an empty map means
  /// empty). Called after a merge and on sign-out; it must not write to the
  /// cloud itself, and the mixin persists afterwards via [persistLocalCache].
  void applyCloudItems(Map<String, Object?> items);

  /// Write the in-memory state to the store's own prefs cache.
  Future<void> persistLocalCache();

  /// How long to gather a burst of changes before one merge. Zero merges on
  /// every change.
  Duration get cloudPushDebounce => Duration.zero;

  /// The key this store's whole blob was synced under before step 13, or
  /// null for a store that never synced. Read once, on a phone that holds
  /// nothing yet, through [applyLegacyBlob].
  String? get legacyBlobKey => null;

  /// Take an old whole blob (the format [legacyBlobKey] holds).
  void applyLegacyBlob(Object blob) {}

  // ---- the book ------------------------------------------------------------------

  final Map<String, Map<String, dynamic>> _book = {};
  final Set<String> _dirty = {};
  Map<String, String> _snap = {};
  bool _bookLoaded = false;
  bool _seeded = false;
  bool _ready = false;
  bool _applying = false;
  bool _merging = false;
  bool _again = false;
  bool _registered = false;
  Timer? _timer;

  String get _itemsKey => '$cloudKey:items';
  String get _bookKey => mergedBookKey;

  /// Where this phone keeps the book. Only a test playing two phones in one
  /// process needs to change it.
  String get mergedBookKey => 'pv_merged_$cloudKey';

  /// True while a change here has not been confirmed by the cloud. The
  /// sign-out sheet reads it through SyncRegistry.
  bool get mergedChangeWaiting => _dirty.isNotEmpty;

  @visibleForTesting
  Map<String, Map<String, dynamic>> get debugBook => _book;

  bool _isWaiting() => _dirty.isNotEmpty;

  Future<void> _loadBook() async {
    if (_bookLoaded) return;
    _bookLoaded = true;
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_bookKey);
      if (raw == null) return;
      final m = jsonDecode(raw);
      if (m is! Map) return;
      _seeded = m['seeded'] == true;
      final items = m['items'];
      if (items is Map) {
        for (final e in items.entries) {
          if (e.value is Map) {
            _book[e.key.toString()] = Map<String, dynamic>.from(e.value as Map);
          }
        }
      }
      final dirty = m['dirty'];
      if (dirty is List) _dirty.addAll(dirty.map((e) => e.toString()));
    } catch (_) {/* start with an empty book */}
  }

  Future<void> _saveBook() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(
          _bookKey,
          jsonEncode({
            'seeded': _seeded,
            'items': _book,
            'dirty': _dirty.toList(),
          }));
    } catch (_) {}
  }

  Map<String, Object?> _liveOfBook() => {
        for (final e in _book.entries)
          if (!MergedItems.removedOf(e.value)) e.key: e.value['v'],
      };

  /// ⚠️ CANONICAL, KEYS SORTED. Postgres `jsonb` keeps an object's keys in
  /// its own order, not ours, so a map that went round the server comes back
  /// encoded differently. Compared as plain jsonEncode it would look edited on
  /// every notify, be stamped again, and that fresh stamp could beat a real
  /// edit made on another phone. Sorting the keys makes "the same value" mean
  /// the same string on both sides.
  static Map<String, String> _encode(Map<String, Object?> items) =>
      {for (final e in items.entries) e.key: jsonEncode(_canonical(e.value))};

  static Object? _canonical(Object? v) {
    if (v is Map) {
      final keys = v.keys.map((k) => k.toString()).toList()..sort();
      return {for (final k in keys) k: _canonical(v[k])};
    }
    if (v is List) return [for (final e in v) _canonical(e)];
    return v;
  }

  /// Stamps every item that differs from the last known state. True when
  /// anything changed.
  bool _stamp() {
    final enc = _encode(cloudItems());
    final now = CloudMergeIo.nowMs();
    var changed = false;
    int tick(String k) => math.max(now, MergedItems.timeOf(_book[k]) + 1);
    for (final e in enc.entries) {
      if (_snap[e.key] == e.value) continue;
      _book[e.key] = {'v': jsonDecode(e.value), 't': tick(e.key)};
      _dirty.add(e.key);
      changed = true;
    }
    for (final k in _snap.keys) {
      if (enc.containsKey(k)) continue;
      _book[k] = {'v': null, 't': tick(k), 'd': true};
      _dirty.add(k);
      changed = true;
    }
    _snap = enc;
    return changed;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (!_ready || _applying) return;
    // A sign-out empties every store; that is not her removing anything.
    if (SyncRegistry.resetting) return;
    if (!_stamp()) return;
    _saveBook();
    if (!CloudMergeIo.isLoggedIn()) return; // waits for the next sign-in
    final wait = cloudPushDebounce;
    if (wait == Duration.zero) {
      _mergeNow();
      return;
    }
    _timer?.cancel();
    _timer = Timer(wait, _mergeNow);
  }

  void _mergeNow() {
    _runMerge().catchError(PvSyncHealth.report);
  }

  Future<void> _runMerge() async {
    if (_merging) {
      _again = true;
      return;
    }
    _merging = true;
    try {
      do {
        _again = false;
        final sent = <String, Map<String, dynamic>>{
          for (final k in _dirty)
            if (_book[k] != null) k: Map<String, dynamic>.from(_book[k]!),
        };
        final server = await CloudMergeIo.merge(_itemsKey, sent);
        await _adopt(server, sent);
      } while (_again);
    } finally {
      _merging = false;
    }
  }

  /// Takes the server's merged map. Items changed here while the merge was in
  /// flight stay as they are and stay waiting.
  Future<void> _adopt(
      Map<String, dynamic> server, Map<String, Map<String, dynamic>> sent) async {
    for (final e in sent.entries) {
      if (MergedItems.timeOf(_book[e.key]) == MergedItems.timeOf(e.value)) {
        _dirty.remove(e.key);
      }
    }
    for (final e in server.entries) {
      if (e.value is! Map || _dirty.contains(e.key)) continue;
      _book[e.key] = Map<String, dynamic>.from(e.value as Map);
    }
    // A live item the server does not hold never reached it: send it again.
    // A tombstone it does not hold was purged there: let it go here too.
    for (final k in _book.keys.toList()) {
      if (server.containsKey(k) || _dirty.contains(k)) continue;
      if (MergedItems.removedOf(_book[k])) {
        _book.remove(k);
      } else {
        _dirty.add(k);
      }
    }
    _dropSettled();
    final live = _liveOfBook();
    final enc = _encode(live);
    if (!mapEquals(enc, _snap)) {
      _applying = true;
      try {
        applyCloudItems(live);
      } finally {
        _applying = false;
      }
      _snap = enc;
      await persistLocalCache();
      super.notifyListeners();
    }
    await _saveBook();
  }

  void _dropSettled() {
    final cutoff = CloudMergeIo.nowMs() - MergedItems.phoneKeep.inMilliseconds;
    _book.removeWhere((k, v) =>
        !_dirty.contains(k) &&
        MergedItems.removedOf(v) &&
        MergedItems.timeOf(v) < cutoff);
  }

  Future<void> _seed() async {
    var items = cloudItems();
    final legacy = legacyBlobKey;
    // The old blob is read on a phone's first run whatever the store holds:
    // some stores start with demo seeds, so "holds nothing" would skip her
    // real data on a new phone. It wins, exactly as the old sync's "cloud
    // wins" did, unless this phone kept a change the old sync had not
    // uploaded yet (its waiting mark, cloud_synced_store.dart).
    var oldWaiting = false;
    if (legacy != null) {
      try {
        final p = await SharedPreferences.getInstance();
        oldWaiting = p.getBool('pv_blob_waiting_$legacy') ?? false;
      } catch (_) {}
    }
    if (legacy != null && !oldWaiting && CloudMergeIo.isLoggedIn()) {
      try {
        final blob = await CloudMergeIo.loadLegacy(legacy);
        if (blob != null) {
          _applying = true;
          try {
            applyLegacyBlob(blob as Object);
          } finally {
            _applying = false;
          }
          await persistLocalCache();
          items = cloudItems();
        }
      } catch (_) {/* offline: start from what the phone holds */}
    }
    for (final e in _encode(items).entries) {
      _book[e.key] = {'v': jsonDecode(e.value), 't': 0};
      _dirty.add(e.key);
    }
    _seeded = true;
    await _saveBook();
  }

  void _resetMerged() {
    _timer?.cancel();
    _ready = false;
    _book.clear();
    _dirty.clear();
    _snap = {};
    _seeded = false;
    _bookLoaded = true; // the wipe cleared it from disk
    SharedPreferences.getInstance()
        .then((p) => p.remove(_bookKey))
        .catchError((_) => false);
    _applying = true;
    try {
      applyCloudItems(const {});
    } finally {
      _applying = false;
    }
    super.notifyListeners();
  }

  /// Run once at the end of the store's init, after its local cache is
  /// loaded. Registered with SyncRegistry, so every sign-in and resume runs it.
  Future<void> syncMergedFromCloud() async {
    if (!_registered) {
      _registered = true;
      SyncRegistry.register(syncMergedFromCloud);
      SyncRegistry.registerReset(_resetMerged);
      SyncRegistry.registerPending(_isWaiting);
    }
    await _loadBook();
    if (!_seeded) {
      await _seed();
      _snap = _encode(_liveOfBook());
    } else if (!_ready) {
      // What the book last knew, then anything the store holds beyond it.
      _snap = _encode(_liveOfBook());
      if (_stamp()) await _saveBook();
    }
    _ready = true;
    if (CloudMergeIo.isLoggedIn()) {
      try {
        await _runMerge();
      } catch (_) {/* offline: keep local, still waiting */}
    }
    super.notifyListeners();
  }

  /// Replaces the store's whole state with [items] AS HER EDIT (R1,
  /// 2026-10-25): a new pregnancy starting clean, or an undo putting the old
  /// pregnancy's things back. Unlike [applyCloudItems] (the merge's own
  /// write, never stamped), this is stamped like any change she makes, so
  /// her other phones follow. A store that has not started yet starts first,
  /// or the change could not be stamped and the next merge would undo it.
  Future<void> replaceItemsAsEdit(Map<String, Object?> items) async {
    if (!_ready) await syncMergedFromCloud();
    applyCloudItems(items);
    await persistLocalCache();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
