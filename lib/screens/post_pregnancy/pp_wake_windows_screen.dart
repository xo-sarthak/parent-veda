// =============================================================================
//  PpWakeWindowsScreen — her happy-awake window, shown directly
// -----------------------------------------------------------------------------
//  The Sleep rebuild's one new tool: "Her current happy-awake window, shown
//  directly. A guide, not a stopwatch: watch her, not the clock."
//
//  ⚠️ IT ASKS NOTHING. The app knows her age, so the screen opens on her
//  window and offers no other. That is the age rule applied to a tool: the
//  old "Is she sleeping enough?" existed only to turn an age into a range, and
//  this one would have the same shape if it had an age picker. It does not.
//
//  ⚠️ NOT A TIMER. The obvious feature — "she woke 38 minutes ago, 22 to go"
//  with a countdown — is exactly the thing the brief warns off. A wake window
//  is a range that varies by the day and by the baby; a countdown turns it
//  into a target and the section's rule is that nothing here becomes an
//  anxiety tool. So if she HAS logged a sleep today the screen says, quietly,
//  how long ago it ended, and stops there. No colour change, no "overdue".
//
//  ⚠️ THE NUMBERS MATCH THE TRACKER. `SleepStore.ageContext.wakeLabel` already
//  shows a wake window on the Sleep journey's age-context card, for the first
//  year. Two screens quoting different windows for the same baby is a bug that
//  cannot be seen from either screen, so `test/pp_sleep_door_test.dart` reads
//  both and fails if they drift. The table below extends past the tracker's
//  range because a toddler has a wake window and the tracker's card does not
//  reach that far.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_child_profile.dart';
import 'pp_content.dart';
import 'pp_sleep_data.dart';
import 'pp_surface_router.dart';

/// One age span's happy-awake window, in minutes.
class PpWakeWindow {
  const PpWakeWindow({
    required this.fromMonths,
    required this.toMonths,
    required this.minMinutes,
    required this.maxMinutes,
    required this.note,
  });

  /// Inclusive lower, exclusive upper — the `PpBand` convention.
  final int fromMonths;
  final int toMonths;
  final int minMinutes;
  final int maxMinutes;

  /// What this span is like, in one line.
  final String note;

  bool contains(int months) => months >= fromMonths && months < toMonths;

  /// "60 to 90 minutes", "1.5 to 2.5 hours".
  String get label {
    String one(int m) {
      if (m < 60) return '$m';
      final h = m / 60;
      return h == h.roundToDouble() ? '${h.round()}' : h.toStringAsFixed(1);
    }

    if (maxMinutes < 60) return '$minMinutes to $maxMinutes minutes';
    if (minMinutes < 60) return '$minMinutes minutes to ${one(maxMinutes)} hour';
    return '${one(minMinutes)} to ${one(maxMinutes)} hours';
  }
}

/// The arc. Newborn about 45 to 60 minutes, rising.
const List<PpWakeWindow> kPpWakeWindows = [
  PpWakeWindow(
      fromMonths: 0,
      toMonths: 1,
      minMinutes: 45,
      maxMinutes: 60,
      note: 'Barely longer than a feed and a nappy. That is the whole window, '
          'and it is not a problem to solve.'),
  PpWakeWindow(
      fromMonths: 1,
      toMonths: 4,
      minMinutes: 60,
      maxMinutes: 90,
      note: 'Long enough for a feed, a look around and a short play on the '
          'mat, then she is done.'),
  PpWakeWindow(
      fromMonths: 4,
      toMonths: 7,
      minMinutes: 90,
      maxMinutes: 150,
      note: 'The first window of the day is usually the shortest. Later ones '
          'stretch a little.'),
  PpWakeWindow(
      fromMonths: 7,
      toMonths: 10,
      minMinutes: 120,
      maxMinutes: 180,
      note: 'Two or three naps a day, and the last stretch before bed is often '
          'the longest.'),
  PpWakeWindow(
      fromMonths: 10,
      toMonths: 15,
      minMinutes: 180,
      maxMinutes: 240,
      note: 'Two naps, moving toward one. The morning nap is the one that '
          'goes.'),
  PpWakeWindow(
      fromMonths: 15,
      toMonths: 24,
      minMinutes: 240,
      maxMinutes: 330,
      note: 'One afternoon nap. The morning stretch and the evening stretch '
          'are both long now.'),
  PpWakeWindow(
      fromMonths: 24,
      toMonths: 36,
      minMinutes: 300,
      maxMinutes: 390,
      note: 'One nap after lunch, and a whole morning awake. If the nap runs '
          'past 3pm, bedtime pays for it.'),
  PpWakeWindow(
      fromMonths: 36,
      toMonths: 72,
      minMinutes: 360,
      maxMinutes: 720,
      note: 'Most of the day, with a nap or quiet rest after lunch for as '
          'long as she still needs it.'),
];

PpWakeWindow ppWakeWindowFor(int months) {
  for (final w in kPpWakeWindows) {
    if (w.contains(months)) return w;
  }
  return months < 0 ? kPpWakeWindows.first : kPpWakeWindows.last;
}

class PpWakeWindowsScreen extends StatefulWidget {
  const PpWakeWindowsScreen({super.key});

  @override
  State<PpWakeWindowsScreen> createState() => _PpWakeWindowsScreenState();
}

