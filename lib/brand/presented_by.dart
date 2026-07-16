// =============================================================================
//  Presented-by — the archetype behind 8 of the 15 brand products
// -----------------------------------------------------------------------------
//  ParentVeda's content. A brand's funding. A visible attribution. The brand
//  pays for the thing to EXIST and never touches what it SAYS.
//
//  The design goal of this file is that a host screen never branches on whether
//  a sponsor exists. It drops in a PresentedBy and gets either a quiet line or
//  an empty box — so the unsponsored case is the default shape of the code, and
//  "is this sponsored?" logic can never sprawl across the app.
//
//  Nothing here is capped: a sponsor line on a tool a parent chose to open is
//  attribution, not an interruption. See BrandArchetypeX.isPushed.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'brand_analytics.dart';
import 'brand_context.dart';
import 'brand_disclosure.dart';
import 'brand_models.dart';
import 'brand_studio.dart';

/// A quiet `Presented by <Brand>` line for a sponsored surface.
///
/// Renders nothing at all when no campaign is live — which is the normal case.
/// Deliberately subtle: it must never compete with the content it funds.
class PresentedBy extends StatefulWidget {
  const PresentedBy({
    super.key,
    required this.slot,
    required this.stage,
    this.placementKey,
    this.pregnancyWeek,
    this.color,
    this.padding = EdgeInsets.zero,
  });

  final BrandSlot slot;
  final BrandStage stage;
  final String? placementKey;
  final int? pregnancyWeek;
  final Color? color;
  final EdgeInsets padding;

  @override
  State<PresentedBy> createState() => _PresentedByState();
}

class _PresentedByState extends State<PresentedBy> {
  BrandCampaign? _campaign;

  @override
  void initState() {
    super.initState();
    // Resolve once per mount, not per build: a rebuild is not a new impression,
    // and analytics that counts frames is analytics that lies.
    try {
      final ctx = captureBrandContext(stage: widget.stage, pregnancyWeek: widget.pregnancyWeek);
      _campaign = BrandStudio.instance.resolve(widget.slot, ctx, placementKey: widget.placementKey);
      final c = _campaign;
      if (c != null) BrandAnalytics.instance.event(c, BrandEvent.impression);
    } catch (_) {
      _campaign = null; // a brand surface never breaks its host
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _campaign;
    if (c == null) return const SizedBox.shrink();
    return Padding(
      padding: widget.padding,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          BrandAnalytics.instance.event(c, BrandEvent.opened);
          showSponsorSheet(context, c);
        },
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: c.brand.colour, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            c.disclosure,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: widget.color ?? const Color(0xFF69636C),
            ),
          ),
          const SizedBox(width: 3),
          Icon(Icons.info_outline_rounded, size: 12, color: widget.color ?? const Color(0xFFA99CBB)),
        ]),
      ),
    );
  }
}

/// The explanation a parent gets when they tap a sponsor line.
///
/// This exists because a label alone ("Presented by X") is ambiguous — it could
/// mean the brand wrote it. The sheet says plainly what the money did and did
/// not buy, and it is reachable from every presented-by surface.
void showSponsorSheet(BuildContext context, BrandCampaign c) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFFBF9FE),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          child: Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE4E2E5), borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 18),
        SponsorDisclosure(campaign: c, color: c.brand.colour),
        const SizedBox(height: 14),
        Text(
          'What that means',
          style: GoogleFonts.fraunces(fontSize: 21, fontWeight: FontWeight.w600, color: const Color(0xFF2D144C)),
        ),
        const SizedBox(height: 10),
        Text(
          '${c.brand.name} paid for this to exist. They did not write it, they did not review it before you saw it, '
          'and they cannot change it now. ParentVeda decides what it says.',
          style: GoogleFonts.manrope(fontSize: 14, height: 1.6, color: const Color(0xFF2F2C30)),
        ),
        const SizedBox(height: 12),
        Text(
          'Sponsorship never moves a product\'s ParentVeda rating, and it never changes what we recommend to you. '
          'If we stopped believing this was worth your time, it would come down — funded or not.',
          style: GoogleFonts.manrope(fontSize: 13, height: 1.6, color: const Color(0xFF69636C)),
        ),
        const SizedBox(height: 18),
        IndependenceNote(campaign: c),
      ]),
    ),
  );
}

/// A section heading with an optional sponsor line beneath it.
///
/// The whole point: the host writes the same code whether or not the section is
/// sponsored. Sponsorship is a property of the slot, not a branch in the screen.
class PresentedBySection extends StatelessWidget {
  const PresentedBySection({
    super.key,
    required this.title,
    required this.slot,
    required this.stage,
    this.placementKey,
    this.pregnancyWeek,
    this.titleStyle,
  });

  final String title;
  final BrandSlot slot;
  final BrandStage stage;
  final String? placementKey;
  final int? pregnancyWeek;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        title,
        style: titleStyle ??
            GoogleFonts.fraunces(fontSize: 22, height: 1.15, fontWeight: FontWeight.w600, color: const Color(0xFF2D144C)),
      ),
      PresentedBy(
        slot: slot,
        stage: stage,
        placementKey: placementKey,
        pregnancyWeek: pregnancyWeek,
        padding: const EdgeInsets.only(top: 6),
      ),
    ]);
  }
}
