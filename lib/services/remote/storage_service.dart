// =============================================================================
//  StorageService - files (photos + voice notes) <-> Supabase Storage
// -----------------------------------------------------------------------------
//  The DB tables hold text/metadata; the actual image + audio BYTES live in a
//  private Storage bucket ("media"), foldered per user + type:
//      media/<uid>/journal/<file>.jpg
//      media/<uid>/bump/<file>.jpg
//      media/<uid>/memory/<file>.jpg
//      media/<uid>/voice/<file>.m4a
//
//  LOCAL-FIRST, same as everything else:
//    * upload(localPath, type)  -> copies bytes up, returns the STORAGE object
//      path to store in the DB (or the original local path if logged out /
//      offline, so the app still works and we can back-fill later).
//    * resolve(ref)             -> returns a local File for display/playback,
//      downloading + caching from Storage on demand. Handles BOTH new storage
//      paths AND legacy absolute local paths (back-compat). null = show a
//      placeholder.
//    * remove(ref)              -> best-effort delete of the cloud object + cache.
//
//  resolve() downloads whatever [ref] points at, so it already works for a
//  PARTNER's file (e.g. the merged journal) the moment the storage read policy
//  allows it - no code change needed for that later step.
// =============================================================================

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  StorageService._();

  /// The private bucket the user creates in the dashboard.
  static const String bucket = 'media';

  static SupabaseClient get _client => Supabase.instance.client;
  static String? get _uid => _client.auth.currentUser?.id;
  static bool get isLoggedIn => _uid != null;

  // Local download cache (so a file is fetched at most once per device).
  static Future<Directory> _cacheDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/media_cache');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// The last path segment (the file name), tolerant of \ or / separators.
  static String _fileName(String pathOrRef) {
    final norm = pathOrRef.replaceAll('\\', '/');
    return norm.contains('/') ? norm.split('/').last : norm;
  }

  /// True if [ref] is a Storage object path (not an on-disk local file).
  static bool isRemoteRef(String ref) =>
      ref.isNotEmpty && !File(ref).existsSync();

  /// Upload a local file to `media/<uid>/<type>/<name>` and return the STORAGE
  /// object path to persist. Falls back to the original local path if logged
  /// out / the file is missing / the upload fails (offline - back-fill later).
  static Future<String> upload(String localPath, String type) async {
    final uid = _uid;
    final file = File(localPath);
    if (uid == null || !file.existsSync()) return localPath;
    final name = _fileName(localPath);
    final objectPath = '$uid/$type/$name';
    try {
      await _client.storage.from(bucket).upload(
            objectPath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );
      // Keep a cached copy so this device never re-downloads its own upload.
      final cache = File('${(await _cacheDir()).path}/$name');
      if (!cache.existsSync()) await file.copy(cache.path);
      return objectPath;
    } catch (_) {
      return localPath; // offline / not set up yet - keep working locally
    }
  }

  /// Resolve a stored reference to a local File for display/playback.
  ///   * legacy absolute local path that still exists -> used directly,
  ///   * already-cached storage object -> served from cache,
  ///   * otherwise downloaded from Storage and cached.
  /// Returns null when it can't be resolved (caller shows a placeholder).
  static Future<File?> resolve(String ref) async {
    if (ref.isEmpty) return null;
    // Legacy / same-device local file.
    final direct = File(ref);
    if (direct.existsSync()) return direct;
    // Treat as a Storage object path.
    final cache = File('${(await _cacheDir()).path}/${_fileName(ref)}');
    if (cache.existsSync()) return cache;
    try {
      final bytes = await _client.storage.from(bucket).download(ref);
      await cache.writeAsBytes(bytes);
      return cache;
    } catch (_) {
      return null;
    }
  }

  /// Best-effort delete of a Storage object + its local cache. No-op for a
  /// legacy local-only reference (nothing in the cloud to remove).
  static Future<void> remove(String ref) async {
    if (ref.isEmpty || !isRemoteRef(ref)) return;
    try {
      await _client.storage.from(bucket).remove([ref]);
    } catch (_) {}
    try {
      final cache = File('${(await _cacheDir()).path}/${_fileName(ref)}');
      if (cache.existsSync()) await cache.delete();
    } catch (_) {}
  }

  /// Backfill: if [ref] is still a local file (captured offline / logged-out, or
  /// from before Storage existed), upload it now and return the Storage path;
  /// otherwise return [ref] unchanged. No-op when logged out (upload falls back
  /// to the local path).
  static Future<String> backfill(String ref, String type) async {
    if (ref.isEmpty || !File(ref).existsSync()) return ref;
    return upload(ref, type);
  }

  /// Backfill every ref in [refs] (see [backfill]).
  static Future<List<String>> backfillAll(List<String> refs, String type) async {
    if (refs.isEmpty) return refs;
    final out = <String>[];
    for (final r in refs) {
      out.add(await backfill(r, type));
    }
    return out;
  }
}
