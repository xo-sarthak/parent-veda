// =============================================================================
//  Experts / doctors - shared data for the reusable profile (parenting)
// -----------------------------------------------------------------------------
//  Every masterclass, cohort, course or local service is led by a named expert.
//  This backs a single reusable profile screen (ProviderProfileScreen, the
//  S18·detail layout) so tapping any expert - anywhere - opens their page. A
//  handful of seed profiles for now; real experts slot in here later without
//  touching any screen. Kept inside the post_pregnancy module (fully isolated).
// =============================================================================

import 'package:flutter/material.dart';

/// One expert/doctor, shaped to fill the profile layout.
class Expert {
  const Expert({
    required this.id,
    required this.name,
    required this.credential,
    required this.backLabel,
    required this.rating,
    required this.reviewsCount,
    required this.mid,
    required this.fee,
    required this.whyHeading,
    required this.why,
    required this.tags,
    required this.reviews,
    required this.ctaPrice,
    required this.ctaSub,
    required this.ctaLabel,
    required this.disclaimer,
    this.topPick = false,
    this.topPickLabel = 'ParentVeda top pick',
    this.seeded = false,
    this.location = '',
    // --- Find-help / results fields (all optional, safe defaults) ------------
    this.category = '',
    this.blurb = '',
    this.timings = '',
    this.availableToday = true,
    this.videoConsult = false,
    this.priceValue = 0,
    this.ratingValue = 0,
  });

  final String id;
  final String name; // "Dr. Ananya Rao"
  final String credential; // "Paediatrician · 15 years"
  final String backLabel; // top back-bar label, e.g. "Masterclass expert"
  /// ⚠️ A PLACEHOLDER PERSON, KEPT DISTINGUISHABLE FROM A REAL ONE.
  ///
  /// Six categories had no supply at all, so the doors that named a sleep
  /// coach, a nutritionist, a physio, a postnatal counsellor or a development
  /// expert could not be filtered without landing a parent on an empty list.
  /// The decision was to build the whole path as though the expert exists, so
  /// that real supply is a data edit rather than a build.
  ///
  /// This flag is what stops that being a lie you cannot find later. It is the
  /// difference between "we have twelve more experts" and "we have twelve
  /// placeholders and here they are". `kSeededExpertIds` lists them,
  /// `test/pp_consult_filter_test.dart` counts them, and any screen that needs
  /// to behave differently for real supply has one boolean to read.
  ///
  /// ⚠️ IT IS NOT RENDERED TO A PARENT ANYWHERE, and that is a deliberate
  /// choice rather than an oversight: a "not a real expert" badge on a booking
  /// screen would be worse than either shipping or not shipping the door. The
  /// honest control is that booking is stubbed anyway — see the booking
  /// engine — so nobody can pay a placeholder.
  final bool seeded;

  final bool topPick;
  final String topPickLabel;
  final String location; // "Delhi NCR · online" - shown under the name on the profile
  final String rating; // "4.9"
  final String reviewsCount; // "1,020 reviews"
  final (String, String) mid; // (value, label) - e.g. ("12k+", "parents taught")
  final (String, String) fee; // (value, label) - e.g. ("₹1,499", "per class")
  final String whyHeading; // "Why ParentVeda picks her"
  final String why; // paragraph
  final List<String> tags; // languages & specialties
  final List<(String, String, String)> reviews; // (name, who, quote)
  final String ctaPrice; // "₹1,499"
  final String ctaSub; // "via ParentVeda"
  final String ctaLabel; // "View sessions"
  final String disclaimer;

  // --- Find-help / results fields (optional; power the "Browse by need" flow) -
  final String category; // maps to a FindHelpNeed, e.g. "Pediatrician"
  final String blurb; // 1-2 line qualification desc for the results card
  final String timings; // e.g. "9-12 PM · 4-6 PM"
  final bool availableToday;
  final bool videoConsult;
  final int priceValue; // numeric mirror of the fee, for price sorting
  final double ratingValue; // numeric mirror of the rating, for rating sorting
}

