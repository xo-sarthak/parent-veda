"""Re-emit lib/data/home JSON in the house format: one line per {en, hi} pair.

Why this is not cosmetic. `json.dump(..., indent=2)` expands every bilingual
pair across four lines, so translating 5,114 pairs produced a diff of 21,726
insertions against 5,460 deletions - every line in every file, whether it
changed or not. A reviewer cannot see the actual change in that, and neither
can `git blame`.

Written back in the original shape, the same work is 5,114 changed lines: one
per translation, each showing the old Hinglish beside the new Devanagari. The
diff becomes the review.

The rule the original files follow: a dict whose keys are exactly {en, hi}
prints inline; everything else prints expanded at indent 2.

    python tool/format_home_json.py
"""

import glob
import io
import json
import os


def enc(s):
    """JSON string, Devanagari kept literal (ensure_ascii=False)."""
    return json.dumps(s, ensure_ascii=False)


def dump(node, indent=0):
    pad = ' ' * indent
    if isinstance(node, dict):
        # The house form: a bilingual leaf lives on one line.
        if set(node) == {'en', 'hi'}:
            return '{ "en": %s, "hi": %s }' % (enc(node['en']), enc(node['hi']))
        if not node:
            return '{}'
        inner = ',\n'.join(
            '%s%s: %s' % (' ' * (indent + 2), enc(k), dump(v, indent + 2))
            for k, v in node.items())
        return '{\n%s\n%s}' % (inner, pad)
    if isinstance(node, list):
        if not node:
            return '[]'
        inner = ',\n'.join('%s%s' % (' ' * (indent + 2), dump(v, indent + 2))
                           for v in node)
        return '[\n%s\n%s]' % (inner, pad)
    return enc(node) if isinstance(node, str) else json.dumps(node)


def main():
    paths = sorted(glob.glob('lib/data/home/*.json')) + \
        ['lib/data/homeDailyContent.json']
    for p in paths:
        p = p.replace(os.sep, '/')
        data = json.load(io.open(p, encoding='utf-8'))
        io.open(p, 'w', encoding='utf-8', newline='\n').write(
            dump(data) + '\n')
    print('reformatted %d files' % len(paths))


if __name__ == '__main__':
    main()
