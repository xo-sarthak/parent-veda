// =============================================================================
//  The Mind & body practice library — twelve short practices, defined ONCE
// -----------------------------------------------------------------------------
//  Content from `ParentVeda_Mindbody_twelve_practice_cards.pdf`, 30 Aug 2026.
//  Every step, duration and "skip it if" below is the brief's own wording.
//
//  ⚠️ THE BRIEF'S SHARPEST INSTRUCTION IS ABOUT DUPLICATION, NOT ABOUT CONTENT:
//  *"These twelve practice cards exist ONCE, here. Today references them; do
//  not create a second copy on Today."*
//
//  That is the whole reason this is a data file rather than tiles typed into
//  the focus page. A card typed into "The practice" tab and a card typed into
//  Today would look identical on the day they were written and would disagree
//  within a month — and the disagreement is invisible, because nobody has both
//  screens open at once.
//
//  ⚠️ THE DURATIONS ARE THE BRIEF'S NOW. An earlier version of this file filled
//  six of the twelve from judgement, because the first brief only timed five of
//  them, and said so in `docs/STILL-OPEN.md` §28.2. All twelve are stated here,
//  and four of my six guesses were wrong — the breathing practices are ONE
//  minute, not three or four. Worth noticing: every guess erred long, because a
//  three-minute practice feels more substantial to write than a one-minute one.
//  The brief is shorter on purpose; a minute is what somebody will actually do.
//
//  ⚠️ WHAT THIS FILE MUST NEVER GROW. Absolute, and two of them are clinical:
//    · No claim that any of this makes conception happen.
//    · No claim about a baby's intelligence or nature.
//    · No detox, cleanses, herbs, or astrology.
//    · Gentle only — nothing that needs a teacher watching.
//  `test/ttc_mind_body_test.dart` scans this file's own strings for the first
//  three, because a rule kept only in a comment is a rule until someone is in a
//  hurry.
// =============================================================================

import '../models/breath_pattern.dart';

/// Which library a practice belongs to. Today picks one card from each.
enum TtcPracticeKind { move, breathe }

// -----------------------------------------------------------------------------
//  How a card animates
// -----------------------------------------------------------------------------
//  ⚠️ THE BRIEF DRAWS A LINE THROUGH THE TWELVE AND IT IS AN HONEST ONE: *"the
//  six breathing cards can be built completely in code, today, with no artwork.
//  The six movement cards need drawn figure animation, which Claude Code cannot
//  produce."*
//
//  So this union has both halves. The breathing specs are complete and their
//  players are real; the movement spec carries an asset path that is null today
//  and a commissioning note that says exactly what to draw. A movement card
//  works with no animation at all — steps, timer and safety note are the
//  fallback and are always on screen.

sealed class TtcPracticeAnim {
  const TtcPracticeAnim();

  /// How long the whole session runs, in seconds.
  int get seconds;
}

/// The one component the brief asks to be built once and configured per card.
///
/// ⚠️ `hold` AND `holdEmpty` ARE SECONDS, AND ZERO MEANS NO PAUSE — not a pause
/// of length zero that the player has to special-case. Box breathing is the
/// only card that uses both.
final class TtcBreathAnim extends TtcPracticeAnim {
  const TtcBreathAnim({
    required this.inhale,
    required this.exhale,
    required this.seconds,
    this.hold = 0,
    this.holdEmpty = 0,
    this.square = false,
    this.nostrils = false,
    this.countTo,
    this.twoMarkers = false,
  });

  final int inhale;
  final int hold;
  final int exhale;
  final int holdEmpty;

  @override
  final int seconds;

  /// ⚠️ BOX BREATHING TRACES A SQUARE, AND THE BRIEF IS EXPLICIT: *"This one is
  /// naturally a square, not a circle."* Four equal phases around four equal
  /// sides is the shape teaching the timing, which is the whole reason the
  /// practice is called what it is.
  final bool square;

  /// Alternate nostril: show which side is closed.
  final bool nostrils;

  /// Ten slow breaths together counts 1..10 rather than running a clock.
  final int? countTo;

  /// Two markers on the ring, because the practice is for both of them.
  final bool twoMarkers;

  int get cycle => inhale + hold + exhale + holdEmpty;

