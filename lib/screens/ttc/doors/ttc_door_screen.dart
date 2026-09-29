// =============================================================================
//  TtcDoorScreen — a Trying-to-Conceive door in the new door language
// -----------------------------------------------------------------------------
//  Renders a `TtcFocusPage` the way the pregnancy doors render a `PvDoorPage`
//  (Scans and tests, Complications, Symptoms, Nutrition, Garbh): a photograph
//  hero whose eyebrow is the door's name and whose headline is a sentence, a
//  live search field under the blurb, a white sheet, a rail of white cards
//  with drawn marks straddling the seam, and under it the open tab.
//
//  ⚠️ MIRROR, DON'T MERGE (2026-09-26). The pregnancy engine is not generic:
//  it reads `PregnancyController`, pregnancy stores, pregnancy const gates and
//  the pregnancy router and search. This is its TTC copy, built from the
//  stage-neutral pieces it already exposes (`PvDoorSheet`, `PvDoorRailCard`,
//  `PvDoorDisclaimer`, `pvDoorPad`, `PvLiveSearch`, `V3HeroField`, `PvPress`)
//  and the TTC side's own model, opener and router. Same precedent as the
//  parenting and skilling engines. Nothing here touches a pregnancy file.
//
//  ⚠️ THE OLD SCREEN STAYS ON DISK. `TtcFocusScreen` renders the same data and
//  is reachable from nowhere once the three openers call `openTtcDoor`; the
//  pushes it replaced are commented at each call site, kept for revert.
//
//  ---------------------------------------------------------------------------
//  The build order, top to bottom, and why each is where it is
//  ---------------------------------------------------------------------------
//    hero       photo + dark scrim, eyebrow (the tile's own words), the
//               sentence, the blurb, the search field
//    rail       one white card per tab, half over the photo, half on the sheet
//    red flag   the read's own `whenToSeeSomeone`, as an ink rule, a heading
//               and a coral dot; never retyped, never in a box
//    note       an icon and a grey line
//    tool       rendered in place, ABOVE the tab's sections (not instead)
//    sections   a plain-question heading, then rows if every tile is written,
//               else a rail of cards
//    closing    the page's one line, unless the tab's note already says it
//    disclaimer "general information, not medical advice" (the estimates
//               line only where a door estimates; review D1, 2026-09-26)
//
//  ⚠️ THE REVIEW FIXES, 2026-09-26 (Mobbin review D1, D2, D3, D5):
//    D1  the disclaimer is `TtcS.doorDisclaimer`, plus the estimates line on
//        the one door that estimates ([kTtcDoorsThatEstimate]).
//    D2  the pinned flag is one short line per sign: the read's own callout,
//        split into its sentences for display ([ttcFlagLines]), never
//        retyped. Flo's "Seek immediate medical help if", one sign per dot
//        (https://mobbin.com/screens/0482506d-3f84-42f3-8c1c-f9ec3d6b48ea).
//    D3  the keyboard's Search key with no match no longer jumps into Ask
//        Veda: it stays on the rows, where "Ask Veda about ..." is offered.
//    D5  the whole flag opens its read, and "Read the full piece" is a 44pt
//        target, as the pregnancy flag is.
//
//  ⚠️ ONE SYSTEM, NOT NINE (the user walking build 13, 2026-09-27: the doors
//  looked "bland" and "random", "so many elements placed but not blending",
//  "everything should feel done on purpose rather than random"). Six
//  changes, each fixing one source of "random":
//    1  the hero is ONE height on every door ([kTtcDoorHeroHeight]); the
//       headline clamps to two lines and the blurb to three, so a long blurb
//       no longer makes a taller photograph. The scrim is lighter, and the
//       photograph PARALLAXES: it climbs at under half the scroll speed
//       while the sheet slides up over it (the doctor app's `DcHero`
//       mechanism, copied, not shared: a scroll offset in a notifier, the
//       photo translated by a fraction of it).
//    2  the search field is glass on the photograph
//       (`TtcDoorGlassSearchField`), not a white slab.
//    3  every section is a rail of ONE card (`TtcDoorSectionCard`), never
//       rows: the rows-when-all-written rule is retired (kept for revert).
//       A card with no photo is typographic, not a faded ghost shape.
//       ⚠️ 2026-09-29: the one card is now `TtcKindCard` on every door, one
//       shape with a tint, a kind pill and a fact pill per kind, after the
//       user's reference picture (`ttc_kind_cards.dart`, DESIGN-SYSTEM
//       §4.0f). `TtcDoorSectionCard` is the never-reached fallback.
//    4  a pinned red flag is one compact row that opens the full list in a
//       sheet (`TtcDoorFlagRow`); nothing clinical removed, only folded.
//    5  one heading style for every section: pvFraunces 21 w600.
//    6  one vertical rhythm ([_kTtcDoorBlockGap], [_kTtcDoorHeadingGap]).
//
//  ⚠️ THE IVF DOOR'S TOP PANEL (B7): `TtcIvfRoundPanel`, "Your round" /
//  "Between rounds" / "Positive test" / "Starting treatment?", and while a
//  round is planned or running "Going through it" and "Track" lead the rail
//  (`kTtcIvfRoundTabsFirst`, order only).
//
//  ⚠️ ADDING A DOOR OR A TAB IS DATA ONLY. A door is a `TtcFocusPage` in
//  `lib/ttc/focus/` plus one line in `kTtcFocusPages`; a tab is a
//  `TtcFocusGroup` (with a `mark`) plus sections naming its id. Nothing in
//  this file is keyed on a bracket id, except two small, commented lists
//  (2026-09-28): the one tab that still opens on a safety line
//  ([kTtcDoorFlagTabs]) and the tabs that end on "Get help now"
//  ([kTtcDoorGetHelpTabs]). They are rules about safety, so they live in code
//  beside the renderer, not in the door data.
//
//  ⚠️ SAFETY LINES, 2026-09-28 (the user's option B): item 4 above now
//  applies to one tab only. The folded flag row came off the top of every
//  other tab; see [kTtcDoorFlagTabs].
// =============================================================================

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../../../localization/app_language.dart';
import '../../../models/bracket.dart';
import '../../../models/pv_read.dart';
import '../../../services/bracket_resolver.dart' show bracketById;
import '../../../services/ttc_search_store.dart';
import '../../../theme/pv_fonts.dart';
import '../../../ttc/ttc_content_prefs.dart';
import '../../../ttc/ttc_fertility_help_rules.dart'
    show FertilityAgeBand, FertilityAgeBandCopy;
import '../../../ttc/ttc_fertility_help_store.dart';
import '../../../ttc/ttc_focus_data.dart';
import '../../../ttc/ttc_reads_data.dart';
import '../../../ttc/ttc_practice_data.dart'
    show TtcPractice, TtcPracticeKind, ttcPracticeById;
import '../../../ttc/ttc_videos_data.dart' show ttcVideoBySlot;
import '../../../widgets/pv_feedback.dart';
import '../../brackets/hub/hub_intent_art.dart';
import '../../doors/pv_door_chrome.dart';
import '../../doors/pv_live_search.dart';
import '../../products/pv_store_chrome.dart' show PvChip;
import '../../v2/v2_palette.dart';
import '../../v2/v3_bracket_art.dart';
import '../../v2/v3_hero_field.dart';
import '../ttc_askveda_screen.dart' show openTtcAskVeda;
// Kept for revert (2026-09-27): `iconForFormat` too, for `PvDoorRailCard`'s
// icon; the TTC section card draws the format's mark instead.
import '../ttc_focus_screen.dart'
    show openTtcFocusTile, openTtcArticle, photoForTile;
import '../../../data/mind_mood_data.dart'
    show kEmergencyNumber, kAmbulanceNumber;
import '../ttc_get_help_screen.dart'
    show TtcGetHelpRow, openTtcGetHelp, ttcDialNumber, TtcDial;
import '../ttc_intimate_offer.dart' show ttcMaybeOfferIntimateSwitch;
import '../ttc_common.dart' show ttcSectionHeadingStyle;
import '../ttc_strings.dart';
import '../ttc_surface_router.dart' show ttcInlineToolFor, openTtcSurface;
// Kept for revert: `show TtcStartTreatmentCard` (the panel draws it now).
import '../ttc_treatment_round_screens.dart'
    show TtcIvfRoundPanel, ttcIvfRoundLeads;
import '../../../ttc/ttc_treatment_store.dart';
import 'ttc_door_card.dart';
import 'ttc_door_hero.dart';
import 'ttc_door_rail.dart';
import 'ttc_door_search.dart';
import 'ttc_kind_cards.dart';

// -----------------------------------------------------------------------------
//  Keys a test can find
// -----------------------------------------------------------------------------

const Key kTtcDoorSearchKey = ValueKey('ttc-door-search');
Key ttcDoorFlagKey(String readId) => ValueKey('ttc-door-flag-$readId');
Key ttcDoorRowsKey(String heading) => ValueKey('ttc-door-rows-$heading');
Key ttcDoorSectionRailKey(String heading) =>
    ValueKey('ttc-door-section-rail-$heading');

const Key kTtcDoorHeroKey = ValueKey('ttc-door-hero');

/// The compact bar that pins once the hero has scrolled away (D2).
const Key kTtcDoorPinnedBarKey = ValueKey('ttc-door-pinned-bar');

/// The line under "Nothing here by that name yet" (D6).
const Key kTtcDoorSearchEmptyKey = ValueKey('ttc-door-search-empty');

/// Words that find something on every door, offered when a search finds
/// nothing (D6). Each one is a stage-wide topic with reads behind it, so a
/// tap is never a second empty page (`ttc_door_screen_test` holds that).
const List<String> kTtcDoorSearchSuggestions = [
  'Fertile window',
  'Ovulation tablets',
  'Semen test',
  'PCOS',
  'Two-week wait',
];

/// A section of one piece, drawn as the one wide card (D13).
Key ttcDoorSectionWideKey(String heading) =>
    ValueKey('ttc-door-section-wide-$heading');

/// A way to another door, drawn as a plain link row (MB20).
Key ttcDoorLinkKey(String bracketId) => ValueKey('ttc-door-link-$bracketId');

// -----------------------------------------------------------------------------
//  Which tabs open on a safety line, and which end on "Get help now"
// -----------------------------------------------------------------------------

