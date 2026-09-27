// =============================================================================
//  Cycle Companion — rebuilt from the "Cycle Companion" design project
// -----------------------------------------------------------------------------
//      "Cycle Companion. Not called Cycle Tracker. Purpose: understand
//       patterns. Not predict perfection."            — TTC master spec §3.4
//
//  ⚠️ A NEW FRONT ON A SCREEN TWELVE PLACES ALREADY OPEN. Surface id
//  `ttc_cycle`, reached from the TTC home (four call sites), the fertility-help
//  screen, the PCOS door's Track group, a hub, two journey steps and two
//  brackets. Nothing is renamed and nothing moves — `TtcCycleScreen` in
//  `ttc_cycle_screens.dart` is still the entry and simply delegates here.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT THIS REPLACED, AND WHY THE REPLACEMENT IS MOSTLY REUSE
//  ---------------------------------------------------------------------------
//
//  The old screen was two numbers and a list: an average, a range, and the
//  logged dates. It had no picture of a cycle anywhere on it, never showed the
//  symptoms, temperatures or LH strips already stored, and — the sharpest gap —
//  did not link to the cycle report at all. Someone who opened it to understand
//  her pattern was standing next to the answer and could not see it.
//
//  Almost nothing here is new drawing. The ring is `TtcCycleRing`, built for
//  the report and approved there; the four stretches come from
//  `ttcCyclePhaseSpans`; the colours are `ttcPhaseBand` / `ttcPhaseMark` /
//  `ttcPhaseInk`. Asked for directly: *"we already have ring colors, so use
//  what we have"*. Two screens drawing one cycle from one source cannot
//  disagree about it, which is the whole reason the report's parts were made
//  public rather than private to it.
//
//  ---------------------------------------------------------------------------
//  ⚠️ FOUR STATES, AND THE TWO QUIET ONES ARE NOT EDGE CASES
//  ---------------------------------------------------------------------------
//
//  healthy · empty · no-estimate · clinic-held. The last two are refusals, and
//  they are common: someone three dates in, or on a clinic-run cycle, sees one
//  of them every single time. They are designed as real screens — her data
//  still shows, only the estimate is withheld, and the reason is said in plain
//  words. A refusal that looks like an error teaches her the app is broken; a
//  refusal that looks like a gap teaches her it is unfinished.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/cycle_store.dart';
import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_cycle_report.dart';
import '../../ttc/ttc_store.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_hero_field.dart';
import 'ttc_common.dart';
import 'ttc_cycle_report_screen.dart';
import 'ttc_cycle_report_v3.dart';
import 'ttc_home_gap.dart' show showTtcPeriodCameNudge;
import 'ttc_phase_colours.dart';
import 'ttc_strings.dart';

/// Which of the four the screen is in.
///
/// ⚠️ DERIVED, NEVER STORED. The same question the report answers with
/// `TtcReportState`, asked here because this screen refuses on the same terms
/// and must not be able to disagree about when.
enum TtcCompanionState { empty, noEstimate, clinicHeld, healthy }

/// Ring or day-grid. Not remembered between visits — she picks a picture to
/// answer the question in front of her, not to declare a preference.
enum TtcCompanionPicture { ring, days }

class TtcCycleCompanionScreen extends StatefulWidget {
  const TtcCycleCompanionScreen({super.key});

  @override
  State<TtcCycleCompanionScreen> createState() =>
      _TtcCycleCompanionScreenState();
}

class _TtcCycleCompanionScreenState extends State<TtcCycleCompanionScreen> {
  TtcCompanionPicture _picture = TtcCompanionPicture.ring;

  /// The row currently slid open. One at a time, so a half-open row cannot be
  /// left behind another one.
  DateTime? _openRow;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge(
            [CycleStore.instance, TtcStore.instance, TtcLang.instance]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final t = TtcS.current();
          final cycle = CycleStore.instance;
          final store = TtcStore.instance;
          const engine = TtcChapterEngine();
          final state = store.state();

          final spans = ttcCyclePhaseSpans();
          final TtcCompanionState screen;
          if (cycle.periodStarts.isEmpty) {
            screen = TtcCompanionState.empty;
          } else if (!store.today.behaviour.showsFertilityWindow) {
            screen = TtcCompanionState.clinicHeld;
          } else if (spans.isEmpty || engine.hasUnreliableHistory(state)) {
            screen = TtcCompanionState.noEstimate;
          } else {
            screen = TtcCompanionState.healthy;
          }

          return Scaffold(
            backgroundColor: p.ground,
            body: Stack(children: [
              Positioned.fill(
                child: V3HeroField(
                  accent: v2BlockTint(kTtcCompanionHue, p),
                  ground: p.ground,
                  variant: switch (screen) {
                    TtcCompanionState.healthy => 2,
                    TtcCompanionState.empty => 4,
                    _ => 1,
                  },
                  chroma: v3FieldChroma(kTtcCompanionHue),
                ),
              ),
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  _Hero(p: p, screen: screen, spans: spans),
                  _CompanionSheet(
                    p: p,
                    t: t,
                    screen: screen,
                    spans: spans,
                    picture: _picture,
                    openRow: _openRow,
                    onPicture: (v) => setState(() => _picture = v),
                    onOpenRow: (d) => setState(() => _openRow = d),
                  ),
                ],
              ),
            ]),
          );
        },
      );
}

/// The area's own hue. 288 — the same violet-magenta PCOS wears, because the
/// PCOS door is where most people meet this tool.
const double kTtcCompanionHue = 288;

// =============================================================================
//  The hero
// =============================================================================

