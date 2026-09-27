// =============================================================================
//  The words for a treatment round
// -----------------------------------------------------------------------------
//  Added 2026-09-26 for docs/TTC-TREATMENT-FLOW.md (B3, B4). Every sentence a
//  person reads about a round lives here, apart from the logic that decides
//  which one applies (`lib/ttc/ttc_treatment_round.dart`, the hero states in
//  `lib/ttc/ttc_home_hero.dart`). English only (CLAUDE.md, new work is
//  English), to docs/TTC-VOICE.md: "you", contractions, short sentences, no
//  dashes, no exclamation marks.
//
//  ⚠️ OURS NEVER COMPETE WITH HERS (CLAUDE.md, clinical ownership). Every date
//  printed here is one her clinic gave her. We explain, remind and help her
//  prepare; we never suggest a date, a dose or a step, never read a result,
//  and never put a number on how likely anything is. The blood test is always
//  named by its DATE and never counted down to.
//
//  ⚠️ NOTHING CHANGES SILENTLY (the user's rule, 2026-09-26). The start flow,
//  the check-in, the result and "the plan changed" each say, in the option's
//  own label, exactly what choosing it does, and every closing says how to
//  undo it and when her own cycle comes back.
// =============================================================================

import '../../ttc/ttc_home_hero.dart';
import '../../ttc/ttc_treatment_round.dart';
import '../../ttc/ttc_treatment_store.dart';

// ---- dates --------------------------------------------------------------------

const _wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _wdFull = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', //
  'Sunday',
];
const _mo = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

DateTime _d(DateTime x) => DateTime(x.year, x.month, x.day);

/// "Tue 14 Oct".
String ttcRoundDate(DateTime d) =>
    '${_wd[d.weekday - 1]} ${d.day} ${_mo[d.month - 1]}';

/// "10:15pm".
String ttcRoundTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final ampm = d.hour < 12 ? 'am' : 'pm';
  return '$h:${d.minute.toString().padLeft(2, '0')}$ampm';
}

/// "today", "tomorrow", "on Thursday" (within the week), else
/// "on Tue 14 Oct". Relative to [from], the day the page describes.
String ttcRoundOn(DateTime d, DateTime from) {
  final gap = _d(d).difference(_d(from)).inDays;
  if (gap == 0) return 'today';
  if (gap == 1) return 'tomorrow';
  if (gap > 1 && gap < 7) return 'on ${_wdFull[d.weekday - 1]}';
  return 'on ${ttcRoundDate(d)}';
}

// ---- kinds ----------------------------------------------------------------------

/// The start flow's option for [kind].
String ttcRoundKindName(TtcRoundKind kind) => switch (kind) {
      TtcRoundKind.ivfFresh => 'IVF with a fresh transfer',
      TtcRoundKind.ivfFreezeAll => 'IVF, freezing the embryos',
      TtcRoundKind.fetMedicated => 'Frozen embryo transfer, with medicines',
      TtcRoundKind.fetNatural => 'Frozen embryo transfer, in my natural cycle',
      TtcRoundKind.iui => 'IUI',
      TtcRoundKind.ovulationInduction => 'Tablets with scans',
      TtcRoundKind.notSure => 'Not sure yet',
    };

/// One line under the option.
String ttcRoundKindNote(TtcRoundKind kind) => switch (kind) {
      TtcRoundKind.ivfFresh =>
        'Injections, egg collection, then a transfer a few days later.',
      TtcRoundKind.ivfFreezeAll =>
        'Injections and egg collection. The embryos are frozen for later.',
      TtcRoundKind.fetMedicated =>
        'Estrogen tablets first, then progesterone. The most common kind.',
      TtcRoundKind.fetNatural =>
        'Scans watch your own ovulation, and the transfer is timed from it.',
      TtcRoundKind.iui => 'Tablets or injections, scans, a trigger, then the IUI.',
      TtcRoundKind.ovulationInduction =>
        'Tablets like letrozole or clomiphene, with follicle scans.',
      TtcRoundKind.notSure =>
        "We'll show the IVF steps. Every step is optional.",
    };

/// The eyebrow on the home: "IVF", "IUI".
String ttcRoundKindShort(TtcRoundKind? kind) => switch (kind) {
      TtcRoundKind.iui => 'IUI',
      TtcRoundKind.ovulationInduction => 'Your round',
      TtcRoundKind.fetMedicated || TtcRoundKind.fetNatural => 'Frozen transfer',
      TtcRoundKind.ivfFresh ||
      TtcRoundKind.ivfFreezeAll ||
      TtcRoundKind.notSure ||
      null =>
        'IVF',
    };

