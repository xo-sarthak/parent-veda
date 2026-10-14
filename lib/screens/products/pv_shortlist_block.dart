// =============================================================================
//  The shortlist block — what the team's product sheets say about a pick
// -----------------------------------------------------------------------------
//  2026-10-13. Shown on the product page for a `PvProduct.shortlist` product
//  (lib/data/products/pv_sheet_products.dart): the team's score where the
//  sheet has one, the age and the skills for a toy, the buy-by week and "what
//  the team looked for" for a pregnancy pick. Only what the sheets say.
//
//  Mobbin, 2026-10-13: Yuka sets "47/100" beside the product with one quiet
//  word; Too Good To Go draws each part of a rating as a bar; Commons shows a
//  1–5 rating as dots and says how it rates. So: the number large, the parts
//  as bars only where the sheet scored them part by part, confidence as five
//  dots, and one line on who scored it.
//
//  Drawn marks only (the user, 2026-10-13), never Material glyphs.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/pv_product.dart';
import '../../services/pv_catalog_store.dart';
import '../../theme/pv_fonts.dart';
import '../ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import '../ttc/ttc_tool_marks.dart' show TtcMarkLeading;
import '../v2/v2_palette.dart';

class PvShortlistBlock extends StatelessWidget {
  const PvShortlistBlock({super.key, required this.p, required this.product});
  final V2Palette p;
  final PvProduct product;

  @override
  Widget build(BuildContext context) {
    final cat = PvCatalogStore.instance.category(product.categoryId);
    final guide = cat?.guidanceFor(product.subId);
    final subName = cat?.subs.where((s) => s.id == product.subId).map((s) => s.name).firstOrNull;
    final age = product.specs.where((s) => s.$1 == 'Age').map((s) => s.$2).firstOrNull;
    return Padding(
      key: const ValueKey('pv_shortlist_block'),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            TtcMarkLeading(tab: TtcTabMark.checklist, tint: p.ink1, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text("ON PARENTVEDA'S SHORTLIST",
                  style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.9, color: p.ink2)),
            ),
          ]),
          if (product.score != null) ...[
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${product.score}',
                  style: pvFraunces(fontSize: 34, fontWeight: FontWeight.w500, height: 1, color: p.ink1)),
              Padding(
                padding: const EdgeInsets.only(left: 3, bottom: 4),
                child: Text('/100', style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink3)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('ParentVeda score',
                      style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink2)),
                ),
              ),
            ]),
          ],
          for (final (label, v) in product.scoreParts) ...[
            const SizedBox(height: 9),
            _bar(label, v),
          ],
          if (product.confidence != null) ...[
            const SizedBox(height: 12),
            _dots(product.confidence!),
          ],
          if (product.score != null || product.confidence != null) ...[
            const SizedBox(height: 8),
            Text('Scored by the ParentVeda team.',
                style: pvManrope(fontSize: 12, height: 1.4, color: p.ink3)),
          ],
          if (age != null || product.skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 6, runSpacing: 6, children: [
              if (age != null) _chip('Age $age', strong: true),
              for (final s in product.skills.take(6)) _chip(s),
            ]),
          ],
          if (product.weekFrom != null) ...[
            const SizedBox(height: 12),
            Row(children: [
              TtcMarkLeading(tab: TtcTabMark.timelineDots, tint: p.ink1, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Good to have by week ${product.weekFrom}',
                    style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink1)),
              ),
            ]),
          ],
          if (guide != null && guide.lookFor.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(subName == null ? 'What the team looked for' : 'What the team looked for in ${subName.toLowerCase()}',
                style: pvManrope(fontSize: 13, fontWeight: FontWeight.w800, color: p.ink1)),
            const SizedBox(height: 6),
            for (final l in guide.lookFor)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7, right: 9),
                    child: Container(width: 4, height: 4, decoration: BoxDecoration(color: p.ink2, shape: BoxShape.circle)),
                  ),
                  Expanded(child: Text(l, style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2))),
                ]),
              ),
          ],
        ]),
      ),
    );
  }

  Widget _bar(String label, int outOf10) => Row(children: [
        SizedBox(
          width: 128,
          child: Text(label, style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink2)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (outOf10 / 10).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: p.surfaceAlt,
              valueColor: AlwaysStoppedAnimation(p.ink1),
            ),
          ),
        ),
        SizedBox(
          width: 34,
          child: Text('$outOf10/10',
              textAlign: TextAlign.right,
              style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, color: p.ink1)),
        ),
      ]);

  Widget _dots(int of5) => Row(children: [
        for (var i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: i < of5 ? p.ink1 : p.surfaceAlt,
                shape: BoxShape.circle,
              ),
            ),
          ),
        const SizedBox(width: 6),
        Flexible(
          child: Text('Team confidence $of5 of 5',
              style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink2)),
        ),
      ]);

  Widget _chip(String t, {bool strong = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: strong ? p.ink1 : p.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(t,
            style: pvManrope(
                fontSize: 12, fontWeight: FontWeight.w700, color: strong ? Colors.white : p.ink1)),
      );
}

/// The card's one-line score, under the name ("84/100" or "Confidence 4/5").
/// Empty for a product the team did not score.
String pvShortlistScoreLine(PvProduct p) {
  if (p.score != null) return 'ParentVeda score ${p.score}/100';
  if (p.shortlist && p.confidence != null) return 'Team confidence ${p.confidence}/5';
  return '';
}
