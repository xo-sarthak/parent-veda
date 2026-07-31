// Product sampling — the claim has to reach somebody.
//
// The screen asks for a postal address, requires an unticked consent box to be
// ticked, and promises "ParentVeda posts it". Before 0071 the register handler
// wrote a local flag and DISCARDED the address: a parent saw a confirmation for
// a parcel nobody could send. The only place in the Brand Studio where the app
// told a user something untrue — and worse than a missing feature, because a
// missing feature looks missing.
//
// These tests hold the three promises printed on that screen, and the one rule
// that keeps them: the confirmation depends on the save.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/brand/brand_sampling.dart';

void main() {
  final sql = File('supabase/migrations/0071_brand_sample_claims.sql')
      .readAsStringSync();
  final dart = File('lib/brand/brand_sampling.dart').readAsStringSync();
  final screen = File('lib/brand/sampling_screen.dart').readAsStringSync();

  group('"the brand receives a COUNT, not your name or address"', () {
    test('there is no brand-facing read of the claims table at all', () {
      // Not a view with columns hidden — no access to a row to begin with.
      final policies = RegExp(
              r'create policy "[^"]*" on public\.brand_sample_claims[^;]*;',
              multiLine: true, dotAll: true)
          .allMatches(sql)
          .map((m) => m.group(0)!)
          .toList();
      expect(policies, isNotEmpty);
      for (final p in policies) {
        expect(p.contains('anon'), isFalse,
            reason: 'a signed-out reader could enumerate claims');
      }
      // The only roles that appear are the parent and the fulfilment desk.
      expect(sql.contains('to authenticated'), isTrue);
      expect(sql.contains('to directus_cms'), isTrue);
    });

    test('the count function cannot return anything identifying', () {
      final start = sql.indexOf('function public.brand_sample_counts(');
      expect(start, greaterThan(-1));
      final sig = sql.substring(start, sql.indexOf('language sql', start));
      for (final col in ['user_id', 'address', 'name', 'feedback']) {
        expect(sig.contains(col), isFalse,
            reason: 'brand_sample_counts must not return $col');
      }
      expect(sig.contains('bigint'), isTrue);
    });

    test('the app only ever asks for a count', () {
      expect(dart.contains('brand_sample_counts'), isTrue);
      // No method here could return a claimant. The API is the guarantee.
      expect(dart.contains('address'), isTrue); // it writes one
      expect(RegExp(r'Future<[^>]*>\s+claimants|listClaims|allClaims')
              .hasMatch(dart),
          isFalse,
          reason: 'nothing may read the claim list back into the app');
    });
  });

  group('"ParentVeda posts it"', () {
    test('the fulfilment desk can read the address and mark it posted, but '
        'not create or destroy a claim', () {
      expect(sql.contains('grant select, update on public.brand_sample_claims '
              'to directus_cms;'), isTrue);
      expect(
          RegExp(r'grant[^;]*insert[^;]*on public\.brand_sample_claims[^;]*'
                  r'to directus_cms')
              .hasMatch(sql),
          isFalse,
          reason: 'staff must not be able to invent a claim');
      expect(
          RegExp(r'grant[^;]*delete[^;]*on public\.brand_sample_claims')
              .hasMatch(sql),
          isFalse,
          reason: 'withdrawing a claim is a status change with a record, not '
              'a vanished row');
    });

    test('status is constrained, so a claim cannot drift into a state nothing '
        'handles', () {
      expect(sql.contains("check (status in ('claimed','posted','cancelled'))"),
          isTrue);
    });

    test('consent is stored, not assumed', () {
      expect(sql.contains('consent_at'), isTrue,
          reason: 'consent given at a moment is what has to be evidenced later');
    });
  });

  group('the confirmation depends on the save', () {
    test('register awaits the claim and switches on the result', () {
      expect(screen.contains('await BrandSampling.claim('), isTrue);
      for (final branch in [
        'SampleClaimResult.ok',
        'SampleClaimResult.alreadyClaimed',
        'SampleClaimResult.notSignedIn',
        'SampleClaimResult.failed',
      ]) {
        expect(screen.contains(branch), isTrue, reason: '$branch unhandled');
      }
    });

    test('markCompleted is reached only on a real claim', () {
      // The bug in one line: markCompleted used to run unconditionally.
      final idx = screen.indexOf('BrandStudioStore.instance.markCompleted');
      final claimIdx = screen.indexOf('await BrandSampling.claim(');
      expect(claimIdx, greaterThan(-1));
      expect(idx, greaterThan(claimIdx),
          reason: 'the local flag must be set AFTER the write, not before');
    });

    test('a double tap cannot fire two claims', () {
      expect(screen.contains('if (_saving'), isTrue);
      expect(screen.contains('!_saving &&'), isTrue,
          reason: 'the CTA must disable while saving');
      // And the database backs it up, because a guard on one device is not a
      // guarantee across two.
      expect(sql.contains('unique (campaign_id, user_id)'), isTrue);
    });
  });

  group('SampleClaimResult', () {
    test('distinguishes already-claimed from failed', () {
      // Collapsing these would either show an error to someone whose claim is
      // safely recorded, or a confirmation to someone whose is not.
      expect(SampleClaimResult.values, hasLength(4));
      expect(SampleClaimResult.values.contains(SampleClaimResult.alreadyClaimed),
          isTrue);
      expect(SampleClaimResult.values.contains(SampleClaimResult.failed), isTrue);
    });
  });
}
