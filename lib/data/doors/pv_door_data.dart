// =============================================================================
//  Doors — one problem area, one page, five sub-tabs
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS THE PREGNANCY-SIDE TWIN OF THE TTC FOCUS ENGINE, AND THE
//  DUPLICATION IS DELIBERATE RATHER THAN ACCIDENTAL. Read this before deciding
//  it should be merged.
//
//  `lib/ttc/ttc_focus_data.dart` + `lib/screens/ttc/ttc_focus_screen.dart` are
//  the same idea, built first, and they are welded to TTC by their payloads:
//  an article names an id in `kTtcReads`, a tool names a surface only
//  `ttcScreenForSurface` can resolve, a product names a row in the TTC
//  catalogue. None of those exist on the pregnancy side, and pregnancy's own
//  destinations — a scan page, the report locker, the decoder — have no way to
//  be expressed over there.
//
//  So the two engines share a SHAPE and nothing else. What they genuinely share
//  is already shared and stage-neutral: `V2Palette`, `V3HeroField`,
//  `V3BracketArt`, `PvRead`, `PvReaderScreen`, `pv_placeholders`. That is what
//  lets a pregnancy door look identical to a TTC door without either file
//  importing the other.
//
//  ⚠️ IF THE TWO ARE EVER MERGED, THIS IS THE SEAM: lift the model and the
//  renderer to a stage-neutral home, and give each stage an injected resolver
//  for reads and surfaces — the way `PvReaderScreen` already takes
//  `openRead` / `openSurface` rather than importing a library. That is a
//  one-import change per TTC file and is not attempted here, because TTC is
//  being worked on in parallel and a shared-file edit is everybody's conflict.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE TILES ARE A SEALED UNION, FOR THE REASON `TtcTile` GIVES
//  ---------------------------------------------------------------------------
//
//  The obvious model is one `Tile` with `format`, `readId?`, `surfaceId?`,
//  `scanId?`, `action?`. It compiles, it is shorter, and CLAUDE.md names it
//  forbidden: "a config object that can express more states than the product
//  has is a bug surface, not flexibility."
//
//  With seven formats and four payload fields that object can express well over
//  a hundred states, of which seven are legal. A guide tile with a `scanId` and
//  no `readId` is constructible, passes analysis, and renders a card that does
//  nothing — on a rail where a tile is a title, a blurb and a chip, and none of
//  that fails to draw when the id underneath it is wrong.
//
//  A sealed hierarchy makes the illegal states unrepresentable: a
//  `PvDoorScanTile` HAS a scan id because its constructor requires one, and has
//  no `readId` because the field does not exist. The renderer's switch is then
//  exhaustive — add an eighth format and the compiler names the screen that has
//  not handled it, rather than the app drawing a blank card.
//
//  ---------------------------------------------------------------------------
//  ⚠️ ENGLISH ONLY. Plain `String`, not `LocalizedText`.
//  ---------------------------------------------------------------------------
//
//  CLAUDE.md, decided 2026-08-27: new copy is English. The Devanagari already
//  shipped elsewhere in Pregnancy stays exactly as it is, and nothing here
//  touches it — the scan pages, the timeline and the decoder this door opens
//  are all bilingual and all reused unchanged.
//
//  The register is deliberate and is not "simple because the reader is simple".
//  Most of this audience reads English as a second or third language, so the
//  rule for every line is: one idea per sentence, the common word over the
//  precise-sounding one, no clause stacked on a clause. A medical name survives
//  ONLY as a card title where it is the exact word printed on her report — she
//  has to match it to her paper — and it always carries a plain line under it.
//  Never a jargon word in a heading or a blurb we write.
// =============================================================================

import 'package:flutter/material.dart' show IconData;

import '../../screens/brackets/hub/hub_intent_art.dart' show IntentMark;

import '../same_day_signs_data.dart';
import '../scan_extras.dart' show kScanUrgentSigns;
import 'pv_door_belly_skin.dart';
import 'pv_door_complications.dart';
import 'pv_door_garbh.dart';
import 'pv_door_labour.dart';
import 'pv_door_mind.dart';
import 'pv_door_nutrition.dart';
import 'pv_door_scans.dart';

export 'pv_door_belly_skin.dart';
export 'pv_door_complications.dart';
export 'pv_door_labour.dart';
export 'pv_door_nutrition.dart';
export 'pv_door_scans.dart';

/// What kind of thing a tile is. Drives the chip, the icon and the tap.
///
/// ⚠️ SEVEN, BECAUSE SEVEN IS WHAT THE FIRST DOOR ASKED FOR. Adding an eighth
/// is two lines — a value here and a case in `pvDoorFormatLabel` — plus a case
/// in the renderer's switch, which the compiler will demand rather than
/// letting a new format render nothing. Do not add one speculatively: a format
/// is a promise to the reader about what happens when she taps, and a chip
/// nothing is behind is worse than a missing chip.
enum PvDoorFormat {
  tool,
  article,
  guide,
  read,
  mythFact,
  checklist,
  talk,
  // ⚠️ ADDED FOR NUTRITION, AND EACH ONE HAS A CONCRETE READER. A recipe opens
  // the app's own recipe page with its serving scaler; a chip reading "Guide"
  // over a dish would be the chip lying about what the tap gives you, which is
  // the one thing this enum exists to prevent.
  recipe,
  video,
  // ⚠️ ADDED FOR MIND & MOOD. Its brief's format list has Audio beside Video,
  // and four calming tracks sit on the Feel tab. A chip reading "Video" over
  // a rain track would be the chip lying, which is the one thing this enum
  // exists to prevent.
  audio,
  // ⚠️ ADDED FOR GARBH SANSKAR. Buddhi's four puzzles are marked [Game] in the
  // brief, and "Tool" over Sudoku would be the chip lying about what the tap
  // gives her — a tool is used and put down; a game is played.
  game,
  // ⚠️ ADDED FOR NUTRITION'S CHARTS (2026-09-20). A diet chart is a plan she
  // comes back to: "Tool" over it read wrong (the user), and "Guide" made the
  // rail a list, because a guide is written and a written section is rows.
  // A plan is neither used-and-put-down nor read once; it is followed.
  plan,
}

