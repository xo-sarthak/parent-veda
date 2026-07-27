// =============================================================================
//  The admin actions cannot be reached, bypassed, or performed unlogged.
// -----------------------------------------------------------------------------
//  These scan the migration SQL rather than the database, in the mould of
//  test/care_partner_config_test.dart. There is no Postgres in the test suite,
//  and the properties worth protecting here are textual anyway: a missing
//  `revoke execute` or a missing audit call is invisible at runtime until the
//  day someone asks who approved a doctor and the answer is "nobody knows".
//
//  Every one of these guards a specific way the panel could quietly become more
//  powerful than intended.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final actions =
      File('supabase/migrations/0051_admin_actions.sql').readAsStringSync();
  final audit =
      File('supabase/migrations/0050_admin_audit.sql').readAsStringSync();

  /// Every function the panel is meant to call. `_audit` is internal and is
  /// checked separately.
  const publicActions = <String>[
    'approve_care_partner',
    'deactivate_care_partner',
    'create_partner_campaign',
    'rotate_partner_tokens',
    'remove_demo_partners',
  ];

  group('admin actions are admin-only', () {
    for (final fn in publicActions) {
      test('$fn is security definer with a pinned search_path', () {
        // Without `security definer` the function runs as the caller and the
        // grants below become pointless. Without an empty search_path it can be
        // hijacked by a schema the caller controls.
        final body = _functionBody(actions, fn);
        expect(body, contains('security definer'),
            reason: '$fn must run with the definer\'s rights.');
        expect(body, contains("set search_path = ''"),
            reason: '$fn must pin its search_path.');
      });

      test('$fn execute is revoked from public', () {
        expect(
          RegExp('revoke execute on function\\s+public\\.$fn',
                  multiLine: true, dotAll: true)
              .hasMatch(actions),
          isTrue,
          reason: 'Without this, any authenticated app session can call $fn. '
              'Approval must never be self-service from the app the applicant '
              'controls.',
        );
      });

      test('$fn writes an audit row', () {
        final body = _functionBody(actions, fn);
        expect(body, contains('_audit('),
            reason: '$fn performs a privileged act without recording it. '
                'A Flow only logs that it ran, never what the database agreed to.');
      });
    }

    test('the internal audit writer is not callable by the panel either', () {
      expect(
        actions.contains('revoke execute on function\n  public._audit'),
        isTrue,
        reason: 'A caller who can write admin_audit directly can forge the '
            'record of their own actions.',
      );
    });
  });

  group('approval is a real gate, not a status change', () {
    final body = _functionBody(actions, 'approve_care_partner');

    test('it reads the verification record', () {
      expect(body, contains('care_partner_verification'),
          reason: 'Approval that does not look at the paperwork is a dropdown '
              'with extra steps.');
    });

    test('it refuses on missing or incomplete paperwork', () {
      expect('raise exception'.allMatches(body).length, greaterThanOrEqualTo(3),
          reason: 'The refusals ARE the feature. Expect one for a missing '
              'partner, one for a missing record, one for incomplete fields.');
      expect(body, contains('registration_expires_at'),
          reason: 'Licence expiry is checked at the one moment anyone reliably '
              'looks at it - when they are about to rely on it.');
    });
  });

  group('destructive acts require confirmation', () {
    test('rotation refuses unless the partner id is retyped', () {
      final body = _functionBody(actions, 'rotate_partner_tokens');
      expect(body, contains('p_confirm is distinct from p_partner_id'),
          reason: 'Rotation invalidates every printed QR - posters in clinics '
              'stop working. A boolean flag would be defaulted to true by the '
              'second caller who found it inconvenient.');
    });

    test('demo cleanup refuses if real history is attached', () {
      final body = _functionBody(actions, 'remove_demo_partners');
      expect(body, contains('partner_attributions'));
      expect(body, contains('commission_ledger'),
          reason: 'A demo partner carrying a real attribution is no longer '
              'only demo data.');
    });
  });

  group('the audit log and the paperwork stay private', () {
    test('admin_audit is append-only — nothing is granted update or delete', () {
      final grants = RegExp(r'grant[^;]*on\s+public\.admin_audit\b[^;]*;',
              caseSensitive: false, dotAll: true)
          .allMatches(audit)
          .map((m) => m.group(0)!.toLowerCase());
      for (final g in grants) {
        expect(g.contains('update'), isFalse,
            reason: 'An audit log you can edit is a diary: $g');
        expect(g.contains('delete'), isFalse, reason: 'Same: $g');
      }
    });

    test('the panel reads the log through a view, never the table', () {
      expect(audit, contains('create or replace view public.admin_audit_log'));
      expect(audit, contains('grant select on public.admin_audit_log to directus_cms'));
      expect(
        RegExp(r'grant[^;]*on\s+public\.admin_audit\s+to\s+directus_cms',
                caseSensitive: false)
            .hasMatch(audit),
        isFalse,
        reason: 'Granting the table gives a path to writing the record of your '
            'own actions. The view is the only door.',
      );
    });

    test('verification paperwork is never public-read', () {
      // care_partners is public-read by design, so these columns had to live
      // elsewhere. If a policy ever grants anon/authenticated here, a doctor's
      // council registration and KYC reference become world-readable.
      expect(audit, contains('alter table public.care_partner_verification enable row level security'));
      expect(audit, contains('revoke all on public.care_partner_verification from anon, authenticated'));
      expect(
        RegExp(r'create policy[^;]*on public\.care_partner_verification[^;]*to (anon|authenticated)',
                caseSensitive: false, dotAll: true)
            .hasMatch(audit),
        isFalse,
        reason: 'Verification paperwork must be service_role/CMS only.',
      );
    });
  });

  test('no second way to mint a token was introduced', () {
    // 0040 owns token creation. The actions here may CALL mint_partner_token,
    // but must never insert into partner_referrals themselves - a second
    // writer is how a QR that scans, looks right and credits nobody gets
    // printed and stuck to a wall for two years.
    expect(
      RegExp(r'insert\s+into\s+public\.partner_referrals', caseSensitive: false)
          .hasMatch(actions),
      isFalse,
      reason: 'Call mint_partner_token instead of inserting directly.',
    );
  });
}

/// The text of one `create or replace function public.<name>` block, up to the
/// `$$;` that closes it.
///
/// Throws rather than `expect`s, so it can be called from a group body as well
/// as from inside a test — `expect` outside a running test fails the whole file
/// to load, which reads as a broken test rather than a missing function.
String _functionBody(String sql, String name) {
  final start = sql.indexOf('create or replace function public.$name');
  if (start < 0) throw StateError('no function named $name in the migration');
  final end = sql.indexOf(r'$$;', start);
  if (end <= start) throw StateError('$name is not terminated');
  return sql.substring(start, end);
}
