// "Not interested" on a Spiritual Reading was saved under the DISPLAY title
// (`title.now`) while "interested" and the sort used the English one, so a mark
// made in Hindi matched nothing after a switch. The store re-keys old marks onto
// the English title (2026-09-30, docs/STILL-OPEN.md §81.16).
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/data/spiritual_reading_data.dart';
import 'package:parentveda/services/spiritual_prefs_store.dart';

void main() {
  final idx = spiritualTitleIndex();
  final read = kSpiritualTraditions.first.sections.first.reads.first;

  Set<String> run(Iterable<String> keys) => migrateSpiritualNotInterested(keys,
      englishTitles: idx.en, hindiToEnglish: idx.hiToEn);

  test('an English key stays', () {
    expect(run([read.title.en]), {read.title.en});
  });

  test('a Hindi display key becomes the English title', () {
    expect(read.title.hi, isNot(read.title.en), reason: 'the fixture read must differ per language');
    expect(run([read.title.hi]), {read.title.en});
  });

  test('a key that is neither stays (a removed read is not ours to drop)', () {
    expect(run(['A read that no longer exists']), {'A read that no longer exists'});
  });

  test('it is idempotent: a second run changes nothing', () {
    final once = run([read.title.hi, 'gone']);
    expect(run(once), once);
  });

  test('a mark saved in Hindi and one saved in English collapse to one', () {
    expect(run([read.title.hi, read.title.en]), {read.title.en});
  });

  test('a Hindi title two different reads share is left alone, never guessed', () {
    // "बड़ों का आशीर्वाद" is the Hindi title of two English reads, so a stale mark
    // under it cannot say which she meant.
    const shared = 'बड़ों का आशीर्वाद';
    expect(idx.hiToEn.containsKey(shared), isFalse);
    expect(run([shared]), {shared});
  });

  test('every Hindi title that maps at all maps to a real English title', () {
    for (final en in idx.hiToEn.values) {
      expect(idx.en, contains(en));
    }
  });
}
