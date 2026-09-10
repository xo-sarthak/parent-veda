// =============================================================================
//  The free preconception garbh sanskar course — eight sessions, as data
// -----------------------------------------------------------------------------
//  Content from `ParentVeda_garbh_sanskar_eight_sessions.pdf`, 30 Aug 2026.
//  Every intro, step and "said plainly" note below is the brief's own wording.
//
//  ⚠️ THIS COURSE EXISTED AS A PRICE OF ZERO AND NOTHING ELSE. Before this file
//  it was one `TtcOffering` in `ttc_prepare_data.dart` — a catalogue card that
//  described eight sessions and opened a shelf. The door's "Go deeper" tile
//  said "taught properly rather than described" and then landed on a
//  description. This file is the eight sessions themselves.
//
//  ⚠️ IT TEACHES BY REUSING THE PRACTICE LIBRARY, NOT BY RESTATING IT. The
//  brief is explicit — *"Reuse, do not rebuild. The course uses the same
//  animation components already built for the twelve practice cards"* — so a
//  session names practice IDS and the session screen renders the real player.
//  Session 2 does not carry its own copy of the long out-breath; it points at
//  `mb_longout`, and when that card changes the session changes with it.
//
//  ⚠️ THE ORDER IS ARGUED, NOT ARBITRARY, and the brief says why: *"breath
//  first because it is the easiest to feel working, then stillness, then sound,
//  then the body and the day, then food, then the two of you, then putting it
//  together."* Renumbering these is a content decision, not a tidy-up.
//
//  ⚠️ WHAT THIS FILE MUST NEVER GROW — the same four absolutes as the practice
//  library, and here they matter more, because a course is the format the
//  market uses to sell exactly these claims:
//    · No claim that any of this makes conception happen.
//    · No claim about a baby's intelligence or nature.
//    · No detox, cleanses, herbs, panchakarma or astrology.
//    · No price, no upsell, no locked session.
//  `test/ttc_garbh_course_test.dart` scans these strings for all four.
// =============================================================================

/// What a session asks the reader to DO at the end, beyond the practices.
///
/// ⚠️ THREE VALUES AND NOT A FLAG PER SESSION. Three of the eight produce
/// something the app keeps — a bedtime, meal times, and the assembled practice
/// — and the rest produce nothing but the doing of them. A boolean per feature
/// would let this express states the course does not have; see CLAUDE.md on
/// config objects with more states than the product.
enum TtcCourseAction {
  /// Most sessions. You do the practice and that is the session.
  none,

  /// Session 5: one wake time and one sleep time, both of you.
  setTimes,

  /// Session 6: your regular meal times.
  setMeals,

  /// Session 8: assemble the daily practice and write it into Today.
  assemble,
}

class TtcCourseSession {
  const TtcCourseSession({
    required this.id,
    required this.number,
    required this.title,
    required this.duration,
    required this.setting,
    required this.betterTogether,
    required this.intro,
    required this.steps,
    required this.saidPlainly,
    this.practiceIds = const [],
    this.action = TtcCourseAction.none,
    this.sitSeconds,
  });

  final String id;

  /// 1..8. Shown as the session number and used for ordering.
  final int number;

  final String title;

  /// "About 15 minutes" — the brief hedges and so does this.
  final String duration;

  /// "Sitting", "Both of you, headphones optional".
  final String setting;

  /// ⚠️ A LINE OF TEXT, NEVER A LOCK. The brief is emphatic: *"Sessions 1, 5, 7
  /// and 8 say they are better done together; that is a line of text, not a
  /// lock."* Nothing in this app may require a partner to have finished
  /// anything — half the people doing this course are doing it alone, and some
  /// of them are doing it alone because their partner will not join in, which
  /// is the one situation where a lock would be cruel.
  final bool betterTogether;

  /// The paragraph that opens the session.
  final String intro;

  /// WHAT YOU DO, numbered on screen.
  final List<String> steps;

  /// The honest aside. Always shown, and never hidden behind a tap — the brief
  /// lists it with the step text and the timer as the part that must work when
  /// no animation exists.
  final String saidPlainly;

