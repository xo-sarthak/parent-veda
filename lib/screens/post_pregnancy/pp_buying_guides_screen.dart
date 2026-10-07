// =============================================================================
//  Parenting · What to buy › How to choose (2026-10-07)
// -----------------------------------------------------------------------------
//  The six buying guides (lib/data/reads/pp_buying_guides.dart), listed on the
//  shared tool shell; each opens in the one reader. Gap analysis P3: "Short
//  guides that say what matters and what to skip, inside What to buy, with no
//  brand ranking."
//
//  Mobbin: rows with the one line that sums each up, after Walmart's baby
//  registry checklist (mobbin.com/screens/5b7653ab-aafb-42b9-824f-e834c8ad7062);
//  each guide's "what matters / what you can skip" split, after Lovi's main
//  points for and against (mobbin.com/screens/c0ed17b9-f3e0-4501-9126-4154cb0fee61).
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/reads/pp_buying_guides.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show pvStorePalette;
import '../reader/pv_reader_screen.dart';

class PpBuyingGuidesScreen extends StatelessWidget {
  const PpBuyingGuidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final guides = kPpBuyingGuides;
    return PregToolScaffold(
      hue: 12,
      eyebrow: 'What to buy',
      mark: IntentMark.listMark,
      title: 'How to choose',
      intro: 'What matters and what you can skip, for the things worth getting right. '
          'No brands and no rankings: buy less, and buy safer.',
      children: [
        pregToolPad(PvRowGroup(p: p, children: [
          for (final r in guides)
            PvListRow(
              key: ValueKey('pp_buy_row_${r.id}'),
              p: p,
              leading: PvMarkWell(p: p, hue: r.hue, size: 40, mark: IntentMark.checkMark),
              title: r.title.en,
              line: r.scaleSetter.en,
              lineMaxLines: 2,
              onTap: () {
                pvCommitFeedback();
                Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: RouteSettings(name: 'pp/read/${r.id}'),
                  builder: (_) => PvReaderScreen(read: r, lang: PvType.lang),
                ));
              },
            ),
        ])),
        const SizedBox(height: 18),
        pregToolPad(Text(
            'General guidance for choosing safely. Always follow the maker\'s instructions for fitting and use.',
            style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink3))),
      ],
    );
  }
}
