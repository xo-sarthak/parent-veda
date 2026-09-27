// =============================================================================
//  Messages - what ParentVeda has said to her, newest first
// -----------------------------------------------------------------------------
//  The in-app half of `TtcMessagesStore`. Every message that went to her phone
//  is also here, and so is every message she never allowed on the phone.
//
//  ⚠️ THE EMPTY STATE IS THE FEATURE'S ADVERTISEMENT (CLAUDE.md). With nothing
//  delivered yet, the screen says what will arrive and when, with a switch on
//  each. The same list sits under the messages once there are some, so the
//  switches never move and she never has to hunt for a setting.
//
//  ⚠️ A TAP OPENS THE FIRST DESTINATION THAT RESOLVES. See
//  `TtcMessageKindInfo.destinations`: a read still being written falls through
//  to the door that already ships, rather than to nothing. A treatment message
//  carries its own (`TtcMessage.destinations`, 2026-09-26).
//
//  ⚠️ THE REVIEW FIXES, 2026-09-26 (Mobbin review M1 to M4):
//    * M1: the empty state is no longer text on a tinted box. A drawn mark in
//      a hue well, a value statement (not "Nothing here yet"), three lines
//      with small icons, and one outlined pill, "Choose what we send", that
//      scrolls to the switches. Apple Health's "Set Up Medications"
//      (https://mobbin.com/screens/652a9e9c-8a08-4a0a-93f9-8a357e3abca7).
//    * M2: a row leads with the kind's drawn mark in a 40 well, the time
//      top right, the unread dot trailing, and presses (`PvPress`). Flo's
//      Messages (https://mobbin.com/screens/805ee984-337b-4ed3-8bed-bb6abcab207d).
//    * M3: one switch, `TtcSwitchRow`, shared with the content-prefs sheet.
//    * M4: "What we send" is a section head in the display face.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_messages_store.dart';
import '../../ttc/ttc_period_due.dart';
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../v2/v2_palette.dart';
import 'chats/ttc_chat.dart';
import 'ttc_common.dart';
import 'ttc_content_prefs_sheet.dart' show TtcSwitchRow;
import 'ttc_surface_router.dart';

/// The empty state's words (M1): what arrives, not what is missing.
const String kTtcMessagesEmptyTitle =
    'A few words from us, at the moments they help';
const String kTtcMessagesEmptyBody =
    'Each one comes once, at its moment. You choose which ones below.';
const List<(IconData, String)> kTtcMessagesEmptyLines = [
  (Icons.wb_twilight_rounded, 'The morning your fertile days start'),
  (Icons.help_outline_rounded, 'A day after your period was due'),
  (Icons.favorite_border_rounded, 'After a hard month, a few kind words'),
];
const String kTtcMessagesChoose = 'Choose what we send';

/// The drawn mark for each kind of message (M2).
IntentMark ttcMessageMark(TtcMessageKind k) => switch (k) {
      TtcMessageKind.windowOpens => IntentMark.cycleRing,
      TtcMessageKind.periodCame => IntentMark.cuppedHands,
      TtcMessageKind.lateByOne => IntentMark.questionMark,
      TtcMessageKind.cycleReport => IntentMark.reportPage,
      TtcMessageKind.tryingLong => IntentMark.askDoctor,
      TtcMessageKind.treatment => IntentMark.calendarDay,
    };

/// The hue of each kind's well.
double _hueFor(TtcMessageKind k) => switch (k) {
      TtcMessageKind.windowOpens => 344,
      TtcMessageKind.periodCame => 268,
      TtcMessageKind.lateByOne => 206,
      TtcMessageKind.cycleReport => 42,
      TtcMessageKind.tryingLong => 160,
      TtcMessageKind.treatment => 222,
    };

class TtcMessagesScreen extends StatefulWidget {
  const TtcMessagesScreen({super.key});

  @override
  State<TtcMessagesScreen> createState() => _TtcMessagesScreenState();
}

class _TtcMessagesScreenState extends State<TtcMessagesScreen> {
  final _store = TtcMessagesStore.instance;

