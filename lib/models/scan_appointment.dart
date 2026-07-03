// =============================================================================
//  Scan & Appointment models — "Scans & Appointments" care roadmap
// -----------------------------------------------------------------------------
//  Scan *content* (the roadmap) is reused from kJourneyMilestones (type medical).
//  Here we only persist the mother's own data: which scans she marked completed,
//  and the appointments she added. Completed scans flow into the Journal; the
//  appointments flow into the Calendar.
// =============================================================================

import 'package:flutter/foundation.dart';

enum ApptType { doctor, scan, test, vaccination, custom }

@immutable
class CompletedScan {
  const CompletedScan(
      {required this.scanId, required this.dateIso, this.notes = ''});
  final String scanId;
  final String dateIso;
  final String notes;

  Map<String, dynamic> toJson() =>
      {'scanId': scanId, 'dateIso': dateIso, 'notes': notes};

  factory CompletedScan.fromJson(Map<String, dynamic> j) => CompletedScan(
        scanId: (j['scanId'] ?? '').toString(),
        dateIso: (j['dateIso'] ?? '').toString(),
        notes: (j['notes'] ?? '').toString(),
      );
}

@immutable
class Appointment {
  const Appointment({
    required this.id,
    required this.title,
    required this.dateIso,
    this.time = '',
    this.location = '',
    this.doctor = '',
    this.type = ApptType.doctor,
    this.notes = '',
    this.status = 'upcoming',
  });

  final String id;
  final String title;
  final String dateIso;
  final String time;
  final String location;
  final String doctor;
  final ApptType type;
  final String notes;
  final String status; // 'upcoming' | 'completed'

  DateTime get date => DateTime.tryParse(dateIso) ?? DateTime.now();

  Appointment copyWith({String? status}) => Appointment(
        id: id,
        title: title,
        dateIso: dateIso,
        time: time,
        location: location,
        doctor: doctor,
        type: type,
        notes: notes,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dateIso': dateIso,
        'time': time,
        'location': location,
        'doctor': doctor,
        'type': type.name,
        'notes': notes,
        'status': status,
      };

  factory Appointment.fromJson(Map<String, dynamic> j) {
    var t = ApptType.doctor;
    for (final e in ApptType.values) {
      if (e.name == j['type']) {
        t = e;
        break;
      }
    }
    return Appointment(
      id: (j['id'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      dateIso: (j['dateIso'] ?? '').toString(),
      time: (j['time'] ?? '').toString(),
      location: (j['location'] ?? '').toString(),
      doctor: (j['doctor'] ?? '').toString(),
      type: t,
      notes: (j['notes'] ?? '').toString(),
      status: (j['status'] ?? 'upcoming').toString(),
    );
  }
}
