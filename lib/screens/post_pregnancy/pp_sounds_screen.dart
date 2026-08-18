// =============================================================================
//  PpSoundsScreen — the Sleep Sounds player
// -----------------------------------------------------------------------------
//  ⚠️ THE SPEC'S CONTROLS, AND WHY EACH ONE IS SHAPED THE WAY IT IS:
//
//    "Controls: sleep timer (default ON), loop, offline play, and a safe default
//     volume that is not loud."
//
//  * **Sleep timer, on by default.** Owned by `RagaAudioStore`, not by this
//    screen, because she puts the phone down and the screen goes away. See that
//    file's note. On by default because the safe choice must not be the one she
//    has to find at 2am.
//  * **Loop.** `RagaAudioStore` already sets `ReleaseMode.loop`. A six-minute lori
//    that stops dead is worse than no lori: the silence wakes her.
//  * **Volume.** ⚠️ NOT A SLIDER IN THIS SCREEN. Android and iOS both own volume
//    at the OS level, and an in-app slider multiplies against the hardware volume
//    so the same "40%" is a different loudness on every phone — which is exactly
//    the wrong property for the one control that has a safety story. What this
//    screen does instead is say the true thing plainly, once, where she will read
//    it. Flagged in the report as a real gap if a genuine in-app cap is wanted.
//  * **Offline.** The tracks are bundled assets, so offline is a property of
//    shipping them in the app rather than a feature to build. True the moment
//    real files land.
//
//  ⚠️ AND THE THING THIS SCREEN MUST NOT BECOME: a music app. No favourites, no
//  play counts, no "most played". The Sleep spec's rule for its trackers applies
//  here for the same reason — "it must never become an anxiety tool" — and a
//  parent who can see she played the womb sound 40 times this week has been handed
//  a number to feel bad about.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/raga_audio_store.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_content.dart';
import 'pp_sounds_data.dart';

class PpSoundsScreen extends StatefulWidget {
  const PpSoundsScreen({super.key});

  @override
  State<PpSoundsScreen> createState() => _PpSoundsScreenState();
}

class _PpSoundsScreenState extends State<PpSoundsScreen> {
  RagaAudioStore get _audio => RagaAudioStore.instance;

  @override
  void initState() {
    super.initState();
    // ⚠️ THE DEFAULT IS ARMED ON ARRIVAL, not on first play. If it were set when
    // she pressed play, the very first tap would race the arming and the timer
    // she was promised would sometimes not exist.
    if (_audio.sleepAfter == null) {
      _audio.setSleepTimer(RagaAudioStore.kDefaultSleepTimer);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) =>
            _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) => Scaffold(
        backgroundColor: p.ground,
        body: SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: _audio,
            builder: (context, _) => Column(children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  children: [
                    ppV3Back(context, p),
                    const SizedBox(height: 18),
                    Text('Sounds for sleep',
                        style: pvFraunces(fontSize: 27, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
                    const SizedBox(height: 9),
                    Text(
                        'Lullabies, steady sound, and a few slow stories. '
                        'Everything here is free.',
                        style: pvManrope(fontSize: 15, fontWeight: FontWeight.w500, height: 1.6, color: p.ink2)),

                    // ---- the volume truth, said once, where she reads it ----
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
                      decoration: BoxDecoration(
                        color: p.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: p.line),
                      ),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.volume_down_rounded,
                                size: 18, color: p.action),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                  'Keep it low, and keep the phone off the bed. '
                                  'Quiet enough that you can still hear her '
                                  'breathing is about right.',
                                  style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.6, color: p.ink1)),
                            ),
                          ]),
                    ),

                    // ---- the sleep timer ------------------------------------
                    const SizedBox(height: 14),
                    _TimerRow(
                      current: _audio.sleepAfter,
                      onPick: _audio.setSleepTimer,
                    ),

                    const SizedBox(height: 30),
                    for (final c in kPpSoundCategories) ...[
                      _CategoryBlock(
                        category: c,
                        audio: _audio,
                        onPlay: _play,
                      ),
                      const SizedBox(height: 28),
                    ],
                  ],
                ),
              ),

              // ⚠️ THE NOW-PLAYING BAR IS THE PAUSE SHE CAN ALWAYS REACH. The
              // whole reason `RagaAudioStore` exists is a report that there was
              // no way to pause; a bar pinned outside the scroll view is what
              // makes that structurally true rather than true-if-you-scroll-back.
              if (_audio.asset != null)
                _NowPlaying(
                  audio: _audio,
                  onToggle: () => _audio.toggle(_audio.asset!),
                  onStop: _audio.stop,
                ),
            ]),
          ),
        ),
      );

  void _play(PpSoundTrack t) {
    final asset = t.asset;
    // A track with no file does nothing, visibly — the row already says COMING
    // SOON rather than offering a play button.
    if (asset == null) return;
    _audio.toggle(asset, title: t.title);
  }
}

