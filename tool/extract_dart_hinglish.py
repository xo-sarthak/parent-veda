"""Worklist of Latin-script Hinglish in Dart call sites outside lib/data.

Found by tool/scan_live_hinglish.py: 255 strings across week_flow_screen,
pv_video, bump_book_screen, father_day_derive and two week_card widgets - all
pregnancy-side, all shipping, none ever covered by an audit here.

Emits CHARACTER spans (offsets into the decoded string, NOT bytes -
Devanagari is multi-byte and slicing raw bytes lands mid-glyph), not text to
search for. The applier writes back by span, so
a string that appears twice with different context cannot be replaced in the
wrong place, and a translation containing regex-special characters cannot
corrupt the substitution. Editing Dart by search-and-replace is how this repo
once lost 96 `_t(...)` calls to a `return ;`.

Columns: file | start char | end char | EMPTY (new Devanagari) | English | current Hinglish

    python tool/extract_dart_hinglish.py <out.tsv>
"""

import glob
import io
import os
import re
import sys

DEV = re.compile('[ऀ-ॿ]')
LATIN = re.compile(r'[A-Za-z]{3}')
BS = chr(92)
STR = "'(?:[^'" + BS + BS + "]|" + BS + BS + ".)*'"
PAIR = re.compile(
    r"(?:LocalizedText\(\s*en:\s*|_t\(\s*)(" + STR + r")\s*,\s*(?:hi:\s*)?(" +
    STR + r")")

SKIP_DIRS = ('/post_pregnancy/', '/ttc/')

# A `hi` half that is pure Dart interpolation is not copy - `${m.facts[1].big.hi}`
# is already correct, it just looks Latin. Skip anything with no literal words
# of its own outside the ${...} braces.
INTERP = re.compile(r'\$\{[^}]*\}|\$\w+')


def is_interpolation_only(s):
    return not LATIN.search(INTERP.sub(' ', s))


def rows():
    out = []
    for path in glob.glob('lib/**/*.dart', recursive=True):
        path = path.replace(os.sep, '/')
        if any(d in path for d in SKIP_DIRS):
            continue
        src = io.open(path, encoding='utf-8').read()
        for m in PAIR.finditer(src):
            en, hi = m.group(1)[1:-1], m.group(2)[1:-1]
            if en == hi or not hi.strip():
                continue
            if DEV.search(hi) or not LATIN.search(hi):
                continue
            if is_interpolation_only(hi):
                continue
            out.append((path, m.start(2) + 1, m.end(2) - 1, en, hi))
    return out


def main():
    out_path = sys.argv[1] if len(sys.argv) > 1 else 'tool/hindi/d_all.tsv'
    rs = rows()
    with io.open(out_path, 'w', encoding='utf-8', newline='') as fh:
        for path, a, b, en, hi in rs:
            fh.write('%s\t%d\t%d\t\t%s\t%s\n'
                     % (path, a, b,
                        en.replace('\t', ' '), hi.replace('\t', ' ')))
    print('%d rows -> %s' % (len(rs), out_path))
    by = {}
    for path, _a, _b, _en, _hi in rs:
        by[path] = by.get(path, 0) + 1
    for p, n in sorted(by.items(), key=lambda x: -x[1]):
        print('  %-48s %4d' % (p, n))


if __name__ == '__main__':
    main()
