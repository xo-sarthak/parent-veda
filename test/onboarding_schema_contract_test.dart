// =============================================================================
//  Onboarding V3 schema contract (0102) - the Dart writes match the migration
// -----------------------------------------------------------------------------
//  Same reason as ttc_schema_contract_test.dart: the cloud writes these feed
//  are fire-and-forget, so a column name that disagrees between Dart and SQL
//  fails SILENTLY and the answer simply never leaves the phone. Source-reading
//  on both sides; no database here.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/services/family_profile.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

String _read(String path) => File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  final sql = _read('supabase/migrations/0102_onboarding_v3.sql');
  final repo = _read('lib/services/remote/supabase_repo.dart');
  final preg = _read('lib/services/pregnancy_controller.dart');
  final child = _read('lib/screens/post_pregnancy/pp_child_profile.dart');
  final plan = _read('lib/ttc/ttc_ready_plan_store.dart');

  bool adds(String table, String column) => RegExp(
          'alter table public\\.$table add column if not exists $column\\s')
      .hasMatch(sql);

  /// The quoted values inside the named check constraint.
  Set<String> checkValues(String constraint) {
    final at = sql.indexOf('add constraint $constraint');
    expect(at, isNot(-1), reason: '$constraint exists');
    final body = sql.substring(at, sql.indexOf(';', at));
    return {for (final m in RegExp(r"'([A-Za-z]+)'").allMatches(body)) m.group(1)!};
  }

  test('profiles: the due date keeps where it came from', () {
    expect(adds('profiles', 'due_date_source'), isTrue);
    expect(adds('profiles', 'dating_date'), isTrue);
    expect(preg, contains("'due_date_source': source.name"));
    expect(preg, contains("'dating_date':"));
    expect(preg, contains(".select('due_date_source')"));
  });

  test('the due-date source check allows exactly the Dart enum', () {
    expect(checkValues('profiles_due_date_source_check'),
        {for (final v in DueDateSource.values) v.name});
  });

  test('children: birth mode and born-early weeks', () {
    expect(adds('children', 'birth_mode'), isTrue);
    expect(adds('children', 'born_weeks'), isTrue);
    expect(child, contains("if (kChildBirthColumns) 'birth_mode': birthMode,"));
    expect(child, contains("if (kChildBirthColumns) 'born_weeks': bornWeeks,"));
    expect(checkValues('children_birth_mode_check'),
        {for (final v in BirthMode.values) v.name});
  });

  test('ttc_ready_plans: every column the plan store pushes exists', () {
    final at = sql.indexOf('create table if not exists public.ttc_ready_plans (');
    expect(at, isNot(-1));
    final body = sql.substring(at, sql.indexOf('\n);', at));
    const pushed = [
      'user_id', 'planned_start', 'already_trying', 'answers', 'made_at',
      'updated_at',
    ];
    for (final c in pushed) {
      expect(RegExp('^\\s*$c\\s', multiLine: true).hasMatch(body), isTrue,
          reason: 'column $c');
      expect(plan, contains("'$c':"), reason: 'the store sends $c');
    }
    // The upsert target must be the primary key.
    expect(body, contains('user_id        uuid primary key'));
    expect(plan, contains("onConflict: 'user_id'"));
  });

  test('ttc_ready_plans: the couple reads, only the owner writes', () {
    expect(sql, contains(
        'for select using (auth.uid() = user_id or user_id = public.my_partner_id())'));
    for (final p in ['insert', 'update', 'delete']) {
      expect(sql, contains('create policy ttc_ready_plans_$p'));
    }
    expect(sql, isNot(contains('on public.ttc_ready_plans\n  for all')),
        reason: 'one `for all` policy would let the partner delete her row');
  });

  test('link_as_partner refuses rather than re-pairing', () {
    expect(sql, contains("raise exception 'You are already linked with someone else'"));
    expect(sql, contains("raise exception 'That code is already linked with someone else'"));
    // Reached only through the repo (CLAUDE.md).
    expect(repo, contains("rpc('link_as_partner'"));
  });
}
