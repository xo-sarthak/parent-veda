"""Dump `_p(en, hi)` call sites as TSV for translation.

    python tool/dump_ui_strings.py <file> [start_line] [end_line]

Columns: idx, flag, english, current_hi
`flag` is `.` for a mechanically rewritable call and `HAND` for one whose
argument is a ternary or a concatenation — those get translated in the editor,
not through the applier.
"""

import sys
from ui_strings import find_calls

path = sys.argv[1]
lo = int(sys.argv[2]) if len(sys.argv) > 2 else 0
hi = int(sys.argv[3]) if len(sys.argv) > 3 else 10 ** 9

src = open(path, encoding='utf-8').read()
line_of = [0]
for ch in src:
    line_of.append(line_of[-1] + (1 if ch == '\n' else 0))

shown = 0
for c in find_calls(src):
    ln = line_of[c['en_span'][0]] + 1
    if not (lo <= ln <= hi):
        continue
    shown += 1
    if c['simple']:
        print(f"{c['idx']}\t.\t{c['text_en']}\t{c['text_hi']}")
    else:
        en = c['en_src'].replace('\n', ' ⏎ ')
        h = c['hi_src'].replace('\n', ' ⏎ ')
        print(f"{c['idx']}\tHAND\t{en}\t{h}")

print(f'\n# {shown} calls in lines {lo}..{hi}', file=sys.stderr)
