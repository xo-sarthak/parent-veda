// =============================================================================
//  PpBlock / PpPage / PpContentPage — the mandated page formats, built once
// -----------------------------------------------------------------------------
//  ⚠️ THIS FILE EXISTS BECAUSE ELEVEN SECTION SPECS ARRIVED AT ONCE AND EVERY
//  ONE OF THEM MANDATES THE SAME SHORT LIST OF PAGE SHAPES.
//
//  Each spec brackets a FORMAT beside every page and says it is not optional:
//
//    "The FORMAT of each page is specified in brackets and is mandatory: build
//     it as that type (chart-card, comparison table, step-list, cards, short
//     article, flagged callout, or tool), not as generic prose."
//
//  and separately:
//
//    "Do not render any page as one long undifferentiated paragraph."
//
//  Eleven sections built independently would each grow their own step-list,
//  their own callout, their own comparison table — and they would not match.
//  That is not a hypothetical: this repo already had three bottom navigation
//  bars for exactly this reason, each fixed once by a different pass, and it
//  took a shared `PvNavBar` to end it. The cheapest moment to avoid the same
//  outcome is before the eleven sections exist, not after.
//
//  ⚠️ SO A PAGE IS DATA, NOT LAYOUT. A section author writes a `PpPage` — a
//  title and a list of blocks — and never touches padding, type or colour. The
//  consequences are worth being explicit about, because they are the whole
//  point:
//
//  * **Eleven sections cannot drift**, because there is one renderer. Fix the
//    step-list's spacing once and every step-list in the parenting app moves.
//  * **A format becomes checkable.** "Every article has a when-to-worry callout"
//    is a test over data (`blocks.whereType<PpCallout>()`), not a reading of
//    eleven screens. `test/pp_content_test.dart` does exactly this.
//  * **Content can be edited without touching code paths**, which is the repo's
//    existing habit (`pp_*_data.dart` files beside screens that render them) and
//    also what makes a later move to Directus possible at all.
//  * The cost: a page that genuinely needs a bespoke layout has to either add a
//    block type here or drop out of this model. That is deliberate friction —
//    it makes "I'll just hand-build this one" a visible decision rather than the
//    path of least resistance.
//
//  ⚠️ WHAT THIS IS NOT: a generic CMS. The block list is closed and short on
//  purpose. Every type below appears in the specs by name; nothing is here
//  speculatively. A block model that can express more shapes than the product
//  has is a bug surface, which is the same reason this repo rejects config
//  objects with dozens of flags.
//
//  ⚠️ ENGLISH ONLY FOR NOW, per the user's standing instruction. Every string is
//  a plain `String` rather than `LocalizedText` — see the note on that at the
//  foot of this file, because it is a real decision with a real cost.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_placeholders.dart';
import '../v2/v2_palette.dart';

// =============================================================================
//  THE BLOCKS
// =============================================================================

/// One piece of a content page.
///
/// Deliberately a plain base class rather than a sealed union: Dart's exhaustive
/// `switch` over a sealed type would be nice, but the renderer already has a
/// default arm and a closed hierarchy here would mean every section that adds a
/// block type edits this file's `switch` too. The type test in `_render` is the
/// one place that needs to know the full list.
abstract class PpBlock {
  const PpBlock();
}

/// The warm 2-to-3-line opening every page template requires.
///
/// Its own type rather than a `PpArticle` with a flag, because every spec asks
/// for it by name and in a fixed position, and a test can then assert a page
/// opens with one instead of dropping the reader straight into steps.
class PpIntro extends PpBlock {
  const PpIntro(this.text);
  final String text;
}

/// `[SHORT ARTICLE]` / `[ARTICLE]` — real prose, in paragraphs.
///
/// ⚠️ A LIST OF PARAGRAPHS, NOT ONE STRING WITH `\n\n` IN IT. The spec rule is
/// "do not render any page as one long undifferentiated paragraph", and a single
/// string makes breaking it optional. A list makes the paragraph the unit, so
/// "no paragraph is longer than N characters" is checkable.
class PpArticle extends PpBlock {
  const PpArticle(this.paragraphs, {this.heading});
  final String? heading;
  final List<String> paragraphs;
}

