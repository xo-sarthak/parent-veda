// =============================================================================
//  Grow — V2. The redesign brief, built as written.
// -----------------------------------------------------------------------------
//  This is the brief's four screens, in its order, with its language, INCLUDING
//  the three things this codebase would normally push back on:
//
//    * a breakable streak, and "🔥 14 Day Streak" in the header
//    * a celebration screen after every activity
//    * the Development Map, the check-in and the eight areas gone from the home
//
//  Filing those edges off would produce a V2 that is really V3 wearing the
//  brief's title, and then the comparison decides nothing. So they are here.
//  The arguments against them live in V3 and in pp_grow_data.dart, where they
//  can be read next to what they are arguing with.
//
//  TWO DEPARTURES, both mechanical rather than editorial:
//
//    1. Line icons instead of the brief's 🧠 💬 🤸 ❤ 🎨. The no-decorative-emoji
//       rule is app-wide chrome policy, not a view about this feature, and
//       emoji in one section header would look broken beside every other screen.
//    2. "Watch demo (30 sec)" renders and then says plainly that no demo is
//       recorded yet. The brief lists it as optional; pretending a video exists
//       would be worse than the empty state.
//
//  NOTHING HERE REPLACES ANYTHING. V1 is untouched, the Map and check-in still
//  exist and are still reachable in V1 and V3 — they are absent from THIS
//  home, which is what the brief asked for.
// =============================================================================

import 'package:flutter/material.dart';

import '../../widgets/global_ask_fab.dart' show kAskFabReserve;

import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_development_data.dart';
import 'pp_grow_data.dart';

void _push(BuildContext c, Widget s) =>
    Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

Widget _pad(Widget c) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

// =============================================================================
//  "How the streak works" — the (i)
// -----------------------------------------------------------------------------
//  THE RULE THIS SHEET EXISTS TO STATE OUT LOUD: a missed day sets it back to
//  zero. That is the whole mechanism, and it is the only part a parent cannot
//  see until it has already happened to her.
//
//  Written plainly rather than softened. "Don't worry if you miss a day!" would
//  be a lie sitting directly above a counter that does not agree — and a
//  cheerful explanation of a punishing rule reads worse than the rule alone.
//  The last line does the only honest reassurance available: the days you did
//  are still recorded, and the number is not a measure of the child.
// =============================================================================

void showStreakInfo(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: ppBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
              color: ppBorder, borderRadius: BorderRadius.circular(999)),
        ),
        const SizedBox(height: 22),
        Row(children: [
          const Icon(Icons.local_fire_department_outlined,
              size: 20, color: ppAccentAmber),
          const SizedBox(width: 10),
          Text('How the streak works', style: ppJakarta(17)),
        ]),
        const SizedBox(height: 18),
        _infoLine('One activity a day keeps it going.',
            'Any activity counts. A three-minute one counts the same as a '
                'twelve-minute one.'),
        _infoLine('It counts days, not activities.',
            'Doing three in one day still adds one to the streak.'),
        _infoLine('A missed day sets it back to zero.',
            'This is the part worth knowing before it happens. The number '
                'starts again from one the next time you do something.'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: ppPanel,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
              'The days you did are still recorded either way — you can see '
              'them under "Completed recently". The streak is a nudge to come '
              'back, and nothing more than that. It is not a measure of your '
              'child, and it is not a measure of you.',
              style: ppBody(12.5, h: 1.6)),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => Navigator.of(ctx).pop(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ppPurple,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('Got it',
                style: ppBody(13.5, color: Colors.white, w: FontWeight.w800)),
          ),
        ),
      ]),
    ),
  );
}

Widget _infoLine(String title, String body) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration:
              const BoxDecoration(color: ppPurple, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: ppJakarta(13.5)),
            const SizedBox(height: 4),
            Text(body, style: ppBody(12.5, h: 1.55)),
          ]),
        ),
      ]),
    );

// =============================================================================
//  SCREEN 1 — Grow home
// =============================================================================

