// =============================================================================
//  HomeV3Screen — direction "2a", built so it can be compared against V2
// -----------------------------------------------------------------------------
//  THE THIRD VERSION, sitting beside Classic and Focus rather than replacing
//  either. home_screen_b.dart (Classic) and home_focus_screen.dart (Focus) are
//  both untouched; the pill in today_home_screen.dart decides which is on
//  screen. Nothing is deleted so all three can be looked at on one phone.
//
//  WHAT 2a IS: grid-led like direction 1a, carrying the full-bleed hero from
//  direction 1b. Four differences from V2, each of which 2a did better —
//  the reasoning for each is in v3_sections.dart.
//
//    header merged INTO the hero  ·  reads as a vertical list  ·  a Begin verb
//    on the practice  ·  "PRICES SHOWN" stated in the products heading
//
//  SAME CONTENT AS V2, and deliberately so. If the two versions differed in
//  what they showed as well as how, a comparison between them would answer
//  nothing. Both read HomeDay, read_next_data, kVideos and product_data.
//
//  ENGLISH ONLY via `.en` — see v2_sections.dart.
// =============================================================================

import 'package:flutter/material.dart';
import 'mind_mood/mind_mood_home_screen.dart';
import 'nutrition/nutrition_home_screen.dart';
import 'belly_skin/belly_skin_home_screen.dart';
import 'conditions/conditions_home_screen.dart';
import '../theme/pv_fonts.dart';
import '../services/tool_usage_store.dart';
import 'brackets/hub/hub_intent_art.dart';
import 'brackets/hub/journey_screen.dart';
import '../data/journeys/journey_registry.dart';
import 'prepare/consultations_screen.dart';
import 'brackets/hub/problem_hub_screen.dart';
import '../data/hubs/pregnancy_hubs.dart';
import '../data/hubs/hub_registry.dart';
import 'package:flutter/services.dart';

// brand_models / launch_spotlight imports removed with the LaunchSpotlight
// block below. Restore both if that block is uncommented.
import '../data/product_data.dart' show productImageUrl;
import '../services/app_nav.dart';
import '../services/app_structure.dart';
import '../services/home_content_controller.dart';
import '../services/landing_focus.dart';
import '../services/life_stage_store.dart';
import '../services/pregnancy_controller.dart';
import 'weekly_card_stack_screen.dart';
import '../services/scans_store.dart';
// openAskVeda dropped from the show list with the Ask door. The FAB still calls
// it; this screen no longer needs to, because Ask is on every screen already.
import '../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../referral/referral_store.dart';
import 'referral/invite_friends_screen.dart';
import 'today_home_screen.dart';
import 'v2/v2_block_art.dart';
import 'v2/v2_block_grid.dart';
import 'v2/v2_palette.dart';
import 'v2/v2_sections.dart';
import '../data/garbh_data.dart';
import '../services/garbh_store.dart';
import 'garbh_screen.dart' show ShravanScreen, SamvadScreen, KriyaScreen;
import '../models/journal_entry.dart';
import '../services/medicine_store.dart';
import '../services/reminder_store.dart';
import '../widgets/journal/journal_create.dart';
import 'journal_screen.dart';
import 'reminders_screen.dart' show showMedReminderEditor;
import 'tools/medicine_tracker_screen.dart';
import 'brackets/bracket_screen.dart';
import 'brackets/scans_hub_screen.dart';
import '../services/bracket_resolver.dart';
import '../services/surface_router.dart';
import 'v2/v3_bracket_art.dart';
import 'v2/v3_daily.dart';
import 'v2/v3_daily_art.dart';
import 'v2/v3_daily_tip.dart';
import 'v2/v3_garbh.dart';
import 'v2/v3_sections.dart';

class HomeV3Screen extends StatefulWidget {
  const HomeV3Screen({super.key, required this.pregnancy, required this.home});

  final PregnancyController pregnancy;
  final HomeContentController home;

  @override
  State<HomeV3Screen> createState() => _HomeV3ScreenState();
}

class _HomeV3ScreenState extends State<HomeV3Screen> {
  PregnancyController get pregnancy => widget.pregnancy;
  HomeContentController get home => widget.home;

  // ---- The daily tip, fired once when this screen first has content ---------
  //
  // WHY NOT initState. On a cold start both controllers are still loading, so
  // `home.dayFor(...)` is null and the tip would be empty — and the guard in
  // showDailyTip is one-shot, so an empty first call would silently eat the
  // only chance to show it. Instead every build tries, and the first build that
  // actually HAS a line wins. The guard makes the repeats free.
  //
  // Deferred by a frame because showing a dialog synchronously inside build
  // mutates the Navigator mid-build — the same "setState during build" class of
  // crash main_scaffold.dart documents for the Ask FAB.
  bool _tipQueued = false;


  /// "Good morning, Meera" — the greeting the hour actually justifies.
  ///
  /// ⚠️ NIGHT IS ITS OWN BAND AND IT MATTERS MOST. Someone opening a pregnancy
  /// app at 2am is usually awake because something is wrong, uncomfortable or
  /// frightening. "Good evening" at that hour reads as an app that is not paying
  /// attention.
  String _greeting(String name) {
    final h = DateTime.now().hour;
    final part = h < 5
        ? 'Good night'
        : h < 12
            ? 'Good morning'
            : h < 17
                ? 'Good afternoon'
                : h < 22
                    ? 'Good evening'
                    : 'Good night';
    return name.trim().isEmpty ? part : '$part, ${name.trim()}';
  }

