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

import 'remote/cloud_merged_store.dart';
// import 'remote/sync_registry.dart'; // kept for revert (step 13: the mixin registers)

// In the cloud since step 13 (2026-10-22, sync log). The "no cloud copy" note
// above is kept as history: it was phone-only, so a sign-out or a new phone
// emptied her recent searches. One item per query, value = when last searched
// (epoch ms); on apply the newest six win, de-duplicated without case.
class TtcSearchStore extends ChangeNotifier with CloudMergedStore {
  TtcSearchStore._();
  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   TtcSearchStore._() {
  //     SyncRegistry.registerReset(_resetForAccount);
  //   }
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
      _readTimes(prefs);
    } catch (_) {
      _recent = const [];
    }
    notifyListeners();
    await syncMergedFromCloud();
  }

  // ---- the cloud (step 13) --------------------------------------------------

  /// query -> when last used (epoch ms). Kept beside the list in prefs under
  /// `<key>_at`, so the times survive a restart.
  final Map<String, int> _at = {};

  String get _atKey => '${kKey}_at';

  /// Reads the times saved beside the list; a list from before step 13 gets
  /// small stand-ins in its own order, so any real search outranks them.
  void _readTimes(SharedPreferences prefs) {
    _at.clear();
    final saved = prefs.getStringList(_atKey) ?? const <String>[];
    for (var i = 0; i < _recent.length; i++) {
      final t = i < saved.length && saved.length == _recent.length
          ? int.tryParse(saved[i])
          : null;
      _at[_recent[i]] = t ?? (_recent.length - i);
    }
  }

  @override
  String get cloudKey => 'ttc_search_recent';

  @override
  Map<String, Object?> cloudItems() =>
      {for (final q in _recent) q: _at[q] ?? 0};

  @override
  void applyCloudItems(Map<String, Object?> items) {
    final byTime = items.entries.toList()
      ..sort((a, b) => _num(b.value).compareTo(_num(a.value)));
    final out = <String>[];
    final seen = <String>{};
    _at.clear();
    for (final e in byTime) {
      if (out.length >= _max) break;
      if (!seen.add(e.key.toLowerCase())) continue;
      out.add(e.key);
      _at[e.key] = _num(e.value);
    }
    _recent = out;
    _loaded = true;
  }

  static int _num(Object? v) => v is num ? v.toInt() : 0;

  @override
  Future<void> persistLocalCache() => _save();

  /// Remember a query that led somewhere. Trimmed, de-duplicated, newest
  /// first, capped: a history, not a log.
  Future<void> remember(String q) async {
    final s = q.trim();
    if (s.isEmpty) return;
    _recent = [
      s,
      ..._recent.where((r) => r.toLowerCase() != s.toLowerCase()),
    ].take(_max).toList();
    _at[s] = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
    await _save();
  }

  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  //   // are wiped, the singleton was not.
  //   // clear() also writes prefs, so this one touches memory only.
  //   void _resetForAccount() {
  //     _recent = const [];
  //     _loaded = false;
  //     notifyListeners();
  //   }

  Future<void> clear() async {
    _recent = const [];
    _at.clear();
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(kKey, _recent);
      await prefs.setStringList(
          _atKey, [for (final q in _recent) '${_at[q] ?? 0}']);
    } catch (_) {}
  }
}
