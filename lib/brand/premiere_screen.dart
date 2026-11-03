// =============================================================================
//  ParentVeda Premiere — Brand Product 1 (archetype: takeover)
// -----------------------------------------------------------------------------
//  The only interruption the Brand Studio permits, and the rules that make it
//  tolerable are structural, not editorial:
//
//    · once per CAMPAIGN, persisted (not once per launch, which is what the old
//      in-memory promo guard actually enforced)
//    · 3–6 times a year, because BrandSlot.premiere has one live campaign
//    · skippable from the first frame — the close affordance is never delayed
//    · a launch STORY, never an offer
//
//  Replaces widgets/launch_promo.dart (a discount carousel). See
//  docs/BRAND-STUDIO.md §3.
//
//  REDESIGN 2026-11-02 (docs/PEE-SAFE-DEMO.md item 3, "Mobbin: Premiere"):
//  full-bleed film with no card; Skip pill top right, Mute pill top left (only
//  when there is sound to mute); the caption sits over a bottom scrim; a
//  "Presented by <brand>" chip is in frame from the first frame; the film ends
//  on an end card — logo, one line, a "See what's new" pill and a quiet
//  "Not now". The previous title-card + white story panel is kept, commented
//  out, at the bottom of this file for revert.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'brand_analytics.dart';
import 'brand_context.dart';
// Only the old UI used SponsorDisclosure; the new chip is drawn below. Kept
// for revert:
// import 'brand_disclosure.dart';
import 'brand_mark.dart';
import 'brand_models.dart';
import 'brand_store.dart';
import 'brand_studio.dart';
import 'launch_hub_screen.dart';
import 'outbound.dart';
import 'pee_safe/pee_safe_brand.dart' show kPeeSafeDemo, kPeeSafePremiereId;
import '../theme/pv_fonts.dart';
import '../localization/app_language.dart';

/// TESTING: show the Premiere on EVERY app open, ignoring the once-per-campaign
/// cap.
///
/// ⚠️ MUST BE `false` BEFORE LAUNCH. Tracked in docs/STILL-OPEN.md §1.4.
///
/// The cap is not a technical limit, it is the thing that makes a full-screen
/// takeover acceptable at all: `maxImpressions: 1`, persisted, surviving a
/// reinstall. Seen once it is a launch story; seen on every open it is an
/// advert a parent cannot escape — and this app opens at 2am, by someone who
/// is worried. That is the wrong moment to be sold to for the fourth time.
///
/// It is on now because the flagship is otherwise almost impossible to look
/// at: one impression per campaign, three to six campaigns a year, and no way
/// to see it again short of wiping app storage.
///
/// Tools -> Brand Studio -> "Show me" does the same thing WITHOUT this flag,
/// and is the better habit — it does not change what a real parent gets.
bool kPremiereAlwaysShow = true;

/// Resolve and show the Premiere, if one is live for this parent.
///
/// Null-safe by design: no campaign is the normal case and the caller does
/// nothing. Never throws into app startup.
Future<void> showPremiereIfAny(
  BuildContext context, {
  required BrandStage stage,
  int? pregnancyWeek,
}) async {
  try {
    final ctx = captureBrandContext(stage: stage, pregnancyWeek: pregnancyWeek);
    final campaign = BrandStudio.instance.resolve(
      BrandSlot.premiere,
      ctx,
      // Resolve normally, but let the testing flag look past a spent cap.
      ignoreImpressionCap: kPremiereAlwaysShow,
    );
    if (campaign == null) return;
    if (!context.mounted) return;

    // Spend the cap at the moment it is actually surfaced, not at resolve time.
    // Still recorded while testing: the analytics and the store should reflect
    // what was actually shown, not what the cap would have allowed.
    BrandStudioStore.instance.recordImpression(campaign.id);
    BrandAnalytics.instance.event(campaign, BrandEvent.impression);

    await _pushPremiere(context, campaign, stage);
  } catch (_) {
    // A brand surface must never be the reason the app fails to open.
  }
}

