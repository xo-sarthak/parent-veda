// =============================================================================
//  PpHomeV3 — the parenting home, rebuilt around the L1 brackets
// -----------------------------------------------------------------------------
//  V1 is `MyChildScreen(home: true)` and is UNTOUCHED. This sits beside it
//  behind a toggle, exactly as Brain (`GrowVersionStore`), Health
//  (`WalletVersionStore`) and Baby names (`NameVersionStore`) already do — three
//  precedents in this same folder, so the pattern is the app's, not mine.
//
//  SAME DESIGN LANGUAGE AS PREGNANCY V3, DIFFERENT CONTENT. The shapes are
//  deliberately identical — same grid, same section heads, same card treatments
//  — because a mother crosses between these two stages once, and that crossing
//  is the worst possible moment to make her relearn a screen. What changes is
//  what is inside them, which is the only thing that should.
//
//  ⚠️ THE HERO CARRIES INFORMATION, NOT A PICTURE.
//
//  It held five drawn scenes and they were the weakest thing in the app. The
//  replacement is Flo's actual move rather than an imitation of its surface: a
//  soft field, one large fact, two short lines. A drawing is the same every
//  morning; the child's age and what is coming next are not. Full reasoning at
//  the head of pp_hero_field.dart.
//
//  ⚠️ RESHAPED 2026-09-16 TO THE "PARENTVEDA V3 HOME" CLAUDE DESIGN, from the
//  user's own seven-point brief. What changed, section by section, and why
//  each piece of the old screen is commented rather than deleted:
//
//    1. Where to go        What to buy is the FIRST tile. Order only.
//    2. This phase explained  VIDEO FIRST, then the text, then a rail of three
//                          further resources. The separate "Watch" section
//                          lower down is gone — that video lives here now.
//    3. How {name} is doing  Only what is ACTUALLY changing at this age — one
//                          card per domain with a milestone this phase, from
//                          the AAP list in pp_phases_data. Tap → a sheet:
//                          video, then text, then more. See pp_home_changes.
//    4. Today              "Activities to do today with your baby" — three,
//                          Done stays for the day, Change swaps at once, all
//                          fresh tomorrow. State in pp_home_activities_store.
//    5. Read               "Recommended reads for today", age-relevant, a rail.
//    6. Recommended        "Recommended products for your baby", age-relevant.
//    7. My journal         "Record a memory for your child today" — a photo
//                          square, a prompt, four entry chips.
//
//  The hero is untouched. "Asked a lot" and "Looking ahead" were not in the
//  design and were not in the brief either way; they stay below the journal
//  until told otherwise, because a section is never removed on inference.
// =============================================================================

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'calendar/pp_child_calendar_screen.dart' show openPpChildCalendar;
import '../brackets/hub/journey_screen.dart';
import '../../data/journeys/journey_registry.dart';
import 'reading_home_screen.dart';
import 'pp_activity_paintings.dart' show PpActivityThumb;
import 'pp_changes_store.dart';
import 'pp_what_changed_data.dart' show kWcHandOff;
import 'what_changed_screen.dart';
import '../../data/hubs/parenting_hubs.dart';
import '../brackets/hub/hub_owed_screen.dart';
import '../brackets/hub/hub_config.dart';
import '../brackets/hub/problem_hub_screen.dart';
import '../../data/hubs/hub_registry.dart';

import '../../localization/app_language.dart';
import '../../models/bracket.dart';
import '../../services/bracket_resolver.dart';
import '../../services/life_stage_store.dart';
import '../../services/parenting_surfaces.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/bracket_screen.dart';
import '../v2/v2_block_grid.dart';
import '../v2/v2_palette.dart';
import '../v2/v2_sections.dart' show v2CoverTint, v2PpReadCover;
import '../v2/v3_bracket_art.dart';
// V3JournalSection is in the commented-out journal block below. Kept so the
// revert is one uncomment.
// ignore: unused_import
import '../v2/v3_daily.dart';
// V3DailyMark is only in the commented-out journal block. Kept for revert.
// ignore: unused_import
import '../v2/v3_daily_art.dart';
import '../v2/v3_daily_tip.dart';
import '../v2/v3_hero_chrome.dart';
import '../v2/v3_dev_mark.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_daily_tips.dart';
import 'pp_development_data.dart';
// The old day-rotated single pick read these directly; the store does now.
// Kept for revert. `kGrowExtraActivities` is still reachable through
// pp_grow_data's `kGrowActivities`.
// ignore: unused_import
import 'pp_grow_activities.dart';
import 'pp_home_activities_store.dart';
import 'pp_home_changes.dart';
import 'pp_feeding_data.dart' show FeedingStore;
import 'pp_home_quick.dart';
import 'pp_sleep_data.dart' show SleepStore;
import 'pp_age_page_parts.dart';
import 'pp_month_notes.dart';
import 'journal_v2/pp_journal_screen.dart';
import 'journal_v2/journal_capture_screens.dart';
import 'pp_milestones_data.dart' show MilestoneStore, kSnapshotMilestone;
import 'pp_milestones_screen.dart' show PpMilestonesScreen;
import 'pp_tools_kit.dart' show ppShortDate;
import '../../widgets/storage_image.dart';
import 'reading_reader_screen.dart';
import 'development_activity_screen.dart';
import 'watch_player_screen.dart';
// import 'product_detail_screen.dart'; // kept for revert (PP 5: the rail opens PvProductScreen)
// import 'journal_v2/journal_home_screen.dart'; // the demo journal, kept for revert
import 'phase_map_screen.dart';
// import 'family_profile_screen.dart'; // kept for revert — the avatar opens You since 2026-09-19
// import 'pp_hero_field.dart'; // the field gave way to the painted hero (2026-10-22)
import '../../widgets/pv_feedback.dart' show PvPress;
import '../../widgets/pv_toast.dart' show pvToast;
// import 'pp_saved_hub_screen.dart'; // kept for revert — SavedScreen replaced the hub 2026-09-16
import '../dear_baby_vault_screen.dart' show DearBabyLettersReadyCard;
import '../profile/pv_you_screen.dart';
import 'multichild_sheet.dart' show showAddChildForm;
import '../saved_screen.dart';
import 'pp_phase_faqs.dart';
import 'pp_phases_data.dart';
import 'pp_products_data.dart';
import 'pp_reading_data.dart';
import 'pp_section_registry.dart';
import '../../data/doors/pp_door_data.dart';
import 'doors/pp_door_screen.dart';
import 'pp_section_screen.dart' show PpSectionTool, ppOpenPage;
import 'pp_surface_router.dart';
import 'pp_watch_data.dart';
import '../../services/father_preview.dart';
import 'pp_father_card.dart';
import 'pp_home_reads.dart';
import 'pp_relevance.dart';
import 'pp_home_products.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../../services/pv_catalog_store.dart';
import 'doors/pp_door_screen.dart' show ppShelfSpecFor, ppTabMarkFor;
import '../doors/pv_shelf_card.dart';
import '../doors/pv_list_row.dart';
import 'pp_tile_order.dart';
import '../../services/family_profile.dart';
// The kept-for-revert _Hero still draws the child switch; the live header
// uses pv_family_switch.dart.
import 'pp_child_switch.dart';
import '../../services/pp_messages_store.dart' show PpMessagesStore;
import '../v2/pv_family_switch.dart' show FamilyHome, PvFamilyTitle;
import 'pp_messages_screen.dart' show openPpMessages;
import '../skilling/sk_turning_six.dart' show PpLearningSpaceCard;
import 'pp_visit_card.dart';
import 'pp_home_today.dart';
import 'problem_solver_screen.dart';
// import 'video/pv_video_config.dart' show pvResolveVideoUrl; // the film pick moved to pp_home_reads.dart (2026-10-21)
import 'pp_tip_links.dart';
// import 'pp_phase_film.dart'; // the film moved onto the phase page (2026-10-22)
import 'pp_phase_doc_reads.dart' show ppOpenMilestoneRead;
import 'pp_phase_page.dart' show ppOpenPhasePage, PpDomainMark;
import '../../data/pp_phase_docs.dart' show ppPhaseDocFor;
import '../ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import '../ttc/ttc_tool_marks.dart' show TtcMarkLeading;
import '../v2/pv_insight_rail.dart';
import '../reader/pv_reader_screen.dart';
import '../../widgets/pv_home_arrival.dart';
import 'pp_page_fill.dart' show ppPageTitle;
import '../community/community_home_card.dart';

// ---- One type scale for the whole home (2026-10-07) ------------------------
//
// The user: "Make sure the font is the same throughout, font size too." Every
// heading is `_Head`; every body line is [_kBody]; every meta line (minutes,
// ages, "Tomorrow brings ...", captions) is [_kMeta]; every card title is
// [_kCardTitle]. pvFraunces for titles, pvManrope for everything else.
// Pregnancy's home scale (2026-10-21, Wave 2): the user found parenting's
// type bigger than the other stages. Was 14; the heading was 24, the age 42.
const double _kBody = 13;

/// The five-card shelf rail the home's reads used before Wave 4 (2026-10-21).
/// Off: reads are three rows, as in TTC and Pregnancy. Kept for revert.
const bool kPpHomeReadsAsRail = false;
const double _kMeta = 12;
const double _kCardTitle = 17;

class PpHomeV3 extends StatefulWidget {
  const PpHomeV3({super.key, this.lang = AppLanguage.english});

  final AppLanguage lang;

  @override
  State<PpHomeV3> createState() => _PpHomeV3State();
}

class _PpHomeV3State extends State<PpHomeV3> {
  /// Which "At this age" question is open, by index.
  ///
  /// ⚠️ ONE AT A TIME, AND THE STATE LIVES HERE RATHER THAN IN THE ROW. Three
  /// independently-open accordions can all be open at once, which pushes the
  /// rest of the page a screen and a half down and defeats the point of
  /// collapsing them. Owning the index in the parent makes "only one" a
  /// property of the data rather than a rule three siblings have to agree on.
  int? _openFaq;

  /// Whether "This phase explained" is showing its full description. Read
  /// only by the commented-out `_PhaseExplained` call since 2026-10-07 (the
  /// full description opens in the reader now). Kept for revert.
  // ignore: prefer_final_fields, unused_field
  bool _phaseExpanded = false;

  AppLanguage get lang => widget.lang;

  // ---- The daily tip, the same card pregnancy shows -------------------------
  //
  // Deliberately the SAME widget rather than a parenting copy. Two cards that
  // look almost alike is worse than one that is identical. Only the content
  // differs — this stage's own tips, and an age instead of a week.
  bool _tipQueued = false;

