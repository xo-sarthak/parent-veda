// =============================================================================
//  ParentVeda Community - seed data (prototype)
// -----------------------------------------------------------------------------
//  Pregnancy-adapted seed: cohort / trimester / location communities are
//  auto-joined; the rest are recommended. NO gender communities during
//  pregnancy (per spec). Feed posts carry community + topic + stage metadata.
// =============================================================================

import '../models/community_models.dart';

// Stable id used for the Community Pulse "question of the week" poll.
const String kPulseKicksPollId = 'pulse_kicks';

/// Specialties a mother can request when she asks for expert verification - so
/// the request reaches the right kind of doctor (curating the doctor feed).
const List<String> kVerifySpecialties = [
  'all',
  'gynae',
  'pediatric',
  'lactation',
  'nutrition',
  'physio',
  'mental',
];

const List<Community> kCommunities = [
  // --- Auto-joined for a pregnancy user (cohort / trimester / location) ---
  Community(
    id: 'nov2026',
    name: 'November 2026 Moms',
    emoji: '🤰',
    description: 'Mothers due in November 2026, going through it together - week by week.',
    members: 1284,
    auto: true,
    topics: ['Pregnancy Symptoms', 'Labor', 'Nutrition'],
  ),
  Community(
    id: 'second_tri',
    name: 'Second Trimester',
    emoji: '🌸',
    description: 'The golden trimester - energy returns, the bump grows, the kicks begin.',
    members: 8640,
    auto: true,
    topics: ['Pregnancy Symptoms', 'Brain Development'],
  ),
  Community(
    id: 'delhi_moms',
    name: 'Delhi Moms',
    emoji: '📍',
    description: 'Local mothers in Delhi - hospitals, doctors, services and meetups.',
    members: 5120,
    auto: true,
    topics: ['Labor'],
  ),
  // --- Recommended / opt-in (no gender communities during pregnancy) ---
  Community(
    id: 'first_time',
    name: 'First Time Moms',
    emoji: '🌷',
    description: 'Everything is new - ask anything, no question is too small here.',
    members: 12400,
    topics: ['Pregnancy Symptoms', 'Labor', 'Breastfeeding'],
  ),
  Community(
    id: 'preg_nutrition',
    name: 'Pregnancy Nutrition',
    emoji: '🥗',
    description: 'What to eat, what to skip, and real meal ideas for every trimester.',
    members: 9300,
    topics: ['Nutrition'],
  ),
  Community(
    id: 'working_moms',
    name: 'Working Moms',
    emoji: '💼',
    description: 'Balancing pregnancy and work - leave, comfort and the road back.',
    members: 7100,
    topics: ['Pregnancy Symptoms'],
  ),
  Community(
    id: 'preg_fitness',
    name: 'Pregnancy Fitness',
    emoji: '🧘',
    description: 'Gentle, safe movement - prenatal yoga, walking and staying strong.',
    members: 4200,
    topics: ['Pregnancy Fitness'],
  ),
  Community(
    id: 'breastfeeding_prep',
    name: 'Breastfeeding Prep',
    emoji: '🤱',
    description: 'Get ready before baby arrives - latch, supply and the first week.',
    members: 6800,
    topics: ['Breastfeeding'],
  ),
  Community(
    id: 'twin_preg',
    name: 'Twin Pregnancy',
    emoji: '👯',
    description: 'Two at once - extra scans, extra love, and parents who get it.',
    members: 1900,
    topics: ['Pregnancy Symptoms'],
  ),
  Community(
    id: 'high_risk',
    name: 'High Risk Pregnancy',
    emoji: '💗',
    description: 'Extra care, extra support - a gentle space to share and lean on others.',
    members: 2600,
    topics: ['Pregnancy Symptoms'],
  ),
  Community(
    id: 'ivf',
    name: 'IVF Pregnancy',
    emoji: '🌱',
    description: 'The long road that led here - a community that understands the journey.',
    members: 2100,
    topics: ['Pregnancy Symptoms'],
  ),
  Community(
    id: 'brain_dev',
    name: 'Brain Development',
    emoji: '🧠',
    description: 'Nurturing your baby mind before birth and in the early years.',
    members: 5400,
    topics: ['Brain Development'],
  ),
];

