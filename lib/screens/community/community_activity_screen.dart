// "Replies to you": route 'community/activity'. Replies to her posts and to
// her comments, newest first. Opening it clears the count on the home card
// and the bell. Likes are deliberately not listed (user's call, 2026-10-28:
// replies only keeps it calm). Push notifications come later
// (docs/COMMUNITY.md, phase 3); until then this inbox does the job.
import 'package:flutter/material.dart';

import '../../services/pv_community_store.dart';
import '../products/pv_store_chrome.dart' show kPvInk;
import 'community_alerts_screen.dart' show openCommunityAlerts;
import 'community_chrome.dart';
import 'community_marks.dart';

class CommunityActivityScreen extends StatefulWidget {
  const CommunityActivityScreen({super.key});

  @override
  State<CommunityActivityScreen> createState() => _CommunityActivityScreenState();
}

class _CommunityActivityScreenState extends State<CommunityActivityScreen> {
  final _store = PvCommunityStore.instance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _store.init();
    await _store.loadActivity();
    if (!mounted) return;
    setState(() => _loading = false);
    // Seen once it is on screen; the dots stay for this visit so she can
    // still tell which ones are new.
    _store.markSeen();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          final items = _store.activity;
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
              title: Text('Replies to you', style: cmText(17, weight: FontWeight.w800)),
              centerTitle: true,
              // (0147, C3-2) The alert switches, the same screen Settings opens.
              actions: [
                IconButton(
                  tooltip: 'Community alerts',
                  icon: const Icon(Icons.settings_outlined, color: kPvInk),
                  onPressed: () => openCommunityAlerts(context),
                ),
              ],
            ),
            body: RefreshIndicator(
              color: kPvInk,
              onRefresh: _store.loadActivity,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (!_store.signedIn)
                    CommunityEmpty(
                      icon: Icons.lock_outline_rounded,
                      title: 'Sign in to see replies',
                      body: 'Replies to your posts and comments gather here.',
                      action: 'Sign in',
                      onAction: () => openCommunitySignIn(context),
                    )
                  else if (_loading && items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator(color: kPvInk, strokeWidth: 2)),
                    )
                  else if (items.isEmpty)
                    CommunityEmpty(
                      icon: Icons.notifications_none_rounded,
                      title: 'No replies yet',
                      body: 'When someone replies to your post or your comment, it shows here.',
                      action: 'Write a post',
                      onAction: () => openCommunityCompose(context),
                    )
                  else
                    for (var i = 0; i < items.length; i++)
                      CommunityEnter(
                        key: ValueKey(items[i].commentId),
                        index: i,
                        child: InkWell(
                          onTap: () => openCommunityPost(context, items[i].postId),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cmP.line))),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              SizedBox(
                                width: 12,
                                child: items[i].unread
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                              color: Color(0xFFC6295A), shape: BoxShape.circle),
                                        ),
                                      )
                                    : null,
                              ),
                              CommunityFaceMark(author: items[i].author, size: 34),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text: items[i].author.label,
                                        style: cmText(14, weight: FontWeight.w800)),
                                    TextSpan(
                                      text: items[i].toComment ? ' replied to your comment' : ' replied to your post',
                                      style: cmText(14, color: cmP.ink2),
                                    ),
                                  ])),
                                  const SizedBox(height: 3),
                                  Text(items[i].body,
                                      maxLines: 3, overflow: TextOverflow.ellipsis, style: cmText(14)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${communityAgo(items[i].createdAt)} · ${items[i].postTitle}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: cmText(12, color: cmP.ink3),
                                  ),
                                ]),
                              ),
                            ]),
                          ),
                        ),
                      ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      );
}
