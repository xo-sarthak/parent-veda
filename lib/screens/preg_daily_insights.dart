// =============================================================================
//  Daily insights — which cards a pregnancy day earns
// -----------------------------------------------------------------------------
//  The pregnancy half of what ttc_daily_insights.dart does for TTC, built when
//  the pregnancy home took the TTC fold (2026-09-21, docs/PREG-HOME-HERO-
//  PLAN.md). Given a day, what is worth putting under the hero?
//
//  ⚠️ THE POINT IS THAT THE SET CHANGES. A fixed row of the same six cards in
//  the same order every day is a menu wearing a date. So: some cards are there
//  because they are always true of a week (what is forming, the size of a …);
//  some appear only because of something SHE did (a symptom she logged today,
//  a need she has not ticked); some because of where the calendar is (a scan
//  in the next fortnight). Order is by how much the day differs from any other
//  day — her own facts first, the week's facts after.
//
//  ⚠️ EVERY CARD OPENS SOMETHING THAT EXISTS. The wiring gate, applied to
//  content: a card is only added here when its destination is built. What we
//  do not have yet, and would have been a card (kept as a list, not as dead
//  tiles):
//    · "Myth or fact" — three pregnancy reads carry a mythFact opening today
//      (scans, conditions, labour); three is not a daily rotation. Owed.
//    · "Move" — no pregnancy movement set exists (TTC has one). Owed.
//  Both are recorded in docs/STILL-OPEN.md §72.
//
//  ⚠️ NOTHING HERE IS A DIAGNOSIS OR A PREDICTION. "You logged nausea → what
//  helps" opens the symptom's own page, whose copy ends at the doctor line.
//  The size line is a population average ("about"). Nothing computes a number
//  about her.
//
//  ⚠️ THIS FILE STAYS PURE OF NAVIGATION. It returns cards with a `go` and the
//  ids they need; `home_v3_screen.dart` resolves every `go` in one exhaustive
//  switch, so a card kind that goes nowhere is a compile error and not a tile
//  that does nothing on a phone three weeks from now.
// =============================================================================

import '../data/can_i_data.dart';
import '../data/doors/pv_door_data.dart' show PvDoorEntryTile, PvDoorLibrary;
import '../data/doors/pv_door_scans.dart' show kScansDoor;
import '../data/nutrition/nutrition_plate.dart';
import '../data/symptoms/symptom_library.dart';
import '../models/can_i_entry.dart';
import '../models/home_day.dart';
import '../models/read_item.dart';
import '../models/scan_appointment.dart';
import '../models/week_content.dart';
import '../services/nutrition_day_store.dart';
import '../services/scans_store.dart';
import '../services/symptom_store.dart';
import '../ttc/ttc_daily_data.dart' show ttcPickForToday;
import '../data/preg_size_sets.dart';
import '../services/preg_size_set_store.dart';
import 'v2/pv_insight_rail.dart' show PvInsightArt;

/// Where tapping a card goes. Resolved by the screen.
enum PregInsightGo {
  /// The symptom companion, to log how the day felt.
  log,

  /// The symptom she logged — its own page (what helps, when to call).
  symptom,

  /// The Scans & tests door.
  scan,

  /// The scan timeline, where she adds the date of the usual scan for her
  /// week (2026-09-30, "Upcoming tests on the home").
  scanWindow,

  /// What is forming this week — the week sheet (was the week stack until
  /// the user cut that wire on 2026-09-21).
  week,

  /// The size sheet — the baby beside the thing it is the size of.
  size,

  /// The Nutrition door's Today — a need not ticked.
  eat,

  /// An Is it safe? verdict.
  safe,

  /// A read for this week.
  read,
}

/// One card on the pregnancy rail.
class PregInsight {
  const PregInsight({
    required this.id,
    required this.eyebrow,
    required this.value,
    required this.hue,
    required this.art,
    required this.go,
    this.caption,
    this.symptomId,
    this.entry,
    this.read,
    this.needId,
    this.scanId,
  });

  /// Stable, so a test can assert which cards a given day produces.
  final String id;
  final String eyebrow;
  final String value;
  final String? caption;
  final double hue;
  final PvInsightArt art;
  final PregInsightGo go;

  /// Payloads, by `go`. Only the one the destination needs is set.
  final String? symptomId;
  final CanIEntry? entry;
  final ReadItem? read;
  final String? needId;

  /// The scan a [PregInsightGo.scanWindow] card is about.
  final String? scanId;
}

/// A routine scan or test and the weeks it is usually done in.
typedef PregScanWindow = ({String id, String title, int from, int to});

