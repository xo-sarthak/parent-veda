// =============================================================================
//  ScansStore - completed scans + appointments ("Scans & Appointments")
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
import 'appointment_reminders.dart';
import 'journal_store.dart';
import 'pregnancy_records.dart';
import 'remote/own_row_ledger.dart';
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';
import 'remote/sync_row_book.dart';

class ScansStore extends ChangeNotifier implements PregnancyScopedStore {
  ScansStore._();
  static final ScansStore instance = ScansStore._();

  static const _completedKey = 'scans_completed';
  static const _apptKey = 'scans_appointments';
  static const _notesKey = 'scans_notes';

  /// Her own note on a scan, by scan id — what the doctor said, the report
  /// number, a question to carry in. Added 2026-09-18 for the timeline's
  /// "Add a note"; local-first like everything here (STILL-OPEN §63.9 owes
  /// the cloud column).
  final Map<String, String> _notes = {};

  String? noteFor(String scanId) {
    final n = _notes[scanId];
    return n == null || n.trim().isEmpty ? null : n;
  }

  Future<void> setNote(String scanId, String text) async {
    final t = text.trim();
    if (t.isEmpty) {
      if (_notes.remove(scanId) == null) return;
    } else {
      if (_notes[scanId] == t) return;
      _notes[scanId] = t;
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notesKey, jsonEncode(_notes));
    } catch (_) {}
  }

  final List<CompletedScan> _completed = [];
  final List<Appointment> _appts = [];

  // The paired partner's scan-done state + appointments (read-only): a scan
  // shows done if EITHER partner marked it, and both partners see all
  // appointments. Refreshed from the cloud on each sync.
  final List<CompletedScan> _partnerCompleted = [];
  final List<Appointment> _partnerAppts = [];

  bool _loaded = false;

  // ---- newer-wins sync (2026-10-21, sync log step 9, migration 0107) -------
  // Her rows only: the partner can READ both tables (0012) but never writes
  // them, so her phone's edit time decides (§16ii) and his copy stays the
  // separate read-only fetch below.
  final OwnRowLedger _scanSync = OwnRowLedger(
      'completed_scans', 'completed_scans_sync',
      keyColumn: 'scan_id');
  final OwnRowLedger _apptSync =
      OwnRowLedger('appointments', 'appointments_sync');

  /// Changes the cloud has not confirmed (the sign-out sheet reads this).
  bool get hasPending => _scanSync.hasPending || _apptSync.hasPending;

  Map<String, Map<String, dynamic>> _scanRows() =>
      {for (final c in _completed) c.scanId: _toScanRow(c)};
  Map<String, Map<String, dynamic>> _apptRows() =>
      {for (final a in _appts) a.id: _toApptRow(a)};

  Future<void> _pushWaiting() async {
    await _scanSync.push(_scanRows);
    await _apptSync.push(_apptRows);
  }

  /// Pure: the partner's rows minus the ones he soft-deleted. A removal is a
  /// row with `removed_at` set now, so a plain read would show it (step 9).
  static List<Map<String, dynamic>> notRemoved(
          List<Map<String, dynamic>> rows) =>
      [for (final r in rows) if (syncParseStamp(r['removed_at']) == null) r];

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
      final n = prefs.getString(_notesKey);
      if (n != null) {
        (jsonDecode(n) as Map).forEach((k, v) => _notes['$k'] = '$v');
      }
    } catch (_) {/* start empty */}
    await _scanSync.load();
    await _apptSync.load();
    SyncRegistry.registerPending(() => hasPending);
    _loaded = true;
    notifyListeners();
    // Re-arm her appointment reminders (P3 D7): derived ids, so a repeat
    // overwrites. Not awaited: launch never waits on the plugin.
    AppointmentReminders.instance.syncAll(_appts).catchError((_) {});

    // 2) Then sync with the cloud (no-op if logged out).
    await _syncFromCloud();
  }

  /// A sign-out, or another account signing in (2026-10-17): this store
  /// forgets the person in memory; the cloud keeps it.
  void _resetLocal() {
    _notes.clear();
    _completed.clear();
    _appts.clear();
    _partnerCompleted.clear();
    _partnerAppts.clear();
    _scanSync
      ..clear()
      ..save();
    _apptSync
      ..clear()
      ..save();
    notifyListeners();
  }

  /// Newer wins per row for her own scans and appointments (step 9), then the
  /// partner's, read-only, without his removed rows.
  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    SyncRegistry.registerReset(_resetLocal);
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      bool gone(Map<String, dynamic> r) =>
          syncParseStamp(r['removed_at']) != null;

      final byScan = {for (final c in _completed) c.scanId: c};
      for (final r in await _scanSync.pull(liveKeys: byScan.keys)) {
        final id = r['id'] as String; // = scan_id (keyed table)
        if (gone(r)) {
          byScan.remove(id);
        } else {
          byScan[id] = _fromScanRow(r);
        }
      }
      _completed
        ..clear()
        ..addAll(byScan.values);
      await _persistCompleted();

      final byId = {for (final a in _appts) a.id: a};
      for (final r
          in await _apptSync.pull(liveKeys: byId.keys, orderBy: 'date_iso')) {
        final id = r['id'] as String;
        if (gone(r)) {
          byId.remove(id);
        } else {
          byId[id] = _fromApptRow(r);
        }
      }
      // A row removed on her other phone takes its reminder with it (P3 D7).
      for (final a in _appts) {
        if (!byId.containsKey(a.id)) {
          AppointmentReminders.instance.cancelFor(a.id).catchError((_) {});
        }
      }
      _appts
        ..clear()
        ..addAll(byId.values);
      await _persistAppts();
      AppointmentReminders.instance.syncAll(_appts).catchError((_) {});

      _partnerCompleted.clear();
      _partnerAppts.clear();
      final partnerId = await SupabaseRepo.myPartnerId();
      if (partnerId != null) {
        final pScans =
            await SupabaseRepo.fetchByUser('completed_scans', partnerId);
        _partnerCompleted.addAll(notRemoved(pScans).map(_fromScanRow));
        final pAppts = await SupabaseRepo.fetchByUser('appointments', partnerId,
            orderBy: 'date_iso');
        _partnerAppts.addAll(notRemoved(pAppts).map(_fromApptRow));
      }

      notifyListeners();
      await _pushWaiting();
    } catch (_) {/* offline - keep local; the ledgers keep what waits */}
  }

  // ignore: unused_element
  Future<void> _syncFromCloudOld() async {
    // kept for revert (before step 9): cloud wins per id, local-only rows are
    // pushed again, so an un-marked scan or a deleted appointment came back.
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      // completed_scans - keyed by scan_id (no `id` column)
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

      // appointments - keyed by id
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
      // (read-only - RLS allows reading the partner's rows).
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
    } catch (_) {/* offline - keep local */}
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
  // ⚠️ THIS PREGNANCY'S (R1, 2026-10-25). A scan is keyed by its catalogue id,
  // so the dating scan done in a lost pregnancy read as done in the next. Her
  // own marks move into the old pregnancy's archive when the next begins
  // ([takeCompletedForNewPregnancy]); the partner's are read by date.
  // Kept for revert:
  //   bool isCompleted(String scanId) =>
  //       _completed.any((c) => c.scanId == scanId) ||
  //       _partnerCompleted.any((c) => c.scanId == scanId);
  static bool _now(CompletedScan c) => PregnancyRecords.instance
      .inCurrent(DateTime.tryParse(c.dateIso) ?? DateTime.now());

  /// ⚠️ ONE SCAN, ONE ID (P3 CA3, 2026-10-28). The Calendar's usual checks
  /// are journey milestones (`m_nt`); the Scans timeline is its own run
  /// (`nt_scan`). Both mark the same scan done in this store, so a scan done
  /// in one read as open in the other. New marks are written under the
  /// timeline's id; every read and removal matches either spelling, so a tick
  /// already stored under the old one is never lost, here or in the cloud.
  static const Map<String, String> kScanIdTwins = {
    'm_ultrasound': 'dating_scan',
    'm_nt': 'nt_scan',
    'm_anomaly': 'anomaly_scan',
    'm_glucose': 'ogtt',
    'm_growth': 'growth_scan',
    'm_gbs': 'gbs',
  };

  /// The one id a scan is known by.
  static String scanKey(String scanId) => kScanIdTwins[scanId] ?? scanId;

  static bool _same(CompletedScan c, String scanId) =>
      scanKey(c.scanId) == scanKey(scanId);

  // Kept for revert (P3 CA3): `c.scanId == scanId` in both reads below.
  bool isCompleted(String scanId) =>
      _completed.any((c) => _same(c, scanId) && _now(c)) ||
      _partnerCompleted.any((c) => _same(c, scanId) && _now(c));

  CompletedScan? completedOf(String scanId) {
    for (final c in _completed) {
      if (_same(c, scanId) && _now(c)) return c;
    }
    for (final c in _partnerCompleted) {
      if (_same(c, scanId) && _now(c)) return c;
    }
    return null;
  }

  /// The journal entry a completed scan writes. The first pregnancy keeps
  /// `scan_<id>`; a later pregnancy's scan of the same kind gets the day it
  /// was done in its id, or it would overwrite the first one's entry (R1).
  static String scanJournalId(String scanId, DateTime doneOn) {
    final base = 'scan_$scanId';
    final recs = PregnancyRecords.instance;
    for (final e in JournalStore.instance.manualEntries) {
      if (e.id != base) continue;
      final same = recs.all.isEmpty ||
          recs.all.any((r) => recs.windowOf(r).holds(e.date) && recs.windowOf(r).holds(doneOn));
      if (same) return base;
      final d = doneOn.toIso8601String().substring(0, 10);
      return '${base}_$d';
    }
    return base;
  }

  /// Copies her completed scans and clears them: a new pregnancy starts with
  /// none done (pregnancy_archive.dart). The journal entries they wrote stay
  /// in the journal, dated in the old pregnancy.
  Future<List<Object?>> takeCompletedForNewPregnancy() async {
    final copy = [for (final c in _completed) c.toJson()];
    for (final c in _completed) {
      _scanSync.remove(c.scanId, _toScanRow(c));
    }
    _completed.clear();
    notifyListeners();
    await _persistCompleted();
    await _scanSync.push(_scanRows);
    return copy;
  }

  /// Puts them back (the undo of a new pregnancy).
  Future<void> restoreCompleted(Object? copy) async {
    if (copy is! List) return;
    for (final e in copy) {
      if (e is! Map) continue;
      final c = CompletedScan.fromJson(Map<String, dynamic>.from(e));
      _completed.removeWhere((x) => x.scanId == c.scanId);
      _completed.add(c);
      _scanSync.touch(c.scanId);
    }
    notifyListeners();
    await _persistCompleted();
    await _scanSync.push(_scanRows);
  }

  /// Her appointments in [w] (the "Kept for you" page).
  List<Appointment> appointmentsIn(PregnancyWindow w) =>
      [for (final a in _appts) if (w.holds(a.date)) a]
        ..sort((a, b) => a.date.compareTo(b.date));

  @override
  int countIn(PregnancyWindow w) => appointmentsIn(w).length;

  @override
  Future<int> removeIn(PregnancyWindow w) async {
    final ids = [for (final a in appointmentsIn(w)) a.id];
    for (final id in ids) {
      await deleteAppointment(id);
    }
    return ids.length;
  }

  List<CompletedScan> get completed => List.unmodifiable(_completed);

  Future<void> markCompleted({
    required String scanId,
    required String journalTitle,
    required int week,
  }) async {
    if (isCompleted(scanId)) return;
    // One id per scan (P3 CA3): the timeline's spelling, whichever page
    // marked it. The journal id below follows it.
    scanId = scanKey(scanId);
    final now = DateTime.now();
    final scan = CompletedScan(scanId: scanId, dateIso: now.toIso8601String());
    _completed.add(scan);
    _scanSync.touch(scanId);
    notifyListeners();
    await _persistCompleted();
    // kept for revert (before step 9): a one-shot upsert, lost if offline.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.upsert('completed_scans', _toScanRow(scan),
    //         onConflict: 'user_id,scan_id');
    //   } catch (_) {}
    // }
    await _scanSync.push(_scanRows);
    await JournalStore.instance.addEntry(JournalEntry(
      // id: 'scan_$scanId', // kept for revert
      id: scanJournalId(scanId, now),
      type: JournalEntryType.scan,
      title: journalTitle,
      date: now,
      weekNumber: week,
    ));
  }

  Future<void> unmarkCompleted(String scanId) async {
    // Which journal entry it wrote (R1): the day it was done picks the id.
    // Either spelling of the scan (P3 CA3); each row goes by its own stored
    // id, so the cloud removes the row it actually holds.
    final was = _completed.where((c) => _same(c, scanId)).firstOrNull;
    final journalId = was == null
        ? 'scan_${scanKey(scanId)}'
        : scanJournalId(was.scanId, DateTime.tryParse(was.dateIso) ?? DateTime.now());
    // A soft delete that travels (step 9).
    for (final c in _completed.where((c) => _same(c, scanId)).toList()) {
      _scanSync.remove(c.scanId, _toScanRow(c));
    }
    _completed.removeWhere((c) => _same(c, scanId));
    notifyListeners();
    await _persistCompleted();
    // kept for revert (before step 9): a one-shot hard delete.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.deleteBy('completed_scans', 'scan_id', scanId);
    //   } catch (_) {}
    // }
    await _scanSync.push(_scanRows);
    // await JournalStore.instance.deleteEntry('scan_$scanId'); // kept for revert
    await JournalStore.instance.deleteEntry(journalId);
  }

  // ---- appointments ---------------------------------------------------------

  /// Her booked appointment for a scan or check known by any of [names], or
  /// null (C1, P3's hand-over, 2026-10-30). ONE RULE for the Calendar and the
  /// Scans timeline, which matched two ways: the Calendar by exact title,
  /// skipping completed visits; the timeline by substring, not skipping them,
  /// so a finished visit still read as booked. The appointment model has no
  /// link to a check, so a name is all there is: a name matches when its
  /// words appear in the title as whole words, in order ("NT scan" matches
  /// "My NT scan at Apollo", and "NT" never matches inside "appointment"). A
  /// renamed visit simply reads as open again, never wrong.
  Appointment? bookedFor(Iterable<String> names) {
    List<String> words(String t) =>
        t.toLowerCase().split(RegExp(r'[^a-z0-9]+')).where((w) => w.isNotEmpty).toList();
    bool contains(List<String> hay, List<String> needle) {
      if (needle.isEmpty || needle.length > hay.length) return false;
      for (var i = 0; i + needle.length <= hay.length; i++) {
        var ok = true;
        for (var j = 0; j < needle.length && ok; j++) {
          ok = hay[i + j] == needle[j];
        }
        if (ok) return true;
      }
      return false;
    }

    final keys = [for (final n in names) words(n)];
    for (final a in appointments) {
      if (a.status == 'completed') continue;
      final t = words(a.title);
      if (keys.any((k) => contains(t, k))) return a;
    }
    return null;
  }

  List<Appointment> get appointments {
    // Union of own + the partner's appointments (keyed by id), soonest first.
    // This pregnancy's only (R1, 2026-10-25). Kept for revert:
    //   final byId = {for (final a in _appts) a.id: a};
    //   for (final a in _partnerAppts) {
    //     byId.putIfAbsent(a.id, () => a);
    //   }
    bool now(Appointment a) => PregnancyRecords.instance.inCurrent(a.date);
    final byId = {for (final a in _appts) if (now(a)) a.id: a};
    for (final a in _partnerAppts) {
      if (now(a)) byId.putIfAbsent(a.id, () => a);
    }
    final list = byId.values.toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  Future<void> addAppointment(Appointment a) async {
    _appts.add(a);
    _apptSync.touch(a.id);
    notifyListeners();
    AppointmentReminders.instance.kick(a);
    await _persistAppts();
    // kept for revert (before step 9):
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.insert('appointments', _toApptRow(a));
    //   } catch (_) {}
    // }
    await _apptSync.push(_apptRows);
  }

  /// Replace one of HER appointments, kept by id (the calendar's Edit,
  /// 2026-10-17). A partner's appointment is not hers to change, so an id she
  /// does not own is a no-op. Same id, so the local row and its cloud copy stay
  /// one identity: the cloud write is an update of that row, not a new one.
  Future<void> updateAppointment(Appointment a) async {
    final i = _appts.indexWhere((x) => x.id == a.id);
    if (i < 0) return;
    _appts[i] = a;
    _apptSync.touch(a.id);
    notifyListeners();
    AppointmentReminders.instance.kick(a);
    await _persistAppts();
    // kept for revert (before step 9):
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.update('appointments', a.id, _toApptRow(a));
    //   } catch (_) {}
    // }
    await _apptSync.push(_apptRows);
  }

  /// Whether [id] is one of her own appointments (editable), not the partner's.
  bool ownsAppointment(String id) => _appts.any((a) => a.id == id);

  Future<void> deleteAppointment(String id) async {
    // A soft delete that travels (step 9). A partner's id is not in _appts,
    // so it is left alone, as before.
    for (final a in _appts.where((a) => a.id == id)) {
      _apptSync.remove(id, _toApptRow(a));
    }
    if (_appts.any((a) => a.id == id)) {
      AppointmentReminders.instance.cancelFor(id).catchError((_) {});
    }
    _appts.removeWhere((a) => a.id == id);
    notifyListeners();
    await _persistAppts();
    // kept for revert (before step 9): a one-shot hard delete.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.delete('appointments', id);
    //   } catch (_) {}
    // }
    await _apptSync.push(_apptRows);
  }

  /// Testing: clear all completed scans + appointments (empties the map's scan
  /// state) and remove their linked Journal scan entries.
  Future<void> clearAllForTesting() async {
    final ids = _completed.map((c) => c.scanId).toList();
    // Soft deletes through the ledgers (step 9), so the other phone clears too.
    for (final c in _completed) {
      _scanSync.remove(c.scanId, _toScanRow(c));
    }
    for (final a in _appts) {
      _apptSync.remove(a.id, _toApptRow(a));
    }
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
    // kept for revert (before step 9): hard clears.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.clear('completed_scans');
    //     await SupabaseRepo.clear('appointments');
    //   } catch (_) {}
    // }
    await _pushWaiting();
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
