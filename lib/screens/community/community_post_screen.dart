// One post and its replies: route 'community/post/<id>'. Flo's thread shape:
// the post in full, Top / Newest / Mine over the replies, replies one level
// deep behind "View N replies", and a reply bar docked to the bottom that
// rides up with the keyboard.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/pv_community.dart';
import '../../services/community_safety.dart';
import '../../services/pv_community_store.dart';
import '../../services/saved_store.dart';
import '../../theme/pv_motion.dart';
import '../../widgets/pv_feedback.dart' show PvPress;
import '../../widgets/pv_toast.dart';
import '../products/pv_store_chrome.dart' show kPvInk;
import 'community_chrome.dart';
import 'community_marks.dart';
import 'community_offering_thread.dart' show communityAboutLabel;

class CommunityPostScreen extends StatefulWidget {
  const CommunityPostScreen({super.key, required this.postId});
  final String postId;

  @override
  State<CommunityPostScreen> createState() => _CommunityPostScreenState();
}

class _CommunityPostScreenState extends State<CommunityPostScreen> {
  final _store = PvCommunityStore.instance;
  final _reply = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  String _filter = 'top';
  bool _replyAnon = true;
  PvCommunityComment? _replyTo;
  final Set<String> _open = {};
  bool _loaded = false;
  bool _sending = false;

  // (0145, C3-1) Replies just shown from the pill: ringed for two seconds,
  // and keyed so the list can scroll to the first.
  Set<String> _ring = const {};
  final Map<String, GlobalKey> _ringKeys = {};
  Timer? _ringTimer;

