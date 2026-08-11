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


# JSON content bodies. Backups are listed so they are visibly EXCLUDED rather
# than silently missed - weekContent.hinglish.json is the kept-verbatim
# pre-migration copy ("comment out, never delete") and is Hinglish on purpose.
JSON_GLOBS = ['lib/data/*.json', 'lib/data/home/*.json',
              'lib/data/father/*.json']
JSON_SKIP = ('weekContent.hinglish.json', 'weekContent_week5_original.json')


def json_bodies():
    """(path, pairs, devanagari, hinglish) per JSON content file.

    This audit reported the app clean while lib/data/home/ - 37 files and 5,095
    Hinglish pairs, the largest single body in the product - sat untouched,
    because the file list was `lib/data/*.dart` plus weekContent.json and
    nothing else.

    A tool that only inspects where you remembered to look will always tell you
    that you are finished.
    """
    import json as _json
    dev_re = re.compile('[ऀ-ॿ]')
    lat_re = re.compile(r'[A-Za-z]{3}')
    rows = []
    for pattern in JSON_GLOBS:
        for path in sorted(glob.glob(pattern)):
            if os.path.basename(path) in JSON_SKIP:
                continue
            counts = [0, 0, 0]

            def walk(node):
                if isinstance(node, dict):
                    if 'en' in node and len(node) <= 2:
                        counts[0] += 1
                        hi = str(node.get('hi', ''))
                        if dev_re.search(hi):
                            counts[1] += 1
                        elif lat_re.search(hi) and hi != node['en']:
                            counts[2] += 1
                        return
                    for v in node.values():
                        walk(v)
                elif isinstance(node, list):
                    for v in node:
                        walk(v)

            try:
                walk(_json.load(open(path, encoding='utf-8')))
            except Exception:
                continue
            if counts[0]:
                rows.append((path, counts[0], counts[1], counts[2]))
    return rows


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
        # Count `_en(` in CODE only. A plain src.count() also counts the token
        # inside doc comments, and the `_same` helper's own docstring explains
        # itself by naming `_en()` - so adding that comment to seven files made
        # the backlog appear to grow by seven while nothing changed. An audit
        # that miscounts in the direction of "more work than there is" gets
        # ignored just as fast as one that undercounts.
        cspans = comment_spans(src)
        owed = sum(1 for m in re.finditer(r'\b_en\(', src)
                   if not any(a <= m.start() < b for a, b in cspans)) \
            - (1 if '_en(String s)' in src else 0)
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
    print(f'{"TOTAL (dart)":<32}{sum(r[1] for r in rows):>9}'
          f'{sum(r[2] for r in rows):>7}{sum(r[3] for r in rows):>13}')

    # Dart OUTSIDE lib/data. This audit has now been wrong twice in the same
    # way: it reported the app clean while lib/data/home held 5,095 Hinglish
    # pairs, and again while lib/screens/week_flow_screen.dart held 173. Both
    # times the tool was correct about everywhere it looked.
    try:
        from scan_live_hinglish import PAIR, DEV as SDEV, LATIN as SLAT
        import glob as _g
        live = {}
        for p in _g.glob('lib/**/*.dart', recursive=True):
            p = p.replace(os.sep, '/')
            if '/post_pregnancy/' in p or '/ttc/' in p or p.startswith('lib/data/'):
                continue
            s = open(p, encoding='utf-8').read()
            n = sum(1 for a, b in PAIR.findall(s)
                    if a[1:-1] != b[1:-1] and b[1:-1].strip()
                    and not SDEV.search(b) and SLAT.search(b))
            if n:
                live[p] = n
        if live:
            print()
            print(f'{"Dart outside lib/data":<48}{"hinglish":>10}')
            print('-' * 61)
            for p, n in sorted(live.items(), key=lambda x: -x[1]):
                print(f'{p:<48}{n:>10}')
            print('-' * 61)
            print(f'{"TOTAL still live":<48}{sum(live.values()):>10}')
    except Exception as e:                       # never let the audit die here
        print('\n(dart-outside-lib/data scan unavailable: %s)' % e)

    jrows = [r for r in json_bodies() if r[3]]
    if jrows:
        print()
        print(f'{"JSON body":<40}{"pairs":>8}{"hinglish":>10}')
        print('-' * 61)
        by_dir = {}
        for path, pairs, _dev, hing in jrows:
            d = os.path.dirname(path)
            a = by_dir.setdefault(d, [0, 0])
            a[0] += pairs
            a[1] += hing
        for d, (pairs, hing) in sorted(by_dir.items(), key=lambda x: -x[1][1]):
            print(f'{d:<40}{pairs:>8}{hing:>10}')
        print('-' * 61)
        print(f'{"TOTAL Hinglish still in JSON":<40}'
              f'{"":>8}{sum(a[1] for a in by_dir.values()):>10}')


if __name__ == '__main__':
    main()
