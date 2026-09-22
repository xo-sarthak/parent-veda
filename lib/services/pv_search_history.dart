// =============================================================================
//  PvSearchHistory — what she searched for in the store, most recent first
// -----------------------------------------------------------------------------
//  Every marketplace search screen opens on "Recent" (eBay, UNIQLO, StubHub,
//  Mobbin 2026-09-20) because the second search is usually the first one
//  again. Eight entries, local, `shared_preferences`; a convenience, not a
//  record, so it does not sync (the family model puts it with bookmarks if
//  it ever does).
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PvSearchHistory extends ChangeNotifier {
  PvSearchHistory._();
  static final PvSearchHistory instance = PvSearchHistory._();

  static const _key = 'pv_store_search_history_v1';
  static const _max = 8;

  final List<String> _recent = [];
  bool _loaded = false;

  List<String> get recent => List.unmodifiable(_recent);

  Future<void> init() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final v = (await SharedPreferences.getInstance()).getStringList(_key);
      if (v != null) _recent.addAll(v);
    } catch (_) {
      /* start empty */
    }
    notifyListeners();
  }

  void add(String query) {
    final q = query.trim();
    if (q.length < 2) return;
    _recent.removeWhere((x) => x.toLowerCase() == q.toLowerCase());
    _recent.insert(0, q);
    if (_recent.length > _max) _recent.removeRange(_max, _recent.length);
    _save();
  }

  void remove(String query) {
    _recent.remove(query);
    _save();
  }

  void clear() {
    _recent.clear();
    _save();
  }

  Future<void> _save() async {
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).setStringList(
        _key,
        _recent,
      );
    } catch (_) {
      /* best-effort */
    }
  }

  @visibleForTesting
  void resetForTest() {
    _recent.clear();
    _loaded = false;
  }
}
