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

import '../../screens/products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;
import '../../screens/ttc/doors/ttc_tab_art.dart' show ttcTabGround, ttcTabInk;
import '../../screens/v2/v2_palette.dart' show V2PaletteStore, v2BlockTint;
import '../../services/raga_audio_store.dart';
import '../../theme/app_theme.dart';
import '../../theme/pv_fonts.dart';
import '../pv_feedback.dart' show PvPress;

class RagaPlayer extends StatefulWidget {
  const RagaPlayer({
    super.key,
    required this.title,
    required this.subtitle,
    this.asset = 'audio/raga_drone.wav',
    this.isFile = false,
    this.isUrl = false,
    this.loop = true,
    this.onFinished,
    this.large = false,
    this.credit,
    this.coverHue = 42,
    this.showTitle = false,
    this.onPrevious,
    this.onNext,
    this.autoplay = false,
  });

  // ---- The now-playing layout (2026-10-15, the Garbh pillars pass) -------
  // The user: Shravan "looks off"; it should feel like "the audio playing
  // applications, music playing applications". From the Mobbin look at
  // Spotify, Shazam, Deezer, SiriusXM and Calm's now-playing: a big square
  // cover, the title and the artist under it, a scrubber with times, and the
  // play as one large disc between previous and next. Only the large card
  // changes; the small one is as it was.

  /// The recordist and piece, shown under the title like an artist line.
  final String? credit;

  /// The cover's tone (`shravanHueFor(id)`), so each raga has its own.
  final double coverHue;

  /// The daily screen's hero already names the raga, so it passes false
  /// there; the full player passes true.
  final bool showTitle;

  /// Previous / next raga. Null hides them: the daily screen plays ONE track,
  /// and a control that leads nowhere is a choice she does not need.
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  /// Start playing on arrival (the full player after previous / next, so
  /// moving to the next raga keeps the music going, as every player does).
  final bool autoplay;

  final String title;
  final String subtitle;

  /// The session layout (2026-10-02, Oura's and Noom's audio sessions): one big
  /// ink play disc under a row of moving bars, the scrubber and the two times
  /// below it, on a white card with the page hairline. The title and subtitle
  /// are not repeated here; the screen above already says them. Off by default,
  /// so the three other places this player draws are as they were.
  final bool large;

  /// A bundled asset path by default; a device file or a URL when the caller
  /// says so (Shravan's manifest tracks). See `RagaAudioStore.toggle`.
  final String asset;
  final bool isFile;
  final bool isUrl;

  /// The drone loops; a real track ends. "Finishes on its own when the track
  /// ends" is the SHARED block's rule, and `onFinished` depends on it.
  final bool loop;

  /// ⚠️ FIRES WHEN THE TRACK REACHES ITS END, NOT WHEN PLAY IS PRESSED.
  ///
  /// This is how Garbh Sanskar's completion rule is actually implemented for
  /// Shravan: a practice completes because it was DONE, never because it was
  /// claimed. Pressing play and immediately leaving must not count, or the
  /// section is back to issuing receipts for nothing.
  ///
  /// Fired at most once per mount, so a woman who replays a track does not
  /// write the same listen into her journal five times.
  final VoidCallback? onFinished;

  @override
  State<RagaPlayer> createState() => _RagaPlayerState();
}