const List<CommunityPost> kSeedPosts = [
  CommunityPost(
    id: 'p1',
    communityId: 'nov2026',
    author: 'Anjali',
    authorEmoji: '🤰',
    text: 'Anyone else having back pain in Week 24? How are you managing it through the day?',
    type: PostType.question,
    topics: ['Pregnancy Symptoms'],
    likes: 84,
    comments: 37,
    saves: 12,
    wantsVerification: true,
  ),
  CommunityPost(
    id: 'p2',
    communityId: 'second_tri',
    author: 'Sneha',
    authorEmoji: '🌸',
    text: 'Felt the first proper kicks today and cried happy tears. Best feeling in the world 💛',
    type: PostType.experience,
    topics: ['Pregnancy Symptoms', 'Brain Development'],
    likes: 210,
    comments: 45,
    saves: 30,
    endorsedBy: 'Dr. Meera',
    endorsedByCred: 'IBCLC',
    expertEndorseCount: 240,
  ),
  CommunityPost(
    id: 'p3',
    communityId: 'preg_nutrition',
    author: 'Ritu',
    authorEmoji: '🥗',
    text: 'How many glasses of water are you actually managing in a day?',
    type: PostType.poll,
    topics: ['Nutrition'],
    pollOptions: ['Under 6', '6 to 8', 'More than 8'],
    likes: 33,
    comments: 14,
    saves: 4,
  ),
  CommunityPost(
    id: 'p4',
    communityId: 'nov2026',
    author: 'Pooja',
    authorEmoji: '🙂',
    text: 'Is it normal to feel breathless climbing stairs at week 22? It started this week.',
    type: PostType.question,
    topics: ['Pregnancy Symptoms'],
    likes: 56,
    comments: 22,
    saves: 8,
    wantsVerification: true,
  ),
  CommunityPost(
    id: 'p5',
    communityId: 'breastfeeding_prep',
    author: 'Dr. Meera',
    authorEmoji: '👩‍⚕️',
    text: 'Lactation tip: start learning the latch positions now - it makes the first week so much easier.',
    type: PostType.expert,
    topics: ['Breastfeeding'],
    likes: 140,
    comments: 19,
    saves: 88,
    upvotes: 76,
    cred: 'IBCLC',
    expertEndorseCount: 180,
  ),
  CommunityPost(
    id: 'p6',
    communityId: 'delhi_moms',
    author: 'Neha',
    authorEmoji: '📍',
    text: 'Which hospital did you choose in Delhi for delivery? Looking for recommendations 🙏',
    type: PostType.question,
    topics: ['Labor'],
    likes: 47,
    comments: 31,
    saves: 15,
  ),
  CommunityPost(
    id: 'p7',
    communityId: 'first_time',
    author: 'Divya',
    authorEmoji: '🌷',
    text: 'Packed my hospital bag at week 30 and felt so much calmer. Sharing my full checklist below.',
    type: PostType.experience,
    topics: ['Labor'],
    likes: 96,
    comments: 24,
    saves: 61,
  ),
  CommunityPost(
    id: 'p8',
    communityId: 'preg_fitness',
    author: 'Kavya',
    authorEmoji: '🧘',
    text: 'My little prenatal yoga corner. Ten minutes a morning has done wonders for my mood.',
    type: PostType.photo,
    topics: ['Pregnancy Fitness'],
    image: '🧘‍♀️',
    likes: 72,
    comments: 9,
    saves: 14,
  ),
  CommunityPost(
    id: 'p9',
    communityId: 'nov2026',
    author: 'ParentVeda',
    authorEmoji: '💜',
    text: 'Question of the week: have you started feeling regular kicks?',
    type: PostType.poll,
    topics: ['Pregnancy Symptoms'],
    pollOptions: ['Yes', 'Sometimes', 'Not yet'],
    likes: 41,
    comments: 12,
    saves: 2,
  ),
  CommunityPost(
    id: 'p10',
    communityId: 'second_tri',
    author: 'Aishwarya',
    authorEmoji: '🌸',
    text: 'Halfway there - completed my anomaly scan today and everything looks perfect 💛',
    type: PostType.milestone,
    topics: ['Pregnancy Symptoms'],
    likes: 188,
    comments: 33,
    saves: 9,
  ),
  CommunityPost(
    id: 'p11',
    communityId: 'preg_nutrition',
    author: 'Shruti',
    authorEmoji: '🥗',
    text: 'Craving everything fried lately 😅 has anyone found healthy swaps that actually satisfy?',
    type: PostType.question,
    topics: ['Nutrition'],
    likes: 64,
    comments: 41,
    saves: 22,
  ),
  CommunityPost(
    id: 'p12',
    communityId: 'working_moms',
    author: 'Simran',
    authorEmoji: '💼',
    text: 'Told my manager today. Nervous but relieved. Any tips for the third trimester at work?',
    type: PostType.experience,
    topics: ['Pregnancy Symptoms'],
    likes: 58,
    comments: 27,
    saves: 11,
  ),
  CommunityPost(
    id: 'p13',
    communityId: 'high_risk',
    author: 'Fatima',
    authorEmoji: '💗',
    text: 'On bed rest this week. It is hard, but reading your stories keeps me going. Thank you all 💗',
    type: PostType.experience,
    topics: ['Pregnancy Symptoms'],
    likes: 122,
    comments: 38,
    saves: 7,
  ),
  CommunityPost(
    id: 'p14',
    communityId: 'nov2026',
    author: 'ParentVeda',
    authorEmoji: '💜',
    text: 'Welcome to your November 2026 Moms community. Introduce yourself below 👇',
    type: PostType.parentVeda,
    topics: [],
    likes: 33,
    comments: 56,
    saves: 1,
  ),
  CommunityPost(
    id: 'p15',
    communityId: 'first_time',
    author: 'Aisha',
    authorEmoji: '🌷',
    text:
        'My birth story 💕 After a long labour we did skin-to-skin right away and started feeding within the first hour. To every first-time mom reading this - trust your body, it truly knows the way.',
    type: PostType.milestone,
    topics: ['Labor', 'Breastfeeding'],
    likes: 264,
    comments: 52,
    saves: 73,
    endorsedBy: 'Dr. Meera',
    endorsedByCred: 'IBCLC',
    expertEndorseCount: 320,
  ),
  // --- General feed (no community) - your main timeline ---
  CommunityPost(
    id: 'g1',
    communityId: '',
    author: 'Tanvi',
    authorEmoji: '🌼',
    text:
        'Reminder to every mama scrolling tonight: you are doing so much better than you think. Rest when you can 💛',
    type: PostType.experience,
    topics: ['Pregnancy Symptoms'],
    likes: 152,
    comments: 28,
    saves: 19,
  ),
  CommunityPost(
    id: 'g2',
    communityId: '',
    author: 'Dr. Aarti Desai',
    authorEmoji: '👩‍⚕️',
    text:
        'Quick iron tip: pair your dal, spinach or beans with something rich in vitamin C (lemon, tomato, orange) and keep tea/coffee away from meals - you absorb a lot more iron that way.',
    type: PostType.expert,
    topics: ['Nutrition'],
    likes: 198,
    comments: 21,
    saves: 96,
    upvotes: 64,
    cred: 'RD',
    expertEndorseCount: 150,
  ),
  CommunityPost(
    id: 'g3',
    communityId: '',
    author: 'Meghna',
    authorEmoji: '🤰',
    text:
        'How is everyone managing the third-trimester sleep struggle? Pillows everywhere and I still wake up at 3am 😅',
    type: PostType.question,
    topics: ['Pregnancy Symptoms', 'Sleep'],
    likes: 73,
    comments: 33,
    saves: 7,
    wantsVerification: true,
  ),
];

