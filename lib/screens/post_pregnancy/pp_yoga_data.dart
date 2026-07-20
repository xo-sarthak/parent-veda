// =============================================================================
//  ParentVeda Yoga - content model, seed catalog + saved/booked store
// -----------------------------------------------------------------------------
//  "Yoga & Parenting Classes" is an image-led, cult.fit-style class marketplace
//  for the parenting journey - prenatal, postnatal, post-IVF, breathing/Lamaze,
//  meditation and core recovery. Every class carries a mode (live 1:1, live
//  group, or recorded), an instructor with a credential, a rating, a schedule,
//  a price and honest review snippets. Static seed data for now (a CMS/booking
//  engine slots in later). Kept inside the post_pregnancy module - nothing here
//  depends on the pregnancy app.
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/cloud_synced_store.dart';

/// How a class is delivered. The home's toggles map straight onto these three.
enum YogaMode { liveOneToOne, liveGroup, recorded }

/// A grouping shown as a cult.fit-style section header (title + one-line subtitle).
class YogaCategory {
  const YogaCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}

/// A short, attributed review snippet (stars + note + who said it).
class YogaReview {
  const YogaReview({required this.author, required this.note, this.stars = 5});
  final String author;
  final String note;
  final int stars;
}

/// One bookable/streamable class. `category` references a [YogaCategory.id];
/// `mode` splits the three delivery types; everything else is shared.
class YogaClass {
  const YogaClass({
    required this.id,
    required this.title,
    required this.category,
    required this.instructorName,
    required this.instructorCredential,
    // Who this person actually is. For a 1:1 session the trainer IS the
    // product - booking one on a name and a credential alone asks a parent to
    // spend money on a stranger.
    this.instructorBio = '',
    this.instructorFocus = const [],
    required this.rating,
    required this.reviewsCount,
    required this.mode,
    required this.schedule,
    required this.durationLabel,
    required this.price,
    required this.level,
    required this.about,
    required this.reviews,
    required this.seed,
    this.tagline = '',
  });

  final String id;
  final String title;
  final String category; // -> YogaCategory.id
  final String instructorName;
  final String instructorCredential;
  final String instructorBio;
  final List<String> instructorFocus;
  final double rating; // out of 5
  final int reviewsCount;
  final YogaMode mode;
  final String schedule; // "Live · Mon, Wed, Fri · 7am IST" / "Recorded · watch anytime"
  final String durationLabel; // "45 min"
  final String price; // "₹499 / class · free on ParentVeda+"
  final String level; // "All levels" / "Postnatal" / "Extra-gentle"
  final String about;
  final List<YogaReview> reviews;
  final int seed; // varies the placeholder card tint
  final String tagline; // optional one-liner shown on the card

  YogaCategory get categoryInfo => yogaCategoryById(category);
  bool get isLive => mode != YogaMode.recorded;

  /// Full label ("Live 1:1" / "Live group" / "Recorded").
  String get modeLabel => switch (mode) {
        YogaMode.liveOneToOne => 'Live 1:1',
        YogaMode.liveGroup => 'Live group',
        YogaMode.recorded => 'Recorded',
      };

  /// Short badge for the card corner ("1:1" / "GROUP" / "RECORDED").
  String get modePill => switch (mode) {
        YogaMode.liveOneToOne => '1:1',
        YogaMode.liveGroup => 'GROUP',
        YogaMode.recorded => 'RECORDED',
      };

  /// The primary CTA verb for this mode.
  String get ctaLabel => switch (mode) {
        YogaMode.liveOneToOne => 'Book 1:1 session',
        YogaMode.liveGroup => 'Join this class',
        YogaMode.recorded => 'Start practising',
      };
}

// ---- categories -------------------------------------------------------------
const List<YogaCategory> kYogaCategories = [
  YogaCategory(
      id: 'yoga',
      title: 'Yoga & Meditation',
      subtitle: 'Everyday practice for strength and calm.',
      icon: Icons.self_improvement_outlined),
  YogaCategory(
      id: 'prenatal',
      title: 'Prenatal Yoga',
      subtitle: 'Safe, trimester-aware movement through pregnancy.',
      icon: Icons.pregnant_woman_outlined),
  YogaCategory(
      id: 'postnatal',
      title: 'Postnatal Yoga',
      subtitle: 'Rebuild gently in the fourth trimester and beyond.',
      icon: Icons.child_friendly_outlined),
  YogaCategory(
      id: 'postivf',
      title: 'Post-IVF Yoga',
      subtitle: 'Extra-gentle, mindful care after fertility treatment.',
      icon: Icons.volunteer_activism_outlined),
  YogaCategory(
      id: 'breathing',
      title: 'Breathing & Lamaze',
      subtitle: 'Breath for labour, and a calmer everyday.',
      icon: Icons.air_outlined),
  YogaCategory(
      id: 'meditation',
      title: 'Meditation',
      subtitle: 'Quiet the mind - ten minutes a day.',
      icon: Icons.nightlight_outlined),
  YogaCategory(
      id: 'core',
      title: 'Core & Recovery',
      subtitle: 'Heal the deep core and pelvic floor, the right way.',
      icon: Icons.fitness_center_outlined),
];

