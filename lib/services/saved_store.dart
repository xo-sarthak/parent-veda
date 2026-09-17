// =============================================================================
//  SavedStore — every bookmark in the app, owned by the person, in one place
// -----------------------------------------------------------------------------
//  The app half of `saved_items` (migration 0081). Read docs/FAMILY-MODEL.md §5
//  before changing anything here: the one rule is that the PERSON owns a
//  bookmark and stage / child are tags on it, which is why "she saved it while
//  trying and is now pregnant" needs no code at all.
//
//  Singleton `ChangeNotifier`, private constructor, lazy load, prefs cache —
//  the house pattern. Local-first: the cache is read and listeners notified
//  before any network; a cloud failure is never a crash; logged out behaves
//  exactly like a backend that never answered.
//
//  WHY NOT CloudSyncedStore. That mixin syncs one blob per store and adopts the
//  cloud copy wholesale on startup. Two devices on one account then race: an
//  unsave on the tablet is undone when the offline phone pushes its stale set.
//  Rows keyed by (kind, item) merge item by item; a tombstone (`removedAt`)
//  records the unsave; the later `updatedAt` wins. [merge] below is the whole
//  algorithm and `test/saved_store_test.dart` walks every branch of it.
//
//  THE SEVEN OLD SETS. VideoStore, ReadNextStore, ProductStore, CanIStore,
//  ReadToBabySavedStore, CommunityStore and PvReadStore each kept their own
//  saved set. They now delegate here (their sets are commented out, kept for
//  revert) and [importLegacy] reads each old prefs key ONCE on first run, so
//  nothing a tester saved before the update is lost. The old keys are not
//  deleted — a rollback would find them intact.
//
//  TITLE SNAPSHOTS. A row carries the title it was saved with, so the Saved
//  screen renders even when the content has been edited or withdrawn. Legacy
//  imports have no title; the screen resolves those live by id and, when it
//  cannot, shows "No longer available" with a Remove — never a blank row.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'life_stage_store.dart';
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';

/// The wire vocabulary — `id` is what the database's check constraint accepts.
/// Persisted, compared, sent: identity, never display.
enum SavedKind {
  article('article'),
  video('video'),
  recipe('recipe'),
  product('product'),
  question('question'),
  readToBaby('read_to_baby'),
  post('post'),
  tool('tool'),
  activity('activity'),
  tip('tip');

  const SavedKind(this.id);
  final String id;

  /// Null for a word this build does not know — the row is kept and skipped,
  /// never a crash on a newer app's vocabulary.
  static SavedKind? fromId(String? id) {
    for (final k in values) {
      if (k.id == id) return k;
    }
    return null;
  }
}

class SavedItem {
  const SavedItem({
    required this.kind,
    required this.itemId,
    required this.savedAt,
    required this.updatedAt,
    this.stage,
    this.childId,
    this.title = '',
    this.subtitle,
    this.removedAt,
  });

  final SavedKind kind;
  final String itemId;
  final String? stage; // 'trying' | 'pregnancy' | 'parenting' | 'skilling'
  final String? childId;
  final String title;
  final String? subtitle;
  final DateTime savedAt;
  final DateTime updatedAt;
  final DateTime? removedAt;

  bool get live => removedAt == null;

  /// The identity. Two rows with the same key are the same bookmark.
  String get key => '${kind.id}:$itemId';

  SavedItem copyWith({
    String? stage,
    String? childId,
    String? title,
    String? subtitle,
    DateTime? savedAt,
    DateTime? updatedAt,
    DateTime? removedAt,
    bool clearRemoved = false,
  }) =>
      SavedItem(
        kind: kind,
        itemId: itemId,
        stage: stage ?? this.stage,
        childId: childId ?? this.childId,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        savedAt: savedAt ?? this.savedAt,
        updatedAt: updatedAt ?? this.updatedAt,
        removedAt: clearRemoved ? null : (removedAt ?? this.removedAt),
      );

  /// Wire shape = the table's columns, snake_case. `user_id` is added by the
  /// repo on the way out and ignored on the way in.
  Map<String, dynamic> toRow() => {
        'kind': kind.id,
        'item_id': itemId,
        'stage': stage,
        'child_id': childId,
        'title': title,
        'subtitle': subtitle,
        'saved_at': savedAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'removed_at': removedAt?.toUtc().toIso8601String(),
      };

