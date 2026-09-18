// =============================================================================
//  PvRead — the app's long-form reading model, stage-neutral
// -----------------------------------------------------------------------------
//  THE FIFTH READER'S MODEL, and the reason there is a fifth.
//
//  Four readers already exist and each is half-right:
//
//    · `reading_reader_screen.dart` (parenting, 568 lines) has the best READING
//      EXPERIENCE in the product — progress, table of contents, font scale,
//      light/sepia/dark, bookmark, resume-where-you-left-off, inline tips,
//      myth-vs-fact, an evidence note, a read-next chain. It is also welded to
//      parenting: `ppBg` is baked into its light theme, its video block is a
//      bespoke `PpStriped` rather than the app's placeholder, and its model is
//      bare `String` with `ageTag` and `relatedRecipeId` on it.
//    · `article_reader_screen.dart` (parenting) has a cover and a byline and
//      none of the six reading features. Handed a null article it silently
//      renders a sleep piece.
//    · `mm_article_screen.dart` is in the correct V3 language and is bilingual,
//      but its body is ONE STRING split on `\n\n` — no headings, so no table of
//      contents and no way to reach real depth.
//    · `bs_article_screen.dart` is the most architecturally correct — V3
//      language, `PvVideoPlaceholder`, products through `SolutionCard` — and
//      hardcodes `const _lang = AppLanguage.english` on a bilingual model.
//
//  The pattern, stated once: **the two with the best reading experience are in
//  the wrong design language, and the two in the right design language have the
//  weakest reading experience.** Nobody has both. This model + `PvReaderScreen`
//  take the feature set from the first and the design language from the last.
//
//  ---------------------------------------------------------------------------
//  ⚠️ `LocalizedText`, NOT `String`, EVEN THOUGH WE ARE SHIPPING ENGLISH FIRST
//  ---------------------------------------------------------------------------
//
//  This is the one decision worth defending, because the instruction was
//  "English first, don't worry about Hindi" and this looks like ignoring it.
//
//  It is not. Every string below renders English today. The wrapper costs one
//  `_en(...)` at the call site and nothing at runtime.
//
//  What it buys is the migration we have already failed twice:
//
//    · `ReadArticle` (parenting) chose bare `String`. It is now read by
//      `pp_home_v3`, `my_child_screen`, `pp_reco_data`, `brand_campaigns`,
//      `veda_index` and five reading screens. Widening it is a nine-file change
//      nobody has been willing to start.
//    · `WeekArticle` chose bare `String`, hit the same wall, and bolted
//      `titleHi`/`bodyHi` on beside it. Its own header says "English for now -
//      a prototype; can move to LocalizedText later." That was months ago.
//
//  Per CLAUDE.md the greppable form of "English now, Hindi owed" is `_en(...)`,
//  so `grep -c '_en('` over the reads data IS the size of the backlog. A bare
//  `String` is not greppable as debt — it just looks finished.
//
//  ⚠️ NEVER `_t(x, x)` for a string that merely has no translation yet. An
//  identical pair reads as completed work to every audit, which is how
//  `can_i_data` was once reported done with 302 strings still English.
//  `_same(...)` is for things identical BY NATURE — PCOS, IVF, AMH.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../localization/app_language.dart';

// -----------------------------------------------------------------------------
//  The inline furniture
// -----------------------------------------------------------------------------

/// A ParentVeda Tip — the aside that earns its interruption.
///
/// Collapsed to its title by default. The parenting reader proved the shape:
/// an always-open tip box every third paragraph turns a read into a leaflet,
/// and the reader stops seeing them at all.
@immutable
class PvReadTip {
  const PvReadTip({required this.title, required this.body});
  final LocalizedText title;
  final LocalizedText body;
}

