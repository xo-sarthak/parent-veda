// =============================================================================
//  Pee Safe demo, item 8: where a sponsored notification's tap lands
// -----------------------------------------------------------------------------
//  A notification that leads to a sale has to land somewhere useful, not on a
//  sponsor sheet. Each of the three opens the real screen it talks about:
//    * week 36       -> the hospital bag (V1, the version that opens by default)
//    * first days    -> the peri care read, in the one reader
//    * travel        -> "The 4-month travel kit" reco detail
//  The Pee Safe products already sit on each of those screens (items 5 and 7),
//  so the path is: notification, then ParentVeda's own page, then the products.
//
//  Called from NotificationOpener's brand branch. False means "not one of
//  ours, or it cannot open here", and the caller falls back to the sponsor
//  sheet, so a tap never dead-ends.
// =============================================================================

import 'package:flutter/material.dart';

// import '../../screens/post_pregnancy/pp_reco_data.dart' show kReco; // kept for revert
// import '../../screens/post_pregnancy/reco_detail_screen.dart' show RecoDetailScreen; // kept for revert
import '../../screens/products/pv_shelf_screen.dart' show PvShelfScreen;
import '../../screens/tools/ready_for_birth_screen.dart' show ReadyForBirthScreen;
import '../../services/pregnancy_controller.dart' show PregnancyController;
import 'pee_safe_brand.dart';
import 'pee_safe_reads.dart' show openPeeSafeRead;

/// The read the peri care notification opens.
const String kPeeSafeNotifPeriReadId = 'ps_read_peri';

/// Opens the screen for the Pee Safe notification [campaignId]. False when it
/// is not a Pee Safe notification or its screen cannot open in this profile.
bool openPeeSafeNotification(BuildContext context, String campaignId) {
  if (!kPeeSafeDemo) return false;
  switch (campaignId) {
    case kPeeSafeNotifBagId:
      final preg = PregnancyController.current;
      if (preg == null) return false;
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'tools/hospital_bag'),
        // The live bag (2026-11-03). Kept for revert: HospitalBagScreen(controller: preg).
        builder: (_) => ReadyForBirthScreen(controller: preg),
      ));
      return true;
    case kPeeSafeNotifPeriId:
      return openPeeSafeRead(context, kPeeSafeNotifPeriReadId);
    case kPeeSafeNotifTravelId:
      // The live store's On the move shelf (2026-11-03), where the travel kit
      // is. Kept for revert: the RecoDetailScreen of kPeeSafeTravelKey at
      // 'pp/reco_detail' (the old Recommendations screens).
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'products/shelf'),
        builder: (_) => const PvShelfScreen(categoryId: 'on_the_move'),
      ));
      return true;
  }
  return false;
}
