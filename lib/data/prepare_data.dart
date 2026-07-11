// =============================================================================
//  Prepare - content model + data
// -----------------------------------------------------------------------------
//  Single source of truth for the "Prepare" tab. Every category screen lists
//  from here, and every detail page renders from the matching object - so
//  nothing dead-ends. Content is a faithful, on-brand extension of the Claude
//  Design mock (Priya · 30 weeks). Static for now; a future pass can make it
//  week-adaptive and back it with a CMS/DB.
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/prepare/prepare_common.dart';

// ---- shared value types -----------------------------------------------------
class Coach {
  const Coach(this.name, this.role, this.bio);
  final String name;
  final String role;
  final String bio;
}

class QuickFact {
  const QuickFact(this.big, this.small);
  final String big;
  final String small;
}

class Testimonial {
  const Testimonial(this.quote, this.who, this.when);
  final String quote;
  final String who;
  final String when;
}

class Faq {
  const Faq(this.q, [this.a]);
  final String q;
  final String? a; // open (with answer) vs collapsed
}

class Review {
  const Review(this.who, this.when, this.quote);
  final String who;
  final String when;
  final String quote;
}

// ---- masterclasses ----------------------------------------------------------
class Masterclass {
  const Masterclass({
    required this.id,
    required this.title,
    required this.listDesc,
    required this.longDesc,
    required this.price,
    required this.facts,
    required this.coaches,
    required this.learn,
    this.testimonials = const [],
    this.faqs = const [],
    this.badge,
    this.badgeIsCoral = true,
    this.listChip,
    this.listChipIsCoral = false,
    this.featured = false,
  });

  final String id;
  final String title;
  final String listDesc; // one-liner on the list/featured card
  final String longDesc; // detail hero paragraph
  final String price; // "₹799"
  final List<QuickFact> facts;
  final List<Coach> coaches;
  final List<String> learn;
  final List<Testimonial> testimonials;
  final List<Faq> faqs;
  final String? badge; // hero/featured pill, e.g. "Most-booked at 30 weeks"
  final bool badgeIsCoral;
  final String? listChip; // small chip in the "more" list
  final bool listChipIsCoral;
  final bool featured;
}

const List<Masterclass> kMasterclasses = [
  Masterclass(
    id: 'mc_birth',
    featured: true,
    title: 'Birth Confidence Masterclass',
    badge: 'Most-booked at 30 weeks',
    price: '₹799',
    listDesc:
        'What labour really feels like: breathing, pain relief, C-section prep, and emotional readiness. 90 min live + lifetime recording.',
    longDesc:
        'What labour really feels like - breathing, pain relief, C-section prep, and the emotional readiness no one talks about. One live evening that changes how you walk into the delivery room.',
    facts: [QuickFact('90 min', 'live'), QuickFact('Sun 13 Jul', '8:00 pm'), QuickFact('Forever', 'recording')],
    coaches: [
      Coach('Dr. Ananya Rao', 'Obstetrician · 15 years',
          "Has delivered over 3,000 babies across Delhi's leading hospitals. Known for calm, plain-language guidance."),
      Coach('Deepti Sharma', 'Doula & birth coach',
          'Has supported 400+ births. Brings the emotional side - fear, partners, and staying in control.'),
    ],
    learn: [
      'A clear picture of each stage of labour, minute by minute.',
      'Breathing techniques you can actually use through a contraction.',
      'The real pros and cons of epidural, natural and C-section.',
      'How to write a birth plan your hospital will respect.',
    ],
    testimonials: [
      Testimonial(
          '"I went in terrified and came out feeling like I could actually do this. The breathing section alone was worth it."',
          'Ananya P.',
          'delivered March 2025'),
      Testimonial('"My husband finally understood how to help. We watched the recording together twice."',
          'Ritika M.', '34 weeks'),
    ],
    faqs: [
      Faq("What if I can't attend live?",
          "The full recording lands in your library within 24 hours, and it's yours forever."),
      Faq('Is this okay at 30 weeks?'),
      Faq('Can my partner join?'),
      Faq('Is it in Hindi or English?'),
    ],
  ),
  Masterclass(
    id: 'mc_playbook',
    title: 'Pregnancy Playbook Workshop',
    price: '₹699',
    listChip: 'Great to catch up on',
    listDesc: 'The whole journey, trimester by trimester, with a practical action plan.',
    longDesc:
        'The whole pregnancy journey, trimester by trimester - what to expect, how to prepare in body and mind, the common fears addressed head-on, and a practical action plan you will actually use.',
    facts: [QuickFact('120 min', 'recorded'), QuickFact('On demand', 'anytime'), QuickFact('Forever', 'access')],
    coaches: [
      Coach('Deepti Sharma', 'Doula & birth coach',
          'Distils a whole pregnancy into a calm, do-this-next plan - warm, practical, and refreshingly non-preachy.'),
    ],
    learn: [
      'A month-by-month map of your pregnancy.',
      'How to prepare your body and your mind for each trimester.',
      'The fears no one talks about - named and addressed.',
      'A practical, week-by-week action plan.',
    ],
    testimonials: [
      Testimonial('"Finally something that told me what to actually do, not just what to worry about."',
          'Sneha K.', '18 weeks'),
    ],
    faqs: [
      Faq('When should I take this?',
          "It's built for early second trimester, but it's useful at any stage - you keep lifetime access."),
      Faq('Is there a workbook?'),
    ],
  ),
  Masterclass(
    id: 'mc_first100',
    title: 'The First 100 Days with Baby',
    price: '₹999',
    listChip: 'Coming up next',
    listChipIsCoral: true,
    listDesc: 'Newborn survival: feeding, sleep, and the fourth trimester.',
    longDesc:
        'Newborn survival, made calm: feeding rhythms, decoding those early sleep patterns, the fourth-trimester emotional rollercoaster, and setting up real help at home.',
    facts: [QuickFact('120 min', 'live'), QuickFact('Sat 26 Jul', '6:00 pm'), QuickFact('Forever', 'recording')],
    coaches: [
      Coach('Dr. Kabir Rao', 'Paediatrician · 12 years',
          'Guides new parents through the newborn weeks with steady, no-panic advice grounded in Indian homes.'),
      Coach('Deepti Sharma', 'Doula & birth coach',
          'Covers the mother\'s side of the fourth trimester - recovery, mood, and asking for help.'),
    ],
    learn: [
      'Reading your newborn\'s feeding and hunger cues.',
      'Realistic newborn sleep - and how to protect your own.',
      'The fourth trimester for you: recovery and mood.',
      'Setting up help in a joint family without friction.',
    ],
    faqs: [
      Faq('Is this before or after birth?',
          'Take it now to feel ready - most mothers watch it again in the first week with the recording.'),
    ],
  ),
  Masterclass(
    id: 'mc_bf',
    title: 'Breastfeeding Basics',
    price: '₹699',
    listDesc: 'Latch, supply, and the first week - before baby arrives.',
    longDesc:
        'Latch, supply, and the first tender week - everything you need to feel ready to breastfeed before baby arrives, from an IBCLC lactation expert.',
    facts: [QuickFact('75 min', 'live'), QuickFact('Wed 16 Jul', '7:00 pm'), QuickFact('Forever', 'recording')],
    coaches: [
      Coach('Sana Khan', 'Lactation Consultant · IBCLC',
          'An IBCLC who makes the first week feel far less daunting - practical, gentle, and judgement-free.'),
    ],
    learn: [
      'What a good latch looks and feels like.',
      'How milk supply really works - and how to protect it.',
      'Troubleshooting the tricky first week.',
      'Pumping and return-to-work basics.',
    ],
    faqs: [
      Faq('Can I take this before the baby is here?',
          'Yes - preparing antenatally is exactly when it helps most.'),
    ],
  ),
];

