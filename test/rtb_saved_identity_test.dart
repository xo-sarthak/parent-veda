// =============================================================================
//  A bookmark must survive the language toggle
// -----------------------------------------------------------------------------
//  SavedRtbPiece used to have no key: a bookmark was found by comparing the
//  title it displayed. That is a display string doing an identity job, and it
//  works right up until the title is translated - after which the same piece
//  answers to a different name in each language. Marks made in English vanish
//  in Hindi, return on switching back, and saving again in Hindi writes a
//  second row for one piece. This store syncs to Supabase, so the duplicate
//  would follow her onto every device.
//
//  The same mistake has now been made three times in this migration
//  (_valueName stripping "ParentVeda ", _fromCohort stripping "^Week N · ",
//  and this), so it is pinned rather than merely fixed.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/read_to_baby_saved_store.dart';

void main() {
  group('SavedRtbPiece identity', () {
    test('a row written before keys existed keeps working', () {
      // Exactly what is sitting in SharedPreferences (and Supabase) today:
      // no 'k', the English title in 't'.
      final old = SavedRtbPiece.fromJson({
        't': 'You are loved',
        'b': 'Little one, you are already so deeply loved.',
        'g': 'Affirmations',
        's': 1700000000000,
      });

      // It must migrate itself, not orphan. This is what buys a zero-migration
      // rollout: every key already persisted IS an English title.
      expect(old.key, 'You are loved');
      expect(old.title, 'You are loved');
    });

    test('key survives a JSON round trip once it differs from the title', () {
      const piece = SavedRtbPiece(
        key: 'You are loved',
        title: 'तुमसे प्यार है',
        body: 'नन्ही जान, तुमसे अभी से इतना गहरा प्यार है।',
        tag: 'Affirmations',
        savedAt: 1700000000000,
      );

      final back = SavedRtbPiece.fromJson(piece.toJson());

      // The identity is English and the display is Hindi, and the codec keeps
      // them apart. If 'k' were ever dropped from toJson this fails here
      // rather than silently in a mother's saved list.
      expect(back.key, 'You are loved');
      expect(back.title, 'तुमसे प्यार है');
      expect(back.body, piece.body);
      expect(back.tag, 'Affirmations');
      expect(back.savedAt, 1700000000000);
    });

    test('the display title is a snapshot, not a live translation', () {
      // A bookmark records what she chose to keep. Re-resolving it on every
      // language change would mean her saved list rewrites itself underneath
      // her; worse, a piece later deleted from the catalogue would lose its
      // text entirely. So the title and body are stored, not looked up.
      final json = const SavedRtbPiece(
        key: 'You are loved',
        title: 'तुमसे प्यार है',
        body: 'नन्ही जान',
        tag: 'Affirmations',
        savedAt: 1,
      ).toJson();

      expect(json['t'], 'तुमसे प्यार है',
          reason: 'the saved copy keeps the language she saved it in');
      expect(json['k'], 'You are loved',
          reason: 'identity is invariant and travels separately');
    });
  });
}
