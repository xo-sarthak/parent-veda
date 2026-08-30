// =============================================================================
//  TtcHomeV3 — the Trying-to-Conceive home, rebuilt around the L1 brackets
// -----------------------------------------------------------------------------
//  Third and last of the built stages. `TtcTodayScreen` is V1 and is UNTOUCHED;
//  this sits beside it behind a toggle, the same way parenting's V3 does.
//
//  SAME SHAPES AS THE OTHER TWO STAGES, DIFFERENT CONTENT. Field, hero type,
//  door grid, section heads, journal — all shared widgets rather than
//  lookalikes, which is the whole point. A woman crosses TTC → pregnancy →
//  parenting once, and each crossing is the worst possible moment to make her
//  relearn a screen.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE CLINICAL RULES THIS SCREEN HAD TO OBEY, AND WHERE THEY CAME FROM
//  ---------------------------------------------------------------------------
//
//  A big number on a fertility hero is the most dangerous piece of type in the
//  product, because the obvious ones are all forbidden:
//
//    · **Never a personalised probability.** No "your chance this month". Held
//      by `test/ttc_clinical_review_test.dart`, which scans source rather than
//      seed lists.
//    · **Never a countdown to an outcome.** `test/ttc_home_hero_test.dart`
//      asserts the waiting chapter says "or the next cycle — both are fine",
//      and that "next" names a TRIGGER ("when you log your next period") rather
//      than a number of days. "In 14 days" has to be wrong eventually, and being
//      wrong about this is worse than being vague.
//    · **No denominator across the stage.** Chapters 2–4 come round with every
//      cycle, so "Chapter 2 of 5" would promise a finish line that does not
//      exist — the exact feeling the Journey Map's "not a step backwards" line
//      was written to prevent. Parenting says "PHASE 1 OF 20" and TTC must not.
//    · **We may not always generate a value at all.** `TimingOwnership` decides
//      that, and when a clinic owns the cycle the app defers rather than
//      computes.
//
//  So the big fact is DAY IN THIS CHAPTER — a fact about where she is, which is
//  true on a clinic cycle, true with no history, and never a prediction. It is
//  also the one `TtcTodayScreen` already settled on, so the two versions agree.
//
//  And when nothing has been logged, the hero does not show a zero: it shows
//  the invitation, because `TtcNoEstimate.noPeriodLogged` is a real state with
//  its own sentence, not a hole.
// =============================================================================

import 'package:flutter/material.dart';
import '../brackets/hub/journey_screen.dart';
import '../../data/journeys/journey_registry.dart';
import 'ttc_prepare_screen.dart';
import '../../data/hubs/ttc_hubs.dart';
import '../brackets/hub/hub_owed_screen.dart';
import '../brackets/hub/problem_hub_screen.dart';
import '../../data/hubs/hub_registry.dart';

import '../../localization/app_language.dart';
import '../../services/bracket_resolver.dart';
import '../../services/life_stage_store.dart';
import '../../services/ttc_surfaces.dart';
import '../../theme/pv_fonts.dart';

import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_daily_data.dart';
import '../../ttc/ttc_fertile_window.dart';
import '../../ttc/ttc_products_data.dart';
import '../../ttc/ttc_reads_data.dart';
import '../../ttc/ttc_ritual_store.dart';
import '../../ttc/ttc_store.dart';
import '../brackets/bracket_screen.dart';
import '../v2/v2_block_grid.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_bracket_art.dart';
import '../v2/v3_daily.dart';
import '../v2/v3_daily_art.dart';
import '../v2/v3_hero_chrome.dart';
import '../v2/v3_hero_field.dart';
import 'ttc_calendar_screen.dart' show ttcFactsFor, TtcDayFacts;
import 'ttc_chapter_screen.dart';
import 'ttc_common.dart';
import 'ttc_insight_screen.dart';
import 'ttc_journey_map_screen.dart';
import 'ttc_partner_screen.dart';
import 'ttc_products_screen.dart';
import 'ttc_profile_screen.dart';
import 'ttc_ritual_screen.dart';
import 'ttc_strings.dart';
import 'ttc_surface_router.dart';
import 'ttc_today_parts.dart';
import 'ttc_today_screen.dart' show logTtcPeriod;
import 'ttc_tracker_screen.dart' show openTtcTracker;
import 'ttc_transition_screen.dart';
import '../../widgets/pv_nav_bar.dart';

/// The four chapters' hues, on the same controlled-pastel wheel every other
/// stage uses.
///
/// ⚠️ THEY MOVE WITH THE CYCLE AND THEY DO NOT RANK IT. Rose for preparing,
/// green for knowing the rhythm, gold for trying, blue-violet for waiting —
/// four different places, not a progress ramp from cold to warm. A palette that
/// got visibly "better" toward one chapter would be scoring her cycle, which is
/// the pressure this entire stage is built to remove.
double _chapterHue(TtcChapter c) => switch (c) {
      TtcChapter.preparingTogether => 344,
      TtcChapter.knowingYourRhythm => 160,
      TtcChapter.tryingTogether => 42,
      TtcChapter.theWaitingDays => 268,
      // The fifth chapter, and the only one that is an ENDING rather than a
      // place in the loop: she is pregnant, and this stage is handing her over.
      // Green, the same hue pregnancy's own arrival wears.
      TtcChapter.aNewBeginning => 104,
    };

int _chapterNumber(TtcChapter c) => TtcChapter.values.indexOf(c) + 1;

