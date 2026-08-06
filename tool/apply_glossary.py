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

# Matches EVERY literal, including one-character ones like '🔤'.
#
# The {2,} minimum this used to carry looked like a harmless filter and was
# not. A one-character literal fails to match, the scanner advances past its
# OPENING quote, and the next match then pairs that string's CLOSING quote with
# the following string's OPENING quote - so the gap between two literals (', ')
# is matched as content and the real string after it is eaten as a delimiter.
#
# It skipped four live strings in garbh_data.dart, each sitting after an emoji
# icon: GarbhPuzzle('Word Search', '🔤', 'Find the hidden words…'). Silently -
# they were simply never offered for translation. Emoji-as-icon is common in
# this codebase, so the blast radius was every file using that shape.
#
# Match everything, then filter with skip(). The same note is on the LITERAL in
# tool/hindi_progress.py, where this was found first.
#
# The `(?<!_t\()` lookbehind this used to carry was the SAME MISTAKE in another
# form. It existed to leave already-converted `_t('en', 'hi')` alone, but a
# lookbehind skips the OPENING quote - which strands the scanner inside the
# string, so that string's CLOSING quote becomes the next match's opening one
# and the Dart between two literals is captured as content. can_i_data.dart,
# which uses single-argument `_t('…')`, produced worklist rows reading
# `), why: _t(` and `), aliases: [` - fragments of source code offered up for
# translation, and one bad applier run away from being replaced by Hindi.
#
# Never skip a quote. Match every literal so the scan stays in phase, then use
# already_converted() to decide what to leave alone.
LITERAL = re.compile(r"""(['"])((?:\\.|(?!\1).)*?)\1""")


NEVER_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                          'hindi', '_never_translate.tsv')


def never_translate():
    """Strings code reads rather than renders - see the file for each reason."""
    out = set()
    try:
        for line in open(NEVER_PATH, encoding='utf-8'):
            if line.startswith('#') or not line.strip():
                continue
            out.add(line.rstrip('\n').partition('\t')[0])
    except FileNotFoundError:
        pass
    return out


NEVER = never_translate()


def already_converted(src, start):
    """Is the literal at [start] the first argument of a `_t(` call?"""
    return src[max(0, start - 3):start] == '_t('


def literal_runs(src, comments):
    """Adjacent string literals grouped into ONE unit, as Dart reads them.

    Dart concatenates adjacent literals, which is how long prose is written
    here:

        whyImportant:
            'A scan does not give a diagnosis '
            'or a prediction. It gives a measurement.',

    That is ONE sentence to a mother and one row in a glossary, but three
    matches to a literal-by-literal scan. So a worklist built naively asks for
    translations of ' or a prediction. ' as a standalone phrase, and a glossary
    keyed on whole sentences matches nothing at all.

    It cost a full agent run: 399 of 414 fragments already had committed Hindi
    in g_tests_scans.tsv, keyed on the joined sentence, and the applier could
    not see it.

    Yields (start, end, text, raw) where [text] is the joined, unescaped
    sentence and [raw] is the original source slice, so the applier can keep
    the author's line breaks in the English half.
    """
    runs = []
    current = []
    for m in LITERAL.finditer(src):
        if in_any(m.start(), comments) or already_converted(src, m.start()):
            if current:
                runs.append(current)
                current = []
            continue
        # Only whitespace between two literals means Dart joins them. Anything
        # else - a comma, a bracket - makes them separate arguments.
        if current and src[current[-1].end():m.start()].strip():
            runs.append(current)
            current = []
        current.append(m)
    if current:
        runs.append(current)

    out = []
    for group in runs:
        text = ''.join(unescape(m.group(2), m.group(1)) for m in group)
        out.append((group[0].start(), group[-1].end(), text,
                    src[group[0].start():group[-1].end()]))
    return out


HAS_WORD = re.compile(r'[A-Za-z]{3,}')
DEVANAGARI = re.compile(r'[ऀ-ॿ]')
IDENT = re.compile(r'^[a-z][a-z0-9_]*$')


def unescape_tsv(s):
    r"""A TSV cell's `\n` becomes a real newline; a real tab cannot occur."""
    return s.replace('\\n', '\n')


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
    return (text in NEVER
            or not HAS_WORD.search(text)
            or DEVANAGARI.search(text)
            or IDENT.match(text)
            or text.startswith(('package:', 'http', 'assets/'))
            or text.endswith(('.dart', '.png', '.jpg', '.json')))


