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
import '../../ttc/ttc_journal_store.dart';
import '../../ttc/ttc_partner_data.dart';
import '../../ttc/ttc_store.dart';
import 'ttc_askveda_screen.dart';
import 'ttc_common.dart';
import 'ttc_insight_screen.dart';
import 'ttc_journal_screen.dart';
import 'ttc_journey_map_screen.dart';
import 'ttc_strings.dart';

class TtcPartnerTodayScreen extends StatelessWidget {
  const TtcPartnerTodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        TtcStore.instance,
        TtcJournalStore.instance,
        TtcLang.instance,
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
        final insight = ttcPickForToday(insights, offset: 1);

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
          overlay: _ModePill(t: t, him: true),
          children: [
            _Header(t: t),
            const SizedBox(height: 18),
            _Hero(chapter: chapter, today: today, t: t),
            const SizedBox(height: 20),

            _MissionCard(mission: mission, t: t),
            const SizedBox(height: 12),
            _SupportCard(brief: brief, t: t),
            const SizedBox(height: 12),
            // Understanding before advice, and her body before his. He was
            // being told how to help with something he had never had explained.
            _HerBodyCard(brief: brief, t: t),
            const SizedBox(height: 12),
            _YourBodyCard(brief: brief, t: t),
            const SizedBox(height: 12),
            _LearnCard(insight: insight, t: t),
            const SizedBox(height: 12),
            _AskVedaCard(t: t),
            const SizedBox(height: 12),
            _JournalCard(t: t),
          ],
        );
      },
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

class _Header extends StatelessWidget {
  const _Header({required this.t});
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Image.asset('assets/brand/pv-mark.png', height: 30),
      const SizedBox(width: 9),
      Text('ParentVeda',
          style: ttcFraunces(20, w: FontWeight.w600, color: ttcSlate)),
    ]);
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.chapter, required this.today, required this.t});

  final TtcChapter chapter;
  final TtcToday today;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ttcCardRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ttcSlate, ttcSlateDeep],
        ),
      ),
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
        Row(children: [
          Expanded(
            child: Text(t.partnerTodayTitle,
                style: ttcBody(12,
                    color: Colors.white.withValues(alpha: 0.82),
                    w: FontWeight.w700)),
          ),
          // "Show me it all" - the same door hers has. Structure is never
          // personalised, so he reaches the map too.
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const TtcJourneyMapScreen(),
              settings: const RouteSettings(name: 'ttc/journey'),
            )),
            behavior: HitTestBehavior.opaque,
            child: Row(children: [
              Text(t.journeyMap,
                  style: ttcBody(12.5,
                      color: Colors.white, w: FontWeight.w700)),
              const SizedBox(width: 3),
              const Icon(Icons.chevron_right_rounded,
                  size: 17, color: Colors.white),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        // Fraunces, as the father mode does for its headers.
        Text(chapter.title(hi),
            style: ttcFraunces(26, w: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        Text(chapter.tagline(hi),
            style: ttcBody(13,
                color: Colors.white.withValues(alpha: 0.92), h: 1.5)),
        const SizedBox(height: 16),
        TtcChapterBar(today: today),
        const SizedBox(height: 14),
        Container(height: 1, color: Colors.white.withValues(alpha: 0.18)),
        const SizedBox(height: 12),
        // What is coming, named by its trigger rather than a countdown - the
        // same copy hers uses, so the two cannot describe the journey
        // differently to the two people on it.
        Text(chapter.nextUp(hi),
            style: ttcBody(12.5,
                color: Colors.white.withValues(alpha: 0.9), h: 1.5)),
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

class _LearnCard extends StatelessWidget {
  const _LearnCard({required this.insight, required this.t});

  final TtcInsight insight;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return _SlateCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => TtcInsightScreen(insight: insight),
        settings: const RouteSettings(name: 'ttc/insight'),
      )),
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
                : "The questions that feel awkward to ask out loud. Answered for where the two of you are.",
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
  const _SlateCard({required this.child, this.onTap, this.color = Colors.white});

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
