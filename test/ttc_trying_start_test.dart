// How long she has been trying comes from HER answer when she gave one
// (2026-09-27). On the phone, You said "Trying · over a year" while Should I
// get help? filled in "Less than 6 months": onboarding V2 saved the answer to
// her profile only, and every "how long" in the stage counted from the day she
// entered it. The answer is read at its low end, so nothing ever says she has
// tried longer than she told us.

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ttc/ttc_store.dart';

void main() {
  final entered = DateTime(2026, 8, 20);

  test('each answer counts back from the day she answered, at its low end', () {
    expect(ttcStartFromAnswer('starting', entered), DateTime(2026, 8, 20));
    expect(ttcStartFromAnswer('months', entered)!.isBefore(entered), isTrue);
    final year = ttcStartFromAnswer('year', entered)!;
    // A year is enough for the one-year check to see a year.
    expect(entered.difference(year).inDays, greaterThanOrEqualTo(365));
    final six = ttcStartFromAnswer('six', entered)!;
    expect(entered.difference(six).inDays, inInclusiveRange(182, 184));
  });

  test('no answer, or no day to count from, gives nothing to invent', () {
    expect(ttcStartFromAnswer(null, entered), isNull);
    expect(ttcStartFromAnswer('', entered), isNull);
    expect(ttcStartFromAnswer('year', null), isNull);
  });
}
