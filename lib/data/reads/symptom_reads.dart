// =============================================================================
//  Symptoms — the library and the ten questions, as reads
// -----------------------------------------------------------------------------
//  2026-09-22, the Symptoms door. ONE READER (CLAUDE.md): a symptom's page
//  and an "is this normal?" answer are writing, so they open in
//  `PvReaderScreen` as `PvRead`s, like every other door's leaves. The old
//  `_SymptomDetail` in symptom_companion_screen.dart stays for revert.
//
//  Two adapters:
//    symptom   how common · why (the scale-setter) · what may help (bullets)
//              · when to contact your doctor (the closing callout; urgent
//              tone when the symptom is one of the five)
//    normal    the verdict as the OPENING callout (reassure / note / urgent
//              by verdict) · why · what to do now (bullets) · when it
//              changes (the closing callout)
//
//  ⚠️ NO PHOTOS ON THIS DOOR (the plan): symptom photography is either
//  stock-fake or clinical. The rows wear drawn marks; the reads open without
//  a picture band.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import '../../models/symptom.dart';
import '../symptoms/symptom_library.dart';
import '../symptoms/symptom_normal.dart';

const String kSymptomReadPrefix = 'symptom_';
const String kNormalReadPrefix = 'normal_';

const LocalizedText _desk = LocalizedText(en: 'ParentVeda editorial', hi: 'ParentVeda editorial');
const LocalizedText _kicker = LocalizedText(en: 'Symptoms', hi: 'Symptoms');
LocalizedText _same(String s) => LocalizedText(en: s, hi: s);

PvRead pvReadFromSymptom(Symptom s) {
  final area = symptomArea(s);
  return PvRead(
    id: '$kSymptomReadPrefix${s.id}',
    kicker: _kicker,
    title: s.name,
    teaser: s.commonness,
    scaleSetter: s.why,
    author: _desk,
    authorRole: _kicker,
    reviewed: false,
    hue: area.hue,
    sections: [
      PvReadSection(heading: _same('What may help'), bullets: s.tips),
      PvReadSection(
        heading: _same('Log it, and see the pattern'),
        paragraphs: [
          _same('Tap it on the Symptoms door\'s check-in on the days you feel it. A week of days says more to your doctor than one afternoon\'s worry, and the door keeps the week for you.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: s.urgent ? PvCalloutTone.urgent : PvCalloutTone.note,
      title: const LocalizedText(en: 'When to contact your doctor', hi: 'When to contact your doctor'),
      body: s.doctorGuidance,
    ),
    faqs: const [],
    readNext: [
      for (final o in symptomsInArea(area))
        if (o.id != s.id) '$kSymptomReadPrefix${o.id}',
    ].take(4).toList(),
  );
}

PvCalloutTone _toneFor(NormalVerdict v) => switch (v) {
      NormalVerdict.usually => PvCalloutTone.reassure,
      NormalVerdict.today => PvCalloutTone.note,
      NormalVerdict.now => PvCalloutTone.urgent,
    };

PvRead pvReadFromNormal(NormalQuestion q) => PvRead(
      id: '$kNormalReadPrefix${q.id}',
      kicker: const LocalizedText(en: 'Is this normal?', hi: 'Is this normal?'),
      title: _same(q.question),
      teaser: _same(q.verdict.word),
      scaleSetter: _same(q.short),
      author: _desk,
      authorRole: _kicker,
      reviewed: false,
      hue: switch (q.verdict) { NormalVerdict.usually => 160, NormalVerdict.today => 42, NormalVerdict.now => 344 },
      sections: [
        PvReadSection(
          callout: PvCallout(tone: _toneFor(q.verdict), title: _same(q.verdict.word), body: _same(q.short)),
        ),
        PvReadSection(heading: _same('Why it matters'), paragraphs: [_same(q.why)]),
        PvReadSection(heading: _same('What to do'), bullets: [for (final d in q.doNow) _same(d)]),
      ],
      whenToSeeSomeone: PvCallout(
        tone: q.verdict == NormalVerdict.now ? PvCalloutTone.urgent : PvCalloutTone.note,
        title: const LocalizedText(en: 'When it changes', hi: 'When it changes'),
        body: _same(q.whenItChanges),
      ),
      faqs: const [],
      readNext: [
        for (final o in kNormalQuestions)
          if (o.id != q.id) '$kNormalReadPrefix${o.id}',
      ].take(4).toList(),
    );

/// Both kinds by id, for the reader's read-next.
PvRead? symptomReadById(String id) {
  if (id.startsWith(kSymptomReadPrefix)) {
    final s = symptomById(id.substring(kSymptomReadPrefix.length));
    return s == null ? null : pvReadFromSymptom(s);
  }
  if (id.startsWith(kNormalReadPrefix)) {
    final q = normalQuestionById(id.substring(kNormalReadPrefix.length));
    return q == null ? null : pvReadFromNormal(q);
  }
  return null;
}
