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
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';
import 'remote/sync_row_book.dart';

class BumpStore extends ChangeNotifier {
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

  /// Photos in chronological order (by week, then date).
  List<BumpPhoto> get photos {
    final list = [..._photos];
    list.sort((a, b) {
      final w = a.weekNumber.compareTo(b.weekNumber);
      return w != 0 ? w : a.date.compareTo(b.date);
    });
    return list;
  }

  int get count => _photos.length;
  bool get isEmpty => _photos.isEmpty;
  BumpPhoto? get first => photos.isEmpty ? null : photos.first;
  BumpPhoto? get latest => photos.isEmpty ? null : photos.last;
  bool hasWeek(int week) => _photos.any((p) => p.weekNumber == week);

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

  Future<void> toggleFavorite(String id) async {
    final i = _photos.indexWhere((p) => p.id == id);
    if (i < 0) return;
    _photos[i] = _photos[i].copyWith(isFavorite: !_photos[i].isFavorite);
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
