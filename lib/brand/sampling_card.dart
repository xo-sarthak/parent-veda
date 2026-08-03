// =============================================================================
//  SamplingCard — the front door to Product Sampling (Brand Product 12)
// -----------------------------------------------------------------------------
//  Renders nothing unless a sampling campaign is live for this parent. Like the
//  launch spotlight it is a DOOR, not a message: it names the offer plainly,
//  discloses the sponsor, and the actual asking (an address) happens on the
//  screen behind it, after the privacy promise has been made.
//
//  Shows a settled "you are on the list" state once claimed, so a parent is
//  never invited to claim the same sample twice.
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

import 'brand_analytics.dart';
import 'brand_context.dart';
import 'brand_mark.dart';
import 'brand_models.dart';
import 'brand_store.dart';
import 'brand_studio.dart';
import 'sampling_screen.dart';
import '../theme/pv_fonts.dart';

class SamplingCard extends StatefulWidget {
  const SamplingCard({
    super.key,
    required this.stage,
    this.pregnancyWeek,
    this.padding = EdgeInsets.zero,
  });

  final BrandStage stage;
  final int? pregnancyWeek;
  final EdgeInsets padding;

  @override
  State<SamplingCard> createState() => _SamplingCardState();
}

class _SamplingCardState extends State<SamplingCard> {
  BrandCampaign? _campaign;

  @override
  void initState() {
    super.initState();
    try {
      final ctx = captureBrandContext(
          stage: widget.stage, pregnancyWeek: widget.pregnancyWeek);
      _campaign = BrandStudio.instance.resolve(BrandSlot.productSampling, ctx);
      final c = _campaign;
      if (c != null) BrandAnalytics.instance.event(c, BrandEvent.impression);
    } catch (_) {
      _campaign = null;
    }
  }

  Future<void> _open(BrandCampaign c) async {
    BrandAnalytics.instance.event(c, BrandEvent.opened);
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => SamplingScreen(campaign: c),
    ));
    if (mounted) setState(() {}); // reflect a claim made on the way back
  }

  @override
  Widget build(BuildContext context) {
    final c = _campaign;
    if (c == null) return const SizedBox.shrink();
    final brand = c.brand;
    final claimed = BrandStudioStore.instance.completed(c.id);
    return Padding(
      padding: widget.padding,
      child: GestureDetector(
        onTap: () => _open(c),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: brand.colour.withValues(alpha: 0.22)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              BrandMark(brand: brand, size: 32),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        claimed ? 'ON THE LIST' : c.creative.eyebrow.toUpperCase(),
                        style: pvManrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                          color: claimed ? AppTheme.accentGreen : brand.colour,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c.creative.headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2F2C30)),
                      ),
                    ]),
              ),
              Icon(
                  claimed
                      ? Icons.check_circle_rounded
                      : Icons.arrow_forward_rounded,
                  size: 18,
                  color: claimed ? AppTheme.accentGreen : brand.colour),
            ]),
            const SizedBox(height: 9),
            Text(
              claimed
                  ? 'We will post it within about two weeks.'
                  : c.creative.subline,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                  fontSize: 12.5, height: 1.45, color: const Color(0xFF69636C)),
            ),
            const SizedBox(height: 8),
            Text(c.disclosure,
                style: pvManrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: const Color(0xFF8B8394))),
          ]),
        ),
      ),
    );
  }
}
