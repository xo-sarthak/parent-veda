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
//  ⚠️ NO CLOUD SYNC, DELIBERATELY. TTC takes no new tables while its UI is
//  being finalised — docs/STILL-OPEN.md §9.7, the same call TTC attachments
//  made. Local-first already behaves correctly: it shows instantly and there is
//  no cloud call to fail.
//
//  ⚠️ STATUS IS PERSISTED BY NAME, NOT INDEX. Reordering `TtcVaccineStatus`
//  later would silently reinterpret every stored value — the same class of bug
//  as `.now` where `.en` was meant.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ttc_vaccines_data.dart';

class TtcVaccineStore extends ChangeNotifier {
  TtcVaccineStore._();
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
    }

    notifyListeners();

    final p = await SharedPreferences.getInstance();
    await p.setStringList(
        _kStatus, [for (final e in _status.entries) '${e.key}:${e.value.name}']);
    await p.setStringList(_kDoneOn, [
      for (final e in _doneOn.entries) '${e.key}:${e.value.toIso8601String()}'
    ]);
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
      final at = _doneOn[v.id];
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
