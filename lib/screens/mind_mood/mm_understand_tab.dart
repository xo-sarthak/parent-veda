// =============================================================================
//  Understand tab - plain, warm articles, all free
// -----------------------------------------------------------------------------
//  Four groups, in the order the spec lays them out: "Is this normal?" ->
//  fears -> "when it is more than a mood" -> everyday care. Reuses
//  `SolutionGroup` / `SolutionCard` from hub_solution_cards.dart rather than
//  a bespoke row - these are real articles with real body copy, not
//  placeholders, so the READ-type card is the right shell (§6 of that file:
//  the same chip means the same kind of thing everywhere in the app).
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/mind_mood_data.dart';
import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_solution_cards.dart';
import '../v2/v2_palette.dart';
import 'mm_article_screen.dart';

class MmUnderstandTab extends StatelessWidget {
  const MmUnderstandTab({super.key});

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final lang = S.current;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 40),
      children: [
        Text(
            'Every feeling here is normal until it is not, and this section '
            'tells you which is which.',
            style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        const SizedBox(height: 22),
        for (final g in MmArticleGroup.values) ...[
          Text(g.intro.of(lang),
              style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink3)),
          const SizedBox(height: 12),
          SolutionGroup(
            title: g.heading,
            p: p,
            lang: lang,
            cards: [
              for (final a in mmArticlesIn(g))
                SolutionCard(
                  type: SolutionType.read,
                  title: a.title,
                  value: a.teaser,
                  meta: a.readingTime,
                  p: p,
                  lang: lang,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    settings: RouteSettings(name: 'mind_mood_article_${a.id}'),
                    builder: (_) => MmArticleScreen(article: a),
                  )),
                ),
            ],
          ),
          const SizedBox(height: 28),
        ],
      ],
    );
  }
}
