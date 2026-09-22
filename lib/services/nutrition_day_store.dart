// =============================================================================
//  Nutrition — what she did with today
// -----------------------------------------------------------------------------
//  2026-09-20, the Nutrition door rebuild. The plate (nutrition_plate.dart)
//  is computed; this is what she did with it, per day:
//
//    water      glasses tapped, 0–8
//    ticks      which needs she ticked (iron, calcium, protein, folate, fibre)
//    swaps      slot key → the meal she swapped in
//    skipped    slot keys she marked "not today" (nausea is a valid reason)
//    cravings   what she reached for and when
//
//  plus three things that are not per day: her region (the chart facets'
//  own enum), a shopping list (recipe → ingredients, ticked as she buys),
//  and whether she wants the one gentle reminder.
//
//  ⚠️ A BLOB, BY THE SAME TEST AS can_i_activity_store.dart (BACKEND-PATTERNS
//  §16g): only she reads it, on her own phones, and it is small. Sixty days
//  of ticks and glasses is a few KB. Nobody counts across users here — if a
//  desk ever wants "how many women tick iron", that is a table and a
//  different decision. `CloudSyncedStore`, key `nutrition_day`.
//
//  ⚠️ KEYED BY LOCAL DATE STRING, NOT BY DateTime. A DateTime in a JSON blob
//  round-trips through UTC and a breakfast logged at 8 am IST would file
//  itself under yesterday on the way back. "2026-09-20" cannot drift.
//
//  ⚠️ NOTHING HERE IS A SCORE. There is no streak, no total, no "days
//  missed". `daysTicked(need)` exists for one sentence on the door ("iron,
//  four days this week") and that sentence is a celebration, never a
//  reproach — the calm rule, for a reader who may be nauseous, tired, or
//  simply not hungry today.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/diet_chart_facets.dart' show ChartRegion;
import '../data/nutrition/nutrition_plate.dart' show plateDateKey;
import 'remote/cloud_synced_store.dart';

/// One day.
class NutritionDay {
  NutritionDay({
    this.water = 0,
    Set<String>? ticks,
    Map<String, String>? swaps,
    Set<String>? skipped,
  })  : ticks = ticks ?? {},
        swaps = swaps ?? {},
        skipped = skipped ?? {};

  int water;
  final Set<String> ticks;
  final Map<String, String> swaps;
  final Set<String> skipped;

  bool get isEmpty => water == 0 && ticks.isEmpty && swaps.isEmpty && skipped.isEmpty;

  Map<String, dynamic> toJson() => {
        'water': water,
        'ticks': ticks.toList(),
        'swaps': swaps,
        'skipped': skipped.toList(),
      };

  static NutritionDay fromJson(Map<String, dynamic> j) => NutritionDay(
        water: (j['water'] as num?)?.toInt() ?? 0,
        ticks: {...(j['ticks'] as List? ?? const []).whereType<String>()},
        swaps: {for (final e in (j['swaps'] as Map? ?? const {}).entries) e.key.toString(): e.value.toString()},
        skipped: {...(j['skipped'] as List? ?? const []).whereType<String>()},
      );
}

/// A craving she logged.
class CravingLog {
  const CravingLog({required this.at, required this.kind});
  final DateTime at;

  /// 'sweet' | 'sour' | 'spicy' | 'salty' | 'ice' | 'other'
  final String kind;
}

/// One line on the shopping list.
class ShoppingItem {
  ShoppingItem({required this.recipeId, required this.name, this.done = false});
  final String recipeId;
  final String name;
  bool done;
  String get key => '$recipeId|$name';
}

class NutritionDayStore extends ChangeNotifier with CloudSyncedStore {
  NutritionDayStore._();
  static final NutritionDayStore instance = NutritionDayStore._();

  static const String _key = 'nutrition_day_v1';
  static const int kGlasses = 8;
  static const int kKeepDays = 60;

