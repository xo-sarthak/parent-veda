// =============================================================================
//  Move today — the page behind the home rail's Move card (2026-10-22)
// -----------------------------------------------------------------------------
//  The user, walking the phone: the card said Move and opened an article. "No
//  user is gonna expect an article" when she taps Move; give her a movement,
//  a video if there is one, a teacher if she wants one, and if there is an
//  article, say it is one. Approved as drawn in the prototype (artifact
//  1WKApV5Qck5tifamhY1TDH). Mobbin: Fitbit's and Runna's session pages (the
//  film first, minutes and kind on one line, one big button), Tempo's "Good
//  to know" rows, Withings' "Article" label said before the tap.
//
//  ⚠️ THE BUTTON SAYS WHAT HAPPENS. The user's one condition on the design:
//  "make sure that Start button won't misguide people, as in a difference
//  between start/play activity vs video". So there is no "Start". With a film
//  the button is "Play video · 15 min"; without one (every session today) the
//  poster and the button both say "Video coming soon" and nothing is tappable.
//  `PrepareVideoScreen` is a placeholder player, and a Play that lands on a
//  placeholder is exactly the misguiding tap she asked us not to make.
//
//  ⚠️ NO RATINGS OR REVIEWER NAMES on the class rows. Those are seed values in
//  pp_yoga_data.dart, not real reviews, and the class page itself is where a
//  booking decision is made.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/doors/pv_door_move.dart' show kMoveTabClasses;
import '../../data/preg_week_extras.dart' show pregMonthFor;
import '../../data/prepare_data.dart' show YogaSession, kYogaSessions;
import '../../data/reads/pregnancy_reads_move.dart' show kMoveSurfaceToday;
import '../../data/reads/pregnancy_reads.dart' show pregnancyReadById;
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../doors/pv_door_chrome.dart';
import '../doors/pv_door_router.dart' show openPvDoorRead;
import '../doors/pv_door_screen.dart' show pvDoorScreenForBracket;
import '../post_pregnancy/pp_yoga_data.dart' show YogaClass, YogaMode, kYogaClasses;
import '../post_pregnancy/yoga_class_screen.dart';
import '../ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import '../../ttc/ttc_daily_data.dart' show ttcPickForToday;
import '../ttc/ttc_tool_marks.dart' show TtcMarkLeading;
import '../v2/v2_palette.dart';

/// The route name, so `global_ask_fab.dart` and tests can find the page.
const String kMoveTodayRoute = kMoveSurfaceToday;

/// Three lines from the yoga read's short answer
/// (`preg_move_read_yoga`, lib/data/reads/pregnancy_reads_move.dart), so
/// the page adds no safety advice of its own.
const List<String> kMoveTodaySafety = [
  "After about 20 weeks, don't lie flat on your back for long. Use a cushion or stay on your side.",
  'Skip hot yoga, and if you are new to yoga, leave out deep twists and upside-down poses.',
  'Stop and call your doctor if you have pain, bleeding or feel faint.',
];

YogaSession? yogaSessionById(String id) => kYogaSessions.where((s) => s.id == id).firstOrNull;

/// Today's session for her week: one of her month's, stable for the day and
/// different across days. The home card and a read's "Try today's session"
/// both ask here, so they always name the same session.
YogaSession? moveTodaySessionFor(int week, DateTime date) {
  final mine = [for (final s in kYogaSessions) if (s.month == pregMonthFor(week)) s];
  return mine.isEmpty ? null : ttcPickForToday(mine, now: date, offset: 3);
}

/// The prenatal classes, in catalogue order.
List<YogaClass> get kPrenatalClasses => [for (final c in kYogaClasses) if (c.category == 'prenatal') c];

void openMoveToday(BuildContext context, PregnancyController c, {required String sessionId, String? readId}) {
  final s = yogaSessionById(sessionId);
  if (s == null) return;
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kMoveTodayRoute),
    builder: (_) => PvMoveTodayScreen(session: s, readId: readId, pregnancy: c),
  ));
}

class PvMoveTodayScreen extends StatelessWidget {
  const PvMoveTodayScreen({super.key, required this.session, required this.pregnancy, this.readId});
  final YogaSession session;
  final PregnancyController pregnancy;
  final String? readId;

