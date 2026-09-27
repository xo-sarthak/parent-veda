// =============================================================================
//  TTC - the partner's Today
// -----------------------------------------------------------------------------
//      "His role is not observer. His role is not assistant. His role is
//       partner."                                        - TTC master, §15
//
//  Structurally identical to her Today - same card shell, same gutter, same
//  order of ideas - in the Slate palette. That is the same trick the pregnancy
//  father mode uses, and the reason it works: change the colour and the voice,
//  never the architecture, so the two halves of a couple can talk about the
//  same app.
//
//  The section order is deliberate and is NOT hers with the labels swapped:
//
//    mission → supporting her → your half of this → learn → journal
//
//  "Your half of this" sits above the reading and the journal on purpose. A
//  partner screen where his own body appears last is a partner screen that has
//  quietly decided this is her project and he is helping.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_daily_data.dart';
import '../../ttc/ttc_insight_read.dart';
import '../../ttc/ttc_journal_store.dart';
import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_mind_today.dart';
import '../../ttc/ttc_partner_data.dart';
import '../../ttc/ttc_practice_data.dart';
import '../../ttc/ttc_store.dart';
import '../../ttc/ttc_treatment_store.dart';
import 'ttc_askveda_screen.dart';
import 'ttc_chapter_screen.dart';
import 'ttc_common.dart';
// import 'ttc_insight_screen.dart'; // kept for revert — the insight opens in the reader now
import 'ttc_journal_screen.dart';
import 'ttc_journey_map_screen.dart';
import 'ttc_profile_screen.dart' show openTtcProfile;
import 'ttc_round_strings.dart'
    show ttcPartnerRoundLine, kTtcPartnerRoundEyebrow;
import 'ttc_strings.dart';
import 'ttc_surface_router.dart';

