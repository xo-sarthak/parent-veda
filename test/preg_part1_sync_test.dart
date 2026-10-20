// =============================================================================
//  Pregnancy part 1 syncs newer-wins (0106, sync log step 8)
// -----------------------------------------------------------------------------
//  Her calendar, bump photos, the daily tables, weekly notes and reminders
//  moved to `OwnRowLedger`. These cases check the store-level behaviour that
//  can run without a network, and read the source to check every store is
//  wired: the ledger, the soft delete, the pending check, and the alarm and
//  Storage clean-ups that follow a removal.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/daily_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test("re-saving a day's talk keeps one entry with the same id", () async {
    final s = DailyStore.instance;
    final a = await s.saveTalk(
        day: 40, week: 6, prompt: 'p', text: 'first', spoken: false);
    final b = await s.saveTalk(
        day: 40, week: 6, prompt: 'p', text: 'second', spoken: false);
    expect(b.id, a.id, reason: 'an edit in place, not delete + insert');
    expect(s.talkEntries.where((e) => e.day == 40).length, 1);
    expect(s.talkForDay(40)!.text, 'second');
  });

  String src(String p) => File(p).readAsStringSync();

  test('every store syncs through the ledger and reports pending changes', () {
    for (final f in [
      'lib/services/calendar_store.dart',
      'lib/services/bump_store.dart',
      'lib/services/daily_store.dart',
      'lib/services/memory_store.dart',
      'lib/services/reminder_store.dart',
    ]) {
      final s = src(f);
      expect(s, contains('OwnRowLedger('), reason: f);
      expect(s, contains('SyncRegistry.registerPending('), reason: f);
      expect(s, contains('.pull('), reason: f);
    }
  });

  test('deletes are soft: no live hard delete is left', () {
    // The old calls stay only in comments ("kept for revert") or in the
    // unused *Old pull.
    for (final f in [
      'lib/services/calendar_store.dart',
      'lib/services/bump_store.dart',
      'lib/services/daily_store.dart',
      'lib/services/memory_store.dart',
      'lib/services/reminder_store.dart',
    ]) {
      final live = src(f)
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      expect(live, isNot(contains('SupabaseRepo.delete(')), reason: f);
      expect(live, isNot(contains('SupabaseRepo.deleteBy(')), reason: f);
    }
  });

  test('a reminder taken from the cloud re-arms or cancels its alarm here', () {
    final s = src('lib/services/reminder_store.dart');
    final pull = s.substring(s.indexOf('Future<void> _syncFromCloud()'),
        s.indexOf('Future<void> _syncFromCloudOld()'));
    expect(pull, contains('_cancelOs(mine)'));
    expect(pull, contains('_scheduleOs(theirs)'));
  });

  test('a removed photo leaves Storage only after the cloud confirms', () {
    final bump = src('lib/services/bump_store.dart');
    expect(bump, contains('onRemovalConfirmed:'));
    expect(bump, contains("StorageService.remove((cols['image_url']"));
    final notes = src('lib/services/memory_store.dart');
    expect(notes, contains('onRemovalConfirmed:'));
  });
}