Masterclass? masterclassById(String id) {
  for (final m in kMasterclasses) {
    if (m.id == id) return m;
  }
  return null;
}

// ---- specialists (1:1 consultations) ----------------------------------------
class Specialist {
  const Specialist({
    required this.id,
    required this.icon,
    required this.role,
    required this.name,
    required this.cred,
    required this.fromPrice,
    required this.consultPrice,
    required this.rating,
    required this.desc,
    required this.about,
    required this.helps,
    required this.reviews,
    this.next,
    this.slots = const ['6:00 pm', '6:30 pm', '7:15 pm', '8:00 pm'],
  });

  final String id;
  final IconData icon;
  final String role; // "Obstetrician"
  final String name; // "Dr. Ananya Rao"
  final String cred; // "MBBS, MD (OB-GYN)" / "RD"
  final String fromPrice; // "from ₹999"
  final String consultPrice; // "₹999"
  final String rating; // "★ 4.9"
  final String desc; // one-liner on the list
  final String about;
  final List<String> helps;
  final List<Review> reviews;
  final String? next; // "Next: today 6pm"
  final List<String> slots;
}

const List<Specialist> kSpecialists = [
  Specialist(
    id: 'sp_ob',
    icon: Icons.medical_services_outlined,
    role: 'Obstetrician',
    name: 'Dr. Ananya Rao',
    cred: 'MBBS, MD (OB-GYN) · 15 yrs',
    fromPrice: 'from ₹999',
    consultPrice: '₹999',
    rating: '★ 4.9',
    next: 'Next: today 6pm',
    desc: "Your questions, a specialist's answer.",
    about:
        "Senior obstetrician at a leading Delhi hospital, with over 3,000 deliveries. Mothers describe her as calm, unhurried, and refreshingly straight-talking. She's the expert behind ParentVeda's Birth Confidence Masterclass.",
    helps: [
      'Reading and understanding your scan reports',
      'Birth-plan questions and delivery options',
      'Third-trimester aches, movements and warning signs',
    ],
    reviews: [
      Review('Priya S.', '30 weeks', '"She never rushed me. I finally understood my reports."'),
      Review('Neha R.', 'delivered Feb 2025', '"Calm and clear. Worth every rupee."'),
    ],
  ),
  Specialist(
    id: 'sp_nutrition',
    icon: Icons.restaurant_outlined,
    role: 'Prenatal Nutritionist',
    name: 'Ritu Malhotra',
    cred: 'RD · 10 yrs',
    fromPrice: 'from ₹599',
    consultPrice: '₹599',
    rating: '★ 4.8',
    desc: 'Eat right for you and baby.',
    about:
        'A registered dietitian who makes pregnancy nutrition simple and Indian-kitchen-friendly - no fads, no imported superfoods, just food that works for you and baby.',
    helps: [
      'Trimester-wise diet plans built around Indian meals',
      'Managing nausea, acidity and cravings',
      'Gestational-diabetes-friendly eating',
    ],
    reviews: [
      Review('Aditi V.', '22 weeks', '"Practical desi food swaps, not a boring diet chart."'),
      Review('Meghna T.', 'delivered Jan 2025', '"My sugar levels finally settled."'),
    ],
  ),
  Specialist(
    id: 'sp_lactation',
    icon: Icons.child_care_outlined,
    role: 'Lactation Consultant',
    name: 'Sana Khan',
    cred: 'IBCLC · 8 yrs',
    fromPrice: 'from ₹799',
    consultPrice: '₹799',
    rating: '★ 4.9',
    desc: 'Prepare to breastfeed before baby arrives.',
    about:
        'An IBCLC who helps you prepare to breastfeed before the baby arrives - so day one feels a little less daunting, and you know what a good start looks like.',
    helps: [
      'Getting ready to breastfeed before birth',
      'What a good latch looks and feels like',
      'Building and protecting your milk supply',
    ],
    reviews: [
      Review('Ishita R.', '36 weeks', '"I felt so much calmer about feeding after one call."'),
      Review('Pooja M.', 'delivered Mar 2025', '"Wish I had spoken to her even earlier."'),
    ],
  ),
  Specialist(
    id: 'sp_counsellor',
    icon: Icons.psychology_outlined,
    role: 'Prenatal Counsellor',
    name: 'Dr. Neha Verma',
    cred: 'Clinical Psychologist · 11 yrs',
    fromPrice: 'from ₹899',
    consultPrice: '₹899',
    rating: '★ 5.0',
    desc: 'Anxiety, mood, and the mental side of pregnancy.',
    about:
        'A clinical psychologist who holds space for the parts of pregnancy that are hard to say out loud - anxiety, mood swings, and the quiet weight of expectation.',
    helps: [
      'Pregnancy anxiety and intrusive worries',
      'Mood changes and low days',
      'Fears about birth and becoming a mother',
    ],
    reviews: [
      Review('Ritika S.', '28 weeks', '"She made me feel normal, not broken."'),
      Review('Kavita N.', 'delivered Feb 2025', '"Gentle, warm, and genuinely helpful."'),
    ],
  ),
  Specialist(
    id: 'sp_physio',
    icon: Icons.accessibility_new_rounded,
    role: 'Physiotherapist',
    name: 'Kavya Menon',
    cred: "Women's-health PT · 9 yrs",
    fromPrice: 'from ₹699',
    consultPrice: '₹699',
    rating: '★ 4.7',
    desc: 'Back pain, pelvic floor, posture.',
    about:
        'A women\'s-health physiotherapist who eases the aches pregnancy brings and prepares your body for birth and recovery - with simple moves you can actually keep up.',
    helps: [
      'Back, hip and pelvic-girdle pain',
      'Pelvic-floor prep for birth and recovery',
      'Safe posture and movement day to day',
    ],
    reviews: [
      Review('Divya P.', '31 weeks', '"My back pain eased within a week of her exercises."'),
      Review('Anjali K.', 'delivered Dec 2024', '"The pelvic-floor prep made recovery easier."'),
    ],
  ),
];

