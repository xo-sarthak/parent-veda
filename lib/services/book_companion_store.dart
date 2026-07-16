// =============================================================================
//  BookCompanionStore — which ideas and chapters a reader has opened
// -----------------------------------------------------------------------------
//  Powers the companion's reading progress ("Ideas 3/5 · Chapters 6/12").
//
//  Progress here means EXPLORED, not "completed": opening an idea is the whole
//  interaction, so opening it is what counts. There is no streak, no score and
//  nothing to finish — a reader who opens two ideas and leaves has used the
//  book companion exactly as intended.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_synced_store.dart';

class BookCompanionStore extends ChangeNotifier with CloudSyncedStore {
  BookCompanionStore._();
  static final BookCompanionStore instance = BookCompanionStore._();

  static const _key = 'book_companion_progress';

  /// bookId -> idea indices opened.
  final Map<String, Set<int>> _ideas = {};

  /// bookId -> chapter indices opened.
  final Map<String, Set<int>> _chapters = {};

  bool _loaded = false;

  /// Lazy-loaded from build (a no-op after the first call), matching the other
  /// reader stores — no main.dart wiring needed.
  void ensureLoaded() {
    if (_loaded) return;
    _loaded = true;
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) _apply(jsonDecode(raw) as Map);
      notifyListeners();
    } catch (_) {/* start empty */}
    try {
      await syncStateFromCloud();
    } catch (_) {/* stay local */}
  }

  // ---- reads ----------------------------------------------------------------
  bool ideaOpened(String bookId, int i) => _ideas[bookId]?.contains(i) ?? false;
  bool chapterOpened(String bookId, int i) => _chapters[bookId]?.contains(i) ?? false;
  int ideasExplored(String bookId) => _ideas[bookId]?.length ?? 0;
  int chaptersExplored(String bookId) => _chapters[bookId]?.length ?? 0;

  // ---- writes ---------------------------------------------------------------
  /// Opening is the interaction, so opening is what counts. Collapsing again
  /// does not un-explore it — you cannot un-read something.
  void markIdea(String bookId, int i) {
    if (_ideas.putIfAbsent(bookId, () => <int>{}).add(i)) _save();
  }

  void markChapter(String bookId, int i) {
    if (_chapters.putIfAbsent(bookId, () => <int>{}).add(i)) _save();
  }

  @visibleForTesting
  void reset(String bookId) {
    _ideas.remove(bookId);
    _chapters.remove(bookId);
    _save();
  }

  // ---- persistence ----------------------------------------------------------
  Map<String, Object?> _toMap() => {
        'ideas': _ideas.map((k, v) => MapEntry(k, v.toList())),
        'chapters': _chapters.map((k, v) => MapEntry(k, v.toList())),
      };

  void _apply(Map j) {
    Map<String, Set<int>> read(Object? o) => ((o as Map?) ?? const {}).map(
          (k, v) => MapEntry('$k', ((v as List?) ?? const []).map((e) => (e as num).toInt()).toSet()),
        );
    _ideas
      ..clear()
      ..addAll(read(j['ideas']));
    _chapters
      ..clear()
      ..addAll(read(j['chapters']));
  }

  Future<void> _save() async {
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_toMap()));
    } catch (_) {/* best-effort */}
  }

  @override
  String get cloudKey => 'book_companion_progress';
  @override
  Object cloudData() => _toMap();
  @override
  void applyCloudData(Object data) => _apply(data as Map);
  @override
  Future<void> persistLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_toMap()));
    } catch (_) {/* best-effort */}
  }
}
