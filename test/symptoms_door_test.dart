// =============================================================================
//  The Symptoms door — 2026-09-22
// -----------------------------------------------------------------------------
//  docs/SYMPTOMS-DOOR-PLAN.md, built in the door language. These pin:
//    · the library: 33 ordinary symptoms, each with tips and a doctor line,
//      each in one of six areas; the urgent five are NOT in it
//    · the week ranking leads with what peaks this week
//    · the ten questions: four "now", their flag, every one a read whose
//      opening is the verdict
//    · the store's day verbs: log, strengthen, remove, count the week
//    · the check-in: one tap logs mild, the next tap opens the strength
//      sheet, "What helps" appears for what she logged, a day ahead does
//      not log
//    · the week grid and the note she sends
//    · the door is registered, five tabs, the flag on Talk only, every tile
//      resolves
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/doors/pv_door_symptoms.dart';
import 'package:parentveda/data/reads/symptom_reads.dart';
import 'package:parentveda/data/symptom_data.dart';
import 'package:parentveda/data/symptoms/symptom_library.dart';
import 'package:parentveda/data/symptoms/symptom_normal.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/screens/search/pv_search_screen.dart';
import 'package:parentveda/screens/symptoms/door/symptoms_today_body.dart';
import 'package:parentveda/screens/symptoms/door/symptoms_week_body.dart';
import 'package:parentveda/screens/symptoms/door/symptoms_widgets.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/symptom_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('the library', () {
    test('thirty-three ordinary symptoms, none urgent, ids unique', () {
      expect(kSymptomLibrary.length, 33);
      expect(kSymptomLibrary.any((s) => s.urgent), isFalse);
      expect(kSymptomLibrary.map((s) => s.id).toSet().length, 33);
      expect(kSymptomUrgent.length, 5);
    });

    test('every entry says how common, why, three things that help, and when to call', () {
      for (final s in kSymptomLibrary) {
        expect(s.commonness.en, isNotEmpty, reason: s.id);
        expect(s.why.en, isNotEmpty, reason: s.id);
        // Baby hiccups, from the old set, has one tip — it needs none.
        expect(s.tips.length, greaterThanOrEqualTo(s.id == 'babyHiccups' ? 1 : 3), reason: s.id);
        expect(s.doctorGuidance.en, isNotEmpty, reason: s.id);
        expect(s.trimesters, isNotEmpty, reason: s.id);
      }
    });

    test('every area has symptoms, and every peak week names a real symptom', () {
      for (final a in SymptomArea.values) {
        expect(symptomsInArea(a), isNotEmpty, reason: a.name);
      }
      for (final id in kSymptomPeakWeeks.keys) {
        expect(symptomById(id), isNotNull, reason: id);
        final (from, to) = kSymptomPeakWeeks[id]!;
        expect(from, lessThanOrEqualTo(to), reason: id);
      }
    });

    test('the week ranking leads with what peaks this week', () {
      final w8 = symptomsCommonAt(8).take(8).map((s) => s.id).toList();
      expect(w8, contains('nausea'));
      expect(w8, contains('fatigue'));
      expect(w8, isNot(contains('braxtonHicks')));
      final w34 = symptomsCommonAt(34).take(8).map((s) => s.id).toList();
      expect(w34, contains('heartburn'));
      expect(w34, contains('braxtonHicks'));
      expect(w34, isNot(contains('nausea')));
      // Stable: the same call gives the same order.
      expect(symptomsCommonAt(20).map((s) => s.id).toList(), symptomsCommonAt(20).map((s) => s.id).toList());
    });
  });

  group('is this normal?', () {
    test('ten questions, four now, their flag', () {
      expect(kNormalQuestions.length, 10);
      final now = kNormalQuestions.where((q) => q.verdict == NormalVerdict.now).map((q) => q.id).toList();
      expect(now, containsAll(['bleeding', 'movement', 'fluid', 'contractions']));
      expect(now.length, 4);
      expect(kSymptomsUrgentFlag.lines.length, 5);
      for (final q in kNormalQuestions) {
        expect(q.doNow, isNotEmpty, reason: q.id);
        expect(q.whenItChanges, isNotEmpty, reason: q.id);
      }
    });

    test('every question is a read whose opening is the verdict', () {
      for (final q in kNormalQuestions) {
        final r = pvReadFromNormal(q);
        expect(r.sections.first.callout, isNotNull, reason: q.id);
        expect(r.sections.first.callout!.title.en, q.verdict.word);
        expect(symptomReadById(r.id), isNotNull);
      }
    });
  });

  group('reads', () {
    test('every symptom is a read with help and the doctor line, resolvable by id', () {
      for (final s in kSymptomLibrary) {
        final r = pvReadFromSymptom(s);
        expect(r.sections.first.bullets, isNotEmpty, reason: s.id);
        expect(r.whenToSeeSomeone.body.en, s.doctorGuidance.en);
        expect(symptomReadById(r.id)?.id, r.id);
        for (final n in r.readNext) {
          expect(symptomReadById(n), isNotNull, reason: '${s.id} → $n');
        }
      }
    });
  });

  group('the store', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SymptomStore.instance.init();
    });

    test('log, strengthen, remove, count', () async {
      final store = SymptomStore.instance;
      final today = _dayOnly(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));
      await store.setOn(today, 'nausea', 'mild');
      expect(store.severityOn(today, 'nausea'), 'mild');
      await store.setOn(today, 'nausea', 'strong');
      expect(store.severityOn(today, 'nausea'), 'strong');
      expect(store.logsOn(today).length, 1, reason: 'one log per symptom per day');
      await store.setOn(yesterday, 'nausea', 'mild');
      await store.setOn(yesterday, 'heartburn', 'moderate');
      final counts = store.weekCounts(today);
      expect(counts.first.symptomId, 'nausea');
      expect(counts.first.days, 2);
      expect(store.daysLoggedInWeek(today), 2);
      await store.unlogOn(today, 'nausea');
      expect(store.severityOn(today, 'nausea'), isNull);
      expect(symptomPatternLine(store.weekCounts(today)), contains('Nausea on 1 of the last 7 days'));
    });
  });

  group('the check-in', () {
    late PregnancyController c;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SymptomStore.instance.init();
      for (final l in SymptomStore.instance.logs.toList()) {
        await SymptomStore.instance.unlogOn(DateTime.parse(l.dateKey), l.symptomId);
      }
      c = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 140)));
    });

    Future<void> pump(WidgetTester tester, Widget child) async {
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child))));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    }

    testWidgets('one tap logs mild; the next opens the strength sheet; help appears', (tester) async {
      await pump(tester, SymptomsTodayBody(pregnancy: c));
      expect(find.text('COMMON IN WEEK 20'), findsOneWidget);
      expect(find.textContaining('Tap a symptom above'), findsOneWidget);
      final first = symptomsCommonAt(20).first;
      await tester.tap(find.byKey(ValueKey('sym_tile_${first.id}')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(SymptomStore.instance.severityOn(_dayOnly(DateTime.now()), first.id), 'mild');
      expect(find.text('${first.name.en} · mild'), findsOneWidget, reason: 'what helps, for what she logged');

      await tester.tap(find.byKey(ValueKey('sym_tile_${first.id}')));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('How strong is it today?'), findsOneWidget);
      await tester.tap(find.text('Strong'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(SymptomStore.instance.severityOn(_dayOnly(DateTime.now()), first.id), 'strong');
      expect(find.text('${first.name.en} · strong'), findsOneWidget);
    });

    testWidgets('a day ahead does not log', (tester) async {
      await pump(tester, SymptomsTodayBody(pregnancy: c));
      final t = _dayOnly(DateTime.now()).add(const Duration(days: 1));
      await tester.tap(find.byKey(ValueKey('sym_day_${t.year}-${t.month}-${t.day}')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('THAT DAY HAS NOT COME YET'), findsOneWidget);
      final first = symptomsCommonAt(20).first;
      await tester.tap(find.byKey(ValueKey('sym_tile_${first.id}')), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(SymptomStore.instance.severityOn(t, first.id), isNull);
    });

    testWidgets('the week grid and the note follow the log', (tester) async {
      final today = _dayOnly(DateTime.now());
      await SymptomStore.instance.setOn(today, 'heartburn', 'moderate');
      await SymptomStore.instance.setOn(today.subtract(const Duration(days: 2)), 'heartburn', 'strong');
      await pump(tester, SymptomsWeekBody(pregnancy: c, onSend: () {}));
      expect(find.text('Heartburn'), findsOneWidget);
      expect(find.textContaining('Heartburn on 2 of the last 7 days'), findsOneWidget);
      final note = symptomWeekNote(c);
      expect(note, contains('Heartburn — 2 days (strong ×1, moderate ×1)'));
      expect(note, contains('My observation, not a diagnosis'));
    });

    test('the severities', () {
      expect(severityDots('strong'), 3);
      expect(severityDots(null), 0);
      expect(severityLabel('moderate'), 'Moderate');
    });
  });

  group('the door', () {
    test('registered, five tabs, the flag on Talk only, every tile resolves', () {
      expect(pvDoorPageFor('pregnancy_symptoms'), same(kSymptomsDoor));
      expect(kSymptomsDoor.groups.length, 5);
      final flagged = kSymptomsDoor.groups.where((g) => g.pinnedRedFlag != null).map((g) => g.id).toList();
      expect(flagged, ['talk']);
      for (final s in kSymptomsDoor.sections) {
        for (final t in s.tiles) {
          switch (t) {
            case PvDoorEntryTile(:final library, :final entryId):
              expect(pvDoorEntryResolves(library, entryId), isTrue, reason: '${t.title} → $entryId');
            case PvDoorToolTile(:final surfaceId):
              expect(pvDoorSurfaceResolves(surfaceId), isTrue, reason: '${t.title} → $surfaceId');
            case PvDoorTalkTile(:final surfaceId):
              expect(pvDoorSurfaceResolves(surfaceId), isTrue, reason: '${t.title} → $surfaceId');
            default:
              break;
          }
        }
      }
      // Every ordinary symptom is on the By symptom tab.
      final onDoor = {
        for (final s in kSymptomsDoor.sections)
          for (final t in s.tiles)
            if (t is PvDoorEntryTile && t.library == PvDoorLibrary.symptom) t.entryId
      };
      expect(onDoor.length, kSymptomLibrary.length);
      // And the old companion's twelve are all in the library.
      for (final s in kSymptoms.where((s) => !s.urgent)) {
        expect(onDoor, contains(s.id));
      }
    });

    test('the door search finds a symptom by the word she types, and a question by its verb', () {
      final index = pvSearchIndexOf(kSymptomsDoor);
      // "chakkar" is in no title or blurb — only the tile's keywords carry it.
      expect(pvSearch('chakkar', index).map((h) => h.title), contains('Dizziness'));
      expect(pvSearch('peshab', index).map((h) => h.title), contains('Needing to pee often'));
      // The ten questions are rows on a tool, not tiles; they reach search by hand.
      final bleeding = pvSearch('bleeding', index).where((h) => h.open != null);
      expect(bleeding, isNotEmpty);
      expect(bleeding.first.meta, contains('Is this normal?'));
      // Is this normal? is a tool on its tab — a "now" row must be able to carry the phone.
      final normal = kSymptomsDoor.groups.firstWhere((g) => g.id == kSymTabNormal);
      expect(normal.inlineSurfaceId, kSymSurfaceNormal);
      expect(pvDoorSurfaceResolves(kSymSurfaceNormal), isTrue);
    });
  });
}
