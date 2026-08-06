"""Widen named fields to LocalizedText, SCOPED TO THEIR CLASS.

Written after the unscoped version did real damage. It replaced the first
`final String title;` in a file holding four classes that each have a `title`,
so it widened BookKeyIdea and left ReadItem - the one that needed it - alone.
Nothing said so; the analyzer simply reported a different set of errors, and
the wrong class stayed wrong until someone read the line numbers.

So a target here is always Class.field, never a bare field name, and every
target must be found or the run fails loudly rather than half-applying.

Handles three shapes:

    final String x;              -> final LocalizedText x;
    final List<String> x;        -> final List<LocalizedText> x;
    this.x = '',                 -> this.x = const LocalizedText(en: '', hi: ''),
    this.x = const [],           -> unchanged (an empty list is still an
                                    empty list once its element type widens)

    python tool/widen_fields.py <file.dart> Class.field [Class.field…]
"""

import re
import sys


def class_span(src, name):
    """(start, end) of `class <name> {…}`, by brace balance."""
    m = re.search(r'^class ' + re.escape(name) + r'\b[^{]*\{', src, re.M)
    if not m:
        return None
    i, depth = m.end(), 1
    while i < len(src) and depth:
        if src[i] == '{':
            depth += 1
        elif src[i] == '}':
            depth -= 1
        i += 1
    return (m.start(), i)


def main():
    path, targets = sys.argv[1], sys.argv[2:]
    src = open(path, encoding='utf-8').read()

    missed = []
    for target in targets:
        cls, _, field = target.partition('.')
        span = class_span(src, cls)
        if not span:
            missed.append(target + ' (no such class)')
            continue
        head, block, tail = src[:span[0]], src[span[0]:span[1]], src[span[1]:]

        before = block
        block = re.sub(r'\bfinal String (' + re.escape(field) + r');',
                       r'final LocalizedText \1;', block)
        block = re.sub(r'\bfinal List<String> (' + re.escape(field) + r');',
                       r'final List<LocalizedText> \1;', block)
        block = block.replace(
            'this.' + field + " = '',",
            'this.' + field + " = const LocalizedText(en: '', hi: ''),")
        if block == before:
            missed.append(target + ' (declaration not found or already wide)')
        src = head + block + tail

    if missed:
        sys.exit('nothing written - unresolved targets:\n  '
                 + '\n  '.join(missed))

    if 'localization/app_language.dart' not in src:
        imports = list(re.finditer(r"^import .*;$", src, re.M))
        rel = '../localization/app_language.dart'
        if imports:
            at = imports[-1].end()
            src = src[:at] + "\nimport '" + rel + "';" + src[at:]
        else:
            src = "import '" + rel + "';\n\n" + src

    open(path, 'w', encoding='utf-8', newline='').write(src)
    print(path + ': widened ' + str(len(targets)) + ' fields')


if __name__ == '__main__':
    main()
