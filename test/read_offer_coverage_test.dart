// Every article links to one of our services (2026-10-23, global pass phase 2).
//
// The user: "for each and every article, wherever possible, provide option to
// relevant services that we have." Before this, about half the pregnancy and
// TTC reads matched no offering. Loss and urgent reads still never pitch.

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/screens/reader/pv_read_offer.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

const _quiet = [
  'loss', 'miscarriage', 'stillbirth', 'grief', 'ectopic', 'emergency',
  'bleeding', 'urgent',
];

bool _isQuiet(PvRead r) {
  final words = '${r.title.en} ${r.kicker.en} ${r.teaser.en}'
      .toLowerCase()
      .split(RegExp(r'[^a-z]+'));
  return words.any(_quiet.contains) ||
      r.sections.any((s) => s.callout?.tone == PvCalloutTone.urgent);
}

void main() {
  for (final (stage, reads) in [
    ('pregnancy', kPregnancyReads),
    ('TTC', kTtcReads),
  ]) {
    test('every $stage read that may pitch has a service', () {
      final missing = [
        for (final r in reads)
          if (!_isQuiet(r) && pvReadOfferFor(r) == null) r.id,
      ];
      expect(missing, isEmpty, reason: missing.join('\n'));
    });

    test('no $stage loss or urgent read pitches anything', () {
      final loud = [
        for (final r in reads)
          if (_isQuiet(r) && pvReadOfferFor(r) != null) r.id,
      ];
      expect(loud, isEmpty, reason: loud.join('\n'));
    });
  }

  test('a scan read reaches the obstetrician, an OHSS read the fertility doctor', () {
    final scan = kPregnancyReads.firstWhere((r) => r.id == 'preg_scan_read_nst');
    expect(pvReadOfferFor(scan)!.subtitle, contains('Obstetrician'));
    final ohss = kTtcReads.firstWhere((r) => r.id == 'ttc_read_ivf_ohss');
    expect(pvReadOfferFor(ohss)!.title, contains('Fertility'));
  });
}
