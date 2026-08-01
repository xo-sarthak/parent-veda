// =============================================================================
//  WalletHomeScreen — one door, three rooms.
// -----------------------------------------------------------------------------
//  Explore → "Health" now opens this. Same arrangement as GrowHomeScreen, and
//  for the same reason: three Explore rows would make the versions feel like
//  three features and force a reviewer to compare from memory across
//  navigation.
//
//  V1 IS THE REAL SCREEN. `HealthHomeScreen()` is constructed here exactly as
//  Explore used to construct it — not reimplemented, so it cannot drift away
//  from what ships.
// =============================================================================

import 'package:flutter/material.dart';

// Kept: V1 is retired from the toggle but not from the app, and the commented
// branch below reinstates it in one line.
// ignore: unused_import
import 'health_home_screen.dart';
import 'pp_common.dart';
import 'pp_wallet_data.dart';
import 'wallet_v2_screens.dart';
import 'wallet_v3_screens.dart';

class WalletHomeScreen extends StatelessWidget {
  const WalletHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: WalletVersionStore.instance,
      builder: (context, _) {
        // V1 RETIRED FROM THE TOGGLE, 2026-08-01, at the user's call: the
        // comparison against what ships has been made and the two proposals
        // are what is being looked at now.
        //
        // Kept for revert, and the screen itself is untouched on disk — the
        // Explore row that opened it directly is still commented in place, so
        // putting V1 back is these two lines plus the default below.
        //
        //   WalletVersion.v1 => const HealthHomeScreen(),
        //
        // The wildcard rather than a v1 case: WalletVersion.v1 still exists in
        // the enum (removing it would be a rewrite of the store, the pill and
        // every test), so something has to answer for it. Falling through to
        // V2 is right — it is the default now.
        final body = switch (WalletVersionStore.instance.version) {
          WalletVersion.v3 => const WalletV3Home(),
          _ => const WalletV2Home(),
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
                  WalletVersionPill(),
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

class _VersionCaption extends StatelessWidget {
  const _VersionCaption();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: WalletVersionStore.instance,
        builder: (_, _) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ppHair),
          ),
          child: Text(WalletVersionStore.instance.label,
              style: ppBody(10, color: ppMuted, w: FontWeight.w700)),
        ),
      );
}
