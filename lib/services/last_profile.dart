// =============================================================================
//  Open on the last profile used (F6, 2026-10-25, STAGE-TRANSITIONS)
// -----------------------------------------------------------------------------
//  Each pregnancy and each child is its own profile, and the stage's own home
//  is the navigator's root; a child's home is pushed over it
//  (pv_family_switch.dart). Before this, every launch opened the root, so a
//  pregnant mother last looking at her toddler's home reopened on the
//  pregnancy home.
//
//  ⚠️ ONLY A CHILD'S HOME IS EVER PUSHED. A pregnancy profile exists only while
//  the stage is pregnancy and the trying profile only while it is TTC
//  (`familyProfilesFrom`), so both are always the root. What can be on top is
//  a parenting home or a learning space, and which child each shows is already
//  saved by its own store (`ChildProfileStore`'s active child, `SkChildStore`'s
//  open child). So the one fact saved here is WHICH HOME was on top:
//  'parenting', 'learning' or 'root'. Not the child's id: she can switch
//  children inside the same home with no route change, and a saved id would
//  then reopen the child she had already left.
//
//  ⚠️ RECORDED FROM THE ROUTE STACK, NOT FROM THE TAPS. The observer sees every
//  way a child's home reaches the top (the family switch, the drawer door, a
//  tapped message, the pregnancy You's older-child row) and the back button
//  that leaves it, without each caller remembering to record. The cost: it
//  reads route NAMES, so a child's home pushed under a new name would be
//  missed; test/last_profile_test.dart scans every push of the two homes.
//
//  Phone-only, like the open child: no cloud column, no sync step.
// =============================================================================

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/post_pregnancy/pp_child_profile.dart';
import '../screens/skilling/sk_child_store.dart';
import '../screens/v2/pv_family_switch.dart';
import '../widgets/global_ask_fab.dart' show kParentingRootRoute;
import 'life_stage_store.dart';
import 'notification_service.dart';
import 'pregnancy_ended_store.dart';
import 'remote/sync_registry.dart';

/// The learning space's route name, wherever it is pushed as a profile.
const String kLearningHomeRoute = 'skilling';

const String kLastHomeKey = 'pv_last_home';
const String kLastHomeRoot = 'root';
const String kLastHomeParenting = 'parenting';
const String kLastHomeLearning = 'learning';

/// Which home is on top, from the route names bottom first. The root is never
/// counted (it is the stage's own home); the highest child's home above it
/// wins, whatever pages are pushed over that home.
@visibleForTesting
String lastHomeFromStack(List<String?> names) {
  for (var i = names.length - 1; i >= 1; i--) {
    final n = names[i];
    if (n == kParentingRootRoute) return kLastHomeParenting;
    if (n == kLearningHomeRoute) return kLastHomeLearning;
  }
  return kLastHomeRoot;
}

/// The profile to open over the root at launch, or null to stay on the root.
/// Pure, so the cases are tested without a navigator.
///
/// ⚠️ NULL WHENEVER THE SAVED HOME NO LONGER FITS. The child was deleted, the
/// learning space's yes was taken back, or the stage moved so that home is
/// the root itself: she lands on the root, exactly as before F6. A stale
/// value can never open a profile that is not there.
@visibleForTesting
FamilyProfile? profileToReopen({
  required String? saved,
  required List<FamilyProfile> all,
  required FamilyHome root,
  required String? activeChildId,
  required String? learningOpenId,
}) {
  final FamilyHome want;
  final String? id;
  switch (saved) {
    case kLastHomeParenting:
      want = FamilyHome.parenting;
      id = activeChildId;
    case kLastHomeLearning:
      want = FamilyHome.learning;
      id = learningOpenId;
    default:
      return null;
  }
  if (want == root || id == null) return null;
  for (final p in all) {
    if (p.kind == FamilyProfileKind.child && p.id == id && p.home == want) return p;
  }
  return null;
}

