// =============================================================================
//  Fertility window — the designed screen
// -----------------------------------------------------------------------------
//  Built from `Fertility Window.dc.html` in the "fertile window tool" design
//  project, against the ParentVeda V3 design system. The structure is option
//  **1b**; the "Across this cycle" graphic can be either **1a**'s ranked day
//  list or **1b**'s curve, and 1a is the default.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE TOGGLE IS THE ONLY THING NOT IN THE DESIGN, AND IT IS DELIBERATELY
//  THE SMALLEST POSSIBLE ADDITION
//  ---------------------------------------------------------------------------
//
//  Both graphics answer the same question and neither is strictly better: the
//  list is precise and scannable, the curve shows the SHAPE — that the window
//  has width and that no single day has to be right, which is the reassuring
//  fact this screen exists to deliver.
//
//  So the swap happens in place, inside one card, with the surrounding
//  furniture untouched: same section eyebrow, same card, same "how to read
//  this" affordance. Only the contents cross-fade and slide. A toggle that
//  rebuilt the section around itself would make the screen feel like two
//  screens, which is exactly what a reader does not want when she is comparing
//  two pictures of the same week.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT THE DESIGN FIXED, IN ITS OWN WORDS, AND WHY IT MATTERED
//  ---------------------------------------------------------------------------
//
//  The design note is explicit that the old screen broke three system rules,
//  and all three were live in `TtcFertilityWindowScreen`:
//
//   1. **A violet slab as a card fill.** `_WindowSummary` was a full-bleed
//      purple gradient. The brand colour is spent at decision points only —
//      section eyebrows, links, the active tab — so a violet card makes violet
//      mean nothing. The chroma belongs in the hero field, with dark ink on it.
//   2. **An unlabelled grey paragraph** floating above it with no eyebrow, so
//      it read as stray text rather than as a section.
//   3. **Red on "Ovulation".** Danger is for destructive actions, never for a
//      medical state. Ovulation is the top of the violet ramp here.
//
//  ---------------------------------------------------------------------------
//  ⚠️ NO NUMBER IS EVER SHOWN FOR A DAY
//  ---------------------------------------------------------------------------
//
//  The bars have widths and the curve has a height, and neither is ever
//  rendered as text. The words are Medium / High / Peak / Ovulation, and the
//  line under the graphic says so outright: *the shape ranks the days against
//  each other, it is not a probability.* CLAUDE.md's clinical invariants forbid
//  a personalised probability, and a percentage beside a date is exactly that
//  wearing a chart's clothes.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_fertile_window.dart';
import '../../ttc/ttc_store.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_hero_field.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';
import 'ttc_today_screen.dart' show logTtcPeriod;
import 'ttc_treatment_screen.dart' show TtcTreatmentEntryCard;

/// ⚠️ 273, TAKEN FROM THE DESIGN, NOT FROM THE BRACKET. `accentHue` in
/// `Fertility Window.dc.html` defaults to 273 and every colour on the screen is
/// derived from it — the hero field, the four-stop chance ramp, the curve, the
/// ovulation dot. The conceiving bracket this screen opens from is 344, so the
/// tile is rose and the screen is violet. That is what the design specifies and
/// it is implemented as specified; see the note handed back with this build.
const double kWindowHue = 273;

/// Which picture the "Across this cycle" card is showing.
enum _Across { list, curve }

class TtcWindowScreen extends StatefulWidget {
  const TtcWindowScreen({super.key});

  @override
  State<TtcWindowScreen> createState() => _TtcWindowScreenState();
}

class _TtcWindowScreenState extends State<TtcWindowScreen> {
  /// How many cycles forward she has paged, via the arrows on the cycle card.
  ///
  /// ⚠️ ZERO IS "THE ONE SHE CAN ACT ON", NOT "THIS CALENDAR MONTH". The
  /// projection resolves to the window that is open now or the next one — never
  /// one that has closed. See `ttc_fertile_window.dart`.
  int _cyclesAhead = 0;

  /// ⚠️ THE LIST IS THE DEFAULT. Asked for directly, and it is the right
  /// default anyway: the list answers "which day" without needing to be read as
  /// a picture first, and it is the view that degrades best when someone opens
  /// the screen for four seconds to check a date.
  _Across _view = _Across.list;

  /// -1 when the walkthrough is closed, otherwise the step.
  int _tour = -1;

  /// Which glossary word is open, if any.
  int? _term;

