import 'package:supabase_flutter/supabase_flutter.dart';

/// Read-only access to PUBLIC content tables (articles now; recipes/videos next).
///
/// This is the client half of the content-delivery backend. Content is authored
/// in the admin panel (Directus) and served from Supabase; the app only ever
/// READS it — directly from Supabase, not via Directus. See docs/CONTENT-BACKEND.md.
///
/// Unlike [SupabaseRepo] — which is user-scoped and returns nothing when logged
/// out — content is the SAME for everyone and public-read, so these calls work
/// whether or not anyone is signed in (the anon/publishable key is enough).
class ContentRepo {
  ContentRepo._(); // static-only.

  static SupabaseClient get _client => Supabase.instance.client;

  /// All PUBLISHED articles for [domain] ('pregnancy' | 'parenting' | …),
  /// ordered by week then in-week sort order. One content table serves the
  /// whole app; each side fetches only its own domain. Throws on network
  /// error — callers fall back to their local cache.
  static Future<List<Map<String, dynamic>>> fetchArticles({
    String domain = 'pregnancy',
  }) async {
    final rows = await _client
        .from('articles')
        .select()
        .eq('status', 'published')
        .eq('domain', domain)
        .order('week', ascending: true)
        .order('sort', ascending: true);
    return List<Map<String, dynamic>>.from(rows);
  }
}
