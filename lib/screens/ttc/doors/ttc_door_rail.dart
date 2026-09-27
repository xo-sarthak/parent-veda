// =============================================================================
//  TtcDoorRail — the TTC door's tab selector, as the straddling card rail
// -----------------------------------------------------------------------------
//  ⚠️ A COPY OF `PvDoorRail`, TYPED ON `TtcFocusGroup`, AND THE COPY IS THE
//  DECISION (2026-09-26). The pregnancy rail takes `PvDoorGroup`, which lives
//  in the pregnancy door model; making it generic would mean editing a file
//  the pregnancy doors depend on for a stage it knows nothing about. The repo
//  already settled this the same way twice (the parenting and skilling
//  engines are their own copies), so this is a mirror, not a merge.
//
//  What is shared is everything that is not typed on a group: the geometry
//  constants below are the pregnancy rail's own (`PvDoorRail.cardWidth` etc.),
//  read rather than retyped, so the two rails cannot drift apart in size.
//
//  The card: white, radius 24, the page hairline, the group's DRAWN mark at
//  48pt top-left, the label bold with room for two lines, a grey count line,
//  a chevron. The chosen card is ringed in ink. Tapping presses and hums, and
//  the rail scrolls the chosen card towards the left edge (Flo's behaviour).
// =============================================================================

import 'package:flutter/material.dart';

import '../../../theme/pv_fonts.dart';
import '../../../ttc/ttc_focus_data.dart';
import '../../../widgets/pv_feedback.dart';
import '../../brackets/hub/hub_intent_art.dart';
import '../../doors/pv_door_chrome.dart' show kPvDoorGutter;
import '../../doors/pv_door_rail.dart' show PvDoorRail;
import '../../v2/v2_palette.dart';

const Key kTtcDoorRailKey = ValueKey('ttc-door-rail');
Key ttcDoorRailCardKey(int i) => ValueKey('ttc-door-rail-$i');

class TtcDoorRail extends StatefulWidget {
  const TtcDoorRail({
    super.key,
    required this.groups,
    required this.counts,
    required this.selected,
    required this.p,
    required this.onPick,
  });

  final List<TtcFocusGroup> groups;
  final List<String> counts;
  final int selected;
  final V2Palette p;
  final ValueChanged<int> onPick;

  // One set of numbers with the pregnancy rail. Change them there.
  static const double cardWidth = PvDoorRail.cardWidth;
  static const double cardHeight = PvDoorRail.cardHeight;
  static const double markSize = PvDoorRail.markSize;
  static const double overlap = PvDoorRail.overlap;

  @override
  State<TtcDoorRail> createState() => _TtcDoorRailState();
}

class _TtcDoorRailState extends State<TtcDoorRail> {
  final _ctl = ScrollController();

  @override
  void didUpdateWidget(TtcDoorRail old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) _reveal();
  }

  void _reveal() {
    if (!_ctl.hasClients) return;
    final x = widget.selected * (TtcDoorRail.cardWidth + 10);
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
      key: kTtcDoorRailKey,
      height: TtcDoorRail.cardHeight,
      // A plain scrolling Row, not a lazy list: five cards are cheap, and
      // every card existing lets a test reach any tab at 360pt.
      child: SingleChildScrollView(
        controller: _ctl,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
        child: Row(
          children: [
            for (var i = 0; i < widget.groups.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              _card(i, p),
            ],
          ],
        ),
      ),
    );
  }

  Widget _card(int i, V2Palette p) {
    final g = widget.groups[i];
    final on = i == widget.selected;
    final tint = v2BlockTint(g.hue % 360, p);
    final count = i < widget.counts.length ? widget.counts[i] : '';
    return PvPress(
      key: ttcDoorRailCardKey(i),
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
          width: TtcDoorRail.cardWidth,
          height: TtcDoorRail.cardHeight,
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: on ? p.ink1 : p.line,
              width: on ? 1.2 : 1,
            ),
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
              // The mark, bare on the white card, drawn in the group's tint.
              // A group with no mark falls back to its Material glyph, which
              // is why the door's test requires every tab to carry one.
              SizedBox(
                width: TtcDoorRail.markSize,
                height: TtcDoorRail.markSize,
                child: g.mark != null
                    ? HubIntentArt(mark: g.mark!, tint: tint)
                    : Icon(g.icon, size: 28, color: p.ink1),
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          g.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                            fontSize: 15,
                            fontWeight: on ? FontWeight.w800 : FontWeight.w700,
                            height: 1.2,
                            letterSpacing: -0.2,
                            color: p.ink1,
                          ),
                        ),
                        if (count.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            count,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: p.ink3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_right_rounded, size: 22, color: p.ink2),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
