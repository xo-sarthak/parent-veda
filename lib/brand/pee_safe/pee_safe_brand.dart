// =============================================================================
//  Pee Safe — the brand record for the stakeholder demo
// -----------------------------------------------------------------------------
//  DEMO ONLY (docs/PEE-SAFE-DEMO.md, P1). Nothing here touches the database.
//  Every Pee Safe surface in this build checks [kPeeSafeDemo]; turning it off
//  is a BEFORE-LAUNCH item.
//
//  Lime is Pee Safe's own colour. It appears only on Pee Safe's own surfaces
//  (the Premiere, the brand page, the logo). Shared surfaces stay in
//  ParentVeda's ink — the same rule Brand.colour already documents.
// =============================================================================

import 'package:flutter/material.dart';

import '../brand_models.dart';

/// Switches the whole Pee Safe demo on: the Showcase row in You, the demo
/// triggers, the seeded campaigns. Not for real users.
const bool kPeeSafeDemo = true;

const Brand kPeeSafe = Brand(
  id: 'pee_safe',
  name: 'Pee Safe',
  colour: Color(0xFFB3E053),
  logoAsset: 'assets/brand/pee_safe/logo.png',
  landingUrl: 'https://www.peesafe.com',
);

/// Pee Safe's page background and ink, for its own surfaces only.
const Color kPeeSafeWash = Color(0xFFF6FBE6);
const Color kPeeSafeInk = Color(0xFF2F302C);

/// The Pee Safe Premiere and the launch it hands over to (item 3). Ids live
/// here, not in brand_campaigns.dart, because screens may import this file
/// (the Showcase replays the Premiere by id) and must never import the seeds.
const String kPeeSafePremiereId = 'premiere_pee_safe_2026';
const String kPeeSafeLaunchId = 'launch_pee_safe_2026';

/// The launch film (item 10b): Pee Safe's own 25 s brand film, "Your Personal
/// Hygiene" (YouTube eDEeei2Oi9U, Sep 2026), 720p H.264, bundled so the demo
/// needs no network. One path for both surfaces — the Premiere and the brand
/// page — so they can never disagree. test/pee_safe_film_test.dart holds it to
/// a file on disk that pubspec.yaml declares.
const String kPeeSafeLaunchFilm = 'assets/brand/pee_safe/launch.mp4';

/// The Pee Safe reading shelf (item 5): its sponsoredEducation campaign and the
/// placement it presents. The reads live in pee_safe_reads.dart.
const String kPeeSafeEducationId = 'edu_pee_safe_reads';
const String kPeeSafeReadsPlacement = 'pee_safe_reads';

/// The postpartum recovery kit tool (item 6): its sponsoredTool campaign and
/// the placement it presents. The tool lives in pee_safe_recovery_kit_screen.dart.
const String kPeeSafeKitToolId = 'tool_pee_safe_recovery_kit';
const String kPeeSafeKitPlacement = 'pee_safe_recovery_kit';

/// Product placements (item 7). One campaign per placement, each on its own
/// placementKey, so no placement can appear on another's surface (resolve()
/// matches keys exactly). The keys name the host instance: a RecoItem id for
/// the featured pick and the travel kit, a RecoCollection id, a tool id.
const String kPeeSafeFeaturedId = 'reco_pee_safe_featured';
const String kPeeSafeFeaturedKey = 'pp_selfcare'; // RecoItem, pvRating 4.5, unchanged
const String kPeeSafeBagId = 'tool_pee_safe_hospital_bag';
const String kPeeSafeBagKey = 'hospital_bag';
const String kPeeSafeCollectionId = 'collection_pee_safe_afterbirth';
const String kPeeSafeCollectionKey = 'afterbirth'; // RecoCollection id
const String kPeeSafeTravelId = 'discovery_pee_safe_travel';
const String kPeeSafeTravelKey = 'tv_essentials'; // RecoItem, "The 4-month travel kit"

/// Sponsored notifications (item 8). Three campaigns, each with its own id and
/// its own audience, so each reaches only the parent it fits. What a tap opens
/// lives in pee_safe_notifications.dart, keyed on these ids.
const String kPeeSafeNotifBagId = 'notif_pee_safe_bag_w36';
const String kPeeSafeNotifPeriId = 'notif_pee_safe_peri_care';
const String kPeeSafeNotifTravelId = 'notif_pee_safe_travel';
const List<String> kPeeSafeNotificationIds = [
  kPeeSafeNotifBagId,
  kPeeSafeNotifPeriId,
  kPeeSafeNotifTravelId,
];
