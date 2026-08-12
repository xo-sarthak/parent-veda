"""EVERY language ternary, whatever it is spelled like.

This is the third scanner written for this problem, and the reason is worth
recording rather than quietly fixing.

  scan_live_hinglish.py    found `_t(en, hi)` and `LocalizedText(en:, hi:)`.
                           Reported lib/ clean.
  scan_ternary_pairs.py    found `lang.isEnglish ? en : hi`. Found 43 more.
                           Reported lib/ clean.
  this one                 found `final hinglish = x.isHinglish;` followed by
                           `hinglish ? hi : en` - a local flag, the OPPOSITE
                           polarity, and the Hindi in the FIRST branch.

Each scanner was correct about the shape it knew and silent about the rest, and
each time "clean" meant "clean of the thing I thought to look for". The fix is
not another shape-specific regex. It is to resolve the CONDITION - whatever it
is called - to a polarity, and then look at both branches regardless.

POLARITY MATTERS. `isEnglish ? a : b` puts Hindi in `b`; `isHinglish ? a : b`
puts it in `a`. Getting that backwards would report every correct pair as
broken and every broken pair as correct.

    python tool/scan_lang_ternaries.py
"""

import glob
import io
import os
import re

DEV = re.compile('[ऀ-ॿ]')
LATIN = re.compile(r'[A-Za-z]{3}')
BS = chr(92)
Q1 = "'"
Q2 = '"'
# BOTH quote styles. The single-quote-only version of this regex missed
# `lang.isEnglish ? "You're in week $w" : "Aap week $w mein hain"` - Dart code
# switches to double quotes precisely when the string contains an apostrophe,
# which is exactly where warm English prose lives. The blind spot correlated
# with the content most worth checking.
STR = ("(?:" + Q1 + "(?:[^" + Q1 + BS + BS + "]|" + BS + BS + ".)*" + Q1 +
       "|" + Q2 + "(?:[^" + Q2 + BS + BS + "]|" + BS + BS + ".)*" + Q2 + ")")

# A local boolean assigned from the language: `final hinglish = x.isHinglish;`
LOCAL = re.compile(
    r'(?:final|var|bool)\s+(\w+)\s*=\s*[\w.]*\.(isEnglish|isHinglish|isHindi)\b')

SKIP_DIRS = ('/post_pregnancy/', '/ttc/')
# `hi` is true when the condition is true
HINDI_FIRST = ('isHinglish', 'isHindi')


def conditions(src):
    """name -> True if a true condition means HINDI."""
    out = {'isEnglish': False, 'isHinglish': True, 'isHindi': True}
    for m in LOCAL.finditer(src):
        out[m.group(1)] = m.group(2) in HINDI_FIRST
    return out


def main():
    bad = []
    ok = 0
    for path in glob.glob('lib/**/*.dart', recursive=True):
        path = path.replace(os.sep, '/')
        if any(d in path for d in SKIP_DIRS) or path.startswith('tool/'):
            continue
        src = io.open(path, encoding='utf-8').read()
        conds = conditions(src)
        # any of those names used as a ternary condition on two string literals
        names = '|'.join(re.escape(n) for n in sorted(conds, key=len,
                                                      reverse=True))
        pat = re.compile(r'(?:[\w.]*\.)?(' + names + r')\s*\?\s*(' + STR +
                         r')\s*:\s*(' + STR + r')')
        for m in pat.finditer(src):
            cond, a, b = m.group(1), m.group(2)[1:-1], m.group(3)[1:-1]
            hindi = a if conds.get(cond, False) else b
            other = b if conds.get(cond, False) else a
            line = src.count('\n', 0, m.start()) + 1
            if hindi == other:
                bad.append(('IDENTICAL', path, line, hindi, ''))
            elif not DEV.search(hindi) and LATIN.search(hindi):
                bad.append(('HINGLISH', path, line, other, hindi))
            else:
                ok += 1

    for kind in ('HINGLISH', 'IDENTICAL'):
        rows = [r for r in bad if r[0] == kind]
        print('%s (%d)' % (kind, len(rows)))
        for _k, p, ln, en, hi in rows:
            print('  %s:%d  %r%s' % (p, ln, en[:44],
                                     (' -> %r' % hi[:44]) if hi else ''))
        print()
    print('correctly translated: %d' % ok)


if __name__ == '__main__':
    main()
