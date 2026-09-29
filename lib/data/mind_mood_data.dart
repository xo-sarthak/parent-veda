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
//
//  Rewritten 2026-09-29 to docs/PREG-VOICE.md (the pregnancy warmth pass):
//  every read, tile line and prompt below speaks to her in short sentences
//  with contractions, and every read gains a `shortAnswer`. Facts, warning
//  signs, helpline names and numbers are unchanged. Where a read is marked
//  "REBUILT ... VERBATIM" below, that was the 2026-09-12 brief's copy; the
//  wording is now this pass's, the substance is the brief's.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_language.dart';
import '../models/breath_pattern.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// =============================================================================
//  The crisis helpline - ONE constant, so a placeholder can never ship quietly
// =============================================================================
//  ⚠️ STILL REQUIRED_TO_CONFIRM. Verified against public sources on
//  2026-08-20; NOT yet confirmed by the product owner. Do not treat the
//  research below as sign-off.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THIS WAS KIRAN (1800-599-0019) AND KIRAN HAS BEEN MERGED AWAY.
//  ---------------------------------------------------------------------------
//  KIRAN was real when it was wired here - a Ministry of Social Justice
//  helpline launched in 2020 - which is why the first pass used it rather than
//  inventing a number. It has since been merged into Tele-MANAS, the Ministry
//  of Health's national programme, and government portals now redirect KIRAN's
//  number to it.
//
//  ⚠️ THAT IS THE WHOLE ARGUMENT FOR CHECKING A HELPLINE RATHER THAN TRUSTING
//  ONE. Nothing in this repo could have caught it. The number was real, the
//  constant was correct, the screen worked, no test could fail - and a woman
//  in crisis would have been dialling a service that had been folded into
//  another one. A helpline is the one constant in an app that can go stale
//  without anybody touching the code.
//
//  ---------------------------------------------------------------------------
//  WHY TELE-MANAS, BEYOND IT BEING THE SURVIVOR
//  ---------------------------------------------------------------------------
//    · **14416 is five digits.** KIRAN's was eleven. The number is dialled by
//      someone whose hands are shaking, from a screen she is reading through
//      tears, and short codes are what people can hold in their head long
//      enough to type. This is the single biggest practical difference.
//    · Government of India, Ministry of Health, part of the National Mental
//      Health Programme and run with NIMHANS.
//    · 24x7, free, English plus twenty-odd regional languages, which matters
//      enormously for an India-first product.
//    · It explicitly covers suicide prevention and domestic violence, not only
//      general counselling.
//
//  ⚠️ BOTH NUMBERS REACH IT AND THE SHORT ONE IS THE ONE WE DIAL. The
//  toll-free long form (1800-891-4416) is kept below because a short code can
//  fail on some VoIP and international-roaming setups, and a mother abroad or
//  on a soft-SIM must not be left with nothing.
//
//  Whoever actions the confirmation: change these constants and every crisis
//  surface in the app updates together.
//
//  Sources checked 2026-08-20: telemanas.mohfw.gov.in; PIB release
//  PRID 1866498 (launch, 10 Oct 2022); Vikaspedia's KIRAN page, which is where
//  the merge is stated.
const String kCrisisHelplineName = 'Tele-MANAS'; // REQUIRED_TO_CONFIRM
const String kCrisisHelplineNumber = '14416'; // REQUIRED_TO_CONFIRM

/// ⚠️ THE FALLBACK, NOT A SECOND OPTION ON SCREEN. Same service. Shown only
/// where the short code may not connect; offering a woman in crisis two
/// numbers to choose between is a decision she should not have to make.
const String kCrisisHelplineNumberAlt = '18008914416'; // REQUIRED_TO_CONFIRM

const String kCrisisHelplineHours =
    '24x7, free, in English and 20 Indian languages'; // REQUIRED_TO_CONFIRM

/// Kept for revert, and as the record of what was here before the merge.
// const String kCrisisHelplineNameKiran = 'KIRAN Mental Health Helpline';
// const String kCrisisHelplineNumberKiran = '18005990019';

/// India's single emergency number. Real, not a placeholder - shown only for
/// "you or your baby are in danger right now", never as the primary CTA.
const String kEmergencyNumber = '112';

/// India's ambulance number (2026-09-28). Real, not a placeholder: 108 is
/// the free emergency ambulance service in most states, and it reaches an
/// ambulance directly where 112 first reaches a call centre. Shown beside
/// [kEmergencyNumber] where the danger is medical (a door's "Go to a
/// hospital today" sheet, the Get help page), never on its own.
const String kAmbulanceNumber = '108';

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

/// The exercise's phases as the shared circle reads them. A hold after an
/// in-breath stays large; a hold after an out-breath stays small.
extension MmBreathingExerciseBreath on MmBreathingExercise {
  BreathPattern toBreathPattern() {
    final steps = <BreathStep>[];
    var large = false;
    for (final ph in phases) {
      final kind = switch (ph.action) {
        MmBreathAction.expand => BreathKind.expand,
        MmBreathAction.contract => BreathKind.contract,
        MmBreathAction.hold => large ? BreathKind.hold : BreathKind.holdEmpty,
      };
      if (ph.action == MmBreathAction.expand) large = true;
      if (ph.action == MmBreathAction.contract) large = false;
      steps.add(BreathStep(ph.label.now, ph.seconds, kind));
    }
    return BreathPattern(steps);
  }
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
    why: _en('Four equal sides give your mind something simple to hold on '
        "to. That's most of what a racing mind needs."),
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
    why: _en('The long, slow breath out does the work here. It tells your '
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
    description: _en('A gentle in, a longer out, and nothing to count under '
        'pressure. Good any time you need to slow down.'),
    why: _en('Breathing out for longer than you breathe in is one of the '
        'quickest ways to settle a body that has sped up. No holding, and '
        'nothing to get wrong.'),
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
      _en("Name 1 thing you're grateful for right now."), seconds: 10),
  MmSosStep(
      MmSosStepKind.steadying,
      _en("This feeling will move through you. You're safe, and this "
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
    subtitle: _en("A slow wind-down for a body that won't settle."),
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
    subtitle: _en("Talking to yourself the way you'd talk to a friend."),
    durationLabel: _en('9 MIN'),
  ),
  MmMeditation(
    id: 'hard_day_reset',
    title: _en('A hard-day reset'),
    subtitle: _en("For the days that just didn't go well."),
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
      required this.durationLabel,
      this.asset});
  final String id;
  final LocalizedText title;
  final LocalizedText subtitle;
  final LocalizedText durationLabel;

  /// The bundled asset path, or null while the file does not exist yet.
  ///
  /// ⚠️ NULL IS A STATE, NOT AN OVERSIGHT, and the row reads it. With an asset
  /// the row is a working player; without one it is a placeholder that occupies
  /// the same geometry and is visibly not tappable. That is the rule
  /// `pv_placeholders.dart` was written for - "what is missing is the FILE, and
  /// only the file" - applied to sound instead of to video.
  ///
  /// ⚠️ WHY A FIELD RATHER THAN A NAMING CONVENTION. The tempting version is
  /// `'audio/calm/$id.mp3'` computed on the fly, and it is wrong in the one way
  /// that matters: it can never be false. Every row would claim to be playable,
  /// and the failure would arrive as silence when a mother presses play during
  /// a panic attack. A field can say "not yet"; a convention cannot.
  ///
  /// ⚠️ THESE FOUR ARE STILL NULL - the files are not in the repo. They are
  /// destined for Cloudflare R2 with the ragas, and when they land, filling in
  /// four strings here turns four placeholders into four players with no other
  /// change. Nothing else needs touching.
  final String? asset;

  bool get isReady => asset != null;
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

/// ⚠️ THE READS' AUTHOR, ONE CONSTANT. The Mind & mood brief (2026-09-12) put
/// a named psychologist's byline on every read in the area. No such review
/// happened and the person is not on the real roster (pregnancy gap analysis,
/// P1 trust, 2026-09-29), so the byline is the honest state: the editorial
/// desk, not reviewed. The reader already draws these reads that way
/// (`pvReadFromMm`); this keeps the retired screen's copy in agreement.
/// Kept for revert, and as the record of what was claimed:
///   const String kMmReadAuthor = 'Dr Sharanya Menon';
///   const String kMmReadAuthorRole = 'Perinatal psychologist · reviewed Aug 2026';
const String kMmReadAuthor = 'ParentVeda editorial';
const String kMmReadAuthorRole = 'Mind and mood · not yet reviewed';

enum MmArticleGroup {
  isThisNormal,
  noOneTalksAbout,
  fears,
  moreThanMood,
  everydayCare,

  /// Sex and closeness (2026-09-29). Its own tab on the door, hidden by the
  /// shared-phone switch once the lead wires it.
  closeness,
}

extension MmArticleGroupMeta on MmArticleGroup {
  LocalizedText get heading => switch (this) {
        MmArticleGroup.isThisNormal => _en('Is this normal?'),
        // ⚠️ THE BRIEF'S OWN HEADING, INDIA-FIRST. Seven reads about the things
        // a pregnancy here is lived inside of — the house, the in-laws, the
        // nuskhe, log kya kahenge — that no clinical library ever names.
        MmArticleGroup.noOneTalksAbout => _en('What no one talks about'),
        MmArticleGroup.fears => _en('Fears, named and answered'),
        MmArticleGroup.moreThanMood => _en("When it's more than a mood"),
        MmArticleGroup.everydayCare => _en('Everyday emotional care'),
        MmArticleGroup.closeness => _en('Sex and closeness'),
      };

  LocalizedText get intro => switch (this) {
        MmArticleGroup.isThisNormal => _en('The feelings that take you by '
            "surprise, and almost always aren't a problem."),
        MmArticleGroup.noOneTalksAbout => _en('The parts of pregnancy here '
            'that everyone lives through and nobody writes down.'),
        MmArticleGroup.fears => _en('The worries most women carry and rarely '
            "say out loud, named here so you know you're not the only one."),
        MmArticleGroup.moreThanMood => _en('What it looks like when a feeling '
            'has become more than a passing mood, and what to do about it.'),
        // ⚠️ FIVE PAGES, NOT THE BRIEF'S EIGHT, AND THAT IS SETTLED RATHER
        // THAN OUTSTANDING. Confirmed by the product owner 2026-08-20.
        //
        // Three of the brief's topics were merged into pairs: unsolicited
        // advice with family pressure, relationship changes with intimacy
        // changes, body image with self-esteem. Each pair is genuinely one
        // conversation - a woman reading about her changing body and one
        // reading about how she feels about it are the same woman on the same
        // evening - and splitting them yields two thin pages saying the same
        // thing twice.
        //
        // Same reasoning the conditions library uses: padding a page to look
        // as complete as its neighbours is dishonest rather than thorough.
        // Do not "finish" this to eight without reopening the decision.
        MmArticleGroup.everydayCare => _en('The ordinary things that shape '
            'how you feel, day to day.'),
        MmArticleGroup.closeness => _en('Sex, desire and staying close as a '
            'couple while you are expecting.'),
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
    this.shortAnswer,
    this.hasExpertVideo = false,
    this.hasStoryVideo = false,
    this.whatItIs,
    this.signsToNotice,
    this.howToGetHelp,
    this.requiresReview = false,
    this.linkLabel,
    this.linkDoor,
    this.linkGroup,
    this.linkArticleId,
  });

