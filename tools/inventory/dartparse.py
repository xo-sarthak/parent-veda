# =============================================================================
#  dartparse.py -- a small reader for the app's Dart DATA files
# -----------------------------------------------------------------------------
#  The content inventories have to count what is actually in the app, not what
#  a person remembers being there. Every seed list in this codebase is a Dart
#  literal -- `const [ Foo(id: 'x', title: _en('...'), ...), ... ]` -- so a
#  reader that understands constructor calls, named arguments, strings and
#  nesting can count them exactly.
#
#  ⚠️ IT IS NOT A DART PARSER AND MUST NOT PRETEND TO BE. It knows literals,
#  identifiers, calls and lists. It does not know expressions, conditionals or
#  generics, and it does not need to: these files are data written by hand in
#  a consistent shape. Where it cannot read something it returns the raw text
#  rather than guessing, so a caller can see it failed instead of counting a
#  wrong number.
#
#  Used by the per-stage inventory emitters in this folder.
# =============================================================================

import re


def strip_comments(src):
    """Remove // and /* */ comments without touching string contents.

    ⚠️ THE STRING CHECK IS THE WHOLE POINT. This codebase's comments are
    enormous and full of quotes and slashes, and its strings contain '//' in
    URLs. A regex that strips comments without tracking whether it is inside a
    string mangles every Unsplash URL in the app.
    """
    out = []
    i, n = 0, len(src)
    quote = None
    while i < n:
        c = src[i]
        if quote:
            out.append(c)
            if c == '\\':
                if i + 1 < n:
                    out.append(src[i + 1])
                    i += 2
                    continue
            elif c == quote:
                quote = None
            i += 1
            continue
        if c in "'\"":
            quote = c
            out.append(c)
            i += 1
            continue
        if c == '/' and i + 1 < n:
            if src[i + 1] == '/':
                j = src.find('\n', i)
                i = n if j < 0 else j
                continue
            if src[i + 1] == '*':
                j = src.find('*/', i + 2)
                i = n if j < 0 else j + 2
                continue
        out.append(c)
        i += 1
    return ''.join(out)


def _match(src, i, open_ch, close_ch):
    """Index just past the bracket that closes the one at `i`."""
    depth, n = 0, len(src)
    quote = None
    while i < n:
        c = src[i]
        if quote:
            if c == '\\':
                i += 2
                continue
            if c == quote:
                quote = None
            i += 1
            continue
        if c in "'\"":
            quote = c
        elif c == open_ch:
            depth += 1
        elif c == close_ch:
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return n


def calls(src, name, nested=False):
    """Every `Name(...)` call in `src`, as (start, end, body) triples.

    `nested=False` skips calls that sit inside another call of the same name,
    which is what you want when counting top-level entries in a seed list.
    """
    out = []
    for m in re.finditer(r'\b%s\s*\(' % re.escape(name), src):
        start = m.start()
        if not nested and out and start < out[-1][1]:
            continue
        end = _match(src, m.end() - 1, '(', ')')
        out.append((start, end, src[m.end():end - 1]))
    return out


def entries(src, name, nested=False):
    """Like [calls], but skips the class's own CONSTRUCTOR DEFINITION.

    ⚠️ `const ContentSlot({required this.title, ...})` LOOKS EXACTLY LIKE AN
    ENTRY to a reader that only matches `Name(`. Where a model and its seed
    list share a file, every such class contributed one phantom row — and it
    surfaced as a film in the commissioning sheet titled "ContentSlot", which
    somebody would have had to go and shoot.

    A definition is recognisable: its arguments assign to `this.`, and it has
    no values. That is a shape no data entry has.
    """
    out = []
    for st, en, b in calls(src, name, nested=nested):
        if re.search(r'\bthis\.[A-Za-z_]', b) and not _STR.search(b):
            continue
        out.append((st, en, b))
    return out


def count(src, name):
    return len(calls(src, name))


_STR = re.compile(r"""(?:_en|_same|_t|_p)?\s*\(?\s*(['"])((?:\\.|(?!\1).)*)\1""", re.S)