class TtcHomeV3 extends StatelessWidget {
  const TtcHomeV3({super.key});

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return AnimatedBuilder(
      animation: Listenable.merge([TtcStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final hinglish = TtcLang.instance.hinglish;
        final today = TtcStore.instance.today;
        final chapter = today.chapter;
        final accent = v2BlockTint(_chapterHue(chapter), p);

        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(children: [
            // The field is the PAGE's surface — it does not scroll, and the
            // content sheet slides over it. See the note in v3_hero_field.dart
            // about why nobody blends two sections.
            Positioned.fill(
              child: V3HeroField(
                  accent: accent,
                  ground: p.ground,
                  variant: _chapterNumber(chapter)),
            ),
            ListView(
              // ⚠️ ROOM FOR THE NAV AND THE ASK FAB. `ttcBottomInset` is what
              // every other TTC screen reserves, and V3 shipped without it —
              // the last rows of this page sat under a floating pill and an
              // opaque 56px circle. See docs/STILL-OPEN.md §9.4.
              padding: const EdgeInsets.only(bottom: ttcBottomInset),
              children: [
                // ---- THE CYCLE HEADER ---------------------------------------
                //
                // ⚠️ THIS REPLACED THE CHAPTER HERO, AND THE TRADE IS WORTH
                // NAMING. The old hero led on "Day 6 in this chapter" — a fact
                // about where she is that is true on every pathway and never a
                // prediction, which is why it was chosen. It was also the
                // answer to a question almost nobody opens the app asking.
                //
                // What she opens the app asking is "where am I in this cycle,
                // and when are my days". So the header now leads on the week
                // and the window, and the chapter survives as the chip above
                // them — same destination, less of the screen.
                //
                // ⚠️ NOTHING THE HERO REACHED BECAME UNREACHABLE. Profile is
                // the avatar, the journey map is the chapter chip, the cycle
                // companion is the cycle-day line, and the calendar — which the
                // hero never reached at all — is the icon on the right. See the
                // wiring gate in CLAUDE.md; the reason this list is written out
                // is that a replaced hero is exactly where a door goes missing.
                _CycleHeader(
                  today: today,
                  p: p,
                  hinglish: hinglish,
                  onChapter: () => Navigator.of(context).push(MaterialPageRoute(
                      settings: const RouteSettings(name: 'ttc/journey_map'),
                      builder: (_) => const TtcJourneyMapScreen())),
                  onCycle: () => _openSurface(context, 'ttc_cycle'),
                  onCalendar: () => _openSurface(context, 'ttc_calendar'),
                  onProfile: () => openTtcProfile(context),
                ),
                _Sheet(p: p, children: [
                  const SizedBox(height: 26),

                  // ---- THE DAILY STORIES ------------------------------------
                  //
                  // The five daily items, as a scrollable rail of circles
                  // rather than a card and four rows. Same five destinations,
                  // same deterministic day-of-year rotation — see `_DailyRail`
                  // for why the offsets had to be preserved exactly.
                  _pad(_Head(
                      eyebrow: hinglish ? 'Aaj ke liye' : 'My daily insights',
                      title: hinglish ? 'Aaj ki baatein' : 'Today',
                      p: p)),
                  const SizedBox(height: 14),
                  _DailyRail(p: p, hinglish: hinglish),
                  const SizedBox(height: 32),

                  // ---- THE DOORS -------------------------------------------
                  //
                  // ⚠️ NO EYEBROW ANY MORE. "WHERE TO GO" over "Start anywhere"
                  // was a label explaining a label — the title already says
                  // what the grid is for, and the eyebrow only earned its place
                  // when this section was buried in the middle of the page.
                  _pad(_Head(
                      eyebrow: '',
                      title: hinglish ? 'Kahin se bhi shuru karein' : 'Start anywhere',
                      p: p)),
                  const SizedBox(height: 14),
                  _pad(V2BlockGrid(
                    palette: p,
                    columns: 4,
                    blocks: [
                      for (final b in bracketsFor(LifeStage.tryingToConceive))
                        V2Block(
                          label: hinglish ? b.label.hi : b.label.en,
                          icon: Icons.circle_outlined,
                          tint: v2BlockTint(b.hue, p),
                          bracketMark: bracketMarkFor(b.id),
                          onTap: () => _openBracket(context, b.id),
                        ),
                    ],
                  )),
                  const SizedBox(height: 32),

                  // ---- THE SPINE -------------------------------------------
                  //
                  // ⚠️ THE DOORS DO NOT CARRY THE SPINE, and this is the
                  // mistake parenting's first cut made: eleven problem doors
                  // and nothing else, so a screen that used to hold the whole
                  // day held only a menu. The doors cover what she comes
                  // LOOKING for; the sections cover the cycle she is actually
                  // in. Both, always.
                  //
                  // ⚠️ THE SPINE IS NOW THE HEADER, NOT A CARD IN THE SHEET —
                  // which is why this section is commented out rather than
                  // deleted. `_CycleHeader` states the same three things this
                  // card did (where she is in the cycle, whether we may
                  // estimate at all, and the way into the cycle companion) and
                  // states them above the fold instead of a screen down.
                  //
                  // Kept for revert: if the header experiment comes off, this
                  // block and `_SpineCard` go back together. The rule that
                  // matters either way is the one in the card's own doc
                  // comment — position, never probability.
                  //
                  // _pad(_Head(
                  //     eyebrow: hinglish ? 'Aapki rhythm' : 'Your rhythm',
                  //     title: hinglish ? 'Aaj kahan hain aap' : 'Where you are today',
                  //     p: p)),
                  // const SizedBox(height: 12),
                  // _pad(_SpineCard(
                  //     today: today,
                  //     p: p,
                  //     hinglish: hinglish,
                  //     onTap: () => _openSurface(context, 'ttc_cycle'))),
                  // const SizedBox(height: 32),

                  // ---- PRACTICE --------------------------------------------
                  //
                  // ⚠️ A LINK TO THE RITUAL IS NOT THE RITUAL, and the mistake
                  // is already written up in `ttc_today_screen.dart`: "density
                  // work has to know the difference between something you read
                  // and something you use."
                  //
                  // V3 shipped this as one `_LinkCard` opening the ritual
                  // screen. Same destination, so it passes a reachability
                  // check — and it still removed the thing the card is FOR.
                  // On V1 she can tick a part off from the home, see 2/5, and
                  // see a streak. On V3 completing anything cost a screen.
                  //
                  // That is not a cosmetic difference in an A/B. Ritual
                  // completion would have read as lower on V3 for a reason
                  // that has nothing to do with which home she prefers, and
                  // the toggle would have "proved" it.
                  //
                  // ⚠️ RENAMED, NOT REBUILT. The card, the store, the streak
                  // and the five parts are untouched; only the words over them
                  // changed. What the section always was — a few minutes a day
                  // of preparation before conception — had been labelled
                  // "Daily ritual", which says when it happens and nothing
                  // about what it is for.
                  //
                  // ⚠️ "GARBHADHANA SAMSKARA", NOT "GARBH SANSKAR". The two
                  // name different things and the difference is the whole point
                  // of this section: Garbh Sanskar is the PREGNANCY practice
                  // and ParentVeda already ships it, five pillars deep, in the
                  // pregnancy stage. Garbhadhana Samskara is the older,
                  // narrower idea of preparing *before* conception. Using the
                  // pregnancy name here would promise a woman who has not
                  // conceived the pregnancy feature — and would make the two
                  // stages look like the same screen twice.
                  _pad(_SectionIntro(
                      title: TtcS.current().samskarTitle,
                      subtitle: TtcS.current().samskarSubtitle,
                      body: TtcS.current().samskarBody,
                      p: p)),
                  const SizedBox(height: 14),
                  _pad(_RitualCardV3(p: p, hinglish: hinglish, chapter: chapter)),
                  const SizedBox(height: 32),

                  // ---- TODAY ------------------------------------------------
                  //
                  // ⚠️ FIVE GATES V1 HAD AND V3 DID NOT. The insight, the myth,
                  // today's nutrition, today's movement and today's pick were
                  // all reachable from the V1 home and from nowhere on this
                  // one. That is the V1/V3 toggle failing its own premise: it
                  // is an A/B on how the home LOOKS, so anything only one side
                  // can reach makes the comparison about coverage instead.
                  //
                  // ⚠️ A ROW GROUP, NOT FIVE CARDS, and the reason is the same
                  // one written into `ttc_today_screen.dart`: a row is a line
                  // you scan, a card is a small article you have to read. Five
                  // more `_LinkCard`s here would have doubled the page's height
                  // to carry five sentences. The insight keeps a card because
                  // it is the one item that is genuinely an article.
                  //
                  // ⚠️ V1'S OWN TWO STRINGS, NOT NEW ONES. The eyebrow above
                  // already reads "TODAY" for the practice section, and a
                  // second "TODAY" under it read as a rendering fault. Reaching
                  // for `todaysJourney` / `todaysJourneyTitle` fixes it and
                  // costs nothing: they are the exact labels V1 puts over this
                  // exact group, so the two homes now name the same block the
                  // same way — which is what makes flipping the pill a
                  // comparison rather than a re-orientation.
                  //
                  // ⚠️ THIS BLOCK MOVED TO THE TOP OF THE PAGE AS `_DailyRail`.
                  // The five items and their five destinations are unchanged —
                  // what changed is that they are now circles above the doors
                  // instead of a card and four rows below them.
                  //
                  // Kept for revert, and the coverage argument above still
                  // applies to whichever shape is live: five gates V1 has, V3
                  // has to have. `test/ttc_home_v3_parity_test.dart` is what
                  // actually holds that, and it passes against the rail because
                  // the rail reuses these exact strings as its captions.
                  //
                  // _pad(_Head(
                  //     eyebrow: TtcS.current().todaysJourney,
                  //     title: TtcS.current().todaysJourneyTitle,
                  //     p: p)),
                  // const SizedBox(height: 12),
                  // _pad(_InsightCardV3(p: p, hinglish: hinglish)),
                  // const SizedBox(height: 10),
                  // _pad(_TodayRows(p: p, hinglish: hinglish)),
                  // const SizedBox(height: 32),

                  // ---- RECOMMENDED PRODUCTS --------------------------------
                  //
                  // ⚠️ A RAIL, AND IT SITS ABOVE THE READS RATHER THAN AT THE
                  // FOOT. The page still does not CLOSE on a shop — see the
                  // People section's note, which is the rule this obeys — but
                  // "today's pick" as a single row was the only commerce on the
                  // home and it was doing the job badly: one product, chosen by
                  // a day-of-year rotation, with no way to see the others
                  // without leaving.
                  //
                  // ⚠️ NEVER A PRODUCT THAT CLAIMS TO IMPROVE HER ODDS. The
                  // catalogue's own `whyEn` is what renders here, and every
                  // entry in `ttc_products_data.dart` carries a "look for" and
                  // a "watch out" for exactly this reason. A supplement rail on
                  // a fertility home is one careless subtitle away from being a
                  // claim, which is why the card shows the category and the
                  // price and not a benefit.
                  _pad(_Head(
                      eyebrow: hinglish ? 'Saman' : 'Worth having',
                      title: hinglish ? 'Aapke liye' : 'Recommended for you',
                      p: p)),
                  const SizedBox(height: 14),
                  _ProductRail(p: p, hinglish: hinglish),
                  const SizedBox(height: 32),

                  // ---- RECOMMENDED READS -----------------------------------
                  _pad(_Head(
                      eyebrow: hinglish ? 'Padhne ke liye' : 'To read',
                      title: hinglish ? 'Aapke chapter ke liye' : 'Recommended reads',
                      p: p)),
                  const SizedBox(height: 12),
                  _pad(_LinkCard(
                    title: chapter.title(hinglish),
                    body: chapter.nextUp(hinglish),
                    p: p,
                    hue: _chapterHue(chapter),
                    mark: V3DailyMark.note,
                    onTap: () => _openSurface(context, 'ttc_chapter'),
                  )),
                  const SizedBox(height: 10),

                  // ⚠️ THE THREE TABS, WHICH THE CARD ABOVE CANNOT REACH.
                  // `ttc_chapter` opens the reader at its DEFAULT tab, so V3
                  // could reach "Me" and nothing else. V1 put Me / Us / What's
                  // next in the hero, exactly where pregnancy puts Baby /
                  // Mother / What's next.
                  //
                  // They are not in this hero because the V3 field is a
                  // photographic surface carrying a spine chip and one large
                  // number — three chrome circles on it is the gradient-and-
                  // shortcut hero V3 exists to replace. Hung off the chapter
                  // card instead, which is the thing they are shortcuts INTO.
                  _pad(_ChapterTabs(p: p, chapter: chapter)),
                  const SizedBox(height: 14),

                  // ⚠️ THE LIBRARY, WHICH THE CHAPTER CARD ALSO CANNOT REACH.
                  // `kTtcReads` is the largest body of content in the stage and
                  // the home linked to none of it — the chapter reader is a
                  // different thing written for a different moment. The rail is
                  // the read equivalent of the door grid: a way in, not a feed.
                  _ReadRail(p: p, hinglish: hinglish),
                  const SizedBox(height: 32),

                  // ---- JOURNAL ---------------------------------------------
                  //
                  // ⚠️ KEPT, THOUGH THE REORDER DID NOT ASK FOR IT. The section
                  // list this page was rebuilt against names the header, the
                  // stories, the doors, the samskar, products, reads, experts
                  // and the way out — and not the journal. Dropping it was the
                  // wrong reading: `ttc_journal` has no other entrance on this
                  // home, so removing the section would not have moved it, it
                  // would have deleted it. Placed after the reads and before
                  // the people, which is where it interrupts least.
                  //
                  // ⚠️ LITERALLY PREGNANCY'S WIDGET, not a third copy of it.
                  // Same marks, same hues, same outlined button. Only the two
                  // labels differ, because only the two labels are about a
                  // different stage. Parenting made the same call for the same
                  // reason.
                  _pad(_Head(
                      eyebrow: hinglish ? 'Aaj ke liye' : 'Keep today',
                      title: hinglish ? 'Aapki journal' : 'Your journal',
                      p: p)),
                  const SizedBox(height: 12),
                  _pad(V3JournalSection(
                    p: p,
                    onOpenAll: () => _openSurface(context, 'ttc_journal'),
                    actions: [
                      V3QuickAction(
                          icon: Icons.edit_note_rounded,
                          mark: V3DailyMark.memory,
                          hue: 42,
                          label: hinglish ? 'Kuch\nlikhein' : 'Write\nsomething',
                          onTap: () => _openSurface(context, 'ttc_journal')),
                      V3QuickAction(
                          icon: Icons.favorite_border_rounded,
                          mark: V3DailyMark.capsule,
                          hue: 344,
                          label: hinglish ? 'Aaj kaisa\nlaga' : 'How today\nfelt',
                          onTap: () => _openSurface(context, 'ttc_journal')),
                      V3QuickAction(
                          icon: Icons.checklist_rounded,
                          mark: V3DailyMark.note,
                          hue: 206,
                          label: hinglish ? 'Roz ka\nlog' : 'Log for\ntoday',
                          onTap: () => _openSurface(context, 'ttc_calendar')),
                      V3QuickAction(
                          icon: Icons.people_outline_rounded,
                          mark: V3DailyMark.photo,
                          hue: 268,
                          label: hinglish ? 'Saath\nmein' : 'The two\nof you',
                          onTap: () => _openSurface(context, 'ttc_partner')),
                    ],
                  )),
                  const SizedBox(height: 32),

                  // ---- PEOPLE ----------------------------------------------
                  //
                  // ⚠️ THE ONE SECTION THAT ENDS THE PAGE, and deliberately not
                  // the products rail. TTC is the stage where the paid layer is
                  // genuinely real — thirteen offerings with named experts —
                  // which makes it the stage where closing on a shop would be
                  // most tempting and most wrong. The last thing she reads is
                  // that there is a person, not that there is a price.
                  _pad(_Head(
                      eyebrow: hinglish ? 'Log' : 'People',
                      title: hinglish ? 'Expert se baat karein' : 'Talk to experts',
                      p: p)),
                  const SizedBox(height: 12),
                  _pad(_LinkCard(
                    title: hinglish ? 'Fertility experts' : 'Fertility experts',
                    body: hinglish
                        ? 'Gynae, fertility specialist, nutritionist, psychologist — '
                            'video par, aapke waqt par.'
                        : 'A gynaecologist, a fertility specialist, a nutritionist, '
                            'a psychologist — on video, at a time you choose.',
                    p: p,
                    hue: 186,
                    mark: V3DailyMark.capsule,
                    onTap: () => _openSurface(context, 'ttc_prepare'),
                  )),
                  const SizedBox(height: 26),

                  // ---- THE DOOR OUT ----------------------------------------
                  //
                  // ⚠️ THE ONLY WAY TO LEAVE THIS STAGE, and V3 did not have
                  // it. A positive test on the V3 home had nowhere to go: she
                  // would have had to flip back to V1 to tell the app she is
                  // pregnant, which is not a thing anyone would work out.
                  //
                  // Understated on purpose, and it keeps V1's rule: no
                  // celebration styling, no tint block, no eyebrow. It is a
                  // door, and it must never read as "why haven't you tested?".
                  _pad(_TestDoor(p: p)),
                  const SizedBox(height: 22),

                  // ⚠️ EVERY TOOL CARRIES THIS AND THE BUSIEST SCREEN DID NOT
                  // — which is backwards, because Today is where an estimate is
                  // read fastest and questioned least. Same words as V1, in
                  // this palette.
                  _pad(_HomeDisclaimer(p: p)),
                ]),
              ],
            ),

            // ---- THE DEV SWITCH --------------------------------------------
            //
            // TESTING-ONLY Her | Him pill, at the same coordinates `TtcPage`
            // floats it for V1 (right 14, bottom 96) so it does not appear to
            // move when the toggle is flipped. Remove before launch, with V1's.
            Positioned(
              right: 14,
              // Same fix as the version pill on the opposite corner: a literal
              // 96 sits behind the tab bar wherever the device has a system
              // navigation inset. See `pvNavClearance`.
              bottom: pvNavClearance(context),
              child: ttcModePill(TtcS.current(), him: false),
            ),

            // ---- THE NAV ---------------------------------------------------
            //
            // ⚠️ V3 SHIPPED WITHOUT ONE, AND THAT WAS THE LARGEST HOLE IN IT.
            // `TtcTodayScreen` (V1) gets its nav from `TtcPage`; this screen
            // builds its own Scaffold because the field has to be the page's
            // surface rather than something inside a gutter — so it inherited
            // no nav, and Prepare · Tools · Calendar · Community simply did not
            // exist in V3. Four of five tabs unreachable is not a home.
            //
            // ⚠️ THE SAME FIVE TABS AS V1, DELIBERATELY, and not a V3-specific
            // set. Two reasons, both load-bearing:
            //
            //   · This is an A/B toggle. Changing the nav AND the home means a
            //     reaction to V3 cannot be attributed to either one.
            //   · CLAUDE.md forbids per-pathway navigation — personalisation
            //     changes content, ranking and order, never structure. A
            //     version that navigates differently makes the V1→V3 crossing
            //     the thing she has to relearn, which is the exact cost this
            //     stage's shared widgets exist to avoid.
            //
            // `TtcBottomNav` is already a free-floating pill positioned in a
            // Stack, so this is a drop-in rather than a layout change.
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: SafeArea(
                  top: false, child: TtcBottomNav(active: 0, v3: true)),
            ),
          ]),
        );
      },
    );
  }

  void _openBracket(BuildContext context, String id) {
    final b = bracketById(id);
    if (b == null) return;
    final hinglish = TtcLang.instance.hinglish;

    // ⚠️ THE HUB REGISTRY DECIDES, NOT THIS SCREEN.
    //
    // Two outcomes: a hub with 2+ doors pushes the hub screen; a hub with ONE
    // door opens that door's destination directly, because a screen whose only
    // content restates the tile she just tapped is a tap of pure tax. See
    // lib/data/hubs/hub_registry.dart.
    final hub = hubFor(id);
    if (hub != null) {
      final sole = soleDoorOf(id);
      if (sole != null) {
        if (sole.action != null) {
          _hubAction(context, sole.action!);
        } else if (sole.surfaceId != null) {
          _openSurface(context, sole.surfaceId!);
        }
        return;
      }
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'hub/' + id),
        builder: (_) => ProblemHubScreen(
          config: hub,
          bracket: b,
          lang: hinglish ? AppLanguage.hinglish : AppLanguage.english,
          listenTo: V2PaletteStore.instance,
          onSurface: _openSurface,
          onAction: _hubAction,
        ),
      ));
      return;
    }


    Navigator.of(context).push(MaterialPageRoute(
      settings: const RouteSettings(name: 'bracket_detail'),
      builder: (_) => BracketScreen(
        bracket: b,
        // ⚠️ TTC's language flag, not the pregnancy `AppLanguage` store. The two
        // are separate on purpose — this stage is still Hinglish and pregnancy
        // is Devanagari, and reading the wrong one would render Devanagari rows
        // inside a Hinglish shell.
        lang: hinglish ? AppLanguage.hinglish : AppLanguage.english,
        labelFor: (surfaceId) =>
            ttcSurfaceLabel(surfaceId, hinglish: hinglish),
        onOpenSurface: _openSurface,
      ),
    ));
  }

  /// The TTC hub actions.
  ///
  /// WARNING: every one either reuses a LIVE surface or says plainly that it is
  /// owed. None of them opens a vaguely-related screen and hopes -- that looks
  /// like an answer, wastes her time, and makes her think she failed to find it.
  void _hubAction(BuildContext context, String action) {
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
        settings: const RouteSettings(name: 'ttc/owed'),
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

    switch (action) {
      // The booking engine, configured -- never a new appointment feature.
      // Scoped to the consult category. Unscoped, this opened nine categories
      // and asked her to scroll past yoga and nutrition to reach the card she
      // had just tapped a button about.
      case kTtcActConsult:
        Navigator.of(context).push(MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'ttc/consults'),
          builder: (_) => const TtcPrepareScreen(onlyCategory: 'consults'),
        ));

      // WARNING: timing and habits ONLY. This must never become a computed
      // "your chance this month" -- no personalised probability, ever.
      case kTtcActImproveChances:
        owed('Improve my chances this cycle',
            'Timing through your fertile days, and the handful of habits that '
            'genuinely make a difference. No numbers about your odds -- those '
            'are not ours to give.',
            meanwhile: 'Your cycle',
            meanwhileWhy: 'Track where you are this month.',
            surface: 'ttc_cycle');

      case kTtcActSpermHealth:
        owed('Understand sperm health',
            'What a semen analysis actually measures, what the numbers mean, '
            'and the ninety-day window that makes changes worth making.',
            meanwhile: 'For him, today',
            meanwhileWhy: 'His side of it, one thing at a time.',
            surface: 'ttc_partner');

      case kTtcActPcosLibrary:
        owed('Understand my PCOS',
            'What PCOS is doing to your cycle, in plain words, and what the '
            'usual next steps look like.',
            meanwhile: 'Your cycle',
            meanwhileWhy: 'See how your own cycle is behaving.',
            surface: 'ttc_cycle');

      case kTtcActFertilityReadinessCheck:
        owed('Should I seek fertility help?',
            'The guidance on how long to try before seeing someone, by age -- '
            'so you can decide, rather than wonder.',
            meanwhile: 'Tests worth knowing about',
            meanwhileWhy: 'What a first appointment usually checks.',
            surface: 'ttc_tests');

      case kTtcActPreconceptionReadiness:
        owed('Get ready before trying',
            'The few things worth doing in the months before -- supplements, '
            'checks, and what your partner should do too.',
            meanwhile: 'Supplements',
            meanwhileWhy: 'What to start, and when.',
            surface: 'ttc_supplements');

      // WARNING: no "meanwhile" here, deliberately. After a loss, being handed
      // a cycle tracker instead of what she asked for is worse than being told
      // honestly that it is not ready.
      case kTtcActLossRecoveryLibrary:
        owed('Understand recovery and trying again',
            'What your body needs before trying again, how long is usually '
            'suggested, and what to expect of yourself. At your pace.');
    }
  }

  void _openSurface(BuildContext context, String id) {
    final screen = ttcScreenForSurface(id);
    // Null is a real answer — see the router. Nothing happens rather than
    // something wrong.
    if (screen == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(name: id),
      builder: (_) => screen,
    ));
  }
}

