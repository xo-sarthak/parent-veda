// One face of a member: route 'community/profile'. A profile is ONE name,
// never both: the community-name face lists only posts made under it, the
// first-name face only posts made under that. On her own profile she can
// switch between her two faces, rename her community name, and manage the
// members she has blocked.
import 'package:flutter/material.dart';

import '../../models/pv_community.dart';
import '../../services/pv_community_store.dart';
import '../../services/saved_store.dart';
import '../../widgets/pv_toast.dart';
import '../products/pv_store_chrome.dart' show kPvInk;
import 'community_chrome.dart';
import 'community_marks.dart';

class CommunityProfileScreen extends StatefulWidget {
  const CommunityProfileScreen({super.key, this.fromId, this.anon = true});

  /// A post or comment she tapped; null opens her own profile.
  final String? fromId;
  final bool anon;

  @override
  State<CommunityProfileScreen> createState() => _CommunityProfileScreenState();
}

class _CommunityProfileScreenState extends State<CommunityProfileScreen> {
  final _store = PvCommunityStore.instance;
  late bool _anon = widget.anon;
  PvCommunityAuthor? _author;
  List<PvCommunityPost> _posts = const [];
  bool _loading = true;

  bool get _own => widget.fromId == null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _store.init();
    final res = await _store.face(fromId: widget.fromId, anon: _anon);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _author = res?.$1;
      _posts = res?.$2 ?? const [];
    });
  }

  Future<void> _blocked() async {
    final list = await _store.blockedList();
    if (!mounted) return;
    await showCommunitySheet<void>(
      context,
      (c) => StatefulBuilder(
        builder: (c, set) => ListView(shrinkWrap: true, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text('Blocked members', style: cmTitle(24)),
          ),
          if (list.isEmpty)
            const CommunityEmpty(
              icon: Icons.block_rounded,
              title: 'Nobody blocked',
              body: 'When you block someone from a post, they show here and you can unblock them.',
            ),
          for (final b in [...list])
            CommunitySheetRow(
              icon: Icons.block_rounded,
              label: '${b['label']}',
              trailing: TextButton(
                onPressed: () async {
                  final ok = await _store.unblock('${b['id']}');
                  if (!c.mounted) return;
                  if (ok) set(() => list.remove(b));
                  pvToast(c, ok ? '${b['label']} is unblocked' : 'That did not go through. Try again.',
                      kind: ok ? PvToastKind.done : PvToastKind.gentle);
                },
                style: TextButton.styleFrom(foregroundColor: kPvInk),
                child: const Text('Unblock'),
              ),
              onTap: () {},
            ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_store, SavedStore.instance]),
      builder: (context, _) {
        final me = _store.me;
        final author = _own ? _store.myFace(anon: _anon) : _author;
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
            actions: [
              if (_own && me.joined)
                PopupMenuButton<String>(
                  tooltip: 'Profile options',
                  icon: const Icon(Icons.more_horiz_rounded, color: kPvInk),
                  onSelected: (v) async {
                    if (v == 'rename') {
                      final can = me.canRenameAt == null || me.canRenameAt!.isBefore(DateTime.now());
                      if (!can) {
                        pvToast(context,
                            'You can change your community name again on ${me.canRenameAt!.day}/${me.canRenameAt!.month}.',
                            kind: PvToastKind.info);
                        return;
                      }
                      final ok = await showCommunityWelcome(context, renameOnly: true);
                      if (ok == true) _load();
                    } else if (v == 'blocked') {
                      _blocked();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'rename', child: Text('Change community name')),
                    PopupMenuItem(value: 'blocked', child: Text('Blocked members')),
                  ],
                ),
            ],
          ),
          body: RefreshIndicator(
            color: kPvInk,
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (_own && !me.joined)
                  CommunityEmpty(
                    icon: Icons.person_outline_rounded,
                    title: 'You have not joined yet',
                    body: 'Join to post, reply and choose your community name. Reading is open to every member.',
                    action: 'Join the community',
                    onAction: () async {
                      final ok = await communityEnsureMember(context);
                      if (ok) _load();
                    },
                  )
                else if (author == null && !_loading)
                  const CommunityEmpty(
                    icon: Icons.visibility_off_outlined,
                    title: 'This profile is not available',
                    body: 'It may belong to someone you have blocked, or who has left.',
                  )
                else ...[
                  if (author != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: Column(children: [
                        CommunityFaceMark(author: author, size: 76),
                        const SizedBox(height: 10),
                        Text(author.label, textAlign: TextAlign.center, style: cmTitle(28)),
                        const SizedBox(height: 6),
                        Text(
                          author.anon
                              ? (_own
                                  ? 'Your community name. Posts here are never linked to your real name.'
                                  : 'A community name. Posts under it are not linked to anyone\'s real name.')
                              : (_own ? 'Your name. Only posts you chose to make as yourself.' : 'Posting under their own name.'),
                          textAlign: TextAlign.center,
                          style: cmText(14, color: cmP.ink2),
                        ),
                        if (_own) ...[
                          const SizedBox(height: 14),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            CommunityPill(
                              label: me.pseudonym ?? 'Community name',
                              selected: _anon,
                              onTap: () {
                                setState(() => _anon = true);
                                _load();
                              },
                            ),
                            const SizedBox(width: 8),
                            CommunityPill(
                              label: me.firstName ?? 'Your name',
                              selected: !_anon,
                              onTap: () {
                                setState(() => _anon = false);
                                _load();
                              },
                            ),
                          ]),
                        ],
                      ]),
                    ),
                  if (_loading && _posts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(child: CircularProgressIndicator(color: kPvInk, strokeWidth: 2)),
                    )
                  else if (_posts.isEmpty)
                    CommunityEmpty(
                      icon: Icons.edit_outlined,
                      title: _own ? 'No posts as ${author?.label ?? 'this name'} yet' : 'No posts yet',
                      body: _own
                          ? (_anon
                              ? 'When you post under your community name, it shows here.'
                              : 'When you post under your name, it shows here.')
                          : 'Their posts will show here.',
                      action: _own ? 'Write a post' : null,
                      onAction: _own ? () => openCommunityCompose(context) : null,
                    )
                  else
                    for (var i = 0; i < _posts.length; i++)
                      CommunityEnter(
                        key: ValueKey(_posts[i].id),
                        index: i,
                        child: CommunityPostCard(post: _store.post(_posts[i].id) ?? _posts[i], showJoin: false),
                      ),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
