// =============================================================================
//  Garbh Sanskar Journey — content models
// -----------------------------------------------------------------------------
//  Four pillars, four content shapes:
//    Shravan  → GarbhAudio    (Spotify-like listening)
//    Vichara  → GarbhStory    (Kindle-like reflective reading)
//    Kriya    → GarbhPractice (Headspace-like guided breathing, with phases)
//    Samvad   → GarbhPrompt   (Memory-Vault-like womb connection prompts)
//
//  English-first plain strings (this is a calm, content-light experience; Hindi
//  can be layered later). Audio files are placeholders for now — the player uses
//  the bundled drone until real recordings are added.
// =============================================================================

import 'package:flutter/material.dart';

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
  final String title;
  final String subtitle;
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
  final String theme; // "Curiosity", "Patience", …
  final String title;
  final String blurb; // one-line description on the card
  final String body; // the reflection itself
  final String reflection; // closing question
  final int minutes;
}

/// One step of a breathing practice. [scale] is the target size of the breathing
/// circle at the END of this phase (1.0 = full inhale, ~0.5 = full exhale).
@immutable
class BreathPhase {
  const BreathPhase(this.label, this.seconds, this.scale);
  final String label; // "Breathe in", "Hold", "Breathe out", "Rest"
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
  final String title;
  final String blurb;
  final String emoji;
  final int minutes;
  final List<BreathPhase> phases; // one breath cycle, looped
}

@immutable
class GarbhPrompt {
  const GarbhPrompt(this.id, this.text);
  final String id;
  final String text;
}
