// =============================================================================
//  The book companion docs on the parenting shelf (2026-10-13)
// -----------------------------------------------------------------------------
//  Every parenting (and newborn) book from lib/data/book_companions.dart as a
//  `ReadArticle` of kind `bookSummary`, so it sits on Reading → Book Summaries,
//  in its topic's collection, in search and in "read next". Opening one goes
//  to the Book Companion, not the article reader: `ReadingReaderScreen` hands
//  any id with a book doc straight to `BookCompanionScreen`, which covers
//  every way in (home rails, collections, search, Saved) at once.
// =============================================================================

import '../../data/book_companions.dart';
import 'pp_reading_data.dart';

/// The parenting collection a book belongs with, from its title and themes.
String _collectionFor(BookDoc d) {
  final t = '${d.title} ${d.themes.join(' ')}'.toLowerCase();
  if (RegExp(r'sleep').hasMatch(t)) return 'sleep';
  if (RegExp(r'feed|eater|weaning|solid|food|nutrition').hasMatch(t)) return 'feeding';
  if (RegExp(r'disciplin|behaviour|behavior|tantrum|kids will|love language|good inside|emotion|punish')
      .hasMatch(t)) {
    return 'behaviour';
  }
  if (RegExp(r'montessori|busy book|play|activit').hasMatch(t)) return 'play';
  if (RegExp(r'brain').hasMatch(t)) return 'brain';
  return 'parent';
}

/// Every book a parent should find, as a Book Summaries entry.
final List<ReadArticle> kPpBookArticles = [
  for (final d in kBookDocList)
    if (bookStage(d) != BookStage.pregnancy)
      ReadArticle(
        id: bookShelfId(d),
        title: d.title,
        teaser: bookFirstSentence(d.about),
        whyToday: bookFirstSentence(d.philosophy),
        collection: _collectionFor(d),
        ageTag: 'All stages',
        minutes: d.minutes,
        seed: d.id.hashCode & 0x7fffffff,
        author: d.author,
        authorRole: 'Book companion',
        kind: ReadKind.bookSummary,
        sections: [ReadSection(paragraphs: [d.about])],
      ),
];
