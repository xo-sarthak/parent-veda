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
//  ⚠️ COMPETITORS SET THE BAR (corrected 2026-10-16). Where Flo or another
//  app does something better, that is the standard people expect and we
//  match it; we keep what we do beyond them, and pick only what is relevant
//  for him. This note used to read "never Flo's chance of getting pregnant",
//  which contradicted the rail below. The 'chance' card he sees is a GRADE of
//  her fertile window (days from estimated ovulation, Low to Highest), not a
//  probability, so it is allowed (test/ttc_clinical_review_test.dart bans a
//  personalised percentage, not this). The user, deciding it: "he should be
//  also knowing ... if we are not telling the male the fertile days, how are
//  we educating them?"
//
//  The old Slate screen (`TtcPartnerTodayScreen`) is kept for revert, unused.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_insight_read.dart' show kTtcShortPieceCallout;
import '../../widgets/pv_feedback.dart';
import '../../ttc/ttc_daily_data.dart' show ttcPickForToday;
import '../../ttc/ttc_home_hero.dart' show TtcHeroState;
import '../../ttc/ttc_partner_data.dart';
import '../../ttc/ttc_store.dart';
import '../../ttc/ttc_treatment_store.dart';
import '../doors/pv_list_row.dart';
// Kept for revert with the tile row: import '../v2/pv_insight_rail.dart';
import 'doors/ttc_tab_art.dart' show TtcTabMark;
import 'ttc_tool_marks.dart' show TtcMarkLeading;
import '../v2/v2_palette.dart';
import 'ttc_common.dart' show TtcSectionHeading;
import 'ttc_daily_insights.dart' show TtcInsightCard;
import 'ttc_daily_tip_open.dart' show openTtcTipRead;
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

    // ⚠️ ONE CARD AND A ROW, NOT FIVE PARAGRAPHS (2026-10-16). The user, on
    // the device: "this initial homescreen looks very text cluttered". The
    // five ruled blocks were about 25 lines, and nothing on her home reads
    // like that. Now: today's mission as one compact card (two lines, tap for
    // all of it) and the rest as a row in the same tiles as her insights.
    // Every word is still there, one tap deeper in the one reader (Flo's
    // partner home and Oura's "guidance and tips" do the same on Mobbin).
    // Kept for revert: the five `_Ruled` blocks, commented below.
    final missionRead = ttcPartnerRead(
      id: 'ttc_partner_mission_${mission.id}',
      kicker: t.partnerMission,
      teaser: kTtcMissionTeaser,
      title: LocalizedText(en: mission.title(false), hi: mission.title(true)),
      paragraphs: [
        LocalizedText(en: mission.body(false), hi: mission.body(true)),
      ],
    );
    final tiles = <(String, String, double, PvRead, Key?)>[
      (
        t.partnerSupport,
        t.partnerSheMayFeel,
        268,
        ttcPartnerRead(
          id: 'ttc_partner_support',
          kicker: t.partnerSupport,
          teaser: kTtcSupportTeaser,
          title: LocalizedText(en: t.partnerSheMayFeel, hi: t.partnerSheMayFeel),
          paragraphs: [
            LocalizedText(
                en: brief.sheMayFeel(false), hi: brief.sheMayFeel(true)),
          ],
          second: (
            LocalizedText(en: t.partnerYouCan, hi: t.partnerYouCan),
            LocalizedText(en: brief.youCan(false), hi: brief.youCan(true)),
          ),
        ),
        const ValueKey('ttc_partner_support'),
      ),
      (
        kTtcTonightLabel,
        kTtcTonightTileValue,
        206,
        ttcPartnerRead(
          id: 'ttc_partner_tonight',
          kicker: kTtcTonightLabel,
          teaser: kTtcTonightTeaser,
          title:
              LocalizedText(en: ttcTonightQuestion(), hi: ttcTonightQuestion()),
          paragraphs: const [
            LocalizedText(en: kTtcTonightReadNote, hi: kTtcTonightReadNote),
          ],
        ),
        null,
      ),
      (
        kTtcHerBodyTileEyebrow,
        kTtcHerBodyTileValue,
        104,
        ttcPartnerRead(
          id: 'ttc_partner_her_body',
          kicker: kTtcHerBodyTileEyebrow,
          teaser: kTtcHerBodyTeaser,
          title: LocalizedText(en: t.partnerHerBody, hi: t.partnerHerBody),
          paragraphs:
              ttcPartnerParagraphs(brief.herBody(false), brief.herBody(true)),
        ),
        null,
      ),
      (
        kTtcYourHalfTileEyebrow,
        kTtcYourHalfTileValue,
        42,
        ttcPartnerRead(
          id: 'ttc_partner_your_half',
          kicker: kTtcYourHalfTileEyebrow,
          teaser: kTtcYourHalfTeaser,
          title: LocalizedText(en: t.partnerYourBody, hi: t.partnerYourBody),
          paragraphs: [
            LocalizedText(en: brief.yourBody(false), hi: brief.yourBody(true)),
          ],
        ),
        const ValueKey('ttc_partner_your_half'),
      ),
    ];

    // The head and the cards sit in the page gutter; the row runs edge to
    // edge and pads itself (`PvInsightRail`'s rule), so the home no longer
    // wraps this block in `_pad`.
    Widget gutter(Widget w) =>
        Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: w);

    // ⚠️ THE HOME'S OWN HEADING, NOT A LOOK-ALIKE (2026-10-16). This header
    // was hand-built and drifted twice: a grey eyebrow (`p.ink3`) where every
    // other section is purple, and a default-weight title that read as a
    // different font beside "Today" and "Explore by topic". It now copies
    // `_Head` in ttc_home_v3.dart exactly (that one is private) and uses the
    // shared `TtcSectionHeading`. Kept for revert:
    //   Text('FOR YOU', style: pvManrope(fontSize: 11, fontWeight:
    //       FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
    //   const SizedBox(height: 4),
    //   Text('Your part today', style: pvFraunces(fontSize: 22, color: p.ink1)),
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      gutter(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('FOR YOU',
            style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: p.action)),
        const SizedBox(height: 5),
        TtcSectionHeading('Your part today', color: p.ink1),
        const SizedBox(height: 14),
        if (round case (final kind, final what, final note)) ...[
          _PartCard(
            p: p,
            eyebrow: '$kTtcPartnerRoundEyebrow · $kind',
            title: what,
            body: note,
          ),
          const SizedBox(height: 10),
        ],
        _PartCard(
          key: const ValueKey('ttc_partner_mission'),
          p: p,
          eyebrow: mission.forHimself
              ? '${t.partnerMission} · ${t.partnerAboutHimself}'
              : t.partnerMission,
          title: mission.title(hi),
          body: mission.body(hi),
          onTap: () => openTtcTipRead(context, missionRead),
        ),
      ])),
      const SizedBox(height: 14),
      // ⚠️ ROWS, NOT TILES (2026-10-16). The user: "these are like in the same
      // format as the insights about her today ... why the repetitiveness?"
      // Four tiles in the insight look read as a second insights rail. These
      // are things to read, so they wear the reading list's rows (the same
      // `PvListRow` as "Trying to conceive 101"): a drawn mark, the name, one
      // line, a chevron. Kept for revert: a horizontal SingleChildScrollView
      // of `PvInsightTile`s (eyebrow, value, hue, showArt: false,
      // centreValue: true), each opening the same read.
      gutter(PvRowGroup(p: p, children: [
        for (var i = 0; i < tiles.length; i++)
          KeyedSubtree(
            key: tiles[i].$5,
            child: PvListRow(
              p: p,
              // The doors' pale tint from the row's own hue (2026-10-16): the
              // full purple painted a heavy disc the mark disappeared into.
              leading: TtcMarkLeading(
                  tab: _kPartMarks[i],
                  tint: v2BlockTint(tiles[i].$3 % 360, p),
                  size: 40),
              title: tiles[i].$1,
              line: tiles[i].$2,
              onTap: () => openTtcTipRead(context, tiles[i].$4),
            ),
          ),
      ])),
    ]);

    // Kept for revert (2026-10-16): the five ruled blocks, each spaced by
    // SizedBox(height: 22) under the header.
    // final items = <Widget>[
    //   if (round case (final kind, final what, final note))
    //     _Ruled(p: p, eyebrow: '$kTtcPartnerRoundEyebrow · $kind',
    //         title: what, body: note),
    //   _Ruled(p: p, key: const ValueKey('ttc_partner_mission'),
    //       eyebrow: t.partnerMission, title: mission.title(hi),
    //       body: mission.body(hi)),
    //   _Ruled(p: p, key: const ValueKey('ttc_partner_support'),
    //       eyebrow: t.partnerSupport, title: t.partnerSheMayFeel,
    //       body: brief.sheMayFeel(hi),
    //       second: (t.partnerYouCan, brief.youCan(hi))),
    //   _Ruled(p: p, eyebrow: kTtcTonightLabel, title: ttcTonightQuestion()),
    //   _Ruled(p: p, eyebrow: t.partnerHerBody, body: brief.herBody(hi)),
    //   _Ruled(p: p, key: const ValueKey('ttc_partner_your_half'),
    //       eyebrow: t.partnerYourBody, body: brief.yourBody(hi)),
    // ];
  }
}

