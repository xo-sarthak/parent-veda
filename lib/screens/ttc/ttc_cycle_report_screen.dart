// =============================================================================
//  TtcCycleReportScreen — a month of logging, given back
// -----------------------------------------------------------------------------
//  ⚠️ REBUILT. The first version was unreadable and the note was fair: *"When I
//  see my cycle report I cannot understand what is this graph at all. If I
//  cannot understand it, being an educated person, no one will."*
//
//  Four things were wrong, and each has a general lesson worth keeping:
//
//    1. **The chart had no context.** A line and two axis numbers, floating.
//       A chart is only readable if it says what it is measuring, over what
//       span, against what — so it now carries its own title, its unit, date
//       ticks, the phase bands behind it, and marker rows underneath for
//       period, sex and tests. The line is the smallest part of a chart.
//    2. **Sections existed to explain their own emptiness.** "Changes during
//       the cycle → add a weight and a chart appears here" is a heading, a card
//       and a paragraph spent on nothing. Empty states belong INSIDE the thing
//       that is empty, not as a section of their own.
//    3. **Purple everywhere.** Same mistake as the logger: the stage's accent
//       used as its ground. Colour here comes from the cycle PHASES, which are
//       the only thing on the screen that colour actually means something about.
//    4. **The disclaimer ate the foot of the page.** It is an ⓘ in the header
//       now — reachable, not occupying the last screenful.
//
//  ⚠️ AND IT IS FOR HER, NOT FOR A CLINIC. Decided explicitly. That is why it
//  is four things readable in twenty seconds rather than a printable summary —
//  a doctor-facing export is a different document and would be denser, drier
//  and organised by system rather than by month.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_cycle_report.dart';
import '../v2/v2_palette.dart';
import '../../theme/pv_fonts.dart';
import 'ttc_common.dart';
import '../v2/v3_hero_field.dart' show v3FieldChroma;
import 'ttc_cycle_companion.dart' show showTtcPeriodLogSheet;
// Kept for revert (2026-09-27): ... show kTtcCompanionHue, showTtcPeriodLogSheet;
import 'ttc_cycle_palette.dart';
import 'ttc_cycle_report_states.dart';
import 'ttc_cycle_report_v3.dart';
import 'ttc_symptom_log_screen.dart'
    show
        TtcSymptomLogScreen,
        kTtcLogMeasurementsGroup,
        TtcMeasureKind,
        showTtcMeasureSheet;
import 'ttc_surface_router.dart';
import 'ttc_strings.dart';
import 'ttc_tool_chrome.dart';

class TtcCycleReportScreen extends StatefulWidget {
  const TtcCycleReportScreen({super.key, this.series});

  /// Which number the chart opens on, when she came from that number's
  /// "View chart" in the logger (launch sanity U2, 2026-09-28): the chart is
  /// shown on that series and scrolled into view. Null opens as before.
  final TtcMeasureKind? series;

  @override
  State<TtcCycleReportScreen> createState() => _TtcCycleReportScreenState();
}

class _TtcCycleReportScreenState extends State<TtcCycleReportScreen> {
  int _index = 0;
  // U2 (2026-09-28): preset from `widget.series`. Kept for revert:
  //   bool _showTemp = false;
  late bool _showTemp = widget.series == TtcMeasureKind.temperature;