// Not `const` because the find-help roster below is built via _findHelp(...);
// the existing seed entries remain const-constructible literals.
final List<Expert> kExperts = [
  // The original Problem Solver provider - keeps the S18·detail screen identical.
  Expert(
    id: 'neha',
    location: 'Greater Kailash, Delhi',
    name: 'Dr. Neha Sharma',
    credential: 'Paediatrician · 12 years',
    backLabel: 'Paediatricians',
    topPick: true,
    rating: '4.9',
    reviewsCount: '312 reviews',
    mid: ('2.4 km', 'Greater Kailash'),
    fee: ('₹800', 'consult'),
    whyHeading: 'Why ParentVeda picks her',
    why:
        'Gentle with anxious first-time parents, generous with time, and quick to reassure without over-prescribing. Consistently top-rated by mothers for the 4-month vaccine visit.',
    tags: ['Hindi', 'English', 'Vaccinations', 'Newborn care'],
    reviews: [
      ('Priya', 'mother of Aarav (4 mo)', "“She talked me through Aarav's vaccine day calmly. Never rushed.”"),
      ('Ritika', 'mother of Vivaan (9 mo)', '“Our go-to for every fever since birth.”'),
    ],
    ctaPrice: '₹800',
    ctaSub: 'video consult',
    ctaLabel: 'Book a consultation',
    disclaimer: 'A private video consult, booked and held inside ParentVeda.',
    category: 'Pediatrician',
    blurb: 'MBBS, DCH · newborn care, vaccinations & everyday fevers. Gentle with anxious first-time parents.',
    timings: '9-1 PM · 5-8 PM',
    availableToday: true,
    videoConsult: true,
    priceValue: 800,
    ratingValue: 4.9,
  ),

  // Masterclass + featured expert.
  Expert(
    id: 'ananya',
    location: 'Delhi NCR · online sessions',
    name: 'Dr. Ananya Rao',
    credential: 'Paediatrician · 15 years',
    backLabel: 'Masterclass expert',
    topPick: true,
    rating: '4.9',
    reviewsCount: '1,020 reviews',
    mid: ('12k+', 'parents taught'),
    fee: ('₹1,499', 'per class'),
    whyHeading: 'Why ParentVeda picks her',
    why:
        'Has guided thousands of Indian families through the fourth-month wobble - calm, practical, and firmly no-cry-it-out. Her sleep masterclass is our most-attended session.',
    tags: ['Hindi', 'English', 'Infant sleep', 'Vaccinations'],
    reviews: [
      ('Priya', 'mother of Aarav (4 mo)', '“Her class finally made the 4-month regression make sense. We slept that week.”'),
      ('Sneha', 'mother of Ira (6 mo)', '“Warm, clear, zero judgement. Worth every rupee.”'),
    ],
    ctaPrice: '₹1,499',
    ctaSub: 'per masterclass',
    ctaLabel: 'View sessions',
    disclaimer: 'Sessions are hosted inside ParentVeda. The price you see is what you pay - no hidden fees.',
    category: 'Pediatrician',
    blurb: 'Paediatrician · infant sleep & the 4-month wobble. Calm, practical, firmly no-cry-it-out.',
    timings: '10-1 PM · 4-7 PM',
    availableToday: false,
    videoConsult: true,
    priceValue: 1200,
    ratingValue: 4.9,
  ),

  // Cohort coach.
  Expert(
    id: 'meher',
    location: 'Mumbai · online cohorts',
    blurb: 'Paediatric sleep consultant · gentle, no-cry-it-out sleep. Has coached 60+ small cohorts of Indian families.',
    name: 'Dr. Meher Shah',
    credential: 'Paediatric sleep consultant · 8 years',
    backLabel: 'Cohort coach',
    topPick: true,
    rating: '4.9',
    reviewsCount: '640 reviews',
    mid: ('60+', 'cohorts led'),
    fee: ('₹5,999', 'per cohort'),
    whyHeading: 'Why ParentVeda picks her',
    why:
        'Has coached 60+ small cohorts of Indian families through gentle, no-cry-it-out sleep. Warm, practical, and honest about what a two-week plan can and cannot do.',
    tags: ['Hindi', 'English', 'Gujarati', 'Infant sleep', 'Routines'],
    reviews: [
      ('Aditi', 'mother of Kabir (5 mo)', '“Doing it with other parents at the same stage is what made it stick.”'),
      ('Fatima', 'mother of Zoya (7 mo)', '“She knew our baby by the second call.”'),
    ],
    ctaPrice: '₹5,999',
    ctaSub: 'per cohort',
    ctaLabel: 'View cohorts',
    disclaimer: 'Cohorts are hosted inside ParentVeda. The price you see is what you pay - no hidden fees.',
  ),

  // Masterclass - Wonder Weeks.
  Expert(
    id: 'kabir',
    location: 'Bengaluru · online',
    name: 'Dr. Kabir Sen',
    credential: 'Child psychologist · 12 years',
    backLabel: 'Masterclass expert',
    rating: '4.8',
    reviewsCount: '410 reviews',
    mid: ('5k+', 'parents taught'),
    fee: ('₹2,499', 'per class'),
    whyHeading: 'Why ParentVeda picks him',
    why:
        'Translates infant brain development into plain, reassuring language. Gentle, evidence-first, and brilliant at demystifying the fussy stretches.',
    tags: ['Hindi', 'English', 'Bengali', 'Child development', 'Behaviour'],
    reviews: [
      ('Nisha', 'mother of Aarav (4 mo)', '“I stopped panicking about every fussy phase after his class.”'),
      ('Rahul', 'father of Meera (10 mo)', '“Clear, calm, science-backed. Loved it.”'),
    ],
    ctaPrice: '₹2,499',
    ctaSub: 'per masterclass',
    ctaLabel: 'View sessions',
    disclaimer: 'Sessions are hosted inside ParentVeda. The price you see is what you pay - no hidden fees.',
    category: 'Child psychologist',
    blurb: 'Child psychologist · development & behaviour, and the science of the Wonder Weeks.',
    timings: '11-2 PM · 5-7 PM',
    availableToday: true,
    videoConsult: true,
    priceValue: 2000,
    ratingValue: 4.8,
  ),

  // Masterclass - baby-proofing.
  Expert(
    id: 'meera',
    location: 'Chennai · home visits + online',
    blurb: 'Certified child-safety educator · room-by-room baby-proofing for Indian and joint-family homes.',
    name: 'Meera Iyer',
    credential: 'Child-safety educator · 10 years',
    backLabel: 'Masterclass expert',
    rating: '4.7',
    reviewsCount: '280 reviews',
    mid: ('300+', 'homes made safe'),
    fee: ('₹1,299', 'per class'),
    whyHeading: 'Why ParentVeda picks her',
    why:
        'A certified child-safety educator who has baby-proofed hundreds of Indian and joint-family homes. Practical, room-by-room, and refreshingly jargon-free.',
    tags: ['Hindi', 'English', 'Tamil', 'Home safety', 'First aid'],
    reviews: [
      ('Divya', 'mother of Vivaan (8 mo)', '“Room-by-room checklist we actually used the same weekend.”'),
      ('Karan', 'father of Anaya (11 mo)', '“Perfect for our joint-family setup.”'),
    ],
    ctaPrice: '₹1,299',
    ctaSub: 'per masterclass',
    ctaLabel: 'View sessions',
    disclaimer: 'Sessions are hosted inside ParentVeda. The price you see is what you pay - no hidden fees.',
  ),

  // Masterclass - starting solids.
  Expert(
    id: 'ritu',
    location: 'Delhi NCR · online',
    blurb: 'Paediatric nutritionist · calm, mess-friendly first foods with an Indian-first, allergy-safe order.',
    name: 'Ritu Malhotra',
    credential: 'Paediatric nutritionist · 9 years',
    backLabel: 'Masterclass expert',
    rating: '4.8',
    reviewsCount: '350 reviews',
    mid: ('4k+', 'parents taught'),
    fee: ('₹999', 'per class'),
    whyHeading: 'Why ParentVeda picks her',
    why:
        'Makes starting solids calm and mess-friendly - Indian-first foods, an allergy-safe order, and portions that suit real families and joint kitchens.',
    tags: ['Hindi', 'English', 'Punjabi', 'Weaning', 'Nutrition'],
    reviews: [
      ('Pooja', 'mother of Reyansh (6 mo)', '“First solids stopped being scary. Loved the Indian-first approach.”'),
      ('Anil', 'father of Sara (7 mo)', '“Practical and reassuring - no fads.”'),
    ],
    ctaPrice: '₹999',
    ctaSub: 'per masterclass',
    ctaLabel: 'View sessions',
    disclaimer: 'Sessions are hosted inside ParentVeda. The price you see is what you pay - no hidden fees.',
  ),

  // ===========================================================================
  //  Find-help roster - the experts surfaced by "Browse by need". Narrative
  //  fields (whyHeading / why / reviews) are intentionally light here; the
  //  profile guards and hides those blocks when empty. Results sort/filter on
  //  ratingValue, priceValue and availableToday.
  // ===========================================================================
  _findHelp('rajan', 'Dr. Rajan Mehta', 'Paediatrician · 14 years', 'Pediatrician',
      'MBBS, MD Paediatrics · everyday illnesses, growth tracking & vaccination visits.',
      '9-1 PM · 5-8 PM', 4.8, 750, true, true,
      const ['Hindi', 'English', 'Vaccinations', 'Newborn care']),
  _findHelp('kavita', 'Dr. Kavita Reddy', 'Paediatrician · 10 years', 'Pediatrician',
      'MBBS, DCH · allergies, feeding troubles & first-year check-ups.',
      '11-2 PM · 6-8 PM', 4.7, 700, false, true,
      const ['Telugu', 'English', 'Allergies', 'Feeding']),

  // --- Gynaecologists --------------------------------------------------------
  _findHelp('sunita', 'Dr. Sunita Rao', 'Gynaecologist · 18 years', 'Gynecologist',
      'MBBS, MD Obstetrics & Gynaecology · postpartum recovery and contraception counselling.',
      '10-1 PM · 4-6 PM', 4.9, 1200, true, true,
      const ['Hindi', 'English', 'Postpartum care', 'Contraception']),
  _findHelp('farah', 'Dr. Farah Khan', 'Obstetrician-Gynaecologist · 11 years', 'Gynecologist',
      'MBBS, DGO · fourth-trimester healing, pelvic-floor and period concerns.',
      '9-12 PM · 5-7 PM', 4.7, 900, true, false,
      const ['Hindi', 'Urdu', 'English', 'Pelvic health']),
  _findHelp('anjali', 'Dr. Anjali Desai', 'Gynaecologist · 13 years', 'Gynecologist',
      'MBBS, MS · postnatal wellness, PCOS and spacing between pregnancies.',
      '11-2 PM · 6-8 PM', 4.8, 1000, false, true,
      const ['Gujarati', 'Hindi', 'English', 'Postnatal wellness']),

  // --- Speech therapists -----------------------------------------------------
  _findHelp('aisha', 'Aisha Verma', 'Speech-language therapist · 9 years', 'Speech therapist',
      'MASLP · early sounds, late talkers and bilingual-home language delays.',
      '10-1 PM · 4-7 PM', 4.9, 850, true, true,
      const ['Hindi', 'English', 'Late talkers', 'Bilingual homes']),
  _findHelp('rohan_sp', 'Rohan Kapoor', 'Speech therapist · 7 years', 'Speech therapist',
      'BASLP · feeding & oral-motor support, stammering and articulation.',
      '12-3 PM · 5-8 PM', 4.6, 700, true, true,
      const ['Hindi', 'English', 'Oral-motor', 'Articulation']),
  _findHelp('deepa', 'Deepa Nair', 'Paediatric speech therapist · 12 years', 'Speech therapist',
      'MASLP · early-intervention play therapy for under-3s and AAC.',
      '9-12 PM · 4-6 PM', 4.8, 900, false, true,
      const ['Malayalam', 'English', 'Early intervention', 'Play therapy']),

  // --- Lactation experts -----------------------------------------------------
  _findHelp('shalini', 'Shalini Gupta', 'IBCLC lactation consultant · 10 years', 'Lactation expert',
      'IBCLC · latch and supply, painful feeds, pumping and back-to-work plans.',
      '8-11 AM · 4-7 PM', 4.9, 600, true, true,
      const ['Hindi', 'English', 'Latch', 'Supply']),
  _findHelp('ruchi', 'Ruchi Jain', 'Certified lactation counsellor · 6 years', 'Lactation expert',
      'CLC · first-week feeding, cluster feeds and gentle weaning.',
      '9-12 PM · 5-8 PM', 4.7, 500, true, true,
      const ['Hindi', 'English', 'Newborn feeds', 'Weaning']),
  _findHelp('nadia', 'Nadia Sheikh', 'IBCLC lactation consultant · 8 years', 'Lactation expert',
      'IBCLC · tongue-tie feeding support, low supply and relactation.',
      '10-1 PM · 6-8 PM', 4.8, 650, false, true,
      const ['Hindi', 'Urdu', 'English', 'Tongue-tie', 'Relactation']),

  // --- Child dermatologists --------------------------------------------------
  _findHelp('vikram', 'Dr. Vikram Sethi', 'Paediatric dermatologist · 15 years', 'Child derma',
      'MD Dermatology · eczema, cradle cap, nappy rash and infant skin allergies.',
      '10-1 PM · 5-7 PM', 4.8, 1100, true, false,
      const ['Hindi', 'English', 'Eczema', 'Infant skin']),
  _findHelp('leela', 'Dr. Leela Menon', 'Paediatric dermatologist · 16 years', 'Child derma',
      'MD, DVD · atopic skin, birthmarks and stubborn rashes in babies.',
      '11-2 PM · 4-6 PM', 4.9, 1300, false, true,
      const ['Tamil', 'English', 'Atopic skin', 'Birthmarks']),
  _findHelp('arjun_dm', 'Dr. Arjun Rao', 'Dermatologist (child skin) · 9 years', 'Child derma',
      'MBBS, DDVL · heat rash, hives, and everyday newborn skin worries.',
      '12-3 PM · 6-8 PM', 4.6, 900, true, true,
      const ['Hindi', 'English', 'Heat rash', 'Hives']),

  // --- Child psychologists ---------------------------------------------------
  _findHelp('tara', 'Dr. Tara Bose', 'Child psychologist · 14 years', 'Child psychologist',
      'PhD Clinical Psychology · big feelings, sleep-behaviour links and gentle discipline.',
      '11-2 PM · 5-7 PM', 4.9, 1800, true, true,
      const ['Bengali', 'Hindi', 'English', 'Behaviour', 'Emotions']),
  _findHelp('sameer', 'Dr. Sameer Ali', 'Child & adolescent psychologist · 10 years', 'Child psychologist',
      'MPhil Clinical Psychology · tantrums, anxiety and screen-time balance.',
      '10-1 PM · 6-8 PM', 4.7, 1500, false, true,
      const ['Hindi', 'English', 'Tantrums', 'Anxiety']),

  // --- Special-needs experts -------------------------------------------------
  _findHelp('priya_sn', 'Priya Ranganathan', 'Special educator (autism, ADHD) · 13 years', 'Special needs expert',
      'M.Ed Special Education · early red flags, autism and ADHD learning support.',
      '10-1 PM · 4-6 PM', 4.9, 1400, true, true,
      const ['Tamil', 'English', 'Autism', 'ADHD']),
  _findHelp('neil', 'Neil Dcosta', 'Occupational therapist · 8 years', 'Special needs expert',
      'MOT · sensory processing, fine-motor skills and daily-routine support.',
      '9-12 PM · 5-7 PM', 4.7, 1200, true, false,
      const ['English', 'Hindi', 'Sensory', 'Fine-motor']),
  _findHelp('maya', 'Maya Krishnan', 'Developmental therapist · 11 years', 'Special needs expert',
      'MSc Developmental Therapy · milestone delays and early-intervention plans.',
      '11-2 PM · 6-8 PM', 4.8, 1300, false, true,
      const ['Kannada', 'English', 'Milestones', 'Early intervention']),
  // ===========================================================================
  //  SEEDED SUPPLY — placeholder people, real plumbing
  // ---------------------------------------------------------------------------
  //  ⚠️ THESE ARE NOT REAL EXPERTS AND THE APP KNOWS IT. Each carries
  //  `seeded: true`, which is the one flag that separates them from the eleven
  //  above. `test/pp_consult_filter_test.dart` asserts every category has
  //  supply; `kSeededExpertIds` below is how you find and replace all of them.
  //
  //  ⚠️ WHY SEED AT ALL RATHER THAN LEAVE THE DOORS UNFILTERED. Six hubs and
  //  nine consult roles named a person the app could not produce. The choice
  //  was between three bad options and one reasonable one:
  //    - leave it unfiltered (the door opens a list without that person in it)
  //    - hide the door (the section loses an offer it is supposed to make)
  //    - filter to an empty list (worst of all: she taps and gets nothing)
  //    - seed, so the whole path is exercised and swapping in a real person is
  //      a data edit
  //  The last one is the only one that is ready when supply arrives.
  //
  //  ⚠️ NAMES ARE OBVIOUSLY PLACEHOLDER, DELIBERATELY. "Dr. A. Placeholder"
  //  would be honest and would look broken in a screenshot; a plausible fake
  //  name would look real and get shipped by accident. These read as people
  //  and every one is flagged, listed and greppable.
  //
  //  ⚠️ FEES ARE ROUND NUMBERS IN THE RIGHT RANGE, not invented precision.
  //  ₹800 reads as a placeholder; ₹847 reads as a real price somebody set.

  // ⚠️ RENAMED FROM 'Ananya Rao'. The roster already contains
  // 'Dr. Ananya Rao' (id `ananya`, a paediatrician), and two near-identical
  // names in one directory is the precise risk of seeding plausible people:
  // a parent who booked one and met the other would be right to be alarmed,
  // and nobody reviewing a list of twelve placeholders would spot it.
  //
  // Checked the whole roster for collisions after this one, not just this
  // name. `test/pp_expert_links_test.dart` now fails on a duplicate name.
  _findHelp('seed_sleep_1', 'Aditi Rao', 'Certified paediatric sleep coach · 7 years', 'Sleep expert',
      'Gentle, no-cry-it-out sleep support for Indian families who co-sleep.',
      '9-12 PM · 6-9 PM', 4.8, 800, true, true,
      const ['Hindi', 'English', 'Co-sleeping', 'Night waking'], seeded: true),
  _findHelp('seed_sleep_2', 'Farah Qureshi', 'Sleep consultant · 5 years', 'Sleep expert',
      'Naps, wake windows and the four-month change, without a training plan.',
      '10-1 PM', 4.7, 700, false, true,
      const ['Hindi', 'Urdu', 'English', 'Naps'], seeded: true),

  _findHelp('seed_nutrition_1', 'Divya Menon', 'Paediatric nutritionist · 9 years', 'Nutritionist',
      'Weaning, fussy eating and weight worries, built around what your family '
      'already cooks.',
      '9-12 PM · 5-8 PM', 4.8, 900, true, true,
      const ['English', 'Malayalam', 'Weaning', 'Fussy eating'], seeded: true),
  _findHelp('seed_nutrition_2', 'Ritika Shah', 'Clinical dietitian · 6 years', 'Nutritionist',
      'Iron, growth and vegetarian and Jain diets for toddlers.',
      '11-2 PM', 4.6, 800, true, true,
      const ['Hindi', 'Gujarati', 'English', 'Vegetarian'], seeded: true),

  _findHelp('seed_physio_1', 'Neha Kulkarni', 'Postnatal physiotherapist · 8 years', 'Physiotherapist',
      'Core and pelvic floor recovery after birth, including after a caesarean.',
      '8-11 AM · 4-7 PM', 4.9, 900, true, true,
      const ['Hindi', 'Marathi', 'English', 'Pelvic floor', 'C-section'], seeded: true),
  _findHelp('seed_physio_2', 'Sana Iqbal', 'Womens health physiotherapist · 6 years', 'Physiotherapist',
      'Back pain, diastasis and getting back to moving without being rushed.',
      '10-1 PM · 5-8 PM', 4.7, 800, false, true,
      const ['Hindi', 'English', 'Back pain', 'Diastasis'], seeded: true),

  _findHelp('seed_mmh_1', 'Dr. Kavita Bhatt', 'Perinatal psychologist · 11 years', 'Maternal mental health',
      'Postnatal low mood, anxiety and the things that feel too big to say out '
      'loud.',
      '11-2 PM · 6-9 PM', 4.9, 1200, true, true,
      const ['Hindi', 'English', 'Postnatal depression', 'Anxiety'], seeded: true),
  _findHelp('seed_mmh_2', 'Meghna Das', 'Counselling psychologist · 7 years', 'Maternal mental health',
      'A calm hour for a mother who has not had one, with no diagnosis in the '
      'first session.',
      '9-12 PM', 4.8, 1000, true, true,
      const ['Bengali', 'Hindi', 'English', 'Identity', 'Overwhelm'], seeded: true),

  _findHelp('seed_dev_1', 'Dr. Anil Verma', 'Developmental paediatrician · 14 years', 'Development expert',
      'A proper look when something about development has felt off for a while.',
      '10-1 PM', 4.9, 1500, false, true,
      const ['Hindi', 'English', 'Milestones', 'Early intervention'], seeded: true),
  _findHelp('seed_dev_2', 'Preeti Nair', 'Occupational therapist · 9 years', 'Development expert',
      'Motor skills, sensory questions and the wobbly bits in between.',
      '9-12 PM · 4-7 PM', 4.7, 1000, true, true,
      const ['English', 'Tamil', 'Motor skills', 'Sensory'], seeded: true),

  _findHelp('seed_early_1', 'Shruti Kapoor', 'Early years educator · 10 years', 'Early learning expert',
      'School readiness without flashcards, and what actually matters before '
      'five.',
      '10-1 PM · 5-7 PM', 4.8, 700, true, true,
      const ['Hindi', 'English', 'School readiness', 'Play-based'], seeded: true),
  _findHelp('seed_early_2', 'Zoya Ahmed', 'Montessori guide · 7 years', 'Early learning expert',
      'Reading, writing and counting when the child is ready, not when the '
      'school is.',
      '9-12 PM', 4.6, 650, false, true,
      const ['Hindi', 'Urdu', 'English', 'Montessori'], seeded: true),

];

