// =============================================================================
//  HomeFocusScreen — Today, ordered by what she is here for
// -----------------------------------------------------------------------------
//  AN EXPERIMENT, sitting beside the shipped Today rather than replacing it.
//  home_screen_b.dart is untouched; the Classic | Focus pill in
//  today_home_screen.dart decides which one is on screen.
//
//  WHAT IT CHANGES: the order of Today, and how much of it is on Today at all.
//  The shipped home stacks fourteen cards, every one of which matters to
//  somebody and most of which do not matter to anybody on a given morning. This
//  leads with ONE block — the focus — and demotes the rest to a short "also"
//  row of routes into the tabs that own them.
//
//  WHAT IT DOES NOT CHANGE: the tabs, the routes, or which screens exist.
//  Everything demoted is one tap away in the tab that owns it, and that mapping
//  comes from app_structure.dart rather than from this screen's opinion.
//
//  WHY THE FOCUS BLOCK USES THE REAL CARDS. GrowModule, TodaysVideoCard,
//  DailyReadsHomeCard, LaunchSpotlight and InviteNudgeCard are the widgets the
//  shipped home builds — constructed here, not reimplemented. The Grow
//  experiment learned this the hard way: a version built from copies drifts the
//  moment anyone touches the original, and then the comparison is against
//  something that never shipped.
//
//  The cards that are PRIVATE to home_screen_b (the hero, Garbh, journal,
//  medicines, products) cannot be reused without editing it, and editing it is
//  exactly what this experiment is meant to avoid. Those appear in the "also"
//  row as routes instead — which is the demotion the brief asks for anyway, so
//  the constraint and the design agree for once.
//
//  ENGLISH ONLY, on purpose. This may not survive the experiment, and putting a
//  screen through the string table is work you only want to do once.
// =============================================================================

import 'package:flutter/material.dart';

import '../brand/brand_models.dart';
import '../brand/launch_spotlight.dart';
import '../models/home_day.dart';
import '../localization/app_language.dart';
import '../services/app_nav.dart';
import '../services/app_structure.dart';
import '../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../services/home_content_controller.dart';
import '../services/landing_focus.dart';
import '../services/life_stage_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/home/home_modules.dart';
import 'read_next_screen.dart' show DailyReadsHomeCard;
import 'referral/invite_nudge_card.dart';
import 'today_home_screen.dart';
import 'watch_learn_screen.dart' show TodaysVideoCard;

class HomeFocusScreen extends StatelessWidget {
  const HomeFocusScreen({
    super.key,
    required this.pregnancy,
    required this.home,
  });

