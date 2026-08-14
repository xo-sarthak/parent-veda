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
const _baseline = V2Palette(
  id: 'baseline',
  name: 'Baseline',
  blurb: 'What ships today — cool lavender ground.',
  ground: Color(0xFFF3EEF7),
  surface: Color(0xFFFFFFFF),
  surfaceAlt: Color(0xFFECE5F2),
  line: Color(0x14000000),
  ink1: Color(0xFF201C24),
  ink2: Color(0xFF5B5464),
  ink3: Color(0xFF8B8494),
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
  V2Palette get current => _current;

  void set(V2Palette p) {
    if (identical(p, _current)) return;
    _current = p;
    notifyListeners();
  }
}