  /// The "changes during the cycle" heading, so a "View chart" from the
  /// logger lands on the chart instead of the top of the page.
  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.series != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final c = _chartKey.currentContext;
        if (c != null && c.mounted) {
          Scrollable.ensureVisible(c,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic);
        }
      });
    }
  }

  /// Whether the ⓘ panel is open. Not remembered between visits — it is an
  /// aside, and one she has read once she does not need reopened for her.
  bool _about = false;

  /// ⚠️ THE DIAL, AND IT IS NOT REMEMBERED BETWEEN VISITS. A stored preference
  /// here would be a setting nobody set — she picks a picture to answer the
  /// question in front of her, not to declare how she likes cycle reports. If
  /// it turns out people flip it every single time, that is the evidence for
  /// persisting it, and there is none yet.
  ///
  /// ⚠️ THE REPORT DRAWS THE DAYS, NOT THE RING (launch sanity H4,
  /// 2026-09-28). The Cycle companion and this report both opened on the same
  /// ring, the same four-part key and the same "Day 10" in the middle: two
  /// screens, one picture, and no way to tell which to use. The ring is the
  /// Companion's (where you are, this cycle, your dates); the report is each
  /// cycle's days in order with what she logged on them, paged cycle by
  /// cycle. The toggle below is commented out, not deleted. Kept for revert:
  ///   TtcCycleView _view = TtcCycleView.dial;
  // ignore: prefer_final_fields
  TtcCycleView _view = TtcCycleView.calendar;

  static const _m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static String _fmt(DateTime d) => '${d.day} ${_m[d.month - 1]}';

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    final r = ttcBuildCycleReport(index: _index);

    // ⚠️ THE V3 PICTURES RENDER FOR ONE STATE, ON PURPOSE. The design project
    // drew a cycle that has a period, an estimate and four stretches — the
    // `ready` state. The other four (nothing logged, a clinic running the
    // cycle, an estimate refused, almost nothing logged) have not been designed
    // yet and are keeping the treatment they already ship, which is reviewed
    // copy that works.
    //
    // Building them on the new chrome would mean inventing a hero line for
    // "your clinic is running this cycle" — and a screen that says a phase in
    // 40pt type above a panel explaining that we may not name a phase is a
    // contradiction, not a gap. Recorded in `docs/STILL-OPEN.md` §18.
    // ⚠️ GATED ON THE PICTURE BEING DRAWABLE, NOT ON `ready`. The first cut
    // asked for `state == ready`, and that was a real bug with a very quiet
    // symptom: almost nobody saw the new report.
    //
    // `ready` degrades to `thin` the moment fewer than three days in the cycle
    // have ANYTHING logged — a symptom, a weight, a temperature. That is most
    // people most months, and it is the correct rule for whether we have
    // findings worth printing. It has nothing to do with whether we can draw
    // the cycle: the ring, the calendar and the four stops need a period and an
    // estimate, and `thin` has both.
    //
    // So the two questions are separated. `spans.isNotEmpty` answers "can we
    // draw this cycle" — it is already empty on every refusal — and the
    // findings section answers itself further down by rendering nothing.
    final spans = ttcCyclePhaseSpans(index: _index);
    if (spans.isNotEmpty &&
        (r.state == TtcReportState.ready || r.state == TtcReportState.thin)) {
      return _v3(context, t, r, spans);
    }

    // ⚠️ AND THE OTHER THREE ARE DESIGNED NOW TOO, so the screen no longer has
    // two chromes depending on her data. Turn 2 of the design project drew
    // nothing-logged, no-estimate and clinic-held; each gets the same hero,
    // the same picker and the same sheet as the cycle that can be drawn.
    return _states(context, t, r);
  }

  /// The three states where there is no cycle to draw.
  ///
  /// ⚠️ ALL THREE SHARE THE SHELL AND DIFFER IN THE SHEET, which is the point:
  /// a refusal that changed the whole screen would read as a different feature
  /// rather than as this one having nothing to say this month.
  Widget _states(BuildContext context, TtcS t, TtcCycleReport r) {
    final clinic = r.state == TtcReportState.clinicHeld;
    final empty = r.state == TtcReportState.noPeriod;
    final facts = TtcReportFacts.read();

    final (String chip, String title) = switch (r.state) {
      TtcReportState.noPeriod => ('No cycle yet', t.reportNoPeriod),
      TtcReportState.clinicHeld => (ttcClinicChip(), t.reportClinicTitle),
      // Kept for revert: 'Your dates are here', which did not say which of
      // the three pages this is (2026-09-27).
      _ => ('No estimate this cycle', t.reportNoEstimateTitle),
    };

    return TtcToolScaffold(
      // ⚠️ THE FIELD VARIANT CHANGES WITH THE STATE, from the design: 1 on the
      // empty page, 3 where we will not estimate, 5 where a clinic is running
      // it. One composition for every state would make three different
      // situations look like one screen that failed to load.
      // ⚠️ A NEAR-GREY FIELD WHERE NO PART IS NAMED (2026-09-27). It was the
      // Companion's violet-magenta, one more colour meaning nothing on a page
      // that is explaining why it draws no phases. Kept for revert:
      //   hue: kTtcCompanionHue,
      hue: TtcCycleColours.heroHue(null),
      chroma: v3FieldChroma(TtcCycleColours.heroHue(null)) *
          TtcCycleColours.heroChromaScale(null),
      variant: switch (r.state) {
        TtcReportState.noPeriod => 1,
        TtcReportState.clinicHeld => 5,
        _ => 3,
      },
      eyebrow: t.reportTitle,
      title: title,
      action: IconButton(
        icon: const Icon(Icons.info_outline_rounded, size: 21),
        color: ttcInk, // ink on the field (2026-09-29, 2.8:1 in ttcSoft); was ttcMuted
        onPressed: () => setState(() => _about = !_about),
      ),
      heroLead: _CyclePicker(
        // ⚠️ THE PICKER STAYS, DIMMED, ON THE EMPTY PAGE. Removing it would
        // change the shape of the header between states, and she would have to
        // work out whether this is the same screen. It says "No cycles yet"
        // and does nothing, which is honest.
        label: empty
            ? 'No cycles yet'
            : r.start == null
                ? ''
                : '${_fmt(r.start!)} to ${_fmt(r.end!)}',
        caption: empty ? null : ttcWhichCycle(_index, r.cyclesAvailable),
        onLatest: _index > 0 ? () => setState(() => _index = 0) : null,
        canGoBack: !empty && _index + 1 < r.cyclesAvailable,
        canGoForward: !empty && _index > 0,
        onBack: () => setState(() => _index++),
        onForward: () => setState(() => _index--),
      ),
      children: [
        ttcToolPad(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),
            Text(chip.toUpperCase(),
                style: pvManrope(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: ttcMuted)),
            const SizedBox(height: 18),
            if (_about) ...[
              TtcReportAbout(text: ttcReportAboutText(clinic: clinic)),
              const SizedBox(height: 22),
            ],
            if (empty)
              TtcReportEmptyBody(onLog: () => _openLog(context))
            else if (clinic)
              TtcReportRefusalBody(
                report: r,
                facts: facts,
                eyebrow: 'Who is guiding this cycle',
                // Change 5 (2026-09-28). Kept for revert: 'Your doctor is
                // timing this one'.
                title: 'Your doctor is timing this cycle',
                body: "You've marked this as a treatment cycle. Your clinic "
                    'is scanning you and choosing the dates, and they can see '
                    'things this page never will.',
                // "Stretches" was our word; "parts" is hers (2026-09-27).
                body2: "So we're not putting our estimate next to theirs. "
                    "Nothing is wrong with your dates. They're all below, "
                    'and the four parts of your cycle come back the month '
                    'after your treatment cycle ends.',
                actionLabel: 'Prepare questions for your next visit',
                onAction: () => _openSurface(context, 'ttc_appointments'),
                footLabel: "This isn't a treatment cycle",
                onFoot: () => _openSurface(context, 'ttc_profile'),
                footNote: 'Your rhythm numbers come from your own history and '
                    "keep updating. They're not an estimate for this cycle.",
              )
            else
              TtcReportRefusalBody(
                report: r,
                facts: facts,
                eyebrow: 'Why there are no phases',
                title: "We'd rather not guess",
                // ⚠️ THE ACTUAL NUMBER, READ FROM HER DATA. The design writes
                // 46 days because that is what its fixture held. A refusal that
                // cannot name the gap it is refusing over is asking to be
                // taken on trust, on the one screen that is explaining why it
                // will not do that itself.
                body: facts.longestGap == null
                    ? "There isn't enough here yet to place the four "
                        'parts of your cycle.'
                    : 'One gap in your dates runs ${facts.longestGap} days. '
                        "That's long enough to be a month that went unlogged, "
                        'not a cycle that really lasted that long.',
                body2: 'If we counted it in, the fertile days we showed could '
                    "be off by more than a week. So we've left them off this "
                    "cycle, instead of showing you dates we don't trust.",
                actionLabel: 'Fill in the missing month',
                onAction: () => _openLog(context),
                // The action that fixes it, above the reason (2026-09-27).
                actionFirst: true,
                note: facts.longestGap == null
                    ? null
                    : 'If you really had a ${facts.longestGap}-day cycle, leave '
                        'it as it is. Two more periods will settle the number '
                        'on their own.',
                // One name with the Tools tile (2026-09-27). Kept for revert:
                // 'Open the Cycle Companion'.
                footLabel: 'Open your cycle companion',
                onFoot: () => _openSurface(context, 'ttc_cycle'),
                footNote: 'Estimates come from your own dates and are never a '
                    "diagnosis. If your cycles stay irregular, it's worth "
                    'asking a doctor to take a look.',
              ),
            const SizedBox(height: 10),
          ],
        )),
      ],
    );
  }

  // Every card on this page is `TtcCycleCard` since 2026-09-27 (a hairline,
  // not the V1 `TtcCard` shadow). Kept for revert: TtcCard( at five sites.
  void _openLog(BuildContext context) => showTtcPeriodLogSheet(context);

  /// The daily log on today: where symptoms, weight and morning temperature
  /// are all entered.
  // Opens today's log scrolled to weight and temperature, the two things the
  // button names (2026-09-28). Kept for revert:
  //   openTtcSurface(context, 'ttc_symptom_log');
  void _openLogToday(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'ttc/symptom_log'),
          builder: (_) => const TtcSymptomLogScreen(
              focusGroup: kTtcLogMeasurementsGroup)));

  /// ⚠️ THE NUMBER IS ADDED HERE, NOT IN THE LOGGER (launch sanity U2,
  /// 2026-09-28). "Add today's temperature or weight" pushed the whole
  /// symptom logger, scrolled to its foot; the user: "let the user add it
  /// there only, instead user is taken to symptoms page bottom". Each link
  /// now opens the logger's own number sheet (`showTtcMeasureSheet`, one
  /// piece shared by both screens) over this page, saves to the same store,
  /// and the chart above redraws the moment it closes. `_openLogToday` stays
  /// for "Log how today went", which is about the day, not a number.
  void _addNumber(BuildContext context, TtcMeasureKind kind) =>
      showTtcMeasureSheet(context, kind, DateTime.now(), onChanged: () {
        if (mounted) setState(() {});
      });

  /// Two links, one per number, where there was one link for both: the
  /// choice is made on the card, so the sheet opens on the right number in
  /// one tap. Stardust puts an "Add" on its Temperature row
  /// (https://mobbin.com/screens/4fb4438f-6715-4122-a1c4-db54b4bee75e),
  /// Lifesum an "Add new amount" under each measurement
  /// (https://mobbin.com/screens/3e616b8e-f8d7-4a7f-aad2-957bf99a4c5d), and
  /// Clue enters each measure in its own section of the day
  /// (https://mobbin.com/screens/f4526107-52d1-43b1-8d75-f485432dfba4).
  /// Under a chart it is one link for the series on show, because a chart
  /// page's add is for that chart: Apple Health's + on Blood Pressure
  /// (https://mobbin.com/screens/f6471b67-8921-4d71-826b-476849a1ec61) and
  /// Future Pro's + on Weight, which opens the entry over the chart
  /// (https://mobbin.com/screens/ffb9ac16-40be-4506-b607-97b9e292fe07).
  /// Kept for revert (2026-09-28): one `_ReportLink` keyed
  /// `ttc_report_add_numbers`, label `kTtcReportAddNumbers`, onTap
  /// `_openLogToday(context)`.
  Widget _addNumbers(BuildContext context, {TtcMeasureKind? only}) => Wrap(
        key: const ValueKey('ttc_report_add_numbers'),
        spacing: 8,
        runSpacing: 8,
        children: [
          if (only != TtcMeasureKind.weight)
          _ReportLink(
            key: const ValueKey('ttc_report_add_temp'),
            icon: Icons.thermostat_rounded,
            label: kTtcReportAddTemp,
            onTap: () => _addNumber(context, TtcMeasureKind.temperature),
          ),
          if (only != TtcMeasureKind.temperature)
          _ReportLink(
            key: const ValueKey('ttc_report_add_weight'),
            icon: Icons.monitor_weight_outlined,
            label: kTtcReportAddWeight,
            onTap: () => _addNumber(context, TtcMeasureKind.weight),
          ),
        ],
      );

  void _openSurface(BuildContext context, String id) =>
      openTtcSurface(context, id);

  /// ⚠️ THE OLD BODY, KEPT FOR REVERT PER CLAUDE.md. It was the plain-list
  /// treatment every state wore before turn 2 of the design: a back bar, the
  /// picker, a `_Note` panel for the two refusals and the chart card. Nothing
  /// reaches it now.
  // ignore: unused_element
  Widget _legacyBody(BuildContext context, TtcS t, V2Palette p,
      TtcCycleReport r) {
    return Scaffold(
      backgroundColor: ttcBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              ttcGutter, 6, ttcGutter, ttcBottomInset),
          children: [
            // ---- header, with the disclaimer behind an ⓘ ----------------
            Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: ttcTitleInk,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(child: Text(t.reportTitle, style: ttcJakarta(18))),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, size: 21),
                color: ttcMuted,
                onPressed: () => _showDisclaimer(context, t),
              ),
            ]),
            const SizedBox(height: 6),

            if (r.state == TtcReportState.noPeriod) ...[
              _Empty(title: t.reportNoPeriod, body: t.reportNoPeriodBody),
            ] else ...[
              _CyclePicker(
                label: r.start == null
                    ? ''
                    : '${_fmt(r.start!)} to ${_fmt(r.end!)}',
                canGoBack: _index + 1 < r.cyclesAvailable,
                canGoForward: _index > 0,
                onBack: () => setState(() => _index++),
                onForward: () => setState(() => _index--),
              ),
              const SizedBox(height: 16),

              // ⚠️ A REFUSAL, NOT AN ERROR, AND IT LOOKS LIKE NEITHER A WARNING
              // NOR A GAP. Quiet panel, plain sentence, and the data below it
              // renders exactly as it would otherwise — minus the phase bands
              // that are not ours to draw.
              if (r.state == TtcReportState.clinicHeld ||
                  r.state == TtcReportState.noEstimate) ...[
                _Note(
                  title: r.state == TtcReportState.clinicHeld
                      ? t.reportClinicTitle
                      : t.reportNoEstimateTitle,
                  body: r.state == TtcReportState.clinicHeld
                      ? t.reportClinicBody
                      : t.reportNoEstimateBody,
                ),
                const SizedBox(height: 16),
              ],

              // ---- one card: the cycle, the chart, the markers ---------
              //
              // ⚠️ MERGED. These were three sections — the day strip, the
              // chart, and an empty "changes during the cycle". They are one
              // picture of one month, and splitting them meant three headings
              // for a thing the reader thinks of as one.
              _CycleCard(
                report: r,
                p: p,
                showTemp: _showTemp,
                onPickSeries: (v) => setState(() => _showTemp = v),
              ),
              const SizedBox(height: 18),

              // ---- what it adds up to ----------------------------------
              //
              // ⚠️ ABSENT BELOW A WEEK OF LOGGING, and absent when nothing
              // clustered. Silence is the correct output of a report with
              // nothing to report — see the note in `ttc_cycle_report.dart`.
              if (_notes(r).isNotEmpty) ...[
                ttcSectionTitle(t.reportWhatYouLogged),
                for (final f in _notes(r)) ...[
                  TtcCycleCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.headline,
                              style: ttcFraunces(16,
                                  w: FontWeight.w600, color: ttcTitleInk)),
                          const SizedBox(height: 5),
                          Text(f.detail, style: ttcBody(13, h: 1.55)),
                        ]),
                  ),
                  const SizedBox(height: 10),
                ],
              ] else if (r.state == TtcReportState.thin) ...[
                _Note(title: t.reportThinTitle, body: t.reportThinBody),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// The `ready` report, drawn from the Cycle Report design project.
  ///
  /// ⚠️ THE HERO TAKES THE CURRENT STRETCH'S COLOUR, not the stage accent. That
  /// is `V3HeroField`'s own instruction — one colour decision, so the field
  /// behind the page and the arc she is standing on cannot disagree. On a
  /// screen whose entire job is "where am I in this", two different colours
  /// meaning the same moment would be the one mistake worth avoiding.
  Widget _v3(
    BuildContext context,
    TtcS t,
    TtcCycleReport r,
    List<TtcPhaseSpan> spans,
  ) {
    final here = spans.firstWhere(
      (s) => s.status == TtcSpanStatus.here,
      orElse: () => spans.first,
    );
    final today = spans.any((s) => s.status == TtcSpanStatus.here)
        ? DateTime.now()
        : null;

    final hasSeries =
        r.withWeight.length >= 2 || r.withTemp.length >= 2;

    // ⚠️ THE FIELD FROM THE ONE PALETTE (2026-09-27). `here.phase.hue` gave
    // each part its own hue, so the days before the fertile days opened on a
    // BLUE page: "the colour above is blue… what was the need of blue?". Now
    // rose in her period, violet in her fertile days, near-grey between.
    // Kept for revert: hue: here.phase.hue,
    final heroHue = TtcCycleColours.heroHue(here.phase);
    return TtcToolScaffold(
      hue: heroHue,
      chroma: v3FieldChroma(heroHue) *
          TtcCycleColours.heroChromaScale(here.phase),
      variant: 2,
      eyebrow: t.reportTitle,
      title: _heroLine(here.phase),
      // An earlier cycle's stretches are worked out looking back from its own
      // length (2026-09-26), so they no longer shift and the words say so.
      // "Stretches" was our word; the four parts are named in plain words
      // (2026-09-27). Kept for revert: '... The four stretches are worked out
      // looking back ...' / '... The four stretches are estimates ...'.
      intro: _index > 0
          ? 'One whole cycle, start to finish. Its four parts are worked out '
              'looking back, from how long this cycle ran.'
          : 'One whole cycle, start to finish, split into four parts. The '
              'dates are estimates from what you log, and they shift as you '
              'log more.',
      // ⚠️ THE i DOES ONE THING ON EVERY STATE (tools pass, 2026-09-27): it
      // opened a sheet here and an inline panel on the other three. Now the
      // same inline panel everywhere. Kept for revert:
      //   onPressed: () => _showDisclaimer(context, t),
      action: IconButton(
        icon: const Icon(Icons.info_outline_rounded, size: 21),
        color: ttcInk, // ink on the field (2026-09-29, 2.8:1 in ttcSoft); was ttcMuted
        // Kept for revert (2026-09-28, explicit labels): 'About this page'
        tooltip: 'About the cycle report',
        onPressed: () => setState(() => _about = !_about),
      ),
      heroLead: _CyclePicker(
        label: r.start == null ? '' : '${_fmt(r.start!)} to ${_fmt(r.end!)}',
        caption: ttcWhichCycle(_index, r.cyclesAvailable),
        onLatest: _index > 0 ? () => setState(() => _index = 0) : null,
        canGoBack: _index + 1 < r.cyclesAvailable,
        canGoForward: _index > 0,
        onBack: () => setState(() => _index++),
        onForward: () => setState(() => _index--),
      ),
      children: [
        ttcToolPad(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),
            if (_about) ...[
              TtcReportAbout(text: t.reportDisclaimer),
              const SizedBox(height: 18),
            ],

            // ---- walk me through it (2026-09-26) --------------------------
            //
            // The gap analysis ("Behind: Guided help") asked for the report
            // to be told as well as drawn. The scripted chat walks this cycle
            // in plain words, from the same report, and ends back here; no AI
            // and no verdict, only what her dates say.
            _WalkMeThrough(
                onTap: () => _openSurface(context, 'ttc_chat/cycle_report')),
            const SizedBox(height: 20),

            // ---- the picture, and the choice of picture ------------------
            Row(children: [
              Expanded(
                // The intro above already says "one whole cycle, start to
                // finish" (2026-09-27). Kept for revert: that line here.
                child: Text(
                    _view == TtcCycleView.dial
                        ? 'This cycle as a circle'
                        : t.reportThisCycle,
                    style: ttcJakarta(16)),
              ),
              // H4 (2026-09-28): no Circle / Calendar toggle on the report;
              // the ring lives on the Cycle companion. Kept for revert:
              // const SizedBox(width: 10),
              // TtcCycleViewToggle(
              //   view: _view,
              //   onPick: (v) => setState(() => _view = v),
              // ),
            ]),
            const SizedBox(height: 6),
            Text(
                _view == TtcCycleView.dial
                    ? 'The ring is one cycle. It starts at the top on day 1, '
                        'the first day of your period, and moves clockwise, '
                        'one step per day.'
                    : 'Every day of this cycle, in order. The colour of a day '
                        'says which part of your cycle it belongs to.',
                style: ttcBody(13, h: 1.55)),
            const SizedBox(height: 18),

            TtcCycleCard(
              child: Column(children: [
                // ⚠️ ONE KEY, NOT TWO. Swapping the picture must not swap the
                // meaning of the colours underneath it, or the toggle stops
                // being two views of one thing and becomes two screens.
                if (_view == TtcCycleView.dial)
                  TtcCycleRing(spans: spans, today: today)
                else
                  TtcCycleGrid(spans: spans, report: r, today: today),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TtcPhaseLegend(
                      spans: spans,
                      loggedDots: _view == TtcCycleView.calendar),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // ---- the four stops -----------------------------------------
            // Kept for revert: ttcSectionTitle('The four stretches, in order').
            ttcSectionTitle(kTtcReportFourParts),
            TtcCycleCard(child: TtcCycleTimeline(spans: spans)),
            // ⚠️ THE "ESTIMATES" LINE ONCE, IN THE INTRO (2026-09-27). This
            // said it a second time for the current cycle; the looking-back
            // line stays, because it is a different fact. Kept for revert:
            //   : 'These four stretches are estimates from the dates you '
            //       'log. They shift as you log more.',
            if (_index > 0) ...[
              const SizedBox(height: 10),
              Text(
                  'Looking back: the fertile days are placed about 14 days '
                  'before the period that ended this cycle.',
                  style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
            ],
            const SizedBox(height: 24),

            // ---- changes during the cycle -------------------------------
            //
            // ⚠️ KEPT, NOT REPLACED. The design demotes weight and temperature
            // to one line offering to accept them. That line is right when
            // there is nothing to show and wrong the moment there is — this
            // chart carries its own axis, unit, date ticks, phase bands and
            // marker rows, and throwing it away would take a reviewed reading
            // of her month with it. So: the invitation when empty, the chart
            // when not.
            //
            // ⚠️ AND ONE HEADING ACROSS BOTH BRANCHES. The empty branch used to
            // borrow "What you logged", which is the heading the FINDINGS
            // section below already carries — so a month with no numbers but
            // some symptoms printed the same heading twice, a few inches apart,
            // over two different things.
            //
            // The general rule, and this screen's own file header states it:
            // an empty state belongs INSIDE the thing that is empty, not as a
            // section of its own. Changes-during-the-cycle is one section that
            // is sometimes full and sometimes an invitation; it is never a
            // different section.
            KeyedSubtree(
                key: _chartKey, child: ttcSectionTitle(t.reportChanges)),
            if (hasSeries) ...[
              _CycleCard(
                report: r,
                p: V2PaletteStore.instance.current,
                showTemp: _showTemp,
                onPickSeries: (v) => setState(() => _showTemp = v),
                showLegend: false,
              ),
              // The way to add the next reading, under the chart it adds to
              // (2026-09-27).
              const SizedBox(height: 10),
              // U2 (2026-09-28): adds in place. Kept for revert:
              //   _ReportLink(
              //     key: const ValueKey('ttc_report_add_numbers'),
              //     icon: Icons.add_rounded,
              //     label: kTtcReportAddNumbers,
              //     onTap: () => _openLogToday(context),
              //   ),
              // Under a chart, the add is for the series the chart shows,
              // as Apple Health's "Add Data" is for the chart it sits on.
              _addNumbers(context,
                  only: _showTemp
                      ? TtcMeasureKind.temperature
                      : TtcMeasureKind.weight),
              const SizedBox(height: 24),
            ] else ...[
              // ⚠️ THE LINE THAT ASKED HER TO ADD NUMBERS NOW HAS THE BUTTON
              // (2026-09-27). The user on build 13: "there is 'add your
              // temperature and weight' but there is no option to add. Why
              // is it given to add? Where should the user go?" Both numbers
              // live in the daily log, so the button opens it on today.
              // Kept for revert: the card with the title and
              // `t.reportNoNumbers` only.
              TtcCycleCard(
                key: const ValueKey('ttc_report_numbers_empty'),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Morning temperature and weight',
                          style: ttcJakarta(14)),
                      const SizedBox(height: 6),
                      Text(kTtcReportNoNumbers,
                          style: ttcBody(12.5, color: ttcMuted, h: 1.5)),
                      const SizedBox(height: 14),
                      // U2 (2026-09-28): adds in place. Kept for revert:
                      //   _ReportLink(
                      //     key: const ValueKey('ttc_report_add_numbers'),
                      //     icon: Icons.add_rounded,
                      //     label: kTtcReportAddNumbers,
                      //     onTap: () => _openLogToday(context),
                      //   ),
                      _addNumbers(context),
                    ]),
              ),
              const SizedBox(height: 24),
            ],

            // ---- what it adds up to -------------------------------------
            //
            // ⚠️ SILENCE IS THE CORRECT OUTPUT OF A REPORT WITH NOTHING TO
            // REPORT, and below a week of logging there is nothing honest to
            // say — see the note in `ttc_cycle_report.dart`. `thin` gets one
            // quiet line instead, because an absent section on a screen that
            // just drew a full cycle reads as something failing to load.
            if (r.state == TtcReportState.thin && _notes(r).isEmpty) ...[
              ttcSectionTitle(t.reportWhatYouLogged),
              _Note(title: t.reportThinTitle, body: t.reportThinBody),
              // The note says this fills with logging; the way to log is
              // here (2026-09-27).
              const SizedBox(height: 12),
              _ReportLink(
                key: const ValueKey('ttc_report_log_today'),
                icon: Icons.checklist_rounded,
                label: kTtcReportLogToday,
                onTap: () => _openLogToday(context),
              ),
              const SizedBox(height: 10),
            ],
            if (_notes(r).isNotEmpty) ...[
              ttcSectionTitle(t.reportWhatYouLogged),
              for (final f in _notes(r)) ...[
                TtcCycleCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.headline,
                            style: ttcFraunces(16,
                                w: FontWeight.w600, color: ttcTitleInk)),
                        const SizedBox(height: 5),
                        Text(f.detail, style: ttcBody(13, h: 1.55)),
                      ]),
                ),
                const SizedBox(height: 10),
              ],
            ],
            const SizedBox(height: 10),
          ],
        )),
      ],
    );
  }

  /// The one Fraunces line in the hero.
  ///
  /// ⚠️ IT NAMES WHERE SHE IS AND STOPS THERE. The design's line is "You are in
  /// your fertile days" — a position, not an instruction and not an assessment.
  /// Nothing here may grow into what she should therefore do, which is the
  /// sentence a fertility app is always one edit away from writing.
  static String _heroLine(TtcPhase phase) => switch (phase) {
        TtcPhase.period => "You're in your period days",
        // One name per thing: "fertile days", never "window" here
        // (2026-09-27). Kept for revert: "You're before your fertile window".
        TtcPhase.beforeWindow => 'Your fertile days are coming up',
        TtcPhase.fertileWindow => "You're in your fertile days",
        TtcPhase.afterWindow => "You're in the waiting days",
      };

  List<TtcFinding> _notes(TtcCycleReport r) {
    final length = ttcCycleLengthNote();
    return [...r.findings, ?length];
  }

  // Kept for revert: the i opened this sheet on the drawable state until
  // 2026-09-27; it now opens the same inline panel as the other states.
  // ignore: unused_element
  void _showDisclaimer(BuildContext context, TtcS t) => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(t.reportDisclaimer, style: ttcBody(14, h: 1.65)),
          ]),
        ),
      );
}