extension PvDoorFormatCopy on PvDoorFormat {
  /// The chip on the tile. Short, because it sits beside a title that matters
  /// more than it does.
  ///
  /// ⚠️ THE CHIP IS THE PROMISE ABOUT WHAT THE TAP DOES, which is why "Read"
  /// and "Article" are two words for what is nearly one thing. An article is
  /// something written about one subject, read start to finish; a read is a
  /// lookup she dips into with a word in her hand. The brief marks them
  /// separately and it is right to — a woman holding a report and a woman
  /// preparing for Thursday want different objects.
  String get label => switch (this) {
        PvDoorFormat.tool => 'Tool',
        PvDoorFormat.article => 'Article',
        // 'Article' too — a Guide tile opens the reader at a heading, which
        // is an article by another name. One word for written pieces
        // (STILL-OPEN §60.2; the user, 2026-09-18: one format per tag).
        // Kept for revert: 'Guide'.
        PvDoorFormat.guide => 'Article',
        // ⚠️ 'Article', NOT 'Read' — STILL-OPEN §60.2, applied 2026-09-17. The
        // enum value stays (it is persisted in door data); only the word on
        // the chip changes. Nobody in the Mobbin set distinguishes look-up
        // from read-through at the chip; the distinction above lives INSIDE
        // the piece (glossary or FAQ first, contents visible). Kept for
        // revert: 'Read'.
        PvDoorFormat.read => 'Article',
        // 'Article' — the myth-vs-fact block lives INSIDE the piece it opens.
        // Kept for revert: 'Myth vs fact'.
        PvDoorFormat.mythFact => 'Article',
        PvDoorFormat.checklist => 'Checklist',
        PvDoorFormat.talk => 'Talk',
        PvDoorFormat.recipe => 'Recipe',
        PvDoorFormat.video => 'Video',
        PvDoorFormat.audio => 'Audio',
        PvDoorFormat.game => 'Game',
        PvDoorFormat.plan => 'Plan',
      };
}

// -----------------------------------------------------------------------------
//  The tiles
// -----------------------------------------------------------------------------

/// Whether a tile opens a piece of WRITING — an article, guide, read or
/// myth-fact — as opposed to a tool, a film, a checklist, a person. A section
/// whose tiles are all written draws as a LIST (2026-09-19); anything mixed
/// stays a rail. See `_ArticleList` in pv_door_screen.dart.
bool pvDoorTileIsWritten(PvDoorTile t) => switch (t.format) {
      PvDoorFormat.article ||
      PvDoorFormat.guide ||
      PvDoorFormat.read ||
      PvDoorFormat.mythFact =>
        true,
      _ => false,
    };

/// The read id a written tile opens, for its photo (`readImageFor`), or null
/// where the tile's library has no read-image entry.
String? pvDoorTileReadImageId(PvDoorTile t) => switch (t) {
      PvDoorGuideTile(:final readId) => readId,
      PvDoorMythTile(:final readId) => readId, // "Do I need every scan" had none (2026-09-19)
      // A scan's read is `scan_<id>` (read_adapters.dart, kScanReadPrefix);
      // a finding's is `finding_<id>`; a condition's `condition_<id>`.
      PvDoorEntryTile(:final library, :final entryId) => switch (library) {
          PvDoorLibrary.scan => 'scan_$entryId',
          PvDoorLibrary.finding => 'finding_$entryId',
          PvDoorLibrary.condition => 'condition_$entryId',
          _ => null,
        },
      _ => null,
    };

sealed class PvDoorTile {
  const PvDoorTile({
    required this.title,
    required this.blurb,
    this.meta,
    this.comingSoon = false,
  });

  /// Short and plain. The one line she reads.
  ///
  /// ⚠️ A MEDICAL NAME IS ALLOWED HERE AND NOWHERE ELSE, and only when it is
  /// the exact word printed on her report or on the timeline — "NT scan",
  /// "Sugar test (OGTT)", "Group B Strep". She has to be able to match the card
  /// to her paper, and a card reading "the early growth check" cannot be
  /// matched to a slip that says NT. The plain line always sits under it.
  final String title;

  /// One line under it saying what she gets. Required, not optional — a tile
  /// whose title has to carry the whole explanation ends up as a sentence in
  /// bold.
  ///
  /// ⚠️ NEVER JARGON, EVEN WHERE THE TITLE CARRIES SOME. This is the half that
  /// does the explaining: "Checks the baby's early growth and development", not
  /// "nuchal translucency measurement".
  final String blurb;

  /// A short fact set above the title on a card. "Weeks 6–10".
  ///
  /// ⚠️ ADDED AFTER SEEING THE RAIL ON A PHONE, AND IT FIXES TWO THINGS AT
  /// ONCE.
  ///
  /// The brief annotates every scan with its week range — `"Blood tests"
  /// (weeks 6-10)`, `"NT scan" (weeks 11-13)` — and the first build read those
  /// as identification rather than as copy, so they did not reach the card.
  /// That was arguably defensible on its own. What settled it is what the rail
  /// looked like: nine cards of the same format, so the same fallback mark on
  /// every one, distinguished only by a title and a 22° hue step. Nine grey
  /// pages in a row.
  ///
  /// The week range is the line that makes each card its own thing AND is the
  /// question she is actually asking on a tab called "before you go" — *which
  /// of these is mine, now*. The brief had it and the card did not.
  ///
  /// ⚠️ IT IS NOT THE BLURB. The blurb says what the scan does and is often
  /// contracted by the brief word for word; this says when. Both fit because
  /// the blurb does not render on a rail card.
  final String? meta;

