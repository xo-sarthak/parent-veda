// =============================================================================
//  "Families you brought" — Partner Editions D2
// -----------------------------------------------------------------------------
//  docs/partner-editions/DOCTOR-APP.md §D2. What is defended here:
//
//    * a doctor sees HER OWN slice (my_doctor_referrals, 0133), never the
//      clinic's — and an organisation login gets nothing from it (R4);
//    * a solo doctor's slice uses the same definitions as partner_impact /
//      partner_funnel, so she reads one number in both places;
//    * attribution finally records WHO handed the code over — without that,
//      every per-doctor count reads zero forever;
//    * the kit carries the caller's OWN code and names the signed-in doctor
//      (STILL-OPEN §5.4n);
//    * Home shows the card with an invitation when empty (a feature is never
//      hidden), and "we could not ask" is not "you are not set up" (item 5).
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/care_partner/care_partner_models.dart';
import 'package:parentveda/care_partner/partner_dashboard_store.dart';
import 'package:parentveda/care_partner/your_doctor_line.dart';
import 'package:parentveda/doctor/doctor_session.dart';
import 'package:parentveda/screens/doctor/doctor_home_tab.dart';
import 'package:parentveda/screens/doctor/doctor_impact_screen.dart';
import 'package:parentveda/screens/doctor/doctor_referral_kit_screen.dart';
import 'package:parentveda/screens/doctor/doctor_task_feed.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _read(String path) => File(path).readAsStringSync();

/// The SQL of one function, from its `create` line to the end of its body.
String _fn(String sql, String signature) {
  final start = sql.indexOf('function public.$signature');
  expect(start, greaterThan(-1), reason: '$signature is missing');
  return sql.substring(start, sql.indexOf(r'$$;', start));
}

/// A doctor onboarded after this build, inside a clinic.
const _id = 'exp_d2_member_doctor';

Map<String, Object> _doctorPrefs({bool inClinic = true}) => {
  'doctor_profile_$_id': jsonEncode({
    'expert_id': _id,
    'name': 'Dr Asha Verma',
    'credential': 'MS (Obs & Gyn)',
    'category': 'Fertility specialist',
    'location': 'Pune',
    'blurb': 'Fertility care.',
    'photo_url': null,
    'fee_inr': 900,
    'rating': 4.6,
    'takes_consults': true,
    'partner_id': inClinic ? 'cp_bloom' : null,
    'domain': 'ttc',
  }),
  if (inClinic)
    'doctor_org_$_id': jsonEncode({
      'id': 'cp_bloom',
      'name': 'Bloom Fertility Centre',
    }),
};

Future<void> _signInDoctor({bool inClinic = true}) async {
  SharedPreferences.setMockInitialValues(_doctorPrefs(inClinic: inClinic));
  DoctorSession.instance.enter(_id);
  await DoctorSession.instance.loadProfile();
}

void _noTab(DoctorTab _) {}