/// ⚠️ THE ONLY TABS THAT STILL OPEN ON A SAFETY LINE (the user, 2026-09-28,
/// option B). Every door tab used to open on its pinned read's "When to see
/// someone" list as a tinted row (Mind & body › Hard days opened on "When to
/// get help for low mood or anxiety"), which put a warning above the content
/// on nine tabs across six doors. The guidance is not gone: it is each read's
/// own "When to see someone" section, which `PvReaderScreen` always draws, and
/// every one of those reads is still a tile on its door.
///
/// The rule for this list: a tab keeps its line at the top ONLY when the
/// topic can be a real emergency that should not wait for her to open a read.
/// Today that is one tab: After a loss › Your body, whose read's list is heavy
/// bleeding, severe pain, pain in the tip of the shoulder (a sign of an
/// ectopic pregnancy), fever and fainting ("Go to a hospital today, not
/// tomorrow"). Low mood is serious but is not routed by a banner: it has the
/// calm "Get help now" page below. Keyed by bracket id, then tab id; the
/// pinned read ids stay on the data (`TtcFocusGroup.pinnedRedFlagReadIds`)
/// so turning a tab back on is one line here.
const Map<String, Set<String>> kTtcDoorFlagTabs = {
  'ttc_after_loss': {'body'},
};

/// Whether tab [groupId] of door [bracketId] opens on its safety line.
bool ttcDoorShowsFlag(String bracketId, String groupId) =>
    kTtcDoorFlagTabs[bracketId]?.contains(groupId) ?? false;

/// ⚠️ THE TABS THAT END ON A WAY TO "GET HELP NOW" (2026-09-28). At the END of
/// the tab, after its content, as a question ("Need to talk to someone
/// now?"), never above it: an offer she can take, not a warning she is shown.
///   · Mind & body › Hard days, where the removed low-mood line was.
///   · Mind & body › Today, because it is the tab the door OPENS on, so the
///     way to help is on the door without a hunt, and at the foot of a few
///     calm minutes it reads as care rather than alarm. The alternative,
///     under the tab rail on every tab, would have been the banner again.
///   · Mind & body › Talk (launch sanity MB22, 2026-09-28): the tab about
///     talking to someone. Its two pinned lists no longer open it (see
///     [kTtcDoorFlagTabs]), so its one way to urgent help is this calm row
///     at its end, not two alarms at its top.
const Map<String, Set<String>> kTtcDoorGetHelpTabs = {
  // Kept for revert (2026-09-28): 'ttc_mind_body': {'today', 'hard'},
  'ttc_mind_body': {'today', 'hard', 'talk'},
};

/// Whether tab [groupId] of door [bracketId] ends on the Get help row.
bool ttcDoorEndsOnGetHelp(String bracketId, String groupId) =>
    kTtcDoorGetHelpTabs[bracketId]?.contains(groupId) ?? false;

/// How far the photograph runs on under the sheet's rounded top. The rail
/// lifts by `TtcDoorRail.overlap` on top of this; see `_Hero._bleed`.
const double kTtcDoorHeroOverlap = 38;

/// The hero's height under the status bar, the same on every door
/// (2026-09-27, the user: "the hero image height differs door to door").
/// Sized to hold the back button, the eyebrow, a two-line headline, a
/// three-line blurb and the field, so the clamps below are what keep it
/// fixed. At a very large text size the hero grows rather than overflow.
///
/// ⚠️ SUPERSEDED 2026-09-29 by `ttcDoorHeroHeight(width, top)` in
/// ttc_door_hero.dart: the art's 3:2 frame is as tall as the screen is wide
/// allows, so the one height is per screen, still the same on every door.
/// Kept for revert and for `_Hero`.
const double kTtcDoorHeroHeight = 344;

/// The gap from the sheet's edge to the tab rail (2026-09-29): the same as
/// the search pill keeps above the edge (`kTtcDoorHeroFootGap`), so the pill
/// and the cards each have their own clear space.
const double kTtcDoorRailTopGap = kTtcDoorHeroFootGap;

/// The one vertical rhythm on a door (2026-09-27): the gap between any two
/// blocks (rail, panel, flag, note, tool, section, closing line), and the
/// gap between a section's heading and its rail.
const double _kTtcDoorBlockGap = 24;
const double _kTtcDoorHeadingGap = 12;

/// The section heading, one style for every section on every door (and the
/// inline Mind & body Today panel matches it).
///
/// 2026-09-29 (one heading style): it IS the stage's one section heading now,
/// `ttcSectionHeadingStyle` in ttc_common.dart, so a door and a tool page can
/// no longer drift apart. Kept for revert, the same numbers inline:
///   pvFraunces(fontSize: 21, fontWeight: FontWeight.w600, height: 1.2,
///       letterSpacing: -0.45, color: p.ink1)
TextStyle ttcDoorHeadingStyle(V2Palette p) =>
    ttcSectionHeadingStyle(color: p.ink1);

// -----------------------------------------------------------------------------
//  The one opener
// -----------------------------------------------------------------------------

/// Open the door for [bracketId]. Returns false, and opens nothing, when the
/// bracket has no door, so a caller can fall through to a hub.
///
/// ⚠️ ONE OPENER, THREE CALLERS (the home's `_openBracket`, the semen report's
/// IVF gateway, and a "Elsewhere" tile inside another door). Each used to build
/// its own `MaterialPageRoute`, which is how a door ends up reachable in one
/// design from one entrance and the old design from another.
///
/// ⚠️ THE ROUTE NAME IS UNCHANGED: `ttc/focus/<id>`. `global_ask_fab.dart`
/// reads route names to decide which Ask Veda opens, so the name is an
/// identity and survives the redesign.
bool openTtcDoor(
  BuildContext context,
  String bracketId, {
  String? initialGroup,
}) {
  final page = ttcFocusPageFor(bracketId);
  final bracket = bracketById(bracketId);
  if (page == null || bracket == null) return false;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: 'ttc/focus/$bracketId'),
      builder: (_) => TtcDoorScreen(
        page: page,
        bracket: bracket,
        initialGroup: initialGroup,
      ),
    ),
  );
  return true;
}

// -----------------------------------------------------------------------------
//  Tile helpers, public so the test can hold the rules
// -----------------------------------------------------------------------------

/// Whether a tile opens a piece of writing in the one reader. A section of
/// only these draws as rows (DESIGN-SYSTEM §4.0 addendum 2); anything mixed
/// keeps the rail.
///
/// ⚠️ A MYTH IS NOT "WRITTEN" HERE, UNLIKE ON THE PREGNANCY DOORS. A TTC myth
/// opens the story deck (`TtcStoryScreen`), not the reader, and a row
/// promises a page to read.
bool ttcDoorTileIsWritten(TtcTile t) =>
    t is TtcArticleTile || t is TtcGuideTile;

/// ⚠️ RETIRED ON THE DOOR 2026-09-27: every section is a card rail now (the
/// user, of His side › Understand: rows for "Is it about him?" and cards for
/// "Is it worth testing?" in one tab read as random; "Fertile window seems
/// consistent because it follows the card design throughout"). The screen no
/// longer calls this. Kept for revert, with the rows branch in `build`.
bool ttcDoorSectionIsRows(List<TtcTile> tiles) =>
    tiles.isNotEmpty && tiles.every(ttcDoorTileIsWritten);

/// The chip on a card. One word per format (DESIGN-SYSTEM §4.0b): a guide
/// opens the reader, so it is an Article; the one thing that costs money
/// says so before she taps.
String ttcDoorChip(TtcTile t) {
  if (t.format.isPaid) return 'Paid';
  if (t is TtcGuideTile) return 'Article';
  return t.format.label;
}

/// The format as a drawn mark: the row well and the card's ghost.
IntentMark ttcDoorFormatMark(TtcTileFormat f) => switch (f) {
  TtcTileFormat.masterclass => IntentMark.schoolMark,
  TtcTileFormat.tool => IntentMark.toolMark,
  TtcTileFormat.article => IntentMark.pageMark,
  TtcTileFormat.carousel => IntentMark.listMark,
  TtcTileFormat.video => IntentMark.playMark,
  TtcTileFormat.mythFact => IntentMark.questionMark,
  TtcTileFormat.product => IntentMark.bagMark,
  TtcTileFormat.booking => IntentMark.calendarDay,
  TtcTileFormat.recipe => IntentMark.cookMark,
  TtcTileFormat.community => IntentMark.cuppedHands,
  TtcTileFormat.infographic => IntentMark.compareMark,
  TtcTileFormat.practice => IntentMark.lotusMark,
  TtcTileFormat.checklist => IntentMark.checkMark,
  TtcTileFormat.talk => IntentMark.askDoctor,
  // ⚠️ AN "ARTICLE" CHIP WEARS THE PAGE MARK, WHATEVER ITS FORMAT (launch
  // sanity MB16, 2026-09-28). A guide opens the reader and its chip says
  // Article (`ttcDoorChip`), but it drew the open book, so one row of
  // "Article" cards carried two different glyphs. One chip, one mark.
  // Kept for revert: TtcTileFormat.guide => IntentMark.bookMark,
  TtcTileFormat.guide => IntentMark.pageMark,
  TtcTileFormat.door => IntentMark.nextStep,
};

/// The practice a tile opens, when it opens one (`ttc_practice/<id>`).
TtcPractice? ttcTilePractice(TtcTile t) => switch (t) {
  TtcDoTile(:final surfaceId) when surfaceId.startsWith('ttc_practice/') =>
    ttcPracticeById(surfaceId.substring('ttc_practice/'.length)),
  _ => null,
};

/// ⚠️ A PRACTICE WEARS ITS KIND (launch sanity MB15, 2026-09-28). Every
/// practice card on Mind & body › The practice drew the same lotus, so a
/// stretch looked like a breath. A movement draws steps, a breath draws the
/// wind; anything else keeps its format's mark. Everything else on a door is
/// [ttcDoorFormatMark], one mark per chip.
IntentMark ttcDoorTileMark(TtcTile t) => switch (ttcTilePractice(t)?.kind) {
  TtcPracticeKind.move => IntentMark.stepsMark,
  TtcPracticeKind.breathe => IntentMark.windMark,
  null => ttcDoorFormatMark(t.format),
};

/// Whether [t] is a film that is not made yet: a video tile whose slot has
/// no file (`PvVideoSlot.isLive`), or names no slot at all (D3, L3).
bool ttcTileIsUnmadeFilm(TtcTile t) =>
    t is TtcVideoTile && !(ttcVideoBySlot(t.slotId)?.isLive ?? false);

/// The words an unmade film says on its card, in place of a duration.
const String kTtcFilmComingSoon = 'Coming soon';

