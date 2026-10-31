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
//
//  6b leftover L4 (2026-10-31): the phone's thirteen older alarms (reminders,
//  medicines, vaccines, appointments, bookings, sessions, referrals, brand
//  messages, prescriptions, feeding, mood check, health records, the TTC
//  Ready plan) and the TTC trigger alarms carry a payload too, and open
//  here. They used to only open the app.
// =============================================================================

import 'package:flutter/material.dart';

import '../booking/booking_store.dart' show BookingStore;
import '../booking/prescription.dart' show PrescriptionStore;
import '../brand/brand_studio.dart' show BrandStudio;
import '../brand/presented_by.dart' show showSponsorSheet;
import '../services/last_profile.dart' show LastProfile;
import '../services/life_stage_store.dart';
import '../services/medicine_store.dart' show MedicineStore;
import '../services/pregnancy_controller.dart' show PregnancyController;
import '../ttc/ttc_records_store.dart' show TtcAppointmentsStore;
import 'calendar_screen.dart' show CalendarScreen;
import 'learn/pv_session_screen.dart' show pvOpenSession;
import 'post_pregnancy/calendar/pp_child_calendar_screen.dart' show openPpChildCalendar;
import 'post_pregnancy/feeding_journey_screen.dart' show FeedingJourneyScreen;
import 'post_pregnancy/health_records_screen.dart' show HealthRecordsScreen;
import 'post_pregnancy/pp_child_profile.dart' show ChildProfileStore;
import 'post_pregnancy/pp_mood_check_screen.dart' show PpMoodCheckScreen;
import 'post_pregnancy/pp_vaccine_data.dart' show kVaxVisits;
import 'post_pregnancy/pp_vax_tracker_screen.dart' show VaxTrackerScreen;
import 'post_pregnancy/prescription_view_screen.dart' show PrescriptionViewScreen;
import 'post_pregnancy/vax_detail_screen.dart' show VaxDetailScreen;
import 'post_pregnancy/wallet_v2_screens.dart' show WalletRemindersScreen;
import 'referral/birth_club_screen.dart' show BirthClubScreen;
import 'referral/invite_friends_screen.dart' show InviteFriendsScreen;
import 'reminders_screen.dart' show RemindersScreen;
import 'tools/medicine_tracker_screen.dart' show MedicineTrackerScreen;
import 'ttc/ttc_appointments_screen.dart'
    show TtcApptEntry, openTtcAppointment, openTtcAppointments;
import 'ttc/ttc_medication_screen.dart' show openTtcMedicine, openTtcMedication;
import 'ttc/ttc_surface_router.dart' show openTtcSurface;
import 'ttc/ttc_treatment_screen.dart' show openTtcTreatment;
import '../services/notification_link.dart';
import '../services/pp_messages_store.dart';
import '../services/preg_messages_store.dart';
import '../services/pv_catalog_store.dart';
import '../services/pv_community_store.dart';
import '../services/saved_store.dart' show SavedItem, SavedKind;
import '../ttc/ttc_messages_store.dart';
import '../widgets/global_ask_fab.dart' show appNavigatorKey;
import '../widgets/pv_toast.dart';
import 'community/community_chrome.dart'
    show openCommunityActivity, openCommunityModeration, openCommunityPost;
import 'learn/pv_learn_catalog.dart' show PvLearnCatalog;
import 'learn/pv_my_learning_screen.dart' show PvMyLearningScreen;
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
const String kNotifNotModerator = 'Moderation is for moderators. This account is not one any more.';
// L4: the phone's own alarms.
const String kNotifOtherProfile = "That reminder belongs to a profile that isn't open now.";
const String kNotifChildGone = "That child's profile isn't here any more.";
const String kNotifGoneAppointment = "That appointment isn't here any more. Here is your calendar.";
const String kNotifGoneSession = "That session isn't in your bookings any more. Here are your bookings.";
const String kNotifNoPrescription = "The prescription isn't here yet. Here is the session.";
const String kNotifGoneBrand = 'That message has ended.';

