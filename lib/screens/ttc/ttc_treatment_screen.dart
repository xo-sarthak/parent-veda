// =============================================================================
//  TTC - the treatment cycle
// -----------------------------------------------------------------------------
//  What replaces the fertility window on IVF, IUI and ovulation induction.
//
//  The reframe this whole screen rests on: ParentVeda cannot predict anything
//  useful on a medicated cycle, because ovulation is triggered by an injection
//  at a time a clinic chose after a scan. So it stops competing with the clinic
//  and carries what the clinic said instead. Her dates are facts on a printout;
//  ours would have been arithmetic about a cycle that is not happening.
//
//  Everything here is optional and partial by design. Most couples know the next
//  two dates and not the rest, and a form that demands all five would simply not
//  get filled in.
//
//  One thing is treated differently from the others: the TRIGGER carries a time
//  and gets a reminder, because clinics say "10:15pm exactly" and mean it -
//  retrieval is scheduled a fixed interval afterwards.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_store.dart';
import '../../ttc/ttc_treatment_store.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

void openTtcTreatment(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const TtcTreatmentScreen(),
    settings: const RouteSettings(name: 'ttc/treatment'),
  ));
}

class TtcTreatmentScreen extends StatelessWidget {
  const TtcTreatmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([TtcTreatmentStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final store = TtcTreatmentStore.instance;
        final cycle = store.cycle;
        final next = cycle.next;

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(ttcGutter, 8, ttcGutter, 40),
              children: [
                TtcBackBar(title: t.treatmentTitle),
                const SizedBox(height: 16),
                Text(t.treatmentIntro, style: ttcBody(14, h: 1.6)),
                const SizedBox(height: 20),

                // The next milestone, made large - it is the one thing she
                // opens this screen to check.
                if (next != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ttcCardRadius),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [ttcPurple, Color(0xFF8B4FD0)],
                      ),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.treatmentNext.toUpperCase(),
                              style: ttcBody(10,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  w: FontWeight.w800)),
                          const SizedBox(height: 9),
                          Text(next.$1.label(hi),
                              style: ttcFraunces(25,
                                  w: FontWeight.w600, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(_when(next.$1, next.$2, hi),
                              style: ttcBody(14,
                                  color: Colors.white.withValues(alpha: 0.95),
                                  w: FontWeight.w700)),
                          // The day count, deliberately SECOND and smaller.
                          //
                          // Leading with a countdown turns the screen into
                          // something to endure - "nine days left" is how the
                          // wait already feels without our help. Leading with
                          // the milestone makes it an appointment she has,
                          // rather than a sentence she is serving. The number
                          // still has to be here, though: leave it out and she
                          // counts it herself, which is worse.
                          const SizedBox(height: 5),
                          Text(_daysAway(next.$2, hi),
                              style: ttcBody(12,
                                  color: Colors.white.withValues(alpha: 0.75))),
                          const SizedBox(height: 10),
                          Text(next.$1.note(hi),
                              style: ttcBody(12.5,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  h: 1.5)),
                        ]),
                  ),
                  const SizedBox(height: 20),
                ],

                // WHICH pathway, before the two questions about it.
                //
                // This is the wiring that was missing entirely. TtcStore.setPath
                // had no caller anywhere in the app, and the card that leads
                // here only rendered once a non-natural path was set - so the
                // only way in was through a door that could not open until you
                // were already through it. Every user stayed on `natural`, and
                // the whole ownership model, the two questions, the treatment
                // cycle, the trigger reminders and the beta countdown were
                // unreachable code with forty-seven passing tests over the top.
                const TtcPathChooser(),
                const SizedBox(height: 20),

                // Asked here rather than at signup: this is where she has come
                // BECAUSE the app stopped predicting, so it is the one moment
                // the questions obviously earn their place.
                const TtcPathwayQuestions(),
                const SizedBox(height: 20),

                ttcSectionTitle(t.treatmentDates),
                for (final step in TtcTreatmentStep.values) ...[
                  _StepRow(step: step, at: cycle[step], t: t),
                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 14),
                if (cycle[TtcTreatmentStep.trigger] != null)
                  TtcCard(
                    color: ttcPanel,
                    child: Row(children: [
                      const Icon(Icons.notifications_active_outlined,
                          size: 17, color: ttcPurple),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(t.treatmentTriggerReminder,
                            style: ttcBody(12.5, h: 1.5)),
                      ),
                    ]),
                  ),

                const SizedBox(height: 16),
                if (store.hasDates)
                  GestureDetector(
                    onTap: () => _confirmClear(context, t),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(t.treatmentClear,
                            style: ttcBody(12.5,
                                color: ttcMuted, w: FontWeight.w700)),
                      ),
                    ),
                  ),

                const SizedBox(height: 14),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 15, color: ttcMuted),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(t.treatmentDisclaimer,
                        style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _when(TtcTreatmentStep step, DateTime at, bool hi) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final date = '${at.day} ${m[at.month - 1]}';
    if (!step.needsTime) return date;
    final h = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final ampm = at.hour < 12 ? 'am' : 'pm';
    return '$date · $h:${at.minute.toString().padLeft(2, '0')}$ampm';
  }

  /// "in 9 days" rather than "9 days remaining" - remaining is a sentence being
  /// served, and this is the one stretch of the cycle where nothing she does
  /// changes the date.
  static String _daysAway(DateTime at, bool hi) {
    final today = DateTime.now();
    final days = DateTime(at.year, at.month, at.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    if (days <= 0) return hi ? 'Aaj' : 'Today';
    if (days == 1) return hi ? 'Kal' : 'Tomorrow';
    return hi ? '$days din baad' : 'in $days days';
  }

  Future<void> _confirmClear(BuildContext context, TtcS t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(t.treatmentClear, style: ttcJakarta(16)),
        content: Text(t.treatmentClearBody, style: ttcBody(13.5, h: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.journalCancel,
                style: ttcBody(13, color: ttcSoft, w: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.treatmentClear,
                style: ttcBody(13, color: ttcPurple, w: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok == true) TtcTreatmentStore.instance.clearCycle();
  }
}

/// The tick that silences the trigger reminders.
///
/// Without it the fifteen-minute alert is unsafe: it would fire at someone who
/// already did it, at the exact minute the timing mattered, which is alarm
/// dressed as help. The tick is what earns that reminder its place.
class _TakenTick extends StatelessWidget {
  const _TakenTick({required this.taken, required this.hi});

  final bool taken;
  final bool hi;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => TtcTreatmentStore.instance.setTriggerTaken(!taken),
      behavior: HitTestBehavior.opaque,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: taken ? ttcPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: taken ? ttcPurple : ttcLine, width: 1.4),
          ),
          child: taken
              ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          taken
              ? (hi ? 'Le liya - reminder band' : 'Taken · reminders off')
              : (hi ? 'Le liya? Yahan tick karein' : 'Taken? Tick this'),
          style: ttcBody(11.5,
              color: taken ? ttcPurple : ttcSoft, w: FontWeight.w700),
        ),
      ]),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.at, required this.t});

  final TtcTreatmentStep step;
  final DateTime? at;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final set = at != null;
    return TtcCard(
      onTap: () => _pick(context),
      padding: const EdgeInsets.all(16),
      border: step.needsTime && set ? ttcPurple : null,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: set ? ttcPanel : ttcBg,
            shape: BoxShape.circle,
            border: set ? null : Border.all(color: ttcLine),
          ),
          child: Icon(_icon(step),
              size: 16, color: set ? ttcPurple : ttcMuted),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(step.label(hi),
                style: ttcJakarta(14.5, color: set ? ttcTitleInk : ttcSoft)),
            const SizedBox(height: 3),
            Text(
              set
                  ? TtcTreatmentScreen._when(step, at!, hi)
                  : t.treatmentNotSet,
              style: ttcBody(12.5,
                  color: set ? ttcPurple : ttcMuted, w: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Text(step.note(hi), style: ttcBody(11.5, h: 1.45)),
            // Only the trigger gets a tick, because only the trigger has
            // reminders that must stop. A generic "done" on every step would be
            // a tracker, and a treatment cycle is not hers to complete.
            if (step == TtcTreatmentStep.trigger && set) ...[
              const SizedBox(height: 9),
              _TakenTick(taken: TtcTreatmentStore.instance.cycle.triggerTaken,
                  hi: hi),
            ],
          ]),
        ),
        if (set)
          GestureDetector(
            onTap: () => TtcTreatmentStore.instance.setDate(step, null),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.close_rounded, size: 16, color: ttcMuted),
            ),
          ),
      ]),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: at ?? now,
      firstDate: now.subtract(const Duration(days: 120)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (day == null || !context.mounted) return;

    // Only the trigger asks for a time. Making her set one for every date would
    // be five extra taps for four values nobody needs to the minute.
    if (!step.needsTime) {
      TtcTreatmentStore.instance
          .setDate(step, DateTime(day.year, day.month, day.day));
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(at ?? DateTime(0, 1, 1, 21, 0)),
      helpText: t.treatmentTriggerTime,
    );
    if (!context.mounted) return;
    TtcTreatmentStore.instance.setDate(
      step,
      DateTime(day.year, day.month, day.day, time?.hour ?? 21,
          time?.minute ?? 0),
    );
  }

  static IconData _icon(TtcTreatmentStep step) {
    switch (step) {
      case TtcTreatmentStep.stimStart:
        return Icons.vaccines_outlined;
      case TtcTreatmentStep.trigger:
        return Icons.alarm_on_rounded;
      case TtcTreatmentStep.retrieval:
        return Icons.local_hospital_outlined;
      case TtcTreatmentStep.transfer:
        return Icons.spa_outlined;
      case TtcTreatmentStep.betaTest:
        return Icons.biotech_outlined;
    }
  }
}

