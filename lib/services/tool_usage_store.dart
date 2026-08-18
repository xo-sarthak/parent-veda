// =============================================================================
//  ToolUsageStore — which tools she actually opens
// -----------------------------------------------------------------------------
//  ⚠️ BUILT FOR ONE REQUIREMENT, STATED PLAINLY:
//
//    "If the mother has not used any tools yet, show recommended tools. If she
//     has used tools previously, show her most-used/relevant tools, max 4.
//     Every displayed tool must be properly wired. Do not show static cards
//     that don't lead to the actual tool."
//
//  Nothing in the app was recording this. The home screen's tool row was a
//  fixed list of names in the same order for everyone, forever.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT THIS IS ALLOWED TO CHANGE, AND WHAT IT IS NOT
//  ---------------------------------------------------------------------------
//  It reorders. It never hides.
//
//  `test/landing_focus_test.dart` holds the rule this repo has already argued
//  out: **personalisation changes content, ranking and order, never structure.**
//  A mother who has used no tools and a mother who uses four every day must be
//  able to reach the same tools; what differs is which four are in front of her.
//
//  So this store answers "which order", and the full set stays reachable from
//  the Tools tab. If it ever starts deciding which tools EXIST for someone, it
//  has become a different and forbidden thing.
//
//  ⚠️ AND IT IS NOT ANALYTICS. It records a count and a last-opened date per
//  tool id, locally, and nothing else — no session, no timing, no what-she-did
//  inside. `usage_events.dart` states the app's line as "which room, never what
//  was in it"; this is narrower still, and it never leaves the phone.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToolUsageStore extends ChangeNotifier {
  ToolUsageStore._();
  static final ToolUsageStore instance = ToolUsageStore._();

  static const _key = 'tool_usage_v1';

  /// surfaceId -> times opened.
  final Map<String, int> _counts = {};

  /// surfaceId -> last opened, ISO date. Used to break ties toward recency, so
  /// a tool she used twice this week outranks one she used three times in
  /// month four.
  final Map<String, String> _last = {};

  bool _loaded = false;

  bool get hasHistory => _counts.isNotEmpty;

  int countFor(String id) => _counts[id] ?? 0;

  /// Her tools, most-used first, recency breaking ties.
  List<String> get ranked {
    final ids = _counts.keys.toList();
    ids.sort((a, b) {
      final c = (_counts[b] ?? 0).compareTo(_counts[a] ?? 0);
      if (c != 0) return c;
      return (_last[b] ?? '').compareTo(_last[a] ?? '');
    });
    return ids;
  }

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return;
      final j = jsonDecode(raw);
      if (j is! Map) return;
      final c = j['counts'];
      final l = j['last'];
      if (c is Map) {
        c.forEach((k, v) => _counts[k.toString()] = (v as num?)?.toInt() ?? 0);
      }
      if (l is Map) l.forEach((k, v) => _last[k.toString()] = v.toString());
      notifyListeners();
    } catch (_) {
      // A corrupt blob must not take the home screen with it. She gets the
      // recommended set, which is the same thing a new user gets.
    }
  }

  /// Call this the moment a tool is opened, from wherever it is opened.
  ///
  /// ⚠️ RECORDED AT THE ROUTER, NOT AT EACH CARD. If every card that can open a
  /// tool has to remember to call this, the counts will be wrong within a week —
  /// and wrong counts are worse than none, because the row would confidently
  /// show her the tools she uses least.
  Future<void> record(String surfaceId) async {
    if (surfaceId.isEmpty) return;
    _counts[surfaceId] = (_counts[surfaceId] ?? 0) + 1;
    _last[surfaceId] = DateTime.now().toIso8601String();
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode({'counts': _counts, 'last': _last}));
    } catch (_) {
      // Fire-and-forget, like every other store here.
    }
  }

  @visibleForTesting
  void resetForTest() {
    _counts.clear();
    _last.clear();
    _loaded = false;
  }
}

/// The tools worth putting in front of someone who has used none yet, by week.
///
/// ⚠️ THE RECOMMENDATION IS BY PREGNANCY STAGE, not by popularity. A kick
/// counter is the single most useful tool in the app at week 30 and is
/// meaningless at week 12, and a contraction timer offered in the second
/// trimester is just a reminder that labour is coming.
///
/// Ordered best-first; the caller takes the first four that actually route.
List<String> recommendedToolsForWeek(int week) {
  if (week <= 13) {
    return const [
      'due_date', // the first thing anyone wants: when
      'symptoms', // first trimester is symptoms, mostly
      'can_i', // and what she is suddenly unsure about eating
      'tests_scans',
      'appointments',
      'medication',
    ];
  }
  if (week <= 27) {
    return const [
      'tests_scans', // the anomaly scan window: the highest-stakes weeks
      'weight',
      'can_i',
      'appointments',
      'symptoms',
      'kegel',
    ];
  }
  // Third trimester: movement and labour become the whole conversation.
  return const [
    'movement', // kick counting is the third trimester's daily habit
    'contractions',
    'hospital_bag',
    'appointments',
    'symptoms',
    'weight',
  ];
}
