// =============================================================================
//  The entitlement engine's invariants — client and SQL.
// -----------------------------------------------------------------------------
//  The client half is a rendering hint; the SQL half is the boundary. These
//  tests hold the line between them, because the failure mode is quiet: a
//  capability that is only ever checked in Dart looks like it works, right up
//  until someone calls the API directly.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/entitlement_store.dart';

void main() {
  final engine =
      File('supabase/migrations/0057_entitlement_engine.sql').readAsStringSync();
  final sponsors =
      File('supabase/migrations/0058_sponsors_and_activation.sql')
          .readAsStringSync();

  group('the client store is a rendering hint, not a boundary', () {
    test('an unknown capability is denied, never assumed', () {
      final s = EntitlementStore.instance..setForTest(capabilities: {Caps.sponsorEvents});
      expect(s.can(Caps.sponsorEvents), isTrue);
      expect(s.can(Caps.consultationCredit), isFalse);
      expect(s.can('a_capability_this_build_has_never_heard_of'), isFalse);
    });

    test('no sponsor means no capabilities and no crash', () {
      final s = EntitlementStore.instance..setForTest();
      expect(s.isSponsored, isFalse);
      expect(s.capabilities, isEmpty);
      expect(s.sponsor, isNull);
    });
  });

  group('access is decided server-side', () {
    test('has_capability derives the user from auth.uid(), never a parameter', () {
      // If the user id were an argument, any caller could ask about anyone.
      expect(engine, contains('has_capability(p_capability text)'));
      expect(engine, contains('ue.user_id = auth.uid()'));
      expect(
        RegExp(r'has_capability\([^)]*p_user_id').hasMatch(engine),
        isFalse,
        reason: 'has_capability must not take a user id — it answers about the '
            'caller or it answers nothing.',
      );
    });

    test('a user cannot grant themselves a plan', () {
      // Own-row READ is fine; a write policy would let anyone mint Premium.
      expect(engine, contains('user_entitlements own read'));
      expect(
        RegExp(r'create policy[^;]*on public\.user_entitlements[^;]*for '
                r'(insert|update|all)', caseSensitive: false, dotAll: true)
            .hasMatch(engine),
        isFalse,
        reason: 'No client write policy on user_entitlements.',
      );
    });

    test('granting and revoking are revoked from public', () {
      for (final fn in const ['grant_plan', 'revoke_plan_by_source']) {
        expect(
          RegExp('revoke execute on function\\s+public\\.$fn',
                  dotAll: true, multiLine: true)
              .hasMatch(engine),
          isTrue,
          reason: '$fn must not be callable by an app session.',
        );
      }
    });
  });

  group('activation cannot be faked or farmed', () {
    test('the one-time code is never returned to the caller', () {
      // Returning it would make proving control of the address theatre.
      expect(sponsors, contains('The code is NOT returned'));
      expect(
        RegExp(r"jsonb_build_object\([^)]*'code',\s*v_code").hasMatch(sponsors),
        isFalse,
        reason: 'The generated code must not appear in the response body.',
      );
    });

    test('unknown domains and inactive customers give the SAME answer', () {
      // Otherwise this endpoint enumerates who bought ParentVeda.
      expect(sponsors, contains('not_eligible'));
      expect(
        'not_eligible'.allMatches(sponsors).length,
        greaterThanOrEqualTo(1),
        reason: 'One vague code must cover both eligibility failures.',
      );
    });

    test('codes expire, are attempt-limited, and are single use', () {
      expect(sponsors, contains('expires_at'));
      expect(sponsors, contains('too_many_attempts'));
      expect(sponsors, contains('consumed_at'));
      expect(sponsors, contains('too_many_requests'),
          reason: 'Without a rate limit this is free mail to any address at a '
              'customer domain.');
    });

    test('one work email can only ever activate once', () {
      expect(sponsors, contains('sponsor_members_email_idx'),
          reason: 'Without a unique index on the work email, forwarding an '
              'invite around a group chat is a seat farm.');
    });

    test('eligibility is re-checked at the moment of granting', () {
      // Ten minutes is long enough for the last seat to go.
      expect(sponsors, contains('Re-check eligibility at the moment of granting'));
    });
  });

  group('the sensitive tables stay sensitive', () {
    test('sponsor_domains is not public — it is a customer list', () {
      expect(sponsors,
          contains('revoke all on public.sponsor_domains from anon, authenticated'));
    });

    test('membership and codes are never handed to the CMS', () {
      for (final t in const ['sponsor_members', 'sponsor_activation_codes']) {
        expect(
          RegExp('grant[^;]*on\\s+public\\.$t\\s+to\\s+directus_cms',
                  caseSensitive: false, dotAll: true)
              .hasMatch(sponsors),
          isFalse,
          reason: '$t says where a person works, or is a credential in '
              'flight. Neither is a form to edit.',
        );
      }
    });
  });

  test('leaving a company removes only what that company granted', () {
    // Someone who bought Premium themselves must keep it. That is why
    // user_entitlements records a source at all.
    expect(engine, contains('revoke_plan_by_source'));
    expect(sponsors, contains("revoke_plan_by_source(p_user_id, 'sponsor'"));
  });

  test('the gates return refusals rather than raising them', () {
    // 0055's lesson: a raise aborts the transaction and discards the audit
    // row written a line earlier, so the blocked attempt leaves no trace.
    for (final sql in [engine, sponsors]) {
      expect(sql, contains('_refuse('));
      expect(sql, contains('_allow('));
    }
    expect(
      RegExp(r'raise exception').hasMatch(sponsors),
      isFalse,
      reason: 'Activation gates must return, not raise.',
    );
  });
}
