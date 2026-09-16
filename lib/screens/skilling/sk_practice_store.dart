// =============================================================================
//  SkPracticeStore — the no-score practice keepsake
// -----------------------------------------------------------------------------
//  ⚠️ THIS STORE CANNOT RETURN A SCORE, AND THE SHAPE OF ITS API IS THE
//  GUARD.
//
//  The brief: "Records only tried, practised again, made. Renders words via
//  devWordLabel, never a number, bar, level, percentage or comparison. Hard
//  guard so no consumer can request a score." The parenting Development area
//  learned this the hard way — `devWordLabel` exists because a progress bar
//  was drawn, seen, and refused — and skilling is where the pressure is
//  highest, because the workbook itself asked for streaks and reports.
//
//  So there is NO public member on this class that returns an `int`, a
//  `double`, a fraction or a comparison. Not "a count that we promise not to
//  draw": no count. What a screen can ask is
//
//    · `wordFor(door, item)`   → "Tried", "Practised again", "Made", or ""
//    · `entriesFor(door)`      → the things she did, each with its word and
//                                the day, for the keepsake list
//    · `hasPractised(door)`    → a bool for the compass, which lights a point
//                                when a skill has been practised, never by
//                                how much
//
//  `test/sk_doors_sanity_test.dart` scans this file for a public getter or
//  method returning `int` or `double` and fails if one appears. If a future
//  screen genuinely needs one — "you practised on three days" — the test
//  fails first, and that is the conversation happening in the right place.
//
//  ⚠️ THE THREE KINDS ARE AN ORDER, NOT A LADDER. A thing can be tried, then
//  practised again, then made; the word shown is the furthest she went. That
//  is not a level — nothing is unlocked by it, nothing compares one child's
//  furthest word to another's, and "Tried" is a whole achievement on its own.
//
//  Local-first, `shared_preferences`, no cloud copy — see `SkChildStore` for
//  why nothing about a child leaves the phone.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What she did. The only three verbs the keepsake knows.
enum SkPractice { tried, practisedAgain, made }

/// The word for a kind — the skilling `devWordLabel`.
String skPracticeWord(SkPractice k) => switch (k) {
      SkPractice.tried => 'Tried',
      SkPractice.practisedAgain => 'Practised again',
      SkPractice.made => 'Made',
    };

/// One thing she did, once. The list is append-only; the keepsake reads the
/// furthest word per item and the days it happened on.
class SkPracticeEntry {
  const SkPracticeEntry({
    required this.doorId,
    required this.itemId,
    required this.title,
    required this.kind,
    required this.at,
  });

  final String doorId;
  final String itemId;

  /// Kept with the entry so the keepsake can name it after the content
  /// moves or a placeholder is replaced — the keepsake is hers, not the
  /// content file's.
  final String title;
  final SkPractice kind;
  final DateTime at;

  Map<String, dynamic> toJson() => {
        'door': doorId,
        'item': itemId,
        'title': title,
        'kind': kind.name,
        'at': at.toIso8601String(),
      };

  static SkPracticeEntry? fromJson(Map<String, dynamic> j) {
    final kind = SkPractice.values
        .cast<SkPractice?>()
        .firstWhere((k) => k!.name == j['kind'], orElse: () => null);
    final at = DateTime.tryParse((j['at'] ?? '') as String);
    if (kind == null || at == null) return null;
    return SkPracticeEntry(
      doorId: (j['door'] ?? '') as String,
      itemId: (j['item'] ?? '') as String,
      title: (j['title'] ?? '') as String,
      kind: kind,
      at: at,
    );
  }
}

/// What the keepsake list shows per item: the title, the furthest word, and
/// the day it was last done. Words and a date. Nothing to add up.
class SkKeepsakeLine {
  const SkKeepsakeLine({
    required this.itemId,
    required this.title,
    required this.word,
    required this.lastAt,
  });
  final String itemId;
  final String title;
  final String word;
  final DateTime lastAt;
}

class SkPracticeStore extends ChangeNotifier {
  SkPracticeStore._();
  static final SkPracticeStore instance = SkPracticeStore._();

  static const _key = 'sk_practice';

  final List<SkPracticeEntry> _entries = [];
  bool _loaded = false;

  /// The furthest word for one item, or '' when she has not touched it.
  String wordFor(String doorId, String itemId) {
    SkPractice? furthest;
    for (final e in _entries) {
      if (e.doorId != doorId || e.itemId != itemId) continue;
      if (furthest == null || e.kind.index > furthest.index) furthest = e.kind;
    }
    return furthest == null ? '' : skPracticeWord(furthest);
  }

  /// The keepsake list for a door, most recent first. One line per item.
  List<SkKeepsakeLine> entriesFor(String doorId) {
    final byItem = <String, SkKeepsakeLine>{};
    for (final e in _entries.where((e) => e.doorId == doorId)) {
      final have = byItem[e.itemId];
      byItem[e.itemId] = SkKeepsakeLine(
        itemId: e.itemId,
        title: e.title,
        word: wordFor(doorId, e.itemId),
        lastAt: have == null || e.at.isAfter(have.lastAt) ? e.at : have.lastAt,
      );
    }
    final lines = byItem.values.toList()
      ..sort((a, b) => b.lastAt.compareTo(a.lastAt));
    return lines;
  }

  /// For the compass: a point lights when a skill has been practised at all.
  bool hasPractised(String doorId) => _entries.any((e) => e.doorId == doorId);

  /// The one write. Append-only.
  void record({
    required String doorId,
    required String itemId,
    required String title,
    required SkPractice kind,
  }) {
    _entries.add(SkPracticeEntry(
      doorId: doorId,
      itemId: itemId,
      title: title,
      kind: kind,
      at: DateTime.now(),
    ));
    _save();
    notifyListeners();
  }

  /// Withdrawn with consent — see `SkChildStore.forget`.
  void forgetAll() {
    _entries.clear();
    _save();
    notifyListeners();
  }

  @visibleForTesting
  void debugReset() {
    _entries.clear();
    _loaded = true;
  }

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      // Merge, never append — the same rule the voice store learned on a
      // phone. An entry's identity is (door, item, kind, moment).
      for (final j in (jsonDecode(raw) as List)) {
        final e = SkPracticeEntry.fromJson(Map<String, dynamic>.from(j));
        if (e == null) continue;
        final dup = _entries.any((x) =>
            x.doorId == e.doorId &&
            x.itemId == e.itemId &&
            x.kind == e.kind &&
            x.at == e.at);
        if (!dup) _entries.add(e);
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode([for (final e in _entries) e.toJson()]));
    } catch (_) {}
  }
}
