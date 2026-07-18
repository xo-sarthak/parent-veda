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
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'brand_analytics.dart';
import 'brand_context.dart';
import 'brand_disclosure.dart';
import 'brand_models.dart';
import 'brand_store.dart';
import 'brand_studio.dart';
import 'launch_hub_screen.dart';
import 'outbound.dart';

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
    final campaign = BrandStudio.instance.resolve(BrandSlot.premiere, ctx);
    if (campaign == null) return;
    if (!context.mounted) return;

    // Spend the cap at the moment it is actually surfaced, not at resolve time.
    BrandStudioStore.instance.recordImpression(campaign.id);
    BrandAnalytics.instance.event(campaign, BrandEvent.impression);

    await Navigator.of(context, rootNavigator: true).push(
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
  } catch (_) {
    // A brand surface must never be the reason the app fails to open.
  }
}

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
  late final AnimationController _c;
  bool _storyShown = false;

  BrandCampaign get c => widget.campaign;
  Color get _brand => c.brand.colour;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..forward();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _storyShown = true);
        BrandStudioStore.instance.markCompleted(c.id);
        BrandAnalytics.instance.event(c, BrandEvent.completed);
      }
    });
  }

  @override
  void dispose() {
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
    BrandStudioStore.instance.markDismissed(c.id);
    BrandAnalytics.instance.event(c, BrandEvent.dismissed);
    Navigator.of(context).maybePop();
  }

  Future<void> _cta() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14101A),
      body: Stack(children: [
        // The film. A real videoRef renders the player here; until a brand
        // supplies one we show our own title sequence rather than a black box.
        Positioned.fill(child: _titleSequence()),

        // Skippable from the first frame. Never delayed, never a countdown.
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 10,
          child: IconButton(
            onPressed: _close,
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            tooltip: 'Close',
          ),
        ),

        // Disclosure sits in the frame from the start — not after the story.
        Positioned(
          top: MediaQuery.of(context).padding.top + 14,
          left: 20,
          child: _rise(
            _stage(0.0, 0.25),
            SponsorDisclosure(
              campaign: c,
              color: Colors.white,
              background: Colors.white.withValues(alpha: 0.14),
            ),
          ),
        ),

        if (_storyShown)
          Positioned(left: 0, right: 0, bottom: 0, child: _storyPanel()),
      ]),
    );
  }

  Widget _titleSequence() => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(_brand, Colors.black, 0.34)!,
              Color.lerp(_brand, const Color(0xFF14101A), 0.72)!,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rise(
                  _stage(0.18, 0.42),
                  Text(
                    c.creative.eyebrow.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.2,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _rise(
                  _stage(0.30, 0.62),
                  Text(
                    c.creative.headline,
                    style: GoogleFonts.fraunces(
                      fontSize: 52,
                      height: 1.02,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _rise(
                  _stage(0.46, 0.78),
                  Text(
                    c.creative.subline,
                    style: GoogleFonts.manrope(
                      fontSize: 15.5,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                _rise(_stage(0.62, 0.9), _hairline()),
              ],
            ),
          ),
        ),
      );

  Widget _hairline() => Container(
        width: 54,
        height: 2,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2)),
      );

  Widget _storyPanel() => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (_, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 26 * (1 - t)), child: child),
        ),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFFBF9FE),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                c.creative.story,
                style: GoogleFonts.manrope(fontSize: 14.5, height: 1.62, color: const Color(0xFF2F2C30)),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _brand,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _cta,
                  child: Text(
                    c.creative.cta,
                    style: GoogleFonts.manrope(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _close,
                  child: Text(
                    'Not now',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF69636C),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ]),
          ),
        ),
      );
}
