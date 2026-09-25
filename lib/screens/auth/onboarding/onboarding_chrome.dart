// =============================================================================
//  Onboarding chrome — the few pieces every first-run screen is built from
// -----------------------------------------------------------------------------
//  Tokens come from V2PaletteStore (the V3 palette), type from pv_fonts, as on
//  every V3 screen.
//
//  ⚠️ THE BASE-UI RULE, 2026-09-17 (DESIGN-SYSTEM §4, from the Mobbin
//  component audit — Airbnb, Notion, Linear, Etsy, Queue): INK FOR ACTIONS,
//  BRAND AS A SMALL ACCENT, COLOUR ONLY INSIDE WELLS. The one commit button
//  per screen is a near-black pill (ink1), never the violet; the Google button
//  is a white outlined pill with the four-colour mark on it; a selected chip
//  or tile inks its border and mark, never fills with the action colour; the
//  action colour appears on eyebrows, links and a switch's on-state, and
//  nowhere else. Category colour lives in the tinted icon wells.
//
//  (The earlier §5.2 decision — one filled violet button per screen — was
//  reversed by the user on seeing it: "so much purple thrown around". Kept
//  here as history so it is not re-decided.)
//
//  ⚠️ THE "NO PROGRESS BAR" RULE IS NARROWED, 2026-09-22 — not deleted.
//  This file used to say "no progress bar anywhere (a count announces a
//  task)", and for the flow as it stood that was right: welcome, hello, who,
//  stage and date are five DIFFERENT kinds of screen, and "2 of 5" over them
//  counts nothing a person can feel.
//
//  What changed is that there is now a contiguous run of identically shaped
//  questions, and reading fourteen onboarding flows on Mobbin, every single
//  one puts a bar over exactly that run — Noom goes further and LABELS the
//  section ("DEMOGRAPHIC PROFILE") over seven dots. The finding is consistent
//  and it is the opposite of the intuition: an unknown number of questions is
//  what makes people leave, because they cannot tell if they are two from the
//  end or twenty. A bar over a run of like things is information; a bar over
//  a whole flow of unlike things is the task-announcing pressure the original
//  rule was protecting against. So: `ObProgress` exists, and it appears on
//  the question block ONLY. (docs/ONBOARDING-V2.md §1.2.)
//
//  No decorative emoji, English only.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../v2/v2_palette.dart';
import 'onboarding_art.dart';

/// Press feedback for every base component: a 2% settle while the finger is
/// down, back on release. Airbnb's and Linear's buttons do exactly this and
/// nothing more — it is the difference between "tapped" and "pressed", and it
/// costs 120 ms. Ripples stay (InkWell inside); the scale wraps them.
/// The press feedback — now the app-wide `PvPress` (lib/widgets/pv_feedback.dart),
/// promoted 2026-09-18 so every tile presses the same way. Kept as a name so
/// the onboarding screens read as before.
typedef ObPress = PvPress;

/// Page frame: ground, safe area, an optional back arrow and a scrolling body
/// with the primary action pinned beneath it.
class ObPage extends StatelessWidget {
  const ObPage({
    super.key,
    required this.p,
    required this.body,
    this.onBack,
    this.bottom,
    this.trailing,
    this.center = false,
  });

  final V2Palette p;
  final List<Widget> body;

  /// Pull a short body down off the top bar so it sits in the middle of the
  /// page.
  ///
  /// ⚠️ FOR DECISION SCREENS, NOT FOR LISTS. A screen with two cards and a
  /// sentence — "which of you is this?", "how should we reach you?" — filled
  /// its top 45% and left the rest white, which reads as a page that failed
  /// to finish loading rather than as one that is calm. A question screen
  /// keeps the default: its options can grow past the fold, and content that
  /// starts in the middle and runs off the bottom is worse than content that
  /// starts at the top.
  final bool center;
  final VoidCallback? onBack;
  final Widget? bottom;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: p.ground,
    body: SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Row(
              children: [
                if (onBack != null)
                  IconButton(
                    onPressed: onBack,
                    icon: Icon(Icons.arrow_back_rounded, color: p.ink1),
                  )
                else
                  const SizedBox(width: 48),
                const Spacer(),
                ?trailing,
              ],
            ),
          ),
          Expanded(
            // ⚠️ `Center` ROUND A `SingleChildScrollView`, NOT A SHRINK-WRAPPED
            // LIST. The first attempt set `shrinkWrap: true` on the ListView
            // and put a centred Column inside it, which changes how tall the
            // list is and not where its content starts — a shrink-wrapped
            // list still lays out from the top of its viewport, so the screen
            // looked exactly as before.
            //
            // `Center` gives the scroll view loose constraints, so it takes
            // its child's height and sits in the middle; when the child grows
            // past the viewport it fills it and scrolls as normal. One widget,
            // both behaviours, no measuring.
            child: center
                ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: body,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    children: body,
                  ),
          ),
          if (bottom != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: bottom,
            ),
        ],
      ),
    ),
  );
}

