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
    // 0044 (written since 2026-09, pinned 2026-10-27).
    'clinic_monitors', 'medication_controls', 'timing_ownership',
    // 0117 (T1, 2026-10-27): her "how long" pick and the start his phone shows.
    'trying_count_from', 'trying_count_date', 'trying_effective_start',
  ],
  // 0097 (2026-10-17): the merge clock, the soft delete and the bleed days.
  // Kept for revert: cycles ['id', 'user_id', 'started_on']; signals without
  // the two times; logs without removed_at.
  TtcTables.cycles: [
    'id', 'user_id', 'started_on', 'updated_at', 'removed_at', 'bleed_days',
  ],
  TtcTables.signals: [
    'id', 'user_id', 'cycle_start', 'kind', 'cycle_day', 'updated_at',
    'removed_at',
  ],
  TtcTables.logs: [
    'user_id', 'tracker', 'field', 'logged_on', 'value', 'note', 'updated_at',
    'removed_at',
  ],
  TtcTables.journal: [
    'id', 'user_id', 'author_id', 'kind', 'body', 'prompt', 'photo_path',
    'written_at',
  ],
  // 0099 (2026-10-17): the merge clock and the soft delete on supplements,
  // their ticks and the timeline. Kept for revert: without the two times.
  TtcTables.supplements: [
    'id', 'user_id', 'for_partner', 'name', 'dose', 'updated_at', 'removed_at',
  ],
  TtcTables.supplementTaken: [
    'user_id', 'supplement_id', 'taken_on', 'updated_at', 'removed_at',
  ],
  // 0098 (2026-10-17): the merge clock and the soft delete on the ritual,
  // the records and the appointments. Kept for revert: without the two times.
  TtcTables.ritual: [
    'user_id', 'part', 'completed_on', 'updated_at', 'removed_at',
  ],
  TtcTables.timeline: [
    'id', 'user_id', 'stage', 'kind', 'happened_on', 'title_en', 'title_hi',
    'detail_en', 'detail_hi', 'updated_at', 'removed_at',
  ],
  'ttc_records': [
    'id', 'user_id', 'test_id', 'label', 'value', 'unit', 'taken_on', 'note',
    'for_partner', 'updated_at', 'removed_at',
  ],
  'ttc_appointments': [
    'id', 'user_id', 'title', 'with_whom', 'starts_utc', 'note', 'updated_at',
    'removed_at',
  ],
  // 0092, 2026-09-28: the questions for the doctor left the journal for a
  // table of their own (TtcDoctorQuestionsStore.pushToCloud).
  // Kept for revert (2026-09-28): without the visit and the tick.
  //   'id', 'user_id', 'body', 'written_at', 'updated_at', 'removed_at',
  TtcTables.doctorQuestions: [
    'id', 'user_id', 'body', 'written_at', 'updated_at', 'removed_at',
    'appointment_id', 'asked_at',
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
  TtcTables.doctorQuestions: 'written_at',
};

/// The upsert conflict target for each table. Every one of these must be a
/// real primary key or unique constraint, or the upsert errors at runtime.
const Map<String, String> conflictTarget = {
  TtcTables.journeys: 'user_id',
  // 0113 (2026-10-24, B9): keyed per person. Kept for revert: 'id', 'id'.
  TtcTables.cycles: 'user_id,id',
  TtcTables.signals: 'user_id,id',
  TtcTables.logs: 'user_id,tracker,field,logged_on',
  TtcTables.journal: 'id',
  TtcTables.supplements: 'id',
  TtcTables.supplementTaken: 'supplement_id,taken_on',
  TtcTables.ritual: 'user_id,part,completed_on',
  TtcTables.timeline: 'user_id,id', // 0113. Kept for revert: 'id'
  'ttc_records': 'id',
  'ttc_appointments': 'id',
  TtcTables.doctorQuestions: 'id',
};

