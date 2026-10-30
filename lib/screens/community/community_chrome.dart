// The community's shared parts: routes, the post card, polls, photos, the
// sheets (first time, report, block, menus) and the one place every outcome
// is turned into words. Screens are in this folder; the design and its
// Mobbin sources are in docs/COMMUNITY.md.
//
// UX choices made on purpose, from the apps mothers already use:
//  · POST sits TOP RIGHT in the composer (Reddit, X, Threads, Instagram).
//    Two reasons: it is where a thumb that has used any of those apps goes
//    looking, and while she types the keyboard covers the bottom of the
//    screen, so a bottom button would be hidden at the exact moment she
//    needs it.
//  · WRITE A POST floats bottom right on the feeds (Flo, Reddit, X): the
//    thumb's resting place, and it folds to a round button while she scrolls
//    so it never covers the text she is reading.
//  · REPLY is a bar docked to the bottom of a post (Flo, Instagram): it
//    rides up with the keyboard, so the post stays visible above it.
//  · Every write ends in a toast that says what happened (pvToast, the one
//    notice). A post that is waiting for review says so; a post kept on the
//    phone for later says so. Nothing is silent.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/pv_community.dart';
import '../../services/community_safety.dart';
import '../../services/pv_community_store.dart';
import '../../theme/pv_fonts.dart';
import '../../theme/pv_motion.dart';
import '../../widgets/pv_feedback.dart' show PvPress;
import '../../widgets/pv_toast.dart';
import '../auth/auth_flow_screen.dart';
import '../products/pv_store_chrome.dart' show kPvInk;
import '../v2/v2_palette.dart';
import 'community_activity_screen.dart';
import 'community_compose_screen.dart';
import 'community_home_screen.dart';
import 'community_marks.dart';
import 'community_moderation_screen.dart';
import 'community_offering_thread.dart';
import 'community_post_screen.dart';
import 'community_profile_screen.dart';
import 'community_room_screen.dart';

// ---- routes -------------------------------------------------------------------
//
// Route names are load-bearing: the Ask FAB reads them, and
// test/community_reachability_test.dart greps for every entry point.

const String kCommunityRoute = 'community';
const String kCommunityRoomPrefix = 'community/room/';
const String kCommunityPostPrefix = 'community/post/';
const String kCommunityComposeRoute = 'community/compose';
const String kCommunityProfileRoute = 'community/profile';
const String kCommunityActivityRoute = 'community/activity';
const String kCommunityModerationRoute = 'community/moderation';

/// The community home; with [roomId], straight into that room.
void openCommunity(BuildContext context, {String? roomId}) {
  final nav = Navigator.of(context);
  nav.push(MaterialPageRoute<void>(
    builder: (_) => const CommunityHomeScreen(),
    settings: const RouteSettings(name: kCommunityRoute),
  ));
  if (roomId != null && roomId.isNotEmpty) openCommunityRoom(context, roomId, nav: nav);
}

void openCommunityRoom(BuildContext context, String roomId, {NavigatorState? nav}) {
  (nav ?? Navigator.of(context)).push(MaterialPageRoute<void>(
    builder: (_) => CommunityRoomScreen(roomId: roomId),
    settings: RouteSettings(name: '$kCommunityRoomPrefix$roomId'),
  ));
}

void openCommunityPost(BuildContext context, String postId) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => CommunityPostScreen(postId: postId),
    settings: RouteSettings(name: '$kCommunityPostPrefix$postId'),
  ));
}

/// The composer rises from the bottom (a full-screen dialog), the way
/// writing opens in every app she knows. It returns the new post's id.
///
/// (0137) [about] tags a course post to a lesson or session ([aboutLabel] is
/// how the chip reads, "Lesson 2"). [asTeam] opens the moderators' "Post as
/// ParentVeda team" mode, with pin days.
Future<void> openCommunityCompose(
  BuildContext context, {
  String? roomId,
  PvPostAbout? about,
  String? aboutLabel,
  bool asTeam = false,
}) async {
  if (!await communityEnsureMember(context)) return;
  if (!context.mounted) return;
  final id = await Navigator.of(context).push<String>(MaterialPageRoute<String>(
    fullscreenDialog: true,
    builder: (_) => CommunityComposeScreen(roomId: roomId, about: about, aboutLabel: aboutLabel, asTeam: asTeam),
    settings: const RouteSettings(name: kCommunityComposeRoute),
  ));
  if (id != null && context.mounted) openCommunityPost(context, id);
}

void openCommunityProfile(BuildContext context, {String? fromId, bool anon = true}) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => CommunityProfileScreen(fromId: fromId, anon: anon),
    settings: const RouteSettings(name: kCommunityProfileRoute),
  ));
}

void openCommunityActivity(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const CommunityActivityScreen(),
    settings: const RouteSettings(name: kCommunityActivityRoute),
  ));
}

void openCommunityModeration(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const CommunityModerationScreen(),
    settings: const RouteSettings(name: kCommunityModerationRoute),
  ));
}

void openCommunitySignIn(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => AuthFlowScreen(onDone: (_, _) => Navigator.of(context).maybePop()),
  ));
}

// ---- palette + type -----------------------------------------------------------

V2Palette get cmP => V2PaletteStore.instance.current;

TextStyle cmTitle(double size, {Color? color}) =>
    pvFraunces(fontSize: size, fontWeight: FontWeight.w500, height: 1.15, color: color ?? cmP.ink1);

TextStyle cmText(double size, {FontWeight weight = FontWeight.w500, Color? color, double height = 1.4}) =>
    pvManrope(fontSize: size, fontWeight: weight, color: color ?? cmP.ink1, height: height);

/// "now", "5m", "3h", "2d", then a date.
String communityAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'now';
  if (d.inMinutes < 60) return '${d.inMinutes}m';
  if (d.inHours < 24) return '${d.inHours}h';
  if (d.inDays < 7) return '${d.inDays}d';
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${t.day} ${m[t.month - 1]}';
}

/// Room member counts show only once a room is busy enough that the number
/// reassures rather than discourages (user's call, 2026-10-28: 50).
String? communityMembersLine(int n) => n >= 50 ? '$n members' : null;

// ---- the outcome, in words ----------------------------------------------------

