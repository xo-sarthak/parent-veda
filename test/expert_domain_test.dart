// Server experts are filed under their own stage (2026-10-23).
//
// `expert_profiles.domain` (0072) was never read, so every expert published
// from the panel landed under parenting: an OB-GYN or a fertility doctor
// onboarded today never reached the pregnancy or TTC side.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/expert_store.dart';

void main() {
  test('the row carries its domain, defaulting to universal', () {
    final store = ExpertStore.instance;
    expect(store.fromMap({'expert_id': 'a', 'domain': 'pregnancy'}).domain,
        'pregnancy');
    expect(store.fromMap({'expert_id': 'b'}).domain, 'universal');
  });

  test('every place that files an expert under a stage reads the domain', () {
    for (final path in [
      'lib/booking/booking_catalog.dart',
      'lib/screens/learn/pv_learn_catalog.dart',
      'lib/doctor/doctor_directory.dart',
    ]) {
      expect(File(path).readAsStringSync().contains('e.domain'), isTrue,
          reason: '$path files experts without their domain again');
    }
  });
}
