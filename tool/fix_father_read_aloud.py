"""Translate the read-aloud TAB LABELS without touching the persisted tags.

The same four strings appear twice in father_read_aloud_screen.dart:

    Tab(text: 'Stories & Fables')     <- copy, a mother/father reads it
    group: 'Stories & Fables'         <- passed to ReadToBabySavedStore as the
                                         `tag`, persisted AND cloud-synced

apply_glossary matches on text, so it would have translated both and split
every saved collection in two: items saved from the father's door would carry
the Hindi tag and the same items saved from the mother's Samvad the English
one, because garbh_screen.dart passes these exact English literals too.

So this is a targeted edit, not a glossary run. The tabs use the S-table
wordings so the two doors read identically.

    python tool/fix_father_read_aloud.py [--dry]
"""

import re
import sys

PATH = 'lib/screens/father/father_read_aloud_screen.dart'

TABS = [
    ('Affirmations & Blessings', 'संकल्प और आशीर्वाद'),
    ('Stories & Fables', 'कहानियाँ और नीति-कथाएँ'),
    ('Mantras & Lullabies', 'मंत्र और लोरियाँ'),
    ('Spiritual Reading', 'आध्यात्मिक पाठ'),
]

HELPER = ('LocalizedText _t(String en, String hi) =>\n'
          '    LocalizedText(en: en, hi: hi);\n\n')


def main():
    dry = '--dry' in sys.argv
    src = open(PATH, encoding='utf-8', newline='').read()

    for en, hi in TABS:
        old = "Tab(text: '" + en + "')"
        if src.count(old) != 1:
            sys.exit('expected exactly one ' + repr(old) + ', found '
                     + str(src.count(old)))
        src = src.replace(old, "Tab(text: _t('" + en + "', '" + hi + "').now)")

    # The `group:` literals must survive untouched - that is the whole point.
    for en, _ in TABS:
        if "group: '" + en + "'" not in src and en != 'Spiritual Reading':
            sys.exit('a group: tag for ' + en + ' went missing')

    if 'LocalizedText _t(' not in src:
        anchor = re.search(r'^(class |const |final )', src, re.M)
        src = src[:anchor.start()] + HELPER + src[anchor.start():]
    if 'localization/app_language.dart' not in src:
        imports = list(re.finditer(r"^import .*;$", src, re.M))
        at = imports[-1].end()
        src = (src[:at] + "\nimport '../../localization/app_language.dart';"
               + src[at:])

    print(PATH.split('/')[-1] + ': 4 tab labels translated, '
          'group: tags left English')
    if dry:
        print('(dry run - nothing written)')
        return
    open(PATH, 'w', encoding='utf-8', newline='').write(src)


if __name__ == '__main__':
    main()
