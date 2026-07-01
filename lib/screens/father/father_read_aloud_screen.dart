// =============================================================================
//  FatherReadAloudScreen — the father's "Read to baby" tab (Slate)
// -----------------------------------------------------------------------------
//  Read-only mirror of the mother's Samvad read-aloud pool (same words she's
//  reading). Customization lives ONLY on the mother's side — this just surfaces
//  the enabled pieces so the father can read them aloud to the bump. Embedded as
//  a tab → no back button, bottom padding clears the floating pill.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/garbh_data.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/read_to_baby_store.dart';
import '../../services/samvad_pool.dart';
import '../../theme/father_skin.dart';

class FatherReadAloudScreen extends StatelessWidget {
  const FatherReadAloudScreen({super.key, required this.controller});
  final PregnancyController controller;

  TextStyle _body(double s,
          {FontWeight w = FontWeight.w400, Color c = kFInk, double h = 1.5}) =>
      GoogleFonts.plusJakartaSans(fontSize: s, fontWeight: w, color: c, height: h);
  TextStyle _eyebrow(Color c) => GoogleFonts.plusJakartaSans(
      fontSize: 11, fontWeight: FontWeight.w700, color: c, letterSpacing: 1.4);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ReadToBabyStore.instance,
      builder: (context, _) {
        final t = garbhTrimester(controller.currentWeek);
        final groups = samvadLibraryGroups(ReadToBabyStore.instance, t);
        return Container(
          color: kFBg,
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
              children: [
                Text('READ TO YOUR BABY', style: _eyebrow(kFMuted)),
                const SizedBox(height: 4),
                Text('Read to your baby',
                    style: fatherSerif(26, weight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                    "The same words she's reading — say them aloud to the bump. Your voice is one they already know.",
                    style: _body(13, c: kFMuted)),
                const SizedBox(height: 18),
                if (groups.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: kFAccentSoft,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: kFLine),
                    ),
                    child: Text(
                        "Nothing chosen yet — she sets what to read in her app, and it shows up here for you.",
                        style: _body(14, c: kFInk)),
                  )
                else
                  for (final g in groups) _group(g),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _group(SamvadGroup g) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 10),
            child: Text(g.heading.toUpperCase(), style: _eyebrow(kFAccent)),
          ),
          for (final p in g.pieces) _card(p),
          const SizedBox(height: 8),
        ],
      );

  Widget _card(SamvadPiece p) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: kFCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kFLine),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (p.title != null && p.title!.trim().isNotEmpty) ...[
            Text(p.title!, style: fatherSerif(16, weight: FontWeight.w700)),
            const SizedBox(height: 8),
          ],
          Text('“${p.body}”',
              style: GoogleFonts.fraunces(
                  fontSize: 15.5,
                  fontStyle: FontStyle.italic,
                  height: 1.55,
                  color: kFInk)),
        ]),
      );
}
