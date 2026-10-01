// =============================================================================
//  The checklist's notes, taken into the doctor visit (2026-10-01)
// -----------------------------------------------------------------------------
//  Second of five changes to what the Pre-pregnancy checklist gives back (the
//  user: "when we collect this information then the user might expect
//  something… is that linked anywhere or are we just collecting it?"). The
//  notes page could only be COPIED as text. Now the same notes are one
//  function that three places read:
//
//    · the notes page and its copy button (as before);
//    · "Add my questions to my next visit": her questions go onto the visit in
//      the Appointments tool, where she already keeps what to ask;
//    · the Records PDF "for an appointment": a short section after the results.
//
//  ⚠️ WHAT SHE TOLD US, AND NOTHING WE CONCLUDED (the note on the summary's
//  copy holds here too): her answers and her questions, no reading of them.
//  Hers only; nothing for his side.
// =============================================================================

import '../localization/app_language.dart';
import '../screens/ttc/ttc_precheck_summary.dart' show precheckDoctorQuestions;
import 'ttc_doctor_questions_store.dart';
import 'ttc_precheck_rules.dart';
import 'ttc_precheck_store.dart';

class PrecheckNotes {
  const PrecheckNotes(this.covered, this.toTalkAbout, this.questions);

  final List<String> covered;
  final List<String> toTalkAbout;
  final List<String> questions;

  /// Nothing she has answered or the app has ticked: nothing to carry.
  bool get isEmpty => covered.isEmpty && toTalkAbout.isEmpty;
}

PrecheckNotes ttcPrecheckNotes(AppLanguage lang) {
  final store = TtcPrecheckStore.instance;
  final c = PrecheckContext.gather();
  return PrecheckNotes(
    [for (final i in store.doneItems(c)) i.title.of(lang)],
    [for (final i in store.openItems(c)) i.title.of(lang)],
    precheckDoctorQuestions(store, c, lang),
  );
}

/// Puts her checklist questions on her next visit (or, with no visit coming,
/// leaves them waiting for the next one she adds, which is how the store
/// already behaves). A question already there is not added twice, in any
/// wording of case. Returns how many were new and which visit they went to.
({int added, TtcVisitRef? visit}) ttcAddPrecheckQuestionsToNextVisit(
    AppLanguage lang) {
  final qs = ttcPrecheckNotes(lang).questions;
  final store = TtcDoctorQuestionsStore.instance;
  final have = <String>{
    for (final q in store.questions)
      if (!q.isRemoved) q.text.trim().toLowerCase(),
  };
  var added = 0;
  for (final q in qs) {
    if (!have.add(q.trim().toLowerCase())) continue;
    if (store.add(q) != null) added++;
  }
  return (added: added, visit: store.nextVisit());
}

/// What Ask Veda is told about her checklist (change 3 of the five): the ids
/// of what she has covered and of what she has flagged, nothing else. Null
/// when there is nothing to say, so the field is simply not sent.
///
/// Only items SHE answered count here, not ticks the app derived from her
/// records: Ask Veda is told what she said, never what we inferred.
Map<String, List<String>>? ttcPrecheckAskVedaContext() {
  final store = TtcPrecheckStore.instance;
  final c = PrecheckContext.gather();
  final covered = <String>[
    for (final i in store.doneItems(c))
      if (store.entryFor(i.id) != null) i.id,
  ];
  final flagged = [for (final i in store.openItems(c)) i.id];
  if (covered.isEmpty && flagged.isEmpty) return null;
  return {'covered': covered, 'flagged': flagged};
}
