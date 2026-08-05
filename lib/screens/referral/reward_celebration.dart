// =============================================================================
//  Reward celebration — the moment something is earned
// -----------------------------------------------------------------------------
//  Rewards used to land silently: a credit appeared in an entitlement list and
//  nobody was told. If a parent invites a friend and the app says nothing when
//  it pays off, the referral has taught her that inviting people does nothing.
//
//  Deliberately restrained. ParentVeda is a calm app used by exhausted people,
//  so this is a sheet she dismisses, not confetti and a fanfare - the reward is
//  the point, not the animation. It is also SHOWN ONCE per reward: celebrating
//  the same credit on every app open would be nagging dressed as delight.
// =============================================================================

import 'package:flutter/material.dart';

import '../post_pregnancy/pp_common.dart';
import '../../localization/app_language.dart';

class RewardCelebration extends StatelessWidget {
  const RewardCelebration({
    super.key,
    required this.title,
    required this.body,
    this.footnote,
    this.icon = Icons.card_giftcard_rounded,
  });

  final String title;
  final String body;
  final String? footnote;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ppBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 38,
          height: 4,
          decoration:
              BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 26),
        // A single quiet flourish: the icon scales in once. No confetti.
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.75, end: 1),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutBack,
          builder: (context, v, child) =>
              Transform.scale(scale: v, child: child),
          child: Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7C3FC4), Color(0xFF9B6FDD)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 34, color: Colors.white),
          ),
        ),
        const SizedBox(height: 22),
        Text(title,
            textAlign: TextAlign.center, style: ppFraunces(24, h: 1.15)),
        const SizedBox(height: 10),
        Text(body,
            textAlign: TextAlign.center, style: ppBody(13.5, h: 1.6)),
        if (footnote != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
            decoration: BoxDecoration(
                color: ppPanel, borderRadius: BorderRadius.circular(12)),
            child: Text(footnote!,
                textAlign: TextAlign.center, style: ppBody(11.5, h: 1.5)),
          ),
        ],
        const SizedBox(height: 22),
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 50,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: ppPurple, borderRadius: BorderRadius.circular(14)),
            child: Text(S.now.uiLovely, style: ppJakarta(14, color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

/// Show a reward moment. Returns when it is dismissed.
Future<void> showRewardCelebration(
  BuildContext context, {
  required String title,
  required String body,
  String? footnote,
  IconData icon = Icons.card_giftcard_rounded,
}) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RewardCelebration(
        title: title,
        body: body,
        footnote: footnote,
        icon: icon,
      ),
    );
