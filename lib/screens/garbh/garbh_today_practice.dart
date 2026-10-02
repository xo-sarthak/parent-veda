// =============================================================================
//  Garbh Sanskar — Today's practice, ONE component for two homes
// -----------------------------------------------------------------------------
//  2026-09-23. The user: *"on the pregnancy home we have this same section for
//  Garbh Sanskar… the same section should not be different at two places in
//  the same app."* It was:
//
//    · THE HOME drew four pillar rows with today's actual pick ("Morning Calm
//      Raga") and a done tick — and every row opened the OLD standalone pillar
//      screen, and "About" opened the old library (with a streak card the
//      brief forbids), under a comment claiming it opened the door.
//    · THE DOOR's Today tab drew four generic cards whose text never changed
//      ("One raga chosen for today, and why") — the right destinations, and no
//      word of what today actually holds.
//
//  Each half right, and drifting: the rows' own comments record Buddhi going
//  missing from one of them and Kriya wearing two colours. Two copies of one
//  thing drift; one thing cannot. So this is the only drawing of today's
//  practice in the app, and both places render it.
//
//  THE BRIEF (ParentVeda_Garbh_Sanskar_rebuild.pdf, 30 Aug 2026), held here:
//    · Four cards, each opening its HOME TAB at today's pick — Shravan → Listen,
//      Samvad → Talk and read, Buddhi and Kriya → For you. In the door that is a
//      tab switch; on the home it opens the door at that tab (`PvDoorTabSwitch`).
//    · "Keep the existing 'nothing keeps score' behaviour; do not add a streak."
//      The done tick is hers for today and counts nothing.
//    · The pillar names stay, each with the plain subtitle the build had.
//
//  THE SHAPE is Headspace's "Start your day" (Mobbin, 2026-09-23): today's
//  items as a short list, each with what it is, its format and minutes, and a
//  state mark — the one app in the set that shows today's practice WITHOUT a
//  streak or a weekly ring beside it (Calm, Ten Percent Happier and stoic all
//  put one there; the brief rules that out).
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/doors/pv_door_data.dart' show pvDoorPageFor;
import '../../data/garbh_data.dart';
import '../../data/reads/read_images.dart' show readImageFor;
import '../../services/bracket_resolver.dart' show bracketById;
import '../../services/garbh_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../doors/pv_door_screen.dart' show PvDoorScreen, PvDoorTabSwitch;
import '../garbh_buddhi_screen.dart' show GarbhBuddhiScreen, buddhiTodayLine;
import '../garbh_samvad_daily.dart' show GarbhSamvadDailyScreen;
import '../garbh_screen.dart' show KriyaScreen, ShravanScreen, gameForPuzzle;
import '../v2/v2_palette.dart';

/// The Garbh door's bracket and its tabs — the destinations. Kept as strings
/// here (not imported from the door's data file) so this component has no
/// dependency on the door's layout; `garbh_symmetry_test.dart` holds them equal.
const String kGarbhBracketId = 'pregnancy_garbh';
const String kGarbhTabListenId = 'listen';
const String kGarbhTabReadId = 'read';
const String kGarbhTabForYouId = 'for_you';

/// One pillar's today.
@immutable
class GarbhTodayItem {
  const GarbhTodayItem({
    required this.pillarId,
    required this.name,
    required this.tag,
    required this.today,
    required this.meta,
    required this.icon,
    required this.accent,
    required this.tab,
  });

  /// Identity — the `GarbhStore` done key. Never a label.
  final String pillarId;

  /// The Sanskrit name, which the brief keeps.
  final String name;

  /// The plain subtitle the build already had.
  final String tag;

  /// TODAY's item, named. The row is worth tapping because it says what is
  /// behind it.
  final String today;

  /// "Audio · 7 min" — the format and how long, Headspace's line.
  final String meta;
  final IconData icon;
  final Color accent;

  /// The door tab it opens at.
  final String tab;

  /// The pillar's photograph (R2 through the read-image table), or null.
  String? get image => readImageFor('garbh_pillar_$pillarId');
}

/// Read-aloud time for a passage, honestly derived: words at a gentle
/// read-aloud pace (about 110 a minute), never less than a minute.
int garbhReadAloudMinutes(String text) {
  final words = text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  return (words / 110).ceil().clamp(1, 60);
}