class GrowV2Home extends StatelessWidget {
  const GrowV2Home({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GrowStore.instance,
      builder: (context, _) {
        final store = GrowStore.instance;
        final today = growToday();
        final child = ChildProfileStore.instance;
        return Scaffold(
          backgroundColor: ppBg,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.only(top: 12, bottom: kAskFabReserve),
              children: [
                _pad(Row(children: [
                  Expanded(child: ppBack(context, 'Explore')),
                  // Room for the version pill, which the wrapper floats here.
                  const SizedBox(width: 128),
                ])),
                const SizedBox(height: 14),
                _pad(_streakBar(context, store)),
                const SizedBox(height: 18),
                _pad(Text('Grow', style: ppFraunces(32, h: 1.05))),
                const SizedBox(height: 8),
                _pad(Text(
                    "Build ${child.their} brain, one activity at a time.",
                    style: ppBody(14, h: 1.55))),

                // ---- today's brain builder ----------------------------------
                const SizedBox(height: 22),
                _pad(_heroCard(context, today)),

                // ---- capabilities -------------------------------------------
                const SizedBox(height: 30),
                _pad(Text('Capabilities', style: ppJakarta(17))),
                const SizedBox(height: 4),
                _pad(Text('Every activity strengthens one or more.',
                    style: ppBody(12.5, color: ppMuted))),
                const SizedBox(height: 14),
                SizedBox(
                  height: 118,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: kDocCapabilities.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) =>
                        _capTile(context, kDocCapabilities[i]),
                  ),
                ),

                const SizedBox(height: 26),
                _pad(_moreActivities(context)),

                // ---- completed / saved --------------------------------------
                const SizedBox(height: 30),
                _pad(Text('Completed recently', style: ppJakarta(17))),
                const SizedBox(height: 12),
                if (store.recentlyCompleted().isEmpty)
                  _pad(_emptyRecent())
                else
                  ...store.recentlyCompleted().map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _pad(_miniRow(context, a)),
                      )),
                const SizedBox(height: 34),
              ],
            ),
          ),
        );
      },
    );
  }

  // The brief's "🔥 14 Day Streak". A flame glyph would break the emoji rule,
  // so it is a line icon carrying the same meaning.
  //
  // HOW THE BRIEF'S TWO INSTRUCTIONS WERE READ, since they pull against each
  // other and the reading is a decision:
  //
  //     "Include ● Daily streaks ● Progress animations ● Activity completion
  //      celebration ● Gentle encouragement"
  //     "Avoid gamification that feels childish."
  //
  // The guardrail names a KIND of gamification, not gamification itself, and
  // what it points at is childishness — badges, confetti, cartoon mascots,
  // points, levels. So it is read as scoped to those, and the explicit
  // include-list two lines above it stands. When a document's general line
  // fights its specific line, the specific one wins; the general line is
  // usually the one written first and least thought about.
  //
  // So V2 keeps the streak, keeps the celebration, keeps a progress animation
  // — and carries no badge, no confetti and no mascot anywhere.
  //
  // The (i) is the one addition the brief did not ask for. A number that can
  // reset to zero should say so BEFORE it does it, not after: a parent who
  // learns the rule by losing fourteen days learns it the expensive way.
  Widget _streakBar(BuildContext context, GrowStore store) {
    final n = store.streakDays;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFF0D9BE)),
      ),
      child: Row(children: [
        const Icon(Icons.local_fire_department_outlined,
            size: 18, color: ppAccentAmber),
        const SizedBox(width: 9),
        Text(n == 0 ? 'No streak yet' : '$n day streak',
            style: ppJakarta(13.5, color: const Color(0xFF8A4A12))),
        const Spacer(),
        Text(n == 0 ? 'Start today' : 'Keep it going',
            style: ppBody(11.5, color: const Color(0xFFA1743F))),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => showStreakInfo(context),
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Icon(Icons.info_outline_rounded,
                size: 16, color: Color(0xFFA1743F)),
          ),
        ),
      ]),
    );
  }

  Widget _heroCard(BuildContext context, DevActivity a) {
    final caps = capabilitiesOf(a, from: kDocCapabilities);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ppBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.star_rounded, size: 15, color: ppAccentAmber),
          const SizedBox(width: 6),
          Text("TODAY'S BRAIN BUILDER",
              style: ppBody(10.5, color: ppSoft, w: FontWeight.w800)),
        ]),
        const SizedBox(height: 12),
        Text(a.title, style: ppFraunces(24, h: 1.12)),
        const SizedBox(height: 10),
        Row(children: [
          _meta(Icons.schedule_rounded, '${a.minutes} min'),
          const SizedBox(width: 14),
          _meta(Icons.child_care_outlined, a.ageTag),
          const SizedBox(width: 14),
          _meta(Icons.trending_up_rounded, a.difficulty),
        ]),
        const SizedBox(height: 16),
        Text('Supports', style: ppBody(11.5, color: ppMuted, w: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final c in caps) GrowCapabilityChip(cap: c)],
        ),
        const SizedBox(height: 16),
        Container(height: 1, color: ppHair),
        const SizedBox(height: 14),
        Text('Why today?', style: ppJakarta(13)),
        const SizedBox(height: 6),
        Text(growWhyToday(a), style: ppBody(13, h: 1.55)),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () => _push(context, GrowActivityScreen(activity: a)),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ppPurple,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('START ACTIVITY',
                style: ppBody(13.5, color: Colors.white, w: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }

  Widget _meta(IconData i, String s) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(i, size: 13, color: ppMuted),
        const SizedBox(width: 5),
        Text(s, style: ppBody(11.5, color: ppSoft)),
      ]);

  Widget _capTile(BuildContext context, GrowCapability c) => GestureDetector(
        onTap: () => _push(context, GrowCapabilityScreen(cap: c)),
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

  Widget _moreActivities(BuildContext context) => GestureDetector(
        onTap: () => _push(context, const GrowAllActivitiesScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: ppPanel,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Text('More activities', style: ppJakarta(14)),
            const Spacer(),
            const Icon(Icons.arrow_forward_rounded, size: 17, color: ppPurple),
          ]),
        ),
      );

  // A feature is never hidden: the empty state invites rather than vanishing.
  Widget _emptyRecent() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ppPanel,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
            'Nothing yet. Finish today’s activity and it will show up here, '
            'so you can see what you have already done together.',
            style: ppBody(12.5, h: 1.5)),
      );

  Widget _miniRow(BuildContext context, DevActivity a) => GestureDetector(
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
//  SCREEN 2 — Capability detail
// =============================================================================

class GrowCapabilityScreen extends StatelessWidget {
  const GrowCapabilityScreen({super.key, required this.cap});
  final GrowCapability cap;

  @override
  Widget build(BuildContext context) {
    final acts = cap.activities;
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
            const SizedBox(height: 14),
            _pad(Text(
                "Strengthen ${ChildProfileStore.instance.their} ability to",
                style: ppBody(12.5, color: ppMuted, w: FontWeight.w700))),
            const SizedBox(height: 10),
            _pad(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final a in cap.abilities)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        margin: const EdgeInsets.only(top: 7),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                            color: cap.accent, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(a, style: ppBody(13.5, h: 1.5))),
                    ]),
                  ),
              ],
            )),
            const SizedBox(height: 26),
            _pad(Text('Activities', style: ppJakarta(17))),
            const SizedBox(height: 12),
            if (acts.isEmpty)
              _pad(Text(
                  'No activities are tagged to this capability yet.',
                  style: ppBody(13, h: 1.5)))
            else
              ...acts.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _pad(_row(context, a)),
                  )),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, DevActivity a) => GestureDetector(
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
                Text('${a.minutes} min · ${a.ageTag} · ${a.difficulty}',
                    style: ppBody(11.5, color: ppMuted)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );
}