/// The sleep-timer chooser. Preset lengths, not a picker: at 2am a wheel is worse
/// than four buttons, and the exact minute has never mattered.
class _TimerRow extends StatelessWidget {
  const _TimerRow({required this.current, required this.onPick});

  final Duration? current;
  final void Function(Duration?) onPick;

  static const _options = <(String, Duration?)>[
    ('15 min', Duration(minutes: 15)),
    ('20 min', Duration(minutes: 20)),
    ('45 min', Duration(minutes: 45)),
    ('All night', null),
  ];

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.timer_outlined, size: 16, color: p.ink3),
            const SizedBox(width: 8),
            Text('Stops itself after',
                style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, height: 1.55, color: p.ink2)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            for (final (label, d) in _options) ...[
              Expanded(
                child: GestureDetector(
                  onTap: () => onPick(d),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: current == d ? p.action : p.surface,
                      borderRadius: BorderRadius.circular(999),
                      border:
                          Border.all(color: current == d ? p.action : p.line),
                    ),
                    child: Text(label,
                        style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
                  ),
                ),
              ),
              if (label != _options.last.$1) const SizedBox(width: 7),
            ],
          ]),
          // ⚠️ "All night" IS ALLOWED AND IT IS LABELLED HONESTLY. Removing the
          // option would be the abstinence version of this, and the Sleep spec is
          // explicit that abstinence framing gets ignored. Naming it plainly, next
          // to the volume line above, is harm reduction: she chooses it knowing
          // what she chose.
          if (current == null) ...[
            const SizedBox(height: 9),
            Text('It will keep playing until you stop it.',
                style: pvManrope(fontSize: 12, fontWeight: FontWeight.w500, height: 1.5, color: p.ink3)),
          ],
        ],
      );
  }
}
class _CategoryBlock extends StatelessWidget {
  const _CategoryBlock(
      {required this.category, required this.audio, required this.onPlay});

  final PpSoundCategory category;
  final RagaAudioStore audio;
  final void Function(PpSoundTrack) onPlay;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category.label, style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
          const SizedBox(height: 5),
          Text(category.blurb, style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
          const SizedBox(height: 13),
          for (final t in category.tracks) ...[
            _TrackRow(
              track: t,
              hue: category.hue,
              playing: t.asset != null && audio.isPlayingAsset(t.asset!),
              onTap: () => onPlay(t),
            ),
            const SizedBox(height: 8),
          ],
        ],
      );
  }
}
class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.track,
    required this.hue,
    required this.playing,
    required this.onTap,
  });

  final PpSoundTrack track;
  final double hue;
  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final live = track.isLive;
    return InkWell(
      onTap: live ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: playing ? p.action : p.line),
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ppTintFor(hue),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
                !live
                    ? Icons.graphic_eq_rounded
                    : playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                size: 22,
                color: p.action),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.title,
                      style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.55, color: p.ink1)),
                  if (track.note != null) ...[
                    const SizedBox(height: 3),
                    Text(track.note!,
                        style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.5, color: p.ink2)),
                  ],
                  const SizedBox(height: 5),
                  Text(
                      live
                          ? track.minutes
                          : '${track.minutes}  ·  COMING SOON',
                      style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, height: 1.55, color: p.ink3)
                          .copyWith(letterSpacing: 0.8)),
                ]),
          ),
        ]),
      ),
    );
  }
}

class _NowPlaying extends StatelessWidget {
  const _NowPlaying(
      {required this.audio, required this.onToggle, required this.onStop});

  final RagaAudioStore audio;
  final VoidCallback onToggle;
  final VoidCallback onStop;

  String _left() {
    final r = audio.sleepRemaining;
    if (r == null) return 'Playing until you stop it';
    final m = r.inMinutes;
    return m <= 0 ? 'Stopping now' : 'Stops in $m min';
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 12, 12 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: p.surface,
          border: Border(top: BorderSide(color: p.line)),
        ),
        child: Row(children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: p.action,
                shape: BoxShape.circle,
              ),
              child: Icon(
                  audio.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: p.surface,
                  size: 24),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(audio.title ?? 'Playing',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, height: 1.55, color: p.ink1)),
                  const SizedBox(height: 2),
                  Text(_left(), style: pvManrope(fontSize: 12, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
                ]),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onStop,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.close_rounded, size: 20, color: p.ink3),
            ),
          ),
        ]),
      );
  }
}
