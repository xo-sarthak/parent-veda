// =============================================================================
//  PvListStore — her own named product lists (store Track A, 2026-10-28)
// -----------------------------------------------------------------------------
//  The user: "provide a functionality in the wish list like Amazon does to
//  actually name your own wish list, so users can customize what products to
//  add in what list". So beside the heart (SavedStore, one flat wishlist)
//  she can make lists — "Hospital bag", "Baby's room", "Ask mum to gift" —
//  and put any product in any number of them.
//
//  THE TWO DO NOT COUPLE. The heart stays exactly what it was; a list is a
//  separate grouping. The wishlist's "All" view shows hearted products and
//  every product in any list together, so nothing she kept is ever out of
//  sight, and no tap in one place silently changes the other.
//
//  ONE UNIFORM AFFILIATE FLOW (decided 2026-10-28): an affiliate product
//  never enters the cart (the cart is what ParentVeda ships). It gets the
//  same three actions on every page: Buy on <shop> (then "Did you buy
//  it?"), the heart, and Add to a list.
//
//  Owned by the PERSON, never a stage (docs/FAMILY-MODEL.md): moving from
//  pregnancy to parenting changes nothing here. Synced as one blob per user
//  through CloudSyncedStore, like BoughtStore; lists are small and edited on
//  one phone at a time, so the blob's last-write-wins is acceptable here.
// =============================================================================

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_synced_store.dart';

/// One named list.
@immutable
class PvProductList {
  const PvProductList({
    required this.id,
    required this.name,
    required this.productIds,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// In the order she added them, newest last.
  final List<String> productIds;
  final DateTime createdAt;

  PvProductList copyWith({String? name, List<String>? productIds}) =>
      PvProductList(
        id: id,
        name: name ?? this.name,
        productIds: productIds ?? this.productIds,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'products': productIds,
    'created_at': createdAt.toIso8601String(),
  };

  static PvProductList? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final name = raw['name'];
    if (id is! String || name is! String || name.trim().isEmpty) return null;
    return PvProductList(
      id: id,
      name: name,
      productIds: [
        for (final p in (raw['products'] as List? ?? const []))
          if (p is String) p,
      ],
      createdAt:
          DateTime.tryParse(raw['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class PvListStore extends ChangeNotifier with CloudSyncedStore {
  PvListStore._();
  static final PvListStore instance = PvListStore._();

  static const _key = 'pv_product_lists';
  static const maxNameLength = 40;

  final List<PvProductList> _lists = [];
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) applyCloudData(jsonDecode(raw) as Object);
    } catch (_) {
      /* start empty */
    }
    _loaded = true;
    notifyListeners();
    await syncStateFromCloud();
  }

  // ---- cloud sync -----------------------------------------------------------
  @override
  String get cloudKey => 'pv_product_lists';
  @override
  Object get cloudEmptyData => const <Object>[];
  @override
  Object cloudData() => [for (final l in _lists) l.toJson()];
  @override
  void applyCloudData(Object data) {
    _lists
      ..clear()
      ..addAll([
        if (data is List)
          for (final e in data) ?PvProductList.fromJson(e),
      ]);
  }

  @override
  Future<void> persistLocalCache() => _persist();

  // ---- queries --------------------------------------------------------------

  List<PvProductList> get lists => List.unmodifiable(_lists);

  PvProductList? byId(String id) {
    for (final l in _lists) {
      if (l.id == id) return l;
    }
    return null;
  }

  bool contains(String listId, String productId) =>
      byId(listId)?.productIds.contains(productId) ?? false;

  /// The lists [productId] is in, for "In 2 lists" on the product page.
  List<PvProductList> listsWith(String productId) => [
    for (final l in _lists)
      if (l.productIds.contains(productId)) l,
  ];

  /// Every product in any list, once, in list order.
  List<String> get allProductIds => {
    for (final l in _lists) ...l.productIds,
  }.toList();

  // ---- mutations ------------------------------------------------------------

  /// A new list, or null when [name] is blank or already taken (names are
  /// how she tells them apart, so two "Hospital bag" lists are refused).
  PvProductList? create(String name, {String? firstProductId}) {
    final n = _clean(name);
    if (n.isEmpty || _taken(n)) return null;
    final l = PvProductList(
      id: _newId(),
      name: n,
      productIds: [?firstProductId],
      createdAt: DateTime.now(),
    );
    _lists.add(l);
    _changed();
    return l;
  }

  /// False when the new name is blank or another list has it.
  bool rename(String listId, String name) {
    final n = _clean(name);
    final i = _lists.indexWhere((l) => l.id == listId);
    if (i < 0 || n.isEmpty || _taken(n, except: listId)) return false;
    _lists[i] = _lists[i].copyWith(name: n);
    _changed();
    return true;
  }

  void delete(String listId) {
    final before = _lists.length;
    _lists.removeWhere((l) => l.id == listId);
    if (_lists.length != before) _changed();
  }

  /// Puts [productId] in the list, or takes it out. Returns whether it is
  /// in the list afterwards.
  bool toggle(String listId, String productId) {
    final i = _lists.indexWhere((l) => l.id == listId);
    if (i < 0) return false;
    final ids = [..._lists[i].productIds];
    final had = ids.remove(productId);
    if (!had) ids.add(productId);
    _lists[i] = _lists[i].copyWith(productIds: ids);
    _changed();
    return !had;
  }

  // ---- internals ------------------------------------------------------------

  String _clean(String s) {
    final t = s.trim().replaceAll(RegExp(r'\s+'), ' ');
    return t.length > maxNameLength ? t.substring(0, maxNameLength) : t;
  }

  bool _taken(String name, {String? except}) => _lists.any(
    (l) => l.id != except && l.name.toLowerCase() == name.toLowerCase(),
  );

  void _changed() {
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(cloudData()));
    } catch (_) {
      /* best-effort */
    }
  }

  static final _rand = Random.secure();
  static String _newId() =>
      'pl_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
      '${_rand.nextInt(1 << 20).toRadixString(36)}';

  @visibleForTesting
  void resetForTest() {
    _lists.clear();
    _loaded = false;
  }
}
