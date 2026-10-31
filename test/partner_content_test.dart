// =============================================================================
//  Partners P4 · exclusive content, the Content tab, and contract end (0142)
// -----------------------------------------------------------------------------
//  Renders the real Content tab against PartnerContentStore (setForTest, and
//  its `ask` seam for the load path; the house has no mocking framework), and
//  reads 0142 for the rules a render cannot see. What it holds:
//    * booked / used counts show "—" below the server's min_cohort, never 0,
//      and the threshold in the words is min_cohort, not a literal 5;
//    * the tab is read-only (R9): nothing on it writes;
//    * ONE audience rule, called by the view, the table's policy, the three
//      receipt doors and the coupon validator, and closed to the API;
//    * a deleted sponsor cannot turn its session public (on delete restrict);
//    * 'ended' withdraws plans and unspent credits, 'suspended' does not (R2).
//  verify_exclusive_content.sql proves the same against real tables.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/partner_app/partner_content_store.dart';
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
({String file, String body}) _last(String name, {String kind = 'function'}) {
  final head = 'create or replace $kind public.$name';
  String? file;
  String? body;
  for (final f in _migrations()) {
    final code = _code(f.readAsStringSync().replaceAll('\r\n', '\n'));
    final at = code.lastIndexOf(head);
    if (at < 0) continue;
    if (kind == 'function') {
      final open = code.indexOf(r'$$', at);
      final close = code.indexOf(r'$$', open + 2);
      body = code.substring(at, close);
    } else {
      body = code.substring(at, code.indexOf(';', at));
    }
    file = f.uri.pathSegments.last;
  }
  if (body == null) fail('no definition of public.$name');
  return (file: file!, body: body);
}

const _sponsor = PartnerOrg(
  kind: PartnerOrgKind.sponsor,
  id: 'demo_northwind',
  name: 'Northwind',
  status: 'active',
  sponsorKind: 'employer',
);

const _centre = PartnerOrg(
  kind: PartnerOrgKind.careOrg,
  id: 'demo_org_ivf',
  name: 'Nova IVF Fertility',
  status: 'active',
  partnerType: 'ivf_centre',
);

