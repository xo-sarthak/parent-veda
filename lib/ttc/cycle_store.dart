// =============================================================================
//  CycleStore - the biological truth behind the TTC stage
// -----------------------------------------------------------------------------
//  Holds ONLY what was actually observed: the days her periods began, and any
//  ovulation signals she chose to record. Everything derived - cycle length,
//  cycle day, the ovulation estimate, the fertility window - is computed by
//  TtcChapterEngine from this data and is never stored, so there is exactly one
//  place the arithmetic lives and no stale copy of it can drift.
//
//  Follows the house store pattern: singleton, local-first, lazily loaded,
//  best-effort persistence, screens listen directly. Cloud sync arrives in
//  Phase 8 - the data shapes here are already id-free lists of dates, which
//  merge idempotently.
//
//  A deliberate omission: there is no "missed period" concept and no notion of
//  a cycle being wrong, late or irregular-as-a-problem. A cycle is a record of
//  what happened. See docs/TTC-SPEC.md.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/supabase_repo.dart';
import 'ttc_chapter.dart';
import 'ttc_sync.dart';

class CycleStore extends ChangeNotifier with TtcSyncedStore {
  CycleStore._() {
    _load();
  }
  static final CycleStore instance = CycleStore._();

  static const _periodsKey = 'ttc_period_starts';
  static const _lhKey = 'ttc_lh_positive';
  static const _bbtKey = 'ttc_temp_shift';

  /// First days of logged periods, oldest first. The only cycle fact we store.
  final List<DateTime> _periodStarts = [];

  /// Cycle day a positive LH strip was recorded, per cycle start (ISO date key).
  final Map<String, int> _lhPositive = {};

  /// Cycle day a sustained temperature rise was seen, per cycle start.
  final Map<String, int> _tempShift = {};

  bool _loaded = false;
  bool get isLoaded => _loaded;

  // ---- reads ----------------------------------------------------------------

  /// Period starts, oldest first. Copied so callers cannot mutate our state.
  List<DateTime> get periodStarts => List.unmodifiable(_periodStarts);

  /// The current cycle's first day, or null before anything is logged.
  DateTime? get lastPeriodStart =>
      _periodStarts.isEmpty ? null : _periodStarts.last;

  /// The plausibility window for a real cycle.
  ///
  /// Public because it was the quiet half of a real problem: entries outside it
  /// were dropped from the average with no signal anywhere, so a list of eleven
  /// dates could produce a single usable cycle while the screen looked full.
  /// The UI now warns at input and marks the ones it did not count, and both
  /// need this number.
  static const int minPlausibleCycleDays = 15;
  static const int maxPlausibleCycleDays = 90;

  /// Lengths of COMPLETED cycles, oldest first. The current cycle is still
  /// running and so is deliberately not included.
  List<int> get cycleLengths {
    final out = <int>[];
    for (var i = 1; i < _periodStarts.length; i++) {
      final len = _periodStarts[i].difference(_periodStarts[i - 1]).inDays;
      // Guard against a mis-tap producing an absurd cycle that would poison
      // the average. Clinically plausible cycles only.
      if (_isPlausible(len)) out.add(len);
    }
    return out;
  }

  static bool _isPlausible(int len) =>
      len >= minPlausibleCycleDays && len <= maxPlausibleCycleDays;

  /// Days between [day] and the most recent start before it, or null when it
  /// would be the first entry. Used to warn BEFORE an entry is accepted.
  int? daysSincePreviousStart(DateTime day) {
    final d = _dayOnly(day);
    DateTime? prev;
    for (final s in _periodStarts) {
      if (s.isBefore(d)) prev = s;
    }
    return prev == null ? null : d.difference(prev).inDays;
  }

  /// The cycle that BEGAN on [start] — how long it ran, and whether it counted
  /// toward the average.
  ///
  /// Returns null for the most recent start, whose cycle has not ended yet.
  ///
  /// **Both halves come from here on purpose.** They used to be computed
  /// separately: the row printed `starts[i+1] - starts[i]` (the cycle beginning
  /// on that date) while the "not counted" verdict came from
  /// `starts[i] - starts[i-1]` (the cycle *before* it). Two different cycles on
  /// one line, so a row could read "54 days · Not counted · too close to the
  /// entry before it" — each half true about a different thing, and nonsense
  /// together. In the other direction a four-day gap was shown as counted,
  /// contradicting the average printed inches above it.
  ///
  /// A cycle **begins** on day one of a period and ends the day before the next,
  /// so it belongs to the earlier start. Returning the length and the verdict
  /// from one call is what makes it impossible for them to disagree again — the
  /// bug was not arithmetic, it was two sources for one fact.
  ({int days, bool counted})? cycleFrom(DateTime start) {
    final i = _periodStarts.indexWhere((s) => _sameDay(s, start));
    if (i < 0 || i + 1 >= _periodStarts.length) return null;
    final days = _periodStarts[i + 1].difference(_periodStarts[i]).inDays;
    return (days: days, counted: _isPlausible(days));
  }