class TtcPartnerTodayScreen extends StatelessWidget {
  const TtcPartnerTodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        TtcStore.instance,
        TtcJournalStore.instance,
        TtcLang.instance,
        // His two practice cards carry a done state, and it is his own row.
        TtcLogStore.instance,
        // The couple's treatment round, for his round line (B10).
        TtcTreatmentStore.instance,
      ]),
      builder: (context, _) {
        final t = TtcS.current();
        final today = TtcStore.instance.today;
        // His account has no cycle of its own, so his chapter comes from the
        // one SHE publishes to ttc_journeys. He never reads her cycle - that
        // is the whole point of the derived column.
        final chapter = TtcStore.instance.displayChapter;
        final brief = ttcPartnerBriefs[chapter]!;
        final mission = ttcPickForToday(ttcMissions);
        // His insight comes from the shared library, filtered to the ones
        // written for him - one brain, two doors, not a second library.
        final insights = ttcInsights.where((i) => i.forPartner).toList();
        // The single pick fed `_LearnCard`, kept for revert with it:
        // final insight = ttcPickForToday(insights, offset: 1);

        // His half was a raw Scaffold with no navigation at all: five cards,
        // and the only way out was toggling back to Her. He could not reach
        // Prepare, Tools, Calendar or Community from his own home.
        //
        // Same five destinations as hers, not a reduced set. Per-user
        // navigation is forbidden - personalisation changes content, ranking
        // and order, never structure - and the father shell in pregnancy makes
        // the same choice: one scaffold, his content inside it.
        //
        // The shared tabs are safe for him by construction rather than by a
        // check here: his device has no rows in ttc_cycles, so the Calendar
        // simply has no cycle to draw. The privacy comes from the own-row rule,
        // which is where it belongs.
        return TtcPage(
          tab: 0,
          slate: true,
          // ⚠️ NO FLOATING HER / HIM PILL (2026-09-27, build 10 on the
          // phone). It sat over his cards on every scroll and was never a
          // thing he should see: his phone reaches this screen by pairing,
          // and the preview switch lives in You › Developer, as it does for
          // her V3 home. Kept for revert:
          //   overlay: _ModePill(t: t, him: true),
          children: [
            // The SHARED header, in his palette - not a private one. His was a
            // logo row with no actions, so the profile door added to fix A-2 /
            // A-3 / A-61 (no language control, no sign-out, no way to correct
            // anything) never reached his half. Two headers is exactly how his
            // came to be missing it.
            // Her V3 header's shape (the date between the round buttons),
            // not the wordmark row (2026-09-27). Kept for revert:
            // const TtcHeader(slate: true),
            const _HisTop(),
            const SizedBox(height: 18),
            _Hero(chapter: chapter, today: today, t: t),
            const SizedBox(height: 20),
            // ⚠️ HIS ROUND LINE (2026-09-26, docs/TTC-TREATMENT-FLOW.md §3g,
            // B10). The `ttc_treatment` row is couple-scoped, so his device
            // holds the round: "IVF · Transfer on Thursday", and what it
            // asks of him. Never her cycle: no cycle day, no period, no
            // fertile days, and no result (a closed round shows nothing;
            // how the test went is hers to tell). `ttcPartnerRoundLine`.
            if (ttcPartnerRoundLine(
                    TtcTreatmentStore.instance.cycle, DateTime.now())
                case final round?) ...[
              _RoundLineCard(line: round),
              const SizedBox(height: 12),
            ],

            _MissionCard(mission: mission, t: t),
            const SizedBox(height: 12),
            // ⚠️ TODAY'S INSIGHTS FOR HIM, A RAIL (2026-09-27; the user's
            // brief keeps today's insights, Flo for Partners' "insights about
            // her · Today"). Up to three pieces written for him, turning over
            // with the day; one card was all he had. Directly under his
            // mission, near the top where Flo puts them: on build 10 it sat
            // eighth, under his door. Kept for revert, in its old place below:
            //   _LearnCard(insight: insight, t: t),
            _HisInsights(insights: insights, t: t),
            const SizedBox(height: 12),
            // ⚠️ THE HALF OF MIND & BODY'S BRIEF THAT WAS LOGIC WITH NO CALLER
            // — WIRED 2026-09-10. Its Today spec says *"Both partners see
            // Today. Their picked cards may differ. Either can complete alone,
            // and it does not count against the other."* `kTtcPartnerOffset`
            // and the `offset` parameter existed and were tested from the
            // start; nothing called them, so his half of the practice did not
            // exist. Recorded honestly in `docs/STILL-OPEN.md` §28.7 rather
            // than claimed, and now closed.
            //
            // It sits directly under the mission because both are "a thing to
            // do today", and above supporting her because his own half coming
            // last is the exact failure this screen's header warns about.
            const _PracticeCard(),
            const SizedBox(height: 12),
            _SupportCard(brief: brief, t: t),
            const SizedBox(height: 12),
            // ⚠️ ONE QUESTION, UNDER "SUPPORTING HER" (gap analysis, Behind ›
            // Partner, 2026-09-26). He had missions and no easy way into a
            // conversation. It sits here because asking is the most useful
            // form support takes, and above the reading so it is seen.
            const _TonightCard(),
            const SizedBox(height: 12),
            // Understanding before advice, and her body before his. He was
            // being told how to help with something he had never had explained.
            _HerBodyCard(brief: brief, t: t),
            const SizedBox(height: 12),
            _YourBodyCard(brief: brief, t: t),
            const SizedBox(height: 12),
            // His one door (2026-09-27): the rest are hers, and the user's
            // brief takes them away from his home. His body, his tests, his
            // habits live behind this one.
            const _HisDoorCard(),
            const SizedBox(height: 12),
            // The insights rail moved up under his mission (above).
            _AskVedaCard(t: t),
            const SizedBox(height: 12),
            _JournalCard(t: t),
          ],
        );
      },
    );
  }
}

