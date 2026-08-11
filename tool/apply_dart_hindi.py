"""Write translated Hindi back into Dart string literals, by byte span.

WHY SPANS AND NOT SEARCH-AND-REPLACE. This repo has already lost 96 `_t(...)`
calls to a regex substitution that produced `return ;` - valid Dart, compiled
fine, silently deleted a screen's worth of content. Text substitution on source
code has no way to know it hit the wrong occurrence, and a translation
containing `$`, a backslash or a quote can corrupt the pattern itself.

A span cannot miss. The applier re-reads the file, checks that the bytes at
[start, end) are still EXACTLY the Hinglish the extractor saw, and only then
replaces them. If anything moved, it refuses rather than guessing.

Spans are applied in DESCENDING order within each file, because replacing text
shifts every offset after it. Ascending order would corrupt every span but the
first - and would still produce a file that compiles.

Checks before anything is written:

    span still matches      the file has not changed under us
    no overlapping spans    two rows writing the same bytes
    Devanagari present      the point of the pass
    placeholder parity      a lost $w shows the wrong week number
    no raw apostrophe       these go into single-quoted Dart literals
    no tab or newline       would break the literal or the TSV round-trip

    python tool/apply_dart_hindi.py --dry
    python tool/apply_dart_hindi.py
"""

import glob
import io
import re
import sys

DEV = re.compile('[ऀ-ॿ]')
PLACEHOLDER = re.compile(r'\$\{[^}]*\}|\$\w+')
BS = chr(92)


def load(path, n):
    rows = []
    for ln, line in enumerate(io.open(path, encoding='utf-8'), 1):
        line = line.rstrip('\n').rstrip('\r')
        if not line:
            continue
        parts = line.split('\t')
        rows.append((ln, parts))
    return rows


def main():
    dry = '--dry' in sys.argv

    # The extractor's output is the source of truth for what the spans held.
    src = {}
    for _ln, p in load('tool/hindi/d_all.tsv', 6):
        if len(p) >= 6:
            src[(p[0], int(p[1]), int(p[2]))] = (p[4], p[5])

    problems = []
    edits = {}
    seen = set()

    done = sorted(glob.glob('tool/hindi/d_batch*.done.tsv'))
    if not done:
        print('no d_batch*.done.tsv - nothing to apply')
        return 1

    for path in done:
        for ln, p in load(path, 4):
            where = '%s:%d' % (path.split('/')[-1], ln)
            if len(p) != 4:
                problems.append('%s  expected 4 columns, got %d'
                                % (where, len(p)))
                continue
            f, a, b, hi = p[0], p[1], p[2], p[3]
            try:
                key = (f, int(a), int(b))
            except ValueError:
                problems.append('%s  non-numeric span %r %r' % (where, a, b))
                continue
            if key not in src:
                problems.append('%s  unknown span %s' % (where, key))
                continue
            if key in seen:
                problems.append('%s  duplicate span %s' % (where, key))
                continue
            seen.add(key)
            en, old = src[key]

            if not hi.strip():
                problems.append('%s  empty translation' % where)
                continue
            if not DEV.search(hi):
                problems.append('%s  no Devanagari: %s' % (where, hi[:70]))
                continue
            if "'" in hi:
                problems.append('%s  raw apostrophe would break the Dart '
                                'literal: %s' % (where, hi[:70]))
                continue
            # `\n` is legitimate - several of these literals are two-line card
            # titles and the English carries the break. Any OTHER escape is
            # refused: an unpaired backslash ends a Dart literal early, and the
            # damage looks like a syntax error somewhere further down the file.
            stray_escape = re.sub(r'\\n', '', hi)
            if BS in stray_escape:
                problems.append('%s  backslash other than \\n: %s'
                                % (where, hi[:70]))
                continue
            if hi.count(BS + 'n') != en.count(BS + 'n'):
                problems.append('%s  newline parity %d vs %d: %s'
                                % (where, en.count(BS + 'n'),
                                   hi.count(BS + 'n'), hi[:60]))
                continue
            if sorted(PLACEHOLDER.findall(hi)) != sorted(PLACEHOLDER.findall(en)):
                problems.append('%s  placeholders %s vs %s'
                                % (where, PLACEHOLDER.findall(en),
                                   PLACEHOLDER.findall(hi)))
                continue
            edits.setdefault(f, []).append((int(a), int(b), hi, old))

    missing = set(src) - seen
    if missing:
        problems.append('%d spans never came back, e.g. %s'
                        % (len(missing), sorted(missing)[0]))

    # Overlap check, per file.
    for f, es in edits.items():
        ordered = sorted(es)
        for (a1, b1, _h, _o), (a2, _b2, _h2, _o2) in zip(ordered, ordered[1:]):
            if a2 < b1:
                problems.append('%s  overlapping spans %d-%d and %d'
                                % (f, a1, b1, a2))

    if problems:
        print('REFUSING TO APPLY - %d problem(s):\n' % len(problems))
        for p in problems[:40]:
            print('  ' + p)
        if len(problems) > 40:
            print('  ... and %d more' % (len(problems) - 40))
        return 1

    total = 0
    for f, es in sorted(edits.items()):
        text = io.open(f, encoding='utf-8').read()
        # Descending, so earlier offsets stay valid as we rewrite.
        for a, b, hi, old in sorted(es, reverse=True):
            if text[a:b] != old:
                print('REFUSING - %s span %d-%d no longer holds the expected '
                      'text.\n   expected: %r\n   found   : %r'
                      % (f, a, b, old, text[a:b]))
                return 1
            text = text[:a] + hi + text[b:]
        if not dry:
            io.open(f, 'w', encoding='utf-8', newline='\n').write(text)
        print('%-52s %4d' % (f, len(es)))
        total += len(es)

    print('\n%s %d strings across %d files'
          % ('WOULD APPLY' if dry else 'APPLIED', total, len(edits)))
    if not dry:
        print('spans are now stale - re-run tool/extract_dart_hinglish.py '
              'before any further pass')
    return 0


if __name__ == '__main__':
    sys.exit(main())
