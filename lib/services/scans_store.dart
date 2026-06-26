// =============================================================================
//  ScansStore — completed scans + appointments ("Scans & Appointments")
// -----------------------------------------------------------------------------
//  Scan roadmap content is reused from kJourneyMilestones; this store only holds
//  the mother's own data. Marking a scan completed creates a Journal scan entry
//  (→ Journal "Scans" lane). Appointments are read by CalendarStore (→ Calendar
//  "Appointment" lane). Both persisted in shared_preferences.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';
import '../models/scan_appointment.dart';
import 'journal_store.dart';

class ScansStore extends ChangeNotifier {
  ScansStore._();
  static final ScansStore instance = ScansStore._();

  static const _completedKey = 'scans_completed';
  static const _apptKey = 'scans_appointments';

  final List<CompletedScan> _completed = [];
  final List<Appointment> _appts = [];
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final c = prefs.getString(_completedKey);
      if (c != null) {
        for (final e in (jsonDecode(c) as List)) {
          _completed.add(CompletedScan.fromJson(Map<String, dynamic>.from(e)));
        }
      }
      final a = prefs.getString(_apptKey);
      if (a != null) {
        for (final e in (jsonDecode(a) as List)) {
          _appts.add(Appointment.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
  }

  // ---- completed scans ------------------------------------------------------
  bool isCompleted(String scanId) =>
      _completed.any((c) => c.scanId == scanId);

  CompletedScan? completedOf(String scanId) {
    for (final c in _completed) {
      if (c.scanId == scanId) return c;
    }
    return null;
  }

  List<CompletedScan> get completed => List.unmodifiable(_completed);

  Future<void> markCompleted({
    required String scanId,
    required String journalTitle,
    required int week,
  }) async {
    if (isCompleted(scanId)) return;
    final now = DateTime.now();
    _completed.add(CompletedScan(scanId: scanId, dateIso: now.toIso8601String()));
    notifyListeners();
    await _persistCompleted();
    await JournalStore.instance.addEntry(JournalEntry(
      id: 'scan_$scanId',
      type: JournalEntryType.scan,
      title: journalTitle,
      date: now,
      weekNumber: week,
    ));
  }

  Future<void> unmarkCompleted(String scanId) async {
    _completed.removeWhere((c) => c.scanId == scanId);
    notifyListeners();
    await _persistCompleted();
    await JournalStore.instance.deleteEntry('scan_$scanId');
  }

  // ---- appointments ---------------------------------------------------------
  List<Appointment> get appointments {
    final list = [..._appts];
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  Future<void> addAppointment(Appointment a) async {
    _appts.add(a);
    notifyListeners();
    await _persistAppts();
  }

  Future<void> deleteAppointment(String id) async {
    _appts.removeWhere((a) => a.id == id);
    notifyListeners();
    await _persistAppts();
  }

  Future<void> _persistCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _completedKey, jsonEncode(_completed.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> _persistAppts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _apptKey, jsonEncode(_appts.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }
}
