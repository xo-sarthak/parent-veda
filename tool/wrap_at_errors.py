"""Wrap plain string literals the analyzer says should be LocalizedText.

The counterpart to resolve_read_sites. That one handles a LocalizedText turning
up where a String is wanted; this handles the reverse - a literal in a data file
whose model has widened but which no glossary covered, usually because skip()
filtered it as identifier-like ('live', 'opening') or because it is a bare
number-and-unit ('8:00 pm').

Driven by analyzer POSITIONS rather than field names, because these sit in
positional arguments too - `QuickFact(_t('90 min', '90 min'), 'live')` - where
a `field:` pattern sees nothing.

The wrapper is _en(), not _t(x, x). An identical pair reads as finished
translation work to anything counting pairs; _en() says "English for now" and
`grep -c '_en('` is the size of what is still owed.

    python tool/wrap_at_errors.py <file.dart> [--dry]
"""

import re
import subprocess
import sys

HELPER = (
    "/// English-only, awaiting translation. Same shape as a translated pair so\n"
    "/// the model can widen, but deliberately NOT `_t(x, x)`: an identical pair\n"
    "/// reads as finished work to anything counting pairs.\n"
    "/// `grep -c '_en('` is the size of what is left here.\n"
    "LocalizedText _en(String s) => LocalizedText(en: s, hi: s);\n\n"
)

LIT = re.compile(r"""(['"])((?:\\.|(?!\1).)*?)\1""")


def positions(path):
    out = subprocess.run('flutter analyze ' + path, shell=True,
                         capture_output=True, text=True, encoding='utf-8')
    pat = re.compile(r"- ([^ ]+\.dart):(\d+):(\d+) - (\w+)$")
    rows = []
    for line in (out.stdout or '').split('\n'):
        line = line.strip()
        m = pat.search(line)
        if not m:
            continue
        # Only the direction where a String needs to BECOME a LocalizedText.
        if "type 'String' can't be assigned" not in line:
            continue
        rows.append((int(m.group(2)), int(m.group(3))))
    return rows


def main():
    path = sys.argv[1]
    dry = '--dry' in sys.argv
    rows = positions(path)
    if not rows:
        print(path + ': nothing to wrap')
        return

    src = open(path, encoding='utf-8').read()
    starts = [0]
    for ln in src.split('\n'):
        starts.append(starts[-1] + len(ln) + 1)

    wrapped, seen = 0, set()
    for line, col in sorted(rows, reverse=True):
        at = starts[line - 1] + col - 1
        m = LIT.match(src, at)
        if not m or at in seen:
            continue
        seen.add(at)
        src = src[:m.start()] + '_en(' + m.group(0) + ')' + src[m.end():]
        wrapped += 1

    if '_en(String s)' not in src:
        anchor = re.search(r'^(class |enum |const |final |List<|Map<)', src,
                           re.M)
        src = src[:anchor.start()] + HELPER + src[anchor.start():]

    print(path + ': wrapped ' + str(wrapped) + ' literals in _en()')
    if dry:
        print('  (dry run - nothing written)')
        return
    open(path, 'w', encoding='utf-8', newline='').write(src)


if __name__ == '__main__':
    main()
