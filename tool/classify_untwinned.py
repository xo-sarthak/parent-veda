"""Group untwinned String literals by the FIELD they sit in.

The audit reports ~731 literals in lib/data with no Hindi twin, and treats them
as one number. They are not one thing. Sampling found three different kinds:

    RENDERED   painted on screen, and English there is a bug. The Can I? popular
               chips carried `label: 'Pineapple'` while the entry they opened
               held LocalizedText(en: 'Pineapple', hi: 'अनानास') - so the chip
               said one thing and the page said another.
    READ       code matches on it: contains() keywords, search aliases, stage
               values, composed ids. Translating these BREAKS them, which is
               what tool/hindi/_never_translate.tsv exists to record.
    NEITHER    proper nouns, author names, a mother's own post text.

Guessing wrong is expensive in both directions, so this does not guess. It
groups by field name and prints one row per (file, field) with examples, which
turns 731 individual judgements into about thirty.

    python tool/classify_untwinned.py
"""

import collections
import glob
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from apply_glossary import comment_spans, literal_runs, skip   # noqa: E402
from hindi_audit import covered                                # noqa: E402

FIELD = re.compile(r'(\w+)\s*:\s*$')


def field_for(src, start):
    """The `name:` this literal is assigned to, if any."""
    line_start = src.rfind('\n', 0, start) + 1
    before = src[line_start:start]
    m = FIELD.search(before.rstrip())
    if m:
        return m.group(1)
    # Inside a list: walk back for the nearest `name: [`
    chunk = src[max(0, start - 400):start]
    ms = re.findall(r'(\w+)\s*:\s*(?:const\s*)?\[', chunk)
    return ms[-1] if ms else '?'


def main():
    groups = collections.defaultdict(list)
    for path in sorted(glob.glob('lib/data/*.dart')) + \
            sorted(glob.glob('lib/data/father/*.dart')):
        src = open(path, encoding='utf-8').read()
        spans = covered(src)
        for s, e, text, _q in literal_runs(src, comment_spans(src)):
            if skip(text):
                continue
            if any(a <= s and e <= b for a, b in spans):
                continue
            groups[(os.path.basename(path)[:-5], field_for(src, s))].append(text)

    rows = sorted(groups.items(), key=lambda kv: -len(kv[1]))
    total = sum(len(v) for v in groups.values())
    print('%-26s %-18s %5s  examples' % ('file', 'field', 'n'))
    print('-' * 104)
    for (f, field), texts in rows:
        ex = ' | '.join(t[:26] for t in texts[:3])
        print('%-26s %-18s %5d  %s' % (f, field, len(texts), ex))
    print('-' * 104)
    print('%d literals in %d (file, field) groups' % (total, len(rows)))


if __name__ == '__main__':
    main()