/// One verified expert in the (dummy) endorsement pool.
typedef CommunityExpert = ({String name, String cred, String specialty});

/// The pool of verified experts shown in the "who verified this" sheet.
/// All fictional - placeholder data until real doctor accounts exist.
const List<CommunityExpert> kCommunityExperts = [
  (name: 'Dr. Meera Nair', cred: 'IBCLC', specialty: 'Lactation'),
  (name: 'Dr. Priya Sharma', cred: 'MD', specialty: 'Pediatrics'),
  (name: 'Dr. Ananya Rao', cred: 'OB-GYN', specialty: 'Obstetrics'),
  (name: 'Dr. Kavita Menon', cred: 'MD', specialty: 'Gynaecology'),
  (name: 'Dr. Sneha Iyer', cred: 'DNB', specialty: 'Fetal Medicine'),
  (name: 'Dr. Riya Kapoor', cred: 'MD', specialty: 'Neonatology'),
  (name: 'Dr. Aarti Desai', cred: 'RD', specialty: 'Prenatal Nutrition'),
  (name: 'Dr. Neha Bansal', cred: 'MD', specialty: 'Pediatrics'),
  (name: 'Dr. Pooja Reddy', cred: 'OB-GYN', specialty: 'High-risk Pregnancy'),
  (name: 'Dr. Shalini Verma', cred: 'IBCLC', specialty: 'Breastfeeding'),
  (name: 'Dr. Ritu Agarwal', cred: 'MD', specialty: 'Obstetrics'),
  (name: 'Dr. Divya Pillai', cred: 'PT', specialty: 'Prenatal Fitness'),
  (name: 'Dr. Sana Khan', cred: 'MD', specialty: 'Gynaecology'),
  (name: 'Dr. Tara Joshi', cred: 'PsyD', specialty: 'Perinatal Mental Health'),
  (name: 'Dr. Ishita Gupta', cred: 'DCH', specialty: 'Child Health'),
  (name: 'Dr. Lakshmi Subramanian', cred: 'MD', specialty: 'Maternal Medicine'),
  (name: 'Dr. Farah Ahmed', cred: 'IBCLC', specialty: 'Lactation'),
  (name: 'Dr. Megha Saxena', cred: 'OB-GYN', specialty: 'Obstetrics'),
  (name: 'Dr. Nandini Rao', cred: 'RD', specialty: 'Nutrition'),
  (name: 'Dr. Sweta Mishra', cred: 'MD', specialty: 'Neonatology'),
  (name: 'Dr. Aisha Sheikh', cred: 'DNB', specialty: 'Gynaecology'),
  (name: 'Dr. Vidya Hegde', cred: 'MD', specialty: 'Pediatrics'),
  (name: 'Dr. Charita Reddy', cred: 'PT', specialty: 'Pelvic Health'),
  (name: 'Dr. Ramya Krishnan', cred: 'OB-GYN', specialty: 'Fetal Medicine'),
];

