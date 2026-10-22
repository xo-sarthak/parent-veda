// =============================================================================
//  HospitalBagStore
// -----------------------------------------------------------------------------
//  "My Hospital Bag ❤️" - a personalized preparation planner (NOT a checklist).
//  Local-only persistence (shared_preferences). Holds the mother's bag: a list
//  of items, each with a state (needed / already-have / buy-from-ParentVeda /
//  buy-elsewhere / skip) plus a "packed" flag, optional buy details and an
//  optional ParentVeda recommendation. Everything autosaves; nothing is
//  mandatory; there is no fixed target.
//
//  ChangeNotifier so the screens react. Mirrors the style of [ToolsStore].
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_language.dart';
import 'bought_store.dart';
import 'remote/cloud_merged_store.dart';
// import 'remote/cloud_synced_store.dart'; // kept for revert (step 13)

/// The six default sections, plus a "custom" bucket for the mother's own items.
enum BagCategory { labour, afterDelivery, baby, partner, documents, comfort, custom }

/// The decision the mother has made about an item. `packed` is tracked
/// separately (you can pack something you already have or have bought).
enum BagItemStatus { needed, have, buyVeda, buyElse, skip }

/// Optional onboarding hint that lets us suggest a few extra items.
enum DeliveryType { unsure, vaginal, csection }

/// Common "buy elsewhere" stores (plus free-text Other).
const List<String> kBagStores = ['Amazon', 'FirstCry', 'Local store', 'Other'];

BagCategory _catFromString(String s) =>
    BagCategory.values.firstWhere((c) => c.name == s,
        orElse: () => BagCategory.custom);

BagItemStatus _statusFromString(String s) =>
    BagItemStatus.values.firstWhere((c) => c.name == s,
        orElse: () => BagItemStatus.needed);

/// The ParentVeda "trust layer" for a recommended product - never pushy.
@immutable
class BagRecommendation {
  const BagRecommendation({
    this.title,
    this.price,
    this.why = const [],
    this.consider = const [],
  });

  /// e.g. "Best Overall".
  final LocalizedText? title;

  /// ParentVeda price in ₹ (null = no price shown).
  final int? price;

  /// "Why ParentVeda recommends this" - max 3.
  final List<LocalizedText> why;

  /// "Things to consider".
  final List<LocalizedText> consider;

  // BOTH halves are persisted, matching how BagItem.name already stores itself.
  //
  // This is not optional tidiness. LocalizedText.toString() returns `.now`, so
  // the old `map((e) => e.toString())` would have written whichever language
  // happened to be on screen at save time and thrown the other away - silently,
  // permanently, and differently depending on when the row was written.
  // A store must never resolve language; it caches every column the model
  // holds, both languages, and lets the screen choose.
  static Map<String, String> _pair(LocalizedText t) => {'en': t.en, 'hi': t.hi};

  Map<String, dynamic> toJson() => {
        'title': title == null ? null : _pair(title!),
        'price': price,
        'why': why.map(_pair).toList(),
        'consider': consider.map(_pair).toList(),
      };

  factory BagRecommendation.fromJson(Map<String, dynamic> j) =>
      BagRecommendation(
        // LocalizedText.fromJson already accepts a bare string, so rows written
        // before this change - which hold plain English - still load, with the
        // English standing in for both halves rather than orphaning the item.
        title: j['title'] == null ? null : LocalizedText.fromJson(j['title']),
        price: (j['price'] as num?)?.toInt(),
        why: ((j['why'] as List?) ?? [])
            .map(LocalizedText.fromJson)
            .toList(),
        consider: ((j['consider'] as List?) ?? [])
            .map(LocalizedText.fromJson)
            .toList(),
      );
}

/// A single item in the hospital bag.
class BagItem {
  BagItem({
    required this.id,
    required this.category,
    required this.name,
    this.isCustom = false,
    this.recommendation,
    this.status = BagItemStatus.needed,
    this.packed = false,
    this.purchased = false,
    this.favourite = false,
    this.store = '',
    this.link = '',
    this.price,
    this.notes = '',
    this.selectedProductId,
  });

  final String id;
  final BagCategory category;
  final LocalizedText name;
  final bool isCustom;
  final BagRecommendation? recommendation;

