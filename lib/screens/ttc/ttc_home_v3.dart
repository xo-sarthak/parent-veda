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
import '../../ttc/ttc_store.dart';
import '../brackets/bracket_screen.dart';
import '../v2/v2_block_grid.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_bracket_art.dart';
import '../v2/v3_daily.dart';
import '../v2/v3_daily_art.dart';
import '../v2/v3_hero_chrome.dart';
import '../v2/v3_hero_field.dart';
import 'ttc_journey_map_screen.dart';
import 'ttc_profile_screen.dart';
import 'ttc_strings.dart';
import 'ttc_surface_router.dart';

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
              padding: EdgeInsets.zero,
              children: [
                _Hero(
                  today: today,
                  p: p,
                  hinglish: hinglish,
                  onSpine: () => Navigator.of(context).push(MaterialPageRoute(
                      settings: const RouteSettings(name: 'ttc/journey_map'),
                      builder: (_) => const TtcJourneyMapScreen())),
                  // TTC's saved things are its reads; there is no saved hub in
                  // this stage yet, so the bookmark opens the chapter reader
                  // where saving actually happens rather than a screen that
                  // does not exist.
                  onSaved: () => _openSurface(context, 'ttc_chapter'),
                  onProfile: () => openTtcProfile(context),
                ),
                _Sheet(p: p, children: [
                  const SizedBox(height: 26),

                  // ---- THE DOORS -------------------------------------------
                  _pad(_Head(
                      eyebrow: hinglish ? 'Kahan jaana hai' : 'Where to go',
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
                  _pad(_Head(
                      eyebrow: hinglish ? 'Aapki rhythm' : 'Your rhythm',
                      title: hinglish ? 'Aaj kahan hain aap' : 'Where you are today',
                      p: p)),
                  const SizedBox(height: 12),
                  _pad(_SpineCard(
                      today: today,
                      p: p,
                      hinglish: hinglish,
                      onTap: () => _openSurface(context, 'ttc_cycle'))),
                  const SizedBox(height: 32),

                  // ---- PRACTICE --------------------------------------------
                  _pad(_Head(
                      eyebrow: hinglish ? 'Aaj' : 'Today',
                      title: hinglish ? 'Ek chhota abhyas' : 'One small practice',
                      p: p)),
                  const SizedBox(height: 12),
                  _pad(_LinkCard(
                    title: hinglish ? 'Aaj ka abhyas' : "Today's practice",
                    body: hinglish
                        ? 'Saans, thoda movement, ya bas paanch minute shaant. '
                            'Isse kuch "hasil" nahi karna — yeh sirf aapke liye hai.'
                        : 'Breath, a little movement, or five quiet minutes. '
                            'Nothing to achieve here — this part is only for you.',
                    p: p,
                    hue: 42,
                    mark: V3DailyMark.capsule,
                    onTap: () => _openSurface(context, 'ttc_ritual'),
                  )),
                  const SizedBox(height: 32),

                  // ---- READING ---------------------------------------------
                  _pad(_Head(
                      eyebrow: hinglish ? 'Padhne ke liye' : 'To read',
                      title: hinglish ? 'Is chapter ke baare mein' : 'About this chapter',
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
                  const SizedBox(height: 32),

                  // ---- JOURNAL ---------------------------------------------
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
                      title: hinglish ? 'Kisi se baat karni ho to' : 'If you want to talk to someone',
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
                ]),
              ],
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

// -----------------------------------------------------------------------------
//  The hero
// -----------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero(
      {required this.today,
      required this.p,
      required this.hinglish,
      required this.onSpine,
      required this.onSaved,
      required this.onProfile});

  final TtcToday today;
  final V2Palette p;
  final bool hinglish;
  final VoidCallback onSpine;
  final VoidCallback onSaved;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final chapter = today.chapter;
    final logged = today.noEstimate != TtcNoEstimate.noPeriodLogged;

    return SizedBox(
      height: 300,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⚠️ NO "OF 4". Parenting's eyebrow reads "PHASE 1 OF 20" because
              // parenting's phases run once, in order, and end. TTC chapters
              // come round again with every cycle, so a denominator would draw
              // a finish line across something that loops.
              //
              // ink2 rather than ink3, for the reason written out in
              // pp_home_v3.dart: a grey calibrated for a neutral ground loses
              // contrast on a tinted one faster than it loses lightness.
              Align(
                alignment: Alignment.centerRight,
                child: V3HeroChrome(
                  tone: V3HeroTone.onField,
                  p: p,
                  onSaved: onSaved,
                  onProfile: onProfile,
                ),
              ),
              const Spacer(),
              // ⚠️ THE EYEBROW IS THE DOOR TO THE JOURNEY MAP. Same move as the
              // other two stages, and it lands hardest here: TTC's chapters
              // RECUR, so "where am I in the whole thing" is the question this
              // stage generates most often and had no answer to on V3.
              //
              // No denominator in the label — see the hero note. The chip says
              // which chapter, never which of how many.
              V3SpineChip(
                label: chapter.title(hinglish).toUpperCase(),
                tone: V3HeroTone.onField,
                p: p,
                onTap: onSpine,
              ),
              const SizedBox(height: 10),
              if (logged) ...[
                Text(
                    hinglish
                        ? 'Din ${today.daysIntoChapter}'
                        : 'Day ${today.daysIntoChapter}',
                    style: pvFraunces(
                        fontSize: 42,
                        fontWeight: FontWeight.w600,
                        height: 1.05,
                        letterSpacing: -1.3,
                        color: p.ink1)),
                const SizedBox(height: 2),
                Text(
                    hinglish
                        ? 'is chapter mein, ${today.chapterLength} mein se'
                        : 'in this chapter, of about ${today.chapterLength}',
                    style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: p.ink2)),
              ] else ...[
                // ⚠️ THE INVITATION, NOT A ZERO. "Day 0" is what the parenting
                // hero shipped with for a fortnight and it is worse here: a
                // number implies we are counting something, and before a period
                // is logged we are counting nothing. `noPeriodLogged` is a real
                // state with its own sentence.
                Text(hinglish ? 'Shuruaat' : 'Start here',
                    style: pvFraunces(
                        fontSize: 38,
                        fontWeight: FontWeight.w600,
                        height: 1.05,
                        letterSpacing: -1.2,
                        color: p.ink1)),
                const SizedBox(height: 2),
                Text(
                    hinglish
                        ? 'Apna last period log karein, phir yahan aapki rhythm dikhegi'
                        : 'Log your last period, and your rhythm shows up here',
                    style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        height: 1.4,
                        color: p.ink2)),
              ],
              const SizedBox(height: 14),
              // The one forward-looking line, and it names a TRIGGER rather
              // than a date. `nextUp` is the string the hero test guards.
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: p.ink2.withValues(alpha: 0.5),
                      shape: BoxShape.circle),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(chapter.nextUp(hinglish),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 13.5, height: 1.45, color: p.ink2)),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

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
        Text(eyebrow.toUpperCase(),
            style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: p.action)),
        const SizedBox(height: 5),
        Text(title,
            style: pvFraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.5,
                color: p.ink1)),
      ]);
}

