"""Write the de-gendered Hindi back into weekContent.json, by JSON path.

Validates before it writes, because this rewrites the baby's own voice across
37 weeks and a bad row is a sentence a mother hears her child say.

Checks, all fatal:
  - the path resolves and currently holds an {en, hi} pair
  - the new Hindi contains no first-person gender marker, in EITHER direction
    (swapping masculine for feminine is the same bug pointed the other way)
  - placeholder sets match the text being replaced
  - the new Hindi is not empty and is actually Devanagari

    python tool/apply_degendered.py <table.tsv> [--dry]
"""

import json
import re
import sys

DOC = 'lib/data/weekContent.json'
DEV = re.compile('[ऀ-ॿ]')
PLACEHOLDER = re.compile(r'\$\{[^}]*\}|\$\w+')

# First person + gendered participle, both directions.
GENDERED = re.compile(
    r'(?:ता|ती|रहा|रही|गया|गई|हुआ|हुई|चुका|चुकी|वाला|वाली)\s+हूँ'
    r'|ूँगा|ूँगी')


def main():
    tsv = sys.argv[1]
    dry = '--dry' in sys.argv
    doc = json.load(open(DOC, encoding='utf-8'))

    # week number -> block, so a path like week20.a.b can be walked.
    by_week = {str(b.get('week')): b for b in doc}

    rows, problems, applied = [], [], 0
    for line in open(tsv, encoding='utf-8'):
        line = line.rstrip('\n')
        if not line.strip() or line.startswith('#'):
            continue
        cols = line.split('\t')
        if len(cols) < 4:
            problems.append('malformed row: ' + line[:60])
            continue
        rows.append(cols)

    for path, new_hi, _en, old_hi in rows:
        if not new_hi.strip():
            problems.append(path + ': empty replacement')
            continue
        if not DEV.search(new_hi):
            problems.append(path + ': no Devanagari')
            continue
        if GENDERED.search(new_hi):
            problems.append(path + ': STILL GENDERED -> '
                            + GENDERED.search(new_hi).group(0))
            continue
        if set(PLACEHOLDER.findall(new_hi)) != set(PLACEHOLDER.findall(old_hi)):
            problems.append(path + ': placeholder drift')
            continue

        parts = path.split('.')
        node = by_week.get(parts[0].replace('week', ''))
        if node is None:
            problems.append(path + ': no such week')
            continue
        for key in parts[1:]:
            if isinstance(node, list):
                node = node[int(key)]
            elif isinstance(node, dict) and key in node:
                node = node[key]
            else:
                node = None
                break
        if not isinstance(node, dict) or 'hi' not in node:
            problems.append(path + ': path does not resolve to an {en,hi} pair')
            continue
        node['hi'] = new_hi
        applied += 1

    print('rows: ' + str(len(rows)) + '   applied: ' + str(applied)
          + '   problems: ' + str(len(problems)))
    for p in problems[:12]:
        print('   ' + p)
    if problems:
        sys.exit('nothing written - fix the rows above')

    if dry:
        print('(dry run - nothing written)')
        return
    with open(DOC, 'w', encoding='utf-8', newline='') as f:
        json.dump(doc, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print('written: ' + DOC)


if __name__ == '__main__':
    main()
