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
import 'pp_child_profile.dart';
import 'pp_content_art.dart';
import 'pp_interactive_screen.dart';
import 'pp_story_screen.dart';

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
  const PpTable({
    required this.columns,
    required this.rows,
    this.heading,
    this.rowMonths,
  });
  final String? heading;
  final List<String> columns;
  final List<List<String>> rows;

  /// ⚠️ THE AGE RULE, FOR AN AGE-ARC TABLE: HER ROW LEADS, THE REST IS CONTEXT.
  ///
  /// Sleep's rebuild states it for every age-arc table: "LEAD with her row;
  /// the rest of the arc stays as context, not as a chooser." The app knows the
  /// child's age, so a table that makes her find her own row in a list of six
  /// is asking her for a fact it already holds.
  ///
  /// One `(fromMonths, toMonths)` span per row, parallel to `rows`, lower bound
  /// inclusive and upper exclusive, the same convention as `PpBand`. Null keeps
  /// the table exactly as it was: a plain table for content that is not an age
  /// arc. Stated in months rather than band ids so a block does not need to
  /// know which section it is in, and so the same table renders right in any
  /// section whatever its band boundaries.
  ///
  /// The renderer hoists her row to the top and marks it. Nothing is removed,
  /// which is the whole distinction the age rule rests on: other ages are still
  /// there, below, as context. What changes is what she reads first.
  final List<(int, int)>? rowMonths;

  /// Index of the row the child is in right now, or null.
  int? herRow(int months) => _herRow(rowMonths, months);
}

/// Shared by `PpTable` and `PpChartCard`: which span holds this age.
int? _herRow(List<(int, int)>? spans, int months) {
  if (spans == null) return null;
  for (var i = 0; i < spans.length; i++) {
    final (from, to) = spans[i];
    if (months >= from && months < to) return i;
  }
  return null;
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
    this.rowMonths,
  });
  final String title;
  final String? subtitle;
  final List<(String, String)> rows;

  /// The one-line "what's normal at this age" reassurance.
  final String? note;
  final double hue;

  /// The age rule for a TIMELINE card ("When they typically hit"): her row is
  /// marked in place rather than hoisted, because a timeline read out of order
  /// is not a timeline. Same `(fromMonths, toMonths)` convention as `PpTable`.
  final List<(int, int)>? rowMonths;

  int? herRow(int months) => _herRow(rowMonths, months);
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

  /// Who this consult is actually for.
  ///
  /// ⚠️ THIS WAS RECORDED AND NEVER READ, WHICH IS THE WIRING GATE IN ITS
  /// quietest form. Forty-eight consult blocks across the parenting content
  /// carry a role — 'pediatrician', 'lactation', 'speech' — and every one of
  /// them opened `pp_experts`, the whole roster. The data knew exactly who it
  /// wanted; the tap threw it away. Nothing failed, no test could see it, and
  /// the only symptom was a parent reading "talk to a paediatrician tonight"
  /// and landing on a list that opens with a physiotherapist.
  ///
  /// [surface] is what fixes it, and it is deliberately a getter here rather
  /// than a fix at each of the forty-eight call sites.
  final String? role;

  /// The surface this consult should open: filtered when the role maps to a
  /// real expert category, the plain roster when it does not.
  ///
  /// ⚠️ AN UNMAPPED ROLE FALLS BACK RATHER THAN FAILING, AND THAT IS
  /// DELIBERATE BUT NOT FREE. Ten of the fourteen roles in the content —
  /// physio, sleep, nutrition, maternal_mental_health and the group ones —
  /// have no expert in `kFindHelpExperts` at all. Filtering to them would show
  /// an empty list, which is worse than an unfiltered one for a parent who
  /// needs somebody now. `test/pp_consult_filter_test.dart` prints the unmapped
  /// set so the gap is visible rather than silently absorbed.
  String get surface {
    if (surfaceId != 'pp_experts') return surfaceId;
    final category = kPpConsultRoleToCategory[role];
    return category == null ? surfaceId : 'pp_experts/$category';
  }
}

