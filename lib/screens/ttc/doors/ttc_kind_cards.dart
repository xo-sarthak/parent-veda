// =============================================================================
//  TTC door cards, one card family, one tint per kind (2026-09-29, all nine)
// -----------------------------------------------------------------------------
//  The user, with a reference picture (a PCOS page of tinted cards): "a video
//  looks like a video, a product looks like a product with the product
//  image … every door seems a bit different in the way of representation."
//  The 2026-09-28 language below (one SHAPE per kind, on the Fertile window
//  door only) told the kinds apart, but by shape: nine widths, some cards a
//  photo, some a verb pill, some bubbles, so a rail read as nine designs. The
//  reference tells them apart by COLOUR and WORDS on ONE shape, and that is
//  what every door now draws ([TtcKindCard]):
//
//    ground   a soft tint per kind, never per door (`ttcCardKindGround`):
//             video rose, article blue, carousel lilac, product green, tool
//             amber, talk to an expert teal; myth peach, chat orchid,
//             practice sage, masterclass periwinkle, recipe butter,
//             community sky, infographic sea green.
//    pills    top left, the kind in words with a line icon ("Video",
//             "Talk to an expert"); top right, one fact when there is one:
//             "5 min read" (at 200 words or more, the reader's rule),
//             "7 slides", "Coming soon" for an unmade film, "Paid" with a
//             lock where an offering has a price, "About 3 min" for a
//             practice.
//    picture  the image well, 16px corners, inset 6 in the tint: the photo
//             for a video, article, product, myth, consult, course, recipe,
//             practice; a drawn object for a tool and a chat (the Tools
//             tab's own marks, `ttc_tool_marks.dart`), never a stock photo
//             of a tool; stacked slide previews for a carousel. A play button
//             ONLY on a film that exists; a live film also shows its length.
//    words    a serif title, two lines at most, one grey caption, two lines
//             at most, a chevron. Both boxes are reserved at two lines, so
//             every card on a door is one size whatever its words.
//
//  ⚠️ LAYOUT: A RAIL, NOT THE REFERENCE'S GRID (decided 2026-09-29, the
//  reasoning in `docs/DESIGN-SYSTEM.md` §4.0f). At 360dp a two-up grid card
//  is 158 wide: two lines of the serif title hold about 36 characters and a
//  quarter of the door titles (up to 52) would be cut, and "Talk to an
//  expert" plus "Paid" do not fit side by side on the picture. A 240 card on
//  the rail holds every title whole, keeps the reference's anatomy exactly,
//  and matches every other door rail in the app (pregnancy and parenting
//  doors, Flo, Clue, Hers). The grid is built and one constant away
//  ([kTtcDoorCardsAsGrid]). Mobbin:
//    * Hers, Nutrition: section heading, a rail of one card size, the kind
//      top left on the photo ("1 min" with a camera, "14 Slides" with a deck)
//      and a play button on the film
//      https://mobbin.com/screens/9dc1cc3a-3cd2-4e04-b724-e1ca2fe2e5f5
//    * Flo, Insights: a question heading, one card size per rail, "▶ Video
//      Course" as a pill on the picture
//      https://mobbin.com/screens/10d53da4-0522-4468-99d6-f98598845e80
//    * Clue, Content: sections of same-size cards, a play button only on
//      films https://mobbin.com/screens/17a36856-fefd-44fb-a897-c9786b56fcc5
//    * Headspace, Your Mind Matters: the two-up grid alternative, the kind
//      and minutes under the title
//      https://mobbin.com/screens/6a279b52-7e71-489c-ae0f-c0a5963af13d
//    * Tiimo, library: the two-up grid with a kind glyph on the picture
//      https://mobbin.com/screens/667fb312-0fc2-4e46-a548-884ee4a78d88
//
//  What stays from the 2026-09-28 language: sections are questions, never
//  kinds; an unmade film is last in its rail and never shows a play glyph;
//  the kind is said in words for screen readers; a photo keys on the tile's
//  stable id; no stock face is ever presented as our expert (the consult
//  pictures are objects: a stethoscope, a bench, a cup held in two hands).
//
//  The 2026-09-28 card is kept below as `TtcKindCardV1`, reachable from
//  nowhere, for revert.
// =============================================================================
//
// =============================================================================
//  TTC door cards, one look per kind (2026-09-28, the Fertile window door first)
// -----------------------------------------------------------------------------
//  The user: "we need to see how to differentiate articles and videos and
//  carousels and all that stuff inside doors ... so that users find it
//  intuitive to click." Until now every piece on a door was the same 150 x 176
//  photo card with a small chip, so a tool, a read and a story looked alike
//  and she learned what she had tapped only after the tap.
//
//  So each KIND gets its own SHAPE, and the shape is the promise:
//
//    video     16:9 thumbnail, a dark pill bottom left: play and the length,
//              or a clock and "Coming soon" when the film is not made (never
//              a play glyph on something that cannot play).
//    story     tall and narrow, full-bleed photo, story ticks along the top,
//              one per slide, and "Story · N slides".
//    article   photo on top, white below, the title, "Article · N min read"
//              (the minutes only at 200 words or more, the reader's rule).
//    myth      no photo: the door's tint, "Myth vs fact", the question, what
//              people say in quotes, and "See the fact".
//    tool      no photo: a line icon in a tinted tile, "Tool", the name, and
//              an ink pill with the verb ("See your best days").
//    chat      two speech bubbles (her question in ink, the answer's promise
//              in the tint) and an outlined "Start the chat".
//    consult   a person card with no stock face: a video-call object in a
//              circle, the kind of doctor, the price, "See times and book".
//    practice  a drawn mark, "Practice", the name, steps and minutes.
//    product   the photo inset in a well, as the store draws a product.
//
//  ⚠️ ONE ROW, MANY SHAPES, ONE GRAMMAR. Every card in a rail is the same
//  HEIGHT ([kTtcKindRailHeight]) and only the width changes with the kind, so
//  a mixed row still reads as one row (Netflix mixes tall posters and wide
//  episode cards across rows, never heights inside one; Flo's "My daily
//  insights" rail puts a "Log your symptoms" tile beside story cards at one
//  height). Every card is white with the page hairline and the 20 corner,
//  except the two that are deliberately flat colour (a story is its photo, a
//  myth is the door's tint), and every card says its kind IN WORDS, not only
//  as a shape, for screen readers and for anyone who does not read shapes.
//
//  ⚠️ SECTIONS STAY QUESTIONS, NOT KINDS. A section is "When should we have
//  sex?", never "Videos" (`TtcFocusSection`, its heading rule). The shape
//  tells her the kind; the heading keeps telling her what she wants to know.
//
//  Mobbin, what decided each shape:
//    * YouTube home: 16:9 thumbnail, the length in a dark pill on the image
//      https://mobbin.com/screens/7cdbe518-761a-4138-a232-85b33a2964a4
//    * Calm Discover: "▶ 36 min" bottom left on the thumbnail, the kind in
//      words under it ("Sleep Story")
//      https://mobbin.com/screens/0a90059d-1243-4eb0-a583-4b21135f86a9
//    * Flo stories: segment ticks across the top, one per slide
//      https://mobbin.com/screens/457173f7-3614-4ba9-a206-d444d73ddf2b
//    * Flo daily insights: tall story cards beside a "Log your symptoms"
//      action tile, one height
//      https://mobbin.com/screens/594db2bf-6139-4046-920e-fb3936c364ed
//    * Flo Insights: an article is its picture on top, the title and
//      "6 min read" under it
//      https://mobbin.com/screens/05fec5cd-4ac8-4fab-b374-04d47cc994ab
//    * Flo "▶ Video Course" chip, Flo partner "Video" chip: the kind in words
//      https://mobbin.com/screens/3fba06c7-b554-46cd-9487-ae5e74721a32
//      https://mobbin.com/screens/571ae270-e511-4b9e-bceb-244b15cb2381
//    * Headspace Today: the kind with its own icon and the minutes
//      ("Podcast · 26 min") https://mobbin.com/screens/005702a0-d4fb-466a-a591-36abe479f465
//    * Instagram profile grid: a corner glyph tells a reel from a post
//      https://mobbin.com/screens/6f95a774-9854-446b-a2ea-4e80609f4b3a
//    * Medium: "3 min read" in the foot of an article row
//      https://mobbin.com/screens/23a98136-07b1-4c18-a89b-677badb20fb9
//    * Nibble "Chat with the greatest", Ro "Start a conversation": a chat
//      is shown as bubbles with a way to start it
//      https://mobbin.com/screens/e878152e-bcfb-49c7-b15a-c6e898ee209e
//      https://mobbin.com/screens/678b13db-dc0e-42b5-9993-38f4d89b6b41
//    * Zocdoc "Providers nearby": a person card, a round portrait, the
//      specialty, one action (we draw an object where they show a face)
//      https://mobbin.com/screens/3b03d53a-6614-4054-a34a-0d8ba4213c8e
//    * Netflix rows: one shape per kind of thing
//      https://mobbin.com/screens/0ace80fe-8932-41d0-b86e-7ceec8b910da
// =============================================================================

import 'package:flutter/material.dart';

import '../../../ttc/ttc_focus_data.dart';
import '../../../ttc/ttc_prepare_data.dart' show ttcOfferingById;
import '../../../ttc/ttc_practice_data.dart' show TtcPracticeKind;
import '../../../ttc/ttc_reads_data.dart' show ttcReadById;
import '../../../ttc/ttc_videos_data.dart' show ttcVideoBySlot;
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../brackets/hub/hub_intent_art.dart';
import '../../v2/v2_palette.dart';
import '../ttc_focus_screen.dart' show photoForTile, ttcTilePhotoId;
import '../ttc_tool_marks.dart' show TtcToolArt, ttcToolMarkForSurface;
import 'ttc_tab_art.dart' show TtcTabArt, TtcTabMark;
import '../ttc_common.dart' show ttcTitleInk;
import '../../../ttc/ttc_prepare_data.dart' show TtcOffering;
import '../../../ttc/ttc_products_data.dart' show ttcProducts;
import '../../learn/pv_learn_catalog.dart' show PvLearnCatalog;
import 'ttc_card_art.dart';
import 'ttc_door_screen.dart'
    show
        ttcTileIsUnmadeFilm,
        ttcTilePractice,
        ttcDoorTileMark,
        kTtcFilmComingSoon;

