// =============================================================================
//  My Journal V2 - data models + realistic sample content
// -----------------------------------------------------------------------------
//  Meaningful, hand-written sample content (no Lorem Ipsum), per the spec.
//  Scenario: Priya keeping the story of her son Aarav (born Jan 2023).
// =============================================================================

import 'package:flutter/material.dart';

// A captured memory: a moment, a written story, or a guided milestone.
enum JvKind { moment, story, letter, guided }

class JvMemory {
  const JvMemory({
    required this.title,
    required this.date,
    required this.age,
    required this.body,
    required this.kind,
    required this.seed,
    this.mediaCount = 1,
  });
  final String title;
  final String date; // "12 July 2025"
  final String age; // "2 years 4 months"
  final String body;
  final JvKind kind;
  final int seed; // photo tint
  final int mediaCount;
}

class JvGuidedPrompt {
  const JvGuidedPrompt(this.title, this.subtitle, this.minutes, this.icon, {this.done = false});
  final String title;
  final String subtitle;
  final int minutes;
  final IconData icon;
  final bool done;
}

class JvChapter {
  const JvChapter(this.title, this.page, this.seed, {this.label});
  final String title;
  final int page;
  final int seed;
  final String? label; // "Chapter 1" / "Welcome" / "Letters"
}

class JvStorybook {
  const JvStorybook(this.title, this.years, this.detail, this.seed);
  final String title;
  final String years;
  final String detail; // "248 memories"
  final int seed;
}

class JvMilestone {
  const JvMilestone(this.title, this.date);
  final String title;
  final String date;
}

// ---- the child / parent -----------------------------------------------------
const String jvChild = 'Aarav';
const String jvParent = 'Priya';
const String jvChildAge = '2 years, 4 months old';
const String jvBornSince = 'Since 18 Jan 2023';

// ---- memories ---------------------------------------------------------------
const JvMemory jvFeatured = JvMemory(
  title: 'Puppy Kisses!',
  date: '12 July 2025',
  age: '2 years 4 months',
  body: 'You laughed so hard when the puppy licked your face for the first time today. That smile is everything.',
  kind: JvKind.moment,
  seed: 1,
  mediaCount: 4,
);

const List<JvMemory> jvMemories = [
  jvFeatured,
  JvMemory(
    title: 'First Day at School',
    date: '20 June 2025',
    age: '2 years 3 months',
    body: 'You were so brave walking in on your own - no tears, just a little wave goodbye and a grin over your shoulder.',
    kind: JvKind.guided,
    seed: 2,
  ),
  JvMemory(
    title: 'Beach Day',
    date: '5 May 2025',
    age: '2 years 2 months',
    body: 'Your first time feeling sand between your toes. You chased every wave and did not want to leave when the sun went down.',
    kind: JvKind.moment,
    seed: 3,
    mediaCount: 3,
  ),
  JvMemory(
    title: 'The day you discovered bananas',
    date: '5 May 2025',
    age: '2 years 2 months',
    body: 'You held it like a treasure, studied it, then decided your cheeks were the best place for it. Pure joy, entirely mashed.',
    kind: JvKind.story,
    seed: 5,
  ),
  JvMemory(
    title: 'First Bicycle Ride',
    date: '18 April 2025',
    age: '2 years 1 month',
    body: 'Wobbly, determined, and grinning the whole way down the lane while Papa ran alongside pretending not to hold on.',
    kind: JvKind.moment,
    seed: 4,
    mediaCount: 2,
  ),
];

// ---- letters ----------------------------------------------------------------
const String jvLetterBody =
    'Dear Aarav,\n\nOne day, when you read this letter, I hope you know how much love and joy you bring to our lives - every single day.\n\nThe way you laugh, the way you reach for us in the morning, the way you see wonder in the smallest things - it changes everything.\n\nWhatever you grow up to be, know that you were loved from the very first moment.\n\nLove,\nMom';

const List<JvMemory> jvLetters = [
  JvMemory(
    title: 'A letter for the future',
    date: '12 July 2025',
    age: '2 years 4 months',
    body: jvLetterBody,
    kind: JvKind.letter,
    seed: 0,
  ),
  JvMemory(
    title: 'A letter about bananas',
    date: '12 May 2025',
    age: '2 years 2 months',
    body:
        'Dear Aarav,\n\nToday you learned you could feed yourself. It was messy and magnificent, and I never want to forget the look on your face.\n\nLove,\nMom',
    kind: JvKind.letter,
    seed: 5,
  ),
];

// ---- guided prompts ---------------------------------------------------------
const List<JvGuidedPrompt> jvGuided = [
  JvGuidedPrompt('First Day at School', 'A big milestone', 2, Icons.school_outlined),
  JvGuidedPrompt('First Sleepover', 'Capture this memory', 2, Icons.night_shelter_outlined),
  JvGuidedPrompt('Learned to Ride', 'A proud moment', 2, Icons.pedal_bike_outlined),
  JvGuidedPrompt('Favourite Food', 'What do they love?', 1, Icons.restaurant_outlined),
  JvGuidedPrompt('Family Vacation', 'Memories from the trip', 2, Icons.beach_access_outlined),
];

// ---- storybook --------------------------------------------------------------
const List<JvChapter> jvChapters = [
  JvChapter('Welcome Little One', 1, 6, label: 'Welcome'),
  JvChapter('Tiny Beginnings', 7, 2, label: 'Chapter 1'),
  JvChapter('Growing Together', 24, 3, label: 'Chapter 2'),
  JvChapter('First Adventures', 42, 4, label: 'Chapter 3'),
  JvChapter('First Birthday', 68, 5, label: 'Chapter 4'),
  JvChapter('Letters', 95, 0, label: 'Letters'),
  JvChapter('Timeline', 120, 1, label: 'Timeline'),
];

const JvStorybook jvOurStory = JvStorybook('Our Story', '2023 – 2025', '248 memories', 2);

const List<JvStorybook> jvStorybooks = [
  jvOurStory,
  JvStorybook('Year One', '2023', '120 memories', 5),
  JvStorybook('Letters to Aarav', 'Ongoing', '18 letters', 0),
];

const List<JvMilestone> jvMilestones = [
  JvMilestone('First Smile', '23 Mar 2023'),
  JvMilestone('First Laugh', '12 Apr 2023'),
  JvMilestone('First Tooth', '18 Jun 2023'),
  JvMilestone('First Steps', '5 Sep 2023'),
  JvMilestone('First Day at School', '20 Jun 2025'),
];

// ---- monthly auto-cover -----------------------------------------------------
const String jvMonthlyTitle = 'July 2026';
const List<String> jvMonthlyItems = [
  'You learned to laugh out loud',
  'You met Grandma for the first time',
  'You loved bananas (all over your face)',
  'You discovered water at the beach',
];
