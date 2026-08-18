// =============================================================================
//  PvNavBar — ONE bottom bar, for all three stages
// -----------------------------------------------------------------------------
//  ⚠️ THIS EXISTS BECAUSE THE APP HAD THREE, AND EACH HAD A DIFFERENT HALF OF
//  THE SAME FIX.
//
//  Audited 2026-08-17:
//
//    PvTabBar     (pregnancy)  layout shifted on tap · container removed
//    PpBottomNav  (parenting)  layout fixed          · filled disc remained
//    TtcBottomNav (TTC)        layout shifted on tap · filled pill remained
//
//  Not one of the three had both. Each had been fixed once, by a different pass,
//  and the code said so: "PARENTING ONLY. The pregnancy bar is deliberately
//  untouched." Every future fix would have diverged the same way.
//
//  A component on every screen of every stage cannot be three components. So
//  the three now delegate here and differ only in their tabs and their accent.
//
//  ---------------------------------------------------------------------------
//  THE RULES IT ENFORCES, and where each came from
//  ---------------------------------------------------------------------------
//
//  ⚠️ 1. NOTHING MOVES WHEN YOU SWITCH TABS.
//  Every tab is icon-above-label, always, active or not. Two of the three bars
//  used to make the active tab a horizontal pill — icon and label side by side —
//  so selecting a tab re-flowed the whole row and the other four labels slid
//  sideways. The bar never sat still. The parenting bar's own comment had
//  already diagnosed this and the fix was never carried across.
//
//  ⚠️ 2. NO CONTAINER BEHIND THE ACTIVE TAB.
//  DESIGN-SYSTEM.md §4.9 / UX-PRINCIPLES.md §4.3. Not because a video said so —
//  Material 3 ships a pill and it is perfectly good design — but for two
//  reasons of our own: our labels are ALWAYS visible, so the label already says
//  which tab she is on and colour says it again, making a container a redundant
//  third signal; and `action` is the only saturated colour this app spends, so a
//  filled violet shape parked on every screen at all times spends that meaning
//  down to nothing.
//
//  ⚠️ 3. THE INACTIVE LABEL MUST BE READABLE.
//  It was `neutral400` — 2.73:1 against the app ground, when WCAG AA asks 4.5:1.
//  The most-seen text in the entire app was at well under half the required
//  contrast. It is `neutral600` now: 5.28:1.
//
//  4. Two changes mark the active tab — colour AND weight — never one.
//  5. Labels never hide, never wrap, and never go below 11px.
//  6. The bar floats on a tinted shadow, so it is distinct from the page
//     without a hard border.
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/pv_fonts.dart';

class PvNavItem {
  const PvNavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

class PvNavBar extends StatelessWidget {
  const PvNavBar({
    super.key,
    required this.items,
    required this.activeIndex,
    required this.onTap,
    this.accent,
    this.inactive,
    this.labelStyle,
  });

  final List<PvNavItem> items;
  final int activeIndex;
  final ValueChanged<int> onTap;

  /// The stage's own accent. Defaults to the brand violet; the father shell and
  /// the TTC partner view pass their slate.
  final Color? accent;

  /// Override for the idle ink. Defaults to `neutral600`, which is the lightest
  /// value in the ramp that passes AA on our ground — do not lighten it.
  final Color? inactive;

  /// Lets a stage keep its own font helper (TTC and parenting have theirs).
  final TextStyle Function(double size, {Color color, FontWeight w})? labelStyle;

  @override
  Widget build(BuildContext context) {
    final on = accent ?? AppTheme.primary600;
    final off = inactive ?? AppTheme.neutral600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          // Tinted, not black — DESIGN-SYSTEM.md §2.5.
          BoxShadow(
            color: Color(0x292D144C),
            blurRadius: 28,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) _item(i, on, off),
        ],
      ),
    );
  }

  Widget _item(int i, Color on, Color off) {
    final active = i == activeIndex;
    final it = items[i];
    final ink = active ? on : off;

    // ⚠️ EVERY TAB IS `Expanded`, so the row shares its width evenly and cannot
    // overflow however large the user's text scale is. A five-tab bar that
    // overflows at 1.3x scale is a crash for someone who needs bigger type —
    // which is exactly the person who set it.
    return Expanded(
      child: GestureDetector(
        onTap: () => activeIndex == i ? null : onTap(i),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The transition is a COLOUR crossfade and nothing else. Because
              // the layout is identical in both states there is no geometry to
              // animate, which is why it now feels settled rather than springy.
              TweenAnimationBuilder<Color?>(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                tween: ColorTween(end: ink),
                builder: (_, c, _) => Icon(it.icon, size: 22, color: c),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                style: labelStyle != null
                    ? labelStyle!(11,
                        color: ink,
                        w: active ? FontWeight.w800 : FontWeight.w600)
                    : pvManrope(
                        fontSize: 11,
                        color: ink,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      ),
                child: Text(
                  it.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