  /// Opens the required add-child form once, the first build that knows
  /// there is no child (`ChildProfileStore.needsChild`, relevance PP 10). A
  /// developer build keeps the form closable, so the stage chip's stand-in
  /// child still works for testing, as Pregnancy's week-20 stand-in does.
  bool _childAskQueued = false;
  void _maybeAskChild() {
    if (_childAskQueued) return;
    _childAskQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showAddChildForm(context, required: !(kDebugMode || kPvDevBuild));
    });
  }

  void _maybeShowTip(int ageMonths, V2Palette p) {
    if (_tipQueued || kDailyTips.isEmpty) return;
    _tipQueued = true;
    // Day-indexed, so it is stable all day and two people on the same day see
    // the same tip — which matters the first time one is screenshot into a
    // family group.
    // A tip for THIS child's age (gap analysis P2, 2026-10-07: "Ours rotates
    // 14 tips for every age"); `dailyTip()` picks from the age windows and
    // falls back to the general rotation only before a birth date exists.
    // Still stable all day. Kept for revert:
    //   kDailyTips[DateTime.now().difference(DateTime(2020)).inDays % kDailyTips.length]
    final tip = dailyTip();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Filled from her profile, and linked to a door page (2026-10-07).
      // Hand-matched links (pp_tip_links.dart); a keyword match made wrong
      // ones. Kept for revert: final hit = ppTipHit(tip.title, tip.body);
      final id = dailyTipId();
      final link = id.startsWith('atip_') ? kPpTipLinks[id.substring(5)] : null;
      final page = link == null ? null : ppPageTitleForSurface(link);
      showDailyTip(context,
          line: ppFillChild(tip.body),
          heading: ppFillChild(tip.title),
          week: 0,
          day: ageMonths,
          p: p,
          readLabel: page == null ? null : 'Read: $page',
          onRead: page == null ? null : () => _openSurface(context, link!));
    });
  }

  @override
  Widget build(BuildContext context) {
    // The first home's welcome (2026-10-18, pv_home_arrival.dart): once,
    // right after onboarding; every other open is exactly as before.
    return PvHomeArrival(child: AnimatedBuilder(
      animation: Listenable.merge([
        ChildProfileStore.instance,
        V2PaletteStore.instance,
        PpHomeActivitiesStore.instance,
        FatherPreview.instance, // the father's card (2026-10-07)
        PpLastPageStore.instance, // Continue reading (2026-10-07)
        FamilyProfileStore.instance, // tile order by her priorities (2026-10-07)
        PpChangesStore.instance, // what she told us (2026-10-23, Wave 8)
        PpMessagesStore.instance, // the header's inbox count (2026-10-25)
        MilestoneStore.instance, // the Milestones row (R10, 2026-10-26)
        PvCatalogStore.instance, // the store sheet's products (PP 5, 2026-10-28)
      ]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final child = ChildProfileStore.instance;
        final phase = currentPhase(child);
        // No child: ask for one first, and no tip for an age we don't know
        // (relevance PP 10, 2026-10-28). Kept for revert:
        //   _maybeShowTip(child.ageInMonths, p);
        if (child.needsChild(father: FatherPreview.instance.on)) {
          _maybeAskChild();
        } else {
          _maybeShowTip(child.ageInMonths, p);
        }

        // The single day-rotated pick, replaced by the three-a-day store.
        // Kept for revert:
        //   final activity = _todaysActivity();
        // ⚠️ THIS CHILD'S THREE, BY CORRECTED AGE (relevance PP 1 and PP 2,
        // 2026-10-28). Keyed by the child on screen, so a switch or a newly
        // saved birthday brings that child's own three at once, not at
        // midnight. Activities are development content, so a baby born early
        // gets them by corrected age, as the hero and the Brain tab already
        // do. Kept for revert:
        //   PpHomeActivitiesStore.instance.todays(child.ageInMonths);
        final activities = PpHomeActivitiesStore.instance
            .todays(child.devAgeInMonths, childId: child.activeChildId);
        final changes = phaseChangesFor(phase);
        // Corrected age, like the activities above (relevance PP 2,
        // 2026-10-28). Kept for revert:
        //   final reads = _readsForAge(child.ageInMonths, 3);
        final reads = _readsForAge(child.devAgeInMonths, 3);
        // Three, as rows: the shape TTC and Pregnancy already use (2026-10-21,
        // Wave 4, approved). Was five on a shelf rail.
        final sit = PpSituation.now();
        final doorReads = ppHomeDoorReads(3, situation: sit);
        // The film is on the phase page now (2026-10-22). Kept for revert:
        // final video = _video(phase);
        // ⚠️ THE STORE'S CATALOGUE, ONLY WHAT FITS (relevance PP 3 and PP 5,
        // 2026-10-28; pp_home_products.dart). Was the 24 built-in products,
        // padded to six with ones outside the age, so a five-year-old's rail
        // carried baby items, and the store sheet's products never reached
        // the home. Fewer cards when fewer fit; none, and the Store is
        // offered instead. Corrected age (PP 2). Kept for revert:
        //   final products = _productsForAge(child.ageInMonths, 6);
        final products =
            ppCatalogProducts(child.devAgeInMonths, limit: 6, situation: sit);
        // Her situation's questions first (a C-section mother's, a born-early
        // baby's), from the same pool; the brain never drops one.
        final faqs = ppRelevanceOrder(phaseFaqs(phase.number, count: 6),
                situation: sit, text: (f) => '${f.question} ${f.answer}')
            .take(3)
            .toList();
        final next = nextPhase(child);
        final insights = ppHomeInsights();
        // ⚠️ TODAY, WHAT COMES FIRST (relevance PP 7, 2026-10-28;
        // pp_home_today.dart). An urgent answer she gave in the last week
        // sits above the rail; a visit within a week, then the first of the
        // three raised, open today's block under the grid.
        final now = DateTime.now();
        final urgent = ppUrgentFollowUp(now: now);
        final visitLead = ppVisitLead(now: now);
        // Under one the rail is Feed, Sleep, what is growing now, a tip that
        // matches her (only when one does, its reason as the eyebrow), then
        // today's tip: five at most. Over one it stays today's tip and four
        // more, because "This month" and its "Try this" sit right under it.
        final careTiles = ppHomeShowCareTiles();
        final growingNow = careTiles && changes.isNotEmpty ? changes.first : null;
        final railTips = careTiles
            ? [?ppHomeSituationTip(sit, on: now), ...insights.take(1)]
            : insights;

        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(children: [
            // ---- THE FIELD IS THE PAGE, NOT A SECTION --------------------
            //
            // ⚠️ THIS IS THE ANSWER TO "how do people blend two sections", and
            // the answer is that THEY DO NOT.
            //
            // Two flat regions meeting will always show a seam — edge detection
            // is the single thing human vision is best at, and no gradient
            // hides a boundary from it. Every attempt to fade one section into
            // the next has failed here twice: the pregnancy hero (three tries)
            // and this one.
            //
            // What real apps do instead is two things, usually together:
            //
            //   1. THE BACKGROUND BELONGS TO THE PAGE. Flo's pink is not a hero
            //      block with a bottom edge; it is the page's own surface, with
            //      content floating on it. There is no seam because there is
            //      only one surface. Ours was a 302px box that had to end
            //      somewhere — which is also why the colour appeared to
            //      "disappear" on scroll. It was not disappearing; the box was
            //      scrolling away.
            //
            //   2. YOU OVERLAP, YOU DO NOT FADE. The content is a SHEET with a
            //      rounded top and a soft shadow, sitting ON the field. What
            //      reads as smooth is DEPTH — a card edge — not a blend.
            //
            // So: the field fills the whole screen and does not scroll, and the
            // sheet slides over it. The parallax is free.
            // The tinted field gave way to the phase painting at the top of
            // the hero (2026-10-22, Wave 6). Kept for revert:
            // Positioned.fill(
            //   child: PvArrive.field(
            //     child: PpHeroField(
            //         accent: phase.accent,
            //         ground: p.ground,
            //         variant: phase.number),
            //   ),
            // ),
            ListView(
              padding: EdgeInsets.zero,
              children: [
                PvArrive(
                  delay: PvArriveAt.header,
                  // THE PAINTED HERO (2026-10-22, Wave 6, approved in the
                  // Artifact): the phase painting fades into the page, the
                  // child's name and age on it, the 20-step strip, and one
                  // way into the phase page. `_Hero` is kept for revert; its
                  // spine opened the phase map:
                  //   onSpine: () => Navigator.of(context).push(MaterialPageRoute(
                  //       settings: const RouteSettings(name: 'pp/phase_map'),
                  //       builder: (_) => const PhaseMapScreen())),
                  child: _PaintedHero(
                  phase: phase,
                  next: next,
                  child: child,
                  p: p,
                  onSpine: () => ppOpenPhasePage(context),
                  // One Saved screen for the whole app since 2026-09-16
                  // (docs/FAMILY-MODEL.md §6). Kept for revert:
                  // onSaved: () => Navigator.of(context).push(MaterialPageRoute(
                  //     settings: const RouteSettings(name: 'pp/saved'),
                  //     builder: (_) => const PpSavedHubScreen())),
                  onSaved: () => Navigator.of(context).push(MaterialPageRoute(
                      settings: const RouteSettings(name: 'saved'),
                      builder: (_) => const SavedScreen(stage: 'parenting'))),
                  // Was the family profile editor; kept for revert. Since
                  // 2026-09-19 the avatar opens You, and the editor is one
                  // row inside it (Preferences · Personalise).
                  // onProfile: () => Navigator.of(context).push(MaterialPageRoute(
                  //     settings: const RouteSettings(name: 'pp/profile'),
                  //     builder: (_) => const FamilyProfileScreen())),
                  onProfile: () => openPvYou(context, stage: LifeStage.parenting),
                  // Talk to someone, from the header (2026-10-14).
                  onTalk: () => _openSurface(context, 'pp_experts'),
                  // ⚠️ ONE HEADER ON EVERY HOME (2026-10-25, the user: "unify
                  // the header as in parenting its a bit missing"). TTC and
                  // Pregnancy carry Messages and Calendar on the right; so does
                  // Parenting now. The inbox was reachable only from Settings
                  // and More. The calendar opens the vaccines until a child
                  // calendar exists (decided 2026-10-25, owed). Saved moved to
                  // You, as Pregnancy's did on 2026-10-10.
                  onMessages: () => openPpMessages(context),
                  // The child's own calendar now (F7, 2026-10-25): vaccines,
                  // check-ups and appointments. Kept for revert:
                  //   onCalendar: () => _openSurface(context, 'pp_vaccines'),
                  onCalendar: () => openPpChildCalendar(context),
                  unreadMessages: PpMessagesStore.instance.unreadCount,
                )),
                _Sheet(p: p, children: [
                const SizedBox(height: 22),
                // ---- HER LETTERS, READY TO OPEN (2026-10-15) -----------------
                // The Dear Baby letters she wrote in pregnancy open at birth
                // (STILL-OPEN §83.2). First on the sheet until she opens them,
                // then gone: the one card on this home that is about her.
                // It draws nothing for a family without letters.
                DearBabyLettersReadyCard(p: p),
                // ---- SIX TODAY: HER LEARNING SPACE IS READY (2026-10-25) ----
                // From the sixth birthday until a grown-up opens it; "Not now"
                // rests it 7, 14, then 30 days (sk_turning_six.dart, F4/F5).
                // It draws nothing before six or once the space is open.
                PpLearningSpaceCard(p: p),
                // ---- MY DAILY INSIGHTS · TODAY ------------------------------
                //
                // The user (2026-10-07): "On the home screen I would require
                // the Today insight, the way we are having in Pregnancy and
                // trying to conceive." Pregnancy's rail, in pregnancy's place
                // (first thing under the hero), the same `PvInsightTile` with
                // pregnancy's settings. The cards are this child's age tips
                // (pp_home_reads.dart `ppHomeInsights`); each opens its linked
                // door page, or the tip itself in the reader.
                // The heading also shows for an urgent answer alone (PP 7).
                // Was: if (insights.isNotEmpty) ...[
                if (insights.isNotEmpty || urgent != null) ...[
                  _pad(_Head(eyebrow: 'My daily insights', title: 'Today', p: p)),
                  const SizedBox(height: 12),
                  // ---- SOMETHING URGENT SHE TOLD US (PP 7) -------------------
                  // Where her "You told us" rows sit, and above them: the one
                  // answer whose check said to see a doctor, for a week. It
                  // repeats what the check said and routes to a doctor; it never
                  // guesses. Its own row below steps aside meanwhile.
                  if (urgent case final u?) ...[
                    _pad(PpUrgentFollowUpCard(
                      change: u,
                      childName: child.nameMid,
                      p: p,
                      now: now,
                      // Kept for revert (PP 20): a switch on u.concern that
                      // pushed WcFlowScreen, skipping the fever hand-off.
                      onOpen: () => _openChange(context, u),
                      onBetter: () {
                        PpChangesStore.instance.clear(u.concernId);
                        pvToast(context, 'Glad it is better. Your home is back to usual.');
                      },
                      onWorried: () => Navigator.of(context).push(MaterialPageRoute<void>(
                          settings: const RouteSettings(name: 'pp/find_help'),
                          builder: (_) => const ProblemSolverScreen())),
                    )),
                    const SizedBox(height: 14),
                  ],
                  if (insights.isNotEmpty) ...[
                  // ⚠️ TEXT SCALE CLAMPED AT 1.3 FOR THIS RAIL ONLY. The tile is
                  // a fixed 100 x 112 (shared; three fit on a 360dp phone) and
                  // a tip title is longer than pregnancy's values ("Back to
                  // sleep, every sleep"): at 1.5x it ran 14px out of the
                  // card. The full words are one tap away in the page.
                  MediaQuery.withClampedTextScaling(
                    maxScaleFactor: 1.3,
                    child: KeyedSubtree(
                    key: const ValueKey('pp_home_insights'),
                    // The feed and sleep logs ride at the front of the rail
                    // (the user, 2026-10-07), under one only, live from their
                    // stores. pp_home_quick.dart has the lines.
                    child: ListenableBuilder(
                    listenable: Listenable.merge([FeedingStore.instance, SleepStore.instance]),
                    builder: (context, _) => PvInsightRail(tiles: [
                      if (ppHomeShowCareTiles()) ...[
                        PvInsightTile(
                          key: const ValueKey('pp_home_quick_feed'),
                          eyebrow: 'Feed',
                          value: ppHomeFeedLine(),
                          hue: 206,
                          art: PvInsightArt.note,
                          showArt: false,
                          centreValue: true,
                          p: p,
                          onTap: () => _openSurface(context, 'pp_feeding'),
                        ),
                        PvInsightTile(
                          key: const ValueKey('pp_home_quick_sleep'),
                          eyebrow: 'Sleep',
                          value: ppHomeSleepLine(),
                          hue: 268,
                          art: PvInsightArt.note,
                          showArt: false,
                          centreValue: true,
                          p: p,
                          onTap: () => _openSurface(context, 'pp_sleep'),
                        ),
                      ],
                      // What is growing now, under one (PP 7): the first line
                      // of "How {name} is growing", which is far down the page.
                      if (growingNow case final g?)
                        PvInsightTile(
                          key: const ValueKey('pp_home_growing_now'),
                          eyebrow: 'Growing now',
                          value: g.title,
                          hue: 104,
                          art: PvInsightArt.note,
                          showArt: false,
                          centreValue: true,
                          p: p,
                          onTap: () => switch ((g.doc, g.milestonePage)) {
                                (final doc?, final page?) => ppOpenMilestoneRead(context, doc, page),
                                _ => _showChangeSheet(context, g, child, p),
                              },
                        ),
                      // Was: for (final c in insights) (PP 7, 2026-10-28).
                      for (final c in railTips)
                        PvInsightTile(
                          key: ValueKey('pp_insight_${c.id}'),
                          eyebrow: c.eyebrow,
                          value: c.value,
                          hue: c.hue,
                          art: PvInsightArt.note,
                          showArt: false,
                          centreValue: true,
                          p: p,
                          onTap: () => _openInsight(context, c),
                        ),
                    ]),
                  ))),
                  ],
                  const SizedBox(height: 26),
                ],
                // ---- MILESTONES, ONE TAP FROM HOME (R10, 2026-10-26) --------
                // The user: milestones were "hidden" (three taps, through
                // Tools or the Development door). The approved prototype puts
                // the way in under Today, naming the newest one. Drawn with
                // none saved too: the empty line is the invitation (a feature
                // is never hidden).
                _pad(PvRowGroup(
                  key: const ValueKey('pp_home_milestones'),
                  p: p,
                  children: [_milestonesRow(context, p)],
                )),
                const SizedBox(height: 26),
                // Search first, then the last feed and sleep for an under-one
                // (gap analysis P1, 2026-10-07; pp_home_quick.dart).
                // A paired father's week, first (gap analysis P1, Behind · Partner).
                if (FatherPreview.instance.on) ...[
                  _pad(PpFatherCard(p: p, onSurface: (id) => _openSurface(context, id))),
                  const SizedBox(height: 18),
                ],
                // No search bar on the parenting home, and the feed and sleep
                // logs are in the rail above (the user, 2026-10-07). Kept for
                // revert:
                // _pad(PpHomeQuick(p: p, onSurface: (id) => _openSurface(context, id))),
                // const SizedBox(height: 26),
                // The answers a parent opens the age page for, always shown:
                // sleep and feeding now, the WHO ranges, call the doctor if,
                // and the sources (gap analysis P1, 2026-10-07).
                // A note for every month from 12 months, every three from
                // three years (gap analysis P1, 2026-10-07; pp_month_notes.dart).
                if (ppMonthNoteFor(ChildProfileStore.instance.devAgeInMonths) case final note?) ...[
                  const SizedBox(height: 22),
                  _pad(PpThisMonth(note: note, p: p)),
                ],
                // The next well-baby visit, when it is due or close (gap
                // analysis P2, 2026-10-07; pp_visit_card.dart).
                // Within a week it leads today's block under the grid instead
                // (PP 7), so it is not said twice. Was: if (ppVisitCardFor() case final visit?) ...[
                if (ppVisitCardFor(now: now) case final visit? when visitLead == null) ...[
                  const SizedBox(height: 22),
                  _pad(PpVisitCard(visit: visit, p: p, onOpen: () => _openSurface(context, 'pp_vaccines'))),
                ],
                // WHAT SHE TOLD US (2026-10-23, Wave 8): one row per active
                // "Something changed?" answer, only while active, each with its
                // own "Better now". The reads and activities below move up for
                // it and say why (pp_relevance.dart).
                // The urgent one is the card at the top for its first week
                // (PP 7); the rest stay here. Was:
                //   if (PpChangesStore.instance.active() case final told when told.isNotEmpty) ...[
                if ([
                  for (final c in PpChangesStore.instance.active(now: now))
                    if (c.concernId != urgent?.concernId) c
                ] case final told when told.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _pad(PvRowGroup(
                    key: const ValueKey('pp_home_told'),
                    p: p,
                    children: [
                      for (final c in told)
                        PvListRow(
                          key: ValueKey('pp_home_told_${c.concernId}'),
                          p: p,
                          leading: TtcMarkLeading(tab: TtcTabMark.twoBubbles, tint: v2BlockTint(20, p), size: 40),
                          title: 'You told us: ${c.name}', // was c.concern?.label lower-cased (PP 20)
                          line: _toldAgo(c.at),
                          trailing: PvPress(
                            child: OutlinedButton(
                              key: ValueKey('pp_home_told_clear_${c.concernId}'),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: p.ink1,
                                  side: BorderSide(color: p.ink1),
                                  shape: const StadiumBorder(),
                                  visualDensity: VisualDensity.compact),
                              onPressed: () {
                                PpChangesStore.instance.clear(c.concernId);
                                pvToast(context, 'Glad it is better. Your home is back to usual.');
                              },
                              child: const Text('Better now'),
                            ),
                          ),
                          // Kept for revert (PP 20): a switch on c.concern that
                          // pushed WcFlowScreen, skipping the fever hand-off.
                          onTap: () => _openChange(context, c)),
                    ],
                  )),
                ],
                // EXPLORE BY TOPIC UNDER "DUE NOW" (2026-10-22, Wave 6; the user:
                // below the vaccine row "as our app is door oriented"). No
                // eyebrow, like the other two homes.
                // TTC's and pregnancy's heading for the door grid: "Explore by
                // topic", no eyebrow (one ParentVeda, 2026-10-07). Kept for
                // revert: eyebrow: 'Where to go', title: 'Start anywhere'.
                _pad(_Head(
                    eyebrow: '', title: 'Explore by topic', p: p)),
                const SizedBox(height: 14),
                // ⚠️ WHAT TO BUY IS FIRST, and only first. The brief: "What to
                // Buy should become the FIRST box among these 11. It does NOT
                // become the top heading of the overall Parenting page."
                //
                // Reordered HERE rather than in kParentingBrackets: that list
                // is the registry every hub, door and test reads, and its
                // order is documentary (the eleven were built in that order).
                // This is a display decision about one grid.
                _pad(V2BlockGrid(
                  palette: p,
                  columns: 4,
                  blocks: [
                    for (final b in _tilesOrder(bracketsFor(LifeStage.parenting)))
                      V2Block(
                        label: b.label.of(lang),
                        icon: Icons.circle_outlined,
                        tint: v2BlockTint(b.hue, p),
                        bracketMark: bracketMarkFor(b.id),
                        onTap: () => _openBracket(context, b.id),
                      ),
                  ],
                )),
                // WHY THE TILES MOVED (relevance PP 9, 2026-10-28): one line
                // when her own answers moved a tile, never for age alone.
                if (_tilesWhy(bracketsFor(LifeStage.parenting), lang) case final why?) ...[
                  const SizedBox(height: 10),
                  _pad(Text(why,
                      key: const ValueKey('pp_home_tiles_why'),
                      style: pvManrope(fontSize: _kMeta, height: 1.45, color: p.ink3))),
                ],
                const SizedBox(height: 32),

                // ---- ACTIVITIES TO DO TODAY ---------------------------------
                //
                // Was "Today · One thing to try", a single day-rotated card that
                // opened the activities library. Now three cards with their
                // own Done and Change, state held by PpHomeActivitiesStore.
                // The old block is kept for revert:
                //   if (activity != null) ...[
                //     _pad(_Head(
                //         eyebrow: 'Today', title: 'One thing to try', p: p)),
                //     const SizedBox(height: 12),
                //     _pad(_ActivityCard(
                //         activity: activity,
                //         p: p,
                //         onTap: () => _openSurface(context, 'pp_activities'))),
                //     const SizedBox(height: 32),
                //   ],
                // THREE ROWS (2026-10-22, Wave 6, approved in the Artifact; Noom's
                // "Today's plan" on Mobbin): the area's drawn mark, the title, one
                // line, and a round check for done. A tap opens the activity in
                // the reader; a press and hold swaps it, and the line under the
                // rows says so. The three cards with Done and Change are kept
                // below for revert.
                // ---- TODAY'S BLOCK, UNDER THE GRID (PP 7, 2026-10-28) ---------
                // Where Pregnancy keeps its daily practice and TTC its
                // "Recommended" (the user: "so that app symmetry is
                // maintained"). A visit within a week comes first and says why.
                if (visitLead case final v?) ...[
                  _pad(PpVisitLeadCard(
                    visit: v,
                    days: ppDaysToVisit(v, now: now),
                    p: p,
                    onOpen: () => _openSurface(context, 'pp_vaccines'),
                  )),
                  const SizedBox(height: 22),
                ],
                _pad(_Head(
                    eyebrow: 'Together',
                    title: 'Three things to do with ${child.nameMid} today',
                    p: p)),
                const SizedBox(height: 12),
                if (activities.isEmpty)
                  _pad(_EmptyInvite(
                      p: p,
                      line: 'The activity library is still filling in for '
                          '${phase.ageLabel}.',
                      cta: 'Browse every activity',
                      onTap: () => _openSurface(context, 'pp_activities')))
                else ...[
                  // THE FIRST, RAISED (PP 7): one of the three stands out so
                  // the eye lands on one thing to do. It IS activity one, not a
                  // copy, so its tick is the only tick. The rows hold the rest.
                  // Was: activities: activities, in the rows below.
                  _pad(PpFirstActivityCard(
                    activity: activities.first,
                    // What she told us raised it (PP 4): the card says so.
                    why: ppActivityWhy(activities.first, PpChangesStore.instance.active(now: now)),
                    leading: PpActivityThumb(
                      activityId: activities.first.id,
                      size: 56,
                      fallback: _activityMark(activities.first, p, 56),
                    ),
                    done: PpHomeActivitiesStore.instance.isDone(activities.first.id),
                    p: p,
                    onOpen: () => Navigator.of(context).push(MaterialPageRoute<void>(
                        settings: RouteSettings(name: 'pp/activity/${activities.first.id}'),
                        builder: (_) => DevelopmentActivityScreen(activity: activities.first))),
                    onDone: () => PpHomeActivitiesStore.instance.markDone(activities.first.id),
                    onSwap: () {
                      PpHomeActivitiesStore.instance.swap(activities.first.id, child.devAgeInMonths,
                          childId: child.activeChildId);
                      pvToast(context, 'Swapped for another activity.');
                    },
                  )),
                  if (activities.length > 1) ...[
                  const SizedBox(height: 10),
                  _pad(_ActivityRows(
                    activities: activities.skip(1).toList(),
                    p: p,
                    why: (a) => ppActivityWhy(a, PpChangesStore.instance.active(now: now)),
                    onOpen: (a) => Navigator.of(context).push(MaterialPageRoute<void>(
                        settings: RouteSettings(name: 'pp/activity/${a.id}'),
                        builder: (_) => DevelopmentActivityScreen(activity: a))),
                    onSwap: (a) => PpHomeActivitiesStore.instance.swap(
                        a.id, child.devAgeInMonths,
                        childId: child.activeChildId),
                  )),
                  ],
                  const SizedBox(height: 10),
                  _pad(Text(
                      PpHomeActivitiesStore.instance.allDone
                          ? 'All three done. Tomorrow brings three new ones.'
                          : 'Not right today? Press and hold one to swap it.',
                      style: pvManrope(
                          fontSize: _kMeta, height: 1.45, color: p.ink3))),
                ],
                const SizedBox(height: 32),
                // _pad(_Head(
                //     eyebrow: 'Today',
                //     title: 'Activities to do today with your baby',
                //     p: p)),
                // const SizedBox(height: 14),
                // if (activities.isEmpty)
                //   _pad(_EmptyInvite(
                //       p: p,
                //       line: 'The activity library is still filling in for '
                //           '${phase.ageLabel}.',
                //       cta: 'Browse every activity',
                //       onTap: () => _openSurface(context, 'pp_activities')))
                // else ...[
                //   for (final a in activities) ...[
                //     _pad(_TodayActivityCard(
                //       activity: a,
                //       p: p,
                //       done: PpHomeActivitiesStore.instance.isDone(a.id),
                //       swapped: PpHomeActivitiesStore.instance.wasSwappedIn(a.id),
                //       onDone: () => PpHomeActivitiesStore.instance.markDone(a.id),
                //       onChange: () => PpHomeActivitiesStore.instance
                //           .swap(a.id, child.ageInMonths),
                //       onOpen: () => Navigator.of(context).push(
                //           MaterialPageRoute<void>(
                //               settings: RouteSettings(
                //                   name: 'pp/activity/${a.id}'),
                //               builder: (_) =>
                //                   DevelopmentActivityScreen(activity: a))),
                //     )),
                //     const SizedBox(height: 12),
                //   ],
                //   // No counter, no streak, no "2 of 3" — the brief and the
                //   // Grow feature both refuse those. One line about tomorrow.
                //   _pad(Text(
                //       PpHomeActivitiesStore.instance.allDone
                //           ? 'All three done. Tomorrow brings three new ones.'
                //           : 'Tomorrow brings three new ones.',
                //       style: pvManrope(
                //           fontSize: _kMeta, height: 1.45, color: p.ink3))),
                // ],
                // const SizedBox(height: 32),
                // ---- HOW {NAME} IS DOING ------------------------------------
                //
                // ⚠️ ONLY WHAT IS CHANGING, NOT EVERY DOMAIN. The brief: "When
                // opened, it should NOT show every possible developmental
                // change. Determine what is actually changing at the baby's
                // current age and surface only those under the existing
                // categories." The cards come from the phase's own AAP
                // milestone list — see the head of pp_home_changes.dart for
                // why that list and not kDevAreas.
                //
                // The eight-row `_Snapshot` this replaces is kept below for
                // revert; its rows were fixed at a four-month-old and did not
                // move with the child.
                // ONE LINE A CHANGE (2026-10-22, Wave 6, approved in the Artifact):
                // a row with the area's drawn mark, the doc's title and line. The
                // eyebrow names the child, never "her" (the user: "For her" read
                // as the mother). The cards and the summary line are kept below
                // for revert.
                _pad(_Head(
                    eyebrow: 'Right now',
                    title: 'How ${child.nameMid} is growing',
                    p: p)),
                const SizedBox(height: 14),
                if (changes.isEmpty)
                  _pad(_EmptyInvite(
                      p: p,
                      line: 'Nothing is listed for ${phase.ageLabel} yet. '
                          'The Development door has the whole picture.',
                      cta: 'Open Development',
                      onTap: () => _openSurface(context, 'pp_development')))
                else
                  _pad(PvRowGroup(
                    key: const ValueKey('pp_home_changes'),
                    p: p,
                    children: [
                      for (final c in changes)
                        PvListRow(
                          key: ValueKey('pp_home_change_${c.domain.name}'),
                          p: p,
                          leading: c.snapshot == null
                              ? TtcMarkLeading(tab: TtcTabMark.sprout, tint: v2BlockTint(c.hue, p), size: 40)
                              : PpDomainMark(c.snapshot!.domain),
                          title: c.title,
                          line: c.snapshot == null ? c.notice : ppFillChild(c.snapshot!.line),
                          // A snapshot that is one of the milestones shows
                          // the day she saved it (R10, one list).
                          meta: _seenMeta(c.snapshot?.title) ?? c.category,
                          lineMaxLines: 2,
                          onTap: () => switch ((c.doc, c.milestonePage)) {
                                (final doc?, final page?) => ppOpenMilestoneRead(context, doc, page),
                                _ => _showChangeSheet(context, c, child, p),
                              }),
                    ],
                  )),
                const SizedBox(height: 32),
                // _pad(_Head(
                //     eyebrow: 'How ${child.nameMid} is doing',
                //     title: 'Right now',
                //     p: p)),
                // if (changes.isNotEmpty) ...[
                //   const SizedBox(height: 6),
                //   _pad(Text(phaseChangesLine(changes, phase),
                //       style: pvManrope(
                //           fontSize: _kBody, height: 1.45, color: p.ink3))),
                // ],
                // const SizedBox(height: 14),
                // // Kept for revert:
                // //   _pad(_Snapshot(
                // //       p: p,
                // //       onTap: () => _openSurface(context, 'pp_development'))),
                // if (changes.isEmpty)
                //   // A feature is never hidden: a phase with nothing listed
                //   // still shows the door to Development.
                //   _pad(_EmptyInvite(
                //       p: p,
                //       line: 'Nothing is listed for ${phase.ageLabel} yet. '
                //           'The Development door has the whole picture.',
                //       cta: 'Open Development',
                //       onTap: () => _openSurface(context, 'pp_development')))
                // else
                //   for (final c in changes) ...[
                //     _pad(_ChangeCard(
                //         change: c,
                //         p: p,
                //         // A doc card opens the doc's milestone page (2026-10-13);
                //         // the sheet stays for phases without a doc.
                //         onTap: () => switch ((c.doc, c.milestonePage)) {
                //               (final doc?, final page?) => ppOpenMilestoneRead(context, doc, page),
                //               _ => _showChangeSheet(context, c, child, p),
                //             })),
                //     const SizedBox(height: 12),
                //   ],
                // const SizedBox(height: 20),
                // ---- READ ---------------------------------------------------
                //
                // "Short enough for today" → "Recommended reads for today", and
                // a rail rather than rows, per the design. The row form is
                // kept for revert:
                //   _pad(_Head(
                //       eyebrow: 'To read',
                //       title: 'Short enough for today',
                //       p: p)),
                //   const SizedBox(height: 6),
                //   for (final r in reads)
                //     _pad(_ReadRow(
                //         article: r,
                //         p: p,
                //         onTap: () => _openSurface(context, 'pp_read'))),
                // From the doors, in the child's band (gap analysis P1,
                // 2026-10-07; pp_home_reads.dart), with "Continue reading"
                // first. The ten-read rail below is now only the fallback.
                if (PpLastPageStore.instance.last case final last?) ...[
                  _pad(_Head(eyebrow: 'Read', title: 'Continue reading', p: p)),
                  const SizedBox(height: 8),
                  _pad(PvListRow(
                    key: const ValueKey('pp_home_continue'),
                    p: p,
                    leading: PvMarkWell(p: p, hue: 268, size: 44, mark: ppTabMarkFor(Icons.menu_book_outlined)),
                    title: ppPageTitle(last.page),
                    line: last.section.title,
                    onTap: () => ppOpenPage(context, last.section, last.page,
                        onSurface: (ctx, id) => _openSurface(ctx, id)),
                  )),
                  const SizedBox(height: 26),
                ],
                if (doorReads.isNotEmpty) ...[
                  _pad(_Head(eyebrow: 'Read', title: 'Recommended reads for today', p: p)),
                  const SizedBox(height: 14),
                  // ONE FORMAT FOR READS (2026-10-21, Wave 4): three rows, the
                  // shape of Pregnancy's V3ReadRow and TTC's _ReadRow. A row that
                  // the brain moved says why ("On formula"). The shelf rail it
                  // replaces is kept below, unreachable, for revert.
                  Padding(
                    key: const ValueKey('pp_home_door_reads'),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(children: [
                      for (final r in doorReads)
                        _DoorReadRow(
                          read: r,
                          p: p,
                          why: ppRelevanceWhy(sit, r.page.title, r.page.id),
                          onTap: () => ppOpenPage(context, r.section, r.page,
                              onSurface: (ctx, id) => _openSurface(ctx, id)),
                        ),
                    ]),
                  ),
                  if (kPpHomeReadsAsRail)
                  SizedBox(
                    height: pvShelfRailHeight(MediaQuery.textScalerOf(context)),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: doorReads.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final r = doorReads[i];
                        final spec = ppShelfSpecFor(r.page);
                        return PvShelfCard(
                          p: p,
                          hue: (200 + i * 40) % 360,
                          kind: spec.kind,
                          kindWord: spec.word,
                          fact: spec.fact,
                          title: ppPageTitle(r.page),
                          onTap: () => ppOpenPage(context, r.section, r.page,
                              onSurface: (ctx, id) => _openSurface(ctx, id)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ] else if (reads.isNotEmpty) ...[
                  _pad(_Head(
                      eyebrow: 'Read',
                      title: 'Recommended reads for today',
                      p: p)),
                  const SizedBox(height: 14),
                  _ReadRail(
                      items: reads,
                      p: p,
                      onOpen: (r) => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              settings:
                                  RouteSettings(name: 'pp/read/${r.id}'),
                              builder: (_) =>
                                  ReadingReaderScreen(article: r)))),
                  const SizedBox(height: 32),
                ],

                // ---- WATCH — MOVED INTO "THIS PHASE EXPLAINED" --------------
                //
                // The heading is gone; the video is the first thing in that
                // section now. Kept for revert:
                //   if (video != null) ...[
                //     _pad(_Head(
                //         eyebrow: 'Watch',
                //         title: 'This phase, in a video',
                //         p: p)),
                //     const SizedBox(height: 12),
                //     _pad(_VideoCard(
                //         video: video,
                //         p: p,
                //         onTap: () => _openSurface(context, 'pp_watch'))),
                //     const SizedBox(height: 32),
                //   ],

                // ---- RECOMMENDED PRODUCTS -----------------------------------
                //
                // Products still after every free section, same as pregnancy
                // V3 — free first, paid last, which is the wedge expressed as
                // layout. Renamed from "Things that help · What parents ask us
                // about" to the brief's wording, and filtered to the child's
                // age. Kept for revert:
                //   _pad(_Head(
                //       eyebrow: 'Things that help',
                //       title: 'What parents ask us about',
                //       note: 'Prices shown',
                //       p: p)),
                // The section always shows (a feature is never hidden, PP 3,
                // 2026-10-28): with nothing in the catalogue for this age yet,
                // one row offers the whole Store instead of a rail.
                // Was `if (products.isNotEmpty) ...[` around the rail.
                ...[
                  // Named for the child (2026-10-22, Wave 6). Was eyebrow
                  // 'Recommended', title 'Recommended products for your baby'.
                  _pad(_Head(
                      eyebrow: 'For ${child.nameMid}',
                      title: 'Useful at this age',
                      p: p)),
                  const SizedBox(height: 14),
                  // The PpProduct rail, kept for revert:
                  //   _ProductRail(
                  //       items: products,
                  //       p: p,
                  //       onOpen: (it) => Navigator.of(context).push(
                  //           MaterialPageRoute<void>(
                  //               settings:
                  //                   RouteSettings(name: 'pp/product/${it.id}'),
                  //               builder: (_) =>
                  //                   ProductDetailScreen(product: it)))),
                  if (products.isNotEmpty)
                    PpCatalogRail(
                        key: const ValueKey('pp_home_products'),
                        items: products,
                        p: p)
                  else
                    _pad(PvListRow(
                      key: const ValueKey('pp_home_products_empty'),
                      p: p,
                      leading: PvMarkWell(p: p, hue: 28, size: 44, mark: IntentMark.bagMark),
                      title: 'Browse the Store',
                      line: 'Nothing picked for ${child.nameMid}\'s age yet. Everything we carry is in the Store.',
                      onTap: () => _openSurface(context, 'pp_products'),
                    )),
                  const SizedBox(height: 32),
                ],

                // ---- JOURNAL ------------------------------------------------
                //
                // ⚠️ NO BRACKET OWNS THIS, and none should. A journal is not a
                // problem she has — it is the one place on the screen where she
                // PUTS SOMETHING IN rather than taking something out. Pregnancy
                // V3 learned this the hard way: the journal was demoted to a
                // chip and quietly stopped happening.
                // "Keep today" → "Record a memory for your child today", and
                // the design's own card: a photo square, a prompt line, four
                // entry chips. The shared V3JournalSection it replaces is kept
                // for revert — the note about why it was shared still holds,
                // and the day pregnancy V3 adopts this card it should become
                // the shared one again.
                //   _pad(_Head(
                //       eyebrow: 'My journal', title: 'Keep today', p: p)),
                //   const SizedBox(height: 12),
                //   _pad(V3JournalSection(
                //     p: p,
                //     actions: [
                //       V3QuickAction(
                //           icon: Icons.edit_note_rounded,
                //           mark: V3DailyMark.memory,
                //           hue: 42,
                //           label: 'Write a\nmemory',
                //           onTap: () => _openJournal(context)),
                //       V3QuickAction(
                //           icon: Icons.favorite_border_rounded,
                //           mark: V3DailyMark.note,
                //           hue: 344,
                //           label: 'Note for\nthem',
                //           onTap: () => _openJournal(context)),
                //       V3QuickAction(
                //           icon: Icons.photo_camera_outlined,
                //           mark: V3DailyMark.photo,
                //           hue: 206,
                //           label: 'Add a\nphoto',
                //           onTap: () => _openJournal(context)),
                //       V3QuickAction(
                //           icon: Icons.mic_none_rounded,
                //           mark: V3DailyMark.voice,
                //           hue: 268,
                //           label: 'Record\nvoice',
                //           onTap: () => _openJournal(context)),
                //     ],
                //     onOpenAll: () => _openJournal(context),
                //   )),
                _pad(_Head(
                    eyebrow: 'My journal',
                    title: 'Record a memory for your child today',
                    p: p)),
                const SizedBox(height: 14),
                // ONE CARD, BOTH STAGES (2026-10-17). The user: the two
                // journals "look as separate things". Pregnancy kept the
                // shared V3JournalSection; this home now uses it too, with
                // its own four ways in. Each tile opens the page it always
                // reached, by name. The private _JournalInvite (photo square,
                // prompt line, four text chips) is kept for revert below.
                _pad(V3JournalSection(
                  key: const ValueKey('pp_home_journal'),
                  p: p,
                  actions: [
                    V3QuickAction(
                        icon: Icons.edit_note_rounded,
                        mark: V3DailyMark.memory,
                        hue: 42,
                        label: 'Add a\nmemory',
                        onTap: () => showAddMemorySheet(context)),
                    // "A first" IS THE ONE MILESTONE SAVE (R10, 2026-10-26):
                    // it lands in Milestones and, switch on, in the journal
                    // as one memory. One word everywhere, so it says
                    // milestone. The guided prompts, kept for revert:
                    //   label: 'A\nfirst',
                    //   onTap: () => Navigator.of(context).push(
                    //       MaterialPageRoute<void>(
                    //           settings: const RouteSettings(
                    //               name: 'pp/journal/guided'),
                    //           builder: (_) => const GuidedMemoryScreen()))),
                    V3QuickAction(
                        icon: Icons.star_outline_rounded,
                        mark: V3DailyMark.first,
                        hue: 18,
                        label: 'A\nmilestone',
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                                settings: const RouteSettings(
                                    name: 'pp_milestones'),
                                builder: (_) => const PpMilestonesScreen(
                                    startSave: true)))),
                    V3QuickAction(
                        icon: Icons.photo_camera_outlined,
                        mark: V3DailyMark.photo,
                        hue: 206,
                        label: 'Add a\nphoto',
                        onTap: () =>
                            _openCapture(context, 'A photo from today')),
                    V3QuickAction(
                        icon: Icons.mail_outline_rounded,
                        mark: V3DailyMark.letter,
                        hue: 330,
                        label: 'Write a\nletter',
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                                settings: const RouteSettings(
                                    name: 'pp/journal/letter'),
                                builder: (_) => const LetterScreen()))),
                  ],
                  onOpenAll: () => _openJournal(context),
                )),
                // Kept for revert (2026-10-17): the parenting-only card.
                // _pad(_JournalInvite(
                //   p: p,
                //   onPhoto: () => _openCapture(context, 'A photo from today'),
                //   onMilestone: () => Navigator.of(context).push(
                //       MaterialPageRoute<void>(
                //           settings:
                //               const RouteSettings(name: 'pp/journal/guided'),
                //           builder: (_) => const GuidedMemoryScreen())),
                //   onThought: () => Navigator.of(context).push(
                //       MaterialPageRoute<void>(
                //           settings:
                //               const RouteSettings(name: 'pp/journal/write'),
                //           builder: (_) => const WriteStoryScreen())),
                //   onMoment: () =>
                //       _openCapture(context, 'A moment from today'),
                //   onOpenAll: () => _openJournal(context),
                // )),
                const SizedBox(height: 32),

                // ---- PARENTS LIKE YOU (2026-10-28, the community) ----------
                //
                // Before the phase questions: the people asking them. Replies
                // waiting for her, or a real question from her stage's rooms.
                _pad(const CommunityHomeCard()),
                const SizedBox(height: 32),

                // ---- QUESTIONS FOR THIS PHASE -------------------------------
                //
                // Rotates once per launch, not per rebuild — otherwise the
                // questions shuffle under her thumb on every repaint. That
                // rotation already lives in pp_phase_faqs.dart; this only reads
                // it.
                if (faqs.isNotEmpty) ...[
                  _pad(_Head(
                      eyebrow: 'Asked a lot',
                      title: 'At this age',
                      p: p)),
                  const SizedBox(height: 10),
                  // One white group, hairlines between the questions, no
                  // tinted fill when one is open (2026-10-07; the user: "the
                  // purple lavender background behind the drop-down, I don't
                  // like it"). Kept for revert: each `_FaqRow` padded on its
                  // own, as below, with the surfaceAlt fill in the row.
                  //   for (var i = 0; i < faqs.length; i++)
                  //     _pad(_FaqRow(faq: faqs[i], p: p, open: _openFaq == i,
                  //       onTap: () => setState(() => _openFaq = _openFaq == i ? null : i))),
                  _pad(Container(
                    key: const ValueKey('pp_home_faqs'),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: p.line),
                    ),
                    child: Column(children: [
                      for (var i = 0; i < faqs.length; i++)
                        _FaqRow(
                          faq: faqs[i],
                          p: p,
                          open: _openFaq == i,
                          last: i == faqs.length - 1,
                          // Tapping the open one closes it: a disclosure that
                          // cannot be undone is a worse control than none.
                          onTap: () =>
                              setState(() => _openFaq = _openFaq == i ? null : i),
                        ),
                    ]),
                  )),
                  const SizedBox(height: 32),
                ],

                _ResourceRail(p: p, items: [
                  _Resource(
                      label: 'This month', // was "This month's checklist" (R10)
                      hue: 28,
                      icon: Icons.checklist_rtl_outlined,
                      mark: TtcTabMark.checklist,
                      onTap: () => _openSurface(context, 'pp_month_checklist')),
                  // "What changes next" went with the phase map (2026-10-22, Wave 6):
                  // the hero opens the phase page, a swipe from the next phase.
                  // Kept for revert:
                  //   _Resource(
                  //       label: 'What changes next',
                  //       hue: 42,
                  //       icon: Icons.timeline_outlined,
                  //       mark: TtcTabMark.timelineDots,
                  //       onTap: () => Navigator.of(context).push(
                  //           MaterialPageRoute<void>(
                  //               settings:
                  //                   const RouteSettings(name: 'pp/phase_map'),
                  //               builder: (_) => const PhaseMapScreen()))),
                  _Resource(
                      // Was 'Something changed?' (tools pass H2: one symptom tool).
                      label: 'Is my baby OK?',
                      hue: 285,
                      icon: Icons.help_outline_rounded,
                      mark: TtcTabMark.signpost,
                      onTap: () => _openSurface(context, 'pp_what_changed')),
                  _Resource(
                      label: 'When to call the doctor',
                      hue: 188,
                      icon: Icons.medical_services_outlined,
                      mark: TtcTabMark.doctorChat,
                      // This phase's own lines first (gap analysis P1, 2026-10-07).
                      // Kept for revert: onTap: () => _openSurface(context, 'pp_baby_ok_check')),
                      onTap: () => showPpCallDoctorSheet(context,
                          phase: phase, p: p, onCheck: () => _openSurface(context, 'pp_baby_ok_check'))),
                ]),
                const SizedBox(height: 32),

                // ---- KEPT FOR REVERT (2026-10-22, Wave 6) ------------------
                //
                // The phase film, its caption, "Phase at a glance" and the age
                // page (sleep, feeding, growth, call the doctor) left the home:
                // the hero opens the phase page, whose body is the whole phase
                // doc with the film on top. "Looking ahead" is commented out on
                // the user's word ("no need of it").
                // // ---- CHILD SNAPSHOT -----------------------------------------
                // //
                // // ⚠️ THIS IS THE SPINE, NOT A BRACKET, and the distinction is
                // // why the first cut of this screen was wrong.
                // //
                // // The eleven doors cover the PROBLEM space — the things she
                // // comes looking for. They were never meant to carry the phase
                // // spine or the personal tools, and building the grid and
                // // stopping left this screen missing everything V1 does between
                // // its hero and its footer. Pregnancy V3 makes the same split:
                // // doors for problems, sections for the week she is in.
                // //
                // // The Development door goes deeper on all four domains. This is
                // // the glance.
                // // ---- THIS PHASE EXPLAINED -----------------------------------
                // //
                // // ⚠️ V3 DID NOT HAVE THIS AND THE CURRENT HOME DOES. The review
                // // asked for symmetry between the two and named this section by
                // // name. It is the only place either screen explains what the
                // // phase actually IS, as opposed to what to do during it, so
                // // losing it in V3 meant the doors and the daily prompts sat on
                // // top of nothing.
                // //
                // // Summary always, the full description on tap: the sections are
                // // several paragraphs each and printing them unasked would push
                // // every door below the fold.
                // // Pregnancy's heading for its film, "Your week, explained": a
                // // serif title, no eyebrow (one ParentVeda, 2026-10-07). Kept
                // // for revert: eyebrow 'This phase explained', title
                // // 'What ${phase.ageLabel} looks like'.
                // _pad(_Head(eyebrow: '', title: 'This phase, explained', p: p)),
                // const SizedBox(height: 14),
                // // ⚠️ VIDEO FIRST. The brief: "Currently the written description
                // // comes first while the video appears much further down the
                // // page. Change the order so that the video explanation of the
                // // phase comes first, the written description follows
                // // immediately after, and any additional resources follow."
                // //
                // // The video is the same phase-matched one the old "Watch"
                // // section showed (see `_video`). Only its place changed.
                // // The film as pregnancy plays its week film: edge to edge, in
                // // place, the title and "Why this matters now" under it
                // // (pp_phase_film.dart). Kept for revert: _pad(_PhaseVideoCard(
                // // video: video, p: p, onTap: () => _openVideo(context, video))).
                // if (video != null) ...[
                //   PpPhaseFilm(
                //       video: video,
                //       phase: phase.number,
                //       p: p,
                //       onUnavailable: () => _openVideo(context, video)),
                //   const SizedBox(height: 14),
                //   _pad(PpPhaseFilmCaption(video: video, p: p)),
                //   const SizedBox(height: 20),
                // ],
                // // The prose, segregated (2026-10-07; the user: "very text
                // // heavy, like text thrown"). The summary and three short
                // // labelled points; the rest of the phase opens in the reader
                // // behind "Read the full description" (pp_phase_film.dart
                // // `ppPhaseAsRead`), so no word is lost. Kept for revert:
                // //   _pad(_PhaseExplained(
                // //     phase: phase,
                // //     p: p,
                // //     expanded: _phaseExpanded,
                // //     onToggle: () =>
                // //         setState(() => _phaseExpanded = !_phaseExpanded),
                // //   )),
                // _pad(_PhaseAtAGlance(
                //   phase: phase,
                //   p: p,
                //   onReadMore: () => ppOpenPhaseRead(context, phase),
                // )),
                // const SizedBox(height: 22),
                // _pad(PpAtThisAge(
                //   phase: phase,
                //   p: p,
                //   onGrowth: () => _openSurface(context, 'pp_growth'),
                // )),
                // const SizedBox(height: 16),
                // // ---- LOOKING AHEAD ------------------------------------------
                // //
                // // The only thing on the page about a time that has not arrived.
                // // It closes the screen because the last thing she should read is
                // // that there is a next, not that there is a product.
                // if (next != null) ...[
                //   // The name moved into the card (2026-10-07). Kept for
                //   // revert: title: next.name.
                //   _pad(_Head(
                //       eyebrow: 'Looking ahead', title: 'What comes next', p: p)),
                //   const SizedBox(height: 12),
                //   _pad(_AheadCard(
                //       next: next,
                //       p: p,
                //       // The phase map is where "what changes next" actually
                //       // lives, and it is already the hero's own destination.
                //       onTap: () => Navigator.of(context).push(
                //           MaterialPageRoute<void>(
                //               settings:
                //                   const RouteSettings(name: 'pp/phase_map'),
                //               builder: (_) => const PhaseMapScreen())))),
                //   const SizedBox(height: 30),
                // ],
                ]),
              ],
            ),
            const Positioned(
                left: 16,
                right: 16,
                bottom: 18,
                child: PpBottomNav(active: PpTab.home)),
          ]),
        );
      },
    ));
  }

  Widget _pad(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18), child: child);

  // ---- Content selection ----------------------------------------------------
  //
  // Everything below picks from data that already ships. Nothing is written
  // here, and nothing is filtered so tightly that an empty result is likely — an
  // empty section on a home screen is a worse failure than a slightly off-age
  // one, and the age filtering belongs in the destination screens that already
  // do it properly.

  /// The eleven tiles, in registry order — Sleep first.
  ///
  /// ⚠️ WHAT TO BUY IS NO LONGER HOISTED — 2026-09-18, the user: "the door
  /// positioning should be like the way it was." The 2026-09-16 brief put it
  /// first; on the phone it read as the shop leading a parenting home, and
  /// the products door is being built elsewhere anyway. Kept for revert:
  // static List<Bracket> _tilesOrder(List<Bracket> all) => [
  //       for (final b in all)
  //         if (b.id == 'parenting_buying') b,
  //       for (final b in all)
  //         if (b.id != 'parenting_buying') b,
  //     ];
  // By age and her priorities (gap analysis P2, 2026-10-07; pp_tile_order.dart).
  // Every tile stays; only the order moves. Kept for revert:
  // static List<Bracket> _tilesOrder(List<Bracket> all) => all;
  static List<Bracket> _tilesOrder(List<Bracket> all) {
    // ON since 2026-10-07 (kPpTileOrderByAge, pp_tile_order.dart): by age, her
    // priorities and her signals. Was "OFF BY DEFAULT", stale since that day
    // (relevance PP 14). Kept for revert: the user's 2026-09-18 call was
    // registry order, Sleep first; flipping the flag restores it.
    if (!kPpTileOrderByAge) return all;
    final f = FamilyProfileStore.instance;
    final order = ppTileOrder([for (final b in all) b.id],
        ageInDays: ChildProfileStore.instance.ageInDays,
        priorities: f.priorities,
        birthMode: f.birthMode,
        // The relevance brain's signals (2026-10-21, Wave 4).
        signals: PpSituation.now().signals);
    final byId = {for (final b in all) b.id: b};
    return [for (final id in order) byId[id]!];
  }

  /// The line under the grid when her answers moved a tile (PP 9), from the
  /// same inputs as [_tilesOrder]. Null with the flag off or for age alone.
  static String? _tilesWhy(List<Bracket> all, AppLanguage lang) {
    if (!kPpTileOrderByAge) return null;
    final f = FamilyProfileStore.instance;
    final byId = {for (final b in all) b.id: b};
    return ppTileWhy([for (final b in all) b.id],
        ageInDays: ChildProfileStore.instance.ageInDays,
        label: (id) => byId[id]?.label.of(lang) ?? id,
        priorities: f.priorities,
        birthMode: f.birthMode,
        signals: PpSituation.now().signals);
  }

  // The single day-rotated pick. Superseded by PpHomeActivitiesStore, which
  // owns "three a day, Done stays, Change swaps". Kept for revert.
  // ignore: unused_element
  DevActivity? _todaysActivity() {
    final all = [...kGrowExtraActivities, ...kDevActivities];
    if (all.isEmpty) return null;
    return all[DateTime.now().day % all.length];
  }

  // Day-rotated, age-blind. Kept for revert.
  // ignore: unused_element
  List<ReadArticle> _reads(int n) {
    final all = readCatalog;
    if (all.isEmpty) return const [];
    final start = DateTime.now().day % all.length;
    return [
      for (var i = 0; i < n && i < all.length; i++) all[(start + i) % all.length]
    ];
  }

  /// Reads that fit the child's age first, the rest to fill — a rail of three
  /// is the promise, and "relevant to the current age" is the preference.
  ///
  /// ⚠️ THE TAGS ARE PROSE AND THE PARSER FAILS OPEN. `ReadArticle.ageTag` is
  /// '3–6 mo', '1–3 yr', '6+ mo' or 'All stages'. `devAgeRange` reads the
  /// first two; '6+' is read here; anything else ('All stages', a typo) is
  /// treated as suiting every age rather than none, because a read that
  /// silently vanishes from every rail is the worse failure.
  List<ReadArticle> _readsForAge(int months, int n) {
    final all = readCatalog;
    if (all.isEmpty) return const [];
    bool suits(ReadArticle a) {
      final r = devAgeRange(a.ageTag);
      if (r != null) return months >= r.lo && months <= r.hi;
      final plus = RegExp(r'(\d+)\s*\+').firstMatch(a.ageTag);
      if (plus != null) {
        var lo = int.parse(plus.group(1)!);
        if (a.ageTag.toLowerCase().contains('yr')) lo *= 12;
        return months >= lo;
      }
      return true;
    }

    // Day-rotated within each tier, so the rail is not the same three every
    // morning for a child who stays in one band for months.
    List<ReadArticle> rotate(List<ReadArticle> xs) {
      if (xs.isEmpty) return xs;
      final start = DateTime.now().day % xs.length;
      return [for (var i = 0; i < xs.length; i++) xs[(start + i) % xs.length]];
    }

    final fit = rotate(all.where(suits).toList());
    final rest = rotate(all.where((a) => !suits(a)).toList());
    return [...fit, ...rest].take(n).toList();
  }

  /// ⚠️ THE PHASE'S VIDEO, NOT THE DAY'S.
  ///
  /// This was `kWatchVideos[day % length]` -- a rotation across the whole
  /// catalogue, so a parent of a three-week-old could be shown a video about
  /// toddler tantrums. The Current home has had a phase-matched one since it
  /// was built ("This phase, in a video"), and `watchCategoryForPhase` already
  /// exists to do the matching. V3 simply never used it.
  ///
  /// Falls back to the old rotation rather than showing nothing: an empty
  /// category is a content gap, and a home screen with a hole in it is worse
  /// than one showing a slightly off-age video.
  // Only a film that can play (gap analysis P1, Behind · Age by age,
  // 2026-10-07): "hide the phase video card until a film exists". In release
  // the dev placeholders are off, so a video with no real URL draws no card.
  // Kept for revert: the same two picks without the playable filter.
  // The pick moved to pp_home_reads.dart (`ppPhaseVideo`, 2026-10-21) so the
  // phase screen shows the same film. The body it had, kept for revert:
  //   bool plays(WatchVideo v) => pvResolveVideoUrl(v) != null;
  //   final pool = watchByCategory(watchCategoryForPhase(phase)).where(plays).toList();
  //   if (pool.isNotEmpty) return pool[DateTime.now().day % pool.length];
  //   final all = kWatchVideos.where(plays).toList();
  //   return all.isEmpty ? null : all[DateTime.now().day % all.length];
  // ignore: unused_element
  WatchVideo? _video(AgePhase phase) => ppPhaseVideo(phase);

  // Day-rotated, age-blind. Kept for revert.
  // ignore: unused_element
  List<PpProduct> _products(int n) {
    if (kPpProducts.isEmpty) return const [];
    final start = DateTime.now().day % kPpProducts.length;
    return [
      for (var i = 0; i < n && i < kPpProducts.length; i++)
        kPpProducts[(start + i) % kPpProducts.length]
    ];
  }

  /// Products that suit the child's age first (`PpProduct.suitsAge`, which
  /// every product already declares), the rest to fill the rail. A card for a
  /// product she does not need yet is allowed — the design's own rail says
  /// "You do not need this yet" on one — but it comes after the ones she does.
  // Superseded by ppCatalogProducts (PP 3 and PP 5, 2026-10-28). Kept for revert.
  // ignore: unused_element
  List<PpProduct> _productsForAge(int months, int n) {
    if (kPpProducts.isEmpty) return const [];
    List<PpProduct> rotate(List<PpProduct> xs) {
      if (xs.isEmpty) return xs;
      final start = DateTime.now().day % xs.length;
      return [for (var i = 0; i < xs.length; i++) xs[(start + i) % xs.length]];
    }

    final fit = rotate(kPpProducts.where((x) => x.suitsAge(months)).toList());
    final rest = rotate(kPpProducts.where((x) => !x.suitsAge(months)).toList());
    // The brain (2026-10-21, Wave 4): inside the age fit, products for her
    // situation lead (a bottle set when she formula-feeds). Age still comes
    // first; nothing is dropped. Was: return [...fit, ...rest].take(n).toList();
    final sit = PpSituation.now();
    String about(PpProduct x) => '${x.name} ${x.category}';
    return [
      // commerce: an urgent "Something changed?" never lifts a product (Wave 8).
      ...ppRelevanceOrder(fit, situation: sit, text: about, commerce: true),
      ...ppRelevanceOrder(rest, situation: sit, text: about, commerce: true),
    ].take(n).toList();
  }

  // ---- Navigation -----------------------------------------------------------

  void _openBracket(BuildContext context, String bracketId) {
    final b = bracketById(bracketId);
    if (b == null) return;

    // ⚠️ A DOOR, IF THIS BRACKET HAS ONE, AND IT OPENS DIRECTLY. Decided
    // 2026-09-11: the parenting doors open the way the TTC and pregnancy
    // doors open — hero, selector, rails — from the tile, with no hub screen
    // in front. `kPpDoors` is parenting's own registry; a bracket that is not
    // in it keeps its hub and library exactly as before.
    final door = ppDoorFor(bracketId);
    if (door != null) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'pp_door/$bracketId'),
        builder: (_) => PpDoorScreen(door: door, onSurface: _openSurface),
      ));
      return;
    }

    // ⚠️ THE HUB REGISTRY DECIDES, NOT THIS SCREEN.
    //
    // Two outcomes: a hub with 2+ doors pushes the hub screen; a hub with ONE
    // door opens that door's destination directly, because a screen whose only
    // content restates the tile she just tapped is a tap of pure tax. See
    // lib/data/hubs/hub_registry.dart.
    final hub = hubFor(bracketId);
    if (hub != null) {
      final sole = soleDoorOf(bracketId);
      if (sole != null) {
        if (sole.action != null) {
          _hubAction(context, sole.action!);
        } else if (sole.surfaceId != null) {
          _openSurface(context, sole.surfaceId!);
        }
        return;
      }
      // ⚠️ THE HUB'S TOOLS ARE READ FROM THE SECTION, NOT DECLARED TWICE.
      //
      // Feedback: tools should sit on the main section screen above "Talk to
      // an expert", rather than inside one of the doors. The obvious way to do
      // that is to add a tools list to `HubConfig` — and then every tool
      // exists in two files, and the day somebody adds one to the section it
      // silently does not appear on the hub. `ppSectionFor` already keys on
      // the same `bracketId` the hub carries, so there is exactly one list.
      //
      // Empty for any bracket with no built section yet, which renders as no
      // tools block at all rather than an empty heading.
      final section = ppSectionFor(bracketId);
      final hubTools = [
        for (final t in section?.tools ?? const <PpSectionTool>[])
          HubTool(
            label: LocalizedText(en: t.label, hi: t.label),
            blurb: LocalizedText(en: t.blurb, hi: t.blurb),
            surfaceId: t.surfaceId,
            // The section already chose an icon for every tool; the hub row
            // used to throw it away and draw a spanner nine times on Health.
            icon: t.icon,
          ),
      ];

      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'hub/' + bracketId),
        builder: (_) => ProblemHubScreen(
          config: hub,
          bracket: b,
          lang: lang,
          tools: hubTools,
          listenTo: V2PaletteStore.instance,
          onSurface: _openSurface,
          onAction: _hubAction,
        ),
      ));
      return;
    }

    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'bracket'),
      builder: (_) => BracketScreen(
        bracket: b,
        lang: lang,
        // Parenting answers from its own surface list — app_structure is the
        // pregnancy tab set and has no opinion about these ids.
        labelFor: (id) => ppSurfaceLabel(id)?.of(lang),
        onOpenSurface: _openSurface,
      ),
    ));
  }

  /// The parenting hub actions. Same rule as TTC: reuse a live surface, or say
  /// plainly that it is owed. Never open something adjacent and hope.
  void _hubAction(BuildContext context, String action) {
    // ⚠️ SECTIONS JUMP THE JOURNEY GUARD, AND THIS ORDER IS LOAD-BEARING.
    //
    // The guard below RETURNS for any door with a journey. Seven parenting doors
    // have one, which means their `case` arms further down -- six carefully
    // written `owed(...)` calls with their own copy and fallbacks -- have never
    // been able to run. They compile, they read as live code, and nothing fails.
    // That is the same trap the pregnancy side hit when three of its doors gained
    // real sections, and it is why this block sits above the guard rather than
    // inside the switch.
    //
    // The journeys are NOT deleted. They stay in `kParentingJourneys` as the
    // record of what each door promised, and they are what these sections were
    // built to satisfy: a journey is a three-to-five step walk toward one
    // outcome, a section is the age-banded library behind it. Where a real
    // library now exists it is strictly more than the walk was.
    const sectionForAction = <String, String>{
      kPpActSleepProblem: 'parenting_sleep',
      kPpActBehaviour: 'parenting_behaviour',
      kPpActTradition: 'parenting_traditional',
      kPpActFeedingProblem: 'parenting_feeding',
      kPpActSchoolReadiness: 'parenting_early_learning',
      // ⚠️ THESE TWO USED TO BE IDENTICAL, and the feedback caught it: "Is My
      // Child Ready and Start & Manage Potty Training both are opening to same
      // sections". Both mapped to the bare section id, so two differently
      // worded questions got one landing page.
      //
      // Left in this map as the FALLBACK — if either area id ever stops
      // existing, the door still opens the right section rather than nothing.
      // The specific destinations are set just below.
      kPpActPottyReadiness: 'parenting_potty',
      kPpActPottyTraining: 'parenting_potty',
      kPpActFirst40Days: 'parenting_first_40',
      kPpActMaternalRecovery: 'parenting_maternal',
      kPpActMaternalConcern: 'parenting_maternal',
    };
    // ⚠️ DOORS THAT NAME A SPECIFIC AREA, RATHER THAN A SECTION.
    //
    // A hub door is a question. When two doors ask different questions the
    // answers have to differ, and until now the only thing the router could
    // address was a whole section. Third instance of that shape in this
    // review, after Nutrition and Development.
    const areaForAction = <String, String>{
      kPpActPottyReadiness: 'parenting_potty/getting_ready',
      kPpActPottyTraining: 'parenting_potty/how_to_do_it',
      // The Early Learning brief's one structural call: "Prepare for
      // school" points at the school-readiness tab, not at the whole
      // library, so the stories and activities are not behind a school
      // button. 2026-09-13.
      kPpActSchoolReadiness: 'parenting_early_learning/school',
    };
    final areaTarget = areaForAction[action];
    if (areaTarget != null) {
      _openSurface(context, 'pp_section/$areaTarget');
      return;
    }

    final sectionId = sectionForAction[action];
    if (sectionId != null && ppSectionFor(sectionId) != null) {
      _openSurface(context, 'pp_section/' + sectionId);
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
          onSurface: _openSurface,
          onAction: _hubAction,
        ),
      ));
      return;
    }

    void owed(String title, String willHold,
        {String? meanwhile, String? meanwhileWhy, String? surface}) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'pp/owed'),
        builder: (_) => HubOwedScreen(
          title: title,
          willHold: willHold,
          meanwhileLabel: meanwhile,
          meanwhileValue: meanwhileWhy,
          onMeanwhile:
              surface == null ? null : () => _openSurface(context, surface),
        ),
      ));
    }

    void pushWhatChanged(String query) =>
        Navigator.of(context).push(MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'pp/what_changed'),
          builder: (_) => WhatChangedScreen(initialQuery: query),
        ));

    switch (action) {
      case kPpActConsult:
        _openSurface(context, 'pp_experts');

      // ⚠️ PRE-FILTERED, NOT DUMPED IN A LIBRARY. All three of these doors land
      // on the same thirty-concern library, so each one arrives carrying the
      // word she tapped. Prompt §16: do not make her enter information the app
      // already has.
      case kPpActSleepProblem:
        pushWhatChanged('sleep');

      case kPpActFeedingProblem:
        pushWhatChanged('feeding');

      // ⚠️ CATEGORIES, NOT THE WORD "behaviour". Tantrums, clinginess and
      // separation upset are filed under "Mood", so a text match surfaced two
      // concerns out of the handful the door's own blurb names.
      //
      // ⚠️ DEAD, AND NOW SAID SO. `sectionForAction` above returns first for
      // this action, so this arm has never run since Behaviour gained a
      // section. What it meant to do lives on as the surface
      // `pp_what_changed/behaviour` (the Behaviour door's tool), on the
      // brief's judgement call 1 and the user's answer, 2026-09-13. Kept
      // for revert.
      // case kPpActBehaviour:
      //   Navigator.of(context).push(MaterialPageRoute<void>(
      //     settings: const RouteSettings(name: 'pp/what_changed'),
      //     builder: (_) => const WhatChangedScreen(
      //         initialCategories: ['Behaviour', 'Mood']),
      //   ));

      case kPpActPottyReadiness:
        owed('Is my child ready?',
            'The signs that actually matter, and why age is the least useful '
            'of them. Nothing here will tell you your child is behind.',
            meanwhile: 'How your child is developing',
            meanwhileWhy: 'Where they are right now, across areas.',
            surface: 'pp_development');

      case kPpActPottyTraining:
        owed('Start and manage potty training',
            'A plan you can start this week, what to do about accidents and '
            'regressions, and when to simply pause.',
            meanwhile: 'Activities for this age', // R3 (tools pass, 2026-10-25). Was 'Something to do today'.
            meanwhileWhy: 'Activities for where your child is now.',
            surface: 'pp_activities');

      case kPpActSchoolReadiness:
        owed('Prepare for school',
            'What schools actually look for, what to practise at home, and how '
            'to handle the first weeks.',
            meanwhile: 'Something to do today',
            meanwhileWhy: 'Play that builds what school asks for.',
            surface: 'pp_activities');

      case kPpActFirst40Days:
        owed('Follow my First 40 Days',
            'Day by day through the first forty -- for the baby, and for you. '
            'Feeding, healing, visitors, and what is normal.',
            meanwhile: 'Your recovery',
            meanwhileWhy: 'Reading for the first weeks.',
            surface: 'pp_read');

      // ⚠️ WAS THE WHOLE READING LIBRARY, whose hero is hardcoded to an
      // article about the BABY's sleep regression. A mother asking about her
      // own recovery was shown her baby's sleep. Now it opens the one
      // collection that is about her.
      case kPpActMaternalRecovery:
        Navigator.of(context).push(MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'pp/read'),
          builder: (_) =>
              const ReadingHomeScreen(initialCollection: 'The Parent, Too'),
        ));

      case kPpActMaternalConcern:
        owed('Get help with a recovery concern',
            'Pain, bleeding, mood, or something that does not feel right -- '
            'what is usual after birth and what is worth a call.',
            meanwhile: 'Find help near you',
            meanwhileWhy: 'People who work with new mothers.',
            surface: 'pp_find_help');
    }
  }

  void _openJournal(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'pp/journal'),
        // The "Priya" demo, replaced 2026-10-07 by the real journal (from the
        // fork's 57020be). Kept for revert: builder: (_) => const JournalV2Home(),
        builder: (_) => const PpJournalScreen(),
      ));

  void _openCapture(BuildContext context, String prompt) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'pp/journal/capture'),
        builder: (_) => QuickCaptureScreen(prompt: prompt),
      ));

  /// An insight card opens its door page, or the tip itself in the one
  /// reader when no page is linked. Never nothing.
  void _openInsight(BuildContext context, PpHomeInsight c) {
    if (c.link case final link?) {
      _openSurface(context, link);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: 'pp/tip/${c.id}'),
      builder: (_) => PvReaderScreen(read: ppTipAsRead(c.id, c.tip), lang: AppLanguage.english),
    ));
  }

  void _openVideo(BuildContext context, WatchVideo video) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'pp/watch/${video.id}'),
        builder: (_) => WatchPlayerScreen(video: video),
      ));

  /// The "How {name} is doing" detail sheet: video first, then the written
  /// explanation, then "More on this". Same order as the phase section above
  /// it, by the brief's own rule.
  void _showChangeSheet(BuildContext context, PhaseChange change,
      ChildProfileStore child, V2Palette p) {
    final video = change.video;
    final read = change.read;
    final activity = change.activityFor(child.ageInMonths);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.86,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        expand: false,
        builder: (ctx, sc) => Container(
          decoration: BoxDecoration(
            color: p.ground,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
              child: Row(children: [
                const SizedBox(width: 38),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: Icon(Icons.close_rounded, color: p.ink3),
                  splashRadius: 20,
                ),
              ]),
            ),
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 28),
                children: [
                  _Chip(label: change.category, hue: change.hue, p: p),
                  const SizedBox(height: 10),
                  Text(change.title,
                      style: pvFraunces(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                          letterSpacing: -0.6,
                          color: p.ink1)),
                  const SizedBox(height: 16),
                  // 1. Video.
                  if (video != null) ...[
                    _PhaseVideoCard(
                        video: video,
                        p: p,
                        hue: change.hue,
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _openVideo(context, video);
                        }),
                    const SizedBox(height: 18),
                  ],
                  // 2. Text.
                  for (final para in change.paragraphs()) ...[
                    Text(para,
                        style: pvManrope(
                            fontSize: _kBody,
                            fontWeight: FontWeight.w500,
                            height: 1.65,
                            color: p.ink1)),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 12),
                  // 3. More.
                  Text('MORE ON THIS',
                      style: pvManrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: p.action)),
                  const SizedBox(height: 10),
                  if (read != null)
                    _MoreRow(
                        p: p,
                        icon: Icons.menu_book_outlined,
                        hue: 42,
                        title: read.title,
                        sub: 'Article · ${read.minutes} min',
                        onTap: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).push(MaterialPageRoute<void>(
                              settings:
                                  RouteSettings(name: 'pp/read/${read.id}'),
                              builder: (_) =>
                                  ReadingReaderScreen(article: read)));
                        }),
                  if (activity != null)
                    _MoreRow(
                        p: p,
                        icon: Icons.back_hand_outlined,
                        hue: 150,
                        title: activity.title,
                        sub: 'Activity · ${activity.timeLabel}',
                        onTap: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).push(MaterialPageRoute<void>(
                              settings: RouteSettings(
                                  name: 'pp/activity/${activity.id}'),
                              builder: (_) => DevelopmentActivityScreen(
                                  activity: activity)));
                        }),
                  _MoreRow(
                      p: p,
                      icon: Icons.eco_outlined,
                      hue: 268,
                      title: 'Development',
                      sub: 'Everything for ${change.phase.ageLabel}',
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _openSurface(context, 'pp_development');
                      }),
                  const SizedBox(height: 14),
                  Text(
                      'General guidance for this age. Your paediatrician knows '
                      'your child; nothing here replaces that.',
                      style: pvManrope(
                          fontSize: _kMeta, height: 1.5, color: p.ink3)),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // Opens a door's link, or says why it can't (S8, 2026-10-25). Was a silent
  // `if (screen == null) return;`.
  /// The Milestones row under Today (R10): the newest one by name, with its
  /// photo when it has one.
  Widget _milestonesRow(BuildContext context, V2Palette p) {
    final newest = MilestoneStore.instance.newest;
    final ph = newest?.obs.photo;
    return PvListRow(
      key: const ValueKey('pp_home_milestones_row'),
      p: p,
      leading: ph != null && ph.isNotEmpty
          ? StorageImage(ph, width: 40, height: 40, borderRadius: BorderRadius.circular(12))
          : TtcMarkLeading(tab: TtcTabMark.sprout, tint: v2BlockTint(28, p), size: 40),
      title: 'Milestones',
      line: newest == null
          ? 'When you see something new, save it here'
          : 'Newest: ${newest.title} · ${ppShortDate(newest.obs.date)}',
      lineMaxLines: 2,
      onTap: () => _openSurface(context, 'pp_milestones'),
    );
  }

  /// "Seen 2 Aug" for a snapshot that is a milestone she saved, else null.
  String? _seenMeta(String? snapshotTitle) {
    final id = snapshotTitle == null ? null : kSnapshotMilestone[snapshotTitle];
    final obs = id == null ? null : MilestoneStore.instance.observation(id);
    return obs == null ? null : 'Seen ${ppShortDate(obs.date)}';
  }

  void _openSurface(BuildContext context, String surfaceId) =>
      ppPushSurface(context, surfaceId);

  /// Opens what she told us, the way the "Is my baby OK?" list does (PP 20,
  /// 2026-10-28): a fever goes to Fever check, the one fever judge (H1), and
  /// the newborn feeding check to its own screen (`kWcHandOff`). Was a push of
  /// `WcFlowScreen` from both home cards, so a fever saved by Fever check
  /// opened the old fever questions instead.
  void _openChange(BuildContext context, PpChange c) {
    final handOff = kWcHandOff[c.concernId];
    final wc = c.concern;
    if (handOff != null) return _openSurface(context, handOff);
    if (wc == null) return _openSurface(context, 'pp_what_changed');
    Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'pp_what_changed'), builder: (_) => WcFlowScreen(concern: wc)));
  }
}