Specialist? specialistById(String id) {
  for (final s in kSpecialists) {
    if (s.id == id) return s;
  }
  return null;
}

// ---- cohort programs --------------------------------------------------------
class Cohort {
  const Cohort({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.desc,
    required this.whatsInside,
    this.start,
    this.seats,
    this.recommended,
    this.coachName,
    this.forWhen,
    this.schedule = const [],
    this.reviews = const [],
    this.featured = false,
  });

  final String id;
  final String name;
  final String price;
  final String duration; // "4 weeks"
  final String desc;
  final List<String> whatsInside;
  final String? start; // "starts Mon 6 Jul"
  final String? seats; // "32 of 100 seats left"
  final String? recommended; // "Recommended · 30–34 weeks"
  final String? coachName; // "Meera Nair"
  final String? forWhen; // list meta e.g. "for 6–13 weeks"
  final List<String> schedule; // week-by-week
  final List<Review> reviews;
  final bool featured;
}

const List<Cohort> kCohorts = [
  Cohort(
    id: 'ch_birthready',
    featured: true,
    name: 'Birth-Ready Bootcamp',
    price: '₹6,999',
    duration: '4 weeks',
    start: 'starts Mon 6 Jul',
    seats: '32 of 100 seats left',
    recommended: 'Recommended · 30–34 weeks',
    coachName: 'Meera Nair',
    desc:
        'Labour prep, breathing, and partner training - a live coach plus a peer group of mums due right around when you are.',
    whatsInside: [
      '4 live weekly sessions with Meera',
      'A small peer group of 30–34-week mums',
      'Weekly homework + a birth-plan template',
      'A private WhatsApp group',
    ],
    schedule: [
      'Week 1 · Understanding labour, start to finish',
      'Week 2 · Breathing and coping techniques',
      'Week 3 · Positions, movement and your partner',
      'Week 4 · Your birth plan and the big day',
    ],
    reviews: [
      Review('Shreya M.', 'delivered Apr 2025', '"The peer group got me through the last month."'),
    ],
  ),
  Cohort(
    id: 'ch_first_tri',
    name: 'First-Trimester Foundations',
    price: '₹4,999',
    duration: '3 weeks',
    forWhen: 'for 6–13 weeks',
    coachName: 'Deepti Sharma',
    desc: 'Steady your first trimester - manage symptoms, quiet the early fears, and start pregnancy in control.',
    whatsInside: [
      '3 live weekly sessions',
      'A first-trimester peer group',
      'Symptom + nutrition toolkit',
      'A private WhatsApp group',
    ],
    schedule: [
      'Week 1 · Symptoms and what helps',
      'Week 2 · Eating well when nothing appeals',
      'Week 3 · Early fears and your first scan',
    ],
  ),
  Cohort(
    id: 'ch_fit',
    name: 'Fit & Strong Pregnancy',
    price: '₹7,999',
    duration: '6 weeks',
    coachName: 'Sana Kapoor',
    desc: 'A guided prenatal fitness cohort - safe, progressive workouts scaled to your trimester by a certified coach.',
    whatsInside: [
      '6 weeks of guided workouts',
      'Trimester-safe progressions',
      'Live form checks with the coach',
      'A private WhatsApp group',
    ],
  ),
  Cohort(
    id: 'ch_fourth_tri',
    name: 'Fourth-Trimester Prep',
    price: '₹6,499',
    duration: '4 weeks',
    coachName: 'Dr. Kabir Rao',
    desc: 'Get ready for the newborn weeks before they arrive - feeding, sleep, recovery, and support at home.',
    whatsInside: [
      '4 live weekly sessions',
      'A due-soon peer group',
      'Newborn-setup checklist',
      'A private WhatsApp group',
    ],
  ),
];

Cohort? cohortById(String id) {
  for (final c in kCohorts) {
    if (c.id == id) return c;
  }
  return null;
}

