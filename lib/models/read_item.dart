// =============================================================================
//  Read Next ❤️ - content model (stage-aware reading & discovery)
// -----------------------------------------------------------------------------
//  Not a blog or library - a curated, week-aware discovery layer. Every item
//  knows the week window where it is relevant and carries a "why this matters
//  now" reason, so the mother never has to wonder what to read. English-first.
// =============================================================================

import 'package:flutter/foundation.dart';

enum ReadType { article, book, research, expert, reflection }

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

  bool relevantAt(int week) => week >= weekStart && week <= weekEnd;
  bool get isHigh => priority == 'high';
  bool get hasRating => rating > 0;
}
