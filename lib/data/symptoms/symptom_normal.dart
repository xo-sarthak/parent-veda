// =============================================================================
//  "Is this normal?" — the ten questions, each with the answer that decides
//  where it goes
// -----------------------------------------------------------------------------
//  2026-09-22, the Symptoms door. A row on the door is a question in her
//  words. Its VERDICT is the design:
//
//    usually  →  "Usually, yes." A read: why, what helps, when it changes.
//    today    →  "Call your doctor today." A read whose opening callout is
//                the instruction, then the why — she reads it on the way.
//    now      →  "Call now." The row ends in the call, not in a read; the
//                read exists (for the partner reading it later) but the
//                door's row wears the phone.
//
//  ⚠️ NEVER A DIAGNOSIS, AND NEVER REASSURANCE WE CANNOT GIVE. A "usually"
//  still carries the line that turns it into a call. Every "now" says who to
//  call. Nothing here computes a risk for her; the verdicts are the same
//  ones every antenatal service prints on its "when to call" card.
//
//  Sources for the lines: NHS "Pregnancy — when to get help", NICE antenatal
//  care, FOGSI patient guidance. English only (CLAUDE.md).
// =============================================================================

enum NormalVerdict {
  usually,
  today,
  now;

  String get word => switch (this) {
        NormalVerdict.usually => 'Usually, yes',
        NormalVerdict.today => 'Call your doctor today',
        NormalVerdict.now => 'Call now',
      };
}

class NormalQuestion {
  const NormalQuestion({
    required this.id,
    required this.question,
    required this.verdict,
    required this.short,
    required this.why,
    required this.doNow,
    required this.whenItChanges,
  });

  final String id;

  /// In her words: "Is it normal to …".
  final String question;
  final NormalVerdict verdict;

  /// One sentence under the verdict.
  final String short;

  /// Why it happens, or why it matters.
  final String why;

  /// What to do, in order.
  final List<String> doNow;

  /// The line that turns a "usually" into a call, or tells a "now" what to
  /// say on the phone.
  final String whenItChanges;
}

