// =============================================================================
//  Focus pages — one scrollable page per problem area
// -----------------------------------------------------------------------------
//  ⚠️ THIS REPLACES A MIDDLE MENU, AND THAT IS THE WHOLE POINT.
//
//  Tapping "Conceiving & the fertile window" used to open a hub asking "What do
//  you need?" with three answers: the fertile-window tool, "Improve my chances
//  this cycle", and a consult. Three problems with that, in order of severity:
//
//    · **Two of the three answers were the same answer.** "Improve my chances
//      this cycle" opened `kTtcImproveChances`, a four-step journey whose first
//      step was... the fertile-window tool, which was also the card next to it.
//      The menu offered a choice between a thing and a wrapper around that same
//      thing.
//    · **She had already told us what she needed** by tapping the area. Asking
//      again, in a second menu, is asking the same question twice.
//    · **The tool and the reading were separated** as if they were alternatives.
//      They are not. Knowing which days, and knowing what actually helps on
//      those days, is one job.
//
//  So: one page. The tool is section one, the reading is the body, the consult
//  is the last tile. This file is the content; `ttc_focus_screen.dart` renders
//  it. Nothing here knows about widgets.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY THE TILES ARE A SEALED UNION AND NOT ONE CLASS WITH NULLABLE FIELDS
//  ---------------------------------------------------------------------------
//
//  The obvious model is a single `Tile` with `format`, `surfaceId?`, `readId?`,
//  `productId?`, `myth?`, `cards?` and so on. It compiles, it is shorter to
//  write, and it is the exact shape CLAUDE.md names as forbidden: "a config
//  object that can express more states than the product has is a bug surface,
//  not flexibility."
//
//  With eight formats and seven payload fields that object can express roughly
//  a thousand states, of which eight are legal. A Myth tile with a `productId`
//  and no `fact` is constructible, passes analysis, and fails at runtime on a
//  screen nobody opened during review.
//
//  A sealed hierarchy makes the illegal states unrepresentable instead: a
//  `TtcVideoTile` HAS a slot id because its constructor requires one, and has
//  no `productId` because the field does not exist. The renderer's switch is
//  then exhaustive — add a ninth format and the compiler names the screen that
//  has not handled it, rather than the app rendering a blank card.
//
//  The cost, stated honestly: eight small classes instead of one, and adding a
//  format touches two files rather than one. That is the right trade at eight
//  formats. At two it would be ceremony.
//
//  ---------------------------------------------------------------------------
//  ⚠️ ENGLISH ONLY, AND THE SENTENCES ARE SHORT ON PURPOSE
//  ---------------------------------------------------------------------------
//
//  Plain `String`, not `LocalizedText`. New copy is English — CLAUDE.md, decided
//  2026-08-27 — and the existing Devanagari elsewhere in the stage stays
//  exactly as it is.
//
//  The register is deliberate and is not "simple because the reader is simple".
//  Most of this audience reads English as a second or third language, so the
//  rule for every line here is: one idea per sentence, the common word over the
//  precise-sounding one, and no clause stacked on a clause. "Some things really
//  help. Some things do not." is not a rewrite of a better sentence — it IS the
//  sentence. Do not make these more formal or more clinical later; that is a
//  regression, not a polish.
// =============================================================================

// ⚠️ `show`, NOT A BARE IMPORT. `ttc_hubs.dart` pulls in the whole hub-config
// graph and Flutter's material library with it; this file needs exactly one
// string constant from it. Naming that one keeps the dependency legible and
// stops a data file quietly acquiring a UI framework.
//
// The constant rather than the literal because `'ttc_consult'` is an IDENTITY —
// it is matched by the action router, and a second copy of it here is a second
// place for it to drift.
import '../screens/ttc/ttc_illustrations.dart';
import 'focus/ttc_focus_conceiving.dart';
import 'focus/ttc_focus_ivf.dart';
import 'focus/ttc_focus_pcos.dart';

export 'focus/ttc_focus_conceiving.dart';
export 'focus/ttc_focus_ivf.dart';
export 'focus/ttc_focus_pcos.dart';

/// What kind of thing a tile is. Drives the chip, the icon and the shape.
enum TtcTileFormat {
  masterclass,
  tool,
  article,
  carousel,
  video,
  mythFact,
  product,
  booking,
}

