"""Content check for ParentVeda copy: copied, AI-sounding, or hard to read.

Usage (from the repo root):
    python -X utf8 tool/content_check/pp_content_check.py lib/screens/post_pregnancy/pp_sleep_content.dart [more files]
    python -X utf8 tool/content_check/pp_content_check.py --all-parenting

What it checks, and why (docs/PARENTING-VOICE.md, the user 2026-10-07: "a
plagiarism check ... so that it doesn't resemble AI or copied, and keep content
language simple to understand and humanised with warmth and comfort"):

  1. COPIED: any run of 8 words shared with What to Expect or theAsianparent, as
     captured on the device walks (Downloads/competitor-walks/*/pages/*.txt).
     The rule the gap analyses set: they show us what to cover, we never copy a
     sentence; no run of eight words may match theirs.
  2. AI TELLS: the banned words and habits of the voice guides (delve, navigate,
     journey as a metaphor, "it's important to note", "rest assured", em dashes
     as punctuation, exclamation marks, "not just X, it's Y" sayings, and so on).
  3. PLAIN LANGUAGE: sentences over 28 words, and a Flesch reading-ease score per
     file (60+ is plain English; under 50 is hard going for a tired parent).
  4. "HIM" ON A DOOR PAGE: door pages are shared by every family, so they say
     "your baby" / "your child", never he or she (the user's pronoun decision).

It reads Dart source, pulls out the English string literals (joining adjacent
literals, which is how long copy is written), and skips ids, keys, routes and
code-ish strings. It never edits anything; it prints a report.
"""
import glob
import os
import re
import sys

WALKS = os.path.expanduser(r'~/Downloads/competitor-walks')
WALK_DIRS = ['wte-parent', 'asianparent-parent', 'wte-preg', 'flo-preg']
N = 8

BANNED = [
    'delve', 'navigate', 'navigating', 'empower', 'embark', 'holistic', 'game-changer', 'game changer',
    'crucial', "you've got this", 'rest assured', 'we understand how you feel', "it's important to note",
    'it is important to note', "it's worth noting", 'it is worth noting', "let's dive in", 'dive into',
    'the single most', 'the one thing nobody tells you', "here's the thing", 'mama', 'mommy', 'momma',
    'miracle', 'magical', "don't worry", 'do not worry', 'journey through', 'your parenting journey',
    'in today\'s', 'landscape', 'tapestry', 'testament to', 'seamless', 'unlock', 'elevate', 'supercharge',
    'bundle of joy', 'supermom', 'mommy brain', 'good baby', 'should be able to', 'advanced for',
    'genuinely', 'truly', 'simply put', 'at the end of the day',
]
SCOREBOARD = ['behind', 'ahead of', 'late talker', 'spoil']
PATTERNS = [
    (re.compile(r"\bit'?s not (just )?\w[\w ]{0,30}, it'?s\b", re.I), '"it\'s not X, it\'s Y" saying'),
    (re.compile(r"\bnot just \w[\w ]{0,30}, but\b", re.I), '"not just X, but Y" saying'),
    (re.compile(r"—|–"), 'em/en dash as punctuation'),
    (re.compile(r"\s-\s"), 'spaced hyphen as a dash'),
    (re.compile(r"!"), 'exclamation mark'),
]
PRONOUN = re.compile(r"\b(he|him|his|himself|she|her|hers|herself)\b", re.I)


def words(t):
    return re.findall(r"[a-z0-9']+", t.lower().replace('’', "'"))


def shingles(ws):
    return {' '.join(ws[i:i + N]) for i in range(len(ws) - N + 1)}


def load_competitors():
    grams = {}
    for d in WALK_DIRS:
        for f in glob.glob(os.path.join(WALKS, d, 'pages', '*.txt')):
            try:
                t = open(f, encoding='utf-8', errors='ignore').read()
            except OSError:
                continue
            for g in shingles(words(t)):
                grams.setdefault(g, f'{d}/{os.path.basename(f)}')
    return grams


LIT = re.compile(r"""(?:r?'((?:[^'\\\n]|\\.)*)'|r?"((?:[^"\\\n]|\\.)*)")""")


