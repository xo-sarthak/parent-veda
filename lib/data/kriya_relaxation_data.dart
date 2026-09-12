// =============================================================================
//  Kriya — the guided relaxation, as data
// -----------------------------------------------------------------------------
//  Built from `ParentVeda_Garbh_Sanskar_pillars_build.pdf`, pillar 4, 12 Sep
//  2026: *"Guided Relaxation (8 min, head to toe): a real session. For NOW,
//  narrate a written progressive-relaxation script with on-device
//  text-to-speech, synced to a gentle timer and a calm visual... Make the
//  script and narration data-driven so a recorded professional voice replaces
//  the TTS later with no code change."*
//
//  ⚠️ EVERYTHING THE SESSION SAYS AND DOES IS IN THIS LIST. The screen walks
//  it: one step at a time, for [seconds], lighting [part] on the figure,
//  speaking [script] through `GarbhNarrator`. A longer session, a different
//  order, a step cut — data. A recorded voice — a line in the narration
//  manifest under [narrationKey], and the TTS stops being used for that step
//  the day the file is listed. Nothing in the screen names a step.
//
//  ⚠️ THE SCRIPT IS ORIGINAL, WRITTEN HERE, AND MAKES NO CLAIM. The pillars
//  brief allows writing ("plain, warm, original") and forbids one thing
//  absolutely: *"Make NO claim that any of this makes the baby smarter,
//  calmer or healthier."* So the belly step says the baby is there and this
//  rest is hers — and stops. `test/kriya_relaxation_test.dart` greps every
//  step for the words that would break that.
//
//  ⚠️ SIDE OR PROPPED, NEVER FLAT. The first step says where to lie, because
//  a relaxation script that opens "lie on your back" is the one instruction
//  in it that prenatal guidance contradicts from the second trimester on. The
//  Kriya safety note says the same in fewer words; both are on the intro.
//
//  ⚠️ HEAD TO TOE. The brief's own words, and the figure's highlight runs
//  0 (head) to 1 (feet) with it. Progressive relaxation is often taught the
//  other way; the brief chose, so the script follows.
//
//  ⚠️ ENGLISH ONLY. New copy, per CLAUDE.md. A Hindi narration is a
//  manifest entry when one is recorded.
// =============================================================================

/// One step of the session.
class KriyaRelaxationStep {
  const KriyaRelaxationStep({
    required this.id,
    required this.title,
    required this.script,
    required this.seconds,
    required this.part,
  });

  final String id;

  /// The heading on screen — "Your shoulders".
  final String title;

  /// What is spoken, and what is printed under the heading so the step is
  /// readable with the sound off (TTC's rule: *"the step text must be
  /// readable on its own for someone who cannot see the animation"*).
  final String script;

  /// How long the step holds, narration and silence together.
  final int seconds;

  /// Where the figure lights up: 0 at the head, 1 at the feet, 0.5 for the
  /// whole body.
  final double part;

  /// The key the narration manifest would carry a recording under.
  String get narrationKey => 'kriya.relax.$id';
}

/// The session: title, intro, the steps, the close.
class KriyaRelaxation {
  const KriyaRelaxation({
    required this.title,
    required this.intro,
    required this.steps,
    required this.close,
    this.figureAsset,
  });

  final String title;

  /// Read on the intro, before Begin.
  final String intro;
  final List<KriyaRelaxationStep> steps;

  /// The last words, on the finished screen. Not a celebration.
  final String close;

  /// A Rive/Lottie figure, when one is drawn. Null: the schematic figure.
  final String? figureAsset;

  int get totalSeconds => steps.fold(0, (a, s) => a + s.seconds);
}

