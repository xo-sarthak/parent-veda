// =============================================================================
//  ProductChecklistStore - user-built checklists over the product catalogue
// -----------------------------------------------------------------------------
//  Lets a mother turn ParentVeda's products into her own checklists: she browses
//  the catalogue, adds the products she wants, tags each with a custom "when /
//  for" note ("Day zero", "First month") and ticks them off as she gets them.
//  A few curated starter lists give her a head start. Persisted locally.
//
//  ⚠️ PER ITEM SINCE P4 (2026-10-28). It synced as one whole blob
//  (CloudSyncedStore), so a tick on one phone and a new item on the other
//  erased each other: the last phone to write replaced the whole list. It now
//  merges item by item (CloudMergedStore, the step-13 pattern, migration
//  0110's `pv_state_merge`; no new migration). Items:
//    `list|<listId>`            {name, items: [item ids in order]}
//    `item|<listId>|<itemId>`   the item's JSON (tick, note, custom fields)
//    `order`                    [list ids, oldest first]
//  A tick is one `item|` key, so two phones ticking two things both keep
//  them. The old blob (`product_checklists`) is read once on a phone that has
//  not merged yet, so nothing she made before is lost.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_merged_store.dart';
// import 'remote/cloud_synced_store.dart'; // kept for revert (P4 P4)

/// One item on a checklist. Either a CATALOG product (non-empty [productId],
/// resolved via productById) OR a mother's OWN custom product (empty productId
/// + its own [name]/[link]/[price]). [id] is unique within the list (the
/// productId for catalog items; a generated id for custom ones). Plus a custom
/// "when/for" [note] and a "got it" [checked] flag.
class ChecklistItem {
  ChecklistItem({
    required this.id,
    this.productId = '',
    this.name = '',
    this.link = '',
    this.price = '',
    this.note = '',
    this.checked = false,
  });
  final String id;
  final String productId; // '' for a custom product
  final String name; // custom product name ('' for catalog)
  final String link; // custom product link (optional)
  final String price; // custom product price (optional)
  String note; // the custom timing/label, e.g. "Day zero"
  bool checked; // got it

  bool get isCustom => productId.isEmpty;

  /// A named thing from a starter list (2026-10-28): the custom shape, but
  /// not hers, so it does not wear "Added by you".
  bool get isStarter => isCustom && id.startsWith(kStarterItemPrefix);

  Map<String, dynamic> toJson() => {
        'id': id,
        'p': productId,
        'name': name,
        'link': link,
        'price': price,
        'n': note,
        'c': checked,
      };
  factory ChecklistItem.fromJson(Map<String, dynamic> j) => ChecklistItem(
        // Back-compat: old items had no 'id' - fall back to the productId.
        id: (j['id'] as String?) ?? (j['p'] as String? ?? ''),
        productId: j['p'] as String? ?? '',
        name: j['name'] as String? ?? '',
        link: j['link'] as String? ?? '',
        price: j['price'] as String? ?? '',
        note: j['n'] as String? ?? '',
        checked: j['c'] as bool? ?? false,
      );
}

/// A named, user-created checklist of products.
class ProductChecklist {
  ProductChecklist({required this.id, required this.name, List<ChecklistItem>? items})
      : items = items ?? [];
  final String id;
  String name;
  final List<ChecklistItem> items;

  /// Ticked only. ⚠️ The screen counts "owned" (ticked OR bought) since P4
  /// P3; use [ownedCount] wherever she reads a number.
  int get gotCount => items.where((i) => i.checked).length;

  /// Ticked or bought: the same rule the list's "Got" group uses (P4 P3,
  /// 2026-10-28). The progress said "1 of 3" while "Got" held two.
  int ownedCount(bool Function(ChecklistItem item) isBought) =>
      items.where((i) => i.checked || isBought(i)).length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'items': items.map((i) => i.toJson()).toList(),
      };
  factory ProductChecklist.fromJson(Map<String, dynamic> j) => ProductChecklist(
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        items: (j['items'] as List?)
                ?.map((e) => ChecklistItem.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [],
      );
}