/// A step's name in a round of [kind].
String ttcStepLabel(TtcTreatmentStep step, TtcRoundKind? kind) {
  final oiOrIui =
      kind == TtcRoundKind.ovulationInduction || kind == TtcRoundKind.iui;
  return switch (step) {
    TtcTreatmentStep.stimStart => kind == TtcRoundKind.ovulationInduction
        ? 'First tablet'
        : kind == TtcRoundKind.iui
            ? 'First tablet or injection'
            : 'First stimulation injection',
    TtcTreatmentStep.trigger => 'Trigger injection',
    TtcTreatmentStep.retrieval =>
      kind == null ? 'Egg collection or IUI' : 'Egg collection',
    TtcTreatmentStep.transfer => 'Embryo transfer',
    TtcTreatmentStep.betaTest => oiOrIui ? 'Pregnancy test' : 'Blood test',
    TtcTreatmentStep.repeatBeta => 'Repeat blood test',
    _ => step.label(false),
  };
}

/// One scan's name in a round of [kind].
String ttcScanLabel(TtcRoundKind? kind) => switch (kind) {
      TtcRoundKind.fetMedicated => 'Lining scan',
      TtcRoundKind.ovulationInduction ||
      TtcRoundKind.iui ||
      TtcRoundKind.fetNatural =>
        'Follicle scan',
      _ => 'Monitoring scan',
    };

/// The heading of the scans row.
String ttcScansRowLabel(TtcRoundKind? kind) => '${ttcScanLabel(kind)}s';

/// One plain sentence for a row of "Here's how your round usually goes".
String ttcRowLine(TtcRoundRow row, TtcRoundKind? kind) {
  final ivf = ttcRoundIsIvfShaped(kind) && kind != TtcRoundKind.fetMedicated;
  if (row.scans) {
    return switch (kind) {
      TtcRoundKind.fetMedicated => 'A scan or two to check your lining.',
      TtcRoundKind.fetNatural => 'Scans that watch your own ovulation.',
      TtcRoundKind.ovulationInduction || TtcRoundKind.iui =>
        'Follicle scans from about day 9 to 11, until a follicle is ready.',
      _ => 'A scan every 1 to 3 days, to watch your follicles grow.',
    };
  }
  return switch (row.step!) {
    TtcTreatmentStep.pillStart =>
      'Some clinics use a month of pills first, to time the start.',
    TtcTreatmentStep.downRegStart =>
      'On a long plan, a daily injection quietens your cycle first.',
    TtcTreatmentStep.estrogenStart =>
      'Tablets that build up the lining of your womb.',
    TtcTreatmentStep.baselineScan =>
      'A scan on day 2 or 3 of your period, before any medicine starts.',
    TtcTreatmentStep.stimStart => kind == TtcRoundKind.ovulationInduction
        ? 'Tablets once a day, usually for 5 days.'
        : kind == TtcRoundKind.iui
            ? 'Tablets or low-dose injections, to help an egg ripen.'
            : 'Daily injections, at about the same time each evening.',
    TtcTreatmentStep.trigger => ivf
        ? 'An injection at an exact time. Egg collection is 34 to 36 hours later.'
        : kind == TtcRoundKind.iui
            ? 'An injection at an exact time. Your IUI is timed from it.'
            : 'If your clinic uses one, it times what comes next.',
    TtcTreatmentStep.retrieval =>
      'About 15 to 30 minutes under short sedation. Someone takes you home.',
    TtcTreatmentStep.iui =>
      'A few minutes, a bit like a smear test. You can go about your day after.',
    TtcTreatmentStep.progesteroneStart =>
      'Supports the lining. Keep taking it until your clinic says to stop.',
    TtcTreatmentStep.transfer =>
      'A few minutes, with no sedation. Some clinics ask for a full bladder.',
    TtcTreatmentStep.betaTest =>
      "On the date your clinic gives. It's the answer to trust.",
    TtcTreatmentStep.repeatBeta =>
      'Some clinics repeat the test about 48 hours later.',
    TtcTreatmentStep.reviewAppointment =>
      'A time to go through the round with your doctor.',
  };
}

