// =============================================================================
//  FatherContentController
// -----------------------------------------------------------------------------
//  Loads the Father Mode "Daily Moment" content and exposes the moment for a
//  given day of pregnancy. Content is authored one file per week under
//  lib/data/father/week_NN.json (each an array of 7 day-objects); weeks not yet
//  authored are simply skipped, so the rollout can grow week by week.
//
//  A legacy single-file day (lib/data/father/fatherDailyContent.json) is also
//  loaded as a fallback so the week-20 prototype day stays alive until its
//  per-week file exists. Mirrors HomeContentController so both modes behave the
//  same way (preview bar, nearest-day fallback, engagement tracking).
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/father_day.dart';
import '../models/father_day_derive.dart';
import '../models/home_day.dart';
import '../models/father_week.dart';
import '../models/father_week_derive.dart';
import '../models/week_content.dart';

/// The three modules that make up a complete Father daily moment.
enum FatherModule { learn, talk, mission }

class FatherContentController extends ChangeNotifier {
  FatherContentController();

  static const String _weekDir = 'lib/data/father';
  static const int _firstWeek = 4;
  static const int _lastWeek = 40;

  /// Legacy single-day fallback (the week-20 prototype moment).
  static const String _legacyPath = 'lib/data/father/fatherDailyContent.json';

  final List<FatherDay> _days = [];
  final List<FatherWeek> _weeks = []; // Weekly Journey (once-per-week)
  bool _isLoading = true;
  Object? _error;

  /// Modules engaged this session (resets on relaunch - a gentle ritual, not a
  /// persisted checklist).
  final Set<FatherModule> _engaged = {};

  /// PROTOTYPE-ONLY: when set, Father Home shows this day of pregnancy instead
  /// of the real current day, so authored content can be reviewed.
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
    _weeks.clear();
    try {
      for (int w = _firstWeek; w <= _lastWeek; w++) {
        final pad = w.toString().padLeft(2, '0');
        await _tryLoadInto('$_weekDir/week_$pad.json');
        await _tryLoadWeek('$_weekDir/journey_week_$pad.json');
      }
      await _tryLoadInto(_legacyPath, fallbackOnly: true);

      _days.sort((a, b) => a.day.compareTo(b.day));
      _weeks.sort((a, b) => a.week.compareTo(b.week));
      if (_days.isEmpty) {
        throw const FormatException('No Father daily content could be loaded');
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
        final d = FatherDay.fromJson(Map<String, dynamic>.from(entry));
        if (fallbackOnly && _days.any((e) => e.day == d.day)) continue;
        _days.add(d);
      }
    } catch (_) {
      // Missing / unparseable file - skipped (expected during rollout).
    }
  }

  /// Load one Weekly Journey file (a single week object). Missing files are
  /// skipped so the weekly rollout can grow week by week.
  Future<void> _tryLoadWeek(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      _weeks.add(FatherWeek.fromJson(Map<String, dynamic>.from(decoded)));
    } catch (_) {
      // Missing / unparseable file - skipped (expected during rollout).
    }
  }

  /// The father moment for [day] of pregnancy (1–280), within [week]. Prefers an
  /// exact day match, then the nearest authored day in the same week, then the
  /// nearest authored day overall. Null if nothing loaded.
  /// The father moment for [day] of pregnancy (1-280), within [week].
  ///
  /// THE NEAREST-DAY FALLBACK IS GONE. With one authored file it returned day
  /// 143 for every day of the pregnancy, so a father at week 34 read a week-20
  /// card and nothing anywhere said so.
  ///
  /// Now: an authored day wins if one exists, and otherwise the day is DERIVED
  /// from the mother's week, which is written and reviewed for all 259 days.
  /// Pass [motherWeek] from HomeContentController.daysInWeek(week).
  FatherDay? dayFor(int day, int week, {List<HomeDay> motherWeek = const []}) {
    for (final d in _days) {
      if (d.day == day) return d;
    }
    if (motherWeek.isNotEmpty) return fatherDayFromMother(day, week, motherWeek);
    // Nothing authored and no mother content loaded yet.
    return null;
  }

  /// The Weekly Journey for [week] (4–40), filled out from her matching week.
  ///
  /// THE NEAREST-WEEK FALLBACK IS GONE, and that is the point of this method.
  /// It used to return the closest authored week when [week] had no file — with
  /// only week 20 written, that meant every father from week 4 to week 40 read
  /// week 20: the anomaly scan, "your baby can hear you now", all of it, months
  /// early or months late. Nothing errored. Nothing looked wrong.
  ///
  /// Now a week with no file (or a file that failed to parse — the loader
  /// cannot tell those apart) is built from HER week instead, which exists for
  /// all 37. The father gets content that is correct for the week he is
  /// actually in, minus the one section that is genuinely his.
  ///
  /// Pass [mother] from PregnancyController.weekData(week).
  FatherWeek? weekFor(int week, {WeekContent? mother}) {
    for (final w in _weeks) {
      if (w.week == week) return w.filledFrom(mother);
    }
    // No authored file for this week. Derive rather than substitute someone
    // else's week.
    if (mother != null) return fatherWeekFromMother(mother);
    return null;
  }

  // --- engagement ------------------------------------------------------------

  bool isEngaged(FatherModule m) => _engaged.contains(m);

  void markEngaged(FatherModule m) {
    if (_engaged.add(m)) notifyListeners();
  }
}
