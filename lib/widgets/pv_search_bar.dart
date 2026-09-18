// =============================================================================
//  PvSearchBar — the search entry, drawn as a field, working as a button
// -----------------------------------------------------------------------------
//  Where search sits was decided on Mobbin, 2026-09-18 (BASE-UI-DECISIONS
//  §2.9). The "bar at the bottom" that is in fashion is a SEARCH-SCREEN
//  pattern — iOS 26 drops the field onto the keyboard once you are already
//  searching (Apple Games, Podcasts, Linear, Wabi). The ENTRY to search, on
//  a page that is about something else, is still at the top in every app
//  that has one: Flo puts a field under the heading of a topic page and in
//  the app bar of its browse tab; Superpower under its heading; CVS, Bloom,
//  Yazio at the top of the search screen itself. So: the entry lives up
//  where the page starts, and the field the user types into is the first
//  thing on the search screen.
//
//  This is that entry. It looks like a field and behaves like a button — a
//  tap opens `PvSearchScreen`, whose own field takes focus. No keyboard on
//  the home, no focus ring on a page that is not a form (App Store, Flo).
//
//  ⚠️ NO VIOLET, AT REST OR ON TAP. The user (2026-09-18): "search bars
//  across the app look gross to me due to that purple thing in them,
//  especially when tapped." White fill, the page hairline, a grey lens, ink
//  words. The press is the shared `PvPress` scale, not a colour.
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/v2/v2_palette.dart';
import '../theme/pv_fonts.dart';
import 'pv_feedback.dart';

const Key kPvSearchBarKey = ValueKey('pv-search-bar');

class PvSearchBar extends StatelessWidget {
  const PvSearchBar({
    super.key,
    required this.hint,
    required this.p,
    required this.onTap,
  });

  final String hint;
  final V2Palette p;
  final VoidCallback onTap;

  static const double height = 48;

  @override
  Widget build(BuildContext context) {
    return PvPress(
      child: Semantics(
        button: true,
        label: hint,
        child: Material(
          key: kPvSearchBarKey,
          color: p.surface,
          shape: StadiumBorder(side: BorderSide(color: p.line)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              pvCommitFeedback();
              onTap();
            },
            child: SizedBox(
              height: height,
              child: Row(children: [
                const SizedBox(width: 16),
                Icon(Icons.search_rounded, size: 21, color: p.ink3),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: p.ink3)),
                ),
                const SizedBox(width: 16),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