const Map<String, List<CommunityComment>> kSeedComments = {
  'p1': [
    CommunityComment(author: 'Meera', emoji: '🙂', text: 'Yes! Week 25 here. A warm compress and a pregnancy pillow helped me a lot.', likes: 14),
    CommunityComment(author: 'Ritu', emoji: '🌸', text: 'Prenatal yoga changed everything for my back. Gentle cat-cow stretches every morning.', likes: 9),
    CommunityComment(author: 'Anjali', emoji: '🤰', text: 'Thank you both, trying the pillow tonight 🙏', likes: 3),
  ],
  'p2': [
    CommunityComment(author: 'Pooja', emoji: '🙂', text: 'Congratulations! Such a magical moment 💛', likes: 8),
    CommunityComment(author: 'Neha', emoji: '📍', text: 'Wait till you feel the hiccups, even cuter!', likes: 5),
  ],
  'p7': [
    CommunityComment(author: 'Kavya', emoji: '🧘', text: 'Could you share the checklist please? Due in November too!', likes: 4),
    CommunityComment(author: 'Divya', emoji: '🌷', text: 'Just posted it inside First Time Moms 😊', likes: 2),
  ],
  'p10': [
    CommunityComment(author: 'Sneha', emoji: '🌸', text: 'So happy for you! Halfway feels unreal.', likes: 6),
    CommunityComment(author: 'Shruti', emoji: '🥗', text: 'Congrats! Mine is next week, fingers crossed 🤞', likes: 3),
  ],
};

const List<PulseCard> kPulse = [
  PulseCard(
    type: PulseType.cohort,
    title: 'You are not alone',
    body: '127 mothers are also due in November 2026.',
  ),
  PulseCard(
    type: PulseType.poll,
    title: 'Question of the week',
    body: 'Have you started feeling regular kicks?',
    options: ['Yes', 'Sometimes', 'Not yet'],
  ),
  PulseCard(
    type: PulseType.trending,
    title: 'Trending discussion',
    body: 'Anyone else having back pain in Week 24?',
    linkPostId: 'p1',
  ),
  PulseCard(
    type: PulseType.benchmark,
    title: 'Cohort benchmark',
    body: '68% of mothers in your cohort have completed their anomaly scan.',
  ),
  PulseCard(
    type: PulseType.expert,
    title: 'Expert session',
    body: 'Live tomorrow: Nutrition During the Third Trimester.',
  ),
];

Community? communityById(String id) {
  for (final c in kCommunities) {
    if (c.id == id) return c;
  }
  return null;
}

List<CommunityComment> seedCommentsFor(String postId) =>
    kSeedComments[postId] ?? const [];

// ---------------------------------------------------------------------------
//  Auto-tagging: guess topic hashtags from a post's text (keyword match).
//  Powers the recommendation/feed metadata without asking the user to tag.
// ---------------------------------------------------------------------------
const Map<String, List<String>> _topicKeywords = {
  'Nutrition': ['eat', 'food', 'diet', 'nutrition', 'craving', 'fried', 'water', 'meal', 'hungry', 'snack', 'weight gain'],
  'Sleep': ['sleep', 'nap', 'insomnia', 'awake', 'rest', 'night'],
  'Breastfeeding': ['breastfeed', 'breast', 'latch', 'milk supply', 'nursing', 'pump', 'feeding'],
  'Labor': ['labor', 'labour', 'delivery', 'contraction', 'hospital bag', 'birth', 'c-section', 'csection', 'due date', 'induction'],
  'Pregnancy Symptoms': ['pain', 'nausea', 'vomit', 'kick', 'swelling', 'back', 'cramp', 'heartburn', 'acidity', 'breathless', 'scan', 'symptom', 'bp', 'blood pressure', 'dizzy'],
  'Brain Development': ['brain', 'development', 'music', 'talk to baby', 'garbh', 'read to'],
  'Pregnancy Fitness': ['yoga', 'exercise', 'walk', 'fitness', 'workout', 'gym', 'stretch'],
  'Vaccination': ['vaccine', 'vaccination', 'tetanus', 'flu shot', 'jab'],
};

