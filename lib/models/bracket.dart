// =============================================================================
//  Bracket — a problem a parent has, and what the app holds for it
// -----------------------------------------------------------------------------
//  THE MODEL BEHIND THE DOORS.
//
//  `parentveda-level-map-checklist.xlsx` defines 40 problem brackets across four
//  stages, each checked against seven layers. This file is that grid, typed.
//  `docs/BRACKET-AUDIT.md` is the audit that decides each cell's state, and
//  `docs/BRACKET-SCREEN.md` is what the screen does with it.
//
//  ⚠️ WHY LayerState HAS FOUR CASES AND NOT A BOOLEAN.
//
//  The workbook marks unavailable cells in red, and reading that as one "hidden"
//  flag loses a distinction that matters enormously. Counted across all 40
//  brackets: 22 cells say "Not a fit", 17 say "Not core", 13 say "Optional", 11
//  say "Rare", and about 5 name a real offer that simply is not built.
//
//  Those are not the same instruction. "Infertility & IVF → Products: Not a fit
//  (clinical)" must NEVER show a shopping prompt, however long the roadmap runs.
//  "Preconception → Course" is merely not built yet. Compile both to `hidden`
//  and the first person who reads the first as the second puts commerce exactly
//  where the workbook deliberately refused it — which is the filler its own Read
//  Me names as "the thing that sinks Mylo and iMumz on trust".
//
//  ⚠️ AND THE FILL COLOUR CANNOT BE TRUSTED ALONE. Fill and text disagree in 38
//  places sheet-wide, both directions. Four pregnancy cells carry "Not a fit"
//  with NO fill at all. The audit resolves every one of them by text.
//
//  ⚠️ STATE BELONGS TO THE BRACKET, NEVER TO THE USER. `landing_focus_test.dart`
//  enforces "personalisation changes order, never structure". If `notReady` ever
//  comes to mean "she has not paid", two axes have collapsed into one and the
//  rule is broken. Entitlement is a separate question asked separately.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../localization/app_language.dart';
import '../services/life_stage_store.dart';

/// The seven layers every bracket is checked against.
///
/// `extras` is a real layer, not a notes field. The workbook's own entries earn
/// it: a red-flag "when to call / rush" card is the most valuable single item
/// under Complications, and it is not a tool, a course or a product. Folding
/// these into the six would bury the most distinctive thing in several brackets.
///
/// ⚠️ ADDING AN EIGHTH IS EXPENSIVE — every exhaustive `switch` over this enum
/// has to grow a case. That is why `extras` was settled before this file existed
/// rather than after.
enum BracketLayer { content, activities, tools, products, course, consult, extras }

/// Whether a layer ships, and if not, which kind of "no" it is.
enum LayerState {
  /// Ships now. **A resolver must exist** — see `bracket_resolver.dart`. A `live`
  /// cell with nothing behind it is worse than an absent one: it promises a
  /// section and opens to nothing.
  live,

  /// Real, planned, not built. One flag flips it on when the content arrives.
  /// Renders nothing meanwhile.
  notReady,

  /// Real, but it lives on another surface — usually riding the week spine
  /// rather than sitting in a bracket. Renders nothing HERE.
  notCore,

  /// Never. The workbook refused it, with a reason.
  ///
  /// ⚠️ Renders **nothing at all** — no heading, no empty state, no invitation.
  /// This is a deliberate exception to `CLAUDE.md`'s "a feature is never hidden;
  /// empty sections render an invitation", and the exception is the whole point:
  /// an invitation under `Infertility & IVF → Products` is a shopping prompt
  /// beside a clinical grief.
  notApplicable,
}

/// One cell of the grid.
@immutable
class BracketLayerSpec {
  const BracketLayerSpec({
    required this.state,
    required this.reason,
    this.surfaceIds = const [],
    this.heading,
  });

  /// Convenience for the common case: it ships, and here is what serves it.
  const BracketLayerSpec.live(List<String> surfaces, {this.heading})
      : state = LayerState.live,
        reason = '',
        surfaceIds = surfaces;

  /// Overrides the layer's default section heading.
  ///
  /// EXISTS FOR `extras`, WHICH HAS NO HONEST GENERIC NAME. "Also here" tells
  /// her nothing; "When the report comes back" tells her everything. The other
  /// six layers share a heading across all brackets because they genuinely are
  /// the same kind of thing each time — Extras is the one that is different in
  /// every bracket, which is exactly why the workbook gave it its own column.
  final LocalizedText? heading;

  final LayerState state;

  /// The workbook's own words, verbatim — "Not a fit", "Not core (rides week
  /// spine)", "Mood check". Kept so the next person can see WHY a section is
  /// absent without opening the spreadsheet, and so a `notReady` can be told
  /// from a `notApplicable` by reading rather than by guessing.
  final String reason;

  /// Ids from `app_structure.dart` that this layer opens.
  ///
  /// This is the join between the workbook and the app, and the thing the wiring
  /// test asserts: every id here must resolve through `homeFor()`, or the door
  /// leads nowhere.
  final List<String> surfaceIds;

  bool get isLive => state == LayerState.live;

  /// True when the layer must produce no widget of any kind.
  bool get rendersNothing => state != LayerState.live;
}

/// A problem bracket — one door on the grid, one screen behind it.
@immutable
class Bracket {
  const Bracket({
    required this.id,
    required this.stage,
    required this.theme,
    required this.label,
    required this.title,
    required this.blurb,
    required this.hue,
    required this.layers,
  });

  /// ⚠️ STAGE-PREFIXED, ON PURPOSE — `pregnancy_mental_health`, not
  /// `mental_health`.
  ///
  /// Several brackets recur across stages, and a shared id would claim a
  /// sameness that is not real: prenatal anxiety and postpartum depression are
  /// different subjects with different content, different clinicians and
  /// different risks. A global id would also carry a saved item across a
  /// transition into a bracket whose material does not match it.
  ///
  /// Continuity, where we want it, comes from [theme] instead.
  final String id;

  final LifeStage stage;

  /// The cross-stage link that [id] deliberately does not provide — 'nutrition',
  /// 'mental_health'. Two brackets sharing a theme are *related*, not the same.
  final String theme;

  /// The short door label. ⚠️ At four columns on a 360dp screen a tile is about
  /// 73dp, so this has to be short — "Complications", not "Complications &
  /// conditions". [title] carries the full name on the screen itself.
  final LocalizedText label;

  final LocalizedText title;

  /// One line, from the workbook's Content cell. What this bracket is about.
  final LocalizedText blurb;

  /// Its hue on the controlled-pastel wheel. Saturation and lightness are fixed
  /// elsewhere; only hue varies, which is what lets ten colours read as one
  /// family. See `v2BlockTint`.
  final double hue;

  /// All seven layers, always. ⚠️ No defaulting — a bracket that omits a layer
  /// would silently inherit someone's assumption, and the assumption people make
  /// is `live`.
  final Map<BracketLayer, BracketLayerSpec> layers;

  BracketLayerSpec layer(BracketLayer l) =>
      layers[l] ??
      // Unreachable if the completeness test passes, and deliberately the
      // safest possible answer rather than a throw: an un-declared layer shows
      // nothing instead of guessing that it ships.
      const BracketLayerSpec(
          state: LayerState.notApplicable, reason: 'undeclared');

  Iterable<BracketLayer> get liveLayers =>
      BracketLayer.values.where((l) => layer(l).isLive);
}
