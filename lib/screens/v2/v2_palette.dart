// =============================================================================
//  V2Palette — five grounds, one loud colour, for the Focus experiment ONLY
// -----------------------------------------------------------------------------
//  WHY THIS EXISTS RATHER THAN A CHANGE TO AppTheme.
//
//  AppTheme holds 71 `static const Color` values. Switching palette at runtime
//  would mean converting every one of them to a lookup, which touches the whole
//  app — an unacceptable risk to a shipped product for the sake of a
//  comparison. So the comparison lives here instead: a plain object that only
//  home_focus_screen.dart reads, with a chip row to switch between five
//  directions on a real phone.
//
//  Nothing outside the Focus experiment imports this. When a direction wins,
//  AppTheme gets migrated properly as its own piece of work, and this file is
//  deleted.
//
//  THE ONE RULE ALL FIVE OBEY: one loud colour.
//  `action` is the only saturated value in a palette and it means exactly one
//  thing — "you can act on this". Every other colour is a quiet ground or ink.
//  That is docs/DESIGN-LAYER.md §2, and it is why every palette below shares
//  the same violet: the variable under test is the GROUND, not the accent.
//
//  ENGLISH ONLY, like the screen that uses it. See the header of
//  home_focus_screen.dart.
// =============================================================================

import 'package:flutter/material.dart';

@immutable
class V2Palette {
  const V2Palette({
    required this.id,
    required this.name,
    required this.blurb,
    required this.ground,
    required this.surface,
    required this.surfaceAlt,
    required this.line,
    required this.ink1,
    required this.ink2,
    required this.ink3,
    required this.action,
  });

  /// Short id, used for the chip label and for reading a screenshot back later.
  final String id;
  final String name;

  /// One line, shown under the chip row, so a screenshot taken three days from
  /// now still says which direction it was.
  final String blurb;

  /// The page behind everything.
  final Color ground;

  /// A raised card.
  final Color surface;

  /// A quiet block — inset panels, the second row of the grid.
  final Color surfaceAlt;

  /// Hairlines. Never a shadow: elevation in this system is a line, not a blur.
  final Color line;

  final Color ink1; // primary text
  final Color ink2; // secondary text
  final Color ink3; // metadata, disabled

  /// THE loud colour. Violet in all five, deliberately.
  final Color action;

  Color get onAction => Colors.white;
}

// -----------------------------------------------------------------------------
//  The five directions
// -----------------------------------------------------------------------------

