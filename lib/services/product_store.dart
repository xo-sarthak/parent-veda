// =============================================================================
//  ProductStore - saved products for ParentVeda Products
// -----------------------------------------------------------------------------
//  Since 2026-09-16 a FACADE over SavedStore (docs/FAMILY-MODEL.md §5): rows of
//  kind `product`, owned by the person. The API its callers use - savedIds /
//  hasSaved / isSaved / toggleSave - is unchanged. The old implementation is
//  commented at the bottom, kept for revert; its 'prod_saved' key is read once
//  by SavedStore.importLegacy.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../data/product_data.dart';
import '../models/product_models.dart';
import 'saved_store.dart';

class ProductStore extends ChangeNotifier {
  ProductStore._() {
    SavedStore.instance.addListener(notifyListeners);
  }
  static final ProductStore instance = ProductStore._();

  Future<void> init() => SavedStore.instance.load();

  List<String> get savedIds => SavedStore.instance.idsOf(SavedKind.product);
  bool get hasSaved => SavedStore.instance.count(SavedKind.product) > 0;
  bool isSaved(String id) => SavedStore.instance.isSaved(SavedKind.product, id);

  void toggleSave(String id) {
    Product? p;
    for (final x in kProducts) {
      if (x.id == id) {
        p = x;
        break;
      }
    }
    SavedStore.instance.toggle(SavedKind.product, id, title: p?.name.en ?? '');
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
// class ProductStore extends ChangeNotifier with CloudSyncedStore {
//   ProductStore._();
//   static final ProductStore instance = ProductStore._();
//
//   static const _savedKey = 'prod_saved';
//   SharedPreferences? _prefs;
//   final List<String> _saved = []; // product ids, most recent first
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
//   String get cloudKey => 'prod_saved';
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
//   void toggleSave(String id) {
//     if (!_saved.remove(id)) _saved.insert(0, id);
//     _prefs?.setStringList(_savedKey, _saved);
//     notifyListeners();
//   }
// }
