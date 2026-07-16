// =============================================================================
//  Brand Studio — campaign analytics
// -----------------------------------------------------------------------------
//  Mirrors the proven PvVideoAnalytics sink pattern: the app emits FACTS, a
//  sink decides what to do with them. Swapping in Supabase later is one line
//  (BrandAnalytics.instance.setSink(...)) and touches no call site.
//
//  Campaign ROI, CTR and completion rate are DERIVED downstream from these
//  events. We do not compute metrics in the client.
// =============================================================================

import 'package:flutter/foundation.dart';

import 'brand_models.dart';

enum BrandEvent {
  /// The campaign was actually surfaced to a parent. This is the event that
  /// spends the frequency cap.
  impression,
  opened,
  dismissed,

  /// Watched/read to the end — the honest denominator for completion rate.
  completed,
  ctaTapped,
  videoStarted,
  videoMilestone,
  videoCompleted,
  hubOpened,
  resourceOpened,
  productOpened,
  wishlistSaved,
  compareOpened,
  purchaseClicked,
}

@immutable
class BrandAnalyticsRecord {
  const BrandAnalyticsRecord({
    required this.campaignId,
    required this.brandId,
    required this.slot,
    required this.event,
    this.valueSeconds,
    this.meta = const {},
  });

  final String campaignId;
  final String brandId;
  final BrandSlot slot;
  final BrandEvent event;

  /// Watch time / dwell, where the event has a duration.
  final int? valueSeconds;
  final Map<String, Object?> meta;

  @override
  String toString() => 'Brand[${slot.name}] ${event.name} '
      'campaign=$campaignId brand=$brandId'
      '${valueSeconds != null ? ' ${valueSeconds}s' : ''}'
      '${meta.isEmpty ? '' : ' $meta'}';
}

abstract class BrandAnalyticsSink {
  void record(BrandAnalyticsRecord record);
}

/// Default sink: prints in debug, silent in release. Keeps the whole system
/// inert until a real sink is attached.
class DebugBrandAnalyticsSink implements BrandAnalyticsSink {
  const DebugBrandAnalyticsSink();

  @override
  void record(BrandAnalyticsRecord record) {
    if (kDebugMode) debugPrint('$record');
  }
}

class BrandAnalytics {
  BrandAnalytics._();
  static final BrandAnalytics instance = BrandAnalytics._();

  BrandAnalyticsSink _sink = const DebugBrandAnalyticsSink();

  /// Swap in a Supabase/Segment sink at startup.
  void setSink(BrandAnalyticsSink sink) => _sink = sink;

  void fire(BrandAnalyticsRecord record) {
    try {
      _sink.record(record);
    } catch (_) {
      // Analytics must never break a parent's session.
    }
  }

  /// Convenience for the common case.
  void event(
    BrandCampaign c,
    BrandEvent event, {
    int? valueSeconds,
    Map<String, Object?> meta = const {},
  }) =>
      fire(BrandAnalyticsRecord(
        campaignId: c.id,
        brandId: c.brand.id,
        slot: c.slot,
        event: event,
        valueSeconds: valueSeconds,
        meta: meta,
      ));
}
