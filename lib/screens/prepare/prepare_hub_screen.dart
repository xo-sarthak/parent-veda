// =============================================================================
//  PrepareHubScreen (S0) - the "Prepare" tab root
// -----------------------------------------------------------------------------
//  Landing for ParentVeda's guided/paid experiences. Sits under the real
//  PvTabBar (rendered by MainScaffold), so it draws no nav of its own - just a
//  generous bottom pad to clear the floating pill.
//
//  Reworked (Section 4): the hub now surfaces four sections -
//    1. Courses & Cohorts  (unified V2 - CoursesCohortsScreen)
//    2. Birthing Classes   (kept as-is)
//    3. Yoga               (renamed from Prenatal Yoga; month tabs)
//    4. Nutrition          (Assessment -> plans -> trailer -> consult -> plan)
//  The old standalone Masterclasses / 1:1 Consultations / Cohort Programs tiles
//  are folded in (Masterclasses & Cohorts live inside Courses & Cohorts; the
//  nutritionist consult is reached through the Nutrition funnel) and are kept
//  commented below for revert. Their screens remain in the module.
// =============================================================================

import '../../brand/brand_models.dart';
import '../../brand/presented_by.dart';
import 'package:flutter/material.dart';

import '../../data/prepare_data.dart';
import 'birthing_classes_screen.dart';
// import 'cohort_detail_screen.dart'; // retired from hub - see Courses & Cohorts
// import 'cohorts_screen.dart';
// import 'consultations_screen.dart';
// import 'masterclass_detail_screen.dart';
// import 'masterclasses_screen.dart';
import 'courses_cohorts_screen.dart';
import 'nutrition_screen.dart';
import 'prenatal_yoga_screen.dart';
import 'prepare_common.dart';
import 'program_detail_screen.dart';

class PrepareHubScreen extends StatelessWidget {
  const PrepareHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

    void openSection(Widget s) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

    // Featured programs for the recommended rail (from the unified catalogue).
    final railMasterclass = programById('prog_mc_birth');
    final railCohort = programById('prog_ch_birthready');

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
              Text('Courses, live cohorts, expert sessions, and gentle movement - chosen for exactly where you are.',
                  style: pvSubStyle()),
            ])),

            const SizedBox(height: 26),
            pad(Text('RECOMMENDED AT 30 WEEKS',
                style: pvBody(kSoft, 11).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.1))),
            const SizedBox(height: 14),

            // Renders nothing unless the live sessions are sponsored. The
            // experts stay independent — a brand funds the room, it does not
            // choose the answers given in it.
            pad(const PresentedBy(
              slot: BrandSlot.liveSession,
              stage: BrandStage.pregnancy,
              placementKey: 'prepare_hub',
              padding: EdgeInsets.only(bottom: 14),
            )),

            // recommended rail
            SizedBox(
              height: 252,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  if (railMasterclass != null)
                    _railCard(
                      tag: 'Masterclass',
                      tagColor: kPurple,
                      title: railMasterclass.title,
                      meta: '${railMasterclass.durationLabel} · ${railMasterclass.price}',
                      onTap: () => openSection(ProgramDetailScreen(program: railMasterclass)),
                    ),
                  const SizedBox(width: 14),
                  if (railCohort != null)
                    _railCard(
                      tag: 'Cohort · starts Mon',
                      tagColor: kCoral,
                      title: railCohort.title,
                      meta: '${railCohort.durationLabel} · ${railCohort.price}',
                      onTap: () => openSection(ProgramDetailScreen(program: railCohort)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // category tiles - the four sections
            pad(Column(children: [
              _tile(context, Icons.school_outlined, 'Courses & Cohorts',
                  'Self-paced courses, live cohorts & masterclasses.', '${kPrepPrograms.length} programs',
                  top: true, onTap: () => openSection(const CoursesCohortsScreen())),
              _tile(context, Icons.child_friendly_outlined, 'Birthing Classes', 'Everything for the big day.',
                  '6-class course', onTap: () => openSection(const BirthingClassesScreen())),
              _tile(context, Icons.self_improvement_rounded, 'Yoga', 'Trimester-safe movement, month by month.',
                  '9-month program', onTap: () => openSection(const PrenatalYogaScreen())),
              _tile(context, Icons.restaurant_outlined, 'Nutrition',
                  'A plan built around you, made yours by an expert.', 'Plan + consult',
                  bottom: true, onTap: () => openSection(const NutritionScreen())),
              // --- retired standalone tiles (folded into the above) --------------
              // _tile(context, Icons.school_outlined, 'Masterclasses', 'Deep-dive live sessions with experts.',
              //     '4 sessions', onTap: () => openSection(const MasterclassesScreen())),
              // _tile(context, Icons.chat_bubble_outline_rounded, '1:1 Consultations', 'A private call with the right expert.',
              //     '5 specialists', onTap: () => openSection(const ConsultationsScreen())),
              // _tile(context, Icons.groups_outlined, 'Cohort Programs',
              //     'Small groups, a real coach, mums due when you are.', '4 programs',
              //     onTap: () => openSection(const CohortsScreen())),
            ])),

            const SizedBox(height: 22),
            pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18)),
              child: Row(children: [
                const Icon(Icons.auto_awesome_outlined, size: 16, color: kPurple),
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
                Text(meta, style: pvBody(kSoft, 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String sub, String count,
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
            child: Icon(icon, size: 22, color: kPurple),
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