// Rewritten 2026-09-29 to docs/PREG-VOICE.md; every verdict, number and
// instruction kept. The eleventh question (few symptoms) is from the gap
// analysis ("The Zero Symptoms Club", P2).
const List<NormalQuestion> kNormalQuestions = [
  NormalQuestion(
    id: 'bleeding',
    question: "I'm bleeding. Is that normal?",
    verdict: NormalVerdict.now,
    short: "Any bleeding in pregnancy, even light spotting, is a call now. Most turn out fine, but the check isn't optional.",
    why: "Light spotting early on is common and often harmless. It can be the pregnancy settling in, or a cervix that bleeds after sex or an internal exam. But bleeding is also the first sign of things that need to be seen today: an early loss, a low-lying placenta, and later, the placenta coming away. Nobody can tell which from home.",
    doNow: [
      'Call your obstetrician or the labour ward now. Say how much (spots, or a pad in an hour), what colour, and whether there is pain.',
      'Note the time it started. Keep the pad, as they may ask to see it.',
      "Don't use a tampon, and don't have sex until you've been seen.",
      "Heavy bleeding (soaking a pad in an hour), clots, or pain with it: go to the hospital. Don't wait for a call back.",
    ],
    whenItChanges: 'Bleeding with severe pain, feeling faint, or bleeding after 20 weeks: go in now.',
  ),
  NormalQuestion(
    id: 'movement',
    question: 'My baby is moving less. Is that normal?',
    verdict: NormalVerdict.now,
    short: "No. A change in your baby's pattern is a call now, at any hour. Never wait until morning.",
    why: "From about 24 weeks you get to know your baby's pattern. Fewer or weaker movements can be the only sign that a baby isn't well, and checking is quick: a heartbeat trace at the hospital. Most checks are reassuring. The ones that aren't are the reason the rule exists.",
    doNow: [
      "Don't use a home doppler, a drink or a lie-down to test it. Call the labour ward now.",
      'Tell them when you last felt your baby move as usual.',
      'Go in when they ask you to, even if your baby moves on the way.',
      'If movements are reduced again on another day, call again. Every time.',
    ],
    whenItChanges: "Before 24 weeks, movements aren't regular enough to count yet. From 28 weeks, treat any change as a call.",
  ),
  NormalQuestion(
    id: 'swelling',
    question: 'My face and hands have swollen suddenly. Is that normal?',
    verdict: NormalVerdict.today,
    short: "Feet that swell slowly by evening are normal. Sudden swelling of the face, hands or around the eyes isn't, and needs a blood pressure check today.",
    why: "Fluid gathers in your feet and ankles as pregnancy goes on, especially in the heat, and that's ordinary. Swelling that comes on over hours in the face and hands, with a headache, vision changes or pain under the right ribs, can be pre-eclampsia. It's a blood pressure condition that is only found by checking.",
    doNow: [
      'Call your obstetrician today and say "sudden swelling". They will want to check your blood pressure and urine.',
      'Sit with your feet up while you wait, and note any headache or spots in your vision.',
      "If you have a headache that won't lift, blurred vision, or pain under your ribs with it: call now, not today.",
    ],
    whenItChanges: 'Swelling only in your feet that goes down overnight is the ordinary kind. Mention it at your next visit.',
  ),
  NormalQuestion(
    id: 'headache',
    question: "I have a headache that won't lift. Is that normal?",
    verdict: NormalVerdict.today,
    short: "Ordinary headaches are common, especially early on. One that doesn't ease with rest, water and paracetamol, or comes with vision changes, needs a check today.",
    why: 'Hormones, tiredness, low sugar and less caffeine cause most pregnancy headaches. After 20 weeks, a severe or lasting headache can be a sign of raised blood pressure, which is why the same-day rule applies.',
    doNow: [
      'Water, food, a dark quiet room, and paracetamol at the dose on the pack. Not ibuprofen.',
      "If it doesn't ease in a few hours, or it's the worst headache you've had, call your doctor today.",
      'Any change in your vision (flashing, spots, blurring) or swelling of your face with it: call now.',
    ],
    whenItChanges: 'A headache that eases with rest and only comes back now and then is the ordinary kind. Mention the pattern at your next visit.',
  ),
  NormalQuestion(
    id: 'fever',
    question: 'I have a fever. Is that normal?',
    verdict: NormalVerdict.today,
    short: "Feeling warm is normal. A measured temperature of 38°C or more isn't, and needs a doctor today to find the cause.",
    why: "A fever means an infection somewhere. In pregnancy the common one is a urine infection, which is easy to treat but does need treating. A high fever also matters to your baby, so it isn't something to sweat out.",
    doNow: [
      'Take your temperature. Take paracetamol to bring it down, and drink fluids.',
      'Call your doctor today. Tell them the temperature, and whether you have burning when you pee, a cough, a rash or a headache.',
      "A fever with a stiff neck, a rash that doesn't fade when you press a glass on it, or confusion: call now.",
    ],
    whenItChanges: 'A temperature under 38°C with a cold is ordinary. Rest, drink fluids, and call if it climbs.',
  ),
  NormalQuestion(
    id: 'fluid',
    question: "I'm leaking fluid. Is that normal?",
    verdict: NormalVerdict.now,
    short: 'Discharge is normal and increases through pregnancy. Watery fluid that keeps coming, or a gush, may be your waters. That is a call now, at any week.',
    why: 'The bag of waters can break before labour. It has to be checked quickly, because once the waters go, infection can reach your baby, and before 37 weeks it changes the plan for the birth.',
    doNow: [
      'Put on a pad and note the colour (clear, pink, green or brown) and the time.',
      'Call the labour ward now and say "I think my waters may have gone".',
      "Don't use a tampon, have a bath, or have sex.",
      'Green or brown fluid, a fever, or your baby moving less: go in now.',
    ],
    whenItChanges: "Thin white or clear discharge with no smell, that doesn't soak a pad, is the normal kind. Itchy, lumpy, grey or smelly discharge is an infection to treat: call today.",
  ),
  NormalQuestion(
    id: 'urine',
    question: 'It burns when I pee. Is that normal?',
    verdict: NormalVerdict.today,
    short: "Needing to pee often is normal. Burning, pain, or cloudy or smelly urine is treated as a urine infection until a test says otherwise, and in pregnancy it's treated the same day.",
    why: 'Urine infections are more common in pregnancy and reach the kidneys more easily, where they can bring on early labour. Antibiotics that are safe in pregnancy clear it quickly.',
    doNow: [
      'Call your doctor today and ask for a urine test. Drink plenty of water meanwhile.',
      "Don't hold on, empty your bladder fully, and wipe from front to back.",
      'Fever, pain in your back over the kidneys, shivering or vomiting with it: call now.',
    ],
    whenItChanges: 'Going often, without any burning or pain, is the ordinary pregnancy kind.',
  ),
  NormalQuestion(
    id: 'itching',
    question: 'My palms and soles are itching. Is that normal?',
    verdict: NormalVerdict.today,
    short: 'Itching over a stretching belly is normal. Itching on the palms and soles, worse at night, with no rash, needs a blood test today. It can be a liver condition of pregnancy.',
    why: 'Cholestasis of pregnancy is a build-up of bile acids that itches in exactly this pattern. It is checked with one blood test, and managed with medicine and closer watching of your baby.',
    doNow: [
      'Call your doctor today and say "itching on my palms and soles, no rash".',
      "Cool compresses and loose cotton help while you wait. Nothing else changes what the test will show.",
      'Pale stools, dark urine or yellowing of your eyes with it: call now.',
    ],
    whenItChanges: 'Itching on your belly, breasts and thighs, with dry or stretching skin, is the ordinary kind. Moisturise, and mention it at your next visit.',
  ),
  NormalQuestion(
    id: 'contractions',
    question: "I'm getting tightenings before 37 weeks. Is that normal?",
    verdict: NormalVerdict.now,
    short: 'Irregular, painless tightenings (Braxton Hicks) are normal from the middle of pregnancy. Regular or painful ones, or ones with fluid or bleeding, before 37 weeks, are a call now.',
    why: "Braxton Hicks come and go, don't get closer, and stop when you rest or drink water. Early labour does the opposite: the tightenings get regular, closer and stronger. Before 37 weeks it can often be slowed if it's caught early, which is why the rule is to call, not to wait and see.",
    doNow: [
      'Drink a glass of water, lie on your left side, and time them for an hour.',
      "If they come regularly (say every ten minutes or closer), get stronger, or don't stop: call the labour ward now.",
      'Any fluid, bleeding, or a period-like ache in your back with them: go in now.',
    ],
    whenItChanges: "From 37 weeks the same tightenings may be labour beginning. Call when they're regular and five minutes apart, or sooner if you live far from the hospital.",
  ),
  NormalQuestion(
    id: 'fall',
    question: 'I had a fall. Do I need to be seen?',
    verdict: NormalVerdict.today,
    short: 'A stumble onto your hands and knees is usually fine, because your baby is well cushioned. A fall onto your belly, a blow to it, or any fall after 20 weeks needs a check the same day.',
    why: 'A direct blow can shake the placenta loose even when you feel fine, and the signs can take hours to show. A heartbeat trace and a check of your belly are quick, and settle the question.',
    doNow: [
      'Call your obstetrician or the labour ward today, and say how you fell and where you landed.',
      'Watch for bleeding, fluid, tightenings, belly pain, or your baby moving less. Any of these is a call now.',
      'After a car accident, even a small one, get seen the same day.',
    ],
    whenItChanges: 'A slip caught by your hands, with no knock to your belly, before 20 weeks: rest, keep an eye out, and mention it at your next visit.',
  ),
  NormalQuestion(
    id: 'fewSymptoms',
    question: 'I have hardly any symptoms. Is that normal?',
    verdict: NormalVerdict.usually,
    short: "Yes. Plenty of women feel well in pregnancy, and having few symptoms doesn't mean anything is wrong.",
    why: "How much you feel depends on how your body responds to the pregnancy hormones, not on how well your baby is growing. Some women have little sickness or tiredness at all, and symptoms often come and go from week to week.",
    doNow: [
      'Enjoy feeling well. Keep going to your check-ups and scans, which are what tell you how things are going.',
      "If you're worried, ask your doctor at your next visit. You won't be wasting their time.",
      "From the middle of pregnancy, get to know your baby's pattern of movements, and call if it changes.",
    ],
    whenItChanges: 'Bleeding or cramps are a call now, whatever else you feel. If symptoms you had faded suddenly and it worries you, it is always fine to call your doctor and ask.',
  ),
];

NormalQuestion? normalQuestionById(String id) => kNormalQuestions.where((q) => q.id == id).firstOrNull;

/// The five urgent lines for the pinned flag, in the words of the questions
/// that carry a "now".
List<String> get kSymptomFlagLines => [
      for (final q in kNormalQuestions)
        if (q.verdict == NormalVerdict.now) q.question.replaceAll(RegExp(r'\. Is that normal\?$|\. Do I need to be seen\?$'), ''),
    ];