/// The route her bookings open under from a moved-session alert.
const String kPvBookingsFromAlertRoute = 'bookings/from_alert';

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
    // (C3-2, 0147) Community alerts: PushService.linkVersion 2.
    NotificationLink.communityPost,
    NotificationLink.booking,
    NotificationLink.communityModeration,
    // (6b leftover L4) The phone's own older alarms. Never from the server.
    ...localKinds,
  };

  /// The kinds only the phone arms (L4). push_campaigns' link_kind check
  /// refuses them, so pv_push_link_needs never has to know them.
  static const Set<String> localKinds = {
    NotificationLink.reminder,
    NotificationLink.medicine,
    NotificationLink.vaccine,
    NotificationLink.appointment,
    NotificationLink.ppAppointment,
    NotificationLink.ttcAppointment,
    NotificationLink.session,
    NotificationLink.referral,
    NotificationLink.brand,
    NotificationLink.prescription,
    NotificationLink.feeding,
    NotificationLink.moodCheck,
    NotificationLink.healthRecord,
    NotificationLink.ttcReadyPlan,
    NotificationLink.ttcTreatment,
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

      // ---- Community alerts (C3-2, 0147) -----------------------------------
      // The post screen says itself when a post has gone, so it opens as is.
      case NotificationLink.communityPost:
        if (link.id.isEmpty) return openCommunityActivity(context);
        openCommunityPost(context, link.id);
      // Her bookings: the moved card says "Moved from ..." (0137, LA-22).
      case NotificationLink.booking:
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => const PvMyLearningScreen(),
          settings: const RouteSettings(name: kPvBookingsFromAlertRoute),
        ));
      // Moderation opens on At risk. A member who is not a moderator (a
      // role removed after the alert went) is told, not shown the queue.
      case NotificationLink.communityModeration:
        final store = PvCommunityStore.instance;
        store.init().then((_) async {
          if (!store.me.isMod) await store.refreshMe();
          final ctx = appNavigatorKey.currentContext;
          if (ctx == null || !ctx.mounted) return;
          if (store.me.isMod) return openCommunityModeration(ctx);
          pvToast(ctx, kNotifNotModerator);
        });

      // ---- the phone's own older alarms (6b leftover L4) -------------------
      // A reminder opens the list it was set from, by its category.
      case NotificationLink.reminder:
        if (link.id.startsWith('ttc_plan')) return openTtcSurface(context, 'ttc_ready_plan');
        if (link.id.startsWith('hw_')) return _push(context, 'wallet/reminders', const WalletRemindersScreen());
        final preg = PregnancyController.current;
        if (preg == null) {
          pvToast(context, kNotifOtherProfile);
          return;
        }
        _push(context, 'tools/reminders', RemindersScreen(controller: preg));
      // One store, two stages: TTC opens the medicine, Pregnancy the list.
      case NotificationLink.medicine:
        if (LifeStageStore.instance.stage == LifeStage.tryingToConceive) {
          if (MedicineStore.instance.all.any((m) => m.id == link.id)) {
            return openTtcMedicine(context, link.id);
          }
          return openTtcMedication(context);
        }
        final preg = PregnancyController.current;
        if (preg == null) {
          pvToast(context, kNotifOtherProfile);
          return;
        }
        _push(context, 'tools/medicines', MedicineTrackerScreen(controller: preg));
      case NotificationLink.vaccine:
        final v = NotificationLink.splitChild(link.id);
        if (!_toChild(context, v.child)) return;
        if (kVaxVisits.any((x) => x.id == v.item)) {
          return _push(context, 'pp/vaccine', VaxDetailScreen(visitId: v.item));
        }
        _push(context, 'pp/vaccines', const VaxTrackerScreen());
      case NotificationLink.appointment:
        final preg = PregnancyController.current;
        if (preg == null) {
          pvToast(context, kNotifOtherProfile);
          return;
        }
        _push(context, 'tools/calendar', CalendarScreen(controller: preg));
      case NotificationLink.ppAppointment:
        final v = NotificationLink.splitChild(link.id);
        if (!_toChild(context, v.child)) return;
        openPpChildCalendar(context);
      case NotificationLink.ttcAppointment:
        final a = TtcAppointmentsStore.instance.all.where((a) => a.id == link.id).firstOrNull;
        if (a == null) {
          pvToast(context, kNotifGoneAppointment);
          return openTtcAppointments(context);
        }
        openTtcAppointment(context, TtcApptEntry(
          own: a, title: a.title, startsUtc: a.startsUtc, detail: a.withWhom, fromParentVeda: false));
      case NotificationLink.session:
        final b = BookingStore.instance.byId(link.id);
        if (b != null) return pvOpenSession(context, b);
        pvToast(context, kNotifGoneSession);
        _push(context, kPvBookingsFromAlertRoute, const PvMyLearningScreen());
      case NotificationLink.referral:
        if (link.id == NotificationLink.referralClub) {
          return _push(context, 'referral/club', const BirthClubScreen());
        }
        _push(context, 'invite', const InviteFriendsScreen());
      case NotificationLink.brand:
        final c = BrandStudio.instance.campaigns.where((c) => c.id == link.id).firstOrNull;
        if (c != null) return showSponsorSheet(context, c);
        pvToast(context, kNotifGoneBrand);
      case NotificationLink.prescription:
        final rx = PrescriptionStore.instance.forBooking(link.id);
        final b = BookingStore.instance.byId(link.id);
        if (rx != null) {
          return _push(context, 'learn/prescription',
              PrescriptionViewScreen(prescription: rx, title: b?.title ?? 'Your prescription'));
        }
        if (b != null) {
          pvToast(context, kNotifNoPrescription);
          return pvOpenSession(context, b);
        }
        pvToast(context, kNotifGoneSession);
        _push(context, kPvBookingsFromAlertRoute, const PvMyLearningScreen());
      case NotificationLink.feeding:
        if (!_toChild(context, link.id.isEmpty ? null : link.id)) return;
        _push(context, 'pp/feeding', const FeedingJourneyScreen());
      case NotificationLink.moodCheck:
        _push(context, 'pp/mood_check', const PpMoodCheckScreen());
      case NotificationLink.healthRecord:
        final v = NotificationLink.splitChild(link.id);
        if (!_toChild(context, v.child)) return;
        _push(context, 'pp/health_records', HealthRecordsScreen(category: v.item.isEmpty ? 'medications' : v.item));
      case NotificationLink.ttcReadyPlan:
        openTtcSurface(context, 'ttc_ready_plan');
      case NotificationLink.ttcTreatment:
        openTtcTreatment(context);

      default:
        pvToast(context, kNotifUnknownKind);
    }
  }

  static void _push(BuildContext context, String route, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => page,
        settings: RouteSettings(name: route),
      ));

  /// Makes [childId] the active child before her page opens (a Parenting
  /// alarm is set for one child). False, after saying so, when that child
  /// has been removed: never open another child's page in her place.
  static bool _toChild(BuildContext context, String? childId) {
    if (childId == null) return true;
    final kids = ChildProfileStore.instance;
    if (!kids.children.any((c) => c.id == childId)) {
      pvToast(context, kNotifChildGone);
      return false;
    }
    if (kids.activeChildId != childId) kids.switchTo(childId);
    return true;
  }
}