def comment_spans(src):
    """Character ranges that are Dart comments, so literals inside them are
    left alone.

    The literal scanner is a regex over the whole file, which cannot tell code
    from prose. Any apostrophe-bearing comment - `// today's connection` - can
    pair with a later quote and be rewritten into `_t(...)` INSIDE the comment.
    That compiles, so nothing catches it; the damage is a mangled explanation.

    This has to track string state as well as comment state, because `//` and
    `/*` occur inside real strings ('http://…' is the common one) and treating
    those as comment starts would blind the scanner to the rest of the file.
    """
    spans = []
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if c in '\'"':
            quote, i = c, i + 1
            while i < n and src[i] != quote:
                i += 2 if src[i] == '\\' else 1
            i += 1
        elif c == '/' and i + 1 < n and src[i + 1] == '/':
            start = i
            while i < n and src[i] != '\n':
                i += 1
            spans.append((start, i))
        elif c == '/' and i + 1 < n and src[i + 1] == '*':
            start = i
            end = src.find('*/', i + 2)
            i = n if end < 0 else end + 2
            spans.append((start, i))
        else:
            i += 1
    return spans


def in_any(pos, spans):
    return any(a <= pos < b for a, b in spans)


def untranslated(path, glossary):
    """Literals in [path] that [glossary] does not cover, in source order.

    Shares the matching rules above on purpose: a second copy of the escaping
    and skip logic would drift, and then the worklist would disagree with the
    applier about what is left to do.
    """
    src = open(path, encoding='utf-8').read()
    out = []
    for _s, _e, text, _raw in literal_runs(src, comment_spans(src)):
        if skip(text) or text in glossary or text in out:
            continue
        out.append(text)
    return out


def load(tsv):
    r"""English -> Hindi, with both columns normalised to real newlines.

    Two bugs live in not normalising here. Reading: unescape() turns \n in the
    SOURCE into a real newline, so a multi-line literal could never match a
    glossary key that still held the two-character escape - and if that string
    also contained an escaped quote, the raw-form fallback missed too, because
    the glossary holds a bare ". Writing: literal() escapes backslashes BEFORE
    newlines, so a Hindi value still holding \n came out as \\n - a visible
    backslash in front of a mother, which is how this last shipped.
    """
    glossary = {}
    for line in open(tsv, encoding='utf-8'):
        line = line.rstrip('\n')
        if not line.strip() or line.startswith('#'):
            continue
        en, _, hi = line.partition('\t')
        if hi.strip():
            glossary[unescape_tsv(en.strip())] = unescape_tsv(hi.strip())
    return glossary


def main():
    path, tsv = sys.argv[1], sys.argv[2]
    dry = '--dry' in sys.argv

    glossary = load(tsv)

    src = open(path, encoding='utf-8').read()
    hit, unmatched = [], []

    # Runs, not single literals: adjacent literals are one sentence to Dart and
    # one row in a glossary. Rewritten back-to-front so earlier offsets stay
    # valid while the string is being spliced.
    out = src
    for start, end, text, raw in reversed(literal_runs(src, comment_spans(src))):
        if skip(text):
            continue
        # Both sides are real text by now (see the loader), so this is a
        # straight comparison - no escape-form guessing, which is what made
        # the old two-attempt lookup silently miss.
        hi = glossary.get(text)
        if hi is None:
            unmatched.append(text)
            continue
        hit.append(text)
        # [raw] keeps the author's own line breaks in the English half; the
        # Hindi becomes one literal, because re-splitting a translation across
        # the English fragment boundaries would put the breaks in the wrong
        # places for a different language.
        out = out[:start] + f'_t({raw}, {literal(hi)})' + out[end:]
    unmatched.reverse()

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
        if imports:
            at = imports[-1].end()
            out = out[:at] + f"\nimport '{rel}';" + out[at:]
        else:
            # A file with no imports starts with its banner comment, and the
            # newline belongs AFTER the import, not before it. Getting this
            # backwards welded the import onto the first comment line -
            # `import '...';// ===` - which Dart accepts, so it survives
            # analyze and only shows up as a mangled file header.
            out = f"import '{rel}';\n\n" + out

    open(path, 'w', encoding='utf-8', newline='').write(out)
    print('  written — now widen the field types and fix read sites')


# Guarded so load()/untranslated() can be imported. Working out which literals
# a glossary does NOT cover needs exactly the matching rules above, and a
# second copy of them would drift from these.
if __name__ == '__main__':
    main()
