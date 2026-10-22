// =============================================================================
//  ReadNextStore - saved / reading / completed states for Read Next
// -----------------------------------------------------------------------------
//  Two clean concepts: a per-item STATUS (reading | completed) for the Read Next
//  chip, and an explicit SAVED/bookmark set with a save-timestamp (so the Saved
//  hub can show newest-first). No gamification - gentle bookkeeping only.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/read_next_data.dart';
import 'remote/cloud_merged_store.dart';
// import 'remote/cloud_synced_store.dart'; // kept for revert (step 13)
import 'saved_store.dart';

// Per-item since step 13 (2026-10-22, sync log). It synced as one whole blob,
// so a read marked on one phone could be erased by the other phone's older
// map. One item per read id, value = its status ('reading' | 'completed');
// clearing a status removes the item. Bookmarks are SavedStore's, not here.
class ReadNextStore extends ChangeNotifier with CloudMergedStore {
  static final ReadNextStore instance = ReadNextStore._();

  static const _key = 'readnext_state'; // status: id → 'reading' | 'completed'
  // ⚠️ BOOKMARKS MOVED TO SavedStore ON 2026-09-16 (docs/FAMILY-MODEL.md §5).
  // Rows of kind `article`, owned by the person. This store keeps ONLY the
  // reading / completed status. The old 'readnext_saved' prefs key and the
  // `saved` half of the cloud blob are read once by SavedStore's legacy
  // imports and otherwise ignored here. Kept for revert:
  // static const _savedKey = 'readnext_saved'; // bookmarks: id → saved-at millis
  // final Map<String, int> _saved = {};
  SharedPreferences? _prefs;
  final Map<String, String> _status = {};

  ReadNextStore._() {
    SavedStore.instance.addListener(notifyListeners);
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _status.clear();
    // Legacy combined map (id → 'saved' | 'reading' | 'completed'). The
    // 'saved' entries used to be split out here; SavedStore.importLegacy
    // does not read this key, so lift them across once, idempotently.
    final raw = _prefs?.getString(_key);
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map;
        m.forEach((k, v) {
          final key = k.toString();
          final val = v.toString();
          if (val == 'saved') {
            if (!SavedStore.instance.isSaved(SavedKind.article, key)) {
              SavedStore.instance.save(SavedKind.article, key, title: _titleOf(key));
            }
          } else {
            _status[key] = val; // reading | completed
          }
        });
      } catch (_) {/* ignore */}
    }
    notifyListeners();
    await SavedStore.instance.load();
    // await syncStateFromCloud(); // kept for revert (step 13)
    await syncMergedFromCloud();
  }

  static String _titleOf(String id) {
    for (final r in kReadItems) {
      if (r.id == id) return r.title.en;
    }
    return '';
  }

  // --- status (reading / completed) -----------------------------------------
  String? statusOf(String id) => _status[id];
  void setStatus(String id, String status) {
    _status[id] = status;
    _persist();
    notifyListeners();
  }

  void clearStatus(String id) {
    if (_status.remove(id) != null) {
      _persist();
      notifyListeners();
    }
  }

  // --- saved / bookmarks — delegated to SavedStore, API unchanged ----------
  bool isSaved(String id) => SavedStore.instance.isSaved(SavedKind.article, id);
  List<String> get savedIds => SavedStore.instance.idsOf(SavedKind.article);
  bool get hasSaved => SavedStore.instance.count(SavedKind.article) > 0;
  int savedAt(String id) =>
      SavedStore.instance.savedAt(SavedKind.article, id)?.millisecondsSinceEpoch ?? 0;

  /// Saved ids, most recently saved first.
  List<String> savedIdsRecent() => SavedStore.instance.idsOf(SavedKind.article);

  void toggleSave(String id) {
    SavedStore.instance.toggle(SavedKind.article, id, title: _titleOf(id));
  }
  // Kept for revert:
  // bool isSaved(String id) => _saved.containsKey(id);
  // void toggleSave(String id) {
  //   if (_saved.remove(id) == null) {
  //     _saved[id] = DateTime.now().millisecondsSinceEpoch;
  //   }
  //   _persist();
  //   notifyListeners();
  // }

  // --- cloud sync ------------------------------------------------------------
  @override
  String get cloudKey => 'readnext';
  @override
  String? get legacyBlobKey => cloudKey;

  // Kept for revert (step 13): applyCloudItems({}) is the empty state now.
  //   /// What a sign-out resets this store to (2026-10-17): the blob of a store nobody has used.
  //   @override
  //   Object get cloudEmptyData => const <String, Object?>{};
  //
  //   @override
  //   Object cloudData() => {'status': _status};

  @override
  Map<String, Object?> cloudItems() => Map<String, Object?>.of(_status);

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _status.clear();
    items.forEach((k, v) {
      if (v != null) _status[k] = v.toString();
    });
  }

  @override
  void applyLegacyBlob(Object blob) {
    final m = blob as Map;
    _status.clear();
    ((m['status'] as Map?) ?? const {})
        .forEach((k, v) => _status[k.toString()] = v.toString());
    // `saved` in an old blob is deliberately NOT applied here — SavedStore
    // lifted it once (importLegacyCloud) and owns it from then on.
  }

  @override
  Future<void> persistLocalCache() async => _persist();

  void _persist() {
    _prefs?.setString(_key, jsonEncode(_status));
  }
}
