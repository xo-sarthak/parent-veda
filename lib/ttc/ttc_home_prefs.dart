// =============================================================================
//  TtcHomePrefs - the two small things the TTC home remembers
// -----------------------------------------------------------------------------
//  Added 2026-09-26 with the gap analysis's home work ("Behind: Home & daily",
//  "Behind: Guided help"):
//
//    * whether she said "Not now" to the "it may be time for a check" card, so
//      a card she dismissed stays dismissed;
//    * which "Trying to conceive 101" steps she has opened, so the home's
//      "New here?" card can step aside once she has started (two steps).
//
//  House pattern: singleton `ChangeNotifier`, private constructor, lazy load,
//  `shared_preferences`, a storage failure is never a crash (the in-memory
//  answer still holds for this session).
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/pv_read_store.dart';

/// "Trying to conceive 101", in order: the free seven-step course from the
/// gap analysis ("Behind: Learning shapes", P1), built from reads we already
/// have. The Learn tab's "Start here" list and the home's "New here?" card
/// both read this, so the course cannot be two different lists.
///
/// ⚠️ IDS, NOT TITLES. Each must resolve in `kTtcReads`; one that is removed
/// later is skipped where the list is drawn rather than shown as a dead row.
const List<String> kTtc101ReadIds = [
  'ttc_read_three_months_before',
  'ttc_read_folic_acid',
  'ttc_read_how_conception_works',
  'ttc_read_timing_myths',
  'ttc_read_stress_fertility',
  'ttc_read_when_to_test',
  'ttc_read_when_to_seek_help',
];

/// How many steps she must have opened before the home's "New here?" card
/// steps aside.
const int kTtc101StartedAfter = 2;

class TtcHomePrefs extends ChangeNotifier {
  TtcHomePrefs._();
  static final TtcHomePrefs instance = TtcHomePrefs._();

  static const String _kCheckDismissed = 'ttc_home_check_dismissed';
  static const String _kOpened101 = 'ttc_home_101_opened';

  bool _loaded = false;
  bool _checkDismissed = false;
  final Set<String> _opened = {};

  bool get isLoaded => _loaded;

  /// She tapped "Not now" on the check card.
  bool get checkDismissed => _checkDismissed;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final p = await SharedPreferences.getInstance();
      _checkDismissed = p.getBool(_kCheckDismissed) ?? false;
      _opened.addAll(p.getStringList(_kOpened101) ?? const <String>[]);
      notifyListeners();
    } catch (_) {/* local-first: the defaults are a fine answer */}
  }

  Future<void> dismissCheck() async {
    if (_checkDismissed) return;
    _checkDismissed = true;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kCheckDismissed, true);
    } catch (_) {/* best effort */}
  }

  /// Remember that a course step was opened. Ids outside the course are
  /// ignored, so any read opener can call this without checking first.
  Future<void> markOpened(String readId) async {
    if (!kTtc101ReadIds.contains(readId) || !_opened.add(readId)) return;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_kOpened101, _opened.toList());
    } catch (_) {/* best effort */}
  }

  /// Whether this course step has been opened: tapped from the home or Learn,
  /// or scrolled at all in the reader (which records progress wherever it
  /// was opened from).
  bool opened(String readId) =>
      _opened.contains(readId) || PvReadStore.instance.progressOf(readId) > 0;

  /// How many course steps she has opened. Drives the home card only; it is
  /// never shown as a number.
  int get opened101 => kTtc101ReadIds.where(opened).length;

  /// Whether the home should still offer the course.
  bool get offer101 => opened101 < kTtc101StartedAfter;

  @visibleForTesting
  void resetForTest() {
    _loaded = true;
    _checkDismissed = false;
    _opened.clear();
  }
}
