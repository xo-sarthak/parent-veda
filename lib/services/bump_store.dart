// =============================================================================
//  BumpStore - persistence for "My Bump Journey"
// -----------------------------------------------------------------------------
//  Stores weekly bump photos (metadata in shared_preferences; image files in
//  the app documents dir). Each added photo ALSO creates a Journal PHOTO entry
//  (its own file copy, id "bump_<id>") so the photo flows into My Journal and
//  My Calendar automatically - and the two stay independent (deleting one never
//  breaks the other).
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bump_photo.dart';
import '../models/journal_entry.dart';
import 'journal_store.dart';
import 'remote/own_row_ledger.dart';
import 'remote/storage_service.dart';
import 'pregnancy_records.dart';
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';
import 'remote/sync_row_book.dart';

class BumpStore extends ChangeNotifier implements PregnancyScopedStore {
  BumpStore._();
  static final BumpStore instance = BumpStore._();

  static const _key = 'bump_photos';

  final List<BumpPhoto> _photos = [];
  bool _loaded = false;

  /// Newer-wins sync for her photos (2026-10-20, sync log step 8, 0106).
  final OwnRowLedger _sync = OwnRowLedger('bump_photos', 'bump_photos_sync');

  /// Photos the cloud has not confirmed (the sign-out sheet reads this).
  bool get hasPending => _sync.hasPending;

  Map<String, Map<String, dynamic>> _live() =>
      {for (final p in _photos) p.id: _toRow(p)};

  /// The Storage file goes only once the cloud has taken the removal: if the
  /// row upload failed and the file were already gone, her other phone would
  /// hold a photo row pointing at nothing. The old delete never removed it
  /// at all, so every deleted photo stayed in Storage.
  Future<void> _pushWaiting() => _sync.push(_live,
      onRemovalConfirmed: (_, cols) =>
          StorageService.remove((cols['image_url'] ?? '').toString()));

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _photos.add(BumpPhoto.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    await _sync.load();
    SyncRegistry.registerPending(() => hasPending);
    _loaded = true;
    notifyListeners();

    // Sync with the cloud (no-op if logged out). Metadata (caption/week/favorite)
    // syncs now; the image file itself moves to Supabase Storage in Phase 3.
    await _syncFromCloud();
  }