/// His two practices for today, from the same library hers come from.
///
/// ⚠️ THE OFFSET IS THE WHOLE POINT, AND IT IS NOT DECORATION. `ttcPracticeOfTheDay`
/// takes an `offset` of half a library, so on any given day his movement and
/// hers are different cards. The brief asks for that deliberately: two people
/// handed the identical instruction at breakfast are doing an exercise class,
/// and two people who each have their own thing to do and can compare notes are
/// doing this together.
///
/// ⚠️ AND HIS DONE STATE IS HIS OWN ROW. `ttcSetPracticeDone` writes into
/// `TtcLogStore` on the device it is running on, so nothing here can mark her
/// day complete or leave her a card she did not open. *"Either can complete
/// alone, and it does not count against the other"* holds by construction
/// rather than by a check — with one caveat worth knowing: the Mom|Dad pill is
/// a TESTING switch on a single device, so flipping it does not swap the store
/// underneath. In the real product his half arrives through the pairing code on
/// his own install, and the rows are separate because the devices are.
class _PracticeCard extends StatelessWidget {
  const _PracticeCard();

  @override
  Widget build(BuildContext context) {
    final move =
        ttcPracticeOfTheDay(TtcPracticeKind.move, offset: kTtcPartnerOffset);
    final breathe =
        ttcPracticeOfTheDay(TtcPracticeKind.breathe, offset: kTtcPartnerOffset);

    return _SlateCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('A FEW MINUTES, YOURS',
            style: ttcBody(10, color: ttcSlateAmber, w: FontWeight.w800)),
        const SizedBox(height: 6),
        // ⚠️ IT SAYS THE CARDS ARE NOT HERS, BECAUSE HE WILL ASSUME THEY ARE.
        // Everything else on this screen is about her; a practice card with no
        // such line reads as a chore she has set him.
        Text('These are different from hers, on purpose. Nothing here keeps '
            'score, and neither of you is waiting on the other.',
            style: ttcBody(13, color: ttcSlateSoft, h: 1.6)),
        const SizedBox(height: 14),
        _PracticeRow(practice: move),
        const SizedBox(height: 10),
        _PracticeRow(practice: breathe),
      ]),
    );
  }
}

class _PracticeRow extends StatelessWidget {
  const _PracticeRow({required this.practice});
  final TtcPractice practice;

  @override
  Widget build(BuildContext context) {
    final done = ttcPracticeDoneToday(practice.kind);

    return GestureDetector(
      onTap: () => openTtcSurface(context, 'ttc_practice/${practice.id}'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: ttcSlatePanel,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Icon(
              practice.kind == TtcPracticeKind.move
                  ? Icons.self_improvement_rounded
                  : Icons.air_rounded,
              size: 18,
              color: ttcSlate),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(practice.title,
                      style: ttcBody(13.5,
                          color: ttcSlateInk, w: FontWeight.w700, h: 1.3)),
                  const SizedBox(height: 3),
                  Text(practice.duration,
                      style: ttcBody(11.5, color: ttcSlateSoft)),
                ]),
          ),
          const SizedBox(width: 8),
          Icon(done ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
              size: 17, color: ttcSlate),
        ]),
      ),
    );
  }
}

/// Shown on her Today too, so the switch is reachable from both sides during
/// design review.
class _ModePill extends StatelessWidget {
  const _ModePill({required this.t, required this.him});
  final TtcS t;
  final bool him;

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, bool active, VoidCallback onTap) =>
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
            decoration: BoxDecoration(
              color: active ? (him ? ttcSlate : ttcPurple) : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                style: ttcBody(12,
                    color: active ? Colors.white : ttcMuted,
                    w: FontWeight.w800)),
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
          seg(t.partnerHer, !him, () => TtcPartnerMode.instance.on = false),
          seg(t.partnerHim, him, () => TtcPartnerMode.instance.on = true),
        ]),
      ),
    );
  }
}

/// Reusable so her Today can carry the same dev switch.
Widget ttcModePill(TtcS t, {required bool him}) => _ModePill(t: t, him: him);

// Superseded by `TtcHeader(slate: true)`. Kept for revert.
//
// This is the object lesson: a private copy of a shared component looks
// harmless the day it is written and silently stops receiving every fix the
// shared one gets. The profile door - his only route to Hinglish and to signing
// out - was added to `TtcHeader` and never arrived here.
//
// class _Header extends StatelessWidget {
//   const _Header({required this.t});
//   final TtcS t;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(children: [
//       Image.asset('assets/brand/pv-mark.png', height: 30),
//       const SizedBox(width: 9),
//       Text('ParentVeda',
//           style: ttcFraunces(20, w: FontWeight.w600, color: ttcSlate)),
//     ]);
//   }
// }

