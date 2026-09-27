// =============================================================================
//  TTC read blocks: what a TTC read carries that the shared reader does not
// -----------------------------------------------------------------------------
//  Written 2026-09-26 from the TTC gap analysis ("ask age once", "a drawing of
//  how a line darkens").
//
//  ⚠️ DATA ONLY, NO WIDGETS. A read file puts one of these in a section's
//  `PvReadSection.custom`; the reader carries it as an opaque `Object` and
//  hands it back through `PvReaderScreen.customBlock`, where
//  `ttcReadCustomBlock` (lib/screens/ttc/ttc_read_blocks_view.dart) turns it
//  into the widget. Keeping the marker widget-free is what lets the reads stay
//  plain data files the tests can load without a screen.
//
//  ⚠️ ONLY THE TTC OPENERS PASS THE RENDERER: the surface router's
//  `ttc_read/<id>` and `openTtcArticle`. Any other reader that meets one of
//  these draws nothing for it (the reader's documented behaviour), so the
//  prose around a block must read whole without it.
// =============================================================================

import 'package:flutter/foundation.dart';

/// "How old are you?", asked once, with one tap, inside a read.
///
/// Writes the same saved answer the fertility-help tool writes
/// (`TtcFertilityHelpStore.setAgeBand`), so it is never asked twice.
@immutable
class TtcAgeBandAskBlock {
  const TtcAgeBandAskBlock();
}

/// A drawing of four test windows over six days, the test line going from
/// very faint to clear beside a solid control line.
@immutable
class TtcFaintLineDrawingBlock {
  const TtcFaintLineDrawingBlock();
}
