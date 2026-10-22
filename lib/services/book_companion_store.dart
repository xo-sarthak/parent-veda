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

import 'remote/cloud_merged_store.dart';
// import 'remote/cloud_synced_store.dart'; // kept for revert (step 13)

// In the cloud per item since step 13 (2026-10-22, sync log). It synced as one
// whole blob before, so two phones opening different chapters erased each
// other's progress. Items: `idea|<bookId>|<i>` and `chapter|<bookId>|<i>`,
// value true, so an opened idea on either phone is kept.
class BookCompanionStore extends ChangeNotifier with CloudMergedStore {
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
      // await syncStateFromCloud(); // kept for revert (step 13)
      await syncMergedFromCloud();
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
  // Kept for revert (step 13): the whole-blob mixin's empty state and blob.
  //   /// What a sign-out resets this store to (2026-10-17): the blob of a store nobody has used.
  //   @override
  //   Object get cloudEmptyData => const <String, Object?>{'ideas': <String, Object>{}, 'chapters': <String, Object>{}};
  //
  //   @override
  //   Object cloudData() => _toMap();

  @override
  String? get legacyBlobKey => cloudKey;

  /// The old whole blob, read once on a phone that holds nothing yet.
  @override
  void applyLegacyBlob(Object blob) => _apply(blob as Map);

  @override
  Map<String, Object?> cloudItems() => {
        for (final e in _ideas.entries)
          for (final i in e.value) 'idea|${e.key}|$i': true,
        for (final e in _chapters.entries)
          for (final i in e.value) 'chapter|${e.key}|$i': true,
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _ideas.clear();
    _chapters.clear();
    for (final k in items.keys) {
      final first = k.indexOf('|');
      final last = k.lastIndexOf('|');
      if (first <= 0 || last <= first) continue;
      final kind = k.substring(0, first);
      final book = k.substring(first + 1, last);
      final i = int.tryParse(k.substring(last + 1));
      if (i == null) continue;
      final target = kind == 'idea' ? _ideas : kind == 'chapter' ? _chapters : null;
      target?.putIfAbsent(book, () => <int>{}).add(i);
    }
    _loaded = true; // a later ensureLoaded must not read stale prefs over this
  }

  @override
  Future<void> persistLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_toMap()));
    } catch (_) {/* best-effort */}
  }
}
