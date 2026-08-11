"""Pick the longest multi-paragraph Hindi read, for the audio pilot.

A FILE because the inline version kept losing its backslashes to the shell:
`'\\n\\n'` in a quoted heredoc arrives as two real newlines, which the Dart
source does not contain, so every match silently failed.
"""

import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from unwrap_t import calls   # noqa: E402

DEV = re.compile('[ऀ-ॿ]')
BREAK = chr(92) + 'n' + chr(92) + 'n'      # the two-character escape, twice


def main():
    best = None
    for path in ('lib/data/garbh_data.dart', 'lib/data/read_to_baby_data.dart',
                 'lib/data/spiritual_reading_data.dart'):
        src = open(path, encoding='utf-8').read()
        for _s, _e, args in calls(src, '_t('):
            if len(args) != 2:
                continue
            raw = src[args[1][0]:args[1][1]].strip()
            if not DEV.search(raw) or raw.count(BREAK) < 2:
                continue
            if best is None or len(raw) > len(best[1]):
                best = (path, raw)
    if not best:
        sys.exit('no multi-paragraph Devanagari passage found')

    path, raw = best
    os.makedirs('build/audio', exist_ok=True)
    json.dump({'source': path, 'text': raw},
              open('build/audio/_passage.json', 'w', encoding='utf-8'),
              ensure_ascii=False, indent=1)
    print(os.path.basename(path) + ': ' + str(len(raw)) + ' raw chars, '
          + str(raw.count(BREAK) + 1) + ' paragraphs')


if __name__ == '__main__':
    main()