/// Consult role -> `Expert.category`.
///
/// ⚠️ BOTH SPELLINGS OF PAEDIATRICIAN ARE HERE ON PURPOSE. The content uses
/// 'pediatrician' eight times and 'paediatrician' once. Normalising the
/// content would be tidier and would also be a silent behaviour change in a
/// file somebody is still editing; mapping both costs one line and cannot
/// regress.
/// ⚠️ EVERY ROLE IN THE CONTENT NOW MAPS. Nine of the fourteen used to fall
/// through to the unfiltered roster because the categories they wanted had no
/// supply. Rather than leave the pipeline half-built until people exist, the
/// missing categories were seeded (`Expert.seeded`) and the map completed — so
/// the day a real sleep coach or nutritionist is signed, nothing here changes.
///
/// ⚠️ THE GROUP ROLES DELIBERATELY POINT AT THE SAME CATEGORY AS THEIR 1:1
/// EQUIVALENT. `group_physio` is a physiotherapist running a group; it is a
/// FORMAT, not a different profession, and giving it its own category would
/// mean seeding a second roster of the same people. If group sessions ever need
/// their own supply, that is a booking-engine concern rather than a directory
/// one.
const Map<String, String> kPpConsultRoleToCategory = {
  // real supply
  'pediatrician': 'Pediatrician',
  'paediatrician': 'Pediatrician',
  'lactation': 'Lactation expert',
  'speech': 'Speech therapist',
  'psychologist': 'Child psychologist',
  // seeded supply — see kSeededExpertIds
  'sleep': 'Sleep expert',
  'nutrition': 'Nutritionist',
  'physio': 'Physiotherapist',
  'group_physio': 'Physiotherapist',
  'maternal_mental_health': 'Maternal mental health',
  'group_mental_health': 'Maternal mental health',
  'development': 'Development expert',
  'early_learning': 'Early learning expert',
  'school_readiness': 'Early learning expert',
};

// =============================================================================
//  THE FORMATS THE DOOR REBUILDS ADDED
// -----------------------------------------------------------------------------
//  ⚠️ FOUR MORE BLOCK TYPES, EACH ONE NAMED BY A REBUILD BRIEF AND NONE OF THEM
//  SPECULATIVE. The Sleep rebuild marks pages "[reformat: was step-list]" into
//  Video, "[reformat: was text list]" into Interactive, "[reformat: was
//  article+diagram]" into Animation, "[reformat: was article]" into
//  Illustration, and "[reformat: was 5 short articles]" into Carousel. Video
//  already existed. The other four did not, and a brief that says "the 3am page
//  becomes a glanceable interactive" cannot be satisfied by a step-list with a
//  different chip on it.
//
//  Each one follows the same shape as `PpVideoSlot`: the block is DATA, the
//  page renders a launch card in the page's own vocabulary, and the experience
//  itself is a full screen (`pp_story_screen.dart`, `pp_interactive_screen.dart`)
//  or a drawn component (`pp_content_art.dart`). A carousel opened in a half
//  sheet would tell her before she starts that what she tapped was minor; the
//  TTC story screen makes that argument at length and it holds here.
// =============================================================================

/// `[CAROUSEL]` — a few cards, swiped, one idea per slide.
///
/// ⚠️ A CARD MAY LINK TO A SIBLING PAGE, AND THAT IS HOW "NO SECOND COPIES"
/// IS KEPT. The worry set is four short articles that became one carousel;
/// the brief says "each links to its canonical page, no second copies". So a
/// slide is a summary with a `pageId`, and swiping up (or the visible "read
/// the full page" pill) opens the article. The four articles stay where they
/// are, unlisted, and the carousel is the only tile.
class PpCarousel extends PpBlock {
  const PpCarousel({
    required this.cards,
    this.coverTitle,
    this.coverBlurb,
    this.hue = 268,
    this.eyebrow,
  });

  final List<PpCarouselCard> cards;

  /// A title card before the first slide, so she knows how long this is and
  /// what it covers before she is mid-argument. Null skips it.
  final String? coverTitle;
  final String? coverBlurb;
  final double hue;

