"""Merge the garbh leftovers into g_garbh.tsv, and prove the result matches.

Deliberately a FILE, not a shell heredoc. The first attempt at this ran through
`bash -c` with a quoted heredoc, and the backslashes did not survive: a step
meant to turn a doubled escape into a single one wrote REAL newlines into the
cells instead, which splits a row in half and silently loses translations. Any
script whose job is escaping should not itself be passed through a shell.
"""

import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from apply_glossary import (LITERAL, comment_spans, in_any, load,   # noqa: E402
                            unescape, untranslated)

DART = 'lib/data/garbh_data.dart'
GLOSS = 'tool/hindi/g_garbh.tsv'
TODO = 'tool/hindi/_todo_garbh.tsv'

# Interpolated into a hint that is lowercased and matched against ENGLISH
# keywords ('evening', 'sleep', 'night'…) in ragaTimeBadge(). Translating it
# would not fail to compile once the fields widen - it would silently badge
# every raga 'Morning' in Hindi. Never convert it.
INTERP = '${a.id} ${a.title} ${a.subtitle}'

DOUBLED = '\\' + '\\' + 'n'      # backslash backslash n, as it sits in the file
SINGLE = '\\' + 'n'              # backslash n


def source_literals(path):
    """Every literal in the file that is real code, not comment prose."""
    src = open(path, encoding='utf-8').read()
    spans = comment_spans(src)
    return {unescape(m.group(2), m.group(1))
            for m in LITERAL.finditer(src) if not in_any(m.start(), spans)}


def read(path):
    rows = []
    for line in open(path, encoding='utf-8'):
        line = line.rstrip('\n')
        if not line.strip() or line.startswith('#'):
            continue
        en, _, hi = line.partition('\t')
        rows.append([en.strip(), hi.strip()])
    return rows


def main():
    # The on-disk glossary was damaged by the shell-escaping mishap above, so
    # take the committed copy as the base rather than trusting the file.
    base = subprocess.run(['git', 'show', 'HEAD:' + GLOSS],
                          capture_output=True, text=True, encoding='utf-8')
    if base.returncode != 0:
        sys.exit('could not read the committed glossary: ' + base.stderr)
    committed = []
    for line in base.stdout.split('\n'):
        if not line.strip() or line.startswith('#'):
            continue
        en, _, hi = line.partition('\t')
        committed.append([en.strip(), hi.strip()])

    todo = read(TODO)
    # The agent wrote its newlines doubled. Collapse BOTH columns by the same
    # rule so the pair stays consistent, and count it so the fix is visible.
    collapsed = 0
    for r in todo:
        if DOUBLED in r[0] or DOUBLED in r[1]:
            r[0] = r[0].replace(DOUBLED, SINGLE)
            r[1] = r[1].replace(DOUBLED, SINGLE)
            collapsed += 1

    present = source_literals(DART)
    kept, seen, dropped = [], set(), []
    for en, hi in committed + todo:
        if en == INTERP:
            dropped.append(('ragaTimeBadge interpolation', en))
            continue
        if en.replace(SINGLE, '\n') not in present:
            dropped.append(('no matching literal in the file', en))
            continue
        if en in seen:
            continue
        seen.add(en)
        kept.append((en, hi))

    with open(GLOSS, 'w', encoding='utf-8', newline='') as f:
        for en, hi in kept:
            f.write(en + '\t' + hi + '\n')

    print('collapsed doubled newlines in ' + str(collapsed) + ' rows')
    print(GLOSS + ': ' + str(len(kept)) + ' rows, ' + str(len(dropped))
          + ' dropped')
    for why, en in dropped:
        print('   [' + why + '] ' + repr(en[:58]))

    left = untranslated(DART, load(GLOSS))
    print('\nstill untranslated: ' + str(len(left)))
    for x in left:
        print('   ' + repr(x[:72]))
    # The interpolation is the only acceptable survivor.
    ok = len(left) == 1 and left[0] == INTERP
    print('\n' + ('OK - only the interpolation is left, as intended'
                  if ok else 'NOT CLEAN - see the list above'))


if __name__ == '__main__':
    main()
