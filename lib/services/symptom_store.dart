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

  Future<void> log({
    required String symptomId,
    required String severity,
    String notes = '',
    required bool addToJournal,
    required int week,
    required String journalTitle,
  }) async {
    final now = DateTime.now();
    final id = 'sl_${now.microsecondsSinceEpoch}';
    final entry = SymptomLog(
      id: id,
      symptomId: symptomId,
      dateKey: dateKey(now),
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
