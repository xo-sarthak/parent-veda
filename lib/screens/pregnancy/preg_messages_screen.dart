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

import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/life_stage_store.dart';
import '../../services/preg_messages_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/stage_gateway.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show appNavigatorKey, FabState;
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../doors/pv_door_router.dart' show openPvDoorRead;
import '../doors/pv_door_screen.dart' show pvDoorScreenForBracket;
import '../doors/pv_list_row.dart';
import '../preg_week_screen.dart';
import '../products/pv_store_chrome.dart' show kPvInk, pvStorePalette;
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
    case PregMessageKind.ntScan:
    case PregMessageKind.anomalyScan:
      final door = pvDoorScreenForBracket('pregnancy_scans_tests', c);
      if (door != null) push('bracket/pregnancy_scans_tests', () => door);
    case PregMessageKind.tdap:
      openPvDoorRead(context, 'preg_scan_read_vaccines', c);
    case PregMessageKind.movements:
      push('tools/movement', () => BabyMovementScreen(controller: c));
    case PregMessageKind.hospitalBag:
      push('tools/hospital_bag', () => ReadyForBirthScreen(controller: c));
    case PregMessageKind.babyArrived:
      // The same sheet and the same move as You › "Baby has arrived".
      unawaited(showPvAddChildSheet(context, arrival: true).then((added) {
        if (added && context.mounted) {
          LifeStageStore.instance.setStage(LifeStage.parenting);
          openStageDoor(context, StageDoor.parenting);
        }
      }));
  }
}

/// A phone tap: wait for the pregnancy shell, then open the message's page,
/// or the inbox when the message is not known.
void pregOpenMessageFromPhone(PregMessage? m, {int attempt = 0}) {
  final ctx = appNavigatorKey.currentContext;
  final c = PregnancyController.current;
  if (ctx == null || c == null || FabState.instance.inTtc || FabState.instance.inParenting) {
    if (attempt < 20) {
      Future<void>.delayed(const Duration(milliseconds: 500),
          () => pregOpenMessageFromPhone(m, attempt: attempt + 1));
    }
    return;
  }
  if (m == null) {
    openPregMessages(ctx, c);
  } else {
    openPregMessage(ctx, m, c);
  }
}

IntentMark _markFor(PregMessageKind k) => switch (k) {
      PregMessageKind.newWeek => IntentMark.calendarDay,
      PregMessageKind.ntScan => IntentMark.reportPage,
      PregMessageKind.anomalyScan => IntentMark.reportPage,
      PregMessageKind.tdap => IntentMark.askDoctor,
      PregMessageKind.movements => IntentMark.bodyMark,
      PregMessageKind.hospitalBag => IntentMark.bagMark,
      PregMessageKind.babyArrived => IntentMark.cuppedHands,
    };

double _hueFor(PregMessageKind k) => switch (k) {
      PregMessageKind.newWeek => 268,
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
                    Text(
                        'A note on the morning each new week starts, and a word at the moments '
                        'worth remembering: the scans, the vaccine, the bag.',
                        style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
                  ]),
                ),
                const SizedBox(height: 18),
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