  /// The content behind this does not exist yet.
  ///
  /// ⚠️ A STATE ON EVERY TILE, NOT A FORMAT OF ITS OWN. Coming-soon is
  /// orthogonal to what a thing IS — a film, a guide and a read can each be
  /// unwritten — and making it a format would have meant one chip that lies
  /// about the object in order to tell the truth about its readiness.
  ///
  /// The card still draws at full size with its real title, because the rule at
  /// the head of `pv_placeholders.dart` holds here too: a placeholder occupies
  /// the real geometry, so nothing shifts on the page the day the piece lands.
  /// It is not tappable, and it says so.
  final bool comingSoon;

  PvDoorFormat get format;
}

/// Opens a screen that already exists elsewhere in the stage.
final class PvDoorToolTile extends PvDoorTile {
  const PvDoorToolTile({
    required super.title,
    required super.blurb,
    required this.surfaceId,
    super.meta,
    super.comingSoon,
  });

  /// ⚠️ A SURFACE ID, NOT A WIDGET. The tool is built, shipped and tested; this
  /// opens it through the door router so the route NAME stays the surface id —
  /// which is what `global_ask_fab.dart` reads to decide which Ask Veda opens.
  /// Constructing the screen here would work and would quietly break that.
  final String surfaceId;

  @override
  PvDoorFormat get format => PvDoorFormat.tool;
}

/// A library of pages this app already ships, and which lookup finds them.
///
/// ⚠️ THIS REPLACED THREE NEAR-IDENTICAL TILE CLASSES AND STOPPED SEVEN MORE
/// BEING WRITTEN — 2026-09-10.
///
/// `PvDoorScanTile`, `PvDoorConditionTile` and `PvDoorFindingTile` were the
/// same class three times: one id, one lookup, one push. Nutrition needs six
/// more of them — nutrients, diet stages, diet conditions, recipes, diet
/// charts, fasting topics — and at that point the pattern is not a set of
/// types, it is a table with a column missing.
///
/// ⚠️ AND THIS IS NOT THE CONFIG OBJECT THE HEADER OF THIS FILE FORBIDS.
/// Read that rule carefully: it is about a tile with SEVERAL INDEPENDENT
/// PAYLOAD FIELDS, where most combinations are illegal and constructible — a
/// myth tile carrying a `productId` and no `fact`. This has exactly one payload
/// field and one selector, so there is no combination to get wrong. The only
/// error possible is an id that is not in its library, and no type system
/// catches that; `test/pv_door_*_test.dart` does.
///
/// What is lost is the compiler naming an unhandled case. What is gained is
/// that adding a library is one enum value, one lookup and one push, instead of
/// a class, a case and a test per destination.
enum PvDoorLibrary {
  /// `kTestsScans` — one scan or test, on its rich page.
  scan,

  /// `kAllConditions` — "my doctor said I have X".
  condition,

  /// `kReportFindings` — "my report says X". See
  /// `docs/PREGNANCY-DOOR-BUILD.md` §4a for why both exist.
  finding,

  /// `kNutrientGuides` — one of the twelve nutrients.
  nutrient,

  /// `kTrimesterGuides` — what to eat before, and in each third.
  dietStage,

  /// `kConditionGuides` — eating for a condition. NOT [condition]: this is the
  /// DIET page, and where Complications owns the condition itself the brief
  /// says link there instead of restating it.
  dietCondition,

  /// `kRecipes` — a dish, on the app's own recipe page.
  recipe,

  /// `kDietCharts` — a three-day plan.
  dietChart,

  /// `kFastingByOccasion` + `kFastingGeneral` — fasting, safely.
  fasting,

  /// `kNutritionPracticalCards` — the five whole-diet questions, each a read.
  dietQuestion,

  /// `kBsPages` — one skin or belly read.
  bellySkin,

  /// `kMmArticles` — one Mind & mood read, on `MmArticleScreen`.
  mindRead,
}

extension PvDoorLibraryCopy on PvDoorLibrary {
  /// The chip a tile from this library wears.
  ///
  /// ⚠️ THE FORMAT BELONGS TO THE LIBRARY, NOT TO THE TILE. Every page in
  /// `kNutrientGuides` is the same kind of object, so a nutrient tile that
  /// declared its own chip would be a chance to declare the wrong one. The
  /// briefs agree with this: they mark whole rails `[Guide]` or `[Article]`,
  /// never card by card.
  PvDoorFormat get format => switch (this) {
        // A scan page is a written piece about one scan — what it is, why, how
        // to prepare, what the report says. The brief marks all nine [Article].
        PvDoorLibrary.scan => PvDoorFormat.article,
        PvDoorLibrary.condition => PvDoorFormat.article,
        PvDoorLibrary.finding => PvDoorFormat.article,
        // A nutrient, a stage and a diet-condition page are all things you act
        // on — what it does, which everyday foods give it to you, whether you
        // need a supplement. The nutrition brief marks every one [Guide].
        PvDoorLibrary.nutrient => PvDoorFormat.guide,
        PvDoorLibrary.dietStage => PvDoorFormat.guide,
        PvDoorLibrary.dietCondition => PvDoorFormat.guide,
        PvDoorLibrary.fasting => PvDoorFormat.guide,
        PvDoorLibrary.dietQuestion => PvDoorFormat.guide,
        // ⚠️ "Read", NOT "Guide". The Belly & skin brief marks every one of its
        // nineteen pages [Read], and it is the right word: these explain what
        // is happening to her skin rather than handing her something to do.
        PvDoorLibrary.bellySkin => PvDoorFormat.read,
        // The Mind & mood brief marks every one [Read].
        PvDoorLibrary.mindRead => PvDoorFormat.read,
        PvDoorLibrary.recipe => PvDoorFormat.recipe,
        // A chart is a three-day plan you open, filter and download. That is a
        // tool, not a read.
        // A chart is a plan she comes back to — a guide, not a tool; the
        // "Tool" tag on every chart card read wrong (the user, 2026-09-20).
        PvDoorLibrary.dietChart => PvDoorFormat.plan,
      };
}

