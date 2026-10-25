// =============================================================================
//  What she told us: "Something changed?" remembered (2026-10-23, Wave 8)
// -----------------------------------------------------------------------------
//  Before this, the What changed flow kept its answers in widget state, so the
//  moment the screen closed the app forgot that Aarav was waking every two
//  hours. Approved as an Artifact (claude.ai/artifact/RwVWyxCE6VzYoFFJCakaCP).
//
//  A change is one concern per child, with the day she told us and the tone of
//  the result. It stays ACTIVE for three weeks or until she taps "Better now"
//  (the user, 2026-10-23), and while active the relevance brain lifts pages
//  about it (pp_relevance.dart). It only orders; nothing is hidden or decided.
//
//  Sync: the step-13 per-item merge, the same shape as DevStore. One item per
//  change, keyed `c|<childId>|<concernId>`, so two phones telling us different
//  things both keep theirs, and each child keeps its own. No migration: the
//  server merge takes any store key.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/pp_use_consent.dart';
import '../../services/remote/cloud_merged_store.dart';
import 'pp_child_profile.dart';
import 'pp_what_changed_data.dart';

/// How long a change keeps lifting content (the user, 2026-10-23).
const Duration kPpChangeActiveFor = Duration(days: 21);

/// One thing she told us.
class PpChange {
  const PpChange({required this.childId, required this.concernId, required this.at, required this.tone});

  final String childId;
  final String concernId;
  final DateTime at;
  final WcTone tone;

  WcConcern? get concern {
    for (final c in kWcConcerns) {
      if (c.id == concernId) return c;
    }
    return null;
  }

  bool activeAt(DateTime now) => now.difference(at) < kPpChangeActiveFor;

  /// Lower-case words that mark a page as being about this change: the
  /// concern's own label words and keywords, plus its area's words.
  List<String> get words {
    final c = concern;
    if (c == null) return const [];
    return [
      ...c.keywords.map((k) => k.toLowerCase()),
      ...?kPpChangeAreaWords[c.category],
    ];
  }

  bool matches(String text) {
    final t = text.toLowerCase();
    return words.any(t.contains);
  }

  /// The words a moved card shows: "Because you said: waking every 2 hours".
  String get why => 'Because you said: ${(concern?.label ?? concernId).toLowerCase()}';

  Map<String, Object?> toJson() => {'at': at.toIso8601String(), 'tone': tone.name};
}

/// The words of each What changed area, as they appear in page titles. Short
/// stems so "settling" and "settle" both match.
const Map<String, List<String>> kPpChangeAreaWords = {
  'Sleep': ['sleep', 'nap', 'night', 'wak', 'settl', 'bedtime'],
  'Feeding': ['feed', 'milk', 'latch', 'bottle', 'formula', 'solids', 'weaning'],
  'Illness': ['fever', 'cough', 'cold', 'unwell', 'sick', 'temperature'],
  'Mood': ['cry', 'fuss', 'calm', 'colic', 'clingy', 'soothe'],
  'Skin': ['rash', 'skin', 'eczema', 'nappy'],
  'Tummy': ['tummy', 'poo', 'constipat', 'vomit', 'reflux', 'wind', 'gas'],
  'Teething': ['teeth', 'teething', 'gum'],
  'Behaviour': ['tantrum', 'behaviour', 'hitting', 'biting'],
  'Development': ['milestone', 'development', 'crawl', 'walk', 'talk'],
};

class PpChangesStore extends ChangeNotifier with CloudMergedStore {
  PpChangesStore._();
  static final PpChangesStore instance = PpChangesStore._();

  /// `<childId>|<concernId>` -> the change. Cleared ones are removed.
  final Map<String, PpChange> _changes = {};

  static const _prefsKey = 'pp_changes';

  @override
  String get cloudKey => _prefsKey;

  String get _childId => ChildProfileStore.instance.activeChildId ?? '_none';

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) applyCloudItems((jsonDecode(raw) as Map).cast<String, Object?>());
    } catch (_) {/* start empty */}
    notifyListeners();
    try {
      await syncMergedFromCloud();
    } catch (_) {/* stay local */}
  }

  @override
  Map<String, Object?> cloudItems() => {
        for (final c in _changes.values) 'c|${c.childId}|${c.concernId}': c.toJson(),
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _changes.clear();
    for (final e in items.entries) {
      final parts = e.key.split('|');
      final v = e.value;
      if (parts.length != 3 || parts[0] != 'c' || v is! Map) continue;
      final at = DateTime.tryParse('${v['at']}');
      if (at == null) continue;
      final tone = WcTone.values.where((t) => t.name == v['tone']).firstOrNull ?? WcTone.calm;
      _changes['${parts[1]}|${parts[2]}'] =
          PpChange(childId: parts[1], concernId: parts[2], at: at, tone: tone);
    }
  }

  @override
  Future<void> persistLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(cloudItems()));
    } catch (_) {}
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    persistLocalCache();
  }

  /// Remember a change for the child on screen. Telling us again restarts the
  /// three weeks.
  void note(WcConcern concern, WcTone tone, {DateTime? at}) {
    final id = _childId;
    _changes['$id|${concern.id}'] =
        PpChange(childId: id, concernId: concern.id, at: at ?? DateTime.now(), tone: tone);
    notifyListeners();
  }

  /// "Better now" or "Not now": forget it.
  void clear(String concernId) {
    if (_changes.remove('$_childId|$concernId') != null) notifyListeners();
  }

  bool isActive(String concernId) {
    final c = _changes['$_childId|$concernId'];
    return c != null && c.activeAt(DateTime.now());
  }

  /// The active changes for the child on screen, newest first.
  ///
  /// ⚠️ ONLY WITH HER YES (tools pass H3, 2026-10-25). Every reader (the home
  /// "You told us" card, the relevance brain) comes through here, so the ask
  /// once answer is checked in one place. Saved changes are kept either way;
  /// a no only stops them being used.
  List<PpChange> active({DateTime? now}) {
    if (!PpUseConsent.instance.allows(PpUseKind.changes)) return const [];
    final t = now ?? DateTime.now();
    final id = _childId;
    return _changes.values.where((c) => c.childId == id && c.activeAt(t)).toList()
      ..sort((a, b) => b.at.compareTo(a.at));
  }

  @visibleForTesting
  void debugReset() => _changes.clear();
}
