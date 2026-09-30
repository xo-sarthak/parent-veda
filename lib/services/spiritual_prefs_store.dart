// =============================================================================
//  SpiritualPrefsStore - per-read Interested / Not-interested preferences
// -----------------------------------------------------------------------------
//  Lets the mother mark individual Spiritual-Reading items as Interested or
//  Not-interested. Interested items are gently floated to the top of a list and
//  Not-interested ones are greyed and sunk to the bottom. Keyed by read TITLE
//  (titles are unique within the tool and are already used as save-keys
//  elsewhere). Persisted via shared_preferences.
//
//  Self-initialising: loads lazily on first construction so it needs no wiring
//  in main.dart. Best-effort persistence (failures keep in-memory state).
//
//  ⚠️ SYNCED SINCE 2026-09-23 (the persistence audit). It was phone-only with
//  no stated reason — unlike the birth plan and the scan checklist, which are
//  local on purpose and say why. The user's rule: "we should be able to
//  maintain her activity… if she saves something, likes something". A choice
//  she made about her own reading is hers on the next phone too. One blob in
//  `user_state` through `CloudSyncedStore`: cloud wins on first sync, local
//  seeds the cloud when the cloud is empty, a logged-out phone is unchanged.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/spiritual_reading_data.dart';
import 'remote/cloud_synced_store.dart';

/// Moves "not interested" marks saved under a DISPLAY title onto the English
/// title that identifies the read (2026-09-30).
///
/// ⚠️ THE BUG THIS UNDOES. The screen saved "not interested" under `title.now`
/// while "interested" and the sort used `title.en`. In English the two strings
/// are the same, so nothing showed. Once a mother chose Hindi, the mark was
/// saved as the Devanagari title, so it matched nothing when she switched back,
/// and the other half of the app (the sort, which asks by `.en`) never saw it.
///
/// THE MIGRATION. Every key that is already an English title stays. A key that is
/// a Hindi title of a read becomes that read's English title. A key that is
/// neither (a read since removed or reworded) stays as it is: dropping it would
/// be a guess, keeping it costs one string. Pure and idempotent, so it can run on
/// every load and on every cloud apply, and a second run changes nothing.
///
/// Trade-off, named: it maps by exact Hindi title, and the seed has a few
/// Hindi titles that two different English reads share (both "Kindness to the
/// weary" and "Gentle with the weary" are translated the same way). A stale
/// Hindi mark on one of those cannot say which read she meant, so it is NOT
/// migrated: guessing would mark the wrong read as "not interested", which is
/// worse than losing a mark she can tap again. New marks are English-keyed and
/// have no such ambiguity.
Set<String> migrateSpiritualNotInterested(
  Iterable<String> keys, {
  required Set<String> englishTitles,
  required Map<String, String> hindiToEnglish,
}) {
  return {
    for (final k in keys)
      if (englishTitles.contains(k)) k else (hindiToEnglish[k] ?? k),
  };
}

/// The English titles, and each Hindi title's English twin, of every read.
({Set<String> en, Map<String, String> hiToEn}) spiritualTitleIndex() {
  final en = <String>{};
  final hiToEn = <String, String>{};
  final ambiguous = <String>{};
  for (final t in kSpiritualTraditions) {
    for (final sec in t.sections) {
      for (final r in sec.reads) {
        en.add(r.title.en);
        final known = hiToEn[r.title.hi];
        if (known != null && known != r.title.en) {
          ambiguous.add(r.title.hi);
        } else {
          hiToEn[r.title.hi] = r.title.en;
        }
      }
    }
  }
  // Two English reads behind one Hindi title: leave that key alone.
  hiToEn.removeWhere((hi, _) => ambiguous.contains(hi));
  return (en: en, hiToEn: hiToEn);
}

class SpiritualPrefsStore extends ChangeNotifier with CloudSyncedStore {
  SpiritualPrefsStore._() {
    _load();
  }
  static final SpiritualPrefsStore instance = SpiritualPrefsStore._();

  static const _interestedKey = 'spr_interested';
  static const _notInterestedKey = 'spr_not_interested';

  final Set<String> _interested = {};
  final Set<String> _notInterested = {};
  bool _loaded = false;

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      _interested
        ..clear()
        ..addAll(p.getStringList(_interestedKey) ?? const []);
      _notInterested
        ..clear()
        ..addAll(p.getStringList(_notInterestedKey) ?? const []);
    } catch (_) {/* keep defaults */}
    _loaded = true;
    if (_migrateNotInterested()) await _persist();
    notifyListeners();
    await syncStateFromCloud();
  }

  /// Re-keys any "not interested" mark saved under a display title. True when
  /// something moved, so the caller knows to write it back.
  bool _migrateNotInterested() {
    final idx = spiritualTitleIndex();
    final moved = migrateSpiritualNotInterested(_notInterested,
        englishTitles: idx.en, hindiToEnglish: idx.hiToEn);
    if (moved.length == _notInterested.length && moved.containsAll(_notInterested)) {
      return false;
    }
    _notInterested
      ..clear()
      ..addAll(moved);
    // A read cannot be both: an English-keyed "interested" wins over a stale mark.
    _notInterested.removeAll(_interested);
    return true;
  }

  // ---- cloud (CloudSyncedStore) ----------------------------------------------
  @override
  String get cloudKey => 'spiritual_prefs';

  @override
  Object cloudData() => {
        'interested': _interested.toList(),
        'not_interested': _notInterested.toList(),
      };

  @override
  void applyCloudData(Object data) {
    if (data is! Map) return;
    List<String> list(Object? v) => v is List ? v.whereType<String>().toList() : const [];
    _interested
      ..clear()
      ..addAll(list(data['interested']));
    _notInterested
      ..clear()
      ..addAll(list(data['not_interested']));
    // The cloud copy may come from a phone that saved display titles.
    _migrateNotInterested();
  }

  @override
  Future<void> persistLocalCache() => _persist();

  bool isInterested(String key) => _interested.contains(key);
  bool isNotInterested(String key) => _notInterested.contains(key);

  /// Toggle "interested"; clears any "not interested" on the same item.
  void toggleInterested(String key) {
    if (_interested.remove(key)) {
      // was interested → now neutral
    } else {
      _interested.add(key);
      _notInterested.remove(key);
    }
    _persist();
    notifyListeners();
  }

  /// Toggle "not interested"; clears any "interested" on the same item.
  void toggleNotInterested(String key) {
    if (_notInterested.remove(key)) {
      // was not-interested → now neutral
    } else {
      _notInterested.add(key);
      _interested.remove(key);
    }
    _persist();
    notifyListeners();
  }

  /// Sort helper: interested first (0), neutral (1), not-interested last (2).
  int rank(String key) => isInterested(key)
      ? 0
      : isNotInterested(key)
          ? 2
          : 1;

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_interestedKey, _interested.toList());
      await p.setStringList(_notInterestedKey, _notInterested.toList());
    } catch (_) {/* best-effort */}
  }
}
