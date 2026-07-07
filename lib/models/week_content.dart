// =============================================================================
//  WeekContent model (rich, bilingual)
// -----------------------------------------------------------------------------
//  Parses lib/data/weekContent.json - the richer PDF-derived schema, with every
//  text leaf as a {en, hi} LocalizedText. Null-safe throughout.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../localization/app_language.dart';

LocalizedText _loc(Object? v) => LocalizedText.fromJson(v);

List<LocalizedText> _locList(Object? v) {
  if (v is List) return v.map(_loc).toList();
  return const [];
}

String _s(Object? v, [String d = '']) => v == null ? d : v.toString();
int _i(Object? v, [int d = 0]) =>
    v is int ? v : int.tryParse(v?.toString() ?? '') ?? d;
bool _b(Object? v, [bool d = false]) => v is bool ? v : d;

@immutable
class BabySnapshot {
  const BabySnapshot({
    required this.milestone,
    required this.weekHeadline,
    required this.fruit,
    required this.length,
    required this.weight,
    required this.reveal,
  });
  final LocalizedText milestone;
  final LocalizedText weekHeadline;
  final LocalizedText fruit;
  final LocalizedText length;
  final LocalizedText weight;
  final LocalizedText reveal;

  factory BabySnapshot.fromJson(Map? j) {
    j ??= {};
    final size = (j['size'] as Map?) ?? {};
    return BabySnapshot(
      milestone: _loc(j['milestone']),
      weekHeadline: _loc(j['weekHeadline']),
      fruit: _loc(size['fruit']),
      length: _loc(size['length']),
      weight: _loc(size['weight']),
      reveal: _loc(j['reveal']),
    );
  }
}

@immutable
class BabyDevelopment {
  const BabyDevelopment({required this.whatImDoing, required this.funFact});
  final LocalizedText whatImDoing;
  final LocalizedText? funFact;
  factory BabyDevelopment.fromJson(Map? j) {
    j ??= {};
    return BabyDevelopment(
      whatImDoing: _loc(j['whatImDoing']),
      funFact: j['funFact'] == null ? null : _loc(j['funFact']),
    );
  }
}

@immutable
class MomJourney {
  const MomJourney({
    required this.physicalChanges,
    required this.emotionalState,
    required this.commonSymptoms,
    required this.selfCareTip,
    required this.reassurance,
  });
  final LocalizedText physicalChanges;
  final LocalizedText emotionalState;
  final List<LocalizedText> commonSymptoms;
  final LocalizedText selfCareTip;
  final LocalizedText reassurance;
  factory MomJourney.fromJson(Map? j) {
    j ??= {};
    return MomJourney(
      physicalChanges: _loc(j['physicalChanges']),
      emotionalState: _loc(j['emotionalState']),
      commonSymptoms: _locList(j['commonSymptoms']),
      selfCareTip: _loc(j['selfCareTip']),
      reassurance: _loc(j['reassurance']),
    );
  }
}

@immutable
class Superfood {
  const Superfood({required this.food, required this.benefit, required this.howToConsume});
  final LocalizedText food;
  final LocalizedText benefit;
  final LocalizedText howToConsume;
  factory Superfood.fromJson(Map? j) {
    j ??= {};
    return Superfood(
      food: _loc(j['food']),
      benefit: _loc(j['benefit']),
      howToConsume: _loc(j['howToConsume']),
    );
  }
}

@immutable
class Nutrition {
  const Nutrition({
    required this.nutritionTheme,
    required this.focusNutrients,
    required this.whyNow,
    required this.foods,
    required this.superfood,
    required this.mealIdea,
    required this.tip,
  });
  final LocalizedText nutritionTheme;
  final List<LocalizedText> focusNutrients;
  final LocalizedText whyNow;
  final List<LocalizedText> foods;
  final Superfood? superfood;
  final LocalizedText mealIdea;
  final LocalizedText tip;
  factory Nutrition.fromJson(Map? j) {
    j ??= {};
    return Nutrition(
      nutritionTheme: _loc(j['nutritionTheme']),
      focusNutrients: _locList(j['focusNutrients']),
      whyNow: _loc(j['whyNow']),
      foods: _locList(j['foods']),
      superfood: j['indianSuperfoodOfTheWeek'] == null
          ? null
          : Superfood.fromJson(j['indianSuperfoodOfTheWeek'] as Map?),
      mealIdea: _loc(j['mealIdea']),
      tip: _loc(j['tip']),
    );
  }
}

@immutable
class MythBuster {
  const MythBuster({required this.myth, required this.truth});
  final LocalizedText myth;
  final LocalizedText truth;
  factory MythBuster.fromJson(Map? j) {
    j ??= {};
    return MythBuster(myth: _loc(j['myth']), truth: _loc(j['truth']));
  }
}

