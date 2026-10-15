// The one notice (DESIGN-SYSTEM §4.0g). Every "done", "saved", "undo",
// "copied" and gentle error in the app goes through `pvToast`.
//
// ⚠️ WHY NOT A SnackBar (2026-10-15). The user: "our app lacks toasts a lot",
// asking for the motion and smoothness that Mobbin apps have. The old path
// was ~190 `showSnackBar` calls in two looks (the white `pvSnack` card and the
// theme's dark bar), and the SnackBar itself fought every part of the brief:
//  · a new notice CUT the old one (`clearSnackBars`) instead of morphing;
//  · its exit was a flat fade; no swipe-away, no press-and-hold;
//  · Flutter 3.44 made any SnackBar with an action persist until dismissed;
//  · it belongs to the nearest Scaffold, so a notice raised from a sheet or
//    from the doctor overlay landed behind or inside the wrong layer.
// So this is one `OverlayEntry` on the root overlay, owned by a singleton.
// Trade-off: Scaffold no longer lifts the notice over a FAB or sheet for us.
// We already computed our own lift per route (`pvSnackLiftFor`), so that
// costs nothing we were using.
//
// Mobbin, 2026-10-15 (~60 screens): Linear, eBay, Google Photos, AllTrails,
// Gopuff (undo at the bottom, the action on the right); NYT, Google, Flo,
// Digg, Substack (a save says where it went, with View); Alan, Klarna,
// Perplexity, Luma (the tick says done before the words do); Sesame (a calm
// cream card for an error, never alarm red). One notice at a time in all.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/v2/v2_palette.dart';
import '../services/father_preview.dart';
import '../services/life_stage_store.dart';
import '../theme/pv_fonts.dart';
import '../theme/pv_motion.dart';
import 'global_ask_fab.dart' show appNavigatorKey, fabRouteObserver;
import 'pv_feedback.dart' show PvPress;

/// What the notice is saying. The mark and the haptic follow the kind; a
/// caller never picks them, so "done" looks and feels the same everywhere.
enum PvToastKind {
  /// Something she did has landed. Green tick, light haptic.
  done,

  /// Something was kept for later. Bookmark mark; pair with `action: 'View'`.
  saved,

  /// Something was removed or changed and can be taken back. No mark; the
  /// Undo pill is the point.
  undo,

  /// Neutral words ("Copied", "Opens soon"). No mark.
  info,

  /// Something did not go through. A calm cream card, never red: nothing in
  /// this app is lost on a failure, because it is all saved on the phone.
  gentle,

  /// Something is in progress. A small spinner, no timeout; the handle turns
  /// it into `done` or `gentle` in place.
  working,
}

/// Show a notice. Replaces (morphs) any notice already showing.
///
/// [action] is the pill's word ("Undo", "View"); [onAction] runs at most
/// once. [lift] is how far above the screen's foot the card floats; null
/// reads the route (above the nav bar on a stage home, at the foot on a
/// pushed screen, above the Store's buy bar in the Store). [icon] overrides
/// the kind's mark when a confirmation has a more specific one.
PvToastHandle pvToast(
  BuildContext context,
  String text, {
  PvToastKind kind = PvToastKind.info,
  String? action,
  VoidCallback? onAction,
  double? lift,
  IconData? icon,
}) =>
    PvToast.instance.show(context, text,
        kind: kind, action: action, onAction: onAction, lift: lift, icon: icon);

/// A notice for work in progress: `pvToastWorking(c, 'Booking…')`, then
/// `handle.done('Booked')` or `handle.gentle('Could not book. Try again.')`.
PvToastHandle pvToastWorking(BuildContext context, String text, {double? lift}) =>
    PvToast.instance.show(context, text, kind: PvToastKind.working, lift: lift);

/// Turns a notice that is still showing into another, in place.
class PvToastHandle {
  const PvToastHandle._(this._id);
  final int _id;

  void done(String text, {String? action, VoidCallback? onAction}) =>
      PvToast.instance._update(_id, text, PvToastKind.done, action, onAction);

