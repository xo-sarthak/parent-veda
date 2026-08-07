"""Worklist of pairs whose Hindi half is still Latin-script Hinglish.

Different from extract_todo: nothing is MISSING here. Every string has a twin,
which is why every pair-counting audit called these files finished. The twin is
just written in the house style dropped on 2026-08-03 - and a Latin-script twin
also breaks voice, because the app asks the OS for the hi-IN voice and a Hindi
voice cannot read Roman script.

Column 1 is the ENGLISH (the stable key the applier will match on); column 2 is
left empty for real Devanagari. The existing Hinglish is written to a third
column as a hint for the translator - it already carries the intended meaning
and register, so it is worth reading, but it is not the answer.

    python tool/extract_hinglish.py <file.dart> <out.tsv>
"""

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from unwrap_t import calls   # noqa: E402

DEV = re.compile('[ऀ-ॿ]')
LATIN = re.compile(r'[A-Za-z]{3}')


def unquote(s):
    s = s.strip()
    parts = re.findall(r"(['\"])((?:\\.|(?!\1).)*?)\1", s)
    return ''.join(p[1] for p in parts)


def main():
    path, out = sys.argv[1], sys.argv[2]
    src = open(path, encoding='utf-8').read()
    rows = []
    for start, end, args in calls(src, '_t('):
        if len(args) != 2:
            continue
        en_raw = src[args[0][0]:args[0][1]]
        hi_raw = src[args[1][0]:args[1][1]]
        if DEV.search(hi_raw) or not LATIN.search(hi_raw):
            continue
        en, hi = unquote(en_raw), unquote(hi_raw)
        if en == hi:
            continue      # a deliberate Latin mirror, not Hinglish
        rows.append((en, hi))

    with open(out, 'w', encoding='utf-8', newline='') as f:
        for en, hi in rows:
            f.write(en.replace('\n', '\\n') + '\t\t'
                    + hi.replace('\n', '\\n') + '\n')
    print(f'{os.path.basename(path):<28} {len(rows):>4} Hinglish pairs -> {out}')


if __name__ == '__main__':
    main()