/// A section's rail, in the order she should meet it (D3, 2026-09-28): the
/// door tiles leave the rail for their own link rows (MB20), and a film that
/// is not made yet goes LAST, behind everything she can open today. Order
/// only; nothing is hidden, because the empty slot is the film's promise.
List<TtcTile> ttcDoorRailTiles(List<TtcTile> tiles) => [
  for (final t in tiles)
    if (t is! TtcDoorTile && !ttcTileIsUnmadeFilm(t)) t,
  for (final t in tiles)
    if (t is! TtcDoorTile && ttcTileIsUnmadeFilm(t)) t,
];

/// One small fact above a card's title. The tile's own `meta` wins; else it
/// is DERIVED, never typed: a read's minutes from its words, a film's
/// duration, a deck's slide count. A number nobody updates is worse than none.
String? ttcDoorTileMeta(TtcTile t) {
  if (t.meta case final m?) return m;
  String? minutes(String? readId) {
    if (readId == null) return null;
    final r = ttcReadById(readId);
    return r == null ? null : '${r.minutes} min read';
  }

  return switch (t) {
    TtcArticleTile(:final readId) => minutes(readId),
    TtcGuideTile(:final readId) => minutes(readId),
    // D3 (2026-09-28): an unmade film says so, never "6 min film". Kept for
    // revert: TtcVideoTile(:final duration) => '${duration.toLowerCase()} film',
    TtcVideoTile(:final duration) => ttcTileIsUnmadeFilm(t)
        ? kTtcFilmComingSoon
        : '${duration.toLowerCase()} film',
    TtcCarouselTile(:final cards) => '${cards.length} slides',
    TtcMythTile(:final slides) =>
      slides.isEmpty ? null : '${slides.length} slides',
    // MB15 (2026-09-28): a practice says how long, from the library's own
    // words, shortened: "About 3 minutes" is "About 3 min".
    TtcDoTile() => ttcTilePractice(t)?.duration
        .replaceAll(RegExp(r'\bminutes?\b'), 'min'),
    _ => null,
  };
}

// =============================================================================
//  The shared-phone switch: what she has chosen not to see
// -----------------------------------------------------------------------------
//  "Hide sex and intimacy content" (`TtcContentPrefs.hideIntimate`, gap plan
//  "Behind — Settings"). Many phones in India are shared with family, so when
//  it is on, the door leaves out the Sex and closeness tab
//  (`kTtcIntimateGroupId`) and every tile that opens a read in
//  `kTtcIntimateReadIds`, wherever that tile sits.
//
//  ⚠️ ONE FUNCTION, CALLED BY THE SCREEN AND BY THE SEARCH INDEX. The obvious
//  build is an `if` in each place that draws a tab, a count, a section and a
//  search row, and the one that gets missed is the search: the tab vanishes,
//  and typing "lubricant" into the field still lists the piece. Filtering the
//  PAGE once, before anything reads it, means every consumer downstream sees
//  the same smaller page and none of them has to know the switch exists.
//
//  ⚠️ CONTENT, NEVER STRUCTURE (CLAUDE.md, personalisation). Every other tab
//  stays in its place; the switch only takes pieces out. A section left with
//  no tiles goes, and a tab left with no sections and no tool goes, because a
//  tab that opens onto nothing is worse than no tab. Timing is never hidden:
//  it is not the private part, and it lives in other tabs.
// =============================================================================

/// Whether a tile opens a read the switch hides.
bool ttcTileIsIntimate(TtcTile t) => switch (t) {
  TtcArticleTile(:final readId, :final moreReadId) =>
    kTtcIntimateReadIds.contains(readId) ||
        kTtcIntimateReadIds.contains(moreReadId),
  TtcGuideTile(:final readId) => kTtcIntimateReadIds.contains(readId),
  _ => false,
};

/// [page] as she has chosen to see it. Returns [page] itself, untouched, when
/// nothing is hidden, so the common case costs nothing.
TtcFocusPage ttcDoorVisiblePage(
  TtcFocusPage page, {
  required bool hideIntimate,
}) {
  if (!hideIntimate) return page;
  // ⚠️ A FIELD ADDED TO `TtcFocusPage` MUST BE COPIED BELOW, or the switch
  // quietly drops it from every door while it is on.
  final sections = <TtcFocusSection>[
    for (final s in page.sections)
      if (s.group != kTtcIntimateGroupId)
        if ([
          for (final t in s.tiles)
            if (!ttcTileIsIntimate(t)) t,
        ] case final tiles when tiles.isNotEmpty)
          TtcFocusSection(heading: s.heading, group: s.group, tiles: tiles),
  ];
  final groups = page.groups == null
      ? null
      : <TtcFocusGroup>[
          for (final g in page.groups!)
            if (g.id != kTtcIntimateGroupId &&
                ((g.inlineSurfaceId ?? g.toolSurfaceId) != null ||
                    sections.any((s) => s.group == g.id)))
              g,
        ];
  return TtcFocusPage(
    bracketId: page.bracketId,
    intro: page.intro,
    sections: sections,
    heroVideoSlot: page.heroVideoSlot,
    heroVideoTitle: page.heroVideoTitle,
    headline: page.headline,
    groups: groups,
    heroImageUrl: page.heroImageUrl,
    heroBlurb: page.heroBlurb,
    closingLine: page.closingLine,
    heroTitle: page.heroTitle,
  );
}

// =============================================================================
//  Tab order by her age (2026-09-26, gap plan: "put the age tab higher in
//  IVF & IUI")
// -----------------------------------------------------------------------------
//  ⚠️ ORDER, NEVER STRUCTURE (CLAUDE.md, personalisation). Every tab stays on
//  the rail; the one change is that "Age and second baby" moves up to second
//  when she has told us she is 35 or over. Nothing is hidden and nothing is
//  added, so the door she learns is the same door everyone learns.
//
//  ⚠️ THE FIRST TAB NEVER MOVES. A door with no chosen tab opens on the first
//  one, so moving a tab into first place would change where she lands. Second
//  is one tap from the top, which is all the analysis asked for.
//
//  The age is the fertility-help tool's saved band (`TtcFertilityHelpStore`),
//  the same answer the six-month rule reads. "35 or over" is
//  `refersAtPresentation`, so the tab and the rule cannot disagree about where
//  35 falls.
// =============================================================================

/// The doors that estimate something (the fertile window), so their
/// disclaimer keeps the estimates line before the general one (D1).
const Set<String> kTtcDoorsThatEstimate = {'ttc_conceiving'};

/// ⚠️ THE ESTIMATES LINE ONLY UNDER TABS THAT ESTIMATE (launch sanity D5,
/// 2026-09-28). The Fertile window door ended EVERY tab on "These are
/// estimates, never guarantees…", Sex and closeness included, where nothing
/// is estimated; a disclaimer that does not fit the page trains her to skip
/// the one that does. By bracket id, then tab id: the tabs whose pieces
/// work out dates (the fertile days, when to test). Every other tab keeps
/// the general line only.
const Map<String, Set<String>> kTtcDoorEstimateTabs = {
  'ttc_conceiving': {'trying', 'waiting'},
};

/// The disclaimer at the foot of a door (D1), for tab [groupId] (D5). With
/// no tab (a door with no rail, or a caller that does not know) the door's
/// own rule stands, so the line is never lost where the door estimates.
String ttcDoorDisclaimerFor(String bracketId, [String? groupId]) {
  final t = TtcS.current();
  final estimates = kTtcDoorsThatEstimate.contains(bracketId) &&
      (groupId == null ||
          (kTtcDoorEstimateTabs[bracketId]?.contains(groupId) ?? true));
  // Kept for revert: kTtcDoorsThatEstimate.contains(bracketId) alone.
  return estimates
      ? '${t.estimatesDisclaimer} ${t.doorDisclaimer}'
      : t.doorDisclaimer;
}

/// ⚠️ THE IVF DOOR'S ROUND PANEL SITS ON THE TABS ABOUT A ROUND (launch
/// sanity D10, 2026-09-28). "Starting treatment? … Start" repeated at the
/// top of every tab and pushed Money and clinics' own content down for an
/// action that does not belong there. It stays where a round is the
/// subject: Understand (what the treatments involve), Going through it and
/// Track. The other tabs (Should I get help?, Age and second baby, Money
/// and clinics) open on their own content.
const Set<String> kTtcIvfPanelTabs = {'understand', 'going', 'track'};

/// Whether the IVF door's round panel shows on tab [groupId].
bool ttcIvfPanelShowsOn(String? groupId) =>
    groupId == null || kTtcIvfPanelTabs.contains(groupId);

/// The callout's body as one short line per sign (D2): split on its own line
/// breaks, then into sentences. The words are the read's own, in order and
/// whole; nothing is trimmed or retyped, so the self-harm routing on After a
/// loss and Mind and body travels intact. A full stop after a short
/// abbreviation ("Dr.", "e.g.") or before a lowercase word or a number does
/// not end a line.
///
/// ⚠️ ONLY THE FIRST BLOCK IS SIGNS (launch walk, 2026-09-27). A callout may
/// close with advice after a blank line ("These are signs of heavy bleeding
/// or infection. Both can be treated…"); split into sentences, that advice was
/// drawn as four more bullets and an urgent list read as ten signs. The text
/// after the first blank line is [ttcFlagProse] and renders as a paragraph.
List<String> ttcFlagLines(String body) {
  body = body.split('\n\n').first;
  final abbrev = RegExp(
      r'(?:\b(?:Dr|Mr|Mrs|Ms|St|vs|approx|No|e\.g|i\.e|etc)\.)$',
      caseSensitive: false);
  final out = <String>[];
  for (final para in body.split('\n')) {
    final t = para.trim();
    if (t.isEmpty) continue;
    var from = 0;
    for (final m in RegExp(r'[.!?\u0964]["\u201D\u2019)]*\s+')
        .allMatches(t)) {
      final piece = t.substring(from, m.end).trim();
      final rest = t.substring(m.end);
      if (abbrev.hasMatch(piece) || RegExp(r'^[a-z0-9]').hasMatch(rest)) {
        continue;
      }
      out.add(piece);
      from = m.end;
    }
    if (from < t.length) out.add(t.substring(from).trim());
  }
  return out;
}

/// The advice after a callout's signs: every block after the first blank
/// line, each one a paragraph. Empty when the callout is signs only.
List<String> ttcFlagProse(String body) => body
    .split('\n\n')
    .skip(1)
    .map((b) => b.replaceAll('\n', ' ').trim())
    .where((b) => b.isNotEmpty)
    .toList();

