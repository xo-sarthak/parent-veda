"""Drop the `const` that a lifted string just invalidated.

`S.now.x` is a getter, so any const expression that now contains one stops
being a compile-time constant. The analyzer reports the exact position; this
walks backwards from there to the `const` keyword that owns it and removes it.

Runs from analyzer output on stdin:

    flutter analyze lib 2>&1 | python tool/fix_const_errors.py
"""

import collections
import re
import sys

LOC = re.compile(r'-\s+(lib[\\/][^\s:]+\.dart):(\d+):(\d+)\s+-\s+'
                 r'(invalid_constant|non_constant_map_value|'
                 r'non_constant_list_element|non_constant_default_value|'
                 r'const_initialized_with_non_constant_value)')

by_file = collections.defaultdict(list)
for line in sys.stdin:
    m = LOC.search(line)
    if m:
        by_file[m.group(1).replace('\\', '/')].append(
            (int(m.group(2)), int(m.group(3))))

fixed = 0
for path, spots in by_file.items():
    src = open(path, encoding='utf-8').read()
    lines = src.split('\n')
    offsets = [0]
    for ln in lines:
        offsets.append(offsets[-1] + len(ln) + 1)

    # Walk backwards from each error to the nearest `const` that precedes it
    # without an intervening `;` or `{` - i.e. the one governing this
    # expression. Collect positions first, then cut from the end so earlier
    # offsets stay valid.
    cuts = set()
    for line_no, col in spots:
        pos = offsets[line_no - 1] + col - 1
        window = src[max(0, pos - 900):pos]
        best = None
        for m in re.finditer(r'\bconst\b\s*', window):
            between = window[m.end():]
            if ';' in between:
                continue
            best = m
        if best:
            start = max(0, pos - 900) + best.start()
            end = max(0, pos - 900) + best.end()
            cuts.add((start, end))

    for start, end in sorted(cuts, reverse=True):
        src = src[:start] + src[end:]
        fixed += 1
    open(path, 'w', encoding='utf-8', newline='').write(src)
    print(f'  {len(cuts):>3} const removed  {path}')

print(f'{fixed} total')