  @override
  void initState() {
    super.initState();
    _replyAnon = true;
    _store.init().then((_) async {
      await _store.loadPost(widget.postId);
      await _store.loadComments(widget.postId, sort: _filter == 'new' ? 'new' : 'top');
      // (0145) Live while open: another phone's reply raises the pill.
      if (mounted) _store.watchPost(widget.postId);
      // (0137) An expert replies under her own name and badge; in a course
      // room the default is her first name (classmates), as in the composer.
      final p = _store.post(widget.postId);
      final hasName = (_store.me.firstName ?? '').isNotEmpty || _store.me.isExpert;
      if (hasName && (_store.me.isExpert || p?.roomKind == 'offering')) _replyAnon = false;
      if (mounted) setState(() => _loaded = true);
    });
    _reply.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _store.unwatchPost(widget.postId);
    _ringTimer?.cancel();
    _reply.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _reply.text.trim();
    if (text.isEmpty || _sending) return;
    if (!await communityEnsureMember(context)) return;
    setState(() => _sending = true);
    final parent = _replyTo;
    final o = await _store.comment(
      postId: widget.postId,
      parentId: parent?.parentId ?? parent?.id,
      anon: _replyAnon,
      body: text,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    final kept = o == PvCommunityOutcome.live || o == PvCommunityOutcome.held || o == PvCommunityOutcome.queued;
    if (kept) {
      _reply.clear();
      setState(() {
        if (parent != null) _open.add(parent.parentId ?? parent.id);
        _replyTo = null;
        if (parent == null) _filter = 'new';
      });
      _focus.unfocus();
      HapticFeedback.lightImpact();
      if (parent == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.animateTo(_scroll.position.maxScrollExtent,
                duration: PvMotion.enter, curve: PvMotion.arrive);
          }
        });
      }
    }
    communityOutcomeToast(context, o, what: 'reply', crisis: o == PvCommunityOutcome.live && communityLooksLikeCrisis(text));
  }

  /// The pill: show the waiting replies, scroll to the first, ring them.
  /// The list did not move before this tap; now it moves because she asked.
  void _showNewReplies() {
    final ids = _store.showNewReplies(widget.postId);
    if (ids.isEmpty) return;
    final all = _store.comments(widget.postId) ?? const <PvCommunityComment>[];
    setState(() {
      // Mine and Experts could hide them; Newest shows them first.
      if (_filter == 'mine' || _filter == 'experts') _filter = 'new';
      for (final c in all) {
        if (ids.contains(c.id) && c.parentId != null) _open.add(c.parentId!);
      }
      _ring = ids.toSet();
      _ringKeys
        ..clear()
        ..addAll({for (final id in ids) id: GlobalKey()});
    });
    HapticFeedback.selectionClick();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The ringed reply highest on the page, in the order the list draws.
      BuildContext? first;
      double firstY = double.infinity;
      for (final k in _ringKeys.values) {
        final c = k.currentContext;
        final box = c?.findRenderObject() as RenderBox?;
        if (c == null || box == null) continue;
        final y = box.localToGlobal(Offset.zero).dy;
        if (y < firstY) {
          first = c;
          firstY = y;
        }
      }
      if (first != null && first.mounted) {
        Scrollable.ensureVisible(first, alignment: 0.2, duration: PvMotion.enter, curve: PvMotion.arrive);
      }
    });
    _ringTimer?.cancel();
    _ringTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _ring = const {});
    });
  }

  void _startReply(PvCommunityComment c) {
    setState(() => _replyTo = c);
    _focus.requestFocus();
  }

  Future<void> _commentMenu(PvCommunityComment c) async {
    final a = await showCommunitySheet<String>(
      context,
      (s) => ListView(shrinkWrap: true, children: [
        CommunitySheetRow(icon: Icons.reply_rounded, label: 'Reply', onTap: () => Navigator.pop(s, 'reply')),
        CommunitySheetRow(
          icon: Icons.copy_rounded,
          label: 'Copy text',
          onTap: () => Navigator.pop(s, 'copy'),
        ),
        if (c.author.isMine)
          CommunitySheetRow(
            icon: Icons.delete_outline_rounded,
            label: 'Delete your reply',
            danger: true,
            onTap: () => Navigator.pop(s, 'delete'),
          )
        else ...[
          CommunitySheetRow(
            icon: Icons.flag_outlined,
            label: 'Report this reply',
            note: 'Confidential',
            danger: true,
            onTap: () => Navigator.pop(s, 'report'),
          ),
          CommunitySheetRow(
            icon: Icons.block_rounded,
            label: 'Block ${c.author.label}',
            danger: true,
            onTap: () => Navigator.pop(s, 'block'),
          ),
        ],
      ]),
    );
    if (!mounted || a == null) return;
    switch (a) {
      case 'reply':
        _startReply(c);
      case 'copy':
        await Clipboard.setData(ClipboardData(text: c.body));
        if (mounted) pvToast(context, 'Copied', kind: PvToastKind.done);
      case 'delete':
        final yes = await confirmCommunity(
          context,
          title: 'Delete your reply?',
          body: 'It is removed for everyone. This cannot be undone.',
          confirm: 'Delete',
        );
        if (!yes || !mounted) return;
        final ok = await _store.deleteMine(kind: 'comment', id: c.id, postId: widget.postId);
        if (mounted) {
          pvToast(context, ok ? 'Your reply is deleted' : 'Removed here. It will be deleted once you are online.',
              kind: ok ? PvToastKind.done : PvToastKind.gentle);
        }
      case 'report':
        await showCommunityReport(context, kind: 'comment', id: c.id, postId: widget.postId);
      case 'block':
        final ok = await confirmCommunityBlock(context, kind: 'comment', id: c.id, label: c.author.label);
        if (ok) await _store.loadComments(widget.postId);
    }
  }

  /// "Ask an expert to look" (0137). A crisis post is refused with the
  /// moderator line: crisis stays with moderators for now (W20).
  Future<void> _askExpert() async {
    final r = await _store.askExpert(widget.postId);
    if (!mounted) return;
    switch (r) {
      case 'ok':
        pvToast(context, 'Asked. An expert will see your question, and their reply will reach you in Replies.',
            kind: PvToastKind.done, hold: const Duration(seconds: 5));
      case 'crisis':
        pvToast(context, 'A moderator is already looking at this, and the helplines are on your post.',
            kind: PvToastKind.info, hold: const Duration(seconds: 5));
      case 'offline':
        pvToast(context, 'No connection. Nothing was sent; try again when you are online.', kind: PvToastKind.gentle);
      default:
        pvToast(context, 'That did not go through. Try again.', kind: PvToastKind.gentle);
    }
  }

  static bool _byExpert(PvCommunityComment c) => c.author.expert != null || c.endorsements.isNotEmpty;

  List<PvCommunityComment> _top(List<PvCommunityComment> all) {
    var top = [for (final c in all) if (c.parentId == null) c];
    if (_filter == 'mine') {
      final mineThreads = {for (final c in all) if (c.author.isMine) c.parentId ?? c.id};
      top = [for (final c in top) if (mineThreads.contains(c.id)) c];
    } else if (_filter == 'experts') {
      // A thread an expert answered in, or a reply an expert found helpful.
      final expertThreads = {for (final c in all) if (_byExpert(c)) c.parentId ?? c.id};
      top = [for (final c in top) if (expertThreads.contains(c.id)) c];
    } else if (_filter == 'new') {
      top.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      // An expert's endorsement lifts a reply, as the server ranks it (0137).
      int score(PvCommunityComment c) => c.likeCount + 5 * c.endorsements.length;
      top.sort((a, b) => score(b).compareTo(score(a)));
    }
    return top;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_store, SavedStore.instance]),
      builder: (context, _) {
        final post = _store.post(widget.postId);
        final all = _store.comments(widget.postId) ?? const <PvCommunityComment>[];
        if (post == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              leading: const BackButton(color: kPvInk),
            ),
            body: _loaded
                ? CommunityEmpty(
                    icon: Icons.visibility_off_outlined,
                    title: 'This post is not available',
                    body: 'It may have been removed, or hidden for you. Other conversations are waiting.',
                    action: 'Open the community',
                    onAction: () => Navigator.of(context).maybePop(),
                  )
                : const Center(child: CircularProgressIndicator(color: kPvInk, strokeWidth: 2)),
          );
        }
        final top = _top(all);
        final room = _store.room(post.roomId);
        final crisisMine = post.author.isMine && communityLooksLikeCrisis('${post.title} ${post.body}');
        final expertAnswered = post.expertAnswered || all.any((c) => c.author.expert != null);
        final canAsk = post.author.isMine && !post.author.team && !post.sending && post.status == 'live' && !expertAnswered;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_rounded, color: kPvInk),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            actions: [
              IconButton(
                tooltip: 'More',
                icon: const Icon(Icons.more_horiz_rounded, color: kPvInk),
                onPressed: () => showCommunityPostMenu(context, post),
              ),
            ],
          ),
          body: Column(children: [
            Expanded(
              child: Stack(children: [
              RefreshIndicator(
                color: kPvInk,
                onRefresh: () async {
                  await _store.loadPost(widget.postId);
                  await _store.loadComments(widget.postId);
                },
                child: ListView(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => openCommunityRoom(context, post.roomId),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: cmP.line),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              CommunityRoomMark(mark: room?.mark ?? post.roomMark, hue: room?.hue ?? post.roomHue, size: 26),
                              const SizedBox(width: 8),
                              Text(post.roomTitle, style: cmText(13, weight: FontWeight.w700)),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 14),
                        CommunityAuthorRow(
                          author: post.author,
                          when: post.createdAt,
                          size: 36,
                          hostRole: post.hostRole,
                          edited: post.editedAt != null,
                          onAuthor: post.sending || post.author.team
                              ? null
                              : () => openCommunityProfile(context, fromId: post.id, anon: post.author.anon),
                        ),
                        if (post.about != null) ...[
                          const SizedBox(height: 10),
                          CommunityAboutChip(
                            label: communityAboutLabel(room?.programmeId, post.about!),
                            about: post.about!,
                          ),
                        ],
                        if (post.sending || post.waitingForReview) ...[
                          const SizedBox(height: 10),
                          CommunityStatusLine(
                            icon: post.sending ? Icons.cloud_upload_outlined : Icons.schedule_rounded,
                            text: post.sending
                                ? 'Saved on your phone. It posts when you are back online.'
                                : 'Waiting for a quick review. Only you can see it until a moderator has looked.',
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(post.title, style: cmTitle(27)),
                        if (post.body.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          // (0137) #tags open their feed. Kept for revert:
                          // SelectableText(post.body, style: cmText(15.5, height: 1.55)),
                          CommunityBodyText(post.body, style: cmText(15.5, height: 1.55)),
                        ],
                        if (post.poll != null) ...[
                          const SizedBox(height: 14),
                          CommunityPollView(post: post),
                        ],
                        if (post.media.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          CommunityPhotos(post: post, height: 240),
                        ],
                        if (crisisMine) ...[
                          const SizedBox(height: 16),
                          const CommunityHelplines(),
                        ],
                        const SizedBox(height: 6),
                        CommunityPostActions(post: post, onReply: () => _focus.requestFocus()),
                      ]),
                    ),
                    if (canAsk && _filter != 'experts')
                      _AskRow(asked: post.expertAsked, onAsk: _askExpert),
                    Container(
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: cmP.line))),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                        child: Row(children: [
                          for (final (k, l) in const [
                            ('top', 'Top'),
                            ('new', 'Newest'),
                            ('experts', 'Experts'),
                            ('mine', 'Mine'),
                          ]) ...[
                            CommunityPill(label: l, selected: _filter == k, onTap: () => setState(() => _filter = k)),
                            const SizedBox(width: 8),
                          ],
                        ]),
                      ),
                    ),
                    if (!_loaded && all.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(child: CircularProgressIndicator(color: kPvInk, strokeWidth: 2)),
                      )
                    else if (top.isEmpty && _filter == 'experts')
                      // The Experts pill is always there; its empty state is
                      // the invitation to ask (0137).
                      CommunityEmpty(
                        key: const ValueKey('community_experts_empty'),
                        icon: Icons.verified_outlined,
                        title: 'No expert has answered yet',
                        body: canAsk
                            ? (post.expertAsked
                                ? 'An expert has been asked. Their reply will reach you in Replies.'
                                : 'Ask a verified expert to look at your question. They answer under their own name.')
                            : 'When a verified expert answers or marks a reply as helpful, it shows here.',
                        action: canAsk && !post.expertAsked ? 'Ask an expert to look' : null,
                        onAction: canAsk && !post.expertAsked ? _askExpert : null,
                      )
                    else if (top.isEmpty)
                      CommunityEmpty(
                        title: _filter == 'mine' ? 'You have not replied yet' : 'Start the conversation',
                        body: _filter == 'mine'
                            ? 'Your replies to this post will show here.'
                            : 'Share what helped you, or just say you are here too.',
                        icon: Icons.chat_bubble_outline_rounded,
                      )
                    else
                      for (var i = 0; i < top.length; i++)
                        CommunityEnter(
                          key: ValueKey(top[i].id),
                          index: i,
                          child: _Thread(
                            comment: top[i],
                            replies: [
                              for (final c in all)
                                if (c.parentId == top[i].id) c,
                            ]..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
                            open: _open.contains(top[i].id),
                            onOpen: () => setState(() => _open.add(top[i].id)),
                            onReply: _startReply,
                            onMenu: _commentMenu,
                            postId: widget.postId,
                            ring: _ring,
                            ringKeys: _ringKeys,
                          ),
                        ),
                  ],
                ),
              ),
              // (0145, C3-1) "N new replies": the list waits for her tap.
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: PvMotion.swap,
                    child: _store.newReplies(widget.postId) == 0
                        ? const SizedBox.shrink()
                        : _NewRepliesPill(
                            key: const ValueKey('community_new_replies_pill'),
                            count: _store.newReplies(widget.postId),
                            onTap: _showNewReplies,
                          ),
                  ),
                ),
              ),
              ]),
            ),
            _ReplyBar(
              controller: _reply,
              focus: _focus,
              anon: _replyAnon,
              replyTo: _replyTo,
              sending: _sending,
              locked: post.sending || post.status != 'live',
              onToggleFace: () {
                setState(() => _replyAnon = !_replyAnon);
                final face = _store.myFace(anon: _replyAnon);
                pvToast(context, 'Replying as ${face.label}', kind: PvToastKind.info);
              },
              onCancelReplyTo: () => setState(() => _replyTo = null),
              onSend: _send,
            ),
          ]),
        );
      },
    );
  }
}