  /// The line under the hero: where she is, in the terms she thinks in.
  ///
  /// ⚠️ DAY-SPECIFIC, and derived rather than authored, so it is right on all
  /// 280 days without 280 strings. It names the week, the day within the week,
  /// and the one milestone fact that is true of that stretch — a trimester
  /// boundary, viability, full term.
  String _dayLine(int week, int activeDay) {
    final dayInWeek = ((activeDay - 1) % 7) + 1;
    final base = 'Week $week, day $dayInWeek';

    // Only the handful of markers a mother actually counts toward.
    if (week >= 40) return '$base. Any day now.';
    if (week >= 37) return '$base. Full term from here.';
    if (week >= 28) return '$base. Third trimester.';
    if (week == 24) return '$base. A milestone week.';
    if (week >= 20 && week <= 22) return '$base. The anomaly scan window.';
    if (week >= 14) return '$base. Second trimester.';
    if (week >= 13) return '$base. The first trimester is behind you.';
    return '$base. Early days.';
  }

  void _maybeShowTip(String line, int week, int day, V2Palette p) {
    if (_tipQueued || line.trim().isEmpty) return;
    _tipQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDailyTip(context,
          line: line,
          week: week,
          day: day,
          p: p);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Wired once, here, so v3_sections does not have to import product_data.
    productImageUrlV3 = productImageUrl;
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
    final p = V2PaletteStore.instance.current;
    final reads = v2ReadsFor(week, activeDay);
    final video = v2VideoFor(week);
    final products = v2ProductsFor(week, activeDay);

    final insight = (day?.grow.remember.en.trim().isNotEmpty ?? false)
        ? day!.grow.remember.en
        : (day?.grow.insight.en ?? '');

    final name = pregnancy.motherName.trim();

    // The tip no longer has a section on this page — it arrives as a card in
    // the middle of the screen on open. See v2/v3_daily_tip.dart for why a
    // greeting is not the interstitial §16.3 bans.
    _maybeShowTip(insight, week, activeDay, p);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // The clock, battery and signal now sit ON the photograph, so they have
      // to be light. Without this they render dark-on-dark and disappear.
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
        color: p.ground,
        // NO SafeArea AT THE TOP, deliberately. SafeArea would inset the list
        // below the status bar and leave a coloured strip above the image —
        // which is exactly the seam this screen is trying not to have. The
        // hero adds MediaQuery.padding.top to its own header instead, so the
        // photograph bleeds under the bar while her name still clears it.
        child: SafeArea(
          top: false,
          bottom: false,
        // NO HORIZONTAL PADDING ON THE LIST. The hero has to reach both
        // edges, and a list that pads everything cannot let one child out.
        // Every other section wraps itself in _pad() instead.
        child: ListView(
          padding: const EdgeInsets.only(bottom: kAskFabReserve),
          children: [
            // ---- HEADER AND HERO AS ONE BLOCK -------------------------------
            if (day != null)
              V3Hero(
                // ⚠️ THE GREETING NOW KNOWS THE TIME, AND THE SUBTITLE KNOWS
                // THE DAY.
                //
                // It said "Today, mum" at every hour and "Symptoms, medicines
                // and how you are doing" in every one of the 280 days. Both were
                // true always, which is another way of saying neither was about
                // now. The screen already held the hour and the day and was
                // using neither.
                //
                // See `_greeting()` and `_dayLine()` below.
                name: _greeting(name),
                subtitle: _dayLine(week, activeDay),
                week: week,
                day: activeDay,
                learning: day.babyLearning.en,
                p: p,
                onTap: () => _open(context, 'weekly_snapshot'),
                // ⚠️ A PUSH, NOT A TAB SWITCH. `_open` routes through
                // `homeFor()` to `AppNav.go(tabIndex)`, which lands on Today —
                // the classic home. The chip says WEEK 40, so it has to open
                // week 40.
                //
                // `selectWeek` before the push, because the stack reads the
                // controller's selection rather than taking a week argument;
                // pushing without it opens the stack wherever it was left.
                onSpine: () {
                  pregnancy.selectWeek(week);
                  Navigator.of(context).push(MaterialPageRoute(
                    settings: const RouteSettings(name: 'weekly_card_stack'),
                    builder: (_) =>
                        WeeklyCardStackScreen(controller: pregnancy),
                  ));
                },
                onAvatar: () => _open(context, 'journal'),
                onSaved: () => _open(context, 'saved'),
              ),
            // Everything except the hero is inset. The hero is the only
            // child allowed to touch the screen edges.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            const SizedBox(height: 24),

            // ---- The only time-sensitive row, still hiding when empty -------
            V2ComingUp(p: p, onTap: () => _open(context, 'tests_scans')),
            if (ScansStore.instance.appointments.isNotEmpty)
              const SizedBox(height: 12),

            // MOVEMENT / KICK COUNT REMOVED — placement rejected.
            //
            // It sat under "Coming up" on the argument that both answer "does
            // anything need me today". On the phone it read as an interruption
            // between the hero and the doors: the first thing after the
            // photograph was a clinical instruction, which is the opposite of
            // what this screen opens with everywhere else.
            //
            // Not re-homed elsewhere on purpose. The Scans door and the
            // Tests & scans chip already reach it, and a clinical prompt needs
            // a placement decision rather than a spare slot. Note also that the
            // copy was written here rather than taken from the content files —
            // if it comes back, the words come from a clinician.

            // ---- WHERE TO GO ------------------------------------------------
            // "Six doors" counted the tiles, which is a fact about the layout and
            // not a thing she needs. This gives permission instead: no order, no
            // right answer, nothing waiting to be worked through.
            V3SectionHead(
                eyebrow: 'What are you looking for?',
                title: 'Start anywhere',
                p: p),
            const SizedBox(height: 12),
            V2BlockGrid(
                palette: p, blocks: _brackets(context, p), columns: 4),
            const SizedBox(height: 28),

            // ⚠️ READS AND WATCH HAVE SWAPPED PLACES.
            //
            // Reads used to sit here, directly under the doors, with Watch far
            // below. Recommended Watch now comes first and Recommended Reads
            // follows it, because a video is the lower-effort thing to start and
            // the one more likely to be opened on a tired evening. The reads
            // block moved down rather than being duplicated — see below.

            // ---- GARBH SANSKAR ---------------------------------------------
            //
            // One block, not three cards. See v3_garbh.dart for what was wrong
            // and which principle each fix comes from.
            if (day != null) ...[
              ListenableBuilder(
                listenable: GarbhStore.instance,
                builder: (context, _) {
                  final store = GarbhStore.instance;
                  final cd = activeDay;
                  final tri = garbhTrimester(week);
                  final rows = <GarbhPillarRow>[
                    GarbhPillarRow(
                      name: 'Shravan',
                      image:
                          'https://images.unsplash.com/photo-1633411988188-6e63354a9019?w=200&h=200&fit=crop',
                      tag: 'Sacred listening',
                      today: shravanForDay(cd).title.en,
                      icon: Icons.graphic_eq_rounded,
                      accent: const Color(0xFF9A7526),
                      done: store.isDone('shravan'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ShravanScreen(
                              controller: pregnancy, daily: true))),
                    ),
                    GarbhPillarRow(
                      name: 'Samvad & Vichara',
                      image:
                          'https://images.unsplash.com/photo-1541956799312-3f9df99e0006?w=200&h=200&fit=crop',
                      tag: 'Womb talk',
                      today: promptForDay(cd, tri).text.en,
                      icon: Icons.record_voice_over_rounded,
                      accent: const Color(0xFF9C5F51),
                      done: store.isDone('samvad'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => SamvadScreen(
                              controller: pregnancy, daily: true))),
                    ),
                    GarbhPillarRow(
                      name: 'Kriya',
                      image:
                          'https://images.unsplash.com/photo-1485808269728-77bb07c059a8?w=200&h=200&fit=crop',
                      tag: 'Breath & grounding',
                      today: kriyaForDay(cd).title.en,
                      icon: Icons.spa_rounded,
                      accent: const Color(0xFF3F6E62),
                      done: store.isDone('kriya'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              KriyaScreen(controller: pregnancy, daily: true))),
                    ),
                  ];
                  return V3GarbhSection(
                    day: day,
                    p: p,
                    rows: rows,
                    onAbout: () => _open(context, 'garbh_daily'),
                  );
                },
              ),
              const SizedBox(height: 28),
            ],

            // ---- TODAY'S MEDICINES ------------------------------------------
            //
            // Restored from Classic. It sits directly under Garbh Sanskar
            // because the two belong to the same half of the screen: everything
            // above is content she takes in, and these are the things she DOES.
            // Grouping them means the page has one "your turn" region rather
            // than actions scattered between articles.
            V3SectionHead(
                eyebrow: 'Medicine Reminder',
                title: "Don't miss today's dose",
                p: p),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable:
                  Listenable.merge([MedicineStore.instance, ReminderStore.instance]),
              builder: (context, _) {
                final store = MedicineStore.instance;
                return V3MedsSection(
                  p: p,
                  items: [
                    for (final m in store.activeMeds)
                      V3MedItem(
                        name: m.name,
                        sub: [m.dose, m.time]
                            .where((x) => x.isNotEmpty)
                            .join(' · '),
                        taken: store.isTakenToday(m.id),
                        onToggle: () => store.toggleToday(m.id),
                      ),
                  ],
                  onManage: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          MedicineTrackerScreen(controller: pregnancy))),
                  onAddReminder: () =>
                      showMedReminderEditor(context, pregnancy),
                );
              },
            ),
            const SizedBox(height: 28),

            // ---- MY JOURNAL --------------------------------------------------
            //
            // Also restored. Four verbs, not a prompt — she arrives already
            // knowing whether she wants to write, photograph or speak, and the
            // job of this card is to not stand between her and that.
            V3SectionHead(
                eyebrow: 'My journal',
                title: 'Something for your baby, when it grows up',
                p: p),
            const SizedBox(height: 12),
            V3JournalSection(
              p: p,
              // Four hues off the controlled-pastel wheel, same rule as the six
              // doors: hue varies, saturation and lightness do not, so four
              // different colours still read as one system.
              actions: [
                V3QuickAction(
                    icon: Icons.edit_note_rounded,
                    mark: V3DailyMark.memory,
                    hue: 42,
                    label: 'Write a\nmemory',
                    onTap: () => openJournalText(
                        context, pregnancy, JournalEntryType.memory)),
                V3QuickAction(
                    icon: Icons.favorite_border_rounded,
                    mark: V3DailyMark.note,
                    hue: 344,
                    label: 'Note for\nbaby',
                    onTap: () => openJournalText(
                        context, pregnancy, JournalEntryType.noteForBaby)),
                V3QuickAction(
                    icon: Icons.photo_camera_outlined,
                    mark: V3DailyMark.photo,
                    hue: 206,
                    label: 'Add a\nphoto',
                    onTap: () => openJournalAddPhoto(context, pregnancy)),
                V3QuickAction(
                    icon: Icons.mic_none_rounded,
                    mark: V3DailyMark.voice,
                    hue: 268,
                    label: 'Record\nvoice',
                    onTap: () => openJournalRecordVoice(context, pregnancy)),
              ],
              onOpenAll: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => JournalScreen(controller: pregnancy))),
            ),
            const SizedBox(height: 28),

            // ---- TODAY'S TIP — MOVED OUT OF THE PAGE ------------------------
            //
            // Kept commented rather than deleted, per the repo's "comment out,
            // never delete" rule: if the pop-up turns out to be the wrong home
            // for it, this is the section it goes back to.
            //
            // if (insight.trim().isNotEmpty) ...[
            //   V3SectionHead(
            //       eyebrow: "Today's tip", title: 'Worth remembering', p: p),
            //   const SizedBox(height: 12),
            //   V2InsightBlock(line: insight, p: p),
            //   const SizedBox(height: 28),
            // ],

            // ---- RECOMMENDED WATCH — above the reads -------------------------
            if (video != null) ...[
              V3SectionHead(
                  eyebrow: 'Recommended Watch',
                  title: 'Six minutes, this week',
                  p: p),
              const SizedBox(height: 12),
              V2VideoCard(
                  video: video,
                  p: p,
                  onTap: () => _open(context, 'todays_video')),
              const SizedBox(height: 28),
            ],

            // ---- RECOMMENDED READS — now below Watch ------------------------
            //
            // "Short enough for today" was about length. "Research-backed
            // articles" is about why she should trust it, which is the thing
            // that actually makes someone open a pregnancy article.
            if (reads.isNotEmpty) ...[
              V3SectionHead(
                  eyebrow: 'Recommended Reads',
                  title: 'Research-backed articles',
                  p: p),
              const SizedBox(height: 8),
              for (final r in reads.take(3))
                V3ReadRow(
                    item: r,
                    p: p,
                    onTap: () => _open(context, 'daily_reads')),
              const SizedBox(height: 28),
            ],

            // ---- THINGS THAT HELP · PRICES SHOWN ----------------------------
            if (products.isNotEmpty) ...[
              // ⚠️ THE TITLE IS NOW WEEK-SPECIFIC, AND THE PRICE NOTE IS GONE.
              //
              // "What mothers ask us about" was true of every mother in every
              // week, which is another way of saying it was about nobody. The
              // week number is the one fact this screen already knows and was
              // not using.
              //
              // `note: 'Prices shown'` is removed with the prices themselves:
              // a price on the home screen turns a companion into a shop front
              // before she has asked to shop.
              V3SectionHead(
                  eyebrow: 'Recommended Products',
                  title: 'Crafted for Week $week of Pregnancy',
                  p: p),
              const SizedBox(height: 12),
              // A RAIL, NOT A LIST — and the difference is the point.
              //
              // Reads get the committed vertical treatment because a read is
              // the thing we want her to do. Products are optional, so they get
              // the browse treatment: "some things exist, swipe if curious".
              // Four rows with right-aligned prices read like an invoice; a
              // rail reads like a shelf, and takes a third of the height.
              V2ProductRail(
                  items: products, p: p, onOpen: () => _open(context, 'shop')),
              const SizedBox(height: 28),
            ],

            // ---- USE THESE TOOLS --------------------------------------------
            //
            // ⚠️ WAS "Also today · Still here, just not first" — a heading that
            // told her these were the leftovers. It also rendered as a wrap of
            // text pills, which is a list of names rather than a set of tools.
            //
            // It is now a real tool section that adapts: recommended tools when
            // she has used none, her own most-used when she has. See _ToolsRow.
            _ToolsRow(p: p, week: week, onOpen: (id) => _open(context, id)),
            const SizedBox(height: 28),

            // ---- Commerce, after the content --------------------------------
            //
            // ⚠️ LAUNCH SPOTLIGHT REMOVED FROM V3, kept commented per the
            // repo's "comment out, never delete" rule.
            //
            // It is a sponsored brand card ("A PARENTVEDA LAUNCH — Calm Balm").
            // The same brand moment is meant to arrive as a full-screen card on
            // open, so carrying it at the foot of the page as well is the same
            // promotion twice in one session — and a promotion she has already
            // dismissed, reappearing, is the exact pattern §16.3 calls pursuit.
            //
            // NOTE FOR WHOEVER PICKS THIS UP: the full-screen version
            // (widgets/launch_promo.dart) is currently NOT WIRED — its import
            // in main_scaffold.dart is commented out, so nothing shows it on
            // open today. Removing this leaves the brand slot with no surface
            // at all on V3 until that is re-enabled. Stated rather than
            // discovered, because a silently empty monetisation slot is the
            // kind of gap that survives for months.
            //
            // LaunchSpotlight(
            //   stage: BrandStage.pregnancy,
            //   pregnancyWeek: week,
            //   padding: const EdgeInsets.only(bottom: 14),
            // ),
            ListenableBuilder(
              listenable: ReferralStore.instance,
              builder: (context, _) {
                final store = ReferralStore.instance;
                if (!store.isLoaded || !store.config.enabled) {
                  return const SizedBox.shrink();
                }
                return V3InviteBlock(
                  p: p,
                  inviterReward: store.config.inviterReward.label.toLowerCase(),
                  inviteeReward: store.config.inviteeReward.label.toLowerCase(),
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const InviteFriendsScreen())),
                );
              },
            ),
            const SizedBox(height: 20),
            // ⚠️ OFF, KEPT FOR REVERT. `_ArtToggle` switched the door marks
            // between rendered objects and drawn marks. Drawn won, and the
            // control was competing for the same corner as the nav and the
            // version pill — three floating controls clipping the grid.
            // _ArtToggle(p: p),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  /// Same six doors as V2 — the grid is the part both versions share, so that
  /// what differs between them is structure rather than contents.
  /// The doors, built from the bracket table rather than written out by hand.
  ///
  /// ⚠️ THE SIX LITERAL TILES ARE GONE. They are kept commented at the foot of
  /// this file per "comment out, never delete" — but three of them were never
  /// brackets at all: Practice, This week and Ask are RHYTHM, not problems. On
  /// this screen all three were already duplicated elsewhere:
  ///
  ///   this week  -> the hero, directly above this grid
  ///   practice   -> the Garbh Sanskar section, further down
  ///   ask        -> the global FAB, on every screen in the app
  ///
  /// So the grid loses three duplicates and gains ten entry points that did not
  /// exist anywhere. That is the trade, and it is why the count went 6 -> 10
  /// rather than 6 -> 13.
  ///
  /// ⚠️ AND A DOOR NOW OPENS A SCREEN, NOT A TAB. The old tiles ran
  /// `surfaceId -> homeFor() -> AppNav.go(tabIndex)`; these push a bracket
  /// route. Same rectangle, different kind of object.
  List<V2Block> _brackets(BuildContext context, V2Palette p) => [
        for (final b in bracketsFor(LifeStage.pregnancy))
          V2Block(
            label: b.label.of(pregnancy.language),
            // Never rendered — bracketMark always wins — but required, and a
            // sensible fallback beats a placeholder nobody would notice.
            icon: Icons.circle_outlined,
            tint: v2BlockTint(b.hue, p),
            bracketMark: bracketMarkFor(b.id),
            onTap: () => _openBracket(context, b.id),
          ),
      ];

  /// Push a bracket screen.
  ///
  /// Named route from the first line, because notifications, referral and the
  /// brand Premiere all navigate by name — retrofitting a name after something
  /// already pushes anonymously is a migration nobody schedules.
  ///
  /// Analytics deliberately records nothing here. `usage_events.dart` is
  /// write-only with no read grant and its own stated rule is "which room, never
  /// what was in it" — logging `pregnancy_mental_health` would put a health
  /// signal into a log nothing can retract. One surface, no id, or none at all.
  void _openBracket(BuildContext context, String bracketId) {
    final b = bracketById(bracketId);
    if (b == null) return; // wiring test makes this unreachable

    // ⚠️ ONE BRACKET HAS GRADUATED FROM THE GENERIC SCREEN.
    //
    // Scans & tests is the highest-volume bracket in the product, and the only
    // one whose demand data splits into two incompatible needs — anomaly scan
    // ~135,000 (calm, planning) and ectopic ~74,000 (frightened, 2am). A
    // layer-ordered list cannot put an emergency above a library, so this one
    // gets a hand-built hub. See docs/SCANS-FLOW-SCREENS.md.
    //
    // Everything else still opens `BracketScreen`, and that is the intended
    // steady state rather than a backlog: a bracket earns a bespoke screen when
    // its volume justifies one. The resolver stays the chokepoint either way —
    // the hub asks `canRender()` exactly as the generic screen does.
    if (bracketId == kScansBracketId) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'bracket/scans'),
        builder: (_) => ScansHubScreen(bracket: b, pregnancy: pregnancy),
      ));
      return;
    }

    // ⚠️ EVERY OTHER BRACKET NOW GOES THROUGH THE HUB REGISTRY.
    //
    // The comment above used to say the generic screen was "the intended steady
    // state rather than a backlog", and that a bracket earned a hub when its
    // volume justified one. The door audit replaced that: every hub now has a
    // declared set of doors, and a bracket without one is the exception rather
    // than the rule.
    //
    // TWO OUTCOMES, and the second is the one that matters:
    //   · 2+ doors -> the hub screen, because there is something to choose;
    //   · ONE door -> its destination directly, because a screen whose only
    //     content restates the tile she just tapped is a tap of pure tax.
    final hub = hubFor(bracketId);
    if (hub != null) {
      final sole = soleDoorOf(bracketId);
      if (sole != null) {
        if (sole.action != null) {
          _hubAction(context, sole.action!);
        } else if (sole.surfaceId != null) {
          _openSurfaceScreen(context, sole.surfaceId!);
        }
        return;
      }
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'hub/$bracketId'),
        builder: (_) => ProblemHubScreen(
          config: hub,
          bracket: b,
          lang: pregnancy.language,
          listenTo: V2PaletteStore.instance,
          onSurface: _openSurfaceScreen,
          onAction: _hubAction,
        ),
      ));
      return;
    }

    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'bracket'),
      builder: (_) => BracketScreen(
        bracket: b,
        lang: pregnancy.language,
        // Pregnancy answers from app_structure; parenting will answer from its
        // own list. See BracketScreen.labelFor.
        labelFor: (id) {
          final s = kAppSurfaces.where((x) => x.id == id);
          return s.isEmpty ? null : s.first.label;
        },
        onOpenSurface: _openSurfaceScreen,
      ),
    ));
  }

  /// The pregnancy hub actions — destinations a surface id cannot name on its
  /// own, either because the screen needs a constructor argument or because the
  /// right answer depends on state.
  ///
  /// ⚠️ EVERY ONE OF THESE REUSES A SCREEN THAT ALREADY SHIPS. Nothing here is
  /// a new feature; the doors are new, the destinations are not.
  void _hubAction(BuildContext context, String action) {
    void push(Widget s, String name) =>
        Navigator.of(context).push(MaterialPageRoute<void>(
            settings: RouteSettings(name: name), builder: (_) => s));

    // ⚠️ THREE DOORS NOW HAVE REAL SECTIONS, AND THEY MUST JUMP THE JOURNEY
    // GUARD BELOW.
    //
    // The guard returns early for any action with a journey, so a door that has
    // both a journey and a destination would open the journey forever and its
    // `case` below would be dead code that looks alive. Complications, Nutrition
    // and Belly & skin now have whole built sections, which are strictly better
    // than the three-to-five step journeys that stood in for them.
    //
    // The journeys are NOT deleted: they stay in `kPregnancyJourneys` as the
    // record of what each door promised, and they are what these sections were
    // built to satisfy.
    switch (action) {
      case kPgActConditionLibrary:
        push(conditionsHomeScreen(pregnancy: pregnancy), 'conditions');
        return;
      case kPgActSkinConcern:
        push(bellySkinHomeScreen(controller: pregnancy), 'belly_skin');
        return;
      case kPgActNutritionFlag:
      case kPgActNutritionMain:
        push(nutritionHomeScreen(), 'nutrition');
        return;
      // Mind & Mood replaces the two placeholder mood actions, which used to
      // fall back to the reads library because no mood surface existed.
      case kPgActMoodCheck:
      case kPgActFeelBetter:
        push(mindMoodHomeScreen(controller: pregnancy), 'mind_mood');
        return;
    }

    // ⚠️ A JOURNEY FIRST, IF THIS DOOR HAS ONE.
    //
    // Doors whose destination already finishes the job fall straight through to
    // the switch below — wrapping a journey around a complete screen is the
    // same tax as a hub screen in front of a single door.
    final journey = journeyFor(action);
    if (journey != null) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'journey/' + action),
        builder: (_) => JourneyScreen(
          config: journey,
          onSurface: _openSurfaceScreen,
          onAction: _hubAction,
        ),
      ));
      return;
    }




    switch (action) {
      // ⚠️ FILTERED TO THE EXPERT WE NAMED. The hubs promise different people —
      // Complications and Scans say a doctor, Nutrition says a nutritionist,
      // Mind & mood says someone who works with mothers — so the action carries
      // the role rather than dumping her on the full list every time.
      case kPgActConsult:
        push(
            ConsultationsScreen(lang: pregnancy.language, onlyRole: 'sp_ob'),
            'consults');

      case kPgActConsultNutrition:
        push(
            ConsultationsScreen(
                lang: pregnancy.language, onlyRole: 'sp_nutrition'),
            'consults');

      case kPgActConsultCounsellor:
        push(
            ConsultationsScreen(
                lang: pregnancy.language, onlyRole: 'sp_counsellor'),
            'consults');

      // ⚠️ A CLASS, NOT A CONSULT. This case exists because the Labour prep hub
      // used `kPgActConsult` under a "Join a birthing class" label and sent her
      // to a gynaecologist instead. See the note at that call site.
      case kPgActBirthClass:
        _openSurfaceScreen(context, 'birthing_classes');

      // Sugar, blood pressure and weight all live in the existing trackers.
      // Weight is the one that exists as its own screen today; the others are
      // reached from it. Not a new tracker — §11 forbids one.
      case kPgActTrackReadings:
        _openSurfaceScreen(context, 'weight');

      // The condition library is the tests/scans/reports reference, which
      // already carries conditions alongside scans.
      case kPgActConditionLibrary:
        _openSurfaceScreen(context, 'tests_scans');

      // "Prepare for birth" = the birth-prep reading plus the bag tool; the
      // birthing classes are its closing offer, not its entry.
      case kPgActBirthPrep:
        _openSurfaceScreen(context, 'birthing_classes');

      // ⚠️ THE MOOD FALLBACK IS GONE, AND THAT IS THE POINT.
      // These two used to open the reads library because no mood surface
      // existed. Mind & Mood now exists, and the cases above route to it.
    }
  }

  /// Open a surface as a SCREEN where one exists, and fall back to the tab jump
  /// where it does not.
  ///
  /// The difference matters inside a bracket. `_open` moves the bottom-nav index
  /// and leaves her on a hub to find the row herself — acceptable for a
  /// demotion chip that means "this lives over there", useless for a row that
  /// says "Appointments" and should open appointments. A door that lands one
  /// screen short is the same defect as a door that opens nothing, only harder
  /// to notice.
  ///
  /// Falls back rather than failing: `daily_reads` and `weekly_snapshot` live
  /// inside Today rather than standing alone, and for those the tab jump is the
  /// honest answer.
  void _openSurfaceScreen(BuildContext context, String surfaceId) {
    final screen =
        screenForSurface(surfaceId, pregnancy, pregnancy.language);
    if (screen == null) {
      _open(context, surfaceId);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: surfaceId),
      builder: (_) => screen,
    ));
  }

  void _open(BuildContext context, String surfaceId) {
    final h = homeFor(surfaceId);
    if (h == null) return;
    switch (h) {
      case AppHome.today:
      case AppHome.profile:
        TodayVersionStore.instance.set(TodayVersion.classic);
      case AppHome.prepare:
        AppNav.instance.go(1);
      case AppHome.tools:
        AppNav.instance.go(2);
      case AppHome.calendar:
        AppNav.instance.go(3);
      case AppHome.community:
        AppNav.instance.go(4);
    }
  }
}

