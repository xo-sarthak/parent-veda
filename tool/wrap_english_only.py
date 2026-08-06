"""Wrap a not-yet-translated data file's literals so a shared model can widen.

ReadItem is used by BOTH the pregnancy reads and the father reads. Widening it
for the pregnancy glossary breaks the father file, which has no Hindi and is
deliberately out of scope (CLAUDE.md: only Pregnancy is being migrated).

The tempting fix is `_t(text, text)`. Do not: a pair whose halves are identical
is indistinguishable from a finished translation to anything that counts pairs,
and that is exactly how can_i_data was once reported done while 302 of its
strings were still English.

So these get `_en(...)` instead - same runtime value, but a name that says what
it is and one grep away from a worklist.

    python tool/wrap_english_only.py <file.dart> field [field…]
"""

import re
import sys

HELPER = (
    "/// English-only, awaiting translation. Same shape as a translated pair so\n"
    "/// the shared model can widen, but deliberately NOT `_t(x, x)`: an\n"
    "/// identical pair reads as finished work to anything counting pairs.\n"
    "/// `grep -c '_en('` is the size of what is left here.\n"
    "LocalizedText _en(String s) => LocalizedText(en: s, hi: s);\n\n"
)


def main():
    path, fields = sys.argv[1], sys.argv[2:]
    src = open(path, encoding='utf-8').read()

    wrapped = 0
    for field in fields:
        def one(m):
            nonlocal wrapped
            wrapped += 1
            return m.group(1) + ': _en(' + m.group(2) + ')'
        # The value may sit on the NEXT line, and may be a RUN of adjacent
        # literals that Dart concatenates:
        #
        #     body:
        #         'para one '
        #         'para two',
        #
        # Both shapes were missed by a same-line single-literal pattern, which
        # reported "wrapped 0" and looked like there was nothing to do. Capture
        # the whole run so the concatenation stays inside one _en().
        lit = r"(?:'(?:\\.|[^'])*'|\"(?:\\.|[^\"])*\")"
        src = re.sub(
            r"(\b" + field + r"):\s*(" + lit + r"(?:\s*" + lit + r")*)",
            one, src)

    if '_en(String s)' not in src:
        anchor = re.search(r'^(class |enum |const |final |List<|Map<)', src,
                           re.M)
        at = anchor.start() if anchor else 0
        src = src[:at] + HELPER + src[at:]
    if 'localization/app_language.dart' not in src:
        imports = list(re.finditer(r"^import .*;$", src, re.M))
        rel = '../../localization/app_language.dart' if '/father/' in \
            path.replace('\\', '/') else '../localization/app_language.dart'
        if imports:
            at = imports[-1].end()
            src = src[:at] + "\nimport '" + rel + "';" + src[at:]
        else:
            src = "import '" + rel + "';\n\n" + src

    open(path, 'w', encoding='utf-8', newline='').write(src)
    print(path + ': wrapped ' + str(wrapped) + ' literals in _en()')


if __name__ == '__main__':
    main()
