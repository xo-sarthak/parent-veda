// =============================================================================
//  What ParentVeda may use: "ask once per kind" (tools pass T0, 2026-10-25)
// -----------------------------------------------------------------------------
//  The user, 2026-10-24: the app should take care of what a tool learned,
//  "maybe not auto use it but wherever relevant can ask user if that info user
//  wants us to use or no". Their pick: ask once per kind of info, remember the
//  answer, and let it be changed in You.
//
//  One store owns every answer, so there is one rule and one settings row
//  instead of a flag inside each of thirty-odd tools. Readers (relevance,
//  reminders, the home strip) call `allows(kind)` before using a tool's data.
//  A "no" only changes ordering and suggestions: no feature is ever hidden,
//  and the tool itself keeps working exactly the same.
//
//  Sync (the user's word, 2026-10-25): the step-13 per-item merge, the same
//  shape as PpChangesStore. One item per kind, keyed by the kind's name, the
//  value the answer. Unasked is no item at all. The state row is the
//  person's own (B9 / step 14 keys rows per person), which is right: consent
//  is hers, and a co-parent answers for himself. A new phone signs in and
//  gets her answers back instead of asking again. No migration: the server
//  merge takes any store key.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'life_stage_store.dart' show LifeStage;
import 'remote/cloud_merged_store.dart';

/// A kind of information a tool collects. One per tool family; later tools
/// add theirs. ⚠️ `.name` is persisted and synced: never rename a value.
enum PpUseKind {
  feeds,
  // Tools pass, Health family (2026-10-25).
  nappies,
  changes,
  // Tools pass, Development family (2026-10-25): milestones seen and the
  // gentle check-in's answers, for Before you see the doctor.
  development,
  // Tools pass, Food family (2026-10-25): the foods a child has tried, from
  // Can my baby eat this?, for Recipes and Before you see the doctor.
  foods,
  // P1, Pregnancy look-ups and records (D4/D5, 2026-10-28): what the doctor-
  // visit summary may include. Pregnancy kinds are their own names, so a stage
  // never inherits Parenting's answer (00-MASTER T1).
  pregReadings,
  pregConditions,
  pregReports,
  pregDoctorCalls,
}

enum PpUseAnswer { unasked, yes, no }

extension PpUseKindText on PpUseKind {
  /// The row label in You.
  String get label => switch (this) {
        PpUseKind.feeds => 'Your feed log',
        PpUseKind.nappies => 'Your nappy log',
        PpUseKind.changes => 'What you tell Is my baby OK?',
        PpUseKind.development => 'Milestones and check-in answers',
        PpUseKind.foods => 'Foods tried',
        PpUseKind.pregReadings => 'Your blood pressure and sugar readings',
        PpUseKind.pregConditions => 'The conditions you follow',
        PpUseKind.pregReports => 'Your saved reports',
        PpUseKind.pregDoctorCalls => 'What your doctor said in Is it safe?',
      };

  /// The stage whose tools collect it. You lists each kind under its stage.
  /// Kept as a switch (not a name prefix) so a new kind cannot compile
  /// without saying where it belongs.
  LifeStage get stage => switch (this) {
        PpUseKind.feeds ||
        PpUseKind.nappies ||
        PpUseKind.changes ||
        PpUseKind.development ||
        PpUseKind.foods =>
          LifeStage.parenting,
        PpUseKind.pregReadings ||
        PpUseKind.pregConditions ||
        PpUseKind.pregReports ||
        PpUseKind.pregDoctorCalls =>
          LifeStage.pregnancy,
      };

  /// The toast after a yes on the ask card: what it now does, in her terms.
  String get saidYes => stage == LifeStage.pregnancy
      ? 'Thank you. $label will be in the summary you can show your doctor.'
      : 'Thank you. $label now helps choose what you see first.';

  /// The toast after a no.
  String get saidNo => stage == LifeStage.pregnancy
      ? 'Okay. $label stays in this tool and is left out of the summary.'
      : 'Okay. $label stays in this tool only.';

  /// What a yes changes, in one line. Shown on the ask card and in You.
  String get why => switch (this) {
        PpUseKind.feeds => 'We use it to put the most useful pages first, '
            'like breastfeeding or bottle pages that match how your baby feeds, '
            'and to fill in the newborn feeding check for you.',
        PpUseKind.nappies => 'We use it to fill in the newborn feeding check '
            'for you, so you only confirm the count.',
        PpUseKind.changes => 'We remember it for three weeks and move pages and '
            'activities about it up on your home.',
        PpUseKind.development => 'We add the milestones you have seen, and anything '
            'the check-in marked "not yet", to Before you see the doctor, '
            'so the questions are ready when you go.',
        PpUseKind.foods => 'Recipes can show which dishes bring a new food, and '
            'Before you see the doctor lists any reaction you noted.',
        PpUseKind.pregReadings => 'We add your latest readings to the summary '
            'you can show your doctor, beside any target they gave you.',
        PpUseKind.pregConditions => 'We list them in the summary you can show '
            'your doctor, so nothing is missed at the visit.',
        PpUseKind.pregReports => 'We list your latest reports, by name and date, '
            'in the summary you can show your doctor.',
        PpUseKind.pregDoctorCalls => 'We add what your doctor told you to the '
            'summary, so the next doctor sees it too.',
      };
}

class PpUseConsent extends ChangeNotifier with CloudMergedStore {
  PpUseConsent._();
  static final PpUseConsent instance = PpUseConsent._();

  static const _prefsKey = 'pp_use_consent';
  final Map<PpUseKind, PpUseAnswer> _answers = {};
  bool _loaded = false;

  @override
  String get cloudKey => _prefsKey;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) applyCloudItems((jsonDecode(raw) as Map).cast<String, Object?>());
    } catch (_) {/* start unasked */}
    _loaded = true;
    notifyListeners();
    try {
      await syncMergedFromCloud();
    } catch (_) {/* stay local */}
  }

  // ---- the merge's view: one item per kind ---------------------------------
  @override
  Map<String, Object?> cloudItems() => {
        for (final e in _answers.entries)
          if (e.value != PpUseAnswer.unasked) e.key.name: e.value.name,
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _answers.clear();
    for (final e in items.entries) {
      final kind = PpUseKind.values.where((k) => k.name == e.key).firstOrNull;
      final answer = PpUseAnswer.values.where((a) => a.name == e.value).firstOrNull;
      if (kind != null && answer != null) _answers[kind] = answer;
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

  // ---- reads -----------------------------------------------------------------
  PpUseAnswer answerFor(PpUseKind kind) => _answers[kind] ?? PpUseAnswer.unasked;

  /// True only after a yes. Unasked is a no until she says otherwise.
  bool allows(PpUseKind kind) => answerFor(kind) == PpUseAnswer.yes;

  bool unasked(PpUseKind kind) => answerFor(kind) == PpUseAnswer.unasked;

  // ---- writes ----------------------------------------------------------------
  /// Her answer. The mixin stamps the changed item and merges it up.
  void set(PpUseKind kind, bool yes) {
    _answers[kind] = yes ? PpUseAnswer.yes : PpUseAnswer.no;
    notifyListeners();
  }

  @visibleForTesting
  void debugReset() {
    _answers.clear();
    _loaded = false;
  }
}