Widget _pad(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: child);

// =============================================================================
//  The cycle header
// -----------------------------------------------------------------------------
//  The week, the window, and the two things she came to do.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE BIG LINE IS A TIMING ESTIMATE AND IT IS NEVER A PROBABILITY
//  ---------------------------------------------------------------------------
//
//  The obvious headline for a fertility home — the one every competitor
//  prints — is a chance. This one states WHEN, never HOW LIKELY, and the
//  distinction is not stylistic:
//
//    · "Your fertile days open in 5 days" is a timing estimate built from a
//      logged period and an assumed luteal phase. The app already makes it, on
//      the cycle companion and the window screen, and it is honest about being
//      an estimate.
//    · A percentage attached to her, this cycle, is a personalised probability.
//      Forbidden outright — CLAUDE.md, and `test/ttc_clinical_review_test.dart`
//      scans source for it rather than trusting a seed list.
//
// ⚠️ AND THE SCANNER READS COMMENTS TOO, WHICH IS WHY THAT SECOND BULLET IS
// DESCRIBED RATHER THAN QUOTED. Writing the forbidden sentence out as an
// example of what not to do failed the test, correctly: a regex cannot tell an
// illustration from a claim, and a comment is one careless copy-paste from
// being a string. Describe the shape, never type the line.
//
//  ⚠️ AND IT REFUSES, LOUDLY, IN THREE CASES. Nothing logged, a clinic holding
//  the timing, or an engine that has declined to estimate all produce a
//  SENTENCE rather than a number. `ttcFertileWindowNow` returns null for the
//  last two and the header says which. The failure this prevents is the one
//  already written up in `TtcNoEstimate`: "ovulation around day 40" appearing
//  on five screens from a single unlogged gap.
//
//  ⚠️ TWO ACTIONS, NOT SEVEN. Edit period dates and check symptoms — the two
//  things that make every estimate on this page better, and nothing else. A
//  header is the most valuable strip on a screen and the most tempting place
//  to put a row of shortcuts; a row of shortcuts is what the V3 field exists to
//  replace.
// =============================================================================

