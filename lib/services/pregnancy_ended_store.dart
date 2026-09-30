// =============================================================================
//  PregnancyEndedStore — "If your pregnancy has ended" (2026-09-29)
// -----------------------------------------------------------------------------
//  The pregnancy gap analysis's second most urgent finding: "If her pregnancy
//  ends, the app has no way to be told. It keeps showing her baby growing week
//  by week." What to Expect has "Report a Loss" in its top menu; Oura keeps a
//  quiet "My pregnancy ended" row in its pregnancy details. This is ours.
//
//  ONE BOOLEAN, LOCAL-FIRST, AND NOTHING IS DELETED.
//
//  When she confirms, the Today tab (hers, and his on the partner side) shows
//  the After a loss home instead of the baby home: no week, no size, no daily
//  tip. Her journal, bump photos, reports and saved items are untouched, and
//  the same row in You undoes it, because a mistaken tap on this of all
//  switches must cost nothing.
//
//  The trade-off, named: a flag rather than a stage. Making "after a loss" a
//  fourth life stage would give it its own tabs and state, and would also be
//  a second way to leave pregnancy that every stage-aware screen would need to
//  learn. A flag inside pregnancy costs two call sites (the two Today pages)
//  and cannot strand anyone in a stage nothing else knows about.
//
//  Cloud sync is owed (docs/STILL-OPEN.md): today it lives on this phone,
//  which is the safe failure (a new phone shows the pregnancy again, and the
//  row is one tap away).
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PregnancyEndedStore extends ChangeNotifier {
  PregnancyEndedStore._();
  static final PregnancyEndedStore instance = PregnancyEndedStore._();

  static const String kEndedKey = 'pregnancy_ended_v1';
  static const String kEndedAtKey = 'pregnancy_ended_at_v1';

  bool _loaded = false;
  bool _ended = false;
  DateTime? _endedAt;

  /// True once she has told ParentVeda her pregnancy has ended.
  bool get ended => _ended;

  /// True once [load] has run, so a reader can tell "not ended" from "not
  /// known yet" (the pregnancy messages wait for it, 2026-09-30).
  bool get isLoaded => _loaded;

  /// When she said so, for "take things slowly" copy; never shown as a count.
  DateTime? get endedAt => _endedAt;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _ended = prefs.getBool(kEndedKey) ?? false;
      final at = prefs.getString(kEndedAtKey);
      _endedAt = at == null ? null : DateTime.tryParse(at);
      notifyListeners();
    } catch (_) {
      // Storage failing must never show a loss she did not report.
    }
  }

  Future<void> markEnded() => _set(true);

  /// "Go back to my pregnancy view": the undo, from the same You row.
  Future<void> undo() => _set(false);

  Future<void> _set(bool v) async {
    _ended = v;
    _endedAt = v ? DateTime.now() : null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kEndedKey, v);
      if (v) {
        await prefs.setString(kEndedAtKey, _endedAt!.toIso8601String());
      } else {
        await prefs.remove(kEndedAtKey);
      }
    } catch (_) {}
  }

  /// Tests only.
  @visibleForTesting
  void resetForTest() {
    _loaded = false;
    _ended = false;
    _endedAt = null;
  }
}
