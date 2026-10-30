// Community alerts (C3-2, 0147): route 'community/alerts'. Opens from
// Settings, Notifications, Community in every stage, and from the gear on
// Replies to you. Also here: the one-time ask after her first live post.
//
// The words and layout are the signed-off prototype's (P0, "Ask after her
// first post", "Community alerts", "Mute one post"). The rules behind each
// switch are the server's (0147); this screen only shows and changes them.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;

import '../../services/community_alerts.dart';
import '../../widgets/pv_toast.dart';
import '../products/pv_store_chrome.dart' show kPvInk;
import 'community_chrome.dart';

// ---- words (prototype) --------------------------------------------------------

const String kAlertsAskTitle = 'Want to know when someone replies?';
const String kAlertsAskLead = 'We will send one quiet alert when a parent replies to your post. This is all your lock screen will show:';
const String kAlertsAskNote = 'Never their words, the room or a name. Up to 3 a day, and nothing between 9 pm and 8 am.';
const String kAlertsAskYes = 'Turn on reply alerts';
const String kAlertsAskNo = 'Not now';
const String kAlertsToastYes = 'Reply alerts are on. One quiet alert when someone replies to your post.';
const String kAlertsToastNo = 'No alerts. Replies still gather in Replies to you. To turn alerts on: Settings, Notifications, Community.';
const String kAlertsToastPhoneBlocks =
    'Your phone is blocking alerts from ParentVeda. You can allow them in phone settings, and Community alerts links there.';
const String kAlertsToastOffline = 'No connection, so reply alerts are not on yet. Turn them on in Settings, Notifications, Community.';
const String kAlertsPhoneOff = 'Notifications are off for ParentVeda on this phone, so nothing below can ring.';
const String kAlertsMuteOff = 'Turn off replies for this post';
const String kAlertsMuteOn = 'Turn on replies for this post';
const String kAlertsMuteOffNote = 'No alerts for this post. Replies still show in Replies to you.';
const String kAlertsMuteOnNote = 'You will get an alert again when someone replies.';
const String kAlertsMutedToast = 'Alerts off for this post. Replies still show in Replies to you.';
const String kAlertsUnmutedToast = 'Alerts back on for this post.';

void openCommunityAlerts(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const CommunityAlertsScreen(),
    settings: const RouteSettings(name: kCommunityAlertsRoute),
  ));
}

const String kCommunityAlertsRoute = 'community/alerts';

/// The ask, once, after her own post is live (C8, P0-1). Called by the post
/// screen when it opens on her post. Does nothing if she was already asked
/// on any phone, or on this one.
Future<void> maybeAskCommunityAlerts(BuildContext context, {required bool postIsMineAndLive}) async {
  final alerts = CommunityAlerts.instance;
  if (!await alerts.shouldAsk(postIsMineAndLive: postIsMineAndLive)) return;
  if (!context.mounted) return;
  final yes = await showCommunitySheet<bool>(context, (c) => const _AskSheet());
  if (yes == null || !context.mounted) return;   // dismissed: ask again next time
  final saved = await alerts.answerAsk(yes: yes);
  if (!context.mounted) return;
  if (!yes) {
    pvToast(context, kAlertsToastNo, kind: PvToastKind.info, hold: const Duration(seconds: 5));
    return;
  }
  if (!saved) {
    pvToast(context, kAlertsToastOffline, kind: PvToastKind.gentle, hold: const Duration(seconds: 5));
    return;
  }
  // Android's own question follows her yes, only if the phone has not allowed
  // ParentVeda yet.
  final allowed = await CommunityAlerts.phoneAllows() || await CommunityAlerts.askPhone();
  if (!context.mounted) return;
  pvToast(context, allowed ? kAlertsToastYes : kAlertsToastPhoneBlocks,
      kind: allowed ? PvToastKind.done : PvToastKind.gentle, hold: const Duration(seconds: 5));
}

