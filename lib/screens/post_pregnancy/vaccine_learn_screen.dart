// =============================================================================
//  VaccineLearnScreen — "Learn why" (the educational page for a vaccine)
// -----------------------------------------------------------------------------
//  A dedicated, calm explainer: why this vaccine matters, the diseases it
//  prevents, when it's given, the benefits, the common (expected) side effects,
//  and ParentVeda's gentle guidance. Reached from the Vaccination home's "Learn
//  why →" insight and the vaccine detail's "Learn" cross-link. Educational only,
//  not medical advice. Defaults to PCV (the dose due for the scenario child).
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

class VaccineLearnScreen extends StatelessWidget {
  const VaccineLearnScreen({
    super.key,
    this.vaccine = 'Pneumococcal (PCV)',
    this.importance =
        'PCV protects against pneumococcus — a bacterium behind some of the most serious infections of the first years of life. The primary series finishes around now, which is exactly when a baby’s own passive immunity from birth is fading, so the timing is what makes it powerful.',
    this.diseases = const [
      'Pneumonia — a leading cause of serious childhood illness',
      'Meningitis — infection of the lining of the brain',
      'Blood infections (sepsis)',
      'Some ear infections',
    ],
    this.timing =
        'Given as a three-dose primary series in the first months (typically at 6, 10 and 14 weeks in the Indian schedule), with a booster later in the first/second year. Dose 3 is the one due now.',
    this.benefits = const [
      'Builds strong, lasting protection right as birth immunity fades',
      'Protects against the most dangerous forms of pneumococcal disease',
      'Reduces the spread of the bacteria to others around your baby',
    ],
    this.sideEffects = const [
      'Mild soreness, redness or swelling where the shot was given',
      'A low-grade fever for a day or two',
      'Being a little more sleepy or fussy than usual',
    ],
    this.guidance =
        'Expected reactions are a good sign — they mean the immune system is responding. Offer extra cuddles and feeds, a cool compress for soreness, and paracetamol only if he’s genuinely uncomfortable, at the weight-based dose your paediatrician advises. Seek help urgently for difficult breathing, facial swelling, a seizure or unusual floppiness.',
  });

  final String vaccine;
  final String importance;
  final List<String> diseases;
  final String timing;
  final List<String> benefits;
  final List<String> sideEffects;
  final String guidance;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Vaccinations')),
            const SizedBox(height: 18),
            _pad(ppEyebrow('Why this vaccine', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text(vaccine, style: ppFraunces(30, h: 1.1))),

            const SizedBox(height: 20),
            _pad(_panel('Why it’s important', importance)),

            _pad(ppSectionDivider()),
            _pad(Text('Diseases it prevents', style: ppJakarta(17))),
            const SizedBox(height: 12),
            for (final d in diseases) _pad(_bullet(d)),

            _pad(ppSectionDivider()),
            _pad(Text('When it’s given', style: ppJakarta(17))),
            const SizedBox(height: 10),
            _pad(Text(timing, style: ppBody(14, h: 1.6))),

            _pad(ppSectionDivider()),
            _pad(Text('The benefits', style: ppJakarta(17))),
            const SizedBox(height: 12),
            for (final b in benefits) _pad(_bullet(b, icon: Icons.check_circle_outline_rounded)),

            _pad(ppSectionDivider()),
            _pad(Text('Common side effects', style: ppJakarta(17))),
            const SizedBox(height: 6),
            _pad(Text('Usually mild and short-lived — a sign the vaccine is working.', style: ppBody(12.5, color: ppMuted))),
            const SizedBox(height: 12),
            for (final s in sideEffects) _pad(_bullet(s, icon: Icons.circle, small: true)),

            _pad(ppSectionDivider()),
            _pad(_panel('ParentVeda guidance', guidance)),

            const SizedBox(height: 20),
            _pad(Text('Educational only, not medical advice — always confirm anything important with your paediatrician.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _panel(String title, String body) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ppEyebrow(title, color: ppPurple, spacing: 0.8),
          const SizedBox(height: 8),
          Text(body, style: ppBody(14, color: ppInk, h: 1.6)),
        ]),
      );

  Widget _bullet(String text, {IconData icon = Icons.arrow_right_rounded, bool small = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: EdgeInsets.only(top: small ? 6 : 2), child: Icon(icon, size: small ? 7 : 18, color: ppPurple)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: ppBody(14, color: ppInk, h: 1.5))),
        ]),
      );
}
