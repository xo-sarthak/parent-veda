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
// ⚠️ `show IconData`, NARROWED FOR THE SAME REASON THE HUB IMPORT BELOW IS.
// One class off the material library, named, so a data file does not quietly
// acquire a UI framework.
import 'package:flutter/material.dart' show IconData;

import '../screens/ttc/ttc_illustrations.dart';
// The new door's drawn tab marks (`TtcFocusGroup.mark`). Exported below so a
// focus file can name `IntentMark.cycleRing` without a second import.
import '../screens/brackets/hub/hub_intent_art.dart' show IntentMark;
// The TTC tab family (2026-09-27), narrowed and exported the same way.
import '../screens/ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import 'focus/ttc_focus_conceiving.dart';
import 'focus/ttc_focus_after_loss.dart';
import 'focus/ttc_focus_mind_body.dart';
import 'focus/ttc_focus_getting_ready.dart';
import 'focus/ttc_focus_his_side.dart';
import 'focus/ttc_focus_ivf.dart';
import 'focus/ttc_focus_pcos.dart';
import 'focus/ttc_focus_body_cycle.dart';
import 'focus/ttc_focus_not_yet.dart';

export 'focus/ttc_focus_conceiving.dart';
export 'focus/ttc_focus_ivf.dart';
export 'focus/ttc_focus_pcos.dart';
export '../screens/brackets/hub/hub_intent_art.dart' show IntentMark;
export '../screens/ttc/doors/ttc_tab_art.dart' show TtcTabMark;

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
  recipe,
  community,
  infographic,
  practice,
  checklist,
  talk,
  guide,
  door,
}

extension TtcTileFormatCopy on TtcTileFormat {
  /// The chip on the tile. Short, because it sits beside a title that matters
  /// more than it does.
  String get label => switch (this) {
        TtcTileFormat.masterclass => 'Masterclass',
        TtcTileFormat.tool => 'Tool',
        // "Practice", not "Do" (launch sanity MB15, 2026-09-28): "Do" is not
        // a word she would use for a kind of thing. Kept for revert: 'Do',
        TtcTileFormat.practice => 'Practice',
        TtcTileFormat.checklist => 'Checklist',
        TtcTileFormat.guide => 'Guide',
        TtcTileFormat.talk => 'Talk',
        TtcTileFormat.article => 'Article',
        TtcTileFormat.carousel => 'Carousel',
        TtcTileFormat.video => 'Video',
        TtcTileFormat.mythFact => 'Myth vs fact',
        TtcTileFormat.product => 'Product',
        TtcTileFormat.booking => 'Booking',
        TtcTileFormat.recipe => 'Recipe',
        TtcTileFormat.community => 'Community',
        TtcTileFormat.infographic => 'Infographic',
        // ⚠️ "Elsewhere", NOT "Reference". The chip is a promise about what
        // the tap does, and "reference" is a word from our content model that
        // means nothing to a reader. "Elsewhere" says the one thing she needs
        // to know before tapping: this leaves the door you are on.
        TtcTileFormat.door => 'Elsewhere',
      };

  /// ⚠️ WHAT PARENTVEDA CHARGES FOR — and a product is not on that list.
  ///
  /// The rule it enforces is still right: a tile that costs money must be
  /// legible as such BEFORE she taps, not at a checkout. Eight of the
  /// twenty-five tiles on the conceiving page are content, and the ones that
  /// are not have to declare themselves.
  ///
  /// ⚠️ `product` WAS IN THIS LIST AND WAS REMOVED — 2026-09-03.
  ///
  /// It made a product card render in the amber paid treatment with its chip
  /// reading **"Paid"** instead of **"Product"** — the same treatment a
  /// masterclass gets. Reported plainly: *"Cards out there like product instead
  /// of paid, showing it differently as if it's a course or some specialty. It
  /// is a product. That's it. We can have a product tag."*
  ///
  /// And it was wrong in substance, not only in style. **ParentVeda does not
  /// sell these, does not earn from them and is not paid to list them** — there
  /// is no cart, no retailer and no affiliate relationship in this stage. A
  /// product tile opens a research page carrying an indicative price range and
  /// an honest recommendation band, one of which reads "generally not needed".
  /// Marking that "Paid" told the reader we were charging for it, which is the
  /// opposite of what the page says.
  ///
  /// It also flattened the distinction the chip exists to draw: "Paid" over a
  /// product and "Paid" over a masterclass are the same words for two entirely
  /// different transactions — one is a course we sell, the other is a bottle
  /// somebody else sells.
  ///
  /// If this stage ever gains affiliate links, that is a **disclosure on the
  /// product page** — the interstitial the design specifies — and still not a
  /// price tag on the card. See `docs/STILL-OPEN.md` §24.3.
  bool get isPaid => this == TtcTileFormat.masterclass;
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
  const TtcTile({
    required this.title,
    required this.blurb,
    this.meta,
    this.keywords = const [],
    this.id,
  });

