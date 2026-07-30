// A partner is a partner, whether it is a person or an institution.
//
// 0037 authorised every partner-facing read through
//   care_partners.expert_id -> expert_accounts -> auth.uid()
// which works for a solo doctor and cannot work for a hospital: expert_id is
// nullable by design, and kExperts is a compiled catalogue an institution has
// no business appearing in. The consequence was total — an organisation could
// hold a referral token, be named correctly on /care/, and never see a single
// number, with its kit reading "not set up yet" permanently.
//
// These tests hold the new rule in both halves: the SQL that authorises, and
// the app that must stop inventing an identity when there is no expert record.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/care_partner/care_partner_models.dart';
import 'package:parentveda/care_partner/partner_dashboard_store.dart';
import 'package:parentveda/doctor/doctor_session.dart';
import 'package:parentveda/screens/doctor/doctor_home_screen.dart';
import 'package:parentveda/screens/doctor/doctor_profile_screen.dart';
import 'package:parentveda/screens/doctor/doctor_referral_kit_screen.dart';

/// A hospital: a real partner with NO expert record. The case that was broken.
const _org = CarePartner(
  id: 'demo_org_ivf',
  name: 'Nova IVF Fertility',
  type: CarePartnerType.ivfCentre,
  status: PartnerStatus.active,
  city: 'Pune',
  // expertId deliberately absent.
);