class _Hero extends StatelessWidget {
  const _Hero({required this.chapter, required this.today, required this.t});

  final TtcChapter chapter;
  final TtcToday today;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    // Built against the pregnancy stage's DAD hero (`father_daily_screen.dart`,
    // `_weeklySnapshot`), the same way her TTC hero was built against the
    // mother's home. That is the standard: the two products' father halves
    // should look like each other, not like a plainer version of the same app.
    //
    // Dad's shape, element for element: a muted eyebrow ABOVE the card, a
    // clipped two-stop gradient, one large white circle bleeding off the top
    // right and one amber circle off the bottom, a greeting, the serif
    // headline, a summary, an onward link, a progress bar, a hairline divider,
    // and three circular shortcuts.
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Dad has "WEEKLY SNAPSHOT" here; she has "YOUR CHAPTER". His hero
      // floated with nothing naming it.
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
        child: ttcEyebrow(t.partnerTodayTitle, color: ttcSlateSoft),
      ),
      ClipRRect(
        borderRadius: BorderRadius.circular(ttcCardRadius),
        child: Stack(children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ttcSlate, ttcSlateDeep],
                ),
              ),
            ),
          ),
          // The two soft circles Dad's hero carries. Amber is the accent on
          // his side exactly as coral is on hers.
          Positioned(
              right: -34,
              top: -40,
              child: _softCircle(150, Colors.white.withValues(alpha: 0.06))),
          // The amber circle sat behind "What's next" like a stuck blob on
          // a phone (2026-09-27). Kept for revert:
          // Positioned(right: 26, bottom: -42,
          //     child: _softCircle(96, ttcSlateAmber.withValues(alpha: 0.20))),
          _body(context, hi),
        ]),
      ),
    ]);
  }

  static String _greeting(TtcS t) {
    final h = DateTime.now().hour;
    if (h < 12) return t.goodMorning;
    if (h < 17) return t.goodAfternoon;
    return t.goodEvening;
  }

  static Widget _softCircle(double size, Color c) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );

  Widget _body(BuildContext context, bool hi) {
    return Container(
      padding: const EdgeInsets.all(20),
      // Hers answers three questions above the fold - where am I, what is next,
      // show me it all. His answered none: a title, a tagline and one flat bar
      // that could have been at any point of anything. The hero parity work was
      // done on her side only, so the stage still had a first-class half and a
      // second-class one.
      //
      // ONE THING IS DELIBERATELY MISSING. Hers reads "Day 2 of 28 in this
      // chapter"; his does not, and must not. That number is her position in
      // her cycle, and he is only ever given the chapter she publishes - his
      // device holds no rows in `ttc_cycles`. Copying the line across "for
      // parity" would route around the own-row rule in prose, which is exactly
      // the leak the partner Ask Veda door is careful to avoid. The segmented
      // bar is chapter-level and therefore safe.
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Dad opens "Good afternoon, {name}". Same beat.
        Text(_greeting(t),
            style: ttcBody(12.5,
                color: Colors.white.withValues(alpha: 0.85),
                w: FontWeight.w600)),
        const SizedBox(height: 6),
        // Fraunces, as the father mode does for its headers.
        // ⚠️ THE DAYS, NOT THE CHAPTER NAME (the user, 2026-09-27: "Trying
        // Together… how does that make sense? Why are we even using it?").
        // Kept for revert: Text(chapter.title(hi), ...)
        Text(ttcChapterHisTitle(chapter),
            style: ttcFraunces(26, w: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        Text(chapter.tagline(hi),
            style: ttcBody(13,
                color: Colors.white.withValues(alpha: 0.92), h: 1.5)),
        const SizedBox(height: 12),
        // Dad's "Open her week ›" — the onward link sits under the summary,
        // not floating in the top corner.
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => const TtcJourneyMapScreen(),
            settings: const RouteSettings(name: 'ttc/journey'),
          )),
          behavior: HitTestBehavior.opaque,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(t.journeyMap,
                style: ttcBody(12.5, color: Colors.white, w: FontWeight.w700)),
            const Icon(Icons.chevron_right_rounded,
                size: 17, color: Colors.white),
          ]),
        ),
        // ⚠️ NO FIVE-STEP CHAPTER BAR AND NO "Next: The Waiting Days" LINE
        // (2026-09-27): both spoke in chapter names, which the user asked to
        // stop showing on their own. Her home dropped the same pair. Kept for
        // revert:
        //   const SizedBox(height: 18),
        //   TtcChapterBar(today: today),
        //   const SizedBox(height: 14),
        //   Text(chapter.nextUp(hi), style: ttcBody(12.5, ...)),
        const SizedBox(height: 16),
        Container(height: 1, color: Colors.white.withValues(alpha: 0.16)),
        const SizedBox(height: 14),
        // Dad's Baby / Mother / What's-next circles. Same component hers uses -
        // it is white-on-translucent, so it carries across palettes unchanged.
        Row(children: [
          TtcHeroShortcut(
              icon: Icons.self_improvement_rounded,
              // Who each is for (2026-09-27). Kept for revert: t.shortcutMe.
              label: 'For you',
              onTap: () =>
                  openTtcChapter(context, chapter, tab: TtcChapterTab.me)),
          TtcHeroShortcut(
              icon: Icons.favorite_rounded,
              // Kept for revert: t.shortcutUs.
              label: 'You both',
              onTap: () =>
                  openTtcChapter(context, chapter, tab: TtcChapterTab.us)),
          TtcHeroShortcut(
              icon: Icons.event_available_rounded,
              label: t.shortcutNext,
              onTap: () =>
                  openTtcChapter(context, chapter, tab: TtcChapterTab.next)),
        ]),
      ]),
    );
  }
}

