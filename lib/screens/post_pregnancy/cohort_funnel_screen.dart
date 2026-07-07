// =============================================================================
//  CohortFunnelScreen - Cohort Courses · full page (parenting)
// -----------------------------------------------------------------------------
//  The sales/detail page for a cohort programme (Sleep Bootcamp). Unlike a
//  one-off masterclass, a cohort is multi-week and scheduled - so this page
//  leads with a week-by-week timetable, the live-call rhythm, what's included,
//  the coach, a guarantee row, an FAQ, and a sticky "Join cohort" bar. Net-new
//  page (no Claude Design frame) modelled on the masterclass funnel + the iMumz
//  plan-page reference. Reached from Cohort Courses → any cohort.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_experts_data.dart';
import 'provider_profile_screen.dart';

class CohortFunnelScreen extends StatefulWidget {
  const CohortFunnelScreen({super.key});

  @override
  State<CohortFunnelScreen> createState() => _CohortFunnelScreenState();
}

class _CohortFunnelScreenState extends State<CohortFunnelScreen> {
  int _openFaq = 0;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _openExpert(BuildContext context, String id) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => ProviderProfileScreen(expert: expertById(id))));

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enrolment opens soon'), behavior: SnackBarBehavior.floating),
      );

  static const List<List<String>> _faqs = [
    ['What if I miss a live call?', 'Every call is recorded and shared within the hour - you never fall behind.'],
    ['How big is the group?', 'Capped at 20 parents, all with babies around your stage, so the coach knows every baby by name.'],
    ["What if it doesn't work for us?", "There's a 7-day money-back guarantee, and you can pause the plan for up to 90 days if life gets in the way."],
    ['Do I get anything to keep?', 'Yes - the recordings, a downloadable sleep toolkit, and lifetime access to the private group.'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 120),
            children: [
              _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ppBack(context, 'Cohort Courses'),
                ppLangToggle(),
              ])),

              // hero
              const SizedBox(height: 18),
              _pad(GestureDetector(
                onTap: () => _soon(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(children: [
                    const PpStriped(height: 190, radius: 22, border: true),
                    const Positioned.fill(child: Center(child: _PlayDisc(56))),
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(999)),
                        child: Text('Watch how the cohort works', style: ppBody(11, color: Colors.white, w: FontWeight.w600)),
                      ),
                    ),
                  ]),
                ),
              )),

              // title
              const SizedBox(height: 20),
              _pad(Row(children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                    child: Text('Next cohort · Sun 21 July',
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
              ])),
              const SizedBox(height: 12),
              _pad(Text('Sleep Bootcamp', style: ppFraunces(30, h: 1.14))),
              const SizedBox(height: 10),
              _pad(Text(
                  'Two guided weeks with a paediatric sleep consultant and a small group of parents at exactly your stage. A real plan for your baby, built together - never alone at 2am.',
                  style: ppBody(15))),

              // quick facts
              const SizedBox(height: 20),
              _pad(Row(children: [
                _fact('2 weeks', 'programme'),
                const SizedBox(width: 10),
                _fact('2×/week', 'live calls'),
                const SizedBox(width: 10),
                _fact('20', 'small group'),
              ])),

              // schedule (the cohort differentiator)
              const SizedBox(height: 28),
              _pad(Text('Your 2-week schedule', style: ppJakarta(18))),
              const SizedBox(height: 4),
              _pad(Text('Live group calls Mondays & Thursdays, 8–9pm IST - recorded if you miss one.', style: ppBody(13))),
              const SizedBox(height: 14),
              _pad(_week('Week 1', 'Foundations', 'Mon 21 & Thu 24 Jul · 8–9pm', [
                "How your baby's sleep actually works at this age",
                'Building a wind-down routine that sticks',
                'The sleep environment - light, sound, temperature',
              ])),
              const SizedBox(height: 12),
              _pad(_week('Week 2', 'Practice & troubleshoot', 'Mon 28 & Thu 31 Jul · 8–9pm', [
                'Drowsy-but-awake, and gentle settling',
                'Night wakings and early mornings',
                "Your baby's personal plan - reviewed live",
              ])),

              // what's included
              const SizedBox(height: 28),
              _pad(Text("What's included", style: ppJakarta(18))),
              const SizedBox(height: 12),
              _pad(Column(children: [
                _incl('Four live group calls (all recorded and yours to keep)'),
                _incl('A sleep plan built around your baby, not a template'),
                _incl('Direct access to your coach between calls'),
                _incl('A private group that stays with you after it ends'),
                _incl('A downloadable sleep toolkit and tracker'),
              ])),

              // coach
              const SizedBox(height: 28),
              _pad(Row(children: [
                Expanded(child: Text('Your coach', style: ppJakarta(18))),
                GestureDetector(
                  onTap: () => _openExpert(context, 'meher'),
                  behavior: HitTestBehavior.opaque,
                  child: Text('View profile →', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
                ),
              ])),
              const SizedBox(height: 14),
              _pad(GestureDetector(
                onTap: () => _openExpert(context, 'meher'),
                behavior: HitTestBehavior.opaque,
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
                    clipBehavior: Clip.antiAlias,
                    child: const PpStriped(height: 70, colorA: ppBorder, colorB: ppStripeB),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Dr. Meher Shah', style: ppJakarta(16)),
                      const SizedBox(height: 2),
                      Text('Paediatric sleep consultant · 8 years', style: ppBody(12)),
                      const SizedBox(height: 8),
                      Text('Has coached 60+ small cohorts of Indian families through gentle, no-cry-it-out sleep. Warm, practical, and honest about what a two-week plan can and can\'t do.',
                          style: ppBody(13, h: 1.55)),
                    ]),
                  ),
                ]),
              )),

              // testimonial
              const SizedBox(height: 26),
              _pad(Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFECE5F2))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('★★★★★', style: ppBody(13, color: ppCoral, w: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text('“Doing it with other parents at the same stage is what made it stick. The coach knew our baby by the second call.”',
                      style: ppBody(15, color: ppInk, h: 1.55)),
                  const SizedBox(height: 10),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: 'Meghna T. ', style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                    TextSpan(text: '· mother of a 5-month-old', style: ppBody(13, color: ppMuted)),
                  ])),
                ]),
              )),

              // guarantee
              const SizedBox(height: 28),
              _pad(ppEyebrow('The ParentVeda promise', color: ppBrown, spacing: 0.8)),
              const SizedBox(height: 16),
              _pad(ppGuaranteeRow()),

              // faq
              const SizedBox(height: 30),
              _pad(Text('Common questions', style: ppJakarta(18))),
              const SizedBox(height: 6),
              _pad(Column(children: [
                for (int i = 0; i < _faqs.length; i++) _faq(i, _faqs[i][0], _faqs[i][1]),
              ])),

              const SizedBox(height: 22),
              _pad(Text("Small cohorts by design - so your coach actually knows your baby's name.",
                  textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
            ],
          ),

          Positioned(left: 0, right: 0, bottom: 0, child: _ctaBar(context)),
        ]),
      ),
    );
  }

  Widget _fact(String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label, style: ppBody(11, color: ppMuted)),
          ]),
        ),
      );

  Widget _week(String tag, String title, String when, List<String> topics) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ppEyebrow(tag, color: ppPurple, spacing: 1.0),
            const Spacer(),
            const Icon(Icons.videocam_outlined, size: 15, color: ppSoft),
            const SizedBox(width: 5),
            Flexible(child: Text(when, textAlign: TextAlign.right, style: ppBody(11, color: ppSoft, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
          Text(title, style: ppJakarta(16)),
          const SizedBox(height: 10),
          for (final t in topics)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(margin: const EdgeInsets.only(top: 7), width: 5, height: 5, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle)),
                const SizedBox(width: 11),
                Expanded(child: Text(t, style: ppBody(13, color: ppInk, h: 1.5))),
              ]),
            ),
        ]),
      );

  Widget _incl(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.check_rounded, size: 18, color: ppPurple),
          const SizedBox(width: 11),
          Expanded(child: Text(t, style: ppBody(14, color: ppInk, h: 1.5))),
        ]),
      );

  Widget _faq(int i, String q, String a) {
    final open = _openFaq == i;
    return GestureDetector(
      onTap: () => setState(() => _openFaq = open ? -1 : i),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: ppHair))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(q, style: ppBody(14, color: ppInk, w: FontWeight.w700))),
            const SizedBox(width: 10),
            Icon(open ? Icons.remove : Icons.add, size: 18, color: ppMuted),
          ]),
          if (open) ...[const SizedBox(height: 8), Text(a, style: ppBody(13, h: 1.55))],
        ]),
      ),
    );
  }

  Widget _ctaBar(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00FBF9FE), ppBg], stops: [0, 0.22]),
        ),
        child: Row(children: [
          Flexible(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: '₹8,999', style: ppBody(16, color: ppInk, w: FontWeight.w700)),
                  TextSpan(text: '  ₹12,999', style: ppBody(12, color: ppMuted).copyWith(decoration: TextDecoration.lineThrough)),
                ]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text('+ 18% GST · or ParentVeda+ Pro',
                  style: ppBody(11, color: ppPurple, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: () => _soon(context),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
                child: Text('Join cohort', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
              ),
            ),
          ),
        ]),
      );
}

class _PlayDisc extends StatelessWidget {
  const _PlayDisc(this.size);
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
        child: Icon(Icons.play_arrow_rounded, color: ppPurple, size: size * 0.5),
      );
}