/// The demotion row — everything the day did not lead with, named, with the tab
/// that owns it.
///
/// Its absence is how V3 first shipped without My journal, Medicines or
/// Tests & scans anywhere on the home screen. A screen that leads with six
/// things still has to say where the other twenty went.
// ⚠️ ORPHANED BY A COMMENTED-OUT CALL SITE, KEPT ON PURPOSE.
// The repo rule is comment out, never delete: the revert has to bring
// back a block that still compiles, which it will not if its helper was
// tidied away in the meantime.
// `_AlsoRow` is what "Also today" rendered before it became
// "Use These Tools" — see `_ToolsRow`.
// ignore: unused_element
class _AlsoRow extends StatelessWidget {
  const _AlsoRow({required this.p, required this.onOpen});

  final V2Palette p;
  final void Function(String id) onOpen;

  // 'journal' and 'medication' were here and have been REMOVED, because they
  // now have real sections above. A surface named twice on one screen — once as
  // the thing itself and once as a chip pointing at it — teaches her that the
  // chips are unreliable, which costs the whole row its usefulness.
  static const _ids = [
    'tests_scans',
    'weight',
    'hospital_bag',
    'can_i',
  ];

  @override
  Widget build(BuildContext context) {
    final ids = _ids.where((id) => homeFor(id) != null).toList();
    if (ids.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      V3SectionHead(
          eyebrow: 'Also today', title: 'Still here, just not first', p: p),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final id in ids)
          Builder(builder: (context) {
            final surface = kAppSurfaces.firstWhere((x) => x.id == id);
            return InkWell(
              onTap: () => onOpen(id),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: p.line),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(surface.label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: p.ink1)),
                  if (surface.home != AppHome.today) ...[
                    const SizedBox(width: 6),
                    Text(surface.home.label,
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: p.action.withValues(alpha: 0.7))),
                  ],
                ]),
              ),
            );
          }),
      ]),
    ]);
  }
}

