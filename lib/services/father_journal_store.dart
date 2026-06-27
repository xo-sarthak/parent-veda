// =============================================================================
//  FatherJournalStore — the father's own simple journal (manual entries only)
// -----------------------------------------------------------------------------
//  A deliberately small, SEPARATE store from the mother's JournalStore: it holds
//  only the father's manual entries (a memory, a note for baby, a photo, a voice
//  note) under its own prefs key — no auto milestones / health / scans. Photos +
//  voice clips reuse JournalStore's static saveImage / saveAudio helpers and the
//  shared JournalEntry model. (Mother + father journals stay separate for now;
//  merging into one shared source can come later.)
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';

class FatherJournalStore extends ChangeNotifier {
  FatherJournalStore._();
  static final FatherJournalStore instance = FatherJournalStore._();

  static const _key = 'father_journal_entries';

  final List<JournalEntry> _manual = [];
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _manual.add(JournalEntry.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
  }

  bool get hasEntries => _manual.isNotEmpty;

  /// All entries, newest first.
  List<JournalEntry> get entries {
    final list = [..._manual];
    list.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(list);
  }

  Future<void> addEntry(JournalEntry e) async {
    _manual.add(e);
    notifyListeners();
    await _persist();
  }

  Future<void> deleteEntry(String id) async {
    for (final x in _manual.where((x) => x.id == id)) {
      for (final p in [...x.images, ...x.audios]) {
        if (p.isEmpty) continue;
        try {
          final f = File(p);
          if (f.existsSync()) f.deleteSync();
        } catch (_) {}
      }
    }
    _manual.removeWhere((x) => x.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(_manual.map((e) => e.toJson()).toList()));
    } catch (_) {/* best-effort */}
  }
}
