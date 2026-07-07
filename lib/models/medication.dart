// =============================================================================
//  Medication + MedicationLog - "Daily Medication & Supplement Tracking"
// -----------------------------------------------------------------------------
//  A pregnancy nourishment companion, not a pillbox. A Medication is something
//  the doctor recommended (supplement / medicine / custom); a MedicationLog
//  records that it was taken on a given day. Tracking only - never advice.
// =============================================================================

import 'package:flutter/foundation.dart';

enum MedType { supplement, medication, custom }

/// Common pregnancy supplements offered at setup (educational text lives in S).
const List<String> kMedPresetKeys = [
  'iron',
  'calcium',
  'folicAcid',
  'vitaminD',
  'dha',
  'multivitamin',
];

@immutable
class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.type,
    this.dose = '',
    this.time = '',
    this.frequency = '',
    this.notes = '',
    this.presetKey,
    required this.startDateIso,
    this.endDateIso,
    this.isActive = true,
  });

  final String id;
  final String name;
  final MedType type;
  final String dose;
  final String time;
  final String frequency;
  final String notes;

  /// For preset supplements (iron/calcium/…) - drives the educational blurb.
  final String? presetKey;
  final String startDateIso;
  final String? endDateIso;
  final bool isActive;

  Medication copyWith({
    String? name,
    String? dose,
    String? time,
    String? frequency,
    String? notes,
    bool? isActive,
    String? endDateIso,
  }) =>
      Medication(
        id: id,
        name: name ?? this.name,
        type: type,
        dose: dose ?? this.dose,
        time: time ?? this.time,
        frequency: frequency ?? this.frequency,
        notes: notes ?? this.notes,
        presetKey: presetKey,
        startDateIso: startDateIso,
        endDateIso: endDateIso ?? this.endDateIso,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'dose': dose,
        'time': time,
        'frequency': frequency,
        'notes': notes,
        'presetKey': presetKey,
        'startDateIso': startDateIso,
        'endDateIso': endDateIso,
        'isActive': isActive,
      };

  factory Medication.fromJson(Map<String, dynamic> j) {
    var t = MedType.supplement;
    for (final e in MedType.values) {
      if (e.name == j['type']) {
        t = e;
        break;
      }
    }
    return Medication(
      id: (j['id'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      type: t,
      dose: (j['dose'] ?? '').toString(),
      time: (j['time'] ?? '').toString(),
      frequency: (j['frequency'] ?? '').toString(),
      notes: (j['notes'] ?? '').toString(),
      presetKey: j['presetKey']?.toString(),
      startDateIso: (j['startDateIso'] ?? '').toString(),
      endDateIso: j['endDateIso']?.toString(),
      isActive: j['isActive'] != false,
    );
  }
}

@immutable
class MedicationLog {
  const MedicationLog({
    required this.id,
    required this.medicationId,
    required this.dateKey,
    required this.takenAtIso,
  });

  final String id;
  final String medicationId;
  final String dateKey; // yyyy-MM-dd
  final String takenAtIso;

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicationId': medicationId,
        'dateKey': dateKey,
        'takenAtIso': takenAtIso,
      };

  factory MedicationLog.fromJson(Map<String, dynamic> j) => MedicationLog(
        id: (j['id'] ?? '').toString(),
        medicationId: (j['medicationId'] ?? '').toString(),
        dateKey: (j['dateKey'] ?? '').toString(),
        takenAtIso: (j['takenAtIso'] ?? '').toString(),
      );
}
