// =============================================================================
//  TtcVaccineStore — where she stands on each preconception vaccine
// -----------------------------------------------------------------------------
//  Singleton `ChangeNotifier`, private constructor, lazy load,
//  `shared_preferences`. The house pattern.
//
//  ⚠️ THIS IS HER NOTE TO HERSELF, NOT A CLINICAL RECORD, and the distinction
//  is load-bearing. Nothing here is verified, nothing is sent anywhere, and
//  nothing about it should ever be presented as fact to a clinician. It exists
//  because "am I rubella immune?" is a question with a real answer that a woman
//  gets once, from a blood test, and then has to remember for months.
//
//  ⚠️ SYNCED SINCE STEP 13 (2026-10-22): see the note above the class. The
//  header said "NO CLOUD SYNC, DELIBERATELY" until T3 K11 (2026-10-29), which
//  had been untrue for a week. Kept for revert:
//    ⚠️ NO CLOUD SYNC, DELIBERATELY. TTC takes no new tables while its UI is
//    being finalised — docs/STILL-OPEN.md §9.7, the same call TTC attachments
//    made. Local-first already behaves correctly: it shows instantly and there
//    is no cloud call to fail.
//
//  ⚠️ A SECOND DOSE IS ONE MORE ID, NOT A NEW SHAPE (T3 W14, 2026-10-29).
//  Varicella is two doses, and the month's wait counts from the second. Dose
//  two is stored as `<id>_2` with status `done` and its date, in the same maps
//  and the same merged cloud item set, so no table, column or item format
//  changed. Nothing iterates `_status` expecting only vaccine ids: every
//  reader walks `kTtcVaccines`, so `varicella_2` is invisible to them.
//
//  ⚠️ STATUS IS PERSISTED BY NAME, NOT INDEX. Reordering `TtcVaccineStatus`
//  later would silently reinterpret every stored value — the same class of bug
//  as `.now` where `.en` was meant.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/cloud_merged_store.dart';
// import '../services/remote/sync_registry.dart'; // kept for revert (step 13: the mixin registers)

import 'ttc_vaccines_data.dart';

// ⚠️ IN THE CLOUD SINCE STEP 13 (2026-10-22, sync log). It was phone-only, so
// a sign-out or a new phone lost where she stood on every vaccine (and the
// live-vaccine wait). Items: `v|<vaccine id>` -> `[status name]`, or
// `[status name, given on (ISO)]` for `done`. Status and date are one item
// because `set` writes them together and one must never outlive the other.
class TtcVaccineStore extends ChangeNotifier with CloudMergedStore {
  TtcVaccineStore._();
  // Kept for revert (step 13): the reset now comes from the mixin.
  //   TtcVaccineStore._() {
  //     SyncRegistry.registerReset(_resetForAccount);
  //   }
  static final TtcVaccineStore instance = TtcVaccineStore._();

  static const _kStatus = 'ttc_vaccine_status';
  static const _kDoneOn = 'ttc_vaccine_done_on';

  final Map<String, TtcVaccineStatus> _status = {};

  /// When a live vaccine was given, so the wait can be counted from it.
  final Map<String, DateTime> _doneOn = {};

  bool _loaded = false;

  TtcVaccineStatus statusOf(String id) =>
      _status[id] ?? TtcVaccineStatus.unknown;

  DateTime? doneOn(String id) => _doneOn[id];

  static String _second(String id) => '${id}_2';

  /// When dose two was given, for a vaccine given in two (T3 W14).
  DateTime? secondDoseOn(String id) => _doneOn[_second(id)];

  /// The dose the live wait counts from: the second when there is one.
  DateTime? lastDoseOn(String id) => secondDoseOn(id) ?? _doneOn[id];

  /// The day dose two can be given: four weeks after dose one. Null unless
  /// the course needs it and only dose one is logged.
  DateTime? secondDoseDueFrom(TtcVaccine v) {
    if (v.doses < 2 || statusOf(v.id) != TtcVaccineStatus.done) return null;
    final first = _doneOn[v.id];
    if (first == null || secondDoseOn(v.id) != null) return null;
    return first.add(const Duration(days: TtcVaccine.doseGapDays));
  }

  /// Live vaccines with dose one logged and dose two still owed.
  List<TtcVaccine> get secondDoseOwed => [
        for (final v in ttcLiveVaccines)
          if (secondDoseDueFrom(v) != null) v,
      ];

  /// Logs dose two (or clears it with null). Dose one must be logged first.
  Future<void> setSecondDose(String id, DateTime? on) async {
    final k = _second(id);
    if (on == null) {
      _status.remove(k);
      _doneOn.remove(k);
    } else {
      _status[k] = TtcVaccineStatus.done;
      _doneOn[k] = on;
    }
    notifyListeners();
    await _persistNow();
  }

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final p = await SharedPreferences.getInstance();

    for (final row in p.getStringList(_kStatus) ?? const <String>[]) {
      final i = row.indexOf(':');
      if (i <= 0) continue;
      final id = row.substring(0, i);
      final name = row.substring(i + 1);
      final match = TtcVaccineStatus.values.where((s) => s.name == name);
      // A value we no longer recognise is dropped rather than throwing. A
      // status note must never be the reason a screen fails to open.
      if (match.isNotEmpty) _status[id] = match.first;
    }

