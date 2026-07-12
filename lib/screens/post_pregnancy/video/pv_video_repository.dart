// =============================================================================
//  PvVideoRepository - the seam between the player and where lessons live
// -----------------------------------------------------------------------------
//  The player never talks to a data source directly; it talks to this interface.
//  Today the only implementation is LocalWatchRepository (backed by the in-memory
//  WatchStore). Tomorrow a SupabaseVideoRepository / HttpVideoRepository slots in
//  with zero player changes - that is the whole point of the abstraction.
//
//  Backend contract this mirrors (see docs/watch-video-module.md):
//    GET  /lesson/{id}          -> VideoLesson (incl. resolved videoUrl + lastPosition)
//    POST /lesson/{id}/progress { positionSeconds, watchedSeconds }
//    POST /lesson/{id}/complete
//  videoUrl is returned per-request from an authenticated endpoint (a signed,
//  possibly short-lived URL) - never baked into the client - so access can be
//  gated and links rotated server-side.
// =============================================================================

import '../pp_watch_data.dart';
import 'pv_video_config.dart';

/// The backend's view of one lesson. Field names match the JSON contract.
class VideoLesson {
  const VideoLesson({
    required this.lessonId,
    required this.title,
    required this.videoUrl,
    required this.duration,
    required this.completed,
    required this.lastPosition,
  });

  final String lessonId;
  final String title;
  final String? videoUrl; // the MP4/HLS URL to play; null if unavailable
  final int duration; // seconds
  final bool completed;
  final int lastPosition; // seconds to resume from

  factory VideoLesson.fromJson(Map<String, dynamic> json) => VideoLesson(
        lessonId: '${json['lessonId'] ?? json['id']}',
        title: json['title'] as String? ?? '',
        videoUrl: json['videoUrl'] as String?,
        duration: (json['duration'] as num?)?.toInt() ?? 0,
        completed: json['completed'] as bool? ?? false,
        lastPosition: (json['lastPosition'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'lessonId': lessonId,
        'title': title,
        'videoUrl': videoUrl,
        'duration': duration,
        'completed': completed,
        'lastPosition': lastPosition,
      };
}

/// What the player depends on. Small on purpose.
abstract class PvVideoRepository {
  Future<VideoLesson> lesson(String id);
  Future<void> saveProgress(String id, {required int positionSeconds, required int watchedSeconds});
  Future<void> markCompleted(String id);
}

/// Local-first implementation: resolves the lesson from the seed catalog + the
/// dev id map, and persists progress into WatchStore (the same store that powers
/// continue-watching everywhere else). This is the "backend" until Supabase.
class LocalWatchRepository implements PvVideoRepository {
  const LocalWatchRepository();

  @override
  Future<VideoLesson> lesson(String id) async {
    final v = watchVideoById(id);
    final store = WatchStore.instance;
    return VideoLesson(
      lessonId: v.id,
      title: v.title,
      videoUrl: pvResolveVideoUrl(v),
      duration: v.seconds,
      completed: store.isCompleted(v.id),
      lastPosition: store.lastPositionOf(v.id),
    );
  }

  @override
  Future<void> saveProgress(String id, {required int positionSeconds, required int watchedSeconds}) async {
    WatchStore.instance.setLastPosition(id, positionSeconds, watchVideoById(id).seconds);
  }

  @override
  Future<void> markCompleted(String id) async {
    WatchStore.instance.markCompleted(id);
  }
}