/// Turns what the server said about something she wrote into one toast.
/// [what] is 'post' or 'reply'; [room] names where a post went.
void communityOutcomeToast(
  BuildContext context,
  PvCommunityOutcome o, {
  String what = 'post',
  String? room,
  bool photos = false,
  bool crisis = false,
}) {
  final store = PvCommunityStore.instance;
  switch (o) {
    case PvCommunityOutcome.live:
      final where = room == null || room.isEmpty ? '' : ' in $room';
      pvToast(
        context,
        crisis
            ? 'Posted. You are not alone. Helplines are on your post, and a moderator will see it soon.'
            : photos
                ? 'Posted$where. Your photos show after a quick review.'
                : (what == 'post' ? 'Posted$where' : 'Reply posted'),
        kind: PvToastKind.done,
      );
    case PvCommunityOutcome.held:
      pvToast(
        context,
        'Your $what is waiting for a quick review. Only you can see it for now.',
        kind: PvToastKind.info,
        hold: const Duration(seconds: 5),
      );
    case PvCommunityOutcome.queued:
      pvToast(
        context,
        'No connection. Your $what is saved on your phone and will send when you are back online.',
        kind: PvToastKind.gentle,
        hold: const Duration(seconds: 5),
      );
    case PvCommunityOutcome.muted:
      final until = store.me.mutedUntil;
      pvToast(
        context,
        until == null
            ? 'A moderator has paused posting on this account for a while.'
            : 'A moderator has paused posting on this account until ${_clock(until)}.',
        kind: PvToastKind.gentle,
      );
    case PvCommunityOutcome.banned:
      pvToast(context, 'This account can no longer post in the community. You can still read.',
          kind: PvToastKind.gentle);
    case PvCommunityOutcome.rate:
      pvToast(context, 'That is a lot in a short time. Take a breath and try again in a little while.',
          kind: PvToastKind.gentle);
    case PvCommunityOutcome.noName:
      pvToast(context, 'Add your name in You to post under it, or post with your community name.',
          kind: PvToastKind.gentle, hold: const Duration(seconds: 5));
    case PvCommunityOutcome.gone:
      pvToast(context, 'That is no longer open. Your $what was not posted.', kind: PvToastKind.gentle);
    case PvCommunityOutcome.signedOut:
      pvToast(context, 'Sign in to $what in the community.', kind: PvToastKind.info,
          action: 'Sign in', onAction: () => openCommunitySignIn(context));
    case PvCommunityOutcome.noAccess:
      pvToast(context, 'This discussion is for people with a seat in this course. Your $what was not posted.',
          kind: PvToastKind.gentle, hold: const Duration(seconds: 5));
    case PvCommunityOutcome.notJoined:
    case PvCommunityOutcome.invalid:
      pvToast(context, 'That did not go through. Try again.', kind: PvToastKind.gentle);
  }
}

String _clock(DateTime t) {
  final now = DateTime.now();
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final mm = t.minute.toString().padLeft(2, '0');
  final ap = t.hour < 12 ? 'am' : 'pm';
  final sameDay = t.year == now.year && t.month == now.month && t.day == now.day;
  return sameDay ? '$h:$mm $ap' : '${t.day}/${t.month}, $h:$mm $ap';
}

/// Before anything she writes: signed in, not banned, and the first-time
/// sheet (house rules + community name) done. True when she may go on.
Future<bool> communityEnsureMember(BuildContext context) async {
  final s = PvCommunityStore.instance;
  if (!s.signedIn) {
    pvToast(context, 'Sign in to post, reply or join a room.',
        kind: PvToastKind.info, action: 'Sign in', onAction: () => openCommunitySignIn(context));
    return false;
  }
  if (s.me.banned) {
    communityOutcomeToast(context, PvCommunityOutcome.banned);
    return false;
  }
  if (s.me.joined) return true;
  // (0137) A verified expert writes under her own name and needs no
  // community name: the doctor app has no first-time sheet, and the server
  // lets an expert's NAMED post through without one.
  if (s.me.isExpert) return true;
  // A new phone, or the first launch after signing in: she may have joined on
  // another device. Ask the server before showing the first-time sheet.
  await s.refreshMe();
  if (s.me.joined) return true;
  if (!context.mounted) return false;
  final ok = await showCommunityWelcome(context);
  return ok == true;
}

// ---- small parts --------------------------------------------------------------

/// The ink pill: the app's one filled button.
class CommunityInkButton extends StatelessWidget {
  const CommunityInkButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.busy = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool busy;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final on = onTap != null && !busy;
    return AnimatedOpacity(
      duration: PvMotion.swap,
      opacity: on || busy ? 1 : 0.35,
      child: Material(
        color: kPvInk,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: on
              ? () {
                  HapticFeedback.selectionClick();
                  onTap!();
                }
              : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 20, vertical: compact ? 9 : 13),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (busy)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              else if (icon != null)
                Icon(icon, size: 18, color: Colors.white),
              if (busy || icon != null) const SizedBox(width: 8),
              Text(label, style: cmText(compact ? 13.5 : 15, weight: FontWeight.w700, color: Colors.white)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// A selectable pill (feed tabs, sort, comment filters).
class CommunityPill extends StatelessWidget {
  const CommunityPill({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: selected,
        button: true,
        child: PvPress(child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: PvMotion.swap,
            curve: PvMotion.arrive,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? kPvInk : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? kPvInk : cmP.line),
            ),
            child: Text(label,
                style: cmText(13, weight: FontWeight.w700, color: selected ? Colors.white : cmP.ink1)),
          ),
        )),
      );
}

/// A centred, calm empty state with one clear next step. Never a blank page.
class CommunityEmpty extends StatelessWidget {
  const CommunityEmpty({
    super.key,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
    this.icon = Icons.forum_outlined,
  });

  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(32, 36, 32, 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 30, color: cmP.ink3),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: cmText(16.5, weight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(body, textAlign: TextAlign.center, style: cmText(14, color: cmP.ink2)),
          if (action != null && onAction != null) ...[
            const SizedBox(height: 16),
            CommunityInkButton(label: action!, onTap: onAction, compact: true),
          ],
        ]),
      );
}

/// Fades and lifts a list item in, a little later for each index, the first
/// time it builds. Capped so a long list never waits on its own entrance.
class CommunityEnter extends StatelessWidget {
  const CommunityEnter({super.key, required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 260 + 45 * index.clamp(0, 6)),
        curve: PvMotion.arrive,
        builder: (_, v, c) => Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, 10 * (1 - v)), child: c),
        ),
        child: child,
      );
}

/// A small grey chip beside a name: "Moderator", "Lead host".
class CommunityNameChip extends StatelessWidget {
  const CommunityNameChip(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: const Color(0xFFF3F3F4), borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: cmText(11, weight: FontWeight.w800, color: cmP.ink2)),
      );
}

