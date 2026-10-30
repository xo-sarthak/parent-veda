// A course's discussion, where the course lives (0137, LA-20).
//
// One discussion per offering RUN (L.2, L.3): Batch 2 has its own room, and
// Batch 1's parents are not in it. Two places show it:
//
//  · CommunityOfferingThread — the section on the course page
//    (pv_offering_screen.dart, after "More like this"). With a seat: the
//    pinned team notice first, the three newest posts, "Open the
//    discussion". Without one: a blurred preview and what she would get,
//    "Opens when you book your seat" (or "It closed with your refund"). The
//    feature is never hidden; the empty state is its advertisement.
//  · CommunityLessonThread — the Discussion tab under a lesson
//    (pv_lesson_screen.dart): only the posts about that lesson, and "Ask
//    about Lesson N", which tags her post to it (Mindvalley's Lesson |
//    Discussions).
//
// WHO MAY ENTER IS NEVER DECIDED HERE. Both widgets ask the store, which asks
// `community_offering_room` on the server: a receipt for the run, a booked
// seat (a credit seat counts, D3), a host, or a moderator. The phone's own
// record of a purchase is a claim, and a claim is never an access check.
import 'package:flutter/material.dart';

import '../../models/pv_community.dart';
import '../../services/pv_community_store.dart';
import '../learn/pv_learn_catalog.dart';
import '../products/pv_store_chrome.dart' show kPvInk;
import 'community_chrome.dart';
import 'community_marks.dart';

/// How "about" reads on a chip: "Lesson 2" from the course's own lesson
/// list, or "A live session". The server stores only the id (lessons are
/// app strings with no table behind them).
String communityAboutLabel(String? programmeId, PvPostAbout about) {
  if (about.isLesson) {
    final v = programmeId == null ? null : PvLearnCatalog.instance.byId(programmeId);
    final i = v?.lessons.indexWhere((l) => l.id == about.id) ?? -1;
    return i >= 0 ? 'Lesson ${i + 1}' : 'A lesson';
  }
  return 'A live session';
}

/// "Batch 2 discussion", or "Course discussion" before a run has a label.
String communityDiscussionTitle(PvCommunityRoom? room) {
  final b = room?.blurb.trim() ?? '';
  return b.isEmpty ? 'Course discussion' : '$b discussion';
}

/// The course page's discussion section.
class CommunityOfferingThread extends StatefulWidget {
  const CommunityOfferingThread({super.key, required this.programmeId, this.expertName});
  final String programmeId;

  /// "Ask Dr Kavya between sessions …" on the invitation.
  final String? expertName;

  @override
  State<CommunityOfferingThread> createState() => _CommunityOfferingThreadState();
}

class _CommunityOfferingThreadState extends State<CommunityOfferingThread> {
  final _store = PvCommunityStore.instance;

  @override
  void initState() {
    super.initState();
    _store.init().then((_) => _refresh());
  }

