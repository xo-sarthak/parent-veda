// =============================================================================
//  DevelopmentAllActivitiesScreen - everything that fits his age
// -----------------------------------------------------------------------------
//  ⚠️ THIS EXISTS BECAUSE THE HOME SHOWS FOUR AND THERE WAS NO FIFTH.
//
//  The development home lists four "try together today" cards and then stops.
//  Feedback: "below 4 activities there should be see all option showing other
//  activities that can be done at this age too."
//
//  The four on the home are a suggestion for today. This is the shelf they came
//  off, and it is the only screen in the section that shows the whole set —
//  which is why it groups by the four ways he is growing rather than listing
//  twenty cards in authored order. A flat list of twenty is a wall; four
//  headed groups of five is a library.
//
//  ⚠️ IT FILTERS BY AGE AND SAYS SO. `activitiesForAge` reads
//  `ChildProfileStore`, so a parent never types anything — derive, never ask.
//  The count in the subtitle is the honest number: if his age has six
//  activities behind it, the screen says six rather than implying a catalogue.
// =============================================================================

import 'package:flutter/material.dart';

import 'development_activity_screen.dart';
import 'pp_activity_paintings.dart' show PpActivityThumb;
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_development_data.dart';
import 'development_common.dart';
import 'pp_activity_read.dart' show ppActivityReader;
import 'pp_phases_data.dart' show ppFillChild;
import 'pp_care_parts.dart' show ppCareSaved;
import '../products/pv_store_chrome.dart' show PvChip;
import 'pp_relevance.dart' show PpSituation, ppRelevanceOrder;
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart' show PvRowGroup, PvListRow;
import '../pregnancy/preg_chrome.dart' show PregSectionHeading;
import '../pregnancy/preg_tool_chrome.dart' show PregToolScaffold, pregToolPad;
import '../ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import '../ttc/ttc_tool_marks.dart' show TtcMarkLeading;
import '../v2/v2_palette.dart';
import '../v2/v3_dev_mark.dart' show V3DevMark, devMarkFor;

class DevelopmentAllActivitiesScreen extends StatelessWidget {
  const DevelopmentAllActivitiesScreen({super.key, this.area});

  /// The area chip to open on (`pp_activities/<areaId>`), so "Talking
  /// activities for this age" lands on talking, not the top of every area.
  final String? area;

