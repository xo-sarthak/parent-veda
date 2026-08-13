"""ONE scanner for Latin-script Hinglish, replacing four shape-specific ones.

WHY THIS EXISTS. Four scanners were written for this problem and each declared
the codebase clean while the next found more:

    scan_live_hinglish.py    `_t(en,hi)`, `LocalizedText(en:,hi:)`   said clean
    scan_ternary_pairs.py    `lang.isEnglish ? en : hi`             said clean
    scan_lang_ternaries.py   any language condition, both polarities said clean
    hindi_audit.py           JSON bodies + `_p()` in the S table     said clean

They were all correct about the shapes they knew. A shape-aware scanner is only
ever as complete as the list of shapes somebody thought of, so "clean" always
meant "clean of the thing I looked for". The last audit found ~337 more strings
across five further shapes, 188 of them in one file, hidden because
scan_live_hinglish matched SINGLE-quoted literals only - and Dart switches to
double quotes exactly when a string contains an apostrophe, which is where warm
English prose lives. scan_lang_ternaries had already documented that trap and
the fix was never carried back.

So this is built from three primitives instead of a shape list:

  1. A string EXPRESSION is `LITERAL (whitespace LITERAL)*` in BOTH quote
     styles. Dart concatenates adjacent literals, so `_p('one ' 'two', 'ek ' 'do')`
     is two arguments and four literals; a regex expecting one quoted run per
     argument sees `' '` where it wants a comma and the match dies. This alone
     hid 25+ strings.

  2. Helper names and flag names are DISCOVERED, not listed. A screen that
     invents `_tr(String en, String hin)` or `bool get _e => lang.isEnglish`
     is invisible to anything hard-coding `_t(` or scanning only for local
     `final x = ....isEnglish`. Both happened.

  3. The test is on the Hindi BRANCH, not the Hindi LITERAL. A branch can be a
     list, a named argument, or the THIRD positional argument
     (`ep(lang, en, hi)`), none of which look like "argument 2 of a pair".

    python tool/hinglish.py            # summary by shape and file
    python tool/hinglish.py --list     # every finding
    python tool/hinglish.py --tsv OUT  # worklist: file, start, end, EMPTY, en, hi
"""

import glob
import io
import os
import re
import sys

DEV = re.compile('[ऀ-ॿ]')
LATIN = re.compile(r'[A-Za-z]{3}')
BS = chr(92)
Q1 = "'"
Q2 = '"'

# --- primitive 1: a string expression, both quote styles, adjacent literals ---
_SINGLE = Q1 + '(?:[^' + Q1 + BS + BS + ']|' + BS + BS + '.)*' + Q1
_DOUBLE = Q2 + '(?:[^' + Q2 + BS + BS + ']|' + BS + BS + '.)*' + Q2
LITERAL = '(?:' + _SINGLE + '|' + _DOUBLE + ')'
EXPR = LITERAL + r'(?:\s*' + LITERAL + r')*'

_LIT_RE = re.compile(LITERAL)

SKIP_DIRS = ('/post_pregnancy/', '/ttc/')
SKIP_FILES = ('weekContent.hinglish.json', 'weekContent_week5_original.json')

# Fields whose contents code MATCHES rather than renders. Hinglish there is
# deliberate - a mother typing `kamar dard` must still find her symptom.
READ_NOT_RENDERED = re.compile(r'\b(keywords|aliases|synonyms)\s*:')


def text_of(expr):
    """Concatenated value of a Dart string expression."""
    return ''.join(m.group(0)[1:-1] for m in _LIT_RE.finditer(expr))


# A Hindi branch made only of interpolation is already correct - it just looks
# Latin. `'${m.facts[1].big.hi} · ${m.facts[1].small.hi}'` reads every field from
# the Hindi side and has no prose of its own. Offering it as work wastes a
# translator's time and, worse, invites someone to "translate" an expression.
INTERP = re.compile(r'\$\{[^}]*\}|\$[A-Za-z_][A-Za-z0-9_]*')


