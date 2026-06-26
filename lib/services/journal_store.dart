// =============================================================================
//  JournalStore — persistence + timeline assembly for "My Journal"
// -----------------------------------------------------------------------------
//  Manual entries (memory / note-for-baby / photo / voice) are persisted in
//  shared_preferences; photo files live in the app documents dir. The full
//  timeline merges those manual entries with AUTO entries derived from the
//  mother's existing data — pregnancy milestones, weight logs, kick sessions —
//  so the journal feels alive without her logging anything twice.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/journey_milestones.dart';
import '../localization/app_language.dart';
import '../models/journal_entry.dart';
import '../models/journey_node.dart';
import 'pregnancy_controller.dart';
import 'tools_store.dart';

class JournalStore extends ChangeNotifier {
  JournalStore._();
  static final JournalStore instance = JournalStore._();

  static const _key = 'journal_entries';

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

  List<JournalEntry> get manualEntries => List.unmodifiable(_manual);

  bool get hasManualEntries => _manual.isNotEmpty;

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

  /// Replace a manual entry (same id) with an edited copy.
  Future<void> updateEntry(JournalEntry e) async {
    final i = _manual.indexWhere((x) => x.id == e.id);
    if (i < 0) return;
    _manual[i] = e;
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

  /// Copy a picked image into the app documents dir; returns the stored path
  /// (falls back to the source path if copying fails).
  static Future<String> saveImage(String sourcePath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final jdir = Directory('${dir.path}/journal');
      if (!jdir.existsSync()) jdir.createSync(recursive: true);
      final ext = sourcePath.contains('.') ? sourcePath.split('.').last : 'jpg';
      final dest =
          '${jdir.path}/jr_${DateTime.now().microsecondsSinceEpoch}.$ext';
      await File(sourcePath).copy(dest);
      return dest;
    } catch (_) {
      return sourcePath;
    }
  }

  /// Copy a recorded audio clip into the app documents dir; returns the stored
  /// path (falls back to the source path if copying fails).
  static Future<String> saveAudio(String sourcePath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final jdir = Directory('${dir.path}/journal');
      if (!jdir.existsSync()) jdir.createSync(recursive: true);
      final ext = sourcePath.contains('.') ? sourcePath.split('.').last : 'm4a';
      final dest =
          '${jdir.path}/jr_${DateTime.now().microsecondsSinceEpoch}.$ext';
      await File(sourcePath).copy(dest);
      return dest;
    } catch (_) {
      return sourcePath;
    }
  }

  // ---- Timeline (manual + auto), newest first --------------------------------

  List<JournalEntry> timeline(PregnancyController p) {
    final s = S(p.language);
    final list = <JournalEntry>[..._manual];
    list.addAll(_autoMilestones(p));
    list.addAll(_autoHealth(p, s));
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  // Kept for the (commented-out) kick auto-entries above.
  // ignore: unused_element
  int _weekAt(PregnancyController p, DateTime d) {
    final days = p.dueDate.difference(DateTime(d.year, d.month, d.day)).inDays;
    final raw = 40 - (days / 7).floor();
    return raw.clamp(4, 40);
  }

  // Milestones reached so far, sourced from the shared Journey milestone library
  // (achievements + baby development + "days together" + mother experiences) so
  // the journal and the Pregnancy Map stay in sync. Medical scans and
  // feature-unlock nodes are intentionally excluded (scans fill from real logs
  // later; the spec forbids feature/product achievements in the journal).
  List<JournalEntry> _autoMilestones(PregnancyController p) {
    final lang = p.language;
    final currentDay = p.currentDay;
    final now = DateTime.now();
    const included = {
      JourneyNodeType.achievement,
      JourneyNodeType.babyDev,
      JourneyNodeType.pvJourney,
      JourneyNodeType.mother,
    };
    final out = <JournalEntry>[];
    for (final m in kJourneyMilestones) {
      if (!included.contains(m.type)) continue;
      if (m.posDay > currentDay) continue;
      var date = p.dueDate.subtract(
          Duration(days: (PregnancyController.termDays - m.posDay).round()));
      if (date.isAfter(now)) date = now;
      var desc = '';
      for (final sec in m.sections) {
        final b = sec.body.of(lang).trim();
        if (b.isNotEmpty) {
          desc = b;
          break;
        }
      }
      out.add(JournalEntry(
        id: 'jm_${m.id}',
        type: JournalEntryType.milestone,
        title: '${m.emoji}  ${m.title.of(lang)}',
        description: desc,
        date: date,
        weekNumber: m.anchorWeek,
        isAutomatic: true,
      ));
    }
    return out;
  }

  List<JournalEntry> _autoHealth(PregnancyController p, S s) {
    final out = <JournalEntry>[];
    final t = ToolsStore.instance;

    for (final w in t.weightEntries) {
      final d = DateTime.tryParse(w.timeIso) ??
          DateTime.tryParse(w.dateIso) ??
          p.dueDate;
      out.add(JournalEntry(
        id: 'wt_${w.id}',
        type: JournalEntryType.weight,
        title: s.jrWeightLogged,
        description: '${w.weight.toStringAsFixed(1)} ${s.kgUnit}',
        date: d,
        weekNumber: w.week,
        isAutomatic: true,
      ));
    }

    // Kick sessions are intentionally NOT shown in the journal — they live in
    // the Baby Movement tool. Kept commented for an easy revert.
    /*
    var first = true;
    for (final ms in t.movementSessionHistory.reversed) {
      out.add(JournalEntry(
        id: 'kick_${ms.id}',
        type: JournalEntryType.kick,
        title: first ? s.jrFirstKick : s.jrKickSession,
        description: s.jrMovementsCount(ms.times.length),
        date: ms.start,
        weekNumber: _weekAt(p, ms.start),
        isAutomatic: true,
      ));
      first = false;
    }
    */
    return out;
  }
}
