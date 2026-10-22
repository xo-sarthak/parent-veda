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

import '../../services/remote/cloud_merged_store.dart';
// import '../../services/remote/sync_registry.dart'; // kept for revert (step 13: the mixin registers)

enum PgVote { none, recommend, notForUs }

// In the cloud since step 13 (2026-10-22, sync log). It was phone-only, so a
// sign-out or a new phone lost every vote she had cast. Items: one per product
// id, value the vote's name; a vote taken back to none is no item.
class ProductGuideVotes extends ChangeNotifier with CloudMergedStore {
  ProductGuideVotes._();
  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   ProductGuideVotes._() {
  //     SyncRegistry.registerReset(_resetForAccount);
  //   }
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
    await syncMergedFromCloud();
  }

  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  //   // are wiped, the singleton was not.
  //   void _resetForAccount() {
  //     _votes.clear();
  //     _loaded = false;
  //     notifyListeners();
  //   }

  // ---- the cloud (step 13) --------------------------------------------------

  @override
  String get cloudKey => 'pg_votes';

  @override
  Map<String, Object?> cloudItems() => {
        for (final e in _votes.entries)
          if (e.value != PgVote.none) e.key: e.value.name,
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _votes.clear();
    for (final e in items.entries) {
      final v = PgVote.values.firstWhere((x) => x.name == '${e.value}',
          orElse: () => PgVote.none);
      if (v != PgVote.none) _votes[e.key] = v;
    }
    _loaded = true;
  }

  @override
  Future<void> persistLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_votes.map((k, v) => MapEntry(k, v.name))));
    } catch (_) {/* best-effort */}
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
