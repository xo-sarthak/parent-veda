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
import '../symptoms/symptom_pages.dart';

const String kSymptomReadPrefix = 'symptom_';
const String kNormalReadPrefix = 'normal_';

const LocalizedText _desk = LocalizedText(en: 'ParentVeda editorial', hi: 'ParentVeda editorial');
const LocalizedText _kicker = LocalizedText(en: 'Symptoms', hi: 'Symptoms');
LocalizedText _same(String s) => LocalizedText(en: s, hi: s);

// 2026-09-29, the pregnancy warmth pass (docs/PREG-VOICE.md): every symptom
// page opens with a short answer (`kSymptomShortAnswers`). The reader hides
// the scale-setter when a short answer is present, so "why" moves into its
// own section under "What may help" rather than vanishing. The new pages'
// longer sections, and the Appendix A additions, come from
// `kSymptomExtraSections`; `kSymptomReadFirst` puts the urgent answers in
// "Is this normal?" first under Read next.
PvRead pvReadFromSymptom(Symptom s) {
  final area = symptomArea(s);
  final short = kSymptomShortAnswers[s.id];
  return PvRead(
    id: '$kSymptomReadPrefix${s.id}',
    kicker: _kicker,
    title: s.name,
    teaser: s.commonness,
    scaleSetter: s.why,
    shortAnswer: short == null ? null : _same(short),
    author: _desk,
    authorRole: _kicker,
    reviewed: false,
    hue: area.hue,
    sections: [
      PvReadSection(heading: _same('What may help'), bullets: s.tips),
      if (short != null && s.why.en.trim().isNotEmpty)
        PvReadSection(heading: _same('Why does this happen?'), paragraphs: [s.why]),
      for (final x in kSymptomExtraSections[s.id] ?? const <SymptomPageSection>[])
        PvReadSection(
          heading: _same(x.heading),
          paragraphs: [for (final t in x.paragraphs) _same(t)],
          bullets: [for (final t in x.bullets) _same(t)],
        ),
      PvReadSection(
        heading: _same('Log it, and see the pattern'),
        paragraphs: [
          _same("Tap it on the Symptoms check-in on the days you feel it. A week of logged days tells your doctor more than one worried afternoon, and the door keeps the week for you."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: s.urgent || kSymptomUrgentCallout.contains(s.id) ? PvCalloutTone.urgent : PvCalloutTone.note,
      title: const LocalizedText(en: 'When to contact your doctor', hi: 'When to contact your doctor'),
      body: s.doctorGuidance,
    ),
    faqs: const [],
    readNext: [
      ...?kSymptomReadFirst[s.id],
      for (final o in symptomsInArea(area))
        if (o.id != s.id && !(kSymptomReadFirst[s.id]?.contains('$kSymptomReadPrefix${o.id}') ?? false))
          '$kSymptomReadPrefix${o.id}',
    ].take(4).toList(),
  );
}

PvCalloutTone _toneFor(NormalVerdict v) => switch (v) {
      NormalVerdict.usually => PvCalloutTone.reassure,
      NormalVerdict.today => PvCalloutTone.note,
      NormalVerdict.now => PvCalloutTone.urgent,
    };

// 2026-09-29: the one-line answer is the short answer box now. The opening
// callout still wears the verdict (the door test holds it) and carries the
// first thing to do; "What to do" lists the rest, so nothing is said twice.
PvRead pvReadFromNormal(NormalQuestion q) => PvRead(
      id: '$kNormalReadPrefix${q.id}',
      kicker: const LocalizedText(en: 'Is this normal?', hi: 'Is this normal?'),
      title: _same(q.question),
      teaser: _same(q.verdict.word),
      scaleSetter: _same(q.short),
      shortAnswer: _same(q.short),
      author: _desk,
      authorRole: _kicker,
      reviewed: false,
      hue: switch (q.verdict) { NormalVerdict.usually => 160, NormalVerdict.today => 42, NormalVerdict.now => 344 },
      sections: [
        PvReadSection(
          callout: PvCallout(tone: _toneFor(q.verdict), title: _same(q.verdict.word), body: _same(q.doNow.first)),
        ),
        PvReadSection(heading: _same('Why does this matter?'), paragraphs: [_same(q.why)]),
        if (q.doNow.length > 1)
          PvReadSection(heading: _same('What else should I do?'), bullets: [for (final d in q.doNow.skip(1)) _same(d)]),
      ],
      whenToSeeSomeone: PvCallout(
        tone: q.verdict == NormalVerdict.now ? PvCalloutTone.urgent : PvCalloutTone.note,
        title: const LocalizedText(en: 'When is it different?', hi: 'When is it different?'),
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
