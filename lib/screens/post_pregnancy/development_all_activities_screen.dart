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
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_development_data.dart';
import 'development_common.dart';

class DevelopmentAllActivitiesScreen extends StatelessWidget {
  const DevelopmentAllActivitiesScreen({super.key});

  Widget _pad(Widget c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
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