/// The cycle spine, as one card.
///
/// ⚠️ IT SHOWS POSITION AND REFUSES TO SHOW PROBABILITY. `fertility` is a level
/// this app is allowed to name; a percentage is not, and neither is anything
/// that reads as a target. When confidence is unknown the card says the app has
/// nothing to lean on rather than printing an estimate anyway — the exact
/// failure `TtcNoEstimate` was added to stop, after "ovulation around day 40"
/// appeared on five screens from a single unlogged gap.
class _SpineCard extends StatelessWidget {
  const _SpineCard(
      {required this.today,
      required this.p,
      required this.hinglish,
      required this.onTap});

  final TtcToday today;
  final V2Palette p;
  final bool hinglish;
  final VoidCallback onTap;

  String get _line {
    if (today.noEstimate == TtcNoEstimate.noPeriodLogged) {
      return hinglish
          ? 'Abhi tak kuch log nahi hua. Pehla period log karte hi cycle yahan banna shuru ho jayega.'
          : 'Nothing logged yet. Log one period and your cycle starts taking shape here.';
    }
    if (today.clinicInvolved) {
      // ⚠️ WE DEFER, WE DO NOT COMPUTE. When a clinic owns the timing, an app
      // estimate beside it is a second opinion she did not ask for. Truth
      // hierarchy: treating clinician outranks ParentVeda's calculation by six
      // places.
      return hinglish
          ? 'Aapki clinic timing sambhaal rahi hai. Hum yahan sirf aapke saath chal rahe hain — apna hisaab nahi laga rahe.'
          : 'Your clinic is holding the timing. We are keeping you company here, '
              'not running our own numbers alongside theirs.';
    }
    if (today.confidence == OvulationConfidence.unknown) {
      return hinglish
          ? 'Abhi itna record nahi hai ki hum kuch keh sakein. Jaise-jaise aap log karengi, yeh saaf hota jayega.'
          : 'Not enough logged yet for us to say anything useful. It gets clearer as you go.';
    }
    return hinglish
        ? 'Cycle day ${today.cycleDay}. Aapki rhythm, jitna abhi tak pata hai.'
        : 'Cycle day ${today.cycleDay}. Your rhythm, as far as we know it.';
  }

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
            Text(_line,
                style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
            const SizedBox(height: 12),
            Row(children: [
              Text(hinglish ? 'Cycle kholein' : 'Open your cycle',
                  style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: p.action)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 15, color: p.action),
            ]),
          ]),
        ),
      );
}

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
