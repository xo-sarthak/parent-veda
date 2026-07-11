// =============================================================================
//  Father Read slots - "Read recommendations" tailored for the dad
// -----------------------------------------------------------------------------
//  The mother's daily reads come from kReadItems (read_next_data.dart). These
//  are the FATHER slots for the same Read-recommendations layer: week-aware
//  reads written for the dad - about her, the baby, and how to support - so the
//  Father Daily "Daily read" card surfaces real, relevant content instead of a
//  placeholder. Re-voiced from the mother set (third-person about her) plus a
//  few dad-specific pieces. English only, matching the Father screen.
//
//  Mirrors the mother "Learn V2" reader: each item can carry whyThisMatters +
//  researchSimplified (+ optional myth/fact) shown as styled blocks in the
//  father Slate reader. Types span article / research / book so the Reads tab
//  can group them as Articles · Research Summaries · Book Summaries.
// =============================================================================

import '../../models/read_item.dart';

const List<ReadItem> kFatherReadItems = [
  ReadItem(
    id: 'f_baby_hears',
    title: 'What Your Baby Can Hear at 20 Weeks',
    type: ReadType.article,
    weekStart: 18,
    weekEnd: 24,
    priority: 'high',
    reason: 'Your voice carries especially well now - here is why reading aloud matters.',
    readingTime: '3 min',
    category: 'Bonding',
    emoji: '👂',
    body:
        'Around now the tiny bones of your baby\'s inner ear finish forming, and sound begins to reach them. Your voice - lower and slower than hers - carries especially well through the body.\n\n'
        'Reading a few lines aloud each day is not sentimental; it is how your baby starts to know you before they ever see you. The rhythm matters more than the words.\n\n'
        'A minute is plenty. Pick a short story, sit close to her bump, and let your voice rise and fall.',
    whyThisMatters:
        'Your baby learning your voice now is not a nice-to-have - it lays the first thread of attachment. Newborns turn toward voices they heard in the womb, and a father\'s lower pitch is one of the easiest for them to pick out. The minutes you spend reading aloud quietly build a recognition that pays off the day they are born.',
    researchSimplified:
        'Newborns calm to voices and rhymes they heard repeatedly before birth, and can tell their parents\' voices apart within days. Low-frequency sound travels through tissue better than high sound, so your voice reaches the womb clearly. In short: repetition plus your natural pitch equals a baby who already knows you.',
    myth: 'The baby cannot really hear me through the bump yet.',
    fact:
        'By around 20 weeks the inner ear is working and low sounds - like your voice - reach your baby clearly.',
  ),
  ReadItem(
    id: 'f_halfway',
    title: "She's Halfway - What's Changing for Her",
    type: ReadType.article,
    weekStart: 18,
    weekEnd: 22,
    priority: 'high',
    reason: 'Around week 20 she reaches the halfway point - here is how to show up.',
    readingTime: '4 min',
    category: 'Supporting Her',
    emoji: '🌗',
    body:
        'Around week 20 she reaches the halfway mark - a real milestone. Many mothers feel more energetic now, the bump becomes visible, and the first kicks often arrive.\n\n'
        'What she needs from you is presence, not fixes. Her body is doing enormous work, and a little practical help - a chore taken off her plate, an early night - lands bigger than grand gestures.\n\n'
        'It is also a lovely window to connect with the baby together: your voice is clear to them now, so read or talk to the bump while she rests.',
    whyThisMatters:
        'The halfway point is when pregnancy starts to feel real for many dads too. Knowing what is shifting for her - energy, body, the first kicks - lets you offer the specific, practical support that actually lands, instead of guessing.',
    researchSimplified:
        'Around the mid-point many women report an energy rebound as early fatigue eases. Partner support is consistently linked to lower stress and better wellbeing in pregnancy, and practical help (chores, rest) reduces her load more than reassurance alone.',
  ),
  ReadItem(
    id: 'f_anomaly_scan',
    title: 'The 20-Week Scan - How to Be There for Her',
    type: ReadType.article,
    weekStart: 18,
    weekEnd: 22,
    priority: 'high',
    reason: 'The detailed anatomy scan is around now - your presence matters.',
    readingTime: '4 min',
    category: 'Supporting Her',
    emoji: '🔍',
    body:
        'The anomaly scan, usually around weeks 18–22, is a detailed look at how your baby is developing - heart, brain, spine, limbs and organs. It takes longer than earlier scans.\n\n'
        'You can usually go with her, and your presence matters more than you think - these appointments can carry quiet anxiety. Write down any questions beforehand so neither of you forgets them in the moment.\n\n'
        'Most findings are reassuring. If anything needs a closer look, the doctor will guide the next steps calmly - your job is simply to be steady beside her.',
    whyThisMatters:
        'Scan days carry quiet anxiety even when everything is fine. Being there - steady, prepared, unhurried - is one of the clearest ways to show up. It also means you hear the same information she does, so you can talk it through together afterwards.',
    researchSimplified:
        'The anomaly scan checks the baby\'s anatomy in detail; the large majority come back reassuring. Partner presence at antenatal appointments is associated with lower maternal anxiety, and writing questions down beforehand improves how much couples remember and understand.',
  ),
  ReadItem(
    id: 'f_back_ache',
    title: 'Why Her Back Aches Now - and What Helps',
    type: ReadType.article,
    weekStart: 16,
    weekEnd: 30,
    priority: 'medium',
    reason: 'Her centre of gravity is shifting - small, specific help lands big.',
    readingTime: '3 min',
    category: 'Supporting Her',
    emoji: '🤰',
    body:
        'As the bump grows, her centre of gravity shifts forward and her lower back takes the strain. By evening, it often aches.\n\n'
        'Small, specific help works best: offer a five-minute back rub, take the heavy lifting off her, and encourage her to rest on her side with a pillow for support.\n\n'
        'You do not need to solve it - just notice it before she has to ask. That noticing is its own kind of care.',
    whyThisMatters:
        'Back ache is one of the most common, most under-noticed strains of pregnancy. Spotting it before she has to ask turns "help" into care - and small, specific actions beat grand gestures every time.',
    researchSimplified:
        'As the uterus grows, the centre of gravity shifts forward and the lower-back muscles work harder, which is why aching peaks by evening. Side-lying with a support pillow and gentle counter-pressure (a short massage) are commonly recommended, low-risk ways to ease it.',
  ),
  ReadItem(
    id: 'f_first_kicks',
    title: 'Feeling the First Kicks Together',
    type: ReadType.article,
    weekStart: 18,
    weekEnd: 26,
    priority: 'medium',
    reason: 'The first movements often arrive now - a moment to share.',
    readingTime: '2 min',
    category: 'Bonding',
    emoji: '👣',
    body:
        'Around now, the first flutters and kicks often arrive. At first they are faint - easy to miss - but they grow stronger over the coming weeks.\n\n'
        'Ask her to tell you when she feels one, and rest your hand gently on her bump. It may take patience; babies often go quiet when they sense a new pressure, then start again.\n\n'
        'The first time you feel that little nudge against your palm is a moment you will remember. Do not rush it - just be there for it.',
    whyThisMatters:
        'Feeling the first kick is often the moment a dad\'s bond becomes physical. Sharing it - hand on the bump, waiting together - turns a private sensation into something you both hold.',
    researchSimplified:
        'First movements (quickening) are usually felt by the mother before they are strong enough to feel from outside; external kicks tend to become palpable a few weeks later. Babies often still when they sense new pressure, then resume - so patience, not force, is the trick.',
  ),

  // ---- Research Summaries -------------------------------------------------
  ReadItem(
    id: 'f_res_voice',
    title: 'The Science of Talking to the Bump',
    type: ReadType.research,
    weekStart: 16,
    weekEnd: 40,
    priority: 'medium',
    reason: 'What the evidence actually says about prenatal bonding through sound.',
    readingTime: '4 min',
    category: 'Research',
    emoji: '🔬',
    body:
        'Prenatal hearing is one of the better-studied parts of fetal development, and the findings are surprisingly practical for dads.\n\n'
        'From the second trimester, the auditory system is wired enough to register sound, and low-frequency voices carry best through the abdominal wall. Repeated exposure to a melody or passage before birth shows up afterwards as recognition - newborns settle to what is familiar.\n\n'
        'The takeaway is simple: a short daily habit beats a rare grand gesture. Same story, same time, your voice.',
    whyThisMatters:
        'It reframes "talking to the bump" from something that feels awkward into something with a real, measurable payoff - a head start on the bond and on soothing your newborn.',
    researchSimplified:
        'Fetal heart-rate and newborn-behaviour studies consistently show recognition of pre-birth sounds. Low frequencies penetrate best, and repetition is the active ingredient. Practically: pick one short thing and repeat it daily.',
  ),
  ReadItem(
    id: 'f_res_dads',
    title: 'What the Research Says About Dads in Pregnancy',
    type: ReadType.research,
    weekStart: 12,
    weekEnd: 40,
    priority: 'medium',
    reason: 'Involved partners measurably change how pregnancy goes for her.',
    readingTime: '5 min',
    category: 'Research',
    emoji: '📊',
    body:
        'A father\'s involvement is not just sentimental - it correlates with concrete outcomes for mother and baby.\n\n'
        'Reviews link supportive partners to lower maternal stress, better antenatal-care attendance, and improved wellbeing. Some studies even associate strong partner support with healthier birth outcomes, likely through reduced stress and better self-care.\n\n'
        'The mechanism is ordinary: presence at appointments, sharing the mental load, and steady emotional support. None of it requires expertise - just showing up.',
    whyThisMatters:
        'If you have ever wondered whether your involvement really moves the needle, the evidence says it does - and it tells you where to spend your effort.',
    researchSimplified:
        'Across studies, partner support tracks with lower stress, better care engagement and wellbeing. The effective inputs are practical and emotional support plus appointment attendance - not grand gestures.',
  ),

  // ---- Book Summaries -----------------------------------------------------
  ReadItem(
    id: 'f_book_handbook',
    title: "We're Pregnant! The First-Time Dad's Pregnancy Handbook",
    type: ReadType.book,
    weekStart: 4,
    weekEnd: 40,
    priority: 'medium',
    reason: 'A week-by-week, no-jargon field guide written dad-to-dad.',
    readingTime: 'Book · 5 min summary',
    category: 'Book Summary',
    emoji: '📗',
    author: 'Adrian Kulp',
    rating: 4.6,
    ratingCount: 4200,
    why:
        'Warm, funny and practical - it treats the dad as a real participant, not a bystander, with concrete things to do each week.',
    body:
        'A week-by-week companion that walks a first-time father from positive test to delivery room. Each stage pairs what is happening for her and the baby with a short, doable list of ways to help.\n\n'
        'The tone is plain and reassuring - no medical jargon, no guilt - and it is honest about the parts nobody warns you about. Think of it as a field guide you dip into a few minutes at a time.\n\n'
        'Best used alongside her appointments: read the matching week, then show up prepared.',
    buyUrl: '',
  ),
  ReadItem(
    id: 'f_book_dude',
    title: "Dude, You're Gonna Be a Dad!",
    type: ReadType.book,
    weekStart: 4,
    weekEnd: 40,
    priority: 'medium',
    reason: 'A quick, encouraging primer for the newly-terrified dad-to-be.',
    readingTime: 'Book · 4 min summary',
    category: 'Book Summary',
    emoji: '📘',
    author: 'John Pfeiffer',
    rating: 4.5,
    ratingCount: 3100,
    why:
        'Short, blunt and encouraging - good for the dad who wants the essentials without a 300-page textbook.',
    body:
        'A fast, confidence-building read that covers the essentials: what she is going through, what the appointments mean, how to prepare practically and financially, and how to be useful in the delivery room.\n\n'
        'It leans on humour to take the edge off the fear, then gets specific about what to actually do. Ideal for a dad who wants to feel ready without wading through jargon.\n\n'
        'Read the summary here, then keep the book handy for the trimester you are in.',
    buyUrl: '',
  ),
];

