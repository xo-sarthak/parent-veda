// =============================================================================
//  BsArticleScreen — the generic renderer for a Belly & Skin content page
// -----------------------------------------------------------------------------
//  Every page in Areas 1, 2, 4 and 5 (stretch marks, pigmentation, safe
//  skincare, belly care) renders through here, from `lib/data/belly_skin_data
//  .dart`'s `BsPage`. Area 3 (itching) is the one exception — its two-part
//  safety layout lives in bs_itching_screen.dart instead, because that page's
//  shape is not "content plus optional product", it is "soothing tips, then
//  an unmissable warning", and forcing it through this generic renderer would
//  either bury the warning in the block list or special-case this file for a
//  single page.
//
//  ⚠️ EVERY PAGE CARRIES A PvVideoPlaceholder — see lib/widgets/pv_placeholders
//  .dart. No page in this section is text-only, full stop.
//
//  Products are rendered through hub_solution_cards.dart's SolutionCard, the
//  same component family the rest of the app uses for a "thing you can buy" —
//  so a product here reads as the same kind of row as a product anywhere
//  else, not a bespoke shop card. They render `comingSoon: true` because this
//  pass wires content, not a checkout flow: the row is honest about what
//  exists today (a recommendation) versus what does not yet (a purchase).
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/belly_skin_data.dart';
import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_solution_cards.dart';
import '../v2/v2_palette.dart';
import '../../widgets/pv_placeholders.dart';

const _lang = AppLanguage.english;

class BsArticleScreen extends StatelessWidget {
  const BsArticleScreen({super.key, required this.page});
  final BsPage page;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final areaHue = kBsAreaInfo[page.area]!.hue;

    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        backgroundColor: p.ground,
        elevation: 0,
        foregroundColor: p.ink1,
        title: Text(page.title.of(_lang),
            style: pvJakarta(
                fontSize: 17, fontWeight: FontWeight.w700, color: p.ink1)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
        children: [
          PvVideoPlaceholder(
            title: page.videoTitle.of(_lang),
            subtitle: page.videoSubtitle?.of(_lang),
            duration: page.videoDuration?.of(_lang),
            hue: areaHue,
          ),
          const SizedBox(height: 20),
          if (page.honestNote != null) ...[
            _HonestNote(text: page.honestNote!.of(_lang), p: p),
            const SizedBox(height: 20),
          ],
          for (final b in page.blocks) ...[
            BsBlockView(block: b, p: p),
            const SizedBox(height: 20),
          ],
          if (page.products.isNotEmpty) ...[
            const SizedBox(height: 4),
            SolutionGroup(
              title: const LocalizedText(
                  en: 'What can help', hi: 'What can help'),
              p: p,
              lang: _lang,
              cards: [
                for (final prod in page.products)
                  SolutionCard(
                    type: SolutionType.product,
                    title: prod.title,
                    value: prod.blurb,
                    p: p,
                    lang: _lang,
                    comingSoon: true,
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          _FootDisclaimer(p: p),
        ],
      ),
    );
  }
}

/// The honesty beat — "this is largely genetic" — set apart so it cannot be
/// skimmed past as one more paragraph. Warm, not clinical: a tinted card, not
/// a warning box, because there is nothing alarming here, only something
/// worth being straight about.
class _HonestNote extends StatelessWidget {
  const _HonestNote({required this.text, required this.p});
  final String text;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.spa_outlined, size: 18, color: p.ink2),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: pvManrope(
                  fontSize: 13.5,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: p.ink1)),
        ),
      ]),
    );
  }
}

/// Renders one [BsBlock] (an optional heading, paragraphs, bullets). Public
/// because bs_itching_screen.dart reuses it for the "normal itching" half of
/// its page rather than duplicating a second paragraph/bullet renderer.
class BsBlockView extends StatelessWidget {
  const BsBlockView({super.key, required this.block, required this.p});
  final BsBlock block;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (block.heading != null) ...[
        Text(block.heading!.of(_lang),
            style: pvFraunces(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.4,
                color: p.ink1)),
        const SizedBox(height: 10),
      ],
      for (final para in block.paragraphs) ...[
        Text(para.of(_lang),
            style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink2)),
        if (para != block.paragraphs.last || block.bullets.isNotEmpty)
          const SizedBox(height: 10),
      ],
      if (block.bullets.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final bullet in block.bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration:
                            BoxDecoration(color: p.ink3, shape: BoxShape.circle),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(bullet.of(_lang),
                          style: pvManrope(
                              fontSize: 14, height: 1.5, color: p.ink2)),
                    ),
                  ],
                ),
              ),
          ],
        ),
    ]);
  }
}

class _FootDisclaimer extends StatelessWidget {
  const _FootDisclaimer({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline_rounded, size: 14, color: p.ink3),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
              'General skincare guidance, not a diagnosis. Anything that '
              'concerns you is worth a word with your doctor.',
              style: pvManrope(fontSize: 11.5, height: 1.4, color: p.ink3)),
        ),
      ]),
    );
  }
}
