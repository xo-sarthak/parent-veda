// =============================================================================
//  Journey map markers
// -----------------------------------------------------------------------------
//  * JourneyNodeMarker  - a week checkpoint on the trail (green / gold / grey).
//  * YouAreHereMarker   - the gently pulsing "you are here" marker + label pill.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

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
    final completed = state == NodeState.completed;
    final future = state == NodeState.future;
    final current = state == NodeState.current;

    // MapB node styles: current = coral gradient (no border), done = solid
    // purple + white check, future = plain white with a soft shadow.
    final core = Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: completed
            ? JourneyColors.completed
            : future
                ? Colors.white
                : null,
        gradient: current
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF5A79), Color(0xFFBF435B)],
              )
            : null,
        shape: BoxShape.circle,
        boxShadow: [
          if (current)
            const BoxShadow(
              color: Color(0x66FF5A79),
              blurRadius: 24,
              offset: Offset(0, 10),
            )
          else
            const BoxShadow(
              color: Color(0x1F2D144C),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
        ],
      ),
      child: completed
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
          : Text(
              label,
              style: TextStyle(
                color: future ? const Color(0xFFB2AEB5) : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: current ? 17 : 14,
              ),
            ),
    );

    Widget child = core;
    if (pulse != null && current) {
      // The current week must be unmistakable: two staggered "ping" rings (a
      // soft filled halo + a crisp expanding ring) radiate outward and fade on
      // a loop, behind a gently breathing core - clearly alive next to the
      // static completed/future circles.
      child = AnimatedBuilder(
        animation: pulse!,
        builder: (context, c) {
          const here = Color(0xFFFF5A79); // current coral
          final v = pulse!.value; // 0 → 1, repeating
          final v2 = (v + 0.5) % 1.0; // second ping, half a cycle behind
          Widget ping(double t, {required bool stroke}) => OverflowBox(
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: Container(
                  width: diameter * (1.0 + t * 1.35),
                  height: diameter * (1.0 + t * 1.35),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        stroke ? null : here.withValues(alpha: 0.26 * (1 - t)),
                    border: stroke
                        ? Border.all(
                            color: here.withValues(alpha: 0.55 * (1 - t)),
                            width: 2.5)
                        : null,
                  ),
                ),
              );
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              ping(v, stroke: false),
              ping(v2, stroke: true),
              Transform.scale(
                scale: 1 + 0.06 * math.sin(v * math.pi),
                child: c,
              ),
            ],
          );
        },
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
/// Emoji-free but with real presence: a circular checkpoint in its TYPE colour
/// carrying a small Material type-icon. Reached = full colour fill + white ring
/// + white icon; upcoming = white fill with a colour ring + colour icon.
class MilestoneMarker extends StatelessWidget {
  const MilestoneMarker({
    super.key,
    required this.color,
    required this.icon,
    required this.reached,
    required this.onTap,
    this.diameter = 36,
  });

  final Color color;
  final IconData icon;
  final bool reached;
  final VoidCallback onTap;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: diameter,
        height: diameter,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: reached ? color : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: reached ? Colors.white : color,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F2D144C),
              blurRadius: 9,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: diameter * 0.5,
          color: reached ? Colors.white : color,
        ),
      ),
    );
  }
}

/// The small caption pill that sits directly below a node (MapB design): a
/// single rounded pill - white with deep-purple text for ordinary stops, or a
/// deep-purple pill with white text for the current "You're here" stop.
class JourneyNodeLabel extends StatelessWidget {
  const JourneyNodeLabel({
    super.key,
    required this.text,
    required this.onTap,
    this.dark = false,
    this.maxWidth = 150,
  });

  final String text;
  final VoidCallback onTap;

  /// The current ("you're here") pill uses the dark deep-purple treatment.
  final bool dark;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF2D144C) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x142D144C),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          // Wrap to 2 lines + size the pill to its content (no hard truncation).
          child: Text(
            text,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: dark ? Colors.white : const Color(0xFF502489),
              fontSize: 11,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}

/// A soft dashed ring (kept for reference; upcoming stops now use plain white
/// discs / colour-ringed dots to match the reference design).
// ignore: unused_element
class _DashedRingPainter extends CustomPainter {
  const _DashedRingPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2 - 1.3;
    if (radius <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = color
      ..isAntiAlias = true;
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / 8).floor().clamp(8, 64);
    final step = (2 * math.pi) / dashCount;
    final dashSweep = step * 0.5;
    final rect = Rect.fromCircle(center: center, radius: radius);
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, i * step, dashSweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter old) => old.color != color;
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

/// The journey's destination - the final node near Birth. Bigger than a normal
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
