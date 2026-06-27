// =============================================================================
//  MainScaffold — the app shell ("Warm Nest" / Direction B)
// -----------------------------------------------------------------------------
//  A floating pill tab bar (PvTabBar) over the five Direction-B destinations:
//    Today (Daily Moment) · Journey (week stack → map/tools) · Sanskar
//    (Garbh) · Read (articles + reading) · Community.
//  Profile is reached from the avatar on Today (not a tab). The previous
//  5-tab Material NavigationBar version is preserved in git history.
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../services/app_nav.dart';
import '../services/baby_voice_service.dart';
import '../services/father_content_controller.dart';
import '../services/father_preview.dart';
import '../services/home_content_controller.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/pv_tab_bar.dart';
import 'calendar_screen.dart';
import 'community_screen.dart';
import 'father/father_daily_screen.dart';
import 'home_screen_b.dart';
import 'tools_hub_screen.dart';
import 'weekly_card_stack_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({
    super.key,
    required this.pregnancy,
    required this.home,
    required this.father,
  });

  final PregnancyController pregnancy;
  final HomeContentController home;

  /// Kept threaded through for when Father Mode is un-parked (currently unused).
  final FatherContentController father;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  @override
  void initState() {
    super.initState();
    AppNav.instance.addListener(_onNav);
    FatherPreview.instance.addListener(_onNav); // testing-only mode switch
  }

  @override
  void dispose() {
    AppNav.instance.removeListener(_onNav);
    FatherPreview.instance.removeListener(_onNav);
    super.dispose();
  }

  /// Applies a tab change requested anywhere (tab-bar tap or the Home "flow"
  /// toggle): hush baby voice, snap Journey to the current week, then rebuild.
  void _onNav() {
    BabyVoiceService.instance.stop();
    if (AppNav.instance.index == AppNav.journeyTab) {
      widget.pregnancy.selectWeek(widget.pregnancy.currentWeek);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.pregnancy,
      builder: (context, _) {
        final s = S(widget.pregnancy.language);
        final fatherPreview = FatherPreview.instance.on;
        final pages = [
          // Today — the Daily Moment (Warm Nest), or the Father Daily screen
          // when the testing mode switch is flipped to Dad.
          fatherPreview
              ? FatherDailyScreen(
                  controller: widget.pregnancy, embedded: true)
              : HomeScreenB(pregnancy: widget.pregnancy, home: widget.home),
          // Journey — the week-on-week stack (same UI for mother & father; the
          // father skin/copy is applied inside it when FatherPreview is on).
          WeeklyCardStackScreen(controller: widget.pregnancy),
          // Tools — the calm tools hub (Garbh Sanskar moved onto Home).
          ToolsHubScreen(controller: widget.pregnancy),
          // Calendar — the pregnancy command center. (Read Next stays reachable
          // from its Home section, so the pill slot goes to Calendar.)
          CalendarScreen(controller: widget.pregnancy),
          // Community.
          CommunityScreen(controller: widget.pregnancy),
        ];
        final tabs = [
          PvTab(Icons.home_rounded, s.tabToday),
          PvTab(Icons.explore_rounded, s.tabJourney),
          PvTab(Icons.widgets_rounded, s.toolsTab),
          PvTab(Icons.calendar_today_rounded, s.tabCalendar),
          PvTab(Icons.groups_rounded, s.tabCommunity),
        ];
        return Scaffold(
          backgroundColor: AppTheme.scaffoldBackground,
          body: Stack(
            children: [
              Positioned.fill(
                child: IndexedStack(
                    index: AppNav.instance.index, children: pages),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: PvTabBar(
                  tabs: tabs,
                  activeIndex: AppNav.instance.index,
                  onChanged: (i) => AppNav.instance.go(i),
                  // In Dad mode the nav pill takes the father (Slate) colours.
                  father: fatherPreview,
                ),
              ),
              // TESTING-ONLY Mom | Dad switch, top-right on the Today tab so we
              // can preview the Father experience. Remove before launch.
              if (AppNav.instance.index == 0)
                Positioned(
                  right: 14,
                  top: MediaQuery.of(context).padding.top + 8,
                  child: _modePill(fatherPreview),
                ),
            ],
          ),
        );
      },
    );
  }

  // Compact two-segment pill that flips FatherPreview (dev affordance). In Dad
  // mode the active segment takes the father (Slate) accent.
  Widget _modePill(bool father) {
    final activeColor =
        father ? const Color(0xFF2E5266) : AppTheme.primary600;
    Widget seg(String label, bool active, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
            decoration: BoxDecoration(
              color: active ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : AppTheme.neutral400,
                )),
          ),
        );
    return Material(
      elevation: 5,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(999),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          seg('Mom', !father, () => FatherPreview.instance.on = false),
          seg('Dad', father, () => FatherPreview.instance.on = true),
        ]),
      ),
    );
  }
}
