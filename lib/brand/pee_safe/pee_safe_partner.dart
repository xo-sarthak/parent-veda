// =============================================================================
//  PeeSafeStoreQr — the Partner track's "Pee Safe store QR" demo switch
// -----------------------------------------------------------------------------
//  Pee Safe demo, item 9 (docs/PEE-SAFE-DEMO.md, track A). A family who
//  scanned a QR in a Pee Safe store would arrive as a partner family: the
//  homes' lockup, the You chip, the benefit card, the rail and an offer all
//  name Pee Safe. There is no such row in the database yet (P1: demo only, no
//  database change), so this switch plays that family on the phone:
//
//    on  → PartnerBrand.demoLockup = kPeeSafePartnerLockup
//          PartnerOfferStore.demoOffers = [kPeeSafeDemoOffer]
//    off → both cleared; every surface is exactly what it was.
//
//  MEMORY ONLY. Nothing is saved, fetched or sent; a restart turns it off.
//  The surfaces stay ParentVeda ink: lime shows only inside Pee Safe's own
//  logo (PartnerMark draws the bundled asset). "Presented by Pee Safe" is the
//  rail's eyebrow, the benefit card's eyebrow and the You row's line.
//
//  Gated on kPeeSafeDemo: with the flag off, set(true) does nothing.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/partner_brand.dart';
import '../../services/partner_offer_store.dart';
import '../../theme/pv_fonts.dart';
import 'pee_safe_brand.dart';

/// The id the demo lockup and its offer share, so the rail's
/// `o.audienceId == sponsor.id` rule pairs them like a real sponsor's.
const String kPeeSafeStoreQrId = 'pee_safe_store_qr_demo';

/// What a Pee Safe store-QR family's lockup draws. `kind: 'store'` gives the
/// rail and benefit card their "Presented by" wording.
const PartnerLockupInfo kPeeSafePartnerLockup = PartnerLockupInfo(
  name: 'Pee Safe',
  kind: 'store',
  id: kPeeSafeStoreQrId,
  logoAsset: 'assets/brand/pee_safe/logo.png',
);

/// The one offer the demo family holds. Local only: the server has never
/// heard of it, so it is never applied at a real checkout.
const PartnerOffer kPeeSafeDemoOffer = PartnerOffer(
  code: 'PEESAFE15',
  kind: 'percent',
  value: 15,
  audience: 'sponsor',
  audienceId: kPeeSafeStoreQrId,
  label: 'any postpartum care session',
);

abstract final class PeeSafeStoreQr {
  /// True while the demo family is being played.
  static bool get on =>
      identical(PartnerBrand.instance.demoLockup, kPeeSafePartnerLockup);

  static void set(bool value) {
    if (value && !kPeeSafeDemo) return;
    PartnerBrand.instance.demoLockup = value ? kPeeSafePartnerLockup : null;
    PartnerOfferStore.instance.demoOffers =
        value ? const [kPeeSafeDemoOffer] : const [];
  }

  /// Back to the state before the demo. Item 10's "Reset demo" calls this.
  static void reset() {
    PartnerBrand.instance.reset();
    PartnerOfferStore.instance.demoOffers = const [];
  }
}

/// The switch row, for the Brand Studio tour now and the Showcase (item 10).
class PeeSafeStoreQrSwitch extends StatelessWidget {
  const PeeSafeStoreQrSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kPeeSafeDemo) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: PartnerBrand.instance,
      builder: (context, _) => Container(
        key: const ValueKey('pee_safe_store_qr_switch'),
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6E2E8)),
        ),
        child: Row(
          children: [
            const Icon(Icons.qr_code_2_outlined, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pee Safe store QR',
                    style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Play a family who scanned the QR in a Pee Safe store. '
                    'On this phone only.',
                    style: pvManrope(fontSize: 11.5, height: 1.4),
                  ),
                ],
              ),
            ),
            Switch(
              value: PeeSafeStoreQr.on,
              onChanged: PeeSafeStoreQr.set,
            ),
          ],
        ),
      ),
    );
  }
}
