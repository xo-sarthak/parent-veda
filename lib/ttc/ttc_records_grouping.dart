// =============================================================================
//  Records, gathered by test rather than by date
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS THE WHOLE ARGUMENT OF THE REDESIGN, AND IT IS ONE FUNCTION.
//
//  The screen was a flat, date-ordered list, and a list cannot answer the
//  question a repeated test exists to answer. AMH from two years ago and AMH
//  from last month sat as unrelated cards, possibly screens apart, and the one
//  thing worth knowing — which direction it moved — was invisible.
//
//  Grouping makes it visible on the row, before anything is tapped: "3
//  readings · 1.2 ng/mL · first was 2.1, Mar 2025".
//
//  ⚠️ AND A GROUP OF ONE COSTS NOTHING, which is the objection that nearly
//  stopped this. Fifteen tests with three repeats sounds like twelve groups of
//  one, and twelve groups of one sounds worse than a list — but a group of one
//  renders as an ordinary row with its value and its date, exactly as it did
//  before. The grouping is free where it does not apply and pays where it does.
//
//  ⚠️ IT NEVER INTERPRETS. Everything here is arithmetic on her own readings
//  and the order they arrived in. No range, no verdict, no comparison against
//  anybody else's numbers — see the head of `ttc_records_screen.dart`.
// =============================================================================

import 'ttc_records_store.dart';
import 'ttc_tests_data.dart';

/// One test, and every reading of it.
class TtcRecordGroup {
  const TtcRecordGroup(
      {required this.key, required this.readings, String? testKey})
      : testKey = testKey ?? key;

  /// The group's identity: [testKey] for hers, `partner:` + [testKey] for his.
  ///
  /// ⚠️ ONE GROUP PER TEST PER PERSON (2026-09-29). The key used to be the
  /// test alone, so her TSH and his TSH (thyroid, vitamin D, B12 and HbA1c
  /// are tests both of them may have) fell into ONE group: the row took the
  /// newest reading's owner, the "You / Partner" filter hid the other
  /// person's result under it, and the trend page did arithmetic across two
  /// bodies ("0.9 lower over 17 months" from her 2.1 to his 1.2). A reading
  /// only has a direction against the same person's earlier reading, so the
  /// person is part of the identity. Hers keep the bare key, so a link or a
  /// test that names `'amh'` still finds her group.
  final String key;

  /// `testId` where the record has one, the trimmed lower-cased label
  /// otherwise. The same for both people; coverage matches on this.
  ///
  /// ⚠️ TWO KEYS BECAUSE ONLY SOME RECORDS CAME FROM THE LIBRARY. A result
  /// added from the tests screen carries a `testId`; one typed in by hand
  /// carries only what she called it. Grouping on the id alone would file
  /// "AMH" typed by hand apart from "AMH" picked from the list, which is the
  /// exact split this screen exists to close.
  final String testKey;

  /// Newest first.
  final List<TtcRecord> readings;

  TtcRecord get latest => readings.first;
  TtcRecord get oldest => readings.last;
  int get count => readings.length;
  bool get repeated => readings.length > 1;

  /// The name to print. The most recent spelling wins, because it is the one
  /// she used last.
  String get label => latest.label;

  /// Whose it is. Every reading in a group is one person's (see [key]).
  /// Kept for revert (2026-09-29), the note from when a group could hold
  /// both: "A test belongs to one person in practice, and where records
  /// disagree the most recent one decides."
  bool get forPartner => latest.forPartner;

  /// True when nothing was ever typed, only photographed.
  bool get valueless => readings.every((r) => r.value.trim().isEmpty);
}

/// Every record, gathered by test and ordered by how recently each was seen.
///
/// `resultsOnly` keeps the Reports tile's existing promise: the same folder,
/// narrowed to entries that came from the test library. It is a filter on the
/// records, applied before grouping, so a group is never half-hidden.
List<TtcRecordGroup> ttcGroupedRecords({bool resultsOnly = false}) {
  final byKey = <String, List<TtcRecord>>{};
  final testKeys = <String, String>{};
  for (final r in TtcRecordsStore.instance.records) {
    if (resultsOnly && r.testId == null) continue;
    final testKey = (r.testId ?? r.label.trim().toLowerCase());
    // Kept for revert (2026-09-29, one group per person): final key = testKey;
    final key = r.forPartner ? 'partner:$testKey' : testKey;
    testKeys[key] = testKey;
    byKey.putIfAbsent(key, () => []).add(r);
  }

  final groups = [
    for (final e in byKey.entries)
      TtcRecordGroup(
        key: e.key,
        testKey: testKeys[e.key],
        readings: e.value..sort((a, b) => b.takenOn.compareTo(a.takenOn)),
      ),
  ];

  // ⚠️ ORDERED BY THE LATEST READING, NOT BY NAME. Alphabetical would be
  // stable and useless: the thing she added this morning would sit under H.
  groups.sort((a, b) => b.latest.takenOn.compareTo(a.latest.takenOn));
  return groups;
}

