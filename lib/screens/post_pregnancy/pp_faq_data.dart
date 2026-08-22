// =============================================================================
//  The tracker FAQs — real answers, written down
// -----------------------------------------------------------------------------
//  ⚠️ THESE QUESTIONS HAD NO ANSWERS, AND THE WAY THEY FAILED IS THE POINT.
//
//  The four trackers each show a "Learn while you track" block of four
//  questions. Tapping one opened `ppFaqSheet`, which asked
//  `parentingVedaAnswer(question)` — a fuzzy search across the parenting
//  corpus. When the search found nothing it returned "I don't have a confident
//  answer for that yet", and the sheet showed that.
//
//  So a parent tapped a question the app had printed for her, and the app said
//  it did not know. Nothing crashed, nothing logged, and the block looked
//  complete because the questions were real. Reported as: "currently the
//  answers are not there for question, add proper answers."
//
//  ⚠️ A SEARCH IS THE WRONG MECHANISM FOR A FIXED LIST. Sixteen questions are
//  authored in the app's own source; there is no reason to go looking for
//  them. Search is right when the query is unpredictable, and these are the
//  opposite of unpredictable. So this file answers them directly, and the
//  search stays as the fallback for anything not listed here.
//
//  ⚠️ AGE-BANDED, BECAUSE THE HONEST ANSWER CHANGES. "How do wake windows
//  change with age" has a different true answer at six weeks and at two years,
//  and a single averaged reply would be wrong for both. Feedback asked for
//  this explicitly — "again it should change based on child age" — and the age
//  comes from `ChildProfileStore`, so nothing is asked of the mother.
//
//  ⚠️ NO DIAGNOSIS ANYWHERE, and every answer that touches a red flag routes to
//  a doctor rather than resolving it. These are explanations, not assessments.
// =============================================================================

/// A question, and the answers that fit different ages.
///
/// ⚠️ `general` IS REQUIRED AND THE BANDS ARE OPTIONAL, deliberately. A missing
/// band falls back to a real answer rather than to silence, which is the
/// failure this file exists to fix. Adding a band later is additive.
class PpFaq {
  const PpFaq({
    required this.question,
    required this.general,
    this.under6m,
    this.m6to12,
    this.m12to36,
    this.over36m,
  });

  final String question;

  /// True at any age, and the fallback whenever a band is not written.
  final String general;

  final String? under6m;
  final String? m6to12;
  final String? m12to36;
  final String? over36m;

  /// The answer for a child of [months].
  String forAge(int months) {
    final banded = months < 6
        ? under6m
        : months < 12
            ? m6to12
            : months < 36
                ? m12to36
                : over36m;
    return banded ?? general;
  }
}

