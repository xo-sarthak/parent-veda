"""Move hardcoded UI copy into the string table.

The translation passes reach content, not code. A string written straight into
a widget - `Text('Ready for Birth')` - stays English on a Hindi phone, sitting
inside a screen that is otherwise Devanagari. That reads worse than a screen
that was never translated at all.

This lifts every plain literal into `app_language.dart` as a `_p(en, hi)`
getter and rewrites the call site to read it. The Hindi side starts as a copy
of the English, which puts these strings into exactly the shape the existing
dump/apply pipeline already translates.

Strings carrying `$interpolation` are LEFT ALONE. They need a method with
parameters whose names differ per call site, so they are a hand job, not a
sweep - and a sweep that guessed would produce code that compiles and lies.

    python tool/extract_inline_strings.py --dry
    python tool/extract_inline_strings.py --write
"""

import glob
import os
import re
import sys

SKIP = ('/post_pregnancy/', '/ttc/', '/doctor/', '/enterprise/',
        '/localization/', '/data/')

# `const` is captured so it can be DROPPED: `S.now.x` is a getter, so
# `const Text(S.now.x)` is not a compile-time constant. Outer const containers
# (`const Column(children: [Text('…')])`) cannot be seen from here - those
# surface as analyzer errors, which is the loud failure we want.
LITERAL = re.compile(
    r"""((?:const\s+)?)(Text\(\s*)(['"])((?:\\.|(?!\3).){3,}?)\3(\s*[,)])""")
NAMED = re.compile(
    r"""\b(hintText|labelText|tooltip|title|label)(:\s*)(['"])((?:\\.|(?!\3).){3,}?)\3""")
HAS_WORD = re.compile(r'[A-Za-z]{3,}')
DEVANAGARI = re.compile(r'[ऀ-ॿ]')
INTERP = re.compile(r'\$\{[^}]*\}|\$\w+')
STOP = {'the', 'a', 'an', 'to', 'of', 'and', 'or', 'is', 'in', 'for', 'your',
        'you', 'it', 'this', 'that', 'with', 'on', 'at', 'be'}


def wanted(text):
    if DEVANAGARI.search(text) or INTERP.search(text):
        return False
    if not HAS_WORD.search(text):
        return False
    return text.strip() != 'ParentVeda'


def getter_name(text, taken):
    """A stable, readable identifier derived from the copy itself."""
    words = re.findall(r'[A-Za-z]+', text)
    keep = [w for w in words if w.lower() not in STOP] or words
    stem = keep[0].lower() + ''.join(w.capitalize() for w in keep[1:4])
    stem = re.sub(r'[^A-Za-z]', '', stem)[:34] or 'label'
    name = 'ui' + stem[0].upper() + stem[1:]
    if name in taken and taken[name] != text:
        i = 2
        while f'{name}{i}' in taken and taken[f'{name}{i}'] != text:
            i += 1
        name = f'{name}{i}'
    taken[name] = text
    return name


def dart_literal(text):
    """Re-emit captured source text as a Dart literal.

    The text arrives as it was WRITTEN, so an escape in the source is two real
    characters here. Escaping again turns `\\'` into a visible backslash and
    `\\n` into the letter n - it compiles, and it is wrong on screen. Unescape
    first, then escape once. If the copy contains a quote, prefer the other
    delimiter over an escape; it reads better in the table.
    """
    plain = (text.replace('\\' + "'", "'")
                 .replace('\\' + '"', '"')
                 .replace('\\' + 'n', '\n')
                 .replace('\\' + '\\', '\\'))
    if "'" in plain and '"' not in plain:
        body = plain.replace('\\', '\\\\').replace('\n', '\\n')
        return '"' + body + '"'
    body = (plain.replace('\\', '\\\\')
                 .replace("'", "\\'")
                 .replace('\n', '\\n'))
    return "'" + body + "'"


def import_line(path):
    """Relative import of app_language.dart from `path`."""
    rel = os.path.relpath('lib/localization/app_language.dart',
                          os.path.dirname(path)).replace(os.sep, '/')
    return f"import '{rel}';"


def main():
    write = '--write' in sys.argv
    taken, per_file, order = {}, {}, []

    for path in sorted(glob.glob('lib/**/*.dart', recursive=True)):
        norm = path.replace(os.sep, '/')
        if any(s in norm for s in SKIP):
            continue
        src = open(path, encoding='utf-8').read()
        edits = []

        def sub_literal(m):
            text = m.group(4)
            if not wanted(text):
                return m.group(0)
            name = getter_name(text, taken)
            if name not in [o[0] for o in order]:
                order.append((name, text))
            edits.append(name)
            # group(1) is any leading `const `, deliberately not re-emitted
            return f'{m.group(2)}S.now.{name}{m.group(5)}'

        def sub_named(m):
            text = m.group(4)
            if not wanted(text):
                return m.group(0)
            name = getter_name(text, taken)
            if name not in [o[0] for o in order]:
                order.append((name, text))
            edits.append(name)
            return f'{m.group(1)}{m.group(2)}S.now.{name}'

        out = LITERAL.sub(sub_literal, src)
        out = NAMED.sub(sub_named, out)
        if not edits:
            continue
        if 'localization/app_language.dart' not in out:
            imports = list(re.finditer(r"^import .*;$", out, re.M))
            at = imports[-1].end() if imports else 0
            out = out[:at] + '\n' + import_line(path) + out[at:]
        per_file[norm] = (len(edits), out)

    print(f'{len(order)} distinct getters across {len(per_file)} files')
    for f, (n, _) in sorted(per_file.items(), key=lambda kv: -kv[1][0])[:12]:
        print(f'  {n:>4}  {f}')

    if not write:
        print('\n(dry run - pass --write to apply)')
        return

    for f, (_, out) in per_file.items():
        open(f, 'w', encoding='utf-8', newline='').write(out)

    block = ['', '  // ' + '=' * 73, '  //  INLINE UI COPY - lifted out of widgets so it can be translated',
             '  // ' + '=' * 73]
    for name, text in order:
        lit = dart_literal(text)
        block.append(f'  String get {name} => _p({lit}, {lit});')
    lang = open('lib/localization/app_language.dart', encoding='utf-8').read()
    end = lang.rstrip().rfind('}')
    lang = lang[:end] + '\n'.join(block) + '\n' + lang[end:]
    open('lib/localization/app_language.dart', 'w', encoding='utf-8',
         newline='').write(lang)
    print(f'\nwrote {len(order)} getters + {len(per_file)} rewritten files')


main()
