// =============================================================================
//  PvVideoPlayer - ParentVeda's native video surface
// -----------------------------------------------------------------------------
//  Plays a video we host ourselves (an MP4/HLS URL from our backend) using
//  Flutter's native video_player - NO WebView, NO third-party player, so there
//  is zero provider branding to hide and nothing to fight. Everything on screen
//  is ParentVeda: our own overlay draws every control (play, ±10s, scrubber,
//  speed, fullscreen, replay, completion, next).
//    • Autoplay off; resumes from the last saved second.
//    • Fullscreen handled here (the SAME player instance is reparented via a
//      GlobalKey in the host, so playback never restarts).
//    • Reports progress + milestones to the repository and analytics.
//  If no URL exists (or under tests / on a platform without the video plugin) it
//  renders a calm poster instead - no call site has to special-case it.
// =============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../pp_common.dart';
import '../pp_watch_data.dart';
import 'pv_screen_security.dart';
import 'pv_video_analytics.dart';
import 'pv_video_config.dart';
import 'pv_video_repository.dart';

class PvVideoPlayer extends StatefulWidget {
  const PvVideoPlayer({
    super.key,
    required this.video,
    this.onNext,
    this.onFullscreenChanged,
    this.repository = const LocalWatchRepository(),
  });

  final WatchVideo video;

  /// Tapped from the completion card. If null, no "Next lesson" button shows.
  final VoidCallback? onNext;

  /// The host uses this to give the player the whole screen in fullscreen.
  final ValueChanged<bool>? onFullscreenChanged;

  final PvVideoRepository repository;

  @override
  State<PvVideoPlayer> createState() => PvVideoPlayerState();
}

class PvVideoPlayerState extends State<PvVideoPlayer> {
  VideoPlayerController? _controller;

  // playback snapshot (mirrored from the controller each tick)
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _buffered = 0;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _hasError = false;
  double _rate = 1.0;

  // session tracking
  bool _started = false;
  bool _completed = false;
  int _watchedSeconds = 0;
  int _replayCount = 0;
  int _prevPosSecs = 0;
  int _lastSavedSecs = -999;
  final Set<int> _milestones = {};

  // chrome
  bool _controlsVisible = true;
  bool _fullscreen = false;
  Timer? _hideTimer;
  double? _scrubFraction;

  // An OPAQUE ParentVeda cover sits over the video until it is actually playing.
  bool _playedOnce = false;
  bool _awaitingPlay = false;
  Timer? _watchdog;

  static const List<double> _speeds = [1.0, 1.25, 1.5, 2.0, 0.5, 0.75];

  WatchVideo get v => widget.video;
  bool get _ready => _controller != null && _controller!.value.isInitialized;
  int get _durationSecs => _duration.inSeconds > 0 ? _duration.inSeconds : (v.seconds > 0 ? v.seconds : 1);

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    if (!pvCanPlayNatively(v)) return;

    final lesson = await widget.repository.lesson(v.id);
    final url = lesson.videoUrl;
    if (url == null || !mounted) return;

    final resumeAt = lesson.completed ? 0 : lesson.lastPosition;
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;
    controller.addListener(_onTick);

