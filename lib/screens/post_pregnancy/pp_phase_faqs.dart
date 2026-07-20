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
    'No. Hard stretches come from his brain reorganising itself, not from anything you did or did not do. The clinginess is him seeking his safest place while everything else feels unfamiliar — which is a compliment, even when it does not feel like one at 3am.',
  ),
  PhaseFaq(
    'How long do these difficult stretches last?',
    'Usually days rather than weeks, and they do not run to a schedule — no two children follow the same pattern, which is exactly why we do not print one. Fussiness that drags on, or arrives with fever, poor feeding or unusual listlessness, is worth a call to your paediatrician. That is not development.',
  ),
  PhaseFaq(
    'Should I keep to the routine or let it slide?',
    'Keep the shape, loosen the timings. Familiar order helps him feel safe, but a hard week is a poor time to enforce a schedule. You are not undoing months of work by holding him more.',
  ),
  PhaseFaq(
    'He has started waking at night again. Have we gone backwards?',
    'Almost certainly not. Sleep commonly fragments while a new skill is arriving and settles again after. It reads as regression because the change is sudden, but the underlying skill is moving forward.',
  ),
  PhaseFaq(
    'Everyone compares. Is he behind?',
    'The milestones we show are the ones about three in four children reach by that age — not an average, and not a deadline. A child can sit outside a range and be perfectly well. What matters is steady progress and your own instinct; if that instinct says something is off, tell your paediatrician rather than the internet.',
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
      'He startles at everything. Is that normal?',
      'Yes. He has come from somewhere warm, dark and constant into a world that is none of those things, and everything arrives unfiltered. Startling is his nervous system learning where the edges are. Swaddling and dimmer, quieter rooms genuinely help.',
    ),
    PhaseFaq(
      'Am I feeding him too often?',
      'Almost certainly not. Eight to twelve feeds in twenty-four hours is normal in the early weeks, and a newborn stomach empties fast. Feeding on demand is not a habit you are creating — it is how supply establishes.',
    ),
  ],
  2: [
    PhaseFaq(
      'The crying is worse than it was. What is happening?',
      'Crying rises from birth and peaks somewhere around six weeks, then falls away through three to four months. This is one of the few infant findings almost nobody disputes — it happens across cultures and feeding methods. If this is your hardest month, you are also close to the turn.',
    ),
  ],
  3: [
    PhaseFaq(
      'He hates tummy time. Do I have to?',
      'Short and often beats long and once. A few minutes several times a day, always stopping while he is still content, builds the neck strength that rolling and sitting depend on. On your chest counts.',
    ),
  ],
  5: [
    PhaseFaq(
      'He was sleeping better a month ago. What went wrong?',
      'Nothing. Around four months his sleep reorganises from the simple newborn pattern into cycles with lighter and deeper phases — the structure he keeps for life. At the end of each cycle he surfaces near waking, and if he cannot resettle, he calls you. It is developmental, not a habit you created.',
    ),
    PhaseFaq(
      'Should he be rolling by now?',
      'The window is wide — many babies roll between four and six months, and some skip it and go straight to sitting. Floor time while he is content does more than practice drills. Do mention it if he is not pushing up on his forearms at all.',
    ),
  ],
  7: [
    PhaseFaq(
      'How do I know he is ready for food?',
      'Sitting with support, holding his head steady, showing real interest in what you are eating, and having lost the reflex that pushes food back out. Age alone is not the signal — those four are.',
    ),
    PhaseFaq(
      'He eats almost nothing. Should I worry?',
      'Not at this age. Food before one is about learning to eat, not about calories — milk is still supplying nearly all of it. A teaspoon taken with interest beats a bowl pushed in.',
    ),
  ],
  9: [
    PhaseFaq(
      'He screams when I leave the room. Is this a phase?',
      'It is, and it is an achievement in disguise. He has worked out that you still exist when you are out of sight — which is why he now objects. Short, cheerful goodbyes teach him you come back; sneaking out teaches him to watch you constantly.',
    ),
  ],
  10: [
    PhaseFaq(
      'The doctor mentioned a screening. Should I be worried?',
      'No. At nine months a developmental screening is recommended for every child, not because anything is suspected. It is a short questionnaire, usually filled in by you, designed to catch things early enough that support is easy. Being screened says nothing about your child.',
    ),
  ],
  11: [
    PhaseFaq(
      'He picks up everything off the floor now.',
      'The pincer grasp has arrived — thumb and forefinger together. It is the same skill that lets him feed himself, and it means this is the week to get down at his eye level and look at your floor properly. What he can pick up, he can choke on.',
    ),
  ],
  13: [
    PhaseFaq(
      'He is one and not walking. Is that a problem?',
      'Walking anywhere from about nine to seventeen months is normal, and late walkers are not slower children. What is worth mentioning is if he is not pulling to stand at all, or not bearing weight on his legs.',
    ),
    PhaseFaq(
      'How much milk now?',
      'Cow milk is fine from one year, capped around 500 ml a day. Beyond that it crowds out iron-rich food — and excess milk is the most common cause of toddler iron deficiency in India.',
    ),
  ],
  14: [
    PhaseFaq(
      'He only has a few words. Should I push?',
      'Pushing rarely helps; talking does. Narrate what you are doing, leave gaps as though waiting for an answer, and respond to gestures as if they were sentences. Gestures matter as much as words at this age — a child who communicates well without words is communicating well.',
    ),
  ],
  15: [
    PhaseFaq(
      'Why is he being screened for autism if nothing is wrong?',
      'Because it is recommended for every child at eighteen months, and again at twenty-four. Universal screening exists precisely so it is not reserved for children someone already worried about — that is what makes it useful, and what makes it mean nothing about yours.',
    ),
  ],
  16: [
    PhaseFaq(
      'The tantrums are constant. What am I doing wrong?',
      'Nothing. He now knows exactly what he wants and can picture it clearly, but has almost none of the language to negotiate for it and none of the brain machinery to manage the frustration. That gap IS the tantrum. It closes with language, not with discipline.',
    ),
    PhaseFaq(
      'He will not share. Is that normal?',
      'Completely. Playing near other children rather than with them is exactly right at two, and sharing is a skill that arrives considerably later. Its absence now is not a character flaw.',
    ),
  ],
  17: [
    PhaseFaq(
      'When should we start potty training?',
      'When he shows the signals, not when he reaches an age or when another child did. Staying dry for a couple of hours, telling you afterwards, and being able to pull clothes down are the ones that matter. Starting before those appear usually takes longer, not less.',
    ),
  ],
  19: [
    PhaseFaq(
      'The endless why questions are exhausting.',
      'He has just worked out that things have causes and that you might know them. Short honest answers do more than perfect ones, and "I do not know — shall we find out?" is a genuinely good answer.',
    ),
    PhaseFaq(
      'Strangers cannot understand him. Is that a problem?',
      'By four, most of what he says should be understandable to someone outside the family. If it routinely is not, that is worth raising with your paediatrician — not a reason to panic, but worth raising.',
    ),
  ],
  20: [
    PhaseFaq(
      'Is he ready for school?',
      'Readiness is far more about sitting for a short activity, following a two-step instruction, managing the toilet, and separating from you calmly than about letters and numbers. The academics catch up fast; the rest takes longer to build.',
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
