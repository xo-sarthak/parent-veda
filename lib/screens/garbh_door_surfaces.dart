// =============================================================================
//  Garbh Sanskar — the one surface the door needed that no pillar had
// -----------------------------------------------------------------------------
//  Everything else on the Garbh Sanskar door opens a screen that already
//  existed. This file holds the one widget that did not: the "Your own
//  practice" rail on the Today tab, which has to READ A STORE — whichever
//  rituals she picked in `GarbhRitualScreen` — and a door page is data built
//  once. See `PvDoorSection.inline` for the engine side.
//
//  ⚠️ A RAIL, IN THE DOOR'S OWN CARD. The symmetry test counts one horizontal
//  `ListView` per section on every tab and does not know this section is
//  special, which is the point. `PvDoorRailCard` is the card every other rail
//  draws; the same height, the same gutter.
//
//  ⚠️ THE PICKER CARD IS ALWAYS FIRST, PICKED OR NOT. "A feature is never
//  hidden": with nothing picked the rail is one card — the invitation — and
//  with three picked it is four. Nothing about the rail's shape depends on
//  her answer except its length.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/doors/pv_door_garbh.dart';
import '../data/garbh_rebuild_data.dart';
import '../services/pregnancy_controller.dart';
import 'doors/pv_door_chrome.dart';
import 'doors/pv_door_router.dart' show openPvDoorSurface;
import 'v2/v2_palette.dart';

/// "Do you already have a daily practice?", then each ritual she picked.
class GarbhRitualRail extends StatelessWidget {
  const GarbhRitualRail({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final store = GarbhJournalStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        // In the library's order, not the order she picked them — a set has
        // no order, and a rail that reshuffled between visits would read as
        // a bug.
        final picked = [
          for (final r in kGarbhRituals)
            if (store.hasRitual(r.id)) r,
        ];
        return SizedBox(
          height: kPvRailCardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
            itemCount: picked.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: kPvRailGap),
            itemBuilder: (context, i) {
              if (i == 0) {
                return PvDoorRailCard(
                  key: const ValueKey('garbh_ritual_picker'),
                  p: p,
                  hue: 42,
                  icon: Icons.tune_rounded,
                  chip: 'Tool',
                  title: picked.isEmpty
                      ? 'Do you already have a daily practice?'
                      : 'Change what you do daily',
                  meta: picked.isEmpty ? null : '${picked.length} PICKED',
                  index: 0,
                  onTap: () => openPvDoorSurface(
                      context, kGarbhSurfaceRitual, pregnancy),
                );
              }
              final r = picked[i - 1];
              return PvDoorRailCard(
                key: ValueKey('garbh_ritual_${r.id}'),
                p: p,
                hue: 42,
                icon: r.hasCounter
                    ? Icons.radio_button_checked_rounded
                    : Icons.auto_awesome_outlined,
                chip: 'Tool',
                title: r.name.en,
                meta: r.planWeeks > 0 ? '${r.planWeeks}-WEEK PLAN' : 'DAILY',
                index: i,
                onTap: () =>
                    openPvDoorSurface(context, kGarbhSurfaceRitual, pregnancy),
              );
            },
          ),
        );
      },
    );
  }
}
