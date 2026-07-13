// =============================================================================
//  ParentVeda Feeding Journey - data model, store & interpretive voice
// -----------------------------------------------------------------------------
//  The Feeding Tracker, rebuilt from the Claude Design prompt as a "Feeding
//  Journey": it doesn't just record timestamps, it reads patterns and speaks
//  reassuringly. One in-memory ChangeNotifier singleton (FeedingStore) holds the
//  feeds and derives the hero snapshot, the estimated next feed, plain-language
//  patterns, and growth-aware insights (using the child's age from
//  ChildProfileStore). Prototype-shaped: seeded, no persistence/backend - a real
//  repository slots behind the same getters later. Nothing here touches the
//  pregnancy app.
// =============================================================================

import 'package:flutter/foundation.dart';

import 'pp_child_profile.dart';

/// How the baby was fed. Bottle carries a [BottleMilk] sub-type so expressed /
/// formula are captured without multiplying the top-level kinds.
enum FeedKind { breast, bottle, solid }

enum FeedSideX { left, right, both }

enum BottleMilk { formula, expressed, other }

/// How a solids offer went - celebrated either way, never a pass/fail.
enum SolidTake { ate, tasted, refused }

class FeedLog {
  FeedLog({
    required this.id,
    required this.time,
    required this.kind,
    this.side,
    this.durationMin,
    this.milk,
    this.amountMl,
    this.food,
    this.take,
    this.note,
  });

  final String id;
  final DateTime time;
  final FeedKind kind;

  // breast
  final FeedSideX? side;
  final int? durationMin;

  // bottle
  final BottleMilk? milk;
  final int? amountMl;

  // solids
  final String? food;
  final SolidTake? take;

  final String? note;
}

class FeedingStore extends ChangeNotifier {
  FeedingStore._() {
    _seed();
  }
  static final FeedingStore instance = FeedingStore._();

  final List<FeedLog> _logs = [];
  int _seq = 0;
  String _id() => 'feed_${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  // ---- reads --------------------------------------------------------------
  /// Every feed, newest first.
  List<FeedLog> get all {
    final list = [..._logs]..sort((a, b) => b.time.compareTo(a.time));
    return List.unmodifiable(list);
  }

  List<FeedLog> get todays => List.unmodifiable(all.where((f) => _isToday(f.time)));

  int get countToday => todays.length;

  FeedLog? get last => all.isEmpty ? null : all.first;

  /// The dominant method today, as a short label for the hero.
  String get methodToday {
    if (todays.isEmpty) return 'Not yet today';
    final counts = <FeedKind, int>{};
    for (final f in todays) {
      counts[f.kind] = (counts[f.kind] ?? 0) + 1;
    }
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final mixed = counts.length > 1;
    final base = switch (top) {
      FeedKind.breast => 'Breast',
      FeedKind.bottle => 'Bottle',
      FeedKind.solid => 'Solids',
    };
    return mixed ? '$base + more' : base;
  }

  /// Average gap between today's feeds, in minutes, or null if too few.
  int? get avgGapMinutes {
    final t = todays;
    if (t.length < 2) return null;
    // t is newest-first; walk consecutive pairs.
    var total = 0;
    var n = 0;
    for (var i = 0; i < t.length - 1; i++) {
      total += t[i].time.difference(t[i + 1].time).inMinutes.abs();
      n++;
    }
    return n == 0 ? null : (total / n).round();
  }

  /// A gentle *estimate* of the next feed - never prescriptive.
  DateTime? get nextExpected {
    if (last == null) return null;
    final gap = avgGapMinutes ?? _defaultGapForAge();
    return last!.time.add(Duration(minutes: gap));
  }

