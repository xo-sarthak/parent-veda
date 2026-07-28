// =============================================================================
//  ContentStore<T> — the build-once engine every content type shares.
// -----------------------------------------------------------------------------
//  Generalised out of ArticleStore, which had been carrying a note since
//  2026-07-14 saying it was "the engine every future content type will copy".
//  Copying it twelve times would also have copied three defects, so it became a
//  base class instead. Each new type is now a ~40-line subclass implementing two
//  methods.
//
//  LOCAL-FIRST, IN THREE LAYERS. A store is never empty and never crashes:
//    1. the bundled seed          — instant, offline, first launch, forever
//    2. a SharedPreferences cache — instant, last known server state
//    3. the network               — fresh, then cached
//  A failure at any layer simply leaves the layer below in place.
//
//  ---------------------------------------------------------------------------
//  THE THREE DEFECTS THIS FIXES — do not reintroduce them
//
//  1. AN EMPTY RESULT WAS DISCARDED.
//     The old code did `if (rows.isNotEmpty)`, so a SUCCESSFUL fetch returning
//     zero rows was thrown away. Unpublishing content in Directus could
//     therefore never remove it from the app — the panel's most basic promise,
//     quietly broken.
//
//     But honouring every empty result has its own failure: run a migration on
//     production without its seed and every screen for that type goes blank.
//     So the rule here is narrower and, I think, the honest one:
//
//       an empty result is authoritative ONLY once the backend has been seen
//       to serve rows at least once.
//
//     Unpublish-everything after real content existed  -> empties. Correct.
//     Table created but not yet seeded                 -> keeps the seed. Correct.
//
//     The "has served rows" fact is persisted with the cache, so it survives a
//     relaunch. Once true it stays true — a type that has had content is
//     allowed to become empty, and the empty state renders its own invitation
//     ("a feature is never hidden").
//
//  2. THE CACHE WAS MONOLINGUAL.
//     The old _persist wrote only title/body. The moment a _hi column exists, a
//     language toggle offline silently shows English. A store must NEVER
//     resolve language — cache every column the model holds, both languages,
//     and let the UI choose. toCacheMap is where that rule is kept.
//
//  3. THERE WAS NO THROTTLE.
//     One store refreshing on every app resume is fine. Twelve stores doing it
//     is twelve round trips every time someone alt-tabs. minRefreshGap fixes it;
//     refresh(force: true) is the deliberate user-initiated pull-to-refresh.
//
//  ---------------------------------------------------------------------------
//  WHY A FULL FETCH AND NOT `updated_at` DELTAS
//
//  docs/CONTENT-BACKEND.md once promised incremental fetching. It is not built,
//  and that is a decision rather than an omission: a delta cannot see an
//  unpublish or a delete, so it needs a reconcile pass — which at these volumes
//  (hundreds of rows) costs more code and more bugs than the thing it saves.
//  Revisit at ~500 rows in one table.
//
//  See docs/CONTENT-BACKEND.md for the add-a-type recipe.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/content_repo.dart';

abstract class ContentStore<T> extends ChangeNotifier {
  ContentStore({
    required this.table,
    required this.cacheKey,
    required List<T> seed,
    this.domain,
    this.serverOnly = false,
  })  : assert(serverOnly || seed.isNotEmpty,
            'A content store must ship a non-empty seed: it is the offline '
            'floor. If this type genuinely has nothing to ship, say so with '
            'serverOnly: true rather than passing an empty list.'),
        _seed = List<T>.unmodifiable(seed),
        _items = List<T>.of(seed);

  /// The Supabase table. Also the key into [ContentOwnership] and into
  /// AskVeda's SOURCE_SPECS — one vocabulary across three repos.
  final String table;

  /// SharedPreferences key. Version it (`content_recipes_v1`) so a change to
  /// the cached shape can be invalidated by bumping rather than by migration.
  final String cacheKey;

  /// Optional `domain` filter ('pregnancy' | 'parenting' | 'universal').
  final String? domain;

  /// This type ships NOTHING with the app, deliberately.
  ///
  /// Content types are normally required to carry a bundled seed — it is the
  /// offline floor, and a missing one shows as a blank screen on a slow
  /// network that nobody notices until a user complains. That rule is right
  /// for a library of recipes or articles, which exist before anyone opens
  /// the app.
  ///
  /// It is wrong for INVENTORY. There are no masterclasses until somebody
  /// schedules one, and "nothing scheduled yet" is a legitimate state that
  /// should render its own invitation rather than a stale bundled list.
  ///
  /// So the exception is declared rather than smuggled in as an empty list:
  /// the assertion still fires for every type that simply forgot its seed.
  ///
  /// It also changes the empty-result rule. A seeded type only honours an
  /// empty backend once it has been seen to serve rows (an unseeded table
  /// must not blank a screen). A server-only type has no such ambiguity —
  /// empty is the correct starting state and is honoured immediately.
  final bool serverOnly;