/// `[STEP-LIST]` — an ordered sequence she actually performs.
///
/// Numbered, because order carries information here (a bedtime routine is not a
/// set). Where order does NOT matter, use `PpCards` — mixing them up is how a
/// checklist ends up implying a sequence it does not have.
class PpSteps extends PpBlock {
  const PpSteps(this.steps, {this.heading});
  final String? heading;
  final List<PpStep> steps;
}

class PpStep {
  /// ⚠️ `detail` IS POSITIONAL, AND THAT IS A CORRECTION.
  ///
  /// It was `{this.detail}` — named — and `PpCard` right below takes its two
  /// strings positionally. Two blocks that are the same shape to an author (a
  /// heading and a line under it) had different call syntax for no reason, and
  /// the first section to be written naturally reached for `PpStep('x', 'y')`
  /// over a hundred times. When an API is got wrong that consistently by someone
  /// reading the file, the API is what is wrong.
  const PpStep(this.title, [this.detail]);
  final String title;
  final String? detail;
}

/// `[CARDS]` — an unordered set, each one a title plus a line.
///
/// The specs use this for "one card per cause" (why babies wake) and "what NOT
/// to do". Unordered on purpose: see the note on `PpSteps`.
class PpCards extends PpBlock {
  const PpCards(this.cards, {this.heading, this.hue = 268});
  final String? heading;
  final List<PpCard> cards;

  /// Off the controlled pastel wheel, so a page of three card blocks does not
  /// read as three grey lumps.
  final double hue;
}

class PpCard {
  const PpCard(this.title, this.line);
  final String title;
  final String line;
}

/// `[COMPARISON TABLE]` — the scan-and-relax format.
///
/// ⚠️ IT SCROLLS SIDEWAYS INSIDE ITSELF. A three-column table at 360dp either
/// wraps into illegibility or pushes the page into a horizontal scroll, and a
/// page body that scrolls sideways is a bug on every screen it touches.
class PpTable extends PpBlock {
  const PpTable({required this.columns, required this.rows, this.heading});
  final String? heading;
  final List<String> columns;
  final List<List<String>> rows;
}

/// `[CHART-CARD]` — structured facts as a card, not prose.
///
/// Sleep-by-age is the worked example: total 24h sleep, naps, night hours, the
/// honest range. The spec adds "these cards are the data source for the
/// quick-check tool, so model them as structured data" — which is why the rows
/// are label/value pairs a tool can read, not a rendered string.
class PpChartCard extends PpBlock {
  const PpChartCard({
    required this.title,
    required this.rows,
    this.subtitle,
    this.note,
    this.hue = 206,
  });
  final String title;
  final String? subtitle;
  final List<(String, String)> rows;

  /// The one-line "what's normal at this age" reassurance.
  final String? note;
  final double hue;
}

/// How loud a callout is.
enum PpCalloutKind {
  /// `[CALLOUT]` — the one key point on the page. Quiet, purple.
  key,

  /// `[FLAGGED CALLOUT]` — see a doctor. Visible, never buried.
  ///
  /// ⚠️ NOT ALARM RED. Every spec says calm and anti-anxiety, and a red box on a
  /// page a frightened parent is already reading at 3am does the opposite of
  /// triage. Coral, and it always names what to do rather than what to fear.
  doctor,

  /// A myth stated and corrected. Used by the "what's true" pages.
  myth,

