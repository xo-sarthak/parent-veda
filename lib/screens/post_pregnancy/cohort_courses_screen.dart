// =============================================================================
//  CohortCoursesScreen - Learn · Cohort Courses (parenting · S12)
// -----------------------------------------------------------------------------
//  "Guided, together" - a small group, a real coach, a set start and finish.
//  A featured cohort with a join CTA plus other upcoming cohorts. Reached from
//  the Explore drawer (design path: Products → Learn → Cohort Courses).
//  Faithful build of Claude Design · S12.
// =============================================================================

import 'package:flutter/material.dart';

import 'cohort_funnel_screen.dart';
import 'pp_common.dart';

class CohortCoursesScreen extends StatelessWidget {
  const CohortCoursesScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _openFunnel(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CohortFunnelScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ppBack(context, 'Explore'),
              ppLangToggle(),
            ])),

            const SizedBox(height: 22),
            _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ppEyebrow('Guided, together'),
              const SizedBox(height: 10),
              Text('Cohort Courses', style: ppFraunces(32, h: 1.12)),
              const SizedBox(height: 12),
              Text(
                  'A small group, a real coach, a set start and finish. You move through it week by week - with other parents at exactly your stage. Never alone at 2am.',
                  style: ppBody(15)),
            ])),

            // featured cohort
            const SizedBox(height: 22),
            _pad(Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: ppBorder),
                boxShadow: ppCardShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                        child: Text('Next cohort · 21 July',
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text('8 of 20 seats left',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ppBody(12, color: ppCoral, w: FontWeight.w700)),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Text('Sleep Bootcamp', style: ppFraunces(24, h: 1.12)),
                  const SizedBox(height: 6),
                  Text('2 weeks · led by a paediatric sleep consultant', style: ppBody(13)),
                  const SizedBox(height: 16),
                  _check('Two live group calls each week'),
                  _check('A plan built around Aarav, not a template'),
                  _check('A private group that stays with you after'),
                  const SizedBox(height: 16),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: '₹8,999', style: ppBody(16, color: ppInk, w: FontWeight.w700)),
                    TextSpan(text: '  ·  or ', style: ppBody(13, color: ppSoft)),
                    TextSpan(text: 'ParentVeda+ Pro', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                  ])),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _openFunnel(context),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
                      child: Text('Join cohort', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                    ),
                  ),
                ]),
              ),
            )),

            // other cohorts
            const SizedBox(height: 28),
            _pad(Text('Other cohorts', style: ppJakarta(18))),
            const SizedBox(height: 12),
            _pad(_row(context, 'Confident Weaning · 4 weeks', 'Starts 1 Aug · opens at 6 months', '₹12,999',
                top: true)),
            _pad(_row(context, 'Calm Parent, Calm Baby · 6 weeks', 'Mindfulness for the fourth trimester',
                '₹24,999',
                bottom: true)),

            const SizedBox(height: 22),
            _pad(Text("Small cohorts by design - so your coach actually knows your baby's name.",
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _check(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.check_rounded, size: 18, color: ppPurple),
          const SizedBox(width: 10),
          Expanded(child: Text(t, style: ppBody(14, color: ppInk, h: 1.5))),
        ]),
      );

  Widget _row(BuildContext context, String title, String sub, String price,
      {bool top = false, bool bottom = false}) {
    return GestureDetector(
      onTap: () => _openFunnel(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ppBody(15, color: ppInk, w: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(sub, style: ppBody(12)),
              const SizedBox(height: 6),
              Text(price, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
            ]),
          ),
          const SizedBox(width: 12),
          const Text('→', style: TextStyle(color: ppMuted)),
        ]),
      ),
    );
  }
}
