// =============================================================================
//  OnTrackChecklistScreen - "Is my child on track?", as one readable page
// -----------------------------------------------------------------------------
//  ⚠️ THE AREA WITH THIS NAME WAS FOUR ARTICLES, NOT AN ANSWER.
//
//  "Is my child on track?" opened a reading list — the normal range is wide, if
//  your baby was born early, when something is worth checking. All good pages,
//  and none of them the thing a parent taps that title to find out.
//
//  Feedback: "Is my child on track should be an easy checklist. Based on the
//  age of the child, show what all should have been achieved, what is coming up
//  now and what shall be in next 2-3 months."
//
//  ⚠️ THE THIRD GROUP IS THE ONE THAT WAS MISSING, AND IT IS ALSO THE RISKY
//  ONE. The milestone journey already showed emerging and coming soon; what no
//  screen showed was what is typically ALREADY there — which is the actual
//  question behind "on track". It is also the group most easily read as a
//  report card, so it is framed as "usually settled by now", every row carries
//  the wide range that makes it true, and an unticked row says nothing at all
//  about the child. `MilestoneStore.foundations` deliberately excludes what she
//  has ticked, so the two lists never double-count.
//
//  ⚠️ NEVER A SCORE, AND NO COUNT ANYWHERE. No "4 of 9", no progress bar, no
//  percentage. The moment this page can be totalled it becomes the comparison
//  the whole section exists to defuse — and a parent will total it herself if
//  we give her the numbers to do it with.
//
//  ⚠️ "NEXT 2-3 MONTHS", NOT EVERYTHING AHEAD. `comingSoon` already caps at six
//  months; this narrows further because the feedback asked for it and because
//  a shorter horizon is the difference between a look ahead and a workload.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_milestones_data.dart';

class OnTrackChecklistScreen extends StatefulWidget {
  const OnTrackChecklistScreen({super.key});

  @override
  State<OnTrackChecklistScreen> createState() => _OnTrackChecklistScreenState();
}

class _OnTrackChecklistScreenState extends State<OnTrackChecklistScreen> {
  final _store = MilestoneStore.instance;

  Widget _pad(Widget c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _store,
          builder: (context, _) {
            final months = ChildProfileStore.instance.ageInMonths;
            final name = ChildProfileStore.instance.nameMid;

            // Already there = ticked, plus everything whose typical window has
            // closed. `foundations` excludes observed, so no double-counting.
            final settled = <Milestone>[
              ..._store.achieved,
              ..._store.foundations,
            ];
            final emerging = _store.emerging;
            final next = _store.comingSoon
                .where((m) => m.loMonths <= months + 3)
                .toList();

            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 48),
              children: [
                _pad(ppBack(context, 'Development')),
                const SizedBox(height: 20),
                _pad(ppEyebrow(ChildProfileStore.instance.ageLabel,
                    color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('Where $name is right now',
                    style: ppFraunces(28, h: 1.12))),
                const SizedBox(height: 8),
                _pad(Text(
                    'Three groups, not a score. Ranges are wide on purpose, and '
                    'a row you have not ticked is not a row he has missed.',
                    style: ppBody(13.5, h: 1.55))),
                const SizedBox(height: 26),

                _group(
                  'Usually settled by now',
                  'Typical windows that have already passed. Most children have '
                      'these; some arrive later and still arrive.',
                  settled,
                  Icons.check_circle_outline_rounded,
                  showTicks: true,
                ),
                _group(
                  'Emerging now',
                  'The window is open. You may start seeing these any week.',
                  emerging,
                  Icons.spa_outlined,
                  showTicks: true,
                ),
                _group(
                  'Next two or three months',
                  'A soft look ahead. Nothing here is due.',
                  next,
                  Icons.wb_twilight_rounded,
                  showTicks: false,
                ),

                const SizedBox(height: 8),
                _pad(Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: ppPanel, borderRadius: BorderRadius.circular(16)),
                  child: Text(
                      'If a skill he had has gone away, or something has felt '
                      'off for a while, that is worth mentioning to your '
                      'paediatrician — not because of anything on this page, '
                      'but because you noticed it.',
                      style: ppBody(13, h: 1.55)),
                )),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _group(String title, String blurb, List<Milestone> items, IconData icon,
      {required bool showTicks}) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(children: [
      _pad(Row(children: [
        Icon(icon, size: 17, color: ppPurple),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: ppJakarta(16.5))),
      ])),
      const SizedBox(height: 5),
      _pad(Text(blurb, style: ppBody(12.5, color: ppMuted, h: 1.5))),
      const SizedBox(height: 12),
      _pad(Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ppHair),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          for (int i = 0; i < items.length; i++)
            _row(items[i], last: i == items.length - 1, showTick: showTicks),
        ]),
      )),
      const SizedBox(height: 26),
    ]);
  }

  Widget _row(Milestone m, {required bool last, required bool showTick}) {
    final meta = kDomainMeta[m.domain]!;
    final ticked = _store.isObserved(m.id);
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 14, 13),
      decoration: BoxDecoration(
        border: Border(
            bottom: last ? BorderSide.none : const BorderSide(color: ppHair)),
      ),
      child: Row(children: [
        // The domain colour, as a small bar rather than another icon: the row
        // already has a tick and a chevron, and a third glyph makes a list of
        // nine unreadable.
        Container(
          width: 4,
          height: 34,
          decoration: BoxDecoration(
              color: meta.ink, borderRadius: BorderRadius.circular(99)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.title, style: ppBody(14, color: ppInk, w: FontWeight.w600)),
            const SizedBox(height: 3),
            Text('${meta.label} · usually ${m.ageRangeLabel}',
                style: ppBody(11.5, color: ppMuted)),
          ]),
        ),
        if (showTick) ...[
          const SizedBox(width: 10),
          // ⚠️ AN EMPTY CIRCLE, NOT AN EMPTY CHECKBOX. A checkbox asks to be
          // completed; a circle simply is not filled yet. The difference sounds
          // small and it is the whole tone of the page.
          Icon(
            ticked
                ? Icons.check_circle_rounded
                : Icons.circle_outlined,
            size: 19,
            color: ticked ? ppPurple : ppBorder,
          ),
        ],
      ]),
    );
  }
}