@immutable
class ActionPlan {
  const ActionPlan({
    required this.doThisWeek,
    required this.skipThisWeek,
    required this.redFlags,
    required this.mythBuster,
  });
  final LocalizedText doThisWeek;
  final LocalizedText skipThisWeek;
  final LocalizedText redFlags;
  final MythBuster mythBuster;
  factory ActionPlan.fromJson(Map? j) {
    j ??= {};
    return ActionPlan(
      doThisWeek: _loc(j['doThisWeek']),
      skipThisWeek: _loc(j['skipThisWeek']),
      redFlags: _loc(j['redFlags']),
      mythBuster: MythBuster.fromJson(j['mythBuster'] as Map?),
    );
  }
}

@immutable
class GarbhSanskar {
  const GarbhSanskar({
    required this.raga,
    required this.affirmation,
    required this.reflectionPrompt,
    required this.spokenLine,
  });
  final String raga;
  final LocalizedText affirmation;
  final LocalizedText reflectionPrompt;
  final LocalizedText? spokenLine; // {en: translation, hi: romanised line}
  bool get hasSpokenLine => spokenLine != null;
  factory GarbhSanskar.fromJson(Map? j) {
    j ??= {};
    return GarbhSanskar(
      raga: _s(j['raga'], '-'),
      affirmation: _loc(j['affirmation']),
      reflectionPrompt: _loc(j['reflectionPrompt']),
      spokenLine: j['spokenLine'] == null ? null : _loc(j['spokenLine']),
    );
  }
}

@immutable
class ReflectAndRemember {
  const ReflectAndRemember({
    required this.reflectionPrompt,
    required this.journalPrompt,
    required this.photoPrompt,
    required this.voiceJournalEnabled,
    required this.textJournalEnabled,
    required this.cameraEnabled,
  });
  final LocalizedText reflectionPrompt;
  final LocalizedText journalPrompt;
  final LocalizedText photoPrompt;
  final bool voiceJournalEnabled;
  final bool textJournalEnabled;
  final bool cameraEnabled;
  factory ReflectAndRemember.fromJson(Map? j) {
    j ??= {};
    return ReflectAndRemember(
      reflectionPrompt: _loc(j['reflectionPrompt']),
      journalPrompt: _loc(j['journalPrompt']),
      photoPrompt: _loc(j['photoPrompt']),
      voiceJournalEnabled: _b(j['voiceJournalEnabled'], true),
      textJournalEnabled: _b(j['textJournalEnabled'], true),
      cameraEnabled: _b(j['cameraEnabled'], true),
    );
  }
}

@immutable
class PartnerCorner {
  const PartnerCorner({
    required this.whatSheMayFeel,
    required this.whatYouCanDo,
    required this.oneMission,
    required this.shareMessage,
  });
  final LocalizedText whatSheMayFeel;
  final LocalizedText whatYouCanDo;
  final LocalizedText oneMission;
  final LocalizedText shareMessage;
  factory PartnerCorner.fromJson(Map? j) {
    j ??= {};
    return PartnerCorner(
      whatSheMayFeel: _loc(j['whatSheMayFeel']),
      whatYouCanDo: _loc(j['whatYouCanDo']),
      oneMission: _loc(j['oneMission']),
      shareMessage: _loc(j['shareMessage']),
    );
  }
}

@immutable
class WeekContent {
  const WeekContent({
    required this.week,
    required this.phase,
    required this.audioEnabled,
    required this.snapshot,
    required this.development,
    required this.mom,
    required this.nutrition,
    required this.actionPlan,
    required this.garbhSanskar,
    required this.reflect,
    required this.partner,
  });

  final int week;
  final String phase;
  final bool audioEnabled;
  final BabySnapshot snapshot;
  final BabyDevelopment development;
  final MomJourney mom;
  final Nutrition nutrition;
  final ActionPlan actionPlan;
  final GarbhSanskar garbhSanskar;
  final ReflectAndRemember reflect;
  final PartnerCorner partner;

  factory WeekContent.fromJson(Map<String, dynamic> j) {
    return WeekContent(
      week: _i(j['week']),
      phase: _s(j['phase']),
      audioEnabled: _b(j['audioEnabled']),
      snapshot: BabySnapshot.fromJson(j['babySnapshot'] as Map?),
      development: BabyDevelopment.fromJson(j['babyDevelopment'] as Map?),
      mom: MomJourney.fromJson(j['momJourney'] as Map?),
      nutrition: Nutrition.fromJson(j['nutrition'] as Map?),
      actionPlan: ActionPlan.fromJson(j['actionPlan'] as Map?),
      garbhSanskar: GarbhSanskar.fromJson(j['garbhSanskar'] as Map?),
      reflect: ReflectAndRemember.fromJson(j['reflectAndRemember'] as Map?),
      partner: PartnerCorner.fromJson(j['partnerCorner'] as Map?),
    );
  }
}