/// The tile words for the row (2026-10-16). Short on purpose: a tile is
/// 100pt wide and its answer is one tap away.
/// The drawn marks on his reading rows, in order (2026-10-16).
const List<TtcTabMark> _kPartMarks = [
  TtcTabMark.heartHand,
  TtcTabMark.twoBubbles,
  TtcTabMark.cycleDrops,
  TtcTabMark.twoCircles,
];

const String kTtcTonightTileValue = 'A question for tonight';
const String kTtcTonightReadNote =
    'One question, nothing to fix. Ask it, then listen. If she would rather '
    'not talk tonight, that is an answer too.';
const String kTtcHerBodyTileEyebrow = 'Her body';
const String kTtcHerBodyTileValue = "What's happening now";
const String kTtcYourHalfTileEyebrow = 'Your half';
const String kTtcYourHalfTileValue = 'Your side of it';

/// Each piece's one-line standfirst in the reader (2026-10-16). Its own
/// line, not the first paragraph: the reader draws the standfirst, then the
/// first paragraph as the lede, so passing the same text to both showed it
/// three times on the device.
const String kTtcMissionTeaser = 'One small thing for you to do today.';
const String kTtcSupportTeaser =
    'How she may be feeling at this point in her cycle, and what helps.';
const String kTtcTonightTeaser = 'One question to ask her tonight.';
const String kTtcHerBodyTeaser =
    'What her body is doing at this point in her cycle.';