/// "Walk me through it": a quiet row to the cycle report chat.
class _WalkMeThrough extends StatelessWidget {
  const _WalkMeThrough({required this.onTap});

  final VoidCallback onTap;

  // Kept for revert (2026-09-28, explicit labels): 'Walk me through it'
  static const String label = 'Walk me through my report';

  @override
  Widget build(BuildContext context) => InkWell(
        key: const ValueKey('ttc_report_walk_me_through'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(ttcCardRadius),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
          decoration: BoxDecoration(
            // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
            color: Colors.white, border: const Border.fromBorderSide(BorderSide(color: ttcLine)),
            borderRadius: BorderRadius.circular(ttcCardRadius),
          ),
          child: Row(children: [
            // Ink, not the brand violet, which on this page means fertile
            // days (2026-09-27). Kept for revert: color: ttcPurple.
            const Icon(Icons.chat_bubble_outline_rounded,
                size: 18, color: ttcTitleInk),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: ttcBody(14, color: ttcTitleInk, w: FontWeight.w800)),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: ttcMuted),
          ]),
        ),
      );
}

/// ◀ 23 Aug – 15 Sept ▶
class _CyclePicker extends StatelessWidget {
  const _CyclePicker({
    required this.label,
    this.caption,
    this.onLatest,
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
  });

