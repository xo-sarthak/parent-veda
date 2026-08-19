// =============================================================================
//  Mind & Mood - data
// -----------------------------------------------------------------------------
//  The most emotionally sensitive section in the app, so the rules here have
//  teeth rather than being decoration:
//
//    - NEVER a diagnosis. Nothing here names a condition AT her; the "more than
//      a mood" group explains a word she may already have heard, it does not
//      hand her a new one.
//    - NEVER a score. The self-check screener and the mood-pattern nudge both
//      compute a private severity signal and NEVER show her the number. See
//      `MmScreener.severityOf` and `MoodTrend` below - both return English
//      sentences, not integers, to the widgets that read them.
//    - NO gamification of mood. No streak, no "you missed a day", no badge.
//    - Paid content lives ONLY in `kMmTalkOfferings` and the footer of a
//      "more than a mood" article. It must never be reachable from Feel,
//      Track, the crisis path, or the screener itself.
//
//  ⚠️ CONDITION AND SCREENER COPY IS MARKED `requiresReview: true` BELOW.
//  Draft wording only - a perinatal counsellor must approve the exact phrasing
//  of the six "more than a mood" articles and every screener question before
//  this ships. See the `REQUIRED_REVIEW` markers throughout this file.
//
//  ⚠️ ENGLISH ONLY FOR NOW - see `_en` below and CLAUDE.md's language rules.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_language.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// =============================================================================
//  The crisis helpline - ONE constant, so a placeholder can never ship quietly
// =============================================================================
//  ⚠️ REQUIRED_TO_CONFIRM ⚠️
//  KIRAN is India's real 24x7 government mental health helpline (toll-free),
//  used here so the crisis path is never wired to a fake number even in a
//  first pass. BUT the product owner must confirm this is the number we want
//  to send a mother to - a partner counselling line, once one exists, may be
//  the better front door. Whoever actions this: change ONE constant here and
//  every crisis surface in the app updates together.
const String kCrisisHelplineName = 'KIRAN Mental Health Helpline'; // REQUIRED_TO_CONFIRM
const String kCrisisHelplineNumber = '18005990019'; // REQUIRED_TO_CONFIRM
const String kCrisisHelplineHours = '24x7, toll free'; // REQUIRED_TO_CONFIRM

/// India's single emergency number. Real, not a placeholder - shown only for
/// "you or your baby are in danger right now", never as the primary CTA.
const String kEmergencyNumber = '112';

// =============================================================================
//  Feel - breathing
// =============================================================================

enum MmBreathAction { expand, hold, contract }

class MmBreathPhase {
  const MmBreathPhase(this.label, this.seconds, this.action);
  final LocalizedText label;
  final int seconds;
  final MmBreathAction action;
}

class MmBreathingExercise {
  const MmBreathingExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.why,
    required this.phases,
  });
  final String id;
  final LocalizedText name;

  /// One line, shown on the picker card.
  final LocalizedText description;

  /// Why this pattern in particular helps - shown once, on the exercise's own
  /// screen, so it reads as care rather than a feature list.
  final LocalizedText why;
  final List<MmBreathPhase> phases;
}

final List<MmBreathingExercise> kMmBreathingExercises = [
  MmBreathingExercise(
    id: 'box',
    name: _en('Box breathing'),
    description: _en('Four equal counts, in a steady square. Good when your '
        'thoughts are racing.'),
    why: _en('Four equal sides give your mind something simple to hold onto, '
        'which is most of what a racing mind needs.'),
    phases: [
      MmBreathPhase(_en('Breathe in'), 4, MmBreathAction.expand),
      MmBreathPhase(_en('Hold'), 4, MmBreathAction.hold),
      MmBreathPhase(_en('Breathe out'), 4, MmBreathAction.contract),
      MmBreathPhase(_en('Hold'), 4, MmBreathAction.hold),
    ],
  ),
  MmBreathingExercise(
    id: '4-7-8',
    name: _en('4-7-8 breath'),
    description: _en('A short in, a long hold, a longer out. Good before '
        'sleep or when your heart is pounding.'),
    why: _en('The long, slow exhale is doing the work here. It tells your '
        'body the moment has passed, even before your mind believes it.'),
    phases: [
      MmBreathPhase(_en('Breathe in'), 4, MmBreathAction.expand),
      MmBreathPhase(_en('Hold'), 7, MmBreathAction.hold),
      MmBreathPhase(_en('Breathe out'), 8, MmBreathAction.contract),
    ],
  ),
  MmBreathingExercise(
    id: 'slow_down',
    name: _en('Slow-down breath'),
    description: _en('A gentle in, a longer out, nothing to count under '
        'pressure. Good any time you just need to slow down.'),
    why: _en('An exhale longer than the inhale is the single fastest way to '
        'settle a body that has sped up. No holding, nothing to get wrong.'),
    phases: [
      MmBreathPhase(_en('Breathe in'), 4, MmBreathAction.expand),
      MmBreathPhase(_en('Breathe out'), 6, MmBreathAction.contract),
    ],
  ),
];

/// Selectable session lengths, in seconds - shown as chips on the breathing
/// screen before she starts.
const List<int> kMmBreathDurationsSec = [60, 180, 300];

MmBreathingExercise mmBreathingById(String id) =>
    kMmBreathingExercises.firstWhere((e) => e.id == id,
        orElse: () => kMmBreathingExercises.first);

// =============================================================================
//  Feel - the SOS / calm-now grounding flow (about 60 seconds, three steps)
// =============================================================================

enum MmSosStepKind { breath, senses, steadying }

class MmSosStep {
  const MmSosStep(this.kind, this.prompt, {this.seconds = 12});
  final MmSosStepKind kind;
  final LocalizedText prompt;
  final int seconds;
}

/// Step 1 is a single slow breath (reuses the slow-down pattern's shape but
/// is written out here so the SOS flow does not depend on the breathing
/// screen to run). Step 2 is 5-4-3-2-1 senses grounding. Step 3 is one
/// steadying line to close on.
final List<MmSosStep> kMmSosFlow = [
  MmSosStep(MmSosStepKind.breath, _en('Breathe in slowly.'), seconds: 4),
  MmSosStep(MmSosStepKind.breath, _en('Breathe out, slower than that.'),
      seconds: 6),
  MmSosStep(MmSosStepKind.senses,
      _en('Name 5 things you can see around you.'), seconds: 14),
  MmSosStep(
      MmSosStepKind.senses, _en('Name 4 things you can hear.'), seconds: 12),
  MmSosStep(MmSosStepKind.senses,
      _en('Name 3 things you can touch or feel.'), seconds: 12),
  MmSosStep(
      MmSosStepKind.senses, _en('Name 2 things you can smell.'), seconds: 10),
  MmSosStep(MmSosStepKind.senses,
      _en('Name 1 thing you are grateful for, right now.'), seconds: 10),
  MmSosStep(
      MmSosStepKind.steadying,
      _en('This feeling will move through you. You are safe, and this '
          'moment is passing.'),
      seconds: 10),
];

/// If the SOS flow is opened this many times within [kMmSosWindow], the
/// crisis path is surfaced after the flow finishes - see
/// `MindMoodStore.registerSosOpen`.
const int kMmSosRepeatThreshold = 3;
const Duration kMmSosWindow = Duration(minutes: 15);

// =============================================================================
//  Feel - guided meditations (mother-focused; Garbh Sanskar already owns the
//  baby-connection meditations, so nothing here is addressed to the baby)
// =============================================================================

