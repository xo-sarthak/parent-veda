// Relevance pass, Batch 1 (2026-10-27): the app knows where she is.
// docs/door-relevance/README.md; faults named as in the stage gap files.
//
// The clinic-cycle chapter rule is held day by day, for every round kind, in
// ttc_date_consistency_test.dart ("every day of the round").

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/pregnancy/preg_due_date_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_home_situation.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _src(String path) => File(path).readAsStringSync();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pregnancy: her week is read from the clock (PREG fault 1)', () {
    test('"now" is a getter, not a value stored at launch', () {
      final s = _src('lib/services/pregnancy_controller.dart');
      expect(s, contains('DateTime get _now => _fixedNow ?? DateTime.now();'));
      expect(RegExp(r'^\s*final DateTime _now;', multiLine: true).hasMatch(s),
          isFalse,
          reason: 'a stored _now freezes the week for as long as the app '
              'stays in memory');
    });

    test('with no clock pinned, the week is today\'s', () {
      final today = DateTime.now();
      final due = DateTime(today.year, today.month, today.day)
          .add(const Duration(days: 140));
      expect(PregnancyController(dueDate: due).currentWeek, 20);
    });

    test('refreshClock repaints only on a new day', () {
      final c = PregnancyController(now: DateTime(2026, 10, 27, 9));
      var n = 0;
      c.addListener(() => n++);
      c.refreshClock();
      c.refreshClock();
      expect(n, 0, reason: 'same day: nothing to repaint');
    });

    test('the Pregnancy shell refreshes the clock on resume', () {
      expect(_src('lib/screens/main_scaffold.dart'),
          contains('widget.pregnancy.refreshClock();'));
    });
  });

  group('Pregnancy: the due date is required (PREG faults 2, 25)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('asked only once loading has settled, never of him', () async {
      final c = PregnancyController();
      expect(pregNeedsDueDate(c), isFalse,
          reason: 'not loaded yet: her account may still bring the date');
      await c.load();
      expect(c.hasLoaded, isTrue);
      expect(pregNeedsDueDate(c), isTrue);
      expect(pregNeedsDueDate(c, father: true), isFalse);
    });

    test('a saved date ends the question', () async {
      final c = PregnancyController();
      await c.load();
      await c.setDueDate(DateTime.now().add(const Duration(days: 100)));
      expect(pregNeedsDueDate(c), isFalse);
    });

    test('the home asks, and the page is locked in a store build', () {
      final home = _src('lib/screens/home_v3_screen.dart');
      expect(home, contains('pregNeedsDueDate(pregnancy, father: him)'));
      expect(home, contains('required: !(kDebugMode || kPvDevBuild)'));
      final page = _src('lib/screens/pregnancy/preg_due_date_screen.dart');
      expect(page, contains('canPop: !locked'));
      expect(page, contains('automaticallyImplyLeading: !locked'));
    });

    test('a sign-in prompt never moves her stage', () {
      expect(_src('lib/screens/auth/auth_flow_screen.dart'),
          contains('if (LifeStageStore.instance.stage == null) {'));
    });

    test('the store names no week without a real date', () {
      expect(_src('lib/services/pv_catalog_store.dart'),
          contains('!c.isDueDateSet) ? null : c.currentWeek'));
    });
  });

  group('TTC: the clinic and the loss decide (TTC faults 1, 2, 11)', () {
    test('on her own cycle every chapter passes through', () {
      for (final ch in TtcChapter.values) {
        expect(ttcScreenChapter(ch), ch);
      }
    });

    test('Ask Veda and the home read the screen chapter', () {
      expect(_src('lib/screens/ttc/ttc_askveda_screen.dart'),
          contains('ttcScreenChapter(TtcStore.instance.displayChapter)'));
      expect(_src('lib/screens/ttc/ttc_home_v3.dart'),
          contains('ttcScreenChapter(today.chapter)'));
    });

    test('"Your period came" counts only periods since a loss', () {
      expect(_src('lib/ttc/ttc_home_situation.dart'),
          contains('CycleStore.instance.currentPeriodStarts).map(_day)]'));
    });
  });
}
