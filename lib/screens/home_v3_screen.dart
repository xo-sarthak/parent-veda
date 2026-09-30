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
//
//  RESHAPED 2026-09-16 TO THE "Pregnancy Home V3" CLAUDE DESIGN (option 1a).
//  The order is now: hero · scans due · Start anywhere · This Week Explained
//  (the week's film, full-bleed, playing in place) · Garbh Sanskar (a
//  full-bleed band with the practice card over it) · Medicine reminder · My
//  journal · Watch These Videos This Week (a three-row shelf) · Recommended
//  reads · Recommended products · Use these tools. What moved, what was
//  commented out and what was assumed is recorded in docs/STILL-OPEN.md §58.
// =============================================================================

import 'package:flutter/material.dart';
// import 'mind_mood/mind_mood_home_screen.dart'; // retired 2026-09-12 — the door
import '../data/doors/pv_door_mind.dart' show kMindTabFeel, kMindTabTrack;
import 'nutrition/nutrition_home_screen.dart';
import 'nutrition/nutrition_stage_screen.dart';
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
// import '../data/product_data.dart' show productImageUrl; // kept for revert, see build()
import '../services/app_nav.dart';
import 'calendar_screen.dart';
import 'doors/pv_door_router.dart' show openPvDoorSurface, openPvDoorRead;
import 'pregnancy/preg_hero_extras.dart';
import 'pregnancy/preg_more_screen.dart' show kPregTabMore, kPregTabProducts, kPregTabTools;
import '../services/app_structure.dart';
import '../services/home_content_controller.dart';
import '../services/landing_focus.dart';
import '../services/life_stage_store.dart';
import '../models/week_content.dart' show WeekContent;
import '../services/pregnancy_controller.dart';
import 'weekly_card_stack_screen.dart';
import 'preg_daily_insights.dart';
import '../data/preg_daily_tips.dart' show pregDailyTipFor;
import 'symptoms/door/symptoms_widgets.dart' show symptomLineMark;
import '../data/symptoms/symptom_library.dart' show symptomById;
import 'v2/preg_size_sheet.dart';
import '../data/preg_size_sets.dart';
import '../services/preg_size_set_store.dart';
// import 'v2/pv_day_strip.dart'; // the strip is inside V3PregHero now
import 'v2/v3_preg_hero.dart';
import 'preg_week_screen.dart';
// import 'v2/v3_hero_field.dart'; // kept for revert — PregField since 2026-09-22
import 'v2/pv_insight_rail.dart';
import '../services/symptom_store.dart';
import '../services/nutrition_day_store.dart';
// import 'tools/symptom_companion_screen.dart' show SymptomCompanionScreen, openSymptomDetail; // kept for revert — the companion the log card used to open
import 'can_i/can_i_answer.dart' show openCanIAnswer;
// import '../data/symptom_data.dart' show kSymptoms; // kept for revert — the old 12, which the tap used to search
import 'profile/pv_you_screen.dart';
import 'saved_screen.dart';
// import 'search/pv_search_screen.dart'; // the home bar, kept for revert
// import '../widgets/pv_search_bar.dart';
import '../services/scans_store.dart';
// openAskVeda dropped from the show list with the Ask door. The FAB still calls
// it; this screen no longer needs to, because Ask is on every screen already.
// import '../widgets/global_ask_fab.dart' show kAskFabReserve; // the sheet owns the clearance (2026-09-22)
import '../referral/referral_store.dart';
import 'referral/invite_friends_screen.dart';
import 'today_home_screen.dart';
import 'v2/v2_block_art.dart';
import 'v2/v2_block_grid.dart';
import 'v2/v2_palette.dart';
import 'v2/v2_sections.dart';
import '../data/garbh_data.dart';
import '../services/garbh_store.dart';
// GarbhScreen dropped from the show list 2026-09-23: "About" opens the door.
import 'garbh_screen.dart' show ShravanScreen, SamvadScreen, KriyaScreen, gameForPuzzle;
import 'garbh_buddhi_screen.dart';
// journal_entry.dart no longer needed here since Add a memory opens the compose screen (2026-09-23).
// import '../models/journal_entry.dart';
import '../services/medicine_store.dart';
import '../services/reminder_store.dart';
import '../widgets/journal/journal_create.dart';
import 'journal_screen.dart';
import 'read_next_screen.dart' show ReadItemScreen;
import 'watch_learn_screen.dart';
import 'reminders_screen.dart' show showMedReminderEditor;
import 'tools/medicine_tracker_screen.dart';
import 'brackets/bracket_screen.dart';
import '../data/doors/pv_door_data.dart';
import 'doors/pv_door_screen.dart';
import 'nutrition/door/nutrition_door.dart';
// ⚠️ COMMENTED WITH THE PUSH IT SERVED, KEPT FOR REVERT. `ScansHubScreen` and
// both of its configs still ship and still have their tests; see the note at
// `_openBracket`. Restoring the old landing is uncommenting this line and the
// five below it.
// import 'brackets/scans_hub_screen.dart';
import '../services/bracket_resolver.dart';
import '../services/family_profile.dart' show FamilyProfileStore;
import '../services/preg_tile_order.dart';
import '../services/surface_router.dart';
import 'v2/v3_bracket_art.dart';
import 'v2/v3_daily.dart';
import 'v2/v3_daily_art.dart';
import 'v2/v3_daily_tip.dart';
import 'v2/v3_film_screen.dart';
import 'v2/v3_garbh.dart';
import 'v2/v3_sections.dart';
import 'v2/v3_week_film.dart';
import '../data/doors/pv_door_symptoms.dart' show kSymptomsBracketId;
import 'symptoms/door/symptoms_today_body.dart' show openSymptomRead;
import 'journal_compose_screen.dart' show openJournalCompose;
import 'garbh/garbh_today_practice.dart' show GarbhTodayPractice, openGarbhDoor;

class HomeV3Screen extends StatefulWidget {
  const HomeV3Screen({super.key, required this.pregnancy, required this.home});

  final PregnancyController pregnancy;
  final HomeContentController home;

  @override
  State<HomeV3Screen> createState() => _HomeV3ScreenState();
}

