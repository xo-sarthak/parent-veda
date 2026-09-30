// =============================================================================
//  The free preconception garbh sanskar course — the course, and one session
// -----------------------------------------------------------------------------
//  ⚠️ THE DOOR ALREADY PROMISED THIS AND DID NOT DELIVER IT. Mind & body's "Go
//  deeper" tile says *"taught properly rather than described"* and opened
//  `ttc_prepare` — the Prepare catalogue — where the course was one card
//  DESCRIBING eight sessions at a price of zero. Tapping a tile that promises
//  teaching and landing on a description is the exact failure the wiring gate
//  exists to catch, and it is invisible to a test that only checks the tile
//  opens something.
//
//  ⚠️ IT TEACHES BY RUNNING THE REAL PRACTICE PLAYERS. A session names practice
//  ids and this screen renders `TtcPracticeSession` — the same widget the
//  library's own cards use. The brief is explicit: *"Reuse, do not rebuild. The
//  course uses the same animation components already built for the twelve
//  practice cards."* So session 2 is not a description of the long out-breath
//  with a picture of a circle; it is the long out-breath.
//
//  ⚠️ NOTHING LOCKS. No session waits for the one before it, no session waits
//  for a partner, and there is no order enforced anywhere in this file. Four
//  sessions SAY they are better done together and that is a line of text. The
//  brief: *"Do not require them to be in sync or to have both finished a
//  session before the next unlocks."*
//
//  ⚠️ AND NOTHING COSTS. No price, no upsell, no locked session — the course is
//  the one free thing in a priced catalogue and that is its entire job. If a
//  paid tile ever appears on this screen the acquisition argument is gone.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_garbh_course.dart';
import '../../ttc/ttc_garbh_course_store.dart';
import '../../ttc/ttc_practice_data.dart';
import '../v2/v2_palette.dart';
import 'ttc_mind_today_screen.dart';
import 'ttc_practice_card_parts.dart';
import 'ttc_practice_player.dart';
import 'ttc_surface_router.dart';
import 'ttc_tool_chrome.dart';
import '../learn/pv_offering_screen.dart';
import '../learn/pv_learn_catalog.dart';
import 'ttc_common.dart' show ttcTitleInk;

/// Sage. The hue of "The practice" tab, which is where this course is reached
/// from — see `ttc_focus_mind_body.dart`. The course is the deep end of that
/// tab, not a different subject.
const double kTtcCourseHue = 104;

// =============================================================================
//  The course
// =============================================================================

// ⚠️ FACADE since 2026-09-20 (docs/LEARNING-AUDIT.md). The class keeps its
// name and constructor so every push of it lands on the unified learn
// screens; the body below is kept, byte for byte, as `TtcGarbhCourseScreenClassic` for
// revert. Nothing pushes the Classic (test/pv_learn_test.dart holds that).
class TtcGarbhCourseScreen extends StatelessWidget {
  const TtcGarbhCourseScreen({super.key, });

  @override
  Widget build(BuildContext context) {
    final v = PvLearnCatalog.instance.byId(kPvTtcGarbhCourseId);
    return v == null ? const TtcGarbhCourseScreenClassic() : PvOfferingScreen(view: v);
  }
}

/// The pre-2026-09-20 body. Kept for revert; nothing pushes it.
class TtcGarbhCourseScreenClassic extends StatelessWidget {
  const TtcGarbhCourseScreenClassic({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [TtcGarbhCourseStore.instance, V2PaletteStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;

        return TtcToolScaffold(
          hue: kTtcCourseHue,
          // ⚠️ "FREE" IS IN THE EYEBROW, NOT IN A BADGE FURTHER DOWN. Everything
          // else this stage offers is priced, so the first thing to know about
          // this one is that it is not.
          eyebrow: 'FREE · EIGHT SESSIONS',
          title: 'Preconception garbh sanskar',
          intro: kTtcCourseHow,
          children: [
            ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // ⚠️ THE POSITION, BEFORE THE FIRST SESSION AND NOT INSIDE
                  // IT. Session one states it too, but somebody who arrives
                  // here from a search result or a deep link has to meet it
                  // before choosing anything — and this is the paragraph the
                  // entire area is built to be able to defend.
                  _Panel(
                    p: p,
                    tint: v2BlockTint(kTtcCourseHue, p),
                    // Kept for revert (2026-09-28): "WHAT THIS IS, AND WHAT IT
                    // ISN'T". A heading names the course, not "this".
                    heading: "WHAT THE COURSE IS, AND ISN'T",
                    body: kTtcCourseFrame,
                  ),
                  const SizedBox(height: 12),
                  _Panel(
                    p: p,
                    tint: v2BlockTint(42, p),
                    heading: 'WHAT THIS COURSE WILL NEVER INCLUDE',
                    body: kTtcCourseNever,
                  ),

                  const SizedBox(height: 26),
                  Text('THE EIGHT SESSIONS',
                      style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: p.ink3)),
                  const SizedBox(height: 6),
                  // ⚠️ PROGRESS IS A SENTENCE, NOT A BAR AND NOT A COUNTER OUT
                  // OF EIGHT. The brief: *"Show progress only as which sessions
                  // have been opened."* A bar at 3/8 is a debt statement on a
                  // course whose closing note is that there is nothing to keep
                  // up with.
                  Text(
                      TtcGarbhCourseStore.instance.openedCount == 0
                          // Kept for revert (2026-09-28): '... Session one
                          // explains what this is, ...'
                          ? 'Start wherever you like. Session one explains '
                              'what the course is, and session two is the one most '
                              'people use most.'
                          : 'Open them in any order, and open them again '
                              'whenever you like.',
                      style: pvManrope(
                          fontSize: 12.5, height: 1.6, color: p.ink3)),
                  const SizedBox(height: 14),

                  for (final s in kTtcCourseSessions) ...[
                    _SessionRow(session: s, p: p),
                    const SizedBox(height: 8),
                  ],

                  const SizedBox(height: 14),
                  Text(kTtcCourseSkipNote,
                      style: pvFraunces(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w500,
                          height: 1.55,
                          color: p.ink2)),
                  const SizedBox(height: 10),
                ])),
          ],
        );
      },
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session, required this.p});

  final TtcCourseSession session;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final opened = TtcGarbhCourseStore.instance.isOpened(session.id);
    final tint = v2BlockTint(kTtcCourseHue, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.44)
        .withLightness(0.36)
        .toColor();

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TtcCourseSessionScreen(session: session),
        settings: RouteSettings(name: 'ttc_garbh_course/${session.id}'),
      )),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ⚠️ THE NUMBER FILLS WHEN IT HAS BEEN OPENED, and that is the whole
          // of the progress display. No tick, because a tick means finished and
          // nobody here is being asked to certify that they finished sitting
          // still.
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: opened ? deep : tint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('${session.number}',
                style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: opened ? Colors.white : deep)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.title,
                      style: pvFraunces(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          color: p.ink1)),
                  const SizedBox(height: 5),
                  Wrap(spacing: 12, runSpacing: 4, children: [
                    _meta(Icons.schedule_rounded, session.duration),
                    if (session.betterTogether)
                      _meta(Icons.people_outline_rounded, 'Better together'),
                  ]),
                ]),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_rounded, size: 16, color: p.ink3),
        ]),
      ),
    );
  }

  Widget _meta(IconData icon, String label) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: p.ink3),
        const SizedBox(width: 5),
        Text(label,
            style: pvManrope(
                fontSize: 11.5, fontWeight: FontWeight.w700, color: p.ink3)),
      ]);
}