extension TtcTileFormatCopy on TtcTileFormat {
  /// The chip on the tile. Short, because it sits beside a title that matters
  /// more than it does.
  String get label => switch (this) {
        TtcTileFormat.masterclass => 'Masterclass',
        TtcTileFormat.tool => 'Tool',
        TtcTileFormat.article => 'Article',
        TtcTileFormat.carousel => 'Carousel',
        TtcTileFormat.video => 'Video',
        TtcTileFormat.mythFact => 'Myth vs fact',
        TtcTileFormat.product => 'Product',
        TtcTileFormat.booking => 'Booking',
      };

  /// ⚠️ THE TWO THAT COST MONEY SAY SO ON THE TILE, not at the checkout.
  ///
  /// A shop tile that looks like a free tile is the pattern this stage is most
  /// exposed to: eight of the twenty-five tiles on the conceiving page are
  /// content, and the two that are not must be legible as such before she taps,
  /// not after. Read by the renderer to pick a different treatment entirely.
  bool get isPaid =>
      this == TtcTileFormat.masterclass || this == TtcTileFormat.product;
}

/// One card inside a carousel.
class TtcCarouselCard {
  const TtcCarouselCard(
      {required this.title, this.body = '', this.art, this.hue});

  /// ⚠️ THE WHOLE SLIDE, IN ONE LINE. These used to be a short label ("Smoking
  /// and alcohol") over a paragraph, which is a list item pretending to be a
  /// slide. The reference writes each slide as a complete sentence that teaches
  /// one step — "It all starts in the testes, where sperm are produced" — and
  /// that is the difference between a carousel someone finishes and a carousel
  /// someone swipes past.
  final String title;

  /// Optional supporting line. Often empty: the picture is the explanation.
  final String body;

  /// The drawn picture for this slide.
  final TtcArt? art;

  /// ⚠️ THIS SLIDE'S OWN GROUND, NOT THE SECTION'S.
  ///
  /// The reference gives every card in a story a different colour, and the
  /// effect is not decoration: a story on one flat ground reads as a document
  /// that happens to swipe, and you lose the sense of having moved. A colour
  /// change per slide is the cheapest possible "you are somewhere new" — it is
  /// what makes six screens feel like six beats instead of one long page.
  ///
  /// Null inherits the section hue, so a carousel that has not been coloured
  /// still looks deliberate rather than unfinished.
  final double? hue;
}

// -----------------------------------------------------------------------------
//  The tiles
// -----------------------------------------------------------------------------

sealed class TtcTile {
  const TtcTile({required this.title, required this.blurb});

  /// Short and plain. The one line she reads.
  final String title;

  /// One line under it saying what she gets. Required, not optional — a tile
  /// whose title has to carry the whole explanation ends up as a sentence in
  /// bold, and the same rule already governs `HubNeed.blurb` and
  /// `JourneyElement.value`.
  final String blurb;

  TtcTileFormat get format;
}

/// Opens a screen that already exists elsewhere in the stage.
final class TtcToolTile extends TtcTile {
  const TtcToolTile(
      {required super.title, required super.blurb, required this.surfaceId});

  /// ⚠️ A SURFACE ID, NOT A WIDGET. The tool is built, shipped and tested; this
  /// opens it through `openTtcSurface` so the route NAME stays the surface id —
  /// which is what `global_ask_fab.dart` reads to decide which Ask Veda opens.
  /// Constructing the screen here would work and would quietly break that.
  final String surfaceId;

  @override
  TtcTileFormat get format => TtcTileFormat.tool;
}

/// Something to read.
final class TtcArticleTile extends TtcTile {
  const TtcArticleTile({
    required super.title,
    required super.blurb,
    this.body = const [],
    this.readId,
    this.moreReadId,
    this.art,
    this.imageUrl,
  });

  /// The hero picture, used BOTH as the card's thumbnail on the rail and as the
  /// header of the piece itself. One image in two places on purpose — watching
  /// the card you tapped become the page's header is what makes them feel like
  /// one object rather than a link to another.
  final TtcArt? art;

