// =============================================================================
//  The father strand: one job a week for the first year (2026-10-07)
// -----------------------------------------------------------------------------
//  Gap analysis P1 (Behind · Partner): "His app follows the baby, and he gets a
//  job each week." The paired father lands on the parenting home with his own
//  top card: "<Name> is 6 weeks. This week, <job>." Week 0 is the birth week.
//  After a year the card keeps the last line's spirit with a monthly one.
//
//  Clinical lines stay general: never a dose, never a diagnosis; anything
//  medical is "ask your paediatrician".
// =============================================================================

const List<String> kPpFatherJobs = [
  // 0-7: the newborn weeks
  'learn the nappy change, and do every one you are home for',
  'take one night feed or settle, so she gets one long sleep',
  'keep visitors short, and say no for her when she is tired',
  'give the bath, and make it your job from now on',
  'notice her mood. If she seems low most days, gently suggest the doctor',
  'try skin to skin for half an hour; your chest calms the baby too',
  'go along to the six-week check, for the baby and for her',
  'take the baby for a walk so she gets an hour to herself',
  // 8-15
  'learn the soothing that works: rocking, shushing, a walk round the room',
  'talk to the baby during every change; your voice is being learned',
  'sort the next vaccine visit: the date, the card, the leave',
  'take the early morning shift at the weekend',
  'try tummy time on your chest, a few minutes at a time',
  'put a babyproof plan on paper before the baby starts rolling',
  'cook or bring one proper meal she does not have to think about',
  'read a short book aloud before bed, even if it feels silly',
  // 16-25
  'check the cot: firm mattress, nothing else in it, baby on the back',
  'take over one daily job for good, like laundry or bottles',
  'play the face game: get close, smile, wait for the smile back',
  'plan a small outing for the three of you',
  'ask her what would help most this week, and do that',
  'learn the first-aid steps for choking, so you are ready',
  'get down on the floor and play; your baby loves the attention',
  'start a photo or note for each month, so you both remember',
  'talk with her about starting solids, and read up together',
  'make the first taste of food your moment to share',
  // 26-35
  'cover sockets and secure heavy furniture before crawling starts',
  'do one meal a day with the baby, spoon and all',
  'take the baby out on your own for a morning',
  'sing the same song at bedtime every night',
  'name things as you walk around the house together',
  'check in on her sleep, and swap a night if she needs it',
  'play peekaboo; it teaches that people come back',
  'go to the nine-month vaccine visit if you can',
  'put the medicines and cleaners up high, out of reach',
  'roll a ball back and forth; small games build a lot',
  // 36-45
  'let the baby pull up on you, and cheer every try',
  'take a full day with the baby so she can rest or see friends',
  'read the same favourite book again; repetition is learning',
  'fit a stair gate, top and bottom',
  'share bath time as a family, with no phones',
  'talk about how the two of you are doing, not just the baby',
  'let the baby feed themselves, and accept the mess',
  'learn which foods are choking risks, and how to cut them',
  'stack blocks together and let the baby knock them down',
  'plan the first birthday with her, simply',
  // 46-51
  'take the baby to the park and let them watch the world',
  'start a small bedtime routine you always do',
  'check the car seat fits, and that it still faces backwards',
  'make time for just the two of you this week',
  'write down the year: what changed, what you loved',
  'thank her, out loud, for this year',
];

/// After the first year: one line a month, so the card never goes silent.
const List<String> kPpFatherMonthJobs = [
  'take one bedtime a week that is fully yours',
  'name feelings out loud: "You are cross, the tower fell"',
  'do the doctor visit this month, notes and all',
  'read every evening, ten minutes, the same chair',
  'give one calm "no" and stick to it together',
  'plan a weekly outing that is yours and your child\'s',
];

/// The job for a child [weeks] old (week 0 = birth week).
String ppFatherJobFor(int weeks) {
  if (weeks < 0) return kPpFatherJobs.first;
  if (weeks < kPpFatherJobs.length) return kPpFatherJobs[weeks];
  final month = weeks ~/ 4;
  return kPpFatherMonthJobs[month % kPpFatherMonthJobs.length];
}

/// "Meera is 6 weeks." The age half of the card.
String ppFatherAgeLine(String name, int weeks, int months) {
  if (weeks < 1) return '$name was born this week.';
  if (weeks < 13) return '$name is $weeks ${weeks == 1 ? 'week' : 'weeks'}.';
  return '$name is $months months.';
}