/// Myth on the left, what is actually true on the right.
///
/// ⚠️ THE MOST USEFUL SINGLE COMPONENT IN A FERTILITY ARTICLE, which is why it
/// is in the model rather than being spelled out in prose. This stage's content
/// is competing with a very large volume of confident nonsense, and the answer
/// to "lie down for twenty minutes after" is not a paragraph — it is two
/// columns, one of which says "no evidence".
@immutable
class PvMythFact {
  const PvMythFact({required this.myth, required this.fact});
  final LocalizedText myth;
  final LocalizedText fact;
}

/// The tone of a [PvCallout]. Drives colour and icon, nothing else.
enum PvCalloutTone {
  /// Neutral emphasis — "the number worth remembering".
  note,

  /// Reassurance. The commonest tone in this stage and deliberately first-class:
  /// "most women with this go on to conceive" is a clinical fact, not a
  /// decoration, and burying it in a paragraph wastes it.
  reassure,

  /// ⚠️ Pick up the phone. Never used decoratively — see the assertion in
  /// `PvRead.assertShape`.
  urgent,
}

/// A boxed line that must not be missed.
@immutable
class PvCallout {
  const PvCallout(
      {required this.tone, required this.title, required this.body});
  final PvCalloutTone tone;
  final LocalizedText title;
  final LocalizedText body;
}

/// The one when-to-ask line a SHORT piece carries when nobody wrote one for
/// it — a daily insight, a parenting page with no doctor line of its own.
///
/// ⚠️ `whenToSeeSomeone` stays REQUIRED on the model (CLAUDE.md: anything
/// clinical ends by routing calmly to a doctor), and this is how an adapter
/// meets that without inventing clinical text: one honest, quiet sentence —
/// general, not about you; your clinic knows your case. `note` tone, so it
/// renders inline between hairlines, not as the urgent well. Hand-written
/// reads must not use it; `assertShape` still demands the urgent tone there.
const PvCallout kPvShortPieceCallout = PvCallout(
  tone: PvCalloutTone.note,
  title: LocalizedText(
      en: 'A general note, not advice about you',
      hi: 'Aam baat, aapke baare mein salah nahi'),
  body: LocalizedText(
      en: 'Nothing here is written with your history in front of it. If '
          'anything worries you, or a clinic is already looking after you, '
          'ask them — they know your case and this page does not.',
      hi: 'Yahan kuch bhi aapki history dekh kar nahi likha gaya. Agar kuch '
          'pareshan kare, ya koi clinic pehle se aapko dekh raha hai, unse '
          'poochhein — wo aapka case jaante hain, ye page nahi.'),
);

/// A question and its answer, at the foot of the read.
@immutable
class PvReadFaq {
  const PvReadFaq({required this.question, required this.answer});
  final LocalizedText question;
  final LocalizedText answer;
}

// -----------------------------------------------------------------------------
//  A section
// -----------------------------------------------------------------------------

/// One section of a read: a heading, prose, and optional furniture.
///
/// ⚠️ THE HEADING IS WHAT MAKES A TABLE OF CONTENTS POSSIBLE, and the table of
/// contents is what makes a 2,500-word piece survivable on a phone. This is the
/// single thing `MmArticleScreen` gave up by storing its body as one string,
/// and it is why that reader can never carry a piece of real depth.
@immutable
class PvReadSection {
  const PvReadSection({
    this.heading,
    this.paragraphs = const [],
    this.bullets = const [],
    this.tip,
    this.mythFact,
    this.callout,
    this.videoSlot,
    this.collapsible = false,
    this.summary,
    this.custom,
  });

  /// A block the reader does not model, owned and rendered by the stage that
  /// wrote it — a parenting table, a chart card, a script, a consult offer.
  ///
  /// ⚠️ OPAQUE HERE, ON PURPOSE. The model stays widget-free and stage-free:
  /// it carries the block as an `Object`, and `PvReaderScreen.customBlock`
  /// is the seam through which the stage turns it back into its own widget
  /// (`PpBlockView` for parenting). This is what lets a parenting page with
  /// a wake-windows table read in the one article format without the table
  /// being rewritten as prose or the reader learning what a table is. A
  /// section carrying a custom block usually carries nothing else; the
  /// reader renders it after any heading and paragraphs it does have.
  final Object? custom;