// ---- today's mission --------------------------------------------------------

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission, required this.t});

  final TtcMission mission;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ttcCardRadius),
        border: Border.all(color: ttcSlateAmber, width: 1.4),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(t.partnerMission.toUpperCase(),
              style: ttcBody(10,
                  color: ttcSlateAmber, w: FontWeight.w800)),
          const Spacer(),
          if (mission.forHimself)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: ttcSlatePanel,
                  borderRadius: BorderRadius.circular(999)),
              child: Text(t.partnerAboutHimself,
                  style: ttcBody(9.5, color: ttcSlate, w: FontWeight.w800)),
            ),
        ]),
        const SizedBox(height: 11),
        Text(mission.title(hi),
            style: ttcFraunces(19, w: FontWeight.w600, color: ttcSlateInk)),
        const SizedBox(height: 9),
        Text(mission.body(hi),
            style: ttcBody(14, color: ttcSlateSoft, h: 1.65)),
      ]),
    );
  }
}

// ---- supporting her ---------------------------------------------------------

class _SupportCard extends StatelessWidget {
  const _SupportCard({required this.brief, required this.t});

  final TtcPartnerBrief brief;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return _SlateCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.partnerSupport, style: ttcJakarta(16.5, color: ttcSlateInk)),
        const SizedBox(height: 14),
        _labelled(t.partnerSheMayFeel, brief.sheMayFeel(hi)),
        const SizedBox(height: 14),
        Container(height: 1, color: ttcSlateLine),
        const SizedBox(height: 14),
        _labelled(t.partnerYouCan, brief.youCan(hi)),
      ]),
    );
  }

  Widget _labelled(String label, String body) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: ttcBody(9.5, color: ttcSlateAmber, w: FontWeight.w800)),
          const SizedBox(height: 7),
          Text(body, style: ttcBody(14, color: ttcSlateSoft, h: 1.65)),
        ],
      );
}

// ---- tonight, ask her -------------------------------------------------------

/// One gentle question a day, from `kTtcTonightQuestions`.
///
/// English only, including in his Hinglish view: new work is English
/// (CLAUDE.md), and a question he reads in English he can still ask her in
/// any language they share.
class _TonightCard extends StatelessWidget {
  const _TonightCard();