  /// What the launch card calls this — "THE WORRY SET", "MYTH VS TRUTH".
  final String? eyebrow;

  /// The cards that fit this age. Empty spans fit everyone.
  List<PpCarouselCard> cardsFor(int months) =>
      [for (final c in cards) if (c.fits(months)) c];
}

class PpCarouselCard {
  const PpCarouselCard(
    this.title, [
    this.body = '',
  ]) : pageId = null,
       myth = false,
       fromMonths = null,
       toMonths = null;

  /// A slide that opens a fuller page on swipe-up.
  const PpCarouselCard.linked(
    this.title,
    this.body, {
    required this.pageId,
    this.fromMonths,
    this.toMonths,
  }) : myth = false;

  /// A myth stated, then what is true. The slide draws the two halves apart.
  const PpCarouselCard.myth(this.title, this.body)
      : pageId = null,
        myth = true,
        fromMonths = null,
        toMonths = null;

  /// ⚠️ THE WHOLE SLIDE, IN ONE LINE. A slide is a sentence that teaches one
  /// thing, not a label over a paragraph. The TTC story format found this the
  /// hard way and it is the difference between a carousel someone finishes and
  /// one someone swipes past.
  final String title;

  /// The payoff line. Often short; sometimes empty.
  final String body;

  /// A sibling page this slide summarises.
  final String? pageId;

  /// Title is the myth, body is the truth.
  final bool myth;

  /// ⚠️ THE AGE RULE, PER SLIDE. A worry about a 30-minute nap is a 3-to-6-
  /// month worry; a toddler's parent should not swipe past it. Same months
  /// convention as `PpTable.rowMonths`. Null on both means every age.
  final int? fromMonths;
  final int? toMonths;

  bool fits(int months) =>
      (fromMonths == null || months >= fromMonths!) &&
      (toMonths == null || months < toMonths!);
}

/// How an interactive behaves.
enum PpInteractiveKind {
  /// One big step per screen, dark and dim, tap to advance. For the page she
  /// reads at 3am with one eye open. Not a list.
  night,

  /// One item per screen with "done" / "not yet", ending on the short list of
  /// what to fix tonight. For a checklist that is walked, not read.
  checklist,
}

/// `[INTERACTIVE]` — a step-through she taps, not a list she reads.
class PpInteractive extends PpBlock {
  const PpInteractive({
    required this.kind,
    required this.title,
    required this.items,
    this.blurb,
    this.closing,
    this.closingPageId,
    this.closingLabel,
    this.hue = 268,
  });

  final PpInteractiveKind kind;
  final String title;

  /// What the launch card says under the title.
  final String? blurb;
  final List<PpInteractiveItem> items;

  /// The last screen. For the night kind: what to do if none of it worked.
  /// For the checklist kind: shown above the "not yet" list.
  final String? closing;

  /// An optional page the last screen opens — the doctor page, typically.
  final String? closingPageId;
  final String? closingLabel;
  final double hue;
}

/// An interactive's items as story slides: one step per slide, the group
/// name folded into the body where there is one, the closing as the last
/// slide (linked to its page, if it names one).
///
/// ⚠️ THIS IS HOW AN INTERACTIVE RENDERS NOW. Decided on a phone,
/// 2026-09-12: the carousel and the interactive are one design. The kinds
/// still mean something — `night` is drawn on the dim ground — and the
/// done / not-yet walk-through (`pp_interactive_screen.dart`) is kept for
/// revert and opened by nothing.
List<PpCarouselCard> ppInteractiveAsSlides(PpInteractive b) => [
      for (final it in b.items)
        PpCarouselCard(it.title, [
          if (it.group != null) it.group!,
          if (it.detail != null) it.detail!,
        ].join('  ·  ')),
      if (b.closing case final c?)
        if (b.closingPageId case final id?)
          PpCarouselCard.linked(c, b.closingLabel ?? 'Swipe up for the page',
              pageId: id)
        else
          PpCarouselCard(c),
    ];