// =============================================================================
//  One session
// =============================================================================

/// The parts a session is split into. Read is always there; Do only when the
/// session has something to play; Keep only when it saves something.
enum TtcCoursePart { read, doIt, keep }

extension TtcCoursePartCopy on TtcCoursePart {
  String get label => switch (this) {
        // Kept for revert (2026-09-28): 'Read', 'Do it', 'Keep it'. The
        // pills and the Next button name the part she lands on ("Next: The
        // practice"), not an "it".
        TtcCoursePart.read => 'Read',
        TtcCoursePart.doIt => 'The practice',
        TtcCoursePart.keep => 'Your plan',
      };

  /// One plain line under the part picker: what this part is.
  String get line => switch (this) {
        TtcCoursePart.read => "What this session is about, and what you'll do.",
        TtcCoursePart.doIt => "The practice itself. Start the timer when you're ready.",
        TtcCoursePart.keep => 'What this session saves for your days.',
      };
}

/// Which parts one session has, in order.
List<TtcCoursePart> ttcCourseParts(TtcCourseSession s) => [
      TtcCoursePart.read,
      if (s.sitSeconds != null ||
          s.practiceIds.any((id) => ttcPracticeById(id) != null))
        TtcCoursePart.doIt,
      if (s.action != TtcCourseAction.none) TtcCoursePart.keep,
    ];

// ⚠️ A SESSION IS TWO OR THREE SHORT PARTS NOW, NOT ONE LONG SCROLL
// (2026-09-27, tools rebuild). The notes' "too big for this pass" item, done:
// session one stacked an intro, two dense panels, five steps and a timer
// before she got to sit still; session eight put twelve options, two clocks,
// a meals line and a save on one page. Each session is now Read, Do it and
// Keep it (only the parts it has), with a picker at the top she can jump
// around in (nothing locks, the course's own rule) and Back / Next at the
// foot. The last part offers the next session, the way a course app hands
// you the next lesson.
//
// Mobbin: Blue Apron's stepped flow with Back and Next at the foot
// (https://mobbin.com/screens/abae8f67-deed-43a5-b14b-12094e2fdac1), Monzo's
// lesson opener with its length
// (https://mobbin.com/screens/4084ed06-2074-456f-b386-d48cab07b5b2), Noom's
// "Continue learning" list (https://mobbin.com/screens/e53b47e7-1acd-4689-bc75-909b8a6868b0).
// The gap analysis asks for "courses she can follow step by step" (Flo's
// "Getting pregnant 101", chapter by chapter).
//
// NOTHING ELSE CHANGED: the words, the practices, what is saved and when
// "opened" is recorded. The single scroll is kept as
// `TtcCourseSessionScreenClassic`.
class TtcCourseSessionScreen extends StatefulWidget {
  const TtcCourseSessionScreen(
      {super.key, required this.session, this.startAt = TtcCoursePart.read});

  final TtcCourseSession session;

  /// Which part opens first. Read, unless a caller has a reason.
  final TtcCoursePart startAt;

  @override
  State<TtcCourseSessionScreen> createState() => _TtcCourseSessionScreenState();
}

class _TtcCourseSessionScreenState extends State<TtcCourseSessionScreen> {
  final _scroll = ScrollController();
  late List<TtcCoursePart> _parts = ttcCourseParts(widget.session);
  late int _at = _startIndex();

  int _startIndex() =>
      _parts.contains(widget.startAt) ? _parts.indexOf(widget.startAt) : 0;

  @override
  void didUpdateWidget(TtcCourseSessionScreen old) {
    super.didUpdateWidget(old);
    // The same state can be handed another session (a rebuild in place);
    // its parts and its place in them belong to the old one.
    if (old.session.id != widget.session.id) {
      _parts = ttcCourseParts(widget.session);
      _at = _startIndex();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        TtcGarbhCourseStore.instance.markOpened(widget.session.id);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // ⚠️ ON OPEN, NOT ON FINISH. Same rule as before the split: "opened" is
    // the only fact this course records.
    //
    // ⚠️ AFTER THE FIRST FRAME, NOT IN `initState`. "Next session" replaces
    // this route with the next one, and the outgoing session still listens
    // to the store while the new one is being built: a notify from inside
    // that build marks a widget dirty mid-build, which Flutter refuses. One
    // frame later it is the same fact, recorded safely.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TtcGarbhCourseStore.instance.markOpened(widget.session.id);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _go(int i) {
    if (i == _at || i < 0 || i >= _parts.length) return;
    setState(() => _at = i);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _openNextSession(TtcCourseSession next) =>
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => TtcCourseSessionScreen(session: next),
        settings: RouteSettings(name: 'ttc_garbh_course/${next.id}'),
      ));

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final part = _parts[_at];
    final next = kTtcCourseSessions
        .where((x) => x.number == s.number + 1)
        .firstOrNull;

