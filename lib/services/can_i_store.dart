// =============================================================================
//  CanIStore - persistence for the Can I? feature
// -----------------------------------------------------------------------------
//  Currently just the mother's "Saved questions" (a list of entry ids, most
//  recent first), persisted via shared_preferences. Mirrors the other singleton
//  stores; init() is called once in main().
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_synced_store.dart';

class CanIStore extends ChangeNotifier with CloudSyncedStore {
  CanIStore._();
  static final CanIStore instance = CanIStore._();

  static const String _savedKey = 'cani_saved';

  SharedPreferences? _prefs;
  final List<String> _saved = []; // entry ids, most-recent first

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _saved
      ..clear()
      ..addAll(_prefs?.getStringList(_savedKey) ?? const []);
    notifyListeners();
    await syncStateFromCloud();
  }

  // --- cloud sync ------------------------------------------------------------
  @override
  String get cloudKey => 'cani_saved';
  @override
  Object cloudData() => List<String>.from(_saved);
  @override
  void applyCloudData(Object data) => _saved
    ..clear()
    ..addAll((data as List).map((e) => e.toString()));
  @override
  Future<void> persistLocalCache() async {
    await _prefs?.setStringList(_savedKey, _saved);
  }

  List<String> get savedIds => List.unmodifiable(_saved);
  bool get hasSaved => _saved.isNotEmpty;
  bool isSaved(String id) => _saved.contains(id);

  void toggleSaved(String id) {
    if (!_saved.remove(id)) _saved.insert(0, id);
    _prefs?.setStringList(_savedKey, _saved);
    notifyListeners();
  }
}