  /// How many complete cycles she has logged with us.
  int get completedCycles => cycleLengths.length;

  int? get lhPositiveDay {
    final s = lastPeriodStart;
    return s == null ? null : _lhPositive[_key(s)];
  }

  int? get temperatureShiftDay {
    final s = lastPeriodStart;
    return s == null ? null : _tempShift[_key(s)];
  }

  // ---- writes ---------------------------------------------------------------

  /// Records the first day of a period. Idempotent on the same date, and kept
  /// sorted so callers may log an older cycle they forgot without corrupting
  /// the ordering the engine depends on.
  void logPeriodStart(DateTime day) {
    final d = _dayOnly(day);
    if (_periodStarts.any((e) => _sameDay(e, d))) return;
    _periodStarts
      ..add(d)
      ..sort();
    _persist();
    notifyListeners();
  }

  /// Removes a logged period start - a mis-tap must always be undoable.
  void removePeriodStart(DateTime day) {
    final d = _dayOnly(day);
    final before = _periodStarts.length;
    _periodStarts.removeWhere((e) => _sameDay(e, d));
    if (_periodStarts.length == before) return;
    _lhPositive.remove(_key(d));
    _tempShift.remove(_key(d));
    _persist();
    // Deleting has to reach the cloud explicitly: a union merge would otherwise
    // pull the removed period straight back on the next sync.
    _deleteCycleFromCloud(d).catchError((_) {});
    notifyListeners();
  }

  /// Records a positive ovulation strip on the given cycle day of the current
  /// cycle. Passing null clears it.
  void logLhPositive(int? cycleDay) {
    final s = lastPeriodStart;
    if (s == null) return;
    if (cycleDay == null) {
      _lhPositive.remove(_key(s));
    } else {
      _lhPositive[_key(s)] = cycleDay;
    }
    _persist();
    notifyListeners();
  }

  /// Records the cycle day a sustained basal-temperature rise was seen.
  void logTemperatureShift(int? cycleDay) {
    final s = lastPeriodStart;
    if (s == null) return;
    if (cycleDay == null) {
      _tempShift.remove(_key(s));
    } else {
      _tempShift[_key(s)] = cycleDay;
    }
    _persist();
    notifyListeners();
  }

  /// Testing / sign-out reset.
  @visibleForTesting
  void resetForTest() {
    _periodStarts.clear();
    _lhPositive.clear();
    _tempShift.clear();
    _loaded = true;
    notifyListeners();
  }