  /// The same cycle as the shared circle reads it. See `BreathPattern`.
  BreathPattern toBreathPattern() => BreathPattern([
        BreathStep('Breathe in', inhale, BreathKind.expand),
        if (hold > 0) BreathStep('Hold', hold, BreathKind.hold),
        BreathStep('Breathe out', exhale, BreathKind.contract),
        if (holdEmpty > 0)
          BreathStep('Hold empty', holdEmpty, BreathKind.holdEmpty),
      ]);
}

/// Attention moving down the body. No breathing circle.
final class TtcBodyScanAnim extends TtcPracticeAnim {
  const TtcBodyScanAnim({required this.seconds});
  @override
  final int seconds;
}

/// A pulsing light and a ring. The user brings their own audio.
///
/// ⚠️ WE BUNDLE NO SOUND, AND THE BRIEF SAYS SO TWICE. "Soft music, a raag, a
/// chant, or whatever settles you" is a personal and often religious choice,
/// and shipping one would be us choosing it for her.
final class TtcListenAnim extends TtcPracticeAnim {
  const TtcListenAnim({required this.seconds});
  @override
  final int seconds;
}

/// A drawn figure, when one exists.
final class TtcFigureAnim extends TtcPracticeAnim {
  const TtcFigureAnim({
    required this.seconds,
    required this.brief,
    this.assetPath,
    this.sides = false,
  });

  @override
  final int seconds;

  /// ⚠️ READ FROM DATA SO A FILE CAN BE DROPPED IN WITHOUT A CODE CHANGE. The
  /// brief asks for exactly this. Null today for all six; the player renders
  /// the step list and a placeholder, which is the state it must work in
  /// anyway for anyone who cannot see an animation.
  final String? assetPath;

  /// The commissioning note — loop length and view angle, in the brief's own
  /// words. It is carried in the data rather than a spreadsheet so that the
  /// file that needs the asset is the file that describes it.
  final String brief;

  /// Left and right alternate, so the step list has to say which side is live.
  final bool sides;
}

/// A clock and nothing else.
final class TtcTimerAnim extends TtcPracticeAnim {
  const TtcTimerAnim({required this.seconds});
  @override
  final int seconds;
}

class TtcPractice {
  const TtcPractice({
    required this.id,
    required this.kind,
    required this.title,
    required this.duration,
    required this.setting,
    required this.blurb,
    required this.steps,
    required this.skipIf,
    required this.anim,
  });

  final String id;
  final TtcPracticeKind kind;
  final String title;

  /// "About 3 minutes" — the brief's own phrasing, which hedges on purpose.
  final String duration;

  /// "Standing or sitting", "On the floor", "Next to a wall".
  final String setting;

  /// Two lines at most: what it is for, and when it suits.
  final String blurb;

  final List<String> steps;

  /// ⚠️ NEVER EMPTY, AND SEVERAL OF THEM SAY "Nothing to skip". The brief writes
  /// that line out rather than omitting the section, and it is right to: a card
  /// with no safety note reads as a card nobody checked, and the reader cannot
  /// tell that from a card that is genuinely safe for everyone.
  final String skipIf;

  final TtcPracticeAnim anim;
}

/// The one safety line, shown once on the practice tab.
///
/// ⚠️ ONCE, NOT PER CARD — the brief puts this in its heading: *"Safety line
/// shown once on the practice tab, not on every card."* An earlier build put it
/// on all twelve, which is the reflex, and it is wrong for a reason worth
/// keeping: a warning repeated on every card stops being read by the third one,
/// and the cards that genuinely need a specific caution already carry their own
/// `skipIf`.
const String kTtcPracticeSafety =
    'Keep all of this gentle. Stop if anything hurts, if you feel dizzy, or if '
    'you feel breathless. None of this should be hard work. If you have a '
    'health condition, a recent surgery, or your doctor has told you to limit '
    'activity, check with them first.';

