// =============================================================================
//  Contraction timer schema contract: contraction_sessions
// -----------------------------------------------------------------------------
//  P4 C9 (docs/preg-ttc-tool-plans/P4-birth-prep.md, 2026-10-28), the pattern
//  of `preg_her_week_schema_contract_test.dart`.
//
//  `contraction_sessions` syncs through `OwnRowLedger`, fire-and-forget, so a
//  column the client writes that no migration declares fails SILENTLY: the
//  phone keeps working and the row never reaches the cloud. The client side
//  is read out of the store's own row builder, never a hand-kept list. The
//  ledger adds `user_id`, `updated_at` and `removed_at`.
//
//  And the type, which is what C9 found: `date_iso` is a `date` column, so
//  the full ISO the app used to send had its time cut off by Postgres. The
//  row now sends the date part only; this pins both halves of that.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/services/tools_store.dart';

String _read(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

/// The quoted keys of the map literal a row builder returns.
List<String> _builderKeys(String source, String signature) {
  final start = source.indexOf(signature);
  if (start < 0) throw StateError('no $signature in the store');
  final end = source.indexOf('};', start);
  return RegExp(
    r"^\s*'([a-z_]+)':",
    multiLine: true,
  ).allMatches(source.substring(start, end)).map((m) => m.group(1)!).toList();
}

/// The body of `create table public.<name> ( ... )`, from all migrations.
String _tableBody(String sql, String table) {
  final m = RegExp(
    'create table (if not exists )?public\\.$table\\s*\\(',
  ).firstMatch(sql);
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
/// which is where 0107 adds the sync clock columns.
Set<String> _clockLoop(String sql) {
  final start = sql.indexOf('foreach t in array array[');
  if (start < 0) return {};
  final end = sql.indexOf(']', start);
  return RegExp(
    r"'([a-z_]+)'",
  ).allMatches(sql.substring(start, end)).map((m) => m.group(1)!).toSet();
}

void main() {
  const table = 'contraction_sessions';
  final tools = _read('lib/services/tools_store.dart');
  final screen = _read('lib/screens/tools/contraction_tracker_screen.dart');

  final all =
      (Directory('supabase/migrations').listSync().whereType<File>().toList()
            ..sort((a, b) => a.path.compareTo(b.path)))
          .map((f) => f.readAsStringSync().replaceAll('\r\n', '\n'))
          .join('\n');
  final clocked = _clockLoop(
    _read('supabase/migrations/0107_preg_part2_sync_clock.sql'),
  );
  final written = _builderKeys(
    tools,
    'Map<String, dynamic> _contractionToRow(',
  );

  bool declared(String column) {
    if (RegExp(
      '^\\s*$column\\s',
      multiLine: true,
    ).hasMatch(_tableBody(all, table))) {
      return true;
    }
    if ((column == 'updated_at' || column == 'removed_at') &&
        clocked.contains(table)) {
      return true;
    }
    return RegExp(
      'alter table (if exists )?public\\.$table\\s+add column '
      '(if not exists )?$column\\s',
    ).hasMatch(all);
  }

  test('the row builder was found and is not empty', () {
    expect(
      written,
      containsAll(['id', 'date_iso', 'contractions', 'labor_response']),
    );
  });

  test('every column the client writes is declared', () {
    for (final column in [...written, 'user_id', 'updated_at', 'removed_at']) {
      expect(
        declared(column),
        isTrue,
        reason:
            '$table.$column is written by the client but no migration '
            'declares it - every sync write fails silently',
      );
    }
  });

  test('the ledger names the right table', () {
    expect(
      tools,
      contains(
        "OwnRowLedger('contraction_sessions', 'contraction_sessions_sync')",
      ),
    );
  });

  group('C9: date_iso is a date, so the row sends a date', () {
    test('the column is declared as a date', () {
      expect(
        RegExp(
          r'^\s*date_iso\s+date\b',
          multiLine: true,
        ).hasMatch(_tableBody(all, table)),
        isTrue,
        reason:
            'if this ever becomes a timestamptz, the row can send the '
            'full time again and this contract should move with it',
      );
    });

    test('the row builder sends the date part, through contractionRowDate', () {
      final at = tools.indexOf('Map<String, dynamic> _contractionToRow(');
      final body = tools.substring(at, tools.indexOf('};', at));
      expect(body, contains("'date_iso': contractionRowDate(s.dateIso)"));
    });

    test('contractionRowDate keeps yyyy-MM-dd and nothing else', () {
      expect(
        ToolsStore.contractionRowDate('2026-10-28T03:14:15.926'),
        '2026-10-28',
      );
      expect(ToolsStore.contractionRowDate('2026-10-28'), '2026-10-28');
      expect(ToolsStore.contractionRowDate(''), isNull);
      expect(ToolsStore.contractionRowDate('not a date'), isNull);
    });
  });

  test('labor_response holds only what the screen writes', () {
    // 0003: check (labor_response in ('yes','no')). The screen sets these
    // two and nothing else; a third value would be refused by the cloud and
    // the whole row would fail, silently.
    expect(_tableBody(all, table), contains("labor_response in ('yes','no')"));
    final sets = RegExp(
      r"_setLabor\('([a-z]+)'\)",
    ).allMatches(screen).map((m) => m.group(1)).toSet();
    expect(sets, {'yes', 'no'});
  });
}