class _Hero extends StatelessWidget {
  const _Hero({required this.p, required this.screen, required this.spans});

  final V2Palette p;
  final TtcCompanionState screen;
  final List<TtcPhaseSpan> spans;

  @override
  Widget build(BuildContext context) {
    final today = TtcStore.instance.today;
    final here = spans.where((s) => s.status == TtcSpanStatus.here).firstOrNull;

    final (String title, String line) = switch (screen) {
      TtcCompanionState.empty => (
          'One date to start',
          'Get to know your own pattern, at your own pace.',
        ),
      TtcCompanionState.clinicHeld => (
          today.cycleDay == null ? 'Your cycle' : 'Cycle day ${today.cycleDay}',
          'Your clinic is guiding this cycle.',
        ),
      TtcCompanionState.noEstimate => (
          today.cycleDay == null ? 'Your cycle' : 'Cycle day ${today.cycleDay}',
          "No estimate this month. That's on purpose.",
        ),
      TtcCompanionState.healthy => (
          here?.phase.label ?? 'Your cycle',
          here == null
              ? 'Here to understand, not to predict.'
              : '${ttcShortDate(here.firstDay)} to ${ttcShortDate(here.lastDay)}'
                  ' · here to understand, not to predict',
        ),
    };

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              _BackArrow(p: p),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Cycle Companion',
                    style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: p.ink1)),
              ),
              // ⚠️ THE CHIP CARRIES THE RAW CYCLE DAY, and it is the only place
              // on the screen that does. The engine calls it backend truth and
              // warns against rendering it in the calm surfaces; a small chip
              // beside the title is the compromise the stage already uses — it
              // is there for the woman who counts, and ignorable by the one who
              // does not.
              if (today.cycleDay != null &&
                  screen != TtcCompanionState.empty) ...[
                const SizedBox(width: 10),
                _SpineChip(p: p, label: 'Cycle day ${today.cycleDay}'),
              ],
            ]),
            const SizedBox(height: 26),
            Text(title,
                style: pvFraunces(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    height: 1.12,
                    letterSpacing: -0.9,
                    color: p.ink1)),
            const SizedBox(height: 8),
            Text(line,
                style: pvManrope(fontSize: 14, height: 1.5, color: p.ink1)),
          ],
        ),
      ),
    );
  }
}

/// A bare arrow, not a chip.
///
/// ⚠️ NO CIRCLE, AND THE FIRST CUT HAD ONE. `ttc_chrome_test.dart` states the
/// rule and the reason — *"the circle was the thing that made it look invented.
/// Nothing in the pregnancy stage draws one."* — and the design agrees: a plain
/// chevron, no well behind it. The V3 tool chrome does use a round translucent
/// close, but that is a CLOSE on a screen you opened as a sheet, not a BACK on
/// a screen you navigated to, and the two are different promises.
///
/// It is `Icons.arrow_back` rather than the rounded variant so the whole stage
/// answers one finder. That is not pedantry: the chrome test taps
/// `find.byIcon(Icons.arrow_back)` on whatever the Tools hub opens first, and a
/// screen that quietly picked the rounded glyph made it untappable.
class _BackArrow extends StatelessWidget {
  const _BackArrow({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Back',
        child: InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(Icons.arrow_back, size: 22, color: p.ink1),
          ),
        ),
      );
}

class _SpineChip extends StatelessWidget {
  const _SpineChip({required this.p, required this.label});
  final V2Palette p;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label,
            style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: p.ink1)),
      );
}

/// "22 Aug".
String ttcShortDate(DateTime d) {
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${m[d.month - 1]}';
}

