// =============================================================================
//  The prefs key two stores shared (found 2026-10-25, R1 step 0)
// -----------------------------------------------------------------------------
//  MemoryStore (her weekly notes) and JournalStore (the pregnancy journal) both
//  cached their lists under 'journal_entries', each in its own shape. Each
//  store's decoder is forgiving, so each read the other's entries as its own,
//  and whichever wrote last overwrote the other's on this phone. The cloud
//  kept each in its own table (weekly_journal_notes, journal_entries), so a
//  synced entry came back on the next pull; one written offline could be lost.
//
//  The two shapes are told apart by one field: a journal entry always writes
//  'type' (JournalEntry.toJson in models/journal_entry.dart); a weekly note
//  never does (models/memory_models.dart). [splitSharedJournalKey] runs once,
//  before either store reads: weekly notes move to their own key, the journal
//  keeps the old one. Both stores call it, so the first to load does it.
// =============================================================================

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// The key both stores used. The journal keeps it.
const String kSharedJournalKey = 'journal_entries';

/// The weekly notes' own key from 2026-10-25.
const String kWeeklyNotesKey = 'weekly_notes_v1';

const String _kSplitDone = 'journal_key_split_v1';

/// Pure: splits the shared list into (journal entries, weekly notes).
({List<Object?> journal, List<Object?> notes}) splitJournalRows(Object? decoded) {
  final journal = <Object?>[];
  final notes = <Object?>[];
  if (decoded is List) {
    for (final e in decoded) {
      if (e is! Map) continue;
      (e.containsKey('type') ? journal : notes).add(e);
    }
  }
  return (journal: journal, notes: notes);
}

/// Once per phone. Safe to call from both stores at once: both compute the
/// same split from the same list.
Future<void> splitSharedJournalKey([SharedPreferences? given]) async {
  try {
    final prefs = given ?? await SharedPreferences.getInstance();
    if (prefs.getBool(_kSplitDone) == true) return;
    final raw = prefs.getString(kSharedJournalKey);
    if (raw != null) {
      final s = splitJournalRows(jsonDecode(raw));
      if (prefs.getString(kWeeklyNotesKey) == null && s.notes.isNotEmpty) {
        await prefs.setString(kWeeklyNotesKey, jsonEncode(s.notes));
      }
      await prefs.setString(kSharedJournalKey, jsonEncode(s.journal));
    }
    await prefs.setBool(_kSplitDone, true);
  } catch (_) {/* unreadable: leave it, the cloud pull refills both */}
}
