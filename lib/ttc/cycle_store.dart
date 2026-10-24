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

import '../services/life_stage_store.dart';
import '../services/pregnancy_ended_store.dart';
import '../services/remote/supabase_repo.dart';
import '../services/remote/sync_batch.dart';
import 'ttc_chapter.dart';
import 'ttc_row_merge.dart';
import 'ttc_sync.dart';

/// Recorded against a period that had not finished when she logged it.
///
/// WARNING: A SENTINEL RATHER THAN A NULL, BECAUSE THE TWO MEAN DIFFERENT
/// THINGS AND BOTH ARE COMMON. Null is "she has not said"; this is "she said,
/// and the answer was that it is still going". A screen that collapsed them
/// would ask a question she has already answered.
///
/// Negative so no arithmetic mistakes it for a length: any code that averages
/// or sums bleed days has to exclude it deliberately, and a sum that quietly
/// went down is easier to notice than one that quietly went up.
const int kBleedStillOn = -1;

class CycleStore extends ChangeNotifier with TtcSyncedStore {
  CycleStore._() {
    _load();
  }
  static final CycleStore instance = CycleStore._();

  static const _periodsKey = 'ttc_period_starts';
  static const _lhKey = 'ttc_lh_positive';
  static const _bbtKey = 'ttc_temp_shift';
  static const _bleedKey = 'ttc_bleed_days';
  static const _clearedSignalsKey = 'ttc_signals_cleared';
  static const _stampsKey = 'ttc_cycle_stamps';
  static const _tombsKey = 'ttc_cycle_tombs';
  static const _dirtyKey = 'ttc_cycle_dirty';

  /// First days of logged periods, oldest first. The only cycle fact we store.
  final List<DateTime> _periodStarts = [];

  /// Cycle day a positive LH strip was recorded, per cycle start (ISO date key).
  final Map<String, int> _lhPositive = {};

  /// Cycle day a sustained temperature rise was seen, per cycle start.
  final Map<String, int> _tempShift = {};

  /// Signals she cleared, as 'lh|2026-09-30' (2026-10-17). A TOMBSTONE.
  ///
  /// ⚠️ WHY IT EXISTS (the device walk, 2026-10-17): clearing an LH positive
  /// removed it here only. The pull is a union (`putIfAbsent`), so the next
  /// sync put the cloud's copy straight back, and a test the user had just
  /// cleared returned after a reinstall. Deleting the cloud row fixes the
  /// online case; this set fixes the offline one, where that delete never
  /// arrived: a pull skips any signal she cleared until she logs it again.
  /// The same pattern `TtcLogStore` uses (`_cleared`, H12).
  //
  // ⚠️ SUPERSEDED THE SAME DAY by the row clock below: a removal is now a
  // soft-deleted row (0097) that reaches every phone, not a note on this one.
  // The set is still read once, so a clear made on the previous build turns
  // into a removal that uploads.
  final Set<String> _clearedSignals = {};

  // ---- the row clock (2026-10-17, 0097) -------------------------------------
  //
  // Every synced row has a key: 'c|2026-09-30' for a period (its bleed days
  // ride on it), 'lh|2026-09-30' and 'temperature|2026-09-30' for a test
  // result on that cycle. Per key the store keeps:
  //
  //  · when she last changed it ON THIS PHONE (the merge clock; the newer
  //    change wins on every phone, see `ttc_row_merge.dart`);
  //  · whether that change was a removal (a soft delete, kept as a row);
  //  · whether the cloud has confirmed it yet (the "dirty" set; a row stays
  //    in it until its upload succeeds, so nothing is lost offline).
  //
  // A row from before this release has no time and reads as `ttcEpoch`, so
  // the cloud's copy wins wherever there is one.

  /// Row key → when she last changed it (UTC).
  final Map<String, DateTime> _stamps = {};

  /// Row key → when she removed it. A removed row is not shown anywhere.
  final Map<String, DateTime> _tombs = {};

  /// Row keys the cloud has not confirmed yet.
  final Set<String> _dirty = {};

  static String _cRow(DateTime d) => 'c|${_key(d)}';
  static String _sRow(String kind, DateTime start) => '$kind|${_key(start)}';

  void _touch(String row) {
    _stamps[row] = DateTime.now().toUtc();
    _tombs.remove(row);
    _dirty.add(row);
  }

