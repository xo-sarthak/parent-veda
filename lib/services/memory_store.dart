// =============================================================================
//  MemoryStore
// -----------------------------------------------------------------------------
//  Local-only persistence for journal entries and photo memories
//  (shared_preferences for metadata, app documents dir for image files).
//  ChangeNotifier so the Reflect & Remember card and the week-40 collage update
//  live as entries are added.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/memory_models.dart';

class MemoryStore extends ChangeNotifier {
  MemoryStore._();
  static final MemoryStore instance = MemoryStore._();

  static const _journalKey = 'journal_entries';
  static const _photoKey = 'photo_memories';

  final List<JournalEntry> _journal = [];
  final List<PhotoMemory> _photos = [];
  bool _loaded = false;

  /// Journal entries, newest first.
  List<JournalEntry> get journal {
    final list = [..._journal];
    list.sort((a, b) => b.id.compareTo(a.id));
    return list;
  }

  /// Photo memories, newest first.
  List<PhotoMemory> get photos {
    final list = [..._photos];
    list.sort((a, b) => b.id.compareTo(a.id));
    return list;
  }

  bool get hasMemories => _journal.isNotEmpty || _photos.isNotEmpty;

  /// The single journal entry for [week], or null if none exists. Each week now
  /// holds at most one entry (see the migration in [init]).
  JournalEntry? journalForWeek(int week) {
    for (final e in _journal) {
      if (e.week == week) return e;
    }
    return null;
  }

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final j = prefs.getString(_journalKey);
      if (j != null) {
        for (final e in (jsonDecode(j) as List)) {
          _journal.add(JournalEntry.fromJson(Map<String, dynamic>.from(e)));
        }
      }
      final p = prefs.getString(_photoKey);
      if (p != null) {
        for (final e in (jsonDecode(p) as List)) {
          final pm = PhotoMemory.fromJson(Map<String, dynamic>.from(e));
          if (File(pm.path).existsSync()) _photos.add(pm); // skip missing files
        }
      }
      await _migrateToOnePerWeek();
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
  }

  /// Upgrade-safe migration: older builds allowed several notes per week. We now
  /// keep exactly one entry per week. Collapse any duplicates into a single
  /// entry — newest text first (blank texts dropped), keeping up to two photos —
  /// so nothing the mother wrote or photographed is lost.
  Future<void> _migrateToOnePerWeek() async {
    final byWeek = <int, List<JournalEntry>>{};
    for (final e in _journal) {
      byWeek.putIfAbsent(e.week, () => []).add(e);
    }
    final needsMigration = byWeek.values.any((list) => list.length > 1);
    if (!needsMigration) return;

    final merged = <JournalEntry>[];
    for (final entry in byWeek.entries) {
      final list = [...entry.value]..sort((a, b) => b.id.compareTo(a.id));
      if (list.length == 1) {
        merged.add(list.first);
        continue;
      }
      final newest = list.first;
      final texts = list
          .map((e) => e.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      final photos = <String>[];
      for (final e in list) {
        for (final pth in e.photoPaths) {
          if (!photos.contains(pth)) photos.add(pth);
        }
      }
      // Photos beyond the new max of two are removed from disk so we don't leak.
      final keptPhotos = photos.take(2).toList();
      await _deleteFiles(photos.skip(2).toList());
      merged.add(JournalEntry(
        id: newest.id,
        week: entry.key,
        dateIso: newest.dateIso,
        source: newest.source,
        prompt: newest.prompt,
        text: texts.join('\n\n'),
        photoPaths: keptPhotos,
      ));
    }
    _journal
      ..clear()
      ..addAll(merged);
    await _persistJournal();
  }

  String _todayIso() {
    final d = DateTime.now();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // ---- Journal --------------------------------------------------------------

  /// Creates the entry for [week], or updates it if one already exists — each
  /// week holds at most one entry, with up to two photos.
  Future<JournalEntry> addJournal({
    required int week,
    required String source,
    required String prompt,
    required String text,
    List<String> photoPaths = const [],
  }) async {
    final capped = photoPaths.take(2).toList();
    final existing = journalForWeek(week);
    if (existing != null) {
      final removed =
          existing.photoPaths.where((p) => !capped.contains(p)).toList();
      existing.text = text;
      existing.photoPaths = capped;
      await _deleteFiles(removed);
      await _persistJournal();
      notifyListeners();
      return existing;
    }
    final entry = JournalEntry(
      id: _newId(),
      week: week,
      dateIso: _todayIso(),
      source: source,
      prompt: prompt,
      text: text,
      photoPaths: capped,
    );
    _journal.add(entry);
    await _persistJournal();
    notifyListeners();
    return entry;
  }

  Future<void> updateJournal(String id, String text,
      {List<String>? photoPaths}) async {
    final e = _journal.firstWhere((x) => x.id == id, orElse: () => _journal.first);
    e.text = text;
    if (photoPaths != null) {
      final capped = photoPaths.take(2).toList();
      // Any photos dropped from the entry are removed from disk too.
      final removed = e.photoPaths.where((p) => !capped.contains(p)).toList();
      e.photoPaths = capped;
      await _deleteFiles(removed);
    }
    await _persistJournal();
    notifyListeners();
  }

  Future<void> deleteJournal(String id) async {
    final idx = _journal.indexWhere((x) => x.id == id);
    if (idx < 0) return;
    final e = _journal.removeAt(idx);
    await _deleteFiles(e.photoPaths);
    await _persistJournal();
    notifyListeners();
  }

  Future<void> _deleteFiles(List<String> paths) async {
    for (final p in paths) {
      try {
        final f = File(p);
        if (f.existsSync()) await f.delete();
      } catch (_) {}
    }
  }

  Future<void> _persistJournal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _journalKey, jsonEncode(_journal.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  // ---- Photos ---------------------------------------------------------------

  /// Captures a photo from the camera and stores it. Returns null if cancelled.
  Future<PhotoMemory?> capturePhoto({required int week}) async {
    try {
      final picker = ImagePicker();
      final XFile? shot = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 88,
      );
      if (shot == null) return null;
      final dir = await getApplicationDocumentsDirectory();
      final id = _newId();
      final dest = File('${dir.path}/memory_$id.jpg');
      await dest.writeAsBytes(await shot.readAsBytes());
      final pm = PhotoMemory(
          id: id, week: week, dateIso: _todayIso(), path: dest.path);
      _photos.add(pm);
      await _persistPhotos();
      notifyListeners();
      return pm;
    } catch (_) {
      return null;
    }
  }

  /// Captures a photo and saves it to the documents dir, returning the file
  /// path (or null if cancelled). Used to attach photos to a journal note —
  /// the path is stored on the [JournalEntry], not as a standalone memory.
  Future<String?> capturePhotoFile() async {
    try {
      final picker = ImagePicker();
      final XFile? shot = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 88,
      );
      if (shot == null) return null;
      final dir = await getApplicationDocumentsDirectory();
      final dest = File('${dir.path}/note_${_newId()}.jpg');
      await dest.writeAsBytes(await shot.readAsBytes());
      return dest.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> deletePhoto(String id) async {
    final idx = _photos.indexWhere((x) => x.id == id);
    if (idx < 0) return;
    final pm = _photos.removeAt(idx);
    try {
      final f = File(pm.path);
      if (f.existsSync()) await f.delete();
    } catch (_) {}
    await _persistPhotos();
    notifyListeners();
  }

  Future<void> _persistPhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _photoKey, jsonEncode(_photos.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }
}