const _doctor = CarePartner(
  id: 'cp_meera',
  name: 'Dr Meera Rao',
  type: CarePartnerType.doctor,
  status: PartnerStatus.active,
  expertId: 'exp_meera',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    PartnerDashboardStore.instance.reset();
    DoctorSession.instance.exit();
  });

  group('the session carries either identity', () {
    test('a doctor session consults; a partner session does not', () {
      DoctorSession.instance.enter('exp_meera');
      expect(DoctorSession.instance.consults, isTrue);
      expect(DoctorSession.instance.sessionKey, 'exp_meera');

      DoctorSession.instance.enterAsPartner('demo_org_ivf');
      expect(DoctorSession.instance.consults, isFalse);
      expect(DoctorSession.instance.expertId, isNull);
      expect(DoctorSession.instance.sessionKey, 'demo_org_ivf');
    });

    test('entering one route clears the other — an org must not inherit a '
        'doctor identity from a previous session', () {
      DoctorSession.instance.enter('exp_meera');
      DoctorSession.instance.enterAsPartner('demo_org_ivf');
      expect(DoctorSession.instance.expertId, isNull);

      DoctorSession.instance.enter('exp_meera');
      expect(DoctorSession.instance.partnerId, isNull);
    });

    test('exit clears both', () {
      DoctorSession.instance.enterAsPartner('demo_org_ivf');
      DoctorSession.instance.exit();
      expect(DoctorSession.instance.active, isFalse);
      expect(DoctorSession.instance.sessionKey, isNull);
    });
  });

  group('an organisation is never shown somebody else identity', () {
    // doctorInfoById() falls back to the FIRST doctor for an unknown id, so
    // both of these screens used to render a stranger's name for an org.
    testWidgets('the home header shows the ORG name, not a doctor', (t) async {
      t.view.physicalSize = const Size(1200, 2600);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);

      DoctorSession.instance.enterAsPartner(_org.id);
      PartnerDashboardStore.instance.debugSeed(partner: _org);

      await t.pumpWidget(const MaterialApp(
          home: Scaffold(body: DoctorHomeScreen())));
      await t.pump();

      expect(find.text('Nova IVF Fertility'), findsWidgets);
      expect(find.textContaining('Dr '), findsNothing);
    });

    testWidgets('the profile shows the ORG name, and its type instead of a '
        'consulting category', (t) async {
      t.view.physicalSize = const Size(1200, 2600);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);

      DoctorSession.instance.enterAsPartner(_org.id);
      PartnerDashboardStore.instance.debugSeed(partner: _org);

      await t.pumpWidget(const MaterialApp(
          home: Scaffold(body: DoctorProfileScreen())));
      await t.pump();

      expect(find.text('Nova IVF Fertility'), findsWidgets);
      expect(find.text('IVF Centre'), findsWidgets);
      expect(find.textContaining('Dr '), findsNothing);
    });

    testWidgets('a consulting doctor still sees their own name and credential',
        (t) async {
      t.view.physicalSize = const Size(1200, 2600);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);

      DoctorSession.instance.enter('exp_meera');
      PartnerDashboardStore.instance.debugSeed(partner: _doctor);

      await t.pumpWidget(const MaterialApp(
          home: Scaffold(body: DoctorHomeScreen())));
      await t.pump();
      // Resolved from kExperts, so the exact name depends on the catalogue —
      // what matters is that a doctor route still produces a doctor.
      expect(find.textContaining('Dr'), findsWidgets);
    });
  });

  group('the referral kit works for an organisation', () {
    testWidgets('an org with a server token gets its QR', (t) async {
      PartnerDashboardStore.instance
          .debugSeed(partner: _org, token: 'R2ST6PY4H2');
      await t.pumpWidget(
          const MaterialApp(home: DoctorReferralKitScreen()));
      await t.pump();
      expect(find.text('R2ST6PY4H2'), findsOneWidget);
      expect(find.text('Nova IVF Fertility'), findsWidgets);
    });

    test('debugSeed keys off the partner id, not expertId — an org has none',
        () {
      final store = PartnerDashboardStore.instance;
      store.debugSeed(partner: _org, token: 'R2ST6PY4H2');
      expect(store.partner?.id, 'demo_org_ivf');
      expect(store.token, 'R2ST6PY4H2');
      expect(store.isNotAPartner, isFalse);
    });
  });

  // ---------------------------------------------------------------------
  // The half that is not Dart.
  // ---------------------------------------------------------------------
  group('migration 0068', () {
    final sql =
        File('supabase/migrations/0068_partner_accounts.sql').readAsStringSync();

    test('authorisation lives in ONE place, and both routes are in it', () {
      final start = sql.indexOf('function public.caller_owns_partner(');
      expect(start, greaterThan(-1), reason: 'the helper is missing');
      final body = sql.substring(start, sql.indexOf(r'$$;', start));
      expect(body.contains('partner_accounts'), isTrue,
          reason: 'the direct partner route is missing');
      expect(body.contains('expert_accounts'), isTrue,
          reason: 'the original doctor route was dropped — every signed-in '
              'doctor would lose access');
      expect(body.contains("security definer set search_path = ''"), isTrue);
    });

    test('all three partner-facing functions go through the helper', () {
      for (final fn in [
        'partner_impact',
        'partner_earnings',
        'partner_funnel',
      ]) {
        final start = sql.indexOf('function public.$fn(');
        expect(start, greaterThan(-1), reason: '$fn is missing from 0068');
        final body = sql.substring(start, sql.indexOf(r'$$;', start));
        expect(body.contains('caller_owns_partner'), isTrue,
            reason: '$fn still authorises its own way');
      }
    });

    test('the boundary did not widen — still counts only, no user_id returned',
        () {
      for (final fn in ['partner_impact', 'partner_funnel']) {
        final start = sql.indexOf('function public.$fn(');
        final sig = sql.substring(start, sql.indexOf('language sql', start));
        expect(sig.contains('user_id'), isFalse,
            reason: '$fn must never return a family identifier');
      }
    });

    test('partner_accounts has no write policy — attaching a login to a '
        'partner is an editorial act', () {
      final block = sql.substring(sql.indexOf('partner_accounts'));
      for (final verb in ['for insert', 'for update', 'for delete', 'for all']) {
        expect(block.contains('on public.partner_accounts $verb'), isFalse,
            reason: 'a client could $verb and attach itself to any partner');
      }
    });

    test('the CMS can attach a login, and both halves are present', () {
      // A grant alone yields a collection that lists nothing and inserts
      // nothing, with no error explaining why: RLS is on and there is no
      // policy for this role. 0045 §4 established grant + policy together.
      final cms = File('supabase/migrations/0070_partner_accounts_cms.sql')
          .readAsStringSync();
      expect(
          cms.contains('grant select, insert, update, delete on '
              'public.partner_accounts to directus_cms;'),
          isTrue);
      expect(cms.contains('for all to directus_cms using (true) '
              'with check (true);'), isTrue);
    });

    test('function grants look the signature up rather than spelling it out',
        () {
      // Spelling it out failed on a live database with "function does not
      // exist" while the function was plainly there: the deployed signature
      // had drifted from 0040, and a GRANT names a function by its exact
      // argument types. That error reads as "the migration never ran", which
      // sends you looking in the wrong place entirely.
      final cms = File('supabase/migrations/0070_partner_accounts_cms.sql')
          .readAsStringSync();
      expect(cms.contains('oid::regprocedure'), isTrue);
      for (final fn in [
        'create_care_partner',
        'mint_partner_token',
        'link_partner_account',
        'rotate_partner_token',
        'partner_token_history',
      ]) {
        expect(cms.contains("'$fn'"), isTrue, reason: '$fn is not granted');
      }
      expect(RegExp(r'grant execute on function\s+public\.').hasMatch(cms),
          isFalse,
          reason: 'a hardcoded signature will drift again');
    });

    test('the panel is NOT granted the two family-data tables', () {
      final cms = File('supabase/migrations/0070_partner_accounts_cms.sql')
          .readAsStringSync();
      for (final t in ['partner_attributions', 'parent_timeline']) {
        expect(RegExp('grant[^;]*on public\.$t[^;]*to directus_cms')
                .hasMatch(cms),
            isFalse,
            reason: '$t carries which mother came from which partner, and '
                'her timeline. Granting it makes that browsable from a panel '
                'login — a decision, not a side effect of registering a '
                'collection');
      }
    });

    test('link_partner_account is not callable by a client', () {
      expect(
          sql.contains('revoke execute on function\n'
              '  public.link_partner_account(uuid, text, text) from public;'),
          isTrue);
    });

    test('my_care_partner returns at most one partner and carries expert_id so '
        'the app can tell whether consults apply', () {
      final start = sql.indexOf('function public.my_care_partner(');
      expect(start, greaterThan(-1));
      final body = sql.substring(start, sql.indexOf(r'$$;', start));
      expect(body.contains('limit 1'), isTrue);
      expect(body.contains('cp.expert_id'), isTrue);
      expect(body.contains('caller_owns_partner'), isTrue);
      expect(body.contains('deleted_at is null'), isTrue);
    });
  });
}
