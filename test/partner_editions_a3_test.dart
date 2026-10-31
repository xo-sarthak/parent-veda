// Partner Editions A3: a family's own partner offers (0148), the offer card in
// the rail, a doctor's words-only benefit card on You, the always-shown
// "Your benefits" row, one Benefits page for employer and doctor, and the
// wiring gate for all of it on the source.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/care_partner/care_partner_models.dart';
import 'package:parentveda/care_partner/care_partner_store.dart';
import 'package:parentveda/screens/enterprise/employer_benefits_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_learning_data.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/services/credits_store.dart';
import 'package:parentveda/services/entitlement_store.dart';
import 'package:parentveda/services/partner_brand.dart';
import 'package:parentveda/services/partner_offer_store.dart';
import 'package:parentveda/services/programme_store.dart';
import 'package:parentveda/services/remote/sync_registry.dart';
import 'package:parentveda/widgets/partner_benefit_card.dart';
import 'package:parentveda/widgets/partner_exclusive_rail.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sponsor = SponsorInfo(id: 's1', name: 'Northwind Systems');

PartnerOffer _offer({
  String code = 'NW15',
  String audience = 'sponsor',
  String id = 's1',
  String? label = 'any masterclass',
  DateTime? ends,
}) => PartnerOffer(
  code: code,
  kind: 'percent',
  value: 15,
  audience: audience,
  audienceId: id,
  label: label,
  endsAt: ends,
);

LearningProgram _prog(String id, {String? sponsor, String? partner}) =>
    LearningProgram(
      id: id,
      kind: LearningKind.masterclass,
      instructorId: '',
      title: 'Dr Rao on your 20-week scan',
      subtitle: '',
      topics: const [],
      accent: const Color(0xFF000000),
      price: 'Free',
      status: LearningStatus.available,
      isLiveScheduled: true,
      startLabel: '6 Nov',
      audienceSponsorId: sponsor,
      audiencePartnerId: partner,
    );

CarePartner _care({String type = CarePartnerType.doctor}) => CarePartner(
  id: 'p1',
  name: type == CarePartnerType.doctor
      ? 'Dr Meera Rao'
      : 'Bloom Fertility Centre',
  type: type,
  status: PartnerStatus.active,
);

PartnerLockupInfo _lockup() =>
    const PartnerLockupInfo(name: 'Northwind Systems', id: 's1');

String _src(String path) => File(path).readAsStringSync();