class _HomeV3ScreenState extends State<HomeV3Screen>
    with WidgetsBindingObserver {
  PregnancyController get pregnancy => widget.pregnancy;
  HomeContentController get home => widget.home;

  // ---- The day the page is about --------------------------------------------
  //
  // ⚠️ THE TTC HOME'S RULES, TAKEN WHOLE (2026-09-21, the pregnancy home took
  // the TTC fold). One idea of today, held here and threaded down, so the
  // strip, the heading and the cards cannot disagree about which day it is;
  // refreshed on resume and on any rebuild after midnight; and the selection
  // is only dragged forward if she was standing on the old today — advancing
  // a default is correct, advancing a decision is not.
  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _today = _dayOnly(DateTime.now());
  late DateTime _selected = _today;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PregArrivalPrompt.instance.load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _rollOver();
  }

  void _rollOver() {
    final now = _dayOnly(DateTime.now());
    if (now == _today) return;
    setState(() {
      final wasOnToday = _selected == _today;
      _today = now;
      if (wasOnToday) _selected = now;
    });
  }

  /// "Today", "Yesterday", or the date — the insights heading names the day
  /// the cards were computed for. A heading that says Today above cards
  /// computed for last Tuesday is a screen lying about its own contents.
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  String _dayTitle(DateTime day) {
    final diff = day.difference(_today).inDays;
    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    return '${day.day} ${_months[day.month - 1]}';
  }

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
  // ignore: unused_element
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
  ///
  /// ⚠️ THE WEEK AND DAY LEFT THIS LINE ON 2026-09-21: the hero's title says
  /// "Week 14 · Day 3" now, and a subtitle repeating it two lines above was
  /// the "Today three times" the Nutrition walk rejected. The milestone alone
  /// stays. Kept for revert:
  ///   final dayInWeek = ((activeDay - 1) % 7) + 1;
  ///   final base = 'Week $week, day $dayInWeek';
  ///   ... return '$base. Any day now.'; etc.
  // ignore: unused_element
  String _dayLine(int week, int activeDay) {
    // Only the handful of markers a mother actually counts toward.
    if (week >= 40) return 'Any day now.';
    if (week >= 37) return 'Full term from here.';
    if (week >= 28) return 'Third trimester.';
    if (week == 24) return 'A milestone week.';
    if (week >= 20 && week <= 22) return 'The anomaly scan window.';
    if (week >= 14) return 'Second trimester.';
    if (week >= 13) return 'The first trimester is behind you.';
    return 'Early days.';
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
    // Kept for revert (2026-09-30, one ParentVeda: no placeholder images):
    // `productImageUrl` falls back to a random loremflickr photo when a product
    // has no picture of its own, so the shelf showed strangers' stock photos.
    // The shelf now uses the product's own `imageUrl` and a quiet tile without.
    // productImageUrlV3 = productImageUrl;
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
        // The insights rail reads these three: a symptom logged, a scan
        // booked, a need ticked — each must rebuild the rail.
        SymptomStore.instance,
        ScansStore.instance,
        NutritionDayStore.instance,
        // "Not yet" on the arrival card rests it (2026-09-30).
        PregArrivalPrompt.instance,
        // The hero line and the size card name the set she chose.
        PregSizeSetStore.instance,
        // The door tiles lead with what she chose in onboarding, so a change
        // in Profile must reorder them (2026-09-30, preg_tile_order.dart).
        FamilyProfileStore.instance,
      ]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    if (pregnancy.isLoading || home.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ⚠️ A SECOND MIDNIGHT CHECK, and not a redundant one: the lifecycle
    // observer covers a resume; this covers a rebuild for any other reason
    // after midnight without the app having been backgrounded.
    if (_dayOnly(DateTime.now()) != _today) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _rollOver();
      });
    }

    // ⚠️ THE SELECTED DAY, NOT TODAY. The strip picks a date; the date maps
    // to a pregnancy day; everything authored by day follows it — the hero,
    // the insights, the reads. `previewDay` (the debug preview) still wins.
    final activeDay =
        home.previewDay ?? pregnancy.dayForDate(_selected);
    final week = (((activeDay - 1) ~/ 7) + 1).clamp(4, 40);
    final day = home.dayFor(activeDay, week);
    final weekContent = pregnancy.weekData(week);
    final p = V2PaletteStore.instance.current;
    final reads = v2ReadsFor(week, activeDay);
    final video = v2VideoFor(week);
    // The three under "Watch These Videos This Week" — never the film above.
    final shelf = v3ShelfVideosFor(week, excludeId: video?.id);
    final products = v2ProductsFor(week, activeDay);

    // ⚠️ `.now` ON BOTH THE TEST AND THE VALUE, AND THE TEST IS THE SUBTLE
    // HALF. This picked `remember` when its ENGLISH was non-empty and then
    // displayed it — so on a day where `remember` is written in English but
    // not yet in Hindi, a Hindi reader got the branch chosen for her by a
    // language she is not reading, and then got it in English. Checking one
    // language and rendering another is how a fallback stops falling back.
    // Kept for revert (the tip's old source, retired 2026-09-29 below):
    // final remember = day?.grow.remember.now.trim() ?? '';
    // final insight =
    //     remember.isNotEmpty ? remember : (day?.grow.insight.now ?? '');

    final name = pregnancy.motherName.trim();

    // The tip no longer has a section on this page — it arrives as a card in
    // the middle of the screen on open. See v2/v3_daily_tip.dart for why a
    // greeting is not the interstitial §16.3 bans.
    // The day within the week, as the hero says it — the tip said WEEK 4 ·
    // DAY 14 over a hero saying Week 4 · Day 7 (the phone, 2026-09-22).
    // ⚠️ A PREGNANCY TIP FOR HER WEEK, 2026-09-29. The gap analysis (P1,
    // "Make 'Today's tip' a practical pregnancy tip for that week") found the
    // pop-up showing a parenting reflection ("Offer the warmth; let the
    // flower choose its hour."). Seven practical tips per week now come from
    // the week's own data (lib/data/preg_daily_tips.dart). Kept for revert:
    //   _maybeShowTip(insight, week, ((activeDay - 1) % 7) + 1, p);
    final dayInWeek = ((activeDay - 1) % 7) + 1;
    _maybeShowTip(pregDailyTipFor(week, dayInWeek), week, dayInWeek, p);

    // The field's hue: the trimester's — the arrival green of the first, the
    // warm second, the deep third. One colour decision, shared with the sheet.
    // ⚠️ THE ART'S OWN HUE, EVERY TRIMESTER. A green field under the pink
    // figure was "two different things put together" (the user,
    // 2026-09-22). The field is the peach the illustrator painted, so the
    // figure's halo and the page are one surface. The trimester still picks
    // the field's composition. Kept for revert:
    //   final fieldHue = switch (trimester) { 1 => 104.0, 2 => 24.0, _ => 268.0 };
    final trimester = activeDay <= 91 ? 1 : (activeDay <= 189 ? 2 : 3);
    // const fieldHue = kPregFieldHue;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // The clock, battery and signal sit on the light field now (they sat
      // on the photograph until 2026-09-22), so they are dark again.
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
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
        child: Stack(children: [
          // The field is the PAGE's surface — it does not scroll; the sheet
          // slides over it (TTC's shape, 2026-09-22).
          // `PregField`, the art's own colours (2026-09-22, second pass:
          // `V3HeroField` at a warm hue came out khaki). Kept for revert:
          //   V3HeroField(accent: v2BlockTint(fieldHue, p), ground: p.ground,
          //       variant: trimester, chroma: v3FieldChroma(fieldHue)),
          Positioned.fill(child: PregField(ground: p.ground, variant: trimester)),
        // NO HORIZONTAL PADDING ON THE LIST. The hero has to reach both
        // edges, and a list that pads everything cannot let one child out.
        // Every other section wraps itself in _pad() instead.
        // The sheet owns the bottom clearance now; the list pads nothing.
        // Kept for revert: padding: const EdgeInsets.only(bottom: kAskFabReserve),
        ListView(
          padding: EdgeInsets.zero,
          children: [
            // ---- HEADER AND HERO AS ONE BLOCK -------------------------------
            // ---- THE FOLD, IN THE TTC HOME'S STRUCTURE — 2026-09-22 ----------
            //
            // [avatar · date · saved] → the day strip → the baby in a disc →
            // "Week n · Day d" → the size line → "This week" — on the field,
            // with the rest of the page on a white sheet over it. See
            // v3_preg_hero.dart for the user's words. The full-bleed
            // photograph (`V3Hero`) is commented out below, kept for revert.
            if (day != null)
              V3PregHero(
                p: p,
                week: week,
                day: activeDay,
                selected: _selected,
                today: _today,
                // Back to day one of the pregnancy, six months at most; six
                // ahead, dimmed, so today sits in the centre as on TTC.
                daysBack: (pregnancy.currentDay - 1).clamp(0, 180),
                onSelectDay: (d) => setState(() => _selected = d),
                // A dot under a day she logged a symptom on.
                markFor: (date, _) {
                  final key = SymptomStore.dateKey(date);
                  final any = SymptomStore.instance.logs.any((l) => l.dateKey == key);
                  if (!any) return null;
                  return Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(color: p.ink2, shape: BoxShape.circle),
                    ),
                  );
                },
                initial: name.isEmpty ? '' : name.trim().characters.last,
                // The figure and Details open the week page (Flo's Details).
                // The size line and the "This week" pill left the hero on
                // 2026-09-22 — the insight card says the size, the page says
                // the rest. Kept for revert:
                //   sizeLine: _sizeLine(week, weekContent),
                //   onSize / onThisWeek: () => _openWeekSheet(context, week, weekContent, p),
                onDetails: () => openPregWeek(context, pregnancy, week),
                // "20 weeks to go" with an (i), and past the due date the
                // count keeps going (2026-09-30, gap analysis). Counted for the
                // SELECTED day, like everything else on the fold.
                timeLeft: pregTimeLeft(_daysToDue(_selected)),
                pastDueCount: pregPastDueCount(_daysToDue(_selected)),
                onHowCounted: () => showPregHowWeeksCounted(context, pregnancy),
                onPastDue: () => openPvDoorRead(context, kPregPastDueReadId, pregnancy),
                // "Has your baby arrived?" from week 37, today's week.
                footer: PregArrivalPrompt.instance.showsFor(pregnancy.currentWeek)
                    ? PregArrivalCard(p: p)
                    : null,
                onAvatar: () => openPvYou(context, stage: LifeStage.pregnancy),
                onSaved: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    settings: const RouteSettings(name: 'saved'),
                    builder: (_) => const SavedScreen())),
              ),
            // ---- THE SHEET: everything under the fold ------------------------
            V3PregSheet(p: p, children: [
            // ---- KEPT FOR REVERT: the full-bleed photograph hero ---------------

            // if (day != null)
            //   V3Hero(
            //     // ⚠️ THE GREETING NOW KNOWS THE TIME, AND THE SUBTITLE KNOWS
            //     // THE DAY.
            //     //
            //     // It said "Today, mum" at every hour and "Symptoms, medicines
            //     // and how you are doing" in every one of the 280 days. Both were
            //     // true always, which is another way of saying neither was about
            //     // now. The screen already held the hour and the day and was
            //     // using neither.
            //     //
            //     // See `_greeting()` and `_dayLine()` below.
            //     name: _greeting(name),
            //     subtitle: _dayLine(week, activeDay),
            //     week: week,
            //     day: activeDay,
            //     // ⚠️ DISPLAY, so `.now`. This lands in a `Text(learning)` in
            //       // v3_sections.dart — rendered prose, not an identity.
            //       learning: day.babyLearning.now,
            //     p: p,
            //     height: 372,
            //     // ---- the day strip, on the photograph -----------------------
            //     //
            //     // The window runs back to day one of the pregnancy and no
            //     // further (a date before it is not a day of this pregnancy),
            //     // six months at most, and SIX DAYS AHEAD, dimmed, exactly as
            //     // TTC — the user (2026-09-21): "the date today is in the
            //     // centre", and a strip that ends at today puts today at the
            //     // edge. A day ahead is selectable; the insights hide the log
            //     // and the plate on it, and the week it shows is at most six
            //     // days early.
            //     strip: PvDayStrip(
            //       p: p,
            //       selected: _selected,
            //       today: _today,
            //       accent: Colors.white,
            //       onPhoto: true,
            //       keyPrefix: 'preg_day_',
            //       daysBack: (pregnancy.currentDay - 1).clamp(0, 180),
            //       daysForward: 6,
            //       // A dot under a day she logged a symptom on — "when have I
            //       // been logging?" at a glance; the detail is the card.
            //       markFor: (date, _) {
            //         final key = SymptomStore.dateKey(date);
            //         final any = SymptomStore.instance.logs
            //             .any((l) => l.dateKey == key);
            //         if (!any) return null;
            //         return Center(
            //           child: Container(
            //             width: 5,
            //             height: 5,
            //             decoration: BoxDecoration(
            //                 color: Colors.white.withValues(alpha: 0.85),
            //                 shape: BoxShape.circle),
            //           ),
            //         );
            //       },
            //       onSelect: (d) => setState(() => _selected = d),
            //     ),
            //     sizeLine: _sizeLine(week, weekContent),
            //     // ⚠️ THE HERO NO LONGER OPENS THE WEEK STACK — 2026-09-21,
            //     // the user: "a pill that says week four, day 13, which leads
            //     // to the weekly card stack that we don't need at all. Even
            //     // clicking on the image does that … cut the wire. Don't
            //     // delete the section, just don't wire it like that."
            //     //
            //     // So the photograph, the size line and the "This week" pill
            //     // all open the week SHEET — the baby this week, its size,
            //     // what it is doing — and the stack keeps its own doors
            //     // elsewhere. `_openWeek` stays below for revert.
            //     onSize: weekContent == null ? null : () => _openWeekSheet(context, week, weekContent, p),
            //     onThisWeek: weekContent == null ? null : () => _openWeekSheet(context, week, weekContent, p),
            //     onTap: weekContent == null ? null : () => _openWeekSheet(context, week, weekContent, p),
            //     // Kept for revert — the stack wiring the user cut:
            //     // onTap: () {
            //     //   pregnancy.selectWeek(week);
            //     //   Navigator.of(context).push(MaterialPageRoute(
            //     //     settings: const RouteSettings(name: 'weekly_card_stack'),
            //     //     builder: (_) => WeeklyCardStackScreen(controller: pregnancy),
            //     //   ));
            //     // },
            //     // onSpine: () {  // (the chip; `_openWeek` does the same)
            //     //   pregnancy.selectWeek(week);
            //     //   Navigator.of(context).push(MaterialPageRoute(
            //     //     settings: const RouteSettings(name: 'weekly_card_stack'),
            //     //     builder: (_) => WeeklyCardStackScreen(controller: pregnancy),
            //     //   ));
            //     // },
            //     // Was `_open(context, 'journal')` — classic fallback, then the
            //     // journal itself. Both kept for revert. Since 2026-09-19 the
            //     // avatar is the one door to You on every stage; the journal
            //     // sits under Your things there.
            //     // onAvatar: () => Navigator.of(context).push(MaterialPageRoute<void>(
            //     //     settings: const RouteSettings(name: 'journal'),
            //     //     builder: (_) => JournalScreen(controller: pregnancy))),
            //     onAvatar: () => openPvYou(context, stage: LifeStage.pregnancy),
            //     // ⚠️ WAS `_open(context, 'saved')`, which switched the home to
            //     // CLASSIC and stopped — the V3 scaffolding from when classic
            //     // was still the destination. V3 is final (2026-09-16): every
            //     // tap opens the thing itself. Kept for revert:
            //     // onSaved: () => _open(context, 'saved'),
            //     onSaved: () => Navigator.of(context).push(MaterialPageRoute<void>(
            //         settings: const RouteSettings(name: 'saved'),
            //         builder: (_) => const SavedScreen())),
            //   ),
            // ---- MY DAILY INSIGHTS · <day> ----------------------------------
            //
            // The TTC rail, under the hero (2026-09-21). The heading names
            // the day the cards were computed for; the rail pads itself and
            // runs edge to edge, so it sits OUTSIDE the padded column — the
            // double-gutter "wall" Nutrition shipped is the thing to avoid.
            // See preg_daily_insights.dart for which cards a day earns.
            if (day != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
                child: V3SectionHead(
                    eyebrow: 'My daily insights',
                    title: _dayTitle(_selected),
                    p: p),
              ),
              PvInsightRail(tiles: [
                for (final c in pregInsightsFor(
                  date: _selected,
                  today: _today,
                  day: activeDay,
                  week: week,
                  homeDay: day,
                  weekContent: weekContent,
                  reads: reads,
                ))
                  PvInsightTile(
                    key: ValueKey('preg_insight_${c.id}'),
                    eyebrow: c.eyebrow,
                    value: c.value,
                    caption: c.caption,
                    hue: c.hue,
                    art: c.art,
                    // A logged symptom wears its own drawn mark — two cards
                    // both showing the generic one read as a duplicate.
                    artWidget: switch (c.symptomId) {
                      final id? when symptomById(id) != null =>
                        symptomLineMark(symptomById(id)!, size: 22, ink: p.ink2),
                      _ => null,
                    },
                    p: p,
                    onTap: () => _openInsight(context, c, week, weekContent),
                  ),
              ]),
            ],
            // ⚠️ THE PAGE IS THREE INSET COLUMNS WITH TWO FULL-BLEED THINGS
            // BETWEEN THEM, not one column any more.
            //
            // It used to be one Padding(Column) after the hero, and the hero
            // was the only child allowed to touch the edges. The design adds
            // two more: the week's film and the Garbh Sanskar band. A list
            // that pads everything cannot let one child out, so the column is
            // split where each of them sits and the gutter is re-opened after.
            // Same 18dp gutter as before — the V3 family's, not the design's
            // 24 (see STILL-OPEN §57.2).
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            const SizedBox(height: 26),

            // ---- The only time-sensitive row — FOLDED INTO THE RAIL ---------
            // 2026-09-21: a scan in the next fortnight is the "Coming up"
            // card on My daily insights (preg_daily_insights.dart). A row of
            // its own between the hero and the doors was the interruption
            // the kick-count card was removed for. Kept for revert:
            // V2ComingUp(p: p, onTap: () => _open(context, 'tests_scans')),
            // if (ScansStore.instance.appointments.isNotEmpty)
            //   const SizedBox(height: 12),

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
            // ---- SEARCH — NOT HERE. 2026-09-18: a bar sat between this
            // heading and the grid for an hour; the user: "not below Start
            // anywhere, that wasn't my intent." Search lives in each door's
            // hero (`PvDoorScreen._Hero`), scoped to the door with
            // "Everywhere" one tap away. Kept for revert:
            //   PvSearchBar(
            //       hint: 'Search scans, symptoms, foods, anything',
            //       p: p,
            //       onTap: () => openPvSearch(context, pregnancy)),
            //   const SizedBox(height: 14),
            V2BlockGrid(
                palette: p, blocks: _brackets(context, p), columns: 4),

            // ---- THIS WEEK EXPLAINED — the heading ---------------------------
            //
            // ⚠️ THE WEEK'S FILM MOVED UP HERE FROM BELOW THE JOURNAL, and it
            // is the design's central call: the film is her week's
            // explanation, so it follows the doors directly, at the page's
            // second-largest type, with no eyebrow. "Recommended Watch · Six
            // minutes, this week" is commented out below, kept for revert.
            if (video != null) ...[
              const SizedBox(height: 36),
              // Rewritten 2026-09-29 (docs/PREG-VOICE.md). Was 'This Week Explained'.
              Text('Your week, explained',
                  style: pvFraunces(
                      fontSize: 24,
                      letterSpacing: -0.6,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                      color: p.ink1)),
              const SizedBox(height: 14),
            ],
                ],
              ),
            ),

            // ---- THIS WEEK EXPLAINED — the film, edge to edge ----------------
            //
            // Plays IN PLACE. Tapping the poster swaps in the player where
            // the poster was; nothing navigates. See v3_week_film.dart for
            // what that costs in a ListView and why it is still the right
            // shape for this section.
            if (video != null)
              V3WeekFilm(
                  video: video,
                  week: week,
                  p: p,
                  // While there is no file: Watch & Learn, where every film
                  // she can watch today lives. Was `_open(context,
                  // 'todays_video')` — the classic fallback; kept for revert.
                  onUnavailable: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      settings: const RouteSettings(name: 'watch'),
                      builder: (_) => WatchLearnScreen(controller: pregnancy)))),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            if (video != null) ...[
              const SizedBox(height: 14),
              Text(video.title.en,
                  style: pvFraunces(
                      fontSize: 17,
                      letterSpacing: -0.43,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: p.ink1)),
              if (video.reason.en.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('Why this matters now: ${video.reason.en}',
                    style: pvJakarta(fontSize: 13, height: 1.5, color: p.ink2)),
              ],
            ],
            // Room for the Garbh band to arrive as its own moment. When
            // there is no film the doors sit directly above it.
            SizedBox(height: video != null ? 40 : 28),
                ],
              ),
            ),

            // ⚠️ READS AND WATCH HAVE SWAPPED PLACES.
            //
            // Reads used to sit here, directly under the doors, with Watch far
            // below. Recommended Watch now comes first and Recommended Reads
            // follows it, because a video is the lower-effort thing to start and
            // the one more likely to be opened on a tired evening. The reads
            // block moved down rather than being duplicated — see below.

            // ---- GARBH SANSKAR — a band, and a card over it -----------------
            //
            // The 2026-09-16 shape: `V3GarbhBlock`, full-bleed. The band
            // reaches both edges and the card insets itself, so this sits
            // OUTSIDE the padded column like the film above it. The previous
            // `V3GarbhSection` — one framed card — is kept in v3_garbh.dart
            // and its call is the commented `return` below.
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
                      today: shravanForDay(cd).title.now,
                      icon: Icons.graphic_eq_rounded,
                      accent: const Color(0xFF9A7526),
                      done: store.isDone('shravan'),
                      onToggleDone: () => _toggleGarbh(store, 'shravan'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ShravanScreen(
                              controller: pregnancy, daily: true))),
                    ),
                    // ⚠️ NAMED 'Samvad', NOT 'Samvad & Vichara'. Vichara was
                    // not renamed away, it was REPLACED - its Sacred Insights
                    // and Uplifting Vibrations shelves duplicated Samvad and
                    // Shravan, so as a pillar it was two copies wearing a
                    // third name. The daily screen has said 'Samvad' since;
                    // this row kept the old compound name and was the only
                    // place in the app still implying Vichara exists.
                    GarbhPillarRow(
                      name: 'Samvad',
                      image:
                          'https://images.unsplash.com/photo-1541956799312-3f9df99e0006?w=200&h=200&fit=crop',
                      tag: 'Talking to your baby',
                      // ⚠️ `.title.now`, AND BOTH HALVES OF THAT MATTER.
                      //
                      // `.title` because this row is a LABEL: two lines of Fraunces with
                      // an ellipsis. It used to be `.text`, which for trimester two is a
                      // whole story to read aloud, so the label read "Round and round
                      // the garden hums a gentle bee. Buzz, buzz,…" — the practice
                      // named by a fragment of itself. Nothing failed; the row rendered
                      // perfectly, with the wrong field in it.
                      //
                      // `.now` because this is DISPLAY, not identity. `.en` on a rendered
                      // string is the mistake CLAUDE.md counts — it hands a mother who
                      // chose Hindi an English line on a screen that is otherwise hers.
                      today: promptForDay(cd, tri).title.now,
                      icon: Icons.record_voice_over_rounded,
                      accent: const Color(0xFF9C5F51),
                      done: store.isDone('samvad'),
                      onToggleDone: () => _toggleGarbh(store, 'samvad'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => SamvadScreen(
                              controller: pregnancy, daily: true))),
                    ),
                    // ⚠️ THE PILLAR THAT WAS MISSING, AND WHY NOTHING CAUGHT
                    // IT. Buddhi was built properly - its own screen, its own
                    // place on the wheel, its own row on the daily screen with
                    // a comment explaining why it exists. This landing block
                    // was simply never updated to match. Nothing failed,
                    // nothing was internally inconsistent, and no test could
                    // see it: three correct pillars, doing three correct
                    // things, in a list that happened to be short.
                    //
                    // ⚠️ IT IS THE ONE PILLAR THAT IS NOT FOR THE BABY, which
                    // is why its tag says so out loud rather than describing a
                    // practice. See garbh_buddhi_screen.dart.
                    GarbhPillarRow(
                      name: 'Buddhi',
                      image:
                          'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=200&h=200&fit=crop',
                      tag: 'Just for you',
                      today: buddhiTodayLine(cd).now,
                      icon: Icons.psychology_alt_outlined,
                      accent: const Color(0xFF2F2C30),
                      done: store.isDone('buddhi'),
                      onToggleDone: () => _toggleGarbh(store, 'buddhi'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => GarbhBuddhiScreen(
                                controller: pregnancy,
                                daily: true,
                                onOpenPuzzle: (ctx, puzzle) =>
                                    Navigator.of(ctx).push(MaterialPageRoute(
                                        builder: (_) => gameForPuzzle(
                                            puzzle, pregnancy,
                                            markComplete: true))),
                              ))),
                    ),
                    // ⚠️ ACCENT AND TAG NOW MATCH THE DAILY SCREEN. This row
                    // carried #3F6E62 and 'Breath & grounding' against the
                    // daily screen's #8A6D3B and 'Breath and grounding' - the
                    // same pillar wearing two colours in one app, which is the
                    // kind of drift that only shows up when someone puts the
                    // two screens side by side.
                    GarbhPillarRow(
                      name: 'Kriya',
                      image:
                          'https://images.unsplash.com/photo-1485808269728-77bb07c059a8?w=200&h=200&fit=crop',
                      tag: 'Breath and grounding',
                      today: kriyaForDay(cd).title.now,
                      icon: Icons.spa_rounded,
                      accent: const Color(0xFF8A6D3B),
                      done: store.isDone('kriya'),
                      onToggleDone: () => _toggleGarbh(store, 'kriya'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              KriyaScreen(controller: pregnancy, daily: true))),
                    ),
                  ];
                  // The one-card shape, kept for revert:
                  // return V3GarbhSection(
                  //   day: day,
                  //   p: p,
                  //   rows: rows,
                  //   onAbout: () => _open(context, 'garbh_daily'),
                  // );
                  return V3GarbhBlock(
                    day: day,
                    p: p,
                    rows: rows, // the previous drawing, kept for revert
                    // ⚠️ THE ONE DRAWING OF TODAY'S PRACTICE (2026-09-23) —
                    // the same component the door's Today tab renders, so
                    // the home and the door cannot drift again. Each pillar
                    // opens the DOOR at its tab (the brief); the rows above
                    // opened the old standalone screens.
                    body: GarbhTodayPractice(pregnancy: pregnancy, day: cd, week: week),
                    // ⚠️ THE DOOR, NOT THE OLD LIBRARY. This used to say "Now
                    // the Garbh Sanskar door itself" and then push
                    // `GarbhScreen` — the pre-brief library, with the streak
                    // card the brief forbids. Kept for revert:
                    //   onAbout: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    //       settings: const RouteSettings(name: 'garbh'),
                    //       builder: (_) => GarbhScreen(controller: pregnancy))),
                    onAbout: () => openGarbhDoor(context, pregnancy),
                  );
                },
              ),
            ],

            // The gutter re-opens here and runs to the foot of the page.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            const SizedBox(height: 40),

            // ---- TODAY'S MEDICINES ------------------------------------------
            //
            // Restored from Classic. It sits directly under Garbh Sanskar
            // because the two belong to the same half of the screen: everything
            // above is content she takes in, and these are the things she DOES.
            // Grouping them means the page has one "your turn" region rather
            // than actions scattered between articles.
            V3SectionHead(
                // Rewritten 2026-09-29 (docs/PREG-VOICE.md). Was 'Medicine
                // Reminder' over "Don't miss today's dose".
                eyebrow: 'Medicine reminder',
                title: "Today's medicines",
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
            // ⚠️ TWO DOORS NOW, NOT FOUR — AND THE REVIEW ASKED FOR THIS
            // EXPLICITLY: "Note for Baby should be removed, add a photo should
            // be removed. Record Voice should be called Add a voice note."
            //
            // The instruction was applied to the compose screen and NOT to this
            // section, which is the surface the review named ("My Journal
            // Section on landing page"). It sat unchanged for the rest of the
            // pass, and it was not in the backlog either — the four tiles read
            // as finished work from every angle except comparing them to the
            // sentence that asked for them.
            //
            // ⚠️ WHY TWO IS BETTER THAN FOUR HERE, beyond being what was asked:
            // "Add a photo" was never a different KIND of entry — the compose
            // screen takes photos with or without words, so it was one door
            // leading where the other already went. Four tiles implied four
            // outcomes and delivered two.
            //
            // And the remaining pair is a real distinction: writing and
            // speaking are different acts, not different formats. A woman who
            // does not want to type is not looking for a smaller version of the
            // writing screen.
            // ⚠️ ONLY THE TITLE LINE CHANGED (design option 1g: "the card
            // under it is untouched"). Was 'Something for your baby, when it
            // grows up'.
            V3SectionHead(
                eyebrow: 'My journal',
                // Rewritten 2026-09-29. Was 'Create a memory for your baby to
                // show when it grows up'.
                title: 'Keep a memory for your baby to see one day',
                p: p),
            const SizedBox(height: 12),
            V3JournalSection(
              p: p,
              // Four hues off the controlled-pastel wheel, same rule as the six
              // doors: hue varies, saturation and lightness do not, so four
              // different colours still read as one system.
              actions: [
                V3QuickAction(
                    // ⚠️ A NEUTRAL ICON, PER THE REVIEW: "its icon should
                    // reflect that either user can write or upload pics or
                    // something neutral". A pencil promises typing, and this
                    // screen takes a photograph with no words at all.
                    icon: Icons.auto_stories_outlined,
                    mark: V3DailyMark.memory,
                    hue: 42,
                    label: 'Add a\nmemory',
                    // ⚠️ ONE WAY TO WRITE A MEMORY (2026-09-23). This opened
                    // the small text-only sheet; the journal's own "Add a
                    // memory" opened the full compose screen — photos, place,
                    // words. Same action, two screens, and the one on the home
                    // could not take the photo the tile's icon promised. Was:
                    //   onTap: () => openJournalText(
                    //       context, pregnancy, JournalEntryType.memory)),
                    onTap: () => openJournalCompose(context, pregnancy)),
                V3QuickAction(
                    icon: Icons.mic_none_rounded,
                    mark: V3DailyMark.voice,
                    hue: 268,
                    label: 'Add a\nvoice note',
                    onTap: () => openJournalRecordVoice(context, pregnancy)),

                // ⚠️ REMOVED, KEPT FOR REVERT — repo rule, and both are one
                // uncomment away.
                //
                // "Note for baby" is gone from HER landing page only. The
                // father's app still creates the type from his own screens and
                // his own store, and the review did not ask to touch that.
                // Existing entries are migrated — see `JournalStore`.
                //
                // V3QuickAction(
                //     icon: Icons.favorite_border_rounded,
                //     mark: V3DailyMark.note,
                //     hue: 344,
                //     label: 'Note for\nbaby',
                //     onTap: () => openJournalText(
                //         context, pregnancy, JournalEntryType.noteForBaby)),
                //
                // "Add a photo" led to the same compose screen the first tile
                // opens, which now takes photo-only entries.
                //
                // V3QuickAction(
                //     icon: Icons.photo_camera_outlined,
                //     mark: V3DailyMark.photo,
                //     hue: 206,
                //     label: 'Add a\nphoto',
                //     onTap: () => openJournalAddPhoto(context, pregnancy)),
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

            // ---- RECOMMENDED WATCH — MOVED UP, KEPT FOR REVERT ---------------
            //
            // The week's film is now "This Week Explained", directly under
            // the doors. This card showed the SAME video here; showing it twice
            // on one page would be the same promotion twice in one session.
            //
            // if (video != null) ...[
            //   V3SectionHead(
            //       eyebrow: 'Recommended Watch',
            //       title: 'Six minutes, this week',
            //       p: p),
            //   const SizedBox(height: 12),
            //   V2VideoCard(
            //       video: video,
            //       p: p,
            //       onTap: () => _open(context, 'todays_video')),
            //   const SizedBox(height: 28),
            // ],

            // ---- WATCH THESE VIDEOS THIS WEEK — the shelf -------------------
            //
            // Three MORE films, as rows with a small thumb (design option 1d).
            // Not a rail: the products rail sits two sections down and two
            // rails on one scroll read as one shop. Not two-up: a third card
            // orphans. A row opens `V3FilmScreen`; the film above plays in
            // place, these open a page, and that is the difference between
            // her week's explanation and three more if she wants them.
            if (shelf.isNotEmpty) ...[
              V3SectionHead(
                  eyebrow: 'Recommended videos',
                  // Was 'Watch These Videos This Week' (2026-09-29).
                  title: 'Videos for this week',
                  p: p),
              const SizedBox(height: 2),
              for (final v in shelf) ...[
                V3VideoRow(
                    video: v,
                    p: p,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                        settings: RouteSettings(name: 'pregnancy/film/${v.id}'),
                        builder: (_) => V3FilmScreen(
                            video: v, week: week, pregnancy: pregnancy)))),
                if (v != shelf.last)
                  Divider(height: 1, thickness: 1, color: p.line),
              ],
              const SizedBox(height: 28),
            ],

            // ---- RECOMMENDED READS — now below Watch ------------------------
            //
            // "Short enough for today" was about length. "Research-backed
            // articles" is about why she should trust it, which is the thing
            // that actually makes someone open a pregnancy article.
            if (reads.isNotEmpty) ...[
              V3SectionHead(
                  // ⚠️ THE GAP ANALYSIS, P1 ("Say 'Research-backed' only when it
                  // is true"): no pregnancy read has had a real review yet, so
                  // the heading names the week instead. Was 'Recommended
                  // Reads' over 'Research-backed articles'.
                  eyebrow: 'Recommended reads',
                  title: 'Reads for week $week',
                  p: p),
              const SizedBox(height: 8),
              for (final r in reads.take(3))
                V3ReadRow(
                    item: r,
                    p: p,
                    // ⚠️ WAS `_open(context, 'daily_reads')`, which switched
                    // the home to CLASSIC and never opened the article — the
                    // bug the user hit on "You are halfway, what changes now?".
                    // Kept for revert. The row opens the piece it names:
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                        settings: RouteSettings(name: 'read/${r.id}'),
                        builder: (_) => ReadItemScreen(item: r, controller: pregnancy)))),
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
                  // Was 'Recommended Products' over 'Crafted for Week $week of
                  // Pregnancy' (2026-09-29, docs/PREG-VOICE.md).
                  eyebrow: 'Recommended products',
                  title: 'Picked for week $week',
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
            ]),
            ],
          ),
        ]),
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
        // ⚠️ RANKED, NEVER HIDDEN (2026-09-30, gap analysis "Order the door tiles
        // by her week and her answers"). Her onboarding choices lead, then her
        // trimester's, then the table's own order; every door is still here.
        // It takes the week she is IN, not the day the strip is showing, so the
        // tiles do not shuffle while she browses. Kept for revert:
        //   for (final b in bracketsFor(LifeStage.pregnancy))
        for (final b in orderPregnancyTiles(
          bracketsFor(LifeStage.pregnancy),
          week: pregnancy.currentWeek,
          priorities: FamilyProfileStore.instance.pregPriorities,
        ))
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
  /// The Mind & mood door on a given tab. Two home actions and the bracket
  /// tile all land here; only the tab differs.
  void _openMindDoor(BuildContext context, String tab) {
    final door = pvDoorPageFor('pregnancy_mental_health');
    final b = bracketById('pregnancy_mental_health');
    if (door == null || b == null) return; // wiring test makes this unreachable
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'mind_mood'),
      builder: (_) => PvDoorScreen(
          page: door, bracket: b, pregnancy: pregnancy, initialGroup: tab),
    ));
  }

  void _openBracket(BuildContext context, String bracketId) {
    final b = bracketById(bracketId);
    if (b == null) return; // wiring test makes this unreachable

    // ⚠️ A BRACKET WITH A DOOR OPENS ITS DOOR, AND THIS IS CHECKED FIRST.
    //
    // A door is the five-sub-tab page — `PvDoorScreen` over a `PvDoorPage` —
    // and it replaces the LANDING an area used to have, not the screens under
    // it. Scans & tests is the first; the other seven briefs land here as data
    // and this branch does not change again.
    //
    // It is checked before the hub registry on purpose: an area that has both
    // has a door because somebody decided the hub was the wrong shape for it,
    // and falling through to the hub would silently keep the shape that was
    // replaced.
    // Nutrition opened as its own day screen for a few hours on 2026-09-20;
    // the user asked for one door language, so the day is now the first
    // tab's tool on the ordinary door below. `kNutritionDoorAsDay` is false
    // and the standalone screen stays for revert.
    if (bracketId == kNutritionBracketId && kNutritionDoorAsDay) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: kNutritionDoorRoute),
        builder: (_) => NutritionDoorScreen(pregnancy: pregnancy),
      ));
      return;
    }

    if (pvDoorPageFor(bracketId) case final door?) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        // ⚠️ THE ROUTE NAME IS UNCHANGED FROM THE HUB'S. `global_ask_fab.dart`
        // reads it to decide which Ask Veda opens, so renaming it while
        // replacing the screen would have moved the FAB's context without
        // anything failing.
        settings: const RouteSettings(name: 'bracket/scans'),
        builder: (_) => PvDoorScreen(
            page: door, bracket: b, pregnancy: pregnancy),
      ));
      return;
    }

    // ⚠️ THE OLD SCANS HUB, COMMENTED OUT AND STILL SHIPPING — 2026-09-10.
    //
    // `ScansHubScreen` was Scans & tests' landing: a hero over a "What do you
    // need?" list, behind a V1 | V2 pill. V1 was six doors from the
    // reconciliation Excel's six journey steps; V2 was three. Both are replaced
    // by the door above, and asked to be commented rather than deleted.
    //
    // Nothing about them was removed. `scans_hub_screen.dart`,
    // `scans_hub.dart`, `scans_hub_v2.dart` and `scans_hub_version.dart` are
    // all still on disk with their tests, so restoring the toggle is
    // uncommenting these five lines.
    //
    // ⚠️ AND EVERY DESTINATION THEY OPENED IS STILL REACHABLE. The timeline,
    // the locker, the decoder, the nine scan pages and the urgent screen are
    // all on the door, most of them one tap earlier than before. What went is
    // the menu in front of them.
    //
    // if (bracketId == kScansBracketId) {
    //   Navigator.of(context).push(MaterialPageRoute<void>(
    //     settings: const RouteSettings(name: 'bracket/scans'),
    //     builder: (_) => ScansHubScreen(bracket: b, pregnancy: pregnancy),
    //   ));
    //   return;
    // }

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
      case kPgActNutritionMain:
        push(nutritionHomeScreen(pregnancy: pregnancy), 'nutrition');
        return;
      // ⚠️ THE TWO NUTRITION DOORS USED TO SHARE THIS CASE, AND THAT MADE THE
      // SECOND ONE A LIE. "What should I eat?" and "Something has been
      // flagged" are different questions from different people — one is
      // planning dinner, the other was handed a number at an appointment —
      // and both landed on the same generic nutrition home. Two doors with
      // one destination teach her the labels do not mean anything.
      //
      // ⚠️ THE JOURNEY IS NOT THE ANSWER EITHER, WHICH IS WHY THIS IS NOT
      // SIMPLY A DELETED CASE. `kPgNutritionFlag` is registered and would
      // take over the moment this case is removed — but two of its three
      // steps are `owed: true`, so she would arrive at promises with nothing
      // behind them. Falling through would look like a fix and ship a worse
      // screen.
      //
      // So it opens the condition tab of "Food for my stage", where
      // `kConditionGuides` already covers gestational diabetes, anaemia and
      // thyroid — the flags this door names in its own blurb.
      case kPgActNutritionFlag:
        push(NutritionStageScreen(initialTab: 1, pregnancy: pregnancy),
            'nutrition_condition');
        return;
      // ⚠️ TWO ACTIONS, TWO TABS OF ONE DOOR — THE BUG THE MIND & MOOD BRIEF
      // NAMES. "Check how I am feeling" and "Help me feel better" used to open
      // the same landing. They now open the Mind & mood door on Track and on
      // Feel respectively; the tab is the whole difference between them, and
      // it is the difference she tapped for.
      //
      // ⚠️ THE ROUTE NAME IS THE OLD ONE. `global_ask_fab.dart` reads it.
      case kPgActMoodCheck:
        _openMindDoor(context, kMindTabTrack);
        return;
      case kPgActFeelBetter:
        _openMindDoor(context, kMindTabFeel);
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
        // ⚠️ THE ROUTE NAME IS LOAD-BEARING (CLAUDE.md): `global_ask_fab`
        // and others detect which stage is on screen from it, so a name
        // that does not interpolate is not a cosmetic bug.
        settings: RouteSettings(name: 'journey/$action'),
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

      // ⚠️ THE CONDITION LIBRARY, AND THIS LINE NEVER RAN UNTIL 2026-08-21.
      //
      // It used to send her to the tests/scans reference — correct when written,
      // superseded when `ConditionsHomeScreen` was built — and it was moot
      // either way, because `journeyFor(action)` above returned a registered
      // journey for this door and returned early. Both the old destination and
      // the new one were unreachable; the journey won.
      //
      // ⚠️ A ROUTE NAME OF ITS OWN. 'conditions' rather than 'tests_scans',
      // because route names are load-bearing in this app (CLAUDE.md) and a
      // screen filing itself under another screen's name is how a detector
      // starts answering the wrong question about which stage is on screen.
      case kPgActConditionLibrary:
        push(conditionsHomeScreen(pregnancy: pregnancy), 'conditions');

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

  /// The Garbh done-mark as a control. Undo is allowed because a tick she
  /// did not mean is worse than a streak she can fix — and `undoDone` does
  /// not rewind the streak, so a mis-tap costs nothing but the tick.
  void _toggleGarbh(GarbhStore store, String pillarId) =>
      store.isDone(pillarId) ? store.undoDone(pillarId) : store.markDone(pillarId);

  /// "About the size of a guava · 8.7 cm · 43 g" — in the set she chose,
  /// from the week's snapshot. Null when the week has no size (the sheet and
  /// the line both hide).
  // ignore: unused_element
  String? _sizeLine(int week, WeekContent? w) {
    if (w == null) return null;
    final item =
        pregSizeOrFallback(week, PregSizeSetStore.instance.set, w.snapshot.fruit.en);
    if (item == null) return null;
    final parts = [
      item.line,
      w.snapshot.length.en.trim(),
      w.snapshot.weight.en.trim(),
    ].where((s) => s.isNotEmpty);
    return parts.join(' · ');
  }

  /// The week's sheet — superseded by `PregWeekScreen` on 2026-09-22; kept
  /// for revert.
  // ignore: unused_element
  void _openWeekSheet(BuildContext context, int week, WeekContent content, V2Palette p) =>
      showPregSizeSheet(context, week: week, content: content, p: p);

  /// The week stack, on [week]. `selectWeek` before the push, because the
  /// stack reads the controller's selection rather than taking an argument.
  /// ⚠️ UNWIRED from the hero and the insights on 2026-09-21 (the user);
  /// kept for revert.
  // ignore: unused_element
  void _openWeek(BuildContext context, int week) {
    pregnancy.selectWeek(week);
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'weekly_card_stack'),
      builder: (_) => WeeklyCardStackScreen(controller: pregnancy),
    ));
  }

  /// Every destination an insight card can have, in one place.
  ///
  /// ⚠️ AN EXHAUSTIVE SWITCH ON PURPOSE. `PregInsightGo` is a plain enum and
  /// Dart warns on a missing case — the cheapest version of the wiring gate:
  /// a card kind that goes nowhere is a compile-time complaint, not a tile
  /// that does nothing on a device three weeks from now.
  void _openInsight(
      BuildContext context, PregInsight c, int week, WeekContent? content) {
    switch (c.go) {
      // ⚠️ THE SYMPTOMS DOOR, NOT THE OLD COMPANION (2026-09-23). Both cards
      // opened the retired 12-symptom companion after the door shipped, and
      // the second was worse than stale: its lookup searched the old 12, so
      // for any of the 21 new symptoms the card drew and the tap did nothing.
      // The old lines are kept below for revert.
      case PregInsightGo.log:
        _openBracket(context, kSymptomsBracketId); // opens on Today, the check-in
      case PregInsightGo.symptom:
        final s = symptomById(c.symptomId ?? '');
        if (s == null) return; // the card is only built for a known id
        openSymptomRead(context, s, pregnancy);
      // Kept for revert:
      // case PregInsightGo.log:
      //   Navigator.of(context).push(MaterialPageRoute<void>(
      //     settings: const RouteSettings(name: 'symptoms'),
      //     builder: (_) => SymptomCompanionScreen(controller: pregnancy),
      //   ));
      // case PregInsightGo.symptom:
      //   final s = kSymptoms.where((x) => x.id == c.symptomId).firstOrNull;
      //   if (s == null) return;
      //   openSymptomDetail(context, s, pregnancy);
      case PregInsightGo.scan:
        _openBracket(context, 'pregnancy_scans_tests');
      // The timeline, where each scan has "Add the date" (2026-09-30).
      case PregInsightGo.scanWindow:
        openPvDoorSurface(context, kScansSurfaceTimeline, pregnancy);
      case PregInsightGo.week:
        // The week page, Flo's Details (2026-09-22). Not the stack (the user
        // cut that wire, 2026-09-21); the size sheet before that. Kept for
        // revert: _openWeek(context, week); _openWeekSheet(…).
        openPregWeek(context, pregnancy, week);
      case PregInsightGo.size:
        openPregWeek(context, pregnancy, week);
      case PregInsightGo.eat:
        _openBracket(context, kNutritionBracketId);
      case PregInsightGo.safe:
        if (c.entry case final e?) openCanIAnswer(context, e, pregnancy);
      case PregInsightGo.read:
        if (c.read case final r?) {
          Navigator.of(context).push(MaterialPageRoute<void>(
              settings: RouteSettings(name: 'read/${r.id}'),
              builder: (_) => ReadItemScreen(item: r, controller: pregnancy)));
        }
    }
  }

  /// Days from [date] to the due date; negative once it has passed.
  int _daysToDue(DateTime date) => DateTime(pregnancy.dueDate.year, pregnancy.dueDate.month, pregnancy.dueDate.day)
      .difference(DateTime(date.year, date.month, date.day))
      .inDays;

  void _open(BuildContext context, String surfaceId) {
    final h = homeFor(surfaceId);
    if (h == null) return;
    switch (h) {
      case AppHome.today:
      case AppHome.profile:
        TodayVersionStore.instance.set(TodayVersion.classic);
      // ⚠️ THE BAR IS TODAY · LEARN · PRODUCTS · TOOLS · MORE since
      // 2026-09-29, so every index moved. Kept for revert: products 1,
      // prepare 2, tools 2, calendar 3, community 4.
      case AppHome.products:
        AppNav.instance.go(kPregTabProducts);
      case AppHome.prepare:
        // Prepare is More › All programmes and sessions now.
        AppNav.instance.go(kPregTabMore);
      case AppHome.tools:
        AppNav.instance.go(kPregTabTools);
      case AppHome.calendar:
        // Calendar lost its tab to Learn; it opens itself rather than
        // landing her on More one tap short of it.
        Navigator.of(context).push(MaterialPageRoute<void>(
            settings: const RouteSettings(name: 'calendar'),
            builder: (_) => CalendarScreen(controller: pregnancy)));
      case AppHome.community:
        // Held back until it is real (gap analysis P1). Kept for revert:
        //   AppNav.instance.go(4);
        return;
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
          // Was 'Still here, just not first' (2026-09-29: a clever line).
          eyebrow: 'Also today', title: 'More for you today', p: p),
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
                            color: p.ink1.withValues(alpha: 0.7))),
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
                color: on ? p.ink1 : p.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: on ? p.ink1 : p.line),
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
          // ⚠️ ONE TITLE NOW, the design's. It used to switch between
          // 'Worth having at week $week' and 'The ones you come back to' on
          // `store.hasHistory`; the tiles still switch, the title no longer
          // announces which rule picked them. Kept for revert:
          //   title: store.hasHistory
          //       ? 'The ones you come back to'
          //       : 'Worth having at week $week',
          V3SectionHead(
              eyebrow: 'Use these tools',
              // Was 'Count, track, time' (2026-09-29, docs/PREG-VOICE.md).
              title: 'Tools for this week',
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