/// The id prefix of an item a starter list put on her list (2026-10-28).
const String kStarterItemPrefix = 'starter_';

/// A pre-made starter list a mother can adopt (then make her own).
@immutable
class CuratedList {
  const CuratedList(
      {required this.name,
      required this.emoji,
      required this.items,
      this.forNewborn = false});
  final String name;
  final String emoji;
  // Kept for revert (seed retired 2026-10-28, the user: no fake products):
  //   final List<({String productId, String note})> items;
  /// Named things to get, in the custom-item shape: [productId] is '' (no
  /// invented product behind the name), [name] is what she reads and what
  /// the store is searched for, [fromWeek] the pregnancy week it is due
  /// from (null = any week), which orders the starters for her week.
  final List<({String productId, String name, String note, int? fromWeek})>
      items;

  /// A list for a baby on the way. After a loss it steps aside (D4); the
  /// lists she made stay.
  final bool forNewborn;
}

/// Curated starters: named things to get (2026-10-28; they were seed
/// `kProducts` ids until the seed was retired, see below).
///
/// ⚠️ P4 P5 (2026-10-28): "Newborn essentials" held a swaddle, a nursing bra
/// and a breast pump: two of the three are for her, not the newborn, and the
/// catalogue has no other newborn products (its eight categories are pillow,
/// stretch care, maternity wear, belly band, compression socks, nursing bra,
/// breast pump and swaddle). Renamed honestly instead. A list she already
/// adopted keeps the name it had. Kept for revert:
///   CuratedList(name: 'Newborn essentials', emoji: '👶', items: [...]),
const String kFeedingStarterName = 'Feeding and first weeks';

///
/// ⚠️ NAMED THINGS, NOT SEED PRODUCTS (2026-10-28, the user: "no need to
/// have fake situations in the app... show whatever we have"). Each item was
/// a seed product id (`sw_overall`, `nb_overall`...), so the list showed an
/// invented brand, a seed price, a seed rating and a photo. Each is now the
/// thing itself ("Nursing bras") with no product behind it; "See it in the
/// store" searches the real store for that name, and every name here finds
/// real products or, where the sheet has none yet ("Belly support band"),
/// the store's "Coming soon" place-holder, never an empty search
/// (test/store_no_seed_products_test.dart holds it). The weeks are the old
/// seed products' own, so the order for her week is unchanged. Kept for
/// revert:
///   CuratedList(name: kFeedingStarterName, emoji: '👶', forNewborn: true, items: [
///     (productId: 'sw_overall', note: 'From birth'),
///     (productId: 'nb_overall', note: 'From birth'),
///     (productId: 'bp_overall', note: 'From birth'),
///   ]),
///   CuratedList(name: 'Bump comfort', emoji: '🤰', items: [
///     (productId: 'pp_overall', note: '2nd–3rd trimester'),
///     (productId: 'bb_overall', note: '2nd–3rd trimester'),
///     (productId: 'cs_overall', note: '2nd–3rd trimester'),
///   ]),
///   CuratedList(name: 'Skin & body', emoji: '🧴', items: [
///     (productId: 'sc_overall', note: 'Daily, 2nd trimester on'),
///     (productId: 'mw_overall', note: 'From 2nd trimester'),
///   ]),
const List<CuratedList> kCuratedChecklists = [
  CuratedList(name: kFeedingStarterName, emoji: '👶', forNewborn: true, items: [
    (productId: '', name: 'Swaddles', note: 'From birth', fromWeek: 34),
    (productId: '', name: 'Nursing bras', note: 'From birth', fromWeek: 30),
    (productId: '', name: 'Breast pump', note: 'From birth', fromWeek: 34),
  ]),
  CuratedList(name: 'Bump comfort', emoji: '🤰', items: [
    (
      productId: '',
      name: 'Pregnancy pillow',
      note: '2nd–3rd trimester',
      fromWeek: 16,
    ),
    // No real belly band in the sheet yet: its search finds the store's
    // "Coming soon" place-holder (pv_coming_soon.dart), which steps aside
    // the day the sheet adds one.
    (
      productId: '',
      name: 'Belly support band',
      note: '2nd–3rd trimester',
      fromWeek: 20,
    ),
    (
      productId: '',
      name: 'Compression socks',
      note: '2nd–3rd trimester',
      fromWeek: 20,
    ),
  ]),
  CuratedList(name: 'Skin & body', emoji: '🧴', items: [
    (
      productId: '',
      name: 'Stretch mark cream',
      note: 'Daily, 2nd trimester on',
      fromWeek: 12,
    ),
    (
      productId: '',
      name: 'Maternity leggings',
      note: 'From 2nd trimester',
      fromWeek: 14,
    ),
  ]),
];