class _CycleHeader extends StatelessWidget {
  const _CycleHeader({
    required this.today,
    required this.p,
    required this.hinglish,
    required this.onChapter,
    required this.onCycle,
    required this.onCalendar,
    required this.onProfile,
  });

  final TtcToday today;
  final V2Palette p;
  final bool hinglish;
  final VoidCallback onChapter;
  final VoidCallback onCycle;
  final VoidCallback onCalendar;
  final VoidCallback onProfile;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    final now = DateTime.now();

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ---- avatar · date · calendar ------------------------------------
          Row(children: [
            _RoundButton(
                icon: Icons.person_outline_rounded,
                p: p,
                onTap: onProfile,
                semantic: t.profileTitle),
            const Spacer(),
            Text('${now.day} ${_months[now.month - 1]}',
                style: pvManrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
                    color: p.ink1)),
            const Spacer(),
            // ⚠️ THE CALENDAR HAD NO ENTRANCE ON THIS HOME AT ALL before the
            // header. It was a nav tab and nothing else, which meant the one
            // screen showing a whole month of her own logs was reachable only
            // by knowing which of five icons it hid behind.
            _RoundButton(
                icon: Icons.calendar_today_rounded,
                p: p,
                onTap: onCalendar,
                semantic: t.tabCalendar),
          ]),
          const SizedBox(height: 16),

          // ---- the week ----------------------------------------------------
          _WeekStrip(p: p, hinglish: hinglish, onTap: onCalendar),
          const SizedBox(height: 20),

          // ---- which chapter -----------------------------------------------
          V3SpineChip(
            label: today.chapter.title(hinglish).toUpperCase(),
            tone: V3HeroTone.onField,
            p: p,
            onTap: onChapter,
          ),
          const SizedBox(height: 12),

          // ---- the window, or the honest refusal ---------------------------
          _WindowLine(today: today, p: p, hinglish: hinglish, onTap: onCycle),
          const SizedBox(height: 18),

          // ---- the two actions ---------------------------------------------
          Row(children: [
            Expanded(
              child: _HeaderAction(
                label: t.headerEditPeriod,
                icon: Icons.water_drop_outlined,
                p: p,
                filled: true,
                onTap: () => logTtcPeriod(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _HeaderAction(
                label: t.headerCheckSymptoms,
                icon: Icons.favorite_border_rounded,
                p: p,
                filled: false,
                // ⚠️ THE SYMPTOMS TRACKER BY ID, not `ttc_tracker` — the
                // surface router deliberately refuses that id because
                // `TtcTrackerScreen` needs to be told WHICH tracker and
                // dropping her into an arbitrary one is the wrong-screen
                // failure it exists to prevent. See the comment in
                // `ttc_surface_router.dart`.
                onTap: () => openTtcTracker(context, 'symptoms'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

/// The seven days around today.
///
/// ⚠️ IT READS `ttcFactsFor`, THE CALENDAR'S OWN ENGINE. Every marker here —
/// period start, fertile day, ovulation, expected period, "something logged" —
/// is the same function the month grid calls, so a day cannot be coral in the
/// header and plain in the calendar. Re-deriving them from `CycleStore` would
/// have been four lines shorter and the two would have drifted the first time
/// either changed.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip(
      {required this.p, required this.hinglish, required this.onTap});

  final V2Palette p;
  final bool hinglish;
  final VoidCallback onTap;

  static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Today sits fourth of seven, so there is always context on both sides.
    final first = today.subtract(const Duration(days: 3));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 7; i++)
            _WeekDay(
              date: DateTime(first.year, first.month, first.day + i),
              isToday: i == 3,
              letter: _dayLetters[
                  (DateTime(first.year, first.month, first.day + i).weekday -
                          1) %
                      7],
              p: p,
            ),
        ],
      ),
    );
  }
}

class _WeekDay extends StatelessWidget {
  const _WeekDay({
    required this.date,
    required this.isToday,
    required this.letter,
    required this.p,
  });

  final DateTime date;
  final bool isToday;
  final String letter;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final TtcDayFacts facts = ttcFactsFor(date);

    // ⚠️ INTENSITY AND SHAPE, NOT A TRAFFIC LIGHT. Same rule the day bars on
    // the window screen follow: a period day is a filled coral disc, a fertile
    // day is a soft teal disc, an expected period is a dashed outline. A
    // greyscale screenshot and a colour-blind eye both still read it, which a
    // red-amber-green week would not.
    final isFertile = facts.fertility != null &&
        facts.fertility != FertilityLevel.low;

    Color? fill;
    Color? ring;
    if (facts.isPeriodStart) {
      fill = ttcCoral;
    } else if (isFertile) {
      fill = ttcFertilityTint(facts.fertility!);
    } else if (facts.isExpectedPeriod) {
      ring = ttcCoral;
    }

    final onFill = fill == ttcCoral ? Colors.white : p.ink1;

    return Column(children: [
      Text(letter,
          style: pvManrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: p.ink3)),
      const SizedBox(height: 7),
      Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: ring != null
              ? Border.all(color: ring, width: 1.4)
              : isToday
                  ? Border.all(color: p.action, width: 2)
                  : null,
        ),
        child: Text('${date.day}',
            style: pvManrope(
                fontSize: 13.5,
                fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                color: fill != null ? onFill : p.ink1)),
      ),
      const SizedBox(height: 5),
      // A single dot for "you logged something here" — the calendar's own
      // `calendarLogged` marker, at week scale.
      SizedBox(
        height: 5,
        child: facts.loggedTrackers.isEmpty && facts.journalEntries.isEmpty
            ? null
            : Container(
                width: 4,
                height: 4,
                decoration:
                    BoxDecoration(color: p.action, shape: BoxShape.circle)),
      ),
    ]);
  }
}

/// The one big line: when her days are, or why we will not say.
class _WindowLine extends StatelessWidget {
  const _WindowLine(
      {required this.today,
      required this.p,
      required this.hinglish,
      required this.onTap});

