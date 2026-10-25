// =============================================================================
//  The foods a child has tried (tools pass, Food family, 2026-10-25)
// -----------------------------------------------------------------------------
//  "Can my baby eat this?" answers whether a food is right for his age. This
//  remembers which ones he has actually had: the day of the first try, and a
//  reaction if there was one. Asked for by the plan's D1, with the user's
//  answer "Yes, and partner sees it".
//
//  WHY A CHILD TABLE AND NOT A user_state ITEM. DevStore keeps its check-in
//  answers in the person's own user_state row (§16pp), which is right for a
//  thing only she reads. A first try is different: whoever feeds lunch needs
//  to know egg is no longer new. So it lives where milestones live, one row
//  per (child, food) in a co-parented table (0115), and syncs the same way:
//  local first, newer wins per row, a soft delete for Undo (0104's ledger).
//  BACKEND-PATTERNS §16rr says it as a rule: who needs to see a record
//  decides its table.
//
//  ⚠️ NEVER A DIAGNOSIS. A reaction is what the parent saw, stored in her
//  words and listed for the doctor. Nothing here concludes "allergic".
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/child_scoped_store.dart';
import '../../services/remote/supabase_repo.dart';
import '../../services/remote/sync_registry.dart';
import 'pp_child_profile.dart';

/// What the parent saw after a first try. ⚠️ `.name` is persisted and synced:
/// never rename a value.
enum FoodReaction { none, mild, doctor }

extension FoodReactionText on FoodReaction {
  String get label => switch (this) {
        FoodReaction.none => 'No reaction',
        FoodReaction.mild => 'A mild reaction',
        FoodReaction.doctor => 'We saw a doctor',
      };
}

class FoodTry {
  const FoodTry({required this.date, this.reaction = FoodReaction.none, this.note});
  final DateTime date;
  final FoodReaction reaction;
  final String? note;

  bool get hadReaction => reaction != FoodReaction.none;

  Map<String, Object?> toJson() => {
        'date': SupabaseRepo.dbTime(date),
        'reaction': reaction.name,
        if (note != null) 'note': note,
      };

  static FoodTry fromJson(Map j) => FoodTry(
        date: SupabaseRepo.parseDbTime(j['date']),
        reaction: reactionFrom(j['reaction']),
        note: j['note']?.toString(),
      );

  /// Lenient: an unknown value from the other phone reads as none rather
  /// than failing the whole pull.
  static FoodReaction reactionFrom(Object? v) =>
      FoodReaction.values.firstWhere((r) => r.name == v, orElse: () => FoodReaction.none);
}

/// The stable id of a food in the checker's catalogue: its name as a slug.
/// The app generates it, so a local row and its cloud copy share one key.
String ppFoodId(String name) => name
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');

class PpFoodTriesStore extends ChangeNotifier {
  PpFoodTriesStore._();
  static final PpFoodTriesStore instance = PpFoodTriesStore._();

  final PerChild<Map<String, FoodTry>> _byChild =
      PerChild<Map<String, FoodTry>>(() => {});
  Map<String, FoodTry> get _tries => _byChild.of(_childId, _childId);

  bool _loaded = false;
  static const _prefsKey = 'pp_food_tries';
  static const table = 'pp_food_tries';
  // Newer-wins bookkeeping, keyed by food (0104's ledger, 0115's table).
  final ChildLogLedger _sync =
      ChildLogLedger(table, 'pp_food_tries_sync', keyColumn: 'food_id');

  String? get _childId => ChildProfileStore.instance.activeChildId;