  @override
  Widget build(BuildContext context) {
    return _SlateCard(
      color: ttcSlatePanel,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.chat_bubble_outline_rounded,
              size: 18, color: ttcSlate),
        ),
        const SizedBox(width: 11),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(kTtcTonightLabel.toUpperCase(),
                style: ttcBody(10, color: ttcSlateAmber, w: FontWeight.w800)),
            const SizedBox(height: 7),
            Text(ttcTonightQuestion(),
                style: ttcFraunces(17, w: FontWeight.w600, color: ttcSlateInk)),
          ]),
        ),
      ]),
    );
  }
}

/// His one round line (B10): an eyebrow, the step and its day, and what it
/// asks of him. A white card in his palette, like the mission.
class _RoundLineCard extends StatelessWidget {
  const _RoundLineCard({required this.line});
  final (String, String, String?) line;

  @override
  Widget build(BuildContext context) {
    final (kind, what, note) = line;
    return Semantics(
      container: true,
      label: '$kTtcPartnerRoundEyebrow, $kind. $what.${note == null ? '' : ' $note'}',
      child: _SlateCard(
        key: const ValueKey('ttc_partner_round_line'),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.event_note_outlined, size: 18, color: ttcSlate),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${kTtcPartnerRoundEyebrow.toUpperCase()} · ${kind.toUpperCase()}',
                      style: ttcBody(10,
                          color: ttcSlateAmber, w: FontWeight.w800)),
                  const SizedBox(height: 7),
                  Text(what,
                      style: ttcFraunces(17,
                          w: FontWeight.w600, color: ttcSlateInk)),
                  if (note != null) ...[
                    const SizedBox(height: 6),
                    Text(note,
                        style: ttcBody(13, color: ttcSlateInk, h: 1.45)),
                  ],
                ]),
          ),
        ]),
      ),
    );
  }
}

// ---- her half ---------------------------------------------------------------

/// The explanation his side was missing entirely.
///
/// He had what she may be feeling, what he could do about it, and his own
/// biology - and nothing that said what a cycle IS. Most men arrive here knowing
/// very little about any of it, and asking someone to support a process nobody
/// has explained to them produces exactly the well-meaning uselessness this
/// stage is trying to avoid.
///
/// Sits ABOVE `_YourBodyCard` deliberately: her body is the thing he came to
/// understand, and his is the smaller half.
///
/// The footnote is not a disclaimer, it is a promise being kept in the open. He
/// is told, on the card itself, that this is chapter-level and that he is never
/// shown where she is in her cycle - because the privacy rule is only reassuring
/// if the person it protects and the person it constrains can both see it.
class _HerBodyCard extends StatelessWidget {
  const _HerBodyCard({required this.brief, required this.t});

  final TtcPartnerBrief brief;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return _SlateCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.school_outlined, size: 18, color: ttcSlateAmber),
          const SizedBox(width: 9),
          Expanded(
              child: Text(t.partnerHerBody,
                  style: ttcJakarta(16.5, color: ttcSlateInk))),
        ]),
        const SizedBox(height: 12),
        Text(brief.herBody(hi),
            style: ttcBody(14, color: ttcSlateSoft, h: 1.7)),
        const SizedBox(height: 14),
        Container(height: 1, color: ttcSlateLine),
        const SizedBox(height: 12),
        Text(t.partnerHerBodyNote,
            style: ttcBody(11.5, color: ttcSlateSoft, h: 1.5)),
      ]),
    );
  }
}

// ---- his half ---------------------------------------------------------------

class _YourBodyCard extends StatelessWidget {
  const _YourBodyCard({required this.brief, required this.t});

  final TtcPartnerBrief brief;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return _SlateCard(
      color: ttcSlatePanel,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.male_rounded, size: 18, color: ttcSlate),
          const SizedBox(width: 9),
          Expanded(
              child:
                  Text(t.partnerYourBody, style: ttcJakarta(16, color: ttcSlateInk))),
        ]),
        const SizedBox(height: 12),
        Text(brief.yourBody(hi),
            style: ttcBody(14, color: ttcSlateSoft, h: 1.65)),
      ]),
    );
  }
}

// ---- learn ------------------------------------------------------------------