    return AnimatedBuilder(
      animation: Listenable.merge(
          [TtcGarbhCourseStore.instance, V2PaletteStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final tint = v2BlockTint(kTtcCourseHue, p);

        return TtcToolScaffold(
          hue: kTtcCourseHue,
          // One lesson, opened from the course: back, not an X (2026-09-29).
          leading: TtcToolLeading.back,
          scrollController: _scroll,
          eyebrow: 'SESSION ${s.number} OF 8',
          title: s.title,
          intro: s.intro,
          children: [
            ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  // ⚠️ ONE QUIET LINE FOR TIME AND WHO (2026-09-28), as on the
                  // practice cards: two bold lines behind a clock and a people
                  // icon were icons for plain facts. Headspace's session list
                  // says the length in one quiet line
                  // (https://mobbin.com/screens/f2297328-ef5d-42b9-96ba-e851f428f5e4).
                  Text('${s.duration} · ${s.setting}', style: ttcCardMeta(p)),
                  // Kept for revert (2026-09-28): the icon row below.
                  // ignore: dead_code
                  if (false) Row(children: [
                    Icon(Icons.schedule_rounded, size: 15, color: p.ink3),
                    const SizedBox(width: 7),
                    Text(s.duration,
                        style: pvManrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: p.ink2)),
                    const SizedBox(width: 12),
                    Icon(Icons.people_outline_rounded, size: 15, color: p.ink3),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(s.setting,
                          style: pvManrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: p.ink2)),
                    ),
                  ]),

                  // ---- the part picker: where she is, and free to jump -----
                  const SizedBox(height: 16),
                  TtcToolOptions(
                    p: p,
                    hue: kTtcCourseHue,
                    items: [
                      for (var i = 0; i < _parts.length; i++)
                        TtcToolOption(
                          label: '${i + 1}  ${_parts[i].label}',
                          on: i == _at,
                          onTap: () => _go(i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(part.line,
                      style: pvManrope(
                          fontSize: 12.5, height: 1.5, color: p.ink3)),

                  if (part == TtcCoursePart.read)
                    ..._readPart(s, p, tint)
                  else if (part == TtcCoursePart.doIt)
                    ..._doPart(s, p)
                  else
                    ..._keepPart(s, p),

                  // ---- Back and Next -----------------------------------------
                  const SizedBox(height: 26),
                  if (_at < _parts.length - 1)
                    Row(children: [
                      if (_at > 0) ...[
                        Expanded(
                          child: TtcToolSecondary(
                              label: 'Back', onTap: () => _go(_at - 1)),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        flex: 2,
                        child: TtcToolPrimary(
                            label: 'Next: ${_parts[_at + 1].label}',
                            onTap: () => _go(_at + 1)),
                      ),
                    ])
                  else ...[
                    if (next != null)
                      TtcToolPrimary(
                          label: 'Next session: ${next.title}',
                          onTap: () => _openNextSession(next))
                    else
                      TtcToolPrimary(
                          label: 'Back to the course',
                          onTap: () => Navigator.of(context).maybePop()),
                    if (_at > 0) ...[
                      const SizedBox(height: 10),
                      TtcToolSecondary(
                          label: 'Back', onTap: () => _go(_at - 1)),
                    ],
                  ],
                  const SizedBox(height: 12),
                ])),
          ],
        );
      },
    );
  }

  // ---- Read: the frame, the steps, and the line that lowers the stakes -----
  List<Widget> _readPart(TtcCourseSession s, V2Palette p, Color tint) => [
        // ⚠️ "Better together" ALSO SAYS "and it does not wait". See the
        // Classic below for the reasoning; the words are unchanged.
        if (s.betterTogether) ...[
          const SizedBox(height: 16),
          // The card family's inset and corner (2026-09-28; was all(13),
          // radius 14), so every block on the page shares one left edge.
          Container(
            padding: kTtcCardPad,
            decoration: BoxDecoration(
              // Kept for revert (2026-09-29, no tinted slab behind text): color: p.surfaceAlt,
              color: p.surface, border: Border.fromBorderSide(BorderSide(color: p.line)),
              borderRadius: BorderRadius.circular(kTtcCardRadius),
            ),
            child: Row(children: [
              Icon(Icons.people_outline_rounded, size: 15, color: p.ink3),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                    'Better done together. But nothing here waits for anyone, '
                    'and doing it on your own counts just the same.',
                    style: pvManrope(
                        fontSize: 12.5, height: 1.5, color: p.ink2)),
              ),
            ]),
          ),
        ],
        if (s.number == 1) ...[
          const SizedBox(height: 16),
          // Kept for revert (2026-09-28): heading 'What this is'.
          _Panel(
              p: p,
              tint: tint,
              heading: 'What the course is',
              body: kTtcCourseFrame),
          const SizedBox(height: 12),
          _Panel(
            p: p,
            tint: v2BlockTint(42, p),
            heading: 'What this course leaves out',
            body: kTtcCourseNever,
          ),
        ],
        const SizedBox(height: 22),
        Text("What you'll do",
            style: pvManrope(
                fontSize: 13.5, fontWeight: FontWeight.w800, color: p.ink2)),
        const SizedBox(height: 12),
        for (var i = 0; i < s.steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: tint, borderRadius: BorderRadius.circular(999)),
                child: Text('${i + 1}',
                    style: pvManrope(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: p.ink1)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(s.steps[i],
                    style: pvManrope(
                        fontSize: 13.5, height: 1.55, color: p.ink1)),
              ),
            ]),
          ),
        // ⚠️ SAID PLAINLY STAYS ON THE FIRST PART, never behind a tap: it is
        // the sentence that lowers the stakes, and the first part is the one
        // every visit sees.
        const SizedBox(height: 16),
        // The card family (2026-09-28): its inset, corner, title and body.
        // Kept for revert: padding all(15), radius 16, the heading in bold
        // Manrope 12.5 ink2 and the words in Manrope 13 ink1.
        Container(
          width: double.infinity,
          padding: kTtcCardPad,
          decoration: BoxDecoration(
            // Kept for revert (2026-09-29, no tinted slab behind text): color: p.surfaceAlt,
            color: p.surface, border: Border.fromBorderSide(BorderSide(color: p.line)),
            borderRadius: BorderRadius.circular(kTtcCardRadius),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Said plainly', style: ttcCardTitle(p)),
            const SizedBox(height: 6),
            Text(s.saidPlainly, style: ttcCardBody(p)),
          ]),
        ),
      ];

  // ---- Do it: the sit and the practices, nothing to read around them ------
  List<Widget> _doPart(TtcCourseSession s, V2Palette p) => [
        if (s.sitSeconds case final seconds?) ...[
          const SizedBox(height: 20),
          Text(
              seconds >= 300 ? 'Sit for five minutes' : 'Sit for two minutes',
              style: pvManrope(
                  fontSize: 13.5, fontWeight: FontWeight.w800, color: p.ink2)),
          const SizedBox(height: 12),
          TtcPracticeSession.sit(seconds: seconds),
        ],
        for (final id in s.practiceIds)
          if (ttcPracticeById(id) case final practice?) ...[
            const SizedBox(height: 26),
            _TaughtPractice(practice: practice, p: p),
          ],
      ];

  // ---- Keep it: what the session saves ------------------------------------
  List<Widget> _keepPart(TtcCourseSession s, V2Palette p) => [
        const SizedBox(height: 18),
        if (s.action == TtcCourseAction.setTimes) _TimesBlock(p: p),
        if (s.action == TtcCourseAction.setMeals) ...[
          _MealsBlock(p: p),
          const SizedBox(height: 16),
          _GettingReadyLinks(p: p),
        ],
        if (s.action == TtcCourseAction.assemble) _AssembleBlock(p: p),
        if (s.number == 8) ...[
          const SizedBox(height: 20),
          Text(kTtcCourseSkipNote,
              style: pvFraunces(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                  color: p.ink2)),
        ],
      ];
}

