// =============================================================================
//  PvOrderStore — addresses and orders for the unified store
// -----------------------------------------------------------------------------
//  Two things a checkout needs to remember, both owned by the PERSON
//  (docs/FAMILY-MODEL.md): where she lives, and what she ordered.
//
//  LOCAL-FIRST, LIKE EVERYTHING HERE. Addresses and the order list live in
//  shared_preferences and sync as one state blob through `CloudSyncedStore`
//  (the `user_state` shape CartStore already uses), so a new phone gets her
//  addresses back. An ORDER additionally becomes a ROW in `orders` /
//  `order_items` (migration 0083) when she is logged in, fire-and-forget —
//  because an order is a ledger entry someone else (support, the fulfilment
//  side, an accountant) has to read, and a JSON blob in user_state is not a
//  ledger anyone can query.
//
//  ⚠️ STATUS IS THE PAYMENT'S, NOT THE TAP'S. `placed` means she pressed the
//  button; `paid` is set ONLY after `PaymentService` has verified Razorpay's
//  signature server-side. `preview` means the payment backend was not
//  reachable (not deployed, logged out, offline) and the order is a rehearsal
//  — the copy says so, and nothing is fulfilled from it. The app never
//  promotes an order to `paid` on its own judgement.
//
//  ⚠️ THE APP MINTS THE ORDER ID, so the local row and the cloud row share
//  one identity and a retry is an idempotent upsert, not a second order.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cart_store.dart';
import 'remote/cloud_synced_store.dart';
import 'remote/supabase_repo.dart';

enum PvOrderStatus { placed, paid, preview, cancelled }

extension PvOrderStatusCopy on PvOrderStatus {
  String get label => switch (this) {
        PvOrderStatus.placed => 'Placed',
        PvOrderStatus.paid => 'Confirmed',
        PvOrderStatus.preview => 'Preview order',
        PvOrderStatus.cancelled => 'Cancelled',
      };
  String get id => name;
  static PvOrderStatus fromId(String? s) =>
      PvOrderStatus.values.firstWhere((v) => v.name == s,
          orElse: () => PvOrderStatus.placed);
}

class PvAddress {
  const PvAddress({
    required this.id,
    required this.name,
    required this.phone,
    required this.line1,
    this.line2 = '',
    required this.city,
    required this.state,
    required this.pin,
    this.label = 'Home',
  });
  final String id;
  final String name;
  final String phone;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String pin;
  final String label; // Home / Work / Other

  String get oneLine => [line1, if (line2.isNotEmpty) line2, '$city $pin', state].join(', ');

  Map<String, dynamic> toJson() => {
        'id': id,
        'n': name,
        'ph': phone,
        'l1': line1,
        'l2': line2,
        'c': city,
        's': state,
        'p': pin,
        'lb': label,
      };

  factory PvAddress.fromJson(Map<String, dynamic> j) => PvAddress(
        id: j['id'] as String? ?? '',
        name: j['n'] as String? ?? '',
        phone: j['ph'] as String? ?? '',
        line1: j['l1'] as String? ?? '',
        line2: j['l2'] as String? ?? '',
        city: j['c'] as String? ?? '',
        state: j['s'] as String? ?? '',
        pin: j['p'] as String? ?? '',
        label: j['lb'] as String? ?? 'Home',
      );
}

class PvOrder {
  PvOrder({
    required this.id,
    required this.createdAt,
    required this.lines,
    required this.subtotal,
    required this.delivery,
    required this.address,
    required this.status,
    this.paymentId = '',
  });
  final String id;
  final DateTime createdAt;
  final List<CartItem> lines;
  final double subtotal;
  final double delivery;
  final PvAddress address;
  PvOrderStatus status;
  String paymentId;

  double get total => subtotal + delivery;
  int get itemCount => lines.fold(0, (a, l) => a + l.qty);

  /// Short human reference: PV-XXXXXX from the tail of the id.
  String get reference {
    final s = id.replaceAll(RegExp(r'[^0-9A-Za-z]'), '').toUpperCase();
    return 'PV-${s.length > 6 ? s.substring(s.length - 6) : s}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        't': createdAt.toIso8601String(),
        'l': lines.map((e) => e.toJson()).toList(),
        'sub': subtotal,
        'del': delivery,
        'a': address.toJson(),
        'st': status.id,
        'pay': paymentId,
      };

  factory PvOrder.fromJson(Map<String, dynamic> j) => PvOrder(
        id: j['id'] as String? ?? '',
        createdAt: DateTime.tryParse(j['t'] as String? ?? '') ?? DateTime.now(),
        lines: [
          for (final e in (j['l'] as List? ?? const []))
            CartItem.fromJson(Map<String, dynamic>.from(e as Map))
        ],
        subtotal: (j['sub'] as num?)?.toDouble() ?? 0,
        delivery: (j['del'] as num?)?.toDouble() ?? 0,
        address: PvAddress.fromJson(Map<String, dynamic>.from(j['a'] as Map? ?? const {})),
        status: PvOrderStatusCopy.fromId(j['st'] as String?),
        paymentId: j['pay'] as String? ?? '',
      );
}