/// Rendered objects vs drawn marks, switchable on the phone.
///
/// Same reasoning as the palette bar: a taste question between two coherent
/// options is settled faster by looking than by arguing. Sandbox chrome —
/// it goes when one of the two wins.
// ⚠️ ORPHANED BY A COMMENTED-OUT CALL SITE, KEPT ON PURPOSE.
// The repo rule is comment out, never delete: the revert has to bring
// back a block that still compiles, which it will not if its helper was
// tidied away in the meantime.
// ignore: unused_element
class _ArtToggle extends StatelessWidget {
  const _ArtToggle({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: V2BlockArtMode.instance,
      builder: (context, _) {
        Widget seg(String label, bool vector) {
          final on = V2BlockArtMode.instance.vector == vector;
          return InkWell(
            onTap: () => V2BlockArtMode.instance.set(vector),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: on ? p.action : p.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: on ? p.action : p.line),
              ),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: on ? p.onAction : p.ink1)),
            ),
          );
        }

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Divider(color: p.line, height: 1),
          const SizedBox(height: 16),
          Text('DOOR MARKS — SANDBOX ONLY',
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: p.ink3)),
          const SizedBox(height: 12),
          Row(children: [
            seg('Rendered', false),
            const SizedBox(width: 8),
            seg('Drawn', true),
          ]),
        ]);
      },
    );
  }
}