  final TtcToday today;
  final V2Palette p;
  final bool hinglish;
  final VoidCallback onTap;

  static const _short = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static String _fmt(DateTime d) => '${d.day} ${_short[d.month - 1]}';

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();

    // ---- the refusals, in order of authority -------------------------------
    if (today.noEstimate == TtcNoEstimate.noPeriodLogged) {
      return _block(t.headerStartHere, t.headerStartHereBody);
    }
    if (today.clinicInvolved) {
      return _block(t.headerClinicHolds, t.headerClinicHoldsBody);
    }

    final window = ttcFertileWindowNow();
    if (window == null) {
      return _block(t.headerNoEstimate, t.headerNoEstimateBody);
    }

    // ---- the estimate ------------------------------------------------------
    final headline = window.openNow
        ? t.headerWindowOpenNow
        : t.headerWindowOpensIn(window.daysUntilOpen);

    // ⚠️ A PROJECTED WINDOW SAYS SO. `cyclesAhead > 0` means this cycle's
    // window has already closed and we have rolled forward on an ASSUMED cycle
    // length — a guess resting on a guess. Presenting that with the same
    // confidence as the current cycle's window is the exact overreach
    // `TtcNoEstimate` exists to stop.
    final sub = window.cyclesAhead > 0
        ? t.headerWindowProjected(
            _fmt(window.opensOn), _fmt(window.closesOn))
        : t.headerWindowDates(_fmt(window.opensOn), _fmt(window.closesOn));

    return _block(headline, sub, cycleDay: today.cycleDay);
  }

  Widget _block(String headline, String body, {int? cycleDay}) {
    final t = TtcS.current();
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(headline,
            style: pvFraunces(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                height: 1.12,
                letterSpacing: -1,
                color: p.ink1)),
        const SizedBox(height: 6),
        Text(body,
            style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
        if (cycleDay != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            Text(t.headerCycleDay(cycleDay),
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: p.action)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_rounded, size: 14, color: p.action),
          ]),
        ],
      ]),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton(
      {required this.icon,
      required this.p,
      required this.onTap,
      required this.semantic});

  final IconData icon;
  final V2Palette p;
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
            child: Icon(icon, size: 18, color: p.ink2),
          ),
        ),
      );
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.label,
    required this.icon,
    required this.p,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final V2Palette p;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: filled ? p.surface : p.surface.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: filled ? p.surface : p.line),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: p.action),
            const SizedBox(width: 7),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: p.ink1)),
            ),
          ]),
        ),
      );
}

// -----------------------------------------------------------------------------
//  The hero
// -----------------------------------------------------------------------------

// ⚠️ SUPERSEDED BY `_CycleHeader`, KEPT FOR REVERT.
//
// The chapter hero: a spine chip, "Day 6 in this chapter", and the one
// forward-looking line. Every clinical argument in it still stands — no
// denominator, no countdown to an outcome, an invitation rather than a zero
// — and the header that replaced it obeys all three. What changed is which
// question the top of the page answers: "where am I in this chapter" became
// "where am I in this cycle, and when are my days".
//
// Uncomment this and re-point the `_CycleHeader(...)` call in `build` to put
// it back; nothing else moved.
// class _Hero extends StatelessWidget {
//   const _Hero(
//       {required this.today,
//       required this.p,
//       required this.hinglish,
//       required this.onSpine,
//       required this.onSaved,
//       required this.onProfile});
//
//   final TtcToday today;
//   final V2Palette p;
//   final bool hinglish;
//   final VoidCallback onSpine;
//   final VoidCallback onSaved;
//   final VoidCallback onProfile;
//
//   @override
//   Widget build(BuildContext context) {
//     final chapter = today.chapter;
//     final logged = today.noEstimate != TtcNoEstimate.noPeriodLogged;
//
//     return SizedBox(
//       height: 300,
//       child: SafeArea(
//         bottom: false,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ⚠️ NO "OF 4". Parenting's eyebrow reads "PHASE 1 OF 20" because
//               // parenting's phases run once, in order, and end. TTC chapters
//               // come round again with every cycle, so a denominator would draw
//               // a finish line across something that loops.
//               //
//               // ink2 rather than ink3, for the reason written out in
//               // pp_home_v3.dart: a grey calibrated for a neutral ground loses
//               // contrast on a tinted one faster than it loses lightness.
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: V3HeroChrome(
//                   tone: V3HeroTone.onField,
//                   p: p,
//                   onSaved: onSaved,
//                   onProfile: onProfile,
//                 ),
//               ),
//               const Spacer(),
//               // ⚠️ THE EYEBROW IS THE DOOR TO THE JOURNEY MAP. Same move as the
//               // other two stages, and it lands hardest here: TTC's chapters
//               // RECUR, so "where am I in the whole thing" is the question this
//               // stage generates most often and had no answer to on V3.
//               //
//               // No denominator in the label — see the hero note. The chip says
//               // which chapter, never which of how many.
//               V3SpineChip(
//                 label: chapter.title(hinglish).toUpperCase(),
//                 tone: V3HeroTone.onField,
//                 p: p,
//                 onTap: onSpine,
//               ),
//               const SizedBox(height: 10),
//               if (logged) ...[
//                 Text(
//                     hinglish
//                         ? 'Din ${today.daysIntoChapter}'
//                         : 'Day ${today.daysIntoChapter}',
//                     style: pvFraunces(
//                         fontSize: 42,
//                         fontWeight: FontWeight.w600,
//                         height: 1.05,
//                         letterSpacing: -1.3,
//                         color: p.ink1)),
//                 const SizedBox(height: 2),
//                 Text(
//                     hinglish
//                         ? 'is chapter mein, ${today.chapterLength} mein se'
//                         : 'in this chapter, of about ${today.chapterLength}',
//                     style: pvManrope(
//                         fontSize: 13.5,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 0.3,
//                         color: p.ink2)),
//               ] else ...[
//                 // ⚠️ THE INVITATION, NOT A ZERO. "Day 0" is what the parenting
//                 // hero shipped with for a fortnight and it is worse here: a
//                 // number implies we are counting something, and before a period
//                 // is logged we are counting nothing. `noPeriodLogged` is a real
//                 // state with its own sentence.
//                 Text(hinglish ? 'Shuruaat' : 'Start here',
//                     style: pvFraunces(
//                         fontSize: 38,
//                         fontWeight: FontWeight.w600,
//                         height: 1.05,
//                         letterSpacing: -1.2,
//                         color: p.ink1)),
//                 const SizedBox(height: 2),
//                 Text(
//                     hinglish
//                         ? 'Apna last period log karein, phir yahan aapki rhythm dikhegi'
//                         : 'Log your last period, and your rhythm shows up here',
//                     style: pvManrope(
//                         fontSize: 13.5,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 0.3,
//                         height: 1.4,
//                         color: p.ink2)),
//               ],
//               const SizedBox(height: 14),
//               // The one forward-looking line, and it names a TRIGGER rather
//               // than a date. `nextUp` is the string the hero test guards.
//               Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Container(
//                   margin: const EdgeInsets.only(top: 6),
//                   width: 6,
//                   height: 6,
//                   decoration: BoxDecoration(
//                       color: p.ink2.withValues(alpha: 0.5),
//                       shape: BoxShape.circle),
//                 ),
//                 const SizedBox(width: 9),
//                 Expanded(
//                   child: Text(chapter.nextUp(hinglish),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: pvManrope(
//                           fontSize: 13.5, height: 1.45, color: p.ink2)),
//                 ),
//               ]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// -----------------------------------------------------------------------------
//  Shared shapes — identical to parenting's, different content
// -----------------------------------------------------------------------------

class _Sheet extends StatelessWidget {
  const _Sheet({required this.p, required this.children});

  final V2Palette p;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        // The sheet owns the bottom clearance. See the long note on parenting's
        // `_Sheet`: once the background belongs to the page, every piece of
        // padding in the scroll view is a window onto it.
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
          const SizedBox(height: 150),
        ]),
      );
}

class _Head extends StatelessWidget {
  const _Head({required this.eyebrow, required this.title, required this.p});

  final String eyebrow;
  final String title;
  final V2Palette p;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ⚠️ `p.action`, NOT `p.ink3` — the section eyebrow is PURPLE on every
        // other V3 screen, and this copy of `_Head` shipped grey.
        //
        // The mechanism is worth naming because it will happen again: the
        // shape was copied from pregnancy and parenting by hand, and one
        // colour token drifted in the copying. Nothing failed — grey is a
        // legal colour, the layout is identical, and no test looks at a
        // Color. It is only visible by putting the three screens side by side,
        // which is exactly what a copied widget makes nobody do.
        //
        // The real fix is a shared `_Head`; it is not shared today because the
        // three take different label types. Until then this comment is the
        // guard.
        //
        // ⚠️ AN EMPTY EYEBROW RENDERS NOTHING, rather than an empty line. The
        // doors section dropped its eyebrow when it moved up the page, and
        // without this guard a blank `Text` still reserved its line height and
        // its 5px gap — a gap nobody could account for by reading the call.
        if (eyebrow.isNotEmpty) ...[
          Text(eyebrow.toUpperCase(),
              style: pvManrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: p.action)),
          const SizedBox(height: 5),
        ],
        Text(title,
            style: pvFraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.5,
                color: p.ink1)),
      ]);
}

