// Move today and the Eat today need page (user, 2026-10-22).
//
// Move: the card said Move and opened an article. Now it opens a session page
// whose one button says what the tap does: "Play video" only when a film
// exists, "Video coming soon" (not tappable) otherwise. A Start that lands on
// a placeholder player is the misguiding tap the user asked us not to make.
//
// Eat today: the Iron card opened the top of the Nutrition door. It now opens
// the need's own page, with each food's serving in home words and grams or ml.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/nutrition/nutrition_plate.dart';
import 'package:parentveda/data/nutrition_data.dart';
import 'package:parentveda/data/prepare_data.dart';
import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/data/reads/pregnancy_reads_move.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart' show pvDoorSurfaceResolves;
import 'package:parentveda/screens/move/pv_move_today_screen.dart';
import 'package:parentveda/screens/nutrition/door/need_screen.dart';
import 'package:parentveda/screens/preg_daily_insights.dart' show kPregMoveYogaReadId;
import 'package:parentveda/services/pregnancy_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final c = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 140)));

  Future<void> pump(WidgetTester t, Widget w) async {
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: w));
    await t.pump();
  }

  group('Move today', () {
    final session = kYogaSessions.firstWhere((s) => s.month == 5);

    testWidgets('no film: the button says Video coming soon and cannot be tapped', (t) async {
      expect(session.videoUrl, isNull, reason: 'no session has a film yet');
      await pump(t, PvMoveTodayScreen(session: session, pregnancy: c, readId: kPregMoveYogaReadId));
      expect(find.byKey(const ValueKey('move_today_coming')), findsOneWidget);
      expect(find.text('Video coming soon'), findsOneWidget);
      expect(find.text('VIDEO COMING SOON'), findsOneWidget, reason: 'the poster agrees with the button');
      expect(find.textContaining('Start'), findsNothing, reason: 'no Start that could mean an activity');
      expect(find.textContaining('Play video'), findsNothing);
      final b = t.widget<OutlinedButton>(find.byKey(const ValueKey('move_today_coming')));
      expect(b.onPressed, isNull);
    });

    testWidgets('with a film: the button says Play video and the minutes', (t) async {
      final withFilm = YogaSession(session.id, session.title, session.duration, session.focus, session.blurb,
          month: session.month, videoUrl: 'https://example.org/film.mp4');
      await pump(t, PvMoveTodayScreen(session: withFilm, pregnancy: c));
      expect(find.text('Play video · ${session.duration.en}'), findsOneWidget);
      expect(find.byKey(const ValueKey('move_today_coming')), findsNothing);
    });

    testWidgets('teachers show price and schedule, never ratings; the read says Article', (t) async {
      await pump(t, PvMoveTodayScreen(session: session, pregnancy: c, readId: kPregMoveYogaReadId));
      // The page is a sliver list, so rows below the fold are not built until
      // scrolled to.
      for (final cls in kPrenatalClasses) {
        final row = find.byKey(ValueKey('move_today_class_${cls.id}'));
        await t.scrollUntilVisible(row, 200, scrollable: find.byType(Scrollable).first);
        expect(row, findsOneWidget);
        expect(find.descendant(of: row, matching: find.textContaining('${cls.rating}')), findsNothing, reason: cls.id);
      }
      await t.scrollUntilVisible(find.byKey(const ValueKey('move_today_read')), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.textContaining('ARTICLE ·'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    test('a session for every month, and the card and the read step agree', () {
      for (var w = 4; w <= 40; w++) {
        expect(moveTodaySessionFor(w, DateTime(2026, 10, 22)), isNotNull, reason: 'week $w');
      }
      expect(pvDoorSurfaceResolves(kMoveSurfaceToday), isTrue);
    });

    test('every next step on a Move read opens something', () {
      for (final r in kPregnancyReadsMove) {
        for (final n in r.nextSteps) {
          expect(pvDoorSurfaceResolves(n.surfaceId!), isTrue, reason: '${r.id}: ${n.surfaceId}');
        }
      }
      final yoga = pregnancyReadById(kPregMoveYogaReadId)!;
      expect(yoga.nextSteps.map((n) => n.kind), containsAll([PvNextKind.activity, PvNextKind.consult]));
      expect(pregnancyReadById('preg_move_read_when_not')!.nextSteps, isEmpty,
          reason: '"try a session" under "when not to exercise" would argue with the page');
    });
  });

  group('Eat today', () {
    test('every food on every need has a serving with a measure', () {
      for (final n in kPlateNeeds) {
        final guide = kNutrientGuides.firstWhere((g) => g.id == n.id);
        for (final f in guide.foods) {
          final portion = platePortionFor(n.id, f.en);
          expect(portion, isNotNull, reason: '${n.id}: ${f.en}');
          expect(portion, matches(RegExp(r'\d+ ?(g|ml)\b')), reason: 'grams or ml, as the user asked: $portion');
        }
      }
    });

    testWidgets('the iron page: answer, servings, absorb, tick', (t) async {
      final iron = plateNeedById('iron')!;
      await pump(t, NeedScreen(need: iron, pregnancy: c));
      expect(find.text('Iron'), findsWidgets);
      final list = find.byType(Scrollable).first;
      await t.scrollUntilVisible(find.text('1 katori cooked · about 150 ml').first, 200, scrollable: list);
      await t.scrollUntilVisible(find.text('Help it absorb'), 200, scrollable: list);
      await t.scrollUntilVisible(find.text('I had iron today'), 200, scrollable: list);
      await t.tap(find.byKey(const ValueKey('need_tick')));
      await t.pump();
      expect(find.text('Done for today'), findsOneWidget, reason: "the door's own tick");
      expect(find.textContaining('My doctor said'), findsNothing, reason: 'nobody gets a yes or no on iron');
      expect(t.takeException(), isNull);
    });
  });
}
