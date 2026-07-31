// =============================================================================
//  An organisation is a partner, not a special case.
// -----------------------------------------------------------------------------
//  This file tests an ABSENCE, which is unusual and is the point. The rule is:
//
//      A doctor with their own clinic and a 400-bed hospital are the same
//      kind of thing. No gate branches on which one is calling.
//
//  The failure it guards against is not a crash. It is a hospital that signs
//  in, sees a dashboard, is invited to teach a masterclass — and then cannot
//  accept it, cannot see a booking, cannot set an hour and cannot write a
//  prescription. Every one of those fails silently or with an error about
//  something else ("not an expert account"), which is why nobody would find it
//  by using the app for five minutes.
//
//  So the check is: does any consulting gate still resolve the caller through
//  expert_accounts alone? One question, asked of the whole migration set.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Strip SQL comments before asserting something is absent — these files
/// explain at length what they no longer do, and a naive match fails on the
/// files that documented the decision best.
String _code(String sql) => sql
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('--'))
    .join('\n');

void main() {
  final dir = Directory('supabase/migrations');
  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.sql'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  /// The LAST definition wins in Postgres, so an early file resolving the
  /// caller narrowly is fine if a later one replaced it. Only the newest
  /// version of each object matters — which is exactly the mistake a
  /// grep-the-whole-repo test would make.
  String latestBodyOf(String objectName) {
    for (final f in files.reversed) {
      final sql = f.readAsStringSync();
      final i = sql.indexOf(objectName);
      if (i == -1) continue;
      // From the definition to the end of its $$ body.
      final end = sql.indexOf(r'$$;', i);
      return _code(sql.substring(i, end == -1 ? sql.length : end));
    }
    fail('$objectName is not defined in any migration');
  }

  final resolver =
      File('supabase/migrations/0073_one_partner_no_exceptions.sql')
          .readAsStringSync();

  group('there is one identity question', () {
    test('my_expert_ids() resolves a person AND an organisation', () {
      expect(resolver, contains('function public.my_expert_ids()'));
      // Route A — the person's own record.
      expect(resolver, contains('from public.expert_accounts ea'));
      // Route B — every doctor under an organisation. Reads expert_profiles,
      // not care_partners.expert_id, because that column holds at most one
      // expert: fine for a solo practitioner, useless for a hospital.
      expect(resolver, contains('join public.expert_profiles ep on ep.partner_id = pa.partner_id'));
    });

    test('it takes no argument, so it cannot answer about anyone else', () {
      expect(
        RegExp(r'my_expert_ids\s*\(\s*p_').hasMatch(resolver),
        isFalse,
      );
      expect(resolver, contains('where ea.user_id = auth.uid()'));
    });
  });

  group('no consulting gate branches on person-versus-organisation', () {
    // Each of these could be reached by a hospital login. If the newest
    // definition still resolves through expert_accounts directly, an
    // organisation is refused — silently, or with a message about the wrong
    // thing.
    const gates = <String>[
      'function public.respond_to_programme_assignment',
      'function public.expert_roster()',
      'function public.write_prescription',
    ];

    for (final g in gates) {
      test('$g uses the resolver', () {
        final body = latestBodyOf(g);
        expect(body, contains('my_expert_ids()'),
            reason: '$g still resolves the caller narrowly, so an '
                'organisation cannot use it.');
      });
    }

    test('the policies that let a doctor work were widened too', () {
      // Availability, schedule and prescriptions. A hospital that can see a
      // booking but cannot open a diary has a dashboard and no product.
      for (final p in const [
        'doctor_availability write',
        'doctor_schedule insert',
        'doctor_schedule update',
        'doctor_schedule delete',
        'prescriptions read',
      ]) {
        expect(resolver, contains('"$p"'),
            reason: '$p was not re-pointed at my_expert_ids().');
      }
      // Five policies, and every one of them must use the resolver.
      expect(
        'my_expert_ids()'.allMatches(resolver).length,
        greaterThanOrEqualTo(10),
        reason: 'each policy needs it in both using and with check.',
      );
    });

    test('an organisation can ACCEPT, through the same condition', () {
      // Not a second branch for organisations — ONE condition. Two host
      // columns would have been an exception in the schema, which is the
      // thing the rule forbids (and Postgres refused it anyway: expert_id is
      // half the primary key and a PK column cannot be nullable).
      final body =
          latestBodyOf('function public.respond_to_programme_assignment');
      expect(body, contains('pe.expert_id in (select public.my_expert_ids())'));
      expect(body.contains("raise exception 'not an expert account'"), isFalse,
          reason: 'that refusal WAS the exception this file removes.');
      expect(body.contains('pe.partner_id'), isFalse,
          reason: 'one host column. An organisation gets a deliverer row like '
              'everyone else, not a parallel column.');
    });

    test('an organisation has a deliverer row like everyone else', () {
      final t = File('supabase/migrations/0072_expert_profiles.sql')
          .readAsStringSync();
      // takes_consults is what let programme_experts stay unchanged: an org
      // that only teaches has a row with it false, rather than a second
      // column existing to describe it.
      expect(t, contains('takes_consults boolean'));
      expect(t.contains('add column if not exists partner_id text'), isFalse);
    });
  });

  group('the depth is possible, and deliberately not built', () {
    test('the roster says which doctor a booking belongs to', () {
      // A solo doctor never needed it — every row was theirs. A hospital
      // does, and it is what a per-clinician breakdown would be built on.
      final body = latestBodyOf('function public.expert_roster()');
      expect(body, contains('s.expert_id'));
    });

    test('per-doctor performance is named as future work, not implied', () {
      expect(resolver, contains('STILL LAYER TWO'));
      // The shape to copy already exists — an employer and its staff is the
      // same problem, already solved with the privacy thinking done.
      expect(resolver, contains('sponsor_dashboard'));
    });
  });

  group('a referral carries both layers', () {
    test('the token records WHO handed it over', () {
      // Apollo can see forty families arrived; without this it can never see
      // which of its clinicians brought them — the school knowing its average
      // and not its students.
      expect(resolver, contains('alter table public.partner_referrals'));
      expect(resolver, contains('add column if not exists expert_id text'));
      expect(resolver, contains('alter table public.partner_attributions'));
    });

    test('naming a person who is not theirs is refused', () {
      // A typo would credit one hospital's families to another's doctor, and
      // the number would look plausible forever.
      expect(resolver,
          contains("raise exception '% does not belong to %'"));
    });

    test('the old mint signature is DROPPED, not overloaded', () {
      // create-or-replace with a different arity creates an overload, and
      // then mint_partner_token('cp_x') is ambiguous — breaking 0051, 0052,
      // 0055 and 0069 at once with an error about function resolution.
      // 0052 hit exactly this.
      final dropped = RegExp(
              r'drop function if exists public\.mint_partner_token\(\s*text,\s*text,\s*text,\s*timestamptz\s*\);')
          .hasMatch(resolver);
      expect(dropped, isTrue,
          reason: 'the 4-arg signature must be dropped before the 5-arg one '
              'is created, or both exist and every short call is ambiguous.');
    });

    test('the breakdown gives numbers, never families', () {
      // Same line as the sponsor roster: a hospital learns how many it
      // introduced and by whom, never who they are.
      final body = latestBodyOf('function public.partner_referral_breakdown()');
      expect(body, contains('caller_owns_partner(a.partner_id)'));
      for (final leak in const ['user_id', 'a.token', 'due_date']) {
        expect(body.contains(leak), isFalse,
            reason: 'the breakdown must not expose $leak.');
      }
    });

    test('rotation dropping the person layer is recorded, not hidden', () {
      expect(resolver, contains('ROTATION DROPS THE PERSON LAYER'));
    });
  });

  test('a signed-in parent gets nothing from any of it', () {
    // my_expert_ids() returns rows only for a login mapped to an expert or a
    // partner. A parent matches neither, so every gate above closes for them
    // by the same mechanism rather than by a separate check.
    final body = latestBodyOf('function public.my_expert_ids()');
    expect(body, contains('auth.uid()'));
    expect(body.contains('true'), isFalse,
        reason: 'no unconditional branch may leak the roster to a parent.');
  });
}
