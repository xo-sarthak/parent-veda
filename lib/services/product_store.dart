// =============================================================================
//  ProductStore — saved products for ParentVeda Products
// -----------------------------------------------------------------------------
//  Just the "Saved" list for now (persisted). Commerce/cart is future affiliate.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductStore extends ChangeNotifier {
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