  final String id;
  final MmArticleGroup group;

  /// A single cross-link at the foot of the read, where the brief asks for
  /// one — "Fear of labour" points at Labour prep, "Bringing him in" at the
  /// partner piece. One of [linkDoor] (+ optional [linkGroup]) or
  /// [linkArticleId]; never both.
  final String? linkLabel;
  final String? linkDoor;
  final String? linkGroup;
  final String? linkArticleId;
  final LocalizedText title;

  /// One line, shown on the article's card.
  final LocalizedText teaser;
  final LocalizedText readingTime; // "3 MIN"

  /// Paragraphs, separated by a blank line.
  final LocalizedText body;

  /// Two or three sentences that answer the title, shown in the reader's
  /// short-answer box (docs/PREG-VOICE.md §3, added 2026-09-29). Null renders
  /// as before. Reaches the reader through `pvReadFromMm`.
  final LocalizedText? shortAnswer;

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
    // ⚠️ REBUILT 2026-09-12 FROM THE MIND & MOOD BRIEF, VERBATIM. The
    // teaser is the read's own first sentence. The earlier body is kept
    // below, commented, for revert.
    title: _en('One minute okay, next minute not'),
    teaser: _en(
      'Why your mood can change so fast right now, and when to mention it.',
    ),
    shortAnswer: _en(
      'Fast mood changes are very common in pregnancy. Your hormones are '
      'rising quickly, and your mood moves with them. It usually settles as '
      'the weeks go on.',
    ),
    readingTime: _en('3 MIN'),
    hasStoryVideo: true,
    body: _en(
      'You were fine a moment ago. Now your eyes are wet over an advert, or '
      "you've snapped at someone who did nothing wrong.\n\n"
      "This isn't you losing control. Your body is running on more hormones "
      'than it ever has, and they change fast, so your mood changes with '
      'them. It settles as the weeks pass, and more once your baby is here.\n\n'
      'You don\'t have to explain every mood to the people around you. "I\'m '
      'alright, it\'s just one of those days" is enough.\n\n'
      "If the low moods start lasting whole days and don't lift, tell "
      'someone. The Talk tab shows you who.',
    ),
    // id: 'mood_swings',
    // group: MmArticleGroup.isThisNormal,
    // title: _en('Mood swings'),
    // teaser: _en('Up one hour, in tears the next. This is one of the most '
    //     'common things pregnancy does.'),
    // readingTime: _en('3 MIN'),
    // hasStoryVideo: true,
    // body: _en(
    //   'Your hormone levels are changing faster than at almost any other '
    //   'point in your life, and those same hormones sit close to the parts '
    //   'of the brain that manage mood. A swing from laughing to tearful in '
    //   'the space of an hour is not a sign anything is wrong with you, it is '
    //   'a sign your body is doing a lot of chemical work in a short time.\n\n'
    //   'It tends to be strongest in the first trimester, when the change is '
    //   'sharpest, and again nearer the end, when your body is preparing for '
    //   'birth. Many women find it eases in the middle months.\n\n'
    //   'What helps most is not fighting it. Naming it out loud, "I am just '
    //   'having a wobbly hour", takes some of the pressure off. If it is '
    //   'making daily life hard most days rather than some days, that is '
    //   'worth reading more about, and "When it is more than a mood" is '
    //   'where to look.',
    // ),
  ),
  MmArticle(
    id: 'crying_easily',
    group: MmArticleGroup.isThisNormal,
    // ⚠️ REBUILT 2026-09-12 FROM THE MIND & MOOD BRIEF, VERBATIM. The
    // teaser is the read's own first sentence. The earlier body is kept
    // below, commented, for revert.
    title: _en('Crying at everything'),
    teaser: _en(
      'Why tears come so easily now, and the kind of crying worth '
      'mentioning.',
    ),
    shortAnswer: _en(
      "Crying easily is normal in pregnancy, and it doesn't mean something "
      'is wrong. It usually passes in a few minutes and leaves you lighter. '
      "If it's there most days, or you can't stop, talk to someone.",
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      'Adverts, a song, the way someone looked at you, or nothing at all. '
      "The tears come easily right now, and you can't always find a reason.\n\n"
      "That's normal in pregnancy. It doesn't mean something is wrong with "
      "you, and crying isn't a problem to fix. Let it come. It usually "
      'passes in a few minutes, and you feel lighter after.\n\n'
      "What's worth watching is crying that stops feeling like a release. "
      "If it starts to feel like you can't stop, or it's there most days, "
      "it's more than hormones, and it's worth a proper talk with someone.",
    ),
    // id: 'crying_easily',
    // group: MmArticleGroup.isThisNormal,
    // title: _en('Crying easily'),
    // teaser: _en('An advert, a song, a kind word from a stranger. Any of it '
    //     'can set you off, and that is normal.'),
    // readingTime: _en('3 MIN'),
    // body: _en(
    //   'Pregnancy lowers the threshold for tears. Things that would once '
    //   'have passed you by, a song on the radio, a stranger being kind, now '
    //   'reach you faster and deeper. That is not a character change, it is '
    //   'a hormonal one, and it fades as your body settles into each stage.\n\n'
    //   'It can feel embarrassing in the moment, especially in front of '
    //   'colleagues or family who do not expect it. It does not need '
    //   'explaining every time. "I am a bit emotional today" is enough.\n\n'
    //   'The distinction worth knowing is between tears that pass and leave '
    //   'you feeling lighter, and a heaviness that does not lift. The first '
    //   'is ordinary pregnancy. The second is worth a closer look.',
    // ),
  ),
  MmArticle(
    id: 'irritability_anger',
    group: MmArticleGroup.isThisNormal,
    // ⚠️ REBUILT 2026-09-12 FROM THE MIND & MOOD BRIEF, VERBATIM. The
    // teaser is the read's own first sentence. The earlier body is kept
    // below, commented, for revert.
    title: _en('Short temper, and the guilt after'),
    teaser: _en(
      'Why you snap more easily now, and how to ask for quiet without '
      'guilt.',
    ),
    shortAnswer: _en(
      'Snapping more easily is common in pregnancy. Tiredness and hormones '
      'shorten your fuse, and the guilt afterwards shows you care. Neither '
      'makes you a bad mother-to-be.',
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      'Someone asks one more question or gives one more piece of advice, '
      'and you snap. Then you feel terrible about it for the rest of the '
      'day.\n\n'
      'The snapping is tiredness and hormones. The guilt after is you being '
      'a kind person. Neither makes you a bad mother-to-be.\n\n'
      'You\'re allowed to say, "I can\'t take advice right now. I just need a '
      'bit of quiet." You don\'t owe everyone patience while you\'re growing '
      'a whole person.\n\n'
      "If the anger is scaring you, or it's turning on you, talk to "
      "someone. There's no shame in it.",
    ),
    // id: 'irritability_anger',
    // group: MmArticleGroup.isThisNormal,
    // title: _en('Irritability and anger'),
    // teaser: _en('Snapping at people you love, over things that would '
    //     'usually not bother you.'),
    // readingTime: _en('3 MIN'),
    // body: _en(
    //   'Anger is a less-talked-about pregnancy feeling than tears, but it is '
    //   'just as common. Poor sleep, nausea, physical discomfort and the '
    //   'sheer effort of growing a baby all shorten your fuse, and hormones '
    //   'add to it.\n\n'
    //   'It often lands hardest on the people closest to you, a partner, a '
    //   'parent, because they are the ones around when the fuse runs out. '
    //   'That is not a reflection of how you feel about them.\n\n'
    //   'A short pause before responding, even ten seconds, helps more than '
    //   'it sounds like it should. If anger is frequent enough that you '
    //   'worry about it, or it frightens you, that is worth talking through '
    //   'with someone rather than managing alone.',
    // ),
  ),
  MmArticle(
    id: 'feeling_disconnected',
    group: MmArticleGroup.isThisNormal,
    // ⚠️ REBUILT 2026-09-12 FROM THE MIND & MOOD BRIEF, VERBATIM. The
    // teaser is the read's own first sentence. The earlier body is kept
    // below, commented, for revert.
    title: _en('Not feeling the bond yet'),
    teaser: _en(
      "If you don't feel that rush of love yet, you're far from the only "
      'one.',
    ),
    shortAnswer: _en(
      "Many mothers don't feel a strong bond during pregnancy, and it "
      "doesn't mean anything is missing in you. A bond grows over time, and "
      'for many women it grows after the birth.',
    ),
    readingTime: _en('4 MIN'),
    hasStoryVideo: true,
    body: _en(
      'Everyone assumes you fell in love with your baby the second you saw '
      "two lines. Some mothers do. Plenty don't, and they carry a worry "
      'that something is missing in them. Nothing is.\n\n'
      "A bond isn't a switch. It grows, and for many women it grows after "
      'the baby is born, not before. Talking to your bump or feeling the '
      "kicks doesn't have to feel special to be real. You're already doing "
      'the loving part by looking after yourself.\n\n'
      'If not feeling it is making you feel low or broken, share that '
      "feeling with someone. It's more common than anyone admits.",
    ),
    // id: 'feeling_disconnected',
    // group: MmArticleGroup.isThisNormal,
    // title: _en('Feeling disconnected from the pregnancy'),
    // teaser: _en('Not feeling the rush of love you expected, or not feeling '
    //     'much at all yet.'),
    // readingTime: _en('4 MIN'),
    // hasStoryVideo: true,
    // body: _en(
    //   'Some women feel connected to their pregnancy from the first missed '
    //   'period. Many do not, and instead feel oddly separate from it for '
    //   'weeks or months, especially before there is any movement to feel. '
    //   'Neither is more correct than the other.\n\n'
    //   'Connection often builds gradually rather than arriving all at once, '
    //   'and it is not unusual for it to properly begin after the first '
    //   'flutter of movement, or even after the birth itself. Feeling '
    //   'disconnected now says nothing about the kind of mother you will '
    //   'be.\n\n'
    //   'If it comes with a general flatness about everything, not just the '
    //   'pregnancy, that is worth reading about in "When it is more than a '
    //   'mood".',
    // ),
  ),
  MmArticle(
    id: 'guilt',
    group: MmArticleGroup.isThisNormal,
    // ⚠️ REBUILT 2026-09-12 FROM THE MIND & MOOD BRIEF, VERBATIM. The
    // teaser is the read's own first sentence. The earlier body is kept
    // below, commented, for revert.
    title: _en('The guilt that follows you around'),
    teaser: _en(
      'The wrong meal, the skipped walk: why the guilt is so loud, and why '
      "it's rarely fair.",
    ),
    shortAnswer: _en(
      "Guilt is loud in pregnancy, and it's rarely fair. One meal, one "
      "skipped walk or one bad day doesn't harm your baby. If the guilt "
      "won't stop, tell someone.",
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      'You ate the wrong thing. You skipped the walk. You felt annoyed at '
      'the baby for making you sick.\n\n'
      "Guilt in pregnancy is loud, and it's rarely fair. One meal, one bad "
      "day, or one moment of not feeling grateful doesn't harm your baby. "
      'You can get things wrong and still be a good mother.\n\n'
      "If the guilt has become a voice that won't stop, listing everything "
      "you've done wrong, please tell someone. That isn't your conscience "
      "any more, and it's something we can help with.",
    ),
    // id: 'guilt',
    // group: MmArticleGroup.isThisNormal,
    // title: _en('Guilt'),
    // teaser: _en('For resting, for not feeling grateful enough, for a hundred '
    //     'small things.'),
    // readingTime: _en('3 MIN'),
    // body: _en(
    //   'Guilt shows up in pregnancy in small, persistent ways: guilt for '
    //   'needing to rest, guilt for not enjoying every moment, guilt for a '
    //   'coffee or a bad night, guilt for feeling anything other than '
    //   'grateful. It is one of the most common feelings mothers describe and '
    //   'rarely say out loud.\n\n'
    //   'A useful question to ask it is simple: would you judge a friend this '
    //   'harshly for the same thing? Almost always the answer is no, and that '
    //   'gap between how you treat yourself and how you would treat someone '
    //   'you love is worth noticing.\n\n'
    //   'Guilt that becomes a constant background hum, rather than something '
    //   'that visits and passes, is covered in "When it is more than a '
    //   'mood".',
    // ),
  ),
  MmArticle(
    id: 'pregnancy_brain',
    group: MmArticleGroup.isThisNormal,
    // ⚠️ REBUILT 2026-09-12 FROM THE MIND & MOOD BRIEF, VERBATIM. The
    // teaser is the read's own first sentence. The earlier body is kept
    // below, commented, for revert.
    title: _en('Forgetting everything'),
    teaser: _en(
      'Walking into a room and forgetting why: what pregnancy brain is, and '
      'what helps.',
    ),
    shortAnswer: _en(
      'Forgetfulness in pregnancy is real, and people call it pregnancy '
      "brain. It isn't a sign of anything lasting, and it comes back after. "
      "It's worth a second look only if it comes with feeling low.",
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      "You walked into a room and forgot why. You've said the same thing "
      "twice. You're sure you're getting slower.\n\n"
      "This is real. People call it pregnancy brain, and it's your body "
      "putting its energy elsewhere for a while. It isn't a sign of "
      'anything lasting, and it comes back after.\n\n'
      'Write things down, keep one list, and be kind to yourself about it. '
      "It's only worth a second look if the fog comes with feeling low or "
      'not like yourself. Then it might not be the pregnancy alone.',
    ),
    // id: 'pregnancy_brain',
    // group: MmArticleGroup.isThisNormal,
    // title: _en('Pregnancy brain'),
    // teaser: _en('Forgetting words mid-sentence, walking into a room and '
    //     'losing the reason why.'),
    // readingTime: _en('3 MIN'),
    // body: _en(
    //   'Forgetfulness and foggy thinking in pregnancy are real and well '
    //   'documented, not something you are imagining or a sign of anything '
    //   'wrong. Sleep changes, hormone shifts and simply having a great deal '
    //   'on your mind all play a part.\n\n'
    //   'It tends to be most noticeable in the third trimester and usually '
    //   'improves after birth, though tiredness in the early weeks with a '
    //   'newborn can keep it going a while longer.\n\n'
    //   'Small systems help more than trying to remember harder: a note on '
    //   'your phone, keys always in the same bowl, a list by the door. It is '
    //   'a season, not a permanent change.',
    // ),
  ),
  MmArticle(
    id: 'overwhelm',
    group: MmArticleGroup.isThisNormal,
    // ⚠️ REBUILT 2026-09-12 FROM THE MIND & MOOD BRIEF, VERBATIM. The
    // teaser is the read's own first sentence. The earlier body is kept
    // below, commented, for revert.
    title: _en('When it all feels like too much'),
    teaser: _en(
      'The appointments, the advice, the worry: how to put some of it down.',
    ),
    shortAnswer: _en(
      "Feeling overwhelmed in pregnancy isn't weakness. There's a lot on "
      'you. Pick the one thing that matters today and let the rest wait, '
      'and if the feeling is there every day, reach out.',
    ),
    readingTime: _en('3 MIN'),
    hasStoryVideo: true,
    body: _en(
      'The appointments, the advice, the changes in your body, the worry '
      'about money or work or the delivery, and everyone with an opinion. '
      'Some days it piles up and you just want it all to stop for a minute.\n\n'
      "That feeling isn't weakness. It's a lot. You're allowed to put some "
      'of it down.\n\n'
      'Pick the one thing that matters today and let the rest wait. Say no '
      'to a visit. Hand something to your partner.\n\n'
      "If you feel overwhelmed every day, or you're lying awake with it, "
      "please don't sit with it alone. The Talk tab shows you who to reach.",
    ),
    // id: 'overwhelm',
    // group: MmArticleGroup.isThisNormal,
    // title: _en('Feeling overwhelmed'),
    // teaser: _en('Too much to think about, too many decisions, too little '
    //     'time to feel ready.'),
    // readingTime: _en('3 MIN'),
    // hasStoryVideo: true,
    // body: _en(
    //   'Pregnancy arrives with a long list: appointments, decisions, things '
    //   'to buy, things to learn, and often work and family to manage '
    //   'alongside all of it. Feeling overwhelmed by the sheer size of that '
    //   'list is common, and it does not mean you are not coping.\n\n'
    //   'It often helps to separate "this week" from "the whole nine months" '
    //   '. Almost nothing on the list actually needs deciding today, even '
    //   'when it feels urgent.\n\n'
    //   'If the overwhelm sits with you most of most days, rather than lifting '
    //   'once the immediate task is done, "When it is more than a mood" is '
    //   'worth a look.',
    // ),
  ),
  MmArticle(
    id: 'numb_no_joy',
    group: MmArticleGroup.isThisNormal,
    // ⚠️ REBUILT 2026-09-12 FROM THE MIND & MOOD BRIEF, VERBATIM. The
    // teaser is the read's own first sentence. The earlier body is kept
    // below, commented, for revert.
    title: _en('Numb, when everyone says you should be glowing'),
    teaser: _en(
      'Feeling flat, even trapped, when everyone expects you to be happy.',
    ),
    shortAnswer: _en(
      'Feeling flat when everyone around you is excited happens, and it '
      "isn't your fault. It doesn't mean you won't love your baby. If the "
      'numbness stays, talk to a counsellor.',
    ),
    readingTime: _en('4 MIN'),
    hasStoryVideo: true,
    body: _en(
      'Everyone is excited. The family is planning. And you feel flat, like '
      'nothing. Maybe even a bit trapped, and then guilty for feeling '
      'trapped.\n\n'
      "Feeling numb when you're supposed to be happy is one of the "
      "loneliest things in pregnancy, because you can't say it out loud "
      'without someone gasping. So here it is said plainly: it happens, it '
      "doesn't mean you won't love your baby, and it isn't your fault.\n\n"
      'Numbness that stays is one of the clearer signs that this is more '
      "than a mood. It's exactly what a counsellor is there for. Reaching "
      "out isn't giving up.",
    ),
    // id: 'numb_no_joy',
    // group: MmArticleGroup.isThisNormal,
    // title: _en('Feeling numb when you expected joy'),
    // teaser: _en('Everyone says this should be the happiest time, and you '
    //     'mostly feel nothing.'),
    // readingTime: _en('4 MIN'),
    // hasStoryVideo: true,
    // body: _en(
    //   'This one is quietly common and rarely spoken about, because '
    //   'pregnancy is supposed to feel joyful and admitting it does not can '
    //   'feel like a failure. It is not one. Feelings do not arrive on '
    //   'schedule just because an occasion calls for them.\n\n'
    //   'Numbness can come from exhaustion, from a pregnancy that followed a '
    //   'hard journey to get here, from stress elsewhere in life taking up '
    //   'all the emotional room, or simply because that is how you process '
    //   'big change.\n\n'
    //   'A flat, empty feeling that persists, rather than a quiet or delayed '
    //   'one, is worth reading about in "When it is more than a mood", '
    //   'specifically antenatal depression.',
    // ),
  ),
  MmArticle(
    id: 'loneliness',
    group: MmArticleGroup.isThisNormal,
    // ⚠️ REBUILT 2026-09-12 FROM THE MIND & MOOD BRIEF, VERBATIM. The
    // teaser is the read's own first sentence. The earlier body is kept
    // below, commented, for revert.
    title: _en('Lonely, even in a full house'),
    teaser: _en(
      'When everyone is busy with the baby and nobody asks how you are '
      'inside.',
    ),
    shortAnswer: _en(
      'Feeling alone in a house full of people is common in pregnancy. '
      "You're allowed to want to be seen, not just checked on. Tell one "
      'person what you need, or talk to someone here.',
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      "The house is full of people and you've never felt more alone. "
      'Everyone is focused on the baby, the plans and the rituals, and '
      "nobody has asked how you're doing inside.\n\n"
      "That loneliness is real, and it's common, especially when you're "
      "surrounded by people who love you but don't quite see you. You're "
      'allowed to want to be seen, not just checked on.\n\n'
      'Tell one person, the one most likely to just listen: "I don\'t need '
      'advice. I just need you to hear me today."\n\n'
      'It also helps to know someone going through the same months. A '
      'friend or cousin who is expecting, a woman from your antenatal '
      'class, or a mother you keep meeting in the hospital waiting room can '
      'become the person you message at night.\n\n'
      "If there's no one like that right now, the community and the "
      'counsellor here are for exactly this.',
    ),
    // id: 'loneliness',
    // group: MmArticleGroup.isThisNormal,
    // title: _en('Loneliness'),
    // teaser: _en('Surrounded by people, and still feeling like no one quite '
    //     'understands.'),
    // readingTime: _en('3 MIN'),
    // body: _en(
    //   'It is possible to be surrounded by a loving family and still feel '
    //   'lonely in pregnancy, because what changes in your body and mind is '
    //   'yours alone to carry, even when everyone around you is trying to '
    //   'help.\n\n'
    //   'It is especially common for a first pregnancy, when friends who '
    //   'have not been through it cannot quite meet you where you are, or '
    //   'when family is far away, or when a joint household leaves little '
    //   'space that is only yours.\n\n'
    //   'Other mothers, even ones you have not met yet, are often the '
    //   'fastest route out of this particular loneliness. The Community '
    //   'space in the app exists for exactly this.',
    // ),
  ),

  // ---------------------------------------------------------------------------
  //  What no one talks about - 7
  // ---------------------------------------------------------------------------
  //  ⚠️ NEW 2026-09-12, FROM THE MIND & MOOD BRIEF, VERBATIM. India-first: the
  //  house, the in-laws, the nuskhe, the gender question, the secret months.
  //  Not one of these appears in a clinical library, and every one of them is
  //  lived by most of the women this app is for.
  MmArticle(
    id: 'policed_eating',
    group: MmArticleGroup.noOneTalksAbout,
    title: _en('When everyone polices what you eat and do'),
    teaser: _en(
      "No papaya, don't lift that: when the whole house has rules for your "
      'body.',
    ),
    shortAnswer: _en(
      'When everyone has advice on what you eat and do, much of it is love '
      'and habit rather than fact. Check what matters, gently let the rest '
      "go, and keep in mind it's still your body.",
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      "No papaya. Don't lift that. Sit down. Eat this, it's good for the "
      "baby. Don't eat that, it's too hot. Everyone in the house has become "
      'an expert on your body.\n\n'
      "Some of it is love, some of it is old habit, and a lot of it isn't "
      'backed by anything. Check what matters (the Can I? section has the '
      'real answers) and gently let the rest go.\n\n'
      '"Doctor said it\'s fine" is a full sentence. You don\'t have to argue, '
      "and you don't have to obey either. It's still your body, even now.",
    ),
  ),
  MmArticle(
    id: 'log_kya_kahenge',
    group: MmArticleGroup.noOneTalksAbout,
    title: _en('Log kya kahenge'),
    teaser: _en(
      'When what the neighbours and in-laws will say starts to weigh on '
      'you.',
    ),
    shortAnswer: _en(
      "So much of pregnancy here gets lived for other people's opinions. "
      "Most of them won't remember any of it in a year. The people whose "
      'opinion matters are you, your partner and your doctor.',
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      'So much of pregnancy here gets lived for other people. What will the '
      'neighbours say, what will the in-laws think, are we doing it the '
      'right way, are we telling people at the right time. Carrying '
      "everyone's opinion on top of everything else is exhausting.\n\n"
      "Most of those people won't remember any of it in a year, and none of "
      "them are the ones growing this baby or raising it. You're allowed to "
      'do this your way.\n\n'
      'The people whose opinion matters are you, your partner and your '
      "doctor. That's a short list, and it's the right one.",
    ),
  ),
  MmArticle(
    id: 'secret_months',
    group: MmArticleGroup.noOneTalksAbout,
    title: _en('The secret months, carried alone'),
    teaser: _en(
      'Not telling anyone for three months, and carrying the sickness and '
      'worry alone.',
    ),
    shortAnswer: _en(
      "Many couples wait three months before telling anyone. It's a "
      'sensible custom, but it can leave you carrying the sickness and '
      'worry alone. You can tell one or two people who make you feel safe.',
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      "Many couples don't tell anyone for the first three months, just in "
      "case. It's a sensible custom, but it has a cost. You're going "
      'through the sickness, the fear, the tiredness and the worry, and you '
      "can't tell a soul.\n\n"
      "That's a heavy secret to carry, especially at work or in a full "
      "house. You're allowed to tell the one or two people who make you "
      "feel safe, even in these early weeks. A secret doesn't have to mean "
      'being completely alone.\n\n'
      'If the early worry is keeping you up, the community here is '
      "anonymous, so you can say it out loud without anyone knowing it's "
      'you.',
    ),
  ),
  MmArticle(
    id: 'gender_everyones_business',
    group: MmArticleGroup.noOneTalksAbout,
    title: _en('When the baby\'s gender becomes everyone\'s business'),
    teaser: _en(
      'When people drop hints or make one answer sound better than the '
      'other.',
    ),
    shortAnswer: _en(
      "The law doesn't let anyone tell you, and that's a good thing. People "
      'may still drop hints or show a preference. That says something about '
      "them, not about your child, and you don't have to carry it.",
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      "The law won't let anyone tell you, and that's a good thing. But it "
      "doesn't stop people wondering out loud, dropping hints, or making "
      'you feel one answer would be better than the other.\n\n'
      "If you've felt the weight of that, or felt a flicker of your own "
      "hope and then guilt about it, you're not a bad person. You're living "
      'in a place where this still carries pressure.\n\n'
      'Your baby is your baby. People who make it about a gender are '
      "telling you about themselves, not about your child. You don't have "
      'to carry their preference as your worry.',
    ),
  ),
  MmArticle(
    id: 'no_corner_of_the_house',
    group: MmArticleGroup.noOneTalksAbout,
    title: _en('No corner of the house that\'s yours'),
    teaser: _en(
      "When there's nowhere to close a door and just be, and how to find "
      'ten minutes.',
    ),
    shortAnswer: _en(
      'In a full house there may be nowhere to be alone, and that wears you '
      "down. Taking a little space for yourself isn't rude. It's how you "
      'stay okay.',
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      'In a joint family, or even a small flat full of people, there may be '
      'nowhere you can close a door and just be. Everyone means well, '
      'everyone is around, and you never get five minutes that are only '
      'yours. That wears you down more than people realise.\n\n'
      "You're allowed to take that space, even in small ways: a walk by "
      'yourself, ten minutes in a room with the door shut, or headphones on '
      "with something calming. It isn't rude and it isn't being difficult. "
      "It's how you stay okay.\n\n"
      'The Feel tab has a few short things for those stolen ten minutes.',
    ),
  ),
  MmArticle(
    id: 'nuskhe_and_superstitions',
    group: MmArticleGroup.noOneTalksAbout,
    title: _en('When the nuskhe and the superstitions start'),
    teaser: _en(
      'Family beliefs and home remedies: what to keep, what to check and '
      'what to let go.',
    ),
    shortAnswer: _en(
      "Every family has its nuskhe and its beliefs. You don't have to "
      'follow the ones that worry you, or fight the ones that comfort '
      'people. Check anything that makes you uneasy, then let it go.',
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      "Don't sit in the doorway. Drink this so the baby is fair. Do this so "
      "it's a boy, do that so the delivery is easy. Every family has its "
      'nuskhe and its beliefs. Some are sweet, some are harmless, and some '
      'leave you anxious or ashamed.\n\n'
      "You don't have to follow the ones that worry you, and you don't have "
      'to fight the ones that comfort people. When something makes you '
      'uneasy, check it (Can I? and Ask Veda are there for that) and then '
      'let it go.\n\n'
      "A belief that adds fear isn't helping you, whatever it promises.",
    ),
  ),
  MmArticle(
    id: 'bringing_him_in',
    group: MmArticleGroup.noOneTalksAbout,
    title: _en('Bringing him in, when he doesn\'t get it'),
    teaser: _en(
      "When he's happy about the baby but doesn't understand why you're low "
      'or scared.',
    ),
    shortAnswer: _en(
      "He may be happy about the baby but not feel what you're feeling, so "
      "he doesn't always understand. That doesn't mean he doesn't care. "
      "Small, clear asks work better than hoping he'll notice.",
    ),
    readingTime: _en('3 MIN'),
    // "There is a short piece for him too on what actually helps" —
    // `kMmPartnerArticle`, which already exists and is written to him.
    linkLabel: 'The short piece for him',
    linkArticleId: 'partner_support',
    body: _en(
      "He's happy about the baby, but he doesn't feel the sickness, the "
      "fear or the change in your body. So he doesn't always understand why "
      "you're low or snappy or scared.\n\n"
      "That gap is normal, and it doesn't mean he doesn't care. Often he "
      "just doesn't know what to do.\n\n"
      'Tell him the specific thing, not the whole feeling: sit with me for '
      "ten minutes, handle your mother today, just listen and don't fix it. "
      'Men here are rarely taught how to do this, so small, clear asks work '
      "better than hoping he'll notice.\n\n"
      "Asking for help can feel like admitting you can't manage. It isn't. "
      "You're doing something big, and letting others carry part of it is "
      'how it gets done. The same goes for family. Tell your mother, sister '
      'or mother-in-law one thing she can take off you this week, like a '
      'meal or an errand. Most people want to help and are waiting to be '
      'told how.\n\n'
      "There's a short piece for him too, on what helps.",
    ),
  ),
  MmArticle(
    id: 'after_ivf_allowed_hard',
    group: MmArticleGroup.noOneTalksAbout,
    // Added 2026-09-29 (pregnancy gap analysis). ParentVeda editorial,
    // not yet reviewed by a clinician.
    title: _en('After IVF, and finding it hard'),
    teaser: _en(
      'When you worked so hard for this pregnancy that finding it hard '
      'feels wrong.',
    ),
    shortAnswer: _en(
      "After IVF, many women feel they've no right to complain about "
      'sickness, tiredness or fear. You do. Wanting this pregnancy very '
      'much and finding it hard are both true at once.',
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      "After months or years of treatment, injections and waiting, you're "
      "finally pregnant. And now you're sick, tired or scared, and you feel "
      "you've no right to say so, because everyone knows how much you "
      'wanted this.\n\n'
      "You're allowed to find it hard. Wanting a baby very much doesn't "
      "make nausea any easier, and saying it's rough doesn't make you "
      'ungrateful. Both are true at once.\n\n'
      'An IVF pregnancy can bring its own kind of worry too. You may have '
      "watched every number for so long that it's hard to stop checking. "
      'The early weeks can feel fragile, and moving from your fertility '
      'clinic to your pregnancy doctor can feel like losing a safety net. '
      'Ask your clinic when that handover happens, and who to call if '
      "you're worried before then.\n\n"
      'Find one person who understands what it took to get here, and let '
      "them hear the hard parts too. If you'd like to talk to someone "
      'trained for this, a counsellor is on the Talk tab.',
    ),
  ),
  MmArticle(
    id: 'husband_far_away',
    group: MmArticleGroup.noOneTalksAbout,
    // Added 2026-09-29 (pregnancy gap analysis). ParentVeda editorial,
    // not yet reviewed by a clinician.
    title: _en('When your husband works far away'),
    teaser: _en(
      'Going through pregnancy while he works in another city or abroad.',
    ),
    shortAnswer: _en(
      'Many women are pregnant while their husband works in another city or '
      "abroad. It's hard, and it's okay to say so. Small daily habits help "
      'you feel close, and an early plan for the birth helps you feel safe.',
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      'Many women here are pregnant while their husband works in another '
      'city, in the Gulf, or further away. You may be living with your '
      "in-laws or back at your parents' home, with the scans, the sickness "
      'and the worry happening without him.\n\n'
      "It's hard, and it's okay to say so, to him and to the people around "
      "you. Missing him doesn't make you ungrateful for the work that keeps "
      'the family going.\n\n'
      'A few things help you feel close. Share scan photos and what the '
      'doctor said on the same day. Keep a regular time to talk, even ten '
      'minutes. Ask if he can join a check-up on a video call. Let him read '
      'about each week too, so you have the same things to talk about.\n\n'
      "Plan for the birth early. Talk about when he'll try to come home, "
      'who will take you to hospital if labour starts before he arrives, '
      "and who you'll call first. Write it down and share it with the "
      'family.\n\n'
      'If the loneliness is heavy most days, the counsellor on the Talk tab '
      'is there for that too.',
    ),
  ),

  // ---------------------------------------------------------------------------
  //  Fears, named and answered - 6
  // ---------------------------------------------------------------------------
  MmArticle(
    id: 'fear_labour',
    // ⚠️ THE BRIEF: "Add a line linking across to Labour prep's 'what
    // actually happens in labour', since knowing the process is the real
    // thing that shrinks the fear." A link, not a copy.
    linkLabel: 'What actually happens in labour',
    linkDoor: 'pregnancy_labour',
    linkGroup: 'birth',
    group: MmArticleGroup.fears,
    title: _en('Fear of labour'),
    teaser: _en(
      'A fear common enough to have its own name, and what makes it '
      'smaller.',
    ),
    shortAnswer: _en(
      "Fear of labour is very common, and when it's strong it has a name, "
      'tokophobia. Knowing what will happen, and knowing pain relief is a '
      "real choice, both make the fear smaller. If it's affecting your "
      'sleep, tell your doctor.',
    ),
    readingTime: _en('4 MIN'),
    hasExpertVideo: true,
    hasStoryVideo: true,
    body: _en(
      'A real, sometimes intense fear of labour is common enough to have a '
      'medical name, tokophobia. It runs from ordinary nervousness to fear '
      'strong enough to affect your sleep and mood. Wherever you are on it, '
      "you're far from the only one there.\n\n"
      'Much of the fear comes from not knowing what to expect, or from '
      'stories other people have told you. Those stories are rarely a fair '
      "picture of labour. Preparing helps here in a way it doesn't for "
      'every fear. Understanding what will happen, stage by stage, and '
      'knowing pain relief is a real, available choice both make the fear '
      'itself smaller.\n\n'
      "If it's the pain you fear most, ask your doctor at your next visit "
      'what pain relief your hospital offers, and when you can ask for it. '
      'Knowing your options ahead of time takes away a lot of the dread.\n\n'
      "If it's tearing, ask about that too. Your doctor can tell you what "
      'they do during the birth to help protect you, and how a tear is '
      'cared for if it happens. Most women find the real answer calmer than '
      "what they'd imagined.\n\n"
      'Write your fears down and take the list with you. Saying them out '
      'loud to your doctor, your partner or a counsellor makes them easier '
      'to hold.\n\n'
      "If the fear is strong enough that you're avoiding thinking about the "
      "birth at all, or it's affecting your sleep most nights, raise it "
      'with your doctor directly, and talk it through with a counsellor. '
      'Both are there for exactly this.',
    ),
  ),
  MmArticle(
    id: 'fear_something_wrong',
    // The brief: links across to Scans & tests for the actual checks.
    linkLabel: 'The scans that check, and when',
    linkDoor: 'pregnancy_scans_tests',
    linkGroup: 'understand',
    group: MmArticleGroup.fears,
    title: _en('Fear something is wrong with the baby'),
    teaser: _en(
      'A worry under everything, even when every scan has been fine.',
    ),
    shortAnswer: _en(
      'Almost every pregnant woman carries this worry, even after good '
      'scans. A clear scan is real evidence, not a short break before the '
      'next worry. If the worry fills hours of your day, talk to someone.',
    ),
    readingTime: _en('4 MIN'),
    hasExpertVideo: true,
    hasStoryVideo: true,
    body: _en(
      'Almost every pregnant woman carries some version of this fear, even '
      "after a string of reassuring scans and appointments. It's one of the "
      'most common pregnancy fears there is, because so much of what '
      "happens inside you can't be seen or felt.\n\n"
      'The scans and checks in your calendar are there to catch what needs '
      'catching. A clear scan is real evidence, not a short break before '
      "the next worry. It's normal for the reassurance to fade after a few "
      'days and the worry to creep back. That cycle is the fear itself, not '
      'a sign something has changed.\n\n'
      'If this worry is taking up hours of most days, or sending you back '
      'to search engines again and again for reassurance that never lands, '
      '"Health anxiety and over-Googling" and "Pregnancy anxiety" go '
      'further into it.',
    ),
  ),
  MmArticle(
    id: 'fear_miscarriage',
    group: MmArticleGroup.fears,
    title: _en('Fear of miscarriage'),
    teaser: _en(
      'Especially sharp in the early weeks, and especially after a loss '
      'before.',
    ),
    shortAnswer: _en(
      'Fear of miscarriage is sharpest in the early weeks, and sharper '
      "still after a loss. How strong your symptoms feel doesn't tell you "
      'how your pregnancy is doing. In most cases, nothing you do causes or '
      'prevents a miscarriage.',
    ),
    readingTime: _en('4 MIN'),
    hasExpertVideo: true,
    hasStoryVideo: true,
    body: _en(
      "Fear of loss is at its sharpest in the first trimester. It's sharper "
      "still if you've miscarried before or spent a long time trying to "
      'conceive. Checking for symptoms all the time, or holding back from '
      'getting attached, are both common ways this fear shows up.\n\n'
      'Many women panic when their sickness eases or their breasts stop '
      'feeling sore, or when the symptoms never came at all. Symptoms come '
      "and go, and they vary hugely from one woman to the next. They don't "
      'measure how well a pregnancy is going. Your doctor and your scans do '
      'that.\n\n'
      'The fear usually eases as the pregnancy goes on and the risk itself '
      'falls. For some women it stays well past the point where the numbers '
      "say it should. That's a real experience, not an overreaction.\n\n"
      'In the vast majority of cases, nothing you did or are doing causes '
      'or prevents a miscarriage. Come back to that fact when the fear '
      'starts to sound like blame.\n\n'
      "If it's affecting your ability to get through the day, please talk "
      'to your doctor, and think about a counsellor alongside them.',
    ),
  ),
  MmArticle(
    id: 'pregnant_after_loss',
    group: MmArticleGroup.fears,
    // Added 2026-09-29 (pregnancy gap analysis). ParentVeda editorial,
    // not yet reviewed by a clinician.
    title: _en('Pregnant again after a loss'),
    teaser: _en(
      "When joy and fear arrive together, because you've lost a pregnancy "
      'before.',
    ),
    shortAnswer: _en(
      'Being pregnant after a miscarriage or loss often brings joy and fear '
      "together. That mix is normal, and you don't have to choose one. Tell "
      'your doctor about your loss and how anxious you feel, so your care '
      'fits you.',
    ),
    readingTime: _en('4 MIN'),
    body: _en(
      "If you've lost a pregnancy before, this one can feel different from "
      'the start. You may be happy and frightened at the same time, and '
      'hold back from getting attached, just in case. Both feelings can be '
      'there together, and neither is wrong.\n\n'
      'Some people call a baby born after a loss a rainbow baby. You can '
      'use the words that feel right to you, or none at all. Your grief for '
      "the baby you lost doesn't have to be finished for you to love this "
      'one.\n\n'
      'The early weeks, and the weeks around the time of your earlier loss, '
      'are often the hardest. Many women find themselves checking for '
      "bleeding or counting symptoms. Your symptoms don't tell you how this "
      'pregnancy is going. Your doctor and your scans do.\n\n'
      "Tell your doctor about your loss, if they don't already know, and "
      "say how anxious you feel. Ask what check-ups you'll have and when, "
      'so you know when the next reassurance is coming. Some doctors offer '
      "an extra early scan after a loss, and it's fine to ask.\n\n"
      'Let one or two people know how hard this is, even if everyone else '
      'only sees good news. If the fear is taking over your days or your '
      'sleep, a counsellor on the Talk tab can help.',
    ),
  ),
  MmArticle(
    id: 'fear_not_good_mother',
    group: MmArticleGroup.fears,
    // ⚠️ REBUILT 2026-09-12 FROM THE MIND & MOOD BRIEF, VERBATIM. The
    // teaser is the read's own first sentence. The earlier body is kept
    // below, commented, for revert.
    title: _en('Fear of being a bad mother'),
    teaser: _en(
      "Already sure you'll get it wrong, before your baby is even here.",
    ),
    shortAnswer: _en(
      "Almost every thoughtful mother fears she'll get it wrong. The "
      'mothers who worry about it are almost never the ones to worry about. '
      "You'll learn your baby, and your baby will learn you.",
    ),
    readingTime: _en('4 MIN'),
    hasExpertVideo: true,
    hasStoryVideo: true,
    body: _en(
      "You're not even a mother yet, and you're already sure you'll get it "
      "wrong. You'll be too tired, too impatient, too much like someone in "
      "your own family you didn't want to become.\n\n"
      'Almost every thoughtful mother has this fear. The mothers who worry '
      "about being bad at it are almost never the ones you'd worry about. "
      'The fear is your care showing up early.\n\n'
      "You don't have to have it all figured out. You'll learn your baby, "
      "your baby will learn you, and you'll both be fine at it in your own "
      'way.\n\n'
      'If this fear is constant and heavy, talk it through with someone.',
    ),
    // id: 'fear_not_good_mother',
    // group: MmArticleGroup.fears,
    // title: _en('Fear of not being a good mother'),
    // teaser: _en('"What if I am not cut out for this." Nearly every mother '
    //     'has thought it.'),
    // readingTime: _en('4 MIN'),
    // hasExpertVideo: true,
    // hasStoryVideo: true,
    // body: _en(
    //   'This fear is close to universal and rarely spoken about, because it '
    //   'feels like admitting a weakness rather than what it actually is: a '
    //   'sign that you care enough to worry about getting this right.\n\n'
    //   'There is no version of motherhood that arrives fully formed on day '
    //   'one. It is learned, mostly on the job, by every mother who has ever '
    //   'done it, including the ones who look most certain from the outside.\n\n'
    //   'If this fear is paired with a persistent sense of dread about the '
    //   'baby arriving at all, rather than ordinary nerves, that combination '
    //   'is worth reading about in "Antenatal depression" and "Pregnancy '
    //   'anxiety".',
    // ),
  ),
  MmArticle(
    id: 'fear_body_changes',
    group: MmArticleGroup.fears,
    title: _en('Fear of body changes'),
    teaser: _en(
      'Worry about how your body will look, feel or work, now and after.',
    ),
    shortAnswer: _en(
      "Worrying about how your body is changing is common, and it isn't "
      'shallow. Most changes soften a lot in the months after birth, though '
      'every woman is different.',
    ),
    readingTime: _en('4 MIN'),
    hasExpertVideo: true,
    hasStoryVideo: true,
    body: _en(
      "Fear about how your body is changing, and whether it'll feel like "
      "yours again, is common. It's rarely said out loud, partly because it "
      'can feel shallow next to the "bigger" worries of pregnancy.\n\n'
      "It isn't shallow. Your body is changing in ways that are visible, "
      'permanent in some ways, and outside your control.\n\n'
      'Most physical changes soften a lot over the months after birth, '
      'though the timeline and the result are different for every woman. '
      'Comparing yourself to anyone else, including your own body before '
      'pregnancy, rarely helps.\n\n'
      '"Body image and self-esteem" in Everyday emotional care goes further '
      'into living with this day to day.',
    ),
  ),
  MmArticle(
    id: 'health_anxiety_googling',
    group: MmArticleGroup.fears,
    title: _en('Health anxiety and over-Googling'),
    teaser: _en(
      'Searching a symptom at midnight, and feeling worse an hour later.',
    ),
    shortAnswer: _en(
      'Searching a symptom is natural, but results often put the rarest, '
      'scariest answer first. If you keep searching late into the night and '
      "never feel reassured, that's the anxiety, not the symptom.",
    ),
    readingTime: _en('4 MIN'),
    hasExpertVideo: true,
    hasStoryVideo: true,
    body: _en(
      'Searching a symptom is a natural thing to do, and pregnancy makes it '
      'more tempting than ever because so much feels new. The trouble is '
      'what the results contain. The rarest, most frightening explanation '
      'is often the loudest one on the page, which is the opposite of how '
      'likely it is.\n\n'
      "One pattern worth noticing in yourself is searching that doesn't "
      'stop at one answer. It keeps going, page after page, late into the '
      'night, chasing a reassurance that never arrives. That pattern is the '
      'anxiety talking, not the symptom.\n\n'
      'Ask Veda, which you can open from any screen here, is there partly '
      'for this: a calmer place to ask a worry out loud, with a clear '
      'pointer to a real person whenever the question needs one.',
    ),
  ),

  // ---------------------------------------------------------------------------
  //  When it is more than a mood - 6
  //  ⚠️ REQUIRED_REVIEW on every article below. Draft wording only.
  // ---------------------------------------------------------------------------
  MmArticle(
    id: 'baby_blues_or_more',
    group: MmArticleGroup.moreThanMood,
    // ⚠️ NEW 2026-09-12, FROM THE BRIEF, VERBATIM — the read that opens the
    // door's "When it is more than this" tab. The red flag beside it holds
    // the signs; this is the sentence before them.
    title: _en('Baby blues, or something more?'),
    teaser: _en(
      'How to tell the usual weepy first weeks from a low that needs help.',
    ),
    shortAnswer: _en(
      'Feeling weepy and up and down in the first days after birth is the '
      'baby blues, and it usually settles within about two weeks. A low '
      "that doesn't lift is different. It's common, it isn't your fault, "
      'and it gets better with the right help.',
    ),
    readingTime: _en('2 MIN'),
    requiresReview: true,
    body: _en(
      'Most mothers feel weepy, up and down and a bit raw in the first days '
      "and weeks. That's the baby blues, and it usually settles on its own "
      'within about two weeks.\n\n'
      "What's different, and worth taking seriously, is a low that doesn't "
      "lift. It's there most of every day, and it takes your sleep, your "
      "appetite or your interest in everything. That isn't a mood you have "
      'to wait out or push through.\n\n'
      "It's common, it isn't your fault, and it gets better with the right "
      'help. The same-day signs on the "When it is more than this" tab tell '
      'you when to reach out today.',
    ),
  ),
  MmArticle(
    id: 'antenatal_depression',
    group: MmArticleGroup.moreThanMood,
    title: _en('Antenatal depression'),
    teaser: _en('When a low mood in pregnancy stays, instead of lifting.'),
    shortAnswer: _en(
      'Depression in pregnancy is more common than most people expect, and '
      "it's treatable. It's a low mood that stays most of the day, for two "
      'weeks or more. Tell your doctor, and a counsellor can help.',
    ),
    readingTime: _en('5 MIN'),
    hasExpertVideo: true,
    requiresReview: true,
    body: _en(
      'Depression during pregnancy is more common than most people expect, '
      "and it's treatable. It isn't a sign of weakness, and it isn't "
      'something you can decide your way out of.',
    ),
    whatItIs: _en(
      'A low mood that stays, most of most days, for two weeks or more, '
      'rather than a hard day or two that passes. It can sit alongside '
      "excitement about the baby, not instead of it. That's part of why "
      "it's easy to miss in pregnancy.",
    ),
    signsToNotice: _en(
      "A flatness or heaviness that doesn't lift. Losing interest in things "
      'you usually enjoy. Changes in appetite or sleep beyond what '
      'pregnancy explains. Feeling worthless, or far more guilty than '
      'usual. Finding it hard to concentrate or make decisions.',
    ),
    howToGetHelp: _en(
      "Say it out loud to your doctor at your next appointment. It's "
      "exactly what perinatal counselling on the Talk tab is for. You don't "
      'need the right words first for either conversation.',
    ),
  ),
  MmArticle(
    id: 'pregnancy_anxiety',
    group: MmArticleGroup.moreThanMood,
    title: _en('Pregnancy anxiety'),
    teaser: _en(
      'When worry is there almost all the time, instead of coming and '
      'going.',
    ),
    shortAnswer: _en(
      'Some worry in pregnancy is expected. It becomes anxiety when '
      'reassurance stops helping and the worry starts running your day. A '
      'counsellor can teach you ways to interrupt it.',
    ),
    readingTime: _en('5 MIN'),
    hasExpertVideo: true,
    requiresReview: true,
    body: _en(
      "Some worry in pregnancy is expected, and it can even help: it's what "
      'gets you to appointments on time. Anxiety becomes its own thing when '
      'the worry stops responding to reassurance and starts running your '
      'day.\n\n'
      'A small practice for when it rises. Breathe out slowly, longer than '
      'you breathe in, three times. Then name the worry in one sentence, '
      "and ask yourself what you can do about it today. If there's "
      "something, do that one thing. If there isn't, write the worry down "
      'and keep it for your next appointment, where you can ask.',
    ),
    whatItIs: _en(
      "A pattern of worry that's hard to switch off, often about the baby's "
      'health or the birth. It keeps coming back even after a scan or your '
      "doctor's reassurance should have settled it.",
    ),
    signsToNotice: _en(
      'Restlessness. A racing heart or a tight chest without a physical '
      "cause. Trouble sleeping because your mind won't quieten. Avoiding "
      'things that set off the worry. Looking for reassurance again and '
      'again without it ever feeling like enough.',
    ),
    howToGetHelp: _en(
      'A perinatal counsellor can teach you specific ways to interrupt this '
      'pattern, which is different from being told to stop worrying. You '
      "can book one on the Talk tab, and it's anonymous.",
    ),
  ),
  MmArticle(
    id: 'panic_attacks',
    group: MmArticleGroup.moreThanMood,
    title: _en('Panic attacks'),
    teaser: _en(
      'A sudden wave of fear with real physical symptoms. Frightening, and '
      'not dangerous in itself.',
    ),
    shortAnswer: _en(
      'A panic attack is a sudden wave of fear with strong physical '
      "symptoms that peaks within minutes and then eases. It's frightening, "
      "and on its own it isn't dangerous to you or your baby.",
    ),
    readingTime: _en('4 MIN'),
    hasExpertVideo: true,
    requiresReview: true,
    body: _en(
      'A panic attack can feel like something is seriously wrong with your '
      'body: a racing heart, a tight chest, shaking, a feeling that nothing '
      "is real. It's very unpleasant, and on its own it isn't dangerous to "
      'you or your baby.',
    ),
    whatItIs: _en(
      'A sudden, sharp wave of fear that peaks within minutes, usually with '
      'strong physical symptoms, and then eases. It can happen with no '
      'obvious trigger.',
    ),
    signsToNotice: _en(
      'A pounding heart, shortness of breath, dizziness, trembling, a '
      'feeling of choking or of things not being real, or a sudden fear '
      'that something terrible is about to happen, all arriving together '
      'and quickly.',
    ),
    howToGetHelp: _en(
      'The Calm note on the Feel tab is made for the moment itself. If '
      'panic attacks happen more than once, tell your doctor, and think '
      'about talking it through with a perinatal counsellor. If you have '
      "chest pain or breathlessness and you're not sure it's panic, call "
      'your doctor or go to hospital today.',
    ),
  ),
  MmArticle(
    id: 'intrusive_thoughts',
    group: MmArticleGroup.moreThanMood,
    title: _en('Intrusive thoughts'),
    teaser: _en(
      'Sudden, unwanted, frightening thoughts about the baby. More common '
      'than almost anyone admits.',
    ),
    shortAnswer: _en(
      'Many pregnant women and new mothers have sudden, unwanted thoughts '
      "about something bad happening to the baby. Having them doesn't mean "
      "you'd ever act on them. Please tell your doctor or a counsellor "
      'instead of carrying them alone.',
    ),
    readingTime: _en('5 MIN'),
    hasExpertVideo: true,
    requiresReview: true,
    body: _en(
      'Many pregnant women and new mothers have sudden, unwanted thoughts '
      "about something bad happening to the baby. They'd never act on them, "
      'and the thoughts frighten them because they seem to come from '
      'nowhere.\n\n'
      'These thoughts are far more common than people talk about. Having '
      "them doesn't mean you'd ever act on them, or that you're a danger to "
      'your baby.',
    ),
    whatItIs: _en(
      'An unwanted thought or picture that arrives suddenly and feels '
      "completely against who you are. You don't want it, and you'd never "
      'choose to act on it. The distress it causes is itself a sign it '
      "isn't a real intention.",
    ),
    signsToNotice: _en(
      'The thoughts keep coming back, cause real distress or shame, or lead '
      'you to avoid the baby, or anything connected to the thought, '
      'altogether.',
    ),
    howToGetHelp: _en(
      'Please say this out loud to your doctor or a perinatal counsellor, '
      "instead of carrying it alone. It's a known experience that can be "
      'treated, and naming it plainly is usually the hardest part and the '
      'biggest relief.',
    ),
  ),
  MmArticle(
    id: 'baby_blues',
    group: MmArticleGroup.moreThanMood,
    title: _en('Baby blues (looking ahead)'),
    teaser: _en(
      'The dip most mothers feel in the first two weeks after birth. '
      'Common, and it passes.',
    ),
    shortAnswer: _en(
      'The baby blues is a short dip in mood that most mothers feel a few '
      'days after birth. It usually settles within about two weeks. If it '
      "doesn't ease, or gets worse, speak to your doctor.",
    ),
    readingTime: _en('4 MIN'),
    requiresReview: true,
    body: _en(
      "This is written for after the birth, so it's here for you to "
      'recognise, not to worry about now. In the days after birth, hormone '
      'levels fall sharply and sleep is short. Most new mothers feel some '
      'tearfulness, mood swings or overwhelm because of it.',
    ),
    whatItIs: _en(
      'A short dip in mood, usually starting two to four days after birth '
      "and settling within about two weeks. It's driven mostly by the "
      'sudden drop in hormones after delivery.',
    ),
    signsToNotice: _en(
      'Tearfulness, irritability, or feeling overwhelmed or anxious, which '
      'comes and goes and gets a little better day by day.',
    ),
    howToGetHelp: _en(
      "If it hasn't started easing by around two weeks, or it's getting "
      'worse instead of better, read "Postpartum depression" and speak to '
      'your doctor.',
    ),
  ),
  MmArticle(
    id: 'postpartum_depression',
    group: MmArticleGroup.moreThanMood,
    title: _en('Postpartum depression (looking ahead)'),
    teaser: _en(
      "When the low feeling after birth doesn't lift on its own. Common, "
      'and treatable.',
    ),
    shortAnswer: _en(
      'Postpartum depression is more than the baby blues. It lasts longer, '
      "feels stronger and doesn't ease on its own. It's common, it's "
      'treatable, and reaching out early helps.',
    ),
    readingTime: _en('5 MIN'),
    hasExpertVideo: true,
    requiresReview: true,
    body: _en(
      'Also written for later. Postpartum depression is more than the baby '
      "blues. It lasts longer, it tends to be stronger, and it doesn't ease "
      "on its own the way the blues usually do. It's one of the most common "
      'complications of childbirth, and good help exists.',
    ),
    whatItIs: _en(
      'A depression that starts any time in the first year after birth, '
      'most often in the first few months. It lasts more than two weeks and '
      'affects how you get through the day.',
    ),
    signsToNotice: _en(
      "A low mood that doesn't lift. Losing interest in the baby or in "
      'things you used to enjoy. Exhaustion beyond ordinary new-parent '
      'tiredness. Feeling unable to cope. Pulling away from people who want '
      'to help.',
    ),
    howToGetHelp: _en(
      'Please tell your doctor plainly, and know that a perinatal '
      'counsellor is trained for exactly this. Reaching out early tends to '
      'shorten how long it lasts.',
    ),
  ),

  // ---------------------------------------------------------------------------
  //  Everyday emotional care - 5
  // ---------------------------------------------------------------------------
  MmArticle(
    id: 'sleep_and_mood',
    group: MmArticleGroup.everydayCare,
    title: _en('Sleep and mood'),
    teaser: _en(
      "Broken sleep doesn't just tire you. It changes how everything else "
      'feels.',
    ),
    shortAnswer: _en(
      'Poor sleep and low mood feed each other. Protect the sleep you can '
      'with a steady wind-down and a cool, dark room. If a racing mind '
      'keeps you awake most nights, tell your doctor.',
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      'Poor sleep and low mood feed each other. Tiredness makes everything '
      'harder to cope with, and a mind full of worry makes it harder to '
      'fall asleep. Pregnancy disrupts sleep for physical reasons too: an '
      "uncomfortable body, trips to the bathroom, and a baby who's more "
      'active at night than in the day.\n\n'
      'Protect the sleep you can. A steady wind-down, a cool dark room and '
      "less screen time before bed help more than you'd expect. The 4-7-8 "
      'breath on the Feel tab is a good one at bedtime.\n\n'
      "If lying awake with a racing mind happens most nights, that's more "
      "than ordinary discomfort, and it's worth mentioning to your doctor.",
    ),
  ),
  MmArticle(
    id: 'unsolicited_advice_family_pressure',
    group: MmArticleGroup.everydayCare,
    title: _en('Unsolicited advice and family pressure'),
    teaser: _en(
      'Everyone has an opinion on your pregnancy, and not all of it was '
      'asked for.',
    ),
    shortAnswer: _en(
      'In many Indian families pregnancy is a family event, which brings '
      "support and a lot of advice you didn't ask for. A short, warm line "
      'closes the conversation without a fight. You can say thank you and '
      'still do it your way.',
    ),
    readingTime: _en('4 MIN'),
    body: _en(
      'In many Indian families, pregnancy is a family event as much as a '
      'personal one. That brings real support, and also a lot of advice you '
      "didn't ask for, on everything from what to eat to how to sleep to "
      'when to have another. It can wear you down even when it comes from '
      'love.\n\n'
      'A short, warm line you can repeat works better than a long '
      'explanation: "Thank you, I\'ll talk to my doctor about that." It '
      'closes the conversation without a fight.\n\n'
      'It helps to practise before the next visit. Pick one line and say it '
      "out loud a few times when you're alone, so it comes easily when you "
      'need it. Keep your voice kind and your answer the same each time. '
      "You don't need to give reasons, and you don't need to win.\n\n"
      "It's fair to protect your own decisions, especially anything "
      "medical, even from people who mean well. You're allowed to say thank "
      'you and still do it your way.',
    ),
  ),
  MmArticle(
    id: 'work_stress',
    group: MmArticleGroup.everydayCare,
    title: _en('Work stress'),
    teaser: _en(
      'Managing a job and a pregnancy at once, and deciding what to tell '
      'work.',
    ),
    shortAnswer: _en(
      'Juggling a job and a pregnancy adds its own stress. Knowing your '
      'maternity leave rights early makes the conversation with work '
      'easier. Even ten minutes of rest in the day helps.',
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      'Deciding when to tell your workplace, how much to say, and how to '
      "manage energy that's lower than usual all add stress on top of the "
      "pregnancy itself. It's common to feel torn between wanting to work "
      'as normal and needing some real support.\n\n'
      'Knowing your maternity leave and workplace rights ahead of time '
      'tends to lower the worry about that conversation, even before you '
      'have it.\n\n'
      'A short rest in the day, even ten minutes with your eyes closed, '
      "changes how the rest of the day feels. It's not a small thing, even "
      'when it looks like one.',
    ),
  ),
  MmArticle(
    id: 'relationship_intimacy_changes',
    group: MmArticleGroup.everydayCare,
    title: _en('Relationship and intimacy changes'),
    teaser: _en('Pregnancy changes a relationship too, not just a body.'),
    shortAnswer: _en(
      'Pregnancy changes a relationship too. Some couples feel closer and '
      'some feel more distant, and neither means trouble. Saying plainly '
      'what you each need helps more than guessing.',
    ),
    readingTime: _en('4 MIN'),
    body: _en(
      "It's common for desire, energy and closeness with your partner to "
      'shift in pregnancy, in both directions. Some couples feel closer '
      'than ever and some feel more distant. Neither is a sign the '
      'relationship is in trouble.\n\n'
      'A change in physical closeness is often about comfort, tiredness and '
      'a body that feels unfamiliar, not about the relationship. Saying '
      'that plainly to your partner usually helps more than either of you '
      'guessing.\n\n'
      'Your partner can feel unsure how to help, or left out by how much '
      'attention the pregnancy takes. A short, direct talk about what you '
      'each need closes that gap faster than working it out alone.\n\n'
      'A few things make those talks easier. Pick a calm moment, not the '
      'middle of an argument. Start with "I feel" instead of "you always". '
      'Ask one question, and listen to the whole answer before you reply.\n\n'
      "There's a hopeful side too. Many couples find that expecting a baby "
      'brings them closer: planning together, feeling the first kicks '
      'together, and learning to lean on each other before the baby '
      'arrives.',
    ),
  ),
  MmArticle(
    id: 'body_image_self_esteem',
    group: MmArticleGroup.everydayCare,
    title: _en('Body image and self-esteem'),
    teaser: _en(
      'Living in a body that changes week by week, whether you feel ready '
      'or not.',
    ),
    shortAnswer: _en(
      'Pride and discomfort about your changing body often come on the same '
      'day, and both are allowed. Comparing yourself to others, especially '
      "online, rarely helps. If it's affecting how you eat, talk to your "
      'doctor or a counsellor.',
    ),
    readingTime: _en('4 MIN'),
    body: _en(
      'A changing body can bring pride and discomfort at the same time, '
      'often on the same day. Both can be true together, and neither '
      'cancels the other out.\n\n'
      'Comparison is usually the sharpest edge: with other pregnant women, '
      'with your own body before pregnancy, and with pictures online that '
      'are rarely the ordinary version of anything.\n\n'
      'Pregnancy photos on social media are chosen, posed and often edited. '
      "You're seeing someone's best angle on their best day, next to your "
      "own ordinary Tuesday. If scrolling leaves you feeling worse, it's "
      'fine to mute accounts or take a break for a while.\n\n'
      "Your body is doing something enormous, and it's allowed to look and "
      'feel different while it does.\n\n'
      'If body image is affecting how you eat, or bringing up feelings that '
      'seem bigger than the moment, have a gentle talk with your doctor or '
      "a counsellor. You don't have to push through it alone.",
    ),
  ),

  // ---------------------------------------------------------------------------
  //  Sex and closeness - 6 (added 2026-09-29, pregnancy gap analysis P2)
  // ---------------------------------------------------------------------------
  //  Private in tone and never explicit. The door lists these on their own tab,
  //  which the shared-phone switch is meant to hide: see
  //  `kMindIntimateReadIds` and `mindDoorVisiblePage` in pv_door_mind.dart.
  MmArticle(
    id: 'closeness_sex_safe',
    group: MmArticleGroup.closeness,
    // Added 2026-09-29 (pregnancy gap analysis). ParentVeda editorial,
    // not yet reviewed by a clinician.
    title: _en('Is sex safe in pregnancy?'),
    teaser: _en(
      'The answer for most couples, and what keeps your baby protected.',
    ),
    shortAnswer: _en(
      "For most couples with a healthy pregnancy, yes. Sex doesn't reach or "
      'hurt your baby, who is protected by the waters, the womb and the '
      'closed cervix. If your doctor has told you to avoid sex, follow '
      'that.',
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      "It's one of the questions couples wonder about most and ask least. "
      'For most couples with a healthy pregnancy, sex is safe all the way '
      'through, unless your doctor has told you otherwise.\n\n'
      "Your baby is well protected. They're cushioned by the fluid in the "
      'bag of waters, held inside the strong muscle of your womb, and '
      'sealed off by a thick plug of mucus at the neck of the womb (the '
      'cervix). Nothing during sex reaches the baby.\n\n'
      "Your womb may tighten for a little while after an orgasm. That's "
      'normal, and it settles on its own with rest.\n\n'
      'Light spotting after sex can happen, because the cervix has more '
      "blood flowing to it now and bleeds more easily when touched. It's "
      'often harmless, but any bleeding in pregnancy is worth a call to '
      'your doctor, so they can check.\n\n'
      'Some doctors ask couples to avoid sex for a while, for reasons the '
      'next read explains. If any of those apply to you, check with your '
      'doctor first. ParentVeda explains and reminds. Your doctor decides.',
    ),
  ),
  MmArticle(
    id: 'closeness_when_to_stop',
    group: MmArticleGroup.closeness,
    // Added 2026-09-29 (pregnancy gap analysis). ParentVeda editorial,
    // not yet reviewed by a clinician.
    title: _en('When your doctor may say to stop'),
    teaser: _en(
      'The usual reasons a doctor asks you to avoid sex, and what to ask.',
    ),
    shortAnswer: _en(
      'Sometimes a doctor advises no sex for a while, or until the birth. '
      'The usual reasons are bleeding, a low-lying placenta, leaking '
      'waters, a risk of early labour or a stitch in the cervix. Your own '
      "doctor's advice always comes first.",
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      'For most pregnancies sex is fine. Sometimes your doctor will ask you '
      'to avoid it for a while, or until your baby is born. These are the '
      'usual reasons.\n\n'
      "Bleeding from the vagina, especially while the cause isn't known.\n\n"
      'A low-lying placenta (placenta praevia), where the placenta lies '
      'over or close to the neck of the womb.\n\n'
      'Leaking waters. Once the bag of waters has opened, infection can '
      'reach the baby more easily.\n\n'
      "A risk of early labour (preterm labour), for example if you've had "
      'early labour before, or your doctor sees signs of it now.\n\n'
      'A stitch in the cervix (cervical cerclage), or a cervix your doctor '
      'has found to be short or opening early.\n\n'
      'Your doctor may also advise it for other reasons in your own '
      'pregnancy, and that advice is the one to follow. Some doctors mean '
      'no intercourse. Others mean no orgasm, or nothing inside the vagina, '
      "as well. It's fine to ask exactly what they mean and for how long. "
      "They've been asked many times before.\n\n"
      'When should you call your doctor? Call straight away if you have '
      'bleeding, a gush or trickle of fluid from the vagina, strong pain, '
      "or tightenings that keep coming regularly after sex. Don't wait for "
      'your next visit.\n\n'
      'Being told to stop can bring worry, and sometimes a feeling of '
      'distance between you. The read on feeling close without sex has '
      'ideas for those weeks.',
    ),
  ),
  MmArticle(
    id: 'closeness_desire_changes',
    group: MmArticleGroup.closeness,
    // Added 2026-09-29 (pregnancy gap analysis). ParentVeda editorial,
    // not yet reviewed by a clinician.
    title: _en('Wanting sex more, or less'),
    teaser: _en(
      'Desire going up, down, or both: why it changes, and how to talk '
      'about it.',
    ),
    shortAnswer: _en(
      'Desire often changes in pregnancy. It can go up, go down, or do both '
      'at different times, and all of it is normal. It says nothing about '
      'your love for each other, and talking gently helps more than '
      'guessing.',
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      'Many women find their desire changes in pregnancy. For some it '
      'drops, especially in the first months with sickness and tiredness, '
      'and again near the end when the bump makes everything harder. For '
      'others it rises, often in the middle months, when extra blood flow '
      'makes the area more sensitive. Many feel both at different times.\n\n'
      "All of this is normal. Not wanting sex doesn't mean you don't love "
      "your partner, and wanting it more isn't strange either.\n\n"
      'His desire can change too. Some men feel shy, or worry about hurting '
      'the baby, and stop reaching out without saying why. Others feel more '
      'drawn to you than ever. Often the silence is the hardest part for '
      'you both.\n\n'
      "A few gentle things help. Say what's going on for you in simple "
      'words: "It\'s not you. I\'m just so tired." Ask what\'s going on for '
      'him. Agree that closeness can look different for now.\n\n'
      'Some women notice dryness, or feel tearful during or after sex. Both '
      'can come with changing hormones. A water-based lubricant can help '
      'with dryness. Tears are okay too. Stop, hold each other, and talk if '
      'you want to.\n\n'
      'Vivid dreams, sex dreams among them, are common in pregnancy as '
      "well. They come with changing hormones and broken sleep, and they're "
      'nothing to feel embarrassed about.\n\n'
      'If sex hurts, or low desire comes with feeling low most days, '
      'mention it to your doctor.',
    ),
  ),
  MmArticle(
    id: 'closeness_comfortable',
    group: MmArticleGroup.closeness,
    // Added 2026-09-29 (pregnancy gap analysis). ParentVeda editorial,
    // not yet reviewed by a clinician.
    title: _en('Staying comfortable as your bump grows'),
    teaser: _en(
      'What tends to feel easier later in pregnancy, in plain words.',
    ),
    shortAnswer: _en(
      'As your bump grows, positions that keep weight off your belly '
      'usually feel best. Lying on your sides, or you being on top, are '
      'easy ones to try. Go slowly, use pillows, and stop if anything '
      'hurts.',
    ),
    readingTime: _en('2 MIN'),
    body: _en(
      'In the early months, most couples find nothing needs to change. As '
      'your bump grows, some positions start to feel awkward or '
      "uncomfortable, and that's normal.\n\n"
      'What helps most is keeping weight and pressure off your bump. Lying '
      'on your sides, with your partner behind you, suits many couples, '
      'especially later on. You being on top lets you set the pace. Sitting '
      'positions, or you at the edge of the bed, keep your bump free too.\n\n'
      'From the middle of pregnancy, lying flat on your back for a long '
      'time can make you feel dizzy or sick, because the weight of your '
      'womb presses on a large blood vessel. A pillow under one hip, or '
      'turning onto your side, helps.\n\n'
      'Use pillows freely, go slowly and talk as you go. If anything hurts, '
      'stop. Bleeding, leaking fluid or pain after sex is a reason to call '
      'your doctor.',
    ),
  ),
  MmArticle(
    id: 'closeness_baby_worries',
    group: MmArticleGroup.closeness,
    // Added 2026-09-29 (pregnancy gap analysis). ParentVeda editorial,
    // not yet reviewed by a clinician.
    title: _en('Can sex hurt the baby?'),
    teaser: _en(
      'The worries couples have and rarely say out loud, answered plainly.',
    ),
    shortAnswer: _en(
      "In a healthy pregnancy, sex can't hurt your baby. Your baby is "
      'protected by the waters, the womb and the closed cervix. Many '
      'husbands worry about this too, so it helps to read it together.',
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      "This is the worry that stops many couples, and it's often the man "
      "who has it but doesn't say it. In a healthy pregnancy, sex can't "
      'hurt your baby.\n\n'
      'Can the baby feel it? Your baby is floating in fluid, inside the '
      'womb, behind a closed cervix. They may feel a gentle rocking, like '
      'when you walk, and nothing more.\n\n'
      'Can it cause a miscarriage? In a healthy pregnancy, no. Most early '
      'losses happen because of a problem in how the pregnancy began, not '
      'because of anything either of you did.\n\n'
      'Can it start labour? Not before your body is ready. Near the due '
      "date families sometimes suggest it to bring labour on, but there's "
      'no good evidence that it works.\n\n'
      'Why does my bump go hard afterwards? The womb often tightens for a '
      "while after an orgasm. It's normal, and it eases with rest. If the "
      'tightenings keep coming regularly, or you have pain, bleeding or '
      'leaking fluid, call your doctor.\n\n'
      "If he's the one who's worried, show him this. Many men feel "
      'protective and pull back without explaining, and a short read can '
      'end weeks of silence.',
    ),
  ),
  MmArticle(
    id: 'closeness_without_sex',
    group: MmArticleGroup.closeness,
    // Added 2026-09-29 (pregnancy gap analysis). ParentVeda editorial,
    // not yet reviewed by a clinician.
    title: _en('Feeling close, with or without sex'),
    teaser: _en(
      'Ways to stay close as a couple when sex is off the table, or just '
      'not wanted.',
    ),
    shortAnswer: _en(
      "Pregnancy changes how you are as a couple, and closeness doesn't "
      'have to mean sex. Touch, time together and talking keep you '
      'connected. It matters most in the weeks your doctor has asked you to '
      'avoid sex.',
    ),
    readingTime: _en('3 MIN'),
    body: _en(
      'Pregnancy changes how you are as a couple. There are new worries, '
      'more family around, less sleep and less time alone. Some weeks sex '
      "just isn't wanted, and some couples have been asked by their doctor "
      'to avoid it.\n\n'
      "Closeness doesn't depend on sex. A long hug, a hand on the bump, "
      'rubbing sore feet or a tired back, sleeping close, or an evening '
      'walk together all keep you connected.\n\n'
      "Protect a little time that's only yours. In a busy house that might "
      'be ten minutes on the terrace, a drive, or tea together before '
      'everyone wakes. Put the phones away.\n\n'
      'Talk about the baby, and also about things that have nothing to do '
      "with the baby. You were a couple before, and you'll be a couple "
      'after.\n\n'
      'Be kind about what each of you can give right now. If one of you '
      'wants more closeness than the other, say it gently, without blame, '
      'and look for something you both feel good about.\n\n'
      'If you find yourselves drifting apart, arguing a lot or not talking, '
      "it can help to see a counsellor together. That isn't a sign of "
      "failure. It's looking after the family you're making.",
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
    whoFor: _en("If you'd like to talk to a trained professional about how "
        'pregnancy is affecting your mind, not just your body.'),
    description: _en('One-to-one sessions with a counsellor trained in '
        'pregnancy and early motherhood. Always anonymous, and always at '
        'your pace.'),
    priceUsd: 25,
    priceInr: 999,
    priceUnit: _en('per session'),
    anonymous: true,
  ),
  MmTalkOffering(
    id: 'one_on_one_consultation',
    kind: MmTalkOfferingKind.consultation,
    title: _en('One-on-one consultation'),
    whoFor: _en('For one worry you want to talk through once, without '
        'seeing a counsellor regularly.'),
    description: _en("A single, focused session to talk through what's on "
        'your mind right now, with clear next steps at the end.'),
    priceUsd: 18,
    priceInr: 749,
    priceUnit: _en('per session'),
  ),
  MmTalkOffering(
    id: 'ongoing_checkin',
    kind: MmTalkOfferingKind.checkin,
    title: _en('Ongoing check-in package'),
    whoFor: _en("If you'd like steady support for the rest of your "
        'pregnancy, not just one conversation.'),
    description: _en('A short call every two weeks with the same '
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
    return _en("What you've described sounds like an ordinary hard "
        'stretch of pregnancy, the kind most mothers go through. The Feel '
        "tab has short things made for this. They're worth trying when it "
        'flares up.');
  }
  if (totalSeverity <= 9) {
    return _en("What you've described has been with you for a while now. "
        'It might help to talk it through with someone who knows pregnancy '
        'and mood well, instead of carrying it alone. Perinatal counselling, '
        "on the Talk tab, is anonymous and it's there for exactly this.");
  }
  return _en("Thank you for answering honestly. What you've described is "
      'worth talking through with someone soon, both a counsellor and your '
      'doctor. Reaching out now tends to make this easier to get through, '
      'and sooner.');
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
