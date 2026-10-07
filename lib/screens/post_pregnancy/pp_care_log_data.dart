// =============================================================================
//  ParentVeda care logs - nappies, pumping, the breastfeed timer, and history
// -----------------------------------------------------------------------------
//  Added 2026-10-02 from the parenting gap analysis ("Tools": What to Expect
//  and theAsianparent both log nappies, pumping and a left/right timer, and
//  both show more than today). Four pieces, one file, because they are one
//  idea to a parent - "what has the baby done lately":
//
//   * NappyStore   - wet / dirty / mixed / dry, with an optional colour and
//                    texture. Child-scoped and co-parented, exactly like
//                    FeedingStore (table pp_nappy_logs, migration 0093).
//   * PumpStore    - expressed milk, left and right in ml. Also child-scoped:
//                    the milk is for the child, and the partner giving the
//                    bottle at 2am is the person who needs to see the stash.
//   * BreastTimer  - the running left/right timer. Its state is LOCAL ONLY
//                    (prefs), because a timer half-way through a feed is not a
//                    record yet. Stopping it writes one ordinary FeedLog.
//   * PpCareHistory - read-only day buckets over feeds, sleeps, nappies and
//                    pumps for the last N days, plus the plain-text summary a
//                    parent can send to the paediatrician.
//
//  Observations, never a diagnosis: the colour notes route to a doctor and
//  stop there.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/child_scoped_store.dart';
import '../../services/remote/supabase_repo.dart';
import '../../services/remote/sync_registry.dart';

import 'pp_child_profile.dart';
import 'pp_feeding_data.dart';
import 'pp_sleep_data.dart';

T? _enumOf<T extends Enum>(List<T> values, Object? v) {
  if (v == null) return null;
  for (final e in values) {
    if (e.name == v.toString()) return e;
  }
  return null;
}

// =============================================================================
//  Nappies
// =============================================================================

enum NappyKind { wet, dirty, mixed, dry }

/// Poo colour. The names are identity (persisted and checked in SQL); the
/// labels are display.
enum NappyColour { yellow, mustard, green, brown, black, red, pale }

enum NappyTexture { runny, seedy, soft, formed, hard, mucus }

class NappyLog {
  NappyLog({
    required this.id,
    required this.time,
    required this.kind,
    this.colour,
    this.texture,
    this.note,
  });

  final String id;
  final DateTime time;
  final NappyKind kind;
  final NappyColour? colour;
  final NappyTexture? texture;
  final String? note;

  bool get isWet => kind == NappyKind.wet || kind == NappyKind.mixed;
  bool get isDirty => kind == NappyKind.dirty || kind == NappyKind.mixed;
}

String nappyKindLabel(NappyKind k) => switch (k) {
      NappyKind.wet => 'Wet',
      NappyKind.dirty => 'Dirty',
      NappyKind.mixed => 'Wet and dirty',
      NappyKind.dry => 'Dry',
    };

String nappyColourLabel(NappyColour c) => switch (c) {
      NappyColour.yellow => 'Yellow',
      NappyColour.mustard => 'Mustard',
      NappyColour.green => 'Green',
      NappyColour.brown => 'Brown',
      NappyColour.black => 'Black',
      NappyColour.red => 'Red or bloody',
      NappyColour.pale => 'White, grey or pale',
    };

String nappyTextureLabel(NappyTexture t) => switch (t) {
      NappyTexture.runny => 'Runny',
      NappyTexture.seedy => 'Seedy',
      NappyTexture.soft => 'Soft',
      NappyTexture.formed => 'Formed',
      NappyTexture.hard => 'Hard pellets',
      NappyTexture.mucus => 'Mucus',
    };

