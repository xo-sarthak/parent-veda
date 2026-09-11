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

class BirthPlanStore extends ChangeNotifier {
  BirthPlanStore._();
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
  String summary() {
    final out = <String>['My birth plan', kBirthPlanVoice];
    for (final s in kBirthPlanSections) {
      if (!hasAnswers(s) && !isDiscussed(s.id)) continue;
      out.add('');
      out.add(s.title.toUpperCase());
      for (final q in s.questions) {
        if (q.kind == BpKind.text) {
          final t = text(q.id).trim();
          if (t.isNotEmpty) out.add(t);
          continue;
        }
        final picked = q.choices.where((c) => isChosen(q.id, c.id));
        for (final c in picked) {
          out.add('• ${c.label}');
        }
      }
      if (isDiscussed(s.id)) out.add('(Talked this through with my doctor.)');
    }
    return out.join('\n');
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