/// Title, subtitle, then a paragraph — for a section that has to explain itself
/// before it can be used.
///
/// ⚠️ THE ONLY SECTION ON THIS PAGE THAT EARNS THREE LEVELS. Every other head
/// is an eyebrow and a title, because every other section is self-evident from
/// the thing under it: a grid of doors, a rail of products, a journal. The
/// samskar is not. "Daily Preconception Samskar" over five tick-boxes is a
/// phrase most people meet for the first time here, and a section whose name
/// needs a sentence should be given the sentence rather than left to be
/// guessed at from the tasks.
class _SectionIntro extends StatelessWidget {
  const _SectionIntro(
      {required this.title,
      required this.subtitle,
      required this.body,
      required this.p});

  final String title;
  final String subtitle;
  final String body;
  final V2Palette p;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: pvFraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.5,
                color: p.ink1)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: pvManrope(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: p.action)),
        const SizedBox(height: 9),
        Text(body,
            style: pvManrope(fontSize: 13.5, height: 1.55, color: p.ink2)),
      ]);
}

// ⚠️ SUPERSEDED BY `_CycleHeader` + `_WindowLine`, KEPT FOR REVERT.
//
// The rule this card was written around is the one that matters and it has
// been carried into the header verbatim: it shows POSITION and refuses to
// show PROBABILITY, and when confidence is unknown it says the app has
// nothing to lean on rather than printing an estimate anyway.
// /// The cycle spine, as one card.
// ///
// /// ⚠️ IT SHOWS POSITION AND REFUSES TO SHOW PROBABILITY. `fertility` is a level
// /// this app is allowed to name; a percentage is not, and neither is anything
// /// that reads as a target. When confidence is unknown the card says the app has
// /// nothing to lean on rather than printing an estimate anyway — the exact
// /// failure `TtcNoEstimate` was added to stop, after "ovulation around day 40"
// /// appeared on five screens from a single unlogged gap.
// class _SpineCard extends StatelessWidget {
//   const _SpineCard(
//       {required this.today,
//       required this.p,
//       required this.hinglish,
//       required this.onTap});
//
//   final TtcToday today;
//   final V2Palette p;
//   final bool hinglish;
//   final VoidCallback onTap;
//
//   String get _line {
//     if (today.noEstimate == TtcNoEstimate.noPeriodLogged) {
//       return hinglish
//           ? 'Abhi tak kuch log nahi hua. Pehla period log karte hi cycle yahan banna shuru ho jayega.'
//           : 'Nothing logged yet. Log one period and your cycle starts taking shape here.';
//     }
//     if (today.clinicInvolved) {
//       // ⚠️ WE DEFER, WE DO NOT COMPUTE. When a clinic owns the timing, an app
//       // estimate beside it is a second opinion she did not ask for. Truth
//       // hierarchy: treating clinician outranks ParentVeda's calculation by six
//       // places.
//       return hinglish
//           ? 'Aapki clinic timing sambhaal rahi hai. Hum yahan sirf aapke saath chal rahe hain — apna hisaab nahi laga rahe.'
//           : 'Your clinic is holding the timing. We are keeping you company here, '
//               'not running our own numbers alongside theirs.';
//     }
//     if (today.confidence == OvulationConfidence.unknown) {
//       return hinglish
//           ? 'Abhi itna record nahi hai ki hum kuch keh sakein. Jaise-jaise aap log karengi, yeh saaf hota jayega.'
//           : 'Not enough logged yet for us to say anything useful. It gets clearer as you go.';
//     }
//     return hinglish
//         ? 'Cycle day ${today.cycleDay}. Aapki rhythm, jitna abhi tak pata hai.'
//         : 'Cycle day ${today.cycleDay}. Your rhythm, as far as we know it.';
//   }
//
//   @override
//   Widget build(BuildContext context) => InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(20),
//         child: Container(
//           padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
//           decoration: BoxDecoration(
//             color: p.surface,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: p.line),
//           ),
//           child:
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(_line,
//                 style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
//             const SizedBox(height: 12),
//             Row(children: [
//               Text(hinglish ? 'Cycle kholein' : 'Open your cycle',
//                   style: pvManrope(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       color: p.action)),
//               const SizedBox(width: 4),
//               Icon(Icons.arrow_forward_rounded, size: 15, color: p.action),
//             ]),
//           ]),
//         ),
//       );
// }

/// A titled card with a drawn mark. The shape every "one thing" section on the
/// other two stages uses.
class _LinkCard extends StatelessWidget {
  const _LinkCard(
      {required this.title,
      required this.body,
      required this.p,
      required this.hue,
      required this.mark,
      required this.onTap});

  final String title;
  final String body;
  final V2Palette p;
  final double hue;
  final V3DailyMark mark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue, p);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SizedBox(
                width: 28, height: 28, child: V3DailyArt(mark: mark, tint: tint)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: pvFraunces(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      letterSpacing: -0.3,
                      color: p.ink1)),
              const SizedBox(height: 5),
              Text(body,
                  style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// =============================================================================
//  The gates V1 had and V3 did not
// -----------------------------------------------------------------------------
//  Everything below is a V1 home component restated in the V3 palette. None of
//  it is new product: same data, same destinations, same words where the words
//  were already right. The V1/V3 pill is an A/B on how the home LOOKS, and the
//  moment one side can reach something the other cannot, the comparison stops
//  being about that.
//
//  ⚠️ THE DESTINATIONS ARE SHARED, NOT COPIED. `showTtcRowSheet`,
//  `TtcInsightScreen`, `openTtcChapter`, `openTtcProducts` and
//  `recordPositiveTest` are the same functions V1 calls. A second set styled
//  for V3 would be two things to keep in step, and this file already carries a
//  comment about a `_Head` that drifted a colour by being copied once.
// =============================================================================

// =============================================================================
//  The three rails
// =============================================================================

/// The five daily items, as circles.
///
/// ⚠️ THE SAME FIVE DESTINATIONS AND THE SAME FIVE OFFSETS as the card-and-rows
/// group this replaced. `ttcPickForToday` is a deterministic day-of-year
/// rotation, so an offset is not decoration — it is what stops the myth and the
/// movement being drawn from the same index every morning. Change one here and
/// V1 and V3 show different content on the same day, which is the one thing an
/// A/B toggle must not do.
///
/// ⚠️ THE CAPTIONS ARE THE SHIPPED STRINGS. `todaysInsight`, `todaysMyth`,
/// `todaysNutrition`, `todaysMovement`, `todaysPick` — not new labels that mean
/// the same thing. Two reasons: the Hinglish halves already exist, and
/// `test/ttc_home_v3_parity_test.dart` finds these five by text to prove V3
/// still reaches what V1 reaches. A hand-typed copy would look identical and
/// fail the test, which is precisely the failure already written up against
/// `todaysInsight`'s curly apostrophe.
///
/// ⚠️ DRAWN MARKS, NOT PHOTOGRAPHS. The reference this shape came from uses
/// image thumbnails; we have no per-item art and inventing an asset pipeline
/// for five rotating items is not the job. `V3DailyArt` in a tinted disc is the
/// stage's existing visual language and degrades honestly — see the note in
/// docs/STILL-OPEN.md if real thumbnails are ever commissioned.
class _DailyRail extends StatelessWidget {
  const _DailyRail({required this.p, required this.hinglish});

  final V2Palette p;
  final bool hinglish;

  @override
  Widget build(BuildContext context) {
    final hi = hinglish;
    final t = TtcS.current();

    final insight = ttcPickForToday(ttcInsights);
    final myth = ttcPickForToday(ttcMyths, offset: 3);
    final n = ttcPickForToday(ttcNutrition, offset: 1);
    final m = ttcPickForToday(ttcMovements, offset: 2);
    final product = ttcPickForToday(ttcProducts, offset: 4);

    return SizedBox(
      height: 128,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        children: [
          _Story(
            caption: t.todaysInsight,
            hue: 206,
            mark: V3DailyMark.note,
            p: p,
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => TtcInsightScreen(insight: insight),
              settings: const RouteSettings(name: 'ttc/insight'),
            )),
          ),
          _Story(
            caption: t.todaysMyth,
            hue: 42,
            mark: V3DailyMark.voice,
            p: p,
            onTap: () => showTtcRowSheet(
              context,
              eyebrow: t.todaysMyth,
              title: myth.myth(hi),
              body: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: ttcPanel,
                    borderRadius: BorderRadius.circular(ttcCardRadius),
                  ),
                  child: Text(myth.truth(hi),
                      style: ttcBody(14, color: ttcTitleInk, h: 1.65)),
                ),
              ],
            ),
          ),
          _Story(
            caption: t.todaysNutrition,
            hue: 104,
            mark: V3DailyMark.capsule,
            p: p,
            onTap: () => showTtcRowSheet(
              context,
              eyebrow: n.nutrient(hi),
              title: n.meal(hi),
              body: [
                Text(n.why(hi), style: ttcBody(14, color: ttcInk, h: 1.7)),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF6EC),
                    borderRadius: BorderRadius.circular(ttcCardRadius),
                  ),
                  child: Text(n.indian(hi),
                      style: ttcBody(13.5, color: ttcBrown, h: 1.6)),
                ),
              ],
            ),
          ),
          _Story(
            caption: t.todaysMovement,
            hue: 160,
            mark: V3DailyMark.memory,
            p: p,
            onTap: () => showTtcRowSheet(
              context,
              eyebrow: t.todaysMovement,
              title: m.title(hi),
              body: [
                Text(m.body(hi), style: ttcBody(14, color: ttcInk, h: 1.7)),
              ],
            ),
          ),
          _Story(
            caption: t.todaysPick,
            hue: 344,
            mark: V3DailyMark.photo,
            p: p,
            // The product rail below shows the catalogue; this circle keeps the
            // one rotating pick V1 has, so the two homes still agree.
            onTap: () => openTtcProducts(context),
            tooltip: product.name(hi),
          ),
        ],
      ),
    );
  }
}

