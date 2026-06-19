// =============================================================================
//  Journey map markers
// -----------------------------------------------------------------------------
//  * JourneyNodeMarker  — a week checkpoint on the trail (green / gold / grey).
//  * YouAreHereMarker   — the gently pulsing "you are here" marker + label pill.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'journey_palette.dart';

/// A circular checkpoint sitting on the trail. Week nodes show their number;
/// completed nodes get a soft glow, future nodes fade back.
class JourneyNodeMarker extends StatelessWidget {
  const JourneyNodeMarker({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
    this.diameter = 54,
  });

  final String label;
  final NodeState state;
  final VoidCallback onTap;
  final double diameter;

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

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
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
      ),
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

/// The pulsing "you are here" marker. [pulse] drives a 0→1 repeating animation;
/// a soft gold halo expands and fades while a star pin and label pill stay put.
class YouAreHereMarker extends StatelessWidget {
  const YouAreHereMarker({
    super.key,
    required this.pulse,
    required this.label,
    this.diameter = 54,
  });

  final Animation<double> pulse;
  final String label;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: diameter * 2.4,
        height: diameter * 2.4,
        child: Center(
          child: AnimatedBuilder(
            animation: pulse,
            builder: (context, child) {
              final v = pulse.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Expanding, fading halo.
                  Container(
                    width: diameter * (1.0 + v * 1.1),
                    height: diameter * (1.0 + v * 1.1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: JourneyColors.current
                          .withValues(alpha: 0.28 * (1 - v)),
                    ),
                  ),
                  child!,
                ],
              );
            },
            child: _pin(context),
          ),
        ),
      ),
    );
  }

  Widget _pin(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label pill floating just above the pin.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: JourneyColors.current,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: JourneyColors.current.withValues(alpha: 0.35),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⭐ ', style: TextStyle(fontSize: 12)),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Icon(Icons.location_on, color: JourneyColors.current, size: 28),
      ],
    );
  }
}
