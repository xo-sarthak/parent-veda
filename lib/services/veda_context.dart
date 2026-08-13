// =============================================================================
//  VedaContext - the mother's own data, for PERSONALIZED Ask Veda answers
// -----------------------------------------------------------------------------
//  Gathers what we already know about her locally - current week/trimester, the
//  symptoms she's logged (and roughly which week she logged them), and her active
//  medications - so Ask Veda's "What this means for you" can speak to HER, not a
//  generic mother. No backend: read straight from the on-device stores. When real
//  login/profiles land, only this gather() changes, not Ask Veda's logic.
// =============================================================================

import '../data/symptom_data.dart';
import '../localization/app_language.dart';
import '../models/symptom.dart';
import 'medicine_store.dart';
import 'family_profile.dart';
import 'pregnancy_controller.dart';
import 'symptom_store.dart';

/// One symptom the mother logged, with the pregnancy week she logged it.
class LoggedSymptomCtx {
  const LoggedSymptomCtx(
      {required this.symptom, required this.week, required this.severity});
  final Symptom symptom;
  final int week;
  final String severity;
}

class VedaContext {
  VedaContext({
    required this.week,
    required this.trimester,
    required this.symptoms,
    required this.medications,
    this.conditions = const [],
    this.diet,
    this.firstBaby,
  });

  final int week;
  final int trimester;
  final List<LoggedSymptomCtx> symptoms;
  final List<String> medications;

  // ---- declared signals from the Living Family Profile ---------------------
  //  Everything above is DERIVED from her data; these are things she TOLD us,
  //  so Ask Veda never re-asks what she has already said. Content only: they
  //  change what an answer mentions, never the app's structure.
  //
  //  BILINGUAL, and they have to be. These are not carried around as data — they
  //  are dropped straight into a sentence [personalLine] speaks back to her. As
  //  plain English strings they produced "आप vegetarian खाना खाती हैं…": one
  //  Latin word mid-Devanagari, which reads badly and which the hi-IN narration
  //  voice cannot pronounce at all. Holding both sides lets the same field be
  //  MATCHED on `.en` (the query terms and content tags are English) and SHOWN
  //  with `.of(lang)`.
  final List<LocalizedText> conditions; // e.g. "gestational diabetes"
  final LocalizedText? diet; // e.g. "vegetarian" / "शाकाहारी"
  final bool? firstBaby;

  static const int _termWeeks = 40;

  /// Read the mother's local data (controller + symptom/medicine stores).
  factory VedaContext.gather(PregnancyController p) {
    final week = p.currentWeek;
    final tri = week <= 13 ? 1 : (week <= 27 ? 2 : 3);
    final due = DateTime(p.dueDate.year, p.dueDate.month, p.dueDate.day);

    // Logged symptoms → resolve to the Symptom + the week she logged it.
    final symptoms = <LoggedSymptomCtx>[];
    final seen = <String>{};
    for (final log in SymptomStore.instance.logs) {
      final sym = _symptomById(log.symptomId);
      if (sym == null) continue;
      if (!seen.add(sym.id)) continue; // one entry per symptom
      var w = week;
      final date = DateTime.tryParse(log.dateKey);
      if (date != null) {
        final d = DateTime(date.year, date.month, date.day);
        final raw =
            _termWeeks - (due.difference(d).inDays / 7).round();
        w = raw.clamp(4, 40);
      }
      symptoms.add(
          LoggedSymptomCtx(symptom: sym, week: w, severity: log.severity));
    }

    final meds = MedicineStore.instance.activeMeds
        .map((m) => m.name)
        .where((n) => n.trim().isNotEmpty)
        .toList();

    // The Living Family Profile — what she has TOLD us, as opposed to what we
    // derived above. Defensive like every other read here: a store that has not
    // loaded, or throws under the test harness, degrades to no signals rather
    // than breaking an answer.
    var conditions = const <LocalizedText>[];
    LocalizedText? diet;
    bool? firstBaby;
    try {
      final fp = FamilyProfileStore.instance;
      // Lower-cased on the English side only. Hindi has no case, and applying
      // toLowerCase() to Devanagari is a no-op that would only invite someone
      // to "fix" it later; keeping it explicit says the casing is for matching.
      conditions = fp.pregConditions
          .map((c) => LocalizedText(en: c.label.en.toLowerCase(), hi: c.label.hi))
          .toList();
      final d = fp.diet?.label;
      diet = d == null
          ? null
          : LocalizedText(en: d.en.toLowerCase(), hi: d.hi);
      firstBaby = fp.parity == null ? null : fp.parity == Parity.first;
    } catch (_) {/* no declared signals */}

    return VedaContext(
      week: week,
      trimester: tri,
      symptoms: symptoms,
      medications: meds,
      conditions: conditions,
      diet: diet,
      firstBaby: firstBaby,
    );
  }

  static Symptom? _symptomById(String id) {
    for (final x in kSymptoms) {
      if (x.id == id) return x;
    }
    return null;
  }

