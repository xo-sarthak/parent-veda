// =============================================================================
//  ParentVeda Development Journey - milestone catalogue, store & voice
// -----------------------------------------------------------------------------
//  The Milestone Checklist rebuilt from the Claude Design prompt as a
//  "Development Journey": milestones are observations to celebrate, never a test.
//  A catalogue of milestones across six developmental domains (each with its own
//  identity), and one in-memory ChangeNotifier singleton (MilestoneStore) that,
//  using the child's age from ChildProfileStore, sorts them into a gentle journey
//  - foundations behind, skills emerging now, and what may come next - and lets a
//  parent mark one "observed" with a note. Language is warm throughout:
//  "developing / emerging", never "delayed / behind". Prototype-shaped: seeded,
//  no persistence/backend. Nothing here touches the pregnancy app.
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/child_scoped_store.dart';
import '../../services/remote/supabase_repo.dart';
import '../../services/remote/sync_registry.dart';

import 'pp_child_profile.dart';

/// The six developmental areas, each with its own colour + glyph so a parent
/// sees development as many parallel threads, not one ladder.
enum DevDomain { grossMotor, fineMotor, language, cognitive, social, selfCare }

class DomainMeta {
  const DomainMeta(this.label, this.short, this.icon, this.tint, this.ink);
  final String label;
  final String short;
  final IconData icon;
  final Color tint;
  final Color ink;
}

const Map<DevDomain, DomainMeta> kDomainMeta = {
  DevDomain.grossMotor: DomainMeta('Gross motor', 'Movement', Icons.directions_run_rounded, Color(0xFFEAF1FB), Color(0xFF2E5AAC)),
  DevDomain.fineMotor: DomainMeta('Fine motor', 'Hands', Icons.back_hand_outlined, Color(0xFFEAF4EE), Color(0xFF2E7D57)),
  DevDomain.language: DomainMeta('Language', 'Talking', Icons.chat_bubble_outline_rounded, Color(0xFFEDEAF7), Color(0xFF6A30B6)),
  DevDomain.cognitive: DomainMeta('Cognitive', 'Thinking', Icons.lightbulb_outline_rounded, Color(0xFFFBF4E7), Color(0xFF9A6B00)),
  DevDomain.social: DomainMeta('Social & emotional', 'Feelings', Icons.favorite_border_rounded, Color(0xFFFBEAF0), Color(0xFFB83A63)),
  DevDomain.selfCare: DomainMeta('Self-care', 'Everyday', Icons.spa_outlined, Color(0xFFEAF6F6), Color(0xFF2A7B7B)),
};

/// One milestone. [loMonths]/[hiMonths] are the *typical* range - always shown
/// as a range, never a due date.
class Milestone {
  const Milestone({
    required this.id,
    required this.domain,
    required this.title,
    required this.loMonths,
    required this.hiMonths,
    required this.desc,
    required this.why,
    required this.encourage,
    required this.variation,
    required this.discuss,
  });

  final String id;
  final DevDomain domain;
  final String title;
  final int loMonths;
  final int hiMonths;
  final String desc;
  final String why;
  final List<String> encourage;
  final String variation;
  final String discuss;

  String get ageRangeLabel => 'Typically $loMonths–$hiMonths months';
}

/// One recorded observation - a milestone becomes a memory, not a checkbox.
class MilestoneObs {
  MilestoneObs({required this.date, this.note});
  final DateTime date;
  final String? note;
}

