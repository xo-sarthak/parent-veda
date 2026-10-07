// =============================================================================
//  The father's top card on the parenting home (2026-10-07)
// -----------------------------------------------------------------------------
//  Gap analysis P1 (Behind · Partner): a paired father lands on the parenting
//  home after the birth, "with his own top card: '<Name> is 6 weeks. This
//  week, take one night feed so she sleeps 5 hours.'" Drawn only when
//  FatherPreview is on (a paired father, or the testing Mom|Dad switch). The
//  pages behind it are the Family door's "For fathers" area.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_child_profile.dart';
import 'pp_father_data.dart';

/// Surfaces the card opens (through the home's surface router).
const String kPpFatherPagesSurface = 'pp_section/parenting_family/fathers';
const String kPpFatherNightSurface = 'pp_page/parenting_family/fam_dad_night_shift';

class PpFatherCard extends StatelessWidget {
  const PpFatherCard({super.key, required this.p, required this.onSurface});
  final V2Palette p;
  final ValueChanged<String> onSurface;

  @override
  Widget build(BuildContext context) {
    final c = ChildProfileStore.instance;
    final weeks = c.ageInWeeks.floor();
    return Container(
      key: const ValueKey('pp_father_card'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('YOUR WEEK',
            style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.action)),
        const SizedBox(height: 6),
        Text(ppFatherAgeLine(c.name, weeks, c.ageInMonths),
            style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
        const SizedBox(height: 8),
        Text('This week, ${ppFatherJobFor(weeks)}.',
            style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink1)),
        const SizedBox(height: 4),
        _link('The night shift', kPpFatherNightSurface, const ValueKey('pp_father_night')),
        _link('All the pages for fathers', kPpFatherPagesSurface, const ValueKey('pp_father_pages')),
      ]),
    );
  }

  Widget _link(String label, String surface, Key key) => Material(
        color: Colors.transparent,
        child: InkWell(
          key: key,
          borderRadius: BorderRadius.circular(10),
          onTap: () => onSurface(surface),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Expanded(
                child: Text(label,
                    style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
              ),
              Icon(Icons.arrow_forward_rounded, size: 18, color: p.ink2),
            ]),
          ),
        ),
      );
}
