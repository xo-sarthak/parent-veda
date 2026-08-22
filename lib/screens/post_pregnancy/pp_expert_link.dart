// =============================================================================
//  An expert's name, everywhere, tappable
// -----------------------------------------------------------------------------
//  ⚠️ THIS EXISTS BECAUSE THE ANSWER WAS "SOMETIMES", AND SOMETIMES IS WORSE
//  THAN NEVER.
//
//  A parent tapped an instructor's name on a course and got their profile. She
//  tapped the same-looking name on a video card, on a program row, on a channel
//  and got nothing. Reported as: "in courses we have the doc name, when you
//  click you can see their profile, but that isn't happening for a lot of
//  sections."
//
//  An inconsistent affordance is the expensive kind of bug. A name that is
//  never tappable teaches "names are not links" in one screen. A name that is
//  tappable in six places and dead in twenty-two teaches nothing, and every
//  dead one reads as the app being broken.
//
//  ⚠️ A SHARED WIDGET RATHER THAN TWENTY-EIGHT EDITS. Each site could have been
//  wrapped in its own `GestureDetector`, and then the twenty-ninth name written
//  next month would be dead again. One widget means the tap, the styling and
//  the route name are decided once, and using it is shorter than not using it.
//
//  ⚠️ THE NAME IS THE TARGET, NOT THE ROW. On a video card the row already has
//  a job: it plays the video. Nesting a second tap zone over the whole row
//  would steal that, so only the name's own glyphs respond. That is what
//  `Text.rich` plus a recognizer buys, and it is why this is not simply an
//  `InkWell`.
//
//  ⚠️ IT IS A StatefulWidget SO THE RECOGNIZER GETS DISPOSED. `TapGestureRecognizer`
//  holds a native gesture-arena subscription; creating one inside a
//  StatelessWidget's `build` leaks one per rebuild, and a scrolling list of
//  video cards rebuilds constantly. This is the whole reason the class has
//  state.
// =============================================================================

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_experts_data.dart';
import 'provider_profile_screen.dart';

/// Opens an expert's profile. One route name, so navigation is legible in logs
/// and `GlobalAskFab` can reason about where it is.
void openExpertProfile(BuildContext context, Expert e) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: 'pp/expert/${e.id}'),
    builder: (_) => ProviderProfileScreen(expert: e),
  ));
}

/// An expert's name, rendered as part of a line, with only the name tappable.
///
/// [prefix] and [suffix] carry the surrounding metadata ("4 min · ", " · 90s")
/// so a card can keep its single line of text and still have one live word in
/// it.
class PpExpertName extends StatefulWidget {
  const PpExpertName(
    this.expert, {
    super.key,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.maxLines = 1,
    this.underline = true,
    this.overflow = TextOverflow.ellipsis,
  });

  final Expert expert;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final int maxLines;

  /// ⚠️ ACCEPTED RATHER THAN HARDCODED, because every call site this
  /// replaced was already passing it. A widget that forces its own overflow
  /// makes the conversion a rewrite of each caller instead of a swap, and a
  /// rewrite is where a card quietly loses its ellipsis.
  final TextOverflow overflow;

  /// ⚠️ ON BY DEFAULT, AND IT IS NOT DECORATION. Without some mark the name is
  /// indistinguishable from the metadata beside it, and a tap target nobody
  /// can see is the same as no tap target. A hairline underline is the
  /// quietest signal that still reads as "this does something" — a colour
  /// change would fight the one loud colour rule, and an icon beside every
  /// name would clutter a card.
  ///
  /// Off for the few places where the name is already a heading and obviously
  /// the subject of the screen.
  final bool underline;

  @override
  State<PpExpertName> createState() => _PpExpertNameState();
}

class _PpExpertNameState extends State<PpExpertName> {
  late final TapGestureRecognizer _tap;

  @override
  void initState() {
    super.initState();
    _tap = TapGestureRecognizer()
      ..onTap = () => openExpertProfile(context, widget.expert);
  }

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.style ?? ppBody(13, color: ppMuted);
    return Text.rich(
      TextSpan(children: [
        if (widget.prefix.isNotEmpty) TextSpan(text: widget.prefix),
        TextSpan(
          text: widget.expert.name,
          recognizer: _tap,
          style: widget.underline
              ? const TextStyle(
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.solid,
                  // A hairline, not a link. Same weight as the text so it
                  // reads as an affordance rather than as a hyperlink from
                  // 2003.
                  decorationThickness: 0.6,
                )
              : null,
        ),
        if (widget.suffix.isNotEmpty) TextSpan(text: widget.suffix),
      ]),
      style: base,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}

/// A whole row that is about one expert, made tappable.
///
/// For the cases where the name IS the point of the block — a "who wrote this"
/// card, a channel header — a name-sized target is the wrong shape and the
/// whole card should respond.
class PpExpertTapRow extends StatelessWidget {
  const PpExpertTapRow(
      {super.key, required this.expert, required this.child});

  final Expert expert;
  final Widget child;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => openExpertProfile(context, expert),
        behavior: HitTestBehavior.opaque,
        child: child,
      );
}
