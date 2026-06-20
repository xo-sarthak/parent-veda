// =============================================================================
//  Journey map markers
// -----------------------------------------------------------------------------
//  * JourneyNodeMarker  — a week checkpoint on the trail (green / gold / grey).
//  * YouAreHereMarker   — the gently pulsing "you are here" marker + label pill.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'journey_palette.dart';

/// A circular checkpoint sitting on the trail. Week nodes show their number;
/// completed nodes get a soft glow, future nodes fade back. The CURRENT week
/// gently "breathes" (a soft scale pulse) when a [pulse] animation is supplied.
class JourneyNodeMarker extends StatelessWidget {
  const JourneyNodeMarker({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
    this.diameter = 54,
    this.pulse,
  });

  final String label;
  final NodeState state;
  final VoidCallback onTap;
  final double diameter;

  /// When set (used for the current week), the circle breathes gently.
  final Animation<double>? pulse;

  @override
  Widget build(BuildContext context) {
    final color = JourneyColors.forState(state);
    final completed = state == NodeState.completed;
    final future = state == NodeState.future;

    final fill = future ? AppTheme.surface : color;
    final textColor = future ? AppTheme.neutral500 : Colors.white;
    final border = future
        ? Border.all(color: JourneyColors.future, width: 3)
        : Border.all(color: Colors.white, width: 3);

    final core = Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: border,
        boxShadow: [
          if (completed)
            BoxShadow(
              color: JourneyColors.completed.withValues(alpha: 0.35),
              blurRadius: 14,
              spreadRadius: 1,
            )
          else if (!future)
            BoxShadow(
              color: color.withValues(alpha: 0.30),
              blurRadius: 12,
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
            ),
        ],
      ),
      child: completed
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 26)
          : Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
    );

    Widget child = core;
    if (pulse != null && state == NodeState.current) {
      child = AnimatedBuilder(
        animation: pulse!,
        // A smooth 0→1→0 breath each cycle (sin over the 0→1 pulse value).
        builder: (context, c) => Transform.scale(
          scale: 1 + 0.07 * math.sin(pulse!.value * math.pi),
          child: c,
        ),
        child: core,
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

/// A milestone stop (achievement / medical / baby / mother / journey / feature).
/// Smaller than a week checkpoint, filled with its TYPE colour and an emoji.
/// Future milestones fade back so the trail reads "not yet reached".
class MilestoneMarker extends StatelessWidget {
  const MilestoneMarker({
    super.key,
    required this.emoji,
    required this.color,
    required this.reached,
    required this.onTap,
    this.diameter = 40,
  });

  final String emoji;
  final Color color;
  final bool reached;
  final VoidCallback onTap;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: reached ? 1.0 : 0.55,
        child: Container(
          width: diameter,
          height: diameter,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: reached ? color : AppTheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: reached ? Colors.white : color,
              width: reached ? 2.5 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: reached ? 0.30 : 0.12),
                blurRadius: 10,
              ),
            ],
          ),
          child: Text(emoji, style: TextStyle(fontSize: diameter * 0.42)),
        ),
      ),
    );
  }
}

/// The little caption pill that sits beside a node so its meaning is readable
/// at a glance (no tap needed): an emoji + short title, tinted by the node's
/// colour. Reached nodes read in full colour on white; future ones fade back.
/// [alignEnd] right-aligns the pill (for nodes on the left of the trail, whose
/// label grows leftwards toward the screen edge).
class JourneyNodeLabel extends StatelessWidget {
  const JourneyNodeLabel({
    super.key,
    required this.text,
    required this.color,
    required this.reached,
    required this.onTap,
    required this.maxWidth,
    this.emoji,
    this.subtitle,
    this.alignEnd = false,
  });

  final String text;
  final String? emoji;

