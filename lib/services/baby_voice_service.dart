// =============================================================================
//  BabyVoiceService
// -----------------------------------------------------------------------------
//  A gentle, high-pitched baby text-to-speech voice (flutter_tts). Singleton,
//  ChangeNotifier so speaker icons + the cartoon avatar react to playback and
//  mute state.
//
//  - Auto-play once per card per session (session-scoped, not persisted).
//  - Per-card speaker toggle (independent of global mute).
//  - Global mute (persisted) suppresses all auto-play.
//  - Raga music player is entirely separate and unaffected.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_language.dart';

class BabyVoiceService extends ChangeNotifier {
  BabyVoiceService._();
  static final BabyVoiceService instance = BabyVoiceService._();

  static const _mutedKey = 'baby_voice_muted';

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  bool _isMuted = false;
  String? _playingKey;
  final Set<String> _playedThisSession = {};

  bool get isMuted => _isMuted;
  String? get playingKey => _playingKey;
  bool isPlaying(String cardKey) => _playingKey == cardKey;

  Future<void> init() async {
    if (_ready) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMuted = prefs.getBool(_mutedKey) ?? false;
      await _tts.setPitch(1.8);
      await _tts.setSpeechRate(0.4);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      _tts.setStartHandler(() {
        notifyListeners();
      });
      _tts.setCompletionHandler(() {
        _playingKey = null;
        notifyListeners();
      });
      _tts.setCancelHandler(() {
        _playingKey = null;
        notifyListeners();
      });
      _tts.setErrorHandler((_) {
        _playingKey = null;
        notifyListeners();
      });
    } catch (_) {
      // TTS is an enhancement — never fatal.
    }
    _ready = true;
  }

  String _localeFor(AppLanguage lang) => lang.isHinglish ? 'hi-IN' : 'en-IN';

  /// Speak [text] for [cardKey]. Returns immediately if muted.
  Future<void> speak(String text, {
    required String cardKey,
    required AppLanguage lang,
  }) async {
    if (_isMuted || text.trim().isEmpty) return;
    await init();
    try {
      await _tts.stop();
      try {
        await _tts.setLanguage(_localeFor(lang));
      } catch (_) {
        await _tts.setLanguage('en-IN');
      }
      _playingKey = cardKey;
      notifyListeners();
      await _tts.speak(text);
    } catch (_) {
      _playingKey = null;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _playingKey = null;
    notifyListeners();
  }

  /// Speaker-icon behaviour for a card: stop if this card is playing, else play.
  Future<void> toggleCard(String text, {
    required String cardKey,
    required AppLanguage lang,
  }) async {
    if (isPlaying(cardKey)) {
      await stop();
    } else {
      markPlayed(cardKey);
      await speak(text, cardKey: cardKey, lang: lang);
    }
  }

  /// Auto-play once per card per session (respects mute).
  Future<void> autoPlay(String text, {
    required String cardKey,
    required AppLanguage lang,
  }) async {
    if (_isMuted || _playedThisSession.contains(cardKey)) return;
    markPlayed(cardKey);
    await speak(text, cardKey: cardKey, lang: lang);
  }

  bool hasPlayed(String cardKey) => _playedThisSession.contains(cardKey);
  void markPlayed(String cardKey) => _playedThisSession.add(cardKey);

  Future<void> setMuted(bool muted) async {
    if (_isMuted == muted) return;
    _isMuted = muted;
    if (muted) await stop();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_mutedKey, muted);
    } catch (_) {}
  }

  Future<void> toggleMute() => setMuted(!_isMuted);

  /// Stable per-card key, e.g. "week_21_size_reveal".
  static String keyFor(int week, String card) => 'week_${week}_$card';
}
