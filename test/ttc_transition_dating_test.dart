// The new-chapter page, rebuilt (2026-10-22). The user (walk 2026-10-20):
// "Book your first appointment" as the first button took her into pregnancy,
// the button was not the house pill, and the page said "about 2 weeks
// pregnant". A positive home test comes from about 3 weeks (counted from the
// last period), usually around 4, so under 3 weeks the logged period was
// probably not her last one, or it was a light implantation bleed. The page
// asks; it never moves her date for her.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/pregnancy/preg_hero_extras.dart' show pregWeeksAndDays;
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_transition_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/ttc/ttc_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _today = DateTime(2026, 10, 22);

TtcTransitionResult _result({
  DateTime? lmp,
  bool clinic = false,
  bool derived = true,
}) {
  final from = lmp ?? _today.subtract(const Duration(days: 28));
  return TtcTransitionResult(
    dueDate: TtcTransitionEngine.dueDateFrom(from),
    weeksPregnant: TtcTransitionEngine.weeksFrom(from, on: _today),
    timelineEvents: 3,
    supplements: 2,
    cyclesLogged: 4,
    partnerJoined: true,
    dueDateWasDerived: derived,
    lmpUsed: clinic ? null : lmp,
    clinicOwned: clinic,
  );
}

Future<void> _pump(WidgetTester tester, TtcTransitionResult r) async {
  tester.view.physicalSize = const Size(1200, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
      home: TtcTransitionScreen(result: r, today: _today)));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  const t = TtcS(false);

  group('ttcDatingCheck', () {
    DateTime ago(int d) => _today.subtract(Duration(days: d));

    test('under 3 weeks: a positive test cannot usually be that early', () {
      for (final d in [0, 7, 14, 20]) {
        expect(ttcDatingCheck(lmp: ago(d), today: _today),
            TtcDatingCheck.tooEarly,
            reason: '$d days');
      }
    });

    test('3 weeks to 4: early, the first scan confirms', () {
      for (final d in [21, 24, 27]) {
        expect(ttcDatingCheck(lmp: ago(d), today: _today),
            TtcDatingCheck.early);
      }
    });

    test('4 to 10 weeks: nothing to say', () {
      for (final d in [28, 35, 70]) {
        expect(ttcDatingCheck(lmp: ago(d), today: _today),
            TtcDatingCheck.fine);
      }
    });

    test('over 10 weeks: a period probably went unlogged', () {
      expect(ttcDatingCheck(lmp: ago(71), today: _today),
          TtcDatingCheck.stale);
    });

    test('nothing logged: guessed; a clinic date: never questioned', () {
      expect(ttcDatingCheck(today: _today), TtcDatingCheck.guessed);
      expect(
          ttcDatingCheck(lmp: ago(5), today: _today, clinicOwned: true),
          TtcDatingCheck.clinic);
    });
  });

  group('the page', () {
    testWidgets('one ink pill into pregnancy, undo a real button', (tester) async {
      await _pump(tester, _result(lmp: _today.subtract(const Duration(days: 35))));
      expect(find.text(t.transitionGo), findsOneWidget);
      expect(find.text(t.transitionNext), findsNothing,
          reason: '"Book your first appointment" went into pregnancy');
      expect(find.byKey(const ValueKey('ttc_transition_undo')), findsOneWidget);
      expect(find.text(t.transitionUndo), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_transition_check_fine')),
          findsNothing);
      // Going on comes before the keepsake, and the keepsake before undo.
      final go = tester.getTopLeft(find.text(t.transitionGo)).dy;
      final card = tester.getTopLeft(find.text(t.transitionMakeCard)).dy;
      final undo = tester.getTopLeft(find.text(t.transitionUndo)).dy;
      expect(go, lessThan(card));
      expect(card, lessThan(undo));
    });

    testWidgets('2 weeks asks her to check, and "That was my period" settles it',
        (tester) async {
      await _pump(tester, _result(lmp: _today.subtract(const Duration(days: 14))));
      expect(find.byKey(const ValueKey('ttc_transition_check_tooEarly')),
          findsOneWidget);
      expect(find.text(t.transitionCheckTitle), findsOneWidget);
      expect(find.text(t.transitionChangeDate), findsOneWidget);
      await tester.tap(find.text(t.transitionKeepPeriod));
      await tester.pump();
      expect(find.byKey(const ValueKey('ttc_transition_check_tooEarly')),
          findsNothing, reason: 'her answer is final; the page asks once');
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('a stale log and a guessed date each say so', (tester) async {
      await _pump(tester, _result(lmp: _today.subtract(const Duration(days: 90))));
      expect(find.byKey(const ValueKey('ttc_transition_check_stale')),
          findsOneWidget);
      await _pump(tester, _result(derived: false));
      expect(find.byKey(const ValueKey('ttc_transition_check_guessed')),
          findsOneWidget);
      expect(find.text(t.transitionAddDate), findsOneWidget);
    });

    testWidgets('a clinic date is stated, never questioned or changed',
        (tester) async {
      await _pump(tester, _result(clinic: true));
      expect(find.text(t.transitionClinic), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_transition_change')), findsNothing);
      expect(find.text(t.transitionHowCounted), findsNothing);
    });
  });

  // The user, 2026-10-23: "why say week 8 w/o being in one??" Weeks and days,
  // as a scan report says it, and the same count the pregnancy home shows.
  testWidgets('the week card says weeks and days; "about" only for a guess',
      (tester) async {
    await _pump(tester, _result(lmp: _today.subtract(const Duration(days: 53))));
    expect(find.text("You're 7 weeks and 4 days pregnant"), findsOneWidget);
    await _pump(tester, _result(lmp: _today.subtract(const Duration(days: 29))));
    expect(find.text("You're 4 weeks and 1 day pregnant"), findsOneWidget);
    await _pump(tester, _result(lmp: _today.subtract(const Duration(days: 35))));
    expect(find.text("You're 5 weeks pregnant"), findsOneWidget);
    await _pump(tester, _result(derived: false));
    expect(find.text(t.transitionWeeks(4)), findsOneWidget);
    expect(find.textContaining('about'), findsWidgets);
  });

  test('the pregnancy hero counts the same way, and names the week she is in',
      () {
    expect(pregWeeksAndDays(53), ('7 weeks', 'and 4 days'));
    expect(pregWeeksAndDays(56), ('8 weeks', null));
    expect(pregWeeksAndDays(8), ('1 week', 'and 1 day'));
    expect(pregWeeksAndDays(0), ('0 weeks', null));
    final src = File('lib/screens/v2/v3_preg_hero.dart').readAsStringSync();
    expect(src, contains('pregWeeksAndDays(widget.day)'));
    expect(src, contains("widget.pastDueCount != null ? 'Week \${widget.week}' : weeksLine"));
  });

  test('redate counts again from her date, and drops a clinic source',
      () async {
    SharedPreferences.setMockInitialValues(
        {PregnancyController.kDueDateSourceKey: 'ivfTransfer'});
    final lmp = DateTime(2026, 9, 10);
    final r = await const TtcTransitionEngine()
        .redate(_result(lmp: _today.subtract(const Duration(days: 12))), lmp,
            on: _today);
    expect(r.dueDate, TtcTransitionEngine.dueDateFrom(lmp));
    expect(r.weeksPregnant, 6);
    expect(r.lmpUsed, lmp);
    expect(ttcDatingCheck(lmp: r.lmpUsed, today: _today), TtcDatingCheck.fine);
    final prefs = await SharedPreferences.getInstance();
    expect(DateTime.parse(prefs.getString(PregnancyController.kDueDateKey)!),
        r.dueDate);
    expect(prefs.getString(PregnancyController.kDueDateSourceKey), isNull);
  });
}