    try {
      await controller.initialize();
    } catch (e) {
      if (kDebugMode) debugPrint('PvVideoPlayer init error for ${v.id}: $e');
      if (mounted) setState(() => _hasError = true);
      return;
    }
    if (!mounted) {
      controller.dispose();
      return;
    }
    if (resumeAt > 0) await controller.seekTo(Duration(seconds: resumeAt));
    _prevPosSecs = resumeAt;
    setState(() {
      _duration = controller.value.duration;
      _position = controller.value.position;
    });
    PvScreenSecurity.instance.enable();
    _restartHideTimer();
  }

  // ---- controller listener ------------------------------------------------
  void _onTick() {
    final c = _controller;
    if (c == null || !mounted) return;
    final val = c.value;

    if (val.hasError) {
      if (!_hasError) setState(() => _hasError = true);
      return;
    }

    final nowPlaying = val.isPlaying;
    final secs = val.position.inSeconds;

    // transitions -> analytics
    if (nowPlaying && !_started) {
      _started = true;
      _fire(PvVideoEvent.started);
    } else if (nowPlaying && !_isPlaying && _started) {
      _fire(PvVideoEvent.resumed);
    } else if (!nowPlaying && _isPlaying && !val.isCompleted) {
      _fire(PvVideoEvent.paused);
      _save();
    }

    // first real playback -> drop the opaque cover
    if (nowPlaying && !_playedOnce) {
      _watchdog?.cancel();
      _playedOnce = true;
      _awaitingPlay = false;
    }

    // watch-time: count natural forward ticks only (ignore seeks)
    final delta = secs - _prevPosSecs;
    if (nowPlaying && delta > 0 && delta < 2) _watchedSeconds += delta;
    _prevPosSecs = secs;

    _checkMilestones(secs);
    if (val.isCompleted && !_completed) _onEnded();
    if ((secs - _lastSavedSecs).abs() >= 5) _save();

    setState(() {
      _isPlaying = nowPlaying;
      _isBuffering = val.isBuffering;
      _position = val.position;
      _duration = val.duration;
      _buffered = _bufferedFraction(val);
      _rate = val.playbackSpeed;
    });

    if (nowPlaying) _restartHideTimer();
  }

  double _bufferedFraction(VideoPlayerValue val) {
    if (val.duration.inMilliseconds <= 0 || val.buffered.isEmpty) return 0;
    final end = val.buffered.last.end.inMilliseconds;
    return (end / val.duration.inMilliseconds).clamp(0.0, 1.0);
  }

  void _checkMilestones(int secs) {
    final pct = (secs / _durationSecs) * 100;
    for (final m in const [25, 50, 75]) {
      if (pct >= m && _milestones.add(m)) {
        _fire(m == 25
            ? PvVideoEvent.milestone25
            : m == 50
                ? PvVideoEvent.milestone50
                : PvVideoEvent.milestone75);
      }
    }
  }

  void _onEnded() {
    _completed = true;
    _controlsVisible = true;
    _hideTimer?.cancel();
    widget.repository.markCompleted(v.id);
    _fire(PvVideoEvent.completed);
  }

  // ---- persistence + analytics -------------------------------------------
  void _save() {
    final secs = _position.inSeconds;
    _lastSavedSecs = secs;
    if (!_completed) {
      widget.repository.saveProgress(v.id, positionSeconds: secs, watchedSeconds: _watchedSeconds);
    }
  }

  void _fire(PvVideoEvent event) {
    PvVideoAnalytics.instance.fire(PvVideoAnalyticsRecord(
      videoId: v.id,
      event: event,
      positionSeconds: _position.inSeconds,
      durationSeconds: _durationSecs,
      watchedSeconds: _watchedSeconds,
      playbackRate: _rate,
      replayCount: _replayCount,
    ));
  }

  // ---- controls -----------------------------------------------------------
  void _togglePlay() {
    final c = _controller;
    if (c == null) return;
    c.value.isPlaying ? c.pause() : c.play();
    _restartHideTimer();
  }

  void _startPlayback() {
    final c = _controller;
    if (c == null) return;
    setState(() => _awaitingPlay = true);
    c.play();
    _startWatchdog();
  }

  void _startWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer(const Duration(seconds: 15), () {
      if (mounted && !_playedOnce) setState(() => _hasError = true);
    });
  }

  void _seekBy(int seconds) {
    final c = _controller;
    if (c == null) return;
    final target = Duration(seconds: (c.value.position.inSeconds + seconds).clamp(0, _durationSecs));
    c.seekTo(target);
    _prevPosSecs = target.inSeconds;
    setState(() => _position = target);
    _restartHideTimer();
  }

  void _seekToFraction(double f) {
    final c = _controller;
    if (c == null) return;
    final target = Duration(milliseconds: (f.clamp(0.0, 1.0) * _duration.inMilliseconds).round());
    c.seekTo(target);
    _prevPosSecs = target.inSeconds;
    setState(() => _position = target);
  }

  void _cycleSpeed() {
    final c = _controller;
    if (c == null) return;
    final i = _speeds.indexOf(_rate);
    final next = _speeds[(i + 1) % _speeds.length];
    c.setPlaybackSpeed(next);
    setState(() => _rate = next);
    _restartHideTimer();
  }

  void _replay() {
    final c = _controller;
    if (c == null) return;
    _replayCount++;
    _milestones.clear();
    _completed = false;
    _prevPosSecs = 0;
    c.seekTo(Duration.zero);
    c.play();
    _fire(PvVideoEvent.replay);
    setState(() => _position = Duration.zero);
    _restartHideTimer();
  }

  Future<void> _retry() async {
    final old = _controller;
    _controller = null;
    setState(() {
      _hasError = false;
      _playedOnce = false;
      _awaitingPlay = false;
    });
    old?.removeListener(_onTick);
    await old?.dispose();
    _boot();
  }

  Future<void> _toggleFullscreen() async {
    final next = !_fullscreen;
    setState(() => _fullscreen = next);
    if (next) {
      await SystemChrome.setPreferredOrientations(
          const [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setPreferredOrientations(
          const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    widget.onFullscreenChanged?.call(next);
    _restartHideTimer();
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _restartHideTimer();
  }

  void _restartHideTimer() {
    _hideTimer?.cancel();
    if (_completed) return;
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) setState(() => _controlsVisible = false);
    });
  }

  @override
  void dispose() {
    if (_started && !_completed && _position.inSeconds > _durationSecs * 0.05) {
      _fire(PvVideoEvent.abandoned);
    }
    _save();
    _hideTimer?.cancel();
    _watchdog?.cancel();
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    PvScreenSecurity.instance.disable();
    if (_fullscreen) {
      SystemChrome.setPreferredOrientations(
          const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  // ---- build --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // No source (or tests / no plugin): calm poster, never a crash.
    if (!pvCanPlayNatively(v)) {
      return _PvVideoPoster(video: v, loading: false, fullscreen: _fullscreen);
    }
    // Booting: error before first frame, or still loading.
    if (!_ready) {
      if (_hasError) return _framed(_errorLayer());
      return _PvVideoPoster(video: v, loading: true, fullscreen: _fullscreen);
    }

    final media = Stack(children: [
      Positioned.fill(child: _videoWidget()),
      Positioned.fill(child: _overlay()),
    ]);

    return PopScope(
      canPop: !_fullscreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _fullscreen) _toggleFullscreen();
      },
      child: _framed(media),
    );
  }

  Widget _framed(Widget child) => _fullscreen
      ? SizedBox.expand(child: ColoredBox(color: Colors.black, child: child))
      : AspectRatio(aspectRatio: 16 / 9, child: child);

  Widget _videoWidget() {
    final c = _controller!;
    final ar = c.value.aspectRatio;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: (ar.isFinite && ar > 0) ? ar : 16 / 9,
          child: VideoPlayer(c),
        ),
      ),
    );
  }

  // ---- overlay ------------------------------------------------------------
  Widget _overlay() {
    if (_hasError) return _errorLayer();
    if (_completed) return _completeLayer();
    if (!_playedOnce) return _coverLayer();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleControls,
      child: AnimatedOpacity(
        opacity: _controlsVisible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: IgnorePointer(
          ignoring: !_controlsVisible,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x55000000), Color(0x11000000), Color(0x66000000)],
                stops: [0, 0.5, 1],
              ),
            ),
            child: Stack(children: [
              _topBar(),
              if (_isBuffering) const Center(child: _Spinner()) else Center(child: _centerControls()),
              _bottomBar(),
            ]),
          ),
        ),
      ),
    );
  }

  // Opaque ParentVeda surface shown until real playback begins.
  Widget _coverLayer() {
    final loading = _awaitingPlay || _isBuffering;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF3A2A55), ppPurple.withValues(alpha: 0.9)],
        ),
      ),
      child: Stack(children: [
        _topBar(),
        Center(
          child: loading
              ? const _Spinner()
              : GestureDetector(
                  onTap: _startPlayback,
                  behavior: HitTestBehavior.opaque,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 66, height: 66, alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.94), shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded, color: ppPurple, size: 38),
                    ),
                    const SizedBox(height: 12),
                    Text(v.durationLabel, style: ppBody(11.5, color: Colors.white, w: FontWeight.w700)),
                  ]),
                ),
        ),
      ]),
    );
  }

  Widget _topBar() => Positioned(
        top: 6,
        left: 6,
        right: 6,
        child: Row(children: [
          _roundBtn(_fullscreen ? Icons.close_rounded : Icons.arrow_back_rounded, () {
            if (_fullscreen) {
              _toggleFullscreen();
            } else {
              Navigator.of(context).maybePop();
            }
          }),
          const SizedBox(width: 10),
          Expanded(
            child: Text(v.title,
                style: ppBody(13, color: Colors.white, w: FontWeight.w700),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ]),
      );

  Widget _centerControls() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seekBtn(Icons.replay_10_rounded, () => _seekBy(-10)),
          const SizedBox(width: 26),
          GestureDetector(
            onTap: _togglePlay,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 66, height: 66, alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.94), shape: BoxShape.circle),
              child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: ppPurple, size: 38),
            ),
          ),
          const SizedBox(width: 26),
          _seekBtn(Icons.forward_10_rounded, () => _seekBy(10)),
        ],
      );

  Widget _bottomBar() {
    final pos = _scrubFraction != null
        ? Duration(seconds: (_scrubFraction! * _durationSecs).round())
        : _position;
    return Positioned(
      left: 12,
      right: 12,
      bottom: 8,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _scrubber(),
        const SizedBox(height: 4),
        Row(children: [
          Text('${_fmt(pos.inSeconds)} / ${_fmt(_durationSecs)}',
              style: ppBody(11, color: Colors.white, w: FontWeight.w600)),
          const Spacer(),
          GestureDetector(
            onTap: _cycleSpeed,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text('${_rateLabel(_rate)}x', style: ppBody(12.5, color: Colors.white, w: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 6),
          _iconBtn(_fullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded, _toggleFullscreen),
        ]),
      ]),
    );
  }

  Widget _scrubber() {
    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth;
      final playedFraction = _scrubFraction ??
          (_durationSecs > 0 ? (_position.inSeconds / _durationSecs).clamp(0.0, 1.0) : 0.0);
      void handle(double dx) => setState(() => _scrubFraction = (dx / width).clamp(0.0, 1.0));

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (d) => handle(d.localPosition.dx),
        onHorizontalDragUpdate: (d) => handle(d.localPosition.dx),
        onHorizontalDragEnd: (_) {
          final f = _scrubFraction;
          if (f != null) _seekToFraction(f);
          setState(() => _scrubFraction = null);
          _restartHideTimer();
        },
        onTapDown: (d) {
          _seekToFraction((d.localPosition.dx / width).clamp(0.0, 1.0));
          _restartHideTimer();
        },
        child: SizedBox(
          height: 22,
          child: Stack(alignment: Alignment.centerLeft, children: [
            Container(height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.28), borderRadius: BorderRadius.circular(999))),
            FractionallySizedBox(
              widthFactor: _buffered.clamp(0.0, 1.0),
              child: Container(height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(999))),
            ),
            FractionallySizedBox(
              widthFactor: playedFraction,
              child: Container(height: 4, decoration: BoxDecoration(color: ppCoral, borderRadius: BorderRadius.circular(999))),
            ),
            Align(
              alignment: Alignment(playedFraction * 2 - 1, 0),
              child: Container(
                width: 13, height: 13,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x55000000), blurRadius: 4)]),
              ),
            ),
          ]),
        ),
      );
    });
  }

  Widget _completeLayer() => DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xCC1A1030)),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 58, height: 58, alignment: Alignment.center,
              decoration: BoxDecoration(color: ppCoral, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 14),
            Text('Lesson complete', style: ppJakarta(17, color: Colors.white)),
            const SizedBox(height: 16),
            Row(mainAxisSize: MainAxisSize.min, children: [
              _pillBtn(Icons.replay_rounded, 'Replay', _replay, filled: false),
              if (widget.onNext != null) ...[
                const SizedBox(width: 12),
                _pillBtn(Icons.skip_next_rounded, 'Next lesson', widget.onNext!, filled: true),
              ],
            ]),
          ]),
        ),
      );

  Widget _errorLayer() => DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xE61A1030)),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white70, size: 34),
            const SizedBox(height: 12),
            Text('Couldn’t load this lesson', style: ppJakarta(15, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Check your connection and try again.', style: ppBody(12.5, color: Colors.white70)),
            const SizedBox(height: 16),
            _pillBtn(Icons.refresh_rounded, 'Retry', _retry, filled: true),
          ]),
        ),
      );

  // ---- small pieces -------------------------------------------------------
  Widget _roundBtn(IconData i, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 36, height: 36, alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.32), shape: BoxShape.circle),
          child: Icon(i, size: 19, color: Colors.white),
        ),
      );

  Widget _seekBtn(IconData i, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 48, height: 48, alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.28), shape: BoxShape.circle),
          child: Icon(i, size: 26, color: Colors.white),
        ),
      );

  Widget _iconBtn(IconData i, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(padding: const EdgeInsets.all(4), child: Icon(i, size: 21, color: Colors.white)),
      );

  Widget _pillBtn(IconData i, String label, VoidCallback onTap, {required bool filled}) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: filled ? ppCoral : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: filled ? null : Border.all(color: Colors.white54),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(i, size: 17, color: Colors.white),
            const SizedBox(width: 7),
            Text(label, style: ppBody(13, color: Colors.white, w: FontWeight.w700)),
          ]),
        ),
      );

  String _fmt(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  String _rateLabel(double r) => r == r.roundToDouble() ? r.toInt().toString() : r.toString();
}