  static SavedItem? fromRow(Map<String, dynamic> r) {
    final kind = SavedKind.fromId(r['kind'] as String?);
    final itemId = r['item_id'] as String?;
    if (kind == null || itemId == null || itemId.isEmpty) return null;
    DateTime? d(Object? v) => v is String ? DateTime.tryParse(v)?.toUtc() : null;
    final saved = d(r['saved_at']) ?? DateTime.now().toUtc();
    return SavedItem(
      kind: kind,
      itemId: itemId,
      stage: r['stage'] as String?,
      childId: r['child_id'] as String?,
      title: (r['title'] as String?) ?? '',
      subtitle: r['subtitle'] as String?,
      savedAt: saved,
      updatedAt: d(r['updated_at']) ?? saved,
      removedAt: d(r['removed_at']),
    );
  }
}

class SavedStore extends ChangeNotifier {
  SavedStore._();
  static final SavedStore instance = SavedStore._();

  static const String kCacheKey = 'saved_items_v1';
  static const String kImportedKey = 'saved_items_legacy_imported_v1';
  static const String table = 'saved_items';

  final Map<String, SavedItem> _items = {}; // key → row, tombstones included
  bool _loaded = false;
  Future<void>? _loading;

  bool get isLoaded => _loaded;

  // ---- reads -----------------------------------------------------------------

  bool isSaved(SavedKind kind, String itemId) =>
      _items['${kind.id}:$itemId']?.live ?? false;

  DateTime? savedAt(SavedKind kind, String itemId) {
    final it = _items['${kind.id}:$itemId'];
    return (it != null && it.live) ? it.savedAt : null;
  }

  /// Live rows, newest saved first, optionally narrowed.
  List<SavedItem> items({SavedKind? kind, String? stage, String? childId}) {
    final out = _items.values.where((i) =>
        i.live &&
        (kind == null || i.kind == kind) &&
        (stage == null || i.stage == stage) &&
        (childId == null || i.childId == childId)).toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return out;
  }

  int count([SavedKind? kind]) => items(kind: kind).length;

  /// Ids of live rows of one kind, newest first — what the old per-kind
  /// stores used to hand out, so their callers keep working unchanged.
  List<String> idsOf(SavedKind kind) =>
      items(kind: kind).map((i) => i.itemId).toList();

  /// The stages she has saved from — the Saved screen shows a stage chip row
  /// only when there is more than one.
  Set<String> get stagesPresent =>
      {for (final i in _items.values) if (i.live && i.stage != null) i.stage!};

  // ---- writes ----------------------------------------------------------------

  /// Save, or refresh the snapshot of an already-saved item. Idempotent.
  /// [stage] and [childId] default to where she is now; they are tags.
  Future<void> save(
    SavedKind kind,
    String itemId, {
    String title = '',
    String? subtitle,
    String? stage,
    String? childId,
  }) async {
    await _ensureLoaded();
    final now = DateTime.now().toUtc();
    final key = '${kind.id}:$itemId';
    final prev = _items[key];
    final next = (prev == null)
        ? SavedItem(
            kind: kind,
            itemId: itemId,
            stage: stage ?? _currentStage,
            childId: childId,
            title: title,
            subtitle: subtitle,
            savedAt: now,
            updatedAt: now,
          )
        : prev.copyWith(
            // A re-save after an unsave is a fresh save: new savedAt, no
            // tombstone. A save of something already live just refreshes
            // the snapshot and keeps its place in the list.
            savedAt: prev.live ? prev.savedAt : now,
            updatedAt: now,
            title: title.isNotEmpty ? title : null,
            subtitle: subtitle,
            clearRemoved: true,
          );
    _items[key] = next;
    notifyListeners();
    await _persist();
    _push(next);
  }

  /// Unsave = tombstone, never delete. The row stays so a stale device cannot
  /// resurrect it; the server prunes tombstones after 30 days.
  Future<void> unsave(SavedKind kind, String itemId) async {
    await _ensureLoaded();
    final key = '${kind.id}:$itemId';
    final prev = _items[key];
    if (prev == null || !prev.live) return;
    final now = DateTime.now().toUtc();
    final next = prev.copyWith(updatedAt: now, removedAt: now);
    _items[key] = next;
    notifyListeners();
    await _persist();
    _push(next);
  }

