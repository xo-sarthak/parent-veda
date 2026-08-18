// =============================================================================
//  PpChartBrowserScreen — "what is normal at this age", for any section
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS THE SECOND VERSION OF A SCREEN I ALMOST BUILT TWICE.
//
//  The Sleep section needed a quick check reading its sleep-by-age chart cards.
//  Then the Feeding section declared `pp_food_chart` -- "age food chart quick
//  view. Should read the Area 4 PpChartCard rows, not hold its own copy" -- which
//  is the same screen with different words on it.
//
//  Two screens would have been quicker to write and would have drifted the first
//  time either was touched, which is the exact failure the block model in
//  `pp_content.dart` exists to prevent. So: one screen, parameterised, and both
//  tools are three lines of configuration.
//
//  ⚠️ IT HOLDS NO DATA OF ITS OWN. It reads the section's `PpChartCard`s through
//  the registry, because both sets of numbers are marked REQUIRED_REVIEW and are
//  expected to be corrected by a clinician. A second copy would go on saying the
//  old figure after the card was fixed, and nothing would fail.
//
//  ⚠️ IT ANSWERS "WHAT IS NORMAL", NEVER "IS YOUR CHILD NORMAL". No comparison
//  to her child, no verdict, nothing logged. The reassurance line at the foot is
//  configurable precisely because the honest reassurance differs -- for sleep it
//  is about wide ranges, for food it is about appetite varying day to day -- but
//  every one of them says the same underlying thing: the range is not a target.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_age_bands.dart';
import 'pp_child_profile.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_content.dart';
import 'pp_section_registry.dart';

/// The first `PpChartCard` on a page of [sectionId] tagged to [band].
///
/// Returns null when that section has no card for the band, which is a real
/// answer: the screen says so rather than inventing numbers.
PpChartCard? ppChartForBand(String sectionId, String band) {
  final section = ppSectionFor(sectionId);
  if (section == null) return null;
  for (final area in section.areas) {
    for (final page in area.pages) {
      if (!page.inBand(band)) continue;
      for (final b in page.blocks) {
        if (b is PpChartCard) return b;
      }
    }
  }
  return null;
}

class PpChartBrowserScreen extends StatefulWidget {
  const PpChartBrowserScreen({
    super.key,
    required this.sectionId,
    required this.bands,
    required this.title,
    required this.intro,
    required this.reassurance,
  });

  /// Which section's chart cards to read.
  final String sectionId;

  /// The bands to offer. Must be the section's own band set, or the ids will not
  /// match its page tags and nothing will resolve.
  final PpBandSet bands;

  final String title;
  final String intro;

  /// ⚠️ REQUIRED, NOT OPTIONAL. A screen of ranges with no line saying the range
  /// is not a target is an anxiety machine, and making this a required argument
  /// means a new tool cannot be added without someone writing one.
  final String reassurance;

  @override
  State<PpChartBrowserScreen> createState() => _PpChartBrowserScreenState();
}

class _PpChartBrowserScreenState extends State<PpChartBrowserScreen> {
  late String _band = widget.bands.active.id;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return AnimatedBuilder(
      animation: ChildProfileStore.instance,
      builder: (context, _) {
        final card = ppChartForBand(widget.sectionId, _band);
        final band = widget.bands.byId(_band);
        final mine = widget.bands.active.id;

        return Scaffold(
          backgroundColor: p.ground,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                ppV3Back(context, p),
                const SizedBox(height: 18),
                Text(widget.title, style: pvFraunces(fontSize: 26, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
                const SizedBox(height: 9),
                Text(widget.intro,
                    style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w500, height: 1.6, color: p.ink2)),
                const SizedBox(height: 22),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (final b in widget.bands.ordered) ...[
                      _AgeChip(
                        label: b.label,
                        selected: b.id == _band,
                        mine: b.id == mine,
                        onTap: () => setState(() => _band = b.id),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ]),
                ),
                const SizedBox(height: 24),
                if (card != null)
                  // The same code path the article uses, so the tool and the
                  // section cannot look like two different products.
                  PpBlockView(block: card)
                else
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: p.surfaceAlt,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                        'Nothing recorded for ${band?.label ?? 'this age'} yet.',
                        style: pvManrope(fontSize: 14, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
                  ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
                  decoration: BoxDecoration(
                    color: p.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: p.line),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.favorite_border_rounded,
                            size: 17, color: p.action),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(widget.reassurance,
                              style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.6, color: p.ink1)),
                        ),
                      ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AgeChip extends StatelessWidget {
  const _AgeChip(
      {required this.label,
      required this.selected,
      required this.mine,
      required this.onTap});

  final String label;
  final bool selected;

  /// Whether this is the band the child is actually in.
  final bool mine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? p.action : p.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? p.action : p.line),
          ),
          child: Row(children: [
            if (mine) ...[
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: selected ? p.surface : p.action,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
            ],
            Text(label,
                style: pvManrope(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? Colors.white : p.ink2)),
          ]),
        ),
      );
  }
}