/// One page from a library the app already ships.
///
/// ⚠️ THE ID MUST EXIST IN ITS LIBRARY, and that is what the wiring test
/// checks. A tile whose id is wrong renders perfectly — a title, a blurb and a
/// chip — and does nothing.
final class PvDoorEntryTile extends PvDoorTile {
  const PvDoorEntryTile({
    required super.title,
    required super.blurb,
    required this.library,
    required this.entryId,
    super.meta,
    super.comingSoon,
  });

  final PvDoorLibrary library;
  final String entryId;

  @override
  PvDoorFormat get format => library.format;
}

/// A film. None of them exist yet.
///
/// ⚠️ IT IS ALWAYS COMING SOON TODAY, AND THAT IS HONEST RATHER THAN LAZY.
/// `PvVideoPlaceholder` holds real 16:9 geometry, a real title and a
/// "coming soon" mark, and is not tappable — so the page can be judged now and
/// only the file is missing. The rule is at the head of `pv_placeholders.dart`.
final class PvDoorVideoTile extends PvDoorTile {
  const PvDoorVideoTile({
    required super.title,
    required super.blurb,
    super.meta,
  }) : super(comingSoon: true);

  @override
  PvDoorFormat get format => PvDoorFormat.video;
}

/// A track. Two forms, same pair as [PvDoorReadTile]: the default requires a
/// surface and plays, the coming-soon form refuses one and does not.
///
/// ⚠️ THE COMING-SOON FORM CAME FIRST. Mind & mood's four calming tracks have
/// `asset: null` on `MmCalmAudio` ("the files are not in the repo"), so the
/// card says so. Garbh Sanskar's Shravan library has a player behind every
/// track — it plays the bundled drone until the real files land, which is a
/// placeholder INSIDE a working screen, not a missing screen — so its cards
/// open. Which form a track takes is a fact about the screen, never a mood.
final class PvDoorAudioTile extends PvDoorTile {
  const PvDoorAudioTile({
    required super.title,
    required super.blurb,
    required String this.surfaceId,
    super.meta,
  }) : super(comingSoon: false);

  /// The file is not in the repo. Drawn at full size, not tappable.
  const PvDoorAudioTile.comingSoon({
    required super.title,
    required super.blurb,
    super.meta,
  })  : surfaceId = null,
        super(comingSoon: true);

  /// Null only on the coming-soon form.
  final String? surfaceId;

  @override
  PvDoorFormat get format => PvDoorFormat.audio;
}

/// A game — played, not used. Opens through the router like a tool.
final class PvDoorGameTile extends PvDoorTile {
  const PvDoorGameTile({
    required super.title,
    required super.blurb,
    required this.surfaceId,
    super.meta,
    super.comingSoon,
  });

  final String surfaceId;

  @override
  PvDoorFormat get format => PvDoorFormat.game;
}

/// A guide — a piece written to be USED rather than read through.
///
/// ⚠️ IT OPENS THE SAME READER AS AN ARTICLE, AND ONLY THE CHIP DIFFERS. That
/// is the whole justification: a chip is the promise about what happens when
/// she taps, and "Article" over "What scans cost in India" promises something
/// to read on a train. It is not that — it is a thing you act on, take to a
/// counter, and argue with a price list about.
///
/// ⚠️ A GUIDE IS NOT A LOWER BAR WEARING A DIFFERENT WORD. The content standard
/// is identical to an article's: a `PvRead`, four sections, a contents, an FAQ,
/// named sources and a when-to-see-someone. `assertShape()` enforces it and
/// `test/pregnancy_reads_shape_test.dart` runs it over every one.
final class PvDoorGuideTile extends PvDoorTile {
  const PvDoorGuideTile({
    required super.title,
    required super.blurb,
    required this.readId,
    this.atHeading,
    super.meta,
    super.comingSoon,
  });

  /// Must exist in `kPregnancyReads`.
  final String readId;

  /// Open the read scrolled to this section, matched on the heading text.
  /// See `PvReaderScreen.openAtHeading` for why it matches text and not an
  /// index.
  final String? atHeading;

  @override
  PvDoorFormat get format => PvDoorFormat.guide;
}

/// A thing people believe, and what is actually true.
///
/// ⚠️ IT OPENS A FULL READ, AND THE MYTH IS THE FIRST THING IN IT. The chip
/// promises two lines and a correction; a chip that promises that and opens
/// seven hundred words of essay is a chip that lies about length, which is the
/// one thing a format system exists to prevent.
///
/// So the read it names carries a `PvReadSection.mythFact` in its OPENING
/// section — the claim and the correction, side by side, before anything else —
/// and the depth follows underneath for whoever wants it. The promise is kept
/// in the first screenful; the article is the reward for staying.
final class PvDoorMythTile extends PvDoorTile {
  const PvDoorMythTile({
    required super.title,
    required super.blurb,
    required this.readId,
    super.meta,
    super.comingSoon,
  });

  /// Must exist in `kPregnancyReads`, and its first section must carry a
  /// `mythFact` — asserted by `test/pv_door_scans_test.dart`.
  final String readId;

  @override
  PvDoorFormat get format => PvDoorFormat.mythFact;
}

/// Something to look a word up in.
///
/// ⚠️ TWO CONSTRUCTORS, AND THE PAIR IS WHAT KEEPS THE NULL HONEST. A read with
/// no destination is a dead card; a coming-soon read with a destination is a
/// card that says "not yet" and then opens something. Neither is
/// constructible: the default form requires a surface, and the coming-soon form
/// refuses one.
///
/// Same shape as `TtcProductTile`'s one-product / whole-shelf pair, and for the
/// same reason — a model that cannot say what the brief means gets a near-miss
/// substituted for it.
final class PvDoorReadTile extends PvDoorTile {
  const PvDoorReadTile({
    required super.title,
    required super.blurb,
    required String this.surfaceId,
    super.meta,
  }) : super(comingSoon: false);

  /// The piece is not written. The card draws at full size and does not tap.
  const PvDoorReadTile.comingSoon({
    required super.title,
    required super.blurb,
    super.meta,
  })  : surfaceId = null,
        super(comingSoon: true);