  Widget _pad(Widget c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  // ⚠️ ON THE TOOL SHELL SINCE 2026-10-21 (Wave 5b): the shell every tool
  // uses, one row group per area with the area's drawn mark, each row opening
  // the activity in the one reader. Within an area, the relevance brain orders
  // the rows (a finished one sinks; nothing is dropped). The page as it was is
  // [_buildClassic], kept for revert.
  @override
  Widget build(BuildContext context) => _Activities(initialArea: area);

  /// The page before the tools pass (2026-10-25), kept for revert: no area
  /// chips, no "We tried this", birthday age, no redraw on a child switch.
  // ignore: unused_element
  Widget _buildBeforeToolsPass(BuildContext context) {
    final child = ChildProfileStore.instance;
    final months = child.ageInMonths;
    final all = activitiesForAge(months);
    final p = V2PaletteStore.instance.current;
    final situation = PpSituation.now();
    return PregToolScaffold(
      hue: 38,
      eyebrow: 'Development',
      title: 'Things to do together',
      mark: IntentMark.playMark,
      intro: all.isEmpty
          ? 'Nothing is tagged for ${child.their} age yet. The ideas on the home still work.'
          : '${all.length} ${all.length == 1 ? 'idea' : 'ideas'} for ${child.name} now. '
              'None of it is a test, and none of it has to be done.',
      children: [
        for (final area in kDevAreas)
          if (all.any((a) => a.areaId == area.id)) ...[
            pregToolPad(PregSectionHeading(area.name)),
            const SizedBox(height: 4),
            pregToolPad(PvRowGroup(p: p, children: [
              for (final a in ppRelevanceOrder(
                all.where((x) => x.areaId == area.id).toList(),
                situation: situation,
                text: (x) => x.title,
                readId: (x) => 'pp_activity_${x.id}',
              ))
                PvListRow(
                  key: ValueKey('pp_activity_row_${a.id}'),
                  p: p,
                  leading: PpActivityThumb( // the painting once it has one (Wave 8)
                      activityId: a.id,
                      fallback: _AreaMark(areaId: area.id, accent: area.accent, tint: v2BlockTint(38, p))),
                  title: ppFillChild(a.title),
                  line: a.metaLine,
                  trailing: Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    settings: RouteSettings(name: 'pp/development/activity/${a.id}'),
                    builder: (_) => ppActivityReader(a),
                  )),
                ),
            ])),
            const SizedBox(height: 22),
          ],
      ],
    );
  }

  /// The page before Wave 5b, kept for revert.
  // ignore: unused_element
  Widget _buildClassic(BuildContext context) {
    final child = ChildProfileStore.instance;
    final months = child.ageInMonths;
    final all = activitiesForAge(months);

    // Grouped by area, in the order the home shows the four domains, so the
    // two screens read as the same product.
    final areas = kDevAreas;

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 44),
          children: [
            _pad(ppBack(context, 'Back')),
            const SizedBox(height: 22),
            _pad(ppEyebrow('Try together', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text('Everything that fits him now',
                style: ppFraunces(28, h: 1.12))),
            const SizedBox(height: 8),
            _pad(Text(
                all.isEmpty
                    ? 'Nothing is tagged for this age yet. The four on the '
                        'previous screen still work.'
                    : '${all.length} ${all.length == 1 ? 'activity' : 'activities'} '
                        'for a ${months == 1 ? '1 month' : '$months month'} old. '
                        'Nothing here is a test, and none of it has to be done.',
                style: ppBody(13.5, h: 1.55))),
            const SizedBox(height: 24),

            for (final area in areas) ...[
              if (all.any((a) => a.areaId == area.id)) ...[
                _pad(Row(children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: area.accent, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 9),
                  Text(area.name, style: ppJakarta(15)),
                ])),
                const SizedBox(height: 12),
                _pad(Column(children: [
                  for (final a in all.where((x) => x.areaId == area.id))
                    DevActivityCard(
                      activity: a,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          settings: RouteSettings(
                              name: 'pp/development/activity/${a.id}'),
                          builder: (_) =>
                              DevelopmentActivityScreen(activity: a),
                        ),
                      ),
                    ),
                ])),
                const SizedBox(height: 22),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// An area's drawn mark on a neutral disc; the sprout for an area that has no
/// drawn mark yet (creativity, self-care), never a Material glyph.
class _AreaMark extends StatelessWidget {
  const _AreaMark({required this.areaId, required this.accent, required this.tint});
  final String areaId;
  final Color accent;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final mark = devMarkFor(areaId);
    if (mark == null) return TtcMarkLeading(tab: TtcTabMark.sprout, tint: tint, size: 40);
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
      child: V3DevMark(mark: mark, accent: accent, size: 28),
    );
  }
}

// =============================================================================
//  The live page (tools pass, Development, 2026-10-25)
// -----------------------------------------------------------------------------
//  * Area chips, which a link can preselect (Mobbin: foodpanda's "All" chips,
//    mobbin.com/screens/28fee3ea-cf93-47a5-8eaa-5ea289a82822). "All" shows every
//    area as before.
//  * "We tried this" on each row (Saturn's "Mark as done",
//    mobbin.com/screens/c1c6d90c-bcf2-4334-b936-630a87738d1e): per child, with
//    the day, synced (DevStore `c|<childId>|<id>`), with a toast and Undo. A
//    quiet record, never a streak or a count.
//  * Corrected age, and it redraws when the child changes.
// =============================================================================
class _Activities extends StatefulWidget {
  const _Activities({this.initialArea});
  final String? initialArea;