/// One session as a single long scroll, before the 2026-09-27 rebuild split it
/// into parts. Kept for revert; nothing pushes it.
class TtcCourseSessionScreenClassic extends StatefulWidget {
  const TtcCourseSessionScreenClassic({super.key, required this.session});

  final TtcCourseSession session;

  @override
  State<TtcCourseSessionScreenClassic> createState() =>
      _TtcCourseSessionScreenClassicState();
}

class _TtcCourseSessionScreenClassicState
    extends State<TtcCourseSessionScreenClassic> {
  @override
  void initState() {
    super.initState();
    // ⚠️ ON OPEN, NOT ON FINISH. "Opened" is the only fact this course records
    // and it is true the moment the screen is on screen. Recording it on the
    // way out would quietly mean "opened and stayed", which is a completion
    // metric wearing a different name.
    TtcGarbhCourseStore.instance.markOpened(widget.session.id);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;

    return AnimatedBuilder(
      animation: Listenable.merge(
          [TtcGarbhCourseStore.instance, V2PaletteStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final tint = v2BlockTint(kTtcCourseHue, p);

        return TtcToolScaffold(
          hue: kTtcCourseHue,
          eyebrow: 'SESSION ${s.number} OF 8',
          title: s.title,
          intro: s.intro,
          children: [
            ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Row(children: [
                    Icon(Icons.schedule_rounded, size: 15, color: p.ink3),
                    const SizedBox(width: 7),
                    Text(s.duration,
                        style: pvManrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: p.ink2)),
                    const SizedBox(width: 12),
                    Icon(Icons.people_outline_rounded, size: 15, color: p.ink3),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(s.setting,
                          style: pvManrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: p.ink2)),
                    ),
                  ]),

                  // ⚠️ THE LINE THAT SAYS "better together" ALSO SAYS "and it
                  // does not wait". Without the second half, somebody doing
                  // this alone reads the first half as a requirement she cannot
                  // meet — which is exactly the person the brief is protecting
                  // when it insists this is text and not a lock.
                  if (s.betterTogether) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        // Kept for revert (2026-09-29, no tinted slab behind text): color: p.surfaceAlt,
                        color: p.surface, border: Border.fromBorderSide(BorderSide(color: p.line)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(children: [
                        Icon(Icons.people_outline_rounded,
                            size: 15, color: p.ink3),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              'Better done together. But nothing here waits '
                              'for anyone, and doing it on your own counts '
                              'just the same.',
                              style: pvManrope(
                                  fontSize: 12.5,
                                  height: 1.5,
                                  color: p.ink2)),
                        ),
                      ]),
                    ),
                  ],

                  // Session one carries the frame in full, because its own first
                  // two steps are "read the opening" and "read what this leaves
                  // out". A step that instructs you to read something absent is
                  // a step that cannot be done.
                  if (s.number == 1) ...[
                    const SizedBox(height: 18),
                    _Panel(
                      p: p,
                      tint: tint,
                      // Sentence case (tools pass, 2026-09-27). Kept for
                      // revert: 'WHAT THIS IS, PLAINLY'
                      // Kept for revert (2026-09-28): 'What this is'.
                      heading: 'What the course is',
                      body: kTtcCourseFrame,
                    ),
                    const SizedBox(height: 12),
                    _Panel(
                      p: p,
                      tint: v2BlockTint(42, p),
                      // Kept for revert (2026-09-27): 'AND THE FOUR THINGS
                      // IT LEAVES OUT'. The panel lists five, and a count
                      // that does not match makes her recount.
                      heading: 'What this course leaves out',
                      body: kTtcCourseNever,
                    ),
                  ],

                  const SizedBox(height: 24),
                  // Kept for revert (2026-09-27): 'WHAT YOU DO'.
                  _label('What you do', p),
                  const SizedBox(height: 12),
                  for (var i = 0; i < s.steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: tint,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text('${i + 1}',
                                  style: pvManrope(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: p.ink1)),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              // No maxLines: the same accessibility rule the
                              // practice cards hold. A clipped instruction is
                              // worse than a long screen.
                              child: Text(s.steps[i],
                                  style: pvManrope(
                                      fontSize: 13.5,
                                      height: 1.55,
                                      color: p.ink1)),
                            ),
                          ]),
                    ),

                  // ---- the sit, where the session asks for one --------------
                  if (s.sitSeconds case final seconds?) ...[
                    const SizedBox(height: 18),
                    // Kept for revert (2026-09-27): 'FIVE MINUTES' /
                    // 'TWO MINUTES', which named a length, not an action.
                    _label(
                        seconds >= 300
                            ? 'Sit for five minutes'
                            : 'Sit for two minutes',
                        p),
                    const SizedBox(height: 12),
                    TtcPracticeSession.sit(seconds: seconds),
                  ],

                  // ---- the practices this session teaches ------------------
                  //
                  // ⚠️ RESOLVED, NOT TRUSTED. A session naming a practice that
                  // has been renamed renders nothing rather than a heading over
                  // an empty box. Same wiring gate as the door's Do tiles.
                  for (final id in s.practiceIds)
                    if (ttcPracticeById(id) case final practice?) ...[
                      const SizedBox(height: 26),
                      _TaughtPractice(practice: practice, p: p),
                    ],

                  // ---- what the session asks you to keep -------------------
                  if (s.action == TtcCourseAction.setTimes) ...[
                    const SizedBox(height: 26),
                    _TimesBlock(p: p),
                  ],
                  if (s.action == TtcCourseAction.setMeals) ...[
                    const SizedBox(height: 26),
                    _MealsBlock(p: p),
                    const SizedBox(height: 16),
                    _GettingReadyLinks(p: p),
                  ],
                  if (s.action == TtcCourseAction.assemble) ...[
                    const SizedBox(height: 26),
                    _AssembleBlock(p: p),
                  ],

                  // ---- said plainly ----------------------------------------
                  //
                  // ⚠️ ALWAYS VISIBLE, NEVER BEHIND A TAP. The brief lists it
                  // with the step text and the timer as the part that has to
                  // work when there is no animation — and it is usually the
                  // sentence that lowers the stakes, which is the half somebody
                  // struggling most needs to see without looking for it.
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      // Kept for revert (2026-09-29, no tinted slab behind text): color: p.surfaceAlt,
                      color: p.surface, border: Border.fromBorderSide(BorderSide(color: p.line)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kept for revert (2026-09-27): 'SAID PLAINLY'
                          // at 9.5 in capitals.
                          Text('Said plainly',
                              style: pvManrope(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: p.ink2)),
                          const SizedBox(height: 6),
                          Text(s.saidPlainly,
                              style: pvManrope(
                                  fontSize: 13, height: 1.6, color: p.ink1)),
                        ]),
                  ),

                  if (s.number == 8) ...[
                    const SizedBox(height: 20),
                    Text(kTtcCourseSkipNote,
                        style: pvFraunces(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                            height: 1.55,
                            color: p.ink2)),
                  ],
                  const SizedBox(height: 12),
                ])),
          ],
        );
      },
    );
  }

  // Sentence-case labels (2026-09-27) read at 13.5 with no tracking; the old
  // style was 10.5 with 1.4 letter spacing, for capitals.
  static Widget _label(String s, V2Palette p) => Text(s,
      style: pvManrope(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: p.ink2));
}

