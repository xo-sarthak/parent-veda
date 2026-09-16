// =============================================================================
//  PpHomeActivitiesStore — "Activities to do today with your baby"
// -----------------------------------------------------------------------------
//  The V3 home's Today section (design of 2026-09-16) shows THREE activities
//  a day from the age-banded pool, and the brief is precise about how they
//  behave over a day:
//
//    * a completed activity stays on the page, marked done, until tomorrow —
//      it is not replaced the moment it is ticked;
//    * "Change" replaces an activity immediately with another that suits the
//      age, and the one she sent away does not come straight back;
//    * tomorrow, the whole three are fresh;
//    * history is kept so the same activity does not keep reappearing.
//
//  That is a STATE machine with a date on it, and it is what this store is.
//  It is a singleton ChangeNotifier like every other store in the app — the
//  screen listens with AnimatedBuilder and never holds the state itself,
//  because a hot restart or a second visit must show the same three.
//
//  ⚠️ WHAT THIS STORE DOES NOT OWN: the fact that an activity was done.
//  `GrowStore` already records completions for the Brain tab, and the Brain
//  tab's "did something today" and "days this week" must agree with the home.
//  So `markDone` writes THROUGH to GrowStore; this store only remembers that
//  the tick happened on one of TODAY'S THREE cards, which is a home-screen
//  fact, not a development fact. One event, two readers, one writer each.
//
//  ⚠️ DETERMINISTIC ON THE DATE, like `growPickFor`. The three are chosen by
//  hashing (activity id + day) and taking the lowest three that history
//  allows. Reopening the app does not reshuffle them, and two phones with the
//  same age and the same empty history show the same three — which matters
//  the first time one is screenshot into a family group.
//
//  PERSISTENCE. Local only, in shared_preferences, one JSON blob. Not cloud
//  synced: what a parent was shown on a given day is a device fact, and the
//  completion itself already syncs through GrowStore. If the pick history ever
//  needs to follow her to a new phone, `CloudSyncedStore` is the mixin and
//  GrowStore is the worked example.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pp_development_data.dart';
import 'pp_grow_data.dart';

/// How many activities the home shows each day. The brief says "at least 3".
const int kPpHomeActivityCount = 3;

/// How many days an activity stays out of rotation after it was shown or
/// sent away. Fourteen is `_kFortnight` in pp_grow_data — the same promise:
/// nothing repeats inside a fortnight when the pool allows it.
const int kPpHomeActivityCooldownDays = 14;

class PpHomeActivitiesStore extends ChangeNotifier {
  PpHomeActivitiesStore._();
  static final PpHomeActivitiesStore instance = PpHomeActivitiesStore._();

  static const _prefsKey = 'pp_home_activities_v1';

  /// The day the current picks belong to, as yyyy-MM-dd.
  String _day = '';

  /// Today's three, in display order.
  List<String> _picks = const [];

  /// Which of today's picks have been ticked.
  final Set<String> _done = {};

  /// Which of today's picks arrived through "Change" — the card wears a small
  /// "Swapped" chip so she can see the swap happened.
  final Set<String> _swappedIn = {};

  /// activityId → the last day it was shown OR sent away. The cooldown reads
  /// this; it is the "history to avoid unnecessary repetition".
  final Map<String, String> _lastSeen = {};

  bool _loaded = false;
  Future<void>? _loading;

  // ---- Loading --------------------------------------------------------------