  /// ⚠️ A SAFETY RULE SHE ACTS ON HERSELF, WHICH IS NOT THE SAME AS A FLAG THAT
  /// SENDS HER TO SOMEONE.
  ///
  /// Added because `doctor` was quietly doing two jobs, and a test caught it.
  /// `test/pp_section_test.dart` asserts that a page raising a clinical worry
  /// names someone to take it to, and it failed on the First 40 Days safe-sleep
  /// page -- whose callout reads "do not share a bed if anyone has been
  /// drinking... put him in a cot beside you instead". That callout names nobody
  /// because it needs nobody: it is a complete instruction, and the action is
  /// hers.
  ///
  /// The distinction is worth having in the model rather than in a reviewer's
  /// head, because the two want different things from the reader:
  ///
  /// * `doctor`  -- "something may be wrong; here is who can tell you." Ends in
  ///                a person. Failing to name one leaves her holding a fear.
  /// * `safety`  -- "here is the rule, and here is what to do instead." Ends in
  ///                an action. Naming a doctor would be padding, and would
  ///                imply a decision she does not need to outsource.
  ///
  /// They render alike deliberately: both must be impossible to skim past. What
  /// differs is what a test may demand of them.
  safety,
}

class PpCallout extends PpBlock {
  const PpCallout(this.text, {this.kind = PpCalloutKind.key, this.title});
  final PpCalloutKind kind;
  final String? title;
  final String text;
}

/// `[SCRIPT BOX]` — the exact words to say.
///
/// From the Behaviour spec's fixed article skeleton ("words to use"). A script
/// is not prose and not a step: it is a line she can borrow verbatim, and it is
/// most useful paired with the thing not to say.
class PpScript extends PpBlock {
  const PpScript(this.lines, {this.heading});
  final String? heading;
  final List<PpScriptLine> lines;
}

class PpScriptLine {
  const PpScriptLine({required this.say, this.notThis, this.why});
  final String say;
  final String? notThis;
  final String? why;
}

/// The mandatory "when / how much / what age" practical line.
class PpWhenLine extends PpBlock {
  const PpWhenLine(this.text);
  final String text;
}

/// The India-home adaptation note — joint family, shared room, no nursery,
/// Indian climate, malish, lori. Its own type so a reviewer can see at a glance
/// which pages have been adapted and which are still generic.
class PpIndiaNote extends PpBlock {
  const PpIndiaNote(this.text);
  final String text;
}

/// A video the section will have. Renders through `PvVideoPlaceholder`, so it
/// occupies the real 16:9 geometry rather than naming itself in a bar.
///
/// ⚠️ `slotId` IS DECLARED HERE, WITH THE PLACEHOLDER, and that is the point:
/// the wiring is written down at the moment the slot is created rather than
/// worked out again when the file arrives.
class PpVideoSlot extends PpBlock {
  const PpVideoSlot({
    required this.title,
    required this.slotId,
    this.subtitle,
    this.minutes,
    this.hue = 344,
  });
  final String title;
  final String? subtitle;
  final String? minutes;
  final String slotId;
  final double hue;
}

/// An audio track the section will have. Same contract as the video slot.
class PpAudioSlot extends PpBlock {
  const PpAudioSlot({
    required this.title,
    required this.slotId,
    this.category,
    this.minutes,
  });
  final String title;
  final String? category;
  final String? minutes;
  final String slotId;
}

/// A soft link across to a tool or another page — "links to the related tool".
///
/// ⚠️ `surfaceId` RESOLVES THROUGH THE ROUTER, so a link that stops resolving is
/// findable by test rather than by tapping. A `null` surfaceId is a link that is
/// honestly not built yet and renders as such instead of as a dead tap.
class PpLink extends PpBlock {
  const PpLink(this.label, {this.surfaceId, this.pageId, this.blurb});
  final String label;
  final String? blurb;
  final String? surfaceId;

  /// ⚠️ A LINK TO ANOTHER PAGE IN THE SAME SECTION.
  ///
  /// Added after the Potty section reported the gap, and the report was right
  /// about why it mattered: every spec's article skeleton ends with "related
  /// page", and the only link this block had was a router `surfaceId`. A page is
  /// not a surface — it has no router entry — so the author had two bad options:
  /// pass `surfaceId: null`, which renders "SOON" and so LIES about a page that
  /// already exists, or write the pointer into the prose and lose the tap.
  ///
  /// It chose the prose, correctly. But "read next in this area: how to read your
  /// baby's signals" as a sentence is a cross-reference the reader has to resolve
  /// by hand, in a section built around not making her do that.
  ///
  /// ⚠️ RESOLVED AGAINST THE SECTION, WHICH IS WHY IT IS AN ID AND NOT A
  /// `PpPage`. Holding the page object would make the data a graph with cycles in
  /// it — page A links to B links back to A — and `const` data cannot express a
  /// cycle at all. An id resolved at render time can, and a bad id is catchable:
  /// `test/pp_section_test.dart` asserts every `pageId` exists in its own section.
  final String? pageId;
}

