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
import '../products/pv_store_chrome.dart' show pvSnack;
import 'ttc_cycle_palette.dart';
// Kept for revert (2026-09-27): import 'ttc_phase_colours.dart';
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

          // ⚠️ THE FIELD WEARS THE PART SHE IS IN, FROM THE ONE PALETTE
          // (2026-09-27): rose in her period, violet in her fertile days, a
          // near-grey otherwise. It was always violet-magenta (288), which on
          // a page of cycle colours read as one more colour with no meaning.
          // Kept for revert: accent: v2BlockTint(kTtcCompanionHue, p),
          // chroma: v3FieldChroma(kTtcCompanionHue).
          final herePhase = screen == TtcCompanionState.healthy
              ? spans
                  .where((s) => s.status == TtcSpanStatus.here)
                  .firstOrNull
                  ?.phase
              : null;
          final heroHue = TtcCycleColours.heroHue(herePhase);

          return Scaffold(
            backgroundColor: p.ground,
            body: Stack(children: [
              Positioned.fill(
                child: V3HeroField(
                  accent: v2BlockTint(heroHue, p),
                  ground: p.ground,
                  variant: switch (screen) {
                    TtcCompanionState.healthy => 2,
                    TtcCompanionState.empty => 4,
                    _ => 1,
                  },
                  chroma: v3FieldChroma(heroHue) *
                      TtcCycleColours.heroChromaScale(herePhase),
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

    // ⚠️ THE LINE SAYS WHAT THIS PAGE IS (tools pass, 2026-09-27). It was a
    // motto ("here to understand, not to predict", "at your own pace") and
    // never said that this is where her period dates live. Kept for revert:
    //   empty: 'Get to know your own pattern, at your own pace.'
    //   clinicHeld: 'Your clinic is guiding this cycle.'
    //   noEstimate: "No estimate this month. That's on purpose."
    //   healthy: '<first> to <last> · here to understand, not to predict'
    final (String title, String line) = switch (screen) {
      TtcCompanionState.empty => (
          'One date to start',
          'This is where your period dates live. Add the day your last '
              "period started and we'll count your cycle from there.",
        ),
      TtcCompanionState.clinicHeld => (
          today.cycleDay == null ? 'Your cycle' : 'Cycle day ${today.cycleDay}',
          'Your period dates. Your clinic is guiding this cycle.',
        ),
      TtcCompanionState.noEstimate => (
          today.cycleDay == null ? 'Your cycle' : 'Cycle day ${today.cycleDay}',
          "Your period dates. We can't place your fertile days this month, "
              'and below is why.',
        ),
      TtcCompanionState.healthy => (
          here?.phase.label ?? 'Your cycle',
          here == null
              ? 'Your period dates, and where you are in your cycle.'
              : 'Where you are now, until ${ttcShortDate(here.lastDay)}. '
                  'Your period dates are below.',
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
                // One name with the Tools tile (2026-09-27). Kept for revert:
                // 'Cycle Companion'.
                child: Text('Cycle companion',
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
              // Only where the big title is not already the cycle day
              // (2026-09-27): "Cycle day 12" twice, a line apart, read as
              // two different things. Kept for revert:
              //   screen != TtcCompanionState.empty
              if (today.cycleDay != null &&
                  screen == TtcCompanionState.healthy) ...[
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
  // ⚠️ `TtcCycleCard`, NOT `TtcCard`, ON EVERY CARD HERE (2026-09-27): the
  // V1 card's violet drop shadow was the old look; the base UI is a hairline.
  // Kept for revert: TtcCard( at the four call sites.
  List<Widget> _empty(BuildContext context) => [
        TtcCycleCard(
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
            // Kept for revert: 'The spread, and a picture of the whole cycle'.
            value: 'How much your cycles vary, and a picture of the whole '
                'cycle'),
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
      TtcCycleCard(
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
          // One name for the report everywhere (2026-09-27). Kept for
          // revert: 'See your logged months in full'.
          _QuietAction(
            label: kTtcSeeCycleReport,
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
        // A pill you can hit, not a word (2026-09-27): a 13pt label with
        // no edge was the only way to add a period once one existed. Kept
        // for revert: GestureDetector(Text('Add a date', ttcBody(13, w800))).
        Semantics(
          button: true,
          label: 'Add a period date',
          excludeSemantics: true,
          child: InkWell(
            key: const ValueKey('ttc_companion_add_date'),
            onTap: () => showTtcPeriodLogSheet(context),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              constraints: const BoxConstraints(minHeight: 36),
              padding: const EdgeInsets.fromLTRB(10, 0, 14, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: ttcLine, width: 1.2),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.add_rounded, size: 17, color: ttcTitleInk),
                const SizedBox(width: 4),
                Text('Add a date',
                    style:
                        ttcBody(13, color: ttcTitleInk, w: FontWeight.w800)),
              ]),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 6),
      // ⚠️ A TAP, NOT ONLY A SWIPE (tools pass, 2026-09-27). The swipe was
      // the only way to fix a date and nothing showed it; each row now
      // carries a pencil and opens "Change" and "Remove" on a tap (Withings'
      // pencil per row, mobbin a2b2a57e; Greg's action sheet, mobbin
      // ce063299). The swipe still works. Kept for revert:
      //   'Swipe a row left to fix or remove it.'
      Text('Tap a date to change or remove it.',
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
    return TtcCycleCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text('This cycle',
                style: ttcFraunces(16.5,
                    w: FontWeight.w600, color: ttcTitleInk)),
          ),
          // Named for what they show (2026-09-27), the same two words as the
          // cycle report. Kept for revert: 'Ring', 'Days'.
          _Segmented(
            left: kTtcCirclePicture,
            right: kTtcCalendarPicture,
            rightOn: !ring,
            onPick: (r) => onPicture(
                r ? TtcCompanionPicture.days : TtcCompanionPicture.ring),
          ),
        ]),
        const SizedBox(height: 6),
        // The four parts named once, in plain words (2026-09-27).
        Text(kTtcFourPartsLine, style: ttcBody(13, h: 1.45)),
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
                // Kept for revert: 'See this month in full'.
                child: Text(kTtcSeeCycleReport,
                    style: ttcBody(13,
                        color: ttcTitleInk, w: FontWeight.w800)),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: ttcTitleInk),
            ]),
          ),
        ),
        // The same "estimates" line sits at the foot of the page
        // (`_Estimates`); once is enough (2026-09-27). Kept for revert:
        //   Text('These dates are estimates, worked out from your own past '
        //       'cycles.', style: ttcBody(13, h: 1.45)),
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
          // The legend swatch is the ring's own fill (2026-09-27). Kept for
          // revert: color: ttcPhaseMark(span.phase).
          decoration: BoxDecoration(
              color: TtcCycleColours.fill(span.phase),
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
        // Says the colour it is (2026-09-27). Kept for revert:
        //   'Outlined square: when the next period is expected.'
        child: Text('Rose outline: when the next period is expected.',
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
    // Today is ink and the expected period a rose outline, from the one
    // palette (2026-09-27). Kept for revert:
    //   final mark = phase == null ? ttcTitleInk : ttcPhaseMark(phase!);
    //   color: ... : ttcPhaseBand(phase!),
    //   border: expected ? Border.all(color: ttcBorder, width: 1.5) : null,
    const mark = TtcCycleColours.today;

    return Container(
      decoration: BoxDecoration(
        color: expected
            ? null
            : isToday
                ? mark
                : phase == null
                    ? null
                    : TtcCycleColours.fill(phase!),
        borderRadius: BorderRadius.circular(11),
        border: expected
            ? Border.all(color: TtcCycleColours.period, width: 1.6)
            : null,
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
                              : TtcCycleColours.onFill(phase!),
                      w: FontWeight.w800)),
            ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('${date.day}',
                style: ttcBody(12.5,
                    color: isToday && !expected
                        ? Colors.white
                        : expected
                            ? TtcCycleColours.periodInk
                            : phase == null
                                ? ttcSoft
                                : TtcCycleColours.onFill(phase!),
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

    return TtcCycleCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: _Fact(
                p: p,
                // ⚠️ ONE CYCLE IS NOT AN AVERAGE, and the old screen was right
                // about this before the redesign. Calling a single observation
                // "usual" invites her to plan around one month.
                // With no counted cycle the number is the starting guess (her
                // stated length, else 28), not a cycle of hers (2026-09-27).
                // Kept for revert:
                //   lengths.length <= 1 ? 'Your first full cycle' : 'Usual length',
                label: lengths.isEmpty
                    ? 'A starting guess'
                    : lengths.length == 1
                        ? 'Your first full cycle'
                        : 'Usual length',
                value: '$usual days'),
          ),
          if (lengths.length > 1) ...[
            const SizedBox(width: 10),
            Expanded(
              // Kept for revert: label: 'Spread'.
              child: _Fact(
                  p: p, label: 'Shortest to longest', value: '$lo to $hi days'),
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

    // ⚠️ THE CYCLE THAT BEGAN ON THIS DATE, FROM THE STORE (2026-09-27). The
    // row used to measure `start - previous`, the cycle BEFORE it, so the
    // verdict landed one row late: the current cycle read "NOT COUNTED" for
    // the gap behind it. `CycleStore.cycleFrom` returns the length and the
    // verdict from one call so they cannot disagree; the current cycle has
    // not ended, so it has neither. Kept for revert:
    //   final gap = widget.previous == null
    //       ? null
    //       : widget.start.difference(widget.previous!).inDays;
    //   final counted = gap == null ||
    //       (gap >= CycleStore.minPlausibleCycleDays &&
    //           gap <= CycleStore.maxPlausibleCycleDays);
    final cycle = widget.isCurrent ? null : store.cycleFrom(widget.start);
    final gap = cycle?.days;
    final counted = cycle == null || cycle.counted;
    final tooShort = gap != null && gap < CycleStore.minPlausibleCycleDays;

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
          // A tap opens Change and Remove (2026-09-27). Kept for revert:
          //   onTap: widget.open ? () => widget.onOpen(false) : null,
          onTap: widget.open
              ? () => widget.onOpen(false)
              : () => showTtcPeriodDateActions(context, widget.start),
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
                            ? TtcCycleColours.period
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
                    // A pencil you can see, in place of the swipe hint
                    // (2026-09-27). Kept for revert:
                    //   Icon(Icons.keyboard_double_arrow_left_rounded,
                    //       size: 15, color: ttcMuted.withValues(alpha: 0.6)),
                    Semantics(
                      button: true,
                      label: 'Change or remove ${ttcLongDate(widget.start)}',
                      excludeSemantics: true,
                      child: InkWell(
                        key: ValueKey('ttc_period_row_edit_'
                            '${widget.start.toIso8601String()}'),
                        onTap: () =>
                            showTtcPeriodDateActions(context, widget.start),
                        customBorder: const CircleBorder(),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(Icons.edit_outlined,
                              size: 18, color: ttcSoft),
                        ),
                      ),
                    ),
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
                            // Says what it means (2026-09-27). Kept for
                            // revert: 'NOT COUNTED'.
                            child: Text('NOT IN YOUR AVERAGE',
                                style: pvManrope(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    color: ttcSoft)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            // One reason per kind of gap (2026-09-27): a
                            // ten-day gap used to read "a gap this long".
                            // Kept for revert: the long-gap sentence only.
                            child: Text(
                                tooShort
                                    ? 'Too short to be a whole cycle. It may be '
                                        'spotting, or a date logged twice. We keep '
                                        "it, but we don't use it for your usual "
                                        'length.'
                                    : "A gap this long is usually a month that "
                                        "wasn't logged. We keep it, but we don't "
                                        'use it for your usual length.',
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

  // ⚠️ THE HOUSE NOTICE (2026-09-27): a white card with an ink "Undo" pill,
  // the same one every other tool uses, instead of a dark bar with a
  // lavender "UNDO" of its own. Kept for revert: a SnackBar with
  // backgroundColor ttcTitleInk, margin 86, 5s, and a SnackBarAction 'UNDO'
  // in 0xFFC9A8F0 calling the same restore.
  pvSnack(
    context,
    'Removed the period from ${ttcShortDate(start)}',
    action: 'Undo',
    lift: 24,
    onAction: () => store.restorePeriodStart(start,
        bleed: kept.bleed, lh: kept.lh, temp: kept.temp),
  );
}

/// "Change this date" and "Remove this date" for one logged period, from a
/// tap on its row or its pencil (tools pass, 2026-09-27).
///
/// ⚠️ REMOVE STILL UNDOES, IT DOES NOT CONFIRM. Same trade as the swipe: the
/// undo taxes only the mistake, and [CycleStore.detailsFor] brings back the
/// bleed days, LH strip and temperature shift with the date.
Future<void> showTtcPeriodDateActions(BuildContext context, DateTime start) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      routeSettings: const RouteSettings(name: 'ttc/period_actions'),
      builder: (sheet) => _PeriodActionsSheet(
        start: start,
        onChange: () {
          Navigator.of(sheet).pop();
          showTtcPeriodLogSheet(context, correcting: start);
        },
        onRemove: () {
          Navigator.of(sheet).pop();
          _removeWithUndo(context, start);
        },
      ),
    );

/// The Change / Remove sheet for one period, in the log sheet's own clothes.
///
/// ⚠️ THE SAME SHEET AS "LOG A PERIOD" (2026-09-27): the same surface, handle,
/// eyebrow and Fraunces question, so opening a date feels like the tool and
/// not a system menu. It also says what she saved about this period before
/// she chooses, which the plain white menu did not (Withings' pencil per row,
/// mobbin a2b2a57e; MacroFactor's period list with an edit per day, mobbin
/// 3fd2db7d).
class _PeriodActionsSheet extends StatelessWidget {
  const _PeriodActionsSheet({
    required this.start,
    required this.onChange,
    required this.onRemove,
  });

  final DateTime start;
  final VoidCallback onChange;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final store = CycleStore.instance;
    final bleed = store.bleedDaysFor(start);
    final isLast = store.lastPeriodStart != null &&
        _sameDay(store.lastPeriodStart!, start);
    final cycle = isLast ? null : store.cycleFrom(start);
    final facts = <String>[
      if (bleed == kBleedStillOn)
        'Still on'
      else if (bleed != null)
        '$bleed bleeding ${bleed == 1 ? 'day' : 'days'}'
      else
        'Bleeding days not added',
      if (cycle != null) 'a ${cycle.days}-day cycle',
      if (isLast) 'your current cycle',
    ];

    Widget row(IconData icon, String label, String line, Color ink,
            VoidCallback go, Key key) =>
        InkWell(
          key: key,
          onTap: go,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ttcLine),
            ),
            child: Row(children: [
              Icon(icon, size: 20, color: ink),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: ttcBody(15, color: ink, w: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(line, style: ttcBody(12.5, h: 1.35)),
                    ]),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
            ]),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Text('YOUR PERIOD',
                    style: pvManrope(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: ttcMuted)),
                const SizedBox(height: 8),
                Text('Started ${ttcLongDate(start)}',
                    style: ttcFraunces(22,
                        w: FontWeight.w600, color: ttcTitleInk, h: 1.2)),
                const SizedBox(height: 6),
                Text(
                    '${facts.first[0].toUpperCase()}${facts.first.substring(1)}'
                    '${facts.length > 1 ? ', ${facts.skip(1).join(', ')}' : ''}.',
                    key: const ValueKey('ttc_period_action_facts'),
                    style: ttcBody(13, h: 1.45)),
                const SizedBox(height: 18),
                row(
                    Icons.edit_calendar_outlined,
                    'Change this date',
                    'Or how many days you bled',
                    ttcTitleInk,
                    onChange,
                    const ValueKey('ttc_period_action_change')),
                const SizedBox(height: 10),
                row(
                    Icons.delete_outline_rounded,
                    'Remove this date',
                    'You can undo this straight after',
                    const Color(0xFFB3261E),
                    onRemove,
                    const ValueKey('ttc_period_action_remove')),
              ]),
        ),
      ),
    );
  }
}