/// The read a row links to, first choice first. The screen shows the first
/// that resolves, so a new `ttc_read_tx_*` read takes over the day it lands.
List<String> ttcRowReadIds(TtcRoundRow row, TtcRoundKind? kind) {
  // 2026-09-26: the G1 to G12 reads exist, so each row leads with its own.
  // Kept for revert, the scans row before: fetMedicated had none, every
  // other kind `ttc_read_follicle_scans`.
  if (row.scans) {
    return switch (kind) {
      TtcRoundKind.fetMedicated => const ['ttc_read_tx_frozen_transfer'],
      TtcRoundKind.ovulationInduction ||
      TtcRoundKind.iui ||
      TtcRoundKind.fetNatural =>
        const ['ttc_read_follicle_scans'],
      _ => const ['ttc_read_tx_monitoring_scans', 'ttc_read_follicle_scans'],
    };
  }
  return switch (row.step!) {
    TtcTreatmentStep.pillStart ||
    TtcTreatmentStep.downRegStart =>
      const ['ttc_read_ivf_explained'],
    // Kept for revert: const ['ttc_read_clinic_glossary'].
    TtcTreatmentStep.baselineScan =>
      const ['ttc_read_tx_baseline_scan', 'ttc_read_clinic_glossary'],
    TtcTreatmentStep.estrogenStart => const ['ttc_read_tx_frozen_transfer'],
    TtcTreatmentStep.stimStart => kind == TtcRoundKind.ovulationInduction ||
            kind == TtcRoundKind.iui
        ? const ['ttc_read_ovulation_tablets']
        : const ['ttc_read_ivf_injections'],
    TtcTreatmentStep.trigger =>
      const ['ttc_read_tx_trigger_shot', 'ttc_read_ivf_injections'],
    TtcTreatmentStep.retrieval => kind == TtcRoundKind.ivfFreezeAll
        ? const ['ttc_read_ivf_retrieval', 'ttc_read_tx_fresh_or_frozen']
        : const ['ttc_read_ivf_retrieval'],
    TtcTreatmentStep.iui => const ['ttc_read_tx_iui_day'],
    TtcTreatmentStep.transfer => const ['ttc_read_tx_transfer_day'],
    TtcTreatmentStep.betaTest ||
    TtcTreatmentStep.repeatBeta =>
      const ['ttc_read_tx_beta_test', 'ttc_read_when_to_test'],
    TtcTreatmentStep.reviewAppointment =>
      const ['ttc_read_tx_review_appointment'],
    _ => const [],
  };
}

/// What undated rows say (the brief's own words).
const String kTtcRoundClinicWillTell = 'Your clinic will tell you';

// ---- the hero (§3a) -----------------------------------------------------------

/// The next clinic date after the day, as a sentence: "Next scan on
/// Thursday." / "Egg collection on Sunday."
String? ttcRoundNextLine(TtcHeroLine line, DateTime day) {
  final on = line.nextOn;
  if (on == null) return null;
  final step = line.nextStep;
  final when = ttcRoundOn(on, day);
  if (step == null) return 'Next scan $when.';
  if (step == TtcTreatmentStep.betaTest || step == TtcTreatmentStep.repeatBeta) {
    // A test is named by its date, never by how soon.
    return '${ttcStepLabel(step, line.kind)} on ${ttcRoundDate(on)}.';
  }
  return '${ttcStepLabel(step, line.kind)} $when.';
}

/// The small line under her own cycle's hero while a round is planned (S1).
String ttcRoundUpcomingLine(TtcHeroLine line) {
  final on = line.upcomingOn!;
  final what = switch (line.upcomingStep) {
    null || TtcTreatmentStep.baselineScan => 'starts with a scan',
    TtcTreatmentStep.stimStart => line.kind == TtcRoundKind.ovulationInduction
        ? 'starts with your first tablet'
        : 'starts with the first injection',
    TtcTreatmentStep.pillStart => 'starts with a pill cycle',
    TtcTreatmentStep.downRegStart => 'starts with down-regulation',
    TtcTreatmentStep.estrogenStart => 'starts with estrogen tablets',
    _ => 'starts',
  };
  final who =
      line.kind == TtcRoundKind.ovulationInduction ? 'Your round' : ttcRoundKindShort(line.kind);
  return '$who $what on ${ttcRoundDate(on)}.';
}

