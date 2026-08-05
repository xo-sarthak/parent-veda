// =============================================================================
//  Grow — V3. The reframe, without the rewrite.
// -----------------------------------------------------------------------------
//  WHAT IT TAKES FROM THE BRIEF, because the brief is right about these:
//
//    * one question, one answer, today. The current home is a good companion
//      page and a bad daily habit — five stacked sections, and a parent has to
//      choose. Choosing is the work we are supposed to be doing for her.
//    * capabilities over academic domains. "Gross motor / fine motor" is a
//      textbook's vocabulary; "Move" is a parent's.
//    * activities are the exercise, not the product.
//
//  WHAT IT DECLINES, and why each one:
//
//    1. THE BREAKABLE STREAK. A counter that resets to zero, next to the words
//       "your child's brain", punishes the parent who had a hard fortnight. The
//       same daily pull is available without it: a week that FILLS. Seven slots,
//       a missed day costs one, and nothing is ever taken away. The habit
//       research this borrows from is about consistency, not about loss — the
//       loss part is what makes a streak feel bad, and it is optional.
//
//    2. DELETING THE MAP AND THE CHECK-IN. Both are built, shipped and carry
//       real state. The brief is right that they do not belong ON the home; it
//       does not follow that they should not exist. They move one tap down.
//
//    3. LEAVING SELF-CARE HOMELESS. The brief lists five capabilities; the
//       library has eight areas; self-care maps to none of the five. It is not
//       "Move" and calling it "Connect" is worse. V3 adds a sixth, "Do", so
//       nothing in the library is unreachable.
//
//  V1 IS UNTOUCHED. Nothing here edits or removes DevelopmentHomeScreen,
//  DevelopmentMapScreen, DevelopmentAreaScreen, DevelopmentCheckinScreen or
//  kDevActivities — they are reused as they stand.
// =============================================================================

import 'package:flutter/material.dart';

import '../../widgets/global_ask_fab.dart' show kAskFabReserve;

import 'development_area_screen.dart';
import 'development_checkin_screen.dart';
import 'development_map_screen.dart';
import 'grow_v2_screens.dart' show GrowActivityScreen;
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_development_data.dart';
import 'pp_grow_data.dart';

void _push(BuildContext c, Widget s) =>
    Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

Widget _pad(Widget c) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

// =============================================================================
//  Home
// =============================================================================

