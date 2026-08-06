"""Insert .en/.now before a String method called on a LocalizedText.

The second half of a widening. resolve_read_sites handles values PASSED
somewhere; this handles values USED - `x.isNotEmpty`, `x.split(…)` - which the
analyzer reports as undefined_getter / undefined_method instead.

The suffix is not uniform, and the split is the whole point:

  .en   for PRESENCE - isEmpty / isNotEmpty / trim-then-check. Whether a block
        exists must give the same answer in both languages, or a myth-vs-fact
        card appears in English and vanishes in Hindi. Presence is structure,
        and structure is not translated.

  .now  for TEXT - split / toUpperCase / replaceAll / substring. These shape
        what is drawn, so they follow the language on screen.

Anything else is left for a human, because guessing at it is how `.now` ended
up on a store key.

    python tool/resolve_string_methods.py [--dry]
"""

import re
import subprocess
import sys

PRESENCE = {'isEmpty', 'isNotEmpty'}
TEXT = {'split', 'toUpperCase', 'toLowerCase', 'replaceAll', 'substring',
        'trim', 'contains', 'startsWith', 'endsWith'}


def find():
    out = subprocess.run('flutter analyze lib', shell=True,
                         capture_output=True, text=True, encoding='utf-8')
    pat = re.compile(
        r"The (?:getter|method) '(\w+)' isn't defined for the type "
        r"'LocalizedText'.*- ([^ ]+\.dart):(\d+):(\d+) -")
    rows = []
    for line in (out.stdout or '').split('\n'):
        m = pat.search(line.strip())
        if not m:
            continue
        name = m.group(1)
        if name in PRESENCE:
            suffix = '.en'
        elif name in TEXT:
            suffix = '.now'
        else:
            print('  left alone (not classified): ' + name + ' at '
                  + m.group(2) + ':' + m.group(3))
            continue
        rows.append({'file': m.group(2), 'line': int(m.group(3)),
                     'col': int(m.group(4)), 'suffix': suffix, 'name': name})
    return rows


def main():
    dry = '--dry' in sys.argv
    rows = find()
    if not rows:
        print('nothing to do')
        return
    by_file = {}
    for r in rows:
        by_file.setdefault(r['file'], []).append(r)

    for path, items in by_file.items():
        src = open(path, encoding='utf-8').read()
        starts = [0]
        for ln in src.split('\n'):
            starts.append(starts[-1] + len(ln) + 1)
        for r in sorted(items, key=lambda x: (-x['line'], -x['col'])):
            at = starts[r['line'] - 1] + r['col'] - 1
            # The column points at the METHOD NAME; the suffix goes before the
            # dot that precedes it.
            dot = src.rfind('.', 0, at)
            if dot < 0 or src[dot + 1:at] != '':
                continue
            src = src[:dot] + r['suffix'] + src[dot:]
        n_en = sum(1 for r in items if r['suffix'] == '.en')
        print(path + ': ' + str(n_en) + ' presence + .en, '
              + str(len(items) - n_en) + ' text + .now')
        if not dry:
            open(path, 'w', encoding='utf-8', newline='').write(src)
    if dry:
        print('(dry run - nothing written)')


if __name__ == '__main__':
    main()