  /// ⚠️ A STABLE ID, SO A PHOTO SURVIVES A RETITLE (2026-09-28). The door
  /// keys a card's own photograph by `ttcTilePhotoId`, which used to be the
  /// title only, and photos broke seven times on the day cards were retitled.
  /// Where this is set it IS the photo key, so its value is the key the photo
  /// was filed under (`ttc_tile_<the title it had then>`), which is also the
  /// photo's file name on R2: never rename an id, only a title. Null keeps the
  /// title rule. Set on the Fertile window door first; the other doors keep
  /// the title rule until they are moved one by one.
  ///
  /// ⚠️ EVERY DOOR TILE HAS ONE SINCE 2026-09-29, on all nine doors: the key
  /// its photo was filed under that day (`ttcTileTitleKey` of the title it had
  /// then). A new tile is born with `ttcTileTitleKey(title)` and keeps it.
  /// `ttc_door_photos_test.dart` fails on a tile without one.
  final String? id;

  /// Short and plain. The one line she reads.
  final String title;

  /// One line under it saying what she gets. Required, not optional — a tile
  /// whose title has to carry the whole explanation ends up as a sentence in
  /// bold, and the same rule already governs `HubNeed.blurb` and
  /// `JourneyElement.value`.
  final String blurb;

  /// One small fact above the title on the new door (`TtcDoorScreen`), where
  /// it helps her decide before tapping: "6 min read", "5 min film".
  ///
  /// ⚠️ OPTIONAL, AND USUALLY LEFT NULL ON PURPOSE (2026-09-26). The door
  /// derives the common cases itself (`ttcDoorTileMeta`): a read's minutes come
  /// from `PvRead.minutes`, which is computed from the words, and a film's from
  /// its `duration`. A number typed here goes stale the day the read is
  /// rewritten, so set this only for a fact the door cannot work out.
  /// The old `TtcFocusScreen` never reads it.
  final String? meta;

  /// Extra words the door's search matches on, beyond the title and blurb —
  /// the word she would type that the title does not use ("HSG", "sperm
  /// test", "AMH"). Read only by `ttc_door_search.dart`.
  final List<String> keywords;

  TtcTileFormat get format;
}

/// Opens a screen that already exists elsewhere in the stage.
final class TtcToolTile extends TtcTile {
  const TtcToolTile(
      {required super.title, required super.blurb, super.meta, super.keywords, super.id, required this.surfaceId});

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
    required super.blurb, super.meta, super.keywords, super.id,
    this.body = const [],
    this.readId,
    this.moreReadId,
    this.art,
    this.imageUrl,
    this.atHeading,
  });

  /// Open the read scrolled to this section. See `TtcGuideTile.atHeading`.
  final String? atHeading;

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

/// One side of an infographic's comparison.
class TtcInfographicColumn {
  const TtcInfographicColumn(
      {required this.label, required this.points, this.hue});

  /// What this side IS. Short — it sits above the points in a half-width box.
  final String label;

  /// WARNING: THREE OR FOUR, NEVER MORE. A fifth point is the moment this
  /// stopped being one frame, and the format's whole promise is that it is one
  /// frame. Nothing enforces the count in code because a number in a lint
  /// invites arguing with the number; the rule is in the header of
  /// `ttc_infographic_screen.dart` and in this sentence.
  final List<String> points;

  /// The column's own tint. Two different hues is what makes the comparison
  /// read as two things rather than one list split in half.
  final double? hue;
}

/// One frame that answers its own title. No swiping.
///
/// WARNING: ONE SLIDE, AND THAT IS THE DEFINITION RATHER THAN A PREFERENCE.
/// Asked for exactly that way: *"infographic only consists of 1 slide, so keep
/// that in mind — in one slide provide required info."*
///
/// So there is no `cards` list and no `slides` here, deliberately: there is
/// nowhere for a second frame to go, and a subject that needs one was never an
/// infographic. Both tiles that use it are "X or Y" questions, which is the
/// shape a single frame beats a carousel at — the two halves sit side by side,
/// so the difference IS the picture rather than something the reader has to
/// carry across a swipe.
final class TtcInfographicTile extends TtcTile {
  const TtcInfographicTile({
    required super.title,
    required super.blurb, super.meta, super.keywords, super.id,
    required this.headline,
    required this.left,
    required this.right,
    this.footnote,
    this.reviewedBy,
  });

  /// The answer, in one line, above the comparison.
  ///
  /// WARNING: NOT A RESTATEMENT OF THE TITLE. The title is the question she
  /// tapped; a headline that repeats it spends her first look on nothing.
  final String headline;

  final TtcInfographicColumn left;
  final TtcInfographicColumn right;

