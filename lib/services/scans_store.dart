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
import 'remote/supabase_repo.dart';

class ScansStore extends ChangeNotifier {
  ScansStore._();
  static final ScansStore instance = ScansStore._();

  static const _completedKey = 'scans_completed';
  static const _apptKey = 'scans_appointments';

  final List<CompletedScan> _completed = [];
  final List<Appointment> _appts = [];

  // The paired partner's scan-done state + appointments (read-only): a scan
  // shows done if EITHER partner marked it, and both partners see all
  // appointments. Refreshed from the cloud on each sync.
  final List<CompletedScan> _partnerCompleted = [];
  final List<Appointment> _partnerAppts = [];

  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    // 1) Local cache first.
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

    // 2) Then sync with the cloud (no-op if logged out).
    await _syncFromCloud();
  }

  Future<void> _syncFromCloud() async {
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      // completed_scans — keyed by scan_id (no `id` column)
      final scanRows = await SupabaseRepo.fetch('completed_scans');
      final byScan = {
        for (final r in scanRows) r['scan_id'].toString(): _fromScanRow(r)
      };
      for (final c in _completed) {
        if (!byScan.containsKey(c.scanId)) {
          byScan[c.scanId] = c;
          await SupabaseRepo.upsert('completed_scans', _toScanRow(c),
              onConflict: 'user_id,scan_id');
        }
      }
      _completed
        ..clear()
        ..addAll(byScan.values);
      await _persistCompleted();

      // appointments — keyed by id
      final apptRows =
          await SupabaseRepo.fetch('appointments', orderBy: 'date_iso');
      final byId = {for (final r in apptRows) r['id'].toString(): _fromApptRow(r)};
      for (final a in _appts) {
        if (!byId.containsKey(a.id)) {
          byId[a.id] = a;
          await SupabaseRepo.insert('appointments', _toApptRow(a));
        }
      }
      _appts
        ..clear()
        ..addAll(byId.values);
      await _persistAppts();

      // Partner share: also pull the paired partner's done-scans + appointments
      // (read-only — RLS allows reading the partner's rows).
      _partnerCompleted.clear();
      _partnerAppts.clear();
      final partnerId = await SupabaseRepo.myPartnerId();
      if (partnerId != null) {
        final pScans =
            await SupabaseRepo.fetchByUser('completed_scans', partnerId);
        _partnerCompleted.addAll(pScans.map(_fromScanRow));
        final pAppts = await SupabaseRepo.fetchByUser('appointments', partnerId,
            orderBy: 'date_iso');
        _partnerAppts.addAll(pAppts.map(_fromApptRow));
      }

      notifyListeners();
    } catch (_) {/* offline — keep local */}
  }

  // ---- camelCase model <-> snake_case columns -------------------------------
  Map<String, dynamic> _toScanRow(CompletedScan c) => {
        'scan_id': c.scanId,
        'date_iso': c.dateIso.isEmpty ? null : c.dateIso,
        'notes': c.notes,
      };

  CompletedScan _fromScanRow(Map<String, dynamic> r) => CompletedScan(
        scanId: (r['scan_id'] ?? '').toString(),
        dateIso: (r['date_iso'] ?? '').toString(),
        notes: (r['notes'] ?? '').toString(),
      );

  Map<String, dynamic> _toApptRow(Appointment a) => {
        'id': a.id,
        'title': a.title,
        'date_iso': a.dateIso.isEmpty ? null : a.dateIso,
        'time': a.time,
        'location': a.location,
        'doctor': a.doctor,
        'type': a.type.name,
        'notes': a.notes,
        'status': a.status,
      };

  Appointment _fromApptRow(Map<String, dynamic> r) {
    var t = ApptType.doctor;
    for (final e in ApptType.values) {
      if (e.name == r['type']) {
        t = e;
        break;
      }
    }
    return Appointment(
      id: (r['id'] ?? '').toString(),
      title: (r['title'] ?? '').toString(),
      dateIso: (r['date_iso'] ?? '').toString(),
      time: (r['time'] ?? '').toString(),
      location: (r['location'] ?? '').toString(),
      doctor: (r['doctor'] ?? '').toString(),
      type: t,
      notes: (r['notes'] ?? '').toString(),
      status: (r['status'] ?? 'upcoming').toString(),
    );
  }

  // ---- completed scans ------------------------------------------------------
  // Done if EITHER partner marked it (own rows OR the partner's, read-only).
  bool isCompleted(String scanId) =>
      _completed.any((c) => c.scanId == scanId) ||
      _partnerCompleted.any((c) => c.scanId == scanId);

  CompletedScan? completedOf(String scanId) {
    for (final c in _completed) {
      if (c.scanId == scanId) return c;
    }
    for (final c in _partnerCompleted) {
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
    final scan = CompletedScan(scanId: scanId, dateIso: now.toIso8601String());
    _completed.add(scan);
    notifyListeners();
    await _persistCompleted();
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.upsert('completed_scans', _toScanRow(scan),
            onConflict: 'user_id,scan_id');
      } catch (_) {}
    }
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
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.deleteBy('completed_scans', 'scan_id', scanId);
      } catch (_) {}
    }
    await JournalStore.instance.deleteEntry('scan_$scanId');
  }

  // ---- appointments ---------------------------------------------------------
  List<Appointment> get appointments {
    // Union of own + the partner's appointments (keyed by id), soonest first.
    final byId = {for (final a in _appts) a.id: a};
    for (final a in _partnerAppts) {
      byId.putIfAbsent(a.id, () => a);
    }
    final list = byId.values.toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  Future<void> addAppointment(Appointment a) async {
    _appts.add(a);
    notifyListeners();
    await _persistAppts();
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.insert('appointments', _toApptRow(a));
      } catch (_) {}
    }
  }

  Future<void> deleteAppointment(String id) async {
    _appts.removeWhere((a) => a.id == id);
    notifyListeners();
    await _persistAppts();
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.delete('appointments', id);
      } catch (_) {}
    }
  }

  /// Testing: clear all completed scans + appointments (empties the map's scan
  /// state) and remove their linked Journal scan entries.
  Future<void> clearAllForTesting() async {
    final ids = _completed.map((c) => c.scanId).toList();
    _completed.clear();
    _appts.clear();
    _partnerCompleted.clear();
    _partnerAppts.clear();
    notifyListeners();
    await _persistCompleted();
    await _persistAppts();
    for (final id in ids) {
      await JournalStore.instance.deleteEntry('scan_$id');
    }
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.clear('completed_scans');
        await SupabaseRepo.clear('appointments');
      } catch (_) {}
    }
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
