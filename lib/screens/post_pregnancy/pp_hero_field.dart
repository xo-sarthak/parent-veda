// =============================================================================
//  MOVED — this field is now shared by every stage.
// -----------------------------------------------------------------------------
//  The painter, and the long note explaining why the parenting hero has no
//  illustration in it, live in `lib/screens/v2/v3_hero_field.dart`.
//
//  It moved when TTC needed the same hero. The alternative was a second copy in
//  `lib/screens/ttc/`, and the copy would have been the wrong answer for the
//  reason the journal section already demonstrated: two screens holding
//  lookalikes drift apart without anyone deciding they should.
//
//  ⚠️ THIS FILE IS KEPT AS A FORWARD RATHER THAN DELETED — "comment out, never
//  delete", applied to a move. Anything still importing the old path keeps
//  working, and `PpHeroField` keeps its name here so no call site had to change
//  to make the move safe.
// =============================================================================

export '../v2/v3_hero_field.dart' show V3HeroField;

import '../v2/v3_hero_field.dart';

/// The parenting name for [V3HeroField]. Same widget, same painter.
typedef PpHeroField = V3HeroField;
