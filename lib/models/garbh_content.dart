// =============================================================================
//  Garbh Sanskar Journey - content models
// -----------------------------------------------------------------------------
//  Four pillars, four content shapes:
//    Shravan  → GarbhAudio    (Spotify-like listening)
//    Vichara  → GarbhStory    (Kindle-like reflective reading)
//    Kriya    → GarbhPractice (Headspace-like guided breathing, with phases)
//    Samvad   → GarbhPrompt   (Memory-Vault-like womb connection prompts)
//
//  English-first plain strings (this is a calm, content-light experience; Hindi
//  can be layered later). Audio files are placeholders for now - the player uses
//  the bundled drone until real recordings are added.
// =============================================================================

import 'package:flutter/material.dart';
import '../localization/app_language.dart';
import 'breath_pattern.dart';

/// Shravan sub-kinds (just for the small label/icon).
enum GarbhKind { raga, nature, guided }

@immutable
class GarbhAudio {
  const GarbhAudio({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.minutes,
    required this.kind,
    this.asset,
  });
  final String id;
  final LocalizedText title;
  final LocalizedText subtitle;
  final String emoji;
  final int minutes;
  final GarbhKind kind;

  /// ⚠️ THE FILE THIS RAGA ACTUALLY PLAYS. Null means the shared placeholder.
  ///
  /// Ten named ragas currently point at one bundled twelve-second tanpura
  /// loop, because no real recordings exist yet. That is not a code problem
  /// and it will not be fixed by code - it needs audio.
  ///
  /// What this field buys is that fixing it stops being a code change at all.
  /// Drop a file on R2, put its path here, and that raga plays its own
  /// recording; everything else - the player, the completion hook, the journal
  /// entry it writes - already works. Without the field, every real file would
  /// mean editing the player.
  ///
  /// ⚠️ AND IT IS NULLABLE RATHER THAN DEFAULTED TO THE DRONE, so the UI can
  /// tell the difference. A screen that cannot see which ragas are real cannot
  /// stop telling a mother that a tanpura is ocean waves.
  final String? asset;

  /// True once this raga has a recording of its own.
  bool get hasRealAudio => asset != null;
}

@immutable
class GarbhStory {
  const GarbhStory({
    required this.id,
    required this.theme,
    required this.title,
    required this.blurb,
    required this.body,
    required this.reflection,
    this.minutes = 3,
  });
  final String id;
  final LocalizedText theme; // "Curiosity", "Patience", …
  final LocalizedText title;
  final LocalizedText blurb; // one-line description on the card
  final LocalizedText body; // the reflection itself
  final LocalizedText reflection; // closing question
  final int minutes;
}

/// One step of a breathing practice. [scale] is the target size of the breathing
/// circle at the END of this phase (1.0 = full inhale, ~0.5 = full exhale).
@immutable
class BreathPhase {
  const BreathPhase(this.label, this.seconds, this.scale);
  final LocalizedText label; // "Breathe in", "Hold", "Breathe out", "Rest"
  final int seconds;
  final double scale;
}

/// The practice's phases as the shared circle reads them.
///
/// ⚠️ THE KIND IS INFERRED FROM THE SCALE SEQUENCE, so the data files do not
/// change: a phase whose scale is larger than the one before it is an
/// in-breath, smaller is an out-breath, the same is a hold — large or empty.
/// `.now` on the label because the label is DISPLAY, the word on the screen
/// in her language; nothing keys on it.
extension GarbhPracticeBreath on GarbhPractice {
  BreathPattern toBreathPattern() {
    final steps = <BreathStep>[];
    var prev = phases.last.scale;
    for (final ph in phases) {
      final kind = ph.scale > prev
          ? BreathKind.expand
          : ph.scale < prev
              ? BreathKind.contract
              : (ph.scale >= 0.75 ? BreathKind.hold : BreathKind.holdEmpty);
      steps.add(BreathStep(ph.label.now, ph.seconds, kind));
      prev = ph.scale;
    }
    return BreathPattern(steps);
  }
}