  bool get _hasVideo => (session.videoUrl ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final read = readId == null ? null : pregnancyReadById(readId!);
    final classes = kPrenatalClasses;
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        return Scaffold(
          backgroundColor: p.ground,
          body: CustomScrollView(slivers: [
            // ---- THE POSTER: the film's place, honest about whether it exists
            SliverAppBar(
              pinned: true,
              expandedHeight: 240,
              backgroundColor: p.ground,
              surfaceTintColor: Colors.transparent,
              foregroundColor: p.ink1,
              elevation: 0,
              scrolledUnderElevation: 0,
              shape: Border(bottom: BorderSide(color: p.line)),
              leading: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Material(
                  color: Colors.white.withValues(alpha: 0.82),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: SizedBox(width: 40, height: 40, child: Icon(Icons.arrow_back_rounded, size: 20, color: p.ink1)),
                  ),
                ),
              ),
              leadingWidth: 56,
              flexibleSpace: FlexibleSpaceBar(
                background: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFECE7E0), Color(0xFFDCD3C8)],
                    ),
                  ),
                  child: Stack(children: [
                    Center(child: TtcMarkLeading(tab: TtcTabMark.lotus, tint: p.ink1, size: 72)),
                    Positioned(
                      left: 16,
                      bottom: 14,
                      child: Container(
                        key: const ValueKey('move_today_poster_badge'),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88), borderRadius: BorderRadius.circular(999)),
                        child: Text(_hasVideo ? 'VIDEO · ${session.duration.en.toUpperCase()}' : 'VIDEO COMING SOON',
                            style: pvManrope(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: p.ink1)),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            SliverList.list(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('MOVE TODAY · MONTH ${session.month}',
                      style: pvManrope(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: p.ink2)),
                  const SizedBox(height: 6),
                  Text(session.title.en,
                      style: pvFraunces(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.5, height: 1.15, color: p.ink1)),
                  const SizedBox(height: 6),
                  Text('${session.duration.en} · Prenatal yoga · No equipment',
                      style: pvManrope(fontSize: 13, color: p.ink2)),
                  const SizedBox(height: 16),
                  _videoButton(context, p),
                  if (!_hasVideo) ...[
                    const SizedBox(height: 8),
                    Text('Until then, join a teacher below, or read the guide first.',
                        style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink3)),
                  ],
                  const SizedBox(height: 16),
                  Text(session.blurb.en, style: pvManrope(fontSize: 15, height: 1.55, color: p.ink1)),
                ]),
              ),

              // ---- GOOD TO KNOW ------------------------------------------
              _heading(p, 'Good to know'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line)),
                  child: Column(children: [
                    for (var i = 0; i < kMoveTodaySafety.length; i++)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                            border: i == kMoveTodaySafety.length - 1 ? null : Border(bottom: BorderSide(color: p.line))),
                        child: Text(kMoveTodaySafety[i], style: pvManrope(fontSize: 14, height: 1.5, color: p.ink1)),
                      ),
                  ]),
                ),
              ),

              // ---- DO IT WITH A TEACHER ----------------------------------
              if (classes.isNotEmpty) ...[
                _heading(p, 'Do it with a teacher'),
                for (final c in classes) _classRow(context, p, c),
              ],

              // ---- READ FIRST: an article, and it says so ----------------
              if (read != null) ...[
                _heading(p, 'Read first'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Material(
                    color: p.ground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: p.line)),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      key: const ValueKey('move_today_read'),
                      onTap: () => openPvDoorRead(context, read.id, pregnancy),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(children: [
                          TtcMarkLeading(tab: TtcTabMark.openBook, tint: p.ink1, size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('ARTICLE · ${read.minutes} MIN READ',
                                  style: pvManrope(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: p.ink2)),
                              const SizedBox(height: 2),
                              Text(read.title.en, style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
                            ]),
                          ),
                          Icon(Icons.chevron_right_rounded, color: p.ink3),
                        ]),
                      ),
                    ),
                  ),
                ),
              ],

              // ---- THE DOOR ----------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 14, 20, 0),
                child: TextButton(
                  key: const ValueKey('move_today_door'),
                  onPressed: () {
                    final door = pvDoorScreenForBracket('pregnancy_fitness', pregnancy, initialGroup: kMoveTabClasses);
                    if (door == null) return;
                    Navigator.of(context).push(MaterialPageRoute<void>(
                      // The door's own route name, as the home opens every door.
                      settings: const RouteSettings(name: 'bracket/scans'),
                      builder: (_) => door,
                    ));
                  },
                  child: Text('All yoga and classes →',
                      style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PvDoorDisclaimer(
                    p: p,
                    text: 'General guidance for a healthy pregnancy. If your doctor has asked you to rest or '
                        'avoid exercise, go with your doctor.'),
              ),
              const SizedBox(height: 32),
            ]),
          ]),
        );
      },
    );
  }

  /// The one button. Its words are what the tap does.
  Widget _videoButton(BuildContext context, V2Palette p) {
    if (_hasVideo) {
      return FilledButton.icon(
        key: const ValueKey('move_today_play'),
        onPressed: () {
          pvCommitFeedback();
          // The player lands with the first film; until a session carries a
          // videoUrl this branch is unreachable, by design.
        },
        icon: const Icon(Icons.play_arrow_rounded, size: 20),
        label: Text('Play video · ${session.duration.en}'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      );
    }
    return OutlinedButton(
      key: const ValueKey('move_today_coming'),
      onPressed: null,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: p.line),
        foregroundColor: p.ink2,
        disabledForegroundColor: p.ink2,
      ),
      child: const Text('Video coming soon'),
    );
  }

  Widget _heading(V2Palette p, String t) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
        child: Text(t, style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
      );

  Widget _classRow(BuildContext context, V2Palette p, YogaClass c) {
    final mode = switch (c.mode) {
      YogaMode.liveGroup => 'Live group',
      YogaMode.liveOneToOne => 'Live 1:1',
      YogaMode.recorded => 'Recorded',
    };
    final when = c.mode == YogaMode.recorded ? c.durationLabel : c.schedule.replaceFirst(RegExp(r'^Live\s*·\s*'), '');
    return InkWell(
      key: ValueKey('move_today_class_${c.id}'),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          settings: RouteSettings(name: 'move/yoga/class/${c.id}'), builder: (_) => YogaClassScreen(cls: c))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(children: [
          TtcMarkLeading(
              tab: c.mode == YogaMode.recorded ? TtcTabMark.openBook : TtcTabMark.lotus, tint: p.ink1, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.title, style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
              const SizedBox(height: 2),
              Text('$mode · $when', style: pvManrope(fontSize: 12.5, color: p.ink3)),
            ]),
          ),
          const SizedBox(width: 8),
          Text(c.price, style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink1)),
        ]),
      ),
    );
  }
}
