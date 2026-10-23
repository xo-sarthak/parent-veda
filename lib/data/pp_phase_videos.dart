// =============================================================================
//  The phase videos (2026-10-23, Wave 8)
// -----------------------------------------------------------------------------
//  One video per phase of the twenty, shown on the phase page with the phase
//  painting as its poster. "Films" are called videos now (the user).
//
//  ⚠️ PUTTING A VIDEO LIVE IS A DATA CHANGE: add one line here. Until a phase
//  has a line, the phase page says "Video for this phase coming soon" over the
//  painting, never a blank box.
//
//  Hosting is not decided yet (the user, 2026-10-23: "maybe Bunny Stream").
//  The url is any address the player can stream: an mp4, or an HLS .m3u8 as
//  Bunny Stream serves. Nothing else in the app knows where it lives.
// =============================================================================

/// One phase's video.
class PpPhaseVideo {
  const PpPhaseVideo({required this.url, required this.seconds});

  /// A streamable address (mp4 or HLS).
  final String url;

  /// Its length, shown on the poster ("3:40").
  final int seconds;
}

/// Phase number (1 to 20) -> its video. Empty until the videos are hosted.
const Map<int, PpPhaseVideo> kPhaseVideos = {
  // 1: PpPhaseVideo(url: 'https://…/phase_01.m3u8', seconds: 220),
};

/// "3:40" for a length in seconds.
String ppVideoLength(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
