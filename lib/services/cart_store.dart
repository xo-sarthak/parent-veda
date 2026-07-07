// =============================================================================
//  CartStore - a local, preview-only shopping cart
// -----------------------------------------------------------------------------
//  A believable "real shopping" layer over our catalogue: products (and planned
//  hospital-bag items) can be added to a cart, with quantities + optional size /
//  colour, then taken through a preview checkout. NO real payment is taken - the
//  flow ends at a friendly "order placed" preview. Two separate carts are kept
//  (Products vs Hospital bag). Persisted locally.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_synced_store.dart';

/// The two carts we keep separate for now.
const String kProductsCartId = 'products';
const String kHospitalCartId = 'hospitalBag';

/// One line in a cart: a product + quantity + optional size/colour variant.
class CartItem {
  CartItem({
    required this.lineId,
    required this.productId,
    required this.name,
    required this.emoji,
    required this.unitPrice,
    this.qty = 1,
    this.size = '',
    this.color = '',
  });

  final String lineId;
  final String productId;
  final String name;
  final String emoji;
  final double unitPrice;
  int qty;
  String size; // optional variant
  String color; // optional variant

  double get lineTotal => unitPrice * qty;

  Map<String, dynamic> toJson() => {
        'l': lineId,
        'p': productId,
        'n': name,
        'e': emoji,
        'u': unitPrice,
        'q': qty,
        's': size,
        'c': color,
      };

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        lineId: j['l'] as String? ?? '',
        productId: j['p'] as String? ?? '',
        name: j['n'] as String? ?? '',
        emoji: j['e'] as String? ?? '🛍️',
        unitPrice: (j['u'] as num?)?.toDouble() ?? 0,
        qty: (j['q'] as num?)?.toInt() ?? 1,
        size: j['s'] as String? ?? '',
        color: j['c'] as String? ?? '',
      );
}

class CartStore extends ChangeNotifier with CloudSyncedStore {
  CartStore._();
  static final CartStore instance = CartStore._();

  static const _key = 'cart_v1';

  final Map<String, List<CartItem>> _carts = {};
  bool _loaded = false;
  int _seq = 0;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        m.forEach((cartId, list) {
          _carts[cartId] = (list as List)
              .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        });
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
    await syncStateFromCloud();
  }

  // --- queries ---
  List<CartItem> items(String cartId) =>
      List.unmodifiable(_carts[cartId] ?? const []);

  /// Total quantity across all lines (used for the badge count).
  int count(String cartId) =>
      (_carts[cartId] ?? const []).fold(0, (a, i) => a + i.qty);

  double subtotal(String cartId) =>
      (_carts[cartId] ?? const []).fold(0.0, (a, i) => a + i.lineTotal);

  bool contains(String cartId, String productId) =>
      (_carts[cartId] ?? const []).any((i) => i.productId == productId);

  // --- mutations ---
  void add(
    String cartId, {
    required String productId,
    required String name,
    required String emoji,
    required double unitPrice,
    String size = '',
    String color = '',
    int qty = 1,
  }) {
    final list = _carts.putIfAbsent(cartId, () => []);
    // Same product + same variant → just bump the quantity.
    for (final i in list) {
      if (i.productId == productId && i.size == size && i.color == color) {
        i.qty += qty;
        _persistNotify();
        return;
      }
    }
    _seq++;
    list.add(CartItem(
      lineId: 'ln_${DateTime.now().microsecondsSinceEpoch}_$_seq',
      productId: productId,
      name: name,
      emoji: emoji,
      unitPrice: unitPrice,
      qty: qty,
      size: size,
      color: color,
    ));
    _persistNotify();
  }

  void setQty(String cartId, String lineId, int qty) {
    final list = _carts[cartId];
    if (list == null) return;
    final idx = list.indexWhere((i) => i.lineId == lineId);
    if (idx < 0) return;
    if (qty <= 0) {
      list.removeAt(idx);
    } else {
      list[idx].qty = qty;
    }
    _persistNotify();
  }

  void remove(String cartId, String lineId) {
    _carts[cartId]?.removeWhere((i) => i.lineId == lineId);
    _persistNotify();
  }

  void clear(String cartId) {
    _carts[cartId]?.clear();
    _persistNotify();
  }

  // --- cloud sync ------------------------------------------------------------
  @override
  String get cloudKey => 'cart_v1';
  @override
  Object cloudData() =>
      _carts.map((k, v) => MapEntry(k, v.map((i) => i.toJson()).toList()));
  @override
  void applyCloudData(Object data) {
    _carts.clear();
    (data as Map).forEach((cartId, list) {
      _carts[cartId.toString()] = (list as List)
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  @override
  Future<void> persistLocalCache() => _persist();

  void _persistNotify() {
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final m =
          _carts.map((k, v) => MapEntry(k, v.map((i) => i.toJson()).toList()));
      await prefs.setString(_key, jsonEncode(m));
    } catch (_) {/* best-effort */}
  }
}

// ---------------------------------------------------------------------------
//  Price helpers
// ---------------------------------------------------------------------------

/// Parse a price label like "₹2,499" → 2499.0.
double parsePriceString(String s) {
  final digits = s.replaceAll(RegExp(r'[^0-9.]'), '');
  return double.tryParse(digits) ?? 0;
}

/// A believable, STABLE mock price (₹) derived from [id] - no randomness, so it
/// stays the same across rebuilds. Used for items with no real price.
double mockPriceFor(String id) {
  final base = 199 + (id.hashCode.abs() % 2300);
  return ((base ~/ 50) * 50 + 49).toDouble();
}

/// Format a rupee amount: "₹2,499".
String formatINR(num v) {
  final n = v.round();
  final neg = n < 0;
  final digits = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return '${neg ? '-' : ''}₹$buf';
}
