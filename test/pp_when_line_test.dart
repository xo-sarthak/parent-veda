// =============================================================================
//  The when-line: a doctor box only when it sends her to a doctor (2026-10-27)
// -----------------------------------------------------------------------------
//  ⚠️ `PpWhenLine` is the page's "when / how much / what age" line. The reader,
//  the story deck and the Ask Veda export titled every one "When to see a
//  doctor", in the urgent tone, so a parent read "Three to six." or "From
//  about four months" in the red doctor box: 452 of 560 lines, found by the
//  final review of the fourteen doors.
//
//  The split is held both ways here. A `.doctor` line must say who to go to;
//  a plain line that says "see a doctor" must be marked `.doctor`, or the
//  doctor line it is would be drawn as a quiet note. And the three places
//  that draw the line must keep the doctor title for doctor lines only.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/ask_veda/pp_veda_corpus.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_page_read.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';

Iterable<(PpSection, PpPage, PpWhenLine)> _lines() sync* {
  for (final s in kPpSections) {
    for (final p in s.allPages) {
      for (final b in p.blocks.whereType<PpWhenLine>()) {
        yield (s, p, b);
      }
    }
  }
}

/// Who a doctor line sends her to.
final _who = RegExp(
    r'doctor|paediatrician|physio|hospital|clinic|DEIC|visit|check|assessed|'
    r'call|telling someone|someone|appointment',
    caseSensitive: false);

/// Words that make a line a doctor line, whatever else it says.
final _sendsToDoctor = RegExp(
    r"\b(see|call|ask) (a|your) (doctor|paediatrician)|go to (a |the )?hospital|"
    r"needs a doctor|needs a call|worth a (check|mention|conversation)|"
    r"worth mentioning|get it assessed|then go the same day",
    caseSensitive: false);

void main() {
  test('every doctor line says who to go to', () {
    var doctor = 0;
    for (final (s, p, b) in _lines()) {
      if (!b.doctor) continue;
      doctor++;
      expect(b.text, matches(_who), reason: '${s.id}/${p.id}: "${b.text}"');
    }
    expect(doctor, greaterThanOrEqualTo(30));
  });

  test('a line that sends her to a doctor is marked as one', () {
    for (final (s, p, b) in _lines()) {
      if (b.doctor) continue;
      expect(b.text, isNot(matches(_sendsToDoctor)),
          reason: '${s.id}/${p.id}: a doctor line drawn as a quiet note: "${b.text}"');
    }
  });

  test('most when-lines are not doctor lines, and none is lost', () {
    final all = _lines().toList();
    final plain = all.where((l) => !l.$3.doctor).length;
    expect(all.length, greaterThan(500));
    expect(plain, greaterThan(all.length * 3 ~/ 4),
        reason: 'the block is the when / how much / what age line');
  });

  test('the reader: a plain line is a quiet "When" note, a doctor line the urgent box', () {
    for (final s in kPpSections) {
      for (final p in s.allPages) {
        if (p.toolSurfaceId != null) continue;
        final lines = p.blocks.whereType<PpWhenLine>().toList();
        if (lines.isEmpty) continue;
        final r = ppPageAsRead(s, p);
        final callouts = [for (final sec in r.sections) ?sec.callout];
        for (final b in lines.where((b) => !b.doctor)) {
          expect(
              callouts.any((c) =>
                  c.title.en == 'When' &&
                  c.body.en == b.text &&
                  c.tone == PvCalloutTone.note),
              isTrue,
              reason: '${s.id}/${p.id}: the plain line is not a "When" note');
          expect(r.whenToSeeSomeone.body.en, isNot(b.text),
              reason: '${s.id}/${p.id}: a plain line in the doctor box');
        }
        for (final c in callouts) {
          if (c.title.en == 'When to see a doctor') {
            expect(lines.where((b) => b.doctor).map((b) => b.text), contains(c.body.en),
                reason: '${s.id}/${p.id}: a doctor title on a plain line');
          }
        }
        if (lines.every((b) => !b.doctor)) {
          expect(r.whenToSeeSomeone.tone, isNot(PvCalloutTone.urgent),
              reason: '${s.id}/${p.id}: no doctor line, so no urgent doctor box');
        }
      }
    }
  });

  test('the deck and Ask Veda carry the same split', () {
    for (final (s, p, b) in _lines()) {
      final slides = p.format?.toUpperCase() == 'CARDS' ? ppCardsAsSlides(p) : null;
      if (slides != null) {
        final slide = slides.firstWhere((x) => x.body == b.text);
        expect(slide.title, b.doctor ? 'When to see a doctor' : 'When',
            reason: '${s.id}/${p.id}');
      }
    }
    final docs = buildParentingVedaCorpus();
    for (final (s, p, b) in _lines()) {
      if (p.comingSoon) continue;
      final body = docs.firstWhere((d) => d['doc_id'] == ppVedaPageId(s.id, p.id))['body'] as String;
      expect(body.contains('When to see a doctor: ${b.text}'), b.doctor,
          reason: '${s.id}/${p.id}');
    }
  });
}
