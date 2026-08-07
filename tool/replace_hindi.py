"""Replace the Hindi half of an existing `_t(en, hi)` pair.

Distinct from both siblings, and the distinction is the whole reason this file
exists:

    apply_glossary   a bare literal        -> _t(en, hi)      (wrap)
    fill_single_t    _t('en')              -> _t(en, hi)      (add an argument)
    replace_hindi    _t(en, OLD)           -> _t(en, NEW)     (overwrite one)

Used for content that was already bilingual but whose Hindi half is written in
the dropped Latin-script Hinglish. Nothing is missing there, which is why every
pair-counting audit called those files finished.

The TSV may carry a third column (the old Hinglish, kept as a translator's
hint). It is read and ignored.

    python tool/replace_hindi.py <file.dart> <table.tsv> [--dry]
"""

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from apply_glossary import literal, unescape, unescape_tsv   # noqa: E402
from unwrap_t import calls                                   # noqa: E402

BACKSLASH = chr(92)

LIT = re.compile(r"(['\"])((?:\\.|(?!\1).)*?)\1")


def joined(src, span):
    """The text of an argument, joining any adjacent literals as Dart does."""
    return ''.join(unescape(m.group(2), m.group(1))
                   for m in LIT.finditer(src[span[0]:span[1]]))


def main():
    path, tsv = sys.argv[1], sys.argv[2]
    dry = '--dry' in sys.argv

    table = {}
    for line in open(tsv, encoding='utf-8'):
        line = line.rstrip('\n')
        if not line.strip() or line.startswith('#'):
            continue
        cols = line.split('\t')
        if len(cols) < 2 or not cols[1].strip():
            continue
        # extract_hinglish wrote the RAW literal body, so a quote escaped in
        # Dart source (`don\'t`) is still escaped here, while joined() below
        # unescapes it. Normalise the key so the two meet. Fixing it here
        # rather than in the extractor on purpose: the translations are keyed
        # to the file as it was handed out, and regenerating it would throw
        # them away to fix one row.
        key = unescape_tsv(cols[0]).replace(BACKSLASH + "'", "'") \
                                   .replace(BACKSLASH + '"', '"')
        table[key] = unescape_tsv(cols[1])

    src = open(path, encoding='utf-8').read()
    done, missing = 0, []

    # Back-to-front so earlier offsets stay valid.
    for start, end, args in reversed(calls(src, '_t(')):
        if len(args) != 2:
            continue
        en = joined(src, args[0])
        hi = table.get(en)
        if hi is None:
            continue
        # Replace ONLY the second argument; the English half keeps the
        # author's own line breaks.
        src = src[:args[1][0]] + ' ' + literal(hi) + src[args[1][1]:]
        done += 1

    for en in table:
        if en not in [joined(src, a[0]) for _s, _e, a in calls(src, '_t(')
                      if len(a) == 2]:
            missing.append(en)

    print(path)
    print('  replaced        : ' + str(done) + ' of ' + str(len(table)))
    print('  keys not found  : ' + str(len(missing)))
    for m in missing[:8]:
        print('      ' + m[:84])
    if dry:
        print('  (dry run - nothing written)')
        return
    open(path, 'w', encoding='utf-8', newline='').write(src)


if __name__ == '__main__':
    main()