/// What a colour usually means, in one calm line. Null when there is nothing
/// to say. REQUIRED_REVIEW (paediatrician).
String? nappyColourNote(NappyColour c, {required int ageDays}) => switch (c) {
      NappyColour.yellow || NappyColour.mustard =>
        'Mustard or yellow, often seedy, is the classic breastfed poo.',
      NappyColour.green =>
        'Green is usually fine: a fast feed, foremilk, iron drops or a green vegetable. Watch how he is, not the colour.',
      NappyColour.brown =>
        'Brown is normal, especially on formula or once solids start.',
      NappyColour.black => ageDays <= 4
          ? 'Black, sticky meconium is expected in the first few days.'
          : 'Black poo after the first few days, unless he takes iron drops, is worth a call to his paediatrician today.',
      NappyColour.red =>
        'Red streaks or blood in the nappy: call his paediatrician today. A crack, a cow milk reaction or an infection can all do this, and a doctor should look.',
      NappyColour.pale =>
        'White, grey or chalky poo: call his paediatrician today and take a photo of the nappy. Pale poo can be a sign of a liver problem that needs checking quickly.',
    };

class NappyStore extends ChangeNotifier {
  NappyStore._();
  static final NappyStore instance = NappyStore._();

  final List<NappyLog> _logs = [];
  int _seq = 0;
  String _id() => 'nappy_${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  bool _loaded = false;
  static const _prefsKey = 'pp_nappies';
  static const table = 'pp_nappy_logs';

  String? get _childId => ChildProfileStore.instance.activeChildId;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _logs.add(fromRow(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
    try {
      await _syncFromCloud();
    } catch (_) {/* stay local */}
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    final childId = _childId;
    if (!SupabaseRepo.isLoggedIn || childId == null) return;
    try {
      final merged = await ChildSync.merge<NappyLog>(
        table: table,
        childId: childId,
        local: _logs,
        idOf: (n) => n.id,
        toRow: toRow,
        fromRow: fromRow,
        orderBy: 'time',
      );
      _logs
        ..clear()
        ..addAll(merged);
      await _persist();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(_logs.map(toRow).toList()));
    } catch (_) {}
  }

  static Map<String, dynamic> toRow(NappyLog n) => {
        'id': n.id,
        'time': SupabaseRepo.dbTime(n.time),
        'kind': n.kind.name,
        'colour': n.colour?.name,
        'texture': n.texture?.name,
        'note': n.note,
      };

  static NappyLog fromRow(Map<String, dynamic> r) => NappyLog(
        id: (r['id'] ?? '').toString(),
        time: SupabaseRepo.parseDbTime(r['time']),
        kind: _enumOf(NappyKind.values, r['kind']) ?? NappyKind.wet,
        colour: _enumOf(NappyColour.values, r['colour']),
        texture: _enumOf(NappyTexture.values, r['texture']),
        note: r['note']?.toString(),
      );

  List<NappyLog> get all {
    final list = [..._logs]..sort((a, b) => b.time.compareTo(a.time));
    return List.unmodifiable(list);
  }

  List<NappyLog> get todays => List.unmodifiable(all.where((n) => _isToday(n.time)));
  int get wetToday => todays.where((n) => n.isWet).length;
  int get dirtyToday => todays.where((n) => n.isDirty).length;
  NappyLog? get last => all.isEmpty ? null : all.first;

  /// The one line under the counts. Reassuring by default; the wet-nappy
  /// count is the most useful "is he getting enough milk" sign a parent has.
  /// REQUIRED_REVIEW (paediatrician / lactation consultant).
  String insight({DateTime? now}) {
    final days = ChildProfileStore.instance.ageInDays;
    final wet = wetToday;
    final hour = (now ?? DateTime.now()).hour;
    if (days >= 0 && days < 5) {
      return 'In the first days, wet nappies climb with his age: about one on day one, two on day two, and so on, until about six a day by day five or six.';
    }
    if (days < 42) {
      if (wet >= 6) return 'Six or more wet nappies today: a good sign that milk is going in.';
      if (hour >= 18 && wet < 4) {
        return 'Fewer wet nappies than usual today. Offer feeds more often, and if he has fewer than six heavy wet nappies in a day, dark urine or a dry mouth, call his paediatrician.';
      }
      return 'From about day five, six or more heavy wet nappies a day is the sign milk is going in. Dirty nappies vary much more.';
    }
    return 'Wet nappies are the steady sign he is drinking enough. Poo can come several times a day or once in a few days, and both can be normal.';
  }

