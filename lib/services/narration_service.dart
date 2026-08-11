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

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

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

  /// Where [key]'s audio lives. THE ONLY PLACE THAT KNOWS.
  ///
  /// Swap this for `UrlSource(...)` over R2 - or resolve through
  /// StorageService for download-once-and-cache - and the rest of the app is
  /// unchanged.
  Source _sourceFor(String key) =>
      AssetSource('narration/${_files[key]!}');

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
        await _player.play(_sourceFor(key));
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
}