// -----------------------------------------------------------------------------
//  The hero
// -----------------------------------------------------------------------------

/// The headline unit, chosen by how old the child actually is.
///
/// Under 8 weeks a parent counts days — "eleven days old" — and a week counter
/// sits still for six days out of seven, which is exactly the staleness this
/// hero exists to avoid. After that weeks are the unit people use, and after
/// six months, months.
String _bigAge(ChildProfileStore c) {
  // Clamped to 1. The day a child is born is day one, not day zero — and with
  // the placeholder profile (DOB = today) the unclamped version rendered
  // "Day 0", which is not a thing anybody has ever said about a baby.
  final d = c.ageInDays < 1 ? 1 : c.ageInDays;
  if (d < 56) return d == 1 ? 'Day 1' : 'Day $d';
  if (c.ageInMonths < 6) return '${c.ageInWeeks.round()} weeks';
  return c.ageLabel;
}

/// The other unit, so the big number is never the only thing she is given —
/// and so the two together always answer "how old" however she asks it.
String _subAge(ChildProfileStore c) {
  // Born early (2026-10-07): the corrected age is the other unit, because it
  // is what the phase and the milestones on this page are read by.
  if (c.correctionWeeks != null) return '${c.devAgeInMonths} months corrected';
  final d = c.ageInDays < 1 ? 1 : c.ageInDays;
  final w = c.ageInWeeks.round();
  if (d < 56) return w <= 0 ? 'First week' : (w == 1 ? 'Week 1' : 'Week $w');
  if (c.ageInMonths < 6) return 'Day $d';
  return '$w weeks  ·  Day $d';
}

