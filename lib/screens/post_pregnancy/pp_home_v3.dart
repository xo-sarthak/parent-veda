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

import 'package:flutter/material.dart';
import '../brackets/hub/journey_screen.dart';
import '../../data/journeys/journey_registry.dart';
import 'reading_home_screen.dart';
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
import 'journal_v2/journal_capture_screens.dart';
import 'reading_reader_screen.dart';
import 'development_activity_screen.dart';
import 'watch_player_screen.dart';
import 'product_detail_screen.dart';
import 'journal_v2/journal_home_screen.dart';
import 'phase_map_screen.dart';
import 'family_profile_screen.dart';
import 'pp_hero_field.dart';
// import 'pp_saved_hub_screen.dart'; // kept for revert — SavedScreen replaced the hub 2026-09-16
import '../saved_screen.dart';
import 'pp_phase_faqs.dart';
import 'pp_phases_data.dart';
import 'pp_products_data.dart';
import 'pp_reading_data.dart';
import 'pp_section_registry.dart';
import '../../data/doors/pp_door_data.dart';
import 'doors/pp_door_screen.dart';
import 'pp_section_screen.dart' show PpSectionTool;
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
      animation: Listenable.merge([
        ChildProfileStore.instance,
        V2PaletteStore.instance,
        PpHomeActivitiesStore.instance,
      ]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final child = ChildProfileStore.instance;
        final phase = currentPhase(child);
        _maybeShowTip(child.ageInMonths, p);

        // The single day-rotated pick, replaced by the three-a-day store.
        // Kept for revert:
        //   final activity = _todaysActivity();
        final activities =
            PpHomeActivitiesStore.instance.todays(child.ageInMonths);
        final changes = phaseChangesFor(phase);
        final reads = _readsForAge(child.ageInMonths, 3);
        final video = _video(phase);
        final products = _productsForAge(child.ageInMonths, 6);
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
                  // One Saved screen for the whole app since 2026-09-16
                  // (docs/FAMILY-MODEL.md §6). Kept for revert:
                  // onSaved: () => Navigator.of(context).push(MaterialPageRoute(
                  //     settings: const RouteSettings(name: 'pp/saved'),
                  //     builder: (_) => const PpSavedHubScreen())),
                  onSaved: () => Navigator.of(context).push(MaterialPageRoute(
                      settings: const RouteSettings(name: 'saved'),
                      builder: (_) => const SavedScreen())),
                  onProfile: () => Navigator.of(context).push(MaterialPageRoute(
                      settings: const RouteSettings(name: 'pp/profile'),
                      builder: (_) => const FamilyProfileScreen())),
                ),
                _Sheet(p: p, children: [
                const SizedBox(height: 26),
                _pad(_Head(
                    eyebrow: 'Where to go', title: 'Start anywhere', p: p)),
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
                const SizedBox(height: 14),
                // ⚠️ VIDEO FIRST. The brief: "Currently the written description
                // comes first while the video appears much further down the
                // page. Change the order so that the video explanation of the
                // phase comes first, the written description follows
                // immediately after, and any additional resources follow."
                //
                // The video is the same phase-matched one the old "Watch"
                // section showed (see `_video`). Only its place changed.
                if (video != null) ...[
                  _pad(_PhaseVideoCard(
                      video: video,
                      p: p,
                      onTap: () => _openVideo(context, video))),
                  const SizedBox(height: 16),
                ],
                _pad(_PhaseExplained(
                  phase: phase,
                  p: p,
                  expanded: _phaseExpanded,
                  onToggle: () =>
                      setState(() => _phaseExpanded = !_phaseExpanded),
                )),
                const SizedBox(height: 16),
                _ResourceRail(p: p, items: [
                  _Resource(
                      label: 'What changes next',
                      hue: 42,
                      icon: Icons.timeline_outlined,
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              settings:
                                  const RouteSettings(name: 'pp/phase_map'),
                              builder: (_) => const PhaseMapScreen()))),
                  _Resource(
                      label: 'Something changed?',
                      hue: 285,
                      icon: Icons.help_outline_rounded,
                      onTap: () => _openSurface(context, 'pp_what_changed')),
                  _Resource(
                      label: 'When to call the doctor',
                      hue: 188,
                      icon: Icons.medical_services_outlined,
                      onTap: () => _openSurface(context, 'pp_baby_ok_check')),
                ]),
                const SizedBox(height: 32),

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
                _pad(_Head(
                    eyebrow: 'How ${child.nameMid} is doing',
                    title: 'Right now',
                    p: p)),
                if (changes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _pad(Text(phaseChangesLine(changes, phase),
                      style: pvManrope(
                          fontSize: 13, height: 1.45, color: p.ink3))),
                ],
                const SizedBox(height: 14),
                // Kept for revert:
                //   _pad(_Snapshot(
                //       p: p,
                //       onTap: () => _openSurface(context, 'pp_development'))),
                if (changes.isEmpty)
                  // A feature is never hidden: a phase with nothing listed
                  // still shows the door to Development.
                  _pad(_EmptyInvite(
                      p: p,
                      line: 'Nothing is listed for ${phase.ageLabel} yet. '
                          'The Development door has the whole picture.',
                      cta: 'Open Development',
                      onTap: () => _openSurface(context, 'pp_development')))
                else
                  for (final c in changes) ...[
                    _pad(_ChangeCard(
                        change: c,
                        p: p,
                        onTap: () => _showChangeSheet(context, c, child, p))),
                    const SizedBox(height: 12),
                  ],
                const SizedBox(height: 20),

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
                _pad(_Head(
                    eyebrow: 'Today',
                    title: 'Activities to do today with your baby',
                    p: p)),
                const SizedBox(height: 14),
                if (activities.isEmpty)
                  _pad(_EmptyInvite(
                      p: p,
                      line: 'The activity library is still filling in for '
                          '${phase.ageLabel}.',
                      cta: 'Browse every activity',
                      onTap: () => _openSurface(context, 'pp_activities')))
                else ...[
                  for (final a in activities) ...[
                    _pad(_TodayActivityCard(
                      activity: a,
                      p: p,
                      done: PpHomeActivitiesStore.instance.isDone(a.id),
                      swapped: PpHomeActivitiesStore.instance.wasSwappedIn(a.id),
                      onDone: () => PpHomeActivitiesStore.instance.markDone(a.id),
                      onChange: () => PpHomeActivitiesStore.instance
                          .swap(a.id, child.ageInMonths),
                      onOpen: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              settings: RouteSettings(
                                  name: 'pp/activity/${a.id}'),
                              builder: (_) =>
                                  DevelopmentActivityScreen(activity: a))),
                    )),
                    const SizedBox(height: 12),
                  ],
                  // No counter, no streak, no "2 of 3" — the brief and the
                  // Grow feature both refuse those. One line about tomorrow.
                  _pad(Text(
                      PpHomeActivitiesStore.instance.allDone
                          ? 'All three done. Tomorrow brings three new ones.'
                          : 'Tomorrow brings three new ones.',
                      style: pvManrope(
                          fontSize: 13, height: 1.45, color: p.ink3))),
                ],
                const SizedBox(height: 32),

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
                if (reads.isNotEmpty) ...[
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
                if (products.isNotEmpty) ...[
                  _pad(_Head(
                      eyebrow: 'Recommended',
                      title: 'Recommended products for your baby',
                      p: p)),
                  const SizedBox(height: 14),
                  _ProductRail(
                      items: products,
                      p: p,
                      onOpen: (it) => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              settings:
                                  RouteSettings(name: 'pp/product/${it.id}'),
                              builder: (_) =>
                                  ProductDetailScreen(product: it)))),
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
                _pad(_JournalInvite(
                  p: p,
                  onPhoto: () => _openCapture(context, 'A photo from today'),
                  onMilestone: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          settings:
                              const RouteSettings(name: 'pp/journal/guided'),
                          builder: (_) => const GuidedMemoryScreen())),
                  onThought: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          settings:
                              const RouteSettings(name: 'pp/journal/write'),
                          builder: (_) => const WriteStoryScreen())),
                  onMoment: () =>
                      _openCapture(context, 'A moment from today'),
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
                left: 16,
                right: 16,
                bottom: 18,
                child: PpBottomNav(active: PpTab.home)),
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
  static List<Bracket> _tilesOrder(List<Bracket> all) => all;

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
  WatchVideo? _video(AgePhase phase) {
    final pool = watchByCategory(watchCategoryForPhase(phase));
    if (pool.isNotEmpty) return pool[DateTime.now().day % pool.length];
    return kWatchVideos.isEmpty
        ? null
        : kWatchVideos[DateTime.now().day % kWatchVideos.length];
  }

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
  List<PpProduct> _productsForAge(int months, int n) {
    if (kPpProducts.isEmpty) return const [];
    List<PpProduct> rotate(List<PpProduct> xs) {
      if (xs.isEmpty) return xs;
      final start = DateTime.now().day % xs.length;
      return [for (var i = 0; i < xs.length; i++) xs[(start + i) % xs.length]];
    }

    final fit = rotate(kPpProducts.where((x) => x.suitsAge(months)).toList());
    final rest = rotate(kPpProducts.where((x) => !x.suitsAge(months)).toList());
    return [...fit, ...rest].take(n).toList();
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

  void _openCapture(BuildContext context, String prompt) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'pp/journal/capture'),
        builder: (_) => QuickCaptureScreen(prompt: prompt),
      ));

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
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            height: 1.65,
                            color: p.ink1)),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 12),
                  // 3. More.
                  Text('MORE ON THIS',
                      style: pvManrope(
                          fontSize: 11.5,
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
                        sub: 'Activity · ${activity.minutes} min',
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
                          fontSize: 12, height: 1.5, color: p.ink3)),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

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

