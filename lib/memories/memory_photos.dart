// =============================================================================
//  MemoryPhotos — where a memory's photo actually lives
// -----------------------------------------------------------------------------
//  image_picker hands back a path inside the app's CACHE directory. Android
//  purges that whenever it wants space, so persisting the picker's path means a
//  saved memory can lose its photo while the app is still installed - no
//  reinstall, no uninstall, just Android reclaiming cache. The parent opens a
//  keepsake they made last month and the frame is empty.
//
//  So every picked image is copied straight into the app's documents directory,
//  which is only cleared when the app itself is removed. This is the same shape
//  journal_store and the older memory_store already use for their photos.
//
//  This is also the seam for cloud sync: [importPicked] is where a
//  StorageService.upload() will go, and a resolve() alongside it, so the rest of
//  the feature never has to know whether a photo is local or remote.
// =============================================================================

import 'dart:io';

import 'package:path_provider/path_provider.dart';

class MemoryPhotos {
  MemoryPhotos._();

  /// `<documents>/memories/` — created on first use.
  static Future<Directory> _dir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/memories');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// Copy a just-picked image out of the picker's cache and into permanent
  /// storage; returns the path to persist. On any failure the ORIGINAL path is
  /// returned rather than throwing - a photo that might later vanish still
  /// beats losing the parent's pick outright.
  static Future<String> importPicked(String srcPath) async {
    try {
      final src = File(srcPath);
      if (!src.existsSync()) return srcPath;
      final dir = await _dir();
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final dest = File('${dir.path}/mem_$stamp.jpg');
      await dest.writeAsBytes(await src.readAsBytes());
      return dest.path;
    } catch (_) {
      return srcPath;
    }
  }

  /// True if [path] is one of ours (i.e. already copied to permanent storage).
  /// Used by the tests that guard against the cache-path regression.
  static bool isPersisted(String path) =>
      path.replaceAll('\\', '/').contains('/memories/mem_');
}