  final PregnancyController pregnancy;
  final HomeContentController home;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [pregnancy, home, LandingFocus.instance, LifeStageStore.instance]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    if (pregnancy.isLoading || home.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final lang = pregnancy.language;
    final activeDay = home.previewDay ?? pregnancy.currentDay;
    final week = (((activeDay - 1) ~/ 7) + 1).clamp(4, 40);
    final day = home.dayFor(activeDay, week);

    final stage = LifeStageStore.instance.stage;
    final focus = LandingFocus.instance.effective(stage);

    return Container(
      color: AppTheme.surfaceContainer,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, kAskFabReserve),
          children: [
            _header(context, focus),
            const SizedBox(height: 18),

            // ---- THE FOCUS BLOCK -------------------------------------------
            _eyebrow(focus.label.toUpperCase()),
            const SizedBox(height: 8),
            ..._focusBlock(context, focus, week, day, lang),

            const SizedBox(height: 26),

            // ---- AT MOST TWO SECONDARY CARDS -------------------------------
            //
            // Both hide themselves when they have nothing to say — a launch
            // that is not live and a referral cap already hit both render
            // nothing — so on most mornings this is empty and Today really is
            // just the focus plus the row below.
            LaunchSpotlight(
              stage: BrandStage.pregnancy,
              pregnancyWeek: week,
              padding: const EdgeInsets.only(bottom: 20),
            ),
            const InviteNudgeCard(padding: EdgeInsets.only(bottom: 20)),

            // ---- ALSO: everything else, as routes not cards -----------------
            _alsoRow(context),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  The focus block. Each branch answers "what should be first this morning".
  // ---------------------------------------------------------------------------
  List<Widget> _focusBlock(
    BuildContext context,
    TodayFocus focus,
    int week,
    HomeDay? day,
    AppLanguage lang,
  ) {
    switch (focus) {
      case TodayFocus.weeklyGrowth:
        return [
          TodaysVideoCard(controller: pregnancy),
          const SizedBox(height: 16),
          if (day != null) GrowModule(day: day, lang: lang, home: home),
        ];

      case TodayFocus.keepMeCalm:
        return [
          _routeCard(context, 'garbh_daily',
              'Your ritual for today — Shravan, Vichara, Samvad, Kriya.'),
          const SizedBox(height: 16),
          if (day != null) GrowModule(day: day, lang: lang, home: home),
        ];

      case TodayFocus.bodyAndMind:
        return [
          _routeCard(context, 'medication',
              "What is due today, and what you have already taken."),
          const SizedBox(height: 12),
          _routeCard(context, 'weight', 'Your curve, and what it means.'),
          const SizedBox(height: 16),
          DailyReadsHomeCard(controller: pregnancy, lang: lang),
        ];

      case TodayFocus.prepareForBirth:
        return [
          _routeCard(context, 'hospital_bag',
              'What is packed, what is left, and what happens on the day.'),
          const SizedBox(height: 12),
          _routeCard(context, 'birthing_classes',
              'Classes that walk you through it before it happens.'),
          const SizedBox(height: 16),
          DailyReadsHomeCard(controller: pregnancy, lang: lang),
        ];

      // Parenting focuses can be selected from Profile before the stage has
      // actually changed, so they must render something sane here rather than
      // fall through to nothing.
      case TodayFocus.problemLed:
        return [
          _routeCard(context, 'daily_reads',
              'Sleep and feeding, read in five minutes.'),
          const SizedBox(height: 16),
          if (day != null) GrowModule(day: day, lang: lang, home: home),
        ];

      case TodayFocus.activityLed:
        return [
          if (day != null) GrowModule(day: day, lang: lang, home: home),
          const SizedBox(height: 16),
          TodaysVideoCard(controller: pregnancy),
        ];
    }
  }

  // ---------------------------------------------------------------------------
  //  Chrome
  // ---------------------------------------------------------------------------

  Widget _header(BuildContext context, TodayFocus focus) => Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              pregnancy.motherName.trim().isEmpty
                  ? 'Today'
                  : 'Today, ${pregnancy.motherName.trim()}',
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w700, height: 1.1),
            ),
            const SizedBox(height: 3),
            Text(focus.blurb,
                style: TextStyle(fontSize: 13, color: Colors.black.withValues(alpha: 0.55))),
          ]),
        ),
        const SizedBox(width: 12),
        // The way to change her mind, next to the thing it changes. A choice
        // buried in Profile is a choice she made once and cannot revisit.
        GestureDetector(
          onTap: () => showFocusChooser(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.tune_rounded, size: 15, color: AppTheme.primary),
              SizedBox(width: 5),
              Text('Focus',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary)),
            ]),
          ),
        ),
      ]);

  Widget _eyebrow(String t) => Text(
        t,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppTheme.primary.withValues(alpha: 0.85),
        ),
      );

  /// A card that is a DOOR, not a copy of the thing behind it.
  ///
  /// Reads its label from app_structure, so a surface renamed there is renamed
  /// here — and so this screen cannot invent a destination the structure does
  /// not know about.
  Widget _routeCard(BuildContext context, String surfaceId, String blurb) {
    final surface =
        kAppSurfaces.where((s) => s.id == surfaceId).cast<AppSurface?>().firstOrNull;
    final home = homeFor(surfaceId);
    return GestureDetector(
      onTap: () => _open(context, surfaceId),
      behavior: HitTestBehavior.opaque,
      child: Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(surface?.label ?? surfaceId,
                style: const TextStyle(
                    fontSize: 15.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(blurb,
                style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: Colors.black.withValues(alpha: 0.55))),
            if (home != null) ...[
              const SizedBox(height: 6),
              Text('In ${home.label}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary.withValues(alpha: 0.7))),
            ],
          ]),
        ),
        const Icon(Icons.chevron_right_rounded, size: 20),
      ]),
      ),
    );
  }

  /// Open the tab that owns a surface.
  ///
  /// THE TAB, not the screen itself, and that is the honest thing to do here.
  /// The card already says "In Tools"; taking her to Tools is what it promised.
  /// Deep-linking each surface would mean importing a dozen screens and knowing
  /// each one's constructor, and every one of those imports is a way for this
  /// experiment to break the shipped app it is meant to sit beside.
  ///
  /// A Today-homed surface is not somewhere else — it is on this tab, just not
  /// first. So it switches to Classic, where the card actually is. That is the
  /// truthful answer rather than a no-op.
  void _open(BuildContext context, String surfaceId) {
    final home = homeFor(surfaceId);
    if (home == null) return;
    switch (home) {
      case AppHome.today:
        TodayVersionStore.instance.set(TodayVersion.classic);
      case AppHome.prepare:
        AppNav.instance.go(1);
      case AppHome.tools:
        AppNav.instance.go(2);
      case AppHome.calendar:
        AppNav.instance.go(3);
      case AppHome.community:
        AppNav.instance.go(4);
      case AppHome.profile:
        // Profile is behind the avatar on the shipped Today, so Classic is
        // where the door is.
        TodayVersionStore.instance.set(TodayVersion.classic);
    }
  }

  /// The demotion, made honest.
  ///
  /// Everything the shipped Today stacks as a card is still here — as a name and
  /// the tab that owns it. That is the difference between "we removed it" and
  /// "it lives somewhere sensible now", and a parent can see which at a glance.
  Widget _alsoRow(BuildContext context) {
    const also = ['weekly_snapshot', 'garbh_daily', 'journal', 'medication',
      'tests_scans', 'daily_reads'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _eyebrow('ALSO TODAY'),
      const SizedBox(height: 4),
      Text('Still here, just not first today.',
          style: TextStyle(
              fontSize: 12.5, color: Colors.black.withValues(alpha: 0.5))),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final id in also)
          if (homeFor(id) != null) _alsoChip(context, id),
      ]),
    ]);
  }

  Widget _alsoChip(BuildContext context, String id) {
    final s = kAppSurfaces.firstWhere((x) => x.id == id);
    return GestureDetector(
      onTap: () => _open(context, id),
      behavior: HitTestBehavior.opaque,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withValues(alpha: 0.07)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(s.label,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        // NO TAB NAME when the surface's home IS Today.
        //
        // The row exists to say "this moved, here is where". A chip reading
        // "Garbh Sanskar · Today" said the opposite of what a parent could
        // see: it named the screen she was standing on, while the card itself
        // was nowhere on it. Today-homed surfaces are not relocated, they are
        // just not first — so they carry their name and nothing else, and only
        // the genuinely-relocated ones name a destination.
        if (s.home != AppHome.today) ...[
          const SizedBox(width: 6),
          Text(s.home.label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary.withValues(alpha: 0.7))),
        ],
      ]),
      ),
    );
  }
}