/// The scans and tests the home may remind her of, by id.
///
/// ⚠️ ROUTINE ONLY, AND THAT IS A CLINICAL CHOICE, NOT A GAP. NIPT is an
/// optional private test, a Doppler is done when a doctor advises it, and a
/// Group B Strep swab is not routine in India. A home card about any of them
/// would prompt a test she may not need; they stay on the Scans door, where she
/// reads about them on purpose.
const Set<String> kPregRoutineScans = {
  'blood_tests',
  'dating_scan',
  'nt_scan',
  'anomaly_scan',
  'ogtt',
  'growth_scan',
};

/// The windows, DERIVED from the Scans door's own tiles ("Weeks 18–22"), so
/// the home and the door cannot say two different things. Door order.
List<PregScanWindow> pregScanWindows() {
  final out = <PregScanWindow>[];
  final seen = <String>{};
  final range = RegExp(r'Weeks?\s+(\d+)\s*[–-]\s*(\d+)');
  for (final t in kScansDoor.allTiles) {
    if (t is! PvDoorEntryTile || t.library != PvDoorLibrary.scan) continue;
    if (!kPregRoutineScans.contains(t.entryId) || !seen.add(t.entryId)) continue;
    final m = range.firstMatch(t.meta ?? '');
    if (m == null) continue;
    out.add((id: t.entryId, title: t.title, from: int.parse(m.group(1)!), to: int.parse(m.group(2)!)));
  }
  return out;
}

/// The usual scan for [week], or null when none is due around then.
PregScanWindow? pregScanWindowFor(int week) {
  for (final w in pregScanWindows()) {
    if (week >= w.from && week <= w.to) return w;
  }
  return null;
}

