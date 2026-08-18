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
// =============================================================================

import 'package:flutter/material.dart';
import '../brackets/hub/journey_screen.dart';
import '../../data/journeys/journey_registry.dart';
import 'reading_home_screen.dart';
import 'what_changed_screen.dart';
import '../../data/hubs/parenting_hubs.dart';
import '../brackets/hub/hub_owed_screen.dart';
import '../brackets/hub/problem_hub_screen.dart';
import '../../data/hubs/hub_registry.dart';

import '../../localization/app_language.dart';
import '../../services/bracket_resolver.dart';
import '../../services/life_stage_store.dart';
import '../../services/parenting_surfaces.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/bracket_screen.dart';
import '../v2/v2_block_grid.dart';
import '../v2/v2_palette.dart';
import '../v2/v2_sections.dart' show v2CoverTint, v2PpReadCover;
import '../v2/v3_bracket_art.dart';
import '../v2/v3_daily.dart';
import '../v2/v3_daily_art.dart';
import '../v2/v3_daily_tip.dart';
import '../v2/v3_hero_chrome.dart';
import '../v2/v3_dev_mark.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_daily_tips.dart';
import 'pp_development_data.dart';
import 'pp_grow_activities.dart';
import 'journal_v2/journal_home_screen.dart';
import 'phase_map_screen.dart';
import 'family_profile_screen.dart';
import 'pp_hero_field.dart';
import 'pp_saved_hub_screen.dart';
import 'pp_phase_faqs.dart';
import 'pp_phases_data.dart';
import 'pp_products_data.dart';
import 'pp_reading_data.dart';
import 'pp_section_registry.dart';
import 'pp_surface_router.dart';
import 'pp_watch_data.dart';

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

  /// Whether "This phase explained" is showing its full description.
  bool _phaseExpanded = false;

  AppLanguage get lang => widget.lang;

  // ---- The daily tip, the same card pregnancy shows -------------------------
  //
  // Deliberately the SAME widget rather than a parenting copy. Two cards that
  // look almost alike is worse than one that is identical. Only the content
  // differs — this stage's own tips, and an age instead of a week.
  bool _tipQueued = false;

  void _maybeShowTip(int ageMonths, V2Palette p) {
    if (_tipQueued || kDailyTips.isEmpty) return;
    _tipQueued = true;
    // Day-indexed, so it is stable all day and two people on the same day see
    // the same tip — which matters the first time one is screenshot into a
    // family group.
    final tip = kDailyTips[
        DateTime.now().difference(DateTime(2020)).inDays % kDailyTips.length];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDailyTip(context,
          line: tip.body,
          heading: tip.title,
          week: 0,
          day: ageMonths,
          p: p);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [ChildProfileStore.instance, V2PaletteStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final child = ChildProfileStore.instance;
        final phase = currentPhase(child);
        _maybeShowTip(child.ageInMonths, p);

        final activity = _todaysActivity();
        final reads = _reads(3);
        final video = _video(phase);
        final products = _products(6);
        final faqs = phaseFaqs(phase.number, count: 3);
        final next = nextPhase(child);

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
            Positioned.fill(
              child: PpHeroField(
                  accent: phase.accent,
                  ground: p.ground,
                  variant: phase.number),
            ),
            ListView(
              padding: EdgeInsets.zero,
              children: [
                _Hero(
                  phase: phase,
                  child: child,
                  p: p,
                  onSpine: () => Navigator.of(context).push(MaterialPageRoute(
                      settings: const RouteSettings(name: 'pp/phase_map'),
                      builder: (_) => const PhaseMapScreen())),
                  onSaved: () => Navigator.of(context).push(MaterialPageRoute(
                      settings: const RouteSettings(name: 'pp/saved'),
                      builder: (_) => const PpSavedHubScreen())),
                  onProfile: () => Navigator.of(context).push(MaterialPageRoute(
                      settings: const RouteSettings(name: 'pp/profile'),
                      builder: (_) => const FamilyProfileScreen())),
                ),
                _Sheet(p: p, children: [
                const SizedBox(height: 26),
                _pad(_Head(
                    eyebrow: 'Where to go', title: 'Start anywhere', p: p)),
                const SizedBox(height: 14),
                _pad(V2BlockGrid(
                  palette: p,
                  columns: 4,
                  blocks: [
                    for (final b in bracketsFor(LifeStage.parenting))
                      V2Block(
                        label: b.label.of(lang),
                        icon: Icons.circle_outlined,
                        tint: v2BlockTint(b.hue, p),
                        bracketMark: bracketMarkFor(b.id),
                        onTap: () => _openBracket(context, b.id),
                      ),
                  ],
                )),
                const SizedBox(height: 32),

                // ---- CHILD SNAPSHOT -----------------------------------------
                //
                // ⚠️ THIS IS THE SPINE, NOT A BRACKET, and the distinction is
                // why the first cut of this screen was wrong.
                //
                // The eleven doors cover the PROBLEM space — the things she
                // comes looking for. They were never meant to carry the phase
                // spine or the personal tools, and building the grid and
                // stopping left this screen missing everything V1 does between
                // its hero and its footer. Pregnancy V3 makes the same split:
                // doors for problems, sections for the week she is in.
                //
                // The Development door goes deeper on all four domains. This is
                // the glance.
                // ---- THIS PHASE EXPLAINED -----------------------------------
                //
                // ⚠️ V3 DID NOT HAVE THIS AND THE CURRENT HOME DOES. The review
                // asked for symmetry between the two and named this section by
                // name. It is the only place either screen explains what the
                // phase actually IS, as opposed to what to do during it, so
                // losing it in V3 meant the doors and the daily prompts sat on
                // top of nothing.
                //
                // Summary always, the full description on tap: the sections are
                // several paragraphs each and printing them unasked would push
                // every door below the fold.
                _pad(_Head(
                    eyebrow: 'This phase explained',
                    title: 'What ${phase.ageLabel} looks like',
                    p: p)),
                const SizedBox(height: 12),
                _pad(_PhaseExplained(
                  phase: phase,
                  p: p,
                  expanded: _phaseExpanded,
                  onToggle: () =>
                      setState(() => _phaseExpanded = !_phaseExpanded),
                )),
                const SizedBox(height: 32),

                _pad(_Head(
                    eyebrow: 'How ${child.nameMid} is doing',
                    title: 'Right now',
                    p: p)),
                const SizedBox(height: 12),
                _pad(_Snapshot(
                    p: p,
                    onTap: () => _openSurface(context, 'pp_development'))),
                const SizedBox(height: 32),

                if (activity != null) ...[
                  _pad(_Head(
                      eyebrow: 'Today', title: 'One thing to try', p: p)),
                  const SizedBox(height: 12),
                  _pad(_ActivityCard(
                      activity: activity,
                      p: p,
                      onTap: () => _openSurface(context, 'pp_activities'))),
                  const SizedBox(height: 32),
                ],

                if (reads.isNotEmpty) ...[
                  _pad(_Head(
                      eyebrow: 'To read',
                      title: 'Short enough for today',
                      p: p)),
                  const SizedBox(height: 6),
                  for (final r in reads)
                    _pad(_ReadRow(
                        article: r,
                        p: p,
                        onTap: () => _openSurface(context, 'pp_read'))),
                  const SizedBox(height: 32),
                ],

                if (video != null) ...[
                  _pad(_Head(
                      eyebrow: 'Watch',
                      title: 'This phase, in a video',
                      p: p)),
                  const SizedBox(height: 12),
                  _pad(_VideoCard(
                      video: video,
                      p: p,
                      onTap: () => _openSurface(context, 'pp_watch'))),
                  const SizedBox(height: 32),
                ],

                // Products LAST and priced, same as pregnancy V3 — free first,
                // paid last, which is the wedge expressed as layout.
                if (products.isNotEmpty) ...[
                  _pad(_Head(
                      eyebrow: 'Things that help',
                      title: 'What parents ask us about',
                      note: 'Prices shown',
                      p: p)),
                  const SizedBox(height: 12),
                  _ProductRail(
                      items: products,
                      p: p,
                      onOpen: () => _openSurface(context, 'pp_products')),
                  const SizedBox(height: 32),
                ],

                // ---- JOURNAL ------------------------------------------------
                //
                // ⚠️ NO BRACKET OWNS THIS, and none should. A journal is not a
                // problem she has — it is the one place on the screen where she
                // PUTS SOMETHING IN rather than taking something out. Pregnancy
                // V3 learned this the hard way: the journal was demoted to a
                // chip and quietly stopped happening.
                _pad(_Head(
                    eyebrow: 'My journal', title: 'Keep today', p: p)),
                const SizedBox(height: 12),
                // ⚠️ THE SAME WIDGET PREGNANCY USES, not a parenting copy.
                //
                // It was a copy, and a copy is how two screens drift: the
                // pregnancy card has drawn marks in four hues and a bordered
                // pill, this one had flat line icons and a different button.
                // Nobody decided that — it happened because two people (or the
                // same person twice) wrote the same card in two places.
                //
                // A shared component makes uniformity the default rather than a
                // thing to remember, which matters most for the sections that
                // exist in BOTH stages. The verbs differ by one word ("Note for
                // baby" / "Note for them") and that is all that should.
                _pad(V3JournalSection(
                  p: p,
                  actions: [
                    V3QuickAction(
                        icon: Icons.edit_note_rounded,
                        mark: V3DailyMark.memory,
                        hue: 42,
                        label: 'Write a\nmemory',
                        onTap: () => _openJournal(context)),
                    V3QuickAction(
                        icon: Icons.favorite_border_rounded,
                        mark: V3DailyMark.note,
                        hue: 344,
                        label: 'Note for\nthem',
                        onTap: () => _openJournal(context)),
                    V3QuickAction(
                        icon: Icons.photo_camera_outlined,
                        mark: V3DailyMark.photo,
                        hue: 206,
                        label: 'Add a\nphoto',
                        onTap: () => _openJournal(context)),
                    V3QuickAction(
                        icon: Icons.mic_none_rounded,
                        mark: V3DailyMark.voice,
                        hue: 268,
                        label: 'Record\nvoice',
                        onTap: () => _openJournal(context)),
                  ],
                  onOpenAll: () => _openJournal(context),
                )),
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
                  for (var i = 0; i < faqs.length; i++)
                    _pad(_FaqRow(
                      faq: faqs[i],
                      p: p,
                      open: _openFaq == i,
                      // Tapping the open one closes it: a disclosure that cannot
                      // be undone is a worse control than no disclosure.
                      onTap: () =>
                          setState(() => _openFaq = _openFaq == i ? null : i),
                    )),
                  const SizedBox(height: 32),
                ],

                // ---- LOOKING AHEAD ------------------------------------------
                //
                // The only thing on the page about a time that has not arrived.
                // It closes the screen because the last thing she should read is
                // that there is a next, not that there is a product.
                if (next != null) ...[
                  _pad(_Head(
                      eyebrow: 'Looking ahead', title: next.name, p: p)),
                  const SizedBox(height: 12),
                  _pad(_AheadCard(
                      next: next,
                      p: p,
                      // The phase map is where "what changes next" actually
                      // lives, and it is already the hero's own destination.
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              settings:
                                  const RouteSettings(name: 'pp/phase_map'),
                              builder: (_) => const PhaseMapScreen())))),
                  const SizedBox(height: 30),
                ],
                ]),
              ],
            ),
            const Positioned(
                left: 16, right: 16, bottom: 18, child: PpBottomNav(active: 0)),
          ]),
        );
      },
    );
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

  DevActivity? _todaysActivity() {
    final all = [...kGrowExtraActivities, ...kDevActivities];
    if (all.isEmpty) return null;
    return all[DateTime.now().day % all.length];
  }

  List<ReadArticle> _reads(int n) {
    final all = readCatalog;
    if (all.isEmpty) return const [];
    final start = DateTime.now().day % all.length;
    return [
      for (var i = 0; i < n && i < all.length; i++) all[(start + i) % all.length]
    ];
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
  WatchVideo? _video(AgePhase phase) {
    final pool = watchByCategory(watchCategoryForPhase(phase));
    if (pool.isNotEmpty) return pool[DateTime.now().day % pool.length];
    return kWatchVideos.isEmpty
        ? null
        : kWatchVideos[DateTime.now().day % kWatchVideos.length];
  }

  List<PpProduct> _products(int n) {
    if (kPpProducts.isEmpty) return const [];
    final start = DateTime.now().day % kPpProducts.length;
    return [
      for (var i = 0; i < n && i < kPpProducts.length; i++)
        kPpProducts[(start + i) % kPpProducts.length]
    ];
  }

  // ---- Navigation -----------------------------------------------------------

  void _openBracket(BuildContext context, String bracketId) {
    final b = bracketById(bracketId);
    if (b == null) return;

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
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'hub/' + bracketId),
        builder: (_) => ProblemHubScreen(
          config: hub,
          bracket: b,
          lang: lang,
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
      kPpActPottyReadiness: 'parenting_potty',
      kPpActPottyTraining: 'parenting_potty',
      kPpActFirst40Days: 'parenting_first_40',
      kPpActMaternalRecovery: 'parenting_maternal',
      kPpActMaternalConcern: 'parenting_maternal',
    };
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
      case kPpActBehaviour:
        Navigator.of(context).push(MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'pp/what_changed'),
          builder: (_) => const WhatChangedScreen(
              initialCategories: ['Behaviour', 'Mood']),
        ));

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
            meanwhile: 'Something to do today',
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
        builder: (_) => const JournalV2Home(),
      ));

  void _openSurface(BuildContext context, String surfaceId) {
    final screen = ppScreenForSurface(surfaceId);
    if (screen == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: surfaceId),
      builder: (_) => screen,
    ));
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
  final d = c.ageInDays < 1 ? 1 : c.ageInDays;
  final w = c.ageInWeeks.round();
  if (d < 56) return w <= 0 ? 'First week' : (w == 1 ? 'Week 1' : 'Week $w');
  if (c.ageInMonths < 6) return 'Day $d';
  return '$w weeks  ·  Day $d';
}

