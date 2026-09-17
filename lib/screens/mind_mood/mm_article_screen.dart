// =============================================================================
//  MmArticleScreen - one Understand article
// -----------------------------------------------------------------------------
//  §Understand: "an expert explainer at the top of each 'more than a mood'
//  page and each major fear page; a 'real mother story' slot on the 'is this
//  normal' and fear pages." Both are real PvVideoPlaceholder geometry, not a
//  one-line "video coming soon" row.
//
//  ⚠️ THE ONLY PLACE IN Understand WHERE PAID SHOWS UP: the foot of a
//  "more than a mood" article, and only there - never on a fear page, never
//  on an "is this normal" page, never on an everyday-care page. See
//  `mm_talk_tab.dart`'s `showCounsellingBookingSheet`, reused rather than
//  re-implemented so the paid card looks identical everywhere it appears.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/mind_mood_data.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_placeholders.dart';
import '../v2/v2_palette.dart';
import 'mm_talk_tab.dart' show showCounsellingBookingSheet;
import '../../data/reads/read_adapters.dart';
import '../reader/pv_reader_screen.dart';

class MmArticleScreen extends StatelessWidget {
  const MmArticleScreen({
    super.key,
    required this.article,
    this.onOpenLink,
    this.onTalk,
  });
  final MmArticle article;

  /// ⚠️ INJECTED, NOT IMPORTED. The read's one cross-link (Labour prep, Scans,
  /// the partner piece) and its "talk to someone" foot both open things this
  /// screen has no business knowing how to open — a door, a stage's router.
  /// The Mind & mood door router passes both; the old landing passes neither
  /// and simply shows no link. Same pattern as `PvReaderScreen`.
  final void Function(BuildContext)? onOpenLink;
  final void Function(BuildContext)? onTalk;

  // ⚠️ THE ARTICLE FORMAT, 2026-09-17 — this screen now hands its model to
  // the one reader through `read_adapters.dart` (STILL-OPEN §60.1, §60.6),
  // so every caller — door, home, Saved, search — gets the one format and
  // nothing that constructs this screen has to change. The previous body is
  // `buildClassic` below, kept for revert and opened by nothing;
  // test/reader_unification_test.dart holds that.
  @override
  Widget build(BuildContext context) {
    return PvReaderScreen(
      read: pvReadFromMm(article, withTalk: onTalk != null),
      lang: PvType.lang,
      openAction: (ctx, action) {
        if (action == 'mm_talk') onTalk?.call(ctx);
        if (action.startsWith('mm_link:')) onOpenLink?.call(ctx);
      },
    );
  }

  /// The previous body, kept for revert. See `build`.
  Widget buildClassic(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final moreThanMood = article.group == MmArticleGroup.moreThanMood;
    final paragraphs =
        article.body.now.split('\n\n').where((s) => s.trim().isNotEmpty);

    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 44),
          children: [
            Row(children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(Icons.arrow_back_rounded, color: p.ink2),
              ),
            ]),
            const SizedBox(height: 6),
            Text(article.group.heading.now,
                style: pvManrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: p.ink3)),
            const SizedBox(height: 8),
            Text(article.title.now,
                style: pvFraunces(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.5,
                    color: p.ink1)),
            const SizedBox(height: 6),
            Text(article.readingTime.now,
                style: pvManrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: p.ink3)),
            // ⚠️ THE BYLINE, ON EVERY READ — the Mind & mood brief: "Author on
            // every read: Dr Sharanya Menon, Perinatal psychologist." One
            // constant, so a new read cannot forget it.
            const SizedBox(height: 10),
            Text('$kMmReadAuthor · $kMmReadAuthorRole',
                style: pvManrope(fontSize: 12, height: 1.4, color: p.ink2)),
            const SizedBox(height: 20),
            if (article.hasExpertVideo) ...[
              PvVideoPlaceholder(
                title: '${article.title.now}, explained by a doctor',
                subtitle: 'A calm, clinical explanation in plain language.',
                duration: '5 MIN',
                hue: 344,
              ),
              const SizedBox(height: 22),
            ],
            for (final para in paragraphs) ...[
              Text(para,
                  style: pvManrope(fontSize: 14.5, height: 1.65, color: p.ink1)),
              const SizedBox(height: 16),
            ],
            if (moreThanMood) ...[
              const SizedBox(height: 8),
              _StructuredBlock(
                  label: 'WHAT IT IS', text: article.whatItIs?.now, p: p),
              const SizedBox(height: 14),
              _StructuredBlock(
                  label: 'SIGNS TO NOTICE',
                  text: article.signsToNotice?.now,
                  p: p),
              const SizedBox(height: 14),
              _StructuredBlock(
                  label: 'HOW TO GET HELP',
                  text: article.howToGetHelp?.now,
                  p: p,
                  accent: true),
              const SizedBox(height: 26),
            ],
            if (article.hasStoryVideo) ...[
              PvVideoPlaceholder(
                title: 'A mother, telling it as it happened to her',
                subtitle: 'A real story, in her own words.',
                duration: '4 MIN',
                hue: 344,
              ),
              const SizedBox(height: 22),
            ],
            // The read's one cross-link, where the brief asks for one.
            if (article.linkLabel case final label? when onOpenLink != null) ...[
              const SizedBox(height: 4),
              _LinkRow(p: p, label: label, onTap: () => onOpenLink!(context)),
              const SizedBox(height: 18),
            ],
            // ⚠️ "Each points to the last tab if a feeling needs a person." A
            // quiet foot on every read, opening the counsellor.
            if (onTalk != null) ...[
              Container(height: 1, color: p.line),
              const SizedBox(height: 14),
              _LinkRow(
                  p: p,
                  label: 'If this feeling needs a person, talk to someone',
                  onTap: () => onTalk!(context)),
              const SizedBox(height: 22),
            ],
            if (moreThanMood) _PaidFooter(p: p),
          ],
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.p, required this.label, required this.onTap});
  final V2Palette p;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(children: [
          Expanded(
            child: Text(label,
                style: pvManrope(
                    fontSize: 14, fontWeight: FontWeight.w700, color: p.action)),
          ),
          Icon(Icons.chevron_right_rounded, size: 20, color: p.action),
        ]),
      );
}

class _StructuredBlock extends StatelessWidget {
  const _StructuredBlock(
      {required this.label, required this.text, required this.p, this.accent = false});
  final String label;
  final String? text;
  final V2Palette p;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent ? p.surfaceAlt : p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: pvManrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: p.ink3)),
        const SizedBox(height: 8),
        Text(text!, style: pvManrope(fontSize: 13.5, height: 1.55, color: p.ink1)),
      ]),
    );
  }
}

class _PaidFooter extends StatelessWidget {
  const _PaidFooter({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.lock_outline_rounded, size: 16, color: p.ink3),
          const SizedBox(width: 6),
          Text('ANONYMOUS · TALK',
              style: pvManrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: p.ink3)),
        ]),
        const SizedBox(height: 10),
        Text('If you would like to talk this through',
            style: pvFraunces(
                fontSize: 16.5, fontWeight: FontWeight.w600, color: p.ink1)),
        const SizedBox(height: 6),
        Text(
            'A perinatal counsellor, trained for exactly this, in a session '
            'that stays anonymous.',
            style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2)),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: () => showCounsellingBookingSheet(context),
            style: OutlinedButton.styleFrom(
                foregroundColor: p.ink1,
                side: BorderSide(color: p.line),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 11)),
            child: const Text('See how this works'),
          ),
        ),
      ]),
    );
  }
}
