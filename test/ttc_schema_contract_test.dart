// =============================================================================
//  TTC schema contract - the Dart writes must match the applied migrations
// -----------------------------------------------------------------------------
//  Every TTC cloud write is fire-and-forget (`.catchError((_) {})`), because a
//  network hiccup must never reach the UI. The cost of that is real: if a
//  column name in Dart and a column name in SQL ever disagree, the write fails
//  SILENTLY and the parent sees a perfectly working local app whose data never
//  leaves the phone.
//
//  Nothing else in the codebase would catch that - not a unit test, not a
//  widget test, and not a manual pass on a device, because the local half looks
//  identical either way. So the contract is pinned here, in the same spirit as
//  care_website_contract_test.dart, which runs the app's parser against the
//  website's real output.
//
//  WHAT THIS CATCHES: a column renamed or dropped in the SQL, a table renamed,
//  an order-by column that does not exist, or a NOT NULL column the client
//  never sends.
//
//  WHAT IT DOES NOT CATCH: a column the client stops writing. The expected
//  lists below are maintained by hand alongside the stores - which is the point
//  at which a human has to think, and is where the comment should be read.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/ttc/ttc_sync.dart';

/// Everything the client writes into each table, per `pushToCloud`.
const Map<String, List<String>> written = {
  TtcTables.journeys: [
    'user_id', 'journey_start', 'path', 'pregnancy_confirmed_on',
    'partner_joined', 'current_chapter', 'updated_at',
  ],
  TtcTables.cycles: ['id', 'user_id', 'started_on'],
  TtcTables.signals: [
    'id', 'user_id', 'cycle_start', 'kind', 'cycle_day',
  ],
  TtcTables.logs: [
    'user_id', 'tracker', 'field', 'logged_on', 'value', 'note', 'updated_at',
  ],
  TtcTables.journal: [
    'id', 'user_id', 'author_id', 'kind', 'body', 'prompt', 'photo_path',
    'written_at',
  ],
  TtcTables.supplements: [
    'id', 'user_id', 'for_partner', 'name', 'dose',
  ],
  TtcTables.supplementTaken: ['user_id', 'supplement_id', 'taken_on'],
  TtcTables.ritual: ['user_id', 'part', 'completed_on'],
  TtcTables.timeline: [
    'id', 'user_id', 'stage', 'kind', 'happened_on', 'title_en', 'title_hi',
    'detail_en', 'detail_hi',
  ],
  'ttc_records': [
    'id', 'user_id', 'test_id', 'label', 'value', 'unit', 'taken_on', 'note',
    'for_partner',
  ],
  'ttc_appointments': [
    'id', 'user_id', 'title', 'with_whom', 'starts_utc', 'note',
  ],
};

/// The column each read orders by. A missing one is a runtime error from
/// PostgREST, not a compile error, so it is worth pinning too.
const Map<String, String> orderedBy = {
  TtcTables.journeys: 'updated_at',
  TtcTables.cycles: 'started_on',
  TtcTables.signals: 'cycle_start',
  TtcTables.logs: 'logged_on',
  TtcTables.journal: 'written_at',
  TtcTables.supplements: 'created_at',
  TtcTables.supplementTaken: 'taken_on',
  TtcTables.ritual: 'completed_on',
  TtcTables.timeline: 'happened_on',
  'ttc_records': 'taken_on',
  'ttc_appointments': 'starts_utc',
};

/// The upsert conflict target for each table. Every one of these must be a
/// real primary key or unique constraint, or the upsert errors at runtime.
const Map<String, String> conflictTarget = {
  TtcTables.journeys: 'user_id',
  TtcTables.cycles: 'id',
  TtcTables.signals: 'id',
  TtcTables.logs: 'user_id,tracker,field,logged_on',
  TtcTables.journal: 'id',
  TtcTables.supplements: 'id',
  TtcTables.supplementTaken: 'supplement_id,taken_on',
  TtcTables.ritual: 'user_id,part,completed_on',
  TtcTables.timeline: 'id',
  'ttc_records': 'id',
  'ttc_appointments': 'id',
};