  /// Null only on the coming-soon form.
  final String? surfaceId;

  @override
  PvDoorFormat get format => PvDoorFormat.read;
}

/// A checklist — a thing with items you tick, not a tool you operate.
///
/// ⚠️ THE DIFFERENCE FROM `PvDoorToolTile` IS THE CHIP, NOT THE PUSH. "Tool"
/// over "What to ask at your next scan" describes the wrong kind of object: a
/// checklist is something you come back to, add to, and carry into a room, not
/// something you use once and put down.
final class PvDoorChecklistTile extends PvDoorTile {
  const PvDoorChecklistTile({
    required super.title,
    required super.blurb,
    required this.surfaceId,
    super.meta,
    super.comingSoon,
  });

  final String surfaceId;

  @override
  PvDoorFormat get format => PvDoorFormat.checklist;
}

/// Time with a person, reached by asking rather than by booking a slot.
///
/// ⚠️ "Talk" AND NOT "Booking". The two are not the same promise: booking says
/// a calendar and a slot, talk says a person and a conversation — which is what
/// "Have a doctor go through it with you" is offering somebody holding a report
/// she cannot read. Same booking engine underneath; only the card differs.
final class PvDoorTalkTile extends PvDoorTile {
  const PvDoorTalkTile({
    required super.title,
    required super.blurb,
    required this.surfaceId,
    super.meta,
    super.comingSoon,
  });

  /// A surface the door router resolves — never a booking flow rebuilt here.
  final String surfaceId;

  @override
  PvDoorFormat get format => PvDoorFormat.talk;
}

// -----------------------------------------------------------------------------
//  Sections, groups and the page
// -----------------------------------------------------------------------------

/// A heading and the tiles under it.
///
/// ⚠️ THE HEADING IS A PLAIN PHRASE SOMEBODY WOULD SAY, and never a format
/// name. "First three months" and "Before any scan" are sections; "Articles" is
/// not. The moment a format becomes a heading the page stops being organised by
/// what she wants to know and starts being organised by how we happened to
/// build it — the content-management view of a product, and never the reader's.
class PvDoorSection {
  const PvDoorSection({
    required this.heading,
    required this.tiles,
    required this.group,
    this.lead,
    this.folded = false,
    this.strip = false,
    this.moreSurfaceId,
    this.railMax,
  }) : inlineSurfaceId = null;

  /// "View all ›" on the heading, opening this surface — for a rail that
  /// would otherwise be nineteen cards long (Nutrition's charts, 2026-09-20:
  /// "it's a big scroll"). Null: no link.
  final String? moreSurfaceId;

  /// How many tiles the rail draws when [moreSurfaceId] is set; the rest
  /// live on that screen. Null: all of them.
  final int? railMax;

  /// A section whose rail is drawn by a widget, not by tiles.
  ///
  /// ⚠️ FOR A RAIL WHOSE CARDS DEPEND ON A STORE. Garbh Sanskar's "Your own
  /// practice" shows whichever rituals she has picked — Gita paath, Japa, a
  /// Quran passage — and a page built once at startup cannot know that. The
  /// widget behind [inlineSurfaceId] listens to the store and draws the rail
  /// itself, in position, under this heading.
  ///
  /// ⚠️ IT MUST DRAW A RAIL. The symmetry test counts one horizontal
  /// `ListView` per section on every tab; a widget here that draws a column
  /// fails that test, which is the point of the test. `PvDoorRailCard` is the
  /// card to use, and the cards must be the same height as every other rail.
  ///
  /// ⚠️ NOT `PvDoorGroup.inlineSurfaceId`. That renders ABOVE a tab's sections
  /// and is for a tab that IS a tool. This is one section among others, in the
  /// order the brief puts it, and it exists because the group form could not
  /// put a dynamic rail third.
  const PvDoorSection.inline({
    required this.heading,
    required String this.inlineSurfaceId,
    required this.group,
    this.moreSurfaceId,
    this.railMax,
  })  : tiles = const [],
        folded = false,
        strip = false,
        lead = null;

  final String heading;
  final List<PvDoorTile> tiles;

  /// Closed by default, opened by a tap on its heading — for a section of
  /// background reading under a list of specific things ("Before any scan"
  /// under the nine scans, 2026-09-19). GoodRx's shape: the specific list,
  /// then "Related · 9 articles" with a count. It never moves above the
  /// list — that is where she came for — and it never hides: the heading
  /// carries the count and a chevron. Inline sections ignore it.
  final bool folded;

  /// A folded section that is ALSO offered as a slim strip above the tab's
  /// first list until she dismisses it once ("New to scans? Four things to
  /// read first ›" with an ✕). Bluesky's and Shopify's "Getting started"
  /// strip (Mobbin, 2026-09-19): background reading is a tap away on the
  /// first visits, and never in the way after. The dismissal is remembered
  /// per section heading in `PvDoorStripStore`.
  final bool strip;

  /// Null on every tile-backed section; set only by [PvDoorSection.inline].
  final String? inlineSurfaceId;

  /// Which entry, if any, should be brought to the front for THIS woman.
  ///
  /// ⚠️ RANKING, NEVER STRUCTURE. CLAUDE.md's rule for personalisation is that
  /// it may change content, ranking and order and never what exists — and a
  /// rail is the same rail for everyone, with the same cards, whichever one
  /// leads. This hook is that rule in its smallest form: given her week, it
  /// names one `entryId` and the screen moves that tile to the front of the
  /// rail's entry tiles. Nothing is hidden, nothing is added.
  ///
  /// ⚠️ A WEEK, NOT A CONTROLLER. Door data must not import the controller —
  /// it is data, it is built once, and it is tested without a store behind
  /// it. An `int` is what the section actually needs and the screen has it.
  ///
  /// ⚠️ AND IT HOISTS TO THE FIRST ENTRY TILE, NOT TO INDEX ZERO. Nutrition's
  /// stage rail opens with "Add this to your plate now", which sits first on
  /// purpose — it is the narrowest question — and a hoist that displaced it
  /// would undo a decision made for a reason. See `PvDoorPage.tilesOf`.
  final String? Function(int week)? lead;