class _PpWakeWindowsScreenState extends State<PpWakeWindowsScreen> {
  @override
  void initState() {
    super.initState();
    // Idempotent. The store loads once and stays loaded; this only matters
    // when the tool is the first sleep surface opened in a session.
    SleepStore.instance.init();
  }

  void _open(BuildContext context, String surfaceId) {
    final screen = ppScreenForSurface(surfaceId);
    if (screen == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: surfaceId),
      builder: (_) => screen,
    ));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([
          ChildProfileStore.instance,
          SleepStore.instance,
          V2PaletteStore.instance,
        ]),
        builder: (context, _) => _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) {
    final child = ChildProfileStore.instance;
    final window = ppWakeWindowFor(child.ageInMonths);
    final tint = ppTintFor(206);

    // How long since the last logged sleep ended, if that was today.
    final last = SleepStore.instance.last;
    final now = DateTime.now();
    final awakeFor = last != null &&
            last.end.year == now.year &&
            last.end.month == now.month &&
            last.end.day == now.day
        ? SleepStore.instance.currentWakeMinutes
        : null;

    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
          children: [
            ppV3Back(context, p),
            const SizedBox(height: 18),
            Text('Wake windows',
                style: pvFraunces(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    height: 1.22,
                    color: p.ink1)),
            const SizedBox(height: 8),
            Text(
                'How long ${child.nameMid} can happily stay awake between one '
                'sleep and the next, right now. A guide, not a stopwatch.',
                style: pvManrope(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                    color: p.ink2)),
            const SizedBox(height: 22),

            // ---- her window --------------------------------------------------
            Container(
              padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'FOR ${child.nameMid.toUpperCase()}  ·  '
                        '${child.ageLabel.toUpperCase()}',
                        style: pvManrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: p.action)),
                    const SizedBox(height: 10),
                    Text(window.label,
                        style: pvFraunces(
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                            letterSpacing: -0.8,
                            color: p.ink1)),
                    const SizedBox(height: 6),
                    Text('happily awake, between sleeps',
                        style: pvManrope(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: p.ink2)),
                    const SizedBox(height: 12),
                    Container(
                        height: 1, color: Colors.white.withValues(alpha: 0.7)),
                    const SizedBox(height: 11),
                    Text(window.note,
                        style: pvManrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.55,
                            color: p.ink1)),
                    if (awakeFor != null) ...[
                      const SizedBox(height: 12),
                      Row(children: [
                        Icon(Icons.schedule_rounded, size: 15, color: p.ink3),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                              'Awake for about ${_hm(awakeFor)} since the last '
                              'sleep you logged. Just so you know, not a '
                              'countdown.',
                              style: pvManrope(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                  color: p.ink2)),
                        ),
                      ]),
                    ],
                  ]),
            ),
            const SizedBox(height: 26),

            // ---- watch her, not the clock ------------------------------------
            const PpBlockView(
              block: PpCards([
                PpCard('A long, still stare',
                    'Looking through you rather than at you. The earliest sign, '
                        'and the easiest to miss.'),
                PpCard('Rubbing eyes or ears, pulling hair',
                    'Her hands go to her face. In a newborn this is often the '
                        'first thing you see.'),
                PpCard('Turning away from you or the toy',
                    'She has had enough of the interesting thing. Not bored, '
                        'ready.'),
                PpCard('Yawning, and going quiet',
                    'One yawn is a good moment to start. Three yawns is late.'),
                PpCard('Fussing with no obvious cause',
                    'Fed, dry, not too warm, and cross anyway. Usually this is '
                        'the window closing.'),
              ], heading: 'Watch her, not the clock', hue: 206),
            ),
            const SizedBox(height: 26),
            const PpBlockView(
              block: PpCallout(
                  'The window is a guide to when to start looking, not a time '
                  'to hit. Two babies the same age can sit at opposite ends of '
                  'it, and the same baby can move across it in a week. If she '
                  'shows the signs early, follow her. If she is cheerful past '
                  'it, that is fine too.'),
            ),
            const SizedBox(height: 20),
            const PpBlockView(
              block: PpWhenLine(
                  'The window lengthens as she grows and nothing you do sets '
                  'its pace. An overtired baby is harder to settle, not easier, '
                  'so catching the window matters more than stretching it.'),
            ),
            const SizedBox(height: 14),
            const PpBlockView(
              block: PpIndiaNote(
                  'In a busy house the signs are easy to miss because someone '
                  'is always entertaining her. Whoever is holding her when the '
                  'stare arrives is the one who should start the wind-down.'),
            ),
            const SizedBox(height: 24),
            PpBlockView(
              block: const PpLink(
                'Log her sleep and see the shape of her day',
                surfaceId: 'pp_sleep',
                blurb: 'A few days of times is what makes her own window '
                    'visible.',
              ),
              onSurface: _open,
            ),
            const SizedBox(height: 10),
            PpBlockView(
              block: const PpLink(
                'The overtired baby',
                surfaceId: 'pp_section/parenting_sleep/how_much',
                blurb: 'Why more tired is harder to settle, and how to catch '
                    'the window.',
              ),
              onSurface: _open,
            ),
          ],
        ),
      ),
    );
  }

  static String _hm(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '$m minutes';
    if (m == 0) return '$h ${h == 1 ? 'hour' : 'hours'}';
    return '${h}h ${m}m';
  }
}