/// One practice, played here, with its own card one tap away.
class _TaughtPractice extends StatelessWidget {
  const _TaughtPractice({required this.practice, required this.p});

  final TtcPractice practice;
  final V2Palette p;

  // ⚠️ THE SAME CARD AS ON TODAY, WITH THE PLAYER INSIDE IT (2026-09-28). It
  // was a loose title, a 12.5 blurb, the player and a line of bold coloured
  // text as the way to the full card: no edge, a third text size and a text
  // link. Now the practice's own tint (Move or Breathe, the colour of its
  // Today card), the chip, title, body and one quiet line of time and place,
  // the player, and a white pill to the full card. Headspace's course session
  // holds its technique in a card with the length under the title
  // (https://mobbin.com/screens/cda46030-4c2b-4b7c-b6f1-6e08db0ddf96).
  // The white pill, not the ink one: the player's Start is this card's main
  // action. The loose layout is `_buildLoose`, kept for revert.
  @override
  Widget build(BuildContext context) {
    final move = practice.kind == TtcPracticeKind.move;
    final tint = v2BlockTint(move ? kTtcMoveHue : kTtcBreatheHue, p);
    return Container(
      width: double.infinity,
      padding: kTtcCardPad,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(kTtcCardRadius),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TtcCardChip(
            label: move ? 'Move' : 'Breathe',
            icon: move ? Icons.self_improvement_rounded : Icons.air_rounded,
            fg: ttcCardDeep(tint),
            bg: Colors.white.withValues(alpha: 0.82)),
        const SizedBox(height: 14),
        Text(practice.title, style: ttcCardTitle(p)),
        const SizedBox(height: 6),
        Text(practice.blurb, style: ttcCardBody(p)),
        const SizedBox(height: 10),
        Text('${practice.duration} · ${practice.setting}',
            style: ttcCardMeta(p)),
        const SizedBox(height: 16),
        TtcPracticeSession(practice: practice),
        const SizedBox(height: 16),
        // ⚠️ THE FULL CARD IS ONE TAP AWAY AND IS NOT COPIED HERE (below).
        TtcQuietPill(
          label: 'The full steps, and when to skip it',
          icon: Icons.format_list_numbered_rounded,
          onTap: () => openTtcSurface(context, 'ttc_practice/${practice.id}'),
        ),
      ]),
    );
  }

  // Kept for revert (2026-09-28). Nothing calls it.
  // ignore: unused_element
  Widget _buildLoose(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(practice.title,
            style: pvFraunces(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.25,
                color: p.ink1)),
        const SizedBox(height: 5),
        Text(practice.blurb,
            style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink2)),
        const SizedBox(height: 16),
        TtcPracticeSession(practice: practice),
        const SizedBox(height: 12),
        // ⚠️ THE FULL CARD IS ONE TAP AWAY AND IS NOT COPIED HERE. The steps and
        // the "skip it if" live on the practice card; reprinting them inside the
        // session is the second copy the whole area is built to avoid.
        GestureDetector(
          onTap: () =>
              openTtcSurface(context, 'ttc_practice/${practice.id}'),
          behavior: HitTestBehavior.opaque,
          // ⚠️ `Flexible`, AND IT IS NOT DEFENSIVE PADDING. A centred Row of a
          // Text and an icon overflows the moment the text is wider than the
          // page — which happens at the larger accessibility sizes, and which
          // the widget test caught first because its own font is wider than
          // Manrope. A caught overflow here is a yellow-striped bar across the
          // one link out of the session.
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
              child: Text('The full steps, and when to skip it',
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: p.action)),
            ),
            const SizedBox(width: 5),
            Icon(Icons.arrow_forward_rounded, size: 14, color: p.action),
          ]),
        ),
      ]);
}

