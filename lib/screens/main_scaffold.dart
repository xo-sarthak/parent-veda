// =============================================================================
//  MainScaffold - the app shell ("Warm Nest" / Direction B)
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
import '../services/content_registry.dart';
import '../services/baby_voice_service.dart';
import '../services/father_content_controller.dart';
import '../services/father_preview.dart';
import '../services/home_content_controller.dart';
import '../services/pregnancy_controller.dart';
import '../brand/brand_models.dart';
import '../brand/premiere_screen.dart';
import '../theme/app_theme.dart';
// Retired: the old sponsored-brand promo carousel, replaced by ParentVeda
// Premiere (lib/brand/). Kept for revert — see docs/BRAND-STUDIO.md §12.
// import '../widgets/launch_promo.dart';
import '../widgets/global_ask_fab.dart';
import '../widgets/pv_tab_bar.dart';
import 'calendar_screen.dart';
import 'community_screen.dart';
import 'father/father_daily_screen.dart';
import 'father/father_journal_screen.dart';
import 'father/father_read_aloud_screen.dart';
import 'father/father_reads_screen.dart';
// Kept: the revert line in the tab list constructs HomeScreenB directly, and
// TodayHomeScreen's Classic branch is the live path to it.
// ignore: unused_import
import 'home_screen_b.dart';
import 'today_home_screen.dart';
import 'prepare/prepare_hub_screen.dart';
import 'tools_hub_screen.dart';
import 'weekly_card_stack_screen.dart';
import '../services/usage_events.dart';

/// The five pregnancy tabs, in nav order, as usage surfaces.
///
/// Positional rather than derived from the tab label, because the labels are
/// bilingual and father mode swaps three of them — a metric keyed on display
/// text would silently split one surface into several the day someone switched
/// language, and the numbers would look like a drop in usage.
const _pregnancySurfaces = <String>[
  UsageSurface.home,
  UsageSurface.prepare,
  UsageSurface.tools,
  UsageSurface.calendar,
  UsageSurface.community,
];

class MainScaffold extends StatefulWidget {
  const MainScaffold({
    super.key,
    required this.pregnancy,
    required this.home,
    required this.father,
    this.isFather = false,
  });

  final PregnancyController pregnancy;
  final HomeContentController home;

  /// Kept threaded through for when Father Mode is un-parked (currently unused).
  final FatherContentController father;

