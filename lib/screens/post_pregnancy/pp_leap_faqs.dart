// =============================================================================
//  Leap FAQs — the questions parents actually ask during each leap
// -----------------------------------------------------------------------------
//  Shown three at a time on the My Child home, ROTATING each app launch so a
//  parent who opens the app daily meets the whole pool over a week rather than
//  the same three forever. Anything not covered goes to Ask Veda.
//
//  These are written to answer the 3am question honestly — "is this normal",
//  "am I making it worse", "when does it end" — not to reassure blandly. Each
//  answer earns its place by telling her something she did not already know.
// =============================================================================

class LeapFaq {
  const LeapFaq(this.question, this.answer);
  final String question;
  final String answer;
}

/// Rotates once per app LAUNCH, not per rebuild — otherwise the questions would
/// shuffle under her thumb every time the page repainted. Incremented the first
/// time the home asks for FAQs in a session.
int _rotation = 0;
bool _rotated = false;

void _rotateOnce() {
  if (_rotated) return;
  _rotated = true;
  _rotation++;
}

/// Questions asked in EVERY leap. Pooled with the leap-specific ones so a leap
/// with few of its own still has enough to rotate through.
const List<LeapFaq> _universal = [
  LeapFaq(
    'Is this fussiness my fault?',
    'No. Leaps are driven by his brain reorganising itself, not by anything you did or did not do. The clinginess is him seeking his safest place while everything else feels unfamiliar — which is a compliment, even when it does not feel like one at 3am.',
  ),
  LeapFaq(
    'How long does a leap usually last?',
    'Most run one to three weeks, and the hardest stretch is usually shorter than that. Fussiness that lasts well beyond the leap window, or comes with fever, poor feeding or unusual listlessness, is worth a call to your paediatrician — that is not a leap.',
  ),
  LeapFaq(
    'Should I keep to the routine or let it slide?',
    'Keep the shape, loosen the timings. Familiar order helps him feel safe, but a leap is a poor week to enforce a schedule. You are not undoing months of work by holding him more this week.',
  ),
  LeapFaq(
    'He has started waking at night again. Have we gone backwards?',
    'Almost certainly not. Sleep commonly fragments during a leap and settles again after. It reads as regression because the change is sudden, but the underlying skill is moving forward, not back.',
  ),
  LeapFaq(
    'Can I do anything to speed a leap up?',
    'Not really, and trying tends to make it harder. What helps is meeting the new skill where it is — the activities in each domain are there for exactly that — and protecting your own rest so you can be steady through it.',
  ),
];

/// Leap-specific questions, keyed by leap number.
const Map<int, List<LeapFaq>> _byLeap = {
  1: [
    LeapFaq(
      'He startles at everything. Is that normal?',
      'Yes. In the world of sensations everything arrives at once and unfiltered — light, sound, his own body. Startling is his nervous system learning where the edges are. Swaddling and dimmer, quieter rooms genuinely help this week.',
    ),
  ],
  2: [
    LeapFaq(
      'Why does he stare at the ceiling fan for so long?',
      'He has just started noticing patterns, and repeating shapes are the easiest ones to find. It looks like zoning out; it is closer to studying. Let him — this is concentration, and interrupting it is a small waste.',
    ),
  ],
  3: [
    LeapFaq(
      'His movements suddenly look jerky again.',
      'Smooth transitions are exactly what he is working on. Motion that was reflexive is becoming deliberate, and deliberate is clumsy before it is graceful. It smooths out on its own.',
    ),
  ],
  4: [
    LeapFaq(
      'What is cause and effect actually doing for him?',
      'He is working out that his own actions change the world — he shakes, and it rattles. It is the seed of every problem he will ever solve. Pausing after you respond, so he notices the link, does more than any toy.',
    ),
    LeapFaq(
      'He wants to be held constantly this week.',
      'Leap four is one of the more demanding ones. Understanding that events have causes also means understanding that you leaving has a consequence. Extra closeness now does not create a habit; it settles the anxiety that is driving it.',
    ),
    LeapFaq(
      'Should he be rolling by now?',
      'The usual window is wide — many babies roll somewhere between four and six months, and some skip straight past it. Floor time on his tummy while he is content does more than practice drills. Mention it at your next visit if he is not pushing up on his forearms at all.',
    ),
  ],
  5: [
    LeapFaq(
      'He has become wary of people he used to smile at.',
      'The world of relationships includes distance — he now understands that you can move away from him, which makes strangers newly significant. Let him approach at his own pace rather than being passed around.',
    ),
  ],
  6: [
    LeapFaq(
      'He sorts and re-sorts the same toys endlessly.',
      'He is building categories — soft things, round things, things that make noise. Repetition is how the category firms up. It is genuinely productive, however dull it looks from the outside.',
    ),
  ],
  7: [
    LeapFaq(
      'He gets frustrated halfway through things now.',
      'Sequences mean he can picture the finished thing before he can do it — stacking, posting, fitting. The gap between intention and ability is where the frustration lives, and it closes with practice, not rescue.',
    ),
  ],
  8: [
    LeapFaq(
      'He copies everything we do.',
      'Programs are whole sequences of actions — sweeping, stirring, wiping. Imitation is how he learns them. Giving him a safe version of the real thing beats a toy version almost every time.',
    ),
  ],
  9: [
    LeapFaq(
      'He has started testing limits deliberately.',
      'He is discovering that principles exist and can be probed — that a rule holds, or does not. It is not defiance in the adult sense. Consistency is what turns the testing into understanding.',
    ),
  ],
  10: [
    LeapFaq(
      'His personality suddenly seems much more his own.',
      'Systems means he is beginning to see himself as a person among people, with preferences he can act on. What looks like stubbornness is often the first draft of a self.',
    ),
  ],
};

/// Three FAQs for this leap, rotating each app launch. Leap-specific questions
/// come first (they are the ones she is most likely to be asking today), then
/// the universal pool fills the rest.
List<LeapFaq> leapFaqs(int leapNumber, {int count = 3}) {
  _rotateOnce();
  final pool = <LeapFaq>[...?_byLeap[leapNumber], ..._universal];
  if (pool.length <= count) return pool;
  // Keep the leap-specific ones anchored at the top, rotate through the rest,
  // so the most relevant question never rotates away.
  final specific = _byLeap[leapNumber] ?? const <LeapFaq>[];
  final rest = <LeapFaq>[..._universal];
  final out = <LeapFaq>[...specific.take(count)];
  var i = 0;
  while (out.length < count && rest.isNotEmpty) {
    out.add(rest[(_rotation + i) % rest.length]);
    i++;
  }
  return out.take(count).toList();
}
