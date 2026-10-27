// =============================================================================
//  Inline tools on a parenting door (`PpDoorTab.inlineSurfaceId`)
// -----------------------------------------------------------------------------
//  The parenting twin of the pregnancy door's `pvDoorInlineToolFor`: a tool
//  drawn in place as a tab's first block, because a card in front of the
//  thing a tab is for is a door in front of a door. Each one lays out its own
//  gutter (`kPvDoorSelfPaddedTools`'s rule) so its rail runs edge to edge.
//
//  Three so far: Development's Play today shelf (door plan 04, D2, look
//  approved 2026-10-24, `claude.ai/artifact/1bsFmZ4i5SRg8oiQFyeHHR`),
//  Potty's "Try this today" (door plan 05, PT3), which reuses that look, and
//  First 40's "Try this today" by week (door plan 06, FD1, the same look).
//  Then Sleep's "Tonight" (door plan 07, SL1) and Behaviour's "Right now"
//  (door plan 08, BH1), both on the same card.
//
//  ⚠️ THIS FILE NEVER IMPORTS THE ROUTER, as the door screen doesn't. A tap
//  that leaves the shelf goes through the door's own `onSurface`; an activity
//  opens in the one reader directly, as the Activities screen opens it.
// =============================================================================

import 'dart:math' show Random;

import 'package:flutter/material.dart';

import '../../../data/doors/pp_door_behaviour.dart'
    show kPpBehaviourDoor, kPpBehRightNowCards, kPpBehRightNowShelf, PpBehRightNowCard;
import '../../../data/doors/pp_door_development.dart' show kPpPlayTodayShelf;
import '../../../data/doors/pp_door_first40.dart' show kPpFirst40TodayShelf;
import '../../../data/doors/pp_door_potty.dart'
    show kPpPottyDoor, kPpPottyTodayShelf;
import '../../../data/doors/pp_door_sleep.dart'
    show kPpSleepDoor, kPpSleepTonightCards, kPpSleepTonightShelf, PpSleepTonightCard;
import '../../../theme/pv_fonts.dart';
import '../../doors/pv_door_chrome.dart' show kPvDoorGutter;
import '../../doors/pv_door_screen.dart' show kPvDoorHeadingGap;
import '../../v2/v2_palette.dart';
import '../../v2/v3_dev_mark.dart' show V3DevMark, devMarkFor;
import '../pp_activity_paintings.dart' show ppActivityPainting;
import '../pp_activity_read.dart' show ppActivityReader;
import '../pp_behaviour_content.dart' show kPpBehaviourSection;
import '../pp_child_profile.dart';
import '../pp_content.dart' show PpPage;
import '../pp_page_fill.dart' show ppPageTitle;
import '../multichild_sheet.dart' show showAddChildForm;
import '../pp_development_data.dart';
import '../pp_din_by_din.dart';
import '../pp_first40_content.dart' show kPpFirst40Section;
import '../pp_phases_data.dart' show ppFillChild;
import '../pp_potty_content.dart';
import '../pp_section_screen.dart' show ppOpenPage;
import '../pp_sleep_content.dart' show kPpSleepSection;
import '../pp_age_bands.dart' show kPpChildBands, kPpSleepBands;

/// The inline tool for [surfaceId], or null when there is none (the tab then
/// opens on its rails, as every other tab does).
Widget? ppDoorInlineToolFor(
  String surfaceId, {
  required V2Palette p,
  required void Function(String surfaceId) onSurface,
}) =>
    switch (surfaceId) {
      kPpPlayTodayShelf => PpPlayTodayShelf(p: p, onSurface: onSurface),
      kPpFirst40TodayShelf => PpFirst40TodayShelf(p: p, onSurface: onSurface),
      _ when ppPottyShelfShows(surfaceId) =>
        PpPottyTodayShelf(p: p, onSurface: onSurface),
      _ when ppSleepShelfShows(surfaceId) =>
        PpSleepTonightShelf(p: p, onSurface: onSurface),
      _ when ppBehShelfShows(surfaceId) =>
        PpBehRightNowShelf(p: p, onSurface: onSurface),
      _ => null,
    };