/// What ships today. Here so the delta is visible rather than remembered.
///
/// ⚠️ The ground and surfaceAlt were desaturated on 2026-08-16, from S36/S33 to
/// S16. The old values are kept in the comment beside each so the delta is
/// readable rather than archaeological:
///
///   ground     #F3EEF7  H273 S36 L95   ->  #F5F3F6  H280 S16 L96
///   surfaceAlt #ECE5F2  H272 S33 L92   ->  #EDEAF0  H280 S16 L93
///
/// The reason is the one the whole design system now rests on: **a brand colour
/// is not an interface colour.** The inks in this same palette sit at S7–S12 —
/// correctly, because text should carry no hue of its own. The ground sat at
/// S36, three to five times more saturated than the inks it holds, so every
/// screen arrived pre-tinted and every hue placed on top of it (the six door
/// tints, a photo, a green success state) had to fight a violet cast to read as
/// itself. Zepto's brand is purple and its shelves are white for exactly this
/// reason: the loud colour has to be spendable, and you cannot spend a colour
/// that is already everywhere.
///
/// Lightness was deliberately NOT raised while dropping saturation. At L96 the
/// ground still sits four lightness points below `surface` (#FFFFFF), which is
/// what makes a white card read as a card without needing a shadow — this system
/// draws elevation as a line, so that four-point gap is the only separation the
/// card gets. Pushing to L97/L98 to "brighten" it would have removed the one
/// thing the ground is doing. Brightness in this app comes from the hue wells,
/// the hero field and the photography, none of which changed here.
const _baseline = V2Palette(
  id: 'baseline',
  name: 'Baseline',
  blurb: 'What ships today — near-neutral ground, violet spent on purpose.',
  // ⚠️ SETTLED ON A DEVICE, 2026-08-17. Four candidate grounds were driven on
  // a real phone across both homes and the pixels were sampled:
  //
  //   ground      page      gap to a white card
  //   White       #FFFFFF   +0.8 L   <- no edge at all
  //   Soft        #FCFCFD   +1.8 L
  //   Near        #FAFAFB   +2.6 L
  //   Current     #F5F3F6   +4.9 L   <- chosen
  //
  // Cards in this app are pure white, and below roughly 2–3 lightness points a
  // card stops having an edge on a phone — worst on the cheap screens most of
  // our users have. At pure white the gap is 0.8: the card and the page are the
  // same surface.
  //
  // ⚠️ AND THE TINT IS NOT AN OUTLIER. iOS's grouped background is #F2F2F7 —
  // H240, S23%. Notion's is #F7F6F3 — H45, S20%. Ours is H280 S14%: the LEAST
  // saturated of the three. Practically nobody ships a neutral grey.
  //
  // What made the app read duller than a shopping app was never the ground; it
  // was that our content stops carrying colour halfway down the page. A whiter
  // page would have removed the last structure rather than adding brightness.
  ground: Color(0xFFF5F3F6), // was 0xFFF3EEF7 (S36)
  surface: Color(0xFFFFFFFF),
  surfaceAlt: Color(0xFFEDEAF0), // was 0xFFECE5F2 (S33)
  line: Color(0x14000000),
  ink1: Color(0xFF201C24),
  ink2: Color(0xFF5B5464),
  // ⚠️ WAS #8B8494 AND FAILED WCAG AA. Measured 3.27:1 against this ground;
  // AA for normal-size text needs 4.5:1. It carries metadata, timestamps,
  // chevrons, "4 min · read" — and the product-card caveat line — all at
  // 11–12.5px, which is exactly the size the 4.5 threshold exists for.
  //
  // #6F6878 measures 4.85:1. It stays the quietest tier by a clear margin
  // (ink2 is 6.57:1, ink1 15.19:1), so the three-tier hierarchy survives; it
  // is simply no longer illegible to anyone whose close vision has shifted.
  //
  // ⚠️ THE GROUND WAS NEVER THE PROBLEM. On pure white the old value measured
  // 3.60:1 — still failing. Chasing a whiter page would not have fixed this,
  // and the question that found it was about the tint.
  ink3: Color(0xFF6F6878),
  action: Color(0xFF6A30B6),
);

/// A — warm paper. Same violet, moved off lavender onto unbleached ground.
const _warmPaper = V2Palette(
  id: 'A',
  name: 'Warm paper',
  blurb: 'Unbleached bone and clay. Warmth from temperature, not hue.',
  ground: Color(0xFFFDFBF7),
  surface: Color(0xFFFFFDF9),
  surfaceAlt: Color(0xFFF1EBE0),
  line: Color(0xFFDDD3C2),
  ink1: Color(0xFF241E2B),
  ink2: Color(0xFF4A4351),
  ink3: Color(0xFF8A828F),
  action: Color(0xFF6A30B6),
);

/// C — the current direction, tightened. Cooler and cleaner than baseline,
/// with the lavender cast taken out of the neutrals.
const _coolClean = V2Palette(
  id: 'C',
  name: 'Cool & clean',
  blurb: 'Today’s direction with the lavender cast removed.',
  ground: Color(0xFFFAFAFC),
  surface: Color(0xFFFFFFFF),
  surfaceAlt: Color(0xFFF2F2F7),
  line: Color(0xFFE5E5EC),
  ink1: Color(0xFF16161A),
  ink2: Color(0xFF55555F),
  ink3: Color(0xFF8A8A94),
  action: Color(0xFF6A30B6),
);

