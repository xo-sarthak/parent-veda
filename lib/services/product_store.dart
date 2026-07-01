// =============================================================================
//  ProductStore — saved products for ParentVeda Products
// -----------------------------------------------------------------------------
//  Just the "Saved" list for now (persisted). Commerce/cart is future affiliate.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_synced_store.dart';

class ProductStore extends ChangeNotifier with CloudSyncedStore {
  ProductStore._();
  static final ProductStore instance = ProductStore._();

  static const _savedKey = 'prod_saved';
  SharedPreferences? _prefs;
  final List<String> _saved = []; // product ids, most recent first

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
  String get cloudKey => 'prod_saved';
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

  void toggleSave(String id) {
    if (!_saved.remove(id)) _saved.insert(0, id);
    _prefs?.setStringList(_savedKey, _saved);
    notifyListeners();
  }
}
