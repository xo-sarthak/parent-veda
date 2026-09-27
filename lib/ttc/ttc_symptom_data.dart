// =============================================================================
//  What she can log in a day, and how it is grouped
// -----------------------------------------------------------------------------
//  ⚠️ THIS REPLACES SIX SLIDERS WITH NINETY CHIPS, AND THAT IS THE POINT.
//
//  The old Symptom Companion asked six questions — cramping, bloating, breast
//  tenderness, tiredness, headache, mucus — each on a five-point scale, and
//  then stopped. The complaint about it was exact and correct: *"I know what
//  I'm feeling. How does that make sense?"*
//
//  A scale asks her to grade a feeling she has already had. A chip asks her to
//  recognise one, which is a much smaller act, and it lets the app carry a
//  vocabulary she does not have to supply. Ninety things she might tap is not
//  clutter — it is the difference between a form and a place to say what kind
//  of day it was.
//
//  ---------------------------------------------------------------------------
//  ⚠️ ICONS, AND WHY THEY ARE NOT EMOJI
//  ---------------------------------------------------------------------------
//
//  The reference app draws a small coloured illustration on every chip, and
//  that is most of why its logger is pleasant rather than clinical. CLAUDE.md
//  bans decorative emoji and mandates line icons — and the two are not actually
//  in conflict here, because these icons are not decoration. They are how you
//  find "bloating" in a group of twelve without reading twelve words.
//
//  So: a line icon and a hue per chip, drawn from the same controlled wheel as
//  everything else. Identifying, not ornamental. No 🤢.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT THIS IS FOR, WHICH IS NOT DIAGNOSIS
//  ---------------------------------------------------------------------------
//
//  Nothing here is interpreted. The app records what she noticed, shows it back
//  to her across the cycle, and takes it no further — CLAUDE.md, "never a
//  diagnosis". The value is that three cycles of this turns *"I think this
//  happens sometimes"* into something she can put in front of a doctor, and
//  that is the only claim the feature makes.
//
//  ⚠️ AND IT IS EXPLICITLY NOT A PREGNANCY TEST. Early pregnancy and an
//  approaching period produce the same symptoms because they are driven by the
//  same hormone. Any feature that invites symptom-spotting in the two-week wait
//  is selling false hope; that warning survives from the old screen and belongs
//  on the new one.
// =============================================================================

import 'package:flutter/material.dart';

/// One thing she can tap.
class TtcSymptom {
  const TtcSymptom({
    required this.id,
    required this.label,
    required this.icon,
    required this.hue,
    this.emoji,
  });

  /// ⚠️ AN IDENTITY. Persisted through `TtcLogStore` as the field name and
  /// synced, so renaming one orphans every day it was ever tapped. The label is
  /// free to change; this is not.
  final String id;

  final String label;
  final IconData icon;

  /// ⚠️ EMOJI ON FEELINGS AND DISCHARGE ONLY, AND THE EXCEPTION IS ARGUED.
  ///
  /// CLAUDE.md bans decorative emoji and it is right to — a smiley beside a
  /// section heading is noise. But a mood is the one thing on this screen that
  /// an emoji is not decorating: it IS the content. A face reads as "calm"
  /// faster than any line drawing of a face, needs no translation, and renders
  /// identically for every user on every device, which is exactly the
  /// consistency the request asked for.
  ///
  /// Null everywhere else, and [icon] is the fallback. If this list ever grows
  /// past feelings and discharge, that is the moment to stop.
  final String? emoji;

  /// Position on the controlled-pastel wheel. Inherited from the group unless
  /// a chip needs to stand out inside it.
  final double hue;
}

/// A titled set of chips.
class TtcSymptomGroup {
  const TtcSymptomGroup({
    required this.id,
    required this.title,
    required this.hue,
    required this.symptoms,
    this.single = false,
    this.note,
  });

  final String id;
  final String title;
  final double hue;
  final List<TtcSymptom> symptoms;

  /// ⚠️ SINGLE-CHOICE GROUPS EXIST AND MULTI-CHOICE ONES ARE THE DEFAULT.
  /// "Did the test say positive or negative" has one answer; "what did you feel
  /// today" has as many as it has. Getting this backwards is how a logger ends
  /// up refusing to record a day that was genuinely cramping AND tired.
  final bool single;

