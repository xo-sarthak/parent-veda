// =============================================================================
//  ParentVeda Growth Journey - measurements, WHO-style percentiles & voice
// -----------------------------------------------------------------------------
//  The Growth Percentile tool rebuilt from the Claude Design prompt as a "Growth
//  Journey": the percentile is one quiet piece of evidence, never the headline.
//  One in-memory ChangeNotifier singleton (GrowthStore) holds the measurements
//  and derives an approximate WHO percentile, a plain-language interpretation
//  (continuity matters more than the number), and the trend. The percentile is a
//  transparent *estimate*: a z-score against the WHO 50th-centile reference in
//  pp_child_profile, using published coefficients of variation - honest and
//  reassuring, not clinical software. Prototype-shaped: seeded, no persistence.
//  Reference table covers 0–12 months (older ages clamp to 12 for now).
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'pp_child_profile.dart';

/// The metrics we chart. Head circumference is optional per measurement.
enum GrowthMetric { weight, height, head }

extension GrowthMetricX on GrowthMetric {
  String get label => switch (this) {
        GrowthMetric.weight => 'Weight',
        GrowthMetric.height => 'Height',
        GrowthMetric.head => 'Head',
      };
  String get unit => switch (this) {
        GrowthMetric.weight => 'kg',
        GrowthMetric.height => 'cm',
        GrowthMetric.head => 'cm',
      };
  String get axisLabel => switch (this) {
        GrowthMetric.weight => 'Weight-for-age',
        GrowthMetric.height => 'Length/height-for-age',
        GrowthMetric.head => 'Head circumference',
      };
}

class GrowthMeasurement {
  GrowthMeasurement({
    required this.id,
    required this.date,
    required this.weightKg,
    required this.heightCm,
    this.headCm,
    this.note,
  });

  final String id;
  final DateTime date;
  final double weightKg;
  final double heightCm;
  final double? headCm;
  final String? note;

  /// Age (in months) at the time of this measurement, from the child's DOB.
  double ageMonthsAt(DateTime dob) => date.difference(dob).inDays / 30.4375;

  double? value(GrowthMetric m) => switch (m) {
        GrowthMetric.weight => weightKg,
        GrowthMetric.height => heightCm,
        GrowthMetric.head => headCm,
      };
}

class GrowthStore extends ChangeNotifier {
  GrowthStore._() {
    _seed();
  }
  static final GrowthStore instance = GrowthStore._();

  final List<GrowthMeasurement> _items = [];
  int _seq = 0;
  String _id() => 'grow_${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  ChildProfileStore get _child => ChildProfileStore.instance;
  String get name => _child.name;

  // ---- reads --------------------------------------------------------------
  /// Newest first.
  List<GrowthMeasurement> get all {
    final list = [..._items]..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(list);
  }

  /// Oldest first (chart order).
  List<GrowthMeasurement> get chronological {
    final list = [..._items]..sort((a, b) => a.date.compareTo(b.date));
    return List.unmodifiable(list);
  }

  GrowthMeasurement? get latest => all.isEmpty ? null : all.first;
  GrowthMeasurement? get previous => all.length < 2 ? null : all[1];

  bool get isEmpty => _items.isEmpty;
  bool get hasHead => _items.any((m) => m.headCm != null);

  // ---- percentile (approximate, transparent) ------------------------------
  /// The percentile (1–99) for [value] of [metric] at [ageMonths] for this
  /// child's sex, or null if the metric value is missing.
  int? percentile(GrowthMetric metric, double? value, double ageMonths) {
    if (value == null) return null;
    final median = _median(metric, ageMonths);
    final sd = _sd(metric, median);
    if (sd <= 0) return null;
    final z = (value - median) / sd;
    // Logistic approximation to the normal CDF (good to ~1%).
    final p = 1 / (1 + math.exp(-1.702 * z));
    return (p * 100).round().clamp(1, 99);
  }

  /// Percentile of the latest measurement for [metric].
  int? latestPercentile(GrowthMetric metric) {
    final m = latest;
    if (m == null) return null;
    return percentile(metric, m.value(metric), m.ageMonthsAt(_child.dob));
  }

  /// The WHO 50th-centile value for a metric at an age (reused reference table).
  double _median(GrowthMetric metric, double ageMonths) {
    final ref = expectedGrowth(ageMonths.round(), boy: _child.isBoy);
    return switch (metric) {
      GrowthMetric.weight => ref.weightKg,
      GrowthMetric.height => ref.heightCm,
      GrowthMetric.head => ref.headCm,
    };
  }

  /// Approximate SD from published coefficients of variation for infant growth.
  double _sd(GrowthMetric metric, double median) => switch (metric) {
        GrowthMetric.weight => median * 0.12,
        GrowthMetric.height => median * 0.037,
        GrowthMetric.head => median * 0.033,
      };

  /// The shaded "typical range" (±1 SD ≈ 16th–84th centile) for a metric at an
  /// age — used by the chart to draw a calm band rather than hard lines.
  (double lo, double mid, double hi) band(GrowthMetric metric, double ageMonths) {
    final mid = _median(metric, ageMonths);
    final sd = _sd(metric, mid);
    return (mid - sd, mid, mid + sd);
  }

