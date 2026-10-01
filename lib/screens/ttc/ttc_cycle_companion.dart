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
import '../../ttc/ttc_day_context.dart' show ttcDayContext;
import '../../ttc/ttc_cycle_report.dart';
import '../../ttc/ttc_store.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_hero_field.dart';
import 'ttc_common.dart';
import 'ttc_what_is_this.dart';
import 'ttc_cycle_report_screen.dart';
import 'ttc_cycle_report_v3.dart';
import 'ttc_home_gap.dart' show showTtcPeriodCameNudge;
import '../../ttc/ttc_treatment_store.dart';
import 'ttc_treatment_round_screens.dart' show showTtcCheckInSheet;
import '../products/pv_store_chrome.dart' show pvSnack;
import 'ttc_cycle_palette.dart';
// Kept for revert (2026-09-27): import 'ttc_phase_colours.dart';
import 'ttc_strings.dart';
import 'ttc_tool_marks.dart' show ttcToolHeaderMark;

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
                  _Hero(p: p, screen: screen, spans: spans, hue: heroHue),
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
  const _Hero(
      {required this.p,
      required this.screen,
      required this.spans,
      required this.hue});

  final V2Palette p;
  final TtcCompanionState screen;
  final List<TtcPhaseSpan> spans;

  /// The field's hue (the phase she is in), so the mark's disc belongs to
  /// the colour behind it (2026-09-29).
  final double hue;

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
                child: Text(kTtcCycleCompanionName,
                    style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: p.ink1)),
              ),
              // What this screen is, in three lines (2026-09-30).
              const TtcWhatIsButton(what: kTtcWhatIsCompanion),
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
            // The tool's mark over the title (2026-09-29, ttc_tool_marks.dart):
            // the object she tapped on the Tools row. 14 + 40 + 12 where the
            // gap was 26, so the hero grows by 40 and no more. Kept for
            // revert: const SizedBox(height: 26),
            const SizedBox(height: 14),
            ttcToolHeaderMark('cycle', v2BlockTint(hue % 360, p))!,
            const SizedBox(height: 12),
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
                // Kept for revert (2026-09-28): Text('Add a date',
                Text('Add a period date',
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
      // H6 (2026-09-28): the reason for "Not in your average", said once.
      // ⚠️ A QUIET LINE ON THE PAGE, NOT A SLAB (2026-09-29, the user: "again
      // in that purple background, it looks not so good"). DESIGN-SYSTEM §4.0
      // gives a note "an icon and a grey line, on the page"; Flo sets its
      // "NOTE:" the same way under its cycle stats
      // (https://mobbin.com/screens/f5511740-f90a-4965-b99f-1f8b1c883ed2).
      // Same words, same icon. Kept for revert: the Container had
      //   padding: EdgeInsets.fromLTRB(14, 11, 14, 11),
      //   decoration: BoxDecoration(color: ttcPanel,
      //       borderRadius: BorderRadius.circular(14)),
      if (ttcCompanionNotCountedNote() case final note?) ...[
        const SizedBox(height: 10),
        SizedBox(
          key: const ValueKey('ttc_companion_not_counted_note'),
          width: double.infinity,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(Icons.info_outline_rounded, size: 16, color: ttcSoft),
            ),
            const SizedBox(width: 9),
            Expanded(child: Text(note, style: ttcBody(12.5, h: 1.45))),
          ]),
        ),
      ],
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

