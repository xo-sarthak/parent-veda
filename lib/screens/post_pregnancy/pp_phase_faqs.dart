// =============================================================================
//  Phase FAQs — the questions parents actually ask at each age
// -----------------------------------------------------------------------------
//  Replaces pp_leap_faqs.dart. That file's questions were keyed to the ten
//  Wonder Weeks leaps and written in its vocabulary — "the world of sensations",
//  "the world of relationships", "programs are whole sequences of actions". None
//  of that survives the move to age phases, because none of it was ours: it was
//  a rejected framework's language describing a structure we no longer use.
//
//  Shown three at a time on the My Child home, ROTATING each app launch so a
//  parent who opens the app daily meets the whole pool over a week rather than
//  the same three forever. Anything not covered goes to Ask Veda.
//
//  Written to answer the 3am question honestly — "is this normal", "am I making
//  it worse", "when does it end" — not to reassure blandly. Each answer earns
//  its place by telling her something she did not already know.
// =============================================================================

class PhaseFaq {
  const PhaseFaq(this.question, this.answer);
  final String question;
  final String answer;
}

/// Rotates once per app LAUNCH, not per rebuild — otherwise the questions would
/// shuffle under her thumb every time the page repainted.
int _rotation = 0;
bool _rotated = false;

void _rotateOnce() {
  if (_rotated) return;
  _rotated = true;
  _rotation++;
}

/// Asked at every age. Pooled with the phase-specific ones so a phase with few
/// of its own still has enough to rotate through.
const List<PhaseFaq> _universal = [
  PhaseFaq(
    'Is this fussiness my fault?',
    'No. Hard stretches come from a brain that is reorganising itself, not from anything you did or didn\'t do. The clinginess is your child seeking the safest place while everything else feels unfamiliar. That\'s a compliment, even when it doesn\'t feel like one at 3am.',
  ),
  PhaseFaq(
    'How long do these difficult stretches last?',
    'Usually days rather than weeks, and they don\'t run to a schedule. No two children follow the same pattern, which is exactly why we don\'t print one. Fussiness that drags on, or arrives with fever, poor feeding or unusual listlessness, is worth a call to your paediatrician. That isn\'t development.',
  ),
  PhaseFaq(
    'Should I keep to the routine or let it slide?',
    'Keep the shape, loosen the timings. A familiar order helps your child feel safe, but a hard week is a poor time to enforce a schedule. You aren\'t undoing months of work by giving more cuddles.',
  ),
  PhaseFaq(
    'The night waking is back. Have we gone backwards?',
    'Almost certainly not. Sleep commonly fragments while a new skill is arriving and settles again after. It reads as regression because the change is sudden, but the underlying skill is moving forward.',
  ),
  PhaseFaq(
    'Everyone compares. Is my child on track?',
    'The milestones we show are the ones about three in four children reach by that age. They\'re not an average, and not a deadline. A child can sit outside a range and be perfectly well. What matters is steady progress and your own instinct. If that instinct says something is off, tell your paediatrician rather than the internet.',
  ),
  PhaseFaq(
    'Can I speed any of this up?',
    'Not really, and trying tends to make it harder. What helps is meeting the new skill where it is, and protecting your own rest so you can be steady through it.',
  ),
];

