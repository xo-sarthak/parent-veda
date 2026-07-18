// =============================================================================
//  Personalization Engine — invariants AND liveness
// -----------------------------------------------------------------------------
//  Two halves, both required.
//
//  INVARIANTS prove personalization did not restructure the app: the same set of
//  items comes back, nothing is hidden, nothing becomes unreachable.
//
//  LIVENESS proves it actually DOES something. This half is not optional. The
//  Brand Studio Premiere sat dead for months because every test asserted only
//  what should NOT appear — an engine that changes nothing passes an invariant
//  suite perfectly. See docs/PERSONALIZATION.md §7.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/family_profile.dart';

/// A stand-in for anything orderable — a tool tile, a card, a rail item.
class _Item {
  const _Item(this.id, this.priority);
  final String id;
  final PregPriority? priority;
}

const _tools = <_Item>[
  _Item('garbh', PregPriority.anxiety),
  _Item('bump', null),
  _Item('journal', null),
  _Item('weight', PregPriority.nutrition),
  _Item('kegel', PregPriority.fitness),
  _Item('contractions', PregPriority.birthPrep),
  _Item('canI', null),
  _Item('symptoms', PregPriority.symptoms),
];

void main() {
  final p = FamilyProfileStore.instance;

  setUp(() {
    // A clean profile before each test — the store is a singleton.
    p.clearPregConditions();
    for (final x in PregPriority.values) {
      if (p.wantsPreg(x)) p.togglePregPriority(x);
    }
    p.setDiet(null);
    p.setParity(null);
  });

  group('invariants — personalization never restructures', () {
    test('ordering returns every item it was given', () {
      p.togglePregPriority(PregPriority.symptoms);
      final out = p.orderByPregPriority(_tools, (t) => t.priority);
      expect(out.length, _tools.length);
      expect(out.map((e) => e.id).toSet(), _tools.map((e) => e.id).toSet());
    });

    test('no item is hidden however many priorities are chosen', () {
      for (final x in PregPriority.values) {
        p.togglePregPriority(x);
      }
      final out = p.orderByPregPriority(_tools, (t) => t.priority);
      expect(out.length, _tools.length);
    });

    test('an empty profile leaves the order exactly as authored', () {
      final out = p.orderByPregPriority(_tools, (t) => t.priority);
      expect(out.map((e) => e.id), _tools.map((e) => e.id));
    });

    test('unprioritised items keep their relative order behind boosted ones', () {
      p.togglePregPriority(PregPriority.fitness);
      final out = p.orderByPregPriority(_tools, (t) => t.priority);
      final rest = out.where((e) => e.priority != PregPriority.fitness).map((e) => e.id).toList();
      final authored = _tools.where((e) => e.priority != PregPriority.fitness).map((e) => e.id).toList();
      expect(rest, authored, reason: 'a stable sort must not shuffle the rest');
    });

    test('boosts are weights, never a filter — they cannot exclude anything', () {
      p.togglePregCondition(PregCondition.anemia);
      final boosts = p.recoBoosts();
      expect(boosts.values.every((w) => w > 0), isTrue);
    });
  });

  group('liveness — personalization actually does something', () {
    test('two different profiles produce two different tool orders', () {
      p.togglePregPriority(PregPriority.symptoms);
      final a = p.orderByPregPriority(_tools, (t) => t.priority).map((e) => e.id).toList();

      p.togglePregPriority(PregPriority.symptoms); // off
      p.togglePregPriority(PregPriority.birthPrep);
      final b = p.orderByPregPriority(_tools, (t) => t.priority).map((e) => e.id).toList();

      expect(a, isNot(equals(b)), reason: 'the engine must visibly change something');
      expect(a.first, 'symptoms');
      expect(b.first, 'contractions');
    });

    test('a chosen priority reaches the front', () {
      p.togglePregPriority(PregPriority.nutrition);
      final out = p.orderByPregPriority(_tools, (t) => t.priority);
      expect(out.first.id, 'weight');
    });

    test('conditions outrank priorities in the boost map', () {
      p.togglePregPriority(PregPriority.nutrition);
      p.togglePregCondition(PregCondition.gestationalDiabetes);
      final b = p.recoBoosts();
      expect(b['gestationalDiabetes']! > b['nutrition']!, isTrue);
    });

    test('the focus line changes with the profile, and always says something', () {
      expect(p.pregnancyFocus(), 'Your week, thoughtfully');
      p.togglePregPriority(PregPriority.sleep);
      expect(p.pregnancyFocus(), isNot('Your week, thoughtfully'));
      // Health outranks a chosen priority.
      p.togglePregCondition(PregCondition.gestationalDiabetes);
      expect(p.pregnancyFocus(), contains('sugar'));
    });

    test('matchesSignal picks up pregnancy vocabulary, not just parenting', () {
      expect(p.matchesSignal('managing anemia in pregnancy'), isFalse);
      p.togglePregCondition(PregCondition.anemia);
      expect(p.matchesSignal('managing anemia in pregnancy'), isTrue);
    });

    test('the AI context reports declared signals and nothing more', () {
      expect(p.pregnancyAiContext(), isNull, reason: 'nothing declared yet');
      p.setParity(Parity.first);
      p.setDiet(DietPreference.vegetarian);
      final ctx = p.pregnancyAiContext()!;
      expect(ctx, contains('first pregnancy'));
      expect(ctx, contains('vegetarian'));
      // Week/trimester are derived elsewhere; repeating them here would be the
      // duplication the engine exists to avoid.
      expect(ctx, isNot(contains('week')));
    });
  });

  progressiveProfilingTests();

  group('the parenting side is untouched by the pregnancy vocabulary', () {
    test('pregnancy signals do not leak into the parenting focus line', () {
      p.togglePregCondition(PregCondition.gestationalDiabetes);
      expect(p.personalizedFocus(), isNot(contains('sugar')));
    });

    test('parenting ordering still works on its own vocabulary', () {
      final items = [
        const _PItem('sleep', Priority.sleep),
        const _PItem('play', Priority.play),
      ];
      p.togglePriority(Priority.play);
      final out = p.orderByPriority(items, (i) => i.priority);
      expect(out.first.id, 'play');
      expect(out.length, 2);
      p.togglePriority(Priority.play); // clean up the singleton
    });
  });
}

