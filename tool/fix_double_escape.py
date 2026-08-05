"""Undo the double-escape in generated `ui*` getters.

The extractor captured a literal straight out of the source, so a string that
already contained `\\'` arrived carrying the backslash as a real character -
then got escaped a second time on the way out. The result compiles and renders
a visible backslash, or a literal `\\n` where a line break was meant.

Only the generated block is touched; hand-written strings elsewhere in the file
may legitimately contain a doubled backslash.
"""

import re

PATH = 'lib/localization/app_language.dart'
GETTER = re.compile(
    r"(String get ui\w+ => _p\()('(?:\\.|[^'])*')(, )('(?:\\.|[^'])*')(\);)")

DOUBLE = '\\' + '\\'      # two characters: backslash backslash
SINGLE = '\\'             # one character


def collapse(lit):
    return lit.replace(DOUBLE, SINGLE)


def repl(m):
    return (m.group(1) + collapse(m.group(2)) + m.group(3)
            + collapse(m.group(4)) + m.group(5))


src = open(PATH, encoding='utf-8').read()
before = src.count(DOUBLE)
out = GETTER.sub(repl, src)
after = out.count(DOUBLE)
open(PATH, 'w', encoding='utf-8', newline='').write(out)
print(f'doubled backslashes in generated getters: {before} -> {after}')