  final String label;

  /// "This cycle · 3 of 3", "Last cycle · 2 of 3". Null keeps the old word.
  final String? caption;

  /// Jumps back to the newest cycle. Null on the newest (2026-09-27): after
  /// paging four cycles back, the only way home was four taps.
  final VoidCallback? onLatest;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;

  // ⚠️ THE CAPTION SAYS WHICH CYCLE, NOT THAT ONE WAS CHOSEN (tools pass,
  // 2026-09-27). "Chosen cycle" over a date range left her counting; now it
  // is "Last cycle · 2 of 3". Kept for revert: Text(reportChosenCycle).
  @override
  Widget build(BuildContext context) => Row(children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: 'Earlier cycle',
          color: canGoBack ? ttcTitleInk : ttcBorder,
          onPressed: canGoBack ? onBack : null,
        ),
        Expanded(
          child: Column(children: [
            Text(caption ?? TtcS.current().reportChosenCycle,
                key: const ValueKey('ttc_report_which_cycle'),
                style: ttcBody(11, color: ttcInk, w: FontWeight.w700)), // ink on the field; was ttcMuted (2026-09-29)
            const SizedBox(height: 2),
            Text(label, style: ttcJakarta(16)),
            if (onLatest != null)
              TextButton(
                key: const ValueKey('ttc_report_back_to_latest'),
                onPressed: onLatest,
                style: TextButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 10)),
                child: Text(kTtcReportBackToThisCycle,
                    style: ttcBody(12.5,
                        color: ttcTitleInk, w: FontWeight.w800)),
              ),
          ]),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          tooltip: 'Later cycle',
          color: canGoForward ? ttcTitleInk : ttcBorder,
          onPressed: canGoForward ? onForward : null,
        ),
      ]);
}

