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

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/supabase_repo.dart';
import 'ttc_daily_data.dart';
import 'ttc_row_merge.dart';
import 'ttc_sync.dart';

// =============================================================================
//  WHOSE TICK IS IT (2026-10-17, 0098)
// -----------------------------------------------------------------------------
//  The table is couple-scoped and keyed by (user_id, part, day), so each tick
//  is one person's row. The old store poured the partner's rows into her own
//  set, showed them as hers, and pushed them back up as hers. Un-ticking
//  deleted only her row, so his brought it straight back.
//
//  The user's rule: a SHARED part is the couple's, an INDIVIDUAL part is each
//  person's own (`kTtcSharedRitualParts`).
//
//   · Individual (reflection, breath, gratitude, action): only her own rows
//     decide what she sees. His breath is not her breath.
//   · Shared (conversation): the NEWEST row across both of them decides, tick
//     or un-tick. Her un-tick is a row of hers with `removed_at`, newer than
//     his tick, so it wins without this phone ever writing his row.
//
//  Each phone writes only its own rows. That is what keeps two people from
//  overwriting each other: there is no row both of them update.
// =============================================================================

class TtcRitualStore extends ChangeNotifier with TtcSyncedStore {
  TtcRitualStore._() {
    _load();
  }
  static final TtcRitualStore instance = TtcRitualStore._();

  static const _key = 'ttc_ritual_done';
  static const _bookKey = 'ttc_ritual_sync';
  static const _partnerKey = 'ttc_ritual_partner';

  // Kept for revert (2026-10-17): one map for both people's ticks.
  //   /// "yyyy-mm-dd" → the parts completed that day.
  //   final Map<String, Set<TtcRitualPart>> _done = {};

  /// Her own live ticks, as "yyyy-mm-dd|part".
  final Set<String> _mine = {};

  /// Times, un-ticks and what is waiting to upload, for her own rows.
  final TtcRowBook _book = TtcRowBook();

  /// The partner's rows, read-only here: key -> its time and whether it is a
  /// tick (true) or an un-tick (false).
  final Map<String, ({int at, bool live})> _partner = {};

  bool _loaded = false;

  bool get isLoaded => _loaded;

  @override
  bool get hasPendingPush => _book.dirty.isNotEmpty;

  @visibleForTesting
  TtcRowBook get bookForTest => _book;

