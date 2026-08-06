"""Give a single-argument `_t('English')` its Hindi second argument.

Some files were built bilingual from the start but with a MIRROR helper:

    LocalizedText _t(String s) => LocalizedText(en: s, hi: s);

Every call is structurally a bilingual pair and semantically English twice.
can_i_data.dart has 302 of them, and they are exactly why an early audit
reported that file finished: it counted pairs, and a mirror is a pair.

apply_glossary is the wrong tool here. It WRAPS a bare literal into a new
`_t(en, hi)`, which in a file like this produces `LocalizedText(en: _t('Stress',
'तनाव'), hi: 'तनाव')` - a bilingual pair nested inside the `en:` slot of another
one, against a helper that only takes one argument. 430 of those landed before
the analyzer stopped it.

What is actually needed is to FILL the second argument, leaving every existing
`LocalizedText(en:, hi:)` pair untouched.

    python tool/fill_single_t.py <file.dart> <glossary.tsv> [--dry]
"""

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from apply_glossary import (comment_spans, in_any, literal,   # noqa: E402
                            load, unescape)

# `_t(` followed by ONE literal (possibly a run of adjacent ones) and a close
# paren. A two-argument call has a comma at depth 1 and will not match.
CALL = re.compile(
    r"_t\(\s*((?:(['\"])(?:\\.|(?!\2).)*?\2\s*)+)\)")


def main():
    path, tsv = sys.argv[1], sys.argv[2]
    dry = '--dry' in sys.argv
    glossary = load(tsv)
    src = open(path, encoding='utf-8').read()
    comments = comment_spans(src)

    filled, missing = [], []

    def one(m):
        if in_any(m.start(), comments):
            return m.group(0)
        raw = m.group(1).strip()
        # Join the run the way Dart does, then unescape for lookup.
        parts = re.findall(r"(['\"])((?:\\.|(?!\1).)*?)\1", raw)
        text = ''.join(unescape(p[1], p[0]) for p in parts)
        hi = glossary.get(text)
        if hi is None:
            missing.append(text)
            return m.group(0)
        filled.append(text)
        return '_t(' + raw + ', ' + literal(hi) + ')'

    out = CALL.sub(one, src)

    # The helper must accept the second argument. Optional, so any call this
    # run could not fill still compiles and still reads as English-only.
    out = out.replace(
        'LocalizedText _t(String s) => LocalizedText(en: s, hi: s);',
        'LocalizedText _t(String en, [String? hi]) =>\n'
        '    LocalizedText(en: en, hi: hi ?? en);')

    print(path)
    print('  filled   : ' + str(len(filled)))
    print('  no Hindi : ' + str(len(missing)))
    for t in missing[:10]:
        print('      ' + t[:84])
    if dry:
        print('  (dry run - nothing written)')
        return
    open(path, 'w', encoding='utf-8', newline='').write(out)


if __name__ == '__main__':
    main()
