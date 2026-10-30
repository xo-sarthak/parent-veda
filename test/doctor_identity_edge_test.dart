// =============================================================================
//  ParentVeda+ identity edge cases — Partner Editions D1
// -----------------------------------------------------------------------------
//  docs/partner-editions/DOCTOR-APP.md lists eight ways the doctor app's idea of
//  "who is signed in" went wrong at the edges. The sign-out half lives in
//  partner_account_test.dart and the boot half in doctor_app_shell_test.dart;
//  this file holds the identity itself:
//
//    * "the server did not answer" is not "you are nobody" (item 2)
//    * a doctor the compiled catalogue does not know is still a doctor (item 7)
//    * a doctor inside a clinic knows the clinic, and says so (item 6)
//    * the testing "Test as" switch is not in a store build (item 4)
//    * my_care_partner() picks the same row every time (item 5, 0132)
//    * the boot claims an invite accepted on another phone (item 8)
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/care_partner/partner_dashboard_store.dart';
import 'package:parentveda/doctor/doctor_directory.dart';
import 'package:parentveda/doctor/doctor_session.dart';
import 'package:parentveda/screens/doctor/doctor_home_tab.dart';
import 'package:parentveda/screens/doctor/doctor_profile_tab.dart';
import 'package:parentveda/screens/doctor/doctor_task_feed.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _read(String path) => File(path).readAsStringSync();

/// Source with whole-line comments removed, so a "kept for revert" line cannot
/// satisfy (or break) an assertion about live code.
String _live(String path) => _read(
  path,
).split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');

/// An expert onboarded after this build: in no compiled catalogue.
const _newId = 'exp_d1_not_in_catalogue';

Map<String, Object> _cachedProfile({
  String? partnerId,
  String domain = 'pregnancy',
}) => {
  'doctor_profile_$_newId': jsonEncode({
    'expert_id': _newId,
    'name': 'Dr Asha Verma',
    'credential': 'MS (Obs & Gyn)',
    'category': 'Fertility specialist',
    'location': 'Pune',
    'blurb': 'Fertility care.',
    'photo_url': null,
    'fee_inr': 900,
    'rating': 4.6,
    'takes_consults': true,
    'partner_id': partnerId,
    'domain': domain,
  }),
};