  /// One quiet line under the title where the group needs framing.
  final String? note;
}

/// ⚠️ AN IDENTITY, LIKE EVERY OTHER GROUP ID. Named because three files now
/// have to agree that feelings are handled differently from the rest, and a
/// bare `'feeling'` typed in three places is a rename waiting to strand one of
/// them.
const String kTtcFeelingGroup = 'feeling';

/// The groups that render as category cards — everything except feelings.
///
/// ⚠️ FEELINGS ARE NOT A CATEGORY ANY MORE, they are the top of the logging
/// screen. They used to be both: a four-mood shortcut row AND a card below with
/// the same eight moods under a near-identical heading, which is a redundancy
/// nobody could resolve by looking at it. The row now holds all eight and the
/// card is gone.
///
/// This exists so the logger and the edit-categories screen cannot disagree
/// about that. Offering "hide Feelings" on a screen where feelings are no
/// longer a card would be a switch that does nothing — the specific failure
/// this stage keeps testing for.
List<TtcSymptomGroup> get kTtcCategoryGroups =>
    [for (final g in kTtcSymptomGroups) if (g.id != kTtcFeelingGroup) g];

/// Everything loggable in a day, in the order it is shown.
///
/// ⚠️ ORDER IS BY HOW OFTEN IT IS TAPPED, NOT BY ANATOMY. Mood and symptoms
/// come before discharge and digestion because they are what most people open
/// this screen to record. A logger sorted by body system is sorted for the
/// person who built it.
const List<TtcSymptomGroup> kTtcSymptomGroups = [
  TtcSymptomGroup(
    id: 'feeling',
    title: 'How are you feeling?',
    hue: 42,
    symptoms: [
      TtcSymptom(id: 'calm', emoji: '😌', label: 'Calm', icon: Icons.spa_outlined, hue: 160),
      TtcSymptom(
          id: 'happy', emoji: '🙂', label: 'Happy', icon: Icons.wb_sunny_outlined, hue: 42),
      TtcSymptom(
          id: 'energetic', emoji: '⚡',
          label: 'Energetic',
          icon: Icons.bolt_outlined,
          hue: 42),
      TtcSymptom(
          id: 'low', emoji: '😔', label: 'Low', icon: Icons.cloud_outlined, hue: 206),
      TtcSymptom(
          id: 'anxious', emoji: '😰',
          label: 'Anxious',
          icon: Icons.blur_on_rounded,
          hue: 268),
      TtcSymptom(
          id: 'irritated', emoji: '😤',
          label: 'Irritated',
          icon: Icons.flash_on_outlined,
          hue: 344),
      TtcSymptom(
          id: 'mood_swings', emoji: '🎭',
          label: 'Mood swings',
          icon: Icons.swap_vert_rounded,
          hue: 268),
      TtcSymptom(
          id: 'tearful', emoji: '🥲',
          label: 'Tearful',
          icon: Icons.water_drop_outlined,
          hue: 206),
      // ⚠️ FOUR FEELINGS THAT BELONG TO TRYING (gap analysis, Behind ›
      // Logging, 2026-09-26). The first eight are feelings anyone has; these
      // are the ones a month of trying brings. New ids, appended, never a
      // rename of an old one. No emoji: they draw faces like the rest.
      //
      // The last three, logged three days running, bring up one gentle line
      // in the logger. See `kTtcHardThoughtIds` in `ttc_logging_extras.dart`.
      TtcSymptom(
          id: 'hopeful',
          label: 'Hopeful',
          icon: Icons.wb_twilight_rounded,
          hue: 160),
      TtcSymptom(
          id: 'guilty',
          label: 'Guilty',
          icon: Icons.mood_bad_outlined,
          hue: 268),
      TtcSymptom(
          id: 'cant_stop_thinking',
          label: "Can't stop thinking about it",
          icon: Icons.loop_rounded,
          hue: 268),
      TtcSymptom(
          id: 'hard_on_myself',
          label: 'Hard on myself',
          icon: Icons.sentiment_dissatisfied_outlined,
          hue: 344),
    ],
  ),

  TtcSymptomGroup(
    id: 'body',
    title: 'Your body today',
    hue: 344,
    symptoms: [
      TtcSymptom(
          id: 'all_fine',
          label: "Everything's fine",
          icon: Icons.check_circle_outline_rounded,
          hue: 160),
      TtcSymptom(
          id: 'cramping',
          label: 'Cramping',
          icon: Icons.waves_rounded,
          hue: 344),
      TtcSymptom(
          id: 'breast',
          label: 'Tender breasts',
          icon: Icons.favorite_border_rounded,
          hue: 344),
      TtcSymptom(
          id: 'headache',
          label: 'Headache',
          icon: Icons.psychology_outlined,
          hue: 268),
      TtcSymptom(
          id: 'fatigue',
          label: 'Tired',
          icon: Icons.bedtime_outlined,
          hue: 206),
      TtcSymptom(
          id: 'backache',
          label: 'Backache',
          icon: Icons.accessibility_new_rounded,
          hue: 42),
      TtcSymptom(
          id: 'bloating',
          label: 'Bloating',
          icon: Icons.bubble_chart_outlined,
          hue: 104),
      TtcSymptom(
          id: 'acne', label: 'Acne', icon: Icons.face_retouching_natural,
          hue: 42),
      TtcSymptom(
          id: 'cravings',
          label: 'Cravings',
          icon: Icons.cookie_outlined,
          hue: 42),
      TtcSymptom(
          id: 'insomnia',
          label: "Couldn't sleep",
          icon: Icons.nightlight_outlined,
          hue: 268),
      TtcSymptom(
          id: 'nausea',
          label: 'Nausea',
          icon: Icons.sick_outlined,
          hue: 104),
      TtcSymptom(
          id: 'pelvic_pain',
          label: 'Pelvic pain',
          icon: Icons.adjust_rounded,
          hue: 344),
    ],
  ),

  TtcSymptomGroup(
    id: 'discharge',
    title: 'Discharge',
    hue: 206,
    note: 'The clearest free sign of your fertile days. Clear, wet and '
        'stretchy means your most fertile days are close.',
    symptoms: [
      TtcSymptom(
          id: 'disch_none',
          label: 'None',
          icon: Icons.remove_rounded,
          hue: 206),
      TtcSymptom(
          id: 'disch_eggwhite',
          label: 'Egg white',
          icon: Icons.egg_outlined,
          hue: 160),
      TtcSymptom(
          id: 'disch_watery',
          label: 'Watery',
          icon: Icons.opacity_rounded,
          hue: 206),
      TtcSymptom(
          id: 'disch_creamy',
          label: 'Creamy',
          icon: Icons.blur_circular_rounded,
          hue: 42),
      TtcSymptom(
          id: 'disch_sticky',
          label: 'Sticky',
          icon: Icons.grain_rounded,
          hue: 42),
      TtcSymptom(
          id: 'disch_spotting',
          label: 'Spotting',
          icon: Icons.circle_rounded,
          hue: 344),
      TtcSymptom(
          id: 'disch_unusual',
          label: 'Unusual',
          icon: Icons.help_outline_rounded,
          hue: 268),
    ],
  ),

  TtcSymptomGroup(
    id: 'sex',
    title: 'Sex',
    hue: 344,
    symptoms: [
      TtcSymptom(
          id: 'sex_none',
          label: 'None',
          icon: Icons.remove_rounded,
          hue: 206),
      TtcSymptom(
          id: 'sex_unprotected',
          label: 'Unprotected',
          icon: Icons.favorite_rounded,
          hue: 344),
      TtcSymptom(
          id: 'sex_protected',
          label: 'Protected',
          icon: Icons.shield_outlined,
          hue: 206),
      TtcSymptom(
          id: 'sex_high_drive',
          label: 'High drive',
          icon: Icons.trending_up_rounded,
          hue: 344),
      TtcSymptom(
          id: 'sex_low_drive',
          label: 'Low drive',
          icon: Icons.trending_down_rounded,
          hue: 206),
    ],
  ),

  // ⚠️ SINGLE-CHOICE. A test said one thing.
  TtcSymptomGroup(
    id: 'ovulation_test',
    title: 'Ovulation test',
    hue: 160,
    single: true,
    symptoms: [
      TtcSymptom(
          id: 'ov_none',
          label: "Didn't test",
          icon: Icons.remove_rounded,
          hue: 206),
      TtcSymptom(
          id: 'ov_positive',
          label: 'Positive',
          icon: Icons.add_circle_outline_rounded,
          hue: 160),
      TtcSymptom(
          id: 'ov_negative',
          label: 'Negative',
          icon: Icons.remove_circle_outline_rounded,
          hue: 206),
    ],
  ),

  TtcSymptomGroup(
    id: 'pregnancy_test',
    title: 'Pregnancy test',
    hue: 268,
    single: true,
    note: "We note it and never read into it. If it's positive, please "
        'confirm it with a doctor.',
    symptoms: [
      TtcSymptom(
          id: 'pt_none',
          label: "Didn't test",
          icon: Icons.remove_rounded,
          hue: 206),
      TtcSymptom(
          id: 'pt_positive',
          label: 'Positive',
          icon: Icons.add_circle_outline_rounded,
          hue: 160),
      TtcSymptom(
          id: 'pt_negative',
          label: 'Negative',
          icon: Icons.remove_circle_outline_rounded,
          hue: 206),
      TtcSymptom(
          id: 'pt_faint',
          label: 'Faint line',
          icon: Icons.more_horiz_rounded,
          hue: 42),
    ],
  ),

  TtcSymptomGroup(
    id: 'life',
    title: 'The rest of the day',
    hue: 104,
    symptoms: [
      TtcSymptom(
          id: 'exercise',
          label: 'Exercised',
          icon: Icons.directions_run_rounded,
          hue: 160),
      TtcSymptom(
          id: 'yoga', label: 'Yoga', icon: Icons.self_improvement_rounded,
          hue: 160),
      TtcSymptom(
          id: 'walk', label: 'Walked', icon: Icons.directions_walk_rounded,
          hue: 104),
      TtcSymptom(
          id: 'stress', label: 'Stressful day', icon: Icons.bolt_rounded,
          hue: 344),
      TtcSymptom(
          id: 'travel', label: 'Travelled', icon: Icons.flight_takeoff_rounded,
          hue: 206),
      TtcSymptom(
          id: 'alcohol', label: 'Alcohol', icon: Icons.local_bar_outlined,
          hue: 42),
      TtcSymptom(
          id: 'illness', label: 'Unwell', icon: Icons.thermostat_rounded,
          hue: 344),
      TtcSymptom(
          id: 'meditation',
          label: 'Meditated',
          icon: Icons.spa_rounded,
          hue: 268),
      // Added 2026-09-26 (gap analysis, Behind › Logging). New ids.
      TtcSymptom(
          id: 'kegels',
          label: 'Kegels',
          icon: Icons.compress_rounded,
          hue: 344),
      TtcSymptom(
          id: 'breathing',
          label: 'Breathing',
          icon: Icons.air_rounded,
          hue: 206),
    ],
  ),
];

/// The tracker id every chip is stored under.
///
/// ⚠️ THE SAME ID THE OLD SCREEN USED, deliberately. `TtcLogStore` keys on
/// `tracker/field/day`, the calendar's `ttcFactsFor` already asks it which days
/// have anything under `symptoms`, and the day-strip on the V3 header reads
/// that. Inventing a new tracker id would have made every one of those go quiet
/// for the new logger while continuing to work for the old one.
const String kTtcSymptomTracker = 'symptoms';

/// Look up a chip by its persisted id.
TtcSymptom? ttcSymptomById(String id) {
  for (final g in kTtcSymptomGroups) {
    for (final s in g.symptoms) {
      if (s.id == id) return s;
    }
  }
  return null;
}

/// The group a chip belongs to.
TtcSymptomGroup? ttcGroupOf(String symptomId) {
  for (final g in kTtcSymptomGroups) {
    if (g.symptoms.any((s) => s.id == symptomId)) return g;
  }
  return null;
}