/// Pee Safe demo (item 11, the user 2026-11-02: "when the app opens up, they
/// have a premiere of ad going on", as Blinkit, Zepto and Swiggy do): the
/// Pee Safe launch film as the app opens, ONCE per phone, on every stage.
///
/// Why not [showPremiereIfAny]: that path honours [kPremiereAlwaysShow], which
/// is true and looks past the cap — the reason the Premiere "opened again and
/// again" and was switched off at app open on 2026-09-17. This one reads the
/// cap itself, so neither that flag nor demo mode (which relaxes caps, and the
/// Showcase leaves on) can make it repeat. Trade-off: a third entry point,
/// bought so the old flag stays exactly as it was for the other campaigns.
///
/// The store is loaded first: an unloaded store reads 0 impressions, which
/// would replay the film on every cold start. "Reset demo" re-arms it via
/// [BrandStudioStore.forgetImpressions].
Future<void> showPeeSafePremiereAtOpen(
  BuildContext context, {
  required BrandStage stage,
  int? pregnancyWeek,
}) async {
  if (!kPeeSafeDemo) return;
  try {
    final studio = BrandStudio.instance;
    BrandCampaign? campaign;
    for (final c in studio.campaigns) {
      if (c.id == kPeeSafePremiereId && c.slot == BrandSlot.premiere) campaign = c;
    }
    if (campaign == null) return;
    final store = BrandStudioStore.instance;
    await store.init();
    if (store.impressions(campaign.id) >= campaign.maxImpressions) return;
    // Kill switch, `active` and the schedule still decide; only the cap is ours.
    final ctx = captureBrandContext(stage: stage, pregnancyWeek: pregnancyWeek);
    if (!studio.isEligible(campaign, ctx, ignoreCaps: true)) return;
    if (!context.mounted) return;
    store.recordImpression(campaign.id);
    BrandAnalytics.instance.event(campaign, BrandEvent.impression);
    await _pushPremiere(context, campaign, stage);
  } catch (_) {
    // A brand surface must never be the reason the app fails to open.
  }
}

/// DEMO ONLY — replay one named Premiere, past its once-per-campaign cap.
///
/// Returns false and shows nothing unless demo mode is on. That gate is the
/// whole design: the cap protects a real parent, so the only way round it is a
/// switch a real parent never has on (BrandStudioStore.demoMode, set by the
/// Brand Showcase). Everything else still applies — the kill switch, `active`
/// and the schedule — because isEligible() checks those even with caps
/// ignored. A replay does NOT record an impression: watching it again in a
/// meeting is not a parent being shown an advert again.
///
/// Trade-off: a replay by id rather than through resolve() means the demo can
/// pick WHICH Premiere to show (resolve returns only the first). It costs a
/// second entry point, so the gate above lives here, not at each caller.
Future<bool> replayPremiere(
  BuildContext context, {
  required String campaignId,
  BrandStage stage = BrandStage.parenting,
}) async {
  final studio = BrandStudio.instance;
  if (!studio.demoMode) return false;
  BrandCampaign? campaign;
  for (final c in studio.campaigns) {
    if (c.id == campaignId && c.slot == BrandSlot.premiere) campaign = c;
  }
  if (campaign == null) return false;
  if (!studio.isEligible(campaign, captureBrandContext(stage: stage), ignoreCaps: true)) return false;
  if (!context.mounted) return false;
  try {
    await _pushPremiere(context, campaign, stage);
    return true;
  } catch (_) {
    return false;
  }
}

Future<void> _pushPremiere(BuildContext context, BrandCampaign campaign, BrandStage stage) =>
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        settings: const RouteSettings(name: 'premiere'),
        opaque: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, _, _) => PremiereScreen(campaign: campaign, stage: stage),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );

class PremiereScreen extends StatefulWidget {
  const PremiereScreen({super.key, required this.campaign, this.stage = BrandStage.parenting});
  final BrandCampaign campaign;

  /// The shell this fired in — threaded through so the CTA resolves the linked
  /// launch against the right app rather than assuming one.
  final BrandStage stage;

  @override
  State<PremiereScreen> createState() => _PremiereScreenState();
}

class _PremiereScreenState extends State<PremiereScreen> with SingleTickerProviderStateMixin {
  /// Drives the caption's staged rise and, with no film, the whole title
  /// sequence — its end is the end of the "film".
  late final AnimationController _c;

  /// The launch film, when the campaign has one. Null means no videoRef, or a
  /// film that failed to load; either way the title sequence plays instead,
  /// so a broken file is never a black box.
  VideoPlayerController? _video;
  bool _videoReady = false;
  bool _muted = false;

