// =============================================================================
//  GarbhNarrator — a recorded voice when there is one, a calm TTS when not
// -----------------------------------------------------------------------------
//  ⚠️ WAS `KriyaNarrator` FOR ONE COMMIT (a26a48a). Samvad needed the same
//  thing the next day — "for NOW use on-device text-to-speech to read any
//  passage aloud at a gentle pace, wired data-driven so a recorded narrator
//  replaces it per passage later" — and two narrators with one job is the
//  drift this file exists to prevent. One narrator, two pillars.
//
//  The relaxation's narration, one step at a time; a Samvad passage, whole. Same shape as
//  `NarrationService`: a step has a key; if the narration manifest lists a
//  file under it, the file plays; if not, the device speaks the script. A
//  recorded professional voice therefore replaces the TTS one step at a time
//  by editing `assets/narration/manifest_hi.json` — no code change, which is
//  what the pillars brief asks for.
//
//  ⚠️ WHY NOT JUST `NarrationService.play()`. Its fallback is
//  `BabyVoiceService`, which is tuned for the weekly "your baby says" cards —
//  pitch 1.8, the baby voice. A progressive-relaxation script read in a baby
//  voice would be the wrong screen entirely. This owns its own `FlutterTts`,
//  at a normal pitch and a slower rate, and uses `NarrationService` only for
//  the file path: `hasAudio(key)` and the cached download it already does.
//
//  ⚠️ ONE VOICE AT A TIME. `speak()` stops whatever this narrator was
//  saying first. It does not stop the raga underneath — that is
//  `RagaAudioStore`'s, and the whole point of the background track is that
//  it keeps going between steps.
//
//  ⚠️ LOCAL-FIRST AND BEST EFFORT. A phone with no TTS engine gets a silent
//  session with the script printed under each heading, which is the screen's
//  fallback anyway. Nothing here throws to the UI.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../localization/app_language.dart';
import 'narration_service.dart';

class GarbhNarrator extends ChangeNotifier {
  GarbhNarrator._();
  static final GarbhNarrator instance = GarbhNarrator._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  String? _speakingKey;

  /// The step being spoken, or null between steps.
  String? get speakingKey => _speakingKey;

  Future<void> _init() async {
    if (_ready) return;
    _ready = true;
    try {
      await _tts.setPitch(1.0);
      // Slower than speech: a relaxation script is paced by the listener's
      // breath, not the reader's. 0.4 is the same rate the app's other
      // narration uses; this sits a little under it.
      await _tts.setSpeechRate(0.38);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(false);
      _tts.setCompletionHandler(() {
        _speakingKey = null;
        notifyListeners();
      });
      _tts.setCancelHandler(() {
        _speakingKey = null;
        notifyListeners();
      });
      try {
        await _tts.setLanguage('en-IN');
      } catch (_) {}
    } catch (_) {
      // No engine. The screen prints the script; the session still runs.
    }
  }

  /// True when a recording is listed for [key] — the step will not use TTS.
  Future<bool> hasRecording(String key) async {
    await NarrationService.instance.init();
    return NarrationService.instance.hasAudio(key);
  }

  /// Say one step. Returns as soon as playback has started.
  Future<void> speak(String key, String text, {AppLanguage? lang}) async {
    await stop();
    if (await hasRecording(key)) {
      _speakingKey = key;
      notifyListeners();
      // The service plays the file and clears itself on completion.
      await NarrationService.instance
          .play(key, text: text, lang: lang ?? AppLanguage.english);
      return;
    }
    await _init();
    try {
      _speakingKey = key;
      notifyListeners();
      await _tts.speak(text);
    } catch (_) {
      _speakingKey = null;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    if (NarrationService.instance.playingKey != null) {
      await NarrationService.instance.stop();
    }
    if (_speakingKey != null) {
      _speakingKey = null;
      notifyListeners();
    }
  }

  /// Pause is a stop: TTS engines do not resume mid-sentence reliably, and a
  /// step that restarts from its first word after a pause reads better than
  /// one that picks up mid-clause.
  Future<void> pause() => stop();
}