/// "This cycle", "Last cycle", "3 cycles back", with where it sits among the
/// cycles she has: index 0 is the newest.
String ttcWhichCycle(int index, int available) {
  final name = switch (index) {
    0 => 'This cycle',
    1 => 'Last cycle',
    _ => '$index cycles back',
  };
  if (available <= 1) return name;
  return '$name · ${available - index} of $available';
}

/// The heading over the timeline of the four parts.
const String kTtcReportFourParts = 'The four parts of your cycle';

// ---- the numbers, and the way to add them (2026-09-27) ---------------------

/// Where weight and temperature are entered, said where the chart would be.
// U2 (2026-09-28): the numbers are added right here now. Kept for revert:
//   'Add a weight or a morning temperature in your daily log on any day, and '
//   "a chart shows up here. You don't need either. This page works with "
//   'symptoms alone.'
const String kTtcReportNoNumbers =
    'Add a morning temperature or a weight, here or in your daily log, and a '
    "chart shows up after two readings. You don't need either. This page "
    'works with symptoms alone.';

/// The button that opened the daily log on today. Unused since U2
/// (2026-09-28), kept for revert.
const String kTtcReportAddNumbers = "Add today's temperature or weight";

/// The two links that add a number in place (U2, 2026-09-28).
const String kTtcReportAddTemp = "Add today's temperature";
const String kTtcReportAddWeight = "Add today's weight";

