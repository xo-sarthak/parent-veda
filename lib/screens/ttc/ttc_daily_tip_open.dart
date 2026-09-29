// =============================================================================
//  Today's myth, nutrition and movement: a story and two reads, not sheets
// -----------------------------------------------------------------------------
//  The user, on the phone (2026-09-28): the myth ("Infertility is mostly a
//  woman's problem"), today's nutrition ("nimbu paani without sugar") and
//  today's movement ("take the stairs today") "only open pop-ups that come
//  from below. Not good UI, not a good way to give information. For myths vs
//  facts we already have the Instagram-story style, use that, consistency.
//  For tips like today's nutrition, it could be a read, an article."
//
//  So this file turns each one into a format the app already has:
//
//  · A MYTH IS A STORY. `TtcStoryScreen`, the deck every myth tile in the
//    doors opens, with the doors' own fallback shape: "What people say", then
//    "What's true". The seed's truth is usually two sentences, the fact and
//    what follows from it, so the second sentence onward is a third slide
//    rather than a paragraph squeezed under the second. One idea per slide,
//    the way story decks read (Ahead,
//    https://mobbin.com/screens/2f8bcfdc-49e6-475e-9422-cb90c74da52f;
//    Deepstash, https://mobbin.com/screens/4dbb8d3a-6d23-4ea8-b0e0-6084e5cb6521).
//
//  · A TIP IS A READ. `PvReaderScreen`, the one reader (CLAUDE.md, "One
//    reader"), built from the seed at the moment it is opened, the same
//    adapter shape as `ttc_insight_read.dart`. A short piece reads the way
//    Clue's content pages and Gymshark's tips do: a title, the point first,
//    a few lines, and somewhere to go next
//    (https://mobbin.com/screens/22db4de9-3bba-4906-909c-c239b32f90ca,
//    https://mobbin.com/screens/c390c08f-0360-4ae1-8da1-0e8be887433b).
//
//  ⚠️ NOTHING IS WRITTEN HERE THAT THE SEED DOES NOT SAY. Every clinical word
//  on these pages is the seed's, rearranged: the why becomes the short
//  answer, the Indian-kitchen line its paragraph, the movement's body its
//  steps. The only new words are labels ("What's true", "Good to know",
//  "Takes about 15 minutes") and the stage's one short-piece note. What makes
//  a two-line tip worth opening is the Read next rail: a longer library read
//  on the same subject, chosen per tip below.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import '../../ttc/ttc_daily_data.dart';
import '../../ttc/ttc_focus_data.dart' show TtcCarouselCard;
import '../../ttc/ttc_insight_read.dart' show kTtcShortPieceCallout;
import '../../ttc/ttc_practice_data.dart' show TtcPractice, ttcPracticeById;
import '../../ttc/ttc_reads_data.dart' show ttcReadById;
import '../reader/pv_reader_screen.dart';
import 'ttc_story_screen.dart';
import 'ttc_strings.dart';
import 'ttc_surface_router.dart' show openTtcSurface, kTtcReadPrefix;

// ---- the words -------------------------------------------------------------

/// The three slide headings of a daily myth. The first two are the doors'
/// fallback words (`ttc_focus_screen.dart`, `TtcMythTile`), so a myth reads
/// the same wherever she meets one.
const String kTtcMythSaySlide = 'What people say';
const String kTtcMythTrueSlide = "What's true";
const String kTtcMythMoreSlide = 'Worth knowing';

/// The kickers over a tip read: the rail card's own eyebrow, in words.
const String kTtcNutritionKicker = "Today's nutrition";
const String kTtcMovementKicker = "Today's movement";

/// The heading over a nutrition read's Indian-kitchen line.
const String kTtcNutritionMoreHeading = 'Good to know';

/// The route a tip read is pushed on.
const String kTtcTipRoute = 'ttc/tip';

/// The id a tip carries as a read.
const String kTtcNutritionReadPrefix = 'ttc_nutrition_';
const String kTtcMovementReadPrefix = 'ttc_movement_';