class MmMeditation {
  const MmMeditation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationLabel,
  });
  final String id;
  final LocalizedText title;
  final LocalizedText subtitle;
  final LocalizedText durationLabel; // "8 MIN"
}

final List<MmMeditation> kMmMeditations = [
  MmMeditation(
    id: 'letting_go_of_worry',
    title: _en('Letting go of worry'),
    subtitle: _en('For the thoughts that keep circling back.'),
    durationLabel: _en('10 MIN'),
  ),
  MmMeditation(
    id: 'sleep',
    title: _en('Falling asleep'),
    subtitle: _en('A slow wind-down for a body that will not settle.'),
    durationLabel: _en('15 MIN'),
  ),
  MmMeditation(
    id: 'morning_calm',
    title: _en('Morning calm'),
    subtitle: _en('A gentle start, before the day asks anything of you.'),
    durationLabel: _en('7 MIN'),
  ),
  MmMeditation(
    id: 'releasing_birth_fear',
    title: _en('Releasing birth fear'),
    subtitle: _en('For when labour feels bigger than you can hold.'),
    durationLabel: _en('12 MIN'),
  ),
  MmMeditation(
    id: 'self_compassion',
    title: _en('Self-compassion'),
    subtitle: _en('Speaking to yourself the way you would to a friend.'),
    durationLabel: _en('9 MIN'),
  ),
  MmMeditation(
    id: 'hard_day_reset',
    title: _en('A hard-day reset'),
    subtitle: _en('For the days that just did not go well.'),
    durationLabel: _en('6 MIN'),
  ),
];

// =============================================================================
//  Feel - calming audio
// =============================================================================

class MmCalmAudio {
  const MmCalmAudio(
      {required this.id,
      required this.title,
      required this.subtitle,
      required this.durationLabel});
  final String id;
  final LocalizedText title;
  final LocalizedText subtitle;
  final LocalizedText durationLabel;
}

final List<MmCalmAudio> kMmCalmAudio = [
  MmCalmAudio(
      id: 'rain',
      title: _en('Rain'),
      subtitle: _en('Steady rainfall, nothing else.'),
      durationLabel: _en('30 MIN LOOP')),
  MmCalmAudio(
      id: 'om',
      title: _en('Om chant'),
      subtitle: _en('A single sustained chant, low and slow.'),
      durationLabel: _en('20 MIN LOOP')),
  MmCalmAudio(
      id: 'instrumental',
      title: _en('Soft instrumental'),
      subtitle: _en('Quiet strings and piano, no lyrics.'),
      durationLabel: _en('25 MIN LOOP')),
  MmCalmAudio(
      id: 'humming',
      title: _en('Humming'),
      subtitle: _en('A soft, wordless hum, like a lullaby without words.'),
      durationLabel: _en('15 MIN LOOP')),
];

// =============================================================================
//  Understand - article groups
// =============================================================================

enum MmArticleGroup { isThisNormal, fears, moreThanMood, everydayCare }

extension MmArticleGroupMeta on MmArticleGroup {
  LocalizedText get heading => switch (this) {
        MmArticleGroup.isThisNormal => _en('Is this normal?'),
        MmArticleGroup.fears => _en('Fears, named and answered'),
        MmArticleGroup.moreThanMood => _en('When it is more than a mood'),
        MmArticleGroup.everydayCare => _en('Everyday emotional care'),
      };

  LocalizedText get intro => switch (this) {
        MmArticleGroup.isThisNormal => _en('The feelings that catch mothers '
            'by surprise, and almost always are not a problem.'),
        MmArticleGroup.fears => _en('The worries most women carry and rarely '
            'say out loud. Named here, so you know you are not the only '
            'one.'),
        MmArticleGroup.moreThanMood => _en('Gently, and only where it is '
            'useful to know: what it looks like when a feeling has become '
            'more than a passing mood, and what to do about it.'),
        MmArticleGroup.everydayCare => _en('The ordinary things that shape '
            'how you feel, day to day.'),
      };
}

class MmArticle {
  const MmArticle({
    required this.id,
    required this.group,
    required this.title,
    required this.teaser,
    required this.readingTime,
    required this.body,
    this.hasExpertVideo = false,
    this.hasStoryVideo = false,
    this.whatItIs,
    this.signsToNotice,
    this.howToGetHelp,
    this.requiresReview = false,
  });

  final String id;
  final MmArticleGroup group;
  final LocalizedText title;

  /// One line, shown on the article's card.
  final LocalizedText teaser;
  final LocalizedText readingTime; // "3 MIN"

  /// Paragraphs, separated by a blank line.
  final LocalizedText body;

  /// §Understand - "an expert explainer at the top of each 'more than a
  /// mood' page and each major fear page".
  final bool hasExpertVideo;

  /// §Understand - "a 'real mother story' slot on the 'is this normal' and
  /// fear pages".
  final bool hasStoryVideo;

  /// Only the six "more than a mood" articles carry these three - the
  /// structured shape the spec asks for: what it is, signs to notice, how to
  /// get help.
  final LocalizedText? whatItIs;
  final LocalizedText? signsToNotice;
  final LocalizedText? howToGetHelp;

  /// ⚠️ REQUIRED_REVIEW - a perinatal counsellor has not yet approved this
  /// wording. True for every "more than a mood" article.
  final bool requiresReview;
}

List<MmArticle> mmArticlesIn(MmArticleGroup g) =>
    kMmArticles.where((a) => a.group == g).toList(growable: false);

MmArticle? mmArticleById(String id) {
  for (final a in kMmArticles) {
    if (a.id == id) return a;
  }
  return null;
}

