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

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/diet_chart_facets.dart' show ChartRegion;
import '../data/nutrition/nutrition_plate.dart' show plateDateKey;
import 'remote/cloud_merged_store.dart';
// import 'remote/cloud_synced_store.dart'; // kept for revert (step 13)

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

/// The group her own typed items sit under on the list (P4 S5, 2026-10-28).
/// A recipe id, as far as the store and the sync key are concerned:
/// `shop|own|<name>`. A recipe id never holds a bar, and this one does not.
const String kOwnListId = 'own';

/// A line taken off the list, with where it sat, so an Undo puts it back in
/// the same place (P4 S5).
typedef ShoppingLine = ({ShoppingItem item, int order});

/// One line on the shopping list.
class ShoppingItem {
  ShoppingItem({required this.recipeId, required this.name, this.done = false});
  final String recipeId;
  final String name;
  bool done;
  String get key => '$recipeId|$name';
}

// Per-item since step 13 (2026-10-22, sync log). It synced as one whole blob,
// so a glass tapped on one phone and a tick on the other erased each other.
// Items: `water|<date>` (glasses), `tick|<date>|<need>`, `swap|<date>|<slot>`
// (the meal), `skip|<date>|<slot>`, `craving|<ISO time>` (the kind),
// `shop|<recipeId>|<name>` ({d: bought, o: order}), and `region`, `reminder`,
// `chart` (each only when set, so an unused store has no items).
class NutritionDayStore extends ChangeNotifier with CloudMergedStore {
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

  // ⚠️ NOTHING IS WRITTEN BEFORE THE CACHE IS READ (P4 S2, 2026-10-28).
  // Every mutation saves the WHOLE local blob (`persistLocalCache`). Only the
  // Nutrition door and the Today body called `init`, so a recipe's "Add to my
  // list" opened another way changed an empty store and saved it, writing
  // over `nutrition_day_v1`: her water, ticks and list went, for good when
  // logged out (nothing in the cloud to bring them back).
  //
  // The fix, and its trade-off: before the cache is read, a mutation is held
  // (`_waiting`), the read is started, and the held edits are replayed on top
  // of what was read. The other way was to make every mutator `async` and
  // await `init` first: the same result, but every caller (sync taps in a
  // dozen screens) would change shape. Replaying costs one thing: an edit made
  // in the few milliseconds before the read lands shows when the read lands,
  // not at the tap. A late tick is better than a lost day. Removals that
  // return what they took return nothing in that window, which is right:
  // before the read there is nothing on screen to remove.
  bool _cacheRead = false;
  final List<VoidCallback> _waiting = [];
  Future<void>? _starting;

  // Kept for revert (P4 S2): the old init, which a second caller returned
  // from before the first had read anything.
  // Future<void> init() async {
  //   if (_loaded) return;
  //   _loaded = true;
  //   _prefs = await SharedPreferences.getInstance();
  //   ...
  // }
  /// Reads the cache and starts the sync. Safe to call from every screen;
  /// every caller waits for the same read.
  Future<void> init() {
    if (_starting case final f?) return f;
    if (_loaded) return Future.value();
    return _starting = _start();
  }

