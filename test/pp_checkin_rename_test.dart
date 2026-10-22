// A reworded check-in question keeps its answer (2026-10-22, Wave 7).
// The question text is the storage key, so DevStore moves an answer saved
// under the old wording to the new one when it loads.

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';

void main() {
  // Step 13 (2026-10-22): the store merges item by item, so an answer arrives
  // two ways: the local cache and old cloud blob (applyLegacyBlob, which was
  // applyCloudData), and the merged items (applyCloudItems, one `q|` per answer).
  test('an answer saved under the old wording lands on the new question', () {
    final s = DevStore.instance;
    kCheckInRenames.forEach((from, to) {
      // s.applyCloudData({'checkIns': {from: true}}); // kept for revert (step 13)
      s.applyLegacyBlob({'checkIns': {from: true}});
      expect(s.checkInAnswer(to), isTrue);
      expect(s.checkInAnswer(from), isNull);
    });
  });

  test('a merged answer under the old wording lands on the new question', () {
    final s = DevStore.instance;
    kCheckInRenames.forEach((from, to) {
      s.applyCloudItems({'q|$from': true});
      expect(s.checkInAnswer(to), isTrue);
      expect(s.checkInAnswer(from), isNull);
      // The store now names only the new wording, so the next merge sends it.
      expect(s.cloudItems().keys, contains('q|$to'));
      expect(s.cloudItems().keys, isNot(contains('q|$from')));
    });
  });

  test('an answer already given to the new wording is never overwritten', () {
    final s = DevStore.instance;
    kCheckInRenames.forEach((from, to) {
      s.applyCloudItems({'q|$to': false, 'q|$from': true});
      expect(s.checkInAnswer(to), isFalse);
      s.applyLegacyBlob({'checkIns': {from: true, to: false}});
      expect(s.checkInAnswer(to), isFalse);
    });
  });

  test('every new wording is a live question', () {
    final live = [...kCheckIns0to6, ...kCheckIns6to12].map((q) => q.text).toSet();
    for (final to in kCheckInRenames.values) {
      expect(live, contains(to));
    }
  });
}