/// The paid human-help offer, where a spec says to surface it.
///
/// ⚠️ IT CARRIES ITS OWN "WHO THIS IS FOR" LINE AND IT IS REQUIRED. Every spec
/// asks for one, and the reason is that the alternative — a bare "Book a
/// consult" — sells to everyone including the parent whose problem is already
/// solved on the page above it.
class PpConsult extends PpBlock {
  const PpConsult({
    required this.title,
    required this.whoFor,
    required this.surfaceId,
    this.role,
  });
  final String title;
  final String whoFor;
  final String surfaceId;
  final String? role;
}

// =============================================================================
//  A PAGE
// =============================================================================

/// One content page: a title, an optional format tag, and its blocks.
class PpPage {
  const PpPage({
    required this.id,
    required this.title,
    required this.blocks,
    this.subtitle,
    this.bands = const [],
    this.format,
  });

  /// Stable slug. Used for routing, saved items and slot ids, so it must not be
  /// derived from the title — a title is copy and copy gets edited.
  final String id;

  final String title;
  final String? subtitle;

  /// The blocks, in order. Order is authored, never sorted.
  final List<PpBlock> blocks;

  /// Which age bands this page belongs to. Empty means every band.
  ///
  /// See `pp_age_bands.dart`. A mother four months in must not be shown day-one
  /// healing content, and a parent of a three-month-old must not be shown the
  /// tantrum library — so band membership lives on the page, not in the screen
  /// that lists it.
  final List<String> bands;

  /// The spec's bracketed format, kept verbatim for review. Not read by the
  /// renderer — the blocks are the implementation — but it makes "was this built
  /// as the format the spec asked for?" answerable without reading the layout.
  final String? format;

  bool inBand(String band) => bands.isEmpty || bands.contains(band);
}

// =============================================================================
//  THE ONE RENDERER
// =============================================================================

/// Renders a `PpPage`. The only place parenting content page layout is decided.
class PpContentPage extends StatelessWidget {
  const PpContentPage({
    super.key,
    required this.page,
    this.onSurface,
    this.onPage,
  });

  final PpPage page;

  /// How a `PpLink` / `PpConsult` opens. Injected rather than imported so this
  /// file does not depend on the router, and so a preview can render a page with
  /// no navigation at all.
  final void Function(BuildContext context, String surfaceId)? onSurface;

  /// How a `PpLink(pageId:)` opens a sibling page.
  ///
  /// Injected for the same reason as `onSurface`, plus one specific to pages: the
  /// resolution needs the SECTION, and a block does not know which section it is
  /// in. The screen that pushed this page does. Passing the resolver down is what
  /// keeps `pp_content.dart` free of any import of the registry — otherwise the
  /// block model would depend on the list of all sections, and the list of all
  /// sections already depends on the block model.
  final void Function(BuildContext context, String pageId)? onPage;

