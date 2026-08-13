// =============================================================================
//  MasterclassDetailScreen (S6) - Prepare › Masterclass full page
//  Data-driven (any Masterclass). Intro play → placeholder video; sticky CTA →
//  mock booking flow (reflects "Reserved" after).
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/prepare_data.dart';
import 'prepare_common.dart';
import 'prepare_video_screen.dart';
import '../../theme/pv_fonts.dart';
import '../../localization/app_language.dart';

class MasterclassDetailScreen extends StatelessWidget {
  const MasterclassDetailScreen({super.key, required this.m, required this.lang});

  final Masterclass m;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    final when = m.facts.length >= 2 ? '${m.facts[1].big} · ${m.facts[1].small}' : null;

    return Scaffold(
      backgroundColor: kCanvas,
      body: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // hero
            SizedBox(
              height: 250,
              child: Stack(children: [
                const PvStriped(height: 250, colorA: Color(0xFFE4D5F0), colorB: kStripeA),
                Positioned(
                  top: 52,
                  left: 20,
                  right: 20,
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: _circle(const Icon(Icons.arrow_back, size: 16, color: kInk)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(999)),
                      child: pvLangToggle(lang),
                    ),
                  ]),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PrepareVideoScreen(
                            lang: lang,
                            title: s.prepIntroOf('${m.title}'),
                            subtitle: s.prepNinetySecPreview))),
                    child: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Color(0x662F2C30), blurRadius: 24, offset: Offset(0, 8)),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text('▶', style: TextStyle(color: kPurple, fontSize: 22)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: kInk.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(999)),
                    child: Text(s.uiWatchSecIntro,
                        style: pvManrope(
                            fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (m.badge != null)
                  pvPill(m.badge!.now,
                      bg: m.badgeIsCoral ? kCoralTint : kPanel, fg: m.badgeIsCoral ? kCoral : kPurple),
                if (m.badge != null) const SizedBox(height: 14),
                Text(m.title.now, style: pvHeroStyle().copyWith(fontSize: 30, height: 1.15)),
                const SizedBox(height: 12),
                Text(m.longDesc.now, style: pvSubStyle()),
                const SizedBox(height: 18),
                Row(children: [
                  for (int i = 0; i < m.facts.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    _fact(m.facts[i]),
                  ],
                ]),

                _divider(),
                _sectionTitle(s.prepWalkAwayWith),
                const SizedBox(height: 12),
                for (final l in m.learn) _check(l.now),

                _divider(),
                _sectionTitle(
                    m.coaches.length > 1 ? s.prepMeetYourCoaches : s.prepMeetYourCoach),
                const SizedBox(height: 14),
                for (int i = 0; i < m.coaches.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  _coach(m.coaches[i]),
                ],

                if (m.testimonials.isNotEmpty) ...[
                  _divider(),
                  _sectionTitle(s.prepWhatMothersSay),
                  const SizedBox(height: 14),
                  for (int i = 0; i < m.testimonials.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _testimonial(m.testimonials[i]),
                  ],
                ],

                if (m.faqs.isNotEmpty) ...[
                  _divider(),
                  _sectionTitle(s.prepCommonQuestions),
                  const SizedBox(height: 6),
                  for (int i = 0; i < m.faqs.length; i++)
                    m.faqs[i].a != null
                        ? _faqOpen(m.faqs[i].q.now, m.faqs[i].a!.now)
                        : _faqClosed(m.faqs[i].q.now, bottom: i == m.faqs.length - 1),
                ],

                pvFooterNote(s.prepFooterMasterclassDetail),
              ]),
            ),
          ]),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: PvStickyCta(
            lang: lang,
            id: m.id,
            price: m.price,
            note: s.prepFreeOnPlusShort,
            noteColor: kPurple,
            label: s.uiReserveSeat,
            bookedLabel: s.prepReserved,
            onBook: () => showPrepareBooking(
              context,
              lang: lang,
              id: m.id,
              title: m.title.now,
              priceLabel: '${m.price} · ${s.prepFreeOnPlusShort}',
              whenLabel: when,
              heading: s.prepReserveYourSeat,
              cta: s.prepReserveMySeat,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _circle(Widget child) => Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
        child: child,
      );

  Widget _fact(QuickFact f) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Text(f.big.now, style: pvTitleStyle(14), textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(f.small.now, style: pvBody(kMuted, 11)),
          ]),
        ),
      );

  Widget _divider() => const Padding(
      padding: EdgeInsets.symmetric(vertical: 24), child: Divider(height: 1, color: Color(0xFFE4E2E5)));

  Widget _sectionTitle(String t) => Text(t, style: pvTitleStyle(17));

  Widget _check(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: kPanel, shape: BoxShape.circle),
            child: const Text('✓', style: TextStyle(color: kPurple, fontSize: 11)),
          ),
          const SizedBox(width: 11),
          Expanded(child: Text(text, style: pvBody(kInk, 14))),
        ]),
      );

  Widget _coach(Coach c) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pvAvatar(56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.name.now, style: pvTitleStyle(15)),
              const SizedBox(height: 1),
              Text(c.role.now, style: pvBody(kPurple, 12).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              Text(c.bio.now, style: pvBody(kSoft, 13).copyWith(height: 1.55)),
            ]),
          ),
        ],
      );

  Widget _testimonial(Testimonial t) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('★★★★★', style: TextStyle(color: kCoral, fontSize: 13)),
          const SizedBox(height: 8),
          Text(t.quote.now, style: pvFraunces(fontSize: 16, height: 1.5, color: kInk)),
          const SizedBox(height: 12),
          Text.rich(TextSpan(children: [
            TextSpan(text: t.who.now, style: const TextStyle(color: kInk, fontWeight: FontWeight.w700)),
            TextSpan(text: ' · ${t.when}', style: const TextStyle(color: kSoft)),
          ]), style: pvBody(kSoft, 12)),
        ]),
      );

  Widget _faqOpen(String q, String a) => Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: kHair))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(q, style: pvBody(kInk, 14).copyWith(fontWeight: FontWeight.w600))),
            const Text('−', style: TextStyle(color: kMuted)),
          ]),
          const SizedBox(height: 8),
          Text(a, style: pvBody(kSoft, 13).copyWith(height: 1.55)),
        ]),
      );

  Widget _faqClosed(String q, {bool bottom = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
            border: Border(
          top: const BorderSide(color: kHair),
          bottom: bottom ? const BorderSide(color: kHair) : BorderSide.none,
        )),
        child: Row(children: [
          Expanded(child: Text(q, style: pvBody(kInk, 14).copyWith(fontWeight: FontWeight.w600))),
          const Text('+', style: TextStyle(color: kMuted)),
        ]),
      );
}
