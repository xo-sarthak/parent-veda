// =============================================================================
//  TtcTabRootHeader: one header for the tab roots of Trying to Conceive
//  (2026-09-29, build 19)
// -----------------------------------------------------------------------------
//  The user: "If you click on Tools from the bottom navigation, you can see
//  the header of Tools aligned at the very top. But when you see the same
//  thing for Learn, it's not aligned at that very top." And, asked which one
//  was right: "More feels in the middle, Tools at the very top, Learn a little
//  lower. I would say the Learn header is the optimal."
//
//  ⚠️ THE MECHANISM, measured in the tab host at 360x800 with a 24dp status
//  bar (test/ttc_tab_root_header_test.dart holds the after):
//
//    tab       title top   what put it there
//    Learn     40.5        inset 12, then a 42dp row (the bookmark circle)
//                          with the 33dp title CENTRED in it: +4.5
//    Tools     36.0        inset 12, a row with NO circle on V3, so the row
//                          was only as tall as the title: +0
//    More      38.0        its own inset of 14, no row at all
//    Products  (none)      no title; a search pill at inset 14
//
//  Three screens each wrote "safe area + a number" by hand, and the row
//  height depended on whether a button happened to sit beside the title. So
//  the title's y was a side effect of the trailing button, which is why no
//  one number fixed it. The fix is to make the row a FIXED height whether or
//  not anything sits in it, and to make that row one widget.
//
//  THE SPEC (Learn's geometry, the one the user chose):
//    · top: the safe area + 12 (`kTtcTabRootTopInset`)
//    · a title row at least 42dp tall (`kTtcTabRootRowHeight`), the title
//      centred in it, trailing round buttons 42dp on its right, 8 apart
//    · the title: our serif (pvFraunces) 30, w500, height 1.1, ink 1
//    · the intro line 6 below the row: Manrope 14, height 1.45, ink 2
//    · the first content (the search) 14 below the intro
//
//  WHY A FIXED POSITION, from Mobbin (2026-09-29): well-made apps put every
//  tab root's title at one place, and buttons beside it never move it.
//    * Apple Photos, Library and Collections: the same large title at the
//      same y, with and without round buttons on the right.
//      https://mobbin.com/screens/3d260ff3-f34a-4648-b16d-f2757e5f9858
//      https://mobbin.com/screens/346f497b-ea50-4f95-9ffb-1ad3c23a9b70
//    * Apple Health, Summary: large title, the avatar centred on its line.
//      https://mobbin.com/screens/1a54ec87-6f51-416b-977b-663a1e7a2684
//    * Apple TV, Library: the same, title left, avatar right, one line.
//      https://mobbin.com/screens/448c2f12-10ab-4115-9b79-c6be76c8e0f3
//    * Airbnb, Wishlists: a large title at a fixed place under the bar.
//      https://mobbin.com/screens/472e14de-22dd-4190-87df-1ed4a2e8d771
//    * Revolut: every tab (Home, Invest, Payments, Crypto, Lifestyle) opens
//      on the SAME top row at the same y; only what is under it changes.
//      https://mobbin.com/screens/0582a39e-955b-4b24-9b76-57129bc61544
//      https://mobbin.com/screens/1da27e42-6bbf-4ae5-9c01-027229ef9cf5
//      https://mobbin.com/screens/20880c9f-c172-4660-8867-7166b5a5257c
//    * Flo, Insights: the search row sits where Today's date row sits.
//      https://mobbin.com/screens/3fba06c7-b554-46cd-9487-ae5e74721a32
//  Headspace's Explore opens on a search field with no title
//  (https://mobbin.com/screens/22b861df-e8d9-4284-a4f9-a25dc6c6dbcc), which
//  is what our Products did; it was not taken, because on our other three
//  tabs the title is how she knows which tab she is on.
//
//  Today keeps its own hero, by design. This header is for the other four.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../products/pv_store_chrome.dart' show pvStorePalette;

/// From the safe area to the top of the title row.
const double kTtcTabRootTopInset = 12;

/// The title row's height, with or without buttons in it. A trailing round
/// button is this size, so a button never makes the row taller.
const double kTtcTabRootRowHeight = 42;

/// Between the title row and the intro line.
const double kTtcTabRootIntroGap = 6;

/// Between the intro (or the row, when there is no intro) and [below].
const double kTtcTabRootBelowGap = 14;

/// The stage's side gutter (the doors, the TTC chrome, Learn and Tools).
const double kTtcTabRootGutter = 18;

/// The title, for tests that find it.
const Key kTtcTabRootTitleKey = ValueKey('ttc_tab_root_title');

/// The one title style of a tab root.
TextStyle ttcTabRootTitleStyle() => pvFraunces(
      fontSize: 30,
      fontWeight: FontWeight.w500,
      height: 1.1,
      color: pvStorePalette.ink1,
    );

/// The one intro-line style of a tab root: what the page is, in a sentence.
TextStyle ttcTabRootIntroStyle() =>
    pvManrope(fontSize: 14, height: 1.45, color: pvStorePalette.ink2);

/// The header of a TTC tab root: title (with round buttons on its right),
/// an optional intro line, and an optional first content such as a search.
///
/// It carries the safe-area inset itself, so the page puts it first with no
/// top padding of its own. The page's own content goes below it.
class TtcTabRootHeader extends StatelessWidget {
  const TtcTabRootHeader({
    super.key,
    required this.title,
    this.trailing = const [],
    this.intro,
    this.below,
    this.gutter = kTtcTabRootGutter,
  });

  final String title;

  /// Round buttons beside the title, each [kTtcTabRootRowHeight] tall.
  final List<Widget> trailing;

  /// The one line under the title. Style it with [ttcTabRootIntroStyle].
  final Widget? intro;

  /// The first content, [kTtcTabRootBelowGap] under the intro (the search).
  final Widget? below;

  /// The page's side gutter. The title's y never depends on it; a page whose
  /// content sits on another edge passes that edge so the header lines up
  /// with what is under it.
  final double gutter;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + kTtcTabRootTopInset;
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter, top, gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints:
                const BoxConstraints(minHeight: kTtcTabRootRowHeight),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    // ONE LINE, always: a title that wrapped would make its
                    // row taller and move everything under it, which is the
                    // bug this widget exists to stop. The four titles are one
                    // word each and fit at 1.5x text on a 360dp phone beside
                    // three buttons; only far larger text truncates, as
                    // iOS's large titles do.
                    child: Text(
                      title,
                      key: kTtcTabRootTitleKey,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: ttcTabRootTitleStyle(),
                    ),
                  ),
                ),
                for (var i = 0; i < trailing.length; i++) ...[
                  SizedBox(width: i == 0 ? 10 : 8),
                  trailing[i],
                ],
              ],
            ),
          ),
          if (intro != null) ...[
            const SizedBox(height: kTtcTabRootIntroGap),
            intro!,
          ],
          if (below != null) ...[
            const SizedBox(height: kTtcTabRootBelowGap),
            below!,
          ],
        ],
      ),
    );
  }
}
