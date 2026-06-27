// =============================================================================
//  GarbhStore — Garbh Sanskar daily-ritual state (v2.0)
// -----------------------------------------------------------------------------
//  Garbh Sanskar is a daily ritual, not a content library. This store tracks the
//  5 daily pillars completed TODAY (resets each day), a gentle day streak, and
//  favorites. The goal is ritual formation — 5/5 pillars a day.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GarbhStore extends ChangeNotifier {
  GarbhStore._();
  static final GarbhStore instance = GarbhStore._();

  // 4 pillars now that Ahara is commented out (was 5). Restore to 5 if Ahara
  // comes back in garbh_screen.dart / home_screen_b.dart.
  static const int dailyGoal = 4;

  static const _favsKey = 'garbh_favs';
  static const _doneKey = 'garbh_done';
  static const _doneDateKey = 'garbh_done_date';
  static const _streakKey = 'garbh_streak';
  static const _streakDateKey = 'garbh_streak_date';

  SharedPreferences? _prefs;
  final Set<String> _favs = {};
  final Set<String> _doneToday = {}; // pillar ids completed today
  String _doneDate = '';
  int _streak = 0;
  String _streakDate = '';

  // --- date helpers (app runtime) ---
  static String _ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String get _today => _ymd(DateTime.now());
  String get _yesterday => _ymd(DateTime.now().subtract(const Duration(days: 1)));

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    _favs
      ..clear()
      ..addAll(p.getStringList(_favsKey) ?? const []);
    _streak = p.getInt(_streakKey) ?? 0;
    _streakDate = p.getString(_streakDateKey) ?? '';
    _doneDate = p.getString(_doneDateKey) ?? '';
    _doneToday
      ..clear()
      ..addAll(p.getStringList(_doneKey) ?? const []);

    // New day → today's completions reset.
    if (_doneDate != _today) {
      _doneToday.clear();
      _doneDate = _today;
      await p.setStringList(_doneKey, const []);
      await p.setString(_doneDateKey, _doneDate);
    }
    // If the streak was not touched yesterday or today, it has lapsed.
    if (_streakDate != _today && _streakDate != _yesterday) {
      _streak = 0;
    }
    notifyListeners();
  }

  // --- favorites ---
  bool isFav(String id) => _favs.contains(id);
  List<String> get favIds => List.unmodifiable(_favs);
  void toggleFav(String id) {
    if (!_favs.remove(id)) _favs.add(id);
    _prefs?.setStringList(_favsKey, _favs.toList());
    notifyListeners();
  }

  // --- daily rituals ---
  bool isDone(String pillarId) => _doneToday.contains(pillarId);
  int get doneCount => _doneToday.length;
  int get streak => _streak;

  void markDone(String pillarId) {
    if (_doneDate != _today) {
      _doneToday.clear();
      _doneDate = _today;
    }
    if (_doneToday.contains(pillarId)) return;
    final wasFirstToday = _doneToday.isEmpty;
    _doneToday.add(pillarId);
    if (wasFirstToday) {
      // First ritual of the day → advance the streak.
      if (_streakDate == _yesterday) {
        _streak += 1;
      } else if (_streakDate != _today) {
        _streak = 1;
      }
      _streakDate = _today;
    }
    _prefs
      ?..setStringList(_doneKey, _doneToday.toList())
      ..setString(_doneDateKey, _doneDate)
      ..setInt(_streakKey, _streak)
      ..setString(_streakDateKey, _streakDate);
    notifyListeners();
  }

  void undoDone(String pillarId) {
    if (_doneToday.remove(pillarId)) {
      _prefs?.setStringList(_doneKey, _doneToday.toList());
      notifyListeners();
    }
  }
}