  /// Null for the opening section, which runs straight on from the teaser.
  final LocalizedText? heading;

  final List<LocalizedText> paragraphs;

  /// Dot lines. For genuine lists — symptoms, what a test measures — never as a
  /// way to avoid writing sentences.
  final List<LocalizedText> bullets;

  final PvReadTip? tip;
  final PvMythFact? mythFact;
  final PvCallout? callout;

  /// Starts closed, showing only its heading and [summary].
  ///
  /// ⚠️ THE AUTHOR DECIDES, NOT THE SCREEN, and that is the whole design of
  /// this flag. Collapsing every section would turn a piece of writing into a
  /// FAQ and break the argument — a reader who has to open five boxes to follow
  /// one line of reasoning has been given a filing cabinet, not an article.
  /// Collapsing nothing leaves a clinical explainer at a length that reads as
  /// homework on a phone.
  ///
  /// So the rule is: **the spine of the argument stays open; reference material
  /// folds.** "Why your cycle became hard to read" is the argument. "The
  /// supplements you will be sold" is a lookup she may not need today. Only the
  /// person writing the piece knows which is which.
  final bool collapsible;

  /// The one line shown while a collapsible section is closed.
  ///
  /// ⚠️ REQUIRED IN SPIRIT WHEN [collapsible] IS TRUE — a closed box showing
  /// only a heading is a door with no label, and she has to open it to find out
  /// whether she wanted it. That is worse than the length it saved.
  /// `assertShape` enforces it.
  final LocalizedText? summary;

  /// A video that belongs at THIS point in the argument.
  ///
  /// The parenting reader drops its one video at `(sections.length - 1) ~/ 2`
  /// — the arithmetic middle, regardless of what the middle happens to be
  /// saying. Placing it on the section instead means the video sits where it is
  /// relevant, and a read with nothing to show simply has none.
  final String? videoSlot;

  /// Every word this section actually renders.
  ///
  /// ⚠️ THE FURNITURE COUNTS, and leaving it out was a measurement bug rather
  /// than a strict standard. The first version counted only paragraphs and
  /// bullets, and then failed `ttc_read_timing_myths` at 347 words — a piece
  /// whose entire substance is four myth-and-correction blocks and two tips,
  /// none of which were being counted. It was not thin; the ruler was wrong.
  ///
  /// A `PvMythFact` is sixty words of authored prose that the reader displays
  /// at reading size. Anything in that category is writing, and an article made
  /// mostly of it can be excellent — excluding it would have quietly pushed
  /// every author towards paragraphs and away from the component that is most
  /// useful on a page competing with confident nonsense.
  int get _words {
    int count(String s) => s.trim().isEmpty ? 0 : s.split(RegExp(r'\s+')).length;
    return [
      for (final p in paragraphs) count(p.en),
      for (final b in bullets) count(b.en),
      if (summary != null) count(summary!.en),
      if (tip != null) ...[count(tip!.title.en), count(tip!.body.en)],
      if (mythFact != null) ...[count(mythFact!.myth.en), count(mythFact!.fact.en)],
      if (callout != null) ...[count(callout!.title.en), count(callout!.body.en)],
    ].fold(0, (a, b) => a + b);
  }
}

// -----------------------------------------------------------------------------
//  The read
// -----------------------------------------------------------------------------