// =============================================================================
//  THE SIX LITERAL DOORS — kept for revert, per "comment out, never delete"
// -----------------------------------------------------------------------------
//  Replaced by `_brackets()`, which builds ten doors from the bracket table.
//  Restoring these means restoring `openAskVeda` to the global_ask_fab import
//  and setting the grid back to `columns: 3`.
//
//  Three of them were never problem brackets — Practice, This week and Ask are
//  rhythm — and all three were already duplicated elsewhere on this screen. That
//  is why the replacement is 6 -> 10 and not 6 -> 13.
//
//  List<V2Block> _blocks(BuildContext context, int week, V2Palette p) => [
//        V2Block(label: 'Practice', mark: V2Mark.practice,
//            tint: v2BlockTint(V2BlockHues.practice, p), meta: 'Today',
//            icon: Icons.self_improvement_rounded,
//            asset: 'assets/blocks/block_practice.png',
//            onTap: () => _open(context, 'garbh_daily')),
//        V2Block(label: 'This week', mark: V2Mark.week,
//            tint: v2BlockTint(V2BlockHues.week, p), meta: 'Week $week',
//            icon: Icons.child_care_rounded,
//            asset: 'assets/blocks/block_week.png',
//            onTap: () => _open(context, 'weekly_snapshot')),
//        V2Block(label: 'Scans', mark: V2Mark.scan,
//            tint: v2BlockTint(V2BlockHues.scans, p),
//            icon: Icons.monitor_heart_rounded,
//            asset: 'assets/blocks/block_scan.png',
//            onTap: () => _open(context, 'tests_scans')),
//        V2Block(label: 'Read', mark: V2Mark.read,
//            tint: v2BlockTint(V2BlockHues.read, p),
//            icon: Icons.menu_book_rounded,
//            asset: 'assets/blocks/block_read.png',
//            onTap: () => _open(context, 'daily_reads')),
//        V2Block(label: 'Watch', mark: V2Mark.watch,
//            tint: v2BlockTint(V2BlockHues.watch, p),
//            icon: Icons.play_circle_outline_rounded,
//            asset: 'assets/blocks/block_video.png',
//            onTap: () => _open(context, 'todays_video')),
//        V2Block(label: 'Ask', mark: V2Mark.ask,
//            tint: v2BlockTint(V2BlockHues.ask, p),
//            icon: Icons.auto_awesome_rounded,
//            asset: 'assets/blocks/block_ask.png',
//            onTap: () => openAskVeda(pregnancy)),
//      ];
// =============================================================================

