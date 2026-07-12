// =============================================================================
//  What Changed? — concern library (parenting · S22a v2)
// -----------------------------------------------------------------------------
//  The data behind the "What Changed?" guided diagnostic. Each concern is a
//  self-contained mini-flow: a short quote the parent recognises, its own set
//  of gentle questions (every concern asks DIFFERENT questions), and a likely-
//  cause result with a few things to try tonight. Parents search or pick from
//  "Most common", walk the questions, and land on a warm, non-clinical starting
//  point (never a diagnosis — the screen keeps the doctor disclaimer).
//
//  `{baby}` in any string is replaced with the child's name at render time.
//  Add new concerns here; the hub search + grouping pick them up automatically.
// =============================================================================

import 'package:flutter/material.dart';

/// One question inside a concern's flow.
class WcQuestion {
  const WcQuestion(this.category, this.icon, this.prompt, this.options);

  /// Short chip label shown on the journey stepper (e.g. 'Sleep', 'Diet').
  final String category;
  final IconData icon;

  /// The question. May contain `{baby}`.
  final String prompt;

  /// 2–4 answer options.
  final List<String> options;
}

/// The likely-cause result a flow lands on.
class WcResult {
  const WcResult({required this.cause, required this.explanation, required this.todos});

  /// Headline cause, e.g. 'The 4-month sleep regression'.
  final String cause;

  /// One or two warm sentences. May contain `{baby}`.
  final String explanation;

  /// 2–3 gentle "what to do" steps. May contain `{baby}`.
  final List<String> todos;
}

/// A single searchable concern on the What Changed? hub.
class WcConcern {
  const WcConcern({
    required this.id,
    required this.category,
    required this.icon,
    required this.label,
    required this.quote,
    required this.questions,
    required this.result,
    this.common = false,
    this.keywords = const [],
  });

  final String id;

  /// Grouping / area, e.g. 'Sleep'.
  final String category;
  final IconData icon;

  /// Short label for the list + search, e.g. 'Waking every 2 hours'.
  final String label;

  /// The full concern sentence shown at the top of the flow. May contain `{baby}`.
  final String quote;

  final List<WcQuestion> questions;
  final WcResult result;

  /// Surfaced under "Most common" on the hub.
  final bool common;

  /// Extra search terms not already in the label/quote/category.
  final List<String> keywords;
}

// -----------------------------------------------------------------------------
//  Reused question icons
// -----------------------------------------------------------------------------
const _iSleep = Icons.bedtime_outlined;
const _iDiet = Icons.restaurant_outlined;
const _iHome = Icons.home_outlined;
const _iIll = Icons.medical_services_outlined;
const _iMood = Icons.favorite_border;
const _iTummy = Icons.bubble_chart_outlined;
const _iBody = Icons.child_care_outlined;
const _iTime = Icons.schedule_outlined;

