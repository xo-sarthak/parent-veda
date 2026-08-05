// =============================================================================
//  ReadToBabySavedStore - read-to-baby pieces the mother has bookmarked
// -----------------------------------------------------------------------------
//  The day's read-to-baby piece is ephemeral, so saving keeps a copy (title,
//  body, source tag) with a timestamp - surfaced newest-first in the Saved hub.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_synced_store.dart';

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

class ReadToBabySavedStore extends ChangeNotifier with CloudSyncedStore {
  ReadToBabySavedStore._();
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
    await syncStateFromCloud();
  }

  // --- cloud sync ------------------------------------------------------------
  @override
  String get cloudKey => 'rtb_saved';
  @override
  Object cloudData() => _items.map((e) => e.toJson()).toList();
  @override
  void applyCloudData(Object data) => _items
    ..clear()
    ..addAll((data as List)
        .map((e) => SavedRtbPiece.fromJson(Map<String, dynamic>.from(e))));
  @override
  Future<void> persistLocalCache() => _persist();

  bool isSaved(String key) => _items.any((p) => p.key == key);
  bool get isEmpty => _items.isEmpty;

  /// Newest-saved first.
  List<SavedRtbPiece> recent() {
    final l = [..._items];
    l.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return l;
  }

  /// [key] identifies the piece and must not change with language; [title] is
  /// what she sees in the Saved hub and may. They are the same string until a
  /// caller has a translated title to hand, which is why [title] is optional.
  void toggleSave(String key, String body, String tag, {String? title}) {
    final idx = _items.indexWhere((p) => p.key == key);
    if (idx >= 0) {
      _items.removeAt(idx);
    } else {
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
