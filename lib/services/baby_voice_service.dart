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

/// Which surface a voice request belongs to. Mute is tracked independently per
/// scope, so muting the Weekly Journey never silences the Home screen and vice
/// versa.
enum VoiceScope { home, journey }

class BabyVoiceService extends ChangeNotifier {
  BabyVoiceService._();
  static final BabyVoiceService instance = BabyVoiceService._();

  // Per-scope persisted mute. The legacy single key migrates into `journey`.
  static const _mutedKeyHome = 'baby_voice_muted_home';
  static const _mutedKeyJourney = 'baby_voice_muted_journey';
  static const _legacyMutedKey = 'baby_voice_muted';

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  final Map<VoiceScope, bool> _muted = {
    VoiceScope.home: false,
    VoiceScope.journey: false,
  };
  String? _playingKey;
  VoiceScope? _playingScope;
  final Set<String> _playedThisSession = {};

  bool isMutedFor(VoiceScope scope) => _muted[scope] ?? false;
  String? get playingKey => _playingKey;
  bool isPlaying(String cardKey) => _playingKey == cardKey;

  Future<void> init() async {
    if (_ready) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final legacy = prefs.getBool(_legacyMutedKey) ?? false;
      _muted[VoiceScope.home] = prefs.getBool(_mutedKeyHome) ?? false;
      _muted[VoiceScope.journey] = prefs.getBool(_mutedKeyJourney) ?? legacy;
      await _tts.setPitch(1.8);
      await _tts.setSpeechRate(0.4);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      _tts.setStartHandler(() {
        notifyListeners();
      });
      _tts.setCompletionHandler(() {
        _playingKey = null;
        _playingScope = null;
        notifyListeners();
      });
      _tts.setCancelHandler(() {
        _playingKey = null;
        _playingScope = null;
        notifyListeners();
      });
      _tts.setErrorHandler((_) {
        _playingKey = null;
        _playingScope = null;
        notifyListeners();
      });
    } catch (_) {
      // TTS is an enhancement - never fatal.
    }
    _ready = true;
  }

  String _localeFor(AppLanguage lang) => lang.isHinglish ? 'hi-IN' : 'en-IN';

  /// Speak [text] for [cardKey]. Returns immediately if muted.
  Future<void> speak(String text, {
    required String cardKey,
    required AppLanguage lang,
    VoiceScope scope = VoiceScope.journey,
  }) async {
    if (isMutedFor(scope) || text.trim().isEmpty) return;
    await init();
    try {
      await _tts.stop();
      try {
        await _tts.setLanguage(_localeFor(lang));
      } catch (_) {
        await _tts.setLanguage('en-IN');
      }
      _playingKey = cardKey;
      _playingScope = scope;
      notifyListeners();
      await _tts.speak(text);
    } catch (_) {
      _playingKey = null;
      _playingScope = null;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _playingKey = null;
    _playingScope = null;
    notifyListeners();
  }

  /// Speaker-icon behaviour for a card: stop if this card is playing, else play.
  Future<void> toggleCard(String text, {
    required String cardKey,
    required AppLanguage lang,
    VoiceScope scope = VoiceScope.journey,
  }) async {
    if (isPlaying(cardKey)) {
      await stop();
    } else {
      markPlayed(cardKey);
      await speak(text, cardKey: cardKey, lang: lang, scope: scope);
    }
  }

  /// Auto-play once per card per session (respects that scope's mute).
  Future<void> autoPlay(String text, {
    required String cardKey,
    required AppLanguage lang,
    VoiceScope scope = VoiceScope.journey,
  }) async {
    if (isMutedFor(scope) || _playedThisSession.contains(cardKey)) return;
    markPlayed(cardKey);
    await speak(text, cardKey: cardKey, lang: lang, scope: scope);
  }

  bool hasPlayed(String cardKey) => _playedThisSession.contains(cardKey);
  void markPlayed(String cardKey) => _playedThisSession.add(cardKey);

  Future<void> setMutedFor(VoiceScope scope, bool muted) async {
    if (isMutedFor(scope) == muted) return;
    _muted[scope] = muted;
    // Only stop playback if the scope being muted is the one currently speaking.
    if (muted && _playingScope == scope) await stop();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        scope == VoiceScope.home ? _mutedKeyHome : _mutedKeyJourney,
        muted,
      );
    } catch (_) {}
  }

  Future<void> toggleMuteFor(VoiceScope scope) =>
      setMutedFor(scope, !isMutedFor(scope));

  /// Stable per-card key, e.g. "week_21_size_reveal".
  static String keyFor(int week, String card) => 'week_${week}_$card';
}
