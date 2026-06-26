// =============================================================================
//  PvTabBar — the floating pill bottom navigation ("Warm Nest" / Direction B)
// -----------------------------------------------------------------------------
//  A detached, rounded white bar that floats above the content. The active tab
//  expands into a purple pill showing icon + label; inactive tabs are icon-only.
//  Mirrors the design's TabBarB. Used by MainScaffold.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

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
  });

  final List<PvTab> tabs;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x292D144C), // rgba(45,20,76,0.16)
                blurRadius: 28,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < tabs.length; i++) _item(i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i) {
    final active = i == activeIndex;
    final t = tabs[i];
    return GestureDetector(
      onTap: () => onChanged(i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
            horizontal: active ? 12 : 6, vertical: active ? 9 : 4),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary500 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        // Active = horizontal pill (icon + label). Inactive = icon with a small
        // label beneath, so the mother always knows what each tab is.
        child: active
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.icon, size: 21, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    t.label,
                    style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.icon, size: 20, color: AppTheme.neutral400),
                  const SizedBox(height: 2),
                  Text(
                    t.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neutral400,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
