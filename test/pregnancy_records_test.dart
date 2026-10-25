// =============================================================================
//  R1: one record per pregnancy, "Kept for you" (2026-10-25)
// -----------------------------------------------------------------------------
//  Holds: what an install from before R1 already implies (never asked), the
//  windows that say whose a dated record is, a new pregnancy starting clean
//  while the old one keeps its things, the undo of both moves, and deleting a
//  pregnancy only at her asking. Plus the prefs key two stores shared.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/models/bump_photo.dart';
import 'package:parentveda/screens/pregnancy/pregnancy_kept_screen.dart';
import 'package:parentveda/services/bump_store.dart';
import 'package:parentveda/services/daily_store.dart';
import 'package:parentveda/services/journal_key_split.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pregnancy_archive.dart';
import 'package:parentveda/services/pregnancy_records.dart';

DateTime d(int y, int m, int day) => DateTime(y, m, day);

BumpPhoto _photo(String id, DateTime on, int week) =>
    BumpPhoto(id: id, imageUrl: '', weekNumber: week, date: on);

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  group('backfill: what an install already implies, never asked', () {
    test('a pregnancy going on: one ongoing record, 280 days before the due date', () {
      final r = backfillPregnancies(
        confirmedDays: const [],
        dueDate: d(2027, 3, 1),
        stage: LifeStage.pregnancy,
        children: const [],
      );
      expect(r, hasLength(1));
      expect(r.single.outcome, PregnancyOutcome.ongoing);
      expect(r.single.startedOn, d(2027, 3, 1).subtract(const Duration(days: 280)));
      expect(r.single.id, PregnancyRecord.idFor(r.single.startedOn));
    });

    test('a recorded loss ends it as a loss', () {
      final r = backfillPregnancies(
        confirmedDays: const [],
        dueDate: d(2027, 3, 1),
        stage: LifeStage.pregnancy,
        lossAt: d(2026, 8, 10),
        children: const [],
      );
      expect(r.single.outcome, PregnancyOutcome.loss);
      expect(r.single.endedOn, d(2026, 8, 10));
    });

    test('a child born in it ends it as a birth, with that child', () {
      final r = backfillPregnancies(
        confirmedDays: const [],
        dueDate: d(2026, 6, 1),
        stage: LifeStage.parenting,
        children: [(id: 'child_1', dob: d(2026, 5, 25))],
      );
      expect(r.single.outcome, PregnancyOutcome.birth);
      expect(r.single.childId, 'child_1');
    });

    test('a pregnancy the story remembers, then the one going on now', () {
      final r = backfillPregnancies(
        confirmedDays: [d(2025, 11, 1), d(2026, 7, 1)],
        dueDate: d(2027, 2, 20),
        stage: LifeStage.pregnancy,
        lossAt: d(2026, 1, 15),
        children: const [],
      );
      expect(r, hasLength(2), reason: 'the confirmation in July and the due date are one pregnancy');
      expect(r.first.outcome, PregnancyOutcome.loss);
      expect(r.last.outcome, PregnancyOutcome.ongoing);
      expect(r.last.dueDate, d(2027, 2, 20), reason: "the due date's start wins");
    });

    test('a due date worked out while trying is not a pregnancy', () {
      expect(
          backfillPregnancies(
            confirmedDays: const [],
            dueDate: d(2027, 3, 1),
            stage: LifeStage.tryingToConceive,
            children: const [],
          ),
          isEmpty);
    });
  });

  group('windows: whose a dated record is', () {
    final p1 = PregnancyRecord(id: 'a', startedOn: d(2025, 1, 1), outcome: PregnancyOutcome.loss);
    final p2 = PregnancyRecord(id: 'b', startedOn: d(2025, 6, 1));

    test('they partition time: the first owns before it, the latest after it', () {
      final w1 = pregnancyWindowOf(p1, [p2, p1]);
      final w2 = pregnancyWindowOf(p2, [p2, p1]);
      expect(w1.holds(d(2024, 12, 1)), isTrue);
      expect(w1.holds(d(2025, 5, 31)), isTrue);
      expect(w1.holds(d(2025, 6, 1)), isFalse);
      expect(w2.holds(d(2025, 6, 1)), isTrue);
      expect(w2.holds(d(2030, 1, 1)), isTrue);
    });

    test('no pregnancy yet: everything is shown', () {
      PregnancyRecords.instance.debugReset();
      expect(PregnancyRecords.instance.inCurrent(d(2000, 1, 1)), isTrue);
    });

    test("a second pregnancy's bump opens clean; the first one's is kept with it", () {
      PregnancyRecords.instance.debugReset(rows: [p1, p2]);
      BumpStore.instance.debugSeed([
        _photo('old', d(2025, 3, 1), 12),
        _photo('new', d(2025, 9, 1), 12),
      ]);
      expect(BumpStore.instance.photos.map((p) => p.id), ['new']);
      expect(BumpStore.instance.photosForWeek(12).map((p) => p.id), ['new'],
          reason: 'both are week 12; only this pregnancy\'s shows');
      final kept = PregnancyRecords.instance.windowOf(p1);
      expect(BumpStore.instance.photosIn(kept).map((p) => p.id), ['old']);
      expect(PregnancyRecords.instance.kept.map((r) => r.id), ['a']);
    });
  });

  group('the moves', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      PregnancyRecords.instance.debugReset();
    });

    test('a loss ends the pregnancy, its undo carries it on', () async {
      final recs = PregnancyRecords.instance;
      recs.debugReset(rows: [PregnancyRecord(id: 'a', startedOn: d(2026, 1, 1))]);
      await recs.end(PregnancyOutcome.loss, on: d(2026, 3, 1));
      expect(recs.current, isNull);
      expect(recs.kept.single.outcome, PregnancyOutcome.loss);
      await recs.undoEnd();
      expect(recs.current?.id, 'a');
      expect(recs.kept, isEmpty);
    });

    test('a new pregnancy seals the one before and starts after it; its undo gives the things back', () async {
      final recs = PregnancyRecords.instance;
      recs.debugReset(rows: [
        PregnancyRecord(
            id: 'a', startedOn: d(2026, 1, 1), outcome: PregnancyOutcome.loss, endedOn: d(2026, 3, 1)),
      ]);
      final made = await recs.startNew(due: d(2026, 12, 1), today: d(2026, 4, 1));
      final old = recs.byId('a')!;
      expect(old.sealed, isTrue);
      expect(old.archive.keys, containsAll(PregnancyArchive.partKeys));
      expect(recs.current?.id, made.id);
      expect(made.startedOn.isAfter(old.endedOn!), isTrue,
          reason: 'the old window must not slide into the new pregnancy');
      await recs.undoStart(made);
      expect(recs.current, isNull);
      expect(recs.byId('a')!.sealed, isFalse, reason: 'its things went back to the live stores');
    });

    test('confirming the same pregnancy again only re-dates it', () async {
      final recs = PregnancyRecords.instance;
      final a = await recs.startNew(due: d(2027, 1, 1));
      final b = await recs.startNew(due: d(2027, 1, 8));
      expect(b.id, a.id);
      expect(recs.all, hasLength(1));
      expect(b.dueDate, d(2027, 1, 8));
    });

    test('deleting a pregnancy removes its records and itself, and only at her asking', () async {
      final recs = PregnancyRecords.instance;
      final p1 = PregnancyRecord(
          id: 'a', startedOn: d(2025, 1, 1), outcome: PregnancyOutcome.loss, endedOn: d(2025, 3, 1),
          archive: {'sealed_at': 'x'});
      final p2 = PregnancyRecord(id: 'b', startedOn: d(2025, 6, 1));
      recs.debugReset(rows: [p1, p2]);
      BumpStore.instance.debugSeed([
        _photo('old', d(2025, 2, 1), 8),
        _photo('new', d(2025, 9, 1), 14),
      ]);
      await DailyStore.instance.init();
      await PregnancyArchive.deletePregnancy(p1);
      expect(recs.kept, isEmpty);
      expect(recs.byId('a'), isNull);
      expect(BumpStore.instance.photos.map((p) => p.id), ['new']);
      expect(BumpStore.instance.photosIn(PregnancyWindow.all).map((p) => p.id), ['new']);
      expect(recs.windowOf(p2).from, d(2025, 6, 1),
          reason: 'a removed pregnancy still bounds the windows');
    });
  });

  group('the words', () {
    test("a pregnancy's name: the child's, or the months, never a loss named", () {
      final r = PregnancyRecord(
          id: 'a', startedOn: d(2026, 2, 1), outcome: PregnancyOutcome.loss, endedOn: d(2026, 6, 3));
      expect(pregnancyKeptTitle(r, children: const []), 'Pregnancy, March to June 2026');
      final same = PregnancyRecord(
          id: 'b', startedOn: d(2026, 2, 1), outcome: PregnancyOutcome.loss, endedOn: d(2026, 3, 20));
      expect(pregnancyKeptTitle(same, children: const []), 'Pregnancy, March 2026');
    });

    test('the delete names what goes', () {
      expect(
        pregnancyDeleteSummary(photos: 14, journal: 1, notes: 0, letters: 6, recordings: 0, other: 3),
        'This deletes 14 bump photos, 1 journal entry, 6 letters and everything else you logged.',
      );
      expect(
        pregnancyDeleteSummary(photos: 0, journal: 0, notes: 0, letters: 0, recordings: 0, other: 0),
        'This pregnancy has nothing saved in it.',
      );
    });
  });

  group('wiring', () {
    test('every move tells the record', () {
      final moves = _code('lib/services/stage_moves.dart');
      expect(moves, contains('.end(PregnancyOutcome.loss'));
      expect(moves, contains('.end(PregnancyOutcome.birth'));
      expect(moves, contains('.undoEnd()'));
      final t = _code('lib/ttc/ttc_transition.dart');
      expect(t.indexOf('PregnancyRecords.instance\n        .startNew('), greaterThan(0));
      expect(t.indexOf('.startNew('), lessThan(t.indexOf('await ctrl.setDueDate(due,')),
          reason: 'the record starts before the due date moves');
      expect(t, contains('.undoStart(made)'));
      expect(_code('lib/services/pregnancy_controller.dart'), contains('.dueDateSet('));
      expect(_code('lib/main.dart'), contains('PregnancyRecords.instance.load()'));
    });

    test('every dated pregnancy store reads its window', () {
      for (final f in [
        'bump_store.dart',
        'symptom_store.dart',
        'tools_store.dart',
        'memory_store.dart',
        'daily_store.dart',
        'journal_store.dart',
        'scans_store.dart',
        'father_journal_store.dart',
      ]) {
        expect(_code('lib/services/$f'), contains('inCurrent('), reason: f);
      }
      expect(_code('lib/data/garbh_rebuild_data.dart'), contains('inCurrent('));
    });

    test('the undated stores are sealed', () {
      expect(PregnancyArchive.partKeys, [
        'hb', 'hb2', 'birth_plan', 'rfb_ctx', 'pv_checklists', 'journey_dates',
        'scan_reports', 'completed_scans', 'days',
      ]);
    });

    test('Kept for you is in the family sheet and in You, never in the switch', () {
      expect(_code('lib/screens/v2/pv_family_switch.dart'), contains("group('Kept for you')"));
      expect(_code('lib/screens/profile/pv_you_content.dart'), contains('_keptPregnancies()'));
      final pure = _code('lib/screens/v2/pv_family_switch.dart');
      final fn = pure.substring(pure.indexOf('List<FamilyProfile> familyProfilesFrom('),
          pure.indexOf('List<FamilyProfile> familyProfiles()'));
      expect(fn, isNot(contains('PregnancyRecords')), reason: 'never a switchable profile');
    });
  });

  group('the prefs key two stores shared (R1 step 0)', () {
    test('a journal entry has a type; a weekly note does not', () {
      final s = splitJournalRows([
        {'id': '1', 'type': 'memory', 'title': 'x'},
        {'id': '2', 'week': 12, 'source': 'card', 'text': 'y'},
      ]);
      expect(s.journal, hasLength(1));
      expect(s.notes, hasLength(1));
    });

    test('the split moves the notes to their own key, once', () async {
      SharedPreferences.setMockInitialValues({
        kSharedJournalKey: jsonEncode([
          {'id': '1', 'type': 'memory'},
          {'id': '2', 'week': 12, 'source': 'card'},
        ]),
      });
      final prefs = await SharedPreferences.getInstance();
      await splitSharedJournalKey(prefs);
      expect(jsonDecode(prefs.getString(kSharedJournalKey)!), hasLength(1));
      expect(jsonDecode(prefs.getString(kWeeklyNotesKey)!), hasLength(1));
    });

    test('no two stores cache under one key', () {
      final keys = <String, String>{};
      final dup = <String>[];
      final decl = RegExp(r"static const (?:String )?_?[A-Za-z]*[kK]ey[A-Za-z0-9]* = '([^']+)'");
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        for (final m in decl.allMatches(_code(f.path))) {
          final k = m.group(1)!;
          // Read once, never written: the old TTC journal's questions.
          if (k == 'ttc_journal') continue;
          final was = keys[k];
          if (was != null && was != f.path) dup.add('$k: $was, ${f.path}');
          keys[k] = f.path;
        }
      }
      expect(dup, isEmpty);
    });
  });
}
