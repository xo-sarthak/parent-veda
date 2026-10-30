// =============================================================================
//  Partners P3 · an IVF centre's Overview and Doctors, and 0139
// -----------------------------------------------------------------------------
//  Renders the real tabs against CareOrgStore (setForTest, and its `ask` seam
//  for the load path; the house has no mocking framework). What it holds:
//    * referral facts always show, even at 1 (R3);
//    * behaviour shows "—" with the server's threshold in the words when it was
//      held back, never 0, and the threshold is min_cohort, not a literal 5;
//    * every family is filed under a doctor, a former doctor or the centre;
//    * no family is ever named, and the SQL cannot return one;
//    * the numbers come from ONE call that resolves the centre through
//      my_partner_org(), and the four shared care RPCs are untouched.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/partner_app/care_org_store.dart';
import 'package:parentveda/partner_app/partner_org_session.dart';
import 'package:parentveda/screens/partner_app/partner_tabs.dart';
import 'package:parentveda/screens/partner_app/partner_words.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _read(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

String _live(String path) => _read(
  path,
).split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');

List<File> _migrations() =>
    Directory('supabase/migrations')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.sql'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

String _code(String sql) =>
    sql.split('\n').where((l) => !l.trimLeft().startsWith('--')).join('\n');

/// The LAST definition across every migration, so a later create-or-replace
/// that drops a rule fails here.
({String file, String body}) _last(String name) {
  final head = 'create or replace function public.$name(';
  String? file;
  String? body;
  for (final f in _migrations()) {
    final code = _code(f.readAsStringSync().replaceAll('\r\n', '\n'));
    final at = code.lastIndexOf(head);
    if (at < 0) continue;
    final open = code.indexOf(r'$$', at);
    final close = code.indexOf(r'$$', open + 2);
    file = f.uri.pathSegments.last;
    body = code.substring(at, close);
  }
  if (body == null) fail('no definition of public.$name');
  return (file: file!, body: body);
}

const _org = PartnerOrg(
  kind: PartnerOrgKind.careOrg,
  id: 'demo_org_ivf',
  name: 'Nova IVF Fertility',
  status: 'active',
  partnerType: 'ivf_centre',
);

Map<String, Object?> _answer({bool suppressed = false, int min = 5}) => {
  'ok': true,
  'partner_id': 'demo_org_ivf',
  'min_cohort': min,
  'suppressed': suppressed,
  'families': 23,
  'scanned': 21,
  'installed': 19,
  'signed_up': 17,
  'active_30d': 11,
  'activated': suppressed ? null : 9,
  'pregnancies': suppressed ? null : 8,
  'children': suppressed ? null : 3,
  'consultations': suppressed ? null : 14,
  'vaccinations': suppressed ? null : 12,
  'content_read': suppressed ? null : 140,
  'earnings': [
    {
      'source': 'consultation',
      'status': 'accrued',
      'entries': 4,
      'partner_minor': 120000,
    },
  ],
  'doctors': [
    {
      'who': 'doctor',
      'name': 'Dr Meera Rao',
      'families': 13,
      'latest_on': '2026-10-21',
    },
    {'who': 'centre', 'name': '', 'families': 6, 'latest_on': '2026-10-02'},
    {
      'who': 'former',
      'name': 'Dr Arjun Iyer',
      'families': 4,
      'latest_on': '2026-07-11',
    },
    {'who': 'doctor', 'name': 'Dr Kavya Shah', 'families': 0},
  ],
};

Future<void> _pump(WidgetTester t, Widget tab) async {
  t.view.physicalSize = const Size(1080, 5000);
  t.view.devicePixelRatio = 2.5;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: Scaffold(body: tab)));
  await t.pumpAndSettle();
}

