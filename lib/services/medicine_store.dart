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
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';

class MedicineStore extends ChangeNotifier {
  MedicineStore._();
  static final MedicineStore instance = MedicineStore._();

  static const _medsKey = 'medicine_meds';
  static const _logsKey = 'medicine_logs';

  final List<Medication> _meds = [];
  final List<MedicationLog> _logs = [];
  bool _loaded = false;

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
    _loaded = true;
    notifyListeners();

    // Re-arm medication alarms over the rolling horizon (best-effort).
    try {
      await NotificationService.instance.syncMedicationAlarms(_meds);
    } catch (_) {/* notifications not ready - alarms arm on next add/edit */}

    // 2) Then sync with the cloud (no-op if logged out).
    await _syncFromCloud();
  }

  // Two tables in one store → merge each. Same recipe as symptom, twice.
  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
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
      };

  Medication _fromMedRow(Map<String, dynamic> r) {
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
    notifyListeners();
    await _persistMeds();
    try {
      await NotificationService.instance.scheduleMedicationAlarms(m);
    } catch (_) {}
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.insert('medications', _toMedRow(m));
      } catch (_) {/* offline - syncs up on next init */}
    }
  }

  Future<void> updateMed(Medication m) async {
    final i = _meds.indexWhere((x) => x.id == m.id);
    if (i < 0) return;
    _meds[i] = m;
    notifyListeners();
    await _persistMeds();
    try {
      // scheduleMedicationAlarms cancels then reschedules from scratch.
      await NotificationService.instance.scheduleMedicationAlarms(m);
    } catch (_) {}
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.upsert('medications', _toMedRow(m), onConflict: 'id');
      } catch (_) {}
    }
  }

  Future<void> deleteMed(String id) async {
    _meds.removeWhere((m) => m.id == id);
    _logs.removeWhere((l) => l.medicationId == id);
    notifyListeners();
    await _persistMeds();
    await _persistLogs();
    try {
      await NotificationService.instance.cancelMedicationAlarms(id);
    } catch (_) {}
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.delete('medications', id);
        await SupabaseRepo.deleteBy('medication_logs', 'medication_id', id);
      } catch (_) {}
    }
  }

  /// Toggle today's "taken" state for a medication (log or un-log).
  Future<void> toggleToday(String medId) async {
    final key = dateKey(DateTime.now());
    if (isTakenOn(medId, key)) {
      final removed =
          _logs.where((l) => l.medicationId == medId && l.dateKey == key).toList();
      _logs.removeWhere((l) => l.medicationId == medId && l.dateKey == key);
      notifyListeners();
      await _persistLogs();
      if (SupabaseRepo.isLoggedIn) {
        try {
          for (final l in removed) {
            await SupabaseRepo.delete('medication_logs', l.id);
          }
        } catch (_) {}
      }
    } else {
      final log = MedicationLog(
        id: 'ml_${DateTime.now().microsecondsSinceEpoch}',
        medicationId: medId,
        dateKey: key,
        takenAtIso: DateTime.now().toIso8601String(),
      );
      _logs.add(log);
      notifyListeners();
      await _persistLogs();
      if (SupabaseRepo.isLoggedIn) {
        try {
          await SupabaseRepo.insert('medication_logs', _toLogRow(log));
        } catch (_) {}
      }
    }
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
