// =============================================================================
//  DailyStore
// -----------------------------------------------------------------------------
//  Local-only persistence for the Home Screen "Daily Moment":
//    * Emotional Check-In moods   (one per day, stored permanently)
//    * Talk To Your Baby entries  (saved to the Dear Baby vault)
//    * Kept Nurture affirmations  ("Keep This With Me")
//    * Baby Movement responses    (Week 28+, stored per day)
//
//  shared_preferences only — no files. ChangeNotifier so Home cards react.
//  Mirrors the lightweight style of [MemoryStore].
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/supabase_repo.dart';

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

class DailyStore extends ChangeNotifier {
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

  // --- getters ---------------------------------------------------------------

  /// The mood chosen for [day], or null if not answered.
  String? moodForDay(int day) => _moods[day];

  /// Talk-To-Baby entries, newest first.
  List<TalkEntry> get talkEntries {
    final list = [..._talk];
    list.sort((a, b) => b.id.compareTo(a.id));
    return list;
  }

  bool isKept(String text) => _kept.contains(text.trim());

  /// Movement response for [day]: 'yes', 'not_yet', or null.
  String? movementForDay(int day) => _movement[day];

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
    _loaded = true;
    notifyListeners();

    // Then sync with the cloud (no-op if logged out).
    await _syncFromCloud();
  }

  // === Cloud sync (Supabase) — two day-maps, a list, a string-list, and the
  //     father's mission-done day set. ==========================================
  Future<void> _syncFromCloud() async {
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      // daily_moods — one mood per day, keyed by (user_id, day)
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

      // baby_talk — list, by id
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

      // kept_affirmations — plain strings, keyed by the text itself
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

      // daily_movement_responses — one response per day, keyed by (user_id, day)
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

      // father_missions — done days, keyed by (user_id, day)
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
    } catch (_) {/* offline — keep local */}
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
    notifyListeners();
    await _persist(_moodKey,
        jsonEncode(_moods.map((k, v) => MapEntry(k.toString(), v))));
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.upsert('daily_moods', {'day': day, 'mood_id': moodId},
            onConflict: 'user_id,day');
      } catch (_) {}
    }
  }

  Future<void> clearMood(int day) async {
    if (_moods.remove(day) == null) return;
    notifyListeners();
    await _persist(_moodKey,
        jsonEncode(_moods.map((k, v) => MapEntry(k.toString(), v))));
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.deleteBy('daily_moods', 'day', day);
      } catch (_) {}
    }
  }

  /// Saves (or replaces) the Talk-To-Baby entry for [day] into Dear Baby.
  Future<TalkEntry> saveTalk({
    required int day,
    required int week,
    required String prompt,
    required String text,
    required bool spoken,
  }) async {
    _talk.removeWhere((e) => e.day == day);
    final entry = TalkEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      day: day,
      week: week,
      prompt: prompt,
      text: text,
      dateIso: _todayIso(),
      spoken: spoken,
    );
    _talk.add(entry);
    notifyListeners();
    await _persist(
        _talkKey, jsonEncode(_talk.map((e) => e.toJson()).toList()));
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.deleteBy('baby_talk', 'day', day); // replace this day's entry
        await SupabaseRepo.insert('baby_talk', _talkToRow(entry));
      } catch (_) {}
    }
    return entry;
  }

  TalkEntry? talkForDay(int day) {
    for (final e in _talk) {
      if (e.day == day) return e;
    }
    return null;
  }

  /// Appends a free-standing note to the Dear Baby vault (does NOT dedup by
  /// day, unlike [saveTalk]). Used by tools — e.g. a Baby Movement memory.
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
    notifyListeners();
    await _persist(
        _talkKey, jsonEncode(_talk.map((e) => e.toJson()).toList()));
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.insert('baby_talk', _talkToRow(entry));
      } catch (_) {}
    }
    return entry;
  }

  Future<void> toggleKept(String text) async {
    final t = text.trim();
    final wasPresent = _kept.remove(t);
    if (!wasPresent) _kept.add(t);
    notifyListeners();
    await _persist(_keptKey, jsonEncode(_kept));
    if (SupabaseRepo.isLoggedIn) {
      try {
        if (wasPresent) {
          await SupabaseRepo.deleteBy('kept_affirmations', 'text', t);
        } else {
          await SupabaseRepo.upsert('kept_affirmations', {'text': t},
              onConflict: 'user_id,text');
        }
      } catch (_) {}
    }
  }

  Future<void> setMovement(int day, String response) async {
    _movement[day] = response;
    notifyListeners();
    await _persist(_movementKey,
        jsonEncode(_movement.map((k, v) => MapEntry(k.toString(), v))));
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.upsert('daily_movement_responses',
            {'day': day, 'response': response},
            onConflict: 'user_id,day');
      } catch (_) {}
    }
  }

  /// Toggles the Father Mode mission-done flag for [day].
  Future<void> toggleMissionDone(int day) async {
    final nowDone = !_missionsDone.remove(day);
    if (nowDone) _missionsDone.add(day);
    notifyListeners();
    await _persist(_missionKey, jsonEncode(_missionsDone.toList()));
    if (SupabaseRepo.isLoggedIn) {
      try {
        if (nowDone) {
          await SupabaseRepo.insert('father_missions', {'day': day});
        } else {
          await SupabaseRepo.deleteBy('father_missions', 'day', day);
        }
      } catch (_) {}
    }
  }

  Future<void> _persist(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {/* best-effort */}
  }
}
