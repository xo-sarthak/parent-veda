// =============================================================================
//  Period logging is safe everywhere (launch sanity 2026-09-28, H1 follow-up)
// -----------------------------------------------------------------------------
//  The home's Period button was fixed first: a stock Material date picker set
//  to TODAY meant one reflex tap on OK started a new cycle. Every other
//  "Log a period" in the stage went through `logTtcPeriod`, which still opened
//  that picker. It now delegates to the home's sheet, and this file holds it:
//
//  1. no live code in the stage opens a stock date picker to log a period;
//  2. `logTtcPeriod` and a second caller (the journey map) open the sheet;
//  3. the empty case, before her first period, works on the sheet.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_journey_map_screen.dart'
    show openTtcMilestoneWay;
import 'package:parentveda/screens/ttc/ttc_today_screen.dart'
    show logTtcPeriod;
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

class _NoNet extends HttpOverrides {}

/// The source with every line comment removed, so a picker kept for revert
/// as a comment does not count.
String _live(String src) => src
    .split('\n')
    .map((l) {
      final i = l.indexOf('//');
      return i < 0 ? l : l.substring(0, i);
    })
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  setUpAll(() => HttpOverrides.global = _NoNet());

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
  });

  DateTime ago(int days) {
    final n = DateTime.now().subtract(Duration(days: days));
    return DateTime(n.year, n.month, n.day);
  }

  // ===========================================================================
  group('no stock picker logs a period', () {
    test('logTtcPeriod delegates to the sheet', () {
      final src = _live(File('lib/screens/ttc/ttc_today_screen.dart')
          .readAsStringSync());
      final at = src.indexOf('Future<void> logTtcPeriod(');
      expect(at, greaterThan(-1));
      final body = src.substring(at, src.indexOf(';', at) + 1);
      expect(body, contains('showTtcHomePeriodSheet(context)'));
      expect(body, isNot(contains('showDatePicker')));
    });

    test('no live showDatePicker in the stage sits next to period logging',
        () {
      // Onboarding asks her last period once, before any cycle exists: the
      // picked date is shown back on the button and only Continue commits
      // it, so a reflex OK cannot restart a cycle there.
      const allowed = {'lib/screens/ttc/ttc_intro_flow.dart'};
      final offenders = <String>[];
      for (final dir in ['lib/screens/ttc', 'lib/ttc']) {
        for (final f in Directory(dir)
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
          final path = f.path.replaceAll('\\', '/');
          if (allowed.contains(path)) continue;
          final lines = _live(f.readAsStringSync()).split('\n');
          for (var i = 0; i < lines.length; i++) {
            if (!lines[i].contains('showDatePicker(')) continue;
            final near = lines
                .sublist((i - 12).clamp(0, lines.length),
                    (i + 60).clamp(0, lines.length))
                .join('\n');
            if (near.contains('logPeriodTitle') ||
                near.contains('logPeriodStart(')) {
              offenders.add('$path:${i + 1}');
            }
          }
        }
      }
      expect(offenders, isEmpty,
          reason: 'a stock picker opens on today, and one reflex OK starts '
              'a new cycle. Use logTtcPeriod (the period sheet) instead.');
    });
  });

  // ===========================================================================
  group('every caller opens the sheet', () {
    Future<void> host(WidgetTester tester, void Function(BuildContext) open) async {
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (c) => TextButton(
              onPressed: () => open(c),
              child: const Text('Log'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Log'));
      await tester.pumpAndSettle();
    }

    for (final (name, open) in <(String, void Function(BuildContext))>[
      ('logTtcPeriod', (c) => logTtcPeriod(c)),
      (
        'the journey map',
        (c) => openTtcMilestoneWay(c, 'first_cycle_logged', ahead: true)
      ),
    ]) {
      testWidgets('$name: opens on her logged start and OK changes nothing',
          (tester) async {
        CycleStore.instance
          ..logPeriodStart(ago(37))
          ..logPeriodStart(ago(9));
        await host(tester, open);

        expect(find.byType(DatePickerDialog), findsNothing);
        final line = tester.widget<Text>(
            find.byKey(const ValueKey('ttc_home_period_line')));
        expect(line.data, contains('Your period started on'));
        final save = find.byKey(const ValueKey('ttc_home_period_save'));
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(CycleStore.instance.periodStarts, [ago(37), ago(9)],
            reason: 'the reflex tap restarted her cycle');
      });
    }

    testWidgets('before her first period the sheet opens empty and saves one',
        (tester) async {
      await host(tester, (c) => logTtcPeriod(c));
      expect(find.byType(DatePickerDialog), findsNothing);
      expect(find.text('LOG A PERIOD'), findsOneWidget);
      // Nothing is picked for her, so nothing can be saved by reflex.
      expect(find.byKey(const ValueKey('ttc_home_period_line')), findsNothing);

      await tester.tap(find.text('${DateTime.now().day}').first);
      await tester.pumpAndSettle();
      final line = tester.widget<Text>(
          find.byKey(const ValueKey('ttc_home_period_line')));
      expect(line.data, contains('Your period started on'));
      final save = find.byKey(const ValueKey('ttc_home_period_save'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(CycleStore.instance.periodStarts, [ago(0)]);
    });
  });
}
