"""`_t(x, x)` -> `_same(x)`, adding the helper where a file lacks it.

CLAUDE.md: "Never write `_t(x, x)`. An identical pair reads as finished work to
anything counting pairs, which is how can_i_data was once reported done with
302 strings still English."

That is exactly what happened again. The audit reported 233 "hollow pairs" -
pairs whose Hindi half is Latin - and 230 of them turned out to be identical
halves: 'ComfyBump Full-Body Pillow', 'Hb (Haemoglobin)', 'Birth Confidence
Masterclass'. Proper nouns and things printed on a report, correctly Latin, and
finished. They were wearing the marker for unfinished work.

The three markers, and why the distinction is not cosmetic:

    _t(en, hi)   a real translation
    _same(s)     identical in both BY NATURE - a brand, a drug name, an acronym
    _en(s)       English for now, Hindi owed - a greppable backlog

An audit that cannot tell _same from _en cannot tell finished from outstanding,
so its total is not a number anyone can act on. After this pass, "hollow pair"
means only genuinely-unfinished work.

Rewrites by BYTE SPAN, descending, so no offset shifts under us.

    python tool/same_ify.py --dry
    python tool/same_ify.py
"""

import glob
import io
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from unwrap_t import calls   # noqa: E402

HELPER = (
    "/// Identical in both languages BY NATURE - a brand, a drug name printed on\n"
    "/// a packet, an acronym a mother reads in Latin either way. Distinct from\n"
    "/// `_en()`, which means 'English for now, Hindi owed'. This one is finished\n"
    "/// work, and saying so is what keeps tool/hindi_audit.py honest.\n"
    "LocalizedText _same(String s) => LocalizedText(en: s, hi: s);\n"
)


def main():
    dry = '--dry' in sys.argv
    total = 0
    for path in sorted(glob.glob('lib/data/*.dart')) + \
            sorted(glob.glob('lib/data/father/*.dart')):
        src = io.open(path, encoding='utf-8').read()
        hits = []
        for start, end, args in calls(src, '_t('):
            if len(args) != 2:
                continue
            a = src[args[0][0]:args[0][1]].strip()
            b = src[args[1][0]:args[1][1]].strip()
            if a == b and a.startswith(("'", '"')):
                hits.append((start, end, a))
        if not hits:
            continue

        out = src
        for start, end, a in sorted(hits, reverse=True):
            out = out[:start] + '_same(' + a + ')' + out[end:]

        if not re.search(r'LocalizedText _same\(String', out):
            # Insert AFTER the whole `_t` declaration, which in Dart may span
            # lines:
            #
            #     LocalizedText _t(String en, [String? hi]) =>
            #         LocalizedText(en: en, hi: hi ?? en);
            #
            # Anchoring on the first LINE put the new helper between the `=>`
            # and its body, which orphaned the body and broke the file. Match to
            # the terminating `;` instead - the statement, not the line.
            m = re.search(r'LocalizedText _t\(.*?;', out, re.S)
            if m:
                out = out[:m.end()] + '\n\n' + HELPER.rstrip('\n') + out[m.end():]
            else:
                print('  !! %s has no _t helper to sit beside - SKIPPED'
                      % os.path.basename(path))
                continue

        print('%-32s %4d' % (os.path.basename(path), len(hits)))
        total += len(hits)
        if not dry:
            io.open(path, 'w', encoding='utf-8', newline='\n').write(out)

    print('\n%s %d pairs' % ('WOULD CONVERT' if dry else 'CONVERTED', total))


if __name__ == '__main__':
    main()