  // Mutable planning state.
  BagItemStatus status;
  bool packed;
  bool purchased; // bought (separate from packed). Auto-set for ParentVeda buys.
  bool favourite; // the mother's own "favourites" list (her must-haves)
  String store; // for buyElse
  String link; // for buyElse
  int? price; // chosen product price (buyVeda) or user-entered (buyElse)
  String notes; // for buyElse
  String? selectedProductId; // which ParentVeda product was chosen (buyVeda)

  bool get isSkipped => status == BagItemStatus.skip;
  bool get isPlanned => status != BagItemStatus.skip;

  /// The cost this item contributes (₹): chosen product price for buyVeda,
  /// user-entered price for buyElse, otherwise 0.
  int get plannedCost {
    if (status == BagItemStatus.buyVeda) {
      return price ?? recommendation?.price ?? 0;
    }
    if (status == BagItemStatus.buyElse) return price ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'name': {'en': name.en, 'hi': name.hi},
        'isCustom': isCustom,
        'recommendation': recommendation?.toJson(),
        'status': status.name,
        'packed': packed,
        'purchased': purchased,
        'favourite': favourite,
        'store': store,
        'link': link,
        'price': price,
        'notes': notes,
        'selectedProductId': selectedProductId,
      };

  factory BagItem.fromJson(Map<String, dynamic> j) {
    final n = (j['name'] as Map?) ?? const {};
    return BagItem(
      id: (j['id'] ?? '').toString(),
      category: _catFromString((j['category'] ?? 'custom').toString()),
      name: LocalizedText(
        en: (n['en'] ?? '').toString(),
        hi: (n['hi'] ?? n['en'] ?? '').toString(),
      ),
      isCustom: j['isCustom'] == true,
      recommendation: j['recommendation'] == null
          ? null
          : BagRecommendation.fromJson(
              Map<String, dynamic>.from(j['recommendation'])),
      status: _statusFromString((j['status'] ?? 'needed').toString()),
      packed: j['packed'] == true,
      purchased: j['purchased'] == true,
      favourite: j['favourite'] == true,
      store: (j['store'] ?? '').toString(),
      link: (j['link'] ?? '').toString(),
      price: (j['price'] as num?)?.toInt(),
      notes: (j['notes'] ?? '').toString(),
      selectedProductId: j['selectedProductId']?.toString(),
    );
  }
}

// In the cloud per item since step 13 (2026-10-22, sync log). It synced as one
// whole blob before, so two phones packing different items erased each
// other's ticks. Items: `item|<id>` = the item's JSON; `order` = the list of
// item ids (changes only on create, add or remove); `onboarded`, `delivery`
// and `updatedIso` one item each, written only when set.
class HospitalBagStore extends ChangeNotifier with CloudMergedStore {
  HospitalBagStore._();
  static final HospitalBagStore instance = HospitalBagStore._();

  static const _itemsKey = 'hb_items';
  static const _metaKey = 'hb_meta'; // {onboarded, updatedIso, delivery}

  final List<BagItem> _items = [];
  bool _onboarded = false;
  String? _updatedIso;
  DeliveryType _delivery = DeliveryType.unsure;
  bool _loaded = false;

  // ---- Getters --------------------------------------------------------------

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

  // Progress (skipped items never count).
  List<BagItem> get planned => _items.where((i) => i.isPlanned).toList();
  int get plannedCount => planned.length;
  int get packedCount =>
      _items.where((i) => i.isPlanned && i.packed).length;
  int get remainingCount => plannedCount - packedCount;
  int get percentReady =>
      plannedCount == 0 ? 0 : ((packedCount / plannedCount) * 100).round();

  // Per-category.
  List<BagItem> itemsIn(BagCategory c) =>
      _items.where((i) => i.category == c).toList();
  int plannedCountIn(BagCategory c) =>
      itemsIn(c).where((i) => i.isPlanned).length;
  int packedCountIn(BagCategory c) =>
      itemsIn(c).where((i) => i.isPlanned && i.packed).length;

  /// Categories that currently have at least one item (in display order).
  List<BagCategory> get activeCategories {
    const order = [
      BagCategory.labour,
      BagCategory.afterDelivery,
      BagCategory.baby,
      BagCategory.partner,
      BagCategory.documents,
      BagCategory.comfort,
      BagCategory.custom,
    ];
    return order.where((c) => itemsIn(c).isNotEmpty).toList();
  }

  // Cost totals (kept strictly separate, per the spec).
  int _sumCost(BagItemStatus status) {
    var total = 0;
    for (final i in _items) {
      if (i.status == status) total += i.plannedCost;
    }
    return total;
  }

