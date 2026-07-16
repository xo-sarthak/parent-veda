// =============================================================================
//  ParentVeda Brand Studio — domain model
// -----------------------------------------------------------------------------
//  This is a brand PARTNERSHIP platform, not an ad network. See
//  docs/BRAND-STUDIO.md for the architecture and the trust invariants.
//
//  The one rule: brand content reaches the UI only through BrandStudio.resolve().
//  Nothing here is constructed by a screen directly.
// =============================================================================

import 'package:flutter/material.dart';

/// The four shapes every brand product collapses into. The archetype decides
/// which contract the resolver enforces, so 15 sellable products need only 4
/// implementations.
enum BrandArchetype {
  /// Full-screen, rare, once per campaign. The only interruption we permit.
  takeover,

  /// A place parents choose to visit. Never pushed at anyone.
  destination,

  /// ParentVeda's content + a brand's funding + a visible attribution.
  /// The brand pays for the thing to exist, never for what it says.
  presentedBy,

  /// Entry into a curated/ranked list, gated by a quality floor and a rank
  /// floor. Never a score bonus.
  rankedInventory,
}

/// Every placement in the app. A closed enum on purpose: adding a placement is
/// a deliberate, reviewable act, not something that happens by dropping a
/// widget into a build method.
///
/// Phase 1 ships only [premiere] and [launchHub]. The rest are declared so the
/// archetype mapping is reviewable as a whole, but no campaign may target them
/// until their surface is built (see [BrandSlot.isLive]).
enum BrandSlot {
  // ---- Phase 1 · live -------------------------------------------------------
  premiere, // Product 1
  launchHub, // Product 2

  // ---- Phase 2 · presented-by (designed, not built) -------------------------
  sponsoredEducation, // Product 3
  sponsoredJourney, // Product 7
  sponsoredTool, // Product 8
  sponsoredMilestone, // Product 13
  liveSession, // Product 10
  communityCampaign, // Product 11
  compareGuide, // Product 6
  productGuideExpert, // Product 4 — expert videos
  productGuideResearch, // Product 4 — research corner

  // ---- Phase 3 · ranked inventory (designed, not built) ---------------------
  recoFeatured, // Product 5
  sponsoredCollection, // Product 9
  nativeDiscovery, // Product 14
  sponsoredNotification, // Product 15
  productSampling, // Product 12
}

extension BrandSlotX on BrandSlot {
  BrandArchetype get archetype => switch (this) {
        BrandSlot.premiere => BrandArchetype.takeover,
        BrandSlot.launchHub => BrandArchetype.destination,
        BrandSlot.sponsoredEducation ||
        BrandSlot.sponsoredJourney ||
        BrandSlot.sponsoredTool ||
        BrandSlot.sponsoredMilestone ||
        BrandSlot.liveSession ||
        BrandSlot.communityCampaign ||
        BrandSlot.compareGuide ||
        BrandSlot.productGuideExpert ||
        BrandSlot.productGuideResearch =>
          BrandArchetype.presentedBy,
        BrandSlot.recoFeatured ||
        BrandSlot.sponsoredCollection ||
        BrandSlot.nativeDiscovery ||
        BrandSlot.sponsoredNotification ||
        BrandSlot.productSampling =>
          BrandArchetype.rankedInventory,
      };

  /// Only slots whose surface actually exists may carry a campaign. Keeps a
  /// sold-but-unbuilt placement from silently resolving to nothing.
  bool get isLive => switch (this) {
        // Phase 1
        BrandSlot.premiere || BrandSlot.launchHub => true,
        // Phase 2 — presented-by, wired to real host surfaces
        BrandSlot.sponsoredEducation || // parenting Learn collections
        BrandSlot.sponsoredTool || // both tools hubs
        BrandSlot.sponsoredMilestone || // the development journey
        BrandSlot.communityCampaign || // the community feed
        BrandSlot.liveSession || // Prepare: cohorts & masterclasses
        // Guided journeys now exist as a real feature (pp_journeys_data.dart),
        // built to stand on their own with no sponsor at all — so there is
        // finally something real to attach a sponsorship to.
        BrandSlot.sponsoredJourney =>
          true,
        // FLAGGED, NOT PARKED. These three are research surfaces, and the app
        // promised parents "never on your research pages". Built at the
        // product owner's direction, with the shipped copy narrowed to match
        // reality rather than left as a quiet lie, and a NeedsAttentionFlag on
        // each surface in debug builds. See needs_attention.dart and §11.
        BrandSlot.compareGuide ||
        BrandSlot.productGuideExpert ||
        BrandSlot.productGuideResearch =>
          true,
        // Phase 3 — ranked inventory
        BrandSlot.recoFeatured ||
        BrandSlot.sponsoredCollection ||
        BrandSlot.nativeDiscovery ||
        BrandSlot.productSampling =>
          true,
        BrandSlot.sponsoredNotification => false, // needs the notification seam
      };
}