  /// The tiles as they should render for a woman at [week].
  ///
  /// Stable: everything keeps its order except the one tile [lead] names,
  /// which moves to where the first entry tile was. With no [lead], or a lead
  /// that names nothing on the rail, this IS [tiles].
  List<PvDoorTile> tilesFor(int week) {
    final id = lead?.call(week);
    if (id == null) return tiles;
    final at = tiles.indexWhere(
        (t) => t is PvDoorEntryTile && t.entryId == id);
    if (at < 0) return tiles;
    final firstEntry = tiles.indexWhere((t) => t is PvDoorEntryTile);
    if (at == firstEntry) return tiles;
    final out = List<PvDoorTile>.of(tiles);
    final hoisted = out.removeAt(at);
    out.insert(firstEntry, hoisted);
    return out;
  }

  /// Which [PvDoorGroup] this section appears under.
  ///
  /// ⚠️ THE SECTION NAMES ITS GROUP, NOT THE OTHER WAY ROUND. The obvious model
  /// is a group holding a list of the sections it owns. That lets a section
  /// belong to two groups, or to none, and neither failure looks like anything
  /// — the section simply renders twice, or vanishes. One field means one
  /// answer, and the test only has to check that the id exists.
  ///
  /// ⚠️ REQUIRED, NOT NULLABLE. TTC's equivalent is optional because its first
  /// doors were one long scroll; every door here has tabs from the first line,
  /// and a null would mean a section that renders in NO tab — a failure that
  /// looks like nothing at all.
  final String group;
}

/// A red flag pinned above a tab's content, never inside an accordion.
///
/// ⚠️ IT REFERENCES THE EXISTING LIST, IT DOES NOT RETYPE IT. `kScanUrgentSigns`
/// in `scan_extras.dart` is the stage's one copy of these lines and
/// `ScanUrgentScreen` already renders them. Typing them onto the door would put
/// a clinical warning in two places, and the day one is updated they disagree —
/// with the one on the landing being the one she reads first.
///
/// ⚠️ AND THE LIST IS NEVER TRIMMED FOR LAYOUT. The brief names two of the
/// signs in passing; showing only those two would drop bleeding, one-sided pain
/// and shoulder-tip pain, and shoulder-tip pain is the classic sign of a
/// ruptured ectopic — the one on the list a mother would otherwise ignore. A
/// red-flag list is shown whole or not at all.
class PvDoorRedFlag {
  const PvDoorRedFlag({
    required this.title,
    required this.lines,
    required this.surfaceId,
    this.footer,
    this.seeAll = true,
  });

  final String title;

  /// Whether the card links out to [surfaceId]. False when the card already
  /// carries everything that page would say (2026-09-18).
  final bool seeAll;

  /// The signs themselves, referenced from their one home.
  final List<PvDoorFlagLine> lines;

  /// Where "see all of this properly" goes.
  final String surfaceId;

  /// One sentence under the list.
  ///
  /// ⚠️ ADDED FOR A LINE THE COMPLICATIONS BRIEF ASKS FOR BY NAME: *"State
  /// plainly this tells you when to call and never replaces calling a doctor or
  /// going in."* It is content, so it lives in the data rather than in the
  /// renderer — a sentence typed into a shared widget is a sentence that
  /// appears on somebody else's warning.
  final String? footer;
}

/// One line on a pinned flag, and optionally where it goes.
///
/// ⚠️ THE PER-LINE DESTINATION EXISTS FOR ONE BRIEF'S ONE INSTRUCTION —
/// *"Each line opens the fuller page"* — and it is nullable because the other
/// flag on the app does not work that way. The pregnancy urgent list is seven
/// symptoms with one shared destination; the same-day condition list is five
/// lines each assembled from a different condition's own call-now section, and
/// each belongs back at that page.
///
/// ⚠️ A NULL TARGET IS NOT A DISABLED LINE. It means the flag as a whole has
/// the destination, which is what `PvDoorRedFlag.surfaceId` is for. Both flags
/// are fully usable; only the granularity differs.
class PvDoorFlagLine {
  const PvDoorFlagLine(this.text, {this.conditionId});

  /// What she reads. Plain — never a bare medical word, which the Complications
  /// brief forbids on a red-flag line specifically.
  final String text;

  /// The condition page this line opens, when it has one of its own.
  final String? conditionId;
}

/// What kind of tab a group is.
///
/// ⚠️ SEMANTIC, NOT VISUAL — SINCE 2026-09-11. This used to choose between a
/// horizontal rail and full-width rows. The user's call on the phone: every
/// section on every door is a card rail, so a woman learns one card and meets
/// it everywhere. `stack` still says something true about the tab — the tool
/// is the content and the sections under it are errands — and the briefs'
/// "do not render Sub-tabs 1 or 4 as card rails" is still honoured in the only
/// way that matters: those tabs lead with the tool, in place, and nothing sits
/// in front of it. The errands beneath draw as rails like everything else.
enum PvDoorLayout {
  /// A browse tab: headings and rails of cards, nothing inline above them.
  rails,

  /// A tool tab: the inline tool is the content; sections beneath are errands.
  /// Draws exactly like [rails] — the value is a description of the tab.
  stack,
}

/// One tab in the selector at the top of a door.
class PvDoorGroup {
  const PvDoorGroup({
    required this.id,
    required this.label,
    required this.icon,
    required this.hue,
    this.mark,
    this.inlineSurfaceId,
    this.inlineLabel,
    this.layout = PvDoorLayout.rails,
    this.pinnedRedFlag,
    this.note,
    this.noteFor,
  });

  /// Matched against [PvDoorSection.group].
  final String id;

  /// The words on the card. Short — it sits under a mark on a 172pt card.
  final String label;