Future<void> _pumpHome(WidgetTester t) async {
  t.view.physicalSize = const Size(1200, 4000);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    const MaterialApp(
      home: Scaffold(body: DoctorHomeTab(goTo: _noTab)),
    ),
  );
  await t.pump();
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));
  tearDown(() {
    DoctorSession.instance.clear();
    PartnerDashboardStore.instance.reset();
  });

  group('DoctorReferrals reads what my_doctor_referrals returns', () {
    test('all five columns', () {
      final r = DoctorReferrals.fromMap({
        'scanned': 9,
        'installed': 8,
        'signed_up': 7,
        'active_30d': 5,
        'booked_me': 2,
      });
      expect(
        [r.scanned, r.installed, r.signedUp, r.active30d, r.bookedMe],
        [9, 8, 7, 5, 2],
      );
      expect(r.isEmpty, isFalse);
    });

    test('a missing column is zero, and no one joined is empty', () {
      expect(DoctorReferrals.fromMap(const {}).isEmpty, isTrue);
      expect(DoctorReferrals.fromMap({'signed_up': 1}).bookedMe, 0);
    });
  });

  group('the store says "could not ask" apart from "not a partner"', () {
    test('a failed load is not "not a partner"', () {
      final s = PartnerDashboardStore.instance;
      s.debugSeed(failed: true);
      expect(s.loadFailed, isTrue);
      expect(s.isNotAPartner, isFalse);
    });

    test('a clean answer of "no partner" is', () {
      final s = PartnerDashboardStore.instance;
      s.debugSeed();
      expect(s.loadFailed, isFalse);
      expect(s.isNotAPartner, isTrue);
    });

    test('reset forgets the slice and the failure', () {
      final s = PartnerDashboardStore.instance;
      s.debugSeed(referrals: const DoctorReferrals(signedUp: 3), failed: true);
      s.reset();
      expect(s.referrals, isNull);
      expect(s.loadFailed, isFalse);
    });

    test('her code and her slice are asked OUTSIDE the partner check', () {
      // A member doctor owns no partner row; gating these on it hid her code.
      final src = _read('lib/care_partner/partner_dashboard_store.dart');
      final tok = src.indexOf("callFunction('my_partner_token')");
      final slice = src.indexOf("callFunction('my_doctor_referrals')");
      final gate = src.indexOf('if (id != null) {');
      expect(tok, greaterThan(-1));
      expect(slice, greaterThan(-1));
      expect(tok, lessThan(gate));
      expect(slice, lessThan(gate));
    });
  });

  group('Home: Families you brought', () {
    testWidgets('empty: an invitation with the way to the kit, never hidden', (
      t,
    ) async {
      await _signInDoctor();
      PartnerDashboardStore.instance.debugSeed(
        referrals: const DoctorReferrals(),
        sessionKey: _id,
      );
      await _pumpHome(t);
      expect(find.text('FAMILIES YOU BROUGHT'), findsOneWidget);
      expect(find.text('No families yet'), findsOneWidget);
      expect(find.text('Share your QR'), findsOneWidget);
    });

    testWidgets('filled: Joined, Active, Booked you, and the privacy line', (
      t,
    ) async {
      await _signInDoctor();
      PartnerDashboardStore.instance.debugSeed(
        referrals: const DoctorReferrals(
          signedUp: 12,
          active30d: 7,
          bookedMe: 3,
        ),
        sessionKey: _id,
      );
      await _pumpHome(t);
      expect(find.text('JOINED'), findsOneWidget);
      expect(find.text('BOOKED YOU'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Counts only. Families stay private.'), findsOneWidget);
      expect(find.text('No families yet'), findsNothing);
    });

    testWidgets('could not load: says so, with Try again — not "no families"', (
      t,
    ) async {
      await _signInDoctor();
      PartnerDashboardStore.instance.debugSeed(failed: true, sessionKey: _id);
      await _pumpHome(t);
      expect(
        find.textContaining('Couldn\'t load your numbers'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('No families yet'), findsNothing);
    });

    testWidgets(
      'signed out: the store answers, so the card never spins forever',
      (t) async {
        await _signInDoctor();
        await _pumpHome(t);
        await t.pump(const Duration(milliseconds: 50));
        expect(find.text('No families yet'), findsOneWidget);
      },
    );

    testWidgets('How parents see you previews the "Your doctor" line', (
      t,
    ) async {
      await _signInDoctor();
      PartnerDashboardStore.instance.debugSeed(
        referrals: const DoctorReferrals(),
        sessionKey: _id,
      );
      await _pumpHome(t);
      expect(find.byType(YourDoctorLine), findsOneWidget);
      expect(
        find.text('Dr Asha Verma, Bloom Fertility Centre'),
        findsOneWidget,
      );
    });
  });

  group('YourDoctorLine — one widget, both apps', () {
    test('name and clinic', () {
      expect(
        yourDoctorLabel('Dr Asha Verma', 'Bloom Fertility Centre'),
        'Dr Asha Verma, Bloom Fertility Centre',
      );
    });

    test('no clinic, or a clinic that is her own name, is just her name', () {
      expect(yourDoctorLabel('Dr Meera Rao', null), 'Dr Meera Rao');
      expect(yourDoctorLabel('Dr Meera Rao', '  '), 'Dr Meera Rao');
      expect(yourDoctorLabel('Dr Meera Rao', 'dr meera rao'), 'Dr Meera Rao');
    });

    test(
      'lives in lib/care_partner/ so the parent app (A1) renders the same one',
      () {
        expect(
          File('lib/care_partner/your_doctor_line.dart').existsSync(),
          isTrue,
        );
        expect(
          _read(
            'lib/screens/doctor/doctor_home_tab.dart',
          ).contains('YourDoctorLine('),
          isTrue,
        );
      },
    );
  });

  group('Impact screen: three answers that used to look the same', () {
    testWidgets(
      'could not load and nothing known: "Couldn\'t load", not zeroes',
      (t) async {
        PartnerDashboardStore.instance.debugSeed(failed: true);
        await t.pumpWidget(
          const MaterialApp(home: Scaffold(body: DoctorImpactScreen())),
        );
        await t.pump();
        expect(
          find.textContaining('Couldn\'t load your numbers'),
          findsOneWidget,
        );
        expect(find.text('Try again'), findsOneWidget);
        expect(find.text('Families referred'), findsNothing);
      },
    );

    testWidgets('not a partner and no code: being set up', (t) async {
      PartnerDashboardStore.instance.debugSeed();
      await t.pumpWidget(
        const MaterialApp(home: Scaffold(body: DoctorImpactScreen())),
      );
      await t.pump();
      expect(find.textContaining('Your code is being set up'), findsOneWidget);
      expect(find.text('Families referred'), findsNothing);
    });

    testWidgets('a member doctor with her own code sees her slice', (t) async {
      PartnerDashboardStore.instance.debugSeed(
        token: 'KM7QX2PDVR',
        referrals: const DoctorReferrals(
          signedUp: 4,
          active30d: 2,
          bookedMe: 1,
        ),
      );
      await t.pumpWidget(
        const MaterialApp(home: Scaffold(body: DoctorImpactScreen())),
      );
      await t.pump();
      expect(find.textContaining('4 families'), findsOneWidget);
      expect(find.text('Booked you'), findsOneWidget);
      expect(find.textContaining('being set up'), findsNothing);
    });
  });

  group('the kit carries her own code, under her own name (§5.4n)', () {
    testWidgets('a member doctor — no partner row — gets her QR', (t) async {
      await _signInDoctor();
      PartnerDashboardStore.instance.debugSeed(
        token: 'KM7QX2PDVR',
        sessionKey: _id,
      );
      await t.pumpWidget(const MaterialApp(home: DoctorReferralKitScreen()));
      await t.pump();
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('Dr Asha Verma'), findsOneWidget);
      expect(find.textContaining('Bloom Fertility Centre'), findsOneWidget);
    });

    testWidgets(
      'a doctor on a seeded partner row is named as herself, not the row',
      (t) async {
        await _signInDoctor(inClinic: false);
        PartnerDashboardStore.instance.debugSeed(
          partner: const CarePartner(
            id: 'cp_demo',
            name: 'Dr Meera Rao',
            type: CarePartnerType.doctor,
            status: PartnerStatus.active,
            organisation: 'Rainbow Hospital',
          ),
          token: 'KM7QX2PDVR',
          sessionKey: _id,
        );
        await t.pumpWidget(const MaterialApp(home: DoctorReferralKitScreen()));
        await t.pump();
        expect(find.text('Dr Asha Verma'), findsOneWidget);
        expect(find.text('Dr Meera Rao'), findsNothing);
      },
    );

    testWidgets('an organisation login is named as the organisation', (
      t,
    ) async {
      PartnerDashboardStore.instance.debugSeed(
        partner: const CarePartner(
          id: 'cp_bloom',
          name: 'Bloom Fertility Centre',
          type: CarePartnerType.ivfCentre,
          status: PartnerStatus.active,
        ),
        token: 'ORG7QX2PDV',
      );
      await t.pumpWidget(const MaterialApp(home: DoctorReferralKitScreen()));
      await t.pump();
      expect(find.text('Bloom Fertility Centre'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------
  // The half that is not Dart: 0133 itself.
  // ---------------------------------------------------------------------
  group('migration 0133', () {
    final sql = _read('supabase/migrations/0133_my_doctor_referrals.sql');
    final s0068 = _read('supabase/migrations/0068_partner_accounts.sql');

    test(
      'my_doctor_referrals returns exactly the five counts the app reads',
      () {
        final body = _fn(sql, 'my_doctor_referrals(');
        final sig = body.substring(0, body.indexOf('language sql'));
        for (final col in [
          'scanned',
          'installed',
          'signed_up',
          'active_30d',
          'booked_me',
        ]) {
          expect(sig.contains('$col '), isTrue, reason: '$col is missing');
          expect(
            _read(
              'lib/care_partner/partner_dashboard_store.dart',
            ).contains("d['$col']"),
            isTrue,
            reason: 'the app does not read $col',
          );
        }
        expect(
          sig.contains('user_id'),
          isFalse,
          reason: 'counts only — never a family id',
        );
        expect(RegExp(r'\bbigint\b').allMatches(sig).length, 5);
      },
    );

    test('security definer, pinned search_path, authenticated only', () {
      final body = _fn(sql, 'my_doctor_referrals(');
      expect(body.contains("security definer set search_path = ''"), isTrue);
      expect(
        sql.contains(
          'revoke execute on function public.my_doctor_referrals() from public, anon;',
        ),
        isTrue,
      );
      expect(
        sql.contains(
          'grant execute on function public.my_doctor_referrals() to authenticated;',
        ),
        isTrue,
      );
    });

    test('"me" is her own expert account — an org login gets none (R4)', () {
      final body = _fn(sql, 'my_doctor_referrals(');
      expect(body.contains('public.expert_accounts ea'), isTrue);
      expect(body.contains('ea.user_id = auth.uid()'), isTrue);
      // my_expert_ids() would hand an organisation every doctor under it.
      expect(body.contains('my_expert_ids'), isFalse);
      expect(body.contains('partner_accounts'), isFalse);
      // And caller_owns_partner would hand a founder the colleagues' families.
      expect(body.contains('caller_owns_partner'), isFalse);
    });

    test(
      'a solo doctor reads the same numbers as partner_impact and partner_funnel',
      () {
        final body = _fn(sql, 'my_doctor_referrals(');
        // Her own-practice families: the partner row is hers, the token names nobody.
        expect(
          body.contains(
            'a.expert_id is null and cp.expert_id in (select expert_id from me)',
          ),
          isTrue,
        );
        // Active: the identical definition partner_impact uses.
        const active = "t.at > now() - interval '30 days'";
        expect(body.contains(active), isTrue);
        expect(_fn(s0068, 'partner_impact(').contains(active), isTrue);
        // Signed up: the identical definition partner_funnel uses.
        expect(body.contains('where signed_up_at is not null'), isTrue);
        expect(
          _fn(
            s0068,
            'partner_funnel(',
          ).contains('where signed_up_at is not null'),
          isTrue,
        );
      },
    );

    test('Booked you counts her slots only, and not cancelled ones', () {
      final body = _fn(sql, 'my_doctor_referrals(');
      expect(
        body.contains('s.expert_id in (select expert_id from me)'),
        isTrue,
      );
      expect(body.contains("b.status <> 'cancelled'"), isTrue);
    });

    test('attribution records who handed the code over', () {
      final body = _fn(
        sql,
        'attribute_to_partner(\n  p_token text,\n  p_channel text default',
      );
      expect(body.contains('v_ref.expert_id);'), isTrue);
      // A member doctor cannot credit herself through her own per-doctor code.
      expect(
        body.contains('ea.expert_id in (v_partner.expert_id, v_ref.expert_id)'),
        isTrue,
      );
    });

    test(
      'the backfill only fills nulls — an attribution is frozen history',
      () {
        final i = sql.indexOf('update public.partner_attributions a');
        final stmt = sql.substring(i, sql.indexOf(';', i));
        expect(stmt.contains('a.expert_id is null'), isTrue);
        expect(stmt.contains('r.token = a.token'), isTrue);
      },
    );

    test('the old three-argument form keeps its defaults and forwards', () {
      // `create or replace` cannot remove a default, so losing them fails the
      // whole migration on the live database.
      expect(
        sql.contains(
          "p_channel text default 'qr',\n  p_campaign text default null\n)\nreturns text\nlanguage sql",
        ),
        isTrue,
      );
      expect(sql.contains('null::timestamptz, null::timestamptz'), isTrue);
    });

    test(
      'my_partner_token: her own code first, an org only its org-wide code',
      () {
        final body = _fn(sql, 'my_partner_token(');
        expect(body.contains('pr.retired_at is null'), isTrue);
        expect(
          body.contains('pr.expires_at is null or pr.expires_at > now()'),
          isTrue,
        );
        expect(body.contains('order by x.rank, x.created_at desc'), isTrue);
        // A per-doctor code only while she still belongs to that partner.
        expect(body.contains('ep.partner_id = c.partner_id'), isTrue);
        // The org route never sees a code that names a person.
        final org = body.substring(body.indexOf('public.partner_accounts pa'));
        expect(org.contains('c.expert_id is null'), isTrue);
        expect(body.contains("security definer set search_path = ''"), isTrue);
      },
    );
  });
}
