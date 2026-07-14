// =============================================================================
//  ArticleStore — the app's copy of the "This week's reads" content.
// -----------------------------------------------------------------------------
//  Reads PUBLISHED articles from the content backend (Supabase, authored in
//  Directus) and serves them to the weekly reads carousel. Local-first:
//    1. starts with the bundled kWeekArticles so the UI is NEVER empty,
//    2. shows a cached copy instantly on launch,
//    3. fetches fresh in the background and updates + re-caches.
//  Offline / empty table → it simply keeps the cache (or the bundled fallback),
//  so nothing regresses. Lazy-loaded (no main.dart wiring), like ReadDoneStore.
//  This is the build-once engine every future content type will copy.
//  See docs/CONTENT-BACKEND.md.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/week_articles_data.dart';
import 'remote/content_repo.dart';

class ArticleStore extends ChangeNotifier {
  ArticleStore._();
  static final ArticleStore instance = ArticleStore._();

  static const _cacheKey = 'content_articles_v1';

  // Seeded with the bundled articles so the carousel shows content instantly —
  // offline, on first launch, and before the first fetch returns. Replaced by
  // the DB content once a non-empty fetch (or cache) arrives.
  List<WeekArticle> _articles = List.of(kWeekArticles);
  bool _loaded = false;

  List<WeekArticle> get all => List.unmodifiable(_articles);

  /// Articles for [week] (empty → the carousel hides itself).
  List<WeekArticle> forWeek(int week) =>
      _articles.where((a) => a.week == week).toList();

  /// Load once (call from build — a no-op after the first time).
  void ensureLoaded() {
    if (_loaded) return;
    _loaded = true;
    _load();
  }

  Future<void> _load() async {
    // 1) instant: a cached copy from a previous run.
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        final list = (jsonDecode(raw) as List)
            .map((e) => _fromMap(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          _articles = list;
          notifyListeners();
        }
      }
    } catch (_) {/* keep the bundled fallback */}

    // 2) fresh: pull the latest from the content backend.
    await _fetchFresh();
  }

  /// Re-pull published articles from the backend (pull-to-refresh / app resume).
  /// Bypasses the once-per-session guard, so freshly-published articles show
  /// without relaunching the app. Safe to call anytime; offline → keeps current.
  Future<void> refresh() => _fetchFresh();

  Future<void> _fetchFresh() async {
    // One shared table; the pregnancy side fetches only its own domain.
    try {
      final rows = await ContentRepo.fetchArticles(domain: 'pregnancy');
      if (rows.isNotEmpty) {
        _articles = rows.map(_fromMap).toList();
        notifyListeners();
        await _persist(rows);
      }
    } catch (_) {/* offline / no backend → keep cache or bundled */}
  }

  // A DB row and a cached row share the same shape, so one mapper serves both.
  WeekArticle _fromMap(Map<String, dynamic> m) => WeekArticle(
        week: (m['week'] as num?)?.toInt() ?? 0,
        emoji: (m['emoji'] as String?) ?? '',
        title: (m['title'] as String?) ?? '',
        readMins: (m['read_mins'] as num?)?.toInt() ?? 3,
        body: (m['body'] as String?) ?? '',
      );

  Future<void> _persist(List<Map<String, dynamic>> rows) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Cache only the fields the UI renders, keyed like DB rows.
      final slim = rows
          .map((r) => {
                'week': r['week'],
                'emoji': r['emoji'],
                'title': r['title'],
                'read_mins': r['read_mins'],
                'body': r['body'],
              })
          .toList();
      await prefs.setString(_cacheKey, jsonEncode(slim));
    } catch (_) {/* best-effort */}
  }
}
