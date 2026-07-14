// =============================================================================
//  Product Guide — the parent's own vote ("mark your own")
// -----------------------------------------------------------------------------
//  Every parent can add their own verdict to a product's buy signal. A tiny
//  local (shared_preferences) ChangeNotifier singleton, app-independent like the
//  rest of the Product Guide module. Their vote nudges the "parents like you"
//  number and shows their mark on the card.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PgVote { none, recommend, notForUs }

class ProductGuideVotes extends ChangeNotifier {
  ProductGuideVotes._();
  static final ProductGuideVotes instance = ProductGuideVotes._();

  static const _key = 'pg_votes';
  final Map<String, PgVote> _votes = {};
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final m = jsonDecode(raw) as Map;
        m.forEach((k, v) {
          _votes[k.toString()] = PgVote.values.firstWhere((e) => e.name == v.toString(), orElse: () => PgVote.none);
        });
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
  }

  PgVote voteFor(String id) => _votes[id] ?? PgVote.none;

  /// Tap the same choice again to un-vote (toggle back to none).
  void cast(String id, PgVote v) {
    final current = voteFor(id);
    _votes[id] = current == v ? PgVote.none : v;
    _save();
  }

  Future<void> _save() async {
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_votes.map((k, v) => MapEntry(k, v.name))));
    } catch (_) {/* best-effort */}
  }
}