/// How many things an inline tool shows, for the tab card's count.
int ppDoorInlineCount(String surfaceId) => switch (surfaceId) {
      kPpPlayTodayShelf => ppPlayTodayPicks().length,
      kPpFirst40TodayShelf => ppFirst40TodayPicks().length +
          (ppDinKnown() && ppDinAfter(kPpDinTabId) ? 1 : 0),
      _ when ppPottyShelfShows(surfaceId) => ppPottyTodayPicks().length,
      _ when ppSleepShelfShows(surfaceId) => ppSleepTonightPicks().length,
      _ when ppBehShelfShows(surfaceId) => ppBehRightNowPicks().length,
      _ => 0,
    };

/// ⚠️ THE PAGES AN INLINE TOOL DRAWS, SO THE RAILS DO NOT DRAW THEM AGAIN.
/// Potty's shelf is pages of the tab's own area; the rails skip them the way
/// they skip an age rail's, and an area left empty drops. Empty for a tool
/// that is not pages (Play today's activities are not section pages).
/// Sleep's Tonight row is the same (SL1): a newborn's Safe sleep tab does not
/// show the sleep-space check and the swaddle twice. Its cards from another
/// tab (Gentle settling on Waking) are not on this tab's rails anyway.
/// Behaviour's Right now row likewise (BH1): the crying pages on it are not
/// drawn again on the Crying tab's rail.
Set<String> ppDoorInlinePageIds(String surfaceId) => ppPottyShelfShows(surfaceId)
    ? {for (final x in ppPottyTodayPicks()) x.id}
    : ppSleepShelfShows(surfaceId)
        ? {for (final c in ppSleepTonightPicks()) ?c.pageId}
        : ppBehShelfShows(surfaceId)
            ? {for (final c in ppBehRightNowPicks()) ?c.pageId}
            : const {};
    // Before Sleep's row (SL1), kept for revert:
    // : const {};
    // Before Behaviour's row (BH1), kept for revert:
    //     : const {};

/// ⚠️ THE SURFACES AN INLINE ROW OPENS, SO THE TAB DOES NOT DRAW THEIR TOOL
/// ROWS AGAIN (Behaviour BH1). Right now ends on What to say, which is also a
/// tool on the Crying and Tantrums tabs. Empty when the row is not drawn for
/// her band, so the same tab for another age keeps its tool row.
Set<String> ppDoorInlineSurfaceIds(String surfaceId) => ppBehShelfShows(surfaceId)
    ? {for (final c in ppBehRightNowPicks()) ?c.surfaceId}
    : ppSleepShelfShows(surfaceId)
        ? {for (final c in ppSleepTonightPicks()) ?c.surfaceId}
        : const {};

// =============================================================================
//  Sleep: "Tonight" (SL1)
// =============================================================================

/// ⚠️ ONE ROW, ON THE TAB THAT OPENS FOR HER BAND. Two tabs can host it
/// (`kPpSleepTonightShelf/<tab id>`): Safe sleep for a newborn, Getting to
/// sleep after that. It draws only where `tabOrder` lands her, so a
/// four-month-old's Safe sleep tab is pages, not the same row twice.
bool ppSleepShelfShows(String surfaceId, {String? band}) {
  const prefix = '$kPpSleepTonightShelf/';
  if (!surfaceId.startsWith(prefix)) return false;
  final b = band ?? kPpSleepBands.active.id;
  return kPpSleepDoor.tabOrder[b]?.first == surfaceId.substring(prefix.length);
}

/// The cards for her band, in the plan's order, and all of them (four or
/// five). A page card is dropped only if its page is missing or not for her
/// band, so a later retag can never put a newborn page on a toddler's row.
/// Pure, so a test can hold any band.
List<PpSleepTonightCard> ppSleepTonightPicks({String? band}) {
  final b = band ?? kPpSleepBands.active.id;
  return [
    for (final c in kPpSleepTonightCards[b] ?? const <PpSleepTonightCard>[])
      if (c.pageId == null ||
          (kPpSleepSection.pageById(c.pageId!)?.inBand(b) ?? false))
        c,
  ];
}

