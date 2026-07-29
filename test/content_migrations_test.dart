// =============================================================================
//  Every content table is wired the same way — and only content tables are.
// -----------------------------------------------------------------------------
//  Adding a content type is a five-step recipe (docs/CONTENT-BACKEND.md), and
//  two of those steps fail SILENTLY when skipped:
//
//    * forget the `grant ... to directus_cms` and the collection simply never
//      appears in Directus. No error. It reads as "Directus is being difficult".
//    * forget the `for all to directus_cms` POLICY and it appears, works, and
//      hides the editor's own drafts — because the only other policy on the
//      table is `using (status = 'published')`. That one is worse, because it
//      looks like the save button is broken.
//
//  The mirror of that is the dangerous direction: a `to directus_cms` grant on
//  a table that is NOT content would hand an editor something they should never
//  see. 0045 is deliberately an allow-list for exactly this reason, and the
//  last test here is what stops the list growing by accident.
//
//  Scans the migration SQL, like test/admin_actions_test.dart — no database.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/content_registry.dart';

void main() {
  final migrations = Directory('supabase/migrations')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.sql'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final allSql = migrations.map((f) => f.readAsStringSync()).join('\n');

  /// Tables the CMS role is legitimately granted, beyond the content tables
  /// every store declares. Each one is a deliberate decision, so each one is
  /// listed by hand rather than pattern-matched.
  const allowedNonContentGrants = <String, String>{
    'articles': 'the first content type (0019), predates the registry',
    'content_posts': "the website's articles",
    'content_categories': "the website's taxonomy",
    'content_authors': 'author profiles — public credentials only; the private '
        'paperwork stays in care_partner_verification',
    'referral_config': 'config — select+update only',
    'care_visibility_rules': 'config — select+update only',
    'care_trust_messages': 'config — select+update only',
    'care_commission_rules': 'config — select+update only',
    'care_partner_config': 'config — select+update only',
    'wa_message_templates': 'config — select+update only',
    'care_partners': 'read only; writes go through 0040/0051 functions',
    'partner_referrals': 'read only; tokens are minted, never inserted',
    'care_partner_verification': 'the paperwork behind an approval (0050)',
    'admin_audit_log': 'a VIEW, read only — never the admin_audit table',
    'veda_drafts': "Ask Veda's editorial inbox",
    'veda_content_gaps': 'the what-to-write-next board',
    'programmes': 'ParentVeda owns one-to-many products; experts only deliver',
    'programme_sessions': 'the schedule, authored with the programme',
    'programme_experts': 'assignment is an admin act; ACCEPTANCE is the expert\'s',
    'programme_coupons': 'discounts — not public-read, validated via a function',
    'capabilities': 'the access registry — Internal Admin manages plans',
    'plans': 'bundles of capabilities; making something Premium is a row here',
    'plan_capabilities': 'the entitlement matrix itself',
    'sponsors': 'organisations sponsoring a plan — ops manages these',
    'sponsor_domains': 'the eligibility rule; NOT public-read (a customer list)',
    'public_email_domains': 'the consumer-provider block list (0062) — ops may '
        'ADD to it when a customer\'s staff use a provider not listed, but '
        'note there is deliberately no delete grant: removing gmail.com from '
        'it is the exact move that makes every Gmail account eligible',
    'sponsor_eligible_people': 'the staff list HR sends us (0061) — this is '
        'the table the CSV lands in, so if the panel cannot write it, '
        'onboarding a customer stays an engineering ticket forever. It is '
        'ELIGIBILITY ("Acme pays for priya@acme.com"), not MEMBERSHIP '
        '("priya@acme.com uses ParentVeda") — the second is sponsor_members '
        'and is deliberately still absent from this list',
    'sponsor_analytics_config': 'the k-anonymity threshold for HR analytics '
        '(0060) — select+update only, and it exists as a row precisely so a '
        'privacy decision can be tightened without a release',
  };

  /// True when the store reads a VIEW rather than a base table. Views play by
  /// different rules: they carry no RLS policies of their own, and the CMS
  /// edits the tables underneath rather than the view, so the table checks
  /// below would be wrong rather than merely noisy.
  bool isView(String name) => RegExp(
          'create (or replace )?view\\s+(public\\.)?$name\\b',
          caseSensitive: false)
      .hasMatch(allSql);

  group('every content-backed VIEW is read-only and public', () {
    for (final store in ContentRegistry.stores.where((s) => isView(s.table))) {
      final view = store.table;

      test('$view is granted select to the app', () {
        expect(
          RegExp('grant select on\\s+(public\\.)?$view\\s+to[^;]*anon',
                  caseSensitive: false, dotAll: true)
              .hasMatch(allSql),
          isTrue,
          reason: 'The app reads $view with the anon key; without this every '
              'fetch fails silently and the store serves nothing.',
        );
      });

      test('$view is NOT granted to the CMS role', () {
        // A view is a read shape. Granting it to Directus offers an editor a
        // duplicate of data they already have, in a form that cannot be
        // written back — two places showing the same thing, one of them inert.
        expect(
          RegExp('grant[^;]*on\\s+(public\\.)?$view\\s+to\\s+directus_cms',
                  caseSensitive: false, dotAll: true)
              .hasMatch(allSql),
          isFalse,
          reason: 'Edit the underlying tables, not $view.',
        );
      });
    }
  });

  group('every registered content table is fully wired', () {
    for (final store in ContentRegistry.stores.where((s) => !isView(s.table))) {
      final table = store.table;

      test('$table has a published-only public read policy', () {
        expect(
          RegExp('create policy[^;]*on public\\.$table[^;]*for select'
                  '[^;]*using\\s*\\(\\s*status\\s*=\\s*\'published\'',
                  caseSensitive: false, dotAll: true)
              .hasMatch(allSql),
          isTrue,
          reason: 'Without this the app reads nothing — or worse, reads drafts.',
        );
      });

      test('$table grants the CMS role full CRUD', () {
        expect(
          // \s+ not a literal space: 0045 aligns its grants into columns.
          RegExp('grant[^;]*on\\s+public\\.$table\\s+to\\s+directus_cms',
                  caseSensitive: false, dotAll: true)
              .hasMatch(allSql),
          isTrue,
          reason: 'Step 2 of the add-a-type recipe. Without it $table never '
              'appears in Directus, with nothing anywhere saying why.',
        );
      });

      test('$table has a CMS policy so drafts are visible to editors', () {
        expect(
          RegExp('create policy[^;]*on public\\.$table[^;]*for all[^;]*'
                  'to directus_cms', caseSensitive: false, dotAll: true)
              .hasMatch(allSql),
          isTrue,
          reason: 'A grant gets past the privilege check; the POLICY is what '
              'lets an editor see their own draft. Without it Directus works '
              'and hides unpublished rows, which looks like a broken save.',
        );
      });

      test('$table has no client write policy', () {
        // Content is admin-write only. A stray insert/update policy for anon or
        // authenticated would let the app rewrite the content it reads.
        expect(
          RegExp('create policy[^;]*on public\\.$table[^;]*for '
                  '(insert|update|delete|all)[^;]*to (anon|authenticated)',
                  caseSensitive: false, dotAll: true)
              .hasMatch(allSql),
          isFalse,
          reason: '$table must be public-READ, admin-write.',
        );
      });
    }
  });

  test('the CMS role is granted nothing beyond the allow-list', () {
    // The highest-severity failure available in this repo: an editor login
    // reaching a table of user data. 0045 is an allow-list precisely so that
    // adding a grant is a deliberate act — this is what makes it stay one.
    final contentTables =
        ContentRegistry.stores.map((s) => s.table).toSet();

    final granted = RegExp(
            r'grant[^;]*?on\s+(?:table\s+)?public\.([a-z_]+)\s+to\s+directus_cms',
            caseSensitive: false, dotAll: true)
        .allMatches(allSql)
        .map((m) => m.group(1)!.toLowerCase())
        .toSet();

    final unexpected = granted
        .where((t) =>
            !contentTables.contains(t) &&
            !allowedNonContentGrants.containsKey(t))
        .toList()
      ..sort();

    expect(
      unexpected,
      isEmpty,
      reason: 'These tables grant the CMS role access but are not registered '
          'content and are not on the reviewed allow-list: '
          '${unexpected.join(', ')}.\n'
          'If that is intended, add each one to allowedNonContentGrants in '
          'this test WITH THE REASON — that list is the review, and an entry '
          'without a reason is not one.',
    );
  });

  test('no user-data table is ever granted to the CMS role', () {
    // Belt and braces over the test above, naming the tables whose exposure
    // would matter most. These are the ones a mis-click would be worst on.
    const neverExpose = <String>[
      'profiles', 'journal_entries', 'photo_memories', 'bump_photos',
      'medication_logs', 'symptom_logs', 'ttc_journal', 'ttc_cycles',
      'pp_reports', 'pp_documents', 'children', 'user_state',
      'booking_bookings', 'commission_ledger', 'profile_events',
      'admin_audit',
    ];

    for (final table in neverExpose) {
      expect(
        RegExp('grant[^;]*on\\s+(?:table\\s+)?public\\.$table\\s+to[^;]*directus_cms',
                caseSensitive: false, dotAll: true)
            .hasMatch(allSql),
        isFalse,
        reason: '$table is granted to directus_cms. This is the failure 0045 '
            'exists to prevent — an editor account one mis-click from '
            "everyone's private data.",
      );
    }
  });

  test('migration numbers are unique and contiguous', () {
    // Four terminals share this sequence. A duplicate number applies in
    // whatever order the runner sorts it and the loser is never run — silently.
    // A gap is harmless but reads as a missing file, which has already cost one
    // round trip.
    final numbers = migrations
        .map((f) => f.uri.pathSegments.last.split('_').first)
        .map(int.parse)
        .toList()
      ..sort();

    expect(numbers.toSet().length, numbers.length,
        reason: 'Two migrations share a number; one of them will never run.');

    for (var i = 1; i < numbers.length; i++) {
      expect(numbers[i], numbers[i - 1] + 1,
          reason: 'Gap between ${numbers[i - 1]} and ${numbers[i]}. Claim a '
              'number when you write the file, never in advance.');
    }
  });
}
