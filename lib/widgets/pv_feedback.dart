// =============================================================================
//  PvPress / PvTick — the app's tap feedback, in one place
// -----------------------------------------------------------------------------
//  The user, 2026-09-18: "make sure each and every change we make considers
//  the taps and the effects that make the user feel like they did something."
//  So the feedback is a component, not a per-screen habit:
//
//    PvPress   — a 2% settle on pointer-down, 120 ms, released on up. The
//                same one the onboarding chrome had as `ObPress`; promoted
//                here so tiles, rows and cards across the app press the same
//                way. (Airbnb, Notion, Linear: a press scales, never dims.)
//    PvTick    — the tick circle a list uses to mark a thing done: it bounces
//                on toggle (1 → 1.18 → 1, 220 ms) and the mark cross-fades in,
//                with a light haptic — the feedback Things, Apple Reminders
//                and Todoist give a completed row, which is what makes a tick
//                satisfying rather than merely recorded.
//    pvCommitFeedback — the haptic alone, for a commit tap that already has
//                its own visual answer (a pill that turns into a "thanks").
//
//  Haptics go through `HapticFeedback.lightImpact`, which is a no-op where
//  the device has none, so nothing here needs a platform check.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A 2% settle while the pointer is down.
class PvPress extends StatefulWidget {
  const PvPress({super.key, required this.child, this.enabled = true});
  final Widget child;
  final bool enabled;

  @override
  State<PvPress> createState() => _PvPressState();
}

class _PvPressState extends State<PvPress> {
  bool _down = false;

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown:
            widget.enabled ? (_) => setState(() => _down = true) : null,
        onPointerUp: (_) => setState(() => _down = false),
        onPointerCancel: (_) => setState(() => _down = false),
        child: AnimatedScale(
          scale: _down ? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      );
}

/// The haptic for a commit tap.
void pvCommitFeedback() {
  HapticFeedback.lightImpact();
}

/// A tick circle that answers its toggle.
///
/// `done` is the state; `emphasis` draws a heavier ring for "the next one";
/// `onTap` is null when the row cannot be toggled yet (the ring still draws,
/// quieter, so the list keeps its column).
class PvTick extends StatefulWidget {
  const PvTick({
    super.key,
    required this.done,
    required this.ink,
    required this.line,
    required this.surface,
    this.emphasis = false,
    this.onTap,
    this.size = 24,
  });

  final bool done;
  final bool emphasis;
  final Color ink;
  final Color line;
  final Color surface;
  final VoidCallback? onTap;
  final double size;

  @override
  State<PvTick> createState() => _PvTickState();
}

class _PvTickState extends State<PvTick> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 220));
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 1.18), weight: 45),
    TweenSequenceItem(tween: Tween(begin: 1.18, end: 1), weight: 55),
  ]).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

  @override
  void didUpdateWidget(PvTick old) {
    super.didUpdateWidget(old);
    if (old.done != widget.done) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.done;
    final ring = done
        ? widget.ink
        : widget.emphasis
            ? widget.ink
            : widget.line;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap == null
          ? null
          : () {
              pvCommitFeedback();
              widget.onTap!();
            },
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? widget.ink : Colors.transparent,
              border: Border.all(
                  color: ring, width: widget.emphasis && !done ? 1.8 : 1.4),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: done
                  ? Icon(Icons.check_rounded,
                      key: const ValueKey('on'),
                      size: widget.size * 0.62,
                      color: widget.surface)
                  : const SizedBox.shrink(key: ValueKey('off')),
            ),
          ),
        ),
      ),
    );
  }
}
