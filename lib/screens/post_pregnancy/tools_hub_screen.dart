// =============================================================================
//  ToolsHubScreen - Tools · hub (parenting · S22 v2 premium)
// -----------------------------------------------------------------------------
//  The Tools tab landing, premium editorial version: two "ParentVeda originals"
//  (What Changed? · Wonder Week Window) and a vertical list of everyday trackers
//  with live-status lines - including Compare (a tool in its own right, right
//  under Growth percentile). Faithful build of Claude Design "post pregnancy -
//  content.dc.html" · S22 v2. A hero tab (index 2 in the bottom-nav pill).
// =============================================================================

import 'package:flutter/material.dart';

import 'baby_naming_home_screen.dart';
// The four "Journey" tools, rebuilt from the Claude Design prompts.
import 'feeding_journey_screen.dart';
import 'growth_journey_screen.dart';
import 'milestone_journey_screen.dart';
import 'sleep_journey_screen.dart';
// Old lightweight trackers - replaced by the Journey tools above, kept for revert.
// import 'feeding_tracker_screen.dart';
// import 'sleep_tracker_screen.dart';
// Was a direct entry to the V1 finder; the front door (baby_naming_home_screen)
// now owns the V1|V2 toggle and imports NameFinderScreen itself.
// import 'name_finder_screen.dart';
import 'package:flutter/foundation.dart';

import '../../brand/brand_preview_screen.dart';
import '../../brand/brand_models.dart';
import '../../brand/launch_hub_screen.dart';
import '../product_guide/product_guide_hub_screen.dart';
import 'pp_common.dart';
import 'products_compare_screen.dart';
import 'vax_tracker_screen.dart';
// Redesigned tracker (vax_tracker_screen) is the live entry now; the old
// VaccinationScreen is kept for revert.
// import 'vaccination_screen.dart';
import 'leap_definition_screen.dart';
import 'pp_leaps_data.dart';
import 'what_changed_screen.dart';
// "Wonder Week Window" now opens the full leap page (LeapDefinitionScreen) for
// the child's current leap — the standalone WonderWeekScreen is kept for revert
// but no longer wired here.
// import 'wonder_week_screen.dart';

