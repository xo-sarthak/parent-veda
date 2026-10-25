// =============================================================================
//  DailyStore
// -----------------------------------------------------------------------------
//  Local-only persistence for the Home Screen "Daily Moment":
//    * Emotional Check-In moods   (one per day, stored permanently)
//    * Talk To Your Baby entries  (saved to the Dear Baby vault)
//    * Kept Nurture affirmations  ("Keep This With Me")
//    * Baby Movement responses    (Week 28+, stored per day)
//
//  shared_preferences only - no files. ChangeNotifier so Home cards react.
//  Mirrors the lightweight style of [MemoryStore].
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/own_row_ledger.dart';
import 'pregnancy_records.dart';
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';
import 'remote/sync_row_book.dart';

/// A single Talk-To-Baby message saved into Dear Baby. Text-based for now
/// (spoken notes are transcribed via speech-to-text before saving).
@immutable
class TalkEntry {
  const TalkEntry({
    required this.id,
    required this.day,
    required this.week,
    required this.prompt,
    required this.text,
    required this.dateIso,
    required this.spoken,
  });

  final String id;
  final int day;
  final int week;
  final String prompt;
  final String text;
  final String dateIso;

  /// True when captured by voice (transcribed), false when typed.
  final bool spoken;

  Map<String, dynamic> toJson() => {
        'id': id,
        'day': day,
        'week': week,
        'prompt': prompt,
        'text': text,
        'dateIso': dateIso,
        'spoken': spoken,
      };

  factory TalkEntry.fromJson(Map<String, dynamic> j) => TalkEntry(
        id: (j['id'] ?? '').toString(),
        day: (j['day'] is int) ? j['day'] : int.tryParse('${j['day']}') ?? 0,
        week: (j['week'] is int) ? j['week'] : int.tryParse('${j['week']}') ?? 0,
        prompt: (j['prompt'] ?? '').toString(),
        text: (j['text'] ?? '').toString(),
        dateIso: (j['dateIso'] ?? '').toString(),
        spoken: j['spoken'] == true,
      );
}

class DailyStore extends ChangeNotifier implements PregnancyScopedStore {
  DailyStore._();
  static final DailyStore instance = DailyStore._();

  static const _moodKey = 'daily_moods'; // {day: moodId}
  static const _talkKey = 'dear_baby_talk'; // [TalkEntry]
  static const _keptKey = 'kept_affirmations'; // [String text]
  static const _movementKey = 'daily_movement'; // {day: 'yes'|'not_yet'}
  static const _missionKey = 'father_missions'; // {day: true} (Father Mode)

  final Map<int, String> _moods = {};
  final List<TalkEntry> _talk = [];
  final List<String> _kept = [];
  final Map<int, String> _movement = {};
  final Set<int> _missionsDone = {}; // days whose Father mission is marked done
  bool _loaded = false;

  // --- newer-wins sync, one ledger per table (2026-10-20, sync log step 8,
  //     0106). All five tables are own-only. Moods, movement and missions are
  //     keyed by `day`, kept affirmations by their `text`; movement answers
  //     are state, never removed. -------------------------------------------
  final OwnRowLedger _moodSync =
      OwnRowLedger('daily_moods', 'daily_moods_sync', keyColumn: 'day');
  final OwnRowLedger _talkSync = OwnRowLedger('baby_talk', 'baby_talk_sync');
  final OwnRowLedger _keptSync = OwnRowLedger(
      'kept_affirmations', 'kept_affirmations_sync',
      keyColumn: 'text');
  final OwnRowLedger _moveSync = OwnRowLedger(
      'daily_movement_responses', 'daily_movement_sync',
      keyColumn: 'day', hasRemovedAt: false);
  final OwnRowLedger _missionSync =
      OwnRowLedger('father_missions', 'father_missions_sync', keyColumn: 'day');

  List<OwnRowLedger> get _ledgers =>
      [_moodSync, _talkSync, _keptSync, _moveSync, _missionSync];

  /// Changes the cloud has not confirmed (the sign-out sheet reads this).
  bool get hasPending => _ledgers.any((l) => l.hasPending);