/// The IVF & IUI door's bracket, the only door whose order follows age.
const String kTtcIvfBracketId = 'ttc_infertility';

/// The "Age and second baby" tab on that door.
const String kTtcAgeGroupId = 'age';

/// [groups] in the order she should see them. Returns [groups] itself when
/// nothing moves, so every other door costs nothing.
///
/// [roundRunning] (2026-09-26, B7): while a treatment round is planned or
/// running, the IVF door leads with [kTtcIvfRoundTabsFirst] ("Going through
/// it", then "Track"), and the age move waits until the round closes. Order
/// only: every tab stays.
List<TtcFocusGroup> ttcDoorOrderedGroups(
  List<TtcFocusGroup> groups, {
  required String bracketId,
  required FertilityAgeBand? ageBand,
  bool roundRunning = false,
}) {
  if (bracketId != kTtcIvfBracketId) return groups;
  if (roundRunning) {
    final lead = [
      for (final id in kTtcIvfRoundTabsFirst)
        ...groups.where((g) => g.id == id),
    ];
    if (lead.isEmpty) return groups;
    return [...lead, ...groups.where((g) => !lead.contains(g))];
  }
  if (!(ageBand?.refersAtPresentation ?? false)) return groups;
  final at = groups.indexWhere((g) => g.id == kTtcAgeGroupId);
  if (at <= 1) return groups;
  return [...groups]
    ..removeAt(at)
    ..insert(1, groups[at]);
}

// =============================================================================
//  The screen
// =============================================================================

class TtcDoorScreen extends StatefulWidget {
  const TtcDoorScreen({
    super.key,
    required this.page,
    required this.bracket,
    this.initialGroup,
    this.dial = ttcDialNumber,
  });

  /// How the flag sheet's call button dials. A test swaps it (D15).
  final TtcDial dial;

  final TtcFocusPage page;

  /// ⚠️ THE WHOLE BRACKET. The eyebrow is `bracket.label`, the exact words on
  /// the tile she tapped, so the tile and the door cannot drift apart.
  final Bracket bracket;

  /// The tab to open on, by group id. Null opens the first. The selector
  /// does not remember: the first tab is where a newcomer should land.
  final String? initialGroup;

  @override
  State<TtcDoorScreen> createState() => _TtcDoorScreenState();
}

class _TtcDoorScreenState extends State<TtcDoorScreen> {
  final PvLiveSearch _search = PvLiveSearch();
  final GlobalKey _selectorAnchor = GlobalKey();

  /// The list's scroll, for the hero's parallax and its words' fade
  /// (2026-09-27). A notifier, so a scroll repaints the hero only, never the
  /// whole door.
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<double> _offset = ValueNotifier(0);

  void _onScroll() {
    final o = _scroll.offset;
    if (o != _offset.value) _offset.value = o;
  }

  /// The search index, built once per language and per switch position.
  List<TtcDoorHit>? _index;
  AppLanguage? _indexLang;
  bool? _indexHides;

  /// The open tab, BY ID. ⚠️ NOT AN INDEX, since the shared-phone switch: a
  /// tab can leave the rail while the door is open, and an index would then
  /// point at the tab that slid into its place. Null or unknown opens the
  /// first tab.
  late String? _groupId = widget.initialGroup;

  /// The page as she has chosen to see it, rebuilt only when the switch moves.
  TtcFocusPage? _visible;
  bool? _visibleHides;

  TtcFocusPage get page {
    final hide = TtcContentPrefs.instance.hideIntimate;
    if (_visible == null || _visibleHides != hide) {
      _visible = ttcDoorVisiblePage(widget.page, hideIntimate: hide);
      _visibleHides = hide;
    }
    return _visible!;
  }