// ---- catalog ----------------------------------------------------------------
const List<YogaClass> kYogaClasses = [
  // ---- Yoga -----------------------------------------------------------------
  YogaClass(
    id: 'y_flow_am',
    title: 'Morning Sun Flow',
    category: 'yoga',
    instructorName: 'Aditi Verma',
    instructorCredential: 'Certified Yoga Acharya · 15 yrs',
    instructorBio:
        'Aditi trained in Mysore and has spent fifteen years working almost entirely with pregnant and postpartum women. She is unusually careful about diastasis recti and pelvic-floor recovery, and will slow a session down rather than push a pose that is not ready.',
    instructorFocus: ['Postpartum recovery', 'Pelvic floor', 'Diastasis recti', 'Gentle prenatal'],
    rating: 4.9,
    reviewsCount: 214,
    mode: YogaMode.liveGroup,
    schedule: 'Live · Mon, Wed, Fri · 6:30am IST',
    durationLabel: '40 min',
    price: '₹399 / class · free on ParentVeda+',
    level: 'All levels',
    tagline: 'Start the day with a gentle full-body flow.',
    about:
        'A warm, unhurried morning flow to wake the body and settle the mind before the day begins. Aditi keeps every posture optional and offers a softer variation for tired parents - you set the pace.',
    reviews: [
      YogaReview(author: 'Ritika S.', note: 'The 6:30 slot is perfect before the baby wakes. Calm, never rushed.'),
      YogaReview(author: 'Devang P.', stars: 5, note: 'Aditi explains the why behind each pose. I actually feel it in my back now.'),
    ],
    seed: 1,
  ),
  YogaClass(
    id: 'y_1to1',
    title: 'Personalised Hatha 1:1',
    category: 'yoga',
    instructorName: 'Aditi Verma',
    instructorCredential: 'Certified Yoga Acharya · 15 yrs',
    rating: 4.9,
    reviewsCount: 88,
    mode: YogaMode.liveOneToOne,
    schedule: 'Book a 1:1 slot · Mon–Sat',
    durationLabel: '50 min',
    price: '₹999 / session',
    level: 'All levels',
    tagline: 'A practice built entirely around your body.',
    about:
        'One-to-one Hatha yoga shaped around your current strength, any niggles, and how much time you have. Aditi builds a plan you can keep even between sessions.',
    reviews: [
      YogaReview(author: 'Meera N.', note: 'She adjusted everything for my old knee injury. Felt truly seen.'),
      YogaReview(author: 'Ananya R.', stars: 5, note: 'Worth every rupee - it is like having a coach who remembers exactly where you left off.'),
    ],
    seed: 2,
  ),
  YogaClass(
    id: 'y_evening_recorded',
    title: 'Evening Wind-Down',
    category: 'yoga',
    instructorName: 'Nisha Pillai',
    instructorCredential: 'Yoga & Breathwork Guide · 8 yrs',
    rating: 4.8,
    reviewsCount: 460,
    mode: YogaMode.recorded,
    schedule: 'Recorded · watch anytime',
    durationLabel: '25 min',
    price: 'Free on ParentVeda+',
    level: 'Gentle',
    tagline: 'Unknot the day before bed.',
    about:
        'A slow, floor-based sequence to release the neck, shoulders and hips after a long day of carrying and lifting. Dim the lights, roll out your mat, and let go.',
    reviews: [
      YogaReview(author: 'Sana K.', note: 'My go-to after bedtime chaos. I sleep so much better on the nights I do it.'),
      YogaReview(author: 'Priya M.', stars: 4, note: 'Gentle and short enough that I actually keep coming back to it.'),
    ],
    seed: 3,
  ),
  YogaClass(
    id: 'y_strength_rec',
    title: 'Everyday Strength & Mobility',
    category: 'yoga',
    instructorName: 'Aditi Verma',
    instructorCredential: 'Certified Yoga Acharya · 15 yrs',
    rating: 4.7,
    reviewsCount: 302,
    mode: YogaMode.recorded,
    schedule: 'Recorded · watch anytime',
    durationLabel: '35 min',
    price: '₹299',
    level: 'Beginner',
    tagline: 'Build the strength parenting quietly demands.',
    about:
        'A grounded, standing-and-mat practice to build real functional strength for the daily lift-carry-rock of parenting - without any equipment.',
    reviews: [
      YogaReview(author: 'Karan V.', note: 'My back stopped complaining after the school-bag lifts. Simple and effective.'),
      YogaReview(author: 'Lakshmi T.', stars: 5, note: 'No fancy gear, no jumping - just steady strength I can feel.'),
    ],
    seed: 4,
  ),

  // ---- Prenatal Yoga --------------------------------------------------------
  YogaClass(
    id: 'pn_group',
    title: 'Trimester-Safe Prenatal Flow',
    category: 'prenatal',
    instructorName: 'Radhika Menon',
    instructorCredential: 'Prenatal Yoga Therapist · 12 yrs',
    rating: 4.9,
    reviewsCount: 342,
    mode: YogaMode.liveGroup,
    schedule: 'Live · Tue, Thu, Sat · 8am IST',
    durationLabel: '45 min',
    price: '₹499 / class',
    level: 'All trimesters',
    tagline: 'Move safely, whatever week you are in.',
    about:
        'A prenatal flow that adapts pose-by-pose to your trimester - building the strength and openness that help in labour, while always keeping you and baby safe. Radhika calls out modifications live.',
    reviews: [
      YogaReview(author: 'Neha J.', note: 'She always checks in on how far along everyone is. I never felt unsafe.'),
      YogaReview(author: 'Ishita B.', stars: 5, note: 'The hip openers were a lifesaver in my third trimester.'),
    ],
    seed: 5,
  ),
  YogaClass(
    id: 'pn_1to1',
    title: 'Your Prenatal Practice, 1:1',
    category: 'prenatal',
    instructorName: 'Radhika Menon',
    instructorCredential: 'Prenatal Yoga Therapist · 12 yrs',
    rating: 5.0,
    reviewsCount: 76,
    mode: YogaMode.liveOneToOne,
    schedule: 'Book a 1:1 slot · flexible timing',
    durationLabel: '50 min',
    price: '₹1,199 / session',
    level: 'All trimesters',
    tagline: 'A private practice for you and your pregnancy.',
    about:
        'One-to-one prenatal sessions tailored to your body, your due date, and anything your obstetrician has flagged. Ideal for high-risk pregnancies or if group classes feel like too much.',
    reviews: [
      YogaReview(author: 'Pooja D.', note: 'With my placenta previa I was scared to move. Radhika made it safe and calm.'),
      YogaReview(author: 'Sneha K.', stars: 5, note: 'She coordinated with what my doctor said. That trust meant everything.'),
    ],
    seed: 6,
  ),
  YogaClass(
    id: 'pn_hips_rec',
    title: 'Open Hips for Labour',
    category: 'prenatal',
    instructorName: 'Radhika Menon',
    instructorCredential: 'Prenatal Yoga Therapist · 12 yrs',
    rating: 4.8,
    reviewsCount: 288,
    mode: YogaMode.recorded,
    schedule: 'Recorded · watch anytime',
    durationLabel: '30 min',
    price: 'Free on ParentVeda+',
    level: 'Beginner',
    tagline: 'Gentle openness for an easier birth.',
    about:
        'A recorded sequence of supported hip and pelvic openers - the movements that create space for baby and can make labour feel more manageable. Safe from the second trimester onward.',
    reviews: [
      YogaReview(author: 'Aarti S.', note: 'Did this daily in my last month. My midwife noticed how relaxed my hips were.'),
      YogaReview(author: 'Divya R.', stars: 5, note: 'Simple, calming and I could pause whenever I needed the loo!'),
    ],
    seed: 7,
  ),
  YogaClass(
    id: 'pn_back_rec',
    title: 'Relief for a Pregnancy Back',
    category: 'prenatal',
    instructorName: 'Farah Sheikh',
    instructorCredential: 'Lamaze Educator · 10 yrs',
    rating: 4.7,
    reviewsCount: 190,
    mode: YogaMode.recorded,
    schedule: 'Recorded · watch anytime',
    durationLabel: '20 min',
    price: '₹299',
    level: 'Gentle',
    tagline: 'Ease the ache of a growing bump.',
    about:
        'Twenty gentle minutes of cat-cow, supported stretches and breath to release the lower-back tension that builds as your bump grows. Do it on the days your back is loudest.',
    reviews: [
      YogaReview(author: 'Reema T.', note: 'The only thing that touched my sciatica at 30 weeks.'),
      YogaReview(author: 'Kavya P.', stars: 4, note: 'Short and doable even when I was exhausted.'),
    ],
    seed: 8,
  ),

  // ---- Postnatal Yoga -------------------------------------------------------
  YogaClass(
    id: 'po_group',
    title: 'Fourth-Trimester Reset',
    category: 'postnatal',
    instructorName: 'Sana Kapoor',
    instructorCredential: 'Postnatal & Core Coach · 9 yrs',
    rating: 4.9,
    reviewsCount: 256,
    mode: YogaMode.liveGroup,
    schedule: 'Live · Mon, Thu · 11am IST',
    durationLabel: '40 min',
    price: '₹399 / class',
    level: 'Postnatal',
    tagline: 'Come back to your body, gently.',
    about:
        'A live class for the fourth trimester - reconnecting breath and core, easing feeding-tight shoulders, and moving in a way that honours how new your body still is. Babies welcome on the mat.',
    reviews: [
      YogaReview(author: 'Tanvi M.', note: 'She lets us pause to feed or soothe. First class that felt made for new mums.'),
      YogaReview(author: 'Rhea S.', stars: 5, note: 'My posture from all the nursing has completely changed. Thank you Sana.'),
    ],
    seed: 9,
  ),
  YogaClass(
    id: 'po_1to1',
    title: 'Postnatal Recovery 1:1',
    category: 'postnatal',
    instructorName: 'Sana Kapoor',
    instructorCredential: 'Postnatal & Core Coach · 9 yrs',
    rating: 5.0,
    reviewsCount: 64,
    mode: YogaMode.liveOneToOne,
    schedule: 'Book a 1:1 slot · Mon–Sat',
    durationLabel: '45 min',
    price: '₹999 / session',
    level: 'Postnatal',
    tagline: 'Recovery paced to your delivery, not a template.',
    about:
        'Private postnatal sessions that meet your body where it is - whether you had a vaginal birth or a C-section, six weeks or six months ago. Sana screens for diastasis and builds up safely.',
    reviews: [
      YogaReview(author: 'Anjali V.', note: 'After my C-section I had no idea where to start. She gave me a real, safe plan.'),
      YogaReview(author: 'Megha D.', stars: 5, note: 'She checked my ab separation before anything else. Felt properly cared for.'),
    ],
    seed: 10,
  ),
  YogaClass(
    id: 'po_gentle_rec',
    title: 'Gentle Return to Movement',
    category: 'postnatal',
    instructorName: 'Sana Kapoor',
    instructorCredential: 'Postnatal & Core Coach · 9 yrs',
    rating: 4.8,
    reviewsCount: 388,
    mode: YogaMode.recorded,
    schedule: 'Recorded · watch anytime',
    durationLabel: '20 min',
    price: 'Free on ParentVeda+',
    level: 'Beginner',
    tagline: 'Your very first steps back, whenever you are ready.',
    about:
        'The gentlest possible re-entry - breath, pelvic-floor awareness and soft mobility you can start once your doctor clears you. No crunches, no pressure, no rush.',
    reviews: [
      YogaReview(author: 'Simran K.', note: 'Cleared at 8 weeks and this was exactly the soft start I needed.'),
      YogaReview(author: 'Nidhi R.', stars: 5, note: 'I could do it beside the cot during naps. Perfect length.'),
    ],
    seed: 11,
  ),
  YogaClass(
    id: 'po_babywearing_rec',
    title: 'Baby-in-Arms Flow',
    category: 'postnatal',
    instructorName: 'Nisha Pillai',
    instructorCredential: 'Yoga & Breathwork Guide · 8 yrs',
    rating: 4.6,
    reviewsCount: 142,
    mode: YogaMode.recorded,
    schedule: 'Recorded · watch anytime',
    durationLabel: '25 min',
    price: '₹299',
    level: 'Gentle',
    tagline: 'Move with your baby, not around them.',
    about:
        'A playful flow you can do while holding or wearing your baby - turning fussy afternoons into gentle movement for you both. Every pose has a hands-free option too.',
    reviews: [
      YogaReview(author: 'Ira S.', note: 'She loves the swaying bits and I get to stretch. Win-win.'),
      YogaReview(author: 'Bhavna T.', stars: 4, note: 'Clever way to move when you genuinely cannot put the baby down.'),
    ],
    seed: 12,
  ),

  // ---- Post-IVF Yoga --------------------------------------------------------
  YogaClass(
    id: 'iv_1to1',
    title: 'Post-IVF Gentle 1:1',
    category: 'postivf',
    instructorName: 'Kavya Reddy',
    instructorCredential: 'Fertility Yoga Specialist · 7 yrs',
    rating: 5.0,
    reviewsCount: 52,
    mode: YogaMode.liveOneToOne,
    schedule: 'Book a 1:1 slot · flexible timing',
    durationLabel: '45 min',
    price: '₹1,299 / session',
    level: 'Extra-gentle',
    tagline: 'Careful, calming movement after treatment.',
    about:
        'Private, extra-gentle sessions for the delicate window after an IVF transfer or early pregnancy - restorative postures, calming breath, and absolutely nothing that strains the abdomen.',
    reviews: [
      YogaReview(author: 'Shreya G.', note: 'After three cycles I was terrified to move. Kavya made me feel safe again.'),
      YogaReview(author: 'Payal M.', stars: 5, note: 'She understood the emotional side too, not just the physical.'),
    ],
    seed: 13,
  ),
  YogaClass(
    id: 'iv_group',
    title: 'Two-Week-Wait Calm Circle',
    category: 'postivf',
    instructorName: 'Kavya Reddy',
    instructorCredential: 'Fertility Yoga Specialist · 7 yrs',
    rating: 4.9,
    reviewsCount: 96,
    mode: YogaMode.liveGroup,
    schedule: 'Live · Wed, Sun · 9am IST',
    durationLabel: '35 min',
    price: '₹599 / class',
    level: 'Extra-gentle',
    tagline: 'Steady the nerves of the two-week wait.',
    about:
        'A small, warm live circle of restorative movement and breath for the anxious wait after a transfer. As much about steadying the mind as the body, with others who truly understand.',
    reviews: [
      YogaReview(author: 'Ritu A.', note: 'Being with others in the same wait was as healing as the yoga itself.'),
      YogaReview(author: 'Naina S.', stars: 5, note: 'The breathwork got me through the longest fortnight of my life.'),
    ],
    seed: 14,
  ),
  YogaClass(
    id: 'iv_restore_rec',
    title: 'Restorative After IVF',
    category: 'postivf',
    instructorName: 'Kavya Reddy',
    instructorCredential: 'Fertility Yoga Specialist · 7 yrs',
    rating: 4.8,
    reviewsCount: 168,
    mode: YogaMode.recorded,
    schedule: 'Recorded · watch anytime',
    durationLabel: '30 min',
    price: 'Free on ParentVeda+',
    level: 'Restorative',
    tagline: 'Deep rest for a body that has been through a lot.',
    about:
        'Fully supported, propped restorative postures held long and soft - designed to calm the nervous system after the intensity of fertility treatment. Nothing to achieve, only to rest.',
    reviews: [
      YogaReview(author: 'Zoya H.', note: 'I cried in the first savasana - in a good, releasing way.'),
      YogaReview(author: 'Gauri P.', stars: 5, note: 'The most restful 30 minutes of my week, every week.'),
    ],
    seed: 15,
  ),

  // ---- Breathing & Lamaze ---------------------------------------------------
  YogaClass(
    id: 'br_lamaze_group',
    title: 'Lamaze Breathing for Labour',
    category: 'breathing',
    instructorName: 'Farah Sheikh',
    instructorCredential: 'Lamaze Educator · 10 yrs',
    rating: 4.9,
    reviewsCount: 224,
    mode: YogaMode.liveGroup,
    schedule: 'Live · Sat · 5pm IST',
    durationLabel: '60 min',
    price: '₹799 / class',
    level: 'For labour',
    tagline: 'Practise the breath that carries you through birth.',
    about:
        'A live, hands-on Lamaze session teaching the breathing patterns for each stage of labour - so that when the day comes, the breath is already in your body. Partners are encouraged to join.',
    reviews: [
      YogaReview(author: 'Sunita R.', note: 'The patterned breathing genuinely got me through transition. I still hear Farah counting.'),
      YogaReview(author: 'Alia K.', stars: 5, note: 'My husband joined and finally knew how to help. Huge.'),
    ],
    seed: 16,
  ),
  YogaClass(
    id: 'br_1to1',
    title: 'Breath Coaching 1:1',
    category: 'breathing',
    instructorName: 'Farah Sheikh',
    instructorCredential: 'Lamaze Educator · 10 yrs',
    rating: 5.0,
    reviewsCount: 48,
    mode: YogaMode.liveOneToOne,
    schedule: 'Book a 1:1 slot · flexible timing',
    durationLabel: '45 min',
    price: '₹1,099 / session',
    level: 'All levels',
    tagline: 'Your breath, coached one-on-one.',
    about:
        'Private breath coaching - whether you are preparing a personal labour plan, managing anxiety, or learning to down-regulate a racing mind. Farah tailors every pattern to you.',
    reviews: [
      YogaReview(author: 'Charu D.', note: 'We built a breathing plan for my birth. I felt so prepared.'),
      YogaReview(author: 'Manasi V.', stars: 5, note: 'Also helped my panic attacks postpartum. Genuinely life-changing.'),
    ],
    seed: 17,
  ),
  YogaClass(
    id: 'br_pranayama_rec',
    title: 'Pranayama Basics',
    category: 'breathing',
    instructorName: 'Nisha Pillai',
    instructorCredential: 'Yoga & Breathwork Guide · 8 yrs',
    rating: 4.8,
    reviewsCount: 512,
    mode: YogaMode.recorded,
    schedule: 'Recorded · watch anytime',
    durationLabel: '15 min',
    price: 'Free on ParentVeda+',
    level: 'Beginner',
    tagline: 'The foundational breaths, clearly taught.',
    about:
        'A clear, unhurried introduction to the core pranayama techniques - ujjayi, nadi shodhana and simple extended exhales - and when to reach for each in daily life.',
    reviews: [
      YogaReview(author: 'Vidya S.', note: 'Finally understood alternate-nostril breathing instead of just copying it.'),
      YogaReview(author: 'Rohan M.', stars: 5, note: 'Fifteen minutes that changed how I handle stressful mornings.'),
    ],
    seed: 18,
  ),
  YogaClass(
    id: 'br_calm_rec',
    title: '3-Minute Calm Breath',
    category: 'breathing',
    instructorName: 'Nisha Pillai',
    instructorCredential: 'Yoga & Breathwork Guide · 8 yrs',
    rating: 4.7,
    reviewsCount: 340,
    mode: YogaMode.recorded,
    schedule: 'Recorded · watch anytime',
    durationLabel: '5 min',
    price: 'Free',
    level: 'All levels',
    tagline: 'A reset you can do while rocking the baby.',
    about:
        'A pocket-sized guided breath for the hard moments - three rounds to slow the heart, soften the jaw and come back to the present. Save it for the 2am wobbles.',
    reviews: [
      YogaReview(author: 'Preeti K.', note: 'I use this on the bathroom floor when it all gets too much. It works.'),
      YogaReview(author: 'Sameer T.', stars: 4, note: 'Short enough to actually do. That is the whole point.'),
    ],
    seed: 19,
  ),

  // ---- Meditation -----------------------------------------------------------
  YogaClass(
    id: 'md_group',
    title: 'Guided Meditation Circle',
    category: 'meditation',
    instructorName: 'Nisha Pillai',
    instructorCredential: 'Meditation & Breathwork Guide · 8 yrs',
    rating: 4.9,
    reviewsCount: 198,
    mode: YogaMode.liveGroup,
    schedule: 'Live · daily · 9pm IST',
    durationLabel: '20 min',
    price: '₹299 / class · free on ParentVeda+',
    level: 'All levels',
    tagline: 'End the day in a room full of calm.',
    about:
        'A gentle nightly sit - twenty guided minutes to unwind, let go of the day, and drop into sleep. Different theme each evening, no experience needed, cameras off if you like.',
    reviews: [
      YogaReview(author: 'Harini R.', note: 'The 9pm circle has become my favourite part of the day.'),
      YogaReview(author: 'Isha M.', stars: 5, note: 'Knowing others are sitting quietly with me keeps me consistent.'),
    ],
    seed: 20,
  ),
  YogaClass(
    id: 'md_1to1',
    title: '1:1 Meditation Coaching',
    category: 'meditation',
    instructorName: 'Nisha Pillai',
    instructorCredential: 'Meditation & Breathwork Guide · 8 yrs',
    rating: 5.0,
    reviewsCount: 40,
    mode: YogaMode.liveOneToOne,
    schedule: 'Book a 1:1 slot · flexible timing',
    durationLabel: '30 min',
    price: '₹899 / session',
    level: 'All levels',
    tagline: 'A practice for your particular mind.',
    about:
        'Private guidance to build a meditation habit that fits your real, interrupted life - working with new-parent anxiety, intrusive thoughts, or simply a mind that will not slow down.',
    reviews: [
      YogaReview(author: 'Tara S.', note: 'She helped me meditate in five-minute pockets instead of chasing an hour I never had.'),
      YogaReview(author: 'Kunal D.', stars: 5, note: 'Practical and kind. No incense-and-mystery, just what actually helps.'),
    ],
    seed: 21,
  ),
  YogaClass(
    id: 'md_sleep_rec',
    title: 'Sleep-Story Meditation',
    category: 'meditation',
    instructorName: 'Nisha Pillai',
    instructorCredential: 'Meditation & Breathwork Guide · 8 yrs',
    rating: 4.8,
    reviewsCount: 620,
    mode: YogaMode.recorded,
    schedule: 'Recorded · watch anytime',
    durationLabel: '15 min',
    price: 'Free on ParentVeda+',
    level: 'Gentle',
    tagline: 'Drift off before the story ends.',
    about:
        'A softly narrated wind-down to quiet a racing mind and carry you into sleep - for the nights when the baby is finally down but you still cannot switch off.',
    reviews: [
      YogaReview(author: 'Maya K.', note: 'I have never once heard the end. That is the highest praise I can give.'),
      YogaReview(author: 'Farhan S.', stars: 5, note: 'Rescued me during the four-month sleep regression.'),
    ],
    seed: 22,
  ),
  YogaClass(
    id: 'md_newmum_rec',
    title: 'Meditation for New Mothers',
    category: 'meditation',
    instructorName: 'Nisha Pillai',
    instructorCredential: 'Meditation & Breathwork Guide · 8 yrs',
    rating: 4.7,
    reviewsCount: 276,
    mode: YogaMode.recorded,
    schedule: 'Recorded · watch anytime',
    durationLabel: '12 min',
    price: '₹299',
    level: 'Gentle',
    tagline: 'A kind pause for the fourth-trimester fog.',
    about:
        'A tender, honest meditation for the overwhelm of early motherhood - naming the hard feelings, softening the guilt, and returning a little compassion to yourself.',
    reviews: [
      YogaReview(author: 'Ananya P.', note: 'The line about "you are enough today" undid me in the best way.'),
      YogaReview(author: 'Roshni V.', stars: 4, note: 'Felt like being understood, not fixed.'),
    ],
    seed: 23,
  ),

  // ---- Core & Recovery ------------------------------------------------------
  YogaClass(
    id: 'co_group',
    title: 'Core & Pelvic-Floor Rebuild',
    category: 'core',
    instructorName: 'Meghna Rao',
    instructorCredential: 'Pelvic Floor Physiotherapist · 11 yrs',
    rating: 4.9,
    reviewsCount: 182,
    mode: YogaMode.liveGroup,
    schedule: 'Live · Tue, Fri · 10am IST',
    durationLabel: '40 min',
    price: '₹499 / class',
    level: 'Postnatal',
    tagline: 'Rebuild the deep support system, together.',
    about:
        'A physiotherapist-led live class to reconnect and strengthen the deep core and pelvic floor after birth - the right way, in the right order. Addresses leaking, heaviness and that "core disconnect".',
    reviews: [
      YogaReview(author: 'Deepa S.', note: 'The leaking when I sneezed is basically gone. I did not know that was fixable.'),
      YogaReview(author: 'Vaishali M.', stars: 5, note: 'A real physio, not just an instructor. That made all the difference.'),
    ],
    seed: 24,
  ),
  YogaClass(
    id: 'co_1to1',
    title: 'Diastasis Recovery 1:1',
    category: 'core',
    instructorName: 'Meghna Rao',
    instructorCredential: 'Pelvic Floor Physiotherapist · 11 yrs',
    rating: 5.0,
    reviewsCount: 58,
    mode: YogaMode.liveOneToOne,
    schedule: 'Book a 1:1 slot · Mon–Sat',
    durationLabel: '45 min',
    price: '₹1,199 / session',
    level: 'Postnatal',
    tagline: 'A guided plan to close the gap, safely.',
    about:
        'Private assessment and a progressive plan for abdominal separation (diastasis recti). Meghna measures your gap, corrects the movements that make it worse, and rebuilds from the inside out.',
    reviews: [
      YogaReview(author: 'Swati R.', note: 'My four-finger gap is down to one. Objectively measurable progress.'),
      YogaReview(author: 'Nandini K.', stars: 5, note: 'She stopped me doing the planks that were making it worse. Wish I had found her sooner.'),
    ],
    seed: 25,
  ),
  YogaClass(
    id: 'co_deepcore_rec',
    title: 'Deep-Core Foundations',
    category: 'core',
    instructorName: 'Sana Kapoor',
    instructorCredential: 'Postnatal & Core Coach · 9 yrs',
    rating: 4.8,
    reviewsCount: 244,
    mode: YogaMode.recorded,
    schedule: 'Recorded · watch anytime',
    durationLabel: '20 min',
    price: 'Free on ParentVeda+',
    level: 'Beginner',
    tagline: 'The basics, before any crunches.',
    about:
        'The foundational deep-core work everyone skips - breath-led activation of the transverse abdominis and pelvic floor. Master this before you go anywhere near a sit-up.',
    reviews: [
      YogaReview(author: 'Aparna S.', note: 'Turns out I had never actually engaged my core correctly. Eye-opening.'),
      YogaReview(author: 'Jyoti M.', stars: 5, note: 'Twenty minutes, no equipment, real foundations.'),
    ],
    seed: 26,
  ),
  YogaClass(
    id: 'co_pelvic_rec',
    title: 'Pelvic-Floor Daily Ten',
    category: 'core',
    instructorName: 'Meghna Rao',
    instructorCredential: 'Pelvic Floor Physiotherapist · 11 yrs',
    rating: 4.7,
    reviewsCount: 210,
    mode: YogaMode.recorded,
    schedule: 'Recorded · watch anytime',
    durationLabel: '10 min',
    price: '₹299',
    level: 'All levels',
    tagline: 'Ten minutes that add up.',
    about:
        'A short, do-it-anywhere daily routine of correct pelvic-floor work - not just endless kegels, but the coordinated release-and-lift that actually builds control. Great alongside any recovery plan.',
    reviews: [
      YogaReview(author: 'Ruchi V.', note: 'I do it while the kettle boils. Small habit, big difference.'),
      YogaReview(author: 'Sneha T.', stars: 4, note: 'Loved learning that relaxing matters as much as squeezing.'),
    ],
    seed: 27,
  ),
];

