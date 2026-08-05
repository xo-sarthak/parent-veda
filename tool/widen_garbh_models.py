"""Widen the copy fields of the Garbh models to LocalizedText.

Only fields a mother READS move. Left as String on purpose:

  id      - identity, looked up and compared
  emoji   - not language
  seconds / scale / minutes / kind - not text

A file, not a heredoc: see tool/merge_garbh.py for why.
"""

import re

PATH = 'lib/models/garbh_content.dart'

# (declaration as it appears, exactly once) -> widened
COPY = [
    'final String title;',
    'final String subtitle;',
    'final String label; // "Breathe in", "Hold", "Breathe out", "Rest"',
    'final String theme; // "Curiosity", "Patience", …',
    'final String blurb; // one-line description on the card',
    'final String body; // the reflection itself',
    'final String reflection; // closing question',
    'final String blurb;',
    'final String text;',
    'final String sloka; // a gentle line (no heavy religious language)',
    'final String meaning; // simple interpretation',
    'final String lesson; // life lesson',
    'final String reflection; // reflection prompt',
    'final String tip; // today\'s nutrition tip (what to do)',
    'final String why; // why it matters',
    'final String recipe; // recommended recipe',
    'final String swap; // food swap',
    'final String habit; // lifestyle habit',
]


def main():
    src = open(PATH, encoding='utf-8').read()
    changed = 0
    for decl in COPY:
        n = src.count(decl)
        if n == 0:
            print('  MISSING: ' + decl)
            continue
        src = src.replace(decl, decl.replace('final String ',
                                             'final LocalizedText ', 1))
        changed += n
    if 'localization/app_language.dart' not in src:
        imports = list(re.finditer(r"^import .*;$", src, re.M))
        at = imports[-1].end()
        src = (src[:at] + "\nimport '../localization/app_language.dart';"
               + src[at:])
    open(PATH, 'w', encoding='utf-8', newline='').write(src)
    print('widened ' + str(changed) + ' field declarations')


if __name__ == '__main__':
    main()