/// One long-form read.
///
/// ⚠️ THREE FIELDS ARE REQUIRED THAT A BLOG POST WOULD NOT HAVE, and they are
/// the whole anti-shallowness mechanism. `docs/BRACKET-SCREEN.md`'s conditions
/// page proved that a fixed required order is what forces depth: a rare
/// condition still walks all eight parts, it just says less in each. A free-form
/// section list alone lets a thin piece look finished.
///
/// So: [scaleSetter], [whenToSeeSomeone] and [faqs] are required on every read,
/// and [sections] carries the argument in between. A piece that cannot answer
/// "how worried should I be" and "when do I call someone" is not ready to ship,
/// and now it will not compile.
@immutable
class PvRead {
  const PvRead({
    required this.id,
    required this.kicker,
    required this.title,
    required this.teaser,
    required this.scaleSetter,
    required this.author,
    required this.authorRole,
    required this.hue,
    required this.sections,
    required this.whenToSeeSomeone,
    required this.faqs,
    this.evidence,
    this.heroVideoSlot,
    this.relatedVideoSlots = const [],
    this.readNext = const [],
    this.nextSteps = const [],
    this.imageUrl,
    this.reviewed = true,
  });

  /// Whether a named clinician stands behind the piece — true for every
  /// hand-written read (their `authorRole` names the reviewer and the month).
  /// False for pieces the adapters build from editorial seeds (a daily
  /// insight), where the byline is the desk and the verified mark would be a
  /// claim nobody made. The reader keys the eyebrow and the mark on it.
  final bool reviewed;

  /// The picture above the masthead, and on this read's card wherever it is
  /// offered (a Read next tile, a door rail).
  ///
  /// ⚠️ ON THE READ, NOT ON THE TILE — 2026-09-17. The first picture-led
  /// article kept its URL on the door tile that opened it, so the same piece
  /// opened from a journey step or another article's Read next had no
  /// picture. The user's rule now: every article has an image on top. The
  /// reader draws this when the caller passes no `hero`; a null renders the
  /// tinted band with the article mark in the same 132-pt frame, so the page
  /// keeps its shape whether or not the picture has been chosen yet — and
  /// `docs/DOOR-CONTENT-OWED.md` lists the ones that have not.
  final String? imageUrl;

  final String id;

  /// The eyebrow — which bracket this belongs to. "PCOS", "IVF & IUI".
  final LocalizedText kicker;

  final LocalizedText title;

  /// The standfirst, set in italic serif under the title. One sentence on what
  /// the piece will do for her.
  final LocalizedText teaser;

  /// ⚠️ REQUIRED, AND IT RENDERS BEFORE THE FIRST SECTION.
  ///
  /// "How worried should I be" is the question she actually arrived with, and
  /// the conditions page learned this the expensive way: a definition first and
  /// reassurance at the bottom means the reassurance is read by nobody, because
  /// frightened people do not scroll. Scale first, then detail.
  final LocalizedText scaleSetter;

  final LocalizedText author;
  final LocalizedText authorRole;

  /// Tint for the cover and the type chips, off the controlled wheel. Matches
  /// the bracket's own hue so a read opened from a door keeps its colour.
  final double hue;

  final List<PvReadSection> sections;

  /// ⚠️ REQUIRED. Every clinical read in this app ends by routing calmly to a
  /// doctor — CLAUDE.md, "never a diagnosis". Making it a required field means
  /// the disclaimer cannot be the thing that got left off.
  final PvCallout whenToSeeSomeone;

  /// ⚠️ REQUIRED, minimum enforced by [assertShape]. The FAQ is where the
  /// questions she was too embarrassed to type go.
  final List<PvReadFaq> faqs;

  /// Where this came from, in plain words — "NICE fertility guideline CG156;
  /// ESHRE 2023". Rendered visibly at the foot, not buried.
  ///
  /// ⚠️ NAMED BODIES, NEVER "studies show". An unsourced claim in a fertility
  /// article is indistinguishable from the content this product exists to
  /// replace.
  final LocalizedText? evidence;

  /// The video slot that sits under the hero, if this read leads with one.
  final String? heroVideoSlot;

  /// The rail at the foot.
  final List<String> relatedVideoSlots;

  /// Other read ids, for the chain onward.
  final List<String> readNext;

  /// Surface ids this read should hand her to when she is done — the cycle
  /// tool, supplements, a consult. Rendered as `SolutionCard`s, the same
  /// component the hubs use, so a tool offered here reads as the same kind of
  /// thing as a tool offered anywhere.
  final List<PvReadNextStep> nextSteps;