// ignore: unused_element (kept for revert since 2026-09-27; `_HisInsights` replaced it)
class _LearnCard extends StatelessWidget {
  const _LearnCard({required this.insight, required this.t});

  final TtcInsight insight;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return _SlateCard(
      // The article format (ttc_insight_read.dart). Kept for revert:
      // onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
      //   builder: (_) => TtcInsightScreen(insight: insight),
      //   settings: const RouteSettings(name: 'ttc/insight'),
      // )),
      onTap: () => openTtcInsight(context, insight),
      // Parity with her `_InsightCard`, which carries a read time, the opening
      // paragraph and the takeaway in a panel. His had a title and a takeaway,
      // so the same piece of writing looked like a caption on his side and an
      // article on hers - and he had no way to tell there was more behind it.
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(t.partnerLearn.toUpperCase(),
              style: ttcBody(10, color: ttcSlateAmber, w: FontWeight.w800)),
          const Spacer(),
          Text(t.readSeconds(insight.readTime(hi)),
              style: ttcBody(11, color: ttcSlateSoft, w: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        Text(insight.title(hi),
            style: ttcJakarta(16.5, color: ttcSlateInk)),
        const SizedBox(height: 8),
        Text(
          insight.body(hi).split('\n\n').first,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: ttcBody(13.5, color: ttcSlateSoft, h: 1.55),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ttcSlatePanel,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(insight.takeaway(hi),
              style: ttcBody(13,
                  color: ttcSlateInk, w: FontWeight.w700, h: 1.45)),
        ),
      ]),
    );
  }
}

/// His door into Ask Veda.
///
/// PRIVACY — `partnerMode: true` is load-bearing, not decoration. The TTC data
/// model keeps `ttc_cycles` own-row so he can never read her cycle; he sees only
/// the chapter she publishes. Sending her cycle day from HIS device would route
/// around that rule on the client side, so this door sends the chapter and never
/// the cycle day. Do not remove the flag.
class _AskVedaCard extends StatelessWidget {
  const _AskVedaCard({required this.t});

  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return _SlateCard(
      onTap: () => openTtcAskVeda(context, partnerMode: true),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_awesome_outlined,
              size: 16, color: ttcSlateAmber),
          const SizedBox(width: 8),
          Text(hi ? 'ASK VEDA' : 'ASK VEDA',
              style: ttcBody(10, color: ttcSlateAmber, w: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        Text(hi ? 'Kuch bhi poochho' : 'Ask anything',
            style: ttcJakarta(16.5, color: ttcSlateInk)),
        const SizedBox(height: 8),
        Text(
            hi
                ? 'Sawaal jo poochhne mein ajeeb lage — yahin poochho. Jawaab tumhare liye, is safar ke hisaab se.'
                : "Ask the questions that feel awkward to say out loud. The answers fit where the two of you are right now.",
            style: ttcBody(13.5, color: ttcSlateSoft, h: 1.6)),
      ]),
    );
  }
}

// ---- shared journal ---------------------------------------------------------

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.t});
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return _SlateCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(t.partnerJournal,
                  style: ttcJakarta(16.5, color: ttcSlateInk))),
          GestureDetector(
            onTap: () => openTtcJournal(context),
            behavior: HitTestBehavior.opaque,
            child: Text(t.seeAll,
                style: ttcBody(12, color: ttcSlate, w: FontWeight.w800)),
          ),
        ]),
        const SizedBox(height: 8),
        Text(t.partnerJournalNote,
            style: ttcBody(12.5, color: ttcSlateSoft, h: 1.5)),
        const SizedBox(height: 14),
        Row(children: [
          for (final kind in TtcEntryKind.values) ...[
            Expanded(
              child: GestureDetector(
                // His entries are attributed to him. She sees them; that is
                // the point of a shared journal.
                onTap: () => writeTtcEntry(context,
                    kind: kind, author: TtcAuthor.partner),
                behavior: HitTestBehavior.opaque,
                child: Column(children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: ttcSlatePanel, shape: BoxShape.circle),
                    child: Icon(_icon(kind), size: 19, color: ttcSlate),
                  ),
                  const SizedBox(height: 7),
                  Text(kind.label(hi),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ttcBody(10,
                          color: ttcSlateSoft, w: FontWeight.w700, h: 1.25)),
                ]),
              ),
            ),
            if (kind != TtcEntryKind.values.last) const SizedBox(width: 8),
          ],
        ]),
      ]),
    );
  }

  IconData _icon(TtcEntryKind kind) {
    switch (kind) {
      case TtcEntryKind.memory:
        return Icons.auto_stories_outlined;
      case TtcEntryKind.letter:
        return Icons.drafts_outlined;
      case TtcEntryKind.question:
        return Icons.help_outline_rounded;
      case TtcEntryKind.feeling:
        return Icons.favorite_border_rounded;
    }
  }
}