// =============================================================================
//  The full list, behind "More activities"
// =============================================================================

class GrowAllActivitiesScreen extends StatelessWidget {
  const GrowAllActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final months = ChildProfileStore.instance.ageInMonths;
    final forAge = growActivitiesForAge(months);
    final rest =
        kGrowActivities.where((a) => !forAge.contains(a)).toList();
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(top: 12, bottom: kAskFabReserve),
          children: [
            _pad(ppBack(context, 'Grow')),
            const SizedBox(height: 20),
            _pad(Text('All activities', style: ppFraunces(28, h: 1.05))),
            const SizedBox(height: 8),
            _pad(Text(
                '${kGrowActivities.length} in the library. '
                '${forAge.length} suit ${ChildProfileStore.instance.their} '
                'age right now.',
                style: ppBody(13, h: 1.55))),
            const SizedBox(height: 22),
            _pad(Text('For this stage', style: ppJakarta(16))),
            const SizedBox(height: 12),
            ...forAge.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _pad(_row(context, a)),
                )),
            if (rest.isNotEmpty) ...[
              const SizedBox(height: 20),
              _pad(Text('Earlier and later', style: ppJakarta(16))),
              const SizedBox(height: 4),
              _pad(Text(
                  'Kept visible on purpose — children arrive at things in '
                  'their own order.',
                  style: ppBody(12, color: ppMuted))),
              const SizedBox(height: 12),
              ...rest.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _pad(_row(context, a)),
                  )),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, DevActivity a) => GestureDetector(
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
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );
}