  Map<String, Map<String, dynamic>> _moodRows() => {
        for (final e in _moods.entries)
          '${e.key}': {'day': e.key, 'mood_id': e.value},
      };
  Map<String, Map<String, dynamic>> _talkRows() =>
      {for (final e in _talk) e.id: _talkToRow(e)};
  Map<String, Map<String, dynamic>> _keptRows() => {
        for (final t in _kept) t: {'text': t},
      };
  Map<String, Map<String, dynamic>> _moveRows() => {
        for (final e in _movement.entries)
          '${e.key}': {'day': e.key, 'response': e.value},
      };
  Map<String, Map<String, dynamic>> _missionRows() => {
        for (final d in _missionsDone) '$d': {'day': d},
      };

  Future<void> _pushAll() async {
    await _moodSync.push(_moodRows);
    await _talkSync.push(_talkRows);
    await _keptSync.push(_keptRows);
    await _moveSync.push(_moveRows);
    await _missionSync.push(_missionRows);
  }

  // --- getters ---------------------------------------------------------------

  /// The mood chosen for [day], or null if not answered.
  String? moodForDay(int day) => _moods[day];

  /// ⚠️ THIS PREGNANCY'S LETTERS (R1, 2026-10-25). A letter belongs to the
  /// pregnancy whose window holds its date; the letters of a pregnancy that
  /// became a child are read through [talkEntriesIn] by the vault.
  static DateTime _talkDay(TalkEntry e) =>
      DateTime.tryParse(e.dateIso) ??
      DateTime.fromMicrosecondsSinceEpoch(int.tryParse(e.id) ?? 0);

  bool _isMine(TalkEntry e) => PregnancyRecords.instance.inCurrent(_talkDay(e));

  /// [w]'s letters, newest first.
  List<TalkEntry> talkEntriesIn(PregnancyWindow w) =>
      [for (final e in _talk) if (w.holds(_talkDay(e))) e]
        ..sort((a, b) => b.id.compareTo(a.id));

  @override
  int countIn(PregnancyWindow w) => talkEntriesIn(w).length;

  /// Soft deletes that travel (step 8). Moods and the rest are keyed by
  /// pregnancy day and live in the sealed pregnancy's archive instead.
  @override
  Future<int> removeIn(PregnancyWindow w) async {
    final gone = talkEntriesIn(w);
    if (gone.isEmpty) return 0;
    _talk.removeWhere(gone.contains);
    for (final e in gone) {
      _talkSync.remove(e.id, _talkToRow(e));
    }
    notifyListeners();
    await _persist(_talkKey, jsonEncode(_talk.map((e) => e.toJson()).toList()));
    await _talkSync.push(_talkRows);
    return gone.length;
  }

  // ---- A new pregnancy starts clean (R1, 2026-10-25) ------------------------
  // Moods, the father's missions and the movement answers are keyed by the
  // pregnancy DAY, so day 120 of a second pregnancy would land on the first's.
  // When the next pregnancy begins they are copied into the old one's archive
  // (pregnancy_archive.dart) and cleared here, the way her own clearing
  // travels. Movement answers are state with no removal (0106), so they are
  // set to '' (no answer).

  /// Copies the day-keyed records and clears them.
  Future<Map<String, Object?>> takeDaysForNewPregnancy() async {
    final copy = <String, Object?>{
      'moods': {for (final e in _moods.entries) '${e.key}': e.value},
      'missions': [..._missionsDone],
      'movement': {
        for (final e in _movement.entries)
          if (e.value.isNotEmpty) '${e.key}': e.value,
      },
    };
    for (final e in _moods.entries) {
      _moodSync.remove('${e.key}', {'day': e.key, 'mood_id': e.value});
    }
    for (final d in _missionsDone) {
      _missionSync.remove('$d', {'day': d});
    }
    for (final day in _movement.keys.toList()) {
      if (_movement[day]!.isEmpty) continue;
      _movement[day] = '';
      _moveSync.touch('$day', columns: {'day': day, 'response': ''});
    }
    _moods.clear();
    _missionsDone.clear();
    notifyListeners();
    await _persist(_moodKey, jsonEncode({}));
    await _persist(_missionKey, jsonEncode([]));
    await _persist(_movementKey,
        jsonEncode(_movement.map((k, v) => MapEntry(k.toString(), v))));
    await _pushAll();
    return copy;
  }

