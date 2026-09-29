// The evening symptoms reminder fires whatever stage she is in, so its words
// must fit every stage (2026-09-28: "Two taps on the Symptoms door and your
// week keeps itself" reached a user on trying to conceive). The words live in
// the screen that switches the reminder on and, mirrored, in ReminderStore,
// which rewords a stored copy of the retired line. This keeps the two in step.

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/symptoms/door/symptoms_today_body.dart'
    show kSymptomReminderBody, kSymptomReminderOldBody;
import 'package:parentveda/services/reminder_store.dart';

void main() {
  test('the store rewords the same retired line to the same new line', () {
    expect(ReminderStore.retiredSymptomBody, kSymptomReminderOldBody);
    expect(ReminderStore.currentSymptomBody, kSymptomReminderBody);
  });

  test('the new line names no stage-only place', () {
    for (final word in ['door', 'week', 'baby', 'pregnan', 'cycle']) {
      expect(kSymptomReminderBody.toLowerCase(), isNot(contains(word)),
          reason: 'the reminder fires on every stage');
    }
  });
}
