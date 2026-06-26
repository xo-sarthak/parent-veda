// =============================================================================
//  ProductChecklistStore — user-built checklists over the product catalogue
// -----------------------------------------------------------------------------
//  Lets a mother turn ParentVeda's products into her own checklists: she browses
//  the catalogue, adds the products she wants, tags each with a custom "when /
//  for" note ("Day zero", "First month") and ticks them off as she gets them.
//  A few curated starter lists give her a head start. Persisted locally.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        // Back-compat: old items had no 'id' — fall back to the productId.
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

  int get gotCount => items.where((i) => i.checked).length;

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

/// A pre-made starter list a mother can adopt (then make her own).
@immutable
class CuratedList {
  const CuratedList({required this.name, required this.emoji, required this.items});
  final String name;
  final String emoji;
  final List<({String productId, String note})> items;
}

/// Curated starters, built from real `kProducts` ids.
const List<CuratedList> kCuratedChecklists = [
  CuratedList(name: 'Newborn essentials', emoji: '👶', items: [
    (productId: 'sw_overall', note: 'From birth'),
    (productId: 'nb_overall', note: 'From birth'),
    (productId: 'bp_overall', note: 'From birth'),
  ]),
  CuratedList(name: 'Bump comfort', emoji: '🤰', items: [
    (productId: 'pp_overall', note: '2nd–3rd trimester'),
    (productId: 'bb_overall', note: '2nd–3rd trimester'),
    (productId: 'cs_overall', note: '2nd–3rd trimester'),
  ]),
  CuratedList(name: 'Skin & body', emoji: '🧴', items: [
    (productId: 'sc_overall', note: 'Daily, 2nd trimester on'),
    (productId: 'mw_overall', note: 'From 2nd trimester'),
  ]),
];

class ProductChecklistStore extends ChangeNotifier {
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
    _lists.add(ProductChecklist(
      id: id,
      name: c.name,
      items: c.items
          .map((e) =>
              ChecklistItem(id: e.productId, productId: e.productId, note: e.note))
          .toList(),
    ));
    _persistNotify();
    return id;
  }

  // --- internals ---
  String _newId() {
    _seq++;
    return 'cl_${DateTime.now().microsecondsSinceEpoch}_$_seq';
  }

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
