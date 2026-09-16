// =============================================================================
//  Skilling surface router — every `sk_` surface, and the screen it opens
// -----------------------------------------------------------------------------
//  Sibling of `pp_surface_router.dart` (parenting) and `ttc_surface_router.
//  dart`, for the reason the whole stage separation exists: this file
//  imports `skilling/*` and nothing else imports it back, so a skilling
//  bracket cell can be `live` and the wiring test can prove it opens
//  something without the pregnancy or parenting trees being compiled in.
//
//  ⚠️ EVERY ENTRY OPENS A SCREEN THAT EXISTS. `sk_page/<door>/<page>` is the
//  cross-door window (a page of another door, by id — the parenting `pp_page`
//  idea, so one thing lives once). The parent surfaces route to the grown-up
//  screen, which asks the gate itself, so a deep link cannot skip it.
//
//  NULL IS A REAL ANSWER: an id nobody declared opens nothing, and the test
//  says so by name.
//
//  Surfaces, in one list, so a reader does not have to derive them:
//
//    sk_gate                          set up and consent
//    sk_door/<door>[/<tab>]           the door, optionally on a tab
//    sk_today/<door>                  the door on Today's thing to try
//    sk_activities/<door>             the door on Things to do
//    sk_lessons/<door>                the door on Lessons
//    sk_cross/<door>                  the door on the cross-band tab
//    sk_keepsake/<door>               What I've made and tried
//    sk_voice/<door>                  Your voice, saved (clips + the words)
//    sk_access/<door>                 the free tools to set up (gated)
//    sk_grown_up/<door>               the parent side (gated)
//    sk_courses/<door>                the parent side, on the course shelf
//    sk_products/<door>               the parent side, on the product shelf
//    sk_page/<door>/<page>            one page, by id
//    sk_activity/<door>/<activity>    one activity, by id
// =============================================================================

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../data/doors/sk_door_data.dart';
import '../../services/bracket_resolver.dart';
import 'doors/sk_door_screen.dart';
import 'sk_access_screen.dart';
import 'sk_activity_screen.dart';
import 'sk_child_store.dart';
import 'sk_content_registry.dart';
import 'sk_grown_up_screen.dart';
import 'sk_keepsake_screen.dart';
import 'sk_parent_gate_screen.dart';
import 'sk_practice_store.dart';
import 'sk_voice_keepsake.dart';

/// The screen for a surface id, or null.
Widget? skScreenForSurface(String id) {
  final parts = id.split('/');
  final head = parts.first;
  final door = parts.length > 1 ? parts[1] : null;
  final rest = parts.length > 2 ? parts[2] : null;

  SkDoor? d() => door == null ? null : skDoorFor(door);
  Widget? onTab(SkTabKind kind) {
    final dd = d();
    if (dd == null) return null;
    final tab = dd.tabs.where((t) => t.kind == kind).firstOrNull;
    return SkDoorScreen(door: dd, onSurface: skOpenSurface, initialTabId: tab?.id);
  }

  switch (head) {
    case 'sk_gate':
      return const SkParentGateScreen();
    case 'sk_door':
      final dd = d();
      if (dd == null) return null;
      return SkDoorScreen(door: dd, onSurface: skOpenSurface, initialTabId: rest);
    case 'sk_today':
      return onTab(SkTabKind.today);
    case 'sk_activities':
      return onTab(SkTabKind.activities);
    case 'sk_lessons':
      return onTab(SkTabKind.lessons);
    case 'sk_cross':
      return onTab(SkTabKind.crossBand);
    case 'sk_keepsake':
      if (door == null || skDoorContentFor(door) == null) return null;
      return SkKeepsakeScreen(
          doorId: door, doorTitle: bracketById(door)?.title.now ?? '');
    case 'sk_voice':
      if (door == null || skDoorContentFor(door)?.voiceKeepsake != true) return null;
      return SkVoiceKeepsakeScreen(doorId: door);
    case 'sk_access':
      if (door == null || skDoorContentFor(door) == null) return null;
      return SkAccessScreen(doorId: door);
    case 'sk_grown_up':
      if (door == null || skDoorContentFor(door) == null) return null;
      return SkGrownUpScreen(doorId: door);
    case 'sk_courses':
      if (door == null || skDoorContentFor(door) == null) return null;
      return SkGrownUpScreen(doorId: door, section: SkGrownUpSection.courses);
    case 'sk_products':
      if (door == null || skDoorContentFor(door) == null) return null;
      return SkGrownUpScreen(doorId: door, section: SkGrownUpSection.products);
    case 'sk_page':
      final c = door == null ? null : skDoorContentFor(door);
      final page = c == null || rest == null ? null : c.pageById(rest);
      if (c == null || page == null) return null;
      if (page.toolSurfaceId != null) return skScreenForSurface(page.toolSurfaceId!);
      return skPageScreen(c, page, onSurface: skOpenSurface);
    case 'sk_activity':
      final c = door == null ? null : skDoorContentFor(door);
      final a = c == null || rest == null ? null : c.activityById(rest);
      if (c == null || a == null || a.comingSoon) return null;
      return SkActivityScreen(content: c, activity: a);
  }
  return null;
}

/// True when the router knows the id — the wiring test's `routerKnows`.
bool skRouterKnows(String id) => skScreenForSurface(id) != null;

/// Push a surface. The `onSurface` every skilling screen is handed.
void skOpenSurface(BuildContext context, String id) {
  final screen = skScreenForSurface(id);
  if (screen == null) return;
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: id),
    builder: (_) => screen,
  ));
}

/// ⚠️ THE ONE WAY A SKILL DOOR OPENS FROM ITS TILE. The parent gate first
/// if consent has not been given; then the door. Behind `kDebugMode` — the
/// stage stays gated until the briefs say otherwise (the user's call,
/// 2026-09-14, question 1: the preview ships, the door does not), so in a
/// release build this returns false and the tile shows its plan sheet.
bool skOpenDoor(BuildContext context, String doorId) {
  if (!kDebugMode) return false;
  final door = skDoorFor(doorId);
  if (door == null) return false;
  MaterialPageRoute<void> route() => MaterialPageRoute<void>(
        settings: RouteSettings(name: 'sk_door/$doorId'),
        builder: (_) => SkDoorScreen(door: door, onSurface: skOpenSurface),
      );
  // ⚠️ THE STORES LOAD LAZILY, AND THIS IS THE ONE ENTRY. Both reads are a
  // prefs lookup and idempotent; awaiting them here is what stops a first
  // tap after a cold start from meeting the gate for a child already
  // consented. `context.mounted` guards the tiny window in which the
  // preview could have gone.
  Future.wait([
    SkChildStore.instance.load(),
    SkPracticeStore.instance.load(),
    SkVoiceStore.instance.load(),
  ]).then((_) {
    if (!context.mounted) return;
    if (!SkChildStore.instance.consented) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'sk_gate'),
        // The gate replaces itself with the door, so Back from the door
        // lands on the preview and not on a consent form already given.
        builder: (_) => SkParentGateScreen(
            onDone: (ctx) => Navigator.of(ctx).pushReplacement(route())),
      ));
      return;
    }
    Navigator.of(context).push(route());
  });
  return true;
}
