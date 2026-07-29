// =============================================================================
//  AppShell - the door between life stages
// -----------------------------------------------------------------------------
//  A life-stage change is the only event in this product that has to replace the
//  entire app, and until now nothing could perform one. The reason is a plain
//  ownership problem rather than a missing feature:
//
//    * `MainScaffold` needs three long-lived controllers - `PregnancyController`,
//      the home controller and the father controller - and they are created in
//      `_ParentVedaAppState`, above every route.
//    * Nothing inside `lib/screens/ttc/` can reach them, and it should not be
//      able to: the stages are deliberately isolated, and handing TTC a
//      pregnancy controller would be exactly the coupling the folder layout
//      exists to prevent.
//
//  So the two halves never met, and both doors out of TTC were dead:
//  "Go to pregnancy" popped to a first route that was already TTC, and the
//  button after a positive test - the single most important tap in the product -
//  showed a "coming soon" toast.
//
//  This file is the meeting point. `main.dart` REGISTERS how to build the
//  pregnancy shell; TTC ASKS for it by name. Neither imports the other.
//
//  ---------------------------------------------------------------------------
//  Why a route registry and not an app-level swap
//
//  The obvious mirror is `DoctorSession`: it flips a flag and `MaterialApp`'s
//  builder swaps the whole app to the doctor dashboard, keeping the parent app
//  offstage so state survives. That is the right shape THERE because a doctor
//  bounces in and out many times a day, and losing their place each time would
//  be intolerable.
//
//  A life stage is the opposite: a family crosses it roughly once, ever. Keeping
//  a TTC shell alive offstage for the rest of a pregnancy buys nothing and costs
//  a second live widget tree, a second Navigator, and a second source of truth
//  for "which stage am I in" that the Ask Veda FAB would have to reconcile - the
//  FAB infers its stage from the route stack, and routes inside a nested
//  Navigator do not reliably report their removal to the root observer. A stale
//  `inTtc` would answer a pregnant woman's question with trying-to-conceive
//  framing.
//
//  Replacing the stack instead means the old stage is genuinely gone, the
//  observer sees every route leave, and the FAB corrects itself for free. The
//  cost is honest and small: TTC's in-memory screen state is discarded. Her
//  DATA is untouched - every store is local-first and stage-agnostic, which is
//  the whole reason the Transition Engine has nothing to migrate.
//
//  The general lesson, worth more than this fix: how long a thing lives decides
//  whether you preserve it or rebuild it. Preserving state is not free, and
//  "cheap to rebuild, rarely rebuilt" is the case where replacing wins.
// =============================================================================

import 'package:flutter/material.dart';

/// Builds a route for a top-level shell. Registered by `main.dart`, which is the
/// only place that holds the controllers such a shell needs.
typedef ShellRouteBuilder = Route<void> Function();

class AppShell {
  AppShell._();

  static ShellRouteBuilder? _pregnancy;

  /// Called once from `main.dart`'s `initState`. Registration rather than a
  /// constant because the route closes over controllers that only exist there.
  static void register({required ShellRouteBuilder pregnancy}) {
    _pregnancy = pregnancy;
  }

  /// False in a widget test that pumped a screen directly, and in any build
  /// where registration has not run yet. Callers check it so they can say
  /// something honest instead of appearing to do nothing.
  static bool get canOpenPregnancy => _pregnancy != null;

  /// Replaces the ENTIRE stack with the pregnancy shell.
  ///
  /// `pushAndRemoveUntil(..., (_) => false)` is deliberate: the predicate never
  /// matches, so every existing route is removed. That is what makes the new
  /// shell the first route - so its back button exits the app, as a home should,
  /// rather than reopening the stage she just left.
  ///
  /// Returns false when nothing is registered, so the caller can fall back.
  static bool openPregnancy(NavigatorState nav) {
    final build = _pregnancy;
    if (build == null) return false;
    nav.pushAndRemoveUntil(build(), (_) => false);
    return true;
  }

  @visibleForTesting
  static void resetForTest() => _pregnancy = null;
}