// ---- the Slate card shell ---------------------------------------------------
//  Same geometry as TtcCard, different palette. Deliberately not a parameter on
//  TtcCard: her surfaces must never accidentally render in his colours.

class _SlateCard extends StatelessWidget {
  const _SlateCard(
      {super.key, required this.child, this.onTap, this.color = Colors.white});

  final Widget child;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(ttcCardRadius),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1422333B), blurRadius: 22, offset: Offset(0, 8)),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(
        onTap: onTap, behavior: HitTestBehavior.opaque, child: card);
  }
}

/// His top: the profile door and today's date, the shape of her V3 header
/// (2026-09-27).
class _HisTop extends StatelessWidget {
  const _HisTop();

  static const _m = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Row(children: [
      Semantics(
        button: true,
        label: 'Profile',
        child: InkWell(
          onTap: () => openTtcProfile(context),
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ttcSlatePanel,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline_rounded,
                size: 22, color: ttcSlateInk),
          ),
        ),
      ),
      Expanded(
        child: Text('${now.day} ${_m[now.month - 1]}',
            textAlign: TextAlign.center,
            style: ttcBody(15, color: ttcSlateInk, w: FontWeight.w700)),
      ),
      const SizedBox(width: 44),
    ]);
  }
}

/// Today's insights for him: a rail of up to three pieces written for him
/// (2026-09-27). Each opens in the one reader.
class _HisInsights extends StatelessWidget {
  const _HisInsights({required this.insights, required this.t});
  final List<TtcInsight> insights;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    if (insights.isEmpty) return const SizedBox.shrink();
    final picks = [
      for (var i = 0; i < 3 && i < insights.length; i++)
        ttcPickForToday(insights, offset: 1 + i),
    ];
    final seen = <String>{};
    final unique = [for (final p in picks) if (seen.add(p.id)) p];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 6, 4, 10),
        child: Text('FOR YOU TODAY',
            style: ttcBody(10.5, color: ttcSlateAmber, w: FontWeight.w800)),
      ),
      SizedBox(
        // 176 left a third of each card blank on the phone (build 10).
        height: 142,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: unique.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, i) {
            final ins = unique[i];
            return SizedBox(
              width: 236,
              child: _SlateCard(
                onTap: () => openTtcInsight(context, ins),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.readSeconds(ins.readTime(hi)),
                          style: ttcBody(11,
                              color: ttcSlateSoft, w: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(ins.title(hi),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: ttcJakarta(15.5, color: ttcSlateInk)),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(ins.takeaway(hi),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: ttcBody(12.5,
                                color: ttcSlateSoft, h: 1.45)),
                      ),
                    ]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

/// His one door: the His side door (2026-09-27).
class _HisDoorCard extends StatelessWidget {
  const _HisDoorCard();

  @override
  Widget build(BuildContext context) => _SlateCard(
        key: const ValueKey('ttc_partner_his_door'),
        onTap: () => openTtcSurface(context, 'ttc_door/ttc_male_fertility'),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ttcSlatePanel,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.biotech_outlined,
                size: 22, color: ttcSlateInk),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('His side', style: ttcJakarta(16, color: ttcSlateInk)),
              const SizedBox(height: 3),
              Text('Your tests, your habits and what really changes sperm health.',
                  style: ttcBody(12.5, color: ttcSlateSoft, h: 1.45)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ttcSlateSoft),
        ]),
      );
}