// =============================================================================
//  SCREEN 3 — Activity detail
// -----------------------------------------------------------------------------
//  Shared by V2 and V3. The two versions genuinely agree about this screen —
//  they disagree about what happens AFTER the Complete button, which is why
//  the completion screen takes the version and this does not.
//
//  DevelopmentActivityScreen (V1's) is left completely alone and is still what
//  My Child, Recommendations and the phase pages open.
// =============================================================================

class GrowActivityScreen extends StatefulWidget {
  const GrowActivityScreen({super.key, required this.activity});
  final DevActivity activity;

  @override
  State<GrowActivityScreen> createState() => _GrowActivityScreenState();
}

class _GrowActivityScreenState extends State<GrowActivityScreen> {
  bool _whyOpen = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;
    final version = GrowVersionStore.instance.version;
    final caps = capabilitiesOf(a, from: capabilitiesFor(version));
    final done = GrowStore.instance.isCompletedToday(a.id);

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(top: 12, bottom: kAskFabReserve),
          children: [
            _pad(ppBack(context, 'Grow')),
            const SizedBox(height: 18),
            _pad(Text(a.title, style: ppFraunces(28, h: 1.08))),
            const SizedBox(height: 12),
            _pad(Row(children: [
              _pill('${a.minutes} minutes'),
              const SizedBox(width: 8),
              _pill(a.difficulty),
              const SizedBox(width: 8),
              _pill(a.ageTag),
            ])),

            const SizedBox(height: 22),
            _pad(Text("Today you'll strengthen", style: ppJakarta(15))),
            const SizedBox(height: 10),
            _pad(Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final c in caps) GrowCapabilityChip(cap: c)],
            )),
            if (caps.isEmpty)
              _pad(Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                    'This activity is not covered by any capability in this '
                    'version — see V3.',
                    style: ppBody(12, color: ppMuted)),
              )),

            const SizedBox(height: 22),
            _pad(_demoRow(context)),

            const SizedBox(height: 24),
            _pad(Text('Things needed', style: ppJakarta(15))),
            const SizedBox(height: 9),
            ...a.materials.map((m) => _pad(_bullet(m))),

            const SizedBox(height: 24),
            _pad(Text('Steps', style: ppJakarta(15))),
            const SizedBox(height: 11),
            for (var i = 0; i < a.steps.length; i++)
              _pad(_step(i + 1, a.steps[i])),

            const SizedBox(height: 22),
            _pad(_safety(a)),

            const SizedBox(height: 22),
            _pad(_why(a)),

            const SizedBox(height: 26),
            _pad(_completeButton(context, a, done)),
            const SizedBox(height: 34),
          ],
        ),
      ),
    );
  }

  Widget _pill(String s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: ppPanel,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(s, style: ppBody(11.5, color: ppSoft, w: FontWeight.w700)),
      );

  // The brief lists a 30-second demo as optional. None are recorded, and
  // rendering a play button that does nothing would be the worse of the two
  // honest options.
  Widget _demoRow(BuildContext context) => GestureDetector(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No demo filmed for this one yet.')),
        ),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
            color: ppPanel,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            const Icon(Icons.play_circle_outline, size: 19, color: ppMuted),
            const SizedBox(width: 11),
            Expanded(
                child: Text('Watch demo (30 sec)',
                    style: ppJakarta(13, color: ppSoft))),
            Text('Not filmed yet', style: ppBody(11, color: ppMuted)),
          ]),
        ),
      );

  Widget _bullet(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 5,
            height: 5,
            decoration: const BoxDecoration(color: ppMuted, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(s, style: ppBody(13.5, h: 1.5))),
        ]),
      );

  Widget _step(int n, String s) => Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ppPurple.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$n',
                style: ppBody(11.5, color: ppPurple, w: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(s, style: ppBody(13.5, h: 1.55))),
        ]),
      );

  Widget _safety(DevActivity a) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: ppCoralTint,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ppCoral.withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.shield_outlined, size: 16, color: ppCoral),
            const SizedBox(width: 8),
            Text('Keep it safe', style: ppJakarta(13)),
          ]),
          const SizedBox(height: 10),
          for (final s in a.safety)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('· $s', style: ppBody(12.5, h: 1.5)),
            ),
        ]),
      );

  Widget _why(DevActivity a) => GestureDetector(
        onTap: () => setState(() => _whyOpen = !_whyOpen),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ppBorder),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('Why this works', style: ppJakarta(14))),
              Icon(_whyOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 20, color: ppMuted),
            ]),
            if (_whyOpen) ...[
              const SizedBox(height: 11),
              Text(a.benefit, style: ppBody(13.5, h: 1.6)),
              if (a.skills.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final s in a.skills)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: ppPanel,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(s, style: ppBody(11, color: ppSoft)),
                      ),
                  ],
                ),
              ],
            ],
          ]),
        ),
      );

  Widget _completeButton(BuildContext context, DevActivity a, bool done) =>
      GestureDetector(
        onTap: done
            ? null
            : () async {
                await GrowStore.instance.complete(a.id);
                if (!context.mounted) return;
                Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
                    builder: (_) => GrowCompletedScreen(activity: a)));
              },
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done ? ppPanel : ppPurple,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(done ? 'Done today' : 'Complete activity',
              style: ppBody(14,
                  color: done ? ppSoft : Colors.white, w: FontWeight.w800)),
        ),
      );
}

