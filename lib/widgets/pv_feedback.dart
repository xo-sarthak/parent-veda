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

import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/pv_fonts.dart';

/// A 2% settle while the pointer is down.
///
/// ⚠️ TWO RULES FOR WHEN IT IS EVERYWHERE (tap feedback second pass,
/// 2026-10-15, when every plain tap in the app got one):
///
///  * A SCROLL IS NOT A PRESS. A finger that starts a scroll on a card used to
///    hold it at 98% until lift; the press now lets go once the pointer has
///    moved past the touch slop, the distance Flutter itself uses to decide a
///    drag is not a tap.
///  * ONLY THE INNERMOST PRESS SETTLES. A `Listener` sees the pointer on every
///    ancestor, so a save icon inside a pressable card settled the card too.
///    Hit testing delivers the pointer-down innermost first, so the first
///    PvPress to see it claims the pointer and the outer ones leave it.
class PvPress extends StatefulWidget {
  const PvPress({super.key, required this.child, this.enabled = true});
  final Widget child;
  final bool enabled;

  @override
  State<PvPress> createState() => _PvPressState();
}

/// Pointers an inner PvPress has already claimed.
final Set<int> _pvPressClaimed = <int>{};

class _PvPressState extends State<PvPress> {
  bool _down = false;
  int? _pointer;
  Offset _origin = Offset.zero;

  void _onDown(PointerDownEvent e) {
    if (!_pvPressClaimed.add(e.pointer)) return; // an inner press has it
    _pointer = e.pointer;
    _origin = e.position;
    setState(() => _down = true);
  }

  void _onMove(PointerMoveEvent e) {
    if (e.pointer != _pointer || !_down) return;
    if ((e.position - _origin).distance > kTouchSlop) {
      setState(() => _down = false);
    }
  }

  void _onEnd(PointerEvent e) {
    // Every PvPress the pointer passed through clears it, so the claim is
    // gone before the next pointer-down whatever order the ends arrive in.
    _pvPressClaimed.remove(e.pointer);
    if (e.pointer != _pointer) return;
    _pointer = null;
    if (_down) setState(() => _down = false);
  }

