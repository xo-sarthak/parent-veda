// =============================================================================
//  BracketResolver — the one place that answers "may this be shown?"
// -----------------------------------------------------------------------------
//  ⚠️ THIS FILE EXISTS TO BE A CHOKEPOINT, NOT A CONVENIENCE.
//
//  The four-state model is only worth having if nothing can go around it. The
//  failure it guards against is specific and was found by walking the code:
//
//    · `global_search.dart` imports `product_data` directly
//    · `veda_index.dart` stamps every product and every tool into the Ask corpus
//    · `tools_hub_screen.dart` keeps its own list of 14 rows
//    · `post_pregnancy/explore_drawer.dart` keeps ~39 more
//
//  Every one of those can surface an item whose bracket marks it
//  `notApplicable`. Ask Veda answering a question about IVF with a product card
//  never touches the bracket screen at all — so a rule enforced only inside that
//  screen is a rule that does not exist.
//
//  So: anything that decides whether to show something asks HERE. The test that
//  keeps it honest lives in `test/bracket_model_test.dart`.
// =============================================================================

import '../data/brackets/parenting_brackets.dart';
import '../data/brackets/pregnancy_brackets.dart';
import '../data/brackets/skilling_brackets.dart';
import '../data/brackets/ttc_brackets.dart';
import '../models/bracket.dart';
import 'app_structure.dart';
import 'life_stage_store.dart';

/// Every bracket the app knows about, in workbook order within each stage.
///
/// All four stages are now declared.
///
/// ⚠️ SKILLING IS DECLARED AND ENTIRELY UNBUILT — eighty-four cells, not one of
/// them `live`. It is in this list on purpose rather than held back: the table
/// IS the plan, and keeping it out would mean the plan lived in a spreadsheet
/// where no test could reach it.
///
/// Everything that reads this list must therefore keep working when a stage
/// contributes zero live surfaces. That is already true of every consumer —
/// `liveSurfaceIds` returns empty, `canRender` returns false — but it is the
/// assumption to check first if something here ever behaves oddly.
List<Bracket> get kAllBrackets => [
      ...kPregnancyBrackets,
      ...kParentingBrackets,
      ...kTtcBrackets,
      ...kSkillingBrackets,
    ];

List<Bracket> bracketsFor(LifeStage stage) =>
    kAllBrackets.where((b) => b.stage == stage).toList(growable: false);

/// Null rather than a throw, and rather than a guess. An unknown id is a wiring
/// mistake, and the caller decides whether that is fatal — the wiring test makes
/// sure it never reaches a user.
Bracket? bracketById(String id) {
  for (final b in kAllBrackets) {
    if (b.id == id) return b;
  }
  return null;
}

/// Brackets related across stages — the continuity that stage-prefixed ids
/// deliberately give up. `pregnancy_mental_health` and a future
/// `parenting_mental_health` share a theme and nothing else.
List<Bracket> bracketsWithTheme(String theme) =>
    kAllBrackets.where((b) => b.theme == theme).toList(growable: false);

// -----------------------------------------------------------------------------
//  The questions everything else must ask
// -----------------------------------------------------------------------------

/// May this layer of this bracket produce any widget at all?
///
/// The ONLY correct way to decide whether to render a section. Note what it does
/// not do: it does not distinguish `notReady` from `notApplicable` for the
/// caller, because at the moment of rendering that distinction is irrelevant —
/// both produce nothing. The distinction matters to humans reading the table and
/// to whoever flips a flag later, which is why the reason is stored rather than
/// discarded.
bool canRender(Bracket b, BracketLayer layer) => b.layer(layer).isLive;

/// Whether a bracket forbids this layer permanently.
///
/// Exists for the leak test rather than for the UI: a hardcoded list somewhere
/// else in the app can ask "is this item's category one that its bracket has
/// refused?" and get a straight answer.
bool isRefused(Bracket b, BracketLayer layer) =>
    b.layer(layer).state == LayerState.notApplicable;

/// Every surface id this bracket can legitimately open, across all live layers.
///
/// Used by the wiring test: each of these must resolve through `homeFor()`, or a
/// door leads nowhere — the failure mode this repo has actually hit and written
/// a gate for.
Set<String> liveSurfaceIds(Bracket b) => {
      for (final l in b.liveLayers) ...b.layer(l).surfaceIds,
    };

/// Whether a surface id opens anything at all.
///
/// ⚠️ TWO WAYS TO BE VALID, AND THE SECOND ONE MATTERS FOR THE OTHER STAGES.
///
/// `app_structure.dart` is pregnancy-shaped: its `AppHome` is today · prepare ·
/// tools · calendar · community · profile, which is the pregnancy tab set.
/// Parenting's tabs are My Child · Brain · Tools · Community · Products, and
/// TTC's are different again. So `homeFor()` cannot be the only test of whether
/// a destination exists without forcing every stage through pregnancy's nav.
///
/// The honest question is not "which pregnancy tab owns this" — it is **"does
/// this open something"**. A surface answers yes if it is declared in
/// app_structure OR if `surface_router.dart` knows how to build its screen.
///
/// [routerKnows] is injected rather than imported so this file stays free of
/// screen imports; the test and the caller supply it.
bool surfaceResolves(String id, {bool Function(String)? routerKnows}) =>
    homeFor(id) != null || (routerKnows?.call(id) ?? false);

/// True when every live layer of every bracket points somewhere the app can
/// actually route to. Cheap enough to assert in a test, not meant for runtime.
bool allSurfacesResolve({bool Function(String)? routerKnows}) {
  for (final b in kAllBrackets) {
    for (final id in liveSurfaceIds(b)) {
      if (!surfaceResolves(id, routerKnows: routerKnows)) return false;
    }
  }
  return true;
}
