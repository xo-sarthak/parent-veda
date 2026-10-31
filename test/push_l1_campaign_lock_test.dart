// =============================================================================
//  Phase 6b leftover L1: an approved campaign's words are locked (0150)
// -----------------------------------------------------------------------------
//  The trigger runs in Postgres, which `flutter test` cannot run. The real
//  proof is supabase/seed/verify_push_campaign_lock.sql. This pins what can
//  drift without anyone noticing: that every column of push_campaigns is
//  either locked or named as free (a column added later must be sorted into
//  one or the other), that the trigger fires before update, the two status
//  rules, and that the app cannot call the function.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _migration = 'supabase/migrations/0150_push_campaign_lock.sql';
const _table = 'supabase/migrations/0143_push_campaigns_and_sends.sql';
const _verify = 'supabase/seed/verify_push_campaign_lock.sql';

/// The SQL with `--` comments removed, so a rule in a comment never passes.
String _live(String path) => File(path)
    .readAsStringSync()
    .split('\n')
    .map((l) {
      final i = l.indexOf('--');
      return i < 0 ? l : l.substring(0, i);
    })
    .join('\n');

/// push_campaigns' columns, as 0143 creates them.
List<String> _columns() {
  final m = RegExp(
    r'create table if not exists public\.push_campaigns \((.*?)\n\);',
    dotAll: true,
  ).firstMatch(_live(_table));
  expect(m, isNotNull);
  final out = <String>[];
  for (final line in m!.group(1)!.split('\n')) {
    final word = line.trim().split(RegExp(r'\s+')).first;
    if (const {'', 'constraint', 'check', 'and', 'or'}.contains(word)) continue;
    if (RegExp(r'^[a-z_]+$').hasMatch(word)) out.add(word);
  }
  return out;
}

/// The `new.` columns the trigger compares, in order.
List<String> _locked() {
  final m = RegExp(
    r'if \((new\..*?)\)\s*is distinct from\s*\((old\..*?)\)',
    dotAll: true,
  ).firstMatch(_live(_migration));
  expect(m, isNotNull, reason: 'the row comparison is missing');
  List<String> cols(String s, String side) => [
        for (final p in s.split(','))
          p.trim().replaceFirst('$side.', ''),
      ];
  final n = cols(m!.group(1)!, 'new');
  expect(cols(m.group(2)!, 'old'), n,
      reason: 'new and old must name the same columns in the same order');
  return n;
}

/// What stays writable once approved: the status (to cancelled), its two
/// timestamps, and created_at, which no writer has a reason to touch.
const _free = {'status', 'approved_at', 'cancelled_at', 'created_at'};

void main() {
  test('every column is locked or named free, none forgotten', () {
    final cols = _columns().toSet();
    final locked = _locked().toSet();
    expect(cols.difference(locked).difference(_free), isEmpty,
        reason: 'a new push_campaigns column must be added to the lock '
            'or to the free list here, on purpose');
    expect(locked.intersection(_free), isEmpty);
    expect(locked, containsAll(<String>[
      'id', 'kind', 'title', 'body', 'link_kind', 'link_id', 'stages',
      'week_from', 'week_to', 'child_months_from', 'child_months_to',
      'starts_on', 'ends_on', 'priority',
    ]));
  });

  test('the trigger fires before every update, row by row', () {
    final sql = _live(_migration);
    expect(
        sql,
        contains('create trigger push_campaigns_lock\n'
            '  before update on public.push_campaigns\n'
            '  for each row execute function public.pv_push_campaign_lock();'));
    expect(sql, contains('drop trigger if exists push_campaigns_lock'));
  });

  test('approved can only become cancelled; cancelled stays cancelled', () {
    final sql = _live(_migration);
    expect(sql, contains("if old.status = 'approved' then"));
    expect(sql, contains("if new.status not in ('approved', 'cancelled') then"));
    expect(sql,
        contains("if old.status = 'cancelled' and new.status <> 'cancelled' then"));
  });

  test('a refusal is a check_violation that names the table', () {
    final sql = _live(_migration);
    expect(RegExp(r"using errcode = 'check_violation'").allMatches(sql).length, 3);
    expect(RegExp(r"raise exception 'push_campaigns: ").allMatches(sql).length, 3);
  });

  test('the app cannot call it', () {
    expect(
        _live(_migration),
        contains('revoke all on function public.pv_push_campaign_lock() '
            'from public, anon, authenticated;'));
  });

  test('the admin functions write only what the lock allows', () {
    // pv_campaign_create rewrites drafts only; approve and cancel touch the
    // status and its timestamps. If either grew a locked column, the lock
    // would refuse the admin's own call.
    final t = _live(_table);
    expect(t, contains("where public.push_campaigns.status = 'draft';"));
    expect(t, contains("set status = 'approved', approved_at = now()"));
    expect(t, contains("set status = 'cancelled', cancelled_at = now()"));
  });

  test('the verify file tries every locked column', () {
    final v = File(_verify).readAsStringSync();
    for (final c in _locked()) {
      expect(v, contains("('$c',"), reason: 'verify does not try $c');
    }
  });
}
