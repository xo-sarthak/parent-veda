// =============================================================================
//  Global "Ask Veda" FAB — one floating button, on every screen, both apps
// -----------------------------------------------------------------------------
//  Injected once via MaterialApp.builder so it floats over EVERY route in the
//  pregnancy AND parenting apps, home screens included — rather than being
//  hand-added to dozens of Scaffolds.
//
//  It is deliberately quiet about which Ask Veda it opens: a route observer
//  tracks whether the parenting stack ('pp/my_child') is on screen, and the FAB
//  opens the parenting Ask Veda there and the pregnancy Ask Veda everywhere
//  else. It hides itself over modal sheets, dialogs, the Premiere takeover, and
//  before the app shell is up (splash).
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/post_pregnancy/askveda_screen.dart' as pp;
import '../screens/tools/ask_veda_screen.dart' as preg;
import '../services/app_nav.dart';
import '../services/father_preview.dart';
import '../services/pregnancy_controller.dart';

/// The one navigator the FAB pushes onto (the app's root navigator).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// The route name the parenting doorway uses; also how we know we're "in" the
/// parenting app.
const String kParentingRootRoute = 'pp/my_child';

/// The route name given to the Premiere takeover + the Ask Veda screens, so the
/// FAB can suppress itself over them.
const String kPremiereRoute = 'premiere';
const String kAskVedaRoute = 'askveda';

/// Shared, tiny reactive state the observer writes and the FAB reads.
class FabState extends ChangeNotifier {
  FabState._();
  static final FabState instance = FabState._();

  bool _appLive = false; // false during splash, before the shell mounts
  bool _inParenting = false;
  bool _suppressed = false; // over a sheet / dialog / premiere / ask screen

  bool get visible => _appLive && !_suppressed;
  bool get inParenting => _inParenting;

  /// Called from the app shell's initState — the FAB only shows once a real
  /// screen (not the splash) is up.
  void markAppLive() {
    if (_appLive) return;
    _appLive = true;
    notifyListeners();
  }

  void _update({bool? inParenting, bool? suppressed}) {
    var changed = false;
    if (inParenting != null && inParenting != _inParenting) {
      _inParenting = inParenting;
      changed = true;
    }
    if (suppressed != null && suppressed != _suppressed) {
      _suppressed = suppressed;
      changed = true;
    }
    if (changed) notifyListeners();
  }
}

/// Tracks the route stack so the FAB knows where it is and whether to hide.
class FabRouteObserver extends NavigatorObserver {
  final List<Route<dynamic>> _stack = [];

  void _recompute() {
    final inParenting = _stack.any((r) => r.settings.name == kParentingRootRoute);
    final top = _stack.isEmpty ? null : _stack.last;
    final suppressed = top != null &&
        (top is PopupRoute || // modal sheets, dialogs, menus
            top.settings.name == kPremiereRoute ||
            top.settings.name == kAskVedaRoute);
    FabState.instance._update(inParenting: inParenting, suppressed: suppressed);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.add(route);
    _recompute();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _recompute();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _recompute();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final i = oldRoute == null ? -1 : _stack.indexOf(oldRoute);
    if (i >= 0 && newRoute != null) {
      _stack[i] = newRoute;
    } else if (newRoute != null) {
      _stack.add(newRoute);
    }
    _recompute();
  }
}

final FabRouteObserver fabRouteObserver = FabRouteObserver();

class GlobalAskFab extends StatelessWidget {
  const GlobalAskFab({super.key, required this.pregnancy});

  /// Needed by the pregnancy Ask Veda (it answers from whole-app data).
  final PregnancyController pregnancy;

  void _open() {
    final nav = appNavigatorKey.currentState;
    if (nav == null) return;
    final parenting = FabState.instance.inParenting;
    nav.push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: kAskVedaRoute),
      builder: (_) => parenting ? const pp.AskVedaScreen() : preg.AskVedaScreen(controller: pregnancy),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([FabState.instance, FatherPreview.instance, AppNav.instance]),
      builder: (context, _) {
        if (!FabState.instance.visible) return const SizedBox.shrink();

        // Clear the bottom chrome. On the pregnancy Today tab a Mom|Dad dev
        // pill floats at bottom:96, so sit above it there; otherwise clear the
        // bottom nav pill.
        final onPregToday = !FabState.instance.inParenting && AppNav.instance.index == AppNav.todayTab;
        final bottom = onPregToday ? 150.0 : 92.0;
        final pad = MediaQuery.of(context).padding.bottom;

        return Positioned(
          right: 16,
          bottom: bottom + (pad > 0 ? 0 : 6),
          child: _pill(),
        );
      },
    );
  }

  // The original parenting Ask-Veda FAB: a plain circle with the sparkle icon,
  // nothing else. Same on both apps now.
  Widget _pill() => Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _open,
          customBorder: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF6A30B6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0x4D6A30B6), blurRadius: 16, spreadRadius: -2, offset: Offset(0, 6)),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 24, color: Colors.white),
          ),
        ),
      );
}
