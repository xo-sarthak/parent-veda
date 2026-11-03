// Pee Safe demo, item 9: the "Pee Safe store QR" switch. On gives the Pee Safe
// lockup and offer; off gives exactly what PartnerBrand gave before; and the
// rail, benefit card, You row and offer store all read it (wiring gate,
// asserted on the source).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_partner.dart';
import 'package:parentveda/services/entitlement_store.dart';
import 'package:parentveda/services/partner_brand.dart';
import 'package:parentveda/services/partner_offer_store.dart';
import 'package:parentveda/widgets/partner_benefit_card.dart';
import 'package:parentveda/widgets/partner_exclusive_rail.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() {
    PeeSafeStoreQr.reset();
    EntitlementStore.instance.setForTest();
  });

  test('on: PartnerBrand returns the Pee Safe lockup and its offer', () {
    PeeSafeStoreQr.set(true);
    final l = PartnerBrand.instance.lockup;
    expect(PeeSafeStoreQr.on, isTrue);
    expect(l?.name, 'Pee Safe');
    expect(l?.kind, 'store');
    expect(l?.logoAsset, 'assets/brand/pee_safe/logo.png');
    expect(PartnerBrand.instance.hasAny, isTrue);
    expect(PartnerOfferStore.instance.forSponsor(l?.id), [kPeeSafeDemoOffer]);

    final rail = partnerRailFor(
      sponsor: l,
      care: null,
      programmes: const [],
      offers: PartnerOfferStore.instance.all,
    );
    expect(rail?.eyebrow, 'Presented by Pee Safe');
    expect(rail?.offers, [kPeeSafeDemoOffer]);
    expect(
      storeBenefitCopy(name: 'Pee Safe', offers: rail!.offers).$1,
      '15% off any postpartum care session',
    );
  });

  test('off and reset give exactly what PartnerBrand gave before', () {
    const sponsor = SponsorInfo(id: 's1', name: 'Northwind Systems');
    for (final seed in [null, sponsor]) {
      EntitlementStore.instance.setForTest(sponsor: seed);
      final before = PartnerBrand.instance.lockup;
      final offersBefore = PartnerOfferStore.instance.all.length;
      PeeSafeStoreQr.set(true);
      PeeSafeStoreQr.set(false);
      expect(PeeSafeStoreQr.on, isFalse);
      expect(PartnerBrand.instance.lockup?.name, before?.name);
      expect(PartnerBrand.instance.lockup?.id, before?.id);
      expect(PartnerOfferStore.instance.all.length, offersBefore);
      PeeSafeStoreQr.set(true);
      PeeSafeStoreQr.reset();
      expect(PartnerBrand.instance.lockup?.name, before?.name);
      expect(PartnerOfferStore.instance.demoOffers, isEmpty);
    }
  });

  test('wiring: the rail, card, row and offers read the switch', () {
    String src(String p) => File(p).readAsStringSync();
    final rail = src('lib/widgets/partner_exclusive_rail.dart');
    expect(rail, contains('sponsor: PartnerBrand.instance.lockup'));
    expect(rail, contains('offers: PartnerOfferStore.instance.all'));
    final card = src('lib/widgets/partner_benefit_card.dart');
    expect(card, contains('final info = PartnerBrand.instance.lockup'));
    expect(card, contains('final sponsor = PartnerBrand.instance.lockup'));
    expect(card, contains('storeBenefitCopy('));
    expect(src('lib/services/partner_offer_store.dart'),
        contains('...demoOffers'));
    expect(src('lib/services/partner_brand.dart'),
        contains('if (_demoLockup != null) return _demoLockup'));
    expect(src('lib/widgets/partner_lockup.dart'), contains('info.logoAsset'));
    // Reachable: the switch sits in the Brand Studio tour.
    expect(src('lib/screens/brand_showcase_screen.dart'),
        contains('const PeeSafeStoreQrSwitch()'));
    // Home strip and You row are mounted already (A1-A3 tests hold those).
    expect(src('lib/screens/profile/pv_you_screen.dart'),
        contains('PartnerBenefitsRow('));
  });
}