/// What today holds, for her day of pregnancy and her week.
///
/// ⚠️ THE SAME FUNCTIONS THE PILLARS' OWN SCREENS USE (`shravanForDay`,
/// `promptForDay`, `buddhiTodayLine`, `kriyaForDay`), so this card and the tab
/// it opens name the same thing — "today's raga" here is today's raga there.
List<GarbhTodayItem> garbhTodayItems({required int day, required int week}) {
  final raga = shravanForDay(day);
  final prompt = promptForDay(day, garbhTrimester(week));
  final practice = kriyaForDay(day);
  return [
    GarbhTodayItem(
      pillarId: 'shravan',
      name: 'Shravan',
      tag: 'Listening',
      today: raga.title.en,
      meta: 'Audio · ${raga.minutes} min',
      icon: Icons.graphic_eq_rounded,
      accent: const Color(0xFF9A7526),
      tab: kGarbhTabListenId,
    ),
    GarbhTodayItem(
      pillarId: 'samvad',
      name: 'Samvad',
      tag: 'Talking to your baby',
      today: prompt.title.en,
      meta: 'Read aloud · about ${garbhReadAloudMinutes(prompt.text.en)} min',
      icon: Icons.record_voice_over_rounded,
      accent: const Color(0xFF9C5F51),
      tab: kGarbhTabReadId,
    ),
    GarbhTodayItem(
      pillarId: 'buddhi',
      name: 'Buddhi',
      tag: 'Just for you',
      today: buddhiTodayLine(day).en,
      // No number: a puzzle has no honest length, and "10 min" would be a
      // target she could fail — the thing this pillar refuses to be.
      meta: 'A quiet game · as long as you like',
      icon: Icons.extension_rounded,
      accent: const Color(0xFF2F2C30),
      tab: kGarbhTabForYouId,
    ),
    GarbhTodayItem(
      pillarId: 'kriya',
      name: 'Kriya',
      tag: 'Breath and grounding',
      today: practice.title.en,
      meta: 'Breath · ${practice.minutes} min',
      icon: Icons.spa_rounded,
      accent: const Color(0xFF8A6D3B),
      tab: kGarbhTabForYouId,
    ),
  ];
}

/// Open a pillar where it lives: switch tabs when already inside the door,
/// otherwise open the door at that tab. The caller never needs to know which.
void garbhOpenPillar(BuildContext context, PregnancyController c, String tab) {
  if (PvDoorTabSwitch.maybeOf(context) case final door?) {
    door.goTo(tab);
    return;
  }
  openGarbhDoor(context, c, at: tab);
}

/// Open TODAY'S PRACTICE itself, for the day the row names.
///
/// ⚠️ THE PRACTICE, NOT THE DOOR'S LANDING PAGE (2026-10-02, the user: "when
/// clicked on any one of them, instead of leaving the user hanging by taking
/// them on the Garbh Sanskar door page, considering it is the daily practice,
/// open it, like open the audio when clicked on Shravan that is meant for that
/// day. Same for all the other pillars"). Each row used to call
/// `garbhOpenPillar`, which opens the door at a tab: right for browsing, wrong
/// for a row that says "Morning Calm Raga · Audio · 7 min", because she then
/// had to find the raga again. Now:
///
///   Shravan → today's raga's player      (ShravanScreen, daily)
///   Samvad  → today's piece, record first (GarbhSamvadDailyScreen)
///   Buddhi  → today's quiet game          (GarbhBuddhiScreen → the puzzle)
///   Kriya   → today's breath or relaxation (KriyaScreen, daily)
///
/// ⚠️ THE SAME DAY THE ROW NAMES. [day] is the day on the home's date strip, and
/// each screen takes it, so the raga on the row is the raga that plays even for an
/// earlier day. The screens that finish a practice still mark it done, as they
/// always did: "finishes on its own when you're done".
///
/// ⚠️ THE LIBRARY IS STILL ONE TAP AWAY. Each screen keeps its "see all" line, and
/// the door's tabs are unchanged; "About" on the home still opens the door. Only a
/// row's tap changed. `garbhOpenPillar` is kept for any caller that wants the tab.
void garbhOpenToday(BuildContext context, PregnancyController c,
    GarbhTodayItem item, {required int day}) {
  final Widget screen = switch (item.pillarId) {
    'shravan' => ShravanScreen(controller: c, daily: true, day: day),
    'samvad' => GarbhSamvadDailyScreen(
        controller: c,
        day: day,
        // The shelves of the library are the door's Read tab: leave this screen
        // and go there.
        onOpenLibrary: () {
          Navigator.of(context).pop();
          garbhOpenPillar(context, c, kGarbhTabReadId);
        },
      ),
    'buddhi' => GarbhBuddhiScreen(
        controller: c,
        daily: true,
        day: day,
        onOpenPuzzle: (ctx, puzzle) => Navigator.of(ctx).push(MaterialPageRoute<void>(
            builder: (_) => gameForPuzzle(puzzle, c, markComplete: true))),
      ),
    'kriya' => KriyaScreen(controller: c, daily: true, day: day),
    // An unknown pillar falls back to where it lives, never to nothing.
    _ => const SizedBox.shrink(),
  };
  if (screen is SizedBox) {
    garbhOpenPillar(context, c, item.tab);
    return;
  }
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: 'garbh/today/${item.pillarId}'),
    builder: (_) => screen,
  ));
}

