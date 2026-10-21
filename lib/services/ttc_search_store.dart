// =============================================================================
//  TtcSearchStore — what she searched for inside a Trying-to-Conceive door
// -----------------------------------------------------------------------------
//  The TTC twin of `PvSearchStore`, and a twin rather than a shared store on
//  purpose: a pregnancy mother's recent searches ("NT scan") are not what a
//  woman still trying wants offered back to her, and one household can hold
//  both stages. A separate key keeps the two histories apart.
//
//  ⚠️ `ttc_search_recent` IS AN IDENTITY. It is persisted in
//  shared_preferences; renaming it strands every history already saved.
//
//  Local-first like every store: six strings on the phone, newest first, no
//  cloud copy. A search history is the one list she is happiest to lose.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/sync_registry.dart';

class TtcSearchStore extends ChangeNotifier {
  TtcSearchStore._() {
    SyncRegistry.registerReset(_resetForAccount);
  }
  static final TtcSearchStore instance = TtcSearchStore._();

  static const String kKey = 'ttc_search_recent';
  static const int _max = 6;

  List<String> _recent = const [];
  bool _loaded = false;

  List<String> get recent => _recent;

  Future<void> init() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _recent = prefs.getStringList(kKey) ?? const [];
    } catch (_) {
      _recent = const [];
    }
    notifyListeners();
  }

  /// Remember a query that led somewhere. Trimmed, de-duplicated, newest
  /// first, capped: a history, not a log.
  Future<void> remember(String q) async {
    final s = q.trim();
    if (s.isEmpty) return;
    _recent = [
      s,
      ..._recent.where((r) => r.toLowerCase() != s.toLowerCase()),
    ].take(_max).toList();
    notifyListeners();
    await _save();
  }

  // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  // are wiped, the singleton was not.
  // clear() also writes prefs, so this one touches memory only.
  void _resetForAccount() {
    _recent = const [];
    _loaded = false;
    notifyListeners();
  }

  Future<void> clear() async {
    _recent = const [];
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(kKey, _recent);
    } catch (_) {}
  }
}