/// (lead, big, sub) for a round hero state on [day].
(String, String, String) ttcRoundHeroCopy(TtcHeroLine line, DateTime day) {
  final short = ttcRoundKindShort(line.kind);
  final next = ttcRoundNextLine(line, day);
  final kind = line.kind;
  switch (line.state) {
    case TtcHeroState.treatmentGettingReady:
      final big = switch (line.countStep) {
        TtcTreatmentStep.estrogenStart => 'Estrogen day ${line.days}',
        TtcTreatmentStep.downRegStart => 'Down-regulation day ${line.days}',
        _ => 'Getting ready',
      };
      return (
        '$short · Getting ready',
        big,
        next ?? 'Your clinic will tell you the next step.',
      );
    case TtcHeroState.treatmentStimulation:
      final scansOnly = line.countStep == null;
      final stage = kind == TtcRoundKind.ovulationInduction ||
              kind == TtcRoundKind.iui
          ? 'Tablets and scans'
          : kind == TtcRoundKind.fetNatural
              ? 'Scans'
              : 'Stimulation';
      final big = scansOnly
          ? 'Scans this week'
          : kind == TtcRoundKind.ovulationInduction
              ? 'Tablet day ${line.days}'
              : kind == TtcRoundKind.iui
                  ? 'Medicine day ${line.days}'
                  : 'Injection day ${line.days}';
      return ('$short · $stage', big, next ?? 'Your clinic will tell you the next scan.');
    case TtcHeroState.treatmentTrigger:
      if (line.days == 0 && line.date != null) {
        return (
          '$short · Trigger day',
          'Trigger injection at ${ttcRoundTime(line.date!)}',
          next ?? "Your clinic's time is the one to keep.",
        );
      }
      final ns = line.nextStep;
      if (ns == TtcTreatmentStep.retrieval && line.nextOn != null) {
        return (
          short,
          'Egg collection ${ttcRoundOn(line.nextOn!, day)}',
          'No food or drink after the time your clinic gave you.',
        );
      }
      if (ns == TtcTreatmentStep.iui && line.nextOn != null) {
        return (
          short,
          'IUI ${ttcRoundOn(line.nextOn!, day)}',
          'Ask your clinic what time his sample is needed.',
        );
      }
      return (
        '$short · After the trigger',
        'The day after your trigger',
        kind == TtcRoundKind.ovulationInduction
            ? 'Your clinic will tell you which days to have sex.'
            : (next ?? 'Your clinic will tell you what comes next.'),
      );
    case TtcHeroState.treatmentProcedure:
      return line.step == TtcTreatmentStep.iui
          ? (short, 'IUI today', 'It takes a few minutes. You can go about your day after.')
          : (short, 'Egg collection today', 'Rest after. Someone should take you home.');
    case TtcHeroState.treatmentEmbryoDays:
      if (kind == TtcRoundKind.ivfFreezeAll) {
        return (
          '$short · Embryo days',
          'Your embryos are with the lab',
          'Your clinic will tell you about freezing.',
        );
      }
      final transfer = line.nextStep == TtcTreatmentStep.transfer &&
              line.nextOn != null
          ? ' Transfer planned ${ttcRoundOn(line.nextOn!, day)}.'
          : '';
      return (
        '$short · Embryo days',
        line.days > 0 ? 'Embryo day ${line.days}' : 'Embryo days',
        'The lab may call with an update.$transfer',
      );
    case TtcHeroState.treatmentTransfer:
      return (short, 'Transfer day', 'Keep taking your progesterone as your clinic said.');
    case TtcHeroState.treatmentWait:
      final after = switch (line.countStep) {
        TtcTreatmentStep.transfer => 'after transfer',
        TtcTreatmentStep.iui || TtcTreatmentStep.retrieval => 'after your IUI',
        TtcTreatmentStep.trigger => 'after your trigger',
        _ => '',
      };
      final lead = after.isEmpty || line.days <= 0
          ? 'The wait'
          : 'The wait · Day ${line.days} $after';
      final test = ttcStepLabel(TtcTreatmentStep.betaTest, kind);
      return (
        lead,
        line.date == null ? 'Waiting for your test' : '$test on ${ttcRoundDate(line.date!)}',
        line.date == null
            ? 'Your clinic will tell you the date. Keep taking your medicines until they say.'
            : 'Keep taking your medicines until your clinic says.',
      );
    case TtcHeroState.treatmentTestDay:
      final test = ttcStepLabel(line.step ?? TtcTreatmentStep.betaTest, kind);
      return line.days == 0
          ? ('', '$test today', "Your clinic will share the result. We're here either way.")
          : ('', 'Waiting to hear', "When you're ready, tell us how the test went.");
    case TtcHeroState.treatmentResult:
      return (
        'Round closed',
        'Positive test',
        'Keep taking your medicines until your clinic tells you otherwise.',
      );
    case TtcHeroState.treatmentBetweenRounds:
      return (
        '',
        'Between rounds',
        line.date != null
            ? 'Review with your clinic ${ttcRoundOn(line.date!, day)}.'
            : 'Your own cycle comes back when you log your next period.',
      );
    default:
      return ('', '', '');
  }
}

// ---- the start flow -------------------------------------------------------------

const String kTtcStartKindTitle = 'What kind of treatment is this?';
const String kTtcStartKindBody =
    "Pick the closest. You can change it later if the plan changes.";
const String kTtcStartDateTitle = "What's the first date your clinic gave you?";
const String kTtcStartDateBody =
    "Add the ones you know. The rest can wait, and we'll show them as your clinic tells you.";
const String kTtcStartLater = "I'll add it later";
const String kTtcStartReviewTitle = "Here's what happens next";
const String kTtcStartClinicLabel = 'Which clinic? (optional)';
const String kTtcStartPartnerLine =
    'If your partner has joined, they see these dates too.';