// ---- catalogue --------------------------------------------------------------
const List<Milestone> kMilestones = [
  // gross motor
  Milestone(
    id: 'gm_headup', domain: DevDomain.grossMotor, title: 'Lifting the head during tummy time', loMonths: 1, hiMonths: 3,
    desc: 'During tummy time, your baby begins lifting their head and holding it up for longer stretches.',
    why: 'Neck and shoulder strength here lays the groundwork for rolling, sitting and everything that follows.',
    encourage: ['Short, frequent tummy time when they are calm and alert', 'Get down to their eye level and chat', 'A small rolled towel under the chest can help at first'],
    variation: 'Some babies love tummy time straight away; others protest at first and warm to it over weeks. Both are normal.',
    discuss: 'If, by around 4 months, there is very little head control even when settled, it is worth a gentle mention at your next visit.',
  ),
  Milestone(
    id: 'gm_roll', domain: DevDomain.grossMotor, title: 'Rolling over', loMonths: 4, hiMonths: 6,
    desc: 'Your baby may begin rolling from tummy to back, or back to tummy — often surprising you the first time.',
    why: 'Rolling is the first big whole-body move, building the coordination that leads to sitting and crawling.',
    encourage: ['Give floor time on a firm, safe surface', 'Offer a toy just out of reach to one side', 'Cheer the first rolls — they love your delight'],
    variation: 'Many babies roll one direction long before the other, or skip straight to sitting. Timing varies widely.',
    discuss: 'Rolling anywhere across 4–7 months is typical. Mention it only if there is no rolling and little effort to move by around 7 months.',
  ),
  Milestone(
    id: 'gm_sit', domain: DevDomain.grossMotor, title: 'Sitting with support, then alone', loMonths: 5, hiMonths: 8,
    desc: 'From propped sitting to a few wobbly seconds unaided, then steadier sitting that frees the hands to play.',
    why: 'Sitting opens up a new view of the world and lets both hands explore — a big leap for play and learning.',
    encourage: ['Prop with a cushion and stay close', 'Sit them facing you for supported practice', 'Toys in front encourage reaching from sitting'],
    variation: 'Independent sitting anywhere from 5 to 9 months is common. Wobbling and toppling is part of learning.',
    discuss: 'If sitting with support is not emerging by around 9 months, a quick chat with your paediatrician can be reassuring.',
  ),
  Milestone(
    id: 'gm_crawl', domain: DevDomain.grossMotor, title: 'Crawling or scooting', loMonths: 6, hiMonths: 10,
    desc: 'Getting mobile — classic hands-and-knees crawling, or a commando shuffle, bottom-scoot or roll to travel.',
    why: 'Any form of getting-around builds strength and spatial understanding. The method matters far less than the drive to move.',
    encourage: ['Lots of safe floor space', 'Place a favourite toy a little way off', 'Get down and crawl alongside them'],
    variation: 'Plenty of babies never crawl in the textbook way — scooting or going straight to pulling up is perfectly healthy.',
    discuss: 'Mention it if there is no way of moving toward a toy at all by around 10–12 months.',
  ),
  // fine motor
  Milestone(
    id: 'fm_grasp', domain: DevDomain.fineMotor, title: 'Reaching and grasping', loMonths: 3, hiMonths: 5,
    desc: 'Your baby starts batting at, then reaching for and holding objects, often bringing them to the mouth to explore.',
    why: 'Hand-eye coordination begins here — the foundation for feeding, play and later, writing.',
    encourage: ['Offer easy-to-hold rattles and soft rings', 'Let them mouth safe objects — it is how they learn', 'Play reaching games at their eye level'],
    variation: 'Some babies are grabby early; others take their time. Mouthing everything is normal and expected.',
    discuss: 'If hands mostly stay fisted and there is little reaching by around 5–6 months, it is worth a mention.',
  ),
  Milestone(
    id: 'fm_transfer', domain: DevDomain.fineMotor, title: 'Passing objects hand to hand', loMonths: 5, hiMonths: 8,
    desc: 'Your baby moves a toy from one hand to the other and turns objects over to inspect them.',
    why: 'Transferring shows growing coordination and curiosity — two hands working together with intent.',
    encourage: ['Offer toys to the middle so they choose a hand', 'Objects with interesting textures invite exploring', 'Name what they are holding'],
    variation: 'The smoothness of the hand-off improves gradually over months.',
    discuss: 'No cause for concern within this wide window — simply enjoy watching it develop.',
  ),
  Milestone(
    id: 'fm_pincer', domain: DevDomain.fineMotor, title: 'Pincer grasp (finger and thumb)', loMonths: 8, hiMonths: 12,
    desc: 'Picking up small pieces with the tip of the thumb and forefinger — a precise, deliberate grip.',
    why: 'The pincer grasp is a milestone of fine control, and it makes self-feeding possible.',
    encourage: ['Offer safe, soft finger foods to practise on', 'Model picking things up with your fingertips', 'Supervise closely — small pieces are a choking risk'],
    variation: 'It starts as a raking grab and refines into a neat pinch over several months.',
    discuss: 'Typically emerges across the second half of the first year; mention only if not appearing by around 12–14 months.',
  ),
  // language
  Milestone(
    id: 'lang_coo', domain: DevDomain.language, title: 'Cooing and first sounds', loMonths: 1, hiMonths: 4,
    desc: 'Gurgles, coos and vowel sounds — your baby\'s first experiments with their voice, often "in conversation" with you.',
    why: 'These early sounds are the seeds of speech, and the back-and-forth wires language long before words.',
    encourage: ['Reply to their sounds as if chatting', 'Narrate your day in a warm voice', 'Leave pauses for them to "answer"'],
    variation: 'Quiet, watchful babies and chatty ones both develop language well.',
    discuss: 'No concern in this window — the conversation is just beginning.',
  ),
  Milestone(
    id: 'lang_babble', domain: DevDomain.language, title: 'Babbling ("bababa", "dada")', loMonths: 4, hiMonths: 9,
    desc: 'Strings of repeated consonants appear — "bababa", "mamama", "dadada" — often with real melody and intent.',
    why: 'Babbling is speech in rehearsal: the mouth and ear practising the building blocks of words.',
    encourage: ['Babble back and take turns', 'Read aloud daily, even briefly', 'Put words to what they point at'],
    variation: 'The range of sounds and when they appear varies a lot between babies.',
    discuss: 'If there is no babbling or vocal play by around 9 months, it is worth raising at a visit.',
  ),
  Milestone(
    id: 'lang_understand', domain: DevDomain.language, title: 'Understanding simple words', loMonths: 6, hiMonths: 12,
    desc: 'Turning to their name, understanding "no", or looking for a familiar person or object when named.',
    why: 'Understanding comes before speaking — a sign the language centres are hard at work.',
    encourage: ['Use their name often and warmly', 'Name people and objects consistently', 'Play simple games like "where is…?"'],
    variation: 'Comprehension quietly outruns speech for a long time — they understand far more than they can say.',
    discuss: 'Mention it if they do not respond to their name or familiar words by around 12 months.',
  ),
  // cognitive
  Milestone(
    id: 'cog_track', domain: DevDomain.cognitive, title: 'Following faces and objects', loMonths: 1, hiMonths: 3,
    desc: 'Your baby\'s eyes track a face or a slowly moving toy, and they hold your gaze during a feed or cuddle.',
    why: 'Visual tracking and eye contact are early signs of attention and connection.',
    encourage: ['Hold your face about a foot away and move slowly', 'High-contrast pictures fascinate at this age', 'Follow their gaze and name what they see'],
    variation: 'Focus and tracking sharpen quickly over the first months.',
    discuss: 'If there is no eye contact or tracking by around 3 months, a check is worthwhile.',
  ),
  Milestone(
    id: 'cog_cause', domain: DevDomain.cognitive, title: 'Exploring cause and effect', loMonths: 4, hiMonths: 9,
    desc: 'Shaking a rattle to hear it, dropping a spoon to watch it fall, banging to make sound — testing how the world responds.',
    why: 'This is early scientific thinking: an action makes something happen, and that is worth repeating.',
    encourage: ['Offer toys that respond — rattles, crinkle books', 'Let them drop things (within reason!)', 'React with delight to their discoveries'],
    variation: 'Curiosity shows up in different ways — some babies are busy explorers, others careful watchers.',
    discuss: 'A wide, gentle window — simply follow their lead.',
  ),
  Milestone(
    id: 'cog_permanence', domain: DevDomain.cognitive, title: 'Object permanence (peekaboo)', loMonths: 6, hiMonths: 10,
    desc: 'Realising a hidden toy still exists — looking for it, and lighting up at peekaboo because they anticipate your return.',
    why: 'Understanding that things (and people) continue when out of sight is a big cognitive leap — and it underpins secure separation later.',
    encourage: ['Play peekaboo often', 'Partly hide a toy under a cloth and find it together', 'Narrate "gone… back!"'],
    variation: 'The delight in peekaboo appears at slightly different times for each baby.',
    discuss: 'No concern within this window; enjoy the game.',
  ),
  // social & emotional
  Milestone(
    id: 'soc_smile', domain: DevDomain.social, title: 'Social smiling', loMonths: 1, hiMonths: 3,
    desc: 'That first real smile in response to your face or voice — not wind, but connection.',
    why: 'Social smiling is the beginning of two-way relationship and communication.',
    encourage: ['Smile and talk warmly, face to face', 'Respond to their smiles every time you can', 'Gentle, playful voices invite them out'],
    variation: 'The first social smiles usually appear around 6–8 weeks, a little later in babies born early.',
    discuss: 'If there is no social smile by around 3 months, mention it at your next visit.',
  ),
  Milestone(
    id: 'soc_laugh', domain: DevDomain.social, title: 'Laughing and showing joy', loMonths: 3, hiMonths: 6,
    desc: 'Belly laughs, squeals and clear delight during play — your baby actively seeking fun with you.',
    why: 'Shared joy strengthens your bond and shows healthy emotional connection.',
    encourage: ['Play the silly games they love', 'Repeat whatever made them laugh', 'Follow their cues for more or a break'],
    variation: 'Some babies are giggly, others give a serious, watchful joy. Both are connection.',
    discuss: 'A gentle window — no need to worry within it.',
  ),
  Milestone(
    id: 'soc_separation', domain: DevDomain.social, title: 'Stranger awareness & clinginess', loMonths: 6, hiMonths: 12,
    desc: 'Suddenly wary of new faces and reluctant to leave you — the famous sudden clinginess.',
    why: 'Counter-intuitively, this is a *good* sign: it shows a strong, secure attachment to you.',
    encourage: ['Let them warm up to new people at their own pace', 'Keep goodbyes short, warm and consistent', 'Reassure rather than rush'],
    variation: 'Intensity varies hugely — some barely notice, others cling hard for a while. Both are normal.',
    discuss: 'This is expected development, not a problem — though your paediatrician is always happy to reassure.',
  ),
  // self-care
  Milestone(
    id: 'self_solids', domain: DevDomain.selfCare, title: 'Readiness for solids', loMonths: 5, hiMonths: 7,
    desc: 'Sitting with support, good head control, interest in your food and losing the tongue-thrust reflex.',
    why: 'These signs together — not age alone — show your baby is ready to begin exploring food.',
    encourage: ['Look for the signs together, not the calendar', 'Offer at a calm, unhurried mealtime', 'Expect mess — it is how they learn to eat'],
    variation: 'Readiness clusters around the middle of the first year but arrives at each baby\'s own pace.',
    discuss: 'Your paediatrician can help you judge readiness if you are unsure.',
  ),
  Milestone(
    id: 'self_finger', domain: DevDomain.selfCare, title: 'Self-feeding finger foods', loMonths: 8, hiMonths: 12,
    desc: 'Picking up soft pieces and bringing them to the mouth — messy, proud, independent eating.',
    why: 'Self-feeding builds fine motor skill, autonomy and a healthy relationship with food.',
    encourage: ['Offer safe, soft, graspable pieces', 'Let them lead and get messy', 'Always supervise for choking safety'],
    variation: 'Appetite and enthusiasm swing day to day — trust the week, not the meal.',
    discuss: 'A wide window; mention only if there is no interest in self-feeding by around 12–14 months.',
  ),
  // ===========================================================================
  //  After the first birthday, to five years (added 2026-10-07)
  // ---------------------------------------------------------------------------
  //  Parenting gap analysis, P1 (Development door): "Our tracker has 19
  //  milestones, all before one ... Extend the tracker to 5 years." The ages
  //  follow the CDC and AAP 2022 checkpoints (15, 18, 24 and 30 months, 3, 4 and
  //  5 years), where about three in four children can do the thing; each
  //  "discuss" line is the calm "act early" point. Neutral words for the child,
  //  because the same card reaches every family. REQUIRED_REVIEW (paediatrician).
  // ===========================================================================
  Milestone(
    id: 'gm_walk', domain: DevDomain.grossMotor, title: 'Walking on their own', loMonths: 11, hiMonths: 16,
    desc: 'The first steps alone, wide and wobbly, usually with arms up for balance. Falls are part of it.',
    why: 'Walking frees the hands to carry and explore, and changes how your toddler sees the whole house.',
    encourage: ['Bare feet on a safe floor help balance', 'Hold both hands, then one, then stand back a little', 'Push toys and a sturdy chair to cruise along'],
    variation: 'Walking anywhere from about 9 to 18 months is normal. Some children crawl for longer and then walk quickly.',
    discuss: 'Mention it if your toddler is not walking at all by 18 months, or always falls to one side.',
  ),
  Milestone(
    id: 'gm_run_climb', domain: DevDomain.grossMotor, title: 'Running and climbing', loMonths: 18, hiMonths: 26,
    desc: 'Walking turns into running, and the sofa becomes a mountain. Climbing up comes before climbing down.',
    why: 'Running and climbing build strength, balance and a sense of where the body is in space.',
    encourage: ['Daily time outdoors, in a park or a safe open space', 'Low steps to climb with you close by', 'Chasing games in a safe room'],
    variation: 'Some toddlers are climbers from the start; others are careful watchers. Both develop well.',
    discuss: 'Mention it if your toddler cannot run at all by about two and a half, or seems to lose balance much more than other children.',
  ),
  Milestone(
    id: 'gm_jump_pedal', domain: DevDomain.grossMotor, title: 'Jumping, and pedalling a tricycle', loMonths: 30, hiMonths: 42,
    desc: 'Jumping with both feet off the ground, then pedalling a tricycle and going up stairs one foot per step.',
    why: 'These need both sides of the body to work together, the same coordination used later in sport and writing.',
    encourage: ['Jump over a line drawn in chalk', 'A tricycle or a ride-on in a safe space', 'Stairs together, holding the rail'],
    variation: 'Pedalling can take a while to click, and many children push with their feet first. That is fine.',
    discuss: 'Mention it if your child cannot jump at all by about three and a half, or trips and falls very often.',
  ),
  Milestone(
    id: 'gm_hop_catch', domain: DevDomain.grossMotor, title: 'Hopping and catching', loMonths: 42, hiMonths: 60,
    desc: 'Hopping on one foot for a moment, catching a big ball, and later skipping.',
    why: 'Balance on one foot and timing a catch are skills for play with other children at school.',
    encourage: ['Hopscotch drawn on the floor', 'Throw and catch a soft, large ball', 'Dance games that stop and start'],
    variation: 'Catching is often still hit and miss at four. Hopping usually comes first.',
    discuss: 'Mention it if your child avoids running games entirely or seems much clumsier than other children of the same age.',
  ),
  Milestone(
    id: 'fm_scribble', domain: DevDomain.fineMotor, title: 'Scribbling and stacking', loMonths: 15, hiMonths: 24,
    desc: 'Holding a crayon in a fist and scribbling, and stacking two, then four or more blocks.',
    why: 'Controlling a crayon and a block is the start of drawing, feeding with a spoon and, much later, writing.',
    encourage: ['Thick crayons and big sheets of paper', 'Steel bowls and boxes to stack and knock down', 'Let your toddler feed with a spoon, mess and all'],
    variation: 'Some toddlers love drawing; others would rather build or pour. Any of these grow the same hand skills.',
    discuss: 'Mention it if your toddler cannot hold a crayon or pick up small objects with fingers by about two.',
  ),
  Milestone(
    id: 'fm_draw_circle', domain: DevDomain.fineMotor, title: 'Drawing a circle', loMonths: 30, hiMonths: 42,
    desc: 'Copying a circle after you show how, and holding the crayon in the fingers rather than a fist.',
    why: 'A controlled shape shows the small hand muscles and the eyes are working together.',
    encourage: ['Draw together and take turns', 'Play dough to roll and pinch', 'Threading big beads on a string'],
    variation: 'Grip changes slowly. A fist grip at three is still common.',
    discuss: 'Mention it if your child avoids using the hands for play or cannot copy any line by about four.',
  ),
  Milestone(
    id: 'fm_scissors_person', domain: DevDomain.fineMotor, title: 'Cutting, and drawing a person', loMonths: 42, hiMonths: 60,
    desc: 'Using child scissors to cut along a line, and drawing a person with a head and a few body parts.',
    why: 'These are the hand skills and planning that school work builds on.',
    encourage: ['Child scissors and old newspapers', 'Ask your child to draw the family and tell you about it', 'Buttons and zips on real clothes'],
    variation: 'Drawings vary a lot at this age. More detail comes with time and interest.',
    discuss: 'Mention it if your child cannot use any fine hand skill by about five, or gets very upset when asked to try.',
  ),
  Milestone(
    id: 'lang_words', domain: DevDomain.language, title: 'First words with meaning', loMonths: 12, hiMonths: 18,
    desc: 'A few words that mean something, even unclear ones: a sound for milk, a name for a pet, "no".',
    why: 'Words are the doorway to telling you what your toddler needs, and to fewer frustrated tears.',
    encourage: ['Name things as you hand them over', 'Wait a moment so there is room to answer', 'Talk in your home language; every language counts'],
    variation: 'Children growing up with two or three languages may start a little later and catch up. That is normal.',
    discuss: 'Mention it if there are no words at all by about 16 months, or words that were there have gone.',
  ),
  Milestone(
    id: 'lang_two_words', domain: DevDomain.language, title: 'Putting two words together', loMonths: 20, hiMonths: 30,
    desc: 'Two words joined into an idea: "more milk", "papa gone", "big car".',
    why: 'Joining words is the start of grammar, and of telling you what happened, not only what is wanted.',
    encourage: ['Add one word to what your toddler says', 'Read picture books and name what you see', 'Sing rhymes with actions'],
    variation: 'Some children save up words and then talk in short sentences quite suddenly.',
    discuss: 'Mention it if there are no two-word phrases by about two years, or few words at all. Early help works best.',
  ),
  Milestone(
    id: 'lang_sentences', domain: DevDomain.language, title: 'Talking in sentences', loMonths: 30, hiMonths: 42,
    desc: 'Short sentences, back-and-forth conversation, and lots of "why" and "what" questions.',
    why: 'Conversation is how your child learns to explain, ask and think out loud.',
    encourage: ['Ask open questions about the day', 'Let your child finish without rushing to help', 'Tell stories about when you were small'],
    variation: 'Clear speech takes years. Some sounds, like r or th, can be hard until five or later.',
    discuss: 'Mention it if strangers understand very little of what your child says by about three, or there is a stammer that upsets your child.',
  ),
  Milestone(
    id: 'lang_story', domain: DevDomain.language, title: 'Telling a short story', loMonths: 42, hiMonths: 60,
    desc: 'Telling you what happened, in order, with a beginning and an end, and answering questions about a story.',
    why: 'Storytelling is a big step towards reading and writing, and towards being understood at school.',
    encourage: ['Ask "what happened next?" at bedtime', 'Let your child retell a favourite story', 'Make up stories together with toys'],
    variation: 'Stories at four can be long and wander. Order and endings come with practice.',
    discuss: 'Mention it if your child cannot tell you about the day at all by about four and a half.',
  ),
  Milestone(
    id: 'cog_pretend', domain: DevDomain.cognitive, title: 'Pretend play', loMonths: 18, hiMonths: 30,
    desc: 'Feeding a doll, talking on a toy phone, stirring an empty pot. Things start to stand for other things.',
    why: 'Pretending is thinking: imagining, planning and understanding how the world works.',
    encourage: ['Join in and let your toddler lead', 'Steel utensils, a dupatta and old bags for play', 'Pretend together during daily jobs'],
    variation: 'Pretend play can start simply and grow richer over months. Any kind counts.',
    discuss: 'Mention it if there is no pretend play at all by about two and a half, or play is the same repeated action all day.',
  ),
  Milestone(
    id: 'cog_sort_count', domain: DevDomain.cognitive, title: 'Sorting, and counting a few things', loMonths: 30, hiMonths: 48,
    desc: 'Sorting by colour or shape, understanding "one" and "more", and counting a few objects.',
    why: 'Sorting and counting are the first steps in maths, and they grow from everyday life.',
    encourage: ['Sort laundry, spoons or vegetables together', 'Count stairs out loud', 'Ask "which one is bigger?"'],
    variation: 'Children can recite numbers long before they can count objects. Both are on the way.',
    discuss: 'Mention it if your child shows no interest in how things go together or work by about four.',
  ),
  Milestone(
    id: 'soc_play_with', domain: DevDomain.social, title: 'Playing with other children', loMonths: 24, hiMonths: 42,
    desc: 'Playing beside other children first, then with them: chasing, sharing a game, taking turns with help.',
    why: 'Playing together builds the friendship and turn-taking skills school relies on.',
    encourage: ['Short playdates with one child', 'Games that need turns, like rolling a ball', 'Name the feeling when sharing is hard'],
    variation: 'Sharing stays hard for a long time. Playing side by side at two is exactly right.',
    discuss: 'Mention it if your child shows no interest in other children or adults by about three, or avoids eye contact.',
  ),
  Milestone(
    id: 'soc_feelings', domain: DevDomain.social, title: 'Naming feelings', loMonths: 36, hiMonths: 54,
    desc: 'Saying "I am angry" or "she is sad", and starting to calm down with help.',
    why: 'A feeling with a name is easier to manage, for children and for adults.',
    encourage: ['Name your own feelings out loud', 'Read stories and ask how a character feels', 'Hug first, talk later'],
    variation: 'Big feelings with few words are normal at three. Words grow through four and five.',
    discuss: 'Mention it if anger, worry or sadness stop your child joining in with family or school for weeks.',
  ),
  Milestone(
    id: 'self_dress_toilet', domain: DevDomain.selfCare, title: 'Dressing and using the toilet', loMonths: 30, hiMonths: 60,
    desc: 'Taking off clothes, then putting them on, and using the toilet in the day with less and less help.',
    why: 'Doing things alone builds confidence, and it matters for playschool and school.',
    encourage: ['Clothes that are easy to pull on', 'Time to try before you help', 'A step stool and a small seat for the toilet'],
    variation: 'Daytime dryness anywhere from two to four is normal. Night dryness can come years later.',
    discuss: 'Mention it if there is no daytime control at all by about four, or a child who was dry starts wetting again.',
  ),
];