/// The words under every expert's reply (B4, the user's wording 2026-10-28).
const String kCommunityExpertFooter =
    'General guidance from a verified expert, not a diagnosis. For your own care, ask your doctor.';

/// Author line: face, name, and (optionally) room and time.
///
/// (0137) Three new faces: a verified expert (the seal, "Dr Name ·
/// category", and their role in a course); a moderator under her first name
/// (a "Moderator" chip, D2, replacing phase 1's "label · ParentVeda team");
/// and the house itself ("ParentVeda team", only ever from the team voice).
class CommunityAuthorRow extends StatelessWidget {
  const CommunityAuthorRow({
    super.key,
    required this.author,
    required this.when,
    this.room,
    this.onAuthor,
    this.trailing,
    this.size = 32,
    this.hostRole,
    this.edited = false,
  });

  final PvCommunityAuthor author;
  final DateTime when;
  final String? room;
  final VoidCallback? onAuthor;
  final Widget? trailing;
  final double size;
  final String? hostRole;
  final bool edited;

  @override
  Widget build(BuildContext context) {
    // Kept for revert (phase 1): author.team ? '${author.label} · ParentVeda team' : author.label
    final expert = author.expert;
    final name = expert?.name ?? author.label;
    final chip = author.team
        ? null
        : hostRole != null && hostRole!.isNotEmpty
            ? pvHostRoleLabel(hostRole)
            : (author.moderator ? 'Moderator' : null);
    return Row(children: [
      PvPress(child: GestureDetector(onTap: onAuthor, child: CommunityFaceMark(author: author, size: size))),
      const SizedBox(width: 10),
      Expanded(
        child: PvPress(child: GestureDetector(
          onTap: onAuthor,
          behavior: HitTestBehavior.opaque,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: name, style: cmText(13.5, weight: FontWeight.w800)),
                    if (expert != null && expert.category.isNotEmpty)
                      TextSpan(text: ' · ${expert.category}', style: cmText(13, weight: FontWeight.w600, color: cmP.ink2)),
                  ]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (chip != null) ...[
                const SizedBox(width: 6),
                CommunityNameChip(chip),
              ],
              if (author.isMine) ...[
                const SizedBox(width: 6),
                Text('You', style: cmText(11.5, weight: FontWeight.w700, color: cmP.ink3)),
              ],
            ]),
            Text(
              [if (room != null && room!.isNotEmpty) room!, communityAgo(when), if (edited) 'Edited'].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: cmText(12.5, color: cmP.ink3),
            ),
          ]),
        )),
      ),
      ?trailing,
    ]);
  }
}

/// "Waiting for a quick review", on her own held post or reply.
class CommunityStatusLine extends StatelessWidget {
  const CommunityStatusLine({super.key, required this.text, this.icon = Icons.schedule_rounded});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 15, color: cmP.ink3),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: cmText(12.5, weight: FontWeight.w600, color: cmP.ink2))),
      ]);
}

/// The like heart, with a small pop when she taps it.
class CommunityLikeButton extends StatefulWidget {
  const CommunityLikeButton({super.key, required this.liked, required this.count, required this.onTap});
  final bool liked;
  final int count;
  final VoidCallback onTap;

  @override
  State<CommunityLikeButton> createState() => _CommunityLikeButtonState();
}

class _CommunityLikeButtonState extends State<CommunityLikeButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const rose = Color(0xFFC6295A);
    return Semantics(
      button: true,
      label: widget.liked ? 'Unlike, ${widget.count} likes' : 'Like, ${widget.count} likes',
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          HapticFeedback.lightImpact();
          if (!widget.liked) _c.forward(from: 0);
          widget.onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            AnimatedBuilder(
              animation: _c,
              builder: (_, c) => Transform.scale(
                scale: 1 + 0.35 * Curves.easeOut.transform(_c.value < .5 ? _c.value * 2 : (1 - _c.value) * 2),
                child: c,
              ),
              child: Icon(
                widget.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 19,
                color: widget.liked ? rose : cmP.ink2,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedSwitcher(
              duration: PvMotion.swap,
              transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
              child: Text('${widget.count}',
                  key: ValueKey(widget.count),
                  style: cmText(13, weight: FontWeight.w700, color: widget.liked ? rose : cmP.ink2)),
            ),
          ]),
        ),
      ),
    );
  }
}

class CommunityIconAction extends StatelessWidget {
  const CommunityIconAction({super.key, required this.icon, required this.onTap, this.label, this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String? label;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: tooltip ?? label,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 19, color: cmP.ink2),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(label!, style: cmText(13, weight: FontWeight.w700, color: cmP.ink2)),
              ],
            ]),
          ),
        ),
      );
}

// ---- poll ---------------------------------------------------------------------

class CommunityPollView extends StatelessWidget {
  const CommunityPollView({super.key, required this.post});
  final PvCommunityPost post;

  @override
  Widget build(BuildContext context) {
    final poll = post.poll!;
    final total = poll.total;
    final results = poll.showResults;
    String left() {
      if (poll.closesAt == null) return '';
      if (poll.closed) return 'Poll closed';
      final d = poll.closesAt!.difference(DateTime.now());
      if (d.inDays >= 1) return '${d.inDays} ${d.inDays == 1 ? 'day' : 'days'} left';
      if (d.inHours >= 1) return '${d.inHours}h left';
      return 'Closing soon';
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (var i = 0; i < poll.options.length; i++) ...[
        _PollOption(
          label: poll.options[i],
          share: total == 0 ? 0 : poll.counts[i] / total,
          showResult: results,
          mine: poll.mine == i,
          onTap: results || post.sending
              ? null
              : () async {
                  if (!await communityEnsureMember(context)) return;
                  final o = await PvCommunityStore.instance.vote(post.id, i);
                  if (!context.mounted) return;
                  if (o == PvCommunityOutcome.live) {
                    pvToast(context, 'Vote counted', kind: PvToastKind.done);
                  } else if (o == PvCommunityOutcome.gone) {
                    pvToast(context, 'This poll has closed.', kind: PvToastKind.info);
                  } else {
                    pvToast(context, 'Your vote did not go through. Try again.', kind: PvToastKind.gentle);
                  }
                },
        ),
        const SizedBox(height: 6),
      ],
      Text(
        [
          '$total ${total == 1 ? 'vote' : 'votes'}',
          if (left().isNotEmpty) left(),
          if (poll.mine != null) 'You voted',
        ].join(' · '),
        style: cmText(12.5, color: cmP.ink3),
      ),
    ]);
  }
}

