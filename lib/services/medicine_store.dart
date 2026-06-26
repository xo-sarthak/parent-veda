// =============================================================================
//  MedicineStore — persistence for Daily Medication & Supplement Tracking
// -----------------------------------------------------------------------------
//  Stores the mother's medications/supplements and a log of which were taken on
//  which day (once-per-day model for v1). Exposes gentle, judgment-free stats:
//  today's progress, weekly per-item counts, and 30-day consistency. No streaks.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/medication.dart';

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
  }

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
  }

  Future<void> updateMed(Medication m) async {
    final i = _meds.indexWhere((x) => x.id == m.id);
    if (i < 0) return;
    _meds[i] = m;
    notifyListeners();
    await _persistMeds();
  }

  Future<void> deleteMed(String id) async {
    _meds.removeWhere((m) => m.id == id);
    _logs.removeWhere((l) => l.medicationId == id);
    notifyListeners();
    await _persistMeds();
    await _persistLogs();
  }

  /// Toggle today's "taken" state for a medication (log or un-log).
  Future<void> toggleToday(String medId) async {
    final key = dateKey(DateTime.now());
    if (isTakenOn(medId, key)) {
      _logs.removeWhere(
          (l) => l.medicationId == medId && l.dateKey == key);
    } else {
      _logs.add(MedicationLog(
        id: 'ml_${DateTime.now().microsecondsSinceEpoch}',
        medicationId: medId,
        dateKey: key,
        takenAtIso: DateTime.now().toIso8601String(),
      ));
    }
    notifyListeners();
    await _persistLogs();
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
