// =============================================================================
//  ReadDoneStore - which Daily Reads / Read Next items the mother has finished
// -----------------------------------------------------------------------------
//  A small, satisfying "accomplished" layer: tick a read as done and it sticks.
//  Lazy-loaded (no main.dart wiring) + persisted via shared_preferences.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_merged_store.dart';
// import 'remote/cloud_synced_store.dart'; // kept for revert (step 13)

// Per-item since step 13 (2026-10-22, sync log). It synced as one whole blob,
// so a read ticked done on one phone could be erased by the other phone's
// older list. One item per read id, value true; an untick removes the item.
class ReadDoneStore extends ChangeNotifier with CloudMergedStore {
  ReadDoneStore._();
  static final ReadDoneStore instance = ReadDoneStore._();

  static const _key = 'reads_done';
  final Set<String> _done = {};
  bool _loaded = false;

  /// Load once (call from build - it's a no-op after the first time).
  void ensureLoaded() {
    if (_loaded) return;
    _loaded = true;
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _done.addAll(prefs.getStringList(_key) ?? const []);
      notifyListeners();
    } catch (_) {/* start empty */}
    // Defensive: a cloud/Supabase hiccup must never break the reader (also
    // makes the store safe under the widget-test harness).
    try {
      // await syncStateFromCloud(); // kept for revert (step 13)
      await syncMergedFromCloud();
    } catch (_) {/* stay local */}
  }

  // --- cloud sync ------------------------------------------------------------
  @override
  String get cloudKey => 'reads_done';
  @override
  String? get legacyBlobKey => cloudKey;

  // Kept for revert (step 13): applyCloudItems({}) is the empty state now.
  //   /// What a sign-out resets this store to (2026-10-17): the blob of a store nobody has used.
  //   @override
  //   Object get cloudEmptyData => const <String>[];
  //
  //   @override
  //   Object cloudData() => _done.toList();

  @override
  void applyLegacyBlob(Object blob) => _done
    ..clear()
    ..addAll((blob as List).map((e) => e.toString()));

  @override
  Map<String, Object?> cloudItems() => {for (final id in _done) id: true};

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _done
      ..clear()
      ..addAll(items.keys);
    _loaded = true;
  }
  @override
  Future<void> persistLocalCache() => _persist();

  bool isDone(String id) => _done.contains(id);

  void toggle(String id) {
    if (!_done.remove(id)) _done.add(id);
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, _done.toList());
    } catch (_) {/* best-effort */}
  }
}