  String _triName(AppLanguage lang) {
    final en = lang.isEnglish;
    switch (trimester) {
      case 1:
        return en ? 'first trimester' : 'पहली तिमाही';
      case 2:
        return en ? 'second trimester' : 'दूसरी तिमाही';
      default:
        return en ? 'third trimester' : 'तीसरी तिमाही';
    }
  }

  /// A short, warm personalized sentence for Section 2 ("What this means for
  /// you"). With [includeWeekLead] it opens with her week/trimester (used for
  /// retrieval answers, which have no built-in personalization); for the
  /// hand-authored showcase answers we pass false so only the genuinely
  /// personal bits (a relevant logged symptom / medication) are appended.
  /// Returns null when there's nothing personal to add.
  String? personalLine(String query, AppLanguage lang,
      {bool includeWeekLead = true}) {
    final en = lang.isEnglish;
    final parts = <String>[];

    if (includeWeekLead) {
      parts.add(en
          ? "You're in week $week (${_triName(lang)})."
          : "आप $weekवें हफ़्ते में हैं (${_triName(lang)})।");
    }

    final q = query.toLowerCase();
    // A logged symptom relevant to the question?
    for (final ls in symptoms) {
      final terms = <String>{
        ...ls.symptom.name.en
            .toLowerCase()
            .split(RegExp(r'[^a-z0-9]+')),
        ...ls.symptom.keywords.map((k) => k.toLowerCase()),
      }..removeWhere((t) => t.length < 3);
      if (terms.any((t) => q.contains(t))) {
        final n = ls.symptom.name.of(lang);
        parts.add(en
            ? "You noted $n around week ${ls.week} - keep an eye on it and mention it at your next visit."
            : "आपने ${ls.week}वें हफ़्ते के आसपास $n के बारे में बताया था — इस पर नज़र रखिए और अगली बार डॉक्टर से मिलें तो ज़िक्र ज़रूर कीजिए।");
        break;
      }
    }

    // An active medication mentioned in the question?
    for (final m in medications) {
      if (m.trim().length >= 3 && q.contains(m.toLowerCase())) {
        parts.add(en
            ? "You're tracking $m - check anything new against it with your doctor."
            : "आप $m ले रही हैं — कोई भी नई चीज़ इसके साथ डॉक्टर से पूछकर ही लीजिए।");
        break;
      }
    }

    // A condition she told us about, relevant to the question. Ranked after the
    // logged symptom because a symptom she recorded this week is more immediate
    // than a standing condition - but it matters more than diet, so it comes
    // first of the declared signals.
    for (final c in conditions) {
      // MATCH on both sides, SHOW one. The query is whatever she typed, so a
      // Hindi question ("ख़ून की कमी में क्या खाऊँ") must be able to hit the same
      // condition an English one does; matching `.en` alone would have made
      // this whole branch dead code for every Hindi user.
      final probes = <String>{c.en.split(' ').first, c.hi.split(' ').first}
        ..removeWhere((t) => t.length < 4);
      if (probes.any(q.contains)) {
        final name = c.of(lang);
        parts.add(en
            ? "You've told us about $name - it's worth reading this with that in mind, and checking anything new with your doctor."
            : "आपने हमें $name के बारे में बताया था — इसे उसी बात को ध्यान में रखकर पढ़िए, और कुछ भी नया हो तो डॉक्टर से पूछ लीजिए।");
        break;
      }
    }

    // Diet, but only when the question is actually about food. Mentioning it
    // anywhere else would be the app showing off that it remembered, which is
    // the opposite of personalization feeling invisible.
    //
    // The keyword list stays as it is: `khana`/`khaana` are Latin-script Hindi,
    // which the house style dropped for COPY - but this is not copy, it is a
    // list of things a mother may type, and she still types Roman on a phone
    // keyboard. `tool/hindi/_never_translate.tsv` is where strings code reads
    // rather than renders belong. The Devanagari spellings are added beside
    // them rather than replacing them, so both keyboards work.
    final foodish = ['eat', 'food', 'diet', 'recipe', 'khana', 'khaana', 'nutrition', 'protein', 'iron', 'calcium',
                     'खाना', 'खानपान', 'भोजन', 'रेसिपी', 'आयरन', 'प्रोटीन', 'कैल्शियम']
        .any((t) => q.contains(t));
    // Copied to a local because `diet` is a FIELD, and Dart will not promote a
    // field to non-null across the closure boundary below - the analyzer is
    // right to refuse: nothing stops another isolate reassigning it in general.
    final dietText = diet;
    if (foodish && dietText != null) {
      // `.of(lang)`, not `.en`: this is DISPLAY. It is the fix for a Hindi
      // sentence that used to read "आप vegetarian खाना खाती हैं…" - and it is
      // why DietPreference's Hindi labels are adjectival (शाकाहारी, not
      // "अंडा खाने वाली"), since they land in front of "खाना खाती हैं".
      final d = dietText.of(lang);
      parts.add(en
          ? "You eat $d, so we've kept that in mind here."
          : "आप $d खाना खाती हैं, इसलिए हमने यहाँ वही ध्यान में रखा है।");
    }

    if (parts.isEmpty) return null;
    return parts.join(' ');
  }
}
