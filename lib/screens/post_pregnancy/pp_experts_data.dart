// =============================================================================
//  Experts / doctors - shared data for the reusable profile (parenting)
// -----------------------------------------------------------------------------
//  Every masterclass, cohort, course or local service is led by a named expert.
//  This backs a single reusable profile screen (ProviderProfileScreen, the
//  S18·detail layout) so tapping any expert - anywhere - opens their page. A
//  handful of seed profiles for now; real experts slot in here later without
//  touching any screen. Kept inside the post_pregnancy module (fully isolated).
// =============================================================================

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
  });

  final String id;
  final String name; // "Dr. Ananya Rao"
  final String credential; // "Paediatrician · 15 years"
  final String backLabel; // top back-bar label, e.g. "Masterclass expert"
  final bool topPick;
  final String topPickLabel;
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
}

const List<Expert> kExperts = [
  // The original Problem Solver provider - keeps the S18·detail screen identical.
  Expert(
    id: 'neha',
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
  ),

  // Masterclass + featured expert.
  Expert(
    id: 'ananya',
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
  ),

  // Cohort coach.
  Expert(
    id: 'meher',
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
    name: 'Dr. Kabir Sen',
    credential: 'Child psychologist · 12 years',
    backLabel: 'Masterclass expert',
    rating: '4.8',
    reviewsCount: '410 reviews',
    mid: ('5k+', 'parents taught'),
    fee: ('₹2,499', 'per class'),
    whyHeading: 'Why ParentVeda picks him',
    why:
        'Translates the science of the Wonder Weeks into plain, reassuring language. Gentle, evidence-first, and brilliant at demystifying the fussy leaps.',
    tags: ['Hindi', 'English', 'Bengali', 'Child development', 'Behaviour'],
    reviews: [
      ('Nisha', 'mother of Aarav (4 mo)', '“I stopped panicking about every fussy phase after his class.”'),
      ('Rahul', 'father of Meera (10 mo)', '“Clear, calm, science-backed. Loved it.”'),
    ],
    ctaPrice: '₹2,499',
    ctaSub: 'per masterclass',
    ctaLabel: 'View sessions',
    disclaimer: 'Sessions are hosted inside ParentVeda. The price you see is what you pay - no hidden fees.',
  ),

  // Masterclass - baby-proofing.
  Expert(
    id: 'meera',
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
];

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
