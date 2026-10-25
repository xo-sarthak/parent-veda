// =============================================================================
//  After a loss, her pregnancy reminders pause (R4); from 42 weeks the arrival
//  card says what to do (R7). 2026-10-25, docs/STAGE-TRANSITIONS.md.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pv_door_after_loss.dart';
import 'package:parentveda/models/reminder.dart';
import 'package:parentveda/screens/pregnancy/preg_hero_extras.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/services/pregnancy_ended_store.dart';
import 'package:parentveda/services/reminder_store.dart';
import 'package:parentveda/services/stage_moves.dart';

Reminder _r(String id, String category, {bool on = true}) =>
    Reminder(id: id, title: id, hour: 9, minute: 0, category: category, enabled: on);

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  final store = ReminderStore.instance;
  bool on(String id) => store.byId(id)?.enabled ?? false;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store.debugSeed([
      _r('bag_prep', 'bag'),
      _r('symptoms_evening', 'symptoms'),
      _r('folic', 'medication'),
      _r('water', 'water'),
      _r('mine', 'custom'),
    ]);
  });

  group('R4: a loss pauses her pregnancy reminders, and only those', () {
    test('the hospital bag and the evening check-in pause; medicines and hers stay on', () {
      expect(store.pauseForLoss(), 2);
      expect(on('bag_prep'), isFalse);
      expect(on('symptoms_evening'), isFalse);
      expect(on('folic'), isTrue, reason: 'a clinician may have prescribed it');
      expect(on('water'), isTrue);
      expect(on('mine'), isTrue);
      expect(store.pausedForLoss.toSet(), {'bag_prep', 'symptoms_evening'});
    });

    test('the undo brings back exactly what the loss paused', () {
      store.debugSeed([_r('bag_prep', 'bag'), _r('symptoms_evening', 'symptoms', on: false)]);
      store.pauseForLoss();
      expect(store.pausedForLoss, ['bag_prep'], reason: 'one she had switched off is not ours to pause');
      store.resumeAfterLossUndo();
      expect(on('bag_prep'), isTrue);
      expect(on('symptoms_evening'), isFalse, reason: 'it was off before the loss, and stays off');
      expect(store.pausedForLoss, isEmpty);
    });

    test('a reminder she removed after the loss stays removed', () {
      store.pauseForLoss();
      store.remove('bag_prep');
      store.resumeAfterLossUndo();
      expect(store.byId('bag_prep'), isNull);
      expect(on('symptoms_evening'), isTrue);
    });

    test('recordLoss and undoLoss carry the reminders with the flag', () async {
      PregnancyEndedStore.instance.resetForTest();
      await recordLoss();
      expect(PregnancyEndedStore.instance.lossRecorded, isTrue);
      expect(on('bag_prep'), isFalse);
      await undoLoss();
      expect(PregnancyEndedStore.instance.lossRecorded, isFalse);
      expect(on('bag_prep'), isTrue);
    });

    test('the loss page goes through stage_moves, and says what pauses and what stays', () {
      final screen = _code('lib/screens/pregnancy/preg_ended_screen.dart');
      expect(screen, contains('await recordLoss();'));
      expect(screen, contains('await undoLoss();'));
      expect(screen, isNot(contains('PregnancyEndedStore.instance.markEnded()')));
      final body = kPregEndedBody.join(' ');
      expect(body, contains('hospital bag and evening check-in'));
      expect(body, contains('reminders for your medicines'));
      expect(kPregEndedUndoBody.join(' '), contains('the reminders we paused come back on'));
    });
  });

  group('R7: from 42 weeks the arrival card names what to do', () {
    test('42 weeks and 0 days is the line', () {
      expect(pregIsPostTerm(13), isFalse);
      expect(pregIsPostTerm(14), isTrue);
      expect(pregIsPostTerm(-3), isFalse);
    });

    Widget host(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));
    final p = V2PaletteStore.instance.current;

    testWidgets('before 42 weeks: the card as it was', (t) async {
      await t.pumpWidget(host(PregArrivalCard(p: p, daysPastDue: 5, onDueDate: () {})));
      expect(find.text('Tell us when you are ready. Nothing from your pregnancy is deleted.'), findsOneWidget);
      expect(find.byKey(const ValueKey('preg_arrival_post_term')), findsNothing);
      expect(find.byKey(const ValueKey('preg_arrival_due_date')), findsNothing);
    });

    testWidgets('from 42 weeks: the doctor today, and the date may be wrong', (t) async {
      var opened = false;
      await t.pumpWidget(host(PregArrivalCard(p: p, daysPastDue: 15, onDueDate: () => opened = true)));
      expect(find.textContaining('Your due date was 2 weeks ago.'), findsOneWidget);
      expect(find.textContaining('call your doctor or hospital today'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('preg_arrival_due_date')));
      expect(opened, isTrue);
    });

    testWidgets('his side speaks of her, and cannot change her date', (t) async {
      await t.pumpWidget(host(PregArrivalCard(p: p, daysPastDue: 20, forPartner: true)));
      expect(find.textContaining('Her due date was 2 weeks ago.'), findsOneWidget);
      expect(find.textContaining('she should call her doctor or hospital today'), findsOneWidget);
      expect(find.byKey(const ValueKey('preg_arrival_due_date')), findsNothing);
    });

    test('"Not yet" rests it a day from 42 weeks, three days before', () async {
      final a = PregArrivalPrompt.instance..resetForTest();
      final now = DateTime(2026, 10, 25, 9);
      await a.notYet(now: now, postTerm: true);
      expect(a.showsFor(42, now: now.add(const Duration(hours: 12))), isFalse);
      expect(a.showsFor(42, now: now.add(const Duration(days: 1))), isTrue);
      await a.notYet(now: now);
      expect(a.showsFor(38, now: now.add(const Duration(days: 2))), isFalse);
    });

    test('the home hands the card today\'s days past the due date', () {
      final code = _code('lib/screens/home_v3_screen.dart');
      expect(code, contains('daysPastDue: pregnancy.isDueDateSet ? -_daysToDue(_today) : 0'));
      expect(code, contains('onDueDate: him ? null : () => openPregDueDate(context, pregnancy)'));
    });
  });
}
