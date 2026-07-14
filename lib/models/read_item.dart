// =============================================================================
//  Read Next ❤️ - content model (stage-aware reading & discovery)
// -----------------------------------------------------------------------------
//  Not a blog or library - a curated, week-aware discovery layer. Every item
//  knows the week window where it is relevant and carries a "why this matters
//  now" reason, so the mother never has to wonder what to read. English-first.
// =============================================================================

import 'package:flutter/foundation.dart';

enum ReadType { article, book, research, expert, reflection }

/// One of a book's "most important ideas" — the what / why / how triple that the
/// companion renders as a styled card.
@immutable
class BookKeyIdea {
  const BookKeyIdea({required this.title, required this.means, required this.matters, required this.inRealLife});
  final String title;
  final String means; // What the author means
  final String matters; // Why it matters
  final List<String> inRealLife; // In real life (bullets)
}

/// A rich "book companion" — the structured summary a book ReadItem can carry so
/// the reader renders About / Core Philosophy / Key Ideas / ParentVeda Perspective
/// / Chapter-by-chapter / Quotes instead of one flat blurb. All optional.
@immutable
class BookCompanion {
  const BookCompanion({
    this.recommendedFor = const [],
    this.themes = const [],
    this.about = '',
    this.philosophy = '',
    this.ideas = const [],
    this.perspective = '',
    this.chapters = const [],
    this.quotes = const [],
  });
  final List<String> recommendedFor;
  final List<String> themes;
  final String about; // "What this book is about"
  final String philosophy; // "Core Philosophy"
  final List<BookKeyIdea> ideas; // "The book's most important ideas"
  final String perspective; // "ParentVeda Perspective"
  final List<(String title, String summary)> chapters; // chapter-by-chapter
  final List<String> quotes; // memorable quotes

  bool get isEmpty => about.isEmpty && ideas.isEmpty && chapters.isEmpty;
}

@immutable
class ReadItem {
  const ReadItem({
    required this.id,
    required this.title,
    required this.type,
    required this.weekStart,
    required this.weekEnd,
    required this.reason,
    required this.readingTime,
    required this.category,
    this.emoji = '📄',
    this.priority = 'medium',
    this.body = '',
    this.author = '',
    this.authorRole = '',
    this.why = '',
    this.rating = 0.0,
    this.ratingCount = 0,
    // ---- Learn V2 reader blocks (additive, optional) --------------------
    // Distinct, styled sections in the premium reader. Left empty here => the
    // reader simply omits the block. All optional so every existing consumer
    // (home DailyReadsHomeCard, father daily screen) keeps compiling unchanged.
    this.whyThisMatters = '',
    this.researchSimplified = '',
    this.myth = '',
    this.fact = '',
    // Optional store link for a book summary's "Buy Book" CTA. Empty => the CTA
    // falls back to a web search for the title + author.
    this.buyUrl = '',
    // Optional rich book companion (About / Philosophy / Key Ideas / Chapters /
    // Quotes). When present, the reader renders it instead of a flat blurb.
    this.companion,
  });

  final String id;
  final String title;
  final ReadType type;
  final int weekStart;
  final int weekEnd;

  /// "Why this matters now" - shown on every recommendation.
  final String reason;
  final String readingTime; // "5 min"
  final String category; // Baby Development, Mother Changes, …
  final String emoji; // cover stand-in
  final String priority; // 'high' | 'medium'

  final String body; // article / research summary text
  final String author; // book author / nothing
  final String authorRole; // expert role (Pediatrician, …)
  final String why; // book / expert "why ParentVeda recommends it"

  final double rating; // reader rating out of 5 (books)
  final int ratingCount; // number of ratings

  // ---- Learn V2 reader blocks (optional, default empty) -------------------
  /// "Why This Matters" - a deeper, styled block on the meaning/impact for
  /// mother & baby (distinct from [reason], which is the week-timing hook).
  final String whyThisMatters;

  /// "Research Simplified" - the evidence, in plain, reassuring language.
  final String researchSimplified;

  /// Optional myth-vs-fact pair. Both must be non-empty for the block to show.
  final String myth;
  final String fact;

  /// Optional purchase link for book summaries ("Buy Book").
  final String buyUrl;

  /// Optional rich book companion (see [BookCompanion]).
  final BookCompanion? companion;

  bool get hasCompanion => companion != null && !companion!.isEmpty;

  bool relevantAt(int week) => week >= weekStart && week <= weekEnd;
  bool get isHigh => priority == 'high';
  bool get hasRating => rating > 0;

  bool get hasWhyThisMatters => whyThisMatters.trim().isNotEmpty;
  bool get hasResearchSimplified => researchSimplified.trim().isNotEmpty;
  bool get hasMythFact => myth.trim().isNotEmpty && fact.trim().isNotEmpty;
}