const _kHeroMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// The header's round button: Pregnancy's `_Round` (v3_preg_hero.dart), so the
/// three homes share one button.
class _HeroRound extends StatelessWidget {
  const _HeroRound({super.key, required this.p, required this.child, required this.onTap, required this.semantic});
  final V2Palette p;
  final Widget child;
  final VoidCallback onTap;
  final String semantic;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: semantic,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.surface.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(color: p.line),
            ),
            child: child,
          ),
        ),
      );
}

// Kept for revert since 2026-10-22 (Wave 6): `_PaintedHero` draws the hero.
// ignore: unused_element
class _Hero extends StatelessWidget {
  const _Hero(
      {required this.phase,
      required this.child,
      required this.p,
      required this.onSpine,
      required this.onSaved,
      required this.onProfile,
      required this.onTalk});

  final AgePhase phase;
  final ChildProfileStore child;
  final V2Palette p;
  final VoidCallback onSpine;
  final VoidCallback onSaved;
  final VoidCallback onProfile;
  final VoidCallback onTalk;

  @override
  Widget build(BuildContext context) {
    // No background of its own — the page carries it. This is only the type.
    // ⚠️ THE HEIGHT FOLLOWS THE TEXT SIZE (2026-10-07). A fixed 300 clipped the
    // hero at large text once the child switch joined it (41px at 1.3x).
    final scale = MediaQuery.textScalerOf(context).scale(10) / 10;
    final extra = (scale - 1).clamp(0.0, 1.0) * 240 + (child.children.length >= 2 ? 36 : 0);
    return SizedBox(
      height: 300 + extra,
      child: Stack(children: [
        SafeArea(
          bottom: false,
          child: Padding(
            // Was fromLTRB(22, 18, 22, 22); 18/10 is TTC's and Pregnancy's, so
            // the header row sits at the same height and inset on all three.
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⚠️ ink2, NOT ink3, AND THE REASON GENERALISES. ink3 (#8B8494)
                // is calibrated to sit on `ground` — a near-neutral. Here it
                // sits on a SATURATED, tinted field, and a grey loses contrast
                // against a chromatic ground faster than against a neutral one
                // of the same lightness, because the eye is separating two
                // signals rather than one. Both small lines in this hero were
                // unreadable for that reason.
                //
                // The fix is not "make it darker until it looks fine" — it is
                // that the tint tier is one step in from what the same type
                // takes on the sheet below. Anything placed on the field takes
                // ink2 where the sheet would take ink3.
                // Saved and profile — parenting V3 had neither, while
                // pregnancy V3 had both. See the note in v3_hero_chrome.dart.
                // ⚠️ THE SAME HEADER ROW AS TTC AND PREGNANCY (2026-10-17, the
                // user: the top-left and top-right buttons "don't align well").
                // Parenting had all three buttons on the right in V3HeroChrome's
                // photo-hero style (no border, white at 0.62, ink1). Now it is
                // Pregnancy's three slots (v3_preg_hero.dart): avatar and Talk
                // left, the date centred, Saved right, in fixed-width sides so
                // the date stays centred, with Pregnancy's round button.
                // Kept for revert:
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: V3HeroChrome(
                //     tone: V3HeroTone.onField,
                //     p: p,
                //     initial: child.nameMid.isEmpty ? '' : child.nameMid[0],
                //     onSaved: onSaved,
                //     onProfile: onProfile,
                //     avatarOpensProfile: true,
                //     onTalk: onTalk,
                //   ),
                // ),
                Builder(builder: (context) {
                  const side = 84.0; // 38 + 8 + 38, Pregnancy's width
                  final today = DateTime.now();
                  final initial = child.nameMid.isEmpty ? '' : child.nameMid[0];
                  return Row(children: [
                    SizedBox(
                      width: side,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          _HeroRound(
                            p: p,
                            semantic: 'Profile',
                            onTap: onProfile,
                            child: initial.isEmpty
                                ? Icon(Icons.person_outline_rounded, size: 18, color: p.ink2)
                                : Text(initial.toUpperCase(),
                                    style: pvJakarta(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
                          ),
                          const SizedBox(width: 8),
                          _HeroRound(
                            p: p,
                            semantic: 'Talk to an expert', // was 'Talk to someone' (2026-10-22)
                            onTap: onTalk,
                            child: Icon(Icons.forum_outlined, size: 17, color: p.ink2),
                          ),
                        ]),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('${today.day} ${_kHeroMonths[today.month - 1]}',
                              style: pvManrope(
                                  fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.1, color: p.ink1)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: side,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _HeroRound(
                          p: p,
                          semantic: 'Saved',
                          onTap: onSaved,
                          child: Icon(Icons.bookmark_border_rounded, size: 18, color: p.ink2),
                        ),
                      ),
                    ),
                  ]);
                }),
                const Spacer(),
                // ⚠️ THE EYEBROW IS THE DOOR TO THE PHASE MAP. It was plain
                // type; nothing on this screen reached the spine at all. The
                // full argument is at the head of v3_hero_chrome.dart — short
                // version: "PHASE 1 OF 20" already implies nineteen others, so
                // the information is the invitation and it only needed to look
                // like the control it should have been.

                // ⚠️ THE BIG FACT IS THE AGE — AND IT HAS TO CHANGE DAILY.
                //
                // "Surviving, together" used to sit here and is gone: it was a
                // mood, and a mood does not change between Tuesday and
                // Wednesday.
                //
                // Then it said "0 weeks" for seven days running, which is the
                // same failure wearing a number. The whole argument for putting
                // information here rather than a picture was that information
                // changes; a unit that only moves once a week does not, and for
                // the first fortnight of a baby's life it is also the wrong
                // unit — nobody says "my baby is 0 weeks old", they say "she is
                // eleven days old".
                //
                // So the unit follows the age: days while days are what she is
                // counting, weeks once weeks are, months after that. And the
                // OTHER unit sits underneath, so the big number is never the
                // only thing she is given.
                // Two or more children: "Aarav ▾" (gap analysis P2, 2026-10-07).
                PpChildSwitch(p: p),
                // Counts up on the first home (pv_home_arrival.dart).
                PvArriveCount(
                    text: _bigAge(child),
                    builder: (s) => Text(s,
                        style: pvFraunces(
                            fontSize: 30, // was 42; Pregnancy's "Week 24" is 30
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                            letterSpacing: -0.75,
                            color: p.ink1))),
                const SizedBox(height: 2),
                Text(_subAge(child),
                    style: pvManrope(
                        fontSize: 12.5, // was 13.5, as Pregnancy's day line
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: p.ink2)),
                const SizedBox(height: 8),
                // One line, scaled down when long (2026-10-13): the phase docs'
                // names run longer ("The World Comes Closer" was "Reaching
                // out"), and a second line overflowed the hero's fixed height.
                // Scaled, never cut — the doc's name is shown whole.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(phase.name,
                      maxLines: 1,
                      style: pvFraunces(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          letterSpacing: -0.4,
                          color: p.ink2)),
                ),
                const SizedBox(height: 14),
                // ⚠️ THE PHASE CHIP LIVES HERE NOW, AND THE LINE THAT WAS HERE
                // IS GONE. Both halves came from one review:
                //
                //   "below the heading the fourth trimester we have 'feeding,
                //    finding a rhythm', whatever route you are on this line
                //    makes absolutely no sense, so there is no need for it. And
                //    that button that says phase 1 of 20 at the very top can be
                //    replaced with this heading, so that positioning can be
                //    changed for that button as it looks a little abrupt on the
                //    top."
                //
                // The line was `phase.workingOn.first` -- one item lifted out of
                // a list of four. Out of context it reads as a fragment, because
                // it IS one: "feeding, finding a rhythm" is a label for a group
                // of things, not a sentence about her baby. The full list is on
                // the phase screen where it has its heading.
                //
                // And the chip was floating at the top of the field with the
                // profile row, above the big age, which is why it read as
                // abrupt: it belongs to the phase, so it sits with the phase
                // name rather than with the chrome.
                V3SpineChip(
                  label:
                      'PHASE ${phase.number} OF 20  ·  ${phase.ageLabel.toUpperCase()}',
                  tone: V3HeroTone.onField,
                  p: p,
                  onTap: onSpine,
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

/// The content sheet that sits ON the field.
///
/// A rounded top and one soft shadow. That shadow is doing the whole job: it is
/// what turns a boundary into an overlap, and an overlap is what people read as
/// "smooth". A gradient between two regions never gets there, however carefully
/// it is tuned — three attempts on the pregnancy hero proved that.
class _Sheet extends StatelessWidget {
  const _Sheet({required this.p, required this.children});

  final V2Palette p;
  final List<Widget> children;

  // The first home rises and its sections follow (pv_home_arrival.dart,
  // 2026-10-18); every other open is exactly as before.
  @override
  Widget build(BuildContext context) => PvArrive.sheet(child: Container(
        // ⚠️ THE SHEET OWNS THE BOTTOM CLEARANCE, NOT THE SCROLL VIEW.
        //
        // The clearance for the floating nav used to be `ListView(padding:
        // bottom 150)`, which put 150 transparent pixels BELOW the sheet —
        // and the field, which now fills the page, showed through them. So
        // scrolling to the end of the last section revealed a band of purple
        // under it. That looked like a rendering bug and was really a
        // question of which widget owns the gap.
        //
        // The general rule: once a background belongs to the PAGE rather than
        // to a section, every piece of padding in the scroll view becomes a
        // window onto it. Padding has to move inside whatever is meant to be
        // opaque.
        //
        // `minHeight` covers the other half — a phase whose sections are short
        // enough that the sheet does not reach the fold would show the same
        // band without it. It is a guard rather than a layout: today's content
        // is far taller.
        constraints: BoxConstraints(
            minHeight: MediaQuery.sizeOf(context).height * 0.72),
        // No card edge since 2026-10-22 (Wave 6): the painted hero fades into
        // the page, so the sheet is the page's own ground, not a card on a
        // field. Kept for revert: the top radius 28 and the shadow
        // BoxShadow(black 0.10, blur 24, offset (0, -6)).
        decoration: BoxDecoration(color: p.ground),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ...pvArriveEach(children),
          // Clearance for the floating bottom nav, inside the opaque sheet.
          const SizedBox(height: 150),
        ]),
      ));
}

// -----------------------------------------------------------------------------
//  Shared pieces — same shapes as pregnancy V3, different content
// -----------------------------------------------------------------------------

class _Head extends StatelessWidget {
  const _Head(
      {required this.eyebrow,
      required this.title,
      required this.p,
      // `note` carried "Prices shown" on the old products head, now commented
      // out. Kept for revert.
      // ignore: unused_element_parameter
      this.note});

  final String eyebrow;
  final String title;
  final String? note;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // An empty eyebrow draws nothing (the door grid's heading has none).
          if (eyebrow.isNotEmpty || note != null) Row(children: [
            Expanded(
              child: Text(eyebrow.toUpperCase(),
                  style: pvManrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: p.action)),
            ),
            if (note != null)
              Text(note!.toUpperCase(),
                  style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: p.ink3)),
          ]),
          if (eyebrow.isNotEmpty || note != null) const SizedBox(height: 6),
          Text(title,
              style: pvFraunces(
                  fontSize: 21, // was 24; v3_sections' head is 21
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                  letterSpacing: -0.5,
                  color: p.ink1)),
        ],
      );
}

// The single "One thing to try" card. Superseded by _TodayActivityCard
// (three a day, with Done and Change). Kept for revert.
// ignore: unused_element
class _ActivityCard extends StatelessWidget {
  const _ActivityCard(
      {required this.activity, required this.p, required this.onTap});

  final DevActivity activity;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(activity.title,
                style: pvFraunces(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    letterSpacing: -0.4,
                    color: p.ink1)),
            const SizedBox(height: 7),
            Text(activity.benefit,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
            const SizedBox(height: 13),
            Row(children: [
              Icon(Icons.schedule_rounded, size: 15, color: p.ink3),
              const SizedBox(width: 6),
              Text('${activity.timeLabel}  ·  ${activity.ageTag}',
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink3)),
            ]),
          ]),
        ),
      );
}