/// ⚠️ A CARDS PAGE IS A STORY — 2026-09-18. The user asked for one format
/// per tag: "for tags like interactive, carousel we have the Instagram story
/// type… we don't have it for cards." A CARDS page is a set of titled ideas
/// ("three rough styles", five cards each), which is exactly the object the
/// reader audit named the story card — one idea per card, swipe, the last
/// card is a verb (Blinkist Shorts, Deepstash, Flo's daily insights). So
/// CARDS opens the same `PpStoryScreen` as CAROUSEL and INTERACTIVE:
///
///   · the cover is the page title and its subtitle or intro;
///   · every `PpCard` is a slide; a callout is a slide under its own title;
///     the doctor line is a slide called "When to see a doctor";
///   · a page link becomes the linked closing slide ("Swipe up for …");
///   · an India note rides as a slide too.
///
/// Returns null when the page carries a block the deck cannot hold — a
/// table, a chart, an illustration, a film — and the page then opens in the
/// reader with its cards listed, rather than losing anything.
List<PpCarouselCard>? ppCardsAsSlides(PpPage page) {
  final slides = <PpCarouselCard>[];
  PpCarouselCard? closing;
  for (final b in page.blocks) {
    switch (b) {
      case PpIntro():
        break; // the cover has it
      case PpCards(:final cards):
        for (final c in cards) {
          slides.add(PpCarouselCard(c.title, c.line));
        }
      case PpCallout(:final title, :final text, :final kind):
        slides.add(PpCarouselCard(
            title ??
                switch (kind) {
                  PpCalloutKind.key => 'Worth remembering',
                  PpCalloutKind.doctor => 'Worth raising with a doctor',
                  PpCalloutKind.myth => 'A common belief, checked',
                  PpCalloutKind.safety => 'For safety',
                },
            text));
      case PpWhenLine(:final text):
        slides.add(PpCarouselCard('When to see a doctor', text));
      case PpIndiaNote(:final text):
        slides.add(PpCarouselCard('In India', text));
      case PpCarousel():
        // A carousel on a CARDS page is already slides.
        slides.addAll(b.cards);
      case PpArticle(:final heading, :final paragraphs):
        slides.add(PpCarouselCard(heading ?? page.title, paragraphs.join('\n\n')));
      case PpLink(:final label, :final blurb, :final pageId):
        if (pageId != null && closing == null) {
          closing = PpCarouselCard.linked(label, blurb ?? 'Swipe up for the page',
              pageId: pageId);
        }
      default:
        return null; // a table, a chart, a film — the deck cannot hold it
    }
  }
  if (slides.isEmpty) return null;
  if (closing != null) slides.add(closing);
  return slides;
}

class PpInteractiveItem {
  const PpInteractiveItem(this.title, [this.detail, this.group]);
  final String title;
  final String? detail;

  /// A heading the checklist kind groups items under ("The surface", "Clear
  /// away"). Ignored by the night kind.
  final String? group;
}

/// Which drawn animation. One value per animation that exists; add a value
/// when a brief names one, never before.
enum PpAnimationKind {
  /// Two sleep-cycle waves, hers and yours. She surfaces twice as often.
  sleepCycles,

  /// The shared breathing circle (`lib/widgets/breathing_circle.dart`), on
  /// the balloon pattern: in for three, out for five. Behaviour's balloon
  /// breathing, single-sourced with Mind and mood and Kriya.
  breathing,
}

/// `[ANIMATION]` — a short drawn animation with a caption.
///
/// ⚠️ DRAWN, NOT A SLOT. `PpVideoSlot` waits for a file. This does not: a
/// two-wave cycle comparison is a `CustomPainter` and an `AnimationController`,
/// and it is more honest to draw the thing the brief describes than to leave a
/// 16:9 placeholder that says "animation coming". If a filmed version ever
/// arrives it replaces the painter, and the block does not change.
class PpAnimation extends PpBlock {
  const PpAnimation({
    required this.kind,
    required this.title,
    this.caption,
  });
  final PpAnimationKind kind;
  final String title;
  final String? caption;
}

/// Which drawn illustration.
enum PpIllustrationKind {
  /// Where to take a temperature: under the arm, forehead, ear, mouth.
  thermometerRoutes,

