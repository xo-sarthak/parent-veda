// =============================================================================
//  ParentVeda Personalization Engine — the Living Family Profile
// -----------------------------------------------------------------------------
//  The single source of truth that quietly makes ParentVeda feel personal. This
//  is NOT an onboarding form — it's a background intelligence layer.
//
//  CRITICAL GUARDRAIL (Product Bible): personalization influences CONTENT,
//  RECOMMENDATIONS and PRIORITY-ORDERING only — never navigation, IA, screen
//  hierarchy, feature locations or section names. Every user learns ONE app;
//  the engine just adapts *what* they see and *what's surfaced first*, never
//  *where* they find it. Features READ this profile; they never restructure.
//
//  The profile grows over time (initial setup + progressive profiling in-context
//  + trackers/journal later), so it never feels "complete". Child basics
//  (name/sex/DOB/age) stay in [ChildProfileStore]; this store owns the richer
//  family signals and the engine query API. Cloud-synced like the other stores.
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/cloud_synced_store.dart';
import 'pp_child_profile.dart';

// ---- the signals ------------------------------------------------------------
/// Things a paediatrician may have mentioned. Tapped, never typed.
enum HealthCondition { eczema, cmpa, foodAllergy, reflux, colic, tongueTie, asthma, lowBirthWeight, devDelay, hearing, vision }

enum FeedingMethod { breastfeeding, formula, mixed, expressed, solids, weaning }

enum SleepPattern { well, nightWaking, shortNaps, earlyWaking, unsure }

/// What the parent most wants help with (multi-select).
enum Priority { sleep, feeding, development, nutrition, behaviour, learning, milestones, brain, play, health }

enum LearningStyle { essentials, science, videos, stepByStep, detail }

enum NotifyTopic { vaccinations, feeding, sleep, activities, articles, milestones, recipes, weekly }

// ---- labels (UI-facing; content only) --------------------------------------
extension HealthConditionX on HealthCondition {
  String get label => switch (this) {
        HealthCondition.eczema => 'Eczema',
        HealthCondition.cmpa => 'Cow-milk protein allergy',
        HealthCondition.foodAllergy => 'Food allergies',
        HealthCondition.reflux => 'Reflux',
        HealthCondition.colic => 'Colic',
        HealthCondition.tongueTie => 'Tongue tie',
        HealthCondition.asthma => 'Asthma',
        HealthCondition.lowBirthWeight => 'Low birth weight',
        HealthCondition.devDelay => 'Developmental delay',
        HealthCondition.hearing => 'Hearing concerns',
        HealthCondition.vision => 'Vision concerns',
      };
}

extension FeedingMethodX on FeedingMethod {
  String get label => switch (this) {
        FeedingMethod.breastfeeding => 'Breastfeeding',
        FeedingMethod.formula => 'Formula',
        FeedingMethod.mixed => 'Mixed feeding',
        FeedingMethod.expressed => 'Expressed milk',
        FeedingMethod.solids => 'Solids',
        FeedingMethod.weaning => 'Weaning',
      };
}

extension SleepPatternX on SleepPattern {
  String get label => switch (this) {
        SleepPattern.well => 'Sleeping well',
        SleepPattern.nightWaking => 'Frequent night waking',
        SleepPattern.shortNaps => 'Short naps',
        SleepPattern.earlyWaking => 'Early waking',
        SleepPattern.unsure => 'Not sure yet',
      };
}

extension PriorityX on Priority {
  String get label => switch (this) {
        Priority.sleep => 'Sleep',
        Priority.feeding => 'Feeding',
        Priority.development => 'Development',
        Priority.nutrition => 'Nutrition',
        Priority.behaviour => 'Behaviour',
        Priority.learning => 'Learning',
        Priority.milestones => 'Milestones',
        Priority.brain => 'Brain development',
        Priority.play => 'Play',
        Priority.health => 'Health',
      };
}

extension LearningStyleX on LearningStyle {
  String get label => switch (this) {
        LearningStyle.essentials => 'Just the essentials',
        LearningStyle.science => 'Explain the science',
        LearningStyle.videos => 'Videos first',
        LearningStyle.stepByStep => 'Step-by-step guidance',
        LearningStyle.detail => 'I enjoy reading in detail',
      };
}

extension NotifyTopicX on NotifyTopic {
  String get label => switch (this) {
        NotifyTopic.vaccinations => 'Vaccinations',
        NotifyTopic.feeding => 'Feeding',
        NotifyTopic.sleep => 'Sleep',
        NotifyTopic.activities => 'Activities',
        NotifyTopic.articles => 'Articles',
        NotifyTopic.milestones => 'Milestones',
        NotifyTopic.recipes => 'Recipes',
        NotifyTopic.weekly => 'Weekly journey',
      };
}

/// Progressive-profiling fields we may gently ask about later, in-context.
enum ProfileField { health, feeding, sleep, priorities, learning }