/// The card's meta word: what a tap does.
String _sleepTonightMeta(PpSleepTonightCard c) {
  if (c.surfaceId == 'pp_sleep_sounds') return 'Listen';
  if (c.surfaceId == 'pp_wake_windows') return 'Tool';
  if (c.surfaceId != null) return 'Stories';
  final page = kPpSleepSection.pageById(c.pageId!);
  return page?.format == 'VIDEO' ? 'Watch' : 'How to';
}

/// "Tonight": the heading, its line, and the cards for her band.
class PpSleepTonightShelf extends StatelessWidget {
  const PpSleepTonightShelf({super.key, required this.p, required this.onSurface});

  final V2Palette p;
  final void Function(String surfaceId) onSurface;

  @override
  Widget build(BuildContext context) {
    final kid = ChildProfileStore.instance;
    final picks = ppSleepTonightPicks();
    final ts = MediaQuery.textScalerOf(context);
    final height = 104 + ts.scale(118);
    // The Sleep door's night blue (the Waking tab's hue).
    final accent = HSLColor.fromAHSL(1, 232, 0.38, 0.42).toColor();
    return Column(
      key: const ValueKey('pp_sleep_tonight_shelf'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tonight',
                style: pvFraunces(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.45,
                    color: p.ink1)),
            const SizedBox(height: 2),
            Text('For ${kid.nameMid}, ${kid.ageLabel}  ·  nothing to tick off',
                style: pvManrope(
                    fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink3)),
          ]),
        ),
        const SizedBox(height: kPvDoorHeadingGap),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
            itemCount: picks.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final c = picks[i];
              final page =
                  c.pageId == null ? null : kPpSleepSection.pageById(c.pageId!);
              return _ShelfCard(
                key: ValueKey('pp_sleep_tonight_card_${c.pageId ?? c.surfaceId}'),
                p: p,
                height: height,
                meta: '${_sleepTonightMeta(c)}  ·  Tonight'.toUpperCase(),
                title: c.name,
                picture: Container(
                  color: Color.alphaBlend(accent.withValues(alpha: 0.16), p.surface),
                  alignment: Alignment.center,
                  child: Icon(c.icon, size: 40, color: accent),
                ),
                onTap: () => page != null
                    ? ppOpenPage(context, kPpSleepSection, page,
                        onSurface: (_, id) => onSurface(id))
                    : onSurface(c.surfaceId!),
              );
            },
          ),
        ),
      ],
    );
  }
}

// =============================================================================
//  Behaviour: "Right now" (BH1)
// =============================================================================

/// ⚠️ ONE ROW, ON THE TAB THAT OPENS FOR HER BAND, as Sleep's Tonight is.
/// Three tabs can host it (`kPpBehRightNowShelf/<tab id>`): Crying for a baby,
/// Tantrums from one to three, He keeps doing this from three. It draws only
/// where `tabOrder` lands her, so a two-year-old's He keeps doing this tab is
/// pages, not the row twice.
bool ppBehShelfShows(String surfaceId, {String? band}) {
  const prefix = '$kPpBehRightNowShelf/';
  if (!surfaceId.startsWith(prefix)) return false;
  final b = band ?? kPpChildBands.active.id;
  return kPpBehaviourDoor.tabOrder[b]?.first == surfaceId.substring(prefix.length);
}

/// The cards for her band, in the plan's order, all five. A page card drops
/// only if its page is missing or not for her band, so a later retag can
/// never put a toddler page on a baby's row. Pure, so a test can hold any
/// band.
List<PpBehRightNowCard> ppBehRightNowPicks({String? band}) {
  final b = band ?? kPpChildBands.active.id;
  return [
    for (final c in kPpBehRightNowCards[b] ?? const <PpBehRightNowCard>[])
      if (c.pageId == null ||
          (kPpBehaviourSection.pageById(c.pageId!)?.inBand(b) ?? false))
        c,
  ];
}