// ---- spinner ---------------------------------------------------------------
class _Spinner extends StatelessWidget {
  const _Spinner();
  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 34, height: 34,
        child: CircularProgressIndicator(strokeWidth: 2.6, valueColor: AlwaysStoppedAnimation(Colors.white)),
      );
}

// ---- fallback poster -------------------------------------------------------
class _PvVideoPoster extends StatelessWidget {
  const _PvVideoPoster({required this.video, required this.loading, required this.fullscreen});
  final WatchVideo video;
  final bool loading;
  final bool fullscreen;

  @override
  Widget build(BuildContext context) {
    final content = Stack(children: [
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [const Color(0xFF3A2A55), ppPurple.withValues(alpha: 0.85)],
            ),
          ),
        ),
      ),
      Positioned(
        top: 8, left: 8,
        child: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 34, height: 34, alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.28), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_rounded, size: 18, color: Colors.white),
          ),
        ),
      ),
      Center(
        child: loading
            ? const _Spinner()
            : Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 62, height: 62, alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded, color: ppPurple, size: 34),
                ),
                const SizedBox(height: 12),
                Text(video.durationLabel, style: ppBody(11.5, color: Colors.white, w: FontWeight.w700)),
              ]),
      ),
    ]);
    return fullscreen ? SizedBox.expand(child: content) : AspectRatio(aspectRatio: 16 / 9, child: content);
  }
}
