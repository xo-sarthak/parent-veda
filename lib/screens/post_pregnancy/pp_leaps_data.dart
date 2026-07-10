// =============================================================================
//  ParentVeda Leaps - the Wonder Weeks model + seed content
// -----------------------------------------------------------------------------
//  The mental-development "leaps" (Wonder Weeks framework, tuned for Indian
//  homes) are now DATA, not a hard-coded screen. Each leap carries a name, a
//  character label, the age window (in weeks) it usually falls in, a short and a
//  full sectioned description, what the baby is working on, the sunny side, and
//  cross-links (a video, articles, products, a Watch category + Read collection
//  for "view more"). The current leap is derived from the child's age
//  (ChildProfileStore), and the calendar computes real dates from the DOB.
//
//  Content is hand-authored to feel real; a real developmental engine would
//  personalise it later. Nothing here depends on the pregnancy app.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_child_profile.dart';

/// One block of a leap's full description (heading + paragraphs), for the
/// detail screen and the expandable card on the My Child home.
class LeapSection {
  const LeapSection(this.heading, this.paragraphs);
  final String heading;
  final List<String> paragraphs;
}

class Leap {
  const Leap({
    required this.number,
    required this.name, // "The World of Events"
    required this.character, // "Curious Explorer"
    required this.startWeek, // baby-age week the fussy period usually begins
    required this.endWeek, // when it usually settles (≈ next leap's start)
    required this.tagline,
    required this.summary, // 2–3 lines, shown collapsed
    required this.workingOn, // what he's working on (bullets)
    required this.sunnySide,
    required this.sections, // the full, expandable description
    required this.accent,
    this.videoId, // WatchVideo id for the leap video
    this.watchCategory, // Watch category for "view more"
    this.readCollection, // Read collection id for "view more"
    this.articleIds = const [], // ReadArticle ids (leap reads rail)
    this.productIds = const [], // PpProduct ids (leap products rail)
  });

  final int number;
  final String name;
  final String character;
  final double startWeek;
  final double endWeek;
  final String tagline;
  final String summary;
  final List<String> workingOn;
  final String sunnySide;
  final List<LeapSection> sections;
  final Color accent;
  final String? videoId;
  final String? watchCategory;
  final String? readCollection;
  final List<String> articleIds;
  final List<String> productIds;

  /// "Leap 4" — the short header label.
  String get label => 'Leap $number';

  /// The date this leap's window opens/closes, for a given date of birth.
  DateTime startDate(DateTime dob) => dob.add(Duration(days: (startWeek * 7).round()));
  DateTime endDate(DateTime dob) => dob.add(Duration(days: (endWeek * 7).round()));

  /// Rough age-in-months label for the leap window (e.g. "≈4–6 months").
  String get monthsLabel {
    String m(double w) {
      final months = w / 4.345;
      return months < 1 ? '${w.round()}w' : months.toStringAsFixed(months < 10 ? 1 : 0).replaceAll('.0', '');
    }

    return '≈ ${m(startWeek)}–${m(endWeek)} months';
  }
}

const Color _violet = Color(0xFF6A30B6);
const Color _coral = Color(0xFFFF5A79);
const Color _amber = Color(0xFFC98A2B);
const Color _blue = Color(0xFF3E6DA6);
const Color _rose = Color(0xFFD6478A);
const Color _teal = Color(0xFF2F8F83);