/// The card's meta word: what a tap does.
String _behRightNowMeta(PpBehRightNowCard c) {
  if (c.surfaceId != null) return 'The words';
  final page = kPpBehaviourSection.pageById(c.pageId!);
  return switch (page?.format) {
    'STEP-LIST' || 'INTERACTIVE' => 'Steps',
    'ACTIVITY' => 'Try this',
    _ => 'Read',
  };
}

/// "Right now": the heading, its line, and the cards for her band.
class PpBehRightNowShelf extends StatelessWidget {
  const PpBehRightNowShelf({super.key, required this.p, required this.onSurface});

  final V2Palette p;
  final void Function(String surfaceId) onSurface;

  @override
  Widget build(BuildContext context) {
    final kid = ChildProfileStore.instance;
    final picks = ppBehRightNowPicks();
    final ts = MediaQuery.textScalerOf(context);
    final height = 104 + ts.scale(118);
    // The Tantrums tab's rose, the door's own colour.
    final accent = HSLColor.fromAHSL(1, 344, 0.42, 0.46).toColor();
    return Column(
      key: const ValueKey('pp_beh_right_now_shelf'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Right now',
                style: pvFraunces(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.45,
                    color: p.ink1)),
            const SizedBox(height: 2),
            Text('For ${kid.nameMid}, ${kid.ageLabel}  ·  nothing to tick off',
                style: pvManrope(
                    fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink3)),
          ]),
        ),
        const SizedBox(height: kPvDoorHeadingGap),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
            itemCount: picks.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final c = picks[i];
              final page = c.pageId == null
                  ? null
                  : kPpBehaviourSection.pageById(c.pageId!);
              return _ShelfCard(
                key: ValueKey('pp_beh_right_now_card_${c.pageId ?? c.surfaceId}'),
                p: p,
                height: height,
                meta: _behRightNowMeta(c).toUpperCase(),
                title: c.name,
                picture: Container(
                  color: Color.alphaBlend(accent.withValues(alpha: 0.14), p.surface),
                  alignment: Alignment.center,
                  child: Icon(c.icon, size: 40, color: accent),
                ),
                onTap: () => page != null
                    ? ppOpenPage(context, kPpBehaviourSection, page,
                        onSurface: (_, id) => onSurface(id))
                    : onSurface(c.surfaceId!),
              );
            },
          ),
        ),
      ],
    );
  }
}

// =============================================================================
//  First 40 Days: "Try this today", by week (FD1)
// =============================================================================

/// ⚠️ THE HOW-TOS FOR HER WEEK, ALL PAGES THAT ALREADY EXIST (FD1, the user's
/// yes 2026-10-24 after the rows mockup). Cord care, the bath, malish and
/// the latch were step-lists spread over three tabs, and Day by day opened
/// on a line and an article. (last day, page ids), in the plan's order; not
/// shuffled, because the first week's skin to skin and latch matter more
/// than its burping.
const List<(int, List<String>)> kPpFirst40WeekCards = [
  (7, ['f40_skin_to_skin', 'f40_latch', 'f40_cord_care', 'f40_nappy_poop', 'f40_burping']),
  (20, ['f40_first_bath', 'f40_swaddle', 'f40_soothing', 'f40_day_night', 'f40_burping']),
  (40, ['f40_malish', 'f40_jhula', 'f40_soothing', 'f40_skin_to_skin', 'f40_first_bath']),
];

/// After the forty days: two pages, then a card on to Development's Play
/// today (`kPpFirst40PlayToday`), where the next months' things to do live.
const List<String> kPpFirst40AfterCards = ['f40_malish', 'f40_soothing'];
const String kPpFirst40PlayToday = 'pp_section/parenting_development';