const String kTtcYourHalfTeaser =
    'Your part of getting pregnant, at this point in her cycle.';

final RegExp _blankLine = RegExp(r'\n\s*\n');

/// Splits a brief's long text on its blank lines, one paragraph each.
@visibleForTesting
List<LocalizedText> ttcPartnerParagraphs(String en, String hi) {
  List<String> split(String s) => s
      .split(_blankLine)
      .map((x) => x.trim())
      .where((x) => x.isNotEmpty)
      .toList();
  final e = split(en);
  final h = split(hi);
  return [
    for (var i = 0; i < e.length; i++)
      LocalizedText(en: e[i], hi: e.length == h.length ? h[i] : e[i]),
  ];
}

/// One of his pieces as a read, for the one reader (`PvReaderScreen`, via
/// `openTtcTipRead`). The same shape as the daily tip reads.
@visibleForTesting
PvRead ttcPartnerRead({
  required String id,
  required String kicker,
  required String teaser,
  required LocalizedText title,
  required List<LocalizedText> paragraphs,
  (LocalizedText, LocalizedText)? second,
}) =>
    PvRead(
      id: id,
      kicker: LocalizedText(en: kicker, hi: kicker),
      title: title,
      teaser: LocalizedText(en: teaser, hi: teaser),
      // The first paragraph, once, as the lede; the rest is the body.
      scaleSetter: paragraphs.first,
      author: const LocalizedText(en: 'ParentVeda team', hi: 'ParentVeda team'),
      authorRole: const LocalizedText(en: 'For him', hi: 'For him'),
      reviewed: false,
      hue: 268,
      sections: [
        if (paragraphs.length > 1)
          PvReadSection(paragraphs: paragraphs.sublist(1)),
        if (second case (final heading, final body))
          PvReadSection(heading: heading, paragraphs: [body]),
      ],
      whenToSeeSomeone: kTtcShortPieceCallout,
      faqs: const [],
    );

/// His home's compact card (2026-10-16): the eyebrow, a title, two lines and
/// a chevron when it opens something. The shape of `Ttc101Card`, so his
/// cards and hers are one family.
class _PartCard extends StatelessWidget {
  const _PartCard({
    super.key,
    required this.p,
    required this.eyebrow,
    required this.title,
    this.body,
    this.onTap,
  });
  final V2Palette p;
  final String eyebrow;
  final String title;
  final String? body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final opens = onTap != null;
    final card = Material(
      color: p.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: opens
            ? () {
                pvCommitFeedback();
                onTap!();
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(eyebrow.toUpperCase(),
                        style: pvManrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                            color: p.action)),
                    const SizedBox(height: 5),
                    Text(title,
                        style: pvFraunces(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            letterSpacing: -0.3,
                            color: p.ink1)),
                    if (body != null && body!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(body!,
                          maxLines: opens ? 2 : null,
                          overflow: opens ? TextOverflow.ellipsis : null,
                          style: pvManrope(
                              fontSize: 13, height: 1.45, color: p.ink2)),
                    ],
                  ]),
            ),
            if (opens) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 22, color: p.ink3),
            ],
          ]),
        ),
      ),
    );
    // One labelled node, as `PvInsightTile` does: without it the card's words
    // merged into the page and a screen reader (and the device walk's label
    // taps) could not find it as a button (2026-10-16).
    final labelled = Semantics(
      button: opens,
      label: '${eyebrow.toUpperCase()}: $title',
      excludeSemantics: true,
      child: card,
    );
    return opens ? PvPress(child: labelled) : labelled;
  }
}

