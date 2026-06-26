// =============================================================================
//  ReadToBabyStore — preferences for the customizable "Read to your baby" feed
// -----------------------------------------------------------------------------
//  Holds which content categories the mother wants her daily read to draw from
//  (children's stories / spiritual reading / rhymes / affirmations) and, when
//  spiritual reading is on, which traditions. Persisted via shared_preferences.
//  Default: children's stories ON, everything else OFF (no spiritual unless she
//  chooses it).
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/read_to_baby_data.dart';
import '../data/spiritual_reading_data.dart';

class ReadToBabyStore extends ChangeNotifier {
  ReadToBabyStore._();
  static final ReadToBabyStore instance = ReadToBabyStore._();

  static const _catKey = 'rtb_categories';
  static const _relKey = 'rtb_religions';
  static const _secKey = 'rtb_sections';

  final Set<String> _categories = {kRtbStories};
  final Set<String> _religions = {};
  // Enabled sub-sections, keyed "<traditionId>|<sectionIndex>".
  final Set<String> _sections = {};
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
    } catch (_) {/* keep defaults */}
    _loaded = true;
    notifyListeners();
  }

  Set<String> get categories => Set.unmodifiable(_categories);
  Set<String> get religions => Set.unmodifiable(_religions);
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
      // turned OFF — drop all of its sub-section keys too.
      _sections.removeWhere((k) => k.startsWith('$id|'));
    } else {
      _religions.add(id);
      // turned ON — default-enable every sub-section so it works immediately.
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
    } catch (_) {/* best-effort */}
  }
}