  /// A baby with the six dehydration signs numbered.
  dehydrationSigns,

  /// Eight rashes as a labelled grid of swatches.
  rashGrid,

  /// One bed, set up safely, with the hazards numbered.
  safeBedSetup,

  /// On her back: the one position that is the way, beside the two that are
  /// not.
  backToSleep,

  /// Four katoris: puree, mash, soft finger food, chopped family food.
  solidsTextures,

  /// A grape quartered lengthways beside a grape cut into coins; sticks
  /// beside coins; a nut ground beside a nut whole.
  cutItThisWay,

  /// A face: the mild signs on one side, the call-now signs on the other.
  allergicReaction,

  /// A colour strip of newborn poop, day one to week six: black, dark green,
  /// mustard, tan, occasional green, and the pink stain. Parents are matching
  /// a nappy to a picture.
  poopColours,

  /// Four newborn customs as "this, not that": where a kajal dot may go,
  /// the bare dry cord, the frog-leg swaddle, a head left to round itself.
  newbornCustoms,
}

/// `[ILLUSTRATION]` — one labelled picture.
///
/// ⚠️ THE LABELS ARE THE CONTENT. A picture with numbered callouts and a
/// numbered legend under it is what "one labelled safe-setup picture" means,
/// and it is what a paragraph describing the same setup cannot be: glanceable.
/// The painter places the numbers; the legend carries the words. An `asset`
/// replaces the painter when artwork arrives and the legend stays put.
class PpIllustration extends PpBlock {
  const PpIllustration({
    required this.kind,
    required this.title,
    required this.labels,
    this.caption,
    this.asset,
  });
  final PpIllustrationKind kind;
  final String title;
  final List<PpIllustrationLabel> labels;
  final String? caption;
  final String? asset;
}