  /// The mark at the centre of the card's drawing.
  /// The group's DRAWN mark for the tile selector — the rails' own hand
  /// (`HubIntentArt`), set per group so no icon-to-mark guessing happens.
  /// Null falls back to [icon] in ink. Added 2026-09-18 with `PvDoorTiles`.
  final IntentMark? mark;

  final IconData icon;

  /// The tab's own hue — its field, its rim, its lit dot.
  ///
  /// ⚠️ TAKEN FROM `V2BlockHues` WHERE ONE FITS, for the reason the cycle phase
  /// colours are: a hue in this app already means something, and inventing a
  /// family for one rail would put the door out of tune with every other
  /// surface she has seen.
  final double hue;

  /// One quiet line above this group's content.
  ///
  /// ⚠️ IT IS NOT A RED FLAG AND THE DIFFERENCE MATTERS. A pinned flag is a
  /// doctor-written "call someone today". This is a standing practical note —
  /// the brief's "not every pregnancy needs every test, this is the usual run,
  /// not a rule". Dressing that as a clinical warning would spend the alarm on
  /// the wrong thing. Quieter type, quieter box, no urgency.
  final String? note;

  /// The same note, when it depends on her week. Read only when [note] is
  /// null. Garbh Sanskar's "Why this week" is the line for what is forming —
  /// hearing, the nerve pathways for touch — and a page built once cannot
  /// hold forty of them; a function of the week can. An `int`, not a
  /// controller, for the reason `PvDoorSection.lead` gives.
  final String Function(int week)? noteFor;

  /// A tool rendered IN PLACE, above this group's sections.
  ///
  /// ⚠️ INLINE, NOT A TILE THAT OPENS IT. A card in front of a tool, inside a
  /// tab whose main content is that tool, is a door in front of a door. The
  /// brief calls sub-tabs 1 and 4 "tool screens, not rails" and means exactly
  /// this: the timeline IS My scans, it is not a link to My scans.
  ///
  /// A group may have both — an inline tool and sections under it — which is
  /// what My scans and My reports need, and what Understand a result needs for
  /// its search and chips.
  final String? inlineSurfaceId;

  /// The count line on this tab's card when the tool is the point of it.
  ///
  /// ⚠️ NAMED, NOT INFERRED FROM THE SURFACE. TTC's equivalent switches on the
  /// surface id and defaults to "Quick check", which was written when there was
  /// one tool group and stopped being true the moment there were two. A value
  /// inferred from the first caller is wrong at the second, every time.
  final String? inlineLabel;

  final PvDoorLayout layout;

  /// Shown above everything in this group, always visible.
  final PvDoorRedFlag? pinnedRedFlag;
}

/// One problem area, as one page with a selector at the top.
class PvDoorPage {
  const PvDoorPage({
    required this.bracketId,
    required this.heroTitle,
    required this.heroBlurb,
    required this.groups,
    required this.sections,
    this.heroImageUrl,
    this.closingLine,
  });

  /// Which bracket tile opens this. Matches a `Bracket.id`.
  final String bracketId;

  /// The line set over the hero.
  ///
  /// ⚠️ AN OVERRIDE, AND TTC'S OBJECTION TO ONE IS ANSWERED RATHER THAN
  /// IGNORED. `TtcFocusPage` deliberately has no title field: that screen once
  /// shipped headed "Getting pregnant" behind a tile reading "Fertile window",
  /// and landing on a different name than the one you tapped is the most
  /// disorienting thing a navigation can do.
  ///
  /// The brief asks to keep "Your scans, in one place." — which is not a
  /// different name, it is the same subject plus a promise. The drift is
  /// prevented a different way: the EYEBROW over this line is `bracket.label`,
  /// so the exact words on the tile she tapped are still on screen, above the
  /// sentence. She sees where she is and what it does, in that order.
  final String heroTitle;

  /// One plain sentence under the title. What this area is, not a welcome.
  final String heroBlurb;

  /// A photograph behind the hero.
  ///
  /// ⚠️ A URL IN DATA, AND THE DRAWN BRACKET MARK IS THE FALLBACK. Local-first
  /// is absolute: on a dead connection the hero renders the V3 field and the
  /// mark this bracket has always had, and the page is still finished — rather
  /// than a grey box where a photograph should be.
  final String? heroImageUrl;

  /// The tabs, in order. The first is the default.
  final List<PvDoorGroup> groups;

  final List<PvDoorSection> sections;

  /// One sentence at the foot of the door, under whichever tab is open.
  ///
  /// ⚠️ "ONCE" MEANS ONCE PER PAGE, NOT ONCE PER TAB. It renders below the
  /// sections of whatever group is open, so somebody who only ever opens the
  /// first tab still reads it. A line that appears only under the last tab is a
  /// line most people never see.
  final String? closingLine;

  /// Every tile on the page, in reading order. What the reachability test
  /// walks — including the tiles in tabs nobody has opened, which are the ones
  /// most likely to rot because they are the ones least often seen.
  List<PvDoorTile> get allTiles => [for (final s in sections) ...s.tiles];

  /// The sections belonging to one group, in order.
  List<PvDoorSection> sectionsOf(String groupId) =>
      [for (final s in sections) if (s.group == groupId) s];
}

// -----------------------------------------------------------------------------
//  A tile that opens another tab of the same door
// -----------------------------------------------------------------------------

/// Prefix of a surface id that means "switch this door to the tab named after
/// it" rather than "push a screen".
///
/// ⚠️ A LAUNCHER, WHICH IS WHAT GARBH SANSKAR'S TODAY TAB IS. The brief:
/// *"Today only opens the tabs below, it does not repeat their libraries."* A
/// card reading "Shravan, today's raga" switches the door to Listen, whose
/// first rail is today's pick. Pushing a second copy of Listen on top of the
/// door would leave her two levels deep inside one page.
///
/// The screen intercepts these before the router sees them; the router
/// resolves them as true so the wiring tests hold, and never builds a screen.
const String kPvDoorTabSurface = 'door/tab/';

/// The surface id that opens [groupId] of the same door.
String pvDoorTabSurface(String groupId) => '$kPvDoorTabSurface$groupId';

