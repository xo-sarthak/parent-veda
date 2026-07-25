// =============================================================================
//  ConsultPatient — who the doctor is about to see
// -----------------------------------------------------------------------------
//  The appointment card used to fall back to booking.title, which for a consult
//  is 'Consult · <the doctor's own name>'. A doctor opened their day and read
//  their own name on every row.
//
//  This is the minimum a clinician needs before opening a call: who, and where
//  they are in the journey. Deliberately nothing else - a doctor's appointment
//  list is not a place to surface a family's whole record. Anything more
//  clinical belongs behind an explicit tap, in the health record.
// =============================================================================

import 'package:flutter/foundation.dart';

@immutable
class ConsultPatient {
  const ConsultPatient({this.name = '', this.dueDate, this.childAgeMonths});

  /// The parent's name. Empty when the server has none (a profile that was
  /// never completed) - the UI says "Parent" rather than inventing one.
  final String name;

  /// Pregnancy side: their due date, from which the week is derived.
  final DateTime? dueDate;

  /// Parenting side: the child's age at the time of the consultation.
  final int? childAgeMonths;

  bool get hasName => name.trim().isNotEmpty;
  String get displayName => hasName ? name.trim() : 'Parent';

  /// Weeks pregnant on [on], from a 40-week term. Null when no due date.
  int? weeksPregnantOn(DateTime on) {
    final due = dueDate;
    if (due == null) return null;
    final daysToDue = due.difference(DateTime(on.year, on.month, on.day)).inDays;
    final week = 40 - (daysToDue / 7).floor();
    // Outside a plausible pregnancy the date is stale or wrong, and a wrong
    // clinical number is worse than none.
    if (week < 1 || week > 42) return null;
    return week;
  }

  /// The single line under the parent's name on the appointment card.
  String contextLine(DateTime consultAt) {
    final w = weeksPregnantOn(consultAt);
    if (w != null) return 'Week $w of pregnancy';
    final m = childAgeMonths;
    if (m != null) {
      if (m < 1) return 'Newborn';
      if (m == 1) return '1 month old';
      // 12 is a birthday, and parents say "one" - but 13-23 really is spoken
      // in months ("he's 14 months"), so only the exact year switches over.
      if (m == 12) return '1 year old';
      if (m < 24) return '$m months old';
      final y = m ~/ 12;
      return y == 1 ? '1 year old' : '$y years old';
    }
    return 'No stage details shared';
  }

  static ConsultPatient fromRow(Map row) => ConsultPatient(
        name: (row['patient_name'] ?? '').toString(),
        dueDate: row['patient_due'] == null
            ? null
            : DateTime.tryParse(row['patient_due'].toString()),
      );

  @override
  bool operator ==(Object other) =>
      other is ConsultPatient &&
      other.name == name &&
      other.dueDate == dueDate &&
      other.childAgeMonths == childAgeMonths;

  @override
  int get hashCode => Object.hash(name, dueDate, childAgeMonths);
}