  void gentle(String text, {String? action, VoidCallback? onAction}) =>
      PvToast.instance._update(_id, text, PvToastKind.gentle, action, onAction);

  void dismiss() {
    if (PvToast.instance._current?.id == _id) PvToast.instance.dismiss();
  }

  /// Completes when these words leave the screen: timed out, swiped away,
  /// actioned, or replaced by a newer notice. For work that must wait out an
  /// Undo (deleting a file only once Undo is no longer on offer).
  Future<void> get closed =>
      PvToast.instance._closers[_id]?.future ?? Future<void>.value();
}

class PvToastData {
  const PvToastData({
    required this.id,
    required this.text,
    required this.kind,
    this.action,
    this.onAction,
    this.lift,
    this.icon,
  });
  final int id;
  final String text;
  final PvToastKind kind;
  final String? action;
  final VoidCallback? onAction;
  final double? lift;
  final IconData? icon;

  /// How long it stays. Long enough to read, short enough not to linger:
  /// 2.4 s for a line, 4.5 s when there is something to tap, plus 60 ms a
  /// word past six, never more than 6 s. A spinner stays until it resolves.
  Duration? get hold {
    if (kind == PvToastKind.working) return null;
    final words = text.trim().split(RegExp(r'\s+')).length;
    final base = action == null ? 2400 : 4500;
    final extra = words > 6 ? (words - 6) * 60 : 0;
    return Duration(milliseconds: (base + extra).clamp(0, 6000));
  }
}

/// Owner of the single notice. Singleton `ChangeNotifier`, the house style.
class PvToast extends ChangeNotifier {
  PvToast._();
  static final PvToast instance = PvToast._();

  PvToastData? _current;
  PvToastData? get current => _current;

  OverlayEntry? _entry;
  _PvToastHostState? _host;
  int _seq = 0;
  final Map<int, Completer<void>> _closers = {};

  void _closeAll() {
    for (final c in _closers.values) {
      if (!c.isCompleted) c.complete();
    }
    _closers.clear();
  }

  PvToastHandle show(
    BuildContext context,
    String text, {
    PvToastKind kind = PvToastKind.info,
    String? action,
    VoidCallback? onAction,
    double? lift,
    IconData? icon,
  }) {
    final data = PvToastData(
      id: ++_seq,
      text: text,
      kind: kind,
      action: action,
      onAction: onAction,
      lift: lift ?? pvSnackLiftFor(context),
      icon: icon,
    );
    final handle = PvToastHandle._(data.id);
    // The root overlay, so a notice raised from a sheet or a dialog still
    // lands above everything. A context that IS a navigator (the period
    // nudge passes `navigator.context`) has no overlay above it, only below.
    final overlay = (context.mounted
            ? (Overlay.maybeOf(context, rootOverlay: true) ??
                Navigator.maybeOf(context)?.overlay)
            : null) ??
        appNavigatorKey.currentState?.overlay;
    if (overlay == null) return handle;
    _closeAll();
    _closers[data.id] = Completer<void>();
    _current = data;
    _feel(kind);
    if (_entry != null && _entry!.mounted && _host != null) {
      _host!._present();
    } else {
      _entry = OverlayEntry(builder: (_) => const _PvToastHost());
      overlay.insert(_entry!);
    }
    notifyListeners();
    return handle;
  }

  /// Send the showing notice away.
  void dismiss() => _host?._exit();

  void _update(int id, String text, PvToastKind kind, String? action,
      VoidCallback? onAction) {
    final c = _current;
    if (c == null || c.id != id || _host == null) return;
    // The same notice, new words: the id (and so the handle, and its
    // `closed`) carries over; the card cross-fades on its content.
    _current = PvToastData(
        id: id,
        text: text,
        kind: kind,
        action: action,
        onAction: onAction,
        lift: c.lift);
    _feel(kind);
    _host!._present();
    notifyListeners();
  }

  void _removed(_PvToastHostState host) {
    if (_host != host) return;
    _entry?.remove();
    _entry = null;
    _host = null;
    _current = null;
    _closeAll();
  }

