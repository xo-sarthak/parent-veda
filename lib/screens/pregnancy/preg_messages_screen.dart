// =============================================================================
//  Pregnancy — Messages: what the app said first, kept
// -----------------------------------------------------------------------------
//  2026-09-30, the pregnancy gap analysis: "The app speaks first" (P1) and "An
//  inbox" (P2, "Messages she misses are gone"). `PregMessagesStore` decides
//  WHAT is said and WHEN; this file is where each message is read and where it
//  goes when she taps it.
//
//  EACH MESSAGE OPENS THE PAGE IT NAMES (the PDF's words):
//    new week      the week page for that week
//    NT, anomaly   the Scans & tests door
//    Tdap          the vaccines read
//    movements     the baby movement tool
//    hospital bag  Ready for birth, her bag
//    arrived?      the "Baby has arrived" sheet You already has
//
//  ⚠️ ITS OWN INBOX, NOT TTC'S. The PDF suggests reusing the trying-to-conceive
//  inbox; that store and screen are TTC's, and the user's rule for this pass
//  is pregnancy only. The shape is the same (the store follows
//  `TtcMessagesStore` line for line where it can), and folding the two into
//  one shared inbox is written down in docs/PREG-TTC-HANDOFF.md §8.
// =============================================================================

import '../../brand/brand_inbox.dart' show BrandInboxRows;
import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/doors/pv_door_data.dart' show PvDoorLibrary;
import '../../data/doors/pv_door_symptoms.dart' show kSymptomsBracketId;
import '../../services/pv_catalog_store.dart';
import '../../services/last_profile.dart' show LastProfile, kLastHomeRoot;
import '../../services/notification_link.dart' show kNotifMessageGone, kNotifPageMissing, kNotifProfileClosed;
import '../../services/life_stage_store.dart';
import '../../services/preg_messages_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/stage_gateway.dart';
import '../v2/pv_celebration.dart' show openBirthCelebration;
import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show appNavigatorKey, FabState;
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../doors/pv_door_router.dart' show openPvDoorRead, pvDoorEntryScreen;
import '../doors/pv_door_screen.dart' show pvDoorScreenForBracket;
import '../doors/pv_list_row.dart';
import '../preg_week_screen.dart';
import '../v2/v2_palette.dart' show V2Palette;
import '../learn/pv_learn_catalog.dart' show PvLearnCatalog;
import '../learn/pv_offering_screen.dart' show pvOpenOffering;
import '../products/pv_store_chrome.dart' show kPvInk, pvOpenProduct, pvStorePalette;
import '../../widgets/pv_campaign_tonight.dart';
import '../../widgets/pv_toast.dart';
import '../profile/pv_you_sheets.dart' show showPvAddChildSheet;
import '../reminders_screen.dart';
import '../tools/baby_movement_screen.dart';
import '../tools/ready_for_birth_screen.dart';

const String kPregMessagesRoute = 'pregnancy/messages';

void openPregMessages(BuildContext context, PregnancyController c) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kPregMessagesRoute),
    builder: (_) => PregMessagesScreen(pregnancy: c),
  ));
}

