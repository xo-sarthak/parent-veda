"""How much English is still untranslated on the pregnancy side?

Written because the question was answered wrong once. can_i_data was reported
finished on the strength of its 283 `LocalizedText(en:, hi:)` pairs — while 302
single-argument `_t('...')` call sites in the same file went on mirroring
English into the Hindi slot, unseen, because the audit looked at the mechanism
it happened to have in hand rather than at the content.

So this counts CONTENT, and it counts a string as translated only when its
Hindi twin actually contains Devanagari. Three bilingual shapes exist in this
codebase and all three are checked:

    _p(en, hi)                    the string table
    _t(en, hi)                    per-file helpers
    LocalizedText(en: …, hi: …)   data models

A literal belonging to none of them is plain `String` content — a file that has
not had its model widened yet — and counts as outstanding.

    python tool/hindi_progress.py            # summary table
    python tool/hindi_progress.py --loose <file>   # list what is outstanding
"""

import glob
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ui_strings import find_calls, find_localized   # noqa: E402

SKIP_DIRS = ('/post_pregnancy/', '/ttc/', '/doctor/', '/enterprise/')
WORD = re.compile(r'[A-Za-z]{3,}')
DEVANAGARI = re.compile('[ऀ-ॿ]')
INTERP = re.compile(r'\$\{[^}]*\}|\$\w+')
IDENT = re.compile(r'^[a-z][a-z0-9_]*$')
# Matches EVERY literal, including one-character ones like '🍍'.
#
# A minimum length here looks like a harmless filter and is not: a short
# literal fails to match, the scanner advances past its opening quote, and the
# next match pairs a CLOSING quote with the following OPENING one — so the gap
# between two strings (", label: ") gets counted as content. Match everything,
# then filter with is_copy().
LITERAL = re.compile(r"""(['"])((?:\\.|(?!\1).)*?)\1""")
UI_SITE = re.compile(
    r"""(?:Text\(|hintText:|labelText:|tooltip:)\s*(['"])"""
    r"""((?:\\.|(?!\1).){3,}?)\1""")


def is_copy(text):
    """Words a person reads — not an id, a path, a url or an interpolation."""
    if DEVANAGARI.search(text) or IDENT.match(text):
        return False
    if text.startswith(('package:', 'http', 'assets/')):
        return False
    if text.endswith(('.dart', '.png', '.jpg', '.json')):
        return False
    return bool(WORD.search(INTERP.sub('', text)))


def audit(path):
    """(translated, pairs still English, loose literals with no pair)."""
    src = open(path, encoding='utf-8').read()
    pairs = []
    for find in (find_localized,
                 lambda s: find_calls(s, marker='_t('),
                 lambda s: find_calls(s, marker='_p(')):
        try:
            pairs.extend(find(src))
        except Exception:
            pass

    covered, done, todo = [], 0, 0
    for c in pairs:
        covered.append(c['en_span'])
        covered.append(c['hi_span'])
        if DEVANAGARI.search(c['hi_src'] or ''):
            done += 1
        else:
            todo += 1

    loose = []
    for m in LITERAL.finditer(src):
        if any(a <= m.start() and m.end() <= b for a, b in covered):
            continue
        if is_copy(m.group(2)):
            loose.append((src.count('\n', 0, m.start()) + 1, m.group(2)))
    return done, todo, loose


def main():
    if '--loose' in sys.argv:
        target = sys.argv[sys.argv.index('--loose') + 1]
        done, todo, loose = audit(target)
        print(f'{target}: {done} translated, {todo} pairs still English, '
              f'{len(loose)} literals with no Hindi slot at all')
        for line, text in loose:
            print(f'  {line:>5}  {text[:96]}')
        return

    print(f'{"file":<32}{"done":>7}{"left":>7}')
    print('-' * 46)
    total_done = total_left = 0
    rows = []
    for path in sorted(glob.glob('lib/data/*.dart')):
        done, todo, loose = audit(path)
        left = todo + len(loose)
        if done + left < 5:
            continue
        rows.append((os.path.basename(path)[:-5], done, left))
        total_done += done
        total_left += left
    for name, done, left in sorted(rows, key=lambda r: -r[2]):
        print(f'{name:<32}{done:>7}{left:>7}')

    ui = 0
    for path in glob.glob('lib/**/*.dart', recursive=True):
        norm = path.replace(os.sep, '/')
        if any(s in norm for s in SKIP_DIRS) or '/data/' in norm:
            continue
        src = open(path, encoding='utf-8').read()
        ui += sum(1 for m in UI_SITE.finditer(src) if is_copy(m.group(2)))

    # The two biggest finished bodies live outside lib/data. Leaving them out
    # of the total would make the percentage a lie in the flattering direction
    # AND the pessimistic one at the same time — a smaller denominator, but
    # none of the work already banked.
    table_done, table_left, _ = audit('lib/localization/app_language.dart')

    week_done = week_total = 0
    try:
        import json
        weeks = json.load(open('lib/data/weekContent.json', encoding='utf-8'))

        def walk(node):
            nonlocal week_done, week_total
            if isinstance(node, dict):
                if set(node) == {'en', 'hi'}:
                    week_total += 1
                    if DEVANAGARI.search(node['hi']):
                        week_done += 1
                    return
                for v in node.values():
                    walk(v)
            elif isinstance(node, list):
                for v in node:
                    walk(v)
        walk(weeks)
    except Exception:
        pass

    print('-' * 46)
    print(f'{"data files":<32}{total_done:>7}{total_left:>7}')
    print(f'{"app_language.dart (string table)":<32}'
          f'{table_done:>7}{table_left:>7}')
    print(f'{"weekContent.json":<32}{week_done:>7}'
          f'{week_total - week_done:>7}')
    print(f'{"UI code (inline literals)":<32}{"":>7}{ui:>7}')
    print('=' * 46)
    done = total_done + table_done + week_done
    left = total_left + table_left + (week_total - week_done) + ui
    pct = 100 * done / max(done + left, 1)
    print(f'{"TOTAL":<32}{done:>7}{left:>7}   ({pct:.0f}% done)')


main()