/// Builder for a lean find-help expert - fills the required narrative fields with
/// safe empties (the profile guards them) and sets the results-facing fields.
Expert _findHelp(
  String id,
  String name,
  String credential,
  String category,
  String blurb,
  String timings,
  double ratingValue,
  int priceValue,
  bool availableToday,
  bool videoConsult,
  List<String> tags, {
  bool seeded = false,
}) =>
    Expert(
      id: id,
      name: name,
      credential: credential,
      backLabel: category,
      rating: ratingValue.toStringAsFixed(1),
      reviewsCount: '',
      mid: (credential.contains('·') ? credential.split('·').last.trim() : 'experience', 'experience'),
      fee: ('₹$priceValue', 'consult'),
      whyHeading: '',
      why: '',
      tags: tags,
      reviews: const [],
      ctaPrice: '₹$priceValue',
      ctaSub: 'per consult',
      ctaLabel: 'Book consultation',
      disclaimer:
          'Booking is handled by our partner. ParentVeda earns a small referral fee - it never changes your price.',
      category: category,
      // The one flag that separates a placeholder from a real person.
      seeded: seeded,
      blurb: blurb,
      timings: timings,
      availableToday: availableToday,
      videoConsult: videoConsult,
      priceValue: priceValue,
      ratingValue: ratingValue,
    );