// =============================================================================
//  Session 5 — one wake time and one sleep time
// =============================================================================

class _TimesBlock extends StatelessWidget {
  const _TimesBlock({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final store = TtcGarbhCourseStore.instance;
    return _Keep(
      p: p,
      heading: 'Your two times',
      blurb: 'Pick your wake time first, because work usually decides it. '
          "Count back about eight hours, and that's your bedtime.",
      children: [
        _TimeRow(
          p: p,
          label: 'Wake',
          value: store.wakeTime,
          fallback: kTtcDefaultWake,
          onPick: (t) => store.setTimes(wake: t),
        ),
        _TimeRow(
          p: p,
          label: 'In bed by',
          value: store.bedtime,
          fallback: kTtcDefaultBed,
          onPick: (t) => store.setTimes(bed: t),
        ),
      ],
    );
  }
}

// =============================================================================
//  Session 6 — the regular meal times
// =============================================================================

class _MealsBlock extends StatefulWidget {
  const _MealsBlock({required this.p});
  final V2Palette p;

  @override
  State<_MealsBlock> createState() => _MealsBlockState();
}

class _MealsBlockState extends State<_MealsBlock> {
  static const _names = ['Breakfast', 'Lunch', 'Dinner'];

  @override
  Widget build(BuildContext context) {
    final store = TtcGarbhCourseStore.instance;
    final meals = store.meals;

    return _Keep(
      p: widget.p,
      heading: 'Your regular meal times',
      // ⚠️ TIMES, NOT FOOD, AND THAT IS THE WHOLE BOUNDARY. The session teaches
      // that sattvik means regular and home-cooked; WHAT to eat is owned by
      // Getting ready and is linked below rather than restated here.
      blurb: 'Regular matters more than perfect. Eating at the same three '
          'times on most days is all this asks.',
      children: [
        for (var i = 0; i < _names.length; i++)
          _TimeRow(
            p: widget.p,
            label: _names[i],
            value: i < meals.length && meals[i].isNotEmpty ? meals[i] : null,
            fallback: kTtcDefaultMeals[i],
            onPick: (t) {
              final next = [
                for (var j = 0; j < _names.length; j++)
                  j == i ? t : (j < meals.length ? meals[j] : ''),
              ];
              store.setMeals(next);
              setState(() {});
            },
          ),
      ],
    );
  }
}

/// The three pages in Getting ready that own the specifics.
class _GettingReadyLinks extends StatelessWidget {
  const _GettingReadyLinks({required this.p});
  final V2Palette p;

  static const _links = [
    ('What to eat before you start', 'ttc_read_three_months_before'),
    ('Folic acid, and when to start it', 'ttc_read_folic_acid'),
    ('Vitamin D, B12 and iron', 'ttc_read_supplement_timing'),
  ];

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kept for revert (2026-09-27): 'THE DETAILS ARE IN GETTING READY'.
        Text('What to eat: read more',
            style: pvManrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: p.ink2)),
        const SizedBox(height: 10),
        for (final (title, readId) in _links)
          GestureDetector(
            onTap: () => openTtcSurface(context, 'ttc_read/$readId'),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Icon(Icons.article_outlined, size: 15, color: p.ink3),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: pvManrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: p.ink1)),
                ),
                Icon(Icons.arrow_forward_rounded, size: 15, color: p.ink3),
              ]),
            ),
          ),
      ]);
}

// =============================================================================
//  Session 8 — the assembly, and the write into Today
// =============================================================================

/// ⚠️ THE BRIEF CALLS THIS *"the single most important build detail in this
/// course"*: the course must end by PRODUCING her practice rather than by
/// playing a closing video. So the last thing on the last session is a form
/// that writes into Today, and under it, Today itself.
class _AssembleBlock extends StatefulWidget {
  const _AssembleBlock({required this.p});
  final V2Palette p;