/// Reads [text] and returns up to 3 topic hashtags it appears to be about.
List<String> inferTopics(String text) {
  final t = text.toLowerCase();
  final found = <String>[];
  _topicKeywords.forEach((topic, keys) {
    if (keys.any(t.contains)) found.add(topic);
  });
  return found.take(3).toList();
}

// ===========================================================================
//  PARENTING-STAGE communities (post-birth). Kept as their OWN lists so the
//  pre-birth (pregnancy) feed above stays exactly as it was - the parenting
//  Community screen (post_pregnancy) reads these; interactions (join/like/save/
//  vote/comment) reuse the same CommunityStore, which is keyed by id. Gender
//  communities are fine now (unlike during pregnancy). `emoji` is left blank -
//  the parenting UI renders monogram/icon avatars, never emojis.
// ===========================================================================
const List<Community> kParentingCommunities = [
  // --- Auto-joined for the scenario child (Aarav · 4-mo boy · Delhi NCR) ---
  Community(id: 'infants_0_1', name: '0–1 Year', emoji: '', description: 'The whole first year - feeding, sleep, milestones and the fourth-trimester fog, together.', members: 14200, auto: true, topics: ['Sleep', 'Feeding', 'Milestones']),
  Community(id: 'boy_moms', name: 'Boy Moms', emoji: '', description: 'Raising boys - the mess, the cuddles and everything in between.', members: 9800, auto: true, topics: ['Behaviour']),
  Community(id: 'delhi_parents', name: 'Delhi Parents', emoji: '', description: 'Local parents in Delhi NCR - paediatricians, daycares, classes and meetups.', members: 6400, auto: true, topics: ['Health']),
  // --- Recommended · the ages that come next ---
  Community(id: 'ones', name: '1 Year Olds', emoji: '', description: 'First steps, first words, first birthday - life with a one-year-old.', members: 11200, topics: ['Milestones', 'Feeding']),
  Community(id: 'twos', name: '2 Year Olds', emoji: '', description: 'Big feelings, big words and the famous twos - you are not alone.', members: 10600, topics: ['Behaviour']),
  Community(id: 'threes', name: '3 Year Olds', emoji: '', description: 'Preschool, endless “why?”, and a little person with big opinions.', members: 7300, topics: ['Behaviour', 'Development']),
  Community(id: 'toddlers', name: 'Toddler Life', emoji: '', description: 'The 1–3 whirlwind - tantrums, milestones and tiny triumphs.', members: 13400, topics: ['Behaviour', 'Development']),
  // --- Topics that only matter once baby is here ---
  Community(id: 'first_foods', name: 'Starting Solids', emoji: '', description: 'First foods, weaning and fussy eating - recipes and reassurance.', members: 8900, topics: ['Feeding']),
  Community(id: 'baby_sleep', name: 'Baby Sleep', emoji: '', description: 'Regressions, naps and nights - gentle, no-judgement sleep support.', members: 12800, topics: ['Sleep']),
  Community(id: 'milestones', name: 'Milestones & Development', emoji: '', description: 'Rolling, sitting, crawling, talking - celebrate and compare notes.', members: 9100, topics: ['Milestones', 'Development']),
  Community(id: 'working_parents', name: 'Working Parents', emoji: '', description: 'Daycare, nannies, pumping and the juggle of going back to work.', members: 7600, topics: ['Health']),
  Community(id: 'potty', name: 'Potty Training', emoji: '', description: 'When to start, what worked, and surviving the accidents.', members: 4300, topics: ['Behaviour']),
  // --- Gender + more city groups (fine now that baby is here) ---
  Community(id: 'girl_moms', name: 'Girl Moms', emoji: '', description: 'Raising girls - the giggles, the grit and everything in between.', members: 9200, topics: ['Behaviour']),
  Community(id: 'mumbai_parents', name: 'Mumbai Parents', emoji: '', description: 'Local parents in Mumbai - paediatricians, daycares, classes and meetups.', members: 5300, topics: ['Health']),
];

const Set<String> kParentingCommunityIds = {
  'infants_0_1', 'boy_moms', 'delhi_parents', 'ones', 'twos', 'threes',
  'toddlers', 'first_foods', 'baby_sleep', 'milestones', 'working_parents', 'potty',
  'girl_moms', 'mumbai_parents',
};

/// Verified experts a parent can reach when asking for verification - so the
/// request lands with the right kind of specialist (curating the doctor feed).
const List<String> kParentingVerifySpecialties = [
  'all',
  'pediatric',
  'lactation',
  'nutrition',
  'sleep',
  'development',
  'mental',
];