int _rank(ReadItem r) => r.isHigh ? 0 : 1;

/// Only the article-type father reads (the daily card + the ARTICLES list use
/// these; research/book items surface in their own Reads-tab sections).
List<ReadItem> get kFatherArticles =>
    kFatherReadItems.where((r) => r.type == ReadType.article).toList();

List<ReadItem> fatherReadsByType(ReadType type) =>
    kFatherReadItems.where((r) => r.type == type).toList();

/// The single father read pick for [week] (week-relevant, high-priority first;
/// falls back to the first item so the card always has something).
ReadItem fatherReadForWeek(int week) {
  final relevant = kFatherArticles.where((r) => r.relevantAt(week)).toList()
    ..sort((a, b) => _rank(a).compareTo(_rank(b)));
  return relevant.isNotEmpty ? relevant.first : kFatherArticles.first;
}

/// [count] father read picks for [week], rotating by [day] so it refreshes.
List<ReadItem> fatherDailyReads(int week, int day, {int count = 3}) {
  final relevant = kFatherArticles.where((r) => r.relevantAt(week)).toList()
    ..sort((a, b) => _rank(a).compareTo(_rank(b)));
  final pool = <ReadItem>[...relevant];
  if (pool.length < count) {
    pool.addAll(kFatherArticles.where((r) => !pool.contains(r)));
  }
  if (pool.isEmpty) return const [];
  final n = pool.length;
  final start = day % n;
  return List.generate(count.clamp(0, n), (i) => pool[(start + i) % n]);
}
