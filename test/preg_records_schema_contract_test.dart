// =============================================================================
//  Pregnancy records schema contract: medications, medication_logs, reminders
// -----------------------------------------------------------------------------
//  P1 (docs/preg-ttc-tool-plans/P1-lookups-records.md, Wave 1, 2026-10-28).
//
//  These three tables sync through `OwnRowLedger`, fire-and-forget. A column
//  the client writes that the SQL never declared fails SILENTLY: the phone
//  keeps working and the row never reaches the cloud. TTC pins its tables in
//  `ttc_schema_contract_test.dart`; these had no such pin.
//
//  Unlike the TTC test, the client side is not a hand-kept list. The columns
//  are read out of the stores' own row builders (`_toMedRow`, `_toLogRow`,
//  `_toRow`), so a column added to a store without a migration fails here
//  the same day. The ledger adds `user_id`, `updated_at` and `removed_at`.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

/// The quoted keys of the map literal a row builder returns.
List<String> _builderKeys(String source, String signature) {
  final start = source.indexOf(signature);
  // Outside a test, so a plain throw: `expect` cannot run at load time.
  if (start < 0) throw StateError('no $signature in the store');
  final end = source.indexOf('};', start);
  final body = source.substring(start, end);
  return RegExp(r"^\s*'([a-z_]+)':", multiLine: true)
      .allMatches(body)
      .map((m) => m.group(1)!)
      .toList();
}

/// The body of `create table public.<name> ( ... )`.
String _tableBody(String sql, String table) {
  final m = RegExp('create table (if not exists )?public\\.$table\\s*\\(')
      .firstMatch(sql);
  if (m == null) throw StateError('no create table for $table');
  var depth = 0;
  for (var i = m.end - 1; i < sql.length; i++) {
    if (sql[i] == '(') depth++;
    if (sql[i] == ')') {
      depth--;
      if (depth == 0) return sql.substring(m.end, i);
    }
  }
  throw StateError('unbalanced parentheses in $table');
}

/// Tables named in a migration's first `foreach t in array array[...]` loop,
/// which is where 0106 and 0107 add the sync clock columns.
Set<String> _clockLoop(String sql) {
  final start = sql.indexOf('foreach t in array array[');
  final end = sql.indexOf(']', start);
  return RegExp(r"'([a-z_]+)'")
      .allMatches(sql.substring(start, end))
      .map((m) => m.group(1)!)
      .toSet();
}

void main() {
  final medStore = _read('lib/services/medicine_store.dart');
  final remStore = _read('lib/services/reminder_store.dart');

  final created = _read('supabase/migrations/0005_health.sql') +
      _read('supabase/migrations/0007_calendar_reminders.sql');
  final m0106 = _read('supabase/migrations/0106_preg_part1_sync_clock.sql');
  final m0107 = _read('supabase/migrations/0107_preg_part2_sync_clock.sql');
  final m0113 = _read('supabase/migrations/0113_rows_keyed_per_person.sql');
  final clocked = {..._clockLoop(m0106), ..._clockLoop(m0107)};

  final written = <String, List<String>>{
    'medications': _builderKeys(medStore, 'Map<String, dynamic> _toMedRow('),
    'medication_logs':
        _builderKeys(medStore, 'Map<String, dynamic> _toLogRow('),
    'reminders': _builderKeys(remStore, 'Map<String, dynamic> _toRow('),
  };

  bool declared(String table, String column) {
    if (RegExp('^\\s*$column\\s', multiLine: true)
        .hasMatch(_tableBody(created, table))) {
      return true;
    }
    if ((column == 'updated_at' || column == 'removed_at') &&
        clocked.contains(table)) {
      return true;
    }
    return RegExp('alter table public\\.$table\\s+add column if not exists '
            '$column\\s')
        .hasMatch(m0107);
  }

  test('the row builders were found and are not empty', () {
    for (final e in written.entries) {
      expect(e.value, contains('id'), reason: e.key);
    }
    expect(written['medications'], contains('alarms'));
  });

  group('every column the client writes is declared', () {
    for (final e in written.entries) {
      test(e.key, () {
        for (final column in [
          ...e.value,
          'user_id',
          'updated_at',
          'removed_at'
        ]) {
          expect(declared(e.key, column), isTrue,
              reason: '${e.key}.$column is written by the client but no '
                  'migration declares it - every sync write fails silently');
        }
      });
    }
  });

  test('all three are keyed per person (0113), matching user_id,id', () {
    for (final table in written.keys) {
      expect(m0113.contains("'$table'"), isTrue,
          reason: '$table must be in 0113, or on conflict (user_id,id) errors');
    }
  });

  test('the ledgers name the right tables', () {
    expect(medStore, contains("OwnRowLedger('medications'"));
    expect(medStore, contains("OwnRowLedger('medication_logs'"));
    expect(remStore, contains("OwnRowLedger('reminders'"));
  });
}
