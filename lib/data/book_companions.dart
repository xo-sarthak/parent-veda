// =============================================================================
//  Book companions — the user's book summary docs, the source of truth
// -----------------------------------------------------------------------------
//  2026-10-13. 40 book companions from the user's "Book summary" folder, built
//  to the Book Companion Bible the app's `BookCompanionScreen` already follows:
//  Hero → What this book is about → About the author → Core philosophy → The
//  book's most important ideas → Chapter by chapter → ParentVeda's take →
//  Memorable quotes → (sometimes) a closing addendum.
//
//  ⚠️ GENERATED. `lib/data/book_companions/*.dart` and `index.dart` are written
//  by `tools/book_companions/docx_to_dart.py`. Fix the doc and re-run.
//
//  WHERE THEY SHOW (the user, 2026-10-13: "by stage")
//    · pregnancy — Read Next → Books (`kReadItems`), opening the companion;
//    · parenting — Reading → Book Summaries (`kPpBookArticles`), opening the
//      same companion through `ReadingReaderScreen`;
//    · both — the two newborn books, from week 30 and in parenting.
//  One list of books feeds both shelves, so the stages cannot disagree.
//
//  English only (CLAUDE.md). The docs' ❤️ / ⚠️ are carried as a flag on each
//  Take pointer and drawn as the app's own marks, never as emoji.
// =============================================================================

import '../localization/app_language.dart';
import '../models/read_item.dart';
import 'book_companions/index.dart';

export 'book_companions/index.dart' show kBookDocList;

class BookDocIdea {
  const BookDocIdea(this.title, this.body, this.points);
  final String title;
  final String body;
  final List<String> points;
}

class BookDocChapter {
  const BookDocChapter(this.title, this.summary, this.points);
  final String title;
  final String summary;
  final List<String> points;
}

class BookDocTakePoint {
  const BookDocTakePoint(this.good, this.text);

  /// ❤️ in the doc: what the book does well. ⚠️: worth knowing.
  final bool good;
  final String text;
}

/// One book companion, as the doc wrote it.
class BookDoc {
  const BookDoc({
    required this.id,
    required this.title,
    required this.author,
    required this.minutes,
    required this.recommendedFor,
    required this.themes,
    required this.about,
    required this.authorIntro,
    required this.otherBooks,
    required this.philosophy,
    required this.ideas,
    required this.chapters,
    required this.take,
    required this.takePoints,
    required this.quotes,
    this.addendumTitle = '',
    this.addendumBody = '',
    this.addendumPoints = const [],
  });
  final String id;
  final String title;
  final String author;
  final int minutes;
  final List<String> recommendedFor;
  final List<String> themes;
  final String about;
  final String authorIntro;
  final List<String> otherBooks;
  final String philosophy;
  final List<BookDocIdea> ideas;
  final List<BookDocChapter> chapters;

  /// The take as one paragraph, when the doc wrote no pointers.
  final String take;
  final List<BookDocTakePoint> takePoints;
  final List<String> quotes;
  final String addendumTitle;
  final String addendumBody;
  final List<String> addendumPoints;
}

/// Which stage's shelf a book sits on.
enum BookStage { pregnancy, both, parenting }

/// The user's "by stage" split (2026-10-13), from each doc's "Recommended for".
/// A book not named here is a parenting book.
const Map<String, BookStage> _kBookStages = {
  'book_what_to_expect_when_you_re_expecting': BookStage.pregnancy,
  'book_expecting_better': BookStage.pregnancy,
  'book_pregnancy_notes': BookStage.pregnancy,
  'book_ayurvedic_garbha_sanskar': BookStage.pregnancy,
  'book_talking_to_the_baby_in_the_womb': BookStage.pregnancy,
  'book_the_mindful_mother': BookStage.pregnancy,
  'book_manifestation_through_garbha_sanskar': BookStage.pregnancy,
  'book_the_happiest_baby_on_the_block': BookStage.both,
  'book_what_to_expect_the_first_year': BookStage.both,
};

BookStage bookStage(BookDoc d) => _kBookStages[d.id] ?? BookStage.parenting;

/// Books that already had an entry on the pregnancy shelf keep that entry's
/// id, so a mother's saved books and reading progress carry over.
const Map<String, String> kBookDocExistingIds = {
  'book_what_to_expect_when_you_re_expecting': 'book_what_to_expect',
  'book_expecting_better': 'book_expecting_better',
  'book_the_whole_brain_child': 'book_whole_brain',
};

