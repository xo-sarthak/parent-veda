// =============================================================================
//  The first home: the welcome after onboarding (2026-10-18)
// -----------------------------------------------------------------------------
//  Prototype: https://claude.ai/artifact/QDYotDV9DFZ7UvcxU3Uwxd, approved by
//  the user ("motion is important, we need to welcome them").
//
//  The homes already show what her answers set. What they did not have is the
//  moment of arriving: onboarding ended and the whole page appeared at once.
//  Now, once, it arrives in order:
//
//      0 ms     the field fades in
//      120 ms   the header and the hero settle, the big number counts up
//      380 ms   the sheet rises
//      560 ms   the sheet's sections follow, 70 ms apart
//      1100 ms  "Set from your answers. Change any time in You.", 4 s
//
//  ⚠️ IN MEMORY, NOT A PREFS FLAG. The plan named a `first_home_seen_v1`
//  flag; nothing would have read it. The welcome belongs to the one moment
//  onboarding hands over, in the same process: `_finish()` calls
//  [PvFirstHome.owe], the first home to draw claims it. If the app dies in
//  between, she loses a few hundred milliseconds of motion and nothing else,
//  because the home itself is already right. A stored flag would add a read
//  on every launch to protect that, and a way for it to go stale.
//
//  ⚠️ ONE CLOCK FOR THE WHOLE PAGE. Every [PvArrive] times itself from the
//  moment the home claimed the welcome, not from when it was built. A
//  ListView builds the rows below the fold only when she scrolls to them; a
//  row that counted from its own build would arrive late, over and over. Past
//  its slot, a row is simply there.
// =============================================================================

import 'package:flutter/material.dart';

import 'pv_toast.dart';

/// Whether this launch owes a welcome, and whether one has played.
class PvFirstHome {
  PvFirstHome._();

  static bool _owed = false;
  static DateTime? _startedAt;

  /// Onboarding has just finished: the next home to draw welcomes her.
  static void owe() => _owed = true;

  /// True from the moment a home claims the welcome until the app closes.
  /// The pregnancy and parenting daily tip read it, so no dialog covers the
  /// home on the first open; it starts from her next open.
  static bool get thisLaunch => _startedAt != null;

  /// The start of the welcome, once; null when none is owed.
  static DateTime? claim() {
    if (!_owed) return null;
    _owed = false;
    return _startedAt = DateTime.now();
  }

  /// Tests only.
  static void resetForTest() {
    _owed = false;
    _startedAt = null;
  }
}

/// The note under the first home, in her words.
const String kPvFirstHomeNote = 'Set from your answers. Change any time in You.';

/// The note when she asked us to be gentle after a loss.
const String kPvFirstHomeNoteGentle =
    'Set from your answers. We keep things quiet here. Change any time in You.';

/// Wraps a stage home. Claims the welcome when one is owed and gives the
/// [PvArrive] pieces inside it their clock; otherwise it is just [child].
class PvHomeArrival extends StatefulWidget {
  const PvHomeArrival({
    super.key,
    required this.child,
    this.note = kPvFirstHomeNote,
  });

  final Widget child;

  /// Shown once, at the foot, about a second in. Null for none.
  final String? note;

  @override
  State<PvHomeArrival> createState() => _PvHomeArrivalState();
}

class _PvHomeArrivalState extends State<PvHomeArrival> {
  late final DateTime? _start = PvFirstHome.claim();

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    if (_start != null && note != null) {
      Future<void>.delayed(const Duration(milliseconds: 1100), () {
        if (!mounted) return;
        pvToast(context, note, hold: const Duration(seconds: 4));
      });
    }
  }

  @override
  Widget build(BuildContext context) =>
      _ArrivalScope(start: _start, child: widget.child);
}

class _ArrivalScope extends InheritedWidget {
  const _ArrivalScope({required this.start, required super.child});
  final DateTime? start;

  @override
  bool updateShouldNotify(_ArrivalScope old) => old.start != start;
}

/// How a piece arrives.
enum PvArriveKind {
  /// Opacity only: the field.
  fade,

  /// A short rise and fade: the header, the hero, each section.
  settle,

  /// A longer rise: the sheet sliding up over the field.
  rise,
}