class _PollOption extends StatelessWidget {
  const _PollOption({
    required this.label,
    required this.share,
    required this.showResult,
    required this.mine,
    required this.onTap,
  });
  final String label;
  final double share;
  final bool showResult;
  final bool mine;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: onTap != null,
        label: showResult ? '$label, ${(share * 100).round()} percent' : 'Vote for $label',
        child: PvPress(child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: mine ? kPvInk : cmP.line, width: mine ? 1.5 : 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              // The bar grows from zero the moment the results appear.
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: showResult ? share : 0),
                duration: const Duration(milliseconds: 520),
                curve: PvMotion.arrive,
                builder: (_, v, _) => FractionallySizedBox(
                  widthFactor: v.clamp(0, 1),
                  heightFactor: 1,
                  child: Container(color: const Color(0xFFE9E9EB)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(children: [
                  Expanded(
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: cmText(14, weight: FontWeight.w600)),
                  ),
                  if (mine) ...[const Icon(Icons.check_rounded, size: 16, color: kPvInk), const SizedBox(width: 6)],
                  if (showResult) Text('${(share * 100).round()}%', style: cmText(13.5, weight: FontWeight.w700)),
                ]),
              ),
            ]),
          ),
        )),
      );
}

// ---- photos -------------------------------------------------------------------

class CommunityPhotos extends StatelessWidget {
  const CommunityPhotos({super.key, required this.post, this.height = 200});
  final PvCommunityPost post;
  final double height;

  @override
  Widget build(BuildContext context) {
    final store = PvCommunityStore.instance;
    final shown = [
      for (final m in post.media)
        if (m.localPath != null || !m.pending || post.author.isMine) m,
    ];
    if (shown.isEmpty) return const SizedBox.shrink();
    final pendingMine = post.author.isMine && post.media.any((m) => m.pending);
    Widget tile(PvCommunityMedia m) {
      final url = store.urlFor(m.path);
      Widget img;
      if (m.localPath != null && File(m.localPath!).existsSync()) {
        img = Image.file(File(m.localPath!), fit: BoxFit.cover, cacheWidth: 900);
      } else if (url != null) {
        img = Image.network(url, fit: BoxFit.cover, cacheWidth: 900,
            errorBuilder: (_, _, _) => const _PhotoPlaceholder());
      } else {
        img = const _PhotoPlaceholder();
      }
      return PvPress(child: GestureDetector(
        onTap: () => _openPhoto(context, m, url),
        child: Container(color: const Color(0xFFF3F3F4), child: img),
      ));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: height,
          child: shown.length == 1
              ? SizedBox.expand(child: tile(shown.first))
              : Row(children: [
                  for (var i = 0; i < shown.length && i < 4; i++) ...[
                    if (i > 0) const SizedBox(width: 3),
                    Expanded(child: SizedBox.expand(child: tile(shown[i]))),
                  ],
                ]),
        ),
      ),
      if (pendingMine) ...[
        const SizedBox(height: 8),
        const CommunityStatusLine(text: 'Your photos show to others after a quick review'),
      ],
    ]);
  }

  void _openPhoto(BuildContext context, PvCommunityMedia m, String? url) {
    final ImageProvider? image = m.localPath != null
        ? FileImage(File(m.localPath!))
        : (url != null ? NetworkImage(url) : null);
    if (image == null) return;
    Navigator.of(context).push(PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      settings: const RouteSettings(name: 'community/photo'),
      pageBuilder: (_, a, _) => FadeTransition(
        opacity: a,
        child: PvPress(child: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(children: [
                Center(child: InteractiveViewer(maxScale: 4, child: Image(image: image))),
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ]),
            ),
          ),
        )),
      ),
    ));
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();
  @override
  Widget build(BuildContext context) =>
      Center(child: Icon(Icons.image_outlined, color: cmP.ink3, size: 26));
}

// ---- the post card --------------------------------------------------------------

class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({super.key, required this.post, this.showRoom = true, this.showJoin = true});

  final PvCommunityPost post;
  final bool showRoom;
  final bool showJoin;

  @override
  Widget build(BuildContext context) {
    final store = PvCommunityStore.instance;
    final room = store.room(post.roomId);
    final joinable = showJoin && showRoom && room != null && !room.joined && !post.author.isMine;
    return InkWell(
      onTap: () => openCommunityPost(context, post.id),
      child: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: cmP.line))),
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (post.pinned) ...[
            Row(children: [
              Icon(Icons.push_pin_outlined, size: 14, color: cmP.ink3),
              const SizedBox(width: 5),
              Text('Pinned', style: cmText(12, weight: FontWeight.w700, color: cmP.ink3)),
            ]),
            const SizedBox(height: 6),
          ],
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CommunityAuthorRow(
              author: post.author,
              when: post.createdAt,
              room: showRoom ? post.roomTitle : null,
              hostRole: post.hostRole,
              edited: post.editedAt != null,
              // A team post has no face to open (0137).
              onAuthor: post.sending || post.author.team
                  ? null
                  : () => openCommunityProfile(context, fromId: post.id, anon: post.author.anon),
              trailing: joinable
                  ? TextButton(
                      onPressed: () => communityJoinRoom(context, room.id),
                      style: TextButton.styleFrom(
                        foregroundColor: kPvInk,
                        visualDensity: VisualDensity.compact,
                        textStyle: cmText(13, weight: FontWeight.w800),
                      ),
                      child: const Text('Join'),
                    )
                  : null,
            ),
          ),
          if (post.sending || post.waitingForReview) ...[
            const SizedBox(height: 8),
            CommunityStatusLine(
              icon: post.sending ? Icons.cloud_upload_outlined : Icons.schedule_rounded,
              text: post.sending
                  ? 'Saved on your phone. Sending when you are online'
                  : 'Waiting for a quick review. Only you can see it',
            ),
          ],
          if (post.about != null) ...[
            const SizedBox(height: 8),
            CommunityAboutChip(label: communityAboutLabel(room?.programmeId, post.about!), about: post.about!),
          ],
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(post.title, style: cmText(17, weight: FontWeight.w800, height: 1.3)),
          ),
          if (post.body.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(post.body,
                  maxLines: 2, overflow: TextOverflow.ellipsis, style: cmText(14, color: cmP.ink2)),
            ),
          ],
          if (post.poll != null) ...[
            const SizedBox(height: 10),
            Padding(padding: const EdgeInsets.only(right: 8), child: CommunityPollView(post: post)),
          ],
          if (post.media.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(padding: const EdgeInsets.only(right: 8), child: CommunityPhotos(post: post, height: 170)),
          ],
          const SizedBox(height: 4),
          CommunityPostActions(post: post),
        ]),
      ),
    );
  }
}