// The 74dp-cover row form. Superseded by the _ReadRail cards. Kept for revert.
// ignore: unused_element
/// A door page as a read row (2026-10-21, Wave 4): the home's reads are three
/// rows now, as TTC's and Pregnancy's are. Same shape as [_ReadRow]: a 74
/// cover, a serif title, one small caps line. The cover is the door's drawn
/// mark on its tint, as the shelf card drew it; the line says why the brain
/// moved it, or which door it is from.
class _DoorReadRow extends StatelessWidget {
  const _DoorReadRow({required this.read, required this.p, required this.onTap, this.why});

  final PpHomeRead read;
  final V2Palette p;
  final VoidCallback onTap;
  final String? why;

  @override
  Widget build(BuildContext context) {
    final mark = bracketMarkFor(read.section.id);
    final tint = v2CoverTint(read.page.id, p);
    final minutes = ppShelfSpecFor(read.page).fact;
    return InkWell(
      key: ValueKey('pp_home_read_${read.page.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 74,
            height: 74,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)),
            child: mark == null
                ? const SizedBox.shrink()
                : SizedBox(width: 44, height: 44, child: V3BracketArt(mark: mark, tint: tint)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ppPageTitle(read.page),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pvFraunces(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      letterSpacing: -0.4,
                      color: p.ink1)),
              const SizedBox(height: 5),
              Text(
                  [
                    (why ?? read.section.title).toUpperCase(),
                    if (minutes != null && minutes.isNotEmpty) minutes.toUpperCase(),
                  ].join(' \u00b7 '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                      fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: p.ink3)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// Its call sites are commented out (kept for revert); _DoorReadRow carries
// its shape for the door reads since 2026-10-21.
// ignore: unused_element
class _ReadRow extends StatelessWidget {
  const _ReadRow({required this.article, required this.p, required this.onTap});

  final ReadArticle article;
  final V2Palette p;
  final VoidCallback onTap;

  // ⚠️ THIS IS PREGNANCY'S `V3ReadRow`, SHAPE FOR SHAPE — 74dp cover, 13dp gap,
  // the same two lines of type at the same sizes. It was a title and a metadata
  // line with no picture at all, which is why the two stages read as different
  // products on the sections they SHARE.
  //
  // Not literally the same widget, because the two stages carry different
  // article models (`ReadArticle` here, `ReadItem` there) and unifying those is
  // a data migration, not a UI change. Where the models agree — the journal
  // section — the widget itself is shared rather than copied. Here the shape is
  // shared and the binding differs, which is the most that can be true today.
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 74,
              height: 74,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: v2CoverTint(article.id, p),
                borderRadius: BorderRadius.circular(12),
              ),
              // The tint is the ground and the photograph sits on it, so a
              // missing image degrades to a coloured square rather than to a
              // hole. Same fallback as pregnancy.
              child: Builder(builder: (_) {
                final url = v2PpReadCover(article.collection);
                if (url == null) return const SizedBox.shrink();
                return Image.network(url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink());
              }),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvFraunces(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            letterSpacing: -0.4,
                            color: p.ink1)),
                    const SizedBox(height: 5),
                    Text(
                        '${readCollectionById(article.collection).title.toUpperCase()} · ${article.minutes} MIN',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: p.ink3)),
                  ]),
            ),
          ]),
        ),
      );
}

