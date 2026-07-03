// =============================================================================
//  PrepareHubScreen (S0) — the "Prepare" tab root
// -----------------------------------------------------------------------------
//  Landing for ParentVeda's guided/paid experiences. Sits under the real
//  PvTabBar (rendered by MainScaffold), so it draws no nav of its own — just a
//  generous bottom pad to clear the floating pill. Routes into the five section
//  screens. Faithful replica of design S0 (Priya · 30 weeks).
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/prepare_data.dart';
import 'birthing_classes_screen.dart';
import 'cohort_detail_screen.dart';
import 'cohorts_screen.dart';
import 'consultations_screen.dart';
import 'masterclass_detail_screen.dart';
import 'masterclasses_screen.dart';
import 'prenatal_yoga_screen.dart';
import 'prepare_common.dart';

class PrepareHubScreen extends StatelessWidget {
  const PrepareHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

    void openSection(Widget s) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

    return Scaffold(
      backgroundColor: kCanvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 120),
          children: [
            pad(pvTopBar(context, title: 'Prepare')),
            const SizedBox(height: 22),

            // hero
            pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              pvEyebrow('30 weeks · third trimester'),
              const SizedBox(height: 12),
              Text('Prepare for your baby,\none guided step at a time.', style: pvHeroStyle()),
              const SizedBox(height: 14),
              Text('Live classes, expert sessions, and gentle movement — chosen for exactly where you are.',
                  style: pvSubStyle()),
            ])),

            const SizedBox(height: 26),
            pad(Text('RECOMMENDED AT 30 WEEKS',
                style: pvBody(kSoft, 11).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.1))),
            const SizedBox(height: 14),

            // recommended rail
            SizedBox(
              height: 252,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _railCard(
                    tag: 'Masterclass',
                    tagColor: kPurple,
                    title: 'Birth Confidence Masterclass',
                    meta: '90 min live · ₹799',
                    onTap: () =>
                        openSection(MasterclassDetailScreen(m: kMasterclasses.firstWhere((m) => m.featured))),
                  ),
                  const SizedBox(width: 14),
                  _railCard(
                    tag: 'Cohort · starts Mon',
                    tagColor: kCoral,
                    title: 'Birth-Ready Bootcamp',
                    meta: '4 weeks · ₹6,999',
                    onTap: () =>
                        openSection(CohortDetailScreen(cohort: kCohorts.firstWhere((c) => c.featured))),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // category tiles
            pad(Column(children: [
              _tile(context, '🎓', 'Masterclasses', 'Deep-dive live sessions with experts.',
                  '4 sessions', top: true, onTap: () => openSection(const MasterclassesScreen())),
              _tile(context, '💬', '1:1 Consultations', 'A private call with the right expert.',
                  '5 specialists', onTap: () => openSection(const ConsultationsScreen())),
              _tile(context, '👭', 'Cohort Programs',
                  'Small groups, a real coach, mums due when you are.', '4 programs',
                  onTap: () => openSection(const CohortsScreen())),
              _tile(context, '🧘', 'Prenatal Yoga', 'Trimester-safe movement.', '6-week program',
                  onTap: () => openSection(const PrenatalYogaScreen())),
              _tile(context, '👶', 'Birthing Classes', 'Everything for the big day.', '6-class course',
                  bottom: true, onTap: () => openSection(const BirthingClassesScreen())),
            ])),

            const SizedBox(height: 22),
            pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18)),
              child: Row(children: [
                const Text('✨', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      pvText('Most of this is free with '),
                      pvPurple('ParentVeda+'),
                      pvText('.'),
                    ]),
                    style: pvBody(kInk, 13),
                  ),
                ),
              ]),
            )),
          ],
        ),
      ),
    );
  }

  Widget _railCard({
    required String tag,
    required Color tagColor,
    required String title,
    required String meta,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kBorder),
          boxShadow: pvCardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const PvStriped(height: 100),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(14),
              width: double.infinity,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tag.toUpperCase(),
                    style: pvBody(tagColor, 10)
                        .copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                const SizedBox(height: 6),
                Text(title, style: pvTitleStyle(16), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(meta, style: pvBody(kSoft, 12)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _tile(BuildContext context, String emoji, String title, String sub, String count,
      {bool top = false, bool bottom = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          border: Border(
            top: const BorderSide(color: kHair),
            bottom: bottom ? const BorderSide(color: kHair) : BorderSide.none,
          ),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(14)),
            child: Text(emoji, style: const TextStyle(fontSize: 19)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: pvTitleStyle(16)),
              const SizedBox(height: 2),
              Text(sub, style: pvBody(kSoft, 13)),
            ]),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(count, style: pvBody(kMuted, 12)),
            const Text('→', style: TextStyle(color: kMuted, fontSize: 15)),
          ]),
        ]),
      ),
    );
  }
}
