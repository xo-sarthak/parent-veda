// =============================================================================
//  V3 hero chrome — the spine door, and the two icons every stage owes her
// -----------------------------------------------------------------------------
//  Two small widgets, shared by all three stage homes, because both of them are
//  the kind of thing that drifts the moment it is copied. The section eyebrow
//  shipped GREY on TTC and PURPLE on parenting for exactly that reason: a
//  hand-copied widget with one token changed, which nothing fails on and only a
//  side-by-side comparison catches.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY THE EYEBROW IS THE DOOR TO THE SPINE
//  ---------------------------------------------------------------------------
//
//  Each stage has a spine — the weekly stack (pregnancy), the phase map
//  (parenting), the chapter journey (TTC) — and until now V3 had no way in to
//  any of them. The obvious fixes were both bad:
//
//    · **A button in the hero.** The hero already carries exactly one forward
//      line ("Next: the peak, and the first smile"). A second call to action
//      beside it makes the reader choose between two invitations, and the usual
//      result is that neither is taken.
//    · **A row further down the page.** The spine is the stage's backbone; a
//      link to it under the fold says it is a feature among features.
//
//  The answer was already on the screen. **The eyebrow states her position on
//  the spine** — "PHASE 1 OF 20", "WEEK 40 · DAY 7" — and "1 of 20" already
//  implies nineteen others. The information IS the invitation, so the eyebrow
//  does not need a button beside it; it needs to LOOK like the control it
//  should always have been.
//
//  So it becomes an outlined chip with a chevron. No new element, no second
//  CTA, no extra vertical space, and the same shape in the same place on all
//  three stages — which is the symmetry the rest of V3 has been converging on.
//
//  ⚠️ ON PREGNANCY THIS FIXES AN INVISIBLE FEATURE RATHER THAN ADDING ONE. Its
//  hero photograph was ALREADY tappable through to the weekly stack — the whole
//  302px image was one big hit target with no affordance whatsoever. That is
//  the "correct but unreachable" failure in its purest form: perfectly wired,
//  perfectly invisible. The chip does not add a route there. It admits one
//  exists.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import 'v2_palette.dart';

/// Where the chip is sitting, which decides its colours.
///
/// ⚠️ TWO TONES, NOT A COLOUR PARAMETER. A caller that can pass any colour is a
/// caller that will eventually pass the wrong one — which is how the eyebrow
/// went grey. Two named surfaces is the whole set of places this can sit:
/// pregnancy's hero is a dark photograph, everyone else's is a pale field.
enum V3HeroTone {
  /// On the pregnancy photograph — white on a dark, busy image.
  onPhoto,

  /// On the tinted field — ink on a pale, chromatic ground.
  onField,
}

/// The eyebrow, rendered as the door to the stage's spine.
///
/// [label] is the position statement itself, already uppercased by the caller
/// if that is the stage's style.
class V3SpineChip extends StatelessWidget {
  const V3SpineChip({
    super.key,
    required this.label,
    required this.tone,
    required this.p,
    this.onTap,
  });

  final String label;
  final V3HeroTone tone;
  final V2Palette p;

  /// Null renders the chip as plain type with no border and no chevron — the
  /// honest state for a stage whose spine has nowhere to go yet. A chip that
  /// looks tappable and is not is worse than a label.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onPhoto = tone == V3HeroTone.onPhoto;
    // ⚠️ ink2 on the field, not ink3 — the rule the parenting hero already
    // records: a grey calibrated for a neutral ground loses contrast against a
    // chromatic one faster than it loses lightness.
    final fg = onPhoto ? Colors.white.withValues(alpha: 0.92) : p.ink2;
    final line = onPhoto ? Colors.white.withValues(alpha: 0.34) : p.ink3.withValues(alpha: 0.34);

    final text = Text(label,
        style: pvManrope(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: fg));

    if (onTap == null) return text;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.fromLTRB(11, 6, 8, 6),
          decoration: BoxDecoration(
            border: Border.all(color: line),
            borderRadius: BorderRadius.circular(999),
            // A whisper of fill on the field so the outline is not the only
            // thing separating it from the gradient behind it. On the
            // photograph the image is dark enough that a fill would muddy it.
            color: onPhoto
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.white.withValues(alpha: 0.34),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            text,
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 15, color: fg),
          ]),
        ),
      ),
    );
  }
}

/// Saved and profile, top-right of the hero.
///
/// ⚠️ TWO SEPARATE DOORS, NOT ONE. Pregnancy settled this and the other stages
/// inherit it: her saved things and her profile are different places, and
/// burying saved behind the avatar is how saved stops being used.
///
/// Parenting and TTC had NO hero chrome at all — no way to reach saved or
/// profile from their V3 homes, while pregnancy had both. Three stage homes
/// disagreeing about whether an account exists is the kind of asymmetry a
/// mother reads as the app being half-finished, because it is.
class V3HeroChrome extends StatelessWidget {
  const V3HeroChrome({
    super.key,
    required this.tone,
    required this.p,
    required this.onSaved,
    required this.onProfile,
    this.initial = '',
  });

  final V3HeroTone tone;
  final V2Palette p;
  /// ⚠️ NULLABLE, AND NULL HIDES THE BUTTON RATHER THAN DISABLING IT. A stage
  /// with nowhere to send her should show no bookmark at all — a greyed icon
  /// still reads as a feature, and one that never responds reads as broken.
  final VoidCallback? onSaved;
  final VoidCallback? onProfile;

  /// One letter for the avatar. Empty falls back to a person glyph rather than
  /// a blank circle.
  final String initial;

  @override
  Widget build(BuildContext context) {
    final onPhoto = tone == V3HeroTone.onPhoto;
    final fg = onPhoto ? Colors.white : p.ink1;
    final bg = onPhoto
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.62);

    Widget button(Widget child, VoidCallback onTap) => Material(
          color: bg,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(width: 38, height: 38, child: Center(child: child)),
          ),
        );

    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (onSaved != null) ...[
        button(Icon(Icons.bookmark_border_rounded, size: 19, color: fg),
            onSaved!),
        const SizedBox(width: 8),
      ],
      if (onProfile != null)
        button(
          initial.isEmpty
              ? Icon(Icons.person_outline_rounded, size: 19, color: fg)
              : Text(initial.toUpperCase(),
                  style: pvJakarta(
                      fontSize: 15, fontWeight: FontWeight.w700, color: fg)),
          onProfile!,
        ),
    ]);
  }
}
