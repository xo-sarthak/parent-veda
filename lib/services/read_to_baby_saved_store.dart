// =============================================================================
//  ReadToBabySavedStore - read-to-baby pieces the mother has bookmarked
// -----------------------------------------------------------------------------
//  The day's read-to-baby piece is ephemeral, so saving keeps a copy (title,
//  body, source tag) with a timestamp - surfaced newest-first in the Saved hub.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_merged_store.dart';
// import 'remote/cloud_synced_store.dart'; // kept for revert (step 13)
import 'saved_store.dart';

class SavedRtbPiece {
  const SavedRtbPiece({
    required this.key,
    required this.title,
    required this.body,
    required this.tag,
    required this.savedAt,
  });

  /// What this piece IS, independent of the language it is being read in.
  ///
  /// Separate from [title] on purpose. Before the Hindi migration the two were
  /// one field, and a bookmark was found by comparing the displayed title -
  /// which works exactly until the title is translated. Then the same piece
  /// answers to a different name in each language: marks made in English go
  /// missing in Hindi, come back on switching, and re-saving in Hindi produces
  /// a duplicate row. It syncs to Supabase too, so the split would follow her
  /// across devices.
  ///
  /// The key is the ENGLISH string. That choice costs nothing to adopt - every
  /// key already persisted IS an English title, so old rows migrate for free
  /// (see [fromJson]) and no data has to be rewritten on device or in cloud.
  /// What it does not fix: editing the English copy still orphans a bookmark.
  /// Stable synthetic ids would, and would need a migration on both sides -
  /// worth doing the day content ids exist, not worth blocking a translation on.
  final String key;

  /// The snapshot as she saved it - shown in the Saved hub. Deliberately NOT
  /// re-resolved on language change: a bookmark records what she chose to keep.
  final String title;
  final String body;
  final String tag; // source label (e.g. "Affirmations", "Hinduism")
  final int savedAt;

  Map<String, dynamic> toJson() =>
      {'k': key, 't': title, 'b': body, 'g': tag, 's': savedAt};

  factory SavedRtbPiece.fromJson(Map<String, dynamic> j) {
    final title = j['t'] as String? ?? '';
    return SavedRtbPiece(
      // Rows written before the key existed carry their English title in 't'.
      key: j['k'] as String? ?? title,
      title: title,
      body: j['b'] as String? ?? '',
      tag: j['g'] as String? ?? '',
      savedAt: (j['s'] as num?)?.toInt() ?? 0,
    );
  }
}

// ⚠️ MEMBERSHIP MOVED TO SavedStore ON 2026-09-16 (docs/FAMILY-MODEL.md §5).
// Whether a piece IS saved is a `saved_items` row of kind `read_to_baby`,
// owned by the person. What stays here is the BODY CACHE: a read-to-baby piece
// is a few paragraphs she reads aloud, and the row carries only title and tag,
// so the text is kept locally (and in this store's blob) so the Saved screen
// can open it. A fresh device with the row but no cached body shows the title
// and tag and opens Samvad — never a blank row.
//
// Per-item since step 13 (2026-10-22, sync log). The body cache synced as one
// whole blob, so a piece saved on one phone could be erased by the other
// phone's older list. One item per piece key, value = the piece's JSON
// (key, title, body, tag, saved-at); order on apply is by saved-at.
class ReadToBabySavedStore extends ChangeNotifier with CloudMergedStore {
  ReadToBabySavedStore._() {
    SavedStore.instance.addListener(notifyListeners);
  }
  static final ReadToBabySavedStore instance = ReadToBabySavedStore._();

  static const _key = 'rtb_saved';
  final List<SavedRtbPiece> _items = [];
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _items.add(SavedRtbPiece.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
    await SavedStore.instance.load();
    // await syncStateFromCloud(); // kept for revert (step 13)
    await syncMergedFromCloud();
  }

  // --- cloud sync ------------------------------------------------------------
  @override
  String get cloudKey => 'rtb_saved';
  @override
  String? get legacyBlobKey => cloudKey;

  // Kept for revert (step 13): applyCloudItems({}) is the empty state now.
  //   /// What a sign-out resets this store to (2026-10-17): the blob of a store nobody has used.
  //   @override
  //   Object get cloudEmptyData => const <Object>[];
  //
  //   @override
  //   Object cloudData() => _items.map((e) => e.toJson()).toList();

  @override
  void applyLegacyBlob(Object blob) => _items
    ..clear()
    ..addAll((blob as List)
        .map((e) => SavedRtbPiece.fromJson(Map<String, dynamic>.from(e))));

  @override
  Map<String, Object?> cloudItems() =>
      {for (final p in _items) p.key: p.toJson()};

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _items.clear();
    for (final e in items.entries) {
      final v = e.value;
      if (v is! Map) continue;
      final p = SavedRtbPiece.fromJson(Map<String, dynamic>.from(v));
      _items.add(SavedRtbPiece(
          key: e.key, title: p.title, body: p.body, tag: p.tag, savedAt: p.savedAt));
    }
    _items.sort((a, b) => a.savedAt.compareTo(b.savedAt));
    _loaded = true;
  }
  @override
  Future<void> persistLocalCache() => _persist();

  bool isSaved(String key) => SavedStore.instance.isSaved(SavedKind.readToBaby, key);
  bool get isEmpty => SavedStore.instance.count(SavedKind.readToBaby) == 0;
  // Kept for revert:
  // bool isSaved(String key) => _items.any((p) => p.key == key);
  // bool get isEmpty => _items.isEmpty;

  /// The cached body for a saved key, when this device has it.
  SavedRtbPiece? cached(String key) {
    for (final p in _items) {
      if (p.key == key) return p;
    }
    return null;
  }

  /// Newest-saved first — driven by SavedStore's rows, bodies from the cache.
  List<SavedRtbPiece> recent() {
    return [
      for (final r in SavedStore.instance.items(kind: SavedKind.readToBaby))
        cached(r.itemId) ??
            SavedRtbPiece(
              key: r.itemId,
              title: r.title.isEmpty ? r.itemId : r.title,
              body: '',
              tag: r.subtitle ?? '',
              savedAt: r.savedAt.millisecondsSinceEpoch,
            ),
    ];
  }

  /// [key] identifies the piece and must not change with language; [title] is
  /// what she sees in the Saved hub and may. They are the same string until a
  /// caller has a translated title to hand, which is why [title] is optional.
  void toggleSave(String key, String body, String tag, {String? title}) {
    final wasSaved = isSaved(key);
    SavedStore.instance.toggle(SavedKind.readToBaby, key,
        title: title ?? key, subtitle: tag);
    // The body cache follows membership: keep the text while saved, drop it
    // on unsave. The cache is never consulted for "is it saved".
    final idx = _items.indexWhere((p) => p.key == key);
    if (wasSaved) {
      if (idx >= 0) _items.removeAt(idx);
    } else if (idx < 0) {
      _items.add(SavedRtbPiece(
        key: key,
        title: title ?? key,
        body: body,
        tag: tag,
        savedAt: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(_items.map((e) => e.toJson()).toList()));
    } catch (_) {/* best-effort */}
  }
}