  Bracket get bracket => widget.bracket;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    TtcSearchStore.instance.init();
    // Idempotent; main.dart has usually loaded it already.
    TtcContentPrefs.instance.init();
    // Her age band, for the IVF door's tab order. Idempotent; a failed read
    // is the default order.
    TtcFertilityHelpStore.instance.load().catchError((_) {});
    // Opened straight onto Sex and closeness: the one-time shared-phone
    // offer (2026-09-27, ttc_intimate_offer.dart). Additive.
    if (widget.initialGroup == kTtcIntimateGroupId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ttcMaybeOfferIntimateSwitch(context);
      });
    }
  }

  @override
  void didUpdateWidget(covariant TtcDoorScreen old) {
    super.didUpdateWidget(old);
    if (old.page != widget.page) {
      _visible = null;
      _index = null;
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _offset.dispose();
    _search.dispose();
    super.dispose();
  }

  /// The pinned flag's full list, in a sheet. The same `TtcDoorRedFlag`
  /// block the tab used to draw inline, so the words are the read's own.
  ///
  /// ⚠️ AND SOMETHING TO PRESS (launch sanity D15, 2026-09-28). "Go to a
  /// hospital today, not tomorrow" listed the signs and gave her nothing to
  /// do about them. A flag only opens a tab when the topic can be a real
  /// emergency ([kTtcDoorFlagTabs]), so every flag sheet ends on one ink
  /// button that dials the emergency number, through the same dialler as
  /// the Get help page (`ttcDialNumber`), with the number from the one
  /// constant that holds it. Kept for revert: the block alone.
  void _openFlag(String rid, PvCallout callout, AppLanguage lang, V2Palette p) {
    final hue = bracket.hue;
    showTtcDoorFlagSheet(
      context,
      p: p,
      body: (sheet) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TtcDoorRedFlag(
            callout: callout,
            lang: lang,
            p: p,
            onOpen: () {
              Navigator.of(sheet).pop();
              openTtcArticle(context, rid, hue: hue);
            },
          ),
          const SizedBox(height: 16),
          // 108 beside 112 (2026-09-28): every flag sheet is a medical
          // emergency (kTtcDoorFlagTabs), so the ambulance number is
          // offered under the emergency one. Kept for revert:
          // TtcDoorCallButton(p: p, number: kEmergencyNumber, dial: widget.dial),
          TtcDoorCallButton(
              p: p,
              number: kEmergencyNumber,
              ambulance: kAmbulanceNumber,
              dial: widget.dial),
        ],
      ),
    );
  }

  AppLanguage get _lang =>
      TtcLang.instance.hinglish ? AppLanguage.hinglish : AppLanguage.english;

  List<TtcDoorHit> _indexFor(AppLanguage lang) {
    final hide = TtcContentPrefs.instance.hideIntimate;
    if (_index == null || _indexLang != lang || _indexHides != hide) {
      _index = ttcDoorSearchIndex(page, bracket, lang, hideIntimate: hide);
      _indexLang = lang;
      _indexHides = hide;
    }
    return _index!;
  }

  List<TtcFocusSection> _sectionsOf(String groupId) => [
    for (final s in page.sections)
      if (s.group == groupId) s,
  ];

  /// The second line on a tab's card. Counted, never typed; a tool tab
  /// names itself (`inlineLabel`) rather than counting.
  String _countFor(TtcFocusGroup g) {
    if (g.inlineLabel case final label?) return label;
    final n = _sectionsOf(g.id).fold(0, (t, s) => t + s.tiles.length);
    if (n == 0) {
      // Kept for revert (2026-09-28, explicit names): 'Try it'.
      return (g.inlineSurfaceId ?? g.toolSurfaceId) != null ? 'A tool' : '';
    }
    return n == 1 ? '1 thing' : '$n things';
  }

  void _openTile(TtcTile tile) {
    pvCommitFeedback();
    openTtcFocusTile(context, tile, bracket.hue);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        TtcLang.instance,
        V2PaletteStore.instance,
        TtcSearchStore.instance,
        // The shared-phone switch, so turning it on in You updates a door
        // that is already open underneath.
        TtcContentPrefs.instance,
        // Her age band, so answering it in a read or the tool reorders an
        // IVF door that is already open underneath.
        TtcFertilityHelpStore.instance,
        // The round, so "Starting treatment?" leaves the IVF door the moment
        // a round is saved (2026-09-26), and the panel and tab order follow
        // it (B7).
        TtcTreatmentStore.instance,
        _search,
      ]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final hue = bracket.hue;
        final tint = v2BlockTint(hue % 360, p);
        final lang = _lang;
        final page = this.page;
        // Kept for revert: final groups = page.groups ?? const <TtcFocusGroup>[];
        final groups = ttcDoorOrderedGroups(
          page.groups ?? const <TtcFocusGroup>[],
          bracketId: page.bracketId,
          ageBand: TtcFertilityHelpStore.instance.ageBand,
          roundRunning: page.bracketId == kTtcIvfBracketId &&
              ttcIvfRoundLeads(),
        );
        final selected = groups.indexWhere((g) => g.id == _groupId);
        final groupIndex = selected < 0 ? 0 : selected;
        final group = groups.isEmpty ? null : groups[groupIndex];
        // A page with no tabs shows every section at once.
        final sections = group == null ? page.sections : _sectionsOf(group.id);

        return PvLiveSearchScope(
          search: _search,
          child: Scaffold(
            backgroundColor: p.ground,
            body: Stack(
              children: [
                Positioned.fill(
                  child: V3HeroField(
                    accent: tint,
                    ground: p.ground,
                    variant: 1,
                    chroma: v3FieldChroma(hue),
                  ),
                ),
                ListView(
                  // The hero's parallax reads this (2026-09-27).
                  controller: _scroll,
                  // The sheet owns the bottom clearance, not the list.
                  padding: EdgeInsets.zero,
                  children: [
                    // ⚠️ THE HERO FOR FLAT ART (2026-09-29, build 20): the
                    // picture whole in a 3:2 frame, the words and the white
                    // search pill below it in ink on the art's own ground,
                    // no scrim, no parallax (ttc_door_hero.dart). Kept for
                    // revert, the photograph hero:
                    //   _Hero(key: kTtcDoorHeroKey, scroll: _offset,
                    //     page: page, p: p, tint: tint,
                    //     eyebrow: bracket.label.of(lang), bracket: bracket,
                    //     search: _search, hasRail: groups.isNotEmpty,
                    //     onSubmitted: <the same callback>),
                    // ⚠️ BACK TO THE PHOTOGRAPH HERO (2026-09-29, the user on
                    // build 21: the stacked art-then-words hero was "a very
                    // bad change"; Flo's door, the words and search ON the
                    // picture with the cards riding up over its foot, is the
                    // shape to keep). Kept for revert, the flat-art hero:
                    //   TtcDoorHero(key: kTtcDoorHeroKey,
                    //     fieldKey: kTtcDoorSearchKey, page: page, p: p,
                    //     tint: tint, eyebrow: ..., bracket: bracket,
                    //     search: _search, onSubmitted: <the same callback>),
                    _Hero(
                      key: kTtcDoorHeroKey,
                      scroll: _offset,
                      page: page,
                      p: p,
                      tint: tint,
                      eyebrow: bracket.label.of(lang),
                      bracket: bracket,
                      search: _search,
                      hasRail: groups.isNotEmpty,
                      onSubmitted: (q) {
                        final hits = ttcDoorSearch(q, _indexFor(lang));
                        if (hits.isNotEmpty) {
                          openTtcDoorHit(
                            context,
                            hits.first,
                            hue: hue,
                            query: q,
                          );
                        } else if (q.trim().isNotEmpty) {
                          // D3 (2026-09-26): no silent jump into Ask Veda on
                          // the keyboard's Search key. The rows stay, with
                          // "Ask Veda about ..." as a choice she makes.
                          // Kept for revert:
                          //   openTtcAskVeda(context, initialQuery: q.trim());
                          TtcSearchStore.instance.remember(q);
                        }
                      },
                    ),
                    PvDoorSheet(
                      p: p,
                      minHeight: pvLiveSearchSheetMin(context, _search),
                      children: [
                        if (_search.searching)
                          ..._liveResults(p, lang)
                        else if (_search.recalling &&
                            TtcSearchStore.instance.recent.isNotEmpty)
                          ..._liveRecall(p)
                        else ...[
                          SizedBox(key: _selectorAnchor, height: 0),

                          // ---- the rail, on the sheet, in its own space ---
                          // ⚠️ NO LONGER ACROSS THE SEAM (2026-09-29, build
                          // 20: the search "feels like a fit-to-fill" against
                          // the cards). The rail sits [kTtcDoorRailTopGap]
                          // under the sheet's edge, the same gap the search
                          // keeps above it. Kept for revert, the straddle:
                          //   SizedBox(
                          //     height: TtcDoorRail.cardHeight -
                          //         TtcDoorRail.overlap,
                          //     child: OverflowBox(
                          //       alignment: Alignment.bottomCenter,
                          //       minHeight: TtcDoorRail.cardHeight,
                          //       maxHeight: TtcDoorRail.cardHeight,
                          //       child: TtcDoorRail(...the same...)))
                          // The straddle is back with the photograph hero
                          // (2026-09-29): the rail rides up over the hero's
                          // foot, as on Flo. Kept for revert, the gap:
                          //   const SizedBox(height: kTtcDoorRailTopGap),
                          if (groups.isNotEmpty) ...[
                            SizedBox(
                              height: TtcDoorRail.cardHeight -
                                  TtcDoorRail.overlap,
                              child: OverflowBox(
                                alignment: Alignment.bottomCenter,
                                minHeight: TtcDoorRail.cardHeight,
                                maxHeight: TtcDoorRail.cardHeight,
                                child: TtcDoorRail(
                                  groups: groups,
                                  counts: [
                                    for (final g in groups) _countFor(g),
                                  ],
                                  selected: groupIndex,
                                  p: p,
                                  onPick: (i) {
                                    setState(() => _groupId = groups[i].id);
                                    // The one-time shared-phone offer
                                    // (2026-09-27, ttc_intimate_offer.dart).
                                    if (groups[i].id == kTtcIntimateGroupId) {
                                      ttcMaybeOfferIntimateSwitch(context);
                                    }
                                  },
                                ),
                              ),
                            ),
                            // Kept for revert (2026-09-27): 4, then 18.
                          ],
                          const SizedBox(height: _kTtcDoorBlockGap),

                          // ---- "Starting treatment?" (2026-09-26, §2b) ------
                          // The IVF & IUI door only, while no round is saved:
                          // the obvious way into the round's start flow. The
                          // surface it opens is the door's own data
                          // (`kTtcIvfTopCardSurface`). Additive: every tab and
                          // section below is unchanged.
                          //
                          // B7 (2026-09-26): the card is one of four panels
                          // (`TtcIvfRoundPanel`), always there on this door.
                          // Kept for revert:
                          //   if (page.bracketId == kTtcIvfBracketId &&
                          //       TtcTreatmentStore.instance.cycle.isEmpty) ...[
                          //     pvDoorPad(TtcStartTreatmentCard(
                          //       onTap: () => openTtcSurface(
                          //           context, kTtcIvfTopCardSurface),
                          //     )),
                          //     const SizedBox(height: 22),
                          //   ],
                          // D10 (2026-09-28): on the tabs about a round only.
                          // Kept for revert: the bracket test alone.
                          if (page.bracketId == kTtcIvfBracketId &&
                              ttcIvfPanelShowsOn(group?.id)) ...[
                            pvDoorPad(TtcIvfRoundPanel(
                              onStart: () => openTtcSurface(
                                  context, kTtcIvfTopCardSurface),
                              onRead: (id) =>
                                  openTtcArticle(context, id, hue: hue),
                            )),
                            // Kept for revert (2026-09-27): 22.
                            const SizedBox(height: _kTtcDoorBlockGap),
                          ],

                          // ---- the pinned red flag, above everything ------
                          // The read's OWN callout, never retyped here: one
                          // copy of "go to a hospital today". Rendered whole,
                          // so the self-harm line travels with it.
                          //
                          // FOLDED 2026-09-27 (the user: "alerting is fine,
                          // it has to be done, but it's too much on the
                          // face"): still first in the tab, now one compact
                          // row with the read's own title; the whole list
                          // opens in a sheet, the same block, words whole.
                          // Two flags on one tab sit 8 apart, one group.
                          // Kept for revert, the inline block:
                          //   pvDoorPad(TtcDoorRedFlag(
                          //     key: ttcDoorFlagKey(rid),
                          //     callout: read.whenToSeeSomeone,
                          //     lang: lang, p: p,
                          //     onOpen: () =>
                          //         openTtcArticle(context, rid, hue: hue),
                          //   )),
                          //   const SizedBox(height: 22),
                          //
                          // ONLY WHERE IT CAN BE AN EMERGENCY (2026-09-28, the
                          // user's option B): `ttcDoorShowsFlag`, one tab
                          // today (After a loss › Your body), and there one
                          // compact line. Every other tab's list lives in its
                          // read's own "When to see someone". Kept for revert,
                          // the condition on every tab with a pinned read:
                          //   if (group != null &&
                          //       group.pinnedRedFlagReadIds
                          //           .any((r) => ttcReadById(r) != null)) ...[
                          if (group != null &&
                              ttcDoorShowsFlag(page.bracketId, group.id) &&
                              group.pinnedRedFlagReadIds
                                  .any((r) => ttcReadById(r) != null)) ...[
                            for (final rid in group.pinnedRedFlagReadIds)
                              if (ttcReadById(rid) case final read?)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: pvDoorPad(
                                    TtcDoorFlagRow(
                                      key: ttcDoorFlagKey(rid),
                                      // One short line (2026-09-28).
                                      compact: true,
                                      callout: read.whenToSeeSomeone,
                                      lang: lang,
                                      p: p,
                                      onOpen: () => _openFlag(
                                        rid,
                                        read.whenToSeeSomeone,
                                        lang,
                                        p,
                                      ),
                                    ),
                                  ),
                                ),
                            const SizedBox(height: _kTtcDoorBlockGap - 8),
                          ],

                          // ---- the tab's standing note --------------------
                          if (group?.note case final note?) ...[
                            pvDoorPad(_TabNote(note: note, p: p)),
                            // Kept for revert (2026-09-27): 20.
                            const SizedBox(height: _kTtcDoorBlockGap),
                          ],

                          // ---- the tool, in place, above the sections -----
                          // ⚠️ NOT PADDED HERE. The TTC tool bodies lay out
                          // their own gutter (the old screen handed them
                          // through untouched and `ttc_mind_body_test` holds
                          // where their cards start); a second pad would
                          // double the margin and clip their rails.
                          if (group != null)
                            if (group.inlineSurfaceId ?? group.toolSurfaceId
                                case final surface?)
                              if (ttcInlineToolFor(surface)
                                  case final tool?) ...[
                                tool,
                                // Kept for revert (2026-09-27): 28.
                                const SizedBox(height: _kTtcDoorBlockGap),
                              ],

                          // ---- this tab's sections ------------------------
                          // ONE FORMAT (2026-09-27): a heading in the one
                          // heading style, then a rail of the one card, cut
                          // off at the right edge so it reads as "more this
                          // way". Every section, every door.
                          for (final section in sections) ...[
                            pvDoorPad(
                              Text(
                                section.heading,
                                style: ttcDoorHeadingStyle(p),
                              ),
                            ),
                            // Kept for revert (2026-09-27): 13.
                            const SizedBox(height: _kTtcDoorHeadingGap),
                            // Kept for revert (2026-09-27), all written as
                            // rows into the reader:
                            //   if (ttcDoorSectionIsRows(section.tiles))
                            //     pvDoorPad(_ArticleList(
                            //       key: ttcDoorRowsKey(section.heading),
                            //       tiles: section.tiles, p: p, hue: hue,
                            //       onOpen: _openTile,
                            //     ))
                            //   else ...the rail below
                            // and the shared card the rail used to draw:
                            //   PvPress(child: PvDoorRailCard(
                            //     p: p, hue: hue, index: i,
                            //     icon: iconForFormat(t.format),
                            //     mark: ttcDoorFormatMark(t.format),
                            //     imageUrl: photoForTile(t),
                            //     chip: ttcDoorChip(t), title: t.title,
                            //     meta: ttcDoorTileMeta(t),
                            //     onTap: () => _openTile(t),
                            //   ))
                            //
                            // ⚠️ THREE SHAPES OF THE ONE CARD (launch sanity
                            // D3, D13, MB20, 2026-09-28), chosen by what the
                            // section holds, never by door:
                            //   · two or more pieces: the rail, as before,
                            //     with an unmade film last
                            //     (`ttcDoorRailTiles`);
                            //   · ONE piece: the same card at full width
                            //     (`TtcDoorWideCard`). A lone 150-wide card
                            //     beside empty space read as a load failure
                            //     ("Read your own report", "Get it read");
                            //   · a way to ANOTHER DOOR: a plain link row
                            //     under the rail, never a card whose type
                            //     says "Elsewhere". A signpost is not content.
                            // Kept for revert: the rail over `section.tiles`,
                            // every tile a card, whatever it was.
                            // ⚠️ ONE CARD FAMILY ON EVERY DOOR (2026-09-29, the user's
                            // reference picture): every piece is a `TtcKindCard`, one shape
                            // and one tint per kind (`ttc_kind_cards.dart`). Same order
                            // (`ttcDoorRailTiles`, an unmade film last), same taps. Three
                            // placements of the ONE card:
                            //   · two or more pieces: a rail of 240 cards (or the two-up
                            //     grid, `kTtcDoorCardsAsGrid`; the choice is argued in
                            //     DESIGN-SYSTEM §4.0f);
                            //   · ONE piece: the same card at the content width and the rail's
                            //     height, never a lone card beside empty space (D13);
                            //   · a way to another door: its link row below, as before (MB20).
                            // ⚠️ FLO'S SMALL BLOCKS (2026-09-29, the user on build
                            // 21): every shelf, one piece or many, is a row of
                            // [TtcFloCard]s at Flo's size. Kept for revert: the
                            // three branches below, behind kTtcDoorCardsFlo.
                            if (kTtcDoorCardsFlo &&
                                ttcDoorRailTiles(section.tiles)
                                    .any((t) => ttcCardKindOf(t) != null))
                              Builder(builder: (context) {
                                final tiles = [
                                  for (final t in ttcDoorRailTiles(section.tiles))
                                    if (ttcCardKindOf(t) != null) t,
                                ];
                                final h = ttcFloRailHeight(
                                  MediaQuery.textScalerOf(context),
                                );
                                return SizedBox(
                                  key: ttcDoorSectionRailKey(section.heading),
                                  height: h,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: kPvDoorGutter,
                                    ),
                                    itemCount: tiles.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(width: 10),
                                    itemBuilder: (context, i) => TtcFloCard(
                                      tile: tiles[i],
                                      kind: ttcCardKindOf(tiles[i])!,
                                      p: p,
                                      height: h,
                                      onTap: () => _openTile(tiles[i]),
                                    ),
                                  ),
                                );
                              })
                            else if (ttcDoorRailTiles(section.tiles)
                                case final tiles
                                when tiles.length == 1 &&
                                    ttcCardKindOf(tiles.single) != null)
                              pvDoorPad(
                                LayoutBuilder(
                                  key: ttcDoorSectionWideKey(section.heading),
                                  builder: (context, box) => TtcKindCard(
                                    tile: tiles.single,
                                    kind: ttcCardKindOf(tiles.single)!,
                                    p: p,
                                    width: box.maxWidth,
                                    imageHeight: kTtcDoorCardsAsGrid
                                        ? null
                                        : ttcKindCardImageHeight(),
                                    onTap: () => _openTile(tiles.single),
                                  ),
                                ),
                              )
                            else if (ttcDoorRailTiles(section.tiles)
                                case final tiles
                                when tiles.isNotEmpty && kTtcDoorCardsAsGrid)
                              pvDoorPad(
                                LayoutBuilder(
                                  key: ttcDoorSectionRailKey(section.heading),
                                  builder: (context, box) {
                                    final w = (box.maxWidth - kPvRailGap) / 2;
                                    return Wrap(
                                      spacing: kPvRailGap,
                                      runSpacing: kPvRailGap,
                                      children: [
                                        for (final t in tiles)
                                          if (ttcCardKindOf(t) case final kind?)
                                            TtcKindCard(
                                              tile: t,
                                              kind: kind,
                                              p: p,
                                              width: w,
                                              onTap: () => _openTile(t),
                                            ),
                                      ],
                                    );
                                  },
                                ),
                              )
                            else if (ttcDoorRailTiles(section.tiles)
                                case final tiles when tiles.isNotEmpty)
                              SizedBox(
                                key: ttcDoorSectionRailKey(section.heading),
                                // One height for every card, grown with the text size.
                                height: ttcKindCardHeight(MediaQuery.textScalerOf(context)),
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: kPvDoorGutter,
                                  ),
                                  itemCount: tiles.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(width: kPvRailGap),
                                  itemBuilder: (context, i) {
                                    final t = tiles[i];
                                    if (ttcCardKindOf(t) case final kind?) {
                                      return TtcKindCard(
                                        tile: t,
                                        kind: kind,
                                        p: p,
                                        onTap: () => _openTile(t),
                                      );
                                    }
                                    // Never reached: every rail piece has a kind (a door
                                    // tile is a link row). The old card, not a hole.
                                    return Align(
                                      alignment: Alignment.topCenter,
                                      child: TtcDoorSectionCard(
                                        p: p,
                                        hue: hue,
                                        mark: ttcDoorTileMark(t),
                                        kind: ttcDoorChip(t),
                                        title: t.title,
                                        meta: ttcDoorTileMeta(t),
                                        imageUrl: photoForTile(t),
                                        onTap: () => _openTile(t),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            // Kept for revert (2026-09-29), the three shapes before the one
                            // card family (the wide card, the kind rail on the Fertile window
                            // door alone, and the photo card rail on the other eight):
                            // if (ttcDoorRailTiles(section.tiles)
                            //     case final tiles when tiles.length == 1)
                            //   pvDoorPad(
                            //     TtcDoorWideCard(
                            //       key: ttcDoorSectionWideKey(section.heading),
                            //       p: p,
                            //       hue: hue,
                            //       mark: ttcDoorTileMark(tiles.single),
                            //       icon: ttcTileIsUnmadeFilm(tiles.single)
                            //           ? Icons.schedule_rounded
                            //           : null,
                            //       kind: ttcDoorChip(tiles.single),
                            //       title: tiles.single.title,
                            //       blurb: tiles.single.blurb,
                            //       meta: ttcDoorTileMeta(tiles.single),
                            //       imageUrl: photoForTile(tiles.single),
                            //       onTap: () => _openTile(tiles.single),
                            //     ),
                            //   )
                            // // ⚠️ ONE LOOK PER KIND (2026-09-28), on the doors
                            // // in `kTtcDoorsWithKindCards` only (the Fertile
                            // // window door first, for the user to judge): a
                            // // film is a 16:9 thumbnail, a story is tall with
                            // // ticks, a tool is an icon and a verb, and so on
                            // // (`ttc_kind_cards.dart`). Same rail, same order,
                            // // same taps; every other door draws as before.
                            // else if (ttcDoorRailTiles(section.tiles)
                            //     case final tiles
                            //     when tiles.isNotEmpty &&
                            //         ttcDoorDrawsKinds(page.bracketId))
                            //   SizedBox(
                            //     key: ttcDoorSectionRailKey(section.heading),
                            //     height: kTtcKindRailHeight,
                            //     child: ListView.separated(
                            //       scrollDirection: Axis.horizontal,
                            //       padding: const EdgeInsets.symmetric(
                            //         horizontal: kPvDoorGutter,
                            //       ),
                            //       itemCount: tiles.length,
                            //       separatorBuilder: (_, _) =>
                            //           const SizedBox(width: kPvRailGap),
                            //       itemBuilder: (context, i) {
                            //         final t = tiles[i];
                            //         if (ttcCardKindOf(t) case final kind?) {
                            //           return TtcKindCard(
                            //             tile: t,
                            //             kind: kind,
                            //             p: p,
                            //             hue: hue,
                            //             onTap: () => _openTile(t),
                            //           );
                            //         }
                            //         // A kind with no look of its own yet
                            //         // (a course, a recipe): the one card.
                            //         return Align(
                            //           alignment: Alignment.topCenter,
                            //           child: TtcDoorSectionCard(
                            //             p: p,
                            //             hue: hue,
                            //             mark: ttcDoorTileMark(t),
                            //             kind: ttcDoorChip(t),
                            //             title: t.title,
                            //             meta: ttcDoorTileMeta(t),
                            //             imageUrl: photoForTile(t),
                            //             onTap: () => _openTile(t),
                            //           ),
                            //         );
                            //       },
                            //     ),
                            //   )
                            // else if (ttcDoorRailTiles(section.tiles)
                            //     case final tiles when tiles.isNotEmpty)
                            //   SizedBox(
                            //     key: ttcDoorSectionRailKey(section.heading),
                            //     height: kTtcDoorCardHeight,
                            //     child: ListView.separated(
                            //       scrollDirection: Axis.horizontal,
                            //       padding: const EdgeInsets.symmetric(
                            //         horizontal: kPvDoorGutter,
                            //       ),
                            //       itemCount: tiles.length,
                            //       separatorBuilder: (_, _) =>
                            //           const SizedBox(width: kPvRailGap),
                            //       itemBuilder: (context, i) {
                            //         final t = tiles[i];
                            //         return TtcDoorSectionCard(
                            //           p: p,
                            //           hue: hue,
                            //           mark: ttcDoorTileMark(t),
                            //           // D3: an unmade film wears a clock,
                            //           // never a play glyph.
                            //           icon: ttcTileIsUnmadeFilm(t)
                            //               ? Icons.schedule_rounded
                            //               : null,
                            //           kind: ttcDoorChip(t),
                            //           title: t.title,
                            //           meta: ttcDoorTileMeta(t),
                            //           imageUrl: photoForTile(t),
                            //           onTap: () => _openTile(t),
                            //         );
                            //       },
                            //     ),
                            //   ),
                            for (final t
                                in section.tiles.whereType<TtcDoorTile>())
                              pvDoorPad(
                                TtcDoorLinkRow(
                                  key: ttcDoorLinkKey(t.bracketId),
                                  p: p,
                                  door: bracketById(t.bracketId)
                                          ?.label
                                          .of(lang) ??
                                      t.title,
                                  line: t.blurb,
                                  onTap: () => _openTile(t),
                                ),
                              ),
                            // Kept for revert (2026-09-27): 26.
                            const SizedBox(height: _kTtcDoorBlockGap),
                          ],

                          // ---- "Need to talk to someone now?" (2026-09-28) --
                          // At the END of the tabs `kTtcDoorGetHelpTabs`
                          // names, after the content: the calm way to the one
                          // "Get help now" page. See the constant for why
                          // these tabs and why the end.
                          if (group != null &&
                              ttcDoorEndsOnGetHelp(
                                  page.bracketId, group.id)) ...[
                            pvDoorPad(
                              TtcGetHelpRow(
                                p: p,
                                onTap: () => openTtcGetHelp(context),
                              ),
                            ),
                            const SizedBox(height: _kTtcDoorBlockGap),
                          ],

                          // ---- the closing line, unless the tab says it ---
                          // MB9 (2026-09-28): nor when the hero's blurb
                          // already says it. Kept for revert: the note test
                          // alone.
                          if (page.closingLine case final line?
                              when line != group?.note &&
                                  !(page.heroBlurb ?? '').contains(line)) ...[
                            pvDoorPad(
                              Text(
                                line,
                                style: pvFraunces(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                  color: p.ink2,
                                ),
                              ),
                            ),
                            // Kept for revert (2026-09-27): 22.
                            const SizedBox(height: _kTtcDoorBlockGap),
                          ],

                          // D1: not medical advice, and the estimates line
                          // only where a door estimates. Kept for revert:
                          //   text: TtcS.current().estimatesDisclaimer,
                          pvDoorPad(
                            PvDoorDisclaimer(
                              p: p,
                              // D5 (2026-09-28): per tab. Kept for revert:
                              //   ttcDoorDisclaimerFor(page.bracketId),
                              text: ttcDoorDisclaimerFor(
                                page.bracketId,
                                group?.id,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                // ---- the pinned bar, once the hero has gone (D2, MB19) ----
                TtcDoorPinnedBar(
                  key: kTtcDoorPinnedBarKey,
                  scroll: _offset,
                  search: _search,
                  p: p,
                  title: bracket.label.of(lang),
                  onSearch: () => _search.focus.requestFocus(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---- the live field's two states ----------------------------------------

  /// Rows for what she has typed, then the way on: Ask Veda, with her words.
  List<Widget> _liveResults(V2Palette p, AppLanguage lang) {
    final q = _search.query;
    final hits = ttcDoorSearch(q, _indexFor(lang));
    final label = bracket.label.of(lang);
    return [
      const SizedBox(height: 22),
      pvDoorPad(
        Text(
          // Names what was searched and where (2026-09-28, explicit names).
          // Kept for revert: 'Nothing here by that name yet'.
          hits.isEmpty
              ? 'Nothing in $label matches "$q" yet'
              : 'In $label and the library',
          // The one heading style (2026-09-27). Kept for revert: pvFraunces
          // 22, w600, height 1.15.
          style: ttcDoorHeadingStyle(p),
        ),
      ),
      // ⚠️ NO RESULT IS NOT A BLANK PAGE (launch sanity D6, 2026-09-28). It
      // used to be the heading and one Ask Veda row. Now it says what was
      // searched (this door and every read in the stage, their words too)
      // and offers a few words that do find things, as chips that run the
      // search: the no-results shape of Headspace's and Calm's search, a
      // line and suggestions rather than an empty list.
      if (hits.isEmpty) ...[
        pvDoorPad(
          Text(
            key: kTtcDoorSearchEmptyKey,
            // Kept for revert (2026-09-28, explicit names): '... or one of '
            // 'these:',
            'We looked through $label and every read in Trying to conceive, '
            'words and all. Try a shorter word, a medicine name, or a topic '
            'below:',
            style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2),
          ),
        ),
        const SizedBox(height: 12),
        pvDoorPad(
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final w in kTtcDoorSearchSuggestions)
                PvChip(
                  label: w,
                  selected: false,
                  onTap: () {
                    pvCommitFeedback();
                    _search.run(w);
                  },
                ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 6),
      for (var i = 0; i < hits.length && i < 30; i++)
        TtcDoorHitRow(
          key: ttcDoorSearchHitKey(i),
          p: p,
          hit: hits[i],
          onTap: () {
            _search.focus.unfocus();
            openTtcDoorHit(context, hits[i], hue: bracket.hue, query: q);
          },
        ),
      const SizedBox(height: 14),
      pvDoorPad(
        PvLiveSearchWayOn(
          p: p,
          icon: Icons.auto_awesome_outlined,
          title: 'Ask Veda about "$q"',
          line: 'Ask in your own words and get a calm answer.',
          onTap: () {
            pvCommitFeedback();
            TtcSearchStore.instance.remember(q);
            _search.focus.unfocus();
            openTtcAskVeda(context, initialQuery: q);
          },
        ),
      ),
      const SizedBox(height: 8),
    ];
  }

  /// Her recent searches, as rows that put the words back in the field.
  List<Widget> _liveRecall(V2Palette p) {
    final recent = TtcSearchStore.instance.recent;
    return [
      const SizedBox(height: 22),
      pvLiveSearchRecallHeading(
        p,
        'Recent',
        onClear: TtcSearchStore.instance.clear,
      ),
      const SizedBox(height: 6),
      for (final r in recent)
        PvPress(
          child: InkWell(
            onTap: () {
              pvCommitFeedback();
              _search.run(r);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, size: 20, color: p.ink2),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      r,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: p.ink1,
                      ),
                    ),
                  ),
                  Icon(Icons.north_west_rounded, size: 16, color: p.ink3),
                ],
              ),
            ),
          ),
        ),
      const SizedBox(height: 8),
    ];
  }
}

// =============================================================================
//  The hero
// =============================================================================

/// The hero, fixed height, parallax, glass field (2026-09-27). See the file
/// header, change 1 and 2.
///
/// The layout is a Stack whose SIZE comes from a `SizedBox` of
/// [kTtcDoorHeroHeight] and the words column together (whichever is taller),
/// with the words pinned to the bottom. Every door's words fit inside the
/// fixed height once the headline is two lines and the blurb three, so every
/// door is the same height; only an accessibility text size taller than that
/// grows the hero, which is better than clipping her words.
///
/// ⚠️ SUPERSEDED 2026-09-29 by `TtcDoorHero` (ttc_door_hero.dart): the
/// photograph under a scrim, cover-cropped and parallaxed, with white type
/// and the glass field on it. Kept for revert.
// ignore: unused_element
class _Hero extends StatelessWidget {
  const _Hero({
    // ignore: unused_element_parameter
    super.key,
    required this.scroll,
    required this.page,
    required this.p,
    required this.tint,
    required this.eyebrow,
    required this.bracket,
    required this.search,
    required this.hasRail,
    required this.onSubmitted,
  });

  /// The list's offset: the photo climbs at [_kRate] of it, and the words
  /// fade over the first [_kFade] points, so the sheet is never over type.
  final ValueListenable<double> scroll;
  final TtcFocusPage page;
  final V2Palette p;
  final Color tint;
  final String eyebrow;
  final Bracket bracket;
  final PvLiveSearch search;
  final bool hasRail;
  final ValueChanged<String> onSubmitted;

  /// Under half the scroll speed, so the picture reads as behind the page.
  /// The doctor app's hero uses 0.5; a little less here, because the rail
  /// straddles the seam and a fast photo behind it shimmered.
  static const double _kRate = 0.45;
  static const double _kFade = 200;

  /// Room above the words for the back button (8 + 38 + 12).
  static const double _kTopRoom = 58;

  double get _bleed =>
      hasRail ? kTtcDoorHeroOverlap + TtcDoorRail.overlap : kTtcDoorHeroOverlap;

  @override
  Widget build(BuildContext context) {
    final mark = bracketMarkFor(bracket.id);
    final photo = page.heroImageUrl;
    final title = page.heroTitle ?? eyebrow;
    final blurb = page.heroBlurb ?? page.intro;
    final top = MediaQuery.paddingOf(context).top;
    // A soft shadow under white type: insurance for a bright photograph now
    // that the scrim is lighter.
    const shadow = [Shadow(color: Color(0x59000000), blurRadius: 12)];

    final words = PvLiveSearchWords(
      search: search,
      child: ValueListenableBuilder<double>(
        valueListenable: scroll,
        builder: (context, o, child) => Opacity(
          opacity: (1 - o / _kFade).clamp(0.0, 1.0),
          child: child,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              eyebrow.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: photo == null
                    ? p.ink2
                    : Colors.white.withValues(alpha: 0.86),
              ).copyWith(shadows: photo == null ? null : shadow),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: pvFraunces(
                  fontSize: photo == null ? 27 : 29,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                  letterSpacing: -0.6,
                  color: photo == null ? p.ink1 : Colors.white,
                ).copyWith(shadows: photo == null ? null : shadow),
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 330),
              child: Text(
                blurb,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                  fontSize: 13.5,
                  height: 1.5,
                  color: photo == null
                      ? p.ink2
                      : Colors.white.withValues(alpha: 0.94),
                ).copyWith(shadows: photo == null ? null : shadow),
              ),
            ),
          ],
        ),
      ),
    );

    // Search, in the door: Flo's topic page. Live, so rows draw in the sheet
    // as she types. Glass on a photograph; the shared solid field where
    // there is none, because white type would not read on the pale field.
    // Kept for revert: PvLiveSearchField(key: kTtcDoorSearchKey, ...) always.
    final Widget field = photo == null
        ? PvLiveSearchField(
            key: kTtcDoorSearchKey,
            search: search,
            p: p,
            hint: 'Search $eyebrow',
            onSubmitted: onSubmitted,
          )
        : TtcDoorGlassSearchField(
            key: kTtcDoorSearchKey,
            search: search,
            hint: 'Search $eyebrow',
            onSubmitted: onSubmitted,
          );

    return Stack(
      // `Clip.none` lets the picture run on under the sheet and the rail.
      clipBehavior: Clip.none,
      children: [
        // ---- the photograph, parallaxed --------------------------------
        // Translated DOWN by a fraction of the scroll, so on screen it
        // climbs slower than the page. Its top edge stays above the screen
        // (it moves down by less than the page moved up), and what runs on
        // below is under the sheet, which paints over it.
        if (photo != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: -_bleed,
            child: ValueListenableBuilder<double>(
              valueListenable: scroll,
              builder: (context, o, child) => Transform.translate(
                // Clamped at 0 so an overscroll bounce cannot pull the photo
                // off the top of its frame.
                offset: Offset(0, (o * _kRate).clamp(0.0, double.infinity)),
                child: child,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Both builders return nothing, so offline the hero is the
                  // finished field, never a grey box.
                  Image.network(
                    photo,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    loadingBuilder: (context, child, progress) =>
                        progress == null ? child : const SizedBox.shrink(),
                  ),
                  // A dark scrim only; fading to the page colour reads as
                  // fog. LIGHTER since 2026-09-27 (the photo is the picture,
                  // not a dark band), with shadows under the type instead.
                  // Kept for revert: 0.52 / 0.30 / 0.34 at 0 / 0.62 / 1.
                  //
                  // ⚠️ AND DARKER UNDER THE WORDS (launch sanity D8,
                  // 2026-09-28): white body text sat on the brightest part of
                  // the PCOS poha bowl and the Getting ready soup pot. The
                  // scrim now rises through the headline to 0.72 under the
                  // blurb, and stays lighter at the top so the picture is
                  // still the picture. The arithmetic: a bright
                  // photo patch of relative luminance 0.6 under 72% black is
                  // 0.6 x 0.28 = 0.17, and white on 0.17 is (1.05 / 0.22) =
                  // 4.8:1, over the 4.5:1 body-text line (WCAG AA), before
                  // the type's own shadow. Kept for revert:
                  //   colors: 0.42 / 0.20 / 0.44, stops: 0 / 0.45 / 1.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.40),
                          Colors.black.withValues(alpha: 0.30),
                          Colors.black.withValues(alpha: 0.60),
                          Colors.black.withValues(alpha: 0.72),
                          Colors.black.withValues(alpha: 0.72),
                        ],
                        // The box runs on under the rail, so the words sit
                        // at about 0.23 (eyebrow) to 0.57 (blurb's end) of
                        // it: the headline on 0.45 to 0.6 (large text, 3:1),
                        // the blurb on 0.65 to 0.72 (body text, 4.5:1).
                        stops: const [0, 0.16, 0.36, 0.52, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (photo == null)
          Positioned(
            right: -26,
            top: 52,
            child: Opacity(
              opacity: 0.5,
              child: SizedBox(
                width: 146,
                height: 146,
                child: mark == null
                    ? const SizedBox.shrink()
                    : V3BracketArt(mark: mark, tint: tint),
              ),
            ),
          ),

        // ---- the size, and the words at the bottom of it -----------------
        Padding(
          padding: EdgeInsets.only(top: top),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              const SizedBox(
                height: kTtcDoorHeroHeight,
                width: double.infinity,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  _kTopRoom,
                  22,
                  20 + (hasRail ? TtcDoorRail.overlap - 12 : 0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    words,
                    const SizedBox(height: 16),
                    field,
                  ],
                ),
              ),
            ],
          ),
        ),

        // ---- back ----------------------------------------------------------
        Positioned(
          top: top + 8,
          left: 20,
          child: Material(
            color: Colors.white.withValues(alpha: 0.55),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: SizedBox(
                width: 38,
                height: 38,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 19,
                  color: p.ink1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The hero before 2026-09-27: its height followed the blurb's length (and a
/// tenth of the screen), a heavier scrim, a solid white field, no parallax.
/// Kept for revert.
// ignore: unused_element
class _HeroV1 extends StatelessWidget {
  const _HeroV1({
    required this.page,
    required this.p,
    required this.tint,
    required this.eyebrow,
    required this.bracket,
    required this.search,
    required this.hasRail,
    required this.onSubmitted,
  });

  final TtcFocusPage page;
  final V2Palette p;
  final Color tint;

  /// `bracket.label`: the exact words on the tile that opened this.
  final String eyebrow;
  final Bracket bracket;
  final PvLiveSearch search;
  final bool hasRail;
  final ValueChanged<String> onSubmitted;

  /// How far the picture runs under the sheet. The rail's cards float up over
  /// the seam, so the picture reaches up behind them too, or a band of the
  /// tinted field shows between photo and sheet.
  double get _bleed =>
      hasRail ? kTtcDoorHeroOverlap + TtcDoorRail.overlap : kTtcDoorHeroOverlap;

  @override
  Widget build(BuildContext context) {
    final mark = bracketMarkFor(bracket.id);
    final photo = page.heroImageUrl;
    final title = page.heroTitle ?? eyebrow;
    final blurb = page.heroBlurb ?? page.intro;

    // `Clip.none` is what lets the picture run past the hero's own box.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // The photograph is a layer OVER the field. Both builders return
        // nothing, so offline the hero is the finished field, never a grey box.
        if (photo != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: -_bleed,
            child: Image.network(
              photo,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const SizedBox.shrink(),
            ),
          ),
        // A dark scrim only; fading to the page colour reads as fog.
        if (photo != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: -_bleed,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.52),
                    Colors.black.withValues(alpha: 0.30),
                    Colors.black.withValues(alpha: 0.34),
                  ],
                  stops: const [0, 0.62, 1],
                ),
              ),
            ),
          ),
        if (photo == null)
          Positioned(
            right: -26,
            top: 52,
            child: Opacity(
              opacity: 0.5,
              child: SizedBox(
                width: 146,
                height: 146,
                child: mark == null
                    ? const SizedBox.shrink()
                    : V3BracketArt(mark: mark, tint: tint),
              ),
            ),
          ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              22,
              20 + (hasRail ? TtcDoorRail.overlap - 12 : 0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Material(
                      color: Colors.white.withValues(alpha: 0.55),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: SizedBox(
                          width: 38,
                          height: 38,
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 19,
                            color: p.ink1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // The only lever on the photograph's size: a taller column.
                // A fraction of the screen, so a small phone is not eaten.
                SizedBox(
                  height: photo == null
                      ? 20
                      : MediaQuery.sizeOf(context).height * 0.10,
                ),
                PvLiveSearchWords(
                  search: search,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        eyebrow.toUpperCase(),
                        style: pvManrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: photo == null
                              ? p.ink2
                              : Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Text(
                          title,
                          style: pvFraunces(
                            fontSize: photo == null ? 27 : 30,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                            letterSpacing: -0.6,
                            color: photo == null ? p.ink1 : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 330),
                        child: Text(
                          blurb,
                          style: pvManrope(
                            fontSize: 13.5,
                            height: 1.55,
                            color: photo == null
                                ? p.ink2
                                : Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Search, in the door: Flo's topic page. Live, so rows draw
                // in the sheet as she types.
                PvLiveSearchField(
                  key: kTtcDoorSearchKey,
                  search: search,
                  p: p,
                  hint: 'Search $eyebrow',
                  onSubmitted: onSubmitted,
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
//  The pinned red flag, in the new form
// -----------------------------------------------------------------------------
//  An ink rule, the heading in the display face, the read's words with one
//  coral dot, a way to the whole piece, a hairline. No box (DESIGN-SYSTEM §4.0
//  addendum: "a big blob thrown at the screen"). The dot is the only colour.
//
//  ⚠️ THE WORDS ARE THE READ'S OWN `whenToSeeSomeone`, WHOLE. Nothing here is
//  retyped or shortened: a clinical warning in two places disagrees with
//  itself the day one is edited, and the self-harm routing on After a loss
//  and Mind & body must never be trimmed out of an excerpt. A body with line
//  breaks becomes one dotted line per break; one paragraph stays one line.
// =============================================================================

class TtcDoorRedFlag extends StatelessWidget {
  const TtcDoorRedFlag({
    super.key,
    required this.callout,
    required this.lang,
    required this.p,
    this.onOpen,
  });

  final PvCallout callout;
  final AppLanguage lang;
  final V2Palette p;

  /// Opens the read the callout belongs to.
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    // D2 (2026-09-26): one line per sentence, the read's own words. Kept for
    // revert, the line-break split only:
    //   final lines = callout.body.of(lang).split('\n')
    //       .map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final lines = ttcFlagLines(callout.body.of(lang));
    final block = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1.5, color: p.ink1),
        const SizedBox(height: 14),
        Text(
          callout.title.of(lang),
          style: pvFraunces(
            fontSize: 21,
            fontWeight: FontWeight.w600,
            height: 1.2,
            letterSpacing: -0.3,
            color: p.ink1,
          ),
        ),
        const SizedBox(height: 10),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 11),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: kPvUrgentInk,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    line,
                    style: pvManrope(fontSize: 14, height: 1.5, color: p.ink1),
                  ),
                ),
              ],
            ),
          ),
        // The closing advice, as words rather than more signs (2026-09-27).
        for (final para in ttcFlagProse(callout.body.of(lang)))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              para,
              style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2),
            ),
          ),
        if (onOpen != null) ...[
          const SizedBox(height: 4),
          // D5: a 44pt row. The whole block opens the read too (below).
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Read the full piece',
                    style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: p.ink1,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 17, color: p.ink1),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Container(height: 1, color: p.line),
      ],
    );
    if (onOpen == null) return block;
    // D5: the whole flag is the tap target, as on the pregnancy doors.
    return Semantics(
      button: true,
      label: '${callout.title.of(lang)}. Read the full piece',
      child: PvPress(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            pvCommitFeedback();
            onOpen!();
          },
          child: block,
        ),
      ),
    );
  }
}

