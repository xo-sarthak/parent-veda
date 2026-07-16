// =============================================================================
//  Sponsored community campaign — Brand Product 11 (archetype: presented-by)
// -----------------------------------------------------------------------------
//  Replaces a hardcoded brand card that sat in the parenting community feed
//  with no campaign, no targeting, no schedule and no disclosure standard. The
//  card is the same shape; what changed is that a brand can no longer get into
//  the feed by someone typing its name into a build method.
//
//  The community participation is the point. The brand funds the campaign and
//  is named for it — it does not run it, and it does not see who took part.
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/post_pregnancy/pp_common.dart';
import 'brand_analytics.dart';
import 'brand_context.dart';
import 'brand_disclosure.dart';
import 'brand_models.dart';
import 'brand_studio.dart';
import 'presented_by.dart';

class SponsoredCommunityCampaign extends StatefulWidget {
  const SponsoredCommunityCampaign({super.key});

  @override
  State<SponsoredCommunityCampaign> createState() => _SponsoredCommunityCampaignState();
}

class _SponsoredCommunityCampaignState extends State<SponsoredCommunityCampaign> {
  BrandCampaign? _c;

  @override
  void initState() {
    super.initState();
    try {
      final ctx = captureBrandContext(stage: BrandStage.parenting);
      _c = BrandStudio.instance.resolve(BrandSlot.communityCampaign, ctx);
      final c = _c;
      if (c != null) BrandAnalytics.instance.event(c, BrandEvent.impression);
    } catch (_) {
      _c = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    // No campaign is the normal case, and an empty feed slot is the feed
    // working correctly — not a gap to fill.
    if (c == null) return const SizedBox.shrink();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        BrandAnalytics.instance.event(c, BrandEvent.opened);
        showSponsorSheet(context, c);
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SponsorDisclosure(campaign: c, color: c.brand.colour, compact: true),
        const SizedBox(height: 10),
        Row(children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.brand.colour.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.groups_rounded, size: 24, color: c.brand.colour),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                c.creative.headline,
                style: ppJakarta(15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(c.creative.subline, style: ppBody(12), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        IndependenceNote(campaign: c),
      ]),
    );
  }
}