  /// Which day of the window the curve's chips have selected.
  ///
  /// ⚠️ NULL MEANS "NOT CHOSEN YET", AND IT RESOLVES TO PEAK. The design
  /// defaults to the Peak day rather than to the first — opening on the
  /// strongest day is the answer most people came for, and it means the fact
  /// block below is saying something useful before anything is tapped.
  ///
  /// Held here rather than inside the curve view so that a toggle to the list
  /// and back does not lose her choice: the two views are one section, and a
  /// selection surviving the swap is most of what makes that true.
  int? _selDay;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String _d(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  /// ⚠️ THE WALKTHROUGH IS PER VIEW, because the two pictures need different
  /// sentences — "the longer the bar" means nothing on a curve. Switching view
  /// closes it rather than translating the step across, which would land her on
  /// step three of an explanation she has not started.
  List<String> get _tourSteps => _view == _Across.list
      ? const [
          'Each row is one day of your fertile window.',
          'The longer the bar, the better the chance that day.',
          'Peak is the strongest day. Ovulation is when the egg is released.',
        ]
      : const [
          'Left to right is one whole cycle, from day one to your last day.',
          'The line rises on the days when getting pregnant is more likely.',
          'The shaded band is your fertile window: about six days, plus one '
              'day after ovulation, in case it comes a day later.',
          'The dot is ovulation. The dashes show where you are today.',
        ];

  static const _terms = [
    (
      'Cycle',
      'Day 1 is the first day of your period. The next period starts the '
          'next cycle. Twenty-eight days is only the average.'
    ),
    (
      'Period',
      'The bleeding at the start of the cycle, usually three to seven days.'
    ),
    (
      'Ovulation',
      'An egg is released, roughly in the middle of the cycle. It can be '
          'fertilised for about a day.'
    ),
    (
      'Fertile window',
      'The six days when sex can lead to pregnancy: the five days before '
          'ovulation and the day itself. We shade one more day after it, in '
          'case ovulation comes a day later than we estimate.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final p = V2PaletteStore.instance.current;
        final store = TtcStore.instance;
        final today = store.today;

        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(children: [
            Positioned.fill(
              child: V3HeroField(
                accent: v2BlockTint(kWindowHue, p),
                ground: p.ground,
                variant: 2,
                chroma: v3FieldChroma(kWindowHue),
              ),
            ),
            ListView(
              // Zero — the sheet owns the clearance (ttc_tool_chrome.dart).
              padding: EdgeInsets.zero,
              children: [
                _hero(t, p, today),
                _sheet(t, p, today),
              ],
            ),
          ]),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  //  Hero — chroma lives here, and the ink on it is dark
  // ---------------------------------------------------------------------------
  Widget _hero(TtcS t, V2Palette p, TtcToday today) {
    final month = _months[DateTime.now().month - 1];
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Back, not close: this screen is a destination inside the stage, and
          // an X implies a flow she is abandoning.
          Row(children: [
            InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.arrow_back_rounded, size: 20, color: p.ink1),
              ),
            ),
            const SizedBox(width: 8),
            Text(t.fertilityWindow,
                style: pvManrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: p.ink1)),
          ]),
          const SizedBox(height: 20),
          Text(t.windowYourDays,
              style: pvFraunces(
                  fontSize: 27,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                  letterSpacing: -0.6,
                  color: p.ink1)),
          const SizedBox(height: 6),
          Text(
              today.cycleDay == null
                  ? month
                  : 'Cycle day ${today.cycleDay} · $month',
              style: pvManrope(
                  fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink2)),
        ]),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  Sheet
  // ---------------------------------------------------------------------------
  Widget _sheet(TtcS t, V2Palette p, TtcToday today) {
    final window = ttcWindowAhead(_cyclesAhead);

    return Container(
      // Full height, not 0.72 — see the note in ttc_tool_chrome.dart's sheet.
      constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height),
      decoration: BoxDecoration(
        color: p.ground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            // ⚠️ TINTED TO THE GROUND, NOT BLACK. The design system is explicit
            // that a black shadow on a tinted ground clashes, and notes that
            // the Dart side is the half still getting this wrong. This screen
            // is the right direction for that fix to travel from.
            color: const Color(0xFFD0C8DC).withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 28 + ttcBottomInset),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ⚠️ A CLINIC-RUN CYCLE REPLACES THE SCREEN, IT DOES NOT CAVEAT IT. The
        // six-day model is not merely unhelpful on a monitored cycle, it is the
        // wrong model — and drawing it with a footnote underneath would be us
        // offering a second opinion beside the clinic's.
        if (!today.behaviour.showsFertilityWindow) ...[
          TtcTreatmentEntryCard(t: t),
          const SizedBox(height: 20),
          TtcDisclaimer(t: t),
        ] else if (window == null) ...[
          TtcEmpty(
            icon: Icons.wb_twilight_rounded,
            title: t.noEstimateYet,
            body: today.cycleDay == null ? t.ovulationNotYet : t.noEstimateBody,
            cta: today.cycleDay == null ? t.logPeriodCta : null,
            onTap: today.cycleDay == null ? () => logTtcPeriod(context) : null,
          ),
          const SizedBox(height: 20),
          TtcDisclaimer(t: t),
        ] else ...[
          _cycleCard(t, p, window),
          const SizedBox(height: 28),
          _acrossHeader(t, p),
          const SizedBox(height: 10),
          _acrossCard(t, p, window),
          const SizedBox(height: 28),
          _whySixDays(p),
          const SizedBox(height: 22),
          _glossary(p),
          const SizedBox(height: 24),
          TtcDisclaimer(t: t),
        ],
      ]),
    );
  }

  // ---------------------------------------------------------------------------
  //  The cycle card — replaces the violet slab
  // ---------------------------------------------------------------------------
  Widget _cycleCard(TtcS t, V2Palette p, TtcFertileWindow w) {
    final status = w.cyclesAhead > 0
        ? t.windowExpected
        : w.openNow
            ? t.windowOpenNow
            : t.windowOpensIn(w.daysUntilOpen);

    return _Card(
      p: p,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      (w.cyclesAhead == 0 ? 'This cycle' : 'A cycle ahead')
                          .toUpperCase(),
                      style: pvManrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: p.ink3)),
                  const SizedBox(height: 6),
                  Text('${_d(w.opensOn)} – ${_d(w.closesOn)}',
                      maxLines: 1,
                      style: pvFraunces(
                          fontSize: 27,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                          letterSpacing: -0.6,
                          color: p.ink1)),
                ]),
          ),
          const SizedBox(width: 10),
          // ⚠️ BACK IS DISABLED AT ZERO RATHER THAN WRAPPING. Paging past the
          // soonest actionable window should stop; wrapping would silently
          // return her to a cycle she has already passed.
          _Round(
              icon: Icons.chevron_left_rounded,
              p: p,
              enabled: _cyclesAhead > 0,
              onTap: () => setState(() => _cyclesAhead -= 1)),
          const SizedBox(width: 8),
          _Round(
              icon: Icons.chevron_right_rounded,
              p: p,
              enabled: _cyclesAhead < 5,
              onTap: () => setState(() => _cyclesAhead += 1)),
        ]),
        const SizedBox(height: 18),
        // The whole window as one ramp, before any detail. This is the "width
        // is the point" fact, said in one glance.
        Row(children: [
          for (final date in w.days) ...[
            Expanded(
              child: Container(
                height: 9,
                decoration: BoxDecoration(
                  color: _rampColour(w, date, p),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            if (date != w.days.last) const SizedBox(width: 3),
          ],
        ]),
        const SizedBox(height: 12),
        Text('$status · most likely ${_d(w.peakOn)}',
            style: pvManrope(
                fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink2)),
      ]),
    );
  }

  // ---------------------------------------------------------------------------
  //  "Across this cycle" — eyebrow, the toggle, the walkthrough button
  // ---------------------------------------------------------------------------
  Widget _acrossHeader(TtcS t, V2Palette p) {
    return Row(children: [
      Expanded(
        child: Text(t.fertilityAcross.toUpperCase(),
            style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                // ⚠️ THE EYEBROW IS WHERE THE BRAND COLOUR IS SPENT. This is
                // the decision point the system reserves it for, and it is the
                // reason the card below it is white.
                color: p.action)),
      ),
      _ViewToggle(
        value: _view,
        p: p,
        onChanged: (v) => setState(() {
          _view = v;
          // See `_tourSteps`: the sentences differ, so a step index does not
          // survive the swap.
          _tour = -1;
        }),
      ),
    ]);
  }

  Widget _acrossCard(TtcS t, V2Palette p, TtcFertileWindow w) {
    return _Card(
      p: p,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ⚠️ ONE `AnimatedSwitcher`, SIZED BY ITS CHILD, AND THE SLIDE IS
        // HORIZONTAL. Asked for as "a carousel type" — the two pictures are
        // alternatives at the same level, and a horizontal move is how a reader
        // reads that. A fade alone would say "this is loading"; a vertical move
        // would say "this replaced that".
        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            transitionBuilder: (child, anim) {
              final incoming = child.key == ValueKey(_view);
              final dx = _view == _Across.curve ? 1.0 : -1.0;
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(incoming ? dx * 0.14 : -dx * 0.14, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              );
            },
            child: _view == _Across.list
                ? _ListView(
                    key: const ValueKey(_Across.list),
                    window: w,
                    p: p,
                    tour: _tour,
                    fmtDay: _d,
                    weekday: (d) => _weekdays[d.weekday - 1],
                    rank: _rankLabel,
                    fill: _rampColour,
                    width: _barWidth,
                  )
                : _CurveView(
                    key: const ValueKey(_Across.curve),
                    window: w,
                    p: p,
                    tour: _tour,
                    selected: _selDay,
                    onSelect: (i) => setState(() => _selDay = i),
                    fmtDay: _d,
                    weekday: (d) => _weekdays[d.weekday - 1],
                    rank: _rankLabel,
                    fill: _rampColour,
                    note: _dayNote,
                  ),
          ),
        ),
        const SizedBox(height: 14),
        // ⚠️ THIS SENTENCE IS NOT DECORATION. A graphic with a height and a
        // width invites being read as a probability, and this is the line that
        // refuses it. It stays under both views.
        Text(
            'The shape ranks the days against each other. '
            "It isn't a probability.",
            style: pvManrope(fontSize: 11.5, height: 1.4, color: p.ink3)),
        const SizedBox(height: 14),
        _tourRow(p),
      ]),
    );
  }

  /// The walkthrough: one short line at a time, opened from its own pill.
  Widget _tourRow(V2Palette p) {
    final steps = _tourSteps;
    final on = _tour >= 0;

    if (!on) {
      return Align(
        alignment: Alignment.centerLeft,
        child: _Pill(
          p: p,
          label: 'How to read this',
          leading: '?',
          onTap: () => setState(() => _tour = 0),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: Row(children: [
        Text('${_tour + 1} / ${steps.length}',
            style: pvManrope(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: p.action)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(steps[_tour],
              style: pvManrope(
                  fontSize: 12.5,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: p.ink1)),
        ),
        const SizedBox(width: 10),
        _Pill(
          p: p,
          label: _tour < steps.length - 1 ? 'Next' : 'Got it',
          onTap: () => setState(
              () => _tour = _tour < steps.length - 1 ? _tour + 1 : -1),
        ),
      ]),
    );
  }

  Widget _whySixDays(V2Palette p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WHY SIX DAYS',
              style: pvManrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: p.action)),
          const SizedBox(height: 12),
          Text(
              'About six days, ending on the day you ovulate. Sperm survive '
              'about five days, and the egg about one. We add the day after as '
              'well, in case ovulation comes a day later than we estimate. '
              'Because the window is this wide, no single day has to be right.',
              style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2)),
        ],
      );

  /// ⚠️ A GLOSSARY, NOT A TOOLTIP. Four words carry most of the confusion on
  /// this screen, and someone who does not know what "luteal" means will not
  /// hover to find out — she will decide the screen is not for her.
  Widget _glossary(V2Palette p) => _Card(
        p: p,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('New to this? Tap a word.',
              style: pvFraunces(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.35,
                  color: p.ink1)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _terms.length; i++)
                _Pill(
                  p: p,
                  label: _terms[i].$1,
                  selected: _term == i,
                  onTap: () => setState(() => _term = _term == i ? null : i),
                ),
            ],
          ),
          if (_term != null) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.only(top: 14),
              decoration:
                  BoxDecoration(border: Border(top: BorderSide(color: p.line))),
              child: Text(_terms[_term!].$2,
                  style:
                      pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
            ),
          ],
        ]),
      );

  // ---------------------------------------------------------------------------
  //  The ramp
  // ---------------------------------------------------------------------------
  //  ⚠️ ONE FUNCTION FEEDS EVERY GRAPHIC ON THE SCREEN — the summary ramp, the
  //  list bars and the curve. They are three drawings of one fact, and the only
  //  way they cannot disagree is for there to be one place that decides.

  static String _rankLabel(TtcFertileWindow w, DateTime date) {
    if (_sameDay(date, w.peakOn)) return 'Ovulation';
    return switch (ttcFertilityOnDate(w, date)) {
      FertilityLevel.peak => 'Peak',
      FertilityLevel.high => 'High',
      FertilityLevel.medium => 'Medium',
      _ => 'Low',
    };
  }

  /// The violet ramp from the design, four stops. Ovulation is the deepest —
  /// **never red**, which the design calls out as the system's danger colour
  /// being misused for a medical state.
  static Color _rampColour(
      TtcFertileWindow w, DateTime date, V2Palette p) {
    // ⚠️ THE DESIGN'S FOUR STOPS, CONVERTED EXACTLY. hsl(273 52% 58%),
    // hsl(273 46% 69%), hsl(273 40% 79%), hsl(273 34% 87%) — one hue, rising
    // saturation and falling lightness, which is what makes four bars read as
    // one scale rather than four colours.
    if (_sameDay(date, w.peakOn)) return const Color(0xFF995CCC);
    return switch (ttcFertilityOnDate(w, date)) {
      FertilityLevel.peak => const Color(0xFFB48CD4),
      FertilityLevel.high => const Color(0xFFCCB4DF),
      FertilityLevel.medium => const Color(0xFFDFD3E9),
      _ => p.surfaceAlt,
    };
  }

  /// How full the bar runs, 0..1. Derived from the rank rather than stored, so
  /// a day cannot be drawn long and labelled Medium.
  static double _barWidth(TtcFertileWindow w, DateTime date) =>
      switch (_rankLabel(w, date)) {
        'Ovulation' => 1.0,
        'Peak' => 0.86,
        'High' => 0.68,
        'Medium' => 0.4,
        _ => 0.2,
      };

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// The one line under the fact block.
  ///
  /// ⚠️ KEYED ON DISTANCE FROM OVULATION, NOT ON A LIST INDEX. The design ships
  /// seven sentences against seven fixed dates, which is right for a mock and
  /// wrong here: a window is not always seven days, and "the day before
  /// ovulation" has to stay attached to the day before ovulation rather than to
  /// position five. Derived, it survives a short window, a long one, and a peak
  /// that moves.
  static String _dayNote(TtcFertileWindow w, DateTime date) {
    final days = date.difference(w.peakOn).inDays;
    return switch (days) {
      0 => 'Ovulation is most likely today, give or take a day.',
      -1 => 'The day before ovulation. This is the highest of the six.',
      -2 => 'Two days before ovulation is one of the stronger days.',
      -3 => 'Three days before ovulation, and rising.',
      1 => 'The last day we show, in case ovulation came a day late.',
      _ when days < -3 && _sameDay(date, w.opensOn) =>
        'The window opens. Sperm can already be waiting when the egg arrives.',
      _ when days < -3 =>
        'Still early in the window. Nothing has to be timed exactly today.',
      _ => 'Ovulation has passed, and the chance drops quickly.',
    };
  }
}

