// =============================================================================
//  GrowthActivityScreen — Growth · activity detail (parenting app · S8)
// -----------------------------------------------------------------------------
//  A play, fully explained: why it works → how to play (numbered) → mark-done →
//  optional extensions → go-deeper. Faithful build of Claude Design S8.
//
//  Now DATA-DRIVEN: the screen renders whichever [GrowthActivity] it is given so
//  that every "activity" card across the app (Peekaboo, Reach for the ring, a new
//  sound, tummy time, narrating) opens its OWN content instead of always showing
//  Peekaboo. Defaults to Peekaboo for back-compatibility with existing callers.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

/// One fully-explained play. Kept small and const so callers can pass a preset.
class GrowthActivity {
  const GrowthActivity({
    required this.eyebrow,
    required this.title,
    required this.why,
    required this.steps,
    required this.extendNote,
    required this.products,
    required this.deeper,
  });

  final String eyebrow;
  final String title;
  final String why;
  final List<String> steps;
  final String extendNote;
  // (title, why, price, productId)
  final List<(String, String, String, String)> products;
  // (pill, text)
  final List<(String, String)> deeper;
}

// ---- presets ----------------------------------------------------------------
const GrowthActivity kActPeekaboo = GrowthActivity(
  eyebrow: 'Grow · 5 min',
  title: 'Peekaboo, slow and silly',
  why:
      "Leap 4 is all about cause and effect. Hiding your face and reappearing teaches Aarav that you still exist when you vanish — the very first seed of object permanence, and a gentle antidote to this month's clinginess.",
  steps: [
    'Cover your face with your hands, or a light muslin cloth.',
    'Pause a beat — let him wonder where you went.',
    'Reappear with a bright "peekaboo!" and a big smile.',
    "Repeat while he's delighted; stop before he tires.",
  ],
  extendNote: 'Optional — the game needs nothing but you.',
  products: [
    ('Peekaboo Cloth Book', 'Flaps that hide and reveal — object permanence you can hold.', '₹399', 'clothbook'),
    ('Crinkle Sensory Set', 'Crinkly textures to hide and find during play.', '₹499', 'crinkle'),
  ],
  deeper: [
    ('FAQ', 'When does object permanence develop?'),
    ('Course', 'Play & Brain · Leap 4 activities'),
    ('Room', 'Boy moms · favourite 4-month games'),
  ],
);

const GrowthActivity kActReachRing = GrowthActivity(
  eyebrow: 'Grow · 4 min',
  title: 'Reach for the ring',
  why:
      "At four months, reaching becomes intentional — hand and eye start working as a team. Holding a light ring just within reach invites Aarav to plan a movement, stretch and grasp: the groundwork for every skill that needs two coordinated hands.",
  steps: [
    'Sit him propped, or lay him on his back, well supported.',
    'Hold a light ring or rattle a hand-span above his chest.',
    'Wait — let him track it, then aim and swipe. Cheer the try, not just the catch.',
    'Move it slowly side to side so he reaches across his midline.',
  ],
  extendNote: 'Optional — your hands and any light toy are enough.',
  products: [
    ('Crinkle Sensory Set', 'Light, grabbable textures that reward a reach.', '₹499', 'crinkle'),
    ('High-Contrast Play Gym', 'Dangling toys at the perfect height to reach for.', '₹1,999', 'playgym'),
  ],
  deeper: [
    ('FAQ', 'When do babies reach and grasp?'),
    ('Course', 'Play & Brain · hand skills'),
    ('Room', '4-month play ideas'),
  ],
);

const GrowthActivity kActNewSound = GrowthActivity(
  eyebrow: 'Grow · 3 min',
  title: 'Introduce a new sound',
  why:
      "Aarav is mapping the world by ear now. A gentle new sound — a shaker, a spoon on a cup, your humming — makes him still, search and connect what he hears to where it comes from. That listening-and-locating is the very root of language and attention.",
  steps: [
    'Choose one soft, clear sound — a rattle, a spoon on a cup, a hum.',
    'Out of his sight, make the sound to one side and pause.',
    'Watch him still, then turn toward it — narrate: "You heard that!"',
    'Try the other side, and let him reach for the source.',
  ],
  extendNote: 'Optional — everyday household sounds work beautifully.',
  products: [
    ('Crinkle Sensory Set', 'Gentle crinkle sounds to find and turn toward.', '₹499', 'crinkle'),
    ('Peekaboo Cloth Book', 'Soft, crinkly pages that make a findable sound.', '₹399', 'clothbook'),
  ],
  deeper: [
    ('FAQ', 'How does hearing shape early language?'),
    ('Course', 'Play & Brain · sound & listening'),
    ('Room', 'Sensory play ideas'),
  ],
);