// ---- lookups ----------------------------------------------------------------
YogaCategory yogaCategoryById(String id) =>
    kYogaCategories.firstWhere((c) => c.id == id, orElse: () => kYogaCategories.first);

YogaClass yogaClassById(String id) =>
    kYogaClasses.firstWhere((c) => c.id == id, orElse: () => kYogaClasses.first);

/// All classes delivered in [mode].
List<YogaClass> yogaClassesByMode(YogaMode mode) =>
    kYogaClasses.where((c) => c.mode == mode).toList();

/// Classes in one category, filtered to a single mode (the cult.fit rail).
List<YogaClass> yogaClassesIn(String categoryId, YogaMode mode) =>
    kYogaClasses.where((c) => c.category == categoryId && c.mode == mode).toList();

/// Categories that actually have at least one class in [mode] - so the home only
/// renders section headers that have a non-empty rail underneath.
List<YogaCategory> yogaCategoriesWithClasses(YogaMode mode) =>
    kYogaCategories.where((cat) => yogaClassesIn(cat.id, mode).isNotEmpty).toList();

/// Free-text search across title, instructor and category (mode-agnostic).
List<YogaClass> yogaSearch(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  return kYogaClasses.where((c) {
    return c.title.toLowerCase().contains(q) ||
        c.instructorName.toLowerCase().contains(q) ||
        c.categoryInfo.title.toLowerCase().contains(q) ||
        c.level.toLowerCase().contains(q);
  }).toList();
}