final List<MmArticle> kMmArticles = [
  // ---------------------------------------------------------------------------
  //  Is this normal? - 9
  // ---------------------------------------------------------------------------
  MmArticle(
    id: 'mood_swings',
    group: MmArticleGroup.isThisNormal,
    title: _en('Mood swings'),
    teaser: _en('Up one hour, in tears the next. This is one of the most '
        'common things pregnancy does.'),
    readingTime: _en('3 MIN'),
    hasStoryVideo: true,
    body: _en(
      'Your hormone levels are changing faster than at almost any other '
      'point in your life, and those same hormones sit close to the parts '
      'of the brain that manage mood. A swing from laughing to tearful in '
      'the space of an hour is not a sign anything is wrong with you, it is '
      'a sign your body is doing a lot of chemical work in a short time.\n\n'
      'It tends to be strongest in the first trimester, when the change is '
      'sharpest, and again nearer the end, when your body is preparing for '
      'birth. Many women find it eases in the middle months.\n\n'
      'What helps most is not fighting it. Naming it out loud, "I am just '
      'having a wobbly hour", takes some of the pressure off. If it is '
      'making daily life hard most days rather than some days, that is '
      'worth reading more about, and "When it is more than a mood" is '
      'where to look.',
    ),
  ),
  MmArticle(
    id: 'crying_easily',
    group: MmArticleGroup.isThisNormal,
    title: _en('Crying easily'),
    teaser: _en('An advert, a song, a kind word from a stranger. Any of it '
        'can set you off, and that is normal.'),
    readingTime: _en('3 MIN'),
    body: _en(
      'Pregnancy lowers the threshold for tears. Things that would once '
      'have passed you by, a song on the radio, a stranger being kind, now '
      'reach you faster and deeper. That is not a character change, it is '
      'a hormonal one, and it fades as your body settles into each stage.\n\n'
      'It can feel embarrassing in the moment, especially in front of '
      'colleagues or family who do not expect it. It does not need '
      'explaining every time. "I am a bit emotional today" is enough.\n\n'
      'The distinction worth knowing is between tears that pass and leave '
      'you feeling lighter, and a heaviness that does not lift. The first '
      'is ordinary pregnancy. The second is worth a closer look.',
    ),
  ),
  MmArticle(
    id: 'irritability_anger',
    group: MmArticleGroup.isThisNormal,
    title: _en('Irritability and anger'),
    teaser: _en('Snapping at people you love, over things that would '
        'usually not bother you.'),
    readingTime: _en('3 MIN'),
    body: _en(
      'Anger is a less-talked-about pregnancy feeling than tears, but it is '
      'just as common. Poor sleep, nausea, physical discomfort and the '
      'sheer effort of growing a baby all shorten your fuse, and hormones '
      'add to it.\n\n'
      'It often lands hardest on the people closest to you, a partner, a '
      'parent, because they are the ones around when the fuse runs out. '
      'That is not a reflection of how you feel about them.\n\n'
      'A short pause before responding, even ten seconds, helps more than '
      'it sounds like it should. If anger is frequent enough that you '
      'worry about it, or it frightens you, that is worth talking through '
      'with someone rather than managing alone.',
    ),
  ),
  MmArticle(
    id: 'feeling_disconnected',
    group: MmArticleGroup.isThisNormal,
    title: _en('Feeling disconnected from the pregnancy'),
    teaser: _en('Not feeling the rush of love you expected, or not feeling '
        'much at all yet.'),
    readingTime: _en('4 MIN'),
    hasStoryVideo: true,
    body: _en(
      'Some women feel connected to their pregnancy from the first missed '
      'period. Many do not, and instead feel oddly separate from it for '
      'weeks or months, especially before there is any movement to feel. '
      'Neither is more correct than the other.\n\n'
      'Connection often builds gradually rather than arriving all at once, '
      'and it is not unusual for it to properly begin after the first '
      'flutter of movement, or even after the birth itself. Feeling '
      'disconnected now says nothing about the kind of mother you will '
      'be.\n\n'
      'If it comes with a general flatness about everything, not just the '
      'pregnancy, that is worth reading about in "When it is more than a '
      'mood".',
    ),
  ),
  MmArticle(
    id: 'guilt',
    group: MmArticleGroup.isThisNormal,
    title: _en('Guilt'),
    teaser: _en('For resting, for not feeling grateful enough, for a hundred '
        'small things.'),
    readingTime: _en('3 MIN'),
    body: _en(
      'Guilt shows up in pregnancy in small, persistent ways: guilt for '
      'needing to rest, guilt for not enjoying every moment, guilt for a '
      'coffee or a bad night, guilt for feeling anything other than '
      'grateful. It is one of the most common feelings mothers describe and '
      'rarely say out loud.\n\n'
      'A useful question to ask it is simple: would you judge a friend this '
      'harshly for the same thing? Almost always the answer is no, and that '
      'gap between how you treat yourself and how you would treat someone '
      'you love is worth noticing.\n\n'
      'Guilt that becomes a constant background hum, rather than something '
      'that visits and passes, is covered in "When it is more than a '
      'mood".',
    ),
  ),
  MmArticle(
    id: 'pregnancy_brain',
    group: MmArticleGroup.isThisNormal,
    title: _en('Pregnancy brain'),
    teaser: _en('Forgetting words mid-sentence, walking into a room and '
        'losing the reason why.'),
    readingTime: _en('3 MIN'),
    body: _en(
      'Forgetfulness and foggy thinking in pregnancy are real and well '
      'documented, not something you are imagining or a sign of anything '
      'wrong. Sleep changes, hormone shifts and simply having a great deal '
      'on your mind all play a part.\n\n'
      'It tends to be most noticeable in the third trimester and usually '
      'improves after birth, though tiredness in the early weeks with a '
      'newborn can keep it going a while longer.\n\n'
      'Small systems help more than trying to remember harder: a note on '
      'your phone, keys always in the same bowl, a list by the door. It is '
      'a season, not a permanent change.',
    ),
  ),
  MmArticle(
    id: 'overwhelm',
    group: MmArticleGroup.isThisNormal,
    title: _en('Feeling overwhelmed'),
    teaser: _en('Too much to think about, too many decisions, too little '
        'time to feel ready.'),
    readingTime: _en('3 MIN'),
    hasStoryVideo: true,
    body: _en(
      'Pregnancy arrives with a long list: appointments, decisions, things '
      'to buy, things to learn, and often work and family to manage '
      'alongside all of it. Feeling overwhelmed by the sheer size of that '
      'list is common, and it does not mean you are not coping.\n\n'
      'It often helps to separate "this week" from "the whole nine months" '
      '. Almost nothing on the list actually needs deciding today, even '
      'when it feels urgent.\n\n'
      'If the overwhelm sits with you most of most days, rather than lifting '
      'once the immediate task is done, "When it is more than a mood" is '
      'worth a look.',
    ),
  ),
  MmArticle(
    id: 'numb_no_joy',
    group: MmArticleGroup.isThisNormal,
    title: _en('Feeling numb when you expected joy'),
    teaser: _en('Everyone says this should be the happiest time, and you '
        'mostly feel nothing.'),
    readingTime: _en('4 MIN'),
    hasStoryVideo: true,
    body: _en(
      'This one is quietly common and rarely spoken about, because '
      'pregnancy is supposed to feel joyful and admitting it does not can '
      'feel like a failure. It is not one. Feelings do not arrive on '
      'schedule just because an occasion calls for them.\n\n'
      'Numbness can come from exhaustion, from a pregnancy that followed a '
      'hard journey to get here, from stress elsewhere in life taking up '
      'all the emotional room, or simply because that is how you process '
      'big change.\n\n'
      'A flat, empty feeling that persists, rather than a quiet or delayed '
      'one, is worth reading about in "When it is more than a mood", '
      'specifically antenatal depression.',
    ),
  ),
  MmArticle(
    id: 'loneliness',
    group: MmArticleGroup.isThisNormal,
    title: _en('Loneliness'),
    teaser: _en('Surrounded by people, and still feeling like no one quite '
        'understands.'),
    readingTime: _en('3 MIN'),
    body: _en(
      'It is possible to be surrounded by a loving family and still feel '
      'lonely in pregnancy, because what changes in your body and mind is '
      'yours alone to carry, even when everyone around you is trying to '
      'help.\n\n'
      'It is especially common for a first pregnancy, when friends who '
      'have not been through it cannot quite meet you where you are, or '
      'when family is far away, or when a joint household leaves little '
      'space that is only yours.\n\n'
      'Other mothers, even ones you have not met yet, are often the '
      'fastest route out of this particular loneliness. The Community '
      'space in the app exists for exactly this.',
    ),
  ),

  // ---------------------------------------------------------------------------
  //  Fears, named and answered - 6
  // ---------------------------------------------------------------------------
  MmArticle(
    id: 'fear_labour',
    group: MmArticleGroup.fears,
    title: _en('Fear of labour'),
    teaser: _en('A fear strong enough to have its own name: tokophobia. You '
        'are not alone in it.'),
    readingTime: _en('4 MIN'),
    hasExpertVideo: true,
    hasStoryVideo: true,
    body: _en(
      'A real, sometimes intense fear of labour is common enough to have '
      'a medical name, tokophobia, and it exists on a spectrum from '
      'ordinary nervousness to fear strong enough to affect sleep and mood. '
      'Wherever you sit on it, you are far from the only one there.\n\n'
      'Much of the fear comes from not knowing what to expect, or from '
      'stories other people have told you, which are rarely a fair sample '
      'of what labour is actually like. Preparation genuinely helps here in '
      'a way it does not for every fear: understanding what will actually '
      'happen, stage by stage, and knowing pain relief is a real, available '
      'choice, both reduce the fear itself.\n\n'
      'If the fear is strong enough that you are avoiding thinking about '
      'the birth altogether, or it is affecting your sleep most nights, '
      'that is worth raising with your doctor directly, and worth talking '
      'through with a counsellor. Both exist for exactly this.',
    ),
  ),
  MmArticle(
    id: 'fear_something_wrong',
    group: MmArticleGroup.fears,
    title: _en('Fear something is wrong with the baby'),
    teaser: _en('A worry that sits underneath everything, even when every '
        'scan has been fine.'),
    readingTime: _en('4 MIN'),
    hasExpertVideo: true,
    hasStoryVideo: true,
    body: _en(
      'Almost every pregnant woman carries some version of this fear, even '
      'after a string of reassuring scans and appointments. It is one of '
      'the most universal pregnancy fears there is, precisely because so '
      'much of what happens inside you cannot be seen or felt directly.\n\n'
      'The scans and checks in your calendar exist to catch what genuinely '
      'needs catching, and a clear scan is real evidence, not a temporary '
      'reprieve before the next worry. It is normal for the reassurance to '
      'fade after a few days and the worry to creep back. That cycle is the '
      'fear itself, not a sign something has actually changed.\n\n'
      'If this worry is taking up hours of most days, or sending you back '
      'to search engines repeatedly for reassurance that never quite lands, '
      '"Health anxiety and over-Googling" and "Pregnancy anxiety" both go '
      'further into this.',
    ),
  ),
  MmArticle(
    id: 'fear_miscarriage',
    group: MmArticleGroup.fears,
    title: _en('Fear of miscarriage'),
    teaser: _en('Especially sharp in the early weeks, and especially if you '
        'have been through loss before.'),
    readingTime: _en('4 MIN'),
    hasExpertVideo: true,
    hasStoryVideo: true,
    body: _en(
      'Fear of loss is at its sharpest in the first trimester, and sharper '
      'still for anyone who has miscarried before or spent a long time '
      'trying to conceive. Checking for symptoms constantly, or bracing '
      'yourself against getting attached, are both common ways this fear '
      'shows up.\n\n'
      'It usually eases as the pregnancy progresses and the risk itself '
      'genuinely falls, though for some women it lingers well past the '
      'point where the numbers would suggest it should. That is a real '
      'experience, not an overreaction.\n\n'
      'There is nothing you did, or are doing, that causes or prevents a '
      'miscarriage in the vast majority of cases, and that fact is worth '
      'returning to when the fear speaks in the language of blame. If it '
      'is affecting your ability to function day to day, please talk to '
      'your doctor and consider a counsellor alongside them.',
    ),
  ),
  MmArticle(
    id: 'fear_not_good_mother',
    group: MmArticleGroup.fears,
    title: _en('Fear of not being a good mother'),
    teaser: _en('"What if I am not cut out for this." Nearly every mother '
        'has thought it.'),
    readingTime: _en('4 MIN'),
    hasExpertVideo: true,
    hasStoryVideo: true,
    body: _en(
      'This fear is close to universal and rarely spoken about, because it '
      'feels like admitting a weakness rather than what it actually is: a '
      'sign that you care enough to worry about getting this right.\n\n'
      'There is no version of motherhood that arrives fully formed on day '
      'one. It is learned, mostly on the job, by every mother who has ever '
      'done it, including the ones who look most certain from the outside.\n\n'
      'If this fear is paired with a persistent sense of dread about the '
      'baby arriving at all, rather than ordinary nerves, that combination '
      'is worth reading about in "Antenatal depression" and "Pregnancy '
      'anxiety".',
    ),
  ),
  MmArticle(
    id: 'fear_body_changes',
    group: MmArticleGroup.fears,
    title: _en('Fear of body changes'),
    teaser: _en('Worry about how your body will look, feel, or work, both '
        'now and after.'),
    readingTime: _en('4 MIN'),
    hasExpertVideo: true,
    hasStoryVideo: true,
    body: _en(
      'Fear about how your body is changing, and whether it will feel like '
      'yours again afterwards, is common and rarely acknowledged out loud, '
      'partly because it can feel shallow to admit next to the "bigger" '
      'worries of pregnancy. It is not shallow. Your body is genuinely '
      'changing in ways that are visible, permanent in some respects, and '
      'entirely outside your control.\n\n'
      'Most physical changes soften considerably over the months after '
      'birth, though the timeline and the outcome differ for every woman, '
      'and comparing yourself to anyone else, including your own '
      'pre-pregnancy body, rarely helps.\n\n'
      '"Body image and self-esteem" in Everyday emotional care goes '
      'further into living with this day to day.',
    ),
  ),
  MmArticle(
    id: 'health_anxiety_googling',
    group: MmArticleGroup.fears,
    title: _en('Health anxiety and over-Googling'),
    teaser: _en('Searching a symptom at midnight, and feeling worse an hour '
        'later, not better.'),
    readingTime: _en('4 MIN'),
    hasExpertVideo: true,
    hasStoryVideo: true,
    body: _en(
      'Searching a symptom is a reasonable instinct, and pregnancy makes '
      'it more tempting than ever because so much feels new and '
      'unfamiliar. The trouble is what search results actually contain: '
      'the rarest, most frightening explanation is often the loudest one '
      'on the page, which is the opposite of how likely it actually is.\n\n'
      'A pattern worth noticing in yourself is searching that does not '
      'stop at one answer, but keeps going, page after page, late into the '
      'night, chasing a reassurance that never quite arrives. That pattern '
      'is the anxiety talking, not the symptom.\n\n'
      'Ask Veda in the Talk tab exists partly for this: a calmer place to '
      'ask a worry out loud, with a clear steer to a real person whenever '
      'the question is serious enough to need one.',
    ),
  ),

  // ---------------------------------------------------------------------------
  //  When it is more than a mood - 6
  //  ⚠️ REQUIRED_REVIEW on every article below. Draft wording only.
  // ---------------------------------------------------------------------------
  MmArticle(
    id: 'antenatal_depression',
    group: MmArticleGroup.moreThanMood,
    title: _en('Antenatal depression'),
    teaser: _en('When low mood in pregnancy lasts, rather than lifts.'),
    readingTime: _en('5 MIN'),
    hasExpertVideo: true,
    requiresReview: true,
    body: _en(
      'Depression during pregnancy is more common than most people expect, '
      'and it is treatable. It is not a sign of weakness, and it is not '
      'something you can simply decide your way out of.',
    ),
    whatItIs: _en('A low mood that stays, most of most days, for two weeks '
        'or more, rather than a difficult day or two that passes. It can '
        'sit alongside excitement about the baby, not instead of it, which '
        'is part of why it is easy to miss in pregnancy.'),
    signsToNotice: _en('A flatness or heaviness that does not lift, losing '
        'interest in things you normally enjoy, changes in appetite or '
        'sleep beyond what pregnancy alone explains, feeling worthless or '
        'excessively guilty, or finding it hard to concentrate or make '
        'decisions.'),
    howToGetHelp: _en('This is worth saying out loud to your doctor at your '
        'next appointment, and it is exactly what perinatal counselling in '
        'the Talk tab is built for. Neither conversation requires you to '
        'have the words exactly right first.'),
  ),
  MmArticle(
    id: 'pregnancy_anxiety',
    group: MmArticleGroup.moreThanMood,
    title: _en('Pregnancy anxiety'),
    teaser: _en('When worry becomes near constant, rather than something '
        'that comes and goes.'),
    readingTime: _en('5 MIN'),
    hasExpertVideo: true,
    requiresReview: true,
    body: _en(
      'Some worry in pregnancy is expected and even useful, it is what '
      'gets you to appointments on time. Anxiety becomes its own thing '
      'when the worry stops responding to reassurance and starts running '
      'the day.',
    ),
    whatItIs: _en('A pattern of worry that is hard to switch off, often '
        'about the baby\'s health or the birth, that keeps returning even '
        'after a scan or a doctor\'s reassurance should have settled it.'),
    signsToNotice: _en('Restlessness, a racing heart or tight chest without '
        'a physical cause, trouble sleeping because your mind will not '
        'quiet, avoiding things that trigger the worry, or seeking '
        'reassurance again and again without it ever feeling like enough.'),
    howToGetHelp: _en('A perinatal counsellor can teach specific ways to '
        'interrupt this pattern, which is different from simply being told '
        'to stop worrying. Booking one is in the Talk tab, and it is '
        'anonymous.'),
  ),
  MmArticle(
    id: 'panic_attacks',
    group: MmArticleGroup.moreThanMood,
    title: _en('Panic attacks'),
    teaser: _en('A sudden wave of fear with real physical symptoms. '
        'Frightening, and not dangerous in itself.'),
    readingTime: _en('4 MIN'),
    hasExpertVideo: true,
    requiresReview: true,
    body: _en(
      'A panic attack can feel like something is seriously physically '
      'wrong, a racing heart, tight chest, shaking, a feeling of unreality. '
      'It is intensely unpleasant and, on its own, not dangerous to you or '
      'your baby.',
    ),
    whatItIs: _en('A sudden, sharp surge of fear that peaks within minutes, '
        'usually with strong physical symptoms, and then eases. It can '
        'happen with no obvious trigger.'),
    signsToNotice: _en('A pounding heart, shortness of breath, dizziness, '
        'trembling, a feeling of choking or unreality, or a sudden fear '
        'that something terrible is about to happen, all arriving together '
        'and quickly.'),
    howToGetHelp: _en('The Calm-now flow in the Feel tab is built for the '
        'moment itself. If panic attacks are happening more than once, '
        'mention it to your doctor and consider talking it through with a '
        'perinatal counsellor.'),
  ),
  MmArticle(
    id: 'intrusive_thoughts',
    group: MmArticleGroup.moreThanMood,
    title: _en('Intrusive thoughts'),
    teaser: _en('Sudden, unwanted, frightening thoughts about the baby. '
        'More common than almost anyone admits.'),
    readingTime: _en('5 MIN'),
    hasExpertVideo: true,
    requiresReview: true,
    body: _en(
      'Many pregnant and new mothers experience sudden, unwanted thoughts '
      'about something bad happening to the baby, thoughts they would '
      'never act on and that frighten them precisely because they seem to '
      'come from nowhere. These are far more common than they are talked '
      'about, and having them does not mean you would ever act on them, or '
      'that you are a danger to your baby.',
    ),
    whatItIs: _en('An unwanted thought or image that arrives suddenly, '
        'feels completely against your own values, and that you do not '
        'want and would never choose to act on. The distress it causes is '
        'itself a sign it is not a real intention.'),
    signsToNotice: _en('The thoughts repeat, cause real distress or shame, '
        'or lead to avoiding the baby or situations connected to the '
        'thought altogether.'),
    howToGetHelp: _en('Please say this out loud to your doctor or a '
        'perinatal counsellor rather than carrying it alone. It is a known, '
        'treatable experience, and naming it plainly is usually the '
        'hardest and most relieving part.'),
  ),
  MmArticle(
    id: 'baby_blues',
    group: MmArticleGroup.moreThanMood,
    title: _en('Baby blues (looking ahead)'),
    teaser: _en('The dip most mothers feel in the first two weeks after '
        'birth. Common, and it passes.'),
    readingTime: _en('4 MIN'),
    requiresReview: true,
    body: _en(
      'This is written for later, so it is here to recognise rather than '
      'worry about now. In the days after birth, hormone levels fall '
      'sharply and sleep is short, and most new mothers feel some version '
      'of tearfulness, mood swings or overwhelm as a result.',
    ),
    whatItIs: _en('A short dip in mood, usually starting two to four days '
        'after birth and settling within about two weeks, driven largely '
        'by the sudden hormonal drop after delivery.'),
    signsToNotice: _en('Tearfulness, irritability, feeling overwhelmed or '
        'anxious, that comes and goes and generally improves day by day.'),
    howToGetHelp: _en('If it has not started easing by around two weeks, or '
        'it is getting worse rather than better, that is the point to read '
        '"Postpartum depression" and to speak to your doctor.'),
  ),
  MmArticle(
    id: 'postpartum_depression',
    group: MmArticleGroup.moreThanMood,
    title: _en('Postpartum depression (looking ahead)'),
    teaser: _en('When the low feeling after birth does not lift on its own. '
        'Common, and treatable.'),
    readingTime: _en('5 MIN'),
    hasExpertVideo: true,
    requiresReview: true,
    body: _en(
      'Also written for later. Postpartum depression is more than the '
      'baby blues, it lasts longer, tends to be more intense, and does not '
      'ease on its own the way the blues usually do. It is one of the most '
      'common complications of childbirth, and effective help exists.',
    ),
    whatItIs: _en('A depression that develops any time in the first year '
        'after birth, most often within the first few months, that lasts '
        'more than two weeks and affects daily functioning.'),
    signsToNotice: _en('A low mood that does not lift, loss of interest in '
        'the baby or in things you used to enjoy, exhaustion beyond what '
        'new-parent tiredness explains, feeling unable to cope, or '
        'withdrawing from people who want to help.'),
    howToGetHelp: _en('Please tell your doctor or health visitor plainly, '
        'and know that a perinatal counsellor is trained specifically for '
        'this. Reaching out early tends to shorten how long it lasts, not '
        'lengthen the disruption to your life.'),
  ),

  // ---------------------------------------------------------------------------
  //  Everyday emotional care - 5
  // ---------------------------------------------------------------------------
  MmArticle(
    id: 'sleep_and_mood',
    group: MmArticleGroup.everydayCare,
    title: _en('Sleep and mood'),
    teaser: _en('Broken sleep does not just tire you out. It changes how '
        'everything else feels.'),
    readingTime: _en('3 MIN'),
    body: _en(
      'Poor sleep and low mood feed each other in both directions: '
      'tiredness makes everything feel harder to cope with, and a mind '
      'full of worry makes it harder to fall asleep in the first place. '
      'Pregnancy disrupts sleep for very physical reasons too, an '
      'uncomfortable body, frequent trips to the bathroom, a baby who is '
      'more active at night than in the day.\n\n'
      'Protecting what sleep you can, a consistent wind-down, a cool dark '
      'room, less screen time before bed, is worth more than it sounds '
      'like it should. The Falling asleep meditation in the Feel tab is '
      'built for exactly this.\n\n'
      'If lying awake with a racing mind is a near-nightly pattern, that '
      'crosses from ordinary discomfort into something worth mentioning to '
      'your doctor.',
    ),
  ),
  MmArticle(
    id: 'unsolicited_advice_family_pressure',
    group: MmArticleGroup.everydayCare,
    title: _en('Unsolicited advice and family pressure'),
    teaser: _en('Everyone has an opinion on your pregnancy, and not all of '
        'it was asked for.'),
    readingTime: _en('4 MIN'),
    body: _en(
      'In many Indian families, pregnancy is treated as a family event as '
      'much as a personal one, which brings real support and also a great '
      'deal of advice you did not ask for, on everything from what to eat '
      'to how to sleep to when to have another. It can wear you down even '
      'when it comes from love.\n\n'
      'A short, warm, repeatable line helps more than a long explanation: '
      '"Thank you, I will talk to my doctor about that." It closes the '
      'conversation without a confrontation.\n\n'
      'It is fair to protect your own decisions, especially anything '
      'medical, even from people who mean well. You are allowed to say '
      'thank you and still do it your way.',
    ),
  ),
  MmArticle(
    id: 'work_stress',
    group: MmArticleGroup.everydayCare,
    title: _en('Work stress'),
    teaser: _en('Managing a job and a pregnancy at the same time, without '
        'either one being told the truth about the other.'),
    readingTime: _en('3 MIN'),
    body: _en(
      'Deciding when to tell your workplace, how much to say, and how to '
      'manage energy that is genuinely lower than usual, all add a layer '
      'of stress on top of the pregnancy itself. It is common to feel torn '
      'between wanting to perform as normal and needing real '
      'accommodation.\n\n'
      'Knowing your maternity leave and workplace rights ahead of time '
      'tends to lower the anxiety around the conversation, even before you '
      'have it.\n\n'
      'A short rest during the day, even ten minutes with your eyes '
      'closed, genuinely changes how the rest of the day feels. It is not '
      'a small thing, even when it looks like one.',
    ),
  ),
  MmArticle(
    id: 'relationship_intimacy_changes',
    group: MmArticleGroup.everydayCare,
    title: _en('Relationship and intimacy changes'),
    teaser: _en('Pregnancy changes a partnership too, not just a body.'),
    readingTime: _en('4 MIN'),
    body: _en(
      'It is common for desire, energy and closeness with a partner to '
      'shift during pregnancy, in both directions, some couples feel '
      'closer than ever and some feel more distant. Neither is a sign the '
      'relationship is in trouble.\n\n'
      'A change in physical intimacy is often about comfort, tiredness and '
      'a body that feels unfamiliar, rather than about the relationship '
      'itself, and saying that plainly to a partner usually helps more '
      'than either of you guessing.\n\n'
      'A partner can feel unsure how to help, or sidelined by how much '
      'attention the pregnancy naturally takes. A short, direct '
      'conversation about what you each need tends to close that gap '
      'faster than either of you working it out alone.',
    ),
  ),
  MmArticle(
    id: 'body_image_self_esteem',
    group: MmArticleGroup.everydayCare,
    title: _en('Body image and self-esteem'),
    teaser: _en('Learning to live in a body that is changing week by week, '
        'whether you feel ready or not.'),
    readingTime: _en('4 MIN'),
    body: _en(
      'A changing body can bring pride and discomfort at the same time, '
      'often within the same day. Both are allowed to be true together, '
      'and neither cancels the other out.\n\n'
      'Comparison is usually the sharpest edge here, to other pregnant '
      'women, to your own pre-pregnancy body, to images online that are '
      'rarely the ordinary version of anything. Your body is doing '
      'something enormous, and it is allowed to look and feel different '
      'while it does.\n\n'
      'If body image is affecting how you eat, or bringing up feelings '
      'that feel bigger than the moment, that is worth a gentle '
      'conversation with your doctor or a counsellor, not something to '
      'push through alone.',
    ),
  ),
];

