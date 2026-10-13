// =============================================================================
//  Parenting · the phase film, pregnancy's format (2026-10-07)
// -----------------------------------------------------------------------------
//  The user: "have a figured layout, format and structure for this phase,
//  explained the videos that we play into it ... I don't want inconsistency".
//
//  Pregnancy's home shows its film one way (home_v3_screen.dart, V3WeekFilm):
//  a serif heading "Your week, explained" with no eyebrow; the film edge to
//  edge, 16:9, a poster that becomes the player IN PLACE (no new screen);
//  then the film's title and "Why this matters now". Parenting pushed a
//  padded card to a player screen. This is the same format for a phase:
//  same poster, same in-place player, same two lines under it. Only the label
//  differs ("PHASE 4 FILM").
//
//  V3WeekFilm takes pregnancy's PvVideo; parenting's films are WatchVideo, so
//  this is its twin rather than a conversion. The parenting player's default
//  repository (LocalWatchRepository) already keeps progress for WatchVideo.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import '../../theme/pv_fonts.dart';
import '../reader/pv_reader_screen.dart';
import 'pp_age_page_parts.dart' show kPpPhaseSources;
import 'pp_phases_data.dart' show AgePhase;
import '../../data/pp_phase_docs.dart' show ppPhaseDocFor;
import 'pp_phase_doc_reads.dart' show ppOpenPhaseDocRead;
import '../v2/v2_palette.dart';
import '../v2/v2_sections.dart' show v2CoverTint;
import 'pp_watch_data.dart' show WatchVideo;
import 'video/pv_video_config.dart' show pvCanPlayNatively;
import 'video/pv_video_player.dart';

class PpPhaseFilm extends StatefulWidget {
  const PpPhaseFilm({super.key, required this.video, required this.phase, required this.p, this.onUnavailable});
  final WatchVideo video;
  final int phase;
  final V2Palette p;

  /// When no file can play here, the poster opens this (the Watch library).
  final VoidCallback? onUnavailable;

  @override
  State<PpPhaseFilm> createState() => _PpPhaseFilmState();
}

class _PpPhaseFilmState extends State<PpPhaseFilm> {
  bool _playing = false;

  @override
  void didUpdateWidget(PpPhaseFilm old) {
    super.didUpdateWidget(old);
    // A different phase's film is a different film: back to its poster.
    if (old.video.id != widget.video.id) _playing = false;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final canPlay = pvCanPlayNatively(widget.video);
    if (_playing && canPlay) {
      return PvVideoPlayer(video: widget.video, inline: true, autoStart: true);
    }
    final tint = v2CoverTint('video-${widget.video.id}', p);
    final deep = HSLColor.fromColor(tint).withLightness(0.74).toColor();
    return InkWell(
      key: const ValueKey('pp_phase_film'),
      onTap: canPlay ? () => setState(() => _playing = true) : widget.onUnavailable,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(fit: StackFit.expand, children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(center: const Alignment(0.8, -0.9), radius: 1.4, colors: [tint, deep]),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 20,
            child: Text(canPlay ? 'PHASE ${widget.phase} FILM' : 'PHASE ${widget.phase} FILM · ARRIVING',
                style: pvManrope(
                    fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: p.ink1.withValues(alpha: 0.4))),
          ),
          if (canPlay)
            Center(
              child: Container(
                width: 68,
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.ink1,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: p.ink1.withValues(alpha: 0.34), blurRadius: 22, offset: const Offset(0, 8))],
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.play_arrow_rounded, size: 34, color: Colors.white),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

/// The two lines under the film, as pregnancy draws them.
class PpPhaseFilmCaption extends StatelessWidget {
  const PpPhaseFilmCaption({super.key, required this.video, required this.p});
  final WatchVideo video;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(video.title,
            style: pvFraunces(fontSize: 17, letterSpacing: -0.43, fontWeight: FontWeight.w600, height: 1.25, color: p.ink1)),
        if (video.why.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          // 14, the home's one body size (2026-10-07). Was 13.
          Text('Why this matters now: ${video.why}', style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
        ],
      ]);
}

// =============================================================================
//  The full phase, in the one reader (2026-10-07)
// -----------------------------------------------------------------------------
//  The user: "Under This phase explained it's very text heavy, like text
//  thrown. Segregate it." The home now shows the summary and three short
//  labelled points; everything else the phase says moves here, behind "Read
//  the full description", rather than being cut. One reader (CLAUDE.md): the
//  phase is an older seed model, so it reaches PvReaderScreen as a PvRead.
//  Every word the old in-place expansion showed is in this read, plus the
//  doctor lines (as the callout), the screening note and the India note.
// =============================================================================

LocalizedText _same(String s) => LocalizedText(en: s, hi: s);

/// The phase as a read: summary first, the reassurance as the scale-setter,
/// what the child is working on, every section, the screening and India
/// notes; "When to call the doctor" becomes the closing callout.
PvRead ppPhaseAsRead(AgePhase phase) {
  PvCallout? doctor;
  final sections = <PvReadSection>[
    if (phase.workingOn.isNotEmpty)
      PvReadSection(heading: _same('Working on now'), bullets: [for (final w in phase.workingOn) _same(w)]),
  ];
  for (final s in phase.sections) {
    if (s.heading.toLowerCase() == 'when to call the doctor') {
      doctor = PvCallout(
          tone: PvCalloutTone.urgent, title: _same('When to call the doctor'), body: _same(s.paragraphs.join(' ')));
      continue;
    }
    sections.add(PvReadSection(heading: _same(s.heading), paragraphs: [for (final x in s.paragraphs) _same(x)]));
  }
  if (phase.screeningNote case final n?) {
    sections.add(PvReadSection(heading: _same('Screening at this age'), paragraphs: [_same(n)]));
  }
  if (phase.indianNote case final n?) {
    sections.add(PvReadSection(heading: _same('In India'), paragraphs: [_same(n)]));
  }
  return PvRead(
    id: 'pp_phase_${phase.number}',
    kicker: _same('This phase · ${phase.ageLabel}'),
    title: _same(phase.name),
    teaser: _same(phase.summary),
    scaleSetter: _same(phase.reassurance),
    author: _same('ParentVeda editorial'),
    authorRole: _same(phase.source),
    reviewed: false,
    hue: 268,
    sections: sections,
    whenToSeeSomeone: doctor ?? kPvShortPieceCallout,
    faqs: const [],
    evidence: _same(kPpPhaseSources.replaceFirst('Where this comes from: ', '')),
  );
}

/// Opens the full phase in the reader — the phase doc's page where the phase
/// has one (2026-10-13, the doc is the source of truth), else the older read.
void ppOpenPhaseRead(BuildContext context, AgePhase phase) {
  if (ppPhaseDocFor(phase.number) case final doc?) {
    ppOpenPhaseDocRead(context, doc, phase);
    return;
  }
  _openAuthoredPhaseRead(context, phase);
}

void _openAuthoredPhaseRead(BuildContext context, AgePhase phase) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: 'pp/phase_read/${phase.number}'),
      builder: (_) => PvReaderScreen(read: ppPhaseAsRead(phase), lang: AppLanguage.english),
    ));