// ---- yoga sessions ----------------------------------------------------------
//  Sessions are now month-tagged (month 1-9) so the Yoga screen can open on the
//  mother's current month and offer Month 1-9 tabs. The original untagged
//  five-session list is kept below (commented) for reference/revert.
class YogaSession {
  const YogaSession(this.id, this.title, this.duration, this.focus, this.blurb,
      {this.month = 1});
  final String id;
  final String title;
  final String duration; // "18 min"
  final String focus; // "opening"
  final String blurb;
  final int month; // 1-9, the pregnancy month this session is meant for
}

// // ---- original untagged list (pre month-tabs) -----------------------------
// const List<YogaSession> kYogaSessions = [
//   YogaSession('yg_hips', 'Hips & pelvis opener', '18 min', 'opening',
//       'Gentle openers to ease tightness in the hips and pelvis and make room as baby grows.'),
//   YogaSession('yg_back', 'Lower-back relief', '15 min', 'relief',
//       'Slow, supported movement to unload a tired lower back at the end of the day.'),
//   YogaSession('yg_breath', 'Breathing for labour', '12 min', 'breath',
//       'Practise the calm, steady breath that will carry you through contractions.'),
//   YogaSession('yg_evening', 'Gentle evening wind-down', '20 min', 'calm',
//       'A soothing sequence to quiet the body and mind before sleep.'),
//   YogaSession('yg_legsup', 'Legs-up restorative', '10 min', 'restore',
//       'A restful, restorative pose to ease swelling and reset your nervous system.'),
// ];

// TODO: month grouping below is a sensible approximation - once sessions carry a
// real trimester/week range from the content team, distribute them precisely.
const List<YogaSession> kYogaSessions = [
  // Month 1
  YogaSession('yg_m1_settle', 'Settling-in gentle flow', '12 min', 'grounding',
      'A soft, grounding sequence for the very first weeks - nothing strenuous, just breath and ease.',
      month: 1),
  YogaSession('yg_m1_breath', 'Breath awareness basics', '10 min', 'breath',
      'Meet the calm, steady breath you will build on all pregnancy long.',
      month: 1),
  // Month 2
  YogaSession('yg_m2_nausea', 'Ease for nausea days', '12 min', 'relief',
      'Slow, low movements and breathing to settle a queasy first-trimester tummy.',
      month: 2),
  YogaSession('yg_m2_stretch', 'Gentle full-body stretch', '15 min', 'opening',
      'Wake up stiff joints kindly, keeping everything within a safe early range.',
      month: 2),
  // Month 3
  YogaSession('yg_m3_hipsfound', 'Hip-opener foundations', '16 min', 'opening',
      'Begin the hip work that makes room as baby grows - built up slowly and safely.',
      month: 3),
  YogaSession('yg_m3_calm', 'Calm & steady wind-down', '14 min', 'calm',
      'A soothing close to the first trimester to quiet body and mind.',
      month: 3),
  // Month 4
  YogaSession('yg_m4_energy', 'Second-trimester energy flow', '18 min', 'strength',
      'As energy returns, a gently strengthening flow to feel capable and strong.',
      month: 4),
  YogaSession('yg_m4_posture', 'Posture & alignment', '15 min', 'align',
      'Simple work to carry a growing bump with an easy, supported posture.',
      month: 4),
  // Month 5
  YogaSession('yg_m5_back', 'Back-care essentials', '15 min', 'relief',
      'Supported movement to unload a tired lower back as your centre of gravity shifts.',
      month: 5),
  YogaSession('yg_m5_balance', 'Steady balance & core', '16 min', 'strength',
      'Gentle balance and deep-core work, adapted for the mid-pregnancy body.',
      month: 5),
  // Month 6
  YogaSession('yg_m6_hips', 'Hips & pelvis opener', '18 min', 'opening',
      'Gentle openers to ease tightness in the hips and pelvis and make room as baby grows.',
      month: 6),
  YogaSession('yg_m6_evening', 'Gentle evening wind-down', '20 min', 'calm',
      'A soothing sequence to quiet the body and mind before sleep.',
      month: 6),
  // Month 7
  YogaSession('yg_m7_hips', 'Third-trimester hip release', '18 min', 'opening',
      'Deeper, supported hip openers to ease the tightness that builds in the third trimester.',
      month: 7),
  YogaSession('yg_m7_back', 'Lower-back relief', '15 min', 'relief',
      'Slow, supported movement to unload a tired lower back at the end of the day.',
      month: 7),
  YogaSession('yg_m7_breath', 'Breathing for labour', '12 min', 'breath',
      'Practise the calm, steady breath that will carry you through contractions.',
      month: 7),
  // Month 8
  YogaSession('yg_m8_legsup', 'Legs-up restorative', '10 min', 'restore',
      'A restful, restorative pose to ease swelling and reset your nervous system.',
      month: 8),
  YogaSession('yg_m8_pelvic', 'Pelvic-floor & birth prep', '16 min', 'prepare',
      'Gentle pelvic-floor awareness and opening to prepare your body for birth.',
      month: 8),
  YogaSession('yg_m8_evening', 'Gentle evening wind-down', '20 min', 'calm',
      'A soothing sequence to quiet the body and mind before sleep.',
      month: 8),
  // Month 9
  YogaSession('yg_m9_positions', 'Labour positions practice', '18 min', 'prepare',
      'Rehearse the positions and swaying that help labour progress and ease pain.',
      month: 9),
  YogaSession('yg_m9_breath', 'Final breathing rehearsal', '12 min', 'breath',
      'One more calm run-through of the breath that will carry you through the big day.',
      month: 9),
  YogaSession('yg_m9_restore', 'Deep rest & restore', '14 min', 'restore',
      'A soft, restorative close for the final stretch - rest, release, and wait well.',
      month: 9),
];