// Kept for revert (2026-10-16): `_Ruled`, the ruled editorial card the five
// blocks used. Restore with the commented `items` list above.
// /// The home's editorial card: a thin ink rule on the left, a small eyebrow, a
// /// serif title, a quiet body (the same shape as `TtcCheckCard`).
// class _Ruled extends StatelessWidget {
//   const _Ruled({
//     super.key,
//     required this.p,
//     required this.eyebrow,
//     this.title,
//     this.body,
//     this.second,
//   });
//   final V2Palette p;
//   final String eyebrow;
//   final String? title;
//   final String? body;
//   final (String, String)? second;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 2, 0, 2),
//       decoration: BoxDecoration(
//         border: Border(left: BorderSide(color: p.ink1, width: 1.5)),
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         // Her `TtcCheckCard` is the same ruled card; the eyebrow tracking and
//         // the title weight now match it (2026-10-16; they were 0.8 and the
//         // default weight, which read as a lighter font). Kept for revert:
//         // letterSpacing: 0.8 / pvFraunces(fontSize: 19, height: 1.25, ...).
//         Text(eyebrow.toUpperCase(),
//             style: pvManrope(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w800,
//                 letterSpacing: 1.4,
//                 color: p.action)),
//         if (title != null) ...[
//           const SizedBox(height: 6),
//           Text(title!,
//               style: pvFraunces(
//                   fontSize: 19,
//                   fontWeight: FontWeight.w600,
//                   height: 1.25,
//                   letterSpacing: -0.3,
//                   color: p.ink1)),
//         ],
//         if (body != null && body!.trim().isNotEmpty) ...[
//           const SizedBox(height: 6),
//           Text(body!,
//               style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
//         ],
//         if (second case (final label, final text)) ...[
//           const SizedBox(height: 12),
//           Text(label,
//               style: pvFraunces(
//                   fontSize: 17,
//                   fontWeight: FontWeight.w600,
//                   height: 1.25,
//                   letterSpacing: -0.3,
//                   color: p.ink1)),
//           const SizedBox(height: 6),
//           Text(text,
//               style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
//         ],
//       ]),
//     );
//   }
// }

/// Where her quick-log row is, on his side: one quiet line saying why there is
/// nothing to log (Flo: "can't log or edit anything").
class TtcPartnerViewOnlyLine extends StatelessWidget {
  const TtcPartnerViewOnlyLine({super.key, required this.p, this.text});
  final V2Palette p;

  /// The line itself; the default is the home's (2026-10-16: the cycle
  /// companion and the home's "I'm pregnant" place say their own).
  final String? text;

  @override
  Widget build(BuildContext context) => Padding(
        key: text == null ? const ValueKey('ttc_partner_view_only') : null,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.visibility_outlined, size: 16, color: p.ink3),
          const SizedBox(width: 8),
          Flexible(
            child: Text(text ?? kTtcPartnerViewOnly,
                textAlign: TextAlign.center,
                style: pvManrope(fontSize: 12.5, color: p.ink2)),
          ),
        ]),
      );
}

const String kTtcPartnerViewOnly =
    'Her cycle, as she logs it. Only she can change it.';

/// Where her "I'm pregnant" door sits, on his side (2026-10-16).
const String kTtcPartnerPregnantLine =
    "She'll mark it here when she knows. Your side moves with hers.";

/// His door ("His side", bracket `ttc_male_fertility`) leads the topic grid
/// on his side (2026-10-16), as `kTtcHisLearnFirst` already does on Learn.
/// Her order is untouched.
List<String> ttcHisDoorsFirst(List<String> ids, {required bool him}) {
  const his = 'ttc_male_fertility';
  if (!him || !ids.contains(his)) return ids;
  return [his, for (final id in ids) if (id != his) id];
}
