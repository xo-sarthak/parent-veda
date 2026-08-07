"""Turn `_en('English')` markers into real `_t(en, hi)` pairs.

`_en()` means "English for now, Hindi owed" - a deliberate, greppable backlog
left when a shared model had to widen before its translations existed. This
retires them once the Hindi arrives.

Anything the table does not cover stays `_en()`, so the backlog count stays
honest rather than being quietly zeroed.

    python tool/fill_en_markers.py <file.dart> <table.tsv> [--dry]
"""

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from apply_glossary import literal, load, unescape   # noqa: E402

CALL = re.compile(r"_en\(\s*((?:(['\"])(?:\\.|(?!\2).)*?\2\s*)+)\)")
LIT = re.compile(r"(['\"])((?:\\.|(?!\1).)*?)\1")


def main():
    path, tsv = sys.argv[1], sys.argv[2]
    dry = '--dry' in sys.argv
    table = load(tsv)
    src = open(path, encoding='utf-8').read()

    filled, left = [], []

    def one(m):
        raw = m.group(1).strip()
        text = ''.join(unescape(p[1], p[0]) for p in LIT.findall(raw))
        hi = table.get(text)
        if hi is None:
            left.append(text)
            return m.group(0)
        filled.append(text)
        return '_t(' + raw + ', ' + literal(hi) + ')'

    out = CALL.sub(one, src)
    print(os.path.basename(path))
    print('  filled       : ' + str(len(filled)))
    print('  still owed   : ' + str(len(left)))
    if dry:
        print('  (dry run - nothing written)')
        return
    open(path, 'w', encoding='utf-8', newline='').write(out)


if __name__ == '__main__':
    main()