// =============================================================================
//  1a — the ranked day list
// =============================================================================

class _ListView extends StatelessWidget {
  const _ListView({
    super.key,
    required this.window,
    required this.p,
    required this.tour,
    required this.fmtDay,
    required this.weekday,
    required this.rank,
    required this.fill,
    required this.width,
  });

  final TtcFertileWindow window;
  final V2Palette p;
  final int tour;
  final String Function(DateTime) fmtDay;
  final String Function(DateTime) weekday;
  final String Function(TtcFertileWindow, DateTime) rank;
  final Color Function(TtcFertileWindow, DateTime, V2Palette) fill;
  final double Function(TtcFertileWindow, DateTime) width;

  /// ⚠️ THE WALKTHROUGH DIMS THE COLUMNS IT IS NOT TALKING ABOUT. That is the
  /// whole reason the header row exists as three separately-coloured labels
  /// rather than one string — the graphic teaches itself instead of being
  /// captioned underneath.
  Color _head(int index) =>
      tour == index ? p.action : p.ink3;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          SizedBox(
            width: 50,
            child: Text('DAY', style: _label(_head(0))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text('CHANCE ON THAT DAY', style: _label(_head(1)))),
          const SizedBox(width: 10),
          SizedBox(
            width: 66,
            child: Text('RANKED',
                textAlign: TextAlign.right, style: _label(_head(2))),
          ),
        ]),
      ),
      Container(height: 1, color: p.line),
      const SizedBox(height: 16),
      for (final date in window.days) ...[
        Row(children: [
          SizedBox(
            width: 50,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fmtDay(date),
                      style: pvManrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink1)),
                  Text(weekday(date),
                      style: pvManrope(fontSize: 11, color: p.ink3)),
                ]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(children: [
                    Container(height: 10, color: p.surfaceAlt),
                    FractionallySizedBox(
                      widthFactor: width(window, date),
                      child: Container(
                          height: 10, color: fill(window, date, p)),
                    ),
                  ]),
                ),
              ),
              // The ovulation day gets one extra dot, so the strongest row is
              // distinguishable in a greyscale screenshot too.
              if (rank(window, date) == 'Ovulation') ...[
                const SizedBox(width: 7),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      // hsl(273 52% 40%)
                      color: Color(0xFF6B319B),
                      shape: BoxShape.circle),
                ),
              ],
            ]),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 66,
            child: Text(rank(window, date),
                textAlign: TextAlign.right,
                style: pvManrope(
                    fontSize: 12,
                    fontWeight: rank(window, date) == 'Ovulation'
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: rank(window, date) == 'Medium' ? p.ink3 : p.ink1)),
          ),
        ]),
        if (date != window.days.last) const SizedBox(height: 17),
      ],
    ]);
  }

  TextStyle _label(Color c) => pvManrope(
      fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1, color: c);
}