  @override
  State<_AssembleBlock> createState() => _AssembleBlockState();
}

class _AssembleBlockState extends State<_AssembleBlock> {
  String? _move;
  String? _breathe;
  TtcCoupleDaily? _couple;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    // Prefilled from whatever she set last time, so redoing session 8 to change
    // one answer does not mean re-entering the other three.
    final store = TtcGarbhCourseStore.instance;
    _move = store.moveId;
    _breathe = store.breatheId;
    _couple = store.couple;
    _saved = store.hasPractice;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final store = TtcGarbhCourseStore.instance;
    // Kept for revert (2026-09-29), with `deep` below:
    //   final tint = v2BlockTint(kTtcCourseHue, p);
    // Kept for revert (2026-09-29): the button below was filled with the
    // course hue's deep tone; it is the one ink now, so this is unused.
    //   final deep = HSLColor.fromColor(tint)
    //       .withSaturation(0.44)
    //       .withLightness(0.36)
    //       .toColor();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Keep(
        p: p,
        heading: 'Your five minutes',
        blurb: 'Pick the parts you liked. Nothing is set for you, and leaving '
            'one of these blank is a fine answer.',
        children: [
          const SizedBox(height: 4),
          _pickerLabel('The breathing you liked best', p),
          for (final pr in ttcPracticesOfKind(TtcPracticeKind.breathe))
            _Pick(
              p: p,
              label: pr.title,
              meta: pr.duration,
              on: _breathe == pr.id,
              onTap: () => setState(
                  () => _breathe = _breathe == pr.id ? null : pr.id),
            ),
          const SizedBox(height: 16),
          _pickerLabel("The movement you'll really do", p),
          for (final pr in ttcPracticesOfKind(TtcPracticeKind.move))
            _Pick(
              p: p,
              label: pr.title,
              meta: pr.duration,
              on: _move == pr.id,
              onTap: () =>
                  setState(() => _move = _move == pr.id ? null : pr.id),
            ),
          const SizedBox(height: 16),
          // ⚠️ "OR NEITHER" IS AN OPTION AND IS SPELLED OUT. The brief offers it
          // and a two-choice list with no way to decline is not the same
          // question. Tapping a lit row turns it off.
          _pickerLabel('And one thing together, or neither', p),
          _Pick(
            p: p,
            label: 'One thing you like about the other',
            meta: 'Gratitude',
            on: _couple == TtcCoupleDaily.gratitude,
            onTap: () => setState(() => _couple =
                _couple == TtcCoupleDaily.gratitude
                    ? null
                    : TtcCoupleDaily.gratitude),
          ),
          _Pick(
            p: p,
            label: 'One honest question, and just listen',
            meta: 'Conversation',
            on: _couple == TtcCoupleDaily.conversation,
            onTap: () => setState(() => _couple =
                _couple == TtcCoupleDaily.conversation
                    ? null
                    : TtcCoupleDaily.conversation),
          ),
        ],
      ),

      const SizedBox(height: 16),
      // ---- confirm what sessions 5 and 6 already set ------------------------
      _Keep(
        p: p,
        // Kept for revert (2026-09-27): 'AND CONFIRM THESE'.
        heading: 'Check your times',
        blurb: 'You set these in sessions five and six. Change either one '
            'here if it no longer fits.',
        children: [
          _TimeRow(
            p: p,
            label: 'Wake',
            value: store.wakeTime,
            fallback: kTtcDefaultWake,
            onPick: (t) => store.setTimes(wake: t),
          ),
          _TimeRow(
            p: p,
            label: 'In bed by',
            value: store.bedtime,
            fallback: kTtcDefaultBed,
            onPick: (t) => store.setTimes(bed: t),
          ),
          if (store.meals.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('Meals at ${store.meals.where((m) => m.isNotEmpty).join(', ')}',
                  style: pvManrope(
                      fontSize: 12.5, height: 1.5, color: p.ink2)),
            ),
        ],
      ),

      // WHAT TODAY WILL SHOW, BEFORE SHE SAVES (tools pass, 2026-09-27). The
      // live Today appeared only after the tap, so the button asked her to
      // commit to something she had not seen.
      const SizedBox(height: 18),
      _TodayPreview(
          p: p, moveId: _move, breatheId: _breathe, couple: _couple),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () {
          store.setDailyPractice(
              moveId: _move, breatheId: _breathe, couple: _couple);
          setState(() => _saved = true);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ttcTitleInk,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(_saved ? 'Update my daily practice' : 'Set as my daily practice',
              style: pvManrope(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ),
      ),

      // ---- and here it is ---------------------------------------------------
      //
      // ⚠️ THE REAL TODAY TAB, NOT A PICTURE OF ONE. `TtcMindTodayBody` is the
      // exact widget the door renders, so what she sees here is what she will
      // open tomorrow — including the ticks, which are live. A mock-up would
      // have been easier and would drift the first time Today changed.
      if (_saved) ...[
        const SizedBox(height: 26),
        // Kept for revert (2026-09-27): 'THIS IS NOW YOUR TODAY'.
        // Kept for revert (2026-09-28): 'This is now your Today'.
        Text('Your practice is now on Today',
            style: pvManrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: p.ink2)),
        const SizedBox(height: 6),
        Text('Mind & body opens on this. Nothing here keeps count.',
            style: pvManrope(fontSize: 12.5, height: 1.6, color: p.ink3)),
        const SizedBox(height: 4),
        // ⚠️ `padded: false`, AND IT IS NOT A STYLE CHOICE. Today insets itself
        // to 18 because it normally sits straight in a focus sheet; here it is
        // already inside this screen's own 18, and two nested gutters turn it
        // into a narrow column down the middle of the page.
        const TtcMindTodayBody(padded: false),
      ],
    ]);
  }

  static Widget _pickerLabel(String s, V2Palette p) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(s,
            style: pvManrope(
                fontSize: 12.5, fontWeight: FontWeight.w800, color: p.ink2)),
      );
}

