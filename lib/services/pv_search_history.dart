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

import 'remote/cloud_merged_store.dart';
// import 'remote/sync_registry.dart'; // kept for revert (step 13: the mixin registers)

// In the cloud since step 13 (2026-10-22, sync log). The "does not sync" note
// above is kept as history: it was phone-only, so a sign-out or a new phone
// emptied "Recent". One item per query, value = when last searched (epoch ms);
// on apply the newest eight win, de-duplicated without case.
class PvSearchHistory extends ChangeNotifier with CloudMergedStore {
  PvSearchHistory._();
  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   PvSearchHistory._() {
  //     SyncRegistry.registerReset(_resetForAccount);
  //   }
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
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getStringList(_key);
      if (v != null) _recent.addAll(v);
      _readTimes(prefs);
    } catch (_) {
      /* start empty */
    }
    notifyListeners();
    await syncMergedFromCloud();
  }

  // ---- the cloud (step 13) --------------------------------------------------

  /// query -> when last used (epoch ms). Kept beside the list in prefs under
  /// `<key>_at`, so the times survive a restart.
  final Map<String, int> _at = {};

  String get _atKey => '${_key}_at';

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
  String get cloudKey => 'pv_store_search_history';

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
    _recent
      ..clear()
      ..addAll(out);
    _loaded = true;
  }

  static int _num(Object? v) => v is num ? v.toInt() : 0;

  @override
  Future<void> persistLocalCache() => _save();

  void add(String query) {
    final q = query.trim();
    if (q.length < 2) return;
    _recent.removeWhere((x) => x.toLowerCase() == q.toLowerCase());
    _recent.insert(0, q);
    _at[q] = DateTime.now().millisecondsSinceEpoch;
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _key,
        _recent,
      );
      await prefs.setStringList(
          _atKey, [for (final q in _recent) '${_at[q] ?? 0}']);
    } catch (_) {
      /* best-effort */
    }
  }

  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  //   // are wiped, the singleton was not.
  //   void _resetForAccount() {
  //     resetForTest();
  //     notifyListeners();
  //   }

  @visibleForTesting
  void resetForTest() {
    _recent.clear();
    _at.clear();
    _loaded = false;
  }
}