  // ---- interpretation (reassuring, continuity over number) ----------------
  /// The emotional headline for the hero — never "65th percentile".
  String get headline {
    if (isEmpty) return 'Add a measurement to begin';
    if (_items.length < 2) return 'A first point on the curve';
    final trend = _weightTrendPoints();
    if (trend.abs() <= 10) return 'Growing consistently';
    return trend > 0 ? 'Following his own rising curve' : 'Tracking along steadily';
  }

  /// The longer ParentVeda interpretation paragraph.
  String get interpretation {
    if (isEmpty) {
      return 'Once you add a measurement or two, this space explains what the numbers mean for $name — in plain, reassuring language.';
    }
    if (_items.length < 2) {
      return 'This is $name\'s first recorded point. A single measurement is just a snapshot — it\'s the pattern over time that tells the real story, so keep adding as you go.';
    }
    final trend = _weightTrendPoints();
    final months = _spanMonths();
    if (trend.abs() <= 10) {
      return '$name\'s growth has stayed close to its own steady curve over the last ${_monthsLabel(months)}. Consistency like this is usually the most reassuring sign of all — far more than any single number.';
    }
    if (trend > 0) {
      return '$name has been climbing along his curve over the last ${_monthsLabel(months)}. Steady, gradual change in one direction is normal and healthy — babies often find their own line and follow it.';
    }
    return 'Over the last ${_monthsLabel(months)}, $name\'s curve has eased a little lower while staying steady. One shift like this is rarely a concern on its own; it can simply be worth a mention at your next paediatric visit.';
  }

  /// A one-line plain explanation of what a percentile *is*.
  String get percentileMeaning =>
      'A percentile compares $name with other babies of the same age and sex. Being in, say, the 30th percentile does not mean unhealthy — perfectly healthy babies fall right across the range. What matters most is that $name keeps following his own curve.';

  /// Contextual AI-style observations.
  List<String> get insights {
    if (isEmpty) return const [];
    final out = <String>[];
    final wp = latestPercentile(GrowthMetric.weight);
    final hp = latestPercentile(GrowthMetric.height);
    if (wp != null) out.add('Weight is tracking around the ${_ordinalBand(wp)} — comfortably within the healthy range.');
    if (hp != null) out.add('Height is following the ${_ordinalBand(hp)}, growing in step with age.');
    if (hasHead) out.add('Head growth is following its expected pattern.');
    out.add('The shape of the curve matters more than any single point on it.');
    return out;
  }

  // ---- writes -------------------------------------------------------------
  void add(GrowthMeasurement m) {
    _items.add(m);
    // Keep the child profile's "latest" figures in step with the newest entry.
    final newest = all.first;
    _child.update(weightKg: newest.weightKg, heightCm: newest.heightCm, headCm: newest.headCm ?? _child.headCm);
    notifyListeners();
  }

  void log({required DateTime date, required double weightKg, required double heightCm, double? headCm, String? note}) {
    add(GrowthMeasurement(id: _id(), date: date, weightKg: weightKg, heightCm: heightCm, headCm: headCm, note: note));
  }

  void remove(String id) {
    _items.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  // ---- helpers ------------------------------------------------------------
  /// Change in the latest-vs-previous weight percentile (points).
  int _weightTrendPoints() {
    final a = latest, b = previous;
    if (a == null || b == null) return 0;
    final pa = percentile(GrowthMetric.weight, a.weightKg, a.ageMonthsAt(_child.dob));
    final pb = percentile(GrowthMetric.weight, b.weightKg, b.ageMonthsAt(_child.dob));
    if (pa == null || pb == null) return 0;
    return pa - pb;
  }

  double _spanMonths() {
    final c = chronological;
    if (c.length < 2) return 0;
    return c.last.date.difference(c.first.date).inDays / 30.4375;
  }

  String _monthsLabel(double months) {
    final m = months.round();
    if (m <= 1) return 'few weeks';
    return '$m months';
  }

  /// "40th percentile" style band, rounded to the nearest 5 to avoid false
  /// precision.
  String _ordinalBand(int p) {
    final r = (p / 5).round() * 5;
    final v = r.clamp(5, 95);
    return '${v}th percentile';
  }

  void _seed() {
    final dob = _child.dob;
    _items.addAll([
      GrowthMeasurement(id: _id(), date: dob, weightKg: 3.4, heightCm: 50.0, headCm: 34.6, note: 'At birth'),
      GrowthMeasurement(id: _id(), date: dob.add(const Duration(days: 31)), weightKg: 4.4, heightCm: 54.3, headCm: 37.1),
      GrowthMeasurement(id: _id(), date: dob.add(const Duration(days: 62)), weightKg: 5.5, heightCm: 58.2, headCm: 39.0),
      GrowthMeasurement(id: _id(), date: dob.add(const Duration(days: 120)), weightKg: 6.4, heightCm: 63.0, headCm: 41.0, note: 'Latest well-baby visit'),
    ]);
  }

  /// Nicely rounded percentile phrase for the hero chip, e.g. "~45th".
  String? latestPercentilePhrase(GrowthMetric metric) {
    final p = latestPercentile(metric);
    if (p == null) return null;
    final r = (p / 5).round() * 5;
    return '~${r.clamp(5, 95)}th';
  }
}
