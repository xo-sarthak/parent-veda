// =============================================================================
//  The panel experts - the five specialists who work with ParentVeda
// -----------------------------------------------------------------------------
//  Built 2026-10-30 for the "Our experts" directory (You > Support > Our
//  experts). Source of the wording: the approved preview, which was written from
//  each expert's own documents. The documents themselves are never shown and
//  nothing here comes from anywhere else.
//
//  Never in this file: phone, email, home address, a father's name, roll or
//  enrolment numbers. `test/pv_experts_screen_test.dart` scans for '@' and any
//  ten-digit run.
//
//  ⚠️ A SEPARATE LIST, NOT MERGED INTO `kExperts`. `kExperts` is the bookable
//  roster plus its placeholders, and its counting tests (expert_catalogue_test,
//  pp_consult_filter_test) would change meaning if five directory-only people
//  joined it. These five are profiles, not a shop front.
//
//  ⚠️ NOTHING HERE IS BOOKABLE, RATED, PRICED OR REVIEWED.
//    - `timings: ''` is what the profile reads to decide there is no Book bar,
//      and what the consult lists read to decide a person is not offered.
//    - `rating`, `fee`, `reviews` are empty on purpose. There is no verified
//      badge anywhere: `registration` is a number the expert supplied, printed
//      under a plain "Registration" label.
//
//  ⚠️ `domain: 'universal'` ON ALL FIVE. An expert is never "only for" a stage
//  (user, 2026-10-30), so the directory has one list and no stage chips.
//
//  ⚠️ EACH EXPERT CONFIRMS HER OWN TEXT BEFORE LAUNCH - registration number and
//  title included. Photos are owed. Both are on docs/BEFORE-LAUNCH.md.
// =============================================================================

import 'expert.dart';

/// Shown on the profile after the expert's name, so "Dr." is never read as a
/// medical doctor: Simranpreet's is a PhD, Maneesha's is a physiotherapist.
/// Keyed by [Expert.id]; absent means no note.
const Map<String, String> kPanelNameNote = {
  'panel_simran': 'PhD',
  'panel_maneesha': 'Physiotherapist',
};

/// "Helps with: A, B, C" - the first three tags, the same line on every row.
String panelHelpsWith(Expert e) => 'Helps with: ${e.tags.take(3).join(', ')}';

/// True for an expert in [kPanelExperts]. The profile screen uses it to switch
/// off everything that belongs to a bookable expert.
bool isPanelExpert(Expert e) => e.id.startsWith('panel_');

const String _kDisclaimer =
    'The expert supplied these details and ParentVeda keeps them on file. '
    'General guidance never replaces your own doctor.';