  void add(NappyLog n) {
    _logs.add(n);
    _persist();
    ChildSync.push(table, _childId, n.id, toRow(n));
    notifyListeners();
  }

  void log({required DateTime time, required NappyKind kind, NappyColour? colour, NappyTexture? texture, String? note}) =>
      add(NappyLog(id: _id(), time: time, kind: kind, colour: colour, texture: texture, note: note));

  void remove(String id) {
    _logs.removeWhere((n) => n.id == id);
    _persist();
    ChildSync.remove(table, id);
    notifyListeners();
  }

  @visibleForTesting
  void debugReset() {
    _logs.clear();
    _loaded = true;
  }
}

// =============================================================================
//  Pumping
// =============================================================================

class PumpLog {
  PumpLog({
    required this.id,
    required this.time,
    this.leftMl,
    this.rightMl,
    this.durationMin,
    this.note,
  });

  final String id;
  final DateTime time;
  final int? leftMl;
  final int? rightMl;
  final int? durationMin;
  final String? note;

  int get totalMl => (leftMl ?? 0) + (rightMl ?? 0);
}

class PumpStore extends ChangeNotifier {
  PumpStore._();
  static final PumpStore instance = PumpStore._();

  final List<PumpLog> _logs = [];
  int _seq = 0;
  String _id() => 'pump_${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  bool _loaded = false;
  static const _prefsKey = 'pp_pumps';
  static const table = 'pp_pump_logs';

  String? get _childId => ChildProfileStore.instance.activeChildId;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _logs.add(fromRow(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
    try {
      await _syncFromCloud();
    } catch (_) {/* stay local */}
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    final childId = _childId;
    if (!SupabaseRepo.isLoggedIn || childId == null) return;
    try {
      final merged = await ChildSync.merge<PumpLog>(
        table: table,
        childId: childId,
        local: _logs,
        idOf: (p) => p.id,
        toRow: toRow,
        fromRow: fromRow,
        orderBy: 'time',
      );
      _logs
        ..clear()
        ..addAll(merged);
      await _persist();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(_logs.map(toRow).toList()));
    } catch (_) {}
  }

  static Map<String, dynamic> toRow(PumpLog p) => {
        'id': p.id,
        'time': SupabaseRepo.dbTime(p.time),
        'left_ml': p.leftMl,
        'right_ml': p.rightMl,
        'duration_min': p.durationMin,
        'note': p.note,
      };

  static PumpLog fromRow(Map<String, dynamic> r) => PumpLog(
        id: (r['id'] ?? '').toString(),
        time: SupabaseRepo.parseDbTime(r['time']),
        leftMl: (r['left_ml'] as num?)?.toInt(),
        rightMl: (r['right_ml'] as num?)?.toInt(),
        durationMin: (r['duration_min'] as num?)?.toInt(),
        note: r['note']?.toString(),
      );

  List<PumpLog> get all {
    final list = [..._logs]..sort((a, b) => b.time.compareTo(a.time));
    return List.unmodifiable(list);
  }

  List<PumpLog> get todays => List.unmodifiable(all.where((p) => _isToday(p.time)));
  int get mlToday => todays.fold(0, (s, p) => s + p.totalMl);
  PumpLog? get last => all.isEmpty ? null : all.first;

  /// Average per session over the last seven days, or null with too few.
  int? get avgSessionMl7d {
    final since = DateTime.now().subtract(const Duration(days: 7));
    final week = all.where((p) => p.time.isAfter(since) && p.totalMl > 0).toList();
    if (week.length < 2) return null;
    return (week.fold(0, (s, p) => s + p.totalMl) / week.length).round();
  }

  void add(PumpLog p) {
    _logs.add(p);
    _persist();
    ChildSync.push(table, _childId, p.id, toRow(p));
    notifyListeners();
  }

  void log({required DateTime time, int? leftMl, int? rightMl, int? durationMin, String? note}) =>
      add(PumpLog(id: _id(), time: time, leftMl: leftMl, rightMl: rightMl, durationMin: durationMin, note: note));

