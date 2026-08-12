"""How many "untwinned" literals actually have a Hindi sibling nearby?

hindi_audit.py recognises four shapes as covered:

    _t(en, hi)   _same(s)   _en(s)   LocalizedText(en:, hi:)

and counts everything else as having no Hindi twin. But the repo pairs
languages in at least two other shapes it was never taught:

    _Word(0.0, 'Forming', 'बनना शुरू')     positional constructor
    title: '...', titleHi: 'आप आधे रास्ते'  sibling field

Both are fully translated. Both were reported as outstanding - 43 strings
between them. The number the audit prints is therefore an upper bound, not a
worklist, and treating it as a worklist means re-translating finished content.

This is the same failure as every other one in this migration: the tool is
correct about the shapes it knows, and silent about the rest.

Rather than teach the audit every constructor in the codebase, this asks a
shape-independent question: is there a Devanagari literal within [WINDOW]
characters of this English one? That is not proof - it is a strong enough
signal to separate "probably already paired, go look" from "genuinely bare".

    python tool/pairing_shapes.py
"""

import collections
import glob
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from apply_glossary import comment_spans, literal_runs, skip   # noqa: E402
from hindi_audit import covered                                # noqa: E402

DEV = re.compile('[ऀ-ॿ]')

# Wide enough to cross a `title: '...',\n    titleHi: '...'` pair, tight enough
# not to catch an unrelated Hindi string two entries down.
WINDOW = 220


def main():
    paired = collections.Counter()
    bare = collections.Counter()
    bare_ex = {}
    for path in sorted(glob.glob('lib/data/*.dart')) + \
            sorted(glob.glob('lib/data/father/*.dart')):
        src = open(path, encoding='utf-8').read()
        spans = covered(src)
        name = os.path.basename(path)[:-5]
        for s, e, text, _q in literal_runs(src, comment_spans(src)):
            if skip(text) or any(a <= s and e <= b for a, b in spans):
                continue
            near = src[max(0, s - WINDOW):min(len(src), e + WINDOW)]
            if DEV.search(near):
                paired[name] += 1
            else:
                bare[name] += 1
                bare_ex.setdefault(name, []).append(text)

    print('%-28s %10s %8s' % ('file', 'has Hindi', 'bare'))
    print('%-28s %10s %8s' % ('', 'nearby', ''))
    print('-' * 50)
    for name in sorted(set(paired) | set(bare),
                       key=lambda n: -(bare[n])):
        print('%-28s %10d %8d' % (name, paired[name], bare[name]))
    print('-' * 50)
    print('%-28s %10d %8d' % ('TOTAL', sum(paired.values()), sum(bare.values())))
    print()
    print('"has Hindi nearby" = almost certainly already paired in a shape the')
    print('audit does not parse. Verify before treating any of it as work.')
    print()
    for name, ex in list(bare_ex.items())[:6]:
        print('  bare in %-22s %s' % (name, ' | '.join(x[:22] for x in ex[:4])))


if __name__ == '__main__':
    main()
