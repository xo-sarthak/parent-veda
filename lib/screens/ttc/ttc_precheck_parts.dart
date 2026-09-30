// =============================================================================
//  Pre-pregnancy checklist — the parts of the rebuilt list (2026-09-29)
// -----------------------------------------------------------------------------
//  The user, on build 20's Tools tab: the tools "look very just put together…
//  big blobs of text… I want usability out of the tools." The checklist was
//  ten bordered boxes that each opened into rows that each opened into
//  paragraphs: two levels of taps before a tick, and every level black text.
//
//  What a checklist that people come back to looks like, from Mobbin:
//
//  · A PROGRESS HEADER THAT MOVES WHEN SHE ACTS. CVS Health's visit checklist
//    opens on a ring ("50% Completed") above its sections
//    https://mobbin.com/screens/387b81ad-b6ed-483c-88d5-5cf2384388b5 ; KOHO's
//    "1 of 7 items completed" bar over "Most recommended"
//    https://mobbin.com/screens/0dab839b-0280-40be-8d35-964462d7ce65 ; Target's
//    "3 of 85 items completed" with "3/12 complete" per section
//    https://mobbin.com/screens/5624b56e-794a-4ea1-b56f-4817c8534951 . Ours is
//    a ring and a count of HER list ("5 of 21 done"), never a percentage and
//    never a claim about her body (the rules file says why).
//  · THE TICK ON THE CLOSED ROW, ONE TAP. Apple Reminders' grouped list
//    https://mobbin.com/screens/18651acb-c9e7-4579-9148-ee2737350062 , Amazon
//    Alexa's grouped list with its Completed group
//    https://mobbin.com/screens/5bfa4fd9-0058-4c67-ba77-36d9b7ba7edc .
//  · DONE FOLDS AWAY, COUNTED. Amie's "Hide 2 done"
//    https://mobbin.com/screens/a4ea2bef-dcfe-4b67-89c6-2766e5376383 , Tiimo's
//    "DONE (1)" group https://mobbin.com/screens/e0497409-3a81-4cf6-b9e8-3c9fee7f26d3 ,
//    Attio's collapsed "Completed 1"
//    https://mobbin.com/screens/c45cd1e7-9589-42fd-8408-b8a6fe179a4b . Things 3
//    keeps a ticked to-do in place until you leave the list, so a slip is
//    seen and undone where it happened; ours does the same.
//  · DETAIL OPENS IN PLACE. Things 3 opens a to-do into its notes and
//    checklist inline, in the list
//    https://mobbin.com/screens/18b05379-2af1-41ab-afef-0ca4870933c1 .
//  · WHAT TO DO NEXT, NUMBERED, ON TOP. Cleo's numbered steps with the done
//    ones ticked https://mobbin.com/screens/e114897d-82eb-4d57-9964-52e1b16f2cbb ;
//    Strava's "how to get started" rows with a reason under each
//    https://mobbin.com/screens/9e550f02-8d7a-4e05-be89-aae812901ec4 .
//
//  ONE PARENTVEDA: the one black (ttcTitleInk, 0xFF2F2C30) for every tick,
//  number and pill; tints only on tags; drawn marks on rows that go somewhere;
//  line icons only for controls; no tinted slab behind text.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_precheck_data.dart';
import '../v2/v2_palette.dart';
import 'doors/ttc_tab_art.dart';
import 'ttc_common.dart';
import 'ttc_tool_hues.dart';
import 'ttc_tool_marks.dart';

/// Hairline card: white, one line, the stage's card radius.
BoxDecoration precheckCard(V2Palette p) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: ttcLine),
);

// -----------------------------------------------------------------------------
//  The progress ring
// -----------------------------------------------------------------------------

/// A ring that fills with her ticks. Ink on a hairline track.
class PrecheckRing extends StatelessWidget {
  const PrecheckRing({
    super.key,
    required this.done,
    required this.total,
    this.size = 76,
  });

  final int done;
  final int total;
  final double size;