// =============================================================================
//  Talk - paid offerings (the ONLY paid layer in this section)
// =============================================================================

enum MmTalkOfferingKind { counselling, consultation, checkin }

class MmTalkOffering {
  const MmTalkOffering({
    required this.id,
    required this.kind,
    required this.title,
    required this.whoFor,
    required this.description,
    required this.priceUsd,
    required this.priceInr,
    required this.priceUnit,
    this.anonymous = false,
  });

  final String id;
  final MmTalkOfferingKind kind;
  final LocalizedText title;

  /// "Who this is for" - required by the spec on every paid card.
  final LocalizedText whoFor;
  final LocalizedText description;

  final double priceUsd;
  final double priceInr;

  /// "per session", "per month" - appended after the price.
  final LocalizedText priceUnit;

  /// The counselling offering keeps its anonymity promise visible on the
  /// card itself, not buried in a details screen.
  final bool anonymous;
}

final List<MmTalkOffering> kMmTalkOfferings = [
  MmTalkOffering(
    id: 'perinatal_counselling',
    kind: MmTalkOfferingKind.counselling,
    title: _en('Perinatal mental-health counselling'),
    whoFor: _en('For anyone who wants to talk to a trained professional '
        'about how pregnancy is affecting their mind, not just their '
        'body.'),
    description: _en('One-on-one sessions with a counsellor trained '
        'specifically in pregnancy and early motherhood. Always '
        'anonymous, always at your pace.'),
    priceUsd: 25,
    priceInr: 999,
    priceUnit: _en('per session'),
    anonymous: true,
  ),
  MmTalkOffering(
    id: 'one_on_one_consultation',
    kind: MmTalkOfferingKind.consultation,
    title: _en('One-on-one consultation'),
    whoFor: _en('For a specific worry you want to talk through once, '
        'rather than an ongoing relationship with a counsellor.'),
    description: _en('A single, focused session to talk through what is on '
        'your mind right now, with clear next steps at the end.'),
    priceUsd: 18,
    priceInr: 749,
    priceUnit: _en('per session'),
  ),
  MmTalkOffering(
    id: 'ongoing_checkin',
    kind: MmTalkOfferingKind.checkin,
    title: _en('Ongoing check-in package'),
    whoFor: _en('For anyone who wants steady support across the rest of '
        'the pregnancy, not just a one-off conversation.'),
    description: _en('A short check-in call every two weeks with the same '
        'counsellor, so you never have to start from the beginning again.'),
    priceUsd: 79,
    priceInr: 3299,
    priceUnit: _en('per month'),
  ),
];