// =============================================================================
//  SCREEN 4 — Activity completed
// -----------------------------------------------------------------------------
//  THE ONE SCREEN WHERE V2 AND V3 REALLY PART.
//
//    V2  "Great job", the streak count, tomorrow's activity named.
//    V3  a quieter acknowledgement, the week as a filling ribbon, and no
//        number that can go back to zero.
//
//  Same data underneath. Only the reading of it changes.
// =============================================================================

class GrowCompletedScreen extends StatelessWidget {
  const GrowCompletedScreen({super.key, required this.activity});
  final DevActivity activity;

  @override
  Widget build(BuildContext context) {
    final v = GrowVersionStore.instance.version;
    final store = GrowStore.instance;
    final caps = capabilitiesOf(activity, from: capabilitiesFor(v));
    final tomorrow = growTomorrow();
    final isV2 = v == GrowVersion.v2;

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: ppBack(context, 'Grow'),
            ),
            const SizedBox(height: 40),
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ppAccentGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.check_rounded,
                  size: 34, color: ppAccentGreen),
            ),
            const SizedBox(height: 22),
            Text(isV2 ? 'Great job' : "That's done",
                style: ppFraunces(30, h: 1.05)),
            const SizedBox(height: 8),
            Text(
                isV2
                    ? "Today's brain builder complete."
                    : 'You did ${activity.title.toLowerCase()} together. '
                        'That is the whole of it.',
                style: ppBody(14, h: 1.55)),

            const SizedBox(height: 28),
            Text('You strengthened',
                style: ppBody(11.5, color: ppMuted, w: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final c in caps) GrowCapabilityChip(cap: c)],
            ),

            const SizedBox(height: 30),
            if (isV2) _streakBlock(context, store) else _weekBlock(store),

            const SizedBox(height: 24),
            _tomorrow(context, tomorrow, isV2),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // The brief's "progress animation", done as the number counting up to its
  // new value. Deliberately NOT confetti or a badge — those are the childish
  // devices its own guardrail rules out, and this satisfies the instruction
  // without them.
  Widget _streakBlock(BuildContext context, GrowStore store) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4E8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0D9BE)),
        ),
        child: Row(children: [
          const Icon(Icons.local_fire_department_outlined,
              size: 26, color: ppAccentAmber),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Current streak',
                  style: ppBody(11.5, color: const Color(0xFFA1743F))),
              const SizedBox(height: 3),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: store.streakDays.toDouble()),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                builder: (_, value, _) => Text(
                  '${value.round()} ${store.streakDays == 1 ? 'day' : 'days'}',
                  style: ppFraunces(22, color: const Color(0xFF8A4A12)),
                ),
              ),
            ]),
          ),
          GestureDetector(
            onTap: () => showStreakInfo(context),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.info_outline_rounded,
                  size: 17, color: Color(0xFFA1743F)),
            ),
          ),
        ]),
      );

  Widget _weekBlock(GrowStore store) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${store.daysThisWeek} of the last 7 days',
              style: ppJakarta(15)),
          const SizedBox(height: 4),
          Text('No streak to break. A quiet week costs you nothing.',
              style: ppBody(12, color: ppMuted)),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final on in store.weekPattern)
                Expanded(
                  child: Container(
                    height: 8,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      color: on ? ppPurple : ppPanel,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
            ],
          ),
        ]),
      );

  Widget _tomorrow(BuildContext context, DevActivity a, bool isV2) =>
      GestureDetector(
        onTap: () => _push(context, GrowActivityScreen(activity: a)),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ppPanel,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isV2 ? 'Next brain builder' : 'Ready for tomorrow',
                    style: ppBody(11.5, color: ppMuted, w: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(a.title, style: ppJakarta(14.5)),
                const SizedBox(height: 3),
                Text('Tomorrow · ${a.minutes} min',
                    style: ppBody(11.5, color: ppSoft)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );
}