// Kept for revert (2026-09-27): the plain white menu this sheet replaced.
// Future<void> showTtcPeriodDateActions(BuildContext context, DateTime start) =>
//     showModalBottomSheet<void>(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
//       builder: (sheet) {
//         Widget row(IconData icon, String label, Color ink, VoidCallback go,
//                 Key key) =>
//             InkWell(
//               key: key,
//               onTap: () {
//                 Navigator.of(sheet).pop();
//                 go();
//               },
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
//                 child: Row(children: [
//                   Icon(icon, size: 20, color: ink),
//                   const SizedBox(width: 14),
//                   Expanded(
//                     child: Text(label,
//                         style: ttcBody(15, color: ink, w: FontWeight.w700)),
//                   ),
//                 ]),
//               ),
//             );
//         return SafeArea(
//           top: false,
//           child: Padding(
//             padding: const EdgeInsets.only(top: 18, bottom: 10),
//             child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 22),
//                     child: Text('Period that started ${ttcLongDate(start)}',
//                         style: ttcFraunces(18,
//                             w: FontWeight.w600, color: ttcTitleInk)),
//                   ),
//                   const SizedBox(height: 8),
//                   row(
//                       Icons.edit_calendar_outlined,
//                       'Change this date',
//                       ttcTitleInk,
//                       () => showTtcPeriodLogSheet(context, correcting: start),
//                       const ValueKey('ttc_period_action_change')),
//                   row(
//                       Icons.delete_outline_rounded,
//                       'Remove this date',
//                       const Color(0xFFB3261E),
//                       () => _removeWithUndo(context, start),
//                       const ValueKey('ttc_period_action_remove')),
//                 ]),
//           ),
//         );
//       },
//     );

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
///
/// [initial] picks a day in advance (the calendar's day card, 2026-09-27), so
/// "Log a period" on the 12th opens on the 12th. A future day is not picked.
Future<void> showTtcPeriodLogSheet(
  BuildContext context, {
  DateTime? correcting,
  DateTime? initial,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // The saved notice needs a Scaffold under the messenger; every screen
      // that opens this sheet has one, and a bare host (a test) is told so.
      builder: (_) => _LogSheet(
          correcting: correcting,
          initial: initial,
          notify: Scaffold.maybeOf(context) != null),
    );

class _LogSheet extends StatefulWidget {
  const _LogSheet({this.correcting, this.initial, this.notify = true});
  final DateTime? correcting;
  final DateTime? initial;

  /// Whether the screen underneath can show the saved notice.
  final bool notify;

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
    final now = DateTime.now();
    final todayD = DateTime(now.year, now.month, now.day);
    final init = widget.initial == null
        ? null
        : DateTime(widget.initial!.year, widget.initial!.month,
            widget.initial!.day);
    final usable = init != null && !init.isAfter(todayD) ? init : null;
    final seed = widget.correcting ?? usable ?? now;
    _month = DateTime(seed.year, seed.month);
    _picked = widget.correcting ?? usable;
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
    // ⚠️ SHE IS TOLD IT SAVED (2026-09-27). The sheet closed and nothing
    // said so; on a screen where the new date lands below the fold that read
    // as a tap that did nothing. The "talk it through" offer, when it
    // applies, replaces this notice (it says the period was logged too).
    if (messenger != null && widget.notify) {
      pvSnack(
        navigator.context,
        _isEdit
            ? 'Changed to ${ttcShortDate(picked)}'
            : 'Period saved: started ${ttcShortDate(picked)}',
        icon: Icons.check_rounded,
        lift: 24,
      );
    }
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

// ---- plain words, shared with the cycle report (tools pass, 2026-09-27) ----

/// One name for the cycle report on every button that opens it.
const String kTtcSeeCycleReport = 'See your cycle report';

/// The picture toggle, the same two words here and on the report.
const String kTtcCirclePicture = 'Circle';
const String kTtcCalendarPicture = 'Calendar';

/// The four parts of a cycle, named once in plain words.
const String kTtcFourPartsLine =
    'Your cycle has four parts: your period, the days before your fertile '
    'days, your fertile days (when you can get pregnant), and the wait for '
    'your next period.';