/// "22 August 2026".
String ttcLongDate(DateTime d) {
  const m = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

// =============================================================================
//  The sheet — one of four bodies over the same field
// =============================================================================

class _CompanionSheet extends StatelessWidget {
  const _CompanionSheet({
    required this.p,
    required this.t,
    required this.screen,
    required this.spans,
    required this.picture,
    required this.openRow,
    required this.onPicture,
    required this.onOpenRow,
  });

  final V2Palette p;
  final TtcS t;
  final TtcCompanionState screen;
  final List<TtcPhaseSpan> spans;
  final TtcCompanionPicture picture;
  final DateTime? openRow;
  final ValueChanged<TtcCompanionPicture> onPicture;
  final ValueChanged<DateTime?> onOpenRow;

  @override
  Widget build(BuildContext context) => Container(
        // ⚠️ A FULL SCREEN MINIMUM. The empty and refusal bodies are short, and
        // a sheet that stops before the fold leaves the field showing under the
        // last card — the same bug the grouped focus page hit, for the same
        // reason.
        constraints:
            BoxConstraints(minHeight: MediaQuery.sizeOf(context).height),
        decoration: BoxDecoration(
          color: p.ground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, -6)),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(18, 24, 18, ttcBottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: switch (screen) {
            TtcCompanionState.empty => _empty(context),
            TtcCompanionState.healthy => _healthy(context),
            _ => _refusal(context),
          },
        ),
      );

  // ---------------------------------------------------------------------------
  //  Healthy
  // ---------------------------------------------------------------------------
  List<Widget> _healthy(BuildContext context) => [
        _Eyebrow('Where you are', p: p),
        const SizedBox(height: 12),
        _ThisCycleCard(
          p: p,
          spans: spans,
          picture: picture,
          onPicture: onPicture,
        ),
        const SizedBox(height: 28),
        _Eyebrow('Your rhythm', p: p),
        const SizedBox(height: 12),
        _RhythmCard(p: p),
        const SizedBox(height: 28),
        ..._dates(context),
        const SizedBox(height: 24),
        _Estimates(p: p),
      ];

  // ---------------------------------------------------------------------------
  //  Empty
  // ---------------------------------------------------------------------------
  List<Widget> _empty(BuildContext context) => [
        TtcCard(
          child: Column(children: [
            Text('Your rhythm starts with one date',
                textAlign: TextAlign.center,
                style: ttcFraunces(19,
                    w: FontWeight.w600, color: ttcTitleInk, h: 1.25)),
            const SizedBox(height: 9),
            Text(
                'Tell us the day your last period started. With that one date '
                "we can show your cycle day, every day.",
                textAlign: TextAlign.center,
                style: ttcBody(13.5, h: 1.55)),
            const SizedBox(height: 18),
            _QuietAction(
                label: 'Add a period date',
                onTap: () => showTtcPeriodLogSheet(context)),
          ]),
        ),
        const SizedBox(height: 28),
        _Eyebrow('What each date gives you', p: p),
        const SizedBox(height: 12),
        // ⚠️ THE LADDER IS THE INVITATION, AND IT IS HONEST ABOUT COST. Most
        // empty states say "add data and something happens". This says exactly
        // what each date buys, so the first one is a small ask with a named
        // reward rather than the start of an open-ended chore.
        _Fact(p: p, label: 'After one date', value: 'Your cycle day, every day'),
        const SizedBox(height: 10),
        _Fact(p: p, label: 'After two', value: 'Your usual cycle length'),
        const SizedBox(height: 10),
        _Fact(
            p: p,
            label: 'After three',
            value: 'The spread, and a picture of the whole cycle'),
        const SizedBox(height: 20),
        Text(
            "Nothing here is shared with anyone. You can remove a date any "
            'time you like.',
            style: ttcBody(13, h: 1.5)),
        const SizedBox(height: 24),
        _Estimates(p: p),
      ];

  // ---------------------------------------------------------------------------
  //  The two refusals
  // ---------------------------------------------------------------------------
  List<Widget> _refusal(BuildContext context) {
    final clinic = screen == TtcCompanionState.clinicHeld;
    // ⚠️ ONE OR THE OTHER, NEVER BOTH. The refusal card's placeholder and the
    // rhythm section below carry the same label, so showing them together put
    // "YOUR RHYTHM" on the screen twice — once over an explanation and once
    // over the numbers it was explaining the absence of. The placeholder is for
    // the case where there ARE no numbers.
    final showsRhythm =
        !TtcChapterEngine().hasUnreliableHistory(TtcStore.instance.state()) &&
            CycleStore.instance.cycleLengths.isNotEmpty;
    return [
      _Eyebrow(
          clinic ? 'Who is guiding this cycle' : "Why there's no picture yet",
          p: p),
      const SizedBox(height: 12),
      TtcCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              clinic
                  ? 'Your clinic is tracking this cycle'
                  : "We're not drawing this cycle",
              style: ttcFraunces(20,
                  w: FontWeight.w600, color: ttcTitleInk, h: 1.22)),
          const SizedBox(height: 10),
          // ⚠️ IT SAYS WHY, IN HER TERMS, AND NEVER APOLOGISES. A refusal
          // phrased as a shortcoming teaches her the app is broken; phrased as
          // a deferral it teaches her the app knows the difference between what
          // it can see and what it cannot.
          Text(
              clinic
                  ? 'Your fertility clinic is following your dates this month. '
                      "When a doctor is guiding you, we don't put our own "
                      'estimate next to theirs.'
                  : 'One gap in your dates is so long that it was probably a '
                      "month that wasn't logged, not a cycle that long.",
              style: ttcBody(14, h: 1.55)),
          const SizedBox(height: 10),
          Text(
              clinic
                  ? "Everything you log here stays yours, and we'll keep it "
                      'ready for your next visit.'
                  : "Guessing from it would give you dates we don't trust, "
                      "so we're waiting instead. Irregular cycles are common, "
                      "and they're nothing you did wrong.",
              style: ttcBody(14, h: 1.55)),
          if (!showsRhythm) ...[
            const SizedBox(height: 16),
            _Fact(
              p: p,
              label: 'Your rhythm',
              placeholder: clinic
                  ? 'While your clinic is guiding this cycle, the dates are '
                      'theirs.'
                  : 'Once you log your next period, the picture comes back.',
            ),
          ],
          const SizedBox(height: 16),
          _QuietAction(
            label: 'See your logged months in full',
            onTap: () => _openReport(context),
          ),
        ]),
      ),
      // ⚠️ HER RHYTHM SURVIVES A REFUSAL, AND THE FIRST CUT OF THIS GOT IT
      // WRONG. Refusing to draw THIS cycle is not the same as refusing to state
      // her history: an overdue cycle stops the estimate dead, and her last
      // four cycle lengths are exactly as true the day it goes overdue as they
      // were the day before. Withholding them would be the app sulking.
      //
      // The one case where they really are unsafe is a history the engine has
      // called untrustworthy — a 54-day gap that was an unlogged month — and
      // there the numbers are withheld, which is the behaviour the screen this
      // replaced already had right.
      if (showsRhythm) ...[
        const SizedBox(height: 28),
        _Eyebrow('Your rhythm', p: p),
        const SizedBox(height: 12),
        _RhythmCard(p: p),
      ],
      const SizedBox(height: 28),
      ..._dates(context),
      const SizedBox(height: 24),
      _Estimates(p: p),
    ];
  }

  // ---------------------------------------------------------------------------
  //  Her dates — shared by healthy and both refusals
  // ---------------------------------------------------------------------------
  List<Widget> _dates(BuildContext context) {
    final starts = [...CycleStore.instance.periodStarts]..sort();
    return [
      Row(children: [
        Expanded(child: _Eyebrow('Your dates', p: p)),
        GestureDetector(
          onTap: () => showTtcPeriodLogSheet(context),
          behavior: HitTestBehavior.opaque,
          child: Text('Add a date',
              style: ttcBody(13, color: ttcTitleInk, w: FontWeight.w800)),
        ),
      ]),
      const SizedBox(height: 6),
      Text('Swipe a row left to fix or remove it.',
          style: ttcBody(13, h: 1.45)),
      const SizedBox(height: 12),
      for (var i = starts.length - 1; i >= 0; i--) ...[
        _DateRow(
          p: p,
          start: starts[i],
          previous: i > 0 ? starts[i - 1] : null,
          isCurrent: i == starts.length - 1,
          open: openRow != null && _sameDay(openRow!, starts[i]),
          onOpen: (v) => onOpenRow(v ? starts[i] : null),
        ),
        const SizedBox(height: 10),
      ],
    ];
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

void _openReport(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'ttc/cycle_report'),
      builder: (_) => const TtcCycleReportScreen(),
    ));