  /// True when this user is the (paired) FATHER - the whole shell runs in the
  /// father (Slate) structure. The testing Mom|Dad toggle (FatherPreview) also
  /// flips this at runtime for previewing on a mother account.
  final bool isFather;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // A paired father turns on FatherPreview so every existing father (Slate)
    // skin - the nav pill, the weekly stack, the week pop-ups - fires too. Set
    // before wiring the listener so it doesn't bounce a setState during init.
    if (widget.isFather) FatherPreview.instance.on = true;
    // The shell is up (not the splash) — let the global Ask-Veda FAB appear.
    // AFTER the first frame: the FAB is mounted by MaterialApp.builder, ABOVE
    // this shell in the tree, so notifying it from initState marks an ancestor
    // dirty mid-build — "setState() called during build", thrown on every cold
    // start. Deferring one frame lets this build finish before the FAB rebuilds.
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => FabState.instance.markAppLive());
    AppNav.instance.addListener(_onNav);
    FatherPreview.instance.addListener(_onNav); // testing-only mode switch
    WidgetsBinding.instance.addObserver(this); // app-resume → refresh content
    // Ask the Brand Studio whether a Premiere is live for this parent (after
    // the first frame, so a valid Navigator/context exists). Almost always
    // resolves to null — Premiere runs 3-6 times a year and only once per
    // campaign — and null is the normal, correct answer.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showPremiereIfAny(
        context,
        stage: BrandStage.pregnancy,
        pregnancyWeek: widget.pregnancy.currentWeek,
      );
    });
  }

  @override
  void dispose() {
    AppNav.instance.removeListener(_onNav);
    FatherPreview.instance.removeListener(_onNav);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// When the app returns to the foreground, re-pull server-driven content so
  /// freshly-published content appears without a full relaunch.
  ///
  /// Goes through the registry rather than naming stores: a new content type
  /// registers itself once and this call site never changes again. Each store
  /// throttles itself, so alt-tabbing does not mean a round trip per type.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ContentRegistry.refreshAll();
    }
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
        // Father mode is driven by FatherPreview - set true in initState for a
        // paired father, and flipped by the testing Mom|Dad toggle otherwise.
        final fatherMode = FatherPreview.instance.on;

        // The SAME nav-pill structure for both, just father (Slate) content +
        // colours in father mode. Today + Journey are shared; the other three
        // become the father's own sections (Reads · Read · Journal).
        final pages = fatherMode
            ? [
                FatherDailyScreen(controller: widget.pregnancy, embedded: true),
                WeeklyCardStackScreen(controller: widget.pregnancy),
                const FatherReadsScreen(),
                FatherReadAloudScreen(controller: widget.pregnancy),
                FatherJournalScreen(
                    controller: widget.pregnancy, embedded: true),
              ]
            : [
                // TodayHomeScreen is a WRAPPER, not a replacement: it opens
                // HomeScreenB by default and offers a Classic | Focus pill to
                // preview the focus-ordered experiment. The shipped Today is
                // untouched and is still what everyone lands on.
                //
                // Kept for revert — deleting today_home_screen.dart and
                // restoring this line is the whole rollback:
                // HomeScreenB(pregnancy: widget.pregnancy, home: widget.home),
                TodayHomeScreen(
                    pregnancy: widget.pregnancy, home: widget.home),
                PrepareHubScreen(lang: widget.pregnancy.language),
                ToolsHubScreen(controller: widget.pregnancy),
                CalendarScreen(controller: widget.pregnancy),
                CommunityScreen(controller: widget.pregnancy),
              ];
        final tabs = fatherMode
            ? const [
                PvTab(Icons.home_rounded, 'Today'),
                PvTab(Icons.explore_rounded, 'Journey'),
                PvTab(Icons.menu_book_rounded, 'Reads'),
                PvTab(Icons.auto_stories_rounded, 'Read'),
                PvTab(Icons.edit_outlined, 'Journal'),
              ]
            : [
                PvTab(Icons.home_rounded, s.tabToday),
                PvTab(Icons.school_rounded, s.tabPrepare),
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
                  onChanged: (i) {
                    // ENGAGEMENT (0065): which section, never what was in it.
                    // Recorded on the TAP rather than in build(), because
                    // build runs on every rebuild — a language toggle would
                    // otherwise look like a hundred screen views.
                    UsageEvents.instance.screen(
                      _pregnancySurfaces[i],
                      stage: 'pregnancy',
                    );
                    AppNav.instance.go(i);
                  },
                  // In Dad mode the nav pill takes the father (Slate) colours.
                  father: fatherMode,
                ),
              ),
              // TESTING-ONLY switch, bottom-right, Today tab only. Remove
              // before launch.
              //
              // WHICH switch depends on which home is showing. Mom | Dad only
              // means anything on Classic — the experimental homes are
              // mother-side only, so on those the slot carries the version
              // switch instead of a father toggle that would do nothing.
              // One control in one place, rather than two competing for the
              // same corner.
              if (AppNav.instance.index == 0)
                Positioned(
                  right: 14,
                  bottom: 96,
                  child: ListenableBuilder(
                    listenable: TodayVersionStore.instance,
                    builder: (context, _) =>
                        TodayVersionStore.instance.version == TodayVersion.classic
                            ? _modePill(fatherMode)
                            : const _V3Pill(),
                  ),
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


/// Focus | V3 switch, in the slot Mom | Dad occupies on Classic.
///
/// Testing chrome, same as the pill it replaces. It shows only on the
/// experimental homes, so there is never a moment where both a father toggle
/// and a version toggle are fighting for the same corner.
class _V3Pill extends StatelessWidget {
  const _V3Pill();

  @override
  Widget build(BuildContext context) {
    // ⚠️ THIS LISTENER IS LOAD-BEARING, and it was missing.
    //
    // The pill read TodayVersionStore but never listened to it, so it only
    // repainted when something ELSE rebuilt its parent. On the phone the body
    // swapped to V3 while the pill went on showing Focus as the active segment
    // — the control lying about the state it controls.
    //
    // Third time in this screen's history: the version pill in
    // today_home_screen.dart and the art toggle read by v2_block_grid.dart both
    // had it. The general rule, worth more than the fix: A STORE READ INSIDE
    // build() IS A STORE THE WIDGET MUST LISTEN TO. Reading is not subscribing,
    // and Flutter will not warn you — the value is simply the one from
    // whenever this widget last happened to be rebuilt.
    return ListenableBuilder(
      listenable: TodayVersionStore.instance,
      builder: (context, _) => _pill(),
    );
  }

  Widget _pill() {
    final store = TodayVersionStore.instance;
    Widget seg(String label, TodayVersion v) {
      final on = store.version == v;
      return InkWell(
        onTap: () => store.set(v),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: on ? AppTheme.primary600 : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: on ? Colors.white : AppTheme.primary700)),
        ),
      );
    }

    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          seg('Focus', TodayVersion.focus),
          seg('V3', TodayVersion.v3),
        ]),
      ),
    );
  }
}
