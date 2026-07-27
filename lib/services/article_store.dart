// =============================================================================
//  ArticleStore — the app's copy of the "This week's reads" content.
// -----------------------------------------------------------------------------
//  Reads PUBLISHED articles from the content backend (Supabase, authored in
//  Directus) and serves them to the weekly reads carousel.
//
//  This used to BE the engine — it carried a note saying it was the pattern
//  every future content type would copy. It is now the first SUBCLASS of that
//  engine (lib/services/content_store.dart), which is where the local-first
//  layering, the cache, the throttle and the empty-result rules now live. What
//  is left here is only what is specific to articles: the table, the domain, the
//  ordering, and the row mapping.
//
//  That refit was deliberate: generalising against a live, shipping type is the
//  only way to find out whether the abstraction actually fits before four more
//  types depend on it.
//
//  See docs/CONTENT-BACKEND.md.
// =============================================================================

import '../data/week_articles_data.dart';
import 'content_store.dart';
import 'remote/content_repo.dart';

class ArticleStore extends ContentStore<WeekArticle> {
  ArticleStore._()
      : super(
          table: 'articles',
          cacheKey: 'content_articles_v2', // v1 held an un-enveloped, English-only cache.
          seed: kWeekArticles,
          domain: 'pregnancy', // one table serves the whole app; take our slice.
        );

  static final ArticleStore instance = ArticleStore._();

  @override
  List<ContentOrder> get order =>
      const [ContentOrder('week'), ContentOrder('sort')];

  /// Articles for [week] (empty → the carousel renders its own invitation).
  List<WeekArticle> forWeek(int week) =>
      all.where((a) => a.week == week).toList(growable: false);

  @override
  WeekArticle fromMap(Map<String, dynamic> row) => WeekArticle(
        week: (row['week'] as num?)?.toInt() ?? 0,
        emoji: (row['emoji'] as String?) ?? '',
        title: (row['title'] as String?) ?? '',
        readMins: (row['read_mins'] as num?)?.toInt() ?? 3,
        body: (row['body'] as String?) ?? '',
        titleHi: row['title_hi'] as String?,
        bodyHi: row['body_hi'] as String?,
      );

  @override
  Map<String, dynamic> toCacheMap(WeekArticle a) => <String, dynamic>{
        'week': a.week,
        'emoji': a.emoji,
        'title': a.title,
        'read_mins': a.readMins,
        'body': a.body,
        // Both languages, always — see defect 2 in content_store.dart.
        'title_hi': a.titleHi,
        'body_hi': a.bodyHi,
      };
}
