"""Turn the kWhyPack mirror-map into bilingual pairs.

`Map<String, String>` keyed by item id, so every "why pack this" line rendered
English regardless of language — on a screen whose chrome is already Hindi.
Refuses unless every key in the map has Hindi, because a half-translated list
is worse here than an untranslated one: the mother sees the seam.
"""

import re

DATA = 'lib/data/ready_for_birth_data.dart'
TSV = 'tool/hindi/d_whypack.tsv'

BLOCK = re.compile(r"const Map<String, String> kWhyPack = \{(.*?)\n\};", re.S)
ENTRY = re.compile(r"'([a-z_0-9]+)':\s*('(?:\\.|[^'])*'|\"(?:\\.|[^\"])*\")")


def literal(text):
    return "'" + text.replace('\\', '\\\\').replace("'", "\\'") + "'"


hindi = {}
for line in open(TSV, encoding='utf-8'):
    line = line.rstrip('\n')
    if not line.strip() or line.startswith('#'):
        continue
    k, _, v = line.partition('\t')
    hindi[k.strip()] = v.strip()

src = open(DATA, encoding='utf-8').read()
m = BLOCK.search(src)
if not m:
    raise SystemExit('kWhyPack map not found — has it already been converted?')

entries = ENTRY.findall(m.group(1))
missing = [k for k, _ in entries if k not in hindi]
if missing:
    raise SystemExit(f'REFUSED — no Hindi for: {", ".join(missing)}')

lines = ['const Map<String, LocalizedText> kWhyPack = {']
for key, en in entries:
    lines.append(f"  '{key}': _t({en}, {literal(hindi[key])}),")
lines.append('};')

src = src[:m.start()] + '\n'.join(lines) + src[m.end():]
open(DATA, 'w', encoding='utf-8', newline='').write(src)
print(f'kWhyPack: {len(entries)} entries now bilingual')
