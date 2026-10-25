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
import 'remote/own_row_ledger.dart';
import 'journal_key_split.dart';
import 'pregnancy_records.dart';
import 'remote/storage_service.dart';
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';
import 'remote/sync_row_book.dart';

class MemoryStore extends ChangeNotifier implements PregnancyScopedStore {
  MemoryStore._();
  static final MemoryStore instance = MemoryStore._();

  // static const _journalKey = 'journal_entries'; // kept for revert
  // ⚠️ ITS OWN KEY (R1 step 0, 2026-10-25): 'journal_entries' was the
  // pregnancy journal's key too, and each store overwrote the other's
  // entries on this phone (journal_key_split.dart).
  static const _journalKey = kWeeklyNotesKey;
  static const _photoKey = 'photo_memories';

  final List<JournalEntry> _journal = [];
  final List<PhotoMemory> _photos = [];
  bool _loaded = false;

  /// Newer-wins sync for her weekly notes (2026-10-20, sync log step 8, 0106).
  final OwnRowLedger _sync =
      OwnRowLedger('weekly_journal_notes', 'weekly_journal_notes_sync');

  /// Notes the cloud has not confirmed (the sign-out sheet reads this).
  bool get hasPending => _sync.hasPending;

  Map<String, Map<String, dynamic>> _live() =>
      {for (final e in _journal) e.id: _noteToRow(e)};

  /// A removed note's photos leave Storage only once the cloud has taken the
  /// removal, so her other phone never holds a note pointing at nothing.
  Future<void> _pushWaiting() => _sync.push(_live,
      onRemovalConfirmed: (_, cols) {
        for (final p in (cols['photos'] as List?) ?? const []) {
          StorageService.remove(p.toString());
        }
      });

  /// ⚠️ THIS PREGNANCY'S NOTES ONLY (R1, 2026-10-25). A note is keyed by its
  /// pregnancy week, and every pregnancy has a week 12: without this a
  /// second pregnancy's week 12 opened on (and then overwrote) the first's.
  /// A note belongs to the pregnancy whose window holds its date.
  List<JournalEntry> get _mine =>
      [for (final e in _journal) if (PregnancyRecords.instance.inCurrent(_dayOf(e))) e];

  static DateTime _dayOf(JournalEntry e) =>
      DateTime.tryParse(e.dateIso) ??
      DateTime.fromMicrosecondsSinceEpoch(int.tryParse(e.id) ?? 0);

  /// [w]'s notes, by week (the "Kept for you" page).
  List<JournalEntry> notesIn(PregnancyWindow w) =>
      [for (final e in _journal) if (w.holds(_dayOf(e))) e]
        ..sort((a, b) => a.week.compareTo(b.week));

  @override
  int countIn(PregnancyWindow w) => notesIn(w).length;

  @override
  Future<int> removeIn(PregnancyWindow w) async {
    final ids = [for (final e in notesIn(w)) e.id];
    for (final id in ids) {
      await deleteJournal(id);
    }
    return ids.length;
  }

  /// Journal entries, newest first.
  List<JournalEntry> get journal {
    // final list = [..._journal]; // kept for revert
    final list = [..._mine];
    list.sort((a, b) => b.id.compareTo(a.id));
    return list;
  }

  /// Photo memories, newest first.
  List<PhotoMemory> get photos {
    final list = [..._photos];
    list.sort((a, b) => b.id.compareTo(a.id));
    return list;
  }

  bool get hasMemories => _mine.isNotEmpty || _photos.isNotEmpty;

  /// The single journal entry for [week], or null if none exists. Each week now
  /// holds at most one entry (see the migration in [init]).
  JournalEntry? journalForWeek(int week) {
    // for (final e in _journal) { // kept for revert
    for (final e in _mine) {
      if (e.week == week) return e;
    }
    return null;
  }

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await splitSharedJournalKey(prefs);
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
    await _sync.load();
    SyncRegistry.registerPending(() => hasPending);
    _loaded = true;
    notifyListeners();