/// ⚠️ MATCHED ON THE EXACT QUESTION STRING, which makes the string a KEY as
/// well as copy — the identity-versus-display trap this repo has hit eight
/// times. `test/pp_faq_test.dart` asserts every question printed by a tracker
/// has an entry here, so editing the copy on one side and not the other fails
/// a build rather than a tap.
const List<PpFaq> kPpFaqs = [
  // ---------------------------------------------------------------- sleep ---
  PpFaq(
    question: 'Why do babies wake through the night?',
    general:
        'Because waking is normal, not a fault. Everybody surfaces briefly '
        'between sleep cycles; adults turn over and go back down without '
        'remembering it. A baby has shorter cycles and has not yet learned to '
        'rejoin the next one on his own, so he calls for you instead.',
    under6m:
        'At this age he also genuinely needs to feed at night. His stomach is '
        'small, milk digests fast, and night feeds are protecting his growth '
        'and your supply. Waking two or three times is not a problem to solve. '
        'The stretch usually lengthens on its own between three and six months, '
        'and it moves backwards for a while around four months, which is '
        'expected rather than a regression in the ordinary sense.',
    m6to12:
        'From about six months many babies can go longer without a feed, but '
        '"can" is not "will". Teeth, sitting up, crawling and separation '
        'anxiety all arrive in this window and every one of them shows up at '
        'night. If he was sleeping longer and has stopped, look for what is '
        'new in the day before changing anything at night.',
    m12to36:
        'After a year, night waking is more often about the day than about '
        'hunger: a nap that ran late, a big change, a new sibling, or simply '
        'wanting you. Bedtime that is the same shape every night does more '
        'here than anything you can do at 2am.',
  ),
  PpFaq(
    question: 'What is the 4-month sleep regression?',
    general:
        'Around four months his sleep permanently reorganises into adult-like '
        'cycles with lighter phases he briefly surfaces from. Sleep that had '
        'settled can fall apart in a week. It is a step forward in how his '
        'brain works, which is why it does not reverse — the settling that '
        'follows is new, not a return.',
    under6m:
        'This is the window. Expect more frequent waking, shorter naps and a '
        'baby who is harder to put down, usually for two to six weeks. Keep '
        'the day predictable, feed when he is hungry, and do not start '
        'anything new while it is happening.',
    m6to12:
        'If he is past six months and still waking often, this is no longer '
        'the four-month change — look at teeth, a leap in movement, or a nap '
        'schedule that has outgrown itself.',
  ),
  PpFaq(
    question: 'How do wake windows change with age?',
    general:
        'A wake window is how long he can comfortably stay awake between '
        'sleeps, and it stretches steadily through the first two years. '
        'Watching him matters more than watching the clock: yawning, staring '
        'past you and going quiet are the signal, and by the time he is crying '
        'the window has already closed.',
    under6m:
        'Newborns manage roughly 45 to 90 minutes, growing to about two hours '
        'by four months. At this age overtiredness is the usual reason a baby '
        'will not go down, and the fix is an earlier nap rather than a later '
        'one.',
    m6to12:
        'Two to three hours early in this stage, stretching towards three to '
        'four by the first birthday, as three naps become two.',
    m12to36:
        'Four to six hours, on one afternoon nap for most of this stage. The '
        'nap usually disappears somewhere between two and four, and the '
        'bedtime that replaces it needs to move earlier for a while.',
  ),
  PpFaq(
    question: 'What are safe sleep guidelines?',
    general:
        'On his back, on a firm flat surface, with nothing soft near his face: '
        'no pillow, no quilt, no bumper, no soft toy for the first year. Keep '
        'him in your room, and keep the room cool rather than warm.',
    under6m:
        'This matters most right now. If you bed-share — and most Indian '
        'families do — the safer version is a firm mattress, no gap between '
        'mattress and wall, no heavy razai over him, nobody who has been '
        'drinking or smoking, and him on his back beside you rather than '
        'between two adults. The Sleep section has a page on doing this more '
        'safely rather than pretending it does not happen.',
    m6to12:
        'Once he can roll both ways you do not have to turn him back over; '
        'still start him on his back. The cot can stay clear a while longer.',
  ),

  // -------------------------------------------------------------- feeding ---
  PpFaq(
    question: 'How do I know my baby is getting enough milk?',
    general:
        'By what comes out and how he grows, not by what you can see going in. '
        'Enough wet nappies, weight tracking along his own curve, and a baby '
        'who is alert and settles after most feeds are the reassuring signs.',
    under6m:
        'Six or more heavy wet nappies a day once your milk is in, yellow '
        'stools in the early weeks, and steady weight gain on his own line. '
        'A baby who feeds often is not necessarily a hungry baby — small '
        'stomachs empty fast. If he is sleepy at the breast, not waking to '
        'feed, or nappies are dry, that is worth a call today rather than '
        'tomorrow.',
    m6to12:
        'Milk is still the main food this whole year; solids are practice '
        'alongside it, not a replacement. Nappies and his growth curve remain '
        'the answer.',
  ),
  PpFaq(
    question: 'What is cluster feeding, and is it normal?',
    general:
        'Several feeds bunched close together, usually in the evening, with '
        'very little gap between them. It is normal, it is exhausting, and it '
        'is not a sign that your milk has run out.',
    under6m:
        'It peaks in the first weeks and around growth spurts. Feeding to '
        'order is how supply gets set, so the bunching is doing a job. Set '
        'yourself up before it starts: water, food, a charged phone, and '
        'somebody else holding everything that is not the baby.',
  ),
  PpFaq(
    question: 'How do I recognise early hunger cues?',
    general:
        'Stirring, turning his head with his mouth open, bringing hands to his '
        'mouth, sucking noises. Crying is a late cue, and a crying baby latches '
        'worse than a stirring one — which is why catching the early signs '
        'makes the feed easier for both of you.',
    m12to36:
        'At this age hunger looks like behaviour rather than cues: '
        'irritability before a meal, hovering near the kitchen, refusing '
        'everything and then eating properly ten minutes later.',
  ),
  PpFaq(
    question: 'When and how do I start solids?',
    general:
        'Around six months, when he can sit with support, holds his head '
        'steady, and reaches for food rather than pushing it out with his '
        'tongue. Start with one soft, plain thing at a time.',
    under6m:
        'Not yet. Before about six months his gut and his swallow are not '
        'ready, and early solids displace milk he still needs. Ignore advice '
        'about starting at four months to help him sleep — it does not.',
    m6to12:
        'Begin with soft mashed dal, khichdi, ragi, banana or well-cooked '
        'vegetables. One new food every two or three days makes a reaction '
        'easy to spot. Expect almost none of it to be eaten at first; this '
        'stage is about learning to eat, not about nutrition. No honey before '
        'one, no salt or sugar early, nothing hard and round.',
  ),

  // --------------------------------------------------------------- growth ---
  PpFaq(
    question: 'What does a growth percentile actually mean?',
    general:
        'It is his position among a hundred healthy children of the same age '
        'and sex, and nothing more. At the 25th, 24 of a hundred are smaller '
        'and 75 are bigger. It is a description, not a score — the 25th is not '
        'a worse result than the 75th, and there is no percentile to aim for.',
  ),
  PpFaq(
    question: 'Why consistency matters more than a single number',
    general:
        'Because one measurement is a dot and growth is a line. A child who '
        'has sat around the 20th since birth and stays there is growing '
        'exactly as he should. A child who was at the 60th and has drifted to '
        'the 15th over several visits is the one worth asking about, even '
        'though 15 is a perfectly ordinary number on its own.',
  ),
  PpFaq(
    question: 'What happens during a growth spurt?',
    general:
        'A short stretch of feeding more often, sleeping differently and being '
        'generally unlike himself, followed by a visible change. It usually '
        'lasts two to four days.',
    under6m:
        'Common around two to three weeks, six weeks and three months. More '
        'feeding is how he asks for more milk, and supply answers within a day '
        'or two. It is not a sign that you are running out.',
  ),
  PpFaq(
    question: 'How is my baby measured accurately?',
    general:
        'Weight with no clothes or nappy on the same scale each time; length '
        'lying flat until two, standing after that; head measured at the '
        'widest part, above the eyebrows and around the back. Small '
        'differences between clinics are usually the method, not the child — '
        'which is another reason the trend matters more than the reading.',
  ),

  // ---------------------------------------------------------- development ---
  PpFaq(
    question: 'Why do babies develop at such different rates?',
    general:
        'Because development is not a queue. Every skill has a wide normal '
        'range — walking anywhere from nine to eighteen months is all typical '
        '— and children spend their effort in different places at different '
        'times. A baby pouring everything into words often pauses on movement, '
        'and the reverse. Temperament, how much floor time he gets and whether '
        'he has older siblings all shift the order without shifting the '
        'outcome.',
    under6m:
        'At this age the range is at its widest, and prematurity shifts '
        'everything: use his corrected age, not his birthday, until two.',
  ),
  PpFaq(
    question: 'What does "serve and return" mean?',
    general:
        'It is the back-and-forth that builds his brain. He serves — a sound, '
        'a look, a hand raised — and you return it by responding to that exact '
        'thing. Naming what he is looking at, answering his babble as though '
        'it were a sentence, waiting for his turn. It is the single most '
        'useful thing anyone has found for early development, it needs no '
        'equipment, and it is mostly what you are already doing.',
    under6m:
        'His serve right now is eye contact, a wriggle, or a small sound. '
        'Returning it means catching his eye and answering. Face-to-face time '
        'while he is calm and alert is the whole activity.',
    m12to36:
        'Now the returns get longer: adding a word to what he said, asking '
        'something back, letting a silence sit long enough for him to fill it. '
        'Waiting is the hard part and the important part.',
  ),
  PpFaq(
    question: 'How can I support development through play?',
    general:
        'By following him rather than teaching him. Let him choose, join what '
        'he has already picked, narrate it, and resist improving it. Ordinary '
        'household things beat almost every toy, and ten unhurried minutes '
        'beats an hour with a phone in your hand.',
    under6m:
        'Tummy time in short frequent bursts, faces, high-contrast things to '
        'look at, and being talked to while you carry him about.',
    m6to12:
        'Containers to fill and empty, things to bang together, peekaboo, and '
        'floor time with something just out of reach.',
    m12to36:
        'Pretend play, simple pretend cooking, stacking, and books read the '
        'same way for the hundredth time. Repetition is the learning, not a '
        'sign he is bored.',
  ),
  PpFaq(
    question: 'When is a wait-and-see, and when to ask?',
    general:
        'Wait-and-see fits a child who is moving forward at his own pace, even '
        'a slow one. Ask sooner when he LOSES a skill he had, when he is not '
        'responding to sound or to his name, when there is no babble or '
        'pointing by around a year, no words by about eighteen months, or when '
        'something feels off to you and keeps feeling off. That last one is '
        'not a soft reason — a parent noticing is how most of these start.',
  ),
];

/// The answer for [question] at [months], or null when it is not one of ours.
///
/// ⚠️ RETURNS NULL RATHER THAN A PLACEHOLDER so the caller can fall back to
/// search. A default string here would silently become the answer for anything
/// mistyped, which is the shape of the bug this file replaced.
String? ppFaqAnswer(String question, int months) {
  for (final f in kPpFaqs) {
    if (f.question == question) return f.forAge(months);
  }
  return null;
}
