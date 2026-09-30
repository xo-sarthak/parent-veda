// =============================================================================
//  Weight Tracker
// -----------------------------------------------------------------------------
//  Two experiences: a one-time onboarding (pre-pregnancy weight, with an
//  OPTIONAL height → personalized gain range) and an ongoing dashboard that
//  reframes weight as "my body is supporting my baby" - never a scorecard.
//  Per the product spec: the gain number is shown calmly, never celebrated or
//  judged, and the chart never shows above/below-target or warning colours.
//
//  Entries are kept individually - multiple weigh-ins per day are allowed and
//  never overwrite each other (so the record never appears to "reset").
//
//  ⚠️ ONE PARENTVEDA (restyle, 2026-09-30), in the shape of trying to
//  conceive's BMI tool (`ttc_bmi_screen.dart`, read, never imported): the
//  page title in the serif on the page and the AppBar carrying only the back
//  arrow; the hero a white card on the hairline, not a pink block behind the
//  number; each dashboard section headed with the one serif heading over a
//  white card; the decorative emoji (the scale, the hearts) gone from the
//  chrome; the "Start" row of the history no longer tinted (its tag keeps the
//  tint, a tag may have one); the note a quiet line on the page; every
//  filled button and the add in the one ink.
//
//  ⚠️ ONE ADD AT A TIME (TTC's launch sanity T13 rule): the AppBar's "Add
//  weight" and a bottom "Add Today's Weight" button opened the same sheet on
//  one screen. Before the first weigh-in the hero card carries the add; once
//  there is one, the AppBar's add is the only one. Same sheet, same flow.
//  The Asian BMI cut-offs (23 / 25) are untouched.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/tools_store.dart';
import '../../theme/app_theme.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../pregnancy/preg_chrome.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;
// Kept for revert alongside the commented-out `pregHealthStrip` call below.
// import '../../widgets/profile_ask_strip.dart';

class WeightTrackerScreen extends StatefulWidget {
  const WeightTrackerScreen({super.key, required this.controller});

  final PregnancyController controller;

  @override
  State<WeightTrackerScreen> createState() => _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen> {
  final _store = ToolsStore.instance;

  @override
  void initState() {
    super.initState();
    _store.init();
  }

  @override
  Widget build(BuildContext context) {
    // TOOL SHELL (2026-09-30, Tools audit): each page below wears
    // `PregToolScaffold` itself, so the AppBar and the outer Scaffold are gone.
    // The one add is now a round ink control opposite the back button, shown
    // once the profile is set and there is a weigh-in (before that the hero
    // card carries the add). Kept for revert: Scaffold(backgroundColor: ground,
    // appBar: AppBar(actions: [TextButton.icon(add_rounded, s.addWeightShort)])).
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        if (!_store.weightOnboarded) {
          return _SetupFlow(
            controller: widget.controller,
            onDone: () => setState(() {}),
          );
        }
        return _Dashboard(controller: widget.controller);
      },
    );
  }
}

/// The round ink add, opposite the back button on the hero.
Widget _addAction(String label, VoidCallback onTap) => Tooltip(
  message: label,
  child: Material(
    color: kPvInk,
    shape: const CircleBorder(),
    child: InkWell(
      key: const ValueKey('weight_add_action'),
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: const SizedBox(
        width: 38,
        height: 38,
        child: Icon(Icons.add_rounded, size: 20, color: Colors.white),
      ),
    ),
  ),
);

// ---------------------------------------------------------------------------
//  Onboarding (height optional)
// ---------------------------------------------------------------------------

class _SetupFlow extends StatefulWidget {
  const _SetupFlow({required this.controller, required this.onDone});
  final PregnancyController controller;
  final VoidCallback onDone;

  @override
  State<_SetupFlow> createState() => _SetupFlowState();
}