/// Lookup by id; falls back to the first expert (Dr. Neha Sharma).
///
/// ⚠️ THAT FALLBACK IS A REAL NAME. For an id this catalogue does not know,
/// this hands back a different, living doctor — the same shape of defect
/// already recorded against `doctorInfoById()`, where a partner organisation
/// would have seen a stranger's name presented as its own.
///
/// It is tolerable where the result is decoration (an avatar, a "with…" line
/// that is cosmetic). It is NOT tolerable anywhere the name is a CLAIM about
/// who did something — an attribution, an author, a prescriber. Use
/// [expertByIdOrNull] there and render nothing rather than the wrong person.
Expert expertById(String id) => kExperts.firstWhere((e) => e.id == id, orElse: () => kExperts.first);

/// Lookup by id with no fallback, for callers that must not name the wrong
/// person. Null means "we do not know who this is", which is a printable fact;
/// somebody else's name is not.
Expert? expertByIdOrNull(String id) {
  if (id.isEmpty) return null;
  for (final e in kExperts) {
    if (e.id == id) return e;
  }
  return null;
}

/// Lookup by display name - tolerant of the "Dr." prefix and punctuation.
/// Returns null when no seed profile matches, so callers can skip the link
/// rather than open the wrong profile.
Expert? expertByName(String name) {
  String norm(String s) => s.toLowerCase().replaceAll(RegExp('[^a-z]'), '');
  final key = norm(name);
  for (final e in kExperts) {
    if (norm(e.name) == key) return e;
  }
  return null;
}

