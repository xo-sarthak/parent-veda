// =============================================================================
//  SponsorDisclosure — the one way brand attribution is ever worded
// -----------------------------------------------------------------------------
//  Centralised on purpose. A brand may not supply its own disclosure text, and
//  a screen may not invent its own phrasing. If disclosure lived at the call
//  site, it would drift — quietly, one placement at a time, in the direction
//  brands prefer.
//
//  Theme-neutral by construction: the two apps have isolated theme systems
//  (AppTheme vs pp_common), so this takes its colours rather than importing
//  either one.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'brand_models.dart';

/// `Presented by <Brand>` — for takeover and destination surfaces.
///
/// Deliberately legible rather than legally-minimal: it sits at the top of the
/// experience, not buried under a fold.
class SponsorDisclosure extends StatelessWidget {
  const SponsorDisclosure({
    super.key,
    required this.campaign,
    this.color,
    this.background,
    this.compact = false,
  });

  final BrandCampaign campaign;
  final Color? color;
  final Color? background;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? const Color(0xFF69636C);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 4 : 5),
      decoration: BoxDecoration(
        color: background ?? fg.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        campaign.disclosure.toUpperCase(),
        style: GoogleFonts.manrope(
          fontSize: compact ? 9 : 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: fg,
        ),
      ),
    );
  }
}

/// `<Brand> funded this. They did not write it.`
///
/// The line that carries the actual promise. Used on presented-by surfaces and
/// anywhere a parent might reasonably wonder who chose the words.
class IndependenceNote extends StatelessWidget {
  const IndependenceNote({super.key, required this.campaign, this.color});

  final BrandCampaign campaign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? const Color(0xFF69636C);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.lock_outline_rounded, size: 13, color: fg),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          campaign.independenceNote,
          style: GoogleFonts.manrope(fontSize: 11.5, height: 1.45, color: fg, fontWeight: FontWeight.w600),
        ),
      ),
    ]);
  }
}

/// "Sponsored" — for ranked inventory, where the label must sit on the item
/// itself and never only in a legend at the top of the list.
class SponsoredTag extends StatelessWidget {
  const SponsoredTag({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? const Color(0xFF69636C);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        'SPONSORED',
        style: GoogleFonts.manrope(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
          color: fg,
        ),
      ),
    );
  }
}