  /// What to do about it. On a clinical comparison this is where the reader
  /// stops being merely better informed.
  final String? footnote;

  final String? reviewedBy;

  @override
  TtcTileFormat get format => TtcTileFormat.infographic;
}

/// A few cards, swiped.
final class TtcCarouselTile extends TtcTile {
  const TtcCarouselTile(
      {required super.title,
      required super.blurb, super.meta, super.keywords, super.id,
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
    required super.blurb, super.meta, super.keywords, super.id,
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
    required super.blurb, super.meta, super.keywords, super.id,
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
/// Something to buy — either one product, or a whole shelf of them.
///
/// ⚠️ THE SHELF FORM WAS MISSING AND IT COST A REBUILD. 2026-09-03.
///
/// This tile could only ever name ONE product. So a brief row reading
/// *"Folic acid and preconception supplements — Product"* — which plainly means
/// "open the supplements shelf" — had no form to be built in, and it went out
/// as `TtcToolTile(surfaceId: 'ttc_supplements')` instead. That surface is the
/// supplements TRACKER: a record of what she took today. Tapping a card about
/// what to buy landed on a compliance grid.
///
/// Reported bluntly, and correctly: *"It was a product section to buy
/// something. What you have wired in is 'what medication was taken'. How does
/// that make any sense?"*
///
/// The lesson is not "read the brief harder". A model that cannot express what
/// a brief asks for will get a near-miss substituted for it, every time,
/// because the person building it reaches for the closest thing that compiles.
/// The fix is the missing form.
final class TtcProductTile extends TtcTile {
  /// One product, straight to its page.
  const TtcProductTile(
      {required super.title, required super.blurb, super.meta, super.keywords, super.id, required this.productId})
      : category = null;

  /// A whole shelf — every product in one category, ranked, with the
  /// recommendation band on each card.
  const TtcProductTile.shelf(
      {required super.title, required super.blurb, super.meta, super.keywords, super.id, required this.category})
      : productId = null;

  /// Exactly one of these is set, and which one decides where it opens.
  final String? productId;
  final String? category;

  @override
  TtcTileFormat get format => TtcTileFormat.product;
}

/// A guide — a piece written to be USED rather than read through.
///
/// ⚠️ IT OPENS THE SAME READER AS AN ARTICLE, AND ONLY THE CHIP DIFFERS. That
/// is deliberate and it is the whole justification: the format system's rule in
/// this file is that a chip is the promise about what happens when she taps,
/// and "Article" over "The carrier screening that matters in India" promises
/// something to read on a train. It is not that — it is a thing you act on,
/// take to a doctor, and ask for by name.
///
/// ⚠️ AND IT WAS BUILT AS AN ARTICLE FIRST, ON PURPOSE. The brief's format
/// column said Guide; its Step 2 said "formats and badges as before, plus Do
/// and Talk", and Guide was not among them. Rather than invent a chip nobody
/// had asked for — the exact habit that put four wrong formats on this door —
/// it shipped as an Article with the deviation written into the brief table,
/// and the badge was added when it was asked for.
///
/// The content standard is identical to an article's: a `PvRead`, four
/// sections, a contents, an FAQ, sourcing and a when-to-see-someone. A guide is
/// not a lower bar wearing a different word.
final class TtcGuideTile extends TtcTile {
  const TtcGuideTile({
    required super.title,
    required super.blurb, super.meta, super.keywords, super.id,
    required this.readId,
    this.atHeading,
  });

  /// Must exist in `kTtcReads`, exactly like an article's.
  final String readId;

  /// Open the read scrolled to this section, matched on the heading text.
  ///
  /// ⚠️ THIS IS WHAT MAKES "PROMOTE" REAL. The After-a-loss rebuild asks for
  /// cards that reference a SECTION of an existing article — single source,
  /// shown twice, never copied. Without an anchor, six such cards all open one
  /// article at the top and the woman who tapped "Rh status and retained
  /// tissue" is left hunting through two thousand words for the paragraph she
  /// was promised.
  ///
  /// See `PvReaderScreen.openAtHeading` for why it matches on text rather than
  /// on an index.
  final String? atHeading;

  @override
  TtcTileFormat get format => TtcTileFormat.guide;
}

/// A checklist — a thing with items you tick, not a tool you operate.
///
/// ⚠️ THE BRIEF NAMES THIS FORMAT AND IT WAS BUILT AS `Tool`. The chip is the
/// promise about what happens when she taps, and "Tool" over "Your
/// pre-pregnancy checklist" describes the wrong kind of object — a checklist is
/// something you come back to and add to, not something you use once.
final class TtcChecklistTile extends TtcTile {
  const TtcChecklistTile(
      {required super.title, required super.blurb, super.meta, super.keywords, super.id, required this.surfaceId});

  final String surfaceId;

  @override
  TtcTileFormat get format => TtcTileFormat.checklist;
}

/// Time with a person, reached by asking rather than by booking a slot.
///
/// ⚠️ THE BRIEF ASKS FOR THIS FORMAT BY NAME — "plus Do : run and Talk :
/// message" — and it was built as `TtcBookingTile`, whose chip reads "Booking".
/// The two are not the same promise. "Booking" says a calendar and a slot;
/// "Talk" says a person and a conversation, which is what "Talk to someone
/// before you start" is offering somebody who has not started trying yet.
final class TtcTalkTile extends TtcTile {
  const TtcTalkTile(
      {required super.title, required super.blurb, super.meta, super.keywords, super.id, required this.action});

  /// A hub action, resolved by the caller — the same booking engine underneath.
  /// Only the promise on the card differs.
  final String action;

  @override
  TtcTileFormat get format => TtcTileFormat.talk;
}

/// A dish, on the app's own recipe page.
///
/// WARNING: A NINTH FORMAT, AND THE HEADER OF THIS FILE ARGUES FOR PAYING THAT
/// COST RATHER THAN AVOIDING IT. The alternative was a `TtcToolTile` pointing
/// at the recipe screen, which compiles and is wrong in the one way this stage
/// cannot afford: the chip would read "Tool" over a dish. The chip is the
/// promise about what happens when she taps, and eight of the twenty-five tiles
/// on a page are content -- a chip that lies is worse than a missing format.
///
/// WARNING: AND IT REUSES THE SHIPPED RECIPE PAGE, NOT A TTC COPY OF ONE.
/// `RecipeDetailScreen` already scales ingredients to a chosen serving count,
/// lists steps and carries a nutrition glance. Asked for directly: *"we have
/// recipe page format so do that."*
final class TtcRecipeTile extends TtcTile {
  const TtcRecipeTile(
      {required super.title, required super.blurb, super.meta, super.keywords, super.id, required this.recipeId});

  /// Must exist in `kRecipes`. Held by `ttc_focus_page_test.dart` for the same
  /// reason every other id here is: a tile whose id is wrong renders perfectly
  /// and does nothing.
  final String recipeId;

  @override
  TtcTileFormat get format => TtcTileFormat.recipe;
}

/// A room full of other people going through the same thing.
///
/// WARNING: A TENTH FORMAT FOR ONE TILE, AND THE SAME ARGUMENT AS THE NINTH.
/// The alternative was a `TtcToolTile` pointing at the community screen, which
/// compiles and puts the chip "Tool" over "PCOS circle". A circle of people is
/// not a tool, and the chip is the promise about what happens when she taps --
/// on a page where eight tiles are content and two cost money, a chip that
/// misdescribes its destination is the one thing the format system exists to
/// prevent.
///
/// WARNING: AND THE COMMUNITY IS NEVER A SOURCE. Ask Veda's own rule, and it
/// holds here too: this tile opens a room, it does not answer a question. No
/// clinical claim on this page may point at it.
final class TtcCommunityTile extends TtcTile {
  const TtcCommunityTile(
      {required super.title, required super.blurb, super.meta, super.keywords, super.id, required this.surfaceId});

  /// Resolved by `ttcScreenForSurface`, like a tool's.
  final String surfaceId;

  @override
  TtcTileFormat get format => TtcTileFormat.community;
}

/// Something to practise, rather than something to read or operate.
///
/// WARNING: A TWELFTH FORMAT, AND THE SAME ARGUMENT AS THE NINTH AND TENTH.
/// The alternative was `TtcToolTile` pointing at the checklist's lifestyle
/// section, which compiles and puts the chip "Tool" over "Habits worth building
/// now". Sleep, movement and cutting down are not a tool — a tool is a thing
/// you operate and put down, and these are things you do for weeks. The chip is
/// the promise about what happens when she taps, and on a page of twenty tiles
/// a chip that misdescribes its destination is precisely what the format system
/// exists to prevent.
///
/// WARNING: AND IT NEVER SCORES OR GRADES. Habit content in a fertility app is
/// one careless step from a streak, and a streak turns "I did not sleep well"
/// into a failure at the exact moment somebody is already blaming her body. The
/// tiles open the checklist and the trackers, which record without ranking.
final class TtcDoTile extends TtcTile {
  const TtcDoTile(
      {required super.title, required super.blurb, super.meta, super.keywords, super.id, required this.surfaceId});

  /// Resolved by `ttcScreenForSurface`, exactly like a tool's — the difference
  /// is what the chip promises, not how it opens.
  final String surfaceId;

  @override
  TtcTileFormat get format => TtcTileFormat.practice;
}

/// A card that opens a DIFFERENT door.
///
/// ⚠️ A SIXTEENTH FORMAT, AND THE HEADER OF THIS FILE ARGUES FOR JUSTIFYING
/// EACH ONE. This is the first tile whose destination is not a piece of content
/// or a surface but another focus area, and nothing already here can express
/// that: `TtcToolTile` would promise a tool, `TtcGuideTile` needs a `readId`.
///
/// ⚠️ AND MOST OF THE BRIEF'S "reference" CARDS ARE *NOT* THIS. Mind & body's
/// brief marks nine cards `reference` — "opens an item owned by another focus
/// area, do not re-teach it here". Eight of them name an ARTICLE that Getting
/// ready owns, and the honest build for those is an ordinary `TtcArticleTile`
/// carrying Getting ready's own `readId`: same article, one copy, and the chip
/// says "Article", which is what actually happens when she taps.
///
/// Only "His part of this" genuinely points at an AREA rather than a piece, and
/// that is the card this format exists for. Adding a "Reference" chip for the
/// other eight would have been a chip that describes our content model instead
/// of describing the tap — nobody outside this repo knows what a reference is.
final class TtcDoorTile extends TtcTile {
  const TtcDoorTile(
      {required super.title,
      required super.blurb,
      super.meta,
      super.keywords, super.id,
      required this.bracketId,
      this.group});

  /// Must resolve through `ttcFocusPageFor`. An unknown id opens nothing, which
  /// `ttc_mind_body_test.dart` checks for — the wiring gate, again.
  final String bracketId;

  /// The tab the door opens on (2026-09-27, relevance audit): "Mind and body"
  /// from Taking a while means its Hard days, not its first tab. Null opens
  /// the door as usual.
  final String? group;

  @override
  TtcTileFormat get format => TtcTileFormat.door;
}

/// A paid course.
final class TtcMasterclassTile extends TtcTile {
  const TtcMasterclassTile(
      {required super.title, required super.blurb, super.meta, super.keywords, super.id, required this.offeringId});

  final String offeringId;

  @override
  TtcTileFormat get format => TtcTileFormat.masterclass;
}

/// Time with a real person.
final class TtcBookingTile extends TtcTile {
  const TtcBookingTile(
      {required super.title, required super.blurb, super.meta, super.keywords, super.id, required this.action});

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
  const TtcFocusSection({
    required this.heading,
    required this.tiles,
    this.group,
  });

  final String heading;
  final List<TtcTile> tiles;

  /// Which [TtcFocusGroup] this section appears under, on a page that has them.
  ///
  /// ⚠️ THE SECTION NAMES ITS GROUP, NOT THE OTHER WAY ROUND. The obvious model
  /// is a group holding a list of sections, or a list of the headings it owns.
  /// Both let a section belong to two groups, or to none, and neither failure
  /// looks like anything — the section simply renders twice, or vanishes.
  ///
  /// Naming it from this side makes both impossible: there is one field, so
  /// there is one answer. `test/ttc_focus_groups_test.dart` then only has to
  /// check that the id exists, which is a question with a yes or a no.
  ///
  /// ⚠️ STALE ABOVE, CORRECTED 2026-09-04. This said "null on every page that
  /// is one long scroll, which is all of them but PCOS", which was true for
  /// about a day. All six doors carry a rail now, so a null here means a
  /// section on a grouped page that renders in NO tab — the failure
  /// `ttc_focus_groups_test.dart` checks for, and one that looks like nothing.
  final String? group;
}

/// One card in the selector rail at the top of a grouped page.
///
/// ⚠️ THIS IS THE SHAPE THAT WAS ASKED FOR AFTER SEEING FLO, AND IT OVERRULES
/// THE NOTE THAT USED TO SIT AT THE HEAD OF `ttc_focus_pcos.dart`.
///
/// The original brief asked for five sub-tabs and that was set aside, on the
/// grounds that a tab is a decision she has to make before she is allowed to
/// see anything. That reasoning was about a **tab bar** — a row of words where
/// picking one hides the other four and nothing tells you what is behind them.
///
/// This is not that. The selector is a horizontal rail of picture cards, in the
/// same language as every other rail on the page, and it is the FIRST thing
/// under the hero: she scrolls past all five before she chooses, so the choice
/// is made after seeing the options rather than before. That is the difference
/// the earlier objection was actually pointing at, and it is now handled.
///
/// ⚠️ ROLLED OUT TO PCOS ONLY, ON PURPOSE. The other doors keep the single
/// scroll until this has been seen on a device. `groups` being null is not a
/// migration waiting to finish — it is the other shape, still correct.
class TtcFocusGroup {
  const TtcFocusGroup({
    required this.id,
    required this.label,
    required this.icon,
    required this.hue,
    this.toolSurfaceId,
    this.pinnedRedFlagReadIds = const [],
    this.note,
    this.mark,
    this.tabMark,
    this.inlineLabel,
    this.inlineSurfaceId,
  });

  // ---------------------------------------------------------------------------
  //  The new door (TtcDoorScreen, 2026-09-26) — three optional fields
  // ---------------------------------------------------------------------------
  //  ⚠️ ADDITIVE, SO THE OLD SCREEN IS UNTOUCHED. `TtcFocusScreen` stays on
  //  disk for revert and reads none of these; the new door reads all three.
  //  Same mirror-not-merge choice as the pregnancy engine (`PvDoorGroup`).

  /// The group's DRAWN mark on the new door's straddling rail — the same
  /// hand-drawn family every pregnancy door tab wears (DESIGN-SYSTEM §4.0).
  /// Null falls back to [icon], which is what a stock glyph looks like next
  /// to drawn ones, so every tab on a shipped door has one
  /// (`test/ttc_door_screen_test.dart`).
  final IntentMark? mark;

  /// The tab's mark from the TTC tab family (`TtcTabArt`, 2026-09-27).
  ///
  /// ⚠️ PREFERRED OVER [mark], WHICH STAYS AS THE FALLBACK. The shared
  /// `IntentMark`s were drawn for pregnancy hub questions, and on a TTC tab
  /// they read as stock (the user: "very random"). This family is drawn for
  /// the rail. [mark] is kept, set and live, so a tab that loses its
  /// [tabMark] still shows a drawn mark and never an empty well.
  final TtcTabMark? tabMark;

  /// The second line on a tool tab's rail card, instead of a count. "1 thing"
  /// over a tool is true and useless. Set per tab, never inferred from the
  /// surface id: a value inferred from the first caller is wrong at the
  /// second, which is how the old rail came to call a practice "Quick check".
  final String? inlineLabel;

  /// A tool rendered in place ABOVE this tab's sections on the new door.
  ///
  /// ⚠️ ABOVE, NOT INSTEAD OF. [toolSurfaceId] is the old either/or (a tool
  /// tab had no sections); on the new door a tab may carry a tool and then
  /// its reading under it, the pregnancy shape. The new door reads
  /// `inlineSurfaceId ?? toolSurfaceId`, so the two existing tool tabs keep
  /// working without the id being written twice. Resolved by
  /// `ttcInlineToolFor`; a surface with no inline body there renders nothing.
  final String? inlineSurfaceId;

  /// One line above this group's rails.
  ///
  /// ⚠️ ADDED FOR A SAFETY LINE THAT MUST APPEAR EXACTLY ONCE. Mind & body's
  /// practice brief puts it in a heading: *"Safety line shown once on the
  /// practice tab, not on every card."* Twelve cards, one warning — and the
  /// reflex build is to put it on all twelve, which is what the first version
  /// did.
  ///
  /// ⚠️ IT IS NOT A `pinnedRedFlagReadId` AND THE DIFFERENCE MATTERS. A
  /// pinned flag renders a doctor-written `whenToSeeSomeone` callout from a
  /// real article — "go to a hospital today, not tomorrow". This is a
  /// practical caution about stretching, it has no article behind it, and
  /// dressing it as a clinical red flag would spend that alarm on the wrong
  /// thing. Quieter type, quieter box, no urgency.
  ///
  /// ⚠️ AND IT IS NOT A SECTION. A section would need tiles; this is one
  /// sentence that belongs to the tab rather than to anything in it.
  final String? note;

  /// Matched against [TtcFocusSection.group].
  /// A read whose `whenToSeeSomeone` is pinned above this group's rails.
  ///
  /// ⚠️ IT NAMES A READ, IT DOES NOT CARRY TEXT — and that is the whole design.
  /// The After-a-loss rebuild asks for two red-flag cards "always visible,
  /// never inside an accordion", and the obvious build is to type the words
  /// onto the group. That would put a clinical warning in two places: the
  /// article that a doctor wrote and reviewed, and a data file nobody reviews.
  /// The day one is updated they disagree, and the one on the landing is the
  /// one she reads first.
  ///
  /// So the group names the read, the screen renders that read's OWN callout,
  /// and there is exactly one copy of the sentence "go to a hospital today, not
  /// tomorrow".
  ///
  /// ⚠️ A LIST SINCE 2026-09-05, AND THE SINGULAR WAS A LUCKY FIT. After a
  /// loss needed two pinned flags and happened to want them on two DIFFERENT
  /// tabs, so one-per-group carried it. Mind & body's Talk tab wants both of
  /// its flags — "when this is more than the strain of waiting" and "where a
  /// practice is not the right answer" — on the same tab, from two different
  /// articles, and the singular field could not say that.
  ///
  /// Worth noticing as a pattern: a field whose cardinality was inferred from
  /// the first caller. The second caller is where you find out.
  ///
  /// ⚠️ AND THE SELF-HARM LINE TRAVELS WITH IT. The Support tab's flag carries
  /// "if you have thoughts of harming yourself… tell someone today", which the
  /// brief says explicitly must not be lost or buried. Rendering the callout
  /// whole rather than an excerpt is what guarantees that.
  final List<String> pinnedRedFlagReadIds;

  final String id;

  /// The words on the card. Short — it sits under an icon in a 150pt box.
  final String label;

  /// The line mark in the tab's well.
  ///
  /// ⚠️ AN ICON IS BACK, AND THE THIRD TIME IT IS IN A WELL. Two earlier
  /// attempts were rejected — a bare Material glyph in the corner of a white
  /// card (*"you have just used the icons basic icons"*) and a drawn mark in a
  /// tinted disc copied off the home rail (*"a lot of wasted space on that
  /// tab"*). Both put a picture on a tab and let it float.
  ///
  /// The design that was chosen — 4b of the PCOS Mode Switcher project — does
  /// something different with it: a 34pt well, filled, at the top of a 108pt
  /// square, with the label and its count anchored to the bottom. The mark is
  /// not decoration floating in space; it is one of two things holding the box
  /// apart. That is the kit's own icon-well vocabulary, and it is why the same
  /// glyph reads as deliberate here and did not before.
  final IconData icon;

  /// The tab's own hue — its fill when resting, and its well when lit.
  ///
  /// ⚠️ THERE IS NO ICON FIELD, AND TWO ATTEMPTS AT ONE WERE REMOVED.
  ///
  /// First a Material glyph, which came back as *"you have just used the icons
  /// basic icons, I don't like it"* — a stock icon in a stage where every other
  /// picture is hand-drawn reads as the placeholder nobody replaced. Then a
  /// drawn `V3DailyArt` mark in a tinted disc, copied from the home's daily
  /// rail, which came back as *"a lot of wasted space on that tab… it's all
  /// white behind, that's why it looks very empty."*
  ///
  /// Both notes are the same note, and it is about SIZE rather than artwork. A
  /// picture forces the tab into a card, a card needs a box, and five boxes of
  /// mostly-empty white across the top of a page is a lot of screen spent on
  /// navigation. A tab is a word you press. So the tab is a pill sized to its
  /// word, and the hue is the only decoration left — as a 5pt dot when the tab
  /// is resting and as the whole fill when it is lit.
  ///
  /// ⚠️ TAKEN FROM `V2BlockHues` WHERE ONE FITS, for the reason the cycle phase
  /// colours are: a hue in this app already means something, and inventing a
  /// sixth family for one rail would put the door slightly out of tune with
  /// every other surface she has seen.
  final double hue;

  /// When set, this group shows one tool inline instead of a list of sections.
  ///
  /// ⚠️ INLINE, NOT A TILE THAT OPENS THE TOOL. "Where do I stand" used to be a
  /// section holding a card you tapped to leave the page. Asked for directly:
  /// *"that tab of tool that you created won't be needed — when the person
  /// clicks on where do I stand, the tool will appear."* A card in front of a
  /// tool, inside a group whose only content is that tool, is a door in front
  /// of a door.
  final String? toolSurfaceId;
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
    this.groups,
    this.heroImageUrl,
    this.heroBlurb,
    this.closingLine,
    this.heroTitle,
  });

  /// The new door's headline: a SENTENCE, set large under the eyebrow
  /// (`TtcDoorScreen`), the way every pregnancy door reads ("Your scans, in
  /// one place.").
  ///
  /// ⚠️ NOT THE DOOR'S NAME, AND THAT IS WHY IT DOES NOT BREAK THE RULE ON
  /// [intro]. The name is still taken from the bracket, as the eyebrow, so
  /// the tile she tapped and the page she lands on still say the same words.
  /// This line is what the door is FOR, in her voice (docs/TTC-VOICE.md).
  /// Null falls back to the bracket's label. The old screen never reads it.
  final String? heroTitle;

  /// One sentence at the foot of the door, under whichever tab is open.
  ///
  /// ⚠️ BUILT ON THE SECOND ASKING, AND THE FIRST REFUSAL WAS RIGHT. After a
  /// loss asked for a closing line on 2026-09-04 and it was held — see
  /// `docs/STILL-OPEN.md` §26.6 — because adding a field to a shared model for
  /// exactly one caller is how a page model turns into a config object that can
  /// express more states than the product has. One door wanting something is a
  /// special case; two doors wanting it is a shape.
  ///
  /// Mind & body asked for one in the same words ("one gentle closing line for
  /// the area, shown once"), so it is a field now, and After a loss can have
  /// its line by filling it in.
  ///
  /// ⚠️ "SHOWN ONCE" MEANS ONCE PER PAGE, NOT ONCE PER TAB. It renders below
  /// the sections of whatever group is open, so somebody who only ever opens
  /// Today still reads it. A line that appears only under the last tab is a
  /// line most people never see.
  final String? closingLine;

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

  /// The selector rail under the hero. Null on a page that is one long scroll.
  ///
  /// ⚠️ THE SECTIONS STAY THE SOURCE OF TRUTH EVEN HERE. Grouping changes which
  /// of them are on screen at once; it does not move content into a second
  /// structure. `allTiles` therefore still walks every tile on the page whether
  /// it is grouped or not, so `ttc_focus_page_test.dart` keeps checking that a
  /// tile in a group nobody has selected still points at something real — which
  /// is the tile most likely to rot, because it is the one least often seen.
  final List<TtcFocusGroup>? groups;

  /// A photograph behind the hero, with the title set over it.
  ///
  /// ⚠️ A URL IN DATA, AND THE DRAWN FIELD IS THE FALLBACK, exactly as
  /// `TtcArticleTile.imageUrl` already works. Local-first is absolute: on a
  /// dead connection the hero renders the V3 field it always had and the page
  /// is still finished, rather than showing a grey box where a face should be.
  final String? heroImageUrl;

  /// One plain sentence under the title, over the photograph.
  ///
  /// ⚠️ WHAT THE CONDITION IS, IN ONE LINE — "PCOS is a condition where hormone
  /// imbalance affects how the ovaries work." Not a welcome, not a promise
  /// about the page. Someone who arrived here from a search result may not know
  /// the definition, and making her tap a card to get it is a page that assumes
  /// its own subject.
  final String? heroBlurb;

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

// ⚠️ `final`, NOT `const`, SINCE MIND & BODY — 2026-09-05. That door builds
// its twelve practice tiles from `ttc_practice_data.dart` with a function
// rather than typing them out, and Dart will not call a function in a const
// list. The alternative was a second copy of every practice title, which is the
// duplication that door's brief forbids most loudly.
//
// Nothing outside reads this as a const, so the change is invisible. Worth
// knowing only if you add a page and wonder why `const` no longer compiles.
final List<TtcFocusPage> kTtcFocusPages = [
  kTtcConceivingFocus,
  kTtcPcosFocus,
  kTtcIvfFocus,
  kTtcGettingReadyFocus,
  kTtcHisSideFocus,
  kTtcAfterLossFocus,
  kTtcMindBodyFocus,
  // The gap plan's two new doors (2026-09-26, docs/TTC-GAP-PLAN.md §8).
  kTtcBodyCycleFocus,
  kTtcNotYetFocus,
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

/// A door tile's name in Ask Veda's content pool (2026-09-27).
///
/// Tiles have no id of their own, and an index would shift the day a tile is
/// added above it, so the exported doc names the tile by its title. Hyphens,
/// not underscores: Ask Veda strips a trailing `_hi` from every doc id, and
/// "Say hi" must not lose its last word to that.
/// The photo key a title files under: `ttc_tile_` and the title in lower
/// case, words joined by `_` ("Every day or not?" is
/// `ttc_tile_every_day_or_not`). Every tile's `id` was set to this key of the
/// title it had on 2026-09-29, so a retitle keeps the photo; this is the
/// fallback for a tile with no id, and the key a new tile's id is born with.
/// `ttcTilePhotoId` (ttc_focus_screen.dart) reads it.
String ttcTileTitleKey(String title) {
  final slug = title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return 'ttc_tile_$slug';
}

String ttcTileSlug(TtcTile t) => t.title
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

/// The tile on [page] named [slug], and the group of the section it sits in,
/// or null when the door no longer has it (the door itself then opens).
///
/// ⚠️ AND BY ITS OLD NAME, WHEN IT HAS AN `id` (2026-09-28). About seventy
/// tiles were retitled to name what they open ("Every day or not?" became
/// "Sex every day, or every other day?"), and Ask Veda's pool still holds the
/// doc ids exported under the old titles until it is refreshed. A tile whose
/// photo was filed under its old title carries `id: 'ttc_tile_<old title>'`,
/// so its old slug is recoverable from the id and an answer card from the
/// old pool still lands on the card. A retitled tile with no id (its photo
/// is its read's) falls back to opening the door, as any unknown slug does,
/// until the pool is re-exported. The title wins when both match.
(TtcTile, String?)? ttcTileBySlug(TtcFocusPage page, String slug) {
  for (final s in page.sections) {
    for (final t in s.tiles) {
      if (ttcTileSlug(t) == slug) return (t, s.group);
    }
  }
  for (final s in page.sections) {
    for (final t in s.tiles) {
      if (ttcTileIdSlug(t) == slug) return (t, s.group);
    }
  }
  return null;
}

/// The slug a tile had in Ask Veda's pool before it was retitled, from its
/// stable `id` (`ttc_tile_can_stress_stop_it` → `can-stress-stop-it`), or
/// null for a tile with no id.
String? ttcTileIdSlug(TtcTile t) {
  final id = t.id;
  if (id == null || !id.startsWith('ttc_tile_')) return null;
  return id.substring('ttc_tile_'.length).replaceAll('_', '-');
}
