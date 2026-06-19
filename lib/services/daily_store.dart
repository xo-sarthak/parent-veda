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
  }

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
  }

  Future<void> clearMood(int day) async {
    if (_moods.remove(day) == null) return;
    notifyListeners();
    await _persist(_moodKey,
        jsonEncode(_moods.map((k, v) => MapEntry(k.toString(), v))));
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
    return entry;
  }

  Future<void> toggleKept(String text) async {
    final t = text.trim();
    if (!_kept.remove(t)) _kept.add(t);
    notifyListeners();
    await _persist(_keptKey, jsonEncode(_kept));
  }

  Future<void> setMovement(int day, String response) async {
    _movement[day] = response;
    notifyListeners();
    await _persist(_movementKey,
        jsonEncode(_movement.map((k, v) => MapEntry(k.toString(), v))));
  }

  /// Toggles the Father Mode mission-done flag for [day].
  Future<void> toggleMissionDone(int day) async {
    if (!_missionsDone.remove(day)) _missionsDone.add(day);
    notifyListeners();
    await _persist(_missionKey, jsonEncode(_missionsDone.toList()));
  }

  Future<void> _persist(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {/* best-effort */}
  }
}