/// Sessions for a given pregnancy month (1-9).
List<YogaSession> yogaSessionsForMonth(int month) =>
    kYogaSessions.where((y) => y.month == month).toList();

// ---- birthing classes -------------------------------------------------------
class BirthingClass {
  const BirthingClass(this.number, this.title, this.duration, this.blurb, {this.free = false});
  final int number;
  final String title;
  final String duration; // "22 min video"
  final String blurb;
  final bool free;
}

const List<BirthingClass> kBirthingClasses = [
  BirthingClass(1, 'The stages of labour, demystified', '22 min video',
      'A calm walkthrough of early, active and transition labour - so nothing takes you by surprise.',
      free: true),
  BirthingClass(2, 'Breathing & relaxation that actually works', '18 min video',
      'The breathing and relaxation tools that genuinely help when contractions build.'),
  BirthingClass(3, 'Positions & movement for an easier labour', '20 min video',
      'How to move, sway and rest in positions that help labour progress and ease pain.'),
  BirthingClass(4, 'Pain relief - natural, epidural & C-section', '24 min video',
      'An honest look at every pain-relief option, so your choices are informed, not fearful.'),
  BirthingClass(5, 'Your partner as birth support', '16 min video',
      'Exactly how your partner can help - from counter-pressure to knowing when to speak up.'),
  BirthingClass(6, 'The golden hour - the first hour after birth', '15 min video',
      'Skin-to-skin, the first feed, and what really happens in the precious first hour.'),
];

// ---- helpers used by detail screens -----------------------------------------
Color chipColorFor(bool coral) => coral ? kCoral : kPurple;
Color chipBgFor(bool coral) => coral ? kCoralTint : kPanel;

// =============================================================================
//  Courses & Cohorts - unified "V2" learning model (mirrors the post-pregnancy
//  merged "Courses & Masterclasses" experience, adapted to pregnancy data + the
//  mother/purple theme). One `PrepProgram` list folds recorded courses, live
//  cohorts and masterclasses into a single searchable/filterable catalogue with
//  a shared rich detail page and business-logic CTA. It reuses the existing
//  masterclass/cohort content (kMasterclasses / kCohorts) so nothing is
//  duplicated by hand; the old standalone screens are kept for revert.
// =============================================================================

// accent palette for program thumbnails/details
const Color _pViolet = kPurple;
const Color _pRose = kCoral;
const Color _pAmber = Color(0xFFC98A2B);
const Color _pBlue = Color(0xFF3E6DA6);
const Color _pTeal = Color(0xFF2E8B8B);
const Color _pPlum = Color(0xFF8E4585);

/// The three kinds a mother can learn from - the merge of the old tabs.
enum PrepKind { course, cohort, masterclass }

extension PrepKindX on PrepKind {
  String get label => switch (this) {
        PrepKind.course => 'Course',
        PrepKind.cohort => 'Live cohort',
        PrepKind.masterclass => 'Masterclass',
      };
  String get filterLabel => switch (this) {
        PrepKind.course => 'Courses',
        PrepKind.cohort => 'Cohorts',
        PrepKind.masterclass => 'Masterclasses',
      };
}

/// Where a program sits in its selling / delivery lifecycle. Drives the CTA.
enum PrepStatus { reserveOpen, available, ongoing, completed }

/// One self-paced lesson inside a recorded course.
class PrepLesson {
  const PrepLesson(this.title, this.minutes, {this.locked = false});
  final String title;
  final int minutes;
  final bool locked;
}

/// One live block in a schedule (a cohort week / a masterclass evening).
class PrepSession {
  const PrepSession({required this.label, required this.title, this.when = '', this.points = const []});
  final String label; // "Week 1" / "Live evening"
  final String title;
  final String when; // "Mon 21 & Thu 24 Jul · 8-9pm"
  final List<String> points;
}

class PrepProgram {
  const PrepProgram({
    required this.id,
    required this.kind,
    required this.instructorName,
    required this.instructorRole,
    required this.instructorBio,
    required this.title,
    required this.subtitle,
    required this.topics,
    required this.accent,
    required this.price,
    required this.status,
    this.priceNote = 'free on ParentVeda+',
    this.isLiveScheduled = false,
    this.startLabel,
    this.sessionTimes = const [],
    this.sessions = const [],
    this.seatsLeft,
    this.lessons = const [],
    this.durationLabel = '',
    this.about = '',
    this.rating = 4.9,
    this.reviewsLabel = '',
    this.covers = const [],
    this.takeaways = const [],
    this.reviews = const [],
    this.featured = false,
    this.recency = 0,
  });

  final String id;
  final PrepKind kind;
  final String instructorName;
  final String instructorRole;
  final String instructorBio;
  final String title;
  final String subtitle;
  final List<String> topics;
  final Color accent;
  final String price;
  final String priceNote;
  final PrepStatus status;
  final bool isLiveScheduled;
  final String? startLabel;
  final List<String> sessionTimes;
  final List<PrepSession> sessions;
  final int? seatsLeft;
  final List<PrepLesson> lessons;
  final String durationLabel;
  final String about;
  final double rating;
  final String reviewsLabel;
  final List<String> covers;
  final List<String> takeaways;
  final List<Review> reviews;
  final bool featured;
  final int recency;

  bool get isCohort => kind == PrepKind.cohort;
  bool get isLive => kind == PrepKind.cohort || isLiveScheduled;

  String get heroTag {
    if (kind == PrepKind.cohort) return startLabel ?? 'Live cohort';
    if (isLiveScheduled) return startLabel ?? 'Live';
    return durationLabel.isNotEmpty ? durationLabel : 'Recorded';
  }
}

/// The resolved primary action for a program, so no screen hand-rolls the rules.
class PrepCta {
  const PrepCta(this.label, {this.enabled = true, this.watch = false, this.note});
  final String label;
  final bool enabled;
  final bool watch; // "Watch now" = play flow, not a pay sheet
  final String? note;
}