const String kTtcStartKeepsLegacy = "We'll keep the dates you already added.";
const String kTtcStartClosesCurrent =
    'Your current round will be closed and kept in your history.';

/// The statement on the last screen: exactly what changes, and from when.
String ttcStartWhatChanges(DateTime? first, DateTime today) {
  if (first == null) {
    return 'Nothing changes yet. Your home follows your own cycle until you '
        "add your clinic's first date.";
  }
  final f = _d(first), t = _d(today);
  if (f.isAfter(t)) {
    return 'From ${ttcRoundDate(f)} (your first treatment day), your home will '
        'follow your round. Fertile days and period predictions will pause '
        'until the round ends. Until then, nothing changes.';
  }
  return 'Your home follows your round from today, because your first '
      'treatment day was ${f == t ? 'today' : ttcRoundDate(f)}. Fertile days '
      'and period predictions pause until the round ends.';
}

const String kTtcStartUndoLine =
    'You can pause or end the round at any time, and your dates always stay.';
const String kTtcStartOkay = 'Okay, follow my round';
const String kTtcStartOkayNoDate = 'Okay';
const String kTtcStartChangeDate = 'Change date';
const String kTtcStartAddDate = 'Add a date';

// ---- the treatment screen --------------------------------------------------------

const String kTtcRoundPlanTitle = "Here's how your round usually goes";
const String kTtcRoundPlanBody =
    "Your clinic's dates are filled in. Tap any step to add or change its date.";
const String kTtcRoundAddScan = 'Add another scan';
const String kTtcRoundEmbryoQ = 'Which day is the embryo?';
const String kTtcRoundStartCardTitle = 'Starting treatment?';
const String kTtcRoundStartCardBody =
    "Tell us your clinic's plan and we'll follow it with you.";
const String kTtcRoundStartCta = 'Start';
const String kTtcRoundLegacyTitle = 'What kind of treatment is this?';
const String kTtcRoundLegacyBody =
    "Tell us, and we'll show every step of your round with the dates you added.";
const String kTtcRoundPastTitle = 'Your past rounds';
const String kTtcRoundHistoryNote = 'Kept, never deleted.';
const String kTtcRoundUndoCta = 'Undo';
const String kTtcRoundPlanChanged = 'The plan changed';
const String kTtcRoundTakeBreak = 'Take a break from treatment';
const String kTtcRoundTellResult = 'Tell us how the test went';
const String kTtcRoundRemove = 'Remove these dates';
const String kTtcRoundRemoveBody =
    "For a round entered by mistake. The dates of this round are removed. Your past rounds and everything else you've logged stay.";
const String kTtcRoundMedicationLink =
    'Add your injection time to your medication schedule, so we can remind you.';

String ttcRoundHistoryLabel(int n, TtcTreatmentCycle r) {
  final first = ttcFirstTreatmentDate(r);
  final last = ttcLastRoundDate(r) ?? r.closedOn;
  String m(DateTime d) => _mo[d.month - 1];
  final span = first == null || last == null
      ? ''
      : (first.month == last.month && first.year == last.year)
          ? ', ${m(first)}'
          : ', ${m(first)} to ${m(last)}';
  return 'Round $n$span';
}

String ttcRoundOutcomeLabel(TtcRoundOutcome? o) => switch (o) {
      TtcRoundOutcome.positive => 'Positive test',
      TtcRoundOutcome.negative => 'Not this time',
      TtcRoundOutcome.paused => 'Paused',
      TtcRoundOutcome.ended => 'Ended',
      TtcRoundOutcome.stopped => 'Stopped early',
      null => 'Open',
    };

// ---- date checks ------------------------------------------------------------------

String ttcDateProblemText(TtcDateProblem p, TtcRoundKind? kind) {
  switch (p.kind) {
    case TtcDateProblemKind.beforeEarlierStep:
      return 'This is before your ${ttcStepLabel(p.other!, kind).toLowerCase()}. '
          "Please check it against your clinic's plan.";
    case TtcDateProblemKind.afterLaterStep:
      return 'This is after your ${ttcStepLabel(p.other!, kind).toLowerCase()}. '
          "Please check it against your clinic's plan.";
    case TtcDateProblemKind.farPast:
      return "That's more than three months ago. Is it the right date?";
    case TtcDateProblemKind.farFuture:
      return "That's more than nine months away. Is it the right date?";
  }
}

const String kTtcDateCheckTitle = 'Check this date';
const String kTtcDateUseIt = 'Use this date';
const String kTtcDatePickAgain = 'Pick again';

// ---- the check-in (decision 3) ----------------------------------------------------

const String kTtcCheckInTitle = 'Is your round still going?';
const String kTtcCheckInBody =
    "Your clinic's dates have all passed. Nothing changes until you choose.";
