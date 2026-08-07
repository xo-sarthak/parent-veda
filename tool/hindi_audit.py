"""How much English in lib/data has NO Hindi twin?

Replaces a naive count that reported 2,529 strings "left" in a tree that was
essentially finished - because it counted the ENGLISH HALF of every bilingual
pair as outstanding English. The number to trust is: literals belonging to no
pair at all.

Four shapes count as covered:

    _t(en, hi)             a real translation
    _same(s)               identical in both by nature
    _en(s)                 English for now, Hindi owed - counted separately
    LocalizedText(en:, hi:)

A literal in none of them is plain String content whose model has not widened.

    python tool/hindi_audit.py
"""

import glob
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from apply_glossary import comment_spans, literal_runs, skip   # noqa: E402
from unwrap_t import calls                                     # noqa: E402

DEV = re.compile('[ऀ-ॿ]')
LT = re.compile(r"LocalizedText\(\s*en:\s*")
QUOTES = "'" + '"'
BACKSLASH = chr(92)


def localized_spans(src):
    """Spans of `LocalizedText(...)` constructor calls, paren-balanced."""
    out = []
    for m in LT.finditer(src):
        i, depth, quote = m.end(), 1, None
        while i < len(src) and depth:
            c = src[i]
            if quote:
                if c == BACKSLASH:
                    i += 2
                    continue
                if c == quote:
                    quote = None
            elif c in QUOTES:
                quote = c
            elif c == '(':
                depth += 1
            elif c == ')':
                depth -= 1
            i += 1
        out.append((m.start(), i))
    return out


def covered(src):
    spans = localized_spans(src)
    for marker in ('_t(', '_en(', '_same('):
        for start, end, args in calls(src, marker):
            if marker != '_t(' or len(args) == 2:
                spans.append((start, end))
    return spans


def hollow_pairs(src):
    """Pairs that HAVE a Hindi half which contains no Devanagari.

    The column this audit was missing, and the one that matters most. A pair
    is not finished because it exists: week5_full_data.dart carries 67 perfectly
    well-formed `_t(english, hinglish)` pairs whose second half is Latin-script
    Hinglish - the house style dropped on 2026-08-03. Every pair-counting audit
    called that file done, including this one until now.
    """
    n = 0
    for start, end, args in calls(src, '_t('):
        if len(args) != 2:
            continue
        hi = src[args[1][0]:args[1][1]]
        if not DEV.search(hi) and re.search(r'[A-Za-z]{3}', hi):
            n += 1
    return n


def main():
    files = sorted(glob.glob('lib/data/*.dart')) \
        + sorted(glob.glob('lib/data/father/*.dart'))
    rows = []
    for path in files:
        src = open(path, encoding='utf-8').read()
        spans = covered(src)
        loose = [t for s, e, t, _ in literal_runs(src, comment_spans(src))
                 if not skip(t)
                 and not any(a <= s and e <= b for a, b in spans)]
        owed = src.count('_en(') - (1 if '_en(String s)' in src else 0)
        hollow = hollow_pairs(src)
        if not loose and not owed and not hollow and not DEV.search(src):
            continue
        rows.append((os.path.basename(path)[:-5], len(loose), owed, hollow))

    print(f'{"file":<32}{"no twin":>9}{"_en()":>7}{"hollow pair":>13}')
    print('-' * 61)
    for name, loose, owed, hollow in sorted(rows,
                                            key=lambda r: -(r[1] + r[3])):
        if loose or owed or hollow:
            print(f'{name:<32}{loose:>9}{owed:>7}{hollow:>13}')
    print('-' * 61)
    print(f'{"TOTAL":<32}{sum(r[1] for r in rows):>9}'
          f'{sum(r[2] for r in rows):>7}{sum(r[3] for r in rows):>13}')


if __name__ == '__main__':
    main()