/// The card names. The page titles are sentences ("Nappies, and what newborn
/// poop should look like") and a shelf card holds a name, whole.
const Map<String, String> kPpFirst40CardNames = {
  'f40_skin_to_skin': 'Skin to skin',
  'f40_latch': 'The latch',
  'f40_cord_care': 'Cord care',
  'f40_nappy_poop': "Nappies: what's normal",
  'f40_burping': 'Burping',
  'f40_first_bath': 'The first bath',
  'f40_swaddle': 'Swaddling',
  'f40_soothing': 'Soothing',
  'f40_day_night': 'Day and night',
  'f40_malish': 'Malish',
  'f40_jhula': 'The jhula',
};

const Map<String, IconData> _kFirst40CardIcons = {
  'f40_skin_to_skin': Icons.favorite_border_rounded,
  'f40_latch': Icons.water_drop_outlined,
  'f40_cord_care': Icons.healing_outlined,
  'f40_nappy_poop': Icons.baby_changing_station_outlined,
  'f40_burping': Icons.air_outlined,
  'f40_first_bath': Icons.bathtub_outlined,
  'f40_swaddle': Icons.crib_outlined,
  'f40_soothing': Icons.spa_outlined,
  'f40_day_night': Icons.wb_twilight_outlined,
  'f40_malish': Icons.back_hand_outlined,
  'f40_jhula': Icons.bedroom_baby_outlined,
};

/// The pages for her day. Empty with no birthday saved (FD7: the shelf
/// appears once the date is). Pure for a given [day], so a test can hold
/// every week.
List<PpPage> ppFirst40TodayPicks({int? day}) {
  if (day == null && !ppDinKnown()) return const [];
  final d = day ?? ppDinDay();
  final ids = d > kPpDinLines.length
      ? kPpFirst40AfterCards
      : kPpFirst40WeekCards.firstWhere((w) => d <= w.$1).$2;
  return [for (final id in ids) ?kPpFirst40Section.pageById(id)];
}

/// Day by day's own block: the birthday ask with none saved (FD7), the
/// after-forty line past day 40 (FD3), and the week's how-tos (FD1).
///
/// ⚠️ ALL THREE LIVE HERE, NOT IN THE DOOR SCREEN, so the shared screen
/// keeps one line for this door (the Day card, `ppDinToday`), and the
/// first-forty logic stays in the two First 40 files.
class PpFirst40TodayShelf extends StatelessWidget {
  const PpFirst40TodayShelf({super.key, required this.p, required this.onSurface});

  final V2Palette p;
  final void Function(String surfaceId) onSurface;

  @override
  Widget build(BuildContext context) {
    if (!ppDinKnown()) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
        child: PpDinNoBirthdayCard(p: p, onAdd: () => showAddChildForm(context)),
      );
    }
    final kid = ChildProfileStore.instance;
    final day = ppDinDay();
    final after = ppDinAfter(kPpDinTabId);
    final picks = ppFirst40TodayPicks();
    final ts = MediaQuery.textScalerOf(context);
    final height = 104 + ts.scale(118);
    final accent = HSLColor.fromAHSL(1, 26, 0.55, 0.45).toColor();
    Widget picture(IconData icon) => Container(
          color: Color.alphaBlend(accent.withValues(alpha: 0.16), p.surface),
          alignment: Alignment.center,
          child: Icon(icon, size: 40, color: accent),
        );
    final cards = <Widget>[
      for (final page in picks)
        _ShelfCard(
          key: ValueKey('pp_f40_today_card_${page.id}'),
          p: p,
          height: height,
          meta: [
            page.format == 'VIDEO' ? 'Watch' : 'How to',
            after ? 'Now' : 'This week',
          ].join('  ·  ').toUpperCase(),
          title: kPpFirst40CardNames[page.id] ?? ppPageTitle(page),
          picture: picture(_kFirst40CardIcons[page.id] ?? Icons.spa_outlined),
          onTap: () => ppOpenPage(context, kPpFirst40Section, page,
              onSurface: (_, id) => onSurface(id)),
        ),
      if (after)
        _ShelfCard(
          key: const ValueKey('pp_f40_today_play'),
          p: p,
          height: height,
          meta: 'DEVELOPMENT',
          title: 'Play with ${kid.them} today',
          picture: picture(Icons.toys_outlined),
          onTap: () => onSurface(kPpFirst40PlayToday),
        ),
    ];
    return Column(
      key: const ValueKey('pp_f40_today_shelf'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (after) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
            child: PpDinAfterCard(p: p, onSurface: onSurface),
          ),
          const SizedBox(height: kPvDoorHeadingGap * 2),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Try this today',
                style: pvFraunces(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.45,
                    color: p.ink1)),
            const SizedBox(height: 2),
            Text(
                after
                    ? 'For ${kid.nameMid}, ${kid.ageLabel}  ·  nothing to tick off'
                    : 'For ${kid.nameMid}, day $day  ·  nothing to tick off',
                style: pvManrope(
                    fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink3)),
          ]),
        ),
        const SizedBox(height: kPvDoorHeadingGap),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
            itemCount: cards.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) => cards[i],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