  @override
  Widget build(BuildContext context) {
    // ⚠️ LISTENS TO THE PALETTE. V3's ground is a store value, not a constant,
    // and a page that reads it once renders yesterday's ground after a change.
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) => _scaffold(context, V2PaletteStore.instance.current),
    );
  }

  Widget _scaffold(BuildContext context, V2Palette p) {
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
          children: [
            _back(context, p),
            const SizedBox(height: 18),
            Text(page.title, style: pvFraunces(fontSize: 26, fontWeight: FontWeight.w600, height: 1.22, color: p.ink1)),
            if (page.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(page.subtitle!,
                  style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
            ],
            const SizedBox(height: 22),
            for (final b in page.blocks) ...[
              _render(context, b),
              SizedBox(height: _gapAfter(b)),
            ],
          ],
        ),
      ),
    );
  }

  /// The back control, in V3's shape: a hairline circle on the ground, not a
  /// filled grey disc.
  Widget _back(BuildContext context, V2Palette p) => Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: p.line),
            ),
            child: Icon(Icons.arrow_back_rounded, size: 19, color: p.ink1),
          ),
        ),
      );

  /// ⚠️ SPACING IS A FUNCTION OF THE BLOCK, NOT A CONSTANT.
  ///
  /// A uniform gap makes an intro float away from the article it introduces and
  /// crams a table against the next heading. Deciding it here is what stops
  /// eleven sections each sprinkling their own `SizedBox`es — which is how the
  /// pregnancy screens ended up with margins that collapsed and doubled
  /// unpredictably.
  double _gapAfter(PpBlock b) => switch (b) {
        PpIntro() => 24,
        PpWhenLine() => 14,
        PpIndiaNote() => 14,
        PpCallout() => 20,
        PpLink() => 10,
        _ => 26,
      };

  Widget _render(BuildContext context, PpBlock b) => PpBlockView(
        block: b,
        onSurface: onSurface,
        onPage: onPage,
      );
}

/// ⚠️ ONE BLOCK, RENDERED THE WAY THE PAGE WOULD RENDER IT.
///
/// Extracted from `PpContentPage` when the sleep quick-check tool needed to show
/// a single chart card that lives inside the Sleep section. The alternative was
/// for the tool to draw its own chart card, which is precisely the duplication
/// this file exists to prevent: two chart cards would drift, and the one in the
/// tool would be the one nobody noticed had drifted.
///
/// A page is still the normal unit. This is for the cases where a tool genuinely
/// needs to reuse one block, and it keeps that reuse honest by making it the
/// same code path rather than a lookalike.
class PpBlockView extends StatelessWidget {
  const PpBlockView({
    super.key,
    required this.block,
    this.onSurface,
    this.onPage,
  });

  final PpBlock block;
  final void Function(BuildContext context, String surfaceId)? onSurface;
  final void Function(BuildContext context, String pageId)? onPage;

  @override
  Widget build(BuildContext context) => _build(context, block);

  Widget _build(BuildContext context, PpBlock b) {
    final p = V2PaletteStore.instance.current;
    if (b is PpIntro) return _intro(b, p);
    if (b is PpArticle) return _article(b, p);
    if (b is PpSteps) return _steps(b, p);
    if (b is PpCards) return _cards(b, p);
    if (b is PpTable) return _table(b, p);
    if (b is PpChartCard) return _chart(b, p);
    if (b is PpCallout) return _callout(b, p);
    if (b is PpScript) return _script(b, p);
    if (b is PpWhenLine) return _whenLine(b, p);
    if (b is PpIndiaNote) return _indiaNote(b, p);
    if (b is PpVideoSlot) return _video(b, p);
    if (b is PpAudioSlot) return _audio(b, p);
    if (b is PpLink) return _link(context, b, p);
    if (b is PpConsult) return _consult(context, b, p);
    return const SizedBox.shrink();
  }

  // ---- the formats ----------------------------------------------------------

  Widget _intro(PpIntro b, V2Palette p) =>
      Text(b.text, style: pvManrope(fontSize: 16, fontWeight: FontWeight.w500, height: 1.6, color: p.ink1));