  static void _feel(PvToastKind kind) {
    switch (kind) {
      case PvToastKind.done:
      case PvToastKind.saved:
        HapticFeedback.lightImpact();
      case PvToastKind.undo:
        HapticFeedback.selectionClick();
      case PvToastKind.info:
      case PvToastKind.gentle:
      case PvToastKind.working:
        break;
    }
  }
}

/// The card itself; a type tests can find.
class PvToastCard extends StatelessWidget {
  const PvToastCard({super.key, required this.data, required this.onAction});
  final PvToastData data;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final gentle = data.kind == PvToastKind.gentle;
    final mark = _mark(p);
    final hasAction = data.action != null;
    return Container(
      padding: EdgeInsets.fromLTRB(mark == null ? 16 : 12, hasAction ? 4 : 10,
          hasAction ? 4 : 16, hasAction ? 4 : 10),
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        // ⚠️ WHITE (the user's rule, 2026-09-23): an ink notice over the ink
        // nav bar read as one object. A gentle one is a warm cream, still
        // light; never red, never the brand colour.
        color: gentle ? const Color(0xFFFBF5E8) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: gentle
                ? const Color(0xFFE6D3A8)
                : p.ink1.withValues(alpha: 0.10),
            width: 1),
        // A shadow you can see (2026-10-01): white on a white page needs a
        // real fall and a contact shadow to lift off the ground.
        boxShadow: [
          BoxShadow(
              color: p.ink1.withValues(alpha: 0.24),
              blurRadius: 30,
              spreadRadius: 1,
              offset: const Offset(0, 12)),
          BoxShadow(
              color: p.ink1.withValues(alpha: 0.16),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(children: [
        if (mark != null) ...[mark, const SizedBox(width: 10)],
        Expanded(
          child: Text(data.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: p.ink1)),
        ),
        if (hasAction) ...[
          const SizedBox(width: 8),
          // 44pt to tap, 32pt to see: the transparent margin is the target.
          PvPress(child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Container(
                height: 32,
                padding: EdgeInsets.fromLTRB(
                    14, 0, data.kind == PvToastKind.undo ? 14 : 10, 0),
                decoration: ShapeDecoration(
                    color: p.ink1, shape: const StadiumBorder()),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(data.action!,
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  // An arrow means "go there"; Undo goes nowhere.
                  if (data.kind != PvToastKind.undo) ...[
                    const SizedBox(width: 3),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 15, color: Colors.white),
                  ],
                ]),
              ),
            ),
          )),
        ],
      ]),
    );
  }

  Widget? _mark(V2Palette p) {
    const size = 30.0;
    Widget disc(Color bg, Widget child) => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: child,
        );
    Widget icon(IconData i, Color c) => Icon(i, size: 17, color: c);
    final Widget? m = switch (data.kind) {
      PvToastKind.done => disc(const Color(0xFFE3F2E6),
          icon(data.icon ?? Icons.check_rounded, const Color(0xFF2E7D4F))),
      PvToastKind.saved => disc(p.ink1.withValues(alpha: 0.07),
          icon(data.icon ?? Icons.bookmark_rounded, p.ink1)),
      PvToastKind.gentle => disc(const Color(0xFFF1E2BF),
          icon(data.icon ?? Icons.info_outline_rounded, const Color(0xFF7A5A14))),
      PvToastKind.working => disc(
          p.ink1.withValues(alpha: 0.07),
          SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(strokeWidth: 2, color: p.ink1),
          )),
      PvToastKind.info || PvToastKind.undo =>
        data.icon == null ? null : disc(p.ink1.withValues(alpha: 0.07), icon(data.icon!, p.ink1)),
    };
    if (m == null || data.kind == PvToastKind.working) return m;
    // The mark lands a beat after the card, so it reads as "done" before the
    // words do.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: PvMotion.enter,
      curve: const Interval(0.17, 1, curve: PvMotion.settle),
      builder: (_, v, child) => Transform.scale(scale: 0.6 + 0.4 * v, child: child),
      child: m,
    );
  }
}