//  Potty: "Try this today" (PT3)
// =============================================================================

/// ⚠️ ONE SHELF, ON THE TAB THAT OPENS FOR HIS STAGE. Three tabs can host it
/// (`kPpPottyTodayShelf/<tab id>`): su-su for a baby, Starting out from one,
/// Accidents from three. It draws only where `tabOrder` lands him, so a
/// two-year-old's Accidents tab is pages, not the same shelf twice.
bool ppPottyShelfShows(String surfaceId, {String? band}) {
  const prefix = '$kPpPottyTodayShelf/';
  if (!surfaceId.startsWith(prefix)) return false;
  final b = band ?? kPpPottyBands.active.id;
  return kPpPottyDoor.tabOrder[b]?.first == surfaceId.substring(prefix.length);
}

/// ⚠️ THE CARDS FOR HIS STAGE, IN A FRESH ORDER EACH DAY, AND ALL OF THEM.
/// Three to six activities a band, so nothing is cut; the date only shuffles
/// them, the same all day and new tomorrow. No tick, no count, no "done": an
/// activity is something to try today. Pure, so a test can hold any day and
/// band.
///
/// By page id, from `kPpPottyActivityTimes`, not by area: the baby's two live
/// in the su-su area so that "Things to do" can stay from one year.
List<PpPage> ppPottyTodayPicks({DateTime? day, String? band}) {
  final b = band ?? kPpPottyBands.active.id;
  final d = day ?? DateTime.now();
  return [
    for (final id in kPpPottyActivityTimes.keys)
      if (kPpPottySection.pageById(id) case final x? when x.inBand(b)) x,
  ]..shuffle(Random(d.year * 10000 + d.month * 100 + d.day));
}

/// A line icon for each activity's card until a painting exists (never an
/// empty frame, D5's rule).
const Map<String, IconData> _kPottyActivityIcons = {
  'cue_at_waking': Icons.wb_twilight_outlined,
  'nappy_off_time': Icons.air_outlined,
  'say_it_as_it_happens': Icons.record_voice_over_outlined,
  'choose_the_potty': Icons.palette_outlined,
  'pants_down_up': Icons.swap_vert_rounded,
  'flush_and_wave': Icons.waving_hand_outlined,
  'after_waking_sit': Icons.wb_sunny_outlined,
  'wash_low_tap': Icons.wash_outlined,
  'big_kid_pants_day': Icons.checkroom_outlined,
  'routine_chart': Icons.draw_outlined,
  'sit_and_read': Icons.menu_book_outlined,
  'teach_the_toy': Icons.toys_outlined,
  'wiping_practice': Icons.clean_hands_outlined,
  'last_wee_before_bed': Icons.bedtime_outlined,
  'spare_clothes_bag': Icons.backpack_outlined,
  'public_toilet_run': Icons.wc_outlined,
};

/// "Try this today": the heading, its line, and his stage's activities.
class PpPottyTodayShelf extends StatelessWidget {
  const PpPottyTodayShelf({super.key, required this.p, required this.onSurface});