// -----------------------------------------------------------------------------
//  Move — gentle only, and every one of these needs drawn artwork
// -----------------------------------------------------------------------------
const List<TtcPractice> _move = [
  TtcPractice(
    id: 'mb_loosen',
    kind: TtcPracticeKind.move,
    title: 'Loosen-up: neck, shoulders, side bends',
    duration: 'About 3 minutes',
    setting: 'Standing or sitting',
    blurb: 'A short loosen-up for a stiff body. Good first thing in the '
        'morning, or after a long day at a desk.',
    steps: [
      'Sit or stand tall. Let your shoulders drop away from your ears.',
      'Slowly drop your chin towards your chest, then lift it back to the '
          'middle. Do this five times, slowly.',
      'Slowly turn your head to the right, back to the middle, then to the '
          'left. Five times each side.',
      'Roll your shoulders backwards five times, then forwards five times.',
      'Raise your right arm overhead and lean gently to the left. Hold for '
          'three slow breaths. Repeat on the other side.',
      'Come back to the middle and take three normal breaths.',
    ],
    skipIf: 'Skip the neck part if you have neck pain or a neck injury. Never '
        'roll your head in a full circle.',
    anim: TtcFigureAnim(
      seconds: 180,
      brief: 'Looping figure, front view, doing the sequence once through. '
          'About 30 seconds, then loops. Step text changes as it goes.',
    ),
  ),
  TtcPractice(
    id: 'mb_catcow',
    kind: TtcPracticeKind.move,
    title: 'Cat and cow, then child\'s pose',
    duration: 'About 3 minutes',
    setting: 'On the floor, on a mat or a folded blanket',
    blurb: 'A gentle way to move your back. It helps if you sit all day, and '
        'it calms the mind because you move with your breath.',
    steps: [
      'Come onto your hands and knees. Hands under your shoulders, knees under '
          'your hips.',
      'Breathe in and let your belly drop, chest lifting, looking slightly up. '
          "That's cow.",
      'Breathe out and round your back upwards, chin towards your chest. '
          "That's cat.",
      'Move between the two with your breath, slowly, eight times.',
      'Then sit back onto your heels, arms stretched forward, forehead down. '
          "That's child's pose.",
      "Stay in child's pose for one minute, breathing normally.",
    ],
    skipIf: 'Put a cushion under your knees if they hurt. Skip this if you '
        'have a wrist or knee injury.',
    anim: TtcFigureAnim(
      seconds: 180,
      brief: 'Side view, looping between cow and cat in time with a breath '
          'cue, then settling into child\'s pose. Loops.',
    ),
  ),
  TtcPractice(
    id: 'mb_hips',
    kind: TtcPracticeKind.move,
    title: 'Hip openers: butterfly and slow lunge',
    duration: 'About 4 minutes',
    setting: 'On the floor',
    blurb: 'Opens up tight hips, which most of us get from sitting. It feels '
        'calming, not like hard work.',
    steps: [
      'Sit with the soles of your feet together, knees falling out to the '
          "sides. That's butterfly.",
      "Hold your feet, sit tall, and let your knees relax down. Don't push "
          'them.',
      'Stay for one minute, breathing slowly.',
      'Then kneel, and step your right foot forward so the knee is over the '
          'ankle.',
      'Gently sink your hips forward and down. Hold for five slow breaths.',
      'Swap sides and repeat.',
    ],
    skipIf: 'Never push or bounce your knees down in butterfly. Skip the lunge '
        'if you have a knee problem.',
    anim: TtcFigureAnim(
      seconds: 240,
      sides: true,
      brief: 'Two-part loop: butterfly held with a slow breath cue, then the '
          'lunge on each side. Side view.',
    ),
  ),
  TtcPractice(
    id: 'mb_walk',
    kind: TtcPracticeKind.move,
    title: 'A ten-minute walk',
    duration: '10 minutes',
    setting: 'Outdoors if you can',
    blurb: 'The easiest one, and it counts as your full movement for the day. '
        "It's nicer outdoors and together, but any walk works.",
    steps: [
      'Walk at a comfortable pace, slow enough that you could still talk.',
      "If you're together, keep your phones in your pockets.",
      'Daylight helps you sleep later, so earlier in the day is better if you '
          'can choose.',
      "That's it. There's no distance to reach.",
    ],
    skipIf: 'Nothing to skip. Slow down if you feel breathless.',
    // ⚠️ NO FIGURE, ON THE BRIEF'S OWN INSTRUCTION. Ten minutes of walking does
    // not need a diagram, and drawing one would be the most expensive asset on
    // the list doing the least work.
    anim: TtcTimerAnim(seconds: 600),
  ),
  TtcPractice(
    id: 'mb_legsup',
    kind: TtcPracticeKind.move,
    title: 'Legs up the wall',
    duration: '3 minutes',
    setting: 'Next to a wall',
    blurb: 'The most restful one. Good in the evening, or on a day when you '
        "don't feel like anything else.",
    steps: [
      'Sit sideways next to a wall, with one hip touching it.',
      'Lie back and swing your legs up the wall, so your body makes an L '
          'shape.',
      'Rest your arms by your sides. Close your eyes if you like.',
      'Stay for three minutes and breathe normally.',
      'To come out, bend your knees, roll to one side, and sit up slowly.',
    ],
    skipIf: 'Come out if your legs tingle or go numb. Skip this if you have eye '
        'pressure problems or blood pressure that is not under control.',
    anim: TtcFigureAnim(
      seconds: 180,
      brief: 'Simple held pose, side view, with a three-minute timer ring. '
          'Very little motion, this is a rest pose.',
    ),
  ),
  TtcPractice(
    id: 'mb_sun',
    kind: TtcPracticeKind.move,
    title: 'Slow sun salutation, three rounds',
    duration: 'About 5 minutes',
    setting: 'Standing, with room to stretch',
    blurb: 'The most active card here, but still gentle if you go slowly. '
        'Only pick this one if you already know the moves or are happy to '
        'learn them.',
    steps: [
      'Stand tall, palms together at your chest.',
      'Breathe in, and raise your arms overhead.',
      'Breathe out, and fold forward from the hips, knees soft.',
      'Breathe in, and lift halfway with a flat back, hands on your shins.',
      'Step back one leg at a time. Gently lower your knees, then your chest '
          'and chin.',
      'Breathe in, slide forward and lift your chest, elbows soft.',
      'Breathe out, and lift your hips up and back into a downward slope. '
          'Stay for three breaths.',
      'Step your feet forward, fold, then rise back up to standing with your '
          'arms overhead.',
      'Repeat the whole thing three times, slowly.',
    ],
    skipIf: 'Skip this if you have back, wrist or shoulder problems, or if you '
        'feel dizzy when you bend forward. Go at half speed the first time.',
    anim: TtcFigureAnim(
      seconds: 300,
      sides: true,
      brief: 'The full sequence as a loop, side view, with the breath cue '
          'marked at each step. This is the longest animation of the six.',
    ),
  ),
];

