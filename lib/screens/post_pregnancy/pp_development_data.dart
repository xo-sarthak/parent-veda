// =============================================================================
//  ParentVeda Development - content model, seed data + store
// -----------------------------------------------------------------------------
//  A Development COMPANION (not a tracker / assessment / checklist): helps
//  parents understand what's developing, what comes next, and how to support it
//  TODAY. Supportive language only (Emerging → Mastered), never "behind/delayed".
//  Feels playful and optimistic (vs. Health's calm structure). Seeded for Aarav
//  (~4 months); a real Development/Age/Brain engine slots in later. No gamification
//  - no points, streaks or badges. Nothing here depends on the pregnancy app.
// =============================================================================

import 'pp_grow_activities.dart';
import 'pp_phase_doc_activities.dart' show kPhaseDocActivities;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../../services/remote/cloud_synced_store.dart'; // kept for revert (step 13)
import '../../services/remote/cloud_merged_store.dart';
import 'pp_child_profile.dart' show ChildProfileStore;

/// Supportive progress words - never percentages, never grades.
enum DevWord { emerging, practicing, growing, confident, mastered }

String devWordLabel(DevWord w) => switch (w) {
      DevWord.emerging => 'Emerging',
      DevWord.practicing => 'Practicing',
      DevWord.growing => 'Growing',
      DevWord.confident => 'Confident',
      DevWord.mastered => 'Mastered',
    };

/// A gentle 0..1 fill for the soft progress arc - visual encouragement, not a score.
double devWordFraction(DevWord w) => switch (w) {
      DevWord.emerging => 0.25,
      DevWord.practicing => 0.45,
      DevWord.growing => 0.65,
      DevWord.confident => 0.85,
      DevWord.mastered => 1.0,
    };

/// One step on a developmental journey (a story, not a checkbox).
class DevStage {
  const DevStage(this.name, this.status, this.meaning, this.why, {this.activities = const []});
  final String name;
  final String status; // 'mastered' | 'current' | 'next' | 'future'
  final String meaning;
  final String why;
  final List<String> activities; // DevActivity ids to encourage it
}

class DevArea {
  const DevArea({
    required this.id,
    required this.name,
    this.shortName = '',
    required this.icon,
    required this.accent,
    required this.word,
    required this.stage,
    required this.summary,
    required this.todayTip,
    required this.brainNote,
    required this.journey,
    required this.seed,
    this.about = const [],
    this.nextActivityId,
    this.relatedArticle,
    this.relatedVideoId,
  });
  final String id;
  final String name;

  /// THE NAME A PARENT TAPPED, which is not always the name of the field.
  ///
  /// The My Child snapshot calls these Brain / Physical / Language / Emotional;
  /// `name` is the developmental term ("Thinking & Problem Solving"). Tapping
  /// "Brain" and landing on a page headed with a phrase you have never seen is
  /// the specific complaint this fixes — the review asked for the category name
  /// at the top of the page to match the one on My Child.
  ///
  /// Defaults to empty and falls back to [name] via [label], so the eight areas
  /// did not all have to be edited at once and any new area works without it.
  final String shortName;

  /// What to put at the top of a page. Always prefer what the parent tapped.
  String get label => shortName.isEmpty ? name : shortName;

  final IconData icon;
  final Color accent;
  final DevWord word;
  final String stage; // current stage label
  final String summary; // one line
  final String todayTip; // one thing a parent can do today
  final String brainNote;
  final List<DevStage> journey;
  final int seed;
  final List<String> about; // 2–3 paragraph description for the area screen
  final String? nextActivityId;
  final String? relatedArticle;
  final String? relatedVideoId;

  /// The area's full description; falls back to summary + brain note if no
  /// dedicated `about` copy has been written yet.
  List<String> get description => about.isNotEmpty ? about : [summary, brainNote];
}

class DevActivity {
  const DevActivity({
    required this.id,
    required this.title,
    required this.areaId,
    required this.minutes,
    required this.difficulty,
    required this.ageTag,
    required this.materials,
    required this.skills,
    required this.safety,
    required this.benefit,
    required this.steps,
    required this.seed,
    this.intro,
    this.remember = const [],
    this.variations,
    this.linkedMilestones = const [],
  });
  final String id;
  final String title;
  final String areaId;

  /// 0 for an activity from the phase docs, which give no duration — the
  /// screens then say [timeLabel]'s "At your pace" rather than a made-up
  /// number (the doc is the source of truth, 2026-10-13).
  final int minutes;

  /// Empty for a phase-doc activity, for the same reason.
  final String difficulty;
  final String ageTag;
  final List<String> materials;
  final List<String> skills;
  final List<String> safety;
  final String benefit;
  final List<String> steps;
  final int seed;

  // ---- from the phase docs (pp_phase_docs.dart), null/empty elsewhere ----
  /// The doc's opening paragraph: what the activity is.
  final String? intro;

  /// "Things to Remember".
  final List<String> remember;
  final String? variations;

  /// "Linked Milestones", by milestone title.
  final List<String> linkedMilestones;

  /// "5 min", or "At your pace" when the source gives no duration.
  String get timeLabel => minutes > 0 ? '$minutes min' : 'At your pace';

  /// "5 min · Easy", leaving out whatever the source does not give.
  String get metaLine => [timeLabel, if (difficulty.isNotEmpty) difficulty].join(' · ');

  /// True for an activity that came from the phase docs.
  bool get fromPhaseDoc => intro != null;
}

class BrainTopic {
  const BrainTopic(this.title, this.body, this.tip);
  final String title;
  final String body;
  final String tip;
}