// =============================================================================
//  Talk - self-check screener
// -----------------------------------------------------------------------------
//  ⚠️ REQUIRED_REVIEW ON THE ENTIRE QUESTION SET BELOW. Draft wording only -
//  a perinatal counsellor must approve exact phrasing before this ships,
//  question by question. Severity values (0-3) are NEVER shown to her, and
//  the total is NEVER shown as a number - only `MmScreener.guidanceFor`
//  reads it, and it returns a sentence.
// =============================================================================

class MmScreenerOption {
  const MmScreenerOption(this.label, this.severity);
  final LocalizedText label;

  /// 0 (not at all) .. 3 (most days) - private, never rendered as a number.
  final int severity;
}

class MmScreenerQuestion {
  const MmScreenerQuestion(this.id, this.prompt, this.options,
      {this.isSafetyQuestion = false});
  final String id;
  final LocalizedText prompt;
  final List<MmScreenerOption> options;

  /// The one question whose top-severity answer routes straight to the
  /// crisis path rather than into the ordinary guidance tiers - see
  /// `MindMoodStore` / `mm_talk_tab.dart`. There is exactly one of these by
  /// design: a screener that treats every question as a safety question
  /// stops being a soft check-in.
  final bool isSafetyQuestion;
}

/// REQUIRED_REVIEW - four soft frequency options, reused across questions so
/// the screener never reads like a clinical instrument.
const List<MmScreenerOption> _kFreqOptions = [
  MmScreenerOption(LocalizedText(en: 'Not really', hi: 'Not really'), 0),
  MmScreenerOption(LocalizedText(en: 'Sometimes', hi: 'Sometimes'), 1),
  MmScreenerOption(LocalizedText(en: 'Often', hi: 'Often'), 2),
  MmScreenerOption(LocalizedText(en: 'Most days', hi: 'Most days'), 3),
];