/// One circle and its caption.
class _Story extends StatelessWidget {
  const _Story({
    required this.caption,
    required this.hue,
    required this.mark,
    required this.p,
    required this.onTap,
    this.tooltip,
  });

  final String caption;
  final double hue;
  final V3DailyMark mark;
  final V2Palette p;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue, p);
    return Semantics(
      button: true,
      label: tooltip == null ? caption : '$caption — $tooltip',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 82,
          child: Column(children: [
            Container(
              width: 66,
              height: 66,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: tint,
                shape: BoxShape.circle,
                // The ring is what makes it read as a story rather than a
                // button. Same tint, one step darker, so it never becomes a
                // second colour to account for.
                border: Border.all(
                    color: HSLColor.fromColor(tint)
                        .withSaturation(0.42)
                        .withLightness(0.72)
                        .toColor(),
                    width: 2),
              ),
              child: V3DailyArt(mark: mark, tint: tint),
            ),
            const SizedBox(height: 8),
            Text(caption.toUpperCase(),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    height: 1.35,
                    color: p.ink2)),
          ]),
        ),
      ),
    );
  }
}

/// Products worth having, as a rail.
class _ProductRail extends StatelessWidget {
  const _ProductRail({required this.p, required this.hinglish});

  final V2Palette p;
  final bool hinglish;

  @override
  Widget build(BuildContext context) {
    // Four, taken off the same deterministic rotation the daily pick uses so
    // the rail is stable within a day and moves between them.
    final picks = [
      for (var i = 0; i < 4; i++) ttcPickForToday(ttcProducts, offset: 4 + i),
    ];

    return SizedBox(
      height: 158,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: picks.length,
        separatorBuilder: (_, _) => const SizedBox(width: 11),
        itemBuilder: (context, i) {
          final product = picks[i];
          final tint = v2BlockTint((344 + (i * 24)) % 360, p);
          return InkWell(
            onTap: () => openTtcProducts(context),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 158,
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
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: tint, borderRadius: BorderRadius.circular(11)),
                      child: Icon(Icons.shopping_bag_outlined,
                          size: 17,
                          color: HSLColor.fromColor(tint)
                              .withSaturation(0.46)
                              .withLightness(0.42)
                              .toColor()),
                    ),
                    const SizedBox(height: 11),
                    Text(product.name(hinglish),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvFraunces(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            letterSpacing: -0.2,
                            color: p.ink1)),
                    const Spacer(),
                    // ⚠️ CATEGORY AND PRICE, NEVER A BENEFIT. See the section
                    // comment: a one-line claim under a supplement on a
                    // fertility home is the shortest route this product has to
                    // an implied promise about her odds.
                    Text(product.category.toUpperCase(),
                        style: pvManrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.9,
                            color: p.ink3)),
                    const SizedBox(height: 3),
                    Text(product.priceEn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: p.ink2)),
                  ]),
            ),
          );
        },
      ),
    );
  }
}

/// Reads from the stage library, as a rail.
class _ReadRail extends StatelessWidget {
  const _ReadRail({required this.p, required this.hinglish});

  final V2Palette p;
  final bool hinglish;

  @override
  Widget build(BuildContext context) {
    if (kTtcReads.isEmpty) return const SizedBox.shrink();
    final picks = [
      for (var i = 0; i < 4 && i < kTtcReads.length; i++)
        kTtcReads[(_dayOfYear() + i) % kTtcReads.length],
    ];

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: picks.length,
        separatorBuilder: (_, _) => const SizedBox(width: 11),
        itemBuilder: (context, i) {
          final read = picks[i];
          final tint = v2BlockTint(read.hue, p);
          return InkWell(
            onTap: () =>
                openTtcSurface(context, '$kTtcReadPrefix${read.id}'),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 196,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: tint,
                          borderRadius: BorderRadius.circular(999)),
                      child: Text(
                          (hinglish ? read.kicker.hi : read.kicker.en)
                              .toUpperCase(),
                          style: pvManrope(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: HSLColor.fromColor(tint)
                                  .withSaturation(0.46)
                                  .withLightness(0.34)
                                  .toColor())),
                    ),
                    const SizedBox(height: 10),
                    Text(hinglish ? read.title.hi : read.title.en,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: pvFraunces(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            letterSpacing: -0.25,
                            color: p.ink1)),
                    const Spacer(),
                    Row(children: [
                      Text(TtcS.current().readOpen,
                          style: pvManrope(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: p.action)),
                      const SizedBox(width: 3),
                      Icon(Icons.arrow_forward_rounded,
                          size: 13, color: p.action),
                    ]),
                  ]),
            ),
          );
        },
      ),
    );
  }

  /// Same day-of-year rotation `ttcPickForToday` uses, so the reads rail turns
  /// over on the same schedule as everything else on this page rather than on
  /// one of its own.
  static int _dayOfYear() {
    final now = DateTime.now();
    return now.difference(DateTime(now.year, 1, 1)).inDays;
  }
}