// =============================================================================
//  1b — the whole cycle as one curve
// =============================================================================

class _CurveView extends StatelessWidget {
  const _CurveView({
    super.key,
    required this.window,
    required this.p,
    required this.tour,
    required this.selected,
    required this.onSelect,
    required this.fmtDay,
    required this.weekday,
    required this.rank,
    required this.fill,
    required this.note,
  });

  final TtcFertileWindow window;
  final V2Palette p;
  final int tour;

  /// Null until she taps, then an index into `window.days`.
  final int? selected;
  final ValueChanged<int> onSelect;
  final String Function(DateTime) fmtDay;
  final String Function(DateTime) weekday;
  final String Function(TtcFertileWindow, DateTime) rank;
  final Color Function(TtcFertileWindow, DateTime, V2Palette) fill;
  final String Function(TtcFertileWindow, DateTime) note;

  /// Peak when nothing has been tapped — see `_TtcWindowScreenState._selDay`.
  int get _index {
    if (selected != null) return selected!.clamp(0, window.days.length - 1);
    final i = window.days.indexWhere((d) =>
        d.year == window.peakOn.year &&
        d.month == window.peakOn.month &&
        d.day == window.peakOn.day);
    // One before ovulation is the design's default. Falls back to ovulation
    // itself on a window too short to have one.
    return i > 0 ? i - 1 : (i < 0 ? 0 : i);
  }

