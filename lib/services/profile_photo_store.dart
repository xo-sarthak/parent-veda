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

import 'remote/cloud_merged_store.dart';
import 'remote/storage_service.dart';
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';

// IN THE CLOUD SINCE STEP 13 (2026-10-22, sync log). Her photo was only a file
// on this phone, so a new phone or a sign-out lost it. The file now goes to
// Storage (`media/<uid>/avatar/...`) and its reference is the one item
// (`photo`) of a per-item merged store (CloudMergedStore). [path] stays this
// phone's own copy; a phone that lacks it downloads one into its cache.
class ProfilePhotoStore extends ChangeNotifier with CloudMergedStore {
  ProfilePhotoStore._() {
    SyncRegistry.registerReset(_resetForAccount);
  }
  static final ProfilePhotoStore instance = ProfilePhotoStore._();

  static const String _kPath = 'pv_profile_photo_path';
  static const String _kRef = 'pv_profile_photo_ref';

  String? _path;
  bool _loaded = false;

  /// The photo's Storage reference once uploaded; null until then.
  String? _ref;

  // ---- the cloud (step 13) --------------------------------------------------

  @override
  String get cloudKey => 'profile_photo';

  @override
  Map<String, Object?> cloudItems() => {if (_ref != null) 'photo': _ref};

  @override
  void applyCloudItems(Map<String, Object?> items) {
    final ref = items['photo']?.toString();
    if (ref == _ref) return;
    _ref = ref;
    if (ref == null) {
      _path = null; // removed on her other phone
      return;
    }
    _download(ref);
  }

  Future<void> _download(String ref) async {
    final f = await StorageService.resolve(ref);
    if (f == null || _ref != ref) return;
    _path = f.path;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPath, f.path);
    } catch (_) {}
    // A display change only: the item itself did not change.
    super.notifyListeners();
  }

  @override
  Future<void> persistLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_ref == null) {
        await prefs.remove(_kRef);
      } else {
        await prefs.setString(_kRef, _ref!);
      }
      if (_path == null) await prefs.remove(_kPath);
    } catch (_) {}
  }

  /// A photo still only on this phone goes up; its reference then syncs.
  Future<void> _uploadIfNeeded() async {
    final p = path;
    if (p == null || _ref != null || !SupabaseRepo.isLoggedIn) return;
    final ref = await StorageService.upload(p, 'avatar');
    if (ref == p) return; // offline or not set up: next time
    _ref = ref;
    await persistLocalCache();
    notifyListeners();
  }

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
      _ref = prefs.getString(_kRef);
    } catch (_) {
      _path = null;
    }
    notifyListeners();
    await syncMergedFromCloud();
    await _uploadIfNeeded();
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
      final oldRef = _ref;
      _ref = null;
      if (oldRef != null) StorageService.remove(oldRef);
      notifyListeners();
      await _uploadIfNeeded();
    } catch (_) {
      // A failed copy leaves her previous photo (or none) as it was.
    }
  }

  Future<void> remove() async {
    final old = _path;
    _path = null;
    final oldRef = _ref;
    _ref = null;
    if (oldRef != null) StorageService.remove(oldRef);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kRef);
    } catch (_) {}
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

  // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  // are wiped, the singleton was not.
  // The photo file on disk is left alone; only the pointer to it is dropped.
  void _resetForAccount() {
    _path = null;
    _ref = null;
    _loaded = false;
    notifyListeners();
  }

  @visibleForTesting
  void resetForTest({String? path}) {
    _path = path;
    _loaded = true;
    notifyListeners();
  }
}