class _Hero extends StatelessWidget {
  const _Hero(
      {required this.phase,
      required this.child,
      required this.p,
      required this.onSpine,
      required this.onSaved,
      required this.onProfile});

  final AgePhase phase;
  final ChildProfileStore child;
  final V2Palette p;
  final VoidCallback onSpine;
  final VoidCallback onSaved;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    // No background of its own — the page carries it. This is only the type.
    return SizedBox(
      height: 300,
      child: Stack(children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
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
                Align(
                  alignment: Alignment.centerRight,
                  child: V3HeroChrome(
                    tone: V3HeroTone.onField,
                    p: p,
                    initial: child.nameMid.isEmpty ? '' : child.nameMid[0],
                    onSaved: onSaved,
                    onProfile: onProfile,
                  ),
                ),
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
                Text(_bigAge(child),
                    style: pvFraunces(
                        fontSize: 42,
                        fontWeight: FontWeight.w600,
                        height: 1.05,
                        letterSpacing: -1.3,
                        color: p.ink1)),
                const SizedBox(height: 2),
                Text(_subAge(child),
                    style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: p.ink2)),
                const SizedBox(height: 8),
                Text(phase.name,
                    style: pvFraunces(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        letterSpacing: -0.4,
                        color: p.ink2)),
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

  @override
  Widget build(BuildContext context) => Container(
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
        decoration: BoxDecoration(
          color: p.ground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ...children,
          // Clearance for the floating bottom nav, inside the opaque sheet.
          const SizedBox(height: 150),
        ]),
      );
}