Map<String, Object?> _answer({bool held = false, int min = 5}) => {
  'ok': true,
  'kind': 'sponsor',
  'id': 'demo_northwind',
  'min_cohort': min,
  'programmes': [
    {
      'id': 'nw_sleep',
      'title': 'Sleep in the first year',
      'kind': 'masterclass',
      'stage': 'parenting',
      'status': 'published',
      'first_session_utc': '2099-01-10T10:00:00Z',
      'last_session_utc': '2099-01-10T10:00:00Z',
      'booked': held ? null : 12,
    },
    {
      'id': 'nw_return',
      'title': 'Returning to work',
      'kind': 'cohort',
      'status': 'scheduled',
      'booked': null,
    },
  ],
  'offers': [
    {
      'code': 'NORTHWIND50',
      'kind': 'percent',
      'value': 50,
      'programme_title': null,
      'ends_at': '2099-03-31T00:00:00Z',
      'active': true,
      'redeemed': held ? null : 9,
    },
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
  final realAsk = PartnerContentStore.ask;
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PartnerContentStore.instance.clear();
  });
  tearDown(() {
    PartnerContentStore.ask = realAsk;
    PartnerContentStore.instance.clear();
  });

  group('the model reads what 0142 sends', () {
    test('sessions, offers and the threshold', () {
      final c = PartnerContent.fromMap(_answer(min: 7))!;
      expect(c.minCohort, 7);
      expect(c.programmes.map((p) => p.id), ['nw_sleep', 'nw_return']);
      expect(c.programmes.first.booked, 12);
      expect(c.offers.single.code, 'NORTHWIND50');
      expect(c.offers.single.isPercent, isTrue);
      expect(c.offers.single.redeemed, 9);
    });

    test('held back is null, never 0', () {
      final c = PartnerContent.fromMap(_answer(held: true))!;
      expect(c.programmes.first.booked, isNull);
      expect(c.offers.single.redeemed, isNull);
    });

    test('a refusal is no content, not empty content', () {
      expect(PartnerContent.fromMap({'ok': false, 'code': 'not_live'}), isNull);
      expect(PartnerContent.fromMap(null), isNull);
    });

    test('state comes from the status and the dates', () {
      final now = DateTime.utc(2026, 10, 30);
      ExclusiveProgramme p(String status, {DateTime? last}) =>
          ExclusiveProgramme(
            id: 'x',
            title: 'x',
            kind: 'masterclass',
            status: status,
            lastSession: last,
          );
      expect(p('scheduled').stateAt(now), ExclusiveState.comingSoon);
      expect(p('completed').stateAt(now), ExclusiveState.finished);
      expect(
        p('published', last: DateTime.utc(2026, 10, 1)).stateAt(now),
        ExclusiveState.finished,
      );
      expect(
        p('published', last: DateTime.utc(2026, 11, 1)).stateAt(now),
        ExclusiveState.open,
      );
    });

    test('the store asks once and reads the answer', () async {
      var calls = 0;
      PartnerContentStore.ask = () async {
        calls++;
        return _answer();
      };
      await PartnerContentStore.instance.refresh();
      expect(calls, 1);
      expect(PartnerContentStore.instance.content!.programmes, hasLength(2));
      expect(PartnerContentStore.instance.error, isNull);
    });

    test('a failed call keeps what was there and says so', () async {
      PartnerContentStore.instance.setForTest(
        content: PartnerContent.fromMap(_answer()),
      );
      PartnerContentStore.ask = () async => throw Exception('offline');
      await PartnerContentStore.instance.refresh();
      expect(PartnerContentStore.instance.content, isNotNull);
      expect(PartnerContentStore.instance.error, isNotNull);
    });
  });

  group('the Content tab', () {
    testWidgets('sessions and offers, with their counts', (t) async {
      PartnerContentStore.instance.setForTest(
        content: PartnerContent.fromMap(_answer()),
      );
      await _pump(t, const PartnerContentTab(org: _sponsor));
      expect(
        find.text('Sessions and offers only your employees see'),
        findsOneWidget,
      );
      expect(find.text('Sleep in the first year'), findsOneWidget);
      expect(find.text('Returning to work'), findsOneWidget);
      expect(find.textContaining('Coming soon'), findsOneWidget);
      expect(find.textContaining('Starts '), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('50% off · NORTHWIND50'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
      expect(
        find.text(partnerContentReadOnlyText('employees')),
        findsOneWidget,
      );
    });

    testWidgets('held back: a dash and the server threshold, never 0', (
      t,
    ) async {
      PartnerContentStore.instance.setForTest(
        content: PartnerContent.fromMap(_answer(held: true, min: 7)),
      );
      await _pump(t, const PartnerContentTab(org: _sponsor));
      expect(find.text('—'), findsNWidgets(3));
      expect(find.text('0'), findsNothing);
      expect(find.text(partnerContentHeldBackText(7)), findsOneWidget);
      expect(partnerContentHeldBackText(7), contains('7'));
    });

    testWidgets('nothing written yet: P1\'s empty state', (t) async {
      PartnerContentStore.instance.setForTest(
        content: PartnerContent.fromMap({
          'ok': true,
          'min_cohort': 5,
          'programmes': [],
          'offers': [],
        }),
      );
      await _pump(t, const PartnerContentTab(org: _centre));
      expect(find.text('No exclusive sessions yet'), findsOneWidget);
      expect(
        find.text('Sessions and offers only your families see'),
        findsOneWidget,
      );
    });

    testWidgets('a failed first load says so and offers Try again', (t) async {
      PartnerContentStore.instance.setForTest(
        error: 'We could not load your sessions just now.',
      );
      await _pump(t, const PartnerContentTab(org: _sponsor));
      expect(
        find.text('We could not load your sessions just now.'),
        findsOneWidget,
      );
    });

    test('read-only (R9): the screen writes nothing', () {
      final src =
          _live('lib/screens/partner_app/partner_exclusive_content.dart') +
          _live('lib/partner_app/partner_content_store.dart');
      for (final w in const ['.insert(', '.update(', '.delete(', '.upsert(']) {
        expect(src.contains(w), isFalse, reason: w);
      }
      expect(RegExp(r"rpcJson\('").allMatches(src).length, 1);
    });
  });

  group('0142 · the SQL contract', () {
    final all = _migrations()
        .map((f) => _code(f.readAsStringSync().replaceAll('\r\n', '\n')))
        .join('\n');
    final m = _code(
      _read('supabase/migrations/0142_exclusive_content_and_contract_end.sql'),
    );

    test(
      'the audience columns, never both, and a delete cannot widen access',
      () {
        for (final t in const ['programmes', 'programme_coupons']) {
          expect(
            m,
            contains(
              'alter table public.$t\n  add column if not exists audience_sponsor_id',
            ),
          );
        }
        expect(RegExp(r'on delete restrict').allMatches(m).length, 4);
        expect(m, isNot(contains('on delete set null')));
        expect(
          m,
          contains(
            'num_nonnulls(audience_sponsor_id, audience_partner_id) <= 1',
          ),
        );
        expect(m, contains('add column if not exists expert_id text'));
      },
    );

    test(
      'one rule, closed to the API; the public door asks only about the caller',
      () {
        final rule = _last('_audience_ok');
        expect(rule.file, '0142_exclusive_content_and_contract_end.sql');
        expect(rule.body, contains('security definer'));
        expect(rule.body, contains("m.status = 'active'"));
        expect(rule.body, contains("s.status in ('active', 'suspended')"));
        expect(rule.body, contains("cp.status in ('active', 'inactive')"));
        expect(
          all,
          contains(
            'revoke all on function public._audience_ok(uuid, text, text) from public, anon, authenticated;',
          ),
        );
        final door = _last('in_programme_audience');
        expect(door.body, contains('public._audience_ok(auth.uid(),'));
        expect(door.body, isNot(contains('p_uid')));
        expect(
          all,
          contains(
            'revoke all on function public._programme_open_to(text, uuid) from public, anon, authenticated;',
          ),
        );
      },
    );

    test(
      'the view and the table policy both filter, through the public door',
      () {
        final v = _last('programmes_published', kind: 'view');
        expect(v.file, '0142_exclusive_content_and_contract_end.sql');
        expect(
          v.body,
          contains(
            'public.in_programme_audience(p.audience_sponsor_id, p.audience_partner_id)',
          ),
        );
        expect(v.body, isNot(contains('_audience_ok(')));
        // Everything 0126 pinned is still there.
        expect(v.body, contains("p.display_source = 'server'"));
        expect(v.body, contains('as hosts'));
        expect(
          v.body.indexOf('p.refund_max_lessons'),
          lessThan(v.body.indexOf('p.audience_sponsor_id')),
        );
        final policy = all.substring(
          all.lastIndexOf('create policy "programmes public read"'),
        );
        expect(
          policy.substring(0, policy.indexOf(';')),
          contains('public.in_programme_audience('),
        );
      },
    );

    test('every receipt door and the coupon validator check the audience', () {
      // The file that holds each door's LATEST definition. open_payment_order
      // and record_stub_purchase were redefined by 0149 (Partner Editions A4:
      // the partner offer comes off the price) and kept the 0142 audience
      // check; the other two are still 0142's. The audience assertion below
      // is the point, the file name only says where to look.
      const latestFile = {
        'open_payment_order': '0149_partner_offer_checkout.sql',
        'claim_free_offering': '0142_exclusive_content_and_contract_end.sql',
        'record_stub_purchase': '0149_partner_offer_checkout.sql',
        'preview_programme_coupon':
            '0142_exclusive_content_and_contract_end.sql',
      };
      for (final e in latestFile.entries) {
        final d = _last(e.key);
        expect(d.file, e.value, reason: e.key);
        expect(d.body, contains('public._programme_open_to('), reason: e.key);
      }
      expect(
        _last('preview_programme_coupon').body,
        contains('public._audience_ok(auth.uid(), audience_sponsor_id'),
      );
      // Refused before money, never after: the receipt writer is unchanged.
      expect(
        _last('_write_purchase').body,
        isNot(contains('_programme_open_to')),
      );
      // The money doors keep their 0126 grants.
      expect(
        all,
        isNot(
          contains(
            RegExp(
              r'grant execute on function public\.open_payment_order\([^)]*\) to [a-z_, ]*authenticated',
            ),
          ),
        ),
      );
    });

    test('the Content RPC: one resolver, live only, behaviour held back', () {
      final fn = _last('partner_exclusive_content');
      expect(fn.body, contains('partner_exclusive_content()'));
      expect(fn.body, contains('security definer'));
      expect(fn.body, contains("set search_path = ''"));
      expect(fn.body, contains('public.my_partner_org()'));
      expect(fn.body, isNot(contains('partner_accounts')));
      expect(fn.body, isNot(contains('sponsor_admins')));
      expect(fn.body, contains("<> 'active'"));
      expect(fn.body, contains("'ok', false"));
      expect(fn.body, contains('public.sponsor_analytics_config'));
      expect(
        fn.body,
        contains("'booked', case when x.booked < v_min then null"),
      );
      expect(
        fn.body,
        contains("'redeemed', case when c.redeemed < v_min then null"),
      );
      expect(fn.body, isNot(contains("'user_id'")));
      expect(
        all,
        contains(
          'revoke all on function public.partner_exclusive_content() from public, anon;',
        ),
      );
      expect(
        all,
        contains(
          'grant execute on function public.partner_exclusive_content() to authenticated;',
        ),
      );
    });

    test('contract end (R2): ended withdraws, suspended does not', () {
      final trg = _last('_sponsor_contract_end_trg');
      expect(
        trg.body,
        contains("public.revoke_plan_by_source(r.user_id, 'sponsor', new.id"),
      );
      expect(
        trg.body,
        contains("public.void_consult_credits(r.user_id, 'sponsor', new.id"),
      );
      expect(trg.body, contains('c.booking_id is null'));
      expect(
        m,
        contains(
          "when (new.status = 'ended' and old.status is distinct from 'ended')",
        ),
      );
      final when = m.substring(
        m.indexOf('create trigger sponsors_contract_end'),
      );
      expect(
        when.substring(0, when.indexOf(';')),
        isNot(contains('suspended')),
      );
      expect(m, contains('after update of status on public.sponsors'));
    });
  });

  group('wiring', () {
    test('the Content tab opens the P4 screen for every organisation', () {
      expect(
        _live('lib/screens/partner_app/partner_tabs.dart'),
        contains('PartnerExclusiveContent(org: org)'),
      );
    });

    test('the store calls partner_exclusive_content', () {
      expect(
        _live('lib/partner_app/partner_content_store.dart'),
        contains("rpcJson('partner_exclusive_content')"),
      );
    });

    test('sign-out forgets the content', () {
      expect(
        _read('lib/partner_app/partner_sign_out.dart'),
        contains('PartnerContentStore.instance.clear()'),
      );
    });

    test('the verify script exists and walks both doors and both statuses', () {
      final v = _read('supabase/seed/verify_exclusive_content.sql');
      for (final s in const [
        'set local role authenticated',
        'set local role anon',
        'claim_free_offering',
        'open_payment_order',
        'preview_programme_coupon',
        'partner_exclusive_content',
        "status = 'suspended'",
        "status = 'ended'",
      ]) {
        expect(v, contains(s), reason: s);
      }
    });
  });
}