/// The single source of truth for "what button does this program show".
PrepCta ctaForPrep(PrepProgram p) {
  switch (p.kind) {
    case PrepKind.cohort:
      switch (p.status) {
        case PrepStatus.reserveOpen:
          return const PrepCta('Join the next cohort', note: 'Small group · a real coach');
        case PrepStatus.available:
          return const PrepCta('Start', note: "You're in - your cohort has begun");
        case PrepStatus.ongoing:
          return const PrepCta('Cohort in progress', enabled: false, note: 'This run has started - reserve the next one');
        case PrepStatus.completed:
          return const PrepCta('View recordings', watch: true, note: 'Yours to keep');
      }
    case PrepKind.masterclass:
      if (p.isLiveScheduled) {
        switch (p.status) {
          case PrepStatus.reserveOpen:
            return const PrepCta('Reserve a seat', note: 'Live seat - the recording is yours forever');
          case PrepStatus.available:
          case PrepStatus.ongoing:
            return const PrepCta('Join live', note: 'Recording lands in your library');
          case PrepStatus.completed:
            return const PrepCta('Buy recorded', note: 'Watch anytime, yours forever');
        }
      }
      switch (p.status) {
        case PrepStatus.reserveOpen:
          return const PrepCta('Reserve', note: 'Pre-book before it opens');
        case PrepStatus.available:
        case PrepStatus.ongoing:
        case PrepStatus.completed:
          return const PrepCta('Buy', note: 'Recording lands in your library');
      }
    case PrepKind.course:
      switch (p.status) {
        case PrepStatus.reserveOpen:
          return const PrepCta('Reserve', note: 'Notify me when it opens');
        case PrepStatus.available:
        case PrepStatus.ongoing:
        case PrepStatus.completed:
          return const PrepCta('Start watching', watch: true, note: 'Free with ParentVeda+ · lifetime access');
      }
  }
}

/// The common topic vocabulary backing the clickable filter chips.
const List<String> kPrepTopics = [
  'Birth & Labour',
  'Breathing',
  'Nutrition',
  'Breastfeeding',
  'Newborn',
  'Fitness',
  'Mind & Mood',
  'First Trimester',
];

// ---- new recorded courses (authored) ----------------------------------------
const List<PrepProgram> _kPrepCourses = [
  PrepProgram(
    id: 'course_pregnancy_guide',
    kind: PrepKind.course,
    instructorName: 'Dr. Ananya Rao',
    instructorRole: 'Obstetrician · 15 yrs',
    instructorBio:
        "Senior obstetrician with 3,000+ deliveries. She scripts and hosts ParentVeda's flagship guide in calm, plain language.",
    title: 'The Complete Pregnancy Guide',
    subtitle: 'Week 1 to the first cry - every stage, taught properly, once.',
    topics: ['First Trimester', 'Birth & Labour', 'Newborn'],
    accent: _pViolet,
    price: '₹2,999',
    status: PrepStatus.available,
    durationLabel: '80+ lessons',
    about:
        'A documentary-style course that unlocks as your pregnancy grows and stays yours for life. You only ever see the lessons for your current stage; earlier and later ones are a tap away. Told through ParentVeda\'s own animated guides, scripted from research and reviewed by obstetricians.',
    rating: 4.9,
    reviewsLabel: '1,240 mothers',
    lessons: [
      PrepLesson('Your third trimester, week by week', 16),
      PrepLesson('Reading your body\'s labour signals', 18),
      PrepLesson('Packing your hospital bag, calmly', 12),
      PrepLesson('The first 48 hours with baby', 20, locked: true),
    ],
    covers: [
      'A month-by-month map of your whole pregnancy.',
      'What to expect - and prepare - at each stage.',
      'The warning signs that genuinely need a call.',
      'A gentle on-ramp into the newborn weeks.',
    ],
    reviews: [
      Review('Sneha K.', '28 weeks', '"The one place that told me what to actually do, stage by stage."'),
    ],
    featured: true,
    recency: 100,
  ),
  PrepProgram(
    id: 'course_birthprep',
    kind: PrepKind.course,
    instructorName: 'Meera Nair',
    instructorRole: 'Childbirth educator',
    instructorBio: 'A certified, OB-reviewed childbirth educator who has prepared thousands of mothers for the big day.',
    title: 'Birth Prep Essentials',
    subtitle: 'A calm, self-paced walkthrough of everything the big day asks of you.',
    topics: ['Birth & Labour', 'Breathing'],
    accent: _pBlue,
    price: '₹1,499',
    status: PrepStatus.available,
    durationLabel: '6 lessons · ~90 min',
    about:
        'The self-paced companion to our live Birthing Classes - the stages of labour, breathing and positions, pain-relief options and the golden hour, all in short lessons you can watch and rewatch at your own pace.',
    rating: 4.8,
    reviewsLabel: '910 mothers',
    lessons: [
      PrepLesson('The stages of labour, demystified', 22),
      PrepLesson('Breathing & relaxation that works', 18),
      PrepLesson('Positions & movement for an easier labour', 20),
      PrepLesson('Pain relief - natural, epidural & C-section', 24, locked: true),
    ],
    covers: [
      'A clear, unhurried picture of each stage of labour.',
      'Breathing you can actually use through a contraction.',
      'The honest pros and cons of every pain-relief option.',
      'What really happens in the golden first hour.',
    ],
    recency: 92,
  ),
  PrepProgram(
    id: 'course_trimester_fit',
    kind: PrepKind.course,
    instructorName: 'Sana Kapoor',
    instructorRole: 'Certified prenatal instructor',
    instructorBio: 'A certified prenatal fitness instructor whose sessions are scaled safely to every trimester.',
    title: 'Trimester-Safe Fitness',
    subtitle: 'Feel strong through pregnancy with movement scaled to your stage.',
    topics: ['Fitness'],
    accent: _pTeal,
    price: '₹1,299',
    status: PrepStatus.available,
    durationLabel: '5 lessons · ~60 min',
    about:
        'A short, practical course on staying safely strong and mobile through pregnancy - what to do, what to skip, and how to scale everything to how you feel that day.',
    rating: 4.8,
    reviewsLabel: '540 mothers',
    lessons: [
      PrepLesson('Safe strength, trimester by trimester', 14),
      PrepLesson('Mobility for a changing body', 12),
      PrepLesson('Core & pelvic floor, done right', 16),
      PrepLesson('Rest, recovery and warning signs', 10),
    ],
    covers: [
      'What movement is safe - and what to skip - each trimester.',
      'Core and pelvic-floor work that helps birth and recovery.',
      'How to scale everything to your energy that day.',
    ],
    recency: 84,
  ),
];