  void _tomb(String row) {
    final t = DateTime.now().toUtc();
    _stamps[row] = t;
    _tombs[row] = t;
    _dirty.add(row);
  }

  @override
  bool get hasPendingPush => _dirty.isNotEmpty;

  @visibleForTesting
  Set<String> get dirtyRowsForTest => Set.unmodifiable(_dirty);

  @visibleForTesting
  Map<String, DateTime> get tombstonesForTest => Map.unmodifiable(_tombs);

  /// How many days she bled, per cycle start (ISO date key).
  ///
  /// WARNING: STORED SEPARATELY FROM THE START DATE, NOT ALONGSIDE IT. A period
  /// start is a fact she is sure of the day she logs it; the length is a fact
  /// she does not have yet. Putting them in one record would mean either
  /// blocking the log until the bleeding stops, or writing a length nobody
  /// measured -- and the second is what the cycle report has been doing all
  /// along, assuming five days to draw its first band.
  ///
  /// A missing key means "not answered", which is not the same as
  /// [kBleedStillOn]. Both are legitimate and they read differently on screen.
  final Map<String, int> _bleedDays = {};

  bool _loaded = false;
  bool get isLoaded => _loaded;

  // ---- reads ----------------------------------------------------------------

  /// Period starts, oldest first. Copied so callers cannot mutate our state.
  List<DateTime> get periodStarts => List.unmodifiable(_periodStarts);

  /// Bleeding days for the period that began on [start], or null if she has
  /// not said. [kBleedStillOn] means it had not finished when she logged it.
  int? bleedDaysFor(DateTime start) => _bleedDays[_key(_dayOnly(start))];

  /// The current cycle's first day, or null before anything is logged.
  //   DateTime? get lastPeriodStart =>
  //       _periodStarts.isEmpty ? null : _periodStarts.last;
  // Kept for revert (2026-10-24): the line above, before the restart rule.
  DateTime? get lastPeriodStart {
    if (_periodStarts.isEmpty) return null;
    final last = _periodStarts.last;
    final restart = restartOn;
    if (restart != null && last.isBefore(restart)) return null;
    return last;
  }

  /// The period starts that belong to her CURRENT run of cycles: all of them,
  /// or after a loss only those logged on or after [restartOn] (B2,
  /// 2026-10-24). For anything that counts forward from the last period - the
  /// "late, time to test" message above all. The full log stays in
  /// [periodStarts] for history and the calendar.
  List<DateTime> get currentPeriodStarts {
    final restart = restartOn;
    if (restart == null) return periodStarts;
    return [
      for (final s in periodStarts)
        if (!s.isBefore(restart)) s
    ];
  }

  /// The day her cycle starts again after a pregnancy loss, or null
  /// (2026-10-24, STAGE-TRANSITIONS B2).
  ///
  /// ⚠️ AFTER A LOSS, THE LAST PERIOD SHE LOGGED IS FROM BEFORE THE PREGNANCY.
  /// Counting from it, the home told a mother back in trying-to-conceive
  /// that her period was about ninety days late. While she is trying and a
  /// loss is recorded, a period logged before the loss is history: the
  /// current cycle waits for the first period she logs after it, and the
  /// home invites her to log it. DERIVED from the loss date the app already
  /// stores (and syncs), not a second date to keep in step: nothing has to
  /// remember to clear it, and undoing the loss undoes it.
  DateTime? get restartOn {
    final ended = PregnancyEndedStore.instance;
    if (!ended.lossRecorded || !LifeStageStore.instance.isTrying) return null;
    final at = ended.endedAt;
    return at == null ? null : DateTime(at.year, at.month, at.day);
  }

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
    final restart = restartOn;
    for (var i = 1; i < _periodStarts.length; i++) {
      // The span across a pregnancy is not a cycle (B2, 2026-10-24).
      if (restart != null &&
          _periodStarts[i - 1].isBefore(restart) &&
          !_periodStarts[i].isBefore(restart)) {
        continue;
      }
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
    _touch(_cRow(d));
    _persist();
    notifyListeners();
  }

  /// Records how many days a period lasted.
  ///
  /// [days] is a count, [kBleedStillOn] while it is ongoing, or null to clear.
  /// Silently ignores a start that is not logged, so a stale screen cannot
  /// create an orphan record keyed to a date the list does not hold.
  void logBleedDays(DateTime start, int? days) {
    final d = _dayOnly(start);
    if (!_periodStarts.any((e) => _sameDay(e, d))) return;
    if (days == null) {
      _bleedDays.remove(_key(d));
    } else {
      _bleedDays[_key(d)] = days;
    }
    // The bleed days ride on the cycle row (0097).
    _touch(_cRow(d));
    _persist();
    notifyListeners();
  }