def is_interpolation_only(s):
    return not LATIN.search(INTERP.sub(' ', s))


def is_hinglish(s):
    if not s.strip() or is_interpolation_only(s):
        return False
    return not DEV.search(s) and bool(LATIN.search(s))


# --- primitive 2: discover the helpers and flags this file defines ------------
# The PARAMETER NAMES have to say this is a language pair. Matching any two
# consecutive `String` parameters looked more general and was simply wrong: it
# discovered `_kv(String k, String v)`, `_stat(String value, String label)` and
# `_upload(String title, String hint)` as bilingual helpers, and every call site
# became a "finding". A worklist built from that would have handed a translator
# a key-value pair and asked for the value in Hindi.
#
# Generality has to come from somewhere the meaning actually lives. Here it is
# the names: a bilingual helper in this codebase always calls its first argument
# `en` and its second some spelling of Hindi.
HELPER = re.compile(
    r'\b(?:String|Widget|Text|LocalizedText)\s+(\w+)\('
    r'\s*(?:BuildContext\s+\w+\s*,\s*)?'
    r'(?:AppLanguage\s+(\w+)\s*,\s*)?'
    r'String\s+(en|english)\s*,\s*String\s+(hi|hin|hindi|hinglish)\s*[,)]',
    re.I)

FLAG = re.compile(
    r'\b(?:final|var|bool)\s+(\w+)\s*=\s*[\w.]*\.(isEnglish|isHinglish|isHindi)\b'
    r'|\bbool\s+get\s+(\w+)\s*=>\s*[\w.]*\.(isEnglish|isHinglish|isHindi)\b')

HINDI_TRUE = ('isHinglish', 'isHindi')


def helpers(src):
    """name -> index of the Hindi argument (0-based, among String args)."""
    out = {}
    for m in HELPER.finditer(src):
        name, langarg = m.group(1), m.group(2)
        # `ep(lang, en, hi)` puts the pair at args 2 and 3.
        out[name] = 1 if langarg is None else 2
    return out


def flags(src):
    """name -> True when a true condition means HINDI."""
    out = {'isEnglish': False, 'isHinglish': True, 'isHindi': True}
    for m in FLAG.finditer(src):
        name = m.group(1) or m.group(3)
        prop = m.group(2) or m.group(4)
        out[name] = prop in HINDI_TRUE
    return out