  /// A sign-out, or another account signing in (2026-10-17): this store
  /// forgets the person in memory; the cloud keeps it.
  void _resetLocal() {
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
      // Newer wins per photo, removals included (step 8, 0106).
      final taken = await _sync.pull(liveKeys: _photos.map((p) => p.id));
      final byId = {for (final p in _photos) p.id: p};
      for (final r in taken) {
        final id = r['id'] as String;
        if (syncParseStamp(r['removed_at']) != null) {
          // Removed on her other phone: drop this phone's file copy too.
          final mine = byId.remove(id);
          if (mine != null) _deleteLocalFile(mine.imageUrl);
        } else {
          byId[id] = _fromRow(r);
        }
      }
      _photos
        ..clear()
        ..addAll(byId.values);
      await _persist();
      notifyListeners();
      await _pushWaiting();
      await _backfillMedia();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  void _deleteLocalFile(String path) {
    try {
      final f = File(path);
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
  }

  // Kept for revert (step 8, 2026-10-20): the cloud won per id and any photo
  // only this phone held was inserted again, so a deleted photo came back.
  // ignore: unused_element
  Future<void> _syncFromCloudOld() async {
    try {
      final rows = await SupabaseRepo.fetch('bump_photos');
      final byId = {for (final r in rows) r['id'].toString(): _fromRow(r)};
      for (final p in _photos) {
        if (!byId.containsKey(p.id)) {
          byId[p.id] = p;
          await SupabaseRepo.insert('bump_photos', _toRow(p));
        }
      }
      _photos
        ..clear()
        ..addAll(byId.values);
      await _persist();
      await _backfillMedia();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  // Upload any bump photo still stored as a local path; rewrite to cloud path.
  Future<void> _backfillMedia() async {
    var changed = false;
    for (var i = 0; i < _photos.length; i++) {
      final p = _photos[i];
      final url = await StorageService.backfill(p.imageUrl, 'bump');
      if (url != p.imageUrl) {
        _photos[i] = BumpPhoto(
          id: p.id,
          imageUrl: url,
          weekNumber: p.weekNumber,
          date: p.date,
          caption: p.caption,
          isFavorite: p.isFavorite,
        );
        changed = true;
        // try { // kept for revert (step 8)
        //   await SupabaseRepo.upsert('bump_photos', _toRow(_photos[i]),
        //       onConflict: 'id');
        // } catch (_) {}
        _sync.touch(p.id);
      }
    }
    if (changed) {
      await _persist();
      await _pushWaiting();
    }
  }

  Map<String, dynamic> _toRow(BumpPhoto p) => {
        'id': p.id,
        'image_url': p.imageUrl,
        'week_number': p.weekNumber,
        'date': SupabaseRepo.dbTime(p.date),
        'caption': p.caption,
        'is_favorite': p.isFavorite,
      };

  BumpPhoto _fromRow(Map<String, dynamic> r) => BumpPhoto(
        id: (r['id'] ?? '').toString(),
        imageUrl: (r['image_url'] ?? '').toString(),
        weekNumber: (r['week_number'] as num?)?.toInt() ?? 0,
        date: SupabaseRepo.parseDbTime(r['date']),
        caption: (r['caption'] ?? '').toString(),
        isFavorite: r['is_favorite'] == true,
      );

  /// ⚠️ THIS PREGNANCY'S PHOTOS ONLY (R1, 2026-10-25). The list holds every
  /// pregnancy's; a photo belongs to the pregnancy whose window holds its
  /// date (pregnancy_records.dart). Every read below goes through this, so a
  /// pregnancy after a loss never opens on the lost one's bump.
  List<BumpPhoto> get _mine => [
        for (final p in _photos)
          if (PregnancyRecords.instance.inCurrent(p.date)) p,
      ];

  /// [w]'s photos, oldest first: the "Kept for you" page.
  List<BumpPhoto> photosIn(PregnancyWindow w) =>
      [for (final p in _byWeek(_photos)) if (w.holds(p.date)) p];

  static List<BumpPhoto> _byWeek(List<BumpPhoto> from) {
    final list = [...from];
    list.sort((a, b) {
      final w = a.weekNumber.compareTo(b.weekNumber);
      return w != 0 ? w : a.date.compareTo(b.date);
    });
    return list;
  }

  @override
  int countIn(PregnancyWindow w) => _photos.where((p) => w.holds(p.date)).length;

  /// Deletes [w]'s photos the way [delete] does, files and journal mirror
  /// included (the "Kept for you" delete).
  @override
  Future<int> removeIn(PregnancyWindow w) async {
    final ids = [for (final p in _photos) if (w.holds(p.date)) p.id];
    for (final id in ids) {
      await delete(id);
    }
    return ids.length;
  }

  /// Photos in chronological order (by week, then date).
  List<BumpPhoto> get photos {
    // final list = [..._photos]; // kept for revert
    final list = [..._mine];
    list.sort((a, b) {
      final w = a.weekNumber.compareTo(b.weekNumber);
      return w != 0 ? w : a.date.compareTo(b.date);
    });
    return list;
  }

  int get count => _mine.length;
  bool get isEmpty => _mine.isEmpty;
  BumpPhoto? get first => photos.isEmpty ? null : photos.first;
  BumpPhoto? get latest => photos.isEmpty ? null : photos.last;
  bool hasWeek(int week) => _mine.any((p) => p.weekNumber == week);

  /// One week's photos, cover first, then in the order she added them
  /// (2026-10-22, week rows). The cover is the photo she favourited, else the
  /// earliest she added. Derived on read rather than stored: there is no
  /// "cover" column, so there is nothing to drift out of step with the photos.
  List<BumpPhoto> photosForWeek(int week) {
    final list = _mine.where((p) => p.weekNumber == week).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final fav = list.indexWhere((p) => p.isFavorite);
    if (fav > 0) list.insert(0, list.removeAt(fav));
    return list;
  }

  /// The week's cover, or null when the week has no photo.
  BumpPhoto? coverFor(int week) {
    final list = photosForWeek(week);
    return list.isEmpty ? null : list.first;
  }

  Future<void> addPhoto({
    required String sourcePath,
    required int week,
    String caption = '',
    required String journalLabel,
  }) async {
    final bumpPath = await JournalStore.saveImage(sourcePath);
    final id = 'bp_${DateTime.now().microsecondsSinceEpoch}';
    final photo = BumpPhoto(
      id: id,
      imageUrl: bumpPath,
      weekNumber: week,
      date: DateTime.now(),
      caption: caption,
    );
    _photos.add(photo);
    _sync.touch(id);
    notifyListeners();
    await _persist();
    // if (SupabaseRepo.isLoggedIn) { // kept for revert (step 8)
    //   try {
    //     await SupabaseRepo.insert('bump_photos', _toRow(photo));
    //   } catch (_) {}
    // }
    await _pushWaiting();

    // Mirror into the Journal (its own file copy) → also shows in the Calendar.
    final journalPath = await JournalStore.saveImage(sourcePath);
    await JournalStore.instance.addEntry(JournalEntry(
      id: 'bump_$id',
      type: JournalEntryType.photo,
      title: caption.isNotEmpty ? caption : journalLabel,
      date: DateTime.now(),
      weekNumber: week,
      imageUrl: journalPath,
    ));
  }

  /// EXCLUSIVE PER WEEK (2026-10-22). The favourite is the week's cover, and
  /// a week has one cover, so favouriting a photo un-favourites the other
  /// photos of its week. Each photo that changed is touched on its own: the
  /// ledger syncs per row, so an untouched sibling would keep its old heart in
  /// the cloud and come back as a second cover on her other phone.
  Future<void> toggleFavorite(String id) async {
    final i = _photos.indexWhere((p) => p.id == id);
    if (i < 0) return;
    final nowFavorite = !_photos[i].isFavorite;
    _photos[i] = _photos[i].copyWith(isFavorite: nowFavorite);
    _sync.touch(id);
    if (nowFavorite) {
      final week = _photos[i].weekNumber;
      for (var j = 0; j < _photos.length; j++) {
        final o = _photos[j];
        // Only this pregnancy's week (R1): the old pregnancy keeps its cover.
        if (j != i && o.weekNumber == week && o.isFavorite &&
            PregnancyRecords.instance.inCurrent(o.date)) {
          _photos[j] = o.copyWith(isFavorite: false);
          _sync.touch(o.id);
        }
      }
    }
    notifyListeners();
    await _persist();
    // Kept for revert (step 8): a one-shot upsert, lost offline.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.upsert('bump_photos', _toRow(_photos[i]),
    //         onConflict: 'id');
    //   } catch (_) {}
    // }
    await _pushWaiting();
  }

  /// Moves a photo to another week (2026-10-22), the toggleFavorite shape.
  /// A favourite moved into a week that already has one loses its heart: the
  /// week she moves it into keeps the cover she chose there, rather than the
  /// move silently replacing it.
  ///
  /// The Journal mirror (`bump_<id>`) carries its week only in its default
  /// title, "Bump, week N". That title follows the move; a caption she wrote
  /// herself is hers and is left alone.
  Future<void> setWeek(String id, int week) async {
    final i = _photos.indexWhere((p) => p.id == id);
    if (i < 0 || _photos[i].weekNumber == week) return;
    final from = _photos[i].weekNumber;
    final clash = _photos[i].isFavorite &&
        _photos.any((p) => p.id != id && p.weekNumber == week && p.isFavorite);
    _photos[i] = _photos[i].copyWith(
      weekNumber: week,
      isFavorite: clash ? false : null,
    );
    _sync.touch(id);
    notifyListeners();
    await _persist();
    await _pushWaiting();
    final mirror = JournalStore.instance.manualEntries.where((e) => e.id == 'bump_$id').firstOrNull;
    if (mirror != null && mirror.title == 'Bump, week $from') {
      await JournalStore.instance.updateEntry(mirror.copyWith(title: 'Bump, week $week'));
    }
  }

  Future<void> updateCaption(String id, String caption) async {
    final i = _photos.indexWhere((p) => p.id == id);
    if (i < 0) return;
    _photos[i] = _photos[i].copyWith(caption: caption);
    _sync.touch(id);
    notifyListeners();
    await _persist();
    // Kept for revert (step 8): a one-shot upsert, lost offline.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.upsert('bump_photos', _toRow(_photos[i]),
    //         onConflict: 'id');
    //   } catch (_) {}
    // }
    await _pushWaiting();
  }

  /// A soft delete (step 8, 0106). The removal travels to her other phones;
  /// the Storage file goes once the cloud has confirmed it ([_pushWaiting]).
  Future<void> delete(String id) async {
    for (final p in _photos.where((p) => p.id == id)) {
      _deleteLocalFile(p.imageUrl);
      _sync.remove(id, _toRow(p));
    }
    _photos.removeWhere((p) => p.id == id);
    notifyListeners();
    await _persist();
    // Kept for revert (step 8): a one-shot hard delete that left the Storage
    // file behind.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.delete('bump_photos', id);
    //   } catch (_) {}
    // }
    await _pushWaiting();
    // Remove the mirrored journal entry (and its file copy).
    await JournalStore.instance.deleteEntry('bump_$id');
  }

  /// Test seam: replace the in-memory list without prefs or the cloud.
  @visibleForTesting
  void debugSeed(List<BumpPhoto> photos) {
    _photos
      ..clear()
      ..addAll(photos);
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(_photos.map((e) => e.toJson()).toList()));
    } catch (_) {/* best-effort */}
  }
}
