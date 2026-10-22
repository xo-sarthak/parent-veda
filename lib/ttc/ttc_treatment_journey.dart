// =============================================================================
//  ttc_treatment_journey.dart - IUI, IVF and a frozen transfer, step by step
// =============================================================================
//
// The user (2026-10-22): "it's very essential for us to make sure that the
// user understands what it is ... what happens at each step", and "vids
// should be first thing user sees". This is the IVF door's first tab: one
// card per step, the video on top, then what happens, how long, whether it
// hurts and one thing to ask the clinic.
//
// ⚠️ THE STEPS COVER THE TRACKER'S ROWS. Each step names the round rows it
// stands for (`ttcRoundRows` in ttc_treatment_round.dart), and
// `test/ttc_treatment_journey_test.dart` fails if a row the tracker asks about
// has no step here. So the journey and the round she logs cannot drift apart.
// A step may cover two rows (the pill and down-regulation are one "getting
// ready"), and one step has no row at all (the lab's days: nothing for her to
// date).
//
// ⚠️ EXPLAIN, REMIND, PREPARE (CLAUDE.md, clinical ownership). No dose, no
// date and no step is given as hers; every timing is "usually" or "your
// clinic gives the day". Nothing here is a chance, and
// `test/ttc_clinical_review_test.dart` scans this file with the rest of
// lib/ttc. English only (new work is English). The facts are the ones the
// treatment reads already state; a doctor reviews them before launch
// (BEFORE-LAUNCH §8).
// =============================================================================

import 'ttc_treatment_round.dart' show TtcRoundPhase;
import 'ttc_treatment_store.dart' show TtcRoundKind, TtcTreatmentStep;

/// The three journeys the switch offers.
enum TtcJourneyKind { iui, ivf, frozen }

extension TtcJourneyKindX on TtcJourneyKind {
  String get label => switch (this) {
        TtcJourneyKind.iui => 'IUI',
        TtcJourneyKind.ivf => 'IVF',
        TtcJourneyKind.frozen => 'Frozen transfer',
      };

  /// The round kind whose tracker rows this journey must cover.
  TtcRoundKind get roundKind => switch (this) {
        TtcJourneyKind.iui => TtcRoundKind.iui,
        TtcJourneyKind.ivf => TtcRoundKind.ivfFresh,
        TtcJourneyKind.frozen => TtcRoundKind.fetMedicated,
      };
}

/// The journey a round of [kind] follows. Tablets alone follow IUI's shape
/// (the same scans and trigger, without the procedure); IVF otherwise.
TtcJourneyKind ttcJourneyKindFor(TtcRoundKind? kind) => switch (kind) {
      TtcRoundKind.iui || TtcRoundKind.ovulationInduction => TtcJourneyKind.iui,
      TtcRoundKind.fetMedicated ||
      TtcRoundKind.fetNatural =>
        TtcJourneyKind.frozen,
      _ => TtcJourneyKind.ivf,
    };

class TtcJourneyStep {
  const TtcJourneyStep({
    required this.key,
    required this.title,
    required this.what,
    required this.howLong,
    required this.hurts,
    required this.ask,
    required this.readId,
    required this.videoSlotId,
    required this.videoMinutes,
    this.steps = const {},
    this.scans = false,
    this.phases = const {},
    this.someClinics = false,
  });

  /// Stable id, for keys and tests.
  final String key;
  final String title;
  final String what;
  final String howLong;
  final String hurts;
  final String ask;

  /// The read "Read more" opens. Must resolve (`ttcReadById`).
  final String readId;

  /// The step's video (`kTtcVideos`). Must resolve.
  final String videoSlotId;
  final int videoMinutes;

  /// The tracker rows this step stands for.
  final Set<TtcTreatmentStep> steps;
  final bool scans;

  /// The round phases during which this is "You are here".
  final Set<TtcRoundPhase> phases;

  /// Not every clinic does this step.
  final bool someClinics;
}

// ---- steps shared by more than one journey ---------------------------------

const _trigger = TtcJourneyStep(
  key: 'trigger',
  title: 'The trigger injection',
  what: 'One injection matures the egg and times its release. Everything '
      'after it is counted from the hour you take it.',
  howLong: 'One injection, at an exact time your clinic gives',
  hurts: 'A small pinch under the skin.',
  ask: 'What time exactly, and what do I do if I am late?',
  readId: 'ttc_read_tx_trigger_shot',
  videoSlotId: 'ttc_vid_step_trigger',
  videoMinutes: 1,
  steps: {TtcTreatmentStep.trigger},
  phases: {TtcRoundPhase.trigger},
);

