// =============================================================================
//  MedicineStore - persistence for Daily Medication & Supplement Tracking
// -----------------------------------------------------------------------------
//  Stores the mother's medications/supplements and a log of which were taken on
//  which day (once-per-day model for v1). Exposes gentle, judgment-free stats:
//  today's progress, weekly per-item counts, and 30-day consistency. No streaks.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/medication.dart';
import 'notification_service.dart';
import 'remote/own_row_ledger.dart';
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';
import 'remote/sync_row_book.dart';

class MedicineStore extends ChangeNotifier {
  MedicineStore._();
  static final MedicineStore instance = MedicineStore._();

  static const _medsKey = 'medicine_meds';
  static const _logsKey = 'medicine_logs';

  final List<Medication> _meds = [];
  final List<MedicationLog> _logs = [];
  bool _loaded = false;

  // ---- newer-wins sync (2026-10-21, sync log step 9, migration 0107) -------
  // Both tables are own-only. A removal is a soft delete that travels, an
  // offline change waits and goes up later, and the alarms ride on the
  // medication row so every phone re-arms them from the same fact (§16ii-g).
  final OwnRowLedger _medSync = OwnRowLedger('medications', 'medications_sync');
  final OwnRowLedger _logSync =
      OwnRowLedger('medication_logs', 'medication_logs_sync');

  /// Changes the cloud has not confirmed (the sign-out sheet reads this).
  bool get hasPending => _medSync.hasPending || _logSync.hasPending;

  Map<String, Map<String, dynamic>> _medRows() =>
      {for (final m in _meds) m.id: _toMedRow(m)};
  Map<String, Map<String, dynamic>> _logRows() =>
      {for (final l in _logs) l.id: _toLogRow(l)};

  Future<void> _pushWaiting() async {
    await _medSync.push(_medRows);
    await _logSync.push(_logRows);
  }

  /// One log per medication per day, so its id is made from both: two phones
  /// ticking the same day write the same row instead of two (step 9).
  static String logIdFor(String medId, String dateKey) =>
      'ml_${medId}_$dateKey';

  /// Arms every medication's alarms. Also run after a sign-in.
  Future<void> rearmNotifications() async {
    try {
      await NotificationService.instance.syncMedicationAlarms(_meds);
    } catch (_) {/* notifications not ready - alarms arm on next add/edit */}
  }

