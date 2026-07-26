// The parent-facing UI. These are widget tests on purpose: the failures this
// module cannot afford (a banned word rendering, a partner appearing on the
// wrong page, an empty slot taking up space) are all things a unit test on the
// model would happily pass.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/care_partner/care_partner_models.dart';
import 'package:parentveda/care_partner/care_partner_store.dart';
import 'package:parentveda/care_partner/care_visibility.dart';
import 'package:parentveda/screens/care_partner/care_circle_screen.dart';
import 'package:parentveda/screens/care_partner/care_partner_card.dart';
import 'package:parentveda/screens/care_partner/care_partner_slot.dart';

CarePartner _partner({
  String name = 'Dr Meera Rao',
  String type = CarePartnerType.lactationConsultant,
  PartnerStatus status = PartnerStatus.active,
  TrustMessage trust = const TrustMessage(),
  String subtitle = '',
}) =>
    CarePartner(
      id: 'p1',
      name: name,
      type: type,
      status: status,
      speciality: subtitle,
      trust: trust,
    );

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => CarePartnerStore.instance.resetAll());

  group('CarePartnerCard', () {
    testWidgets('the line shape says who invited her', (tester) async {
      await tester.pumpWidget(_host(CarePartnerCard(partner: _partner())));
      expect(find.textContaining('Dr Meera Rao', findRichText: true),
          findsOneWidget);
    });

    testWidgets('a banned word configured by an admin never reaches the screen',
        (tester) async {
      final p = _partner(
          trust: const TrustMessage(primary: 'Sponsored by'));
      await tester.pumpWidget(_host(CarePartnerCard(
          partner: p, shape: CarePartnerCardShape.full)));
      expect(find.textContaining('Sponsored', findRichText: true), findsNothing);
      expect(find.textContaining('INVITED BY', findRichText: true),
          findsOneWidget);
    });

    testWidgets('falls back to initials, ignoring the title', (tester) async {
      await tester.pumpWidget(_host(CarePartnerCard(
          partner: _partner(), shape: CarePartnerCardShape.full)));
      // Meera Rao -> MR, not DM.
      expect(find.text('MR'), findsOneWidget);
    });

    testWidgets('an organisation with no name still renders something',
        (tester) async {
      await tester.pumpWidget(_host(CarePartnerCard(
        partner: _partner(name: '', type: CarePartnerType.hospital),
        shape: CarePartnerCardShape.full,
      )));
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('a long name does not overflow the line shape',
        (tester) async {
      await tester.pumpWidget(_host(SizedBox(
        width: 240,
        child: CarePartnerCard(
            partner: _partner(
                name: 'Dr Priyadarshini Venkataraghavan Subramaniam')),
      )));
      expect(tester.takeException(), isNull);
    });
  });

  group('CarePartnerSlot', () {
    testWidgets('renders nothing when this family has no partner',
        (tester) async {
      await tester.pumpWidget(_host(const CarePartnerSlot(
        surface: CareSurface.topic,
        topic: CareTopic.breastfeeding,
      )));
      await tester.pump();
      expect(find.byType(CarePartnerCard), findsNothing);
      // And takes no space, so a screen using it needs no conditional padding.
      expect(tester.getSize(find.byType(CarePartnerSlot)), Size.zero);
    });

    testWidgets('shows the partner on a topic they cover', (tester) async {
      CarePartnerStore.instance.debugSeed(partner: _partner());
      await tester.pumpWidget(_host(const CarePartnerSlot(
        surface: CareSurface.topic,
        topic: CareTopic.breastfeeding,
      )));
      await tester.pump();
      expect(find.byType(CarePartnerCard), findsOneWidget);
    });

    testWidgets('stays silent on a topic they do not cover', (tester) async {
      CarePartnerStore.instance.debugSeed(partner: _partner());
      await tester.pumpWidget(_host(const CarePartnerSlot(
        surface: CareSurface.topic,
        topic: CareTopic.vaccination,
      )));
      await tester.pump();
      expect(find.byType(CarePartnerCard), findsNothing);
    });

    testWidgets('tapping opens the Care Circle', (tester) async {
      CarePartnerStore.instance.debugSeed(partner: _partner());
      await tester.pumpWidget(_host(const CarePartnerSlot(
        surface: CareSurface.profile,
        shape: CarePartnerCardShape.full,
      )));
      await tester.pump();
      await tester.tap(find.byType(CarePartnerCard));
      await tester.pumpAndSettle();
      expect(find.byType(CareCircleScreen), findsOneWidget);
    });
  });

  group('CareCircleScreen', () {
    testWidgets('ParentVeda is always there, even with no partner',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CareCircleScreen()));
      await tester.pump();
      expect(find.text('ParentVeda'), findsOneWidget);
      expect(find.byType(CarePartnerCard), findsNothing);
    });

    testWidgets('a partner appears above ParentVeda, never below',
        (tester) async {
      CarePartnerStore.instance.debugSeed(partner: _partner());
      await tester.pumpWidget(const MaterialApp(home: CareCircleScreen()));
      await tester.pump();
      final partnerY =
          tester.getTopLeft(find.byType(CarePartnerCard)).dy;
      final ourY = tester.getTopLeft(find.text('ParentVeda')).dy;
      expect(partnerY, lessThan(ourY));
    });

    testWidgets('an inactive partner is still listed, and said plainly',
        (tester) async {
      CarePartnerStore.instance
          .debugSeed(partner: _partner(status: PartnerStatus.inactive));
      await tester.pumpWidget(const MaterialApp(home: CareCircleScreen()));
      await tester.pump();
      expect(find.byType(CarePartnerCard), findsOneWidget);
      expect(find.textContaining('No longer partnered'), findsOneWidget);
    });
  });
}
