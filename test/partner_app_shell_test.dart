// =============================================================================
//  ParentVeda Partners: boot, tabs, refusals, sign-out (Partner Editions P1)
// -----------------------------------------------------------------------------
//  The app is driven for real, with PartnerOrgSession's two seams standing in
//  for the server (the house has no mocking framework): `signedIn` says a
//  session exists, `ask` answers my_partner_org() the way 0136 does.
//
//  The SQL half (my_partner_org, sponsor_admins, my_sponsor_admin_id) reads
//  the LAST definition across every migration, as credits_truth_contract_test
//  does: a rule pinned to one file keeps passing after a later
//  `create or replace` has dropped it.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/main_partner.dart';
import 'package:parentveda/partner_app/partner_org_session.dart';
import 'package:parentveda/screens/partner_app/partner_words.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _read(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

String _live(String path) => _read(
  path,
).split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');

// ---- the SQL reader -------------------------------------------------------

List<File> _migrations() =>
    Directory('supabase/migrations')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.sql'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

String _code(String sql) =>
    sql.split('\n').where((l) => !l.trimLeft().startsWith('--')).join('\n');

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
  if (body == null) {
    fail('no definition of public.$name in supabase/migrations');
  }
  return (file: file!, body: body);
}

// ---- answers the server can give -------------------------------------------

Map<String, Object?> _sponsor({
  String kind = 'employer',
  String status = 'active',
}) => {
  'ok': true,
  'kind': 'sponsor',
  'id': 'acme',
  'name': 'Acme Corp',
  'sponsor_kind': kind,
  'logo_url': null,
  'status': status,
  'support_contact': 'hr@acme.com',
};

const Map<String, Object?> _careOrg = {
  'ok': true,
  'kind': 'care_org',
  'id': 'demo_org_ivf',
  'name': 'Nova IVF Fertility',
  'sponsor_kind': null,
  'partner_type': 'ivf_centre',
  'logo_url': null,
  'status': 'active',
  'support_contact': null,
};

/// Stands the server in for one test; the seams are restored by tearDown.
void _server(Object? Function() answer, {bool signedIn = true}) {
  PartnerOrgSession.signedIn = () => signedIn;
  PartnerOrgSession.ask = () async {
    final a = answer();
    if (a is Exception) throw a;
    return a;
  };
}