final List<MmScreenerQuestion> kMmScreenerQuestions = [
  MmScreenerQuestion(
    'q_low_mood',
    _en('Lately, have you been feeling low or down for a lot of the day?'),
    _kFreqOptions,
  ),
  MmScreenerQuestion(
    'q_enjoyment',
    _en('Have the things you normally enjoy stopped feeling enjoyable?'),
    _kFreqOptions,
  ),
  MmScreenerQuestion(
    'q_worry',
    _en('Has worry been hard to switch off, even when you try to relax?'),
    _kFreqOptions,
  ),
  MmScreenerQuestion(
    'q_sleep',
    _en('Setting aside physical discomfort, has your mind been keeping you '
        'from sleeping?'),
    _kFreqOptions,
  ),
  MmScreenerQuestion(
    'q_coping',
    _en('Have you felt like you are not coping, more than you would expect '
        'to?'),
    _kFreqOptions,
  ),
  // ⚠️ THE SAFETY QUESTION. REQUIRED_REVIEW - a counsellor must approve this
  // exact wording; it is the most important sentence in this file. Its top
  // option routes straight to the crisis path.
  MmScreenerQuestion(
    'q_safety',
    _en('Have you had thoughts of harming yourself, or that you or your '
        'baby would be better off without you?'),
    const [
      MmScreenerOption(LocalizedText(en: 'Not at all', hi: 'Not at all'), 0),
      MmScreenerOption(LocalizedText(en: 'A fleeting thought', hi: 'A fleeting thought'), 1),
      MmScreenerOption(LocalizedText(en: 'Yes, more than once', hi: 'Yes, more than once'), 2),
      MmScreenerOption(LocalizedText(en: 'Yes, and it frightens me', hi: 'Yes, and it frightens me'), 3),
    ],
    isSafetyQuestion: true,
  ),
];

