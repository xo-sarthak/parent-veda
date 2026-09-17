// =============================================================================
//  PvCompareStore — the compare tray, two at a time, one category
// -----------------------------------------------------------------------------
//  A tray rather than screen state, because the real journey is: tick one on
//  the shelf, open it, read it, go back, tick another. It has to outlive both
//  screens, so it is a singleton like every other store (the TTC shop learnt
//  this the hard way — "Compare button is not working").
//
//  Two, enforced HERE. A third would be a table nobody reads at 11 pm; adding
//  a third drops the oldest. Cross-category compare is refused with a reason
//  the screen shows — comparing a stroller with a thermometer is a table with
//  no shared rows.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../models/pv_product.dart';

enum PvCompareResult { added, removed, replaced, wrongCategory }

class PvCompareStore extends ChangeNotifier {
  PvCompareStore._();
  static final PvCompareStore instance = PvCompareStore._();

  final List<PvProduct> _items = [];

  List<PvProduct> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  bool get isFull => _items.length >= 2;
  bool contains(String id) => _items.any((p) => p.id == id);
  String? get categoryId => _items.isEmpty ? null : _items.first.categoryId;

  PvCompareResult toggle(PvProduct p) {
    final idx = _items.indexWhere((x) => x.id == p.id);
    if (idx >= 0) {
      _items.removeAt(idx);
      notifyListeners();
      return PvCompareResult.removed;
    }
    if (_items.isNotEmpty && _items.first.categoryId != p.categoryId) {
      return PvCompareResult.wrongCategory;
    }
    var replaced = false;
    if (_items.length >= 2) {
      _items.removeAt(0);
      replaced = true;
    }
    _items.add(p);
    notifyListeners();
    return replaced ? PvCompareResult.replaced : PvCompareResult.added;
  }

  void remove(String id) {
    _items.removeWhere((x) => x.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Seed the tray from a shelf (the `pp_compare/<sub>` deep link): up to two,
  /// replacing whatever was there.
  void preload(Iterable<PvProduct> shelf) {
    _items.clear();
    for (final p in shelf) {
      if (_items.length >= 2) break;
      _items.add(p);
    }
    notifyListeners();
  }
}