// =============================================================================
//  This cycle — the picture, the four stretches, and the way into the report
// =============================================================================

class _ThisCycleCard extends StatelessWidget {
  const _ThisCycleCard({
    required this.p,
    required this.spans,
    required this.picture,
    required this.onPicture,
  });

  final V2Palette p;
  final List<TtcPhaseSpan> spans;
  final TtcCompanionPicture picture;
  final ValueChanged<TtcCompanionPicture> onPicture;

  @override
  Widget build(BuildContext context) {
    final ring = picture == TtcCompanionPicture.ring;
    return TtcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text('This cycle',
                style: ttcFraunces(16.5,
                    w: FontWeight.w600, color: ttcTitleInk)),
          ),
          _Segmented(
            left: 'Ring',
            right: 'Days',
            rightOn: !ring,
            onPick: (r) => onPicture(
                r ? TtcCompanionPicture.days : TtcCompanionPicture.ring),
          ),
        ]),
        const SizedBox(height: 10),
        if (ring)
          TtcCycleRing(spans: spans, today: DateTime.now())
        else
          _DaysGrid(spans: spans),
        const SizedBox(height: 14),
        ttcDivider(),
        const SizedBox(height: 4),
        // ⚠️ THE ROWS ARE THE LEGEND AND THE LEGEND IS THE CONTENT. Four
        // coloured squares with names alone would explain the picture; these
        // also carry the dates and the lengths, which is the thing she actually
        // came to read. A legend that is only a legend is a caption nobody
        // needs twice.
        for (final s in spans) _StretchRow(span: s),
        const SizedBox(height: 4),
        ttcDivider(),
        const SizedBox(height: 8),
        // ⚠️ THE WAY INTO THE REPORT HANGS OFF THE PICTURE, NOT OFF THE PAGE.
        // The picture IS this month; the report is the same month with
        // everything she logged laid over it. Chosen over a card at the foot of
        // the scroll, which is exactly where this link used to live on the
        // logging screen and exactly why nobody found it.
        InkWell(
          onTap: () => _openReport(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Expanded(
                child: Text('See this month in full',
                    style: ttcBody(13,
                        color: ttcTitleInk, w: FontWeight.w800)),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: ttcTitleInk),
            ]),
          ),
        ),
        Text('These dates are estimates, worked out from your own past cycles.',
            style: ttcBody(13, h: 1.45)),
      ]),
    );
  }
}

class _StretchRow extends StatelessWidget {
  const _StretchRow({required this.span});
  final TtcPhaseSpan span;

  @override
  Widget build(BuildContext context) {
    final here = span.status == TtcSpanStatus.here;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: ttcPhaseMark(span.phase),
              borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(span.phase.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ttcBody(13,
                  color: ttcTitleInk,
                  w: here ? FontWeight.w800 : FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Text('${ttcShortDate(span.firstDay)} – ${ttcShortDate(span.lastDay)}',
            style: ttcBody(13, color: ttcSoft)),
        const SizedBox(width: 10),
        SizedBox(
          width: 48,
          child: Text('${span.days} days',
              textAlign: TextAlign.right,
              style: ttcBody(13, color: ttcMuted)),
        ),
      ]),
    );
  }
}

/// The cycle as real calendar weeks.
///
/// ⚠️ WEEKDAY-ALIGNED, WHICH IS WHY IT IS NOT `TtcCycleGrid`. The report's grid
/// runs cycle day 1..28 in order, which is the right shape for reading a cycle
/// as a cycle. This one has to sit under dates she recognises, so it starts on
/// the correct weekday and carries the month where it turns over. Same colours,
/// same spans, different question.
class _DaysGrid extends StatelessWidget {
  const _DaysGrid({required this.spans});
  final List<TtcPhaseSpan> spans;