void main() {
  final sql = [
    File('supabase/migrations/0041_ttc.sql').readAsStringSync(),
    File('supabase/migrations/0042_ttc_records.sql').readAsStringSync(),
    File('supabase/migrations/0092_ttc_doctor_questions.sql')
        .readAsStringSync(),
  ].join('\n');

  /// Columns a later migration adds with `alter table ... add column`
  /// (0097, 0098 and 0099, 2026-10-17), per table.
  final altered = [
    File('supabase/migrations/0097_ttc_cycle_sync_clock.sql'),
    File('supabase/migrations/0098_ttc_records_ritual_sync_clock.sql'),
    File('supabase/migrations/0099_ttc_supplements_timeline_sync_clock.sql'),
    File('supabase/migrations/0044_ttc_care_pathway.sql'),
    File('supabase/migrations/0117_ttc_trying_count.sql'),
  ].map((f) => f.readAsStringSync()).join('\n').replaceAll('\r\n', '\n');
  // ⚠️ PER STATEMENT, NOT PER LINE (2026-10-27). The regex matched only the
  // first column after each `alter table`, so 0044's three-column alter could
  // never be pinned. Kept for revert:
  //   bool addedLater(String table, String column) => RegExp(
  //           'alter table public\\.$table\\s+add column if not exists '
  //           '$column\\s')
  //       .hasMatch(altered);
  bool addedLater(String table, String column) => altered
      .split(';')
      .where((st) => RegExp('alter table public\\.$table\\s').hasMatch(st))
      .any((st) =>
          RegExp('add column if not exists $column\\s').hasMatch('$st '));

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
    // Kept for revert (2026-09-28): 'all eleven'. Twelve with 0092.
    test('all twelve', () {
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
                  .hasMatch(body) ||
              addedLater(entry.key, column);
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

  // 0113 swaps the `id` primary key of the tables it names for
  // `(user_id, id)`, so for those the create-table body is no longer the key.
  final rekeyed = rekeyedTables();

  group('every upsert conflict target is a real key', () {
    for (final entry in conflictTarget.entries) {
      test('${entry.key} on (${entry.value})', () {
        final body = tableBody(entry.key);
        final columns = entry.value.split(',');
        final perPerson = rekeyed.contains(entry.key);

        if (columns.length == 1) {
          final c = columns.single;
          final isPk = !(perPerson && c == 'id') &&
              RegExp('^\\s*$c\\s.*primary key', multiLine: true)
                  .hasMatch(body);
          final isUnique = body.contains('unique ($c)');
          expect(isPk || isUnique, isTrue,
              reason: '${entry.key} upserts on $c, which is neither a primary '
                  'key nor unique - the upsert errors at runtime');
        } else {
          // A composite target must match a composite primary key or a unique
          // constraint, column for column and in order.
          final joined = columns.join(', ');
          final hasPk = body.contains('primary key ($joined)') ||
              (perPerson && joined == 'user_id, id');
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

    test('questions for the doctor: the couple reads, only the owner writes',
        () {
      // docs/FAMILY-MODEL.md: the person owns what she writes; her partner
      // may read, never write. So only the READ policy names the partner.
      String policy(String name) {
        final start = sql.indexOf('create policy $name');
        expect(start, greaterThan(-1), reason: 'no policy $name');
        return sql.substring(start, sql.indexOf(';', start));
      }

      expect(policy('ttc_doctor_questions_read'), contains('my_partner_id'));
      for (final name in [
        'ttc_doctor_questions_insert',
        'ttc_doctor_questions_update',
        'ttc_doctor_questions_delete',
      ]) {
        expect(policy(name), isNot(contains('my_partner_id')), reason: name);
        expect(policy(name), contains('auth.uid() = user_id'), reason: name);
      }
      expect(
          sql.contains(
              'alter table public.ttc_doctor_questions enable row level security'),
          isTrue);
    });

    test('the move from the journal is safe to run twice', () {
      // The backfill keeps each question's id, so it meets the phone's own
      // moved copy as one row, and a second run inserts nothing.
      final at = sql.indexOf('insert into public.ttc_doctor_questions');
      expect(at, greaterThan(-1));
      final stmt = sql.substring(at, sql.indexOf(';', at));
      expect(stmt, contains("where kind = 'question'"));
      expect(stmt, contains('on conflict (id) do nothing'));
    });

    test('a question names its visit and its tick, both optional (0092)', () {
      final body = tableBody(TtcTables.doctorQuestions);
      final visit = RegExp(r'^\s*appointment_id\s+text\s*,', multiLine: true);
      final asked = RegExp(r'^\s*asked_at\s+timestamptz\s*,', multiLine: true);
      expect(visit.hasMatch(body), isTrue,
          reason: 'appointment_id is nullable text: null is "the next visit"');
      expect(asked.hasMatch(body), isTrue,
          reason: 'asked_at is a nullable timestamp: null is "still to ask"');
      // No foreign key: it may name a booking, and a deleted visit must not
      // rewrite the question (its unticked questions roll forward, derived).
      final line = body
          .split('\n')
          .firstWhere((l) => l.trim().startsWith('appointment_id'));
      expect(line, isNot(contains('references')));
      // The policies did not change with the columns: still owner-only
      // writes and a couple read.
      expect(sql, contains('add column if not exists appointment_id text'));
      expect(sql, contains('add column if not exists asked_at timestamptz'));
    });

    // ⚠️ SUPERSEDED 2026-10-17 (0099, the user's decision). Append-only
    // meant no UPDATE grant, and an upsert needs UPDATE even for a new row,
    // so the timeline could never sync. Kept for revert:
    //   test('the timeline stays append-only', () {
    //     expect(RegExp(r'on public\.journey_timeline\s+for update')
    //         .hasMatch(sql), isFalse);
    //     expect(sql.contains(
    //         'grant select, insert, delete on public.journey_timeline'),
    //         isTrue);
    //   });
    test('the timeline: everyone updates only their own moments (0099)', () {
      final m = File(
              'supabase/migrations/0099_ttc_supplements_timeline_sync_clock.sql')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      final policy = RegExp(
              r'create policy journey_timeline_update on public\.journey_timeline\s+'
              r'for update\s+using \((.*?)\)\s+with check \((.*?)\);')
          .firstMatch(m);
      expect(policy, isNotNull, reason: 'an own-row update policy');
      for (final clause in [policy!.group(1)!, policy.group(2)!]) {
        expect(clause.trim(), 'auth.uid() = user_id');
        expect(clause, isNot(contains('my_partner_id')),
            reason: "a partner must never change the other's moment");
      }
      expect(m, contains('grant update on public.journey_timeline'));
      // Insert and delete stay own-row, as 0041 set them.
      expect(sql, contains('for insert with check (auth.uid() = user_id)'));
    });
  });
  // 0103 (2026-10-17): a partner reads her journey and treatment rows and may
  // never delete them. One `for all` policy allowed it, because `with check`
  // does not guard a DELETE (BACKEND-PATTERNS §16jj-b).
  test('the partner can read, never delete, her journey and treatment rows', () {
    final m = File('supabase/migrations/0103_ttc_partner_cannot_delete.sql')
        .readAsStringSync()
        .replaceAll('\r\n', '\n');
    for (final t in ['ttc_journeys', 'ttc_treatment']) {
      String policy(String cmd) {
        final start = m.indexOf('create policy ${t}_$cmd on public.$t');
        expect(start, greaterThan(-1), reason: '$t has no $cmd policy');
        return m.substring(start, m.indexOf(';', start));
      }

      expect(policy('select'), contains('my_partner_id'));
      for (final cmd in ['insert', 'update', 'delete']) {
        expect(policy(cmd), isNot(contains('my_partner_id')),
            reason: '$t $cmd must be own-row');
      }
    }
    expect(m, contains('drop policy if exists ttc_journeys_rw'));
    expect(m, contains('drop policy if exists ttc_treatment_couple'));
  });
}

/// The tables migration 0113 re-keys to `(user_id, id)`, read from its loop.
Set<String> rekeyedTables() {
  final sql = File('supabase/migrations/0113_rows_keyed_per_person.sql')
      .readAsStringSync();
  final loop = sql.substring(sql.indexOf('foreach t in array array['));
  final list = loop.substring(0, loop.indexOf(']'));
  return {for (final m in RegExp(r"'(\w+)'").allMatches(list)) m.group(1)!};
}
