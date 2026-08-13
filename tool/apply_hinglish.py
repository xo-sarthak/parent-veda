"""Write the translations from tool/hinglish.py's worklist back into Dart.

TWO SPAN SHAPES, and getting them confused breaks the build in 320 places.

`tool/hinglish.py` emits the span of the Hindi BRANCH. For most shapes that
branch is a string EXPRESSION and the span therefore includes the surrounding
quotes - and, where Dart concatenated adjacent literals, several sets of them:

    _p('one ' 'two', 'ek ' 'do')
                     ^^^^^^^^^^^  one span, two literals, four quote marks

For a list branch the span is a single literal's INTERIOR, quotes excluded,
because the branch itself is `[...]` and the individual items are what needs
translating.

The translators returned bare text either way, which is right - they should not
be writing Dart syntax. So the applier decides: if the span starts with a quote
it emits `'<hindi>'`, collapsing any concatenation into one literal; otherwise
it drops the text in bare.

Everything else follows the discipline the earlier appliers arrived at:
re-extract fresh spans rather than trusting stale ones, validate the whole set
before touching anything, apply descending within each file, and write all files
or none.

    python tool/apply_hinglish.py --dry
    python tool/apply_hinglish.py
"""

import glob
import io
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from dart_placeholders import parity                       # noqa: E402
from hinglish import (findings_for, DEV, SKIP_DIRS,        # noqa: E402
                      SKIP_FILES, READ_NOT_RENDERED)

BS = chr(92)


def load_done():
    """(file, english, hinglish) -> hindi, keyed by CONTENT not position."""
    src = {}
    for line in io.open('tool/hindi/x_all.tsv', encoding='utf-8'):
        line = line.rstrip('\n')
        if not line:
            continue
        p = line.split('\t')
        src[(p[0], int(p[1]), int(p[2]))] = (p[4], p[5])

    out = {}
    for path in sorted(glob.glob('tool/hindi/x*.done.tsv')):
        for line in io.open(path, encoding='utf-8'):
            line = line.rstrip('\n')
            if not line:
                continue
            p = line.split('\t')
            if len(p) != 4:
                raise SystemExit('%s: expected 4 columns, got %d' %
                                 (path, len(p)))
            key = (p[0], int(p[1]), int(p[2]))
            if key not in src:
                raise SystemExit('%s: unknown span %s' % (path, key))
            en, hi = src[key]
            out[(p[0], en, hi)] = p[3]
    return out


def main():
    dry = '--dry' in sys.argv
    trans = load_done()

    pending, problems, applied = {}, [], 0
    unresolved = 0
    for path in glob.glob('lib/**/*.dart', recursive=True):
        path = path.replace(os.sep, '/')
        if any(d in path for d in SKIP_DIRS):
            continue
        if os.path.basename(path) in SKIP_FILES:
            continue
        src = io.open(path, encoding='utf-8').read()
        edits = []
        for _shape, a, b, en, hi in findings_for(path, src):
            if READ_NOT_RENDERED.search(src[max(0, a - 400):a]):
                continue
            new = trans.get((path, en, hi))
            if new is None:
                unresolved += 1
                if unresolved <= 8:
                    problems.append('%s: no translation for %r' % (path, hi[:44]))
                continue
            if not DEV.search(new):
                problems.append('%s: no Devanagari in %r' % (path, new[:44]))
                continue
            if "'" in new or '"' in new:
                problems.append('%s: quote would break the literal: %r'
                                % (path, new[:44]))
                continue
            if not parity(en, new) and en:
                problems.append('%s: placeholders %r vs %r'
                                % (path, en[:34], new[:34]))
                continue
            raw = src[a:b]
            quoted = raw[:1] in ("'", '"')
            edits.append((a, b, ("'" + new + "'") if quoted else new))
        if edits:
            out = src
            for a, b, new in sorted(edits, reverse=True):
                out = out[:a] + new + out[b:]
            pending[path] = out
            applied += len(edits)

    if problems:
        print('REFUSING - %d problem(s), nothing written:' % len(problems))
        for p in problems[:25]:
            print('  ' + p)
        if unresolved > 8:
            print('  ... %d spans total had no translation' % unresolved)
        return 1

    for path, out in sorted(pending.items()):
        if not dry:
            io.open(path, 'w', encoding='utf-8', newline='\n').write(out)
        print('%-56s' % path)
    print('\n%s %d strings across %d files'
          % ('WOULD APPLY' if dry else 'APPLIED', applied, len(pending)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
