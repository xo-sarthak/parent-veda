// =============================================================================
//  The logger's red flags (T5 S1, S2, S3 — 2026-10-29)
// -----------------------------------------------------------------------------
//  docs/preg-ttc-tool-plans/T5-body-checks.md, "Clinical calls".
//
//  The symptom logger recorded pain, spotting and a positive test on one day
//  and said nothing. Three patterns now bring up one calm card on the day she
//  is looking at, and a fourth brings up a gentle line under her mood:
//
//    · ECTOPIC  pelvic pain AND spotting or bleeding on the same day, WITH a
//               positive test in the last 14 days or a period 7 or more days
//               late. NHS ectopic pregnancy page; RCOG GTG 21.
//    · OHSS     an open round, after egg collection and until the blood test:
//               bloating AND nausea AND pain on the same day. RCOG GTG 5.
//    · FEVER    38.0 °C or above on an open round, or "Unwell" with that
//               temperature within 14 days of a transfer.
//    · LOW MOOD "Low", "Tearful" or "Anxious" on 8 or more of the last 14
//               days (PHQ-2's "more than half the days"), shown at most once
//               a week.
//
//  ⚠️ PURE, AND THE INPUTS ARE PASSED IN. No widget and no singleton is read
//  inside a rule except the log store handed to it, so the test drives every
//  near-miss directly ("pain alone", "a positive test with no pain").
//
//  ⚠️ A FLAG NAMES A ROUTE, NEVER A CONDITION. The words are the plan's, word
//  for word, and each is a BEFORE-LAUNCH clinician CHECK line. None says what
//  she has; each says who to call and when.
// =============================================================================

import 'ttc_cycle_report.dart' show kTtcTempTracker, kTtcTempField;
import 'ttc_log_store.dart';
import 'ttc_symptom_data.dart';
import 'ttc_treatment_store.dart';

/// Which card shows. Identities, read by the screen and the test.
enum TtcSymptomFlag { ectopic, ohss, fever }

// ---- the chips each rule reads (persisted ids, `ttc_symptom_data.dart`) -----

/// One-sided or pelvic pain. "Cramping" is not on it: a period cramps, and
/// the plan names pelvic pain (a clinician CHECK point).
const Set<String> kTtcFlagPainIds = {'pelvic_pain'};

/// Spotting. A period logged that day counts as bleeding too.
const Set<String> kTtcFlagBleedIds = {'disch_spotting'};

/// A positive test. A faint line is a positive line (NHS: "any line").
const Set<String> kTtcFlagPositiveIds = {'pt_positive', 'pt_faint'};

/// OHSS reads tummy pain, so cramping counts there.
const Set<String> kTtcFlagOhssPainIds = {'pelvic_pain', 'cramping'};

const String kTtcFlagBloating = 'bloating';
const String kTtcFlagNausea = 'nausea';
const String kTtcFlagUnwell = 'illness';

/// The feelings the low-mood line counts.
const Set<String> kTtcLowMoodIds = {'low', 'tearful', 'anxious'};

/// 38.0 °C, the line the fever card draws.
const double kTtcFeverC = 38.0;

/// Days back a positive test still counts, and how late a period must be.
const int kTtcFlagPositiveDays = 14;
const int kTtcFlagLateDays = 7;

/// The low-mood window, its threshold, and how often the line may show.
const int kTtcLowMoodWindow = 14;
const int kTtcLowMoodDays = 8;
const int kTtcLowMoodEveryDays = 7;

// ---- the words (the plan's, word for word) ----------------------------------

const String kTtcFlagHeading = 'Worth checking today';

const String kTtcFlagEctopicText =
    'Pain with bleeding after a positive test needs checking the same day. '
    'Call your doctor or go to an early pregnancy unit today. If the pain is '
    'severe, or you feel faint or dizzy, call 112.';

const String kTtcFlagOhssText =
    'Bloating with sickness and pain after egg collection is something your '
    'clinic wants to hear about today. If you are short of breath, passing '
    'very little urine, or the pain is severe, get urgent help (112).';

const String kTtcFlagFeverText =
    'A temperature of 38 or above during treatment is worth a call to your '
    'clinic today.';

/// Under the OHSS card, to the read on it.
const String kTtcFlagOhssReadLink = 'Read about OHSS';

const String kTtcLowMoodLine =
    "It's been a heavy couple of weeks. Talking helps, and it doesn't have to "
    'wait for a bad day. Tele-MANAS is free on 14416, day and night.';

/// The card's text for [flag].
String ttcSymptomFlagText(TtcSymptomFlag flag) => switch (flag) {
      TtcSymptomFlag.ectopic => kTtcFlagEctopicText,
      TtcSymptomFlag.ohss => kTtcFlagOhssText,
      TtcSymptomFlag.fever => kTtcFlagFeverText,
    };

