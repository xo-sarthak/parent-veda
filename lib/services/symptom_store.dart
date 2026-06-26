// =============================================================================
//  SymptomStore — optional symptom logs for "Symptoms Companion"
// -----------------------------------------------------------------------------
//  Logging is optional and never the point of the feature. When the mother
//  chooses, a log can also create a Journal entry (type symptom) — which then
//  also surfaces in My Calendar. Provides a gentle "you've noted this N times
//  this week" insight (supportive, never diagnostic).
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';
import '../models/symptom.dart';
import 'journal_store.dart';

class SymptomStore extends ChangeNotifier {
  SymptomStore._();
  static final SymptomStore instance = SymptomStore._();

  static const _key = 'symptom_logs';
  final List<SymptomLog> _logs = [];
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
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
  }

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
    _logs.add(SymptomLog(
      id: id,
      symptomId: symptomId,
      dateKey: dateKey(now),
      severity: severity,
      notes: notes,
      createdAtIso: now.toIso8601String(),
    ));
    notifyListeners();
    await _persist();

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
