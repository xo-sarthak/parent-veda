// =============================================================================
//  PvDoorChips — the door's group selector as one line of chips
// -----------------------------------------------------------------------------
//  The alternative to the deck (`PvDoorCarousel`), built 2026-09-18 for the
//  user to compare on the Scans & tests door (BASE-UI-DECISIONS §2.8). The
//  deck is the app's signature and costs ~170pt under a hero that already
//  takes two-fifths of the screen; every app in the Mobbin set that puts a
//  selector ABOVE content (Gymshark Workouts / Plans / Creators, DAZN Teams /
//  Standings, Waking Up Practice / Theory / Life) uses a scrolling row of
//  chips at ~44pt and gives the height to the content.
//
//  The chip is the design system's chip (DESIGN-SYSTEM §4.0: hairline pill,
//  ink fill with a white label when selected — Etsy's filters) with the
//  group's line icon before the label (Zocdoc's specialty chips). No count on
//  the chip — none of the set puts one there; the count belongs to the
//  content it selects. Selection presses (PvPress) and hums; the row scrolls
//  the selected chip into view.
//
//  Same contract as the deck — `groups`, `counts`, `selected`, `onPick` — so
//  a door swaps one for the other with a flag and nothing else changes.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/doors/pv_door_data.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../v2/v2_palette.dart';
import 'pv_door_chrome.dart';

/// The row, and the chip for tab [i] — what a test taps to reach a tab on a
/// door that uses chips (the deck's `pvDoorDotKey` is the other route).
const Key kPvDoorChipsKey = ValueKey('pv-door-chips');
Key pvDoorChipKey(int i) => ValueKey('pv-door-chip-$i');

class PvDoorChips extends StatefulWidget {
  const PvDoorChips({
    super.key,
    required this.groups,
    required this.counts,
    required this.selected,
    required this.p,
    required this.onPick,
  });

  final List<PvDoorGroup> groups;
  final List<String> counts;
  final int selected;
  final V2Palette p;
  final ValueChanged<int> onPick;

  /// The row's height, for anything that lays out around it.
  static const double height = 44;

  @override
  State<PvDoorChips> createState() => _PvDoorChipsState();
}

class _PvDoorChipsState extends State<PvDoorChips> {
  final _keys = <int, GlobalKey>{};

  @override
  void didUpdateWidget(PvDoorChips old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) _reveal();
  }

  void _reveal() {
    final ctx = _keys[widget.selected]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        alignment: 0.5,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    // A plain scrolling Row, not a lazy list: five chips are cheap, and every
    // chip existing at once is what lets the row scroll the selected one
    // into view (and a test reach any tab) on a narrow screen.
    return SizedBox(
      key: kPvDoorChipsKey,
      height: PvDoorChips.height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
        child: Row(children: [
          for (var i = 0; i < widget.groups.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _chip(i, p),
          ],
        ]),
      ),
    );
  }

  Widget _chip(int i, V2Palette p) {
    final g = widget.groups[i];
    final on = i == widget.selected;
    return PvPress(
      key: pvDoorChipKey(i),
      child: InkWell(
        key: _keys.putIfAbsent(i, () => GlobalKey()),
        onTap: () {
          if (on) return;
          pvCommitFeedback();
          widget.onPick(i);
        },
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          height: PvDoorChips.height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: on ? p.ink1 : p.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: on ? p.ink1 : p.line, width: 1.2),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(g.icon, size: 16, color: on ? p.surface : p.ink2),
            const SizedBox(width: 7),
            Text(g.label,
                style: pvManrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: on ? p.surface : p.ink1)),
          ]),
        ),
      ),
    );
  }
}