  Widget _heading(String? t, V2Palette p) => t == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(t, style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, height: 1.22, color: p.ink1)),
        );

  Widget _article(PpArticle b, V2Palette p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(b.heading, p),
          for (var i = 0; i < b.paragraphs.length; i++) ...[
            Text(b.paragraphs[i], style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w500, height: 1.65, color: p.ink2)),
            if (i != b.paragraphs.length - 1) const SizedBox(height: 13),
          ],
        ],
      );

  Widget _steps(PpSteps b, V2Palette p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(b.heading, p),
          for (var i = 0; i < b.steps.length; i++) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // A numeral, because the order is the information.
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.action.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Text('${i + 1}',
                    style: pvManrope(fontSize: 12, fontWeight: FontWeight.w800, height: 1.55, color: p.action)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.steps[i].title,
                          style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.4, color: p.ink1)),
                      if (b.steps[i].detail != null) ...[
                        const SizedBox(height: 3),
                        Text(b.steps[i].detail!,
                            style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
                      ],
                    ]),
              ),
            ]),
            if (i != b.steps.length - 1) const SizedBox(height: 16),
          ],
        ],
      );

  Widget _cards(PpCards b, V2Palette p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(b.heading, p),
          for (var i = 0; i < b.cards.length; i++) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.line),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.cards[i].title,
                        style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.55, color: p.ink1)),
                    const SizedBox(height: 4),
                    Text(b.cards[i].line,
                        style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
                  ]),
            ),
            if (i != b.cards.length - 1) const SizedBox(height: 9),
          ],
        ],
      );

  Widget _table(PpTable b, V2Palette p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(b.heading, p),
          // ⚠️ THE TABLE SCROLLS, THE PAGE DOES NOT. See `PpTable`'s own note.
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(children: [
                // header
                Container(
                  color: p.surfaceAlt,
                  child: Row(
                    children: [
                      for (final c in b.columns)
                        _cell(c, bold: true, width: _colWidth(b), p: p),
                    ],
                  ),
                ),
                for (var r = 0; r < b.rows.length; r++)
                  Container(
                    color: r.isEven ? Colors.white : p.surfaceAlt,
                    child: Row(children: [
                      for (final c in b.rows[r]) _cell(c, width: _colWidth(b), p: p),
                    ]),
                  ),
              ]),
            ),
          ),
        ],
      );

  /// First column wider: it is the axis (an age band, a symptom), and the ones
  /// after it are short values.
  double _colWidth(PpTable b) => b.columns.length <= 2 ? 168 : 138;

  Widget _cell(String text,
          {bool bold = false, required double width, required V2Palette p}) =>
      Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Text(text,
            style: pvManrope(
                fontSize: bold ? 12 : 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                height: 1.45,
                color: bold ? p.ink1 : p.ink2)),
      );

  Widget _chart(PpChartCard b, V2Palette p) {
    final tint = ppTintFor(b.hue);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(b.title, style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, height: 1.22, color: p.ink1)),
        if (b.subtitle != null) ...[
          const SizedBox(height: 3),
          Text(b.subtitle!, style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
        ],
        const SizedBox(height: 14),
        for (final (label, value) in b.rows) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Text(label,
                      style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.4, color: p.ink2))),
              const SizedBox(width: 12),
              // ⚠️ tabular figures, so a column of "11 to 14 hours" lines up.
              Text(value,
                  style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, height: 1.55, color: p.ink1)
                      .copyWith(fontFeatures: const [
                    FontFeature.tabularFigures(),
                  ])),
            ],
          ),
          const SizedBox(height: 9),
        ],
        if (b.note != null) ...[
          const SizedBox(height: 4),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(height: 11),
          Text(b.note!, style: pvManrope(fontSize: 13, fontWeight: FontWeight.w500, height: 1.55, color: p.ink1)),
        ],
      ]),
    );
  }

  Widget _callout(PpCallout b, V2Palette p) {
    // ⚠️ THE DOCTOR CALLOUT IS CORAL, NOT RED, and it is the loudest thing on a
    // page rather than the scariest. See `PpCalloutKind.doctor`.
    final (bg, edge, ink, icon) = switch (b.kind) {
      PpCalloutKind.doctor => (
          ppAlertTint(p),
          ppAlertInk(p).withValues(alpha: 0.45),
          p.ink1,
          Icons.medical_services_outlined
        ),
      PpCalloutKind.myth => (
          const Color(0xFFFFF8E8),
          const Color(0xFFE8D9A8),
          p.ink1,
          Icons.lightbulb_outline_rounded
        ),
      PpCalloutKind.safety => (
          ppAlertTint(p),
          ppAlertInk(p).withValues(alpha: 0.45),
          p.ink1,
          Icons.shield_outlined
        ),
      PpCalloutKind.key => (
          p.surfaceAlt,
          p.line,
          p.ink1,
          Icons.push_pin_outlined
        ),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: edge),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon,
            size: 18,
            color: b.kind == PpCalloutKind.doctor ||
                    b.kind == PpCalloutKind.safety
                ? ppAlertInk(p)
                : p.action),
        const SizedBox(width: 11),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (b.title != null) ...[
              Text(b.title!,
                  style: pvManrope(fontSize: 13, fontWeight: FontWeight.w800, height: 1.55, color: p.ink2)),
              const SizedBox(height: 4),
            ],
            Text(b.text, style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.6, color: p.ink2)),
          ]),
        ),
      ]),
    );
  }

  Widget _script(PpScript b, V2Palette p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(b.heading, p),
          for (var i = 0; i < b.lines.length; i++) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.line),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The words to borrow, set as speech.
                    Text('"${b.lines[i].say}"',
                        style: pvFraunces(fontSize: 15.5, fontWeight: FontWeight.w500, height: 1.22, color: p.ink1)
                            .copyWith(height: 1.45)),
                    if (b.lines[i].notThis != null) ...[
                      const SizedBox(height: 8),
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Not  ',
                            style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w800, height: 1.55, color: p.ink3)),
                        Expanded(
                          child: Text('"${b.lines[i].notThis!}"',
                              style: pvManrope(fontSize: 13, fontWeight: FontWeight.w500, height: 1.45, color: p.ink2)),
                        ),
                      ]),
                    ],
                    if (b.lines[i].why != null) ...[
                      const SizedBox(height: 8),
                      Text(b.lines[i].why!,
                          style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.5, color: p.ink2)),
                    ],
                  ]),
            ),
            if (i != b.lines.length - 1) const SizedBox(height: 9),
          ],
        ],
      );

  Widget _whenLine(PpWhenLine b, V2Palette p) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.schedule_rounded, size: 16, color: p.ink3),
          const SizedBox(width: 9),
          Expanded(
              child: Text(b.text,
                  style: pvManrope(fontSize: 13, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2))),
        ],
      );

  Widget _indiaNote(PpIndiaNote b, V2Palette p) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.home_outlined, size: 16, color: p.ink3),
          const SizedBox(width: 9),
          Expanded(
              child: Text(b.text,
                  style: pvManrope(fontSize: 13, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2))),
        ],
      );

  Widget _video(PpVideoSlot b, V2Palette p) => PvVideoPlaceholder(
        title: b.title,
        subtitle: b.subtitle,
        duration: b.minutes,
        hue: b.hue,
        slotId: b.slotId,
      );

  Widget _audio(PpAudioSlot b, V2Palette p) => PvAudioPlaceholder(
        title: b.title,
        category: b.category,
        length: b.minutes,
        slotId: b.slotId,
      );

  Widget _link(BuildContext context, PpLink b, V2Palette p) {
    // ⚠️ A `pageId` LINK WAS DEAD ON ARRIVAL, AND IT FAILED IN THE WORST WAY.
    //
    // `pageId` was added to `PpLink` so a page could point at a sibling page,
    // and this line was never updated: `live` looked only at `surfaceId`. So
    // every `pageId` link rendered with a "SOON" badge and no tap -- announcing
    // that a page which already existed, one tap away, was not built yet.
    //
    // That is worse than a plain dead link. A dead link disappoints; this one
    // lied about the app's own contents, and it did it on the exact rows meant
    // to connect related reading. Caught by an author who tried to use the
    // field, converted six real cross-references to prose to work around it, and
    // reported the cause rather than the symptom.
    final toSurface = b.surfaceId != null && onSurface != null;
    final toPage = b.pageId != null && onPage != null;
    final live = toSurface || toPage;
    return InkWell(
      onTap: !live
          ? null
          : toSurface
              ? () => onSurface!(context, b.surfaceId!)
              // A surfaceId wins if both are set: it is the more specific
              // destination, and a block with both is an authoring mistake worth
              // resolving predictably rather than silently.
              : () => onPage!(context, b.pageId!),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 14, 12, 14),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.label,
                      style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, height: 1.55, color: p.ink1)),
                  if (b.blurb != null) ...[
                    const SizedBox(height: 3),
                    Text(b.blurb!, style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.5, color: p.ink2)),
                  ],
                ]),
          ),
          const SizedBox(width: 8),
          // ⚠️ NOT A CHEVRON WHEN IT GOES NOWHERE. A chevron promises a screen,
          // and a promise that does nothing teaches her that taps do nothing.
          if (live)
            Icon(Icons.chevron_right_rounded, size: 20, color: p.action)
          else
            Text('SOON',
                style: pvManrope(fontSize: 9.5, fontWeight: FontWeight.w800, height: 1.55, color: p.ink3)
                    .copyWith(letterSpacing: 0.9)),
        ]),
      ),
    );
  }

  Widget _consult(BuildContext context, PpConsult b, V2Palette p) => Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TALK TO SOMEONE',
              style: pvManrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  color: p.action.withValues(alpha: 0.85))),
          const SizedBox(height: 8),
          Text(b.title, style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, height: 1.22, color: p.ink1)),
          const SizedBox(height: 7),
          // The required "who this is for" line — see `PpConsult`.
          Text(b.whoFor, style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.6, color: p.ink2)),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onSurface == null
                ? null
                : () => onSurface!(context, b.surfaceId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: p.action,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('See who is available',
                  style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, height: 1.55, color: Colors.white)),
            ),
          ),
        ]),
      );
}