  Future<void> _start() async {
    _loaded = true;
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_key);
    if (raw != null) {
      try {
        _fromBlob(jsonDecode(raw));
      } catch (_) {/* a bad cache is an empty one */}
    }
    _cacheRead = true;
    if (_waiting.isNotEmpty) {
      final held = List.of(_waiting);
      _waiting.clear();
      for (final edit in held) {
        edit();
      }
      _prune();
      await persistLocalCache();
    }
    notifyListeners();
    // await syncStateFromCloud(); // kept for revert (step 13)
    await syncMergedFromCloud();
  }

  /// Every mutation goes through here: applied and saved now, or held until
  /// the cache is read (see above).
  void _change(VoidCallback edit) {
    if (_cacheRead) {
      edit();
      _save();
      return;
    }
    _waiting.add(edit);
    unawaited(init());
  }

  // ---- water ------------------------------------------------------------------

  void setWater(DateTime d, int glasses) =>
      _change(() => day(d).water = glasses.clamp(0, kGlasses));

  void tapGlass(DateTime d, int index) => _change(() {
        final t = day(d);
        // Tapping the last filled glass empties it; tapping ahead fills up to it.
        t.water = (index + 1 == t.water) ? index : index + 1;
      });

  // ---- ticks ------------------------------------------------------------------

  bool ticked(DateTime d, String need) => day(d).ticks.contains(need);

  void toggleTick(DateTime d, String need) => _change(() {
        final t = day(d).ticks;
        if (!t.remove(need)) t.add(need);
      });

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

  void setSwap(DateTime d, String slotKey, String? meal) => _change(() {
        final t = day(d);
        if (meal == null) {
          t.swaps.remove(slotKey);
        } else {
          t.swaps[slotKey] = meal;
          t.skipped.remove(slotKey);
        }
      });

  bool isSkipped(DateTime d, String slotKey) => day(d).skipped.contains(slotKey);

  void toggleSkip(DateTime d, String slotKey) => _change(() {
        final t = day(d).skipped;
        if (!t.remove(slotKey)) t.add(slotKey);
      });

  // ---- cravings ---------------------------------------------------------------

  void logCraving(String kind) {
    final at = DateTime.now();
    _change(() {
      _cravings.insert(0, CravingLog(at: at, kind: kind));
      if (_cravings.length > 100) _cravings.removeRange(100, _cravings.length);
    });
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
    final list = names.toList();
    _change(() {
      for (final n in list) {
        if (!_shopping.any((s) => s.recipeId == recipeId && s.name == n)) {
          final item = ShoppingItem(recipeId: recipeId, name: n);
          _shopping.add(item);
          _shopOrder[item.key] = _nextOrder();
        }
      }
    });
  }

  /// Something she typed herself (P4 S5): under "Your own", synced per item
  /// like every other line (`shop|own|<name>`). False when it is empty or
  /// already on her own list.
  bool addOwnItem(String name) {
    final n = name.trim();
    if (n.isEmpty) return false;
    if (_cacheRead && itemOnList(kOwnListId, n)) return false;
    addToList(kOwnListId, [n]);
    return true;
  }

  bool onList(String recipeId) => _shopping.any((s) => s.recipeId == recipeId);

  /// Is this one ingredient on the list?
  bool itemOnList(String recipeId, String name) =>
      _shopping.any((s) => s.recipeId == recipeId && s.name == name);

  /// One ingredient on or off. She has the onions already; the list should
  /// not make her delete them afterwards (2026-09-22 — Blinkit puts an ADD on
  /// every ingredient, and per-item is the half of that worth copying: the
  /// half that is a shopping list, not a shop).
  void toggleItem(String recipeId, String name) => _change(() {
        final i = _shopping.indexWhere((s) => s.recipeId == recipeId && s.name == name);
        if (i == -1) {
          final item = ShoppingItem(recipeId: recipeId, name: name);
          _shopping.add(item);
          _shopOrder[item.key] = _nextOrder();
        } else {
          _shopping.removeAt(i);
        }
      });

  // By key, not by the object (P4 S2): a held edit replays after the read,
  // when the list holds new objects for the same lines. Kept for revert:
  //   item.done = !item.done; _save();
  void toggleBought(ShoppingItem item) => _change(() {
        for (final s in _shopping) {
          if (s.key == item.key) s.done = !s.done;
        }
      });

  // P4 S5 (2026-10-28): the removals hand back what they took, so the screen
  // can say so and offer Undo. Kept for revert: each was
  //   `_shopping.removeWhere(...); _save();` returning nothing.

  /// Takes a whole group off. Returns the lines removed.
  List<ShoppingLine> removeRecipeFromList(String recipeId) =>
      _removeWhere((s) => s.recipeId == recipeId);

  /// Takes the ticked lines off. Returns the lines removed.
  List<ShoppingLine> clearBought() => _removeWhere((s) => s.done);

  /// Takes one line off. Returns it, or null if it was not there.
  ShoppingLine? removeItem(ShoppingItem item) =>
      _removeWhere((s) => s.key == item.key).firstOrNull;

  List<ShoppingLine> _removeWhere(bool Function(ShoppingItem s) test) {
    var gone = <ShoppingLine>[];
    _change(() {
      gone = [
        for (final s in _shopping)
          if (test(s)) (item: s, order: _orderOf(s)),
      ];
      _shopping.removeWhere(test);
    });
    return gone;
  }

  /// Undo for a removal: the lines back where they were, ticks as they were.
  /// A line already back on the list is left alone.
  void restoreLines(List<ShoppingLine> lines) {
    if (lines.isEmpty) return;
    _change(() {
      for (final l in lines) {
        if (_shopping.any((s) => s.key == l.item.key)) continue;
        _shopping.add(ShoppingItem(
            recipeId: l.item.recipeId, name: l.item.name, done: l.item.done));
        _shopOrder[l.item.key] = l.order;
      }
      // The list is always in order of adding (`_shopOrder`), as a load
      // leaves it; a restored line goes back to its own place.
      _shopping.sort((a, b) {
        final c = _orderOf(a).compareTo(_orderOf(b));
        return c != 0 ? c : a.key.compareTo(b.key);
      });
    });
  }

  // ---- preferences ------------------------------------------------------------

  void setRegion(ChartRegion? r) => _change(() => _region = r);

  void setReminder(bool on) => _change(() => _reminder = on);

  void setPinnedChart(String? chartId) => _change(() => _pinnedChartId = chartId);

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
  String? get legacyBlobKey => cloudKey;

  // Kept for revert (step 13): applyCloudItems({}) is the empty state now,
  // and the blob shape lives on as the local cache (_blob / _fromBlob).
  //   /// What a sign-out resets this store to (2026-10-17): the blob of a store nobody has used.
  //   @override
  //   Object get cloudEmptyData => const <String, Object?>{};
  //
  //   @override
  //   Object cloudData() => {
  //         'days': {for (final e in _days.entries) e.key: e.value.toJson()},
  //         'cravings': [for (final c in _cravings) {'at': c.at.toIso8601String(), 'kind': c.kind}],
  //         'shopping': [for (final s in _shopping) {'r': s.recipeId, 'n': s.name, 'd': s.done}],
  //         'region': _region?.name,
  //         'reminder': _reminder,
  //         'chart': _pinnedChartId,
  //       };

  /// Where each shopping line sits in the list, so the order survives a
  /// merge (the server hands items back in no particular order). Set once,
  /// when the line is added; a removal never renumbers the others.
  final Map<String, int> _shopOrder = {};
  int _lastOrder = 0;

  int _nextOrder() {
    final now = DateTime.now().microsecondsSinceEpoch;
    _lastOrder = now > _lastOrder ? now : _lastOrder + 1;
    return _lastOrder;
  }

  int _orderOf(ShoppingItem s) => _shopOrder[s.key] ?? 0;

  /// The local cache: the old blob shape, plus each shopping line's order.
  Map<String, Object?> _blob() => {
        'days': {for (final e in _days.entries) e.key: e.value.toJson()},
        'cravings': [for (final c in _cravings) {'at': c.at.toIso8601String(), 'kind': c.kind}],
        'shopping': [for (final s in _shopping) {'r': s.recipeId, 'n': s.name, 'd': s.done, 'o': _orderOf(s)}],
        'region': _region?.name,
        'reminder': _reminder,
        'chart': _pinnedChartId,
      };

  @override
  void applyLegacyBlob(Object blob) => _fromBlob(blob);

  @override
  Map<String, Object?> cloudItems() {
    final out = <String, Object?>{};
    for (final e in _days.entries) {
      final d = e.key;
      final day = e.value;
      if (day.water != 0) out['water|$d'] = day.water;
      for (final n in day.ticks) {
        out['tick|$d|$n'] = true;
      }
      for (final s in day.swaps.entries) {
        out['swap|$d|${s.key}'] = s.value;
      }
      for (final k in day.skipped) {
        out['skip|$d|$k'] = true;
      }
    }
    for (final c in _cravings) {
      out['craving|${c.at.toIso8601String()}'] = c.kind;
    }
    for (final s in _shopping) {
      out['shop|${s.recipeId}|${s.name}'] = {'d': s.done, 'o': _orderOf(s)};
    }
    if (_region != null) out['region'] = _region!.name;
    if (_reminder) out['reminder'] = true;
    if (_pinnedChartId != null) out['chart'] = _pinnedChartId;
    return out;
  }

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _days.clear();
    _cravings.clear();
    _shopping.clear();
    _shopOrder.clear();
    _region = null;
    _reminder = false;
    _pinnedChartId = null;
    final shop = <({ShoppingItem item, int order})>[];
    for (final e in items.entries) {
      final k = e.key;
      final v = e.value;
      final bar = k.indexOf('|');
      final kind = bar < 0 ? k : k.substring(0, bar);
      final rest = bar < 0 ? '' : k.substring(bar + 1);
      // `<date>|<id>` for the per-day items; the date never holds a bar.
      final bar2 = rest.indexOf('|');
      final date = bar2 < 0 ? rest : rest.substring(0, bar2);
      final id = bar2 < 0 ? '' : rest.substring(bar2 + 1);
      switch (kind) {
        case 'water':
          if (v is num && date.isNotEmpty) {
            _days.putIfAbsent(date, NutritionDay.new).water = v.toInt().clamp(0, kGlasses);
          }
        case 'tick':
          if (id.isNotEmpty) _days.putIfAbsent(date, NutritionDay.new).ticks.add(id);
        case 'swap':
          if (id.isNotEmpty && v is String) _days.putIfAbsent(date, NutritionDay.new).swaps[id] = v;
        case 'skip':
          if (id.isNotEmpty) _days.putIfAbsent(date, NutritionDay.new).skipped.add(id);
        case 'craving':
          final at = DateTime.tryParse(rest);
          if (at != null && v is String) _cravings.add(CravingLog(at: at, kind: v));
        case 'shop':
          // `shop|<recipeId>|<name>`: the recipe id never holds a bar, the
          // name may.
          if (date.isEmpty || id.isEmpty) break;
          final m = v is Map ? v : const {};
          final o = m['o'];
          shop.add((
            item: ShoppingItem(recipeId: date, name: id, done: m['d'] == true),
            order: o is num ? o.toInt() : 0,
          ));
        case 'region':
          _region = v is String ? ChartRegion.values.where((x) => x.name == v).firstOrNull : null;
        case 'reminder':
          _reminder = v == true;
        case 'chart':
          _pinnedChartId = v is String && v.isNotEmpty ? v : null;
      }
    }
    // Newest craving first, at most a hundred, as logCraving keeps them.
    _cravings.sort((a, b) => b.at.compareTo(a.at));
    if (_cravings.length > 100) _cravings.removeRange(100, _cravings.length);
    shop.sort((a, b) {
      final c = a.order.compareTo(b.order);
      return c != 0 ? c : a.item.key.compareTo(b.item.key);
    });
    for (final s in shop) {
      _shopping.add(s.item);
      _shopOrder[s.item.key] = s.order;
      if (s.order > _lastOrder) _lastOrder = s.order;
    }
    _loaded = true;
    // The whole state was just handed over: nothing left to read first.
    _cacheRead = true;
  }

  void _fromBlob(Object? data) {
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
    _shopOrder.clear();
    final sh = data['shopping'];
    if (sh is List) {
      var i = 0;
      for (final s in sh) {
        if (s is Map && s['r'] is String && s['n'] is String) {
          final item = ShoppingItem(recipeId: s['r'] as String, name: s['n'] as String, done: s['d'] == true);
          _shopping.add(item);
          // A blob from before step 13 has no order: its position stands in,
          // which sorts it before anything added since.
          final o = s['o'];
          final order = o is num ? o.toInt() : i;
          _shopOrder[item.key] = order;
          if (order > _lastOrder) _lastOrder = order;
        }
        i++;
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
    await p.setString(_key, jsonEncode(_blob()));
  }

  /// A reset store counts as read (empty), so a test's edits apply at once,
  /// as they always have.
  @visibleForTesting
  void resetForTest() {
    _cacheRead = true;
    _waiting.clear();
    _days.clear();
    _cravings.clear();
    _shopping.clear();
    _shopOrder.clear();
    _region = null;
    _reminder = false;
    _pinnedChartId = null;
  }

  /// As a phone that has not read its cache yet (P4 S2's test): the next
  /// edit is held, and `init` reads the saved blob.
  @visibleForTesting
  void resetUnreadForTest() {
    resetForTest();
    _cacheRead = false;
    _loaded = false;
    _starting = null;
    _prefs = null;
  }
}
