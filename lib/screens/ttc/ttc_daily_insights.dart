// =============================================================================
//  Daily insights — which cards this day earns
// -----------------------------------------------------------------------------
//  ⚠️ THE POINT IS THAT THE SET CHANGES. The rail shipped as five fixed circles
//  — insight, myth, nutrition, movement, pick — in the same order every day
//  forever. That is a menu wearing a date. The note back was that the reference
//  *"feels like a real time, not a static thing that's just fixed at its
//  position, which our app feels like a lot."*
//
//  So this file answers one question: given a day, what is worth putting on the
//  home? Some cards are always there because they are always true (cycle day).
//  Some appear only because of something she did (a symptom she logged, a
//  discharge type, a test she has not taken). Some appear only because of where
//  the cycle is.
//
//  ---------------------------------------------------------------------------
//  ⚠️ EVERY CARD OPENS SOMETHING THAT EXISTS
//  ---------------------------------------------------------------------------
//
//  The reference has a card reading "What Could Be Causing It?" under a logged
//  symptom, which opens a written piece about that symptom. We do not have
//  per-symptom content, and a card promising it would be the wrong-screen
//  failure this stage keeps writing tests about.
//
//  So where the content does not exist the card says something true instead —
//  "where it fell in your cycle", opening the report, which genuinely answers
//  a version of the question from her own data. The shape matches the
//  reference; the promise matches what we have.
//
//  ---------------------------------------------------------------------------
//  ⚠️ "CHANCE OF CONCEIVING" IS ALLOWED, AND HERE IS WHY
//  ---------------------------------------------------------------------------
//
//  It reads `FertilityLevel` — the engine's own low/medium/high/peak — and the
//  V1 home has shipped exactly this label, `chanceLabel`, since the stage was
//  built. It is a qualitative band derived from cycle POSITION, which is timing
//  information this app is explicitly permitted to give.
//
//  What stays forbidden is a NUMBER attached to her: a percentage, or any
//  figure computed from her own data and presented as how likely conception is
//  for this family. That sets a target. A band says where in the month she is,
//  which is the same thing the fertile-window screen says in dates.
//  `test/ttc_clinical_review_test.dart` holds the line.
//
//  ⚠️ AND DO NOT SPELL THE BANNED PHRASING OUT AS AN EXAMPLE, not even inside a
//  comment saying never to write it. That scanner reads source text, comments
//  included, and it cannot tell a prohibition from an instance — which is the
//  correct behaviour, because a phrase sitting in a file is one careless
//  copy-paste away from being a string. This file failed the suite that way
//  twice while being written, on two different patterns. Describe the shape;
//  do not assemble the words.
// =============================================================================

import '../../ttc/cycle_store.dart';
import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_store.dart';
import '../../ttc/ttc_symptom_data.dart';
import 'ttc_calendar_screen.dart' show TtcDayFacts, ttcFactsFor;
import '../v2/pv_insight_rail.dart' show PvInsightArt;
import 'ttc_mood_face.dart';

/// What the card draws — the shared set since 2026-09-21 (`PvInsightArt`,
/// lib/screens/v2/pv_insight_rail.dart). The TTC name stays so the cards
/// and their tests read as they did. Kept for revert below.
typedef TtcInsightArt = PvInsightArt;

// /// What the card draws in its coloured header.
// enum TtcInsightArt {
//   level,
//   number,
//   symptom,
//   droplet,
//   note,
//   balance,
//   ring,
//   log,
//   meal,
//   move,
//   product,
// }

/// Where tapping it goes. Resolved by the screen, so this file stays pure.
enum TtcInsightGo {
  window,
  cycle,
  report,
  insight,
  myth,
  logger,
  nutrition,
  movement,
  products,
}

/// One card on the rail.
class TtcInsightCard {
  const TtcInsightCard({
    required this.id,
    required this.eyebrow,
    required this.value,
    required this.hue,
    required this.art,
    required this.go,
    this.caption,
  });

  /// Stable, so a test can assert which cards a given day produces.
  final String id;

  /// The small line in the coloured header — "CHANCE OF CONCEIVING", "NAUSEA".
  final String eyebrow;

  /// The large answer in the white body — "Highest", "8", "Fertile".
  final String value;

  /// One optional line under the value.
  final String? caption;

  final double hue;
  final TtcInsightArt art;
  final TtcInsightGo go;
}