// -----------------------------------------------------------------------------
//  The ten leaps of the first ~20 months. Fussy-onset weeks are approximate;
//  every baby's timing varies by a week or two.
// -----------------------------------------------------------------------------
const List<Leap> kLeaps = [
  Leap(
    number: 1,
    name: 'The World of Sensations',
    character: 'New Arrival',
    startWeek: 4.5,
    endWeek: 8,
    accent: _rose,
    tagline: 'The senses wake up, all at once.',
    summary:
        'Around five weeks, your baby becomes far more aware of the world flooding in — light, sound, touch, smell. It can feel overwhelming for such a new little person, so he may be extra fussy and want to be held close.',
    workingOn: [
      'Taking in sharper sights, sounds and smells',
      'Studying your face for longer',
      'The very first tears, and the very first real smile',
    ],
    sunnySide:
        'A more awake, more social baby — longer gazes, the first proper smile, and clearer signals about what he needs.',
    videoId: 'mumwellness',
    watchCategory: 'Parent Stories',
    readCollection: 'parent',
    sections: [
      LeapSection('What is changing', [
        'A newborn spends his first weeks in a soft, blurry world. Around five weeks, his senses sharpen almost overnight: he sees a little further, hears a little more clearly, and begins to notice the difference between one smell, one voice, one face and another.',
        'All of this arriving at once is a lot to take in. That is why this first leap often brings extra crying and a strong need to be held — the world has simply turned up its volume.',
      ]),
      LeapSection('How to walk through it together', [
        'There is nothing to fix here, only to comfort. Hold him close, keep his world calm and unhurried, and let him study your face — it is the most interesting thing in the room.',
        'Skin-to-skin, a quiet voice and a predictable rhythm to the day all help him feel safe while everything is so new and loud.',
      ]),
    ],
  ),
  Leap(
    number: 2,
    name: 'The World of Patterns',
    character: 'Little Watcher',
    startWeek: 7.5,
    endWeek: 12,
    accent: _blue,
    tagline: 'He starts to spot simple patterns.',
    summary:
        'Around eight weeks, your baby begins to recognise simple patterns — the shape of his own hands, the outline of a face, the way light falls. He may discover his hands and stare at them like tiny miracles.',
    workingOn: [
      'Discovering and studying his own hands',
      'Following a moving object with his eyes',
      'Cooing, gurgling and the first sing-song sounds',
    ],
    sunnySide:
        'More head control, longer tracking with his eyes, and the first delicious coos as he finds his voice.',
    videoId: 'q_play',
    watchCategory: 'Play',
    readCollection: 'brain',
    sections: [
      LeapSection('What is changing', [
        'Your baby is beginning to see the world as patterns rather than a single blur. He notices the recurring shapes around him — hands, faces, the slats of his cot — and can hold his gaze on them.',
        'His own hands are a favourite discovery. He will bring them into view and study them, slowly working out that these fascinating things belong to him.',
      ]),
      LeapSection('How to walk through it together', [
        'Give his eyes gentle things to track: a slow-moving toy, your face drifting side to side, a high-contrast pattern. Talk and sing so he can start to link the sound of your voice with the sight of you.',
        'Short bursts of tummy time now build the neck strength he will lean on for every movement to come.',
      ]),
    ],
  ),
  Leap(
    number: 3,
    name: 'The World of Smooth Transitions',
    character: 'Gentle Observer',
    startWeek: 11,
    endWeek: 14,
    accent: _teal,
    tagline: 'He notices smooth, gradual change.',
    summary:
        'Around twelve weeks, your baby perceives smooth transitions — the way your voice glides from high to low, the way light dims, the way movement flows. His own movements grow smoother in step.',
    workingOn: [
      'Smoother, more controlled movements',
      'Turning towards sounds and voices',
      'Squeals, raspberries and a widening range of sounds',
    ],
    sunnySide:
        'A more expressive, wrigglier baby — rolling may appear, and his coos stretch into squeals and laughter.',
    videoId: 'babbling',
    watchCategory: 'Language',
    readCollection: 'play',
    sections: [
      LeapSection('What is changing', [
        'Until now the world moved in jumps for your baby. In this leap he begins to perceive smooth, gradual change — a voice sliding up and down, a hand moving in one flowing arc, the light softening at dusk.',
        'His own body follows suit. Jerky newborn movements give way to smoother reaching, turning and wriggling.',
      ]),
      LeapSection('How to walk through it together', [
        'Play with the smoothness he is discovering: glide a toy slowly through the air, swoop your voice high and low, sway him gently. He will love the flow of it.',
        'Keep offering tummy time and safe floor space — this is often when the first roll surprises everyone.',
      ]),
    ],
  ),
  Leap(
    number: 4,
    name: 'The World of Events',
    character: 'Curious Explorer',
    startWeek: 14.5,
    endWeek: 22,
    accent: _violet,
    tagline: 'One thing leads to another — cause meets effect.',
    summary:
        'Around four months, your baby grasps that one thing leads smoothly to another: his hand reaches, and the toy moves. Cause, meet effect. Taking that in is genuinely disorienting, which is why he clings a little tighter to you.',
    workingOn: [
      'Watching his hands and reaching with real intent',
      'Rolling toward the things he wants',
      'Grasping that his actions make things happen',
    ],
    sunnySide:
        'A calmer, more capable baby — steadier reaching, the first real rolls, and longer, settled sleep stretches.',
    videoId: 'leap4brain',
    watchCategory: 'Brain Development',
    readCollection: 'brain',
    articleIds: ['leap4', 'sleepcycles'],
    productIds: ['dozy'],
    sections: [
      LeapSection('The world of events', [
        'Around four months, babies enter what is often called Leap 4 — “the world of events”. For the first time, your baby grasps that one thing leads smoothly to another: your hand reaches, and the toy moves.',
        'It sounds small. It is enormous. The whole world suddenly has a logic to it — and taking that in is genuinely disorienting, which is exactly why he clings a little tighter to the person who makes him feel safe: you.',
      ]),
      LeapSection('“Nazar lag gayi?” — probably not', [
        'Clingy and crying more, off his feeds and sleep? In many homes the first thought is the evil eye. It is almost always just Leap 4’s fussiness — and it passes. This is growth, not misfortune.',
      ]),
      LeapSection('How to walk through it together', [
        'Leaps pass, and a new skill usually appears on the far side — a first roll, a new sound, a longer gaze. Until then, more closeness helps, not less.',
        'Slow, narrated play — “here comes the ball… and it rolls” — gives his new understanding something to chew on. Name the cause and the effect out loud, and you hand him words for the very thing his brain is discovering.',
      ]),
    ],
  ),
  Leap(
    number: 5,
    name: 'The World of Relationships',
    character: 'Little Investigator',
    startWeek: 22,
    endWeek: 26,
    accent: _coral,
    tagline: 'Distance, and the space between things.',
    summary:
        'Around six months, your baby understands relationships — near and far, in and out, the gap between you and him. Realising you can move away is exactly why the first separation anxiety often begins now.',
    workingOn: [
      'Understanding near and far, in and out',
      'Reaching around and behind for hidden things',
      'The first wariness when you leave the room',
    ],
    sunnySide:
        'A more determined explorer — sitting steadier, reaching further, and delighting in games like peekaboo.',
    videoId: 'leap4brain',
    watchCategory: 'Brain Development',
    readCollection: 'brain',
    productIds: ['dozy'],
    sections: [
      LeapSection('The world of relationships', [
        'In this leap your baby begins to grasp the idea of distance — that things (and people) can be near or far, and that the space between them can change. He can now sense that you might move away from him.',
        'That new understanding is the root of the first real separation anxiety. It is not a step back; it is a sign he has worked out just how much you matter.',
      ]),
      LeapSection('How to walk through it together', [
        'Play with distance in ways that feel safe and fun: peekaboo, rolling a ball back and forth, hiding a toy under a cloth and revealing it. Each game teaches him that things — and you — come back.',
        'When he clings, a warm goodbye and a reliable return teach him far more than slipping away unseen. Consistency is the reassurance he is looking for.',
      ]),
    ],
  ),
  Leap(
    number: 6,
    name: 'The World of Categories',
    character: 'Little Sorter',
    startWeek: 33,
    endWeek: 37,
    accent: _amber,
    tagline: 'He starts to sort the world into groups.',
    summary:
        'Around eight months, your baby begins to categorise — that a dog is a dog whether big or small, that food is food. He studies, compares and sorts, and may become choosier and more particular.',
    workingOn: [
      'Grouping similar things — animals, foods, faces',
      'Examining objects closely, turning them over',
      'Early understanding of a few familiar words',
    ],
    sunnySide:
        'A little scientist — closer inspection, clearer preferences, and the first flashes of understanding when you name things.',
    watchCategory: 'Brain Development',
    readCollection: 'brain',
    sections: [
      LeapSection('The world of categories', [
        'Your baby is learning that the world sorts into groups. He begins to understand that all dogs are somehow “dog”, that different foods share something in common, that faces belong to a category of their own.',
        'To build these categories he studies things intently — turning a toy over, comparing, testing. He may also grow choosier, because he can now tell one option from another.',
      ]),
      LeapSection('How to walk through it together', [
        'Name and group the world for him: “this is a ball, and this is also a ball”. Sorting games, picture books and simple naming all feed the categories he is building.',
        'Let him inspect safe objects closely — this careful study is exactly how the sorting gets done.',
      ]),
    ],
  ),
  Leap(
    number: 7,
    name: 'The World of Sequences',
    character: 'Order Maker',
    startWeek: 41,
    endWeek: 46,
    accent: _blue,
    tagline: 'He learns that steps come in order.',
    summary:
        'Around ten months, your baby understands sequences — that to reach a goal, things happen in order. He starts to do things in steps, and loves stacking, posting and putting-things-into-other-things.',
    workingOn: [
      'Doing things in the right order to reach a goal',
      'Stacking, posting and nesting toys',
      'Pointing, waving and simple gestures',
    ],
    sunnySide:
        'A more purposeful little person — following simple steps, copying you, and communicating with gestures.',
    watchCategory: 'Activities',
    readCollection: 'play',
    sections: [
      LeapSection('The world of sequences', [
        'Now your baby grasps that reaching a goal means doing things in the right order — you have to open the box before you can take out the toy. He begins to plan in little steps.',
        'This is why posting shapes, stacking cups and “putting-in and taking-out” games become endlessly fascinating.',
      ]),
      LeapSection('How to walk through it together', [
        'Offer toys that reward a sequence: stacking rings, cups to nest, simple shape-posters. Narrate the steps as you go so he hears the order.',
        'Let him try, fail and try again — the persistence is the point, and the finished stack is his reward.',
      ]),
    ],
  ),
  Leap(
    number: 8,
    name: 'The World of Programs',
    character: 'Little Helper',
    startWeek: 50,
    endWeek: 55,
    accent: _teal,
    tagline: 'Flexible routines, not just fixed steps.',
    summary:
        'Around the first birthday, your baby understands “programs” — that a routine like mealtime or bathtime can flex and still reach the same end. He loves to imitate everyday tasks and help.',
    workingOn: [
      'Understanding familiar routines and their variations',
      'Imitating everyday jobs — sweeping, wiping, “calling”',
      'First words and clearer communication',
    ],
    sunnySide:
        'A budding helper — copying your day, following short routines, and beginning to make himself understood.',
    watchCategory: 'Behaviour',
    readCollection: 'behaviour',
    sections: [
      LeapSection('The world of programs', [
        'A “program” is a routine that can flex and still work — breakfast can be poha or idli and still be breakfast; the path to the park can vary and still get there. Around his first birthday, your baby begins to understand these flexible sequences.',
        'He loves to imitate the programs he sees you run all day: wiping a table, stirring a pot, holding a phone to his ear.',
      ]),
      LeapSection('How to walk through it together', [
        'Invite him into your routines. Let him “help” with safe, simple tasks and narrate what you are doing. Predictable rhythms to the day help him feel secure while so much is changing.',
        'Pretend play — feeding a doll, sweeping with a little broom — is his way of practising the programs of life.',
      ]),
    ],
  ),
  Leap(
    number: 9,
    name: 'The World of Principles',
    character: 'Little Negotiator',
    startWeek: 59,
    endWeek: 64,
    accent: _rose,
    tagline: 'He experiments, tests and negotiates.',
    summary:
        'Around fourteen months, your toddler grasps principles — that he can vary his approach, plan ahead and negotiate. This is where experimenting, testing limits and the first “no” really begin.',
    workingOn: [
      'Planning ahead and trying different strategies',
      'Testing limits — and your reactions',
      'Big emotions with few tools to manage them',
    ],
    sunnySide:
        'A creative problem-solver — more independent, more inventive, and beginning to understand simple rules.',
    watchCategory: 'Behaviour',
    readCollection: 'behaviour',
    articleIds: ['tantrums'],
    sections: [
      LeapSection('The world of principles', [
        'Your toddler now understands that he can choose how to do something — he can plan, experiment and adjust. He tests what happens if he throws the spoon, refuses the shoe, or tries a different route to the same goal.',
        'This testing is not defiance; it is research. He is learning the principles that govern how people and things behave — including you.',
      ]),
      LeapSection('How to walk through it together', [
        'Offer safe choices so his new sense of agency has somewhere to go: “this cup or that one?”. Keep the important limits kind, clear and consistent.',
        'Tantrums often arrive with this leap — big feelings meeting a brain that cannot yet manage them. Get low, stay calm, and lend him yours.',
      ]),
    ],
  ),
  Leap(
    number: 10,
    name: 'The World of Systems',
    character: 'Little Individual',
    startWeek: 70,
    endWeek: 77,
    accent: _violet,
    tagline: 'A sense of self begins to form.',
    summary:
        'Around seventeen months, your toddler grasps systems — that principles can flex to fit the situation, and that he is his own person. The beginnings of conscience, empathy and “me, mine” appear.',
    workingOn: [
      'A dawning sense of “me”, “mine” and “you”',
      'First flickers of empathy and conscience',
      'Pretend play growing richer and more imaginative',
    ],
    sunnySide:
        'A little individual — more empathetic, more imaginative, and beginning to understand how his world fits together.',
    watchCategory: 'Behaviour',
    readCollection: 'behaviour',
    sections: [
      LeapSection('The world of systems', [
        'A “system” is bigger than a single rule — it is understanding that principles can bend to fit the moment, and that he himself is one whole person moving through the world. This is where a real sense of self takes root.',
        'With it come the first signs of conscience and empathy: a hug when someone is sad, a proud “mine”, the dawn of “I did it”.',
      ]),
      LeapSection('How to walk through it together', [
        'Name feelings — his and others’ — to feed the empathy that is emerging. Give him gentle responsibilities and celebrate the small independences.',
        'Rich pretend play, stories and time with other children all help him understand the systems of people and relationships he is now aware of.',
      ]),
    ],
  ),
];