  /// Moves a logged period from one day to another, keeping what hangs off it.
  ///
  /// WARNING: A MOVE, NOT A DELETE AND AN ADD. Doing it as two operations
  /// silently drops the bleed length, the LH strip and the temperature shift,
  /// because all three are keyed by the start date and `removePeriodStart`
  /// clears them on the way out. Correcting a date by one day would quietly
  /// erase everything she recorded about that cycle -- and nothing would look
  /// wrong afterwards, which is the worst shape a data loss can take.
  void movePeriodStart(DateTime from, DateTime to) {
    final a = _dayOnly(from);
    final b = _dayOnly(to);
    if (_sameDay(a, b)) return;
    if (!_periodStarts.any((e) => _sameDay(e, a))) return;
    if (_periodStarts.any((e) => _sameDay(e, b))) return;

    final bleed = _bleedDays.remove(_key(a));
    final lh = _lhPositive.remove(_key(a));
    final temp = _tempShift.remove(_key(a));

    _periodStarts
      ..removeWhere((e) => _sameDay(e, a))
      ..add(b)
      ..sort();
    if (bleed != null) _bleedDays[_key(b)] = bleed;
    if (lh != null) _lhPositive[_key(b)] = lh;
    if (temp != null) _tempShift[_key(b)] = temp;

    // The old date is REMOVED as a row and the new one written, so every
    // phone moves it (2026-10-17). Kept for revert:
    //   _deleteCycleFromCloud(a).catchError((_) {});
    _tomb(_cRow(a));
    _touch(_cRow(b));
    if (lh != null) {
      _tomb(_sRow('lh', a));
      _touch(_sRow('lh', b));
    }
    if (temp != null) {
      _tomb(_sRow('temperature', a));
      _touch(_sRow('temperature', b));
    }
    _persist();
    notifyListeners();
  }

  /// Everything hanging off a period start, so a removal can be put back.
  ///
  /// WARNING: THIS EXISTS FOR UNDO AND IT IS WHY UNDO IS HONEST. Restoring only
  /// the date would give her back a row that had lost its bleed length -- an
  /// undo that does not undo. Callers capture this BEFORE removing.
  ({int? bleed, int? lh, int? temp}) detailsFor(DateTime start) {
    final k = _key(_dayOnly(start));
    return (bleed: _bleedDays[k], lh: _lhPositive[k], temp: _tempShift[k]);
  }

  /// Puts a removed period back, with what it carried.
  void restorePeriodStart(
    DateTime day, {
    int? bleed,
    int? lh,
    int? temp,
  }) {
    final d = _dayOnly(day);
    if (_periodStarts.any((e) => _sameDay(e, d))) return;
    _periodStarts
      ..add(d)
      ..sort();
    if (bleed != null) _bleedDays[_key(d)] = bleed;
    if (lh != null) _lhPositive[_key(d)] = lh;
    if (temp != null) _tempShift[_key(d)] = temp;
    // A restore is a newer change than the removal, so it wins everywhere
    // (2026-10-17). The upload follows the notify like any other change.
    // Kept for revert: pushToCloud().catchError((_) {});
    _touch(_cRow(d));
    if (lh != null) _touch(_sRow('lh', d));
    if (temp != null) _touch(_sRow('temperature', d));
    _persist();
    notifyListeners();
  }

  /// Removes a logged period start - a mis-tap must always be undoable.
  void removePeriodStart(DateTime day) {
    final d = _dayOnly(day);
    final before = _periodStarts.length;
    _periodStarts.removeWhere((e) => _sameDay(e, d));
    if (_periodStarts.length == before) return;
    final hadLh = _lhPositive.remove(_key(d)) != null;
    final hadTemp = _tempShift.remove(_key(d)) != null;
    _bleedDays.remove(_key(d));
    // A removal is a row (2026-10-17, 0097), so it reaches every phone and
    // an older upload cannot undo it. Kept for revert:
    //   _deleteCycleFromCloud(d).catchError((_) {});
    _tomb(_cRow(d));
    if (hadLh) _tomb(_sRow('lh', d));
    if (hadTemp) _tomb(_sRow('temperature', d));
    _persist();
    notifyListeners();
  }