    // Sync the weekly notes with the cloud (no-op if logged out). photo_memories
    // are deferred - a pure-file store (no text), so metadata-only sync isn't
    // useful until files move to Supabase Storage in Phase 3.
    await _syncFromCloud();
  }

  /// A sign-out, or another account signing in (2026-10-17): this store
  /// forgets the person in memory; the cloud keeps it.
  void _resetLocal() {
    _journal.clear();
    _photos.clear();
    _sync
      ..clear()
      ..save();
    notifyListeners();
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    SyncRegistry.registerReset(_resetLocal);
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      // Newer wins per note, removals included (step 8, 0106).
      final taken = await _sync.pull(liveKeys: _journal.map((e) => e.id));
      final byId = {for (final e in _journal) e.id: e};
      for (final r in taken) {
        final id = r['id'] as String;
        if (syncParseStamp(r['removed_at']) != null) {
          // Removed on her other phone: drop this phone's file copies too.
          final mine = byId.remove(id);
          if (mine != null) _deleteLocalFiles(mine.photoPaths);
        } else {
          byId[id] = _noteFromRow(r);
        }
      }
      _journal
        ..clear()
        ..addAll(byId.values);
      await _persistJournal();
      notifyListeners();
      await _pushWaiting();
      await _backfillMedia();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  void _deleteLocalFiles(List<String> paths) {
    for (final p in paths) {
      try {
        final f = File(p);
        if (f.existsSync()) f.deleteSync();
      } catch (_) {}
    }
  }

  // Kept for revert (step 8, 2026-10-20): the cloud won per id and any note
  // only this phone held was inserted again, so a deleted note came back.
  // ignore: unused_element
  Future<void> _syncFromCloudOld() async {
    try {
      final rows = await SupabaseRepo.fetch('weekly_journal_notes');
      final byId = {for (final r in rows) r['id'].toString(): _noteFromRow(r)};
      for (final e in _journal) {
        if (!byId.containsKey(e.id)) {
          byId[e.id] = e;
          await SupabaseRepo.insert('weekly_journal_notes', _noteToRow(e));
        }
      }
      _journal
        ..clear()
        ..addAll(byId.values);
      await _persistJournal();
      await _backfillMedia();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  // Upload any note photos still stored as local paths; rewrite to cloud paths.
  Future<void> _backfillMedia() async {
    var changed = false;
    for (final e in _journal) {
      final paths = await StorageService.backfillAll(e.photoPaths, 'memory');
      if (!listEquals(paths, e.photoPaths)) {
        e.photoPaths = paths;
        changed = true;
        // try { // kept for revert (step 8)
        //   await SupabaseRepo.upsert('weekly_journal_notes', _noteToRow(e),
        //       onConflict: 'id');
        // } catch (_) {}
        _sync.touch(e.id);
      }
    }
    if (changed) {
      await _persistJournal();
      await _pushWaiting();
    }
  }

  Map<String, dynamic> _noteToRow(JournalEntry e) => {
        'id': e.id,
        'week': e.week,
        'date_iso': e.dateIso.isEmpty ? null : e.dateIso,
        'source': e.source,
        'prompt': e.prompt,
        'text': e.text,
        'photos': e.photoPaths,
      };

  JournalEntry _noteFromRow(Map<String, dynamic> r) => JournalEntry(
        id: (r['id'] ?? '').toString(),
        week: (r['week'] as num?)?.toInt() ?? 0,
        dateIso: (r['date_iso'] ?? '').toString(),
        source: (r['source'] ?? '').toString(),
        prompt: (r['prompt'] ?? '').toString(),
        text: (r['text'] ?? '').toString(),
        photoPaths:
            (r['photos'] as List?)?.map((e) => e.toString()).toList() ?? <String>[],
      );

  /// Upgrade-safe migration: older builds allowed several notes per week. We now
  /// keep exactly one entry per week. Collapse any duplicates into a single
  /// entry - newest text first (blank texts dropped), keeping up to two photos -
  /// so nothing the mother wrote or photographed is lost.
  Future<void> _migrateToOnePerWeek() async {
    // ⚠️ ONE PER WEEK OF ONE PREGNANCY (R1, 2026-10-25). Grouping by week
    // alone fused two pregnancies' week-12 notes into one. A week's notes
    // more than 60 days apart are different pregnancies' and stay apart.
    // Kept for revert:
    //   final byWeek = <int, List<JournalEntry>>{};
    //   for (final e in _journal) {
    //     byWeek.putIfAbsent(e.week, () => []).add(e);
    //   }
    final weeks = <int, List<JournalEntry>>{};
    for (final e in _journal) {
      weeks.putIfAbsent(e.week, () => []).add(e);
    }
    final byWeek = <String, List<JournalEntry>>{};
    for (final w in weeks.entries) {
      final list = [...w.value]..sort((a, b) => _dayOf(a).compareTo(_dayOf(b)));
      var n = 0;
      DateTime? first;
      for (final e in list) {
        final d = _dayOf(e);
        if (first == null || d.difference(first).inDays > 60) {
          n++;
          first = d;
        }
        byWeek.putIfAbsent('${w.key}|$n', () => []).add(e);
      }
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
        // week: entry.key, // kept for revert
        week: newest.week,
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

  /// Creates the entry for [week], or updates it if one already exists - each
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
      _sync.touch(existing.id);
      await _persistJournal();
      notifyListeners();
      // Kept for revert (step 8): a one-shot upsert, lost offline.
      // if (SupabaseRepo.isLoggedIn) {
      //   try {
      //     await SupabaseRepo.upsert('weekly_journal_notes', _noteToRow(existing),
      //         onConflict: 'id');
      //   } catch (_) {}
      // }
      await _pushWaiting();
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
    _sync.touch(entry.id);
    await _persistJournal();
    notifyListeners();
    // if (SupabaseRepo.isLoggedIn) { // kept for revert (step 8)
    //   try {
    //     await SupabaseRepo.insert('weekly_journal_notes', _noteToRow(entry));
    //   } catch (_) {}
    // }
    await _pushWaiting();
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
    _sync.touch(e.id);
    await _persistJournal();
    notifyListeners();
    // Kept for revert (step 8): a one-shot upsert, lost offline.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.upsert('weekly_journal_notes', _noteToRow(e),
    //         onConflict: 'id');
    //   } catch (_) {}
    // }
    await _pushWaiting();
  }

  Future<void> deleteJournal(String id) async {
    final idx = _journal.indexWhere((x) => x.id == id);
    if (idx < 0) return;
    final e = _journal.removeAt(idx);
    // A soft delete (step 8, 0106): the removal travels to her other phones.
    // The files on this phone go now; the Storage copies once the cloud has
    // taken the removal ([_pushWaiting]).
    // await _deleteFiles(e.photoPaths); // kept for revert
    _deleteLocalFiles(e.photoPaths);
    _sync.remove(id, _noteToRow(e));
    await _persistJournal();
    notifyListeners();
    // Kept for revert (step 8): a one-shot hard delete, lost offline.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.delete('weekly_journal_notes', id);
    //   } catch (_) {}
    // }
    await _pushWaiting();
  }

  Future<void> _deleteFiles(List<String> paths) async {
    for (final p in paths) {
      try {
        final f = File(p);
        if (f.existsSync()) await f.delete();
      } catch (_) {}
      await StorageService.remove(p);
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
      final stored = await StorageService.upload(dest.path, 'memory');
      final pm = PhotoMemory(
          id: id, week: week, dateIso: _todayIso(), path: stored);
      _photos.add(pm);
      await _persistPhotos();
      notifyListeners();
      return pm;
    } catch (_) {
      return null;
    }
  }

  /// Captures a photo and saves it to the documents dir, returning the file
  /// path (or null if cancelled). Used to attach photos to a journal note -
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
      return StorageService.upload(dest.path, 'memory');
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
    await StorageService.remove(pm.path);
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