// The 74dp-cover row form. Superseded by the _ReadRail cards. Kept for revert.
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
class _ProductRail extends StatelessWidget {
  const _ProductRail(
      {required this.items, required this.p, required this.onOpen});

  final List<PpProduct> items;
  final V2Palette p;
  final ValueChanged<PpProduct> onOpen;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 236,
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
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                                color: p.ink1)),
                        const SizedBox(height: 4),
                        Text(why,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                                fontSize: 12.5, height: 1.35, color: p.ink2)),
                        const Spacer(),
                        Row(children: [
                          Expanded(
                            child: Text('₹${it.price}',
                                style: pvManrope(
                                    fontSize: 13.5,
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
          style: pvManrope(fontSize: 13, height: 1.45, color: p.ink3)),
    ]);
  }
}

class _Resource {
  const _Resource(
      {required this.label,
      required this.hue,
      required this.icon,
      required this.onTap});
  final String label;
  final double hue;
  final IconData icon;
  final VoidCallback onTap;
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
                                    fontSize: 13.5,
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
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    letterSpacing: -0.4,
                    color: p.ink1)),
            const SizedBox(height: 6),
            Text(change.notice,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
            const SizedBox(height: 12),
            Row(children: [
              Text('See what changes',
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: p.action)),
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
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              color: p.ink1)),
                      const SizedBox(height: 3),
                      Text(sub,
                          style: pvManrope(
                              fontSize: 13, height: 1.3, color: p.ink3)),
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
                style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
            const SizedBox(height: 10),
            Row(children: [
              Text(cta,
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: p.action)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 17, color: p.action),
            ]),
          ]),
        ),
      );
}

