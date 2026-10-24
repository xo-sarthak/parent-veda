// =============================================================================
//  Rows keyed per person (2026-10-24, sync log step 14, migration 0113, B9)
// -----------------------------------------------------------------------------
//  The phone makes row ids, and some are built from a date or a name, so two
//  people's phones make the same one. A table-wide `id` key let the first
//  account own that row for ever and RLS refused everyone else's upload,
//  silently. 0113 keys those tables on (user_id, id); the app's upserts must
//  conflict on the same pair, or every write errors once 0113 has run.
//
//  These checks read the source, so a new table or a stray `onConflict: 'id'`
//  fails here rather than on a phone.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/family_timeline.dart';

import 'ttc_schema_contract_test.dart' show rekeyedTables;

const _expected = {
  // Collide today: ids from a date or a name.
  'ttc_cycles', 'ttc_cycle_signals', 'journey_timeline', 'symptom_logs',
  'journal_entries', 'reminders', 'weight_entries', 'movement_sessions',
  // The rest of the OwnRowLedger `id` tables: one rule, not a flag per table.
  'bump_photos', 'calendar_personal_events', 'baby_talk', 'medications',
  'medication_logs', 'weekly_journal_notes', 'appointments',
  'contraction_sessions',
  // Shares the journal's upsert.
  'father_journal_entries',
};

/// A file's code with whole-line comments removed.
String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

Iterable<File> _dart(String dir) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'));

void main() {
  group('sync: rows keyed per person (B9, 0113)', () {
    test('0113 re-keys exactly the 17 tables', () {
      expect(rekeyedTables(), _expected);
      final sql = File('supabase/migrations/0113_rows_keyed_per_person.sql')
          .readAsStringSync();
      expect(sql, contains('add primary key (user_id, id)'));
      // The constraint name is looked up, never guessed.
      expect(sql, contains("contype = 'p'"));
    });

    test('every OwnRowLedger table keyed on id is re-keyed', () {
      final ledger = RegExp(r"OwnRowLedger\(\s*'(\w+)',\s*'\w+'\s*(,[^)]*)?\)");
      final tables = <String>{};
      for (final f in _dart('lib')) {
        for (final m in ledger.allMatches(_code(f.path))) {
          final rest = m.group(2) ?? '';
          if (rest.contains('keyColumn:')) continue; // its own natural key
          tables.add(m.group(1)!);
        }
      }
      expect(tables, isNotEmpty);
      expect(tables.difference(_expected), isEmpty,
          reason: 'a ledger table on `id` that 0113 does not re-key: its '
              'upserts would conflict on a key that does not exist');
    });

    test('the ledger conflicts on user_id + key for every keyed table', () {
      final code = _code('lib/services/remote/own_row_ledger.dart');
      expect(code,
          contains("String get onConflict => single ? 'user_id' : 'user_id,\$keyColumn';"));
    });

    test("no write to a re-keyed table is left on onConflict: 'id'", () {
      final bad = <String>[];
      for (final path in [
        'lib/ttc/cycle_store.dart',
        'lib/services/family_timeline.dart',
        'lib/services/journal_sync.dart',
        'lib/services/tools_store.dart',
      ]) {
        if (_code(path).contains("onConflict: 'id'")) bad.add(path);
      }
      expect(bad, isEmpty);
      // And the stores that write these tables by name do it per person.
      for (final f in _dart('lib')) {
        final code = _code(f.path);
        for (final t in _expected) {
          final call = RegExp("upsert\\w*\\(\\s*'$t',[^;]*onConflict: 'id'");
          if (call.hasMatch(code)) bad.add('${f.path} ($t)');
        }
      }
      expect(bad, isEmpty);
    });
  });

  group('sync: the shared timeline keeps one entry per event', () {
    Map<String, dynamic> row(String id, String uid) =>
        {'id': id, 'user_id': uid, 'title_en': '$id by $uid'};

    test('her own row wins over the partner\'s copy of the same event', () {
      final out = FamilyTimeline.preferOwnRows(
          [row('pregnancy_started', 'him'), row('pregnancy_started', 'me')],
          'me');
      expect(out, hasLength(1));
      expect(out.single['user_id'], 'me');
    });

    test('a partner\'s event she has no copy of stays', () {
      final out = FamilyTimeline.preferOwnRows(
          [row('ttc_ms_first_cycle', 'him'), row('baby_born', 'me')], 'me');
      expect(out.map((r) => r['id']),
          containsAll(['ttc_ms_first_cycle', 'baby_born']));
    });

    test('signed out: rows pass through untouched', () {
      final rows = [row('a', 'x'), row('a', 'y')];
      expect(FamilyTimeline.preferOwnRows(rows, null), rows);
    });

    test('the pull uses it', () {
      expect(_code('lib/services/family_timeline.dart'),
          contains('applyCloudRows(preferOwnRows(rows, SupabaseRepo.userId));'));
    });
  });
}
