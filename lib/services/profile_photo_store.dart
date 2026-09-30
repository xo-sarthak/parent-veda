// =============================================================================
//  ProfilePhotoStore: her own photo on the profile and the home's avatar
//  (2026-09-30)
// -----------------------------------------------------------------------------
//  The user: "provide an option for the parent to add their photo". Flo's
//  profile puts a small pencil on the avatar; Airbnb's leads with the photo.
//
//  LOCAL-FIRST, AND ONLY LOCAL FOR NOW. The picked image is copied into the
//  app's own documents folder (the picker's file is a cache the OS may clear)
//  and its path kept in shared_preferences. A photo is personal data that
//  never needs the network to show, so nothing is uploaded; syncing it to a
//  second phone (Supabase Storage, a private bucket, RLS by user) is owed and
//  written down in docs/STILL-OPEN.md §80.14. Removing the photo deletes the
//  copy, so "remove" means gone from this phone.
// =============================================================================

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePhotoStore extends ChangeNotifier {
  ProfilePhotoStore._();
  static final ProfilePhotoStore instance = ProfilePhotoStore._();

  static const String _kPath = 'pv_profile_photo_path';

  String? _path;
  bool _loaded = false;

  /// The photo's file path, or null when she has none (or it was deleted
  /// under us, e.g. the app's data was cleared).
  String? get path {
    final p = _path;
    if (p == null) return null;
    try {
      return File(p).existsSync() ? p : null;
    } catch (_) {
      return null;
    }
  }

  bool get hasPhoto => path != null;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _path = prefs.getString(_kPath);
    } catch (_) {
      _path = null;
    }
    notifyListeners();
  }

  /// Keeps a copy of [pickedPath] as her photo, replacing any earlier one.
  /// A new file name each time, so an image cache never shows the old face.
  Future<void> setFrom(String pickedPath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final ext = pickedPath.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
      final dest =
          '${dir.path}/profile_photo_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await File(pickedPath).copy(dest);
      final old = _path;
      _path = dest;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPath, dest);
      if (old != null && old != dest) {
        try {
          await File(old).delete();
        } catch (_) {}
      }
      notifyListeners();
    } catch (_) {
      // A failed copy leaves her previous photo (or none) as it was.
    }
  }

  Future<void> remove() async {
    final old = _path;
    _path = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPath);
    } catch (_) {}
    if (old != null) {
      try {
        await File(old).delete();
      } catch (_) {}
    }
    notifyListeners();
  }

  @visibleForTesting
  void resetForTest({String? path}) {
    _path = path;
    _loaded = true;
    notifyListeners();
  }
}
