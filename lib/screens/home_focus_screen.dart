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
//  leads with a SIX-BLOCK GRID — what to do today — and demotes the rest to a
//  short "also" row of routes into the tabs that own them.
//
//  WHAT IT DOES NOT CHANGE: the tabs, the routes, or which screens exist.
//  Everything demoted is one tap away in the tab that owns it, and that mapping
//  comes from app_structure.dart rather than from this screen's opinion.
//
//  IT NO LONGER REUSES THE SHIPPED CARDS, AND THAT WAS A DELIBERATE REVERSAL.
//
//  The first cut built the grid and left GrowModule, TodaysVideoCard,
//  LaunchSpotlight and the rest below it, on the argument that comparing
//  against copies is dishonest. That argument is sound and it produced the
//  wrong thing: a designed hero sitting on top of somebody else's screen, with
//  everything below it reading as random. A home screen is judged whole.
//
//  So v2_sections.dart holds palette-aware presentations of the SAME real
//  content those cards read — HomeDay's grow / garbhSanskar / story / talk, and
//  real ReadItems from read_next_data. No copy is invented: a section whose
//  content is empty renders nothing rather than filling itself in.
//
//  The cost of the reversal, stated honestly: this screen will NOT track
//  changes to the shipped cards. If GrowModule gains a field, this does not.
//  That is acceptable for an experiment whose whole purpose is to look
//  different, and unacceptable the moment it graduates — at which point these
//  sections become the real widgets rather than a parallel set.
//
//  ENGLISH ONLY, AND ENFORCED. Every string reads `.en`, not `.now`. `.now`
//  follows the app's language setting, which produced an English screen with
//  Hindi cards inside a Hindi app. `.en` is the identity side of LocalizedText
//  and is correct here precisely because this screen is English by decision
//  rather than by her setting. Do NOT copy that habit into shipped screens.
//
//  ---------------------------------------------------------------------------
//  THE PALETTE BAR IS A SANDBOX CONTROL, NOT A FEATURE.
//
//  Five grounds sit behind a chip row so a direction can be chosen by looking
//  at it on a real phone rather than from a description. See v2_palette.dart
//  for why this is local rather than a change to AppTheme.
// =============================================================================

import 'package:flutter/material.dart';

