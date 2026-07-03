// =============================================================================
//  Symptom + SymptomLog — "Symptoms Companion"
// -----------------------------------------------------------------------------
//  Not a tracker or checker — an understanding & reassurance library. Each
//  symptom answers: how common is it, why it happens, what may help, and when
//  to contact a doctor. Logging is optional. Urgent symptoms are a calm,
//  clearly-flagged category (no panic language). Content is bilingual.
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../theme/app_theme.dart';

enum SymptomCategory {
  digestive,
  physical,
  sleep,
  emotional,
  circulation,
  movement,
  labour,
  urgent,
}

class Symptom {
  const Symptom({
    required this.id,
    required this.name,
    required this.category,
    required this.commonness,
    required this.why,
    required this.tips,
    required this.doctorGuidance,
    this.trimesters = const [1, 2, 3],
    this.keywords = const [],
    this.urgent = false,
  });

  final String id;
  final LocalizedText name;
  final SymptomCategory category;
  final LocalizedText commonness; // "How common is it?"
  final LocalizedText why; // "Why it happens"
  final List<LocalizedText> tips; // "What may help"
  final LocalizedText doctorGuidance; // "When to contact your doctor"
  final List<int> trimesters;
  final List<String> keywords; // search synonyms (lowercase)
  final bool urgent;

  bool commonInTrimester(int t) => trimesters.contains(t);

  bool matchesQuery(String q, AppLanguage lang) {
    final query = q.toLowerCase().trim();
    if (query.isEmpty) return true;
    return name.of(lang).toLowerCase().contains(query) ||
        name.en.toLowerCase().contains(query) ||
        keywords.any((k) => k.contains(query));
  }
}

class SymptomCatMeta {
  const SymptomCatMeta(this.color, this.icon);
  final Color color;
  final IconData icon;
}

const Map<SymptomCategory, SymptomCatMeta> kSymptomCatMeta = {
  SymptomCategory.digestive:
      SymptomCatMeta(Color(0xFFC9831F), Icons.restaurant_rounded),
  SymptomCategory.physical:
      SymptomCatMeta(AppTheme.primary500, Icons.accessibility_new_rounded),
  SymptomCategory.sleep:
      SymptomCatMeta(Color(0xFF4A7BC8), Icons.bedtime_rounded),
  SymptomCategory.emotional:
      SymptomCatMeta(AppTheme.secondary500, Icons.favorite_rounded),
  SymptomCategory.circulation:
      SymptomCatMeta(Color(0xFF2E9C8E), Icons.monitor_heart_rounded),
  SymptomCategory.movement:
      SymptomCatMeta(Color(0xFF4F7A52), Icons.child_care_rounded),
  SymptomCategory.labour:
      SymptomCatMeta(AppTheme.tertiary500, Icons.timer_rounded),
  SymptomCategory.urgent:
      SymptomCatMeta(AppTheme.secondary700, Icons.health_and_safety_rounded),
};

SymptomCatMeta symptomCatMeta(SymptomCategory c) =>
    kSymptomCatMeta[c] ??
    const SymptomCatMeta(AppTheme.primary500, Icons.spa_rounded);

class SymptomLog {
  const SymptomLog({
    required this.id,
    required this.symptomId,
    required this.dateKey,
    required this.severity, // 'mild' | 'moderate' | 'severe'
    this.notes = '',
    required this.createdAtIso,
  });

  final String id;
  final String symptomId;
  final String dateKey; // yyyy-MM-dd
  final String severity;
  final String notes;
  final String createdAtIso;

  Map<String, dynamic> toJson() => {
        'id': id,
        'symptomId': symptomId,
        'dateKey': dateKey,
        'severity': severity,
        'notes': notes,
        'createdAtIso': createdAtIso,
      };

  factory SymptomLog.fromJson(Map<String, dynamic> j) => SymptomLog(
        id: (j['id'] ?? '').toString(),
        symptomId: (j['symptomId'] ?? '').toString(),
        dateKey: (j['dateKey'] ?? '').toString(),
        severity: (j['severity'] ?? 'mild').toString(),
        notes: (j['notes'] ?? '').toString(),
        createdAtIso: (j['createdAtIso'] ?? '').toString(),
      );
}