class GrowV3Home extends StatelessWidget {
  const GrowV3Home({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GrowStore.instance,
      builder: (context, _) {
        final store = GrowStore.instance;
        final today = growToday();
        final child = ChildProfileStore.instance;
        final done = store.isCompletedToday(today.id);

        return Scaffold(
          backgroundColor: ppBg,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.only(top: 12, bottom: kAskFabReserve),
              children: [
                _pad(Row(children: [
                  Expanded(child: ppBack(context, 'Explore')),
                  const SizedBox(width: 128),
                ])),
                const SizedBox(height: 18),
                _pad(ppEyebrow('Grow', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('One thing, today', style: ppFraunces(31, h: 1.05))),
                const SizedBox(height: 8),
                _pad(Text(
                    'You do not have to decide what to do with ${child.them} '
                    'today. This is the one worth doing.',
                    style: ppBody(14, h: 1.55))),

                const SizedBox(height: 22),
                _pad(_hero(context, today, done)),

                // ---- the week, filling ---------------------------------------
                const SizedBox(height: 22),
                _pad(_week(store)),

                // ---- capabilities (six) --------------------------------------
                const SizedBox(height: 30),
                _pad(Text('What you are building', style: ppJakarta(17))),
                const SizedBox(height: 4),
                _pad(Text(
                    'Activities are the exercise. These are the point.',
                    style: ppBody(12.5, color: ppMuted))),
                const SizedBox(height: 14),
                SizedBox(
                  height: 118,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: kGrowCapabilities.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) =>
                        _capTile(context, kGrowCapabilities[i]),
                  ),
                ),

                // ---- kept, one tap down --------------------------------------
                const SizedBox(height: 30),
                _pad(Text('When you want the wider view', style: ppJakarta(17))),
                const SizedBox(height: 4),
                _pad(Text(
                    'Not on this screen every day — but never gone.',
                    style: ppBody(12.5, color: ppMuted))),
                const SizedBox(height: 14),
                _pad(_row(
                  context,
                  Icons.map_outlined,
                  'The development map',
                  'Birth to five, and where ${child.they} is on it.',
                  const DevelopmentMapScreen(),
                )),
                const SizedBox(height: 10),
                _pad(_row(
                  context,
                  Icons.checklist_rounded,
                  'A gentle check-in',
                  'A few questions, no score at the end.',
                  const DevelopmentCheckinScreen(),
                )),

                // ---- recently ------------------------------------------------
                const SizedBox(height: 30),
                _pad(Text('Already done together', style: ppJakarta(17))),
                const SizedBox(height: 12),
                if (store.recentlyCompleted().isEmpty)
                  _pad(_empty())
                else
                  ...store.recentlyCompleted().map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _pad(_mini(context, a)),
                      )),
                const SizedBox(height: 34),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _hero(BuildContext context, DevActivity a, bool done) {
    final caps = capabilitiesOf(a);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ppBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(a.title, style: ppFraunces(24, h: 1.12)),
        const SizedBox(height: 10),
        Row(children: [
          _meta(Icons.schedule_rounded, '${a.minutes} min'),
          const SizedBox(width: 14),
          _meta(Icons.child_care_outlined, a.ageTag),
        ]),
        const SizedBox(height: 15),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final c in caps) GrowCapabilityChip(cap: c)],
        ),
        const SizedBox(height: 16),
        Container(height: 1, color: ppHair),
        const SizedBox(height: 14),
        Text(growWhyToday(a), style: ppBody(13, h: 1.55)),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () => _push(context, GrowActivityScreen(activity: a)),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? ppPanel : ppPurple,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(done ? 'Done today — open it again' : 'Start',
                style: ppBody(13.5,
                    color: done ? ppSoft : Colors.white, w: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }

  Widget _meta(IconData i, String s) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(i, size: 13, color: ppMuted),
        const SizedBox(width: 5),
        Text(s, style: ppBody(11.5, color: ppSoft)),
      ]);

  /// The week that fills. Seven slots, nothing ever taken away.
  Widget _week(GrowStore store) {
    const names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final pattern = store.weekPattern;
    final today = DateTime.now();
    // weekPattern is oldest-first ending today, so label backwards from today.
    final labels = [
      for (var i = 6; i >= 0; i--)
        names[(today.subtract(Duration(days: i)).weekday - 1) % 7]
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ppBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('${store.daysThisWeek} of the last 7 days',
              style: ppJakarta(14.5)),
          const Spacer(),
          Text('no streak to lose', style: ppBody(11, color: ppMuted)),
        ]),
        const SizedBox(height: 13),
        Row(children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Column(children: [
                Container(
                  height: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: pattern[i] ? ppPurple : ppPanel,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: pattern[i]
                      ? const Icon(Icons.check_rounded,
                          size: 15, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 6),
                Text(labels[i], style: ppBody(10.5, color: ppMuted)),
              ]),
            ),
        ]),
      ]),
    );
  }

  Widget _capTile(BuildContext context, GrowCapability c) => GestureDetector(
        onTap: () => _push(context, GrowV3CapabilityScreen(cap: c)),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 122,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ppBorder),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(c.icon, size: 18, color: c.accent),
            ),
            const Spacer(),
            Text(c.label, style: ppJakarta(14)),
            const SizedBox(height: 3),
            Text('${c.activities.length} activities',
                style: ppBody(11, color: ppMuted)),
          ]),
        ),
      );

  Widget _row(BuildContext context, IconData icon, String title, String sub,
          Widget dest) =>
      GestureDetector(
        onTap: () => _push(context, dest),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: ppBorder),
          ),
          child: Row(children: [
            Icon(icon, size: 19, color: ppPurple),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: ppJakarta(13.5)),
                const SizedBox(height: 3),
                Text(sub, style: ppBody(11.5, color: ppMuted)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );

  Widget _empty() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ppPanel,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
            'Nothing here yet — and that is a fine place to start. '
            'Whatever you do together will show up here.',
            style: ppBody(12.5, h: 1.5)),
      );

  Widget _mini(BuildContext context, DevActivity a) => GestureDetector(
        onTap: () => _push(context, GrowActivityScreen(activity: a)),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: ppHair),
          ),
          child: Row(children: [
            const Icon(Icons.check_circle_outline_rounded,
                size: 17, color: ppAccentGreen),
            const SizedBox(width: 11),
            Expanded(child: Text(a.title, style: ppJakarta(13))),
            Text('${a.minutes} min', style: ppBody(11.5, color: ppMuted)),
          ]),
        ),
      );
}

