// =============================================================================
//  The sponsor programme's invariants.
// -----------------------------------------------------------------------------
//  Three kinds of check, and they are worth telling apart:
//
//  1. SQL TEXT. These assert the migrations say what they must. They cannot
//     prove a safeguard WORKS -- only that it is still there. The thing that
//     proves it works is supabase/seed/verify_sponsor_gates.sql, which runs the
//     functions against real tables inside a transaction that rolls back.
//  2. DART BEHAVIOUR. The credit bridge, and the refusal vocabulary.
//  3. WIRING. Correct-but-unreachable code is the failure this repo has
//     actually hit, so the call sites are asserted from the source.
//
//  The most valuable test in the file is the one that reads every refusal code
//  out of the SQL and demands the app knows what each one means. That is the
//  cross-repo shape of bug this codebase has had before: one half grows a case
//  the other half never hears about, and nothing errors -- the user just gets a
//  worse message than they should have.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/booking/booking_store.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/enterprise/enterprise_common.dart';
import 'package:parentveda/services/entitlement_store.dart';
import 'package:parentveda/services/sponsor_admin_store.dart';
import 'package:parentveda/services/sponsor_benefits.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final sponsorsSql =
      File('supabase/migrations/0058_sponsors_and_activation.sql')
          .readAsStringSync();
  final bypassSql =
      File('supabase/migrations/0059_sponsor_dev_bypass.sql').readAsStringSync();
  final adminSql =
      File('supabase/migrations/0060_sponsor_admin.sql').readAsStringSync();

  // ===========================================================================
  //  1. The demo door (0059)
  // ===========================================================================
  group('the dev bypass cannot become a real backdoor', () {
    test('it is per-sponsor, not a global flag', () {
      // A global switch is the version that gets left on. This one is a column
      // on one row, so a forgotten demo sponsor cannot weaken anybody else.
      expect(bypassSql, contains('add column if not exists dev_bypass_code'));
      expect(bypassSql, contains('v_spons.dev_bypass_code is not null'));
    });

    test('the real code is still required when no bypass is set', () {
      expect(bypassSql, contains('if v_row.code <> v_given and not v_bypass'));
    });

    test('the generated code is still never returned to the caller', () {
      // 0059 rewrote confirm_sponsor_activation. If that rewrite had loosened
      // request_sponsor_activation too, this is where it would show.
      expect(
        RegExp(r"jsonb_build_object\([^)]*'code',\s*v_code").hasMatch(bypassSql),
        isFalse,
      );
    });

    test('a bypassed activation is auditable as a distinct fact', () {
      // A backdoor you cannot find in the log is the one that stays.
      expect(bypassSql, contains('activated_dev_bypass'));
      expect(bypassSql, contains("case when v_bypass then 'activated_dev_bypass'"));
    });

    test('the attempt limit still applies to it', () {
      expect(bypassSql, contains('attempts = attempts + 1'));
      expect(bypassSql, contains('too_many_attempts'));
    });

    test('a short, guessable bypass string is refused by the database', () {
      expect(bypassSql, contains('sponsors_dev_bypass_len'));
      expect(bypassSql, contains('length(dev_bypass_code) >= 10'));
    });

    test('the CMS cannot set it, even though it may edit the sponsor', () {
      // A column-level revoke does NOT narrow an existing table-level grant,
      // so 0058's `grant ... on public.sponsors` had to be replaced with an
      // explicit column list. If someone re-broadens it, this fails.
      expect(bypassSql, contains('revoke insert, update on public.sponsors from directus_cms'));
      final grant = RegExp(r'grant insert \([^)]*\),\s*update \([^)]*\)\s*on public\.sponsors to directus_cms',
              dotAll: true)
          .firstMatch(bypassSql);
      expect(grant, isNotNull,
          reason: 'sponsors must be granted column-by-column after 0059.');
      expect(grant!.group(0), isNot(contains('dev_bypass_code')));
    });

    test('no migration ships a sponsor carrying one', () {
      // The demo sponsor lives in supabase/seed/, which is run deliberately.
      // A migration runs everywhere, including production.
      for (final f in Directory('supabase/migrations').listSync().whereType<File>()) {
        final sql = f.readAsStringSync();
        expect(
          RegExp(r"insert\s+into\s+public\.sponsors[^;]*dev_bypass_code",
                  caseSensitive: false, dotAll: true)
              .hasMatch(sql),
          isFalse,
          reason: '${f.path} seeds a sponsor with a bypass code.',
        );
      }
    });
  });

  // ===========================================================================
  //  2. The HR wall (0060)
  // ===========================================================================
  group('HR sees numbers, never people', () {
    test('the roster returns no user id — the promise is a signature', () {
      // A caller cannot select a column the function does not return, so this
      // is stronger than a policy: it is the shape of the type.
      final ret = RegExp(
              r'create or replace function public\.sponsor_roster\(\)\s*returns table \(([^)]*)\)',
              dotAll: true)
          .firstMatch(adminSql);
      expect(ret, isNotNull);
      expect(ret!.group(1), isNot(contains('user_id')));
      expect(ret.group(1), isNot(contains('uuid')));
    });

    test('the roster carries nothing behavioural', () {
      final ret = RegExp(
              r'create or replace function public\.sponsor_roster\(\)\s*returns table \(([^)]*)\)',
              dotAll: true)
          .firstMatch(adminSql)!
          .group(1)!;
      for (final leak in const [
        'booking', 'consult', 'last_seen', 'due_date', 'child', 'name'
      ]) {
        expect(ret.contains(leak), isFalse,
            reason: 'sponsor_roster must not expose $leak.');
      }
    });

    test('the company is resolved from the session, never passed in', () {
      // The same reasoning as expert_roster(). A parameter is something a
      // client can change; auth.uid() is not.
      expect(adminSql, contains('m.user_id = auth.uid()'));
      expect(
        RegExp(r'sponsor_dashboard\s*\(\s*p_', caseSensitive: false)
            .hasMatch(adminSql),
        isFalse,
        reason: 'sponsor_dashboard must take no arguments at all.',
      );
      expect(
        RegExp(r'sponsor_roster\s*\(\s*p_', caseSensitive: false)
            .hasMatch(adminSql),
        isFalse,
      );
    });

    test('being a member is not enough — the capability is also required', () {
      expect(adminSql, contains("public.has_capability('sponsor_admin')"));
    });

    test('sponsor_admin is NOT bundled into the employee plan', () {
      // Bundling it would show every colleague the roster. It gets its own
      // plan precisely because it is the one capability about other people.
      expect(adminSql, contains("('sponsor_admin', 'sponsor_admin')"));
      expect(
        RegExp(r"insert into public\.plan_capabilities[^;]*'employer_standard'[^;]*sponsor_admin",
                dotAll: true, caseSensitive: false)
            .hasMatch(adminSql),
        isFalse,
      );
      // ...and the 0058 seed must not be re-run here, because
      // `select id from capabilities` would now sweep sponsor_admin into
      // employer_standard by accident.
      expect(
        adminSql.contains("select 'employer_standard', id from public.capabilities"),
        isFalse,
      );
    });

    test('removing a leaver takes no sponsor id from the client', () {
      expect(adminSql, contains('sponsor_remove_member(p_work_email text)'));
      expect(
        RegExp(r'v_id\s+text\s*:=\s*public\.my_sponsor_admin_id\(\)')
            .hasMatch(adminSql),
        isTrue,
      );
    });

    test('behaviour is suppressed below the cohort; headcount is not', () {
      // Seats and activations are commercial facts about a contract the
      // sponsor signed. Withholding those would be absurd; withholding
      // behaviour in a thirty-person company is not.
      expect(adminSql, contains('sponsor_analytics_config'));
      expect(adminSql, contains("'consultations_booked',    case when v_suppress then null"));
      expect(
        RegExp(r"'activated',\s*case when v_suppress").hasMatch(adminSql),
        isFalse,
        reason: 'Activation counts must never be suppressed.',
      );
    });

    test('the threshold is a config row, not a constant', () {
      expect(adminSql, contains('min_cohort int  not null default 5'));
      expect(adminSql, contains('grant select, update on public.sponsor_analytics_config to directus_cms'));
    });

    test('membership and codes are still never handed to the CMS', () {
      for (final sql in [sponsorsSql, bypassSql, adminSql]) {
        for (final t in const ['sponsor_members', 'sponsor_activation_codes']) {
          expect(
            RegExp('grant[^;]*on\\s+public\\.$t\\s+to\\s+directus_cms',
                    caseSensitive: false, dotAll: true)
                .hasMatch(sql),
            isFalse,
            reason: '$t must never become a form to edit.',
          );
        }
      }
    });

    test('the gates still return refusals rather than raising them', () {
      for (final sql in [bypassSql, adminSql]) {
        expect(RegExp(r'raise exception').hasMatch(sql), isFalse,
            reason: '0055: a raise discards the audit row written a line '
                'earlier, so the blocked attempt leaves no trace.');
      }
    });
  });

  // ===========================================================================
  //  3. The app knows every refusal the server can give
  // ===========================================================================
  test('every refusal code in the SQL has app copy', () {
    // THE CROSS-HALF BUG THIS CATCHES. The server grows a refusal; the app
    // never hears about it; nothing errors, and the person being refused gets
    // whatever raw sentence the database happened to contain -- untranslated,
    // and in a language they may not read. Same failure shape as the Ask Veda
    // wire body silently dropping timing_ownership.
    final codes = <String>{};
    for (final sql in [sponsorsSql, bypassSql]) {
      // _refuse(actor, action, table, target, CODE, message[, args]) — the
      // fifth argument is the one the app branches on.
      for (final m in RegExp(
              r"_refuse\(\s*[^,]+,\s*'(?:request|confirm)_sponsor_activation'\s*,"
              r"\s*'[a-z_]+'\s*,\s*[^,]+,\s*'([a-z_]+)'",
              dotAll: true)
          .allMatches(sql)) {
        codes.add(m.group(1)!);
      }
    }
    // Plus the one refusal the function returns without going through _refuse,
    // because there is no session to attribute the audit row to.
    codes.add('not_signed_in');

    expect(codes, isNotEmpty, reason: 'the scrape itself must not silently fail');

    for (final lang in AppLanguage.values) {
      for (final code in codes) {
        final msg = activationMessage(lang, {'ok': false, 'code': code});
        expect(msg, isNotEmpty);
        expect(
          msg,
          isNot(equals(activationMessage(lang, {'ok': false, 'code': 'zzz'}))),
          reason: '"$code" falls through to the generic message — the app does '
              'not know what it means.',
        );
      }
    }
  });

  test('an unknown code shows what the server said, not a shrug', () {
    final msg = activationMessage(AppLanguage.english,
        {'ok': false, 'code': 'a_code_from_the_future', 'message': 'Specific.'});
    expect(msg, 'Specific.');
  });

  test('the eligibility refusal stays vague in both languages', () {
    // The server answers the same way for an unknown domain and for a
    // customer whose contract lapsed, so this endpoint cannot be used to
    // enumerate who bought ParentVeda. A more helpful message here would undo
    // that in one line.
    for (final lang in AppLanguage.values) {
      final msg =
          activationMessage(lang, {'ok': false, 'code': 'not_eligible'});
      for (final leak in const ['suspend', 'lapsed', 'expired', 'unknown domain']) {
        expect(msg.toLowerCase(), isNot(contains(leak)));
      }
    }
  });

  test('a network failure never reads as a refusal', () {
    // "Your code was wrong" and "we could not reach the server" are different
    // facts, and only one of them means try a different code.
    final msg =
        activationMessage(AppLanguage.english, {'code': 'network_error'});
    expect(msg.toLowerCase(), contains('connection'));
    expect(msg.toLowerCase(), isNot(contains('code')));
  });

  // ===========================================================================
  //  4. The credit bridge
  // ===========================================================================
  group('sponsored consultations reuse the one credit counter', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      EntitlementStore.instance.setForTest();
    });

    Entitlement? sponsored() => BookingStore.instance
        .entitlements()
        .where((e) => e.id == 'ent_gift_sponsor_acme')
        .cast<Entitlement?>()
        .firstWhere((e) => true, orElse: () => null);

    test('no sponsor, no credit', () {
      SponsorBenefits.sync();
      expect(sponsored(), isNull);
    });

    test('a sponsor WITHOUT the capability grants nothing', () {
      // The capability is the fact that decides, not the sponsorship. A plan
      // that does not include consultations must not quietly include them.
      EntitlementStore.instance.setForTest(
        capabilities: const {Caps.sponsorEvents},
        sponsor: const SponsorInfo(id: 'acme', name: 'Acme'),
      );
      SponsorBenefits.sync();
      expect(sponsored(), isNull);
    });

    test('an activated sponsor grants exactly one spendable credit', () {
      EntitlementStore.instance.setForTest(
        capabilities: const {Caps.consultationCredit},
        sponsor: const SponsorInfo(id: 'acme', name: 'Acme'),
      );
      SponsorBenefits.sync();

      final e = sponsored();
      expect(e, isNotNull);
      expect(e!.creditsLeft, SponsorBenefits.consultationsPerActivation);
      // Floating: "a free consultation" is not a promise about who with.
      expect(e.offeringId, kAnyConsultOffering);
    });

    test('syncing on every launch still grants once — the listener case', () {
      // This runs on every notification from EntitlementStore. If it were not
      // idempotent, a sponsored parent would accumulate free consultations by
      // opening the app.
      EntitlementStore.instance.setForTest(
        capabilities: const {Caps.consultationCredit},
        sponsor: const SponsorInfo(id: 'acme', name: 'Acme'),
      );
      for (var i = 0; i < 25; i++) {
        SponsorBenefits.sync();
      }
      final all = BookingStore.instance
          .entitlements()
          .where((e) => e.id.startsWith('ent_gift_sponsor_'))
          .toList();
      expect(all.length, 1);
      expect(all.single.creditsLeft, SponsorBenefits.consultationsPerActivation);
    });

    test('the credit outlives a 90-day referral reward', () {
      // It is tied to an annual contract; expiring it mid-term would take away
      // something the employer has already paid for.
      EntitlementStore.instance.setForTest(
        capabilities: const {Caps.consultationCredit},
        sponsor: const SponsorInfo(id: 'acme', name: 'Acme'),
      );
      SponsorBenefits.sync();
      final e = sponsored()!;
      expect(e.expiresUtc!.difference(e.purchasedUtc).inDays, greaterThan(300));
    });
  });

  // ===========================================================================
  //  5. The client models cannot carry what the server does not send
  // ===========================================================================
  group('the dashboard model keeps null and zero apart', () {
    test('suppressed behaviour is null, not zero', () {
      // Rendering null as 0 would turn a policy into a false claim: a sponsor
      // reading "0 consultations" concludes the benefit is failing.
      final d = SponsorDashboard.fromMap({
        'ok': true,
        'sponsor_id': 'acme',
        'sponsor_name': 'Acme',
        'activated': 3,
        'suppressed': true,
        'min_cohort': 5,
        'consultations_booked': null,
      });
      expect(d, isNotNull);
      expect(d!.suppressed, isTrue);
      expect(d.consultationsBooked, isNull);
      expect(d.activated, 3, reason: 'headcount is never suppressed');
    });

    test('a non-admin resolves to no dashboard at all', () {
      expect(
        SponsorDashboard.fromMap(
            {'ok': false, 'code': 'not_a_sponsor_admin'}),
        isNull,
      );
      expect(SponsorDashboard.fromMap(null), isNull);
    });

    test('a roster row has no field that could identify a person', () {
      final r = SponsorMemberRow.fromMap({
        'work_email': 'a@acme.com',
        'status': 'active',
        'activated_at': '2026-07-01T00:00:00Z',
        // Anything else the server might one day add must be ignored here,
        // not quietly stored.
        'user_id': 'should-not-survive',
      });
      expect(r.workEmail, 'a@acme.com');
      expect(r.isActive, isTrue);
      expect(SponsorMemberRow.fromMap(const {}).workEmail, isEmpty);
    });
  });

  // ===========================================================================
  //  6. Wiring gate — correct-but-unreachable is the failure this repo has hit
  // ===========================================================================
  group('it is actually reachable', () {
    final profile =
        File('lib/screens/profile_screen.dart').readAsStringSync();
    final main = File('lib/main.dart').readAsStringSync();

    test('Profile shows the entry point whether or not it is activated', () {
      expect(profile, contains('_EmployerBenefitsCard'));
      expect(profile, contains('openActivationFlow('));
      expect(profile, contains('EmployerBenefitsScreen('));
      // Not behind an `if (isSponsored)`. A parent whose company already pays
      // would never discover it if the door only appeared once she was
      // through it.
      expect(
        RegExp(r'if\s*\([^)]*isSponsored[^)]*\)\s*\n?\s*_EmployerBenefitsCard')
            .hasMatch(profile),
        isFalse,
      );
    });

    test('the credit bridge is attached at startup', () {
      expect(main, contains('SponsorBenefits.attach()'));
    });

    test('the HR dashboard has a door', () {
      final benefits =
          File('lib/screens/enterprise/employer_benefits_screen.dart')
              .readAsStringSync();
      expect(benefits, contains('SponsorDashboardScreen('));
      expect(benefits, contains('SponsorAdminStore.instance.isAdmin'));
    });

    test('the admin store is never cached to disk', () {
      // Local-first is a default, not a reflex: a roster of employees is the
      // last thing that should be written to a phone.
      final store =
          File('lib/services/sponsor_admin_store.dart').readAsStringSync();
      expect(store.contains("import 'package:shared_preferences"), isFalse,
          reason: 'a roster of employees must not be written to a phone.');
    });
  });
}