/// The id a book is shown under (an existing shelf id where there is one).
String bookShelfId(BookDoc d) => kBookDocExistingIds[d.id] ?? d.id;

/// Every book by its shelf id.
final Map<String, BookDoc> kBookDocsByShelfId = {
  for (final d in kBookDocList) bookShelfId(d): d,
};

/// The doc for a shelf id (pregnancy `ReadItem.id` or parenting article id).
BookDoc? bookDocFor(String shelfId) => kBookDocsByShelfId[shelfId];

LocalizedText _same(String s) => LocalizedText(en: s, hi: s);

/// The doc as the companion the reader draws.
BookCompanion bookCompanionOf(BookDoc d) => BookCompanion(
      recommendedFor: [for (final r in d.recommendedFor) _same(r)],
      themes: [for (final t in d.themes) _same(t)],
      authorIntro: _same(d.authorIntro),
      otherBooks: [for (final b in d.otherBooks) _same(b)],
      about: _same(d.about),
      philosophy: _same(d.philosophy),
      ideas: [
        for (final i in d.ideas)
          BookKeyIdea(title: _same(i.title), body: _same(i.body), pointers: [for (final p in i.points) _same(p)]),
      ],
      perspective: _same(d.take),
      takePoints: [for (final p in d.takePoints) BookTakePoint(good: p.good, text: _same(p.text))],
      chapters: [
        for (final c in d.chapters)
          BookChapter(title: _same(c.title), summary: _same(c.summary), keyPoints: _pointGroups(c.points)),
      ],
      quotes: [for (final q in d.quotes) _same(q)],
      addendumTitle: _same(d.addendumTitle),
      addendumBody: _same(d.addendumBody),
      addendumPoints: [for (final p in d.addendumPoints) _same(p)],
    );

/// A chapter's points, grouped under the doc's own sub-labels when it writes
/// them ("Baby's Development: by the end of month 3…") — the companion's
/// `BookPointGroup` draws each label once above its points. Points without a
/// label stay in an unlabelled group, in order.
final RegExp _kPointLabel = RegExp(r"^([A-Z][A-Za-z’'&,\- ]{2,38}):\s+(.+)$");

List<BookPointGroup> _pointGroups(List<String> points) {
  final groups = <(String, List<String>)>[];
  for (final p in points) {
    final m = _kPointLabel.firstMatch(p);
    final label = m?.group(1) ?? '';
    final text = m?.group(2) ?? p;
    if (groups.isNotEmpty && groups.last.$1 == label) {
      groups.last.$2.add(text);
    } else {
      groups.add((label, [text]));
    }
  }
  return [
    for (final (label, pts) in groups)
      BookPointGroup(label: _same(label), points: [for (final t in pts) _same(t)]),
  ];
}

/// The first sentence of [s], for a one-line "why read it".
String bookFirstSentence(String s) {
  final m = RegExp(r'^.+?[.!?](?=\s|$)').firstMatch(s.trim());
  return (m?.group(0) ?? s).trim();
}

/// The doc as a pregnancy shelf item. [base] is the shelf's existing entry for
/// the same book, whose reason, why and Hindi are kept; the doc supplies the
/// companion, author and reading time (the doc wins on its own content).
ReadItem bookReadItem(BookDoc d, {ReadItem? base}) {
  final stage = bookStage(d);
  final c = bookCompanionOf(d);
  if (base != null) {
    return ReadItem(
      id: base.id,
      title: base.title,
      type: ReadType.book,
      weekStart: base.weekStart,
      weekEnd: base.weekEnd,
      reason: base.reason,
      readingTime: _same('${d.minutes} min'),
      category: base.category,
      emoji: base.emoji,
      priority: base.priority,
      body: base.body,
      author: d.author,
      authorRole: base.authorRole,
      why: base.why,
      rating: base.rating,
      ratingCount: base.ratingCount,
      buyUrl: base.buyUrl,
      companion: c,
    );
  }
  return ReadItem(
    id: bookShelfId(d),
    title: _same(d.title),
    type: ReadType.book,
    weekStart: stage == BookStage.both ? 30 : 4,
    weekEnd: 44,
    reason: _same(bookFirstSentence(d.about)),
    readingTime: _same('${d.minutes} min'),
    category: _same(stage == BookStage.both ? 'Newborn Book' : 'Pregnancy Book'),
    author: d.author,
    why: _same(d.about),
    companion: c,
  );
}