class _AskSheet extends StatelessWidget {
  const _AskSheet();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Text(kAlertsAskTitle, style: cmTitle(24)),
          const SizedBox(height: 8),
          Text(kAlertsAskLead, style: cmText(14.5, color: cmP.ink2)),
          const SizedBox(height: 12),
          const CommunityAlertPreview(flat: true),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.lock_outline_rounded, size: 18, color: cmP.ink3),
            const SizedBox(width: 8),
            Expanded(child: Text(kAlertsAskNote, style: cmText(12.5, color: cmP.ink3))),
          ]),
          const SizedBox(height: 16),
          CommunityInkButton(label: kAlertsAskYes, onTap: () => Navigator.pop(context, true)),
          const SizedBox(height: 8),
          // "Not now" is the same size and weight as yes (prototype).
          _OutlineButton(label: kAlertsAskNo, onTap: () => Navigator.pop(context, false)),
        ]),
      );
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: kPvInk, width: 1.5),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 13),
        ),
        child: Text(label, style: cmText(15, weight: FontWeight.w700, color: kPvInk)),
      );
}

/// A notification as Android draws it, with the exact words 0147 sends. The
/// "this is all your lock screen will show" preview.
class CommunityAlertPreview extends StatelessWidget {
  const CommunityAlertPreview({super.key, this.flat = false});
  final bool flat;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: flat ? const Color(0xFFF3F3F4) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: flat ? null : const [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(color: kPvInk, borderRadius: BorderRadius.circular(7)),
            child: const Icon(Icons.spa_outlined, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ParentVeda · Replies · now', style: cmText(11.5, weight: FontWeight.w600, color: cmP.ink2)),
              Text(kAlertReplyTitle, style: cmText(14, weight: FontWeight.w700)),
              Text(kAlertReplyBody, style: cmText(13.5, color: cmP.ink2)),
            ]),
          ),
        ]),
      );
}

class CommunityAlertsScreen extends StatefulWidget {
  const CommunityAlertsScreen({super.key});

  @override
  State<CommunityAlertsScreen> createState() => _CommunityAlertsScreenState();
}