extension BrandArchetypeX on BrandArchetype {
  /// Pushed content is delivered to a parent whether they asked or not, so it
  /// is frequency-capped. Pulled content — a destination they opened, an
  /// attribution on a tool they chose to use — is not an interruption and is
  /// not capped. This is the distinction the whole "relevance, not volume"
  /// guarantee rests on.
  bool get isPushed => this == BrandArchetype.takeover || this == BrandArchetype.rankedInventory;
}

/// Which app the parent is in. A campaign is never shown across the divide by
/// accident — the pregnancy and parenting apps are deliberately isolated.
enum BrandStage { pregnancy, parenting }

// =============================================================================
//  Brand — the missing spine
// -----------------------------------------------------------------------------
//  Today "a brand" is five unrelated strings: PromoSlide.brand, PpProduct.brand,
//  PpProduct.retailer, PpDeal.retailer, _Cat.brand — with no shared id space.
//  Campaign analytics, certification and commerce all need one. This is it.
// =============================================================================
@immutable
class Brand {
  const Brand({
    required this.id,
    required this.name,
    required this.colour,
    this.logoAsset,
    this.landingUrl,
    this.certified = false,
  });

  final String id;
  final String name;

  /// The brand's own colour, used for creative surfaces only. It never leaks
  /// into ParentVeda's own chrome.
  final Color colour;
  final String? logoAsset;
  final String? landingUrl;

  /// ParentVeda Certified. Deliberately lives on [Brand], NOT on
  /// [BrandCampaign], so that buying a campaign can never confer it.
  /// Certification is an editorial judgement with an independent evaluation and
  /// a published methodology. It is not for sale. See docs/BRAND-STUDIO.md §13.
  final bool certified;
}

