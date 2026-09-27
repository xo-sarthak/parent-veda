// =============================================================================
//  What the home offers while a treatment round runs: reads and daily cards
// -----------------------------------------------------------------------------
//  Added 2026-09-26 for docs/TTC-TREATMENT-FLOW.md §3b (B4). While a round is
//  running, the home's content follows the round's STEP (`ttcTreatmentPhase`)
//  instead of the natural cycle's phase, which a clinic cycle does not have.
//  The same shape as `ttc_phase_reads.dart` and `ttcInsightsForPhase`: a table
//  in code a reviewer can read top to bottom, and a picker that rotates by
//  date only inside the step's own set.
//
//  ⚠️ THE TWELVE GAP READS FIRST. §3b lists twelve gaps (G1 to G12), all
//  written into `lib/ttc/reads/ttc_reads_treatment.dart` as `ttc_read_tx_*`
//  and wired below (2026-09-26). They sit at the front of their step's list;
//  the picker still skips an id that does not resolve (the same rule
//  `ttcReadIdsForPhase` has), so a read withdrawn later breaks nothing.
//
//  ⚠️ THE DAILY CARDS EXPLAIN, REMIND AND HELP HER PREPARE (CLAUDE.md,
//  clinical ownership). None gives a date, a dose or a step as hers; none
//  reads a result; none says how likely anything is. Facts are the flow
//  doc's §1 only, and the ones marked "(confirm)" there are left out. Written
//  to docs/TTC-VOICE.md: "you", contractions, short sentences, no dashes.
//  English only: the Hindi fields repeat the English (new work is English).
// =============================================================================

import 'ttc_daily_data.dart' show TtcInsight, ttcDayIndex;
import 'ttc_reads_data.dart' show ttcReadById;
import 'ttc_treatment_round.dart';
import 'ttc_treatment_store.dart' show TtcRoundKind;

/// The reads that fit each step of a round, best first.
///
/// ⚠️ ALL TWELVE GAPS ARE WIRED (2026-09-26). G1 to G12 now exist in
/// `lib/ttc/reads/ttc_reads_treatment.dart` and sit at the front of the step
/// §3b gives each: G1 baseline scan and G2 frozen transfer (planned, getting
/// ready), G3 monitoring scans (stimulation), G4 trigger, G5 IUI day
/// (procedure), G6 embryo days and G7 fresh or frozen (embryo days), G8
/// transfer, G9 the wait, G10 the blood test, G11 a negative test and G12
/// the review (between rounds). A read written for some kinds of round only
/// is filtered by [_kReadKinds], so an IUI never leads with egg collection.
const Map<TtcRoundPhase, List<String>> kTtcTreatmentPhaseReadIds = {
  TtcRoundPhase.planned: [
    'ttc_read_tx_baseline_scan', // G1
    'ttc_read_tx_frozen_transfer', // G2
    'ttc_read_ivf_explained',
    'ttc_read_ivf_workup',
    'ttc_read_clinic_glossary',
    'ttc_read_ivf_working',
    'ttc_read_ivf_costs',
    'ttc_read_ivf_package',
  ],
  TtcRoundPhase.gettingReady: [
    'ttc_read_tx_baseline_scan', // G1
    'ttc_read_tx_frozen_transfer', // G2
    'ttc_read_ivf_explained',
    'ttc_read_clinic_glossary',
    'ttc_read_ivf_working',
    'ttc_read_ivf_workup',
    'ttc_read_ivf_costs',
    'ttc_read_ivf_package',
  ],
  TtcRoundPhase.stimulation: [
    'ttc_read_tx_monitoring_scans', // G3
    'ttc_read_ivf_injections',
    'ttc_read_follicle_scans',
    'ttc_read_ovulation_tablets',
    'ttc_read_ivf_ohss',
    'ttc_read_pcos_meds',
  ],
  TtcRoundPhase.trigger: [
    'ttc_read_tx_trigger_shot', // G4
    'ttc_read_ivf_injections',
    'ttc_read_ivf_retrieval',
    'ttc_read_tx_iui_day', // G5, for an IUI the day after the trigger
    'ttc_read_ivf_ohss',
  ],
  TtcRoundPhase.procedure: [
    'ttc_read_tx_iui_day', // G5
    'ttc_read_ivf_retrieval',
    'ttc_read_ivf_ohss',
    'ttc_read_semen_analysis',
  ],
  TtcRoundPhase.embryoDays: [
    'ttc_read_tx_embryo_days', // G6
    'ttc_read_tx_fresh_or_frozen', // G7
    'ttc_read_ivf_icsi',
    'ttc_read_clinic_glossary',
    'ttc_read_ivf_ohss',
  ],
  TtcRoundPhase.transfer: [
    'ttc_read_tx_transfer_day', // G8
    'ttc_read_ivf_working',
    'ttc_read_stress_fertility',
  ],
  TtcRoundPhase.waiting: [
    'ttc_read_tx_wait_after_treatment', // G9
    'ttc_read_when_to_test',
    'ttc_read_faint_line',
    'ttc_read_implantation_bleeding',
    'ttc_read_early_signs',
    'ttc_read_stress_fertility',
    'ttc_read_ivf_working',
  ],
  TtcRoundPhase.testDay: [
    'ttc_read_tx_beta_test', // G10
    'ttc_read_when_to_test',
    'ttc_read_faint_line',
  ],
  TtcRoundPhase.result: [
    'ttc_read_tx_beta_test',
    'ttc_read_good_news_answers',
    'ttc_read_ivf_working',
  ],
  TtcRoundPhase.betweenRounds: [
    'ttc_read_tx_negative_after_treatment', // G11
    'ttc_read_tx_review_appointment', // G12
    'ttc_read_period_came',
    'ttc_read_month_after_month',
    'ttc_read_chemical_pregnancy',
    'ttc_read_others_news',
    'ttc_read_good_news_answers',
    'ttc_read_trying_again',
  ],
};

