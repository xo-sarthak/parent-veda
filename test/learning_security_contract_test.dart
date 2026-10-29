// =============================================================================
//  L2a security contract — LA-1, LA-2, LA-3 (docs/LEARNING-ARCHITECTURE.md §5)
// -----------------------------------------------------------------------------
//  Reads the LAST definition of each function across the whole migration set,
//  not one file. That is the point: LA-2 happened because 0084 rewrote
//  book_slot and a test pinned to 0066's text kept passing while the live
//  function had lost the credit claim. `create or replace` swaps the whole
//  body, so the only definition that matters is the latest one.
//
//  Comment lines are stripped before any assertion, so a claim that survives
//  only as a comment ("the credit claim used to be here") does not count.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every migration, in the order Supabase applies them (filename order).
List<File> _migrations() {
  final files = Directory('supabase/migrations')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.sql'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return files;
}

String _code(String sql) => sql
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('--'))
    .join('\n');

/// The body of the last `create or replace function public.<name>(` across the
/// set, with the file it came from. Fails the test if there is none.
({String file, String body}) _lastDefinition(String name) {
  final head = 'create or replace function public.$name(';
  String? file;
  String? body;
  for (final f in _migrations()) {
    final code = _code(f.readAsStringSync());
    var at = code.lastIndexOf(head);
    if (at < 0) continue;
    final open = code.indexOf(r'$$', at);
    final close = code.indexOf(r'$$', open + 2);
    file = f.uri.pathSegments.last;
    body = code.substring(at, close);
  }
  if (body == null) fail('no definition of public.$name in supabase/migrations');
  return (file: file!, body: body);
}

void main() {
  group('LA-1 · expert_accounts is written only by functions', () {
    final all = _migrations().map((f) => _code(f.readAsStringSync())).join('\n');

    test('the 0030 write grant is revoked after it was given', () {
      final grant = all.indexOf(
          'grant select, insert, update on public.expert_accounts to authenticated');
      final revoke = all.indexOf(
          'revoke insert, update, delete on public.expert_accounts from authenticated');
      expect(grant, greaterThanOrEqualTo(0));
      expect(revoke, greaterThan(grant),
          reason: 'any account could name itself any expert (LA-1)');
      expect(all.lastIndexOf(RegExp(r'grant [a-z, ]*(insert|update)[a-z, ]* on public\.expert_accounts')),
          lessThan(revoke),
          reason: 'a later migration re-granted writes on expert_accounts');
    });

    test('dev_claim_expert writes only for an allowlisted tester', () {
      final d = _lastDefinition('dev_claim_expert');
      expect(d.body, contains('security definer'));
      expect(d.body, contains('from public.dev_testers where user_id = v_uid'));
      final gate = d.body.indexOf('public.dev_testers');
      final write = d.body.indexOf('insert into public.expert_accounts');
      expect(write, greaterThan(gate), reason: 'the write must sit behind the allowlist');
      expect(all, isNot(contains(RegExp(r'grant [a-z, ]+ on public\.dev_testers to (authenticated|anon)'))));
    });

    test('no app code writes expert_accounts directly', () {
      final lib = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      final writer = RegExp(
          r"(upsert|insert|update|upsertRow|upsertRowConfirmed|upsertRows)\(\s*'expert_accounts'");
      for (final f in lib) {
        final live = f.readAsStringSync()
            .split('\n')
            .where((l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        expect(writer.hasMatch(live), isFalse, reason: '${f.path} writes expert_accounts');
      }
      expect(File('lib/doctor/doctor_session.dart').readAsStringSync(),
          contains("callFunction('dev_claim_expert'"));
    });
  });

  group('LA-2 · the LAST book_slot claims a credit', () {
    final d = _lastDefinition('book_slot');

    test('it keeps 0084\'s price and 0066\'s credit claim', () {
      // (0128 realigned the argument list when the others gained defaults.)
      // Kept for revert: contains('p_price_paise  int  default null')
      expect(d.body, matches(RegExp(r'p_price_paise\s+int\s+default null')),
          reason: d.file);
      expect(d.body, contains('from public.consult_credits c'), reason: d.file);
      expect(d.body, contains('for update skip locked'), reason: d.file);
      expect(d.body, contains('set booking_id = v_booking.id, spent_at = now()'), reason: d.file);
      expect(d.body, contains("set paid_by = 'credit'"), reason: d.file);
      // Since 0126 (L2b) the booking records the SERVER's seat value, not
      // the phone's p_price_paise (LA-6). Kept for revert:
      // expect(d.body, contains("'upcoming', 'unpaid', p_price_paise"), reason: d.file);
      expect(d.body, contains("'upcoming', 'unpaid', v_seat_paise"), reason: d.file);
    });

    test('a consult credit is only spent on a one-seat slot', () {
      expect(d.body, contains("c.offering_scope = '*any_consult' and v_slot.capacity = 1"));
    });
  });

  group('LA-3 · the LAST open_session_room never creates a slot', () {
    final d = _lastDefinition('open_session_room');

    test('it reads an existing slot and inserts nothing', () {
      expect(d.body, isNot(contains('insert into public.booking_slots')), reason: d.file);
      expect(d.body, contains('from public.booking_slots s where s.id = p_slot_id'));
    });

    test('the stored expert decides, and every time is the stored row\'s', () {
      expect(d.body, contains('v_slot.expert_id not in (select public.my_expert_ids())'));
      final logic = d.body.substring(d.body.indexOf(r'$$'));
      for (final p in ['p_expert_id', 'p_starts_utc', 'p_duration_min', 'p_capacity', 'p_offering_id']) {
        expect(logic, isNot(contains(p)), reason: '$p is a phone value and must not be read');
      }
    });

    // Kept for revert (0123, six arguments):
    // test('the edge function still calls it with the arguments it declares', () {
    //   final edge = File('supabase/functions/livekit-token/index.ts').readAsStringSync();
    //   for (final p in ['p_slot_id', 'p_offering_id', 'p_expert_id', 'p_starts_utc', 'p_duration_min', 'p_capacity']) {
    //     expect(edge, contains('$p:'));
    //     expect(d.body, contains(p));
    //   }
    // });

    // (0128, expand) The last definition takes the slot alone, and the edge
    // function sends exactly that. PostgREST matches by argument names, so a
    // name sent that the function does not declare would match nothing.
    test('the edge function calls the 1-argument version with the slot alone', () {
      final edge = File('supabase/functions/livekit-token/index.ts').readAsStringSync();
      expect(edge, contains('.rpc("open_session_room", { p_slot_id: String(slotId) })'));
      for (final p in ['p_offering_id', 'p_expert_id', 'p_starts_utc', 'p_duration_min', 'p_capacity']) {
        expect(edge, isNot(contains('$p:')), reason: '$p is no longer declared');
      }
      expect(d.body, startsWith('create or replace function public.open_session_room(p_slot_id text)'));
    });
  });
}
