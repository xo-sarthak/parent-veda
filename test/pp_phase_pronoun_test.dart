// =============================================================================
//  The age page talks about HER child (gap analysis P1, Behind · Age by age)
// -----------------------------------------------------------------------------
//  "A girl's mother is told about 'him' on every age page." The phases are
//  authored with he/him/his; `kPhases` fills them for the active child. A girl
//  reads she/her, a child whose sex was not given reads the name (or "your
//  baby"), and a boy reads the text as written.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phases_data.dart';

final _he = RegExp(r'\b(he|him|his|himself)\b', caseSensitive: false);

String _all(AgePhase p) => [
      p.name,
      p.tagline,
      p.summary,
      ...p.workingOn,
      p.reassurance,
      for (final m in p.milestones) m.text,
      for (final s in p.sections) ...[s.heading, ...s.paragraphs],
      p.screeningNote ?? '',
      p.indianNote ?? '',
    ].join(' ');

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 200)));
  });
  tearDown(() => ChildProfileStore.instance.resetForTest());

  test('the authored phases are about the child, and only the child, as "he"', () {
    final authored = kPhasesAuthored.map(_all).join(' ');
    expect(RegExp(r'\b(she|her|hers|herself)\b').hasMatch(authored), isFalse,
        reason: 'a she/her in the authored text would be flipped wrongly for a girl');
    expect(_he.hasMatch(authored), isTrue);
  });

  test('a girl reads she and her on every phase', () {
    final c = ChildProfileStore.instance;
    c.active
      ..name = 'Meera'
      ..isBoy = false
      ..sexGiven = true;
    for (final p in kPhases) {
      expect(_he.hasMatch(_all(p)), isFalse, reason: 'phase ${p.number}');
    }
    expect(ppFillChild('He rolls, and his hands find him.'), 'She rolls, and her hands find her.');
  });

  test('sex not given: the name, never he or she', () {
    final c = ChildProfileStore.instance;
    c.active
      ..name = 'Meera'
      ..sexGiven = false;
    expect(ppFillChild('He smiles at his hands.'), "Meera smiles at Meera's hands.");
    for (final p in kPhases) {
      expect(_he.hasMatch(_all(p)), isFalse, reason: 'phase ${p.number}');
    }
  });

  test('a boy reads the text as written, and the fill follows a change of child', () {
    final c = ChildProfileStore.instance;
    c.active
      ..name = 'Arjun'
      ..isBoy = true
      ..sexGiven = true;
    // The phase as shown is the authored one with its phase doc laid over it
    // (2026-10-13, `ppPhaseWithDoc`); a boy reads that as written.
    expect(_all(kPhases.first), _all(ppPhaseWithDoc(kPhasesAuthored.first)));
    // The doc text says "your baby", so a girl's phase 1 reads the same; the
    // cache is checked by identity instead (doc-only phases, 2026-10-14).
    final before = kPhases;
    c.active.isBoy = false;
    expect(identical(kPhases, before), isFalse, reason: 'the cache follows the child');
  });

  test('currentPhase and phaseByNumber read the filled list', () {
    final c = ChildProfileStore.instance;
    c.active
      ..isBoy = false
      ..sexGiven = true;
    expect(_he.hasMatch(_all(currentPhase())), isFalse);
    expect(_he.hasMatch(_all(phaseByNumber(10)!)), isFalse);
  });
}