@immutable
class GarbhPractice {
  const GarbhPractice({
    required this.id,
    required this.title,
    required this.blurb,
    required this.emoji,
    required this.minutes,
    required this.phases,
    this.safeFromWeek = 1,
    this.safeToWeek = 42,
  });
  final String id;
  final LocalizedText title;
  final LocalizedText blurb;
  final String emoji;
  final int minutes;
  final List<BreathPhase> phases; // one breath cycle, looped

  /// ⚠️ THE WEEK WINDOW THIS PRACTICE IS SAFE IN, AND MOST ARE ALL OF IT.
  ///
  /// The library was offered unfiltered, which the rebuild spec calls out:
  /// "filter the whole library by trimester so nothing unsafe is ever
  /// offered." The honest implementation of that is NOT to invent restrictions
  /// so the filter looks like it is working - gentle breathing is safe
  /// throughout pregnancy, and four of these five genuinely are.
  ///
  /// What is real: **Box Breathing holds the breath.** Its cycle includes two
  /// hold phases, and breath retention is the one thing in this set that
  /// standard prenatal guidance asks women to ease off in the third trimester,
  /// when there is less room for the diaphragm and less reserve. So that one
  /// carries a window and the rest do not.
  ///
  /// Defaulting to 1..42 means a new practice is safe-everywhere until someone
  /// says otherwise - which is the wrong default for a medical filter, and the
  /// right one here, because the alternative is a contributor silently
  /// narrowing a safe practice by forgetting a field.
  final int safeFromWeek;
  final int safeToWeek;

  bool safeAtWeek(int week) => week >= safeFromWeek && week <= safeToWeek;
}

@immutable
class GarbhPrompt {
  const GarbhPrompt(this.id, this.title, this.text);
  final String id;

  /// ⚠️ A SHORT NAME FOR THE PROMPT, AND IT EXISTS BECAUSE ITS ABSENCE
  /// SHIPPED A STORY WHERE A HEADING BELONGS.
  ///
  /// Every other pillar hands the daily row a TITLE — `shravanForDay().title`,
  /// `kriyaForDay().title`. Samvad had no title to hand, so both daily
  /// surfaces passed `text` instead, and `text` for trimester two is a whole
  /// story meant to be read aloud. The row renders two lines with an ellipsis,
  /// so a mother opening the app met "Round and round the garden hums a gentle
  /// bee. Buzz, buzz,…" as the label of her practice — a story fragment
  /// standing where a name should be.
  ///
  /// It is a POSITIONAL parameter, deliberately. Optional-and-named would let
  /// the next prompt be added without one and quietly reintroduce the bug;
  /// positional-and-required means the compiler asks.
  final LocalizedText title;

  /// The full prompt — the affirmation, story or visualisation she reads
  /// aloud. Correct to render in full on a prompt card; never as a row label.
  final LocalizedText text;
}

// ---- Vichara: Sacred Insights (Tab A) ----
@immutable
class GarbhInsight {
  const GarbhInsight({
    required this.sloka,
    required this.meaning,
    required this.lesson,
    required this.reflection,
  });
  final LocalizedText sloka; // a gentle line (no heavy religious language)
  final LocalizedText meaning; // simple interpretation
  final LocalizedText lesson; // life lesson
  final LocalizedText reflection; // reflection prompt
}

// ---- Vichara: Brain Fitness (Tab B) ----
@immutable
class GarbhPuzzle {
  const GarbhPuzzle(this.title, this.emoji, this.blurb);
  final LocalizedText title;
  final String emoji;
  final LocalizedText blurb;
}

// ---- Ahara: Nourishment (Pillar 5) ----
@immutable
class GarbhNutrition {
  const GarbhNutrition({
    required this.tip,
    required this.why,
    required this.recipe,
    required this.swap,
    required this.habit,
  });
  final LocalizedText tip; // today's nutrition tip (what to do)
  final LocalizedText why; // why it matters
  final LocalizedText recipe; // recommended recipe
  final LocalizedText swap; // food swap
  final LocalizedText habit; // lifestyle habit
}