class LastProfile {
  // ⚠️ THE LAST HOME IS THE PERSON'S, NOT THE PHONE'S (caught by
  // test/sync_reset_coverage_test.dart): a second account signing in on this
  // phone must not open on the first one's child. Sign out wipes the key with
  // the rest of prefs; the reset forgets what this run wrote.
  LastProfile._() {
    SyncRegistry.registerReset(_reset);
  }
  static final LastProfile instance = LastProfile._();

  List<String?> _names = const [];
  String? _written;
  bool _homeShown = false;

  /// True once the splash has handed over to a home (and the last profile, if
  /// any, is open). The message openers wait for it: before it, a tapped
  /// message would be pushed under the splash's `pushReplacement` and lost.
  ///
  /// Not `FabState`'s app-live flag: only the pregnancy shell and the TTC home
  /// raise that one, so a family whose root is parenting or the learning space
  /// would have waited forever.
  bool get homeShown => _homeShown;

  /// The home on top right now ('parenting', 'learning' or 'root').
  String get onTop => lastHomeFromStack(_names);

  void _noteStack(List<String?> names) {
    _names = names;
    if (_homeShown) _write();
  }

  /// The home is up. From now on what is on top is saved.
  void markHomeShown() {
    _homeShown = true;
    _write();
  }

  /// Sign out puts the splash back. Taps wait again, and nothing is saved
  /// until the next home is shown.
  void markSignedOut() => _homeShown = false;

  void _reset() {
    _written = null;
    _homeShown = false;
    SharedPreferences.getInstance()
        .then((p) => p.remove(kLastHomeKey))
        .catchError((_) => false);
  }

  void _write() {
    final v = onTop;
    if (v == _written) return;
    _written = v;
    SharedPreferences.getInstance()
        .then((p) => p.setString(kLastHomeKey, v))
        .catchError((_) => false);
  }

  @visibleForTesting
  void debugReset() {
    _names = const [];
    _written = null;
    _homeShown = false;
  }
}

/// Keeps the route names in order for [LastProfile]. The same push / pop /
/// remove / replace shape as `FabRouteObserver`.
class LastProfileObserver extends NavigatorObserver {
  final List<Route<dynamic>> _stack = [];

  void _changed() =>
      LastProfile.instance._noteStack([for (final r in _stack) r.settings.name]);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.add(route);
    _changed();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _changed();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _changed();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final i = oldRoute == null ? -1 : _stack.indexOf(oldRoute);
    if (i >= 0 && newRoute != null) {
      _stack[i] = newRoute;
    } else if (newRoute != null) {
      _stack.add(newRoute);
    }
    _changed();
  }
}

final LastProfileObserver lastProfileObserver = LastProfileObserver();

/// Called by the splash right after it has put the stage's home on screen.
/// Opens the child's home she last had on top, then marks the home shown,
/// always, so a failure here never leaves the message openers waiting.
///
/// Skipped for the partner (his launch follows her stage, as before) and when
/// a notification tap launched the app: the tap wins, and what it opens is
/// then saved as the last profile.
Future<void> restoreLastProfile(NavigatorState nav, {required bool father}) async {
  try {
    if (father || NotificationService.instance.launchedFromTap) return;
    // Each is idempotent and already started in main.dart; at splash time
    // they have long finished, so this is a formality on a real launch.
    await Future.wait(<Future<void>>[
      LifeStageStore.instance.ready,
      ChildProfileStore.instance.init(),
      SkChildStore.instance.load(),
      PregnancyEndedStore.instance.load(),
    ].map((f) => f.catchError((_) {})));
    final prefs = await SharedPreferences.getInstance();
    final root = familyRootHome();
    final to = profileToReopen(
      saved: prefs.getString(kLastHomeKey),
      all: familyProfiles(),
      root: root,
      activeChildId: ChildProfileStore.instance.activeChildId,
      learningOpenId: SkChildStore.instance.openId,
    );
    if (to != null && nav.mounted) openFamilyProfile(nav.context, to, root);
  } catch (_) {
    // The root is already on screen: that is the right fallback.
  } finally {
    LastProfile.instance.markHomeShown();
  }
}
