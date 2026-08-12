"""Bilingual pairs written as a TERNARY, which no other audit here sees.

    lang.isEnglish ? 'Mom' : 'Maa'        <- Latin-script Hinglish, shipping
    lang.isEnglish ? 'Scans' : 'Scans'    <- identical branches: Hindi shows English

tool/scan_live_hinglish.py reported lib/ clean. It was wrong, and the reason is
worth stating plainly: it looked for `_t(...)` and `LocalizedText(en:, hi:)`,
because those are how this codebase pairs languages - except where it doesn't.
A ternary on `isEnglish` is a third way, it predates the helpers, and it is
invisible to every tool written since.

Found by opening the app on a phone and reading the screen. That is the part
worth keeping: three separate scanners agreed the work was finished, and a
screenshot disagreed in ten seconds.

Two failure kinds, both silent:

    HINGLISH   the second branch is Latin-script Hindi - the dropped house
               style, and unreadable by the hi-IN narration voice
    IDENTICAL  both branches are the same string, so the Hindi build renders
               English and every pair-counting audit calls it finished

    python tool/scan_ternary_pairs.py
"""

import glob
import io
import os
import re

DEV = re.compile('[ऀ-ॿ]')
LATIN = re.compile(r'[A-Za-z]{3}')
BS = chr(92)
STR = "'(?:[^'" + BS + BS + "]|" + BS + BS + ".)*'"
TERNARY = re.compile(
    r'(?:\w+\.)?(?:lang|_lang|language)\.isEnglish\s*\?\s*(' + STR +
    r')\s*:\s*(' + STR + r')')

SKIP_DIRS = ('/post_pregnancy/', '/ttc/')


def main():
    identical, hinglish, fine = [], [], 0
    for path in glob.glob('lib/**/*.dart', recursive=True):
        path = path.replace(os.sep, '/')
        if any(d in path for d in SKIP_DIRS):
            continue
        src = io.open(path, encoding='utf-8').read()
        for m in TERNARY.finditer(src):
            en, hi = m.group(1)[1:-1], m.group(2)[1:-1]
            line = src.count('\n', 0, m.start()) + 1
            if en == hi:
                identical.append((path, line, en))
            elif not DEV.search(hi) and LATIN.search(hi):
                hinglish.append((path, line, en, hi))
            else:
                fine += 1

    print('IDENTICAL branches - the Hindi build shows English (%d)'
          % len(identical))
    for p, ln, s in identical:
        print('  %s:%d  %r' % (p, ln, s))
    print()
    print('LATIN-SCRIPT HINGLISH in the Hindi branch (%d)' % len(hinglish))
    for p, ln, en, hi in hinglish:
        print('  %s:%d  %r -> %r' % (p, ln, en, hi))
    print()
    print('properly translated ternaries: %d' % fine)


if __name__ == '__main__':
    main()