def strings_of(path):
    """English copy from a Dart file. Dart writes long copy as adjacent literals
    on consecutive lines with no comma between them; a literal followed by a
    comma (or a bracket) ends one string. Comments are skipped."""
    src = open(path, encoding='utf-8').read()
    # Block comments (/* kept for revert ... */) are not shown to anyone; blank
    # them out, keeping their newlines so line numbers stay true.
    src = re.sub(r'/\*.*?\*/', lambda m: '\n' * m.group(0).count('\n'), src, flags=re.S)
    joined, cur, start = [], '', 0
    for lineno, line in enumerate(src.split('\n'), 1):
        stripped = line.strip()
        if stripped.startswith(('//', 'import ', 'export ', 'part ')):
            if cur:
                joined.append((start, cur))
                cur = ''
            continue
        lits = list(LIT.finditer(line))
        if not lits:
            if cur:
                joined.append((start, cur))
                cur = ''
            continue
        for k, m in enumerate(lits):
            s = (m.group(1) if m.group(1) is not None else m.group(2)) or ''
            s = s.replace("\\'", "'").replace('\\"', '"').replace('\\n', ' ')
            if not cur:
                start = lineno
            cur += s
            tail = line[m.end():].strip()
            # The literal continues only if nothing but whitespace follows it on
            # this line (the next line carries on) or another literal follows.
            if tail and not tail.startswith(("'", '"', "r'", 'r"')):
                joined.append((start, cur))
                cur = ''
    if cur:
        joined.append((start, cur))
    keep = []
    for lineno, s in joined:
        if len(s.split()) < 4:
            continue  # ids, keys, labels
        if re.fullmatch(r"[\w./:\-{}$<>]+", s):
            continue
        keep.append((lineno, s.strip()))
    return keep


def sentences(t):
    return [x.strip() for x in re.split(r"(?<=[.?])\s+", t) if x.strip()]


def syllables(w):
    w = w.lower()
    groups = re.findall(r"[aeiouy]+", w)
    n = len(groups)
    if w.endswith('e') and n > 1 and not w.endswith(('le', 'ee')):
        n -= 1
    return max(1, n)


def flesch(texts):
    ss = [s for t in texts for s in sentences(t)]
    ws = [w for s in ss for w in words(s)]
    if not ss or not ws:
        return None
    syl = sum(syllables(w) for w in ws)
    return 206.835 - 1.015 * (len(ws) / len(ss)) - 84.6 * (syl / len(ws))


def check(path, comp, door_page):
    items = strings_of(path)
    rep = {'copied': [], 'ai': [], 'long': [], 'pronoun': 0, 'strings': len(items)}
    for lineno, s in items:
        low = s.lower()
        hits = [g for g in shingles(words(s)) if g in comp]
        if hits:
            rep['copied'].append((lineno, hits[0], comp[hits[0]]))
        for b in BANNED:
            if re.search(r'\b' + re.escape(b) + r'\b', low):
                rep['ai'].append((lineno, b, s[:90]))
        for rx, name in PATTERNS:
            if rx.search(s):
                rep['ai'].append((lineno, name, s[:90]))
        for sen in sentences(s):
            if len(words(sen)) > 28:
                rep['long'].append((lineno, len(words(sen)), sen[:90]))
        if door_page:
            rep['pronoun'] += len(PRONOUN.findall(s))
    rep['flesch'] = flesch([s for _, s in items])
    return rep


def main(argv):
    if not argv:
        print(__doc__)
        return 2
    if argv == ['--all-parenting']:
        argv = sorted(glob.glob('lib/screens/post_pregnancy/pp_*_content.dart'))
    comp = load_competitors()
    print(f'competitor 8-word runs loaded: {len(comp):,} (from {", ".join(WALK_DIRS)})\n')
    total = {'copied': 0, 'ai': 0, 'long': 0, 'pronoun': 0}
    for f in argv:
        door_page = f.endswith('_content.dart')
        r = check(f, comp, door_page)
        fl = r['flesch']
        print(f'== {f}  strings={r["strings"]}  flesch={fl:.0f}' if fl is not None else f'== {f}')
        print(f'   copied={len(r["copied"])}  ai_tells={len(r["ai"])}  long_sentences={len(r["long"])}'
              + (f'  pronouns_on_door_page={r["pronoun"]}' if door_page else ''))
        for lineno, g, src in r['copied'][:20]:
            print(f'   COPIED  L{lineno}: "{g}"  <- {src}')
        for lineno, what, s in r['ai'][:20]:
            print(f'   AI-TELL L{lineno}: {what}: {s}')
        for lineno, n, s in r['long'][:10]:
            print(f'   LONG    L{lineno} ({n} words): {s}')
        for k in total:
            total[k] += r[k] if k == 'pronoun' else len(r[k])
    print(f'\nTOTAL copied={total["copied"]} ai_tells={total["ai"]} long={total["long"]} door_pronouns={total["pronoun"]}')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
