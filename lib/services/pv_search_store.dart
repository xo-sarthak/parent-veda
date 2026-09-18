// =============================================================================
//  PvSearchStore — what she searched for, so the search screen opens useful
// -----------------------------------------------------------------------------
//  A search screen with an empty query has to show SOMETHING, and every app on
//  Mobbin shows the same two things: what you looked for last (GoodRx, Yazio,
//  Apple Health) and a short list of places to start (Flo, Bloom, CVS). The
//  second is derived from the doors; this store is the first.
//
//  Local-first, like every store: six strings in `shared_preferences`, newest
//  first, no cloud copy — a search history is the one list the user is
//  happiest to lose with the phone.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PvSearchStore extends ChangeNotifier {
  PvSearchStore._();
  static final PvSearchStore instance = PvSearchStore._();

  static const _key = 'pv_search_recent';
  static const _max = 6;

  List<String> _recent = const [];
  bool _loaded = false;

  List<String> get recent => _recent;

  Future<void> init() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _recent = prefs.getStringList(_key) ?? const [];
    } catch (_) {
      _recent = const [];
    }
    notifyListeners();
  }

  /// Remember a query that led somewhere. Trimmed, de-duplicated, newest
  /// first, capped — a history, not a log.
  Future<void> remember(String q) async {
    final s = q.trim();
    if (s.isEmpty) return;
    final next = [s, ..._recent.where((r) => r.toLowerCase() != s.toLowerCase())]
        .take(_max)
        .toList();
    _recent = next;
    notifyListeners();
    await _save();
  }

  Future<void> clear() async {
    _recent = const [];
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, _recent);
    } catch (_) {}
  }
}