/// The kinds a door card can be drawn as. Since 2026-09-29 every tile on a
/// door has one (a masterclass, a recipe, a community room and an
/// infographic joined), so the whole door is one card family. Only a way to
/// another door (`TtcDoorTile`) has none: it is a link row, not content.
enum TtcCardKind {
  video,
  story,
  read,
  myth,
  tool,
  chat,
  consult,
  practice,
  product,
  course,
  recipe,
  community,
  infographic,
}

// ⚠️ THE GATE IS GONE (2026-09-29): every door draws the card family. Kept for
// revert, the Fertile window door alone:
//   const Set<String> kTtcDoorsWithKindCards = {'ttc_conceiving'};
//   bool ttcDoorDrawsKinds(String bracketId) =>
//       kTtcDoorsWithKindCards.contains(bracketId);

/// Every card in a V1 kind rail was this tall; only the width changed.
/// `TtcKindCardV1` only (kept for revert).
const double kTtcKindRailHeight = 236;

/// ⚠️ ONE CONSTANT FOR THE LAYOUT DECISION (2026-09-29). False: each section
/// is a rail of [kTtcKindCardWidth] cards (the decision, see the header).
/// True: each section is a two-up grid under its heading, as the reference
/// picture draws it; the card is the same object at half the content width.
const bool kTtcDoorCardsAsGrid = false;

/// The card's width on a rail. About a card and a half shows at 360dp, so
/// the rail says "more this way" without a hint.
const double kTtcKindCardWidth = 240;

/// The gap between the tinted edge and the picture well.
const double _kInset = 6;
const double _kTitleSize = 15;
const double _kTitleLine = 1.2;
const double _kCaptionSize = 12.5;
const double _kCaptionLine = 1.35;

/// The picture well's height for a card [width] wide: a little wider than
/// 16:9, the reference's proportion. A single-piece section draws its wide
/// card with the rail's height, so one door has one card height.
double ttcKindCardImageHeight([double width = kTtcKindCardWidth]) =>
    ((width - 2 * _kInset) * 0.52).roundToDouble();

double _titleBox(TextScaler s) =>
    (s.scale(_kTitleSize) * _kTitleLine * 2).ceilToDouble() + 1;
double _captionBox(TextScaler s) =>
    (s.scale(_kCaptionSize) * _kCaptionLine * 2).ceilToDouble() + 1;

/// The card's height: the picture, then the title and caption boxes, both
/// reserved at two lines and grown with the text size, so no card on a door
/// is taller than another and none overflows at a large text size.
double ttcKindCardHeight(
  TextScaler s, {
  double width = kTtcKindCardWidth,
  double? imageHeight,
}) =>
    _kInset +
    (imageHeight ?? ttcKindCardImageHeight(width)) +
    10 +
    _titleBox(s) +
    4 +
    _captionBox(s) +
    12;

/// The key on a card's kind pill, and on its fact pill.
Key ttcKindPillKey(TtcCardKind kind, String title) =>
    ValueKey('ttc-kind-pill-${kind.name}-$title');
Key ttcKindMetaKey(String title) => ValueKey('ttc-kind-meta-$title');

/// The hue of a kind's tint. Assigned by what the reference used where it
/// had one (video rose, article blue, carousel lilac, product green, tool
/// amber, talk to an expert teal) and spaced round the wheel for the rest,
/// so no two kinds on one rail share a ground.
double ttcCardKindHue(TtcCardKind k) => switch (k) {
  TtcCardKind.video => 345,
  TtcCardKind.myth => 18,
  TtcCardKind.tool => 40,
  TtcCardKind.recipe => 58,
  TtcCardKind.practice => 96,
  TtcCardKind.product => 140,
  TtcCardKind.infographic => 160,
  TtcCardKind.consult => 176,
  TtcCardKind.community => 196,
  TtcCardKind.read => 212,
  TtcCardKind.course => 240,
  TtcCardKind.story => 268,
  TtcCardKind.chat => 305,
};

/// The card's ground: the kind's hue, very pale (the reference's softness).
Color ttcCardKindGround(TtcCardKind k) =>
    HSLColor.fromAHSL(1, ttcCardKindHue(k), 0.62, 0.955).toColor();

/// The picture well behind a drawing or a loading photo: one step deeper.
Color ttcCardKindWell(TtcCardKind k) =>
    HSLColor.fromAHSL(1, ttcCardKindHue(k), 0.6, 0.895).toColor();

/// The kind's ink: the pill's icon and word.
Color ttcCardKindInk(TtcCardKind k) =>
    HSLColor.fromAHSL(1, ttcCardKindHue(k), 0.55, 0.34).toColor();

/// The pastel a drawn mark is painted from (`TtcTabArt`, `TtcToolArt`).
Color ttcCardKindArtTint(TtcCardKind k) =>
    HSLColor.fromAHSL(1, ttcCardKindHue(k), 0.66, 0.84).toColor();

/// The kind's line icon on its pill. A film wears a camera, never a play
/// glyph: the play button belongs only on a film that can play.
IconData ttcCardKindIcon(TtcCardKind k) => switch (k) {
  TtcCardKind.video => Icons.videocam_outlined,
  TtcCardKind.story => Icons.view_carousel_outlined,
  TtcCardKind.read => Icons.article_outlined,
  TtcCardKind.myth => Icons.balance_rounded,
  TtcCardKind.tool => Icons.build_outlined,
  TtcCardKind.chat => Icons.chat_bubble_outline_rounded,
  TtcCardKind.consult => Icons.forum_outlined,
  TtcCardKind.practice => Icons.self_improvement_outlined,
  TtcCardKind.product => Icons.shopping_bag_outlined,
  TtcCardKind.course => Icons.school_outlined,
  TtcCardKind.recipe => Icons.restaurant_outlined,
  TtcCardKind.community => Icons.groups_outlined,
  TtcCardKind.infographic => Icons.insert_chart_outlined_rounded,
};

/// Whether [t] costs money: an offering (a consult or a course) with a
/// price. A product is never "Paid" (`TtcTileFormatCopy.isPaid`, 2026-09-03):
/// we do not sell it. An offering we cannot find claims nothing.
bool ttcCardIsPaid(TtcTile t) {
  final id = switch (t) {
    TtcTalkTile(:final action) => action,
    TtcBookingTile(:final action) => action,
    TtcMasterclassTile(:final offeringId) => offeringId,
    _ => null,
  };
  final o = id == null ? null : ttcOfferingById(id);
  return o != null && !o.isFree;
}

/// The word on a card's fact pill, top right, or null for none. Every fact
/// is derived, never typed: a read's minutes, a deck's slides, whether a
/// film exists, whether an offering has a price, a practice's length.
String? ttcCardMeta(TtcTile t) => switch (t) {
  TtcArticleTile() || TtcGuideTile() => ttcCardReadMinutes(t),
  // A live film shows its length on the picture, as the reference does.
  TtcVideoTile() => ttcTileIsUnmadeFilm(t) ? kTtcFilmComingSoon : null,
  TtcCarouselTile(:final cards) =>
    cards.length == 1 ? '1 slide' : '${cards.length} slides',
  TtcMythTile(:final slides) =>
    slides.isEmpty ? null : '${slides.length} slides',
  TtcTalkTile() ||
  TtcBookingTile() ||
  TtcMasterclassTile() => ttcCardIsPaid(t) ? kTtcCardPaid : null,
  TtcDoTile() => ttcTilePractice(
    t,
  )?.duration.replaceAll(RegExp(r'\bminutes?\b'), 'min'),
  _ => null,
};

/// The one word for a price on a card.
const String kTtcCardPaid = 'Paid';

/// The key on a kind card, so a test can find each kind on the door.
Key ttcKindCardKey(TtcCardKind kind, String title) =>
    ValueKey('ttc-kind-${kind.name}-$title');

/// Which kind [t] draws as, or null for the kinds that keep the old card.
///
/// ⚠️ A CHAT IS A TOOL TILE IN THE DATA. "Should I test?" is a
/// `TtcToolTile` whose surface is `ttc_chat/should_test`: a scripted chat of
/// rules, no AI. It opens as a conversation, so it looks like one.
TtcCardKind? ttcCardKindOf(TtcTile t) => switch (t) {
  TtcVideoTile() => TtcCardKind.video,
  TtcCarouselTile() => TtcCardKind.story,
  TtcArticleTile() || TtcGuideTile() => TtcCardKind.read,
  TtcMythTile() => TtcCardKind.myth,
  TtcToolTile(:final surfaceId) when surfaceId.startsWith('ttc_chat/') =>
    TtcCardKind.chat,
  TtcToolTile() || TtcChecklistTile() => TtcCardKind.tool,
  TtcTalkTile() || TtcBookingTile() => TtcCardKind.consult,
  TtcDoTile() => TtcCardKind.practice,
  TtcProductTile() => TtcCardKind.product,
  // 2026-09-29: the last four kinds join the family. Kept for revert:
  //   _ => null,
  TtcMasterclassTile() => TtcCardKind.course,
  TtcRecipeTile() => TtcCardKind.recipe,
  TtcCommunityTile() => TtcCardKind.community,
  TtcInfographicTile() => TtcCardKind.infographic,
  TtcDoorTile() => null,
};