/// Eyebrow, the question in Fraunces, an optional line beneath.
class ObHead extends StatelessWidget {
  const ObHead({
    super.key,
    required this.p,
    required this.title,
    this.eyebrow,
    this.subtitle,
  });
  final V2Palette p;
  final String? eyebrow;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (eyebrow != null) ...[
        Text(
          eyebrow!.toUpperCase(),
          style: pvManrope(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
            color: p.ink3, // was p.action at 85% (2026-09-19)
          ),
        ),
        const SizedBox(height: 10),
      ],
      Text(
        title,
        style: pvFraunces(
          fontSize: 27,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.6,
          height: 1.15,
          color: p.ink1,
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 10),
        Text(
          subtitle!,
          style: pvManrope(fontSize: 15, height: 1.5, color: p.ink2),
        ),
      ],
      const SizedBox(height: 22),
    ],
  );
}

/// The one filled button per screen.
class ObPrimary extends StatelessWidget {
  const ObPrimary({
    super.key,
    required this.p,
    required this.label,
    this.onTap,
    this.leading,
  });
  final V2Palette p;
  final String label;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return ObPress(
      enabled: enabled,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? p.ink1 : p.surfaceAlt,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 10)],
              Text(
                label,
                style: pvManrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: enabled ? p.surface : p.ink3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The white outlined pill — the Google button, and any secondary commit.
/// Sesame / Wispr Flow's shape: the four-colour mark reads on white; on a
/// coloured fill it never did.
class ObSecondary extends StatelessWidget {
  const ObSecondary({
    super.key,
    required this.p,
    required this.label,
    this.onTap,
    this.leading,
  });
  final V2Palette p;
  final String label;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => ObPress(
    enabled: onTap != null,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: p.line, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Text(
              label,
              style: pvManrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: p.ink1,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// A quiet text link — "Not now", "Skip", "Edit".
class ObLink extends StatelessWidget {
  const ObLink({
    super.key,
    required this.p,
    required this.label,
    required this.onTap,
    this.center = true,
  });
  final V2Palette p;
  final String label;
  final VoidCallback onTap;
  final bool center;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(
      foregroundColor: p.ink2,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      minimumSize: Size.zero,
    ),
    child: Text(
      label,
      style: pvManrope(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: p.ink2,
      ),
    ),
  );
}

/// An outlined choice tile: title, optional line, optional icon; selected
/// state fills with surfaceAlt and inks up. Never the action colour.
class ObTile extends StatelessWidget {
  const ObTile({
    super.key,
    required this.p,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.compact = false,
  });

  final V2Palette p;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ObPress(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.fromLTRB(
          16,
          compact ? 13 : 16,
          16,
          compact ? 13 : 16,
        ),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? p.ink1 : p.line,
            width: selected ? 1.6 : 1.2,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: p.ground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: p.ink2),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: pvFraunces(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: p.ink1,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: pvManrope(
                        fontSize: 12.5,
                        height: 1.4,
                        color: p.ink3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, size: 20, color: p.ink1)
            else
              Icon(Icons.circle_outlined, size: 20, color: p.line),
          ],
        ),
      ),
    ),
  );
}