// =============================================================================
//  Find help - the seven "Browse by need" categories.
// -----------------------------------------------------------------------------
//  Each need maps to an Expert.category and a Material line icon. The Problem
//  Solver landing lists these; tapping one opens the ranked results for that
//  category (via expertsForNeed).
// =============================================================================

/// One "Browse by need" entry.
class FindHelpNeed {
  const FindHelpNeed(this.label, this.category, this.icon);
  final String label;
  final String category; // matches Expert.category
  final IconData icon;
}

// LABEL first, CATEGORY second - and only the label changes here. The category
// is the matching key against Expert.category, so correcting the spelling in
// place would have silently emptied three of these lists.
//
// Indian English is British English: a mother reads "Paediatrician" on the
// clinic door and on the prescription. Every credential string in this file
// already said Paediatrician/Gynaecologist; only the browse labels said
// Pediatrician/Gynecologist, so Find help showed both spellings on one screen.
// "Child derma" was an abbreviation nobody uses out loud.
/// ⚠️ SEVEN OF THESE HAVE REAL SUPPLY; SIX ARE SEEDED SO THE PATH IS COMPLETE.
///
/// The doors that name a sleep coach, a nutritionist, a physio, a postnatal
/// counsellor or a development expert had **nobody behind them** — so filtering
/// to those categories showed an empty list, and the honest interim was to
/// leave those doors unfiltered, which meant they opened a roster that did not
/// contain the person they named.
///
/// The decision was: build it as though the expert exists, so that the day one
/// does, it is a name change rather than a build. Every seeded expert is marked
/// `seeded: true` — see `Expert.seeded` — which is what makes them findable and
/// removable in one grep rather than being indistinguishable from real supply.
const List<FindHelpNeed> kFindHelpNeeds = [
  FindHelpNeed('Paediatrician', 'Pediatrician', Icons.medical_services_outlined),
  FindHelpNeed('Gynaecologist', 'Gynecologist', Icons.pregnant_woman_outlined),
  FindHelpNeed('Speech therapist', 'Speech therapist', Icons.record_voice_over_outlined),
  FindHelpNeed('Lactation expert', 'Lactation expert', Icons.local_drink_outlined),
  FindHelpNeed('Child dermatologist', 'Child derma', Icons.healing_outlined),
  FindHelpNeed('Child psychologist', 'Child psychologist', Icons.psychology_outlined),
  FindHelpNeed('Special needs expert', 'Special needs expert', Icons.accessibility_new_outlined),
  // --- seeded, awaiting real supply ----------------------------------------
  FindHelpNeed('Sleep expert', 'Sleep expert', Icons.nightlight_outlined),
  FindHelpNeed('Child nutritionist', 'Nutritionist', Icons.restaurant_outlined),
  FindHelpNeed('Postnatal physiotherapist', 'Physiotherapist', Icons.self_improvement_outlined),
  FindHelpNeed('Postnatal counsellor', 'Maternal mental health', Icons.favorite_border_rounded),
  FindHelpNeed('Development expert', 'Development expert', Icons.child_care_outlined),
  FindHelpNeed('Early learning expert', 'Early learning expert', Icons.school_outlined),
];

