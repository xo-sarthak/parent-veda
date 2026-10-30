// Partner Editions A1: who the homes name, how, and that every home and the
// new onboarding actually reach it (the wiring gate, asserted on the source).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/care_partner/care_partner_models.dart';
import 'package:parentveda/care_partner/care_partner_store.dart';
import 'package:parentveda/screens/care_partner/care_partner_card.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/services/entitlement_store.dart';
import 'package:parentveda/services/partner_brand.dart';
import 'package:parentveda/widgets/partner_lockup.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sponsor = SponsorInfo(id: 's1', name: 'Northwind Systems');

CarePartner _doctor({String type = CarePartnerType.doctor}) => CarePartner(
  id: 'p1',
  name: 'Dr Meera Rao',
  type: type,
  status: PartnerStatus.active,
  organisation: 'Rao Women’s Clinic',
  city: 'Pune',
);

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() {
    EntitlementStore.instance.setForTest();
    CarePartnerStore.instance.resetAll();
  });

  group('PartnerBrand (D1, D3)', () {
    test('no partner: nothing to draw', () {
      expect(PartnerBrand.instance.hasAny, isFalse);
      expect(PartnerBrand.instance.lockup, isNull);
      expect(PartnerBrand.instance.careLine, isNull);
    });

    test('a sponsor owns the lockup', () {
      EntitlementStore.instance.setForTest(sponsor: _sponsor);
      expect(PartnerBrand.instance.lockup?.name, 'Northwind Systems');
      expect(PartnerBrand.instance.lockup?.logoUrl, isNull);
    });

    test('a doctor is a line, never a lockup', () {
      CarePartnerStore.instance.debugSeed(partner: _doctor());
      expect(PartnerBrand.instance.lockup, isNull);
      expect(PartnerBrand.instance.careLine?.name, 'Dr Meera Rao');
    });

    test('with both, the sponsor takes the strip', () {
      EntitlementStore.instance.setForTest(sponsor: _sponsor);
      CarePartnerStore.instance.debugSeed(partner: _doctor());
      expect(PartnerBrand.instance.lockup, isNotNull);
      expect(PartnerBrand.instance.careLine, isNull);
    });

    test('a blank logo url is no logo', () {
      EntitlementStore.instance.setForTest(
        sponsor: const SponsorInfo(id: 's1', name: 'Northwind', logoUrl: '  '),
      );
      expect(PartnerBrand.instance.lockup?.logoUrl, isNull);
    });

    test('a person by role, an organisation by place', () {
      expect(careLineLabel(_doctor()), 'Your doctor');
      expect(
        careLineLabel(_doctor(type: CarePartnerType.ivfCentre)),
        'Your clinic',
      );
      expect(
        careLineLabel(_doctor(type: 'pelvic_floor_coach')),
        'Your care partner',
      );
      expect(careLineDetail(_doctor()), 'Rao Women’s Clinic');
      // An organisation's own name is already the line; the city goes under.
      expect(careLineDetail(_doctor(type: CarePartnerType.ivfCentre)), 'Pune');
    });
  });

  group('PartnerStrip', () {
    final p = V2PaletteStore.instance.current;

    testWidgets('no partner takes no room at all', (t) async {
      await t.pumpWidget(_host(Column(children: [PartnerStrip(p: p)])));
      expect(t.getSize(find.byType(PartnerStrip)), Size.zero);
    });

    testWidgets('a sponsor draws ParentVeda × name, in ink, and taps through', (
      t,
    ) async {
      EntitlementStore.instance.setForTest(sponsor: _sponsor);
      await t.pumpWidget(_host(PartnerStrip(p: p)));
      expect(find.text('ParentVeda'), findsOneWidget);
      expect(find.text('×'), findsOneWidget);
      expect(find.text('Northwind Systems'), findsOneWidget);
      // No logo: the monogram, never a broken image.
      expect(find.text('NS'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('partner_strip_lockup')),
        findsOneWidget,
      );
    });

    testWidgets('a very long sponsor name ellipsises instead of overflowing', (
      t,
    ) async {
      EntitlementStore.instance.setForTest(
        sponsor: const SponsorInfo(
          id: 's1',
          name:
              'The Extremely Long Named Northwind Systems Employee Wellbeing Trust',
        ),
      );
      t.view.physicalSize = const Size(360, 800);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        _host(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: PartnerStrip(p: p),
          ),
        ),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('a doctor draws the home line with the place under the name', (
      t,
    ) async {
      CarePartnerStore.instance.debugSeed(partner: _doctor());
      await t.pumpWidget(_host(PartnerStrip(p: p)));
      await t.pump();
      expect(find.text('Your doctor · Dr Meera Rao'), findsOneWidget);
      expect(find.text('Rao Women’s Clinic'), findsOneWidget);
      expect(find.text('ParentVeda'), findsNothing);
    });

    testWidgets('the home card shape draws inside one box at phone width', (
      t,
    ) async {
      t.view.physicalSize = const Size(360, 800);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        _host(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: CarePartnerCard(
              partner: _doctor(),
              shape: CarePartnerCardShape.home,
            ),
          ),
        ),
      );
      expect(t.takeException(), isNull);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });
  });

  group('wiring gate', () {
    String src(String path) => File(path).readAsStringSync();

    test('every home passes the strip into its hero, under the top row', () {
      for (final path in [
        'lib/screens/home_v3_screen.dart',
        'lib/screens/ttc/ttc_home_v3.dart',
        'lib/screens/post_pregnancy/pp_home_v3.dart',
      ]) {
        expect(
          src(path),
          contains('partner: PartnerStrip(p: p)'),
          reason: path,
        );
      }
      expect(
        src('lib/screens/v2/v3_preg_hero.dart'),
        contains('?widget.partner,'),
      );
      expect(src('lib/screens/ttc/ttc_home_v3.dart'), contains('?partner,'));
      expect(
        src('lib/screens/post_pregnancy/pp_home_v3.dart'),
        contains('top: top + 10 + 38, child: partner!'),
      );
    });

    test('the lockup is not the sponsorship component', () {
      expect(
        src('lib/widgets/partner_lockup.dart'),
        isNot(contains('PresentedBy(')),
      );
    });

    test('the new onboarding binds a clinic QR and shows the welcome', () {
      final s = src('lib/screens/auth/onboarding/onboarding_flow.dart');
      final finish = s.substring(s.indexOf('Future<void> _finish() async'));
      expect(finish, contains('CarePartnerStore.instance.applyPending()'));
      expect(finish, contains('showCareWelcome(context)'));
      expect(s, contains('_careInvitedBox(p)'));
    });
  });
}