const String kTtcCheckInReturnBody =
    "Welcome back. Before we show anything, is your round still going, or are you back on your own cycle?";
const String kTtcCheckInStill = 'Still going';
const String kTtcCheckInStillLine = 'Keep following my round.';
const String kTtcCheckInPaused = 'Paused';
const String kTtcCheckInPausedLine =
    'Stop following it for now. Keep my dates.';
const String kTtcCheckInOver = "It's over";
const String kTtcCheckInOverLine =
    'Close this round and go back to my own cycle.';
const String kTtcCheckInAddDate = 'Add the next date';
const String kTtcCheckInLater = 'Ask me later';
const String kTtcCheckInCardTitle = 'Is your round still going?';
const String kTtcCheckInCardCta = 'Answer';

// ---- confirmations: the consequence, restated -----------------------------------

const String kTtcConfirmKeep = 'Keep it open';

(String, String, String) ttcConfirmClose(TtcRoundOutcome how) => switch (how) {
      TtcRoundOutcome.paused => (
          'Pause this round?',
          'We stop following your round for now. Your dates stay in your '
              'history. Your own cycle comes back when you log your next period. '
              'You can undo this for 7 days.',
          'Pause the round',
        ),
      TtcRoundOutcome.ended => (
          'Close this round?',
          'We stop following your round. Your dates stay in your history. Your '
              'own cycle comes back when you log your next period. You can undo '
              'this for 7 days.',
          'Close the round',
        ),
      TtcRoundOutcome.stopped => (
          'Close this round as stopped early?',
          'Plans change often in treatment. It says nothing about the next '
              'round. Your dates stay in your history, and your own cycle comes '
              'back when you log your next period. You can undo this for 7 days.',
          'Close the round',
        ),
      TtcRoundOutcome.negative => (
          'Close this round?',
          "We'll close it as not this time. Your dates stay in your history. "
              'Your own cycle comes back when you log your next period. You can '
              'undo this for 7 days.',
          'Close the round',
        ),
      TtcRoundOutcome.positive => (
          'Record a positive test?',
          "We'll close this round as positive. Keep taking your medicines until "
              'your clinic tells you otherwise. You can undo this for 7 days.',
          'Record it',
        ),
    };

/// What the confirmation card says once a round has closed.
String ttcClosedLine(TtcRoundOutcome how) => how == TtcRoundOutcome.positive
    ? 'Round closed as positive. Your clinic will guide what comes next.'
    : 'Round closed. Your own cycle comes back when you log your next period.';

// ---- the result (from test day) ---------------------------------------------------

const String kTtcResultTitle = 'How did the test go?';
const String kTtcResultBody =
    "Only when you're ready. We never read the number, and your clinic explains the result.";
const String kTtcResultPositive = 'Positive';
const String kTtcResultPositiveLine = 'Close this round as a positive test.';
const String kTtcResultNegative = 'Not this time';
const String kTtcResultNegativeLine =
    'Close this round. Your own cycle comes back with your next period.';
const String kTtcResultRepeat = 'My clinic wants to repeat it';
const String kTtcResultRepeatLine =
    'Add the date of the next test. The round stays open.';
const String kTtcResultLater = "I'd rather not say now";
const String kTtcResultPositiveNext =
    'Keep taking all your medicines until your clinic tells you otherwise. They will date your pregnancy from your treatment.';

// ---- the plan changed ------------------------------------------------------------

const String kTtcPlanTitle = 'The plan changed';
const String kTtcPlanBody =
    "Plans change often in treatment. It doesn't say anything about the next round.";
const String kTtcPlanStopped = 'It stopped early';
const String kTtcPlanStoppedLine = 'Close this round. Keep my dates.';
const String kTtcPlanIui = 'It became an IUI';
const String kTtcPlanIuiLine = 'Keep my dates and show the IUI steps from here.';
const String kTtcPlanFreeze = 'Freezing all the embryos';
const String kTtcPlanFreezeLine =
    'No transfer this round. Keep my dates and end the plan at egg collection.';

(String, String, String) ttcConfirmKind(TtcRoundKind kind) => (
      'Change this round to ${ttcRoundKindName(kind).toLowerCase()}?',
      'Every date you added stays. The steps still ahead change to match. You '
          'can change it back from this screen.',
      'Change it',
    );

// ---- the home's round card ---------------------------------------------------------

const String kTtcActiveTitle = 'Your home now follows your round';
const String kTtcActiveBody =
    'Fertile days and period predictions are paused until the round ends.';
