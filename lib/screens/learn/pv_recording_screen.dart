// =============================================================================
//  PvRecordingScreen — a class recording or a course lesson video (L3, 0128)
// -----------------------------------------------------------------------------
//  One player for both doors into a Mux video:
//    * Your bookings › Past › Watch      -> a recording id (a class she held a
//                                           seat in, or bought)
//    * a course lesson with a video      -> programme id + lesson id
//
//  The phone never holds a lasting link. It asks `recording-playback` for a
//  signed HLS address that works for two hours, plays it with the platform's
//  own player (video_player), and asks again the next time the screen opens.
//  The server decides every time, so a refund is honoured on her next tap.
//
//  Calm by design: no autoplay chrome beyond play / pause and a scrubber, the
//  title, and a plain sentence for every way it can fail.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../services/remote/supabase_repo.dart';
import '../../theme/pv_fonts.dart';
import 'pv_learn_chrome.dart';

const String kPvRecordingRouteName = 'learn/recording';

/// Ask the server for a signed playback address. Null data on any refusal;
/// [EdgeResult.status] tells "not available" (404) from "offline" apart.
Future<EdgeResult> pvFetchPlayback({
  String? recordingId,
  String? programmeId,
  String? lessonId,
}) async {
  // Signed out (or the backend not initialised): nothing to ask. 404 reads
  // as "not available to this account", which is the truth.
  if (!SupabaseRepo.isLoggedIn) return const EdgeResult(status: 404);
  return SupabaseRepo.invokeEdgeResult('recording-playback', {
    'recordingId': ?recordingId,
    'programmeId': ?programmeId,
    'lessonId': ?lessonId,
  });
}

void pvOpenRecording(
  BuildContext context, {
  required String title,
  String? recordingId,
  String? programmeId,
  String? lessonId,
  String? prefetchedUrl,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: kPvRecordingRouteName),
      builder: (_) => PvRecordingScreen(
        title: title,
        recordingId: recordingId,
        programmeId: programmeId,
        lessonId: lessonId,
        prefetchedUrl: prefetchedUrl,
      ),
    ),
  );
}

class PvRecordingScreen extends StatefulWidget {
  const PvRecordingScreen({
    super.key,
    required this.title,
    this.recordingId,
    this.programmeId,
    this.lessonId,
    this.prefetchedUrl,
  });

  final String title;
  final String? recordingId;
  final String? programmeId;
  final String? lessonId;

  /// A signed address fetched a moment ago (the lesson page asks before it
  /// shows the play button), so opening does not ask twice.
  final String? prefetchedUrl;

  @override
  State<PvRecordingScreen> createState() => _PvRecordingScreenState();
}

class _PvRecordingScreenState extends State<PvRecordingScreen> {
  VideoPlayerController? _c;
  String? _problem;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _problem = null);
    var url = widget.prefetchedUrl;
    if (url == null) {
      final res = await pvFetchPlayback(
        recordingId: widget.recordingId,
        programmeId: widget.programmeId,
        lessonId: widget.lessonId,
      );
      if (!mounted) return;
      if (res.offline) {
        setState(
          () => _problem =
              'You appear to be offline. Recordings play over the internet; '
              'try again when you are connected.',
        );
        return;
      }
      url = res.data?['url']?.toString();
      if (!res.ok || url == null) {
        setState(
          () => _problem = res.status == 404
              ? 'This recording is not available to this account yet. If the '
                    'session ended recently it is still being prepared, which '
                    'usually takes under an hour.'
              : 'Something went wrong on our side. Please try again in a moment.',
        );
        return;
      }
    }
    final c = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      c.addListener(_tick);
      setState(() => _c = c);
      await c.play();
    } catch (e) {
      await c.dispose();
      if (!mounted) return;
      setState(
        () => _problem =
            'The video could not start. Check your connection and try again.',
      );
    }
  }

  void _tick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _c?.removeListener(_tick);
    _c?.dispose();
    super.dispose();
  }

  String _clock(Duration d) {
    final h = d.inHours;
    final m = (d.inMinutes % 60).toString().padLeft(h > 0 ? 2 : 1, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final c = _c;
    return Scaffold(
      backgroundColor: p.ground,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          PvLearnTopBar(title: widget.title, eyebrow: 'Recording'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: c != null && c.value.isInitialized
                    ? c.value.aspectRatio
                    : 16 / 9,
                child: Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: c != null && c.value.isInitialized
                      ? GestureDetector(
                          onTap: () => c.value.isPlaying ? c.pause() : c.play(),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(c),
                              if (!c.value.isPlaying)
                                const Icon(
                                  Icons.play_circle_outline,
                                  size: 64,
                                  color: Colors.white,
                                ),
                            ],
                          ),
                        )
                      : _problem == null
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Icon(
                          Icons.videocam_off_outlined,
                          size: 40,
                          color: Colors.white54,
                        ),
                ),
              ),
            ),
          ),
          if (c != null && c.value.isInitialized)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    key: const ValueKey('pv_recording_play'),
                    tooltip: c.value.isPlaying ? 'Pause' : 'Play',
                    onPressed: () => c.value.isPlaying ? c.pause() : c.play(),
                    icon: Icon(
                      c.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    color: p.ink1,
                  ),
                  Expanded(
                    child: VideoProgressIndicator(
                      c,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_clock(c.value.position)} / ${_clock(c.value.duration)}',
                    style: pvManrope(fontSize: 12.5, color: p.ink2),
                  ),
                ],
              ),
            ),
          if (_problem != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _problem!,
                    style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    key: const ValueKey('pv_recording_retry'),
                    onPressed: _load,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
            child: Text(
              'Recordings are yours to keep for life, unless the purchase is '
              'refunded. The link this player uses works for two hours, so it '
              'cannot be passed on.',
              style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2),
            ),
          ),
        ],
      ),
    );
  }
}