// ---- store ------------------------------------------------------------------
class MilestoneStore extends ChangeNotifier {
  // _seed() is deliberately NOT called. It writes somebody else's memories -
  // "First real smile at Papa - melted us" - and this store now syncs, so those
  // would appear in a real parent's keepsake record as if they were hers. Kept
  // for demos (BACKEND-PARENTING-BRIEF §5).
  MilestoneStore._();
  static final MilestoneStore instance = MilestoneStore._();

  final Map<String, MilestoneObs> _observed = {};

  bool _loaded = false;
  static const _prefsKey = 'pp_milestones';
  static const _table = 'pp_milestone_observations';

  String? get _childId => ChildProfileStore.instance.activeChildId;

  // ---- persistence (local-first, then cloud) -------------------------------
  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final j = Map<String, dynamic>.from(jsonDecode(raw));
        j.forEach((id, v) {
          final m = Map<String, dynamic>.from(v);
          _observed[id] = MilestoneObs(
            date: SupabaseRepo.parseDbTime(m['date']),
            note: m['note']?.toString(),
          );
        });
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
    try {
      await _syncFromCloud();
    } catch (_) {/* stay local */}
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    final childId = _childId;
    if (!SupabaseRepo.isLoggedIn || childId == null) return;
    try {
      final rows = await SupabaseRepo.fetchByChild(_table, childId);
      final cloudIds = <String>{};
      for (final r in rows) {
        final id = (r['milestone_id'] ?? '').toString();
        if (id.isEmpty) continue;
        cloudIds.add(id);
        _observed[id] = MilestoneObs(
          date: SupabaseRepo.parseDbTime(r['observed_on']),
          note: r['note']?.toString(),
        );
      }
      for (final entry in _observed.entries) {
        if (cloudIds.contains(entry.key)) continue;
        await _push(entry.key, entry.value);
      }
      await _persist();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  Future<void> _push(String id, MilestoneObs obs) => ChildSync.pushKeyed(
        _table,
        _childId,
        {
          'milestone_id': id,
          'observed_on': SupabaseRepo.dbTime(obs.date),
          'note': obs.note,
        },
        onConflict: 'child_id,milestone_id',
      );

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode(_observed.map((id, o) => MapEntry(
            id, {'date': SupabaseRepo.dbTime(o.date), 'note': o.note}))),
      );
    } catch (_) {}
  }

  // Corrected age for a baby born early (2026-10-07).
  int get _ageMonths => ChildProfileStore.instance.devAgeInMonths;
  String get name => ChildProfileStore.instance.name;

  bool isObserved(String id) => _observed.containsKey(id);
  MilestoneObs? observation(String id) => _observed[id];

  Milestone byId(String id) => kMilestones.firstWhere((m) => m.id == id);

  List<Milestone> inDomain(DevDomain d) => kMilestones.where((m) => m.domain == d).toList();

  /// Emerging = the typical range straddles the child's age now, and not yet
  /// observed. These are the "you may begin noticing..." skills.
  List<Milestone> get emerging => kMilestones
      .where((m) => !isObserved(m.id) && _ageMonths >= m.loMonths - 1 && _ageMonths <= m.hiMonths)
      .toList();

  /// Coming soon = opens after his age, is not already emerging, and is close
  /// enough to be worth knowing about.
  ///
  /// ⚠️ IT USED TO OVERLAP `emerging`, AND THE ARITHMETIC IS WORTH SEEING.
  /// `emerging` starts one month EARLY (`_ageMonths >= m.loMonths - 1`) so a
  /// skill appears just before its window opens. `comingSoon` took everything
  /// with `loMonths > _ageMonths`. For any milestone whose range opens next
  /// month both are true, so the same skill was printed twice on one screen,
  /// once under "you may notice this now" and once under "a soft look ahead".
  ///
  /// Reported as "currently it mentions same milestones which are emerging",
  /// and it is the kind of bug two correct-looking one-line getters produce
  /// without either of them being wrong on its own. Excluding by ID rather
  /// than by re-deriving the boundary means the two can never drift apart
  /// again: whatever `emerging` decides, this is the complement of it.
  ///
  /// ⚠️ AND A SIX-MONTH HORIZON, per the feedback. Without it this listed
  /// every remaining milestone up to five years — a four-month-old's parent
  /// scrolling toward "rides a tricycle". A look ahead is reassuring; the
  /// whole road is a workload.
  List<Milestone> get comingSoon {
    final alreadyEmerging = emerging.map((m) => m.id).toSet();
    return kMilestones
        .where((m) =>
            !isObserved(m.id) &&
            !alreadyEmerging.contains(m.id) &&
            m.loMonths > _ageMonths &&
            m.loMonths <= _ageMonths + 6)
        .toList()
      ..sort((a, b) => a.loMonths.compareTo(b.loMonths));
  }

  /// Foundations = typical range has passed (whether or not marked).
  List<Milestone> get foundations =>
      kMilestones.where((m) => m.hiMonths < _ageMonths && !isObserved(m.id)).toList();

  /// Observed, most recent first — the celebrated memories.
  List<Milestone> get achieved {
    final list = _observed.keys.map(byId).toList();
    list.sort((a, b) => _observed[b.id]!.date.compareTo(_observed[a.id]!.date));
    return list;
  }

  Milestone? get recentlyAchieved => achieved.isEmpty ? null : achieved.first;

  int get observedCount => _observed.length;

  /// A warm, human stage label from the age.
  String get stageLabel {
    final m = _ageMonths;
    if (m < 2) return 'The newborn weeks';
    if (m < 4) return 'Waking up to the world';
    if (m < 7) return 'Reaching, rolling & discovering';
    if (m < 10) return 'On the move & full of curiosity';
    if (m < 13) return 'Little explorer, big personality';
    return 'Busy toddler-in-the-making';
  }

  /// Today's gentle encouragement (rotates by day so it feels alive, no clock
  /// dependence beyond the date).
  String get encouragement {
    final lines = [
      '$name is exploring the world in exciting new ways.',
      'Every small step is real developmental work — and worth celebrating.',
      'Language is quietly blossoming, long before the first word.',
      '$name is developing beautifully, at exactly their own pace.',
      'Curiosity is the engine right now — follow where it leads.',
    ];
    final idx = DateTime.now().day % lines.length;
    return lines[idx];
  }

  // ---- writes -------------------------------------------------------------
  void markObserved(String id, {DateTime? date, String? note}) {
    final obs = MilestoneObs(date: date ?? DateTime.now(), note: note);
    _observed[id] = obs;
    notifyListeners();
    _persist();
    _push(id, obs);
  }

  void unobserve(String id) {
    _observed.remove(id);
    notifyListeners();
    _persist();
    ChildSync.removeKeyed(_table, _childId, 'milestone_id', id);
  }

  /// Demo observations. Deliberately NOT called - see the constructor note.
  // ignore: unused_element
  void _seed() {
    // A couple already lovingly noticed, so the journey looks lived-in.
    _observed['soc_smile'] = MilestoneObs(date: DateTime.now().subtract(const Duration(days: 62)), note: 'First real smile at Papa — melted us');
    _observed['lang_coo'] = MilestoneObs(date: DateTime.now().subtract(const Duration(days: 40)));
    _observed['fm_grasp'] = MilestoneObs(date: DateTime.now().subtract(const Duration(days: 9)), note: 'Grabbed the wooden ring and would not let go');
  }
}