  /// Where "Choose what we send" scrolls to.
  final GlobalKey _settingsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Idempotent. If startup already ran it, this is one more refresh; if it
    // did not, the list still fills the moment she opens it.
    _store.init();
  }

  void _open(TtcMessage m) {
    _store.markRead(m.id);
    // Kept for revert: ttcFirstOpenable(m.kind.destinations).
    final id = ttcFirstOpenable(m.destinations);
    if (id != null) openTtcSurface(context, id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ttcBg,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _store,
          builder: (context, _) {
            final list = _store.delivered();
            final unread = list.where((m) => !m.read).length;
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
              children: [
                TtcBackBar(
                  title: 'Messages',
                  trailing: unread == 0
                      ? null
                      : TextButton(
                          onPressed: _store.markAllRead,
                          child: Text('Mark all read',
                              style: ttcBody(13,
                                  color: ttcPurple,
                                  w: FontWeight.w700,
                                  h: 1.2)),
                        ),
                ),
                const SizedBox(height: 14),
                // Kept for revert: `const _Empty()` and a row + divider pair.
                if (list.isEmpty)
                  _EmptyInvite(onChoose: () {
                    final c = _settingsKey.currentContext;
                    if (c != null) {
                      Scrollable.ensureVisible(c,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut);
                    }
                  })
                else
                  for (final m in list)
                    _MessageTile(message: m, onTap: () => _open(m)),
                const SizedBox(height: 28),
                _Settings(key: _settingsKey, store: _store),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Kept for revert: the empty state before the review (M1), text on a
// tinted box.
// class _Empty extends StatelessWidget {
//   const _Empty();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//           color: ttcPanel, borderRadius: BorderRadius.circular(ttcCardRadius)),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         const Icon(Icons.mark_email_unread_outlined,
//             size: 26, color: ttcPurple),
//         const SizedBox(height: 12),
//         Text('Nothing here yet', style: ttcJakarta(18)),
//         const SizedBox(height: 6),
//         Text(
//           "We'll write to you at a few moments in your cycle, when a word "
//           "from us might help. Here's what arrives, and when. Each one comes "
//           'once, and you can switch any of them off below.',
//           style: ttcBody(14, h: 1.5),
//         ),
//       ]),
//     );
//   }
// }

// Kept for revert: the row before the review (M2), a leading dot slot.
// class _MessageRow extends StatelessWidget {
//   const _MessageRow({required this.message, required this.onTap});
//   final TtcMessage message;
//   final VoidCallback onTap;
//
//   String _when(DateTime at) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final day = DateTime(at.year, at.month, at.day);
//     final diff = today.difference(day).inDays;
//     if (diff == 0) return 'Today';
//     if (diff == 1) return 'Yesterday';
//     return ttcDayDate(at);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final unread = !message.read;
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           // The unread dot. A fixed slot, so titles line up read or not.
//           SizedBox(
//             width: 18,
//             child: Padding(
//               padding: const EdgeInsets.only(top: 6),
//               child: unread
//                   ? Container(
//                       key: const ValueKey('ttc-message-unread'),
//                       width: 8,
//                       height: 8,
//                       decoration: const BoxDecoration(
//                           color: ttcCoral, shape: BoxShape.circle),
//                     )
//                   : null,
//             ),
//           ),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(children: [
//                     Expanded(
//                       child: Text(message.title,
//                           style: ttcJakarta(15.5,
//                               w: unread ? FontWeight.w800 : FontWeight.w600)),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(_when(message.at),
//                         style: ttcBody(12, color: ttcMuted, h: 1.2)),
//                   ]),
//                   const SizedBox(height: 4),
//                   Text(message.body,
//                       maxLines: 3,
//                       overflow: TextOverflow.ellipsis,
//                       style: ttcBody(13.5, h: 1.45)),
//                 ]),
//           ),
//           const SizedBox(width: 6),
//           const Padding(
//             padding: EdgeInsets.only(top: 2),
//             child:
//                 Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
//           ),
//         ]),
//       ),
//     );
//   }
// }

/// The empty state (M1): a drawn mark in a hue well, what arrives, three
/// lines with small icons, and one outlined pill to the switches. No box.
class _EmptyInvite extends StatelessWidget {
  const _EmptyInvite({required this.onChoose});
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(222, p);
    return Padding(
      key: const ValueKey('ttc-messages-empty'),
      padding: const EdgeInsets.only(top: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
              color: tint, borderRadius: BorderRadius.circular(28)),
          padding: const EdgeInsets.all(20),
          child: HubIntentArt(mark: IntentMark.askDoctor, tint: tint),
        ),
        const SizedBox(height: 18),
        Text(kTtcMessagesEmptyTitle,
            style: pvFraunces(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: p.ink1)),
        const SizedBox(height: 8),
        Text(kTtcMessagesEmptyBody,
            style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
        const SizedBox(height: 16),
        for (final (icon, line) in kTtcMessagesEmptyLines)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Icon(icon, size: 18, color: p.ink1),
              const SizedBox(width: 12),
              Expanded(
                child: Text(line,
                    style:
                        pvManrope(fontSize: 14, height: 1.4, color: p.ink1)),
              ),
            ]),
          ),
        const SizedBox(height: 10),
        PvPress(
          child: OutlinedButton(
            key: const ValueKey('ttc-messages-choose'),
            onPressed: () {
              pvCommitFeedback();
              onChoose();
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              shape: const StadiumBorder(),
              side: BorderSide(color: p.ink1, width: 1.3),
              padding: const EdgeInsets.symmetric(horizontal: 22),
            ),
            child: Text(kTtcMessagesChoose,
                style: pvManrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: p.ink1)),
          ),
        ),
      ]),
    );
  }
}

