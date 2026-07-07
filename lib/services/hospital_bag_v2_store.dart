// =============================================================================
//  HospitalBagV2Store - a SEPARATE bag for the "V2" redesign (toggle vs V1)
// -----------------------------------------------------------------------------
//  Holds its OWN copy of the bag (independent persistence keys), so the V1 and V2
//  experiences can be compared side-by-side on different data. Reuses the V1
//  [BagItem] model - its status / packed / purchased / selectedProductId /
//  store-link-price / isCustom already map cleanly onto the V2 "item journey":
//
//     Needs your decision  →  Planning to buy  →  Ready at home  →  Packed
//
//  (plus a gentle "Maybe later" set = status.skip). The mother never sees a
//  "state" - the screens render plain language; this store just keeps the data.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_language.dart'; // LocalizedText
import 'bought_store.dart';
import 'hospital_bag_store.dart'; // BagItem / BagCategory / BagItemStatus / DeliveryType
import 'remote/cloud_synced_store.dart';

/// The single, plain-language journey stage for an item (computed, not stored).
enum BagStage { needsDecision, planningToBuy, readyAtHome, packed, maybeLater }

/// Compute the stage for a [BagItem] (shared by the V2 screens).
BagStage bagStageOf(BagItem i) {
  if (i.status == BagItemStatus.skip) return BagStage.maybeLater;
  if (i.packed) return BagStage.packed;
  final acquired = i.status == BagItemStatus.have ||
      ((i.status == BagItemStatus.buyVeda || i.status == BagItemStatus.buyElse) &&
          i.purchased);
  if (acquired) return BagStage.readyAtHome;
  if (i.status == BagItemStatus.buyVeda || i.status == BagItemStatus.buyElse) {
    return BagStage.planningToBuy;
  }
  return BagStage.needsDecision; // needed (or chosen but not yet sorted)
}

class HospitalBagV2Store extends ChangeNotifier with CloudSyncedStore {
  HospitalBagV2Store._();
  static final HospitalBagV2Store instance = HospitalBagV2Store._();

  static const _itemsKey = 'hb2v2_items';
  static const _metaKey = 'hb2v2_meta'; // {onboarded, delivery, updatedIso}

  final List<BagItem> _items = [];
  bool _onboarded = false;
  DeliveryType _delivery = DeliveryType.unsure;
  String? _updatedIso;
  bool _loaded = false;
  bool _boughtHooked = false;

  // ---- getters --------------------------------------------------------------
  bool get onboarded => _onboarded;
  DeliveryType get delivery => _delivery;
  DateTime? get lastUpdated =>
      _updatedIso == null ? null : DateTime.tryParse(_updatedIso!);
  List<BagItem> get items => List.unmodifiable(_items);

  BagItem? byId(String id) {
    for (final i in _items) {
      if (i.id == id) return i;
    }
    return null;
  }

  List<BagItem> withStatus(BagItemStatus s) =>
      _items.where((i) => i.status == s).toList();

  /// Items still in the bag (everything except the gentle "Maybe later" set).
  List<BagItem> get active =>
      _items.where((i) => i.status != BagItemStatus.skip).toList();

  /// The "Maybe later" set (never deleted, one tap to restore).
  List<BagItem> get maybeLater =>
      _items.where((i) => i.status == BagItemStatus.skip).toList();

  List<BagItem> itemsIn(BagCategory c) =>
      _items.where((i) => i.category == c && i.status != BagItemStatus.skip)
          .toList();

  BagStage stageOf(BagItem i) => bagStageOf(i);

  /// Items needing the mother's attention (anything active that isn't packed),
  /// ordered by where they are in the journey (decision first).
  List<BagItem> needingAttention() {
    const order = {
      BagStage.needsDecision: 0,
      BagStage.planningToBuy: 1,
      BagStage.readyAtHome: 2,
    };
    final list = active.where((i) => !i.packed).toList()
      ..sort((a, b) =>
          (order[bagStageOf(a)] ?? 9).compareTo(order[bagStageOf(b)] ?? 9));
    return list;
  }

  // ---- progress (Shopping % + Packing %, never raw counts) ------------------
  int get _activeCount => active.length;

  /// Of the active items, how many are sorted (already have / bought).
  int get _acquiredCount => active
      .where((i) =>
          i.status == BagItemStatus.have ||
          ((i.status == BagItemStatus.buyVeda ||
                  i.status == BagItemStatus.buyElse) &&
              i.purchased))
      .length;
  int get _packedCount => active.where((i) => i.packed).length;

  /// 0..1 - how much of the bag is acquired (have / bought).
  double get shoppingProgress =>
      _activeCount == 0 ? 0 : _acquiredCount / _activeCount;

  /// 0..1 - how much of the bag is packed.
  double get packingProgress =>
      _activeCount == 0 ? 0 : _packedCount / _activeCount;

  bool get allPacked => _activeCount > 0 && _packedCount == _activeCount;