def arg(body, key, depth=0):
    """The value of a named argument, as raw text. None when absent.

    Only reads arguments at the TOP level of `body`, so `title:` inside a
    nested `Foo(title: ...)` does not shadow the outer one.
    """
    i, n = 0, len(body)
    quote = None
    depth_p = depth_b = depth_c = 0
    pat = re.compile(r'\b%s\s*:' % re.escape(key))
    while i < n:
        c = body[i]
        if quote:
            if c == '\\':
                i += 2
                continue
            if c == quote:
                quote = None
            i += 1
            continue
        if c in "'\"":
            quote = c
            i += 1
            continue
        if c == '(':
            depth_p += 1
        elif c == ')':
            depth_p -= 1
        elif c == '[':
            depth_b += 1
        elif c == ']':
            depth_b -= 1
        elif c == '{':
            depth_c += 1
        elif c == '}':
            depth_c -= 1
        if depth_p == depth_b == depth_c == 0:
            m = pat.match(body, i)
            if m:
                j = m.end()
                # to the next top-level comma
                k, q2 = j, None
                dp = db = dc = 0
                while k < n:
                    ch = body[k]
                    if q2:
                        if ch == '\\':
                            k += 2
                            continue
                        if ch == q2:
                            q2 = None
                        k += 1
                        continue
                    if ch in "'\"":
                        q2 = ch
                    elif ch == '(':
                        dp += 1
                    elif ch == ')':
                        dp -= 1
                    elif ch == '[':
                        db += 1
                    elif ch == ']':
                        db -= 1
                    elif ch == '{':
                        dc += 1
                    elif ch == '}':
                        dc -= 1
                    elif ch == ',' and dp == db == dc == 0:
                        break
                    k += 1
                return body[j:k].strip()
        i += 1
    return None


def split_args(inner):
    """Split a call's inner text on TOP-LEVEL commas."""
    out, depth, quote, start = [], 0, None, 0
    skip = False
    for i, c in enumerate(inner):
        if skip:
            skip = False
            continue
        if quote:
            if c == '\\':
                skip = True
            elif c == quote:
                quote = None
            continue
        if c in "'\"":
            quote = c
        elif c in '([{':
            depth += 1
        elif c in ')]}':
            depth -= 1
        elif c == ',' and depth == 0:
            out.append(inner[start:i])
            start = i + 1
    out.append(inner[start:])
    return out


def english(v):
    """The ENGLISH half of a localized value, as it renders.

    ⚠️ `_t(en, hi)` HOLDS BOTH LANGUAGES AND NAIVELY JOINING THEM IS WRONG.
    Concatenating every quoted run in `_t('Male fertility', 'Male fertility')`
    yields "Male fertilityMale fertility", which is how an inventory ends up
    reporting doubled titles -- and it did, on the first run of this parser.

    So: if the value is a call with more than one top-level argument, only the
    first is English. Adjacent runs WITHIN that argument are still joined,
    because Dart splits long strings by juxtaposition and the reader sees them
    as one sentence.
    """
    if v is None:
        return None
    v = v.strip()
    # ⚠️ `LocalizedText(en: '...', hi: '...')` IS WRITTEN OUT IN FULL IN SOME
    # DATA FILES rather than through the `_t` helper, and it has NAMED
    # arguments, so "first argument" is not the English one -- it is whichever
    # the author typed first. Reading it positionally produced titles like
    # "What the anomaly scan looks atWhat the anomaly scan looks at" in the
    # content-slot rows. Take the named `en:` when it is there.
    m = re.match(r'^LocalizedText\s*\(', v)
    if m:
        end = _match(v, m.end() - 1, '(', ')')
        inner = v[m.end():end - 1]
        for part in split_args(inner):
            if re.match(r'^\s*en\s*:', part):
                parts = [x.group(2) for x in _STR.finditer(part)]
                if parts:
                    return ''.join(p.replace("\\'", "'").replace('\\"', '"')
                                   for p in parts)
    m = re.match(r'^(?:_en|_same|_t|_p)?\s*\(', v)
    if m:
        end = _match(v, m.end() - 1, '(', ')')
        first = split_args(v[m.end():end - 1])[0]
    else:
        first = v
    parts = [x.group(2) for x in _STR.finditer(first)]
    if not parts:
        return first.strip()
    return ''.join(p.replace("\\'", "'").replace('\\"', '"') for p in parts)


def text(body, key):
    """A named argument's English string value. See [english]."""
    return english(arg(body, key))


def all_text(body):
    """Every string anywhere in `body`, joined. For word counts."""
    return ' '.join(m.group(2) for m in _STR.finditer(body))


def words(body):
    return len(all_text(body).split())


def ident(body, key):
    """A named argument that is an identifier or enum, e.g. `PvNextKind.tool`."""
    v = arg(body, key)
    return v.strip() if v else None


def number(body, key):
    v = arg(body, key)
    if not v:
        return None
    m = re.search(r'-?\d+(?:\.\d+)?', v)
    return float(m.group(0)) if m else None
