// =============================================================================
//  PvTabFadeStack: one tab switch for every stage (2026-10-21)
// -----------------------------------------------------------------------------
//  The user: "the effect when you change tabs is different on parenting, is
//  different on pregnancy, so that needs to be one. The effect on parenting is
//  not looking good, it just looks very jittery."
//
//  Trying to conceive already had the right one (ttc_tab_host.dart, 2026-09):
//  every tab lives in one route, and a switch is a 300ms fade-through, the
//  Material 3 pattern. Pregnancy swapped tabs in an IndexedStack with no motion
//  at all; Parenting pushed a new route per tab, so the page slid, its bar slid
//  with it, and the tab was rebuilt and lost its scroll. This is the TTC code
//  lifted unchanged so all three stages share it.
//
//  What a host still owns: its bar, its back rule (PopScope) and the store
//  that says which tab is showing. This widget owns only the pages and the
//  motion between them.
// =============================================================================

import 'package:flutter/material.dart';

/// How long one tab switch takes. Material 3's fade through is 300ms.
const Duration kPvTabSwitch = Duration(milliseconds: 300);

class PvTabFadeStack extends StatefulWidget {
  const PvTabFadeStack({
    super.key,
    required this.index,
    required this.count,
    required this.builder,
    this.lazy = true,
    this.wrap,
    this.keyPrefix = 'pv_tab',
  });

  /// The tab showing now.
  final int index;
  final int count;

  /// Builds tab [i]'s page. Called once per tab while it is kept.
  final Widget Function(BuildContext context, int i) builder;

  /// True: a tab is built the first time it is opened, then kept. False: all
  /// are built up front, as the IndexedStack it replaces did.
  final bool lazy;

  /// Wraps a built page (a scroll controller, a scope). Must return the same
  /// shape of tree every time, or the page's state is thrown away.
  final Widget Function(int i, Widget page)? wrap;

  /// Each tab is keyed `prefix_i`.
  final String keyPrefix;

  @override
  State<PvTabFadeStack> createState() => _PvTabFadeStackState();
}

class _PvTabFadeStackState extends State<PvTabFadeStack> with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(vsync: this, duration: kPvTabSwitch, value: 1)
    ..addStatusListener((s) {
      // The tab that faded out goes offstage once the fade is done.
      if (s == AnimationStatus.completed && mounted) setState(() {});
    });

  // Fade through: out in the first 30%, in (and settling from 97%) after.
  late final Animation<double> _in =
      CurvedAnimation(parent: _fade, curve: const Interval(0.3, 1, curve: Curves.easeOutCubic));
  late final Animation<double> _out =
      ReverseAnimation(CurvedAnimation(parent: _fade, curve: const Interval(0, 0.3, curve: Curves.easeIn)));
  late final Animation<double> _scale = Tween<double>(begin: 0.97, end: 1).animate(_in);

  late final Set<int> _built = widget.lazy ? {widget.index} : {for (var i = 0; i < widget.count; i++) i};
  late int _from = widget.index;
  late int _to = widget.index;

  @override
  void didUpdateWidget(PvTabFadeStack old) {
    super.didUpdateWidget(old);
    final next = widget.index;
    if (next == _to) return;
    // A field on the tab she is leaving must not keep the keyboard up.
    FocusManager.instance.primaryFocus?.unfocus();
    _from = _to;
    _to = next;
    _built.add(next);
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _fade.value = 1;
    } else {
      _fade.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  Widget _tab(BuildContext context, int i) {
    if (!_built.contains(i)) return const SizedBox.shrink();
    final active = i == _to;
    final leaving = !active && i == _from && _fade.isAnimating;
    final shown = active || leaving;
    final page = widget.builder(context, i);
    // ⚠️ THE SAME WRAPPERS IN EVERY STATE. Adding or removing a transition
    // widget when a tab goes on or off stage would change the tree above the
    // page, and Flutter would throw the page's state away with it.
    return Offstage(
      offstage: !shown,
      child: TickerMode(
        enabled: shown,
        child: HeroMode(
          // Only the showing tab's photos may fly to a pushed page.
          enabled: active,
          child: IgnorePointer(
            ignoring: !active,
            child: ExcludeSemantics(
              excluding: !active,
              child: FadeTransition(
                opacity: active
                    ? _in
                    : leaving
                        ? _out
                        : kAlwaysCompleteAnimation,
                child: ScaleTransition(
                  scale: active ? _scale : kAlwaysCompleteAnimation,
                  child: widget.wrap?.call(i, page) ?? page,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        for (var i = 0; i < widget.count; i++)
          KeyedSubtree(key: ValueKey('${widget.keyPrefix}_$i'), child: _tab(context, i)),
      ]);
}
