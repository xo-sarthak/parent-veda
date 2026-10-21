// =============================================================================
//  ttc_temp_rise.dart - spotting her temperature rise from her own readings
// =============================================================================
//
// ⚠️ THE READINGS MUST LEAD SOMEWHERE (the user, 2026-10-21: "this temperature
// noting should actually yield some outcome"). Before this, a morning reading
// went into the log and nothing read it back for timing; the only thing that
// moved her window was a day she typed in by hand. Now her readings are read
// here, and when they show the classic rise, the screen asks her to confirm
// it. Her "yes" goes through `CycleStore.logTemperatureShift`, the same
// door the hand-typed day always used, so the engine is unchanged.
//
// THE RULE IS THE TEXTBOOK ONE, NOT OURS. "Three over six": three readings in
// a row above the highest of the six before them, the third at least 0.2 °C
// above that line. It is what fertility-awareness teaching uses, and it is
// deliberately conservative: a missed rise costs her nothing (the estimate
// stands), a false one would move her window on noise.
//
// WHY IT ONLY PROPOSES. A rise is her body's sign, and her own observation
// outranks our calculation (truth_hierarchy.dart), so the decision to record
// it is hers. We never write it silently.
//
// Pure: no store, no clock, so it is tested on plain lists.

/// One morning: the cycle day and the reading in °C.
typedef TtcTempReading = ({int cycleDay, double celsius});

/// Readings needed before a rise can be seen at all: six to set the line,
/// three above it.
const int kTtcTempRiseReadings = 9;

/// How far the third high reading must clear the line, in °C.
const double kTtcTempRiseMargin = 0.2;

/// The cycle day of the first of three higher mornings, or null when the
/// readings do not show a rise yet. [readings] may be in any order; days
/// with a gap of more than one between them do not count as "in a row".
int? ttcDetectTempRise(List<TtcTempReading> readings) {
  final r = [...readings]..sort((a, b) => a.cycleDay.compareTo(b.cycleDay));
  for (var i = 6; i + 2 < r.length; i++) {
    final three = r.sublist(i, i + 3);
    final inRow = three[1].cycleDay - three[0].cycleDay == 1 &&
        three[2].cycleDay - three[1].cycleDay == 1;
    if (!inRow) continue;
    final line = r
        .sublist(i - 6, i)
        .map((x) => x.celsius)
        .reduce((a, b) => a > b ? a : b);
    final allAbove = three.every((x) => x.celsius > line);
    final thirdClear = three[2].celsius >= line + kTtcTempRiseMargin - 1e-9;
    if (allAbove && thirdClear) return three[0].cycleDay;
  }
  return null;
}

/// The line her rise is measured against, for the chart: the highest of the
/// six readings before [riseDay]. Null when there are not six.
double? ttcTempCoverLine(List<TtcTempReading> readings, int riseDay) {
  final before = readings.where((x) => x.cycleDay < riseDay).toList()
    ..sort((a, b) => a.cycleDay.compareTo(b.cycleDay));
  if (before.length < 6) return null;
  return before
      .sublist(before.length - 6)
      .map((x) => x.celsius)
      .reduce((a, b) => a > b ? a : b);
}