const KriyaRelaxation kKriyaRelaxation = KriyaRelaxation(
  title: 'Guided Relaxation',
  intro: 'Eight minutes, head to toe. A voice walks you down your body, one '
      'part at a time, and asks each one to let go. You do not have to do it '
      'well. You only have to lie there.',
  close: 'That is the whole thing. Stay as long as you like; there is nowhere '
      'to be.',
  steps: [
    KriyaRelaxationStep(
      id: 'settle',
      title: 'Settle in',
      part: 0.5,
      seconds: 45,
      script: 'Lie on your side with a pillow between your knees, or sit back '
          'with something behind you. Not flat on your back. Let the surface '
          'take your weight. Close your eyes if you want to, or let them rest '
          'on one point. Breathe in slowly, and let it out even more slowly.',
    ),
    KriyaRelaxationStep(
      id: 'face',
      title: 'Your face',
      part: 0.06,
      seconds: 35,
      script: 'Start at the top. Let your forehead go smooth. Let the small '
          'muscles around your eyes soften, and let your eyes feel heavy in '
          'their sockets. There is nothing to look at.',
    ),
    KriyaRelaxationStep(
      id: 'jaw',
      title: 'Your jaw and throat',
      part: 0.12,
      seconds: 30,
      script: 'Unclench your jaw. Let your teeth come apart a little, and let '
          'your tongue rest. Swallow once, and let your throat be soft.',
    ),
    KriyaRelaxationStep(
      id: 'neck',
      title: 'Your neck and shoulders',
      part: 0.22,
      seconds: 40,
      script: 'Let your head be heavy and held. Now your shoulders. They have '
          'been carrying more than they say. Let them drop away from your '
          'ears, an inch, and then another. Breathe out, and let them drop '
          'again.',
    ),
    KriyaRelaxationStep(
      id: 'arms',
      title: 'Your arms and hands',
      part: 0.30,
      seconds: 40,
      script: 'Down your arms. Your upper arms, your elbows, your forearms. '
          'Let your hands open. Let the fingers uncurl and lie wherever they '
          'fall. There is nothing to hold right now.',
    ),
    KriyaRelaxationStep(
      id: 'chest',
      title: 'Your chest and your breath',
      part: 0.36,
      seconds: 40,
      script: 'Notice your breath, without changing it. It comes in, and it '
          'goes out, and your chest rises and falls on its own. Let it be a '
          'little slower, if it wants to. Let it be exactly as it is, if it '
          'does not.',
    ),
    KriyaRelaxationStep(
      id: 'belly',
      title: 'Your belly',
      part: 0.46,
      seconds: 45,
      script: 'Rest a hand on your belly if you like. Let it be soft and '
          'round. Your baby is right here, and this is a quiet minute the '
          'two of you share. Nothing here has to help anyone. It only has to '
          'feel like rest.',
    ),
    KriyaRelaxationStep(
      id: 'back',
      title: 'Your lower back and hips',
      part: 0.55,
      seconds: 40,
      script: 'Your lower back works hard every day now. Let it widen and '
          'soften into whatever is under it. Let your hips be heavy. Let the '
          'pillow between your knees do its job.',
    ),
    KriyaRelaxationStep(
      id: 'thighs',
      title: 'Your thighs',
      part: 0.68,
      seconds: 35,
      script: 'Down into your thighs. Let the big muscles at the front and '
          'the back go slack. They do not have to hold you up. Nothing does, '
          'for now.',
    ),
    KriyaRelaxationStep(
      id: 'calves',
      title: 'Your knees and calves',
      part: 0.80,
      seconds: 35,
      script: 'Your knees, soft. Your calves, letting go. If they have been '
          'tight or heavy today, let that heaviness sink out of them and into '
          'the bed.',
    ),
    KriyaRelaxationStep(
      id: 'feet',
      title: 'Your feet',
      part: 0.95,
      seconds: 35,
      script: 'All the way down to your feet. Let your ankles loosen. Let '
          'your toes spread and rest. Feel the whole length of you, from the '
          'top of your head to the ends of your feet, lying still.',
    ),
    KriyaRelaxationStep(
      id: 'whole',
      title: 'All of you',
      part: 0.5,
      seconds: 35,
      script: 'Nothing to do now. Breathe. Let each breath out take a little '
          'more with it. You are held, you are resting, and that is the '
          'whole of the practice.',
    ),
    KriyaRelaxationStep(
      id: 'return',
      title: 'Coming back',
      part: 0.5,
      seconds: 25,
      script: 'When you are ready, and not before, wriggle your fingers and '
          'your toes. Take one deeper breath. Open your eyes slowly. Take '
          'your time getting up; roll to your side first.',
    ),
  ],
);
