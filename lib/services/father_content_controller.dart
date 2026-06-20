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
  bool _isLoading = true;
  Object? _error;

  /// Modules engaged this session (resets on relaunch — a gentle ritual, not a
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
    try {
      for (int w = _firstWeek; w <= _lastWeek; w++) {
        final path = '$_weekDir/week_${w.toString().padLeft(2, '0')}.json';
        await _tryLoadInto(path);
      }
      await _tryLoadInto(_legacyPath, fallbackOnly: true);

      _days.sort((a, b) => a.day.compareTo(b.day));
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
      // Missing / unparseable file — skipped (expected during rollout).
    }
  }

  /// The father moment for [day] of pregnancy (1–280), within [week]. Prefers an
  /// exact day match, then the nearest authored day in the same week, then the
  /// nearest authored day overall. Null if nothing loaded.
  FatherDay? dayFor(int day, int week) {
    if (_days.isEmpty) return null;
    for (final d in _days) {
      if (d.day == day) return d;
    }
    FatherDay? sameWeek;
    for (final d in _days) {
      if (d.week == week) {
        if (sameWeek == null ||
            (d.day - day).abs() < (sameWeek.day - day).abs()) {
          sameWeek = d;
        }
      }
    }
    if (sameWeek != null) return sameWeek;
    FatherDay nearest = _days.first;
    for (final d in _days) {
      if ((d.day - day).abs() < (nearest.day - day).abs()) nearest = d;
    }
    return nearest;
  }

  // --- engagement ------------------------------------------------------------

  bool isEngaged(FatherModule m) => _engaged.contains(m);

  void markEngaged(FatherModule m) {
    if (_engaged.add(m)) notifyListeners();
  }
}