Future<void> _pumpAt(
  WidgetTester t,
  Widget child, {
  double scale = 1.0,
  bool page = false,
}) async {
  t.view.physicalSize = const Size(360, 800);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(360, 800),
          textScaler: TextScaler.linear(scale),
        ),
        child: page
            ? child
            : Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() {
    EntitlementStore.instance.setForTest();
    CreditsStore.instance.setForTest();
    CarePartnerStore.instance.resetAll();
    ProgrammeStore.instance.resetForTest();
    PartnerOfferStore.instance.debugSet(const []);
  });

  group('an offer, as 0148 returns it', () {
    test('a row parses; a bad row is dropped, never a crash', () {
      final o = PartnerOffer.fromRow({
        'code': 'NW15',
        'kind': 'percent',
        'value': 15,
        'label': 'any masterclass',
        'ends_at': '2026-11-30T18:29:59+00:00',
        'audience': 'sponsor',
        'audience_id': 's1',
      })!;
      expect(o.isSponsor, isTrue);
      expect(o.headline, '15% off any masterclass');
      expect(o.until, startsWith('Until '));
      expect(PartnerOffer.fromRow({'code': 'X', 'value': 5}), isNull);
      expect(
        PartnerOffer.fromRow({
          'code': 'X',
          'value': 5,
          'audience': 'everyone',
          'audience_id': 'a',
        }),
        isNull,
      );
    });

    test('flat in rupees, no label means any session, no end date', () {
      const o = PartnerOffer(
        code: 'F',
        kind: 'flat',
        value: 10000,
        audience: 'partner',
        audienceId: 'p1',
      );
      expect(o.headline, '₹100 off any ParentVeda session');
      expect(o.until, 'No end date');
    });

    test('the store forgets the account on sign-out', () {
      PartnerOfferStore.instance.debugSet([_offer()]);
      SyncRegistry.resetAll();
      expect(PartnerOfferStore.instance.all, isEmpty);
    });

    test('registered for the reset and the sign-in resync, memory only', () {
      final s = _src('lib/services/partner_offer_store.dart');
      expect(s, contains('SyncRegistry.registerReset(_resetForAccount)'));
      expect(s, contains('SyncRegistry.register(refresh)'));
      expect(s, contains("rpcJson('my_partner_offers')"));
      expect(s, isNot(contains('SharedPreferences')));
    });

    test('0148 answers the caller only, with no usage counts', () {
      final m = _src('supabase/migrations/0148_partner_offers.sql');
      expect(
        m,
        contains('create or replace function public.my_partner_offers()'),
      );
      expect(m, contains('security definer set search_path = \'\''));
      expect(
        m,
        contains(
          'revoke all on function public.my_partner_offers() from public, anon, authenticated;',
        ),
      );
      expect(
        m,
        contains(
          'grant execute on function public.my_partner_offers() to authenticated;',
        ),
      );
      expect(m, contains('public._audience_ok(v_uid,'));
      final body = m.substring(m.indexOf('jsonb_build_object('));
      final built = body.substring(0, body.indexOf('order by'));
      expect(built, isNot(contains("'redeemed'")));
      expect(built, isNot(contains("'max_redemptions'")));
      expect(
        File('supabase/seed/verify_partner_offers.sql').existsSync(),
        isTrue,
      );
    });
  });

  group('the offer in the rail', () {
    test('a sponsor\'s offer alone is a rail; another\'s is not shown', () {
      final rail = partnerRailFor(
        sponsor: _lockup(),
        care: null,
        programmes: const [],
        offers: [
          _offer(),
          _offer(code: 'OTHER', id: 's2'),
        ],
      )!;
      expect(rail.offers.map((o) => o.code), ['NW15']);
      expect(rail.isEmpty, isFalse);
    });

    test('a doctor\'s offer alone is the doctor\'s rail', () {
      final rail = partnerRailFor(
        sponsor: null,
        care: _care(),
        programmes: const [],
        offers: [_offer(code: 'DR10', audience: 'partner', id: 'p1')],
      )!;
      expect(rail.eyebrow, 'From Dr Meera Rao');
      expect(rail.offers.single.code, 'DR10');
    });

    test('a sponsor still wins over a doctor', () {
      final rail = partnerRailFor(
        sponsor: _lockup(),
        care: _care(),
        programmes: const [],
        offers: [
          _offer(),
          _offer(code: 'DR10', audience: 'partner', id: 'p1'),
        ],
      )!;
      expect(rail.offers.map((o) => o.code), ['NW15']);
    });

    for (final scale in [1.0, 1.5]) {
      testWidgets('the offer card fits 360pt at ${scale}x', (t) async {
        EntitlementStore.instance.setForTest(sponsor: _sponsor);
        PartnerOfferStore.instance.debugSet([
          _offer(label: 'the back-to-work feeding and childcare masterclass'),
        ]);
        await _pumpAt(
          t,
          PartnerExclusiveRail(
            p: V2PaletteStore.instance.current,
            head: (e, h) => Column(children: [Text(e), Text(h)]),
          ),
          scale: scale,
        );
        expect(t.takeException(), isNull);
        expect(
          find.byKey(const ValueKey('partner_rail_offer_NW15')),
          findsOneWidget,
        );
        expect(find.text('Offer'), findsOneWidget);
      });
    }

    test('never says Auto-applied: checkout does not take offers yet', () {
      for (final path in [
        'lib/widgets/partner_exclusive_rail.dart',
        'lib/widgets/partner_benefit_card.dart',
        'lib/services/partner_offer_store.dart',
        'lib/screens/enterprise/employer_benefits_screen.dart',
      ]) {
        final code = _src(
          path,
        ).split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');
        expect(code, isNot(contains('Auto-applied')), reason: path);
      }
    });
  });

  group('a doctor\'s benefit card on You', () {
    test('the copy, for a doctor and for a clinic', () {
      final offerOnly = partnerRailFor(
        sponsor: null,
        care: _care(),
        programmes: const [],
        offers: [_offer(code: 'DR10', audience: 'partner', id: 'p1')],
      )!;
      expect(careBenefitCopy(rail: offerOnly, person: true), (
        '15% off any masterclass',
        "Your doctor's offer lives here. Your health details stay private.",
      ));
      final sessionsOnly = partnerRailFor(
        sponsor: null,
        care: _care(type: CarePartnerType.ivfCentre),
        programmes: [
          _prog('a', partner: 'p1'),
          _prog('b', partner: 'p1'),
        ],
      )!;
      expect(careBenefitCopy(rail: sessionsOnly, person: false), (
        '2 sessions only Bloom Fertility Centre patients see',
        "Your clinic's sessions live here. Your health details stay private.",
      ));
    });

    testWidgets('no room without a real benefit', (t) async {
      CarePartnerStore.instance.debugSeed(partner: _care());
      await _pumpAt(t, const PartnerCareBenefitCard());
      expect(
        find.byKey(const ValueKey('partner_care_benefit_card')),
        findsNothing,
      );
      expect(t.getSize(find.byType(PartnerCareBenefitCard)), Size.zero);
    });

    testWidgets('a sponsor\'s card keeps the slot', (t) async {
      EntitlementStore.instance.setForTest(sponsor: _sponsor);
      CarePartnerStore.instance.debugSeed(partner: _care());
      PartnerOfferStore.instance.debugSet([
        _offer(code: 'DR10', audience: 'partner', id: 'p1'),
      ]);
      await _pumpAt(t, const PartnerCareBenefitCard());
      expect(
        find.byKey(const ValueKey('partner_care_benefit_card')),
        findsNothing,
      );
    });

    for (final scale in [1.0, 1.5]) {
      testWidgets('words only, fits 360pt at ${scale}x', (t) async {
        CarePartnerStore.instance.debugSeed(partner: _care());
        ProgrammeStore.instance.setItemsForTest([_prog('a', partner: 'p1')]);
        PartnerOfferStore.instance.debugSet([
          _offer(code: 'DR10', audience: 'partner', id: 'p1'),
        ]);
        await _pumpAt(t, const PartnerCareBenefitCard(), scale: scale);
        expect(t.takeException(), isNull);
        expect(find.text('FROM DR MEERA RAO'), findsOneWidget);
        expect(
          find.text(
            "Your doctor's sessions and offer live here. Your health details stay private.",
          ),
          findsOneWidget,
        );
        expect(find.byType(Image), findsNothing);
        expect(
          find.byKey(const ValueKey('partner_benefit_meter')),
          findsNothing,
        );
      });
    }
  });

  group('"Your benefits" is always there', () {
    Future<String?> subtitle(WidgetTester t) async {
      await _pumpAt(t, const PartnerBenefitsRow(tint: Color(0xFFEEEEEE)));
      expect(find.text('Your benefits'), findsOneWidget);
      for (final s in [
        'Does your employer offer ParentVeda?',
        'From Northwind Systems',
        'From Dr Meera Rao',
      ]) {
        if (find.text(s).evaluate().isNotEmpty) return s;
      }
      return null;
    }

    testWidgets('no partner: the question', (t) async {
      expect(await subtitle(t), 'Does your employer offer ParentVeda?');
    });

    testWidgets('a sponsor: its name', (t) async {
      EntitlementStore.instance.setForTest(sponsor: _sponsor);
      expect(await subtitle(t), 'From Northwind Systems');
    });

    testWidgets('a doctor with a benefit: their name', (t) async {
      CarePartnerStore.instance.debugSeed(partner: _care());
      PartnerOfferStore.instance.debugSet([
        _offer(code: 'DR10', audience: 'partner', id: 'p1'),
      ]);
      expect(await subtitle(t), 'From Dr Meera Rao');
    });
  });

  group('one Benefits page', () {
    testWidgets('neither: the empty state, unchanged; titled Your benefits', (
      t,
    ) async {
      await _pumpAt(t, const EmployerBenefitsScreen(), page: true);
      expect(
        find.byKey(const ValueKey('employer_benefits_empty')),
        findsOneWidget,
      );
      expect(find.text('Your benefits'), findsOneWidget);
    });

    for (final scale in [1.0, 1.5]) {
      testWidgets('a doctor, no sponsor: their section, then the employer '
          'question, at 360pt ${scale}x', (t) async {
        CarePartnerStore.instance.debugSeed(partner: _care());
        ProgrammeStore.instance.setItemsForTest([_prog('a', partner: 'p1')]);
        PartnerOfferStore.instance.debugSet([
          _offer(code: 'DR10', audience: 'partner', id: 'p1'),
        ]);
        await _pumpAt(
          t,
          const EmployerBenefitsScreen(),
          page: true,
          scale: scale,
        );
        expect(t.takeException(), isNull);
        expect(
          find.byKey(const ValueKey('employer_benefits_care')),
          findsOneWidget,
        );
        expect(find.text('From Dr Meera Rao'), findsOneWidget);
        expect(find.text('15% off any masterclass'), findsOneWidget);
        await t.scrollUntilVisible(
          find.byKey(const ValueKey('employer_benefits_activate')),
          200,
        );
        expect(
          find.byKey(const ValueKey('employer_benefits_activate')),
          findsOneWidget,
        );
      });
    }

    testWidgets('a sponsor and a doctor: both, on the one page', (t) async {
      EntitlementStore.instance.setForTest(sponsor: _sponsor);
      CarePartnerStore.instance.debugSeed(partner: _care());
      PartnerOfferStore.instance.debugSet([
        _offer(label: 'the leave session'),
        _offer(code: 'DR10', audience: 'partner', id: 'p1'),
      ]);
      await _pumpAt(t, const EmployerBenefitsScreen(), page: true);
      expect(
        find.byKey(const ValueKey('employer_benefits_active')),
        findsOneWidget,
      );
      expect(find.text('15% off the leave session'), findsOneWidget);
      await t.scrollUntilVisible(
        find.byKey(const ValueKey('employer_benefits_care_head')),
        200,
      );
      expect(find.text('From Dr Meera Rao'), findsOneWidget);
    });
  });

  group('wiring gate', () {
    test(
      'You: the doctor card under the sponsor\'s, the row in Your things',
      () {
        final you = _src('lib/screens/profile/pv_you_screen.dart');
        final card = you.indexOf('const PartnerBenefitCard(),');
        final care = you.indexOf('const PartnerCareBenefitCard(),');
        expect(card, greaterThan(0));
        expect(care, greaterThan(card));
        final things = you.indexOf("ValueKey('pv_profile_things')");
        final row = you.indexOf('PartnerBenefitsRow(tint: tint),');
        expect(row, greaterThan(things));
        expect(row, lessThan(you.indexOf("ValueKey('pv_profile_quiet')")));
      },
    );

    test('the rail reads the offers', () {
      final s = _src('lib/widgets/partner_exclusive_rail.dart');
      expect(s, contains('offers: PartnerOfferStore.instance.all,'));
      expect(s, contains('PartnerOfferStore.instance.ensureLoaded();'));
    });

    test('every way in keeps the route name `employer`', () {
      for (final path in [
        'lib/widgets/partner_benefit_card.dart',
        'lib/widgets/partner_exclusive_rail.dart',
        'lib/widgets/partner_lockup.dart',
      ]) {
        expect(
          _src(path),
          contains("RouteSettings(name: 'employer')"),
          reason: path,
        );
      }
      expect(
        _src('lib/screens/pregnancy/preg_more_screen.dart'),
        contains("_push('employer', () => EmployerBenefitsScreen("),
      );
      expect(
        _src('lib/screens/ttc/ttc_more_tab.dart'),
        contains("'employer',"),
      );
    });

    test('the doctor card draws no logo, no monogram, no meter (D3)', () {
      final s = _src('lib/widgets/partner_benefit_card.dart');
      final care = s.substring(
        s.indexOf('class PartnerCareBenefitCard'),
        s.indexOf('class PartnerBenefitsRow'),
      );
      expect(care, isNot(contains('PartnerMark(')));
      expect(care, isNot(contains('_Meter(')));
      expect(care, isNot(contains('logoUrl')));
      expect(care, isNot(contains('PresentedBy(')));
    });

    test('the old title is kept for revert', () {
      final s = _src('lib/screens/enterprise/employer_benefits_screen.dart');
      expect(
        s,
        contains(
          "// Kept for revert (A3): _p('Employer benefits', 'Employer benefits'),",
        ),
      );
    });
  });
}
