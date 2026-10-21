// The one calm link from a read to a service of ours (walk 2026-10-20,
// lib/screens/reader/pv_read_offer.dart): relevant or nothing, never on a
// loss or urgent read, and actually drawn by the reader (wiring gate).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/learn/pv_learn_view.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/screens/learn/pv_learn_catalog.dart';
import 'package:parentveda/screens/reader/pv_read_offer.dart';
import 'package:parentveda/services/life_stage_store.dart' show LifeStage;

LocalizedText _l(String s) => LocalizedText(en: s, hi: s);

PvRead _read(String id, String title,
        {String teaser = '', List<PvReadSection>? sections}) =>
    PvRead(
      id: id,
      kicker: _l(''),
      title: _l(title),
      teaser: _l(teaser),
      scaleSetter: _l(''),
      author: _l('ParentVeda team'),
      authorRole: _l(''),
      hue: 0,
      sections: sections ??
          [PvReadSection(heading: _l('One'), paragraphs: [_l('Text.')])],
      whenToSeeSomeone: kPvShortPieceCallout,
      faqs: const [],
    );

PvOfferingView _offer(String id, PvLearnKind kind, String title,
        [String subtitle = '']) =>
    PvOfferingView(
      id: id,
      stage: LifeStage.tryingToConceive,
      kind: kind,
      title: title,
      subtitle: subtitle,
      about: '',
      expert: const PvLearnExpert(id: 'x', name: 'X', role: ''),
      hue: 0,
    );

final _catalog = [
  _offer('pcos', PvLearnKind.course, 'PCOS and trying to conceive'),
  _offer('food', PvLearnKind.consult, 'Nutrition consult',
      'Food that fits your fertile months'),
  _offer('mind', PvLearnKind.consult, 'Talk to a psychologist',
      'For the stress of trying'),
];

void main() {
  test('a read gets the offering that shares its topic', () {
    expect(
        pvReadOfferFor(_read('ttc_pcos_basics', 'Living with PCOS'),
                catalog: _catalog)
            ?.id,
        'pcos');
    expect(
        pvReadOfferFor(
                _read('ttc_eat_well', 'What to eat while trying',
                    teaser: 'Simple food for your fertile months'),
                catalog: _catalog)
            ?.id,
        'food');
  });

  test('no shared topic, no card', () {
    expect(
        pvReadOfferFor(_read('ttc_cervix', 'Reading your cervical mucus'),
            catalog: _catalog),
        isNull);
  });

  test('never on a loss or an urgent read', () {
    for (final t in [
      'After a miscarriage: food and rest',
      'Bleeding and stress in early pregnancy',
      'Grief, sleep and the weeks after a loss',
    ]) {
      expect(pvReadOfferFor(_read('preg_x', t), catalog: _catalog), isNull,
          reason: t);
    }
    final urgent = _read('ttc_pcos_pain', 'PCOS and pain', sections: [
      PvReadSection(
        heading: _l('When to go now'),
        callout: PvCallout(
            tone: PvCalloutTone.urgent, title: _l('Go now'), body: _l('.')),
      ),
    ]);
    expect(pvReadOfferFor(urgent, catalog: _catalog), isNull);
  });

  test('a read outside the three stages gets nothing', () {
    expect(pvReadOfferFor(_read('doc_pcos', 'PCOS'), catalog: _catalog),
        isNull);
  });

  test('anything the live TTC catalogue offers is a real offering', () {
    final live = PvLearnCatalog.instance.all(stage: LifeStage.tryingToConceive);
    final v = pvReadOfferFor(_read('ttc_pcos_basics', 'Living with PCOS'));
    if (v != null) {
      expect(live.map((o) => o.id), contains(v.id));
      expect(PvLearnCatalog.instance.byId(v.id), isNotNull);
    }
  });

  test('wiring: the reader draws the card once, after the second section',
      () {
    final src =
        File('lib/screens/reader/pv_reader_screen.dart').readAsStringSync();
    expect(src, contains('pvReadOfferFor(widget.read)'));
    expect('PvReadOfferCard('.allMatches(src).length, 1);
    expect(src, contains('a.sections.length >= 3 ? 1 : a.sections.length - 1'));
  });
}
