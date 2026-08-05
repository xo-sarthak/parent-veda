"""Find user-visible English strings that never pass through `S._p`.

The translation passes so far reach content: weekContent.json, the data files
and app_language.dart. None of them reach a string written straight into a
widget, e.g. `Text('Save')`. Those stay English on a Hindi phone, scattered
through screens that are otherwise Devanagari - which reads worse than a
consistently English screen.

This classifies the candidates so the genuinely user-facing ones can be
separated from labels that SHOULD stay English (route names, semantics,
assets).

    python tool/audit_inline_strings.py [--list]
"""

import collections
import glob
import os
import re
import sys

SKIP = ('/post_pregnancy/', '/ttc/', '/doctor/', '/enterprise/',
        '/localization/')

# Text('...') and Text("...") with at least three characters
LITERAL = re.compile(r"""Text\(\s*(['"])((?:\\.|(?!\1).){3,}?)\1\s*[,)]""")
HAS_WORD = re.compile(r'[A-Za-z]{3,}')
DEVANAGARI = re.compile(r'[ऀ-ॿ]')
ALL_CAPS = re.compile(r'^[A-Z0-9_ ]+$')


def surfaces():
    for path in glob.glob('lib/**/*.dart', recursive=True):
        norm = path.replace(os.sep, '/')
        if any(s in norm for s in SKIP):
            continue
        yield path, norm


INTERP = re.compile(r'\$\{[^}]*\}|\$\w+')


def translatable(text):
    """Words remain once interpolations are removed?

    `'${(pct * 100).round()}%'` looks wordy to a naive check but carries no
    copy - the letters are all Dart. Strip the interpolations first.
    """
    return bool(HAS_WORD.search(INTERP.sub('', text)))


def classify(text, line):
    if 'semanticLabel' in line or 'Semantics(' in line:
        return 'semantics'
    if text.startswith('http') or re.search(r'\.(png|jpg|json|svg|wav|mp3)$', text):
        return 'asset/url'
    if ALL_CAPS.fullmatch(text) and len(text) < 12:
        return 'constant'
    return 'USER-VISIBLE'


def main():
    show = '--list' in sys.argv
    buckets = collections.Counter()
    per_file = collections.Counter()
    found = collections.defaultdict(list)

    for path, norm in surfaces():
        src = open(path, encoding='utf-8').read()
        for m in LITERAL.finditer(src):
            text = m.group(2)
            if not translatable(text) or DEVANAGARI.search(text):
                continue
            if text.strip() == 'ParentVeda':
                buckets['brand'] += 1
                continue
            nl = src.find('\n', m.start())
            line = src[src.rfind('\n', 0, m.start()) + 1:nl if nl > 0 else None]
            kind = classify(text, line)
            buckets[kind] += 1
            if kind == 'USER-VISIBLE':
                per_file[norm] += 1
                found[norm].append((src.count('\n', 0, m.start()) + 1, text))

    print('inline Text() literals on pregnancy surfaces')
    for k, v in buckets.most_common():
        print(f'  {k:<14}{v:>5}')
    print(f'\nuser-visible, by file:')
    for f, n in per_file.most_common():
        print(f'  {n:>4}  {f}')
    print(f'\n  {sum(per_file.values())} strings across {len(per_file)} files')

    if show:
        print()
        for f in sorted(found):
            print(f'--- {f}')
            for ln, t in found[f]:
                print(f'  {ln:>5}  {t[:90]}')


main()