/// The button under "A start", for a cycle with little logged.
const String kTtcReportLogToday = 'Log how today went';

/// The picker's way home from an earlier cycle.
const String kTtcReportBackToThisCycle = 'Back to this cycle';

/// A small outlined action on the report: an icon and a verb, 44pt tall.
///
/// ⚠️ ONE SHAPE FOR EVERY "DO THIS HERE" ON THE REPORT, so an invitation and
/// its button read as one thing (the calendar's day card uses the same pill).
class _ReportLink extends StatelessWidget {
  const _ReportLink({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: ttcBorder, width: 1.2),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 17, color: ttcTitleInk),
              const SizedBox(width: 7),
              Flexible(
                child: Text(label,
                    style: ttcBody(13.5,
                        color: ttcTitleInk, w: FontWeight.w800)),
              ),
            ]),
          ),
        ),
      );
}

/// The whole month as one picture: phases, the line, and what happened.
class _CycleCard extends StatelessWidget {
  const _CycleCard({
    required this.report,
    required this.p,
    required this.showTemp,
    required this.onPickSeries,
    this.showLegend = true,
  });

  final TtcCycleReport report;
  final V2Palette p;
  final bool showTemp;
  final void Function(bool) onPickSeries;

  /// ⚠️ OFF ON THE V3 REPORT, WHERE THE RING OR THE GRID ABOVE ALREADY CARRIES
  /// THE KEY. Two legends for the same four colours on one scroll is not twice
  /// the help — it is a reader checking whether they say the same thing.
  final bool showLegend;

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    final hasWeight = report.withWeight.length >= 2;
    final hasTemp = report.withTemp.length >= 2;
    final temp = showTemp && hasTemp;
    final series = temp ? report.withTemp : report.withWeight;
    final hasSeries = series.length >= 2;