  SharedPreferences? _prefs;
  bool _loaded = false;
  final Map<String, NutritionDay> _days = {};
  final List<CravingLog> _cravings = [];
  final List<ShoppingItem> _shopping = [];
  ChartRegion? _region;
  bool _reminder = false;

  /// A chart she chose on its own page ("Make this my chart"). Null: Today
  /// picks the chart that fits her (`plateChartFor`). Persisted in the same
  /// blob as her region — one preference next to another.
  String? _pinnedChartId;

  ChartRegion? get region => _region;
  String? get pinnedChartId => _pinnedChartId;
  bool get reminder => _reminder;
  List<CravingLog> get cravings => List.unmodifiable(_cravings);
  List<ShoppingItem> get shopping => List.unmodifiable(_shopping);

  NutritionDay day(DateTime d) => _days.putIfAbsent(plateDateKey(d), NutritionDay.new);
  NutritionDay get today => day(DateTime.now());

  Future<void> init() async {
    if (_loaded) return;
    _loaded = true;
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_key);
    if (raw != null) {
      try {
        applyCloudData(jsonDecode(raw));
      } catch (_) {/* a bad cache is an empty one */}
    }
    notifyListeners();
    await syncStateFromCloud();
  }

  // ---- water ------------------------------------------------------------------

  void setWater(DateTime d, int glasses) {
    day(d).water = glasses.clamp(0, kGlasses);
    _save();
  }

  void tapGlass(DateTime d, int index) {
    final t = day(d);
    // Tapping the last filled glass empties it; tapping ahead fills up to it.
    t.water = (index + 1 == t.water) ? index : index + 1;
    _save();
  }

  // ---- ticks ------------------------------------------------------------------

  bool ticked(DateTime d, String need) => day(d).ticks.contains(need);

  void toggleTick(DateTime d, String need) {
    final t = day(d).ticks;
    if (!t.remove(need)) t.add(need);
    _save();
  }

  /// How many of the last seven days carry this tick — for one warm line.
  int daysTicked(String need, {DateTime? now}) {
    final n = now ?? DateTime.now();
    var c = 0;
    for (var i = 0; i < 7; i++) {
      final k = plateDateKey(n.subtract(Duration(days: i)));
      if (_days[k]?.ticks.contains(need) ?? false) c++;
    }
    return c;
  }

  // ---- the plate --------------------------------------------------------------

  String? swapFor(DateTime d, String slotKey) => day(d).swaps[slotKey];

  void setSwap(DateTime d, String slotKey, String? meal) {
    final t = day(d);
    if (meal == null) {
      t.swaps.remove(slotKey);
    } else {
      t.swaps[slotKey] = meal;
      t.skipped.remove(slotKey);
    }
    _save();
  }

  bool isSkipped(DateTime d, String slotKey) => day(d).skipped.contains(slotKey);

  void toggleSkip(DateTime d, String slotKey) {
    final t = day(d).skipped;
    if (!t.remove(slotKey)) t.add(slotKey);
    _save();
  }

  // ---- cravings ---------------------------------------------------------------

  void logCraving(String kind) {
    _cravings.insert(0, CravingLog(at: DateTime.now(), kind: kind));
    if (_cravings.length > 100) _cravings.removeRange(100, _cravings.length);
    _save();
  }

  /// The kind she has reached for most in the last seven days, if any.
  ({String kind, int times})? cravingPattern({DateTime? now}) {
    final n = now ?? DateTime.now();
    final counts = <String, int>{};
    for (final c in _cravings) {
      if (n.difference(c.at).inDays > 7) break;
      counts[c.kind] = (counts[c.kind] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return top.value >= 2 ? (kind: top.key, times: top.value) : null;
  }

  // ---- shopping ---------------------------------------------------------------

  void addToList(String recipeId, Iterable<String> names) {
    for (final n in names) {
      if (!_shopping.any((s) => s.recipeId == recipeId && s.name == n)) {
        _shopping.add(ShoppingItem(recipeId: recipeId, name: n));
      }
    }
    _save();
  }

  bool onList(String recipeId) => _shopping.any((s) => s.recipeId == recipeId);

  /// Is this one ingredient on the list?
  bool itemOnList(String recipeId, String name) =>
      _shopping.any((s) => s.recipeId == recipeId && s.name == name);

  /// One ingredient on or off. She has the onions already; the list should
  /// not make her delete them afterwards (2026-09-22 — Blinkit puts an ADD on
  /// every ingredient, and per-item is the half of that worth copying: the
  /// half that is a shopping list, not a shop).
  void toggleItem(String recipeId, String name) {
    final i = _shopping.indexWhere((s) => s.recipeId == recipeId && s.name == name);
    if (i == -1) {
      _shopping.add(ShoppingItem(recipeId: recipeId, name: name));
    } else {
      _shopping.removeAt(i);
    }
    _save();
  }

  void toggleBought(ShoppingItem item) {
    item.done = !item.done;
    _save();
  }

  void removeRecipeFromList(String recipeId) {
    _shopping.removeWhere((s) => s.recipeId == recipeId);
    _save();
  }

  void clearBought() {
    _shopping.removeWhere((s) => s.done);
    _save();
  }

  // ---- preferences ------------------------------------------------------------

  void setRegion(ChartRegion? r) {
    _region = r;
    _save();
  }

  void setReminder(bool on) {
    _reminder = on;
    _save();
  }

  void setPinnedChart(String? chartId) {
    _pinnedChartId = chartId;
    _save();
  }

  // ---- persistence ------------------------------------------------------------

  void _save() {
    _prune();
    persistLocalCache();
    notifyListeners();
  }

  void _prune() {
    final keep = <String>{
      for (var i = 0; i < kKeepDays; i++) plateDateKey(DateTime.now().subtract(Duration(days: i))),
    };
    _days.removeWhere((k, v) => !keep.contains(k) || v.isEmpty);
  }

  @override
  String get cloudKey => 'nutrition_day';

  @override
  Object cloudData() => {
        'days': {for (final e in _days.entries) e.key: e.value.toJson()},
        'cravings': [for (final c in _cravings) {'at': c.at.toIso8601String(), 'kind': c.kind}],
        'shopping': [for (final s in _shopping) {'r': s.recipeId, 'n': s.name, 'd': s.done}],
        'region': _region?.name,
        'reminder': _reminder,
        'chart': _pinnedChartId,
      };

  @override
  void applyCloudData(Object data) {
    if (data is! Map) return;
    _days.clear();
    final days = data['days'];
    if (days is Map) {
      for (final e in days.entries) {
        if (e.value is Map) _days[e.key.toString()] = NutritionDay.fromJson(Map<String, dynamic>.from(e.value as Map));
      }
    }
    _cravings.clear();
    final cr = data['cravings'];
    if (cr is List) {
      for (final c in cr) {
        if (c is Map && c['at'] is String && c['kind'] is String) {
          final at = DateTime.tryParse(c['at'] as String);
          if (at != null) _cravings.add(CravingLog(at: at, kind: c['kind'] as String));
        }
      }
    }
    _shopping.clear();
    final sh = data['shopping'];
    if (sh is List) {
      for (final s in sh) {
        if (s is Map && s['r'] is String && s['n'] is String) {
          _shopping.add(ShoppingItem(recipeId: s['r'] as String, name: s['n'] as String, done: s['d'] == true));
        }
      }
    }
    final r = data['region'];
    _region = r is String ? ChartRegion.values.where((x) => x.name == r).firstOrNull : null;
    _reminder = data['reminder'] == true;
    final ch = data['chart'];
    _pinnedChartId = ch is String && ch.isNotEmpty ? ch : null;
  }

  @override
  Future<void> persistLocalCache() async {
    final p = _prefs ??= await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(cloudData()));
  }

  @visibleForTesting
  void resetForTest() {
    _days.clear();
    _cravings.clear();
    _shopping.clear();
    _region = null;
    _reminder = false;
    _pinnedChartId = null;
  }
}
