// =============================================================================
//  LandingFocus — what Today leads with, and why
// -----------------------------------------------------------------------------
//  A mother at week 9 and a mother at week 39 open the same Today and are given
//  the same card first. So does a father, and so does a parent of a newborn.
//  The content under each card is already personalised; the ORDER never was.
//
//  This store answers one question: which block goes on top today. Two inputs,
//  in this precedence:
//
//      1. what she chose, if she chose            (LandingFocus.override)
//      2. otherwise, what her phase implies       (the defaults below)
//
//  ⚠️ THE CONSTRAINT THAT MATTERS MORE THAN THE FEATURE
//
//  This changes CARD ORDER ON TODAY. Nothing else. Not the tabs, not the
//  navigation, not which screens exist, not what any other tab shows. Everyone
//  gets the same ParentVeda and can reach the same things by the same routes;
//  only the top of one list differs.
//
//  That is not a style preference, it is the rule in CLAUDE.md: "Personalisation
//  changes content, ranking and order — never structure. Everyone learns one
//  ParentVeda." A focus that hid a tab, or moved a screen, or unlocked
//  something, would be a different product per user — and then no two people
//  could help each other, no screenshot in the community would match, and no
//  support answer would be true twice. `test/landing_focus_test.dart` asserts
//  that this file exposes ordering and nothing else.
//
//  LOCAL-FIRST. The choice is a shared_preferences string, read on init and
//  applied on the first frame. An unset or unrecognised value falls back to the
//  phase default rather than throwing — an uninitialised store behaves exactly
//  like a clean install, which is the house rule.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'life_stage_store.dart';

/// WHERE THE PARENTING SPLIT FALLS, as one line to tune.
///
/// Before roughly four months a parent's questions are almost entirely "why
/// won't he sleep / feed" — the problems arrive whether or not anyone went
/// looking for them. After it, the questions turn outward and become "what
/// should we be doing together". The cards worth leading with differ, so the
/// default focus does too.
///
/// Four months is a convention, not a finding, and a baby does not read it.
/// Named here so moving it is one edit and one test, rather than a hunt.
const int kProblemToActivityMonths = 4;

/// What Today leads with.
///
/// Deliberately about the SHAPE of a parent's attention, not about features —
/// "I want to watch the baby grow" outlives any particular card, and a card
/// added next year can declare which focus it serves without this enum moving.
enum TodayFocus {
  /// Week-by-week growth: the size, the milestone, the video.
  weeklyGrowth,

  /// Her own body and head: symptoms, medicines, weight, mood.
  bodyAndMind,

  /// The birth itself: bag, plan, classes, what happens on the day.
  prepareForBirth,

  /// Nothing to do. Calm, ritual, affirmation, Garbh Sanskar.
  keepMeCalm,

  /// Newborn parenting: sleep and feeding, because they are the whole day.
  problemLed,

  /// Older baby: activities, play, development.
  activityLed,
}

extension TodayFocusCopy on TodayFocus {
  /// The persisted key. Stable — never rename without a migration, because it
  /// outlives whatever the UI happens to call it.
  String get id => switch (this) {
        TodayFocus.weeklyGrowth => 'weekly_growth',
        TodayFocus.bodyAndMind => 'body_and_mind',
        TodayFocus.prepareForBirth => 'prepare_for_birth',
        TodayFocus.keepMeCalm => 'keep_me_calm',
        TodayFocus.problemLed => 'problem_led',
        TodayFocus.activityLed => 'activity_led',
      };

  /// In the parent's words, not the product's. English only for now — this is
  /// an experiment behind a toggle, and translating a screen that may not
  /// survive it would be work spent twice.
  String get label => switch (this) {
        TodayFocus.weeklyGrowth => 'Watch baby grow',
        TodayFocus.bodyAndMind => 'Track my body',
        TodayFocus.prepareForBirth => 'Prepare for birth',
        TodayFocus.keepMeCalm => 'Just keep me calm',
        TodayFocus.problemLed => 'Sleep and feeding',
        TodayFocus.activityLed => 'Things to do together',
      };

