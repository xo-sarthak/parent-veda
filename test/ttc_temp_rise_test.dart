// The temperature rise, spotted from her own readings (2026-10-21).
// See lib/ttc/ttc_temp_rise.dart.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ttc/ttc_temp_rise.dart';

List<TtcTempReading> _r(int firstDay, List<double> c) => [
      for (var i = 0; i < c.length; i++)
        (cycleDay: firstDay + i, celsius: c[i]),
    ];

void main() {
  group('three over six', () {
    test('a clear rise is found on its first high morning', () {
      final r = _r(8, [36.30, 36.35, 36.25, 36.30, 36.28, 36.32, 36.45, 36.50, 36.55]);
      expect(ttcDetectTempRise(r), 14);
      expect(ttcTempCoverLine(r, 14), closeTo(36.35, 1e-9));
    });

    test('not enough readings: nothing yet', () {
      expect(ttcDetectTempRise(_r(8, [36.3, 36.3, 36.3, 36.6, 36.7])), isNull);
    });

    test('the third reading must clear the line by 0.2', () {
      final r = _r(8, [36.30, 36.35, 36.25, 36.30, 36.28, 36.32, 36.40, 36.42, 36.50]);
      expect(ttcDetectTempRise(r), isNull, reason: '36.50 < 36.35 + 0.2');
    });

    test('one low morning among the three breaks it', () {
      final r = _r(8, [36.30, 36.35, 36.25, 36.30, 36.28, 36.32, 36.60, 36.30, 36.65]);
      expect(ttcDetectTempRise(r), isNull);
    });

    test('a missed morning between the three breaks "in a row"', () {
      final r = [
        ..._r(8, [36.30, 36.35, 36.25, 36.30, 36.28, 36.32]),
        (cycleDay: 14, celsius: 36.60),
        (cycleDay: 16, celsius: 36.62),
        (cycleDay: 17, celsius: 36.70),
      ];
      expect(ttcDetectTempRise(r), isNull);
    });

    test('order does not matter', () {
      final r = _r(8, [36.30, 36.35, 36.25, 36.30, 36.28, 36.32, 36.45, 36.50, 36.55]);
      expect(ttcDetectTempRise(r.reversed.toList()), 14);
    });
  });

  group('wiring gate', () {
    test('the ovulation screen reads the readings and only proposes', () {
      final s = File('lib/screens/ttc/ttc_ovulation_screen.dart').readAsStringSync();
      expect(s, contains('ttcDetectTempRise('));
      expect(s, contains("ValueKey('ttc_ov_temp_rise_yes')"));
      expect(s, contains("ValueKey('ttc_ov_temp_log_today')"));
      expect(s, contains("ValueKey('ttc_ov_temp_log_earlier')"));
      expect(s, contains("ValueKey('ttc_ov_temp_why')"));
      expect(s, contains("productId: 'lh_strips'"));
      expect(s, contains("productId: 'thermometer'"));
      expect(File('lib/screens/ttc/ttc_temp_parts.dart').readAsStringSync(),
          contains('openTtcProductPage(context, productId)'));
    });
  });
}
