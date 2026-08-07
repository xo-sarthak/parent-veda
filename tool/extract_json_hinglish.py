"""Worklist of JSON {en, hi} pairs whose Hindi half is Latin-script Hinglish.

The father content is stored as JSON rather than Dart, so extract_hinglish -
which looks for `_t(` calls - cannot see it. Same job, different container.

Nothing is missing here either: every string already HAS a twin. The twin is
written in the style dropped on 2026-08-03, which also means the hi-IN voice
cannot read it.

Emits three columns: English, an empty cell for Devanagari, and the existing
Hinglish as a hint. A fourth column carries the JSON path so the applier can
put the answer back exactly where it came from - two different weeks can hold
the same English sentence, and keying on text alone would collapse them.

    python tool/extract_json_hinglish.py <out.tsv> <file.json>…
"""

import json
import re
import sys

DEV = re.compile('[ऀ-ॿ]')
LATIN = re.compile(r'[A-Za-z]{3}')


def walk(node, path, rows):
    if isinstance(node, dict):
        if set(node) == {'en', 'hi'} and isinstance(node.get('hi'), str):
            hi, en = node['hi'], node['en']
            if not DEV.search(hi) and LATIN.search(hi) and en != hi:
                rows.append((path, en, hi))
            return
        for k, v in node.items():
            walk(v, path + '/' + str(k), rows)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            walk(v, path + '/' + str(i), rows)


def main():
    out, files = sys.argv[1], sys.argv[2:]
    rows = []
    for f in files:
        walk(json.load(open(f, encoding='utf-8')), f, rows)
    with open(out, 'w', encoding='utf-8', newline='') as fh:
        for path, en, hi in rows:
            fh.write(en.replace('\n', '\\n') + '\t\t'
                     + hi.replace('\n', '\\n') + '\t'
                     + path + '\n')
    print(str(len(rows)) + ' Hinglish pairs across ' + str(len(files))
          + ' files -> ' + out)


if __name__ == '__main__':
    main()