// ---- the rules --------------------------------------------------------------

DateTime _d(DateTime t) => DateTime(t.year, t.month, t.day);

Set<String> _chipsOn(TtcLogStore logs, DateTime day) => {
      for (final v in logs.valuesOn(kTtcSymptomTracker, TtcLogStore.dayKey(day)))
        if (v.value > 0) v.field,
    };

/// Whether a round is open on [day]: dated, not closed, and begun.
bool ttcRoundOpenOn(TtcTreatmentCycle? round, DateTime day) {
  if (round == null || round.isClosed || round.isEmpty) return false;
  final dates = round.allDates..sort();
  return !_d(day).isBefore(dates.first);
}

/// The flag for [day], or null. Ectopic first, then OHSS, then fever: when two
/// patterns stand, the one with the shortest route wins the card.
///
/// [periodStarts] are her current run's period starts (`CycleStore`
/// `currentPeriodStarts`), [usualCycleLength] her usual length in days.
TtcSymptomFlag? ttcSymptomFlag(
  DateTime day, {
  required TtcLogStore logs,
  required List<DateTime> periodStarts,
  required int usualCycleLength,
  TtcTreatmentCycle? round,
}) {
  final today = _d(day);
  final chips = _chipsOn(logs, today);

  // ---- ectopic --------------------------------------------------------------
  final pain = chips.any(kTtcFlagPainIds.contains);
  final periodToday = periodStarts.any((s) => _d(s) == today);
  final bleed = chips.any(kTtcFlagBleedIds.contains) || periodToday;
  if (pain && bleed) {
    var positive = false;
    for (var i = 0; i < kTtcFlagPositiveDays && !positive; i++) {
      final d = DateTime(today.year, today.month, today.day - i);
      positive = _chipsOn(logs, d).any(kTtcFlagPositiveIds.contains);
    }
    // Late is counted from the last start BEFORE today, so a bleed logged as
    // a period today does not reset the count it is being checked against.
    DateTime? last;
    for (final s in periodStarts) {
      final sd = _d(s);
      if (sd.isBefore(today) && (last == null || sd.isAfter(last))) last = sd;
    }
    final late = last != null &&
        today.difference(last).inDays >= usualCycleLength + kTtcFlagLateDays;
    if (positive || late) return TtcSymptomFlag.ectopic;
  }

  // ---- OHSS: an open round, after egg collection, until the blood test -----
  if (round != null && ttcRoundOpenOn(round, today)) {
    final opu = round[TtcTreatmentStep.retrieval];
    final test = round[TtcTreatmentStep.betaTest];
    final inWindow = opu != null &&
        !today.isBefore(_d(opu)) &&
        (test == null || !today.isAfter(_d(test)));
    if (inWindow &&
        chips.contains(kTtcFlagBloating) &&
        chips.contains(kTtcFlagNausea) &&
        chips.any(kTtcFlagOhssPainIds.contains)) {
      return TtcSymptomFlag.ohss;
    }
  }

  // ---- fever ----------------------------------------------------------------
  final temp = logs.valueFor(kTtcTempTracker, kTtcTempField, on: today)?.value;
  if (temp != null && temp >= kTtcFeverC) {
    if (ttcRoundOpenOn(round, today)) return TtcSymptomFlag.fever;
    // The wait after a transfer, even once the round is closed early.
    final transfer = round?[TtcTreatmentStep.transfer];
    if (chips.contains(kTtcFlagUnwell) && transfer != null) {
      final since = today.difference(_d(transfer)).inDays;
      if (since >= 0 && since < kTtcFlagPositiveDays) {
        return TtcSymptomFlag.fever;
      }
    }
  }
  return null;
}

/// How many of the [kTtcLowMoodWindow] days ending on [now] carry a low-mood
/// feeling.
int ttcLowMoodDayCount(TtcLogStore logs, DateTime now) {
  final today = _d(now);
  var n = 0;
  for (var i = 0; i < kTtcLowMoodWindow; i++) {
    final d = DateTime(today.year, today.month, today.day - i);
    if (_chipsOn(logs, d).any(kTtcLowMoodIds.contains)) n++;
  }
  return n;
}

/// Whether the low-mood line shows on [now]: 8 of the last 14 days, and not
/// shown in the 6 days before (it stays all of the day it first shows).
bool ttcLowMoodDue(TtcLogStore logs, DateTime now, DateTime? lastShown) {
  if (ttcLowMoodDayCount(logs, now) < kTtcLowMoodDays) return false;
  if (lastShown == null) return true;
  final gap = _d(now).difference(_d(lastShown)).inDays;
  return gap == 0 || gap >= kTtcLowMoodEveryDays;
}
