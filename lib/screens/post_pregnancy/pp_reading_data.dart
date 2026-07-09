// =============================================================================
//  ParentVeda Reading Experience ("Learn") - content model, catalog + store
// -----------------------------------------------------------------------------
//  Internally "Articles", but designed as a premium reading EXPERIENCE (Kindle +
//  Medium + Headway feel), not a blog. Answers "what should I learn today to be a
//  more confident parent?". So the model carries a teaser, a "why this matters
//  today" line, structured sections with inline ParentVeda Tips + Myth-vs-Fact
//  cards, reading time, a collection, and links onward (Read Next). Content is
//  story/science/calm per the ParentVeda voice. Self-contained; the existing
//  Articles archive/reader are left untouched. Scenario child: Aarav (4 mo).
// =============================================================================

import 'package:flutter/material.dart';

/// An expandable "ParentVeda tip" shown inline in the reader.
class ReadTip {
  const ReadTip(this.title, this.body);
  final String title;
  final String body;
}

/// A myth-vs-fact card shown inline - one of the reader's signature elements.
class MythFact {
  const MythFact(this.myth, this.fact);
  final String myth;
  final String fact;
}

/// One block of an article. A section can carry a heading (for the table of
/// contents), body paragraphs, and optionally an inline tip / myth-fact / image.
class ReadSection {
  const ReadSection({
    this.heading,
    this.paragraphs = const [],
    this.tip,
    this.mythFact,
    this.image = false,
  });
  final String? heading;
  final List<String> paragraphs;
  final ReadTip? tip;
  final MythFact? mythFact;
  final bool image;
}

/// The kind of read, used by the Learn filters.
enum ReadKind { article, bookSummary, research }

String readKindLabel(ReadKind k) => switch (k) {
      ReadKind.article => 'Articles',
      ReadKind.bookSummary => 'Book Summaries',
      ReadKind.research => 'Research Summaries',
    };

class ReadArticle {
  const ReadArticle({
    required this.id,
    required this.title,
    required this.teaser,
    required this.whyToday,
    required this.collection,
    required this.ageTag,
    required this.minutes,
    required this.seed,
    required this.author,
    required this.authorRole,
    required this.sections,
    this.kind = ReadKind.article,
    this.evidence,
    this.relatedActivity,
    this.relatedVideoId,
    this.relatedRecipeId,
    this.relatedProductId,
    this.relatedCommunity,
  });

  final String id;
  final String title;
  final String teaser; // one-line hook
  final String whyToday; // "why this matters today"
  final String collection; // collection id
  final String ageTag;
  final int minutes;
  final int seed;
  final String author;
  final String authorRole;
  final List<ReadSection> sections;
  final ReadKind kind;
  final String? evidence; // a plain-language evidence note
  final String? relatedActivity;
  final String? relatedVideoId;
  final String? relatedRecipeId;
  final String? relatedProductId;
  final String? relatedCommunity;

  /// Section headings for the table of contents.
  List<String> get toc => [for (final s in sections) if (s.heading != null) s.heading!];
}

class ReadCollection {
  const ReadCollection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.articleIds,
    required this.seed,
  });
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> articleIds;
  final int seed;
}

// ---- collections ------------------------------------------------------------
const List<ReadCollection> kReadCollections = [
  ReadCollection(id: 'sleep', title: 'Understanding Sleep', subtitle: 'Why it changes, and how to work with it.', icon: Icons.bedtime_outlined, articleIds: ['sleepcycles', 'drowsy'], seed: 41),
  ReadCollection(id: 'brain', title: 'Brain Development', subtitle: 'What’s growing behind those new expressions.', icon: Icons.psychology_outlined, articleIds: ['leap4', 'talking'], seed: 42),
  ReadCollection(id: 'feeding', title: 'Feeding & Nutrition', subtitle: 'From milk to first foods, calmly.', icon: Icons.restaurant_outlined, articleIds: ['solids'], seed: 43),
  ReadCollection(id: 'behaviour', title: 'Behaviour & Emotions', subtitle: 'Making sense of big feelings.', icon: Icons.favorite_border, articleIds: ['tantrums'], seed: 44),
  ReadCollection(id: 'health', title: 'Health & Illness', subtitle: 'Calm, clear guidance for the worried moments.', icon: Icons.monitor_heart_outlined, articleIds: ['fever'], seed: 45),
  ReadCollection(id: 'play', title: 'Play & Language', subtitle: 'How the everyday builds a mind.', icon: Icons.toys_outlined, articleIds: ['tummytime', 'talking'], seed: 46),
  ReadCollection(id: 'parent', title: 'The Parent, Too', subtitle: 'Because you matter in this story.', icon: Icons.self_improvement_outlined, articleIds: ['matrescence', 'csection'], seed: 47),
];