/// The "your clinic runs this cycle" card, now with a way in. Shown on Today,
/// Fertility Window and the Ovulation Companion.
class TtcTreatmentEntryCard extends StatelessWidget {
  const TtcTreatmentEntryCard({super.key, required this.t});

  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final store = TtcTreatmentStore.instance;
    final next = store.cycle.next;

    return TtcCard(
      color: const Color(0xFFFDF6EC),
      onTap: () => openTtcTreatment(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.local_hospital_outlined, size: 18, color: ttcBrown),
          const SizedBox(width: 9),
          Expanded(
            child: Text(TtcStore.instance.ownership.title(hi),
                style: ttcJakarta(15.5, color: ttcBrown)),
          ),
        ]),
        const SizedBox(height: 11),
        // The copy differs between the two clinic tiers on purpose: "we are not
        // naming a date, keep logging" is a different message from "nothing of
        // your natural cycle applies here".
        Text(TtcStore.instance.ownership.body(hi),
            style: ttcBody(13.5, color: ttcBrown, h: 1.6)),
        const SizedBox(height: 12),
        ttcDivider(),
        const SizedBox(height: 12),

        if (next != null) ...[
          Text(t.treatmentNext.toUpperCase(),
              style: ttcBody(9.5, color: ttcBrown, w: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            '${next.$1.label(hi)} · '
            '${TtcTreatmentScreen._when(next.$1, next.$2, hi)}',
            style: ttcBody(14, color: ttcBrown, w: FontWeight.w800),
          ),
        ] else ...[
          // The invitation - this is what turns "we cannot help" into "tell us
          // and we can".
          Row(children: [
            const Icon(Icons.add_circle_outline_rounded,
                size: 17, color: ttcBrown),
            const SizedBox(width: 8),
            Expanded(
              child: Text(t.treatmentAddDates,
                  style: ttcBody(13, color: ttcBrown, w: FontWeight.w800)),
            ),
          ]),
          const SizedBox(height: 6),
          Text(t.treatmentAddDatesBody,
              style: ttcBody(12, color: ttcBrown, h: 1.5)),
        ],

        // If we are assuming rather than knowing, say so and offer the fix.
        // Someone on unmonitored letrozole is currently having their fertile
        // window withheld on a default, and two taps would give it back.
        if (!TtcStore.instance.pathwayAnswered &&
            TtcStore.instance.path.answersMatter) ...[
          const SizedBox(height: 12),
          ttcDivider(),
          const SizedBox(height: 11),
          Row(children: [
            const Icon(Icons.help_outline_rounded, size: 16, color: ttcBrown),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.pathwayAnswerCta,
                        style:
                            ttcBody(12.5, color: ttcBrown, w: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(t.pathwayAnswerBody,
                        style: ttcBody(11.5, color: ttcBrown, h: 1.45)),
                  ]),
            ),
          ]),
        ],
      ]),
    );
  }
}

