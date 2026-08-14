// =============================================================================
//  V3GarbhSection — Garbh Sanskar as one thing, not three loose cards
// -----------------------------------------------------------------------------
//  WHAT WAS WRONG, AND THE TEST THAT CAUGHT IT.
//
//  The first cut put the practice, the story and the talk prompt in three
//  separate cards under a small heading. Asked whether a mother could tell they
//  belonged together, the honest answer was: they are related because I know
//  they are, not because anything on screen says so. That is the test — is it
//  clear because she can SEE it, or because the person who built it can?
//
//  It was also stripped. The shipped Classic module carries six things this had
//  dropped: its own accent, a TYPE badge (Meditation / Affirmation / Raga, so
//  she knows what today actually is), an explainer, playback, the affirmation,
//  and a keep action. Removing most of a feature and keeping the title is how a
//  flagship ends up looking like filler.
//
//  WHAT THIS DOES INSTEAD, and which principle each move comes from:
//
//  · ONE CONTAINER. Signifiers: things inside a boundary are read as related,
//    which is the cheapest way to say "these belong together" without a
//    sentence explaining it.
//  · AN IMAGE HEADER WITH THE NAME ON IT. Hierarchy: an image is the fastest
//    scanning cue there is, and the name at display size is what makes this
//    read as Garbh Sanskar rather than as a card that happens to mention it.
//  · A GRADIENT, NOT A FLAT SCRIM, so the photograph survives under the type.
//  · THE TYPE BADGE IS BACK — the single most useful fact on the block.
//  · "THEN, IF YOU HAVE TIME" above the two smaller pieces. It names the
//    relationship (these come after) AND removes the obligation (if you have
//    time), which is the product's whole position stated in five words.
//
//  THE ACCENT IS TERTIARY, NOT AN INVENTED HUE. The earlier version used a
//  sage green pulled from the 110dp block-tint scale, which belonged to nothing.
//  Classic gives this section saffron; #C9831F sits in the tertiary #7A4600
//  family, and DESIGN-LAYER already assigns tertiary to structural warmth. The
//  warm, rooted section taking the warm, rooted colour is the palette working,
//  not an exception to it.
//
//  ENGLISH ONLY via `.en` — see v2_sections.dart.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/home_day.dart';
import '../../theme/pv_fonts.dart';
import 'v2_palette.dart';

/// Garbh Sanskar's own accent. Tertiary family, warmer and lighter — the same
/// colour Classic already uses for this section.
const Color kGarbhAccent = Color(0xFFC9831F);

const _kGarbhHeaderImage =
    'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=900&h=520&fit=crop';

class V3GarbhSection extends StatelessWidget {
  const V3GarbhSection({
    super.key,
    required this.day,
    required this.p,
    required this.rows,
    this.onAbout,
  });

  final HomeDay day;
  final V2Palette p;
  final List<GarbhPillarRow> rows;
  final VoidCallback? onAbout;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ---- The header: photograph, name, and what today is ----------------
        SizedBox(
          height: 148,
          child: Stack(fit: StackFit.expand, children: [
            Image.network(_kGarbhHeaderImage,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(color: kGarbhAccent.withValues(alpha: 0.18))),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0x40000000), Color(0xD9000000)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('GARBH SANSKAR',
                        style: pvManrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                            color: const Color(0xFFF0C078))),
                    const Spacer(),
                    // The explainer. Classic has one; a section named in
                    // Sanskrit on a screen that may be read in English needs a
                    // door to "what is this".
                    InkWell(
                      onTap: onAbout,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.55)),
                        ),
                        child: Text('i',
                            style: pvFraunces(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Colors.white)),
                      ),
                    ),
                  ]),
                  const Spacer(),
                  Text('Your practice for today',
                      style: pvFraunces(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                          letterSpacing: -0.6,
                          color: Colors.white)),
                  // NO PROGRESS LINE, and that is the decision rather than an
                  // omission. It read "3 to do today", which is a to-do list
                  // wearing a practice's clothes — and this product's rule is
                  // that nothing on screen may be waiting to be cleared. The
                  // per-row tick still answers "did I do this"; what is gone is
                  // the tally that turns three calm practices into a score.
                ],
              ),
            ),
          ]),
        ),

        // ---- THE THREE PILLARS ----------------------------------------
        //
        // Shravan, Samvad & Vichara, Kriya — the three rows the shipped card
        // carries, and the reason "Read to your baby" and "Talk to your baby"
        // do not appear here. Samvad IS the conversation pillar; showing a
        // talk-to-your-baby card beside it was showing the same thing twice
        // under two names, which is worse than showing it once.
        //
        // Each row is a DOOR with today's item named on it. A daily section is
        // used every day, so the whole value is being able to see what today
        // holds and reach it in one tap — not being told a category exists.
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          child: Column(children: [
            for (final row in rows) ...[
              _PillarRow(row: row, p: p),
              if (row != rows.last) const SizedBox(height: 8),
            ],
          ]),
        ),
      ]),
    );
  }
}