/// What a first fertility check usually covers, against what she has filed.
///
/// ⚠️ "NOT ADDED", NEVER "MISSING", AND THE DIFFERENCE IS THE WHOLE RULE.
/// "Missing" says her workup is incomplete, which is a judgement about the
/// clinician looking after her and is not ours to make. "Not added" says this
/// app does not have it, which is a fact about her filing and is exactly what
/// this screen knows.
///
/// The list is `ttcTests` — already written, already clinically reviewed, and
/// already the thing the tests library shows her. Nothing new is being claimed
/// here; it is the same list, counted.
class TtcCoverage {
  const TtcCoverage({required this.added, required this.notAdded});

  final List<TtcTest> added;
  final List<TtcTest> notAdded;

  int get total => added.length + notAdded.length;
}

TtcCoverage ttcRecordCoverage() {
  final groups = ttcGroupedRecords();
  final added = <TtcTest>[];
  final notAdded = <TtcTest>[];
  for (final t in ttcTests) {
    (ttcCoverageGroup(t, groups) != null ? added : notAdded).add(t);
  }
  return TtcCoverage(added: added, notAdded: notAdded);
}

/// The filed group that answers [test] on the first-check list, or null.
///
/// ⚠️ ONLY THE PERSON THE TEST IS FOR (2026-09-29). The list is a first
/// check's tests, his semen analysis and her AMH; his thyroid result does not
/// tick her thyroid line. A hand-typed "AMH" counts against the library's
/// AMH: matched on the whole name or on the leading word, because the
/// library's names carry a parenthetical the reader does not type ("TSH
/// (thyroid)", "HSG (tube test)"). The whole-name match is new: a typed
/// "semen analysis" did not count, because only "semen" did.
TtcRecordGroup? ttcCoverageGroup(TtcTest test, List<TtcRecordGroup> groups) {
  final name = test.name.toLowerCase();
  for (final g in groups) {
    if (g.forPartner != test.forHim) continue;
    if (g.testKey == test.id ||
        g.testKey == name ||
        g.testKey == name.split(' ').first) {
      return g;
    }
  }
  return null;
}

// Kept for revert (2026-09-29, coverage per person, via ttcCoverageGroup):
// TtcCoverage ttcRecordCoverage() {
//   final groups = ttcGroupedRecords();
//   bool have(TtcTest test) => groups.any((g) =>
//       g.key == test.id ||
//       g.key == test.name.toLowerCase().split(' ').first);
//   final added = <TtcTest>[];
//   final notAdded = <TtcTest>[];
//   for (final t in ttcTests) {
//     (have(t) ? added : notAdded).add(t);
//   }
//   return TtcCoverage(added: added, notAdded: notAdded);
// }

/// "1.2 ng/mL", or just the value where there is no unit.
String ttcRecordValue(TtcRecord r) =>
    r.unit.trim().isEmpty ? r.value.trim() : '${r.value.trim()} ${r.unit.trim()}';

/// The signed difference between two readings, as words, in her own units.
///
/// ⚠️ ARITHMETIC ON HER OWN TWO NUMBERS AND NOTHING ELSE. "0.4 lower" is a
/// description of what she recorded. "0.4 lower than normal" would be a
/// comparison against a population, which is the line this screen does not
/// cross — no range, no band, no colour, no verdict.
///
/// Returns null wherever the arithmetic is not honest: a text result, a
/// photographed result with no number, or two readings in different units.
String? ttcReadingChange(TtcRecord newer, TtcRecord older) {
  final a = double.tryParse(newer.value.trim());
  final b = double.tryParse(older.value.trim());
  if (a == null || b == null) return null;
  if (newer.unit.trim() != older.unit.trim()) return null;
  final diff = a - b;
  if (diff == 0) return 'unchanged';
  final size = diff.abs();
  final shown = size == size.roundToDouble()
      ? size.toStringAsFixed(0)
      : size.toStringAsFixed(1);
  return '$shown ${diff > 0 ? 'higher' : 'lower'}';
}

/// "9 months later", "3 weeks later" — the gap between two readings.
String ttcReadingGap(DateTime newer, DateTime older) {
  final days = newer.difference(older).inDays;
  if (days < 14) return '$days ${days == 1 ? 'day' : 'days'} later';
  if (days < 60) {
    final w = (days / 7).round();
    return '$w ${w == 1 ? 'week' : 'weeks'} later';
  }
  final m = (days / 30.44).round();
  if (m < 24) return '$m ${m == 1 ? 'month' : 'months'} later';
  final y = (days / 365.25).round();
  return '$y ${y == 1 ? 'year' : 'years'} later';
}