  static String _key4(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Whether [part] reads as done on [day] for her, by the rule above.
  bool _ticked(String day, TtcRitualPart part) {
    final k = '$day|${part.name}';
    final mine = _mine.contains(k);
    if (!kTtcSharedRitualParts.contains(part)) return mine;
    final his = _partner[k];
    if (his == null) return mine;
    final myAt = _book.stamps[k];
    // She has no time on it: never touched, or ticked before this release.
    if (myAt == null) return mine || his.live;
    if (his.at > myAt) return his.live;
    if (myAt > his.at) return mine;
    return mine || his.live;
  }

  Set<TtcRitualPart> _for(DateTime day) {
    final d = _key4(day);
    return {
      for (final p in TtcRitualPart.values)
        if (_ticked(d, p)) p,
    };
  }

  /// Did the COUPLE do anything that day, either of them, any part. Only the
  /// streak reads this, so the `ritual_week` milestone counts what it always
  /// counted.
  bool _coupleDidAny(DateTime day) {
    final d = _key4(day);
    for (final p in TtcRitualPart.values) {
      final k = '$d|${p.name}';
      if (_mine.contains(k) || (_partner[k]?.live ?? false)) return true;
    }
    return false;
  }

  bool isDone(TtcRitualPart part, {DateTime? on}) =>
      _for(on ?? DateTime.now()).contains(part);

  /// How many of the five are done today.
  int completedToday({DateTime? on}) => _for(on ?? DateTime.now()).length;

  int get total => TtcRitualPart.values.length;

  /// ⚠️ NOT FOR DISPLAY (tools pass, 2026-09-27). The Mind & body brief rules
  /// out streaks, and the ritual screen no longer shows a count at all. Kept
  /// (not commented out) only because the `ritual_week` milestone and two home
  /// cards still read it; those cards are owned elsewhere and flagged for
  /// removal. Do not add a new reader.
  ///
  /// Consecutive days with at least one part completed, counting back from
  /// today. Today not being started yet does NOT break the streak - a streak
  /// that resets at midnight would punish someone for not having got to it yet.
  int streak({DateTime? on}) {
    final today = on ?? DateTime.now();
    var day = DateTime(today.year, today.month, today.day);
    // If today is empty, start counting from yesterday.
    // Kept for revert (2026-10-17): `_for(day).isEmpty` / `.isNotEmpty`.
    if (!_coupleDidAny(day)) day = day.subtract(const Duration(days: 1));
    var n = 0;
    while (_coupleDidAny(day)) {
      n++;
      day = day.subtract(const Duration(days: 1));
    }
    return n;
  }

  /// Flips what she SEES. On a shared part that her partner ticked, her
  /// un-tick is a newer row of hers, and it wins on both phones.
  void toggle(TtcRitualPart part, {DateTime? on}) {
    final d = on ?? DateTime.now();
    final day = _key4(d);
    final k = '$day|${part.name}';
    if (_ticked(day, part)) {
      _mine.remove(k);
      _book.remove(k, const {});
    } else {
      _mine.add(k);
      _book.touch(k);
    }
    _persist();
    // Kept for revert (2026-10-17): the un-tick was a hard delete, which an
    // offline phone or the other phone's old row undid.
    //   if (removed && SupabaseRepo.isLoggedIn) {
    //     SupabaseRepo.deleteMatch(TtcTables.ritual, {
    //       'user_id': SupabaseRepo.userId!,
    //       'part': part.name,
    //       'completed_on': k,
    //     }).catchError((_) {});
    //   }
    notifyListeners();
  }

  /// A sign-out, or another account signing in (2026-10-17): this store forgets the person in memory; the cloud keeps it.
  @override
  void resetLocal() => resetForTest();

  @visibleForTesting
  void resetForTest() {
    _mine.clear();
    _book.clear();
    _partner.clear();
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
        final part = TtcRitualPart.values
            .where((e) => e.name == row.substring(i + 1))
            .firstOrNull;
        if (part == null) continue;
        _mine.add(row);
      }
      final book = p.getString(_bookKey);
      if (book != null) _book.loadJson(jsonDecode(book));
      final partner = p.getString(_partnerKey);
      if (partner != null) {
        final m = jsonDecode(partner);
        if (m is Map) {
          for (final e in m.entries) {
            final v = e.value;
            if (v is List && v.length == 2 && v[0] is num) {
              _partner[e.key.toString()] =
                  (at: (v[0] as num).toInt(), live: v[1] == true);
            }
          }
        }
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
    applyCloudRows(rows, me: SupabaseRepo.userId);
  }

  /// The merge, network-free so a test can hand it rows (2026-10-17, 0098).
  /// Her rows merge newer-wins into her own ticks; his are only remembered.
  @visibleForTesting
  void applyCloudRows(List<Map<String, dynamic>> rows, {required String? me}) {
    final own = <Map<String, dynamic>>[];
    _partner.clear();
    for (final row in rows) {
      final day = row['completed_on']?.toString();
      final part = TtcRitualPart.values
          .where((e) => e.name == row['part'])
          .firstOrNull;
      if (day == null || part == null) continue;
      final k = '$day|${part.name}';
      final owner = row['user_id']?.toString();
      if (me != null && owner != null && owner != me) {
        final at =
            ttcParseStamp(row['updated_at'])?.millisecondsSinceEpoch ?? 0;
        final seen = _partner[k];
        if (seen != null && seen.at >= at) continue;
        _partner[k] = (at: at, live: ttcParseStamp(row['removed_at']) == null);
        continue;
      }
      own.add({...row, 'id': k});
    }
    for (final row in _book.merge(_mine, own)) {
      final k = row['id'] as String;
      if (_book.removed.containsKey(k)) {
        _mine.remove(k);
      } else {
        _mine.add(k);
      }
    }
  }

  // Kept for revert (2026-10-17): the union pull, both people into one set.
  // ignore: unused_element
  Future<void> _pullUnionKept(Map<String, Set<TtcRitualPart>> done) async {
    final rows = await SupabaseRepo.fetchShared(TtcTables.ritual,
        orderBy: 'completed_on', ascending: true);
    for (final row in rows) {
      final day = row['completed_on']?.toString();
      final part = TtcRitualPart.values
          .where((e) => e.name == row['part'])
          .firstOrNull;
      if (day == null || part == null) continue;
      done.putIfAbsent(day, () => <TtcRitualPart>{}).add(part);
    }
  }

  /// Her own rows only, only what is waiting, each confirmed (2026-10-17).
  /// Never the partner's: his ticks are his phone's to write.
  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    for (final k in List.of(_book.dirty)) {
      final i = k.lastIndexOf('|');
      final live = _mine.contains(k);
      if (i <= 0 || (!live && !_book.removed.containsKey(k))) {
        _book.dirty.remove(k);
        continue;
      }
      final sent = _book.stamps[k] ??=
          DateTime.now().toUtc().millisecondsSinceEpoch;
      final t = _book.times(k);
      final ok = await TtcSyncUtil.upsertConfirmed(
        TtcTables.ritual,
        {
          'user_id': uid,
          'part': k.substring(i + 1),
          'completed_on': k.substring(0, i),
          'updated_at': t.updatedAt,
          'removed_at': live ? null : t.removedAt,
        },
        onConflict: 'user_id,part,completed_on',
      );
      _book.confirmed(k, ok: ok, sent: sent);
    }
    await _persist();
  }

  // Kept for revert (2026-10-17): every tick, both people's, as hers.
  // ignore: unused_element
  Future<void> _pushAllKept(Map<String, Set<TtcRitualPart>> done) async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    await TtcSyncUtil.upsertAll(
      TtcTables.ritual,
      [
        for (final entry in done.entries)
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
      // Same "day|part" lines as before, now her own ticks only.
      await p.setStringList(_key, _mine.toList());
      await p.setString(_bookKey, jsonEncode(_book.toJson()));
      await p.setString(_partnerKey, jsonEncode({
        for (final e in _partner.entries) e.key: [e.value.at, e.value.live],
      }));
    } catch (_) {/* best-effort */}
  }
}
