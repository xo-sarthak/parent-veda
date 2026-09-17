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
import 'remote/cloud_synced_store.dart';
import 'saved_store.dart';

class ReadNextStore extends ChangeNotifier with CloudSyncedStore {
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
    await syncStateFromCloud();
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
  Object cloudData() => {'status': _status};
  @override
  void applyCloudData(Object data) {
    final m = data as Map;
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