/// The Garbh Sanskar door, from outside it (the pregnancy home).
void openGarbhDoor(BuildContext context, PregnancyController c, {String? at}) {
  final page = pvDoorPageFor(kGarbhBracketId);
  final bracket = bracketById(kGarbhBracketId);
  if (page == null || bracket == null) return; // held by the symmetry test
  Navigator.of(context).push(MaterialPageRoute<void>(
    // The route name the home's Ask button reads, unchanged.
    settings: const RouteSettings(name: 'garbh'),
    builder: (_) => PvDoorScreen(page: page, bracket: bracket, pregnancy: c, initialGroup: at),
  ));
}

/// Today's practice — the four rows, inside a card. The home's band and the
/// door's Today tab both draw exactly this.
class GarbhTodayPractice extends StatelessWidget {
  const GarbhTodayPractice({super.key, required this.pregnancy, this.framed = true, this.day, this.week});
  final PregnancyController pregnancy;

  /// The pregnancy day and week to draw. The home passes the day selected on
  /// its date strip (so the whole home follows one day); the door draws today.
  final int? day;
  final int? week;

  /// The home frames it as a card over its photo band; the door frames it the
  /// same way. Off only for a caller that supplies its own frame.
  final bool framed;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Listenable.merge([V2PaletteStore.instance, GarbhStore.instance]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final c = pregnancy;
          final items = garbhTodayItems(day: day ?? c.currentDay, week: week ?? c.currentWeek);
          final store = GarbhStore.instance;
          final rows = Column(children: [
            for (var i = 0; i < items.length; i++) ...[
              GarbhPracticeRow(
                key: ValueKey('garbh_today_${items[i].pillarId}'),
                p: p,
                item: items[i],
                done: store.isDone(items[i].pillarId),
                // Kept for revert: `garbhOpenPillar(context, c, items[i].tab)`,
                // which opened the door at the pillar's tab.
                onOpen: () => garbhOpenToday(context, c, items[i],
                    day: day ?? c.currentDay),
                onToggleDone: () {
                  pvCommitFeedback();
                  final id = items[i].pillarId;
                  store.isDone(id) ? store.undoDone(id) : store.markDone(id);
                },
              ),
              if (i < items.length - 1) Divider(height: 1, thickness: 1, color: p.line),
            ],
          ]);
          if (!framed) return rows;
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.line),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4)),
              ],
            ),
            child: rows,
          );
        },
      );
}

/// One pillar: its photograph, the Sanskrit name in its accent with the plain
/// subtitle, today's item, the format and minutes, and her done tick.
class GarbhPracticeRow extends StatelessWidget {
  const GarbhPracticeRow({
    super.key,
    required this.p,
    required this.item,
    required this.done,
    required this.onOpen,
    required this.onToggleDone,
  });
  final V2Palette p;
  final GarbhTodayItem item;
  final bool done;
  final VoidCallback onOpen;
  final VoidCallback onToggleDone;

  @override
  Widget build(BuildContext context) {
    final photo = item.image;
    return Row(children: [
      Expanded(
        child: InkWell(
          onTap: () {
            pvCommitFeedback();
            onOpen();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              // A PHOTOGRAPH OF THE PRACTICE — a tabla, a heart held on a bump,
              // puzzle pieces, a diya — with the pillar's glyph as the fallback
              // so a dead link costs a mark, not a hole.
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 54,
                  height: 54,
                  color: item.accent.withValues(alpha: 0.14),
                  alignment: Alignment.center,
                  child: photo == null
                      ? Icon(item.icon, size: 22, color: item.accent)
                      : Image.network(photo,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(item.icon, size: 22, color: item.accent)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // The Sanskrit name carries the accent; the gloss does not.
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: item.name.toUpperCase(),
                          style: pvManrope(
                              fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: item.accent)),
                      TextSpan(
                          text: '  ·  ${item.tag}',
                          style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w600, color: p.ink3)),
                    ]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(item.today,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvFraunces(
                          fontSize: 15.5, fontWeight: FontWeight.w600, height: 1.22, letterSpacing: -0.3, color: p.ink1)),
                  const SizedBox(height: 3),
                  Text(item.meta, style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w600, color: p.ink2)),
                ]),
              ),
            ]),
          ),
        ),
      ),
      // Her tick for today — a signifier, not a score. 44pt target.
      Semantics(
        button: true,
        label: done ? '${item.name} done today' : 'Mark ${item.name} done today',
        child: InkWell(
          onTap: onToggleDone,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: done ? item.accent : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: done ? item.accent : Colors.black.withValues(alpha: 0.16), width: 1.5),
                ),
                child: done ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
