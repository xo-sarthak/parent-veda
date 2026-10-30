// =============================================================================
//  NotificationOpener - THE one place a notification tap is turned into a page
// -----------------------------------------------------------------------------
//  Phase 6b, B0 (2026-10-30). What [SavedItemOpener] is for a saved row, this
//  is for a notification: one switch from a [NotificationLink] (`link_kind`,
//  `link_id`) to a screen. Every tap ends here:
//
//    * a stage message armed since B0: its payload names the message;
//    * a stage message armed before B0 (no payload): the stage guesses the
//      message from the OS id, as it always did, and hands the guess here
//      as a link (`handlePhoneTap` in each messages store);
//    * a server push (B1 on): its data carries the same two keys.
//
//  A STAGE MESSAGE OPENS THROUGH ITS STAGE. The three stages already know
//  where each of their messages goes and how to get past the splash and onto
//  the right home first (`ttcOpenMessageFromPhone`, `pregOpenMessageFromPhone`,
//  `ppOpenMessageFromPhone`, reached through each store's `phoneTapOpener`).
//  This file does not repeat that; it finds THE message and hands it over.
//  The stages stay isolated (CLAUDE.md), the routing stays in one place.
//
//  NO SILENT TAP. A message that has gone, a product no longer in the Store,
//  a kind this build does not know: each says so in a pvToast and opens the
//  nearest real place.
//
//  Registered once, in main.dart: `NotificationService.setLinkOpener`.
// =============================================================================

import 'package:flutter/widgets.dart';

import '../services/last_profile.dart' show LastProfile;
import '../services/notification_link.dart';
import '../services/pp_messages_store.dart';
import '../services/preg_messages_store.dart';
import '../services/pv_catalog_store.dart';
import '../services/saved_store.dart' show SavedItem, SavedKind;
import '../ttc/ttc_messages_store.dart';
import '../widgets/global_ask_fab.dart' show appNavigatorKey;
import '../widgets/pv_toast.dart';
import 'learn/pv_learn_catalog.dart' show PvLearnCatalog;
import 'learn/pv_offering_screen.dart' show pvOpenOffering;
import 'post_pregnancy/pp_expert_link.dart' show openExpertProfile;
import 'post_pregnancy/pp_experts_data.dart' show expertByIdOrNull;
import 'products/pv_store_chrome.dart' show pvOpenProduct;
import 'saved_screen.dart' show SavedItemOpener;

/// Copy shown when a tapped thing cannot open. Named so the test can hold
/// that every gap says something.
const String kNotifGoneProduct = "That isn't in the Store any more. Here is what's there now.";
const String kNotifGoneCourse = "That class isn't running any more. Here is what's on now.";
const String kNotifGoneExpert = "That expert isn't taking sessions here any more.";
const String kNotifGoneRead = "That page isn't here any more.";
const String kNotifUnknownKind = 'This needs a newer ParentVeda. Update the app to open it.';

class NotificationOpener {
  NotificationOpener._();

  /// Every `link_kind` this build opens. A push with any other kind gets
  /// [kNotifUnknownKind]; the plan's `app_version` lets the server skip
  /// builds too old for a kind (docs/NOTIFICATIONS-6B-PLAN.md, Risks).
  static const Set<String> kinds = {
    NotificationLink.ttcMessage,
    NotificationLink.pregMessage,
    NotificationLink.ppMessage,
    NotificationLink.product,
    NotificationLink.course,
    NotificationLink.expert,
    NotificationLink.read,
  };

  /// How long a tap waits for the app to be ready: 20 tries, half a second
  /// apart, the stages' own wait.
  static const int _tries = 20;
  static const Duration _gap = Duration(milliseconds: 500);

  /// Opens [link]. Safe to call before the app has a screen: it waits.
  static void open(NotificationLink link) => _open(link, 0);

  static void _open(NotificationLink link, int attempt) {
    void later() {
      if (attempt < _tries) Future<void>.delayed(_gap, () => _open(link, attempt + 1));
    }

    switch (link.kind) {
      // ---- the stages' own messages ----------------------------------------
      // ⚠️ WAIT FOR THE STORE, THEN LOOK UP BY ID. On a cold launch the tap
      // arrives before the store has read its messages back; a lookup then
      // would call a real message "gone".
      case NotificationLink.ttcMessage:
        final s = TtcMessagesStore.instance;
        final m = s.messageById(link.id);
        if (m == null && !s.isLoaded) return later();
        if (m != null) s.markRead(m.id);
        TtcMessagesStore.phoneTapOpener(m);
      case NotificationLink.pregMessage:
        final s = PregMessagesStore.instance;
        final m = s.messageById(link.id);
        if (m == null && !s.isLoaded) return later();
        if (m != null) s.markRead(m.id);
        PregMessagesStore.phoneTapOpener?.call(m);
      case NotificationLink.ppMessage:
        final s = PpMessagesStore.instance;
        final m = s.messageById(link.id);
        if (m == null && !s.isLoaded) return later();
        if (m != null) s.markRead(m.id);
        PpMessagesStore.phoneTapOpener?.call(m);

      // ---- what a campaign links to (6b) -----------------------------------
      // These need a screen to push onto: wait for the home, as the stages do.
      default:
        final ctx = appNavigatorKey.currentContext;
        if (ctx == null || !LastProfile.instance.homeShown) return later();
        _openThing(ctx, link);
    }
  }

  static void _openThing(BuildContext context, NotificationLink link) {
    switch (link.kind) {
      case NotificationLink.product:
        final p = PvCatalogStore.instance.byId(link.id);
        if (p != null) return pvOpenProduct(context, p);
        pvToast(context, kNotifGoneProduct);
      case NotificationLink.course:
        final v = PvLearnCatalog.instance.byId(link.id);
        if (v != null) return pvOpenOffering(context, v);
        pvToast(context, kNotifGoneCourse);
      case NotificationLink.expert:
        final e = expertByIdOrNull(link.id);
        if (e != null) return openExpertProfile(context, e);
        pvToast(context, kNotifGoneExpert);
      case NotificationLink.read:
        final now = DateTime.now();
        final item = SavedItem(kind: SavedKind.article, itemId: link.id, savedAt: now, updatedAt: now);
        if (SavedItemOpener.resolveTitle(item) != null) return SavedItemOpener.open(context, item);
        pvToast(context, kNotifGoneRead);
      default:
        pvToast(context, kNotifUnknownKind);
    }
  }
}