void _noTab(DoctorTab _) {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));
  tearDown(() {
    DoctorSession.instance.clear();
    PartnerDashboardStore.instance.reset();
  });

  group('resolve says WHY it found nobody (item 2)', () {
    // Four since P3 (R5): orgLogin, an organisation login refused in
    // ParentVeda+ and pointed to ParentVeda Partners.
    test('three answers, not a bool (four since P3)', () {
      expect(DoctorResolve.values, [
        DoctorResolve.resolved,
        DoctorResolve.notADoctor,
        DoctorResolve.unreachable,
        DoctorResolve.orgLogin,
      ]);
    });

    test('no backend at all reads as signed out, never as a crash', () async {
      // Supabase is never initialised in a test, exactly the state a failed
      // Supabase.initialize leaves the app in.
      expect(
        await DoctorSession.instance.resolveFromServer(),
        DoctorResolve.notADoctor,
      );
      expect(DoctorSession.instance.active, isFalse);
    });

    test('a timeout is unreachable, and skips the second question', () {
      final src = _live('lib/doctor/doctor_session.dart');
      final start = src.indexOf('Future<DoctorResolve> resolveFromServer()');
      final body = src.substring(start, src.indexOf('void clear()', start));
      expect(body, contains('on TimeoutException'));
      final timeout = body.indexOf('on TimeoutException');
      // The timeout branch returns before my_care_partner is ever asked.
      expect(
        body.indexOf('return DoctorResolve.unreachable;', timeout),
        lessThan(body.indexOf("'my_care_partner'")),
      );
      // A failure (not an answer) on either question is unreachable too.
      expect(
        body,
        contains(
          'failed ? DoctorResolve.unreachable : DoctorResolve.notADoctor',
        ),
      );
    });

    test(
      'the sign-in screen does not tell an offline doctor she is unregistered',
      () {
        final src = _live('lib/screens/doctor/doctor_auth_screen.dart');
        final unreachable = src.indexOf('result == DoctorResolve.unreachable');
        final notRegistered = src.indexOf('result == DoctorResolve.notADoctor');
        expect(unreachable, greaterThan(-1));
        expect(notRegistered, greaterThan(unreachable));
        // The sign-out never runs on the unreachable path: every one comes
        // after that branch, which itself has none. Since P3 there are two,
        // under "not a doctor" and under an organisation login (R5).
        final orgLogin = src.indexOf('result == DoctorResolve.orgLogin');
        expect(orgLogin, greaterThan(unreachable));
        final unreachableBranch = src.substring(
            unreachable, orgLogin < notRegistered ? orgLogin : notRegistered);
        expect(unreachableBranch, isNot(contains('auth.signOut()')));
        expect(src.indexOf('auth.signOut()'), greaterThan(unreachable));
      },
    );
  });

  group('a doctor the catalogue does not know (item 7)', () {
    test('the id alone finds nobody, as before', () {
      expect(doctorInfoById(_newId), isNull);
      expect(doctorInfoFor(_newId), isNull);
    });

    test('her own server row makes her a doctor', () {
      final p = DoctorPublicProfile.fromRow(
        jsonDecode(_cachedProfile()['doctor_profile_$_newId'] as String) as Map,
      );
      final d = doctorInfoFor(_newId, profile: p)!;
      expect(d.name, 'Dr Asha Verma');
      expect(d.credential, 'MS (Obs & Gyn)');
      expect(d.stage, DoctorStage.pregnancy);
      expect(d.rating, '4.6');
    });

    test("somebody else's row is never borrowed", () {
      final other = DoctorPublicProfile.fromRow({
        'expert_id': 'exp_someone_else',
        'name': 'Dr Other',
      });
      expect(doctorInfoFor(_newId, profile: other), isNull);
    });

    test(
      'every live doctor screen asks with the profile, not the id alone',
      () {
        for (final f in const [
          'lib/screens/doctor/doctor_home_tab.dart',
          'lib/screens/doctor/doctor_profile_tab.dart',
          'lib/screens/doctor/doctor_task_feed.dart',
        ]) {
          final src = _live(f);
          expect(
            src,
            contains(
              'doctorInfoFor(session.expertId!, profile: session.profile)',
            ),
            reason: f,
          );
          expect(
            src,
            isNot(contains('doctorInfoById(session.expertId!)')),
            reason: f,
          );
        }
      },
    );

    testWidgets('her Home is a doctor Home, not the organisation one', (
      t,
    ) async {
      t.view.physicalSize = const Size(1200, 2600);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      SharedPreferences.setMockInitialValues(_cachedProfile());

      DoctorSession.instance.enter(_newId);
      await DoctorSession.instance.loadProfile();
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DoctorHomeTab(goTo: _noTab)),
        ),
      );
      await t.pump();

      // The org Home has no "today" fact; a doctor's does.
      expect(find.text('today'), findsWidgets);
      expect(find.textContaining('MS (Obs & Gyn)'), findsWidgets);
    });
  });

  group('a doctor inside a clinic knows the clinic (item 6)', () {
    test('the profile row keeps partner_id and domain through the cache', () {
      final p = DoctorPublicProfile.fromRow({
        'expert_id': 'x',
        'partner_id': 'cp_bloom',
        'domain': 'ttc',
      });
      final back = DoctorPublicProfile.fromRow(p.toRow());
      expect(back.partnerId, 'cp_bloom');
      expect(back.domain, 'ttc');
      expect(
        DoctorPublicProfile.fromRow({
          'expert_id': 'x',
          'partner_id': ' ',
        }).partnerId,
        isNull,
      );
    });

    testWidgets('the Profile header reads "credential · clinic"', (t) async {
      t.view.physicalSize = const Size(1200, 2600);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      SharedPreferences.setMockInitialValues({
        ..._cachedProfile(partnerId: 'cp_bloom'),
        'doctor_org_$_newId': jsonEncode({
          'id': 'cp_bloom',
          'name': 'Bloom Fertility Centre',
        }),
      });

      DoctorSession.instance.enter(_newId);
      await DoctorSession.instance.loadProfile();
      expect(DoctorSession.instance.orgPartnerId, 'cp_bloom');
      expect(DoctorSession.instance.orgName, 'Bloom Fertility Centre');

      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DoctorProfileTab(goTo: _noTab)),
        ),
      );
      await t.pump();
      expect(find.text('Dr Asha Verma'), findsWidgets);
      expect(
        find.text('MS (Obs & Gyn) · Bloom Fertility Centre'),
        findsOneWidget,
      );
    });

    test(
      'a solo doctor is not her own clinic: the test is the partner row\'s expert_id',
      () {
        final src = _live('lib/doctor/doctor_session.dart');
        expect(src, contains("cp['expert_id'] != expertId"));
      },
    );

    test('switching or clearing the session forgets the clinic', () async {
      SharedPreferences.setMockInitialValues({
        ..._cachedProfile(partnerId: 'cp_bloom'),
        'doctor_org_$_newId': jsonEncode({
          'id': 'cp_bloom',
          'name': 'Bloom Fertility Centre',
        }),
      });
      DoctorSession.instance.enter(_newId);
      await DoctorSession.instance.loadProfile();
      DoctorSession.instance.enter('exp_other');
      expect(DoctorSession.instance.orgName, isNull);
      DoctorSession.instance.enter(_newId);
      await DoctorSession.instance.loadProfile();
      DoctorSession.instance.clear();
      expect(DoctorSession.instance.orgPartnerId, isNull);
    });
  });

  test('"Test as" is behind PV_DEV, not in a store build (item 4)', () {
    final src = _live('lib/screens/doctor/doctor_profile_tab.dart');
    expect(
      src,
      contains(
        "const bool _kDevTools = kDebugMode || bool.fromEnvironment('PV_DEV');",
      ),
    );
    final dev = src.indexOf("DcSectionHead('Developer')");
    final gate = src.lastIndexOf('if (d != null && _kDevTools)', dev);
    expect(gate, greaterThan(-1));
    expect(
      dev - gate,
      lessThan(200),
      reason: 'the gate must sit on the Developer block itself',
    );
  });

  test('the boot claims an invite before giving up on an account (item 8)', () {
    final src = _live('lib/main_doctor.dart');
    final start = src.indexOf('Future<void> _resolve()');
    final body = src.substring(
      start,
      src.indexOf('Future<void> _retry()', start),
    );
    expect(
      body,
      contains('result == DoctorResolve.notADoctor && SupabaseRepo.isLoggedIn'),
    );
    expect(
      body.indexOf('claimInvite()'),
      lessThan(body.lastIndexOf('resolveFromServer()')),
    );
  });

  group('migration 0132: my_care_partner is deterministic (item 5)', () {
    final sql = _read('supabase/migrations/0132_my_care_partner_order.sql');
    final start = sql.indexOf('function public.my_care_partner(');
    final body = sql.substring(start, sql.indexOf(r'$$;', start));

    test('ORDER BY before LIMIT, ending on a unique key', () {
      final order = body.indexOf('order by');
      expect(order, greaterThan(-1));
      expect(order, lessThan(body.indexOf('limit 1')));
      expect(body, contains('cp.created_at asc'));
      expect(
        body.indexOf('cp.id asc'),
        greaterThan(body.indexOf('cp.created_at asc')),
      );
    });

    test('her own practice sorts first, and the rule is unchanged', () {
      expect(body, contains('ea.expert_id = cp.expert_id'));
      expect(body, contains(') desc'));
      expect(body, contains('public.caller_owns_partner(cp.id)'));
      expect(body, contains('deleted_at is null'));
    });

    test('same security shape as 0068', () {
      expect(sql, contains("security definer set search_path = ''"));
      expect(
        sql,
        contains(
          'grant execute on function public.my_care_partner() to authenticated;',
        ),
      );
      expect(sql, isNot(contains('to anon')));
    });
  });
}