class _CommunityAlertsScreenState extends State<CommunityAlertsScreen> with WidgetsBindingObserver {
  final _alerts = CommunityAlerts.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _alerts.load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Back from the phone's settings: read whether it now allows ParentVeda.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _alerts.load();
  }

  Future<void> _flip(String kind, bool on) async {
    if (!_alerts.phoneOn) {
      pvToast(context, 'Your phone is blocking alerts from ParentVeda. Open phone settings first.', kind: PvToastKind.gentle);
      return;
    }
    final ok = await _alerts.setSwitch(kind, on);
    if (!mounted) return;
    if (!ok) {
      pvToast(context, 'No connection. Nothing changed; try again when you are online.', kind: PvToastKind.gentle);
      return;
    }
    final label = switch (kind) {
      CommunityAlerts.kindReplies => 'Reply alerts',
      CommunityAlerts.kindBookings => 'Booking alerts',
      _ => 'Moderator alerts',
    };
    final extra = kind == CommunityAlerts.kindReplies && !on ? ' Replies still gather in Replies to you.' : '';
    pvToast(context, '$label ${on ? 'on' : 'off'}.$extra', kind: PvToastKind.done);
  }

  Future<void> _mutedList() async {
    await showCommunitySheet<void>(
      context,
      (c) => AnimatedBuilder(
        animation: _alerts,
        builder: (c, _) => ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(0, 6, 0, 12), children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Text('Muted posts', style: cmTitle(24)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text('No alerts for these. Their replies still show in Replies to you.',
                style: cmText(14, color: cmP.ink2)),
          ),
          if (_alerts.muted.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text('None now. Turn off replies for one post from its ⋯ menu.', style: cmText(14, color: cmP.ink3)),
            ),
          for (final m in _alerts.muted)
            CommunitySheetRow(
              icon: Icons.notifications_off_outlined,
              label: m.title,
              note: [if (m.room != null) m.room!, if (!m.mine) 'you replied'].join(' · '),
              onTap: () => openCommunityPost(c, m.postId),
              trailing: TextButton(
                onPressed: () async {
                  final ok = await _alerts.mute(m.postId, on: false);
                  if (c.mounted) {
                    pvToast(c, ok ? 'Alerts back on for that post.' : 'No connection. Nothing changed.',
                        kind: ok ? PvToastKind.done : PvToastKind.gentle);
                  }
                },
                child: Text('Unmute', style: cmText(13, weight: FontWeight.w700, color: kPvInk)),
              ),
            ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _alerts,
        builder: (context, _) {
          final off = !_alerts.phoneOn;
          Widget sw(String kind, bool value) => Switch(
                value: !off && value,
                activeTrackColor: kPvInk,
                onChanged: (v) => _flip(kind, v),
              );
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              leading: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_rounded, color: kPvInk),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: Text('Community alerts', style: cmText(17, weight: FontWeight.w800)),
              centerTitle: true,
            ),
            body: !_alerts.signedIn
                ? CommunityEmpty(
                    icon: Icons.lock_outline_rounded,
                    title: 'Sign in for Community alerts',
                    body: 'Alerts are for replies to your posts and the sessions you book. Replies always gather in Replies to you.',
                    action: 'Sign in',
                    onAction: () => openCommunitySignIn(context),
                  )
                : ListView(padding: const EdgeInsets.only(bottom: 24), children: [
                    if (off)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Icon(Icons.info_outline_rounded, size: 18, color: cmP.ink2),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(children: [
                              Text('$kAlertsPhoneOff ', style: cmText(12.5, color: cmP.ink2)),
                              GestureDetector(
                                onTap: () => unawaited(openAppSettings()),
                                child: Text('Open phone settings',
                                    style: cmText(12.5, weight: FontWeight.w700, color: kPvInk)
                                        .copyWith(decoration: TextDecoration.underline)),
                              ),
                            ]),
                          ),
                        ]),
                      ),
                    _Row(
                      title: 'Replies to your posts',
                      note: 'One alert per post, never their words. Up to 3 a day.',
                      dim: off,
                      trailing: sw(CommunityAlerts.kindReplies, _alerts.replies),
                    ),
                    _Row(
                      title: 'Your bookings',
                      note: 'When a session you booked moves to a new time. On from the moment you book.',
                      dim: off,
                      trailing: sw(CommunityAlerts.kindBookings, _alerts.bookings),
                    ),
                    if (_alerts.moderation != null)
                      _Row(
                        title: 'Posts that may need a moderator',
                        note: 'Moderators only. A post that may be at risk, at any hour.',
                        dim: off,
                        trailing: sw(CommunityAlerts.kindModeration, _alerts.moderation!),
                      ),
                    const _Group('What your lock screen shows'),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: CommunityAlertPreview(flat: true),
                    ),
                    const _Group('Quiet hours'),
                    _Row(
                      icon: Icons.bedtime_outlined,
                      title: '9 pm to 8 am',
                      note: 'Nothing rings. Replies that came overnight arrive as one alert at 8 am.',
                    ),
                    const _Group('Muted posts'),
                    _Row(
                      icon: Icons.notifications_off_outlined,
                      title: switch (_alerts.muted.length) {
                        0 => 'No muted posts',
                        1 => '1 post',
                        final n => '$n posts',
                      },
                      note: _alerts.muted.isEmpty
                          ? 'Turn off replies for one post from its ⋯ menu.'
                          : 'No alerts for these. Their replies still show in Replies to you.',
                      trailing: Icon(Icons.chevron_right_rounded, color: cmP.ink3),
                      onTap: _mutedList,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Text('Replies always gather in Replies to you, with or without alerts.',
                          style: cmText(12.5, color: cmP.ink3)),
                    ),
                  ]),
          );
        },
      );
}

class _Group extends StatelessWidget {
  const _Group(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
        child: Text(title, style: cmText(12, weight: FontWeight.w700, color: cmP.ink3)),
      );
}

class _Row extends StatelessWidget {
  const _Row({required this.title, required this.note, this.trailing, this.icon, this.dim = false, this.onTap});
  final String title;
  final String note;
  final Widget? trailing;
  final IconData? icon;
  final bool dim;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cmP.line))),
          child: Row(children: [
            if (icon != null) ...[Icon(icon, size: 20, color: cmP.ink1), const SizedBox(width: 12)],
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: cmText(15, weight: FontWeight.w600, color: dim ? cmP.ink3 : cmP.ink1)),
                Text(note, style: cmText(12.5, color: cmP.ink3)),
              ]),
            ),
            ?trailing,
          ]),
        ),
      );
}
