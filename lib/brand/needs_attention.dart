// =============================================================================
//  Needs-attention flags — decisions made visible IN the app
// -----------------------------------------------------------------------------
//  Some things got built despite a real, unresolved tension. Burying that in a
//  markdown file means it ships and nobody remembers. So the flag lives on the
//  screen itself: you cannot walk past the feature without seeing that it is
//  flagged, and tapping it says exactly what the argument is.
//
//  Every flag here is also listed in the terminal handover and in
//  docs/BRAND-STUDIO.md §11. Three places, one truth.
//
//  These are DEBUG-VISIBLE ONLY (kDebugMode) — a parent never sees them. They
//  are a note from the build to the people deciding, not app content.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Everything currently flagged. The single list the preview screen renders.
enum BrandFlag {
  productGuideSponsorship,
  compareSponsorship,
  placeholderBrands,
  noBrandFilm,
  samplingFulfilment,
}

@immutable
class BrandFlagInfo {
  const BrandFlagInfo({
    required this.title,
    required this.what,
    required this.tension,
    required this.decision,
    required this.where,
  });

  /// One line, shown on the flag itself.
  final String title;

  /// What was built.
  final String what;

  /// The honest argument against it.
  final String tension;

  /// What you are actually being asked to decide.
  final String decision;

  /// Where in the app this shows up.
  final String where;
}

const Map<BrandFlag, BrandFlagInfo> kBrandFlags = {
  BrandFlag.productGuideSponsorship: BrandFlagInfo(
    title: 'Sponsorship on a research page',
    what:
        'A brand can sponsor the Product Guide\'s expert videos and Research Corner. It is labelled, it cannot touch the ParentVeda rating, and the research shown is still chosen by us.',
    tension:
        'The app already promises parents, in shipped copy on the parenting home: "Sponsored & affiliate picks — always labelled, and never on your research pages." A Product Guide is a research page by that definition. Building this means the promise is now partly untrue, so the copy was narrowed to match reality rather than left as a quiet lie.',
    decision:
        'Either accept the narrowed promise (sponsorship never influences ratings or rankings, but may fund research pages), or pull sponsorship off Product Guides entirely and sell the adjacent Launch Hub slots instead.',
    where: 'Product Guide → Expert videos + Research Corner',
  ),
  BrandFlag.compareSponsorship: BrandFlagInfo(
    title: 'Sponsorship on the Compare tool',
    what:
        'A brand can sponsor an educational note beneath a comparison. The comparison data itself is untouched — no spec, no rating, no ordering, and the sponsor cannot be one of the two products being compared.',
    tension:
        'Same promise as the Product Guide: Compare is a research surface. It is also the single most decision-shaping screen in the app — a parent is choosing between two things right there — so a brand\'s presence carries more weight here than anywhere else.',
    decision:
        'Decide with the Product Guide question; they are one decision. If you keep it, the "sponsor cannot be a compared product" rule must stay non-negotiable.',
    where: 'Compare products → below the table',
  ),
  BrandFlag.placeholderBrands: BrandFlagInfo(
    title: 'Every brand here is invented',
    what:
        'NestlingCo, MamaBloom, PureStart and TinyToes are not real companies. Their launches, studies and expert quotes are written by us to show the shape of the product.',
    tension:
        'This is fine internally and would be a serious problem if it ever shipped to parents — invented trials ("their own 12-week trial ran on 210 babies") read as real claims.',
    decision: 'Do not ship placeholder campaigns to production. Replace them, or switch the Studio off, before launch.',
    where: 'Everywhere brand content appears',
  ),
  BrandFlag.noBrandFilm: BrandFlagInfo(
    title: 'Premiere has no brand film',
    what:
        'Premiere is specced around a 10–20s brand video. No brand has supplied one, so it renders a title sequence we built instead.',
    tension: 'What you are seeing is the fallback, not the product. The real thing is a film; this is the frame around it.',
    decision: 'Judge the pacing and the story panel, not the visuals. The video slot is wired and waiting for a real asset.',
    where: 'App open → Premiere',
  ),
  BrandFlag.samplingFulfilment: BrandFlagInfo(
    title: 'Sampling collects requests it cannot fulfil',
    what:
        'Parents can register interest in a free sample, and the request is stored locally with their consent recorded.',
    tension:
        'There is no fulfilment behind it: no address collection, no shipping, no brand hand-off, no backend. A parent who registers today gets nothing, and would be right to be annoyed.',
    decision:
        'Sampling must not go live to parents until fulfilment exists. It is behind the Studio kill switch; leave it there until a brand can actually post a box.',
    where: 'Recommendations → sampling card',
  ),
};

/// A visible flag on a flagged surface. Debug builds only.
class NeedsAttentionFlag extends StatelessWidget {
  const NeedsAttentionFlag({super.key, required this.flag, this.padding = EdgeInsets.zero});

  final BrandFlag flag;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    // A parent must never see build notes. This is for the people deciding.
    if (!kDebugMode) return const SizedBox.shrink();

    final info = kBrandFlags[flag]!;
    return Padding(
      padding: padding,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showBrandFlagSheet(context, flag),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFF5A79).withValues(alpha: 0.45)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.flag_rounded, size: 13, color: Color(0xFFD92D20)),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                'NEEDS A DECISION · ${info.title}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: const Color(0xFFD92D20),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

void showBrandFlagSheet(BuildContext context, BrandFlag flag) {
  final info = kBrandFlags[flag]!;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFFBF9FE),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE4E2E5), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          Row(children: [
            const Icon(Icons.flag_rounded, size: 15, color: Color(0xFFD92D20)),
            const SizedBox(width: 8),
            Text(
              'NEEDS A DECISION',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: const Color(0xFFD92D20),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Text(
            info.title,
            style: GoogleFonts.fraunces(fontSize: 24, height: 1.15, fontWeight: FontWeight.w600, color: const Color(0xFF2D144C)),
          ),
          const SizedBox(height: 18),
          _block('WHAT WAS BUILT', info.what),
          _block('THE ARGUMENT AGAINST IT', info.tension),
          _block('WHAT YOU ARE DECIDING', info.decision),
          _block('WHERE IT SHOWS', info.where),
          const SizedBox(height: 8),
          Text(
            'This note is only visible in debug builds. Parents never see it.',
            style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFFA99CBB)),
          ),
        ]),
      ),
    ),
  );
}

Widget _block(String label, String body) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: const Color(0xFF6A30B6),
          ),
        ),
        const SizedBox(height: 6),
        Text(body, style: GoogleFonts.manrope(fontSize: 13.5, height: 1.6, color: const Color(0xFF2F2C30))),
      ]),
    );