const String kTtcActiveWhatChanged = 'What changed';
const String kTtcActiveGotIt = 'Got it';
const List<String> kTtcActiveChanges = [
  "The top of your home shows your round's step and its next date.",
  'Fertile days, ovulation and period predictions are paused.',
  "Your cycle days and everything you log stay exactly as they are.",
  'Every door and read stays where it is.',
  'They come back when the round ends and you log your next period.',
];
const String kTtcReturnTitle = 'Your fertile days are back';
const String kTtcReturnBody =
    'Your round has ended and you logged a new period, so your home follows your own cycle again.';
const String kTtcInviteTitle = "Add your clinic's dates";
const String kTtcInviteBody =
    "Once your clinic's first date arrives, your home follows your round. Until then, it follows your own cycle.";
const String kTtcResultCardTitle = "When you're ready, tell us how the test went.";
const String kTtcBetweenTitle = 'Between rounds';
const String kTtcClosedOwnCycleBack =
    'Your home follows your own cycle again. You can undo this for 7 days.';

/// The one-tap row's replacement while a round runs (§3e).
String ttcBloodTestLine(DateTime on, TtcRoundKind? kind) =>
    'Your ${ttcStepLabel(TtcTreatmentStep.betaTest, kind).toLowerCase()} is on ${ttcRoundDate(on)}';
const String kTtcSeeRound = 'See your round';

/// Where the round stands, in two or three words, for the treatment screen.
String ttcRoundPhaseName(TtcRoundPhase phase, TtcRoundKind? kind) =>
    switch (phase) {
      TtcRoundPhase.ownCycle => 'No dates yet',
      TtcRoundPhase.planned => 'Not started yet',
      TtcRoundPhase.gettingReady => 'Getting ready',
      TtcRoundPhase.stimulation => kind == TtcRoundKind.ovulationInduction ||
              kind == TtcRoundKind.iui
          ? 'Tablets and scans'
          : kind == TtcRoundKind.fetNatural
              ? 'Scans'
              : 'Stimulation',
      TtcRoundPhase.trigger => 'Trigger',
      TtcRoundPhase.procedure =>
        kind == TtcRoundKind.iui ? 'IUI day' : 'Egg collection day',
      TtcRoundPhase.embryoDays => 'Embryo days',
      TtcRoundPhase.transfer => 'Transfer day',
      TtcRoundPhase.waiting => 'The wait',
      TtcRoundPhase.testDay => 'Test day, then waiting to hear',
      TtcRoundPhase.result => 'Positive test',
      TtcRoundPhase.betweenRounds => 'Between rounds',
    };

const String kTtcUndoCardLine = 'You closed a round in the last 7 days.';

// ---- the calendar (B5, §3c) ---------------------------------------------------

/// The band's name, for the legend and the day panel.
String ttcRoundBandLabel(TtcRoundBand band, TtcRoundKind? kind) =>
    switch (band) {
      TtcRoundBand.medicine =>
        kind == TtcRoundKind.iui ? 'Medicine days' : 'Injection days',
      TtcRoundBand.waitingForTest =>
        'Waiting for your ${ttcStepLabel(TtcTreatmentStep.betaTest, kind).toLowerCase()}',
    };

/// The legend's row for the small ink dot under a clinic date.
const String kTtcCalendarClinicDate = 'A date from your clinic';

/// The day panel's prefix for a date from a round she has closed.
const String kTtcCalendarPastRound = 'Past round';

/// The line under "Coming up" while a round runs.
const String kTtcCalendarRoundNote =
    "Your clinic's dates lead while your round runs. Fertile days and period "
    'predictions are paused until it ends.';

/// "Coming up" while a round is planned: her own cycle still leads.
const String kTtcCalendarRoundPlannedNote =
    "Your own cycle leads until your round's first date.";

/// When a clinic date is, for the "Coming up" card. Things she does are
/// counted ("Tomorrow", "In 3 days"); a test is named by its date only.
String ttcCalendarWhen(TtcTreatmentStep? step, DateTime on, DateTime today) {
  final gap = _d(on).difference(_d(today)).inDays;
  if (step == TtcTreatmentStep.betaTest ||
      step == TtcTreatmentStep.repeatBeta) {
    return ttcRoundDate(on);
  }
  if (gap == 0) return 'Today';
  if (gap == 1) return 'Tomorrow';
  return 'In $gap days · ${ttcRoundDate(on)}';
}

/// The name of a clinic date on the calendar: a step, or a scan (null).
String ttcCalendarDateLabel(TtcTreatmentStep? step, TtcRoundKind? kind) =>
    step == null ? ttcScanLabel(kind) : ttcStepLabel(step, kind);

const String kTtcCalendarSeeRound = 'See your round';
const String kTtcCalendarSeeRoundLine =
    'Every date from your clinic, and your past rounds.';

// ---- the IVF door's top panel (B7, §3f) ---------------------------------------

