// =============================================================================
//  NarrationService - plays the pre-generated Hindi narration
// -----------------------------------------------------------------------------
//  Reads a manifest of content-key -> audio file, plays the file when we have
//  one, and falls back to BabyVoiceService (the device's own TTS) when we do
//  not. A screen asks for a KEY and never has to know which of the two answered.
//
//  WHY PRE-GENERATED AUDIO AT ALL, when the device can already speak:
//  the Hindi voice pack is missing on many budget Android phones and
//  flutter_tts fails silently when it is; every phone ships a different
//  narrator, so there is no brand voice and no testable quality floor. A file
//  sounds the same for everyone and needs no voice pack.
//
//  WHERE THE AUDIO COMES FROM is deliberately one method - [_sourceFor].
//  Today it is an asset, because the files are staged into assets/narration for
//  local testing. It becomes a UrlSource over R2 by changing that one method,
//  and StorageService.resolve() already does download-once-and-cache. Nothing
//  else in the app moves.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../localization/app_language.dart';
import 'baby_voice_service.dart';

class NarrationService extends ChangeNotifier {
  NarrationService._();
  static final NarrationService instance = NarrationService._();

  static const _manifestAsset = 'assets/narration/manifest_hi.json';

  final AudioPlayer _player = AudioPlayer();
  Map<String, String> _files = const {};
  bool _loaded = false;
  String? _playingKey;

  String? get playingKey => _playingKey;
  bool isPlaying(String key) => _playingKey == key;

  /// True when a real recording exists for [key].
  ///
  /// Screens use this to decide whether to show a speaker at all where the
  /// device fallback would be poor. It is NOT a precondition for [play] -
  /// play() falls back on its own.
  bool hasAudio(String key) => _files.containsKey(key);