  void remove(String id) {
    _logs.removeWhere((p) => p.id == id);
    _persist();
    ChildSync.remove(table, id);
    notifyListeners();
  }

  @visibleForTesting
  void debugReset() {
    _logs.clear();
    _loaded = true;
  }
}

// =============================================================================
//  The left/right breastfeed timer
// -----------------------------------------------------------------------------
//  Time is stored as STARTED-AT timestamps, never as a ticking counter, so the
//  timer is right after the phone sleeps, the app is killed, or the screen is
//  left. The screen only repaints; the truth is `now - startedAt`.
// =============================================================================

enum TimerSide { left, right }

class BreastTimer extends ChangeNotifier {
  BreastTimer._();
  static final BreastTimer instance = BreastTimer._();

  static const _prefsKey = 'pp_breast_timer';

  TimerSide? _running;
  DateTime? _runningSince;
  DateTime? _feedStarted;
  int _leftSec = 0;
  int _rightSec = 0;
  // The side touched last, started or paused: the one she finished on.
  TimerSide? _endedOn;
  bool _loaded = false;

  TimerSide? get running => _running;
  bool get isActive => _feedStarted != null;
  DateTime? get feedStarted => _feedStarted;

  int secondsFor(TimerSide s, {DateTime? now}) {
    final base = s == TimerSide.left ? _leftSec : _rightSec;
    if (_running == s && _runningSince != null) {
      return base + (now ?? DateTime.now()).difference(_runningSince!).inSeconds;
    }
    return base;
  }

  int totalSeconds({DateTime? now}) => secondsFor(TimerSide.left, now: now) + secondsFor(TimerSide.right, now: now);

  Future<void> init() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final m = Map<String, dynamic>.from(jsonDecode(raw));
      _running = _enumOf(TimerSide.values, m['running']);
      _runningSince = m['since'] == null ? null : DateTime.tryParse(m['since'].toString());
      _feedStarted = m['started'] == null ? null : DateTime.tryParse(m['started'].toString());
      _leftSec = (m['left'] as num?)?.toInt() ?? 0;
      _rightSec = (m['right'] as num?)?.toInt() ?? 0;
      _endedOn = _enumOf(TimerSide.values, m['ended']);
      // A feed left running for more than three hours was forgotten, not fed.
      if (_feedStarted != null && DateTime.now().difference(_feedStarted!).inHours >= 3) _clear();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_feedStarted == null) {
        await prefs.remove(_prefsKey);
        return;
      }
      await prefs.setString(
          _prefsKey,
          jsonEncode({
            'running': _running?.name,
            'since': _runningSince?.toIso8601String(),
            'started': _feedStarted?.toIso8601String(),
            'left': _leftSec,
            'right': _rightSec,
            'ended': _endedOn?.name,
          }));
    } catch (_) {}
  }

  void _bank(DateTime now) {
    if (_running == null || _runningSince == null) return;
    final s = now.difference(_runningSince!).inSeconds;
    if (_running == TimerSide.left) {
      _leftSec += s;
    } else {
      _rightSec += s;
    }
    _running = null;
    _runningSince = null;
  }

  /// Tap a side: start it (switching from the other), or pause it.
  void tap(TimerSide side, {DateTime? now}) {
    final t = now ?? DateTime.now();
    final wasThis = _running == side;
    _bank(t);
    _endedOn = side;
    if (!wasThis) {
      _feedStarted ??= t;
      _running = side;
      _runningSince = t;
    }
    _persist();
    notifyListeners();
  }

  /// Stop and write one FeedLog. Returns false when nothing was timed.
  bool finish({String? note, DateTime? now}) {
    final t = now ?? DateTime.now();
    _bank(t);
    final total = _leftSec + _rightSec;
    if (_feedStarted == null || total < 5) {
      _clear();
      return false;
    }
    final side = _leftSec > 0 && _rightSec > 0
        ? FeedSideX.both
        : (_leftSec > 0 ? FeedSideX.left : FeedSideX.right);
    final parts = <String>[
      if (side == FeedSideX.both) 'Left ${_minLabel(_leftSec)}, right ${_minLabel(_rightSec)}',
      // The side she finished on is the one to offer first next time.
      if (side == FeedSideX.both && _endedOn != null) 'ended on ${_endedOn!.name}',
      if (note != null && note.trim().isNotEmpty) note.trim(),
    ];
    FeedingStore.instance.log(
      time: _feedStarted!,
      kind: FeedKind.breast,
      side: side,
      durationMin: (total / 60).round().clamp(1, 600),
      note: parts.isEmpty ? null : parts.join(' · '),
    );
    _clear();
    return true;
  }

  void discard() => _clear();

  void _clear() {
    _endedOn = null;
    _running = null;
    _runningSince = null;
    _feedStarted = null;
    _leftSec = 0;
    _rightSec = 0;
    _persist();
    notifyListeners();
  }

  static String _minLabel(int sec) => '${(sec / 60).round()} min';

  @visibleForTesting
  void debugReset() {
    _running = null;
    _runningSince = null;
    _feedStarted = null;
    _leftSec = 0;
    _rightSec = 0;
    _endedOn = null;
    _loaded = true;
  }
}

