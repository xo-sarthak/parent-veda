// =============================================================================
//  ReadToBabyStore - preferences for the customizable "Read to your baby" feed
// -----------------------------------------------------------------------------
//  Holds which content categories the mother wants her daily read to draw from
//  (children's stories / spiritual reading / rhymes / affirmations) and, when
//  spiritual reading is on, which traditions. Persisted via shared_preferences.
//  Default: children's stories ON, everything else OFF (no spiritual unless she
//  chooses it).
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

import 'remote/cloud_merged_store.dart';
// import 'remote/cloud_synced_store.dart'; // kept for revert (step 13)

import '../data/read_to_baby_data.dart';
import '../data/spiritual_reading_data.dart';

// Per-item since step 13 (2026-10-22, sync log). It synced as one whole blob,
// so a tradition turned on on one phone and a category on the other erased
// each other. Items: `cat|<category>` (bool, only where it differs from the
// default), `rel|<tradition>` and `sec|<tradition>|<index>` (true), and
// `offset` (only when non-zero). The defaults hold no items, so an unused
// store is empty and applyCloudItems({}) gives the defaults back.
class ReadToBabyStore extends ChangeNotifier with CloudMergedStore {
  ReadToBabyStore._();
  static final ReadToBabyStore instance = ReadToBabyStore._();

  static const _catKey = 'rtb_categories';
  static const _relKey = 'rtb_religions';
  static const _secKey = 'rtb_sections';
  static const _offsetKey = 'rtb_prompt_offset';

  // Default: the Samvad speaking cards + children's stories ON (everything else
  // off until the mother chooses it). Speaking-on preserves the original Samvad
  // experience now that it lives behind the unified Customize sheet.
  final Set<String> _categories = {kRtbSpeaking, kRtbStories};
  final Set<String> _religions = {};
  // Enabled sub-sections, keyed "<traditionId>|<sectionIndex>".
  final Set<String> _sections = {};
  // "Another prompt" offset for the daily Samvad piece - SHARED so when the
  // mother cycles, the father's "Read to your baby" advances to the same piece.
  int _promptOffset = 0;
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      final cats = p.getStringList(_catKey);
      if (cats != null) {
        _categories
          ..clear()
          ..addAll(cats);
      }
      final rels = p.getStringList(_relKey);
      if (rels != null) {
        _religions
          ..clear()
          ..addAll(rels);
      }
      final secs = p.getStringList(_secKey);
      if (secs != null) {
        _sections
          ..clear()
          ..addAll(secs);
      }
      _promptOffset = p.getInt(_offsetKey) ?? 0;
    } catch (_) {/* keep defaults */}
    _loaded = true;
    notifyListeners();
    // await syncStateFromCloud(); // kept for revert (step 13)
    await syncMergedFromCloud();
  }

  // ---- cloud (CloudMergedStore, step 13) ---------------------------------------
  @override
  String get cloudKey => 'read_to_baby_prefs';
  @override
  String? get legacyBlobKey => cloudKey;

  // Kept for revert (step 13): applyCloudItems({}) is the empty state now.
  //   /// What a sign-out resets this store to (2026-10-17): the blob of a store nobody has used.
  //   @override
  //   Object get cloudEmptyData => const <String, Object?>{'categories': [kRtbSpeaking, kRtbStories], 'religions': <String>[], 'sections': <String>[], 'offset': 0};
  //
  //   @override
  //   Object cloudData() => {
  //         'categories': _categories.toList(),
  //         'religions': _religions.toList(),
  //         'sections': _sections.toList(),
  //         'offset': _promptOffset,
  //       };

  static const Set<String> _defaultCategories = {kRtbSpeaking, kRtbStories};

  @override
  Map<String, Object?> cloudItems() => {
        for (final c in {..._defaultCategories, ..._categories})
          if (_categories.contains(c) != _defaultCategories.contains(c))
            'cat|$c': _categories.contains(c),
        for (final r in _religions) 'rel|$r': true,
        for (final k in _sections) 'sec|$k': true,
        // One counter, last write wins: two phones advancing at once can lose
        // a step. It only picks the day's prompt, so that is acceptable.
        if (_promptOffset != 0) 'offset': _promptOffset,
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _categories
      ..clear()
      ..addAll(_defaultCategories);
    _religions.clear();
    _sections.clear();
    _promptOffset = 0;
    for (final e in items.entries) {
      final k = e.key;
      if (k.startsWith('cat|')) {
        final c = k.substring(4);
        if (e.value == true) {
          _categories.add(c);
        } else {
          _categories.remove(c);
        }
      } else if (k.startsWith('rel|')) {
        _religions.add(k.substring(4));
      } else if (k.startsWith('sec|')) {
        _sections.add(k.substring(4));
      } else if (k == 'offset') {
        final o = e.value;
        if (o is num) _promptOffset = o.toInt();
      }
    }
    _loaded = true;
  }

  @override
  void applyLegacyBlob(Object blob) {
    final data = blob;
    if (data is! Map) return;
    List<String> list(Object? v) => v is List ? v.whereType<String>().toList() : const [];
    if (data['categories'] != null) {
      _categories
        ..clear()
        ..addAll(list(data['categories']));
    }
    _religions
      ..clear()
      ..addAll(list(data['religions']));
    _sections
      ..clear()
      ..addAll(list(data['sections']));
    final o = data['offset'];
    if (o is num) _promptOffset = o.toInt();
  }

  @override
  Future<void> persistLocalCache() => _persist();

  Set<String> get categories => Set.unmodifiable(_categories);
  Set<String> get religions => Set.unmodifiable(_religions);
  int get promptOffset => _promptOffset;

  /// Advance the daily Samvad "another prompt" - shared by mother + father.
  void nextPrompt() {
    _promptOffset++;
    _persist();
    notifyListeners();
  }

  bool isCategoryOn(String c) => _categories.contains(c);
  bool isReligionOn(String id) => _religions.contains(id);
  bool isSectionOn(String tradId, int idx) =>
      _sections.contains('$tradId|$idx');

  void toggleCategory(String c) {
    if (!_categories.remove(c)) _categories.add(c);
    _persist();
    notifyListeners();
  }

  void toggleReligion(String id) {
    if (_religions.remove(id)) {
      // turned OFF - drop all of its sub-section keys too.
      _sections.removeWhere((k) => k.startsWith('$id|'));
    } else {
      _religions.add(id);
      // turned ON - default-enable every sub-section so it works immediately.
      final t = kSpiritualTraditions.where((x) => x.id == id);
      if (t.isNotEmpty) {
        for (var i = 0; i < t.first.sections.length; i++) {
          _sections.add('$id|$i');
        }
      }
    }
    _persist();
    notifyListeners();
  }

  void toggleSection(String tradId, int idx) {
    final k = '$tradId|$idx';
    if (!_sections.remove(k)) _sections.add(k);
    _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_catKey, _categories.toList());
      await p.setStringList(_relKey, _religions.toList());
      await p.setStringList(_secKey, _sections.toList());
      await p.setInt(_offsetKey, _promptOffset);
    } catch (_) {/* best-effort */}
  }
}
