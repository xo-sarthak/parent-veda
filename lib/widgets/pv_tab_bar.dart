// =============================================================================
//  PvTabBar - the floating pill bottom navigation ("Warm Nest" / Direction B)
// -----------------------------------------------------------------------------
//  A detached, rounded white bar that floats above the content. The active tab
//  expands into a purple pill showing icon + label; inactive tabs are icon-only.
//  Mirrors the design's TabBarB. Used by MainScaffold.
// =============================================================================

import 'package:flutter/material.dart';
import 'pv_nav_bar.dart';

class PvTab {
  const PvTab(this.icon, this.label);
  final IconData icon;
  final String label;
}

class PvTabBar extends StatelessWidget {
  const PvTabBar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onChanged,
    this.father = false,
  });

  final List<PvTab> tabs;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  /// In Dad (father-preview) mode the bar takes the father Slate palette.
  final bool father;

  // Father (Slate) accents - mirror the Father Daily / father_skin palette.
  static const Color _fAccent = Color(0xFF2E5266);
  static const Color _fMuted = Color(0xFF6A7B82);

  // ⚠️ THIS IS NOW A THIN ADAPTER OVER `PvNavBar`, AND EVERY RULE LIVES THERE.
  //
  // It used to draw its own bar, and so did parenting's and TTC's — three
  // implementations of the component that appears on every screen of the app.
  // Each had been half-fixed by a different pass: this one had its filled pill
  // removed but still re-flowed the row on every tap; parenting had the reflow
  // fixed but kept a filled disc; TTC had neither.
  //
  // Keeping the class name means no call site had to change.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
        child: PvNavBar(
          items: [for (final t in tabs) PvNavItem(t.icon, t.label)],
          activeIndex: activeIndex,
          onTap: onChanged,
          accent: father ? _fAccent : null,
          inactive: father ? _fMuted : null,
        ),
      ),
    );
  }
}
