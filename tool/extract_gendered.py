"""Worklist of baby-voice passages that commit to the baby's sex.

Hindi first-person verbs must agree in gender: `सकता हूँ` is masculine,
`सकती हूँ` feminine. There is no neutral form, so a literal translation of the
baby's English voice - which is genderless - has to pick one, and
weekContent.json picked masculine 80 times.

That is against this product's own rule, and it is the same principle behind
the PCPNDT fix: the app must never state or imply a baby's sex. It reads badly
and it is about to be SPOKEN, which makes it land harder.

Only weekContent.json is affected in any volume: it was migrated before the
gender-neutrality instruction existed. Every body translated afterwards is
clean.

Emits: JSON path, English (the genderless source of truth), current Hindi.

    python tool/extract_gendered.py <out.tsv>
"""

import json
import re
import sys

MASC = re.compile(r'(सकता हूँ|रहा हूँ|गया हूँ|करता हूँ|लगता हूँ|पाता हूँ'
                  r'|हुआ हूँ|चुका हूँ|सकता हूं|रहा हूं)')


def main():
    out_path = sys.argv[1]
    doc = json.load(open('lib/data/weekContent.json', encoding='utf-8'))
    rows = []

    def walk(node, path):
        if isinstance(node, dict):
            if set(node) == {'en', 'hi'}:
                if MASC.search(node['hi']):
                    rows.append((path, node['en'], node['hi']))
                return
            for k, v in node.items():
                walk(v, path + '.' + str(k))
        elif isinstance(node, list):
            for i, v in enumerate(node):
                walk(v, path + '.' + str(i))

    for block in doc:
        walk(block, 'week' + str(block.get('week')))

    with open(out_path, 'w', encoding='utf-8', newline='') as f:
        for path, en, hi in rows:
            f.write(path + '\t\t'
                    + en.replace('\n', '\\n') + '\t'
                    + hi.replace('\n', '\\n') + '\n')
    print(str(len(rows)) + ' gendered passages -> ' + out_path)
    print('columns: path | EMPTY (new Hindi) | English | current Hindi')


if __name__ == '__main__':
    main()