/// Like, reply count, save, and the ⋯ menu. Shared by the card and the post.
class CommunityPostActions extends StatelessWidget {
  const CommunityPostActions({super.key, required this.post, this.onReply});
  final PvCommunityPost post;
  final VoidCallback? onReply;

  @override
  Widget build(BuildContext context) {
    final store = PvCommunityStore.instance;
    final saved = store.isSaved(post.id);
    return Transform.translate(
      offset: const Offset(-8, 0),
      child: Row(children: [
        CommunityLikeButton(
          liked: post.liked,
          count: post.likeCount,
          onTap: () async {
            if (post.sending) {
              pvToast(context, 'You can like it once it has posted.', kind: PvToastKind.info);
              return;
            }
            if (!store.signedIn) {
              communityOutcomeToast(context, PvCommunityOutcome.signedOut, what: 'like posts');
              return;
            }
            final ok = await store.toggleLike(post.id);
            if (!ok && context.mounted) {
              pvToast(context, 'Your like did not go through. Try again.', kind: PvToastKind.gentle);
            }
          },
        ),
        CommunityIconAction(
          icon: Icons.chat_bubble_outline_rounded,
          label: '${post.commentCount}',
          tooltip: '${post.commentCount} replies',
          onTap: onReply ?? () => openCommunityPost(context, post.id),
        ),
        const Spacer(),
        CommunityIconAction(
          icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          tooltip: saved ? 'Remove from saved' : 'Save',
          onTap: () async {
            await store.toggleSave(post);
            if (!context.mounted) return;
            final now = store.isSaved(post.id);
            pvToast(
              context,
              now ? 'Saved. Find it under Saved in the community.' : 'Removed from saved',
              kind: now ? PvToastKind.saved : PvToastKind.info,
            );
          },
        ),
        CommunityIconAction(
          icon: Icons.more_horiz_rounded,
          tooltip: 'More',
          onTap: () => showCommunityPostMenu(context, post),
        ),
      ]),
    );
  }
}

/// Join (or leave) a room, with the first-time sheet if needed and a toast.
Future<void> communityJoinRoom(BuildContext context, String roomId, {bool leave = false}) async {
  if (!await communityEnsureMember(context)) return;
  final store = PvCommunityStore.instance;
  final r = store.room(roomId);
  final ok = await store.setRoom(roomId, join: !leave);
  if (!context.mounted) return;
  if (!ok) {
    pvToast(context, 'That did not go through. Check your connection and try again.', kind: PvToastKind.gentle);
  } else {
    pvToast(
      context,
      leave ? 'You left ${r?.title ?? 'the room'}' : 'Joined ${r?.title ?? 'the room'}. Its posts now come first for you.',
      kind: leave ? PvToastKind.info : PvToastKind.done,
    );
  }
}

// ---- sheets -------------------------------------------------------------------

Future<T?> showCommunitySheet<T>(BuildContext context, WidgetBuilder builder) => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (c) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              decoration: BoxDecoration(color: const Color(0xFFE9E9EB), borderRadius: BorderRadius.circular(4)),
            ),
            Flexible(child: builder(c)),
          ]),
        ),
      ),
    );

class CommunitySheetRow extends StatelessWidget {
  const CommunitySheetRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.note,
    this.danger = false,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final String? note;
  final bool danger;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    const rose = Color(0xFFC6295A);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cmP.line))),
        child: Row(children: [
          Icon(icon, size: 22, color: danger ? rose : cmP.ink1),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: cmText(15, weight: FontWeight.w700, color: danger ? rose : cmP.ink1)),
              if (note != null) Text(note!, style: cmText(12.5, color: cmP.ink3)),
            ]),
          ),
          ?trailing,
        ]),
      ),
    );
  }
}

/// "About: Lesson 2" on a course post (0137).
class CommunityAboutChip extends StatelessWidget {
  const CommunityAboutChip({super.key, required this.label, required this.about});
  final String label;
  final PvPostAbout about;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(color: const Color(0xFFF3F3F4), borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(about.isLesson ? Icons.play_arrow_rounded : Icons.videocam_outlined, size: 14, color: cmP.ink2),
          const SizedBox(width: 4),
          Text('About: $label', style: cmText(12, weight: FontWeight.w700, color: cmP.ink2)),
        ]),
      );
}

/// May she pin this post? Moderators anywhere; a course's hosts in its room.
bool communityCanPin(PvCommunityPost post) {
  final store = PvCommunityStore.instance;
  return store.me.isMod || (store.offeringForRoom(post.roomId)?.isHost ?? false);
}

