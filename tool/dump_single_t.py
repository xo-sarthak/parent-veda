"""Dump / apply single-argument `_t('...')` calls.

`report_findings_data.dart` mirrors its English into `hi` through a one-argument
helper, so there is no second slot to translate into. The helper now takes an
optional second argument; this adds it, call site by call site, from a TSV.

    python tool/dump_single_t.py <file>              # dump
    python tool/dump_single_t.py <file> <tsv>        # apply
"""

import re
import sys

CALL = re.compile(r"_t\(\s*(['\"])((?:\\.|(?!\1).)*?)\1\s*\)")


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
calls = list(CALL.finditer(src))

if len(sys.argv) == 2:
    for i, m in enumerate(calls):
        print(f'{i}\t{unescape(m.group(2), m.group(1))}')
    print(f'\n# {len(calls)} single-argument _t() calls', file=sys.stderr)
    raise SystemExit

rows, errors = {}, []
for ln, raw in enumerate(open(sys.argv[2], encoding='utf-8'), 1):
    raw = raw.rstrip('\n')
    if not raw.strip() or raw.lstrip().startswith('#'):
        continue
    parts = raw.split('\t')
    if len(parts) < 2 or not parts[0].strip().isdigit():
        errors.append(f'{sys.argv[2]}:{ln}: expected `idx<TAB>hindi`')
        continue
    rows[int(parts[0])] = parts[-1].strip()

for i in rows:
    if i >= len(calls):
        errors.append(f'no call with index {i} (file has {len(calls)})')

if errors:
    print('REFUSED — nothing written:', file=sys.stderr)
    for e in errors[:20]:
        print('  ' + e, file=sys.stderr)
    raise SystemExit(1)

out = src
for i in sorted(rows, reverse=True):
    m = calls[i]
    quote = m.group(1)
    en = m.group(2)
    out = (out[:m.start()]
           + f'_t({quote}{en}{quote}, {literal(rows[i])})'
           + out[m.end():])

open(path, 'w', encoding='utf-8', newline='').write(out)
print(f'{path}: {len(rows)} strings given Hindi')
