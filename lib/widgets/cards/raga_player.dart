// =============================================================================
//  RagaPlayer
// -----------------------------------------------------------------------------
//  The controls for the bundled tanpura-style drone (assets/audio/raga_drone.wav),
//  looped: play/pause, live equalizer, seek bar and timer. Audio is a gentle
//  enhancement - failures never crash the card.
//
//  ⚠️ IT USED TO SAY "REUSABLE, SELF-CONTAINED AUDIO PLAYER", AND
//  SELF-CONTAINED WAS THE BUG.
//
//  Four of these exist - the daily home module, the week card, the daily Shravan
//  screen and the Shravan library detail - and each one built its own
//  `AudioPlayer` in `initState`. Four players, four `_isPlaying` flags, one pair
//  of speakers. Play on the home card, walk into Shravan, press play there, and
//  two drones loop at once; press pause on the one in front of you and the sound
//  carries on, because what you can hear is the other one. Reported as:
//
//    "when I play Garbh Sankar Music there is no option to pause it."
//
//  The pause button was always there. It was pausing a different player.
//
//  ⚠️ SO THIS IS NOW A VIEW, NOT AN OWNER. The player lives in
//  `RagaAudioStore` - one for the app - and this widget renders its state and
//  forwards taps. Read the header of that file for why sound cannot be owned by a
//  widget; the short version is that a widget may own a scroll offset and may not
//  own a speaker.
//
//  What is still local: the equalizer's `AnimationController`. That genuinely is
//  per-card - two visible cards should each animate - and it drives no state
//  anyone can hear.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/raga_audio_store.dart';
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
  late final AnimationController _eq;

  RagaAudioStore get _audio => RagaAudioStore.instance;

  @override
  void initState() {
    super.initState();
    _eq = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _eq.dispose();
    // ⚠️ STOP THE SOUND IF THIS CARD WAS THE ONE PLAYING IT.
    //
    // The store outlives the widget, which is the point of it and also the one
    // new hazard it introduces: without this, leaving the screen would leave a
    // drone looping with no visible control anywhere - the original bug, worse.
    //
    // Guarded by `owns`, so a card scrolling away does not stop a different
    // card's audio. And scheduled off this frame because `dispose` runs during
    // teardown, where `notifyListeners` would rebuild widgets mid-unmount.
    if (_audio.owns(widget.asset)) {
      final store = _audio;
      WidgetsBinding.instance.addPostFrameCallback((_) => store.stop());
    }
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ LISTENING, NOT READING. `AnimatedBuilder` on the store is what
    // makes the OTHER card's icon flip back to a play triangle the moment this
    // one starts - which is the visible half of the fix. Reading
    // `RagaAudioStore.instance` without subscribing would leave two cards both
    // showing a pause icon, and only one of them telling the truth.
    return AnimatedBuilder(
      animation: _audio,
      builder: (context, _) => _card(context),
    );
  }

  Widget _card(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final playing = _audio.isPlayingAsset(widget.asset);
    final position = _audio.positionFor(widget.asset);
    final duration = _audio.durationFor(widget.asset);
    final totalSecs = duration.inMilliseconds / 1000.0;
    final posSecs = position.inMilliseconds / 1000.0;

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
                onTap: () => _audio.toggle(widget.asset),
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
                    playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
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
              _Equalizer(animation: _eq, active: playing),
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
              onChanged: (v) => _audio.seek(widget.asset,
                  Duration(milliseconds: (v * 1000).round())),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(position), style: text.labelSmall),
                Text(_fmt(duration), style: text.labelSmall),
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
