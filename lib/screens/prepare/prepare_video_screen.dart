// =============================================================================
//  PrepareVideoScreen — tidy placeholder player
// -----------------------------------------------------------------------------
//  Yoga sessions, birthing classes and the masterclass intro all "play" into
//  here. Real clips aren't wired yet, so this shows a calm "video coming soon"
//  player with the title + blurb — ready to drop a real player into later.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'prepare_common.dart';

class PrepareVideoScreen extends StatelessWidget {
  const PrepareVideoScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.blurb,
  });

  final String title;
  final String? subtitle; // e.g. "18 min · opening"
  final String? blurb;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: pvTopBar(context, backLabel: 'Back'),
          ),
          const SizedBox(height: 20),

          // "player" surface
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(children: [
                const PvStriped(height: 999, colorA: Color(0xFFE4D5F0), colorB: kStripeA, radius: 22),
                Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Color(0x332F2C30), blurRadius: 20, offset: Offset(0, 6)),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text('▶', style: TextStyle(color: kPurple, fontSize: 24)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: kInk.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(999)),
                      child: Text('Video coming soon',
                          style: GoogleFonts.manrope(
                              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ]),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: pvHeroStyle().copyWith(fontSize: 26)),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle!, style: pvBody(kPurple, 13).copyWith(fontWeight: FontWeight.w600)),
              ],
              if (blurb != null) ...[
                const SizedBox(height: 14),
                Text(blurb!, style: pvSubStyle()),
              ],
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  const Text('🎬', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('The full video lands here soon. We\'ll notify you when it\'s ready to watch.',
                        style: pvBody(kInk, 13).copyWith(height: 1.5)),
                  ),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
