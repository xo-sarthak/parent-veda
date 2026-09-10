// =============================================================================
//  Track what you're working on — the four habit trackers, in one place
// -----------------------------------------------------------------------------
//  **Where to look:** TTC → Getting ready → Weight and habits →
//  "Track what you're working on".
//
//  ---------------------------------------------------------------------------
//  ⚠️ ONE DESTINATION, NOT ONE TRACKER — AND THAT IS A DEVIATION FROM THE BRIEF
//  ---------------------------------------------------------------------------
//
//  The rebuild asks for "ONE tracker, reuse and consolidate the separate
//  sleep/movement/stress trackers". The intent is right: sending somebody to a
//  Tools hub of eight tiles when she wanted the three she is working on is a
//  door in front of a door.
//
//  What is NOT done is merging the trackers themselves, and the reason is data
//  rather than taste. `TtcLogStore` keys every entry as `tracker/field/day`, so
//  merging three ids into one either strands every row a user has already
//  logged or needs a migration that rewrites her history — on a store whose
//  whole promise is that it records without judging. A shipped store with real
//  entries in it is not a thing to restructure for a layout.
//
//  So this screen is the consolidation, and it is the honest version of it: one
//  place that gathers the four, each still writing where it always wrote.
//  Nothing is lost, nothing is migrated, and the Tools hub keeps every tracker
//  it had. If the trackers should genuinely become one, that is a data decision
//  with a migration attached, and it belongs in `docs/STILL-OPEN.md` rather
//  than inside a door build.
//
//  ---------------------------------------------------------------------------
//  ⚠️ IT SHOWS WHAT SHE HAS LOGGED AND RANKS NONE OF IT
//  ---------------------------------------------------------------------------
//
//  No streaks, no score, no "3 of 4 done today", no green ticks against an
//  empty row. Habit UI reaches for those by reflex and every one of them turns
//  "I did not sleep well" into a failure — on a screen opened by somebody who
//  is already wondering whether her body is the problem.
//
//  What each row carries instead is the count of days she has recorded, which
//  is a fact about her own logging rather than a verdict on her behaviour, and
//  which reads the same whether the number is 2 or 60.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_trackers_data.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';
import 'ttc_tool_chrome.dart';
import 'ttc_tracker_screen.dart';

/// The Getting-ready accent.
const double kTtcHabitsHue = 104;

/// ⚠️ THE FOUR THE BRIEF NAMES, PLUS LIFESTYLE, AND THE FIFTH IS NOT PADDING.
/// The brief lists "sleep, movement, alcohol, tobacco" as the habits worth
/// building. Alcohol and tobacco live in the `lifestyle` tracker, so a screen
/// carrying only sleep/exercise/stress would offer three of the four things the
/// section next to it just told her to work on.
///
/// ⚠️ AND THEY ARE IDS, NOT COPIES. Each one is looked up in `ttcTrackers` at
/// build time, so a tracker's title, its fields and its "why it exists" line
/// are edited in exactly one place. A renamed tracker changes here for free; a
/// deleted one drops out rather than rendering a dead row.
const List<String> kTtcHabitTrackerIds = [
  'sleep',
  'exercise',
  'stress',
  'lifestyle',
];

class TtcHabitsScreen extends StatelessWidget {
  const TtcHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcLogStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final trackers = [
          for (final id in kTtcHabitTrackerIds)
            if (ttcTrackerById(id) != null) ttcTrackerById(id)!,
        ];

        return TtcToolScaffold(
          hue: kTtcHabitsHue,
          eyebrow: 'Getting ready',
          title: "Track what you're\nworking on.",
          intro: 'Whatever you are actually changing. Log the ones you care '
              'about and leave the rest alone — this is a record, not a '
              'report card.',
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 22),
                for (final tracker in trackers) ...[
                  _HabitRow(tracker: tracker, t: t),
                  const SizedBox(height: 11),
                ],
                const SizedBox(height: 14),

                // ⚠️ THE OTHER TRACKERS ARE NAMED, NOT HIDDEN. Somebody who
                // knows the Tools hub has eight of these needs to be told
                // where the other four went, or this screen reads as having
                // lost them. Same rule the Reminders hub follows in parenting.
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 15, color: ttcMuted),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                        'Your cycle, symptoms, weight, mood and his side are '
                        'all still in Tools. These four are here because they '
                        'are the ones this section is about.',
                        style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
                  ),
                ]),
                const SizedBox(height: 26),
              ],
            )),
          ],
        );
      },
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({required this.tracker, required this.t});

  final TtcTracker tracker;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final days = TtcLogStore.instance.daysLogged(tracker.id).length;

    return InkWell(
      borderRadius: BorderRadius.circular(ttcCardRadius),
      onTap: () => openTtcTracker(context, tracker.id),
      child: TtcCard(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tracker.title(hi), style: ttcJakarta(15)),
                  const SizedBox(height: 5),
                  Text(tracker.subtitle(hi),
                      style: ttcBody(13, color: ttcSoft, h: 1.45)),
                  const SizedBox(height: 7),
                  // ⚠️ A COUNT, NEVER A STREAK. "12 days recorded" is a fact
                  // about her logging. "12 day streak" is a thing she can
                  // break, and breaking it is the moment she stops opening the
                  // screen — on the one subject where giving up quietly is the
                  // outcome we are trying to avoid.
                  Text(
                      days == 0
                          ? 'Nothing logged yet'
                          : '$days ${days == 1 ? 'day' : 'days'} recorded',
                      style: ttcBody(11.5,
                          color: ttcMuted, w: FontWeight.w700)),
                ]),
          ),
          const SizedBox(width: 10),
          Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
        ]),
      ),
    );
  }
}
