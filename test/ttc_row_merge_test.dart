// =============================================================================
//  The newer change wins, on every phone (2026-10-17, 0097)
// -----------------------------------------------------------------------------
//  The device walk found a cleared ovulation test back after a reinstall, and
//  the audit found the cause: a union pull never takes anything away, so a
//  removal or an edit made on one phone lost to the next phone that still
//  held the old row. These hold the rule that replaced it
//  (`lib/ttc/ttc_row_merge.dart`), with no network.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_row_merge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final mon = DateTime.utc(2026, 10, 12, 9);
  final tue = DateTime.utc(2026, 10, 13, 9);

  group('one row', () {
    test('an edit on another phone beats an older copy here', () {
      expect(ttcMergeStep(local: mon, cloud: tue), TtcMergeStep.takeCloud);
    });

    test('an edit here beats an older cloud copy, and uploads', () {
      expect(ttcMergeStep(local: tue, cloud: mon), TtcMergeStep.pushLocal);
    });

    test('a row only this phone has uploads', () {
      expect(ttcMergeStep(local: mon, cloud: null), TtcMergeStep.pushLocal);
    });

    test('a row only the cloud has is taken (a new phone, a reinstall)', () {
      expect(ttcMergeStep(local: null, cloud: mon), TtcMergeStep.takeCloud);
    });

    test('the same time on both sides is nothing to do', () {
      expect(ttcMergeStep(local: mon, cloud: mon), TtcMergeStep.same);
    });

    test('a row from before this release loses to any cloud copy', () {
      expect(ttcMergeStep(local: ttcEpoch, cloud: mon), TtcMergeStep.takeCloud);
    });
  });

  group('a table', () {
    test('a removal on another phone is taken, not undone', () {
      // Phone B removed the test on Tuesday; this phone last touched it on
      // Monday. The old union kept Monday's copy and pushed it back.
      final plan = ttcMergePlan(
        local: {'lh|2026-09-30': mon},
        cloud: {'lh|2026-09-30': tue},
      );
      expect(plan.take, {'lh|2026-09-30'});
      expect(plan.push, isEmpty);
    });

    test('a removal here, offline, uploads over the older cloud copy', () {
      final plan = ttcMergePlan(
        local: {'c|2026-09-08': tue},
        cloud: {'c|2026-09-08': mon},
      );
      expect(plan.push, {'c|2026-09-08'});
    });

    test('two phones, two keys: each newer side wins its own key', () {
      final plan = ttcMergePlan(
        local: {'a': tue, 'b': mon},
        cloud: {'a': mon, 'b': tue},
      );
      expect(plan.push, {'a'});
      expect(plan.take, {'b'});
    });

    test('a stamp the cloud has not got reads as missing', () {
      expect(ttcParseStamp(null), isNull);
      expect(ttcParseStamp(''), isNull);
      expect(ttcParseStamp('2026-10-13T09:00:00Z'), tue);
    });
  });

  group('the stores mark what waits to upload', () {
    setUp(() {
      CycleStore.instance.resetForTest();
      TtcLogStore.instance.resetForTest();
    });

    test('a period, its bleed days and a removal each wait', () {
      final s = CycleStore.instance;
      s.logPeriodStart(DateTime(2026, 9, 30));
      expect(s.dirtyRowsForTest, {'c|2026-09-30'});
      expect(s.hasPendingPush, isTrue);
      s.logLhPositive(9);
      expect(s.dirtyRowsForTest, contains('lh|2026-09-30'));
      s.logLhPositive(null);
      expect(s.tombstonesForTest.keys, contains('lh|2026-09-30'),
          reason: 'a clear is a removal row that uploads, not a local note');
      s.removePeriodStart(DateTime(2026, 9, 30));
      expect(s.tombstonesForTest.keys, contains('c|2026-09-30'));
    });

    test('a move removes the old date and writes the new one', () {
      final s = CycleStore.instance;
      s.logPeriodStart(DateTime(2026, 9, 30));
      s.logBleedDays(DateTime(2026, 9, 30), 5);
      s.movePeriodStart(DateTime(2026, 9, 30), DateTime(2026, 10, 1));
      expect(s.tombstonesForTest.keys, contains('c|2026-09-30'));
      expect(s.dirtyRowsForTest, containsAll(['c|2026-09-30', 'c|2026-10-01']));
      expect(s.bleedDaysFor(DateTime(2026, 10, 1)), 5);
    });

    test('a daily log value and its clear both wait', () {
      final l = TtcLogStore.instance;
      final day = DateTime(2026, 10, 1);
      l.log('symptoms', 'ov_positive', 1, on: day);
      expect(l.dirtyKeysForTest, {'symptoms/ov_positive/2026-10-01'});
      l.clear('symptoms', 'ov_positive', on: day);
      expect(l.dirtyKeysForTest, {'symptoms/ov_positive/2026-10-01'});
      expect(l.clearedKeysForTest, {'symptoms/ov_positive/2026-10-01'});
      expect(l.hasPendingPush, isTrue);
    });
  });
}
