// =============================================================================
//  GarbhStore - Garbh Sanskar daily-ritual state (v2.0)
// -----------------------------------------------------------------------------
//  Garbh Sanskar is a daily ritual, not a content library. This store tracks the
//  5 daily pillars completed TODAY (resets each day), a gentle day streak, and
//  favorites. The goal is ritual formation - 5/5 pillars a day.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_merged_store.dart';
// import 'remote/cloud_synced_store.dart'; // kept for revert (step 13)

// In the cloud per item since step 13 (2026-10-22, sync log). It synced as one
// whole blob before, so a favourite saved on one phone and a practice ticked
// on the other erased each other. Items: `fav|<id>` = true, `done|<pillar>` =
// the day it was ticked (yyyy-mm-dd; only today's count on apply), and one
// `streak` item = {n, date}.
class GarbhStore extends ChangeNotifier with CloudMergedStore {
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
    // await syncStateFromCloud(); // kept for revert (step 13)
    await syncMergedFromCloud();
  }

  // --- cloud sync (favourites + streak; today's done-state stays local) ------
  @override
  String get cloudKey => 'garbh';
  // Kept for revert (step 13): the whole-blob mixin's empty state and blob.
  //   /// What a sign-out resets this store to (2026-10-17): the blob of a store nobody has used.
  //   @override
  //   Object get cloudEmptyData => const <String, Object?>{'favs': <String>[], 'streak': 0, 'streakDate': '', 'done': <String>[], 'doneDate': '0000-00-00'};
  //
  //   @override
  //   Object cloudData() => {
  //         'favs': _favs.toList(),
  //         'streak': _streak,
  //         'streakDate': _streakDate,
  //         // Today's ticks (2026-09-23, the persistence audit): a practice ticked
  //         // on one phone shows ticked on the other the same day. Only favourites
  //         // and the streak travelled before.
  //         'done': _doneToday.toList(),
  //         'doneDate': _doneDate,
  //       };

  @override
  String? get legacyBlobKey => cloudKey;

  @override
  Map<String, Object?> cloudItems() => {
        for (final f in _favs) 'fav|$f': true,
        for (final d in _doneToday) 'done|$d': _doneDate,
        if (_streak != 0 || _streakDate.isNotEmpty)
          'streak': {'n': _streak, 'date': _streakDate},
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _favs.clear();
    _doneToday.clear();
    _streak = 0;
    _streakDate = '';
    _doneDate = '';
    final today = _today;
    for (final e in items.entries) {
      final k = e.key;
      if (k.startsWith('fav|')) {
        _favs.add(k.substring(4));
      } else if (k.startsWith('done|')) {
        // A tick from an earlier day is not a tick today.
        if (e.value == today) _doneToday.add(k.substring(5));
      } else if (k == 'streak' && e.value is Map) {
        final m = e.value as Map;
        _streak = (m['n'] as num?)?.toInt() ?? 0;
        _streakDate = (m['date'] ?? '').toString();
      }
    }
    if (_doneToday.isNotEmpty) _doneDate = today;
  }

  /// The old whole blob, read once on a phone that holds nothing yet.
  @override
  void applyLegacyBlob(Object blob) {
    final m = blob as Map;
    _favs
      ..clear()
      ..addAll(((m['favs'] as List?) ?? const []).map((e) => e.toString()));
    _streak = (m['streak'] as num?)?.toInt() ?? _streak;
    _streakDate = (m['streakDate'] ?? _streakDate).toString();
    final dd = m['doneDate']?.toString();
    if (dd != null && dd.isNotEmpty) {
      _doneDate = dd;
      _doneToday
        ..clear()
        ..addAll(((m['done'] as List?) ?? const []).map((e) => e.toString()));
    }
  }

  @override
  Future<void> persistLocalCache() async {
    final p = _prefs;
    if (p == null) return;
    await p.setStringList(_favsKey, _favs.toList());
    await p.setInt(_streakKey, _streak);
    await p.setString(_streakDateKey, _streakDate);
    // Step 13: today's ticks too. With per-item merge a tick taken from the
    // other phone but not written here would read as removed on the next
    // launch, and that removal would travel back.
    await p.setStringList(_doneKey, _doneToday.toList());
    await p.setString(_doneDateKey, _doneDate);
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
