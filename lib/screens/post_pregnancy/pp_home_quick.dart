// =============================================================================
//  PpHomeQuick — search, and the last feed and sleep, on the parenting home
// -----------------------------------------------------------------------------
//  Parenting gap analysis, P1 (Behind · Home & daily, 2026-10-02):
//    * "Under the hero, for a child under one: 'Last feed 2h 10m ago · Left'
//      and 'Awake for 1h 05m', each a tap to log. Hide it after the first
//      birthday, as What to Expect does."
//    * "A search field: 'Search sleep, rashes, food, anything'."
//  The idea and its place on the home are the fork's (CognihabRepo/
//  parent-veda-fork a79a9a4, `PpHomeQuick`); this is written fresh to the gap
//  analysis's own lines, in the one ink (no violet icons), with the search
//  opening the parenting search (pp_search.dart).
//
//  Mobbin: the search pill is the door heroes' white pill (the shared search
//  look); the two halves are Oura's "readiness / sleep" pair of plain numbers.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_breast_timer_screen.dart' show ppLastSideLine;
import 'pp_care_parts.dart';
import 'pp_child_profile.dart';
import 'pp_feeding_data.dart';
import 'pp_sleep_data.dart';
import '../ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import '../ttc/ttc_tool_marks.dart' show TtcMarkLeading;

/// "1h 05m" from minutes.
String _hm(int mins) {
  final h = mins ~/ 60;
  final m = mins % 60;
  return h == 0 ? '${m}m' : '${h}h ${m.toString().padLeft(2, '0')}m';
}

class PpHomeQuick extends StatelessWidget {
  const PpHomeQuick({super.key, required this.p, required this.onSurface});
  final V2Palette p;
  final void Function(String surfaceId) onSurface;

  @override
  Widget build(BuildContext context) {
    FeedingStore.instance.init();
    SleepStore.instance.init();
    return ListenableBuilder(
      listenable: Listenable.merge([FeedingStore.instance, SleepStore.instance, ChildProfileStore.instance]),
      builder: (context, _) {
        final showCare = ChildProfileStore.instance.ageInMonths < 12;
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _search(),
          if (showCare) ...[
            const SizedBox(height: 12),
            _care(),
          ],
        ]);
      },
    );
  }

  Widget _search() => Semantics(
        button: true,
        label: 'Search sleep, rashes, food, anything',
        excludeSemantics: true,
        child: Material(
          color: Colors.white,
          shape: StadiumBorder(side: BorderSide(color: p.line)),
          child: InkWell(
            key: const ValueKey('pp_home_search'),
            customBorder: const StadiumBorder(),
            onTap: () => onSurface('pp_search'),
            child: SizedBox(
              height: 48,
              child: Row(children: [
                const SizedBox(width: 16),
                Icon(Icons.search_rounded, size: 20, color: p.ink2),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Search sleep, rashes, food, anything',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 14, color: p.ink2)), // the home's body size (2026-10-07); was 14.5
                ),
                const SizedBox(width: 16),
              ]),
            ),
          ),
        ),
      );

  Widget _care() {
    final feed = FeedingStore.instance.last;
    final wake = SleepStore.instance.currentWakeMinutes;
    final side = ppLastSideLine();
    // "Last side: Left, 1h 40m ago" -> "Left", for the compact line.
    final sideWord = side?.substring('Last side: '.length).split(',').first;
    final feedLine = feed == null
        ? 'Log a feed'
        : 'Last feed ${ppCareAgo(feed.time)}${feed.kind == FeedKind.breast && sideWord != null ? ' · $sideWord' : ''}';
    final sleepLine = wake == null ? 'Log a sleep' : 'Awake for ${_hm(wake)}';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      ),
      child: IntrinsicHeight(
        child: Row(children: [
          _half('pp_home_quick_feed', TtcTabMark.hotBottle, 206, feedLine, 'pp_feeding'),
          VerticalDivider(width: 1, thickness: 1, color: p.line, indent: 10, endIndent: 10),
          _half('pp_home_quick_sleep', TtcTabMark.sunrise, 268, sleepLine, 'pp_sleep'),
        ]),
      ),
    );
  }

  // The TTC drawn marks (2026-10-07). Kept for revert: an IconData, drawn as
  // Icon(icon, size: 18, color: p.ink1).
  Widget _half(String key, TtcTabMark mark, double hue, String text, String surface) => Expanded(
        child: InkWell(
          key: ValueKey(key),
          borderRadius: BorderRadius.circular(16),
          onTap: () => onSurface(surface),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(children: [
              TtcMarkLeading(tab: mark, tint: v2BlockTint(hue, p), size: 30),
              const SizedBox(width: 8),
              Expanded(
                child: Text(text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, height: 1.3, color: p.ink1)), // was 13.5 (2026-10-07)
              ),
            ]),
          ),
        ),
      );
}

// ---- the feed and sleep lines, for the insight rail (2026-10-07) -------------
//  The user: "no need for search bar in homescreen parenting, and log a feed
//  and log a sleep can be moved in daily insight as a part of rail". The same
//  words `_care` draws, as functions, so the rail and the (kept) card can never
//  disagree. Under one only, as before.

/// Whether the feed and sleep tiles belong on the home (under one).
bool ppHomeShowCareTiles() => ChildProfileStore.instance.ageInMonths < 12;

/// "Log a feed", or "Last feed 1h 40m ago · Left".
String ppHomeFeedLine() {
  final feed = FeedingStore.instance.last;
  final side = ppLastSideLine();
  final sideWord = side?.substring('Last side: '.length).split(',').first;
  return feed == null
      ? 'Log the last feed' // over 12 letters: the tip size, not the big one
      : 'Last feed ${ppCareAgo(feed.time)}${feed.kind == FeedKind.breast && sideWord != null ? ' · $sideWord' : ''}';
}

/// "Log a sleep", or "Awake for 1h 10m".
String ppHomeSleepLine() {
  final wake = SleepStore.instance.currentWakeMinutes;
  return wake == null ? 'Log the last sleep' : 'Awake for ${_hm(wake)}';
}