    for (final row in p.getStringList(_kDoneOn) ?? const <String>[]) {
      final i = row.indexOf(':');
      if (i <= 0) continue;
      final at = DateTime.tryParse(row.substring(i + 1));
      if (at != null) _doneOn[row.substring(0, i)] = at;
    }

    notifyListeners();
    await syncMergedFromCloud();
  }

  // ---- the cloud (step 13) --------------------------------------------------

  @override
  String get cloudKey => 'ttc_vaccines';

  @override
  Map<String, Object?> cloudItems() => {
        for (final e in _status.entries)
          'v|${e.key}': [
            e.value.name,
            if (_doneOn[e.key] != null) _doneOn[e.key]!.toIso8601String(),
          ],
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _status.clear();
    _doneOn.clear();
    for (final e in items.entries) {
      final v = e.value;
      if (!e.key.startsWith('v|') || v is! List || v.isEmpty) continue;
      final id = e.key.substring(2);
      final match = TtcVaccineStatus.values.where((s) => s.name == '${v[0]}');
      if (match.isEmpty) continue;
      _status[id] = match.first;
      final at = v.length > 1 ? DateTime.tryParse('${v[1]}') : null;
      if (at != null) _doneOn[id] = at;
    }
    _loaded = true;
  }

  @override
  Future<void> persistLocalCache() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_kStatus,
          [for (final e in _status.entries) '${e.key}:${e.value.name}']);
      await p.setStringList(_kDoneOn, [
        for (final e in _doneOn.entries) '${e.key}:${e.value.toIso8601String()}'
      ]);
    } catch (_) {/* best effort */}
  }

  Future<void> set(String id, TtcVaccineStatus status, {DateTime? on}) async {
    _status[id] = status;

    // The date is only meaningful for `done`, and clearing it on any other
    // status stops a stale date outliving the status that justified it — which
    // is how a "wait until" line ends up shown beside "immune".
    if (status == TtcVaccineStatus.done) {
      _doneOn[id] = on ?? DateTime.now();
    } else {
      _doneOn.remove(id);
      // Dose two cannot outlive dose one (T3 W14).
      _status.remove(_second(id));
      _doneOn.remove(_second(id));
    }

    notifyListeners();
    await _persistNow();
  }

  Future<void> _persistNow() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
        _kStatus, [for (final e in _status.entries) '${e.key}:${e.value.name}']);
    await p.setStringList(_kDoneOn, [
      for (final e in _doneOn.entries) '${e.key}:${e.value.toIso8601String()}'
    ]);
  }

  // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  // are wiped, the singleton was not.
  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   void _resetForAccount() {
  //     _status.clear();
  //     _doneOn.clear();
  //     _loaded = false;
  //     notifyListeners();
  //   }

  /// Empties the store in memory, for a test that needs a first open.
  /// (Added 2026-09-27, tool rebuild: tests used to tidy up by hand.)
  @visibleForTesting
  void resetForTest() {
    _status.clear();
    _doneOn.clear();
    _loaded = true;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  //  The one question the screen actually answers
  // ---------------------------------------------------------------------------

  /// The date after which no live vaccine is still holding her back, or null
  /// when nothing is.
  ///
  /// ⚠️ THE LATEST OF THE WAITS, NOT THE FIRST. Two live vaccines given a
  /// fortnight apart produce two windows, and the one that matters is whichever
  /// ends last. Taking the earliest would tell her she is clear while she is
  /// not — the exact failure this whole surface exists to prevent.
  DateTime? clearToTryFrom() {
    DateTime? latest;
    for (final v in ttcLiveVaccines) {
      if (statusOf(v.id) != TtcVaccineStatus.done) continue;
      // ⚠️ FROM THE LAST DOSE, AND NOT WHILE ONE IS OWED (T3 W14). With dose
      // one only, the course is not finished, so there is no wait to count
      // yet: `secondDoseOwed` carries it instead. Kept for revert:
      //   final at = _doneOn[v.id];
      if (secondDoseDueFrom(v) != null) continue;
      final at = lastDoseOn(v.id);
      if (at == null) continue;
      final until = at.add(Duration(days: v.waitDays));
      if (latest == null || until.isAfter(latest)) latest = until;
    }
    // A wait that has already elapsed is not a wait. Returning a past date
    // would render "wait until" on a date behind her.
    if (latest != null && latest.isBefore(DateTime.now())) return null;
    return latest;
  }

  /// Live vaccines she has said she needs but has not had. These are what turn
  /// into a wait the moment she has them, so they earn the top of the screen.
  List<TtcVaccine> get liveOutstanding => [
        for (final v in ttcLiveVaccines)
          if (statusOf(v.id) == TtcVaccineStatus.needed) v,
      ];

  /// Anything at all she has not yet recorded. Drives the quiet progress line —
  /// never a score, never a percentage.
  int get unrecorded => [
        for (final v in kTtcVaccines)
          if (statusOf(v.id) == TtcVaccineStatus.unknown) v,
      ].length;
}
