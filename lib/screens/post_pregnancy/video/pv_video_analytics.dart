// =============================================================================
//  PvVideoAnalytics - lesson + engagement telemetry for the Watch player
// -----------------------------------------------------------------------------
//  A tiny, dependency-free event bus. The player calls fire(...) at meaningful
//  moments; a pluggable sink decides what to do with them (debug console now,
//  Supabase / a product-analytics SDK later). Kept deliberate: no autoplay
//  vanity metrics - only the signals that tell us whether a lesson landed.
// =============================================================================

import 'package:flutter/foundation.dart';

/// The moments worth recording for a learning video.
enum PvVideoEvent {
  started, // first play of a fresh open
  paused,
  resumed,
  milestone25,
  milestone50,
  milestone75,
  completed,
  abandoned, // left before completing (drop-off)
  replay,
  error,
}

/// One telemetry record. [positionSeconds] is where it happened (drop-off
/// timestamp for `abandoned`); [watchedSeconds] is cumulative time actually
/// spent playing this session.
class PvVideoAnalyticsRecord {
  const PvVideoAnalyticsRecord({
    required this.videoId,
    required this.event,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.watchedSeconds,
    required this.playbackRate,
    required this.replayCount,
  });

  final String videoId;
  final PvVideoEvent event;
  final int positionSeconds;
  final int durationSeconds;
  final int watchedSeconds;
  final double playbackRate;
  final int replayCount;

  double get completionFraction =>
      durationSeconds <= 0 ? 0 : (positionSeconds / durationSeconds).clamp(0.0, 1.0);

  @override
  String toString() => 'PvVideo[$videoId] ${event.name} '
      '@${positionSeconds}s/${durationSeconds}s '
      '(watched ${watchedSeconds}s, x$playbackRate, replays $replayCount)';
}

/// Where analytics records go. Swap in a real sink (backend/SDK) via
/// [PvVideoAnalytics.setSink] without touching the player.
abstract class PvVideoAnalyticsSink {
  void record(PvVideoAnalyticsRecord record);
}

/// Default sink: prints in debug, silent in release. Safe to ship.
class DebugPvVideoAnalyticsSink implements PvVideoAnalyticsSink {
  const DebugPvVideoAnalyticsSink();
  @override
  void record(PvVideoAnalyticsRecord record) {
    if (kDebugMode) debugPrint('📊 $record');
  }
}

/// Singleton facade the player talks to.
class PvVideoAnalytics {
  PvVideoAnalytics._();
  static final PvVideoAnalytics instance = PvVideoAnalytics._();

  PvVideoAnalyticsSink _sink = const DebugPvVideoAnalyticsSink();

  /// Point analytics at a real destination (e.g. Supabase) at app start.
  // ignore: use_setters_to_change_properties
  void setSink(PvVideoAnalyticsSink sink) => _sink = sink;

  void fire(PvVideoAnalyticsRecord record) => _sink.record(record);
}