/// Opens the page [m] names.
void openPregMessage(BuildContext context, PregMessage m, PregnancyController c) {
  pvCommitFeedback();
  PregMessagesStore.instance.markRead(m.id);
  void push(String route, Widget Function() b) => Navigator.of(context).push(
      MaterialPageRoute<void>(settings: RouteSettings(name: route), builder: (_) => b()));
  switch (m.kind) {
    case PregMessageKind.newWeek:
      push('pregnancy/week', () => PregWeekScreen(pregnancy: c, week: m.week ?? c.currentWeek));
    // Phase 6a (2026-10-28). The tip is that week's, so it opens the week.
    case PregMessageKind.dayLine:
      push('pregnancy/week', () => PregWeekScreen(pregnancy: c, week: m.week ?? c.currentWeek));
    // The check-in is the Symptoms door's Today tab, the home's own "log".
    // A door that does not resolve says so (no silent tap, B0). Kept for
    // revert: no else.
    case PregMessageKind.checkIn:
      final door = pvDoorScreenForBracket(kSymptomsBracketId, c);
      if (door != null) {
        push('bracket/$kSymptomsBracketId', () => door);
      } else {
        _pregMissing(context, c);
      }
    case PregMessageKind.offer:
      _openOffer(context, m.ref);
    // Batch 7 (2026-10-28): each opens the page the Scans door opens for it,
    // so the message and the door tell her the same thing.
    case PregMessageKind.firstVisit:
      openPvDoorRead(context, 'preg_scan_read_first_visit', c);
    case PregMessageKind.datingScan:
    case PregMessageKind.glucoseTest:
    case PregMessageKind.growthScan:
      final scan = pvDoorEntryScreen(PvDoorLibrary.scan, pregMessageScanId(m.kind)!, c);
      if (scan != null) {
        push('scans/detail', () => scan);
      } else {
        _pregMissing(context, c);
      }
    case PregMessageKind.ntScan:
    case PregMessageKind.anomalyScan:
      final door = pvDoorScreenForBracket('pregnancy_scans_tests', c);
      if (door != null) {
        push('bracket/pregnancy_scans_tests', () => door);
      } else {
        _pregMissing(context, c);
      }
    case PregMessageKind.tdap:
      openPvDoorRead(context, 'preg_scan_read_vaccines', c);
    case PregMessageKind.movements:
      push('tools/movement', () => BabyMovementScreen(controller: c));
    case PregMessageKind.hospitalBag:
      push('tools/hospital_bag', () => ReadyForBirthScreen(controller: c));
    case PregMessageKind.babyArrived:
      // The same sheet and the same move as You › "Baby has arrived".
      unawaited(showPvAddChildSheet(context, arrival: true).then((added) async {
        if (added && context.mounted) {
          LifeStageStore.instance.setStage(LifeStage.parenting);
          // The birth page first (F4, 2026-10-25). Kept for revert:
          //   openStageDoor(context, StageDoor.parenting);
          await openBirthCelebration(context, then: (c) => openStageDoor(c, StageDoor.parenting));
        }
      }));
  }
}

/// A page the message names cannot be found: say so, and open the inbox
/// (no silent tap, B0, 2026-10-30).
void _pregMissing(BuildContext context, PregnancyController c) {
  pvToast(context, kNotifPageMissing);
  openPregMessages(context, c);
}

/// A phone tap: wait for the pregnancy shell, then open the message's page,
/// or the inbox when the message is not known.
void pregOpenMessageFromPhone(PregMessage? m, {int attempt = 0}) {
  var ctx = appNavigatorKey.currentContext;
  final c = PregnancyController.current;
  // ⚠️ A CHILD'S HOME ON TOP NO LONGER DROPS THE TAP (F6, 2026-10-25). This
  // used to wait while a parenting home was on screen and, after ten seconds,
  // give up: a pregnant mother with her toddler's home open tapped "Week 14"
  // and nothing happened. A pregnancy message is the pregnancy profile's, so
  // it goes back to the pregnancy home first (the root while the stage is
  // pregnancy; `leaveTtcForPregnancy` rebuilds it only if TTC was the root).
  // It waits for the home to be shown, so a tap that launched the app is not
  // pushed under the splash. Kept for revert:
  //   if (ctx == null || c == null || FabState.instance.inTtc || FabState.instance.inParenting) {
  final pregnant = LifeStageStore.instance.stage == LifeStage.pregnancy;
  final away = FabState.instance.inTtc || FabState.instance.inParenting ||
      LastProfile.instance.onTop != kLastHomeRoot;
  if (ctx == null || c == null || !LastProfile.instance.homeShown || (away && !pregnant)) {
    if (attempt < 20) {
      Future<void>.delayed(const Duration(milliseconds: 500),
          () => pregOpenMessageFromPhone(m, attempt: attempt + 1));
    } else if (ctx != null && LastProfile.instance.homeShown) {
      // Ten seconds and the pregnancy profile never came: say so (B0).
      pvToast(ctx, kNotifProfileClosed);
    }
    return;
  }
  if (away) {
    openStageDoor(ctx, StageDoor.pregnancy);
    ctx = appNavigatorKey.currentContext;
    if (ctx == null) return;
  }
  if (m == null) {
    pvToast(ctx, kNotifMessageGone); // B0: a message that has gone says so
    openPregMessages(ctx, c);
  } else {
    openPregMessage(ctx, m, c);
  }
}

/// What an offer message opens (Phase 6a). The thing may have gone since the
/// message was sent (a product sold out, a course unpublished): then she is
/// told so, never sent to a blank page (no silent tap).
void _openOffer(BuildContext context, String? ref) {
  final parts = (ref ?? '').split(':');
  if (parts.length >= 2) {
    final id = parts.sublist(1).join(':');
    if (parts.first == 'product') {
      final product = PvCatalogStore.instance.byId(id);
      if (product != null) return pvOpenProduct(context, product);
    } else if (parts.first == 'learn') {
      final view = PvLearnCatalog.instance.byId(id);
      if (view != null) return pvOpenOffering(context, view);
    }
  }
  pvToast(context, "That isn't available any more. The Store and Learn have what's there now.");
}