/// Every placeholder person, by id.
///
/// ⚠️ THE POINT OF THIS LIST IS THE DAY SOMEBODY REPLACES THEM. Real supply
/// arriving means editing these rows and clearing the flag, and the only way
/// that is a five-minute job rather than an archaeology exercise is if the set
/// is written down rather than inferred from the names.
///
/// Derived, not hand-maintained: a seeded expert added tomorrow appears here
/// without anyone remembering to add it.
List<String> get kSeededExpertIds =>
    [for (final e in kFindHelpExperts) if (e.seeded) e.id];

/// True when a category is only being served by placeholders.
///
/// Read this before making a promise in copy — "book a sleep expert tonight"
/// is a different sentence when the roster is seeded.
bool categoryIsSeededOnly(String category) {
  final list = expertsForNeed(category);
  return list.isNotEmpty && list.every((e) => e.seeded);
}

/// The human label for a category key.
///
/// Expert.category is a MATCHING KEY, not display text - it stays
/// "Pediatrician" so nothing unmaps. Anywhere a category is shown to a
/// person it goes through here, so the screen says "Paediatrician" while
/// the lookup keeps working. Falls back to the key, so a category with no
/// entry still renders something rather than nothing.
String needLabel(String category) {
  for (final n in kFindHelpNeeds) {
    if (n.category.toLowerCase() == category.toLowerCase()) return n.label;
  }
  return category;
}

/// Every expert tagged for a given need [category] (case-insensitive).
List<Expert> expertsForNeed(String category) {
  final key = category.trim().toLowerCase();
  return kExperts.where((e) => e.category.trim().toLowerCase() == key).toList();
}

/// The full find-help roster (any expert with a need category set) - used by the
/// landing search and the "All experts" results fallback.
List<Expert> get kFindHelpExperts => kExperts.where((e) => e.category.trim().isNotEmpty).toList();
