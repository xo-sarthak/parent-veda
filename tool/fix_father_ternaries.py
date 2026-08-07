"""Resolve ternaries whose branches are `_t(...)` but whose target is String.

`Text(cond ? _t(a, b) : _t(c, d))` type-checks as LocalizedText and Text wants
a String. resolve_read_sites cannot fix this: the error points at the CONDITION
(the start of the expression), so appending there put `.now` on a bool or a
null check instead - which is how `_recording.now` and `wk.now > 0` happened.

The suffix belongs on each branch. And where a branch's two halves are
identical - pure interpolation, no words - it should never have been a pair at
all, so it is unwrapped instead.

    python tool/fix_father_ternaries.py [--dry]
"""

import sys

D = 'lib/screens/father/father_daily_screen.dart'
H = 'lib/screens/father_home_screen.dart'

FIXES = [
    # Identical halves round pure interpolation - not copy.
    (D, """_t('“${_readAloudToday!.body}”', '“${_readAloudToday!.body}”')""",
     "'“${_readAloudToday!.body}”'", 1),
    # Both branches of a Text() ternary; matched on the tail so the Hindi
    # wording does not have to be repeated here (it is 'चुन लीजिए।', not
    # 'चुनिए।' - guessing at it is what made the first attempt miss).
    (D, "कुछ पंक्तियाँ चुन लीजिए।')", "कुछ पंक्तियाँ चुन लीजिए।').now", 2),
    # The record block: three branches, each needs resolving.
    (D, "? _t('Recording… tap to stop', 'रिकॉर्ड हो रहा है… रोकने के लिए टैप करें')",
     "? _t('Recording… tap to stop', 'रिकॉर्ड हो रहा है… रोकने के लिए टैप करें').now", 1),
    (D, "? _t('Saved · tap to re-record', 'सेव हो गया · दोबारा रिकॉर्ड करने के लिए टैप करें')",
     "? _t('Saved · tap to re-record', 'सेव हो गया · दोबारा रिकॉर्ड करने के लिए टैप करें').now", 1),
    (D, ": _t('Tap to record your voice', 'अपनी आवाज़ रिकॉर्ड करने के लिए टैप करें')",
     ": _t('Tap to record your voice', 'अपनी आवाज़ रिकॉर्ड करने के लिए टैप करें').now", 1),
    # The preview bar is PROTOTYPE-ONLY debug copy with identical halves.
    (H, "_t('day $activeDay of 280', 'day $activeDay of 280')",
     "'day $activeDay of 280'", 1),
]


def main():
    dry = '--dry' in sys.argv
    for path in {f[0] for f in FIXES}:
        src = open(path, encoding='utf-8', newline='').read()
        n = 0
        for p, old, new, want in FIXES:
            if p != path:
                continue
            got = src.count(old)
            if got != want:
                sys.exit(path + ': expected ' + str(want) + ' of '
                         + repr(old[:56]) + ', found ' + str(got))
            src = src.replace(old, new)
            n += 1
        print(path.split('/')[-1] + ': ' + str(n) + ' fixes')
        if not dry:
            open(path, 'w', encoding='utf-8', newline='').write(src)
    if dry:
        print('(dry run - nothing written)')


if __name__ == '__main__':
    main()