/// The Scans library entry a scan message opens, or null for the rest. The
/// ids are the Scans door tiles' (`pv_door_scans.dart`); a test holds that
/// each resolves.
String? pregMessageScanId(PregMessageKind k) => switch (k) {
      PregMessageKind.datingScan => 'dating_scan',
      PregMessageKind.glucoseTest => 'ogtt',
      PregMessageKind.growthScan => 'growth_scan',
      _ => null,
    };

IntentMark _markFor(PregMessageKind k) => switch (k) {
      PregMessageKind.newWeek => IntentMark.calendarDay,
      PregMessageKind.dayLine => IntentMark.calendarDay,
      PregMessageKind.checkIn => IntentMark.bodyMark,
      PregMessageKind.offer => IntentMark.bagMark,
      PregMessageKind.firstVisit => IntentMark.askDoctor,
      PregMessageKind.datingScan => IntentMark.reportPage,
      PregMessageKind.glucoseTest => IntentMark.reportPage,
      PregMessageKind.growthScan => IntentMark.reportPage,
      PregMessageKind.ntScan => IntentMark.reportPage,
      PregMessageKind.anomalyScan => IntentMark.reportPage,
      PregMessageKind.tdap => IntentMark.askDoctor,
      PregMessageKind.movements => IntentMark.bodyMark,
      PregMessageKind.hospitalBag => IntentMark.bagMark,
      PregMessageKind.babyArrived => IntentMark.cuppedHands,
    };

double _hueFor(PregMessageKind k) => switch (k) {
      PregMessageKind.newWeek => 268,
      PregMessageKind.dayLine => 268,
      PregMessageKind.checkIn => 344,
      PregMessageKind.offer => 28,
      PregMessageKind.firstVisit => 160,
      PregMessageKind.datingScan => 206,
      PregMessageKind.glucoseTest => 206,
      PregMessageKind.growthScan => 206,
      PregMessageKind.ntScan => 206,
      PregMessageKind.anomalyScan => 206,
      PregMessageKind.tdap => 160,
      PregMessageKind.movements => 344,
      PregMessageKind.hospitalBag => 28,
      PregMessageKind.babyArrived => 42,
    };

String _ago(DateTime at, DateTime now) {
  final d = DateTime(now.year, now.month, now.day)
      .difference(DateTime(at.year, at.month, at.day))
      .inDays;
  if (d <= 0) return 'Today';
  if (d == 1) return 'Yesterday';
  if (d < 7) return '$d days ago';
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${at.day} ${m[at.month - 1]}';
}

class PregMessagesScreen extends StatefulWidget {
  const PregMessagesScreen({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  State<PregMessagesScreen> createState() => _PregMessagesScreenState();
}

class _PregMessagesScreenState extends State<PregMessagesScreen> {
  @override
  void initState() {
    super.initState();
    // A message may have come due since the store last looked.
    PregMessagesStore.instance.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: PregMessagesStore.instance,
      builder: (context, _) {
        final store = PregMessagesStore.instance;
        final now = DateTime.now();
        final list = store.delivered(now: now);
        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            elevation: 0,
            foregroundColor: p.ink1,
            actions: [
              if (store.unreadCount > 0)
                TextButton(
                  onPressed: store.markAllRead,
                  child: Text('Mark all read',
                      style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink2)),
                ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Messages',
                        style: pvFraunces(fontSize: 28, fontWeight: FontWeight.w500, color: p.ink1)),
                    const SizedBox(height: 6),
                    // Kept for revert (Phase 6a): 'A note on the morning each new week
                    // starts, and a word at the moments worth remembering: the scans,
                    // the vaccine, the bag.'
                    Text(
                        "A tip each morning, a word at the moments worth remembering, like the "
                        "scans, the vaccine and the bag, and never more than two on your phone in a day. "
                        "Everything stays here, even on days your phone stays quiet.",
                        style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
                  ]),
                ),
                const SizedBox(height: 18),
                // 6b B5: tonight's campaign, from 19:00 (`pv_campaign_tonight.dart`).
                PvCampaignTonight(p: p),
                // Pee Safe demo: a sponsored note, once sent, in ParentVeda's voice.
                BrandInboxRows(p: p),
                if (!store.offersAsked && widget.pregnancy.isDueDateSet)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                    child: _OffersCard(p: p),
                  ),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                        widget.pregnancy.isDueDateSet
                            ? 'Nothing yet. Your first note arrives the morning your next week starts.'
                            : 'Add your due date in You and your notes start from your next week.',
                        style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PvRowGroup(p: p, children: [
                      for (final m in list)
                        PvListRow(
                          key: ValueKey('preg_msg_${m.id}'),
                          p: p,
                          leading: Stack(clipBehavior: Clip.none, children: [
                            PvMarkWell(p: p, hue: _hueFor(m.kind), size: 44, mark: _markFor(m.kind)),
                            if (!m.read)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: kPvInk, // one ParentVeda: no violet
                                    shape: BoxShape.circle,
                                    border: Border.all(color: p.ground, width: 2),
                                  ),
                                ),
                              ),
                          ]),
                          title: m.title,
                          line: m.body,
                          lineMaxLines: 3,
                          meta: _ago(m.at, now),
                          onTap: () => openPregMessage(context, m, widget.pregnancy),
                        ),
                    ]),
                  ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextButton.icon(
                    key: const ValueKey('preg_msg_settings'),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      settings: const RouteSettings(name: 'reminders'),
                      builder: (_) => RemindersScreen(controller: widget.pregnancy),
                    )),
                    icon: Icon(Icons.tune_rounded, size: 18, color: p.ink2),
                    label: Text('Choose what we send',
                        style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink2)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The one time she is asked about offers (Phase 6a). Apple's rule 4.5.4 and