/// The ⋯ menu on a post.
Future<void> showCommunityPostMenu(BuildContext context, PvCommunityPost post) async {
  final store = PvCommunityStore.instance;
  final saved = store.isSaved(post.id);
  final canPin = communityCanPin(post) && !post.sending;
  final action = await showCommunitySheet<String>(
    context,
    (c) => ListView(shrinkWrap: true, children: [
      CommunitySheetRow(
        icon: saved ? Icons.bookmark_remove_outlined : Icons.bookmark_border_rounded,
        label: saved ? 'Remove from saved' : 'Save',
        onTap: () => Navigator.pop(c, 'save'),
      ),
      if (canPin)
        CommunitySheetRow(
          icon: Icons.push_pin_outlined,
          label: post.pinned ? 'Unpin' : 'Pin to the top',
          note: post.pinned ? 'It goes back into the feed' : 'For 7 days, at the top of this room',
          onTap: () => Navigator.pop(c, 'pin'),
        ),
      // A team post can be reported, never blocked (0137): it is the house.
      if (!post.author.isMine && post.author.team)
        CommunitySheetRow(
          icon: Icons.flag_outlined,
          label: 'Report',
          note: 'Confidential.',
          danger: true,
          onTap: () => Navigator.pop(c, 'report'),
        )
      else if (!post.author.isMine) ...[
        CommunitySheetRow(
          icon: Icons.visibility_off_outlined,
          label: 'Hide this post',
          note: 'You will not see it again',
          onTap: () => Navigator.pop(c, 'hide'),
        ),
        CommunitySheetRow(
          icon: Icons.flag_outlined,
          label: 'Report',
          note: 'Confidential. They are not told who reported.',
          danger: true,
          onTap: () => Navigator.pop(c, 'report'),
        ),
        CommunitySheetRow(
          icon: Icons.block_rounded,
          label: 'Block ${post.author.label}',
          danger: true,
          onTap: () => Navigator.pop(c, 'block'),
        ),
      ] else
        CommunitySheetRow(
          icon: Icons.delete_outline_rounded,
          label: 'Delete your post',
          danger: true,
          onTap: () => Navigator.pop(c, 'delete'),
        ),
    ]),
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case 'pin':
      final err = await store.pin(post.id, post.pinned ? 0 : 7);
      if (context.mounted) {
        pvToast(
          context,
          err ?? (post.pinned ? 'Unpinned' : 'Pinned to the top of this room for 7 days'),
          kind: err == null ? PvToastKind.done : PvToastKind.gentle,
        );
      }
    case 'save':
      await store.toggleSave(post);
      if (context.mounted) {
        final now = store.isSaved(post.id);
        pvToast(context, now ? 'Saved. Find it under Saved in the community.' : 'Removed from saved',
            kind: now ? PvToastKind.saved : PvToastKind.info);
      }
    case 'hide':
      await store.hide(post.id);
      if (context.mounted) {
        pvToast(context, 'Post hidden. You will not see it again.', kind: PvToastKind.done);
        _popIfOn(context, '$kCommunityPostPrefix${post.id}');
      }
    case 'report':
      final sent = await showCommunityReport(context, kind: 'post', id: post.id);
      if (sent && context.mounted) _popIfOn(context, '$kCommunityPostPrefix${post.id}');
    case 'block':
      final done = await confirmCommunityBlock(context, kind: 'post', id: post.id, label: post.author.label);
      if (done && context.mounted) _popIfOn(context, '$kCommunityPostPrefix${post.id}');
    case 'delete':
      final yes = await confirmCommunity(
        context,
        title: 'Delete your post?',
        body: 'It is removed for everyone, with its replies. This cannot be undone.',
        confirm: 'Delete',
      );
      if (!yes || !context.mounted) return;
      final ok = await store.deleteMine(kind: 'post', id: post.id);
      if (context.mounted) {
        pvToast(context, ok ? 'Your post is deleted' : 'Removed here. It will be deleted once you are online.',
            kind: ok ? PvToastKind.done : PvToastKind.gentle);
        _popIfOn(context, '$kCommunityPostPrefix${post.id}');
      }
  }
}

void _popIfOn(BuildContext context, String routeName) {
  final route = ModalRoute.of(context);
  if (route?.settings.name == routeName) Navigator.of(context).maybePop();
}

/// A plain confirm sheet. True on confirm.
Future<bool> confirmCommunity(
  BuildContext context, {
  required String title,
  required String body,
  required String confirm,
}) async {
  final yes = await showCommunitySheet<bool>(
    context,
    (c) => Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title, style: cmTitle(24)),
        const SizedBox(height: 8),
        Text(body, style: cmText(14.5, color: cmP.ink2)),
        const SizedBox(height: 20),
        CommunityInkButton(label: confirm, onTap: () => Navigator.pop(c, true)),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          style: TextButton.styleFrom(foregroundColor: cmP.ink1, padding: const EdgeInsets.all(14)),
          child: Text('Cancel', style: cmText(15, weight: FontWeight.w700)),
        ),
      ]),
    ),
  );
  return yes == true;
}

Future<bool> confirmCommunityBlock(
  BuildContext context, {
  required String kind,
  required String id,
  required String label,
}) async {
  final yes = await confirmCommunity(
    context,
    title: 'Block $label?',
    body: 'You will not see their posts or replies, and they will not see yours. '
        'They are not told. You can unblock them from your community profile.',
    confirm: 'Block',
  );
  if (!yes || !context.mounted) return false;
  final ok = await PvCommunityStore.instance.block(kind: kind, id: id);
  if (context.mounted) {
    pvToast(context, ok ? '$label is blocked' : 'That did not go through. Try again.',
        kind: ok ? PvToastKind.done : PvToastKind.gentle);
  }
  return ok;
}

// ---- report ---------------------------------------------------------------------

const List<(String, String, String?)> kCommunityReportReasons = [
  ('harassment', 'Harassment or bullying', null),
  ('explicit', 'Sexual or explicit content', null),
  ('misinformation', 'Medical information that could cause harm', 'For example, telling someone to stop a medicine'),
  ('spam', 'Spam or selling', null),
  ('at_risk', 'Someone may be at risk', 'They may hurt themselves, or be in danger'),
  ('other', 'Something else', null),
];

/// The grievance officer, named by the user 2026-10-28. India's IT Rules 2021
/// (Rule 3(2)) ask an app that hosts user posts to publish the officer's name
/// and contact where members can see them, so it sits under the house rules
/// and on the report thank-you.
const String kCommunityGrievanceOfficer = 'Deepti Sekhri';
const String kCommunityGrievanceEmail = 'parentvedateam@gmail.com';

/// "Grievance officer: name, email". A tap opens her mail app; if none
/// opens, the address is copied and a toast says so (no silent tap).
class CommunityGrievanceLine extends StatelessWidget {
  const CommunityGrievanceLine({super.key, this.center = false});
  final bool center;

  @override
  Widget build(BuildContext context) => PvPress(
        child: GestureDetector(
          key: const ValueKey('community_grievance'),
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final ok = await launchUrl(Uri(
              scheme: 'mailto',
              path: kCommunityGrievanceEmail,
              query: 'subject=Community%20grievance',
            ));
            if (!ok && context.mounted) {
              Clipboard.setData(const ClipboardData(text: kCommunityGrievanceEmail));
              pvToast(context, 'Could not open your mail app. $kCommunityGrievanceEmail is copied.',
                  kind: PvToastKind.info);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Grievance officer: $kCommunityGrievanceOfficer, '),
                TextSpan(
                  text: kCommunityGrievanceEmail,
                  style: const TextStyle(decoration: TextDecoration.underline),
                ),
              ]),
              textAlign: center ? TextAlign.center : TextAlign.start,
              style: cmText(12, color: cmP.ink3),
            ),
          ),
        ),
      );
}

