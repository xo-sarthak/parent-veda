// =============================================================================
//  Shravan — the track player that reads the manifest, and the credits
// -----------------------------------------------------------------------------
//  Shravan to final, from the Garbh Sanskar pillars brief, 12 Sep 2026. Two
//  things the pillar gained:
//
//  `ShravanTrackPlayer` — one widget the daily screen and the library detail
//  both draw. It asks `ShravanLibrary` what plays for a track (a cached file,
//  else the URL, else nothing) and draws `RagaPlayer` on that, with the
//  recordist's credit under it and a "Save for offline" pill. When the
//  manifest has no entry, it draws exactly what shipped before — the drone
//  and the honest "sample" line — so a missing track is a missing track, not
//  a broken screen. The guided track is a script, not a file: for it this
//  draws a Begin card that opens the relaxation session.
//
//  `ShravanCreditsScreen` — every track's recordist, licence and source page.
//  The brief asks for this only when a CC-BY track is used; every track here
//  is a public-domain dedication, and the credits are shown anyway. A person
//  made each of these and released it; saying so costs one screen.
//
//  ⚠️ STREAM, THEN CACHE. First play streams (she hears it now); the same
//  press starts the download for next time. See `ShravanLibrary`.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/garbh_rebuild_data.dart';
import '../data/kriya_relaxation_data.dart';
import '../localization/app_language.dart';
import '../models/garbh_content.dart';
import '../services/garbh_store.dart';
import '../services/pregnancy_controller.dart';
import '../services/raga_audio_store.dart';
import '../services/shravan_library.dart';
import '../theme/pv_fonts.dart';
import '../widgets/cards/raga_player.dart';
import 'doors/pv_door_chrome.dart';
import 'garbh_relaxation_screen.dart';
import 'v2/v2_palette.dart';

const Color _ink = Color(0xFF201C24);
const Color _muted = Color(0xFF6F6878);
const Color _accShravan = Color(0xFFBE9C4E);

/// The player for one Shravan track, on whatever the manifest says it is.
///
/// ⚠️ STATEFUL, BECAUSE THE SOURCE MUST NOT CHANGE UNDER HER. First version
/// rebuilt the player on the cached file the moment the download landed,
/// keyed on the source — and the stream she was listening to stopped
/// mid-track (the old card's dispose stops what it owns; found on the phone,
/// 2026-09-13). The source is resolved ONCE per mount: the stream this time,
/// the file next time. A cache is for the next play, never the current one.
class ShravanTrackPlayer extends StatefulWidget {
  const ShravanTrackPlayer({
    super.key,
    required this.audio,
    required this.controller,

    /// Daily mode: finishing marks Shravan done and files "what your baby
    /// heard" into My Journal. Library mode: just listening.
    this.daily = false,
  });

  final GarbhAudio audio;
  final PregnancyController controller;
  final bool daily;

  @override
  State<ShravanTrackPlayer> createState() => _ShravanTrackPlayerState();
}

class _ShravanTrackPlayerState extends State<ShravanTrackPlayer> {
  GarbhAudio get audio => widget.audio;
  PregnancyController get controller => widget.controller;
  bool get daily => widget.daily;

  /// Fixed the first time the library can answer; never changes after.
  ({String source, bool isFile})? _playable;

  void _finished() {
    if (!daily) return;
    GarbhStore.instance.markDone('shravan');
    GarbhJournalStore.instance.add(GarbhJournalEntry(
      id: 'heard_${audio.id}_${DateTime.now().microsecondsSinceEpoch}',
      kind: GarbhEntryKind.heard,
      week: controller.currentWeek,
      tsMs: DateTime.now().millisecondsSinceEpoch,
      title: audio.title,
      seconds: audio.minutes * 60,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;

    // The guided track is a narrated script, not a file.
    if (audio.kind == GarbhKind.guided) {
      return _BeginCard(
        title: audio.title.now,
        subtitle: '${audio.minutes} min · a voice walks you down your body',
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'garbh/listen/bodyscan'),
          builder: (_) => GarbhRelaxationScreen(
              pregnancy: controller,
              session: kKriyaBodyAwareness,
              daily: daily),
        )),
      );
    }