  @override
  Widget build(BuildContext context) {
    if (spans.isEmpty) return const SizedBox.shrink();
    final first = spans.first.firstDay;
    final last = spans.last.lastDay;
    final today = DateTime.now();

    TtcPhase? phaseOn(DateTime d) {
      for (final s in spans) {
        if (!d.isBefore(s.firstDay) && !d.isAfter(s.lastDay)) return s.phase;
      }
      return null;
    }

    // Monday-first, which is what the weekday strip below assumes.
    final lead = (first.weekday - DateTime.monday) % 7;
    final cells = <Widget>[for (var i = 0; i < lead; i++) const SizedBox()];

    for (var d = first;
        !d.isAfter(last);
        d = DateTime(d.year, d.month, d.day + 1)) {
      cells.add(_DayCell(
        date: d,
        phase: phaseOn(d),
        isToday: _sameDay(d, today),
      ));
    }
    // ⚠️ ONE OUTLINED SQUARE FOR THE NEXT PERIOD, AND ONLY ONE. It is a date we
    // expect, not a date we know, so it is drawn as an absence — a dashed edge
    // with no fill — rather than as a fifth coloured stretch.
    cells.add(_DayCell(
      date: DateTime(last.year, last.month, last.day + 1),
      phase: null,
      isToday: false,
      expected: true,
    ));

    return Column(children: [
      Row(children: [
        for (final d in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
          Expanded(
            child: Text(d,
                textAlign: TextAlign.center,
                style: ttcBody(9.5,
                    color: ttcMuted, w: FontWeight.w800)),
          ),
      ]),
      const SizedBox(height: 6),
      GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        childAspectRatio: 1.05,
        children: cells,
      ),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: Text('Outlined square: when the next period is expected.',
            style: ttcBody(12.5, h: 1.35)),
      ),
    ]);
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.phase,
    required this.isToday,
    this.expected = false,
  });

  final DateTime date;
  final TtcPhase? phase;
  final bool isToday;
  final bool expected;

  @override
  Widget build(BuildContext context) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final showsMonth = date.day == 1;

    // WARNING: TODAY IS FILLED AND RINGED, NOT OUTLINED. This cell used to take
    // a plain 2pt border while the report's grid gave today the phase's mark
    // colour, white type and a double halo -- two pictures of the same month
    // marking the same day two different ways. `ttcTodayRings` is now the one
    // definition and both use it.
    final mark = phase == null ? ttcTitleInk : ttcPhaseMark(phase!);

    return Container(
      decoration: BoxDecoration(
        color: expected
            ? null
            : isToday
                ? mark
                : phase == null
                    ? null
                    : ttcPhaseBand(phase!),
        borderRadius: BorderRadius.circular(11),
        border: expected ? Border.all(color: ttcBorder, width: 1.5) : null,
        boxShadow: isToday && !expected ? ttcTodayRings(mark) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showsMonth)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(months[date.month - 1].toUpperCase(),
                  style: ttcBody(8.5,
                      color: isToday && !expected
                          ? Colors.white
                          : phase == null
                              ? ttcMuted
                              : ttcPhaseInk(phase!),
                      w: FontWeight.w800)),
            ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('${date.day}',
                style: ttcBody(12.5,
                    color: isToday && !expected
                        ? Colors.white
                        : expected
                            ? ttcMuted
                            : phase == null
                                ? ttcSoft
                                : ttcTitleInk,
                    w: isToday ? FontWeight.w800 : FontWeight.w700)),
          ),
          if (isToday && !expected)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(kTtcNowLabel,
                  style: pvManrope(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      height: 1.1,
                      color: Colors.white)),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Your rhythm
// =============================================================================

class _RhythmCard extends StatelessWidget {
  const _RhythmCard({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final cycle = CycleStore.instance;
    final lengths = cycle.cycleLengths;
    const engine = TtcChapterEngine();
    final state = TtcStore.instance.state();
    final usual = engine.cycleLengthFor(state);

    final lo = lengths.isEmpty ? null : lengths.reduce((a, b) => a < b ? a : b);
    final hi = lengths.isEmpty ? null : lengths.reduce((a, b) => a > b ? a : b);
    final spread = (lo != null && hi != null) ? hi - lo : null;

    final start = cycle.lastPeriodStart;
    final next = start?.add(Duration(days: usual));

    return TtcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: _Fact(
                p: p,
                // ⚠️ ONE CYCLE IS NOT AN AVERAGE, and the old screen was right
                // about this before the redesign. Calling a single observation
                // "usual" invites her to plan around one month.
                label: lengths.length <= 1 ? 'Your first full cycle' : 'Usual length',
                value: '$usual days'),
          ),
          if (lengths.length > 1) ...[
            const SizedBox(width: 10),
            Expanded(
              child: _Fact(p: p, label: 'Spread', value: '$lo to $hi days'),
            ),
          ],
        ]),
        if (lengths.length > 1) ...[
          const SizedBox(height: 14),
          Text(
              'Across your last ${lengths.length} cycles. '
              '${spread == 0 ? "Yours hasn't changed at all" : 'Yours changes by '
                  '$spread ${spread == 1 ? 'day' : 'days'}'}'
              '${spread != null && spread <= 4 ? '. That\'s a steady rhythm.' : '.'}',
              style: ttcBody(13, h: 1.45, color: ttcSoft)),
        ],
        if (next != null) ...[
          const SizedBox(height: 16),
          ttcDivider(),
          const SizedBox(height: 14),
          Text('NEXT PERIOD EXPECTED',
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: ttcMuted)),
          const SizedBox(height: 5),
          Text('Around ${ttcLongDate(next)}',
              style: ttcFraunces(20, w: FontWeight.w600, color: ttcTitleInk)),
          const SizedBox(height: 5),
          // ⚠️ THE HEDGE IS PART OF THE FACT, NOT A DISCLAIMER UNDER IT. A date
          // with no tolerance beside it reads as a promise, and a period is the
          // one prediction in this app that will visibly miss.
          Text('A few days either side is normal.', style: ttcBody(13, h: 1.45)),
        ],
      ]),
    );
  }
}

// =============================================================================
//  One logged date — swipe left to correct or remove
// =============================================================================