// ---- where each tip leads ----------------------------------------------------

/// The library read a nutrition tip is the short version of. Ids only; one
/// that does not resolve is left off the rail, never shown as a dead tile.
const Map<String, String> kTtcNutritionReads = {
  'folate_greens': 'ttc_read_folic_acid',
  'iron_bajra': 'ttc_read_iron_before_pregnancy',
  'omega3': 'ttc_read_omega3_without_fish',
  'protein_dal': 'ttc_read_meal_plan_week',
  'vitamin_d_food': 'ttc_read_supplement_timing',
  'zinc_male': 'ttc_read_zinc_coq10',
  'whole_grains': 'ttc_read_pcos_insulin',
  'hydration': 'ttc_read_meal_plan_week',
  'antioxidants': 'ttc_read_meal_plan_week',
  'less_processed': 'ttc_read_what_to_cut',
  'b12': 'ttc_read_supplement_timing',
  'coq10': 'ttc_read_zinc_coq10',
};

/// The second tile on every nutrition read, so the rail always has two.
const String kTtcNutritionFallbackRead = 'ttc_read_everyday_recipes';

/// The library read a movement tip leads to.
const Map<String, String> kTtcMovementReads = {
  'walk_after_dinner': 'ttc_read_pcos_insulin',
  'supta_baddha': 'ttc_read_stress_fertility',
  'strength_twice': 'ttc_read_weight_kindly',
  'hip_stretch': 'ttc_read_three_months',
  'rest_day': 'ttc_read_sleep_trying',
  'legs_up_wall': 'ttc_read_timing_myths',
  'walk_together': 'ttc_read_keeping_close',
  'pelvic_floor': 'ttc_read_three_months',
  'stairs': 'ttc_read_three_months',
  'cat_cow': 'ttc_read_stress_fertility',
  'morning_sun': 'ttc_read_sleep_trying',
  'gentle_flow': 'ttc_read_heat_habits',
};

/// The second tile on every movement read.
const String kTtcMovementFallbackRead = 'ttc_read_three_months';

// ---- pure helpers -------------------------------------------------------------

/// [text] split after its first sentence: `(first, rest)`, rest empty when
/// there is only one. A full stop, question or exclamation mark followed by
/// a space and a capital (or an opening quote) ends a sentence, so "per
/// cent" and "0.5" never split.
(String, String) ttcSplitFirstSentence(String text) {
  final t = text.trim();
  final m = RegExp(r'''[.!?]\s+(?=["'A-Z])''').firstMatch(t);
  if (m == null) return (t, '');
  return (t.substring(0, m.start + 1).trim(), t.substring(m.end).trim());
}

/// [s] without a closing full stop, for a title.
String _asTitle(String s) {
  final t = s.trim();
  return t.endsWith('.') ? t.substring(0, t.length - 1) : t;
}

/// "iron", "whole grains", but "Vitamin D", "Omega-3", "CoQ10" as written.
String _nutrientInLine(String n) {
  if (n.isEmpty) return n;
  final keepsCase = RegExp(r'[A-Z0-9]').hasMatch(n.substring(1));
  return keepsCase ? n : n[0].toLowerCase() + n.substring(1);
}

/// Up to two resolving read ids, the paired one first, never twice.
List<String> _rail(String? paired, String fallback) => [
      for (final id in {?paired, fallback})
        if (ttcReadById(id) != null) id,
    ];

// ---- the myth, as a story -------------------------------------------------------

/// The slides of a daily myth: what people say, what is true, and, when the
/// truth runs to a second sentence, what follows from it.
List<TtcCarouselCard> ttcMythSlides(TtcMyth myth, bool hi) {
  final (fact, more) = ttcSplitFirstSentence(myth.truth(hi));
  return [
    TtcCarouselCard(title: kTtcMythSaySlide, body: myth.myth(hi)),
    TtcCarouselCard(title: kTtcMythTrueSlide, body: fact),
    if (more.isNotEmpty) TtcCarouselCard(title: kTtcMythMoreSlide, body: more),
  ];
}

