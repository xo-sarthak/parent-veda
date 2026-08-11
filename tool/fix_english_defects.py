"""Five English content defects, each one a label contradicting its own story.

Found by the translators during the Devanagari pass, not by any test - they read
the English closely enough to notice that a summary described a different story
than the body told. A spell-checker cannot catch these; a schema cannot; only
someone actually reading both halves.

Each fix is the smallest edit that makes the label agree with the story. The
stories themselves are untouched.

  week_04 day 5   "The Moon And The Cap Seller"  - there is no moon anywhere in
                  the tale; it is the cap seller and the monkeys.

  week_20 day 1   "Two quarrelling birds"        - a partridge and a HARE. The
                  hare is not a bird.

  week_10 day 1   "Even a TRUE thing, repeated"  - inverts the fable's whole
                  point. Three crooks repeat a FALSE thing until the Brahmin
                  doubts what he plainly knows. As written, the moral argues
                  the opposite of the story and quietly teaches the wrong
                  lesson to a mother reading aloud.

  week_28 day 4   "The True Heir" / "a true son" - the two-women test. What
                  Birbal identifies is the true MOTHER. Calling her child an
                  heir also imports a claim about the baby's sex into a story
                  where the point is the mother's love.

The Hindi already says what each story actually is - the translators rendered
the content rather than propagating the error, and reported it. These edits make
the two languages agree again.

    python tool/fix_english_defects.py --dry
    python tool/fix_english_defects.py
"""

import io
import json
import sys

FIXES = [
    ('lib/data/home/week_04.json', 5, 'readToBaby', 'title',
     'The Moon And The Cap Seller',
     'The Cap Seller And The Monkeys'),
    ('lib/data/home/week_20.json', 1, 'readToBaby', 'summary',
     'Two quarrelling birds learn that the loudest judge is not always the fairest.',
     'Two quarrelling creatures learn that the loudest judge is not always the fairest.'),
    ('lib/data/home/week_10.json', 1, 'readToBaby', 'body',
     'Even a true thing, repeated often enough by others, can make us doubt what we plainly know.',
     'Even a false thing, repeated often enough by others, can make us doubt what we plainly know.'),
    ('lib/data/home/week_28.json', 4, 'readToBaby', 'title',
     'Birbal Finds The True Heir',
     'Birbal Finds The True Mother'),
    ('lib/data/home/week_28.json', 4, 'readToBaby', 'summary',
     'Wise Birbal reveals a true son by listening for the voice of real love.',
     'Wise Birbal reveals the true mother by listening for the voice of real love.'),
]


def main():
    dry = '--dry' in sys.argv
    docs = {}
    for path, day, block, field, old, new in FIXES:
        doc = docs.setdefault(path, json.load(io.open(path, encoding='utf-8')))
        cur = doc[day][block][field]['en']
        if old not in cur:
            print('REFUSING - %s day %d %s.%s does not contain the expected '
                  'text.\n   looking for: %r' % (path, day, block, field, old))
            return 1
        doc[day][block][field]['en'] = cur.replace(old, new, 1)
        print('%s  day %d  %s.%s' % (path.split('/')[-1], day, block, field))
        print('   - %s' % old)
        print('   + %s' % new)

    if dry:
        print('\nWOULD FIX %d strings (run without --dry to apply)' % len(FIXES))
        return 0

    for path, doc in docs.items():
        io.open(path, 'w', encoding='utf-8', newline='\n').write(
            json.dumps(doc, ensure_ascii=False, indent=2) + '\n')
    print('\nFIXED %d strings in %d files - now run tool/format_home_json.py'
          % (len(FIXES), len(docs)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
