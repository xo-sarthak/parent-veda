"""The remaining hand fixes across the father screens.

All the same family: resolve_read_sites put `.now` on something that is not
text - a null check, a bool, an int - because the analyzer error on that line
came from somewhere else on it. The tool cannot see that; a person can.

Exact strings, asserted counts, dry-runnable. See tool/fix_father_daily.py for
why this is a file rather than a one-liner.

    python tool/fix_father_rest.py [--dry]
"""

import sys

FIXES = [
    # ---- father_daily_screen -------------------------------------------
    ('lib/screens/father/father_daily_screen.dart', [
        # null checks, not text
        ('_readAloudToday.now == null', '_readAloudToday == null', 1),
        ('today.now == null', 'today == null', 1),
        # a bool
        ('_recording.now', '_recording', 1),
        # identical halves round pure interpolation - never was copy
        ('''_t('“${today.body}”', '“${today.body}”')''',
         "'“${today.body}”'", 1),
    ]),
    # ---- father_journal_screen -----------------------------------------
    ('lib/screens/father/father_journal_screen.dart', [
        # wk is an int; the error on this line came from the _t() after it
        ('wk.now > 0', 'wk > 0', 1),
    ]),
    # ---- father_home_screen --------------------------------------------
    ('lib/screens/father_home_screen.dart', [
        # exact is a bool
        ('exact.now', 'exact', 1),
    ]),
]


def main():
    dry = '--dry' in sys.argv
    for path, fixes in FIXES:
        src = open(path, encoding='utf-8', newline='').read()
        for old, new, want in fixes:
            got = src.count(old)
            if got != want:
                sys.exit(path + ': expected ' + str(want) + ' of '
                         + repr(old[:52]) + ', found ' + str(got))
            src = src.replace(old, new)
        print(path.split('/')[-1] + ': ' + str(len(fixes)) + ' fixes')
        if not dry:
            open(path, 'w', encoding='utf-8', newline='').write(src)
    if dry:
        print('(dry run - nothing written)')


if __name__ == '__main__':
    main()