/// How near a starter item's week must be to count as due now: the store's
/// own `kPvDueSoonWeeks` (pv_catalog_store.dart), restated so this store
/// does not import the catalogue.
const int _kStarterDueSoonWeeks = 4;

/// The starter lists for her: after a loss the newborn ones step aside (D4),
/// and with a real week the list whose items are due soonest comes first
/// (P4 P5). [tierOf] is `pvWeekTier` for a product id (0 due within four
/// weeks, 1 no week, 2 further off); null [week] keeps the order. Stable.
List<CuratedList> curatedForHer(
  List<CuratedList> lists, {
  int? week,
  bool afterLoss = false,
  int Function(String productId, int week)? tierOf,
}) {
  final shown = [
    for (final l in lists)
      if (!afterLoss || !l.forNewborn) l,
  ];
  // Kept for revert (seed retired 2026-10-28): the tier came from the seed
  // product behind each item; the items carry their own week now.
  //   if (week == null || tierOf == null) return shown;
  //   int best(CuratedList l) => l.items.isEmpty
  //       ? 1
  //       : l.items
  //           .map((i) => tierOf(i.productId, week))
  //           .reduce((a, b) => a < b ? a : b);
  if (week == null) return shown;
  int tier(({String productId, String name, String note, int? fromWeek}) i) {
    final from = i.fromWeek;
    if (from != null) {
      return (from - week).abs() <= _kStarterDueSoonWeeks ? 0 : 2;
    }
    if (i.productId.isNotEmpty && tierOf != null) {
      return tierOf(i.productId, week);
    }
    return 1;
  }

  int best(CuratedList l) =>
      l.items.isEmpty ? 1 : l.items.map(tier).reduce((a, b) => a < b ? a : b);
  final indexed = [for (var i = 0; i < shown.length; i++) (i, shown[i])];
  indexed.sort((a, b) {
    final t = best(a.$2).compareTo(best(b.$2));
    return t != 0 ? t : a.$1.compareTo(b.$1);
  });
  return [for (final e in indexed) e.$2];
}

// Kept for revert (P4 P4): class ProductChecklistStore extends ChangeNotifier with CloudSyncedStore {
class ProductChecklistStore extends ChangeNotifier with CloudMergedStore {
  ProductChecklistStore._();
  static final ProductChecklistStore instance = ProductChecklistStore._();

  static const _key = 'product_checklists';

  final List<ProductChecklist> _lists = [];
  bool _loaded = false;
  int _seq = 0;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _lists.add(ProductChecklist.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
    // await syncStateFromCloud(); // kept for revert (P4 P4)
    await syncMergedFromCloud();
  }

  // --- queries ---
  // Newest first (most recently created lists appear at the top).
  List<ProductChecklist> get checklists =>
      List.unmodifiable(_lists.reversed.toList());
  bool get isEmpty => _lists.isEmpty;