  Future<void> init() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final raw = await rootBundle.loadString(_manifestAsset);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _files = {
        for (final e in decoded.entries)
          e.key: (e.value as Map)['file'] as String,
      };
    } catch (_) {
      // No manifest bundled (or a bad one) is not an error: every caller still
      // works, just via the device voice. Narration is an enhancement.
      _files = const {};
    }
    _player.onPlayerComplete.listen((_) {
      _playingKey = null;
      notifyListeners();
    });
    notifyListeners();
  }

  /// Cloudflare R2, public bucket. THE ONLY PLACE THAT KNOWS WHERE AUDIO LIVES.
  ///
  /// Being one method is what made the move from bundled assets to R2 a
  /// two-line change instead of a migration: nothing else in the app - no
  /// screen, no widget, no test - has ever named a path.
  ///
  /// ⚠️ This is the r2.dev DEVELOPMENT url. Cloudflare rate-limits it and says
  /// not to ship on it. Swapping to a custom domain (audio.parentveda.com) is a
  /// change to this one constant, which is the point.
  static const String _base =
      'https://pub-e6e800cad8eb4fec88c09b9ddde6e0e2.r2.dev';

  /// Where [key]'s audio lives.
  ///
  /// Through the cache, so a passage is fetched once and then plays from disk -
  /// offline, instantly, and without spending Cloudflare reads every time she
  /// replays a card. R2 charges no egress, but a mother on a metered Indian
  /// connection is paying for every byte we re-download.
  Future<Source> _sourceFor(String key) async {
    final rel = _files[key]!;
    final local = await _cachedFile(rel);
    if (local != null) return DeviceFileSource(local.path);
    return UrlSource('$_base/$rel');
  }

  /// The on-disk copy of [rel], downloading it first if we do not have it.
  ///
  /// Returns null rather than throwing: a failed download must fall through to
  /// streaming, and a failed stream falls through to the device voice. Narration
  /// is an enhancement, and no layer of it may ever be the reason a card is
  /// silent.
  Future<File?> _cachedFile(String rel) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final f = File('${dir.path}/narration/$rel');
      if (await f.exists() && await f.length() > 0) return f;

      final res = await http.get(Uri.parse('$_base/$rel'));
      if (res.statusCode != 200 || res.bodyBytes.isEmpty) return null;
      await f.parent.create(recursive: true);
      // Write beside and rename, so a kill mid-download cannot leave a
      // truncated mp3 that we would then treat as cached forever.
      final tmp = File('${f.path}.part');
      await tmp.writeAsBytes(res.bodyBytes, flush: true);
      await tmp.rename(f.path);
      return f;
    } catch (_) {
      return null;
    }
  }

  /// Speak [key]. [text] is what the passage says, used only if we have to
  /// fall back to the device voice; [englishText] is used if that voice cannot
  /// speak Hindi on this phone.
  Future<void> play(
    String key, {
    required String text,
    required AppLanguage lang,
    String? englishText,
  }) async {
    await init();
    if (isPlaying(key)) {
      await stop();
      return;
    }
    await stop();

    if (_files.containsKey(key)) {
      try {
        _playingKey = key;
        notifyListeners();
        // Resolving can now take a moment - the first play of a passage
        // downloads it. If she taps another card while that is in flight,
        // _playingKey has moved on and this result is stale, so drop it rather
        // than start a second voice over the top of hers.
        final src = await _sourceFor(key);
        if (_playingKey != key) return;
        await _player.play(src);
        return;
      } catch (_) {
        // A missing or corrupt file must not leave the user with silence and
        // a stuck play button - drop through to the device voice.
        _playingKey = null;
        notifyListeners();
      }
    }

    await BabyVoiceService.instance.speak(
      text,
      cardKey: key,
      lang: lang,
      englishText: englishText,
      scope: VoiceScope.journey,
    );
  }

  final Set<String> _autoPlayed = {};

  /// Play [key] once per session, for cards that narrate themselves when they
  /// come into view.
  ///
  /// Separate from [play] because play() TOGGLES - tapping a playing speaker
  /// stops it. Auto-play must never stop something; a card scrolling into view
  /// that silenced the card before it would be maddening.
  Future<void> autoPlay(
    String key, {
    required String text,
    required AppLanguage lang,
    String? englishText,
  }) async {
    if (!_autoPlayed.add(key)) return;
    if (isPlaying(key)) return;
    await play(key, text: text, lang: lang, englishText: englishText);
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    await BabyVoiceService.instance.stop();
    if (_playingKey != null) {
      _playingKey = null;
      notifyListeners();
    }
  }

  /// The manifest key for a weekly-content passage.
  ///
  /// [path] is the JSON path in weekContent.json - `babySnapshot.reveal` - NOT
  /// the Dart field name. The model renames several of them (`snapshot` for
  /// babySnapshot, `mom` for momJourney), so deriving a key from the Dart side
  /// would silently miss. test/narration_keys_test.dart checks every key used
  /// in the app against the manifest, because a typo here is not a crash - it
  /// is just no audio, forever.
  static String weekKey(int week, String path) => 'week$week.$path';

  /// The manifest prefix for a Daily Moment day — `home.w20.0`.
  ///
  /// TWO THINGS HERE ARE EASY TO GET WRONG, and both fail silently: a wrong key
  /// is not an error, it is a speaker that quietly falls back to the device
  /// voice for that passage forever.
  ///
  ///  * The week is ZERO-PADDED. The keys were generated from the filenames
  ///    (`week_04.json`), so it is `home.w04`, never `home.w4`.
  ///  * The second number is the day's INDEX IN ITS WEEK (0-6), not the day of
  ///    pregnancy. `HomeDay.day` is the pregnancy day — 134 for the first day of
  ///    week 20 — and the files are arrays of seven, so the index is
  ///    `day - (week-1)*7 - 1`. Verified against weeks 4, 20 and 40.
  static String homePrefix(int week, int dayOfPregnancy) {
    final idx = dayOfPregnancy - (week - 1) * 7 - 1;
    return 'home.w${week.toString().padLeft(2, '0')}.$idx';
  }

  /// `home.w20.0.grow.expanded` for a field of a Daily Moment day.
  static String homeKey(int week, int dayOfPregnancy, String path) =>
      '${homePrefix(week, dayOfPregnancy)}.$path';
}