  /// The end card is up.
  bool _ended = false;
  bool _completedRecorded = false;

  // Kept for revert (the old UI's flag for its story panel):
  // bool _storyShown = false;

  BrandCampaign get c => widget.campaign;
  Color get _brand => c.brand.colour;

  /// Ink on the brand colour: Pee Safe's lime needs dark text, a deep brand
  /// colour needs white. Decided by luminance so no brand is special-cased.
  Color get _onBrand => ThemeData.estimateBrightnessForColor(_brand) == Brightness.light
      ? const Color(0xFF2F302C)
      : Colors.white;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200));
    _c.addStatusListener((s) {
      // With a film, the film's own end brings the end card, not this timer.
      if (s == AnimationStatus.completed && _video == null) _finish();
    });
    _startFilm();
  }

  void _startFilm() {
    final ref = c.creative.videoRef;
    if (ref == null || ref.isEmpty) {
      _c.forward();
      return;
    }
    final v = ref.startsWith('assets/')
        ? VideoPlayerController.asset(ref)
        : VideoPlayerController.networkUrl(Uri.parse(ref));
    _video = v;
    // A load that never answers (no plugin, a stalled decoder) must not leave
    // a frozen black screen: the timeout throws into the same fallback.
    v.initialize().timeout(const Duration(seconds: 6)).then((_) {
      if (!mounted) return;
      v.addListener(_onVideoTick);
      setState(() => _videoReady = true);
      v.play();
      _c.forward();
    }).catchError((Object _) {
      // A film that will not load falls back to the title sequence.
      if (!mounted) return;
      setState(() => _video = null);
      v.dispose();
      _c.forward();
    });
  }

  void _onVideoTick() {
    final v = _video;
    if (v == null) return;
    final val = v.value;
    if (!val.isInitialized || val.duration == Duration.zero) return;
    if (!val.isPlaying && val.position >= val.duration - const Duration(milliseconds: 250)) _finish();
  }

  void _finish() {
    if (_ended || !mounted) return;
    setState(() => _ended = true);
    if (_completedRecorded) return; // a demo replay is not a second completion
    _completedRecorded = true;
    BrandStudioStore.instance.markCompleted(c.id);
    BrandAnalytics.instance.event(c, BrandEvent.completed);
  }

  /// Demo only (the button is not built otherwise): play it again in place.
  void _replay() {
    setState(() => _ended = false);
    _c.forward(from: 0);
    final v = _video;
    if (v != null) {
      v.seekTo(Duration.zero);
      v.play();
    }
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    _video?.setVolume(_muted ? 0 : 1);
  }

  @override
  void dispose() {
    _video?.removeListener(_onVideoTick);
    _video?.dispose();
    _c.dispose();
    super.dispose();
  }

  /// A staged fade+rise, keyed off one controller so the sequence reads as a
  /// title card rather than a pile of independent animations.
  Animation<double> _stage(double begin, double end) => CurvedAnimation(
        parent: _c,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      );

  Widget _rise(Animation<double> a, Widget child) => AnimatedBuilder(
        animation: a,
        builder: (_, _) => Opacity(
          opacity: a.value,
          child: Transform.translate(offset: Offset(0, 14 * (1 - a.value)), child: child),
        ),
      );

  void _close() {
    _video?.pause();
    BrandStudioStore.instance.markDismissed(c.id);
    BrandAnalytics.instance.event(c, BrandEvent.dismissed);
    Navigator.of(context).maybePop();
  }

  Future<void> _cta() async {
    _video?.pause();
    BrandAnalytics.instance.event(c, BrandEvent.ctaTapped);

    // Premiere is the moment; the Launch Hub is where the launch lives. Always
    // hand the parent somewhere real rather than straight to a shop.
    final ctx = captureBrandContext(stage: widget.stage);
    final launch = BrandStudio.instance.linkedLaunch(c, ctx);
    final nav = Navigator.of(context);
    nav.pop();

    if (launch != null) {
      await nav.push(MaterialPageRoute(builder: (_) => LaunchDetailScreen(campaign: launch)));
      return;
    }
    await openOutbound(c.brand.landingUrl ?? '', campaign: c);
  }

  // ---- the redesigned takeover ----------------------------------------------

  bool get _hasFilm => _video != null && _videoReady;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(fit: StackFit.expand, children: [
        // Full bleed: the film, or our own title field until a brand sends one.
        _hasFilm ? _film(_video!) : _titleField(),

        // Caption over a bottom scrim, so white text reads on any frame.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              height: 360,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.82)],
                ),
              ),
            ),
          ),
        ),
        Positioned(left: 24, right: 24, bottom: pad.bottom + 36, child: _caption()),

        // Top row. Skip is there from the first frame — never delayed, never
        // a countdown. Mute only exists when there is sound to mute.
        Positioned(
          top: pad.top + 10,
          left: 16,
          right: 16,
          child: Row(children: [
            if (_hasFilm)
              _pill(
                icon: _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                label: _muted ? 'Unmute' : 'Mute',
                onTap: _toggleMute,
              )
            else
              _presentedChip(),
            const Spacer(),
            _pill(icon: Icons.close_rounded, label: 'Skip', onTap: _close),
          ]),
        ),
        // Disclosure is in frame from the start; with a film it sits under Mute.
        if (_hasFilm) Positioned(top: pad.top + 56, left: 16, child: _presentedChip()),

        if (_ended) Positioned.fill(child: _endCard(pad)),
      ]),
    );
  }

  Widget _film(VideoPlayerController v) => ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: v.value.size.width,
            height: v.value.size.height,
            child: VideoPlayer(v),
          ),
        ),
      );

  /// The no-film fallback: the brand's colour, deepened, with its logo rising
  /// in the middle third — a title sequence, not a loading screen.
  Widget _titleField() => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(_brand, Colors.black, 0.38)!,
              Color.lerp(_brand, const Color(0xFF14101A), 0.82)!,
            ],
          ),
        ),
        child: Align(
          alignment: const Alignment(0, -0.28),
          child: _rise(_stage(0.0, 0.3), _logoTile(88)),
        ),
      );

  Widget _logoTile(double size) => Container(
        padding: EdgeInsets.all(size * 0.16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size * 0.3),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: BrandMark(brand: c.brand, size: size * 0.68),
      );

  Widget _caption() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rise(
            _stage(0.18, 0.42),
            Text(
              c.creative.eyebrow.toUpperCase(),
              style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _rise(
            _stage(0.30, 0.6),
            Text(
              c.creative.headline,
              style: pvFraunces(
                fontSize: 40,
                height: 1.04,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _rise(
            _stage(0.44, 0.74),
            Text(
              c.creative.subline,
              style: pvManrope(fontSize: 15, height: 1.5, color: Colors.white.withValues(alpha: 0.86)),
            ),
          ),
        ],
      );

  /// "Presented by" + the brand name — the campaign's own disclosure string, with the
  /// brand's mark, so the attribution can never drift from the data.
  Widget _presentedChip() => Container(
        padding: const EdgeInsets.fromLTRB(5, 5, 12, 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: ColoredBox(
              color: Colors.white,
              child: Padding(padding: const EdgeInsets.all(2), child: BrandMark(brand: c.brand, size: 16)),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            c.disclosure,
            style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ]),
      );

  Widget _pill({required IconData icon, required String label, required VoidCallback onTap}) => Material(
        color: Colors.black.withValues(alpha: 0.38),
        shape: StadiumBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.18))),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(label, style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
            ]),
          ),
        ),
      );

  /// The end card: logo, one line, one primary action, one quiet way out.
  Widget _endCard(EdgeInsets pad) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        builder: (_, t, child) => Opacity(opacity: t, child: child),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(_brand, const Color(0xFF14101A), 0.78)!,
                const Color(0xFF14101A),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(28, pad.top + 10, 28, pad.bottom + 20),
            child: Column(children: [
              Align(alignment: Alignment.centerLeft, child: _presentedChip()),
              const Spacer(),
              _logoTile(84),
              const SizedBox(height: 22),
              Text(
                c.creative.subline,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(fontSize: 16, height: 1.45, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const Spacer(),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _brand,
                      foregroundColor: _onBrand,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: _cta,
                    child: Text(
                      c.creative.cta,
                      style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w800, color: _onBrand),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: _close,
                child: Text(
                  S.now.uiNotNow,
                  style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white70),
                ),
              ),
              // Demo only: a real parent never has demo mode on, so never sees this.
              if (BrandStudio.instance.demoMode)
                TextButton.icon(
                  onPressed: _replay,
                  icon: const Icon(Icons.replay_rounded, size: 16, color: Colors.white54),
                  label: Text(
                    'Replay',
                    style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white54),
                  ),
                ),
            ]),
          ),
        ),
      );

  // ---- the previous UI, kept for revert (pre-2026-11-02) --------------------
  // Title card over a brand gradient, a close icon, the uppercase disclosure,
  // then a white story panel with the CTA. Needs `_storyShown` above, the
  // brand_disclosure.dart import, and the old 2600ms controller.
  //
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF14101A),
//       body: Stack(children: [
//         // The film. A real videoRef renders the player here; until a brand
//         // supplies one we show our own title sequence rather than a black box.
//         Positioned.fill(child: _titleSequence()),
//
//         // Skippable from the first frame. Never delayed, never a countdown.
//         Positioned(
//           top: MediaQuery.of(context).padding.top + 8,
//           right: 10,
//           child: IconButton(
//             onPressed: _close,
//             icon: const Icon(Icons.close_rounded, color: Colors.white70),
//             tooltip: S.now.uiClose,
//           ),
//         ),
//
//         // Disclosure sits in the frame from the start — not after the story.
//         Positioned(
//           top: MediaQuery.of(context).padding.top + 14,
//           left: 20,
//           child: _rise(
//             _stage(0.0, 0.25),
//             SponsorDisclosure(
//               campaign: c,
//               color: Colors.white,
//               background: Colors.white.withValues(alpha: 0.14),
//             ),
//           ),
//         ),
//
//         if (_storyShown)
//           Positioned(left: 0, right: 0, bottom: 0, child: _storyPanel()),
//       ]),
//     );
//   }
//
//   Widget _titleSequence() => Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color.lerp(_brand, Colors.black, 0.34)!,
//               Color.lerp(_brand, const Color(0xFF14101A), 0.72)!,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _rise(
//                   _stage(0.18, 0.42),
//                   Text(
//                     c.creative.eyebrow.toUpperCase(),
//                     style: pvManrope(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 2.2,
//                       color: Colors.white.withValues(alpha: 0.72),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 14),
//                 _rise(
//                   _stage(0.30, 0.62),
//                   Text(
//                     c.creative.headline,
//                     style: pvFraunces(
//                       fontSize: 52,
//                       height: 1.02,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                       letterSpacing: -1,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 _rise(
//                   _stage(0.46, 0.78),
//                   Text(
//                     c.creative.subline,
//                     style: pvManrope(
//                       fontSize: 15.5,
//                       height: 1.5,
//                       color: Colors.white.withValues(alpha: 0.82),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 26),
//                 _rise(_stage(0.62, 0.9), _hairline()),
//               ],
//             ),
//           ),
//         ),
//       );
//
//   Widget _hairline() => Container(
//         width: 54,
//         height: 2,
//         decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2)),
//       );
//
//   Widget _storyPanel() => TweenAnimationBuilder<double>(
//         tween: Tween(begin: 0, end: 1),
//         duration: const Duration(milliseconds: 420),
//         curve: Curves.easeOutCubic,
//         builder: (_, t, child) => Opacity(
//           opacity: t,
//           child: Transform.translate(offset: Offset(0, 26 * (1 - t)), child: child),
//         ),
//         child: Container(
//           width: double.infinity,
//           decoration: const BoxDecoration(
//             color: Color(0xFFFBF9FE),
//             borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
//           ),
//           padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
//           child: SafeArea(
//             top: false,
//             child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(
//                 c.creative.story,
//                 style: pvManrope(fontSize: 14.5, height: 1.62, color: const Color(0xFF2F2C30)),
//               ),
//               const SizedBox(height: 18),
//               SizedBox(
//                 width: double.infinity,
//                 child: FilledButton(
//                   style: FilledButton.styleFrom(
//                     backgroundColor: _brand,
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                   ),
//                   onPressed: _cta,
//                   child: Text(
//                     c.creative.cta,
//                     style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Center(
//                 child: TextButton(
//                   onPressed: _close,
//                   child: Text(
//                     S.now.uiNotNow,
//                     style: pvManrope(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       color: const Color(0xFF69636C),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 4),
//             ]),
//           ),
//         ),
//       );
}