/// The home screen's tool section.
///
/// ⚠️ REPLACES `_AlsoRow`, WHICH WAS A WRAP OF TEXT PILLS UNDER THE HEADING
/// "Also today · Still here, just not first" — a heading that told her these
/// were the leftovers, above a row that was the same for everyone forever.
///
/// Two states, and the difference is the requirement:
///
///   no history  ->  recommended tools for her week (see recommendedToolsForWeek)
///   history     ->  her own most-used, max four
///
/// ⚠️ EVERY TILE ROUTES. `homeFor(id)` is checked before a tile is built, so a
/// tool that has no destination is never drawn — "do not show static cards that
/// don't lead to the actual tool". A tile that looks tappable and goes nowhere
/// teaches her that taps do nothing, everywhere in the app.
///
/// ⚠️ AND IT NEVER HIDES A TOOL FROM THE APP. This reorders what is in front of
/// her; the full set stays in the Tools tab. Personalisation changes ranking,
/// never structure — `test/landing_focus_test.dart` holds that line.
class _ToolsRow extends StatelessWidget {
  const _ToolsRow(
      {required this.p, required this.week, required this.onOpen});

  final V2Palette p;
  final int week;
  final void Function(String id) onOpen;

  /// ⚠️ THE SAME DRAWN MARKS THE DOORS USE, NOT MATERIAL ICONS.
  ///
  /// The comment on this map used to claim "a drawn mark per tool… so this reads
  /// as the same family as the six doors above" and then hold a list of
  /// `Icons.*`. The claim was the intent and the map was the implementation, and
  /// they disagreed — on a phone the section directly below ten hand-drawn marks
  /// showed four stock glyphs, which is exactly the seam the door art exists to
  /// remove. Caught on the device:
  ///
  ///   "in use these tools section again use the icons/art whatever its called
  ///    that we are using in doors icons"
  ///
  /// ⚠️ THE MAPPING IS BY ACT, NOT BY OBJECT, which is `hub_intent_art.dart`'s own
  /// rule — "logging a reading should look the same whether she is logging blood
  /// pressure in Complications or sleep in Sleep, because it is the same act".
  /// So weight takes `scaleMark`, appointments takes `calendarDay`, and the
  /// hospital bag takes the same `bagMark` its door does. Two of these are
  /// literally the same tool as a door above (hospital bag, tests & scans), and
  /// they now look identical in both places rather than being drawn twice.
  ///
  /// The hues are unchanged: a hue belongs to a subject and follows it.
  static const Map<String, (IntentMark, double)> _face = {
    'due_date': (IntentMark.calendarDay, 26),
    'symptoms': (IntentMark.bodyMark, 344),
    'can_i': (IntentMark.questionMark, 104),
    'tests_scans': (IntentMark.scanFan, 206),
    'appointments': (IntentMark.calendarDay, 160),
    'medication': (IntentMark.listMark, 268),
    'weight': (IntentMark.scaleMark, 42),
    'kegel': (IntentMark.lotusMark, 186),
    // The movement counter is the act of logging something repeatedly — the same
    // act as a BP log — so it takes the chart mark rather than a baby's face.
    'movement': (IntentMark.chartLog, 26),
    'contractions': (IntentMark.timelineRail, 344),
    'hospital_bag': (IntentMark.bagMark, 160),
    'reports': (IntentMark.reportPage, 42),
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ToolUsageStore.instance,
      builder: (context, _) {
        final store = ToolUsageStore.instance;

        // Her own tools if she has any, otherwise the ones worth her week.
        final source = store.hasHistory
            ? [
                ...store.ranked,
                // Top up from the recommendations so the row is never a lonely
                // single tile after one use.
                ...recommendedToolsForWeek(week),
              ]
            : recommendedToolsForWeek(week);

        final ids = <String>[];
        for (final id in source) {
          if (ids.length == 4) break;
          if (ids.contains(id)) continue;
          if (!_face.containsKey(id)) continue;
          if (homeFor(id) == null) continue; // must actually route
          ids.add(id);
        }
        if (ids.isEmpty) return const SizedBox.shrink();

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          V3SectionHead(
              eyebrow: 'Use These Tools',
              title: store.hasHistory
                  ? 'The ones you come back to'
                  : 'Worth having at week $week',
              p: p),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < ids.length; i++) ...[
                Expanded(child: _tile(context, ids[i])),
                if (i != ids.length - 1) const SizedBox(width: 10),
              ],
            ],
          ),
        ]);
      },
    );
  }

  Widget _tile(BuildContext context, String id) {
    final (mark, hue) = _face[id]!;
    final label = kAppSurfaces.firstWhere((x) => x.id == id).label;
    final tint = v2BlockTint(hue, p);

    return InkWell(
      onTap: () => onOpen(id),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(14),
              ),
              // ⚠️ INSET, BECAUSE THE MARKS ARE AUTHORED EDGE-TO-EDGE.
              //
              // Every painter in `hub_intent_art.dart` draws in a 100×100 box and
              // fills it. Dropping one straight into this tile makes it touch all
              // four sides, and next to the doors — which give theirs breathing
              // room — it reads as a bigger, cruder version of the same drawing.
              // The padding is what makes the two sections look like one family,
              // and it is the whole reason a mark cannot simply replace an
              // `Icon`, which brings its own optical margin.
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: HubIntentArt(mark: mark, tint: tint),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: p.ink1)),
        ],
      ),
    );
  }
}
