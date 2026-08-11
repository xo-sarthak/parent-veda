"""Second Latin pass: the words a per-word rule cannot fix blindly.

Ordering matters here. PHRASES run before WORDS, because a word-level swap
inside a phrase produces grammatical rubbish that still compiles and still
reads as Devanagari to every check we have:

    'एक चौड़ी, सामान्य range में'  ->  'एक चौड़ी, सामान्य दायरे में'   WRONG
                                                                  (चौड़ी is
                                       feminine, दायरा is masculine - Hindi
                                       adjectives agree, so the noun cannot be
                                       swapped without the adjective)
    correct:                          'एक चौड़े, सामान्य दायरे में'

Two entries are QUOTED rather than translated. `co-regulation` and
`prenatal attachment` are named research terms introduced with `... कहते हैं`
- the same construction the corpus already uses for 'zone of proximal
development' and 'name it to tame it', which reads naturally and tells the
reader this is a foreign label. They were simply missing their quotes.

    python tool/fix_stray_latin2.py --dry
    python tool/fix_stray_latin2.py
"""

import glob
import io
import re
import sys

PHRASES = [
    # noun+adjective agreement - see module docstring
    ('चौड़ी, सामान्य range', 'चौड़े, सामान्य दायरे'),
    ('peanut butter', 'पीनट बटर'),
    ('neural connections', 'न्यूरल कनेक्शन'),
    # named terms: quote them, do not translate them
    ('वैज्ञानिक co-regulation कहते', "वैज्ञानिक 'co-regulation' कहते"),
    ('जिसे prenatal attachment कहते', "जिसे 'prenatal attachment' कहते"),
]

WORDS = [
    ('mindfulness', 'माइंडफ़ुलनेस'),
    ('affirmations', 'संकल्प'),
    ('affirmation', 'संकल्प'),
    ('pregnancy', 'गर्भावस्था'),
    ('placenta', 'प्लेसेंटा'),
    ('hormones', 'हॉर्मोन'),
    ('hormone', 'हॉर्मोन'),
    ('chart', 'चार्ट'),
    ('attachment', 'अटैचमेंट'),
    ('acidity', 'एसिडिटी'),
    ('appointments', 'अपॉइंटमेंट'),
    ('muscles', 'मांसपेशियाँ'),
    ('ranges', 'दायरों'),
    ('milestone', 'पड़ाव'),
    ('timetable', 'टाइमटेबल'),
    ('parenting', 'परवरिश'),
    ('perfection', 'परफ़ेक्शन'),
    ('monsoon', 'मानसून'),
    ('prenatal', 'गर्भावस्था'),
    ('class', 'क्लास'),
    ('cortisol', 'कॉर्टिसोल'),
    ('labour', 'प्रसव'),
]

QUOTED = re.compile(r"'[^']*'")


def outside_quotes(hi, fn):
    """Apply fn only to the spans NOT inside single quotes."""
    out, last = [], 0
    for m in QUOTED.finditer(hi):
        out.append(fn(hi[last:m.start()]))
        out.append(m.group(0))
        last = m.end()
    out.append(fn(hi[last:]))
    return ''.join(out)


def fix(hi):
    for a, b in PHRASES:          # phrases first, and OUTSIDE the quote guard
        hi = hi.replace(a, b)     # because two of them ADD quotes
    return outside_quotes(
        hi, lambda s: _words(s))


def _words(s):
    for a, b in WORDS:
        s = re.sub(r'\b%s\b' % re.escape(a), b, s)
    return s


def main():
    dry = '--dry' in sys.argv
    total = 0
    for path in sorted(glob.glob('tool/hindi/h_batch*.done.tsv')):
        lines = [l.rstrip('\n') for l in io.open(path, encoding='utf-8')
                 if l.strip()]
        out, n = [], 0
        for l in lines:
            ptr, _, hi = l.partition('\t')
            new = fix(hi)
            if new != hi:
                n += 1
            out.append(ptr + '\t' + new)
        if n:
            print('%-32s %3d row(s)' % (path.split('/')[-1], n))
            if not dry:
                io.open(path, 'w', encoding='utf-8', newline='').write(
                    '\n'.join(out) + '\n')
            total += n
    print('\n%s %d rows' % ('WOULD FIX' if dry else 'FIXED', total))


if __name__ == '__main__':
    main()