  /// Practices from `ttc_practice_data.dart` this session teaches, in order.
  ///
  /// ⚠️ IDS, NOT COPIES. The session screen resolves each through
  /// `ttcPracticeById` and renders the real player, so a session that names a
  /// practice which has been renamed or removed shows nothing rather than
  /// showing stale text. That is the wiring gate applied to content.
  final List<String> practiceIds;

  final TtcCourseAction action;

  /// A plain sit with a ring, for the two sessions that ask for one and have no
  /// practice card behind them: session 1's two minutes of sitting still, and
  /// session 3's five minutes of attention on the breath.
  final int? sitSeconds;
}

// -----------------------------------------------------------------------------
//  The frame, stated once and never contradicted
// -----------------------------------------------------------------------------

/// How the course works. Shown on the course home, above the eight.
const String kTtcCourseHow =
    'Eight sessions, about fifteen minutes each, done at your own pace. Every '
    'session teaches one part of the practice and ends by having you actually '
    'do it, not just read about it. By session eight you have your own '
    'five-minute daily practice, which is the same practice that lives on the '
    'Today tab. It is free and it stays free.';

/// ⚠️ THE POSITION, IN THE COURSE'S OWN WORDS. It is stated in session one and
/// repeated on the course home, because somebody who arrives from a search
/// result rather than from session one still has to meet it before the first
/// practice. It is the sentence the whole area is built to be able to defend.
const String kTtcCourseFrame =
    'This is preparation, not a method of conception. It will not make a '
    'pregnancy happen and it does not claim to. It does not shape a child\'s '
    'intelligence or nature; there is no evidence for that and we will not tell '
    'you otherwise. What it offers is a calmer way to spend the waiting, and a '
    'body and mind in better shape when conception happens. Belief is optional. '
    'Nothing here needs you to hold any particular faith.';

/// What the course leaves out, and the warning sign at the end of it.
///
/// ⚠️ THE LAST SENTENCE IS THE CLINICAL ONE AND IT IS NOT DECORATION. Garbh
/// sanskar offered as an ALTERNATIVE to fertility treatment is the failure mode
/// that costs someone years, and the brief has us say so plainly rather than
/// leaving it implied by the things we decline to sell.
const String kTtcCourseNever =
    'No detox, cleanses or panchakarma. No herbs or medicines to buy. No '
    'astrology or auspicious dates. No claims about purifying the seed. No '
    'promise of better odds. If you are ever offered garbh sanskar as an '
    'alternative to fertility treatment, that is a warning sign, and the '
    'tradition itself does not claim it.';

// -----------------------------------------------------------------------------
//  The eight
// -----------------------------------------------------------------------------

