# ParentVeda Watch — native video module

The Watch player streams **YouTube "unlisted"** videos (free hosting, great CDN)
while presenting a fully **ParentVeda-branded** experience. YouTube is an
implementation detail the parent should never feel.

## Where things live

```
lib/screens/post_pregnancy/
  pp_watch_data.dart            WatchVideo + WatchStore (adds youtubeId, resume, completion)
  watch_player_screen.dart      the screen; hosts PvVideoPlayer + fullscreen layout swap
  video/
    pv_video_config.dart        id resolution + engine flags (dev CC placeholders)
    pv_video_player.dart        the player: custom overlay, resume, milestones, fullscreen
    pv_video_repository.dart    backend seam (VideoLesson) + LocalWatchRepository
    pv_video_analytics.dart     event bus (started/paused/milestones/completed/abandoned…)
    pv_screen_security.dart     FLAG_SECURE / capture-detection abstraction (off by default)
```

## State management — a deliberate deviation

The generic brief asked for Riverpod. This app uses **`ChangeNotifier` singletons
everywhere** (`WatchStore`, `HealthStore`, …) and has no Riverpod anywhere.
Introducing it would mean a `ProviderScope` at `main.dart` (a shared root that is
being edited in parallel) plus two competing paradigms. So the module follows the
house pattern: the player owns local ephemeral state; durable state lives in
`WatchStore` behind the `PvVideoRepository` interface. Swapping in Riverpod later
is a contained change because the player only depends on the repository, not on
any specific store.

## Hiding YouTube — what we do

Set via `YoutubePlayerParams` in `pv_video_player.dart`:

| Lever | Value | Effect |
|---|---|---|
| `showControls: false` | `controls=0` | No YouTube control chrome — our overlay is the only UI |
| `showFullscreenButton: false` | `fs=0` | We own the fullscreen button |
| `showVideoAnnotations: false` | `iv_load_policy=3` | No annotation cards |
| `strictRelatedVideos: true` | `rel=0` | Related suggestions restricted to the same channel |
| `modestbranding` | `1` (forced) | Minimises the YouTube logo |
| `playsInline: true` | `playsinline=1` | Never kicks out to native fullscreen on iOS |

Navigation out of the app is blocked by the package's `NavigationDelegate`: taps
that would open youtube.com are prevented and (for related/info features) the
video is reloaded in place instead of leaving. Autoplay is disabled by **cueing**
(`cueVideoById`) rather than loading.

## Hiding YouTube — honest limits (cannot be removed via the embed API)

- A faint **YouTube logo** can flash briefly during initial load.
- On **pause**, the IFrame may momentarily expose YouTube affordances before our
  overlay repaints; our opaque overlay covers them, but the first frame is YT's.
- The **watermark / "Watch on YouTube"** channel link can appear in some regions;
  the embed API only *minimises* branding, it can't fully remove it.
- **DRM-grade protection is out of scope** — determined users can still capture.
- These are YouTube ToS constraints, not bugs. Escaping them entirely requires a
  paid host (Mux/Bunny/Vimeo) — deferred for V1.

## Backend contract (mirrored by `PvVideoRepository`)

`videoId` is returned **per request from an authenticated endpoint** — never
baked into the client — so access can be gated and ids rotated server-side.

```
GET /lesson/{id}
  -> { "lessonId": "sleep4mo", "title": "...", "videoId": "xxxxxxxx",
       "duration": 720, "completed": false, "lastPosition": 128 }

POST /lesson/{id}/progress   { "positionSeconds": 128, "watchedSeconds": 94 }
POST /lesson/{id}/complete
```

`LocalWatchRepository` implements this against `WatchStore` today. A
`SupabaseVideoRepository` drops in later with **zero player changes**.

## Lesson tracking & resume

- Progress is saved every ~5s while playing, on pause, and on dispose.
- `WatchStore.setLastPosition` keeps the 0..1 fraction (continue-watching) in sync.
- Reopening a lesson cues at `lastPosition`; a finished lesson restarts at 0.
- Milestones (25/50/75/complete) and drop-off are fired to `PvVideoAnalytics`.

## Analytics events

`started · paused · resumed · milestone25/50/75 · completed · abandoned · replay ·
error`, each carrying position, duration, cumulative watch-time, playback rate and
replay count. Default sink prints in debug; call `PvVideoAnalytics.setSink(...)`
at startup to forward to a real destination.

## Screenshot / screen-record protection

`PvScreenSecurity` is a clean on/off abstraction, **disabled by default**
(`kEnableScreenSecurity`). To enable Android `FLAG_SECURE`, wire the
`parentveda/screen_security` MethodChannel in `MainActivity.kt` (snippet in
`pv_screen_security.dart`). iOS can't block screenshots outright but can detect
screen recording (`UIScreen.capturedDidChangeNotification`) and blur/pause.

## Testing

`pvCanPlayNatively()` returns false under the widget-test binding, so the player
renders a static poster (no WebView platform view) and the existing smoke tests
pass unchanged. Dev placeholder ids are Blender open movies (CC-BY) in
`kDevYoutubeIds`; replace with real unlisted ids from the backend and set
`kUseDevVideos = false`.

## Offline

V1 has no downloads. The repository seam and `VideoLesson` model are shaped so a
`download`/cache layer can be added later without touching the player.