  Future<void> toggle(
    SavedKind kind,
    String itemId, {
    String title = '',
    String? subtitle,
    String? stage,
    String? childId,
  }) =>
      isSaved(kind, itemId)
          ? unsave(kind, itemId)
          : save(kind, itemId,
              title: title, subtitle: subtitle, stage: stage, childId: childId);

  // ---- lifecycle -------------------------------------------------------------

  /// Load the cache, import the old sets once, then reconcile with the cloud.
  /// Safe to call many times; work happens once.
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(kCacheKey);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          final it = SavedItem.fromRow(Map<String, dynamic>.from(e as Map));
          if (it != null) _items[it.key] = it;
        }
      }
      _loaded = true;
      notifyListeners();
      if (!(p.getBool(kImportedKey) ?? false)) {
        final n = await importLegacy(p);
        await p.setBool(kImportedKey, true);
        if (n > 0) {
          await _persist();
          notifyListeners();
          // Pushed row by row: a fresh install has nothing in the cloud yet,
          // and an existing account merges by key on the sync below.
          for (final it in _items.values) {
            _push(it);
          }
        }
      }
    } catch (e) {
      debugPrint('[saved] load failed: $e');
      _loaded = true;
    }
    SyncRegistry.register(syncFromCloud);
    await syncFromCloud();
  }

  Future<void> _ensureLoaded() async {
    if (!_loaded) await load();
  }

  String? get _currentStage => LifeStageStore.instance.stage?.id;

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(
          kCacheKey, jsonEncode(_items.values.map((i) => i.toRow()).toList()));
    } catch (_) {/* best-effort; the in-memory copy is the truth this session */}
  }

  /// Fire-and-forget upsert of one row. `onConflict` names the natural key,
  /// so a second save of the same thing is an update, never a duplicate.
  void _push(SavedItem it) {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    SupabaseRepo.upsertRow(table, {...it.toRow(), 'user_id': uid},
            onConflict: 'user_id,kind,item_id')
        .catchError((_) {});
  }

  // ---- merge -----------------------------------------------------------------

  /// Pull every row of mine, merge by key with last-writer-wins on
  /// `updatedAt`, push back whatever this device knew that the cloud did not
  /// (or knew more recently), persist, notify. No-op when logged out.
  Future<void> syncFromCloud() async {
    if (!SupabaseRepo.isLoggedIn) return;
    await _importLegacyCloudOnce();
    List<Map<String, dynamic>> rows;
    try {
      rows = await SupabaseRepo.fetch(table, orderBy: 'updated_at');
    } catch (e) {
      debugPrint('[saved] sync fetch failed: $e');
      return;
    }
    final cloud = <String, SavedItem>{};
    for (final r in rows) {
      final it = SavedItem.fromRow(r);
      if (it != null) cloud[it.key] = it;
    }
    final result = merge(local: _items, cloud: cloud);
    _items
      ..clear()
      ..addAll(result.merged);
    for (final it in result.toPush) {
      _push(it);
    }
    await _persist();
    notifyListeners();
  }

  /// The whole reconciliation, pure and testable. For each key present on
  /// either side, the row with the later `updatedAt` wins — including a
  /// tombstone, which is how an unsave on one device beats a stale save on
  /// another. Rows only this device has, or that this device has newer, go
  /// back up.
  @visibleForTesting
  static MergeResult merge({
    required Map<String, SavedItem> local,
    required Map<String, SavedItem> cloud,
  }) {
    final merged = <String, SavedItem>{};
    final toPush = <SavedItem>[];
    for (final key in {...local.keys, ...cloud.keys}) {
      final l = local[key];
      final c = cloud[key];
      if (l == null) {
        merged[key] = c!;
      } else if (c == null) {
        merged[key] = l;
        toPush.add(l);
      } else if (l.updatedAt.isAfter(c.updatedAt)) {
        merged[key] = l;
        toPush.add(l);
      } else {
        merged[key] = c;
      }
    }
    return MergeResult(merged, toPush);
  }

  // ---- legacy import ---------------------------------------------------------

  /// Read each of the seven old prefs keys once and turn them into rows. The
  /// old keys are left in place. Returns how many rows were imported.
  @visibleForTesting
  Future<int> importLegacy(SharedPreferences p) async {
    var n = 0;
    final now = DateTime.now().toUtc();
    void add(SavedKind kind, String id, {String title = '', String? subtitle, DateTime? at}) {
      if (id.isEmpty) return;
      final key = '${kind.id}:$id';
      if (_items.containsKey(key)) return;
      final t = at ?? now;
      _items[key] = SavedItem(
          kind: kind, itemId: id, title: title, subtitle: subtitle, savedAt: t, updatedAt: t);
      n++;
    }

    try {
      // VideoStore: 'video_saved' is a JSON list of ids; 'video_saved_at' a
      // JSON map id → millis.
      final vAt = _millisMap(p.getString('video_saved_at'));
      final vRaw = p.getString('video_saved');
      if (vRaw != null) {
        for (final id in (jsonDecode(vRaw) as List)) {
          add(SavedKind.video, id.toString(), at: vAt[id.toString()]);
        }
      }
      // ReadNextStore: 'readnext_saved' is a json map id → saved-at millis.
      _millisMap(p.getString('readnext_saved'))
          .forEach((id, at) => add(SavedKind.article, id, at: at));
      // ProductStore / CanIStore / CommunityStore / PvReadStore: id lists.
      for (final id in p.getStringList('prod_saved') ?? const <String>[]) {
        add(SavedKind.product, id);
      }
      for (final id in p.getStringList('cani_saved') ?? const <String>[]) {
        add(SavedKind.question, id);
      }
      for (final id in p.getStringList('comm_saved') ?? const <String>[]) {
        add(SavedKind.post, id);
      }
      for (final id in p.getStringList('pv_read_saved') ?? const <String>[]) {
        add(SavedKind.article, id);
      }
      // ReadToBabySavedStore: 'rtb_saved' is a JSON list of pieces keyed
      // {k: key, t: title, b: body, g: tag, s: savedAt millis} — the one legacy
      // set that already snapshotted. Rows older than the key carry the
      // English title in 't' and no 'k' (its own fromJson says so).
      final rtb = p.getString('rtb_saved');
      if (rtb != null) {
        for (final e in (jsonDecode(rtb) as List)) {
          final m = Map<String, dynamic>.from(e as Map);
          final title = (m['t'] ?? '').toString();
          final key = (m['k'] ?? title).toString();
          final at = m['s'];
          add(SavedKind.readToBaby, key,
              title: title,
              subtitle: (m['g'] ?? '').toString(),
              at: at is num && at > 0
                  ? DateTime.fromMillisecondsSinceEpoch(at.toInt(), isUtc: true)
                  : null);
        }
      }
      // Parenting side: 'pp_watch', 'pp_reading', 'pp_daily_tip_v1' are each
      // one JSON object with a `saved` list inside. Their demo seeds are
      // skipped — a fresh account was born with them, so they were never a
      // choice she made.
      _importParentingBlob(p.getString('pp_watch'), SavedKind.video, add);
      _importParentingBlob(p.getString('pp_reading'), SavedKind.article, add);
      _importParentingBlob(p.getString('pp_daily_tip_v1'), SavedKind.tip, add);
    } catch (e) {
      debugPrint('[saved] legacy import stopped early: $e');
    }
    return n;
  }

  /// The ids the parenting stores were SEEDED with for the demo — present in
  /// every account's blob whether or not she ever tapped save.
  static const kParentingDemoSeeds = {'tummytime', 'q_iron', 'leap4', 'matrescence'};

  static void _importParentingBlob(
    String? raw,
    SavedKind kind,
    void Function(SavedKind, String, {String title, String? subtitle, DateTime? at}) add,
  ) {
    if (raw == null) return;
    try {
      final m = jsonDecode(raw);
      if (m is! Map) return;
      for (final id in (m['saved'] as List?) ?? const []) {
        final s = id.toString();
        if (kParentingDemoSeeds.contains(s)) continue;
        add(kind, s);
      }
    } catch (_) {/* one bad blob does not stop the others */}
  }

  /// The six old stores each synced ONE BLOB into user_state. A fresh install
  /// of an existing account has none of the old prefs keys, so [importLegacy]
  /// finds nothing — the saves only exist in those blobs. Read each once per
  /// account and lift them into rows. Idempotent: rows already present (from
  /// prefs, or from a previous device) are kept, not overwritten.
  Future<void> _importLegacyCloudOnce() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    final flag = '${kImportedKey}_cloud_$uid';
    SharedPreferences p;
    try {
      p = await SharedPreferences.getInstance();
    } catch (_) {
      return;
    }
    if (p.getBool(flag) ?? false) return;
    var n = 0;
    try {
      n = await importLegacyCloud(SupabaseRepo.loadState);
      await p.setBool(flag, true);
    } catch (e) {
      // Not flagged: a network blip must not permanently skip the import.
      debugPrint('[saved] legacy cloud import failed: $e');
      return;
    }
    if (n > 0) {
      await _persist();
      for (final it in _items.values) {
        _push(it);
      }
      notifyListeners();
    }
  }

  /// Pure over a blob loader, so the test can hand it fixtures. Returns how
  /// many rows were added. Shapes are each store's `cloudData()`, verbatim.
  @visibleForTesting
  Future<int> importLegacyCloud(Future<dynamic> Function(String key) load) async {
    var n = 0;
    final now = DateTime.now().toUtc();
    void add(SavedKind kind, String id, {String title = '', String? subtitle, int? millis}) {
      if (id.isEmpty) return;
      final key = '${kind.id}:$id';
      if (_items.containsKey(key)) return;
      final t = (millis != null && millis > 0)
          ? DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true)
          : now;
      _items[key] = SavedItem(
          kind: kind, itemId: id, title: title, subtitle: subtitle, savedAt: t, updatedAt: t);
      n++;
    }

    int? ms(Object? v) => v is num ? v.toInt() : null;

    // video_saved: {saved: [ids], savedAt: {id: millis}}
    final video = await load('video_saved');
    if (video is Map) {
      final at = (video['savedAt'] as Map?) ?? const {};
      for (final id in (video['saved'] as List?) ?? const []) {
        add(SavedKind.video, id.toString(), millis: ms(at[id.toString()]));
      }
    }
    // readnext: {status: {...}, saved: {id: millis}}
    final rn = await load('readnext');
    if (rn is Map) {
      ((rn['saved'] as Map?) ?? const {})
          .forEach((id, at) => add(SavedKind.article, id.toString(), millis: ms(at)));
    }
    // prod_saved / cani_saved: [ids]
    final prod = await load('prod_saved');
    if (prod is List) {
      for (final id in prod) {
        add(SavedKind.product, id.toString());
      }
    }
    final cani = await load('cani_saved');
    if (cani is List) {
      for (final id in cani) {
        add(SavedKind.question, id.toString());
      }
    }
    // community: {..., saved: [ids], ...}
    final comm = await load('community');
    if (comm is Map) {
      for (final id in (comm['saved'] as List?) ?? const []) {
        add(SavedKind.post, id.toString());
      }
    }
    // rtb_saved: [{k, t, b, g, s}]
    final rtb = await load('rtb_saved');
    if (rtb is List) {
      for (final e in rtb) {
        if (e is! Map) continue;
        final title = (e['t'] ?? '').toString();
        add(SavedKind.readToBaby, (e['k'] ?? title).toString(),
            title: title, subtitle: (e['g'] ?? '').toString(), millis: ms(e['s']));
      }
    }
    // Parenting blobs: {saved: [...], ...}; demo seeds skipped.
    for (final e in {
      'pp_watch': SavedKind.video,
      'pp_reading': SavedKind.article,
      'pp_daily_tip_v1': SavedKind.tip,
    }.entries) {
      final b = await load(e.key);
      if (b is Map) {
        for (final id in (b['saved'] as List?) ?? const []) {
          if (kParentingDemoSeeds.contains(id.toString())) continue;
          add(e.value, id.toString());
        }
      }
    }
    // PvReadStore never synced — nothing in the cloud to lift.
    return n;
  }

  static Map<String, DateTime> _millisMap(String? raw) {
    if (raw == null) return const {};
    try {
      final m = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      return {
        for (final e in m.entries)
          if (e.value is int)
            e.key: DateTime.fromMillisecondsSinceEpoch(e.value as int, isUtc: true)
      };
    } catch (_) {
      return const {};
    }
  }

  /// Test seam: reset in-memory state between tests.
  @visibleForTesting
  void debugReset() {
    _items.clear();
    _loaded = false;
    _loading = null;
  }
}

class MergeResult {
  const MergeResult(this.merged, this.toPush);
  final Map<String, SavedItem> merged;
  final List<SavedItem> toPush;
}