const List<TtcCourseSession> kTtcCourseSessions = [
  // ---- 1 --------------------------------------------------------------------
  TtcCourseSession(
    id: 'gs_what',
    number: 1,
    title: 'What this is, and what it is not',
    duration: 'About 12 minutes',
    setting: 'Both of you, together if possible',
    betterTogether: true,
    intro: 'The honest opening. What garbh sanskar actually is, what the '
        'tradition does and does not claim, and why the preconception version '
        'is the more sensible half of it. Then your first practice, which is '
        'simply sitting still.',
    steps: [
      'Read the opening: where the practice comes from, and what it is for.',
      'Read the four things this course leaves out, and why.',
      'Sit upright, somewhere quiet, and start the two-minute timer.',
      'Do nothing. Let the thoughts come and go. You are not trying to empty '
          'the mind.',
      'When the timer ends, notice how that felt. It is normal to find it '
          'uncomfortable at first.',
    ],
    saidPlainly: 'Sitting still for two minutes is not a small thing when you '
        'have been waiting for months. Nothing in this session is meant to fix '
        'anything yet.',
    sitSeconds: 120,
  ),

  // ---- 2 --------------------------------------------------------------------
  TtcCourseSession(
    id: 'gs_breath',
    number: 2,
    title: 'Breath',
    duration: 'About 15 minutes',
    setting: 'Sitting',
    betterTogether: false,
    intro: 'The part with the clearest effect, and the one you will use most. '
        'Two breathing practices taught properly, slowly, with the counts on '
        'screen.',
    steps: [
      'Sit tall, shoulders down, hands resting.',
      'Learn the long out-breath: in for four, out for six. Practise for two '
          'minutes.',
      'Learn alternate nostril breathing, one step at a time, with the hand '
          'position shown.',
      'Practise alternate nostril for two minutes.',
      'Finish by sitting for thirty seconds with normal breathing, and notice '
          'the difference.',
      'Pick whichever of the two you preferred. That is the one you will keep.',
    ],
    saidPlainly: 'Slow the counts down if you feel light-headed. Breathing '
        'practice should never feel like effort.',
    practiceIds: ['mb_longout', 'mb_nostril'],
  ),

  // ---- 3 --------------------------------------------------------------------
  TtcCourseSession(
    id: 'gs_still',
    number: 3,
    title: 'Stillness',
    duration: 'About 15 minutes',
    setting: 'Sitting or lying',
    betterTogether: false,
    intro: 'Meditation taught without the mystique. You are training attention '
        'to come back, over and over. That is the whole skill.',
    steps: [
      'Sit comfortably and close the eyes.',
      'Put your attention on the feeling of the breath at the nostrils.',
      'When the mind wanders, and it will, bring it back. That returning is '
          'the practice, not a failure.',
      'Do this for five minutes, using the timer below.',
      'Then try a body relaxation instead: move attention from the face down '
          'to the feet, letting each part go.',
      'Notice which of the two suits you better.',
    ],
    saidPlainly: 'A wandering mind is not a sign you are doing it wrong. It is '
        'what minds do. Nobody gets a still mind for five minutes.',
    practiceIds: ['mb_bodyrelax'],
    sitSeconds: 300,
  ),

  // ---- 4 --------------------------------------------------------------------
  TtcCourseSession(
    id: 'gs_sound',
    number: 4,
    title: 'Sound',
    duration: 'About 12 minutes',
    setting: 'Both of you, headphones optional',
    betterTogether: false,
    intro: 'Chanting, mantra and music, offered as a way to settle rather than '
        'as a ritual you must believe in. This is the session people are most '
        'unsure about, so it is deliberately gentle.',
    steps: [
      'Listen to a short calm piece with the eyes closed, two minutes, doing '
          'nothing else.',
      'Try humming on the out-breath for one minute. It naturally lengthens '
          'the exhale.',
      'Try a simple repeated sound or mantra, out loud or silently, for two '
          'minutes. Any word or sound that settles you works.',
      'If chanting is not for you, use the calm listening instead. Both are on '
          'the Today tab.',
      'Notice whether doing it aloud or silently suited you better.',
    ],
    saidPlainly: 'If a mantra means something to you, use it. If it does not, '
        'humming or listening does the same job here. Nothing in this session '
        'depends on the words having power.',
    practiceIds: ['mb_listen'],
  ),

  // ---- 5 --------------------------------------------------------------------
  TtcCourseSession(
    id: 'gs_body',
    number: 5,
    title: 'The body and the day',
    duration: 'About 15 minutes',
    setting: 'Both of you',
    betterTogether: true,
    intro: 'Gentle movement, and the shape of the day. This is where the '
        'routine side of the tradition and ordinary preconception advice agree '
        'with each other.',
    steps: [
      'Learn the loosen-up sequence: neck, shoulders, side bends, one forward '
          'fold.',
      'Learn cat and cow, and child\'s pose, with the breath.',
      'Understand why gentle is the instruction: hard training and hot yoga '
          'work against what you are doing.',
      'Set one wake time and one sleep time that both of you will keep, aiming '
          'for bed by about eleven.',
      'Agree one small change to the evening that makes that bedtime possible.',
    ],
    saidPlainly: 'The sleep part matters more than the postures. If you only '
        'take one thing from this session, take the fixed bedtime.',
    practiceIds: ['mb_loosen', 'mb_catcow'],
    action: TtcCourseAction.setTimes,
  ),

  // ---- 6 --------------------------------------------------------------------
  TtcCourseSession(
    id: 'gs_food',
    number: 6,
    title: 'Food',
    duration: 'About 12 minutes',
    setting: 'Both of you',
    betterTogether: false,
    // ⚠️ IT POINTS AT GETTING READY AND TEACHES NOTHING. Same boundary the
    // door's fourth tab holds: food is owned elsewhere, and a course session
    // that re-taught it would be the second copy that drifts.
    intro: 'Sattvik eating explained plainly, without a diet plan and without '
        'anything imported. Regular, home-cooked, mostly fresh. The detail '
        'lives in Getting ready and this session points there.',
    steps: [
      'Understand what sattvik traditionally means: fresh, simple, '
          'home-cooked, eaten calmly and at regular times.',
      'See how closely that matches ordinary preconception advice.',
      'Pick your regular meal times, for both of you, and keep them.',
      'Open the food and supplement pages in Getting ready for the specifics, '
          'including folic acid.',
      'Agree one meal a day the two of you will eat together, without screens, '
          'if your timings allow.',
    ],
    saidPlainly: 'No calorie counting, no banned foods and no weight targets '
        'here. Anything about supplements should come from a doctor, not from '
        'this course.',
    action: TtcCourseAction.setMeals,
  ),

  // ---- 7 --------------------------------------------------------------------
  TtcCourseSession(
    id: 'gs_two',
    number: 7,
    title: 'The two of you',
    duration: 'About 15 minutes',
    setting: 'Both of you, together',
    betterTogether: true,
    intro: 'The conduct and conversation part of the tradition, which turns '
        'out to be the couple part. This is the session people say changed the '
        'most.',
    steps: [
      'Understand the traditional idea plainly: how you live and how you treat '
          'each other is the preparation, more than any single ritual.',
      'Do the gratitude practice: each of you names one thing you like about '
          'the other, out loud.',
      'Do the conversation practice: ask each other one honest question and '
          'just listen to the answer without fixing it.',
      'Agree what you will say to relatives who keep asking, so neither of you '
          'has to improvise it alone.',
      'Do ten slow breaths together, in the same room, same pace.',
    ],
    saidPlainly: 'If one of you is finding this much harder than the other, '
        'that is normal and not a sign of anything wrong. It is worth saying '
        'out loud rather than managing alone.',
    practiceIds: ['mb_together'],
  ),

  // ---- 8 --------------------------------------------------------------------
  TtcCourseSession(
    id: 'gs_together',
    number: 8,
    title: 'Putting it together',
    duration: 'About 15 minutes',
    setting: 'Both of you',
    betterTogether: true,
    intro: 'You build your own five-minute daily practice from what you '
        'actually liked, and it becomes your Today tab. Nothing is assigned.',
    steps: [
      'Look back at the seven sessions and pick the breathing practice you '
          'preferred.',
      'Pick the movement you will actually do on an ordinary day.',
      'Confirm your bedtime and your meal times.',
      'Choose whether you want the gratitude or the conversation part daily, '
          'or neither.',
      'Set it as your daily practice. It should take five minutes, not more.',
      'Read the last part: what to do on the days you skip it.',
    ],
    saidPlainly: 'There is no streak and nothing to maintain. If you skip '
        'three days you have lost nothing. The moment this becomes another '
        'thing to feel behind on, it is doing the opposite of its job.',
    action: TtcCourseAction.assemble,
  ),
];

/// Null for an unknown id — the wiring gate. A tile naming a session that does
/// not exist opens nothing rather than opening the wrong session.
TtcCourseSession? ttcCourseSessionById(String id) =>
    kTtcCourseSessions.where((s) => s.id == id).firstOrNull;

/// The one closing note, shown at the foot of session eight.
///
/// ⚠️ THE COURSE ENDS ON PERMISSION TO SKIP IT. Every other course in this app
/// ends on a next step; this one ends by lowering the stakes, because the thing
/// it is competing with is a ninety-day programme somebody can fall behind on.
const String kTtcCourseSkipNote =
    'On the days you skip it, skip it. Nothing here is counting, there is '
    'nothing to catch up on, and the practice is waiting where you left it.';
