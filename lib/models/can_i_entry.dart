// =============================================================================
//  Can I?™  - entry model
// -----------------------------------------------------------------------------
//  A fast, calm lookup: one question → one trustworthy verdict. NOT a blog, a
//  forum, or AI reasoning. Each entry follows the same fixed answer structure:
//  verdict → short answer → why → (trimester notes) → (Indian context) →
//  related questions. Educational general guidance, never a diagnosis - every
//  answer ends with a gentle "Ask Veda" handoff for anything beyond the lookup.
//
//  English-first: content uses LocalizedText so Hindi can be filled in later
//  without restructuring (today hi == en via the data helper).
// =============================================================================

import '../localization/app_language.dart';

/// The five verdict states (see the spec). Order matters for display intent.
enum CanIVerdict { safe, moderation, depends, avoid, askDoctor }

/// The four question types. "do" covers Activities + Beauty + Lifestyle.
enum CanICategory { eat, drink, take, doActivity }

class CanIEntry {
  const CanIEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.verdict,
    required this.short,
    required this.why,
    this.t1,
    this.t2,
    this.t3,
    this.indian,
    this.related = const [],
    this.aliases = const [],
  });

  /// Slug, e.g. 'papaya'.
  final String id;

  /// Display name, e.g. "Papaya".
  final LocalizedText name;

  final CanICategory category;
  final CanIVerdict verdict;

  /// 2–3 lines, understandable in seconds.
  final LocalizedText short;

  /// 3–5 lines, no jargon, no scare tactics.
  final LocalizedText why;

  /// Trimester notes - shown only if present (any one may be null).
  final LocalizedText? t1;
  final LocalizedText? t2;
  final LocalizedText? t3;

  /// The ParentVeda differentiator - local foods/habits framing. Optional.
  final LocalizedText? indian;

  /// Related entry ids (the spec wants at least 3 where possible).
  final List<String> related;

  /// Extra search terms (brand names, Hindi words, synonyms).
  final List<String> aliases;

  bool get hasTrimesterNotes => t1 != null || t2 != null || t3 != null;
}