// ---- catalog ----------------------------------------------------------------
const List<ReadArticle> kReadArticles = [
  ReadArticle(
    id: 'sleepcycles',
    title: 'Why your baby’s sleep changes at 4 months',
    teaser: 'The famous “regression” is really a leap forward - here’s what’s happening.',
    whyToday: 'Aarav is right in the middle of the 4-month sleep shift. Understanding it is the difference between panic and patience tonight.',
    collection: 'sleep',
    ageTag: '3–6 mo',
    minutes: 6,
    seed: 1,
    author: 'Dr. Ananya Rao',
    authorRole: 'Paediatrician',
    kind: ReadKind.research,
    evidence: 'Aligned with paediatric sleep research on the maturation of infant sleep architecture around 3–4 months.',
    relatedVideoId: 'sleep4mo',
    relatedProductId: 'dozy',
    relatedCommunity: 'Baby Sleep',
    sections: [
      ReadSection(
        paragraphs: [
          'For twelve blissful weeks, your newborn slept like - well, a newborn: long, deep stretches that could happen anywhere. Then, seemingly overnight, the nights fell apart. Waking every two hours. Fighting naps. If it feels like a step backwards, take a breath: it is precisely the opposite.',
        ],
      ),
      ReadSection(
        heading: 'What’s actually changing',
        paragraphs: [
          'Around four months, your baby’s sleep matures from the simple newborn pattern into the cycled, adult-like structure they’ll keep for life. Sleep now moves through lighter and deeper phases - and at the end of each cycle, there’s a brief surfacing to near-waking.',
          'A baby who hasn’t yet learned to drift back down on their own will fully wake at each of those moments. Hence the two-hourly wake-ups. It isn’t a habit gone wrong; it’s a brain growing up.',
        ],
        mythFact: MythFact(
          'My baby has become a “bad sleeper” and we’ve created bad habits.',
          'This is neurological maturation, not a habit. Nearly every baby goes through it, and it settles as they learn to link sleep cycles - usually within 2–6 weeks.',
        ),
      ),
      ReadSection(
        heading: 'What genuinely helps',
        paragraphs: [
          'You can’t rush the brain, but you can make the nights easier. Keep a calm, consistent wind-down so the body learns the cues for sleep. Offer a moment to resettle before rushing in - sometimes they find their way back. Keep the room dark and boring at night, and protect daytime naps, because an overtired baby sleeps worse, not better.',
        ],
        tip: ReadTip(
          'The two-minute pause',
          'When he stirs at night, wait a slow two minutes before going in. Many babies are simply surfacing between cycles and will resettle - going in too fast can wake them fully.',
        ),
      ),
      ReadSection(
        heading: 'When to simply hold on',
        paragraphs: [
          'There is no cry-it-out required here, and no fixing needed - only weathering. If the waking ever comes with fever, poor feeding or seems like pain, that’s a different story and worth a call to your paediatrician. Otherwise, this passes. You are not doing anything wrong.',
        ],
      ),
    ],
  ),
  ReadArticle(
    id: 'leap4',
    title: 'Leap 4, decoded: what the fussiness means',
    teaser: 'The clinginess isn’t a step back. It’s a window opening.',
    whyToday: 'Fussy, clingy, everything-off days often mean a mental leap. Knowing what he’s working on turns frustration into fascination.',
    collection: 'brain',
    ageTag: '3–6 mo',
    minutes: 5,
    seed: 2,
    author: 'Dr. Ananya Rao',
    authorRole: 'Paediatrician',
    relatedVideoId: 'leap4brain',
    relatedActivity: 'Reach for the ring',
    relatedCommunity: '0–1 Year',
    sections: [
      ReadSection(paragraphs: [
        'Some weeks, your baby seems to come undone - extra clingy, extra fussy, feeding and sleeping all over the place, for no reason you can name. Before you worry, consider the loveliest explanation: his brain is about to do something new.',
      ]),
      ReadSection(
        heading: 'The world of events',
        paragraphs: [
          'Around four months, babies enter what’s often called Leap 4 - “the world of events”. For the first time, your baby grasps that one thing leads smoothly to another: your hand reaches, and the toy moves. Cause, meet effect.',
          'It sounds small. It is enormous. The whole world suddenly has a logic to it - and taking that in is genuinely disorienting, which is exactly why he clings a little tighter to the person who makes him feel safe: you.',
        ],
      ),
      ReadSection(
        heading: 'How to walk through it together',
        paragraphs: [
          'Leaps pass, and a new skill usually appears on the far side - a first roll, a new sound, a longer gaze. Until then, more closeness helps, not less. Slow, narrated play - “here comes the ball… and it rolls” - gives his new understanding something to chew on.',
        ],
        tip: ReadTip(
          'Narrate the cause and effect',
          'During play, say the sequence out loud: “you pushed it… and it fell!” You’re handing him words for the very thing his brain is discovering.',
        ),
      ),
    ],
  ),
  ReadArticle(
    id: 'solids',
    title: 'Starting solids without the stress',
    teaser: 'It’s less about nutrition at first, and more about learning to eat.',
    whyToday: 'Solids are a few weeks away for Aarav - knowing the signs and the first foods now means calm, not scramble, later.',
    collection: 'feeding',
    ageTag: '6+ mo',
    minutes: 6,
    seed: 3,
    author: 'Dr. Neha Sharma',
    authorRole: 'Paediatrician',
    relatedRecipeId: 'ragipancake',
    relatedVideoId: 'solids101',
    relatedCommunity: 'Starting Solids',
    sections: [
      ReadSection(paragraphs: [
        'The first spoonful of food is a milestone soaked in excitement and, for many parents, a surprising amount of anxiety. Here’s the reassuring truth: in the beginning, solids are practice, not nutrition. Milk still does the heavy lifting through the whole first year.',
      ]),
      ReadSection(
        heading: 'The real signs of readiness',
        paragraphs: [
          'Forget the calendar for a moment and watch your baby. Readiness - usually around six months - looks like this: he can sit with support and hold his head steady, he’s eyeing your food with real interest, and he’s lost the reflex that pushes food back out with his tongue.',
        ],
        mythFact: MythFact(
          'Start with rice cereal, and start by four months to help him sleep.',
          'Current guidance is to wait for readiness (around six months) and there’s no need to begin with bland cereal. Iron-rich foods matter more - and food doesn’t reliably improve sleep.',
        ),
      ),
      ReadSection(
        heading: 'First foods worth offering',
        paragraphs: [
          'Begin with single, soft foods and introduce one at a time, so any reaction is easy to spot. Iron is the nutrient to be intentional about now - ragi, well-cooked dal, soft greens - because his birth stores are running low. Let him be messy. Playing with food is how he learns it.',
        ],
        tip: ReadTip(
          'One food, a few days',
          'Offer a new single food for two or three days before adding another. It’s the simplest way to notice if something doesn’t agree with him.',
        ),
      ),
    ],
  ),
  ReadArticle(
    id: 'tantrums',
    title: 'Big feelings in a small body',
    teaser: 'A tantrum isn’t bad behaviour. It’s a brain that hasn’t finished building.',
    whyToday: 'A read-ahead for the toddler months - understanding tantrums now makes them far less frightening when they arrive.',
    collection: 'behaviour',
    ageTag: '1–3 yr',
    minutes: 5,
    seed: 4,
    author: 'Dr. Tara Joshi',
    authorRole: 'Child Psychologist',
    kind: ReadKind.bookSummary,
    relatedCommunity: '2 Year Olds',
    sections: [
      ReadSection(paragraphs: [
        'One day, your sweet baby becomes a small person who melts into the supermarket floor because you opened the banana “wrong”. It can feel like defiance. It almost never is.',
      ]),
      ReadSection(
        heading: 'The unfinished brain',
        paragraphs: [
          'The part of the brain that manages big emotions - the thinking, calming, self-controlling part - is years from being built. A toddler feels enormous feelings with none of the tools to manage them. A tantrum isn’t manipulation; it’s a genuine flood, and your child is as overwhelmed by it as you are.',
        ],
        mythFact: MythFact(
          'Giving attention to a tantrum rewards it and makes it worse.',
          'Young children can’t calm alone - they borrow ours. Calm, connected presence (not giving in to the demand) is how they learn regulation over time.',
        ),
      ),
      ReadSection(
        heading: 'Co-regulation, not control',
        paragraphs: [
          'You can’t reason a flooded toddler back to calm, but you can lend yours. Get low, stay steady, name the feeling - “you’re so frustrated” - and wait it out with them. You’re not spoiling; you’re teaching, one storm at a time, that big feelings are survivable.',
        ],
        tip: ReadTip(
          'Name it to tame it',
          'Putting words to the feeling (“you really wanted that”) helps a child’s brain move the emotion from the panic centre toward the thinking part. It works for us grown-ups too.',
        ),
      ),
    ],
  ),
  ReadArticle(
    id: 'fever',
    title: 'Fever, without the fear',
    teaser: 'The number matters less than you think. Here’s what actually does.',
    whyToday: 'The first fever is frightening. Reading this before it happens means clarity, not 2am panic-Googling.',
    collection: 'health',
    ageTag: '0–12 mo',
    minutes: 5,
    seed: 5,
    author: 'Dr. Neha Sharma',
    authorRole: 'Paediatrician',
    kind: ReadKind.research,
    evidence: 'Consistent with standard paediatric guidance; not a substitute for your doctor.',
    relatedCommunity: 'Delhi Parents',
    sections: [
      ReadSection(paragraphs: [
        'A hot little forehead can send any parent’s heart racing. But fever itself isn’t the enemy - it’s a sign the body is doing its job, mounting a defence. What matters most isn’t the exact number on the thermometer; it’s how your baby seems.',
      ]),
      ReadSection(
        heading: 'What the number means',
        paragraphs: [
          'For a baby, 38°C (100.4°F) or above is a fever. Keep him comfortable and well-hydrated with more frequent feeds, dress him lightly, and use paracetamol only at the dose your paediatrician advises for his weight. A child who is drinking, weeing and has moments of playfulness - even with a temperature - is usually weathering it well.',
        ],
        mythFact: MythFact(
          'Teething causes high fever.',
          'Teething may raise the temperature very slightly, but a genuine fever is caused by something else. Don’t blame teeth for a real fever - treat it as illness.',
        ),
      ),
      ReadSection(
        heading: 'When to call, without hesitation',
        paragraphs: [
          'Some things override the number entirely. Call your doctor for: any fever under three months of age, a rash that doesn’t fade under a glass, breathing difficulty, a fit, unusual drowsiness or floppiness, refusing all feeds, or simply your own strong sense that something is wrong. That instinct is data. Trust it.',
        ],
        tip: ReadTip(
          'Watch the child, not the thermometer',
          'How alert, comfortable and hydrated he is tells you more than the exact reading. Note his behaviour to describe to the doctor.',
        ),
      ),
    ],
  ),
  ReadArticle(
    id: 'talking',
    title: 'Talking to your baby before they can talk',
    teaser: 'The conversation starts long before the first word.',
    whyToday: 'Language is being built right now, in the everyday. A few small habits today shape the years of talking ahead.',
    collection: 'play',
    ageTag: '3–12 mo',
    minutes: 4,
    seed: 6,
    author: 'Dr. Kabir Menon',
    authorRole: 'Speech & Language',
    relatedActivity: 'Narrate your day',
    relatedVideoId: 'babbling',
    sections: [
      ReadSection(paragraphs: [
        'It can feel a little silly, narrating your day to a baby who answers only in coos. It is also one of the most powerful things you can do for his developing mind.',
      ]),
      ReadSection(
        heading: 'Serve and return',
        paragraphs: [
          'Language grows through back-and-forth - what researchers call “serve and return”. He babbles; you answer as if it meant something; he lights up and tries again. These tiny exchanges, thousands of them, wire the brain for conversation long before real words arrive.',
        ],
      ),
      ReadSection(
        heading: 'How to have the conversation',
        paragraphs: [
          'You don’t need flashcards. Narrate the ordinary - “now we’re pouring the water” - sing the songs you love, and pause after you speak, as if leaving room for his reply. Read simple books not for the story but for the closeness and the music of your voice. It all counts.',
        ],
        tip: ReadTip(
          'Pause for the reply',
          'After you say something, wait. That silence invites him to “take his turn” with a coo or a look - and teaches him the rhythm of conversation.',
        ),
      ),
    ],
  ),
  ReadArticle(
    id: 'tummytime',
    title: 'The quiet case for tummy time',
    teaser: 'Five minutes on the floor builds more than strong muscles.',
    whyToday: 'Rolling, sitting and crawling all start here. A little happy floor time today is an investment in every milestone ahead.',
    collection: 'play',
    ageTag: '0–6 mo',
    minutes: 3,
    seed: 7,
    author: 'Dr. Meher Shah',
    authorRole: 'Paediatric Physio',
    relatedActivity: 'Chest-to-chest tummy time',
    relatedVideoId: 'tummytime',
    sections: [
      ReadSection(paragraphs: [
        'Tummy time has a reputation for tears. But behind those grumbles, something important is being built - and it doesn’t take much to make it a game he tolerates, even enjoys.',
      ]),
      ReadSection(
        heading: 'Why it matters',
        paragraphs: [
          'Lying on his tummy asks your baby to lift and hold his head, working the neck, shoulder and core muscles he’ll need to roll, sit and eventually crawl. It also gently shapes the back of the head, evening out the flat spots that come from lying on the back.',
        ],
      ),
      ReadSection(
        heading: 'Making it happy',
        paragraphs: [
          'Go short and frequent rather than long - a few minutes, several times a day, building up as he tolerates it. Get down to his eye level, use a mirror or a favourite toy, and always stop before the grumbles turn to real upset, so it stays a good memory. On the tough days, lying chest-to-chest on you counts, too.',
        ],
        tip: ReadTip(
          'End on a high',
          'Scoop him up while he’s still content, not mid-meltdown. Ending happy makes the next session easier.',
        ),
      ),
    ],
  ),
  ReadArticle(
    id: 'drowsy',
    title: 'Drowsy but awake: the hardest skill',
    teaser: 'The gentlest sleep skill of all - and why it takes patience.',
    whyToday: 'If you’re rocking to sleep every time, this is the small, kind shift that can slowly change your nights.',
    collection: 'sleep',
    ageTag: '3–6 mo',
    minutes: 4,
    seed: 8,
    author: 'Dr. Meher Shah',
    authorRole: 'Paediatric Sleep',
    relatedProductId: 'dozy',
    relatedCommunity: 'Baby Sleep',
    sections: [
      ReadSection(paragraphs: [
        'You’ll hear the advice everywhere: “put them down drowsy but awake.” It sounds simple, and it’s quietly one of the hardest - and gentlest - sleep skills to teach.',
      ]),
      ReadSection(
        heading: 'Why it helps',
        paragraphs: [
          'A baby who always falls asleep being rocked or fed learns that this is how sleep happens. So when he surfaces between cycles at night, he needs the same thing again to go back down. Learning to fall asleep in his own bed, a little awake, means he can find his own way back at 3am - without calling for you.',
        ],
        mythFact: MythFact(
          'This means letting him cry it out.',
          'Not at all. Drowsy-but-awake is gradual and gentle - you can stay, soothe and help. It’s about shifting the very last moment of falling asleep from your arms to his bed, slowly.',
        ),
      ),
      ReadSection(
        heading: 'Going gently',
        paragraphs: [
          'Start with just one sleep a day - often the first nap or bedtime, when he’s most primed for sleep. Do your calm wind-down, then lay him down sleepy but not gone. If he protests, pick him up, soothe, and try again. Some nights it works; some it doesn’t. Over weeks, not days, it adds up.',
        ],
      ),
    ],
  ),
  ReadArticle(
    id: 'matrescence',
    title: 'Matrescence: the birth of a mother',
    teaser: 'A baby is born - and so is a whole new you.',
    whyToday: 'Amid all the baby content, this one’s for you. Because how you’re doing matters, deeply.',
    collection: 'parent',
    ageTag: 'All stages',
    minutes: 5,
    seed: 9,
    author: 'Dr. Tara Joshi',
    authorRole: 'Perinatal Mental Health',
    kind: ReadKind.bookSummary,
    relatedVideoId: 'mumwellness',
    relatedCommunity: 'Working Parents',
    sections: [
      ReadSection(paragraphs: [
        'Everyone asks about the baby. Fewer people ask about you - and yet something enormous has happened to you, too. There’s a word for it: matrescence, the profound becoming of a mother. Like adolescence, it’s a whole identity remaking itself, hormones and all.',
      ]),
      ReadSection(
        heading: 'The in-between',
        paragraphs: [
          'You may feel fierce love and flat exhaustion in the same hour. You may grieve your old freedom while adoring your new life. This isn’t failure or ingratitude - it’s the messy, normal in-between of becoming someone new. Two true things can live side by side.',
        ],
        mythFact: MythFact(
          'A good mother feels instant, uncomplicated bliss.',
          'Love often grows gradually, through the ordinary care of long days and nights. Mixed feelings are common and human - persistent hopelessness or dread, though, deserves support: please reach out.',
        ),
      ),
      ReadSection(
        heading: 'Be as kind to you',
        paragraphs: [
          'You can’t pour from an empty cup, and you are not meant to do this alone. Accept the help. Lower the bar on everything that isn’t the baby or you. Protect small pockets of rest without guilt. Looking after yourself isn’t stealing from your child - it’s the very thing that lets you show up for them.',
        ],
        tip: ReadTip(
          'One small thing',
          'Each day, do one small thing that’s only for you - a hot drink while it’s still hot, five minutes outside, a message to a friend. Tiny, but it keeps you tethered to yourself.',
        ),
      ),
    ],
  ),
  ReadArticle(
    id: 'csection',
    title: 'C-section recovery: the full picture',
    teaser: 'Major surgery, and a recovery that deserves as much attention as the birth - here’s what the weeks afterward really involve.',
    whyToday: 'Whether you’re still deciding, have a date fixed, or are already home with your baby, this is the clear picture of recovery few people give you - in body and in heart.',
    collection: 'parent',
    ageTag: 'All stages',
    minutes: 9,
    seed: 10,
    author: 'Dr. Anjali Verma',
    authorRole: 'Obstetrician & Gynaecologist',
    evidence: 'Aligned with standard obstetric guidance on caesarean recovery, wound healing and VBAC. General information for understanding, not a diagnosis - your own doctor knows your situation and your incision best.',
    sections: [
      ReadSection(paragraphs: [
        'A C-section is major surgery, and the recovery deserves as much attention as the birth itself. Yet it is the part least talked about. Whether a mother is still deciding, has a date fixed, or is already home with her baby, this is a clear picture of what the weeks afterward involve, and what genuinely helps, in body and in heart.',
        'A quick note: this is for understanding, not diagnosis. Every recovery differs, and the timings here are general guides. A mother’s own doctor knows her situation and her incision best.',
      ]),
      ReadSection(
        heading: 'What matters most',
        paragraphs: [
          'The essentials, first:',
          '•  The skin heals in about six to eight weeks; the deeper layers take months.\n•  There is no single “right” pace. Recovery varies widely, and slower is not wrong.\n•  Breastfeeding is safe and helpful; the milk may simply take a little longer to arrive.\n•  Nothing heavier than the baby for about six weeks.\n•  Pain that is easing, even slowly, is a good sign. Pain that is worsening needs a doctor.',
        ],
      ),
      ReadSection(
        heading: 'The scar is the smallest part',
        paragraphs: [
          'The line on the skin is the last and shallowest of several layers the surgeon moved through: skin, fat, the sheet of tissue over the muscles, the muscles themselves (parted, not cut), and the womb, each closed in turn.',
          'The skin heals within weeks. The layers beneath keep healing for months. This is why a mother can look almost back to normal at six weeks and still feel tender and tired inside. The scar cannot show the whole of what is mending.',
        ],
      ),
      ReadSection(
        heading: 'Recovery has its own timeline',
        paragraphs: [
          'There is no fixed schedule. Some mothers move comfortably within two weeks; others feel real pain and stiffness for much longer. Both are normal. It depends on whether the surgery was planned or an emergency, whether labour came first, whether it is a repeat C-section, and on the individual body.',
          'The useful signal is direction, not speed. Easing pain reassures; worsening pain is worth a call to the doctor.',
        ],
      ),
      ReadSection(
        heading: 'The first few days',
        paragraphs: [
          'The early days hold most of the surprises. In hospital, a mother can usually expect:',
          '•  Gentle walking, early. It feels hard at first, but it lowers the risk of clots and helps the gut wake up.\n•  A catheter for the first day or so, usually removed the next morning.\n•  Firm pressure on the belly from a nurse, to help the womb contract. Uncomfortable, but it limits bleeding.\n•  Afterpains - cramps as the womb shrinks, often stronger during breastfeeding.\n•  Trapped gas, which can be surprisingly uncomfortable. Walking, warm fluids, and a stool softener help.',
          'The first bowel movement is often awaited with worry, and is usually far easier than expected.',
        ],
      ),
      ReadSection(
        heading: 'When the milk comes in',
        paragraphs: [
          'Few worries feel as tender as wondering whether there is enough milk. So it helps to know how normal a slow start is.',
          'After a C-section, milk often comes in a little later. The fuller feeling many expect around day three can take longer, and research finds this happens to about one in three mothers, more so after a first baby. It is not a sign that something is wrong, or that there will not be enough.',
          'In those first days, the body is already making colostrum - the concentrated early milk, which is exactly what a newborn needs in tiny amounts. What helps the fuller milk arrive is gentle and simple: feeding or expressing often, so the body receives the signal to make more; skin-to-skin contact, which calms both mother and baby and supports let-down; and a lactation consultant’s support if feeding feels hard.',
          'The delay is common, temporary, and no one’s fault.',
        ],
      ),
      ReadSection(
        heading: 'Feeding and moving while it heals',
        paragraphs: [
          'A C-section recovery is unusual, in that the patient is also the round-the-clock carer. A few practical habits make that kinder on a healing body.',
          'Feeding positions that keep weight off the scar: the rugby (football) hold, with the baby along the mother’s side and nothing resting on the incision; side-lying, mother and baby facing each other, ideal for night feeds; and laid-back, reclining slightly with a pillow across the lap as a cushion between baby and incision.',
          'Moving with less strain: get up by rolling onto one side first, then push up with the arms rather than the stomach. Take pain relief on the schedule a doctor advises, rather than waiting for the pain to peak. Keep water, snacks and baby essentials within reach of the feeding spot. Lift nothing heavier than the baby in the first weeks. And accept help - it is part of recovery, not a failure of it.',
        ],
        tip: ReadTip(
          'Splint before you cough',
          'Press a hand or a folded pillow firmly over the scar before you cough, laugh, sneeze or stand up. That gentle support takes the strain off the incision and makes the movement far less sharp.',
        ),
      ),
      ReadSection(
        heading: 'About the belly',
        paragraphs: [
          '“How to reduce the belly” is one of the most common questions after a C-section, and the honest answer is reassuring. In the early weeks, the rounded tummy is mostly swelling, a still-shrinking womb, and muscles that separated during pregnancy - not fat.',
          'So it is not something to attack with crash diets or hard workouts, especially while the body is healing and making milk. The gentler path works better: eating well rather than eating less, and, once a doctor gives clearance, rebuilding from the inside with breathing and pelvic-floor work before any sit-ups. A support binder can feel comforting, though it supports rather than slims. The shape returns with time.',
        ],
      ),
      ReadSection(
        heading: 'Healing the heart, too',
        paragraphs: [
          'Recovery after a C-section is as much emotional as physical, and this side receives far less attention than it deserves.',
          'Feelings about the birth. A planned C-section can feel settled, or not, and either is fine. After an emergency, or a birth that unfolded differently than hoped, a mother may feel disappointment, or a sense that her body fell short. It did not. A C-section is not a lesser birth, and not a failing of effort or will. It is often the reason mother and baby came through safely.',
          'Bonding that takes time. Love does not always arrive like a thunderbolt, and that is normal. After surgery, pain and broken sleep, connection often builds slowly, over days and weeks of holding and feeding. A mother who feels no instant rush has done nothing wrong. Attachment grows in its own time.',
          'When to reach out. Tearfulness and feeling overwhelmed in the first couple of weeks are common - the “baby blues” - and usually settle on their own. What deserves attention is low mood, anxiety, or a sense of distance from the baby that lingers beyond that or deepens. Postpartum depression and anxiety are common and very treatable. A doctor or counsellor can help, and reaching out early is a quiet act of strength.',
        ],
      ),
      ReadSection(
        heading: 'Once a C-section, always? Not necessarily',
        paragraphs: [
          'This belief is widely repeated, and for many mothers it is untrue. Whether a future vaginal birth fits depends on why the first C-section happened, the type of cut on the womb, and the gap before the next pregnancy - all of which a doctor can weigh.',
          'In India, only about one in ten eligible mothers even attempt it, often because no one told them it was possible. Knowing it is an option is where a real choice begins.',
        ],
        mythFact: MythFact(
          'Once a C-section, always a C-section.',
          'For many mothers this isn’t true. A vaginal birth after caesarean (VBAC) is a safe and reasonable option for many, succeeding roughly three times in four when suitable mothers attempt it, with serious risks kept low.',
        ),
      ),
      ReadSection(
        heading: 'When to see a doctor',
        paragraphs: [
          'General information, not medical advice. It is worth contacting a doctor promptly for:',
          '•  A wound that grows redder, more swollen or warm, or leaks fluid or pus.\n•  An incision that opens, or pain that worsens instead of easing.\n•  Fever, or heavy bleeding that soaks a pad in an hour or passes large clots.\n•  Pain, redness or swelling in a leg, or any breathlessness - which need urgent care.\n•  A low mood that will not lift, or a sense of distance from the baby - which deserve support, not silence.',
        ],
      ),
      ReadSection(
        heading: 'ParentVeda Insight',
        paragraphs: [
          'Recovery is usually measured by how quickly a mother “bounces back” - the flat belly, the faded scar, the day she looks like she never had surgery. Her body is measuring something quieter: layers reconnecting, nerves regrowing a millimetre a month, a womb returning to size, milk arriving in its own time, love growing at its own pace. Bouncing back was never the real goal. Healing, in body and in heart, at her own pace, is.',
        ],
      ),
      ReadSection(
        heading: 'Looking ahead',
        paragraphs: [
          'Most C-section recoveries unfold gently and fully, even if slower than expected. The scar fades, sensation returns, milk settles into a rhythm, bonding deepens, and the cautious early days become a memory. Whatever led to the surgery, the body did something remarkable - and it is doing something equally remarkable now, quietly, layer by layer.',
        ],
      ),
    ],
  ),
];

