"""Apply ternary-branch translations, matching by CONTENT and writing atomically.

Two lessons from the first attempt, both worth keeping.

MATCH BY CONTENT, NOT BY STALE SPAN. The worklist was extracted, then other
edits landed in the same files, and every span after those edits shifted. The
applier refused - correctly - but the spans were now useless. Re-extracting
fresh spans and matching each to its translation by (file, english, hinglish)
survives any edit that does not change the strings themselves.

WRITE ALL FILES OR NONE. The first version validated globally and then wrote
file-by-file, so when it refused on the fifth file, four were already changed.
A refusal that leaves the tree half-applied is worse than no check at all: the
next run sees a mixture and cannot tell which half is which. Everything is
built in memory and flushed only once every file has been resolved.

    python tool/apply_ternary_hindi.py --dry
    python tool/apply_ternary_hindi.py
"""

import io
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from extract_ternary_hinglish import main as _extract   # noqa: E402,F401
from scan_ternary_pairs import TERNARY, DEV, LATIN, SKIP_DIRS   # noqa: E402

PH = re.compile(r'\$\{[^}]*\}|\$\w+')
BS = chr(92)
DONE = 'tool/hindi/t_all.done.tsv'
WORK = 'tool/hindi/t_all.tsv'


def load(path, cols):
    out = []
    for line in io.open(path, encoding='utf-8'):
        line = line.rstrip('\n').rstrip('\r')
        if not line:
            continue
        p = line.split('\t')
        if len(p) == cols:
            out.append(p)
    return out


def main():
    dry = '--dry' in sys.argv

    # translation keyed by what it REPLACES, not by where it was
    trans = {}
    work = {(p[0], int(p[1]), int(p[2])): (p[4], p[5]) for p in load(WORK, 6)}
    for p in load(DONE, 4):
        key = (p[0], int(p[1]), int(p[2]))
        if key not in work:
            print('unknown span in done file: %s' % (key,))
            return 1
        en, hi_old = work[key]
        trans[(p[0], en, hi_old)] = p[3]

    import glob
    pending = {}
    unresolved = []
    applied = 0
    for path in glob.glob('lib/**/*.dart', recursive=True):
        path = path.replace(os.sep, '/')
        if any(d in path for d in SKIP_DIRS) or path.startswith('tool/'):
            continue
        if 'localization/app_language' in path:
            continue
        src = io.open(path, encoding='utf-8').read()
        edits = []
        for m in TERNARY.finditer(src):
            en, hi = m.group(1)[1:-1], m.group(2)[1:-1]
            if en == hi or DEV.search(hi) or not LATIN.search(hi):
                continue
            new = trans.get((path, en, hi))
            if new is None:
                unresolved.append('%s  %r -> %r' % (path, en[:40], hi[:40]))
                continue
            if not DEV.search(new) or "'" in new or BS in new:
                unresolved.append('%s  bad translation %r' % (path, new[:50]))
                continue
            if sorted(PH.findall(new)) != sorted(PH.findall(en)):
                unresolved.append('%s  placeholder mismatch %r' % (path, en[:40]))
                continue
            edits.append((m.start(2) + 1, m.end(2) - 1, new))
        if edits:
            out = src
            for a, b, new in sorted(edits, reverse=True):
                out = out[:a] + new + out[b:]
            pending[path] = out
            applied += len(edits)

    if unresolved:
        print('REFUSING - %d unresolved, nothing written:' % len(unresolved))
        for u in unresolved[:20]:
            print('  ' + u)
        return 1

    for path, out in sorted(pending.items()):
        if not dry:
            io.open(path, 'w', encoding='utf-8', newline='\n').write(out)
        print('%-52s' % path)

    print('\n%s %d strings across %d files'
          % ('WOULD APPLY' if dry else 'APPLIED', applied, len(pending)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