/// A tab's standing note: an icon and a grey line, on the page. No box.
class _TabNote extends StatelessWidget {
  const _TabNote({required this.note, required this.p});

  final String note;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(Icons.info_outline_rounded, size: 15, color: p.ink3),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            note,
            style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2),
          ),
        ),
      ],
    ),
  );
}

// =============================================================================
//  _ArticleList — a section of written tiles, as rows
// -----------------------------------------------------------------------------
//  A 56pt thumbnail (the read's photograph, else the format's drawn mark in a
//  well of the door's tint), the title bold, the blurb in one grey line, the
//  derived meta, a chevron, a hairline under. Presses and hums.
// =============================================================================

// Kept for revert (2026-09-27): no section draws as rows any more; see
// `ttcDoorSectionIsRows`.
// ignore: unused_element
class _ArticleList extends StatelessWidget {
  const _ArticleList({
    // ignore: unused_element_parameter
    super.key,
    required this.tiles,
    required this.p,
    required this.hue,
    required this.onOpen,
  });

  final List<TtcTile> tiles;
  final V2Palette p;
  final double hue;
  final void Function(TtcTile) onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final t in tiles)
          PvPress(
            child: InkWell(
              onTap: () => onOpen(t),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: p.line)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: switch (photoForTile(t)) {
                          final url? => Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _well(t),
                            loadingBuilder: (context, child, progress) =>
                                progress == null ? child : _well(t),
                          ),
                          _ => _well(t),
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              color: p.ink1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            t.blurb,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                              fontSize: 12.5,
                              height: 1.4,
                              color: p.ink2,
                            ),
                          ),
                          if (ttcDoorTileMeta(t) case final m?) ...[
                            const SizedBox(height: 3),
                            Text(
                              m,
                              style: pvManrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: p.ink3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _well(TtcTile t) {
    final tint = v2BlockTint(hue % 360, p);
    return Container(
      color: tint,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(11),
      child: HubIntentArt(mark: ttcDoorFormatMark(t.format), tint: tint),
    );
  }
}
