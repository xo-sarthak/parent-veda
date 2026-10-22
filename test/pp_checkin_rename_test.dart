// A reworded check-in question keeps its answer (2026-10-22, Wave 7).
// The question text is the storage key, so DevStore moves an answer saved
// under the old wording to the new one when it loads.

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';

void main() {
  test('an answer saved under the old wording lands on the new question', () {
    final s = DevStore.instance;
    kCheckInRenames.forEach((from, to) {
      s.applyCloudData({'checkIns': {from: true}});
      expect(s.checkInAnswer(to), isTrue);
      expect(s.checkInAnswer(from), isNull);
    });
  });

  test('every new wording is a live question', () {
    final live = [...kCheckIns0to6, ...kCheckIns6to12].map((q) => q.text).toSet();
    for (final to in kCheckInRenames.values) {
      expect(live, contains(to));
    }
  });
}
