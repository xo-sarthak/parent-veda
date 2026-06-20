// =============================================================================
//  HomeContentController
// -----------------------------------------------------------------------------
//  Loads the daily Home Screen content and exposes the "Daily Moment" for the
//  mother's current day. Content is authored one file per week under
//  lib/data/home/week_NN.json (each an array of 7 day-objects). Weeks not yet
//  authored are simply skipped, so the rollout can grow week by week.
//
//  A legacy single-file day (lib/data/homeDailyContent.json) is also loaded as a
//  fallback so the demo week stays alive until its per-week file exists.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/home_day.dart';

/// The baby-focused modules that make up a complete daily moment (Emotional
/// Check-In sits outside this — it is mother-focused reflection).
enum DailyModule { grow, read, talk, garbhSanskar, nurture, movement }

class HomeContentController extends ChangeNotifier {
  HomeContentController();

  /// Per-week content lives here; weeks run 4..40.
  static const String _weekDir = 'lib/data/home';
  static const int _firstWeek = 4;
  static const int _lastWeek = 40;

  /// Legacy single-day fallback (the originally-approved week-20 moment).
  static const String _legacyPath = 'lib/data/homeDailyContent.json';

  final List<HomeDay> _days = [];
  bool _isLoading = true;
  Object? _error;

  /// Modules engaged in the current session (resets on relaunch — the daily
  /// moment is a gentle ritual, not a persisted checklist).
  final Set<DailyModule> _engaged = {};

  /// PROTOTYPE-ONLY: when set, Home shows this day of pregnancy instead of the
  /// mother's real current day, so authored content can be reviewed. Remove the
  /// preview bar (and this) before production.
  int? _previewDay;
  int? get previewDay => _previewDay;
  void setPreviewDay(int? day) {
    _previewDay = day?.clamp(_firstWeek * 7 - 6, _lastWeek * 7);
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  Object? get error => _error;
  bool get hasError => _error != null;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    _days.clear();
    try {
      // Per-week files (skip any week not yet authored).
      for (int w = _firstWeek; w <= _lastWeek; w++) {
        final path = '$_weekDir/week_${w.toString().padLeft(2, '0')}.json';
        await _tryLoadInto(path);
      }
      // Legacy fallback day(s) — only added for days we don't already have.
      await _tryLoadInto(_legacyPath, fallbackOnly: true);

      _days.sort((a, b) => a.day.compareTo(b.day));
      if (_days.isEmpty) {
        throw const FormatException('No Home daily content could be loaded');
      }
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _tryLoadInto(String path, {bool fallbackOnly = false}) async {
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      for (final entry in decoded) {
        if (entry is! Map) continue;
        final d = HomeDay.fromJson(Map<String, dynamic>.from(entry));
        if (fallbackOnly && _days.any((e) => e.day == d.day)) continue;
        _days.add(d);
      }
    } catch (_) {
      // Missing / unparseable file — skipped (expected during rollout).
    }
  }

  /// The day content for the mother's [day] of pregnancy (1–280), within
  /// [week]. Prefers an exact day match, then the nearest authored day in the
  /// same week, then the nearest authored day overall. Null if nothing loaded.
  HomeDay? dayFor(int day, int week) {
    if (_days.isEmpty) return null;
    for (final d in _days) {
      if (d.day == day) return d;
    }
    HomeDay? sameWeek;
    for (final d in _days) {
      if (d.week == week) {
        if (sameWeek == null ||
            (d.day - day).abs() < (sameWeek.day - day).abs()) {
          sameWeek = d;
        }
      }
    }
    if (sameWeek != null) return sameWeek;
    HomeDay nearest = _days.first;
    for (final d in _days) {
      if ((d.day - day).abs() < (nearest.day - day).abs()) nearest = d;
    }
    return nearest;
  }

  /// Convenience for callers that only know the week.
  HomeDay? dayForWeek(int week) => dayFor((week - 1) * 7 + 1, week);

  // --- engagement / completion ----------------------------------------------

  bool isEngaged(DailyModule m) => _engaged.contains(m);

  void markEngaged(DailyModule m) {
    if (_engaged.add(m)) notifyListeners();
  }

  Set<DailyModule> requiredModules(HomeDay day) => {
        DailyModule.grow,
        DailyModule.read,
        DailyModule.talk,
        DailyModule.garbhSanskar,
        DailyModule.nurture,
        if (day.showsMovementCheckIn) DailyModule.movement,
      };

  bool isComplete(HomeDay day) =>
      requiredModules(day).every(_engaged.contains);
}