// ---- per-item mapping meta (topics/accent/status the old models don't carry) -
const Map<String, ({List<String> topics, Color accent, PrepStatus status, bool live, int recency})> _mcMeta = {
  'mc_birth': (topics: ['Birth & Labour', 'Breathing'], accent: _pRose, status: PrepStatus.reserveOpen, live: true, recency: 99),
  'mc_first100': (topics: ['Newborn'], accent: _pAmber, status: PrepStatus.reserveOpen, live: true, recency: 82),
  'mc_bf': (topics: ['Breastfeeding', 'Newborn'], accent: _pTeal, status: PrepStatus.reserveOpen, live: true, recency: 80),
  'mc_playbook': (topics: ['First Trimester'], accent: _pViolet, status: PrepStatus.available, live: false, recency: 70),
};

const Map<String, ({List<String> topics, Color accent, PrepStatus status, int seatsLeft, int recency})> _chMeta = {
  'ch_birthready': (topics: ['Birth & Labour', 'Breathing'], accent: _pBlue, status: PrepStatus.reserveOpen, seatsLeft: 32, recency: 98),
  'ch_first_tri': (topics: ['First Trimester'], accent: _pAmber, status: PrepStatus.reserveOpen, seatsLeft: 14, recency: 74),
  'ch_fit': (topics: ['Fitness'], accent: _pTeal, status: PrepStatus.reserveOpen, seatsLeft: 20, recency: 66),
  'ch_fourth_tri': (topics: ['Newborn', 'Breastfeeding'], accent: _pPlum, status: PrepStatus.reserveOpen, seatsLeft: 18, recency: 60),
};

PrepProgram _fromMasterclass(Masterclass m) {
  final meta = _mcMeta[m.id]!;
  final coach = m.coaches.isNotEmpty ? m.coaches.first : const Coach('Your expert', 'ParentVeda expert', '');
  final when = m.facts.length >= 2 ? '${m.facts[1].big} · ${m.facts[1].small}' : null;
  final duration = m.facts.isNotEmpty ? '${m.facts.first.big} ${m.facts.first.small}' : '';
  return PrepProgram(
    id: 'prog_${m.id}',
    kind: PrepKind.masterclass,
    instructorName: coach.name,
    instructorRole: coach.role,
    instructorBio: coach.bio,
    title: m.title,
    subtitle: m.listDesc,
    topics: meta.topics,
    accent: meta.accent,
    price: m.price,
    status: meta.status,
    isLiveScheduled: meta.live,
    startLabel: meta.live && when != null ? 'LIVE · $when' : null,
    sessionTimes: meta.live && when != null ? [when] : const [],
    sessions: meta.live
        ? [
            PrepSession(
              label: 'Live evening',
              title: 'One focused sitting + live Q&A',
              when: when ?? '',
              points: m.learn.take(3).toList(),
            ),
          ]
        : const [],
    durationLabel: duration,
    about: m.longDesc,
    rating: 4.9,
    reviewsLabel: '${(m.testimonials.length + 3) * 210} mothers',
    covers: m.learn,
    reviews: m.testimonials.map((t) => Review(t.who, t.when, t.quote)).toList(),
    featured: m.featured,
    recency: meta.recency,
  );
}

PrepProgram _fromCohort(Cohort c) {
  final meta = _chMeta[c.id]!;
  return PrepProgram(
    id: 'prog_${c.id}',
    kind: PrepKind.cohort,
    instructorName: c.coachName ?? 'Your coach',
    instructorRole: 'Childbirth educator',
    instructorBio: 'Leads every live session and the private group.',
    title: c.name,
    subtitle: c.desc,
    topics: meta.topics,
    accent: meta.accent,
    price: c.price,
    priceNote: 'or ParentVeda+',
    status: meta.status,
    startLabel: c.start ?? c.forWhen,
    seatsLeft: meta.seatsLeft,
    sessionTimes: const [],
    sessions: [
      for (int i = 0; i < c.schedule.length; i++)
        PrepSession(label: 'Week ${i + 1}', title: c.schedule[i].replaceFirst(RegExp(r'^Week \d+ · '), '')),
    ],
    durationLabel: '${c.duration} · live',
    about: c.desc,
    rating: 4.9,
    reviewsLabel: '${meta.seatsLeft * 20} mothers',
    covers: c.whatsInside,
    takeaways: c.whatsInside,
    reviews: c.reviews,
    featured: c.featured,
    recency: meta.recency,
  );
}

/// The full unified catalogue, built once from courses + masterclasses + cohorts.
final List<PrepProgram> kPrepPrograms = <PrepProgram>[
  ..._kPrepCourses,
  for (final m in kMasterclasses)
    if (_mcMeta.containsKey(m.id)) _fromMasterclass(m),
  for (final c in kCohorts)
    if (_chMeta.containsKey(c.id)) _fromCohort(c),
];

/// The catalogue in display order (featured first, then by recency).
List<PrepProgram> prepCatalogue() {
  final list = [...kPrepPrograms];
  list.sort((a, b) {
    if (a.featured != b.featured) return a.featured ? -1 : 1;
    return b.recency.compareTo(a.recency);
  });
  return list;
}