import '../brand/brand_models.dart';
import '../brand/launch_spotlight.dart';
import '../services/app_nav.dart';
import '../services/app_structure.dart';
import '../services/scans_store.dart';
import 'referral/invite_nudge_card.dart';
import '../widgets/global_ask_fab.dart' show kAskFabReserve, openAskVeda;
import '../services/home_content_controller.dart';
import '../services/landing_focus.dart';
import '../services/life_stage_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import 'today_home_screen.dart';
import 'v2/v2_block_art.dart';
import 'v2/v2_block_grid.dart';
import 'v2/v2_palette.dart';
import 'v2/v2_sections.dart';

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
      animation: Listenable.merge([
        pregnancy,
        home,
        LandingFocus.instance,
        LifeStageStore.instance,
        V2PaletteStore.instance,
        // The grid reads V2BlockArtMode, so this must listen to it too. Without
        // it the toggle flipped the store and nothing rebuilt — the same class
        // of bug as the version pill that went on showing "Classic" while the
        // body had already swapped (see today_home_screen.dart). A store read
        // by a child is a store the parent has to listen to.
        V2BlockArtMode.instance,
      ]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    if (pregnancy.isLoading || home.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeDay = home.previewDay ?? pregnancy.currentDay;
    final week = (((activeDay - 1) ~/ 7) + 1).clamp(4, 40);
    final day = home.dayFor(activeDay, week);

    final stage = LifeStageStore.instance.stage;
    final focus = LandingFocus.instance.effective(stage);
    final p = V2PaletteStore.instance.current;
    final reads = v2ReadsFor(week, activeDay);
    final video = v2VideoFor(week);
    final products = v2ProductsFor(week, activeDay);

    // The insight of the day, in her words rather than ours. `remember` is the
    // one memorable line the content already carries; `insight` is the fuller
    // sentence and stands in when there is no remember line.
    final insight = (day?.grow.remember.en.trim().isNotEmpty ?? false)
        ? day!.grow.remember.en
        : (day?.grow.insight.en ?? '');

    // WHAT LEADS IS THE FOCUS'S JOB, not this list's. Everything below is
    // present in every ordering — the focus decides which of the two big
    // moments comes first, and nothing is ever removed by it.
    final practiceLeads = focus == TodayFocus.keepMeCalm;

    final practice = day == null
        ? const SizedBox.shrink()
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            V2SectionHead(
                eyebrow: 'Today', title: 'Your practice for today', p: p),
            const SizedBox(height: 12),
            V2PracticeCard(
                garbh: day.garbhSanskar,
                p: p,
                onTap: () => _open(context, 'garbh_daily')),
          ]);

    final readsSection = reads.isEmpty
        ? const SizedBox.shrink()
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            V2SectionHead(
                eyebrow: 'Reads', title: 'Short enough for today', p: p),
            const SizedBox(height: 12),
            V2ReadsRail(
                items: reads,
                p: p,
                onOpen: (_) => _open(context, 'daily_reads')),
          ]);

    return Container(
      color: p.ground,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, kAskFabReserve),
          children: [
            _header(context, focus, p),
            const SizedBox(height: 14),

            // ---- THE GRID: what to do today --------------------------------
            V2BlockGrid(palette: p, blocks: _blocks(context, week, p)),
            const SizedBox(height: 26),

            // ---- THE ONLY TIME-SENSITIVE ROW -------------------------------
            //
            // Above the hero because it is the one thing she might need to act
            // on, and it renders nothing at all when there is nothing due.
            V2ComingUp(p: p, onTap: () => _open(context, 'tests_scans')),
            if (ScansStore.instance.appointments.isNotEmpty)
              const SizedBox(height: 14),

            // ---- THE ONE FULL-BLEED MOMENT ---------------------------------
            if (day != null)
              V2WeekHero(
                week: week,
                day: activeDay,
                learning: day.babyLearning.en,
                p: p,
                onTap: () => _open(context, 'weekly_snapshot'),
              ),
            if (day != null) const SizedBox(height: 26),

            // ---- TYPE AS THE WHOLE DESIGN, once -----------------------------
            V2InsightBlock(line: insight, p: p),
            if (insight.trim().isNotEmpty) const SizedBox(height: 26),

            // ---- The two big moments, ordered by focus ----------------------
            if (practiceLeads) ...[
              practice,
              const SizedBox(height: 26),
              readsSection,
            ] else ...[
              readsSection,
              const SizedBox(height: 26),
              practice,
            ],
            const SizedBox(height: 26),

            // ---- Two prompts, both hiding when empty ------------------------
            if (day != null) ...[
              V2SectionHead(
                  eyebrow: 'Together', title: 'Two small things', p: p),
              const SizedBox(height: 12),
              V2PromptCard(
                title: day.story.title.en,
                body: day.story.summary.en,
                icon: Icons.menu_book_rounded,
                p: p,
                onTap: () => _open(context, 'garbh_daily'),
              ),
              const SizedBox(height: 10),
              V2PromptCard(
                title: day.talk.title.en,
                body: day.talk.motivation.en,
                icon: Icons.record_voice_over_rounded,
                p: p,
                onTap: () => _open(context, 'garbh_daily'),
              ),
              const SizedBox(height: 26),
            ],

            // ---- PRODUCTS, MID-PAGE AND COMPACT -----------------------------
            //
            // Not at the foot. Products were missing from this screen entirely
            // while two full-width sponsor banners sat at the very bottom —
            // maximum space for the least useful commerce, and none at all for
            // the things she actually asks about.
            //
            // A rail shows six in the height of one banner, carries the price
            // on every card (W04), and sits where she will pass it rather than
            // after everything else. Still not leading: the day's content comes
            // first, three sections of it.
            if (products.isNotEmpty) ...[
              V2SectionHead(
                  eyebrow: 'Picks', title: 'What mothers ask us about', p: p),
              const SizedBox(height: 12),
              V2ProductRail(
                  items: products,
                  p: p,
                  onOpen: () => _open(context, 'shop')),
              const SizedBox(height: 26),
            ],

            // ---- ONE VIDEO --------------------------------------------------
            if (video != null) ...[
              V2SectionHead(
                  eyebrow: 'Watch', title: 'Six minutes, this week', p: p),
              const SizedBox(height: 12),
              V2VideoCard(
                  video: video,
                  p: p,
                  onTap: () => _open(context, 'todays_video')),
              const SizedBox(height: 26),
            ],

            // ---- ALSO: everything else, as routes not cards -----------------
            _alsoRow(context, p),

            const SizedBox(height: 26),

            // ---- COMMERCE, BELOW THE CONTENT --------------------------------
            //
            // W19: commerce present, not leading. These are the SHIPPED brand
            // widgets rather than restyled copies, and that is deliberate —
            // LaunchSpotlight resolves campaigns through the Brand Studio's
            // rules and invariants (docs/BRAND-STUDIO.md), which have tests
            // behind them. Re-implementing that to match the palette would mean
            // a second place for sponsorship eligibility to go wrong, which is
            // a far worse trade than one card that does not follow the ground.
            //
            // Both hide themselves when they have nothing to say, so on most
            // mornings this is empty.
            LaunchSpotlight(
              stage: BrandStage.pregnancy,
              pregnancyWeek: week,
              padding: const EdgeInsets.only(bottom: 14),
            ),
            const InviteNudgeCard(padding: EdgeInsets.only(bottom: 6)),

            const SizedBox(height: 22),
            _paletteBar(p),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  The grid
  // ---------------------------------------------------------------------------

  /// Six tiles. The SHAPE is fixed and would be identical in TTC and parenting;
  /// only the contents change.
  ///
  /// ⚠️ `meta` IS ONLY SET WHERE THERE IS REAL DATA. Week number is known, so it
  /// shows. "In 3 days" for a scan is not wired yet, so that tile carries no
  /// meta rather than a plausible-looking invention — the whole product argument
  /// is that a number on screen can be checked.
  List<V2Block> _blocks(BuildContext context, int week, V2Palette p) {
    return [
      V2Block(
        label: 'Practice',
          mark: V2Mark.practice,
        tint: v2BlockTint(V2BlockHues.practice, p),
        meta: 'Today',
        icon: Icons.self_improvement_rounded,
        asset: 'assets/blocks/block_practice.png',
        onTap: () => _open(context, 'garbh_daily'),
      ),
      V2Block(
        label: 'This week',
          mark: V2Mark.week,
        tint: v2BlockTint(V2BlockHues.week, p),
        meta: 'Week $week',
        icon: Icons.child_care_rounded,
        // The sixth object, in the same house style as the other five.
        //
        // This tile first pointed at assets/baby/week_NN.jpg and broke the set:
        // those are dark, full-frame photographs while every other tile is an
        // object isolated on transparency, so it was the only dark square on the
        // grid and the eye went to it for the wrong reason. The photograph is
        // good — it now runs full-bleed in V2WeekHero directly below, at the
        // size it earns.
        asset: 'assets/blocks/block_week.png',
        onTap: () => _open(context, 'weekly_snapshot'),
      ),
      V2Block(
        label: 'Scans',
          mark: V2Mark.scan,
        tint: v2BlockTint(V2BlockHues.scans, p),
        icon: Icons.monitor_heart_rounded,
        asset: 'assets/blocks/block_scan.png',
        onTap: () => _open(context, 'tests_scans'),
      ),
      V2Block(
        label: 'Read',
          mark: V2Mark.read,
        tint: v2BlockTint(V2BlockHues.read, p),
        icon: Icons.menu_book_rounded,
        asset: 'assets/blocks/block_read.png',
        onTap: () => _open(context, 'daily_reads'),
      ),
      V2Block(
        label: 'Watch',
          mark: V2Mark.watch,
        tint: v2BlockTint(V2BlockHues.watch, p),
        icon: Icons.play_circle_rounded,
        asset: 'assets/blocks/block_video.png',
        onTap: () => _open(context, 'todays_video'),
      ),
      V2Block(
        label: 'Ask',
          mark: V2Mark.ask,
        tint: v2BlockTint(V2BlockHues.ask, p),
        icon: Icons.auto_awesome_rounded,
        asset: 'assets/blocks/block_ask.png',
        // Routes through the FAB's own three-way stage decision rather than a
        // second copy of it.
        onTap: () => openAskVeda(pregnancy),
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  //  Chrome
  // ---------------------------------------------------------------------------

  Widget _header(BuildContext context, TodayFocus focus, V2Palette p) =>
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              pregnancy.motherName.trim().isEmpty
                  ? 'Today'
                  : 'Today, ${pregnancy.motherName.trim()}',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: p.ink1),
            ),
            const SizedBox(height: 3),
            Text(focus.blurb, style: TextStyle(fontSize: 13, color: p.ink2)),
          ]),
        ),
        const SizedBox(width: 12),
        // The way to change her mind, next to the thing it changes. A choice
        // buried in Profile is a choice she made once and cannot revisit.
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => showFocusChooser(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: p.line),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.tune_rounded, size: 15, color: p.action),
              const SizedBox(width: 5),
              Text('Focus',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: p.action)),
            ]),
          ),
        ),
      ]);

  Widget _eyebrow(String t, V2Palette p) => Text(
        t,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: p.action.withValues(alpha: 0.85),
        ),
      );

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
  Widget _alsoRow(BuildContext context, V2Palette p) {
    const also = ['weekly_snapshot', 'garbh_daily', 'journal', 'medication',
      'tests_scans', 'daily_reads'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _eyebrow('ALSO TODAY', p),
      const SizedBox(height: 4),
      Text('Still here, just not first today.',
          style: TextStyle(fontSize: 12.5, color: p.ink3)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final id in also)
          if (homeFor(id) != null) _alsoChip(context, id, p),
      ]),
    ]);
  }

  Widget _alsoChip(BuildContext context, String id, V2Palette p) {
    final s = kAppSurfaces.firstWhere((x) => x.id == id);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => _open(context, id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: p.line),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(s.label,
              style: TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink1)),
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
                    color: p.action.withValues(alpha: 0.7))),
          ],
        ]),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  The sandbox control
  // ---------------------------------------------------------------------------

  /// Five grounds, switchable on the phone.
  ///
  /// Sits at the BOTTOM rather than the top on purpose: it is scaffolding for
  /// choosing a direction, not part of the design being judged, and a control
  /// bar above the hero would change the very first impression the comparison
  /// exists to test.
  Widget _paletteBar(V2Palette p) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Divider(color: p.line, height: 1),
      const SizedBox(height: 14),
      Text('PALETTE — SANDBOX ONLY',
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: p.ink3)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final q in kV2Palettes)
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => V2PaletteStore.instance.set(q),
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: identical(q, p) ? p.action : p.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                    color: identical(q, p) ? p.action : p.line),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                // A swatch of the ground itself, so the chip previews what it
                // switches to instead of only naming it.
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: q.ground,
                    shape: BoxShape.circle,
                    border: Border.all(color: q.line),
                  ),
                ),
                const SizedBox(width: 7),
                Text(q.name,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: identical(q, p) ? p.onAction : p.ink1)),
              ]),
            ),
          ),
      ]),
      const SizedBox(height: 8),
      Text(p.blurb, style: TextStyle(fontSize: 11.5, color: p.ink3)),
    ]);
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () async {
              await LandingFocus.instance.choose(null);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
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
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
