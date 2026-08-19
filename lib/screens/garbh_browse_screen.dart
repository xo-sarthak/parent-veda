// =============================================================================
//  GarbhBrowseScreen — "see everything in this pillar", calmly
// -----------------------------------------------------------------------------
//  ⚠️ ONE SCREEN, FOUR CONFIGURATIONS — and that is a deliberate choice against
//  the obvious alternative.
//
//  Review asked for a "see all" under Mark Complete on Shravan, and then for
//  the same on Samvad, Vichara and Kriya. Four screens would have been quicker
//  to write and would have drifted the first time any one of them was touched,
//  which is the same failure `pp_chart_browser_screen.dart` was built to avoid
//  on the parenting side. So: one screen, a config per pillar, and adding a
//  fifth is a list of items rather than a file.
//
//  ---------------------------------------------------------------------------
//  ⚠️ IT HOLDS NO CONTENT OF ITS OWN
//  ---------------------------------------------------------------------------
//  Every item is read from `garbh_data.dart` at call time. A second copy of the
//  raga list here would go on saying "7 min" after the audio was re-cut, and
//  nothing would fail — the same reason the parenting chart browser reads its
//  section's cards through the registry rather than holding numbers.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY IT IS BUILT THIS SPARELY, WHICH IS THE ACTUAL BRIEF
//  ---------------------------------------------------------------------------
//  Review: "listed in a very calming way so that user has enough to know which
//  to select on just seeing the preview of all in list."
//
//  Those are two requirements pulling against each other — enough information
//  to choose, without the density that makes a list feel like work — and the
//  resolution is what every decision below is answering to:
//
//    · ONE LINE OF PREVIEW PER ITEM, never two. The subtitle already exists in
//      the data and was written to be exactly this. Truncated to one line so
//      every row is the same height, because a ragged list of different-height
//      cards is what makes a screen feel busy more than any single element.
//    · NO CARDS, NO BORDERS, NO SHADOWS. Hairline dividers only. Ten bordered
//      cards read as ten decisions; ten rows read as one list.
//    · GROUPED WHERE THE GROUPING IS REAL. Shravan splits into ragas, nature
//      and guided because those are genuinely different things to want. Samvad
//      splits by trimester. Kriya and Vichara do not split, because inventing
//      a category to look organised is how a calm screen becomes a taxonomy.
//    · THE MINUTES ARE THE RIGHT-HAND COLUMN. "How long is this" is the second
//      question after "what is it", and putting it in a fixed column lets the
//      eye scan for a seven-minute gap without reading anything.
//    · NO PROGRESS, NO TICKS, NO STREAKS. This is a menu she is browsing, not
//      a syllabus she is behind on. Garbh Sanskar's whole tone depends on that
//      distinction.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/garbh_data.dart';
import '../localization/app_language.dart';
import '../models/garbh_content.dart';
import '../theme/pv_fonts.dart';

/// One row in the list.
class GarbhBrowseItem {
  const GarbhBrowseItem({
    required this.title,
    this.subtitle,
    this.emoji,
    this.meta,
  });

  final String title;

  /// The one line of preview. See the header on why it is one and not two.
  final String? subtitle;

  final String? emoji;

  /// The right-hand column — "7 min", "3 min read".
  final String? meta;
}

/// A titled run of items. A single unnamed group renders with no heading at
/// all, which is what keeps Kriya and Vichara from growing a category they do
/// not have.
class GarbhBrowseGroup {
  const GarbhBrowseGroup({this.title, required this.items});
  final String? title;
  final List<GarbhBrowseItem> items;
}

class GarbhBrowseScreen extends StatelessWidget {
  const GarbhBrowseScreen({
    super.key,
    required this.title,
    required this.intro,
    required this.accent,
    required this.groups,
  });

  final String title;

  /// One sentence, at the top. Says what the list is FOR, because a list of
  /// ten names with no framing makes a mother wonder whether she is supposed
  /// to do all of them.
  final String intro;