/// The kind in words, as the card's pill says it. The reference's words
/// where it had them ("Carousel", "Talk to an expert"); the tile format's
/// own label for the rest (`TtcTileFormatCopy.label`).
// Kept for revert (2026-09-29): story 'Story', consult 'Consult'.
String ttcCardKindWord(TtcCardKind k) => switch (k) {
  TtcCardKind.video => 'Video',
  TtcCardKind.story => 'Carousel',
  TtcCardKind.read => 'Article',
  TtcCardKind.myth => 'Myth vs fact',
  TtcCardKind.tool => 'Tool',
  TtcCardKind.chat => 'Chat',
  TtcCardKind.consult => 'Talk to an expert',
  TtcCardKind.practice => 'Practice',
  TtcCardKind.product => 'Product',
  TtcCardKind.course => 'Masterclass',
  TtcCardKind.recipe => 'Recipe',
  TtcCardKind.community => 'Community',
  TtcCardKind.infographic => 'Infographic',
};

/// The card's width, by kind. The height is always [kTtcKindRailHeight].
double ttcCardKindWidth(TtcCardKind k) => switch (k) {
  // 16:9 at 248 wide is a 140 thumbnail: the widest card, as a film is.
  TtcCardKind.video => 248,
  // Tall and narrow, about 9:16 at the rail's height.
  TtcCardKind.story => 136,
  TtcCardKind.read => 184,
  TtcCardKind.myth => 184,
  TtcCardKind.tool => 156,
  TtcCardKind.chat => 196,
  TtcCardKind.consult => 176,
  TtcCardKind.practice => 176,
  TtcCardKind.product => 160,
  // The four kinds that joined on 2026-09-29 never drew a V1 card.
  TtcCardKind.course ||
  TtcCardKind.recipe ||
  TtcCardKind.community ||
  TtcCardKind.infographic => 184,
};

/// "7 min read", only when the read is long enough to say it.
///
/// ⚠️ THE READER'S OWN RULE (`PvReaderScreen`, 2026-09-28): under 200 words,
/// counting the short answer, a read says no minutes, because `minutes`
/// rounds up and a sixty-word piece claimed a minute. The card and the page
/// it opens must not disagree.
String? ttcCardReadMinutes(TtcTile t) {
  final id = switch (t) {
    TtcArticleTile(:final readId) => readId,
    TtcGuideTile(:final readId) => readId,
    _ => null,
  };
  final r = id == null ? null : ttcReadById(id);
  if (r == null) return null;
  final words =
      r.wordCount + (r.shortAnswer?.en ?? '').split(RegExp(r'\s+')).length;
  if (words < 200) return null;
  return '${r.minutes} min read';
}

/// A tool's action, as a verb she would say, naming what it opens.
///
/// ⚠️ EVERY PILL NAMES ITS THING (2026-09-28, the user: "instead of using
/// 'it' use the word ... so the user knows in the right way what they are
/// clicking"). "Take the check" became "Take the PCOS check", "See your
/// report" "See your cycle report", and a surface not named here says
/// "Open" and the card's own title, never "Open the tool". The pill wraps to
/// two lines (see `_pill`), so a named verb is never cut to an ellipsis on
/// the 156pt tool card. Kept for revert, the old verbs: 'Log today',
/// 'Take the check' (all three checks), 'See the tests', 'Read his report',
/// 'See your report', and 'Open the tool' as the fallback.
String ttcToolVerb(String surfaceId, [String? title]) => switch (surfaceId) {
  'ttc_window' => 'See your best days',
  'ttc_cycle' || 'ttc_calendar' => 'Open the calendar',
  'ttc_symptom_log' => "Log today's symptoms",
  'ttc_fertility_help' => 'Take the fertility check',
  'ttc_pcos_check' => 'Take the PCOS check',
  'ttc_precheck' => 'Open your checklist',
  'ttc_medication' => 'Open your medicines',
  'ttc_supplements' => 'Open your supplements',
  'ttc_records' => 'Open your records',
  'ttc_tests' => 'See the test library',
  'ttc_appointments' => 'Open your appointments',
  'ttc_semen_report' => 'Read his semen report',
  'ttc_cycle_report' => 'See your cycle report',
  _ => title == null || title.isEmpty ? 'Open the tool' : 'Open $title',
};

/// A chat's action, naming the chat (2026-09-28, explicit names): "Start the
/// should-I-test chat", after Ro's "Start a conversation" button
/// (https://mobbin.com/screens/678b13db-dc0e-42b5-9993-38f4d89b6b41), which
/// names the conversation it opens. Kept for revert: 'Start the chat' for
/// every chat.
String ttcChatVerb(String surfaceId) => switch (surfaceId) {
  'ttc_chat/should_test' => 'Start the should-I-test chat',
  'ttc_chat/period_came' => 'Start the period-day chat',
  'ttc_chat/cycle_report' => 'Start the cycle report chat',
  _ => 'Start the chat',
};

/// A tool's line icon.
IconData _toolIcon(String surfaceId) => switch (surfaceId) {
  'ttc_window' => Icons.date_range_outlined,
  'ttc_cycle' || 'ttc_calendar' => Icons.calendar_month_outlined,
  'ttc_symptom_log' => Icons.edit_note_rounded,
  'ttc_medication' || 'ttc_supplements' => Icons.medication_outlined,
  'ttc_records' ||
  'ttc_semen_report' ||
  'ttc_cycle_report' => Icons.description_outlined,
  'ttc_tests' => Icons.science_outlined,
  'ttc_appointments' => Icons.event_outlined,
  _ => Icons.tune_rounded,
};

