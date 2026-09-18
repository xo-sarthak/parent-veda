// =============================================================================
//  PvDoorTiles — the door's group selector as a row of tiles
// -----------------------------------------------------------------------------
//  The third and, by the evidence, the right form for the selector under a
//  door hero (2026-09-18, after the deck and the chip row — BASE-UI-DECISIONS
//  §2.8). The user found it himself on Mobbin: every category selector at
//  scale — DoorDash, Skip, Glovo, Grab, Instacart, Careem, Baemin — is a row
//  of ICON TILES WITH A LABEL BENEATH, every option visible at once, one tap
//  to switch, no swipe, no hidden tabs. It is also the shape of this app's
//  own V3 home grid ("Start anywhere"), which the user likes, so a door's
//  tabs read as the same object as the doors themselves.
//
//  The tile is the home's tile at a smaller size: the group's tint as a soft
//  square well (radius 14), the group's DRAWN mark inside it (`HubIntentArt`
//  — the rails' own hand, not a Material glyph; the user: "use better
//  icons… the open book looks very generic"), the label beneath in Manrope.
//  The selected tile is ringed in ink (DESIGN-SYSTEM §4.0: selection is ink,
//  never a fill) and its label is bold; a tap presses and hums.
//
//  Five tiles fit a 360pt screen at 56pt each; six or more scroll, with the
//  selected one kept in view. Same contract as the other two selectors —
//  `groups`, `counts`, `selected`, `onPick` — so a door swaps by flag.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/doors/pv_door_data.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../v2/v2_palette.dart';
import 'pv_door_chrome.dart';

/// The row, and the tile for tab [i] — what a test taps to reach a tab.
const Key kPvDoorTilesKey = ValueKey('pv-door-tiles');
Key pvDoorTileKey(int i) => ValueKey('pv-door-tile-$i');

class PvDoorTiles extends StatefulWidget {
  const PvDoorTiles({
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

  static const double well = 56;
  static const double height = well + 6 + 30; // well, gap, two-line label

  @override
  State<PvDoorTiles> createState() => _PvDoorTilesState();
}

class _PvDoorTilesState extends State<PvDoorTiles> {
  final _keys = <int, GlobalKey>{};

  @override
  void didUpdateWidget(PvDoorTiles old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      final ctx = _keys[widget.selected]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx,
            alignment: 0.5,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final n = widget.groups.length;
    // Up to five tiles share the width; more than five scroll at a fixed
    // width, the way every food app's category row does.
    return LayoutBuilder(builder: (context, c) {
      final inner = c.maxWidth - 2 * kPvDoorGutter;
      final gap = 8.0;
      final fits = n <= 5;
      final w = fits ? (inner - gap * (n - 1)) / n : 76.0;
      final tiles = [
        for (var i = 0; i < n; i++) ...[
          if (i > 0) SizedBox(width: gap),
          SizedBox(width: w, child: _tile(i, p)),
        ],
      ];
      return SizedBox(
        key: kPvDoorTilesKey,
        height: PvDoorTiles.height,
        child: fits
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
                child: Row(children: tiles),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
                child: Row(children: tiles),
              ),
      );
    });
  }

  Widget _tile(int i, V2Palette p) {
    final g = widget.groups[i];
    final on = i == widget.selected;
    final tint = v2BlockTint(g.hue % 360, p);
    return PvPress(
      key: pvDoorTileKey(i),
      child: GestureDetector(
        key: _keys.putIfAbsent(i, () => GlobalKey()),
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (on) return;
          pvCommitFeedback();
          widget.onPick(i);
        },
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            width: PvDoorTiles.well,
            height: PvDoorTiles.well,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(tint, Colors.white, 0.10)!,
                  Color.lerp(tint, Colors.black, 0.04)!,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              // Selection is a ring in ink, never a fill.
              // Always 1.8 wide (transparent when off) — a border that
              // changes width changes the well's inner size and shoves the
              // row out of line the moment one tile is selected.
              border: Border.all(
                  color: on ? p.ink1 : Colors.transparent, width: 1.8),
            ),
            padding: const EdgeInsets.all(9),
            child: g.mark != null
                ? HubIntentArt(mark: g.mark!, tint: tint)
                : Icon(g.icon, size: 22, color: p.ink1),
          ),
          const SizedBox(height: 6),
          // A fixed two-line box, so a one-line label and a two-line label
          // leave every well on the same top edge (the user: "make sure
          // they are in a line").
          SizedBox(
            height: 30,
            child: Text(g.label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                    fontSize: 11.5,
                    height: 1.2,
                    fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                    color: on ? p.ink1 : p.ink2)),
          ),
        ]),
      ),
    );
  }
}