  // ---- persistence ----------------------------------------------------------

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      _periodStarts
        ..clear()
        ..addAll((p.getStringList(_periodsKey) ?? const [])
            .map(DateTime.tryParse)
            .whereType<DateTime>()
            .map(_dayOnly))
        ..sort();
      _lhPositive
        ..clear()
        ..addAll(_decodeMap(p.getStringList(_lhKey)));
      _tempShift
        ..clear()
        ..addAll(_decodeMap(p.getStringList(_bbtKey)));
    } catch (_) {/* keep defaults - a storage failure is never a crash */}
    _loaded = true;
    notifyListeners();
    // Local first, cloud after. Never the other way round.
    await syncFromCloud();
  }

  // ---- cloud ----------------------------------------------------------------
  //  Her cycle is OWN-ROW and stays that way. `fetch` pins user_id, and 0041
  //  gives the partner no read policy at all - he sees the derived chapter on
  //  ttc_journeys instead, never these dates.

  /// Deterministic ids, derived from the date rather than the clock, so the
  /// same period logged on two devices produces ONE row rather than two.
  static String _cycleId(DateTime d) => 'ttcc_${TtcSyncUtil.date(d)}';
  static String _signalId(DateTime start, String kind) =>
      'ttcs_${TtcSyncUtil.date(start)}_$kind';

  @override
  Future<void> pullFromCloud() async {
    final cycles = await SupabaseRepo.fetch(TtcTables.cycles,
        orderBy: 'started_on', ascending: true);
    // Union, not cloud-wins: a period logged offline must survive reconnecting.
    for (final row in cycles) {
      final d = TtcSyncUtil.parseDate(row['started_on']);
      if (d == null) continue;
      if (!_periodStarts.any((e) => _sameDay(e, d))) _periodStarts.add(d);
    }
    _periodStarts.sort();

    final signals = await SupabaseRepo.fetch(TtcTables.signals,
        orderBy: 'cycle_start', ascending: true);
    for (final row in signals) {
      final start = TtcSyncUtil.parseDate(row['cycle_start']);
      final day = row['cycle_day'];
      if (start == null || day is! int) continue;
      final target = row['kind'] == 'lh' ? _lhPositive : _tempShift;
      target.putIfAbsent(_key(start), () => day);
    }
  }

  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;

    await TtcSyncUtil.upsertAll(
      TtcTables.cycles,
      [
        for (final d in _periodStarts)
          {
            'id': _cycleId(d),
            'user_id': uid,
            'started_on': TtcSyncUtil.date(d),
          }
      ],
      onConflict: 'id',
    );

    final rows = <Map<String, dynamic>>[];
    for (final entry in _lhPositive.entries) {
      final start = DateTime.tryParse(entry.key);
      if (start == null) continue;
      rows.add({
        'id': _signalId(start, 'lh'),
        'user_id': uid,
        'cycle_start': entry.key,
        'kind': 'lh',
        'cycle_day': entry.value,
      });
    }
    for (final entry in _tempShift.entries) {
      final start = DateTime.tryParse(entry.key);
      if (start == null) continue;
      rows.add({
        'id': _signalId(start, 'temperature'),
        'user_id': uid,
        'cycle_start': entry.key,
        'kind': 'temperature',
        'cycle_day': entry.value,
      });
    }
    await TtcSyncUtil.upsertAll(TtcTables.signals, rows, onConflict: 'id');
  }

  @override
  Future<void> persistLocalCache() => _persist();

  /// A removed period must be removed in the cloud too - a union merge would
  /// otherwise bring it straight back on the next pull.
  Future<void> _deleteCycleFromCloud(DateTime day) async {
    if (!SupabaseRepo.isLoggedIn) return;
    await SupabaseRepo.delete(TtcTables.cycles, _cycleId(day));
    for (final kind in const ['lh', 'temperature']) {
      await SupabaseRepo.delete(TtcTables.signals, _signalId(day, kind));
    }
  }

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(
          _periodsKey, _periodStarts.map((d) => d.toIso8601String()).toList());
      await p.setStringList(_lhKey, _encodeMap(_lhPositive));
      await p.setStringList(_bbtKey, _encodeMap(_tempShift));
    } catch (_) {/* best-effort */}
  }

  // "2026-07-27|14" - a flat encoding so the whole store stays in
  // shared_preferences without pulling in a JSON round-trip.
  static List<String> _encodeMap(Map<String, int> m) =>
      m.entries.map((e) => '${e.key}|${e.value}').toList();

  static Map<String, int> _decodeMap(List<String>? raw) {
    final out = <String, int>{};
    for (final s in raw ?? const <String>[]) {
      final i = s.lastIndexOf('|');
      if (i <= 0) continue;
      final v = int.tryParse(s.substring(i + 1));
      if (v != null) out[s.substring(0, i)] = v;
    }
    return out;
  }

  static String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Convenience for screens: build the engine's input from the live stores.
/// Kept here (rather than in the engine) so the engine stays pure Dart.
TtcJourneyState cycleStateFrom({
  required CycleStore cycle,
  DateTime? journeyStart,
  bool pregnancyConfirmed = false,
  TimingOwnership ownership = TimingOwnership.parentveda,
  DateTime? today,
}) =>
    TtcJourneyState(
      journeyStart: journeyStart,
      lastPeriodStart: cycle.lastPeriodStart,
      cycleLengths: cycle.cycleLengths,
      pregnancyConfirmed: pregnancyConfirmed,
      lhPositiveDay: cycle.lhPositiveDay,
      temperatureShiftDay: cycle.temperatureShiftDay,
      ownership: ownership,
      today: today,
    );