  /// Records a positive ovulation strip on the given cycle day of the current
  /// cycle. Passing null clears it.
  void logLhPositive(int? cycleDay) {
    final s = lastPeriodStart;
    if (s == null) return;
    // A soft delete, not a cloud delete (2026-10-17). Kept for revert:
    //   if (_lhPositive.remove(_key(s)) != null) _clearSignal(s, 'lh');
    //   ... else _clearedSignals.remove('lh|${_key(s)}');
    if (cycleDay == null) {
      if (_lhPositive.remove(_key(s)) != null) _tomb(_sRow('lh', s));
    } else {
      _lhPositive[_key(s)] = cycleDay;
      _touch(_sRow('lh', s));
    }
    _persist();
    notifyListeners();
  }

  /// A cleared signal must leave the cloud too, and stay cleared offline.
  /// Superseded by the soft delete (`_tomb`); kept for revert.
  // ignore: unused_element
  void _clearSignal(DateTime start, String kind) {
    _clearedSignals.add('$kind|${_key(start)}');
    if (SupabaseRepo.isLoggedIn) {
      SupabaseRepo.delete(TtcTables.signals, _signalId(start, kind))
          .catchError((_) {});
    }
  }

  /// Records the cycle day a sustained basal-temperature rise was seen.
  void logTemperatureShift(int? cycleDay) {
    final s = lastPeriodStart;
    if (s == null) return;
    if (cycleDay == null) {
      if (_tempShift.remove(_key(s)) != null) {
        _tomb(_sRow('temperature', s));
      }
    } else {
      _tempShift[_key(s)] = cycleDay;
      _touch(_sRow('temperature', s));
    }
    _persist();
    notifyListeners();
  }

  /// A sign-out, or another account signing in (2026-10-17): her cycle
  /// leaves this phone's memory. The account in the cloud keeps it.
  @override
  void resetLocal() => resetForTest();