/// Reads written for some kinds of round only. Every other read fits any.
const Map<String, Set<TtcRoundKind>> _kReadKinds = {
  'ttc_read_tx_baseline_scan': {
    TtcRoundKind.ivfFresh,
    TtcRoundKind.ivfFreezeAll,
    TtcRoundKind.notSure,
  },
  'ttc_read_tx_frozen_transfer': {
    TtcRoundKind.fetMedicated,
    TtcRoundKind.fetNatural,
  },
  'ttc_read_tx_monitoring_scans': {
    TtcRoundKind.ivfFresh,
    TtcRoundKind.ivfFreezeAll,
    TtcRoundKind.notSure,
  },
  'ttc_read_tx_iui_day': {TtcRoundKind.iui},
  'ttc_read_ivf_retrieval': {
    TtcRoundKind.ivfFresh,
    TtcRoundKind.ivfFreezeAll,
    TtcRoundKind.notSure,
  },
  'ttc_read_tx_embryo_days': {
    TtcRoundKind.ivfFresh,
    TtcRoundKind.ivfFreezeAll,
    TtcRoundKind.notSure,
  },
  'ttc_read_tx_fresh_or_frozen': {
    TtcRoundKind.ivfFresh,
    TtcRoundKind.ivfFreezeAll,
    TtcRoundKind.notSure,
  },
};

/// The gaps §3b names that have no read yet. EMPTY since 2026-09-26: all
/// twelve exist and are in the table above. Kept as the place a new gap is
/// listed the day one is found. Kept for revert, the list before:
///   'G1': 'Your first treatment visit: the baseline scan',
///   'G2': 'Frozen embryo transfer, step by step',
///   'G3': "Monitoring scans during IVF: what they're checking",
///   'G5': 'IUI day: what happens (and his sample)',
///   'G6': 'Day 1, day 3, day 5: the words the lab uses',
///   'G7': 'Fresh or frozen transfer: how clinics decide',
///   'G12': 'Your review appointment: questions to take',
const Map<String, String> kTtcTreatmentReadsOwed = {};

/// Up to [count] read ids for [phase] on [day]: the step's own reads,
/// rotated by date, skipping any id that does not resolve and any read
/// written for another kind of round ([kind] null is a legacy round, read as
/// IVF).
List<String> ttcTreatmentReadIdsFor(TtcRoundPhase phase, DateTime day,
    {int count = 4, TtcRoundKind? kind}) {
  final k = kind ?? TtcRoundKind.ivfFresh;
  final own = kTtcTreatmentPhaseReadIds[phase] ?? const <String>[];
  final live = [
    for (final id in own)
      if (ttcReadById(id) != null && (_kReadKinds[id]?.contains(k) ?? true)) id,
  ];
  if (live.isEmpty || count <= 0) return const [];
  final start = ttcDayIndex(day);
  final out = <String>[];
  for (var i = 0; i < live.length && out.length < count; i++) {
    out.add(live[(start + i) % live.length]);
  }
  return out;
}

