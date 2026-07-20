// =============================================================================
//  PhaseDetailScreen — one age phase, in full
// -----------------------------------------------------------------------------
//  Replaces LeapDefinitionScreen. Same job — help a parent understand what is
//  happening right now — but built on the AAP/CDC milestone framework rather
//  than fixed-week leaps.
//
//  Order is deliberate:
//    1. what this phase IS, and the reassurance line (the 3am question)
//    2. what he is working on
//    3. milestones, grouped by the five AAP domains
//    4. the fuller description
//    5. screening prompt, where AAP recommends one
//    6. the Indian-context layer
//
//  Milestones use the AAP 75% threshold — "most children can do this by now",
//  not "average" — which the 2022 revision adopted specifically to stop parents
//  waiting and seeing. That is why the framing is definite rather than vague,
//  and why every screen carries a "talk to your doctor" route.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_phases_data.dart';

class PhaseDetailScreen extends StatelessWidget {
  const PhaseDetailScreen({super.key, required this.phase});
  final AgePhase phase;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final p = phase;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'His journey')),
            const SizedBox(height: 18),
            _pad(Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(p.ageLabel,
                    style: ppBody(11.5, color: p.accent, w: FontWeight.w800)),
              ),
              if (p.checkpoint) ...[
                const SizedBox(width: 8),
                const Icon(Icons.verified_outlined, size: 15, color: ppMuted),
                const SizedBox(width: 4),
                Flexible(
                  child: Text('Doctor checkpoint',
                      style: ppBody(11.5, color: ppMuted, w: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ])),
            const SizedBox(height: 12),
            _pad(Text(p.name, style: ppFraunces(30, h: 1.1))),
            const SizedBox(height: 6),
            _pad(Text(p.tagline, style: ppBody(14.5, color: p.accent, w: FontWeight.w700))),
            const SizedBox(height: 14),
            _pad(Text(p.summary, style: ppBody(15, color: ppInk, h: 1.65))),

            // The reassurance line — the thing a worried parent came for.
            const SizedBox(height: 18),
            _pad(Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ppPanel,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.favorite_border, size: 17, color: ppCoral),
                const SizedBox(width: 11),
                Expanded(child: Text(p.reassurance, style: ppBody(13.5, color: ppInk, h: 1.6))),
              ]),
            )),

            // ---- working on ----
            const SizedBox(height: 26),
            _pad(Text('What he is working on', style: ppJakarta(18))),
            const SizedBox(height: 12),
            _pad(Column(children: [
              for (final w in p.workingOn)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 7),
                      decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 11),
                    Expanded(child: Text(w, style: ppBody(14, color: ppInk, h: 1.55))),
                  ]),
                ),
            ])),

            // ---- milestones by domain ----
            const SizedBox(height: 22),
            _pad(Text('Most children can, by the end of this phase', style: ppJakarta(18))),
            const SizedBox(height: 4),
            _pad(Text(
              'These are the milestones about three in four children reach by this age — not an average, and not a deadline.',
              style: ppBody(12.5, color: ppMuted, h: 1.45),
            )),
            const SizedBox(height: 14),
            for (final d in PhaseDomain.values)
              if (p.inDomain(d).isNotEmpty) _pad(_domainCard(p, d)),

            // ---- fuller description ----
            for (final s in p.sections) ...[
              const SizedBox(height: 22),
              _pad(Text(s.heading, style: ppJakarta(17))),
              const SizedBox(height: 10),
              for (final para in s.paragraphs) ...[
                _pad(Text(para, style: ppBody(14.5, color: ppInk, h: 1.65))),
                const SizedBox(height: 12),
              ],
            ],

            // ---- screening ----
            if (p.screeningNote != null) ...[
              const SizedBox(height: 12),
              _pad(Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: ppPurple.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: ppPurple.withValues(alpha: 0.20)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.fact_check_outlined, size: 17, color: ppPurple),
                    const SizedBox(width: 9),
                    Expanded(child: Text('A screening is due around now', style: ppJakarta(15))),
                  ]),
                  const SizedBox(height: 9),
                  Text(p.screeningNote!, style: ppBody(13.5, color: ppInk, h: 1.6)),
                  const SizedBox(height: 8),
                  Text(
                    'Screening at these visits is for every child. Being screened says nothing about yours.',
                    style: ppBody(12.5, color: ppSoft, h: 1.5),
                  ),
                ]),
              )),
            ],

            // ---- Indian context ----
            if (p.indianNote != null) ...[
              const SizedBox(height: 14),
              _pad(Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFFC98A2B).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('FOR INDIAN FAMILIES',
                      style: ppBody(9.5, color: const Color(0xFF9A6B12), w: FontWeight.w800)
                          .copyWith(letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  Text(p.indianNote!, style: ppBody(13.5, color: ppInk, h: 1.6)),
                ]),
              )),
            ],

            const SizedBox(height: 22),
            _pad(Text(
              'Based on the AAP/CDC 2022 developmental milestone framework. Guidance to help you notice things — never a diagnosis, and never a substitute for your paediatrician.',
              textAlign: TextAlign.center,
              style: ppBody(11.5, color: ppMuted, h: 1.55),
            )),
          ],
        ),
      ),
    );
  }

  Widget _domainCard(AgePhase p, PhaseDomain d) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppHair),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(d.icon, size: 16, color: p.accent),
            const SizedBox(width: 9),
            Expanded(child: Text(d.label, style: ppJakarta(14.5))),
          ]),
          const SizedBox(height: 10),
          for (final m in p.inDomain(d))
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.check_rounded, size: 14, color: ppMuted),
                const SizedBox(width: 9),
                Expanded(child: Text(m.text, style: ppBody(13.5, color: ppInk, h: 1.5))),
              ]),
            ),
        ]),
      );
}