/// The arrival timings, in one place (the prototype's numbers).
abstract final class PvArriveAt {
  static const Duration field = Duration.zero;
  static const Duration header = Duration(milliseconds: 120);
  static const Duration hero = Duration(milliseconds: 220);
  static const Duration heroAfter = Duration(milliseconds: 380);
  static const Duration sheet = Duration(milliseconds: 380);
  static const Duration sections = Duration(milliseconds: 560);
  static const Duration step = Duration(milliseconds: 70);
}

/// One piece of the first home that arrives in its slot. Outside a welcome,
/// with reduced motion, or once its slot has passed, it is just [child].
class PvArrive extends StatefulWidget {
  const PvArrive({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.kind = PvArriveKind.settle,
  });

  const PvArrive.field({super.key, required this.child})
      : delay = PvArriveAt.field,
        kind = PvArriveKind.fade;

  const PvArrive.sheet({super.key, required this.child})
      : delay = PvArriveAt.sheet,
        kind = PvArriveKind.rise;

  final Widget child;
  final Duration delay;
  final PvArriveKind kind;

  @override
  State<PvArrive> createState() => _PvArriveState();
}

class _PvArriveState extends State<PvArrive>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;
  bool _decided = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decided) return;
    _decided = true;
    final start =
        context.getInheritedWidgetOfExactType<_ArrivalScope>()?.start;
    final calm = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (start == null || calm) return;
    final wait = start.add(widget.delay).difference(DateTime.now());
    // Built after its slot (a row scrolled to later): no animation.
    if (wait < const Duration(milliseconds: -60)) return;
    final c = _c = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: switch (widget.kind) {
        PvArriveKind.fade => 420,
        PvArriveKind.settle => 380,
        PvArriveKind.rise => 520,
      }),
    );
    if (wait <= Duration.zero) {
      c.forward();
    } else {
      Future<void>.delayed(wait, () {
        if (mounted) c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    if (c == null) return widget.child;
    final a = CurvedAnimation(parent: c, curve: Curves.easeOutCubic);
    if (widget.kind == PvArriveKind.fade) {
      return FadeTransition(opacity: a, child: widget.child);
    }
    final rise = widget.kind == PvArriveKind.rise ? 60.0 : 10.0;
    return AnimatedBuilder(
      animation: a,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: a.value,
        child: Transform.translate(
          offset: Offset(0, rise * (1 - a.value)),
          child: child,
        ),
      ),
    );
  }
}

/// The sheet's sections, each in its slot, [PvArriveAt.step] apart. Spacers
/// pass through untouched and take no slot; after the tenth section the rest
/// share the last slot, so nothing waits more than a second.
List<Widget> pvArriveEach(List<Widget> children,
    {Duration start = PvArriveAt.sections}) {
  var i = 0;
  return [
    for (final c in children)
      if (c is SizedBox && c.child == null)
        c
      else
        PvArrive(
          delay: start + PvArriveAt.step * (i++).clamp(0, 10),
          child: c,
        ),
  ];
}

/// [text] with its first number counting up from zero on the first home
/// ("in 3 days", "Week 14", "14 weeks"). Everywhere else, [text] as it is.
class PvArriveCount extends StatefulWidget {
  const PvArriveCount({super.key, required this.text, required this.builder});

  final String text;
  final Widget Function(String shown) builder;

  @override
  State<PvArriveCount> createState() => _PvArriveCountState();
}

class _PvArriveCountState extends State<PvArriveCount>
    with SingleTickerProviderStateMixin {
  static final _number = RegExp(r'\d+');
  AnimationController? _c;
  bool _decided = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decided) return;
    _decided = true;
    final start =
        context.getInheritedWidgetOfExactType<_ArrivalScope>()?.start;
    final calm = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (start == null || calm || !_number.hasMatch(widget.text)) return;
    // Only in the first moments; a hero rebuilt later just shows its number.
    if (DateTime.now().difference(start) > const Duration(milliseconds: 600)) {
      return;
    }
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    if (c == null) return widget.builder(widget.text);
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        // Once the count is done, or the text has moved on (she tapped
        // another day), the real words.
        if (c.isCompleted) return widget.builder(widget.text);
        final t = Curves.easeOutCubic.transform(c.value);
        final shown = widget.text.replaceFirstMapped(
            _number, (m) => '${(int.parse(m[0]!) * t).round()}');
        return widget.builder(shown);
      },
    );
  }
}
