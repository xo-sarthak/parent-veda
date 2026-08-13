"""Worklist for every language ternary that still needs Hindi.

Built on tool/scan_lang_ternaries.py so it inherits all of what the earlier,
narrower scanners missed: local boolean flags, `isHinglish` polarity (Hindi in
the FIRST branch), and double-quoted literals.

Emits the CHARACTER span of whichever branch is the HINDI one - which is not
always the second. Getting that wrong would overwrite the English.

Columns: file | start char | end char | EMPTY | English | current Hindi-slot text

    python tool/extract_lang_ternaries.py <out.tsv>
"""

import glob
import io
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from scan_lang_ternaries import (conditions, DEV, LATIN, STR,   # noqa: E402
                                 SKIP_DIRS)


def main():
    out_path = sys.argv[1] if len(sys.argv) > 1 else 'tool/hindi/g_all.tsv'
    rows = []
    for path in glob.glob('lib/**/*.dart', recursive=True):
        path = path.replace(os.sep, '/')
        if any(d in path for d in SKIP_DIRS) or path.startswith('tool/'):
            continue
        # This file's own docstring contains an example ternary.
        if 'localization/app_language' in path:
            continue
        src = io.open(path, encoding='utf-8').read()
        conds = conditions(src)
        names = '|'.join(re.escape(n) for n in sorted(conds, key=len,
                                                      reverse=True))
        pat = re.compile(r'(?:[\w.]*\.)?(' + names + r')\s*\?\s*(' + STR +
                         r')\s*:\s*(' + STR + r')')
        for m in pat.finditer(src):
            cond = m.group(1)
            hindi_first = conds.get(cond, False)
            hi_grp, en_grp = (2, 3) if hindi_first else (3, 2)
            hi = m.group(hi_grp)[1:-1]
            en = m.group(en_grp)[1:-1]
            if hi != en and (DEV.search(hi) or not LATIN.search(hi)):
                continue                       # already translated
            rows.append((path, m.start(hi_grp) + 1, m.end(hi_grp) - 1, en, hi))

    with io.open(out_path, 'w', encoding='utf-8', newline='') as fh:
        for p, a, b, en, hi in rows:
            fh.write('%s\t%d\t%d\t\t%s\t%s\n'
                     % (p, a, b,
                        en.replace('\t', ' ').replace('\n', ' '),
                        hi.replace('\t', ' ').replace('\n', ' ')))
    print('%d rows -> %s' % (len(rows), out_path))
    by = {}
    for p, _a, _b, _e, _h in rows:
        by[p] = by.get(p, 0) + 1
    for p, n in sorted(by.items(), key=lambda x: -x[1]):
        print('  %-56s %3d' % (p, n))


if __name__ == '__main__':
    main()