/// the user's: nothing promotional until she says yes, inside the app, and a
/// way back out (the "Offers and new things" switch). Either answer stops the
/// card, and the toast says what changed (the app explains itself).
class _OffersCard extends StatelessWidget {
  const _OffersCard({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final store = PregMessagesStore.instance;
    return Container(
      key: const ValueKey('preg_msg_offers_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Classes and things for your week?',
            style: pvManrope(fontSize: 15.5, fontWeight: FontWeight.w700, color: p.ink1)),
        const SizedBox(height: 6),
        Text(
            'When there is a class, something useful for your week, or an expert you can '
            'talk to, we can tell you. At most twice a week, and still never more than two '
            'messages from us in a day.',
            style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        const SizedBox(height: 12),
        Wrap(spacing: 10, runSpacing: 8, children: [
          FilledButton(
            key: const ValueKey('preg_msg_offers_yes'),
            style: FilledButton.styleFrom(
                backgroundColor: kPvInk,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
            onPressed: () async {
              await store.answerOffers(true);
              if (context.mounted) {
                pvToast(context,
                    'Offers on. You can turn them off in Choose what we send.',
                    kind: PvToastKind.done);
              }
            },
            child: Text('Yes, tell me',
                style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          TextButton(
            key: const ValueKey('preg_msg_offers_no'),
            onPressed: () async {
              await store.answerOffers(false);
              if (context.mounted) {
                pvToast(context, 'No offers. You can turn them on in Choose what we send.');
              }
            },
            child: Text('Not now',
                style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink2)),
          ),
        ]),
      ]),
    );
  }
}

/// "From ParentVeda": one switch for the phone, one per kind. Drawn inside
/// Reminders, where the PDF says these are turned off.
class PregMessageSwitches extends StatelessWidget {
  const PregMessageSwitches({super.key});

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: PregMessagesStore.instance,
      builder: (context, _) {
        final store = PregMessagesStore.instance;
        Widget row(String title, String line, bool on, ValueChanged<bool> set, Key key) =>
            SwitchListTile.adaptive(
              key: key,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              title: Text(title,
                  style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w600, color: p.ink1)),
              subtitle: Text(line, style: pvManrope(fontSize: 12.5, color: p.ink3)),
              value: on,
              onChanged: set,
            );
        // A Material, not a coloured Container: a ListTile paints its ink on
        // the nearest Material, so a coloured box between them hid the press.
        return Material(
          key: const ValueKey('preg_msg_switches'),
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: p.line),
          ),
          child: Column(children: [
            row('On your phone too', 'Off keeps them in Messages only', store.phoneOn,
                store.setPhoneOn, const ValueKey('preg_msg_phone')),
            for (final k in PregMessageKind.values) ...[
              Divider(height: 1, thickness: 1, color: p.line, indent: 14, endIndent: 14),
              row(k.label, k.when, store.isOn(k), (v) => store.setOn(k, v),
                  ValueKey('preg_msg_kind_${k.name}')),
            ],
          ]),
        );
      },
    );
  }
}