/// Opens today's myth in the story deck, on the route the doors' myths use
/// (and the one the Ask button stands aside for).
///
/// ⚠️ THE SAME LABELLED COVER AS A DOOR MYTH (launch sanity H8, 2026-09-28).
/// The home's myth opened on a "What people say" slide and put the answer
/// one swipe away, while every door myth now opens on a cover with a
/// labelled MYTH block and a labelled FACT block (D4, D14). One chip, one
/// shape: the cover carries the myth and the first sentence of the truth,
/// and the rest of the truth, when there is more, follows as "Worth
/// knowing", so every word is still on a slide and none is said twice.
void openTtcMythStory(BuildContext context, TtcMyth myth, bool hi) {
  final (fact, more) = ttcSplitFirstSentence(myth.truth(hi));
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: 'ttc/story'),
    builder: (_) => TtcStoryScreen(
      title: TtcS.current().todaysMyth,
      // Kept for revert (2026-09-28): cards: ttcMythSlides(myth, hi),
      cards: [
        if (more.isNotEmpty)
          TtcCarouselCard(title: kTtcMythMoreSlide, body: more),
      ],
      hue: 42,
      reviewedBy: 'ParentVeda team',
      coverTitle: TtcS.current().todaysMyth,
      myth: myth.myth(hi),
      fact: fact,
    ),
  ));
}

// ---- the tips, as reads -----------------------------------------------------------

/// Today's nutrition as a read: the meal is the title, why it helps is the
/// short answer, the Indian-kitchen line is the body.
PvRead ttcNutritionAsRead(TtcNutrition n) {
  final nutrientEn = _nutrientInLine(n.nutrientEn);
  final nutrientHi = _nutrientInLine(n.nutrientHi);
  return PvRead(
    id: kTtcNutritionReadPrefix + n.id,
    kicker: const LocalizedText(en: kTtcNutritionKicker, hi: kTtcNutritionKicker),
    title: LocalizedText(en: _asTitle(n.mealEn), hi: _asTitle(n.mealHi)),
    teaser: LocalizedText(
        en: "Today's food idea: $nutrientEn.",
        hi: "Today's food idea: $nutrientHi."),
    shortAnswer: LocalizedText(en: n.whyEn, hi: n.whyHi),
    // Required by the model; the reader leaves it out under a short answer.
    scaleSetter: LocalizedText(en: n.whyEn, hi: n.whyHi),
    author: const LocalizedText(en: 'ParentVeda team', hi: 'ParentVeda team'),
    authorRole: const LocalizedText(en: 'Daily tip', hi: 'Daily tip'),
    reviewed: false,
    hue: 104,
    sections: [
      PvReadSection(
        heading: const LocalizedText(
            en: kTtcNutritionMoreHeading, hi: kTtcNutritionMoreHeading),
        paragraphs: [LocalizedText(en: n.indianEn, hi: n.indianHi)],
      ),
    ],
    whenToSeeSomeone: kTtcShortPieceCallout,
    faqs: const [],
    readNext: _rail(kTtcNutritionReads[n.id], kTtcNutritionFallbackRead),
  );
}

/// "Takes about 15 minutes", or, on a rest day, that there is nothing to set
/// time aside for.
String ttcMovementTime(int minutes) => minutes > 0
    ? 'Takes about $minutes minutes.'
    : 'Nothing to set time aside for today.';

/// The heading over a practice's steps, and its way into the player.
// Kept for revert (2026-09-28): 'How to do it', 'Start it with the timer'.
// A heading and a card title name the thing, never "it".
const String kTtcTipHowHeading = 'The steps, one by one';
const String kTtcTipStartTitle = 'Start the steps with a timer';
const String kTtcTipStartValue =
    'The steps one at a time, with a timer, and a tick when you finish.';

