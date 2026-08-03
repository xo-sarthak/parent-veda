"""Apply Hindi into `_p(en, hi)` call sites.

    python tool/apply_ui_strings.py <file> <tsv>

TSV rows: idx <TAB> hindi

Refuses to write anything if ANY row fails, so a partial pass can never leave
the file half-translated. Two guards:

  * the target call must be mechanically rewritable (not a ternary) — a HAND
    row belongs in the editor;
  * the new text must carry exactly the placeholders the English carries. A
    string that loses its `$n` still compiles and still passes tests; it just
    shows the mother the wrong number.
"""

import sys
from ui_strings import find_calls, placeholders, dart_literal, quote_of

path, tsv = sys.argv[1], sys.argv[2]
src = open(path, encoding='utf-8').read()
calls = {c['idx']: c for c in find_calls(src)}

rows, errors = [], []
for ln, raw in enumerate(open(tsv, encoding='utf-8'), 1):
    raw = raw.rstrip('\n')
    if not raw.strip() or raw.lstrip().startswith('#'):
        continue
    parts = raw.split('\t')
    if len(parts) < 2:
        errors.append(f'{tsv}:{ln}: expected `idx<TAB>hindi`')
        continue
    try:
        idx = int(parts[0])
    except ValueError:
        errors.append(f'{tsv}:{ln}: first column is not an index: {parts[0]!r}')
        continue
    hindi = parts[-1].strip()
    c = calls.get(idx)
    if c is None:
        errors.append(f'{tsv}:{ln}: no call with index {idx}')
        continue
    if not c['simple']:
        errors.append(f'{tsv}:{ln}: call {idx} needs a hand edit (ternary or '
                      f'concatenation): {c["hi_src"][:60]}')
        continue
    want, got = placeholders(c['text_en']), placeholders(hindi)
    if want != got:
        errors.append(f'{tsv}:{ln}: call {idx} placeholder mismatch — '
                      f'English has {want}, Hindi has {got}')
        continue
    rows.append((c['hi_span'], hindi, quote_of(c['hi_src'])))

if errors:
    print(f'REFUSED — {len(errors)} problem(s), nothing written:', file=sys.stderr)
    for e in errors[:40]:
        print('  ' + e, file=sys.stderr)
    if len(errors) > 40:
        print(f'  ... and {len(errors) - 40} more', file=sys.stderr)
    sys.exit(1)

# apply from the end so earlier offsets stay valid
out = src
for (a, b), hindi, quote in sorted(rows, key=lambda r: -r[0][0]):
    lead = out[a:b]
    pad = lead[:len(lead) - len(lead.lstrip())]   # keep the original indent
    out = out[:a] + pad + dart_literal(hindi, quote) + out[b:]

open(path, 'w', encoding='utf-8', newline='').write(out)
print(f'{path}: {len(rows)} strings written')