/// "5:12" from seconds.
String _clock(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

// =============================================================================
//  The card
// =============================================================================

/// ⚠️ KEPT FOR REVERT (2026-09-29), REACHABLE FROM NOWHERE: the 2026-09-28
/// card, one SHAPE per kind, drawn on the Fertile window door only. The
/// door draws [TtcKindCard] now. See the header.
class TtcKindCardV1 extends StatelessWidget {
  const TtcKindCardV1({
    super.key,
    required this.tile,
    required this.kind,
    required this.p,
    required this.hue,
    required this.onTap,
  });

  final TtcTile tile;
  final TtcCardKind kind;
  final V2Palette p;

  /// The door's hue: every tint on the door is this one.
  final double hue;
  final VoidCallback onTap;

  Color get _tint => v2BlockTint(hue % 360, p);
  Color get _deep => HSLColor.fromColor(
    _tint,
  ).withSaturation(0.46).withLightness(0.32).toColor();

  @override
  Widget build(BuildContext context) {
    final (child, label, flat) = switch (kind) {
      TtcCardKind.video => (_video(), _videoLabel(), false),
      TtcCardKind.story => (_story(), _storyLabel(), true),
      TtcCardKind.read => (_read(), _readLabel(), false),
      TtcCardKind.myth => (_myth(), _mythLabel(), true),
      TtcCardKind.tool => (_tool(), _toolLabel(), false),
      TtcCardKind.chat => (_chat(), _chatLabel(), false),
      TtcCardKind.consult => (_consult(), _consultLabel(), false),
      TtcCardKind.practice => (_practice(), _practiceLabel(), false),
      TtcCardKind.product => (_product(), _productLabel(), false),
      TtcCardKind.course ||
      TtcCardKind.recipe ||
      TtcCardKind.community ||
      TtcCardKind.infographic => (_read(), _readLabel(), false),
    };
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: PvPress(
        child: Material(
          key: ttcKindCardKey(kind, tile.title),
          color: kind == TtcCardKind.myth
              ? _tint
              : kind == TtcCardKind.story
              ? Colors.black
              : p.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: flat ? BorderSide.none : BorderSide(color: p.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            // The door's `_openTile` hums, so the card does not hum twice.
            onTap: onTap,
            child: SizedBox(
              width: ttcCardKindWidth(kind),
              height: kTtcKindRailHeight,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  // ---- shared pieces --------------------------------------------------------

  Widget _photo(String? url, {Widget? fallback}) {
    final none =
        fallback ??
        Container(
          color: _tint,
          alignment: Alignment.center,
          child: SizedBox(
            width: 40,
            height: 40,
            child: HubIntentArt(mark: ttcDoorTileMark(tile), tint: _tint),
          ),
        );
    if (url == null || url.isEmpty) return none;
    return Image.network(
      url,
      fit: BoxFit.cover,
      // Offline: the door's tint and the kind's mark, never a grey box.
      errorBuilder: (_, _, _) => none,
    );
  }

  Widget _title(
    String text, {
    double size = 15.5,
    int lines = 3,
    Color? color,
  }) => Text(
    text,
    maxLines: lines,
    overflow: TextOverflow.ellipsis,
    style: pvFraunces(
      fontSize: size,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: -0.3,
      color: color ?? p.ink1,
    ),
  );

  /// The kind in words, with its line icon: the eyebrow on cards whose
  /// action sits at the foot, the foot on cards that are a picture first.
  Widget _kindLine(IconData icon, String text, {Color? color}) {
    final c = color ?? _deep;
    return Row(
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: pvManrope(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              color: c,
            ),
          ),
        ),
      ],
    );
  }

  /// A pill with an action verb: ink when it is the card's one action,
  /// outlined when the card is a conversation rather than a tool.
  Widget _pill(String verb, {bool outlined = false}) => Container(
    constraints: const BoxConstraints(minHeight: 34),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: outlined ? Colors.transparent : ttcTitleInk,
      borderRadius: BorderRadius.circular(999),
      border: outlined ? Border.all(color: ttcTitleInk, width: 1.2) : null,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Two lines, so a verb that names its thing ("Take the fertility
        // check") is read whole on a 156pt card rather than cut at the
        // ellipsis (2026-09-28). The title above is `Expanded` and gives way.
        // Kept for revert: maxLines: 1.
        Flexible(
          child: Text(
            verb,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: pvManrope(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: outlined ? p.ink1 : Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.arrow_forward_rounded,
          size: 14,
          color: outlined ? p.ink1 : Colors.white,
        ),
      ],
    ),
  );

  Widget _iconTile(Widget child) => Container(
    width: 44,
    height: 44,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: _tint,
      borderRadius: BorderRadius.circular(14),
    ),
    child: child,
  );

  // ---- video ----------------------------------------------------------------

  bool get _unmade => ttcTileIsUnmadeFilm(tile);

  String get _videoFact {
    if (_unmade) return kTtcFilmComingSoon;
    final film = ttcVideoBySlot((tile as TtcVideoTile).slotId);
    return film == null ? '' : '${(film.seconds / 60).ceil()} min';
  }

  String _videoLabel() =>
      'Video, ${tile.title}, ${_unmade ? 'coming soon, not ready to watch yet' : _videoFact}';

  Widget _video() {
    final film = tile is TtcVideoTile
        ? ttcVideoBySlot((tile as TtcVideoTile).slotId)
        : null;
    // ⚠️ NEVER A PLAY GLYPH ON A FILM THAT CANNOT PLAY (launch sanity D3):
    // an unmade film wears a clock and says "Coming soon".
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _unmade ? Icons.schedule_rounded : Icons.play_arrow_rounded,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            _unmade
                ? kTtcFilmComingSoon
                : (film == null ? 'Play' : _clock(film.seconds)),
            style: pvManrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _photo(photoForTile(tile)),
              Positioned(left: 10, bottom: 10, child: badge),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _title(tile.title, lines: 2)),
                const SizedBox(height: 4),
                _kindLine(Icons.smart_display_outlined, 'Video · $_videoFact'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---- story ----------------------------------------------------------------

  int get _slides => switch (tile) {
    TtcCarouselTile(:final cards) => cards.length,
    _ => 0,
  };

  String get _storyFact => _slides == 1 ? '1 slide' : '$_slides slides';

  String _storyLabel() => 'Story, ${tile.title}, $_storyFact to swipe';

  Widget _story() => Stack(
    fit: StackFit.expand,
    children: [
      _photo(photoForTile(tile)),
      // Dark, never white: a white mist washes the photo out.
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.30),
              Colors.black.withValues(alpha: 0.0),
              Colors.black.withValues(alpha: 0.74),
            ],
            stops: const [0.0, 0.28, 1.0],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The story ticks: one per slide, the first one lit (Flo,
            // Instagram). They are the count before she reads the number.
            Row(
              children: [
                for (var i = 0; i < _slides.clamp(1, 12); i++) ...[
                  if (i > 0) const SizedBox(width: 3),
                  Expanded(
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: i == 0 ? 0.95 : 0.5,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const Spacer(),
            Flexible(
              flex: 4,
              child: _title(
                tile.title,
                size: 15,
                lines: 4,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            _kindLine(
              Icons.auto_stories_outlined,
              'Story · $_storyFact',
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ],
        ),
      ),
    ],
  );

  // ---- article --------------------------------------------------------------

  String _readLabel() =>
      ['Article', tile.title, ?ttcCardReadMinutes(tile)].join(', ');

  Widget _read() {
    final minutes = ttcCardReadMinutes(tile);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 112, child: _photo(photoForTile(tile))),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _title(tile.title)),
                const SizedBox(height: 4),
                _kindLine(
                  Icons.article_outlined,
                  ['Article', ?minutes].join(' · '),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---- myth vs fact ---------------------------------------------------------

  String get _claim => switch (tile) {
    TtcMythTile(:final myth) => myth,
    _ => '',
  };

  String _mythLabel() =>
      'Myth vs fact, ${tile.title}. People say: $_claim. See the fact';

  Widget _myth() => Padding(
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kindLine(Icons.balance_rounded, 'Myth vs fact'),
        const SizedBox(height: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: _title(tile.title, size: 17)),
              if (_claim.isNotEmpty) ...[
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    'People say: “$_claim”',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                      color: p.ink2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        _kindLine(Icons.arrow_forward_rounded, 'See the fact', color: p.ink1),
      ],
    ),
  );

  // ---- tool -----------------------------------------------------------------

  String get _surface => switch (tile) {
    TtcToolTile(:final surfaceId) => surfaceId,
    TtcChecklistTile(:final surfaceId) => surfaceId,
    _ => '',
  };

  String _toolLabel() =>
      'Tool, ${tile.title}. ${ttcToolVerb(_surface, tile.title)}';

  Widget _tool() => Padding(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _iconTile(Icon(_toolIcon(_surface), size: 22, color: _deep)),
        const SizedBox(height: 10),
        _kindLine(Icons.tune_rounded, 'Tool'),
        const SizedBox(height: 4),
        Expanded(child: _title(tile.title, size: 16.5)),
        const SizedBox(height: 8),
        _pill(ttcToolVerb(_surface, tile.title)),
      ],
    ),
  );

  // ---- chat -----------------------------------------------------------------

  // Kept for revert (2026-09-28): '... Start the chat'.
  String _chatLabel() =>
      'Chat, ${tile.title}. ${tile.blurb} ${ttcChatVerb(_surface)}';

  Widget _chat() => Padding(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kindLine(Icons.chat_bubble_outline_rounded, 'Chat'),
        const SizedBox(height: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Her question, in ink, tail at the bottom right: what she
              // would type.
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ttcTitleInk,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    child: Text(
                      tile.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // The answer's promise, in the tint, tail at the bottom left.
              Flexible(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _tint,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      tile.blurb,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                        fontSize: 12.5,
                        height: 1.35,
                        color: p.ink1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Kept for revert (2026-09-28): _pill('Start the chat', outlined: true),
        _pill(ttcChatVerb(_surface), outlined: true),
      ],
    ),
  );

  // ---- consult --------------------------------------------------------------

  String get _action => switch (tile) {
    TtcTalkTile(:final action) => action,
    TtcBookingTile(:final action) => action,
    _ => '',
  };

  String _consultLabel() {
    final o = ttcOfferingById(_action);
    return [
      'Consult',
      tile.title,
      ?o?.titleEn,
      if (o != null) 'Video call, ${o.priceLabel}',
      o == null ? 'See the doctors' : 'See times and book',
    ].join(', ');
  }

  Widget _consult() {
    final o = ttcOfferingById(_action);
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⚠️ NO STOCK FACE. A person card with a stranger's photo would
          // put a face to a doctor who is not that face. An object says
          // what happens: a video call.
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: _tint, shape: BoxShape.circle),
            child: Icon(Icons.videocam_outlined, size: 22, color: _deep),
          ),
          const SizedBox(height: 10),
          _kindLine(Icons.person_outline_rounded, 'Consult'),
          const SizedBox(height: 4),
          Flexible(child: _title(tile.title, size: 16, lines: 2)),
          if (o != null) ...[
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                o.titleEn,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(fontSize: 12, height: 1.3, color: p.ink2),
              ),
            ),
          ],
          const Spacer(),
          if (o != null)
            Text(
              'Video call · ${o.priceLabel}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: p.ink1,
              ),
            ),
          const SizedBox(height: 6),
          _pill(o == null ? 'See the doctors' : 'See times and book'),
        ],
      ),
    );
  }

  // ---- practice -------------------------------------------------------------

  String get _practiceFact {
    final pr = ttcTilePractice(tile);
    if (pr == null) return '';
    final steps = pr.steps.length == 1 ? '1 step' : '${pr.steps.length} steps';
    final mins = pr.duration.replaceAll(RegExp(r'\bminutes?\b'), 'min');
    return '$steps · $mins';
  }

  String _practiceLabel() => [
    'Practice',
    tile.title,
    if (_practiceFact.isNotEmpty) _practiceFact,
  ].join(', ');

  Widget _practice() => Padding(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _iconTile(
          SizedBox(
            width: 30,
            height: 30,
            child: HubIntentArt(mark: ttcDoorTileMark(tile), tint: _tint),
          ),
        ),
        const SizedBox(height: 10),
        _kindLine(Icons.self_improvement_outlined, 'Practice'),
        const SizedBox(height: 4),
        Expanded(child: _title(tile.title, size: 16.5)),
        if (_practiceFact.isNotEmpty) ...[
          const SizedBox(height: 6),
          _kindLine(Icons.timer_outlined, _practiceFact, color: p.ink2),
        ],
      ],
    ),
  );

  // ---- product --------------------------------------------------------------

  String _productLabel() => 'Product, ${tile.title}. ${tile.blurb}';

  Widget _product() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // The store's product look: the photo inset in a well, not bled to
      // the edge as a read's is, so a thing to buy never reads as a story.
      Container(
        height: 112,
        color: p.surfaceAlt,
        padding: const EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _photo(photoForTile(tile)),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _title(tile.title)),
              const SizedBox(height: 4),
              _kindLine(Icons.shopping_bag_outlined, 'Product · what to buy'),
            ],
          ),
        ),
      ),
    ],
  );
}

// =============================================================================
//  The card, 2026-09-29: one shape, one tint per kind (see the header)
// =============================================================================