  /// Optional muted second line (e.g. "Week 6" / "Week 18–20") so every node
  /// reads which week it belongs to — kept on its own line for a clean, uniform
  /// look rather than crammed onto the title row.
  final String? subtitle;
  final Color color;
  final bool reached;
  final VoidCallback onTap;
  final double maxWidth;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final inkColor = reached ? _darken(color) : AppTheme.neutral500;
    final subColor = reached
        ? color.withValues(alpha: 0.85)
        : AppTheme.neutral400;
    final cross =
        alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final align = alignEnd ? TextAlign.right : TextAlign.left;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: reached ? Colors.white : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: reached
                  ? color.withValues(alpha: 0.45)
                  : JourneyColors.future.withValues(alpha: 0.8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: reached ? 0.07 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            textDirection: alignEnd ? TextDirection.rtl : TextDirection.ltr,
            children: [
              if (emoji != null && emoji!.isNotEmpty) ...[
                Text(emoji!, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 7),
              ],
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: cross,
                  children: [
                    Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: align,
                      textDirection:
                          alignEnd ? TextDirection.rtl : TextDirection.ltr,
                      style: TextStyle(
                        color: inkColor,
                        fontSize: 11.5,
                        height: 1.12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        textAlign: align,
                        style: TextStyle(
                          color: subColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A slightly deeper shade of the node colour so small text stays legible.
  static Color _darken(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - 0.18).clamp(0.0, 1.0)).toColor();
  }
}

/// The pulsing "you are here" marker. [pulse] drives a 0→1 repeating animation;
/// a soft gold halo expands and fades while the pin + label pill stay put. The
/// pill carries a tiny [eyebrow] ("YOU ARE HERE") over a bold [detail]
/// ("Week 16 · Day 3") so the current spot says exactly where she is.
class YouAreHereMarker extends StatelessWidget {
  const YouAreHereMarker({
    super.key,
    required this.pulse,
    required this.eyebrow,
    required this.detail,
    this.diameter = 54,
  });

  final Animation<double> pulse;
  final String eyebrow;
  final String detail;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final box = diameter * 3.0;
    return IgnorePointer(
      child: SizedBox(
        width: box,
        height: box,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Pulsing halo, centred on the circle.
            Positioned.fill(
              child: Center(
                child: AnimatedBuilder(
                  animation: pulse,
                  builder: (context, _) {
                    final v = pulse.value;
                    return Container(
                      width: diameter * (1.0 + v * 1.1),
                      height: diameter * (1.0 + v * 1.1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: JourneyColors.current
                            .withValues(alpha: 0.28 * (1 - v)),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Pill + tail sitting just above the circle, tail pointing into it.
            Positioned(
              left: 0,
              right: 0,
              bottom: box / 2 + diameter / 2 - 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _pill(context),
                  Transform.translate(
                    offset: const Offset(0, -3),
                    child: const Icon(
                      Icons.arrow_drop_down,
                      color: JourneyColors.current,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: JourneyColors.current,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: JourneyColors.current.withValues(alpha: 0.35),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            detail,
            style: text.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// The journey's destination — the final node near Birth. Bigger than a normal
/// stop, with a warm gold→rose gradient and a soft expanding glow, so the end of
/// the trail clearly reads as "the arrival". Always shown lit (it is the goal).
class DestinationMarker extends StatelessWidget {
  const DestinationMarker({
    super.key,
    required this.emoji,
    required this.pulse,
    required this.onTap,
    this.diameter = 60,
  });

  final String emoji;
  final Animation<double> pulse;
  final VoidCallback onTap;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final core = Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [JourneyColors.arrivalGold, JourneyColors.arrivalRose],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: JourneyColors.arrivalRose.withValues(alpha: 0.45),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(emoji, style: TextStyle(fontSize: diameter * 0.46)),
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, child) {
          final v = pulse.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: diameter * (1.0 + v * 0.9),
                height: diameter * (1.0 + v * 0.9),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: JourneyColors.arrivalGold.withValues(
                    alpha: 0.30 * (1 - v),
                  ),
                ),
              ),
              child!,
            ],
          );
        },
        child: core,
      ),
    );
  }
}