class LookAhead {
  const LookAhead(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

class CheckInQ {
  const CheckInQ(this.areaId, this.text,
      {this.redFlag = false, this.yesIsConcern = false, this.askFrom = 0, this.flagFrom = 0});
  final String areaId;

  /// ⚠️ THE AGE IT IS FAIR TO ASK (tools pass, Development, 2026-10-25). The
  /// 0-6 month questions used to start at birth, so a two-week-old honestly
  /// got "Not yet" on smiling back and turning to voices, both act-early
  /// signs, and her mother was told "Worth a word with your doctor". A
  /// question is asked only from [askFrom] months (corrected age).
  final int askFrom;

  /// The age a "not yet" here becomes an act-early sign. Before it, a "not
  /// yet" counts as an ordinary one. Taken from the milestones data's
  /// "mention it by around" month (`pp_milestones_data.dart`), so the two
  /// tools never disagree; where the milestones have no matching item, from
  /// CDC/AAP 2022. REQUIRED_REVIEW (paediatrician), listed in BEFORE-LAUNCH.
  final int flagFrom;

  /// From when a "not yet" here counts at all, toward a sign or toward the
  /// three that make it worth asking. Before it, the skill is still coming.
  /// A red flag: its [flagFrom]. A lost skill: as soon as it is asked. An
  /// ordinary question: three months after it is first asked, so a baby who
  /// has only just reached a question's age is not counted against it (at 2
  /// months three honest "not yet"s used to add up to "worth asking").
  int get countsFrom => yesIsConcern
      ? askFrom
      : flagFrom > 0
          ? flagFrom
          : askFrom > 0
              ? askFrom + 3
              : 0;

  /// The question, authored with he/him/his (filled for the child on screen
  /// with `ppFillChild`). ALSO THE STORAGE KEY: never fill it before storing.
  final String text;

  /// ⚠️ ONE OF THE "ACT EARLY" SIGNS (CDC/AAP 2022), added 2026-10-07 (gap
  /// analysis P1: "The check-in never escalates"). A "not yet" here is worth a
  /// word with the paediatrician on its own; elsewhere it takes three.
  /// REQUIRED_REVIEW (paediatrician): which questions carry it.
  final bool redFlag;

  /// For "has he lost a skill": here YES is the answer to act on.
  final bool yesIsConcern;
}

/// The question every band ends with. A loss of skills at any age is the one
/// sign that always goes to the doctor (CDC "act early").
// Asked from 6 months: a two-month-old has no words or walking to lose.
const CheckInQ kCheckInLostSkill = CheckInQ('all',
    'Has he lost a skill he used to have, like words, sounds or walking?',
    redFlag: true, yesIsConcern: true, askFrom: 6);

/// What the answers add up to: whether to suggest the paediatrician.
/// Any red-flag "not yet", a lost skill, or three or more "not yet"s.
/// With [months] (corrected age), a "not yet" counts only from its
/// [CheckInQ.countsFrom]; before that the skill is still coming.
bool checkInWorthAsking(List<CheckInQ> qs, bool? Function(String text) answer, {int? months}) {
  var notYet = 0;
  for (final q in qs) {
    final a = answer(q.text);
    if (a == null) continue;
    final concern = q.yesIsConcern ? a == true : a == false;
    if (!concern) continue;
    if (months != null && months < q.countsFrom) continue;
    if (q.redFlag) return true;
    notYet++;
  }
  return notYet >= 3;
}

/// A "yes" to a lost skill: the one answer that shows the result at once,
/// without waiting for the rest.
bool checkInLostSkill(List<CheckInQ> qs, bool? Function(String text) answer) =>
    qs.any((q) => q.yesIsConcern && answer(q.text) == true);

// ---- development areas ------------------------------------------------------
const Color _amber = Color(0xFFC98A2B);
const Color _blue = Color(0xFF3E6DA6);
const Color _rose = Color(0xFFD6478A);
const Color _violet = Color(0xFF7C5CC4);

const List<DevArea> kDevAreas = [
  DevArea(
    id: 'cognitive',
    shortName: 'Brain',
    name: 'Thinking & Problem Solving',
    icon: Icons.psychology_outlined,
    accent: Color(0xFF6A30B6),
    word: DevWord.growing,
    stage: 'Cause & effect',
    summary: 'Working out that one thing makes another happen.',
    todayTip: 'Show him a simple cause and effect, shake a rattle, then pause, and let him take it in.',
    brainNote: 'His brain is wiring the idea that his actions change the world, the seed of all problem-solving.',
    seed: 1,
    about: [
      'Thinking begins with a simple discovery: one thing makes another happen. Right now your baby is working out that his own reaching hand is what makes the toy move. That is cause and effect, and every later bit of problem-solving is built on it.',
      'You will see it in the way he studies things. He follows your hand all the way to the toy, watches what happens when he bats at a rattle, and starts to expect the peekaboo before it comes. He is running tiny experiments all day long.',
      'None of this needs flashcards or “brain-training”. It needs everyday moments where his actions clearly change something, and a calm narrator (you) putting words to what he is figuring out.',
    ],
    nextActivityId: 'peekaboo',
    /* relatedVideoId: 'leap4brain', retired with the leaps 2026-10-14; new phase films to come */
    journey: [
      DevStage('Notices contrast', 'mastered', 'He locks onto bold edges: black and white, a striped cushion, the line of your hairline against your face. Colour and fine detail come later; right now it is contrast that his eyes can actually resolve.', 'This is attention being built from nothing. Before he can learn anything about the world, he needs to hold his gaze on one part of it. A strong edge is the easiest thing to hold onto.'),
      DevStage('Follows a moving toy', 'mastered', 'His eyes travel with something as you move it across him, and after a while his head follows too. Slow and close works far better than fast and far.', 'Tracking is the first time he predicts rather than reacts. His eyes arrive where the toy is going, not where it was. That same prediction is what later lets him reach for it.'),
      DevStage('Cause & effect', 'current', 'He works out that HE did that. A hand swipes, the rattle sounds; a kick lands, the pram toy swings. You will see him do it again on purpose, watching to check it happens twice.', 'This is the beginning of thinking rather than sensing. It is also the first time he learns he has an effect on the world. Confidence grows from that, and so does every experiment he will ever run.', activities: ['peekaboo', 'highcontrast']),
      DevStage('Object permanence', 'next', 'A toy under a cloth stops being gone and starts being hidden. Early on he looks where it disappeared; later he lifts the cloth to check.', 'It changes what absence means. It is why peekaboo becomes hilarious rather than alarming. A little later, it is also why you leaving the room becomes worth protesting about. Both come from the same new idea.', activities: ['peekaboo']),
      DevStage('Simple problem solving', 'future', 'He wants a toy, something is in the way, and instead of giving up or crying he goes around it. A cushion gets pushed aside, an arm reaches past a leg.', 'Two things are happening at once: he is holding a goal in mind, and he is trying a second route when the first fails. Persistence is not a personality trait yet, it is a skill, and this is it being practised.'),
    ],
  ),
  DevArea(
    id: 'language',
    shortName: 'Language',
    name: 'Language & Communication',
    icon: Icons.chat_bubble_outline_rounded,
    accent: Color(0xFFFF5A79),
    word: DevWord.emerging,
    stage: 'Musical babble',
    summary: 'Coos stretching into “aah-goo”, squeals and raspberries.',
    todayTip: 'Have a “conversation”: say something, then pause and wait for his coo, and answer it back.',
    brainNote: 'Long before words, his brain is mapping the rhythm and melody of your voice.',
    seed: 2,
    about: [
      'The conversation starts long before the first word. Your baby is soaking up the melody, rhythm and turn-taking of language now, in every coo and every reply you give back. This is the groundwork the first words will stand on.',
      'He is learning that sounds mean something, that his voice earns a response, and that talking happens back-and-forth. Squeals, raspberries and sing-song “aah-goo” are all rehearsal, and the more you answer them, the more he practises.',
      'The simplest things matter most: narrate your day, sing, and pause to leave room for his reply. You do not need to teach words; you just need to have the conversation.',
    ],
    nextActivityId: 'narrate',
    relatedArticle: 'Talking to your baby before they can talk',
    relatedVideoId: 'babbling',
    journey: [
      DevStage('Cooing', 'mastered', 'Soft open vowels like aah, ooh and ngah, usually aimed at your face. They come when he is calm and fed and you are close enough for him to see you properly.', 'These are not random noises. He is discovering that he owns the sound, and that making it brings your face closer. That is the whole shape of a conversation, learned before a single word.'),
      DevStage('Musical babble', 'current', 'Squeals, raspberries, growls and long sing-song runs. It rises and falls like speech without any of the words being real yet.', 'He is rehearsing the MUSIC of language before the vocabulary: the rhythm and the melody of the language he hears at home. A baby in a Hindi-speaking house babbles with a different tune from one in an English-speaking house, long before either says a word.', activities: ['narrate', 'song']),
      DevStage('Turn-taking', 'next', 'You say something, he waits, and then he answers. Leave a gap and he fills it; talk over him and he stops.', 'Of everything he learns about talking, this may help most, and it is all about your pauses rather than your words. Conversation is a rhythm first and a vocabulary second.', activities: ['narrate']),
      DevStage('Babble with consonants', 'future', 'Ba-ba, da-da, ma-ma arrive and get repeated endlessly. At first they mean nothing at all, however much everyone in the house insists otherwise.', 'Consonants need lips, tongue and breath working together, so this is a physical achievement as much as a language one. The syllables he practises now are the ones his first real words will be made of.'),
      DevStage('First words', 'future', 'One sound starts meaning one thing, reliably: the same noise for milk, or for the dog, every time. It often is not a word an adult would recognise.', 'The leap is not the pronunciation, it is the idea that a sound can STAND FOR something that is not present. Understanding comes well before speaking here: he knows far more words than he can say, and that gap is normal.'),
    ],
  ),
  DevArea(
    id: 'gross_motor',
    shortName: 'Physical',
    name: 'Gross Motor',
    icon: Icons.directions_run_rounded,
    accent: _amber,
    word: DevWord.practicing,
    stage: 'Rolling',
    summary: 'Pushing up strong on the floor, rocking, a first roll is near.',
    todayTip: 'A little tummy time with a toy just out of reach, it builds the strength to roll.',
    brainNote: 'Each push-up wires the neck, core and coordination he’ll build every future move on.',
    seed: 3,
    about: [
      'Every big movement builds on the last. Head control came first; now your baby is pushing up strong on the floor and rocking, and the first roll is close. Each of these is a rung on the ladder that leads to sitting, crawling and, eventually, those first steps.',
      'This is physical strength and brain wiring at the same time: every push-up and wobble is teaching his neck, core and coordination to work together. Being on the floor, free to move, is the best thing for it.',
      'You cannot rush the timeline. Every baby arrives at each move in his own week. What helps is plenty of safe, happy floor time and a little something just out of reach to tempt him toward it.',
    ],
    nextActivityId: 'tummy_play',
    relatedVideoId: 'tummytime',
    journey: [
      DevStage('Head control', 'mastered', 'His head stops needing your hand. He holds it steady when upright, and lifts it while lying on his front.', 'Almost everything else waits on this. He cannot look around, reach, sit or feed himself until his head is stable, so this is less a milestone than the platform the others are built on.'),
      DevStage('Pushes up on forearms', 'mastered', 'On his tummy he plants his elbows and lifts his chest clear of the floor, and can hold it there long enough to look around.', 'It builds the shoulders, back and neck that rolling and crawling will need. It also changes what he can see, from a nose-to-the-mat view to the whole room. Short, frequent stretches beat one long one.'),
      DevStage('Rolling', 'current', 'Rocking turns into a roll, usually tummy to back first because it takes less strength, and back to tummy weeks or months later.', 'It is the first time he changes where he is without anyone carrying him. It is also the first real reason to stop leaving him alone on a bed or sofa. Independence and hazard arrive on the same afternoon.', activities: ['tummy_play', 'roll_help']),
      DevStage('Sitting with support', 'next', 'Propped on cushions or on your leg he holds himself upright, wobbling, and topples cheerfully. Unsupported sitting follows once his trunk catches up.', 'Sitting frees his hands. Lying down, a baby needs his arms for stability; upright, both hands can explore at once. That is why so much fine-motor progress arrives just after he can sit.'),
      DevStage('Crawling', 'future', 'Commando shuffling, bottom-scooting, rolling across a room, or a textbook hands-and-knees crawl. All of them count, and some babies skip it entirely and go straight to pulling up.', 'The point is self-directed movement, not the style. He can now decide where to be, which changes how he learns: the world stops being what you bring him and becomes what he goes and finds.'),
      DevStage('Standing & walking', 'future', 'He pulls up on furniture, cruises sideways along it, and eventually lets go. First steps are wide, stiff-armed and short.', 'The range here is wide. Anywhere from 9 to 18 months is ordinary, and early walking predicts nothing about later ability. What he gains is his hands: a walking child can carry something to you.'),
    ],
  ),
  DevArea(
    id: 'fine_motor',
    shortName: 'Hands',
    name: 'Fine Motor',
    icon: Icons.back_hand_outlined,
    accent: _blue,
    word: DevWord.emerging,
    stage: 'Reaching & grasping',
    summary: 'Hands find each other; he swipes and grabs at dangling toys.',
    todayTip: 'Offer a light, easy-to-hold toy at his midline and let him reach and grasp.',
    brainNote: 'Hand-eye coordination is being wired, every grab is his brain aiming and adjusting.',
    seed: 4,
    nextActivityId: 'reach_ring',
    /* relatedVideoId: 'leap4brain', retired with the leaps 2026-10-14; new phase films to come */
    journey: [
      DevStage('Hands to midline', 'mastered', 'He brings both hands together in front of his chest, usually finds them with his eyes, and often takes them straight to his mouth.', 'Working across the middle of the body is harder than it sounds and it is a prerequisite for anything two-handed. It is also how he discovers his hands are HIS, which is the beginning of a body he owns.'),
      DevStage('Reaching & grasping', 'current', 'Swiping near a toy becomes a deliberate reach, and then a closed fist around it. Aim is poor at first, and improves fast with practice.', 'Reaching is eye and hand agreeing about where something is. It is also his first tool for satisfying his own curiosity: until now, whatever he wanted to examine had to be brought to him.', activities: ['reach_ring', 'texture']),
      DevStage('Transfers hand to hand', 'next', 'A toy in one hand gets passed to the other, often with a pause in the middle while both hands hold it.', 'It needs the two halves of his brain to cooperate, and it doubles what he can do: one hand can hold while the other explores. Most self-feeding depends on this without anyone noticing.'),
      DevStage('Pincer grasp', 'future', 'Finger and thumb close on something small: a pea, a crumb, a bit of thread off the floor. It starts raking and refines to a neat pinch.', 'This is the hand becoming precise, and it is what makes real self-feeding possible. It is also why floor sweeping matters more from now on: anything he can pinch, he can lift, and anything he can lift goes in his mouth.'),
    ],
  ),
  DevArea(
    id: 'emotional',
    shortName: 'Emotional',
    name: 'Emotional',
    icon: Icons.favorite_border,
    accent: _rose,
    word: DevWord.growing,
    stage: 'Borrowing your calm',
    summary: 'Beams with joy, and settles fastest in your steady arms.',
    todayTip: 'When he fusses, slow your own breathing and voice, he tunes to your calm.',
    brainNote: 'He can’t regulate emotions alone yet, so he borrows yours. That’s co-regulation.',
    seed: 5,
    about: [
      'Your baby feels big feelings, but he has none of the tools to manage them yet, so he borrows yours. When he settles fastest in your steady arms, that is not a habit to break; it is exactly how emotional development is meant to work at this age.',
      'This is called co-regulation: your calm voice and slow breathing settle his nervous system. Every time you soothe him, you are laying down the wiring he will one day use to soothe himself.',
      'The social side is growing too. He beams across a room, and a laugh now earns a laugh back. Warm, responsive back-and-forth is what teaches him that he is safe, loved and understood.',
    ],
    relatedVideoId: 'mumwellness',
    journey: [
      DevStage('Social smile', 'mastered', 'A smile aimed at a person, in response to a face or a voice, rather than the fleeting smiles of sleep and wind that came before it.', 'It is the first thing he does purely to connect, with nothing to gain. For most parents it is also the moment the exhausting early weeks start paying something back, which matters more than anyone admits.'),
      DevStage('Borrowing your calm', 'current', 'When he is upset your steady voice and unhurried hands settle him. Not instantly, and not every time, but noticeably.', 'A baby cannot calm himself yet, so he uses yours. Every time it works he learns that big feelings end, which is the thing he will eventually be able to do alone. It is also why your own calm is worth protecting.', activities: ['song']),
      DevStage('Expressing delight', 'next', 'Belly laughs, squeals, kicking with excitement. Then he repeats whatever caused it, looking at you to do it again.', 'His feelings stop being only comfort and distress and start having range. Sharing the joy is the new part: the laugh is aimed at you, not just produced near you.'),
      DevStage('Self-soothing begins', 'future', 'A thumb, a fist, a corner of cloth, turning his head away from too much. Small, unglamorous strategies that take the edge off.', 'These are his first tools for managing himself, and they arrive alongside your comfort rather than replacing it. Needing you and having a thumb are not in competition.'),
    ],
  ),
  DevArea(
    id: 'social',
    shortName: 'Social',
    name: 'Social',
    icon: Icons.groups_outlined,
    accent: _violet,
    word: DevWord.growing,
    stage: 'You are his world',
    summary: 'Your face is the best thing in the room; a laugh earns a laugh.',
    todayTip: 'Play face-to-face: exaggerate your expressions and watch him copy and respond.',
    brainNote: 'He’s learning that people are special and responsive, the root of all relationships.',
    seed: 6,
    nextActivityId: 'peekaboo',
    journey: [
      DevStage('Prefers faces', 'mastered', 'Given anything else to look at, he chooses a face, and yours above the others. Eye contact holds longer than it did.', 'Faces are where everything social begins, and he is wired to find them before he is wired for anything else. In a joint family this is also how he sorts the people around him into familiar and new.'),
      DevStage('Social back-and-forth', 'current', 'He smiles or vocalises AT you, waits, and brightens when you answer. Stop answering and he tries harder, then gives up.', 'This is serve and return, one of the best-supported ideas in early development, and it needs nothing but your attention. What builds his brain here is that the answer comes back, not what the answer is.', activities: ['peekaboo', 'narrate']),
      DevStage('Enjoys games', 'next', 'Peekaboo, this-little-piggy, gonna-get-you. He starts anticipating the ending and laughing before it arrives.', 'Anticipating means he is holding a sequence in mind and predicting what comes next. The delight is real, and so is the thinking underneath it.'),
      DevStage('Stranger awareness', 'future', 'New faces get a long stare, a turned-away head, or tears. That includes relatives he was happy with last month.', 'It looks like a step backwards and it is the opposite: he can now tell his people from everyone else, which is exactly what attachment is. In a house with many visitors this can be hard on everyone, and it passes.'),
    ],
  ),
  DevArea(
    id: 'creativity',
    shortName: 'Creativity',
    name: 'Creativity & Imagination',
    icon: Icons.palette_outlined,
    accent: Color(0xFFFF5A79),
    word: DevWord.emerging,
    stage: 'Exploring the senses',
    summary: 'Fascinated by texture, contrast and sound, his first “art”.',
    todayTip: 'Offer safe things with different textures to touch, soft, crinkly, smooth.',
    brainNote: 'Rich sensory input now builds the pathways later imagination and creativity will use.',
    seed: 7,
    nextActivityId: 'texture',
    journey: [
      DevStage('Sensory delight', 'current', 'He seeks out texture, contrast, light and sound: a steel bowl, a crumpled dupatta, sunlight through a curtain.', 'Everything he will later imagine is built from things he has actually felt. The ordinary house is better material than most toys, and free.', activities: ['texture', 'highcontrast']),
      DevStage('Exploring with mouth & hands', 'next', 'Everything goes in the mouth, and gets turned over, banged and dropped on the way there.', 'His mouth has more nerve endings than his fingers do, so mouthing is real investigation rather than a habit to stop. It does mean small objects and floor sweeping need real attention now.'),
      DevStage('Cause-and-effect play', 'future', 'Deliberate banging, dropping, shaking and posting, then doing it again straight away to see whether the same thing happens.', 'Repetition is the experiment, not boredom. He is testing whether the world is reliable, and dropping a spoon forty times is how you find out.'),
    ],
  ),
  DevArea(
    id: 'selfcare',
    shortName: 'Independence',
    name: 'Self-care & Independence',
    icon: Icons.emoji_food_beverage_outlined,
    accent: _amber,
    word: DevWord.emerging,
    stage: 'First self-soothing',
    summary: 'Brings hands to his mouth and finds small ways to settle himself.',
    todayTip: 'Let him have safe moments to settle himself before you step in, a beat of patience helps.',
    brainNote: 'The first flickers of independence, small self-soothing that grows into big self-reliance.',
    seed: 8,
    journey: [
      DevStage('Hands to mouth', 'current', 'He finds his own hands and takes them to his mouth on purpose, rather than by accident.', 'It is his first act of self-comfort, and the first thing he does for himself without waiting for anyone. Small, but a real beginning.'),
      DevStage('Holds during feeds', 'next', 'A hand rests on the bottle, or pats and holds while feeding at the breast. Not taking over, just joining in.', 'Feeding stops being something done to him and starts being something he takes part in. That shift, not the grip, is the skill.'),
      DevStage('Finger foods', 'future', 'He picks up soft pieces himself and gets some of them in. Most of it ends up on the floor, the chair and him.', 'Self-feeding is fine motor, judgement and appetite all at once, and the mess is not a side effect of learning it. It IS the learning. Letting him do it badly is faster than doing it for him.'),
    ],
  ),
];

// ---- activities -------------------------------------------------------------
const List<DevActivity> kDevActivities = [
  DevActivity(
    id: 'peekaboo',
    title: 'Peekaboo, slow and silly',
    areaId: 'cognitive',
    minutes: 5,
    difficulty: 'Easy',
    ageTag: '3–6 mo',
    materials: ['Just your hands (or a light cloth)'],
    skills: ['Object permanence', 'Social connection', 'Cause & effect'],
    safety: ['Keep any cloth light and away from his face', 'Stop if he seems overwhelmed'],
    benefit: 'Plants the first seed of object permanence, the idea that things (and you) still exist when out of sight.',
    steps: ['Hide your face behind your hands.', 'Pause a beat, let the anticipation build.', 'Reveal with a warm “peekaboo”.', 'Watch his reaction, and follow his lead on the pace.'],
    seed: 11,
  ),
  DevActivity(
    id: 'narrate',
    title: 'Narrate & pause',
    areaId: 'language',
    minutes: 3,
    difficulty: 'Easy',
    ageTag: '3–12 mo',
    materials: ['Nothing at all'],
    skills: ['Language', 'Turn-taking', 'Attention'],
    safety: ['None, just your voice'],
    benefit: 'Builds his ear for language and the back-and-forth rhythm of conversation, long before words.',
    steps: ['Describe what you’re doing, “now we’re pouring the water”.', 'Pause, as if leaving room for his reply.', 'When he coos, answer as if it meant something.', 'Keep the loop going, it’s a real conversation.'],
    seed: 12,
  ),
  DevActivity(
    id: 'tummy_play',
    title: 'Tummy-time mirror play',
    areaId: 'gross_motor',
    minutes: 5,
    difficulty: 'Easy',
    ageTag: '2–6 mo',
    materials: ['A baby-safe mirror or a favourite toy'],
    skills: ['Neck & core strength', 'Visual tracking'],
    safety: ['Always supervise tummy time', 'Stop before happy turns to upset'],
    benefit: 'Builds the neck, shoulder and core strength he needs to roll, then sit.',
    steps: ['Lay him on his tummy on a firm, safe surface.', 'Place a mirror or toy just in front at his eye level.', 'Get down low and talk to him.', 'Short and frequent beats one long session.'],
    seed: 13,
  ),
  DevActivity(
    id: 'roll_help',
    title: 'Encourage the roll',
    areaId: 'gross_motor',
    minutes: 4,
    difficulty: 'Easy',
    ageTag: '3–6 mo',
    materials: ['A rattly toy'],
    skills: ['Rolling', 'Coordination'],
    safety: ['Soft, clear surface', 'Never force the movement'],
    benefit: 'Invites the first roll by tempting him to turn toward something interesting.',
    steps: ['Lay him on his back.', 'Hold a toy to one side, just past his shoulder.', 'Let him reach and twist toward it.', 'Cheer the effort, not just the roll.'],
    seed: 14,
  ),
  DevActivity(
    id: 'reach_ring',
    title: 'Reach for the ring',
    areaId: 'fine_motor',
    minutes: 4,
    difficulty: 'Easy',
    ageTag: '3–6 mo',
    materials: ['A light ring or graspable toy'],
    skills: ['Reaching', 'Grasp', 'Hand-eye coordination'],
    safety: ['Toy larger than his mouth', 'Nothing with small parts'],
    benefit: 'Sharpens hand-eye coordination as he aims, reaches and grasps with intent.',
    steps: ['Hold the ring at his midline, an arm’s reach away.', 'Let him track it and reach.', 'Bring it close enough to grab if he tires.', 'Celebrate the grasp.'],
    seed: 15,
  ),
  DevActivity(
    id: 'texture',
    title: 'A little texture basket',
    areaId: 'creativity',
    minutes: 6,
    difficulty: 'Easy',
    ageTag: '3–8 mo',
    materials: ['A few safe items, silk, a wooden spoon, a crinkly cloth'],
    skills: ['Sensory exploration', 'Fine motor', 'Curiosity'],
    safety: ['Everything larger than his mouth', 'Supervise closely'],
    benefit: 'Feeds his senses and builds the neural pathways that curiosity and creativity grow from.',
    steps: ['Gather 3 or 4 safe items with different textures.', 'Offer one at a time to touch and hold.', 'Name each feeling, “soft”, “crinkly”.', 'Follow his interest; there’s no wrong way.'],
    seed: 16,
  ),
  DevActivity(
    id: 'highcontrast',
    title: 'Black, white & red',
    areaId: 'cognitive',
    minutes: 4,
    difficulty: 'Easy',
    ageTag: '0–6 mo',
    materials: ['A high-contrast card or book'],
    skills: ['Visual attention', 'Focus'],
    safety: ['None'],
    benefit: 'Bold contrast is easiest for young eyes, holding his gaze builds visual attention.',
    steps: ['Hold a high-contrast image about 30 cm away.', 'Let his eyes settle and study it.', 'Slowly move it side to side so he tracks.', 'Stop when his attention drifts.'],
    seed: 17,
  ),
  DevActivity(
    id: 'song',
    title: 'Sing, pause, and play',
    areaId: 'language',
    minutes: 4,
    difficulty: 'Easy',
    ageTag: '0–12 mo',
    materials: ['A song you love'],
    skills: ['Language', 'Emotional connection', 'Anticipation'],
    safety: ['None'],
    benefit: 'Melody and repetition are gifts to a developing brain, and the pauses invite him to join in.',
    steps: ['Sing a simple, repetitive song.', 'Pause before the last word or a tickle.', 'Watch him anticipate what’s coming.', 'Repeat, babies adore the familiar.'],
    seed: 18,
  ),
];

// ---- brain development ------------------------------------------------------
const String kBrainThisWeek =
    'This month, {child}’s brain is becoming far better at connecting cause and effect, and at recognising the faces he loves. Every bit of eye contact, narrated play and “conversation” you share is physically strengthening these fast-growing connections.';

const List<BrainTopic> kBrainTopics = [
  BrainTopic('Recognising familiar faces', 'He now knows your face from a stranger’s, and lights up for it. This is memory and social wiring, together.', 'Lots of face-to-face time and warm eye contact strengthens it.'),
  BrainTopic('Cause and effect', 'He’s grasping that his own actions make things happen, the foundation of thinking and problem-solving.', 'Give him simple “I did that” moments, like a rattle that sounds when he moves it.'),
  BrainTopic('The music of language', 'His brain is mapping the rhythm and melody of speech long before he understands words.', 'Talk, sing and pause for his reply, narration is brain food.'),
  BrainTopic('Borrowing calm', 'The part that manages big feelings is years from ready, for now, he regulates by tuning into you.', 'Your steady voice and slow breathing literally settle his nervous system.'),
];

// ---- looking ahead ----------------------------------------------------------
const List<LookAhead> kLookAhead = [
  LookAhead(Icons.directions_run_rounded, 'A first roll, and then both ways', 'Over the coming weeks, many babies begin rolling tummy-to-back, then back-to-tummy. Plenty of floor time is the best invitation.'),
  LookAhead(Icons.pan_tool_alt_outlined, 'Reaching becomes grabbing', 'Swiping at toys turns into confident grabbing, and soon passing a toy from hand to hand.'),
  LookAhead(Icons.restaurant_outlined, 'The world of first foods', 'Around six months, many babies show they’re ready to explore solids, a whole new kind of learning.'),
  LookAhead(Icons.record_voice_over_outlined, 'Consonants join the babble', 'Over time, “aah-goo” grows into “ba-ba” and “da-da”, the building blocks of first words.'),
];

const List<(String, String)> kLookAheadPicks = [
  ('Toy', 'A soft, graspable rattle or textured ring'),
  ('Book', 'A high-contrast board book'),
  ('Read', 'The quiet case for tummy time'),
];

// ---- gentle check-ins -------------------------------------------------------
/// ⚠️ THE CHECK-IN ASKED EVERY PARENT THE SAME SIX QUESTIONS, AND THEY WERE
/// WRITTEN FOR A FOUR-MONTH-OLD.
///
/// "Does he push up on his forearms during tummy time?", "Does he smile back?",
/// "Does he bring his hands together at his chest?" — asked of the parent of a
/// two-year-old, unchanged. Nothing failed: six real questions rendered, the
/// answers saved, the reflection at the end read warmly. It was simply the
/// wrong conversation.
///
/// Feedback: "check if 'Let us see how your baby is doing' is actually age
/// dependent or not, if not, make it age dependent based on current age of the
/// child that we will anyways always know so no input needed from mother."
///
/// ⚠️ SIX QUESTIONS PER BAND, ONE PER DOMAIN, AND THE SHAPE IS DELIBERATE. The
/// reflection at the end counts yeses against domains, so a band with five
/// questions or two from one area would quietly skew it. Same six areas every
/// time; only the observation changes.
///
/// ⚠️ EVERY QUESTION IS SOMETHING SHE CAN SEE THIS WEEK, and none of them is a
/// threshold. "Does he" and "have you noticed", never "should he by now" — the
/// screen says out loud that there are no right answers, and the questions
/// have to be written so that stays true.
///
/// ⚠️ THE TEXT IS THE STORAGE KEY. `DevStore.checkInAnswer(q.text)` keys on the
/// question string, so answers are naturally per-question and a child who ages
/// into a new band starts that band fresh rather than inheriting ticks from a
/// question nobody asked. That is the right behaviour, and it is a side effect
/// of the key rather than a decision — worth knowing before anyone "tidies"
/// the key into an id.
/// A question whose wording changed: old text -> new text. The text is the
/// storage key, so `DevStore` moves an answer saved under the old wording to
/// the new one when it loads, and nobody loses a tick to a copy edit.
const Map<String, String> kCheckInRenames = {
  'Does he pass a toy from one hand to the other?': 'Can he hand a toy across to his other hand?',
};

const List<CheckInQ> kCheckIns0to6 = [
  CheckInQ('gross_motor', 'Does he push up on his forearms during tummy time?', askFrom: 3),
  // Milestones: "no social smile by around 3 months".
  CheckInQ('social', 'Does he smile back when you smile at him?', redFlag: true, askFrom: 2, flagFrom: 3),
  // No milestone item; CDC 2022: turns to your voice at 4 months, act early by 6.
  CheckInQ('language', 'Does he turn toward your voice or new sounds?', redFlag: true, askFrom: 4, flagFrom: 6),
  CheckInQ('fine_motor', 'Does he bring his hands together at his chest?', askFrom: 3),
  CheckInQ('cognitive', 'Does he follow a toy as you move it across his view?', askFrom: 2),
  CheckInQ('emotional', 'Does he settle more easily in your arms?', askFrom: 2),
];

const List<CheckInQ> kCheckIns6to12 = [
  // Milestones: "sitting ... not emerging by around 9 months".
  CheckInQ('gross_motor', 'Can he sit without you holding him?', redFlag: true, askFrom: 6, flagFrom: 9),
  CheckInQ('social', 'Does he look for you when you leave the room?', askFrom: 7),
  // Milestones: "no babbling or vocal play by around 9 months".
  CheckInQ('language', 'Does he babble strings of sounds, like ba-ba or da-da?', redFlag: true, askFrom: 6, flagFrom: 9),
  // Reworded 2026-10-22 (Wave 7): the old text matched What to Expect for
  // 8 words. Answers saved under it move over in kCheckInRenames.
  // CheckInQ('fine_motor', 'Does he pass a toy from one hand to the other?'),
  CheckInQ('fine_motor', 'Can he hand a toy across to his other hand?'),
  CheckInQ('cognitive', 'Does he look for a toy after you hide it under a cloth?', askFrom: 8),
  CheckInQ('emotional', 'Does he calm faster when you pick him up than when someone else does?'),
];

const List<CheckInQ> kCheckIns1to2 = [
  // No milestone item for pulling up (walking is 18); CDC 2022 15-month.
  CheckInQ('gross_motor', 'Is he pulling up, cruising along furniture, or walking?', redFlag: true, askFrom: 12, flagFrom: 15),
  // No milestone item; CDC 2022: shows you objects by 15 months, act early by 18.
  CheckInQ('social', 'Does he bring something over to show you?', redFlag: true, askFrom: 12, flagFrom: 18),
  // Milestones: "no words at all by about 16 months".
  CheckInQ('language', 'Does he use a few words, even unclear ones, that mean something?', redFlag: true, askFrom: 12, flagFrom: 16),
  CheckInQ('fine_motor', 'Does he pick up small pieces of food with finger and thumb?'),
  CheckInQ('cognitive', 'Does he follow a simple ask, like giving you the spoon?', askFrom: 15),
  CheckInQ('emotional', 'Does he look at your face to check before trying something new?'),
];

const List<CheckInQ> kCheckIns2to3 = [
  CheckInQ('gross_motor', 'Does he run, and climb onto low furniture?'),
  CheckInQ('social', 'Does he play alongside other children, even without joining in?'),
  // Milestones: "no two-word phrases by about two years".
  CheckInQ('language', 'Does he put two words together, like more milk?', redFlag: true, askFrom: 24, flagFrom: 24),
  CheckInQ('fine_motor', 'Does he scribble, and turn the pages of a book?'),
  CheckInQ('cognitive', 'Does he pretend, like feeding a doll or talking on a phone?'),
  CheckInQ('emotional', 'Does he show a strong opinion about what he wants?'),
];

const List<CheckInQ> kCheckIns3plus = [
  CheckInQ('gross_motor', 'Does he jump with both feet, or pedal a tricycle?'),
  CheckInQ('social', 'Does he take turns in a game, even with reminders?'),
  // Milestones: "strangers understand very little ... by about three".
  CheckInQ('language', 'Can someone outside the family understand most of what he says?', redFlag: true, askFrom: 36, flagFrom: 36),
  CheckInQ('fine_motor', 'Does he hold a crayon in his fingers rather than his fist?'),
  CheckInQ('cognitive', 'Does he ask why, and want a real answer?'),
  CheckInQ('emotional', 'Can he name a feeling, like happy, sad or angry?'),
];

/// The questions that fit a child of [months] (corrected age): the band's
/// six, less any not yet fair to ask ([CheckInQ.askFrom]). Empty for the
/// first weeks, when the screen says it is early for a check-in.
List<CheckInQ> checkInsForAge(int months) {
  // Every band ends with the lost-skill question (2026-10-07).
  final band = months < 6
      ? kCheckIns0to6
      : months < 12
          ? kCheckIns6to12
          : months < 24
              ? kCheckIns1to2
              : months < 36
                  ? kCheckIns2to3
                  : kCheckIns3plus;
  return [
    for (final q in [...band, kCheckInLostSkill])
      if (months >= q.askFrom) q,
  ];
}

/// ⚠️ KEPT AS AN ALIAS, NOT DELETED. `kCheckIns` was the whole API and other
/// code may still read it; pointing it at the youngest band preserves the old
/// behaviour exactly for anything not yet passing an age.
const List<CheckInQ> kCheckIns = kCheckIns0to6;

// ---- lookups ----------------------------------------------------------------
DevArea devAreaById(String id) => kDevAreas.firstWhere((a) => a.id == id, orElse: () => kDevAreas.first);
DevActivity devActivityById(String id) => kDevActivities.firstWhere((a) => a.id == id, orElse: () => kDevActivities.first);
List<DevActivity> activitiesForArea(String areaId) => kDevActivities.where((a) => a.areaId == areaId).toList();

/// ⚠️ THE ACTIVITY LIST WAS NEVER AGE-AWARE, AND NOTHING SAID SO.
///
/// The development home showed `kDevActivities.take(4)` — the first four in
/// authored order, for every child at every age. A parent of a three-week-old
/// and a parent of a four-year-old were handed the same four things to try.
/// Nothing failed: every activity is real, every card renders, and the list
/// even looks curated because it is stable.
///
/// Feedback: "check if 'Let us see how your baby is doing' is actually age
/// dependent or not, if not, make it age dependent based on current age of the
/// child that we will anyways always know so no input needed from mother, this
/// will come from system." That last clause is the design rule this app already
/// has — derive, never ask — and the age was sitting in `ChildProfileStore`
/// the whole time.
///
/// ⚠️ THE RANGE IS PARSED FROM `ageTag` RATHER THAN STORED SEPARATELY. The
/// tags are already authored ('3–6 mo', '0–12 mo') and are the string the card
/// displays, so a second numeric field would be a copy that can disagree with
/// the label a parent reads. Parsing is the cost of keeping one source.
({int lo, int hi})? devAgeRange(String ageTag) {
  final m = RegExp(r'(\d+)\s*[–—-]\s*(\d+)').firstMatch(ageTag);
  if (m == null) return null;
  var lo = int.parse(m.group(1)!);
  var hi = int.parse(m.group(2)!);

  // ⚠️ THE UNIT IS IN THE TAG AND IT IS NOT ALWAYS MONTHS. `kDevActivities`
  // is entirely "9–12 mo"; `kGrowExtraActivities` uses "4–5 yr" for anything
  // past two. Parsing the digits alone would read "4–5 yr" as four to five
  // MONTHS — so a four-year-old's parent would be offered preschool activities
  // labelled for her four-month-old, and a genuine four-month-old would get
  // them too.
  //
  // It would not have crashed, and it would not have looked wrong: the cards
  // are real, the ages are printed correctly on them, and only the FILTER
  // would be lying. Worth handling before the second store is wired in rather
  // than after.
  final tag = ageTag.toLowerCase();
  final inYears = tag.contains('yr') || tag.contains('year');
  if (inYears) {
    lo *= 12;
    hi *= 12;
    // "4–5 yr" means up to the fifth birthday, so the upper bound is the last
    // month before it rather than the month of it. Without this a 60-month-old
    // matches both "4–5 yr" and "5–6 yr".
    hi += 11;
  }
  return (lo: lo, hi: hi);
}

/// ⚠️ ONE POOL, EVERY AGE (Development DV3, 2026-10-25). The 102 activities
/// of the phase docs (`kPhaseDocActivities`) reached the home's Today and
/// the Brain tab but never this list, so a 2-to-3-year-old's Activities
/// screen held four. They join here, after the two older stores, and a
/// phase-doc activity with the same title and area as one already in the
/// pool is dropped: the older one has a time and a difficulty, and two cards
/// of one activity is a list padding itself. `test/pp_development_door_test`
/// holds at least 12 for every age band and no title twice.
final List<DevActivity> kDevActivityPool = () {
  String key(DevActivity a) =>
      '${a.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim()}|${a.areaId}';
  final seen = <String>{};
  return [
    for (final a in [...kDevActivities, ...kGrowExtraActivities, ...kPhaseDocActivities])
      if (seen.add(key(a))) a,
  ];
}();

/// Activities that fit a child of [months].
///
/// ⚠️ AN UNPARSEABLE TAG IS INCLUDED, NOT EXCLUDED. A typo in a range must
/// not make an activity vanish silently; showing it to the wrong age is a
/// smaller harm than a library that quietly shrinks.
List<DevActivity> activitiesForAge(int months) {
  // ⚠️ WRITTEN OUT RATHER THAN AS A COLLECTION-IF, AND THE FIRST VERSION WAS
  // A REAL BUG THAT A TEST CAUGHT.
  //
  // It read:
  //     if (devAgeRange(a.ageTag) case final r?)
  //       if (months >= r.lo && months <= r.hi) a
  //     else
  //       a,
  //
  // The `else` binds to the INNER `if`, not to the pattern match — the
  // dangling-else problem, alive and well in Dart's collection syntax. So any
  // activity whose range parsed but did NOT contain the age fell through to
  // `else a` and was included anyway. The filter compiled, analysed clean, and
  // returned every activity at every age: the exact bug it was written to fix,
  // reintroduced by the fix.
  //
  // Nothing on screen would have shown it, because the output of a broken
  // filter over a good library is still a screen full of good activities.
  // ⚠️ BOTH STORES, AND MISSING THE SECOND ONE WAS THE WHOLE OF "D5".
  //
  // This read `kDevActivities` alone — eight activities, every one tagged
  // inside 0–12 months — so `activitiesForAge(30)` returned nothing and the
  // conclusion was "the library stops at twelve months, somebody needs to
  // write toddler content".
  //
  // `kGrowExtraActivities` has been sitting beside it the whole time with 39
  // more, spanning 0–3 months to 4–5 years. The Development build prompt says
  // so in one line: "activities LIVE -> pp_activities + pp_grow_activities
  // (GrowStore: 39 extra grow activities)".
  //
  // So it was never a content gap. It was the same wiring gate this review
  // keeps finding: real content, correct, and not reachable from the place
  // that needed it. The tell was that the missing content was suspiciously
  // shaped — a library that stops dead at exactly twelve months is a filter
  // artefact, not an editorial decision.
  final out = <DevActivity>[];
  // Was `[...kDevActivities, ...kGrowExtraActivities]`, kept for revert.
  for (final a in kDevActivityPool) {
    final r = devAgeRange(a.ageTag);
    if (r == null) {
      out.add(a); // fail open: a bad tag must not hide real content
    } else if (months >= r.lo && months <= r.hi) {
      out.add(a);
    }
  }
  return out;
}


/// Today's one highlighted area (a real engine would rotate/personalise).
DevArea todaysFocus() => devAreaById('language');

// ---- domain → cross-content mapping -----------------------------------------
//  Maps a development area to the Watch category, Read collection and Product
//  category used by its three "Go deeper" rails and their "view more" screens.
String watchCategoryForArea(String areaId) => switch (areaId) {
      'cognitive' => 'Brain Development',
      'language' => 'Language',
      'gross_motor' => 'Activities',
      'fine_motor' => 'Activities',
      'emotional' => 'Behaviour',
      'social' => 'Behaviour',
      'creativity' => 'Play',
      'selfcare' => 'Health',
      _ => 'Brain Development',
    };

String readCollectionForArea(String areaId) => switch (areaId) {
      'cognitive' => 'brain',
      'language' => 'play',
      'gross_motor' => 'play',
      'fine_motor' => 'play',
      'emotional' => 'behaviour',
      'social' => 'behaviour',
      'creativity' => 'play',
      'selfcare' => 'feeding',
      _ => 'brain',
    };

String productCategoryForArea(String areaId) => switch (areaId) {
      'emotional' => 'Sleep',
      'selfcare' => 'Feeding',
      _ => 'Play & Development',
    };

/// The current + emerging skills of an area (its 'current' and 'next' stages) -
/// what the My Child "Milestones" section and the area screen surface.
List<DevStage> activeStages(DevArea area) =>
    area.journey.where((s) => s.status == 'current' || s.status == 'next').toList();

// =============================================================================
//  DevStore - saved & completed activities + gentle check-in answers.
// -----------------------------------------------------------------------------
//  ⚠️ PER CHILD SINCE 2026-10-25 (tools pass, Development, sync step 19).
//  Answers were keyed by the question's wording alone (`q|<text>`), so a
//  sibling in the same age band opened the check-in to find the other child's
//  answers already ticked, and a "we did this" was one set for the family. The
//  cloud row is one `user_state` row per person, so the owner has to live in
//  the ITEM KEY: `q|<childId>|<text>` holds {yes, at}, `c|<childId>|<id>` holds
//  the day it was tried (BACKEND-PATTERNS §16pp).
//
//  Items written before the split carry no child. They are never rewritten or
//  deleted; they are read only while the family has one child (or none), when
//  they can only be that child's. With two children nobody can say whose they
//  were, so neither inherits them: the check-in asks again.
// =============================================================================
class DevStore extends ChangeNotifier with CloudMergedStore {
  DevStore._();
  static final DevStore instance = DevStore._();

  // A fake starter state, shown to every new install as if she had saved and
  // done these. Kept for revert:
  // final Set<String> _saved = {'peekaboo'};
  // final Set<String> _completed = {'tummy_play'};
  final Set<String> _saved = {};
  // Unowned (pre-2026-10-25) items: done activity ids and answers by wording.
  final Set<String> _completed = {};
  final Map<String, bool> _checkIns = {}; // question text -> yes/no
  // Owned: childId -> activity id -> 'yyyy-mm-dd' tried.
  final Map<String, Map<String, String>> _triedBy = {};
  // Owned: childId -> question text -> the answer and the day it was given.
  final Map<String, Map<String, DevAnswer>> _answersBy = {};

  // ---- persistence (user_state KV; own-only, a personal preference) --------
  static const _prefsKey = 'pp_development';

  @override
  String get cloudKey => _prefsKey;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final data = jsonDecode(raw);
        applyLegacyBlob(data);
        // The owned items ride in the local cache beside the old blob shape.
        if (data is Map && data['items'] is Map) {
          _applyOwned((data['items'] as Map).cast<String, Object?>());
        }
      }
    } catch (_) {/* keep the starter state */}
    notifyListeners();
    try {
      // await syncStateFromCloud(); // kept for revert (step 13)
      await syncMergedFromCloud();
    } catch (_) {/* stay local */}
  }

  // Kept for revert (step 13): applyCloudItems({}) now gives the empty state.
  //   /// What a sign-out resets this store to (2026-10-17): the blob of a store nobody has used.
  //   @override
  //   Object get cloudEmptyData => const <String, Object?>{'saved': <String>[], 'completed': <String>[], 'checkIns': <String, bool>{}};
  //
  //   @override
  //   Object cloudData() => {
  //         'saved': _saved.toList(),
  //         'completed': _completed.toList(),
  //         'checkIns': _checkIns,
  //       };

  /// The local prefs blob (the shape the cloud blob had before step 13), plus
  /// the owned items under `items` (2026-10-25).
  Map<String, Object?> _blob() => {
        'saved': _saved.toList(),
        'completed': _completed.toList(),
        'checkIns': _checkIns,
        'items': _ownedItems(),
      };

  @override
  String? get legacyBlobKey => cloudKey;

  Map<String, Object?> _ownedItems() => {
        for (final c in _triedBy.entries)
          for (final e in c.value.entries) 'c|${c.key}|${e.key}': e.value,
        for (final c in _answersBy.entries)
          for (final e in c.value.entries) 'q|${c.key}|${e.key}': e.value.toJson(),
      };

  // One item per saved activity, per completed activity and per answer, so two
  // phones ticking different things both keep their tick (step 13).
  @override
  Map<String, Object?> cloudItems() => {
        for (final id in _saved) 's|$id': true,
        for (final id in _completed) 'c|$id': true,
        for (final e in _checkIns.entries) 'q|${e.key}': e.value,
        ..._ownedItems(),
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _saved.clear();
    _completed.clear();
    _checkIns.clear();
    _triedBy.clear();
    _answersBy.clear();
    for (final e in items.entries) {
      if (e.key.startsWith('s|')) {
        _saved.add(e.key.substring(2));
      } else if (e.key.startsWith('c|') && !e.key.substring(2).contains('|')) {
        _completed.add(e.key.substring(2));
      } else if (e.key.startsWith('q|') && !e.key.substring(2).contains('|')) {
        _takeAnswer(e.key.substring(2), e.value == true);
      }
    }
    _applyOwned(items);
  }

  /// The owned items: `c|<childId>|<id>` and `q|<childId>|<text>`. A key with a
  /// second bar has an owner; question wording and activity ids never hold one.
  void _applyOwned(Map<String, Object?> items) {
    for (final e in items.entries) {
      final k = e.key;
      if (!k.startsWith('c|') && !k.startsWith('q|')) continue;
      final rest = k.substring(2);
      final bar = rest.indexOf('|');
      if (bar <= 0) continue;
      final child = rest.substring(0, bar);
      final id = rest.substring(bar + 1);
      if (k.startsWith('c|')) {
        if (e.value is String) (_triedBy[child] ??= {})[id] = e.value as String;
      } else {
        final a = DevAnswer.fromJson(e.value);
        if (a == null) continue;
        final to = kCheckInRenames[id];
        final answers = _answersBy[child] ??= {};
        if (to == null) {
          answers[id] = a;
        } else {
          answers.putIfAbsent(to, () => a);
        }
      }
    }
  }

  /// Was applyCloudData before step 13; the same body. Also reads the local
  /// prefs cache, which keeps the old blob shape.
  @override
  void applyLegacyBlob(Object data) {
    if (data is! Map) return;
    final s = data['saved'];
    if (s is List) _saved..clear()..addAll(s.map((e) => e.toString()));
    final c = data['completed'];
    if (c is List) _completed..clear()..addAll(c.map((e) => e.toString()));
    final k = data['checkIns'];
    if (k is Map) {
      _checkIns.clear();
      k.forEach((key, v) => _takeAnswer(key.toString(), v == true));
    }
  }

  /// Carry an answer across a reworded question (kCheckInRenames): an answer
  /// under the old wording lands on the new one, and one already given to the
  /// new wording is never overwritten. After a merge the server still holds the
  /// old key, so the next change sends the new key and a removal of the old.
  void _takeAnswer(String text, bool yes) {
    final to = kCheckInRenames[text];
    if (to == null) {
      _checkIns[text] = yes;
    } else {
      _checkIns.putIfAbsent(to, () => yes);
    }
  }

  @override
  Future<void> persistLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // await prefs.setString(_prefsKey, jsonEncode(cloudData())); // kept for revert (step 13)
      await prefs.setString(_prefsKey, jsonEncode(_blob()));
    } catch (_) {}
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    persistLocalCache();
  }

  // ---- whose -----------------------------------------------------------------
  /// The child on screen, or null before a child is saved (then the unowned
  /// items are the only ones, exactly as before the split).
  static String? Function() activeChild = () => ChildProfileStore.instance.activeChildId;

  /// How many children the family has. The unowned items are read only while
  /// this is one or none: then they can only be that child's.
  static int Function() childCount = () => ChildProfileStore.instance.childIds.length;

  bool get _legacyReadable => childCount() <= 1;

  static String _day(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ---- saved (the reader's bookmark is the live save; these are older) ------
  bool isSaved(String id) => _saved.contains(id);
  void toggleSave(String id) {
    _saved.contains(id) ? _saved.remove(id) : _saved.add(id);
    notifyListeners();
  }

  // Unknown ids are dropped rather than mapped to the first activity, which
  // `devActivityById` falls back to.
  List<DevActivity> get savedActivities => [
        for (final id in _saved)
          if (kDevActivities.any((a) => a.id == id)) devActivityById(id),
      ];

  // ---- tried ("We tried this") ---------------------------------------------
  /// The day the child on screen tried [id], or null (also null for an
  /// unowned tick, which kept no day).
  DateTime? triedOn(String id) {
    final child = activeChild();
    final owned = child == null ? null : _triedBy[child]?[id];
    return owned == null ? null : DateTime.tryParse(owned);
  }

  bool isCompleted(String id) {
    if (triedOn(id) != null) return true;
    if (activeChild() != null && !_legacyReadable) return false;
    return _completed.contains(id);
  }

  /// Marks [id] tried today for the child on screen, or clears it.
  void toggleComplete(String id) => isCompleted(id) ? untry(id) : markTried(id);

  void markTried(String id, {DateTime? on}) {
    final child = activeChild();
    if (child == null) {
      _completed.add(id);
    } else {
      (_triedBy[child] ??= {})[id] = _day(on ?? DateTime.now());
    }
    notifyListeners();
  }

  void untry(String id) {
    final child = activeChild();
    if (child != null) _triedBy[child]?.remove(id);
    // An unowned tick goes too, while it is readable as this child's.
    if (child == null || _legacyReadable) _completed.remove(id);
    notifyListeners();
  }

  // ---- the gentle check-in ----------------------------------------------------
  /// The child on screen's answer to [text], with the day it was given.
  DevAnswer? answerFor(String text) {
    final child = activeChild();
    final owned = child == null ? null : _answersBy[child]?[text];
    if (owned != null) return owned;
    if (child != null && !_legacyReadable) return null;
    final legacy = _checkIns[text];
    return legacy == null ? null : DevAnswer(legacy, null);
  }

  bool? checkInAnswer(String text) => answerFor(text)?.yes;

  void setCheckIn(String text, bool yes, {DateTime? on}) {
    final child = activeChild();
    if (child == null) {
      _checkIns[text] = yes;
    } else {
      (_answersBy[child] ??= {})[text] = DevAnswer(yes, on ?? DateTime.now());
    }
    notifyListeners();
  }

  /// Start the check-in again for the child on screen: their answers go, and
  /// so do unowned answers while those read as this child's.
  void clearCheckIns(Iterable<String> texts) {
    final child = activeChild();
    for (final t in texts) {
      if (child != null) _answersBy[child]?.remove(t);
      if (child == null || _legacyReadable) _checkIns.remove(t);
    }
    notifyListeners();
  }

  int get checkInsAnswered {
    final child = activeChild();
    final owned = child == null ? const <String>{} : (_answersBy[child]?.keys.toSet() ?? const <String>{});
    final legacy = (child == null || _legacyReadable) ? _checkIns.keys.toSet() : const <String>{};
    return {...owned, ...legacy}.length;
  }
}

/// One check-in answer: yes or not yet, and the day it was given (null for an
/// answer saved before 2026-10-25, which kept no day).
class DevAnswer {
  const DevAnswer(this.yes, this.at);
  final bool yes;
  final DateTime? at;

  Map<String, Object?> toJson() => {
        'yes': yes,
        if (at != null) 'at': DevStore._day(at!),
      };

  static DevAnswer? fromJson(Object? v) {
    if (v is bool) return DevAnswer(v, null);
    if (v is! Map) return null;
    final yes = v['yes'];
    if (yes is! bool) return null;
    final at = v['at'];
    return DevAnswer(yes, at is String ? DateTime.tryParse(at) : null);
  }
}

// =============================================================================
//  "Ways to help it along" — actionable pointers
// -----------------------------------------------------------------------------
//  A one-line "notice it and follow his lead" is true but useless at 9pm when a
//  parent wants to know what to actually DO. These are the concrete moves, per
//  developmental area, written so each one is a thing you could do in the next
//  ten minutes without buying anything.
//
//  Kept per-AREA rather than per-stage on purpose: the honest advice for
//  encouraging any gross-motor skill is broadly the same, and inventing a
//  different list for ninety-odd stages would produce filler, not guidance.
// =============================================================================
List<String> helpBulletsFor(DevArea area, DevStage stage) {
  switch (area.id) {
    case 'gross_motor':
      return const [
        'Floor time beats any equipment. A firm blanket and space to push against does more than a seat or a bouncer.',
        'Put one favourite toy just past his reach: close enough to be worth it, far enough to need the stretch.',
        'Let him work at it before you rescue him. The wobble IS the exercise; steadying him too soon removes the very thing building the strength.',
        'Short and often beats long and once. A few minutes several times a day, always stopping while he is still happy.',
      ];
    case 'cognitive':
      return const [
        'Pause after you respond. He needs a beat of quiet to notice that HIS action caused YOUR reaction. That gap is where the learning happens.',
        'Repeat the same game far past your own boredom. Repetition is how a hunch becomes a rule for him.',
        'Narrate the cause out loud: "you shook it, and it rattled". Words attach to the pattern he is already sensing.',
        'Give him things that respond honestly: a rattle, a crinkly page, a lid. Toys that do everything by themselves teach him nothing about his own effect.',
      ];
    case 'language':
      return const [
        'Leave a gap after you speak, as though waiting for an answer. Turn-taking is learned long before words arrive.',
        'Answer his sounds as if they were sentences. Copying his coo back is a conversation to him.',
        'Narrate what you are doing while you do it: changing, cooking, walking. Ordinary commentary is the richest input there is.',
        'Face him when you talk. He is reading your mouth as much as hearing you.',
      ];
    case 'emotional':
      return const [
        'Respond to the small bids, not only the crying. A look held and returned is the whole skill in miniature.',
        'Let him set the pace with new people. Being passed around teaches him his signals do not count.',
        'Name what he seems to feel: "that was a surprise, wasn\'t it". Long before he understands the words he learns the feeling has a shape.',
        'Repair after the hard moments. Babies do not need parents who never get it wrong, only ones who come back.',
      ];
    default:
      return [
        'Follow his lead. Interest is the engine, and ${stage.name.toLowerCase()} arrives faster when he is enjoying it.',
        'Keep it short and stop while he is still content. Ending on a good moment makes the next one easier.',
        'Repeat it often. What looks like the same game to you is a fresh rehearsal to him.',
      ];
  }
}
