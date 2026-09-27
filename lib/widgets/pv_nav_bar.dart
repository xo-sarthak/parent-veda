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
//     ⚠️ ONE EXCEPTION, 2026-09-16: a label the AUTHOR breaks with a newline is
//     drawn on two lines at 9.5px. The rule was against the LAYOUT deciding
//     where a word breaks — a five-tab bar that wraps differently at every text
//     scale never sits still. A break placed by hand is stable, so it keeps
//     the guarantee the rule exists for. It was needed for the parenting bar's
//     "Brain activities" (the review asked for that exact wording), which at
//     11px is ~96dp wide on a ~69dp tab — an ellipsis would have shown "Brain
//     acti…", which is worse than two small lines.
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
    this.onReselect,
    this.accent,
    this.inactive,
    this.labelStyle,
  });

  final List<PvNavItem> items;
  final int activeIndex;
  final ValueChanged<int> onTap;

  /// A tap on the tab that is already lit. Null (the default, and every stage
  /// but TTC) keeps the old behaviour: nothing happens. TTC passes one
  /// (2026-09-27) because a page pushed from Today, the calendar, lights
  /// Today, and a tap there must take her home rather than do nothing; on the
  /// home itself it scrolls back to the top, as most apps do.
  final ValueChanged<int>? onReselect;

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
    // See rule 5 above: only an explicit newline gets two lines.
    final twoLine = it.label.contains('\n');
    final size = twoLine ? 9.5 : 11.0;

    // ⚠️ EVERY TAB IS `Expanded`, so the row shares its width evenly and cannot
    // overflow however large the user's text scale is. A five-tab bar that
    // overflows at 1.3x scale is a crash for someone who needs bigger type —
    // which is exactly the person who set it.
    return Expanded(
      child: GestureDetector(
        // Kept for revert: onTap: () => activeIndex == i ? null : onTap(i),
        onTap: () => activeIndex == i ? onReselect?.call(i) : onTap(i),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          // A two-line label is drawn 9.5px + 9.5px ≈ the height of one 11px
          // line plus ~5dp; the top padding gives that back so the ICON of a
          // two-line tab still sits level with its neighbours. Nothing moves
          // between tabs, which is rule 1.
          padding: EdgeInsets.fromLTRB(0, 2, 0, twoLine ? 0 : 2),
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
                style: (labelStyle != null
                        ? labelStyle!(size,
                            color: ink,
                            w: active ? FontWeight.w800 : FontWeight.w600)
                        : pvManrope(
                            fontSize: size,
                            color: ink,
                            fontWeight:
                                active ? FontWeight.w800 : FontWeight.w600,
                          ))
                    .copyWith(height: twoLine ? 1.15 : null),
                child: Text(
                  it.label,
                  maxLines: twoLine ? 2 : 1,
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

// =============================================================================
//  Clearance for anything that floats above the tab bar
// -----------------------------------------------------------------------------
//  ⚠️ THE BUG THIS FIXES: every floating control in the app was pinned at a
//  hardcoded `bottom: 96`, and on a real phone the version toggle sat BEHIND
//  the navigation bar. Reported as "the toggle to switch to version 3 is not
//  visible, it's behind the navigation bar at the bottom."
//
//  96 was not a wrong guess, it was a guess that only held on one device. The
//  bar does not sit at the bottom of the screen — it sits above the SYSTEM
//  inset, and that inset is not a constant:
//
//      gesture navigation   ~24dp
//      three-button nav     ~48dp
//      no software nav       0dp
//
//  So the bar's top edge lands anywhere between 77 and 125 from the bottom of
//  the stack, and a control pinned at 96 is comfortably clear on one handset
//  and half-swallowed on the next. Nothing errors, nothing overflows; the
//  control is simply painted underneath an opaque white pill.
//
//  ⚠️ IT IS ALSO A PAINT-ORDER TRAP, and the two stages behave differently.
//  In `main_scaffold` the pill is a sibling of the bar and drawn after it, so
//  the overlap merely looks wrong. In parenting and TTC the pill lives INSIDE
//  the page, which the floating bar is drawn on top of — so there the overlap
//  genuinely hides it. Same offset, two different symptoms, which is why this
//  was easy to look at and not see.
//
//  The measurements below mirror `PvNavBar.build` and `PvTabBar.build` exactly.
//  If either changes its padding, change it here — they are one component's
//  geometry described in two places, and that is the cost of not being able to
//  measure a widget that has not been laid out yet.
// =============================================================================

/// Height of the bar itself: icon 22 + gap 3 + an 11pt label line, inside the
/// item's 2dp and the container's 10dp vertical padding.
const double _kNavBarHeight = 22 + 3 + 15 + (2 * 2) + (10 * 2);

/// The gap `PvTabBar` leaves under the bar (18 since 2026-09-16, matching
/// the parenting home's placement).
const double _kNavBarBottomInset = 18;

/// The distance from the bottom of a full-screen `Stack` at which a floating
/// control clears the tab bar, on THIS device.
///
/// Use it instead of a literal for anything in the bottom strip — version
/// pills, testing toggles, an Ask FAB.
///
/// [gap] is the breathing room above the bar.
///
/// ⚠️ THE DEFAULT IS DELIBERATELY GENEROUS, because a tight one was still
/// reported as hidden on a real device after the inset maths was corrected.
/// The remaining variables are ones this helper cannot see from here — a
/// larger text scale grows the bar's label line, and the shadow under the bar
/// extends past its box. Rather than keep chasing a number that must be exactly
/// right, this clears the bar by an obvious margin: the pill is testing chrome
/// that comes out before launch, so sitting a little high costs nothing and
/// being invisible costs a build.
///
/// ⚠️ `viewPadding`, NOT `padding`. `MediaQuery.padding` collapses to zero once
/// an ancestor `SafeArea` has consumed the inset, so a control inside one would
/// compute a clearance that ignores the system bar entirely — which is the
/// original bug with extra steps. `viewPadding` reports the physical inset
/// whoever else has already handled it.
double pvNavClearance(BuildContext context, {double gap = 78}) =>
    MediaQuery.of(context).viewPadding.bottom +
    _kNavBarBottomInset +
    _kNavBarHeight +
    gap;