// =============================================================================
//  The library. Grouped by area for readability; order here = order on the hub.
// =============================================================================
const List<WcConcern> kWcConcerns = [
  // --------------------------------------------------------------- Sleep -----
  WcConcern(
    id: 'wake_2h',
    category: 'Sleep',
    icon: _iSleep,
    label: 'Waking every 2 hours at night',
    quote: '"{baby} suddenly wakes every 2 hours at night."',
    common: true,
    keywords: ['night waking', 'regression', 'up all night'],
    questions: [
      WcQuestion('Diet', _iDiet, 'Any recent change to feeds or new foods?',
          ['Yes — a new food or formula', 'Weaning or dropping a feed', "No, feeding's the same"]),
      WcQuestion('Sleep', _iSleep, 'Has the sleep routine or schedule shifted?',
          ['Yes — travel or a new routine', 'Naps got shorter or longer', "No, the routine's the same"]),
      WcQuestion('Home', _iHome, 'Anything different at home lately?',
          ['Yes — travel, guests, or a move', 'A room or temperature change', "No, nothing's changed"]),
      WcQuestion('Illness', _iIll, 'Signs of a cold, fever, or teething?',
          ['Yes — a runny nose or cough', 'Drooling, hands in mouth', 'No — physically well']),
      WcQuestion('Mood', _iMood, 'More clingy or seeking you out in the day?',
          ['Yes — much clingier', 'A bit, on and off', "No, usual self"]),
    ],
    result: WcResult(
      cause: 'A developmental sleep regression',
      explanation:
          'Sleep and development shifted together with no physical cause — the classic leap pattern, where a new skill briefly scrambles nights.',
      todos: [
        'Hold a steady wind-down; put {baby} down drowsy but awake.',
        'Rehearse the new skill in the daytime so nights feel less busy.',
        'Keep responses calm and boring at night — presence over stimulation.',
      ],
    ),
  ),
  WcConcern(
    id: 'early_waking',
    category: 'Sleep',
    icon: _iSleep,
    label: 'Waking very early (before 5am)',
    quote: '"{baby} has started waking up before 5 in the morning."',
    common: true,
    keywords: ['dawn', 'early rise', 'too early'],
    questions: [
      WcQuestion('Light', _iHome, 'Is the room bright or noisy at dawn?',
          ['Yes — light gets in early', 'Some street or house noise', 'No — dark and quiet']),
      WcQuestion('Bedtime', _iTime, 'How is bedtime lately?',
          ['Later than usual', 'Earlier than usual', 'About the same']),
      WcQuestion('Naps', _iSleep, 'How is the last nap of the day?',
          ['Long or late', 'Short or skipped', 'Unchanged']),
    ],
    result: WcResult(
      cause: 'An early-morning schedule tangle',
      explanation:
          'Early waking is usually light, an over- or under-tired bedtime, or a last nap that lands wrong — rarely anything to worry about.',
      todos: [
        'Black the room out fully and mask dawn noise.',
        'Nudge bedtime 15–20 minutes earlier for a few nights.',
        'Treat pre-6am as night: calm, dim, no bright play.',
      ],
    ),
  ),
  WcConcern(
    id: 'fighting_naps',
    category: 'Sleep',
    icon: _iSleep,
    label: 'Suddenly fighting naps',
    quote: '"{baby} is suddenly fighting every nap."',
    keywords: ['nap strike', 'wont nap', 'skipping naps'],
    questions: [
      WcQuestion('Timing', _iTime, 'How long is {baby} awake before naps?',
          ['Feels too long', 'Feels too short', 'Same as always']),
      WcQuestion('Age', _iBody, 'Any new milestone in progress?',
          ['Yes — rolling, crawling, or standing', 'Lots of new babbling', 'Nothing new']),
      WcQuestion('Mood', _iMood, 'Is it a fight, or just not tired?',
          ['Overtired and cross', 'Wide awake and happy', 'Hard to tell']),
    ],
    result: WcResult(
      cause: 'An awake-window that has outgrown the old schedule',
      explanation:
          "As babies grow they can stay up longer — the old nap times can arrive too early (wide awake) or too late (overtired). A skill in progress makes it noisier.",
      todos: [
        'Shift the nap 15–30 minutes and watch the tired cues.',
        'Give a short, consistent nap wind-down every time.',
        'If a nap truly refuses, bring bedtime a little earlier.',
      ],
    ),
  ),
  WcConcern(
    id: 'short_naps',
    category: 'Sleep',
    icon: _iSleep,
    label: 'Naps have got very short',
    quote: '"{baby}\'s naps have shrunk to 30–40 minutes."',
    keywords: ['catnap', 'one sleep cycle', 'short sleep'],
    questions: [
      WcQuestion('Waking', _iSleep, 'How does {baby} wake from the short nap?',
          ['Crying, clearly still tired', 'Happy and rested', 'Grizzly but okay']),
      WcQuestion('Setting', _iHome, 'Where do naps happen?',
          ['Bright or busy room', 'Motion — pram or car', 'Dark, calm cot']),
      WcQuestion('Timing', _iTime, 'Is the nap well-timed?',
          ['Often overtired going in', 'Often not tired going in', 'Usually just right']),
    ],
    result: WcResult(
      cause: 'The one-sleep-cycle catnap',
      explanation:
          'Around this age babies surface between sleep cycles (~40 min) and can\'t always rejoin. Light, timing, or being overtired makes it stick.',
      todos: [
        'Darken the room and keep it boring and cool.',
        'Try a quiet presence at the ~30-minute mark to bridge the cycle.',
        'Protect the awake-window so {baby} isn\'t overtired going down.',
      ],
    ),
  ),
  WcConcern(
    id: 'new_night_wakings',
    category: 'Sleep',
    icon: _iSleep,
    label: 'Waking at night after sleeping through',
    quote: '"{baby} slept through for months and is now waking again."',
    common: true,
    keywords: ['regression', 'used to sleep', 'started waking'],
    questions: [
      WcQuestion('Skill', _iBody, 'Any new physical skill right now?',
          ['Yes — rolling, sitting, pulling up', 'Lots of new sounds/words', 'Nothing obvious']),
      WcQuestion('Teeth', _iIll, 'Any teething signs?',
          ['Drooling and chewing', 'Red, swollen gums', 'No']),
      WcQuestion('Change', _iHome, 'Any recent change at home?',
          ['Travel, guests, or a move', 'Started daycare/new carer', "No, nothing's changed"]),
    ],
    result: WcResult(
      cause: 'A leap or transition catching up with nights',
      explanation:
          'A new skill, teething, or a change in routine can briefly reopen night wakings even in a great sleeper. It usually settles as the new skill lands.',
      todos: [
        'Keep the bedtime routine identical and predictable.',
        'Respond calmly and briefly; avoid starting new sleep habits.',
        'Practise the new skill lots in daylight hours.',
      ],
    ),
  ),
  WcConcern(
    id: 'only_sleeps_held',
    category: 'Sleep',
    icon: _iSleep,
    label: 'Will only sleep in my arms',
    quote: '"{baby} will only sleep on me and wakes the moment I put him down."',
    keywords: ['contact nap', 'held', 'wont be put down'],
    questions: [
      WcQuestion('Age', _iBody, 'Any separation-awareness lately?',
          ['Yes — upset when I leave the room', 'A bit clingier than before', 'Not really']),
      WcQuestion('State', _iSleep, 'How deeply asleep before the put-down?',
          ['I move fast, still light', 'I wait, usually deep', 'Varies']),
      WcQuestion('Comfort', _iIll, 'Any sign of discomfort lying flat?',
          ['Reflux-y or gassy', 'Congested', 'No']),
    ],
    result: WcResult(
      cause: 'Normal closeness-seeking (and sometimes reflux)',
      explanation:
          'Wanting contact is developmentally normal, especially in separation phases. If lying flat seems uncomfortable, gassiness or reflux can add to it.',
      todos: [
        'Wait for deeper sleep (limp arms) before the transfer.',
        'Warm the cot surface and keep a hand on {baby} after the put-down.',
        'If flat-lying looks uncomfortable, hold upright 15–20 min after feeds.',
      ],
    ),
  ),

  // ------------------------------------------------------------- Feeding -----
  WcConcern(
    id: 'refusing_feeds',
    category: 'Feeding',
    icon: _iDiet,
    label: 'Suddenly refusing milk feeds',
    quote: '"{baby} is suddenly refusing milk."',
    common: true,
    keywords: ['nursing strike', 'bottle refusal', 'wont drink'],
    questions: [
      WcQuestion('Mouth', _iIll, 'Any mouth or teething signs?',
          ['Drooling, chewing, sore gums', 'White patches in the mouth', 'No']),
      WcQuestion('Nose', _iIll, 'Is {baby} congested?',
          ['Yes — blocked or runny nose', 'A little', 'No']),
      WcQuestion('Distraction', _iHome, 'More distracted while feeding?',
          ['Yes — looks around constantly', 'Sometimes', 'No']),
    ],
    result: WcResult(
      cause: 'A short feeding strike, not self-weaning',
      explanation:
          'Sudden refusal is usually teething, a blocked nose, or distraction — rarely a real wean. Babies this age almost never choose to stop.',
      todos: [
        'Offer in a calm, dim, boring room with fewer distractions.',
        'Try feeds when sleepy (on waking or drowsy).',
        'Clear the nose before feeds; watch nappies for enough wet ones.',
      ],
    ),
  ),
  WcConcern(
    id: 'eating_less_solids',
    category: 'Feeding',
    icon: _iDiet,
    label: 'Eating much less solid food',
    quote: '"{baby} is eating far less than he used to."',
    common: true,
    keywords: ['appetite', 'off food', 'picky'],
    questions: [
      WcQuestion('Growth', _iBody, 'Has {baby} had a growth spurt recently?',
          ['Yes — just shot up', 'Not sure', 'No']),
      WcQuestion('Teeth', _iIll, 'Any teething or being unwell?',
          ['Teething signs', 'A cold or fever', 'Seems well']),
      WcQuestion('Milk', _iDiet, 'How much milk is {baby} taking?',
          ['Lots of milk still', 'About normal', 'Less than usual']),
    ],
    result: WcResult(
      cause: 'A normal appetite dip',
      explanation:
          "Appetite naturally ebbs — after a growth spurt, during teething, or as growth slows in the second year. As long as {baby} is playful and having wet nappies, it's usually fine.",
      todos: [
        'Offer without pressure; let {baby} decide how much.',
        'Keep meals short, calm, and screen-free.',
        'Trust appetite over the day/week, not one meal.',
      ],
    ),
  ),
  WcConcern(
    id: 'refusing_solids',
    category: 'Feeding',
    icon: _iDiet,
    label: 'Clamping mouth shut at meals',
    quote: '"{baby} turns away and clamps his mouth shut at mealtimes."',
    keywords: ['refuses solids', 'spitting out', 'wont eat'],
    questions: [
      WcQuestion('Texture', _iDiet, 'Any change in food texture or type?',
          ['Yes — moved to lumps/finger foods', 'New flavours', 'Same as before']),
      WcQuestion('Control', _iMood, 'Does {baby} want to self-feed?',
          ['Yes — grabs the spoon', 'Sometimes', 'Not really']),
      WcQuestion('Setting', _iHome, 'How are mealtimes going?',
          ['Rushed or stressful', 'Lots of pressure to finish', 'Calm and short']),
    ],
    result: WcResult(
      cause: 'A bid for control (and maybe texture)',
      explanation:
          'Refusing is often about autonomy or a new texture that feels strange — not dislike of food. Pushing tends to make it worse.',
      todos: [
        'Offer a loaded spoon and let {baby} take it, or hand over finger foods.',
        'Serve tiny portions; refill only if wanted.',
        'Eat together and stay relaxed — model, don\'t pressure.',
      ],
    ),
  ),
  WcConcern(
    id: 'cluster_feeding',
    category: 'Feeding',
    icon: _iDiet,
    label: 'Wants to feed constantly',
    quote: '"{baby} wants to feed all the time, back to back."',
    keywords: ['cluster feed', 'always hungry', 'constant nursing'],
    questions: [
      WcQuestion('Time', _iTime, 'When is the constant feeding?',
          ['Mostly evenings', 'All day', 'Around naps/night']),
      WcQuestion('Growth', _iBody, 'Any signs of a growth spurt?',
          ['Yes — extra sleepy and hungry', 'Maybe', 'No']),
      WcQuestion('Comfort', _iMood, 'Does feeding seem for comfort?',
          ['Yes — soothing more than hunger', 'Hard to tell', 'Seems truly hungry']),
    ],
    result: WcResult(
      cause: 'A growth spurt or evening cluster feed',
      explanation:
          'Frequent feeding — especially in the evening — is how babies boost supply and settle themselves. It spikes around growth spurts and passes in days.',
      todos: [
        'Follow the lead and feed on cue for a few days.',
        'Set up a comfy feeding spot with water and a snack for you.',
        'Offer comfort other ways too — carrying, rocking, a calm room.',
      ],
    ),
  ),
  WcConcern(
    id: 'spitting_up',
    category: 'Feeding',
    icon: _iDiet,
    label: 'Spitting up more than usual',
    quote: '"{baby} is spitting up more than he used to."',
    keywords: ['reflux', 'posseting', 'vomiting milk'],
    questions: [
      WcQuestion('Amount', _iDiet, 'How much is coming up?',
          ['Small, effortless posset', 'Larger, more forceful', 'Varies']),
      WcQuestion('Mood', _iMood, 'Is {baby} bothered by it?',
          ['Happy — a "happy spitter"', 'Fussy and arching', 'Sometimes upset']),
      WcQuestion('Feeds', _iTime, 'How are feeds paced?',
          ['Fast, big feeds', 'Lots of air/gulping', 'Calm and paced']),
    ],
    result: WcResult(
      cause: 'Normal reflux (posseting)',
      explanation:
          'A small immature valve means milk comes back up. If {baby} is gaining and mostly content, it\'s laundry, not illness — and it fades as he sits and stands.',
      todos: [
        'Feed calmly and burp partway through.',
        'Hold upright for 15–20 minutes after feeds.',
        'Offer slightly smaller, more frequent feeds.',
      ],
    ),
  ),

  // ------------------------------------------------------- Crying & mood -----
  WcConcern(
    id: 'extra_clingy',
    category: 'Mood',
    icon: _iMood,
    label: 'Suddenly very clingy',
    quote: '"{baby} is suddenly so clingy — he won\'t let me put him down."',
    common: true,
    keywords: ['velcro baby', 'wont be put down', 'attached'],
    questions: [
      WcQuestion('Skill', _iBody, 'Any new skill brewing?',
          ['Yes — on the edge of a milestone', 'Lots of new sounds', 'Nothing obvious']),
      WcQuestion('Change', _iHome, 'Any change in his world?',
          ['New carer, daycare, or travel', 'A busy or loud few days', "No, nothing's changed"]),
      WcQuestion('Health', _iIll, 'Any sign of being unwell or teething?',
          ['Yes — teething or a cold coming', 'Maybe', 'Seems well']),
    ],
    result: WcResult(
      cause: 'A leap in separation awareness',
      explanation:
          'Clinginess spikes right before new skills and during separation phases — {baby} is checking you\'re his safe base. It\'s a sign of secure attachment, not a step back.',
      todos: [
        'Offer closeness freely — a carrier can be a lifesaver.',
        'Play peekaboo and short come-back games to rehearse separation.',
        'Keep goodbyes short, warm, and predictable.',
      ],
    ),
  ),
  WcConcern(
    id: 'witching_hour',
    category: 'Mood',
    icon: _iMood,
    label: 'Crying a lot in the evenings',
    quote: '"{baby} falls apart and cries every evening."',
    common: true,
    keywords: ['witching hour', 'fussy evenings', 'colic'],
    questions: [
      WcQuestion('Time', _iTime, 'When does the crying peak?',
          ['Late afternoon to evening', 'Right after the last nap', 'Scattered']),
      WcQuestion('Tummy', _iTummy, 'Any tummy signs with it?',
          ['Pulling legs up, gassy', 'Nothing tummy-related', 'Not sure']),
      WcQuestion('Day', _iSleep, 'How was the day\'s sleep?',
          ['Short or skipped naps', 'Plenty of sleep', 'Average']),
    ],
    result: WcResult(
      cause: 'The evening "witching hour"',
      explanation:
          'Many babies get a fussy end-of-day burst as tiredness and stimulation pile up. It peaks around 6 weeks and eases by 3–4 months.',
      todos: [
        'Dim lights and lower noise before the usual wobble.',
        'Try a carrier walk, warm bath, or white noise.',
        'Protect daytime sleep so evenings aren\'t overtired.',
      ],
    ),
  ),
  WcConcern(
    id: 'sudden_tantrums',
    category: 'Mood',
    icon: _iMood,
    label: 'Meltdowns out of nowhere',
    quote: '"{baby} melts down over tiny things, out of nowhere."',
    keywords: ['tantrum', 'toddler', 'meltdown', 'frustration'],
    questions: [
      WcQuestion('Trigger', _iMood, 'What tends to set it off?',
          ['Being told no / limits', 'Not being understood', 'Transitions between activities']),
      WcQuestion('Basics', _iTime, 'How are sleep and food around then?',
          ['Often tired or hungry', 'Usually fine', 'Hard to tell']),
      WcQuestion('Words', _iBody, 'Can {baby} say what he wants?',
          ['Not many words yet', 'A few words', 'Talks but still melts down']),
    ],
    result: WcResult(
      cause: 'Big feelings, small vocabulary',
      explanation:
          'A toddler\'s emotions outrun their words and self-control. Meltdowns are the nervous system overflowing — normal, and not manipulation.',
      todos: [
        'Stay calm and name the feeling: "You\'re so frustrated."',
        'Keep everyone fed and rested — HALT: hungry, angry, lonely, tired.',
        'Give simple choices to hand back a little control.',
      ],
    ),
  ),
  WcConcern(
    id: 'separation_upset',
    category: 'Mood',
    icon: _iMood,
    label: 'Cries when I leave the room',
    quote: '"{baby} cries the moment I step out of the room."',
    keywords: ['separation anxiety', 'stranger', 'wont let me go'],
    questions: [
      WcQuestion('Age', _iBody, 'Roughly how old is {baby}?',
          ['Around 8–18 months', 'Older toddler', 'Younger baby']),
      WcQuestion('People', _iHome, 'Is it also with familiar people?',
          ['Yes — even with grandparents', 'Mostly with strangers', 'Only with me leaving']),
      WcQuestion('Change', _iTime, 'Any new separation lately?',
          ['Started daycare / new carer', 'More time apart', 'No change']),
    ],
    result: WcResult(
      cause: 'Separation anxiety — a developmental milestone',
      explanation:
          'Understanding that you still exist when you leave (object permanence) makes goodbyes hard. It peaks in the first 18 months and is a sign of healthy bonding.',
      todos: [
        'Practise short separations and always come back when you say.',
        'Build a quick, cheerful goodbye ritual — never sneak away.',
        'Play peekaboo and hide-and-seek to make "gone and back" fun.',
      ],
    ),
  ),

  // ------------------------------------------------------ Tummy & body -------
  WcConcern(
    id: 'not_pooped',
    category: 'Tummy',
    icon: _iTummy,
    label: "Hasn't pooped in a few days",
    quote: '"{baby} hasn\'t done a poo in a couple of days."',
    common: true,
    keywords: ['constipation', 'no poop', 'straining'],
    questions: [
      WcQuestion('Stool', _iTummy, 'When it comes, what is it like?',
          ['Hard, dry pellets', 'Soft and normal', 'Not sure yet']),
      WcQuestion('Diet', _iDiet, 'Any recent feeding change?',
          ['Started solids or cow\'s milk', 'Switched formula', 'No change']),
      WcQuestion('Comfort', _iMood, 'Is {baby} comfortable otherwise?',
          ['Straining and unsettled', 'Happy and feeding well', 'A bit uncomfortable']),
    ],
    result: WcResult(
      cause: 'A slow gut, often around a diet change',
      explanation:
          'Frequency varies hugely, and gaps are common — especially when starting solids or changing milk. Soft stools when they come usually mean all is well. Hard, pellet-like stools point to constipation.',
      todos: [
        'Offer extra water (if on solids) and fibre-rich fruit/veg.',
        'Try gentle tummy massage and bicycle legs.',
        'See a doctor if hard stools, blood, a hard belly, or a very unsettled baby.',
      ],
    ),
  ),
  WcConcern(
    id: 'loose_stools',
    category: 'Tummy',
    icon: _iTummy,
    label: 'Runnier, more frequent poops',
    quote: '"{baby}\'s poos have suddenly gone runny and frequent."',
    keywords: ['diarrhoea', 'loose stool', 'upset tummy'],
    questions: [
      WcQuestion('Diet', _iDiet, 'Any new food or drink?',
          ['Yes — a new food', 'More fruit/juice than usual', 'No change']),
      WcQuestion('Teeth', _iIll, 'Any teething or illness signs?',
          ['Teething', 'Cold or fever', 'Seems well']),
      WcQuestion('Hydration', _iBody, 'Are wet nappies still coming?',
          ['Yes — plenty', 'Fewer than usual', 'Not sure']),
    ],
    result: WcResult(
      cause: 'A passing tummy upset',
      explanation:
          'Looser stools often follow a new food, extra fruit, teething, or a mild bug. The main thing to watch is hydration — keep the wet nappies coming.',
      todos: [
        'Keep milk feeds going; offer small, frequent sips of water if on solids.',
        'Ease off very sugary fruit/juice for a couple of days.',
        'See a doctor for blood in stool, few wet nappies, or a floppy, unwell baby.',
      ],
    ),
  ),
  WcConcern(
    id: 'gassy',
    category: 'Tummy',
    icon: _iTummy,
    label: 'Gassy and pulling legs up',
    quote: '"{baby} is gassy, pulling his legs up and squirming."',
    keywords: ['wind', 'gas', 'trapped wind', 'colic'],
    questions: [
      WcQuestion('Feeds', _iDiet, 'How do feeds go?',
          ['Fast, gulping lots of air', 'Frequent small feeds', 'Calm and paced']),
      WcQuestion('Timing', _iTime, 'When is it worst?',
          ['Evenings', 'After feeds', 'Any time']),
      WcQuestion('Relief', _iBody, 'Does anything help?',
          ['Passing wind or a poo helps', 'Being held upright', 'Nothing much']),
    ],
    result: WcResult(
      cause: 'Trapped wind',
      explanation:
          'Immature tummies and gulped air make for gassy, squirmy spells — worst in the evenings. It looks uncomfortable but is rarely a problem, and it eases with time.',
      todos: [
        'Burp partway through and after feeds; pace the feed calmly.',
        'Try bicycle legs and gentle clockwise tummy massage.',
        'Hold upright for a while after feeds.',
      ],
    ),
  ),

  // -------------------------------------------------- Teething & illness -----
  WcConcern(
    id: 'drooling_chewing',
    category: 'Teething',
    icon: _iIll,
    label: 'Drooling and chewing everything',
    quote: '"{baby} is drooling loads and chewing on everything."',
    common: true,
    keywords: ['teething', 'biting', 'gums', 'dribble'],
    questions: [
      WcQuestion('Gums', _iIll, 'How do the gums look?',
          ['Red, swollen, or a white tip', 'A bit puffy', 'Look normal']),
      WcQuestion('Mood', _iMood, 'Any change in mood or sleep?',
          ['Fussy, disrupted sleep', 'A little off', 'Happy as usual']),
      WcQuestion('Fever', _iBody, 'Any temperature?',
          ['Slightly warm', 'Clearly feverish', 'No']),
    ],
    result: WcResult(
      cause: 'Teething',
      explanation:
          'Drooling, chewing, and sore gums are classic teething. It can cause mild fussiness and a slightly raised temperature — but a real fever means something else to check.',
      todos: [
        'Offer a chilled (not frozen) teether or clean cold flannel.',
        'Wipe drool to protect the chin; a bib helps.',
        'See a doctor for a true fever, since teething alone shouldn\'t cause one.',
      ],
    ),
  ),
  WcConcern(
    id: 'low_fever',
    category: 'Illness',
    icon: _iIll,
    label: 'Warm / low-grade fever',
    quote: '"{baby} feels warm and a bit off today."',
    common: true,
    keywords: ['temperature', 'fever', 'unwell', 'hot'],
    questions: [
      WcQuestion('Temp', _iBody, 'What does the thermometer say?',
          ['Under 38°C', '38–39°C', 'Over 39°C / very hot']),
      WcQuestion('Age', _iTime, 'Roughly how old is {baby}?',
          ['Under 3 months', '3–6 months', 'Over 6 months']),
      WcQuestion('Signs', _iIll, 'Any other symptoms?',
          ['Just a bit warm and clingy', 'Cold, cough, or ear-tugging', 'Rash, drowsy, or refusing feeds']),
    ],
    result: WcResult(
      cause: 'A likely mild viral illness — with clear doctor triggers',
      explanation:
          'Most low fevers are the body fighting a mild virus. But a baby under 3 months, a temperature over 39°C, or worrying signs always need a doctor — don\'t wait.',
      todos: [
        'Offer extra fluids and dress {baby} lightly.',
        'Watch wet nappies, alertness, and breathing.',
        'Call a doctor now if under 3 months, over 39°C, a rash, drowsiness, or refusing feeds.',
      ],
    ),
  ),
  WcConcern(
    id: 'runny_nose',
    category: 'Illness',
    icon: _iIll,
    label: 'Runny nose and congestion',
    quote: '"{baby} has a runny nose and sounds a bit blocked."',
    keywords: ['cold', 'snot', 'stuffy', 'congestion'],
    questions: [
      WcQuestion('Feeding', _iDiet, 'Is the blocked nose affecting feeds?',
          ['Yes — struggling to feed', 'A little', 'Feeding fine']),
      WcQuestion('Breathing', _iBody, 'How is breathing otherwise?',
          ['Calm, just snuffly', 'Fast or working hard', 'Wheezy']),
      WcQuestion('Fever', _iIll, 'Any fever with it?',
          ['No', 'Mild', 'High']),
    ],
    result: WcResult(
      cause: 'A common cold',
      explanation:
          'Babies catch lots of colds as their immune systems learn — a snuffly nose and mild cough are normal and pass in a week or so. Breathing that looks hard is the thing to act on.',
      todos: [
        'Use saline drops and a nasal aspirator before feeds and sleep.',
        'Keep feeds up and offer them little and often.',
        'See a doctor for fast/laboured breathing, wheeze, or poor feeding.',
      ],
    ),
  ),
  WcConcern(
    id: 'pulling_ears',
    category: 'Illness',
    icon: _iIll,
    label: 'Tugging at his ears',
    quote: '"{baby} keeps tugging and rubbing at his ears."',
    keywords: ['ear', 'ear infection', 'ear pulling'],
    questions: [
      WcQuestion('Signs', _iIll, 'Any illness signs with it?',
          ['Fever or a recent cold', 'Fluid from the ear', 'None — seems well']),
      WcQuestion('Mood', _iMood, 'Is {baby} in pain?',
          ['Very unsettled, worse lying down', 'A little grizzly', 'Happy and playing']),
      WcQuestion('Habit', _iBody, 'When does the tugging happen?',
          ['With crying / distress', 'When tired or teething', 'Randomly, exploring']),
    ],
    result: WcResult(
      cause: 'Often just exploring — sometimes an ear infection',
      explanation:
          'Happy, well babies often discover and fiddle with their ears, or tug when tired or teething. But ear-pulling with fever, pain, or fluid can mean an infection that needs checking.',
      todos: [
        'If {baby} is content and well, it\'s likely harmless exploring.',
        'Watch for fever, distress worse when lying down, or ear discharge.',
        'See a doctor if any of those appear — ears need proper examination.',
      ],
    ),
  ),

  // ------------------------------------------------------------- Skin --------
  WcConcern(
    id: 'new_rash',
    category: 'Skin',
    icon: _iBody,
    label: 'A new rash appeared',
    quote: '"{baby} has a new rash I haven\'t seen before."',
    common: true,
    keywords: ['rash', 'spots', 'red', 'heat rash'],
    questions: [
      WcQuestion('Look', _iBody, 'What does it look like?',
          ['Small red bumps in warm areas', 'Dry, itchy patches', 'Spots with a fever']),
      WcQuestion('Blanch', _iIll, 'Does it fade when pressed (glass test)?',
          ['Yes — it fades', 'No — it stays', 'Not sure']),
      WcQuestion('Mood', _iMood, 'Is {baby} otherwise well?',
          ['Happy and feeding', 'A bit off', 'Unwell / feverish']),
    ],
    result: WcResult(
      cause: 'Most likely a harmless skin rash — with one urgent exception',
      explanation:
          'Many baby rashes (heat rash, mild eczema, dribble rash) are harmless. The one that can\'t wait: a rash that does NOT fade when pressed, especially with fever or a drowsy baby.',
      todos: [
        'Do the glass test — a non-fading rash needs emergency care now.',
        'For a harmless rash, keep skin cool, dry, and lightly dressed.',
        'See a doctor if it spreads fast, blisters, or comes with fever.',
      ],
    ),
  ),
  WcConcern(
    id: 'dry_patches',
    category: 'Skin',
    icon: _iBody,
    label: 'Dry, rough skin patches',
    quote: '"{baby} has dry, rough patches on his skin."',
    keywords: ['eczema', 'dry skin', 'flaky'],
    questions: [
      WcQuestion('Where', _iBody, 'Where are the patches?',
          ['Cheeks, elbows, or knees', 'Scalp — flaky', 'All over / general']),
      WcQuestion('Itch', _iMood, 'Do they seem itchy?',
          ['Yes — scratching or rubbing', 'A little', 'Not bothered']),
      WcQuestion('Triggers', _iHome, 'Anything new touching the skin?',
          ['New soap/detergent/lotion', 'Very hot baths', 'No change']),
    ],
    result: WcResult(
      cause: 'Dry skin or mild eczema',
      explanation:
          'Baby skin is thin and dries easily; itchy patches on cheeks and joints are often mild eczema. Flakes on the scalp are usually cradle cap — both are manageable, not dangerous.',
      todos: [
        'Moisturise generously with a fragrance-free emollient after short, warm (not hot) baths.',
        'Switch to gentle, fragrance-free soap and detergent.',
        'See a doctor if it\'s weepy, spreading, or clearly bothering {baby}.',
      ],
    ),
  ),
  WcConcern(
    id: 'nappy_rash',
    category: 'Skin',
    icon: _iBody,
    label: 'Sore, red nappy area',
    quote: '"{baby}\'s nappy area is red and sore."',
    keywords: ['nappy rash', 'diaper rash', 'bottom'],
    questions: [
      WcQuestion('Look', _iBody, 'What does it look like?',
          ['Red and sore over the area', 'Bright red with little spots at edges', 'Broken or bleeding skin']),
      WcQuestion('Cause', _iDiet, 'Anything that might have set it off?',
          ['Loose stools / more poos', 'Longer between changes', 'New wipes or food']),
      WcQuestion('Time', _iTime, 'How long has it been there?',
          ['A day or two', 'Several days', 'Over a week']),
    ],
    result: WcResult(
      cause: 'Nappy rash',
      explanation:
          'Warmth, moisture, and friction irritate the skin. Most nappy rash clears with air and barrier cream; the spotty kind at the edges can be a yeast (thrush) rash that needs a different cream.',
      todos: [
        'Change often, clean gently, and let the skin air-dry.',
        'Apply a thick barrier cream at each change.',
        'See a doctor if it\'s not better in a few days, or looks spotty/broken.',
      ],
    ),
  ),

  // --------------------------------------- Development & behaviour -----------
  WcConcern(
    id: 'gone_quiet',
    category: 'Development',
    icon: _iBody,
    label: 'Babbling less than before',
    quote: '"{baby} has gone quieter and is babbling less."',
    keywords: ['speech', 'babbling', 'quiet', 'sounds'],
    questions: [
      WcQuestion('Focus', _iBody, 'Is a physical skill taking over?',
          ['Yes — busy learning to move', 'Lots of staring/observing', 'Nothing obvious']),
      WcQuestion('Ears', _iIll, 'Any recent ear/cold trouble?',
          ['A cold or ear issue', 'Maybe', 'No']),
      WcQuestion('Response', _iMood, 'Does {baby} still respond to you?',
          ['Yes — turns, smiles, engages', 'Sometimes', 'Less than before']),
    ],
    result: WcResult(
      cause: 'A focus shift — one skill at a time',
      explanation:
          'Babies often pour energy into one area at a time, so talking can go quiet while movement races ahead. As long as {baby} still engages and responds, it\'s usually a phase.',
      todos: [
        'Narrate your day and leave pauses for {baby} to "reply".',
        'Read and sing together daily — repetition builds sounds.',
        'Mention it at the next check-up if he stops responding to sounds/name.',
      ],
    ),
  ),
  WcConcern(
    id: 'shy_new_people',
    category: 'Development',
    icon: _iMood,
    label: 'Suddenly shy around new people',
    quote: '"{baby} has suddenly become shy and upset around new people."',
    keywords: ['stranger anxiety', 'shy', 'clingy with strangers'],
    questions: [
      WcQuestion('Age', _iTime, 'Roughly how old is {baby}?',
          ['Around 6–12 months', 'Older toddler', 'Younger baby']),
      WcQuestion('Who', _iHome, 'Who does it happen with?',
          ['New or less-familiar people', 'Even some relatives', 'Anyone approaching fast']),
      WcQuestion('Recover', _iMood, 'Does {baby} warm up with time?',
          ['Yes — from my arms', 'Slowly', 'Stays upset']),
    ],
    result: WcResult(
      cause: 'Stranger anxiety — a normal milestone',
      explanation:
          'Around 6–12 months babies start telling "familiar" from "new" and prefer their safe people. Wariness of strangers is a sign of healthy attachment, not rudeness.',
      todos: [
        'Let {baby} approach on his own terms from your arms.',
        'Ask new people to go slow — no sudden scooping up.',
        'Stay warm and unhurried; he takes his cue from you.',
      ],
    ),
  ),
  WcConcern(
    id: 'head_banging',
    category: 'Behaviour',
    icon: _iBody,
    label: 'Head-banging or rocking',
    quote: '"{baby} bangs his head or rocks — is that normal?"',
    keywords: ['head banging', 'rocking', 'self-soothing', 'rhythmic'],
    questions: [
      WcQuestion('When', _iTime, 'When does it happen?',
          ['Falling asleep or tired', 'When frustrated', 'Randomly through the day']),
      WcQuestion('Mood', _iMood, 'How does {baby} seem doing it?',
          ['Calm, almost soothing himself', 'Upset / frustrated', 'Hard to tell']),
      WcQuestion('Development', _iBody, 'Otherwise developing and engaging well?',
          ['Yes — meeting milestones', 'Some concerns', 'Not sure']),
    ],
    result: WcResult(
      cause: 'Usually normal rhythmic self-soothing',
      explanation:
          'Rhythmic rocking or gentle head-banging at sleep or when upset is a common way toddlers self-regulate, and most grow out of it. It\'s worth a mention only if paired with developmental concerns.',
      todos: [
        'Keep them safe — pad cot bumpers-free but check hard edges.',
        'Add calm rhythm elsewhere: rocking, music, a bedtime routine.',
        'Flag it at a check-up if it\'s intense, injuring, or with other worries.',
      ],
    ),
  ),
  WcConcern(
    id: 'biting_hitting',
    category: 'Behaviour',
    icon: _iMood,
    label: 'Started biting or hitting',
    quote: '"{baby} has started biting or hitting."',
    keywords: ['biting', 'hitting', 'aggression', 'toddler'],
    questions: [
      WcQuestion('When', _iTime, 'When does it happen?',
          ['When frustrated or told no', 'When overtired/overwhelmed', 'While teething / mouthing']),
      WcQuestion('Words', _iBody, 'Can {baby} express himself in words?',
          ['Very few words', 'Some words', 'Talks but still lashes out']),
      WcQuestion('Reaction', _iMood, 'What tends to follow?',
          ['Big reactions from us', 'Attention / a laugh', 'Calm redirection']),
    ],
    result: WcResult(
      cause: 'Communication, not aggression',
      explanation:
          'Toddlers bite and hit when big feelings outrun their words and impulse control. It\'s developmentally normal and fades as language grows — the response shapes how fast.',
      todos: [
        'Stay calm and low-key: "No biting. Biting hurts." Then redirect.',
        'Name the feeling and offer the word: "You wanted the toy."',
        'Head off triggers — keep {baby} fed, rested, and not overwhelmed.',
      ],
    ),
  ),
];

// -----------------------------------------------------------------------------
//  Lookups + search
// -----------------------------------------------------------------------------
WcConcern? wcById(String id) {
  for (final c in kWcConcerns) {
    if (c.id == id) return c;
  }
  return null;
}

/// Concerns flagged as most common, for the hub's default view.
List<WcConcern> get wcCommon => kWcConcerns.where((c) => c.common).toList();

/// Distinct categories, in first-seen order.
List<String> get wcCategories {
  final seen = <String>[];
  for (final c in kWcConcerns) {
    if (!seen.contains(c.category)) seen.add(c.category);
  }
  return seen;
}

/// Simple case-insensitive search across label, category, quote, and keywords.
List<WcConcern> wcSearch(String query) {
  final t = query.trim().toLowerCase();
  if (t.isEmpty) return const [];
  return kWcConcerns.where((c) {
    if (c.label.toLowerCase().contains(t)) return true;
    if (c.category.toLowerCase().contains(t)) return true;
    if (c.quote.toLowerCase().contains(t)) return true;
    for (final k in c.keywords) {
      if (k.toLowerCase().contains(t)) return true;
    }
    return false;
  }).toList();
}
