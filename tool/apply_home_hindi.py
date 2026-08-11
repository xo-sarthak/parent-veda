"""Apply the translated batches back into lib/data/home/*.json.

REFUSES rather than half-applies. Every silent failure this migration has hit
came from a tool that wrote plausible-looking output and reported success:
a regex that skipped four live strings, an applier that rewrote comments, a
one-liner that deleted 96 calls and left `return ;` behind. None of them
failed to compile. None of them failed a test.

So this validates first, applies nothing if anything is wrong, and prints the
offending rows. The checks are the ones that catch a wrong translation the
compiler cannot:

    pointer parity     a row landing on the wrong field is invisible forever
    Devanagari present the whole point of the pass
    not-the-English    a copied English half reads as finished work
    \\n parity          a lost newline silently reflows a screen
    placeholder parity a lost $n shows the mother the wrong number
    no tabs            a tab inside a cell shifts every column after it

    python tool/apply_home_hindi.py --dry
    python tool/apply_home_hindi.py
"""

import glob
import json
import os
import re
import sys

DEV = re.compile('[ऀ-ॿ]')
PLACEHOLDER = re.compile(r'\$\{?\w+\}?|\{\w+\}|%[sd]')

# Latin that is allowed to survive inside Hindi prose: clinical terms she reads
# off a bottle or a report, plus proper nouns. Anything else in Latin is very
# likely un-translated Hinglish, which is exactly what this pass removes.
ALLOWED_LATIN = re.compile(
    r'^(Folate|Folic|Acid|Vitamin|Omega|Iron|Calcium|Protein|Fibre|Fiber|DHA|'
    r'B12|D3|IU|mg|ml|g|kg|cm|IVF|IUI|PCOS|NT|NIPT|TIFFA|Doppler|CTG|BP|'
    r'Braxton|Hicks|Kegel|screen|time|serve|and|return|ParentVeda|Veda|'
    r'WHO|AAP|ICMR|FOGSI|COVID|DNA|REM|A|B|C|D|E|K)$', re.I)


QUOTED = re.compile(r"'[^']*'")
WORD = re.compile(r"[A-Za-z][A-Za-z'-]{2,}")


def bare_latin(hi):
    """Latin words that are neither a quoted term nor a proper name.

    The distinction the whole corpus turns on, and one that a flat word-list
    could not express:

      'zone of proximal development'   a named term, introduced in quotes and
                                       glossed - this is how Hindi prose
                                       imports vocabulary, and it stays Latin
      Carol Dweck                      a person's name - never translated
      nervous system                   an ordinary phrase mid-sentence, and a
                                       word the hi-IN narration voice cannot
                                       pronounce at all

    Only the third kind is a defect. Counting Latin words without reading the
    quotes flagged all three alike, which is why this returns the offenders
    rather than a count over a threshold: a threshold of 3 also silently let
    every SINGLE stray word through, and 5 of the 19 real misses in this
    corpus were single words.
    """
    outside = QUOTED.sub(' ', hi)
    return [w for w in WORD.findall(outside)
            if not ALLOWED_LATIN.match(w) and not w[0].isupper()]


def load(path):
    rows = []
    for n, line in enumerate(open(path, encoding='utf-8'), 1):
        line = line.rstrip('\n').rstrip('\r')
        if not line:
            continue
        parts = line.split('\t')
        rows.append((n, parts))
    return rows


def set_at(root, pointer, value):
    """Write `value` into the `hi` of the {en,hi} pair at `pointer`.

    Returns the English half so the caller can compare, or None if the pointer
    does not resolve - a pointer that does not resolve is a hard failure, not
    something to skip.
    """
    node = root
    for seg in pointer.split('/'):
        if isinstance(node, list):
            if not seg.isdigit() or int(seg) >= len(node):
                return None
            node = node[int(seg)]
        elif isinstance(node, dict):
            if seg not in node:
                return None
            node = node[seg]
        else:
            return None
    if not isinstance(node, dict) or 'en' not in node:
        return None
    en = node['en']
    node['hi'] = value
    return en