// ---- lookups + engine -------------------------------------------------------
ReadArticle readArticleById(String id) =>
    kReadArticles.firstWhere((a) => a.id == id, orElse: () => kReadArticles.first);
ReadCollection readCollectionById(String id) =>
    kReadCollections.firstWhere((c) => c.id == id, orElse: () => kReadCollections.first);
List<ReadArticle> articlesInCollection(String collectionId) =>
    kReadArticles.where((a) => a.collection == collectionId).toList();

/// Today's one carefully-chosen read (a real engine would personalise; iron/
/// sleep leads for a 4-month-old mid-regression).
ReadArticle todaysRead() => readArticleById('sleepcycles');

/// Personalised picks (seeded order stands in for the recommendation engine).
List<ReadArticle> forYou() => ['leap4', 'solids', 'talking', 'tummytime', 'fever', 'matrescence'].map(readArticleById).toList();

/// Articles of a given kind - for the Learn filters (All / Articles / Book
/// Summaries / Research Summaries).
List<ReadArticle> articlesOfKind(ReadKind k) => kReadArticles.where((a) => a.kind == k).toList();

/// "Read next" - the next ARTICLES to keep reading (articles only, never mixed
/// content). Prefers the same collection, then personalised picks, then catalog.
List<ReadArticle> readNextArticles(ReadArticle article, {int limit = 4}) {
  final seen = <String>{article.id};
  final out = <ReadArticle>[];
  void add(Iterable<ReadArticle> arts) {
    for (final a in arts) {
      if (out.length >= limit) return;
      if (seen.add(a.id)) out.add(a);
    }
  }

  add(kReadArticles.where((a) => a.collection == article.collection));
  add(forYou());
  add(kReadArticles);
  return out.take(limit).toList();
}

