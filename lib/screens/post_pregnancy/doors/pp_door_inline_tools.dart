// =============================================================================
//  Inline tools on a parenting door (`PpDoorTab.inlineSurfaceId`)
// -----------------------------------------------------------------------------
//  The parenting twin of the pregnancy door's `pvDoorInlineToolFor`: a tool
//  drawn in place as a tab's first block, because a card in front of the
//  thing a tab is for is a door in front of a door. Each one lays out its own
//  gutter (`kPvDoorSelfPaddedTools`'s rule) so its rail runs edge to edge.
//
//  Two so far: Development's Play today shelf (door plan 04, D2, look
//  approved 2026-10-24, `claude.ai/artifact/1bsFmZ4i5SRg8oiQFyeHHR`), and
//  Potty's "Try this today" (door plan 05, PT3), which reuses that look.
//
//  ⚠️ THIS FILE NEVER IMPORTS THE ROUTER, as the door screen doesn't. A tap
//  that leaves the shelf goes through the door's own `onSurface`; an activity
//  opens in the one reader directly, as the Activities screen opens it.
// =============================================================================

import 'dart:math' show Random;

import 'package:flutter/material.dart';

import '../../../data/doors/pp_door_development.dart' show kPpPlayTodayShelf;
import '../../../data/doors/pp_door_potty.dart'
    show kPpPottyDoor, kPpPottyTodayShelf;
import '../../../theme/pv_fonts.dart';
import '../../doors/pv_door_chrome.dart' show kPvDoorGutter;
import '../../doors/pv_door_screen.dart' show kPvDoorHeadingGap;
import '../../v2/v2_palette.dart';
import '../../v2/v3_dev_mark.dart' show V3DevMark, devMarkFor;
import '../pp_activity_paintings.dart' show ppActivityPainting;
import '../pp_activity_read.dart' show ppActivityReader;
import '../pp_child_profile.dart';
import '../pp_content.dart' show PpPage;
import '../pp_development_data.dart';
import '../pp_phases_data.dart' show ppFillChild;
import '../pp_potty_content.dart';
import '../pp_section_screen.dart' show ppOpenPage;

/// The inline tool for [surfaceId], or null when there is none (the tab then
/// opens on its rails, as every other tab does).
Widget? ppDoorInlineToolFor(
  String surfaceId, {
  required V2Palette p,
  required void Function(String surfaceId) onSurface,
}) =>
    switch (surfaceId) {
      kPpPlayTodayShelf => PpPlayTodayShelf(p: p, onSurface: onSurface),
      _ when ppPottyShelfShows(surfaceId) =>
        PpPottyTodayShelf(p: p, onSurface: onSurface),
      _ => null,
    };

/// How many things an inline tool shows, for the tab card's count.
int ppDoorInlineCount(String surfaceId) => switch (surfaceId) {
      kPpPlayTodayShelf => ppPlayTodayPicks().length,
      _ when ppPottyShelfShows(surfaceId) => ppPottyTodayPicks().length,
      _ => 0,
    };

/// ⚠️ THE PAGES AN INLINE TOOL DRAWS, SO THE RAILS DO NOT DRAW THEM AGAIN.
/// Potty's shelf is pages of the tab's own area; the rails skip them the way
/// they skip an age rail's, and an area left empty drops. Empty for a tool
/// that is not pages (Play today's activities are not section pages).
Set<String> ppDoorInlinePageIds(String surfaceId) => ppPottyShelfShows(surfaceId)
    ? {for (final x in ppPottyTodayPicks()) x.id}
    : const {};

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
                title: page.title,
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
