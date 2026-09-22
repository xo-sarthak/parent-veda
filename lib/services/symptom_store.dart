// =============================================================================
//  SymptomStore - optional symptom logs for "Symptoms Companion"
// -----------------------------------------------------------------------------
//  Logging is optional and never the point of the feature. When the mother
//  chooses, a log can also create a Journal entry (type symptom) - which then
//  also surfaces in My Calendar. Provides a gentle "you've noted this N times
//  this week" insight (supportive, never diagnostic).
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';
import '../models/symptom.dart';
import 'journal_store.dart';
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';

class SymptomStore extends ChangeNotifier {
  SymptomStore._();
  static final SymptomStore instance = SymptomStore._();

  static const _key = 'symptom_logs';
  final List<SymptomLog> _logs = [];
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    // 1) Local cache first - instant, works offline.
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _logs.add(SymptomLog.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();

    // 2) Then sync with the cloud (no-op if logged out).
    await _syncFromCloud();
  }

  // Pull the user's rows from Supabase and merge with what we have locally:
  // cloud wins, but local-only rows (e.g. logged offline) are kept AND pushed
  // up. Best-effort - on any error we just keep the local cache.
  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      final rows =
          await SupabaseRepo.fetch('symptom_logs', orderBy: 'created_at_iso');
      final byId = {for (final r in rows) r['id'].toString(): _fromRow(r)};
      for (final l in _logs) {
        if (!byId.containsKey(l.id)) {
          byId[l.id] = l; // keep local-only entry...
          await SupabaseRepo.insert('symptom_logs', _toRow(l)); // ...and push it up
        }
      }
      _logs
        ..clear()
        ..addAll(byId.values);
      await _persist();
      notifyListeners();
    } catch (_) {/* offline / transient - keep local */}
  }

  // camelCase model  <->  snake_case table columns
  Map<String, dynamic> _toRow(SymptomLog l) => {
        'id': l.id,
        'symptom_id': l.symptomId,
        'date_key': l.dateKey,
        'severity': l.severity,
        'notes': l.notes,
        'created_at_iso': l.createdAtIso,
      };

  SymptomLog _fromRow(Map<String, dynamic> r) => SymptomLog(
        id: (r['id'] ?? '').toString(),
        symptomId: (r['symptom_id'] ?? '').toString(),
        dateKey: (r['date_key'] ?? '').toString(),
        severity: (r['severity'] ?? 'mild').toString(),
        notes: (r['notes'] ?? '').toString(),
        createdAtIso: (r['created_at_iso'] ?? '').toString(),
      );

  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  List<SymptomLog> get logs => List.unmodifiable(_logs);

  /// How many times this symptom was logged in the last 7 days.
  int countThisWeek(String symptomId) {
    final now = DateTime.now();
    var n = 0;
    for (final l in _logs) {
      if (l.symptomId != symptomId) continue;
      final d = DateTime.tryParse(l.createdAtIso) ?? now;
      if (now.difference(d).inDays < 7) n++;
    }
    return n;
  }

  // ---------------------------------------------------------------------------
  //  The day-level verbs the Symptoms door's check-in uses — 2026-09-22
  // ---------------------------------------------------------------------------
  //  The store always keyed a log by its `dateKey`; the old companion only
  //  ever wrote today's. The check-in reads and writes ANY day the strip
  //  selects, so the verbs take a date. A day carries at most one log per
  //  symptom (tapping again changes the severity; tapping off removes it) —
  //  the grid is a set of (day, symptom) cells, not a diary of taps.

  /// The logs on [date], one per symptom.
  List<SymptomLog> logsOn(DateTime date) {
    final k = dateKey(date);
    return [for (final l in _logs) if (l.dateKey == k) l];
  }

  bool isLogged(DateTime date, String symptomId) =>
      logsOn(date).any((l) => l.symptomId == symptomId);

  /// 'mild' · 'moderate' · 'strong', or null when not logged that day.
  String? severityOn(DateTime date, String symptomId) =>
      logsOn(date).where((l) => l.symptomId == symptomId).firstOrNull?.severity;

  /// Log [symptomId] on [date] at [severity], replacing that day's entry
  /// for the same symptom. `notes` is kept if one was already written.
  Future<void> setOn(DateTime date, String symptomId, String severity) async {
    final existing = logsOn(date).where((l) => l.symptomId == symptomId).firstOrNull;
    if (existing != null) {
      if (existing.severity == severity) return;
      final updated = SymptomLog(
        id: existing.id,
        symptomId: existing.symptomId,
        dateKey: existing.dateKey,
        severity: severity,
        notes: existing.notes,
        createdAtIso: existing.createdAtIso,
      );
      _logs[_logs.indexOf(existing)] = updated;
      notifyListeners();
      await _persist();
      if (SupabaseRepo.isLoggedIn) {
        try {
          await SupabaseRepo.update('symptom_logs', updated.id, {'severity': severity});
        } catch (_) {/* offline - the next init merges */}
      }
      return;
    }
    await log(symptomId: symptomId, severity: severity, addToJournal: false, week: 0, journalTitle: '', on: date);
  }

  /// Remove [symptomId] from [date].
  Future<void> unlogOn(DateTime date, String symptomId) async {
    final existing = logsOn(date).where((l) => l.symptomId == symptomId).toList();
    if (existing.isEmpty) return;
    _logs.removeWhere(existing.contains);
    notifyListeners();
    await _persist();
    if (SupabaseRepo.isLoggedIn) {
      for (final l in existing) {
        try {
          await SupabaseRepo.delete('symptom_logs', l.id);
        } catch (_) {/* offline */}
      }
    }
  }

  /// The seven days ending on [end] (inclusive), oldest first.
  static List<DateTime> weekEnding(DateTime end) {
    final e = DateTime(end.year, end.month, end.day);
    return [for (var i = 6; i >= 0; i--) e.subtract(Duration(days: i))];
  }

  /// Every symptom logged in the week ending [end], with its count of days —
  /// most days first. The "Your week" grid's rows and the pattern line.
  List<({String symptomId, int days})> weekCounts(DateTime end) {
    final days = weekEnding(end);
    final counts = <String, int>{};
    for (final d in days) {
      for (final l in logsOn(d)) {
        counts[l.symptomId] = (counts[l.symptomId] ?? 0) + 1;
      }
    }
    final out = [for (final e in counts.entries) (symptomId: e.key, days: e.value)];
    out.sort((a, b) => b.days.compareTo(a.days));
    return out;
  }

  /// Days in the week ending [end] with anything logged.
  int daysLoggedInWeek(DateTime end) => weekEnding(end).where((d) => logsOn(d).isNotEmpty).length;

  Future<void> log({
    required String symptomId,
    required String severity,
    String notes = '',
    required bool addToJournal,
    required int week,
    required String journalTitle,
    DateTime? on,
  }) async {
    final now = DateTime.now();
    final id = 'sl_${now.microsecondsSinceEpoch}';
    final entry = SymptomLog(
      id: id,
      symptomId: symptomId,
      dateKey: dateKey(on ?? now),
      severity: severity,
      notes: notes,
      createdAtIso: now.toIso8601String(),
    );
    _logs.add(entry);
    notifyListeners();
    await _persist();

    // Push to the cloud (best-effort; it's already saved in the local cache).
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.insert('symptom_logs', _toRow(entry));
      } catch (_) {/* offline - will sync up on next init */}
    }

    if (addToJournal) {
      await JournalStore.instance.addEntry(JournalEntry(
        id: 'sym_$id',
        type: JournalEntryType.symptom,
        title: journalTitle,
        description: notes,
        date: now,
        weekNumber: week,
      ));
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(_logs.map((e) => e.toJson()).toList()));
    } catch (_) {/* best-effort */}
  }
}