class _Thread extends StatelessWidget {
  const _Thread({
    required this.comment,
    required this.replies,
    required this.open,
    required this.onOpen,
    required this.onReply,
    required this.onMenu,
    required this.postId,
    this.ring = const {},
    this.ringKeys = const {},
  });

  final PvCommunityComment comment;
  final List<PvCommunityComment> replies;
  final Set<String> ring;
  final Map<String, GlobalKey> ringKeys;
  final bool open;
  final VoidCallback onOpen;
  final ValueChanged<PvCommunityComment> onReply;
  final ValueChanged<PvCommunityComment> onMenu;
  final String postId;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Bubble(
          key: ringKeys[comment.id],
          comment: comment,
          onReply: onReply,
          onMenu: onMenu,
          postId: postId,
          ring: ring.contains(comment.id),
        ),
        if (replies.isNotEmpty)
          AnimatedSize(
            duration: PvMotion.resize,
            curve: PvMotion.arrive,
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
                    padding: const EdgeInsets.only(left: 42),
                    child: Column(children: [
                      for (final r in replies)
                        _Bubble(
                          key: ringKeys[r.id],
                          comment: r,
                          onReply: onReply,
                          onMenu: onMenu,
                          postId: postId,
                          small: true,
                          ring: ring.contains(r.id),
                        ),
                    ]),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(60, 0, 16, 8),
                    child: InkWell(
                      onTap: onOpen,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          'View ${replies.length} ${replies.length == 1 ? 'reply' : 'replies'}',
                          style: cmText(13, weight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
          ),
      ]);
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    super.key,
    required this.comment,
    required this.onReply,
    required this.onMenu,
    required this.postId,
    this.small = false,
    this.ring = false,
  });
  final PvCommunityComment comment;
  final bool ring;
  final ValueChanged<PvCommunityComment> onReply;
  final ValueChanged<PvCommunityComment> onMenu;
  final String postId;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final c = comment;
    const rose = Color(0xFFC6295A);
    final expert = c.author.expert;
    final chip = c.hostRole != null && c.hostRole!.isNotEmpty
        ? pvHostRoleLabel(c.hostRole)
        : (c.author.moderator ? 'Moderator' : null);
    final store = PvCommunityStore.instance;
    // An expert may mark another person's reply helpful (0137).
    final canEndorse = store.me.isExpert && !c.author.isMine && !c.sending;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 2),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PvPress(child: GestureDetector(
          onTap: c.sending ? null : () => openCommunityProfile(context, fromId: c.id, anon: c.author.anon),
          child: CommunityFaceMark(author: c.author, size: small ? 28 : 32),
        )),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            PvPress(child: GestureDetector(
              onLongPress: () => onMenu(c),
              child: AnimatedContainer(
                duration: PvMotion.swap,
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
                // (0145) A reply just shown from the pill is ringed for two
                // seconds, so she can tell which ones are new.
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F4),
                  border: Border.all(color: ring ? const Color(0xFF1D74E0) : const Color(0x00000000), width: 2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(text: expert?.name ?? c.author.label, style: cmText(12.5, weight: FontWeight.w800)),
                          if (expert != null && expert.category.isNotEmpty)
                            TextSpan(text: ' · ${expert.category}', style: cmText(12, weight: FontWeight.w600, color: cmP.ink2)),
                        ]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (chip != null) ...[
                      const SizedBox(width: 6),
                      CommunityNameChip(chip),
                    ],
                    if (c.isOp) ...[
                      const SizedBox(width: 6),
                      Text('Asked this', style: cmText(11.5, weight: FontWeight.w700, color: cmP.action)),
                    ],
                    const SizedBox(width: 6),
                    Text('· ${communityAgo(c.createdAt)}', style: cmText(12, color: cmP.ink3)),
                  ]),
                  const SizedBox(height: 2),
                  Text(c.body, style: cmText(14.5)),
                  // Every expert reply ends with the same line (B4).
                  if (expert != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      key: ValueKey('community_expert_footer_${c.id}'),
                      padding: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: cmP.line))),
                      child: Text(kCommunityExpertFooter, style: cmText(11.5, color: cmP.ink2)),
                    ),
                  ],
                ]),
              ),
            )),
            for (final e in c.endorsements)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Row(children: [
                  const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF1D74E0)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Found helpful by ${e.name}${e.category.isEmpty ? '' : ', ${e.category}'}',
                      style: cmText(12, weight: FontWeight.w700, color: cmP.ink2),
                    ),
                  ),
                ]),
              ),
            if (c.sending || c.status != 'live')
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: CommunityStatusLine(
                  icon: c.sending ? Icons.cloud_upload_outlined : Icons.schedule_rounded,
                  text: c.sending ? 'Sending when you are online' : 'Waiting for a quick review. Only you can see it',
                ),
              )
            else
              Row(children: [
                TextButton(
                  onPressed: () async {
                    if (!PvCommunityStore.instance.signedIn) return;
                    HapticFeedback.lightImpact();
                    final ok = await PvCommunityStore.instance.toggleCommentLike(postId, c.id);
                    if (!ok && context.mounted) {
                      pvToast(context, 'Your like did not go through. Try again.', kind: PvToastKind.gentle);
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: c.liked ? rose : cmP.ink2,
                    visualDensity: VisualDensity.compact,
                    textStyle: cmText(12.5, weight: FontWeight.w700),
                  ),
                  child: Text(c.likeCount > 0 ? '${c.liked ? 'Liked' : 'Like'} · ${c.likeCount}' : (c.liked ? 'Liked' : 'Like')),
                ),
                TextButton(
                  onPressed: () => onReply(c),
                  style: TextButton.styleFrom(
                    foregroundColor: cmP.ink2,
                    visualDensity: VisualDensity.compact,
                    textStyle: cmText(12.5, weight: FontWeight.w700),
                  ),
                  child: const Text('Reply'),
                ),
                if (canEndorse)
                  TextButton(
                    key: ValueKey('community_endorse_${c.id}'),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      final ok = await store.endorse(postId, c.id, on: !c.endorsed);
                      if (!context.mounted) return;
                      pvToast(
                        context,
                        !ok
                            ? 'That did not go through. Try again.'
                            : (c.endorsed ? 'Endorsement removed' : 'Endorsed. Parents see that you found this helpful.'),
                        kind: ok ? PvToastKind.done : PvToastKind.gentle,
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: c.endorsed ? const Color(0xFF1D74E0) : cmP.ink2,
                      visualDensity: VisualDensity.compact,
                      textStyle: cmText(12.5, weight: FontWeight.w700),
                    ),
                    child: Text(c.endorsed ? 'Endorsed' : 'Endorse'),
                  ),
                IconButton(
                  tooltip: 'More',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.more_horiz_rounded, size: 18, color: cmP.ink3),
                  onPressed: () => onMenu(c),
                ),
              ]),
          ]),
        ),
      ]),
    );
  }
}