// ⚠️ SUPERSEDED BY `_DailyRail`, KEPT FOR REVERT. Same insight, same
// destination, same `ttcPickForToday(ttcInsights)` rotation — as a circle in
// the rail rather than a card with the takeaway inlined.
//
// ⚠️ THE ONE THING THE RAIL DOES NOT CARRY is the takeaway panel: the
// sentence meant to survive the day, readable without opening anything. It
// is still on `TtcInsightScreen`, one tap in. If the rail is kept, that is
// the loss to weigh.
// /// Today's insight — the one item here that is genuinely an article.
// class _InsightCardV3 extends StatelessWidget {
//   const _InsightCardV3({required this.p, required this.hinglish});
//
//   final V2Palette p;
//   final bool hinglish;
//
//   @override
//   Widget build(BuildContext context) {
//     final insight = ttcPickForToday(ttcInsights);
//     final tint = v2BlockTint(206, p);
//     return InkWell(
//       onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
//         builder: (_) => TtcInsightScreen(insight: insight),
//         settings: const RouteSettings(name: 'ttc/insight'),
//       )),
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
//         decoration: BoxDecoration(
//           color: p.surface,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: p.line),
//         ),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(children: [
//             // ⚠️ THE SHIPPED STRING, NOT A HAND-TYPED COPY OF IT. The literal
//             // here was 'TODAY’S INSIGHT' with a curly apostrophe while
//             // `todaysInsight` carries a straight one — visually identical,
//             // never equal, and it also meant the Hinglish half was a second
//             // translation of a string that already had one.
//             Text(TtcS.current().todaysInsight.toUpperCase(),
//                 style: pvManrope(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 1.3,
//                     color: p.action)),
//             const Spacer(),
//             Text(TtcS.current().readSeconds(insight.readTime(hinglish)),
//                 style: pvManrope(
//                     fontSize: 11, fontWeight: FontWeight.w700, color: p.ink3)),
//           ]),
//           const SizedBox(height: 9),
//           Text(insight.title(hinglish),
//               style: pvFraunces(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   height: 1.25,
//                   letterSpacing: -0.3,
//                   color: p.ink1)),
//           const SizedBox(height: 7),
//           Text(insight.body(hinglish).split('\n\n').first,
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//               style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
//           const SizedBox(height: 12),
//           // The one takeaway — the part meant to survive the day. Kept from V1
//           // because it is the reason this is a card and not a row.
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: tint,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Text(insight.takeaway(hinglish),
//                 style: pvManrope(
//                     fontSize: 13,
//                     height: 1.45,
//                     fontWeight: FontWeight.w700,
//                     color: p.ink1)),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// ⚠️ SUPERSEDED BY `_DailyRail`, KEPT FOR REVERT. The four rows and their
// four `ttcPickForToday` offsets (myth 3, nutrition 1, movement 2, pick 4)
// moved into the rail UNCHANGED — see the warning there about why those
// numbers are load-bearing rather than arbitrary.
// /// Today's myth, nutrition, movement and pick — four rows in one card.
// class _TodayRows extends StatelessWidget {
//   const _TodayRows({required this.p, required this.hinglish});
//
//   final V2Palette p;
//   final bool hinglish;
//
//   @override
//   Widget build(BuildContext context) {
//     final hi = hinglish;
//     final t = TtcS.current();
//     // ⚠️ THE SAME OFFSETS AS V1. `ttcPickForToday` is a deterministic
//     // day-of-year rotation, so an offset is not decoration — it is what stops
//     // the myth and the movement being drawn from the same index every day.
//     // Change one here and the two homes show different things on the same
//     // morning, which is the one thing an A/B toggle must not do.
//     final myth = ttcPickForToday(ttcMyths, offset: 3);
//     final n = ttcPickForToday(ttcNutrition, offset: 1);
//     final m = ttcPickForToday(ttcMovements, offset: 2);
//     final product = ttcPickForToday(ttcProducts, offset: 4);
//
//     return Container(
//       decoration: BoxDecoration(
//         color: p.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: p.line),
//       ),
//       child: Column(children: [
//         _Row(
//           p: p,
//           hue: 42,
//           icon: Icons.lightbulb_outline_rounded,
//           eyebrow: t.todaysMyth,
//           title: myth.myth(hi),
//           onTap: () => showTtcRowSheet(
//             context,
//             eyebrow: t.todaysMyth,
//             title: myth.myth(hi),
//             body: [
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(15),
//                 decoration: BoxDecoration(
//                   color: ttcPanel,
//                   borderRadius: BorderRadius.circular(ttcCardRadius),
//                 ),
//                 child: Text(myth.truth(hi),
//                     style: ttcBody(14, color: ttcTitleInk, h: 1.65)),
//               ),
//             ],
//           ),
//         ),
//         _Row(
//           p: p,
//           hue: 104,
//           icon: Icons.restaurant_rounded,
//           eyebrow: t.todaysNutrition,
//           title: n.meal(hi),
//           onTap: () => showTtcRowSheet(
//             context,
//             eyebrow: n.nutrient(hi),
//             title: n.meal(hi),
//             body: [
//               Text(n.why(hi), style: ttcBody(14, color: ttcInk, h: 1.7)),
//               const SizedBox(height: 16),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(15),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFDF6EC),
//                   borderRadius: BorderRadius.circular(ttcCardRadius),
//                 ),
//                 child: Text(n.indian(hi),
//                     style: ttcBody(13.5, color: ttcBrown, h: 1.6)),
//               ),
//             ],
//           ),
//         ),
//         _Row(
//           p: p,
//           hue: 160,
//           icon: Icons.directions_walk_rounded,
//           eyebrow: t.todaysMovement,
//           title: m.title(hi),
//           meta: m.minutes > 0 ? t.minutes(m.minutes) : null,
//           onTap: () => showTtcRowSheet(
//             context,
//             eyebrow: t.todaysMovement,
//             title: m.title(hi),
//             body: [
//               Text(m.body(hi), style: ttcBody(14, color: ttcInk, h: 1.7)),
//             ],
//           ),
//         ),
//         _Row(
//           p: p,
//           hue: 344,
//           icon: Icons.shopping_bag_outlined,
//           eyebrow: t.todaysPick,
//           title: product.name(hi),
//           meta: product.priceEn,
//           last: true,
//           onTap: () => openTtcProducts(context),
//         ),
//       ]),
//     );
//   }
// }
//
// class _Row extends StatelessWidget {
//   const _Row({
//     required this.p,
//     required this.hue,
//     required this.icon,
//     required this.eyebrow,
//     required this.title,
//     required this.onTap,
//     this.meta,
//     this.last = false,
//   });
//
//   final V2Palette p;
//   final double hue;
//
//   // ⚠️ A LINE ICON, NOT A `V3DailyMark`. The five marks are deliberately
//   // abstract — they are wallpaper for a section, and on a card the size of the
//   // journal's they read as texture. At 21px in a row they stop being abstract
//   // and start being WRONG: `capsule` is a pill beside a plate of food and
//   // `photo` is a picture frame beside a supplement. V3's hub and journey rows
//   // already use line icons for the same reason.
//   final IconData icon;
//   final String eyebrow;
//   final String title;
//   final String? meta;
//   final bool last;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     final tint = v2BlockTint(hue, p);
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
//         decoration: BoxDecoration(
//           border: last ? null : Border(bottom: BorderSide(color: p.line)),
//         ),
//         child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
//           Container(
//             width: 34,
//             height: 34,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: tint,
//               borderRadius: BorderRadius.circular(11),
//             ),
//             child: Icon(icon,
//                 size: 18,
//                 color: HSLColor.fromColor(tint)
//                     .withSaturation(0.46)
//                     .withLightness(0.42)
//                     .toColor()),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(eyebrow.toUpperCase(),
//                   style: pvManrope(
//                       fontSize: 9.5,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.1,
//                       color: p.ink3)),
//               const SizedBox(height: 3),
//               Text(title,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: pvFraunces(
//                       fontSize: 15.5,
//                       fontWeight: FontWeight.w600,
//                       height: 1.25,
//                       letterSpacing: -0.2,
//                       color: p.ink1)),
//             ]),
//           ),
//           if (meta != null && meta!.isNotEmpty) ...[
//             const SizedBox(width: 10),
//             Text(meta!,
//                 style: pvManrope(
//                     fontSize: 11.5,
//                     fontWeight: FontWeight.w700,
//                     color: p.ink3)),
//           ],
//           const SizedBox(width: 6),
//           Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
//         ]),
//       ),
//     );
//   }
// }

/// Me · Us · What's next — the chapter reader's three tabs, as shortcuts.
class _ChapterTabs extends StatelessWidget {
  const _ChapterTabs({required this.p, required this.chapter});

  final V2Palette p;
  final TtcChapter chapter;

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    Widget chip(String label, IconData icon, TtcChapterTab tab) => Expanded(
          child: InkWell(
            onTap: () => openTtcChapter(context, chapter, tab: tab),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: p.line),
              ),
              child: Column(children: [
                Icon(icon, size: 18, color: p.action),
                const SizedBox(height: 6),
                Text(label,
                    style: pvManrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: p.ink2)),
              ]),
            ),
          ),
        );

    return Row(children: [
      chip(t.shortcutMe, Icons.self_improvement_rounded, TtcChapterTab.me),
      const SizedBox(width: 9),
      chip(t.shortcutUs, Icons.favorite_border_rounded, TtcChapterTab.us),
      const SizedBox(width: 9),
      chip(t.shortcutNext, Icons.event_available_outlined, TtcChapterTab.next),
    ]);
  }
}

/// The door out of the stage. Never a prompt to test.
class _TestDoor extends StatelessWidget {
  const _TestDoor({required this.p});

  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    return InkWell(
      onTap: () => recordPositiveTest(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          // No tint block and no fill — see the section comment. The border
          // alone is what makes it a door rather than an offer.
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        child: Row(children: [
          Icon(Icons.auto_awesome_outlined, size: 18, color: p.ink3),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.transitionRecord,
                  style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink1)),
              const SizedBox(height: 2),
              Text(t.transitionRecordBody,
                  style:
                      pvManrope(fontSize: 11.5, height: 1.45, color: p.ink3)),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// The estimates disclaimer, in this palette.
class _HomeDisclaimer extends StatelessWidget {
  const _HomeDisclaimer({required this.p});

  final V2Palette p;

  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline_rounded, size: 15, color: p.ink3),
        const SizedBox(width: 9),
        Expanded(
          child: Text(TtcS.current().estimatesDisclaimer,
              style: pvManrope(fontSize: 11.5, height: 1.5, color: p.ink3)),
        ),
      ]);
}

/// The daily ritual — done from here, not merely linked to.
///
/// ⚠️ TWO TAP TARGETS PER ROW, AND THAT IS THE DESIGN. The tick completes; the
/// row opens the ritual at that part. Completing must never require reading
/// first — a woman who already knows what "today's breath" means should not
/// have to open a page to say she did it. V1 makes the same split for the same
/// reason.
///
/// ⚠️ ITS OWN `ListenableBuilder`. The page's top-level builder listens to
/// `TtcStore` and `TtcLang` only, so a tick would have changed the store and
/// repainted nothing. Scoping the listener to this card also means ticking one
/// item does not rebuild the doors, the reads and the journal.
class _RitualCardV3 extends StatelessWidget {
  const _RitualCardV3(
      {required this.p, required this.hinglish, required this.chapter});

  final V2Palette p;
  final bool hinglish;
  final TtcChapter chapter;

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    final items = ttcRituals[chapter] ?? const <TtcRitualItem>[];

    return ListenableBuilder(
      listenable: TtcRitualStore.instance,
      builder: (context, _) {
        final store = TtcRitualStore.instance;
        final done = store.completedToday();
        final streak = store.streak();

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 6),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Text(t.dailyRitualBody,
                    style:
                        pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('$done/${store.total}',
                    style: pvFraunces(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                        color: p.action)),
                // ⚠️ A STREAK WITH NOTHING ATTACHED TO IT. No colour, no
                // warning, no "you lost it" state anywhere in the product —
                // this is the stage built to remove pressure, and a streak
                // that can be broken is the commonest way an app puts it back.
                if (streak > 0)
                  Text(t.dayStreak(streak),
                      style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink3)),
              ]),
            ]),
            const SizedBox(height: 14),
            for (var i = 0; i < items.length; i++)
              _RitualRow(
                p: p,
                hinglish: hinglish,
                item: items[i],
                done: store.isDone(items[i].part),
                last: i == items.length - 1,
                onToggle: () => TtcRitualStore.instance.toggle(items[i].part),
                onOpen: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        TtcRitualScreen(chapter: chapter, focus: items[i].part),
                    settings: const RouteSettings(name: 'ttc/ritual'),
                  ),
                ),
              ),
          ]),
        );
      },
    );
  }
}

class _RitualRow extends StatelessWidget {
  const _RitualRow({
    required this.p,
    required this.hinglish,
    required this.item,
    required this.done,
    required this.last,
    required this.onToggle,
    required this.onOpen,
  });

  final V2Palette p;
  final bool hinglish;
  final TtcRitualItem item;
  final bool done;
  final bool last;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        margin: EdgeInsets.only(bottom: last ? 0 : 12),
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: p.line)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              // Generous around a 22px circle: this is the smallest target on
              // the home and the one most often tapped one-handed.
              padding: const EdgeInsets.only(right: 12, top: 1, bottom: 4),
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done ? p.action : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: done ? p.action : p.line, width: 1.6),
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        size: 13, color: Colors.white)
                    : null,
              ),
            ),
          ),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.part.title(hinglish),
                  style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink1)),
              const SizedBox(height: 2),
              Text(item.text(hinglish),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
            ]),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, size: 18, color: p.ink3),
        ]),
      ),
    );
  }
}