/// Guidance tiers - supportive prose only, NEVER a number, NEVER a diagnosis.
/// ⚠️ REQUIRED_REVIEW.
LocalizedText mmScreenerGuidance(int totalSeverity) {
  if (totalSeverity <= 4) {
    return _en('What you have described sounds like an ordinary, hard '
        'stretch of pregnancy, the kind most mothers go through. The Feel '
        'tab has tools built for exactly this, and they are worth trying '
        'when it flares up.');
  }
  if (totalSeverity <= 9) {
    return _en('What you have described has been sitting with you for a '
        'while now. It might help to talk it through with someone who '
        'knows pregnancy and mood well, rather than carrying it alone. '
        'Perinatal counselling, in the Talk tab, is anonymous and built '
        'for exactly this.');
  }
  return _en('Thank you for answering honestly. What you have described is '
      'worth talking through with someone soon, both a counsellor and your '
      'doctor. Reaching out now tends to make this shorter to move '
      'through, not longer.');
}

// =============================================================================
//  Track - mood check-in (no streaks, no scores, no missed-day guilt)
// =============================================================================

class MmMoodOption {
  const MmMoodOption(this.id, this.label, this.tone);
  final String id;
  final LocalizedText label;

  /// 1 (heaviest) .. 5 (lightest) - private, drives the pattern nudge only.
  /// Never shown to her as a number.
  final int tone;
}

/// Five warm words, not a 1-5 scale she would ever see as a scale.
const List<MmMoodOption> kMmMoodOptions = [
  MmMoodOption('heavy', LocalizedText(en: 'Heavy', hi: 'Heavy'), 1),
  MmMoodOption('tender', LocalizedText(en: 'Tender', hi: 'Tender'), 2),
  MmMoodOption('steady', LocalizedText(en: 'Steady', hi: 'Steady'), 3),
  MmMoodOption('light', LocalizedText(en: 'Light', hi: 'Light'), 4),
  MmMoodOption('bright', LocalizedText(en: 'Bright', hi: 'Bright'), 5),
];

MmMoodOption mmMoodOption(String id) =>
    kMmMoodOptions.firstWhere((m) => m.id == id,
        orElse: () => kMmMoodOptions[2]);

// =============================================================================
//  Track - worry journal prompts
// =============================================================================

const List<LocalizedText> kMmJournalPrompts = [
  LocalizedText(
      en: 'What am I afraid of today?', hi: 'What am I afraid of today?'),
  LocalizedText(
      en: 'What went okay today?', hi: 'What went okay today?'),
  LocalizedText(
      en: 'What do I need right now?', hi: 'What do I need right now?'),
];

/// A heuristic safety net, not a diagnosis and not a keyword blocklist for
/// her words - it only ever ADDS a gentle offer of the crisis path after she
/// has already saved her entry; it never edits, blocks or judges what she
/// wrote. Deliberately short and plain rather than clever, because a missed
/// signal here is worse than an occasional over-trigger.
const List<String> kMmJournalSafetySignals = [
  'kill myself',
  'end my life',
  'want to die',
  'better off dead',
  'better off without me',
  'not want to live',
  'not want to be alive',
  'hurt myself',
  'harm myself',
  'suicide',
];

bool mmTextHasSafetySignal(String text) {
  final t = text.toLowerCase();
  return kMmJournalSafetySignals.any((s) => t.contains(s));
}

// =============================================================================
//  MindMoodStore - mood check-ins + worry journal
// -----------------------------------------------------------------------------
//  Local-only, shared_preferences, fire-and-forget saves - mirrors
//  `ReadToBabySavedStore`. Deliberately no cloud sync: nothing in the spec
//  asked for it, and a mood/journal store is exactly the kind of thing that
//  should not gain a network dependency casually. If cross-device sync is
//  wanted later, follow `CloudSyncedStore` the way `ReadToBabySavedStore`
//  does - the shape here is already close to it.
// =============================================================================

class MmMoodEntry {
  const MmMoodEntry({required this.dateKey, required this.moodId, required this.ts});

  /// "2026-08-17" - one entry per day, keyed by this, not by timestamp. A
  /// second check-in on the same day OVERWRITES rather than adding a second
  /// row, which is what keeps this un-gamified: there is no "checked in
  /// twice today" to feel good about.
  final String dateKey;
  final String moodId;
  final int ts;

  Map<String, dynamic> toJson() => {'d': dateKey, 'm': moodId, 't': ts};
  factory MmMoodEntry.fromJson(Map<String, dynamic> j) => MmMoodEntry(
        dateKey: j['d'] as String? ?? '',
        moodId: j['m'] as String? ?? 'steady',
        ts: (j['t'] as num?)?.toInt() ?? 0,
      );
}

class MmJournalEntry {
  const MmJournalEntry(
      {required this.id, required this.ts, required this.text, this.promptId});
  final String id;
  final int ts;
  final String text;
  final String? promptId;