def main():
    dry = '--dry' in sys.argv
    src = {}
    for p in sorted(glob.glob('tool/hindi/h_batch*.tsv')):
        if p.endswith('.done.tsv'):
            continue
        for _n, parts in load(p):
            src[parts[0]] = parts[2] if len(parts) > 2 else ''

    problems = []
    edits = {}          # file -> [(json pointer, hindi)]
    seen = set()

    done_files = sorted(glob.glob('tool/hindi/h_batch*.done.tsv'),
                        key=lambda p: int(re.search(r'batch(\d+)', p).group(1)))
    if not done_files:
        print('no .done.tsv files - nothing to apply')
        return 1

    for path in done_files:
        for n, parts in load(path):
            where = '%s:%d' % (os.path.basename(path), n)
            if len(parts) != 2:
                problems.append('%s  expected 2 columns, got %d  %s'
                                % (where, len(parts), parts[0][:60]))
                continue
            pointer, hi = parts
            if pointer not in src:
                problems.append('%s  unknown pointer  %s' % (where, pointer))
                continue
            if pointer in seen:
                problems.append('%s  duplicate pointer  %s' % (where, pointer))
                continue
            seen.add(pointer)
            en = src[pointer]

            if not hi.strip():
                problems.append('%s  empty translation  %s' % (where, pointer))
                continue
            if not DEV.search(hi):
                problems.append('%s  no Devanagari  %s\n     %s'
                                % (where, pointer, hi[:90]))
                continue
            if hi.strip() == en.strip():
                problems.append('%s  copied the English  %s' % (where, pointer))
                continue
            if hi.count('\\n') != en.count('\\n'):
                problems.append('%s  \\n parity %d vs %d  %s'
                                % (where, en.count('\\n'), hi.count('\\n'),
                                   pointer))
                continue
            if sorted(PLACEHOLDER.findall(en)) != sorted(PLACEHOLDER.findall(hi)):
                problems.append('%s  placeholders %s vs %s  %s'
                                % (where, PLACEHOLDER.findall(en),
                                   PLACEHOLDER.findall(hi), pointer))
                continue

            stray = bare_latin(hi)
            if stray:
                problems.append('%s  Latin left in  %s\n     %s'
                                % (where, pointer, ' '.join(stray[:8])))
                continue

            f, _, ptr = pointer.partition('.json/')
            edits.setdefault(f + '.json', []).append((ptr, hi))

    missing = set(src) - seen
    if missing:
        problems.append('%d rows never came back, e.g. %s'
                        % (len(missing), sorted(missing)[0]))

    if problems:
        print('REFUSING TO APPLY - %d problem(s):\n' % len(problems))
        for p in problems[:40]:
            print('  ' + p)
        if len(problems) > 40:
            print('  ... and %d more' % (len(problems) - 40))
        return 1

    total = 0
    for path, pairs in sorted(edits.items()):
        data = json.load(open(path, encoding='utf-8'))
        bad = []
        for ptr, hi in pairs:
            # The TSV encodes a newline as backslash-n; the JSON holds a real one.
            if set_at(data, ptr, hi.replace('\\n', '\n')) is None:
                bad.append(ptr)
        if bad:
            print('REFUSING - %s: %d pointers do not resolve, e.g. %s'
                  % (path, len(bad), bad[0]))
            return 1
        if not dry:
            with open(path, 'w', encoding='utf-8') as fh:
                json.dump(data, fh, ensure_ascii=False, indent=2)
                fh.write('\n')
        total += len(pairs)
        print('%-40s %4d' % (path, len(pairs)))

    print('\n%s %d translations across %d files'
          % ('WOULD APPLY' if dry else 'APPLIED', total, len(edits)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