class PpIllustrationLabel {
  const PpIllustrationLabel(this.title, [this.detail]);
  final String title;
  final String? detail;
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
    this.toolSurfaceId,
    this.linkedOnly = false,
    this.pinned = false,
    this.comingSoon = false,
  });

  /// ⚠️ A CARD THAT HOLDS ITS PLACE AND DOES NOT TAP. The pregnancy doors'
  /// rule for a brief that names a piece and says the copy will be supplied
  /// ("do not AI-generate it; build the scaffolding"): the card sits on the
  /// rail at full size with a "Coming soon" chip, so nothing moves the day
  /// the piece lands. The blocks may be empty; the page is exempt from the
  /// content tests the way a tool page is. Logged in
  /// `docs/DOOR-CONTENT-OWED.md`, and the test there fails if a coming-soon
  /// page is not in the ledger.
  final bool comingSoon;

  /// Stable slug. Used for routing, saved items and slot ids, so it must not be
  /// derived from the title — a title is copy and copy gets edited.
  final String id;

  /// ⚠️ A PAGE THAT IS A TOOL. Mirrors `PpArea.toolSurfaceId` one level down:
  /// the Sleep rebuild puts "Wake windows [Tool]" INSIDE collection 1, beside
  /// the chart and the animation, rather than on the landing. Its card opens
  /// the surface directly; the blocks are never rendered and may be empty.
  /// `test/pp_section_test.dart` exempts a tool page from "has blocks" and
  /// "opens with an intro", and `test/pp_sleep_check_test.dart` asserts the
  /// surface resolves.
  final String? toolSurfaceId;

  /// ⚠️ REACHABLE BY LINK, NOT LISTED. The page exists, resolves by id, keeps
  /// its bands, and does not appear as a tile. This is how a carousel can say
  /// "each card links to its canonical page, no second copies" without the
  /// canonical pages also sitting beside it as four more tiles. `pagesFor`
  /// excludes it; `allPages` and `pageById` do not.
  final bool linkedOnly;

  /// Sits above the area's grid as one wide card. At most one per area, by
  /// convention. Same treatment and the same reasoning as `PpArea.pinned`:
  /// "pinned at the top" is a brief instruction, and a first-in-the-grid card
  /// does not say "different kind of thing", only "first".
  final bool pinned;

  final String title;
  final String? subtitle;

  /// The blocks, in authored order.
  ///
  /// ⚠️ ONE EXCEPTION, AND IT IS DELIBERATE: `orderedBlocks` HOISTS THE
  /// VIDEO. Feedback, repeated for every parenting section: "in all sections
  /// where a video is added, move it to top of the page." So the renderer
  /// reads `orderedBlocks`, not this list.
  ///
  /// It is done in ONE place rather than by re-authoring every page, because
  /// re-ordering by hand across eleven sections is a change nobody can verify
  /// and one somebody will forget on the next page they write. Hoisting in the
  /// renderer means a page authored tomorrow obeys the rule without being told.
  final List<PpBlock> blocks;

  /// The blocks as the reader meets them: video first, everything else in the
  /// order it was written.
  ///
  /// ⚠️ STABLE, NOT MERELY FILTERED. Both halves keep their relative
  /// authored order, so a page with two videos shows them in the order they
  /// were written and the prose beneath is untouched. A `sort` with a
  /// comparator would have been shorter and is not stable in Dart for small
  /// lists in any guaranteed way — two partitions are.
  List<PpBlock> get orderedBlocks {
    final video = [for (final b in blocks) if (b is PpVideoSlot) b];
    if (video.isEmpty) return blocks;
    return [
      ...video,
      for (final b in blocks) if (b is! PpVideoSlot) b,
    ];
  }

  /// True when this page has no video at all. Read by
  /// `test/pp_video_coverage_test.dart`, which lists the gaps rather than
  /// letting them be discovered one screen at a time.
  bool get hasVideo => blocks.any((b) => b is PpVideoSlot);

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
            // ⚠️ `orderedBlocks`, NOT `blocks` — the video is hoisted to the
            // top here rather than re-authored into position on every page.
            // See PpPage.orderedBlocks for why it is one place and not many.
            for (final b in page.orderedBlocks) ...[
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
    if (b is PpCarousel) return _carousel(context, b, p);
    if (b is PpInteractive) return _interactive(context, b, p);
    if (b is PpAnimation) return PpAnimationView(block: b);
    if (b is PpIllustration) return PpIllustrationView(block: b);
    // ⚠️ A MASTERCLASS LINK IS RENDERED AS A MASTERCLASS, NOT AS A ROW.
    //
    // Feedback: "masterclass should remain but show masterclass as a master
    // class with cover image etc." Nine `PpLink`s across the parenting content
    // point at `pp_courses`, and every one of them rendered as the same grey
    // row as "see the sleep log" — so the paid, taught, hour-long thing looked
    // exactly like a cross-reference and read as one.
    //
    // Detected on the DESTINATION rather than on a new block type, so all nine
    // change at once and a tenth written tomorrow is right without being told.
    // The alternative — a `PpMasterclass` block — would have meant editing nine
    // call sites and remembering the rule forever.
    if (b is PpLink && b.surfaceId == 'pp_courses') {
      return _masterclass(context, b, p);
    }
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

  Widget _table(PpTable b, V2Palette p) {
    // ⚠️ HER ROW LEADS. See `PpTable.rowMonths`. The order is computed here,
    // once, from the child's age: hers first, then the rest in authored order.
    // A table with no spans keeps its authored order untouched.
    final hers = b.herRow(ChildProfileStore.instance.ageInMonths);
    final order = [
      ?hers,
      for (var r = 0; r < b.rows.length; r++)
        if (r != hers) r,
    ];
    final mark = ppTintFor(206);
    return Column(
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
              for (final (i, r) in order.indexed)
                Container(
                  color: r == hers
                      ? mark
                      : i.isEven
                          ? Colors.white
                          : p.surfaceAlt,
                  child: Row(children: [
                    for (final (c, text) in b.rows[r].indexed)
                      c == 0 && r == hers
                          ? _herCell(text, width: _colWidth(b), p: p)
                          : _cell(text, width: _colWidth(b), p: p),
                  ]),
                ),
            ]),
          ),
        ),
      ],
    );
  }

  /// The first cell of her row: the value, with the tag that says why it
  /// leads. The tag reads "HER AGE NOW" rather than the child's name so the
  /// cell keeps its width whatever she is called.
  Widget _herCell(String text, {required double width, required V2Palette p}) =>
      Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('HER AGE NOW',
              style: pvManrope(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.action)),
          const SizedBox(height: 2),
          Text(text,
              style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.45,
                  color: p.ink1)),
        ]),
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
    // ⚠️ MARKED IN PLACE, NOT HOISTED. A timeline card keeps its order and
    // says "you are here" on the row that holds her age. See
    // `PpChartCard.rowMonths`.
    final hers = b.herRow(ChildProfileStore.instance.ageInMonths);
    // ⚠️ A WHITE DATA CARD, LIKE THE TABLE — 2026-09-18. The chart card was a
    // filled tint with a white pane for her row; the table was white with a
    // tinted row. Two treatments for one kind of thing (a few labelled
    // figures), and the filled one read as a slab on the white page. One
    // family now, the one the health apps share (Mobbin: Alan, Withings,
    // Peloton): white, hairline, tabular figures, and colour only on the row
    // that is hers (DESIGN-SYSTEM §4.0). Kept for revert: color: tint.
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(b.title, style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, height: 1.22, color: p.ink1)),
        if (b.subtitle != null) ...[
          const SizedBox(height: 3),
          Text(b.subtitle!, style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
        ],
        const SizedBox(height: 14),
        for (final (i, (label, value)) in b.rows.indexed) ...[
          Container(
            // Her row on a timeline: a white pane on the tinted card, with the
            // tag beside the label. Rows that are not hers are drawn exactly
            // as before.
            padding: i == hers
                ? const EdgeInsets.fromLTRB(10, 8, 10, 8)
                : EdgeInsets.zero,
            decoration: i == hers
                ? BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(12),
                  )
                : null,
            // ⚠️ THE LABEL KEEPS ITS COLUMN. With the value unconstrained, a
            // long value ("From about 7 months once yolk is accepted") took
            // the whole row and the label wrapped one letter per line —
            // "C h i c k e n". Seen on a phone on the Feeding tool,
            // 2026-09-12. Five parts label, seven parts value; the value
            // wraps, the label does not collapse.
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (i == hers)
                          Text('YOU ARE HERE',
                              style: pvManrope(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: p.action)),
                        Text(label,
                            style: pvManrope(
                                fontSize: 13.5,
                                fontWeight: i == hers
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                height: 1.4,
                                color: i == hers ? p.ink1 : p.ink2)),
                      ]),
                ),
                const SizedBox(width: 12),
                // ⚠️ tabular figures, so a column of "11 to 14 hours" lines up.
                Expanded(
                  flex: 7,
                  child: Text(value,
                      textAlign: TextAlign.end,
                      style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, height: 1.55, color: p.ink1)
                          .copyWith(fontFeatures: const [
                        FontFeature.tabularFigures(),
                      ])),
                ),
              ],
            ),
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

  /// The carousel's launch card: a tinted panel that says what it is, how long
  /// it is, and opens the story screen. The slides themselves never render
  /// inline — see the note at the head of the new formats.
  Widget _carousel(BuildContext context, PpCarousel b, V2Palette p) {
    final months = ChildProfileStore.instance.ageInMonths;
    final cards = b.cardsFor(months);
    if (cards.isEmpty) return const SizedBox.shrink();
    final tint = v2BlockTint(b.hue, p);
    final first = b.coverTitle ?? cards.first.title;
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'pp/story'),
        builder: (_) => PpStoryScreen(
          title: b.eyebrow ?? 'Swipe through',
          cards: cards,
          hue: b.hue,
          coverTitle: b.coverTitle,
          coverBlurb: b.coverBlurb,
          onPage: onPage,
        ),
      )),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(
                  '${(b.eyebrow ?? 'CAROUSEL').toUpperCase()}  ·  '
                  '${cards.length} ${cards.length == 1 ? 'SLIDE' : 'SLIDES'}',
                  style: pvManrope(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: p.action)),
            ),
            Icon(Icons.swipe_rounded, size: 18, color: p.action),
          ]),
          const SizedBox(height: 8),
          Text(first,
              style: pvFraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: -0.35,
                  color: p.ink1)),
          if (b.coverBlurb != null) ...[
            const SizedBox(height: 5),
            Text(b.coverBlurb!,
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: p.ink2)),
          ],
          const SizedBox(height: 14),
          // The segments: one per slide, the shape a story reader already
          // knows how to read, drawn here so the card promises the format.
          Row(children: [
            for (var i = 0; i < cards.length; i++) ...[
              Expanded(
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: p.ink1.withValues(alpha: i == 0 ? 0.55 : 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              if (i != cards.length - 1) const SizedBox(width: 4),
            ],
          ]),
        ]),
      ),
    );
  }

  /// The interactive's launch card. The night kind is drawn dark, because the
  /// card is the promise: tapping it at 3am should not open a white screen.
  Widget _interactive(BuildContext context, PpInteractive b, V2Palette p) {
    final night = b.kind == PpInteractiveKind.night;
    final ground = night ? PpInteractiveScreen.nightGround : v2BlockTint(b.hue, p);
    final ink = night ? Colors.white : p.ink1;
    final ink2 = night ? Colors.white.withValues(alpha: 0.72) : p.ink2;
    final accent = night ? PpInteractiveScreen.nightAccent : p.action;
    final n = b.items.length;
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'pp/interactive'),
        builder: (_) => PpStoryScreen(
          title: b.title,
          cards: ppInteractiveAsSlides(b),
          hue: b.hue,
          coverTitle: b.title,
          coverBlurb: b.blurb,
          dim: b.kind == PpInteractiveKind.night,
          onPage: onPage,
        ),
      )),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
        decoration: BoxDecoration(
          color: ground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              'INTERACTIVE  ·  $n ${night ? 'STEPS' : 'CHECKS'}',
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: accent)),
          const SizedBox(height: 8),
          Text(b.title,
              style: pvFraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: -0.35,
                  color: ink)),
          if (b.blurb != null) ...[
            const SizedBox(height: 5),
            Text(b.blurb!,
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: ink2)),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: night ? Colors.white.withValues(alpha: 0.12) : p.action,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(night ? 'Start, one step at a time' : 'Swipe through it',
                style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                    color: Colors.white)),
          ),
        ]),
      ),
    );
  }

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

  /// A masterclass, with a cover.
  ///
  /// ⚠️ THE COVER IS DRAWN, NOT PHOTOGRAPHED, for the same reason as the
  /// section cards: there is no course art in the app, and a grey rectangle is
  /// a placeholder somebody has to delete later. A tinted panel with a play
  /// mark is a finished treatment that an image can replace without this
  /// widget changing.
  ///
  /// ⚠️ AND IT SAYS "MASTERCLASS" OUT LOUD. The label alone was doing that
  /// work in prose ("a masterclass on play and early development"), which is
  /// exactly the kind of thing a reader skims past. The eyebrow makes the kind
  /// of thing legible before the sentence is read.
  Widget _masterclass(BuildContext context, PpLink b, V2Palette p) {
    final tint = v2BlockTint(268, p);
    return InkWell(
      onTap: onSurface == null
          ? null
          : () => onSurface!(context, b.surfaceId!),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // The cover.
          Container(
            height: 96,
            width: double.infinity,
            color: tint,
            alignment: Alignment.center,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: p.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow_rounded, size: 24, color: p.action),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MASTERCLASS',
                      style: pvManrope(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: p.action)
                          .copyWith(letterSpacing: 1.1)),
                  const SizedBox(height: 6),
                  Text(b.label,
                      style: pvFraunces(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          letterSpacing: -0.35,
                          color: p.ink1)),
                  if (b.blurb != null) ...[
                    const SizedBox(height: 5),
                    Text(b.blurb!,
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color: p.ink2)),
                  ],
                ]),
          ),
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
                // ⚠️ `b.surface`, NOT `b.surfaceId` — the role decides.
                : () => onSurface!(context, b.surface),
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