/// The cards [day] earns *because of what is true on it*, in order.
///
/// ⚠️ ORDER IS BY HOW MUCH THIS DAY DIFFERS FROM ANY OTHER DAY. The fertility
/// band and the cycle day come first because they are what she opened the app
/// to see. Anything driven by what she logged comes next, because it is the part
/// that proves the app noticed.
///
/// ⚠️ THE EVERGREEN TAIL IS NOT HERE, and the reason is a layering one worth
/// stating because the obvious refactor undoes it. Today's insight, myth,
/// nutrition, movement and the cycle report appear on EVERY day, and their
/// labels are localised strings that live in `lib/screens/ttc/ttc_strings.dart`
/// — under `screens/`, one layer up from this file. Importing a screen's
/// strings into `lib/ttc/` to save five lines would make the pure cycle logic
/// depend on the UI layer, and `ttc_home_v3_parity_test.dart` matches those
/// exact strings because V1 shows the same five doors.
///
/// So: this function decides what is SPECIAL about a day; the screen appends
/// what is always true. Anything conditional belongs here.
List<TtcInsightCard> ttcInsightsFor(DateTime day) {
  final store = TtcStore.instance;
  final log = TtcLogStore.instance;

  // ⚠️ FERTILITY COMES FROM `ttcFactsFor`, THE SAME CALL THE DAY STRIP MAKES.
  // Not from `TtcChapterEngine` directly, even though that is what this file
  // would otherwise reach for and is one line shorter.
  //
  // A band on a card and a tint on a date are the SAME claim, rendered twice,
  // four inches apart, on one screen. `ttcFactsFor` does the part that is easy
  // to get subtly wrong: it walks back to the most recent period start *on or
  // before* the date, so a day in a previous cycle is read against THAT cycle
  // rather than against the current one. Re-deriving it here would work
  // perfectly until she tapped back past a period start — at which point the
  // strip and the card would disagree and neither would look wrong.
  final TtcDayFacts facts = ttcFactsFor(day);
  final fertility = facts.fertility;

  // Cycle day, against the cycle this date actually belongs to.
  final d = DateTime(day.year, day.month, day.day);
  DateTime? openedOn;
  for (final p in CycleStore.instance.periodStarts) {
    if (!p.isAfter(d)) openedOn = p;
  }
  final cycleDay = openedOn == null ? null : d.difference(openedOn).inDays + 1;

  final clinic = !store.behaviour.showsFertilityWindow;

  final logged = log
      .valuesOn(kTtcSymptomTracker, TtcLogStore.dayKey(day))
      .where((v) => v.value > 0)
      .map((v) => v.field)
      .toList();

  final out = <TtcInsightCard>[];

  // ---- 1. the band, when we are entitled to one ---------------------------
  //
  // ⚠️ ABSENT ON A CLINIC-RUN CYCLE. Not "Low", not "unknown" — absent. A band
  // on a cycle a clinician is directing is a second opinion beside theirs.
  if (!clinic && fertility != null) {
    out.add(TtcInsightCard(
      id: 'chance',
      eyebrow: 'CHANCE OF CONCEIVING',
      value: switch (fertility) {
        FertilityLevel.peak => 'Highest',
        FertilityLevel.high => 'High',
        FertilityLevel.medium => 'Medium',
        FertilityLevel.low => 'Low',
      },
      caption: switch (fertility) {
        FertilityLevel.peak || FertilityLevel.high => 'Your fertile days',
        _ => null,
      },
      hue: 42,
      art: TtcInsightArt.level,
      go: TtcInsightGo.window,
    ));
  }

  // ---- 2. where she is ----------------------------------------------------
  if (cycleDay != null) {
    out.add(TtcInsightCard(
      id: 'cycle_day',
      eyebrow: 'CYCLE DAY',
      value: '$cycleDay',
      hue: 268,
      art: TtcInsightArt.number,
      go: TtcInsightGo.cycle,
    ));
  }

  // ---- 3. what she logged, which is what proves we noticed ---------------
  //
  // Discharge first where it is present, because it is the one logged thing
  // that says something about the WINDOW rather than about how she feels.
  final discharge = logged.firstWhere(
      (id) => id.startsWith('disch_') && id != 'disch_none',
      orElse: () => '');
  if (discharge.isNotEmpty) {
    final sym = ttcSymptomById(discharge);
    out.add(TtcInsightCard(
      id: 'discharge',
      eyebrow: 'DISCHARGE',
      value: sym?.label ?? 'Logged',
      caption: discharge == 'disch_eggwhite'
          ? 'The clearest sign the window is close'
          : null,
      hue: 206,
      art: TtcInsightArt.droplet,
      go: TtcInsightGo.window,
    ));
  }

  final bodySymptom = logged.firstWhere(
      (id) =>
          !id.startsWith('disch_') &&
          !id.startsWith('sex_') &&
          !id.startsWith('ov_') &&
          !id.startsWith('pt_') &&
          id != 'all_fine',
      orElse: () => '');
  if (bodySymptom.isNotEmpty) {
    final sym = ttcSymptomById(bodySymptom);
    out.add(TtcInsightCard(
      id: 'symptom',
      eyebrow: (sym?.label ?? 'Logged').toUpperCase(),
      // ⚠️ NOT "WHAT COULD BE CAUSING IT?". We have no per-symptom article, and
      // a card asking that question would open something that does not answer
      // it. This asks a question her own data can answer.
      value: 'Where it falls in your cycle',
      hue: sym?.hue ?? 344,
      art: TtcInsightArt.symptom,
      go: TtcInsightGo.report,
    ));
  }

  // ---- 4. nothing logged, on a day that has actually happened -------------
  //
  // ⚠️ NOT ON A FUTURE DAY. "Nothing yet — how did today feel?" under Tuesday
  // next week is the app asking her to report on something that has not
  // happened. The strip shows six days forward so she can watch the fertile
  // tint arrive; those days are for looking at, not for filling in.
  final now = DateTime.now();
  final isFuture = d.isAfter(DateTime(now.year, now.month, now.day));
  if (logged.isEmpty && !isFuture) {
    out.add(TtcInsightCard(
      id: 'log_prompt',
      eyebrow: 'NOTHING YET',
      // ⚠️ THE TENSE FOLLOWS THE DATE. "How did today feel?" printed under
      // Tuesday last week is the copy-names-a-thing-that-is-wrong failure in
      // miniature: nothing breaks, nothing fails a test, and the screen is
      // confidently talking about the wrong day.
      value: d == DateTime(now.year, now.month, now.day)
          ? 'How did today feel?'
          : 'How did that day feel?',
      caption: 'A few taps. No wrong answers.',
      hue: 160,
      art: TtcInsightArt.log,
      go: TtcInsightGo.logger,
    ));
  }

  // ---- 5. her own rhythm, once there is one -------------------------------
  final lengths = CycleStore.instance.cycleLengths;
  if (lengths.length >= 2) {
    final recent = lengths.length <= 6
        ? lengths
        : lengths.sublist(lengths.length - 6);
    final usual = (recent.reduce((a, b) => a + b) / recent.length).round();
    out.add(TtcInsightCard(
      id: 'cycle_length',
      eyebrow: 'YOUR CYCLE',
      value: '$usual days',
      caption: 'What that means for trying',
      hue: 104,
      art: TtcInsightArt.ring,
      go: TtcInsightGo.cycle,
    ));
  }

  return out;
}