/// One of today's three activities.
///
/// Three states, per the brief: to do (a "Done" pill and a quiet "Change"),
/// done (dimmed, a filled tick, "Done today", stays until tomorrow), and just
/// swapped in (a small "Swapped" chip beside the title). No counter anywhere.
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
    final hue = HSLColor.fromColor(area.accent).hue;
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
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: v2BlockTint(hue, p),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: switch (devMarkFor(area.id)) {
                  final DevMark m =>
                    V3DevMark(mark: m, accent: area.accent, size: 22),
                  null => Icon(area.icon, size: 19, color: p.ink2),
                },
              ),
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
                                    fontSize: 18,
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
                              fontSize: 13.5, height: 1.5, color: p.ink2)),
                      const SizedBox(height: 8),
                      Text('${activity.minutes} min  ·  ${activity.ageTag}',
                          style: pvManrope(fontSize: 13, color: p.ink3)),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: p.ink2)),
              ]),
            )
          else
            Row(children: [
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
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: p.ink1)),
                  ]),
                ),
              ),
              const SizedBox(width: 10),
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
                            fontSize: 13,
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
                                            fontSize: 12.5,
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
                  fontSize: 12, fontWeight: FontWeight.w700, color: p.ink2)),
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
                            fontSize: 13.5, height: 1.5, color: p.ink2)),
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
            Text('Open the journal',
                style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p.action)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 17, color: p.action),
          ]),
        ),
      ]);
}