// The "Watch" section's card, with title and why inside it. Superseded by
// _PhaseVideoCard, which sits at the top of "This phase explained" with its
// caption under it. Kept for revert.
// ignore: unused_element
class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video, required this.p, required this.onTap});

  final WatchVideo video;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child: Column(children: [
            SizedBox(
              height: 128,
              child: Stack(fit: StackFit.expand, children: [
                ColoredBox(color: v2BlockTint(206, p)),
                Center(
                  child: Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child:
                        Icon(Icons.play_arrow_rounded, size: 26, color: p.ink1),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999)),
                    child: Text('${(video.seconds / 60).ceil()} min',
                        style: pvManrope(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 13, 16, 15),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvFraunces(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: p.ink1)),
                const SizedBox(height: 5),
                Text(video.why,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
              ]),
            ),
          ]),
        ),
      );
}

/// A product category's mark and hue.
///
/// ⚠️ REUSED FROM THE BRACKET SET, NOT DRAWN AGAIN. Every one of the six
/// parenting product categories already has a bracket that means the same
/// thing — sleep IS the moon, feeding IS the bowl, safety IS the steady pulse.
/// Drawing a second bowl for the product rail would give the app two shapes for
/// one idea, which is the point at which an icon language stops being one.
///
/// The hues match the brackets for the same reason: a mother who has just
/// tapped the green Feeding door should meet green again on the feeding
/// products, and if these were assigned by index — which they were, `(26 + i *
/// 53) % 360` — the colour would change depending on WHICH PRODUCTS happened to
/// be in the rail that day.
BracketMark? _productMark(String category) => switch (category) {
      'Sleep' => BracketMark.moon,
      'Feeding' => BracketMark.nutrition,
      'Health & Safety' => BracketMark.complications,
      'Play & Development' => BracketMark.blocks,
      'Skincare' => BracketMark.skin,
      'On the move' => BracketMark.steps,
      _ => null,
    };

double _productHue(String category) => switch (category) {
      'Sleep' => 232,
      'Feeding' => 104,
      'Health & Safety' => 186,
      'Play & Development' => 42,
      'Skincare' => 12,
      'On the move' => 160,
      _ => 268,
    };

/// The design's product card: an image well, the name, a one-line why-now,
/// the price and a chevron. Age-relevant, honest — a card may say "you do not
/// need this yet" — and it opens THAT product, never the shop's front page.
///
/// The image well still draws the category MARK rather than a photograph, for
/// the reason the commented rail below gives at length: `PpProduct.imageUrl`
/// is empty across the catalogue, and a wrong photograph is worse than a
/// colour. `PpProductImage` takes over the day the catalogue has pictures.
// ONE PRODUCT CARD FOR ALL THREE HOMES (2026-10-21, Wave 4; the user chose
// "B: no price"). Pregnancy's V2ProductRail card, shape for shape: 132 wide, a
// 108 picture, the name, no price. A price on the daily home turns a
// suggestion into a listing; the product page still carries it. Not the same
// widget because the models differ (PpProduct here, Product there), the same
// trade _ReadRow below states. The priced card it replaces is
// _ProductRailPriced, kept for revert.
// Superseded by PpCatalogRail (PP 5, 2026-10-28). Kept for revert.
// ignore: unused_element
class _ProductRail extends StatelessWidget {
  const _ProductRail(
      {required this.items, required this.p, required this.onOpen});

  final List<PpProduct> items;
  final V2Palette p;
  final ValueChanged<PpProduct> onOpen;

  @override
  Widget build(BuildContext context) => SizedBox(
        key: const ValueKey('pp_home_products'),
        height: 172 + ((MediaQuery.textScalerOf(context).scale(10) / 10) - 1).clamp(0.0, 1.0) * 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final it = items[i];
            return SizedBox(
              width: 132,
              child: InkWell(
                key: ValueKey('pp_product_${it.id}'),
                onTap: () => onOpen(it),
                borderRadius: BorderRadius.circular(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  PpProductImage(
                    url: it.imageUrl,
                    height: 108,
                    width: 132,
                    radius: 16,
                    border: false,
                    icon: categoryByName(it.category).icon,
                  ),
                  const SizedBox(height: 8),
                  Text(it.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvJakarta(
                          fontSize: 14, fontWeight: FontWeight.w600, height: 1.25, color: p.ink1)),
                ]),
              ),
            );
          },
        ),
      );
}

// ignore: unused_element
class _ProductRailPriced extends StatelessWidget {
  const _ProductRailPriced(
      {required this.items, required this.p, required this.onOpen});

  final List<PpProduct> items;
  final V2Palette p;
  final ValueChanged<PpProduct> onOpen;

  @override
  // The rail grows with the text size (2026-10-07): a fixed 236 clipped the
  // card's foot at large text.
  Widget build(BuildContext context) => SizedBox(
        height: 236 + ((MediaQuery.textScalerOf(context).scale(10) / 10) - 1).clamp(0.0, 1.0) * 90,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final it = items[i];
            final why = it.bestFor.isNotEmpty ? it.bestFor : it.summary;
            return SizedBox(
              width: 158,
              child: InkWell(
                onTap: () => onOpen(it),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: p.line),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 96,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: v2BlockTint(_productHue(it.category), p),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: switch (_productMark(it.category)) {
                            final BracketMark m => SizedBox(
                                width: 46,
                                height: 46,
                                child: V3BracketArt(
                                    mark: m,
                                    tint: v2BlockTint(
                                        _productHue(it.category), p))),
                            null => const SizedBox.shrink(),
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(it.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                                fontSize: _kBody,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                                color: p.ink1)),
                        const SizedBox(height: 4),
                        Text(why,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                                fontSize: _kMeta, height: 1.35, color: p.ink2)),
                        const Spacer(),
                        Row(children: [
                          Expanded(
                            child: Text('₹${it.price}',
                                style: pvManrope(
                                    fontSize: _kBody,
                                    fontWeight: FontWeight.w700,
                                    color: p.ink1)),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 18, color: p.ink3),
                        ]),
                      ]),
                ),
              ),
            );
          },
        ),
      );
}

// The rail this replaces — 132dp cards with no why-line, opening the shop's
// front page rather than the product. Kept for revert:
// class _ProductRail extends StatelessWidget {
//   const _ProductRail(
//       {required this.items, required this.p, required this.onOpen});
//
//   final List<PpProduct> items;
//   final V2Palette p;
//   final VoidCallback onOpen;
//
//   @override
//   Widget build(BuildContext context) => SizedBox(
//         height: 172,
//         child: ListView.separated(
//           scrollDirection: Axis.horizontal,
//           padding: const EdgeInsets.symmetric(horizontal: 18),
//           itemCount: items.length,
//           separatorBuilder: (_, _) => const SizedBox(width: 12),
//           itemBuilder: (context, i) {
//             final it = items[i];
//             return SizedBox(
//               width: 132,
//               child: InkWell(
//                 onTap: onOpen,
//                 borderRadius: BorderRadius.circular(16),
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ⚠️ A DRAWN CATEGORY MARK, NOT A STOCK PHOTOGRAPH — and
//                       // this is the one place where parenting deliberately does
//                       // NOT copy pregnancy.
//                       //
//                       // Pregnancy shows photographs because `Product.imageUrl`
//                       // exists and carries 24 hand-picked ones. `PpProduct` has
//                       // no image field at all, so matching pregnancy would mean
//                       // inventing a per-CATEGORY photo bank — and of the six
//                       // parenting categories only about half have an honest
//                       // match in the images we already own. "On the move" and
//                       // "Health & safety" would get something calm and
//                       // unrelated, which is the failure product_data.dart names
//                       // outright: a wrong photograph is worse than a colour,
//                       // because a photograph is read as THIS product.
//                       //
//                       // The marks are the better answer rather than the
//                       // fallback: they are ours, they are right by
//                       // construction, they need no network, and they are the
//                       // language the eleven doors above already speak. The well
//                       // was bland because it was EMPTY, not because it lacked a
//                       // photograph.
//                       //
//                       // Real product photography replaces this the day the
//                       // catalogue has it — that is a data gap, and it belongs to
//                       // whoever owns the catalogue.
//                       Container(
//                         height: 108,
//                         width: double.infinity,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: v2BlockTint(_productHue(it.category), p),
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: switch (_productMark(it.category)) {
//                           final BracketMark m => SizedBox(
//                               width: 52,
//                               height: 52,
//                               child: V3BracketArt(
//                                   mark: m,
//                                   tint: v2BlockTint(
//                                       _productHue(it.category), p))),
//                           null => const SizedBox.shrink(),
//                         },
//                       ),
//                       const SizedBox(height: 8),
//                       Text(it.name,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: pvJakarta(
//                               fontSize: 12.5,
//                               fontWeight: FontWeight.w600,
//                               height: 1.25,
//                               color: p.ink1)),
//                       const SizedBox(height: 3),
//                       Text('₹${it.price}',
//                           style: pvManrope(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w700,
//                               color: p.ink2)),
//                     ]),
//               ),
//             );
//           },
//         ),
//       );
// }

// -----------------------------------------------------------------------------
//  The spine sections — not brackets, and deliberately so
// -----------------------------------------------------------------------------

/// Four development domains at a glance.
///
/// ⚠️ A GLANCE, NOT A SCORE. Each row is a domain and the word it is currently
/// at — never a bar, a percentage, or a position against other children. The
/// Development door goes deeper on all four; this exists so she can see them
/// without leaving home, which is what V1 does and the first cut of V3 dropped.
// ⚠️ SUPERSEDED 2026-09-16 by _ChangeCard + pp_home_changes.dart. The rows
// here read `DevArea.word`, which is fixed at roughly a four-month-old and
// does not move with the child — the exact opposite of "only what is changing
// at this age". Kept for revert.
// ignore: unused_element
class _Snapshot extends StatelessWidget {
  const _Snapshot({required this.p, required this.onTap});

  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // ⚠️ ALL OF THEM, NOT THE FIRST FOUR.
    //
    // This was `kDevAreas.take(4)`, which is why V3 showed Brain, Language,
    // Physical and Hands while the Current home's child snapshot showed
    // Emotional, Social, Creativity and Self-care as well. The review:
    //
    //   "in V3 we have 'How your baby is doing right now' which contains brain,
    //    language, physical, hands. But that same section is by the name of
    //    child snapshot inside the current screen which has brain, physical,
    //    language, emotional, nutrition, all of which isn't available on the V3
    //    screen... I really wanted symmetry, and no content lost unless told."
    //
    // The `take(4)` was a length decision made on a screen that had fewer
    // sections than it has now, and it silently dropped half the developmental
    // picture. A parent worried about a child who is not smiling looked at a
    // panel that had no row for it.
    final areas = kDevAreas;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: Column(children: [
          for (final a in areas) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(children: [
                // ⚠️ THE DRAWN MARK, NOT `a.icon`. `DevArea.icon` is still a
                // Material glyph and is still used by the development screens,
                // which have not been moved to V3 — this reads the same area
                // and renders it in the language the eleven doors above it are
                // already speaking. Four bought icons directly under eleven
                // drawn ones was the visible seam.
                //
                // `devMarkFor` returns null for an area nobody has drawn, and
                // the glyph is the fallback rather than a blank: an undrawn
                // area should look unfinished, not broken.
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: a.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: switch (devMarkFor(a.id)) {
                    final DevMark m =>
                      V3DevMark(mark: m, accent: a.accent, size: 22),
                    null => Icon(a.icon, size: 17, color: a.accent),
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.shortName.isEmpty ? a.name : a.shortName,
                            style: pvJakarta(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: p.ink1)),
                        const SizedBox(height: 2),
                        // `devWordLabel`, deliberately — and NOT the
                        // `devProgressBar` that sits next to it in
                        // development_common.dart. The word says "Practicing";
                        // the bar says "37% of the way to Confident", which is
                        // a score for a child, and this product does not give
                        // those. The helper exists precisely so the word can be
                        // used without the bar.
                        Text(devWordLabel(a.word),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(fontSize: 12.5, color: p.ink3)),
                      ]),
                ),
                Icon(Icons.chevron_right_rounded, size: 19, color: p.ink3),
              ]),
            ),
            if (a != areas.last)
              Divider(height: 1, thickness: 1, color: p.line, indent: 62),
          ],
        ]),
      ),
    );
  }
}

/// ⚠️ AN ACCORDION, NOT THREE PARAGRAPHS OF TRUNCATED TEXT.
///
/// The review: "the three questions dropdowns are good for them with smooth
/// animations, not just the text lying randomly."
///
/// It was a question in serif with three ellipsised lines under it, repeated
/// three times, and it read as an unfinished article rather than as an answer.
/// Two things were wrong and only one of them was styling:
///
/// * **The answer was cut off with no way to finish it.** `maxLines: 3` with an
///   ellipsis and no tap is a promise the screen cannot keep. Every one of these
///   ended mid-sentence.
/// * **Nothing looked interactive**, so the section read as filler between two
///   real ones.
///
/// Now: closed by default, one open at a time, the full answer on tap. The
/// question stays readable in both states because it is the thing she scans.
///
/// ⚠️ ANIMATED WITH `AnimatedSize` RATHER THAN A HEIGHT TWEEN. The answers are
/// different lengths and none of them is known in advance, so a fixed target
/// height would either clip the long ones or leave a gap under the short ones.
/// `AnimatedSize` measures the real child and animates to it, which is the one
/// approach that cannot be wrong per answer.
/// "This phase explained" — the summary, and the full description on tap.
///
/// Uses the same disclosure vocabulary as the At-this-age accordion rather than
/// inventing a second one: a chevron that turns, `AnimatedSize` over the real
/// child, and no fixed height. Two expanding sections on one screen that behave
/// differently is the drift this app keeps having to undo.
// Superseded 2026-10-07 by _PhaseAtAGlance (summary + three labelled points,
// the full description in the reader). Kept for revert (2026-10-07).
// ignore: unused_element
class _PhaseExplained extends StatelessWidget {
  const _PhaseExplained({
    required this.phase,
    required this.p,
    required this.expanded,
    required this.onToggle,
  });