void main() {
  final sql = [
    File('supabase/migrations/0041_ttc.sql').readAsStringSync(),
    File('supabase/migrations/0042_ttc_records.sql').readAsStringSync(),
  ].join('\n');

  /// The body of one `create table public.<name> ( ... )` block.
  String tableBody(String table) {
    final start = sql.indexOf('create table if not exists public.$table');
    expect(start, greaterThan(-1), reason: 'no create table for $table');
    final open = sql.indexOf('(', start);
    // Walk to the matching close paren so nested parens in CHECK constraints
    // do not truncate the body.
    var depth = 0;
    for (var i = open; i < sql.length; i++) {
      if (sql[i] == '(') depth++;
      if (sql[i] == ')') {
        depth--;
        if (depth == 0) return sql.substring(open + 1, i);
      }
    }
    fail('unbalanced parentheses in $table');
  }

  group('every table the client uses exists', () {
    test('all eleven', () {
      for (final table in written.keys) {
        expect(sql.contains('create table if not exists public.$table'), isTrue,
            reason: 'the client writes to $table, which no migration creates');
      }
    });
  });

  group('every column the client writes exists in the migration', () {
    for (final entry in written.entries) {
      test(entry.key, () {
        final body = tableBody(entry.key);
        for (final column in entry.value) {
          // Column definitions start a line; the leading newline keeps this
          // from matching a column name inside a references/check clause.
          final declared = RegExp('^\\s*$column\\s', multiLine: true)
              .hasMatch(body);
          expect(declared, isTrue,
              reason:
                  '${entry.key}.$column is written by the client but is not '
                  'a column - every sync write to this table fails silently');
        }
      });
    }
  });

  group('every order-by column exists', () {
    for (final entry in orderedBy.entries) {
      test('${entry.key} orders by ${entry.value}', () {
        final body = tableBody(entry.key);
        final declared = RegExp('^\\s*${entry.value}\\s', multiLine: true)
            .hasMatch(body);
        expect(declared, isTrue,
            reason: '${entry.key} has no ${entry.value} column, so every read '
                'of it errors at runtime');
      });
    }
  });

  group('every upsert conflict target is a real key', () {
    for (final entry in conflictTarget.entries) {
      test('${entry.key} on (${entry.value})', () {
        final body = tableBody(entry.key);
        final columns = entry.value.split(',');

        if (columns.length == 1) {
          final c = columns.single;
          final isPk = RegExp('^\\s*$c\\s.*primary key', multiLine: true)
              .hasMatch(body);
          final isUnique = body.contains('unique ($c)');
          expect(isPk || isUnique, isTrue,
              reason: '${entry.key} upserts on $c, which is neither a primary '
                  'key nor unique - the upsert errors at runtime');
        } else {
          // A composite target must match a composite primary key or a unique
          // constraint, column for column and in order.
          final joined = columns.join(', ');
          final hasPk = body.contains('primary key ($joined)');
          final hasUnique = body.contains('unique ($joined)');
          expect(hasPk || hasUnique, isTrue,
              reason: '${entry.key} upserts on (${entry.value}) with no '
                  'matching composite key');
        }
      });
    }
  });

  group('nothing the client omits is NOT NULL without a default', () {
    // A NOT NULL column with no default that the client never sends makes every
    // insert fail - and fail silently, because the write is fire-and-forget.
    for (final entry in written.entries) {
      test(entry.key, () {
        final body = tableBody(entry.key);
        for (final line in body.split('\n')) {
          final trimmed = line.trim();
          if (!trimmed.contains('not null')) continue;
          if (trimmed.contains('default')) continue;
          if (trimmed.startsWith('constraint') ||
              trimmed.startsWith('primary key') ||
              trimmed.startsWith('unique')) {
            continue;
          }
          final column = trimmed.split(RegExp(r'\s+')).first;
          expect(entry.value.contains(column), isTrue,
              reason: '${entry.key}.$column is NOT NULL with no default and '
                  'the client never sends it - every insert would fail');
        }
      });
    }
  });

  group('the privacy shape survives', () {
    test('her cycle tables are own-row, with no partner read', () {
      for (final table in [TtcTables.cycles, TtcTables.signals]) {
        final start = sql.indexOf('create policy ${table}_own');
        expect(start, greaterThan(-1), reason: '$table has no own-row policy');
        final policy = sql.substring(start, sql.indexOf(';', start));
        expect(policy.contains('my_partner_id'), isFalse,
            reason: 'the partner must never be able to read $table');
      }
    });

    test('the journal cannot have its author forged', () {
      expect(sql.contains('author_id = auth.uid()'), isTrue);
    });

    test('the timeline stays append-only', () {
      expect(sql.contains('for update'), isFalse);
      expect(
          sql.contains(
              'grant select, insert, delete on public.journey_timeline'),
          isTrue);
    });
  });
}