  /// Reads the cache once. Safe to call from build: the first call starts the
  /// read and every later call is a no-op. Until it lands, `todays()` computes
  /// the picks from the date alone, which is the same answer the cache holds
  /// for a day with no done/swap events — so the screen is right before AND
  /// after the load, and only a tick or a swap made earlier today changes on
  /// arrival.
  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    var cacheIsToday = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) cacheIsToday = _apply(jsonDecode(raw));
    } catch (_) {/* local-first: an unreadable cache is an empty one */}
    _loaded = true;
    // ⚠️ IF THE CACHE HAD NOTHING FOR TODAY, FORGET THE PRE-LOAD PICKS. They
    // were computed without the cooldown history, which has only just
    // arrived; the next read recomputes with it. Cheap, because a read is a
    // pure function of (date, history), and it is what makes "does not
    // repeat inside a fortnight" true across an app restart.
    if (!cacheIsToday) {
      _day = '';
      _picks = const [];
    }
    notifyListeners();
  }

  /// Returns true when the cache described TODAY and its picks were adopted.
  bool _apply(Object data) {
    if (data is! Map) return false;
    final day = data['day'];
    final picks = data['picks'];
    final done = data['done'];
    final swapped = data['swapped'];
    final seen = data['lastSeen'];
    if (seen is Map) {
      _lastSeen.addAll({
        for (final e in seen.entries) e.key.toString(): e.value.toString(),
      });
    }
    // ⚠️ MERGE, NOT REPLACE, and only if the cache is about TODAY. A tick that
    // happened before the cache landed must survive it; and yesterday's picks
    // must not overwrite today's just because they were read later.
    if (day is String && day == _todayKey() && picks is List) {
      _day = day;
      _picks = [for (final p in picks) p.toString()];
      if (done is List) _done.addAll(done.map((e) => e.toString()));
      if (swapped is List) _swappedIn.addAll(swapped.map((e) => e.toString()));
      return true;
    }
    return false;
  }

  Map<String, Object> _toJson() => {
        'day': _day,
        'picks': _picks,
        'done': _done.toList(),
        'swapped': _swappedIn.toList(),
        'lastSeen': _lastSeen,
      };

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(_toJson()));
    } catch (_) {/* local write failed; in-memory state still stands */}
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (_loaded) _persist();
  }

  // ---- Dates ----------------------------------------------------------------

  /// Overridable so a test can walk the store across midnight without waiting
  /// for one. Production never sets it.
  @visibleForTesting
  DateTime Function() now = DateTime.now;

  String _todayKey() => GrowStore.key(now());

  int _daysSince(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return 1 << 20;
    final d = DateTime(
        int.tryParse(parts[0]) ?? 0,
        int.tryParse(parts[1]) ?? 1,
        int.tryParse(parts[2]) ?? 1);
    final t = now();
    return DateTime(t.year, t.month, t.day).difference(d).inDays;
  }

  bool _onCooldown(String id) {
    final k = _lastSeen[id];
    return k != null && _daysSince(k) < kPpHomeActivityCooldownDays;
  }

  // ---- Picking --------------------------------------------------------------

  /// A stable per-(activity, day) score. FNV-style string hash — nothing
  /// cryptographic, it only has to be deterministic and spread evenly.
  static int _score(String id, String day) {
    var h = 2166136261;
    for (final c in '$id|$day'.codeUnits) {
      h = ((h ^ c) * 16777619) & 0x7fffffff;
    }
    return h;
  }

  /// The pool for this age, best-scoring first for [day], with anything on
  /// cooldown moved to the back rather than dropped — a small pool must still
  /// fill three cards.
  List<DevActivity> _ranked(int ageMonths, String day,
      {Set<String> exclude = const {}}) {
    final pool = growActivitiesForAge(ageMonths)
        .where((a) => !exclude.contains(a.id))
        .toList();
    // ⚠️ EXACT AGE FIRST, THEN THE WIDENED BAND. `growActivitiesForAge`
    // widens the window until fourteen activities fit, so a newborn's pool
    // holds 2–6 mo and 6–9 mo cards too. On the phone a day-one baby was
    // offered "Ball drop (6–9 mo)" while "0–3 mo" cards sat unused: the hash
    // ordered the pool without caring which tier a card came from. Now a
    // card that fits the age exactly always ranks above one that only fits
    // the widened band; the widened band is a fallback, not a peer.
    int cmp(DevActivity a, DevActivity b) {
      final ca = _onCooldown(a.id), cb = _onCooldown(b.id);
      if (ca != cb) return ca ? 1 : -1; // fresh before on-cooldown
      final ea = growSuitsAge(a, ageMonths), eb = growSuitsAge(b, ageMonths);
      if (ea != eb) return ea ? -1 : 1; // exact fit before widened band
      return _score(a.id, day).compareTo(_score(b.id, day));
    }
    pool.sort(cmp);
    return pool;
  }

  /// Rolls the store over to today if its picks are for another day. Called
  /// by every public read so the roll happens on the first look after
  /// midnight rather than needing a timer.
  void _rollover(int ageMonths) {
    final today = _todayKey();
    if (_day == today && _picks.length >= kPpHomeActivityCount) return;
    final fresh = _ranked(ageMonths, today)
        .take(kPpHomeActivityCount)
        .map((a) => a.id)
        .toList();
    _day = today;
    _picks = fresh;
    _done.clear();
    _swappedIn.clear();
    // History is only stamped once the cache is in; a pre-load pick is a
    // guess that may be replaced the moment the history lands, and a guess
    // must not go on cooldown as if it had been shown.
    if (_loaded) {
      for (final id in fresh) {
        _lastSeen[id] = today;
      }
      // No notify here: this runs inside a read during build, and the result
      // is a pure function of (date, history), so every listener agrees.
      _persist();
    }
  }

  // ---- Public API -----------------------------------------------------------

  /// Today's activities for a child of [ageMonths], in display order. Never
  /// fewer than three unless the whole library is smaller than three.
  List<DevActivity> todays(int ageMonths) {
    ensureLoaded();
    _rollover(ageMonths);
    return [
      for (final id in _picks)
        if (kGrowActivities.any((a) => a.id == id)) growActivityById(id),
    ];
  }

  bool isDone(String id) => _done.contains(id);
  bool wasSwappedIn(String id) => _swappedIn.contains(id);

  /// All of today's three are ticked. The footer line reads differently then.
  bool get allDone =>
      _picks.isNotEmpty && _picks.every(_done.contains);

  /// Tick one of today's cards. Stays on the page, dimmed, until tomorrow.
  /// Writes through to GrowStore so the Brain tab's record agrees.
  Future<void> markDone(String id) async {
    if (!_picks.contains(id) || _done.contains(id)) return;
    _done.add(id);
    await GrowStore.instance.complete(id);
    notifyListeners();
  }

  /// Replace one of today's cards with another that suits the age. The one
  /// sent away goes on cooldown so it does not come straight back; the new one
  /// takes its slot so the page does not reflow.
  void swap(String id, int ageMonths) {
    final i = _picks.indexOf(id);
    if (i < 0 || _done.contains(id)) return;
    final today = _todayKey();
    _lastSeen[id] = today;
    final candidates =
        _ranked(ageMonths, '$today#${_swappedIn.length}', exclude: {..._picks});
    if (candidates.isEmpty) return; // the pool has nothing else; keep the card
    final next = candidates.first;
    _picks = [..._picks]..[i] = next.id;
    _swappedIn.add(next.id);
    _lastSeen[next.id] = today;
    notifyListeners();
  }

  /// Test hook: forget everything.
  @visibleForTesting
  void resetForTest() {
    _day = '';
    _picks = const [];
    _done.clear();
    _swappedIn.clear();
    _lastSeen.clear();
  }
}