/// The drawn object for a card with no photograph: a tool's own mark from
/// the Tools tab (`ttcToolMarkForSurface`), two bubbles for a chat, and for
/// any other kind the tab family's mark for its meaning, so an offline photo
/// or a card without one is a finished picture, never a grey box.
Widget ttcKindCardDrawing(TtcTile t, TtcCardKind kind, {Color? tint}) {
  // [tint]: a shelf card on a door tab passes its tab's colour (2026-09-29).
  tint ??= ttcCardKindArtTint(kind);
  final surface = switch (t) {
    TtcToolTile(:final surfaceId) => surfaceId,
    TtcChecklistTile(:final surfaceId) => surfaceId,
    _ => null,
  };
  if (kind != TtcCardKind.chat && surface != null) {
    if (ttcToolMarkForSurface(surface) case final mark?) {
      return TtcToolArt(mark: mark, tint: tint);
    }
  }
  final mark = switch (kind) {
    TtcCardKind.chat => TtcTabMark.twoBubbles,
    TtcCardKind.tool => TtcTabMark.chartLine,
    TtcCardKind.practice => switch (ttcTilePractice(t)?.kind) {
      TtcPracticeKind.breathe => TtcTabMark.sun,
      _ => TtcTabMark.lotus,
    },
    TtcCardKind.video => TtcTabMark.sunrise,
    TtcCardKind.read ||
    TtcCardKind.story ||
    TtcCardKind.course => TtcTabMark.openBook,
    TtcCardKind.myth => TtcTabMark.signpost,
    TtcCardKind.consult => TtcTabMark.doctorChat,
    TtcCardKind.product => TtcTabMark.jarLeaf,
    TtcCardKind.recipe => TtcTabMark.bowl,
    TtcCardKind.community => TtcTabMark.twoFigures,
    TtcCardKind.infographic => TtcTabMark.chartLine,
  };
  return TtcTabArt(mark: mark, tint: tint);
}

/// Whether a kind's picture is a drawing whatever the photo table holds: a
/// tool is shown as the tool (the reference's clipboard), never a stock
/// photo, and a chat as the conversation it opens.
bool ttcKindDrawsNoPhoto(TtcCardKind k) =>
    k == TtcCardKind.tool || k == TtcCardKind.chat;

/// One piece on a door, in the one card family. See the header.
class TtcKindCard extends StatelessWidget {
  const TtcKindCard({
    super.key,
    required this.tile,
    required this.kind,
    required this.p,
    required this.onTap,
    this.width = kTtcKindCardWidth,
    this.imageHeight,
  });

  final TtcTile tile;
  final TtcCardKind kind;
  final V2Palette p;
  final VoidCallback onTap;

  /// The card's width: [kTtcKindCardWidth] on a rail, the content width for
  /// a section of one piece, half of it in the grid.
  final double width;

  /// The picture's height. Null derives it from [width]; the wide card of a
  /// one-piece section passes the rail's, so a door has one card height.
  final double? imageHeight;

  bool get _unmade => ttcTileIsUnmadeFilm(tile);

  /// A live film's length in seconds, or null.
  int? get _filmSeconds => switch (tile) {
    TtcVideoTile(:final slotId) when !_unmade => ttcVideoBySlot(
      slotId,
    )?.seconds,
    _ => null,
  };

