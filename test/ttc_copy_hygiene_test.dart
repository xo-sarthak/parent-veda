// =============================================================================
//  TTC copy hygiene — the marker that escaped the comment
// -----------------------------------------------------------------------------
//  This repo marks a load-bearing decision with ⚠️ in a COMMENT. Writing a
//  large content file, that habit follows the hand into the string literal, and
//  it lands almost exactly where it does the most damage: on the sentence
//  saying "this does not diagnose anything". The warning triangle turns a
//  reassurance into an alarm.
//
//  Four of them shipped into the PCOS result, three into the checklist, two
//  into a BMI band, one into a vaccine note and two into article evidence
//  lines. None of them failed to compile. None of them failed a test. The only
//  place they showed up was on the phone.
//
//  So the rule gets teeth. The check runs against the LOADED DATA rather than
//  the source text, which is what makes it able to tell the difference between
//  `note:` (she reads it) and `medicalReview:` (a clinician reads it, and the
//  marker there is doing its job).
//
//  It also enforces the house rule that already existed - no decorative emoji
//  in chrome - for the one surface where nobody had written it down.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/ttc/ttc_pcos_check_data.dart';
import 'package:parentveda/ttc/ttc_pcos_check_rules.dart';
import 'package:parentveda/ttc/ttc_precheck_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';
import 'package:parentveda/ttc/ttc_vaccines_data.dart';

/// Emoji and pictographic ranges. Deliberately NOT a blanket "non-ASCII" ban:
/// this content is bilingual, so Devanagari, en dashes and curly quotes are all
/// expected and correct. What is banned is the pictograph.
final RegExp _pictograph = RegExp(
    r'[\u2190-\u21FF\u2600-\u27BF\u2B00-\u2BFF\uFE0F\u{1F000}-\u{1FAFF}]',
    unicode: true);

void _clean(LocalizedText? t, String where) {
  if (t == null) return;
  for (final s in [t.en, t.hi]) {
    final m = _pictograph.firstMatch(s);
    expect(m, isNull,
        reason: '$where carries "${m?.group(0)}" — a pictograph in copy she '
            'reads. If it was meant as an editorial marker it belongs in a '
            'comment or in `medicalReview`, not in the sentence.');
  }
}

void main() {
  test('the PCOS checker asks and answers without pictographs', () {
    for (final q in kPcosQuestions) {
      _clean(q.prompt, 'pcos ${q.id}.prompt');
      _clean(q.whyWeAsk, 'pcos ${q.id}.whyWeAsk');
      _clean(q.summaryLabel, 'pcos ${q.id}.summaryLabel');
      for (final o in q.options) {
        _clean(o.label, 'pcos ${q.id} option ${o.id}');
      }
    }
  });

  test('and so does every PCOS result it can produce', () {
    // The four worst offenders were HERE — in `_body`, not in a data table —
    // because a result narrative is a `switch` in a rules file and reads like
    // code while it is being written. Every branch, so a level that only fires
    // on an unusual answer set is covered too.
    final byLevel = <PcosLevel, bool>{};
    for (final q in kPcosQuestions) {
      for (final o in q.options) {
        // One deliberately crude sweep: answer everything with one option
        // index and read what comes out. It does not model a real woman, and
        // it is not trying to — it is trying to reach every narrative branch.
        final answers = {
          for (final qq in kPcosQuestions)
            qq.id: qq.options
                .firstWhere((oo) => oo.id == o.id, orElse: () => qq.options.first)
                .id
        };
        final r = interpretPcos(answers);
        byLevel[r.level] = true;
        _clean(r.headline, 'pcos result headline');
        _clean(r.body, 'pcos result body');
        _clean(r.confidenceNote, 'pcos result confidence note');
        for (final l in pcosDetailLines(r)) {
          _clean(l, 'pcos detail line');
        }
      }
    }
    expect(byLevel.length, greaterThan(1),
        reason: 'the sweep only ever reached one level, so it is not '
            'exercising the narratives it claims to');
  });

  test('the pre-pregnancy checklist reads clean', () {
    for (final i in kPrecheckItems) {
      _clean(i.title, 'precheck ${i.id}.title');
      _clean(i.why, 'precheck ${i.id}.why');
      _clean(i.whatToDo, 'precheck ${i.id}.whatToDo');
      _clean(i.askDoctor, 'precheck ${i.id}.askDoctor');
      // `medicalReview` is deliberately NOT checked. It is a register for a
      // named clinician, never rendered, and the marker there is the point.
    }
  });

  test('the vaccine cards read clean', () {
    for (final v in kTtcVaccines) {
      _clean(v.name, 'vaccine ${v.id}.name');
      _clean(v.protectsAgainst, 'vaccine ${v.id}.protectsAgainst');
      _clean(v.why, 'vaccine ${v.id}.why');
      _clean(v.howChecked, 'vaccine ${v.id}.howChecked');
      _clean(v.schedule, 'vaccine ${v.id}.schedule');
      _clean(v.conditional, 'vaccine ${v.id}.conditional');
      _clean(v.note, 'vaccine ${v.id}.note');
    }
  });

  test('every article reads clean, evidence line included', () {
    for (final r in kTtcReads) {
      _clean(r.kicker, 'read ${r.id}.kicker');
      _clean(r.title, 'read ${r.id}.title');
      _clean(r.teaser, 'read ${r.id}.teaser');
      _clean(r.scaleSetter, 'read ${r.id}.scaleSetter');
      _clean(r.evidence, 'read ${r.id}.evidence');
      _clean(r.whenToSeeSomeone.title, 'read ${r.id}.whenToSeeSomeone');
      _clean(r.whenToSeeSomeone.body, 'read ${r.id}.whenToSeeSomeone');
      for (final s in r.sections) {
        _clean(s.heading, 'read ${r.id} section heading');
        _clean(s.summary, 'read ${r.id} section summary');
        for (final t in [...s.paragraphs, ...s.bullets]) {
          _clean(t, 'read ${r.id} body');
        }
        _clean(s.tip?.title, 'read ${r.id} tip');
        _clean(s.tip?.body, 'read ${r.id} tip');
        _clean(s.mythFact?.myth, 'read ${r.id} myth');
        _clean(s.mythFact?.fact, 'read ${r.id} myth');
        _clean(s.callout?.title, 'read ${r.id} callout');
        _clean(s.callout?.body, 'read ${r.id} callout');
      }
      for (final f in r.faqs) {
        _clean(f.question, 'read ${r.id} faq q');
        _clean(f.answer, 'read ${r.id} faq a');
      }
    }
  });
}