  /// Testing / sign-out reset.
  @visibleForTesting
  void resetForTest() {
    _periodStarts.clear();
    _lhPositive.clear();
    _tempShift.clear();
    _bleedDays.clear();
    _clearedSignals.clear();
    _stamps.clear();
    _tombs.clear();
    _dirty.clear();
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
      _bleedDays
        ..clear()
        ..addAll(_decodeMap(p.getStringList(_bleedKey)));
      _clearedSignals
        ..clear()
        ..addAll(p.getStringList(_clearedSignalsKey) ?? const []);
      _stamps
        ..clear()
        ..addAll(_decodeStamps(p.getStringList(_stampsKey)));
      _tombs
        ..clear()
        ..addAll(_decodeStamps(p.getStringList(_tombsKey)));
      _dirty
        ..clear()
        ..addAll(p.getStringList(_dirtyKey) ?? const []);
      // A clear from the previous build becomes a removal that uploads.
      for (final row in _clearedSignals) {
        if (!_tombs.containsKey(row)) _tomb(row);
      }
      _clearedSignals.clear();
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

  // ⚠️ NEWER WINS, BOTH WAYS (2026-10-17, 0097). The pull below used to be a
  // union, which can never take anything away: a period removed or moved on
  // one phone came back from the next phone that still held it, and a test
  // she cleared returned after a reinstall (the device walk). Now each row's
  // edit time decides (`ttcMergePlan`): the cloud's newer copy is taken,
  // removals included, and the phone's newer copy is queued to upload.
  // The union pull is kept below as `_pullUnionKept`, for revert.
  @override
  Future<void> pullFromCloud() async {
    final cycles = await SupabaseRepo.fetch(TtcTables.cycles,
        orderBy: 'started_on', ascending: true);
    final signals = await SupabaseRepo.fetch(TtcTables.signals,
        orderBy: 'cycle_start', ascending: true);

    final cloudStamp = <String, DateTime>{};
    final cloudRow = <String, Map<String, dynamic>>{};
    for (final row in cycles) {
      final d = TtcSyncUtil.parseDate(row['started_on']);
      if (d == null) continue;
      final k = _cRow(d);
      cloudStamp[k] = ttcParseStamp(row['updated_at']) ?? ttcEpoch;
      cloudRow[k] = row;
    }
    for (final row in signals) {
      final start = TtcSyncUtil.parseDate(row['cycle_start']);
      final kind = row['kind'];
      if (start == null || (kind != 'lh' && kind != 'temperature')) continue;
      final k = _sRow(kind as String, start);
      cloudStamp[k] = ttcParseStamp(row['updated_at']) ?? ttcEpoch;
      cloudRow[k] = row;
    }

    final local = <String, DateTime>{
      for (final d in _periodStarts) _cRow(d): _stamps[_cRow(d)] ?? ttcEpoch,
      for (final k in _lhPositive.keys)
        'lh|$k': _stamps['lh|$k'] ?? ttcEpoch,
      for (final k in _tempShift.keys)
        'temperature|$k': _stamps['temperature|$k'] ?? ttcEpoch,
      for (final k in _tombs.keys) k: _stamps[k] ?? _tombs[k]!,
    };

    final plan = ttcMergePlan(local: local, cloud: cloudStamp);
    for (final k in plan.take) {
      _takeCloud(k, cloudRow[k]!, cloudStamp[k]!);
    }
    _dirty.addAll(plan.push);
    // A row both sides hold at the same time is already in the cloud.
    for (final k in cloudStamp.keys) {
      if (!plan.take.contains(k) && !plan.push.contains(k)) _dirty.remove(k);
    }
    _periodStarts.sort();
    // Removals the cloud has confirmed, older than 80 days, are forgotten
    // (sync log step 12): the same rule and the same reason as
    // `SyncRowBook.dropSettled`, before the server's 90-day purge (0109).
    final cutoff = DateTime.now().toUtc().subtract(SyncRowBook.keepRemovals);
    for (final k in _tombs.keys.toList()) {
      if (_tombs[k]!.isBefore(cutoff) && !_dirty.contains(k)) {
        _tombs.remove(k);
        _stamps.remove(k);
      }
    }
  }

  /// Takes the cloud's copy of one row: its value, or its removal.
  void _takeCloud(String k, Map<String, dynamic> row, DateTime stamp) {
    final bar = k.indexOf('|');
    final kind = k.substring(0, bar);
    final d = DateTime.tryParse(k.substring(bar + 1));
    if (d == null) return;
    final day = _dayOnly(d);
    final removedAt = ttcParseStamp(row['removed_at']);
    if (kind == 'c') {
      if (removedAt != null) {
        _periodStarts.removeWhere((e) => _sameDay(e, day));
        _bleedDays.remove(_key(day));
        _tombs[k] = removedAt;
      } else {
        if (!_periodStarts.any((e) => _sameDay(e, day))) _periodStarts.add(day);
        final bleed = row['bleed_days'];
        if (bleed is int) {
          _bleedDays[_key(day)] = bleed;
        } else if (row.containsKey('bleed_days')) {
          _bleedDays.remove(_key(day));
        }
        _tombs.remove(k);
      }
    } else {
      final target = kind == 'lh' ? _lhPositive : _tempShift;
      final cycleDay = row['cycle_day'];
      if (removedAt != null || cycleDay is! int) {
        target.remove(_key(day));
        _tombs[k] = removedAt ?? stamp;
      } else {
        target[_key(day)] = cycleDay;
        _tombs.remove(k);
      }
    }
    _stamps[k] = stamp;
    _dirty.remove(k);
  }

  // Kept for revert (2026-10-17): the union pull.
  // ignore: unused_element
  Future<void> _pullUnionKept() async {
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
      // A signal she cleared stays cleared (the tombstone above).
      final kind = row['kind'] == 'lh' ? 'lh' : 'temperature';
      if (_clearedSignals.contains('$kind|${_key(start)}')) continue;
      final target = kind == 'lh' ? _lhPositive : _tempShift;
      target.putIfAbsent(_key(start), () => day);
    }
  }