// ---- the store --------------------------------------------------------------
class FamilyProfileStore extends ChangeNotifier with CloudSyncedStore {
  FamilyProfileStore._();
  static final FamilyProfileStore instance = FamilyProfileStore._();

  static const _key = 'family_profile';

  final Set<HealthCondition> _conditions = {};
  FeedingMethod? _feeding;
  SleepPattern? _sleep;
  final Set<Priority> _priorities = {};
  LearningStyle? _learning;
  final Set<NotifyTopic> _notify = {};
  bool _premature = false;
  bool _nicu = false;
  bool _multiple = false;
  bool _onboarded = false;
  final Set<ProfileField> _asked = {}; // fields already prompted (don't nag)
  bool _loaded = false;

  // ---- reads --------------------------------------------------------------
  Set<HealthCondition> get conditions => Set.unmodifiable(_conditions);
  FeedingMethod? get feeding => _feeding;
  SleepPattern? get sleep => _sleep;
  Set<Priority> get priorities => Set.unmodifiable(_priorities);
  LearningStyle? get learning => _learning;
  Set<NotifyTopic> get notify => Set.unmodifiable(_notify);
  bool get premature => _premature;
  bool get nicu => _nicu;
  bool get multiple => _multiple;
  bool get onboarded => _onboarded;

  bool hasCondition(HealthCondition c) => _conditions.contains(c);
  bool wants(Priority p) => _priorities.contains(p);

  String get childName => ChildProfileStore.instance.name;

  /// 0..1 completeness across the key sections (never forced to 1).
  double get completeness {
    var filled = 0;
    const total = 5;
    if (_conditions.isNotEmpty || _asked.contains(ProfileField.health)) filled++;
    if (_feeding != null) filled++;
    if (_sleep != null) filled++;
    if (_priorities.isNotEmpty) filled++;
    if (_learning != null) filled++;
    return filled / total;
  }

  int get completenessPercent => (completeness * 100).round();

  bool asked(ProfileField f) => _asked.contains(f);

  /// True when a field is unknown AND we haven't prompted for it yet — the cue
  /// for a gentle in-context ask (progressive profiling). Never interrupts twice.
  bool shouldAsk(ProfileField f) {
    if (_asked.contains(f)) return false;
    return switch (f) {
      ProfileField.health => _conditions.isEmpty,
      ProfileField.feeding => _feeding == null,
      ProfileField.sleep => _sleep == null,
      ProfileField.priorities => _priorities.isEmpty,
      ProfileField.learning => _learning == null,
    };
  }

  // ---- ENGINE: the query API features consume (content/reco/order only) ----