/// The group a tile switches to, or null when it pushes a screen.
String? pvDoorTabTarget(PvDoorTile tile) {
  final id = switch (tile) {
    PvDoorToolTile(:final surfaceId) => surfaceId,
    PvDoorChecklistTile(:final surfaceId) => surfaceId,
    PvDoorTalkTile(:final surfaceId) => surfaceId,
    PvDoorGameTile(:final surfaceId) => surfaceId,
    PvDoorReadTile(:final surfaceId) => surfaceId,
    PvDoorAudioTile(:final surfaceId) => surfaceId,
    PvDoorEntryTile() ||
    PvDoorVideoTile() ||
    PvDoorGuideTile() ||
    PvDoorMythTile() =>
      null,
  };
  if (id == null || !id.startsWith(kPvDoorTabSurface)) return null;
  return id.substring(kPvDoorTabSurface.length);
}

// =============================================================================
//  The registry
// -----------------------------------------------------------------------------
//  ⚠️ THE PAGES THEMSELVES LIVE ONE FILE PER DOOR, for the reason TTC split
//  its own: eight pregnancy doors are being built from eight briefs, and a
//  shared content file means a conflict per pair in a file where a bad
//  resolution loses whole sections rather than failing to compile.
//
//  ⚠️ ADDING A DOOR IS TWO LINES HERE — one import, one entry below. That is
//  the whole shared surface, and it is deliberately small enough that two
//  people editing it produces a conflict anyone can resolve at a glance.
// =============================================================================

/// ⚠️ `final`, NOT `const`. The Talk tab pins [kPregnancyUrgentFlag], which is
/// derived rather than typed, so the page holding it is not a constant
/// expression either. Nothing outside reads this as a const, so the difference
/// is invisible — worth knowing only if you add a door and wonder why `const`
/// no longer compiles.
final List<PvDoorPage> kPvDoorPages = [
  kScansDoor,
  kComplicationsDoor,
  kNutritionDoor,
  kBellySkinDoor,
  kLabourDoor,
  kMindDoor,
  kGarbhDoor,
];

/// The door for a bracket, or null when that bracket still opens a hub.
///
/// ⚠️ NULL IS THE NORMAL ANSWER TODAY. One of the pregnancy brackets has a
/// door; the rest open `BracketScreen` or a hub and should, until their own
/// brief is built. Adding a door for an area is a judgement about that area,
/// never a migration to run across all of them.
PvDoorPage? pvDoorPageFor(String bracketId) {
  for (final page in kPvDoorPages) {
    if (page.bracketId == bracketId) return page;
  }
  return null;
}

/// The pinned red flag every pregnancy door shares.
///
/// ⚠️ ONE OBJECT, REFERENCED BY WHICHEVER DOOR NEEDS IT. Seven more briefs are
/// coming and several of them will pin a warning; each one typing its own copy
/// is how seven versions of the same clinical list come to disagree.
/// ⚠️ `final`, NOT `const`, AND IT CANNOT BE OTHERWISE. Its lines are derived
/// from `kScanUrgentSigns` by a comprehension, and a comprehension is not a
/// constant expression. That is the price of referencing the one copy instead
/// of retyping it, and it is the right price.
final PvDoorRedFlag kPregnancyUrgentFlag = PvDoorRedFlag(
  title: 'Call your doctor if',
  lines: kScanUrgentSignsEn,
  surfaceId: 'scans/urgent',
  // The urgent screen's one sentence that the card did not carry, carried.
  // With it here, "See all of these" opened a page that repeated the seven
  // lines above it (the door walk, 2026-09-18) — so the card no longer
  // links out. `ScanUrgentScreen` stays for revert.
  footer: 'Call, do not message — your obstetrician, the labour ward, or the '
      'nearest hospital with a maternity unit. If you cannot reach anyone '
      'and the pain or bleeding is bad, go in.',
  seeAll: false,
);

/// `kScanUrgentSigns` in English, which is the only language this door writes.
///
/// ⚠️ NOT A SECOND COPY OF THE WORDS — it is derived from the one list at load
/// time, so editing `scan_extras.dart` changes both. Writing them out again
/// here is exactly what the note on [PvDoorRedFlag] forbids.
///
/// ⚠️ `.en`, NOT `.now`. CLAUDE.md's standing trap: `.now` is display and is
/// wrong wherever a value is persisted, compared, or read outside the widget
/// that draws it. This list is built once at startup, before any language
/// choice can be read, so `.now` here would freeze whatever the store happened
/// to hold at that moment. The door is English by policy; the flag renders the
/// English.
final List<PvDoorFlagLine> kScanUrgentSignsEn = [
  // ⚠️ NO PER-LINE TARGET, AND THAT IS CORRECT FOR THIS LIST. These are
  // symptoms of a pregnancy rather than of a named condition — bleeding does
  // not have "a page"; it has an urgent screen, which the flag as a whole
  // opens. See `PvDoorFlagLine.conditionId`.
  for (final s in kScanUrgentSigns) PvDoorFlagLine(s.en),
];

/// The Complications door's assembled same-day list.
///
/// ⚠️ EVERY LINE IS DRAWN FROM A CONDITION'S OWN CALL NOW SECTION and opens
/// that page. See `same_day_signs_data.dart` for why assembling rather than
/// authoring is the strictest rule on that door: a red-flag list typed fresh
/// into a data file has had none of the clinical review the twenty-seven
/// condition pages passed, and it would sit above all of them.
final PvDoorRedFlag kSameDayFlag = PvDoorRedFlag(
  title: 'Signs to get help the same day',
  lines: [
    for (final s in kSameDaySigns)
      PvDoorFlagLine(s.line, conditionId: s.conditionId),
  ],
  surfaceId: 'conditions/same_day',
  footer: kSameDayFooter,
  // Each line already opens its condition; the "See all" screen was the
  // same five lines with the condition named (2026-09-19). Kept by route.
  seeAll: false,
);
