// =============================================================================
//  The phase docs in the one reader — the phase page and the milestone pages
// -----------------------------------------------------------------------------
//  2026-10-13. The user's My Child phase docs (lib/data/pp_phase_docs.dart)
//  are "the source of truth", so where a phase has a doc its page reads in the
//  doc's own order: Hero → Living Through This Phase → Child Snapshot → When
//  to Contact Your Doctor. Each snapshot row opens that domain's milestone
//  page, also in the doc's order: summary, What is it, Why it matters, the
//  ParentVeda insight, Ways to support, the activity to try, related topics,
//  When to contact your doctor.
//
//  ONE READER (CLAUDE.md): both are `PvRead`s opened in `PvReaderScreen`.
//  The two things the reader does not model — the snapshot's tappable rows and
//  the activity card — ride as `PvReadSection.custom` blocks this file
//  renders, the seam parenting already uses for its tables (`PpBlockView`).
//
//  Mobbin (2026-10-13): Superpower's protocol rows (an icon, a title, a
//  chevron, a hairline card each) and Lifesum's sleep stages (a small marker,
//  a bold label, one line) for the snapshot rows and the activity card.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/pp_phase_docs.dart';
import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import '../../theme/pv_fonts.dart';
import '../reader/pv_reader_screen.dart';
import 'development_activity_screen.dart';
import 'pp_age_page_parts.dart' show kPpPhaseSources;
import 'pp_development_data.dart' show DevActivity;
import 'pp_phase_doc_activities.dart';
import 'pp_phases_data.dart' show AgePhase, ppFillChild;
import '../v2/v2_palette.dart';
import '../brackets/hub/hub_intent_art.dart' show HubIntentArt, IntentMark;

LocalizedText _same(String s) => LocalizedText(en: s, hi: s);
LocalizedText _fill(String s) => _same(ppFillChild(s));

/// The snapshot rows, drawn by [_renderBlock].
class PpDocSnapshotBlock {
  const PpDocSnapshotBlock(this.doc);
  final PpPhaseDoc doc;
}

/// "Activity to try" on a milestone page, drawn by [_renderBlock].
class PpDocActivityBlock {
  const PpDocActivityBlock(this.title, this.activity);
  final String title;

  /// Null when the doc names an activity it never wrote out.
  final DevActivity? activity;
}

/// Each domain's drawn mark (the user, 2026-10-13: the app's latest marks, not
/// Material icons). Was: psychology / child_care / chat_bubble / favorite /
/// restaurant, kept here for revert.
IntentMark ppDocDomainIcon(PpDocDomain d) => switch (d) {
      PpDocDomain.brain => IntentMark.headMark,
      PpDocDomain.physical => IntentMark.stepsMark,
      PpDocDomain.language => IntentMark.audioMark,
      PpDocDomain.emotional => IntentMark.moodArc,
      PpDocDomain.nutrition => IntentMark.feedMark,
    };

/// The doctor lines as the read's closing callout.
PvCallout _doctor(List<String> lines) => PvCallout(
      tone: PvCalloutTone.urgent,
      title: _same('When to contact your doctor'),
      body: _fill(lines.join('\n')),
    );

/// The phase page, in the doc's order.
PvRead ppPhaseDocAsRead(PpPhaseDoc doc, AgePhase phase) => PvRead(
      id: 'pp_phase_${phase.number}',
      kicker: _same('This phase · ${phase.ageLabel}'),
      title: _same(doc.name),
      // The hero's first paragraph opens the page; the rest follow it.
      teaser: _fill(doc.hero.first),
      // Empty: the reader draws no scale-setter box, so nothing jumps ahead
      // of the doc's own order.
      scaleSetter: _same(''),
      author: _same('ParentVeda editorial'),
      authorRole: _same(doc.code),
      reviewed: false,
      hue: 268,
      sections: [
        if (doc.hero.length > 1) PvReadSection(paragraphs: [for (final p in doc.hero.skip(1)) _fill(p)]),
        PvReadSection(heading: _same('Living through this phase')),
        for (final c in doc.living)
          PvReadSection(
            heading: _fill(c.title),
            paragraphs: [_fill(c.body)],
            bullets: [for (final t in c.tips) _fill(t)],
          ),
        PvReadSection(heading: _same('Child snapshot'), custom: PpDocSnapshotBlock(doc)),
        // The India note is not in the doc and the doc does not contradict it;
        // kept so the page loses nothing it had.
        if (phase.indianNote case final n?) PvReadSection(heading: _same('In India'), paragraphs: [_fill(n)]),
      ],
      whenToSeeSomeone: _doctor(doc.doctor),
      faqs: const [],
      evidence: _same(kPpPhaseSources.replaceFirst('Where this comes from: ', '')),
    );

