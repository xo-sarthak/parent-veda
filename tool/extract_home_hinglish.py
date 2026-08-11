"""Worklists for the Daily Moment content, which is still Latin-script Hinglish.

lib/data/home/ is 37 week files and ~5,100 pairs - the largest single content
body in the product, and the screen a mother opens daily. It was missed
entirely by the earlier audit, which only globbed lib/data/*.dart.

Split into batches by FILE, never mid-file, so each batch is a coherent set of
weeks and no two workers can touch the same JSON.

Columns: path | EMPTY (new Devanagari) | English | current Hinglish

    python tool/extract_home_hinglish.py <batches>
"""

import json
import os
import re
import sys

DEV = re.compile('[ऀ-ॿ]')
LATIN = re.compile(r'[A-Za-z]{3}')


def rows_for(path):
    out = []

    def walk(node, ptr):
        if isinstance(node, dict):
            if 'en' in node and len(node) <= 2:
                hi = str(node.get('hi', ''))
                if not DEV.search(hi) and LATIN.search(hi) and hi != node['en']:
                    out.append((path + ptr, node['en'], hi))
                return
            for k, v in node.items():
                walk(v, ptr + '/' + str(k))
        elif isinstance(node, list):
            for i, v in enumerate(node):
                walk(v, ptr + '/' + str(i))

    walk(json.load(open(path, encoding='utf-8')), '')
    return out


def main():
    batches = int(sys.argv[1]) if len(sys.argv) > 1 else 8
    files = sorted(
        [os.path.join('lib/data/home', f).replace(os.sep, '/')
         for f in os.listdir('lib/data/home') if f.endswith('.json')]
    ) + ['lib/data/homeDailyContent.json']

    # Greedy pack by character weight, so batches are even in WORK rather than
    # in file count - week files vary a lot in size.
    weighed = []
    for f in files:
        rs = rows_for(f)
        weighed.append((f, rs, sum(len(h) for _, _, h in rs)))
    weighed.sort(key=lambda x: -x[2])

    bins = [[] for _ in range(batches)]
    load = [0] * batches
    for f, rs, w in weighed:
        i = load.index(min(load))
        bins[i].append((f, rs))
        load[i] += w

    os.makedirs('tool/hindi', exist_ok=True)
    for n, b in enumerate(bins, 1):
        out = 'tool/hindi/h_batch%d.tsv' % n
        count = 0
        with open(out, 'w', encoding='utf-8', newline='') as fh:
            for _f, rs in b:
                for ptr, en, hi in rs:
                    fh.write(ptr + '\t\t'
                             + en.replace('\n', '\\n') + '\t'
                             + hi.replace('\n', '\\n') + '\n')
                    count += 1
        print('batch %d: %2d files, %4d rows, %6d chars -> %s'
              % (n, len(b), count, load[n - 1], out))


if __name__ == '__main__':
    main()
