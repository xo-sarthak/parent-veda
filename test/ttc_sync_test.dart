// =============================================================================
//  TTC cloud sync
// -----------------------------------------------------------------------------
//  Supabase is never initialised in a widget test, so every SupabaseRepo call
//  behaves exactly as it does when logged out. That is not a limitation here -
//  it is the most important case to prove:
//
//      "An uninitialised backend behaves exactly like being logged out."
//                                          - Product Reference, §2.6
//
//  So these tests pin the local-first guarantee: every TTC store must work
//  completely, and never throw, with no cloud at all. Plus the pieces of the
//  sync layer that ARE unit-testable - date mapping, deterministic ids, and the
//  guard that stops a half-loaded store pushing over good cloud rows.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_today_screen.dart';
import 'package:parentveda/services/family_timeline.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/remote/supabase_repo.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart' show TtcRitualPart;
import 'package:parentveda/ttc/ttc_journal_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_ritual_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_supplements_store.dart';
import 'package:parentveda/ttc/ttc_sync.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcJournalStore.instance.resetForTest();
    TtcRitualStore.instance.resetForTest();
    TtcSupplementsStore.instance.resetForTest();
    FamilyTimeline.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  // ===========================================================================
  group('an uninitialised backend behaves exactly like logged out', () {
    test('SupabaseRepo reports logged out rather than throwing', () {
      // Touching Supabase.instance before initialize() throws an assertion;
      // the repo swallows it. Without that, every store below would crash.
      expect(SupabaseRepo.userId, isNull);
      expect(SupabaseRepo.isLoggedIn, isFalse);
    });

    test('every read degrades to empty instead of throwing', () async {
      expect(await SupabaseRepo.fetch(TtcTables.cycles), isEmpty);
      expect(await SupabaseRepo.fetchShared(TtcTables.journal), isEmpty);
      expect(await SupabaseRepo.fetchMyProfile('life_stage'), isNull);
    });

    test('every write is a silent no-op', () async {
      await SupabaseRepo.updateMyProfile({'life_stage': 'trying'});
      await SupabaseRepo.upsertRow(TtcTables.logs, {'x': 1});
      await SupabaseRepo.delete(TtcTables.journal, 'nope');
      await SupabaseRepo.deleteMatch(TtcTables.ritual, {'x': 'y'});
      // Reaching here without an exception is the whole assertion.
    });
  });

  // ===========================================================================
  group('every store works completely with no cloud', () {
    test('cycles', () {
      final c = CycleStore.instance;
      c.logPeriodStart(DateTime(2026, 5, 1));
      c.logPeriodStart(DateTime(2026, 5, 29));
      c.logLhPositive(14);
      expect(c.cycleLengths, [28]);
      expect(c.lhPositiveDay, 14);
      c.removePeriodStart(DateTime(2026, 5, 29));
      expect(c.periodStarts.length, 1);
    });

    test('logs, including clearing', () {
      final s = TtcLogStore.instance;
      s.log('mood', 'mood', 3);
      expect(s.valueFor('mood', 'mood')!.value, 3);
      s.clear('mood', 'mood');
      expect(s.valueFor('mood', 'mood'), isNull);
    });

    test('journal, including deleting', () {
      final s = TtcJournalStore.instance;
      final e = s.add(kind: TtcEntryKind.memory, text: 'hello');
      expect(s.count, 1);
      s.remove(e.id);
      expect(s.count, 0);
    });

    test('ritual, including un-ticking', () {
      final s = TtcRitualStore.instance;
      s.toggle(TtcRitualPart.breath);
      expect(s.completedToday(), 1);
      s.toggle(TtcRitualPart.breath);
      expect(s.completedToday(), 0);
    });

    test('supplements, including removing', () {
      final s = TtcSupplementsStore.instance;
      final item = s.add('Folic acid');
      s.toggleTaken(item.id);
      expect(s.takenToday(), 1);
      s.toggleTaken(item.id);
      expect(s.takenToday(), 0);
      s.remove(item.id);
      expect(s.items, isEmpty);
    });

    test('the family timeline, including removing', () {
      final tl = FamilyTimeline.instance;
      tl.add(
          id: 'x',
          stage: LifeStage.tryingToConceive,
          kind: TimelineKind.action,
          titleEn: 'a',
          titleHi: 'a');
      expect(tl.count, 1);
      tl.remove('x');
      expect(tl.count, 0);
    });

    test('the life stage', () {
      LifeStageStore.instance.setStage(LifeStage.tryingToConceive);
      expect(LifeStageStore.instance.isTrying, isTrue);
    });

    testWidgets('and the screens still render', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: TtcTodayScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ===========================================================================
  group('the push guard', () {
    test('a store does not push before its first sync completes', () {
      // Loading the local cache fires notifyListeners several times. If those
      // pushed, a half-loaded store would clobber good cloud rows.
      final s = TtcLogStore.instance;
      s.setCloudReadyForTest(false);
      expect(s.cloudReady, isFalse);
      s.log('mood', 'mood', 2); // must not throw, must not push
      expect(s.valueFor('mood', 'mood')!.value, 2);
    });

    test('syncFromCloud marks the store ready even when logged out', () async {
      final s = TtcLogStore.instance;
      s.setCloudReadyForTest(false);
      await s.syncFromCloud();
      expect(s.cloudReady, isTrue,
          reason: 'a logged-out sync must still unblock later pushes');
    });
  });

  // ===========================================================================
  group('row mapping', () {
    test('dates are written as plain yyyy-mm-dd', () {
      expect(TtcSyncUtil.date(DateTime(2026, 7, 4)), '2026-07-04');
      expect(TtcSyncUtil.date(DateTime(2026, 12, 31)), '2026-12-31');
    });

    test('dates round-trip, and the time of day is dropped', () {
      final d = DateTime(2026, 7, 4, 23, 59);
      expect(TtcSyncUtil.parseDate(TtcSyncUtil.date(d)), DateTime(2026, 7, 4));
    });

    test('a missing or unparseable date is null, never a guess', () {
      expect(TtcSyncUtil.parseDate(null), isNull);
      expect(TtcSyncUtil.parseDate(''), isNull);
      expect(TtcSyncUtil.parseDate('not a date'), isNull);
    });

    test('table names are all distinct', () {
      const names = [
        TtcTables.journeys,
        TtcTables.cycles,
        TtcTables.signals,
        TtcTables.logs,
        TtcTables.journal,
        TtcTables.supplements,
        TtcTables.supplementTaken,
        TtcTables.ritual,
        TtcTables.timeline,
      ];
      expect(names.toSet().length, names.length);
    });
  });

  // ===========================================================================
  group('the migration and the client agree', () {
    // Cheap contract check against the SQL, so a rename on one side cannot
    // silently break the other.
    final sql = File('supabase/migrations/0041_ttc.sql').readAsStringSync();

    test('every table the client writes to exists in 0041', () {
      for (final table in [
        TtcTables.journeys,
        TtcTables.cycles,
        TtcTables.signals,
        TtcTables.logs,
        TtcTables.journal,
        TtcTables.supplements,
        TtcTables.supplementTaken,
        TtcTables.ritual,
        TtcTables.timeline,
      ]) {
        expect(sql.contains('public.$table'), isTrue,
            reason: '0041 has no table $table');
      }
    });

    test('the timeline is append-only - no update policy, no update grant', () {
      expect(sql.contains('for update'), isFalse,
          reason: 'an UPDATE policy would break the append-only rule');
      // The timeline grant deliberately omits update.
      expect(sql.contains('grant select, insert, delete on public.journey_timeline'),
          isTrue);
    });

    test('her cycle is own-row, with no partner read anywhere near it', () {
      final cyclesPolicy =
          sql.substring(sql.indexOf('create policy ttc_cycles_own'));
      final firstPolicyEnd = cyclesPolicy.indexOf(';');
      expect(cyclesPolicy.substring(0, firstPolicyEnd).contains('my_partner_id'),
          isFalse,
          reason: 'the partner must not be able to read her cycle');
    });

    test('the journal cannot have its author forged', () {
      expect(sql.contains('author_id = auth.uid()'), isTrue,
          reason: 'a client could otherwise write an entry as their partner');
    });
  });
}