  // ---- interpretation (reassuring, never diagnostic) ----------------------
  /// The hero's one-line quick insight.
  String get quickInsight {
    final n = countToday;
    if (n == 0) return 'A fresh day. Log the first feed whenever it happens — no schedule to hit.';
    final gap = avgGapMinutes;
    if (gap != null && gap < 90) {
      return 'Feeds are close together today. Cluster feeding is common around this age and usually passes on its own.';
    }
    if (n >= 8) return "That's a well-fed day so far. Frequent feeds are completely normal for little tummies.";
    return 'Feeding looks steady today. Every baby has their own rhythm — this is $name\'s.';
  }

  /// A growth-aware observation that reads feeding alongside age & growth.
  String get growthAwareInsight {
    final m = ChildProfileStore.instance.ageInMonths;
    if (m < 1) {
      return 'Newborns feed little and often — 8–12 times a day is typical, day and night. Frequency matters more than the clock right now.';
    }
    if (m < 4) {
      return 'Around $m months, feeds often bunch up before a growth spurt, then settle again. A busier feeding day is usually your baby asking to grow.';
    }
    if (m < 6) {
      return 'Close to the halfway mark, milk is still the main event. Longer gaps and the odd distracted feed are both normal as $name notices the world more.';
    }
    if (m < 9) {
      return 'Solids are joining in now, but milk still leads. Expect messy, playful meals — tasting and refusing are both part of learning to eat.';
    }
    return 'Meals and milk share the day at this stage. Appetite naturally rises and falls — trust the pattern over any single meal.';
  }

  /// Plain-language pattern summaries for the Patterns section.
  List<String> get patterns {
    final out = <String>[];
    final n = countToday;
    if (n >= 2) {
      final gap = avgGapMinutes;
      if (gap != null) out.add('Today\'s feeds are about ${ppGapLabel(gap)} apart on average.');
    }
    out.add('Night feeds tend to stretch out gently over the first year — no need to rush them.');
    if (_logs.any((f) => f.kind == FeedKind.solid)) {
      out.add('Solids have started appearing alongside milk — acceptance usually improves week by week.');
    }
    out.add('What matters most is the overall rhythm, not any single feed.');
    return out;
  }

  String get name => ChildProfileStore.instance.name;

  // ---- writes -------------------------------------------------------------
  void add(FeedLog e) {
    _logs.add(e);
    notifyListeners();
  }

  void log({
    required DateTime time,
    required FeedKind kind,
    FeedSideX? side,
    int? durationMin,
    BottleMilk? milk,
    int? amountMl,
    String? food,
    SolidTake? take,
    String? note,
  }) {
    add(FeedLog(
      id: _id(),
      time: time,
      kind: kind,
      side: side,
      durationMin: durationMin,
      milk: milk,
      amountMl: amountMl,
      food: food,
      take: take,
      note: note,
    ));
  }

  void remove(String id) {
    _logs.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  // ---- helpers ------------------------------------------------------------
  int _defaultGapForAge() {
    final m = ChildProfileStore.instance.ageInMonths;
    if (m < 1) return 150; // ~2.5h
    if (m < 4) return 180; // ~3h
    if (m < 8) return 210;
    return 240;
  }

  static bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  void _seed() {
    final now = DateTime.now();
    _logs.addAll([
      FeedLog(id: _id(), time: now.subtract(const Duration(hours: 2, minutes: 5)), kind: FeedKind.breast, side: FeedSideX.left, durationMin: 17),
      FeedLog(id: _id(), time: now.subtract(const Duration(hours: 4, minutes: 40)), kind: FeedKind.bottle, milk: BottleMilk.expressed, amountMl: 110),
      FeedLog(id: _id(), time: now.subtract(const Duration(hours: 7, minutes: 10)), kind: FeedKind.solid, food: 'Mashed banana', take: SolidTake.tasted, note: 'A few playful spoons'),
      FeedLog(id: _id(), time: now.subtract(const Duration(hours: 9, minutes: 30)), kind: FeedKind.breast, side: FeedSideX.both, durationMin: 22),
    ]);
  }
}

/// "about 2h 40m" style gap label used in copy.
String ppGapLabel(int mins) {
  final h = mins ~/ 60;
  final m = mins % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}