class _SetupFlowState extends State<_SetupFlow> {
  int _step = 0;
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  double? _weight;
  double? _height; // optional

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  ({double min, double max}) _gainFor(double w, double h) {
    final bmi = w / ((h / 100) * (h / 100));
    // Asian BMI cut-offs, matching ToolsStore.recommendedGain (2026-09-29).
    if (bmi < 18.5) return (min: 12.5, max: 18.0);
    if (bmi < 23) return (min: 11.5, max: 16.0);
    if (bmi < 25) return (min: 7.0, max: 11.5);
    return (min: 5.0, max: 9.0);
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final text = Theme.of(context).textTheme;
    final p = pvStorePalette;

    if (_step == 1 && _weight != null) {
      final gain = _height != null ? _gainFor(_weight!, _height!) : null;
      // A sub-step of the setup, not the front page: the simple chrome, a back
      // arrow and the serif title (the shell's field is for the front page).
      return Scaffold(
        backgroundColor: p.ground,
        appBar: AppBar(
          backgroundColor: p.ground,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            // No decorative emoji; the step's title is the page title
            // (2026-09-30). Kept for revert:
            // const Center(child: Text('❤️', style: TextStyle(fontSize: 56))),
            // const SizedBox(height: 12),
            // Center(child: Text(s.profileTitleWeight, style: text.headlineMedium)),
            Semantics(
              header: true,
              child: Text(s.profileTitleWeight, style: pregPageTitleStyle()),
            ),
            const SizedBox(height: 20),
            _summaryCard(
              s.startingWeightLabel,
              '${_weight!.toStringAsFixed(1)} ${s.kgUnit}',
              text,
            ),
            if (_height != null)
              _summaryCard(
                s.heightLabel,
                '${_height!.toStringAsFixed(0)} ${s.cmUnit}',
                text,
              ),
            if (gain != null)
              _summaryCard(
                s.recommendedGainLabel,
                '${gain.min.toStringAsFixed(1)} – ${gain.max.toStringAsFixed(1)} ${s.kgUnit}',
                text,
                note: s.weightGuidelineNote,
              )
            else
              _noteCard(s.gainNeedsHeight, text),
            const SizedBox(height: 16),
            FilledButton(
              style: _bigFilled(),
              onPressed: () async {
                await ToolsStore.instance.setWeightProfile(_weight!, _height);
                widget.onDone();
              },
              child: Text(s.startTrackingCta),
            ),
          ],
        ),
      );
    }

    // FRONT PAGE ON THE SHELL: the welcome body is the intro, the form is the
    // sheet. Kept for revert: ListView([serif title, welcome body, form...]).
    return PregToolScaffold(
      hue: 206,
      eyebrow: 'Track',
      title: s.weightToolTitle,
      mark: IntentMark.scaleMark,
      intro: s.weightWelcomeBody,
      children: [
        pregToolPad(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.prePregnancyWeightLabel, style: text.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: '60.0',
                  suffixText: s.kgUnit,
                  helperText: s.prePregnancyWeightHelper,
                ),
              ),
              const SizedBox(height: 20),
              Text(s.heightOptional, style: text.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _heightCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: '160',
                  suffixText: s.cmUnit,
                  helperText: s.heightHelper,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: _bigFilled(),
                  onPressed: () {
                    final w = double.tryParse(_weightCtrl.text.trim());
                    if (w == null) return; // weight required; height optional
                    final h = double.tryParse(_heightCtrl.text.trim());
                    setState(() {
                      _weight = w;
                      _height = (h != null && h > 0) ? h : null;
                      _step = 1;
                    });
                  },
                  child: Text(s.continueCta),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
    String label,
    String value,
    TextTheme text, {
    String? note,
  }) {
    // The one white card on the hairline (2026-09-30). Kept for revert: a
    // Container, AppTheme.surface, radius 18, AppTheme.outlineVariant border.
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PregCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: text.bodyMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (note != null) ...[
              const SizedBox(height: 8),
              Text(note, style: text.bodySmall),
            ],
          ],
        ),
      ),
    );
  }

  // A quiet note on the page, not a grey block behind text (2026-09-30).
  // Kept for revert: Container(margin: bottom 12, padding: all(16),
  //   decoration: BoxDecoration(color: AppTheme.neutral50, radius 18),
  //   child: Text(note, style: text.bodyMedium)).
  Widget _noteCard(String note, TextTheme text) => Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 2),
    child: PregNote(note),
  );
}