TtcInsight _card(String id, String topic, String title, String body,
        String takeaway) =>
    TtcInsight(
      id: id,
      topic: topic,
      titleEn: title,
      titleHi: title,
      bodyEn: body,
      bodyHi: body,
      takeawayEn: takeaway,
      takeawayHi: takeaway,
    );

/// The daily cards for each step of a round, one to three each.
final Map<TtcRoundPhase, List<TtcInsight>> kTtcTreatmentInsights = {
  TtcRoundPhase.planned: [
    _card(
        'ttc_tx_ins_plan',
        'medical',
        'Before your round starts',
        "It helps to have your clinic's plan in one place: the first scan, "
            'when the tablets or injections start, and who to call with a '
            "question. Add each date here as you get it. We'll follow your "
            'round from the first one.',
        'Ask your clinic for the plan on paper.'),
  ],
  TtcRoundPhase.gettingReady: [
    _card(
        'ttc_tx_ins_baseline',
        'medical',
        'The first scan of a round',
        'Many rounds start with a scan on day 2 or 3 of your period. It '
            'checks that your ovaries are quiet before any medicine starts. '
            'Some clinics do a blood test the same morning.',
        "It's usually quick. Plan the morning if you can."),
    _card(
        'ttc_tx_ins_estrogen',
        'medical',
        'Estrogen tablets and your lining',
        'Before a medicated frozen transfer, estrogen tablets build up the '
            'lining of your womb. A scan or two checks how it is growing, and '
            'your clinic uses that to choose the transfer day.',
        'Take them at the times your clinic gave you.'),
  ],
  TtcRoundPhase.stimulation: [
    _card(
        'ttc_tx_ins_injection_time',
        'medical',
        'The same time each evening',
        'Stimulation injections are usually taken at about the same time each '
            'evening. Pick a time you can keep, and add it to your medication '
            'schedule so we can remind you.',
        'Keep the time you and your clinic agreed.'),
    _card(
        'ttc_tx_ins_monitoring',
        'medical',
        'Why the scans come so often',
        'While you take the injections, your clinic watches your follicles '
            'grow, with a scan every one to three days and sometimes a blood '
            'test. Your dose may change after a scan. That is normal, and it '
            'is their call.',
        'A changed dose is part of the plan.'),
    _card(
        'ttc_tx_ins_tablets',
        'medical',
        'Tablets and follicle scans',
        'Tablets like letrozole help your ovaries ripen an egg. Scans from '
            'around day 9 to 11 show how the follicles are growing, so your '
            'clinic can plan what comes next.',
        'Your clinic uses each scan to plan the next step.'),
  ],
  TtcRoundPhase.trigger: [
    _card(
        'ttc_tx_ins_trigger',
        'medical',
        'Why the trigger time is exact',
        'The trigger injection does the last ripening of the eggs, which takes '
            'about a day and a half. Egg collection is booked 34 to 36 hours '
            "after it. If you're late or unsure, call your clinic straight "
            'away.',
        'Set an alarm for the trigger time.'),
  ],
  TtcRoundPhase.procedure: [
    _card(
        'ttc_tx_ins_collection',
        'medical',
        'On egg collection day',
        'Egg collection takes about 15 to 30 minutes under short sedation. '
            "Your clinic will tell you when to stop eating and drinking. You'll "
            'need someone to take you home, and resting for the day is fine.',
        'Bring someone with you.'),
    _card(
        'ttc_tx_ins_iui',
        'medical',
        'On IUI day',
        'An IUI takes a few minutes and feels a bit like a smear test. His '
            'sample is washed in the lab first, which takes one to two hours. '
            'Most people go about their day after.',
        'Ask your clinic what time his sample is needed.'),
  ],
  TtcRoundPhase.embryoDays: [
    _card(
        'ttc_tx_ins_lab',
        'medical',
        'While the lab works',
        'The day after collection, the lab often calls to say how many eggs '
            'fertilised. Over the next few days the embryos grow in the lab, '
            'and your clinic decides the transfer day, often day 3 or day 5.',
        'Keep your phone close, and write down what they say.'),
    _card(
        'ttc_tx_ins_after_collection',
        'medical',
        'After egg collection',
        'Some cramping and bloating is common for a few days. If you feel very '
            'bloated, pass much less urine, or find it hard to breathe, call '
            'your clinic.',
        'Know the signs that mean you should call.'),
  ],
  TtcRoundPhase.transfer: [
    _card(
        'ttc_tx_ins_transfer',
        'medical',
        'Transfer day',
        "An embryo transfer takes a few minutes and doesn't need sedation. "
            'Some clinics ask you to come with a full bladder. Keep taking '
            'your progesterone exactly as your clinic said.',
        'Check whether your clinic wants a full bladder.'),
  ],
  TtcRoundPhase.waiting: [
    _card(
        'ttc_tx_ins_home_test',
        'medical',
        'Why a home test can mislead now',
        'If you had a trigger injection, it has the same hormone a pregnancy '
            'test looks for, so a home test before your blood test can show a '
            "line that isn't a pregnancy. The blood test on your clinic's date "
            'is the one to trust.',
        'Wait for the blood test if you can.'),
    _card(
        'ttc_tx_ins_keep_meds',
        'medical',
        'Keep taking your medicines',
        'In the wait, keep taking your progesterone and any other medicines '
            'until your clinic tells you to stop. If something worries you, '
            'call them and ask.',
        "Don't stop anything without asking your clinic."),
    _card(
        'ttc_tx_ins_middle',
        'emotional',
        'The middle of the wait',
        'This is often the hardest stretch. Plan something small and gentle '
            "for each day, and tell one person how you're really doing.",
        "You don't have to wait alone."),
  ],
  TtcRoundPhase.testDay: [
    _card(
        'ttc_tx_ins_beta',
        'medical',
        'The blood test',
        'The blood test measures the pregnancy hormone. Some clinics repeat it '
            'about 48 hours later to see how it changes. Your clinic will '
            "explain your result. We won't try to read the number.",
        'Plan something gentle for after.'),
  ],
  TtcRoundPhase.result: [
    _card(
        'ttc_tx_ins_positive',
        'medical',
        'After a positive test',
        'Keep taking all your medicines until your clinic tells you otherwise. '
            'Your clinic will usually book a first scan a few weeks later, and '
            'they will date your pregnancy from your treatment.',
        'Your clinic sets your dates from here.'),
  ],
  TtcRoundPhase.betweenRounds: [
    _card(
        'ttc_tx_ins_after_negative',
        'emotional',
        'After a negative test',
        'Your clinic will tell you when to stop progesterone, and your period '
            'usually comes after that. Nothing about the next step has to be '
            'decided today.',
        'Give yourself a few days first.'),
    _card(
        'ttc_tx_ins_review',
        'medical',
        'Your review appointment',
        'A review is a chance to go through the round with your doctor: what '
            "happened, what they'd change, and when to try again. Write your "
            'questions down before you go.',
        'Take your questions on paper.'),
  ],
};

