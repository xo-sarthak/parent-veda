// =============================================================================
//  Parenting — Messages: what the app said first, kept (2026-10-07)
// -----------------------------------------------------------------------------
//  The parenting twin of the pregnancy inbox (`preg_messages_screen.dart`), the
//  same layout and rows, so the stages read as one app. `PpMessagesStore`
//  decides WHAT is said and WHEN; this is where each is read, where it goes
//  when tapped, and where each kind is switched on or off.
//
//  EACH MESSAGE OPENS THE PAGE IT NAMES:
//    age, a new stage, something to try  -> the parenting home (the age page)
//    vaccines                             -> the vaccine tracker
//
//  ⚠️ FOR THE CHILD IT NAMES, FROM ANY HOME (2026-10-25, STAGE-TRANSITIONS
//  F3). Every child now has messages, in every stage, so a tap first makes
//  that child the active one, then opens the page. "Back to the home" is the
//  parenting home only when parenting is the root; a mother who is pregnant
//  again has the pregnancy home there, so her child's home opens over it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/last_profile.dart' show LastProfile;
import '../../services/life_stage_store.dart';
import '../../services/stage_gateway.dart';
import '../../widgets/global_ask_fab.dart' show appNavigatorKey;
import 'pp_child_profile.dart';
import '../../services/pp_messages_store.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart';
import '../products/pv_store_chrome.dart' show kPvInk, pvStorePalette;
import 'vax_tracker_screen.dart';

const String kPpMessagesRoute = 'pp/messages';

void openPpMessages(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kPpMessagesRoute),
    builder: (_) => const PpMessagesScreen(),
  ));
}

/// Opens the page [m] names.
void openPpMessage(BuildContext context, PpMessage m) {
  pvCommitFeedback();
  PpMessagesStore.instance.markRead(m.id);
  final kids = ChildProfileStore.instance;
  final whose = ppMessageChildId(m.id, [for (final c in kids.children) c.id]);
  if (whose != null && whose != kids.activeChildId) kids.switchTo(whose);
  switch (m.kind) {
    case PpMessageKind.vaccine:
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'pp/vaccines'),
        builder: (_) => const VaxTrackerScreen(),
      ));
    case PpMessageKind.age:
    case PpMessageKind.milestones:
    case PpMessageKind.activity:
      // The age page is the parenting home: back to it. When parenting is not
      // the root (pregnant again, trying, the learning space), the child's
      // home opens over the root instead. The navigator is held first: this
      // page's own context is gone once it is popped.
      final nav = Navigator.of(context);
      nav.popUntil((r) => r.isFirst);
      if (LifeStageStore.instance.stage != LifeStage.parenting) {
        openStageDoor(nav.context, StageDoor.parenting);
      }
  }
}

/// A phone tap: open the message's page, or the inbox when it is not known.
void ppOpenMessageFromPhone(PpMessage? m, {int attempt = 0}) {
  final ctx = appNavigatorKey.currentContext;
  // Waits for the home to be shown (F6, 2026-10-25), so a tap that launched
  // the app is not pushed under the splash. Kept for revert:
  //   if (ctx == null) {
  if (ctx == null || !LastProfile.instance.homeShown) {
    if (attempt < 20) {
      Future<void>.delayed(const Duration(milliseconds: 500), () => ppOpenMessageFromPhone(m, attempt: attempt + 1));
    }
    return;
  }
  m == null ? openPpMessages(ctx) : openPpMessage(ctx, m);
}

IntentMark _markFor(PpMessageKind k) => switch (k) {
      PpMessageKind.age => IntentMark.calendarDay,
      PpMessageKind.vaccine => IntentMark.pillMark,
      PpMessageKind.milestones => IntentMark.stepsMark,
      PpMessageKind.activity => IntentMark.playMark,
    };

double _hueFor(PpMessageKind k) => switch (k) {
      PpMessageKind.age => 268,
      PpMessageKind.vaccine => 160,
      PpMessageKind.milestones => 28,
      PpMessageKind.activity => 140,
    };

String _ago(DateTime at, DateTime now) {
  final d = DateTime(now.year, now.month, now.day).difference(DateTime(at.year, at.month, at.day)).inDays;
  if (d <= 0) return 'Today';
  if (d == 1) return 'Yesterday';
  if (d < 7) return '$d days ago';
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${at.day} ${m[at.month - 1]}';
}

class PpMessagesScreen extends StatefulWidget {
  const PpMessagesScreen({super.key});

  @override
  State<PpMessagesScreen> createState() => _PpMessagesScreenState();
}

class _PpMessagesScreenState extends State<PpMessagesScreen> {
  @override
  void initState() {
    super.initState();
    PpMessagesStore.instance.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: PpMessagesStore.instance,
      builder: (context, _) {
        final store = PpMessagesStore.instance;
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
                  child: Text('Mark all read', style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink2)),
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
                    Text('Messages', style: pvFraunces(fontSize: 28, fontWeight: FontWeight.w500, color: p.ink1)),
                    const SizedBox(height: 6),
                    Text('A note on each new week and month, a reminder before each vaccine, and a word when '
                        'a new stage starts.',
                        style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
                  ]),
                ),
                const SizedBox(height: 18),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Nothing yet. Your first note arrives on your baby\'s next week or month.',
                        key: const ValueKey('pp_msg_empty'), style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PvRowGroup(p: p, children: [
                      for (final m in list)
                        PvListRow(
                          key: ValueKey('pp_msg_${m.id}'),
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
                                    color: kPvInk,
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
                          onTap: () => openPpMessage(context, m),
                        ),
                    ]),
                  ),
                const SizedBox(height: 26),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Choose what we send',
                      style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1)),
                ),
                const SizedBox(height: 10),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: PpMessageSwitches()),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One switch for the phone, one per kind. A Material, so the ripple shows.
class PpMessageSwitches extends StatelessWidget {
  const PpMessageSwitches({super.key});

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: PpMessagesStore.instance,
      builder: (context, _) {
        final store = PpMessagesStore.instance;
        Widget row(String title, String line, bool on, ValueChanged<bool> set, Key key) => SwitchListTile.adaptive(
              key: key,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              title: Text(title, style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w600, color: p.ink1)),
              subtitle: Text(line, style: pvManrope(fontSize: 12.5, color: p.ink3)),
              value: on,
              onChanged: set,
            );
        return Material(
          key: const ValueKey('pp_msg_switches'),
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: p.line)),
          child: Column(children: [
            row('On your phone too', 'Off keeps them in Messages only', store.phoneOn, store.setPhoneOn,
                const ValueKey('pp_msg_phone')),
            for (final k in PpMessageKind.values) ...[
              Divider(height: 1, thickness: 1, color: p.line, indent: 14, endIndent: 14),
              row(k.label, k.when, store.isOn(k), (v) => store.setOn(k, v), ValueKey('pp_msg_kind_${k.name}')),
            ],
          ]),
        );
      },
    );
  }
}
