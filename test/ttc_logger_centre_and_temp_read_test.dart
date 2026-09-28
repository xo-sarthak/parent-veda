// =============================================================================
//  Launch sanity U1 and U3 (2026-09-28)
// -----------------------------------------------------------------------------
//  U1: the logger's day name ("Today") sits on the screen's centre line, not
//      in the middle of what the close button leaves over.
//  U3: "How temperature tracking works" opens a read about temperature. It
//      opened "Ovulation kits: do they help?".
//  (U2, the report adding numbers in place, is in ttc_cycle_views_test.dart.)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_edit_categories_screen.dart'
    show TtcCategoryPrefs;
import 'package:parentveda/screens/ttc/ttc_symptom_log_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';
import 'package:parentveda/ttc/ttc_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcCategoryPrefs.instance.resetForTest();
  });

  Future<void> pump(WidgetTester tester, {double width = 360}) async {
    tester.view.physicalSize = Size(width, 5200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        MaterialApp(key: UniqueKey(), home: const TtcSymptomLogScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  }

  group('U1: the day name is centred on the screen', () {
    for (final width in [360.0, 412.0]) {
      testWidgets('at $width points wide', (tester) async {
        await pump(tester, width: width);
        final group = find.byKey(const ValueKey('ttc_log_day_group'));
        expect(group, findsOneWidget);
        expect(tester.getCenter(group).dx, closeTo(width / 2, 1.5),
            reason: '"Today" and its arrows sit on the centre line');
        // The arrows and the name are still all there and still work.
        expect(find.byKey(const ValueKey('ttc_log_day_back')), findsOneWidget);
        expect(
            find.byKey(const ValueKey('ttc_log_day_forward')), findsOneWidget);
        expect(find.text('Today'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('ttc_log_day_back')));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Yesterday'), findsOneWidget);
        expect(tester.getCenter(group).dx, closeTo(width / 2, 1.5));
      });
    }
  });

  group('U3: the temperature link opens a read about temperature', () {
    test('the id resolves and its title says temperature', () {
      final read = ttcReadById(kTtcTempReadId);
      expect(read, isNotNull, reason: '$kTtcTempReadId is not in kTtcReads');
      expect(read!.title.en.toLowerCase(), contains('temperature'));
      expect(kTtcTempReadLink.toLowerCase(), contains('temperature'));
    });

    test('it says what the brief asked it to, and never a chance', () {
      final read = ttcReadById('ttc_read_morning_temperature')!;
      final all = [
        read.shortAnswer!.en,
        read.teaser.en,
        for (final s in read.sections) ...[
          for (final p in s.paragraphs) p.en,
          for (final b in s.bullets) b.en,
        ],
        read.whenToSeeSomeone.body.en,
      ].join(' ');
      expect(all, contains('0.2 to 0.5'));
      expect(all, contains('3 hours'));
      expect(all.toLowerCase(), contains('alcohol'));
      expect(all.toLowerCase(), contains('discharge'));
      expect(all.toLowerCase(), contains('doctor'));
      expect(all.toLowerCase(), isNot(contains('% chance')));
      expect(all.toLowerCase(), isNot(contains('your chance')));
      expect(read.reviewed, isFalse,
          reason: 'no named doctor has reviewed this read yet');
    });
  });
}