// =============================================================================
//  ReadingStore - saved, reading progress, and reader preferences.
// =============================================================================
enum ReadMode { light, sepia, dark }

class ReadingStore extends ChangeNotifier {
  ReadingStore._();
  static final ReadingStore instance = ReadingStore._();

  final Set<String> _saved = {'leap4', 'matrescence'};
  final Map<String, double> _progress = {'sleepcycles': 0.35, 'solids': 0.65};
  double _fontScale = 1.0;
  ReadMode _mode = ReadMode.light;

  bool isSaved(String id) => _saved.contains(id);
  void toggleSave(String id) {
    _saved.contains(id) ? _saved.remove(id) : _saved.add(id);
    notifyListeners();
  }

  List<ReadArticle> get saved => _saved.map(readArticleById).toList();

  double progressOf(String id) => _progress[id] ?? 0;
  void setProgress(String id, double p) {
    final v = p.clamp(0.0, 1.0);
    // never let progress go backwards on a re-read
    if (v > (_progress[id] ?? 0)) {
      _progress[id] = v;
      notifyListeners();
    }
  }

  bool isCompleted(String id) => (_progress[id] ?? 0) >= 0.95;
  bool isInProgress(String id) {
    final p = _progress[id] ?? 0;
    return p > 0.02 && p < 0.95;
  }

  /// Unfinished reads, most-progressed first (Continue Reading).
  List<ReadArticle> get continueReading {
    final ids = _progress.entries.where((e) => e.value > 0.02 && e.value < 0.95).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ids.map((e) => readArticleById(e.key)).toList();
  }

  double collectionProgress(ReadCollection c) {
    if (c.articleIds.isEmpty) return 0;
    final done = c.articleIds.where(isCompleted).length;
    return done / c.articleIds.length;
  }

  double get fontScale => _fontScale;
  void setFontScale(double v) {
    _fontScale = v.clamp(0.85, 1.35);
    notifyListeners();
  }

  ReadMode get mode => _mode;
  void setMode(ReadMode m) {
    _mode = m;
    notifyListeners();
  }
}
