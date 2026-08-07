"""Write a worklist TSV of everything in a data file that still needs Hindi.

Two kinds of outstanding string, and they need different handling downstream:

  loose   a literal belonging to no bilingual pair - the model has not widened
  _en()   already wrapped, marked English-for-now, second half owed

Both go into one TSV so a translator sees one job. The applier knows which is
which from the source, not from this file.

    python tool/extract_todo.py <file.dart> <out.tsv>
"""

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from apply_glossary import comment_spans, literal_runs, skip   # noqa: E402
from hindi_audit import covered                                # noqa: E402

EN_CALL = re.compile(r"_en\(\s*((?:(['\"])(?:\\.|(?!\2).)*?\2\s*)+)\)")
LIT = re.compile(r"(['\"])((?:\\.|(?!\1).)*?)\1")


def main():
    path, out = sys.argv[1], sys.argv[2]
    src = open(path, encoding='utf-8').read()
    spans = covered(src)

    rows = []
    for s, e, text, _raw in literal_runs(src, comment_spans(src)):
        if skip(text):
            continue
        if any(a <= s and e <= b for a, b in spans):
            continue
        rows.append(text)

    for m in EN_CALL.finditer(src):
        parts = LIT.findall(m.group(1))
        text = ''.join(p[1] for p in parts)
        if text and text not in rows:
            rows.append(text)

    seen, uniq = set(), []
    for r in rows:
        if r in seen:
            continue
        seen.add(r)
        uniq.append(r)

    with open(out, 'w', encoding='utf-8', newline='') as f:
        for r in uniq:
            f.write(r.replace('\n', '\\n') + '\t\n')
    print(f'{os.path.basename(path):<30} {len(uniq):>5} rows -> {out}')


if __name__ == '__main__':
    main()
