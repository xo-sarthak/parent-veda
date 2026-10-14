// =============================================================================
//  Books to read with your child — the team's Book Recommendations sheet
// -----------------------------------------------------------------------------
//  2026-10-13. Generated from "ParentVeda Book Recommendations Master.xlsx" by
//  `tools/products/xlsx_to_dart.py` into `kids_books/kids_books_list.dart`.
//
//  The user: a parenting Reading shelf, by the child's age and the parent's
//  goal. These are picture books and first readers to share with a child —
//  not the book companions (lib/data/book_companions.dart), which summarise
//  books for the PARENT.
//
//  What the sheet gives, and so all a row shows: title, author, publisher,
//  Indian or global, an age range, the goals, a theme, how it is read, and
//  whether the team marked it Essential. Its "Why Recommended" only repeats
//  the theme ("Supports Sleep") and its scoring sheets are empty, so neither
//  is carried. 14 rows whose columns slipped are repaired by the converter
//  and listed in its report.
// =============================================================================

import 'kids_books/kids_books_list.dart';

export 'kids_books/kids_books_list.dart' show kKidsBooks;

enum KidsBookRank { essential, niceToHave, listed }

class KidsBook {
  const KidsBook({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.indian,
    required this.ageMin,
    required this.ageMax,
    required this.ageLabel,
    required this.goals,
    required this.theme,
    required this.mode,
    required this.rank,
  });
  final String id;
  final String title;
  final String author;
  final String publisher;
  final bool indian;

  /// Months, from the sheet's "3-5y".
  final int ageMin;
  final int ageMax;
  final String ageLabel;
  final List<String> goals;
  final String theme;

  /// "Read To Child" or "Read With Child".
  final String mode;
  final KidsBookRank rank;

  bool suits(int months) => months >= ageMin && months <= ageMax;

  /// "Ages 3–5", from the sheet's "3-5y".
  String get ageText => 'Ages ${ageLabel.replaceAll('y', '').replaceAll('-', '–')}';
}

/// The books for a child of [months], or every book when the age is unknown
/// (a shelf is never hidden: CLAUDE.md). Essential first, then the sheet's order.
List<KidsBook> kidsBooksFor(int? months) {
  final list = [for (final b in kKidsBooks) if (months == null || b.suits(months)) b];
  final order = {for (var i = 0; i < kKidsBooks.length; i++) kKidsBooks[i].id: i};
  list.sort((a, b) {
    final r = a.rank.index.compareTo(b.rank.index);
    return r != 0 ? r : order[a.id]!.compareTo(order[b.id]!);
  });
  return list;
}

/// The goals present among [books], most books first, for the shelf's chips.
List<String> kidsBookGoals(List<KidsBook> books) {
  final count = <String, int>{};
  for (final b in books) {
    for (final g in b.goals) {
      count[g] = (count[g] ?? 0) + 1;
    }
  }
  return count.keys.toList()..sort((a, b) => count[b]!.compareTo(count[a]!));
}
