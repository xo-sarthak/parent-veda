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

import '../scan_extras.dart' show kScanUrgentSigns;
import 'pv_door_scans.dart';

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
        PvDoorFormat.guide => 'Guide',
        PvDoorFormat.read => 'Read',
        PvDoorFormat.mythFact => 'Myth vs fact',
        PvDoorFormat.checklist => 'Checklist',
        PvDoorFormat.talk => 'Talk',
      };
}

// -----------------------------------------------------------------------------
//  The tiles
// -----------------------------------------------------------------------------

sealed class PvDoorTile {
  const PvDoorTile({
    required this.title,
    required this.blurb,
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

/// One scan or test, on the rich page the stage already ships for it.
///
/// ⚠️ A TILE TYPE OF ITS OWN RATHER THAN A TOOL POINTING AT A SURFACE, and the
/// reason is the wiring gate. `scanId` must exist in `kTestsScans`, which a
/// test can check; a surface string like `scan/nt_scan` can only be checked by
/// the router agreeing to know it, and a router that does not know an id
/// returns null and the tile silently does nothing.
///
/// ⚠️ AND THE CHIP SAYS "Article", WHICH IS WHAT THE BRIEF MARKS IT. The
/// destination is a written piece about one scan — what it is, why it is done,
/// how to prepare, what the report says. That is an article that happens to
/// live in a data library rather than a reads library.
final class PvDoorScanTile extends PvDoorTile {
  const PvDoorScanTile({
    required super.title,
    required super.blurb,
    required this.scanId,
    super.comingSoon,
  });

  /// Must exist in `kTestsScans`. Held by `test/pv_door_scans_test.dart` for the
  /// reason every other id here is held: a tile whose id is wrong renders
  /// perfectly and does nothing.
  final String scanId;

  @override
  PvDoorFormat get format => PvDoorFormat.article;
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
  }) : super(comingSoon: false);

  /// The piece is not written. The card draws at full size and does not tap.
  const PvDoorReadTile.comingSoon({
    required super.title,
    required super.blurb,
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
  });

  final String heading;
  final List<PvDoorTile> tiles;

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
  });

  final String title;

  /// The signs themselves, referenced from their one home.
  final List<String> lines;

  /// Where "see all of this properly" goes.
  final String surfaceId;
}

/// How a group lays its sections out.
enum PvDoorLayout {
  /// A heading and a horizontal scroll of cards. The default, and what the
  /// brief calls a card rail.
  rails,

  /// Full-width rows, stacked.
  ///
  /// ⚠️ THIS EXISTS BECAUSE THE BRIEF FORBIDS RAILS ON TWO TABS BY NAME — "Do
  /// not render Sub-tabs 1 or 4 as card rails" — and it is right to. My scans
  /// and My reports are TOOL SCREENS: the timeline or the locker is the
  /// content, and the two or three things beside it are errands, not a library
  /// to browse. A rail says "there is more sideways"; on a tab with three items
  /// and a tool above them, there is not.
  stack,
}

/// One tab in the selector at the top of a door.
class PvDoorGroup {
  const PvDoorGroup({
    required this.id,
    required this.label,
    required this.icon,
    required this.hue,
    this.inlineSurfaceId,
    this.inlineLabel,
    this.layout = PvDoorLayout.rails,
    this.pinnedRedFlag,
    this.note,
  });

  /// Matched against [PvDoorSection.group].
  final String id;

  /// The words on the card. Short — it sits under a mark on a 172pt card.
  final String label;

  /// The mark at the centre of the card's drawing.
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
final List<String> kScanUrgentSignsEn = [
  for (final s in kScanUrgentSigns) s.en,
];
