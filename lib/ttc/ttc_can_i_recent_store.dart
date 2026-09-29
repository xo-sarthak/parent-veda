// =============================================================================
//  TTC "Can I...?" - the questions she has checked, newest first
// -----------------------------------------------------------------------------
//  Added 2026-09-29 in the tools rebuild ("a reason to come back"). Every
//  look-up app that people return to keeps what was last looked at on top of
//  the list: Monzo's search suggestions
//  (https://mobbin.com/screens/2f456ff2-f46a-44fa-a7c2-8c247ed51867), HYPE's
//  "Recent searches" with Clear all
//  (https://mobbin.com/screens/f5c7ac0e-ca89-4d05-834b-532af5a4f001), and
//  pregnancy's own Is it safe? door (`CanIActivityStore.recents`).
//
//  ⚠️ LOCAL ONLY, ON PURPOSE. Pregnancy's recents ride `CloudSyncedStore`
//  because they sit beside "my doctor said", which is worth keeping across
//  phones. These are a convenience: losing them on a new phone costs one
//  tap, while syncing them means a new `user_state` key for a list of ids.
//  If the two stores are ever unified, that is the moment to sync.
//
//  ⚠️ IDS, NEVER QUESTION TEXT. An id is identity (CLAUDE.md: `.en` is
//  identity); the question is display and is rewritten from time to time
//  (launch sanity T7 rephrased four of them). An id the data no longer has
//  is skipped on read, never shown as a blank row.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ttc_can_i_data.dart';

class TtcCanIRecentStore extends ChangeNotifier {
  TtcCanIRecentStore._();
  static final TtcCanIRecentStore instance = TtcCanIRecentStore._();

  static const String _key = 'ttc_can_i_recent_v1';

  /// How many are kept. Three are shown; five are kept so clearing one of
  /// the three (or a question leaving the data) still leaves a full row.
  static const int kMax = 5;

  final List<String> _ids = [];
  bool _loaded = false;

  /// The checked answers, newest first, only those the data still has.
  List<TtcCanI> get recent => [
        for (final id in _ids) ?ttcCanIById(id),
      ];

  Future<void> init() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final p = await SharedPreferences.getInstance();
      final saved = p.getStringList(_key) ?? const <String>[];
      // A tap made before the load finished stays first.
      for (final id in saved) {
        if (!_ids.contains(id)) _ids.add(id);
      }
      if (_ids.length > kMax) _ids.removeRange(kMax, _ids.length);
    } catch (_) {/* keep what is in memory */}
    notifyListeners();
  }

  /// She opened an answer. Newest first, no duplicates, capped.
  void touch(String id) {
    _ids
      ..remove(id)
      ..insert(0, id);
    if (_ids.length > kMax) _ids.removeRange(kMax, _ids.length);
    notifyListeners();
    _save();
  }

  /// "Clear": the list goes, the answers do not.
  void clear() {
    if (_ids.isEmpty) return;
    _ids.clear();
    notifyListeners();
    _save();
  }

  void _save() {
    SharedPreferences.getInstance()
        .then((p) => p.setStringList(_key, List.of(_ids)))
        .catchError((_) => false);
  }

  @visibleForTesting
  void resetForTest() {
    _ids.clear();
    _loaded = false;
  }
}
