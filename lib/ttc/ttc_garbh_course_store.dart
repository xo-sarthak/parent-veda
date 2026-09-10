// =============================================================================
//  TtcGarbhCourseStore — which sessions were opened, and what session 8 built
// -----------------------------------------------------------------------------
//  ⚠️ THE BRIEF CALLS ONE THING "the single most important build detail in this
//  course": *"Session 8 should write the user's choices straight into the Today
//  tab, so the course ends by producing something rather than by finishing a
//  video."* This store is that write. Everything else here exists to support it.
//
//  ⚠️ PROGRESS IS "OPENED", NOT "COMPLETED", AND THAT IS THE BRIEF'S WORD:
//  *"Show progress only as which sessions have been opened."* The difference is
//  not pedantry. A completion flag needs a definition of finished, and the only
//  honest one for a session whose last step is "notice how that felt" is that
//  the reader decides — at which point you are asking her to certify herself,
//  which is a small test at the end of a course whose whole argument is that
//  there is nothing to pass.
//
//  ⚠️ NO STREAK, NO BADGE, NO CERTIFICATE — the brief bans all three by name,
//  and this store deliberately cannot compute any of them. It records a SET of
//  ids, with no dates, so "seven days in a row" is not a query somebody can
//  write against it later without adding a field first. Same reasoning as
//  `ttc_mind_today.dart`: the absence is designed, not unfinished.
//
//  Local only, like `TtcReadStore`. No table, no columns — TTC is taking no new
//  schema while the interface is being finalised, and the cost of losing this
//  on a reinstall is redoing a free course you can redo any time anyway. When
//  it does sync it is union-shaped: a session opened offline must not vanish
//  because another device pushed first.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The optional couple part session 8 offers. Null is a real answer — the brief
/// says *"or neither"* and means it.
enum TtcCoupleDaily { gratitude, conversation }

class TtcGarbhCourseStore extends ChangeNotifier {
  TtcGarbhCourseStore._() {
    _load();
  }
  static final TtcGarbhCourseStore instance = TtcGarbhCourseStore._();

  static const _openedKey = 'ttc_garbh_opened';
  static const _practiceKey = 'ttc_garbh_practice';

  final Set<String> _opened = {};

  String? _moveId;
  String? _breatheId;
  String? _bedtime;
  String? _wakeTime;
  final List<String> _meals = [];
  TtcCoupleDaily? _couple;
  bool _practiceSet = false;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  // ---- progress -------------------------------------------------------------

  bool isOpened(String sessionId) => _opened.contains(sessionId);
  int get openedCount => _opened.length;

  /// Marks a session opened. Idempotent, and there is no way to un-open one:
  /// the fact is that you looked at it, and that fact does not become untrue.
  void markOpened(String sessionId) {
    if (!_opened.add(sessionId)) return;
    _persist();
    notifyListeners();
  }

  // ---- what session 8 built -------------------------------------------------

  /// True once session 8 has been used to assemble a practice.
  ///
  /// ⚠️ IT IS NOT "did she finish session 8". It is "is there a practice". The
  /// Today tab reads this to decide whether to show her own picks or the daily
  /// rotation, and the honest question there is whether anything was chosen.
  bool get hasPractice => _practiceSet;

  String? get moveId => _moveId;
  String? get breatheId => _breatheId;
  String? get bedtime => _bedtime;
  String? get wakeTime => _wakeTime;
  List<String> get meals => List.unmodifiable(_meals);
  TtcCoupleDaily? get couple => _couple;

  /// Session 5's half: one wake time and one sleep time.
  void setTimes({String? wake, String? bed}) {
    _wakeTime = wake ?? _wakeTime;
    _bedtime = bed ?? _bedtime;
    _persist();
    notifyListeners();
  }

  /// Session 6's half: the regular meal times, in the order they happen.
  void setMeals(List<String> times) {
    _meals
      ..clear()
      ..addAll(times.where((t) => t.trim().isNotEmpty));
    _persist();
    notifyListeners();
  }

  /// Session 8. The write the whole course exists to make.
  ///
  /// ⚠️ BOTH IDS ARE NULLABLE AND THE PRACTICE IS STILL "SET". Somebody who
  /// liked the breathing and none of the movement has made a real choice, and
  /// forcing one of each would be assigning her the thing she just declined —
  /// on a screen whose own first line is "Nothing is assigned".
  void setDailyPractice({
    String? moveId,
    String? breatheId,
    TtcCoupleDaily? couple,
  }) {
    _moveId = moveId;
    _breatheId = breatheId;
    _couple = couple;
    _practiceSet = true;
    _persist();
    notifyListeners();
  }

  /// Hands Today back to the daily rotation.
  ///
  /// ⚠️ THE WAY OUT EXISTS BECAUSE THE WAY IN IS A PREFERENCE, NOT A SETTING.
  /// Session 8 picks the practice you liked in the week you did the course, and
  /// three months later the honest answer may be "surprise me again". Without
  /// this, undoing it means finding the course, opening session 8 and choosing
  /// something else — which is a settings screen with extra steps.
  void clearDailyPractice() {
    _moveId = null;
    _breatheId = null;
    _couple = null;
    _practiceSet = false;
    _persist();
    notifyListeners();
  }

  @visibleForTesting
  void resetForTest() {
    _opened.clear();
    _moveId = null;
    _breatheId = null;
    _bedtime = null;
    _wakeTime = null;
    _meals.clear();
    _couple = null;
    _practiceSet = false;
    _loaded = true;
    notifyListeners();
  }

  // ---- persistence ----------------------------------------------------------
  //
  // ⚠️ ONE ROW OF FIELDS RATHER THAN SIX KEYS. They are written together and
  // read together, and six keys is six chances for a half-saved practice —
  // a move with no breathe, a `practiceSet` with nothing behind it. Pipe
  // separated because the values are ids and HH:mm strings, none of which can
  // contain a pipe.

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      _opened.addAll(p.getStringList(_openedKey) ?? const []);
      final row = p.getStringList(_practiceKey);
      if (row != null && row.length >= 5) {
        _moveId = row[0].isEmpty ? null : row[0];
        _breatheId = row[1].isEmpty ? null : row[1];
        _bedtime = row[2].isEmpty ? null : row[2];
        _wakeTime = row[3].isEmpty ? null : row[3];
        _couple = switch (row[4]) {
          'gratitude' => TtcCoupleDaily.gratitude,
          'conversation' => TtcCoupleDaily.conversation,
          _ => null,
        };
        if (row.length > 5) {
          _meals.addAll(row.sublist(5).where((t) => t.isNotEmpty));
        }
        _practiceSet = _moveId != null || _breatheId != null || _couple != null;
      }
    } catch (_) {/* keep defaults */}
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_openedKey, _opened.toList());
      await p.setStringList(_practiceKey, [
        _moveId ?? '',
        _breatheId ?? '',
        _bedtime ?? '',
        _wakeTime ?? '',
        _couple?.name ?? '',
        ..._meals,
      ]);
    } catch (_) {/* best-effort */}
  }
}
