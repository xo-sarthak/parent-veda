// =============================================================================
//  LaunchSpotlight — the Launch Hub's front door, on the home screen
// -----------------------------------------------------------------------------
//  Brand Product 2 is meant to feel like an Apple Event. It was a row in the
//  Tools list: findable only if you already knew it existed, which means a
//  launch a brand paid for reached almost nobody.
//
//  This is a DESTINATION invitation, not a push. It differs from an ad in three
//  ways that matter:
//    * it renders NOTHING unless a launch is genuinely live for this parent,
//    * it is a door, not a message - no offer, no price, no urgency,
//    * tapping it goes to editorial (story, expert, resources), not a buy page.
//
//  It carries the brand's mark and colour so it reads as what it is, and is
//  labelled so it can never be mistaken for ParentVeda's own editorial.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'brand_analytics.dart';
import 'brand_context.dart';
import 'brand_mark.dart';
import 'brand_models.dart';
import 'brand_studio.dart';
import 'launch_hub_screen.dart';

class LaunchSpotlight extends StatefulWidget {
  const LaunchSpotlight({
    super.key,
    required this.stage,
    this.pregnancyWeek,
    this.padding = EdgeInsets.zero,
  });

  final BrandStage stage;
  final int? pregnancyWeek;
  final EdgeInsets padding;

  @override
  State<LaunchSpotlight> createState() => _LaunchSpotlightState();
}

class _LaunchSpotlightState extends State<LaunchSpotlight> {
  BrandCampaign? _campaign;

  @override
  void initState() {
    super.initState();
    // Resolved once per mount — a rebuild is not a new impression.
    try {
      final ctx = captureBrandContext(
          stage: widget.stage, pregnancyWeek: widget.pregnancyWeek);
      _campaign = BrandStudio.instance.resolve(BrandSlot.launchHub, ctx);
      final c = _campaign;
      if (c != null) BrandAnalytics.instance.event(c, BrandEvent.impression);
    } catch (_) {
      _campaign = null; // a brand surface never breaks its host
    }
  }

  void _open(BrandCampaign c) {
    BrandAnalytics.instance.event(c, BrandEvent.opened);
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => LaunchHubScreen(
          stage: widget.stage, pregnancyWeek: widget.pregnancyWeek),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = _campaign;
    if (c == null) return const SizedBox.shrink();
    final brand = c.brand;
    return Padding(
      padding: widget.padding,
      child: GestureDetector(
        onTap: () => _open(c),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                brand.colour.withValues(alpha: 0.10),
                brand.colour.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(color: brand.colour.withValues(alpha: 0.22)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              BrandMark(brand: brand, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A PARENTVEDA LAUNCH',
                        style: GoogleFonts.manrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: brand.colour,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c.creative.headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.fraunces(
                          fontSize: 19,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D144C),
                        ),
                      ),
                    ]),
              ),
              Icon(Icons.arrow_forward_rounded, size: 18, color: brand.colour),
            ]),
            const SizedBox(height: 9),
            Text(
              c.creative.subline,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                  fontSize: 12.5, height: 1.45, color: const Color(0xFF5C5566)),
            ),
            const SizedBox(height: 9),
            // Disclosure is not optional and never abbreviated away.
            Text(
              c.disclosure,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: const Color(0xFF8B8394),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
