// =============================================================================
//  A coach named on a screen is a coach who exists, in every stage
// -----------------------------------------------------------------------------
//  ⚠️ THE REPORT THAT PROMPTED THIS: "when I am in the Prepare section, if I
//  click on any cohort and courses like a masterclass and I see the coach, I'm
//  not able to click on that coach profile… but if I go to Yoga I can click on
//  their profile."
//
//  Parenting had already been through this once — see `pp_expert_links_test`,
//  written after twenty-two of twenty-eight expert names turned out to open
//  nothing. The lesson recorded there was that **the fix is the join, not the
//  tap**: a NAME typed into a content file cannot be checked against anything,
//  so it drifts and it can be invented, and adding a GestureDetector to it
//  produces a tap that opens a profile for somebody who does not exist.
//
//  ⚠️ SO WHY DOES PREGNANCY JOIN ON A NAME AND NOT AN ID? Because re-keying
//  every `Coach`, `Cohort`, `PrepProgram` and `YogaClass` literal — about forty
//  of them across two SHIPPED stages — buys nothing that this file does not,
//  provided two things hold:
//
//    1. no two experts share a name, so a name resolves to exactly one person;
//    2. every name that content prints actually resolves.
//
//  Both are asserted below, which turns the weak key into a checked one. The
//  trade is stated rather than hidden: an id would fail at compile time, a name
//  fails here. What matters is that it fails BEFORE a mother taps it.
//
//  ⚠️ THIS FILE IS THE WIRING GATE FOR THIS FEATURE (CLAUDE.md). Counting
//  passing tests proves nothing about reachability; these assertions run over
//  the actual content catalogues, so a masterclass added next month with a new
//  coach fails until she is in the roster.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/prepare_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_experts_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_yoga_data.dart';
import 'package:parentveda/screens/prepare/birthing_classes_screen.dart';

String _norm(String s) => s.toLowerCase().replaceAll(RegExp('[^a-z]'), '');

/// Names that are deliberately nobody.
///
/// `_fromMasterclass` and `_fromCohort` fall back to "Your expert" / "Your
/// coach" when a programme has no named coach. That is a LABEL, not a person,
/// and the screens render it un-tappable — which is correct, and is why it must
/// be excluded here rather than "fixed" by inventing an expert called Your
/// Coach.
final Set<String> _placeholders = {
  _norm('Your expert'),
  _norm('Your coach'),
};