  /// A real photograph, loaded at runtime.
  ///
  /// ⚠️ A URL IN DATA, EXACTLY AS `product_data.dart` ALREADY DOES IT. Unsplash,
  /// sized with the same `?w=&h=&fit=crop` query the product catalogue uses, so
  /// the two behave identically on a slow connection.
  ///
  /// ⚠️ AND [art] IS THE FALLBACK, NOT AN ALTERNATIVE. Local-first is absolute
  /// in this repo: a cloud failure is never a crash and never a blank. On a
  /// dead connection the drawn illustration renders in its place and the page
  /// is still complete — which is also why the drawn art was worth having even
  /// once photographs exist.
  final String? imageUrl;

  /// The answer, in a few short paragraphs, shown in a sheet.
  final List<String> body;

  /// Opens the full long-form reader instead of a sheet. Used where a
  /// clinically-reviewed `PvRead` already answers exactly this question — those
  /// are better than anything restated here, and restating them is how two
  /// copies of one fact drift apart.
  final String? readId;

  /// ⚠️ THE SHORT ANSWER FIRST, THE LONG ONE ONE TAP AWAY. Used where a read
  /// exists but is BROADER than the tile's promise: "Folic acid: why she needs
  /// it" opening a general preconception article is the wrong-screen failure,
  /// so the sheet answers the actual question and offers the fuller piece under
  /// it.
  final String? moreReadId;

  @override
  TtcTileFormat get format => TtcTileFormat.article;
}

/// A few cards, swiped.
final class TtcCarouselTile extends TtcTile {
  const TtcCarouselTile(
      {required super.title,
      required super.blurb,
      required this.cards,
      this.art,
      this.reviewedBy,
      this.coverTitle,
      this.coverBlurb,
      this.coverHue});

  final List<TtcCarouselCard> cards;

  /// The card's thumbnail on the rail.
  final TtcArt? art;

  /// Shown on every slide. The cheapest trust signal a clinical carousel has.
  final String? reviewedBy;

  /// ⚠️ A COVER BEFORE THE FIRST SLIDE. Opening straight onto "His half is half
  /// of it" drops the reader mid-argument with no idea how long this is or what
  /// it covers. The reference opens every one of these on a title card for the
  /// same reason a book has one.
  final String? coverTitle;
  final String? coverBlurb;
  final double? coverHue;

  @override
  TtcTileFormat get format => TtcTileFormat.carousel;
}

/// A film. None of them exist yet — see the slot note.
final class TtcVideoTile extends TtcTile {
  const TtcVideoTile({
    required super.title,
    required super.blurb,
    required this.slotId,
    required this.duration,
  });

  final String slotId;

  /// "4 MIN". Shown on the thumbnail where a real one shows it, so the
  /// placeholder occupies the real geometry — the rule at the head of
  /// `pv_placeholders.dart`.
  final String duration;

  @override
  TtcTileFormat get format => TtcTileFormat.video;
}

/// A thing people believe, and what is actually true.
///
/// ⚠️ THE MOST USEFUL SINGLE COMPONENT IN A FERTILITY PRODUCT, which is why it
/// is a format rather than a paragraph inside an article. This stage competes
/// with a very large volume of confident nonsense, and the answer to "should
/// she lie down for twenty minutes after" is not an essay — it is two lines,
/// one of which says "no evidence". Same reasoning as `PvMythFact`.
final class TtcMythTile extends TtcTile {
  const TtcMythTile({
    required super.title,
    required super.blurb,
    required this.myth,
    required this.fact,
    this.slides = const [],
  });

  /// The claim, in the words people actually use.
  final String myth;

  /// What is true. Plain, and never hedged into uselessness.
  final String fact;

  /// ⚠️ A MYTH IS A STORY NOW, NOT TWO BOXES. Two stacked panels state the
  /// correction; they do not teach why the belief exists or what is actually
  /// going on, so the reader leaves knowing an answer rather than a mechanism —
  /// and a mechanism is what stops the NEXT version of the same myth landing.
  ///
  /// The slides run: the claim, where it came from, what the body actually
  /// does, and what that means for her. Empty falls back to the two blocks.
  final List<TtcCarouselCard> slides;

  @override
  TtcTileFormat get format => TtcTileFormat.mythFact;
}

/// Something to buy.
final class TtcProductTile extends TtcTile {
  const TtcProductTile(
      {required super.title, required super.blurb, required this.productId});

  final String productId;

  @override
  TtcTileFormat get format => TtcTileFormat.product;
}

/// A paid course.
final class TtcMasterclassTile extends TtcTile {
  const TtcMasterclassTile(
      {required super.title, required super.blurb, required this.offeringId});

