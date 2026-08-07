"""Collapse stacked `.now.now…` back to a single `.now`.

resolve_read_sites is analyzer-driven and idempotent only if you run it once.
Run it again while a line still errors for a DIFFERENT reason and it appends a
second suffix at the same position, and a third, until you get

    wk.now.now.now.now.now > 0        // wk is an int
    exact.now.now.now.now.now         // exact is a bool

`.now` returns a String, so `.now.now` never type-checks and a stack can only
ever be damage. Collapsing is therefore always safe; deciding whether the
REMAINING single `.now` belongs there is a separate judgement, left to a human.

    python tool/collapse_now.py [--dry]
"""

import glob
import os
import re
import sys

STACK = re.compile(r'(?:\.now){2,}')


def main():
    dry = '--dry' in sys.argv
    total = 0
    for path in glob.glob('lib/**/*.dart', recursive=True):
        src = open(path, encoding='utf-8', newline='').read()
        out, n = STACK.subn('.now', src)
        if not n:
            continue
        total += n
        print(os.path.basename(path) + ': ' + str(n) + ' stacked suffixes')
        if not dry:
            open(path, 'w', encoding='utf-8', newline='').write(out)
    print('collapsed ' + str(total))
    if dry:
        print('(dry run - nothing written)')


if __name__ == '__main__':
    main()
