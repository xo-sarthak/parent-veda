// =============================================================================
//  ShravanLibrary — the sound library's manifest, and the files it caches
// -----------------------------------------------------------------------------
//  Built from `ParentVeda_Garbh_Sanskar_pillars_build.pdf`, pillar 1, 12 Sep
//  2026: *"everything we will replace later with our own licensed content
//  MUST be read from a manifest (a JSON asset registry), keyed by id,
//  holding: title, duration, category, source URL or asset path, licence,
//  attribution. Replacing an asset later must need only a manifest edit, NO
//  code change."* And: *"offline download and caching."*
//
//  ⚠️ THE MANIFEST IS `assets/audio/shravan_manifest.json`. One entry per
//  `GarbhAudio` id. This class reads it once and answers two questions: what
//  plays for a track (a cached file, else its URL), and what to show about
//  it (the recordist, the licence, the source). `RagaAudioStore` stays the
//  one player; this only tells it what to play.
//
//  ⚠️ STREAM FIRST, CACHE BEHIND. On first play the URL streams so she hears
//  it now, and the same bytes download to the app's support directory for
//  next time. Second play is the file: offline, no data. "Save for offline"
//  on the screen is the same download, started on purpose. A `.part` file is
//  written and renamed, so a download the OS kills half-way is not a track
//  that starts and cuts out.
//
//  ⚠️ NO TRACK IN THE MANIFEST IS NOT AN ERROR. `trackFor` returns null and
//  the screen plays the bundled drone with its honest "sample" line, exactly
//  as it did before this file existed. A manifest that fails to parse is the
//  same case for every track. Nothing here throws to a screen.
//
//  ⚠️ WHERE THE FILES LIVE TODAY. Every `file` URL points at archive.org —
//  direct links, no login, no egress bill, and each item's own page is the
//  `sourceUrl` beside it. The intended home is Cloudflare R2 (the user's
//  call; zero egress); moving there is nine URL edits in the manifest.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// One entry of the manifest.
class ShravanTrack {
  const ShravanTrack({
    required this.id,
    required this.title,
    required this.category,
    required this.durationSec,
    required this.file,
    required this.sourceUrl,
    required this.licence,
    required this.attribution,
    this.note = '',
  });

  final String id;
  final String title;

  /// "raga" or "nature".
  final String category;
  final int durationSec;

  /// What plays: a URL today, an R2 URL tomorrow.
  final String file;

  /// The page it came from, for the credits screen.
  final String sourceUrl;
  final String licence;
  final String attribution;
  final String note;

  int get minutes => (durationSec / 60).round();

  factory ShravanTrack.fromJson(Map<String, dynamic> j) => ShravanTrack(
        id: j['id'] as String,
        title: j['title'] as String,
        category: j['category'] as String,
        durationSec: (j['durationSec'] as num).toInt(),
        file: j['file'] as String,
        sourceUrl: j['sourceUrl'] as String? ?? '',
        licence: j['licence'] as String? ?? '',
        attribution: j['attribution'] as String? ?? '',
        note: j['note'] as String? ?? '',
      );
}

class ShravanLibrary extends ChangeNotifier {
  ShravanLibrary._();
  static final ShravanLibrary instance = ShravanLibrary._();

  static const String manifestAsset = 'assets/audio/shravan_manifest.json';

  Map<String, ShravanTrack> _tracks = const {};
  final Map<String, String> _cachedPath = {};
  final Set<String> _downloading = {};
  bool _loaded = false;
  Future<void>? _loading;

  /// Every track in the manifest, in manifest order.
  List<ShravanTrack> get tracks => List.unmodifiable(_tracks.values);
  bool get isLoaded => _loaded;

  /// Idempotent; every caller may await it.
  Future<void> init() {
    if (_loaded) return Future.value();
    return _loading ??= _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString(manifestAsset);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final list = (decoded['tracks'] as List).cast<Map<String, dynamic>>();
      _tracks = {
        for (final j in list) j['id'] as String: ShravanTrack.fromJson(j),
      };
    } catch (_) {
      _tracks = const {};
    }
    try {
      final dir = await _dir();
      if (await dir.exists()) {
        await for (final f in dir.list()) {
          if (f is File && f.path.endsWith('.mp3')) {
            final id = f.uri.pathSegments.last.replaceAll('.mp3', '');
            if (_tracks.containsKey(id)) _cachedPath[id] = f.path;
          }
        }
      }
    } catch (_) {}
    _loaded = true;
    notifyListeners();
  }

  /// Parse a manifest body without touching the bundle — for tests, and for
  /// a future remote manifest.
  @visibleForTesting
  void loadFromJson(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['tracks'] as List).cast<Map<String, dynamic>>();
    _tracks = {
      for (final j in list) j['id'] as String: ShravanTrack.fromJson(j),
    };
    _loaded = true;
    notifyListeners();
  }

  ShravanTrack? trackFor(String id) => _tracks[id];

  bool isCached(String id) => _cachedPath.containsKey(id);
  bool isDownloading(String id) => _downloading.contains(id);

  /// The thing to hand the player: the cached file's path when there is one,
  /// else the URL. [isFile] says which.
  ({String source, bool isFile})? playableFor(String id) {
    final t = _tracks[id];
    if (t == null) return null;
    final local = _cachedPath[id];
    if (local != null) return (source: local, isFile: true);
    return (source: t.file, isFile: false);
  }

  Future<Directory> _dir() async {
    final base = await getApplicationSupportDirectory();
    return Directory('${base.path}/shravan');
  }

  /// Download [id] for offline play. Safe to call twice; safe to call for a
  /// track already cached (a no-op). Failure leaves nothing behind.
  Future<void> download(String id) async {
    final t = _tracks[id];
    if (t == null || _cachedPath.containsKey(id) || _downloading.contains(id)) {
      return;
    }
    _downloading.add(id);
    notifyListeners();
    try {
      final dir = await _dir();
      await dir.create(recursive: true);
      final target = File('${dir.path}/$id.mp3');
      final tmp = File('${target.path}.part');
      final res = await http.get(Uri.parse(t.file));
      if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
        await tmp.writeAsBytes(res.bodyBytes, flush: true);
        await tmp.rename(target.path);
        _cachedPath[id] = target.path;
      }
    } catch (_) {
      // Local-first: a failed download is a track that streams next time.
    } finally {
      _downloading.remove(id);
      notifyListeners();
    }
  }

  /// Remove the cached file, so the next play streams again.
  Future<void> removeDownload(String id) async {
    final p = _cachedPath.remove(id);
    if (p != null) {
      try {
        await File(p).delete();
      } catch (_) {}
    }
    notifyListeners();
  }
}