/// The one line that explains "Not in your average" (launch sanity H6,
/// 2026-09-28), or null when every logged cycle counts. Names only the kinds
/// of gap she actually has.
String? ttcCompanionNotCountedNote() {
  final starts = CycleStore.instance.periodStarts;
  var short = false;
  var long = false;
  for (var i = 0; i + 1 < starts.length; i++) {
    final c = CycleStore.instance.cycleFrom(starts[i]);
    if (c == null || c.counted) continue;
    if (c.days < CycleStore.minPlausibleCycleDays) {
      short = true;
    } else {
      long = true;
    }
  }
  if (!short && !long) return null;
  final parts = [
    if (short)
      'under ${CycleStore.minPlausibleCycleDays} days is too short to be a '
          'whole cycle (it may be spotting, or a date logged twice)',
    if (long)
      'over ${CycleStore.maxPlausibleCycleDays} days is usually a month that '
          "wasn't logged",
  ];
  return 'Dates marked Not in your average stay on your list, but they are '
      'left out of your usual length: a gap ${parts.join(', and one ')}.';
}

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
          // ⚠️ NOT "NOW" ON THE 1ST (2026-10-01, a test that runs on the date
          // caught it the morning it was October 1st): the first day of a
          // month shows its month name, and with today's "Now" as well the cell
          // held three lines in 34.8 points and overflowed by 8.2. Today is
          // already the filled ink cell; the month name wins. Kept for revert:
          // `if (isToday && !expected)`.
          if (isToday && !expected && !showsMonth)
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
                            // H6 (2026-09-28): a small tag in the row; the
                            // reason is said once above the list
                            // (`ttcCompanionNotCountedNote`).
                            if (!counted) ...[
                              const SizedBox(height: 6),
                              Container(
                                key: const ValueKey('ttc_period_row_not_counted'),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                    color: ttcPanel,
                                    borderRadius: BorderRadius.circular(999)),
                                child: Text(
                                    tooShort
                                        ? 'NOT IN YOUR AVERAGE · TOO SHORT'
                                        : 'NOT IN YOUR AVERAGE · TOO LONG',
                                    style: pvManrope(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.9,
                                        color: ttcSoft)),
                              ),
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
                  // ⚠️ THE SAME FOUR LINES ON EVERY SUCH ROW (launch sanity H6,
                  // 2026-09-28): eight rejected dates were eight tall cards of
                  // one paragraph, and the dates got lost. The tag is in the
                  // row now and the reason is said once, above the list. Kept
                  // for revert: the block below.
                  // if (!counted) ...[
                  //   const SizedBox(height: 12),
                  //   ttcDivider(),
                  //   const SizedBox(height: 12),
                  //   Row(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Container(
                  //           padding: const EdgeInsets.symmetric(
                  //               horizontal: 10, vertical: 4),
                  //           decoration: BoxDecoration(
                  //               color: ttcPanel,
                  //               borderRadius: BorderRadius.circular(999)),
                  //           // Says what it means (2026-09-27). Kept for
                  //           // revert: 'NOT COUNTED'.
                  //           child: Text('NOT IN YOUR AVERAGE',
                  //               style: pvManrope(
                  //                   fontSize: 9.5,
                  //                   fontWeight: FontWeight.w800,
                  //                   letterSpacing: 1.1,
                  //                   color: ttcSoft)),
                  //         ),
                  //         const SizedBox(width: 10),
                  //         Expanded(
                  //           // One reason per kind of gap (2026-09-27): a
                  //           // ten-day gap used to read "a gap this long".
                  //           // Kept for revert: the long-gap sentence only.
                  //           child: Text(
                  //               tooShort
                  //                   ? 'Too short to be a whole cycle. It may be '
                  //                       'spotting, or a date logged twice. We keep '
                  //                       "it, but we don't use it for your usual "
                  //                       'length.'
                  //                   : "A gap this long is usually a month that "
                  //                       "wasn't logged. We keep it, but we don't "
                  //                       'use it for your usual length.',
                  //               style: ttcBody(13, h: 1.45)),
                  //         ),
                  //       ]),
                  // ],
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