// =============================================================================
//  YogaStore - saved + booked classes (in-memory seed). A ChangeNotifier
//  singleton, matching the app's other stores. Booking/payment is mocked.
// =============================================================================
class YogaStore extends ChangeNotifier with CloudSyncedStore {
  YogaStore._();
  static final YogaStore instance = YogaStore._();

  final Set<String> _saved = {'pn_group', 'md_sleep_rec'};
  final Set<String> _booked = {};

  // ---- persistence (user_state KV; own-only, a personal preference) --------
  static const _prefsKey = 'pp_yoga';

  @override
  String get cloudKey => _prefsKey;

  @override
  Object cloudData() =>
      {'saved': _saved.toList(), 'booked': _booked.toList()};

  @override
  void applyCloudData(Object data) {
    if (data is! Map) return;
    final s = data['saved'];
    if (s is List) _saved..clear()..addAll(s.map((e) => e.toString()));
    final b = data['booked'];
    if (b is List) _booked..clear()..addAll(b.map((e) => e.toString()));
  }

  @override
  Future<void> persistLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(cloudData()));
    } catch (_) {}
  }

  // The mixin's override pushes to the cloud; this keeps the LOCAL cache
  // current too, so an offline/logged-out user still gets persistence. Every
  // mutation already calls notifyListeners(), so one override covers them all.
  @override
  void notifyListeners() {
    super.notifyListeners();
    persistLocalCache();
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) applyCloudData(jsonDecode(raw));
    } catch (_) {/* keep the starter state */}
    notifyListeners();
    try {
      await syncStateFromCloud();
    } catch (_) {/* stay local */}
  }


  bool isSaved(String id) => _saved.contains(id);
  void toggleSave(String id) {
    _saved.contains(id) ? _saved.remove(id) : _saved.add(id);
    notifyListeners();
  }

  List<YogaClass> get saved => _saved.map(yogaClassById).toList();

  bool isBooked(String id) => _booked.contains(id);
  void book(String id) {
    if (_booked.add(id)) notifyListeners();
  }

  void cancelBooking(String id) {
    if (_booked.remove(id)) notifyListeners();
  }

  List<YogaClass> get booked => _booked.map(yogaClassById).toList();
}

/// Everything else this instructor teaches. A parent deciding on a 1:1 session
/// is really deciding on a person, and seeing their other classes is the
/// cheapest way to judge whether they are the right one.
List<YogaClass> classesByInstructor(String name, {String? excludeId}) =>
    kYogaClasses.where((c) => c.instructorName == name && c.id != excludeId).toList();
