// The moderator queue: route 'community/moderation'. Reached from the shield
// on the community home, which only shows for accounts on the moderators
// list. The server checks that list again on every call, so this screen is
// a convenience, not the lock (0121 `community_is_mod`).
//
// Order is triage order: someone who may be at risk first, then what members
// reported, then what the word check held, then photos waiting. Every action
// asks for a short reason, because the audit row is the point: a removal
// nobody can explain later is a removal nobody can defend.
import 'package:flutter/material.dart';

import '../../services/pv_community_store.dart';
import '../../widgets/pv_toast.dart';
import '../products/pv_store_chrome.dart' show kPvInk;
import 'community_chrome.dart';

class CommunityModerationScreen extends StatefulWidget {
  const CommunityModerationScreen({super.key});

  @override
  State<CommunityModerationScreen> createState() => _CommunityModerationScreenState();
}

class _CommunityModerationScreenState extends State<CommunityModerationScreen> {
  final _store = PvCommunityStore.instance;
  String _queue = 'crisis';
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _denied = false;
  final Map<String, String> _done = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final d = await _store.modQueue(_queue);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _data = d;
      _denied = d == null && _store.signedIn;
    });
    final paths = [
      for (final it in (d?['items'] as List?) ?? const [])
        for (final m in ((it as Map)['media'] as List?) ?? const []) '${(m as Map)['path']}',
    ];
    if (paths.isNotEmpty) _store.signPaths(paths);
  }

  Future<void> _act(Map item, String action, String label) async {
    final reason = await _askReason(label);
    if (reason == null || !mounted) return;
    var mute = 24;
    var act = action;
    if (action == 'remove_mute') {
      act = 'remove';
      mute = 24;
    }
    final err = await _store.modAct(
      kind: '${item['kind']}',
      id: '${item['id']}',
      action: act,
      reason: reason,
      muteHours: mute,
    );
    if (err == null && action == 'remove_mute') {
      await _store.modAct(kind: '${item['kind']}', id: '${item['id']}', action: 'mute', reason: reason, muteHours: mute);
    }
    if (!mounted) return;
    if (err != null) {
      pvToast(context, err, kind: PvToastKind.gentle);
      return;
    }
    setState(() => _done['${item['kind']}:${item['id']}'] = label);
    pvToast(context, '$label. Logged in the audit trail.', kind: PvToastKind.done);
  }

  Future<String?> _askReason(String label) {
    final c = TextEditingController();
    return showCommunitySheet<String>(
      context,
      (s) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(label, style: cmTitle(24)),
          const SizedBox(height: 6),
          Text('A short reason. It is kept in the audit trail with your name.', style: cmText(14, color: cmP.ink2)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final q in const [
              'Breaks house rules',
              'Harassment',
              'Explicit',
              'Medical misinformation',
              'Spam or selling',
              'Fine as it is',
              'Reached out to her',
            ])
              ActionChip(
                label: Text(q),
                onPressed: () => c.text = q,
                backgroundColor: Colors.white,
                side: BorderSide(color: cmP.line),
                shape: const StadiumBorder(),
              ),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: c,
            autofocus: true,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Reason',
              counterText: '',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          CommunityInkButton(
            label: 'Confirm',
            onTap: () {
              if (c.text.trim().length < 3) return;
              Navigator.pop(s, c.text.trim());
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final counts = (_data?['counts'] as Map?) ?? const {};
    final items = [for (final it in (_data?['items'] as List?) ?? const []) it as Map];
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_rounded, color: kPvInk),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text('Moderation', style: cmText(17, weight: FontWeight.w800)),
          centerTitle: true,
        ),
        // (0137, decision 19) An editorial prompt: posted as ParentVeda team
        // into a room she picks, optionally pinned. Pinning any other post is
        // in that post's menu.
        floatingActionButton: _denied
            ? null
            : FloatingActionButton.extended(
                key: const ValueKey('community_mod_write_prompt'),
                heroTag: 'community-mod-prompt',
                backgroundColor: kPvInk,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                onPressed: () => openCommunityCompose(context, asTeam: true),
                icon: const Icon(Icons.campaign_outlined, size: 20),
                label: Text('Write a prompt', style: cmText(15, weight: FontWeight.w700, color: Colors.white)),
              ),
        body: _denied
            ? const CommunityEmpty(
                icon: Icons.shield_outlined,
                title: 'Moderators only',
                body: 'This account is not on the moderators list. An admin adds moderators from the dashboard.',
              )
            : RefreshIndicator(
                color: kPvInk,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Row(children: [
                        for (final (k, l) in const [
                          ('crisis', 'At risk'),
                          ('reported', 'Reported'),
                          ('held', 'Held'),
                          ('photos', 'Photos'),
                        ]) ...[
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() => _queue = k);
                                _load();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _queue == k ? kPvInk : cmP.line, width: _queue == k ? 1.5 : 1),
                                ),
                                child: Column(children: [
                                  Text('${counts[k] ?? 0}', style: cmText(20, weight: FontWeight.w800)),
                                  Text(l, style: cmText(12, weight: FontWeight.w700, color: cmP.ink2)),
                                ]),
                              ),
                            ),
                          ),
                          if (k != 'photos') const SizedBox(width: 6),
                        ],
                      ]),
                    ),
                    if (_loading && items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator(color: kPvInk, strokeWidth: 2)),
                      )
                    else if (items.isEmpty)
                      const CommunityEmpty(
                        icon: Icons.check_circle_outline_rounded,
                        title: 'Queue clear',
                        body: 'Nothing is waiting here. Pull down to check again.',
                      )
                    else
                      for (final it in items) _item(it),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Text(
                        'Write a prompt posts as ParentVeda team and can pin it for up to 14 days. '
                        'To pin any post, use Pin in its ⋯ menu.',
                        style: cmText(12.5, color: cmP.ink3),
                      ),
                    ),
                    const SizedBox(height: 110),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _item(Map it) {
    final key = '${it['kind']}:${it['id']}';
    final done = _done[key];
    final reasons = [for (final r in (it['reasons'] as List?) ?? const []) '$r'];
    final media = [for (final m in (it['media'] as List?) ?? const []) '${(m as Map)['path']}'];
    final author = (it['author'] as Map?) ?? const {};
    const rose = Color(0xFFC6295A);
    Widget tag(String t, {bool crit = false}) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFFF3F3F4), borderRadius: BorderRadius.circular(999)),
          child: Text(t, style: cmText(12, weight: FontWeight.w700, color: crit ? rose : cmP.ink2)),
        );
    Widget btn(String label, VoidCallback onTap, {bool primary = false, bool danger = false}) => Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 8),
          child: primary
              ? CommunityInkButton(label: label, compact: true, onTap: onTap)
              : OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: danger ? rose : kPvInk,
                    side: BorderSide(color: cmP.line),
                    shape: const StadiumBorder(),
                    textStyle: cmText(13, weight: FontWeight.w700),
                  ),
                  child: Text(label),
                ),
        );
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: cmP.line))),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 6, runSpacing: 6, children: [
          if (it['crisis'] == true) tag('May be at risk', crit: true),
          if ((it['report_count'] as num? ?? 0) > 0) tag('Reported ${it['report_count']}×'),
          if (it['status'] == 'hidden') tag('Auto-hidden', crit: true),
          if (it['status'] == 'held') tag('Held: ${it['hold_reason'] ?? 'words'}'),
          for (final r in reasons) tag(r.replaceAll('_', ' ')),
          tag(it['kind'] == 'post' ? 'Post' : 'Reply'),
        ]),
        const SizedBox(height: 8),
        Text('${author['label'] ?? 'A member'}${author['anon'] == true ? ' (community name)' : ''} · ${it['room_title'] ?? ''}',
            style: cmText(12.5, color: cmP.ink3)),
        const SizedBox(height: 6),
        InkWell(
          onTap: it['post_id'] == null ? null : () => openCommunityPost(context, '${it['post_id']}'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF3F3F4), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${it['title'] ?? ''}', style: cmText(14.5, weight: FontWeight.w800)),
              if ('${it['body'] ?? ''}'.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('${it['body']}', maxLines: 8, overflow: TextOverflow.ellipsis, style: cmText(14)),
              ],
            ]),
          ),
        ),
        if (media.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final p in media)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _store.urlFor(p) == null
                        ? Container(width: 110, color: const Color(0xFFF3F3F4), child: const Icon(Icons.image_outlined))
                        : Image.network(_store.urlFor(p)!, width: 110, height: 110, fit: BoxFit.cover),
                  ),
                ),
            ]),
          ),
        ],
        const SizedBox(height: 10),
        if (done != null)
          Row(children: [
            const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF1F8A5B)),
            const SizedBox(width: 6),
            Expanded(child: Text('$done · logged', style: cmText(13, weight: FontWeight.w700, color: const Color(0xFF1F8A5B)))),
          ])
        else
          Wrap(children: switch (_queue) {
            'crisis' => [
                btn('Mark as handled', () => _act(it, 'handled', 'Marked as handled'), primary: true),
                btn('Remove', () => _act(it, 'remove', 'Removed'), danger: true),
              ],
            'photos' => [
                btn('Approve photos', () => _act(it, 'approve_media', 'Photos approved'), primary: true),
                btn('Reject photos', () => _act(it, 'reject_media', 'Photos rejected'), danger: true),
              ],
            _ => [
                btn(_queue == 'held' ? 'Approve' : 'Keep it up', () => _act(it, 'approve', 'Approved'), primary: true),
                btn('Remove', () => _act(it, 'remove', 'Removed'), danger: true),
                btn('Remove + mute 24h', () => _act(it, 'remove_mute', 'Removed, member muted 24 hours'), danger: true),
                btn('Ban', () => _act(it, 'ban', 'Member banned'), danger: true),
              ],
          }),
      ]),
    );
  }
}
