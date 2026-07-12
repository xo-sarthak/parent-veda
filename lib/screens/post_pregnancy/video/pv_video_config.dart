// =============================================================================
//  PvVideoConfig - the single place video sources and engine flags are resolved
// -----------------------------------------------------------------------------
//  ParentVeda Watch plays videos we host ourselves (Supabase Storage now; a real
//  video host like Bunny/Cloudflare later) NATIVELY via video_player - no
//  third-party player, no branding to hide, plays MP4 and HLS. The app is built
//  so the source is an implementation detail:
//    • The catalog (pp_watch_data.dart) never hardcodes a URL. In production
//      every WatchVideo.videoUrl is filled from the authenticated backend
//      (a signed URL) after access is verified.
//    • For DEVELOPMENT, a placeholder URL below stands in so the player is real
//      and testable. Swap in real per-video URLs from the backend and flip
//      kUseDevVideos - a data change, not a code change.
// =============================================================================

import 'package:flutter/widgets.dart';

import '../pp_watch_data.dart';

/// Master switch for the native video engine. When false (or in tests / on
/// platforms without a video plugin) every surface shows the calm poster.
const bool kEnableNativeVideo = true;

/// Use the dev placeholder URL below. Turn OFF once the backend supplies real
/// WatchVideo.videoUrl values so nothing dev-only ships.
const bool kUseDevVideos = true;

/// Invisible screenshot / screen-record protection (Android FLAG_SECURE, iOS
/// capture detection). Off by default: needs the native hook (documented in
/// pv_screen_security.dart) and is invisible in the prototype.
const bool kEnableScreenSecurity = false;

/// DEV ONLY. A real MP4 on our own Supabase Storage (720p, +faststart). Every
/// mapped lesson points at it so the player always has something to play; a few
/// ids are intentionally left unmapped to exercise the poster fallback.
const String _kDevSampleUrl =
    'https://csrabzuhxbschkeyohha.supabase.co/storage/v1/object/public/videos/20260401_094233_720p.mp4';

const Map<String, String> kDevVideoUrls = {
  'sleep4mo': _kDevSampleUrl,
  'leap4brain': _kDevSampleUrl,
  'solids101': _kDevSampleUrl,
  'tummytime': _kDevSampleUrl,
  'q_noise': _kDevSampleUrl,
  'q_tummy': _kDevSampleUrl,
  'pod_sleep': _kDevSampleUrl,
};

/// The URL that should actually play for [video], or null if none is available
/// yet (then the caller shows the placeholder poster). Real URLs win; dev
/// placeholders only fill in when [kUseDevVideos] is on.
String? pvResolveVideoUrl(WatchVideo video) {
  final real = video.videoUrl;
  if (real != null && real.isNotEmpty) return real;
  if (kUseDevVideos) return kDevVideoUrls[video.id];
  return null;
}

/// Whether a real native player should mount for [video] right now. False under
/// the widget-test harness (no video platform view) or when disabled, so screens
/// fall back to the poster without special-casing at each call site.
bool pvCanPlayNatively(WatchVideo video) {
  if (!kEnableNativeVideo) return false;
  if (pvIsUnderTest) return false;
  return pvResolveVideoUrl(video) != null;
}

/// True inside `flutter test`. The test binding's runtime type always contains
/// "Test", so we can dodge the video platform view without any per-test wiring.
bool get pvIsUnderTest {
  final binding = WidgetsBinding.instance;
  return binding.runtimeType.toString().contains('Test');
}
