// =============================================================================
//  Mind & Mood - the two pieces the section was missing
// -----------------------------------------------------------------------------
//  1. Affirmations written for the MOTHER.
//  2. The partner-support article and its expert video slot.
//
//  ---------------------------------------------------------------------------
//  1. WHY THE AFFIRMATIONS ARE NEW RATHER THAN REUSED
//  ---------------------------------------------------------------------------
//  ⚠️ THIS IS A BOUNDARY FIX, NOT AN ADDITION, AND IT IS WORTH BEING PRECISE
//  ABOUT WHY.
//
//  The brief says "reuse the existing ParentVeda affirmations, do not create a
//  duplicate affirmation database". The Feel tab did reuse something: it drew
//  from `kSamvadT1` in `garbh_data.dart`. But Samvad is Garbh Sanskar, and
//  Samvad prompts are words spoken TO THE BABY:
//
//      "Little one, you are so wanted. I am becoming your mother, and my body
//       already knows just what to do."
//
//  That is baby bonding, which the same brief names as the one thing Mind &
//  Mood must not duplicate. So the affirmation card was quietly turning the
//  mother's own emotional-wellbeing section into a bonding exercise, at the
//  exact moment she opened it because she felt awful.
//
//  The distinction in one line: Samvad is what she says to her baby. These are
//  what she needs said to her. A mother lying awake at 3am with her chest tight
//  does not need to be handed a sentence about how wanted the baby is.
//
//  ⚠️ SO "REUSE, DO NOT DUPLICATE" IS STILL HONOURED. There was no existing
//  set of mother-directed affirmations anywhere in the app; the reuse that
//  happened was reuse of the wrong thing. Twelve lines is not a database, and
//  if a real affirmations service ever arrives this list is what it ingests.
//
//  ---------------------------------------------------------------------------
//  2. PARTNER SUPPORT
//  ---------------------------------------------------------------------------
//  Deliberately one article and one video slot. The brief is explicit that this
//  must not become a partner mental-health section, and the restraint is right:
//  the moment it grows a tab it starts competing with the mother's own section
//  for the same screen.
//
//  ⚠️ NO EM DASHES ANYWHERE IN THIS FILE. House rule for this section, and it
//  applies to seeded copy as much as to UI chrome.
// =============================================================================

import '../localization/app_language.dart';
import 'mind_mood_data.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// -----------------------------------------------------------------------------
//  Affirmations, for her
// -----------------------------------------------------------------------------

/// One steadying line.
///
/// ⚠️ NO ID, NO CATEGORY, NO FAVOURITING. An affirmation you can save is an
/// affirmation you can fail to revisit, and this section has a standing rule
/// against anything that turns feeling into a task. It is drawn, read, and
/// gone.
class MmAffirmation {
  const MmAffirmation(this.text);
  final LocalizedText text;
}

/// ⚠️ WRITTEN TO HER, NOT ABOUT HER, AND NOT ABOUT THE BABY.
///
/// Three rules these follow, because affirmations are the easiest copy in an
/// app to get subtly wrong:
///
///   · SECOND PERSON, PRESENT TENSE. "You are allowed to find this hard" lands;
///     "mothers often find this hard" is a fact about other people.
///   · NO INSTRUCTION. "Just relax" and "stay positive" are the two things
///     every anxious person has already been told by someone unhelpful.
///   · PERMISSION, NOT PERFORMANCE. Most of these give her permission to feel
///     what she already feels. An affirmation that sets a standard she is not
///     meeting makes a bad evening worse.
final List<MmAffirmation> kMmAffirmations = [
  MmAffirmation(_en('You are allowed to find this hard. It does not make you '
      'ungrateful.')),
  MmAffirmation(_en('This feeling is real, and it is also temporary. Both '
      'things are true.')),
  MmAffirmation(_en('You do not have to solve everything tonight.')),
  MmAffirmation(_en('You are doing more than anyone can see, including you.')),
  MmAffirmation(_en('Needing help is not the same as not coping.')),
  MmAffirmation(_en('You are allowed to rest before you have earned it.')),
  MmAffirmation(_en('A hard day is a hard day. It is not a verdict on the '
      'kind of mother you will be.')),
  MmAffirmation(_en('You can be frightened and still be doing this well.')),
  MmAffirmation(_en('Your body is working very hard right now, even on the '
      'days it does not feel like it.')),
  MmAffirmation(_en('You are still yourself. Pregnancy has not replaced you.')),
  MmAffirmation(_en('You are allowed to say no to advice you did not ask '
      'for.')),
  MmAffirmation(_en('Whatever you are feeling right now, you are not the only '
      'one who has felt it.')),
];