/// Cards written for some kinds of round only. Every other card fits any.
const Map<String, Set<TtcRoundKind>> _kCardKinds = {
  'ttc_tx_ins_baseline': {
    TtcRoundKind.ivfFresh,
    TtcRoundKind.ivfFreezeAll,
    TtcRoundKind.notSure,
  },
  'ttc_tx_ins_estrogen': {TtcRoundKind.fetMedicated},
  'ttc_tx_ins_injection_time': {
    TtcRoundKind.ivfFresh,
    TtcRoundKind.ivfFreezeAll,
    TtcRoundKind.notSure,
    TtcRoundKind.iui,
  },
  'ttc_tx_ins_monitoring': {
    TtcRoundKind.ivfFresh,
    TtcRoundKind.ivfFreezeAll,
    TtcRoundKind.notSure,
  },
  'ttc_tx_ins_tablets': {
    TtcRoundKind.ovulationInduction,
    TtcRoundKind.iui,
    TtcRoundKind.fetNatural,
  },
  'ttc_tx_ins_collection': {
    TtcRoundKind.ivfFresh,
    TtcRoundKind.ivfFreezeAll,
    TtcRoundKind.notSure,
  },
  'ttc_tx_ins_iui': {TtcRoundKind.iui},
};

/// The daily card for [phase] on [day], rotated by date inside the step's own
/// set, leaving out cards written for another kind of round ([kind] null is
/// a legacy round, read as IVF). Null for a step with no cards.
TtcInsight? ttcTreatmentInsightFor(TtcRoundPhase phase, DateTime day,
    {TtcRoundKind? kind}) {
  final k = kind ?? TtcRoundKind.ivfFresh;
  final set = [
    for (final c in kTtcTreatmentInsights[phase] ?? const <TtcInsight>[])
      if (_kCardKinds[c.id]?.contains(k) ?? true) c,
  ];
  if (set.isEmpty) {
    final all = kTtcTreatmentInsights[phase];
    return all == null || all.isEmpty ? null : all.first;
  }
  return set[ttcDayIndex(day) % set.length];
}
