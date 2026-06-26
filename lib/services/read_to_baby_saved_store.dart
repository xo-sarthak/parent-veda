// =============================================================================
//  ReadToBabySavedStore — read-to-baby pieces the mother has bookmarked
// -----------------------------------------------------------------------------
//  The day's read-to-baby piece is ephemeral, so saving keeps a copy (title,
//  body, source tag) with a timestamp — surfaced newest-first in the Saved hub.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedRtbPiece {
  const SavedRtbPiece({
    required this.title,
    required this.body,
    required this.tag,
    required this.savedAt,
  });
  final String title;
  final String body;
  final String tag; // source label (e.g. "Affirmations", "Hinduism")
  final int savedAt;

  Map<String, dynamic> toJson() =>
      {'t': title, 'b': body, 'g': tag, 's': savedAt};
  factory SavedRtbPiece.fromJson(Map<String, dynamic> j) => SavedRtbPiece(
        title: j['t'] as String? ?? '',
        body: j['b'] as String? ?? '',
        tag: j['g'] as String? ?? '',
        savedAt: (j['s'] as num?)?.toInt() ?? 0,
      );
}

class ReadToBabySavedStore extends ChangeNotifier {
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
  }

  bool isSaved(String title) => _items.any((p) => p.title == title);
  bool get isEmpty => _items.isEmpty;

  /// Newest-saved first.
  List<SavedRtbPiece> recent() {
    final l = [..._items];
    l.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return l;
  }

  void toggleSave(String title, String body, String tag) {
    final idx = _items.indexWhere((p) => p.title == title);
    if (idx >= 0) {
      _items.removeAt(idx);
    } else {
      _items.add(SavedRtbPiece(
        title: title,
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