// =============================================================================
//  The home's Period button (launch sanity H1, 2026-09-28)
// -----------------------------------------------------------------------------
//  ⚠️ ONE REFLEX TAP USED TO RESTART HER CYCLE. The home's quick action opened
//  a stock date picker pre-set to TODAY, so tapping OK out of habit logged a
//  new period today and put her back on day 1, while her real period had
//  started nine days earlier. The fix is three rules, in the shape Flo uses
//  for "Edit period dates" (the logged period already marked when the
//  calendar opens, https://mobbin.com/screens/c6a25c29-3cdd-4a0d-8e24-ea9d1be0c6fa)
//  and Clue's one-question calendar
//  (https://mobbin.com/screens/5aaae3cd-d256-4f85-ad8b-a2558ef79850):
//   1. The sheet opens on the start she LOGGED, never on today.
//   2. A line under the calendar says, in words, what the button will do with
//      the day she has picked ("Your period started on 19 Sep" / "Log a new
//      period starting 28 Sep"), and the button's own label says it again.
//   3. Starting a new cycle asks once, then offers Undo (the house rule:
//      tell her before anything changes, and make it reversible).
//  A day close to the logged start (under 15 days either way) is almost
//  always a correction, so the first offer there is to MOVE the start, which
//  keeps what hangs off it (`CycleStore.movePeriodStart`).
// =============================================================================

/// What the home's period sheet will do with the day she picked.
enum TtcHomePeriodIntent {
  /// Nothing logged before: this is her first period with us.
  first,

  /// The day she already logged as this cycle's start. Nothing changes.
  keep,

  /// Another period she already logged. Nothing changes.
  already,

  /// Too close to the logged start to be a new cycle: offer to move it.
  move,

  /// After the logged start by a whole cycle or more: a NEW cycle.
  newCycle,

  /// Well before the logged start: an earlier period she forgot. Her current
  /// cycle is untouched.
  earlier,
}

/// Pure, so the rule is tested without a sheet (test/ttc_home_period_test.dart).
TtcHomePeriodIntent ttcHomePeriodIntent({
  required DateTime? anchor,
  required DateTime picked,
  List<DateTime> starts = const [],
}) {
  DateTime d(DateTime x) => DateTime(x.year, x.month, x.day);
  final p = d(picked);
  if (anchor == null) return TtcHomePeriodIntent.first;
  final a = d(anchor);
  if (p == a) return TtcHomePeriodIntent.keep;
  if (starts.any((s) => d(s) == p)) return TtcHomePeriodIntent.already;
  final gap = p.difference(a).inDays;
  if (gap.abs() < CycleStore.minPlausibleCycleDays) {
    return TtcHomePeriodIntent.move;
  }
  return gap > 0 ? TtcHomePeriodIntent.newCycle : TtcHomePeriodIntent.earlier;
}

/// The words under the calendar for [intent]: what Save will do, said plainly.
String ttcHomePeriodLine(
    TtcHomePeriodIntent intent, DateTime? anchor, DateTime picked) {
  final day = ttcShortDate(picked);
  final from = anchor == null ? '' : ttcShortDate(anchor);
  switch (intent) {
    case TtcHomePeriodIntent.first:
      return 'Your period started on $day.';
    // ⚠️ SAID AS A CHOICE, NOT A RULE (2026-09-30, the user: "nothing
    // changes unless you pick another day… what does it mean?"). The sheet
    // opens on the start she already logged, so the line says that, and
    // what to do if a new period has begun. Kept for revert:
    //   'Your period started on $day. Nothing changes unless you pick '
    //       'another day.'
    case TtcHomePeriodIntent.keep:
      return 'Your period started on $day. If a new one has started, tap '
          'the day it began.';
    case TtcHomePeriodIntent.already:
      return 'A period starting $day is already logged. Nothing changes.';
    case TtcHomePeriodIntent.move:
      final gap = picked.difference(anchor!).inDays.abs();
      return '$day is $gap ${gap == 1 ? 'day' : 'days'} from the start you '
          'logged ($from), too close to be a new cycle. Did this period '
          'really start on $day?';
    case TtcHomePeriodIntent.newCycle:
      return 'Log a new period starting $day. Your cycle starts again at '
          'day 1.';
    case TtcHomePeriodIntent.earlier:
      return 'Add an earlier period starting $day. Your current cycle, from '
          '$from, stays as it is.';
  }
}

