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
  });

  final int week;
  final int trimester;
  final List<LoggedSymptomCtx> symptoms;
  final List<String> medications;

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

    return VedaContext(
        week: week, trimester: tri, symptoms: symptoms, medications: meds);
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
        return en ? 'first trimester' : 'pehli trimester';
      case 2:
        return en ? 'second trimester' : 'doosri trimester';
      default:
        return en ? 'third trimester' : 'teesri trimester';
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
          : "Aap week $week mein hain (${_triName(lang)}).");
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
            : "Aapne $n week ${ls.week} ke aas-paas note kiya tha - ispar nazar rakhein aur agli visit par doctor ko zaroor batayein.");
        break;
      }
    }

    // An active medication mentioned in the question?
    for (final m in medications) {
      if (m.trim().length >= 3 && q.contains(m.toLowerCase())) {
        parts.add(en
            ? "You're tracking $m - check anything new against it with your doctor."
            : "Aap $m track kar rahi hain - koi nayi cheez iske saath doctor se confirm kar lein.");
        break;
      }
    }

    if (parts.isEmpty) return null;
    return parts.join(' ');
  }
}