    final lib = ShravanLibrary.instance;
    lib.init();
    return AnimatedBuilder(
      animation: Listenable.merge([lib, RagaAudioStore.instance]),
      builder: (context, _) {
        final track = lib.trackFor(audio.id);
        // Resolved once; see the class doc. Until the manifest has loaded
        // this stays null and the drone draws, then the real player replaces
        // it — before she has pressed anything.
        final playable = _playable ??= lib.playableFor(audio.id);
        // ⚠️ THE FIRST PLAY IS THE DOWNLOAD. The stream she is hearing is
        // fetched again into the cache, so the second play needs no data.
        // "Save for offline" is the same call, made before pressing play.
        if (track != null &&
            playable != null &&
            !playable.isFile &&
            !lib.isCached(audio.id) &&
            !lib.isDownloading(audio.id) &&
            RagaAudioStore.instance.isPlayingAsset(playable.source)) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => lib.download(audio.id));
        }
        if (track == null || playable == null) {
          // As it shipped: the drone, and the line that says so.
          return Column(children: [
            RagaPlayer(
                title: audio.title.now,
                subtitle: '${audio.minutes} min',
                onFinished: _finished),
            const SizedBox(height: 8),
            Text(s.gsSampleAudio,
                textAlign: TextAlign.center,
                style: text.labelSmall?.copyWith(color: _muted)),
          ]);
        }
        final cached = lib.isCached(audio.id);
        final downloading = lib.isDownloading(audio.id);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RagaPlayer(
            title: track.title,
            subtitle: '${track.minutes} min',
            asset: playable.source,
            isFile: playable.isFile,
            isUrl: !playable.isFile,
            loop: false,
            onFinished: _finished,
          ),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Text(track.attribution,
                  style: pvManrope(fontSize: 11.5, height: 1.4, color: _muted)),
            ),
            const SizedBox(width: 10),
            _OfflinePill(
              cached: cached,
              downloading: downloading,
              onTap: () =>
                  cached ? lib.removeDownload(audio.id) : lib.download(audio.id),
            ),
          ]),
        ]);
      },
    );
  }
}

class _OfflinePill extends StatelessWidget {
  const _OfflinePill(
      {required this.cached, required this.downloading, required this.onTap});
  final bool cached;
  final bool downloading;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final label = downloading
        ? 'Saving…'
        : cached
            ? 'Saved offline'
            : 'Save for offline';
    return GestureDetector(
      onTap: downloading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: cached ? _accShravan.withValues(alpha: 0.14) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: cached ? _accShravan : const Color(0x14000000)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
              cached
                  ? Icons.download_done_rounded
                  : Icons.download_for_offline_outlined,
              size: 15,
              color: cached ? _accShravan : _muted),
          const SizedBox(width: 5),
          Text(label,
              style: pvManrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: cached ? _accShravan : _ink)),
        ]),
      ),
    );
  }
}

class _BeginCard extends StatelessWidget {
  const _BeginCard(
      {required this.title, required this.subtitle, required this.onTap});
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: _accShravan.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
            child: Row(children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                    color: _accShravan, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: pvManrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _ink)),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          style: pvManrope(
                              fontSize: 12, height: 1.4, color: _muted)),
                    ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: _muted),
            ]),
          ),
        ),
      );
}

/// Every track: who made it, under what, and where.
class ShravanCreditsScreen extends StatelessWidget {
  const ShravanCreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final lib = ShravanLibrary.instance;
    lib.init();
    return AnimatedBuilder(
      animation: lib,
      builder: (context, _) => PvDoorToolScaffold(
        hue: 42,
        eyebrow: 'Shravan',
        title: 'Where these sounds come from',
        intro: 'Each track was recorded by a real person and shared for '
            'anyone to use. Here are their names, and where to find the '
            'originals.',
        children: [
          for (final t in lib.tracks) ...[
            pvDoorPad(Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: p.line),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title,
                        style: pvFraunces(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: p.ink1)),
                    const SizedBox(height: 6),
                    Text(t.attribution,
                        style: pvManrope(
                            fontSize: 13, height: 1.5, color: p.ink1)),
                    if (t.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(t.note,
                          style: pvManrope(
                              fontSize: 12, height: 1.45, color: p.ink2)),
                    ],
                    const SizedBox(height: 8),
                    Text('${t.licence} · ${t.minutes} min · ${t.sourceUrl}',
                        style: pvManrope(
                            fontSize: 11, height: 1.4, color: p.ink3)),
                  ]),
            )),
            const SizedBox(height: 10),
          ],
          if (lib.isLoaded && lib.tracks.isEmpty)
            pvDoorPad(Text(
                'No tracks are listed yet. A soft drone plays in their '
                'place.',
                style: pvManrope(fontSize: 13, color: p.ink2))),
          const SizedBox(height: 8),
          pvDoorPad(Text(
              "Body Awareness isn't a recording. It's a written script, read "
              "aloud by the app's own voice.",
              style: pvManrope(fontSize: 12, height: 1.5, color: p.ink3))),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