  /// LEVEL 3 — priority ordering. Stable-sorts [items] so those whose [keyOf]
  /// priority the family chose come first; everything else keeps its order.
  /// NOTHING is hidden or moved out — only surfaced earlier.
  List<T> orderByPriority<T>(List<T> items, Priority? Function(T) keyOf) {
    final scored = <(int, int, T)>[]; // (rank, originalIndex, item)
    for (var i = 0; i < items.length; i++) {
      final p = keyOf(items[i]);
      final rank = (p != null && _priorities.contains(p)) ? 0 : 1;
      scored.add((rank, i, items[i]));
    }
    scored.sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2));
    return scored.map((e) => e.$3).toList();
  }

  /// LEVEL 1 — a personalized "Today's Focus" line for the family. Content
  /// choice, not a layout change.
  String personalizedFocus() {
    final name = childName;
    // Health first (most actionable), then top priority, then a gentle default.
    if (hasCondition(HealthCondition.eczema)) return 'Gentle skin care for $name today';
    if (hasCondition(HealthCondition.reflux)) return 'Easing reflux for $name';
    if (hasCondition(HealthCondition.cmpa) || hasCondition(HealthCondition.foodAllergy)) {
      return 'Allergy-aware feeding for $name';
    }
    if (_sleep == SleepPattern.nightWaking || wants(Priority.sleep)) return 'Better sleep for $name this week';
    if (_feeding == FeedingMethod.solids || _feeding == FeedingMethod.weaning || wants(Priority.feeding)) {
      return 'Making solids easier for $name';
    }
    if (wants(Priority.development) || wants(Priority.brain)) return "$name's development this week";
    if (wants(Priority.play)) return 'Playful learning with $name';
    return "$name's day, thoughtfully";
  }

  /// LEVEL 2 — recommendation boosts. Maps a lightweight interest/topic key to a
  /// positive weight, so a scoring engine can rank relevant items higher without
  /// removing anything. Keys are plain strings features can match on.
  Map<String, double> recoBoosts() {
    final out = <String, double>{};
    void add(String k, double w) => out[k] = (out[k] ?? 0) + w;
    for (final p in _priorities) {
      add(p.name, 1.0);
    }
    for (final c in _conditions) {
      add(c.name, 1.4); // health signals rank strongest
    }
    if (_feeding != null) add(_feeding!.name, 0.8);
    if (_sleep != null && _sleep != SleepPattern.well && _sleep != SleepPattern.unsure) add('sleep', 0.8);
    if (_learning == LearningStyle.videos) add('video', 0.6);
    return out;
  }

  /// LEVEL 2 — does this free-text topic/tag line match a family signal? A cheap
  /// helper for content filters ("show eczema articles first").
  bool matchesSignal(String text) {
    final t = text.toLowerCase();
    for (final c in _conditions) {
      if (t.contains(c.name.toLowerCase()) || t.contains(c.label.toLowerCase())) return true;
    }
    for (final p in _priorities) {
      if (t.contains(p.name.toLowerCase()) || t.contains(p.label.toLowerCase())) return true;
    }
    return false;
  }

  /// A short natural-language summary of the family — for the AI context layer
  /// (Ask Veda) so it never has to re-ask what we already know.
  String aiContext() {
    final c = ChildProfileStore.instance;
    final parts = <String>['${c.name} is ${c.ageLabel} old'];
    if (_feeding != null) parts.add('feeding: ${_feeding!.label.toLowerCase()}');
    if (_conditions.isNotEmpty) parts.add('noted: ${_conditions.map((e) => e.label.toLowerCase()).join(', ')}');
    if (_sleep != null) parts.add('sleep: ${_sleep!.label.toLowerCase()}');
    if (_priorities.isNotEmpty) parts.add('wants help with: ${_priorities.map((e) => e.label.toLowerCase()).join(', ')}');
    return parts.join(' · ');
  }

  // ---- writes -------------------------------------------------------------
  void toggleCondition(HealthCondition c) {
    if (!_conditions.add(c)) _conditions.remove(c);
    _save();
  }

  void clearConditions() {
    _conditions.clear();
    _save();
  }

  void setFeeding(FeedingMethod? f) {
    _feeding = f;
    _save();
  }

  void setSleep(SleepPattern? s) {
    _sleep = s;
    _save();
  }

  void togglePriority(Priority p) {
    if (!_priorities.add(p)) _priorities.remove(p);
    _save();
  }

  void setLearning(LearningStyle? l) {
    _learning = l;
    _save();
  }

  void toggleNotify(NotifyTopic n) {
    if (!_notify.add(n)) _notify.remove(n);
    _save();
  }

  void setBirth({bool? premature, bool? nicu, bool? multiple}) {
    if (premature != null) _premature = premature;
    if (nicu != null) _nicu = nicu;
    if (multiple != null) _multiple = multiple;
    _save();
  }

  void markOnboarded() {
    _onboarded = true;
    _save();
  }

  /// Record that we've asked about a field (so progressive profiling won't nag).
  void markAsked(ProfileField f) {
    if (_asked.add(f)) _save();
  }

  // ---- load / persist / cloud --------------------------------------------
  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) _apply(jsonDecode(raw) as Map);
    } catch (_) {/* defaults */}
    _loaded = true;
    notifyListeners();
    // Defensive: a cloud/Supabase hiccup must never break init (also test-safe).
    try {
      await syncStateFromCloud();
    } catch (_) {/* stay local */}
  }

  void _apply(Map m) {
    _conditions
      ..clear()
      ..addAll(_decode(m['conditions'], HealthCondition.values));
    _feeding = _one(m['feeding'], FeedingMethod.values);
    _sleep = _one(m['sleep'], SleepPattern.values);
    _priorities
      ..clear()
      ..addAll(_decode(m['priorities'], Priority.values));
    _learning = _one(m['learning'], LearningStyle.values);
    _notify
      ..clear()
      ..addAll(_decode(m['notify'], NotifyTopic.values));
    _premature = m['premature'] == true;
    _nicu = m['nicu'] == true;
    _multiple = m['multiple'] == true;
    _onboarded = m['onboarded'] == true;
    _asked
      ..clear()
      ..addAll(_decode(m['asked'], ProfileField.values));
  }

  static Iterable<T> _decode<T extends Enum>(Object? raw, List<T> values) sync* {
    if (raw is List) {
      for (final e in raw) {
        for (final v in values) {
          if (v.name == e.toString()) {
            yield v;
            break;
          }
        }
      }
    }
  }

  static T? _one<T extends Enum>(Object? raw, List<T> values) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.name == raw.toString()) return v;
    }
    return null;
  }

  Map<String, dynamic> _toMap() => {
        'conditions': _conditions.map((e) => e.name).toList(),
        'feeding': _feeding?.name,
        'sleep': _sleep?.name,
        'priorities': _priorities.map((e) => e.name).toList(),
        'learning': _learning?.name,
        'notify': _notify.map((e) => e.name).toList(),
        'premature': _premature,
        'nicu': _nicu,
        'multiple': _multiple,
        'onboarded': _onboarded,
        'asked': _asked.map((e) => e.name).toList(),
      };

  Future<void> _save() async {
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_toMap()));
    } catch (_) {/* best-effort */}
  }

  @override
  String get cloudKey => 'family_profile';
  @override
  Object cloudData() => _toMap();
  @override
  void applyCloudData(Object data) => _apply(data as Map);
  @override
  Future<void> persistLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_toMap()));
  }
}