/// One pillar's worth of what today holds.
@immutable
class GarbhPillarRow {
  const GarbhPillarRow({
    required this.name,
    required this.tag,
    required this.today,
    required this.icon,
    required this.accent,
    required this.done,
    this.image,
    this.onTap,
  });

  final String name;
  final String tag;

  /// A PHOTOGRAPH OF THE PRACTICE, not a glyph for the category.
  ///
  /// The icons were doing the job of saying "there is a thing here"; they were
  /// not doing the job of saying what kind of thing. A tanpura, two hands on a
  /// bump and a seated breath are recognisable before the words are read, and
  /// they carry the one quality an icon cannot: that a real person does this.
  /// Falls back to [icon] if the image fails, so a dead URL costs a glyph
  /// rather than a hole.
  final String? image;

  /// TODAY's item, named. The row is worth tapping because it says what is
  /// behind it, not because it names a category.
  final String today;

  final IconData icon;
  final Color accent;
  final bool done;
  final VoidCallback? onTap;
}

class _PillarRow extends StatelessWidget {
  const _PillarRow({required this.row, required this.p});
  final GarbhPillarRow row;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: row.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Row(children: [
            // The pillar mark. Its accent appears ONLY here, at 46px — the
            // pillars have their own colours and letting them fill anything
            // larger would put five hues on one card.
            Container(
              width: 46,
              height: 46,
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: row.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(13),
              ),
              child: row.image == null
                  ? Icon(row.icon, size: 20, color: row.accent)
                  : Image.network(row.image!,
                      fit: BoxFit.cover,
                      width: 46,
                      height: 46,
                      errorBuilder: (_, _, _) =>
                          Icon(row.icon, size: 20, color: row.accent)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ⭐ THE SANSKRIT NAME CARRIES THE ACCENT; the English gloss
                    // does not. Both were grey and both read as filing labels,
                    // so the thing that makes this section *Garbh Sanskar*
                    // rather than a generic practice list was the quietest text
                    // on the card. Colour is doing semantic work here — it says
                    // "this word is the tradition's, not ours" — which is the
                    // one job DESIGN-LAYER lets a non-violet hue take.
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: row.name.toUpperCase(),
                            style: pvManrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.3,
                                color: row.accent)),
                        TextSpan(
                            text: '  ·  ${row.tag.toUpperCase()}',
                            style: pvManrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: p.ink3)),
                      ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(row.today,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvFraunces(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            letterSpacing: -0.35,
                            color: p.ink1)),
                  ]),
            ),
            const SizedBox(width: 10),
            // Done state as a signifier, not a score. A filled tick says this
            // one is finished; an empty ring says it is still there. Neither
            // counts anything or asks to be cleared.
            row.done
                ? Icon(Icons.check_circle_rounded, size: 22, color: row.accent)
                : Container(
                    width: 21,
                    height: 21,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: p.line, width: 1.6),
                    ),
                  ),
          ]),
        ),
      );
}