  /// Every heading, for the table of contents.
  List<LocalizedText> get toc =>
      [for (final s in sections) if (s.heading != null) s.heading!];

  /// Reading time from the words actually written, at ~200 wpm.
  ///
  /// ⚠️ COMPUTED, NOT DECLARED, and `TtcInsight` already learned why: every
  /// insight in that file inherited a default of 45 seconds, so a sixty-word
  /// piece and a three-hundred-word one both claimed the same length. A number
  /// nobody updates when the copy changes is worse than no number.
  int get minutes {
    final words = sections.fold<int>(0, (a, s) => a + s._words) +
        faqs.fold<int>(
            0,
            (a, f) =>
                a +
                f.question.en.split(RegExp(r'\s+')).length +
                f.answer.en.split(RegExp(r'\s+')).length);
    return (words / 200).ceil().clamp(1, 60);
  }

  /// Total words — used by the depth test rather than by the UI.
  int get wordCount => sections.fold<int>(0, (a, s) => a + s._words);

  /// The shape rules, in one place, asserted by `test/pv_read_shape_test.dart`.
  ///
  /// Returns the reasons this read is not ready, empty when it is. A LIST
  /// rather than a bool because "this read is malformed" is useless to whoever
  /// has to fix it — the failure has to name which rule and which read.
  List<String> assertShape() {
    final out = <String>[];
    if (sections.length < 4) {
      out.add('$id: ${sections.length} sections, needs at least 4');
    }
    if (toc.length < 3) {
      out.add('$id: ${toc.length} headings, needs at least 3 for a contents');
    }
    if (faqs.isEmpty) out.add('$id: no FAQ');
    if (wordCount < 600) out.add('$id: $wordCount words, thin');
    if (evidence == null) out.add('$id: no evidence note');
    if (whenToSeeSomeone.tone != PvCalloutTone.urgent) {
      out.add('$id: whenToSeeSomeone must carry the urgent tone');
    }
    for (final s in sections) {
      if (s.collapsible && s.heading == null) {
        out.add('$id: a collapsible section with no heading has no handle');
      }
      if (s.collapsible && (s.summary?.en.trim().isEmpty ?? true)) {
        out.add('$id: collapsible "${s.heading?.en}" has no summary — a closed '
            'box with only a heading is a door with no label');
      }
    }
    // ⚠️ THE ARGUMENT MUST SURVIVE WITH EVERYTHING SHUT. If more than half the
    // sections fold, the open remainder is no longer a piece of writing — it is
    // a contents page, and she has to open boxes to find the reasoning. Folding
    // is for reference material, not for the spine.
    final folded = sections.where((s) => s.collapsible).length;
    if (folded * 2 > sections.length) {
      out.add('$id: $folded of ${sections.length} sections fold — the argument '
          'no longer reads with everything closed');
    }
    return out;
  }
}

/// A thing to do next, at the foot of a read.
@immutable
class PvReadNextStep {
  const PvReadNextStep({
    required this.kind,
    required this.title,
    required this.value,
    this.surfaceId,
    this.action,
  });

  /// Mirrors `SolutionType` by name so the reader can hand it straight to
  /// `SolutionCard` without inventing a second vocabulary. Kept as its own enum
  /// only so `models/` does not import from `screens/`.
  final PvNextKind kind;

  final LocalizedText title;

  /// ⚠️ REQUIRED, same rule as `JourneyElement.value`: one line on why it is
  /// worth her time. An element with a title and no reason is a link, and a
  /// list of links is the catalogue this whole restructure replaced.
  final LocalizedText value;

  final String? surfaceId;
  final String? action;
}

// `ask` — 2026-09-19: a step that opens Ask Veda wore the ARTICLE chip,
// which the user called misleading. It wears its own name now.
enum PvNextKind { read, watch, tool, activity, product, course, consult, ask }
