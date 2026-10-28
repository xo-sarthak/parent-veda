// "Parents like you": the community's card on each stage home (pregnancy,
// trying, parenting). One shared widget, so all three say the same thing.
//
// What it shows, in order of usefulness to her:
//  · how many people replied to her since she last looked (the reason to
//    come back, and the only number on the card);
//  · one real question from the rooms of her stage, so the card is never an
//    advert for an empty room;
//  · or, when the community is quiet or she is offline, an invitation. The
//    feature is never hidden; its empty state is its advertisement.
// Title "Parents like you", not "Mothers like you" (user's call, 2026-10-28):
// fathers and partners use the app too.
import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/pv_community_store.dart';
import 'community_chrome.dart';
import 'community_marks.dart';

class CommunityHomeCard extends StatefulWidget {
  const CommunityHomeCard({super.key});

  @override
  State<CommunityHomeCard> createState() => _CommunityHomeCardState();
}

class _CommunityHomeCardState extends State<CommunityHomeCard> {
  final _store = PvCommunityStore.instance;
  final _key = PvCommunityStore.feedKey();

  @override
  void initState() {
    super.initState();
    unawaited(_store.init().then((_) async {
      await _store.refreshMe();
      if (_store.feed(_key).isEmpty) await _store.loadFeed();
    }));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          final stage = _store.currentStageTag;
          final posts = _store.feed(_key);
          final top = posts.where((p) => !p.author.isMine && _store.room(p.roomId)?.stage == stage).firstOrNull ??
              posts.where((p) => !p.author.isMine).firstOrNull;
          final unread = _store.me.unread;
          return Semantics(
            button: true,
            label: 'Community. Parents like you.${unread > 0 ? ' $unread new replies.' : ''}',
            child: InkWell(
              key: const ValueKey('community_home_card'),
              borderRadius: BorderRadius.circular(20),
              onTap: () => unread > 0 ? _openWithReplies(context) : openCommunity(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cmP.line),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('COMMUNITY',
                        style: cmText(11, weight: FontWeight.w800, color: cmP.action).copyWith(letterSpacing: 1)),
                    const Spacer(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: unread > 0
                          ? Container(
                              key: ValueKey(unread),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFC6295A), borderRadius: BorderRadius.circular(999)),
                              child: Text('$unread new ${unread == 1 ? 'reply' : 'replies'}',
                                  style: cmText(11.5, weight: FontWeight.w800, color: Colors.white)),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    top == null ? 'Parents like you, talking honestly' : 'Parents like you are talking about this',
                    style: cmTitle(22),
                  ),
                  const SizedBox(height: 12),
                  if (top != null)
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: cmP.line))),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        CommunityFaceMark(author: top.author, size: 30),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(top.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: cmText(14.5, weight: FontWeight.w800, height: 1.3)),
                            const SizedBox(height: 2),
                            Text(
                              '${top.roomTitle} · ${top.commentCount} ${top.commentCount == 1 ? 'reply' : 'replies'}',
                              style: cmText(12, color: cmP.ink3),
                            ),
                          ]),
                        ),
                      ]),
                    )
                  else
                    Text(
                      'Ask the thing you cannot ask anywhere else. Post under a community name, '
                      'and hear from parents at the same point as you.',
                      style: cmText(14, color: cmP.ink2),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    'Open the community',
                    style: cmText(13.5, weight: FontWeight.w800).copyWith(
                      decoration: TextDecoration.underline,
                      decorationThickness: 1.4,
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
      );

  void _openWithReplies(BuildContext context) {
    openCommunity(context);
    openCommunityActivity(context);
  }
}