class PvOrderStore extends ChangeNotifier with CloudSyncedStore {
  PvOrderStore._();
  static final PvOrderStore instance = PvOrderStore._();

  static const _key = 'pv_orders_v1';

  /// Free delivery above this; below it a flat fee. Decided server-side once
  /// the edge function prices the order — until then this is display only.
  static const int freeDeliveryAbove = 999;
  static const double deliveryFee = 49;

  final List<PvAddress> _addresses = [];
  final List<PvOrder> _orders = [];
  String? _defaultAddressId;
  bool _loaded = false;
  Future<void>? _loading;

  Future<void> init() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) applyCloudData(jsonDecode(raw));
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
    await syncStateFromCloud();
  }

  bool get loaded => _loaded;

  // ---- addresses -------------------------------------------------------------

  List<PvAddress> get addresses => List.unmodifiable(_addresses);

  PvAddress? get defaultAddress {
    if (_addresses.isEmpty) return null;
    for (final a in _addresses) {
      if (a.id == _defaultAddressId) return a;
    }
    return _addresses.first;
  }

  void saveAddress(PvAddress a, {bool makeDefault = true}) {
    final idx = _addresses.indexWhere((x) => x.id == a.id);
    if (idx >= 0) {
      _addresses[idx] = a;
    } else {
      _addresses.add(a);
    }
    if (makeDefault || _defaultAddressId == null) _defaultAddressId = a.id;
    _persistNotify();
  }

  void removeAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    if (_defaultAddressId == id) _defaultAddressId = _addresses.isEmpty ? null : _addresses.first.id;
    _persistNotify();
  }

  void setDefault(String id) {
    _defaultAddressId = id;
    _persistNotify();
  }

  // ---- orders ----------------------------------------------------------------

  /// Newest first.
  List<PvOrder> get orders {
    final l = [..._orders]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(l);
  }

  PvOrder? order(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  static double deliveryFor(double subtotal) =>
      subtotal >= freeDeliveryAbove ? 0 : deliveryFee;

  /// Mint the order locally. Status arrives from the caller AFTER payment.
  PvOrder place({
    required List<CartItem> lines,
    required PvAddress address,
    required PvOrderStatus status,
    String paymentId = '',
  }) {
    final subtotal = lines.fold(0.0, (a, l) => a + l.lineTotal);
    final o = PvOrder(
      id: 'ord_${DateTime.now().microsecondsSinceEpoch}',
      createdAt: DateTime.now(),
      lines: [for (final l in lines) CartItem.fromJson(l.toJson())],
      subtotal: subtotal,
      delivery: deliveryFor(subtotal),
      address: address,
      status: status,
      paymentId: paymentId,
    );
    _orders.add(o);
    _persistNotify();
    _pushOrderRow(o);
    return o;
  }

  void setStatus(String id, PvOrderStatus status, {String? paymentId}) {
    final o = order(id);
    if (o == null) return;
    o.status = status;
    if (paymentId != null) o.paymentId = paymentId;
    _persistNotify();
    _pushOrderRow(o);
  }

  /// The ledger row. Fire-and-forget; the local order is the truth on this
  /// phone either way. Upsert on the app-minted id, so a retry cannot double
  /// an order.
  void _pushOrderRow(PvOrder o) {
    if (!SupabaseRepo.isLoggedIn) return;
    SupabaseRepo.upsertRow('orders', {
      'id': o.id,
      // RLS insists the row is hers; upsertRow injects nothing.
      'user_id': SupabaseRepo.userId,
      'status': o.status.id,
      'subtotal_inr': o.subtotal.round(),
      'delivery_inr': o.delivery.round(),
      'total_inr': o.total.round(),
      'payment_id': o.paymentId.isEmpty ? null : o.paymentId,
      'address': o.address.toJson(),
      'items': [
        for (final l in o.lines)
          {
            'product_id': l.productId,
            'name': l.name,
            'variant': l.size,
            'qty': l.qty,
            'unit_inr': l.unitPrice.round(),
          }
      ],
      'created_at': o.createdAt.toUtc().toIso8601String(),
    }).catchError((_) {});
  }

  // ---- cloud sync ------------------------------------------------------------
  @override
  String get cloudKey => 'pv_orders_v1';

  @override
  Object cloudData() => {
        'addr': _addresses.map((a) => a.toJson()).toList(),
        'def': _defaultAddressId,
        'orders': _orders.map((o) => o.toJson()).toList(),
      };

  @override
  void applyCloudData(Object data) {
    final m = Map<String, dynamic>.from(data as Map);
    _addresses
      ..clear()
      ..addAll([
        for (final e in (m['addr'] as List? ?? const []))
          PvAddress.fromJson(Map<String, dynamic>.from(e as Map))
      ]);
    _defaultAddressId = m['def'] as String?;
    _orders
      ..clear()
      ..addAll([
        for (final e in (m['orders'] as List? ?? const []))
          PvOrder.fromJson(Map<String, dynamic>.from(e as Map))
      ]);
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
      await prefs.setString(_key, jsonEncode(cloudData()));
    } catch (_) {/* best-effort */}
  }
}