/// How far the row slides to uncover its two actions.
const double _kRowReveal = 160;

class _DateRow extends StatefulWidget {
  const _DateRow({
    required this.p,
    required this.start,
    required this.previous,
    required this.isCurrent,
    required this.open,
    required this.onOpen,
  });

  final V2Palette p;
  final DateTime start;

  /// The period logged before this one, for the gap. Null on the oldest row.
  final DateTime? previous;

  final bool isCurrent;
  final bool open;
  final ValueChanged<bool> onOpen;

  @override
  State<_DateRow> createState() => _DateRowState();
}

class _DateRowState extends State<_DateRow> {
  double _drag = 0;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final store = CycleStore.instance;
    final bleed = store.bleedDaysFor(widget.start);

    final gap = widget.previous == null
        ? null
        : widget.start.difference(widget.previous!).inDays;
    // ⚠️ THE SAME PLAUSIBILITY WINDOW THE AVERAGE USES, READ FROM THE STORE
    // RATHER THAN RETYPED. A row that says "54 days" while the average silently
    // drops it is two screens disagreeing about one dataset, which is the exact
    // defect `ttc_data_chain_test` exists to hold.
    final counted = gap == null ||
        (gap >= CycleStore.minPlausibleCycleDays && gap <= CycleStore.maxPlausibleCycleDays);

    final meta = StringBuffer();
    if (widget.isCurrent) {
      final day = TtcStore.instance.today.cycleDay;
      meta.write(day == null ? 'Current cycle' : 'Cycle day $day today');
    } else if (gap != null) {
      meta.write('$gap days');
    }
    if (bleed != null) {
      if (meta.isNotEmpty) meta.write(' · ');
      meta.write(bleed == kBleedStillOn
          ? 'still on'
          : '$bleed bleeding ${bleed == 1 ? 'day' : 'days'}');
    }

    final offset = widget.open ? -_kRowReveal : _drag;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(children: [
        // ---- the two actions, behind ------------------------------------
        Positioned.fill(
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            _RowAction(
              label: 'Correct',
              background: ttcPanel,
              ink: ttcTitleInk,
              onTap: () {
                widget.onOpen(false);
                showTtcPeriodLogSheet(context, correcting: widget.start);
              },
            ),
            _RowAction(
              label: 'Remove',
              background: const Color(0xFFF3DEDE),
              ink: const Color(0xFFB3261E),
              onTap: () {
                widget.onOpen(false);
                _removeWithUndo(context, widget.start);
              },
            ),
          ]),
        ),
        // ---- the row itself ---------------------------------------------
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (d) => setState(() {
            _drag = (_drag + d.delta.dx).clamp(-_kRowReveal, 0.0);
          }),
          onHorizontalDragEnd: (_) {
            // Past a third of the way is a commitment; short of it, snap back.
            final opened = _drag < -_kRowReveal / 3;
            setState(() => _drag = 0);
            widget.onOpen(opened);
          },
          onTap: widget.open ? () => widget.onOpen(false) : null,
          child: AnimatedContainer(
            duration: Duration(milliseconds: _drag == 0 ? 220 : 0),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(offset, 0, 0),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.line),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: widget.isCurrent
                            ? ttcPhaseMark(TtcPhase.period)
                            : ttcBorder,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ttcLongDate(widget.start),
                                style: ttcBody(14,
                                    color: ttcTitleInk, w: FontWeight.w700)),
                            if (meta.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(meta.toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ttcBody(12.5, color: ttcMuted)),
                            ],
                          ]),
                    ),
                    Icon(Icons.keyboard_double_arrow_left_rounded,
                        size: 15, color: ttcMuted.withValues(alpha: 0.6)),
                  ]),
                  if (!counted) ...[
                    const SizedBox(height: 12),
                    ttcDivider(),
                    const SizedBox(height: 12),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: ttcPanel,
                                borderRadius: BorderRadius.circular(999)),
                            child: Text('NOT COUNTED',
                                style: pvManrope(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    color: ttcSoft)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                                "A gap this long is usually a month that wasn't "
                                "logged. We keep it, but we don't use it for your "
                                'usual length.',
                                style: ttcBody(13, h: 1.45)),
                          ),
                        ]),
                  ],
                ]),
          ),
        ),
      ]),
    );
  }
}

class _RowAction extends StatelessWidget {
  const _RowAction({
    required this.label,
    required this.background,
    required this.ink,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color ink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: _kRowReveal / 2,
          alignment: Alignment.center,
          color: background,
          child: Text(label,
              style: ttcBody(12.5, color: ink, w: FontWeight.w800)),
        ),
      );
}

/// Removes a logged period and offers it straight back.
///
/// ⚠️ UNDO RATHER THAN A CONFIRM SHEET, AND THE CHOICE WAS DELIBERATE. A
/// confirm taxes every delete to protect against the rare mistake; an undo
/// taxes only the mistake. It is affordable here because a period is one date
/// in a list — [CycleStore.detailsFor] captures what hangs off it first, so
/// what comes back is the whole row and not just the date.
void _removeWithUndo(BuildContext context, DateTime start) {
  final store = CycleStore.instance;
  final kept = store.detailsFor(start);
  store.removePeriodStart(start);
  HapticFeedback.selectionClick();

  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(SnackBar(
          // Flutter 3.44 keeps a snackbar with an action on screen until it is
          // dismissed (`persist` defaults to true when there is an action).
          persist: false,
    content: Text('${ttcShortDate(start)} removed',
        style: pvManrope(fontSize: 13, color: Colors.white)),
    backgroundColor: ttcTitleInk,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(18, 0, 18, 86),
    shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    duration: const Duration(seconds: 5),
    action: SnackBarAction(
      label: 'UNDO',
      textColor: const Color(0xFFC9A8F0),
      onPressed: () => store.restorePeriodStart(start,
          bleed: kept.bleed, lh: kept.lh, temp: kept.temp),
    ),
  ));
}