/// Reason → optional details → "confidential" thank-you. True when sent.
Future<bool> showCommunityReport(
  BuildContext context, {
  required String kind,
  required String id,
  String? postId,
}) async {
  final sent = await showCommunitySheet<bool>(context, (_) => _ReportSheet(kind: kind, id: id, postId: postId));
  return sent == true;
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.kind, required this.id, this.postId});
  final String kind;
  final String id;
  final String? postId;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  int _step = 0;
  (String, String, String?)? _reason;
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _busy = true);
    await PvCommunityStore.instance.report(
      kind: widget.kind,
      id: widget.id,
      reason: _reason!.$1,
      note: _note.text.trim(),
      postId: widget.postId,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _step = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final what = widget.kind == 'post' ? 'post' : 'reply';
    final Widget body = switch (_step) {
      0 => ListView(key: const ValueKey(0), shrinkWrap: true, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 2),
            child: Text('Why are you reporting this $what?', style: cmTitle(23)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text('Your report is confidential.', style: cmText(14, color: cmP.ink2)),
          ),
          for (final r in kCommunityReportReasons)
            CommunitySheetRow(
              icon: r.$1 == 'at_risk' ? Icons.health_and_safety_outlined : Icons.flag_outlined,
              label: r.$2,
              note: r.$3,
              trailing: Icon(Icons.chevron_right_rounded, color: cmP.ink3),
              onTap: () => setState(() {
                _reason = r;
                _step = 1;
              }),
            ),
        ]),
      1 => Padding(
          key: const ValueKey(1),
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(_reason!.$2, style: cmTitle(23)),
            const SizedBox(height: 6),
            Text('Anything a moderator should know? This is optional.', style: cmText(14, color: cmP.ink2)),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              style: cmText(15),
              decoration: InputDecoration(
                hintText: 'Add details',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: cmP.line)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPvInk)),
              ),
            ),
            const SizedBox(height: 8),
            CommunityInkButton(label: 'Send report', busy: _busy, onTap: _send),
          ]),
        ),
      _ => Padding(
          key: const ValueKey(2),
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Icon(Icons.verified_user_outlined, size: 34, color: cmP.ink1),
            const SizedBox(height: 12),
            Text('Thank you for telling us', style: cmTitle(24), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'We have hidden this $what for you. A moderator will look at it within 24 hours. '
              'If three people report it, it is hidden for everyone until then.',
              textAlign: TextAlign.center,
              style: cmText(14.5, color: cmP.ink2),
            ),
            if (_reason?.$1 == 'at_risk') ...[
              const SizedBox(height: 16),
              const CommunityHelplines(compact: true),
            ],
            const SizedBox(height: 18),
            CommunityInkButton(label: 'Done', onTap: () => Navigator.pop(context, true)),
            const SizedBox(height: 6),
            const CommunityGrievanceLine(center: true),
          ]),
        ),
    };
    return AnimatedSize(
      duration: PvMotion.resize,
      curve: PvMotion.arrive,
      child: AnimatedSwitcher(
        duration: PvMotion.swap,
        transitionBuilder: (c, a) => FadeTransition(
          opacity: a,
          child: SlideTransition(
            position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(a),
            child: c,
          ),
        ),
        child: body,
      ),
    );
  }
}

// ---- helplines ------------------------------------------------------------------

/// The helpline block: shown in the composer the moment her words read like
/// she may be at risk, on her own such post, and after an "at risk" report.
/// Hairlines, not a coloured box (DESIGN-SYSTEM §4.13).
class CommunityHelplines extends StatelessWidget {
  const CommunityHelplines({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: cmP.line), bottom: BorderSide(color: cmP.line)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!compact) ...[
            Row(children: [
              Icon(Icons.info_outline_rounded, size: 18, color: cmP.ink1),
              const SizedBox(width: 8),
              Expanded(child: Text('You do not have to carry this alone', style: cmText(15, weight: FontWeight.w800))),
            ]),
            const SizedBox(height: 6),
            Text(
              'If you are thinking of hurting yourself, please talk to someone now. These lines are free and '
              'confidential. You can still post here, and a moderator will see your post first.',
              style: cmText(13.5, color: cmP.ink2),
            ),
            const SizedBox(height: 4),
          ],
          for (final h in kCommunityHelplines)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${h.name} · ${h.number}', style: cmText(14.5, weight: FontWeight.w800)),
                    Text(h.note, style: cmText(12.5, color: cmP.ink3)),
                  ]),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await launchUrl(Uri(scheme: 'tel', path: h.number));
                    if (!ok && context.mounted) {
                      Clipboard.setData(ClipboardData(text: h.number));
                      pvToast(context, 'Could not open the dialler. ${h.number} is copied.', kind: PvToastKind.info);
                    }
                  },
                  icon: const Icon(Icons.call_outlined, size: 16),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPvInk,
                    side: const BorderSide(color: kPvInk, width: 1.3),
                    shape: const StadiumBorder(),
                    textStyle: cmText(13, weight: FontWeight.w700),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ]),
            ),
        ]),
      );
}

// ---- first time: the rules, then a community name -------------------------------

const List<String> _kNameFirst = [
  'Quiet', 'Gentle', 'Golden', 'Silver', 'Morning', 'Paper', 'Cotton', 'Amber', 'Saffron',
  'Velvet', 'Misty', 'Sunlit', 'Little', 'Bright', 'Soft', 'Evening', 'Rainy', 'Winter',
];
const List<String> _kNameSecond = [
  'Monsoon', 'Lantern', 'River', 'Jasmine', 'Tamarind', 'Harbour', 'Meadow', 'Thread', 'Pebble',
  'Orchard', 'Mango', 'Lotus', 'Neem', 'Marigold', 'Kite', 'Willow', 'Sparrow', 'Fern',
];

(String, int) communitySuggestName([int? salt]) {
  final r = DateTime.now().microsecondsSinceEpoch + (salt ?? 0) * 7919;
  final a = _kNameFirst[r % _kNameFirst.length];
  final b = _kNameSecond[(r ~/ 7) % _kNameSecond.length];
  return ('$a $b', (r ~/ 13) % 48);
}

/// True when she accepted the rules and has a community name.
Future<bool?> showCommunityWelcome(BuildContext context, {bool renameOnly = false}) =>
    showCommunitySheet<bool>(context, (_) => _WelcomeSheet(renameOnly: renameOnly));

class _WelcomeSheet extends StatefulWidget {
  const _WelcomeSheet({this.renameOnly = false});
  final bool renameOnly;

  @override
  State<_WelcomeSheet> createState() => _WelcomeSheetState();
}