  @override
  Widget build(BuildContext context) {
    final target = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: target),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => CustomPaint(
          painter: _RingPainter(v),
          // Scales down inside the ring at large text sizes rather than
          // spilling out of it (1.5x ran 8pt over).
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$done',
                    style: pvFraunces(
                      fontSize: 24,
                      height: 1.0,
                      fontWeight: FontWeight.w600,
                      color: ttcTitleInk,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'of $total',
                    style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: ttcTitleInk,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    const w = 7.0;
    final r = (math.min(size.width, size.height) - w) / 2;
    final c = size.center(Offset.zero);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = ttcLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = w,
    );
    if (value <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      Paint()
        ..color = ttcTitleInk
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}

// -----------------------------------------------------------------------------
//  The tick on every row
// -----------------------------------------------------------------------------

/// The row's circle, as a button. One tap marks it done; a second takes it
/// off. 44 to the finger, 26 to the eye.
///
/// ⚠️ SHAPE AND GLYPH CARRY THE STATUS, NOT COLOUR ALONE, AND NO RED: an
/// unfinished item is not a failure. Done is the filled ink disc with a white
/// tick; "Need to do" a ring with a dot; "Not sure" a ring with a question
/// mark; "Not relevant to me" a ring with a dash.
class PrecheckTick extends StatelessWidget {
  const PrecheckTick({
    super.key,
    required this.status,
    required this.title,
    required this.onTap,
  });

  final PrecheckStatus status;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = status == PrecheckStatus.done;
    final IconData? glyph = switch (status) {
      PrecheckStatus.done => Icons.check_rounded,
      PrecheckStatus.needsAttention => Icons.circle,
      PrecheckStatus.notSure => Icons.question_mark_rounded,
      PrecheckStatus.notRelevant => Icons.remove_rounded,
      PrecheckStatus.untouched => null,
    };
    return Semantics(
      button: true,
      checked: done,
      label: done ? 'Done: $title. Tap to take it off' : 'Mark $title done',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedScale(
              scale: done ? 1.0 : 0.94,
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: done ? ttcTitleInk : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: status == PrecheckStatus.notRelevant
                        ? ttcMuted
                        : ttcTitleInk,
                    width: 1.8,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (c, a) =>
                      ScaleTransition(scale: a, child: c),
                  child: glyph == null
                      ? const SizedBox.shrink(key: ValueKey('none'))
                      : Icon(
                          glyph,
                          key: ValueKey(status),
                          size: status == PrecheckStatus.needsAttention
                              ? 8
                              : 15,
                          color: done
                              ? Colors.white
                              : status == PrecheckStatus.notRelevant
                              ? ttcMuted
                              : ttcTitleInk,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  Tags
// -----------------------------------------------------------------------------

/// A small tag under a row's title. Tints belong to tags; the words are ink.
class PrecheckTag extends StatelessWidget {
  const PrecheckTag(
    this.label, {
    super.key,
    this.filled = false,
    this.icon,
    this.hue = kTtcToolHuePlan,
  });

  final String label;

  /// Tinted fill (for "Core" and "From your …"); otherwise white with a
  /// hairline.
  final bool filled;
  final IconData? icon;
  final double hue;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Container(
      padding: EdgeInsets.fromLTRB(icon == null ? 9 : 7, 3, 9, 3),
      decoration: BoxDecoration(
        color: filled ? v2BlockTint(hue % 360, p) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: filled ? null : Border.all(color: ttcLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: ttcTitleInk),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: pvManrope(
                fontSize: 11,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: ttcTitleInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  A row that goes somewhere, with its drawn mark
// -----------------------------------------------------------------------------

/// The Tools group hue of the tool a surface opens, so the mark on the link
/// is the colour of the page it opens (`ttc_tool_hues.dart`).
double precheckSurfaceHue(String surfaceId) => switch (surfaceId) {
  'ttc_supplements' ||
  'ttc_medication' ||
  'ttc_tests' ||
  'ttc_vaccinations' ||
  'ttc_prepare' => kTtcToolHueCare,
  'ttc_bmi' || 'ttc_window' || 'ttc_cycle' || 'ttc_ritual' => kTtcToolHueBody,
  'ttc_partner' => kTtcToolHueBoth,
  _ => kTtcToolHuePlan,
};

/// A link row: drawn mark, the words that name where it goes, an arrow.
class PrecheckGoRow extends StatelessWidget {
  const PrecheckGoRow({
    super.key,
    required this.label,
    required this.onTap,
    this.toolMark,
    this.tabMark,
    required this.hue,
  });

  final String label;
  final VoidCallback onTap;
  final TtcToolMark? toolMark;
  final TtcTabMark? tabMark;
  final double hue;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(hue % 360, p);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              SizedBox(
                width: 38,
                height: 38,
                child: toolMark != null
                    ? TtcToolArt(mark: toolMark!, tint: tint)
                    : TtcTabArt(
                        mark: tabMark ?? TtcTabMark.openBook,
                        tint: tint,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: pvManrope(
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: ttcTitleInk,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 17,
                color: ttcTitleInk,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  A fold ("Done · 5")
// -----------------------------------------------------------------------------

class PrecheckFoldHead extends StatelessWidget {
  const PrecheckFoldHead({
    super.key,
    required this.label,
    required this.open,
    required this.onTap,
    this.icon = Icons.check_circle_rounded,
  });

  final String label;
  final bool open;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    expanded: open,
    label: label,
    excludeSemantics: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: ttcTitleInk),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: pvManrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: ttcTitleInk,
                ),
              ),
            ),
            AnimatedRotation(
              turns: open ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.expand_more_rounded,
                size: 22,
                color: ttcTitleInk,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// A small uppercase label inside an open item.
class PrecheckLabel extends StatelessWidget {
  const PrecheckLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: pvManrope(
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.1,
      color: V2PaletteStore.instance.current.ink2,
    ),
  );
}