// =============================================================================
//  Logging a period — the date, and how long it lasted
// =============================================================================

/// The bleed-length answers, in the order they are offered.
///
/// ⚠️ CHIPS AND NOT AN END DATE, DECIDED BEFORE THE SCREEN WAS DESIGNED. A
/// count is one tap, it works when she logs three days late, and it is exactly
/// what the picture needs — the report bands the first stretch by a NUMBER of
/// days, not by a second date. An end date is a second date-picker and invites
/// the state where she never comes back to close it.
const List<int> kTtcBleedChoices = [3, 4, 5, 6, 7];

/// Opens the log sheet. Pass [correcting] to move an existing date instead.
Future<void> showTtcPeriodLogSheet(
  BuildContext context, {
  DateTime? correcting,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogSheet(correcting: correcting),
    );

class _LogSheet extends StatefulWidget {
  const _LogSheet({this.correcting});
  final DateTime? correcting;

  @override
  State<_LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends State<_LogSheet> {
  late DateTime _month;
  late DateTime? _picked;
  late int? _bleed;

  bool get _isEdit => widget.correcting != null;

  @override
  void initState() {
    super.initState();
    final seed = widget.correcting ?? DateTime.now();
    _month = DateTime(seed.year, seed.month);
    _picked = widget.correcting;
    _bleed = widget.correcting == null
        ? null
        : CycleStore.instance.bleedDaysFor(widget.correcting!);
  }

  void _save() {
    final picked = _picked;
    if (picked == null) return;
    final store = CycleStore.instance;

    if (_isEdit) {
      // ⚠️ A MOVE, NOT A DELETE AND AN ADD. Removing clears the bleed length,
      // the LH strip and the temperature shift — all keyed by the start date —
      // so correcting a date by one day would silently erase everything she
      // recorded about that cycle. See `CycleStore.movePeriodStart`.
      store.movePeriodStart(widget.correcting!, picked);
    } else {
      store.logPeriodStart(picked);
    }
    store.logBleedDays(picked, _bleed);
    HapticFeedback.selectionClick();
    // ⚠️ "TALK IT THROUGH" AFTER A NEW PERIOD (2026-09-26, gap analysis,
    // "Behind: Guided help"). Offered once, as the sheet closes, and only for
    // a period that started today or yesterday and is not the first she ever
    // logged (`ttcShouldOfferPeriodTalk`). A move is a correction, not news,
    // so editing a date never offers it. The navigator and messenger are
    // taken now because this sheet's context is gone after the pop.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    navigator.maybePop();
    if (!_isEdit && messenger != null) {
      showTtcPeriodCameNudge(
        navigator: navigator,
        messenger: messenger,
        start: picked,
        starts: store.periodStarts,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final today = DateTime.now();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.92),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                          color: ttcBorder,
                          borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_isEdit ? 'CORRECT A DATE' : 'LOG A PERIOD',
                      style: pvManrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: ttcMuted)),
                  const SizedBox(height: 8),
                  Text(_isEdit ? 'When did it really start?' : 'When did it start?',
                      style: ttcFraunces(22,
                          w: FontWeight.w600, color: ttcTitleInk, h: 1.2)),
                  const SizedBox(height: 6),
                  // ⚠️ THE DEFINITION IS ON THE SCREEN THAT ASKS. "Day 1" means
                  // real bleeding and not spotting, and every derived number in
                  // this stage hangs off her getting that right. Saying it in a
                  // help article instead would be saying it to the people who
                  // already knew.
                  Text('The first day of real bleeding, not spotting.',
                      style: ttcBody(13, h: 1.45)),
                  const SizedBox(height: 18),

                  _MonthPicker(
                    month: _month,
                    picked: _picked,
                    today: today,
                    onMonth: (m) => setState(() => _month = m),
                    onPick: (d) => setState(() => _picked = d),
                  ),

                  const SizedBox(height: 24),
                  Text('HOW MANY DAYS DID YOU BLEED',
                      style: pvManrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: ttcMuted)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final n in kTtcBleedChoices)
                      _Chip(
                        label: n == kTtcBleedChoices.last ? '$n+' : '$n',
                        on: _bleed == n,
                        onTap: () =>
                            setState(() => _bleed = _bleed == n ? null : n),
                      ),
                    _Chip(
                      label: 'Still on',
                      on: _bleed == kBleedStillOn,
                      onTap: () => setState(() => _bleed =
                          _bleed == kBleedStillOn ? null : kBleedStillOn),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Text(
                      'Choose "Still on" if it hasn\'t finished. You can change '
                      'this later.',
                      style: ttcBody(13, h: 1.45)),

                  const SizedBox(height: 22),
                  _QuietAction(
                    label: _isEdit ? 'Save the correction' : 'Save this period',
                    onTap: _picked == null ? null : _save,
                  ),
                  const SizedBox(height: 10),
                  _QuietAction(
                    label: 'Not now',
                    muted: true,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}

class _MonthPicker extends StatelessWidget {
  const _MonthPicker({
    required this.month,
    required this.picked,
    required this.today,
    required this.onMonth,
    required this.onPick,
  });

  final DateTime month;
  final DateTime? picked;
  final DateTime today;
  final ValueChanged<DateTime> onMonth;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final days = DateTime(month.year, month.month + 1, 0).day;
    final lead = (DateTime(month.year, month.month, 1).weekday -
            DateTime.monday) %
        7;
    // ⚠️ NO FUTURE DATES. A period cannot have started tomorrow, and letting
    // one be picked would put a negative cycle day on every screen that reads
    // this store.
    final nextAllowed = DateTime(today.year, today.month).isAfter(month);

    return Column(children: [
      Row(children: [
        _Step(
          icon: Icons.chevron_left_rounded,
          onTap: () => onMonth(DateTime(month.year, month.month - 1)),
        ),
        Expanded(
          child: Text('${names[month.month - 1]} ${month.year}',
              textAlign: TextAlign.center,
              style: ttcBody(14, color: ttcTitleInk, w: FontWeight.w800)),
        ),
        _Step(
          icon: Icons.chevron_right_rounded,
          onTap: nextAllowed
              ? () => onMonth(DateTime(month.year, month.month + 1))
              : null,
        ),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        for (final d in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
          Expanded(
            child: Text(d,
                textAlign: TextAlign.center,
                style: ttcBody(9.5, color: ttcMuted, w: FontWeight.w800)),
          ),
      ]),
      const SizedBox(height: 6),
      GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: [
          for (var i = 0; i < lead; i++) const SizedBox(),
          for (var d = 1; d <= days; d++)
            _PickCell(
              day: d,
              date: DateTime(month.year, month.month, d),
              picked: picked,
              today: today,
              onPick: onPick,
            ),
        ],
      ),
    ]);
  }
}

class _PickCell extends StatelessWidget {
  const _PickCell({
    required this.day,
    required this.date,
    required this.picked,
    required this.today,
    required this.onPick,
  });

  final int day;
  final DateTime date;
  final DateTime? picked;
  final DateTime today;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final future = date.isAfter(DateTime(today.year, today.month, today.day));
    final on = picked != null && _sameDay(picked!, date);
    final isToday = _sameDay(date, today);

    return GestureDetector(
      onTap: future ? null : () => onPick(date),
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? ttcTitleInk : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          border: !on && isToday
              ? Border.all(color: ttcBorder, width: 1.5)
              : null,
        ),
        child: Text('$day',
            style: ttcBody(13,
                color: future
                    ? ttcBorder
                    : on
                        ? Colors.white
                        : ttcTitleInk,
                w: on ? FontWeight.w800 : FontWeight.w600)),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: ttcPanel, borderRadius: BorderRadius.circular(11)),
          child: Icon(icon,
              size: 18, color: onTap == null ? ttcBorder : ttcTitleInk),
        ),
      );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: on ? ttcTitleInk : ttcPanel,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
              style: ttcBody(13,
                  color: on ? Colors.white : ttcTitleInk,
                  w: on ? FontWeight.w800 : FontWeight.w600)),
        ),
      );
}

