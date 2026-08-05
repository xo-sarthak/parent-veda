"""Dump / translate the strings inside `_l([...])` mirror-lists.

`_l` maps a list of English strings into LocalizedText with `hi` mirroring `en`,
so the questions a mother might ask her doctor, and the reassurances under each
finding, are still English. Translating means giving each entry its own pair,
which turns `_l([a, b])` into `[_t(a, ha), _t(b, hb)]`.

    python tool/dump_l_lists.py <file>          # dump
    python tool/dump_l_lists.py <file> <tsv>    # apply
"""

import re
import sys

BLOCK = re.compile(r"_l\(\[(.*?)\]\)", re.S)
ITEM = re.compile(r"(['\"])((?:\\.|(?!\1).)*?)\1")


def literal(text, quote="'"):
    body = (text.replace('\\', '\\\\')
                .replace(quote, '\\' + quote)
                .replace('\n', '\\n'))
    return quote + body + quote


def unescape(s, quote):
    return (s.replace('\\' + quote, quote)
             .replace('\\n', '\n')
             .replace('\\' + '\\', '\\'))


path = sys.argv[1]
src = open(path, encoding='utf-8').read()
blocks = list(BLOCK.finditer(src))

items = []          # (block_index, quote, raw, text)
for bi, b in enumerate(blocks):
    for m in ITEM.finditer(b.group(1)):
        items.append((bi, m.group(1), m.group(2), unescape(m.group(2),
                                                           m.group(1))))

if len(sys.argv) == 2:
    for i, (_, _, _, text) in enumerate(items):
        print(f'{i}\t{text}')
    print(f'\n# {len(items)} strings in {len(blocks)} lists', file=sys.stderr)
    raise SystemExit

rows = {}
for ln, raw in enumerate(open(sys.argv[2], encoding='utf-8'), 1):
    raw = raw.rstrip('\n')
    if not raw.strip() or raw.lstrip().startswith('#'):
        continue
    parts = raw.split('\t')
    if len(parts) < 2 or not parts[0].strip().isdigit():
        print(f'REFUSED — {sys.argv[2]}:{ln} expected `idx<TAB>hindi`',
              file=sys.stderr)
        raise SystemExit(1)
    rows[int(parts[0])] = parts[-1].strip()

missing = [i for i in range(len(items)) if i not in rows]
if missing:
    print(f'REFUSED — {len(missing)} of {len(items)} strings have no Hindi; '
          f'a partial list would ship a half-translated question set.',
          file=sys.stderr)
    print('  first missing: ' + ', '.join(str(i) for i in missing[:12]),
          file=sys.stderr)
    raise SystemExit(1)

# Rebuild each block, from the end so earlier offsets stay valid.
out = src
cursor = 0
per_block = {}
for i, (bi, quote, rawtext, _) in enumerate(items):
    per_block.setdefault(bi, []).append((quote, rawtext, rows[i]))

for bi in range(len(blocks) - 1, -1, -1):
    b = blocks[bi]
    parts = [f'_t({q}{raw}{q}, {literal(hi)})' for q, raw, hi in per_block[bi]]
    body = ',\n      '.join(parts)
    out = out[:b.start()] + '[\n      ' + body + ',\n    ]' + out[b.end():]

open(path, 'w', encoding='utf-8', newline='').write(out)
print(f'{path}: {len(items)} list strings given Hindi across {len(blocks)} lists')
