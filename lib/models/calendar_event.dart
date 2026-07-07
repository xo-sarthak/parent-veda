// =============================================================================
//  CalendarEvent - the unit of "My Calendar" (the pregnancy command center)
// -----------------------------------------------------------------------------
//  A single event on the calendar / journey timeline / upcoming list. Most are
//  SYSTEM-generated (milestones, medical, ParentVeda unlocks, journal/health
//  logs); PERSONAL events are added by the mother and persisted. Each category
//  has a subtle dot colour per the spec (purple/blue/green/pink/gold/grey).
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum CalEventCategory {
  milestone, // purple - pregnancy/system milestones
  medical, // blue - scans, tests, vaccinations
  appointment, // green - doctor appointments
  journal, // pink - memories, photos, weight, kicks
  personal, // grey - mother-added events
  parentveda, // gold - feature unlocks, "days together"
}

enum CalEventStatus { completed, current, upcoming }

class CalendarEvent {
  CalendarEvent({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.date,
    this.weekNumber = 0,
    this.status = CalEventStatus.upcoming,
    this.isSystemGenerated = true,
    this.weekRef,
    this.opensJournal = false,
  });

  final String id;
  final String title;
  final String description;
  final CalEventCategory category;
  final DateTime date;
  final int weekNumber;
  final CalEventStatus status;
  final bool isSystemGenerated;

  /// If set, the event's detail offers "Open Week N" (the weekly stack).
  final int? weekRef;

  /// If true, the event's detail offers "Open Journal".
  final bool opensJournal;

  int get trimester => weekNumber <= 13 ? 1 : (weekNumber <= 27 ? 2 : 3);

  // Only PERSONAL events are persisted (the rest are regenerated each load).
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
      };

  factory CalendarEvent.personalFromJson(Map<String, dynamic> j) => CalendarEvent(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        description: (j['description'] ?? '').toString(),
        category: CalEventCategory.personal,
        date: DateTime.tryParse(j['date']?.toString() ?? '') ?? DateTime.now(),
        isSystemGenerated: false,
      );
}

/// Subtle dot colour + icon per category (per the spec's colour system).
class CalMeta {
  const CalMeta(this.color, this.icon);
  final Color color;
  final IconData icon;
}

const Color _cPurple = AppTheme.primary500;
const Color _cBlue = Color(0xFF4A7BC8);
const Color _cGreen = Color(0xFF4F7A52);
const Color _cPink = Color(0xFFFF5A79);
const Color _cGold = Color(0xFFE0921C);
const Color _cGrey = Color(0xFF8A8590);

const Map<CalEventCategory, CalMeta> kCalMeta = {
  CalEventCategory.milestone:
      CalMeta(_cPurple, Icons.emoji_events_rounded),
  CalEventCategory.medical: CalMeta(_cBlue, Icons.medical_services_rounded),
  CalEventCategory.appointment:
      CalMeta(_cGreen, Icons.event_available_rounded),
  CalEventCategory.journal: CalMeta(_cPink, Icons.auto_stories_rounded),
  CalEventCategory.personal: CalMeta(_cGrey, Icons.push_pin_rounded),
  CalEventCategory.parentveda: CalMeta(_cGold, Icons.spa_rounded),
};

CalMeta calMeta(CalEventCategory c) =>
    kCalMeta[c] ?? const CalMeta(_cGrey, Icons.event_rounded);