  ProductChecklist? byId(String id) {
    for (final l in _lists) {
      if (l.id == id) return l;
    }
    return null;
  }

  bool isInChecklist(String checklistId, String productId) =>
      byId(checklistId)?.items.any((i) => i.productId == productId) ?? false;

  // --- mutations ---
  String createChecklist(String name) {
    final id = _newId();
    final clean = name.trim();
    _lists.add(ProductChecklist(id: id, name: clean.isEmpty ? 'My checklist' : clean));
    _persistNotify();
    return id;
  }

  void renameChecklist(String id, String name) {
    final l = byId(id);
    if (l == null || name.trim().isEmpty) return;
    l.name = name.trim();
    _persistNotify();
  }

  void deleteChecklist(String id) {
    _lists.removeWhere((l) => l.id == id);
    _persistNotify();
  }

  /// Where a list sits (oldest first), or -1. Kept by the screen for Undo.
  int listIndexOf(String id) => _lists.indexWhere((l) => l.id == id);

  /// Undo for [deleteChecklist]: the same list, items and all, back in place.
  void restoreChecklist(ProductChecklist list, int index) {
    if (byId(list.id) != null) return;
    _lists.insert(index.clamp(0, _lists.length), list);
    _persistNotify();
  }

  /// Undo for [removeItem]: the same item back at its place in the list.
  void restoreItem(String checklistId, ChecklistItem item, int index) {
    final l = byId(checklistId);
    if (l == null || l.items.any((i) => i.id == item.id)) return;
    l.items.insert(index.clamp(0, l.items.length), item);
    _persistNotify();
  }

  void addItem(String checklistId, String productId, {String note = ''}) {
    final l = byId(checklistId);
    if (l == null || l.items.any((i) => i.productId == productId)) return;
    l.items.add(ChecklistItem(id: productId, productId: productId, note: note));
    _persistNotify();
  }

  /// Add the mother's OWN product (not in our catalogue).
  void addCustomItem(String checklistId,
      {required String name,
      String link = '',
      String price = '',
      String note = ''}) {
    final l = byId(checklistId);
    if (l == null || name.trim().isEmpty) return;
    _seq++;
    l.items.add(ChecklistItem(
      id: 'custom_${DateTime.now().microsecondsSinceEpoch}_$_seq',
      name: name.trim(),
      link: link.trim(),
      price: price.trim(),
      note: note.trim(),
    ));
    _persistNotify();
  }

  void removeItem(String checklistId, String itemId) {
    final l = byId(checklistId);
    if (l == null) return;
    l.items.removeWhere((i) => i.id == itemId);
    _persistNotify();
  }

  void toggleChecked(String checklistId, String itemId) {
    final l = byId(checklistId);
    if (l == null) return;
    for (final i in l.items) {
      if (i.id == itemId) {
        i.checked = !i.checked;
        _persistNotify();
        return;
      }
    }
  }

  void setNote(String checklistId, String itemId, String note) {
    final l = byId(checklistId);
    if (l == null) return;
    for (final i in l.items) {
      if (i.id == itemId) {
        i.note = note.trim();
        _persistNotify();
        return;
      }
    }
  }

  /// Create a new checklist from a curated starter (a copy she can edit).
  String adoptCurated(CuratedList c) {
    final id = _newId();
    // Kept for revert (seed retired 2026-10-28): each item was a seed product.
    //   items: c.items
    //       .map((e) =>
    //           ChecklistItem(id: e.productId, productId: e.productId, note: e.note))
    //       .toList(),
    _lists.add(ProductChecklist(
      id: id,
      name: c.name,
      items: [
        for (final e in c.items)
          if (e.productId.isNotEmpty)
            ChecklistItem(id: e.productId, productId: e.productId, note: e.note)
          else
            ChecklistItem(
              id: '$kStarterItemPrefix${DateTime.now().microsecondsSinceEpoch}_${++_seq}',
              name: e.name,
              note: e.note,
            ),
      ],
    ));
    _persistNotify();
    return id;
  }