  Map<String, dynamic> toJson() =>
      {'id': id, 't': ts, 'x': text, if (promptId != null) 'p': promptId};
  factory MmJournalEntry.fromJson(Map<String, dynamic> j) => MmJournalEntry(
        id: j['id'] as String? ?? '',
        ts: (j['t'] as num?)?.toInt() ?? 0,
        text: j['x'] as String? ?? '',
        promptId: j['p'] as String?,
      );
}

/// What the Track tab's "mood patterns" section reads. Two independent
/// signals, both derived from the same recent history, and both rendered as
/// prose - never a chart with numbers, never a percentage.
class MmMoodTrend {
  const MmMoodTrend({
    required this.hasEnoughData,
    required this.recentTones, // oldest -> newest, for the gentle dot row
    required this.softNudge,
    required this.severeSignal,
  });

  final bool hasEnoughData;
  final List<int> recentTones;

  /// "This has been a hard stretch. Talking to someone can help." - links to
  /// counselling, NEVER the crisis path, NEVER a diagnosis.
  final bool softNudge;

  /// A sustained run of the heaviest tone only - strong enough that, in
  /// addition to the soft nudge, the crisis path is offered too. Still not a
  /// diagnosis - it is a signal, and the crisis screen never labels her.
  final bool severeSignal;
}

class MindMoodStore extends ChangeNotifier {
  MindMoodStore._();
  static final MindMoodStore instance = MindMoodStore._();

  static const _moodKey = 'mm_mood_entries';
  static const _journalKey = 'mm_journal_entries';

  final List<MmMoodEntry> _moods = [];
  final List<MmJournalEntry> _journal = [];
  bool _loaded = false;

  /// SOS opens, most recent last. Deliberately in-memory only - a 15-minute
  /// window does not need to survive an app restart, and persisting it would
  /// mean writing to disk every time she reaches for calm, for no benefit.
  final List<DateTime> _sosOpens = [];

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawMoods = prefs.getString(_moodKey);
      if (rawMoods != null) {
        for (final e in (jsonDecode(rawMoods) as List)) {
          _moods.add(MmMoodEntry.fromJson(Map<String, dynamic>.from(e)));
        }
      }
      final rawJournal = prefs.getString(_journalKey);
      if (rawJournal != null) {
        for (final e in (jsonDecode(rawJournal) as List)) {
          _journal.add(MmJournalEntry.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
  }

  // --- mood check-in ---------------------------------------------------------

  String _todayKey([DateTime? now]) {
    final n = now ?? DateTime.now();
    return '${n.year.toString().padLeft(4, '0')}-'
        '${n.month.toString().padLeft(2, '0')}-'
        '${n.day.toString().padLeft(2, '0')}';
  }

  String? get todayMoodId {
    final key = _todayKey();
    for (final m in _moods) {
      if (m.dateKey == key) return m.moodId;
    }
    return null;
  }

  void logMood(String moodId) {
    final key = _todayKey();
    _moods.removeWhere((m) => m.dateKey == key);
    _moods.add(MmMoodEntry(
        dateKey: key, moodId: moodId, ts: DateTime.now().millisecondsSinceEpoch));
    notifyListeners();
    _persistMoods();
  }

  /// Newest first.
  List<MmMoodEntry> moodHistory({int limit = 30}) {
    final l = [..._moods]..sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return l.take(limit).toList();
  }

  /// §Track - "here is how your last few weeks have felt", plus the two
  /// nudge signals. Looks at up to the last 14 check-ins.
  MmMoodTrend get trend {
    final recent = moodHistory(limit: 14).reversed.toList(); // oldest->newest
    if (recent.length < 5) {
      return const MmMoodTrend(
          hasEnoughData: false,
          recentTones: [],
          softNudge: false,
          severeSignal: false);
    }
    final tones = recent.map((e) => mmMoodOption(e.moodId).tone).toList();
    final heavyCount = tones.where((t) => t <= 2).length;
    final softNudge = heavyCount / tones.length >= 0.7;

    // Severe: the heaviest tone, unbroken, for the last 7 or more check-ins.
    final lastSeven = tones.length >= 7 ? tones.sublist(tones.length - 7) : const <int>[];
    final severeSignal =
        lastSeven.length >= 7 && lastSeven.every((t) => t == 1);

    return MmMoodTrend(
      hasEnoughData: true,
      recentTones: tones,
      softNudge: softNudge,
      severeSignal: severeSignal,
    );
  }

  Future<void> _persistMoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _moodKey, jsonEncode(_moods.map((e) => e.toJson()).toList()));
    } catch (_) {/* best-effort, local-first */}
  }

  // --- worry journal -----------------------------------------------------

  /// Newest first.
  List<MmJournalEntry> get journalEntries {
    final l = [..._journal]..sort((a, b) => b.ts.compareTo(a.ts));
    return l;
  }

  /// Returns true when the text carries a safety signal, so the caller can
  /// gently offer the crisis path right after saving - never blocking the
  /// save itself, and never editing what she wrote.
  bool addJournalEntry(String text, {String? promptId}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    final entry = MmJournalEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      ts: DateTime.now().millisecondsSinceEpoch,
      text: trimmed,
      promptId: promptId,
    );
    _journal.add(entry);
    notifyListeners();
    _persistJournal();
    return mmTextHasSafetySignal(trimmed);
  }

  /// Rewrite an entry she has already saved.
  ///
  /// ⚠️ EDIT EXISTED IN THE BRIEF AND NOT IN THE CODE. The journal could write,
  /// save, view and delete; §9.3 asks for edit too, and its absence is not a
  /// small omission on this particular feature. Without it, fixing one word in
  /// a private entry means deleting the whole thing and typing it again, which
  /// on a page holding a bad night's thoughts is a real cost.
  ///
  /// ⚠️ THE TIMESTAMP DOES NOT MOVE. The entry keeps the date she wrote it,
  /// not the date she corrected a typo, or an edit would silently reorder her
  /// journal and change what "Tuesday" refers to.
  ///
  /// Returns the same safety-signal answer as `addJournalEntry`, because an
  /// edit can introduce one that the original did not carry.
  bool updateJournalEntry(String id, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    final i = _journal.indexWhere((e) => e.id == id);
    if (i < 0) return false;
    final old = _journal[i];
    _journal[i] = MmJournalEntry(
      id: old.id,
      ts: old.ts,
      text: trimmed,
      promptId: old.promptId,
    );
    notifyListeners();
    _persistJournal();
    return mmTextHasSafetySignal(trimmed);
  }

  void deleteJournalEntry(String id) {
    _journal.removeWhere((e) => e.id == id);
    notifyListeners();
    _persistJournal();
  }

  Future<void> _persistJournal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _journalKey, jsonEncode(_journal.map((e) => e.toJson()).toList()));
    } catch (_) {/* best-effort, local-first */}
  }

  // --- SOS repeat detection ------------------------------------------------

  /// Call every time the Calm-now / SOS flow is opened. Returns true the
  /// moment this open crosses [kMmSosRepeatThreshold] within [kMmSosWindow]
  /// - the caller surfaces the crisis path once the grounding flow finishes.
  bool registerSosOpen() {
    final now = DateTime.now();
    _sosOpens.add(now);
    _sosOpens.removeWhere((t) => now.difference(t) > kMmSosWindow);
    return _sosOpens.length >= kMmSosRepeatThreshold;
  }
}
