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
import '../post_pregnancy/yoga_home_screen.dart';
// import 'prenatal_yoga_screen.dart'; // retired — replaced by YogaHomeScreen
import 'prepare_common.dart';
import 'program_detail_screen.dart';
import '../../localization/app_language.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart' show PvMarkWell;
import '../pregnancy/preg_chrome.dart' show PregNote, PregSectionHeading, pregGroupLabelStyle;
import '../products/pv_store_chrome.dart' show kPvLine, pvStorePalette;

/// A caps string read as a sentence ("RECOMMENDED AT 30 WEEKS" becomes
/// "Recommended at 30 weeks"), so a heading that was a grey caps label can
/// take the one serif heading without its copy changing. Leaves a string
/// with no Latin capitals (Hindi) exactly as it is.
String _sentenceCase(String t) {
  if (t.isEmpty || t != t.toUpperCase() || t == t.toLowerCase()) return t;
  final l = t.toLowerCase();
  return l[0].toUpperCase() + l.substring(1);
}

class PrepareHubScreen extends StatelessWidget {
  const PrepareHubScreen({super.key, required this.lang, this.backLabel});

  /// Set when PUSHED (from the Tools hub, since 2026-09-17) so the top bar
  /// grows a back arrow; null when it was a tab root under the pill.
  final String? backLabel;

  /// The language to render in.
  ///
  /// Passed down from MainScaffold, which builds this tab inside an
  /// AnimatedBuilder on the PregnancyController - so flipping the language in
  /// Profile repaints the hub immediately. Reading a global static here
  /// instead would compile, render correctly on a cold start, and then fail
  /// to repaint on a change, which is the bug this tab already had.
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
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
            pad(pvTopBar(context, lang: lang, title: s.uiPrepare, backLabel: backLabel)),
            const SizedBox(height: 22),

            // hero
            pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              pvEyebrow(s.prepHubEyebrow),
              const SizedBox(height: 12),
              Text(s.uiPrepareBabyNoneGuided, style: pvHeroStyle()),
              const SizedBox(height: 14),
              Text(s.uiCoursesLiveCohortsExpert,
                  style: pvSubStyle()),
            ])),

            const SizedBox(height: 26),
            // One section heading (2026-09-30): the serif. Kept for revert:
            // pad(Text(s.uiRecommendedWeeks, style: pvBody(kSoft, 11)
            //     .copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.1))),
            pad(PregSectionHeading(_sentenceCase(s.uiRecommendedWeeks))),
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
                      tag: s.prepTagMasterclass,
                      tagColor: kPurple,
                      mark: IntentMark.lampMark,
                      hue: 240,
                      title: railMasterclass.title.now,
                      meta: '${railMasterclass.durationLabel} · ${railMasterclass.price}',
                      onTap: () =>
                          openSection(ProgramDetailScreen(program: railMasterclass, lang: lang)),
                    ),
                  const SizedBox(width: 14),
                  if (railCohort != null)
                    _railCard(
                      tag: s.prepTagCohortStartsMon,
                      tagColor: kCoral,
                      mark: IntentMark.seatMark,
                      hue: 160,
                      title: railCohort.title.now,
                      meta: '${railCohort.durationLabel} · ${railCohort.price}',
                      onTap: () =>
                          openSection(ProgramDetailScreen(program: railCohort, lang: lang)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // category tiles - the four sections
            pad(Column(children: [
              _tile(context, IntentMark.schoolMark, 240, s.uiCoursesCohorts,
                  s.prepTileCoursesSub, s.prepProgramsCount(kPrepPrograms.length),
                  top: true, onTap: () => openSection(CoursesCohortsScreen(lang: lang))),
              _tile(context, IntentMark.cuppedHands, 20, s.uiBirthingClasses,
                  s.prepTileBirthingSub, s.prepTileBirthingCount,
                  onTap: () => openSection(BirthingClassesScreen(lang: lang))),
              // Yoga now uses the SAME cult.fit screen as the parenting side,
              // filtered to pregnancy categories — one UI both tabs. The old
              // month-tabbed PrenatalYogaScreen is retired (kept for revert).
              _tile(context, IntentMark.lotusMark, 160, s.uiYoga, s.prepTileYogaSub,
                  s.prepTileYogaCount, onTap: () => openSection(YogaHomeScreen(
                        categoryFilter: kPregnancyYogaCategories,
                        backLabel: s.uiPrepare,
                        eyebrow: s.prepYogaEyebrow,
                        heroTitle: s.prepYogaHeroTitle,
                        intro: s.prepYogaIntro,
                      ))),
              // _tile(context, Icons.self_improvement_rounded, 'Yoga', 'Trimester-safe movement, month by month.',
              //     '9-month program', onTap: () => openSection(const PrenatalYogaScreen())),
              _tile(context, IntentMark.plate, 30, s.uiNutrition,
                  s.prepTileNutritionSub, s.prepTileNutritionCount,
                  bottom: true, onTap: () => openSection(NutritionScreen(lang: lang))),
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
            // A quiet note on the page, not a grey panel behind text
            // (2026-09-30). Kept for revert: a Container on `kPanel`, radius
            // 18, holding the icon and
            //   Text.rich(TextSpan(children: [
            //     // "Most are free, or included with ParentVeda+":
            //     //   pvText(s.uiMostFree), pvPurple('ParentVeda+'), pvText('.'),
            //     pvText(s.uiMostFreeRest),
            //   ]), style: pvBody(kInk, 13)),
            pad(PregNote(s.uiMostFreeRest, icon: Icons.auto_awesome_outlined)),
          ],
        ),
      ),
    );
  }

  // ⚠️ ONE PARENTVEDA (2026-09-30): the hairline and no shadow; the drawn
  // mark in its well where a striped placeholder image stood (no placeholder
  // images); the tag in the grey group label, ink rather than a coloured word.
  // Kept for revert: `boxShadow: pvCardShadow`, `const PvStriped(height: 100)`,
  // and the tag styled `pvBody(tagColor, 10)` w700 +0.6.
  Widget _railCard({
    required String tag,
    required Color tagColor,
    required IntentMark mark,
    required double hue,
    required String title,
    required String meta,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 230,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kPvLine),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: PvMarkWell(p: pvStorePalette, hue: hue, size: 64, mark: mark),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(14),
              width: double.infinity,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tag.toUpperCase(), style: pregGroupLabelStyle()),
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

  // A row that opens somewhere carries a drawn mark in its tint (2026-09-30).
  // Kept for revert: a 44pt `kPanel` box holding `Icon(icon, color: kPurple)`,
  // and a '→' glyph under the count where the chevron now is.
  Widget _tile(BuildContext context, IntentMark mark, double hue, String title, String sub, String count,
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
          PvMarkWell(p: pvStorePalette, hue: hue, size: 44, mark: mark),
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
            const Icon(Icons.chevron_right_rounded, size: 20, color: kMuted),
          ]),
        ]),
      ),
    );
  }
}