  @override
  Widget build(BuildContext context) {
    const engine = TtcChapterEngine();
    final len = engine.cycleLengthFor(TtcStore.instance.state());

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Transform.rotate(
          angle: -math.pi / 2,
          child: Icon(Icons.chevron_right_rounded, size: 16, color: p.ink3),
        ),
        const SizedBox(width: 4),
        Text('HIGHER CHANCE OF CONCEIVING',
            style: pvManrope(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: p.ink3)),
      ]),
      const SizedBox(height: 10),
      SizedBox(
        height: 150,
        child: CustomPaint(
          size: Size.infinite,
          painter: _CurvePainter(
            window: window,
            cycleLength: len,
            todayCycleDay: TtcStore.instance.today.cycleDay,
            line: p.line,
            ink3: p.ink3,
            tour: tour,
          ),
        ),
      ),
      const SizedBox(height: 4),
      // The axis caption, with the chevron the design puts after it — it reads
      // as "this is the span you are looking at", not as a button.
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('THE $len DAYS OF YOUR CYCLE',
            style: pvManrope(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: p.ink3)),
        const SizedBox(width: 6),
        Icon(Icons.chevron_right_rounded, size: 15, color: p.ink3),
      ]),

      // ---- the seven days, tappable --------------------------------------
      //
      // ⚠️ THE CHIPS ARE WHAT MAKES THE CURVE READABLE. On its own the curve
      // says "there is a shape" and nothing else — no date is legible on it,
      // because the axis is a whole cycle. The chips are how a day gets named,
      // and the fact block under them is the only place the curve view ever
      // states a day in words. Without both, this view is a picture with no
      // way in, which is exactly what it looked like before they were added.
      const SizedBox(height: 18),
      Row(children: [
        for (var i = 0; i < window.days.length; i++) ...[
          Expanded(
            child: _DayChip(
              date: window.days[i],
              p: p,
              selected: i == _index,
              dot: fill(window, window.days[i], p),
              label: weekday(window.days[i]).substring(0, 1),
              onTap: () => onSelect(i),
            ),
          ),
          if (i != window.days.length - 1) const SizedBox(width: 5),
        ],
      ]),

      // ---- and what that day is ------------------------------------------
      const SizedBox(height: 16),
      _FactBlock(
        p: p,
        label: '${fmtDay(window.days[_index])} · '
            '${weekday(window.days[_index])}',
        value: rank(window, window.days[_index]),
        note: note(window, window.days[_index]),
      ),
    ]);
  }
}