/// D — warmer and earthier than A. The riskiest of the five: clay can fight
/// violet, which is exactly what looking at it is meant to settle.
const _clay = V2Palette(
  id: 'D',
  name: 'Clay',
  blurb: 'Earthier and hotter than warm paper. Terracotta ground.',
  ground: Color(0xFFF7EFE9),
  surface: Color(0xFFFFFAF6),
  surfaceAlt: Color(0xFFEFE1D7),
  line: Color(0xFFDEC9BA),
  ink1: Color(0xFF2A211C),
  ink2: Color(0xFF57483F),
  ink3: Color(0xFF8F7E71),
  action: Color(0xFF6A30B6),
);

/// E — stage temperature (Flo's model): each life stage carries its own warmth
/// while structure, type and behaviour stay identical.
///
/// A LIMITATION WORTH STATING: this screen is pregnancy, so E can only show
/// pregnancy's assigned warmth. Its actual argument — that TTC, pregnancy and
/// parenting each feel different while staying one product — cannot be judged
/// from one screen. See docs/V2-BUILD-PLAN.md §6.
const _stageWarm = V2Palette(
  id: 'E',
  name: 'Stage warmth',
  blurb: 'Pregnancy’s own temperature. Each stage would differ.',
  ground: Color(0xFFFCF0E8),
  surface: Color(0xFFFFF8F3),
  surfaceAlt: Color(0xFFF8E3D6),
  line: Color(0xFFEBCDBA),
  ink1: Color(0xFF2B1F18),
  ink2: Color(0xFF5A473C),
  ink3: Color(0xFF8B7466),
  action: Color(0xFF6A30B6),
);

const List<V2Palette> kV2Palettes = [
  _baseline,
  _warmPaper,
  _coolClean,
  _clay,
  _stageWarm,
];

// -----------------------------------------------------------------------------
//  Block grounds
// -----------------------------------------------------------------------------

/// A ground for a hero tile, given a hue.
///
/// SATURATION AND LIGHTNESS ARE FIXED; ONLY HUE VARIES. That is the whole
/// technique — six different colours that still read as one family, because the
/// eye reads a palette as consistent when its *weight* is consistent, not its
/// hue. Vary all three and you get the Tools hub, where seven accents shout at
/// once.
///
/// Lightness lifts slightly on the cool grounds: the same tint that sits
/// comfortably on warm paper looks muddy on cool white.
Color v2BlockTint(double hue, V2Palette p) {
  final cool = p.id == 'baseline' || p.id == 'C';
  return HSLColor.fromAHSL(1, hue, cool ? 0.32 : 0.30, cool ? 0.91 : 0.88)
      .toColor();
}

/// The six hues, in grid order.
///
/// Assigned by MEANING, not by prettiness — clinical things get the cool end,
/// bodily and warm things the warm end. That is why Scans is the only blue on
/// the grid and why it is the one tile you find without reading.
class V2BlockHues {
  static const practice = 104.0; // sage — calm, ritual
  static const week = 26.0; // peach — growth
  static const scans = 206.0; // blue-grey — clinical, and the only cool tile
  static const read = 42.0; // sand
  static const watch = 344.0; // dusty rose
  static const ask = 268.0; // soft violet, tying back to the brand
}

// -----------------------------------------------------------------------------
//  THE GROUND COMPARISON — how white is the page?
// -----------------------------------------------------------------------------
//  ⚠️ THIS EXISTS BECAUSE OF ONE OBSERVATION THAT WAS RIGHT.
//
//  Held next to Zepto in the app switcher, our page read grey and theirs read
//  bright. Measured: theirs is pure #FFFFFF; ours was #F5F3F6.
//
//  The earlier reasoning for a tinted ground was sound and incomplete: keep a
//  few lightness points between ground and card, and a white card reads as a
//  card without needing a shadow. True — but it assumes separation MUST come
//  from lightness. Zepto proves the other model: a white page, and cards
//  separated by a hairline, a tinted shadow, and photography.
//
//  Both work. They are different products, not better and worse. So this is a
//  comparison rather than an argument, and it has to be seen on a phone.
//
//  ⚠️ AS THE GROUND APPROACHES WHITE, THE CARD TREATMENT MUST CHANGE WITH IT.
//  At #FFFFFF a white card on a white page is invisible, so each option below
//  carries its OWN line strength and its own `surfaceAlt`. Swapping only the
//  ground hex would have made the brightest option look broken and lost the
//  comparison for the wrong reason.
enum GroundOption {
  /// Pure white. The Zepto / Amazon / Myntra model — brightest, and cards must
  /// earn their edges from a hairline rather than a lightness step.
  paperWhite,

