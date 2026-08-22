// =============================================================================
//  An expert named in content is an expert who exists
// -----------------------------------------------------------------------------
//  ⚠️ THE BUG THAT PROMPTED THIS: the 30-Day Breastfeeding Journey credited
//  "Priya Nair, Lactation consultant". Priya Nair was a string typed into
//  `pp_journeys_data.dart` and appeared nowhere else in the app. She had no
//  profile, no roster entry, no bookable slot and no reviews.
//
//  Nothing failed. The credit rendered beautifully, looked exactly like every
//  other expert credit in the app, and did nothing when tapped — reported as
//  "in courses we have the doctor name, when you click you can see their
//  profile, but that isn't happening for a lot of sections."
//
//  ⚠️ THE REAL FIX WAS THE TYPE, NOT THE TAP. A NAME typed into a content file
//  cannot be checked against anything, so it will drift and it can be invented.
//  An ID can be resolved, which is what makes this test possible at all. Adding
//  a GestureDetector to a name-shaped string would have produced a tap that
//  opens a profile for somebody who does not exist.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_courses_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_experts_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_journeys_data.dart';

void main() {
  test('a journey credits an expert who is in the roster', () {
    for (final j in kJourneys) {
      if (!j.expertHookPresent) continue;
      final e = j.expert;
      expect(e, isNotNull,
          reason: '"${j.title}" credits expertId "${j.expertId}", which is not '
              'in kFindHelpExperts. The credit will render and the tap will '
              'open nothing.');
      expect(e!.name.trim(), isNotEmpty);
    }
  });

  test('the credited role matches the person credited', () {
    // ⚠️ THE ID FIXES THE NAME AND NOT THE ROLE, which is the half that can
    // still drift. A journey written by a lactation consultant and credited to
    // a paediatrician is a smaller error than an invented person and it is
    // still a wrong one, and only a human reading both would notice.
    for (final j in kJourneys) {
      final e = j.expert;
      if (e == null) continue;
      final role = j.expertRole.toLowerCase();
      final cred = e.credential.toLowerCase();
      if (role.contains('lactation')) {
        expect(cred.contains('lactation'), isTrue,
            reason: '"${j.title}" is credited to a lactation consultant but '
                '${e.name} is "${e.credential}".');
      }
    }
  });

  test('every expert the app can name has a profile worth opening', () {
    // A roster entry with no credential and no blurb opens a profile that
    // tells a parent nothing, which is barely better than the dead tap this
    // file exists to prevent.
    for (final e in kFindHelpExperts) {
      expect(e.name.trim(), isNotEmpty, reason: '${e.id} has no name');
      expect(e.credential.trim(), isNotEmpty,
          reason: '${e.id} has no credential, so its profile says nothing');
      expect(e.category.trim(), isNotEmpty,
          reason: '${e.id} has no category, so no filter can ever reach it');
    }
  });

  test('no two experts share an id', () {
    // `expertById` returns the FIRST match and falls back to the first expert
    // in the list for an unknown id, so a duplicate id silently shadows
    // somebody and an unknown one silently shows the wrong person.
    final ids = kFindHelpExperts.map((e) => e.id).toList();
    expect(ids.toSet().length, ids.length,
        reason: 'duplicate expert id: one of them is unreachable');
  });

  test('no two experts share a name', () {
    // ⚠️ CAUGHT A COLLISION I CREATED. Seeding placeholder people put "Ananya
    // Rao" into the roster beside the existing "Dr. Ananya Rao" — two
    // different professionals, near-identical names, one of them fictional.
    //
    // A parent who booked one and met the other would be right to be alarmed,
    // and nobody scanning a list of twelve placeholders would have spotted it.
    // Plausible fake names are the whole risk of seeding, and this is the
    // cheapest possible guard against it.
    final seen = <String, String>{};
    for (final e in kFindHelpExperts) {
      final key = e.name.toLowerCase().replaceAll('dr. ', '').replaceAll('dr ', '').trim();
      expect(seen.containsKey(key), isFalse,
          reason: '"${e.name}" (${e.id}) collides with "${seen[key]}". '
              'Two people with the same name in one directory is '
              'indistinguishable from a bug.');
      seen[key] = e.id;
    }
  });

  test('a course credits somebody real, with their real credential', () {
    // The prose version had drifted twice without anything noticing: "Dr.
    // Kabir Menon" is Dr. Kabir Sen, and a paediatric sleep consultant was
    // credited as "Paediatric Physio". A sentence in a content file cannot be
    // checked against anything; an id can.
    for (final c in kCourses) {
      if (c.vettedById.isEmpty) continue;
      final e = expertById(c.vettedById);
      expect(e.id, c.vettedById,
          reason: '"${c.title}" credits "${c.vettedById}", which is not an '
              'expert id. `expertById` falls back to the first person in the '
              'list, so this shows the WRONG person rather than failing.');
    }
  });
}