  final V2Palette p;
  final void Function(String surfaceId) onSurface;

  @override
  Widget build(BuildContext context) {
    final kid = ChildProfileStore.instance;
    final picks = ppPottyTodayPicks();
    final ts = MediaQuery.textScalerOf(context);
    final height = 104 + ts.scale(118);
    final accent = HSLColor.fromAHSL(1, 174, 0.42, 0.40).toColor();
    return Column(
      key: const ValueKey('pp_potty_today_shelf'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Try this today',
                style: pvFraunces(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.45,
                    color: p.ink1)),
            const SizedBox(height: 2),
            Text('For ${kid.nameMid}, ${kid.ageLabel}  ·  nothing to tick off',
                style: pvManrope(
                    fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink3)),
          ]),
        ),
        const SizedBox(height: kPvDoorHeadingGap),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
            itemCount: picks.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final page = picks[i];
              return _ShelfCard(
                key: ValueKey('pp_potty_today_card_${page.id}'),
                p: p,
                height: height,
                meta: [
                  ?kPpPottyActivityTimes[page.id],
                  'Try today',
                ].join('  ·  ').toUpperCase(),
                title: ppPageTitle(page),
                picture: Container(
                  color: Color.alphaBlend(accent.withValues(alpha: 0.16), p.surface),
                  alignment: Alignment.center,
                  child: Icon(_kPottyActivityIcons[page.id] ?? Icons.spa_outlined,
                      size: 40, color: accent),
                ),
                onTap: () => ppOpenPage(context, kPpPottySection, page,
                    onSurface: (_, id) => onSurface(id)),
              );
            },
          ),
        ),
      ],
    );
  }
}

// =============================================================================
//  Development: "Play with him today" (D2)
// =============================================================================

/// How many cards the shelf holds before "All activities" (D2: six).
const int kPpPlayTodayCount = 6;

/// ⚠️ TODAY'S PICK, AND IT IS TRUE NOW (D2). The tool's blurb promised
/// "Today's pick" for months and nothing picked anything. Six activities for
/// his age (corrected for a baby born early, DV4), shuffled by the date so
/// the shelf is the same all day and new tomorrow, one per area of growing
/// first so the six are not six kinds of tummy time. Pure, so a test can
/// hold it for any day and age.
List<DevActivity> ppPlayTodayPicks({DateTime? day, int? months}) {
  final m = months ?? ChildProfileStore.instance.devAgeInMonths;
  final d = day ?? DateTime.now();
  final pool = [...activitiesForAge(m)]
    ..shuffle(Random(d.year * 10000 + d.month * 100 + d.day));
  final out = <DevActivity>[];
  final areas = <String>{};
  for (final a in pool) {
    if (out.length < kPpPlayTodayCount && areas.add(a.areaId)) out.add(a);
  }
  for (final a in pool) {
    if (out.length < kPpPlayTodayCount && !out.contains(a)) out.add(a);
  }
  return out;
}

/// What an activity builds, in a parent's word (the approved card's
/// "5 MIN · TALKING"), by its area.
String ppActivitySkillWord(String areaId) => switch (areaId) {
      'cognitive' => 'Thinking',
      'language' => 'Talking',
      'gross_motor' => 'Moving',
      'fine_motor' => 'Hands',
      'emotional' => 'Feelings',
      'social' => 'Together',
      'creativity' => 'Imagining',
      'selfcare' => 'Doing it alone',
      _ => 'Play',
    };

/// The card's meta line: "5 MIN · TALKING", or the skill alone for a
/// phase-doc activity, which gives no time (the doc is the source; nothing
/// is invented).
String ppActivityCardMeta(DevActivity a) => [
      if (a.minutes > 0) '${a.minutes} min',
      ppActivitySkillWord(a.areaId),
    ].join('  ·  ').toUpperCase();

/// "Play with him today": the heading, its line, and the shelf of six with
/// "All activities" last.
class PpPlayTodayShelf extends StatelessWidget {
  const PpPlayTodayShelf({super.key, required this.p, required this.onSurface});

