// =============================================================================
//  BirthPlanStore — what she has written down for the birth
// -----------------------------------------------------------------------------
//  One plan per phone. Answers keyed by question id, free text keyed by
//  question id, and one "talked this through with my doctor" tick per section.
//
//  ⚠️ LOCAL ONLY, AND DELIBERATELY NOT SYNCED — the same call as
//  `PvChecklistStore`, and for the same two reasons, plus one of its own:
//
//    · **It is hers, and it is sensitive.** Who she wants in the room, how she
//      feels about pain relief, a previous birth she has never mentioned to
//      her family — this is the most personal thing the stage stores, and the
//      cheapest way to keep it private is for it never to leave the phone.
//    · **There is nothing to merge.** One plan, one author. The co-parenting
//      shapes in `docs/BACKEND-PATTERNS.md` exist to reconcile two people
//      writing the same row; nobody else writes this one.
//    · **The way it leaves the phone is by her hand.** The share sheet is the
//      sync: she sends the text to her partner or her mother when she decides
//      to, and that is the right amount of sharing for a document like this.
//
//  If it is ever synced, that is a privacy decision first and plumbing second.
//
//  ⚠️ IDS, NOT LABELS. The store holds `BpChoice.id`s and `BpQuestion.id`s.
//  Storing the sentence would strand every answer the day a label is reworded,
//  and — worse — keep an answer against text that no longer exists.
//
//  ⚠️ ONE JSON BLOB, NOT A KEY PER QUESTION. Twelve questions is twelve prefs
//  keys to keep in step, and a partial write on a budget handset leaves a plan
//  that is half last week's. One document, written whole, is either the old
//  plan or the new one.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/birth_plan_data.dart';
import 'remote/cloud_merged_store.dart';
import 'remote/supabase_repo.dart';
// import 'remote/sync_registry.dart'; // kept for revert (step 13: the mixin registers)

// ⚠️ IN THE CLOUD SINCE STEP 13 (2026-10-22, sync log). It was phone-only, so a
// sign-out or a new phone lost her whole plan; the "not synced" note above is
// kept as history. Items: `c|<question>|<choice>` (true) per chosen choice,
// `t|<question>` (the text) per filled text field, `d|<section>` (true) per
// discussed section, and `updated` (epoch ms).
/// What her partner's phone found when it asked for her plan (P2 O2).
class PartnerBirthPlan {
  const PartnerBirthPlan.plan(String this.text) : state = PartnerPlanState.plan;
  const PartnerBirthPlan.empty()
      : text = null,
        state = PartnerPlanState.empty;
  const PartnerBirthPlan.notLinked()
      : text = null,
        state = PartnerPlanState.notLinked;
  const PartnerBirthPlan.unreachable()
      : text = null,
        state = PartnerPlanState.unreachable;
  final String? text;
  final PartnerPlanState state;
}

enum PartnerPlanState { plan, empty, notLinked, unreachable }

/// A copy of the plan held for an Undo. Only the store can make or read one.
class BirthPlanSnapshot {
  const BirthPlanSnapshot._(
      this.choices, this.texts, this.discussed, this.updatedAt);
  final Map<String, Set<String>> choices;
  final Map<String, String> texts;
  final Set<String> discussed;
  final DateTime? updatedAt;
}

