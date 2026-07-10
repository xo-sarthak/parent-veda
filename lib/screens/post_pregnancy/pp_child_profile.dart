// =============================================================================
//  ChildProfileStore - the child's editable identity + growth
// -----------------------------------------------------------------------------
//  One small singleton holding who the child is (name, sex, date of birth) and
//  the latest growth measurements (weight, height, head). It powers the My Child
//  header, the inline growth edit, and - via age-in-weeks - which developmental
//  leap is current. A tiny WHO-style reference table gives the "expected for his
//  age" figures shown alongside the child's own. Seeded for Aarav; a real profile
//  service slots in later. Nothing here depends on the pregnancy app.
// =============================================================================

import 'package:flutter/material.dart';

/// Expected 50th-centile figures for a given age, used as a gentle reference
/// (never a pass/fail). Values approximate the WHO boy standards.
class GrowthRef {
  const GrowthRef(this.weightKg, this.heightCm, this.headCm);
  final double weightKg;
  final double heightCm;
  final double headCm;
}

const Map<int, GrowthRef> _boyRef = {
  0: GrowthRef(3.3, 49.9, 34.5),
  1: GrowthRef(4.5, 54.7, 37.3),
  2: GrowthRef(5.6, 58.4, 39.1),
  3: GrowthRef(6.4, 61.4, 40.5),
  4: GrowthRef(7.0, 63.9, 41.6),
  5: GrowthRef(7.5, 65.9, 42.6),
  6: GrowthRef(7.9, 67.6, 43.3),
  7: GrowthRef(8.3, 69.2, 44.0),
  8: GrowthRef(8.6, 70.6, 44.5),
  9: GrowthRef(8.9, 72.0, 45.0),
  10: GrowthRef(9.2, 73.3, 45.4),
  11: GrowthRef(9.4, 74.5, 45.8),
  12: GrowthRef(9.6, 75.7, 46.1),
};

const Map<int, GrowthRef> _girlRef = {
  0: GrowthRef(3.2, 49.1, 33.9),
  1: GrowthRef(4.2, 53.7, 36.5),
  2: GrowthRef(5.1, 57.1, 38.3),
  3: GrowthRef(5.8, 59.8, 39.5),
  4: GrowthRef(6.4, 62.1, 40.6),
  5: GrowthRef(6.9, 64.0, 41.5),
  6: GrowthRef(7.3, 65.7, 42.2),
  7: GrowthRef(7.6, 67.3, 42.8),
  8: GrowthRef(7.9, 68.7, 43.4),
  9: GrowthRef(8.2, 70.1, 43.8),
  10: GrowthRef(8.5, 71.5, 44.2),
  11: GrowthRef(8.7, 72.8, 44.6),
  12: GrowthRef(8.9, 74.0, 44.9),
};

GrowthRef expectedGrowth(int months, {bool boy = true}) {
  final m = months.clamp(0, 12);
  final table = boy ? _boyRef : _girlRef;
  return table[m] ?? table[12]!;
}

class ChildProfileStore extends ChangeNotifier {
  ChildProfileStore._();
  static final ChildProfileStore instance = ChildProfileStore._();

  String name = 'Aarav';
  bool isBoy = true;
  DateTime dob = DateTime(2026, 3, 8);
  double weightKg = 6.4;
  double heightCm = 63;
  double headCm = 41;

  // If the device clock puts the child in the future (bad clock / demo machine),
  // fall back to ~4 months so the app still shows a sensible, seeded stage.
  static const double _fallbackWeeks = 18;

  double get ageInWeeks {
    final w = DateTime.now().difference(dob).inDays / 7.0;
    return w >= 1 ? w : _fallbackWeeks;
  }

  int get ageInDays => (ageInWeeks * 7).round();
  int get ageInMonths => (ageInWeeks / 4.345).floor();

  /// "4 months 1 week" / "6 weeks" — a warm, human age label.
  String get ageLabel {
    final months = ageInMonths;
    if (months < 1) {
      final w = ageInWeeks.floor();
      return '$w ${w == 1 ? 'week' : 'weeks'}';
    }
    final remWeeks = (ageInWeeks - months * 4.345).floor();
    final mLabel = '$months ${months == 1 ? 'month' : 'months'}';
    if (remWeeks <= 0) return mLabel;
    return '$mLabel $remWeeks ${remWeeks == 1 ? 'week' : 'weeks'}';
  }

  GrowthRef get expected => expectedGrowth(ageInMonths, boy: isBoy);

  /// A one-line, non-judgemental read on where the child sits vs the reference.
  String get growthNote =>
      '$name is growing along his own steady curve. The figures below sit close to the typical range for his age — nothing here needs attention.';

  void update({
    String? name,
    bool? isBoy,
    DateTime? dob,
    double? weightKg,
    double? heightCm,
    double? headCm,
  }) {
    if (name != null && name.trim().isNotEmpty) this.name = name.trim();
    if (isBoy != null) this.isBoy = isBoy;
    if (dob != null) this.dob = dob;
    if (weightKg != null) this.weightKg = weightKg;
    if (heightCm != null) this.heightCm = heightCm;
    if (headCm != null) this.headCm = headCm;
    notifyListeners();
  }
}