/// One day of the window, as a tappable chip.
///
/// ⚠️ THE SELECTED ONE IS AN OUTLINE IN THE ACTION COLOUR, NOT A FILL. Same
/// rule as everywhere else in this system: the brand colour marks the decision
/// point and never becomes a surface. The dot inside keeps the day's own rank
/// colour, so selecting a day never hides what that day is.
class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.date,
    required this.p,
    required this.selected,
    required this.dot,
    required this.label,
    required this.onTap,
  });

  final DateTime date;
  final V2Palette p;
  final bool selected;
  final Color dot;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.fromLTRB(0, 9, 0, 10),
            decoration: BoxDecoration(
              color: selected ? p.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: selected ? p.action : p.line,
                  width: selected ? 1.4 : 1),
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: pvManrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: p.ink3)),
                  const SizedBox(height: 7),
                  Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: dot, shape: BoxShape.circle),
                  ),
                  const SizedBox(height: 7),
                  Text('${date.day}',
                      style: pvManrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: p.ink1)),
                ]),
          ),
        ),
      );
}

/// The system's fact block: a flat well inside a card, label over value.
///
/// ⚠️ FLAT, NOT A CARD. The design system is explicit that a card inside a card
/// gets the flat treatment instead — `surface-alt`, no shadow, no border. This
/// sits inside the "Across this cycle" card, so it is a well.
class _FactBlock extends StatelessWidget {
  const _FactBlock({
    required this.p,
    required this.label,
    required this.value,
    required this.note,
  });