const _review = TtcJourneyStep(
  key: 'review',
  title: 'Your review',
  what: 'Whatever the result, a visit with your doctor looks back at the '
      'round and plans what comes next.',
  howLong: 'One visit',
  hurts: 'No.',
  ask: 'What would we change next time?',
  readId: 'ttc_read_tx_review_appointment',
  videoSlotId: 'ttc_vid_step_review',
  videoMinutes: 1,
  steps: {TtcTreatmentStep.reviewAppointment},
  phases: {TtcRoundPhase.betweenRounds, TtcRoundPhase.result},
);

const Map<TtcJourneyKind, List<TtcJourneyStep>> kTtcJourney = {
  TtcJourneyKind.iui: [
    TtcJourneyStep(
      key: 'iui_medicine',
      title: 'Medicine to grow an egg',
      what: 'Most IUI rounds use a tablet, such as letrozole, or small '
          'injections, so that one or two eggs grow.',
      howLong: 'About 5 days of tablets, or around 8 to 12 days of injections',
      hurts: 'Tablets, no. An injection is a small pinch under the skin.',
      ask: 'Which medicine, and from which day of my period?',
      readId: 'ttc_read_ovulation_tablets',
      videoSlotId: 'ttc_vid_step_iui_medicine',
      videoMinutes: 1,
      steps: {TtcTreatmentStep.stimStart},
      phases: {TtcRoundPhase.planned, TtcRoundPhase.stimulation},
    ),
    TtcJourneyStep(
      key: 'iui_scans',
      title: 'Follicle scans',
      what: 'An internal ultrasound shows how the eggs are growing, so the '
          'clinic knows when to time the next step.',
      howLong: 'Usually 2 to 3 scans, about 10 minutes each',
      hurts: 'Some pressure, not usually painful.',
      ask: 'What size are we waiting for?',
      readId: 'ttc_read_tx_monitoring_scans',
      videoSlotId: 'ttc_vid_step_scans',
      videoMinutes: 1,
      scans: true,
    ),
    _trigger,
    TtcJourneyStep(
      key: 'iui_day',
      title: 'IUI day',
      what: "His sample is washed in the lab, then placed in your uterus "
          'through a thin, soft tube.',
      howLong: 'He gives the sample an hour or two before. The IUI itself '
          'takes about 5 minutes.',
      hurts: 'It feels like a smear test. Some cramping is common.',
      ask: 'Can we go about our day afterwards?',
      readId: 'ttc_read_tx_iui_day',
      videoSlotId: 'ttc_vid_step_iui_day',
      videoMinutes: 2,
      steps: {TtcTreatmentStep.iui},
      phases: {TtcRoundPhase.procedure},
    ),
    TtcJourneyStep(
      key: 'iui_progesterone',
      title: 'Progesterone support',
      what: 'Some clinics give progesterone to support the lining of your '
          'uterus after the IUI.',
      howLong: 'Daily, until your test day',
      hurts: 'No. Pessaries can be messy, which is normal.',
      ask: 'Do I need it, and until when?',
      readId: 'ttc_read_tx_wait_after_treatment',
      videoSlotId: 'ttc_vid_step_progesterone',
      videoMinutes: 1,
      steps: {TtcTreatmentStep.progesteroneStart},
      phases: {TtcRoundPhase.waiting},
      someClinics: true,
    ),
    TtcJourneyStep(
      key: 'iui_test',
      title: 'The wait and the blood test',
      what: 'A blood test for the pregnancy hormone, beta hCG, gives the '
          'answer.',
      howLong: 'Usually about 14 days after the IUI. Your clinic gives the '
          'day.',
      hurts: 'A normal blood test.',
      ask: 'Who calls me with the result, and when?',
      readId: 'ttc_read_tx_beta_test',
      videoSlotId: 'ttc_vid_step_beta',
      videoMinutes: 1,
      steps: {TtcTreatmentStep.betaTest},
      phases: {TtcRoundPhase.testDay},
    ),
    _review,
  ],
  TtcJourneyKind.ivf: [
    TtcJourneyStep(
      key: 'ivf_ready',
      title: 'Getting ready',
      what: 'Some clinics start with a pill or an injection that quietens '
          'your cycle, so the eggs can grow together.',
      howLong: 'A few days to about 3 weeks, if your clinic uses it',
      hurts: 'No.',
      ask: 'Which protocol am I on, and why?',
      readId: 'ttc_read_ivf_explained',
      videoSlotId: 'ttc_vid_step_ivf_ready',
      videoMinutes: 1,
      steps: {TtcTreatmentStep.pillStart, TtcTreatmentStep.downRegStart},
      phases: {TtcRoundPhase.planned, TtcRoundPhase.gettingReady},
      someClinics: true,
    ),
    TtcJourneyStep(
      key: 'ivf_baseline',
      title: 'The baseline scan',
      what: 'A scan near the start of your period checks your ovaries '
          'before the injections begin.',
      howLong: 'One scan, about 10 minutes',
      hurts: 'Some pressure, not usually painful.',
      ask: 'When do I start the injections?',
      readId: 'ttc_read_tx_baseline_scan',
      videoSlotId: 'ttc_vid_step_baseline',
      videoMinutes: 1,
      steps: {TtcTreatmentStep.baselineScan},
    ),
    TtcJourneyStep(
      key: 'ivf_injections',
      title: 'Stimulation injections',
      what: 'Daily hormone injections help several eggs grow at once. Most '
          'women learn to give them at home.',
      howLong: 'Usually 8 to 12 days',
      hurts: 'A small pinch. Some bloating near the end is common.',
      ask: 'Which pen, which dose, and at what time of day?',
      readId: 'ttc_read_ivf_injections',
      videoSlotId: 'ttc_vid_step_ivf_injections',
      videoMinutes: 2,
      steps: {TtcTreatmentStep.stimStart},
      phases: {TtcRoundPhase.stimulation},
    ),
    TtcJourneyStep(
      key: 'ivf_scans',
      title: 'Monitoring scans',
      what: 'Scans, and sometimes blood tests, show how the eggs are growing. '
          'Your dose may change after one.',
      howLong: 'Every 2 to 3 days, often early in the morning',
      hurts: 'Some pressure, not usually painful.',
      ask: 'Who tells me if my dose changes?',
      readId: 'ttc_read_tx_monitoring_scans',
      videoSlotId: 'ttc_vid_step_scans',
      videoMinutes: 1,
      scans: true,
    ),
    _trigger,
    TtcJourneyStep(
      key: 'ivf_collection',
      title: 'Egg collection',
      what: 'While you are sedated, a thin needle guided by ultrasound '
          'collects the eggs.',
      howLong: 'About 20 to 30 minutes, then a few hours to rest. Take the '
          'day off.',
      hurts: 'You sleep through it. Cramping afterwards is common.',
      ask: 'Who can take me home, and when can I eat?',
      readId: 'ttc_read_ivf_retrieval',
      videoSlotId: 'ttc_vid_step_collection',
      videoMinutes: 2,
      steps: {TtcTreatmentStep.retrieval},
      phases: {TtcRoundPhase.procedure},
    ),
    TtcJourneyStep(
      key: 'ivf_lab',
      title: 'The lab, and the phone calls',
      what: 'The eggs meet the sperm in the lab. The clinic calls to tell you '
          'how the embryos are growing.',
      howLong: 'Up to 5 or 6 days',
      hurts: 'Nothing to do but wait for the calls.',
      ask: 'Will you call me, or should I call you?',
      readId: 'ttc_read_tx_embryo_days',
      videoSlotId: 'ttc_vid_step_lab',
      videoMinutes: 2,
      phases: {TtcRoundPhase.embryoDays},
    ),
    TtcJourneyStep(
      key: 'ivf_progesterone',
      title: 'Progesterone support',
      what: 'Progesterone prepares and supports the lining of your uterus '
          'for the embryo.',
      howLong: 'Daily, from around collection, until the test and often '
          'longer',
      hurts: 'Injections can be sore. Pessaries can be messy.',
      ask: 'Exactly when do I stop?',
      readId: 'ttc_read_tx_transfer_day',
      videoSlotId: 'ttc_vid_step_progesterone',
      videoMinutes: 1,
      steps: {TtcTreatmentStep.progesteroneStart},
    ),
    TtcJourneyStep(
      key: 'ivf_transfer',
      title: 'Embryo transfer',
      what: 'A thin tube places the embryo in your uterus. Other good '
          'embryos may be frozen for later.',
      howLong: 'About 5 to 10 minutes, with no anaesthetic',
      hurts: 'It feels like a smear test. A full bladder is often asked for.',
      ask: 'Fresh or frozen for me, and why?',
      readId: 'ttc_read_tx_fresh_or_frozen',
      videoSlotId: 'ttc_vid_step_transfer',
      videoMinutes: 2,
      steps: {TtcTreatmentStep.transfer},
      phases: {TtcRoundPhase.transfer},
    ),
    TtcJourneyStep(
      key: 'ivf_test',
      title: 'The wait and the blood test',
      what: 'A blood test for beta hCG gives the answer. A home test can '
          'mislead after a trigger injection.',
      howLong: 'Usually about 9 to 14 days after transfer. Your clinic '
          'gives the day.',
      hurts: 'A normal blood test.',
      ask: 'Who calls me with the result?',
      readId: 'ttc_read_tx_beta_test',
      videoSlotId: 'ttc_vid_step_beta',
      videoMinutes: 1,
      steps: {TtcTreatmentStep.betaTest, TtcTreatmentStep.repeatBeta},
      phases: {TtcRoundPhase.waiting, TtcRoundPhase.testDay},
    ),
    _review,
  ],
  TtcJourneyKind.frozen: [
    TtcJourneyStep(
      key: 'fet_lining',
      title: 'Building the lining',
      what: 'Estrogen tablets or patches thicken the lining of your uterus. '
          'A natural frozen transfer uses your own cycle instead.',
      howLong: 'Usually about 10 to 14 days',
      hurts: 'No.',
      ask: 'A medicated or a natural cycle for me?',
      readId: 'ttc_read_tx_frozen_transfer',
      videoSlotId: 'ttc_vid_step_fet_lining',
      videoMinutes: 1,
      steps: {TtcTreatmentStep.estrogenStart},
      phases: {
        TtcRoundPhase.planned,
        TtcRoundPhase.gettingReady,
        TtcRoundPhase.stimulation,
      },
    ),
    TtcJourneyStep(
      key: 'fet_scans',
      title: 'Lining scans',
      what: 'Scans check that the lining is thick enough before the transfer '
          'is planned.',
      howLong: 'Usually 1 to 3 scans',
      hurts: 'Some pressure, not usually painful.',
      ask: 'What thickness are we waiting for?',
      readId: 'ttc_read_tx_frozen_transfer',
      videoSlotId: 'ttc_vid_step_fet_scans',
      videoMinutes: 1,
      scans: true,
    ),
    TtcJourneyStep(
      key: 'fet_progesterone',
      title: 'Progesterone starts',
      what: "Progesterone starts a set number of days before the transfer, "
          "matched to the embryo's age.",
      howLong: 'Daily, from a few days before the transfer',
      hurts: 'Injections can be sore. Pessaries can be messy.',
      ask: 'Which day do I start, and at what time?',
      readId: 'ttc_read_tx_transfer_day',
      videoSlotId: 'ttc_vid_step_progesterone',
      videoMinutes: 1,
      steps: {TtcTreatmentStep.progesteroneStart},
      phases: {TtcRoundPhase.trigger},
    ),
    TtcJourneyStep(
      key: 'fet_transfer',
      title: 'Thaw and transfer',
      what: 'The embryo is thawed in the lab the same day, then placed in '
          'your uterus through a thin tube.',
      howLong: 'About 5 to 10 minutes, with no anaesthetic',
      hurts: 'It feels like a smear test.',
      ask: 'Will you tell me how the thaw went?',
      readId: 'ttc_read_tx_frozen_transfer',
      videoSlotId: 'ttc_vid_step_fet_transfer',
      videoMinutes: 2,
      steps: {TtcTreatmentStep.transfer},
      phases: {TtcRoundPhase.transfer, TtcRoundPhase.procedure},
    ),
    TtcJourneyStep(
      key: 'fet_test',
      title: 'The wait and the blood test',
      what: 'A blood test for beta hCG gives the answer, often with a second '
          'test a few days later.',
      howLong: 'Usually about 9 to 14 days after transfer. Your clinic '
          'gives the day.',
      hurts: 'A normal blood test.',
      ask: 'Who calls me with the result?',
      readId: 'ttc_read_tx_beta_test',
      videoSlotId: 'ttc_vid_step_beta',
      videoMinutes: 1,
      steps: {TtcTreatmentStep.betaTest, TtcTreatmentStep.repeatBeta},
      phases: {TtcRoundPhase.waiting, TtcRoundPhase.testDay},
    ),
    _review,
  ],
};

/// Which step of [kind] is "You are here" during [phase], or null. The first
/// step that claims the phase wins, so a phase two steps share lands on the
/// earlier one.
int? ttcJourneyHere(TtcJourneyKind kind, TtcRoundPhase? phase) {
  if (phase == null) return null;
  final steps = kTtcJourney[kind]!;
  for (var i = 0; i < steps.length; i++) {
    if (steps[i].phases.contains(phase)) return i;
  }
  return null;
}
