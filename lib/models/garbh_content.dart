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
  });
  final String id;
  final LocalizedText title;
  final LocalizedText subtitle;
  final String emoji;
  final int minutes;
  final GarbhKind kind;
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

@immutable
class GarbhPractice {
  const GarbhPractice({
    required this.id,
    required this.title,
    required this.blurb,
    required this.emoji,
    required this.minutes,
    required this.phases,
  });
  final String id;
  final LocalizedText title;
  final LocalizedText blurb;
  final String emoji;
  final int minutes;
  final List<BreathPhase> phases; // one breath cycle, looped
}

@immutable
class GarbhPrompt {
  const GarbhPrompt(this.id, this.text);
  final String id;
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