/// The pool of verified experts shown in the parenting "who verified this" sheet.
/// All fictional - placeholder data until real doctor accounts exist.
const List<CommunityExpert> kParentingExperts = [
  (name: 'Dr. Ananya Rao', cred: 'Paediatrician', specialty: 'Child Health'),
  (name: 'Dr. Neha Sharma', cred: 'MD, Paediatrics', specialty: 'Paediatrics'),
  (name: 'Dr. Priya Menon', cred: 'IBCLC', specialty: 'Lactation'),
  (name: 'Dr. Kavita Reddy', cred: 'Paed. Nutritionist', specialty: 'Infant Nutrition'),
  (name: 'Dr. Riya Kapoor', cred: 'Child Psychologist', specialty: 'Behaviour'),
  (name: 'Dr. Sneha Iyer', cred: 'Paediatric Physio', specialty: 'Motor Development'),
  (name: 'Dr. Aarti Desai', cred: 'Sleep Consultant', specialty: 'Infant Sleep'),
  (name: 'Dr. Meera Nair', cred: 'Paediatrician', specialty: 'Newborn Care'),
  (name: 'Dr. Pooja Verma', cred: 'MD', specialty: 'Paediatrics'),
  (name: 'Dr. Farah Ahmed', cred: 'IBCLC', specialty: 'Breastfeeding'),
  (name: 'Dr. Divya Pillai', cred: 'Paediatric Dentist', specialty: 'Teething'),
  (name: 'Dr. Ritu Agarwal', cred: 'Developmental Paed', specialty: 'Milestones'),
];