/// Whether the treatment card should be shown at all - i.e. she is on a
/// clinic-run path.
bool ttcShowTreatment() => TtcStore.instance.behaviour.showsClinicTimeline;

// ---- the two questions ------------------------------------------------------

/// The whole point of the care-pathway refactor, in one card.
///
/// Treatment type alone cannot tell these two cases apart:
///
///   letrozole, no monitoring, no trigger  → her body decides, we can help
///   letrozole, scans and a trigger        → the clinic decides, we must not
///
/// So we ask. It is two taps, and getting it right is the difference between
/// being useful and being switched off for no reason.
/// The five pathways, as a list she picks from.
///
/// Ordered natural-first and worded so choosing "no clinic" does not read as
/// admitting to something. Changing it is explicitly reversible - a cycle can
/// go from IUI back to natural, and a chooser that felt permanent would stop
/// people using it honestly.
class TtcPathChooser extends StatelessWidget {
  const TtcPathChooser({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final current = TtcStore.instance.path;

        return TtcCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.pathwayChooseTitle, style: ttcJakarta(16)),
            const SizedBox(height: 8),
            Text(t.pathwayChooseBody, style: ttcBody(12.5, h: 1.55)),
            const SizedBox(height: 16),
            for (final path in TtcPath.values) ...[
              GestureDetector(
                onTap: () => TtcStore.instance.setPath(path),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 9),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                  decoration: BoxDecoration(
                    color: path == current ? ttcPurple : ttcPanel,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(path.label(hi),
                                style: ttcBody(13.5,
                                    color: path == current
                                        ? Colors.white
                                        : ttcInk,
                                    w: FontWeight.w700)),
                            if (path == TtcPath.natural) ...[
                              const SizedBox(height: 3),
                              Text(t.pathwayNaturalNote,
                                  style: ttcBody(11,
                                      color: path == current
                                          ? Colors.white
                                              .withValues(alpha: 0.85)
                                          : ttcMuted)),
                            ],
                          ]),
                    ),
                    if (path == current)
                      const Icon(Icons.check_rounded,
                          size: 17, color: Colors.white),
                  ]),
                ),
              ),
            ],
          ]),
        );
      },
    );
  }
}