/// The one filled button, full width and tall enough to find.
ButtonStyle _bigFilled() => pregFilledStyle().copyWith(
  padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 15)),
);

// ---------------------------------------------------------------------------
//  Dashboard
// ---------------------------------------------------------------------------

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.controller});
  final PregnancyController controller;

  /// Educational contributor estimates (kg), anchored on the spec's week-23
  /// example and scaled by week. Not exact measurements.
  Map<String, double> _contributors(int week) {
    final f = week / 23.0;
    double r(double v) => (v * f * 10).round() / 10;
    return {
      'baby': r(0.6),
      'placenta': r(0.5),
      'amniotic': r(0.4),
      'blood': r(1.2),
      'breast': r(0.5),
      'energy': r(1.5),
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final store = ToolsStore.instance;
    final week = controller.currentWeek;
    final latest = store.latestWeight;
    final pre = store.prePregnancyWeight ?? 0;
    final gain = latest != null ? latest.weight - pre : null;
    final entries = store.weightEntries; // newest first
    final p = pvStorePalette;

    // TOOL SHELL + ORDER (2026-09-30, Tools audit). WH: she opens this to log a
    // weigh-in and see where she is, so her number, her gain, this week's line
    // and her history come first; the three explainer cards ("your body is
    // supporting", "where it comes from", "what changed") follow, because she
    // reads them once, not every visit. Kept for revert: the explainers sat
    // between the gain and this week's insight, under the serif page title.
    return PregToolScaffold(
      hue: 206,
      eyebrow: 'Track',
      title: s.weightToolTitle,
      mark: IntentMark.scaleMark,
      intro:
          'A record of your weigh-ins and what they mean for your baby. '
          'It is a record, not a target: your doctor sets your goals.',
      action: latest != null
          ? _addAction(
              s.addWeightShort,
              () => showAddWeight(context, controller),
            )
          : null,
      children: [
        pregToolPad(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gestational diabetes and thyroid change how weight should be
              // read, so this is a relevant moment to ask. It sits on the
              // DASHBOARD rather than the one-time setup flow - a strip that
              // asks once, ever, is wasted on a screen she visits once.
              // ⚠️ OFF, KEPT FOR REVERT — the review said "at all".
              //
              // Full quote: "In Symptoms it was showing 'Has your doctor mentioned
              // any of the following' — when I selected no, it stopped showing. We
              // don't want this 'Has your doctor mentioned any of the following'
              // section at all."
              //
              // ⚠️ IT WAS FIRST READ AS "REMOVE IT FROM SYMPTOMS", AND THAT READING
              // WOULD HAVE CHANGED NOTHING SHE EXPERIENCES. `ProfileAskStrip` is
              // ONE-SHOT APP-WIDE: once she answers or dismisses it anywhere, it
              // never appears again. So a mother who opened the weight tracker
              // before Symptoms would still meet the question, and the only effect
              // of a partial removal is which screen she happens to meet it on.
              //
              // ⚠️ THE GENERAL LESSON: **a one-shot prompt has no per-screen
              // meaning.** Reasoning about it screen by screen — "it is relevant
              // here, less so there" — quietly assumes she sees it on each, and
              // she does not. Deciding where a global thing belongs is deciding
              // whether it exists.
              //
              // pregHealthStrip(controller.language, 'weight_tracker'),
              // Hero: current weight (or empty state). A white card on the
              // hairline, not a pink block behind the number (2026-09-30). Kept for
              // revert: Container(padding: all(22), decoration: BoxDecoration(
              //   color: AppTheme.secondary50, radius 20), child: ...same children).
              PregCard(
                padding: const EdgeInsets.all(20),
                child: latest == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s.weekWord} $week',
                            style: pregGroupLabelStyle(),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.weightEmptyState(week),
                            style: pvManrope(
                              fontSize: 14.5,
                              height: 1.5,
                              color: p.ink1,
                            ),
                          ),
                          // The one add while there is nothing yet (2026-09-30): the
                          // AppBar's add appears once there is a weigh-in.
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: _bigFilled(),
                              onPressed: () =>
                                  showAddWeight(context, controller),
                              icon: const Icon(Icons.add_rounded),
                              label: Text(s.addTodaysWeight),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s.weekWord} $week',
                            style: pregGroupLabelStyle(),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${latest.weight.toStringAsFixed(1)} ${s.kgUnit}',
                            style: pvFraunces(
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                              color: p.ink1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${s.currentWeightLabel} · ${s.lastUpdatedLabel}: '
                            '${_lastUpdated(s, latest)}',
                            style: pvManrope(fontSize: 12.5, color: p.ink3),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 14),
              // Weight gain (calm - small, not celebrated). Moved to sit directly
              // above the "Your Body Supporting" card so the gain number is read
              // alongside its reassurance (the two are kept adjacent).
              // A fact, not a section: a card with its own small label, no heading
              // (2026-09-30).
              if (gain != null)
                _card(
                  context,
                  title: s.weightGainSince,
                  section: false,
                  child: Text(
                    '${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(1)} ${s.kgUnit}',
                    style: text.titleLarge?.copyWith(color: p.ink2),
                  ),
                ),
              if (gain != null) const SizedBox(height: 24),
              // Weekly insight.
              _card(
                context,
                title: s.thisWeekLabel,
                child: Text(s.weeklyWeightInsight(week), style: text.bodyLarge),
              ),
              const SizedBox(height: 24),
              // History - every entry, with column headings.
              if (entries.isNotEmpty)
                _card(
                  context,
                  title: s.weightHistoryTitle,
                  child: Column(
                    children: [
                      _historyHeader(s, text),
                      const Divider(height: 16),
                      for (int i = 0; i < entries.length; i++) ...[
                        _historyRow(context, entries[i], pre, s, text),
                        const Divider(height: 1, color: kPvLine),
                      ],
                      // The starting (pre-pregnancy) weight - the baseline every "change"
                      // is measured from. Tinted + badged so it reads as the origin.
                      if (pre > 0) _startingRow(pre, s, text),
                    ],
                  ),
                ),
              if (entries.isNotEmpty) const SizedBox(height: 24),
              // Supportive insight.
              _card(
                context,
                title: s.bodySupportingTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heartLine(text, s.supportGrowingBaby),
                    _heartLine(text, s.supportPlacenta),
                    _heartLine(text, s.supportAmniotic),
                    _heartLine(text, s.supportBlood),
                    const SizedBox(height: 8),
                    Text(s.everyPregnancyUnique, style: text.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Where weight comes from.
              _card(
                context,
                title: s.whereWeightComesFrom,
                child: _contributorsView(context, _contributors(week), s, text),
              ),
              const SizedBox(height: 24),
              // What changed (only once there is at least one entry).
              if (latest != null)
                _card(
                  context,
                  title: s.whatChangedTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _heartLine(text, s.changedBabyGrew),
                      _heartLine(text, s.changedAmniotic),
                      _heartLine(text, s.changedBlood),
                      _heartLine(text, s.changedUterus),
                    ],
                  ),
                ),
              if (latest != null) const SizedBox(height: 24),
              // Chart REMOVED per request - the plotted weight graph is hidden.
              // Commented out (not deleted) so it can be reverted. The _ChartView /
              // _WeightChartPainter classes below are also commented out to avoid
              // unused-element warnings.
              // if (entries.isNotEmpty)
              //   _card(context, title: s.weightChartTitle, child: _ChartView(
              //     controller: controller,
              //   )),
              // if (entries.isNotEmpty) const SizedBox(height: 14),
              // ⚠️ SAID ONCE (2026-09-30): the AppBar's "Add weight" opens this
              // same sheet, so a second add at the foot was the same button twice.
              // Before the first weigh-in the hero card carries the add. Kept for
              // revert:
              // const SizedBox(height: 18),
              // FilledButton.icon(
              //   onPressed: () => showAddWeight(context, controller),
              //   icon: const Icon(Icons.add_rounded),
              //   label: Text(s.addTodaysWeight),
              // ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  String _lastUpdated(S s, WeightEntry e) {
    final d = DateTime.tryParse(e.timeIso);
    if (d == null) return e.dateIso;
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return '${s.todayWord} · ${s.formatClock(d)}';
    }
    return s.formatShortDate(d);
  }

  /// A page section: the one serif heading over a white card on the
  /// hairline (2026-09-30). With [section] false it is a single fact, a card
  /// with its own small label inside.
  ///
  /// Kept for revert: one Container (AppTheme.surface, radius 18,
  /// AppTheme.outlineVariant border) with the title inside it as
  /// `text.titleMedium?.copyWith(fontWeight: FontWeight.w700)`.
  Widget _card(
    BuildContext context, {
    required String title,
    required Widget child,
    bool section = true,
  }) {
    if (!section) {
      return SizedBox(
        width: double.infinity,
        child: PregCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: pvStorePalette.ink2,
                ),
              ),
              const SizedBox(height: 6),
              child,
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PregSectionHeading(title),
        const SizedBox(height: 12),
        PregCard(padding: const EdgeInsets.all(18), child: child),
      ],
    );
  }

  // A small drawn dot, not a decorative emoji (2026-09-30). Kept for revert:
  //   const Text('❤️ ', style: TextStyle(fontSize: 13)),
  Widget _heartLine(TextTheme text, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 10),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: pvStorePalette.ink3,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(child: Text(label, style: text.bodyLarge)),
      ],
    ),
  );

  Widget _contributorsView(
    BuildContext context,
    Map<String, double> c,
    S s,
    TextTheme text,
  ) {
    final labels = {
      'baby': s.contributorBaby,
      'placenta': s.contributorPlacenta,
      'amniotic': s.contributorAmniotic,
      'blood': s.contributorBlood,
      'breast': s.contributorBreast,
      'energy': s.contributorEnergy,
    };
    final maxV = c.values.fold<double>(0, (a, b) => b > a ? b : a);
    return Column(
      children: [
        for (final entry in c.entries) ...[
          Row(
            children: [
              SizedBox(
                width: 96,
                child: Text(labels[entry.key]!, style: text.bodyMedium),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: maxV <= 0 ? 0 : entry.value / maxV,
                    minHeight: 8,
                    backgroundColor: pvStorePalette.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pvStorePalette.ink3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${entry.value.toStringAsFixed(1)} ${s.kgUnit}',
                style: text.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 2),
        Text(s.estimatesNote, style: text.bodySmall),
      ],
    );
  }

  /// Column headings for the history table.
  Widget _historyHeader(S s, TextTheme text) {
    // The group label inside a card (2026-09-30). Kept for revert:
    // text.labelSmall?.copyWith(color: AppTheme.neutral500,
    //     fontWeight: FontWeight.w800, letterSpacing: 0.4)
    final style = pregGroupLabelStyle();
    return Row(
      children: [
        Expanded(flex: 5, child: Text(s.dateLabel, style: style)),
        Expanded(flex: 3, child: Text(s.weekWord, style: style)),
        Expanded(flex: 4, child: Text(s.weightLabel, style: style)),
        SizedBox(
          width: 56,
          child: Text(s.changeLabel, style: style, textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _historyRow(
    BuildContext context,
    WeightEntry e,
    double pre,
    S s,
    TextTheme text,
  ) {
    final d = DateTime.tryParse(e.timeIso) ?? DateTime.tryParse(e.dateIso);
    final change = e.weight - pre;
    return InkWell(
      onLongPress: () => _confirmDelete(context, e, s),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d != null ? s.formatShortDate(d) : e.dateIso,
                    style: text.bodyMedium,
                  ),
                  if (d != null)
                    Text(
                      s.formatClock(d),
                      style: text.labelSmall?.copyWith(
                        color: AppTheme.neutral500,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(flex: 3, child: Text('${e.week}', style: text.bodyMedium)),
            Expanded(
              flex: 4,
              child: Text(
                '${e.weight.toStringAsFixed(1)} ${s.kgUnit}',
                style: text.bodyLarge,
              ),
            ),
            SizedBox(
              width: 56,
              child: Text(
                '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}',
                textAlign: TextAlign.right,
                style: text.labelMedium?.copyWith(color: AppTheme.neutral500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The pre-pregnancy starting weight, shown as the origin row of the history -
  /// a leading "START" chip + label (sharing the Date+Week width so it never
  /// crowds), with the weight aligned under the Weight column.
  Widget _startingRow(double pre, S s, TextTheme text) {
    // No tint behind the row; the START tag keeps its tint, a tag may have
    // one (2026-09-30). Kept for revert: Container(margin: top 10,
    //   padding: symmetric(vertical: 11, horizontal: 10),
    //   decoration: BoxDecoration(color: AppTheme.neutral50, radius 12)).
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 2),
      child: Row(
        children: [
          // Date + Week columns combined (flex 8) → roomy for chip + label.
          Expanded(
            flex: 8,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: pvStorePalette.surfaceAlt,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Text(
                    s.startWord.toUpperCase(),
                    style: text.labelSmall?.copyWith(
                      color: AppTheme.neutral900,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    s.startingWeightLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.neutral900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Weight column (flex 4) - lines up with the Weight heading above.
          Expanded(
            flex: 4,
            child: Text(
              '${pre.toStringAsFixed(1)} ${s.kgUnit}',
              style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          // Change column (fixed 56) - baseline, so a quiet dash.
          SizedBox(
            width: 56,
            child: Text(
              '-',
              textAlign: TextAlign.right,
              style: text.labelMedium?.copyWith(color: AppTheme.neutral400),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WeightEntry e, S s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(s.deleteEntryQ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (ok == true) await ToolsStore.instance.deleteWeightEntry(e.id);
  }
}

/// The add-weight bottom sheet, shared by the top app-bar button and the bottom
/// button. Allows any past date; multiple entries per day are kept.
Future<void> showAddWeight(
  BuildContext context,
  PregnancyController controller,
) async {
  final s = S(controller.language);
  final ctrl = TextEditingController();
  final notesCtrl = TextEditingController();
  DateTime date = DateTime.now();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    showDragHandle: true,
    builder: (ctx) {
      final text = Theme.of(ctx).textTheme;
      return StatefulBuilder(
        builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              22,
              4,
              22,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.addWeightTitle, style: text.headlineSmall),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: s.currentWeightLabel,
                    suffixText: s.kgUnit,
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: date,
                      firstDate: DateTime(date.year - 1),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setSheet(() => date = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: s.dateLabel),
                    child: Text(s.formatLongDate(date)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: notesCtrl,
                  decoration: InputDecoration(labelText: s.notesOptional),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: _bigFilled(),
                    onPressed: () {
                      final w = double.tryParse(ctrl.text.trim());
                      if (w == null) return;
                      final now = DateTime.now();
                      final ts = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        now.hour,
                        now.minute,
                        now.second,
                      );
                      ToolsStore.instance.addWeightEntry(
                        WeightEntry(
                          id: 'w_${now.microsecondsSinceEpoch}',
                          dateIso:
                              '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                          timeIso: ts.toIso8601String(),
                          week: controller.currentWeek,
                          weight: w,
                          notes: notesCtrl.text.trim(),
                        ),
                      );
                      Navigator.of(ctx).pop();
                    },
                    child: Text(s.saveCta),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// ---------------------------------------------------------------------------
//  Weight chart: actual line (by date) over a soft recommended-range band.
//  COMMENTED OUT per request - the plotted chart was removed from the dashboard.
//  Kept here (not deleted) so it can be reverted; wrapped in a block comment so
//  the unused classes don't trigger analyzer warnings.
// ---------------------------------------------------------------------------

/*
class _ChartView extends StatelessWidget {
  const _ChartView({required this.controller});
  final PregnancyController controller;

  /// Fractional gestational week for an entry, from its actual date - so two
  /// entries on different days land at different x positions (and same-day ones
  /// sit together), instead of every entry snapping to an integer week.
  double _weekOf(WeightEntry e) {
    final raw = DateTime.tryParse(e.timeIso) ?? DateTime.tryParse(e.dateIso);
    if (raw == null) return controller.currentWeek.toDouble();
    final today = DateTime.now();
    final daysAgo =
        DateTime(today.year, today.month, today.day).difference(
            DateTime(raw.year, raw.month, raw.day)).inDays;
    final pday = (controller.currentDay - daysAgo).clamp(1, 280);
    return (pday / 7.0).clamp(4.0, 40.0);
  }

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final store = ToolsStore.instance;
    final pre = store.prePregnancyWeight ?? 0;
    final gain = store.recommendedGain;
    final points = [
      for (final e in store.weightEntries)
        (week: _weekOf(e), weight: e.weight),
    ]..sort((a, b) => a.week.compareTo(b.week));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 180,
        width: double.infinity,
        child: CustomPaint(
          painter: _WeightChartPainter(
            points: points,
            preWeight: pre,
            gainMin: gain?.min ?? 11.5,
            gainMax: gain?.max ?? 16.0,
          ),
        ),
      ),
      const SizedBox(height: 10),
      Row(children: [
        _legendDot(AppTheme.neutral900),
        const SizedBox(width: 6),
        Text(s.chartActualWeight, style: text.labelSmall),
        const SizedBox(width: 16),
        _legendDot(AppTheme.neutral100),
        const SizedBox(width: 6),
        Text(s.chartRecommendedRange, style: text.labelSmall),
      ]),
      const SizedBox(height: 10),
      Text(s.chartFooter, style: text.bodySmall),
    ]);
  }

  Widget _legendDot(Color c) => Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)));
}

class _WeightChartPainter extends CustomPainter {
  _WeightChartPainter({
    required this.points,
    required this.preWeight,
    required this.gainMin,
    required this.gainMax,
  });

  final List<({double week, double weight})> points;
  final double preWeight;
  final double gainMin;
  final double gainMax;

  static const double _wkStart = 4;
  static const double _wkEnd = 40;

  @override
  void paint(Canvas canvas, Size size) {
    // Y range covers the recommended band and any actual entries, with padding.
    var minW = preWeight;
    var maxW = preWeight + gainMax + 3;
    for (final p in points) {
      if (p.weight < minW) minW = p.weight - 1;
      if (p.weight > maxW) maxW = p.weight + 1;
    }
    final span = (maxW - minW) <= 0 ? 1 : (maxW - minW);

    double x(double week) =>
        (week - _wkStart) / (_wkEnd - _wkStart) * size.width;
    double y(double w) => size.height - ((w - minW) / span) * size.height;

    // Recommended range band.
    final band = Path()
      ..moveTo(x(_wkStart), y(preWeight))
      ..lineTo(x(_wkEnd), y(preWeight + gainMin))
      ..lineTo(x(_wkEnd), y(preWeight + gainMax))
      ..lineTo(x(_wkStart), y(preWeight))
      ..close();
    canvas.drawPath(
        band, Paint()..color = AppTheme.neutral100.withValues(alpha: 0.6));

    // Actual line + dots.
    if (points.isNotEmpty) {
      final line = Paint()
        ..color = AppTheme.neutral900
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final path = Path();
      for (int i = 0; i < points.length; i++) {
        final p = Offset(x(points[i].week), y(points[i].weight));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, line);
      final dot = Paint()..color = AppTheme.neutral900;
      for (final p in points) {
        canvas.drawCircle(Offset(x(p.week), y(p.weight)), 4, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter old) =>
      old.points != points ||
      old.preWeight != preWeight ||
      old.gainMin != gainMin ||
      old.gainMax != gainMax;
}
*/