// `why` holds "More about her" as one item per line; the profile splits it.
const List<Expert> kPanelExperts = [
  Expert(
    id: 'panel_simran',
    name: 'Dr. Simranpreet Kaur Sandhu',
    credential: 'Genetic counsellor and embryologist',
    backLabel: 'Our experts',
    rating: '',
    reviewsCount: '',
    mid: ('', ''),
    fee: ('', ''),
    whyHeading: 'More about her',
    why:
        'MSc and BSc (Hons) in Human Genetics, Guru Nanak Dev University\n'
        'Post-doctoral fellow, ICMR National Institute for Research in Reproductive and Child Health, Mumbai (2023)\n'
        'Assistant Professor of Genetics, SGRD Institute of Medical Sciences (2021 to 2024); embryologist and counsellor there (2016 to 2024)\n'
        'Hands-on embryology training in Las Vegas, Bangkok and Mumbai\n'
        '11 research papers, including work on genes linked to infertility and on prenatal genetic counselling\n'
        'Selected for the Gates Foundation OpeningGates programme (2024)',
    tags: ['Fertility', 'IVF', 'Miscarriage', 'Prenatal genetics'],
    reviews: [],
    ctaPrice: '',
    ctaSub: '',
    ctaLabel: '',
    disclaimer: _kDisclaimer,
    location: 'Blossom Genomic Wellness Clinic, Amritsar',
    blurb:
        'Simranpreet counsels couples through infertility, recurrent miscarriage, preconception screening and prenatal testing. She helped set up a genetic clinic and a Level I ART lab at a medical university, and she also coaches on nutrition based on genetic results.',
    qualifications: [
      'PhD, Medical Physiology (Human Genetics), SGRD University of Health Sciences, 2023',
      'MSc and BSc (Hons) in Human Genetics, Guru Nanak Dev University',
      'Post-doctoral fellow, ICMR National Institute for Research in Reproductive and Child Health, Mumbai (2023)',
      'Assistant Professor of Genetics, SGRD Institute of Medical Sciences (2021 to 2024); embryologist and counsellor there (2016 to 2024)',
      'Hands-on embryology training in Las Vegas, Bangkok and Mumbai',
      '11 research papers, including work on genes linked to infertility and on prenatal genetic counselling',
      'Selected for the Gates Foundation OpeningGates programme (2024)',
    ],
    experience:
        'In genetics and fertility since 2007, with more than 1,000 genetic counselling sessions',
    practisesAt: 'Blossom Genomic Wellness Clinic, Amritsar',
    registration:
        'Board of Genetic Counselling India, Level II Genetic Counsellor (BGC 2024-204)',
    memberships: [
      'Board of Genetic Counselling India',
      'Indian Society of Human Genetics',
    ],
    domain: 'universal',
  ),
  Expert(
    id: 'panel_maneesha',
    name: 'Dr. Maneesha Mohan',
    credential: 'Women\'s health physiotherapist and lactation specialist',
    backLabel: 'Our experts',
    rating: '',
    reviewsCount: '',
    mid: ('', ''),
    fee: ('', ''),
    whyHeading: 'More about her',
    why:
        'Postgraduate certificate in Women\'s Health and Rehabilitation, International Health and Fitness Association (2020)\n'
        'Infant and Young Child Feeding and Lactation Management Specialist, Breastfeeding Promotion Network of India (2019)\n'
        'Trauma-informed certified birth doula, The Doula Collective\n'
        'Completed the Lamaze Childbirth Educator Seminar, 25 contact hours (2024)',
    tags: [
      'Women\'s health',
      'Breastfeeding',
      'Birth doula',
      'Childbirth education',
    ],
    reviews: [],
    ctaPrice: '',
    ctaSub: '',
    ctaLabel: '',
    disclaimer: _kDisclaimer,
    location: 'Bengaluru',
    blurb:
        'Maneesha works with women through pregnancy, birth and the months after. She covers movement and recovery as a physiotherapist, feeding as a lactation specialist, and birth as a trained doula and childbirth educator.',
    qualifications: [
      'Bachelor of Physiotherapy, Rajiv Gandhi University of Health Sciences, Karnataka, 2011',
      'Postgraduate certificate in Women\'s Health and Rehabilitation, International Health and Fitness Association (2020)',
      'Infant and Young Child Feeding and Lactation Management Specialist, Breastfeeding Promotion Network of India (2019)',
      'Trauma-informed certified birth doula, The Doula Collective',
      'Completed the Lamaze Childbirth Educator Seminar, 25 contact hours (2024)',
    ],
    experience: 'Physiotherapist since 2011',
    practisesAt: 'Bengaluru',
    registration:
        'Indian Association of Physiotherapists, Life Member (L-34296)',
    memberships: ['Indian Association of Physiotherapists'],
    domain: 'universal',
  ),
  Expert(
    id: 'panel_keya',
    name: 'Keya Sampat',
    credential: 'Clinical hypnotherapist and HypnoBirthing educator',
    backLabel: 'Our experts',
    rating: '',
    reviewsCount: '',
    mid: ('', ''),
    fee: ('', ''),
    whyHeading: 'More about her',
    why:
        'Certified in Integrated Clinical Hypnotherapy, Ekaa (2020)\n'
        'HypnoBirthing Practitioner, HypnoBirthing International, UK (2019)\n'
        'Integral Somatic Psychology training with Dr. Raja Selvam (2024)\n'
        'Certified life coach, Inspiring Evolution (2020)\n'
        'BA Psychology, University of Mumbai\n'
        'Runs workshops on anxiety and an introduction to HypnoBirthing',
    tags: ['HypnoBirthing', 'Birth fear', 'Anxiety', 'Life coaching'],
    reviews: [],
    ctaPrice: '',
    ctaSub: '',
    ctaLabel: '',
    disclaimer: _kDisclaimer,
    location: 'Parichay, Mumbai · sees clients online',
    blurb:
        'Keya works with what a mother carries into birth. She combines hypnotherapy, HypnoBirthing and body-based somatic work to help people approach pregnancy and birth more calmly.',
    qualifications: [
      'MSc Forensic Psychology, National Forensic Sciences University, Gandhinagar, 2022',
      'Certified in Integrated Clinical Hypnotherapy, Ekaa (2020)',
      'HypnoBirthing Practitioner, HypnoBirthing International, UK (2019)',
      'Integral Somatic Psychology training with Dr. Raja Selvam (2024)',
      'Certified life coach, Inspiring Evolution (2020)',
      'BA Psychology, University of Mumbai',
      'Runs workshops on anxiety and an introduction to HypnoBirthing',
    ],
    experience: 'Independent practice since 2018',
    practisesAt: 'Parichay, Mumbai · sees clients online',
    domain: 'universal',
  ),
  Expert(
    id: 'panel_aishwarya',
    name: 'Aishwarya Jain',
    credential: 'Child guidance counsellor',
    backLabel: 'Our experts',
    rating: '',
    reviewsCount: '',
    mid: ('', ''),
    fee: ('', ''),
    whyHeading: 'More about her',
    why:
        'Advanced Diploma in Child Guidance and Counselling, recognised by RCI (2017); registration renewed 2024\n'
        'BSc Home Science, University of Delhi (2014, First Division)',
    tags: ['Child development', 'Behaviour', 'Parenting'],
    reviews: [],
    ctaPrice: '',
    ctaSub: '',
    ctaLabel: '',
    disclaimer: _kDisclaimer,
    location: 'New Delhi',
    blurb:
        'Aishwarya helps parents understand how their child is growing, both in behaviour and in development, and what to do when something feels off.',
    qualifications: [
      'MSc Human Development and Childhood Studies, University of Delhi, 2016 (First Division)',
      'Advanced Diploma in Child Guidance and Counselling, recognised by RCI (2017); registration renewed 2024',
      'BSc Home Science, University of Delhi (2014, First Division)',
    ],
    experience: 'Counselling children and families since 2017',
    practisesAt: 'New Delhi',
    registration:
        'Rehabilitation Council of India, Rehabilitation Counsellor (CRR A62874), valid to 2029',
    domain: 'universal',
  ),
  Expert(
    id: 'panel_madhvi',
    name: 'Madhvi Khurana',
    credential: 'Child and adolescent psychologist',
    backLabel: 'Our experts',
    rating: '',
    reviewsCount: '',
    mid: ('', ''),
    fee: ('', ''),
    whyHeading: 'More about her',
    why:
        'Advanced Diploma in Child Guidance and Counselling, Amity University, recognised by RCI (2026)\n'
        'Trainee child psychologist, Child Development Clinic, Sir Ganga Ram Hospital (2026)\n'
        'Clinical postings at Moolchand Khairati Ram Hospital\n'
        'BA Psychology and English, University of Delhi',
    tags: ['Children and teens', 'Behaviour therapy', 'Assessments'],
    reviews: [],
    ctaPrice: '',
    ctaSub: '',
    ctaLabel: '',
    disclaimer: _kDisclaimer,
    location: 'New Delhi',
    blurb:
        'Madhvi works with children and teenagers on behaviour, emotions and development, using therapy and psychological assessment.',
    qualifications: [
      'MA Clinical Psychology, Amity University, Noida, 2025',
      'Advanced Diploma in Child Guidance and Counselling, Amity University, recognised by RCI (2026)',
      'Trainee child psychologist, Child Development Clinic, Sir Ganga Ram Hospital (2026)',
      'Clinical postings at Moolchand Khairati Ram Hospital',
      'BA Psychology and English, University of Delhi',
    ],
    experience: 'Supervised clinical placements, 2022 to 2026',
    practisesAt: 'New Delhi',
    registration:
        'Rehabilitation Council of India, Rehabilitation Counsellor (CRR A126421), valid to 2033',
    domain: 'universal',
  ),
];