/// Boots the app and lets the resolve (and any sign-out after it) finish.
/// A fixed count of pumps, not pumpAndSettle: the booting spinner never
/// settles, and how many awaits the boot takes is not this test's business.
Future<void> _boot(WidgetTester t) async {
  await t.pumpWidget(const ParentVedaPartnersApp());
  for (var i = 0; i < 10; i++) {
    await t.pump();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final realAsk = PartnerOrgSession.ask;
  final realSignedIn = PartnerOrgSession.signedIn;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PartnerOrgSession.instance.clear();
  });
  tearDown(() {
    PartnerOrgSession.ask = realAsk;
    PartnerOrgSession.signedIn = realSignedIn;
    PartnerOrgSession.instance.clear();
  });

  group('the resolver: four outcomes, never a bool', () {
    test('a live sponsor resolves; a school says parents', () async {
      _server(() => _sponsor(kind: 'school'));
      expect(
        await PartnerOrgSession.instance.resolveFromServer(),
        PartnerResolve.resolved,
      );
      final org = PartnerOrgSession.instance.org!;
      expect(org.kind, PartnerOrgKind.sponsor);
      expect(org.isSchool, isTrue);
      expect(org.peopleWord, 'parents');
      expect(PartnerOrgSession.instance.active, isTrue);
    });

    test(
      'an IVF centre resolves as a care_org whose people are doctors',
      () async {
        _server(() => _careOrg);
        expect(
          await PartnerOrgSession.instance.resolveFromServer(),
          PartnerResolve.resolved,
        );
        expect(PartnerOrgSession.instance.org!.kind, PartnerOrgKind.careOrg);
        expect(PartnerOrgSession.instance.org!.peopleWord, 'doctors');
      },
    );

    test(
      'a paused, unstarted or ended programme is suspended, and still named',
      () async {
        for (final s in const ['suspended', 'pending', 'ended']) {
          _server(() => _sponsor(status: s));
          expect(
            await PartnerOrgSession.instance.resolveFromServer(),
            PartnerResolve.suspended,
            reason: s,
          );
          expect(PartnerOrgSession.instance.org?.name, 'Acme Corp');
          expect(PartnerOrgSession.instance.active, isFalse);
        }
      },
    );

    test('a refusal keeps the server\'s word for what the login is', () async {
      for (final code in const ['doctor', 'parent', 'not_an_admin']) {
        _server(() => {'ok': false, 'code': code});
        expect(
          await PartnerOrgSession.instance.resolveFromServer(),
          PartnerResolve.notAnAdmin,
        );
        expect(PartnerOrgSession.instance.refusal, code);
        expect(PartnerOrgSession.instance.org, isNull);
      }
    });

    test(
      'a failed call or an unreadable answer is unreachable, NOT signed out',
      () async {
        _server(() => Exception('socket closed'));
        expect(
          await PartnerOrgSession.instance.resolveFromServer(),
          PartnerResolve.unreachable,
        );
        _server(() => null);
        expect(
          await PartnerOrgSession.instance.resolveFromServer(),
          PartnerResolve.unreachable,
        );
      },
    );

    test('nobody signed in asks the server nothing', () async {
      var asked = false;
      _server(() {
        asked = true;
        return _careOrg;
      }, signedIn: false);
      expect(
        await PartnerOrgSession.instance.resolveFromServer(),
        PartnerResolve.notAnAdmin,
      );
      expect(asked, isFalse);
    });
  });

  group('the boot', () {
    testWidgets(
      'a backend that never started opens on Try again, with no Sign out',
      (t) async {
        var tries = 0;
        await t.pumpWidget(
          ParentVedaPartnersApp(
            backendUp: false,
            retryBackend: () async {
              tries++;
              return false;
            },
          ),
        );
        await t.pump();
        expect(find.text("Can't reach ParentVeda right now"), findsOneWidget);
        expect(find.text('Sign out'), findsNothing);
        await t.tap(find.text('Try again'));
        await t.pump();
        expect(tries, 1);
      },
    );

    testWidgets(
      'signed in but unanswered: still signed in, Try again and Sign out',
      (t) async {
        _server(() => Exception('timeout'));
        await _boot(t);
        expect(find.textContaining('You are still signed in'), findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
        expect(find.text('Sign out'), findsOneWidget);
        expect(find.text('Sign in'), findsNothing);
      },
    );

    testWidgets('nobody signed in: the sign-in form, with no refusal on it', (
      t,
    ) async {
      _server(() => _careOrg, signedIn: false);
      await _boot(t);
      expect(find.text('Sign in'), findsWidgets);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.textContaining("isn't set up"), findsNothing);
    });

    testWidgets('a restored doctor login is turned away to ParentVeda+', (
      t,
    ) async {
      _server(() => {'ok': false, 'code': 'doctor'});
      await _boot(t);
      expect(find.text(partnerRefusalText('doctor')), findsOneWidget);
      expect(find.textContaining('ParentVeda+'), findsWidgets);
      // The autofocused field's selection must not wipe it; typing does.
      await t.enterText(find.byType(TextField).first, 'someone@else.com');
      await t.pump();
      expect(find.text(partnerRefusalText('doctor')), findsNothing);
    });

    testWidgets(
      'a paused programme says so and offers Sign out, not the form',
      (t) async {
        _server(() => _sponsor(status: 'suspended'));
        await _boot(t);
        expect(
          find.text('Acme Corp is paused. Contact your ParentVeda manager.'),
          findsOneWidget,
        );
        expect(find.text('Sign out'), findsOneWidget);
        expect(find.text('Overview'), findsNothing);
      },
    );
  });

  group('the shell', () {
    testWidgets(
      'an employer: four tabs, People says employees, Account signs out',
      (t) async {
        _server(() => _sponsor());
        await _boot(t);
        for (final tab in const ['Overview', 'People', 'Content', 'Account']) {
          expect(find.text(tab), findsWidgets, reason: tab);
        }
        await t.tap(find.text('People').last);
        await t.pumpAndSettle();
        expect(find.text('Your employees appear here'), findsOneWidget);

        await t.tap(find.text('Account').last);
        await t.pumpAndSettle();
        expect(find.text('Acme Corp'), findsOneWidget);
        expect(find.text(kPartnersSupportEmail), findsOneWidget);
        await t.tap(find.text('Sign out'));
        await t.pumpAndSettle();
        // The root heard the session clear and swapped to the form.
        expect(PartnerOrgSession.instance.org, isNull);
        expect(find.text('Forgot password?'), findsOneWidget);
      },
    );

    testWidgets('Back on a tab other than Overview returns to Overview', (
      t,
    ) async {
      _server(() => _sponsor(kind: 'school'));
      await _boot(t);
      await t.tap(find.text('People').last);
      await t.pumpAndSettle();
      expect(find.text('Your parents appear here'), findsOneWidget);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.text('Your numbers live here'), findsOneWidget);
    });

    testWidgets(
      'an IVF centre: the People tab is Doctors, and adding one is ours',
      (t) async {
        _server(() => _careOrg);
        await _boot(t);
        await t.tap(find.text('Doctors'));
        await t.pumpAndSettle();
        expect(
          find.textContaining(
            'To add a doctor, contact your ParentVeda manager.',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('No family is ever named'), findsOneWidget);
      },
    );
  });

  group('wiring', () {
    test(
      'every sign-out path goes through one function that clears every store',
      () {
        final body = _read('lib/partner_app/partner_sign_out.dart');
        final fn = body.substring(
          body.indexOf('Future<void> forgetPartnerOrgOnThisPhone()'),
        );
        for (final call in const [
          'auth.signOut()',
          'PartnerOrgSession.instance.clear()',
          'SponsorAdminStore.instance.clear()',
          'PartnerDashboardStore.instance.reset()',
        ]) {
          expect(fn, contains(call), reason: '$call is missing from sign-out');
        }
        for (final f in const [
          'lib/main_partner.dart',
          'lib/screens/partner_app/partner_tabs.dart',
          'lib/screens/partner_app/partner_auth_screen.dart',
        ]) {
          expect(
            _live(f),
            contains('await forgetPartnerOrgOnThisPhone();'),
            reason: f,
          );
          expect(
            _live(f),
            isNot(contains('auth.signOut()')),
            reason:
                '$f signs out around the function, so a store would be missed',
          );
        }
      },
    );

    test(
      'the boot catches Supabase.initialize and maps unreachable to offline',
      () {
        final main = _read('lib/main_partner.dart');
        final start = main.indexOf('Future<bool> startPartnerBackend()');
        final body = main.substring(start, main.indexOf('enum _Boot', start));
        expect(
          body.indexOf('try {'),
          lessThan(body.indexOf('Supabase.initialize(')),
        );
        expect(body, contains('return false;'));
        expect(
          main,
          contains(
            'runApp(ParentVedaPartnersApp(backendUp: await startPartnerBackend()));',
          ),
        );
        expect(
          // Whitespace-blind: the formatter may wrap this line.
          main.replaceAll(RegExp(r'\s+'), ' '),
          contains(
            'result == PartnerResolve.unreachable ? _Boot.offline : _Boot.ready',
          ),
        );
        expect(main, contains('PartnerScaffold(org: org)'));
      },
    );

    test('the shell uses the shared PvNavBar and four tabs in order', () {
      final live = _live('lib/screens/partner_app/partner_scaffold.dart');
      expect(live, contains('PvNavBar('));
      expect(live, isNot(contains('BottomNavigationBar(')));
      final order = [
        'PartnerOverviewTab(',
        'PartnerPeopleTab(',
        'PartnerContentTab(',
        'PartnerAccountTab(',
      ].map(live.indexOf).toList();
      expect(order.every((i) => i >= 0), isTrue);
      expect(order, orderedEquals([...order]..sort()));
    });

    test('every pushed Partners route is named (P2-P4 inherit this)', () {
      for (final f in Directory(
        'lib/screens/partner_app',
      ).listSync().whereType<File>()) {
        final src = _read(f.path);
        final pushes = 'MaterialPageRoute'.allMatches(src).length;
        final named = 'RouteSettings(name:'.allMatches(src).length;
        expect(
          named,
          greaterThanOrEqualTo(pushes),
          reason: '${f.path}: $pushes pushes, $named named',
        );
      }
    });

    test(
      'the partner flavour exists, has its icons, and claims no OAuth callback',
      () {
        final gradle = _read('android/app/build.gradle.kts');
        expect(gradle, contains('create("partner")'));
        expect(gradle, contains('applicationIdSuffix = ".partners"'));
        expect(gradle, contains('"ParentVeda Partners"'));
        for (final d in const ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
          for (final f in const [
            'ic_launcher.png',
            'ic_launcher_foreground.png',
          ]) {
            expect(
              File('android/app/src/partner/res/mipmap-$d/$f').existsSync(),
              isTrue,
              reason: 'mipmap-$d/$f',
            );
          }
        }
        expect(
          File('android/app/src/partner/AndroidManifest.xml').existsSync(),
          isFalse,
          reason: 'the OAuth intent filter lives in src/parent only',
        );
      },
    );
  });

  group('0136 · the SQL contract', () {
    final org = _last('my_partner_org');
    final admin = _last('my_sponsor_admin_id');
    final all = _migrations()
        .map((f) => _code(f.readAsStringSync()))
        .join('\n');

    test(
      'my_partner_org is security definer, pinned search_path, no parameters',
      () {
        expect(org.body, contains('my_partner_org()'), reason: org.file);
        expect(org.body, contains('security definer'));
        expect(org.body, contains("set search_path = ''"));
        expect(org.body, contains('auth.uid()'));
        expect(
          all,
          contains(
            'grant execute on function public.my_partner_org() to authenticated;',
          ),
        );
        expect(
          all,
          contains(
            'revoke all on function public.my_partner_org() from public, anon;',
          ),
        );
      },
    );

    test('sponsor wins over care_org, and a care_org is Route A only', () {
      expect(
        org.body.indexOf("'kind', 'sponsor'"),
        lessThan(org.body.indexOf("'kind', 'care_org'")),
      );
      expect(org.body, contains('from public.partner_accounts pa'));
      expect(
        org.body,
        isNot(contains('caller_owns_partner')),
        reason: 'Route B is a doctor; R4 keeps caller_owns_partner as it is',
      );
    });

    test('status is reported, not filtered, so a paused admin is told why', () {
      // The role lookup is everything before the 0060 fallback is consulted.
      final role = org.body.substring(
        0,
        org.body.indexOf('public.my_sponsor_admin_id()'),
      );
      expect(role, contains('s.status'));
      expect(role, isNot(contains("s.status = 'active'")));
    });

    test('a non-admin is told what it is: doctor, parent, or not set up', () {
      for (final code in const ["'doctor'", "'parent'", "'not_an_admin'"]) {
        expect(org.body, contains(code));
      }
      // Zeros or {ok:false, code}, never someone else's row.
      expect(org.body, contains("'ok', false"));
    });

    test(
      'my_sponsor_admin_id reads the role first, keeps the 0060 rule, active only',
      () {
        expect(admin.file, '0136_partner_org_admins.sql');
        expect(
          admin.body.indexOf('public.sponsor_admins'),
          lessThan(admin.body.indexOf('public.sponsor_members')),
        );
        expect(admin.body, contains("public.has_capability('sponsor_admin')"));
        expect("s.status = 'active'".allMatches(admin.body).length, 2);
      },
    );

    test(
      'sponsor_admins: one org per login, own-row read, no client writes',
      () {
        final sql = _code(
          _read('supabase/migrations/0136_partner_org_admins.sql'),
        );
        expect(sql, contains('primary key (user_id)'));
        expect(
          sql,
          contains(
            'alter table public.sponsor_admins enable row level security;',
          ),
        );
        expect(sql, contains('for select using (user_id = auth.uid())'));
        expect(
          RegExp(
            r'on public\.sponsor_admins\s+for (insert|update|delete|all)',
          ).hasMatch(sql),
          isFalse,
        );
        expect(sql, isNot(contains('grant insert')));
      },
    );
  });
}