  final V2Palette p;
  final void Function(String surfaceId) onSurface;

  @override
  Widget build(BuildContext context) {
    final kid = ChildProfileStore.instance;
    final picks = ppPlayTodayPicks();
    final all = activitiesForAge(kid.devAgeInMonths).length;
    final ts = MediaQuery.textScalerOf(context);
    // The text block grows with the text size, the picture does not.
    final height = 104 + ts.scale(118);
    return Column(
      key: const ValueKey('pp_play_today_shelf'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Play with ${kid.them} today',
                style: pvFraunces(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.45,
                    color: p.ink1)),
            const SizedBox(height: 2),
            Text('Picked for ${kid.nameMid}, ${kid.ageLabel}  ·  a new pick each day',
                style: pvManrope(
                    fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink3)),
          ]),
        ),
        const SizedBox(height: kPvDoorHeadingGap),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
            itemCount: picks.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) => i < picks.length
                ? _ActivityCard(p: p, a: picks[i], height: height)
                : _AllCard(
                    p: p,
                    height: height,
                    line: all == 0
                        ? 'Every idea, by area'
                        : '$all for ${kid.their} age',
                    onTap: () => onSurface('pp_activities'),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.p, required this.a, required this.height});
  final V2Palette p;
  final DevActivity a;
  final double height;

  @override
  Widget build(BuildContext context) {
    final area = devAreaById(a.areaId);
    final painting = ppActivityPainting(a.id);
    final mark = devMarkFor(a.areaId);
    // ⚠️ NEVER AN EMPTY FRAME (D5). Until its painting exists the card shows
    // the area's line mark on the area's tint, as the approved look does.
    final picture = painting != null
        ? Image.asset(painting,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
            errorBuilder: (_, _, _) => const SizedBox.shrink())
        : Container(
            color: Color.alphaBlend(area.accent.withValues(alpha: 0.16), p.surface),
            alignment: Alignment.center,
            child: mark == null
                ? Icon(area.icon, size: 40, color: area.accent)
                : V3DevMark(mark: mark, accent: area.accent, size: 46),
          );
    return _ShelfCard(
      key: ValueKey('pp_play_today_card_${a.id}'),
      p: p,
      height: height,
      meta: ppActivityCardMeta(a),
      title: ppFillChild(a.title),
      picture: picture,
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'pp/development/activity/${a.id}'),
        builder: (_) => ppActivityReader(a),
      )),
    );
  }
}

/// One card of an inline shelf, the approved D2 look: a picture, a meta line
/// ("5 MIN · TALKING"), a title of up to four lines. Shared by Play today and
/// Potty's Try this today, so the two shelves cannot drift apart.
class _ShelfCard extends StatelessWidget {
  const _ShelfCard({
    super.key,
    required this.p,
    required this.height,
    required this.meta,
    required this.title,
    required this.picture,
    required this.onTap,
  });
  final V2Palette p;
  final double height;
  final String meta;
  final String title;
  final Widget picture;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 156,
        height: height,
        child: Material(
          color: p.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: p.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(height: 104, child: picture),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(meta,
                      maxLines: 1,
                      style: pvManrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: p.ink3)),
                  const SizedBox(height: 5),
                  Text(title,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: pvFraunces(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          letterSpacing: -0.3,
                          color: p.ink1)),
                ]),
              ),
            ]),
          ),
        ),
      );
}

class _AllCard extends StatelessWidget {
  const _AllCard({
    required this.p,
    required this.height,
    required this.line,
    required this.onTap,
  });
  final V2Palette p;
  final double height;
  final String line;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 156,
        height: height,
        child: Material(
          key: const ValueKey('pp_play_today_all'),
          color: const Color(0xFFF3F3F4),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('All activities',
                      style: pvManrope(
                          fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)),
                  const SizedBox(height: 6),
                  Text(line,
                      style: pvManrope(fontSize: 12.5, height: 1.35, color: p.ink2)),
                ],
              ),
            ),
          ),
        ),
      );
}