  Future<void> _refresh() async {
    final o = await _store.offeringRoom(widget.programmeId);
    if (o != null && o.access) {
      await _store.loadFeed(scope: 'room', sort: 'new', room: o.room.id);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final o = _store.offering(widget.programmeId);
          final room = o?.room;
          final posts = room == null || o?.access != true
              ? const <PvCommunityPost>[]
              : _store.feed(PvCommunityStore.feedKey(scope: 'room', sort: 'new', room: room.id));
          final pinned = posts.where((p) => p.pinned).firstOrNull;
          final latest = posts.where((p) => p != pinned).take(3).toList();
          final batch = room?.blurb.trim() ?? '';
          return Padding(
            key: const ValueKey('community_offering_thread'),
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: Text(communityDiscussionTitle(room), style: cmTitle(23))),
                Icon(Icons.lock_outline_rounded, size: 14, color: cmP.ink3),
                const SizedBox(width: 4),
                Text(batch.isEmpty ? 'Course members only' : '$batch only',
                    style: cmText(12, weight: FontWeight.w600, color: cmP.ink3)),
              ]),
              const SizedBox(height: 12),
              if (o == null || !o.access)
                _Invitation(
                  batch: batch,
                  expertName: widget.expertName,
                  refunded: o?.reason == 'refunded',
                  loading: o == null && _store.signedIn,
                )
              else ...[
                if (pinned != null) CommunityPinnedNotice(post: pinned),
                if (latest.isEmpty && pinned == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Nobody has posted yet. Ask ${widget.expertName ?? 'the expert'} a question, or say hello to your batch.',
                      style: cmText(14, color: cmP.ink2),
                    ),
                  ),
                for (var i = 0; i < latest.length; i++) _MiniPost(post: latest[i], first: i == 0),
                const SizedBox(height: 12),
                OutlinedButton(
                  key: const ValueKey('community_offering_open'),
                  onPressed: () => openCommunityRoom(context, o.room.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPvInk,
                    side: const BorderSide(color: kPvInk, width: 1.5),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: cmText(14, weight: FontWeight.w700),
                  ),
                  child: Text(latest.isEmpty && pinned == null ? 'Write the first post' : 'Open the discussion'),
                ),
              ],
            ]),
          );
        },
      );
}

class _Invitation extends StatelessWidget {
  const _Invitation({required this.batch, required this.refunded, required this.loading, this.expertName});
  final String batch;
  final String? expertName;
  final bool refunded;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    Widget bar(double w) => FractionallySizedBox(
          widthFactor: w,
          alignment: Alignment.centerLeft,
          child: Container(
            height: 14,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: const Color(0xFFE9E9EB), borderRadius: BorderRadius.circular(7)),
          ),
        );
    return Container(
      key: const ValueKey('community_offering_invitation'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: cmP.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // A preview of what is inside, blurred: she sees there IS a room.
        ExcludeSemantics(
          child: Opacity(opacity: 0.55, child: Column(children: [bar(0.8), bar(0.6), bar(0.7)])),
        ),
        const SizedBox(height: 4),
        Text(batch.isEmpty ? 'A private discussion for this course' : 'A private discussion for $batch',
            style: cmText(15, weight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(
          [
            'Ask ${expertName ?? 'the expert'} between sessions, and talk with the parents in your batch.',
            'It stays open after the course ends.',
            if (loading) '' else (refunded ? 'It closed with your refund.' : 'Opens when you book your seat.'),
          ].where((s) => s.isNotEmpty).join(' '),
          style: cmText(14, color: cmP.ink2),
        ),
      ]),
    );
  }
}

/// The pinned team notice (a session moved, a recording is up), first on the
/// course page and in the timetable's words (LA-22, B3).
class CommunityPinnedNotice extends StatelessWidget {
  const CommunityPinnedNotice({super.key, required this.post});
  final PvCommunityPost post;

  @override
  Widget build(BuildContext context) => InkWell(
        key: ValueKey('community_pinned_notice_${post.id}'),
        borderRadius: BorderRadius.circular(16),
        onTap: () => openCommunityPost(context, post.id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(color: const Color(0xFFF3EADB), borderRadius: BorderRadius.circular(16)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.push_pin_outlined, size: 18, color: cmP.ink1),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(post.title, style: cmText(14, weight: FontWeight.w800)),
                if (post.body.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(post.body, maxLines: 4, overflow: TextOverflow.ellipsis, style: cmText(12.5, color: cmP.ink2)),
                ],
                const SizedBox(height: 6),
                Text('Pinned · ${post.author.team ? 'ParentVeda team' : post.author.expert?.name ?? post.author.label}'
                    ' · ${communityAgo(post.createdAt)}',
                    style: cmText(12, weight: FontWeight.w700, color: cmP.ink2)),
              ]),
            ),
          ]),
        ),
      );
}

