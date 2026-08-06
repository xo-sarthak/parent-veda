"""Undo `_t('en', 'hi')` back to `'en'`, optionally only outside named fields.

Needed when a glossary is applied too widely. community_data.dart was the case:
apply_glossary converted all 490 literals, but CommunityPost and
CommunityComment are PERSISTED records - toJson/fromJson round-trip them to
SharedPreferences and Supabase - and their model is shared with posts a mother
writes herself, which have no translation and never will. Widening `text` there
would change a JSON schema that already has rows in it.

Only Community (the room definition) is static content, and it does not
serialize, so only its name/description may widen.

    python tool/unwrap_t.py <file.dart> [--keep field[,field…]] [--dry]

--keep names the fields whose _t() calls SURVIVE. Everything else is unwrapped
to its English first argument. Without --keep, every _t() is unwrapped.
"""

import re
import sys


def calls(src, marker='_t('):
    """(start, end, [(argstart, argend)…]) for each paren-balanced call."""
    out = []
    for m in re.finditer(re.escape(marker), src):
        # Never touch the helper's own DECLARATION. `LocalizedText _t(String
        # en, String hi) => …` contains the marker, and unwrapping it to its
        # first argument produced `LocalizedText String en => …` - which took
        # the whole file down with a confusing "String isn't a type".
        if src[max(0, m.start() - 14):m.start()].endswith('LocalizedText '):
            continue
        i, depth, args, arg_start, quote = m.end(), 1, [], m.end(), None
        while i < len(src) and depth:
            c = src[i]
            if quote:
                if c == '\\':
                    i += 2
                    continue
                if c == quote:
                    quote = None
            elif c in '\'"':
                quote = c
            elif c == '(':
                depth += 1
            elif c == ')':
                depth -= 1
                if not depth:
                    args.append((arg_start, i))
            elif c == ',' and depth == 1:
                args.append((arg_start, i))
                arg_start = i + 1
            i += 1
        if depth == 0:
            out.append((m.start(), i, args))
    return out


def field_before(src, at):
    """The `name:` label immediately preceding position [at], if any."""
    head = src[max(0, at - 60):at]
    m = re.search(r'(\w+):\s*(?:\[\s*)?$', head)
    return m.group(1) if m else None


def main():
    path = sys.argv[1]
    dry = '--dry' in sys.argv
    keep = set()
    if '--keep' in sys.argv:
        keep = set(sys.argv[sys.argv.index('--keep') + 1].split(','))

    src = open(path, encoding='utf-8').read()
    kept = unwrapped = 0
    # Back-to-front so earlier offsets stay valid.
    for start, end, args in reversed(calls(src)):
        if keep and field_before(src, start) in keep:
            kept += 1
            continue
        if not args:
            continue
        src = src[:start] + src[args[0][0]:args[0][1]].strip() + src[end:]
        unwrapped += 1

    print(path + ': unwrapped ' + str(unwrapped) + ', kept ' + str(kept))
    if dry:
        print('  (dry run - nothing written)')
        return
    open(path, 'w', encoding='utf-8', newline='').write(src)


if __name__ == '__main__':
    main()