  // ---- persistence (local-first, then cloud) -------------------------------
  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final j = Map<String, dynamic>.from(jsonDecode(raw));
        _byChild.loadJson(j['byChild'], (v) => v is Map ? _mapFrom(v) : null);
      }
    } catch (_) {/* start empty */}
    await _sync.load();
    SyncRegistry.registerPending(_hasPending);
    // Switching child changes what every read returns.
    ChildProfileStore.instance.addListener(notifyListeners);
    _loaded = true;
    notifyListeners();
    try {
      await _syncFromCloud();
    } catch (_) {/* stay local */}
  }

  /// A sign-out, or another account signing in: forget the person in memory;
  /// the cloud keeps it.
  void _resetLocal() {
    _byChild.clear();
    _sync.clear();
    notifyListeners();
  }

  /// Test-only: empty, for every child, and loaded, so nothing reads prefs.
  @visibleForTesting
  void debugReset() {
    _resetLocal();
    _loaded = true;
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    SyncRegistry.registerReset(_resetLocal);
    final childId = _childId;
    if (!SupabaseRepo.isLoggedIn || childId == null) return;
    try {
      // Every child, the one on screen first (B11's loop).
      for (final c in [childId, ...ChildProfileStore.instance.childIds.where((x) => x != childId)]) {
        final held = _byChild.of(c, childId);
        final merged = await _sync.pull<MapEntry<String, FoodTry>>(
          childId: c,
          local: held.entries.toList(),
          idOf: (e) => e.key,
          fromRow: (r) => MapEntry(
            (r['food_id'] ?? '').toString(),
            FoodTry(
              date: SupabaseRepo.parseDbTime(r['first_tried']),
              reaction: FoodTry.reactionFrom(r['reaction']),
              note: r['note']?.toString(),
            ),
          ),
        );
        held
          ..clear()
          ..addEntries(merged);
      }
      await _persist();
      notifyListeners();
      await _pushWaiting();
    } catch (_) {/* offline - keep local */}
  }

  bool _hasPending() => _sync.hasPending;

  /// The row's own columns (0115). Pinned by `test/pp_food_tools_test.dart`.
  static Map<String, dynamic> cols(String id, FoodTry t) => {
        'food_id': id,
        'first_tried': SupabaseRepo.dbTime(t.date),
        'reaction': t.reaction.name,
        'note': t.note,
      };

  /// Uploads whatever the cloud has not confirmed.
  Future<void> _pushWaiting() => _sync.push(
        () => {for (final e in _tries.entries) e.key: cols(e.key, e.value)},
        fallbackChildId: _childId,
      );

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode({
          'byChild': _byChild.toJson((m) => m.map((id, t) => MapEntry(id, t.toJson()))),
        }),
      );
    } catch (_) {}
  }

  static Map<String, FoodTry> _mapFrom(Map j) => {
        for (final e in j.entries)
          if (e.value is Map) e.key.toString(): FoodTry.fromJson(e.value as Map),
      };

  // ---- reads (the child on screen) -----------------------------------------
  bool tried(String foodId) => _tries.containsKey(foodId);
  FoodTry? tryOf(String foodId) => _tries[foodId];
  int get count => _tries.length;

  /// Most recent first: (food id, try).
  List<MapEntry<String, FoodTry>> get recent =>
      _tries.entries.toList()..sort((a, b) => b.value.date.compareTo(a.value.date));

  /// Tries with a reaction since [since], most recent first. For Before you
  /// see the doctor (behind the `foods` yes).
  List<MapEntry<String, FoodTry>> reactionsSince(DateTime since) =>
      recent.where((e) => e.value.hadReaction && !e.value.date.isBefore(since)).toList();

  // ---- writes ---------------------------------------------------------------
  void markTried(String foodId, {DateTime? date, FoodReaction reaction = FoodReaction.none, String? note}) {
    final t = FoodTry(date: date ?? DateTime.now(), reaction: reaction, note: note);
    _tries[foodId] = t;
    notifyListeners();
    _persist();
    _sync.touch(foodId, _childId, columns: cols(foodId, t));
    _pushWaiting();
  }

  /// Undo, or "not tried after all": a soft delete that uploads like any
  /// other change, so the other phone loses it too.
  void unmark(String foodId) {
    final was = _tries.remove(foodId);
    notifyListeners();
    _persist();
    if (was != null) _sync.remove(foodId, cols(foodId, was), _childId);
    _pushWaiting();
  }

  /// Puts back exactly what [unmark] or an overwrite took away (Undo).
  void restore(String foodId, FoodTry? previous) {
    if (previous == null) {
      unmark(foodId);
    } else {
      markTried(foodId, date: previous.date, reaction: previous.reaction, note: previous.note);
    }
  }
}