  @override
  void dispose() {
    if (_pointer != null) _pvPressClaimed.remove(_pointer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: widget.enabled ? _onDown : null,
        onPointerMove: _onMove,
        onPointerUp: _onEnd,
        onPointerCancel: _onEnd,
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

// =============================================================================
//  PvChoiceTile / PvQuestionProgress: one answer row and one progress line
//  for every question flow (2026-10-10)
// -----------------------------------------------------------------------------
//  The user's notes: "consistency for MCQ type ques" and "consistency for that
//  'keep going' box for ques". Before this, a chosen answer was an ink edge in
//  onboarding, a lavender fill with a violet edge in What changed, a violet
//  edge in the parenting checks, an ink slab in the mood check and a tinted
//  panel in the TTC intro: five looks for one act. And the progress line over
//  a run of questions was violet on the TTC tools, ink in onboarding, and a
//  bare "Question 2 of 5" on What changed.
//
//  The shape, from Mobbin (Cash App's employment status
//  https://mobbin.com/screens/48895749-349e-4c68-8c52-4fa0d2485e73 ,
//  MacroFactor's program style
//  https://mobbin.com/screens/d0e155ed-6da1-4e5f-a03a-675b24be45c9 ,
//  LinkedIn's goal question
//  https://mobbin.com/screens/266fba7e-51d8-468e-8a0b-c41257fa9acd , Ro's
//  thin bar over its questionnaire
//  https://mobbin.com/screens/07c64cc9-88c4-4ca1-ba72-254e1603748a ) and from
//  our base UI (white ground, the one ink, no violet on a selection):
//
//    · AT REST: white card, hairline edge, an empty ring on the right. The ring
//      says "this can be chosen" before anything is.
//    · CHOSEN: the edge goes ink and thicker, the ring fills ink with a white
//      tick. The card itself does NOT fill: a full-width ink slab of text is
//      the loudest thing on a calm page, and the mark already says "this one".
//
//  ⚠️ `selectedEdge` / `selectedTint` EXIST FOR TRIAGE, AND ONLY FOR IT. The
//  parenting checks colour a worrying answer once it is chosen (never before,
//  so no answer looks like the wrong one). That is meaning, not decoration, so
//  the shared tile carries it rather than flattening it away.
//
//  Compact Yes / No / Not sure answers laid out in a grid stay on
//  `TtcToolOptions` (ttc_tool_chrome.dart): ink-filled blocks, decided by the
//  user on 2026-09-06. A row and a block are two shapes; each has one look.
// =============================================================================

/// The one ink and one hairline every question control is drawn in.
const Color kPvChoiceInk = Color(0xFF2F2C30);
const Color kPvChoiceLine = Color(0xFFE4E2E5);
const Color _kPvChoiceMuted = Color(0xFF6F6A73);

/// One answer to a multiple-choice question, as a full-width row.
class PvChoiceTile extends StatelessWidget {
  const PvChoiceTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.leading,
    this.titleStyle,
    this.selectedEdge,
    this.selectedTint,
    this.compact = false,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;

  /// An optional icon well or picture on the left.
  final Widget? leading;

  /// Overrides the label's style (onboarding sets its titles in Fraunces).
  final TextStyle? titleStyle;

  /// Triage only: see the header.
  final Color? selectedEdge;
  final Color? selectedTint;

  /// Tighter vertical padding for long lists.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final mark = selectedEdge ?? kPvChoiceInk;
    final edge = selected ? mark : kPvChoiceLine;
    return Semantics(
      button: true,
      selected: selected,
      child: PvPress(
        enabled: onTap != null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap == null
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onTap!();
                  },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 56),
              padding: EdgeInsets.fromLTRB(
                  16, compact ? 12 : 15, 14, compact ? 12 : 15),
              decoration: BoxDecoration(
                color: selected ? (selectedTint ?? Colors.white) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: edge, width: selected ? 1.6 : 1.2),
              ),
              child: Row(children: [
                if (leading != null) ...[leading!, const SizedBox(width: 14)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: titleStyle ??
                            pvManrope(
                              fontSize: 15,
                              height: 1.35,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w600,
                              color: kPvChoiceInk,
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: pvManrope(
                              fontSize: 12.5,
                              height: 1.4,
                              color: _kPvChoiceMuted),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? mark : Colors.transparent,
                    border: selected
                        ? null
                        : Border.all(color: kPvChoiceLine, width: 1.6),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : null,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// How far through a run of questions: a small label over a thin ink line.
///
/// `done == 0` shows [startLabel]; after the first answer, [goingLabel], the
/// "KEEP GOING" the TTC tools say. [count] adds "3 of 8" on the right, which
/// onboarding uses over its question block and the TTC tools deliberately do
/// not (a counter on a health questionnaire reads as a debt).
class PvQuestionProgress extends StatelessWidget {
  const PvQuestionProgress({
    super.key,
    required this.done,
    required this.total,
    this.startLabel = 'A FEW SHORT QUESTIONS',
    this.goingLabel = 'KEEP GOING',
    this.count = false,
  });

  final int done;
  final int total;
  final String startLabel;
  final String goingLabel;
  final bool count;

  @override
  Widget build(BuildContext context) {
    final t = total <= 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    final style = pvManrope(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.2,
      color: _kPvChoiceMuted,
    );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Text(
            (done == 0 ? startLabel : goingLabel).toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        if (count)
          Text('$done of $total',
              style: style.copyWith(
                  letterSpacing: 0, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: t),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => LinearProgressIndicator(
            value: v,
            minHeight: 4,
            backgroundColor: const Color(0xFFEEECEF),
            // Ink, not the accent: this reports, it does not invite a tap.
            valueColor: const AlwaysStoppedAnimation(kPvChoiceInk),
          ),
        ),
      ),
    ]);
  }
}