/// "No expert has answered yet" under her own post, with Ask; or, once
/// asked, what happens next (0137, the prototype's ask row).
class _AskRow extends StatelessWidget {
  const _AskRow({required this.asked, required this.onAsk});
  final bool asked;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('community_ask_expert_row'),
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: cmP.line)),
        child: Row(children: [
          Icon(asked ? Icons.schedule_rounded : Icons.verified_outlined, size: 22, color: kPvInk),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(asked ? 'An expert has been asked' : 'No expert has answered yet',
                  style: cmText(13.5, weight: FontWeight.w800)),
              Text(
                asked
                    ? 'Their reply will reach you in Replies. This is not a consultation.'
                    : 'An expert from the ParentVeda panel can look at your question.',
                style: cmText(13, color: cmP.ink2),
              ),
            ]),
          ),
          if (!asked) ...[
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onAsk,
              style: OutlinedButton.styleFrom(
                foregroundColor: kPvInk,
                side: const BorderSide(color: kPvInk, width: 1.5),
                shape: const StadiumBorder(),
                textStyle: cmText(13, weight: FontWeight.w700),
              ),
              child: const Text('Ask'),
            ),
          ],
        ]),
      );
}

class _ReplyBar extends StatelessWidget {
  const _ReplyBar({
    required this.controller,
    required this.focus,
    required this.anon,
    required this.replyTo,
    required this.sending,
    required this.locked,
    required this.onToggleFace,
    required this.onCancelReplyTo,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final bool anon;
  final PvCommunityComment? replyTo;
  final bool sending;
  final bool locked;
  final VoidCallback onToggleFace;
  final VoidCallback onCancelReplyTo;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final store = PvCommunityStore.instance;
    final face = store.myFace(anon: anon);
    final can = controller.text.trim().isNotEmpty && !sending && !locked;
    return Material(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: cmP.line))),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedSize(
              duration: PvMotion.resize,
              child: replyTo == null
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 0, 6),
                      child: Row(children: [
                        Expanded(
                          child: Text('Replying to ${replyTo!.author.label}',
                              style: cmText(12.5, weight: FontWeight.w700, color: cmP.ink2)),
                        ),
                        InkWell(
                          onTap: onCancelReplyTo,
                          child: Icon(Icons.close_rounded, size: 18, color: cmP.ink3),
                        ),
                      ]),
                    ),
            ),
            if (locked)
              Padding(
                padding: const EdgeInsets.all(8),
                child: CommunityStatusLine(text: 'Replies open once this post is live.'),
              )
            else
              Row(children: [
                Tooltip(
                  message: 'Switch which name you reply as',
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: store.me.joined ? onToggleFace : null,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: AnimatedSwitcher(
                        duration: PvMotion.swap,
                        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                        child: CommunityFaceMark(key: ValueKey(anon), author: face, size: 32),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focus,
                    minLines: 1,
                    maxLines: 5,
                    maxLength: 2000,
                    textCapitalization: TextCapitalization.sentences,
                    style: cmText(15),
                    decoration: InputDecoration(
                      counterText: '',
                      isDense: true,
                      hintText: store.me.joined ? 'Reply as ${face.label}' : 'Write a reply',
                      filled: true,
                      fillColor: const Color(0xFFF3F3F4),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedScale(
                  duration: PvMotion.swap,
                  scale: can ? 1 : 0.9,
                  child: Material(
                    color: can ? kPvInk : const Color(0xFFE9E9EB),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: can ? onSend : null,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Icon(Icons.arrow_upward_rounded, size: 20, color: can ? Colors.white : cmP.ink3),
                      ),
                    ),
                  ),
                ),
              ]),
          ]),
        ),
      ),
    );
  }
}

/// "2 new replies" (0145, C3-1). Ink, like every action in the app.
class _NewRepliesPill extends StatelessWidget {
  const _NewRepliesPill({super.key, required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: kPvInk,
        shape: const StadiumBorder(),
        elevation: 6,
        shadowColor: Colors.black38,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 9, 16, 9),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.arrow_upward_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(count == 1 ? '1 new reply' : '$count new replies',
                  style: cmText(13.5, weight: FontWeight.w700, color: Colors.white)),
            ]),
          ),
        ),
      );
}
