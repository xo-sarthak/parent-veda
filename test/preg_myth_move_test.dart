// The two rail cards the gap analysis asked for (2026-09-30, P3): Myth or fact,
// from the week's own mythBuster, and Move, one of the Move door's reads.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/models/week_content.dart';
import 'package:parentveda/screens/preg_daily_insights.dart';
import 'package:parentveda/screens/pregnancy/preg_myth_sheet.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final weeks = {
    for (final j in jsonDecode(File('lib/data/weekContent.json').readAsStringSync()) as List)
      (j as Map)['week'] as int: WeekContent.fromJson(j.cast<String, dynamic>()),
  };

  List<PregInsight> cards(int week, {DateTime? on, DateTime? today}) {
    final d = on ?? DateTime(2026, 9, 30);
    return pregInsightsFor(
      date: d,
      today: today ?? d,
      day: week * 7,
      week: week,
      homeDay: null,
      weekContent: weeks[week],
      reads: const [],
    );
  }

  PregInsight? byGo(List<PregInsight> c, PregInsightGo g) => c.where((x) => x.go == g).firstOrNull;

  group('Myth or fact', () {
    test("carries the week's own myth and its answer, and opens the sheet", () {
      final m = byGo(cards(20), PregInsightGo.myth)!;
      expect(m.eyebrow, 'Myth or fact');
      expect(m.value, 'The anomaly scan is only for finding problems.');
      expect(m.truth, isNotEmpty);
      expect(m.truth, isNot(m.value));
      expect(m.id, 'myth_w20');
    });

    test('every week the app has one has a card, and none is filled with a stand-in', () {
      for (final w in weeks.keys) {
        final m = byGo(cards(w), PregInsightGo.myth);
        expect(m, isNotNull, reason: 'week $w');
        expect(m!.value.trim(), isNotEmpty, reason: 'week $w');
        expect(m.truth!.trim(), isNotEmpty, reason: 'week $w');
      }
    });

    test('not on a future date, which would show next week early; nothing without week content', () {
      final today = DateTime(2026, 9, 30);
      expect(byGo(cards(20, on: today.add(const Duration(days: 3)), today: today), PregInsightGo.myth), isNull);
      expect(
          pregInsightsFor(
              date: today, today: today, day: 140, week: 20, homeDay: null, weekContent: null, reads: const []).where(
              (c) => c.go == PregInsightGo.myth),
          isEmpty);
    });

    testWidgets('the sheet shows both halves, names its source and ends at the doctor', (t) async {
      t.view.physicalSize = const Size(360, 800);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        home: Builder(
          builder: (c) => Scaffold(
            body: TextButton(
                onPressed: () => showPregMythSheet(c, myth: 'A myth.', truth: 'The fact.'), child: const Text('open')),
          ),
        ),
      ));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.text('Myth or fact'), findsOneWidget);
      expect(find.text('A myth.'), findsOneWidget);
      expect(find.text('The fact.'), findsOneWidget);
      expect(find.textContaining('ParentVeda editorial'), findsOneWidget);
      expect(find.textContaining('your doctor knows your whole picture'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('Move', () {
    test("is one of the Move door's own reads, and opens it", () {
      final m = byGo(cards(20), PregInsightGo.move)!;
      expect(m.eyebrow, 'Move');
      expect(m.readId, startsWith('preg_move_read_'));
      expect(pregnancyReadById(m.readId!), isNotNull, reason: 'a card whose read is missing does nothing');
      expect(m.value, pregnancyReadById(m.readId!)!.title.en, reason: "the door's words, not ours");
    });

    test('every read it can offer exists, for every week', () {
      for (var w = 4; w <= 40; w++) {
        for (final id in pregMoveReadIdsFor(w)) {
          expect(pregnancyReadById(id), isNotNull, reason: '$id (week $w)');
        }
      }
    });

    test('the pool follows the trimester and waits for the weeks a read is about', () {
      expect(pregMoveReadIdsFor(10), contains('preg_move_read_first_trimester'));
      expect(pregMoveReadIdsFor(10), isNot(contains('preg_move_read_third_trimester')));
      expect(pregMoveReadIdsFor(20), contains('preg_move_read_second_trimester'));
      expect(pregMoveReadIdsFor(20), isNot(contains('preg_move_read_perineal_massage')));
      expect(pregMoveReadIdsFor(30), contains('preg_move_read_side_sleeping'));
      expect(pregMoveReadIdsFor(30), isNot(contains('preg_move_read_perineal_massage')));
      expect(pregMoveReadIdsFor(36), contains('preg_move_read_perineal_massage'));
      for (final w in [4, 20, 36]) {
        expect(pregMoveReadIdsFor(w), containsAll(['preg_move_read_walking', 'preg_move_read_pelvic_floor']));
      }
    });

    test('stable within a day and different across days', () {
      final d = DateTime(2026, 9, 30);
      expect(byGo(cards(20, on: d), PregInsightGo.move)!.readId, byGo(cards(20, on: d), PregInsightGo.move)!.readId);
      final seen = {
        for (var i = 0; i < 12; i++)
          byGo(cards(20, on: d.add(Duration(days: i)), today: d.add(Duration(days: i))), PregInsightGo.move)!.readId,
      };
      expect(seen.length, greaterThan(1), reason: 'something new to open every day');
    });

    test('the card carries no exercise instruction of its own', () {
      // Its words are the door read's title and a fixed label, nothing written here.
      final m = byGo(cards(20), PregInsightGo.move)!;
      expect(m.caption, 'Move & rest');
      expect(m.truth, isNull);
    });
  });

  test('the home resolves both destinations, and the rail keeps its cards', () {
    final home = _code('lib/screens/home_v3_screen.dart');
    expect(home, contains('case PregInsightGo.myth:'));
    expect(home, contains('showPregMythSheet('));
    expect(home, contains('case PregInsightGo.move:'));
    expect(home, contains('openPvDoorRead(context, id, pregnancy)'));
    final ids = cards(20).map((c) => c.id).toList();
    expect(ids, contains('size'));
    expect(ids.indexWhere((i) => i.startsWith('myth_')), greaterThan(ids.indexWhere((i) => i.startsWith('safe_'))));
  });
}