    return TtcCycleCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ---- what this chart is ------------------------------------------
        Row(children: [
          Expanded(
            child: Text(
                hasSeries
                    ? (temp ? t.reportTemperature : t.reportWeight)
                    : t.reportThisCycle,
                style: ttcJakarta(16)),
          ),
          if (hasWeight && hasTemp)
            _Segment(
              left: t.reportWeight,
              right: t.reportTemperature,
              rightOn: temp,
              onPick: onPickSeries,
            ),
        ]),
        const SizedBox(height: 14),

        SizedBox(
          height: hasSeries ? 200 : 96,
          child: CustomPaint(
            painter: _ChartPainter(
              report: report,
              series: hasSeries ? series : const [],
              temp: temp,
              // The one palette's soft tints (2026-09-27). Kept for revert:
              //   v2BlockTint(phase.hue, p).withValues(alpha: 0.6),
              band: (phase) => TtcCycleColours.tint(phase),
              plain: ttcPanel,
              line: ttcTitleInk,
              axis: ttcMuted,
              markPeriod: TtcCycleColours.period,
              markOther: TtcCycleColours.logged,
            ),
            size: Size.infinite,
          ),
        ),

        // ⚠️ THE INVITE LIVES INSIDE THE CHART CARD. It used to be its own
        // section with its own heading — a whole block of screen explaining
        // that a block of screen was empty.
        if (!hasSeries) ...[
          const SizedBox(height: 12),
          Text(t.reportNoNumbers, style: ttcBody(12.5, color: ttcMuted, h: 1.5)),
        ],

        if (showLegend) ...[
          const SizedBox(height: 14),
          ttcDivider(),
          const SizedBox(height: 12),

          // ---- the legend, which is what makes the bands mean anything ----
          Wrap(spacing: 14, runSpacing: 7, children: [
            for (final phase in TtcPhase.values)
              _Key(colour: TtcCycleColours.tint(phase), label: phase.label),
            _Key(
                colour: TtcCycleColours.period,
                label: t.reportKeyPeriod,
                dot: true),
            _Key(
                colour: TtcCycleColours.logged,
                label: t.reportKeyLogged,
                dot: true),

          ]),
        ],
      ]),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.colour, required this.label, this.dot = false});

  final Color colour;
  final String label;
  final bool dot;

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: dot ? 7 : 10,
          height: dot ? 7 : 10,
          decoration: BoxDecoration(
            color: colour,
            shape: dot ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: dot ? null : BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: ttcBody(11, color: ttcMuted, w: FontWeight.w700)),
      ]);
}

class _Segment extends StatelessWidget {
  const _Segment(
      {required this.left,
      required this.right,
      required this.rightOn,
      required this.onPick});

  final String left;
  final String right;
  final bool rightOn;
  final void Function(bool) onPick;

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, bool on, VoidCallback tap) => GestureDetector(
          onTap: tap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: on ? ttcTitleInk : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                style: ttcBody(11,
                    color: on ? Colors.white : ttcMuted, w: FontWeight.w800)),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ttcPanel,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        seg(left, !rightOn, () => onPick(false)),
        seg(right, rightOn, () => onPick(true)),
      ]),
    );
  }
}