// -----------------------------------------------------------------------------
//  Partner support
// -----------------------------------------------------------------------------

/// The slot id a real film gets mapped to later.
const String kMmPartnerVideoSlot = 'expert_partner_support_01';

/// ⚠️ IT IS AN `MmArticle`, NOT A NEW TYPE, and that is the whole reason it is
/// three lines of wiring rather than a screen.
///
/// `MmArticleScreen` already renders body copy, an expert video slot and a
/// support CTA. A `PartnerArticle` class would have meant a second reader
/// screen that drifts from the first the moment either is touched, which is
/// the duplication the brief spends most of its length warning about.
///
/// ⚠️ AND IT IS DELIBERATELY NOT IN `kMmArticles`. Everything in that list is
/// written to the mother and appears in her Understand tab; this one is
/// written to her partner. Dropping it in would put "what to avoid saying to
/// her" inside her own reading list, which reads as the app briefing her on
/// how she ought to be handled. It is surfaced instead as one clearly-labelled
/// link at the foot of Understand, and inside Papa Mode.
final MmArticle kMmPartnerArticle = MmArticle(
  id: 'partner_support',
  // The group is only used for shelving inside the Understand tab, which this
  // article never appears in. `everydayCare` is the least wrong value; nothing
  // reads it for this entry.
  group: MmArticleGroup.everydayCare,
  title: _en('How to support her emotionally during pregnancy'),
  teaser: _en('For a partner who wants to help and is not sure how.'),
  readingTime: _en('4 MIN'),
  hasExpertVideo: true,
  body: _en(
    'Pregnancy changes how she feels, not just how she looks, and a lot of '
    'that change happens where you cannot see it. Hormones shift fast in the '
    'first few months and again near the end. Sleep gets worse. Her body '
    'starts doing things she did not agree to. On top of all that she is '
    'usually being asked, by everyone, how she is feeling, and expected to '
    'say fine.\n\n'
    'What she may be feeling\n\n'
    'Some days she will be happy and excited. Other days she may cry at '
    'nothing, snap at you, go quiet, or feel oddly flat about a pregnancy she '
    'very much wanted. None of that means something is wrong with her, and '
    'none of it means she is unhappy with you. It usually means she is tired '
    'and carrying a lot at once.\n\n'
    'She may also be frightened in ways she has not said out loud. Fear about '
    'labour is common. So is a quiet worry that something might go wrong with '
    'the baby. Many women do not say these things because saying them feels '
    'like tempting fate.\n\n'
    'What helps\n\n'
    'Listening without fixing. This is the big one. When she tells you she is '
    'worried, she is usually not asking you to solve it. Try "that sounds '
    'really hard" before "have you tried".\n\n'
    'Taking something off her plate without being asked. Not offering to '
    'help. Doing it. The offer is one more decision she has to make.\n\n'
    'Coming to appointments where you can. It tells her she is not doing this '
    'alone, and it means two people heard what the doctor said.\n\n'
    'Asking how she is and then waiting. The pause is the part that works.\n\n'
    'Being steady when she is not. She does not need you to match her mood. '
    'She needs one person in the room who is not spiralling.\n\n'
    'What to avoid saying\n\n'
    '"At least the baby is healthy." It is true and it is not a reply to how '
    'she feels.\n\n'
    '"Just relax." Nobody in the history of anxiety has relaxed on hearing '
    'this.\n\n'
    '"My mother did this with four children." Comparison is not comfort.\n\n'
    '"You are being emotional." Even when it is meant kindly, it tells her '
    'her feelings are the problem.\n\n'
    '"Should you be eating that?" She has heard it from six people already '
    'this week.\n\n'
    'When to gently push for more help\n\n'
    'Low mood on some days is normal. If she has seemed persistently low, '
    'anxious or not herself for more than two weeks, or if she says anything '
    'that worries you about her safety, that is worth acting on rather than '
    'waiting out. You do not have to diagnose anything. You can simply say '
    'you have noticed, that you are not going anywhere, and ask whether she '
    'would talk to someone. Offering to help book it, or to sit with her '
    'while she does, removes the hardest step.\n\n'
    'You matter here too\n\n'
    'Partners get frightened and tired as well, and are rarely asked about '
    'it. Having somewhere of your own to put that is not a distraction from '
    'supporting her. It is usually what makes it possible.',
  ),
);