  // --- internals ---
  String _newId() {
    _seq++;
    return 'cl_${DateTime.now().microsecondsSinceEpoch}_$_seq';
  }

  // --- cloud sync ------------------------------------------------------------
  // The same cloudKey: the items live at `product_checklists:items`, and the
  // old blob stays at `product_checklists`, read once and kept for revert.
  @override
  String get cloudKey => 'product_checklists';

  // Kept for revert (P4 P4): the whole-blob mixin's empty state and blob.
  //   /// What a sign-out resets this store to (2026-10-17): the blob of a store nobody has used.
  //   @override
  //   Object get cloudEmptyData => const <Object>[];
  //
  //   @override
  //   Object cloudData() => _lists.map((l) => l.toJson()).toList();
  //   @override
  //   void applyCloudData(Object data) {
  //     _lists
  //       ..clear()
  //       ..addAll((data as List)
  //           .map((e) => ProductChecklist.fromJson(Map<String, dynamic>.from(e))));
  //   }

  @override
  String? get legacyBlobKey => cloudKey;

  /// The old whole blob (a list of lists), read once on a phone that has
  /// not merged yet: the same reading the old `applyCloudData` did.
  @override
  void applyLegacyBlob(Object blob) {
    _lists
      ..clear()
      ..addAll((blob as List)
          .map((e) => ProductChecklist.fromJson(Map<String, dynamic>.from(e))));
    _loaded = true;
  }

  @override
  Map<String, Object?> cloudItems() => {
        for (final l in _lists) ...{
          'list|${l.id}': {
            'name': l.name,
            'items': [for (final i in l.items) i.id],
          },
          for (final i in l.items) 'item|${l.id}|${i.id}': i.toJson(),
        },
        if (_lists.isNotEmpty) 'order': [for (final l in _lists) l.id],
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    final heads = <String, Map>{};
    final byList = <String, Map<String, ChecklistItem>>{};
    var order = const <String>[];
    for (final e in items.entries) {
      final k = e.key;
      final v = e.value;
      if (k == 'order' && v is List) {
        order = v.map((x) => x.toString()).toList();
      } else if (k.startsWith('list|') && v is Map) {
        heads[k.substring('list|'.length)] = v;
      } else if (k.startsWith('item|') && v is Map) {
        final rest = k.substring('item|'.length);
        final bar = rest.indexOf('|');
        if (bar <= 0) continue;
        try {
          final item = ChecklistItem.fromJson(Map<String, dynamic>.from(v));
          (byList[rest.substring(0, bar)] ??= {})[item.id] = item;
        } catch (_) {/* an item this build cannot read is skipped */}
      }
    }
    ProductChecklist build(String id) {
      final head = heads[id]!;
      final found = byList.remove(id) ?? {};
      final ordered = <ChecklistItem>[];
      for (final itemId in (head['items'] as List? ?? const [])) {
        final it = found.remove(itemId.toString());
        if (it != null) ordered.add(it);
      }
      // An item the head's order does not know yet (added on the other phone
      // while this one reordered): after the rest, by id.
      ordered.addAll(found.values.toList()..sort((a, b) => a.id.compareTo(b.id)));
      return ProductChecklist(
          id: id, name: head['name']?.toString() ?? '', items: ordered);
    }

    _lists.clear();
    for (final id in order) {
      if (heads.containsKey(id)) _lists.add(build(id));
    }
    // A list the order does not know: after, by id (ids carry the time).
    final rest = heads.keys.where((id) => !order.contains(id)).toList()..sort();
    for (final id in rest) {
      _lists.add(build(id));
    }
    // Items whose list was removed on another phone are dropped here; the
    // next change on this phone sends their removal too.
    _loaded = true;
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
      await prefs.setString(
          _key, jsonEncode(_lists.map((l) => l.toJson()).toList()));
    } catch (_) {/* best-effort */}
  }
}
