// =============================================================================
//  InviteNudgeCard — the referral's discoverable surfaces
// -----------------------------------------------------------------------------
//  One reusable card so every entry point says the same thing and reads the same
//  live config. Dropped into the two home screens and Community.
//
//  Restraint, on purpose:
//    * it hides itself once the parent has hit her invite cap or the campaign is
//      off, rather than offering something that will be refused;
//    * it never nags a mother to recruit people. It states the offer plainly and
//      gets out of the way. A pregnancy app that pesters her to bring in friends
//      has stopped being a pregnancy app.
//
//  Two shapes: `banner` for a home feed, `row` for a list.
// =============================================================================

import 'package:flutter/material.dart';

import '../../referral/referral_store.dart';
import '../post_pregnancy/pp_common.dart';
import 'invite_friends_screen.dart';

enum InviteNudgeShape { banner, row }

class InviteNudgeCard extends StatefulWidget {
  const InviteNudgeCard({
    super.key,
    this.shape = InviteNudgeShape.banner,
    this.padding = EdgeInsets.zero,
  });

  final InviteNudgeShape shape;
  final EdgeInsets padding;

  @override
  State<InviteNudgeCard> createState() => _InviteNudgeCardState();
}

class _InviteNudgeCardState extends State<InviteNudgeCard> {
  final _store = ReferralStore.instance;

  @override
  void initState() {
    super.initState();
    _store.init();
  }

  void _open() => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const InviteFriendsScreen()));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        // Nothing to offer -> show nothing. Better than a card that leads to
        // "you have hit your limit".
        if (!_store.isLoaded) return const SizedBox.shrink();
        if (!_store.config.enabled) return const SizedBox.shrink();
        if (_store.invitingProblem != null) return const SizedBox.shrink();

        final reward = _store.config.inviterReward.label;
        return Padding(
          padding: widget.padding,
          child: widget.shape == InviteNudgeShape.banner
              ? _banner(reward)
              : _row(reward),
        );
      },
    );
  }

  Widget _banner(String reward) => GestureDetector(
        onTap: _open,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF6A30B6), Color(0xFF8B5CD6)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: [
            const Icon(Icons.card_giftcard_rounded, size: 22, color: Colors.white),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Going through this with a friend?',
                        style: ppJakarta(14, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('Invite her and you both get $reward.',
                        style: ppBody(12, h: 1.4, color: Colors.white70)),
                  ]),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
          ]),
        ),
      );

  Widget _row(String reward) => GestureDetector(
        onTap: _open,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: ppBorder),
          ),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: ppPanel, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.card_giftcard_outlined,
                  size: 19, color: ppPurple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invite a friend', style: ppJakarta(13.5)),
                    const SizedBox(height: 2),
                    Text('You both get $reward.', style: ppBody(11.5, h: 1.4)),
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );
}
