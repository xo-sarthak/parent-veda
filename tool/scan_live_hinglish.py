"""Latin-script Hinglish still LIVE anywhere in lib/, not just lib/data.

tool/hindi_audit.py globs lib/data/*.dart plus the JSON bodies, and that is
where the content lives - but not where all of it lives. `_module()` in
lib/models/father_day_derive.dart returns the eyebrow on the father's Learn
card as `LocalizedText(en: 'BECOMING A FATHER', hi: 'PITA BANNE KI SHURUAAT')`,
Latin-script Hinglish, shipping today, and no audit in this repo looked at
lib/models at all.

That is the same failure as the lib/data/home miss, one directory over: the
tool inspected where the content was assumed to be rather than where it is.

Scope: lib/**, excluding post_pregnancy and ttc - CLAUDE.md is explicit that
only the Pregnancy stage is being migrated and the others hold Hinglish on
purpose.

    python tool/scan_live_hinglish.py
"""

import collections
import glob
import io
import os
import re

DEV = re.compile('[ऀ-ॿ]')
LATIN = re.compile(r'[A-Za-z]{3}')
Q = "'"
BS = chr(92)

# LocalizedText(en: '...', hi: '...') and _t('...', '...') - both halves quoted
# with single quotes, escapes allowed inside.
STR = "'(?:[^'" + BS + BS + "]|" + BS + BS + ".)*'"
PAIR = re.compile(
    r"(?:LocalizedText\(\s*en:\s*|_t\(\s*)(" + STR + r")\s*,\s*(?:hi:\s*)?(" +
    STR + r")")

SKIP_DIRS = ('/post_pregnancy/', '/ttc/')

# A `hi` half made only of Dart interpolation is already correct - it just looks
# Latin. `'${m.facts[1].big.hi} · ${m.facts[1].small.hi}'` reads every field
# from the Hindi side; there is nothing left to translate. Counting it as debt
# means the audit can never reach zero, and an audit that cannot reach zero
# stops being read.
INTERP = re.compile(r'\$\{[^}]*\}|\$\w+')


def is_interpolation_only(s):
    return not LATIN.search(INTERP.sub(' ', s))


def main():
    rows = collections.Counter()
    examples = {}
    for path in glob.glob('lib/**/*.dart', recursive=True):
        path = path.replace(os.sep, '/')
        if any(d in path for d in SKIP_DIRS):
            continue
        src = io.open(path, encoding='utf-8').read()
        for en, hi in PAIR.findall(src):
            en, hi = en[1:-1], hi[1:-1]
            if en == hi or not hi.strip():
                continue
            if is_interpolation_only(hi):
                continue
            if not DEV.search(hi) and LATIN.search(hi):
                rows[path] += 1
                examples.setdefault(path, []).append((en, hi))

    if not rows:
        print('clean - no Latin-script Hinglish left live in lib/')
        return
    print('%-46s %5s  example' % ('file', 'n'))
    print('-' * 100)
    for path, n in rows.most_common():
        en, hi = examples[path][0]
        print('%-46s %5d  %s -> %s' % (path, n, en[:24], hi[:30]))
    print('-' * 100)
    print('TOTAL still live: %d' % sum(rows.values()))


if __name__ == '__main__':
    main()