  final List<T> _seed;
  List<T> _items;

  bool _loaded = false;
  bool _backendHasServedRows = false;
  DateTime? _lastFetchAt;

  // ---- the subclass contract (two methods) ---------------------------------

  /// Build a model from a row. The SAME mapper serves a live Supabase row and a
  /// cached row, because [toCacheMap] persists rows in the DB's own shape.
  @protected
  T fromMap(Map<String, dynamic> row);

  /// What to cache. Include EVERY column the model carries — both languages.
  /// See defect 2 above.
  @protected
  Map<String, dynamic> toCacheMap(T item);

  // ---- optional overrides ---------------------------------------------------

  /// Server-side ordering. Default suits the shared content spine.
  @protected
  List<ContentOrder> get order => const [ContentOrder('sort')];

  /// Ignore un-forced refreshes that arrive sooner than this after the last one.
  @protected
  Duration get minRefreshGap => const Duration(seconds: 30);

  // ---- public surface -------------------------------------------------------

  List<T> get all => List<T>.unmodifiable(_items);

  /// The compiled-in fallback, regardless of what is currently being served.
  List<T> get seed => _seed;

  /// True once a fetch has been served from Supabase rather than seed/cache.
  /// Useful in debug screens; the UI should not branch on it.
  bool get isServingBackendContent => _backendHasServedRows;

  /// Load once. Safe to call from `build` — a no-op after the first time.
  void ensureLoaded() {
    if (_loaded) return;
    _loaded = true;
    _load();
  }

  /// Re-pull from the backend. Bypasses the once-per-session guard so freshly
  /// published content appears without a relaunch.
  ///
  /// [force] skips the throttle too — use it for an explicit user gesture
  /// (pull-to-refresh), not for lifecycle events.
  Future<void> refresh({bool force = false}) => _fetchFresh(force: force);

  // ---- internals ------------------------------------------------------------

  Future<void> _load() async {
    await _readCache();
    await _fetchFresh(force: true);
  }

  Future<void> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(cacheKey);
      if (raw == null) return;

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return; // pre-envelope cache: drop.

      _backendHasServedRows = decoded['served'] == true;

      final rows = (decoded['rows'] as List?) ?? const [];
      if (rows.isEmpty) return;

      _items = rows
          .map((e) => fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false);
      notifyListeners();
    } catch (_) {
      // A corrupt cache is not an error worth surfacing — the seed is intact.
    }
  }

  Future<void> _fetchFresh({bool force = false}) async {
    final now = DateTime.now();
    if (!force &&
        _lastFetchAt != null &&
        now.difference(_lastFetchAt!) < minRefreshGap) {
      return;
    }

    final List<Map<String, dynamic>> rows;
    try {
      rows = await ContentRepo.fetchPublished(
        table,
        domain: domain,
        order: order,
      );
    } catch (_) {
      // Offline, or the table does not exist yet. Keep cache, else seed.
      // Deliberately NOT stamping _lastFetchAt: a failure should not buy the
      // throttle window that a success does.
      return;
    }

    _lastFetchAt = DateTime.now();

    if (rows.isEmpty && !_backendHasServedRows && !serverOnly) {
      // The backend has never served this type. Almost certainly a table that
      // exists but has not been seeded — not an editorial decision to empty it.
      //
      // serverOnly types are exempt: empty IS their correct starting state,
      // and waiting for a first non-empty fetch would mean an unpublished
      // catalogue kept showing whatever it last had.
      return;
    }
    if (rows.isNotEmpty) {
      _backendHasServedRows = true;
    }

    _items =
        rows.map(fromMap).toList(growable: false); // may legitimately be empty
    notifyListeners();
    await _persist(rows);
  }

  Future<void> _persist(List<Map<String, dynamic>> rows) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        cacheKey,
        jsonEncode(<String, dynamic>{
          'v': 1,
          'served': _backendHasServedRows,
          'at': DateTime.now().toIso8601String(),
          // Re-serialised through the model so the cache holds exactly what the
          // UI needs — and so a column the model ignores cannot bloat it.
          'rows': _items.map(toCacheMap).toList(growable: false),
        }),
      );
    } catch (_) {
      // Best-effort. A cache that failed to write costs one network call.
    }
  }

  /// Testing seam: forget the cache and the once-per-session guard.
  @visibleForTesting
  void resetForTest() {
    _items = List<T>.of(_seed);
    _loaded = false;
    _backendHasServedRows = false;
    _lastFetchAt = null;
  }
}