class _RagaPlayerState extends State<RagaPlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _eq;

  /// Once per mount. See `RagaPlayer.onFinished`.
  bool _firedFinished = false;

  RagaAudioStore get _audio => RagaAudioStore.instance;

  /// ⚠️ "NEAR THE END" RATHER THAN EXACTLY AT IT, and the tolerance is not
  /// laziness. Position reporting on both platforms lands a little short of
  /// the reported duration, so an equality check fires for some tracks and
  /// never for others - which would make completion depend on which raga she
  /// happened to pick.
  void _checkFinished(Duration pos, Duration dur) {
    if (_firedFinished || widget.onFinished == null) return;
    if (dur.inMilliseconds <= 0) return;
    if (pos.inMilliseconds < dur.inMilliseconds - 900) return;
    _firedFinished = true;
    // Off this frame: the callback writes to a store, and notifying listeners
    // during a build is what turns a completion into a crash.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.onFinished?.call());
  }

  @override
  void initState() {
    super.initState();
    _eq = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    if (widget.autoplay) {
      // After the outgoing player has let go of its track (its dispose stops
      // it a frame later), so the two never fight over the one player.
      Future<void>.delayed(const Duration(milliseconds: 160), () {
        if (mounted && !_audio.isPlayingAsset(widget.asset)) _toggle();
      });
    }
  }

  /// What the disc shows the instant she taps it, before the platform
  /// reports back: the tap answers the finger, not the audio engine.
  bool? _want;

  void _toggle() {
    setState(() => _want = !(_want ?? _audio.isPlayingAsset(widget.asset)));
    _audio.toggle(widget.asset,
        title: widget.title,
        isFile: widget.isFile,
        isUrl: widget.isUrl,
        loop: widget.loop);
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
      final mine = widget.asset;
      // Only if it is still THIS track a frame later: on previous / next the
      // incoming player may already have taken the store over.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (store.owns(mine)) store.stop();
      });
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

  /// The session layout: bars, one big ink disc, the scrubber and the times.
  Widget _largeCard(BuildContext context, bool playing, Duration position,
      Duration duration, double totalSecs, double posSecs) {
    final p = pvStorePalette;
    if (_want != null && _want == playing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _want = null);
      });
    }
    final shown = _want ?? playing;
    final tint = v2BlockTint(widget.coverHue % 360, V2PaletteStore.instance.current);
    final left = duration - position;
    Widget roundCtl(String label, IconData icon, VoidCallback? onTap, Key key) =>
        Semantics(
          button: true,
          label: label,
          child: PvPress(
            child: GestureDetector(
              key: key,
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: SizedBox(
                width: 56,
                height: 56,
                child: Icon(icon, size: 32, color: kPvInk),
              ),
            ),
          ),
        );
    return SizedBox(
      key: const ValueKey('raga_player_large'),
      width: double.infinity,
      child: Column(
      children: [
        // The cover: the track's tone, its sound bars moving while it plays.
        LayoutBuilder(builder: (context, box) {
          final side = math.min(box.maxWidth, 280.0);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            width: side,
            height: side,
            decoration: BoxDecoration(
              color: ttcTabGround(tint),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: shown ? 0.10 : 0.05),
                  blurRadius: shown ? 22 : 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: _Equalizer(
                animation: _eq,
                active: playing,
                width: side * 0.5,
                height: side * 0.34,
                bars: 9,
                barWidth: side * 0.032,
                color: ttcTabInk(tint)),
          );
        }),
        const SizedBox(height: 20),
        if (widget.showTitle)
          Text(widget.title,
              textAlign: TextAlign.center,
              style: pvFraunces(
                  fontSize: 24, fontWeight: FontWeight.w600, height: 1.15, color: kPvInk)),
        if (widget.credit != null && widget.credit!.trim().isNotEmpty) ...[
          if (widget.showTitle) const SizedBox(height: 6),
          Text(widget.credit!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2)),
        ],
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: kPvInk,
            inactiveTrackColor: kPvLine,
            thumbColor: kPvInk,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: posSecs.clamp(0, totalSecs <= 0 ? 1 : totalSecs),
            max: totalSecs <= 0 ? 1 : totalSecs,
            onChanged: (v) =>
                _audio.seek(widget.asset, Duration(milliseconds: (v * 1000).round())),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(position),
                  style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink3)),
              Text('-${_fmt(left.isNegative ? Duration.zero : left)}',
                  style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink3)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (widget.onPrevious != null) ...[
            roundCtl('Previous raga', Icons.skip_previous_rounded, widget.onPrevious,
                const ValueKey('raga_prev')),
            const SizedBox(width: 22),
          ],
          Semantics(
            button: true,
            label: shown ? 'Pause' : 'Play',
            child: PvPress(child: GestureDetector(
              key: const ValueKey('raga_play'),
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              child: Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(color: kPvInk, shape: BoxShape.circle),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: Icon(shown ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      key: ValueKey(shown), color: Colors.white, size: 42),
                ),
              ),
            )),
          ),
          if (widget.onNext != null) ...[
            const SizedBox(width: 22),
            roundCtl('Next raga', Icons.skip_next_rounded, widget.onNext,
                const ValueKey('raga_next')),
          ],
        ]),
      ],
      ),
    );
  }

  // Kept for revert (2026-10-15): the white card with 15 bars over an 84px
  // disc, a slider and two times.
  // ignore: unused_element
  Widget _largeCardV1(BuildContext context, bool playing, Duration position,
      Duration duration, double totalSecs, double posSecs) {
    final p = pvStorePalette;
    return Container(
      key: const ValueKey('raga_player_large_v1'),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kPvLine),
      ),
      child: Column(children: [
        _Equalizer(
            animation: _eq,
            active: playing,
            width: 150,
            height: 34,
            bars: 15,
            color: kPvInk.withValues(alpha: playing ? 0.85 : 0.25)),
        const SizedBox(height: 18),
        Semantics(
          button: true,
          label: playing ? 'Pause' : 'Play',
          child: PvPress(child: GestureDetector(
            key: const ValueKey('raga_play'),
            onTap: () => _audio.toggle(widget.asset,
                title: widget.title,
                isFile: widget.isFile,
                isUrl: widget.isUrl,
                loop: widget.loop),
            child: Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(color: kPvInk, shape: BoxShape.circle),
              child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white, size: 46),
            ),
          )),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: kPvInk,
            inactiveTrackColor: kPvLine,
            thumbColor: kPvInk,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: posSecs.clamp(0, totalSecs <= 0 ? 1 : totalSecs),
            max: totalSecs <= 0 ? 1 : totalSecs,
            onChanged: (v) =>
                _audio.seek(widget.asset, Duration(milliseconds: (v * 1000).round())),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(position),
                  style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink3)),
              Text(_fmt(duration),
                  style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink3)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _card(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final playing = _audio.isPlayingAsset(widget.asset);
    final position = _audio.positionFor(widget.asset);
    final duration = _audio.durationFor(widget.asset);
    final totalSecs = duration.inMilliseconds / 1000.0;
    final posSecs = position.inMilliseconds / 1000.0;
    _checkFinished(position, duration);

    if (widget.large) {
      return _largeCard(context, playing, position, duration, totalSecs, posSecs);
    }
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
              PvPress(child: GestureDetector(
                onTap: () => _audio.toggle(widget.asset,
                    title: widget.title,
                    isFile: widget.isFile,
                    isUrl: widget.isUrl,
                    loop: widget.loop),
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
              )),
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
  const _Equalizer({
    required this.animation,
    required this.active,
    this.width = 30,
    this.height = 26,
    this.bars = 5,
    this.color,
    this.barWidth = 3.5,
  });

  final double barWidth;

  final Animation<double> animation;
  final bool active;
  final double width;
  final double height;
  final int bars;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(bars, (i) {
              final base = active
                  ? (0.35 +
                      0.65 *
                          (0.5 +
                              0.5 *
                                  math.sin(
                                      animation.value * 2 * math.pi + i * 1.1)))
                  : 0.28;
              return Container(
                width: barWidth,
                height: height * base.clamp(0.12, 1.0),
                decoration: BoxDecoration(
                  color: color ?? AppTheme.primary400,
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
