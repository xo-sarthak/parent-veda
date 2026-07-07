// =============================================================================
//  JournalEntry - the unit of "My Journal" (the mother's pregnancy timeline)
// -----------------------------------------------------------------------------
//  My Journal is a chronological memory timeline, not a tracker. Entries are
//  either MANUAL (a memory, a note for baby, a photo, a voice note) or
//  AUTOMATIC (milestones + health logs derived from her activity). Each entry
//  carries a subtle category colour + icon per the spec's colour system.
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The kind of a journal entry. The first four are created by the mother; the
/// rest are auto-derived (milestones, weight, kicks, scans, symptoms).
enum JournalEntryType {
  memory,
  noteForBaby,
  photo,
  voice,
  custom,
  symptom,
  weight,
  kick,
  scan,
  milestone,
}

/// Top-of-timeline filter buckets (the chips).
enum JournalFilter { all, memories, photos, milestones, health, scans, baby }

class JournalEntry {
  JournalEntry({
    required this.id,
    required this.type,
    required this.title,
    this.description = '',
    required this.date,
    this.weekNumber = 0,
    String? imageUrl,
    String? audioUrl,
    List<String>? imageUrls,
    List<String>? audioUrls,
    this.customTag = '',
    this.tags = const [],
    this.isAutomatic = false,
    this.isPartner = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : imageUrl = imageUrl,
        audioUrl = audioUrl,
        imageUrls = imageUrls ??
            (imageUrl != null && imageUrl.isNotEmpty ? [imageUrl] : const []),
        audioUrls = audioUrls ??
            (audioUrl != null && audioUrl.isNotEmpty ? [audioUrl] : const []),
        createdAt = createdAt ?? date,
        updatedAt = updatedAt ?? date;

  final String id;
  final JournalEntryType type;
  final String title;
  final String description;
  final DateTime date;
  final int weekNumber;
  final String? imageUrl; // legacy single photo path (kept for back-compat)
  final String? audioUrl; // legacy single audio path (kept for back-compat)
  final List<String> imageUrls; // multiple photos (carousel)
  final List<String> audioUrls; // multiple voice notes (carousel)
  final String customTag; // user-named tag for `custom` entries
  final List<String> tags;
  final bool isAutomatic;

  /// TRANSIENT (never serialized): true when this entry belongs to the paired
  /// partner (the father), surfaced read-only in the mother's merged timeline.
  final bool isPartner;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get trimester => weekNumber <= 13 ? 1 : (weekNumber <= 27 ? 2 : 3);

  /// All photo paths (falls back to the legacy single).
  List<String> get images => imageUrls.isNotEmpty
      ? imageUrls
      : (imageUrl != null && imageUrl!.isNotEmpty ? [imageUrl!] : const []);

  /// All voice-note paths (falls back to the legacy single).
  List<String> get audios => audioUrls.isNotEmpty
      ? audioUrls
      : (audioUrl != null && audioUrl!.isNotEmpty ? [audioUrl!] : const []);

  JournalEntry copyWith({
    String? title,
    String? description,
    List<String>? imageUrls,
    List<String>? audioUrls,
    String? customTag,
  }) =>
      JournalEntry(
        id: id,
        type: type,
        title: title ?? this.title,
        description: description ?? this.description,
        date: date,
        weekNumber: weekNumber,
        imageUrls: imageUrls ?? this.imageUrls,
        audioUrls: audioUrls ?? this.audioUrls,
        customTag: customTag ?? this.customTag,
        tags: tags,
        isAutomatic: isAutomatic,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'weekNumber': weekNumber,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'imageUrls': imageUrls,
        'audioUrls': audioUrls,
        'customTag': customTag,
        'tags': tags,
        'isAutomatic': isAutomatic,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> j) {
    var t = JournalEntryType.memory;
    for (final e in JournalEntryType.values) {
      if (e.name == j['type']) {
        t = e;
        break;
      }
    }
    DateTime parse(Object? v) =>
        DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now();
    List<String> strList(Object? v) =>
        (v as List?)?.map((e) => e.toString()).toList() ?? const [];
    return JournalEntry(
      id: (j['id'] ?? '').toString(),
      type: t,
      title: (j['title'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      date: parse(j['date']),
      weekNumber: (j['weekNumber'] is int)
          ? j['weekNumber'] as int
          : int.tryParse('${j['weekNumber']}') ?? 0,
      imageUrl: (j['imageUrl'] == null) ? null : j['imageUrl'].toString(),
      audioUrl: (j['audioUrl'] == null) ? null : j['audioUrl'].toString(),
      imageUrls: j['imageUrls'] == null ? null : strList(j['imageUrls']),
      audioUrls: j['audioUrls'] == null ? null : strList(j['audioUrls']),
      customTag: (j['customTag'] ?? '').toString(),
      tags: strList(j['tags']),
      isAutomatic: j['isAutomatic'] == true,
      createdAt: parse(j['createdAt']),
      updatedAt: parse(j['updatedAt']),
    );
  }
}

/// Subtle visual + grouping metadata per entry type (per the spec's colours).
class JournalMeta {
  const JournalMeta(this.color, this.icon, this.filter);
  final Color color;
  final IconData icon;
  final JournalFilter filter;
}

// Subtle category colours (kept gentle, per spec "never overwhelming").
const Color _jOrange = Color(0xFFE0921C); // Memories - warm
const Color _jPink = Color(0xFFFF5A79); // Photos
const Color _jPurple = AppTheme.primary500; // Milestones
const Color _jBlue = Color(0xFF4A7BC8); // Health
const Color _jTeal = Color(0xFF2E9C8E); // Scans
const Color _jGreen = Color(0xFF4F7A52); // Baby

const Map<JournalEntryType, JournalMeta> kJournalMeta = {
  JournalEntryType.memory:
      JournalMeta(_jOrange, Icons.auto_stories_rounded, JournalFilter.memories),
  JournalEntryType.voice:
      JournalMeta(_jOrange, Icons.mic_rounded, JournalFilter.memories),
  JournalEntryType.custom:
      JournalMeta(_jPurple, Icons.label_rounded, JournalFilter.memories),
  JournalEntryType.noteForBaby:
      JournalMeta(_jGreen, Icons.favorite_rounded, JournalFilter.baby),
  JournalEntryType.photo:
      JournalMeta(_jPink, Icons.photo_rounded, JournalFilter.photos),
  JournalEntryType.milestone: JournalMeta(
      _jPurple, Icons.emoji_events_rounded, JournalFilter.milestones),
  JournalEntryType.weight:
      JournalMeta(_jBlue, Icons.monitor_weight_rounded, JournalFilter.health),
  JournalEntryType.kick:
      JournalMeta(_jBlue, Icons.child_care_rounded, JournalFilter.health),
  JournalEntryType.symptom:
      JournalMeta(_jBlue, Icons.healing_rounded, JournalFilter.health),
  JournalEntryType.scan:
      JournalMeta(_jTeal, Icons.medical_services_rounded, JournalFilter.scans),
};

JournalMeta metaFor(JournalEntryType t) =>
    kJournalMeta[t] ??
    const JournalMeta(_jOrange, Icons.bookmark_rounded, JournalFilter.memories);