/// The cards [date] earns.
///
/// [day] is the pregnancy day the date maps to (1–280), [week] its week,
/// [homeDay] the day's authored content (null while loading), [weekContent]
/// the week's, [reads] the week's recommended reads (the first becomes the
/// read card), [today] the screen's idea of today — passed in, not read from
/// the clock, for the same reason the strip takes it.
List<PregInsight> pregInsightsFor({
  required DateTime date,
  required DateTime today,
  required int day,
  required int week,
  required HomeDay? homeDay,
  required WeekContent? weekContent,
  required List<ReadItem> reads,
}) {
  final cards = <PregInsight>[];
  final isToday = date == today;
  final isFuture = date.isAfter(today);

  // ---- 1. What she logged, or the invitation to ----------------------------
  //
  // Flo puts "Log your symptoms" first on the rail, and it is the right
  // place: the one card that is an action rather than a fact. On a day she
  // has logged something, the log card gives way to what she logged — the
  // rail proves the app noticed. The invitation is today-only: the companion
  // logs against the clock, and a card that says "how did Tuesday feel?" and
  // then writes the answer to Thursday is the silent corruption TTC has
  // already fixed once.
  final key = SymptomStore.dateKey(date);
  final logged = {
    for (final l in SymptomStore.instance.logs)
      if (l.dateKey == key) l.symptomId
  };
  if (logged.isNotEmpty) {
    for (final id in logged.take(2)) {
      // ⚠️ `symptomById`, NOT `kSymptoms`. The door logs from the 33-strong
      // library; the old seed list is 12 of them, so a card for anything she
      // logged from the other 21 silently did not appear (2026-09-22).
      final s = symptomById(id);
      if (s == null) continue;
      cards.add(PregInsight(
        id: 'symptom_$id',
        eyebrow: 'You logged',
        value: s.name.en,
        caption: 'What helps',
        hue: 344,
        art: PvInsightArt.symptom,
        go: PregInsightGo.symptom,
        symptomId: id,
      ));
    }
  } else if (isToday) {
    cards.add(const PregInsight(
      id: 'log',
      eyebrow: 'How are you today?',
      value: 'Log how today feels',
      hue: 344,
      art: PvInsightArt.log,
      go: PregInsightGo.log,
    ));
  }

  // ---- 2. A scan in the next fortnight -------------------------------------
  //
  // This is the "Coming up" card folded into the rail: it was a row of its
  // own between the hero and the doors, and it is an insight — the one
  // time-sensitive thing on the page. Fourteen days, not "the next one ever":
  // a scan in November is not today's business in September.
  final next = _nextAppointment(today);
  if (next != null && next.days <= 14) {
    cards.add(PregInsight(
      id: 'scan',
      eyebrow: next.days == 0 ? 'Today' : 'Coming up',
      value: next.a.title,
      caption: next.days == 0
          ? (next.a.time.isEmpty ? 'Today' : next.a.time)
          : next.days == 1
              ? 'Tomorrow'
              : 'In ${next.days} days',
      hue: 206,
      art: PvInsightArt.scan,
      go: PregInsightGo.scan,
    ));
  } else if (!isFuture && _hasNoUpcoming(today)) {
    // ⚠️ NOTHING BOOKED, SO THE WINDOW SHE IS IN (2026-09-30, the gap
    // analysis, "Upcoming tests on the home"): "If she has not booked, the
    // home says nothing about the scan window she is in." Only when she has
    // no upcoming appointment at all; one booked further out means she knows.
    // "Usually", never "you need": her doctor decides which tests she has.
    final w = pregScanWindowFor(week);
    if (w != null) {
      cards.add(PregInsight(
        id: 'scan_window_${w.id}',
        eyebrow: 'Usually around now',
        value: w.title,
        caption: 'Weeks ${w.from} to ${w.to} · Add my date',
        hue: 206,
        art: PvInsightArt.scan,
        go: PregInsightGo.scanWindow,
        scanId: w.id,
      ));
    }
  }

  // ---- 3. What is forming this week ----------------------------------------
  //
  // The "learning" line that used to sit on the hero photograph at 26pt. It
  // is a card now, so the hero can say the week and the size and nothing else.
  final learning = homeDay?.babyLearning.en.trim() ?? '';
  if (learning.isNotEmpty) {
    cards.add(PregInsight(
      id: 'forming',
      eyebrow: 'This week',
      value: learning,
      hue: 24,
      art: PvInsightArt.baby,
      go: PregInsightGo.week,
    ));
  }

  // ---- 4. The size of a … --------------------------------------------------
  //
  // In the set she chose (fruit & veg · kitchen · sweets); the Western fruit
  // from the week content only when the set has no entry. A sweet compares
  // by weight from week 14 and its eyebrow says so.
  final item = weekContent == null
      ? null
      : pregSizeOrFallback(
          week, PregSizeSetStore.instance.set, weekContent.snapshot.fruit.en);
  if (item != null) {
    final len = weekContent!.snapshot.length.en.trim();
    final wt = weekContent.snapshot.weight.en.trim();
    cards.add(PregInsight(
      id: 'size',
      eyebrow: item.eyebrow,
      value: item.name,
      caption: [len, wt].where((s) => s.isNotEmpty).join(' · '),
      hue: 104,
      art: PvInsightArt.size,
      go: PregInsightGo.size,
    ));
  }

  // ---- 5. One thing to eat -------------------------------------------------
  //
  // The first of the five needs she has not ticked on this date, in the order
  // the plate meets them. Not on a future date: she cannot have eaten it yet,
  // and the Nutrition day store keys by date so a tick lands on the right day.
  if (!isFuture) {
    final store = NutritionDayStore.instance;
    final open = kPlateNeeds.where((n) => !store.ticked(date, n.id)).toList();
    if (open.isNotEmpty) {
      final n = open.first;
      cards.add(PregInsight(
        id: 'eat_${n.id}',
        eyebrow: 'Eat today',
        value: n.label,
        caption: _firstFoods(n.line),
        hue: 104,
        art: PvInsightArt.meal,
        go: PregInsightGo.eat,
        needId: n.id,
      ));
    } else {
      cards.add(const PregInsight(
        id: 'eat_done',
        eyebrow: 'Eat today',
        value: 'All five ticked',
        caption: 'Your plate',
        hue: 104,
        art: PvInsightArt.meal,
        go: PregInsightGo.eat,
      ));
    }
  }

  // ---- 6. Is it safe? — one a day, stable ----------------------------------
  //
  // The "myth" slot, with data we actually have: hundreds of things people
  // ask whether they can eat, drink, take or do. Picked by the day of the
  // year, so yesterday's card is genuinely yesterday's.
  if (kCanIEntries.isNotEmpty) {
    final e = ttcPickForToday(kCanIEntries, now: date, offset: 5);
    cards.add(PregInsight(
      id: 'safe_${e.id}',
      eyebrow: 'Is it safe?',
      value: e.name.en,
      hue: 136,
      art: PvInsightArt.question,
      go: PregInsightGo.safe,
      entry: e,
    ));
  }

  // ---- 7. A read for this week ---------------------------------------------
  if (reads.isNotEmpty) {
    final r = reads.first;
    cards.add(PregInsight(
      id: 'read_${r.id}',
      eyebrow: 'Read',
      value: r.title.en,
      hue: 268,
      art: PvInsightArt.note,
      go: PregInsightGo.read,
      read: r,
    ));
  }

  return cards;
}

/// The soonest upcoming appointment on or after [today], and how far off.
({Appointment a, int days})? _nextAppointment(DateTime today) {
  for (final a in ScansStore.instance.appointments) {
    if (a.status != 'upcoming') continue;
    final d = DateTime.tryParse(a.dateIso);
    if (d == null) continue;
    final diff = DateTime(d.year, d.month, d.day).difference(today).inDays;
    if (diff < 0) continue;
    return (a: a, days: diff); // sorted soonest-first by the store
  }
  return null;
}

/// True when no appointment lies ahead at all.
bool _hasNoUpcoming(DateTime today) => _nextAppointment(today) == null;

/// The first two foods from a need's line — "Dal, greens" — as the caption.
String _firstFoods(String line) {
  final head = line.split(RegExp('[—.]')).first;
  final parts = head.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
  return parts.take(2).join(', ');
}
