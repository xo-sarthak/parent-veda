// =============================================================================
//  Her week schema contract: weight_entries, movement_sessions, appointments,
//  completed_scans
// -----------------------------------------------------------------------------
//  P3 (docs/preg-ttc-tool-plans/P3-her-week.md, Wave 3, 2026-10-28), the
//  pattern of `preg_records_schema_contract_test.dart`.
//
//  These four sync through `OwnRowLedger`, fire-and-forget, so a column the
//  client writes that no migration declares fails SILENTLY: the phone keeps
//  working and the row never reaches the cloud. The client side is read out
//  of the stores' own row builders, never a hand-kept list, so a column added
//  to a store without a migration fails here the same day. The ledger adds
//  `user_id`, `updated_at` and `removed_at`.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

/// The quoted keys of the map literal a row builder returns.
List<String> _builderKeys(String source, String signature) {
  final start = source.indexOf(signature);
  if (start < 0) throw StateError('no $signature in the store');
  final end = source.indexOf('};', start);
  return RegExp(r"^\s*'([a-z_]+)':", multiLine: true)
      .allMatches(source.substring(start, end))
      .map((m) => m.group(1)!)
      .toList();
}

/// The body of `create table public.<name> ( ... )`, from all migrations.
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
  if (start < 0) return {};
  final end = sql.indexOf(']', start);
  return RegExp(r"'([a-z_]+)'")
      .allMatches(sql.substring(start, end))
      .map((m) => m.group(1)!)
      .toSet();
}

void main() {
  final tools = _read('lib/services/tools_store.dart');
  final scans = _read('lib/services/scans_store.dart');

  final all = (Directory('supabase/migrations').listSync().whereType<File>().toList()
        ..sort((a, b) => a.path.compareTo(b.path)))
      .map((f) => f.readAsStringSync().replaceAll('\r\n', '\n'))
      .join('\n');
  final clocked = {
    ..._clockLoop(_read('supabase/migrations/0106_preg_part1_sync_clock.sql')),
    ..._clockLoop(_read('supabase/migrations/0107_preg_part2_sync_clock.sql')),
  };

  final written = <String, List<String>>{
    'weight_entries':
        _builderKeys(tools, 'Map<String, dynamic> _weightEntryToRow('),
    'movement_sessions':
        _builderKeys(tools, 'Map<String, dynamic> _movementToRow('),
    'appointments': _builderKeys(scans, 'Map<String, dynamic> _toApptRow('),
    'completed_scans': _builderKeys(scans, 'Map<String, dynamic> _toScanRow('),
  };

  bool declared(String table, String column) {
    if (RegExp('^\\s*$column\\s', multiLine: true)
        .hasMatch(_tableBody(all, table))) {
      return true;
    }
    if ((column == 'updated_at' || column == 'removed_at') &&
        clocked.contains(table)) {
      return true;
    }
    return RegExp('alter table (if exists )?public\\.$table\\s+add column '
            '(if not exists )?$column\\s')
        .hasMatch(all);
  }

  test('the row builders were found and are not empty', () {
    expect(written['weight_entries'], containsAll(['id', 'week', 'weight']));
    expect(written['movement_sessions'], containsAll(['id', 'times']));
    expect(written['appointments'], containsAll(['id', 'date_iso', 'status']));
    expect(written['completed_scans'], contains('scan_id'));
  });

  group('every column the client writes is declared', () {
    for (final e in written.entries) {
      test(e.key, () {
        for (final column in [...e.value, 'user_id', 'updated_at', 'removed_at']) {
          expect(declared(e.key, column), isTrue,
              reason: '${e.key}.$column is written by the client but no '
                  'migration declares it - every sync write fails silently');
        }
      });
    }
  });

  test('the ledgers name the right tables', () {
    expect(tools, contains("OwnRowLedger('weight_entries'"));
    expect(tools, contains("OwnRowLedger('movement_sessions'"));
    expect(scans, contains("OwnRowLedger('appointments'"));
    expect(scans, contains("'completed_scans', 'completed_scans_sync'"));
  });
}
