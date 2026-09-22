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

const List<NormalQuestion> kNormalQuestions = [
  NormalQuestion(
    id: 'bleeding',
    question: 'I am bleeding. Is that normal?',
    verdict: NormalVerdict.now,
    short: 'Any bleeding in pregnancy is a call, even light spotting — most turn out fine, but the check is not optional.',
    why: 'Light spotting early on is common and often harmless (the placenta bedding in, a cervix that bleeds after sex or an internal exam). But bleeding is also the first sign of the things that need to be seen today — an early loss, a low-lying placenta, and later, the placenta coming away. Nobody can tell which from home.',
    doNow: [
      'Call your obstetrician or the labour ward now. Say how much (spots, a pad in an hour), what colour, and whether there is pain.',
      'Note the time it started. Keep the pad — they may ask to see it.',
      'Do not use a tampon; do not have sex until you have been seen.',
      'Heavy bleeding (soaking a pad in an hour), clots, or pain with it: go to the hospital, do not wait for a call back.',
    ],
    whenItChanges: 'Bleeding with severe pain, faintness, or after 20 weeks: go in now.',
  ),
  NormalQuestion(
    id: 'movement',
    question: 'The baby is moving less. Is that normal?',
    verdict: NormalVerdict.now,
    short: 'No. A change in your baby\'s pattern is a call now, at any hour — never wait until morning.',
    why: 'From about 24 weeks you know your baby\'s pattern. Fewer or weaker movements can be the only sign that a baby is not well, and checking is quick — a heartbeat trace at the hospital. Most checks are reassuring; the ones that are not are the reason the rule exists.',
    doNow: [
      'Do not use a home doppler, a drink, or a lie-down to "test" — call the labour ward now.',
      'Tell them when you last felt the baby move as usual.',
      'Go in when they ask you to, even if the baby moves on the way.',
      'If movements are reduced again another day, call again. Every time.',
    ],
    whenItChanges: 'Before 24 weeks, movements are not yet regular enough to count; from 28 weeks, treat any change as a call.',
  ),
  NormalQuestion(
    id: 'swelling',
    question: 'My face and hands have swollen suddenly. Is that normal?',
    verdict: NormalVerdict.today,
    short: 'Slow swelling of the feet by evening is normal. Sudden swelling of the face, hands or around the eyes is not — it needs a blood-pressure check today.',
    why: 'Fluid gathers in the feet and ankles as the pregnancy grows, especially in heat — that is ordinary. Swelling that comes on over hours in the face and hands, with a headache, vision changes or pain under the right ribs, can be pre-eclampsia, a blood-pressure condition that is only found by checking.',
    doNow: [
      'Call your obstetrician today and say "sudden swelling"; they will want your blood pressure and urine checked.',
      'Sit with your feet up while you wait; note any headache or spots in your vision.',
      'If you have a headache that will not lift, blurred vision, or pain under the ribs with it: call now, not today.',
    ],
    whenItChanges: 'Swelling that is only in the feet and goes down overnight is the ordinary kind — mention it at your next visit.',
  ),
  NormalQuestion(
    id: 'headache',
    question: 'I have a headache that will not lift. Is that normal?',
    verdict: NormalVerdict.today,
    short: 'Ordinary headaches are common, especially early on. One that does not ease with rest, water and paracetamol — or comes with vision changes — needs a check today.',
    why: 'Hormones, tiredness, low sugar and less caffeine cause most pregnancy headaches. After 20 weeks a severe or persistent headache can be a sign of raised blood pressure, which is why the same-day rule applies.',
    doNow: [
      'Water, food, a dark quiet room, paracetamol at the dose on the pack. Not ibuprofen.',
      'If it does not ease in a few hours, or it is the worst headache you have had, call your doctor today.',
      'Any vision change — flashing, spots, blurring — or swelling of the face with it: call now.',
    ],
    whenItChanges: 'A headache that eases with rest and returns only occasionally is the ordinary kind; mention the pattern at your next visit.',
  ),
  NormalQuestion(
    id: 'fever',
    question: 'I have a fever. Is that normal?',
    verdict: NormalVerdict.today,
    short: 'Feeling warm is normal; a measured temperature of 38°C or more is not — it needs a doctor today to find the cause.',
    why: 'Fever means an infection somewhere — a urine infection is the common one in pregnancy and is easy to treat, but it needs treating. A high fever also matters to the baby, so it is not something to sweat out.',
    doNow: [
      'Take your temperature. Paracetamol to bring it down; fluids.',
      'Call your doctor today; say the temperature, and whether you have burning on passing urine, a cough, a rash or a headache.',
      'A fever with a stiff neck, a rash that does not fade under a glass, or confusion: call now.',
    ],
    whenItChanges: 'A temperature under 38°C with a cold is ordinary — rest, fluids, and call if it climbs.',
  ),
  NormalQuestion(
    id: 'fluid',
    question: 'I am leaking fluid. Is that normal?',
    verdict: NormalVerdict.now,
    short: 'Discharge is normal and increases through pregnancy. Watery fluid that keeps coming, or a gush, may be the waters — a call now, at any week.',
    why: 'Before labour, the bag of waters can break early. It has to be checked quickly because once the waters go, infection can reach the baby, and before 37 weeks it changes the plan for the birth.',
    doNow: [
      'Put on a pad and note the colour: clear, pink, green or brown. Note the time.',
      'Call the labour ward now and say "I think my waters may have gone".',
      'Do not use a tampon, do not have a bath, do not have sex.',
      'Green or brown fluid, or a fever, or the baby moving less: go in now.',
    ],
    whenItChanges: 'Thin white or clear discharge with no smell that does not soak a pad is the normal kind. Itchy, lumpy, grey or smelly discharge is an infection to treat — call today.',
  ),
  NormalQuestion(
    id: 'urine',
    question: 'It burns when I pee. Is that normal?',
    verdict: NormalVerdict.today,
    short: 'Needing to pee often is normal. Burning, pain, cloudy or smelly urine is a urine infection until proven otherwise — and in pregnancy it is treated the same day.',
    why: 'Urine infections are more common in pregnancy and travel to the kidneys more easily, where they can bring on early labour. Antibiotics that are safe in pregnancy clear it quickly.',
    doNow: [
      'Call your doctor today and ask for a urine test; drink plenty of water meanwhile.',
      'Do not hold on; empty fully; wipe front to back.',
      'Fever, back pain over the kidneys, shivering or vomiting with it: call now.',
    ],
    whenItChanges: 'Going often, without any burning or pain, is the ordinary pregnancy kind.',
  ),
  NormalQuestion(
    id: 'itching',
    question: 'My palms and soles are itching. Is that normal?',
    verdict: NormalVerdict.today,
    short: 'Itching over a stretching belly is normal. Itching on the palms and soles, worse at night, with no rash, is a blood test today — it can be a liver condition of pregnancy.',
    why: 'Cholestasis of pregnancy is a build-up of bile acids that itches in exactly this pattern. It is checked with one blood test and managed with medicine and closer watching of the baby.',
    doNow: [
      'Call your doctor today and say "itching on my palms and soles, no rash".',
      'Cool compresses and loose cotton help meanwhile; nothing else changes what the test will show.',
      'Pale stools, dark urine or yellowing of the eyes with it: call now.',
    ],
    whenItChanges: 'Itching on the belly, breasts and thighs with dry or stretching skin is the ordinary kind — moisturise and mention it at your next visit.',
  ),
  NormalQuestion(
    id: 'contractions',
    question: 'I am getting tightenings before 37 weeks. Is that normal?',
    verdict: NormalVerdict.now,
    short: 'Irregular, painless tightenings (Braxton Hicks) are normal from the middle of pregnancy. Regular ones, painful ones, or ones with fluid or bleeding, before 37 weeks, are a call now.',
    why: 'Braxton Hicks come and go, do not get closer, and stop when you rest or drink. Early labour does the opposite — regular, closer, stronger. Before 37 weeks it can often be slowed if it is caught early, which is why the rule is to call, not to wait and see.',
    doNow: [
      'Drink a glass of water, lie on your left side, and time them for an hour.',
      'If they come regularly (say every ten minutes or closer), get stronger, or do not stop: call the labour ward now.',
      'Any fluid, bleeding, or a period-like ache in the back with them: go in now.',
    ],
    whenItChanges: 'From 37 weeks the same tightenings may be labour beginning — call when they are regular and five minutes apart, or sooner if you are far from the hospital.',
  ),
  NormalQuestion(
    id: 'fall',
    question: 'I had a fall. Do I need to be seen?',
    verdict: NormalVerdict.today,
    short: 'A stumble onto hands and knees is usually fine; the baby is well cushioned. A fall onto the belly, a blow, or a fall after 20 weeks, is a same-day check.',
    why: 'The placenta can be shaken loose by a direct blow even when you feel fine, and the signs can take hours. A heartbeat trace and a check of the belly are quick and put the question to rest.',
    doNow: [
      'Call your obstetrician or the labour ward today; say how you fell and where you landed.',
      'Watch for bleeding, fluid, tightenings, belly pain, or the baby moving less — any of these is a call now.',
      'After a car accident, even a small one, get seen the same day.',
    ],
    whenItChanges: 'A slip caught by your hands, no belly impact, before 20 weeks: rest, watch, and mention it at your next visit.',
  ),
];

NormalQuestion? normalQuestionById(String id) => kNormalQuestions.where((q) => q.id == id).firstOrNull;

/// The five urgent lines for the pinned flag, in the words of the questions
/// that carry a "now".
List<String> get kSymptomFlagLines => [
      for (final q in kNormalQuestions)
        if (q.verdict == NormalVerdict.now) q.question.replaceAll(RegExp(r'\. Is that normal\?$|\. Do I need to be seen\?$'), ''),
    ];