  final AgePhase phase;
  final V2Palette p;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(phase.summary,
                style: pvManrope(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    height: 1.65,
                    color: p.ink1)),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // The At-this-age block draws feeding, sleep and the
                        // doctor lines itself; not said twice (2026-10-07).
                        for (final sec in phase.sections.where((x) => !ppAtThisAgeOwns(x.heading))) ...[
                          const SizedBox(height: 18),
                          Text(sec.heading,
                              style: pvFraunces(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                  color: p.ink1)),
                          const SizedBox(height: 7),
                          for (final para in sec.paragraphs) ...[
                            Text(para,
                                style: pvManrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.6,
                                    color: p.ink2)),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ],
                    )
                  : // ⚠️ height: 0 IS LOAD-BEARING, NOT TIDINESS.
                      //
                      // This was `SizedBox(width: double.infinity)`, whose height
                      // is unconstrained. Inside `AnimatedSize` that resolves to
                      // an infinite height constraint, which throws
                      // "BoxConstraints forces an infinite height" during layout
                      // and takes the whole sheet down with it -- the field
                      // rendered and nothing else did.
                      //
                      // It cost a while to find because the screen did not crash:
                      // Flutter caught it in the rendering library, logcat carried
                      // nothing, and `flutter analyze` was clean. A blank screen
                      // with a clean build is exactly the shape of a layout
                      // assertion.
                      const SizedBox(width: double.infinity, height: 0),
            ),
            const SizedBox(height: 13),
            Row(children: [
              Flexible(child: Text(expanded ? 'Show less' : 'Read the full description',
                  style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: p.action))),
              const SizedBox(width: 5),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 19, color: p.action),
              ),
            ]),
          ]),
        ),
      );
}

/// "This phase, explained", segregated (2026-10-07).
///
/// The user: "Under This phase explained it's very text heavy, like text
/// thrown. Segregate it, represent it better." It was the summary and, on
/// tap, eight sections of paragraphs unrolled in place. Now: the summary as
/// the lead, then three labelled points, each a drawn mark, a small-caps
/// label and a line or two, then "Read the full description", which opens
/// the WHOLE phase in the one reader (`ppPhaseAsRead`). Nothing is cut; what
/// does not fit lives one tap away, as on a summary card in a health app.
///
/// The three points are the questions a parent brings to an age: what is
/// the child working on, is this normal, and what helps. The doctor lines
/// are not one of them because `PpAtThisAge`, just below, never folds them.
///
/// Mobbin (adopted: a white summary card, a lead line, labelled rows with a
/// small mark each, one link out): Withings Health Mate "Today's Missions",
/// https://mobbin.com/screens/6852bc4c-c9d3-434d-b52f-54521e690076 ; Apple
/// Health's summary card, https://mobbin.com/screens/97104df5-f817-4e56-80a0-0c46eee67e06
// Kept for revert since 2026-10-22 (Wave 6).
// ignore: unused_element
class _PhaseAtAGlance extends StatelessWidget {
  const _PhaseAtAGlance({required this.phase, required this.p, required this.onReadMore});

  final AgePhase phase;
  final V2Palette p;
  final VoidCallback onReadMore;

  /// The first sentence of a section, or null when the phase has none.
  String? _firstSentence(String heading) {
    for (final s in phase.sections) {
      if (s.heading.toLowerCase() != heading || s.paragraphs.isEmpty) continue;
      final para = s.paragraphs.first.trim();
      final m = RegExp(r'^(.+?[.!?])(\s|$)').firstMatch(para);
      return m == null ? para : m.group(1);
    }
    return null;
  }

  Widget _point(String key, TtcTabMark mark, double hue, String label, List<String> lines) => Padding(
        key: ValueKey('pp_phase_point_$key'),
        padding: const EdgeInsets.only(top: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TtcMarkLeading(tab: mark, tint: v2BlockTint(hue, p), size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label.toUpperCase(),
                  style: pvManrope(
                      fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.ink2)),
              const SizedBox(height: 4),
              for (final l in lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(l,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: _kBody, height: 1.45, color: p.ink1)),
                ),
            ]),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final helps = _firstSentence('play that helps now') ?? _firstSentence('what helps');
    return Container(
      key: const ValueKey('pp_phase_glance'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(phase.summary,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: pvManrope(fontSize: _kBody, fontWeight: FontWeight.w500, height: 1.55, color: p.ink1)),
        const SizedBox(height: 4),
        // ⚠️ A PHASE WITH A DOC (1–15 on 2026-10-13, all 20 since 2026-10-16) says what the doc says:
        // `workingOn` is its Living Through This Phase titles, under the
        // doc's own label, and the older "What is normal" line (authored, not
        // in the doc) steps aside. The summary is already the doc's hero.
        if (ppPhaseDocFor(phase.number) != null)
          _point('living', TtcTabMark.sprout, 104, 'Living through this phase', phase.workingOn.toList())
        else ...[
          if (phase.workingOn.isNotEmpty)
            _point('working', TtcTabMark.sprout, 104, 'Working on now', phase.workingOn.take(3).toList()),
          // Authored, so empty on every phase now (doc-only, 2026-10-14).
          if (phase.reassurance.isNotEmpty)
            _point('normal', TtcTabMark.heartHand, 28, 'What is normal', [phase.reassurance]),
        ],
        if (helps != null) _point('helps', TtcTabMark.sun, 42, 'What helps', [helps]),
        const SizedBox(height: 12),
        Divider(height: 1, thickness: 1, color: p.line),
        InkWell(
          key: const ValueKey('pp_phase_read_more'),
          onTap: onReadMore,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(children: [
              Expanded(
                child: Text('Read the full description',
                    style: pvManrope(fontSize: _kBody, fontWeight: FontWeight.w800, color: p.ink1)),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink1),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _FaqRow extends StatefulWidget {
  const _FaqRow(
      {required this.faq,
      required this.p,
      this.open = false,
      this.last = false,
      this.onTap});

  final PhaseFaq faq;
  final V2Palette p;
  final bool open;

  /// The last row in the group draws no hairline under itself.
  final bool last;
  final VoidCallback? onTap;

  @override
  State<_FaqRow> createState() => _FaqRowState();
}

class _FaqRowState extends State<_FaqRow> {
  /// A white row in a white group: the question in ink, a chevron that
  /// turns, the answer under it, a hairline between rows. No fill changes
  /// when a row opens (2026-10-07, the user did not like the lavender).
  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final open = widget.open;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Text(widget.faq.question,
                    style: pvFraunces(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        letterSpacing: -0.3,
                        color: p.ink1)),
              ),
              const SizedBox(width: 10),
              AnimatedRotation(
                turns: open ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 21, color: p.ink1),
              ),
            ]),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: open
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(widget.faq.answer,
                          style: pvManrope(
                              fontSize: _kBody,
                              height: 1.6,
                              color: p.ink2)),
                    )
                  // height: 0 is load-bearing; see _buildBefore below.
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ]),
        ),
      ),
      if (!widget.last)
        Divider(height: 1, thickness: 1, color: p.line, indent: 16),
    ]);
  }

  // The tinted-pill row (surfaceAlt fill when closed). Kept for revert
  // (2026-10-07).
  // ignore: unused_element
  Widget _buildBefore(BuildContext context) {
    final p = widget.p;
    final open = widget.open;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
          decoration: BoxDecoration(
            color: open ? p.surface : p.surfaceAlt,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: open ? p.line : Colors.transparent),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Text(widget.faq.question,
                    style: pvFraunces(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        letterSpacing: -0.3,
                        color: p.ink1)),
              ),
              const SizedBox(width: 10),
              // A quiet chevron that turns. The only moving part, and it is the
              // one that says "there is more".
              AnimatedRotation(
                turns: open ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 21, color: open ? p.action : p.ink3),
              ),
            ]),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: open
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(widget.faq.answer,
                          style: pvManrope(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              height: 1.6,
                              color: p.ink2)),
                    )
                  : // ⚠️ height: 0 IS LOAD-BEARING, NOT TIDINESS.
                      //
                      // This was `SizedBox(width: double.infinity)`, whose height
                      // is unconstrained. Inside `AnimatedSize` that resolves to
                      // an infinite height constraint, which throws
                      // "BoxConstraints forces an infinite height" during layout
                      // and takes the whole sheet down with it -- the field
                      // rendered and nothing else did.
                      //
                      // It cost a while to find because the screen did not crash:
                      // Flutter caught it in the rendering library, logcat carried
                      // nothing, and `flutter analyze` was clean. A blank screen
                      // with a clean build is exactly the shape of a layout
                      // assertion.
                      const SizedBox(width: double.infinity, height: 0),
            ),
          ]),
        ),
      ),
    );
  }
}

/// "Looking ahead", redrawn (2026-10-07).
///
/// The user: "Looking ahead ... purple left line, I don't like it. The
/// representation should be better." A white card with a hairline, a drawn
/// mark in its well, the next phase's age as meta, its name as the card
/// title, one line (its tagline), and an ink "See what's next" link. No
/// accent spine, no accent colour at all: the phase accents are all the
/// brand purple (pp_phases_data.dart), which is exactly what the user saw.
///
/// Mobbin (adopted: a white status card, title, one line, an arrow out):
/// Superpower's "We received your sample",
/// https://mobbin.com/screens/5c8e11ba-1d6e-4802-be01-f0fd16217455 ; the
/// next-stage peek as Oura's "Good to know in Week 40",
/// https://mobbin.com/screens/4ccc949c-fa00-41db-a72e-67f4e19f214e
// Kept for revert since 2026-10-22 (Wave 6).
// ignore: unused_element
class _AheadCard extends StatelessWidget {
  // ignore: unused_element_parameter
  const _AheadCard({required this.next, required this.p, this.onTap});

  final AgePhase next;
  final V2Palette p;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        key: const ValueKey('pp_home_ahead'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TtcMarkLeading(tab: TtcTabMark.sunrise, tint: v2BlockTint(42, p), size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('NEXT · ${next.ageLabel.toUpperCase()}',
                    style: pvManrope(
                        fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.ink3)),
                const SizedBox(height: 5),
                Text(next.name,
                    style: pvFraunces(
                        fontSize: _kCardTitle,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        letterSpacing: -0.4,
                        color: p.ink1)),
                const SizedBox(height: 4),
                // Doc-only phases carry no tagline (2026-10-14): the doc's own
                // opening line instead. Was Text(next.tagline, ...).
                Text(next.tagline.isNotEmpty ? next.tagline : next.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: _kBody, height: 1.45, color: p.ink2)),
                if (onTap != null) ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    Flexible(
                      child: Text("See what's next",
                          style: pvManrope(
                              fontSize: _kBody, fontWeight: FontWeight.w800, color: p.ink1)),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: p.ink1),
                  ]),
                ],
              ]),
            ),
          ]),
        ),
      );
}

// The accent-spine card. Superseded 2026-10-07 by the white card above.
// Kept for revert (2026-10-07).
// ignore: unused_element
class _AheadCardBefore extends StatelessWidget {
  const _AheadCardBefore(
      {required this.next,
      required this.p,
      // ignore: unused_element_parameter
      this.onTap});

  final AgePhase next;
  final V2Palette p;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // ⚠️ THIS WAS A FLAT PURPLE-TINTED SLAB WITH THREE ELLIPSISED LINES ON IT.
    //
    // The review: "a purple shadow card which again makes no sense, it again
    // screams purple and I don't want it... looking ahead basically is the user
    // able to read what's gonna be in the next phase, so that can be
    // incorporated with a better interface, as it's something that is indicating
    // to do something."
    //
    // Both halves are fair. The old card took the phase's accent at 10% and used
    // it as a full-bleed fill, which is the "brand colour as interface colour"
    // mistake `v2_palette.dart` argues against -- and it truncated the one thing
    // the section exists to show. It also had no affordance at all: a block of
    // cut-off text that looks tappable and is not.
    //
    // So it is now a real card on the surface with a hairline, the accent
    // appearing only as a narrow spine and a small dot rather than as the
    // ground, the summary given room to breathe, and an explicit "See what
    // changes" action -- because this section is a door forward, and a door
    // should look like one.
    final accent = HSLColor.fromColor(next.accent)
        .withSaturation(0.46)
        .withLightness(0.52)
        .toColor();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        // ⚠️ THE SPINE TOOK THREE TRIES AND EACH FAILURE IS WORTH KNOWING.
        //
        //  1. `Row(crossAxisAlignment: .stretch)` with a 4px Container. Stretch
        //     asks children for an infinite height when the Row has no bounded
        //     height, so it threw during layout and took the whole sheet down.
        //     That is why the screen went blank with a clean analyze and no
        //     logcat entry: a layout assertion is caught by the framework.
        //  2. A coloured left `BorderSide`. Flutter refuses -- "a borderRadius
        //     can only be given on borders with uniform colors" -- and this card
        //     is rounded.
        //  3. A `Positioned` strip in a clipped Stack, which is this. The Stack
        //     is sized by the padded Row; top + bottom + width makes the strip
        //     match that height without asking anything to stretch.
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: p.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: ColoredBox(color: accent)),
          Row(children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 16, 15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            color: accent, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(next.ageLabel.toUpperCase(),
                          style: pvManrope(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.3,
                              color: p.ink3)),
                    ]),
                    const SizedBox(height: 9),
                    // ⚠️ FIVE LINES, NOT THREE. The point of the section is that
                    // she can read what is coming; cutting it at three lines
                    // meant every phase ended mid-sentence.
                    Text(next.summary,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.55,
                            color: p.ink2)),
                    if (onTap != null) ...[
                      const SizedBox(height: 13),
                      Row(children: [
                        Flexible(
                          child: Text('See what changes',
                              style: pvManrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: accent)),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded,
                            size: 15, color: accent),
                      ]),
                    ],
                  ]),
            ),
          ),
          ]),
        ]),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  The 2026-09-16 design's pieces
// -----------------------------------------------------------------------------

/// A small format chip: "BRAIN", "ARTICLE · 4 MIN", "SWAPPED".
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.p, this.hue, this.icon});

  final String label;
  final V2Palette p;

  /// Tinted on the pastel wheel when given; the quiet surfaceAlt otherwise.
  final double? hue;
  final IconData? icon;

  // ⚠️ `widthFactor: 1` IS THE WHOLE FIX. On the phone this chip stretched to
  // the full width of the change sheet: a ListView hands its children a
  // TIGHT cross-axis width, and a Container obeys it. `Align` with a width
  // factor sizes itself to its child instead, whatever the parent offers, so
  // the chip is the width of its word in a Column, a ListView or a Wrap.
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        widthFactor: 1,
        heightFactor: 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: hue == null ? p.surfaceAlt : v2BlockTint(hue!, p),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Icon(icon, size: 11, color: hue == null ? p.ink3 : p.ink1),
              const SizedBox(width: 5),
            ],
            // Flexible + ellipsis: a chip must shrink before it can overflow.
            // "SUPPLEMENTS" in a 158dp card was 2.6px over under the test
            // font's square glyphs, and a chip that can overflow at all will
            // do it on somebody's large-text setting.
            Flexible(
              child: Text(label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: hue == null ? p.ink3 : p.ink1)),
            ),
          ]),
        ),
      );
}

/// The 16:9 video card at the top of "This phase explained" and of the
/// change sheet: a tinted cover, a play button, a duration chip, and the
/// title as a caption UNDER the card rather than inside it.
class _PhaseVideoCard extends StatelessWidget {
  const _PhaseVideoCard(
      {required this.video, required this.p, required this.onTap, this.hue});

  final WatchVideo video;
  final V2Palette p;
  final VoidCallback onTap;
  final double? hue;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue ?? 273, p);
    final deep = HSLColor.fromColor(tint).withLightness(0.72).toColor();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(fit: StackFit.expand, children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.7, -0.85),
                    radius: 1.5,
                    colors: [tint, deep],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 54,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Icon(Icons.play_arrow_rounded,
                      size: 30, color: p.action),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.58),
                      borderRadius: BorderRadius.circular(999)),
                  child: Text('${(video.seconds / 60).ceil()} MIN',
                      style: pvManrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: Colors.white)),
                ),
              ),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Text(video.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: pvManrope(fontSize: _kMeta, height: 1.45, color: p.ink3)),
    ]);
  }
}

class _Resource {
  const _Resource(
      {required this.label,
      required this.hue,
      required this.icon,
      required this.onTap,
      this.mark});
  final String label;
  final double hue;
  final IconData icon;
  final VoidCallback onTap;

  /// The TTC drawn mark, as pregnancy's "Tools for this week" tiles draw
  /// theirs (2026-10-07). `icon` is kept for revert.
  final TtcTabMark? mark;
}

/// The row of further resources under the phase text: compact cards, a
/// tinted mark, a label and a chevron. Every card opens something real.
class _ResourceRail extends StatelessWidget {
  const _ResourceRail({required this.p, required this.items});

  final V2Palette p;
  final List<_Resource> items;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 96,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, i) {
            final it = items[i];
            return SizedBox(
              width: 170,
              child: InkWell(
                onTap: it.onTap,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: p.line),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // The drawn mark, one ParentVeda (2026-10-07). Kept
                        // for revert: the Material icon in a tinted square.
                        if (it.mark case final m?)
                          TtcMarkLeading(tab: m, tint: v2BlockTint(it.hue, p), size: 34)
                        else
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: v2BlockTint(it.hue, p),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(it.icon, size: 18, color: p.ink2),
                          ),
                        const Spacer(),
                        Row(children: [
                          Expanded(
                            child: Text(it.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: pvManrope(
                                    fontSize: _kBody,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                    color: p.ink1)),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 18, color: p.ink3),
                        ]),
                      ]),
                ),
              ),
            );
          },
        ),
      );
}

/// One "How {name} is doing" card: category chip, the change, one line, and
/// "See what changes ›". Tapping opens the video → text → more sheet.
// Kept for revert since 2026-10-22 (Wave 6).
// ignore: unused_element
class _ChangeCard extends StatelessWidget {
  const _ChangeCard(
      {required this.change, required this.p, required this.onTap});

  final PhaseChange change;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Chip(label: change.category, hue: change.hue, p: p),
            const SizedBox(height: 10),
            Text(change.title,
                style: pvFraunces(
                    fontSize: _kCardTitle,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    letterSpacing: -0.4,
                    color: p.ink1)),
            const SizedBox(height: 6),
            Text(change.notice,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(fontSize: _kBody, height: 1.5, color: p.ink2)),
            const SizedBox(height: 12),
            Row(children: [
              Flexible(
                child: Text('See what changes',
                    style: pvManrope(
                        fontSize: _kBody,
                        fontWeight: FontWeight.w700,
                        color: p.action)),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 17, color: p.action),
            ]),
          ]),
        ),
      );
}

/// A row in the change sheet's "More on this" list.
class _MoreRow extends StatelessWidget {
  const _MoreRow(
      {required this.p,
      required this.icon,
      required this.hue,
      required this.title,
      required this.sub,
      required this.onTap});