const GrowthActivity kActTummyTime = GrowthActivity(
  eyebrow: 'Grow · 5 min',
  title: 'Tummy time, made joyful',
  why:
      "Every minute on his front strengthens the neck, shoulders and core that rolling, sitting and crawling will need. Many babies protest at four months — so we make it short, social and rewarding, with your face as the prize.",
  steps: [
    'Lay him on a firm, flat surface on his tummy.',
    'Get down to his level, face to face, and talk.',
    'Add a mirror or toy just ahead to tempt a reach.',
    'Keep it short and frequent — stop before the fuss builds.',
  ],
  extendNote: 'Optional — a mirror or toy simply adds delight.',
  products: [
    ('High-Contrast Play Gym', 'A mirror and toys to lift up and reach for.', '₹1,999', 'playgym'),
    ('Peekaboo Cloth Book', 'Props up an inch of interest during tummy time.', '₹399', 'clothbook'),
  ],
  deeper: [
    ('FAQ', 'How much tummy time at 4 months?'),
    ('Course', 'Motor skills · the road to rolling'),
    ('Room', 'Tummy-time wins & tips'),
  ],
);

const GrowthActivity kActNarrate = GrowthActivity(
  eyebrow: 'Grow · 5 min',
  title: 'Narrate your day',
  why:
      "Long before his first word, Aarav is building the ear for language. When you narrate — 'now we pour the water' — and pause as if for his reply, you hand him the rhythm of conversation and thousands of words a day to soak in.",
  steps: [
    'Pick an everyday moment — a nappy change, cooking, a walk.',
    'Say what you are doing, simply and warmly.',
    'Pause, as if waiting for his answer.',
    'When he coos back, respond — that is his first conversation.',
  ],
  extendNote: 'Optional — your voice is the only tool you need.',
  products: [
    ('Peekaboo Cloth Book', 'First words and pictures to read aloud together.', '₹399', 'clothbook'),
    ('Crinkle Sensory Set', 'Textures to name as you narrate play.', '₹499', 'crinkle'),
  ],
  deeper: [
    ('FAQ', 'How do babies learn language before speaking?'),
    ('Course', 'Language · the talking baby'),
    ('Room', 'Chatty-baby ideas'),
  ],
);

class GrowthActivityScreen extends StatefulWidget {
  const GrowthActivityScreen({super.key, this.activity = kActPeekaboo});

  final GrowthActivity activity;

  @override
  State<GrowthActivityScreen> createState() => _GrowthActivityScreenState();
}

class _GrowthActivityScreenState extends State<GrowthActivityScreen> {
  bool _done = false;
  bool _liked = false;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, "Today's play")),

            const SizedBox(height: 24),
            _pad(ppEyebrow(a.eyebrow)),
            const SizedBox(height: 10),
            _pad(Text(a.title, style: ppFraunces(31, h: 1.15))),

            const SizedBox(height: 20),
            _pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppEyebrow('Why it works', color: ppPurple, spacing: 0.8),
                const SizedBox(height: 8),
                Text(a.why, style: ppBody(14, color: ppInk, h: 1.6)),
              ]),
            )),

            _pad(ppSectionDivider()),
            _pad(ppEyebrow('How to play', color: ppSoft, spacing: 1.2)),
            const SizedBox(height: 6),
            for (int i = 0; i < a.steps.length; i++)
              _pad(_step((i + 1).toString().padLeft(2, '0'), a.steps[i], top: true, bottom: i == a.steps.length - 1)),

            const SizedBox(height: 22),
            _pad(Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _done = !_done),
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _done ? ppPanel : ppPurple,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ppPurple),
                    ),
                    child: Text(_done ? 'Done ✓' : 'Mark as done',
                        style: ppBody(15, color: _done ? ppPurple : Colors.white, w: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _liked = !_liked),
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppLine)),
                  child: Text(_liked ? '♥' : '♡', style: TextStyle(color: _liked ? ppCoral : ppMuted, fontSize: 20)),
                ),
              ),
            ])),

            _pad(ppSectionDivider()),
            _pad(Text('To extend the play', style: ppJakarta(16))),
            const SizedBox(height: 6),
            _pad(Text(a.extendNote, style: ppBody(12, color: ppMuted))),
            const SizedBox(height: 14),
            for (int i = 0; i < a.products.length; i++)
              _pad(ppProductRow(context, a.products[i].$1, a.products[i].$2, a.products[i].$3,
                  top: true, bottom: i == a.products.length - 1, productId: a.products[i].$4)),

            _pad(ppSectionDivider()),
            _pad(Text('Go deeper', style: ppJakarta(16))),
            const SizedBox(height: 14),
            for (int i = 0; i < a.deeper.length; i++)
              _pad(ppDeeperRow(context, a.deeper[i].$1, a.deeper[i].$2, top: true, bottom: i == a.deeper.length - 1)),
          ],
        ),
      ),
    );
  }

  Widget _step(String n, String text, {bool top = false, bool bottom = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(n, style: ppBody(14, color: ppPurple, w: FontWeight.w700)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: ppBody(14, color: ppInk, h: 1.5))),
        ]),
      );
}