// -----------------------------------------------------------------------------
//  Breathe and calm — all six run in code today, no artwork
// -----------------------------------------------------------------------------
//  ⚠️ NO BREATH IS HELD EXCEPT IN BOX BREATHING, WHERE IT IS THE PRACTICE AND
//  THE CARD OFFERS A WAY OUT OF IT. Retention is the part of this tradition that
//  genuinely wants a teacher in the room, and "shorten the holds to two counts…
//  skip the holds entirely if you are unwell" is the brief's own line.
const List<TtcPractice> _breathe = [
  TtcPractice(
    id: 'mb_longout',
    kind: TtcPracticeKind.breathe,
    // Said in plain words (launch sanity MB7, 2026-09-28): "in four out six"
    // was shorthand she had to decode. Kept for revert:
    //   title: 'Long out-breath, in four out six',
    //   blurb: 'The easiest way to calm your body. Breathing out for longer '
    //       'than you breathe in is what does the work.',
    title: 'Breathe in for 4, out for 6',
    duration: '1 minute',
    setting: 'Sitting or lying',
    blurb: 'A long out-breath is the easiest way to calm your body. Breathing '
        'out for longer than you breathe in is what does the work.',
    steps: [
      'Sit comfortably and let your shoulders drop.',
      'Breathe in through your nose while you count to four.',
      'Breathe out slowly through your nose or mouth while you count to six.',
      "Keep going for one minute. That's about six rounds.",
      'If six feels too long, breathe in for three and out for five.',
    ],
    skipIf: 'Go back to normal breathing if you feel light-headed.',
    anim: TtcBreathAnim(inhale: 4, exhale: 6, seconds: 60),
  ),
  TtcPractice(
    id: 'mb_nostril',
    kind: TtcPracticeKind.breathe,
    title: 'Alternate nostril breathing',
    duration: '1 to 2 minutes',
    setting: 'Sitting',
    blurb: 'A traditional breathing practice that many people find calming. '
        'You use one hand to close one nostril at a time.',
    steps: [
      'Sit tall. Use your right hand, with the thumb and ring finger.',
      'Close your right nostril with your thumb. Breathe in through the left.',
      'Close your left nostril with your ring finger, lift your thumb, and '
          'breathe out through the right.',
      'Breathe in through the right.',
      'Close the right, open the left, and breathe out through the left. '
          "That's one round.",
      'Do this for one to two minutes, slowly and without forcing.',
    ],
    skipIf: 'Skip this if your nose is blocked with a cold. Stop if you feel '
        'light-headed.',
    anim: TtcBreathAnim(inhale: 4, exhale: 4, seconds: 90, nostrils: true),
  ),
  TtcPractice(
    id: 'mb_box',
    kind: TtcPracticeKind.breathe,
    title: 'Box breathing',
    duration: '1 minute',
    setting: 'Anywhere',
    blurb: 'Four equal parts, easy to remember. Useful when your mind is '
        'racing, and you can do it at a desk without anyone noticing.',
    steps: [
      'Breathe in through your nose while you count to four.',
      'Hold for a count of four.',
      'Breathe out for a count of four.',
      "Hold with your lungs empty for a count of four. That's one round.",
      'Do four rounds, which is about one minute.',
    ],
    skipIf: 'Shorten the holds to two counts if holding feels uncomfortable. '
        "Skip the holds completely if you're unwell.",
    anim: TtcBreathAnim(
        inhale: 4, hold: 4, exhale: 4, holdEmpty: 4, seconds: 64, square: true),
  ),
  TtcPractice(
    id: 'mb_bodyrelax',
    kind: TtcPracticeKind.breathe,
    title: 'Two-minute body relaxation',
    duration: '2 minutes',
    setting: 'Sitting or lying',
    blurb: "This isn't breathing work. You move your attention through your "
        'body and let each part relax. Good at the end of the day.',
    steps: [
      'Lie down or sit back comfortably and close your eyes.',
      'Notice your face. Unclench your jaw. Let your forehead soften.',
      'Move to your shoulders. Let them drop.',
      'Move to your hands. Let your fingers uncurl.',
      'Move to your belly. Let it be soft, not held in.',
      'Move down through your legs to your feet.',
      'Take three normal breaths and slowly open your eyes.',
    ],
    skipIf: 'Nothing to skip. If you fall asleep doing this in the evening, '
        "that's fine.",
    anim: TtcBodyScanAnim(seconds: 120),
  ),
  TtcPractice(
    id: 'mb_listen',
    kind: TtcPracticeKind.breathe,
    title: 'Two-minute calm listen',
    duration: '2 minutes',
    setting: 'Anywhere you can close your eyes',
    blurb: "For days when you don't want to do anything. You only have to sit "
        'and listen.',
    steps: [
      'Sit or lie back and close your eyes.',
      'Play something calm. Soft music, a raag, a chant, or whatever calms '
          'you.',
      "Don't try to focus. Let your attention wander off and come back.",
      'When it ends, sit for one more breath before you get up.',
    ],
    skipIf: 'Nothing to skip.',
    anim: TtcListenAnim(seconds: 120),
  ),
  TtcPractice(
    id: 'mb_together',
    kind: TtcPracticeKind.breathe,
    title: 'Ten slow breaths together',
    duration: '1 minute',
    setting: 'Both of you, same room',
    blurb: 'The only one that needs both of you. Nothing to say and nothing to '
        "decide. That's what makes it restful.",
    steps: [
      'Sit near each other, wherever you are.',
      'Decide who counts, or use the screen.',
      'Breathe in and out slowly together, ten times.',
      "Don't try to match each other exactly. About the same pace is "
          'enough.',
      "That's all there is to it.",
    ],
    skipIf: "Nothing to skip. If one of you isn't around, do the long "
        'out-breath card instead.',
    anim: TtcBreathAnim(
        inhale: 4, exhale: 6, seconds: 100, countTo: 10, twoMarkers: true),
  ),
];

/// The whole library, Move first.
const List<TtcPractice> kTtcPractices = [..._move, ..._breathe];

List<TtcPractice> ttcPracticesOfKind(TtcPracticeKind kind) =>
    kTtcPractices.where((p) => p.kind == kind).toList();

/// Null for an unknown id — the wiring gate. A card naming a practice that does
/// not exist opens nothing rather than opening the wrong practice.
TtcPractice? ttcPracticeById(String id) =>
    kTtcPractices.where((p) => p.id == id).firstOrNull;

/// The six drawn animations still to be commissioned, with their briefs.
///
/// ⚠️ IT IS A FUNCTION OVER THE DATA, NOT A LIST SOMEBODY MAINTAINS. The brief
/// asks for this list in the output summary, and a hand-written one is wrong the
/// first time a card changes. Derived, it cannot be.
List<(String id, String title, int seconds, String brief)> ttcAnimationsOwed() =>
    [
      for (final p in kTtcPractices)
        if (p.anim case TtcFigureAnim(:final assetPath, :final brief, :final seconds))
          if (assetPath == null) (p.id, p.title, seconds, brief),
    ];
