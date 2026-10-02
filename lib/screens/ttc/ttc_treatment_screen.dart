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
import '../../ttc/ttc_treatment_round.dart';
import '../../ttc/ttc_treatment_store.dart';
import '../../theme/pv_fonts.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_common.dart';
import 'ttc_ivf_readiness_screen.dart' show kIvfHue;
import 'ttc_tool_chrome.dart';
import 'ttc_strings.dart';
import 'ttc_round_strings.dart';
import 'ttc_surface_router.dart' show openTtcSurface;
import 'ttc_round_home_card.dart' show TtcRoundCheckInCard;
import 'ttc_treatment_round_screens.dart';

void openTtcTreatment(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const TtcTreatmentScreen(),
      settings: const RouteSettings(name: 'ttc/treatment'),
    ),
  );
}

// ⚠️ KEPT FOR REVERT (2026-09-27, the tool rebuild): the screen until the
// rebuild at the foot of this file. Unreached; `TtcTreatmentScreen` below is
// the one every opener pushes. Its static helpers are still shared.
class TtcTreatmentScreenClassic extends StatelessWidget {
  const TtcTreatmentScreenClassic({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        TtcTreatmentStore.instance,
        TtcLang.instance,
      ]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final store = TtcTreatmentStore.instance;
        final cycle = store.cycle;
        final next = cycle.next;

        // ⚠️ V3 CHROME, AND THE CONTENT UNDERNEATH IS UNCHANGED. This screen
        // was already the best-reasoned tool in the door — see the note on the
        // next-milestone card about why the countdown is second and smaller.
        // What was old was the shell: a flat `ttcBg`, a back bar, and a purple
        // gradient block at the top.
        //
        // A tool reached from a focus page has to look like it belongs to the
        // page that sent her. `TtcToolScaffold` is the shared shell every TTC
        // tool now wears — see `ttc_tool_chrome.dart`.
        // ⚠️ A ROUND SINCE 2026-09-26 (docs/TTC-TREATMENT-FLOW.md, B3). With
        // no round, the screen opens on "Starting treatment?"; with a round
        // saved by the start flow, on its plan ("Here's how your round
        // usually goes") and the actions that change it, each confirmed and
        // undoable. A legacy round (dates from before rounds, no kind) keeps
        // the five date rows below and is asked what kind it is.
        if (!store.isLoaded) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: ttcTitleInk)),
          );
        }
        final round = cycle;
        final hasKind = round.kind != null && !round.isEmpty;
        final legacy = round.kind == null && !round.isEmpty;
        final phase = ttcTreatmentPhase(round, DateTime.now());
        final canResult =
            hasKind &&
            (phase == TtcRoundPhase.testDay ||
                ttcRoundBloodTest(round) != null &&
                    !ttcRoundBloodTest(round)!.isAfter(DateTime.now()));

        return TtcToolScaffold(
          hue: kIvfHue,
          eyebrow: t.treatmentTitle,
          // ⚠️ THE HERO ANSWERS "WHAT AM I LOOKING AT", not "what is this
          // called". A tool opened mid-cycle at speed needs the sentence, not
          // the label — the label is the eyebrow above it.
          // ⚠️ ONE LINE, NO FORCED BREAK (2026-10-02, the user: "why is the
          // dates your clinic gave you in half written in next line?"). The
          // title was a hard break in the middle of a phrase ('The dates
          // your' / 'clinic gave you.'), and the intro below says "Add the
          // dates your clinic gave you" straight after. It is the clinic's
          // dates, said short. Kept for revert: the two-line title.
          title: "Your clinic's dates.",
          // ⚠️ SAYS WHAT SHE DOES HERE, ONCE (tools pass, 2026-09-27). The
          // old intro opened by repeating the title, and its "your clinic's
          // dates count" line is said again by the note at the foot, so it
          // now says the job and what she gets for it. The Hindi build keeps
          // the shipped pair. Kept for revert: `intro: t.treatmentIntro,`.
          intro: hi
              ? t.treatmentIntro
              : "Add the dates your clinic gave you, and we'll remind you "
                    'before the trigger injection. Fill in what you know. '
                    'The rest can wait.',
          children: [
            const SizedBox(height: 22),

            // ---- no round: the way in -----------------------------------
            if (round.isEmpty) ...[
              ttcToolPad(const TtcStartTreatmentCard()),
              const SizedBox(height: 20),
            ],

            // ---- the round she can still reopen (7 days) ----------------
            if (store.canUndoClose()) ...[
              ttcToolPad(_UndoCloseCard(store: store)),
              const SizedBox(height: 20),
            ],

            // ---- the check-in, when it is due ----------------------------
            if (store.checkInDue()) ...[
              ttcToolPad(
                TtcRoundCheckInCard(
                  onAnswer: () => showTtcCheckInSheet(context),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ---- a legacy round: what kind is it? ------------------------
            if (legacy) ...[
              ttcToolPad(
                TtcRoundOption(
                  key: const ValueKey('ttc_round_legacy_kind'),
                  title: kTtcRoundLegacyTitle,
                  line: kTtcRoundLegacyBody,
                  icon: Icons.help_outline_rounded,
                  onTap: () => openTtcTreatmentStart(context),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ---- a round: its step today, then the plan ------------------
            if (hasKind) ...[
              ttcToolPad(_RoundHeader(round: round, phase: phase)),
              const SizedBox(height: 18),
              if (canResult) ...[
                ttcToolPad(
                  TtcRoundButton(
                    key: const ValueKey('ttc_round_tell_result'),
                    label: kTtcRoundTellResult,
                    onTap: () => openTtcTreatmentResult(context),
                  ),
                ),
                const SizedBox(height: 18),
              ],
              ttcToolPad(ttcSectionTitle(kTtcRoundPlanTitle)),
              ttcToolPad(Text(kTtcRoundPlanBody, style: ttcBody(12.5, h: 1.5))),
              const SizedBox(height: 16),
              ttcToolPad(TtcRoundTimeline(round: round)),
              const SizedBox(height: 6),
              // Daily injections live in the medication schedule
              // (decision 4), which already has times and a taken tick.
              ttcToolPad(
                TtcCard(
                  onTap: () => openTtcSurface(context, 'ttc_medication'),
                  // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
                  border: ttcLine,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.medication_outlined,
                        size: 18,
                        color: ttcTitleInk,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          kTtcRoundMedicationLink,
                          style: ttcBody(12.5, h: 1.5),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: ttcMuted,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              ttcToolPad(
                TtcRoundButton(
                  key: const ValueKey('ttc_round_plan_changed'),
                  label: kTtcRoundPlanChanged,
                  primary: false,
                  onTap: () => showTtcPlanChangedSheet(context),
                ),
              ),
              const SizedBox(height: 8),
              ttcToolPad(
                TtcRoundButton(
                  key: const ValueKey('ttc_round_pause'),
                  label: kTtcRoundTakeBreak,
                  primary: false,
                  onTap: () =>
                      ttcConfirmCloseRound(context, TtcRoundOutcome.paused),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // The next milestone, made large - it is the one thing she
            // opens this screen to check.
            // A round shows its step in the header above; the big card
            // stays for a legacy round (2026-09-26).
            if (next != null && !hasKind) ...[
              // ⚠️ FLAT, NOT A DIAGONAL GRADIENT. The two-stop purple wash
              // was the loudest object in the stage, on a screen someone
              // opens while anxious. It is also the exact texture that was
              // called out on the video placeholders: a gradient reads as
              // decoration, and decoration on a date she is dreading is the
              // wrong register.
              //
              // Solid `ttcPurple` keeps every bit of the emphasis — this is
              // still the only filled block on the page — and loses the
              // shine.
              ttcToolPad(
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: ttcTitleInk,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.treatmentNext.toUpperCase(),
                        style: ttcBody(
                          10,
                          color: Colors.white.withValues(alpha: 0.8),
                          w: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 9),
                      // One name with the rows (2026-09-27). Kept for
                      // revert: Text(next.$1.label(hi), ...).
                      Text(
                        _StepRow._label(next.$1, hi),
                        style: ttcFraunces(
                          25,
                          w: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _when(next.$1, next.$2, hi),
                        style: ttcBody(
                          14,
                          color: Colors.white.withValues(alpha: 0.95),
                          w: FontWeight.w700,
                        ),
                      ),
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
                      Text(
                        _daysAway(next.$2, hi),
                        style: ttcBody(
                          12,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        next.$1.note(hi),
                        style: ttcBody(
                          12.5,
                          color: Colors.white.withValues(alpha: 0.9),
                          h: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
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
            //
            // ⚠️ COMMENTED OUT 2026-09-26, KEPT FOR REVERT (the user's
            // decision 2, docs/TTC-TREATMENT-FLOW.md §7). The kind of round
            // is asked by the start flow, and who owns the timing is worked
            // out from the kind and whether a trigger is dated
            // (`ttcRoundTier`), so neither the path chooser nor the two
            // questions are asked here any more. Both widgets still exist
            // below. To revert, restore these four lines:
            //
            // ttcToolPad(const TtcPathChooser()),
            // const SizedBox(height: 20),
            // ttcToolPad(const TtcPathwayQuestions()),
            // const SizedBox(height: 20),

            // The five original rows, for a legacy round only: a round
            // with a kind shows its own timeline above. Kept for revert:
            // the rows rendered for every round, over all five steps.
            //
            // ⚠️ AN IUI OR TABLETS CYCLE IS NOT SHOWN IVF ROWS (tools pass,
            // 2026-09-27). A legacy round has no kind, but her path does:
            // on IUI or ovulation induction the transfer row (and, on
            // tablets, egg collection) could only ever sit empty and read
            // like something missed, so it is left out unless a date is
            // already on it. On IUI the retrieval row is named "IUI".
            if (legacy) ...[
              ttcToolPad(ttcSectionTitle(t.treatmentDates)),
              for (final step in _legacySteps(cycle)) ...[
                ttcToolPad(_StepRow(step: step, at: cycle[step], t: t)),
                const SizedBox(height: 10),
              ],
            ],

            const SizedBox(height: 14),
            if (cycle[TtcTreatmentStep.trigger] != null)
              ttcToolPad(
                TtcCard(
                  // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
                  border: ttcLine,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_outlined,
                        size: 17,
                        color: ttcTitleInk,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          t.treatmentTriggerReminder,
                          style: ttcBody(12.5, h: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),
            // "Remove these dates": for a round entered by mistake. Ending
            // a round is closing it (kept in history); this is the one
            // action that removes dates, so it says so before it does.
            // Kept for revert: the label was `t.treatmentClear`.
            if (store.hasDates)
              ttcToolPad(
                Semantics(
                  button: true,
                  child: GestureDetector(
                    key: const ValueKey('ttc_round_remove'),
                    onTap: () => _confirmClear(context, t),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          kTtcRoundRemove,
                          style: ttcBody(
                            12.5,
                            color: ttcMuted,
                            w: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ---- past rounds: kept, never deleted ------------------------
            if (store.history.isNotEmpty) ...[
              const SizedBox(height: 14),
              ttcToolPad(ttcSectionTitle(kTtcRoundPastTitle)),
              ttcToolPad(
                Text(kTtcRoundHistoryNote, style: ttcBody(12, color: ttcMuted)),
              ),
              const SizedBox(height: 10),
              for (var i = store.history.length - 1; i >= 0; i--) ...[
                ttcToolPad(_PastRoundRow(n: i + 1, round: store.history[i])),
                const SizedBox(height: 8),
              ],
            ],

            const SizedBox(height: 14),
            ttcToolPad(
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: ttcMuted,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      t.treatmentDisclaimer,
                      style: ttcBody(11.5, color: ttcMuted, h: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
          ],
        );
      },
    );
  }

  // ⚠️ WITH THE WEEKDAY (tools pass, 2026-09-27): "Thu 12 Oct", the round's
  // own format, because people plan an early scan by the day of the week.
  // Kept for revert: the body built '${at.day} ${m[at.month - 1]}' from a
  // local month list and its own am/pm maths.
  static String _when(TtcTreatmentStep step, DateTime at, bool hi) {
    final date = ttcRoundDate(at);
    if (!step.needsTime) return date;
    return '$date · ${ttcRoundTime(at)}';
  }

  /// The legacy rows that apply to her path (see the note where they render).
  static List<TtcTreatmentStep> _legacySteps(TtcTreatmentCycle cycle) {
    final path = TtcStore.instance.path;
    final iui = path == TtcPath.iui;
    final tablets = path == TtcPath.ovulationInduction;
    return [
      for (final step in kTtcOriginalTreatmentSteps)
        if (cycle[step] != null ||
            !((iui || tablets) && step == TtcTreatmentStep.transfer) &&
                !(tablets && step == TtcTreatmentStep.retrieval))
          step,
    ];
  }

  /// "in 9 days" rather than "9 days remaining" - remaining is a sentence being
  /// served, and this is the one stretch of the cycle where nothing she does
  /// changes the date.
  static String _daysAway(DateTime at, bool hi) {
    final today = DateTime.now();
    final days = DateTime(
      at.year,
      at.month,
      at.day,
    ).difference(DateTime(today.year, today.month, today.day)).inDays;
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
        // Kept for revert: `t.treatmentClear` and `t.treatmentClearBody`,
        // which said to clear a round when it ENDS. Ending is closing now.
        title: Text(kTtcRoundRemove, style: ttcJakarta(16)),
        content: Text(kTtcRoundRemoveBody, style: ttcBody(13.5, h: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              t.journalCancel,
              style: ttcBody(13, color: ttcSoft, w: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              kTtcRoundRemove,
              style: ttcBody(13, color: ttcTitleInk, w: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    if (ok == true) TtcTreatmentStore.instance.clearCycle();
  }
}

/// Where the round stands today: its kind, clinic, step and next date.
class _RoundHeader extends StatelessWidget {
  const _RoundHeader({required this.round, required this.phase});

  final TtcTreatmentCycle round;
  final TtcRoundPhase phase;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final next = ttcRoundNextAfter(round, now);
    final first = ttcFirstTreatmentDate(round);
    String? nextLine;
    if (phase == TtcRoundPhase.planned && first != null) {
      nextLine = 'Your home follows your round from ${ttcRoundDate(first)}.';
    } else if (next != null) {
      final name = next.$1 == null
          ? ttcScanLabel(round.kind)
          : ttcStepLabel(next.$1!, round.kind);
      nextLine = 'Next: $name, ${ttcRoundDate(next.$2)}.';
    }
    return Container(
      key: const ValueKey('ttc_round_header'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
        color: Colors.white, border: const Border.fromBorderSide(BorderSide(color: ttcLine)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              ttcRoundKindName(round.kind!).toUpperCase(),
              if (round.clinic.isNotEmpty) round.clinic.toUpperCase(),
            ].join(' · '),
            style: ttcBody(10, color: ttcSoft, w: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            ttcRoundPhaseName(phase, round.kind),
            style: ttcFraunces(24, w: FontWeight.w600, color: ttcTitleInk),
          ),
          if (nextLine != null) ...[
            const SizedBox(height: 6),
            Text(
              nextLine,
              style: ttcBody(13.5, color: ttcTitleInk, w: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}

/// A round closed in the last 7 days, and the way to reopen it exactly.
class _UndoCloseCard extends StatelessWidget {
  const _UndoCloseCard({required this.store});
  final TtcTreatmentStore store;

  @override
  Widget build(BuildContext context) {
    final last = store.lastClosed!;
    return TtcCard(
      key: const ValueKey('ttc_round_undo_card'),
      // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
      border: ttcLine,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kTtcUndoCardLine,
                  style: ttcBody(13, color: ttcTitleInk, w: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ttcRoundHistoryLabel(store.history.length, last)} · '
                  '${ttcRoundOutcomeLabel(last.outcome)}',
                  style: ttcBody(12, h: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            key: const ValueKey('ttc_round_undo'),
            onPressed: store.undoClose,
            child: Text(
              kTtcRoundUndoCta,
              style: ttcBody(13.5, color: ttcTitleInk, w: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

/// One closed round, kept: "Round 1, Sep to Oct · Not this time".
class _PastRoundRow extends StatelessWidget {
  const _PastRoundRow({required this.n, required this.round});
  final int n;
  final TtcTreatmentCycle round;

  @override
  Widget build(BuildContext context) {
    return TtcCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, size: 18, color: ttcMuted),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ttcRoundHistoryLabel(n, round),
                  style: ttcBody(13.5, color: ttcTitleInk, w: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    if (round.kind != null) ttcRoundKindName(round.kind!),
                    ttcRoundOutcomeLabel(round.outcome),
                    '${round.allDates.length} dates',
                  ].join(' · '),
                  style: ttcBody(12, h: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: taken ? ttcTitleInk : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: taken ? ttcTitleInk : ttcLine,
                width: 1.4,
              ),
            ),
            child: taken
                ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          // Flexible since the label names the trigger (2026-09-28).
          Flexible(
            child: Text(
              taken
                  ? (hi ? 'Le liya - reminder band' : 'Taken · reminders off')
                  // Kept for revert (2026-09-28): 'Taken it? Tick here'
                  : (hi
                        ? 'Le liya? Yahan tick karein'
                        : 'Trigger taken? Tap to tick'),
              style: ttcBody(
                11.5,
                color: taken ? ttcTitleInk : ttcSoft,
                w: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
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
      border: step.needsTime && set ? ttcTitleInk : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: set ? ttcPanel : ttcBg,
              shape: BoxShape.circle,
              border: set ? null : Border.all(color: ttcLine),
            ),
            child: Icon(
              _icon(step),
              size: 16,
              color: set ? ttcTitleInk : ttcMuted,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label(step, hi),
                  style: ttcJakarta(14.5, color: set ? ttcTitleInk : ttcSoft),
                ),
                const SizedBox(height: 3),
                Text(
                  set
                      ? TtcTreatmentScreenClassic._when(step, at!, hi)
                      : t.treatmentNotSet,
                  style: ttcBody(
                    12.5,
                    color: set ? ttcTitleInk : ttcMuted,
                    w: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(step.note(hi), style: ttcBody(11.5, h: 1.45)),
                // Only the trigger gets a tick, because only the trigger has
                // reminders that must stop. A generic "done" on every step would be
                // a tracker, and a treatment cycle is not hers to complete.
                if (step == TtcTreatmentStep.trigger && set) ...[
                  const SizedBox(height: 9),
                  _TakenTick(
                    taken: TtcTreatmentStore.instance.cycle.triggerTaken,
                    hi: hi,
                  ),
                ],
              ],
            ),
          ),
          // The cross now offers Undo (tools pass, 2026-09-27): it sits right
          // beside the row she taps to edit, and the date came off a printout.
          // Kept for revert: onTap was `setDate(step, null)` alone.
          if (set)
            Semantics(
              button: true,
              label: 'Remove this date',
              child: GestureDetector(
                key: ValueKey('ttc_legacy_clear_${step.name}'),
                onTap: () {
                  final store = TtcTreatmentStore.instance;
                  final was = at;
                  final taken = store.cycle.triggerTaken;
                  store.setDate(step, null);
                  ttcRoundDateRemoved(context, _label(step, hi), () {
                    store.setDate(step, was);
                    if (step == TtcTreatmentStep.trigger && taken) {
                      store.setTriggerTaken(true);
                    }
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.close_rounded, size: 16, color: ttcMuted),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// On an IUI path the retrieval row is the IUI itself.
  /// ⚠️ ONE NAME PER STEP (tools pass, 2026-09-27): in English these rows now
  /// use the round's names (`ttcStepLabel`: "Trigger injection", "Blood
  /// test"), the ones her plan and calendar show, instead of the older
  /// "Beta hCG blood test". The Hindi build keeps the shipped labels.
  static String _label(TtcTreatmentStep step, bool hi) =>
      step == TtcTreatmentStep.retrieval &&
          TtcStore.instance.path == TtcPath.iui
      ? 'IUI'
      : hi
      ? step.label(hi)
      : ttcStepLabel(step, null);

  // ⚠️ THE ROUND'S OWN PICKER NOW (tools pass, 2026-09-27). It titles the
  // calendar with the step's name, checks an out-of-order date, and never
  // invents a trigger time: a closed clock used to save 9:00pm here
  // (`time?.hour ?? 21`) and arm reminders for it. Kept for revert, the old
  // body: showDatePicker (120 days back, 365 ahead, no title), then for the
  // trigger showTimePicker(helpText: t.treatmentTriggerTime) and
  //   setDate(step, DateTime(day.year, day.month, day.day,
  //       time?.hour ?? 21, time?.minute ?? 0));
  Future<void> _pick(BuildContext context) async {
    final store = TtcTreatmentStore.instance;
    final picked = await ttcPickRoundDate(
      context,
      round: store.cycle,
      step: step,
      help: _label(step, t.hinglish),
    );
    if (picked == null || !context.mounted) return;
    store.setDate(step, picked);
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
      default:
        return Icons.event_outlined; // the steps added 2026-09-26
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

    // ⚠️ V3 (2026-09-27, the tool rebuild): a white object card with a
    // hairline and ink, the round's own vocabulary, where it was a V1
    // `TtcCard` in the caution cream with brown type. Same words, same tap.
    // Kept for revert: TtcCard(color: ttcCautionCard, ...) with ttcBrown
    // ttcJakarta/ttcBody type throughout.
    final p = V2PaletteStore.instance.current;
    return Semantics(
      button: true,
      onTap: () => openTtcTreatment(context),
      child: Material(
        key: const ValueKey('ttc_treatment_entry_card'),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: ttcLine, width: 1.2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => openTtcTreatment(context),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_hospital_outlined,
                      size: 18,
                      color: ttcTitleInk,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        TtcStore.instance.ownership.title(hi),
                        style: pvManrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: p.ink1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // The copy differs between the two clinic tiers on purpose: "we are not
                // naming a date, keep logging" is a different message from "nothing of
                // your natural cycle applies here".
                Text(
                  TtcStore.instance.ownership.body(hi),
                  style: pvManrope(fontSize: 13.5, height: 1.55, color: p.ink2),
                ),
                const SizedBox(height: 12),
                Divider(color: p.line, height: 1),
                const SizedBox(height: 12),

                if (next != null) ...[
                  Text(
                    t.treatmentNext.toUpperCase(),
                    style: pvManrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: p.ink3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    // One name with the rows (2026-09-27). Was next.$1.label(hi).
                    '${_StepRow._label(next.$1, hi)} · '
                    '${TtcTreatmentScreenClassic._when(next.$1, next.$2, hi)}',
                    style: pvManrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: p.ink1,
                    ),
                  ),
                ] else ...[
                  // The invitation - this is what turns "we cannot help" into "tell us
                  // and we can".
                  Row(
                    children: [
                      const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 17,
                        color: ttcTitleInk,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.treatmentAddDates,
                          style: pvManrope(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: p.ink1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.treatmentAddDatesBody,
                    style: pvManrope(
                      fontSize: 12.5,
                      height: 1.5,
                      color: p.ink2,
                    ),
                  ),
                ],

                // If we are assuming rather than knowing, say so and offer the fix.
                // Someone on unmonitored letrozole is currently having their fertile
                // window withheld on a default, and two taps would give it back.
                // ⚠️ COMMENTED OUT 2026-09-26 WITH THE TWO QUESTIONS (decision 2):
                // the tier comes from the round now, so there is nothing to answer.
                // Kept for revert: the condition was
                //   !TtcStore.instance.pathwayAnswered &&
                //       TtcStore.instance.path.answersMatter
                // if (...) ...[
                // const SizedBox(height: 12),
                // ttcDivider(),
                // const SizedBox(height: 11),
                // Row(children: [
                // const Icon(Icons.help_outline_rounded, size: 16, color: ttcBrown),
                // const SizedBox(width: 8),
                // Expanded(
                // child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                // children: [
                // Text(t.pathwayAnswerCta,
                // style:
                // ttcBody(12.5, color: ttcBrown, w: FontWeight.w800)),
                // const SizedBox(height: 3),
                // Text(t.pathwayAnswerBody,
                // style: ttcBody(11.5, color: ttcBrown, h: 1.45)),
                // ]),
                // ),
                // ]),
                // ],
              ],
            ),
          ),
        ),
      ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      // ⚠️ THE PURPLE BAR IS GONE. Reported on sight: *"I can see
                      // a purple bar which isn't what we are following right now
                      // to select an option."* It was a full-width solid accent
                      // block, which is the accent used as a surface — the one
                      // thing the design system says it is never for.
                      //
                      // This is now the same treatment as the option blocks in
                      // "Check my readiness" and "Where do I stand": the hue at
                      // tint strength, an ink edge, ink type. One selection
                      // language across every tool in the stage.
                      color: path == current
                          ? v2BlockTint(
                              kIvfHue,
                              V2PaletteStore.instance.current,
                            )
                          : ttcPanel,
                      borderRadius: BorderRadius.circular(16),
                      border: path == current
                          ? Border.all(color: ttcTitleInk, width: 1.5)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                path.label(hi),
                                style: ttcBody(
                                  13.5,
                                  color: ttcTitleInk,
                                  w: FontWeight.w700,
                                ),
                              ),
                              if (path == TtcPath.natural) ...[
                                const SizedBox(height: 3),
                                // ⚠️ ONE INK, BOTH STATES. This was white on the
                                // selected row, which was correct while the row
                                // was solid purple and invisible the moment it
                                // became a pale tint — white on light blue, which
                                // is how "no clinic involved with this cycle"
                                // disappeared exactly when it was chosen.
                                //
                                // The general lesson is worth more than the fix:
                                // a colour written as "white, because the
                                // background is dark" is a colour that depends on
                                // a fact stated somewhere else. When the two are
                                // in different widgets, changing one silently
                                // breaks the other and nothing fails.
                                Text(
                                  t.pathwayNaturalNote,
                                  style: ttcBody(11, color: ttcSoft),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // ⚠️ NO TICK. Same leftover: a white check mark on a solid
                        // block, now invisible on a pale one. It was never needed —
                        // the fill and the ink edge already say which row is
                        // chosen, and a tick beside them is a third signal for a
                        // fact that two are already carrying.
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            ],
          ),
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
              // ⚠️ THE TINT AND AN INK EDGE, NEVER THE ACCENT. Same call as the
              // self-read tools: purple is spent at decision points and is not
              // laid down as a fill. A solid violet chip beside a page of pale
              // blocks is also simply the loudest thing on screen, which puts
              // the emphasis on the control rather than the question.
              color: on
                  ? v2BlockTint(kIvfHue, V2PaletteStore.instance.current)
                  : ttcPanel,
              borderRadius: BorderRadius.circular(999),
              border: on ? Border.all(color: ttcTitleInk, width: 1.5) : null,
            ),
            child: Text(
              label,
              style: ttcBody(
                12.5,
                color: on ? ttcTitleInk : ttcSoft,
                w: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: ttcBody(13.5, color: ttcInk, h: 1.5)),
        const SizedBox(height: 6),
        Text(examples, style: ttcBody(11.5, color: ttcMuted, h: 1.45)),
        const SizedBox(height: 11),
        Row(
          children: [
            option(t.pathwayYes, true),
            option(t.pathwayNo, false),
            if (value == null)
              Text(
                t.pathwayNotSure,
                style: ttcBody(11.5, color: ttcMuted, w: FontWeight.w700),
              ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
//  THE REBUILD — 2026-09-27, the tool rebuild (the user, walking build 13:
//  "old tools in new clothes… poor functionality")
// -----------------------------------------------------------------------------
//  Used like a first-time user, every tap, the round screen had these holes:
//
//  * **"I'll add it later" undid itself.** Saving a round with no dates yet
//    (the start flow's own second button) came back to "Starting treatment?"
//    as if nothing had been saved, because the screen asked "does the round
//    have dates" where it meant "is there a round". A round with a kind and
//    no dates now shows its plan, every step saying "Your clinic will tell
//    you" with "Add date" beside it.
//  * **The clinic's name could only be typed once,** on the last start
//    screen. It shows on the round now with "Add clinic" / "Change".
//  * **Past rounds were names in a list that opened nothing.** A tap opens
//    the round's dates to look back at (read-only: every edit on a timeline
//    writes to the open round).
//  * **Today was not said.** The header named the phase; it now says what is
//    on today, the day count, and the next date with how far off it is, the
//    shape of Oura's "7 days until next dose" hero
//    (https://mobbin.com/screens/34b5f9ab-7c53-4b07-a724-d4db1b297e63).
//  * **Old chrome:** `TtcCard`s, a violet reminder icon, a solid violet
//    "Next" card on a legacy round, a grey Material `AlertDialog` for "Remove
//    these dates", `ttcSectionTitle` from the V1 look. All of it is the
//    round's own vocabulary now: white objects with a hairline, ink, the
//    round's confirm dialog, the tool shell's headings.
//
//  Unchanged on purpose (the user's rule): every date rule, the reminder
//  times, when a round closes, the check-in that never closes a round, the
//  7-day undo on every close, and every stored key.
// =============================================================================

/// The screen's section heading, in the tool shell's type.
///
/// 2026-09-29 (one heading style): the stage's one heading now. Kept for
/// revert: Text(text, style: pvFraunces(fontSize: 20,
///     fontWeight: FontWeight.w600, height: 1.25,
///     color: V2PaletteStore.instance.current.ink1)).
Widget _heading(String text) => TtcSectionHeading(text);

/// A white row with a hairline: an icon, words, and a chevron when it opens
/// something. What `TtcCard(color: ttcPanel)` was used for here.
class TtcRoundInfoRow extends StatelessWidget {
  const TtcRoundInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Semantics(
      button: onTap != null,
      label: text,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ttcLine, width: 1.2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
            child: Row(
              children: [
                Icon(icon, size: 18, color: ttcTitleInk),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    text,
                    style: pvManrope(fontSize: 13, height: 1.45, color: p.ink1),
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_right_rounded, size: 18, color: p.ink3),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Add clinic" or "Change": the clinic's name, after the start flow.
const String kTtcClinicSheetTitle = 'Which clinic?';
const String kTtcClinicSheetBody =
    'Only you see this, and your partner if he has joined.';

Future<void> showTtcClinicSheet(BuildContext context) async {
  final store = TtcTreatmentStore.instance;
  final was = store.cycle.clinic;
  final name = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    routeSettings: const RouteSettings(name: 'ttc/treatment/clinic'),
    builder: (_) => _ClinicSheet(initial: was),
  );
  if (name == null || !context.mounted) return;
  store.setClinic(name);
  final now = name.trim();
  if (now == was) return;
  pvSnack(
    context,
    now.isEmpty ? 'Clinic name removed.' : 'Clinic saved.',
    icon: Icons.check_rounded,
    lift: 24,
    action: kTtcRoundUndoCta,
    onAction: () => store.setClinic(was),
  );
}

class _ClinicSheet extends StatefulWidget {
  const _ClinicSheet({required this.initial});
  final String initial;

  @override
  State<_ClinicSheet> createState() => _ClinicSheetState();
}

class _ClinicSheetState extends State<_ClinicSheet> {
  late final TextEditingController _c = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ttcLine,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  kTtcClinicSheetTitle,
                  style: pvFraunces(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    color: p.ink1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  kTtcClinicSheetBody,
                  style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2),
                ),
                const SizedBox(height: 14),
                TextField(
                  key: const ValueKey('ttc_clinic_field'),
                  controller: _c,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (v) => Navigator.of(context).pop(v),
                  // A one-tap clear, as on the start flow (2026-09-29): Save
                  // with the field empty removes the name, with Undo.
                  onChanged: (_) => setState(() {}),
                  style: pvManrope(fontSize: 14.5, color: ttcTitleInk),
                  decoration: InputDecoration(
                    suffixIcon: _c.text.isEmpty
                        ? null
                        : IconButton(
                            key: const ValueKey('ttc_clinic_clear'),
                            tooltip: 'Clear the clinic name',
                            icon: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: p.ink3,
                            ),
                            onPressed: () => setState(_c.clear),
                          ),
                    hintText: 'Clinic name',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: ttcLine),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: ttcTitleInk,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TtcRoundButton(
                  key: const ValueKey('ttc_clinic_save'),
                  label: 'Save',
                  onTap: () => Navigator.of(context).pop(_c.text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TtcTreatmentScreen extends StatelessWidget {
  const TtcTreatmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        TtcTreatmentStore.instance,
        TtcLang.instance,
      ]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final store = TtcTreatmentStore.instance;
        if (!store.isLoaded) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: ttcTitleInk)),
          );
        }
        final p = V2PaletteStore.instance.current;
        final round = store.cycle;
        // ⚠️ A ROUND IS A KIND, WITH OR WITHOUT DATES (see the header above).
        // Kept for revert: `round.kind != null && !round.isEmpty`.
        final hasKind = round.kind != null;
        final legacy = round.kind == null && !round.isEmpty;
        final none = round.kind == null && round.isEmpty;
        final now = DateTime.now();
        final phase = ttcTreatmentPhase(round, now);
        final blood = ttcRoundBloodTest(round);
        final canResult =
            hasKind &&
            !round.isEmpty &&
            (phase == TtcRoundPhase.testDay ||
                blood != null && !blood.isAfter(now));
        final next = round.next;

        return TtcToolScaffold(
          hue: kIvfHue,
          // The tool's mark over the eyebrow (2026-09-29, ttc_tool_marks.dart).
          toolId: 'treatment',
          eyebrow: t.treatmentTitle,
          title: 'The dates your\nclinic gave you.',
          intro: hi
              ? t.treatmentIntro
              : "Add the dates your clinic gave you, and we'll remind you "
                    'before the trigger injection. Fill in what you know. '
                    'The rest can wait.',
          children: [
            const SizedBox(height: 22),

            // ---- no round: the way in ---------------------------------------
            if (none) ...[
              ttcToolPad(const TtcStartTreatmentCard()),
              const SizedBox(height: 20),
            ],

            // ---- the round she can still reopen (7 days) --------------------
            if (store.canUndoClose()) ...[
              ttcToolPad(_UndoCloseRow(store: store)),
              const SizedBox(height: 20),
            ],

            // ---- the check-in, when it is due --------------------------------
            if (store.checkInDue()) ...[
              ttcToolPad(
                TtcRoundCheckInCard(
                  onAnswer: () => showTtcCheckInSheet(context),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ---- a legacy round: what kind is it? ----------------------------
            if (legacy) ...[
              ttcToolPad(
                TtcRoundOption(
                  key: const ValueKey('ttc_round_legacy_kind'),
                  title: kTtcRoundLegacyTitle,
                  line: kTtcRoundLegacyBody,
                  icon: Icons.help_outline_rounded,
                  onTap: () => openTtcTreatmentStart(context),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ---- a round: today, then the plan -------------------------------
            if (hasKind) ...[
              ttcToolPad(_TodayCard(round: round, phase: phase)),
              const SizedBox(height: 18),
              if (canResult) ...[
                ttcToolPad(
                  TtcRoundButton(
                    key: const ValueKey('ttc_round_tell_result'),
                    label: kTtcRoundTellResult,
                    onTap: () => openTtcTreatmentResult(context),
                  ),
                ),
                const SizedBox(height: 18),
              ],
              ttcToolPad(_heading(kTtcRoundPlanTitle)),
              const SizedBox(height: 6),
              ttcToolPad(
                Text(
                  kTtcRoundPlanBody,
                  style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2),
                ),
              ),
              const SizedBox(height: 18),
              ttcToolPad(TtcRoundTimeline(round: round)),
              const SizedBox(height: 6),
              // Daily injections live in the medication schedule (decision
              // 4), which already has times and a taken tick.
              ttcToolPad(
                TtcRoundInfoRow(
                  key: const ValueKey('ttc_round_medication_link'),
                  icon: Icons.medication_outlined,
                  text: kTtcRoundMedicationLink,
                  onTap: () => openTtcSurface(context, 'ttc_medication'),
                ),
              ),
              const SizedBox(height: 22),
              if (!round.isEmpty) ...[
                ttcToolPad(
                  TtcRoundButton(
                    key: const ValueKey('ttc_round_plan_changed'),
                    label: kTtcRoundPlanChanged,
                    primary: false,
                    onTap: () => showTtcPlanChangedSheet(context),
                  ),
                ),
                const SizedBox(height: 8),
                ttcToolPad(
                  TtcRoundButton(
                    key: const ValueKey('ttc_round_pause'),
                    label: kTtcRoundTakeBreak,
                    primary: false,
                    onTap: () =>
                        ttcConfirmCloseRound(context, TtcRoundOutcome.paused),
                  ),
                ),
              ] else
                // A round with no dates has nothing to pause or close; the
                // one thing worth changing is the kind (confirmed, undoable).
                ttcToolPad(
                  TtcRoundButton(
                    key: const ValueKey('ttc_round_change_kind'),
                    label: kTtcPlanWrongKind,
                    primary: false,
                    onTap: () => ttcPickRoundKind(context),
                  ),
                ),
              const SizedBox(height: 20),
            ],

            // ---- a legacy round: its next date, then its rows ------------------
            if (legacy && next != null) ...[
              ttcToolPad(_LegacyNextCard(step: next.$1, at: next.$2, t: t)),
              const SizedBox(height: 20),
            ],
            if (legacy) ...[
              ttcToolPad(_heading(t.treatmentDates)),
              const SizedBox(height: 12),
              for (final step in TtcTreatmentScreenClassic._legacySteps(
                round,
              )) ...[
                ttcToolPad(_LegacyRow(step: step, at: round[step], t: t)),
                const SizedBox(height: 10),
              ],
            ],

            if (round[TtcTreatmentStep.trigger] != null) ...[
              const SizedBox(height: 4),
              ttcToolPad(
                TtcRoundInfoRow(
                  icon: Icons.notifications_active_outlined,
                  text: t.treatmentTriggerReminder,
                ),
              ),
            ],

            // "Remove these dates": for a round entered by mistake. Ending a
            // round is closing it (kept in history); this is the one action
            // that removes dates, so it says so before it does.
            if (store.hasDates) ...[
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  key: const ValueKey('ttc_round_remove'),
                  onPressed: () async {
                    // The round's own confirm (2026-09-27). Kept for revert:
                    // `TtcTreatmentScreenClassic._confirmClear(context, t)`.
                    if (await ttcRoundConfirm(
                      context,
                      title: '$kTtcRoundRemove?',
                      body: kTtcRoundRemoveBody,
                      yes: kTtcRoundRemove,
                      // Kept for revert (2026-09-28): 'Keep them'
                      no: 'Keep the dates',
                      route: 'ttc/treatment/confirm_remove',
                    )) {
                      store.clearCycle();
                    }
                  },
                  child: Text(
                    kTtcRoundRemove,
                    style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: p.ink3,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],

            // ---- past rounds: kept, never deleted, and open to look back at -
            if (store.history.isNotEmpty) ...[
              const SizedBox(height: 18),
              ttcToolPad(_heading(kTtcRoundPastTitle)),
              const SizedBox(height: 4),
              ttcToolPad(
                Text(
                  '$kTtcRoundHistoryNote Tap one to see its dates.',
                  style: pvManrope(fontSize: 12.5, color: p.ink3),
                ),
              ),
              const SizedBox(height: 10),
              for (var i = store.history.length - 1; i >= 0; i--) ...[
                ttcToolPad(_PastRow(n: i + 1, round: store.history[i])),
                const SizedBox(height: 8),
              ],
            ],

            const SizedBox(height: 16),
            ttcToolPad(
              Text(
                t.treatmentDisclaimer,
                style: pvManrope(fontSize: 11.5, height: 1.5, color: p.ink3),
              ),
            ),
            const SizedBox(height: 26),
          ],
        );
      },
    );
  }
}

/// What today is in the round: the phase and its day, what is on today,
/// the next date and how far off it is, and the clinic.
class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.round, required this.phase});

  final TtcTreatmentCycle round;
  final TtcRoundPhase phase;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final kind = round.kind;
    DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);

    final count = ttcRoundDayCount(round, phase, today);
    final title = round.isEmpty
        ? kTtcPanelNoDatesTitle
        : count == null || count.$1 <= 0
        ? ttcRoundPhaseName(phase, kind)
        : '${ttcRoundPhaseName(phase, kind)} · day ${count.$1}';

    // What is on today, named.
    final todays = <String>[
      for (final e in round.dates.entries)
        if (day(e.value) == today)
          e.key.needsTime
              ? '${ttcStepLabel(e.key, kind)} at ${ttcRoundTime(e.value)}'
              : ttcStepLabel(e.key, kind),
      if (round.scans.any((s) => day(s) == today)) ttcScanLabel(kind),
    ];

    final first = ttcFirstTreatmentDate(round);
    final next = ttcRoundNextAfter(round, today);
    String? nextLine;
    if (round.isEmpty) {
      nextLine = kTtcPanelNoDatesLine;
    } else if (phase == TtcRoundPhase.planned && first != null) {
      nextLine = 'Your home follows your round from ${ttcRoundDate(first)}.';
    } else if (next != null) {
      final name = next.$1 == null
          ? ttcScanLabel(kind)
          : ttcStepLabel(next.$1!, kind);
      final gap = day(next.$2).difference(today).inDays;
      final when = gap == 1 ? 'tomorrow' : 'in $gap days';
      final at = next.$1?.needsTime == true
          ? '${ttcRoundDate(next.$2)} at ${ttcRoundTime(next.$2)}'
          : ttcRoundDate(next.$2);
      nextLine = 'Next: $name, $at ($when).';
    } else {
      nextLine = kTtcPanelNoNext;
    }

    return Container(
      key: const ValueKey('ttc_round_header'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ttcLine, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ttcRoundKindName(kind!).toUpperCase(),
            style: pvManrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: p.ink3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: pvFraunces(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: p.ink1,
            ),
          ),
          if (todays.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Today: ${todays.join(', ')}.',
              key: const ValueKey('ttc_round_today_line'),
              style: pvManrope(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.4,
                color: p.ink1,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            nextLine,
            key: const ValueKey('ttc_round_next_line'),
            style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2),
          ),
          const SizedBox(height: 10),
          Divider(color: p.line, height: 1),
          Row(
            children: [
              Icon(Icons.local_hospital_outlined, size: 16, color: p.ink3),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  round.clinic.isEmpty ? 'No clinic added' : round.clinic,
                  style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: round.clinic.isEmpty ? p.ink3 : p.ink1,
                  ),
                ),
              ),
              TextButton(
                key: const ValueKey('ttc_round_clinic'),
                onPressed: () => showTtcClinicSheet(context),
                // Kept for revert (2026-09-28): 'Change'
                child: Text(
                  round.clinic.isEmpty ? 'Add clinic' : 'Change clinic',
                  style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: ttcTitleInk,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A round closed in the last 7 days, and the way to reopen it exactly.
class _UndoCloseRow extends StatelessWidget {
  const _UndoCloseRow({required this.store});
  final TtcTreatmentStore store;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final last = store.lastClosed!;
    return Container(
      key: const ValueKey('ttc_round_undo_card'),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ttcLine, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kTtcUndoCardLine,
                  style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: p.ink1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${ttcRoundHistoryLabel(store.history.length, last)} · '
                  '${ttcRoundOutcomeLabel(last.outcome)}',
                  style: pvManrope(fontSize: 12, height: 1.4, color: p.ink2),
                ),
              ],
            ),
          ),
          TextButton(
            key: const ValueKey('ttc_round_undo'),
            onPressed: store.undoClose,
            child: Text(
              kTtcRoundUndoCta,
              style: pvManrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: ttcTitleInk,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One closed round. A tap opens its dates.
class _PastRow extends StatelessWidget {
  const _PastRow({required this.n, required this.round});
  final int n;
  final TtcTreatmentCycle round;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    void open() => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TtcPastRoundScreen(n: n, round: round),
        settings: const RouteSettings(name: 'ttc/treatment/past'),
      ),
    );
    final label = ttcRoundHistoryLabel(n, round);
    final line = [
      if (round.kind != null) ttcRoundKindName(round.kind!),
      ttcRoundOutcomeLabel(round.outcome),
      '${round.allDates.length} dates',
    ].join(' · ');
    return Semantics(
      button: true,
      label: '$label. $line',
      excludeSemantics: true,
      onTap: open,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ttcLine, width: 1.2),
        ),
        child: InkWell(
          key: ValueKey('ttc_round_past_$n'),
          borderRadius: BorderRadius.circular(16),
          onTap: open,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
            child: Row(
              children: [
                Icon(Icons.history_rounded, size: 18, color: p.ink3),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: pvManrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: p.ink1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        line,
                        style: pvManrope(
                          fontSize: 12,
                          height: 1.4,
                          color: p.ink2,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 18, color: p.ink3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A closed round's dates, to look back at. Nothing here edits it: a round
/// in history is a record.
class TtcPastRoundScreen extends StatelessWidget {
  const TtcPastRoundScreen({super.key, required this.n, required this.round});

  final int n;
  final TtcTreatmentCycle round;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final closed = round.closedOn;
    final parts = [
      if (round.kind != null) ttcRoundKindName(round.kind!),
      ttcRoundOutcomeLabel(round.outcome),
      if (closed != null) 'Closed ${ttcRoundDate(closed)}',
    ];
    return TtcToolScaffold(
      hue: kIvfHue,
      variant: 3,
      // One past round, opened from the plan: back, not an X (2026-09-29).
      leading: TtcToolLeading.back,
      eyebrow: kTtcRoundPastTitle,
      title: ttcRoundHistoryLabel(n, round),
      intro:
          '${parts.join(' · ')}. Kept as a record: nothing here can be '
          'changed.',
      children: [
        const SizedBox(height: 22),
        if (round.clinic.isNotEmpty) ...[
          ttcToolPad(
            Text(
              round.clinic,
              style: pvManrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: p.ink1,
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (round.isEmpty)
          ttcToolPad(
            Text(
              'This round had no dates.',
              style: pvManrope(fontSize: 13.5, color: p.ink2),
            ),
          )
        else
          ttcToolPad(TtcRoundTimeline(round: round, readOnly: true)),
        const SizedBox(height: 28),
      ],
    );
  }
}

/// A legacy round's next date, as a white card (it was a solid violet one).
class _LegacyNextCard extends StatelessWidget {
  const _LegacyNextCard({
    required this.step,
    required this.at,
    required this.t,
  });

  final TtcTreatmentStep step;
  final DateTime at;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final hi = t.hinglish;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ttcLine, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.treatmentNext.toUpperCase(),
            style: pvManrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: p.ink3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _StepRow._label(step, hi),
            style: pvFraunces(
              fontSize: 23,
              fontWeight: FontWeight.w600,
              color: p.ink1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${TtcTreatmentScreenClassic._when(step, at, hi)} · '
            '${TtcTreatmentScreenClassic._daysAway(at, hi)}',
            style: pvManrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: p.ink1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.note(hi),
            style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2),
          ),
        ],
      ),
    );
  }
}

/// A legacy round's date row, in the round's own row.
class _LegacyRow extends StatelessWidget {
  const _LegacyRow({required this.step, required this.at, required this.t});

  final TtcTreatmentStep step;
  final DateTime? at;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final label = _StepRow._label(step, hi);
    final store = TtcTreatmentStore.instance;
    return TtcRoundDateRow(
      label: label,
      line: step.note(hi),
      value: at,
      withTime: step.needsTime,
      clearKey: ValueKey('ttc_legacy_clear_${step.name}'),
      below: step == TtcTreatmentStep.trigger && at != null
          ? TtcRoundTakenTick(taken: store.cycle.triggerTaken)
          : null,
      onTap: () async {
        final picked = await ttcPickRoundDate(
          context,
          round: store.cycle,
          step: step,
          help: label,
        );
        if (picked == null || !context.mounted) return;
        store.setDate(step, picked);
      },
      onClear: () {
        final was = at;
        final taken = store.cycle.triggerTaken;
        store.setDate(step, null);
        ttcRoundDateRemoved(context, label, () {
          store.setDate(step, was);
          if (step == TtcTreatmentStep.trigger && taken) {
            store.setTriggerTaken(true);
          }
        });
      },
    );
  }
}