  /// Barely off-white. Reads white; keeps one lightness point in hand.
  softWhite,

  /// Near-white with a whisper of the brand hue.
  warmGrey,

  /// What ships today — #F5F3F6, S16.
  current,
}

class GroundSpec {
  const GroundSpec(this.label, this.ground, this.surfaceAlt, this.line,
      this.containerHigh);
  final String label;
  final Color ground;
  final Color surfaceAlt;

  /// One step darker than [surfaceAlt] — chips, inset rows, ring tracks.
  /// AppTheme's `surfaceContainerHigh` maps here.
  final Color containerHigh;

  /// ⚠️ STRONGER AS THE GROUND GETS WHITER. On a white page the hairline is
  /// the only thing telling her where a card ends.
  final Color line;
}

const Map<GroundOption, GroundSpec> kGrounds = {
  GroundOption.paperWhite: GroundSpec('White', Color(0xFFFFFFFF),
      Color(0xFFF4F2F6), Color(0x1F000000), Color(0xFFEAE7EE)),
  GroundOption.softWhite: GroundSpec('Soft', Color(0xFFFCFCFD),
      Color(0xFFF2F0F4), Color(0x1A000000), Color(0xFFE8E5EC)),
  GroundOption.warmGrey: GroundSpec('Near', Color(0xFFFAFAFB),
      Color(0xFFEFEDF2), Color(0x17000000), Color(0xFFE6E3EA)),
  GroundOption.current: GroundSpec('Current', Color(0xFFF5F3F6),
      Color(0xFFEDEAF0), Color(0x14000000), Color(0xFFE6DEED)),
};

// -----------------------------------------------------------------------------
//  The switch
// -----------------------------------------------------------------------------

/// Deliberately NOT persisted.
///
/// Every launch starts at Baseline, so a comparison always begins from what
/// ships rather than from whatever was left selected. It is a sandbox control,
/// not a preference, and persisting it would make it feel like a setting the
/// product supports.
class V2PaletteStore extends ChangeNotifier {
  V2PaletteStore._();
  static final V2PaletteStore instance = V2PaletteStore._();

  V2Palette _current = _baseline;

  /// Which ground is on screen. Defaults to what ships.
  GroundOption _ground = GroundOption.current;
  GroundOption get ground => _ground;

  /// ⚠️ EVERY SCREEN READS THIS, so switching the ground repaints the whole app
  /// without a single per-screen edit. That is the only way a comparison like
  /// this is worth running: if it only changed one screen, it would be
  /// comparing a screen rather than a product.
  V2Palette get current {
    final g = kGrounds[_ground]!;
    return V2Palette(
      id: _current.id,
      name: _current.name,
      blurb: _current.blurb,
      ground: g.ground,
      surface: _current.surface,
      surfaceAlt: g.surfaceAlt,
      line: g.line,
      ink1: _current.ink1,
      ink2: _current.ink2,
      ink3: _current.ink3,
      action: _current.action,
    );
  }

  void set(V2Palette p) {
    if (identical(p, _current)) return;
    _current = p;
    notifyListeners();
  }

  /// The spec behind whatever ground is on screen. `AppTheme` reads this so
  /// Classic and every other AppTheme screen answer to the same switch.
  GroundSpec get groundSpec => kGrounds[_ground]!;

  void setGround(GroundOption g) {
    if (g == _ground) return;
    _ground = g;
    notifyListeners();
  }
}