/// A grid card — the Claude Design's shape for Who and Stage: a tinted icon
/// well on top, title and line beneath, two to a row. The tint is
/// `v2BlockTint(hue)`, the same well the V3 door tiles use, so the colour the
/// design put in the cards is the app's own category colour. Selected state
/// inks the border, never fills with the action colour.
class ObGridCard extends StatelessWidget {
  const ObGridCard({
    super.key,
    required this.p,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.hue,
    required this.selected,
    required this.onTap,
    this.art,
    this.artHeight = 76,
  });

  final V2Palette p;
  final String title;
  final String subtitle;
  final IconData icon;

  /// A painting to fill the well instead of the icon. The icon stays as the
  /// required fallback rather than becoming optional, so a card can never end
  /// up with an empty well if an asset fails to decode.
  final ObArt? art;

  /// How tall the well is. 76 suits a four-up grid; the two-up "who" cards
  /// are twice the width and looked like a caption under a swatch at that
  /// height — a card's picture has to be worth looking at or it is decoration
  /// on a list item.
  final double artHeight;
  final double hue;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue, p);
    final deep = HSLColor.fromColor(
      tint,
    ).withSaturation(0.46).withLightness(0.34).toColor();
    return ObPress(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? p.ink1 : p.line,
              width: selected ? 1.8 : 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: artHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                clipBehavior: art == null ? Clip.none : Clip.antiAlias,
                child: art == null
                    ? Icon(icon, size: 28, color: deep)
                    : Image.asset(
                        obArtAsset(art!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, _, _) =>
                            Icon(icon, size: 28, color: deep),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 2,
                style: pvFraunces(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  height: 1.2,
                  color: p.ink1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: pvManrope(fontSize: 12, height: 1.35, color: p.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small outlined pill — chips on the date screen, multi-select options.
class ObPill extends StatelessWidget {
  const ObPill({
    super.key,
    required this.p,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final V2Palette p;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(999),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? p.ink1 : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? p.ink1 : p.line, width: 1.2),
      ),
      child: Text(
        label,
        style: pvManrope(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: selected ? p.surface : p.ink2,
        ),
      ),
    ),
  );
}

/// The give-back well: what she gets for answering (Monzo's "Good to know",
/// Flo's inline answer). SurfaceAlt, an action eyebrow, one paragraph.
class ObGiveBack extends StatelessWidget {
  const ObGiveBack({
    super.key,
    required this.p,
    required this.text,
    this.eyebrow = 'Good to know',
  });
  final V2Palette p;
  final String eyebrow;
  final String text;

  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOut,
    alignment: Alignment.topCenter,
    child: text.isEmpty
        ? const SizedBox(width: double.infinity)
        // No box (2026-09-19, DESIGN-SYSTEM §4.0 addendum): the give-back
        // sits between two hairlines, eyebrow in grey. Was a lavender well
        // with a violet eyebrow — kept for revert.
        : Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: p.line),
                bottom: BorderSide(color: p.line),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: p.ink3,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  text,
                  style: pvManrope(fontSize: 14, height: 1.5, color: p.ink1),
                ),
              ],
            ),
          ),
  );
}

/// A labelled field in the design system's field shape.
class ObField extends StatelessWidget {
  const ObField({
    super.key,
    required this.p,
    required this.label,
    required this.child,
    this.onTap,
  });
  final V2Palette p;
  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 11, 12, 11),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.line, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: pvManrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: p.ink3,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    ),
  );
}

/// The Google mark — the official four-colour G, inline so no asset pipeline
/// is needed. Duplicated from auth_flow_screen.dart (kept for revert there).
const String kGoogleMarkSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">'
    '<path fill="#FFC107" d="M43.611 20.083H42V20H24v8h11.303c-1.649 4.657-6.08 8-11.303 8-6.627 0-12-5.373-12-12s5.373-12 12-12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4 12.955 4 4 12.955 4 24s8.955 20 20 20 20-8.955 20-20c0-1.341-.138-2.65-.389-3.917z"/>'
    '<path fill="#FF3D00" d="M6.306 14.691l6.571 4.819C14.655 15.108 18.961 12 24 12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4 16.318 4 9.656 8.337 6.306 14.691z"/>'
    '<path fill="#4CAF50" d="M24 44c5.166 0 9.86-1.977 13.409-5.192l-6.19-5.238C29.211 35.091 26.715 36 24 36c-5.202 0-9.619-3.317-11.283-7.946l-6.522 5.025C9.505 39.556 16.227 44 24 44z"/>'
    '<path fill="#1976D2" d="M43.611 20.083H42V20H24v8h11.303c-.792 2.237-2.231 4.166-4.087 5.571l6.19 5.238C36.971 39.205 44 34 44 24c0-1.341-.138-2.65-.389-3.917z"/></svg>';