/// Which breast to offer first, read from the feed history. Null when there
/// is no breastfeed with a side on record.
///
/// The rule mothers are taught: start on the side you finished on, because
/// it was drained least. A "both" feed written by the timer records the side
/// it ended on in its note ("ended on left"); a single-side feed means start
/// on the other side.
({FeedSideX lastSide, String suggestion})? ppNextBreastSide() {
  for (final f in FeedingStore.instance.all) {
    if (f.kind != FeedKind.breast || f.side == null) continue;
    switch (f.side!) {
      case FeedSideX.left:
        return (lastSide: FeedSideX.left, suggestion: 'Last feed was on the left. Start on the right.');
      case FeedSideX.right:
        return (lastSide: FeedSideX.right, suggestion: 'Last feed was on the right. Start on the left.');
      case FeedSideX.both:
        final note = (f.note ?? '').toLowerCase();
        if (note.contains('ended on left')) {
          return (lastSide: FeedSideX.both, suggestion: 'Last feed ended on the left. Start on the left this time.');
        }
        if (note.contains('ended on right')) {
          return (lastSide: FeedSideX.both, suggestion: 'Last feed ended on the right. Start on the right this time.');
        }
        return (lastSide: FeedSideX.both, suggestion: 'Last feed used both sides. Start on whichever feels fuller.');
    }
  }
  return null;
}

// =============================================================================
//  History: day buckets and the doctor summary
// =============================================================================

class PpCareDay {
  PpCareDay(this.date);
  final DateTime date;
  int feeds = 0;
  int breastFeeds = 0;
  int bottleFeeds = 0;
  int bottleMl = 0;
  int solids = 0;
  int sleepMin = 0;
  int nightSleepMin = 0;
  int naps = 0;
  int wet = 0;
  int dirty = 0;
  int pumpedMl = 0;

  bool get isEmpty => feeds == 0 && sleepMin == 0 && wet == 0 && dirty == 0 && pumpedMl == 0;
}

class PpCareHistory {
  PpCareHistory._();

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// One bucket per calendar day for the last [days] days, newest first.
  /// Sleep is credited to the day it started on.
  static List<PpCareDay> days(
    int days, {
    DateTime? now,
    List<FeedLog>? feeds,
    List<SleepLog>? sleeps,
    List<NappyLog>? nappies,
    List<PumpLog>? pumps,
  }) {
    final today = _day(now ?? DateTime.now());
    final out = <DateTime, PpCareDay>{
      for (var i = 0; i < days; i++) today.subtract(Duration(days: i)): PpCareDay(today.subtract(Duration(days: i))),
    };
    PpCareDay? at(DateTime t) => out[_day(t)];

    for (final f in feeds ?? FeedingStore.instance.all) {
      final d = at(f.time);
      if (d == null) continue;
      d.feeds++;
      switch (f.kind) {
        case FeedKind.breast:
          d.breastFeeds++;
        case FeedKind.bottle:
          d.bottleFeeds++;
          d.bottleMl += f.amountMl ?? 0;
        case FeedKind.solid:
          d.solids++;
      }
    }
    for (final s in sleeps ?? SleepStore.instance.all) {
      final d = at(s.start);
      if (d == null) continue;
      d.sleepMin += s.minutes;
      if (s.isNight) {
        d.nightSleepMin += s.minutes;
      } else {
        d.naps++;
      }
    }
    for (final n in nappies ?? NappyStore.instance.all) {
      final d = at(n.time);
      if (d == null) continue;
      if (n.isWet) d.wet++;
      if (n.isDirty) d.dirty++;
    }
    for (final p in pumps ?? PumpStore.instance.all) {
      final d = at(p.time);
      if (d == null) continue;
      d.pumpedMl += p.totalMl;
    }
    return out.values.toList();
  }