class _MiniPost extends StatelessWidget {
  const _MiniPost({required this.post, required this.first});
  final PvCommunityPost post;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final who = post.author.expert != null
        ? [post.author.expert!.name, if (post.hostRole != null) pvHostRoleLabel(post.hostRole)].join(' · ')
        : post.author.label;
    final replies = post.commentCount == 1 ? '1 reply' : '${post.commentCount} replies';
    return InkWell(
      onTap: () => openCommunityPost(context, post.id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(border: first ? null : Border(top: BorderSide(color: cmP.line))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CommunityFaceMark(author: post.author, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: cmText(14, weight: FontWeight.w700)),
              Text('$who · ${communityAgo(post.createdAt)} · $replies',
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: cmText(12, color: cmP.ink3)),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// The lesson player's Discussion tab: only this lesson's posts.
class CommunityLessonThread extends StatefulWidget {
  const CommunityLessonThread({
    super.key,
    required this.programmeId,
    required this.lessonId,
    required this.lessonLabel,
    this.expertName,
  });

  final String programmeId;
  final String lessonId;

  /// "Lesson 2".
  final String lessonLabel;
  final String? expertName;

  /// The posts about this lesson, from the cache (for the tab's count).
  static List<PvCommunityPost> postsFor(String programmeId, String lessonId) {
    final store = PvCommunityStore.instance;
    final o = store.offering(programmeId);
    if (o == null || !o.access) return const [];
    return store.feed(PvCommunityStore.feedKey(
      scope: 'room',
      sort: 'new',
      room: o.room.id,
      about: PvPostAbout(kind: 'lesson', id: lessonId),
    ));
  }

  @override
  State<CommunityLessonThread> createState() => _CommunityLessonThreadState();
}

class _CommunityLessonThreadState extends State<CommunityLessonThread> {
  final _store = PvCommunityStore.instance;

  PvPostAbout get _about => PvPostAbout(kind: 'lesson', id: widget.lessonId);

  @override
  void initState() {
    super.initState();
    _store.init().then((_) => _refresh());
  }

  @override
  void didUpdateWidget(CommunityLessonThread old) {
    super.didUpdateWidget(old);
    if (old.lessonId != widget.lessonId) _refresh();
  }

  Future<void> _refresh() async {
    final o = _store.offering(widget.programmeId) ?? await _store.offeringRoom(widget.programmeId);
    if (o != null && o.access) {
      await _store.loadFeed(scope: 'room', sort: 'new', room: o.room.id, about: _about);
    }
  }

  void _ask(PvOfferingRoom o) => openCommunityCompose(
        context,
        roomId: o.room.id,
        about: _about,
        aboutLabel: widget.lessonLabel,
      );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final o = _store.offering(widget.programmeId);
          final posts = CommunityLessonThread.postsFor(widget.programmeId, widget.lessonId);
          final title = communityDiscussionTitle(o?.room);
          if (o == null || !o.access) {
            return Padding(
              key: const ValueKey('community_lesson_thread_locked'),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: CommunityEmpty(
                icon: Icons.lock_outline_rounded,
                title: 'Questions about ${widget.lessonLabel} live here',
                body: o?.reason == 'refunded'
                    ? 'The discussion for this course closed with your refund.'
                    : 'Ask ${widget.expertName ?? 'the expert'} and your batch about this lesson. Opens when you book your seat.',
              ),
            );
          }
          return Column(
            key: const ValueKey('community_lesson_thread'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (posts.isEmpty)
                CommunityEmpty(
                  title: 'No one has asked about this lesson yet',
                  body: 'Ask ${widget.expertName ?? 'the expert'} or the parents in your batch. Your post is tagged to '
                      '${widget.lessonLabel} and also shows in the $title.',
                  action: 'Ask about ${widget.lessonLabel}',
                  onAction: () => _ask(o),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                  child: Text('Posts about this lesson. They also show in the $title.',
                      style: cmText(12.5, color: cmP.ink3)),
                ),
                for (final p in posts) CommunityPostCard(post: p, showRoom: false),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: CommunityInkButton(
                    label: 'Ask about ${widget.lessonLabel}',
                    icon: Icons.edit_outlined,
                    onTap: () => _ask(o),
                  ),
                ),
              ],
            ],
          );
        },
      );
}
