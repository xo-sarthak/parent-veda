// =============================================================================
//  TTC - Supplements
// -----------------------------------------------------------------------------
//  A record of what they actually take, and whether they took it today.
//
//  What this screen deliberately has no room for: an adherence percentage, a
//  streak, a colour that changes as you fall behind, or any wording that turns
//  a missed Tuesday into a failure. The pregnancy app's medication tracker set
//  that rule and this follows it exactly - "a weekday awareness grid rather
//  than a compliance score".
//
//  Both partners' supplements live on one screen, because zinc and CoQ10 are
//  his in the same way folic acid is hers, and putting his on a separate page
//  is how a couple-first product quietly becomes a single-user one.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_journal_store.dart' show TtcAuthor;
import '../../ttc/ttc_supplements_store.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

class TtcSupplementsScreen extends StatelessWidget {
  const TtcSupplementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [TtcSupplementsStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final store = TtcSupplementsStore.instance;
        final mine = store.forAuthor(TtcAuthor.me);
        final theirs = store.forAuthor(TtcAuthor.partner);

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
              children: [
                TtcBackBar(title: t.supplements),
                const SizedBox(height: 16),

                if (store.items.isEmpty)
                  TtcEmpty(
                    icon: Icons.medication_outlined,
                    title: t.supplementsEmptyTitle,
                    body: t.supplementsEmptyBody,
                  )
                else ...[
                  // "2 of 4" - a count, never a percentage.
                  TtcCard(
                    color: ttcPanel,
                    child: Row(children: [
                      Expanded(
                        child: Text(t.supplementsTakenToday,
                            style: ttcBody(13.5,
                                color: ttcTitleInk, w: FontWeight.w700)),
                      ),
                      Text('${store.takenToday()} / ${store.items.length}',
                          style: ttcJakarta(17, color: ttcPurple)),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  if (mine.isNotEmpty) ...[
                    ttcEyebrow(hi ? 'Aapke' : 'Yours', color: ttcPurple),
                    const SizedBox(height: 11),
                    for (final s in mine) ...[
                      _SupplementRow(item: s, t: t),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 10),
                  ],
                  if (theirs.isNotEmpty) ...[
                    ttcEyebrow(hi ? 'Partner ke' : "Your partner's",
                        color: ttcCoral),
                    const SizedBox(height: 11),
                    for (final s in theirs) ...[
                      _SupplementRow(item: s, t: t),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 10),
                  ],
                ],

                const SizedBox(height: 10),
                ttcSectionTitle(t.supplementsSuggested),
                // Offering is not recommending. The dose is left as "as
                // advised" on purpose for everything except folic acid, where
                // the guideline number is genuinely universal.
                for (final s in ttcSuggestedSupplements) ...[
                  _SuggestionCard(suggestion: s, t: t),
                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 14),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 15, color: ttcMuted),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(t.supplementsDisclaimer,
                        style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SupplementRow extends StatelessWidget {
  const _SupplementRow({required this.item, required this.t});

  final TtcSupplement item;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final taken = TtcSupplementsStore.instance.isTaken(item.id);
    return TtcCard(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      onTap: () => TtcSupplementsStore.instance.toggleTaken(item.id),
      child: Row(children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: taken ? ttcPurple : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
                color: taken ? ttcPurple : ttcBorder, width: 1.6),
          ),
          child: taken
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name,
                style: ttcBody(14, color: ttcInk, w: FontWeight.w700)),
            if (item.dose.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(item.dose, style: ttcBody(12)),
            ],
          ]),
        ),
        GestureDetector(
          onTap: () => TtcSupplementsStore.instance.remove(item.id),
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.close_rounded, size: 16, color: ttcMuted),
          ),
        ),
      ]),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion, required this.t});

  final TtcSuggestedSupplement suggestion;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final already = TtcSupplementsStore.instance.items
        .any((e) => e.name.toLowerCase() == suggestion.name.toLowerCase());
    return TtcCard(
      onTap: already
          ? null
          : () => TtcSupplementsStore.instance.add(
                suggestion.name,
                dose: suggestion.dose,
                author:
                    suggestion.forPartner ? TtcAuthor.partner : TtcAuthor.me,
              ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(suggestion.name, style: ttcJakarta(15))),
          if (suggestion.forPartner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: ttcCoralTint,
                  borderRadius: BorderRadius.circular(999)),
              child: Text(t.forPartnerTag,
                  style: ttcBody(10, color: ttcCoral, w: FontWeight.w800)),
            )
          else if (already)
            const Icon(Icons.check_circle_rounded, size: 18, color: ttcPurple)
          else
            const Icon(Icons.add_circle_outline_rounded,
                size: 18, color: ttcPurple),
        ]),
        const SizedBox(height: 7),
        Text(suggestion.note(hi), style: ttcBody(12.5, h: 1.5)),
      ]),
    );
  }
}
