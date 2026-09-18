// =============================================================================
//  PvDoorRail — the door's group selector as Flo's straddling card rail
// -----------------------------------------------------------------------------
//  The fourth form of the selector under a door hero, and the one the user
//  brought a reference for (2026-09-18, Flo's "Vaginal discharge" and "Early
//  signs of pregnancy" doors): a FLAT horizontal rail of tall white cards
//  that sits ACROSS THE SEAM — its top half over the hero photograph, its
//  bottom half on the white sheet — each card a big line icon top-left, the
//  full label bottom-left, a chevron bottom-right. Plain scroll, the first
//  card at the gutter; no fan, no blur, no dots. Where the user's own
//  instinct (the swipe) and every category selector at scale (a flat rail)
//  meet.
//
//  The card is 168×164 (Flo: ~160×170 at 390pt), radius 24, white, the
//  page hairline, the group's DRAWN mark (`HubIntentArt`) at 40pt in the
//  top-left, the label at 15/w600 with room for two lines so "Understand a
//  result" is never cut, a chevron that says "opens". The selected card is
//  ringed in ink (DESIGN-SYSTEM §4.0). Tapping presses and hums, and the
//  rail scrolls the chosen card to the left edge — Flo's own behaviour.
//
//  Same contract as the other selectors — `groups`, `counts`, `selected`,
//  `onPick` — plus `overlap`, how much of the rail rides up over the hero.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/doors/pv_door_data.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../v2/v2_palette.dart';
import 'pv_door_chrome.dart';

const Key kPvDoorRailKey = ValueKey('pv-door-rail');
Key pvDoorRailCardKey(int i) => ValueKey('pv-door-rail-$i');

class PvDoorRail extends StatefulWidget {
  const PvDoorRail({
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

  static const double cardWidth = 168;

  /// 164 for the first day (Flo's ~170). The user, 2026-09-18 evening: the
  /// gap between the mark and the heading was air, not composition — so the
  /// card is shorter. Flip back to 164 to revert.
  static const double cardHeight = 136; // was 164

  /// The mark bare on the white card, larger, no tinted square around it —
  /// Flo's own cards carry a bare icon. `false` restores the 44pt tinted
  /// well (kept below for revert).
  static const bool bareMark = true;
  static const double markSize = 48;

  /// How much of the rail rides up over the hero photograph.
  static const double overlap = 44; // was 70 — the cards covered the hero's blurb

  @override
  State<PvDoorRail> createState() => _PvDoorRailState();
}

class _PvDoorRailState extends State<PvDoorRail> {
  final _ctl = ScrollController();

  @override
  void didUpdateWidget(PvDoorRail old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) _reveal();
  }

  void _reveal() {
    if (!_ctl.hasClients) return;
    final x = widget.selected * (PvDoorRail.cardWidth + 10);
    _ctl.animateTo(
      x.clamp(0.0, _ctl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return SizedBox(
      key: kPvDoorRailKey,
      height: PvDoorRail.cardHeight,
      // A plain scrolling Row, not a lazy list: five cards are cheap, and every
      // card existing lets the rail scroll a chosen one into place (and a
      // test reach any tab) on a narrow screen.
      child: SingleChildScrollView(
        controller: _ctl,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
        child: Row(children: [
          for (var i = 0; i < widget.groups.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            _card(i, p),
          ],
        ]),
      ),
    );
  }

  Widget _card(int i, V2Palette p) {
    final g = widget.groups[i];
    final on = i == widget.selected;
    final tint = v2BlockTint(g.hue % 360, p);
    final count = i < widget.counts.length ? widget.counts[i] : '';
    return PvPress(
      key: pvDoorRailCardKey(i),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (on) return;
          pvCommitFeedback();
          widget.onPick(i);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: PvDoorRail.cardWidth,
          height: PvDoorRail.cardHeight,
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14), // top was 16
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: on ? p.ink1 : p.line,
                width: on ? 1.2 : 1), // selected was 1.8 — "less thick" (user)
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The mark. Bare on the white card at 48pt (the hue shows in
              // the mark itself, which is drawn in the group's tint —
              // DESIGN-SYSTEM §4.0), or, on revert, in a 44pt well of the
              // group's tint. Drawn, not a glyph, either way.
              if (PvDoorRail.bareMark)
                SizedBox(
                  width: PvDoorRail.markSize,
                  height: PvDoorRail.markSize,
                  child: g.mark != null
                      ? HubIntentArt(mark: g.mark!, tint: tint)
                      : Icon(g.icon, size: 28, color: p.ink1),
                )
              else
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: g.mark != null
                      ? HubIntentArt(mark: g.mark!, tint: tint)
                      : Icon(g.icon, size: 22, color: p.ink1),
                ),
              const Spacer(),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(g.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 15,
                              fontWeight: on ? FontWeight.w800 : FontWeight.w700,
                              height: 1.2,
                              letterSpacing: -0.2,
                              color: p.ink1)),
                      if (count.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(count,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: p.ink3)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, size: 22, color: p.ink2),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
