// =============================================================================
//  PvLearnProgressStore — which lessons she has finished, per course
// -----------------------------------------------------------------------------
//  The one number the Learn home's "Continue" strip needs: lessons left. The
//  recorded courses had no notion of progress at all (a lesson row was a
//  lesson row), so "continue where you left off" — Skillshare's first card,
//  Udemy's whole My learning tab — had nothing to read.
//
//  Local-first, `shared_preferences`, one key. Not cloud-synced yet: a
//  finished lesson is a convenience, not a record, and the family model
//  puts it with bookmarks (hers, not the child's) when it does sync —
//  STILL-OPEN §68.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PvLearnProgressStore extends ChangeNotifier {
  PvLearnProgressStore._();
  static final PvLearnProgressStore instance = PvLearnProgressStore._();

  static const _key = 'pv_learn_progress_v1';

  /// courseId → finished lesson ids.
  final Map<String, Set<String>> _done = {};

  /// courseId → the lesson id she opened last, for "Continue".
  final Map<String, String> _last = {};

  /// The order courses were last touched in, most recent first.
  final List<String> _recent = [];
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw != null) _apply(jsonDecode(raw) as Map);
    } catch (_) {
      /* start empty */
    }
    notifyListeners();
  }

  bool isDone(String lessonId) => _done.values.any((s) => s.contains(lessonId));
  int doneCount(String courseId) => _done[courseId]?.length ?? 0;
  String? lastLesson(String courseId) => _last[courseId];
  bool touched(String courseId) => _recent.contains(courseId);

  /// Courses she has opened, most recent first.
  List<String> get recentCourses => List.unmodifiable(_recent);

  void opened(String courseId, String lessonId) {
    _last[courseId] = lessonId;
    _recent.remove(courseId);
    _recent.insert(0, courseId);
    _save();
  }

  void markDone(String courseId, String lessonId) {
    (_done[courseId] ??= {}).add(lessonId);
    _recent.remove(courseId);
    _recent.insert(0, courseId);
    _save();
  }

  void markUndone(String courseId, String lessonId) {
    _done[courseId]?.remove(lessonId);
    _save();
  }

  void _apply(Map data) {
    _done.clear();
    final d = data['done'];
    if (d is Map) {
      d.forEach((k, v) => _done['$k'] = {for (final x in (v as List)) '$x'});
    }
    _last.clear();
    final l = data['last'];
    if (l is Map) l.forEach((k, v) => _last['$k'] = '$v');
    _recent
      ..clear()
      ..addAll([for (final x in (data['recent'] as List? ?? const [])) '$x']);
  }

  Future<void> _save() async {
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode({
          'done': {for (final e in _done.entries) e.key: e.value.toList()},
          'last': _last,
          'recent': _recent,
        }),
      );
    } catch (_) {
      /* best-effort */
    }
  }

  @visibleForTesting
  void resetForTest() {
    _done.clear();
    _last.clear();
    _recent.clear();
    _loaded = false;
  }
}
