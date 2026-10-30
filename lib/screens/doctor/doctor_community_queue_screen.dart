// =============================================================================
//  Community questions — the posts parents asked an expert to look at (0137)
// -----------------------------------------------------------------------------
//  Linear's inbox rows, oldest first. Each says which room it came from and
//  when it was asked, and carries Claim, so two experts do not answer the
//  same question (a claim lapses after a day on the server). A row opens the
//  ordinary post screen, where the reply face defaults to her own name and
//  badge; replying under it marks the question answered.
//
//  NO CRISIS BAND. The user decided on 2026-10-28 that crisis posts stay with
//  the moderators for now (W20), so nothing in here was raised by the safety
//  check; a member asking about a crisis post is refused before it gets here.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/pv_community.dart';
import '../../services/pv_community_store.dart';
import '../../widgets/pv_toast.dart';
import '../community/community_chrome.dart' show communityAgo, openCommunityPost;
import 'doctor_art.dart';
import 'doctor_chrome.dart';

const String kDoctorCommunityQueueRoute = 'doctor/community-queue';

void openDoctorCommunityQueue(BuildContext context) => Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: kDoctorCommunityQueueRoute),
      builder: (_) => const DoctorCommunityQueueScreen(),
    ));

class DoctorCommunityQueueScreen extends StatefulWidget {
  const DoctorCommunityQueueScreen({super.key});

  @override
  State<DoctorCommunityQueueScreen> createState() => _DoctorCommunityQueueScreenState();
}

class _DoctorCommunityQueueScreenState extends State<DoctorCommunityQueueScreen> {
  final _store = PvCommunityStore.instance;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _store.init().then((_) async {
      await _store.refreshMe();
      await _refresh();
    });
  }

  Future<void> _refresh() async {
    await _store.expertQueue();
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _claim(PvExpertRequest q) async {
    final err = await _store.expertClaim(q.post.id, on: !q.claimedByMe);
    if (!mounted) return;
    pvToast(
      context,
      err ?? (q.claimedByMe ? 'Let go. Other experts can pick it up.' : 'Claimed. Other experts see that you are on it.'),
      kind: err == null ? PvToastKind.done : PvToastKind.gentle,
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final items = _store.expertQueueItems;
          final notExpert = _loaded && _store.me.signedIn && !_store.me.isExpert;
          return DcScreen(
            title: 'Community questions',
            subtitle: 'Parents asked an expert to look at these. Answer under your own name. '
                'Crisis posts go to the moderators, not here.',
            onRefresh: _refresh,
            children: [
              if (!_loaded && items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else if (notExpert)
                const DcEmpty(
                  'For verified experts',
                  'This list opens once your expert profile is published on ParentVeda.',
                  mark: DoctorMark.inbox,
                )
              else if (items.isEmpty)
                const DcEmpty(
                  'Nobody is waiting',
                  'When a parent asks an expert to look at her question, it appears here, oldest first.',
                  mark: DoctorMark.inbox,
                )
              else
                DcRowGroup(children: [
                  for (final q in items) _QueueRow(item: q, onClaim: () => _claim(q)),
                ]),
            ],
          );
        },
      );
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({required this.item, required this.onClaim});
  final PvExpertRequest item;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final q = item;
    return InkWell(
      key: ValueKey('doctor_queue_${q.post.id}'),
      onTap: () => openCommunityPost(context, q.post.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text('${q.post.roomTitle} · asked ${communityAgo(q.askedAt)} ago',
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: dcMeta(12.5)),
            ),
            if (q.claimedBy != null)
              Text('${q.claimedBy} is on it', style: dcMeta(12.5))
            else if (q.claimedByMe)
              TextButton.icon(
                onPressed: onClaim,
                icon: Icon(Icons.check_rounded, size: 16, color: p.ink1),
                label: Text('You are on it', style: dcStrong(12.5)),
              )
            else
              OutlinedButton(
                onPressed: onClaim,
                style: OutlinedButton.styleFrom(
                  foregroundColor: p.ink1,
                  side: BorderSide(color: p.line),
                  shape: const StadiumBorder(),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text('Claim', style: dcStrong(12.5)),
              ),
          ]),
          const SizedBox(height: 6),
          Text(q.post.title, style: dcStrong(15.5)),
        ]),
      ),
    );
  }
}