// =============================================================================
//  Capability detail
// -----------------------------------------------------------------------------
//  Differs from V2's in one way that matters: it links DOWN into the eight
//  development areas it covers. The capability is the parent-facing name; the
//  area journey underneath it is the thing that was already built, and it stays
//  reachable rather than being replaced by a nicer word.
// =============================================================================

class GrowV3CapabilityScreen extends StatelessWidget {
  const GrowV3CapabilityScreen({super.key, required this.cap});
  final GrowCapability cap;

  @override
  Widget build(BuildContext context) {
    final acts = cap.activities;
    final months = ChildProfileStore.instance.ageInMonths;
    final now = acts.where((a) => growSuitsAge(a, months)).toList();
    final later = acts.where((a) => !now.contains(a)).toList();

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(top: 12, bottom: kAskFabReserve),
          children: [
            _pad(ppBack(context, 'Grow')),
            const SizedBox(height: 20),
            _pad(Row(children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cap.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(cap.icon, size: 23, color: cap.accent),
              ),
              const SizedBox(width: 13),
              Expanded(child: Text(cap.label, style: ppFraunces(28, h: 1.05))),
            ])),
            const SizedBox(height: 12),
            _pad(Text(cap.promise, style: ppBody(14, h: 1.55))),
            const SizedBox(height: 16),
            _pad(Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final a in cap.abilities)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: cap.accent.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(a,
                        style: ppBody(11.5, color: cap.accent, w: FontWeight.w700)),
                  ),
              ],
            )),

            const SizedBox(height: 28),
            _pad(Text('Right now', style: ppJakarta(17))),
            const SizedBox(height: 12),
            if (now.isEmpty)
              _pad(Text(
                  'Nothing in this capability suits this age yet — the ones '
                  'below are what comes next.',
                  style: ppBody(13, h: 1.5)))
            else
              ...now.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _pad(_actRow(context, a)),
                  )),

            if (later.isNotEmpty) ...[
              const SizedBox(height: 20),
              _pad(Text('Before and after', style: ppJakarta(16))),
              const SizedBox(height: 12),
              ...later.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _pad(_actRow(context, a)),
                  )),
            ],

            // The link the brief would have removed. The area journey is where
            // the stage-by-stage detail lives, and it already existed.
            const SizedBox(height: 26),
            _pad(Text('Go deeper', style: ppJakarta(16))),
            const SizedBox(height: 4),
            _pad(Text(
                '${cap.label} covers '
                '${cap.areaIds.length == 1 ? 'one area' : '${cap.areaIds.length} areas'} '
                'of development. Each has its own journey.',
                style: ppBody(12, color: ppMuted))),
            const SizedBox(height: 12),
            for (final id in cap.areaIds)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _pad(_areaRow(context, devAreaById(id))),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _actRow(BuildContext context, DevActivity a) => GestureDetector(
        onTap: () => _push(context, GrowActivityScreen(activity: a)),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ppBorder),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.title, style: ppJakarta(13.5)),
                const SizedBox(height: 4),
                Text('${a.minutes} min · ${a.ageTag}',
                    style: ppBody(11.5, color: ppMuted)),
              ]),
            ),
            if (GrowStore.instance.isCompletedToday(a.id))
              const Icon(Icons.check_circle_rounded,
                  size: 17, color: ppAccentGreen)
            else
              const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );

  Widget _areaRow(BuildContext context, DevArea area) => GestureDetector(
        onTap: () => _push(context, DevelopmentAreaScreen(area: area)),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
            color: ppPanel,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Icon(area.icon, size: 18, color: area.accent),
            const SizedBox(width: 12),
            Expanded(child: Text(area.name, style: ppJakarta(13))),
            const Icon(Icons.chevron_right_rounded, size: 19, color: ppMuted),
          ]),
        ),
      );
}