class _PItem {
  const _PItem(this.id, this.priority);
  final String id;
  final Priority? priority;
}

// =============================================================================
//  Progressive profiling — asks once, never nags, never blocks
// -----------------------------------------------------------------------------
//  The shouldAsk/markAsked machinery existed for a long time with ZERO callers.
//  These tests exist so it cannot quietly go dead again.
// =============================================================================
void progressiveProfilingTests() {
  final p = FamilyProfileStore.instance;

  group('progressive profiling', () {
    setUp(() {
      p.clearPregConditions();
      for (final x in PregPriority.values) {
        if (p.wantsPreg(x)) p.togglePregPriority(x);
      }
      p.setDiet(null);
    });

    test('an unknown field is asked; a known one is not', () {
      // Fresh field with no value -> ask.
      expect(p.shouldAsk(ProfileField.diet) || p.asked(ProfileField.diet), isTrue);
      p.setDiet(DietPreference.jain);
      expect(p.shouldAsk(ProfileField.diet), isFalse,
          reason: 'we already know the answer');
    });

    test('once marked asked, it never asks again — even if still unknown', () {
      p.markAsked(ProfileField.pregPriorities);
      expect(p.shouldAsk(ProfileField.pregPriorities), isFalse,
          reason: 'dismissing must be permanent, or the strip becomes a nag');
      // Still genuinely unknown...
      expect(p.pregPriorities, isEmpty);
      // ...and STILL not asked.
      expect(p.shouldAsk(ProfileField.pregPriorities), isFalse);
    });

    test('every pregnancy field is reachable by the progressive path', () {
      // A field with no ProfileField case could never be asked in context,
      // which is how a signal silently becomes unfillable.
      for (final f in [
        ProfileField.pregHealth,
        ProfileField.pregPriorities,
        ProfileField.diet,
        ProfileField.parity,
      ]) {
        expect(() => p.shouldAsk(f), returnsNormally);
      }
    });

    test('answering a strip immediately feeds the engine', () {
      p.markAsked(ProfileField.pregPriorities);
      p.togglePregPriority(PregPriority.fitness);
      // The very signal she just gave must already be live in the boost map -
      // the payoff has to be real, not deferred to some later session.
      expect(p.recoBoosts()['fitness'], isNotNull);
    });
  });
}