const List<CommunityPost> kParentingPosts = [
  CommunityPost(
    id: 'pp1',
    communityId: 'baby_sleep',
    author: 'Meera',
    authorEmoji: '',
    text: 'Night 6 of the 4-month sleep regression. What finally helped us: an earlier bedtime and a darker, more boring room. If you are in it right now - hang in there, it does pass.',
    type: PostType.experience,
    topics: ['Sleep'],
    stage: 'Parenting',
    likes: 128,
    comments: 42,
    saves: 26,
    endorsedBy: 'Dr. Ananya Rao',
    endorsedByCred: 'Paediatrician',
    expertEndorseCount: 34,
  ),
  CommunityPost(
    id: 'pp2',
    communityId: 'infants_0_1',
    author: 'Anjali',
    authorEmoji: '',
    text: 'My baby is 4 months and not rolling over yet. Everyone else’s seems to be. Should I be worried, or is this still normal?',
    type: PostType.question,
    topics: ['Milestones'],
    stage: 'Parenting',
    likes: 64,
    comments: 31,
    saves: 9,
    wantsVerification: true,
    preferredSpecialty: 'pediatric',
  ),
  CommunityPost(
    id: 'pp3',
    communityId: 'first_foods',
    author: 'Ritu',
    authorEmoji: '',
    text: 'When did you actually start solids?',
    type: PostType.poll,
    topics: ['Feeding'],
    stage: 'Parenting',
    pollOptions: ['Around 4 months', 'At 6 months', 'After 6 months'],
    likes: 38,
    comments: 15,
    saves: 4,
  ),
  CommunityPost(
    id: 'pp4',
    communityId: 'milestones',
    author: 'Dr. Neha Sharma',
    authorEmoji: '',
    text: 'A reminder from clinic: milestones are a range, not a deadline. Most babies roll between 4 and 6 months, and some skip it entirely and go straight to sitting. Watch the overall trend, not the calendar - and always ask us if something feels off.',
    type: PostType.expert,
    topics: ['Milestones', 'Development'],
    stage: 'Parenting',
    likes: 172,
    comments: 24,
    saves: 118,
    upvotes: 89,
    cred: 'MD, Paediatrics',
    expertEndorseCount: 46,
  ),
  CommunityPost(
    id: 'pp5',
    communityId: 'twos',
    author: 'Sneha',
    authorEmoji: '',
    text: 'The tantrums at 2 nearly broke me this week. What helped a little: naming the feeling out loud ("you’re so frustrated") and staying calm-ish myself. Solidarity, anyone?',
    type: PostType.experience,
    topics: ['Behaviour'],
    stage: 'Parenting',
    likes: 96,
    comments: 40,
    saves: 17,
  ),
  CommunityPost(
    id: 'pp6',
    communityId: 'delhi_parents',
    author: 'Neha',
    authorEmoji: '',
    text: 'Which paediatrician do you love in South Delhi for the 6-month vaccines? Looking for someone gentle and not rushed.',
    type: PostType.question,
    topics: ['Health'],
    stage: 'Parenting',
    likes: 47,
    comments: 28,
    saves: 15,
  ),
  CommunityPost(
    id: 'pp7',
    communityId: 'infants_0_1',
    author: 'ParentVeda',
    authorEmoji: '',
    text: 'A new phase is around the corner. Here’s what changes next - and why a fussy stretch beforehand is usually a good sign.',
    type: PostType.parentVeda,
    topics: ['Development'],
    stage: 'Parenting',
    likes: 54,
    comments: 12,
    saves: 20,
  ),
  CommunityPost(
    id: 'pp8',
    communityId: 'ones',
    author: 'Divya',
    authorEmoji: '',
    text: 'First steps today at 13 months! I cried a little (okay, a lot). All those months of cruising the furniture finally paid off.',
    type: PostType.milestone,
    topics: ['Milestones'],
    stage: 'Parenting',
    likes: 188,
    comments: 33,
    saves: 12,
  ),
  CommunityPost(
    id: 'pp9',
    communityId: 'working_parents',
    author: 'Simran',
    authorEmoji: '',
    text: 'Back to work next month and dreading the daycare drop-off. How did you make the transition easier - for the baby and for yourself?',
    type: PostType.question,
    topics: ['Health'],
    stage: 'Parenting',
    likes: 58,
    comments: 27,
    saves: 11,
  ),
  CommunityPost(
    id: 'pp10',
    communityId: 'first_foods',
    author: 'Kavya',
    authorEmoji: '',
    text: 'Baby-led weaning vs purées - what did you actually end up doing, and would you do it the same way again?',
    type: PostType.question,
    topics: ['Feeding'],
    stage: 'Parenting',
    likes: 71,
    comments: 44,
    saves: 22,
  ),
  CommunityPost(
    id: 'pp11',
    communityId: 'boy_moms',
    author: 'Ishita',
    authorEmoji: '',
    text: 'Nobody warned me how physical raising a boy would be. He climbs everything. Tips for baby-proofing a climber very welcome.',
    type: PostType.question,
    topics: ['Behaviour'],
    stage: 'Parenting',
    likes: 63,
    comments: 29,
    saves: 12,
  ),
  CommunityPost(
    id: 'pp12',
    communityId: 'girl_moms',
    author: 'Aditi',
    authorEmoji: '',
    text: 'My daughter just started saying "no" to everything with the biggest grin. Toddler girl energy is unmatched. Anyone else living this?',
    type: PostType.experience,
    topics: ['Behaviour'],
    stage: 'Parenting',
    likes: 88,
    comments: 34,
    saves: 9,
  ),
  CommunityPost(
    id: 'pp13',
    communityId: 'toddlers',
    author: 'Rhea',
    authorEmoji: '',
    text: 'Mealtimes with my 18-month-old have become a battlefield. She used to eat everything and now refuses. Is this a phase?',
    type: PostType.question,
    topics: ['Feeding', 'Behaviour'],
    stage: 'Parenting',
    likes: 74,
    comments: 38,
    saves: 16,
    endorsedBy: 'Dr. Kavita Reddy',
    endorsedByCred: 'Paed. Nutritionist',
    expertEndorseCount: 12,
  ),
  CommunityPost(
    id: 'pp14',
    communityId: 'threes',
    author: 'Nidhi',
    authorEmoji: '',
    text: 'Started preschool this week. She cried at drop-off but the teacher sent a photo of her laughing 20 minutes later. My heart.',
    type: PostType.experience,
    topics: ['Development', 'Behaviour'],
    stage: 'Parenting',
    likes: 141,
    comments: 22,
    saves: 8,
  ),
  CommunityPost(
    id: 'pp15',
    communityId: 'potty',
    author: 'Meghana',
    authorEmoji: '',
    text: 'When did you actually start potty training?',
    type: PostType.poll,
    topics: ['Behaviour'],
    stage: 'Parenting',
    pollOptions: ['Before 2', 'Around 2.5', 'After 3'],
    likes: 52,
    comments: 19,
    saves: 6,
  ),
  CommunityPost(
    id: 'pp16',
    communityId: 'mumbai_parents',
    author: 'Farida',
    authorEmoji: '',
    text: 'New to Andheri with a 7-month-old. Which paediatrician do you trust nearby, and are there any good baby swim or play classes?',
    type: PostType.question,
    topics: ['Health'],
    stage: 'Parenting',
    likes: 39,
    comments: 24,
    saves: 11,
  ),
  CommunityPost(
    id: 'pp17',
    communityId: 'baby_sleep',
    author: 'Dr. Aarti Desai',
    authorEmoji: '',
    text: 'A gentle reminder on the 4-month regression: it is a permanent change in how your baby sleeps, not a phase that "breaks". Anchor a calm bedtime routine and consistent wake time, and it settles. You are not doing anything wrong.',
    type: PostType.expert,
    topics: ['Sleep'],
    stage: 'Parenting',
    likes: 156,
    comments: 27,
    saves: 102,
    upvotes: 71,
    cred: 'Sleep Consultant',
    expertEndorseCount: 38,
  ),
  CommunityPost(
    id: 'pp18',
    communityId: 'infants_0_1',
    author: 'Tara',
    authorEmoji: '',
    text: 'My 3-month-old fusses at the breast every evening and I am not sure if my supply is dipping. Would love a lactation expert to weigh in.',
    type: PostType.question,
    topics: ['Feeding'],
    stage: 'Parenting',
    likes: 61,
    comments: 33,
    saves: 14,
    wantsVerification: true,
    preferredSpecialty: 'lactation',
  ),
  CommunityPost(
    id: 'pp19',
    communityId: 'milestones',
    author: 'Pallavi',
    authorEmoji: '',
    text: 'She sat up unsupported for a full minute today. Six months of tummy time and here we are. Celebrating the tiny wins.',
    type: PostType.milestone,
    topics: ['Milestones', 'Development'],
    stage: 'Parenting',
    likes: 167,
    comments: 21,
    saves: 7,
  ),
  // --- General parenting timeline (no community) ---
  CommunityPost(
    id: 'pg1',
    communityId: '',
    author: 'Tanvi',
    authorEmoji: '',
    text: 'To every parent up at 3am reading this: you are doing so much better than you think. This stage is hard and it is temporary. Rest when you can.',
    type: PostType.experience,
    topics: ['Behaviour'],
    stage: 'Parenting',
    likes: 152,
    comments: 28,
    saves: 19,
  ),
  CommunityPost(
    id: 'pg2',
    communityId: '',
    author: 'Dr. Kavita Reddy',
    authorEmoji: '',
    text: 'Iron matters a lot from 6 months. Pair iron-rich first foods - ragi, dal, well-cooked egg yolk, pureed meat - with a little vitamin C (a few drops of orange or amla) to boost absorption. Keep milk feeds out of mealtimes.',
    type: PostType.expert,
    topics: ['Feeding'],
    stage: 'Parenting',
    likes: 184,
    comments: 19,
    saves: 121,
    upvotes: 68,
    cred: 'Paed. Nutritionist',
    expertEndorseCount: 42,
  ),
  CommunityPost(
    id: 'pg3',
    communityId: '',
    author: 'Meghna',
    authorEmoji: '',
    text: 'How is everyone handling separation anxiety around 8-9 months? The moment I leave the room the crying starts. Is there anything that actually helps?',
    type: PostType.question,
    topics: ['Behaviour', 'Development'],
    stage: 'Parenting',
    likes: 79,
    comments: 36,
    saves: 13,
    wantsVerification: true,
    preferredSpecialty: 'development',
  ),
];