const String kTtcPanelRoundEyebrow = 'Your round';
const String kTtcPanelSeePlan = 'See the whole plan';
const String kTtcPanelUpdateDates = 'Update dates';
const String kTtcPanelNoDatesTitle = 'No dates yet';
const String kTtcPanelNoDatesLine =
    "Add your clinic's first date, and your home follows your round from that day.";
const String kTtcPanelNoNext = 'Your clinic will tell you the next date.';
const String kTtcPanelBetweenTitle = 'Between rounds';
const String kTtcPanelBetweenLine =
    'Your own cycle comes back when you log your next period. Nothing about '
    'the next step has to be decided today.';
const String kTtcPanelStartNext = 'Start the next round';
const String kTtcPanelPositiveTitle = 'Positive test';
const String kTtcPanelDatePregnancy = 'Move to Pregnancy';

/// "Next: Egg collection, tomorrow" for the round panel.
String ttcPanelNextLine(
    TtcTreatmentStep? step, DateTime on, DateTime today, TtcRoundKind? kind) {
  final w = ttcCalendarWhen(step, on, today);
  final lower = RegExp(r'^(Today|Tomorrow|In )').hasMatch(w)
      ? w[0].toLowerCase() + w.substring(1)
      : w;
  return 'Next: ${ttcCalendarDateLabel(step, kind)}, $lower';
}

// ---- his side (B10, §3g) --------------------------------------------------------

/// His round line: (eyebrow, line, note), or null when there is nothing of
/// the round to show him.
///
/// ⚠️ THE ROUND, NEVER HER CYCLE (the same privacy rule as `partnerChapter`).
/// Only the step and its clinic date, and what it asks of him. No cycle
/// day, no period, no fertile days, and no result: a closed round shows
/// nothing, because how the test went is hers to tell him.
(String, String, String?)? ttcPartnerRoundLine(
    TtcTreatmentCycle r, DateTime now) {
  if (r.isEmpty || r.isClosed) return null;
  final today = _d(now);
  final kind = r.kind;
  final short = ttcRoundKindShort(kind);
  final phase = ttcTreatmentPhase(r, today);
  final test = ttcRoundBloodTest(r);
  if (phase == TtcRoundPhase.testDay) {
    if (test != null && _d(test) == today) {
      return (
        short,
        '${ttcStepLabel(TtcTreatmentStep.betaTest, kind)} today',
        'Plan something gentle together for after, whatever the day brings.',
      );
    }
    return null; // waiting to hear: hers to share
  }
  final next = ttcRoundNextAfter(r, today.subtract(const Duration(days: 1)));
  if (next == null) return null;
  final (step, on) = next;
  final isTest =
      step == TtcTreatmentStep.betaTest || step == TtcTreatmentStep.repeatBeta;
  final when = isTest ? 'on ${ttcRoundDate(on)}' : ttcRoundOn(on, today);
  final line = '${ttcCalendarDateLabel(step, kind)} $when';
  final String? note = switch (step) {
    TtcTreatmentStep.retrieval when kind != TtcRoundKind.iui =>
      'Your sample is needed that morning. Ask the clinic what time.',
    TtcTreatmentStep.iui => 'Your sample is needed that morning. Ask the '
        'clinic what time, and how long before to arrive.',
    // An IUI round kept its IUI in the old combined step.
    TtcTreatmentStep.retrieval => 'Your sample is needed that morning. Ask '
        'the clinic what time, and how long before to arrive.',
    TtcTreatmentStep.transfer =>
      "It's quick. Being there with her is the part that helps.",
    TtcTreatmentStep.trigger => 'The time is exact. Help her keep it.',
    _ => null,
  };
  return (short, line, note);
}

const String kTtcPartnerRoundEyebrow = 'Her round';

// ---- positive, then Pregnancy dated by the clinic (B8) ---------------------------

const String kTtcToPregTitle = 'Moving to Pregnancy';
const String kTtcToPregIntro =
    'Before anything changes: your home will become the pregnancy home. Your '
    'round, your dates and everything you logged stay. Choose how your '
    'pregnancy is dated.';
const String kTtcToPregEmbryoQ = 'Which day was the embryo when it was transferred?';
const String kTtcToPregClinic = 'My clinic gave me a due date';
const String kTtcToPregClinicLine = "Enter the date they told you. We'll use theirs.";
const String kTtcToPregNotNow = 'Not now';
const String kTtcToPregNotNowLine =
    'Stay here for now. You can move to Pregnancy from your round any time.';
const String kTtcToPregConfirmNo = 'Not yet';
const String kTtcToPregConfirmYes = 'Move to Pregnancy';
const String kTtcToPregNoDate =
    "We don't have a date to count from. Add your transfer date to your "
    'round, or enter the due date your clinic gave you.';
const String kTtcToPregAddTransfer = 'Add my transfer date';
