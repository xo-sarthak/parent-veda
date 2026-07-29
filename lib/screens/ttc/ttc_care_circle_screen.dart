// =============================================================================
//  TTC - Care Circle
// -----------------------------------------------------------------------------
//      "Instead of Doctor, Hospital, Partner being isolated, the app introduces
//       Your Care Circle... showing that building a family is a shared
//       journey."                                        - TTC master, §2.15
//
//      "Every recommendation stores its source. Everything becomes transparent.
//       Users know why something appears."               - TTC master, §4.13
//
//  The second quote is the one that matters technically, and it is why this
//  screen exists rather than a contacts list: the Care Circle is the visible
//  half of recommendation provenance. A parent should be able to look at any
//  suggestion in the product and trace it to someone.
//
//  Today the circle holds ParentVeda and the partner. Adding doctors, clinics
//  and nutritionists needs the care-partner attribution question settled first
//  (docs/STILL-OPEN.md §2.1) - so this screen shows the shape honestly rather
//  than pretending to a fuller circle than the platform can currently keep.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_store.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

class TtcCareCircleScreen extends StatelessWidget {
  const TtcCareCircleScreen({super.key});

  /// The roles a circle can eventually hold, from §2.15.
  static const List<(String, String, String)> roles = [
    ('parentveda', 'ParentVeda', 'Everything you see here, and why'),
    ('partner', 'Your partner', 'The other half of this'),
    ('doctor', 'Your doctor', 'Consultations, notes and prescriptions'),
    ('nutritionist', 'Nutritionist', 'Food plans built for your kitchen'),
    ('psychologist', 'Psychologist', 'For the days that are simply hard'),
    ('clinic', 'Clinic or hospital', 'Where your tests and scans happen'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final partnerJoined = TtcStore.instance.partnerJoined;

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
              children: [
                TtcBackBar(title: t.careCircle),
                const SizedBox(height: 16),
                Text(t.careCircleIntro, style: ttcBody(14, h: 1.6)),
                const SizedBox(height: 20),

                // ParentVeda is always in the circle, and is named as a source
                // rather than treated as neutral background.
                _Member(
                  icon: Icons.spa_rounded,
                  name: 'ParentVeda',
                  detail: hi
                      ? 'Har salaah ke saath ye likha hota hai ki wo kahan se aayi'
                      : 'Every suggestion here says where it came from',
                  present: true,
                  t: t,
                ),
                const SizedBox(height: 10),
                _Member(
                  icon: Icons.people_outline_rounded,
                  name: t.careCirclePartner,
                  detail: partnerJoined ? t.careCircleJoined : t.careCircleInvite,
                  present: partnerJoined,
                  t: t,
                ),
                const SizedBox(height: 20),

                ttcSectionTitle(t.careCircleAdd),
                TtcCard(
                  color: ttcPanel,
                  child: Text(t.careCircleEmpty, style: ttcBody(13.5, h: 1.55)),
                ),
                const SizedBox(height: 12),
                for (final (id, en, detail) in roles.skip(2)) ...[
                  TtcCard(
                    onTap: () => ttcSoon(context, en),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: ttcBg, shape: BoxShape.circle),
                        child: Icon(_iconFor(id), size: 17, color: ttcMuted),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(en, style: ttcJakarta(14.5, color: ttcSoft)),
                              const SizedBox(height: 2),
                              Text(detail, style: ttcBody(12)),
                            ]),
                      ),
                      const Icon(Icons.add_rounded, size: 18, color: ttcMuted),
                    ]),
                  ),
                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 12),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.verified_outlined, size: 15, color: ttcMuted),
                  const SizedBox(width: 9),
                  Expanded(
                    child:
                        Text(t.careCircleWhy, style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  static IconData _iconFor(String id) {
    switch (id) {
      case 'doctor':
        return Icons.medical_services_outlined;
      case 'nutritionist':
        return Icons.restaurant_outlined;
      case 'psychologist':
        return Icons.psychology_outlined;
      case 'clinic':
        return Icons.local_hospital_outlined;
      default:
        return Icons.person_outline_rounded;
    }
  }
}

class _Member extends StatelessWidget {
  const _Member({
    required this.icon,
    required this.name,
    required this.detail,
    required this.present,
    required this.t,
  });

  final IconData icon;
  final String name;
  final String detail;
  final bool present;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    return TtcCard(
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: present ? ttcPanel : ttcBg,
              shape: BoxShape.circle,
              border: present ? null : Border.all(color: ttcLine)),
          child: Icon(icon, size: 19, color: present ? ttcPurple : ttcMuted),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: ttcJakarta(15.5)),
            const SizedBox(height: 3),
            Text(detail, style: ttcBody(12.5)),
          ]),
        ),
      ]),
    );
  }
}