/// Today's movement as a read: its first sentence is the short answer, the
/// rest is the body.
///
/// ⚠️ A PRACTICE READS AS A TIP, NOT AS AN ARTICLE (the user on build 16,
/// 2026-09-28: "it isn't a 3 min read, it's way less… it says daily tip").
/// Since the rail's movement became today's practice (launch sanity MB18), the
/// blurb and every step were run together into one paragraph under an
/// article's byline. A practice now reads the way Headspace and Calm show one
/// before you start: what it is and how long it takes on top, the steps as a
/// numbered list, and one way into the player that times them.
PvRead ttcMovementAsRead(TtcMovement m) {
  final practice = ttcPracticeById(m.id);
  if (practice != null) return ttcPracticeAsTipRead(practice);
  final (firstEn, restEn) = ttcSplitFirstSentence(m.bodyEn);
  final (firstHi, restHi) = ttcSplitFirstSentence(m.bodyHi);
  final time = ttcMovementTime(m.minutes);
  return PvRead(
    id: kTtcMovementReadPrefix + m.id,
    kicker: const LocalizedText(en: kTtcMovementKicker, hi: kTtcMovementKicker),
    title: LocalizedText(en: m.titleEn, hi: m.titleHi),
    teaser: LocalizedText(en: time, hi: time),
    shortAnswer: LocalizedText(en: firstEn, hi: firstHi),
    scaleSetter: LocalizedText(en: firstEn, hi: firstHi),
    author: const LocalizedText(en: 'ParentVeda team', hi: 'ParentVeda team'),
    authorRole: const LocalizedText(en: 'Daily tip', hi: 'Daily tip'),
    reviewed: false,
    hue: 160,
    sections: [
      if (restEn.isNotEmpty)
        PvReadSection(paragraphs: [
          LocalizedText(en: restEn, hi: restHi.isEmpty ? restEn : restHi),
        ]),
    ],
    whenToSeeSomeone: kTtcShortPieceCallout,
    faqs: const [],
    readNext: _rail(kTtcMovementReads[m.id], kTtcMovementFallbackRead),
  );
}

/// A practice from the library as a daily tip: the blurb is the short answer,
/// its steps are a numbered list, and the next step starts the player.
PvRead ttcPracticeAsTipRead(TtcPractice p) {
  LocalizedText en(String s) => LocalizedText(en: s, hi: s);
  final time = '${p.duration} · ${p.setting}';
  return PvRead(
    id: kTtcMovementReadPrefix + p.id,
    kicker: en(kTtcMovementKicker),
    title: en(p.title),
    teaser: en(time),
    shortAnswer: en(p.blurb),
    scaleSetter: en(time),
    author: en('ParentVeda team'),
    authorRole: en('Daily tip'),
    reviewed: false,
    hue: 160,
    sections: [
      PvReadSection(
        heading: en(kTtcTipHowHeading),
        paragraphs: [en(time)],
        bullets: [
          for (var i = 0; i < p.steps.length; i++) en('${i + 1}. ${p.steps[i]}'),
        ],
      ),
    ],
    whenToSeeSomeone: kTtcShortPieceCallout,
    faqs: const [],
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: en(kTtcTipStartTitle),
        value: en(kTtcTipStartValue),
        surfaceId: 'ttc_practice/${p.id}',
      ),
    ],
    readNext: _rail(kTtcMovementReads[p.id], kTtcMovementFallbackRead),
  );
}

/// Opens a tip read in the one reader. Its Read next tiles are library reads
/// and open through the router like every other read.
void openTtcTipRead(BuildContext context, PvRead read) {
  final lang =
      TtcLang.instance.hinglish ? AppLanguage.hinglish : AppLanguage.english;
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kTtcTipRoute),
    builder: (_) => PvReaderScreen(
      read: read,
      lang: lang,
      resolveRead: ttcReadById,
      readTitle: (id) => ttcReadById(id)?.title,
      openRead: (ctx, id) {
        if (ttcReadById(id) != null) openTtcSurface(ctx, '$kTtcReadPrefix$id');
      },
      openSurface: openTtcSurface,
    ),
  ));
}
