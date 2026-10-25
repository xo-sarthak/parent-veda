// =============================================================================
//  PvDoorIntroChip — "How this door works", in every door's header
// -----------------------------------------------------------------------------
//  GLOBAL-CHANGES #5, Option A (decided 2026-10-23 after a Mobbin pass): a
//  white pill in the door's photo header, under the title and blurb, above
//  search. One widget, so a TTC, pregnancy, parenting and skilling door wear
//  the same pill in the same place.
//
//  ⚠️ IT SHOWS BEFORE ITS VIDEO EXISTS, SAYING SO. The approved design hid
//  the chip until the film was made. The user, 2026-10-25, on the skilling
//  prototype: "you can provide the button, and it may say coming soon" — and
//  then "yes all stages". So every door shows it now, with a Coming soon tag,
//  and a tap says the video is being made (no silent tap). When a door's film
//  lands, the door passes [length] and [onPlay]: the tag becomes the length
//  ("0:50") and the tap plays it. The first-open pop-up and the NEW state
//  arrive with the first film (still owed, see GLOBAL-CHANGES #5).
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/v2/v2_palette.dart';
import '../theme/pv_fonts.dart';
import 'pv_feedback.dart';
import 'pv_toast.dart';

const Key kPvDoorIntroChipKey = ValueKey('pv-door-intro-chip');

/// What a tap says while a door has no film yet.
const String kPvDoorIntroSoonLine =
    'The video for this door is being made. It will play here, muted with '
    'captions, when it is ready.';

class PvDoorIntroChip extends StatelessWidget {
  const PvDoorIntroChip({
    super.key,
    required this.p,
    this.onPhoto = true,
    this.length,
    this.onPlay,
  });

  final V2Palette p;

  /// On a photograph the pill is near-white with no border; on the plain
  /// field it is the surface with the page hairline.
  final bool onPhoto;

  /// The film's length ("0:50"). Null while the film is not made.
  final String? length;

  /// Plays the film. Null while the film is not made.
  final VoidCallback? onPlay;

  bool get _ready => length != null && onPlay != null;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: _ready
            ? 'How this door works, video, $length'
            : 'How this door works, video, coming soon',
        excludeSemantics: true,
        child: PvPress(
          child: GestureDetector(
            key: kPvDoorIntroChipKey,
            behavior: HitTestBehavior.opaque,
            onTap: () {
              pvCommitFeedback();
              if (_ready) {
                onPlay!();
              } else {
                pvToast(context, kPvDoorIntroSoonLine);
              }
            },
            // ⚠️ GROWS, NEVER OVERFLOWS. At a large text size the words wrap
            // to a second line and the pill grows with them (the 360dp, 1.5x
            // door tests); the 36 is a floor, not a height.
            child: Container(
              constraints: const BoxConstraints(minHeight: 36),
              padding: const EdgeInsets.fromLTRB(5, 5, 8, 5),
              decoration: BoxDecoration(
                color: onPhoto ? Colors.white.withValues(alpha: 0.94) : p.surface,
                borderRadius: BorderRadius.circular(999),
                border: onPhoto ? null : Border.all(color: p.line),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(color: p.ink1, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded,
                      size: 17, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text('How this door works',
                      maxLines: 2,
                      style: pvManrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: p.ink1)),
                ),
                const SizedBox(width: 8),
                if (_ready)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(length!,
                        style: pvManrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: p.ink3)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: p.surfaceAlt,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('COMING SOON',
                        style: pvManrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                            color: p.ink2)),
                  ),
              ]),
            ),
          ),
        ),
      );
}
