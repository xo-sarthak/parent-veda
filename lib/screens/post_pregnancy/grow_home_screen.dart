// =============================================================================
//  GrowHomeScreen — the one door, with three rooms behind it.
// -----------------------------------------------------------------------------
//  Explore → "Skill Development" now opens THIS, and this decides which of the
//  three versions is on screen. The old row is commented in place in
//  explore_drawer.dart rather than removed, so reverting is one line.
//
//  WHY A WRAPPER RATHER THAN THREE ENTRIES IN EXPLORE. Three rows would make
//  the versions feel like three features, and a reviewer would compare them by
//  memory across navigation. One row with a pill means the switch happens
//  where the difference is — same door, same scroll position in your head,
//  swap the room.
//
//  V1 IS THE REAL SCREEN, NOT A COPY. `DevelopmentHomeScreen()` is constructed
//  here exactly as Explore used to construct it. That matters more than it
//  looks: a reimplementation of V1 would drift the moment anyone touched it,
//  and then the comparison would be against something that never shipped.
//
//  The pill floats in a Stack rather than being pushed into each version's
//  header, for the same reason — V1 gets a pill without a single line of V1
//  changing.
// =============================================================================

import 'package:flutter/material.dart';

import 'development_home_screen.dart';
import 'grow_v2_screens.dart';
import 'grow_v3_screens.dart';
import 'pp_common.dart';
import 'pp_grow_data.dart';

class GrowHomeScreen extends StatelessWidget {
  const GrowHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GrowVersionStore.instance,
      builder: (context, _) {
        final v = GrowVersionStore.instance.version;
        final body = switch (v) {
          // The screen that ships today, opened as-is. Do not replace this with
          // a copy.
          GrowVersion.v1 => const DevelopmentHomeScreen(),
          GrowVersion.v2 => const GrowV2Home(),
          GrowVersion.v3 => const GrowV3Home(),
        };
        return Stack(
          children: [
            Positioned.fill(child: body),
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 18,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GrowVersionPill(),
                  SizedBox(height: 6),
                  _VersionCaption(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The one-line description under the pill, so a reviewer never has to
/// remember which number means what.
class _VersionCaption extends StatelessWidget {
  const _VersionCaption();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: GrowVersionStore.instance,
        builder: (_, _) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ppHair),
          ),
          child: Text(GrowVersionStore.instance.label,
              style: ppBody(10, color: ppMuted, w: FontWeight.w700)),
        ),
      );
}