/// What a saved period changed, in one short line (2026-09-30): the fertile
/// days it now gives her, or what is still needed before there are any.
/// Read after the save, from the one resolver every date screen uses.
String ttcPeriodSavedNote(DateTime picked, {bool earlier = false}) {
  final saved = earlier
      ? 'Earlier period added: ${ttcShortDate(picked)}.'
      : 'Period saved: ${ttcShortDate(picked)}.';
  final ctx = ttcDayContext(DateTime.now());
  final opens = ctx.windowOpensOn, closes = ctx.windowClosesOn;
  if (!ctx.isCurrentCycle || ctx.cycleOwnership != TimingOwnership.parentveda) {
    return saved;
  }
  if (opens != null && closes != null) {
    return '$saved Fertile days: ${ttcShortDate(opens)} to '
        '${ttcShortDate(closes)}.';
  }
  return '$saved Log your next one too, and your fertile days will show.';
}

/// The home's Period button. Opens the stage's own log sheet on her logged
/// start (or empty, before her first), never on today.
Future<void> showTtcHomePeriodSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      routeSettings: const RouteSettings(name: 'ttc/home_period'),
      builder: (_) => _LogSheet(
          home: true,
          anchor: CycleStore.instance.lastPeriodStart,
          notify: Scaffold.maybeOf(context) != null),
    );

class _LogSheet extends StatefulWidget {
  const _LogSheet({
    this.correcting,
    this.initial,
    this.anchor,
    this.home = false,
    this.notify = true,
  });
  final DateTime? correcting;
  final DateTime? initial;

  /// The home's Period button (H1): the logged start the sheet opens on.
  final DateTime? anchor;