// =============================================================================
//  Scheduling
// =============================================================================
@immutable
class BrandSchedule {
  const BrandSchedule({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  /// Half-open: live on the start day, dead the moment `end` arrives.
  bool isLiveAt(DateTime now) => !now.isBefore(start) && now.isBefore(end);
}

// =============================================================================
//  Audience — narrows, never widens
// =============================================================================

/// A snapshot of the parent, flattened for targeting. Captured once per
/// resolve; see `brand_context.dart`.
@immutable
class BrandContext {
  const BrandContext({
    required this.stage,
    required this.now,
    this.pregnancyWeek,
    this.childAgeMonths,
    this.signals = const {},
  });

  final BrandStage stage;
  final DateTime now;

  /// Pregnancy week, passed in explicitly — PregnancyController is not a
  /// singleton, it is built in main.dart and handed down.
  final int? pregnancyWeek;
  final int? childAgeMonths;

  /// Flattened Personalization Engine state: feeding/condition/priority `.name`s.
  final Set<String> signals;
}

/// Targeting rules. Every field is a *narrowing* constraint — an unset field
/// means "no constraint", never "match more people".
///
/// This is the load-bearing guarantee of the personalization integration:
/// targeting can make a campaign more relevant, or make it disappear. It can
/// never make there be more advertising. Pinned by an invariant test.
@immutable
class BrandAudience {
  const BrandAudience({
    this.stage,
    this.anySignal = const {},
    this.childAgeMonthsMin,
    this.childAgeMonthsMax,
    this.pregnancyWeekMin,
    this.pregnancyWeekMax,
  });

  /// Reaches every parent in the app. The default for a launch with no
  /// meaningful segment.
  static const everyone = BrandAudience();

  final BrandStage? stage;

  /// Matches when the parent has ANY of these signals. Empty = no constraint.
  final Set<String> anySignal;

  final int? childAgeMonthsMin;
  final int? childAgeMonthsMax;
  final int? pregnancyWeekMin;
  final int? pregnancyWeekMax;

  bool matches(BrandContext c) {
    if (stage != null && stage != c.stage) return false;

    if (anySignal.isNotEmpty) {
      if (!anySignal.any(c.signals.contains)) return false;
    }

    if (childAgeMonthsMin != null || childAgeMonthsMax != null) {
      final m = c.childAgeMonths;
      if (m == null) return false;
      if (childAgeMonthsMin != null && m < childAgeMonthsMin!) return false;
      if (childAgeMonthsMax != null && m > childAgeMonthsMax!) return false;
    }

    if (pregnancyWeekMin != null || pregnancyWeekMax != null) {
      final w = c.pregnancyWeek;
      if (w == null) return false;
      if (pregnancyWeekMin != null && w < pregnancyWeekMin!) return false;
      if (pregnancyWeekMax != null && w > pregnancyWeekMax!) return false;
    }

    return true;
  }

  /// True when this audience constrains nothing — used by the "personalization
  /// never increases volume" invariant test.
  bool get isUnconstrained =>
      stage == null &&
      anySignal.isEmpty &&
      childAgeMonthsMin == null &&
      childAgeMonthsMax == null &&
      pregnancyWeekMin == null &&
      pregnancyWeekMax == null;
}

// =============================================================================
//  Creative
// =============================================================================

/// One highlight of a launching product. Editorial in tone — a claim a parent
/// can check, not a slogan.
@immutable
class BrandHighlight {
  const BrandHighlight({required this.title, required this.body, required this.icon});
  final String title;
  final String body;
  final IconData icon;
}

/// A ParentVeda-authored educational resource offered alongside a launch. The
/// brand funds the placement; it does not write these.
@immutable
class BrandResource {
  const BrandResource({required this.label, required this.blurb, this.readId});
  final String label;
  final String blurb;

  /// Optional link into real ParentVeda content (a ReadItem / guide id).
  final String? readId;
}

@immutable
class BrandCreative {
  const BrandCreative({
    required this.eyebrow,
    required this.headline,
    required this.story,
    required this.cta,
    this.subline = '',
    this.videoRef,
    this.imageAsset,
    this.highlights = const [],
    this.resources = const [],
    this.expertName = '',
    this.expertRole = '',
    this.expertHook = '',
  });

  final String eyebrow;
  final String headline;
  final String subline;

  /// The launch story — why this exists, in prose, not bullet points.
  final String story;
  final String cta;

  /// Video id/url for the 10–20s launch film. Null renders the animated
  /// fallback rather than a broken player.
  final String? videoRef;
  final String? imageAsset;

  final List<BrandHighlight> highlights;
  final List<BrandResource> resources;

  /// The expert introduction. The expert speaks for ParentVeda, not the brand.
  final String expertName;
  final String expertRole;
  final String expertHook;
}

// =============================================================================
//  Campaign — the sellable unit
// =============================================================================
@immutable
class BrandCampaign {
  BrandCampaign({
    required this.id,
    required this.brand,
    required this.slot,
    required this.creative,
    required this.schedule,
    this.audience = BrandAudience.everyone,
    this.maxImpressions = 1,
    this.active = true,
    this.linkedCampaignId,
    this.placementKey,
  })  :
        // Disclosure is not optional and is not the brand's to word. Built here
        // so no campaign can exist without one.
        disclosure = 'Presented by ${brand.name}',
        assert(maxImpressions >= 1, 'a campaign that can never show is a bug, not a config');

  final String id;
  final Brand brand;
  final BrandSlot slot;
  final BrandCreative creative;
  final BrandSchedule schedule;
  final BrandAudience audience;

  /// How many times this campaign may be surfaced, ever, to one parent.
  /// Premiere is 1 — "once per campaign", and it persists across launches.
  ///
  /// Ignored for [BrandArchetype.destination]: a place a parent chooses to
  /// visit does not spend an impression on them.
  final int maxImpressions;

  final bool active;

  /// For a [BrandSlot.premiere]: the Launch Hub campaign this takeover
  /// announces. The Premiere is the moment; the Hub launch is its permanent
  /// home, so "Explore the launch" always has somewhere to land.
  final String? linkedCampaignId;

  /// WHICH instance of a slot this campaign presents — the sleep tracker rather
  /// than tools in general, one collection rather than the Learn tab.
  ///
  /// A slot alone is too coarse for presented-by and ranked inventory: without
  /// this, buying "tool sponsorship" would brand every tool in the app. Matched
  /// exactly by the resolver, so a campaign can never leak onto a surface it
  /// did not name.
  final String? placementKey;

  /// Centralised, non-empty by construction. A brand may not supply its own.
  final String disclosure;

  /// The independence line shown on presented-by surfaces.
  String get independenceNote => '${brand.name} funded this. They did not write it.';
}
