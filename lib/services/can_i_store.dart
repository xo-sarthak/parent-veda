// =============================================================================
//  CanIStore - the mother's saved "Can I…?" questions
// -----------------------------------------------------------------------------
//  Since 2026-09-16 a FACADE over SavedStore (docs/FAMILY-MODEL.md §5): rows of
//  kind `question`, owned by the person. API unchanged: savedIds / hasSaved /
//  isSaved / toggleSaved. Old implementation commented below, kept for revert;
//  its 'cani_saved' key is read once by SavedStore.importLegacy.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../data/can_i_data.dart';
import '../models/can_i_entry.dart';
import 'saved_store.dart';

class CanIStore extends ChangeNotifier {
  CanIStore._() {
    SavedStore.instance.addListener(notifyListeners);
  }
  static final CanIStore instance = CanIStore._();

  Future<void> init() => SavedStore.instance.load();

  List<String> get savedIds => SavedStore.instance.idsOf(SavedKind.question);
  bool get hasSaved => SavedStore.instance.count(SavedKind.question) > 0;
  bool isSaved(String id) => SavedStore.instance.isSaved(SavedKind.question, id);

  void toggleSaved(String id) {
    CanIEntry? e;
    for (final x in kCanIEntries) {
      if (x.id == id) {
        e = x;
        break;
      }
    }
    SavedStore.instance.toggle(SavedKind.question, id,
        title: e?.name.en ?? '', subtitle: e?.short.en);
  }
}

// =============================================================================
//  KEPT FOR REVERT - the pre-2026-09-16 implementation, verbatim.
// =============================================================================
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'remote/cloud_synced_store.dart';
//
// class CanIStore extends ChangeNotifier with CloudSyncedStore {
//   CanIStore._();
//   static final CanIStore instance = CanIStore._();
//
//   static const String _savedKey = 'cani_saved';
//
//   SharedPreferences? _prefs;
//   final List<String> _saved = []; // entry ids, most-recent first
//
//   Future<void> init() async {
//     _prefs = await SharedPreferences.getInstance();
//     _saved
//       ..clear()
//       ..addAll(_prefs?.getStringList(_savedKey) ?? const []);
//     notifyListeners();
//     await syncStateFromCloud();
//   }
//
//   // --- cloud sync ------------------------------------------------------------
//   @override
//   String get cloudKey => 'cani_saved';
//   @override
//   Object cloudData() => List<String>.from(_saved);
//   @override
//   void applyCloudData(Object data) => _saved
//     ..clear()
//     ..addAll((data as List).map((e) => e.toString()));
//   @override
//   Future<void> persistLocalCache() async {
//     await _prefs?.setStringList(_savedKey, _saved);
//   }
//
//   List<String> get savedIds => List.unmodifiable(_saved);
//   bool get hasSaved => _saved.isNotEmpty;
//   bool isSaved(String id) => _saved.contains(id);
//
//   void toggleSaved(String id) {
//     if (!_saved.remove(id)) _saved.insert(0, id);
//     _prefs?.setStringList(_savedKey, _saved);
//     notifyListeners();
//   }
// }