  int get vedaTotal => _sumCost(BagItemStatus.buyVeda);
  int get externalTotal => _sumCost(BagItemStatus.buyElse);
  int get totalPlanned => vedaTotal + externalTotal;

  // Status groupings (for the Shopping + Planner views).
  List<BagItem> withStatus(BagItemStatus s) =>
      _items.where((i) => i.status == s).toList();

  /// Items the partner can help buy (anything to be bought, not yet packed).
  List<BagItem> get pendingPurchases => _items
      .where((i) =>
          (i.status == BagItemStatus.buyVeda ||
              i.status == BagItemStatus.buyElse) &&
          !i.packed)
      .toList();

  /// Planner filter. [key] ∈ all|fav|veda|else|owned|packed|pending|skipped.
  List<BagItem> filter(String key) {
    switch (key) {
      case 'fav':
        return _items.where((i) => i.favourite).toList();
      case 'veda':
        return withStatus(BagItemStatus.buyVeda);
      case 'else':
        return withStatus(BagItemStatus.buyElse);
      case 'owned':
        return withStatus(BagItemStatus.have);
      case 'packed':
        return _items.where((i) => i.isPlanned && i.packed).toList();
      case 'pending':
        return withStatus(BagItemStatus.needed);
      case 'skipped':
        return withStatus(BagItemStatus.skip);
      case 'all':
      default:
        return _items.where((i) => i.isPlanned).toList();
    }
  }