  String get blurb => switch (this) {
        TodayFocus.weeklyGrowth => 'The week, the size, the milestone — first.',
        TodayFocus.bodyAndMind => 'Symptoms, medicines and how you are doing.',
        TodayFocus.prepareForBirth => 'The bag, the plan, and the day itself.',
        TodayFocus.keepMeCalm => 'Ritual and quiet. Nothing to tick off.',
        TodayFocus.problemLed => 'The two questions that fill a newborn day.',
        TodayFocus.activityLed => 'Play and development, at his age.',
      };

  static TodayFocus? fromId(String? id) {
    for (final f in TodayFocus.values) {
      if (f.id == id) return f;
    }
    return null;
  }
}

class LandingFocus extends ChangeNotifier {
  LandingFocus._();
  static final LandingFocus instance = LandingFocus._();

  static const _key = 'pv_landing_focus';

  TodayFocus? _override;
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// What she picked, or null if she has not been asked / chose to skip.
  TodayFocus? get override => _override;

  /// True once she has answered "what are you here for?" — so the question is
  /// asked once and then lives in Profile, rather than nagging.
  bool get hasChosen => _override != null;

  Future<void> init() async {
    if (_loaded) return;
    final p = await SharedPreferences.getInstance();
    _override = TodayFocusCopy.fromId(p.getString(_key));
    _loaded = true;
    notifyListeners();
  }

  /// Record her choice. Passing null clears it and returns her to the phase
  /// default, which is what "no strong feeling" should mean — not a third state.
  Future<void> choose(TodayFocus? f) async {
    if (_override == f) return;
    _override = f;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    if (f == null) {
      await p.remove(_key);
    } else {
      await p.setString(_key, f.id);
    }
  }

  /// The default for a phase, before any override.
  ///
  /// [babyAgeMonths] is only consulted for parenting, and only to pick the side
  /// of [kProblemToActivityMonths] she is on. A null age means we do not know
  /// yet, and the newborn answer is the safer one to be wrong about: showing
  /// sleep and feeding to the parent of a one-year-old is a mild mismatch,
  /// while showing activities to someone who has not slept is worse.
  static TodayFocus defaultFor(LifeStage? stage, {int? babyAgeMonths}) =>
      switch (stage) {
        LifeStage.tryingToConceive => TodayFocus.bodyAndMind,
        LifeStage.pregnancy => TodayFocus.weeklyGrowth,
        LifeStage.parenting =>
          (babyAgeMonths ?? 0) < kProblemToActivityMonths
              ? TodayFocus.problemLed
              : TodayFocus.activityLed,
        // No stage recorded yet. Pregnancy is the app's centre of gravity and
        // the stage a brand-new install is most likely in.
        null => TodayFocus.weeklyGrowth,
      };

  /// The focus in force: her choice if she made one, else the phase default.
  TodayFocus effective(LifeStage? stage, {int? babyAgeMonths}) =>
      _override ?? defaultFor(stage, babyAgeMonths: babyAgeMonths);

  /// The choices worth offering in a phase.
  ///
  /// Deliberately three or four. A list long enough to need scrolling turns a
  /// warm question into a form, and every option here has to actually change
  /// what she sees — an option that reorders nothing is a lie told politely.
  static List<TodayFocus> optionsFor(LifeStage? stage) => switch (stage) {
        LifeStage.tryingToConceive => const [
            TodayFocus.bodyAndMind,
            TodayFocus.keepMeCalm,
          ],
        LifeStage.parenting => const [
            TodayFocus.problemLed,
            TodayFocus.activityLed,
            TodayFocus.keepMeCalm,
          ],
        _ => const [
            TodayFocus.weeklyGrowth,
            TodayFocus.bodyAndMind,
            TodayFocus.prepareForBirth,
            TodayFocus.keepMeCalm,
          ],
      };
}
