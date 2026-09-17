// The daily insight as an article — the adapter's contract.
//
// Every insight must convert, carry the shared when-to-ask line, name no
// reviewer it does not have, and point its Read next at ids that resolve.

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_insight_read.dart';

void main() {
  test('every insight converts, and its read next resolves', () {
    for (final i in ttcInsights) {
      final r = ttcInsightAsRead(i);
      expect(r.id, kTtcInsightReadPrefix + i.id);
      expect(r.title.en, i.titleEn);
      expect(r.teaser.en, i.takeawayEn, reason: 'the takeaway is the teaser');
      expect(r.scaleSetter.en.isNotEmpty, isTrue);
      expect(r.reviewed, isFalse, reason: 'no clinician reviewed an insight');
      expect(r.whenToSeeSomeone, same(kPvShortPieceCallout));
      expect(r.whenToSeeSomeone.tone, isNot(PvCalloutTone.urgent));
      expect(r.readNext, isNotEmpty, reason: '${i.id}: a foot with no rail');
      for (final id in r.readNext) {
        expect(ttcInsightReadById(id), isNotNull, reason: '$id does not resolve');
        expect(id, isNot(r.id), reason: 'a read must not point at itself');
      }
    }
  });

  test('the resolver accepts both the prefixed and the bare id', () {
    final first = ttcInsights.first;
    expect(ttcInsightReadById(first.id)?.id, kTtcInsightReadPrefix + first.id);
    expect(ttcInsightReadById(kTtcInsightReadPrefix + first.id)?.id,
        kTtcInsightReadPrefix + first.id);
    expect(ttcInsightReadById('nope'), isNull);
  });

  test('paragraphs split on blank lines and the first is the lede', () {
    final i = ttcInsights.firstWhere((x) => x.bodyEn.contains('\n\n'));
    final r = ttcInsightAsRead(i);
    final first = i.bodyEn.split(RegExp(r'\n\s*\n')).first.trim();
    expect(r.scaleSetter.en, first);
    expect(r.sections.single.paragraphs.first.en, isNot(first));
  });
}