  final V2Palette p;
  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.ink3)),
          const SizedBox(height: 4),
          Text(value,
              style: pvFraunces(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.35,
                  color: p.ink1)),
          const SizedBox(height: 6),
          Text(note,
              style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
        ]),
      );
}

/// The cycle as one shape.
///
/// ⚠️ DRAWN FROM HER OWN WINDOW, NOT FROM A FIXED PATH. The design's SVG is a
/// hand-tuned curve for a 28-day cycle with ovulation on day 19. Copying those
/// coordinates would have produced a picture that stays put while her dates
/// move — the same class of bug as a marker that does not follow today. The
/// peak sits on `peakOn`, the band spans `opensOn..closesOn`, and the axis ends
/// on her own cycle length.
class _CurvePainter extends CustomPainter {
  const _CurvePainter({
    required this.window,
    required this.cycleLength,
    required this.todayCycleDay,
    required this.line,
    required this.ink3,
    required this.tour,
  });

  final TtcFertileWindow window;
  final int cycleLength;
  final int? todayCycleDay;
  final Color line;
  final Color ink3;
  final int tour;

  /// hsl(273 52% 52%) — the curve's stroke.
  static const _violet = Color(0xFF8B45C4);

  /// hsl(273 52% 62%) — the area gradient's top stop.
  static const _violetSoft = Color(0xFFA36CD1);

  /// hsl(273 36% 90%) — the fertile band behind the curve.
  static const _band = Color(0xFFE6DCEF);

  /// hsl(273 52% 42%) — the OVULATION label, darker so it holds on the band.
  static const _violetDeep = Color(0xFF7133A3);

