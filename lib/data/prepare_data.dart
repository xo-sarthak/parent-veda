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

// ---- prenatal yoga sessions -------------------------------------------------
class YogaSession {
  const YogaSession(this.id, this.title, this.duration, this.focus, this.blurb);
  final String id;
  final String title;
  final String duration; // "18 min"
  final String focus; // "opening"
  final String blurb;
}

const List<YogaSession> kYogaSessions = [
  YogaSession('yg_hips', 'Hips & pelvis opener', '18 min', 'opening',
      'Gentle openers to ease tightness in the hips and pelvis and make room as baby grows.'),
  YogaSession('yg_back', 'Lower-back relief', '15 min', 'relief',
      'Slow, supported movement to unload a tired lower back at the end of the day.'),
  YogaSession('yg_breath', 'Breathing for labour', '12 min', 'breath',
      'Practise the calm, steady breath that will carry you through contractions.'),
  YogaSession('yg_evening', 'Gentle evening wind-down', '20 min', 'calm',
      'A soothing sequence to quiet the body and mind before sleep.'),
  YogaSession('yg_legsup', 'Legs-up restorative', '10 min', 'restore',
      'A restful, restorative pose to ease swelling and reset your nervous system.'),
];

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