  final V2Palette p;
  final IconData icon;
  final double hue;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.line),
            ),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: v2BlockTint(hue, p),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 19, color: p.ink2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: _kBody,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              color: p.ink1)),
                      const SizedBox(height: 3),
                      Text(sub,
                          style: pvManrope(
                              fontSize: _kMeta, height: 1.3, color: p.ink3)),
                    ]),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ]),
          ),
        ),
      );
}

/// An empty section's invitation. A feature is never hidden; only the copy
/// changes.
class _EmptyInvite extends StatelessWidget {
  const _EmptyInvite(
      {required this.p,
      required this.line,
      required this.cta,
      required this.onTap});

  final V2Palette p;
  final String line;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(line,
                style: pvManrope(fontSize: _kBody, height: 1.5, color: p.ink2)),
            const SizedBox(height: 10),
            Row(children: [
              Text(cta,
                  style: pvManrope(
                      fontSize: _kBody,
                      fontWeight: FontWeight.w700,
                      color: p.action)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 17, color: p.action),
            ]),
          ]),
        ),
      );
}

/// The TTC drawn mark and well hue for a development area, one per area, so
/// the home's activity cards speak the same mark language as the pregnancy
/// home's tools rows (2026-10-07). Hues stay off the purple band.
(TtcTabMark, double) ppActivityMark(String areaId) => switch (areaId) {
      'cognitive' => (TtcTabMark.magnifier, 42),
      'language' => (TtcTabMark.twoBubbles, 188),
      'gross_motor' => (TtcTabMark.flagPath, 104),
      'fine_motor' => (TtcTabMark.heartHand, 28),
      'emotional' => (TtcTabMark.bigSmallHearts, 344),
      'social' => (TtcTabMark.twoCircles, 206),
      'creativity' => (TtcTabMark.sprout, 150),
      'selfcare' => (TtcTabMark.bowl, 12),
      _ => (TtcTabMark.openBook, 42),
    };

/// One of today's three activities.
///
/// Three states, per the brief: to do (a "Done" pill and a quiet "Change"),
/// done (dimmed, a filled tick, "Done today", stays until tomorrow), and just
/// swapped in (a small "Swapped" chip beside the title). No counter anywhere.
// Kept for revert since 2026-10-22 (Wave 6).
// ignore: unused_element
class _TodayActivityCard extends StatelessWidget {
  const _TodayActivityCard({
    required this.activity,
    required this.p,
    required this.done,
    required this.swapped,
    required this.onDone,
    required this.onChange,
    required this.onOpen,
  });

  final DevActivity activity;
  final V2Palette p;
  final bool done;
  final bool swapped;
  final VoidCallback onDone;
  final VoidCallback onChange;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final area = devAreaById(activity.areaId);
    // The area accent's hue tinted the old square; the drawn mark carries its
    // own hue now (ppActivityMark). Kept for revert:
    //   final hue = HSLColor.fromColor(area.accent).hue;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: done ? 0.58 : 1,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // The TTC drawn mark for the activity's area (2026-10-07; the
              // user: "use the latest marks or glyphs; these seem outdated").
              // Kept for revert: a 40dp tinted square holding
              // V3DevMark(mark: devMarkFor(area.id), accent: area.accent)
              // or Icon(area.icon), on v2BlockTint(hue, p).
              TtcMarkLeading(
                  key: ValueKey('pp_activity_mark_${area.id}'),
                  tab: ppActivityMark(area.id).$1,
                  tint: v2BlockTint(ppActivityMark(area.id).$2, p),
                  size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(activity.title,
                                style: pvFraunces(
                                    fontSize: _kCardTitle,
                                    fontWeight: FontWeight.w600,
                                    height: 1.25,
                                    letterSpacing: -0.4,
                                    color: p.ink1)),
                            if (swapped)
                              _Chip(
                                  label: 'Swapped',
                                  icon: Icons.refresh_rounded,
                                  p: p),
                          ]),
                      const SizedBox(height: 5),
                      Text(activity.benefit,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: _kBody, height: 1.5, color: p.ink2)),
                      const SizedBox(height: 8),
                      Text('${activity.timeLabel}  ·  ${activity.ageTag}',
                          style: pvManrope(fontSize: _kMeta, color: p.ink3)),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          if (done)
            Container(
              height: 38,
              padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: Color(0xFF2E9E6B), shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text('Done today',
                    style: pvManrope(
                        fontSize: _kBody,
                        fontWeight: FontWeight.w700,
                        color: p.ink2)),
              ]),
            )
          else
            // A Wrap, not a Row (2026-10-07): at large text Change drops to the
            // next line instead of running off the card.
            Wrap(spacing: 10, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
              InkWell(
                onTap: onDone,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: p.line, width: 1.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_rounded, size: 16, color: p.ink1),
                    const SizedBox(width: 7),
                    Text('Done',
                        style: pvManrope(
                            fontSize: _kBody,
                            fontWeight: FontWeight.w700,
                            color: p.ink1)),
                  ]),
                ),
              ),
              InkWell(
                onTap: onChange,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.refresh_rounded, size: 16, color: p.ink2),
                    const SizedBox(width: 7),
                    Text('Change',
                        style: pvManrope(
                            fontSize: _kBody,
                            fontWeight: FontWeight.w700,
                            color: p.ink2)),
                  ]),
                ),
              ),
            ]),
        ]),
      ),
    );
  }
}

/// The reads rail: a cover band, a format chip, the title, one line.
class _ReadRail extends StatelessWidget {
  const _ReadRail({required this.items, required this.p, required this.onOpen});

  final List<ReadArticle> items;
  final V2Palette p;
  final ValueChanged<ReadArticle> onOpen;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 212,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final r = items[i];
            final url = v2PpReadCover(r.collection);
            return SizedBox(
              width: 216,
              child: InkWell(
                onTap: () => onOpen(r),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: p.line),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // The tint is the ground and the photograph sits on
                        // it, so a missing image degrades to a colour band
                        // rather than to a hole.
                        SizedBox(
                          height: 84,
                          width: double.infinity,
                          child: ColoredBox(
                            color: v2CoverTint(r.id, p),
                            child: url == null
                                ? null
                                : Image.network(url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        const SizedBox.shrink()),
                          ),
                        ),
                        // ⚠️ THE TEASER IS `Expanded`, THE TITLE IS NOT. The
                        // card is a fixed height inside a horizontal rail, a
                        // title runs one line or two, and a teaser that always
                        // asks for two lines overflows by 12px under a two-line
                        // title (the widget test caught it). So the title takes
                        // what it needs and the teaser fills whatever is left —
                        // two lines under a short title, one under a long one,
                        // never a stripe.
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Chip(
                                      label: 'Article · ${r.minutes} min',
                                      p: p),
                                  const SizedBox(height: 9),
                                  Text(r.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: pvFraunces(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          height: 1.25,
                                          letterSpacing: -0.3,
                                          color: p.ink1)),
                                  const SizedBox(height: 5),
                                  Expanded(
                                    child: Text(r.teaser,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: pvManrope(
                                            fontSize: _kMeta,
                                            height: 1.4,
                                            color: p.ink2)),
                                  ),
                                ]),
                          ),
                        ),
                      ]),
                ),
              ),
            );
          },
        ),
      );
}

/// "Record a memory for your child today": a photo square on the left, a
/// prompt and four entry chips on the right, "Open the journal ›" under it.
// Kept for revert (2026-10-17): the home now uses the shared V3JournalSection.
// ignore: unused_element
class _JournalInvite extends StatelessWidget {
  const _JournalInvite({
    required this.p,
    required this.onPhoto,
    required this.onMilestone,
    required this.onThought,
    required this.onMoment,
    required this.onOpenAll,
  });

  final V2Palette p;
  final VoidCallback onPhoto;
  final VoidCallback onMilestone;
  final VoidCallback onThought;
  final VoidCallback onMoment;
  final VoidCallback onOpenAll;

  Widget _chip(String label, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        // ⚠️ NO `alignment:` HERE. A Container with an alignment fills the
        // width it is offered, and inside a Wrap that is the whole run — on
        // the phone the four chips stacked one per line, each full width.
        // Padding alone lets the word set the size.
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: p.line, width: 1.2),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: _kMeta, fontWeight: FontWeight.w700, color: p.ink2)),
        ),
      );

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InkWell(
              onTap: onPhoto,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 92,
                height: 92,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.black.withValues(alpha: 0.14)),
                ),
                child: Icon(Icons.photo_camera_outlined,
                    size: 26, color: p.ink3),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'A first smile, a milestone, a thought, or just how '
                        'today felt.',
                        style: pvManrope(
                            fontSize: _kBody, height: 1.5, color: p.ink2)),
                    const SizedBox(height: 10),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      _chip('Photo', onPhoto),
                      _chip('Milestone', onMilestone),
                      _chip('Thought', onThought),
                      _chip('Moment', onMoment),
                    ]),
                  ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onOpenAll,
          borderRadius: BorderRadius.circular(8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: Text('Open the journal',
                  style: pvManrope(
                      fontSize: _kBody,
                      fontWeight: FontWeight.w700,
                      color: p.action)),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 17, color: p.action),
          ]),
        ),
      ]);
}

// -----------------------------------------------------------------------------
//  The painted hero and the activity rows (2026-10-22, Wave 6)
// -----------------------------------------------------------------------------

/// "Aarav is 2 weeks old": days while days are counted, weeks to six months,
/// then the age label, the same units `_bigAge` follows.
String _ageSentence(ChildProfileStore c) {
  final d = c.ageInDays < 1 ? 1 : c.ageInDays;
  final age = d < 56
      ? (d == 1 ? '1 day' : '$d days')
      : (c.ageInMonths < 6 ? '${c.ageInWeeks.round()} weeks' : c.ageLabel);
  final name = c.nameMid;
  final who = name.isEmpty ? 'Your baby' : '${name[0].toUpperCase()}${name.substring(1)}';
  return '$who is $age old';
}

/// When the next phase starts, in words: "in about 2 weeks".
String _nextIn(ChildProfileStore c, AgePhase next) {
  final days = (next.startMonth * 30.44 - c.ageInDays).round();
  if (days <= 7) return 'within a week';
  if (days < 56) return 'in about ${(days / 7).round()} weeks';
  return 'in about ${(days / 30.44).round()} months';
}

/// The hero, painted (2026-10-22, Wave 6; the user: the parenting hero "seems
/// very bland"). The phase painting fills the top and fades into the page, as
/// Pregnancy's baby art fades into its field; on it, the same header row as
/// the other two homes. Under it: the child's name and age, the phase, a
/// strip of the twenty phases with this one in ink (the Wonder Weeks sense of
/// "where are we", without their chart), and one way into the phase page.
class _PaintedHero extends StatelessWidget {
  const _PaintedHero({
    required this.phase,
    required this.next,
    required this.child,
    required this.p,
    required this.onSpine,
    required this.onSaved,
    required this.onProfile,
    required this.onTalk,
    required this.onMessages,
    required this.onCalendar,
    this.unreadMessages = 0,
  });

  final AgePhase phase;
  final AgePhase? next;
  final ChildProfileStore child;
  final V2Palette p;
  final VoidCallback onSpine;
  final VoidCallback onSaved;
  final VoidCallback onProfile;
  final VoidCallback onTalk;
  final VoidCallback onMessages;
  final VoidCallback onCalendar;
  final int unreadMessages;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final today = DateTime.now();
    final initial = child.nameMid.isEmpty ? '' : child.nameMid[0];
    final count = kPhases.length;
    const side = 84.0; // 38 + 8 + 38, Pregnancy's width
    return ColoredBox(
      color: p.ground,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          height: 250 + top,
          child: Stack(fit: StackFit.expand, children: [
            PvPress(child: GestureDetector(
              key: const ValueKey('pp_hero_painting'),
              onTap: onSpine,
              child: PhasePainting(phase: phase),
            )),
            // The fade into the page: the picture has no bottom edge.
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.45, 1],
                    colors: [p.ground.withValues(alpha: 0), p.ground],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              top: top + 10,
              child: Row(children: [
                SizedBox(
                  width: side,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _HeroRound(
                        p: p,
                        semantic: 'Profile',
                        onTap: onProfile,
                        child: initial.isEmpty
                            ? Icon(Icons.person_outline_rounded, size: 18, color: p.ink2)
                            : Text(initial.toUpperCase(),
                                style: pvJakarta(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
                      ),
                      const SizedBox(width: 8),
                      _HeroRound(
                        p: p,
                        semantic: 'Talk to an expert', // was 'Talk to someone' (2026-10-22)
                        onTap: onTalk,
                        child: Icon(Icons.forum_outlined, size: 17, color: p.ink2),
                      ),
                    ]),
                  ),
                ),
                // The family switch (2026-10-25): "Aarav ▾" over the date
                // with two or more profiles, in the same pill that keeps the
                // date readable on the painting; the date alone otherwise.
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: p.surface.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: PvFamilyTitle(
                        p: p,
                        here: FamilyHome.parenting,
                        dateText: '${today.day} ${_kHeroMonths[today.month - 1]}',
                        date: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('${today.day} ${_kHeroMonths[today.month - 1]}',
                              style: pvManrope(fontSize: 13, fontWeight: FontWeight.w800, color: p.ink1)),
                        ),
                      ),
                    ),
                  ),
                ),
                // Messages and Calendar, as on TTC and Pregnancy (2026-10-25).
                // Kept for revert, the Saved button that stood here:
                // SizedBox(
                //   width: side,
                //   child: Align(
                //     alignment: Alignment.centerRight,
                //     child: _HeroRound(
                //       p: p,
                //       semantic: 'Saved',
                //       onTap: onSaved,
                //       child: Icon(Icons.bookmark_border_rounded, size: 18, color: p.ink2),
                //     ),
                //   ),
                // ),
                SizedBox(
                  width: side,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Stack(clipBehavior: Clip.none, children: [
                        _HeroRound(
                          key: const ValueKey('pp_hero_messages'),
                          p: p,
                          semantic: unreadMessages > 0 ? 'Messages, $unreadMessages unread' : 'Messages',
                          onTap: onMessages,
                          child: Icon(Icons.mail_outline_rounded, size: 18, color: p.ink2),
                        ),
                        if (unreadMessages > 0)
                          Positioned(
                            top: -3,
                            right: -3,
                            child: IgnorePointer(
                              child: Container(
                                key: const ValueKey('pp_hero_messages_count'),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: Color(0xFF2F2C30), shape: BoxShape.circle),
                                child: Text(unreadMessages > 9 ? '9+' : '$unreadMessages',
                                    style: pvManrope(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white)),
                              ),
                            ),
                          ),
                      ]),
                      const SizedBox(width: 8),
                      _HeroRound(
                        key: const ValueKey('pp_hero_calendar'),
                        p: p,
                        semantic: 'Calendar',
                        onTap: onCalendar,
                        child: Icon(Icons.calendar_today_rounded, size: 17, color: p.ink2),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // The child switch moved into the header's centre (2026-10-25,
            // pv_family_switch.dart), so a second "Aarav ▾" here would be
            // two controls for one thing. Kept for revert:
            // PpChildSwitch(p: p),
            Text(_ageSentence(child),
                key: const ValueKey('pp_hero_age'),
                style: pvFraunces(
                    fontSize: 28, fontWeight: FontWeight.w600, height: 1.12, letterSpacing: -0.6, color: p.ink1)),
            const SizedBox(height: 6),
            Text('Phase ${phase.number} of $count · ${phase.ageLabel}',
                style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink2)),
            const SizedBox(height: 2),
            Text(phase.name,
                style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
            const SizedBox(height: 12),
            Semantics(
              label: 'Phase ${phase.number} of $count',
              child: Row(key: const ValueKey('pp_hero_strip'), children: [
                for (var i = 1; i <= count; i++) ...[
                  if (i > 1) const SizedBox(width: 3),
                  Expanded(
                    child: Container(
                      height: i == phase.number ? 7 : 5,
                      decoration: BoxDecoration(
                        color: i == phase.number
                            ? p.ink1
                            : (i < phase.number ? p.ink3.withValues(alpha: 0.45) : p.line),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ]),
            ),
            if (next case final n?) ...[
              const SizedBox(height: 6),
              Text('Next: ${n.name}, ${_nextIn(child, n)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontSize: 11.5, color: p.ink3)),
            ],
            const SizedBox(height: 14),
            Semantics(
              button: true,
              child: PvPress(
                child: GestureDetector(
                  key: const ValueKey('pp_hero_open_phase'),
                  onTap: onSpine,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(color: p.ink1, borderRadius: BorderRadius.circular(999)),
                    child: Text('Open this phase  ›',
                        style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

/// An activity's drawn mark in a tinted circle, until it has a painting: the
/// raised first card's fallback (PP 7), the same mark the rows draw.
Widget _activityMark(DevActivity a, V2Palette p, double size) => switch (devMarkFor(a.areaId)) {
      final m? => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: v2BlockTint(38, p), shape: BoxShape.circle),
          child: V3DevMark(mark: m, accent: devAreaById(a.areaId).accent, size: size * 0.7),
        ),
      null => TtcMarkLeading(tab: TtcTabMark.sprout, tint: v2BlockTint(38, p), size: size),
    };

/// Today's three activities as rows: the area's drawn mark, the title, one
/// line, a round check for done. A press and hold swaps one.
class _ActivityRows extends StatelessWidget {
  const _ActivityRows({required this.activities, required this.p, required this.onOpen, required this.onSwap, required this.why});
  final List<DevActivity> activities;
  final V2Palette p;
  final ValueChanged<DevActivity> onOpen;
  final ValueChanged<DevActivity> onSwap;

  /// "Because you said: ..." for a row what she told us raised (PP 4); the
  /// row shows it in place of its meta line.
  final String? Function(DevActivity) why;

  @override
  Widget build(BuildContext context) {
    final store = PpHomeActivitiesStore.instance;
    return PvRowGroup(key: const ValueKey('pp_home_activities'), p: p, children: [
      for (final a in activities)
        PvPress(child: GestureDetector(
          key: ValueKey('pp_home_activity_${a.id}'),
          onLongPress: () {
            onSwap(a);
            pvToast(context, 'Swapped for another activity.');
          },
          child: PvListRow(
            p: p,
            // The activity's painting once it has one (2026-10-23, Wave 8);
            // the drawn mark until then.
            leading: PpActivityThumb(
              activityId: a.id,
              fallback: switch (devMarkFor(a.areaId)) {
                final m? => Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: v2BlockTint(38, p), shape: BoxShape.circle),
                    child: V3DevMark(mark: m, accent: devAreaById(a.areaId).accent, size: 28),
                  ),
                null => TtcMarkLeading(tab: TtcTabMark.sprout, tint: v2BlockTint(38, p), size: 40),
              },
            ),
            title: ppFillChild(a.title),
            // Kept for revert: line: a.metaLine,
            line: why(a) ?? a.metaLine,
            trailing: Semantics(
              button: true,
              label: store.isDone(a.id) ? 'Done' : 'Mark as done',
              child: PvPress(child: GestureDetector(
                key: ValueKey('pp_home_activity_done_${a.id}'),
                onTap: () => store.markDone(a.id),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: store.isDone(a.id) ? p.ink1 : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: store.isDone(a.id) ? p.ink1 : p.ink3, width: 1.5),
                    ),
                    child: store.isDone(a.id)
                        ? Text('✓', style: pvManrope(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white))
                        : null,
                  ),
                ),
              )),
            ),
            onTap: () => onOpen(a),
          ),
        )),
    ]);
  }
}

/// "3 days ago" for the What she told us row (2026-10-23, Wave 8).
String _toldAgo(DateTime at) {
  final d = DateTime.now().difference(at).inDays;
  return d <= 0 ? 'Today' : (d == 1 ? 'Yesterday' : '$d days ago');
}
