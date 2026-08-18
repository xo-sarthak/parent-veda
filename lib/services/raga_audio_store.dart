// =============================================================================
//  RagaAudioStore — one player for the whole app, so pause always means pause
// -----------------------------------------------------------------------------
//  ⚠️ THIS EXISTS BECAUSE OF A BUG REPORT THAT SOUNDED IMPOSSIBLE:
//
//    "Also when I play Garbh Sankar Music there is no option to pause it."
//
//  `RagaPlayer` has had a pause button since the day it was written. Line 139
//  of it is literally `_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded`.
//  So the first read of that report is that it is mistaken.
//
//  It is not. The mechanism is worth writing down because it generalises far
//  beyond audio:
//
//  **`RagaPlayer` was a StatefulWidget that constructed its own `AudioPlayer` in
//  `initState`.** There are four of them in the app — the daily home module, the
//  week card, the daily Shravan screen and the Shravan library detail. Four
//  widgets, four players, four independent `_isPlaying` flags, one pair of
//  speakers. Play on the home card, walk into Shravan, press play there, and two
//  drones are now looping. Press pause on the one in front of you and the sound
//  does not stop, because the thing you can hear is the other player. From the
//  outside that is *exactly* "there is no option to pause it".
//
//  ⚠️ THE GENERAL LESSON: **a widget must not own something the user perceives as
//  global.** Sound is global — there is one room and one pair of ears. So is a
//  video, a vibration, a torch, a mic, a wake lock. The moment two widgets can
//  each own one, the UI stops being able to describe the world truthfully, and no
//  amount of correctness inside either widget can fix it. Widget-owned state is
//  right for a scroll offset and wrong for a speaker.
//
//  And note which way the bug failed: it did not crash, log, or fail a test. The
//  code was correct in every file. It was only wrong in the *count* of files.
//
//  ⚠️ WHY A SINGLETON `ChangeNotifier` RATHER THAN PASSING A PLAYER DOWN.
//  Threading one player through four unrelated screens means every screen in
//  between carries an argument it does not use — and the week card lives inside a
//  card stack that would have to forward it too. The repo's own pattern (a
//  singleton store with `notifyListeners`) is the right shape here for the reason
//  it is usually the right shape: the thing being shared is not part of any
//  screen's identity.
//
//  ⚠️ WHAT THIS DELIBERATELY DOES NOT DO: it does not keep playing after the last
//  player leaves the screen. Background audio needs a notification, an audio
//  session, and a way to stop it from the lock screen; a drone that keeps looping
//  with no visible control is the bug above in a worse form.
// =============================================================================

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class RagaAudioStore extends ChangeNotifier {
  RagaAudioStore._();
  static final RagaAudioStore instance = RagaAudioStore._();

  AudioPlayer? _player;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<PlayerState>? _stateSub;

  /// ⚠️ THE FIELD THAT FIXES THE BUG. Which asset is loaded, app-wide.
  ///
  /// Every `RagaPlayer` compares its own asset against this to decide whether
  /// the sound in the room is *its* sound. Before, each one assumed it was.
  String? _asset;
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(seconds: 12);

  String? get asset => _asset;
  bool get isPlaying => _playing;
  Duration get position => _position;
  Duration get duration => _duration;

  /// A human title for whatever is playing, so a now-playing bar anywhere in the
  /// app can name it without being told.
  String? _title;
  String? get title => _title;

  // ---- the sleep timer ------------------------------------------------------
  //
  // ⚠️ THE SLEEP SECTION SPEC ASKS FOR THIS AND ASKS FOR IT ON BY DEFAULT:
  // "Controls: sleep timer (default ON), loop, offline play, and a safe default
  // volume that is not loud."
  //
  // The default is the interesting half. A looping drone with no timer plays all
  // night beside a sleeping baby, which the same spec separately warns against:
  // "keep the volume low, use a timer, do not play loud all night next to the
  // baby". Defaulting the timer OFF would make the safe choice the one she has to
  // find, and nobody finds a setting at 2am.
  //
  // ⚠️ AND IT LIVES IN THE STORE, NOT IN THE PLAYER SCREEN. The screen gets
  // closed — she puts the phone down. A timer owned by a widget dies with it and
  // the audio plays on, which is the same class of bug as the four independent
  // `AudioPlayer`s this file was written to fix: state the user perceives as
  // global cannot be owned by something that unmounts.
  Timer? _sleepTimer;
  Duration? _sleepAfter;
  DateTime? _sleepStartedAt;

  /// How long until the audio stops itself. Null means it does not.
  Duration? get sleepAfter => _sleepAfter;

  /// Roughly how much of the sleep timer is left, for display. Null when no
  /// timer is set.
  ///
  /// Derived from a start time rather than counted down in a tick, so it stays
  /// right when the app is backgrounded and no timer callbacks run.
  Duration? get sleepRemaining {
    final after = _sleepAfter;
    final from = _sleepStartedAt;
    if (after == null || from == null) return null;
    final left = after - DateTime.now().difference(from);
    return left.isNegative ? Duration.zero : left;
  }

  /// The default the player opens with. Twenty minutes is long enough to get a
  /// baby down and short enough that forgetting about it costs nothing.
  static const Duration kDefaultSleepTimer = Duration(minutes: 20);

  /// Set or clear the sleep timer. Pass null to turn it off.
  void setSleepTimer(Duration? after) {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepAfter = after;
    _sleepStartedAt = after == null ? null : DateTime.now();
    if (after != null) {
      _sleepTimer = Timer(after, () {
        // Stop, and clear the timer with it — a timer that has fired is not a
        // timer that is set, and leaving it displayed would be a lie.
        _sleepAfter = null;
        _sleepStartedAt = null;
        stop();
      });
    }
    notifyListeners();
  }

  /// True when [candidate] is the asset currently loaded — i.e. when this
  /// caller's controls are the controls for the sound that is audible.
  bool owns(String candidate) => _asset == candidate;

  /// Playing, and playing *this*. What a play/pause icon should read.
  bool isPlayingAsset(String candidate) => _playing && owns(candidate);

  /// Position, but only for the owner. A card that is not playing shows 00:00
  /// rather than inheriting another card's progress — which would be the same
  /// confusion in a smaller form.
  Duration positionFor(String candidate) =>
      owns(candidate) ? _position : Duration.zero;

  Duration durationFor(String candidate) =>
      owns(candidate) ? _duration : const Duration(seconds: 12);

  Future<void> _ensure(String next) async {
    if (_player != null && _asset == next) return;

    // ⚠️ A DIFFERENT ASSET MEANS THE OLD ONE STOPS. Two ragas at once is the
    // same defect as two players on one raga.
    //
    // The sleep timer is kept across the switch — see `_teardown`.
    await _teardown(keepSleepTimer: true);

    final p = AudioPlayer();
    await p.setReleaseMode(ReleaseMode.loop);
    _durSub = p.onDurationChanged.listen((d) {
      if (d > Duration.zero) {
        _duration = d;
        notifyListeners();
      }
    });
    _posSub = p.onPositionChanged.listen((pos) {
      _position = pos;
      notifyListeners();
    });
    _stateSub = p.onPlayerStateChanged.listen((st) {
      _playing = st == PlayerState.playing;
      notifyListeners();
    });
    _player = p;
    _asset = next;
    _position = Duration.zero;
  }

  /// ⚠️ TWO CALLERS, TWO INTENTS, AND THE SLEEP TIMER IS WHERE THEY DIFFER.
  ///
  /// `stop()` means "done" and the timer goes with it. `_ensure()` means "switch
  /// track" and the timer must SURVIVE — she asked for silence in twenty minutes,
  /// not for silence in twenty minutes unless she changes her mind about the
  /// lullaby. Tearing it down on a switch would mean tapping a different track
  /// silently disarms the timer and the audio then plays all night, which is the
  /// precise harm the timer exists to prevent.
  ///
  /// This is worth stating because the bug is invisible from either call site:
  /// both just call `_teardown()`, and the one that is wrong still works
  /// perfectly for the first track she plays.
  Future<void> _teardown({bool keepSleepTimer = false}) async {
    await _posSub?.cancel();
    await _durSub?.cancel();
    await _stateSub?.cancel();
    _posSub = _durSub = null;
    _stateSub = null;
    final p = _player;
    _player = null;
    _asset = null;
    _title = null;
    _playing = false;
    if (!keepSleepTimer) {
      _sleepTimer?.cancel();
      _sleepTimer = null;
      _sleepAfter = null;
      _sleepStartedAt = null;
    }
    _position = Duration.zero;
    _duration = const Duration(seconds: 12);
    if (p != null) {
      // Audio is a gentle enhancement — a teardown failure is never a crash.
      try {
        await p.stop();
      } catch (_) {}
      try {
        await p.dispose();
      } catch (_) {}
    }
  }

  /// Play [asset] if it is not already the audible one, otherwise pause/resume.
  ///
  /// One entry point on purpose: a `play()` and a separate `pause()` is how a
  /// caller ends up deciding which to call from a flag it holds itself, and that
  /// flag is where this whole bug lived.
  Future<void> toggle(String asset, {String? title}) async {
    try {
      await _ensure(asset);
      if (title != null) _title = title;
      final p = _player;
      if (p == null) return;
      if (_playing) {
        await p.pause();
      } else if (_position > Duration.zero) {
        await p.resume();
      } else {
        await p.play(AssetSource(asset));
      }
    } catch (_) {
      _playing = false;
      notifyListeners();
    }
  }

  Future<void> seek(String asset, Duration to) async {
    if (!owns(asset)) return;
    _position = to;
    notifyListeners();
    try {
      await _player?.seek(to);
    } catch (_) {}
  }

  /// Stop and release. Called when the last visible player goes away, and safe
  /// to call when nothing is playing.
  Future<void> stop() async {
    if (_player == null) return;
    await _teardown();
    notifyListeners();
  }

  /// ⚠️ TEST-ONLY. Resets the observable state without touching the plugin,
  /// which has no implementation under `flutter test`.
  @visibleForTesting
  void resetForTest() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _posSub = _durSub = null;
    _stateSub = null;
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepAfter = null;
    _sleepStartedAt = null;
    _player = null;
    _asset = null;
    _title = null;
    _playing = false;
    _position = Duration.zero;
    _duration = const Duration(seconds: 12);
  }
}