  // ---- load -----------------------------------------------------------------
  Future<void> init() async {
    if (!_boughtHooked) {
      _boughtHooked = true;
      BoughtStore.instance.addListener(markBoughtFromBought);
    }
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final meta = prefs.getString(_metaKey);
      if (meta != null) {
        final m = jsonDecode(meta) as Map;
        _onboarded = m['onboarded'] == true;
        _updatedIso = m['updatedIso']?.toString();
        _delivery = DeliveryType.values.firstWhere(
            (d) => d.name == (m['delivery'] ?? 'unsure'),
            orElse: () => DeliveryType.unsure);
      }
      final raw = prefs.getString(_itemsKey);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _items.add(BagItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    markBoughtFromBought();
    notifyListeners();
    await syncStateFromCloud();
  }

  // --- cloud sync ------------------------------------------------------------
  @override
  String get cloudKey => 'hb2';
  @override
  Object cloudData() => {
        'items': _items.map((i) => i.toJson()).toList(),
        'onboarded': _onboarded,
        'delivery': _delivery.name,
        'updatedIso': _updatedIso,
      };
  @override
  void applyCloudData(Object data) {
    final m = data as Map;
    _items
      ..clear()
      ..addAll(((m['items'] as List?) ?? const [])
          .map((e) => BagItem.fromJson(Map<String, dynamic>.from(e))));
    _onboarded = m['onboarded'] == true;
    _updatedIso = m['updatedIso']?.toString();
    _delivery = DeliveryType.values.firstWhere(
        (d) => d.name == (m['delivery'] ?? 'unsure'),
        orElse: () => DeliveryType.unsure);
  }

  @override
  Future<void> persistLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _itemsKey, jsonEncode(_items.map((i) => i.toJson()).toList()));
    await prefs.setString(
        _metaKey,
        jsonEncode({
          'onboarded': _onboarded,
          'delivery': _delivery.name,
          'updatedIso': _updatedIso,
        }));
  }

  // ---- mutations ------------------------------------------------------------
  Future<void> createBag(List<BagItem> defaults, DeliveryType delivery) async {
    _items
      ..clear()
      ..addAll(defaults);
    _delivery = delivery;
    _onboarded = true;
    await _save();
  }

  Future<void> setStatus(String id, BagItemStatus status) async {
    final i = byId(id);
    if (i == null) return;
    i.status = status;
    if (status != BagItemStatus.buyVeda) i.selectedProductId = null;
    await _save();
  }

  Future<void> chooseVedaProduct(String id,
      {required String productId, required int price}) async {
    final i = byId(id);
    if (i == null) return;
    i.status = BagItemStatus.buyVeda;
    i.selectedProductId = productId;
    i.price = price;
    await _save();
  }

  Future<void> setBuyElse(String id,
      {required String store,
      String link = '',
      int? price,
      String notes = ''}) async {
    final i = byId(id);
    if (i == null) return;
    i.status = BagItemStatus.buyElse;
    i.store = store;
    i.link = link;
    i.price = price;
    i.notes = notes;
    await _save();
  }

  Future<void> togglePacked(String id) async {
    final i = byId(id);
    if (i == null) return;
    i.packed = !i.packed;
    await _save();
  }

  Future<void> setPurchased(String id, bool value) async {
    final i = byId(id);
    if (i == null || i.purchased == value) return;
    i.purchased = value;
    await _save();
  }

  /// "I don't think I need this" → the gentle Maybe-later set (never deleted).
  Future<void> moveToMaybeLater(String id) => setStatus(id, BagItemStatus.skip);

  /// One-tap restore from Maybe later.
  Future<void> restore(String id) => setStatus(id, BagItemStatus.needed);

  Future<void> addCustomItem(String name, BagCategory category,
      {String notes = ''}) async {
    final clean = name.trim();
    if (clean.isEmpty) return;
    _items.add(BagItem(
      id: 'cust_${DateTime.now().microsecondsSinceEpoch}',
      category: category,
      name: LocalizedText(en: clean, hi: clean),
      isCustom: true,
      notes: notes,
      status: BagItemStatus.needed,
    ));
    await _save();
  }

  /// Custom items can be removed outright (catalogue items use Maybe-later).
  Future<void> removeItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _save();
  }

  /// Mirror BoughtStore → mark any chosen-from-ParentVeda item as purchased
  /// once its product id is bought (so the journey advances automatically).
  void markBoughtFromBought() {
    var changed = false;
    for (final i in _items) {
      if (i.status == BagItemStatus.buyVeda &&
          !i.purchased &&
          i.selectedProductId != null &&
          BoughtStore.instance.isBought(i.selectedProductId!)) {
        i.purchased = true;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      _save();
    }
  }

  // ---- persistence ----------------------------------------------------------
  Future<void> _save() async {
    _updatedIso = DateTime.now().toIso8601String();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _itemsKey, jsonEncode(_items.map((i) => i.toJson()).toList()));
      await prefs.setString(
          _metaKey,
          jsonEncode({
            'onboarded': _onboarded,
            'delivery': _delivery.name,
            'updatedIso': _updatedIso,
          }));
    } catch (_) {/* best-effort */}
  }
}
