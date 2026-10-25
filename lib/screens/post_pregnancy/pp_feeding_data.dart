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

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/child_scoped_store.dart';
import '../../services/remote/supabase_repo.dart';
import '../../services/remote/sync_registry.dart';

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
  // _seed() is deliberately NOT called - it invents a day of feeds for a
  // fictional child, and this store now syncs, so those would land in a real
  // parent's record. Kept for demos (BACKEND-PARENTING-BRIEF §5).
  FeedingStore._();
  static final FeedingStore instance = FeedingStore._();

  final List<FeedLog> _logs = [];
  int _seq = 0;
  String _id() => 'feed_${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  bool _loaded = false;
  static const _prefsKey = 'pp_feeds';
  // Newer-wins bookkeeping beside the rows (0101, sync log step 5).
  final ChildLogLedger _sync = ChildLogLedger(_table, 'pp_feeds_sync');
  static const _table = 'pp_feed_logs';

  String? get _childId => ChildProfileStore.instance.activeChildId;

  // ---- persistence (local-first, then cloud) -------------------------------
  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _logs.add(_fromRow(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    await _sync.load();
    SyncRegistry.registerPending(_hasPending);
    _loaded = true;
    notifyListeners();
    try {
      await _syncFromCloud();
    } catch (_) {/* stay local */}
  }

  bool _hasPending() => _sync.hasPending;

  /// Uploads whatever the cloud has not confirmed (0101).
  Future<void> _pushWaiting() => _sync.push(
        () => {for (final x in _logs) x.id: _toRow(x)},
        fallbackChildId: _childId,
      );

  /// A sign-out, or another account signing in (2026-10-17): this store
  /// forgets the person in memory; the cloud keeps it.
  void _resetLocal() {
    _logs.clear();
    _sync.clear();
    notifyListeners();
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    SyncRegistry.registerReset(_resetLocal);
    final childId = _childId;
    if (!SupabaseRepo.isLoggedIn || childId == null) return;
    try {
      // The union merge, kept for revert: it could never carry a removal.
      // final merged = await ChildSync.merge<FeedLog>(
      // table: _table,
      // childId: childId,
      // local: _logs,
      // idOf: (f) => f.id,
      // toRow: _toRow,
      // fromRow: _fromRow,
      // orderBy: 'time',
      // );
      final merged = await _sync.pull<FeedLog>(
        childId: childId,
        local: _logs,
        idOf: (f) => f.id,
        fromRow: _fromRow,
        orderBy: 'time',
      );
      _logs
        ..clear()
        ..addAll(merged);
      await _persist();
      notifyListeners();
      await _pushWaiting();
    } catch (_) {/* offline - keep local */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(_logs.map(_toRow).toList()));
    } catch (_) {}
  }

  static Map<String, dynamic> _toRow(FeedLog f) => {
        'id': f.id,
        'time': SupabaseRepo.dbTime(f.time),
        'kind': f.kind.name,
        'side': f.side?.name,
        'duration_min': f.durationMin,
        'milk': f.milk?.name,
        'amount_ml': f.amountMl,
        'food': f.food,
        'take': f.take?.name,
        'note': f.note,
      };

  static T? _enumOf<T extends Enum>(List<T> values, Object? v) {
    if (v == null) return null;
    for (final e in values) {
      if (e.name == v.toString()) return e;
    }
    return null;
  }

  static FeedLog _fromRow(Map<String, dynamic> r) => FeedLog(
        id: (r['id'] ?? '').toString(),
        time: SupabaseRepo.parseDbTime(r['time']),
        kind: _enumOf(FeedKind.values, r['kind']) ?? FeedKind.breast,
        side: _enumOf(FeedSideX.values, r['side']),
        durationMin: (r['duration_min'] as num?)?.toInt(),
        milk: _enumOf(BottleMilk.values, r['milk']),
        amountMl: (r['amount_ml'] as num?)?.toInt(),
        food: r['food']?.toString(),
        take: _enumOf(SolidTake.values, r['take']),
        note: r['note']?.toString(),
      );

  // ---- reads --------------------------------------------------------------
  /// ⚠️ ONE CHILD AT A TIME (tools pass 01, 2026-10-25). `_logs` holds every
  /// child's feeds under one prefs key; the ledger knows whose each row is.
  /// Before this, the reads never asked it, so twins' feeds blended into one
  /// "last feed", one count and one next side. A row the ledger has never
  /// seen (logged before the ledger, or with no child yet) counts as the
  /// active child's, the same fallback `uploadFor` files it under.
  bool _mine(FeedLog f) => _sync.belongsTo(f.id, _childId);

  /// Every feed of the active child, newest first.
  List<FeedLog> get all {
    final list = _logs.where(_mine).toList()..sort((a, b) => b.time.compareTo(a.time));
    return List.unmodifiable(list);
  }

  /// The active child's feeds in the last 24 hours, newest first. Feeds are
  /// counted per 24 hours, the way a paediatrician and Is my baby OK? count
  /// them; since midnight read "1 feed today" at 2 am after a full night
  /// (the user's call F1, 2026-10-25).
  List<FeedLog> get last24h {
    final from = DateTime.now().subtract(const Duration(hours: 24));
    return List.unmodifiable(all.where((f) => f.time.isAfter(from)));
  }

  int get countLast24h => last24h.length;

  /// Formula in a bottle in the last 24 hours. Expressed milk is breast milk:
  /// a bottle of it must never read as formula (it lifted formula pages for
  /// breastfeeding mothers through `methodToday`).
  bool get formulaLast24h =>
      last24h.any((f) => f.kind == FeedKind.bottle && f.milk == BottleMilk.formula);

  /// Breast milk in the last 24 hours, at the breast or expressed.
  bool get breastMilkLast24h => last24h.any(
      (f) => f.kind == FeedKind.breast || (f.kind == FeedKind.bottle && f.milk == BottleMilk.expressed));

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

  /// Average gap between feeds in the last 24 hours, in minutes, or null if
  /// too few. Was today's feeds only, so it reset at midnight.
  int? get avgGapMinutes {
    final t = last24h;
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
    final n = countLast24h;
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

  /// Plain-language pattern summaries for the Patterns section. Only lines
  /// read from her own feeds, and one standing line when there is nothing
  /// yet (tools pass 01: fixed sentences printed whatever the data read as
  /// insight). The old fixed lines are kept below for revert.
  List<String> get patterns {
    final out = <String>[];
    final gap = avgGapMinutes;
    if (gap != null) out.add('Over the last 24 hours, feeds were about ${ppGapLabel(gap)} apart.');
    final stretch = longestGapLast24h;
    if (stretch != null && stretch >= 180) {
      out.add('The longest stretch between feeds was ${ppGapLabel(stretch)}.');
    }
    if (all.any((f) => f.kind == FeedKind.solid)) {
      out.add('Solids have started appearing alongside milk. Acceptance usually improves week by week.');
    }
    if (out.isEmpty) {
      out.add('Log a few feeds and the pattern shows here. What matters is the rhythm, not any single feed.');
    }
    return out;
  }
  // Kept for revert (printed whatever the data):
  // out.add('Night feeds tend to stretch out gently over the first year — no need to rush them.');
  // out.add('What matters most is the overall rhythm, not any single feed.');

  /// The longest gap between two feeds in the last 24 hours, in minutes.
  int? get longestGapLast24h {
    final t = last24h;
    if (t.length < 2) return null;
    var best = 0;
    for (var i = 0; i < t.length - 1; i++) {
      final g = t[i].time.difference(t[i + 1].time).inMinutes.abs();
      if (g > best) best = g;
    }
    return best;
  }

  /// Minutes until a gentle next-feed reminder: her own 24-hour rhythm when
  /// there is one, else the usual gap for the age.
  int get reminderGapMinutes => avgGapMinutes ?? _defaultGapForAge();

  String get name => ChildProfileStore.instance.name;

  // ---- writes -------------------------------------------------------------
  /// [childId] files it under a child other than the one on screen: the
  /// breastfeed timer saves to the child it started for.
  void add(FeedLog e, {String? childId}) {
    _logs.add(e);
    _persist();
    // ChildSync.push(_table, _childId, e.id, _toRow(e)); // kept for revert
    _sync.touch(e.id, childId ?? _childId);
    _pushWaiting();
    notifyListeners();
  }

  void log({
    String? childId,
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
    ), childId: childId);
  }

  @visibleForTesting
  void debugReset() {
    _logs.clear();
    _sync.clear();
    // Loaded, so a screen's init() does not read the saved copy back on top
    // of what the test logged (main boots the store before any log).
    _loaded = true;
  }

  /// Replaces a feed in place, keeping its id, so the edit syncs as the same
  /// row (newer wins) rather than as a removal and a new feed.
  void update(FeedLog e) {
    final i = _logs.indexWhere((f) => f.id == e.id);
    if (i < 0) return add(e);
    _logs[i] = e;
    _persist();
    _sync.touch(e.id, _sync.childOf[e.id] ?? _childId);
    _pushWaiting();
    notifyListeners();
  }

  void remove(String id) {
    for (final x in _logs) {
      if (x.id == id) _sync.remove(id, _toRow(x), _childId);
    }
    _logs.removeWhere((f) => f.id == id);
    _persist();
    // A hard delete fired once, lost offline; kept for revert. A removal is
    // now a soft delete that uploads like any other change.
    // ChildSync.remove(_table, id);
    _pushWaiting();
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

  /// Demo feeds. Deliberately NOT called - see the constructor note.
  // ignore: unused_element
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

/// The one notification id the next-feed reminder uses, so setting a new one
/// replaces the old (tools pass 01, F3).
const int kPpFeedReminderId = 7301;

/// The feed the one-tap repeat logs: the last one again at [now], with the
/// breast side switched (left to right, right to left; both stays both), the
/// way the next-side line already suggests (tools pass 01, F2).
FeedLog ppFeedRepeat(FeedLog last, DateTime now) => FeedLog(
      id: '',
      time: now,
      kind: last.kind,
      side: switch (last.side) {
        FeedSideX.left => FeedSideX.right,
        FeedSideX.right => FeedSideX.left,
        final s => s,
      },
      milk: last.milk,
      amountMl: last.amountMl,
      food: last.food,
      take: last.kind == FeedKind.solid ? last.take : null,
    );

/// The repeat chip's words for what one tap will log: "Breast, right",
/// "Bottle, 110 ml", "Solids, khichdi".
String ppFeedRepeatLabel(FeedLog last) {
  final next = ppFeedRepeat(last, last.time);
  return switch (next.kind) {
    FeedKind.breast => switch (next.side) {
        FeedSideX.left => 'Breast, left',
        FeedSideX.right => 'Breast, right',
        FeedSideX.both => 'Breast, both sides',
        null => 'Breast',
      },
    FeedKind.bottle => next.amountMl != null
        ? 'Bottle, ${next.amountMl} ml'
        : (next.milk == BottleMilk.formula ? 'Bottle, formula' : 'Bottle'),
    FeedKind.solid => 'Solids, ${(next.food ?? 'solid food').toLowerCase()}',
  };
}