  final Color accent;
  final List<GarbhBrowseGroup> groups;

  @override
  Widget build(BuildContext context) {
    const ground = Color(0xFFFBF9F6);
    const ink = Color(0xFF2E2A32);
    const muted = Color(0xFF8A8290);

    return Scaffold(
      backgroundColor: ground,
      appBar: AppBar(
        backgroundColor: ground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ink,
        title: Text(title,
            style: pvFraunces(
                fontSize: 18, fontWeight: FontWeight.w600, color: ink)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
          children: [
            Text(intro,
                style:
                    pvManrope(fontSize: 13.5, height: 1.6, color: muted)),
            const SizedBox(height: 26),
            for (final g in groups) ...[
              if (g.title != null) ...[
                Text(g.title!.toUpperCase(),
                    style: pvManrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                        color: accent)),
                const SizedBox(height: 14),
              ],
              for (int i = 0; i < g.items.length; i++) ...[
                _Row(item: g.items[i], ink: ink, muted: muted),
                if (i != g.items.length - 1)
                  const Divider(
                      height: 1, thickness: 1, color: Color(0x14000000)),
              ],
              if (g != groups.last) const SizedBox(height: 30),
            ],
            const SizedBox(height: 30),
            // ⚠️ THE CLOSING LINE IS NOT DECORATION. A list of everything
            // available is exactly where a practice starts to feel like a
            // backlog, and this pillar's whole value is that it does not.
            Text(
                'Nothing here is a list to finish. Pick whatever suits today, '
                'and leave the rest where it is.',
                style: pvManrope(
                    fontSize: 12.5,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                    color: muted)),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.ink, required this.muted});

  final GarbhBrowseItem item;
  final Color ink;
  final Color muted;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.emoji != null) ...[
              Text(item.emoji!, style: const TextStyle(fontSize: 19)),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: pvFraunces(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: ink)),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(item.subtitle!,
                        // ⚠️ ONE LINE, ELLIPSISED. Every row the same height
                        // is most of what makes this list read as calm.
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 12.5, height: 1.4, color: muted)),
                  ],
                ],
              ),
            ),
            if (item.meta != null) ...[
              const SizedBox(width: 14),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(item.meta!,
                    style: pvManrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: muted)),
              ),
            ],
          ],
        ),
      );
}

// -----------------------------------------------------------------------------
//  The four configurations
// -----------------------------------------------------------------------------
//  ⚠️ EACH IS A FUNCTION, NOT A CONST. They read `garbh_data.dart` at call
//  time, so adding a raga shows up here with no second edit — which is the
//  whole reason this screen holds no content.

GarbhBrowseScreen shravanBrowse(AppLanguage lang, Color accent) {
  List<GarbhBrowseItem> of(GarbhKind k) => [
        for (final a in kShravan.where((x) => x.kind == k))
          GarbhBrowseItem(
            title: a.title.of(lang),
            subtitle: a.subtitle.of(lang),
            emoji: a.emoji,
            meta: '${a.minutes} min',
          ),
      ];

  // ⚠️ GROUPED BY KIND BECAUSE THE KINDS ARE GENUINELY DIFFERENT WANTS. A
  // mother reaching for rain sounds and one reaching for a guided body scan
  // are not making the same choice, and one flat list of ten makes her read
  // all ten to discover that.
  final groups = <GarbhBrowseGroup>[
    if (of(GarbhKind.raga).isNotEmpty)
      GarbhBrowseGroup(
          title: lang.isHindi ? 'राग' : 'Ragas', items: of(GarbhKind.raga)),
    if (of(GarbhKind.nature).isNotEmpty)
      GarbhBrowseGroup(
          title: lang.isHindi ? 'प्रकृति की ध्वनियाँ' : 'Nature sounds',
          items: of(GarbhKind.nature)),
    if (of(GarbhKind.guided).isNotEmpty)
      GarbhBrowseGroup(
          title: lang.isHindi ? 'निर्देशित' : 'Guided',
          items: of(GarbhKind.guided)),
  ];

  return GarbhBrowseScreen(
    title: lang.isHindi ? 'सभी राग' : 'All ragas',
    intro: lang.isHindi
        ? 'हर दिन एक अपने-आप चुना जाता है। पूरी सूची यहाँ है — जो आज के मन से मेल खाए, वही सुनिए।'
        : 'One is chosen for you each day. Here is everything there is, so you '
            'can pick whatever matches today instead.',
    accent: accent,
    groups: groups,
  );
}

