"""Merge runs of adjacent `_t(...)` calls back into one.

Dart concatenates adjacent string literals, which is how long prose is written
in this codebase:

    body:
        'para one\\n\\n'
        'para two\\n\\n'
        'para three',

apply_glossary rewrites each literal independently, and the result -
`_t('a','A') _t('b','B')` - is not valid Dart: functions do not concatenate.
So the run has to be folded back into a single call, joining the English parts
in order and the Hindi parts in the same order.

That ordering is the whole correctness argument. The paragraphs were translated
one by one, so joining them by position preserves the pairing; any reordering
here would silently attach the wrong Hindi to the wrong English, which nothing
downstream could detect.

    python tool/merge_adjacent_t.py <file.dart> [--dry]
"""

import re
import sys


def find_calls(src, marker='_t('):
    """(start, end, [arg_spans]) for every marker call, paren-balanced."""
    out = []
    for m in re.finditer(re.escape(marker), src):
        i = m.end()
        depth, args, arg_start = 1, [], m.end()
        quote = None
        while i < len(src) and depth:
            c = src[i]
            if quote:
                if c == '\\':
                    i += 2
                    continue
                if c == quote:
                    quote = None
            elif c in '\'"':
                quote = c
            elif c == '(':
                depth += 1
            elif c == ')':
                depth -= 1
                if not depth:
                    args.append((arg_start, i))
            elif c == ',' and depth == 1:
                args.append((arg_start, i))
                arg_start = i + 1
            i += 1
        if depth == 0:
            out.append((m.start(), i, args))
    return out


def main():
    path = sys.argv[1]
    dry = '--dry' in sys.argv
    src = open(path, encoding='utf-8').read()

    calls = find_calls(src)
    # Group calls separated from the previous one by whitespace ONLY - that is
    # exactly the adjacent-literal shape. Anything else (a comma, a bracket) is
    # a separate argument and must be left alone.
    runs, current = [], []
    for c in calls:
        if current and not src[current[-1][1]:c[0]].strip():
            current.append(c)
        else:
            if len(current) > 1:
                runs.append(current)
            current = [c]
    if len(current) > 1:
        runs.append(current)

    if not runs:
        print(path + ': no adjacent runs')
        return

    # Rewrite back-to-front so earlier offsets stay valid.
    merged = 0
    for run in reversed(runs):
        ens, his = [], []
        ok = True
        for start, end, args in run:
            if len(args) != 2:
                ok = False
                break
            ens.append(src[args[0][0]:args[0][1]].strip())
            his.append(src[args[1][0]:args[1][1]].strip())
        if not ok:
            print('  skipped a run whose call did not have 2 args')
            continue
        joined = '_t(' + '\n        '.join(ens) + ',\n        ' \
                 + '\n        '.join(his) + ')'
        src = src[:run[0][0]] + joined + src[run[-1][1]:]
        merged += 1

    print(path + ': merged ' + str(merged) + ' runs of adjacent _t() calls')
    if dry:
        print('  (dry run - nothing written)')
        return
    open(path, 'w', encoding='utf-8', newline='').write(src)


if __name__ == '__main__':
    main()