  /// The walkthrough dims everything except the part being explained.
  double _op(String part) {
    if (tour < 0) return 1;
    return switch (tour) {
      0 => part == 'axis' ? 1 : 0.22,
      1 => part == 'curve' ? 1 : 0.22,
      2 => part == 'band' ? 1 : 0.22,
      _ => part == 'marks' ? 1 : 0.28,
    };
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final base = size.height - 32;
    double x(int day) => (day - 1) / (cycleLength - 1) * w;

    // ---- the fertile band ------------------------------------------------
    final bandRect = Rect.fromLTRB(
        x(window.opensCycleDay), 0, x(window.closesCycleDay), base);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bandRect, const Radius.circular(6)),
      Paint()..color = _band.withValues(alpha: _op('band') * 0.9),
    );

    // ---- the baseline ----------------------------------------------------
    canvas.drawLine(Offset(0, base), Offset(w, base),
        Paint()..color = line..strokeWidth = 1);

    // ---- the curve -------------------------------------------------------
    //
    // A bump centred on ovulation, tailing to nothing well before and shortly
    // after. Sampled rather than hand-drawn so it follows her dates.
    final peakX = x(window.peakCycleDay);
    final riseFrom = x(window.opensCycleDay) - w * 0.06;
    final fallTo = x(window.closesCycleDay) + w * 0.05;

    final path = Path()..moveTo(0, base);
    for (var i = 0; i <= 120; i++) {
      final px = w * i / 120;
      double h;
      if (px <= riseFrom || px >= fallTo) {
        h = 0;
      } else if (px <= peakX) {
        final tt = (px - riseFrom) / (peakX - riseFrom);
        h = _smooth(tt);
      } else {
        final tt = (px - peakX) / (fallTo - peakX);
        h = _smooth(1 - tt);
      }
      path.lineTo(px, base - h * (base - 14));
    }
    path.lineTo(w, base);

    final area = Path.from(path)..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _violetSoft.withValues(alpha: 0.55 * _op('curve')),
            _violetSoft.withValues(alpha: 0.04 * _op('curve')),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, base)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..color = _violet.withValues(alpha: _op('curve')),
    );

    // ---- ovulation and today --------------------------------------------
    final marks = _op('marks');
    _dashed(canvas, peakX, base - (base - 14), base,
        _violet.withValues(alpha: marks));
    canvas.drawCircle(Offset(peakX, 14), 4.5,
        Paint()..color = _violet.withValues(alpha: marks));

    if (todayCycleDay != null &&
        todayCycleDay! >= 1 &&
        todayCycleDay! <= cycleLength) {
      final tx = x(todayCycleDay!);
      _dashed(canvas, tx, base - 30, base, ink3.withValues(alpha: marks));
      _text(canvas, 'TODAY', tx, base + 18, ink3.withValues(alpha: marks),
          centre: true);
    }
    _text(canvas, 'OVULATION', peakX, base + 18,
        _violetDeep.withValues(alpha: marks),
        centre: true);

    // ---- axis ------------------------------------------------------------
    final axis = ink3.withValues(alpha: _op('axis'));
    _text(canvas, 'DAY 1', 0, base + 18, axis);
    _text(canvas, 'DAY $cycleLength', w, base + 18, axis, rightAlign: true);
  }

  static double _smooth(double t) {
    final c = t.clamp(0.0, 1.0);
    return c * c * (3 - 2 * c);
  }

  void _dashed(Canvas canvas, double x, double y1, double y2, Color c) {
    final paint = Paint()
      ..color = c
      ..strokeWidth = 1;
    for (var y = y1; y < y2; y += 6) {
      canvas.drawLine(Offset(x, y), Offset(x, math.min(y + 3, y2)), paint);
    }
  }

  void _text(Canvas canvas, String s, double x, double y, Color c,
      {bool centre = false, bool rightAlign = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: pvManrope(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
            color: c),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = centre
        ? x - tp.width / 2
        : rightAlign
            ? x - tp.width
            : x;
    tp.paint(canvas, Offset(dx, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(_CurvePainter old) =>
      old.tour != tour ||
      old.cycleLength != cycleLength ||
      old.todayCycleDay != todayCycleDay ||
      old.window.peakOn != window.peakOn;
}

// =============================================================================
//  Furniture
// =============================================================================

/// The system's card: white, hairline, soft tinted shadow, 20pt radius.
class _Card extends StatelessWidget {
  const _Card({required this.p, required this.child});

  final V2Palette p;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: p.surface,
          border: Border.all(color: p.line),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD0C8DC).withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );
}

/// ⚠️ THERE IS ONE BUTTON IN THIS SYSTEM: an outlined pill with a transparent
/// fill. The design system says so in as many words, and gives the reason — a
/// filled button is the loudest thing on a page, so it decides what the page is
/// FOR, and this page is for the content.
class _Pill extends StatelessWidget {
  const _Pill({
    required this.p,
    required this.label,
    required this.onTap,
    this.leading,
    this.selected = false,
  });

  final V2Palette p;
  final String label;
  final VoidCallback onTap;
  final String? leading;
  final bool selected;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? p.surfaceAlt : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border:
                selected ? null : Border.all(color: p.line, width: 1.2),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (leading != null) ...[
              Container(
                width: 15,
                height: 15,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: p.action, width: 1.4),
                ),
                child: Text(leading!,
                    style: pvManrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: p.action)),
              ),
              const SizedBox(width: 7),
            ],
            Text(label,
                style: pvManrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: leading != null ? p.action : p.ink1)),
          ]),
        ),
      );
}

class _Round extends StatelessWidget {
  const _Round({
    required this.icon,
    required this.p,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final V2Palette p;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Opacity(
          opacity: enabled ? 1 : 0.35,
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: p.line),
            ),
            child: Icon(icon, size: 20, color: p.ink3),
          ),
        ),
      );
}

/// List | Curve, as one small segmented control.
///
/// ⚠️ IT SITS ON THE SECTION HEADER, NOT ON THE CARD. The two views are the
/// same section shown differently, so the control belongs to the section — put
/// on the card it would read as a property of that particular picture, which is
/// the thing it is about to replace.
class _ViewToggle extends StatelessWidget {
  const _ViewToggle({
    required this.value,
    required this.p,
    required this.onChanged,
  });

  final _Across value;
  final V2Palette p;
  final ValueChanged<_Across> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget seg(_Across v, IconData icon, String semantic) {
      final on = v == value;
      return Semantics(
        button: true,
        selected: on,
        label: semantic,
        child: GestureDetector(
          onTap: () => onChanged(v),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 38,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? p.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              boxShadow: on
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD0C8DC).withValues(alpha: 0.55),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, size: 16, color: on ? p.action : p.ink3),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        seg(_Across.list, Icons.view_list_rounded, 'Show as a list'),
        seg(_Across.curve, Icons.show_chart_rounded, 'Show as a curve'),
      ]),
    );
  }
}
