// =============================================================================
//  The first activity — what onboarding's two skilling answers turn into
// -----------------------------------------------------------------------------
//  Onboarding V3 (2026-10-17) asks a skilling family what the child enjoys and
//  how much time they have. Until now nothing read either answer. They now
//  pick ONE activity to start with, shown on the onboarding reveal and on the
//  skilling home, from the same function so the two cannot disagree.
//
//  Deliberately small: one activity per interest, written to fit ten minutes
//  and to stretch when there is more time. It is a way in, not a curriculum;
//  the doors hold the rest (STILL-OPEN §59.2: the skilling home is a preview).
// =============================================================================

import '../../services/family_profile.dart';

/// One activity to start with.
class SkFirstActivity {
  const SkFirstActivity(this.title, this.time);
  final String title;

  /// "About 10 minutes", from her time answer.
  final String time;
}

const Map<String, String> _kFirstByInterest = {
  'stories': 'Story walk: retell a favourite book in three pictures',
  'building': 'Tallest tower from ten things in the kitchen',
  'drawing': 'Draw the map of your room',
  'numbers': 'Count-and-sort the shoe shelf',
  'talking': 'Twenty questions about animals',
  'moving': 'Hop-scotch number jumps',
};

const Map<String, String> _kTimeLabel = {
  '10': 'About 10 minutes',
  '20': 'About 20 minutes',
  'more': 'Longer, when you can',
};

/// The activity for these answers: [interests] as onboarding saves them
/// (sorted ids joined by commas) and [time] ('10', '20' or 'more'). Null when
/// no interest was picked, so the caller shows nothing rather than a guess.
SkFirstActivity? skFirstActivity(String? interests, String? time) {
  final ids = (interests ?? '').split(',').where((e) => e.isNotEmpty);
  for (final id in ids) {
    final title = _kFirstByInterest[id];
    if (title != null) {
      return SkFirstActivity(title, _kTimeLabel[time] ?? _kTimeLabel['10']!);
    }
  }
  return null;
}

/// The same, read from what she saved at onboarding.
SkFirstActivity? skFirstActivityFromProfile() {
  final p = FamilyProfileStore.instance;
  return skFirstActivity(p.otherFor('sk_interests'), p.otherFor('sk_time'));
}
