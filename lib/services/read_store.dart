// =============================================================================
//  ReadStore — the parenting Reading Experience, served from Supabase.
// -----------------------------------------------------------------------------
//  Third content type to flip. The line drawn here is between an ARTICLE and
//  the SHELF it sits on:
//
//    this store            -> the articles. Editorial: write, edit, translate,
//                             unpublish.
//    kReadCollections      -> the seven collections. Stay in Dart. They carry
//                             an IconData (code, not content) and a new
//                             collection is a new shelf in the UI, not a new
//                             article on an existing one.
//    ReadingStore          -> reading positions and completions. User data,
//                             cloud-synced. Untouched.
//
//  An editor files an article under a collection by id. Directus should offer
//  that as a dropdown of the known ids — a free-text box would let an article
//  be filed nowhere, and it would still look published.
// =============================================================================

import '../screens/post_pregnancy/pp_reading_data.dart';
import 'content_store.dart';
import 'remote/content_repo.dart';

class ReadStore extends ContentStore<ReadArticle> {
  ReadStore._()
      : super(
          table: 'reads',
          cacheKey: 'content_reads_v1',
          seed: kReadArticles,
          domain: 'parenting',
        );

  static final ReadStore instance = ReadStore._();

  @override
  List<ContentOrder> get order => const [ContentOrder('sort')];

  static String _text(Object? v) => (v as String?) ?? '';

  static List<String> _strings(Object? v) => (v as List?)
          ?.map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList(growable: false) ??
      const [];

  static ReadKind _kind(Object? v) => switch (v) {
        'bookSummary' => ReadKind.bookSummary,
        'research' => ReadKind.research,
        // Anything unrecognised reads as a plain article rather than throwing.
        // A content backend must never crash the app over a typo, and an
        // article showing under the wrong filter is a far smaller failure
        // than a reader that will not open.
        _ => ReadKind.article,
      };

  static ReadSection _section(Map<String, dynamic> m) {
    final tip = m['tip'] as Map?;
    final myth = m['mythFact'] as Map?;
    return ReadSection(
      heading: m['heading'] as String?,
      paragraphs: _strings(m['paragraphs']),
      tip: tip == null
          ? null
          : ReadTip(_text(tip['title']), _text(tip['body'])),
      mythFact: myth == null
          ? null
          : MythFact(_text(myth['myth']), _text(myth['fact'])),
      image: m['image'] == true,
    );
  }

  @override
  ReadArticle fromMap(Map<String, dynamic> row) => ReadArticle(
        id: (row['source_key'] as String?) ?? _text(row['id']),
        title: _text(row['title']),
        teaser: _text(row['teaser']),
        whyToday: _text(row['why_today']),
        collection: _text(row['collection']),
        kind: _kind(row['kind']),
        ageTag: _text(row['age_tag']),
        minutes: (row['minutes'] as num?)?.toInt() ?? 5,
        seed: (row['shuffle_seed'] as num?)?.toInt() ?? 0,
        author: _text(row['author']),
        authorRole: _text(row['author_role']),
        evidence: row['evidence'] as String?,
        sections: ((row['sections'] as List?) ?? const [])
            .map((e) => _section(Map<String, dynamic>.from(e as Map)))
            .toList(growable: false),
        relatedActivity: row['related_activity'] as String?,
        relatedVideoId: row['related_video_id'] as String?,
        relatedVideoIds: _strings(row['related_video_ids']),
        relatedRecipeId: row['related_recipe_id'] as String?,
        relatedProductId: row['related_product_id'] as String?,
        relatedCommunity: row['related_community'] as String?,
      );

  @override
  Map<String, dynamic> toCacheMap(ReadArticle a) => <String, dynamic>{
        'source_key': a.id,
        'title': a.title,
        'teaser': a.teaser,
        'why_today': a.whyToday,
        'collection': a.collection,
        'kind': a.kind.name,
        'age_tag': a.ageTag,
        'minutes': a.minutes,
        'shuffle_seed': a.seed,
        'author': a.author,
        'author_role': a.authorRole,
        'evidence': a.evidence,
        'sections': a.sections
            .map((s) => <String, dynamic>{
                  if (s.heading != null) 'heading': s.heading,
                  'paragraphs': s.paragraphs,
                  if (s.tip != null)
                    'tip': {'title': s.tip!.title, 'body': s.tip!.body},
                  if (s.mythFact != null)
                    'mythFact': {
                      'myth': s.mythFact!.myth,
                      'fact': s.mythFact!.fact,
                    },
                  if (s.image) 'image': true,
                })
            .toList(growable: false),
        'related_activity': a.relatedActivity,
        'related_video_id': a.relatedVideoId,
        'related_video_ids': a.relatedVideoIds,
        'related_recipe_id': a.relatedRecipeId,
        'related_product_id': a.relatedProductId,
        'related_community': a.relatedCommunity,
      };
}
