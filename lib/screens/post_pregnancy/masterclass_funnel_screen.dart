// =============================================================================
//  MasterclassFunnelScreen - Masterclass · full page (parenting · S11·detail)
// -----------------------------------------------------------------------------
//  The sales/detail page for a single masterclass: intro video, quick facts,
//  what's covered, what you walk away with, the expert, a testimonial, an FAQ
//  accordion, and a sticky "Reserve a seat" bar. Reached from Masterclasses →
//  any class. Faithful build of Claude Design · S11·detail.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_experts_data.dart';
import 'provider_profile_screen.dart';

class MasterclassFunnelScreen extends StatefulWidget {
  const MasterclassFunnelScreen({super.key});

  @override
  State<MasterclassFunnelScreen> createState() => _MasterclassFunnelScreenState();
}

class _MasterclassFunnelScreenState extends State<MasterclassFunnelScreen> {
  int _openFaq = 0;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _openExpert(BuildContext context, String id) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => ProviderProfileScreen(expert: expertById(id))));

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking opens soon'), behavior: SnackBarBehavior.floating),
      );

  static const List<List<String>> _faqs = [
    [
      "What if I can't attend live?",
      "The recording lands in your library within 24 hours, and it's yours forever.",
    ],
    [
      'Is this cry-it-out?',
      'No. Everything Dr. Rao teaches is gentle, responsive settling - never leaving {child} to cry it out.',
    ],
    [
      'In Hindi or English?',
      'The live session is in English; the recording includes a Hindi voiceover, so you can watch in whichever you prefer.',
    ],
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
                ppBack(context, 'Masterclasses'),
                ppLangToggle(),
              ])),

              // intro video hero
              const SizedBox(height: 18),
              _pad(GestureDetector(
                onTap: () => _soon(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(children: [
                    const PpStriped(height: 200, radius: 22, border: true),
                    const Positioned.fill(
                      child: Center(
                        child: _PlayDisc(56),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(999)),
                        child: Text('Watch the 90-sec intro', style: ppBody(11, color: Colors.white, w: FontWeight.w600)),
                      ),
                    ),
                  ]),
                ),
              )),

              // title block
              const SizedBox(height: 20),
              _pad(Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: ppCoral, borderRadius: BorderRadius.circular(999)),
                  child: Text('LIVE · Sun 13 Jul, 8pm', style: ppBody(11, color: Colors.white, w: FontWeight.w700)),
                ),
              )),
              const SizedBox(height: 12),
              _pad(Text('The 4-Month Sleep Regression, Solved', style: ppFraunces(30, h: 1.15))),
              const SizedBox(height: 12),
              _pad(Text(
                  "Why it happens, why it's temporary, and exactly what to do tonight. One focused evening that gives you a plan for {child}'s upside-down sleep.",
                  style: ppBody(15))),

              // quick facts
              const SizedBox(height: 20),
              _pad(Row(children: [
                _fact('90 min', 'live'),
                const SizedBox(width: 10),
                _fact('Sun 13 Jul', '8:00 pm'),
                const SizedBox(width: 10),
                _fact('Forever', 'recording'),
              ])),

              // what's covered
              const SizedBox(height: 28),
              _pad(Text('What this masterclass covers', style: ppJakarta(18))),
              const SizedBox(height: 6),
              _pad(Column(children: [
                _covers('Why sleep cycles mature at 4 months - the science, simply.', top: true),
                _covers('The link between the 4-month brain change and the sleep regression.'),
                _covers('Building a wind-down routine that actually sticks.'),
                _covers('Drowsy-but-awake, and gentle no-cry-it-out settling.'),
                _covers('Night wakings and naps in Indian joint-family homes.'),
                _covers('A live Q&A - bring your exact situation.'),
              ])),

              // walk away with
              const SizedBox(height: 24),
              _pad(Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ppEyebrow("What you'll walk away with", color: ppBrown, spacing: 0.8),
                  const SizedBox(height: 14),
                  _take('A calm, repeatable bedtime routine you can start tonight.'),
                  _take('The reassurance that this phase is normal - and ends.'),
                  _take('A printable one-page plan, yours to keep.'),
                ]),
              )),

              // coach
              const SizedBox(height: 28),
              _pad(Row(children: [
                Expanded(child: Text('Your expert', style: ppJakarta(18))),
                GestureDetector(
                  onTap: () => _openExpert(context, 'ananya'),
                  behavior: HitTestBehavior.opaque,
                  child: Text('View profile →', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
                ),
              ])),
              const SizedBox(height: 14),
              _pad(GestureDetector(
                onTap: () => _openExpert(context, 'ananya'),
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
                      Text('Dr. Ananya Rao', style: ppJakarta(16)),
                      const SizedBox(height: 2),
                      Text('Paediatrician · 15 years', style: ppBody(12)),
                      const SizedBox(height: 8),
                      Text(
                          'Has guided thousands of Indian families through the fourth-month wobble. Calm, practical, no cry-it-out.',
                          style: ppBody(13, h: 1.55)),
                    ]),
                  ),
                ]),
              )),

              // testimonial
              const SizedBox(height: 26),
              _pad(Text('What parents say', style: ppJakarta(18))),
              const SizedBox(height: 14),
              _pad(Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFECE5F2))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('★★★★★', style: ppBody(13, color: ppCoral, w: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text('“We went from five wakings to two in a week. I finally slept.”',
                      style: ppBody(15, color: ppInk, h: 1.55)),
                  const SizedBox(height: 10),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: 'Sneha K. ', style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                    TextSpan(text: '· mother of a 4-month-old', style: ppBody(13, color: ppMuted)),
                  ])),
                ]),
              )),

              // FAQ
              const SizedBox(height: 26),
              _pad(Text('Common questions', style: ppJakarta(18))),
              const SizedBox(height: 6),
              _pad(Column(children: [
                for (int i = 0; i < _faqs.length; i++) _faq(i, _faqs[i][0], ppFill(_faqs[i][1])),
              ])),

              const SizedBox(height: 22),
              _pad(Text('Led by a verified paediatrician. Free with ParentVeda+.',
                  textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
            ],
          ),

          // sticky reserve bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ctaBar(context),
          ),
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

  Widget _covers(String t, {bool top = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: Border(top: top ? const BorderSide(color: ppHair) : BorderSide.none),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 5,
            height: 5,
            decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle),
          ),
          const SizedBox(width: 13),
          Expanded(child: Text(t, style: ppBody(14, color: ppInk, h: 1.55))),
        ]),
      );

  Widget _take(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.check_rounded, size: 18, color: ppPurple),
          const SizedBox(width: 10),
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
          if (open) ...[
            const SizedBox(height: 8),
            Text(a, style: ppBody(13, h: 1.55)),
          ],
        ]),
      ),
    );
  }

  Widget _ctaBar(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00FBF9FE), ppBg],
            stops: [0, 0.22],
          ),
        ),
        child: Row(children: [
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('₹1,499', style: ppBody(16, color: ppInk, w: FontWeight.w700)),
            Text('free on ParentVeda+', style: ppBody(11, color: ppPurple, w: FontWeight.w600)),
          ]),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: () => _soon(context),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
                child: Text('Reserve a seat', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
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