/// V3's back control: a hairline circle on the ground, never a filled grey disc.
///
/// Shared rather than copied into each tool screen, for the reason this whole
/// file exists: five screens with five back buttons is five chances for one of
/// them to be a filled circle.
Widget ppV3Back(BuildContext context, V2Palette p) => Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: p.line),
          ),
          child: Icon(Icons.arrow_back_rounded, size: 19, color: p.ink1),
        ),
      ),
    );

/// A pastel off the same controlled wheel the pregnancy doors use, so a
/// parenting chart-card and a pregnancy door read as one product.
Color ppTintFor(double hue) =>
    HSLColor.fromAHSL(1, hue % 360, 0.34, 0.935).toColor();

/// ⚠️ THE ALERT HUE COMES OFF THE SAME WHEEL AS EVERYTHING ELSE.
///
/// It used to be `ppAlertInk(p)` -- the parenting app's brand pink -- which is the
/// second half of the review "new screens again scream purple and old icons".
/// A brand colour is not an interface colour: `v2_palette.dart` makes exactly
/// that argument about the ground, and it applies harder to the one colour that
/// has to mean "stop and read this".
///
/// Hue 14 is the warm end of the controlled wheel, so a doctor callout is
/// unmistakably warmer than the page without being a different product's pink.
Color ppAlertTint(V2Palette p) => v2BlockTint(14, p);
Color ppAlertInk(V2Palette p) => HSLColor.fromColor(v2BlockTint(14, p))
    .withSaturation(0.52)
    .withLightness(0.44)
    .toColor();

// =============================================================================
//  ⚠️ THE LANGUAGE DECISION, WRITTEN DOWN
// -----------------------------------------------------------------------------
//  Every string here is a `String`, not a `LocalizedText`. That is the user's
//  standing instruction ("first give me english thing") and it is the right call
//  for now, but it has a cost worth naming rather than discovering later:
//
//  When Hindi arrives, this is a type change on the block classes, which is a
//  compile error at every construction site — hundreds of them across eleven
//  section data files. That is the GOOD version of the problem: it cannot be
//  half-done, and nothing ships silently English.
//
//  The bad version would be adding an optional `hi` beside every field, which
//  compiles the moment it is added and then quietly renders English forever
//  wherever someone forgot. `_en(...)` exists in the pregnancy data files for
//  exactly this reason — it makes the backlog greppable. If Hindi is wanted here
//  before these files are written, say so now: the cheap moment is before eleven
//  sections of content exist, not after.
// =============================================================================
