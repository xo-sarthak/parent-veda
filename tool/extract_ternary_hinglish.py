"""Worklist of the Latin-script Hinglish hiding in `isEnglish ? en : hi` ternaries.

See tool/scan_ternary_pairs.py for how these went unseen: every audit in this
repo looks for `_t(...)` or `LocalizedText(en:, hi:)`, and this is a third
shape that predates both.

Emits CHARACTER spans of the HINDI branch only - offsets into the decoded
string, not bytes. The English branch is never touched, which is the constraint
on this whole migration.

Columns: file | start char | end char | EMPTY (new Devanagari) | English | current Hinglish

    python tool/extract_ternary_hinglish.py <out.tsv>
"""

import glob
import io
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from scan_ternary_pairs import TERNARY, DEV, LATIN, SKIP_DIRS   # noqa: E402


def main():
    out_path = sys.argv[1] if len(sys.argv) > 1 else 'tool/hindi/t_all.tsv'
    rows = []
    for path in glob.glob('lib/**/*.dart', recursive=True):
        path = path.replace(os.sep, '/')
        if any(d in path for d in SKIP_DIRS):
            continue
        # The scanner's own docstring contains an example ternary. Skipping the
        # tools stops the worklist from offering a comment as work.
        if path.startswith('tool/') or 'localization/app_language' in path:
            continue
        src = io.open(path, encoding='utf-8').read()
        for m in TERNARY.finditer(src):
            en, hi = m.group(1)[1:-1], m.group(2)[1:-1]
            if en == hi:
                continue                      # identical: a wiring fix, not a translation
            if DEV.search(hi) or not LATIN.search(hi):
                continue
            rows.append((path, m.start(2) + 1, m.end(2) - 1, en, hi))

    with io.open(out_path, 'w', encoding='utf-8', newline='') as fh:
        for p, a, b, en, hi in rows:
            fh.write('%s\t%d\t%d\t\t%s\t%s\n'
                     % (p, a, b, en.replace('\t', ' '), hi.replace('\t', ' ')))
    print('%d rows -> %s' % (len(rows), out_path))
    by = {}
    for p, _a, _b, _e, _h in rows:
        by[p] = by.get(p, 0) + 1
    for p, n in sorted(by.items(), key=lambda x: -x[1]):
        print('  %-52s %3d' % (p, n))


if __name__ == '__main__':
    main()