  /// Opened from the home's Period button: says what Save will do and asks
  /// before a new cycle (H1).
  final bool home;

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
    // H1: the home's sheet opens on her LOGGED start, never on today.
    final anchor = widget.home ? widget.anchor : null;
    final seed = widget.correcting ?? usable ?? anchor ?? now;
    _month = DateTime(seed.year, seed.month);
    _picked = widget.correcting ?? usable ?? anchor;
    final owner = widget.correcting ?? anchor;
    _bleed = owner == null ? null : CycleStore.instance.bleedDaysFor(owner);
  }

  /// A period starting on the picked day is already logged (2026-09-30).
  /// Only for the plain "Add a period date" sheet: the home's sheet says so
  /// through its own intent (`already`), and a correction moves a date.
  bool get _duplicate =>
      !widget.home &&
      !_isEdit &&
      _picked != null &&
      CycleStore.instance.periodStarts.any((s) => _sameDay(s, _picked!));

  /// The duplicate's bleeding days differ from what the sheet now holds.
  bool get _duplicateBleedChanged =>
      _duplicate && CycleStore.instance.bleedDaysFor(_picked!) != _bleed;

  TtcHomePeriodIntent? get _homeIntent => !widget.home || _picked == null
      ? null
      : ttcHomePeriodIntent(
          anchor: widget.anchor,
          picked: _picked!,
          starts: CycleStore.instance.periodStarts);

  /// The primary button's label on the home's sheet: the action, not "OK".
  String _homeLabel(TtcHomePeriodIntent intent) {
    final day = ttcShortDate(_picked!);
    switch (intent) {
      case TtcHomePeriodIntent.first:
        return 'Save this period';
      case TtcHomePeriodIntent.keep:
      case TtcHomePeriodIntent.already:
        return 'Done';
      case TtcHomePeriodIntent.move:
        // Kept for revert (2026-09-28, explicit labels): 'Move it to $day'
        return 'Move the start to $day';
      case TtcHomePeriodIntent.newCycle:
        return 'Log a new period';
      case TtcHomePeriodIntent.earlier:
        return 'Add this earlier period';
    }
  }

  /// Asks once before a new cycle starts (H1). Undo follows the save.
  Future<bool> _confirmNewCycle(DateTime picked) async {
    final anchor = widget.anchor;
    final ran = anchor == null ? null : picked.difference(anchor).inDays;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const ValueKey('ttc_home_period_confirm'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text('Start a new cycle on ${ttcShortDate(picked)}?',
            style: ttcFraunces(19, w: FontWeight.w600, color: ttcTitleInk)),
        content: Text(
            anchor != null && ran != null && ran > 0
                ? 'Day 1 becomes ${ttcShortDate(picked)}, and the cycle that '
                    'began on ${ttcShortDate(anchor)} ends at $ran days. You '
                    'can undo this straight after.'
                : 'Day 1 becomes ${ttcShortDate(picked)}. You can undo this '
                    'straight after.',
            style: ttcBody(13.5, h: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Not now',
                style: ttcBody(13, color: ttcSoft, w: FontWeight.w700)),
          ),
          TextButton(
            key: const ValueKey('ttc_home_period_confirm_yes'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Start new cycle',
                style: ttcBody(13, color: ttcTitleInk, w: FontWeight.w800)),
          ),
        ],
      ),
    );
    return ok == true;
  }

  /// Save from the home's sheet: does exactly what the line above it said.
  Future<void> _saveHome({bool separate = false}) async {
    final picked = _picked;
    if (picked == null) return;
    final store = CycleStore.instance;
    final anchor = widget.anchor;
    var intent = _homeIntent!;
    // "Log a separate period" under a Move: a new start after all, asked.
    if (separate) {
      intent = anchor != null && picked.isAfter(anchor)
          ? TtcHomePeriodIntent.newCycle
          : TtcHomePeriodIntent.earlier;
    }
    if (intent == TtcHomePeriodIntent.newCycle) {
      if (!await _confirmNewCycle(picked)) return;
      if (!mounted) return;
    }
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    String? note;
    VoidCallback? undo;
    switch (intent) {
      case TtcHomePeriodIntent.keep:
      case TtcHomePeriodIntent.already:
        final before = store.bleedDaysFor(picked);
        if (before != _bleed) {
          store.logBleedDays(picked, _bleed);
          note = 'Saved';
        }
      case TtcHomePeriodIntent.move:
        store.movePeriodStart(anchor!, picked);
        store.logBleedDays(picked, _bleed);
        note = 'Moved to ${ttcShortDate(picked)}';
        undo = () => store.movePeriodStart(picked, anchor);
      case TtcHomePeriodIntent.first:
      case TtcHomePeriodIntent.newCycle:
      case TtcHomePeriodIntent.earlier:
        store.logPeriodStart(picked);
        store.logBleedDays(picked, _bleed);
        // ⚠️ THE NOTICE SAYS WHAT THE SAVE CHANGED (2026-09-30). She logged
        // 8 September, the home still said "Not enough logged", and it read
        // as a tap that did nothing (the user: "I kept logging the period,
        // nothing was happening"). Now the notice names the result: her
        // fertile days if there are some, or what is still needed.
        // Kept for revert:
        //   note = intent == TtcHomePeriodIntent.earlier
        //       ? 'Earlier period added: ${ttcShortDate(picked)}'
        //       : 'Period saved: started ${ttcShortDate(picked)}';
        note = ttcPeriodSavedNote(picked,
            earlier: intent == TtcHomePeriodIntent.earlier);
        undo = () => store.removePeriodStart(picked);
    }
    HapticFeedback.selectionClick();
    navigator.maybePop();
    if (note != null && messenger != null && widget.notify) {
      // No `lift` (2026-09-30): pvSnack places it by the screen underneath,
      // above the home's tab bar or at the foot of any other TTC page. The
      // fixed 24 hid it behind the home's bar. Kept for revert: lift: 24.
      pvSnack(navigator.context, note,
          icon: Icons.check_rounded,
          action: undo == null ? null : 'Undo',
          onAction: undo);
    }
    // A period logged while a treatment round waits on a check-in opens the
    // check-in, as `logTtcPeriod` always did (docs/TTC-TREATMENT-FLOW.md
    // decision 3). The period itself is saved either way.
    if ((intent == TtcHomePeriodIntent.newCycle ||
            intent == TtcHomePeriodIntent.first) &&
        TtcTreatmentStore.instance.checkInDue() &&
        navigator.mounted) {
      await showTtcCheckInSheet(navigator.context);
    }
    // ⚠️ NO "TALK IT THROUGH" NOTICE HERE, ON PURPOSE: it would replace the
    // Undo, and on this sheet the Undo is the promise. The home still says
    // the kind line on day one (`TtcPeriodCameLine`), which links the read.
  }

  void _save() {
    final picked = _picked;
    if (picked == null) return;
    final store = CycleStore.instance;

    // ⚠️ ALREADY LOGGED IS SAID, NOT SAVED AGAIN (2026-09-30, the user: "if
    // I have logged the period for 8th of September and I re-log it… it
    // should tell me that you have already done that… if I change the
    // bleeding days then… make the change in the original log"). The line
    // above the button said so before the tap; this does what it said.
    if (_duplicate) {
      final changed = _duplicateBleedChanged;
      if (changed) store.logBleedDays(picked, _bleed);
      HapticFeedback.selectionClick();
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.maybeOf(context);
      navigator.maybePop();
      if (messenger != null && widget.notify) {
        pvSnack(
          navigator.context,
          changed
              ? 'Bleeding days updated for ${ttcShortDate(picked)}.'
              : '${ttcShortDate(picked)} was already logged. Nothing changed.',
          icon: Icons.check_rounded,
        );
      }
      return;
    }

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
      // The result, not only the save (2026-09-30), placed by pvSnack.
      // Kept for revert: 'Period saved: started …' with lift: 24.
      pvSnack(
        navigator.context,
        _isEdit
            ? 'Changed to ${ttcShortDate(picked)}'
            : ttcPeriodSavedNote(picked),
        icon: Icons.check_rounded,
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
                  Text(
                      _isEdit
                          ? 'CORRECT A DATE'
                          : widget.home && widget.anchor != null
                              ? 'YOUR PERIOD'
                              : 'LOG A PERIOD',
                      style: pvManrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: ttcMuted)),
                  const SizedBox(height: 8),
                  // Kept for revert (2026-09-28, explicit labels):
                  //   'When did it really start?' : 'When did it start?'
                  Text(
                      _isEdit
                          ? 'When did your period really start?'
                          : 'When did your period start?',
                      style: ttcFraunces(22,
                          w: FontWeight.w600, color: ttcTitleInk, h: 1.2)),
                  const SizedBox(height: 6),
                  // ⚠️ THE DEFINITION IS ON THE SCREEN THAT ASKS. "Day 1" means
                  // real bleeding and not spotting, and every derived number in
                  // this stage hangs off her getting that right. Saying it in a
                  // help article instead would be saying it to the people who
                  // already knew.
                  Text(
                      widget.home && widget.anchor != null
                          ? 'The first day of real bleeding, not spotting. '
                              'The start you logged is picked; choose '
                              'another day only if a new period has begun.'
                          : 'The first day of real bleeding, not spotting.',
                      style: ttcBody(13, h: 1.45)),
                  const SizedBox(height: 18),

                  _MonthPicker(
                    month: _month,
                    picked: _picked,
                    logged: widget.home ? widget.anchor : null,
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
                  if (_homeIntent case final intent?) ...[
                    // H1: what the button will do, in words, before she taps.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: BoxDecoration(
                        // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
                        color: Colors.white, border: const Border.fromBorderSide(BorderSide(color: ttcLine)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                          ttcHomePeriodLine(intent, widget.anchor, _picked!),
                          key: const ValueKey('ttc_home_period_line'),
                          style: ttcBody(13.5,
                              color: ttcTitleInk, w: FontWeight.w600, h: 1.45)),
                    ),
                    const SizedBox(height: 12),
                    _QuietAction(
                      key: const ValueKey('ttc_home_period_save'),
                      label: _homeLabel(intent),
                      onTap: () => _saveHome(),
                    ),
                    if (intent == TtcHomePeriodIntent.move) ...[
                      const SizedBox(height: 10),
                      _QuietAction(
                        key: const ValueKey('ttc_home_period_separate'),
                        label: 'No, log a separate period',
                        muted: true,
                        onTap: () => _saveHome(separate: true),
                      ),
                    ],
                  ] else ...[
                    // A day already logged says so before the tap
                    // (2026-09-30), in the home sheet's white line.
                    if (_duplicate) ...[
                      Container(
                        key: const ValueKey('ttc_period_already_line'),
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: const Border.fromBorderSide(
                              BorderSide(color: ttcLine)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                            _duplicateBleedChanged
                                ? 'You already logged a period starting '
                                    '${ttcShortDate(_picked!)}. Saving '
                                    'updates its bleeding days.'
                                : 'You already logged a period starting '
                                    '${ttcShortDate(_picked!)}.',
                            style: ttcBody(13.5,
                                color: ttcTitleInk,
                                w: FontWeight.w600,
                                h: 1.45)),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Kept as it was for every other caller.
                    _QuietAction(
                      label: _isEdit
                          ? 'Save the correction'
                          : _duplicate
                              ? (_duplicateBleedChanged
                                  ? 'Update bleeding days'
                                  : 'Done')
                              : 'Save this period',
                      onTap: _picked == null ? null : _save,
                    ),
                  ],
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
    this.logged,
    required this.today,
    required this.onMonth,
    required this.onPick,
  });

  final DateTime month;
  final DateTime? picked;

  /// The start she logged (the home's sheet, H1): a small dot under its
  /// number, so it stays findable when she picks another day.
  final DateTime? logged;
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
              logged: logged,
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
    this.logged,
    required this.today,
    required this.onPick,
  });

  final int day;
  final DateTime date;
  final DateTime? picked;
  final DateTime? logged;
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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('$day',
              style: ttcBody(13,
                  color: future
                      ? ttcBorder
                      : on
                          ? Colors.white
                          : ttcTitleInk,
                  w: on ? FontWeight.w800 : FontWeight.w600)),
          // H1: the start she logged keeps a dot when another day is picked.
          if (!on && logged != null && _sameDay(logged!, date))
            Container(
              key: const ValueKey('ttc_period_logged_dot'),
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(top: 2),
              decoration: const BoxDecoration(
                  color: TtcCycleColours.period, shape: BoxShape.circle),
            ),
        ]),
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
          // ⚠️ NO LAVENDER FILL (2026-09-30, the user on the month arrows:
          // "you can still see that purple background which is not needed").
          // White with a hairline, as the day chips below. Kept for revert:
          //   color: ttcPanel, borderRadius: BorderRadius.circular(11)
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: ttcLine),
              shape: BoxShape.circle),
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
          // ⚠️ NO LAVENDER FILL BEHIND THE NUMBERS (2026-09-30, the user:
          // "why is there this purple background thing still behind the
          // numbers? I said no to it"). An unpicked chip is white with a
          // hairline, a picked one ink, the base UI's chip. Kept for revert:
          //   color: on ? ttcTitleInk : ttcPanel,
          decoration: BoxDecoration(
            color: on ? ttcTitleInk : Colors.white,
            border: Border.all(color: on ? ttcTitleInk : ttcLine),
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
  // ⚠️ A LABEL AND A NUMBER ON THE CARD'S WHITE, NOT A NUMBER IN A SLAB
  // (2026-09-29, the user on "A STARTING GUESS / 28 days": "a dark purplish
  // background for no reason whatsoever… what is that even trying to do").
  // The stat is the fact; a filled box around it adds a second surface that
  // says nothing. Flo's cycle stats are exactly this, a grey label over a
  // bold value on white (https://mobbin.com/screens/f5511740-f90a-4965-b99f-1f8b1c883ed2),
  // and Clue's "Shortest: 26 days" sits bare on its page
  // (https://mobbin.com/screens/fde0d1b4-7268-4f33-8079-2e97e98b77fc).
  // The label moves to ttcSoft: at 9.5pt the old ttcMuted measured 3.6:1 on
  // white, under WCAG AA's 4.5. Kept for revert:
  //   padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
  //   decoration: BoxDecoration(
  //       color: ttcPanel, borderRadius: BorderRadius.circular(14)),
  //   label color: ttcMuted
  Widget build(BuildContext context) => SizedBox(
        key: const ValueKey('ttc_companion_fact'),
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: ttcSoft)),
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
    super.key,
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