/// What to draw under a date on the day strip: up to two symptoms, plus a count
/// of everything else logged that day.
///
/// ⚠️ THIS IS THE MARKER THE STRIP WAS MISSING, and it was asked for three
/// times before it landed: *"just below the date, it is indicating that a
/// symptom was logged."* The reference puts the actual logged icons under the
/// SELECTED date, capped at two with a "+6", and a single heart under any other
/// day that holds something. That difference is the whole trick — the day you
/// are on shows WHAT, every other day shows only THAT — and it is what stops
/// the strip becoming an unreadable confetti of thirty icons.
///
/// ⚠️ THE SYMPTOMS COME BACK, NOT A GLYPH. The first version returned a
/// `List<String>` of emoji and it had a hole: only the *feelings* group carries
/// one, so a day where she logged cramping and bloating — very common, arguably
/// the most common — returned an empty list and a bare "+2". Handing back the
/// symptom lets the strip draw a mood face where there is one and fall back to
/// the line icon everywhere else.
({List<TtcSymptom> shown, int more}) ttcDayMarkers(DateTime day) {
  final logged = TtcLogStore.instance
      .valuesOn(kTtcSymptomTracker, TtcLogStore.dayKey(day))
      .where((v) => v.value > 0)
      .map((v) => ttcSymptomById(v.field))
      .whereType<TtcSymptom>()
      .toList();
  if (logged.isEmpty) return (shown: const [], more: 0);

  // ⚠️ ANYTHING WITH A FACE GOES FIRST. Given "cramping, happy, bloating", the
  // mood is the one worth the 18 points — an expression reads at a glance from
  // a strip being scrolled past, and a line icon at that size mostly does not.
  //
  // ⚠️ KEYED ON `ttcMoodFor`, NOT ON `emoji`. They currently select the same
  // eight symptoms, so this looks like a distinction without a difference — it
  // is not. `emoji` is data kept for semantics labels; `ttcMoodFor` is what
  // decides whether the strip can DRAW something. Sorting by the field the
  // renderer does not read is how a preference quietly stops matching what is
  // actually on screen.
  final ordered = [
    ...logged.where((s) => ttcMoodFor(s.id) != null),
    ...logged.where((s) => ttcMoodFor(s.id) == null),
  ];
  final shown = ordered.take(2).toList();
  return (shown: shown, more: ordered.length - shown.length);
}

/// Whether anything at all was logged on a day. Drives the small heart.
bool ttcHasAnyLog(DateTime day) => TtcLogStore.instance
    .valuesOn(kTtcSymptomTracker, TtcLogStore.dayKey(day))
    .isNotEmpty;
