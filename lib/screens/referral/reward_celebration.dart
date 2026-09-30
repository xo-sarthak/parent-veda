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
//
//  ---------------------------------------------------------------------------
//  ON THE BASE UI, 2026-09-29. It opens from the Invite page (and the Birth
//  Club), which were redrawn white with one ink button and a drawn mark; the
//  sheet that rose over them was still the parenting look: a lilac `ppBg`
//  ground, a violet gradient tile with a white Material gift, a lilac slab
//  behind the footnote and a violet button. So the moment she is told she
//  earned something looked like a different app from the page she earned it
//  on. Now: a white sheet, the Invite page's own drawn mark (the big and
//  small hearts, in the Benefits tint) scaling in once, a serif title and
//  ink words, the footnote as one quiet line, and the one ink pill. Every
//  stage shows this sheet, so the fix is everywhere. The old build is kept,
//  commented, at the foot of this file.
// =============================================================================

import 'package:flutter/material.dart';

// Kept for revert (2026-09-29): the parenting tokens the old sheet used.
// import '../post_pregnancy/pp_common.dart';
import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../products/pv_store_chrome.dart' show kPvInk, kPvLine;
import '../ttc/doors/ttc_tab_art.dart';
import '../v2/v2_palette.dart';

/// The hue of the mark: the More tab's Benefits section, the Invite page's.
const double kRewardMarkHue = 20;

/// The one button's key, for tests.
const Key kRewardDoneKey = ValueKey('reward_celebration_done');

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

  /// Kept in the API so no caller breaks; the sheet draws the Invite page's
  /// mark instead of a Material glyph (the icon rule: drawn marks for what
  /// she earned or taps into, line icons only for controls).
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Container(
      decoration: const BoxDecoration(
        // Kept for revert (2026-09-29): color: ppBg,
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 38,
          height: 4,
          // Kept for revert (2026-09-29): color: ppLine.
          decoration: BoxDecoration(
              color: kPvLine, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 26),
        // A single quiet flourish: the icon scales in once. No confetti.
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.75, end: 1),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutBack,
          builder: (context, v, child) =>
              Transform.scale(scale: v, child: child),
          // Kept for revert (2026-09-29): a 76pt rounded square with a
          // violet gradient (0xFF7C3FC4 to 0xFF9B6FDD) and `Icon(icon,
          // size: 34, color: Colors.white)` in it.
          child: SizedBox(
            key: const ValueKey('reward_celebration_mark'),
            width: 88,
            height: 88,
            child: TtcTabArt(
              mark: TtcTabMark.bigSmallHearts,
              tint: v2BlockTint(kRewardMarkHue, p),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Kept for revert (2026-09-29): ppFraunces(24, h: 1.15) and
        // ppBody(13.5, h: 1.6).
        Text(title,
            textAlign: TextAlign.center,
            style: pvFraunces(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                height: 1.2,
                color: p.ink1)),
        const SizedBox(height: 10),
        Text(body,
            textAlign: TextAlign.center,
            style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2)),
        // One quiet line, no slab (the user, 2026-09-29: a tinted panel
        // behind a note is noise). Kept for revert: the footnote in a
        // `ppPanel` box, radius 12, padding 13/11, ppBody(11.5).
        if (footnote != null) ...[
          const SizedBox(height: 12),
          Text(footnote!,
              textAlign: TextAlign.center,
              style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2)),
        ],
        const SizedBox(height: 24),
        // THE ONE INK BUTTON (the switches' black), a pill like every
        // primary action. Kept for revert (2026-09-29): a 50-high `ppPurple`
        // box, radius 14, ppJakarta(14, white).
        Semantics(
          button: true,
          child: Material(
            key: kRewardDoneKey,
            color: kPvInk,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(S.now.uiLovely,
                    textAlign: TextAlign.center,
                    style: pvManrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// =============================================================================
//  Kept for revert (2026-09-29): the parenting-look sheet, from the icon tile
//  to the button, word for word.
// =============================================================================
//         child: Container(
//           width: 76,
//           height: 76,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Color(0xFF7C3FC4), Color(0xFF9B6FDD)],
//             ),
//             borderRadius: BorderRadius.circular(24),
//           ),
//           child: Icon(icon, size: 34, color: Colors.white),
//         ),
//       ),
//       const SizedBox(height: 22),
//       Text(title,
//           textAlign: TextAlign.center, style: ppFraunces(24, h: 1.15)),
//       const SizedBox(height: 10),
//       Text(body,
//           textAlign: TextAlign.center, style: ppBody(13.5, h: 1.6)),
//       if (footnote != null) ...[
//         const SizedBox(height: 14),
//         Container(
//           padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
//           decoration: BoxDecoration(
//               color: ppPanel, borderRadius: BorderRadius.circular(12)),
//           child: Text(footnote!,
//               textAlign: TextAlign.center, style: ppBody(11.5, h: 1.5)),
//         ),
//       ],
//       const SizedBox(height: 22),
//       GestureDetector(
//         onTap: () => Navigator.of(context).maybePop(),
//         behavior: HitTestBehavior.opaque,
//         child: Container(
//           height: 50,
//           width: double.infinity,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//               color: ppPurple, borderRadius: BorderRadius.circular(14)),
//           child: Text(S.now.uiLovely, style: ppJakarta(14, color: Colors.white)),
//         ),
//       ),

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
