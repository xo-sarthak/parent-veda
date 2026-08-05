"""Fold an English->Hindi glossary into a data file as `_t(en, hi)` pairs.

The bucket-2 data files hold plain `String` content, so a translation cannot
simply overwrite the text — that would delete the English app. Each literal
becomes a bilingual pair instead, and the field type widens to LocalizedText.

This does the CONTENT half, which is mechanical and identical every time. The
model half (field types, read sites) stays hand-done per file, because that is
where the judgement is: which fields are user-visible copy and which are ids,
prefixes other code does surgery on, or values a test pins.

    python tool/apply_glossary.py <file.dart> <glossary.tsv> [--dry]

Refuses nothing and skips silently nowhere: every literal it did NOT convert is
reported, so a missing translation is visible rather than assumed absent.
"""

import os
import re
import sys

LITERAL = re.compile(r"""(?<!_t\()(['"])((?:\\.|(?!\1).){2,}?)\1""")
HAS_WORD = re.compile(r'[A-Za-z]{3,}')
DEVANAGARI = re.compile(r'[ऀ-ॿ]')
IDENT = re.compile(r'^[a-z][a-z0-9_]*$')


def unescape(s, quote):
    return (s.replace('\\' + quote, quote)
             .replace('\\n', '\n')
             .replace('\\' + '\\', '\\'))


def literal(text, quote="'"):
    return quote + (text.replace('\\', '\\\\')
                        .replace(quote, '\\' + quote)
                        .replace('\n', '\\n')) + quote


def skip(text):
    """Not copy: ids, paths, urls, bare numbers, already-Hindi."""
    return (not HAS_WORD.search(text)
            or DEVANAGARI.search(text)
            or IDENT.match(text)
            or text.startswith(('package:', 'http', 'assets/'))
            or text.endswith(('.dart', '.png', '.jpg', '.json')))


def main():
    path, tsv = sys.argv[1], sys.argv[2]
    dry = '--dry' in sys.argv

    glossary = {}
    for line in open(tsv, encoding='utf-8'):
        line = line.rstrip('\n')
        if not line.strip() or line.startswith('#'):
            continue
        en, _, hi = line.partition('\t')
        if hi.strip():
            glossary[en.strip()] = hi.strip()

    src = open(path, encoding='utf-8').read()
    hit, unmatched = [], []

    def one(m):
        quote, raw = m.group(1), m.group(2)
        text = unescape(raw, quote)
        if skip(text):
            return m.group(0)
        # A TSV cannot hold a real newline, so a glossary written by hand keys
        # multi-line copy on the ESCAPED form. Try the unescaped text first,
        # then the raw source form.
        hi = glossary.get(text) or glossary.get(raw)
        if hi is None:
            unmatched.append(text)
            return m.group(0)
        hit.append(text)
        return f'_t({quote}{raw}{quote}, {literal(hi)})'

    out = LITERAL.sub(one, src)

    print(f'{path}')
    print(f'  glossary entries : {len(glossary)}')
    print(f'  literals matched : {len(hit)}')
    print(f'  literals UNMATCHED: {len(unmatched)}')
    for t in unmatched[:15]:
        print(f'      {t[:88]}')
    if len(unmatched) > 15:
        print(f'      ... and {len(unmatched) - 15} more')

    if dry:
        print('  (dry run — nothing written)')
        return

    # `_t` is a function call, so a const collection holding one must relax to
    # `final`. ONLY top-level declarations qualify: an earlier version matched
    # `const` anywhere, which rewrote `this.testimonials = const []` — a
    # default parameter value — into `final []`, and that is not Dart at all.
    #
    # Everything else that const-breaks is left to the analyzer, which names
    # each site precisely. A loud failure beats a clever rewrite here.
    out = re.sub(r'^const (?=(?:Map|List|Set)<)', 'final ', out, flags=re.M)

    if 'LocalizedText _t(' not in out:
        anchor = re.search(r'^(class |enum |const |final |List<|Map<)', out,
                           re.M)
        at = anchor.start() if anchor else 0
        out = (out[:at]
               + 'LocalizedText _t(String en, String hi) => '
                 'LocalizedText(en: en, hi: hi);\n\n'
               + out[at:])

    if 'localization/app_language.dart' not in out:
        rel = os.path.relpath('lib/localization/app_language.dart',
                              os.path.dirname(path)).replace(os.sep, '/')
        imports = list(re.finditer(r"^import .*;$", out, re.M))
        at = imports[-1].end() if imports else 0
        out = out[:at] + f"\nimport '{rel}';" + out[at:]

    open(path, 'w', encoding='utf-8', newline='').write(out)
    print('  written — now widen the field types and fix read sites')


main()
