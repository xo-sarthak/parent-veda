// =============================================================================
//  His side of trying to conceive, on HER home (2026-10-10)
// -----------------------------------------------------------------------------
//  The user: "the app remains the same, it looks exactly the same, just a few
//  things are less in his side ... it should not look like a different
//  application. Keep the reference as the home screen that the woman is
//  seeing ... the best example is Flo." Flo for Partners (Mobbin): "a
//  view-only version of your current cycle day and cycle phase predictions",
//  insights about her, expert content, and "your partner can only access the
//  below data and can't log or edit anything".
//
//  So his Today is `TtcHomeV3` itself, with `TtcPartnerMode.on`:
//    · SAME: the cycle header, the day strip, the calendar, the doors, the
//      reads, the recommendations. One app, one look.
//    · LESS: no logging anywhere on the home (a log on his phone would land
//      in his own copy, never hers), none of her private logs on the rail
//      (discharge, symptoms), none of her own next steps (the round's notices,
//      today's visit, "it may be time for a check", the 101 course).
//    · HIS: the hero in his voice ("Her fertile days end today"), and one
//      block for him: today's mission, supporting her, tonight's question,
//      what is happening in her body, his half of getting pregnant. The words
//      are the ones his old screen already had (`ttc_partner_data.dart`); only
//      the look moved to hers.
//
//  ⚠️ NEVER FLO'S "CHANCE OF GETTING PREGNANT". A personalised probability is
//  forbidden in this app (CLAUDE.md, clinical invariants), for him as for her.
//
//  The old Slate screen (`TtcPartnerTodayScreen`) is kept for revert, unused.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_daily_data.dart' show ttcPickForToday;
import '../../ttc/ttc_home_hero.dart' show TtcHeroState;
import '../../ttc/ttc_partner_data.dart';
import '../../ttc/ttc_store.dart';
import '../../ttc/ttc_treatment_store.dart';
import '../v2/v2_palette.dart';
import 'ttc_daily_insights.dart' show TtcInsightCard;
import 'ttc_round_strings.dart' show kTtcPartnerRoundEyebrow, ttcPartnerRoundLine;
import 'ttc_strings.dart';

/// The rail cards he sees: her cycle, in "her" words, and what is for both of
/// them. Everything built from her own logs, and her own next steps, stays on
/// her side.
const Set<String> kTtcRailForHim = {
  'chance', 'cycle_day', 'cycle_length', 'insight', 'myth', 'nutrition',
};

String _her(String s) => s
    .replaceAll(RegExp(r'\bYOUR\b'), 'HER')
    .replaceAll(RegExp(r'\bYour\b'), 'Her')
    .replaceAll(RegExp(r'\byour\b'), 'her');

List<TtcInsightCard> ttcRailForHim(List<TtcInsightCard> cards) => [
      for (final c in cards)
        if (kTtcRailForHim.contains(c.id))
          TtcInsightCard(
            id: c.id,
            eyebrow: _her(c.eyebrow),
            value: _her(c.value),
            caption: c.caption == null ? null : _her(c.caption!),
            hue: c.hue,
            art: c.art,
            go: c.go,
            readId: c.readId,
          ),
    ];

/// The hero's lead and sub-line in his voice. The big middle phrase ("end
/// today", "in 3 days") is the same fact for both of them and is not touched.
/// English only: the Hindi side keeps hers, by the language rule.
(String, String) ttcHeroForHim(TtcHeroState state, String lead, String sub) {
  if (TtcLang.instance.hinglish) return (lead, sub);
  final l = lead
      .replaceAll("You're on", "She's on")
      .replaceAll(RegExp(r'\bYour\b'), 'Her')
      .replaceAll(RegExp(r'\byour\b'), 'her');
  final s = switch (state) {
    TtcHeroState.windowLastDay =>
      'The last of her fertile days this cycle. No pressure on either of you.',
    TtcHeroState.waiting =>
      'The wait before her period. Steady company helps more than questions.',
    TtcHeroState.periodDue || TtcHeroState.periodExpectedBy =>
      'Her period may come around now. Let her tell you how she is.',
    TtcHeroState.periodLate =>
      'Past her usual length. Testing is her call; be there either way.',
    TtcHeroState.onPeriod =>
      'Her period. A gentle, low-key few days help.',
    TtcHeroState.noEstimate || TtcHeroState.startHere =>
      'Her days show here once she has logged her period.',
    _ => sub
        .replaceAll(RegExp(r'\bYour\b'), 'Her')
        .replaceAll(RegExp(r'\byour\b'), 'her'),
  };
  return (l, s);
}