  @override
  State<_Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<_Activities> {
  late String? _area = widget.initialArea;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ChildProfileStore.instance, DevStore.instance]),
      builder: (context, _) {
        final child = ChildProfileStore.instance;
        // Was `child.ageInMonths`: a baby born early got ideas for an older child.
        final all = activitiesForAge(child.devAgeInMonths);
        final p = V2PaletteStore.instance.current;
        final situation = PpSituation.now();
        final areas = [for (final a in kDevAreas) if (all.any((x) => x.areaId == a.id)) a];
        // An area the age has nothing in shows everything rather than nothing.
        final area = areas.any((a) => a.id == _area) ? _area : null;
        return PregToolScaffold(
          hue: 38,
          eyebrow: 'Development',
          title: 'Things to do together',
          mark: IntentMark.playMark,
          intro: all.isEmpty
              ? 'Nothing is tagged for ${child.their} age yet. The ideas on the home still work.'
              : '${all.length} ${all.length == 1 ? 'idea' : 'ideas'} for ${child.name} now. '
                  'None of it is a test, and none of it has to be done.',
          children: [
            if (areas.length > 1) ...[
              SizedBox(
                height: 40,
                child: ListView(
                  key: const ValueKey('pp_activities_chips'),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    for (final (id, label) in [(null, 'All'), for (final a in areas) (a.id, a.name)])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: PvChip(
                          key: ValueKey('pp_activities_chip_${id ?? 'all'}'),
                          label: label,
                          selected: area == id,
                          onTap: () => setState(() => _area = id),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
            for (final a in areas)
              if (area == null || area == a.id) ...[
                pregToolPad(PregSectionHeading(a.name)),
                const SizedBox(height: 4),
                pregToolPad(PvRowGroup(p: p, children: [
                  for (final act in ppRelevanceOrder(
                    all.where((x) => x.areaId == a.id).toList(),
                    situation: situation,
                    text: (x) => x.title,
                    readId: (x) => 'pp_activity_${x.id}',
                  ))
                    PvListRow(
                      key: ValueKey('pp_activity_row_${act.id}'),
                      p: p,
                      leading: PpActivityThumb(
                          activityId: act.id,
                          fallback: _AreaMark(areaId: a.id, accent: a.accent, tint: v2BlockTint(38, p))),
                      title: ppFillChild(act.title),
                      line: act.metaLine,
                      meta: DevStore.instance.triedOn(act.id) == null
                          ? null
                          : 'Tried ${ppActivityTriedWhen(DevStore.instance.triedOn(act.id)!)}',
                      trailing: PpTriedTick(activity: act),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                        settings: RouteSettings(name: 'pp/development/activity/${act.id}'),
                        builder: (_) => ppActivityReader(act),
                      )),
                    ),
                ])),
                const SizedBox(height: 22),
              ],
          ],
        );
      },
    );
  }
}

/// "today", "yesterday" or "on 3 Oct".
String ppActivityTriedWhen(DateTime d) {
  final now = DateTime.now();
  final days = DateTime(now.year, now.month, now.day).difference(DateTime(d.year, d.month, d.day)).inDays;
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return days <= 0 ? 'today' : days == 1 ? 'yesterday' : 'on ${d.day} ${months[d.month - 1]}';
}

/// The "We tried this" tick: a circle that fills when the child on screen has
/// tried it. Tapping says what changed and offers Undo. Also used by the
/// activity's own page.
class PpTriedTick extends StatelessWidget {
  const PpTriedTick({super.key, required this.activity});
  final DevActivity activity;

  @override
  Widget build(BuildContext context) {
    final s = DevStore.instance;
    final p = V2PaletteStore.instance.current;
    final tried = s.isCompleted(activity.id);
    return Semantics(
      button: true,
      checked: tried,
      label: tried ? 'Tried. Tap to undo' : 'We tried this',
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('pp_activity_tried_${activity.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (tried) {
            final was = s.triedOn(activity.id);
            s.untry(activity.id);
            ppCareSaved(context, 'Taken off what you have tried.',
                undo: () => s.markTried(activity.id, on: was));
          } else {
            s.markTried(activity.id);
            ppCareSaved(context, 'Saved: you tried ${ppFillChild(activity.title)} today.',
                undo: () => s.untry(activity.id));
          }
        },
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tried ? p.ink1 : p.surface,
                border: Border.all(color: tried ? p.ink1 : p.ink3, width: 1.5),
              ),
              child: tried ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
            ),
          ),
        ),
      ),
    );
  }
}