def findings_for(path, src):
    """(shape, start, end, english, hindi) for every Hinglish Hindi-branch."""
    out = []
    seen = set()

    def add(shape, hi_span, en_txt, hi_txt):
        if hi_span in seen:
            return
        seen.add(hi_span)
        out.append((shape, hi_span[0], hi_span[1], en_txt, hi_txt))

    # -- named pair: LocalizedText(en:, hi:) / _t(en, hi) --------------------
    named = re.compile(r'(?:LocalizedText\(\s*en:\s*|_t\(\s*)(' + EXPR +
                       r')\s*,\s*(?:hi:\s*)?(' + EXPR + r')')
    for m in named.finditer(src):
        en, hi = text_of(m.group(1)), text_of(m.group(2))
        if en != hi and is_hinglish(hi):
            add('named pair', m.span(2), en, hi)

    # -- xEn: / xHi: named arguments ----------------------------------------
    sub = re.compile(r'(\w+)En:\s*(' + EXPR + r')\s*,\s*\1Hi:\s*(' + EXPR + r')')
    for m in sub.finditer(src):
        en, hi = text_of(m.group(2)), text_of(m.group(3))
        if en != hi and is_hinglish(hi):
            add('xEn/xHi args', m.span(3), en, hi)

    # -- discovered two-arg helpers, incl. ep(lang, en, hi) ------------------
    for name, hi_idx in helpers(src).items():
        if hi_idx == 1:
            pat = re.compile(r'\b' + re.escape(name) + r'\(\s*(' + EXPR +
                             r')\s*,\s*(' + EXPR + r')\s*[,)]')
            g_en, g_hi = 1, 2
        else:
            pat = re.compile(r'\b' + re.escape(name) + r'\(\s*\w+\s*,\s*(' +
                             EXPR + r')\s*,\s*(' + EXPR + r')\s*[,)]')
            g_en, g_hi = 1, 2
        for m in pat.finditer(src):
            en, hi = text_of(m.group(g_en)), text_of(m.group(g_hi))
            if en != hi and is_hinglish(hi):
                add('helper %s()' % name, m.span(g_hi), en, hi)

    # -- primitive 3: ternary on any discovered flag, either polarity --------
    fl = flags(src)
    names = '|'.join(re.escape(n) for n in sorted(fl, key=len, reverse=True))
    tern = re.compile(r'(?:[\w.]*\.)?(' + names + r')\s*\?\s*(' + EXPR +
                      r')\s*:\s*(' + EXPR + r')')
    for m in tern.finditer(src):
        hindi_first = fl.get(m.group(1), False)
        hg, eg = (2, 3) if hindi_first else (3, 2)
        en, hi = text_of(m.group(eg)), text_of(m.group(hg))
        if en != hi and is_hinglish(hi):
            add('ternary', m.span(hg), en, hi)

    # -- list-valued branches: the branch is a list, not a literal ----------
    lst = re.compile(r'(?:[\w.]*\.)?(' + names + r')\s*\?\s*(const\s*)?\[(.*?)\]'
                     r'\s*:\s*(const\s*)?\[(.*?)\]', re.S)
    for m in lst.finditer(src):
        hindi_first = fl.get(m.group(1), False)
        hg, eg = (3, 5) if hindi_first else (5, 3)
        items = list(_LIT_RE.finditer(m.group(hg)))
        base = m.start(hg)
        for it in items:
            hi = it.group(0)[1:-1]
            if is_hinglish(hi):
                add('list branch', (base + it.start() + 1, base + it.end() - 1),
                    '', hi)
    return out


def main():
    want_list = '--list' in sys.argv
    tsv = None
    if '--tsv' in sys.argv:
        tsv = sys.argv[sys.argv.index('--tsv') + 1]

    by_shape, by_file, rows = {}, {}, []
    for path in glob.glob('lib/**/*.dart', recursive=True):
        path = path.replace(os.sep, '/')
        if any(d in path for d in SKIP_DIRS):
            continue
        if os.path.basename(path) in SKIP_FILES:
            continue
        src = io.open(path, encoding='utf-8').read()
        for shape, a, b, en, hi in findings_for(path, src):
            line_start = src.rfind('\n', 0, a) + 1
            if READ_NOT_RENDERED.search(src[max(0, a - 400):a]):
                continue          # keywords:/aliases: — matched, not rendered
            by_shape[shape] = by_shape.get(shape, 0) + 1
            by_file[path] = by_file.get(path, 0) + 1
            rows.append((path, a, b, en, hi,
                         src.count('\n', 0, a) + 1))

    print('%-24s %6s' % ('shape', 'n'))
    print('-' * 32)
    for s, n in sorted(by_shape.items(), key=lambda x: -x[1]):
        print('%-24s %6d' % (s, n))
    print('-' * 32)
    print('%-24s %6d' % ('TOTAL', sum(by_shape.values())))
    print()
    for f, n in sorted(by_file.items(), key=lambda x: -x[1])[:12]:
        print('  %-56s %4d' % (f, n))

    if want_list:
        print()
        for p, a, b, en, hi, ln in rows:
            print('  %s:%d\n     %r\n  -> %r' % (p, ln, en[:60], hi[:60]))

    if tsv:
        with io.open(tsv, 'w', encoding='utf-8', newline='') as fh:
            for p, a, b, en, hi, _ln in rows:
                fh.write('%s\t%d\t%d\t\t%s\t%s\n'
                         % (p, a, b,
                            en.replace('\t', ' ').replace('\n', BS + 'n'),
                            hi.replace('\t', ' ').replace('\n', BS + 'n')))
        print('\n%d rows -> %s' % (len(rows), tsv))


if __name__ == '__main__':
    main()