  Future<void> init() async {
    if (_loaded) return;
    // 1) Local cache first.
    try {
      final prefs = await SharedPreferences.getInstance();
      final m = prefs.getString(_medsKey);
      if (m != null) {
        for (final e in (jsonDecode(m) as List)) {
          _meds.add(Medication.fromJson(Map<String, dynamic>.from(e)));
        }
      }
      final l = prefs.getString(_logsKey);
      if (l != null) {
        for (final e in (jsonDecode(l) as List)) {
          _logs.add(MedicationLog.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    await _medSync.load();
    await _logSync.load();
    SyncRegistry.registerPending(() => hasPending);
    _loaded = true;
    notifyListeners();

    // Re-arm medication alarms over the rolling horizon (best-effort).
    await rearmNotifications();
    // After a sign-in the alarms come back with her (2026-10-10, sign-out mutes).
    SyncRegistry.register(rearmNotifications);

    // 2) Then sync with the cloud (no-op if logged out).
    await _syncFromCloud();
  }

  // Two tables in one store → merge each. Same recipe as symptom, twice.
  /// A sign-out, or another account signing in (2026-10-17): this store
  /// forgets the person in memory; the cloud keeps it.
  void _resetLocal() {
    _meds.clear();
    _logs.clear();
    _medSync
      ..clear()
      ..save();
    _logSync
      ..clear()
      ..save();
    notifyListeners();
  }

  /// Newer wins per row (step 9). A medication removed on another phone
  /// loses its alarms here; one changed there is re-armed from its row.
  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    SyncRegistry.registerReset(_resetLocal);
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      final meds = {for (final m in _meds) m.id: m};
      final gone = <String>[];
      final changed = <Medication>[];
      for (final r in await _medSync.pull(liveKeys: meds.keys)) {
        final id = r['id'] as String;
        if (syncParseStamp(r['removed_at']) != null) {
          meds.remove(id);
          gone.add(id);
          continue;
        }
        final keep = meds[id]?.alarms ?? const <MedAlarm>[];
        final m = _fromMedRow(r, keepAlarms: keep);
        meds[id] = m;
        changed.add(m);
        // A row from before 0107 has no alarms: send this phone's up once.
        if (r['alarms'] == null && keep.isNotEmpty) _medSync.touch(id);
      }
      _meds
        ..clear()
        ..addAll(meds.values);
      await _persistMeds();

      final logs = {for (final l in _logs) l.id: l};
      for (final r in await _logSync.pull(
          liveKeys: logs.keys, orderBy: 'taken_at_iso')) {
        final id = r['id'] as String;
        if (syncParseStamp(r['removed_at']) != null) {
          logs.remove(id);
        } else {
          logs[id] = _fromLogRow(r);
        }
      }
      _logs
        ..clear()
        ..addAll(logs.values);
      await _persistLogs();
      notifyListeners();

      // The alarms follow the fact: each phone keeps its own OS alarms.
      for (final id in gone) {
        try {
          await NotificationService.instance.cancelMedicationAlarms(id);
        } catch (_) {}
      }
      for (final m in changed) {
        try {
          await NotificationService.instance.scheduleMedicationAlarms(m);
        } catch (_) {}
      }
      await _pushWaiting();
    } catch (_) {/* offline - keep local; the ledgers keep what waits */}
  }

  // ignore: unused_element
  Future<void> _syncFromCloudOld() async {
    // kept for revert (before step 9): cloud wins per id, local-only rows are
    // inserted again, so a medication deleted elsewhere came back and every
    // pull wiped the alarms.
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      // medications
      final medRows = await SupabaseRepo.fetch('medications');
      final medById = {for (final r in medRows) r['id'].toString(): _fromMedRow(r)};
      for (final m in _meds) {
        if (!medById.containsKey(m.id)) {
          medById[m.id] = m;
          await SupabaseRepo.insert('medications', _toMedRow(m));
        }
      }
      _meds
        ..clear()
        ..addAll(medById.values);
      await _persistMeds();

      // medication_logs
      final logRows =
          await SupabaseRepo.fetch('medication_logs', orderBy: 'taken_at_iso');
      final logById = {for (final r in logRows) r['id'].toString(): _fromLogRow(r)};
      for (final l in _logs) {
        if (!logById.containsKey(l.id)) {
          logById[l.id] = l;
          await SupabaseRepo.insert('medication_logs', _toLogRow(l));
        }
      }
      _logs
        ..clear()
        ..addAll(logById.values);
      await _persistLogs();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  // ---- camelCase model <-> snake_case columns -------------------------------
  Map<String, dynamic> _toMedRow(Medication m) => {
        'id': m.id,
        'name': m.name,
        'type': m.type.name,
        'dose': m.dose,
        'time': m.time,
        'frequency': m.frequency,
        'notes': m.notes,
        'preset_key': m.presetKey,
        // date columns: empty string isn't a valid date → send null instead
        'start_date_iso': m.startDateIso.isEmpty ? null : m.startDateIso,
        'end_date_iso':
            (m.endDateIso == null || m.endDateIso!.isEmpty) ? null : m.endDateIso,
        'is_active': m.isActive,
        // 0107: the alarm settings sync; each phone arms its own (step 9).
        'alarms': m.alarms.map((a) => a.toJson()).toList(),
      };

  /// [keepAlarms]: this phone's alarms, kept when the row predates 0107.
  Medication _fromMedRow(Map<String, dynamic> r,
      {List<MedAlarm> keepAlarms = const []}) {
    var t = MedType.supplement;
    for (final e in MedType.values) {
      if (e.name == r['type']) {
        t = e;
        break;
      }
    }
    return Medication(
      id: (r['id'] ?? '').toString(),
      name: (r['name'] ?? '').toString(),
      type: t,
      dose: (r['dose'] ?? '').toString(),
      time: (r['time'] ?? '').toString(),
      frequency: (r['frequency'] ?? '').toString(),
      notes: (r['notes'] ?? '').toString(),
      presetKey: r['preset_key']?.toString(),
      startDateIso: (r['start_date_iso'] ?? '').toString(),
      endDateIso: r['end_date_iso']?.toString(),
      isActive: r['is_active'] != false,
      alarms: (r['alarms'] is List)
          ? (r['alarms'] as List)
              .whereType<Map>()
              .map((e) => MedAlarm.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : keepAlarms,
    );
  }

  Map<String, dynamic> _toLogRow(MedicationLog l) => {
        'id': l.id,
        'medication_id': l.medicationId,
        'date_key': l.dateKey,
        'taken_at_iso': l.takenAtIso,
      };

  MedicationLog _fromLogRow(Map<String, dynamic> r) => MedicationLog(
        id: (r['id'] ?? '').toString(),
        medicationId: (r['medication_id'] ?? '').toString(),
        dateKey: (r['date_key'] ?? '').toString(),
        takenAtIso: (r['taken_at_iso'] ?? '').toString(),
      );

  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  bool get isEmpty => _meds.isEmpty;

  /// Her day logs for one medicine, for an Undo that brings them back.
  List<MedicationLog> logsFor(String medId) =>
      [for (final l in _logs) if (l.medicationId == medId) l];

  /// Puts back a deleted medicine with its own id and logs (the Undo on a
  /// delete, P1 2026-10-28). The same ids, so the merge sees the rows return.
  Future<void> restoreMed(Medication m, List<MedicationLog> logs) async {
    if (_meds.any((x) => x.id == m.id)) return;
    for (final l in logs) {
      if (_logs.any((x) => x.id == l.id)) continue;
      _logs.add(l);
      _logSync.touch(l.id);
    }
    await _persistLogs();
    await addMed(m);
  }
  List<Medication> get all => List.unmodifiable(_meds);
  List<Medication> get activeMeds =>
      _meds.where((m) => m.isActive).toList();

  bool isTakenOn(String medId, String key) =>
      _logs.any((l) => l.medicationId == medId && l.dateKey == key);

  bool isTakenToday(String medId) =>
      isTakenOn(medId, dateKey(DateTime.now()));

  int get takenTodayCount =>
      activeMeds.where((m) => isTakenToday(m.id)).length;

  int get todayTotal => activeMeds.length;

  // --- mutations -------------------------------------------------------------

  Future<void> addMed(Medication m) async {
    _meds.add(m);
    _medSync.touch(m.id);
    notifyListeners();
    await _persistMeds();
    try {
      await NotificationService.instance.scheduleMedicationAlarms(m);
    } catch (_) {}
    // kept for revert (before step 9): a one-shot insert, lost if offline.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.insert('medications', _toMedRow(m));
    //   } catch (_) {/* offline - syncs up on next init */}
    // }
    await _pushWaiting();
  }

  Future<void> updateMed(Medication m) async {
    final i = _meds.indexWhere((x) => x.id == m.id);
    if (i < 0) return;
    _meds[i] = m;
    _medSync.touch(m.id);
    notifyListeners();
    await _persistMeds();
    try {
      // scheduleMedicationAlarms cancels then reschedules from scratch.
      await NotificationService.instance.scheduleMedicationAlarms(m);
    } catch (_) {}
    // kept for revert (before step 9):
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.upsert('medications', _toMedRow(m), onConflict: 'id');
    //   } catch (_) {}
    // }
    await _pushWaiting();
  }

  Future<void> deleteMed(String id) async {
    // Soft deletes that travel (step 9): the medication and each of its logs.
    for (final m in _meds.where((m) => m.id == id)) {
      _medSync.remove(id, _toMedRow(m));
    }
    for (final l in _logs.where((l) => l.medicationId == id)) {
      _logSync.remove(l.id, _toLogRow(l));
    }
    _meds.removeWhere((m) => m.id == id);
    _logs.removeWhere((l) => l.medicationId == id);
    notifyListeners();
    await _persistMeds();
    await _persistLogs();
    try {
      await NotificationService.instance.cancelMedicationAlarms(id);
    } catch (_) {}
    // kept for revert (before step 9): one-shot hard deletes.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.delete('medications', id);
    //     await SupabaseRepo.deleteBy('medication_logs', 'medication_id', id);
    //   } catch (_) {}
    // }
    await _pushWaiting();
  }

  /// Toggle today's "taken" state for a medication (log or un-log).
  Future<void> toggleToday(String medId) async {
    final key = dateKey(DateTime.now());
    if (isTakenOn(medId, key)) {
      final removed =
          _logs.where((l) => l.medicationId == medId && l.dateKey == key).toList();
      _logs.removeWhere((l) => l.medicationId == medId && l.dateKey == key);
      // Soft deletes (step 9); every id for the day goes, old duplicates too.
      for (final l in removed) {
        _logSync.remove(l.id, _toLogRow(l));
      }
      notifyListeners();
      await _persistLogs();
      // kept for revert (before step 9): one-shot hard deletes.
      // if (SupabaseRepo.isLoggedIn) {
      //   try {
      //     for (final l in removed) {
      //       await SupabaseRepo.delete('medication_logs', l.id);
      //     }
      //   } catch (_) {}
      // }
    } else {
      final log = MedicationLog(
        // kept for revert (before step 9): a new id on every tick.
        // id: 'ml_${DateTime.now().microsecondsSinceEpoch}',
        id: logIdFor(medId, key),
        medicationId: medId,
        dateKey: key,
        takenAtIso: DateTime.now().toIso8601String(),
      );
      _logs.add(log);
      // A re-tick is a newer touch of the same key, so it beats the removal.
      _logSync.touch(log.id);
      notifyListeners();
      await _persistLogs();
      // kept for revert (before step 9):
      // if (SupabaseRepo.isLoggedIn) {
      //   try {
      //     await SupabaseRepo.insert('medication_logs', _toLogRow(log));
      //   } catch (_) {}
      // }
    }
    await _logSync.push(_logRows);
  }

  /// Toggle the "taken" state for any past day, not only today.
  ///
  /// ⚠️ ADDITIVE (TTC tool rebuild, 2026-09-27). The TTC Medication page lets
  /// her put right a day she forgot to tick, the way Apple Health's week strip
  /// does. Same log row shape and the same cloud calls as `toggleToday`, which
  /// is left exactly as it was so the pregnancy tracker is untouched.
  Future<void> toggleOn(String medId, DateTime day) async {
    final key = dateKey(day);
    if (isTakenOn(medId, key)) {
      final removed = _logs
          .where((l) => l.medicationId == medId && l.dateKey == key)
          .toList();
      _logs.removeWhere((l) => l.medicationId == medId && l.dateKey == key);
      // Soft deletes (step 9); every id for the day goes, old duplicates too.
      for (final l in removed) {
        _logSync.remove(l.id, _toLogRow(l));
      }
      notifyListeners();
      await _persistLogs();
      // kept for revert (before step 9): one-shot hard deletes.
      // if (SupabaseRepo.isLoggedIn) {
      //   try {
      //     for (final l in removed) {
      //       await SupabaseRepo.delete('medication_logs', l.id);
      //     }
      //   } catch (_) {}
      // }
    } else {
      final log = MedicationLog(
        // kept for revert (before step 9): a new id on every tick.
        // id: 'ml_${DateTime.now().microsecondsSinceEpoch}',
        id: logIdFor(medId, key),
        medicationId: medId,
        dateKey: key,
        takenAtIso: DateTime.now().toIso8601String(),
      );
      _logs.add(log);
      // A re-tick is a newer touch of the same key, so it beats the removal.
      _logSync.touch(log.id);
      notifyListeners();
      await _persistLogs();
      // kept for revert (before step 9):
      // if (SupabaseRepo.isLoggedIn) {
      //   try {
      //     await SupabaseRepo.insert('medication_logs', _toLogRow(log));
      //   } catch (_) {}
      // }
    }
    await _logSync.push(_logRows);
  }

  // --- stats (gentle, judgment-free) -----------------------------------------

  /// Distinct days in the last 7 (incl. today) this medication was logged.
  int weeklyDays(String medId) {
    final now = DateTime.now();
    var n = 0;
    for (int i = 0; i < 7; i++) {
      final key = dateKey(now.subtract(Duration(days: i)));
      if (isTakenOn(medId, key)) n++;
    }
    return n;
  }

  /// Days in the last 30 on which at least one medication was logged.
  int get consistencyDays30 {
    final now = DateTime.now();
    final days = <String>{};
    for (final l in _logs) {
      days.add(l.dateKey);
    }
    var n = 0;
    for (int i = 0; i < 30; i++) {
      if (days.contains(dateKey(now.subtract(Duration(days: i))))) n++;
    }
    return n;
  }

  // --- moving into pregnancy (P1 D3, 2026-10-28) -----------------------------

  /// When a medicine was added, read from its id. Both trackers mint
  /// `<prefix>_<microseconds>` (`med_` here, `ttcm_` on the TTC page); an id
  /// in any other shape answers null, never a guess.
  static DateTime? addedAt(Medication m) {
    final bar = m.id.lastIndexOf('_');
    if (bar < 0) return null;
    final us = int.tryParse(m.id.substring(bar + 1));
    return us == null ? null : DateTime.fromMicrosecondsSinceEpoch(us);
  }

  /// ⚠️ DERIVED FROM THE ID, NOT A NEW COLUMN. The medicines she added while
  /// trying (letrozole, progesterone, folic acid) and still has on. A TTC id
  /// (`ttcm_`) says it on its own; any other counts when it was made before
  /// [pregnancyStart]. No stage column and no migration: the id already holds
  /// the moment it was made. The cost, named: the meaning is tied to the id
  /// format, so an id that does not parse is "not known" and is left out.
  List<Medication> addedBefore(DateTime pregnancyStart) => [
        for (final m in activeMeds)
          if (m.id.startsWith('ttcm_') ||
              (addedAt(m)?.isBefore(pregnancyStart) ?? false))
            m,
      ];

  /// The medicines she added during a pregnancy that has ended and still has
  /// on (T4 K7, the TTC mirror of D3). Read from the id, as [addedBefore]
  /// is: a TTC id (`ttcm_`) was added while trying, so it never counts, and
  /// an id that does not parse is left out.
  List<Medication> addedDuring(DateTime start, DateTime end) {
    final from = DateTime(start.year, start.month, start.day);
    final to = DateTime(end.year, end.month, end.day)
        .add(const Duration(days: 1));
    return [
      for (final m in activeMeds)
        if (!m.id.startsWith('ttcm_'))
          if (addedAt(m) case final at?)
            if (!at.isBefore(from) && at.isBefore(to)) m,
    ];
  }

  Future<void> _persistMeds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _medsKey, jsonEncode(_meds.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> _persistLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _logsKey, jsonEncode(_logs.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }
}