/// "What are you here for?" — the override, asked warmly and answerable once.
///
/// A sheet rather than a step, because it has to be reachable from Today AND
/// from Profile without being two implementations. Clearing the choice is a
/// first-class option: "no strong feeling" must be sayable, or the question
/// becomes a trap that only ever adds state.
Future<void> showFocusChooser(BuildContext context) async {
  final stage = LifeStageStore.instance.stage;
  final options = LandingFocus.optionsFor(stage);
  // THE TICK FOLLOWS WHAT IS ON SCREEN, not only what she has explicitly
  // chosen. With no override set, `override` is null and the sheet showed four
  // unticked options while Today was visibly leading with one of them — a
  // chooser that will not admit what it currently is.
  //
  // `chosen` stays separate because it decides something else: the "no strong
  // feeling" row only makes sense once there is a choice to clear.
  final current = LandingFocus.instance.effective(stage);
  final chosen = LandingFocus.instance.override;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999)),
        ),
        const SizedBox(height: 20),
        const Text('What are you here for?',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
            'This only changes what Today leads with. Everything stays exactly '
            'where it is, and you can change your mind whenever.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.black.withValues(alpha: 0.55))),
        const SizedBox(height: 18),
        for (final f in options) ...[
          _FocusOption(
            focus: f,
            selected: current == f,
            onTap: () async {
              await LandingFocus.instance.choose(f);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
          ),
          const SizedBox(height: 10),
        ],
        if (chosen != null)
          GestureDetector(
            onTap: () async {
              await LandingFocus.instance.choose(null);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text('No strong feeling — decide for me',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withValues(alpha: 0.5))),
            ),
          ),
      ]),
    ),
  );
}

class _FocusOption extends StatelessWidget {
  const _FocusOption(
      {required this.focus, required this.selected, required this.onTap});

  final TodayFocus focus;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected
                    ? AppTheme.primary
                    : Colors.black.withValues(alpha: 0.07),
                width: selected ? 1.6 : 1),
          ),
          child: Row(children: [
            Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(focus.label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(focus.blurb,
                    style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: Colors.black.withValues(alpha: 0.55))),
              ]),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  size: 20, color: AppTheme.primary),
          ]),
        ),
      );
}
