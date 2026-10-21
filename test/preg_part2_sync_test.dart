// =============================================================================
//  Pregnancy part 2 syncs newer-wins (0107, sync log step 9)
// -----------------------------------------------------------------------------
//  Medicines and their logs, scans and appointments, symptoms, and the tools
//  (weight, movement, kegel, contractions) moved to `OwnRowLedger`. These
//  cases check the store behaviour that runs without a network, and read the
//  source to check every store is wired: the ledger, the soft delete, the
//  pending check, the alarms rebuilt from the synced row, and the partner's
//  read-only copy without his removed rows.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/medicine_store.dart';
import 'package:parentveda/services/scans_store.dart';
import 'package:parentveda/services/symptom_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a medicine log id is one per medicine per day', () {
    expect(MedicineStore.logIdFor('med_1', '2026-10-21'),
        MedicineStore.logIdFor('med_1', '2026-10-21'));
    expect(MedicineStore.logIdFor('med_1', '2026-10-21'),
        isNot(MedicineStore.logIdFor('med_1', '2026-10-22')));
    expect(MedicineStore.logIdFor('med_1', '2026-10-21'),
        isNot(MedicineStore.logIdFor('med_2', '2026-10-21')));
  });

  test('ticking a medicine twice on two phones names the same row', () async {
    final s = MedicineStore.instance;
    final day = DateTime(2026, 10, 21);
    await s.toggleOn('med_x', day); // tick
    await s.toggleOn('med_x', day); // un-tick
    await s.toggleOn('med_x', day); // tick again: the same key, revived
    expect(s.isTakenOn('med_x', MedicineStore.dateKey(day)), isTrue);
  });

  test('a symptom severity change keeps one log under one id', () async {
    final s = SymptomStore.instance;
    final day = DateTime(2026, 10, 21);
    await s.setOn(day, 'nausea', 'mild');
    final first = s.logsOn(day).single.id;
    await s.setOn(day, 'nausea', 'strong');
    final after = s.logsOn(day).where((l) => l.symptomId == 'nausea');
    expect(after.length, 1);
    expect(after.single.id, first, reason: 'an edit, not delete + insert');
    expect(after.single.severity, 'strong');
    expect(first, SymptomStore.logIdFor('2026-10-21', 'nausea'));
  });

  test("the partner's removed rows are not shown", () {
    final rows = [
      {'scan_id': 'nt', 'removed_at': null},
      {'scan_id': 'anomaly', 'removed_at': '2026-10-21T09:00:00Z'},
    ];
    expect(ScansStore.notRemoved(rows).map((r) => r['scan_id']), ['nt']);
  });

  String src(String p) => File(p).readAsStringSync().replaceAll('\r\n', '\n');
  const stores = [
    'lib/services/medicine_store.dart',
    'lib/services/scans_store.dart',
    'lib/services/symptom_store.dart',
    'lib/services/tools_store.dart',
  ];

  test('every store syncs through the ledger and reports pending changes', () {
    for (final f in stores) {
      final s = src(f);
      expect(s, contains('OwnRowLedger'), reason: f);
      expect(s, contains('SyncRegistry.registerPending('), reason: f);
      expect(s, contains('.pull('), reason: f);
    }
    final tools = src('lib/services/tools_store.dart');
    expect(tools, contains("OwnRowLedger.single('weight_profile'"));
    expect(tools, contains("OwnRowLedger.single('kegel_state'"));
  });

  test('deletes are soft: no live hard delete or clear is left', () {
    for (final f in stores) {
      final live = src(f)
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      expect(live, isNot(contains('SupabaseRepo.delete(')), reason: f);
      expect(live, isNot(contains('SupabaseRepo.deleteBy(')), reason: f);
      expect(live, isNot(contains('SupabaseRepo.clear(')), reason: f);
    }
  });

  test('medicine alarms ride on the row and are rebuilt after a pull', () {
    final s = src('lib/services/medicine_store.dart');
    expect(s, contains("'alarms': m.alarms.map((a) => a.toJson()).toList()"));
    final pull = s.substring(s.indexOf('Future<void> _syncFromCloud()'),
        s.indexOf('Future<void> _syncFromCloudOld()'));
    expect(pull, contains('keepAlarms: keep'),
        reason: 'a row from before 0107 must not wipe her alarms');
    expect(pull, contains('cancelMedicationAlarms(id)'));
    expect(pull, contains('scheduleMedicationAlarms(m)'));
  });

  test('the partner fetch drops his removed rows', () {
    final s = src('lib/services/scans_store.dart');
    expect(s, contains('notRemoved(pScans)'));
    expect(s, contains('notRemoved(pAppts)'));
  });

  test('the scan timeline edits an appointment instead of delete + re-add', () {
    final s = src('lib/screens/brackets/scan_timeline_screen.dart');
    final live = s
        .split('\n')
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n');
    expect(live, contains('store.updateAppointment(Appointment('));
    expect(live, contains('doctor: existing.doctor'));
    expect(live, isNot(contains('await store.deleteAppointment(existing.id)')));
  });

  test("0107 lets symptom severity be 'strong', the door's word", () {
    final sql = File('supabase/migrations/0107_preg_part2_sync_clock.sql')
        .readAsStringSync();
    expect(sql,
        contains("check (severity in ('mild','moderate','severe','strong'))"));
    expect(sql, contains('add column if not exists alarms jsonb'));
  });
}