/// The one block that is his: below the insights, above the doors.
class TtcPartnerHomeBlock extends StatelessWidget {
  const TtcPartnerHomeBlock({super.key, required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    final hi = t.hinglish;
    final brief = ttcPartnerBriefs[TtcStore.instance.displayChapter]!;
    final mission = ttcPickForToday(ttcMissions);
    final round = ttcPartnerRoundLine(
        TtcTreatmentStore.instance.cycle, DateTime.now());

    final items = <Widget>[
      if (round case (final kind, final what, final note))
        _Ruled(
          p: p,
          eyebrow: '$kTtcPartnerRoundEyebrow · $kind',
          title: what,
          body: note,
        ),
      _Ruled(
        p: p,
        key: const ValueKey('ttc_partner_mission'),
        eyebrow: mission.forHimself
            ? '${t.partnerMission} · ${t.partnerAboutHimself}'
            : t.partnerMission,
        title: mission.title(hi),
        body: mission.body(hi),
      ),
      _Ruled(
        p: p,
        key: const ValueKey('ttc_partner_support'),
        eyebrow: t.partnerSupport,
        title: t.partnerSheMayFeel,
        body: brief.sheMayFeel(hi),
        second: (t.partnerYouCan, brief.youCan(hi)),
      ),
      _Ruled(
        p: p,
        eyebrow: kTtcTonightLabel,
        title: ttcTonightQuestion(),
      ),
      _Ruled(
        p: p,
        eyebrow: t.partnerHerBody,
        body: brief.herBody(hi),
      ),
      _Ruled(
        p: p,
        key: const ValueKey('ttc_partner_your_half'),
        eyebrow: t.partnerYourBody,
        body: brief.yourBody(hi),
      ),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('FOR YOU',
          style: pvManrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: p.ink3)),
      const SizedBox(height: 4),
      Text('Your part today', style: pvFraunces(fontSize: 22, color: p.ink1)),
      const SizedBox(height: 16),
      for (var i = 0; i < items.length; i++) ...[
        items[i],
        if (i < items.length - 1) const SizedBox(height: 22),
      ],
    ]);
  }
}

/// The home's editorial card: a thin ink rule on the left, a small eyebrow, a
/// serif title, a quiet body (the same shape as `TtcCheckCard`).
class _Ruled extends StatelessWidget {
  const _Ruled({
    super.key,
    required this.p,
    required this.eyebrow,
    this.title,
    this.body,
    this.second,
  });
  final V2Palette p;
  final String eyebrow;
  final String? title;
  final String? body;
  final (String, String)? second;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 2, 0, 2),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: p.ink1, width: 1.5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(eyebrow.toUpperCase(),
            style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: p.action)),
        if (title != null) ...[
          const SizedBox(height: 6),
          Text(title!,
              style: pvFraunces(fontSize: 19, height: 1.25, color: p.ink1)),
        ],
        if (body != null && body!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(body!,
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        ],
        if (second case (final label, final text)) ...[
          const SizedBox(height: 12),
          Text(label,
              style: pvFraunces(fontSize: 17, height: 1.25, color: p.ink1)),
          const SizedBox(height: 6),
          Text(text,
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        ],
      ]),
    );
  }
}

/// Where her quick-log row is, on his side: one quiet line saying why there is
/// nothing to log (Flo: "can't log or edit anything").
class TtcPartnerViewOnlyLine extends StatelessWidget {
  const TtcPartnerViewOnlyLine({super.key, required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Padding(
        key: const ValueKey('ttc_partner_view_only'),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.visibility_outlined, size: 16, color: p.ink3),
          const SizedBox(width: 8),
          Flexible(
            child: Text('Her cycle, as she logs it. Only she can change it.',
                textAlign: TextAlign.center,
                style: pvManrope(fontSize: 12.5, color: p.ink2)),
          ),
        ]),
      );
}
