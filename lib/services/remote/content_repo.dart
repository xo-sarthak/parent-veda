import 'package:supabase_flutter/supabase_flutter.dart';

/// How to order a content fetch. A tiny value type rather than a record so the
/// call reads as data at the call site and can carry a comment.
class ContentOrder {
  const ContentOrder(this.column, {this.ascending = true});

  final String column;
  final bool ascending;
}

/// Read-only access to PUBLIC content tables (articles now; recipes/reads/
/// products next).
///
/// This is the client half of the content-delivery backend. Content is authored
/// in the admin panel (Directus) and served from Supabase; the app only ever
/// READS it — directly from Supabase, not via Directus. See
/// docs/CONTENT-BACKEND.md.
///
/// Unlike [SupabaseRepo] — which is user-scoped and returns nothing when logged
/// out — content is the SAME for everyone and public-read, so these calls work
/// whether or not anyone is signed in (the anon/publishable key is enough).
class ContentRepo {
  ContentRepo._(); // static-only.

  static SupabaseClient get _client => Supabase.instance.client;

  /// Every PUBLISHED row of [table], optionally narrowed to one [domain] and
  /// ordered by [order].
  ///
  /// Ordering is a PARAMETER, not a constant, and that is load-bearing: the
  /// original version of this class hardcoded `.order('week')`, which is a 400
  /// against any table without a `week` column. Because content fetches
  /// deliberately swallow their errors (a content backend must never crash the
  /// app), that 400 would have surfaced as "the new content type is silently
  /// always empty" — one of the harder bugs to see.
  ///
  /// Throws on network or schema error; callers fall back to their cache.
  static Future<List<Map<String, dynamic>>> fetchPublished(
    String table, {
    String? domain,
    List<ContentOrder> order = const [],
    int? limit,
  }) async {
    var filter = _client.from(table).select().eq('status', 'published');
    if (domain != null) {
      filter = filter.eq('domain', domain);
    }

    dynamic query = filter;
    for (final o in order) {
      query = query.order(o.column, ascending: o.ascending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    final rows = await query;
    return List<Map<String, dynamic>>.from(rows as List);
  }

  /// All PUBLISHED articles for [domain] ('pregnancy' | 'parenting' | …),
  /// ordered by week then in-week sort order.
  ///
  /// Kept as a named wrapper so existing call sites did not have to move when
  /// [fetchPublished] arrived.
  static Future<List<Map<String, dynamic>>> fetchArticles({
    String domain = 'pregnancy',
  }) =>
      fetchPublished(
        'articles',
        domain: domain,
        order: const [ContentOrder('week'), ContentOrder('sort')],
      );
}