/// One milestone page, in the doc's order.
PvRead ppMilestoneAsRead(PpPhaseDoc doc, PpMilestonePage m) {
  final acts = [
    for (final t in m.activities) PpDocActivityBlock(t, ppDocActivityNamed(doc, t)),
  ];
  return PvRead(
    id: 'pp_milestone_${doc.code.toLowerCase()}_${m.domain.name}',
    kicker: _same('${m.domain.label} · ${doc.name}'),
    title: _fill(m.title),
    teaser: _fill(m.summary),
    scaleSetter: _same(''),
    author: _same('ParentVeda editorial'),
    authorRole: _same('Typical age: ${m.typicalAge}'),
    reviewed: false,
    hue: 268,
    sections: [
      PvReadSection(heading: _same('What is it?'), paragraphs: [_fill(m.whatIsIt)]),
      PvReadSection(heading: _same('Why it matters'), paragraphs: [_fill(m.whyItMatters)]),
      PvReadSection(callout: PvCallout(
          tone: PvCalloutTone.note, title: _same('ParentVeda insight'), body: _fill(m.insight))),
      PvReadSection(heading: _same('Ways to support'), bullets: [for (final w in m.ways) _fill(w)]),
      for (final a in acts) PvReadSection(custom: a),
      if (m.relatedTopics.isNotEmpty)
        PvReadSection(heading: _same('Related topics'), paragraphs: [_same(m.relatedTopics.join(' · '))]),
    ],
    whenToSeeSomeone: _doctor(m.doctor),
    faqs: const [],
  );
}

void ppOpenPhaseDocRead(BuildContext context, PpPhaseDoc doc, AgePhase phase) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: 'pp/phase_read/${phase.number}'),
      builder: (_) => PvReaderScreen(
        read: ppPhaseDocAsRead(doc, phase),
        lang: AppLanguage.english,
        customBlock: _renderBlock,
      ),
    ));

void ppOpenMilestoneRead(BuildContext context, PpPhaseDoc doc, PpMilestonePage m) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: 'pp/milestone/${doc.code.toLowerCase()}_${m.domain.name}'),
      builder: (_) => PvReaderScreen(
        read: ppMilestoneAsRead(doc, m),
        lang: AppLanguage.english,
        customBlock: _renderBlock,
      ),
    ));

Widget _renderBlock(BuildContext context, Object block) => switch (block) {
      PpDocSnapshotBlock(:final doc) => _SnapshotRows(doc: doc),
      PpDocActivityBlock() => _ActivityCard(block: block),
      _ => const SizedBox.shrink(),
    };

class _SnapshotRows extends StatelessWidget {
  const _SnapshotRows({required this.doc});
  final PpPhaseDoc doc;

  @override
  Widget build(BuildContext context) => Column(children: [
        for (final s in doc.snapshot)
          _RowCard(
            key: ValueKey('pp_doc_snapshot_${s.domain.name}'),
            icon: ppDocDomainIcon(s.domain),
            eyebrow: s.domain.label.toUpperCase(),
            title: ppFillChild(s.title),
            line: ppFillChild(s.line),
            onTap: switch (doc.milestoneFor(s.domain)) {
              final m? => () => ppOpenMilestoneRead(context, doc, m),
              null => null,
            },
          ),
      ]);
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.block});
  final PpDocActivityBlock block;

  @override
  Widget build(BuildContext context) {
    final a = block.activity;
    return _RowCard(
      key: ValueKey('pp_doc_activity_${block.title}'),
      icon: IntentMark.playMark, // was Icons.toys_outlined
      eyebrow: 'SOMETHING TO TRY TOGETHER',
      title: block.title,
      line: a?.intro ?? '',
      onTap: a == null
          ? null
          : () => Navigator.of(context).push(MaterialPageRoute<void>(
                settings: RouteSettings(name: 'pp/activity/${a.id}'),
                builder: (_) => DevelopmentActivityScreen(activity: a),
              )),
    );
  }
}

/// A hairline card: icon, small-caps eyebrow, title, one line, chevron.
class _RowCard extends StatelessWidget {
  const _RowCard({
    super.key,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.line,
    required this.onTap,
  });
  final IntentMark icon;
  final String eyebrow;
  final String title;
  final String line;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // The palette parenting's other reader blocks use (`PpBlockView`): white
    // cards on a hairline, the app's inks.
    final p = V2PaletteStore.instance.current;
    final ink = p.ink1;
    final soft = p.ink2;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: p.line)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // The drawn mark in the parenting pastel (was a Material icon
              // in a grey disc).
              SizedBox(width: 36, height: 36, child: HubIntentArt(mark: icon, tint: v2BlockTint(268, p))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(eyebrow,
                      style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: soft)),
                  const SizedBox(height: 3),
                  Text(title, style: pvManrope(fontSize: 15, fontWeight: FontWeight.w800, height: 1.3, color: ink)),
                  if (line.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(line, style: pvManrope(fontSize: 13, height: 1.5, color: soft)),
                  ],
                ]),
              ),
              if (onTap != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 8),
                  child: Icon(Icons.chevron_right_rounded, size: 20, color: soft),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