// =============================================================================
//  Small shared parts
// =============================================================================

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text, {required this.p});
  final String text;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: pvManrope(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: ttcMuted));
}

/// A label over a value, or over an invitation where there is no value yet.
///
/// ⚠️ THE PLACEHOLDER IS NOT AN EMPTY STATE, it is the value's honest stand-in.
/// "A feature is never hidden" — the block keeps its shape and its label so the
/// page does not reflow the day her data arrives.
class _Fact extends StatelessWidget {
  const _Fact({
    required this.p,
    required this.label,
    this.value,
    this.placeholder,
  });

  final V2Palette p;
  final String label;
  final String? value;
  final String? placeholder;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
        decoration: BoxDecoration(
            color: ttcPanel, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: ttcMuted)),
          const SizedBox(height: 5),
          Text(value ?? placeholder ?? '',
              style: value != null
                  ? ttcFraunces(17, w: FontWeight.w600, color: ttcTitleInk)
                  : ttcBody(13, h: 1.45)),
        ]),
      );
}

/// The stage's one button: white, a hairline, an ink label.
///
/// ⚠️ NOT A FILLED BAR, AND NOT THE ACCENT. `_QuietButton` at the foot of the
/// symptom logger states the rule — "one button treatment on this stage" — and
/// every screen that has invented a second one has been corrected back to it.
class _QuietAction extends StatelessWidget {
  const _QuietAction({
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final off = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: muted ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: ttcLine),
        ),
        child: Text(label,
            style: ttcBody(14,
                color: off
                    ? ttcMuted
                    : muted
                        ? ttcSoft
                        : ttcTitleInk,
                w: FontWeight.w800)),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.left,
    required this.right,
    required this.rightOn,
    required this.onPick,
  });

  final String left;
  final String right;
  final bool rightOn;
  final ValueChanged<bool> onPick;

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, bool on, VoidCallback tap) => GestureDetector(
          onTap: on ? null : tap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
            decoration: BoxDecoration(
              color: on ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              boxShadow: on
                  ? [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1)),
                    ]
                  : null,
            ),
            child: Text(label,
                style: ttcBody(11.5,
                    color: on ? ttcTitleInk : ttcMuted,
                    w: FontWeight.w800)),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          color: ttcPanel, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        seg(left, !rightOn, () => onPick(false)),
        seg(right, rightOn, () => onPick(true)),
      ]),
    );
  }
}

/// The line every clinical surface in this stage owes the reader.
class _Estimates extends StatelessWidget {
  const _Estimates({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: ttcMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                'These are estimates, never guarantees. If your cycles change or '
                "stop, or you're worried, talk to a doctor.",
                style: ttcBody(13, h: 1.45)),
          ),
        ],
      );
}