  static double _avg(Iterable<int> xs) {
    final l = xs.toList();
    return l.isEmpty ? 0 : l.reduce((a, b) => a + b) / l.length;
  }

  static String _hm(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static String _date(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  /// The plain text a parent sends the paediatrician. Facts only, averaged
  /// over the days that have anything logged, so a forgotten day does not
  /// read as a starving one.
  static String doctorSummary(
    List<PpCareDay> buckets, {
    required String childName,
    String? ageLabel,
  }) {
    final logged = buckets.where((d) => !d.isEmpty).toList();
    final b = StringBuffer()
      ..writeln('$childName${ageLabel == null ? '' : ' ($ageLabel)'}: the last ${buckets.length} days')
      ..writeln('Logged in ParentVeda by the family. Days with nothing logged are left out of the averages.')
      ..writeln();
    if (logged.isEmpty) {
      b.writeln('Nothing logged in this period.');
      return b.toString().trim();
    }
    String a(Iterable<int> xs) => _avg(xs).toStringAsFixed(1);
    final withFeeds = logged.where((d) => d.feeds > 0);
    final withSleep = logged.where((d) => d.sleepMin > 0);
    final withNappies = logged.where((d) => d.wet + d.dirty > 0);
    final withPump = logged.where((d) => d.pumpedMl > 0);
    b.writeln('Averages per day (${logged.length} days with logs)');
    if (withFeeds.isNotEmpty) {
      b.writeln('- Feeds: ${a(withFeeds.map((d) => d.feeds))} '
          '(breast ${a(withFeeds.map((d) => d.breastFeeds))}, bottle ${a(withFeeds.map((d) => d.bottleFeeds))}, solids ${a(withFeeds.map((d) => d.solids))})');
      final ml = withFeeds.where((d) => d.bottleMl > 0);
      if (ml.isNotEmpty) b.writeln('- Bottle milk: ${_avg(ml.map((d) => d.bottleMl)).round()} ml');
    }
    if (withSleep.isNotEmpty) {
      b.writeln('- Sleep: ${_hm(_avg(withSleep.map((d) => d.sleepMin)).round())} '
          '(night ${_hm(_avg(withSleep.map((d) => d.nightSleepMin)).round())}, ${a(withSleep.map((d) => d.naps))} naps)');
    }
    if (withNappies.isNotEmpty) {
      b.writeln('- Nappies: ${a(withNappies.map((d) => d.wet))} wet, ${a(withNappies.map((d) => d.dirty))} dirty');
    }
    if (withPump.isNotEmpty) {
      b.writeln('- Expressed milk: ${_avg(withPump.map((d) => d.pumpedMl)).round()} ml');
    }
    b
      ..writeln()
      ..writeln('Day by day');
    for (final d in logged) {
      final parts = <String>[
        if (d.feeds > 0) '${d.feeds} feeds${d.bottleMl > 0 ? ' (${d.bottleMl} ml bottle)' : ''}',
        if (d.sleepMin > 0) 'sleep ${_hm(d.sleepMin)}',
        if (d.wet + d.dirty > 0) '${d.wet} wet, ${d.dirty} dirty',
        if (d.pumpedMl > 0) 'pumped ${d.pumpedMl} ml',
      ];
      b.writeln('${_date(d.date)}: ${parts.join('; ')}');
    }
    return b.toString().trim();
  }
}

bool _isToday(DateTime d) {
  final now = DateTime.now();
  return d.year == now.year && d.month == now.month && d.day == now.day;
}

// =============================================================================
//  Tummy time (2026-10-07)
// -----------------------------------------------------------------------------
//  The gap analysis (P2, Behind · Logging): "Our pages tell her to do tummy
//  time, and give her no way to keep track. Add a tummy time timer on the
//  Development door with a soft daily total and no target." The fork kept its
//  sessions on the phone only; here they are child-scoped and co-parented like
//  every other care log (0094, `pp_tummy_logs`), because whoever does the
//  session on the play mat is often not the parent who checks the total.
//
//  NO TARGET, NO STREAK. A daily total, shown plainly. A goal turns a few
//  minutes of play into a test she can fail.
// =============================================================================

class TummyLog {
  TummyLog({required this.id, required this.time, required this.seconds});
  final String id;

  /// When the session started.
  final DateTime time;
  final int seconds;
}

class TummyStore extends ChangeNotifier {
  TummyStore._();
  static final TummyStore instance = TummyStore._();

  final List<TummyLog> _logs = [];
  int _seq = 0;
  String _id() => 'tummy_${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  bool _loaded = false;
  static const _prefsKey = 'pp_tummy';
  static const table = 'pp_tummy_logs';

  String? get _childId => ChildProfileStore.instance.activeChildId;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _logs.add(fromRow(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
    try {
      await _syncFromCloud();
    } catch (_) {/* stay local */}
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    final childId = _childId;
    if (!SupabaseRepo.isLoggedIn || childId == null) return;
    try {
      final merged = await ChildSync.merge<TummyLog>(
        table: table,
        childId: childId,
        local: _logs,
        idOf: (t) => t.id,
        toRow: toRow,
        fromRow: fromRow,
        orderBy: 'time',
      );
      _logs
        ..clear()
        ..addAll(merged);
      await _persist();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(_logs.map(toRow).toList()));
    } catch (_) {}
  }

  static Map<String, dynamic> toRow(TummyLog t) => {
        'id': t.id,
        'time': SupabaseRepo.dbTime(t.time),
        'seconds': t.seconds,
      };

  static TummyLog fromRow(Map<String, dynamic> r) => TummyLog(
        id: (r['id'] ?? '').toString(),
        time: SupabaseRepo.parseDbTime(r['time']),
        seconds: (r['seconds'] as num?)?.toInt() ?? 0,
      );

  List<TummyLog> get all {
    final list = [..._logs]..sort((a, b) => b.time.compareTo(a.time));
    return List.unmodifiable(list);
  }

  List<TummyLog> get todays => List.unmodifiable(all.where((t) => _isToday(t.time)));
  int get secondsToday => todays.fold(0, (s, t) => s + t.seconds);

  /// Total seconds on each of the last [n] days, oldest first.
  List<int> lastDays(int n, {DateTime? now}) {
    final t = now ?? DateTime.now();
    final today = DateTime(t.year, t.month, t.day);
    return [
      for (var i = n - 1; i >= 0; i--)
        all
            .where((x) {
              final d = DateTime(x.time.year, x.time.month, x.time.day);
              return d == today.subtract(Duration(days: i));
            })
            .fold(0, (s, x) => s + x.seconds),
    ];
  }

  /// Saves one session. Under ten seconds is a mis-tap, not a session.
  bool log({required DateTime start, required int seconds}) {
    if (seconds < 10) return false;
    final l = TummyLog(id: _id(), time: start, seconds: seconds);
    _logs.add(l);
    _persist();
    ChildSync.push(table, _childId, l.id, toRow(l));
    notifyListeners();
    return true;
  }

  void remove(String id) {
    _logs.removeWhere((t) => t.id == id);
    _persist();
    ChildSync.remove(table, id);
    notifyListeners();
  }

  @visibleForTesting
  void debugReset() {
    _logs.clear();
    _loaded = true;
  }
}
