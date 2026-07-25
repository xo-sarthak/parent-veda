// =============================================================================
//  MemoryAnalytics — the events the Memories feature emits
// -----------------------------------------------------------------------------
//  The funnel: started -> template selected -> photo added -> preview viewed
//  -> saved -> shared. Kept in one place so no screen invents its own event
//  names, and behind a SINK so the events can be sent anywhere without touching
//  a single call site (same shape as BrandAnalytics and ProfileAnalytics).
//
//  WHAT THIS DELIBERATELY DOES NOT CARRY: no baby name, no due date, no message
//  text, no photo, no user id. Only a milestone type, a template id and a fixed
//  destination label - all closed vocabularies. You learn which templates win
//  without ever touching a family's private content, which is the only way an
//  analytics table belongs anywhere near a keepsake feature.
//
//  Wiring lives in main.dart:
//      MemoryAnalytics.instance.setSink(const SupabaseMemorySink());
// =============================================================================

import 'package:flutter/foundation.dart';

/// The funnel steps. Closed set — the sink turns these into row values.
enum MemoryEvent {
  started,
  templateSelected,
  photoAdded,
  previewViewed,
  saved,
  shared,
}

@immutable
class MemoryAnalyticsRecord {
  const MemoryAnalyticsRecord({
    required this.event,
    this.type,
    this.templateId,
    this.destination,
  });

  final MemoryEvent event;

  /// The milestone: `expecting` | `welcomeBaby`. Enum label, never free text.
  final String? type;

  /// A template id from kMemoryTemplates (e.g. `exp_sage_floral`). Fixed set.
  final String? templateId;

  /// Where it was shared. A fixed label (`share_sheet`) — the OS share sheet
  /// does not reliably tell us which app was chosen, so we do not pretend to.
  final String? destination;

  @override
  String toString() => 'MemoryAnalyticsRecord(${event.name}, type: $type, '
      'template: $templateId, destination: $destination)';
}

abstract class MemoryAnalyticsSink {
  void record(MemoryAnalyticsRecord record);
}

/// The default until main.dart swaps in the real one. Debug builds only, so a
/// release build with no sink configured is silent rather than wasteful.
class DebugMemoryAnalyticsSink implements MemoryAnalyticsSink {
  const DebugMemoryAnalyticsSink();

  @override
  void record(MemoryAnalyticsRecord record) {
    if (kDebugMode) debugPrint('[memory] $record');
  }
}

class MemoryAnalytics {
  MemoryAnalytics._();
  static final MemoryAnalytics instance = MemoryAnalytics._();

  MemoryAnalyticsSink _sink = const DebugMemoryAnalyticsSink();

  /// Swap in a real sink at startup.
  void setSink(MemoryAnalyticsSink sink) => _sink = sink;

  /// Fire-and-forget, and it can NEVER throw: analytics must not be able to
  /// break a parent making a keepsake.
  void fire(MemoryAnalyticsRecord record) {
    try {
      _sink.record(record);
    } catch (_) {
      // Swallowed on purpose.
    }
  }

  // ---- the funnel, as called from the screens -------------------------------

  static void started(String type) => instance
      .fire(MemoryAnalyticsRecord(event: MemoryEvent.started, type: type));

  static void templateSelected(String templateId) => instance.fire(
      MemoryAnalyticsRecord(
          event: MemoryEvent.templateSelected, templateId: templateId));

  static void photoAdded(String type) => instance
      .fire(MemoryAnalyticsRecord(event: MemoryEvent.photoAdded, type: type));

  static void previewViewed(String templateId) => instance.fire(
      MemoryAnalyticsRecord(
          event: MemoryEvent.previewViewed, templateId: templateId));

  static void saved(String templateId) => instance.fire(
      MemoryAnalyticsRecord(event: MemoryEvent.saved, templateId: templateId));

  static void shared(String templateId, String destination) =>
      instance.fire(MemoryAnalyticsRecord(
          event: MemoryEvent.shared,
          templateId: templateId,
          destination: destination));
}
