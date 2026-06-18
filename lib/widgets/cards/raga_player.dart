// =============================================================================
//  RagaPlayer
// -----------------------------------------------------------------------------
//  Reusable, self-contained audio player for the bundled tanpura-style drone
//  (assets/audio/raga_drone.wav), looped. Play/pause, live equalizer, seek bar
//  and timer. Audio is a gentle enhancement — failures never crash the card.
// =============================================================================

import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class RagaPlayer extends StatefulWidget {
  const RagaPlayer({
    super.key,
    required this.title,
    required this.subtitle,
    this.asset = 'audio/raga_drone.wav',
  });

  final String title;
  final String subtitle;
  final String asset;

  @override
  State<RagaPlayer> createState() => _RagaPlayerState();
}

class _RagaPlayerState extends State<RagaPlayer>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _player;
  late final AnimationController _eq;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<PlayerState>? _stateSub;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(seconds: 12);

  @override
  void initState() {
    super.initState();
    _eq = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.loop);

    _durSub = _player.onDurationChanged.listen((d) {
      if (mounted && d > Duration.zero) setState(() => _duration = d);
    });
    _posSub = _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _stateSub = _player.onPlayerStateChanged.listen((st) {
      if (mounted) setState(() => _isPlaying = st == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _eq.dispose();
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    try {
      if (_isPlaying) {
        await _player.pause();
      } else if (_position > Duration.zero) {
        await _player.resume();
      } else {
        await _player.play(AssetSource(widget.asset));
      }
    } catch (_) {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  Future<void> _seek(double seconds) async {
    final target = Duration(milliseconds: (seconds * 1000).round());
    setState(() => _position = target);
    try {
      await _player.seek(target);
    } catch (_) {/* ignore */}
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final totalSecs = _duration.inMilliseconds / 1000.0;
    final posSecs = _position.inMilliseconds / 1000.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _toggle,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppTheme.primary500,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary500.withValues(alpha: 0.32),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: text.titleMedium),
                    Text(widget.subtitle, style: text.bodySmall),
                  ],
                ),
              ),
              _Equalizer(animation: _eq, active: _isPlaying),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: posSecs.clamp(0, totalSecs <= 0 ? 1 : totalSecs),
              max: totalSecs <= 0 ? 1 : totalSecs,
              onChanged: _seek,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(_position), style: text.labelSmall),
                Text(_fmt(_duration), style: text.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Equalizer extends StatelessWidget {
  const _Equalizer({required this.animation, required this.active});

  final Animation<double> animation;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 26,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              final base = active
                  ? (0.35 +
                      0.65 *
                          (0.5 +
                              0.5 *
                                  math.sin(
                                      animation.value * 2 * math.pi + i * 1.1)))
                  : 0.28;
              return Container(
                width: 3.5,
                height: 26 * base.clamp(0.12, 1.0),
                decoration: BoxDecoration(
                  color: AppTheme.primary400,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