  String get _label {
    final meta = ttcCardMeta(tile);
    return [
      ttcCardKindWord(kind),
      tile.title,
      if (kind == TtcCardKind.video && _unmade)
        'coming soon, not ready to watch yet'
      else if (_filmSeconds case final s?)
        '${(s / 60).ceil()} min'
      else
        ?meta,
      if (tile.blurb.isNotEmpty) tile.blurb,
    ].join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final imageH = imageHeight ?? ttcKindCardImageHeight(width);
    return Semantics(
      button: true,
      label: _label,
      excludeSemantics: true,
      child: PvPress(
        child: Material(
          key: ttcKindCardKey(kind, tile.title),
          color: ttcCardKindGround(kind),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            // The door's `_openTile` hums, so the card does not hum twice.
            onTap: onTap,
            child: SizedBox(
              width: width,
              height: ttcKindCardHeight(
                scaler,
                width: width,
                imageHeight: imageH,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      _kInset,
                      _kInset,
                      _kInset,
                      0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: imageH,
                        // The picture is a fixed box: its pills may grow a
                        // little with the text size, not without end.
                        child: MediaQuery.withClampedTextScaling(
                          maxScaleFactor: 1.25,
                          child: _picture(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
                    child: Row(
                      children: [
                        Expanded(
                          // ⚠️ ONE BOX FOR BOTH, NOT TWO (2026-09-29, the
                          // first render): a one-line title in its own
                          // two-line box left a blank line above the caption.
                          // The words now run from the top and the reserved
                          // room sits under them, so the card keeps one size
                          // and the caption sits right under its title.
                          // Kept for revert: SizedBox(height: _titleBox) and
                          // SizedBox(height: _captionBox) around each Text.
                          child: SizedBox(
                            height: _titleBox(scaler) + 4 + _captionBox(scaler),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tile.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: pvFraunces(
                                    fontSize: _kTitleSize,
                                    fontWeight: FontWeight.w600,
                                    height: _kTitleLine,
                                    letterSpacing: -0.3,
                                    color: p.ink1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Flexible(
                                  child: Text(
                                    tile.blurb,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: pvManrope(
                                      fontSize: _kCaptionSize,
                                      height: _kCaptionLine,
                                      color: p.ink2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 22,
                          color: p.ink2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---- the picture ----------------------------------------------------------

  Widget _picture() {
    final meta = ttcCardMeta(tile);
    final Widget ground = switch (kind) {
      TtcCardKind.story => _TtcKindDeck(tile: tile, kind: kind),
      _ when ttcKindDrawsNoPhoto(kind) => _TtcKindScene(tile: tile, kind: kind),
      _ => _photo(),
    };
    final seconds = _filmSeconds;
    return Stack(
      fit: StackFit.expand,
      children: [
        ground,
        // ⚠️ A PLAY BUTTON ONLY ON A FILM THAT PLAYS (launch sanity D3): an
        // unmade film says "Coming soon" on its fact pill and draws no play
        // glyph anywhere on the card.
        if (seconds != null) ...[
          Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
                style: pvManrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
        Positioned(
          left: 8,
          top: 8,
          right: 8,
          // A Wrap, not a Row: at a large text size (or on a narrow grid
          // card) the fact pill drops under the kind pill, never overflows.
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 6,
            runSpacing: 6,
            children: [
              _pill(
                key: ttcKindPillKey(kind, tile.title),
                icon: ttcCardKindIcon(kind),
                text: ttcCardKindWord(kind),
                fg: ttcCardKindInk(kind),
                strong: true,
              ),
              if (meta != null)
                _pill(
                  key: ttcKindMetaKey(tile.title),
                  icon: meta == kTtcCardPaid
                      ? Icons.lock_outline_rounded
                      : meta == kTtcFilmComingSoon
                      ? Icons.schedule_rounded
                      : null,
                  text: meta,
                  fg: meta == kTtcCardPaid ? ttcCardKindInk(kind) : p.ink2,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _photo() {
    final fallback = _TtcKindScene(tile: tile, kind: kind);
    final url = photoForTile(tile);
    if (url == null || url.isEmpty) return fallback;
    return Stack(
      fit: StackFit.expand,
      children: [
        // The well shows while the photo arrives, never a blank flash.
        ColoredBox(color: ttcCardKindWell(kind)),
        Image.network(
          url,
          fit: BoxFit.cover,
          // Offline: the kind's drawing, never a grey box.
          errorBuilder: (_, _, _) => fallback,
        ),
      ],
    );
  }

  Widget _pill({
    Key? key,
    IconData? icon,
    required String text,
    required Color fg,
    bool strong = false,
  }) => Container(
    key: key,
    padding: EdgeInsets.fromLTRB(icon == null ? 10 : 8, 5, 10, 5),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: pvManrope(
              fontSize: 11.5,
              fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ],
    ),
  );
}

/// A drawn picture on the kind's well: two soft shapes behind, the object in
/// front, set a little low so the pills never sit on it (the reference's
/// tool card: a clipboard on amber with soft blobs).
class _TtcKindScene extends StatelessWidget {
  const _TtcKindScene({required this.tile, required this.kind});

  final TtcTile tile;
  final TtcCardKind kind;

  @override
  Widget build(BuildContext context) => ColoredBox(
    key: ttcKindDrawingKey(tile.title),
    color: ttcCardKindWell(kind),
    child: LayoutBuilder(
      builder: (context, box) {
        final h = box.maxHeight;
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -h * 0.18,
              bottom: -h * 0.30,
              width: h * 0.95,
              height: h * 0.95,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -h * 0.12,
              top: h * 0.30,
              width: h * 0.55,
              height: h * 0.55,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ttcCardKindGround(kind).withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.6),
              child: SizedBox(
                width: h * 0.74,
                height: h * 0.74,
                child: ttcKindCardDrawing(tile, kind),
              ),
            ),
          ],
        );
      },
    ),
  );
}

/// The key on a tool card's corner badge (2026-09-29).
Key ttcKindToolBarKey(String title) => ValueKey('ttc-kind-toolbar-$title');

/// The key on a card's drawn picture, so a test can tell a drawing from a
/// photograph.
Key ttcKindDrawingKey(String title) => ValueKey('ttc-kind-drawing-$title');

/// A carousel's picture: its first slide in front, the photo and the slide's
/// own words, with the next two peeking behind it, so she sees a deck before
/// she taps (the reference's "1. What happens in PCOS?").
class _TtcKindDeck extends StatelessWidget {
  const _TtcKindDeck({required this.tile, required this.kind});

  final TtcTile tile;
  final TtcCardKind kind;

  @override
  Widget build(BuildContext context) {
    final cards = switch (tile) {
      TtcCarouselTile(:final cards) => cards,
      _ => const <TtcCarouselCard>[],
    };
    final url = photoForTile(tile);
    // The slide's words without their emphasis marks ("*half of it*").
    final first = (cards.isEmpty ? tile.title : cards.first.title).replaceAll(
      '*',
      '',
    );
    Color slideTint(int i) => i < cards.length && cards[i].hue != null
        ? HSLColor.fromAHSL(1, cards[i].hue!, 0.5, 0.86).toColor()
        : ttcCardKindArtTint(kind);
    Widget peek(int i, double opacity) => DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: slideTint(i),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
    return ColoredBox(
      key: ttcKindDeckKey(tile.title),
      color: ttcCardKindWell(kind),
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth, h = box.maxHeight;
          return Stack(
            children: [
              Positioned(
                left: w * 0.60,
                top: h * 0.40,
                width: w * 0.30,
                height: h * 0.58,
                child: peek(2, 0.62),
              ),
              Positioned(
                left: w * 0.42,
                top: h * 0.34,
                width: w * 0.34,
                height: h * 0.68,
                child: peek(1, 0.88),
              ),
              Positioned(
                left: w * 0.07,
                top: h * 0.30,
                width: w * 0.44,
                height: h * 0.80,
                child: Transform.rotate(
                  angle: -0.05,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: url == null
                                  ? ColoredBox(color: slideTint(0))
                                  : Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          ColoredBox(color: slideTint(0)),
                                    ),
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
                              child: Text(
                                '1. $first',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: pvManrope(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  color: const Color(0xFF2A2A2A),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The key on a carousel's stacked slide previews.
Key ttcKindDeckKey(String title) => ValueKey('ttc-kind-deck-$title');

// =============================================================================
//  TtcFloCard: the small block, the way Flo lays a door's shelves (2026-09-29)
// -----------------------------------------------------------------------------
//  ⚠️ THE USER, ON BUILD 21, WITH FLO'S "HOW TO GET PREGNANT" PAGE BESIDE OURS:
//  "copy the exact same sizing and the way they have represented the text on
//  those small blocks… the video is evident to be a video… we can have our
//  tags." Flo's shelf is three small blocks across: the words at the top on
//  the kind's soft ground, the picture filling the foot. A video is a picture
//  with its length on it, the title and "N min watch" under it. Our kind tag
//  rides above the title, so a read, a tool and a story are still told apart
//  in words. Same taps, photos, drawings and honesty rules as [TtcKindCard]
//  (no play mark on an unmade film). Kept for revert: the rail of
//  [TtcKindCard], behind [kTtcDoorCardsFlo] = false.
// =============================================================================

/// True: a door's shelves draw [TtcFloCard]s. False: the [TtcKindCard] rail.
const bool kTtcDoorCardsFlo = true;

/// A block's width: about three across at 360dp, as on Flo.
const double kTtcFloBlockWidth = 116;

/// A video's width: its picture a little wider than a block, as on Flo.
const double kTtcFloVideoWidth = 150;

const double _kFloPictureH = 64;
const double _kFloVideoPictureH = 104;

/// One height for a shelf of blocks and videos, grown with the text size.
double ttcFloRailHeight(TextScaler s) {
  final block =
      10 + s.scale(20) + 6 + s.scale(13.5) * 1.2 * 3 + 8 + _kFloPictureH;
  final video = _kFloVideoPictureH +
      8 +
      s.scale(13) * 1.25 * 2 +
      3 +
      s.scale(11.5) * 1.35 +
      2;
  return (block > video ? block : video).ceilToDouble();
}

class TtcFloCard extends StatelessWidget {
  const TtcFloCard({
    super.key,
    required this.tile,
    required this.kind,
    required this.p,
    required this.onTap,
    required this.height,
  });

  final TtcTile tile;
  final TtcCardKind kind;
  final V2Palette p;
  final VoidCallback onTap;
  final double height;

  bool get _unmade => ttcTileIsUnmadeFilm(tile);

  int? get _filmSeconds => switch (tile) {
    TtcVideoTile(:final slotId) when !_unmade => ttcVideoBySlot(
      slotId,
    )?.seconds,
    _ => null,
  };

  String get _label {
    final meta = ttcCardMeta(tile);
    return [
      ttcCardKindWord(kind),
      tile.title,
      if (kind == TtcCardKind.video && _unmade)
        'coming soon, not ready to watch yet'
      else if (_filmSeconds case final s?)
        '${(s / 60).ceil()} min'
      else
        ?meta,
    ].join(', ');
  }

  Widget _picture() => switch (kind) {
    TtcCardKind.story => _TtcKindDeck(tile: tile, kind: kind),
    _ when ttcKindDrawsNoPhoto(kind) => _TtcKindScene(tile: tile, kind: kind),
    _ => _photo(),
  };

  Widget _photo() {
    final fallback = _TtcKindScene(tile: tile, kind: kind);
    final url = photoForTile(tile);
    if (url == null || url.isEmpty) return fallback;
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: ttcCardKindWell(kind)),
        Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback,
        ),
      ],
    );
  }

  Widget _tag() => Row(
    key: ttcKindPillKey(kind, tile.title),
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(ttcCardKindIcon(kind), size: 12, color: ttcCardKindInk(kind)),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          ttcCardKindWord(kind),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: pvManrope(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            color: ttcCardKindInk(kind),
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) =>
      kind == TtcCardKind.video ? _video() : _block();

  Widget _block() {
    final meta = ttcCardMeta(tile);
    return Semantics(
      button: true,
      label: _label,
      excludeSemantics: true,
      child: PvPress(
        child: Material(
          key: ttcKindCardKey(kind, tile.title),
          color: ttcCardKindGround(kind),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: kTtcFloBlockWidth,
              height: height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _tag(),
                        const SizedBox(height: 6),
                        Text(
                          tile.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                            fontSize: 13.5,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: p.ink1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: _kFloPictureH,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _picture(),
                        if (meta != null)
                          Positioned(right: 6, bottom: 6, child: _chip(meta)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String meta) => Container(
    key: ttcKindMetaKey(tile.title),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (meta == kTtcCardPaid) ...[
          Icon(Icons.lock_outline_rounded, size: 10, color: p.ink1),
          const SizedBox(width: 3),
        ],
        Text(
          meta,
          style: pvManrope(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: p.ink1,
          ),
        ),
      ],
    ),
  );

  Widget _video() {
    final seconds = _filmSeconds;
    final minutes = seconds == null ? null : (seconds / 60).ceil();
    final length = seconds == null
        ? kTtcFilmComingSoon
        : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Semantics(
      button: true,
      label: _label,
      excludeSemantics: true,
      child: PvPress(
        child: InkWell(
          key: ttcKindCardKey(kind, tile.title),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: kTtcFloVideoWidth,
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: kTtcFloVideoWidth,
                    height: _kFloVideoPictureH,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: ttcCardKindGround(kind)),
                        _photo(),
                        // ⚠️ A play mark only on a film that plays (D3).
                        if (seconds != null)
                          Center(
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 26,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: Container(
                            key: ttcKindMetaKey(tile.title),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (seconds == null) ...[
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 3),
                                ],
                                Text(
                                  length,
                                  style: pvManrope(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(left: 8, top: 8, child: _videoTag()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tile.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: p.ink1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  minutes == null ? 'Video, coming soon' : '$minutes min watch',
                  maxLines: 1,
                  style: pvManrope(fontSize: 11.5, color: p.ink2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _videoTag() => Container(
    key: ttcKindPillKey(kind, tile.title),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ttcCardKindIcon(kind), size: 11, color: ttcCardKindInk(kind)),
        const SizedBox(width: 3),
        Text(
          ttcCardKindWord(kind),
          style: pvManrope(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: ttcCardKindInk(kind),
          ),
        ),
      ],
    ),
  );
}

// =============================================================================
//  TtcShelfCard: a picture, then its title and one plain line (2026-09-29)
// -----------------------------------------------------------------------------
//  ⚠️ THE USER, ON BUILD 22, FLO'S "HOW TO GET PREGNANT" BESIDE OUR FERTILE
//  WINDOW DOOR: the half-tint, half-photo block "does not look good", the
//  photos were random, and the whole door "looks so much on the face"; Flo's
//  is "minimalistic and subtle but yet it looks good". The brief: simple,
//  minimal, and she knows what she is tapping; a video shows it is a video
//  "with just a play button", no tag needed.
//
//  So one card, Flo's "Countdown to conception" shelf: a rounded picture, and
//  under it the title and one grey line that says what the thing is ("Article
//  · 9 min read", "Myth or fact", "Tool"). A film is the only card with marks
//  on its picture: the play button and its length, or "Coming soon" and no
//  play button while it is unmade (the D3 honesty rule). The picture is a
//  photo only where it shows the subject (`kTtcCardPhotoOff`); otherwise a
//  drawn object on the kind's soft colour (`kTtcCardMarks`), as Flo draws its
//  hourglass on blue. Same taps and keys as the cards before it. Kept for
//  revert: [TtcFloCard] behind [kTtcDoorCardsShelf] = false.
// =============================================================================

/// True: a door's shelves draw [TtcShelfCard]s (2026-09-29).
const bool kTtcDoorCardsShelf = true;

/// ⚠️ A PREVIEW, NOT A LAUNCH STATE (2026-09-29, the user on build 23: "show
/// me that for video tabs in our doors no matter if they are coming soon,
/// take a random length"). True: an UNMADE film draws Flo's play triangle and
/// a made-up length, so the look can be judged before the films exist. It
/// breaks the D3 rule (no play mark on a film that cannot play: she taps
/// "0:42" and lands on "coming soon"), so it MUST be false before launch.
/// STILL-OPEN §80.13. False: "Coming soon" and no play mark, as before.
const bool kTtcShelfFilmPreview = true;

/// The preview's made-up length for an unmade film: 0:30 to 4:59, fixed by
/// the title so the same card never shows two lengths.
int ttcShelfPreviewSeconds(String title) {
  var h = 0;
  for (final c in title.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return 30 + h % 270;
}

/// A card's width: two and a bit across a 360-411dp phone, so the shelf says
/// "more this way" without a hint.
const double kTtcShelfCardWidth = 148;

/// The picture's height: a little under square, Flo's proportion.
const double kTtcShelfPictureHeight = 128;

const double _kShelfTitleSize = 14;
const double _kShelfTitleLine = 1.25;
const double _kShelfMetaSize = 12;
const double _kShelfMetaLine = 1.3;

/// One height for a shelf, grown with the text size: the picture, the title
/// kept at two lines and the one grey line.
double ttcShelfRailHeight(TextScaler s) =>
    (kTtcShelfPictureHeight +
            8 +
            s.scale(_kShelfTitleSize) * _kShelfTitleLine * 2 +
            3 +
            s.scale(_kShelfMetaSize) * _kShelfMetaLine +
            4)
        .ceilToDouble();

/// The grey line under a card's title: what the thing is, then the one fact
/// worth knowing before the tap. Every fact is derived, never typed.
String ttcShelfMeta(TtcTile t, TtcCardKind kind) {
  final paid = ttcCardIsPaid(t);
  String withPaid(String w) => paid ? '$w · $kTtcCardPaid' : w;
  switch (kind) {
    case TtcCardKind.video:
      // The picture says "Coming soon"; the line only says what it is.
      // In the preview the made-up length reads the same as a real one.
      if (ttcTileIsUnmadeFilm(t)) {
        return kTtcShelfFilmPreview
            ? '${(ttcShelfPreviewSeconds(t.title) / 60).ceil()} min watch'
            : 'Video';
      }
      final s = switch (t) {
        TtcVideoTile(:final slotId) => ttcVideoBySlot(slotId)?.seconds,
        _ => null,
      };
      return s == null ? 'Video' : '${(s / 60).ceil()} min watch';
    case TtcCardKind.read:
      final m = ttcCardReadMinutes(t);
      return m == null ? 'Article' : 'Article · $m';
    case TtcCardKind.story:
      final n = switch (t) {
        TtcCarouselTile(:final cards) => cards.length,
        _ => 0,
      };
      return n == 0 ? 'Carousel' : 'Carousel · $n cards';
    case TtcCardKind.myth:
      return 'Myth or fact';
    case TtcCardKind.practice:
      final d = ttcCardMeta(t);
      return d == null ? 'Practice' : 'Practice · $d';
    // The price rides on the picture (`ttcShelfPrice`), so the line names
    // who she would talk to instead of saying "Paid" twice.
    case TtcCardKind.consult:
      final who = ttcShelfPerson(t);
      // The name alone: "Consult · Dr Ruchika Sood" cut off at 148pt, and
      // her initials and the price already say what this is.
      if (who != null) return who;
      return ttcShelfPrice(t) == null
          ? withPaid('Talk to an expert')
          : 'Talk to an expert';
    // The price left the picture (2026-09-30), so a paid course says so here.
    // Kept for revert:
    //   return ttcShelfPrice(t) == null ? withPaid('Masterclass') : 'Masterclass';
    case TtcCardKind.course:
      return withPaid('Masterclass');
    case TtcCardKind.tool ||
        TtcCardKind.chat ||
        TtcCardKind.product ||
        TtcCardKind.recipe ||
        TtcCardKind.community ||
        TtcCardKind.infographic:
      return ttcCardKindWord(kind);
  }
}

/// The offering behind a consult or a course card, if the catalogue has it.
TtcOffering? _shelfOffering(TtcTile t) {
  final id = switch (t) {
    TtcTalkTile(:final action) => action,
    TtcBookingTile(:final action) => action,
    TtcMasterclassTile(:final offeringId) => offeringId,
    _ => null,
  };
  return id == null ? null : ttcOfferingById(id);
}

/// The price on a paid card's picture (2026-09-29, the user: "an intuitive
/// representation for paid stuff like talk to an expert and products… the
/// user should know what they are clicking on"): the catalogue's own figure,
/// "₹599" or "Free" for an offering, the shelf price for a product. Null when
/// the catalogue has none, and then the card claims nothing.
String? ttcShelfPrice(TtcTile t) {
  if (t case TtcProductTile(:final productId?)) {
    final p = ttcProducts.where((p) => p.id == productId).firstOrNull;
    return p == null || p.price.isEmpty ? null : p.price;
  }
  return _shelfOffering(t)?.priceLabel;
}

/// The roster person behind a consult card, by name, or null. The same
/// answer the Learn rows give (`PvLearnCatalog.ttcRosterFor`); a role
/// ("A gynaecologist") is not a name and is not shown as one.
String? ttcShelfPerson(TtcTile t) {
  final o = _shelfOffering(t);
  if (o == null) return null;
  final name = PvLearnCatalog.ttcRosterFor(o).$1;
  return name.startsWith('A ') || name.startsWith('An ') ? null : name;
}

/// "Dr Ruchika Sood" → "RS".
String _initials(String name) {
  final words = name
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && w.toLowerCase() != 'dr')
      .toList();
  if (words.isEmpty) return '';
  final first = words.first[0];
  final last = words.length > 1 ? words.last[0] : '';
  return (first + last).toUpperCase();
}

/// The one doctor picture on every consult card (2026-09-30).
const String kTtcConsultCardArt = 'assets/doors/card_consult.jpg';

/// The word on a course's corner pill.
const String kTtcCourseEnroll = 'Enroll';

/// The key on a paid card's price tag.
Key ttcKindPriceKey(String title) => ValueKey('ttc-kind-price-$title');

class TtcShelfCard extends StatelessWidget {
  const TtcShelfCard({
    super.key,
    required this.tile,
    required this.kind,
    required this.p,
    required this.onTap,
    this.hue,
    this.width = kTtcShelfCardWidth,
    this.pictureHeight = kTtcShelfPictureHeight,
    this.playCircle = false,
    this.metaPrefix,
  });

  /// The card's width and picture height: a door shelf's by default; the All
  /// videos page draws the same card at the content width, 16:9 (2026-09-30).
  final double width;
  final double pictureHeight;

  /// A film's play mark as a black circle with a white triangle (the All
  /// videos page, the user: "a circle in which there is a play triangle",
  /// after pregnancy's This week explained) instead of Flo's bare triangle.
  final bool playCircle;

  /// Words before the grey line, e.g. the door a film belongs to.
  final String? metaPrefix;

  final TtcTile tile;
  final TtcCardKind kind;
  final V2Palette p;
  final VoidCallback onTap;

  /// The tab's hue, when the card sits on a door tab. ⚠️ A DRAWN CARD TAKES
  /// ITS TAB'S COLOUR, NOT ITS KIND'S (2026-09-29): with every read in the
  /// read blue a tab was a wall of blue; Flo colours a shelf, not a type. The
  /// grey line under the title says the kind now. Null: the kind's colour.
  final double? hue;

  Color get _ground => hue == null
      ? ttcCardKindWell(kind)
      : HSLColor.fromAHSL(1, hue! % 360, 0.52, 0.9).toColor();

  Color get _artTint => hue == null
      ? ttcCardKindArtTint(kind)
      : HSLColor.fromAHSL(1, hue! % 360, 0.6, 0.8).toColor();

  bool get _unmade => kind == TtcCardKind.video && ttcTileIsUnmadeFilm(tile);

  int? get _filmSeconds => switch (tile) {
    TtcVideoTile(:final slotId) when !_unmade => ttcVideoBySlot(
      slotId,
    )?.seconds,
    // The preview's made-up length (kTtcShelfFilmPreview).
    TtcVideoTile() when _unmade && kTtcShelfFilmPreview =>
      ttcShelfPreviewSeconds(tile.title),
    _ => null,
  };

  /// The photo, if this card shows one: never for a tool or a chat (they are
  /// shown as themselves), never where the photo misses the subject.
  String? get _photo {
    // A tool or a chat is drawn today (`ttcKindDrawsNoPhoto`); a photo given
    // to one later sits above its control bar, see [_toolPicture].
    if (ttcKindDrawsNoPhoto(kind)) return null;
    if (kTtcCardPhotoOff.contains(ttcTilePhotoId(tile))) return null;
    final url = photoForTile(tile);
    return url == null || url.isEmpty ? null : url;
  }

  Widget _drawn({Alignment align = Alignment.center, double size = 0.56}) {
    final mark = kTtcCardMarks[ttcTilePhotoId(tile)];
    return ColoredBox(
      key: ttcKindDrawingKey(tile.title),
      color: _ground,
      child: Align(
        alignment: align,
        child: FractionallySizedBox(
          widthFactor: size,
          heightFactor: size,
          child: mark != null
              ? TtcTabArt(mark: mark, tint: _artTint)
              : ttcKindCardDrawing(tile, kind, tint: _artTint),
        ),
      ),
    );
  }

  Widget _picture() {
    final url = _photo;
    // A film with no photo is its colour and the play mark alone: the
    // drawing under a triangle read as two pictures at once (build 23).
    //
    // ⚠️ UNDONE the same night: under Flo's veil a plain colour read as an
    // empty box, and Flo's own illustrated films keep the drawing under the
    // veil and the triangle. Kept for revert:
    //   if (url == null && kind == TtcCardKind.video && _filmSeconds != null) {
    //     return ColoredBox(key: ttcKindDrawingKey(tile.title), color: _ground);
    //   }
    // A carousel shows it is one: its first slide in front with the picture
    // and the slide's own title, two more behind (the user on build 23: the
    // deck "like we had before", at this card's size).
    // A wide film with no photo (All videos): its colour and the play circle
    // alone; the drawing under a 56pt circle read as two pictures at once.
    if (url == null && kind == TtcCardKind.video && playCircle) {
      return ColoredBox(key: ttcKindDrawingKey(tile.title), color: _ground);
    }
    if (kind == TtcCardKind.story) return _deck(url);
    if (kind == TtcCardKind.consult) return _person();
    if (kind == TtcCardKind.tool || kind == TtcCardKind.chat) {
      return _toolPicture(url);
    }
    if (url == null) return _drawn();
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: _ground),
        Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _drawn(),
        ),
      ],
    );
  }

  /// A tool's picture: the picture itself (its drawn mark today, a photo
  /// later) and one small white round badge in the bottom-right corner, the
  /// wrench for a tool and a speech bubble for a chat, where a film shows its
  /// length (2026-09-29, the user: "make visual representation easy, that
  /// also doesn't collide with an image added later").
  ///
  /// ⚠️ TWO TRIES BEFORE IT, THE SAME NIGHT. A slider (a thing you set) read
  /// as a video's progress bar ("as if a video is getting completed"); a
  /// full-width white control bar with a black arrow button, after Mobbin's
  /// tool cards (MacroFactor, Oura, Me+), was "a waste of space" that a photo
  /// added later would lose a third of. A corner badge costs the picture
  /// almost nothing. Kept for revert: git.
  Widget _toolPicture(String? url) {
    final chat = kind == TtcCardKind.chat;
    final deep = HSLColor.fromColor(_artTint).withLightness(0.36).toColor();
    return Stack(
      fit: StackFit.expand,
      children: [
        if (url != null)
          Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _drawn(),
          )
        else
          _drawn(),
        Positioned(
          key: ttcKindToolBarKey(tile.title),
          right: 7,
          bottom: 7,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              chat ? Icons.chat_bubble_outline_rounded : Icons.build_outlined,
              size: 16,
              color: deep,
            ),
          ),
        ),
      ],
    );
  }

  /// A consult's picture: the person, not a stethoscope (Mobbin: Alan's
  /// "Talk with our medical team" leads with faces,
  /// https://mobbin.com/screens/1d8e8577-abc5-4234-8d8e-ebdfd43eae92). No
  /// roster photo exists yet, so her initials in a white circle, which is
  /// true; a stock face would not be. A consult with no named person draws
  /// the doctor mark instead.
  Widget _person() {
    // ⚠️ ONE DOCTOR PICTURE (2026-09-30, the user on build 28: "for paid like
    // 1:1 in door take one doctor image and add it"). A doctor from the
    // shoulders down, no face: the card names a real roster person, and a
    // stranger's face beside her name would read as her photograph, the same
    // honesty line as the reviewers (docs/TTC-EXPERT-SIGNOFF.md). The image
    // lives in assets/doors/ (prompt in Downloads/door-hero-prompts); until
    // it is there, or if it fails, her initials as before.
    return Image.asset(
      kTtcConsultCardArt,
      key: ttcKindDrawingKey(tile.title),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _initialsPicture(),
    );
  }

  /// Her initials in a white circle: the consult picture before the doctor
  /// image (build 27), and its fallback.
  Widget _initialsPicture() {
    final who = ttcShelfPerson(tile);
    if (who == null) return _drawn();
    final deep = HSLColor.fromColor(_artTint).withLightness(0.34).toColor();
    return ColoredBox(
      key: ttcKindDrawingKey(tile.title),
      color: _ground,
      child: Align(
        alignment: const Alignment(0, -0.2),
        child: Container(
          width: 62,
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: _artTint, width: 3),
          ),
          child: Text(
            _initials(who),
            textScaler: TextScaler.noScaling,
            style: pvManrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: deep,
            ),
          ),
        ),
      ),
    );
  }

  /// The mark in the picture's bottom-right corner for a thing that costs
  /// money, where a film shows its length and a tool its wrench.
  ///
  /// ⚠️ NO PRICES ON THE PICTURE (2026-09-30, the user on build 28: "remove
  /// that price pill; for products just use the shopping bag; for
  /// masterclasses and paid courses, instead of the price something like
  /// Join now or Enroll, with a clock"). A product wears a bag, a course or
  /// masterclass an "Enroll" pill with a clock, and a consult nothing: its
  /// doctor picture already says what it is. The price is one tap in, on the
  /// page it opens. Kept for revert: the white price pill ("₹599", a bag
  /// before the price on a product) on consults, products and courses.
  Widget? _priceTag() {
    switch (kind) {
      case TtcCardKind.product:
        return Positioned(
          key: ttcKindPriceKey(tile.title),
          right: 7,
          bottom: 7,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(Icons.shopping_bag_outlined, size: 16, color: p.ink1),
          ),
        );
      case TtcCardKind.course:
        return Positioned(
          key: ttcKindPriceKey(tile.title),
          right: 7,
          bottom: 7,
          child: Container(
            padding: const EdgeInsets.fromLTRB(7, 4, 9, 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded, size: 13, color: p.ink1),
                const SizedBox(width: 4),
                Text(
                  kTtcCourseEnroll,
                  textScaler: TextScaler.noScaling,
                  style: pvManrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: p.ink1,
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return null;
    }
  }

  // Kept for revert (2026-09-30), the price pill:
  // Widget? _priceTagV1() {
  //   if (kind != TtcCardKind.consult && kind != TtcCardKind.product &&
  //       kind != TtcCardKind.course) return null;
  //   final price = ttcShelfPrice(tile);
  //   if (price == null) return null;
  //   return Positioned(right: 7, bottom: 7, child: <a white pill: a bag on a
  //     product, then the price in w800 ink>);
  // }

  /// The carousel's picture: a fanned deck (2026-09-29, the user on build
  /// 23: "initial image, then a few behind it drawn with a mark, the front
  /// image is what we put"; TheFork's fanned photos,
  /// https://mobbin.com/screens/91457673-4806-4064-81d0-ae6225b7689f). The
  /// front slide is the card's picture, photo or drawing, whole in its own
  /// white frame, so a real photo fits it as it is; two slides fan out behind
  /// it to the right, each with a drawn mark, so "more than one" reads at a
  /// glance. Kept for revert: the slide with its "1. title" words (git).
  Widget _deck(String? url) {
    final mark = kTtcCardMarks[ttcTilePhotoId(tile)];
    final Widget front = url != null
        ? Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => ColoredBox(color: _artTint),
          )
        : ColoredBox(
            color: _artTint.withValues(alpha: 0.45),
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.7,
                heightFactor: 0.7,
                child: mark != null
                    ? TtcTabArt(mark: mark, tint: _artTint)
                    : ttcKindCardDrawing(tile, kind, tint: _artTint),
              ),
            ),
          );
    Widget slide({required Widget child, double pad = 3}) => DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: child,
        ),
      ),
    );
    // A slide behind: the tint and a mark, drawn in its visible right part.
    Widget behind(TtcTabMark m, double depth) => slide(
      child: ColoredBox(
        color: _artTint.withValues(alpha: 0.30 + depth * 0.12),
        child: Align(
          alignment: const Alignment(0.95, 0),
          child: FractionallySizedBox(
            widthFactor: 0.36,
            heightFactor: 0.36,
            child: TtcTabArt(mark: m, tint: _artTint),
          ),
        ),
      ),
    );
    return ColoredBox(
      key: ttcKindDeckKey(tile.title),
      color: _ground,
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth, h = box.maxHeight;
          return Stack(
            children: [
              Positioned(
                left: w * 0.36,
                top: h * 0.15,
                width: w * 0.54,
                height: h * 0.70,
                child: Transform.rotate(
                  angle: 0.12,
                  child: behind(TtcTabMark.openBook, 0),
                ),
              ),
              Positioned(
                left: w * 0.26,
                top: h * 0.11,
                width: w * 0.56,
                height: h * 0.78,
                child: Transform.rotate(
                  angle: 0.05,
                  child: behind(TtcTabMark.lotus, 1),
                ),
              ),
              Positioned(
                left: w * 0.07,
                top: h * 0.08,
                width: w * 0.58,
                height: h * 0.84,
                child: Transform.rotate(
                  angle: -0.03,
                  child: slide(child: front),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = metaPrefix == null
        ? ttcShelfMeta(tile, kind)
        : '$metaPrefix · ${ttcShelfMeta(tile, kind)}';
    final seconds = _filmSeconds;
    return Semantics(
      button: true,
      label: '${tile.title}, $meta',
      excludeSemantics: true,
      child: PvPress(
        child: InkWell(
          key: ttcKindCardKey(kind, tile.title),
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: width,
                    height: pictureHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _picture(),
                        ?_priceTag(),
                        // ⚠️ A FILM IS KNOWN BY ITS PLAY BUTTON (the user,
                        // 2026-09-29: "with just a play button", as Flo), and
                        // only a film that plays has one (D3; the preview
                        // above bends that on purpose).
                        //
                        // FLO'S MARKS (the user on build 23): a bare white
                        // triangle, no disc, and the length in white at the
                        // foot, no pill. A drawn picture is pale, so a film
                        // drawn rather than photographed is dimmed a little,
                        // like a still, for the white to read. Kept for
                        // revert: a 42pt white disc with an ink triangle, and
                        // the length on a black pill.
                        if (kind == TtcCardKind.video && seconds != null) ...[
                          // FLO'S VEIL (the user on build 24, Flo's "Sex for
                          // pregnancy" shelf): the whole picture dimmed
                          // evenly, photo or drawing, so every film reads as
                          // a still and the white marks hold on any picture.
                          // Kept for revert: 0.22, on a drawn picture only.
                          ColoredBox(
                            color: Colors.black.withValues(alpha: 0.30),
                          ),
                          if (playCircle)
                            Center(
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  // The one black for what is pressable.
                                  color: ttcTitleInk,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.25),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 3),
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          else
                          const Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 52,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Color(0x66000000),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 9,
                            bottom: 7,
                            child: Text(
                              _clock(seconds),
                              key: ttcKindMetaKey(tile.title),
                              style: pvManrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ).copyWith(
                                shadows: const [
                                  Shadow(
                                    color: Color(0x80000000),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else if (kind == TtcCardKind.video)
                          Positioned(
                            right: 6,
                            bottom: 6,
                            child: Container(
                              key: ttcKindMetaKey(tile.title),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.62),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                kTtcFilmComingSoon,
                                style: pvManrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tile.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                    fontSize: _kShelfTitleSize,
                    height: _kShelfTitleLine,
                    fontWeight: FontWeight.w600,
                    color: p.ink1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  meta,
                  key: ttcKindPillKey(kind, tile.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                    fontSize: _kShelfMetaSize,
                    height: _kShelfMetaLine,
                    fontWeight: FontWeight.w500,
                    color: p.ink3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
