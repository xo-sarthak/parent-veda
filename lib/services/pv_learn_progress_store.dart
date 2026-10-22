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

import 'remote/cloud_merged_store.dart';
// import 'remote/sync_registry.dart'; // kept for revert (step 13: the mixin registers)

// ⚠️ IN THE CLOUD SINCE STEP 13 (2026-10-22, sync log). It was phone-only, so a
// sign-out or a new phone lost every finished lesson. Items:
// `done|<course>|<lesson>` (true), `last|<course>` (lesson id), and
// `recent|<course>` (when last touched, epoch ms; the recents order is
// rebuilt from it). Courses touched before step 13 get small stand-in times
// in their old order, so any real touch on any phone outranks them.
class PvLearnProgressStore extends ChangeNotifier with CloudMergedStore {
  PvLearnProgressStore._();
  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   PvLearnProgressStore._() {
  //     SyncRegistry.registerReset(_resetForAccount);
  //   }
  static final PvLearnProgressStore instance = PvLearnProgressStore._();

  static const _key = 'pv_learn_progress_v1';

  /// courseId → finished lesson ids.
  final Map<String, Set<String>> _done = {};

  /// courseId → the lesson id she opened last, for "Continue".
  final Map<String, String> _last = {};

  /// The order courses were last touched in, most recent first.
  final List<String> _recent = [];

  /// courseId -> when last touched (epoch ms), the order [_recent] is rebuilt
  /// from when the cloud hands it back (step 13).
  final Map<String, int> _recentAt = {};
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
    await syncMergedFromCloud();
  }

  // ---- the cloud (step 13) --------------------------------------------------

  @override
  String get cloudKey => 'learn_progress';

  @override
  Map<String, Object?> cloudItems() => {
        for (final e in _done.entries)
          for (final l in e.value) 'done|${e.key}|$l': true,
        for (final e in _last.entries) 'last|${e.key}': e.value,
        for (final c in _recent) 'recent|$c': _recentAt[c] ?? 0,
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _done.clear();
    _last.clear();
    _recent.clear();
    _recentAt.clear();
    for (final e in items.entries) {
      final k = e.key;
      if (k.startsWith('done|')) {
        final rest = k.substring(5);
        final bar = rest.indexOf('|');
        if (bar <= 0) continue;
        (_done[rest.substring(0, bar)] ??= {}).add(rest.substring(bar + 1));
      } else if (k.startsWith('last|')) {
        final v = e.value;
        if (v is String) _last[k.substring(5)] = v;
      } else if (k.startsWith('recent|')) {
        final v = e.value;
        _recentAt[k.substring(7)] = v is num ? v.toInt() : 0;
      }
    }
    _recent.addAll(_recentAt.keys.toList()
      ..sort((a, b) => _recentAt[b]!.compareTo(_recentAt[a]!)));
    _loaded = true;
  }

  @override
  Future<void> persistLocalCache() => _write();

  void _touchCourse(String courseId) {
    _recent.remove(courseId);
    _recent.insert(0, courseId);
    _recentAt[courseId] = DateTime.now().millisecondsSinceEpoch;
  }

  bool isDone(String lessonId) => _done.values.any((s) => s.contains(lessonId));
  int doneCount(String courseId) => _done[courseId]?.length ?? 0;
  String? lastLesson(String courseId) => _last[courseId];
  bool touched(String courseId) => _recent.contains(courseId);

  /// Courses she has opened, most recent first.
  List<String> get recentCourses => List.unmodifiable(_recent);

  void opened(String courseId, String lessonId) {
    _last[courseId] = lessonId;
    _touchCourse(courseId);
    _save();
  }

  void markDone(String courseId, String lessonId) {
    (_done[courseId] ??= {}).add(lessonId);
    _touchCourse(courseId);
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
    _recentAt.clear();
    final at = data['recentAt'];
    if (at is Map) {
      at.forEach((k, v) {
        if (v is num) _recentAt['$k'] = v.toInt();
      });
    }
    // Before step 13 there were no times: stand-ins in the old order.
    for (var i = 0; i < _recent.length; i++) {
      _recentAt.putIfAbsent(_recent[i], () => _recent.length - i);
    }
  }

  Future<void> _save() async {
    notifyListeners();
    await _write();
  }

  Future<void> _write() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode({
          'done': {for (final e in _done.entries) e.key: e.value.toList()},
          'last': _last,
          'recent': _recent,
          'recentAt': _recentAt,
        }),
      );
    } catch (_) {
      /* best-effort */
    }
  }

  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  //   // are wiped, the singleton was not.
  //   void _resetForAccount() {
  //     resetForTest();
  //     notifyListeners();
  //   }

  @visibleForTesting
  void resetForTest() {
    _done.clear();
    _last.clear();
    _recent.clear();
    _recentAt.clear();
    _loaded = false;
  }
}