  /// Uploads the rows the cloud has not confirmed, one by one (2026-10-17). A
  /// row leaves the waiting set only when the cloud took it AND she has not
  /// changed it again meanwhile; anything else waits for the next resume,
  /// change or login. The old push (every row, unconfirmed, no times) is kept
  /// below as `_pushAllKept`, for revert.
  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    // In batches, one table at a time (step 11, sync_batch.dart). The
    // row-at-a-time loop it replaced, kept for revert:
    //   for (final k in List.of(_dirty)) {
    //     final row = _rowFor(k, uid);
    //     if (row == null) { _dirty.remove(k); continue; }
    //     final sent = _stamps[k];
    //     final ok = await TtcSyncUtil.upsertConfirmed(
    //         k.startsWith('c|') ? TtcTables.cycles : TtcTables.signals, row, onConflict: 'id');
    //     if (ok && _stamps[k] == sent) _dirty.remove(k);
    //   }
    final cycles = <String, Map<String, dynamic>>{};
    final signals = <String, Map<String, dynamic>>{};
    final sent = <String, DateTime?>{};
    for (final k in List.of(_dirty)) {
      final row = _rowFor(k, uid);
      if (row == null) {
        _dirty.remove(k);
        continue;
      }
      sent[k] = _stamps[k];
      (k.startsWith('c|') ? cycles : signals)[k] = row;
    }
    for (final part in [(TtcTables.cycles, cycles), (TtcTables.signals, signals)]) {
      final took = await SyncBatch.push(part.$2,
          (batch) => SupabaseRepo.upsertRows(part.$1, batch, onConflict: 'user_id,id'));
      for (final k in took) {
        if (_stamps[k] == sent[k]) _dirty.remove(k);
      }
    }
    await _persist();
  }

  /// The cloud row for one key, with its edit time and removal.
  Map<String, dynamic>? _rowFor(String k, String uid) {
    final bar = k.indexOf('|');
    final kind = k.substring(0, bar);
    final dateKey = k.substring(bar + 1);
    final d = DateTime.tryParse(dateKey);
    if (d == null) return null;
    final stamp = _stamps[k] ?? DateTime.now().toUtc();
    final removed = _tombs[k];
    if (kind == 'c') {
      return {
        'id': _cycleId(d),
        'user_id': uid,
        'started_on': dateKey,
        'updated_at': TtcSyncUtil.stamp(stamp),
        'removed_at': removed == null ? null : TtcSyncUtil.stamp(removed),
        'bleed_days': removed == null ? _bleedDays[dateKey] : null,
      };
    }
    if (kind != 'lh' && kind != 'temperature') return null;
    final value = (kind == 'lh' ? _lhPositive : _tempShift)[dateKey];
    return {
      'id': _signalId(d, kind),
      'user_id': uid,
      'cycle_start': dateKey,
      'kind': kind,
      // A removed row keeps a valid day for the 1-90 check; it is never read.
      'cycle_day': value ?? 1,
      'updated_at': TtcSyncUtil.stamp(stamp),
      'removed_at': removed == null ? null : TtcSyncUtil.stamp(removed),
    };
  }

  // Kept for revert (2026-10-17): every row, unconfirmed, no times.
  // ignore: unused_element
  Future<void> _pushAllKept() async {
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
      onConflict: 'user_id,id',
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
    await TtcSyncUtil.upsertAll(TtcTables.signals, rows, onConflict: 'user_id,id');
  }

  @override
  Future<void> persistLocalCache() => _persist();

  /// A removed period must be removed in the cloud too - a union merge would
  /// otherwise bring it straight back on the next pull. Superseded by the
  /// soft delete (2026-10-17); kept for revert.
  // ignore: unused_element
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
      await p.setStringList(_bleedKey, _encodeMap(_bleedDays));
      await p.setStringList(_clearedSignalsKey, _clearedSignals.toList());
      await p.setStringList(_stampsKey, _encodeStamps(_stamps));
      await p.setStringList(_tombsKey, _encodeStamps(_tombs));
      await p.setStringList(_dirtyKey, _dirty.toList());
    } catch (_) {/* best-effort */}
  }

  // "c|2026-09-30|2026-10-17T10:04:00.000Z": the row key, then the time.
  static List<String> _encodeStamps(Map<String, DateTime> m) => [
        for (final e in m.entries) '${e.key}|${e.value.toIso8601String()}',
      ];

  static Map<String, DateTime> _decodeStamps(List<String>? raw) {
    final out = <String, DateTime>{};
    for (final s in raw ?? const <String>[]) {
      final i = s.lastIndexOf('|');
      if (i <= 0) continue;
      final t = DateTime.tryParse(s.substring(i + 1));
      if (t != null) out[s.substring(0, i)] = t.toUtc();
    }
    return out;
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
  int? statedCycleLength,
  bool statedIrregular = false,
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
      statedCycleLength: statedCycleLength,
      statedIrregular: statedIrregular,
    );
