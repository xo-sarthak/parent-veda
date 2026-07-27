// =============================================================================
//  TtcRitualStore - completion of the five-minute daily ritual
// -----------------------------------------------------------------------------
//  The TTC counterpart to Garbh Sanskar's daily face: an N/5 counter and a day
//  streak, and nothing else.
//
//  Two deliberate softenings, because this stage is already anxious enough:
//
//   * A day counts towards the streak if the couple did ANY ONE part. Requiring
//     all five would turn a five-minute calming practice into a fifth thing to
//     fail at.
//   * A broken streak is never announced, never coloured, and never compared.
//     The number simply reads what is true today. There is no "you lost your
//     streak" state anywhere in this file, and there must never be one.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/supabase_repo.dart';
import 'ttc_daily_data.dart';
import 'ttc_sync.dart';

class TtcRitualStore extends ChangeNotifier with TtcSyncedStore {
  TtcRitualStore._() {
    _load();
  }
  static final TtcRitualStore instance = TtcRitualStore._();

  static const _key = 'ttc_ritual_done';

  /// "yyyy-mm-dd" → the parts completed that day.
  final Map<String, Set<TtcRitualPart>> _done = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  static String _key4(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Set<TtcRitualPart> _for(DateTime day) =>
      _done[_key4(day)] ?? const <TtcRitualPart>{};

  bool isDone(TtcRitualPart part, {DateTime? on}) =>
      _for(on ?? DateTime.now()).contains(part);

  /// How many of the five are done today.
  int completedToday({DateTime? on}) => _for(on ?? DateTime.now()).length;

  int get total => TtcRitualPart.values.length;

  /// Consecutive days with at least one part completed, counting back from
  /// today. Today not being started yet does NOT break the streak - a streak
  /// that resets at midnight would punish someone for not having got to it yet.
  int streak({DateTime? on}) {
    final today = on ?? DateTime.now();
    var day = DateTime(today.year, today.month, today.day);
    // If today is empty, start counting from yesterday.
    if (_for(day).isEmpty) day = day.subtract(const Duration(days: 1));
    var n = 0;
    while (_for(day).isNotEmpty) {
      n++;
      day = day.subtract(const Duration(days: 1));
    }
    return n;
  }

  void toggle(TtcRitualPart part, {DateTime? on}) {
    final d = on ?? DateTime.now();
    final k = _key4(d);
    final set = _done.putIfAbsent(k, () => <TtcRitualPart>{});
    final removed = set.remove(part);
    if (!removed) set.add(part);
    if (set.isEmpty) _done.remove(k);
    _persist();
    // Un-ticking has to reach the cloud, or the union pull re-ticks it.
    if (removed && SupabaseRepo.isLoggedIn) {
      SupabaseRepo.deleteMatch(TtcTables.ritual, {
        'user_id': SupabaseRepo.userId!,
        'part': part.name,
        'completed_on': k,
      }).catchError((_) {});
    }
    notifyListeners();
  }

  @visibleForTesting
  void resetForTest() {
    _done.clear();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      for (final row in p.getStringList(_key) ?? const <String>[]) {
        final i = row.lastIndexOf('|');
        if (i <= 0) continue;
        final day = row.substring(0, i);
        final part = TtcRitualPart.values
            .where((e) => e.name == row.substring(i + 1))
            .firstOrNull;
        if (part == null) continue;
        _done.putIfAbsent(day, () => <TtcRitualPart>{}).add(part);
      }
    } catch (_) {/* keep defaults */}
    _loaded = true;
    notifyListeners();
    await syncFromCloud();
  }

  // ---- cloud ----------------------------------------------------------------
  //  COUPLE-SCOPED: "Today's conversation" is not something one person
  //  completes alone.
  //
  //  Note what is NOT synced: the streak. It is derived from these rows, so it
  //  cannot arrive from the cloud in a state that disagrees with the ticks -
  //  and there is nowhere for a "longest streak" to creep in later.

  @override
  Future<void> pullFromCloud() async {
    final rows = await SupabaseRepo.fetchShared(TtcTables.ritual,
        orderBy: 'completed_on', ascending: true);
    for (final row in rows) {
      final day = row['completed_on']?.toString();
      final part = TtcRitualPart.values
          .where((e) => e.name == row['part'])
          .firstOrNull;
      if (day == null || part == null) continue;
      _done.putIfAbsent(day, () => <TtcRitualPart>{}).add(part);
    }
  }

  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    await TtcSyncUtil.upsertAll(
      TtcTables.ritual,
      [
        for (final entry in _done.entries)
          for (final part in entry.value)
            {
              'user_id': uid,
              'part': part.name,
              'completed_on': entry.key,
            }
      ],
      onConflict: 'user_id,part,completed_on',
    );
  }

  @override
  Future<void> persistLocalCache() => _persist();

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      final rows = <String>[
        for (final e in _done.entries)
          for (final part in e.value) '${e.key}|${part.name}',
      ];
      await p.setStringList(_key, rows);
    } catch (_) {/* best-effort */}
  }
}
