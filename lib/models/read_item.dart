// =============================================================================
//  Read Next ❤️ - content model (stage-aware reading & discovery)
// -----------------------------------------------------------------------------
//  Not a blog or library - a curated, week-aware discovery layer. Every item
//  knows the week window where it is relevant and carries a "why this matters
//  now" reason, so the mother never has to wonder what to read. English-first.
// =============================================================================

import 'package:flutter/foundation.dart';
import '../localization/app_language.dart';

enum ReadType { article, book, research, expert, reflection }

/// One of a book's "most important ideas": a single flowing paragraph in the
/// author's voice plus 2-3 short, unlabelled pointer lines. Rendered as a
/// collapsible bar + panel, collapsed by default.
@immutable
class BookKeyIdea {
  const BookKeyIdea({required this.title, required this.body, this.pointers = const []});
  final LocalizedText title;
  final LocalizedText body; // one paragraph — no labelled sub-sections
  final List<LocalizedText> pointers; // 2-3 short dot lines
}

/// A run of "Key Points Covered" under an optional bolded sub-label. Chapters
/// with a natural sub-structure ("Baby's Development", Labor's three stages)
/// group their points; an empty [label] means plain, ungrouped bullets.
@immutable
class BookPointGroup {
  const BookPointGroup({this.label = const LocalizedText(en: '', hi: ''), required this.points});
  final LocalizedText label;
  final List<LocalizedText> points;
}

/// One chapter (or chapter group) of the book: a short teaser summary plus the
/// concrete "Key Points Covered" revealed when the reader expands it.
@immutable
class BookChapter {
  const BookChapter({required this.title, required this.summary, this.keyPoints = const []});
  final LocalizedText title;
  final LocalizedText summary;
  final List<BookPointGroup> keyPoints;
}

/// A rich "book companion" — the structured summary a book ReadItem can carry so
/// the reader renders About / Core Philosophy / Key Ideas / ParentVeda's Take /
/// Chapter-by-chapter / Quotes instead of one flat blurb. All optional.
@immutable
class BookCompanion {
  const BookCompanion({
    this.recommendedFor = const [],
    this.themes = const [],
    this.authorIntro = const LocalizedText(en: '', hi: ''),
    this.otherBooks = const [],
    this.parentVedaRating,
    this.about = const LocalizedText(en: '', hi: ''),
    this.philosophy = const LocalizedText(en: '', hi: ''),
    this.ideas = const [],
    this.perspective = const LocalizedText(en: '', hi: ''),
    this.chapters = const [],
    this.quotes = const [],
  });
  final List<LocalizedText> recommendedFor;
  final List<LocalizedText> themes;

  /// "About the author" — one compact line, never a biography.
  final LocalizedText authorIntro;

  /// The author's other notable books, rendered as chips.
  final List<LocalizedText> otherBooks;

  /// FUTURE READY, deliberately not rendered: a ParentVeda Rating for the book
  /// itself. The hero keeps room for it so adding one later is a data change,
  /// not a redesign. Do not surface a number until there is a real methodology
  /// behind it — an invented score on a book we rate is exactly the kind of
  /// thing the Product Guide work was careful to avoid.
  final double? parentVedaRating;

  final LocalizedText about; // "What this book is about"
  final LocalizedText philosophy; // "Core Philosophy"
  final List<BookKeyIdea> ideas; // "The book's most important ideas"
  final LocalizedText perspective; // "ParentVeda's Take"
  final List<BookChapter> chapters; // chapter-by-chapter
  final List<LocalizedText> quotes; // memorable quotes

  // .en: this asks whether a companion EXISTS at all. Presence must not
  // depend on the language on screen, or a book would show its companion in
  // English and a bare blurb in Hindi.
  bool get isEmpty =>
      about.en.isEmpty && ideas.isEmpty && chapters.isEmpty;
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
    this.body = const LocalizedText(en: '', hi: ''),
    this.author = '',
    this.authorRole = const LocalizedText(en: '', hi: ''),
    this.why = const LocalizedText(en: '', hi: ''),
    this.rating = 0.0,
    this.ratingCount = 0,
    // ---- Learn V2 reader blocks (additive, optional) --------------------
    // Distinct, styled sections in the premium reader. Left empty here => the
    // reader simply omits the block. All optional so every existing consumer
    // (home DailyReadsHomeCard, father daily screen) keeps compiling unchanged.
    this.whyThisMatters = const LocalizedText(en: '', hi: ''),
    this.researchSimplified = const LocalizedText(en: '', hi: ''),
    this.myth = const LocalizedText(en: '', hi: ''),
    this.fact = const LocalizedText(en: '', hi: ''),
    // Optional store link for a book summary's "Buy Book" CTA. Empty => the CTA
    // falls back to a web search for the title + author.
    this.buyUrl = '',
    // Optional rich book companion (About / Philosophy / Key Ideas / Chapters /
    // Quotes). When present, the reader renders it instead of a flat blurb.
    this.companion,
  });

  final String id;
  final LocalizedText title;
  final ReadType type;
  final int weekStart;
  final int weekEnd;

  /// "Why this matters now" - shown on every recommendation.
  final LocalizedText reason;
  final LocalizedText readingTime; // "5 min"
  final LocalizedText category; // Baby Development, Mother Changes, …
  final String emoji; // cover stand-in
  final String priority; // 'high' | 'medium'

  final LocalizedText body; // article / research summary text
  final String author; // book author / nothing
  final LocalizedText authorRole; // expert role (Pediatrician, …)
  final LocalizedText why; // book / expert "why ParentVeda recommends it"

  final double rating; // reader rating out of 5 (books)
  final int ratingCount; // number of ratings

  // ---- Learn V2 reader blocks (optional, default empty) -------------------
  /// "Why This Matters" - a deeper, styled block on the meaning/impact for
  /// mother & baby (distinct from [reason], which is the week-timing hook).
  final LocalizedText whyThisMatters;

  /// "Research Simplified" - the evidence, in plain, reassuring language.
  final LocalizedText researchSimplified;

  /// Optional myth-vs-fact pair. Both must be non-empty for the block to show.
  final LocalizedText myth;
  final LocalizedText fact;

  /// Optional purchase link for book summaries ("Buy Book").
  final String buyUrl;

  /// Optional rich book companion (see [BookCompanion]).
  final BookCompanion? companion;

  bool get hasCompanion => companion != null && !companion!.isEmpty;

  bool relevantAt(int week) => week >= weekStart && week <= weekEnd;
  bool get isHigh => priority == 'high';
  bool get hasRating => rating > 0;

  bool get hasWhyThisMatters => whyThisMatters.en.trim().isNotEmpty;
  bool get hasResearchSimplified => researchSimplified.en.trim().isNotEmpty;
  // .en: presence, not content. Asking whether a block EXISTS must give the
  // same answer in both languages, or a myth-vs-fact card would appear in
  // English and vanish in Hindi.
  bool get hasMythFact =>
      myth.en.trim().isNotEmpty && fact.en.trim().isNotEmpty;
}
