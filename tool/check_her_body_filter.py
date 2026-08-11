"""Does the Hindi half of the father safety filter agree with the English half?

`father_day_derive.dart` hides a mother's day from a father when it speaks to
HER body. It asks two questions - `_herBody` against the English, `_herBodyHi`
against the Hindi - and either one is enough to hide the day.

READ THIS BEFORE INTERPRETING THE NUMBERS. Both halves run on both fields of
the SAME LocalizedText, whatever language the reader is in, so a day is hidden
or shown identically for everyone. There is no per-language safety net here and
no such thing as "a Hindi reader is exposed" - an earlier version of this file
said exactly that, and it was wrong.

What each column actually means:

    both      belt and braces; either half alone would have caught it
    EN only   caught by the English half. NOT a gap - the day is still hidden.
              It only tells you the Hindi vocabulary list lacks that word.
    HI only   the ONLY column the Hindi half earns its keep in: days whose
              Hindi speaks to her body while the English does not.

The failure this guards is still real - the Hindi half sat matching nothing for
the whole period between the Devanagari migration and someone noticing - but it
costs coverage, not correctness-for-Hindi-readers.

THE OPPOSITE RISK MATTERS TOO, and it is the live one. `pickFatherSource` walks
the week for a day that reads cleanly to a father; if all 7 are flagged it falls
back to the least-bad day and he may see her-body content. So a filter that
matches too EAGERLY is not "safely conservative" - past 6 of 7 it starts eating
its own escape hatch. Run tool/check_her_body_filter.py after any content change
and watch the worst-week number, not just the totals.

    python tool/check_her_body_filter.py
"""

import glob
import json
import re

EN = re.compile(
    r'your (body|belly|womb|bump|uterus|breasts?|hips?|pelvis|energy|blood|'
    r'hormones?|skin|ankles)', re.I)

HI = re.compile(
    'शरीर|पेट|बच्चेदानी|गर्भाशय|कोख|स्तन|छाती|कमर|कूल्ह|टख[नन]|'
    'हॉर्मोन|हार्मोन|ख़ून|खून|त्वचा|ऊर्जा|थकान')

# Exactly the fields _herScore() inspects. Checking fields the father never
# sees would inflate the numbers and hide the ones that matter.
FIELDS = [
    ('grow', 'title'), ('grow', 'insight'), ('grow', 'expanded'),
    ('grow', 'remember'), ('grow', 'deepDive'),
    ('talkToBaby', 'title'), ('talkToBaby', 'motivation'),
    ('nurture', 'title'), ('nurture', 'remember'),
]


def saturation():
    """Worst-case flagged days in any one week, and the distribution.

    pickFatherSource() needs at least ONE unflagged day per week. The original
    design note said "no week has more than 3 such days out of 7" - that was
    measured when the Hindi half matched nothing, and translating the content
    to Devanagari woke it up. The claim is no longer true, so it is measured
    here rather than asserted in a comment.
    """
    worst, hist = 0, {}
    for path in sorted(glob.glob('lib/data/home/week_*.json')):
        flagged = 0
        for day in json.load(open(path, encoding='utf-8')):
            hit = False
            for block, field in FIELDS:
                t = (day.get(block) or {}).get(field)
                if not isinstance(t, dict) or 'en' not in t:
                    continue
                if EN.search(t['en'] or '') or HI.search(t.get('hi') or ''):
                    hit = True
                    break
            flagged += hit
        worst = max(worst, flagged)
        hist[flagged] = hist.get(flagged, 0) + 1
    return worst, dict(sorted(hist.items()))


def main():
    both = en_only = hi_only = 0
    examples = []
    for path in sorted(glob.glob('lib/data/home/week_*.json')):
        for day in json.load(open(path, encoding='utf-8')):
            for block, field in FIELDS:
                t = (day.get(block) or {}).get(field)
                if not isinstance(t, dict) or 'en' not in t:
                    continue
                e = EN.search(t['en'] or '')
                h = HI.search(t.get('hi') or '')
                if e and h:
                    both += 1
                elif e:
                    en_only += 1
                    if len(examples) < 12:
                        examples.append((path.split('/')[-1], block, field,
                                         e.group(0), (t.get('hi') or '')[:70]))
                elif h:
                    hi_only += 1

    print('both flagged   %4d   either half would have caught it' % both)
    print('EN only        %4d   still hidden; Hindi list lacks the word'
          % en_only)
    print('HI only        %4d   the Hindi half earning its keep' % hi_only)

    # The number that actually decides whether the feature still works.
    worst, hist = saturation()
    print('\nworst week     %d/7 days flagged   %s' % (worst, hist))
    if worst >= 7:
        print('*** NO CLEAN DAY. pickFatherSource() falls back to least-bad '
              'and a father can be shown her-body content. Loosen the filter.')
    elif worst == 6:
        print('    (6/7 leaves one clean day - functional, but no headroom)')

    if examples:
        print('\nEnglish flags these, Hindi does not:')
        for f, b, fld, hit, hi in examples:
            print('  %-14s %s.%-10s "%s"\n     %s' % (f, b, fld, hit, hi))


if __name__ == '__main__':
    main()