void main() {
  group('every coach Pregnancy names has a profile to open', () {
    test('masterclass coaches', () {
      for (final m in kMasterclasses) {
        for (final c in m.coaches) {
          if (_placeholders.contains(_norm(c.name.en))) continue;
          expect(expertByName(c.name.en), isNotNull,
              reason: 'Masterclass "${m.title.en}" credits "${c.name.en}", who '
                  'is not in kExperts. The name renders and the tap opens '
                  'nothing — add her to lib/experts/pregnancy_experts.dart.');
        }
      }
    });

    test('cohort coaches', () {
      for (final c in kCohorts) {
        final name = c.coachName?.en;
        if (name == null || _placeholders.contains(_norm(name))) continue;
        expect(expertByName(name), isNotNull,
            reason: 'Cohort "${c.name.en}" credits "$name", who is not in '
                'kExperts.');
      }
    });

    test('programme instructors', () {
      for (final p in kPrepPrograms) {
        final name = p.instructorName.en;
        if (_placeholders.contains(_norm(name))) continue;
        expect(expertByName(name), isNotNull,
            reason: 'Programme "${p.title.en}" credits "$name", who is not in '
                'kExperts.');
      }
    });

    test('consultation specialists', () {
      for (final s in kSpecialists) {
        expect(expertByName(s.name.en), isNotNull,
            reason: 'Specialist "${s.name.en}" has no roster entry, so the '
                '"view full profile" link on her consultation page cannot '
                'render.');
      }
    });

    test('the birthing-course instructor', () {
      // ⚠️ NOT A LITERAL. The screen reads `kBirthingInstructor`, so this reads
      // it too — a test asserting 'Meera Nair' would keep passing after
      // somebody edited the screen, which is the whole failure mode.
      expect(expertByName(kBirthingInstructor), isNotNull,
          reason: 'The birthing course credits "$kBirthingInstructor", who is '
              'not in kExperts.');
    });
  });

  test('every yoga & movement teacher has a profile to open', () {
    // These join on `instructorName` because `classesByInstructor` already did,
    // long before profiles existed. Same contract as above.
    for (final c in kYogaClasses) {
      expect(expertByName(c.instructorName), isNotNull,
          reason: 'Class "${c.title}" is taught by "${c.instructorName}", who '
              'is not in kExperts — the instructor row falls back to the old '
              'class-derived screen instead of her real profile.');
    }
  });

  test('no two experts share a name', () {
    // ⚠️ THIS IS WHAT MAKES A NAME A USABLE KEY AT ALL, and it caught a real
    // collision: Pregnancy's obstetrician and Parenting's paediatrician were
    // BOTH called "Dr. Ananya Rao". They are different people with different
    // specialties, so the moment both became tappable, tapping the obstetrician
    // would have opened a paediatrician's profile under her name. Pregnancy's
    // was renamed to Dr. Aparna Joshi.
    //
    // `pp_expert_links_test` already asserts this over `kFindHelpExperts`. This
    // one runs over the WHOLE registry, because the collision was between two
    // experts neither of which was in the find-help roster.
    final seen = <String, String>{};
    for (final e in kExperts) {
      final key = _norm(e.name);
      expect(seen.containsKey(key), isFalse,
          reason: 'Two experts are called "${e.name}" (ids "${seen[key]}" and '
              '"${e.id}"). expertByName returns the first, so one of them is '
              'unreachable and the other answers to a name that is not only '
              'hers.');
      seen[key] = e.id;
    }
  });

  test('a name that opens a profile opens a profile worth reading', () {
    // ⚠️ THE SECOND HALF OF THE ORIGINAL COMPLAINT. Making the tap work is not
    // the whole ask — "when I click on the profile what I see about this doctor
    // should be a bit more in depth… qualifications, what she is, what she
    // does." A row that opens a page repeating the name and nothing else is a
    // dead tap with extra steps.
    //
    // Scoped to the people CONTENT NAMES, not to all of kExperts: the ~40
    // find-help doctors are lean rows whose degrees live in `blurb`, and
    // padding them out with invented qualifications would be worse than an
    // honest gap. Credentials are claims about real people — see the warning
    // in lib/experts/expert.dart.
    final named = <String>{
      for (final m in kMasterclasses) ...[for (final c in m.coaches) c.name.en],
      for (final c in kCohorts) if (c.coachName != null) c.coachName!.en,
      for (final p in kPrepPrograms) p.instructorName.en,
      for (final s in kSpecialists) s.name.en,
      for (final c in kYogaClasses) c.instructorName,
      kBirthingInstructor,
    };

    for (final name in named) {
      if (_placeholders.contains(_norm(name))) continue;
      final e = expertByName(name);
      if (e == null) continue; // already failed above, with a better message
      expect(e.hasProfile, isTrue,
          reason: '"$name" resolves but her profile would be almost empty.');
      expect(e.qualifications, isNotEmpty,
          reason: '"$name" leads something people pay for and her profile '
              'shows no qualifications. That is the block the profile exists '
              'for.');
      expect(e.experience.trim(), isNotEmpty,
          reason: '"$name" has no experience line on her profile.');
    }
  });

  test('a person is described once, not once per class', () {
    // ⚠️ THE DRIFT THE ROSTER EXISTS TO END. Nisha Pillai was a "Yoga &
    // Breathwork Guide · 8 yrs" on six yoga classes and a "Meditation &
    // Breathwork Guide · 8 yrs" on four others — one person, one data file, two
    // credentials, and nothing that could notice.
    //
    // The class-level credential is still rendered on cards, so it must not
    // fork again. This does not require it to match the roster word for word
    // (the roster's is broader on purpose — it names all three practices); it
    // requires each teacher to have exactly ONE class-level credential.
    final byTeacher = <String, Set<String>>{};
    for (final c in kYogaClasses) {
      byTeacher.putIfAbsent(c.instructorName, () => <String>{}).add(c.instructorCredential);
    }
    byTeacher.forEach((name, creds) {
      expect(creds.length, 1,
          reason: '"$name" is described ${creds.length} different ways across '
              'her classes: ${creds.join(" / ")}. Pick one, or move the '
              'difference into her roster entry.');
    });
  });
}