  final String offeringId;

  @override
  TtcTileFormat get format => TtcTileFormat.masterclass;
}

/// Time with a real person.
final class TtcBookingTile extends TtcTile {
  const TtcBookingTile(
      {required super.title, required super.blurb, required this.action});

  /// A hub action, resolved by the caller — never a booking flow rebuilt here.
  final String action;

  @override
  TtcTileFormat get format => TtcTileFormat.booking;
}

// -----------------------------------------------------------------------------
//  Sections and pages
// -----------------------------------------------------------------------------

/// A heading and the tiles under it.
///
/// ⚠️ THE HEADING IS ALWAYS A PLAIN QUESTION, and never a format name. "When
/// should we have sex?" is a section; "Articles" is not. The moment a format
/// becomes a heading the page stops being organised by what she wants to know
/// and starts being organised by how we happened to build it — which is the
/// content-management view of a product, and it is never the reader's.
class TtcFocusSection {
  const TtcFocusSection({required this.heading, required this.tiles});

  final String heading;
  final List<TtcTile> tiles;
}

/// One problem area, as one scrollable page.
class TtcFocusPage {
  const TtcFocusPage({
    required this.bracketId,
    required this.intro,
    required this.sections,
    this.heroVideoSlot,
    this.heroVideoTitle,
    this.headline,
  });

  /// Which bracket tile opens this. Matches a `Bracket.id`.
  final String bracketId;

  /// ⚠️ THERE IS NO `title` FIELD, AND ITS ABSENCE IS THE FIX.
  ///
  /// This page used to carry its own title, set to "Getting pregnant". The tile
  /// that opens it says "Fertile window". So she tapped one name and arrived at
  /// a different one, which reads as having landed somewhere else — the single
  /// most disorienting thing a navigation can do, and it survived review
  /// because both strings are individually good.
  ///
  /// The page now takes its heading from the BRACKET it belongs to, so the tile
  /// and the page are the same string by construction and cannot be edited
  /// apart. See `TtcFocusScreen`, which is handed the bracket rather than a
  /// title and a hue.
  ///
  /// The general rule, worth carrying to the next screen: when two places must
  /// show the same words, do not write the words twice and trust a reviewer to
  /// notice. Give one of them a reference to the other.
  final String intro;

  /// The film at the top, in place of a support paragraph.
  final String? heroVideoSlot;

  /// ⚠️ THE FILM'S NAME, NOT THE PAGE'S. These were briefly the same string,
  /// which put "Getting pregnant" as the heading and again on the thumbnail
  /// under it. A page title says where you are; a video title says what the
  /// video is — and when they match, the thumbnail carries no information.
  /// Second time this exact mistake has been made on this stage.
  final String? heroVideoTitle;

  /// One paid tile directly under the intro, above every section.
  final TtcMasterclassTile? headline;

  final List<TtcFocusSection> sections;

  /// Every tile on the page, in reading order. What the reachability test walks.
  List<TtcTile> get allTiles =>
      [?headline, for (final s in sections) ...s.tiles];
}

// =============================================================================
//  The registry
// -----------------------------------------------------------------------------
//  ⚠️ THE PAGES THEMSELVES LIVE IN `focus/`, ONE FILE PER BRACKET. This file
//  keeps the model — `TtcTile` and its subclasses, `TtcTileFormat`,
//  `TtcFocusSection`, `TtcFocusPage` — and the lookup. Splitting the content
//  out means five doors can be built in parallel without five conflicts in one
//  file; see the header of any file in `focus/`.
// =============================================================================

const List<TtcFocusPage> kTtcFocusPages = [
  kTtcConceivingFocus,
  kTtcPcosFocus,
  kTtcIvfFocus,
];

/// The page for a bracket, or null when that bracket still uses a hub.
///
/// ⚠️ NULL IS THE NORMAL ANSWER. Six of the seven TTC brackets still open a hub
/// and should — a hub is right when an area genuinely splits into separate
/// errands. Conceiving was not one of those: its three doors were one job cut
/// into three. Adding a focus page for an area is a judgement about that area,
/// never a migration to run across all of them.
TtcFocusPage? ttcFocusPageFor(String bracketId) {
  for (final page in kTtcFocusPages) {
    if (page.bracketId == bracketId) return page;
  }
  return null;
}