// =============================================================================
//  ADDED 2026-09-22 — the two pieces the V2 flow needed (ONBOARDING-V2 §1.2, §1.3)
// =============================================================================

/// A text field with NOTHING of its own — no box, no fill, no ring.
///
/// ⚠️ `border: InputBorder.none` IS NOT ENOUGH, and that is the whole reason
/// this exists. `border` is only the fallback; the app theme sets
/// `enabledBorder` and `focusedBorder` explicitly (app_theme.dart, an
/// `OutlineInputBorder` in `outlineVariant`) and those win. With `filled:
/// true` on top, a field that asked for no decoration drew a filled, rounded
/// pill INSIDE `ObField`'s own bordered card — a box in a box, which is what
/// the user caught on the walk (2026-09-22: "you see the UI bug around the
/// name, that pill appearing").
///
/// `ObField` already draws the container. The field inside it is just text.
InputDecoration obBareInput({required String hint, required TextStyle style}) =>
    InputDecoration(
      isDense: true,
      filled: false,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
      hintText: hint,
      hintStyle: style,
    );

/// The question block's progress: a named section over a filled bar.
///
/// ⚠️ NAMED, NOT JUST COUNTED. Noom's bar carries the section it belongs to,
/// and that is the difference between "3 of 4" (a chore with a length) and
/// "ABOUT YOUR PREGNANCY · 3 of 4" (a subject with an end). The label is what
/// makes the count feel like a conversation rather than a form.
class ObProgress extends StatelessWidget {
  const ObProgress({
    super.key,
    required this.p,
    required this.label,
    required this.step,
    required this.total,
  });

  final V2Palette p;
  final String label;
  final int step; // 1-based
  final int total;

  @override
  Widget build(BuildContext context) {
    final t = total <= 0 ? 0.0 : (step / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  color: p.ink3,
                ),
              ),
            ),
            Text(
              '$step of $total',
              style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: p.ink3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: t),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 4,
              backgroundColor: p.surfaceAlt,
              // Ink, not the action colour: this reports, it does not invite
              // a tap, and DESIGN-SYSTEM §4 spends violet only on things you
              // can act on.
              valueColor: AlwaysStoppedAnimation(p.ink1),
            ),
          ),
        ),
      ],
    );
  }
}

/// A beat: the app stops and says something back.
///
/// ⚠️ THE ANSWER HAS TO ANSWER BACK, AND A LINE IS NOT ALWAYS ENOUGH.
/// `ObOption.giveBack` already puts one line under a chosen option and that
/// was the right first move. But Headspace gives it a WHOLE SCREEN — "That's
/// great to hear" — and the difference is the difference between an app that
/// acknowledges an answer and an app that reacts to it. Three of these across
/// the flow, no more: a beat after every answer is a flow that will not stop
/// talking.
///
/// Deliberately has no back arrow and one button. A beat is not a decision.
class ObBeat extends StatelessWidget {
  const ObBeat({
    super.key,
    required this.p,
    required this.art,
    required this.title,
    required this.body,
    required this.cta,
    required this.onNext,
  });

  final V2Palette p;
  final ObArt art;
  final String title;
  final String body;
  final String cta;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: p.ground,
    body: Column(
      children: [
        ObBand(art: art, p: p, height: 320),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
            children: [
              Text(
                title,
                style: pvFraunces(
                  fontSize: 27,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.6,
                  height: 1.15,
                  color: p.ink1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                body,
                style: pvManrope(fontSize: 15.5, height: 1.55, color: p.ink2),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: ObPrimary(p: p, label: cta, onTap: onNext),
          ),
        ),
      ],
    ),
  );
}