// -----------------------------------------------------------------------------
//  Shared pieces — same shapes as pregnancy V3, different content
// -----------------------------------------------------------------------------

class _Head extends StatelessWidget {
  const _Head(
      {required this.eyebrow, required this.title, required this.p, this.note});

  final String eyebrow;
  final String title;
  final String? note;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(eyebrow.toUpperCase(),
                  style: pvManrope(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
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
          const SizedBox(height: 6),
          Text(title,
              style: pvFraunces(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                  letterSpacing: -0.6,
                  color: p.ink1)),
        ],
      );
}

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
              Text('${activity.minutes} min  ·  ${activity.ageTag}',
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink3)),
            ]),
          ]),
        ),
      );
}

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

class _ProductRail extends StatelessWidget {
  const _ProductRail(
      {required this.items, required this.p, required this.onOpen});

  final List<PpProduct> items;
  final V2Palette p;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 172,
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
                onTap: onOpen,
                borderRadius: BorderRadius.circular(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ⚠️ A DRAWN CATEGORY MARK, NOT A STOCK PHOTOGRAPH — and
                      // this is the one place where parenting deliberately does
                      // NOT copy pregnancy.
                      //
                      // Pregnancy shows photographs because `Product.imageUrl`
                      // exists and carries 24 hand-picked ones. `PpProduct` has
                      // no image field at all, so matching pregnancy would mean
                      // inventing a per-CATEGORY photo bank — and of the six
                      // parenting categories only about half have an honest
                      // match in the images we already own. "On the move" and
                      // "Health & safety" would get something calm and
                      // unrelated, which is the failure product_data.dart names
                      // outright: a wrong photograph is worse than a colour,
                      // because a photograph is read as THIS product.
                      //
                      // The marks are the better answer rather than the
                      // fallback: they are ours, they are right by
                      // construction, they need no network, and they are the
                      // language the eleven doors above already speak. The well
                      // was bland because it was EMPTY, not because it lacked a
                      // photograph.
                      //
                      // Real product photography replaces this the day the
                      // catalogue has it — that is a data gap, and it belongs to
                      // whoever owns the catalogue.
                      Container(
                        height: 108,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: v2BlockTint(_productHue(it.category), p),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: switch (_productMark(it.category)) {
                          final BracketMark m => SizedBox(
                              width: 52,
                              height: 52,
                              child: V3BracketArt(
                                  mark: m,
                                  tint: v2BlockTint(
                                      _productHue(it.category), p))),
                          null => const SizedBox.shrink(),
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(it.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvJakarta(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                              color: p.ink1)),
                      const SizedBox(height: 3),
                      Text('₹${it.price}',
                          style: pvManrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: p.ink2)),
                    ]),
              ),
            );
          },
        ),
      );
}

// -----------------------------------------------------------------------------
//  The spine sections — not brackets, and deliberately so
// -----------------------------------------------------------------------------

/// Four development domains at a glance.
///
/// ⚠️ A GLANCE, NOT A SCORE. Each row is a domain and the word it is currently
/// at — never a bar, a percentage, or a position against other children. The
/// Development door goes deeper on all four; this exists so she can see them
/// without leaving home, which is what V1 does and the first cut of V3 dropped.
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
                        for (final sec in phase.sections) ...[
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
              Text(expanded ? 'Show less' : 'Read the full description',
                  style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: p.action)),
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

class _FaqRow extends StatefulWidget {
  const _FaqRow(
      {required this.faq, required this.p, this.open = false, this.onTap});

  final PhaseFaq faq;
  final V2Palette p;
  final bool open;
  final VoidCallback? onTap;

  @override
  State<_FaqRow> createState() => _FaqRowState();
}

class _FaqRowState extends State<_FaqRow> {
  @override
  Widget build(BuildContext context) {
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

class _AheadCard extends StatelessWidget {
  const _AheadCard({required this.next, required this.p, this.onTap});

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
                        Text('See what changes',
                            style: pvManrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: accent)),
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
