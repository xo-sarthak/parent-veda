// =============================================================================
//  Focused courses — catalogue + Go-Deeper lookup
// -----------------------------------------------------------------------------
//  Short, focused courses that sit alongside the flagship "Complete Parenting
//  Guide". Their lessons are named to match the "Go deeper · Course" rows across
//  the app (activities, challenges), so a Course row opens the RIGHT course with
//  the referenced lesson highlighted — never the generic list. Static content;
//  playback is previewed through the existing course funnel.
// =============================================================================

import 'package:flutter/material.dart';

class CourseLesson {
  const CourseLesson(this.title, this.minutes, {this.locked = false});
  final String title;
  final int minutes;
  final bool locked;
}

class Course {
  const Course({
    required this.id,
    required this.title,
    required this.tagline,
    required this.about,
    required this.expert,
    required this.ageTag,
    required this.accent,
    required this.lessons,
  });

  final String id;
  final String title; // "Play & Brain"
  final String tagline;
  final String about;
  final String expert; // vetted by
  final String ageTag; // "3–6 months"
  final Color accent;
  final List<CourseLesson> lessons;

  int get totalMinutes => lessons.fold<int>(0, (a, l) => a + l.minutes);
}

const Color _violet = Color(0xFF6A30B6);
const Color _amber = Color(0xFFC98A2B);
const Color _rose = Color(0xFFFF5A79);
const Color _blue = Color(0xFF3E6DA6);

const List<Course> kCourses = [
  Course(
    id: 'playbrain',
    title: 'Play & Brain',
    tagline: 'How the right play grows a four-month-old mind.',
    about:
        'A short, practical course on what your baby is working out right now — cause and effect, object permanence, hand-eye coordination — and the simple, everyday play that supports each one. No flashcards, no pressure; just the "why" behind the games.',
    expert: 'Vetted by Dr. Ananya Rao, Paediatrician',
    ageTag: '3–6 months',
    accent: _violet,
    lessons: [
      CourseLesson('Leap 4 activities', 12),
      CourseLesson('Reaching & hand skills', 10),
      CourseLesson('Sound & listening', 9),
      CourseLesson('High-contrast play', 8),
      CourseLesson('Peekaboo & object permanence', 11, locked: true),
    ],
  ),
  Course(
    id: 'motor',
    title: 'Motor Skills',
    tagline: 'The road from tummy time to those first steps.',
    about:
        'Every big movement builds on the last. This course walks the physical journey — head control, rolling, sitting, crawling — with the gentle, joyful practice that helps each one arrive in its own time.',
    expert: 'Vetted by Dr. Meher Shah, Paediatric Physio',
    ageTag: '2–12 months',
    accent: _amber,
    lessons: [
      CourseLesson('The road to rolling', 11),
      CourseLesson('Tummy-time that works', 9),
      CourseLesson('Sitting with support', 10, locked: true),
      CourseLesson('Crawling begins', 12, locked: true),
    ],
  ),
  Course(
    id: 'language',
    title: 'Language & Communication',
    tagline: 'The conversation that starts long before the first word.',
    about:
        'Your baby is learning language now, in the everyday back-and-forth. This course shows how narration, "serve and return", and simple songs wire the brain for talking — months before real words appear.',
    expert: 'Vetted by Dr. Kabir Menon, Speech & Language',
    ageTag: '3–12 months',
    accent: _rose,
    lessons: [
      CourseLesson('The talking baby', 10),
      CourseLesson('Serve & return', 9),
      CourseLesson('Narrate your day', 8),
      CourseLesson('From coos to first words', 11, locked: true),
    ],
  ),
  Course(
    id: 'sleep',
    title: 'Sleep Bootcamp',
    tagline: 'Understanding baby sleep — and working with it, gently.',
    about:
        'A calm, no-cry course through the science of infant sleep and the 4-month shift. Learn what is actually happening, what genuinely helps, and how to build a wind-down your baby can rely on.',
    expert: 'Vetted by Dr. Meher Shah, Paediatric Sleep',
    ageTag: '3–6 months',
    accent: _blue,
    lessons: [
      CourseLesson('Module 1 · Understanding baby sleep', 14),
      CourseLesson('Module 2 · The 4-month regression', 16),
      CourseLesson('Module 3 · Drowsy but awake', 12, locked: true),
      CourseLesson('Module 4 · Building a wind-down', 11, locked: true),
    ],
  ),
];

Course courseById(String id) => kCourses.firstWhere((c) => c.id == id, orElse: () => kCourses.first);

/// Match a "Go deeper · Course" row text ("Play & Brain · Leap 4 activities") to
/// a course. Uses the part before the "·" as the course name. Null if unmatched.
Course? courseByDeeperText(String text) {
  final head = text.split('·').first.trim().toLowerCase();
  if (head.isEmpty) return null;
  for (final c in kCourses) {
    final t = c.title.toLowerCase();
    if (t.contains(head) || head.contains(t)) return c;
  }
  return null;
}

/// The lesson index a Go-Deeper text points at ("· Leap 4 activities" / "· Module
/// 2"), so the detail can mark it "Start here". Returns -1 if not found.
int lessonIndexForDeeperText(Course course, String text) {
  final parts = text.split('·');
  if (parts.length < 2) return -1;
  final tail = parts.sublist(1).join('·').trim().toLowerCase();
  if (tail.isEmpty) return -1;
  for (var i = 0; i < course.lessons.length; i++) {
    if (course.lessons[i].title.toLowerCase().contains(tail)) return i;
  }
  return -1;
}