class ToolsHubScreen extends StatelessWidget {
  const ToolsHubScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context, [String msg = 'Coming soon']) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );

  void _push(BuildContext context, Widget s) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.only(top: 62, bottom: 116),
          children: [
            // editorial header
            _pad(ppEyebrow('Your toolkit', color: ppMuted, spacing: 1.6)),
            const SizedBox(height: 8),
            _pad(Text.rich(TextSpan(children: [
              const TextSpan(text: 'Everything, '),
              TextSpan(text: 'in one calm place.', style: ppFraunces(38, color: ppPurple, h: 1.08).copyWith(fontStyle: FontStyle.italic)),
            ]), style: ppFraunces(38, h: 1.08))),
            const SizedBox(height: 14),
            _pad(Text('Two ParentVeda originals that think with you - and the everyday trackers, quietly kept.',
                style: ppBody(15))),

            // hero: What Changed
            const SizedBox(height: 26),
            _pad(_hero(
              context,
              dark: true,
              icon: Icons.search_rounded,
              tag: 'Guided diagnostic',
              title: 'What Changed?',
              desc: "Something suddenly different with Aarav? A few gentle questions, and we'll find the likely cause.",
              cta: 'Begin',
              onTap: () => _push(context, const WhatChangedScreen()),
            )),
            const SizedBox(height: 14),
            _pad(_hero(
              context,
              dark: false,
              icon: Icons.brightness_4_outlined,
              tag: 'Live · ${currentLeap().label}',
              title: 'His Leap Window',
              desc: 'Where Aarav is in his leap, how long the storm lasts, and the calm on the other side.',
              cta: 'Open his window',
              onTap: () => _push(context, LeapDefinitionScreen(leap: currentLeap())),
            )),

            // trackers
            const SizedBox(height: 30),
            _pad(Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
              Expanded(child: Text('Everyday trackers', style: ppJakarta(17))),
              Text('the basics', style: ppBody(12, color: ppMuted)),
            ])),
            const SizedBox(height: 6),
            _pad(Text('Kept simple, so you never leave the app for them.', style: ppBody(13))),
            const SizedBox(height: 16),
            _pad(Column(children: [
              _tracker(context, Icons.show_chart_rounded, const Color(0xFFEAF1FB), 'Growth journey', 'Weight, height, head — on his curve', ppMuted, () => _push(context, const GrowthJourneyScreen())),
              const SizedBox(height: 10),
              _tracker(context, Icons.menu_book_outlined, const Color(0xFFEAF4EE), 'Product Guide', 'Is it right for your child?', ppMuted,
                  () => _push(context, const ProductGuideHubScreen())),
              const SizedBox(height: 10),
              // The Launch Hub's only front door. A destination is visited on
              // purpose — it is never pushed at anyone. docs/BRAND-STUDIO.md §3.
              _tracker(context, Icons.auto_awesome_outlined, const Color(0xFFF6EFE6), 'Launches', 'New, and worth knowing about', ppBrown,
                  () => _push(context, const LaunchHubScreen(stage: BrandStage.parenting))),
              const SizedBox(height: 10),
              // Debug-only workbench — see every campaign and why it is blocked.
              if (kDebugMode)
                _tracker(context, Icons.science_outlined, const Color(0xFFFFF1F3), 'Brand Studio (debug)', 'Every campaign, and why it is blocked', const Color(0xFFD92D20),
                    () => _push(context, const BrandPreviewScreen())),
              const SizedBox(height: 10),
              _tracker(context, Icons.compare_arrows_rounded, const Color(0xFFEDEAF7), 'Compare products', 'Two picks, side by side', ppPurple,
                  () => _push(context, const ProductsCompareScreen())),
              const SizedBox(height: 10),
              _tracker(context, Icons.vaccines_outlined, const Color(0xFFFBEAF0), 'Vaccination schedule', 'Next due in 3 weeks', ppCoral,
                  () => _push(context, const VaxTrackerScreen())),
              const SizedBox(height: 10),
              // Was: direct to the V1 finder - now opens the V1|V2 front door.
              // _tracker(context, Icons.badge_outlined, const Color(0xFFEDEAF7), 'Baby name finder', 'Swipe together, match a name', ppPurple,
              //     () => _push(context, const NameFinderScreen())),
              _tracker(context, Icons.badge_outlined, const Color(0xFFEDEAF7), 'Baby names', 'Two ways to choose - swipe or journey', ppPurple,
                  () => _push(context, const BabyNamingHomeScreen())),
              const SizedBox(height: 10),
              _tracker(context, Icons.local_drink_outlined, const Color(0xFFEAF4EE), 'Feeding journey', 'A rhythm you can see', ppMuted, () => _push(context, const FeedingJourneyScreen())),
              const SizedBox(height: 10),
              _tracker(context, Icons.bedtime_outlined, const Color(0xFFEDEAF7), 'Sleep journey', 'Rest, gently understood', ppMuted, () => _push(context, const SleepJourneyScreen())),
              const SizedBox(height: 10),
              _tracker(context, Icons.checklist_rounded, const Color(0xFFEAF4EE), 'Development journey', 'Milestones to celebrate', ppMuted, () => _push(context, const MilestoneJourneyScreen())),
              const SizedBox(height: 10),
              _tracker(context, Icons.calendar_month_outlined, const Color(0xFFFBEAF0), 'Due date & ovulation', 'Plan the next', ppMuted, () => _soon(context, 'Due date & ovulation planner - coming soon')),
            ])),
          ],
        ),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 52,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ppBg, Color(0x00FBF9FE)]),
              ),
            ),
          ),
        ),
        const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: 2)),
      ]),
    );
  }

  Widget _hero(BuildContext context,
      {required bool dark,
      required IconData icon,
      required String tag,
      required String title,
      required String desc,
      required String cta,
      required VoidCallback onTap}) {
    final titleColor = dark ? Colors.white : ppInk;
    final descColor = dark ? const Color(0xFFCFC7DA) : ppSoft;
    final tagColor = dark ? const Color(0xFFC7B2E0) : ppPurple;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: dark
              ? const RadialGradient(center: Alignment(0.6, -0.65), radius: 1.3, colors: [Color(0xFF5A3E8A), Color(0xFF2A2733)])
              : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF0E9F7), Color(0xFFE6DAF2)]),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [BoxShadow(color: (dark ? const Color(0xFF4A3A6B) : ppPurple).withValues(alpha: dark ? 0.75 : 0.4), blurRadius: 44, spreadRadius: -18, offset: const Offset(0, 20))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: dark ? Colors.white.withValues(alpha: 0.12) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: dark ? Border.all(color: Colors.white.withValues(alpha: 0.18)) : null,
              ),
              child: Icon(icon, size: 21, color: dark ? Colors.white : ppPurple),
            ),
            Flexible(
              child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end, children: [
                if (!dark) ...[
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: ppCoral, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                ],
                Flexible(child: Text(tag.toUpperCase(), textAlign: TextAlign.right, style: ppBody(10, color: tagColor, w: FontWeight.w700).copyWith(letterSpacing: 0.8), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ),
          ]),
          const SizedBox(height: 18),
          Text(title, style: ppFraunces(27, color: titleColor, h: 1.1)),
          const SizedBox(height: 8),
          Text(desc, style: ppBody(14, color: descColor, h: 1.55)),
          const SizedBox(height: 18),
          if (dark)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(cta, style: ppBody(13, color: const Color(0xFF2A2733), w: FontWeight.w700)),
                const SizedBox(width: 6),
                const Text('→', style: TextStyle(color: Color(0xFF2A2733))),
              ]),
            )
          else
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(cta, style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
              const SizedBox(width: 6),
              const Text('→', style: TextStyle(color: ppPurple)),
            ]),
        ]),
      ),
    );
  }

  Widget _tracker(BuildContext context, IconData icon, Color tint, String title, String sub, Color subColor, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ppHair),
            boxShadow: const [BoxShadow(color: Color(0x1A6A30B6), blurRadius: 20, spreadRadius: -18, offset: Offset(0, 8))],
          ),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 19, color: ppInk),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: ppJakarta(15)),
                const SizedBox(height: 1),
                Text(sub, style: ppBody(12, color: subColor, w: subColor == ppMuted ? FontWeight.w400 : FontWeight.w600)),
              ]),
            ),
            const SizedBox(width: 10),
            const Text('→', style: TextStyle(color: Color(0xFFC7BBD6))),
          ]),
        ),
      );
}
