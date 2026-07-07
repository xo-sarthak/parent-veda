// =============================================================================
//  BoughtStore - which catalogue products the mother has "bought" (preview)
// -----------------------------------------------------------------------------
//  The preview checkout takes no real payment, but once an order is "placed" we
//  remember the product ids so they can be reflected elsewhere - most notably an
//  "Already bought ✓" marker on her Product Checklists. Persisted locally.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_synced_store.dart';

class BoughtStore extends ChangeNotifier with CloudSyncedStore {
  BoughtStore._();
  static final BoughtStore instance = BoughtStore._();

  static const _key = 'bought_products';
  final Set<String> _bought = {};
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _bought.addAll(prefs.getStringList(_key) ?? const []);
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
    await syncStateFromCloud();
  }

  // --- cloud sync ------------------------------------------------------------
  @override
  String get cloudKey => 'bought_products';
  @override
  Object cloudData() => _bought.toList();
  @override
  void applyCloudData(Object data) => _bought
    ..clear()
    ..addAll((data as List).map((e) => e.toString()));
  @override
  Future<void> persistLocalCache() => _persist();

  // --- queries ---
  bool isBought(String productId) => _bought.contains(productId);
  List<String> get boughtIds => _bought.toList();
  bool get isEmpty => _bought.isEmpty;

  // --- mutations ---
  /// Mark one product as bought (no-op for empty ids or custom items).
  void markBought(String productId) {
    if (productId.trim().isEmpty) return;
    if (_bought.add(productId)) {
      notifyListeners();
      _persist();
    }
  }

  /// Mark several at once - used when an order with multiple lines is placed.
  void markBoughtMany(Iterable<String> productIds) {
    var changed = false;
    for (final id in productIds) {
      if (id.trim().isEmpty) continue;
      changed = _bought.add(id) || changed;
    }
    if (changed) {
      notifyListeners();
      _persist();
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, _bought.toList());
    } catch (_) {/* best-effort */}
  }
}