class TtcPathwayQuestions extends StatelessWidget {
  const TtcPathwayQuestions({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final store = TtcStore.instance;
        final pathway = store.pathway;

        // Only asked where the answers actually change something. On trying
        // naturally and on IVF the outcome is the same either way, so asking
        // would be collecting data we would not act on.
        if (!pathway.path.answersMatter) return const SizedBox();

        return TtcCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.pathwayQuestionsTitle, style: ttcJakarta(16)),
            const SizedBox(height: 8),
            Text(t.pathwayQuestionsWhy, style: ttcBody(12.5, h: 1.55)),
            const SizedBox(height: 16),
            _Question(
              text: t.pathwayQMonitor,
              examples: t.pathwayQMonitorEg,
              value: pathway.clinicMonitors,
              onChanged: store.setClinicMonitors,
              t: t,
            ),
            const SizedBox(height: 14),
            ttcDivider(),
            const SizedBox(height: 14),
            _Question(
              text: t.pathwayQMedicated,
              examples: t.pathwayQMedicatedEg,
              value: pathway.medicationControlsOvulation,
              onChanged: store.setMedicationControlsOvulation,
              t: t,
            ),
          ]),
        );
      },
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.text,
    required this.examples,
    required this.value,
    required this.onChanged,
    required this.t,
  });

  final String text;

  /// The recognition line. She should not have to translate her own cycle into
  /// our vocabulary to answer - naming the things that actually happen to her
  /// does that work instead.
  final String examples;

  final bool? value;
  final ValueChanged<bool?> onChanged;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    Widget option(String label, bool? v) {
      final on = value == v;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          // Tapping the chosen one again clears it back to "not sure", so an
          // answer is never a trap.
          onTap: () => onChanged(on ? null : v),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
            decoration: BoxDecoration(
              color: on ? ttcPurple : ttcPanel,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                style: ttcBody(12.5,
                    color: on ? Colors.white : ttcSoft, w: FontWeight.w800)),
          ),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(text, style: ttcBody(13.5, color: ttcInk, h: 1.5)),
      const SizedBox(height: 6),
      Text(examples, style: ttcBody(11.5, color: ttcMuted, h: 1.45)),
      const SizedBox(height: 11),
      Row(children: [
        option(t.pathwayYes, true),
        option(t.pathwayNo, false),
        if (value == null)
          Text(t.pathwayNotSure,
              style: ttcBody(11.5, color: ttcMuted, w: FontWeight.w700)),
      ]),
    ]);
  }
}