const Map<String, List<CommunityComment>> kParentingComments = {
  'pp1': [
    CommunityComment(author: 'Anjali', emoji: '', text: 'Thank you for this. Night 4 here and I needed to read it.', likes: 11),
    CommunityComment(author: 'Priya', emoji: '', text: 'The darker room made the biggest difference for us too. Blackout curtains were worth every rupee.', likes: 7),
  ],
  'pp2': [
    CommunityComment(author: 'Dr. Neha Sharma', emoji: '', text: 'Totally normal range. If he has good head control and is reaching for things, he is on track - mention it at the 6-month visit and we can check together.', likes: 22),
    CommunityComment(author: 'Ritika', emoji: '', text: 'Mine rolled at nearly 6 months and is a happy, busy toddler now. Try not to compare!', likes: 6),
  ],
  'pp4': [
    CommunityComment(author: 'Sana', emoji: '', text: 'Needed this today. I was spiralling over the 5-month check comparing to the neighbour baby.', likes: 9),
    CommunityComment(author: 'Deepa', emoji: '', text: 'Saved. Thank you for the calm, doctor.', likes: 4),
  ],
  'pp10': [
    CommunityComment(author: 'Sonia', emoji: '', text: 'We did a mix - purees at home, finger foods when out. Zero regrets, way less pressure.', likes: 12),
    CommunityComment(author: 'Kavya', emoji: '', text: 'This is reassuring, thank you. Was feeling like I had to pick a camp.', likes: 3),
  ],
  'pp13': [
    CommunityComment(author: 'Dr. Kavita Reddy', emoji: '', text: 'Very common at this age - appetites naturally dip as growth slows. Keep offering, do not force, and let her decide how much. It passes.', likes: 18),
    CommunityComment(author: 'Rhea', emoji: '', text: 'Thank you doctor, that takes the panic away.', likes: 2),
  ],
  'pp15': [
    CommunityComment(author: 'Anita', emoji: '', text: 'We waited till closer to 3 and it took just a weekend. Waiting for readiness was everything for us.', likes: 7),
  ],
};

Community? parentingCommunityById(String id) {
  for (final c in kParentingCommunities) {
    if (c.id == id) return c;
  }
  return null;
}