/// Filter the catalogue by an optional kind, topic and free-text query.
List<PrepProgram> filterPrograms({PrepKind? kind, String? topic, String? query}) {
  final q = (query ?? '').trim().toLowerCase();
  return prepCatalogue().where((p) {
    if (kind != null && p.kind != kind) return false;
    if (topic != null && !p.topics.contains(topic)) return false;
    if (q.isNotEmpty) {
      final hay = [p.title, p.subtitle, p.instructorName, ...p.topics].join(' ').toLowerCase();
      if (!hay.contains(q)) return false;
    }
    return true;
  }).toList();
}

PrepProgram? programById(String id) {
  for (final p in kPrepPrograms) {
    if (p.id == id) return p;
  }
  return null;
}

// =============================================================================
//  Nutrition funnel - Assessment -> Recommended plans -> Trailer -> Book ->
//  Expert Consultation -> Personalized Diet Plan. Data for the plan cards and
//  the assessment options. Real plans/backends don't exist yet, so these are
//  tasteful placeholders that make the whole click-through work end to end.
// =============================================================================

/// One assessment answer option (a selectable chip).
class NutriOption {
  const NutriOption(this.id, this.label);
  final String id;
  final String label;
}

const List<NutriOption> kNutriTrimesters = [
  NutriOption('t1', 'First trimester'),
  NutriOption('t2', 'Second trimester'),
  NutriOption('t3', 'Third trimester'),
];

const List<NutriOption> kNutriGoals = [
  NutriOption('nausea', 'Manage nausea'),
  NutriOption('gd', 'Gestational diabetes'),
  NutriOption('weight', 'Healthy weight gain'),
  NutriOption('energy', 'More energy'),
  NutriOption('growth', "Baby's growth"),
];

const List<NutriOption> kNutriDiets = [
  NutriOption('veg', 'Vegetarian'),
  NutriOption('nonveg', 'Non-vegetarian'),
  NutriOption('egg', 'Eggetarian'),
  NutriOption('vegan', 'Vegan'),
];

class NutritionPlan {
  const NutritionPlan({
    required this.id,
    required this.name,
    required this.tagline,
    required this.forGoals,
    required this.accent,
    required this.weeks,
    required this.highlights,
    required this.sampleDay,
    this.price = '₹1,499',
    this.priceNote = 'free on ParentVeda+',
  });

  final String id;
  final String name;
  final String tagline;
  final List<String> forGoals; // NutriOption goal ids this plan best suits
  final Color accent;
  final String weeks; // "4-week plan"
  final List<String> highlights;
  final List<({String meal, String food})> sampleDay;
  final String price;
  final String priceNote;
}

const List<NutritionPlan> kNutritionPlans = [
  NutritionPlan(
    id: 'plan_settle',
    name: 'Settle & Nourish',
    tagline: 'Gentle, tummy-friendly eating for queasy days.',
    forGoals: ['nausea', 'energy'],
    accent: _pAmber,
    weeks: '4-week plan',
    highlights: [
      'Small, frequent meals that calm nausea',
      'Iron and folate without the heaviness',
      'Desi swaps for when nothing appeals',
    ],
    sampleDay: [
      (meal: 'Early morning', food: 'Soaked almonds + a dry toast'),
      (meal: 'Breakfast', food: 'Vegetable poha with lemon'),
      (meal: 'Lunch', food: 'Khichdi with curd and a little ghee'),
      (meal: 'Evening', food: 'Coconut water + roasted makhana'),
      (meal: 'Dinner', food: 'Moong dal, soft rice, steamed veg'),
    ],
  ),
  NutritionPlan(
    id: 'plan_balance',
    name: 'Balanced Bump',
    tagline: 'Steady energy and healthy weight gain, Indian-first.',
    forGoals: ['weight', 'energy', 'growth'],
    accent: _pViolet,
    weeks: '6-week plan',
    highlights: [
      'Balanced macros built around Indian meals',
      'Protein at every meal for baby\'s growth',
      'Smart snacks that keep energy even',
    ],
    sampleDay: [
      (meal: 'Breakfast', food: 'Besan chilla + curd + fruit'),
      (meal: 'Mid-morning', food: 'A fruit + a handful of nuts'),
      (meal: 'Lunch', food: '2 rotis, dal, sabzi, salad, curd'),
      (meal: 'Evening', food: 'Sprouts chaat or paneer tikka'),
      (meal: 'Dinner', food: 'Rice/roti, rajma, greens'),
    ],
  ),
  NutritionPlan(
    id: 'plan_sugar',
    name: 'Sugar-Smart',
    tagline: 'Gestational-diabetes-friendly eating that still tastes like home.',
    forGoals: ['gd', 'weight'],
    accent: _pTeal,
    weeks: '8-week plan',
    highlights: [
      'Low-GI meals that keep sugars steady',
      'Portion and pairing rules made simple',
      'Sweet cravings handled the smart way',
    ],
    sampleDay: [
      (meal: 'Breakfast', food: 'Vegetable oats + boiled egg / paneer'),
      (meal: 'Mid-morning', food: 'A small guava or apple'),
      (meal: 'Lunch', food: 'Millet roti, dal, lots of sabzi, salad'),
      (meal: 'Evening', food: 'Buttermilk + roasted chana'),
      (meal: 'Dinner', food: 'Grilled paneer/chicken + veg, no rice'),
    ],
  ),
];

/// Recommend plans for the chosen goal (falls back to all). Simple placeholder
/// scoring - a real engine would weigh trimester, diet and history too.
List<NutritionPlan> recommendPlans({String? goalId}) {
  if (goalId == null) return kNutritionPlans;
  final matched = kNutritionPlans.where((p) => p.forGoals.contains(goalId)).toList();
  return matched.isEmpty ? kNutritionPlans : matched;
}