class BirthPlanStore extends ChangeNotifier with CloudMergedStore {
  BirthPlanStore._();
  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   BirthPlanStore._() {
  //     SyncRegistry.registerReset(_resetForAccount);
  //   }
  static final BirthPlanStore instance = BirthPlanStore._();

  /// ⚠️ VERSIONED IN THE KEY. If the shape ever changes incompatibly, a new
  /// key means the old plan is left where it is rather than misread — and a
  /// migration can read `_v1` explicitly.
  static const String _key = 'birth_plan_v1';

  /// Chosen choice ids per question. A single-choice question holds at most
  /// one; the store enforces that, not the screen.
  final Map<String, Set<String>> _choices = {};

  /// Free text per text question.
  final Map<String, String> _texts = {};

  /// Sections she has marked "talked this through with my doctor".
  final Set<String> _discussed = {};

  DateTime? _updatedAt;
  bool _loaded = false;

  // ---- reads ----------------------------------------------------------------

  Set<String> choices(String questionId) =>
      Set.unmodifiable(_choices[questionId] ?? const <String>{});

  bool isChosen(String questionId, String choiceId) =>
      _choices[questionId]?.contains(choiceId) ?? false;

  String text(String questionId) => _texts[questionId] ?? '';

  bool isDiscussed(String sectionId) => _discussed.contains(sectionId);

  DateTime? get updatedAt => _updatedAt;

  /// True until she has answered anything at all.
  bool get isEmpty =>
      _choices.values.every((s) => s.isEmpty) &&
      _texts.values.every((t) => t.trim().isEmpty) &&
      _discussed.isEmpty;

  /// Whether a section has any answer in it.
  bool hasAnswers(BpSection s) => s.questions.any((q) => q.kind == BpKind.text
      ? text(q.id).trim().isNotEmpty
      : (_choices[q.id]?.isNotEmpty ?? false));

  // ---- lifecycle ------------------------------------------------------------

  /// ⚠️ IDEMPOTENT. Every screen calls this in `initState`; a second visit
  /// must not re-read prefs and notify for no change.
  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) _restore(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Start empty. A store that cannot read its cache is a store with no
      // plan yet, never a crash — local-first is absolute.
    }
    _loaded = true;
    notifyListeners();
    await syncMergedFromCloud();
  }

  // ---- writes ---------------------------------------------------------------

  /// Tap a choice. Single-choice questions replace; multi-choice toggle.
  ///
  /// ⚠️ THE KIND IS READ FROM THE DATA, NOT PASSED IN. A screen that had to
  /// say "this one is single" would be a second copy of the model, and the
  /// day they disagreed a radio group would quietly become checkboxes.
  Future<void> toggle(String questionId, String choiceId) async {
    final q = birthPlanQuestionById(questionId);
    if (q == null || q.kind == BpKind.text) return;
    final set = _choices.putIfAbsent(questionId, () => <String>{});
    if (set.contains(choiceId)) {
      set.remove(choiceId);
    } else {
      if (q.kind == BpKind.single) set.clear();
      set.add(choiceId);
    }
    _touch();
    await _save();
  }

  Future<void> setText(String questionId, String value) async {
    final q = birthPlanQuestionById(questionId);
    if (q == null || q.kind != BpKind.text) return;
    if ((_texts[questionId] ?? '') == value) return;
    _texts[questionId] = value;
    _touch();
    await _save();
  }

  Future<void> setDiscussed(String sectionId, bool value) async {
    final changed = value ? _discussed.add(sectionId) : _discussed.remove(sectionId);
    if (!changed) return;
    _touch();
    await _save();
  }

  /// The whole plan, copied, so "Start again" can be undone (P2, 2026-10-28).
  BirthPlanSnapshot snapshot() => BirthPlanSnapshot._(
        {for (final e in _choices.entries) e.key: {...e.value}},
        {..._texts},
        {..._discussed},
        _updatedAt,
      );

  /// Puts a [snapshot] back, as an edit (it syncs like any other change).
  Future<void> restore(BirthPlanSnapshot s) async {
    _choices
      ..clear()
      ..addAll({for (final e in s.choices.entries) e.key: {...e.value}});
    _texts
      ..clear()
      ..addAll(s.texts);
    _discussed
      ..clear()
      ..addAll(s.discussed);
    _updatedAt = DateTime.now();
    notifyListeners();
    await _save();
  }

  Future<void> clear() async {
    if (isEmpty) return;
    _choices.clear();
    _texts.clear();
    _discussed.clear();
    _updatedAt = null;
    notifyListeners();
    await _save();
  }

  // ---- the page she hands over --------------------------------------------

  /// The plan as plain text, in the page's own order, sections she skipped
  /// simply absent.
  ///
  /// ⚠️ TEXT, NOT A DOCUMENT. It is going into a WhatsApp message to her
  /// partner, or being read off her own screen in a corridor. A PDF would look
  /// more finished and would do neither.
  ///
  /// ⚠️ AND IT LEADS WITH THE VOICE LINE. The first thing the reader sees is
  /// that this is a preference, not a set of instructions — which is what
  /// makes a hospital team willing to read the rest.
  String summary() => summaryFrom(_choices, _texts, _discussed);

  /// The summary from a plan's three parts. One function, so her phone and
  /// her partner's (P2 O2, [partnerPlan]) can never word a plan differently.
  /// Kept for revert: the same body, inline in [summary], reading the
  /// instance through hasAnswers / isDiscussed / text / isChosen.
  static String summaryFrom(Map<String, Set<String>> choices,
      Map<String, String> texts, Set<String> discussed,
      {String heading = 'My birth plan'}) {
    String text(String id) => texts[id] ?? '';
    bool chosen(String q, String c) => choices[q]?.contains(c) ?? false;
    bool answered(BpSection s) => s.questions.any((q) => q.kind == BpKind.text
        ? text(q.id).trim().isNotEmpty
        : (choices[q.id]?.isNotEmpty ?? false));
    final out = <String>[heading, kBirthPlanVoice];
    for (final s in kBirthPlanSections) {
      if (!answered(s) && !discussed.contains(s.id)) continue;
      out.add('');
      out.add(s.title.toUpperCase());
      for (final q in s.questions) {
        if (q.kind == BpKind.text) {
          final t = text(q.id).trim();
          if (t.isNotEmpty) out.add(t);
          continue;
        }
        final picked = q.choices.where((c) => chosen(q.id, c.id));
        for (final c in picked) {
          out.add('• ${c.label}');
        }
      }
      if (discussed.contains(s.id)) {
        out.add('(Talked this through with my doctor.)');
      }
    }
    return out.join('\n');
  }

  // ---- her partner's phone (P2 O2, 2026-10-28) ------------------------------

  /// Her plan as her partner's phone reads it: never stored on his phone,
  /// never written. 0118 lets a paired partner read this one `user_state` row.
  ///
  /// The row is pv_state_merge's per-item book, `{key: {v, t, d?}}`; a removed
  /// item (`d`) is left out, exactly as her own phone reads it.
  static Future<PartnerBirthPlan> partnerPlan() async {
    try {
      final partnerId = await SupabaseRepo.myPartnerId();
      if (partnerId == null) return const PartnerBirthPlan.notLinked();
      final data = await SupabaseRepo.loadPartnerState(partnerId, 'birth_plan');
      final items = <String, Object?>{};
      if (data is Map) {
        for (final e in data.entries) {
          if (MergedItems.removedOf(e.value)) continue;
          final v = e.value;
          if (v is Map) items['${e.key}'] = v['v'];
        }
      }
      final p = parseItems(items);
      if (p.choices.values.every((s) => s.isEmpty) &&
          p.texts.values.every((t) => t.trim().isEmpty) &&
          p.discussed.isEmpty) {
        return const PartnerBirthPlan.empty();
      }
      return PartnerBirthPlan.plan(
          summaryFrom(p.choices, p.texts, p.discussed, heading: 'Her birth plan'));
    } catch (_) {
      return const PartnerBirthPlan.unreachable();
    }
  }

  /// The plan's three parts from its cloud items. [applyCloudItems] reads the
  /// same keys into the singleton.
  static ({
    Map<String, Set<String>> choices,
    Map<String, String> texts,
    Set<String> discussed,
  }) parseItems(Map<String, Object?> items) {
    final choices = <String, Set<String>>{};
    final texts = <String, String>{};
    final discussed = <String>{};
    for (final e in items.entries) {
      final k = e.key;
      if (k.startsWith('c|')) {
        final rest = k.substring(2);
        final bar = rest.indexOf('|');
        if (bar <= 0) continue;
        choices
            .putIfAbsent(rest.substring(0, bar), () => <String>{})
            .add(rest.substring(bar + 1));
      } else if (k.startsWith('t|')) {
        final v = e.value;
        if (v is String) texts[k.substring(2)] = v;
      } else if (k.startsWith('d|')) {
        discussed.add(k.substring(2));
      }
    }
    return (choices: choices, texts: texts, discussed: discussed);
  }

  // ---- persistence ----------------------------------------------------------

  void _touch() {
    _updatedAt = DateTime.now();
    notifyListeners();
  }

  Map<String, dynamic> _snapshot() => {
        'choices': {
          for (final e in _choices.entries)
            if (e.value.isNotEmpty) e.key: e.value.toList(),
        },
        'texts': {
          for (final e in _texts.entries)
            if (e.value.trim().isNotEmpty) e.key: e.value,
        },
        'discussed': _discussed.toList(),
        'updatedAt': _updatedAt?.toIso8601String(),
      };

  void _restore(Map<String, dynamic> m) {
    _choices.clear();
    _texts.clear();
    _discussed.clear();
    final c = m['choices'];
    if (c is Map) {
      for (final e in c.entries) {
        final v = e.value;
        if (v is List) {
          _choices[e.key as String] = {for (final x in v) x as String};
        }
      }
    }
    final t = m['texts'];
    if (t is Map) {
      for (final e in t.entries) {
        _texts[e.key as String] = e.value as String;
      }
    }
    final d = m['discussed'];
    if (d is List) _discussed.addAll(d.cast<String>());
    final u = m['updatedAt'];
    if (u is String) _updatedAt = DateTime.tryParse(u);
  }

  /// ⚠️ NOTIFY FIRST, WRITE AFTER — the same rule as every local store here.
  /// The answer is already the truth in memory; a chip that waits for a disk
  /// write before it moves reads as a laggy app.
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_snapshot()));
    } catch (_) {
      // Fire and forget. A failed write loses the plan on next launch, which
      // is a far smaller cost than a plan screen that can throw.
    }
  }

  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  //   // are wiped, the singleton was not.
  //   // clear() also writes prefs, so this one touches memory only.
  //   void _resetForAccount() {
  //     _choices.clear();
  //     _texts.clear();
  //     _discussed.clear();
  //     _updatedAt = null;
  //     _loaded = false;
  //     notifyListeners();
  //   }

  // ---- the cloud (step 13) --------------------------------------------------

  @override
  String get cloudKey => 'birth_plan';

  /// Text fields notify on every edit; gather a burst into one merge.
  @override
  Duration get cloudPushDebounce => const Duration(seconds: 2);

  @override
  Map<String, Object?> cloudItems() => {
        for (final e in _choices.entries)
          for (final c in e.value) 'c|${e.key}|$c': true,
        for (final e in _texts.entries)
          if (e.value.trim().isNotEmpty) 't|${e.key}': e.value,
        for (final id in _discussed) 'd|$id': true,
        if (_updatedAt != null) 'updated': _updatedAt!.millisecondsSinceEpoch,
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _choices.clear();
    _texts.clear();
    _discussed.clear();
    _updatedAt = null;
    for (final e in items.entries) {
      final k = e.key;
      if (k == 'updated') {
        final v = e.value;
        if (v is num) {
          _updatedAt = DateTime.fromMillisecondsSinceEpoch(v.toInt());
        }
      } else if (k.startsWith('c|')) {
        final rest = k.substring(2);
        final bar = rest.indexOf('|');
        if (bar <= 0) continue;
        _choices
            .putIfAbsent(rest.substring(0, bar), () => <String>{})
            .add(rest.substring(bar + 1));
      } else if (k.startsWith('t|')) {
        final v = e.value;
        if (v is String) _texts[k.substring(2)] = v;
      } else if (k.startsWith('d|')) {
        _discussed.add(k.substring(2));
      }
    }
    _loaded = true;
  }

  @override
  Future<void> persistLocalCache() => _save();

  /// Test seam: load from a map without prefs.
  @visibleForTesting
  void debugRestore(Map<String, dynamic> m) {
    _restore(m);
    _loaded = true;
    notifyListeners();
  }

  @visibleForTesting
  Map<String, dynamic> debugSnapshot() => _snapshot();
}
