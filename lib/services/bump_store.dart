// =============================================================================
//  BumpStore — persistence for "My Bump Journey"
// -----------------------------------------------------------------------------
//  Stores weekly bump photos (metadata in shared_preferences; image files in
//  the app documents dir). Each added photo ALSO creates a Journal PHOTO entry
//  (its own file copy, id "bump_<id>") so the photo flows into My Journal and
//  My Calendar automatically — and the two stay independent (deleting one never
//  breaks the other).
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bump_photo.dart';
import '../models/journal_entry.dart';
import 'journal_store.dart';

class BumpStore extends ChangeNotifier {
  BumpStore._();
  static final BumpStore instance = BumpStore._();

  static const _key = 'bump_photos';

  final List<BumpPhoto> _photos = [];
  bool _loaded = false;

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
    _loaded = true;
    notifyListeners();
  }

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
    _photos.add(BumpPhoto(
      id: id,
      imageUrl: bumpPath,
      weekNumber: week,
      date: DateTime.now(),
      caption: caption,
    ));
    notifyListeners();
    await _persist();

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
    notifyListeners();
    await _persist();
  }

  Future<void> updateCaption(String id, String caption) async {
    final i = _photos.indexWhere((p) => p.id == id);
    if (i < 0) return;
    _photos[i] = _photos[i].copyWith(caption: caption);
    notifyListeners();
    await _persist();
  }

  Future<void> delete(String id) async {
    for (final p in _photos.where((p) => p.id == id)) {
      try {
        final f = File(p.imageUrl);
        if (f.existsSync()) f.deleteSync();
      } catch (_) {}
    }
    _photos.removeWhere((p) => p.id == id);
    notifyListeners();
    await _persist();
    // Remove the mirrored journal entry (and its file copy).
    await JournalStore.instance.deleteEntry('bump_$id');
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(_photos.map((e) => e.toJson()).toList()));
    } catch (_) {/* best-effort */}
  }
}