GarbhBrowseScreen vicharaBrowse(AppLanguage lang, Color accent) =>
    GarbhBrowseScreen(
      title: lang.isHindi ? 'सभी विचार' : 'All reflections',
      intro: lang.isHindi
          ? 'छोटे-छोटे पाठ, हर एक तीन मिनट के आसपास। कोई क्रम नहीं है — जो आज पढ़ने का मन हो, वही पढ़िए।'
          : 'Short reads, about three minutes each. There is no order to them '
              '— read whichever one you feel like today.',
      accent: accent,
      // No grouping: eight reflections do not need a taxonomy, and the theme
      // is already the first thing on each row.
      groups: [
        GarbhBrowseGroup(items: [
          for (final s in kVichara)
            GarbhBrowseItem(
              title: s.title.of(lang),
              subtitle: s.blurb.of(lang),
              meta: '${s.minutes} min',
            ),
        ]),
      ],
    );

GarbhBrowseScreen samvadBrowse(AppLanguage lang, Color accent) =>
    GarbhBrowseScreen(
      title: lang.isHindi ? 'सभी संवाद' : 'All things to say',
      intro: lang.isHindi
          ? 'शिशु से कहने के लिए शब्द, तिमाही के हिसाब से। ऊँची आवाज़ में पढ़िए, या बस मन में।'
          : 'Words to say to your baby, gathered by trimester. Read one aloud, '
              'or just to yourself.',
      accent: accent,
      // ⚠️ GROUPED BY TRIMESTER because the prompts genuinely differ by it —
      // and shown ALL AT ONCE rather than filtered to hers. This is the browse
      // screen; the daily view is where personalisation belongs. Someone at 12
      // weeks reading what she will say at 30 is the point of a list like this.
      groups: [
        GarbhBrowseGroup(
          title: lang.isHindi ? 'पहली तिमाही' : 'First trimester',
          items: [
            for (final p in kSamvadT1)
              GarbhBrowseItem(title: p.text.of(lang)),
          ],
        ),
        GarbhBrowseGroup(
          title: lang.isHindi ? 'दूसरी तिमाही' : 'Second trimester',
          items: [
            for (final p in kSamvadT2)
              GarbhBrowseItem(title: p.text.of(lang)),
          ],
        ),
        GarbhBrowseGroup(
          title: lang.isHindi ? 'तीसरी तिमाही' : 'Third trimester',
          items: [
            for (final p in kSamvadT3)
              GarbhBrowseItem(title: p.text.of(lang)),
          ],
        ),
      ],
    );

GarbhBrowseScreen kriyaBrowse(AppLanguage lang, Color accent) =>
    GarbhBrowseScreen(
      title: lang.isHindi ? 'सभी अभ्यास' : 'All practices',
      intro: lang.isHindi
          ? 'साँस के छोटे अभ्यास, हर एक कुछ ही मिनट का। किसी भी दिन, कोई भी चुन सकती हैं।'
          : 'Short breathing practices, a few minutes each. Any of them, any '
              'day — there is no sequence to keep to.',
      accent: accent,
      groups: [
        GarbhBrowseGroup(items: [
          for (final k in kKriya)
            GarbhBrowseItem(
              title: k.title.of(lang),
              subtitle: k.blurb.of(lang),
              emoji: k.emoji,
              meta: '${k.minutes} min',
            ),
        ]),
      ],
    );
