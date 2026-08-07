"""Fill parallel `xHi` fields rather than wrapping in `_t(en, hi)`.

A third bilingual shape lives in this codebase. week_articles_data.dart does
not use LocalizedText at all - it carries `title` beside `titleHi` and `body`
beside `bodyHi`, with the Hi fields optional and currently unset.

apply_glossary is wrong here and fails loudly: wrapping `title:` produces a
LocalizedText where a String is declared. The fix is to ADD the sibling field,
not to change the type - a smaller change that leaves the model alone.

    python tool/fill_parallel_hi.py <file.dart> <table.tsv> <field>[,<field>…]
"""

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from apply_glossary import literal, load, unescape   # noqa: E402

LIT = r"(?:'(?:\\.|[^'])*'|\"(?:\\.|[^\"])*\")"
INNER = re.compile(r"(['\"])((?:\\.|(?!\1).)*?)\1")


def main():
    path, tsv, fields = sys.argv[1], sys.argv[2], sys.argv[3].split(',')
    dry = '--dry' in sys.argv
    table = load(tsv)
    src = open(path, encoding='utf-8').read()
    added, missing = 0, 0

    for field in fields:
        sibling = field + 'Hi'
        pattern = re.compile(
            r"(\b" + field + r"):\s*(" + LIT + r"(?:\s*" + LIT + r")*)(,)")

        def one(m):
            nonlocal added, missing
            raw = m.group(2)
            text = ''.join(unescape(p[1], p[0]) for p in INNER.findall(raw))
            hi = table.get(text)
            if hi is None:
                missing += 1
                return m.group(0)
            added += 1
            # The sibling goes straight after, so the pair reads together and a
            # missing translation is visible at a glance rather than by grep.
            return (m.group(1) + ': ' + raw + ',\n    ' + sibling + ': '
                    + literal(hi) + ',')

        src = pattern.sub(one, src)

    print(os.path.basename(path))
    print('  Hi fields added : ' + str(added))
    print('  no translation  : ' + str(missing))
    if dry:
        print('  (dry run - nothing written)')
        return
    open(path, 'w', encoding='utf-8', newline='').write(src)


if __name__ == '__main__':
    main()