void main() {
  final realAsk = CareOrgStore.ask;
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    CareOrgStore.instance.clear();
  });
  tearDown(() {
    CareOrgStore.ask = realAsk;
    CareOrgStore.instance.clear();
  });

  group('the model reads what 0139 sends', () {
    test('referral facts, behaviour, money and doctors', () {
      final d = CareOrgDashboard.fromMap(_answer())!;
      expect(d.families, 23);
      expect(d.signedUp, 17);
      expect(d.active30d, 11);
      expect(d.pregnancies, 8);
      expect(d.contentRead, 140);
      expect(d.totalEarnedMinor, 120000);
      expect(d.doctors, hasLength(4));
      expect(d.listedDoctors, 2);
      expect(d.doctors[1].isCentre, isTrue);
      expect(d.doctors[2].isFormer, isTrue);
      expect(d.doctors.first.latestOn, DateTime(2026, 10, 21));
      expect(d.doctors.last.latestOn, isNull);
    });

    test('held back means null, even if a figure arrives with it', () {
      final m = _answer(suppressed: true)..['pregnancies'] = 2;
      final d = CareOrgDashboard.fromMap(m)!;
      expect(d.suppressed, isTrue);
      expect(d.pregnancies, isNull, reason: 'belt and braces on the phone');
      expect(d.activated, isNull);
      // Referral facts are never held back (R3).
      expect(d.families, 23);
      expect(d.active30d, 11);
    });

    test('a refusal is no dashboard, not a dashboard of zeros', () {
      expect(
        CareOrgDashboard.fromMap({'ok': false, 'code': 'not_a_care_org'}),
        isNull,
      );
      expect(CareOrgDashboard.fromMap(null), isNull);
    });

    test('the store asks once and reads the answer', () async {
      var calls = 0;
      CareOrgStore.ask = () async {
        calls++;
        return _answer();
      };
      await CareOrgStore.instance.refresh();
      expect(calls, 1);
      expect(CareOrgStore.instance.dashboard!.families, 23);
      expect(CareOrgStore.instance.error, isNull);
    });

    test('a failed call keeps what was there and says so', () async {
      CareOrgStore.instance.setForTest(
        dashboard: CareOrgDashboard.fromMap(_answer()),
      );
      CareOrgStore.ask = () async => throw Exception('offline');
      await CareOrgStore.instance.refresh();
      expect(CareOrgStore.instance.dashboard!.families, 23);
      expect(CareOrgStore.instance.error, isNotNull);
    });
  });

  group('Overview', () {
    testWidgets('unsuppressed: referral facts, behaviour, doctors, earnings', (
      t,
    ) async {
      CareOrgStore.instance.setForTest(
        dashboard: CareOrgDashboard.fromMap(_answer()),
      );
      await _pump(t, const PartnerOverviewTab(org: _org));
      expect(find.text('Nova IVF Fertility'), findsWidgets);
      expect(find.text('23'), findsOneWidget); // families joined
      expect(find.text('11'), findsOneWidget); // active
      expect(find.text('17'), findsOneWidget); // signed up
      expect(find.text('8'), findsOneWidget); // pregnancies
      expect(find.text('140'), findsOneWidget); // reads
      expect(find.text('Across all your families'), findsOneWidget);
      // The top three doctors, then a pointer to the rest.
      expect(find.text('Dr Meera Rao'), findsOneWidget);
      expect(find.text("Your centre's own code"), findsOneWidget);
      expect(find.text('Dr Kavya Shah'), findsNothing);
      expect(find.text('All 4 on the Doctors tab.'), findsOneWidget);
      expect(find.text('Consultations'), findsWidgets);
      expect(find.textContaining('₹'), findsWidgets);
      expect(find.textContaining('never a family'), findsOneWidget);
    });

    testWidgets(
      'suppressed with a server threshold of 7: dashes and the 7, never 0',
      (t) async {
        CareOrgStore.instance.setForTest(
          dashboard: CareOrgDashboard.fromMap(
            _answer(suppressed: true, min: 7),
          ),
        );
        await _pump(t, const PartnerOverviewTab(org: _org));
        expect(find.text('—'), findsNWidgets(6));
        expect(find.text(partnerCareWithheldText(7)), findsWidgets);
        expect(find.textContaining('Shown once 5'), findsNothing);
        expect(find.textContaining('until 7 have'), findsOneWidget);
        // Referral facts stay.
        expect(find.text('23'), findsOneWidget);
        expect(find.text('11'), findsOneWidget);
      },
    );

    testWidgets('not loaded: P1 empty state; a failure offers Try again', (
      t,
    ) async {
      CareOrgStore.ask = () async => null;
      await _pump(t, const PartnerOverviewTab(org: _org));
      expect(find.text('Your numbers live here'), findsOneWidget);

      CareOrgStore.instance.setForTest(error: 'We could not load.');
      await t.pump();
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  group('Doctors', () {
    testWidgets('every kind of row, a count each, no family named', (t) async {
      CareOrgStore.instance.setForTest(
        dashboard: CareOrgDashboard.fromMap(_answer()),
      );
      await _pump(t, const PartnerPeopleTab(org: _org));
      expect(find.text('Your doctors'), findsWidgets);
      expect(
        find.text('2 doctors listed · 23 families in all'),
        findsOneWidget,
      );
      expect(find.text('Dr Meera Rao'), findsOneWidget);
      expect(find.text('Dr Kavya Shah'), findsOneWidget);
      expect(
        find.text('No families yet. Hand out their code.'),
        findsOneWidget,
      );
      expect(find.text("Your centre's own code"), findsOneWidget);
      expect(find.textContaining('No longer listed here'), findsOneWidget);
      expect(find.text('Latest joined 21 Oct 2026'), findsOneWidget);
      expect(find.textContaining(kPartnerAddDoctorText), findsOneWidget);
      expect(find.textContaining('No family is ever named'), findsOneWidget);
    });

    testWidgets('no doctors yet: the empty state carries the next step', (
      t,
    ) async {
      CareOrgStore.instance.setForTest(
        dashboard: CareOrgDashboard.fromMap(_answer()..['doctors'] = []),
      );
      await _pump(t, const PartnerPeopleTab(org: _org));
      expect(find.text('Your doctors appear here'), findsOneWidget);
      expect(find.textContaining(kPartnerAddDoctorText), findsOneWidget);
    });
  });

  group('0139 · the SQL contract', () {
    final fn = _last('care_org_dashboard');
    final all = _migrations().map((f) => _code(f.readAsStringSync())).join();

    test('security definer, pinned search_path, no parameter, authenticated', () {
      expect(fn.file, '0139_care_org_dashboard.sql');
      expect(fn.body, contains('care_org_dashboard()'));
      expect(fn.body, contains('security definer'));
      expect(fn.body, contains("set search_path = ''"));
      expect(
        all,
        contains(
          'revoke all on function public.care_org_dashboard() from public, anon;',
        ),
      );
      expect(
        all,
        contains(
          'grant execute on function public.care_org_dashboard() to authenticated;',
        ),
      );
    });

    test(
      'the centre comes from my_partner_org(), and only a live care_org',
      () {
        expect(fn.body, contains('public.my_partner_org()'));
        expect(fn.body, isNot(contains('caller_owns_partner')));
        expect(
          fn.body,
          isNot(contains('partner_accounts')),
          reason: 'one resolver: no second copy of the Route A join',
        );
        expect(fn.body, contains("<> 'care_org'"));
        expect(fn.body, contains("<> 'active'"));
        expect(fn.body, contains("'ok', false"));
      },
    );

    test(
      'behaviour is null below the shared threshold; referral facts are not',
      () {
        expect(fn.body, contains('public.sponsor_analytics_config'));
        for (final k in const [
          'activated',
          'pregnancies',
          'children',
          'consultations',
          'vaccinations',
          'content_read',
        ]) {
          expect(
            RegExp("'$k',\\s+case when v_suppress then null").hasMatch(fn.body),
            isTrue,
            reason: '$k must be withheld below min_cohort',
          );
        }
        for (final k in const [
          'families',
          'scanned',
          'signed_up',
          'active_30d',
        ]) {
          expect(
            RegExp("'$k',\\s+case when").hasMatch(fn.body),
            isFalse,
            reason: '$k is a referral fact (R3) and is never withheld',
          );
        }
        expect(fn.body, contains("'min_cohort', v_min"));
      },
    );

    test('no family leaves it: no user id or token out, a day not a time', () {
      for (final leak in const [
        "'user_id'",
        "'token'",
        'a.token',
        'due_date',
      ]) {
        expect(fn.body.contains(leak), isFalse, reason: leak);
      }
      expect(fn.body, contains('max(a.linked_at)::date'));
    });

    test('every family is filed: doctor, former, centre', () {
      for (final who in const ["'doctor'", "'former'", "'centre'"]) {
        expect(fn.body, contains(who));
      }
    });

    test('the shared care RPCs are untouched, so ParentVeda+ is too', () {
      expect(_last('partner_impact').file, '0068_partner_accounts.sql');
      expect(_last('partner_funnel').file, '0068_partner_accounts.sql');
      expect(_last('partner_earnings').file, '0068_partner_accounts.sql');
      expect(
        _last('partner_referral_breakdown').file,
        '0073_one_partner_no_exceptions.sql',
      );
    });
  });

  group('wiring', () {
    test('the care_org tabs open the P3 screens', () {
      final tabs = _live('lib/screens/partner_app/partner_tabs.dart');
      expect(tabs, contains('PartnerCareOverview(org: org)'));
      expect(tabs, contains('PartnerCareDoctors(org: org)'));
    });

    test(
      'the store calls care_org_dashboard, and not the ParentVeda+ store',
      () {
        expect(
          _live('lib/partner_app/care_org_store.dart'),
          contains("rpcJson('care_org_dashboard')"),
        );
        for (final f in const [
          'lib/screens/partner_app/partner_care_overview.dart',
          'lib/screens/partner_app/partner_care_doctors.dart',
        ]) {
          expect(_live(f), isNot(contains('PartnerDashboardStore')), reason: f);
          expect(_live(f), isNot(contains('my_care_partner')), reason: f);
        }
      },
    );

    test('sign-out forgets the centre', () {
      expect(
        _read('lib/partner_app/partner_sign_out.dart'),
        contains('CareOrgStore.instance.clear()'),
      );
    });
  });
}