/// Phase-specific questions, keyed by phase number (1–20).
const Map<int, List<PhaseFaq>> _byPhase = {
  1: [
    PhaseFaq(
      'My baby startles at everything. Is that normal?',
      'Yes. Your baby has come from somewhere warm, dark and constant into a world that is none of those things, and everything arrives unfiltered. Startling is a new nervous system learning where the edges are. Swaddling and dimmer, quieter rooms really help.',
    ),
    PhaseFaq(
      'Am I feeding too often?',
      'Almost certainly not. Eight to twelve feeds in twenty-four hours is normal in the early weeks, and a newborn stomach empties fast. Feeding on demand isn\'t a habit you\'re creating. It\'s how supply establishes.',
    ),
  ],
  2: [
    PhaseFaq(
      'The crying is worse than it was. What is happening?',
      'Crying rises from birth and peaks somewhere around six weeks, then falls away through three to four months. This is one of the few infant findings almost nobody disputes. It happens across cultures and feeding methods. If this is your hardest month, you\'re also close to the turn.',
    ),
  ],
  3: [
    PhaseFaq(
      'My baby hates tummy time. Do I have to?',
      'Short and often beats long and once. A few minutes several times a day builds the neck strength that rolling and sitting depend on. Always stop while your baby is still content. On your chest counts.',
    ),
  ],
  5: [
    PhaseFaq(
      'Sleep was better a month ago. What went wrong?',
      'Nothing. Around four months, sleep reorganises from the simple newborn pattern into cycles with lighter and deeper phases. That is the structure it keeps for life. At the end of each cycle your baby surfaces near waking and, if resettling doesn\'t happen, calls for you. It\'s developmental, not a habit you created.',
    ),
    PhaseFaq(
      'Should my baby be rolling by now?',
      'The window is wide. Many babies roll between four and six months, and some skip it and go straight to sitting. Floor time while your baby is content does more than practice drills. Do mention it if there\'s no pushing up on the forearms at all.',
    ),
  ],
  7: [
    PhaseFaq(
      'How do I know my baby is ready for food?',
      'Look for four signs: sitting with support, holding the head steady, showing real interest in what you\'re eating, and having lost the reflex that pushes food back out. Age alone isn\'t the signal. Those four are.',
    ),
    PhaseFaq(
      'My baby eats almost nothing. Should I worry?',
      'Not at this age. Food before one is about learning to eat, not about calories. Milk is still supplying nearly all of them. A teaspoon taken with interest beats a bowl pushed in.',
    ),
  ],
  9: [
    PhaseFaq(
      'My baby screams when I leave the room. Is this a phase?',
      'It is, and it\'s an achievement in disguise. Your baby has worked out that you still exist when you\'re out of sight, which is why your leaving now brings protest. Short, cheerful goodbyes teach that you come back. Sneaking out teaches a baby to watch you constantly.',
    ),
  ],
  10: [
    PhaseFaq(
      'The doctor mentioned a screening. Should I be worried?',
      'No. At nine months a developmental screening is recommended for every child, not because anything is suspected. It\'s a short questionnaire, usually filled in by you, designed to catch things early enough that support is easy. Being screened says nothing about your child.',
    ),
  ],
  11: [
    PhaseFaq(
      'My baby picks up everything off the floor now.',
      'The pincer grasp has arrived: thumb and forefinger together. It\'s the same skill that makes self-feeding possible. It also means this is the week to get down to your baby\'s eye level and look at your floor properly. Anything small enough to pick up is small enough to choke on.',
    ),
  ],
  13: [
    PhaseFaq(
      'My child is one and not walking. Is that a problem?',
      'Walking anywhere from about nine to seventeen months is normal, and children who walk later aren\'t slower children. It\'s worth mentioning if there\'s no pulling to stand at all, or no bearing weight on the legs.',
    ),
    PhaseFaq(
      'How much milk now?',
      'Cow milk is fine from one year, capped around 500 ml a day. Beyond that it crowds out iron-rich food, and too much milk is the most common cause of toddler iron deficiency in India.',
    ),
  ],
  14: [
    PhaseFaq(
      'My toddler only has a few words. Should I push?',
      'Pushing rarely helps; talking does. Narrate what you\'re doing, leave gaps as though waiting for an answer, and respond to gestures as if they were sentences. At this age gestures matter as much as words. A child who communicates well without words is communicating well.',
    ),
  ],
  15: [
    PhaseFaq(
      'Why is my toddler being screened for autism if nothing is wrong?',
      'Because it\'s recommended for every child at eighteen months, and again at twenty-four. Universal screening exists so it isn\'t kept for children someone is already worried about. That\'s what makes it useful, and why it says nothing about yours.',
    ),
  ],
  16: [
    PhaseFaq(
      'The tantrums are constant. What am I doing wrong?',
      'Nothing. Two-year-olds know exactly what they want and can picture it clearly. What\'s missing is the language to bargain for it and the brain machinery to manage the frustration. That gap is the tantrum. It closes with language, not with discipline.',
    ),
    PhaseFaq(
      'My toddler won\'t share. Is that normal?',
      'Completely. Playing near other children rather than with them is exactly right at two. Sharing is a skill that arrives a good deal later, and its absence now isn\'t a character flaw.',
    ),
  ],
  17: [
    PhaseFaq(
      'When should we start potty training?',
      'When your child shows the signs, not at a set age or because another child did. Staying dry for a couple of hours, telling you afterwards, and being able to pull clothes down are the ones that matter. Starting before those appear usually takes longer, not less.',
    ),
  ],
  19: [
    PhaseFaq(
      'The endless why questions are exhausting.',
      'Your child has just worked out that things have causes, and that you might know them. Short honest answers do more than perfect ones. "I don\'t know, shall we find out?" is a really good answer.',
    ),
    PhaseFaq(
      'Strangers can\'t understand my child. Is that a problem?',
      'By four, most of what children say is usually clear to someone outside the family. If that routinely isn\'t the case, it\'s worth raising with your paediatrician. It\'s not a reason to panic, but it is worth raising.',
    ),
  ],
  20: [
    PhaseFaq(
      'Is my child ready for school?',
      'Readiness is far more about sitting for a short activity, following a two-step instruction, managing the toilet and separating from you calmly than about letters and numbers. The academics catch up fast. The rest takes longer to build.',
    ),
  ],
};

/// Three FAQs for this phase, rotating each app launch. Phase-specific
/// questions come first — they are the ones she is most likely to be asking
/// today — then the universal pool fills the rest.
List<PhaseFaq> phaseFaqs(int phaseNumber, {int count = 3}) {
  _rotateOnce();
  final specific = _byPhase[phaseNumber] ?? const <PhaseFaq>[];
  final pool = <PhaseFaq>[...specific, ..._universal];
  if (pool.length <= count) return pool;

  final rest = <PhaseFaq>[..._universal];
  final out = <PhaseFaq>[...specific.take(count)];
  var i = 0;
  while (out.length < count && rest.isNotEmpty) {
    out.add(rest[(_rotation + i) % rest.length]);
    i++;
  }
  return out.take(count).toList();
}