  /// Puts [copy] back (the undo of a new pregnancy: "the test was wrong").
  Future<void> restoreDays(Object? copy) async {
    if (copy is! Map) return;
    final moods = copy['moods'];
    if (moods is Map) {
      for (final e in moods.entries) {
        final day = int.tryParse('${e.key}');
        if (day != null) await setMood(day, '${e.value}');
      }
    }
    final missions = copy['missions'];
    if (missions is List) {
      for (final d in missions) {
        final day = int.tryParse('$d');
        if (day != null && !_missionsDone.contains(day)) await toggleMissionDone(day);
      }
    }
    final movement = copy['movement'];
    if (movement is Map) {
      for (final e in movement.entries) {
        final day = int.tryParse('${e.key}');
        if (day != null) await setMovement(day, '${e.value}');
      }
    }
  }

  /// Talk-To-Baby entries, newest first.
  List<TalkEntry> get talkEntries {
    // final list = [..._talk]; // kept for revert
    final list = [for (final e in _talk) if (_isMine(e)) e];
    list.sort((a, b) => b.id.compareTo(a.id));
    return list;
  }

  bool isKept(String text) => _kept.contains(text.trim());

  /// Movement response for [day]: 'yes', 'not_yet', or null.
  // String? movementForDay(int day) => _movement[day]; // kept for revert
  /// '' is "no answer": a new pregnancy clears the old one's (R1).
  String? movementForDay(int day) {
    final r = _movement[day];
    return r == null || r.isEmpty ? null : r;
  }

  /// Whether the Father Mode mission for [day] is marked done.
  bool isMissionDone(int day) => _missionsDone.contains(day);

  // --- load ------------------------------------------------------------------

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();

      final m = prefs.getString(_moodKey);
      if (m != null) {
        (jsonDecode(m) as Map).forEach((k, v) {
          final day = int.tryParse(k.toString());
          if (day != null) _moods[day] = v.toString();
        });
      }

      final t = prefs.getString(_talkKey);
      if (t != null) {
        for (final e in (jsonDecode(t) as List)) {
          _talk.add(TalkEntry.fromJson(Map<String, dynamic>.from(e)));
        }
      }

      final k = prefs.getString(_keptKey);
      if (k != null) {
        for (final e in (jsonDecode(k) as List)) {
          _kept.add(e.toString());
        }
      }

      final mv = prefs.getString(_movementKey);
      if (mv != null) {
        (jsonDecode(mv) as Map).forEach((key, v) {
          final day = int.tryParse(key.toString());
          if (day != null) _movement[day] = v.toString();
        });
      }