class _WelcomeSheetState extends State<_WelcomeSheet> {
  late int _step = widget.renameOnly ? 1 : 0;
  late (String, int) _name = communitySuggestName();
  int _salt = 0;
  bool _typing = false;
  bool _busy = false;
  String? _error;
  late final _field = TextEditingController(text: _name.$1);

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _use() async {
    final name = _typing ? _field.text.trim() : _name.$1;
    if (name.length < 3) {
      setState(() => _error = 'Use letters only, 3 to 40 of them.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await PvCommunityStore.instance.join(name, _name.$2);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _busy = false;
        _error = err;
      });
      return;
    }
    HapticFeedback.mediumImpact();
    pvToast(
      context,
      widget.renameOnly ? 'You are now $name' : 'Welcome, $name. You are in.',
      kind: PvToastKind.done,
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final rules = Padding(
      key: const ValueKey('rules'),
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('A kind place to be honest', style: cmTitle(27)),
        const SizedBox(height: 6),
        Text('Before your first post, three house rules.', style: cmText(14.5, color: cmP.ink2)),
        const SizedBox(height: 18),
        const _Rule(
          icon: Icons.favorite_border_rounded,
          title: 'Be kind, always',
          body: 'Everyone here is going through something. Disagree gently.',
        ),
        const _Rule(
          icon: Icons.health_and_safety_outlined,
          title: 'Share what helped you, not orders',
          body: 'Talk about your own experience. For anything medical, your doctor has the final word.',
        ),
        const _Rule(
          icon: Icons.lock_outline_rounded,
          title: 'What is shared here stays here',
          body: 'No screenshots of other people\'s stories, and no trying to find out who someone is.',
        ),
        const SizedBox(height: 6),
        CommunityInkButton(label: 'I accept', onTap: () => setState(() => _step = 1)),
        const SizedBox(height: 10),
        Text(
          'Posts that break these rules are removed, and repeated breaks pause posting.',
          textAlign: TextAlign.center,
          style: cmText(12, color: cmP.ink3),
        ),
        const CommunityGrievanceLine(center: true),
      ]),
    );
    final face = PvCommunityAuthor(label: _typing ? _field.text : _name.$1, anon: true, seed: _name.$2);
    final naming = Padding(
      key: const ValueKey('name'),
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(widget.renameOnly ? 'Change your community name' : 'Your community name', style: cmTitle(27)),
        const SizedBox(height: 6),
        Text(
          'Others see this when you post under your community name. It is never linked to your real name.',
          style: cmText(14.5, color: cmP.ink2),
        ),
        const SizedBox(height: 18),
        Center(
          child: AnimatedSwitcher(
            duration: PvMotion.swap,
            transitionBuilder: (c, a) => ScaleTransition(scale: Tween(begin: .85, end: 1.0).animate(a), child: c),
            child: CommunityFaceMark(key: ValueKey(_name.$2), author: face, size: 76),
          ),
        ),
        const SizedBox(height: 12),
        if (_typing)
          TextField(
            controller: _field,
            autofocus: true,
            maxLength: 40,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[A-Za-z ]'))],
            style: cmTitle(26),
            onChanged: (_) => setState(() => _error = null),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Your community name',
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: cmP.line)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kPvInk)),
            ),
          )
        else
          AnimatedSwitcher(
            duration: PvMotion.swap,
            child: Text(_name.$1, key: ValueKey(_name.$1), textAlign: TextAlign.center, style: cmTitle(28)),
          ),
        const SizedBox(height: 10),
        Wrap(alignment: WrapAlignment.center, spacing: 8, children: [
          OutlinedButton.icon(
            onPressed: () => setState(() {
              _salt++;
              _name = communitySuggestName(_salt);
              _field.text = _name.$1;
              _typing = false;
              _error = null;
            }),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Suggest another'),
            style: _outline(),
          ),
          if (!_typing)
            OutlinedButton.icon(
              onPressed: () => setState(() => _typing = true),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Type my own'),
              style: _outline(),
            ),
        ]),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, textAlign: TextAlign.center, style: cmText(13, color: const Color(0xFFC6295A))),
        ],
        const SizedBox(height: 8),
        Text(
          'You can change it once every 30 days. You can still choose your real name on any post.',
          textAlign: TextAlign.center,
          style: cmText(12.5, color: cmP.ink3),
        ),
        const SizedBox(height: 16),
        CommunityInkButton(label: 'Use this name', busy: _busy, onTap: _use),
      ]),
    );
    return SingleChildScrollView(
      child: AnimatedSize(
        duration: PvMotion.resize,
        curve: PvMotion.arrive,
        child: AnimatedSwitcher(
          duration: PvMotion.enter,
          switchInCurve: PvMotion.arrive,
          transitionBuilder: (c, a) => FadeTransition(
            opacity: a,
            child: SlideTransition(position: Tween(begin: const Offset(.08, 0), end: Offset.zero).animate(a), child: c),
          ),
          child: _step == 0 ? rules : naming,
        ),
      ),
    );
  }

  ButtonStyle _outline() => OutlinedButton.styleFrom(
        foregroundColor: kPvInk,
        side: BorderSide(color: cmP.line),
        shape: const StadiumBorder(),
        textStyle: cmText(13, weight: FontWeight.w700),
      );
}

class _Rule extends StatelessWidget {
  const _Rule({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 22, color: cmP.ink1),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: cmText(15.5, weight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(body, style: cmText(13.5, color: cmP.ink2)),
            ]),
          ),
        ]),
      );
}

/// Room picker for the composer: her stage's rooms first, then all.
Future<String?> pickCommunityRoom(BuildContext context, {String? current}) {
  final store = PvCommunityStore.instance;
  final stage = store.currentStageTag;
  final mine = [for (final r in store.rooms) if (r.stage == stage) r];
  final rest = [for (final r in store.rooms) if (r.stage != stage) r];
  Widget row(BuildContext c, PvCommunityRoom r) => InkWell(
        onTap: () => Navigator.pop(c, r.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(children: [
            CommunityRoomMark(mark: r.mark, hue: r.hue, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.title, style: cmText(15, weight: FontWeight.w700)),
                Text(r.blurb, maxLines: 1, overflow: TextOverflow.ellipsis, style: cmText(12.5, color: cmP.ink3)),
              ]),
            ),
            if (r.id == current) const Icon(Icons.check_rounded, color: kPvInk),
          ]),
        ),
      );
  Widget head(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
        child: Text(t.toUpperCase(),
            style: cmText(11, weight: FontWeight.w800, color: cmP.action).copyWith(letterSpacing: 1)),
      );
  return showCommunitySheet<String>(
    context,
    (c) => ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(c).size.height * 0.8),
      child: store.rooms.isEmpty
          ? const CommunityEmpty(
              title: 'Rooms are loading',
              body: 'Check your connection. Rooms appear here as soon as the community is reachable.',
            )
          : ListView(shrinkWrap: true, children: [
              Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 0), child: Text('Post to', style: cmTitle(24))),
              if (mine.isNotEmpty) head('For where you are now'),
              for (final r in mine) row(c, r),
              head(mine.isEmpty ? 'Rooms' : 'All rooms'),
              for (final r in rest) row(c, r),
              const SizedBox(height: 12),
            ]),
    ),
  );
}
