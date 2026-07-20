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
    ctaSub: 'via Practo',
    ctaLabel: 'Book on Practo',
    disclaimer: 'Booking is handled by Practo. ParentVeda earns a small referral fee - it never changes your price.',
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
  List<String> tags,
) =>
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
      blurb: blurb,
      timings: timings,
      availableToday: availableToday,
      videoConsult: videoConsult,
      priceValue: priceValue,
      ratingValue: ratingValue,
    );

/// Lookup by id; falls back to the first expert (Dr. Neha Sharma).
Expert expertById(String id) => kExperts.firstWhere((e) => e.id == id, orElse: () => kExperts.first);

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

const List<FindHelpNeed> kFindHelpNeeds = [
  FindHelpNeed('Pediatrician', 'Pediatrician', Icons.medical_services_outlined),
  FindHelpNeed('Gynecologist', 'Gynecologist', Icons.pregnant_woman_outlined),
  FindHelpNeed('Speech therapist', 'Speech therapist', Icons.record_voice_over_outlined),
  FindHelpNeed('Lactation expert', 'Lactation expert', Icons.local_drink_outlined),
  FindHelpNeed('Child derma', 'Child derma', Icons.healing_outlined),
  FindHelpNeed('Child psychologist', 'Child psychologist', Icons.psychology_outlined),
  FindHelpNeed('Special needs expert', 'Special needs expert', Icons.accessibility_new_outlined),
];

/// Every expert tagged for a given need [category] (case-insensitive).
List<Expert> expertsForNeed(String category) {
  final key = category.trim().toLowerCase();
  return kExperts.where((e) => e.category.trim().toLowerCase() == key).toList();
}

/// The full find-help roster (any expert with a need category set) - used by the
/// landing search and the "All experts" results fallback.
List<Expert> get kFindHelpExperts => kExperts.where((e) => e.category.trim().isNotEmpty).toList();