      final ms = prefs.getString(_missionKey);
      if (ms != null) {
        for (final e in (jsonDecode(ms) as List)) {
          final day = int.tryParse(e.toString());
          if (day != null) _missionsDone.add(day);
        }
      }
    } catch (_) {/* start empty */}
    for (final l in _ledgers) {
      await l.load();
    }
    SyncRegistry.registerPending(() => hasPending);
    _loaded = true;
    notifyListeners();

    // Then sync with the cloud (no-op if logged out).
    await _syncFromCloud();
  }

  // === Cloud sync (Supabase) - two day-maps, a list, a string-list, and the
  //     father's mission-done day set. ==========================================
  /// A sign-out, or another account signing in (2026-10-17): this store
  /// forgets the person in memory; the cloud keeps it.
  void _resetLocal() {
    _moods.clear();
    _talk.clear();
    _kept.clear();
    _movement.clear();
    _missionsDone.clear();
    for (final l in _ledgers) {
      l
        ..clear()
        ..save();
    }
    notifyListeners();
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    SyncRegistry.registerReset(_resetLocal);
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      // Newer wins per row, removals included (step 8, 0106). Each pull
      // returns the cloud rows that are newer than this phone's; each
      // carries its key as `id`.
      bool gone(Map<String, dynamic> r) =>
          syncParseStamp(r['removed_at']) != null;
      int dayOf(Map<String, dynamic> r) => int.tryParse('${r['id']}') ?? -1;

      for (final r in await _moodSync.pull(
          liveKeys: _moods.keys.map((d) => '$d'), orderBy: 'day')) {
        if (gone(r)) {
          _moods.remove(dayOf(r));
        } else {
          _moods[dayOf(r)] = (r['mood_id'] ?? '').toString();
        }
      }
      await _persist(_moodKey,
          jsonEncode(_moods.map((k, v) => MapEntry(k.toString(), v))));

      final talkById = {for (final e in _talk) e.id: e};
      for (final r in await _talkSync.pull(liveKeys: talkById.keys)) {
        if (gone(r)) {
          talkById.remove(r['id']);
        } else {
          talkById[r['id'] as String] = _talkFromRow(r);
        }
      }
      _talk
        ..clear()
        ..addAll(talkById.values);
      await _persist(
          _talkKey, jsonEncode(_talk.map((e) => e.toJson()).toList()));

      for (final r in await _keptSync.pull(liveKeys: List.of(_kept))) {
        final t = r['id'] as String;
        if (gone(r)) {
          _kept.remove(t);
        } else if (!_kept.contains(t)) {
          _kept.add(t);
        }
      }
      await _persist(_keptKey, jsonEncode(_kept));

      for (final r in await _moveSync.pull(
          liveKeys: _movement.keys.map((d) => '$d'), orderBy: 'day')) {
        _movement[dayOf(r)] = (r['response'] ?? '').toString();
      }
      await _persist(_movementKey,
          jsonEncode(_movement.map((k, v) => MapEntry(k.toString(), v))));

      for (final r in await _missionSync.pull(
          liveKeys: _missionsDone.map((d) => '$d'), orderBy: 'day')) {
        if (gone(r)) {
          _missionsDone.remove(dayOf(r));
        } else {
          _missionsDone.add(dayOf(r));
        }
      }
      await _persist(_missionKey, jsonEncode(_missionsDone.toList()));

      notifyListeners();
      await _pushAll();
    } catch (_) {/* offline - keep local */}
  }

  // Kept for revert (step 8, 2026-10-20). Moods and movement never dropped a
  // local day, kept affirmations and missions were a union, and baby talk
  // re-inserted any row only this phone held: a removal could never travel.
  // ignore: unused_element
  Future<void> _syncFromCloudOld() async {
    try {
      // daily_moods - one mood per day, keyed by (user_id, day)
      final moodRows = await SupabaseRepo.fetch('daily_moods',
          orderBy: 'day', ascending: true);
      final cloudMoodDays = <int>{};
      for (final r in moodRows) {
        final day = (r['day'] as num?)?.toInt();
        if (day != null) {
          cloudMoodDays.add(day);
          _moods[day] = (r['mood_id'] ?? '').toString();
        }
      }
      for (final e in _moods.entries) {
        if (!cloudMoodDays.contains(e.key)) {
          await SupabaseRepo.upsert('daily_moods',
              {'day': e.key, 'mood_id': e.value},
              onConflict: 'user_id,day');
        }
      }
      await _persist(_moodKey,
          jsonEncode(_moods.map((k, v) => MapEntry(k.toString(), v))));

      // baby_talk - list, by id
      final talkRows = await SupabaseRepo.fetch('baby_talk');
      final talkById = {
        for (final r in talkRows) r['id'].toString(): _talkFromRow(r)
      };
      for (final e in _talk) {
        if (!talkById.containsKey(e.id)) {
          talkById[e.id] = e;
          await SupabaseRepo.insert('baby_talk', _talkToRow(e));
        }
      }
      _talk
        ..clear()
        ..addAll(talkById.values);
      await _persist(
          _talkKey, jsonEncode(_talk.map((e) => e.toJson()).toList()));

      // kept_affirmations - plain strings, keyed by the text itself
      final keptRows = await SupabaseRepo.fetch('kept_affirmations');
      final cloudKept =
          keptRows.map((r) => (r['text'] ?? '').toString()).toSet();
      for (final t in _kept) {
        if (!cloudKept.contains(t)) {
          await SupabaseRepo.upsert('kept_affirmations', {'text': t},
              onConflict: 'user_id,text');
        }
      }
      final mergedKept = {...cloudKept, ..._kept};
      _kept
        ..clear()
        ..addAll(mergedKept);
      await _persist(_keptKey, jsonEncode(_kept));

      // daily_movement_responses - one response per day, keyed by (user_id, day)
      final mvRows = await SupabaseRepo.fetch('daily_movement_responses',
          orderBy: 'day', ascending: true);
      final cloudMvDays = <int>{};
      for (final r in mvRows) {
        final day = (r['day'] as num?)?.toInt();
        if (day != null) {
          cloudMvDays.add(day);
          _movement[day] = (r['response'] ?? '').toString();
        }
      }
      for (final e in _movement.entries) {
        if (!cloudMvDays.contains(e.key)) {
          await SupabaseRepo.upsert('daily_movement_responses',
              {'day': e.key, 'response': e.value},
              onConflict: 'user_id,day');
        }
      }
      await _persist(_movementKey,
          jsonEncode(_movement.map((k, v) => MapEntry(k.toString(), v))));

      // father_missions - done days, keyed by (user_id, day)
      final missionRows = await SupabaseRepo.fetch('father_missions',
          orderBy: 'day', ascending: true);
      final cloudMissionDays = <int>{};
      for (final r in missionRows) {
        final day = (r['day'] as num?)?.toInt();
        if (day != null) cloudMissionDays.add(day);
      }
      final localMissions = _missionsDone.toSet();
      for (final day in localMissions) {
        if (!cloudMissionDays.contains(day)) {
          await SupabaseRepo.insert('father_missions', {'day': day});
        }
      }
      _missionsDone
        ..clear()
        ..addAll(cloudMissionDays)
        ..addAll(localMissions);
      await _persist(_missionKey, jsonEncode(_missionsDone.toList()));

      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  Map<String, dynamic> _talkToRow(TalkEntry e) => {
        'id': e.id,
        'day': e.day,
        'week': e.week,
        'prompt': e.prompt,
        'text': e.text,
        'date_iso': e.dateIso.isEmpty ? null : e.dateIso,
        'spoken': e.spoken,
      };

  TalkEntry _talkFromRow(Map<String, dynamic> r) => TalkEntry(
        id: (r['id'] ?? '').toString(),
        day: (r['day'] as num?)?.toInt() ?? 0,
        week: (r['week'] as num?)?.toInt() ?? 0,
        prompt: (r['prompt'] ?? '').toString(),
        text: (r['text'] ?? '').toString(),
        dateIso: (r['date_iso'] ?? '').toString(),
        spoken: r['spoken'] == true,
      );

  // --- mutations -------------------------------------------------------------

  String _todayIso() {
    final d = DateTime.now();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> setMood(int day, String moodId) async {
    _moods[day] = moodId;
    _moodSync.touch('$day', columns: {'day': day, 'mood_id': moodId});
    notifyListeners();
    await _persist(_moodKey,
        jsonEncode(_moods.map((k, v) => MapEntry(k.toString(), v))));
    // Kept for revert (step 8): a one-shot upsert, lost offline.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.upsert('daily_moods', {'day': day, 'mood_id': moodId},
    //         onConflict: 'user_id,day');
    //   } catch (_) {}
    // }
    await _moodSync.push(_moodRows);
  }

  Future<void> clearMood(int day) async {
    final was = _moods.remove(day);
    if (was == null) return;
    // A soft delete (step 8): the cleared day travels to her other phones.
    _moodSync.remove('$day', {'day': day, 'mood_id': was});
    notifyListeners();
    await _persist(_moodKey,
        jsonEncode(_moods.map((k, v) => MapEntry(k.toString(), v))));
    // Kept for revert (step 8): a one-shot hard delete, lost offline.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.deleteBy('daily_moods', 'day', day);
    //   } catch (_) {}
    // }
    await _moodSync.push(_moodRows);
  }

  /// Saves (or replaces) the Talk-To-Baby entry for [day] into Dear Baby.
  Future<TalkEntry> saveTalk({
    required int day,
    required int week,
    required String prompt,
    required String text,
    required bool spoken,
  }) async {
    // The day's entry keeps its id and is edited in place (step 8, 0106). It
    // used to be deleted and re-inserted under a new id on every save, so two
    // phones each held a different "today" and both came back.
    final old = talkForDay(day);
    // _talk.removeWhere((e) => e.day == day); // kept for revert
    // Only this pregnancy's letter for the day (R1): an earlier pregnancy's
    // day-N letter is hers too and stays.
    _talk.removeWhere((e) => e.day == day && _isMine(e));
    final entry = TalkEntry(
      id: old?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      day: day,
      week: week,
      prompt: prompt,
      text: text,
      dateIso: _todayIso(),
      spoken: spoken,
    );
    _talk.add(entry);
    _talkSync.touch(entry.id);
    notifyListeners();
    await _persist(
        _talkKey, jsonEncode(_talk.map((e) => e.toJson()).toList()));
    // Kept for revert (step 8): delete the day, insert under a new id.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.deleteBy('baby_talk', 'day', day); // replace this day's entry
    //     await SupabaseRepo.insert('baby_talk', _talkToRow(entry));
    //   } catch (_) {}
    // }
    await _talkSync.push(_talkRows);
    return entry;
  }

  TalkEntry? talkForDay(int day) {
    for (final e in _talk) {
      // if (e.day == day) return e; // kept for revert
      if (e.day == day && _isMine(e)) return e;
    }
    return null;
  }

  /// Appends a free-standing note to the Dear Baby vault (does NOT dedup by
  /// day, unlike [saveTalk]). Used by tools - e.g. a Baby Movement memory.
  Future<TalkEntry> addDearBabyNote({
    required int week,
    required String prompt,
    required String text,
  }) async {
    final entry = TalkEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      day: 0,
      week: week,
      prompt: prompt,
      text: text,
      dateIso: _todayIso(),
      spoken: false,
    );
    _talk.add(entry);
    _talkSync.touch(entry.id);
    notifyListeners();
    await _persist(
        _talkKey, jsonEncode(_talk.map((e) => e.toJson()).toList()));
    // if (SupabaseRepo.isLoggedIn) { // kept for revert (step 8)
    //   try {
    //     await SupabaseRepo.insert('baby_talk', _talkToRow(entry));
    //   } catch (_) {}
    // }
    await _talkSync.push(_talkRows);
    return entry;
  }

  Future<void> toggleKept(String text) async {
    final t = text.trim();
    final wasPresent = _kept.remove(t);
    if (!wasPresent) _kept.add(t);
    // Un-keeping is a soft delete (step 8): a union pull used to keep it.
    if (wasPresent) {
      _keptSync.remove(t, {'text': t});
    } else {
      _keptSync.touch(t, columns: {'text': t});
    }
    notifyListeners();
    await _persist(_keptKey, jsonEncode(_kept));
    // Kept for revert (step 8): one-shot writes, lost offline.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     if (wasPresent) {
    //       await SupabaseRepo.deleteBy('kept_affirmations', 'text', t);
    //     } else {
    //       await SupabaseRepo.upsert('kept_affirmations', {'text': t},
    //           onConflict: 'user_id,text');
    //     }
    //   } catch (_) {}
    // }
    await _keptSync.push(_keptRows);
  }

  Future<void> setMovement(int day, String response) async {
    _movement[day] = response;
    _moveSync.touch('$day', columns: {'day': day, 'response': response});
    notifyListeners();
    await _persist(_movementKey,
        jsonEncode(_movement.map((k, v) => MapEntry(k.toString(), v))));
    // Kept for revert (step 8): a one-shot upsert, lost offline.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.upsert('daily_movement_responses',
    //         {'day': day, 'response': response},
    //         onConflict: 'user_id,day');
    //   } catch (_) {}
    // }
    await _moveSync.push(_moveRows);
  }

  /// Toggles the Father Mode mission-done flag for [day].
  Future<void> toggleMissionDone(int day) async {
    final nowDone = !_missionsDone.remove(day);
    if (nowDone) _missionsDone.add(day);
    // Un-doing is a soft delete (step 8): a union pull used to keep it.
    if (nowDone) {
      _missionSync.touch('$day', columns: {'day': day});
    } else {
      _missionSync.remove('$day', {'day': day});
    }
    notifyListeners();
    await _persist(_missionKey, jsonEncode(_missionsDone.toList()));
    // Kept for revert (step 8): one-shot writes, lost offline.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     if (nowDone) {
    //       await SupabaseRepo.insert('father_missions', {'day': day});
    //     } else {
    //       await SupabaseRepo.deleteBy('father_missions', 'day', day);
    //     }
    //   } catch (_) {}
    // }
    await _missionSync.push(_missionRows);
  }

  Future<void> _persist(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {/* best-effort */}
  }
}
