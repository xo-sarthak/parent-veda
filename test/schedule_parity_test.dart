// =============================================================================
//  LA-29 · one schedule rule, two languages, one case table
// -----------------------------------------------------------------------------
//  The rule that turns a doctor's schedule into bookable times lives twice:
//  in Dart (`generateSlots`, which the parent's calendar and the doctor's
//  preview call) and in SQL (`_slot_fits_schedule`, migration 0128, which
//  book_slot calls before it creates a consult slot). Two copies drift unless
//  something holds them together.
//
//  flutter_test cannot run Postgres, so both are held to ONE table of cases,
//  `test/fixtures/schedule_parity_cases.json`:
//    * this file runs every case through the Dart rule;
//    * the migration carries the same cases (between the `$cases$` markers)
//      and `select * from public._schedule_parity_selftest()` runs them
//      through the SQL rule on the live database;
//    * this file fails if the migration's copy of the cases differs from the
//      fixture by one byte of meaning.
//  So a change to either rule has to pass the same table, and a change to the
//  table has to land in both places.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/doctor/doctor_schedule.dart';

List<Map<String, dynamic>> _fixture() =>
    (jsonDecode(
              File(
                'test/fixtures/schedule_parity_cases.json',
              ).readAsStringSync(),
            )
            as List)
        .cast<Map<String, dynamic>>();

/// The cases as the LAST migration that embeds them carries them.
List<dynamic> _migrationCases() {
  final files =
      Directory('supabase/migrations')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.sql'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  String? body;
  for (final f in files) {
    final sql = f.readAsStringSync();
    final m = RegExp(r'\$cases\$(.*?)\$cases\$', dotAll: true).firstMatch(sql);
    if (m != null) body = m.group(1);
  }
  if (body == null) fail('no migration carries the parity cases');
  return jsonDecode(body) as List;
}

bool _dartSays(Map<String, dynamic> c) {
  final raw = c['schedule'];
  final schedule = raw == null
      ? DoctorSchedule.starter
      : DoctorSchedule.fromMap(raw as Map);
  final now = istWallClock(DateTime.parse(c['now'] as String));
  final booked = {
    for (final b in (c['booked'] as List))
      istWallClock(DateTime.parse(b as String)),
  };
  final start = DateTime.parse(c['start'] as String);
  final slots = generateSlots(
    schedule,
    from: now,
    days: schedule.rules.advanceWindowDays,
    booked: booked,
    now: now,
  );
  return slots.any((s) => instantFromIstWallClock(s.start) == start);
}

void main() {
  test('the migration carries exactly the fixture\'s cases', () {
    expect(
      _migrationCases(),
      _fixture(),
      reason:
          'edit test/fixtures/schedule_parity_cases.json and the '
          r'$cases$ block in the migration together',
    );
  });

  group('the Dart rule answers every case', () {
    for (final c in _fixture()) {
      test(c['name'] as String, () {
        expect(_dartSays(c), c['expect'], reason: 'start ${c['start']}');
      });
    }
  });

  test('IST wall clock round-trips to the same instant', () {
    final t = DateTime.utc(2026, 11, 2, 4, 30);
    final wall = istWallClock(t);
    expect(wall.hour, 10);
    expect(instantFromIstWallClock(wall), t);
  });
}