  /// Free-text search across item names (planned + custom + skipped).
  List<BagItem> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _items
        .where((i) =>
            i.name.en.toLowerCase().contains(q) ||
            i.name.hi.toLowerCase().contains(q))
        .toList();
  }

  // ---- Load -----------------------------------------------------------------

  Future<void> init() async {
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
    // Auto-reflect in-app ParentVeda purchases as "bought" - now and on change.
    BoughtStore.instance.addListener(markBoughtFromBought);
    markBoughtFromBought();
    notifyListeners();
    // await syncStateFromCloud(); // kept for revert (step 13)
    await syncMergedFromCloud();
  }

  // --- cloud sync ------------------------------------------------------------
  @override
  String get cloudKey => 'hb';
  // Kept for revert (step 13): the whole-blob mixin's empty state and blob.
  // /// What a sign-out resets this store to (2026-10-17): the blob of a store nobody has used.
  // @override
  // Object get cloudEmptyData => const <String, Object?>{};
  //
  // @override
  // Object cloudData() => {
  //       'items': _items.map((i) => i.toJson()).toList(),
  //       'onboarded': _onboarded,
  //       'updatedIso': _updatedIso,
  //       'delivery': _delivery.name,
  //     };

  @override
  String? get legacyBlobKey => cloudKey;

  @override
  Map<String, Object?> cloudItems() => {
        for (final i in _items) 'item|${i.id}': i.toJson(),
        if (_items.isNotEmpty) 'order': [for (final i in _items) i.id],
        if (_onboarded) 'onboarded': true,
        if (_delivery != DeliveryType.unsure) 'delivery': _delivery.name,
        if (_updatedIso != null) 'updatedIso': _updatedIso,
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _items.clear();
    _onboarded = false;
    _delivery = DeliveryType.unsure;
    _updatedIso = null;
    final byId = <String, BagItem>{};
    var order = const <String>[];
    for (final e in items.entries) {
      final k = e.key;
      final v = e.value;
      if (k == 'onboarded') {
        _onboarded = v == true;
      } else if (k == 'delivery') {
        _delivery = DeliveryType.values.firstWhere((d) => d.name == v,
            orElse: () => DeliveryType.unsure);
      } else if (k == 'updatedIso') {
        _updatedIso = v?.toString();
      } else if (k == 'order' && v is List) {
        order = v.map((x) => x.toString()).toList();
      } else if (k.startsWith('item|') && v is Map) {
        try {
          final item = BagItem.fromJson(Map<String, dynamic>.from(v));
          byId[item.id] = item;
        } catch (_) {/* an item this build cannot read is skipped */}
      }
    }
    // The saved order first; an item the order does not know (added on the
    // other phone while this one reordered) goes after, by id.
    for (final id in order) {
      final item = byId.remove(id);
      if (item != null) _items.add(item);
    }
    _items.addAll(byId.values.toList()..sort((a, b) => a.id.compareTo(b.id)));
    _loaded = true; // a later init must not read stale prefs over this
  }

  /// The old whole blob, read once on a phone that holds nothing yet.
  @override
  void applyLegacyBlob(Object blob) {
    final m = blob as Map;
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
          'updatedIso': _updatedIso,
          'delivery': _delivery.name,
        }));
  }

  // ---- Mutations ------------------------------------------------------------

  Future<void> togglePurchased(String id) async {
    final i = byId(id);
    if (i == null) return;
    i.purchased = !i.purchased;
    await _touch();
  }

  Future<void> setPurchased(String id, bool value) async {
    final i = byId(id);
    if (i == null || i.purchased == value) return;
    i.purchased = value;
    await _touch();
  }

  /// Set [purchased] for any "buy from ParentVeda" item whose chosen product has
  /// been bought through the in-app preview checkout (BoughtStore). Idempotent.
  void markBoughtFromBought() {
    var changed = false;
    for (final i in _items) {
      if (i.status == BagItemStatus.buyVeda && !i.purchased) {
        final pid = i.selectedProductId ?? '${i.id}_pv';
        if (BoughtStore.instance.isBought(pid)) {
          i.purchased = true;
          changed = true;
        }
      }
    }
    if (changed) _touch();
  }

  /// Replace the bag with a freshly generated default set and mark onboarded.
  Future<void> createBag(List<BagItem> defaults, DeliveryType delivery) async {
    _items
      ..clear()
      ..addAll(defaults);
    _delivery = delivery;
    _onboarded = true;
    await _touch();
  }

  Future<void> setStatus(String id, BagItemStatus status) async {
    final i = byId(id);
    if (i == null) return;
    i.status = status;
    // Leaving the "buy from ParentVeda" choice clears the chosen product.
    if (status != BagItemStatus.buyVeda) i.selectedProductId = null;
    await _touch();
  }

  /// Choose a ParentVeda product for this item (sets it to "buy from ParentVeda"
  /// and records the chosen product + its price for the cost totals).
  Future<void> chooseVedaProduct(
    String id, {
    required String productId,
    required int price,
  }) async {
    final i = byId(id);
    if (i == null) return;
    i.status = BagItemStatus.buyVeda;
    i.selectedProductId = productId;
    i.price = price;
    await _touch();
  }

  Future<void> togglePacked(String id) async {
    final i = byId(id);
    if (i == null) return;
    i.packed = !i.packed;
    await _touch();
  }

  /// The mother's own favourites - her must-have items, regardless of category.
  Future<void> toggleFavourite(String id) async {
    final i = byId(id);
    if (i == null) return;
    i.favourite = !i.favourite;
    await _touch();
  }

  List<BagItem> get favourites =>
      _items.where((i) => i.favourite).toList();
  int get favouriteCount => favourites.length;

  Future<void> setBuyElse(
    String id, {
    required String store,
    String link = '',
    int? price,
    String notes = '',
  }) async {
    final i = byId(id);
    if (i == null) return;
    i.status = BagItemStatus.buyElse;
    i.store = store;
    i.link = link;
    i.price = price;
    i.notes = notes;
    await _touch();
  }

  Future<void> addCustomItem(String name, BagCategory category) async {
    final clean = name.trim();
    if (clean.isEmpty) return;
    _items.add(BagItem(
      id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
      category: category,
      name: LocalizedText(en: clean, hi: clean),
      isCustom: true,
      status: BagItemStatus.have, // personal items are usually already owned
    ));
    await _touch();
  }

  /// Add one of the "suggested essentials" into the bag (if not already there).
  Future<void> addSuggested(BagItem item) async {
    if (_items.any((i) => i.id == item.id)) {
      // already present - un-skip it if it was skipped
      final existing = byId(item.id)!;
      if (existing.isSkipped) existing.status = BagItemStatus.needed;
    } else {
      _items.add(item);
    }
    await _touch();
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _touch();
  }

  Future<void> restore(String id) async {
    final i = byId(id);
    if (i == null) return;
    i.status = BagItemStatus.needed;
    await _touch();
  }

  // ---- Persistence ----------------------------------------------------------

  Future<void> _touch() async {
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
            'updatedIso': _updatedIso,
            'delivery': _delivery.name,
          }));
    } catch (_) {/* best-effort */}
  }
}