/// ⚠️ THE LINE IS THE SMALLEST PART OF THIS. What makes a chart readable is the
/// furniture around it — the unit on the axis, the dates along the bottom, the
/// bands saying where in the cycle each column falls, and the marker rows
/// saying what happened on those days. The first version drew a line and two
/// numbers and expected the reader to supply the rest.
class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.report,
    required this.series,
    required this.temp,
    required this.band,
    required this.plain,
    required this.line,
    required this.axis,
    required this.markPeriod,
    required this.markOther,
  });

  final TtcCycleReport report;
  final List<TtcReportDay> series;
  final bool temp;
  final Color Function(TtcPhase) band;
  final Color plain;
  final Color line;
  final Color axis;
  final Color markPeriod;
  final Color markOther;

  static const _rows = 2; // period · logged

  @override
  void paint(Canvas canvas, Size size) {
    final days = report.days;
    if (days.isEmpty) return;

    const leftGutter = 30.0;
    const rowHeight = 15.0;
    const tickHeight = 14.0;
    final markersTop = size.height - _rows * rowHeight;
    final ticksTop = markersTop - tickHeight;
    final plot = Rect.fromLTRB(leftGutter, 2, size.width, ticksTop - 4);

    final n = days.length;
    final colWidth = (size.width - leftGutter) / n;
    double xOf(int i) => leftGutter + colWidth * (i + 0.5);

    // ---- phase bands ------------------------------------------------------
    for (var i = 0; i < n; i++) {
      final phase = days[i].phase;
      canvas.drawRect(
        Rect.fromLTWH(leftGutter + colWidth * i, plot.top, colWidth + 0.5,
            plot.height),
        Paint()..color = phase == null ? plain.withValues(alpha: 0.5) : band(phase),
      );
    }

    // ---- the series -------------------------------------------------------
    if (series.length >= 2) {
      final values = series.map((d) => temp ? d.tempC! : d.weightKg!).toList();
      var lo = values.reduce((a, b) => a < b ? a : b);
      var hi = values.reduce((a, b) => a > b ? a : b);
      // A flat series still needs a range, or every point stacks on one line.
      if ((hi - lo).abs() < 0.001) {
        lo -= temp ? 0.3 : 1.0;
        hi += temp ? 0.3 : 1.0;
      } else {
        final pad = (hi - lo) * 0.22;
        lo -= pad;
        hi += pad;
      }
      double yOf(double v) => plot.bottom - plot.height * ((v - lo) / (hi - lo));

      // Axis: three values, and the UNIT on the top one so the number means
      // something without a caption.
      for (var i = 0; i <= 2; i++) {
        final v = lo + (hi - lo) * (i / 2);
        final y = yOf(v);
        canvas.drawLine(
            Offset(leftGutter, y),
            Offset(size.width, y),
            Paint()
              ..color = Colors.white.withValues(alpha: 0.55)
              ..strokeWidth = 0.8);
        _text(
            canvas,
            temp ? v.toStringAsFixed(1) : v.toStringAsFixed(0),
            Offset(0, y - 6),
            9,
            axis,
            bold: true);
      }
      _text(canvas, temp ? '°C' : 'kg', Offset(0, plot.top - 1), 8.5, axis);

      final pts = <Offset>[];
      for (final d in series) {
        final i = days.indexWhere((x) => x.cycleDay == d.cycleDay);
        if (i < 0) continue;
        pts.add(Offset(xOf(i), yOf(temp ? d.tempC! : d.weightKg!)));
      }
      if (pts.length > 1) {
        final path = Path()..moveTo(pts.first.dx, pts.first.dy);
        for (final pt in pts.skip(1)) {
          path.lineTo(pt.dx, pt.dy);
        }
        canvas.drawPath(
            path,
            Paint()
              ..color = line
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round);
      }
      for (final pt in pts) {
        canvas.drawCircle(pt, 4, Paint()..color = Colors.white);
        canvas.drawCircle(pt, 2.6, Paint()..color = line);
      }
    }

    // ---- date ticks -------------------------------------------------------
    for (var i = 0; i < n; i += (n / 6).ceil().clamp(1, 99)) {
      _text(canvas, '${days[i].date.day}', Offset(xOf(i) - 5, ticksTop + 1), 9,
          axis);
    }

    // ---- marker rows ------------------------------------------------------
    //
    // The rows the reference puts under its axis, and the reason they matter:
    // a weight line alone says nothing about a cycle. The same line with
    // "period here, and you logged on these days" underneath is a month.
    for (var row = 0; row < _rows; row++) {
      final y = markersTop + rowHeight * row + rowHeight / 2;
      for (var i = 0; i < n; i++) {
        final d = days[i];
        final on = row == 0
            ? d.phase == TtcPhase.period
            : d.symptoms.isNotEmpty;
        if (!on) continue;
        canvas.drawCircle(Offset(xOf(i), y), 3.2,
            Paint()..color = row == 0 ? markPeriod : markOther);
      }
    }
  }

  void _text(Canvas c, String s, Offset at, double size, Color colour,
      {bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(
              fontSize: size,
              color: colour,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, at);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.series != series || old.temp != temp || old.report != report;
}

class _Note extends StatelessWidget {
  const _Note({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          // ⚠️ THE NEUTRAL PANEL. This was a pink-red wash, which made an
          // ordinary "not much yet" read like a warning.
          // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
          color: Colors.white, border: const Border.fromBorderSide(BorderSide(color: ttcLine)),
          borderRadius: BorderRadius.circular(ttcCardRadius),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: ttcFraunces(17, w: FontWeight.w600, color: ttcTitleInk)),
          const SizedBox(height: 7),
          Text(body, style: ttcBody(13, h: 1.6)),
        ]),
      );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 44),
        child: Column(children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(color: ttcPanel, shape: BoxShape.circle),
            child: const Icon(Icons.insights_rounded,
                size: 28, color: ttcTitleInk),
          ),
          const SizedBox(height: 18),
          Text(title,
              textAlign: TextAlign.center,
              style: ttcFraunces(20, w: FontWeight.w600, color: ttcTitleInk)),
          const SizedBox(height: 9),
          Text(body, textAlign: TextAlign.center, style: ttcBody(13.5, h: 1.6)),
        ]),
      );
}