// ---- lookups + engine -------------------------------------------------------
Leap leapByNumber(int n) => kLeaps.firstWhere((l) => l.number == n, orElse: () => kLeaps.first);

/// The index in kLeaps of the leap a child of [ageWeeks] is currently in —
/// the most recent leap whose window has opened. Clamped to the valid range.
int currentLeapIndex(double ageWeeks) {
  var idx = 0;
  for (var i = 0; i < kLeaps.length; i++) {
    if (kLeaps[i].startWeek <= ageWeeks) idx = i;
  }
  return idx;
}

/// The leap the given child is in right now (defaults to the seeded child).
Leap currentLeap([ChildProfileStore? child]) {
  final c = child ?? ChildProfileStore.instance;
  return kLeaps[currentLeapIndex(c.ageInWeeks)];
}

/// The next leap after the child's current one (null if already at the last).
Leap? nextLeap([ChildProfileStore? child]) {
  final c = child ?? ChildProfileStore.instance;
  final i = currentLeapIndex(c.ageInWeeks);
  return i + 1 < kLeaps.length ? kLeaps[i + 1] : null;
}

/// How far through the current leap's window the child is, as 0..1 (for the
/// "past the worst / to sunny" progress bar).
double leapProgress([ChildProfileStore? child]) {
  final c = child ?? ChildProfileStore.instance;
  final l = currentLeap(c);
  final span = (l.endWeek - l.startWeek);
  if (span <= 0) return 0;
  return ((c.ageInWeeks - l.startWeek) / span).clamp(0.0, 1.0);
}