/// One message (M2): the kind's drawn mark in a 40 well, the title, the time
/// at the top right, two lines of body, the unread dot trailing, a hairline.
class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message, required this.onTap});
  final TtcMessage message;
  final VoidCallback onTap;

  String _when(DateTime at) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return ttcDayDate(at);
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final unread = !message.read;
    final tint = v2BlockTint(_hueFor(message.kind), p);
    return PvPress(
      child: InkWell(
        onTap: () {
          pvCommitFeedback();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: p.line))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: tint, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(7),
              child: HubIntentArt(
                  mark: ttcMessageMark(message.kind), tint: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: Text(message.title,
                            style: pvManrope(
                                fontSize: 15,
                                height: 1.3,
                                fontWeight:
                                    unread ? FontWeight.w800 : FontWeight.w600,
                                color: p.ink1)),
                      ),
                      const SizedBox(width: 8),
                      Text(_when(message.at),
                          style: pvManrope(fontSize: 12, color: p.ink3)),
                    ]),
                    const SizedBox(height: 4),
                    Text(message.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 13.5, height: 1.45, color: p.ink2)),
                  ]),
            ),
            // The unread dot, trailing. A fixed slot, so rows line up.
            SizedBox(
              width: 20,
              child: Padding(
                padding: const EdgeInsets.only(top: 22, left: 10),
                child: unread
                    ? Container(
                        key: const ValueKey('ttc-message-unread'),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: ttcCoral, shape: BoxShape.circle),
                      )
                    : null,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Settings extends StatelessWidget {
  const _Settings({super.key, required this.store});
  final TtcMessagesStore store;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // A section head in the display face (M4). Kept for revert:
      // Text('What we send', style: ttcJakarta(16)),
      Text('What we send',
          style: pvFraunces(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: V2PaletteStore.instance.current.ink1)),
      const SizedBox(height: 4),
      Text('Each message comes once, at its moment.',
          style: ttcBody(13, color: ttcMuted, h: 1.4)),
      const SizedBox(height: 8),
      for (final k in TtcMessageKind.values)
        TtcSwitchRow(
          key: ValueKey('ttc-message-switch-${k.name}'),
          title: k.label,
          sub: k.when,
          value: store.isOn(k),
          onChanged: (v) => store.setOn(k, v),
        ),
      const SizedBox(height: 8),
      ttcDivider(),
      TtcSwitchRow(
        key: const ValueKey('ttc-message-switch-phone'),
        title: 'Also send to my phone',
        sub: 'As a notification, if your phone allows ParentVeda to send them. '
            'They stay here either way.',
        value: store.phoneOn,
        onChanged: store.setPhoneOn,
      ),
    ]);
  }
}

// Kept for revert: the Messages switch before the review (M3), an ink
// track that no other TTC switch used. `TtcSwitchRow` replaces it.
// class _SwitchRow extends StatelessWidget {
//   const _SwitchRow({
//     required this.title,
//     required this.sub,
//     required this.value,
//     required this.onChanged,
//   });
//
//   final String title;
//   final String sub;
//   final bool value;
//   final ValueChanged<bool> onChanged;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Expanded(
//           child:
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(title,
//                 style: ttcBody(14.5,
//                     color: ttcInk, w: FontWeight.w700, h: 1.3)),
//             const SizedBox(height: 2),
//             Text(sub, style: ttcBody(12.5, color: ttcSoft, h: 1.45)),
//           ]),
//         ),
//         const SizedBox(width: 10),
//         Switch(
//           value: value,
//           onChanged: onChanged,
//           activeThumbColor: Colors.white,
//           activeTrackColor: ttcTitleInk,
//         ),
//       ]),
//     );
//   }
// }