class _Pick extends StatelessWidget {
  const _Pick(
      {required this.p,
      required this.label,
      required this.meta,
      required this.on,
      required this.onTap});

  final V2Palette p;
  final String label;
  final String meta;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 130),
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? ttcTitleInk : Colors.transparent,
                shape: BoxShape.circle,
                border: on ? null : Border.all(color: p.line, width: 1.6),
              ),
              child: on
                  ? const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: pvManrope(
                      fontSize: 13.5,
                      height: 1.4,
                      fontWeight: on ? FontWeight.w700 : FontWeight.w400,
                      color: p.ink1)),
            ),
            const SizedBox(width: 8),
            Text(meta,
                style: pvManrope(
                    fontSize: 11, fontWeight: FontWeight.w700, color: p.ink3)),
          ]),
        ),
      );
}

/// One line of what Today will show once she saves, from her picks so far.
class _TodayPreview extends StatelessWidget {
  const _TodayPreview(
      {required this.p,
      required this.moveId,
      required this.breatheId,
      required this.couple});

  final V2Palette p;
  final String? moveId;
  final String? breatheId;
  final TtcCoupleDaily? couple;

  @override
  Widget build(BuildContext context) {
    final b = breatheId == null ? null : ttcPracticeById(breatheId!);
    final m = moveId == null ? null : ttcPracticeById(moveId!);
    final parts = <String>[
      ?b?.title,
      ?m?.title,
      if (couple == TtcCoupleDaily.gratitude)
        'One thing you like about the other',
      if (couple == TtcCoupleDaily.conversation)
        'One honest question, and just listen',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        // Kept for revert (2026-09-29, no tinted slab behind text): color: p.surfaceAlt,
        color: p.surface, border: Border.fromBorderSide(BorderSide(color: p.line)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
          parts.isEmpty
              ? 'Nothing picked yet. If you save now, Today goes on showing a '
                  'different card each day.'
              : 'Your Today will show: ${parts.join(', ')}.',
          style: pvManrope(
              fontSize: 12.5,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: p.ink1)),
    );
  }
}

// =============================================================================
//  Small shared pieces
// =============================================================================

class _Panel extends StatelessWidget {
  const _Panel(
      {required this.p,
      required this.tint,
      required this.heading,
      required this.body});

  final V2Palette p;
  final Color tint;
  final String heading;
  final String body;

  // The card family (2026-09-28): its inset, corner, title and body, so the
  // session's notes and its practices are one kind of object. Kept for
  // revert: padding all(15), radius 18, heading bold Manrope 13 ink1, the
  // body Manrope 13 ink1 at 1.65.
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: kTtcCardPad,
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(kTtcCardRadius),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(heading, style: ttcCardTitle(p)),
          const SizedBox(height: 6),
          Text(body, style: ttcCardBody(p)),
        ]),
      );
}

/// A bordered block for the things a session asks you to keep.
class _Keep extends StatelessWidget {
  const _Keep(
      {required this.p,
      required this.heading,
      required this.blurb,
      required this.children});

  final V2Palette p;
  final String heading;
  final String blurb;
  final List<Widget> children;

  // The card family's inset, corner, title and body (2026-09-28). White with
  // a hairline still: these hold controls (times, picks), not a practice.
  // Kept for revert: padding all(15), radius 18, heading bold Manrope 13,
  // blurb Manrope 12.5.
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: kTtcCardPad,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(kTtcCardRadius),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(heading, style: ttcCardTitle(p)),
          const SizedBox(height: 6),
          Text(blurb, style: ttcCardBody(p)),
          const SizedBox(height: 12),
          ...children,
        ]),
      );
}

/// Where an empty clock opens, per row (tools pass, 2026-09-27).
///
/// A STARTING POINT FOR THE CLOCK, NEVER A SAVED VALUE. Every empty row used
/// to open at 23:00, which is right for bed and means scrolling from 11 pm to
/// 7 am for "Wake". Nothing is stored until she picks, and a cancelled picker
/// still stores nothing.
const TimeOfDay kTtcDefaultWake = TimeOfDay(hour: 6, minute: 30);
const TimeOfDay kTtcDefaultBed = TimeOfDay(hour: 23, minute: 0);
const List<TimeOfDay> kTtcDefaultMeals = [
  TimeOfDay(hour: 8, minute: 0), // breakfast
  TimeOfDay(hour: 13, minute: 0), // lunch
  TimeOfDay(hour: 20, minute: 0), // dinner
];

class _TimeRow extends StatelessWidget {
  const _TimeRow(
      {required this.p,
      required this.label,
      required this.value,
      required this.fallback,
      required this.onPick});

  final V2Palette p;
  final String label;
  final String? value;

  /// Where the clock opens when nothing is set yet.
  final TimeOfDay fallback;
  final void Function(String) onPick;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () async {
          final t = await showTimePicker(
            context: context,
            // Kept for revert (2026-09-27):
            //   initialTime: _parse(value) ?? const TimeOfDay(hour: 23, minute: 0),
            initialTime: _parse(value) ?? fallback,
          );
          if (t == null) return;
          onPick(
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(children: [
            Expanded(
              child: Text(label,
                  style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: p.ink1)),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(999),
              ),
              // An empty row says it opens a clock: an icon and "Set time"
              // instead of a bare "Set" (2026-09-27).
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.schedule_rounded,
                    size: 14, color: value == null ? ttcTitleInk : p.ink3),
                const SizedBox(width: 5),
                Text(value ?? 'Set time',
                    style: pvManrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: value == null ? ttcTitleInk : p.ink1)),
              ]),
            ),
          ]),
        ),
      );

  static TimeOfDay? _parse(String? hhmm) {
    if (hhmm == null) return null;
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }
}