class _PvToastHost extends StatefulWidget {
  const _PvToastHost();
  @override
  State<_PvToastHost> createState() => _PvToastHostState();
}

class _PvToastHostState extends State<_PvToastHost>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: PvMotion.enter,
    reverseDuration: PvMotion.exit,
  )..addStatusListener(_onStatus);
  late final Animation<double> _move = CurvedAnimation(
      parent: _ctrl, curve: PvMotion.settle, reverseCurve: PvMotion.leave);
  late final Animation<double> _fade = CurvedAnimation(
      parent: _ctrl, curve: PvMotion.arrive, reverseCurve: PvMotion.leave);

  // A finger dragging the card down, and the spring back if it lets go short.
  late final AnimationController _snap =
      AnimationController(vsync: this, duration: PvMotion.exit);
  double _drag = 0;
  double _dragFrom = 0;

  Timer? _timer;
  bool _exiting = false;
  bool _held = false;

  PvToast get _owner => PvToast.instance;

  @override
  void initState() {
    super.initState();
    _owner._host = this;
    _snap.addListener(() => setState(() => _drag = _dragFrom * (1 - _snap.value)));
    _ctrl.forward();
    _arm();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    _snap.dispose();
    if (_owner._host == this) _owner._host = null;
    super.dispose();
  }

  void _present() {
    _exiting = false;
    if (mounted) setState(() {});
    _ctrl.forward();
    _arm();
  }

  void _exit() {
    if (_exiting) return;
    _timer?.cancel();
    _exiting = true;
    _ctrl.reverse();
  }

  void _arm() {
    _timer?.cancel();
    if (_held) return;
    final hold = _owner.current?.hold;
    if (hold == null) return;
    _timer = Timer(hold, _exit);
  }

  void _onStatus(AnimationStatus s) {
    if (s == AnimationStatus.dismissed && _exiting) _owner._removed(this);
  }

  void _hold(bool on) {
    _held = on;
    if (on) {
      _timer?.cancel();
    } else if (!_exiting) {
      // Let go: a short, fresh beat to finish reading, not the full hold.
      _timer = Timer(const Duration(milliseconds: 1500), _exit);
    }
  }

  void _tapAction(PvToastData d) {
    // At most once: a double tap on Undo must not undo twice.
    if (_exiting) return;
    _exit();
    d.onAction?.call();
  }

  @override
  Widget build(BuildContext context) {
    final data = _owner.current;
    if (data == null) return const SizedBox.shrink();
    final mq = MediaQuery.of(context);
    final still = mq.disableAnimations;
    // Above the keyboard when one is up; otherwise the route's lift.
    final bottom = [
      (data.lift ?? kPvStickyBarClearance) + mq.padding.bottom,
      mq.viewInsets.bottom + 16,
    ].reduce((a, b) => a > b ? a : b);
    return Stack(children: [
      Positioned(
        left: 16,
        right: 16,
        bottom: bottom,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final v = _move.value;
            final rise = _ctrl.status == AnimationStatus.reverse ? 12.0 : 24.0;
            return Opacity(
              opacity: _fade.value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, (still ? 0 : (1 - v) * rise) + _drag),
                child: Transform.scale(
                  scale: still ? 1 : 0.96 + 0.04 * v,
                  child: child,
                ),
              ),
            );
          },
          child: Listener(
            onPointerDown: (_) => _hold(true),
            onPointerUp: (_) => _hold(false),
            onPointerCancel: (_) => _hold(false),
            child: GestureDetector(
              onVerticalDragUpdate: (d) => setState(() {
                // Down follows the finger; up resists.
                final dy = d.delta.dy;
                _drag = (_drag + (dy < 0 ? dy * 0.25 : dy)).clamp(-12.0, 200.0);
              }),
              onVerticalDragEnd: (d) {
                if (_drag > 36 || (d.primaryVelocity ?? 0) > 500) {
                  _exit();
                } else {
                  _dragFrom = _drag;
                  _snap.forward(from: 0);
                }
              },
              child: Material(
                type: MaterialType.transparency,
                child: Semantics(
                  liveRegion: true,
                  container: true,
                  child: AnimatedSize(
                    duration: still ? Duration.zero : PvMotion.resize,
                    curve: PvMotion.arrive,
                    alignment: Alignment.bottomCenter,
                    child: AnimatedSwitcher(
                      duration: still ? Duration.zero : PvMotion.swap,
                      switchInCurve: PvMotion.arrive,
                      switchOutCurve: PvMotion.leave,
                      layoutBuilder: (current, previous) => Stack(
                        alignment: Alignment.bottomCenter,
                        children: [...previous, ?current],
                      ),
                      child: PvToastCard(
                        key: ValueKey(Object.hash(data.id, data.text, data.kind)),
                        data: data,
                        onAction: () => _tapAction(data),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

// ---- where a notice floats ---------------------------------------------------
// Moved here from `pv_store_chrome.dart` on 2026-10-15 with the rules
// unchanged; that file re-exports them so existing imports keep working.

/// Where a notice floats from: above the sticky commit bar (52 pill + 12 +
/// 12 = 76) AND above the Ask pill's lane (it sits at bottom 92, 64 tall),
/// so a notice with an action never has its action under the FAB — found on
/// the phone with "View bag" half-covered.
const double kPvStickyBarClearance = 164;

/// ⚠️ WHERE A NOTICE SITS IN TRYING TO CONCEIVE (2026-09-30). Every caller
/// that passed no `lift` got the Store's 164, which clears the Store's sticky
/// buy bar and nothing else. Trying to conceive has no such bar, so "Logged
/// for 28 September" and "Your period is logged" floated in the middle of the
/// home and the cycle report, over the content (the user: "the pop up that is
/// appearing in the center of the screen has not been fixed"). So, by the top
/// route: the TTC home, which hosts all five tabs under a floating bar 14
/// above the inset and about 70 tall, sits the notice just above that bar;
/// any other TTC screen sits it at the foot like every lifted TTC call
/// already did (`lift: 24`). Other stages and the Store keep 164 until
/// someone walks them. Null means "the caller's default".
const double kPvSnackOverTtcBar = 96;
const double kPvSnackAtFoot = 24;

double? pvSnackLiftFor(BuildContext context) {
  // ⚠️ THE TOP PAGE, NOT THE TOP ROUTE (2026-09-30, second pass). The first
  // version read the top route with popUntil, and a sheet that had just
  // called `maybePop` (async) was still that route: unnamed, so the notice
  // fell back to the Store's 164 and floated mid-screen over the Cycle
  // companion's dates (seen on the phone). The app's route observer skips
  // sheets, dialogs and menus. Kept for revert: the popUntil read of
  // `Navigator.maybeOf(context)`.
  final name = fabRouteObserver.topPageName;
  if (name != null && name.startsWith('ttc')) {
    return name == 'ttc/today' ? kPvSnackOverTtcBar : kPvSnackAtFoot;
  }
  // ⚠️ PREGNANCY SITS WHERE TRYING TO CONCEIVE'S DOES (2026-10-02, the user:
  // "toast alert in pregnancy side needs to be like TTC"). Pregnancy's shell
  // is unnamed, so it got the Store's 164, which floated a notice mid-screen
  // over the content. Now: just above the bottom bar while only the shell is
  // showing (the same `PvNavBar` as trying to conceive, so the same 96), and
  // at the foot on any screen pushed over it. The Store's own screens keep
  // the default, because their sticky buy bar needs the 164. The father's
  // shell is not drawn the same way and keeps the default.
  final stage = LifeStageStore.instance.stage ?? LifeStage.pregnancy;
  if (stage == LifeStage.pregnancy &&
      !FatherPreview.instance.on &&
      !(name ?? '').startsWith('store/')) {
    return fabRouteObserver.pageCount <= 1 ? kPvSnackOverTtcBar : kPvSnackAtFoot;
  }
  return null;
}
