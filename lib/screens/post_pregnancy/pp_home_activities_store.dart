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
//  ⚠️ ONE THREE PER CHILD, PER AGE (relevance PP 1, 2026-10-28). The picks
//  used to be keyed by the DATE alone, so switching from a 3-week-old to a
//  3-year-old kept the baby's three on the toddler's home until midnight, and
//  so did saving a real birthday after the stand-in child. Each day now holds
//  one slot per (child id, age in months): a sibling gets their own three,
//  switching back the same day finds the first child's three still ticked,
//  and a month birthday refreshes the picks because the pool itself changed.
//  The fortnight history stays shared across children: twins sharing it just
//  get different cards, which is variety, not a fault.
//
//  ⚠️ WHAT SHE TOLD US MOVES THEM (relevance PP 4, 2026-10-28). The app
//  promised "pages and activities about it move up on your home" and only the
//  pages did. Now an answer to "Is my baby OK?" lifts activities from the
//  development area that fits it (`kPpChangeActivityAreas`): babbling less
//  lifts language games, clingy lifts emotional and social ones. A fixed list,
//  not word matching: activities are filed by developmental area, and most
//  concerns (sleep, feeds, tummy, skin, illness) have no activity that fits,
//  so they move pages only. An urgent answer moves none: a worry that needs a
//  doctor never puts play first. Read through `PpChangesStore.active()`, so it
//  happens only with her yes, and the Brain tab and the home agree.
//
//  Today's three re-pick when what she told us changes, but only while the
//  slot is untouched. Once she has ticked or swapped one, the change shows
//  tomorrow: a ticked card never disappears from under her.
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

import 'pp_changes_store.dart';
import 'pp_development_data.dart';
import 'pp_grow_data.dart';
import 'pp_phase_doc_activities.dart';
import 'pp_what_changed_data.dart' show WcTone;

/// How many activities the home shows each day. The brief says "at least 3".
const int kPpHomeActivityCount = 3;

/// Concern id -> the development areas whose activities it lifts (PP 4).
/// Only concerns an activity can actually help with; the rest move pages only.
const Map<String, Set<String>> kPpChangeActivityAreas = {
  'gone_quiet': {'language'},
  'shy_new_people': {'social', 'emotional'},
  'separation_upset': {'emotional', 'social'},
  'extra_clingy': {'emotional', 'social'},
  'sudden_tantrums': {'emotional'},
  'biting_hitting': {'emotional'},
};

/// The changes that lift activities: not urgent, and on the list above.
List<PpChange> ppActivityChanges(List<PpChange> changes) => [
      for (final c in changes)
        if (c.tone != WcTone.urgent && kPpChangeActivityAreas.containsKey(c.concernId)) c,
    ];

/// "Because you said: suddenly very clingy" when [a] is up because of what
/// she told us, else null. The card says why it moved.
String? ppActivityWhy(DevActivity a, List<PpChange> changes) {
  for (final c in ppActivityChanges(changes)) {
    if (kPpChangeActivityAreas[c.concernId]!.contains(a.areaId)) return c.why;
  }
  return null;
}

/// How many days an activity stays out of rotation after it was shown or
/// sent away. Fourteen is `_kFortnight` in pp_grow_data — the same promise:
/// nothing repeats inside a fortnight when the pool allows it.
const int kPpHomeActivityCooldownDays = 14;

class PpHomeActivitiesStore extends ChangeNotifier {
  PpHomeActivitiesStore._();
  static final PpHomeActivitiesStore instance = PpHomeActivitiesStore._();

  static const _prefsKey = 'pp_home_activities_v1';

  /// The day the slots belong to, as yyyy-MM-dd.
  String _day = '';

  /// Today's slots, one per [slotKey]. Was a single `_picks` / `_done` /
  /// `_swappedIn` for the day, whoever was on screen (PP 1).
  // Kept for revert:
  //   List<String> _picks = const [];
  //   final Set<String> _done = {};
  //   final Set<String> _swappedIn = {};
  final Map<String, _Slot> _slots = {};

  /// The slot the last read rolled to: the child on screen. `isDone`,
  /// `allDone` and `markDone` act on it, so the card rows need no child id.
  String _current = '';

  _Slot get _slot => _slots[_current] ?? _Slot.empty();
  List<String> get _picks => _slot.picks;

  /// Which of today's picks have been ticked.
  Set<String> get _done => _slot.done;

  /// Which of today's picks arrived through "Change" — the card wears a small
  /// "Swapped" chip so she can see the swap happened.
  Set<String> get _swappedIn => _slot.swapped;

  /// One child's slot for one age. The stand-in child (no saved child) is
  /// `none`, so a real child saved later never inherits the stand-in's three.
  static String slotKey(String? childId, int ageMonths) =>
      '${(childId == null || childId.isEmpty) ? 'none' : childId}|$ageMonths';

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
      _slots.clear();
    }
    notifyListeners();
  }

  /// Returns true when the cache described TODAY and its picks were adopted.
  bool _apply(Object data) {
    if (data is! Map) return false;
    final day = data['day'];
    final slots = data['slots'];
    final seen = data['lastSeen'];
    if (seen is Map) {
      _lastSeen.addAll({
        for (final e in seen.entries) e.key.toString(): e.value.toString(),
      });
    }
    // ⚠️ MERGE, NOT REPLACE, and only if the cache is about TODAY. A tick that
    // happened before the cache landed must survive it; and yesterday's picks
    // must not overwrite today's just because they were read later.
    //
    // A cache from before PP 1 has a top-level `picks` and no `slots`. It
    // belongs to no child, so only its history is kept (above) and its picks
    // are recomputed, the same thing a load with nothing for today does.
    if (day is String && day == _todayKey() && slots is Map) {
      _day = day;
      for (final e in slots.entries) {
        final v = e.value;
        if (v is! Map || v['picks'] is! List) continue;
        final slot = _slots.putIfAbsent(e.key.toString(), _Slot.empty);
        slot.picks = [for (final p in v['picks'] as List) p.toString()];
        slot.lift = '${v['lift'] ?? ''}';
        final done = v['done'], swapped = v['swapped'];
        if (done is List) slot.done.addAll(done.map((x) => x.toString()));
        if (swapped is List) {
          slot.swapped.addAll(swapped.map((x) => x.toString()));
        }
      }
      return true;
    }
    return false;
  }

  Map<String, Object> _toJson() => {
        'day': _day,
        'slots': {
          for (final e in _slots.entries)
            e.key: {
              'picks': e.value.picks,
              'done': e.value.done.toList(),
              'swapped': e.value.swapped.toList(),
              'lift': e.value.lift,
            },
        },
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
      {Set<String> exclude = const {}, Set<String> lift = const {}}) {
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
      // What she told us (PP 4), but only a card that fits the age exactly:
      // a lift never brings in a card from the widened band.
      final la = lift.contains(a.areaId) && growSuitsAge(a, ageMonths);
      final lb = lift.contains(b.areaId) && growSuitsAge(b, ageMonths);
      if (la != lb) return la ? -1 : 1;
      // The child's own phase doc first (the user, 2026-10-13: "into
      // Today, this phase first"), then any exact fit, then the band.
      final pa = ppIsOwnPhaseDocActivity(a, ageMonths), pb = ppIsOwnPhaseDocActivity(b, ageMonths);
      if (pa != pb) return pa ? -1 : 1;
      final ea = growSuitsAge(a, ageMonths), eb = growSuitsAge(b, ageMonths);
      if (ea != eb) return ea ? -1 : 1; // exact fit before widened band
      return _score(a.id, day).compareTo(_score(b.id, day));
    }
    pool.sort(cmp);
    return pool;
  }

  /// Rolls the store over to today if its slots are for another day, and
  /// fills this child's slot if it has none yet. Called by every public read
  /// so the roll happens on the first look after midnight (or after a child
  /// switch) rather than needing a timer or a listener on the child store.
  void _rollover(int ageMonths, String? childId) {
    final today = _todayKey();
    _current = slotKey(childId, ageMonths);
    if (_day != today) {
      _day = today;
      _slots.clear();
    }
    final lift = _liftAreas();
    final liftKey = (lift.toList()..sort()).join(',');
    final have = _slots[_current];
    // Kept for revert: if (have != null && have.picks.length >= kPpHomeActivityCount) return;
    if (have != null &&
        have.picks.length >= kPpHomeActivityCount &&
        (have.lift == liftKey || have.done.isNotEmpty || have.swapped.isNotEmpty)) {
      return;
    }
    final fresh = _ranked(ageMonths, today, lift: lift)
        .take(kPpHomeActivityCount)
        .map((a) => a.id)
        .toList();
    _slots[_current] = _Slot.empty()
      ..picks = fresh
      ..lift = liftKey;
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

  /// The areas what she told us lifts today. Empty without her yes, because
  /// `active()` is empty then. Defensive: a store that cannot answer lifts
  /// nothing.
  Set<String> _liftAreas() {
    try {
      return {
        for (final c in ppActivityChanges(PpChangesStore.instance.active(now: now())))
          ...kPpChangeActivityAreas[c.concernId]!,
      };
    } catch (_) {
      return const {};
    }
  }

  // ---- Public API -----------------------------------------------------------

  /// Today's activities for [childId] at [ageMonths], in display order.
  /// Never fewer than three unless the whole library is smaller than three.
  /// [childId] is `ChildProfileStore.activeChildId`; null is the stand-in.
  List<DevActivity> todays(int ageMonths, {String? childId}) {
    ensureLoaded();
    _rollover(ageMonths, childId);
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
  void swap(String id, int ageMonths, {String? childId}) {
    _rollover(ageMonths, childId);
    final i = _picks.indexOf(id);
    if (i < 0 || _done.contains(id)) return;
    final today = _todayKey();
    _lastSeen[id] = today;
    final candidates =
        _ranked(ageMonths, '$today#${_swappedIn.length}', exclude: {..._picks}, lift: _liftAreas());
    if (candidates.isEmpty) return; // the pool has nothing else; keep the card
    final next = candidates.first;
    _slot.picks = [..._picks]..[i] = next.id;
    _swappedIn.add(next.id);
    _lastSeen[next.id] = today;
    notifyListeners();
  }

  /// Test hook: forget everything.
  @visibleForTesting
  void resetForTest() {
    _day = '';
    _slots.clear();
    _current = '';
    _lastSeen.clear();
  }
}

/// One child's three for one day: what was picked, ticked and swapped in.
class _Slot {
  _Slot.empty();
  List<String> picks = const [];

  /// The lift areas the picks were made with (PP 4), so a new answer can
  /// re-pick an untouched slot.
  String lift = '';
  final Set<String> done = {};
  final Set<String> swapped = {};
}
